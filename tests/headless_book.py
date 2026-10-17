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
        assert not view['clip'] or Path(view['clip']).is_file(), view['clip']
        for control in controls:
            choice = choices[control['choice']]
            assert (control['kind'], control['label']) == (choice['kind'], choice['label'])
            assert 0 <= control['x'] < control['x'] + control['width'] <= self.width
            assert 0 <= control['y'] < control['y'] + control['height'] <= self.height
            assert control['circle'] == (choice['kind'] == 'object')
            assert control['item'] == (choice['kind'] in ('item', 'pda'))
        # Every circle shows its label as a caption that collides with nothing else.
        def box(r):
            return (r['x'], r['y'], r['x'] + r['width'], r['y'] + r['height'])

        def overlaps(a, b):
            return a[0] < b[2] and b[0] < a[2] and a[1] < b[3] and b[1] < a[3]

        circles = [c for c in controls if c['circle'] or c['item']]
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
                    if other['circle'] or other['item']:
                        assert not overlaps(caption, box(other['caption'])), (control['label'], other['label'])
        if view['kind'] == 'room':
            assert choices
            # Art determines which object anchors project into this camera; carried things sit in a row.
            # A talk has no circles: ask-lines, one end line under them, and the carried things.
            objects = [i for i in indices if choices[i]['kind'] == 'object']
            items = [c for c in choices if c['kind'] in ('item', 'pda')]
            lines = [c for c in choices if c['kind'] in ('ask', 'end')]
            keys = [c for c in choices if c['kind'] == 'key']
            assert sum(c['kind'] == 'pda' for c in choices) <= 1 and not (keys and not view['keypad'])
            if lines:
                assert not objects and not view['hotspots'] and view['talk']
                assert not any(c['kind'] == 'pda' for c in choices), 'the PDA is put away in a conversation'
                assert sum(c['kind'] == 'end' for c in lines) == 1
                assert all(c['command'] and c['object'] == '' for c in lines + keys)
                assert len(lines) + len(items) + len(keys) == len(choices)
                end = next(c for c in controls if c['kind'] == 'end')
                for key in (c for c in controls if c['kind'] == 'key'):
                    assert key['y'] + key['height'] <= end['y'] + 0.5, (key, end)
                asked = [c for c in controls if c['kind'] == 'ask']
                for line in asked:
                    assert line['y'] + line['height'] <= end['y'] + 0.5, (line, end)
                    assert not overlaps(box(line), box(end)), (line['label'], end['label'])
                for i, line in enumerate(asked):
                    for other in asked[:i]:
                        assert not overlaps(box(line), box(other)), (line['label'], other['label'])
            else:
                assert sorted(objects) == sorted(h['choice'] for h in view['hotspots'])
                assert all(c['kind'] in ('object', 'item') and c['object'] and c['command'] or
                           c['kind'] == 'pda' and c['command'] for c in choices)
                assert len(objects) + len(items) == len(choices), (view['image'], view['held'], choices, indices)
            assert all(Path(c['icon']).is_file() for c in items if c['kind'] == 'item'), items
            assert view['held'] in [''] + [c['object'] for c in items], view['held']
        elif view['kind'] == 'beat':
            if choices:
                # A document, or a prose-book passage: one Continue, and the text is on the page.
                assert len(choices) == 1 and choices[0]['kind'] == 'continue' and choices[0]['label']
                assert choices[0]['command'] == '' and choices[0]['object'] == ''
                assert not view['hotspots'] and len(controls) == 1
                assert view['text']
            else:
                # A shot. The clip ends, or a tap on the picture, and there is no Next.
                assert not view['read'] and view['text'] == ''
                assert not view['hotspots'] and not controls
        else:
            # An ending offers exactly one button: try again, or start over after the success.
            assert view['kind'] == 'ended' and view['ending'] in ('success', 'partial', 'failure'), view
            assert len(choices) == 1 and choices[0]['kind'] == 'retry' and choices[0]['command'], choices
            assert not view['hotspots'] and len(controls) == 1 and not controls[0]['circle']
        assert (view['ending'] != '') == (view['kind'] == 'ended'), view
        assert view['held'] == '' or view['kind'] == 'room', view

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

    def hold(self, item):
        """Tap a carried thing in the inventory row, as the reader would."""
        index = next(i for i, choice in enumerate(self.view['choices'])
                     if choice['kind'] == 'item' and choice['command'] == item)
        return self.tap_choice(index)

    def continue_page(self):
        """Dismiss a document by its Continue button, or finish a shot."""
        assert self.view['kind'] == 'beat'
        if self.view['choices']:
            return self.tap_choice(0)
        return self.send(':continue')

    def retry(self):
        assert self.view['kind'] == 'ended'
        return self.tap_choice(0)

    def close(self):
        self.process.stdin.close()
        assert self.process.wait(timeout=10) == 0, self.process.stderr.read()
