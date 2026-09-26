"""Drive a compiled book through its headless page interface and check the page contract.

Each book's test (`tests/test_<name>.py`) builds on this: it reads published pages,
activates published choices and taps the real Continue control.
"""
import json
from pathlib import Path
import subprocess


class Book:
    def __init__(self, binary, root, name, viewport=(1100, 800)):
        self.width, self.height = viewport
        self.root, self.name = Path(root), name
        self.process = subprocess.Popen(
            [str(binary), '--root', str(root), '--book', name, '--headless', '--viewport', *map(str, viewport)],
            cwd='/tmp', stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, text=True)
        self.view = self.read()

    def image(self, camera):
        """The painting for a camera when it exists, else the camera's reference render."""
        painted = self.root / f'books/{self.name}/illustrations/{camera}.png'
        return painted if painted.exists() else self.root / f'books/{self.name}/rooms/{camera}.jpg'

    def camera(self):
        return Path(self.view['image']).stem

    def read(self):
        line = self.process.stdout.readline()
        if not line:
            raise AssertionError(self.process.stderr.read())
        self.view = json.loads(line)
        self.assert_page_contract()
        return self.view

    def assert_page_contract(self):
        view = self.view
        choices, controls = view['choices'], view['controls']
        indices = [c['choice'] for c in controls]
        assert len(indices) == len(set(indices)) and all(0 <= i < len(choices) for i in indices), view
        for control in controls:
            choice = choices[control['choice']]
            assert (control['kind'], control['label']) == (choice['kind'], choice['label'])
            assert 0 <= control['x'] < control['x'] + control['width'] <= self.width
            assert 0 <= control['y'] < control['y'] + control['height'] <= self.height
            assert control['circle'] == (choice['kind'] == 'object')
        # Every circle shows its label as a caption that collides with nothing else.
        def box(r):
            return (r['x'], r['y'], r['x'] + r['width'], r['y'] + r['height'])

        def overlaps(a, b):
            return a[0] < b[2] and b[0] < a[2] and a[1] < b[3] and b[1] < a[3]

        circles = [c for c in controls if c['circle']]
        text = view['text_region']
        regions = view['text_regions']
        assert '\f'.join(r['text'] for r in regions) == view['text']
        for i, region in enumerate(regions):
            assert region['font_size'] + .01 >= 38 * self.height/800, region
            assert region['content_height'] <= region['height'] + .01, (view['image'], region)
            assert 0 <= region['x'] < region['x'] + region['width'] <= self.width
            assert 0 <= region['y'] < region['y'] + region['height'] <= self.height
            for other in regions[:i]:
                assert not overlaps(box(region), box(other)), (region, other)
            for control in controls:
                assert not overlaps(box(region), box(control)), (view['image'], region, control)
        prose = [box(r) for r in regions if r['authored']]
        for control in circles:
            caption = box(control['caption'])
            assert control['caption']['width'] > 0 and control['caption']['height'] > 0, control
            assert 0 <= caption[0] and caption[2] <= self.width and 0 <= caption[1] and caption[3] <= self.height, control
            assert all(not overlaps(caption, r) for r in prose), (control['label'], regions)
            for other in controls:
                if other is not control:
                    assert not overlaps(caption, box(other)), (control['label'], other['label'])
                    if other['circle']:
                        assert not overlaps(caption, box(other['caption'])), (control['label'], other['label'])
        if view['kind'] == 'room':
            assert choices
            # Art determines which object anchors project into this camera.
            assert sorted(indices) == sorted(h['choice'] for h in view['hotspots'])
            assert all(c['kind'] == 'object' and c['object'] and c['command'] for c in choices)
        elif view['kind'] == 'beat':
            assert choices == [{'kind': 'continue', 'label': 'Дальше', 'command': '', 'object': ''}]
            assert not view['hotspots'] and len(controls) == 1
        else:
            # An ending offers exactly one button: try again, or start over after the success.
            assert view['kind'] == 'ended' and view['ending'] in ('success', 'partial', 'failure'), view
            assert len(choices) == 1 and choices[0]['kind'] == 'retry' and choices[0]['command'], choices
            assert not view['hotspots'] and len(controls) == 1 and not controls[0]['circle']
        assert (view['ending'] != '') == (view['kind'] == 'ended'), view

    def send(self, command):
        self.process.stdin.write(command + '\n')
        self.process.stdin.flush()
        return self.read()

    def choose(self, command):
        index = next(i for i, choice in enumerate(self.view['choices'])
                     if choice['command'] == command)
        return self.send(f':choose {index}')

    def tap_choice(self, index):
        control = next(c for c in self.view['controls'] if c['choice'] == index)
        return self.send(f":tap {control['x'] + control['width'] / 2} {control['y'] + control['height'] / 2}")

    def continue_page(self):
        assert self.view['kind'] == 'beat'
        return self.tap_choice(0)

    def retry(self):
        assert self.view['kind'] == 'ended'
        return self.tap_choice(0)

    def close(self):
        self.process.stdin.close()
        assert self.process.wait(timeout=10) == 0, self.process.stderr.read()
