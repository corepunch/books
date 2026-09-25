#!/usr/bin/env python3
"""Exercise the C Three Stars adventure through its headless page interface."""
import json
from itertools import permutations
from pathlib import Path
import subprocess
import sys

binary, root = (Path(value).resolve() for value in sys.argv[1:3])


class Book:
    def __init__(self):
        self.process = subprocess.Popen(
            [str(binary), '--root', str(root), '--book', 'three-stars', '--headless'],
            cwd='/tmp', stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, text=True)
        self.view = self.read()

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
            assert 0 <= control['x'] < control['x'] + control['width'] <= 1100
            assert 0 <= control['y'] < control['y'] + control['height'] <= 800
            assert control['circle'] == (choice['kind'] == 'object')
        if view['kind'] == 'room':
            assert choices
            # Art determines which object anchors project into this camera.
            assert sorted(indices) == sorted(h['choice'] for h in view['hotspots'])
            assert all(c['kind'] == 'object' and c['object'] and c['command'] for c in choices)
        elif view['kind'] == 'beat':
            assert choices == [{'kind': 'continue', 'label': 'Дальше', 'command': '', 'object': ''}]
            assert not view['hotspots'] and len(controls) == 1
        else:
            assert view['kind'] == 'ended' and not choices and not controls and not view['hotspots']

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

    def close(self):
        self.process.stdin.close()
        assert self.process.wait(timeout=10) == 0, self.process.stderr.read()


# Reuse slot zero through different page kinds, execute the actual published choice,
# and check that aliases cannot bypass that choice or invoke stale room commands.
b = Book()
initial = b.view
for invalid in (':choose -1', ':choose 9999', ':choose nope', ':continue', ':back', ':focus pearlstar'):
    assert b.send(invalid) == initial
b.tap_choice(1)  # The reported failure: floor -> book stairs -> intermediate page.
assert b.view['image'].endswith('/floor-climb-table.png') and b.view['overlay'] == ''
beat = b.view
for ignored in (':choose 1', 'go table', 'take brass-star', ':focus book-stairs', ':reload'):
    assert b.send(ignored) == beat
button = beat['controls'][0]
assert b.send(f":tap {button['x'] - 1} {button['y']}") == beat
assert b.send(f":tap {button['x'] + button['width']} {button['y']}") == beat
b.send(':choose 0')  # This used to fail while the :continue shortcut passed.
assert b.view['kind'] == 'room' and b.view['image'].endswith('/table-show-cleared-desk.png')
assert b.view['overlay'].endswith('/copper-star-table-show-desk.png')
for alias in (':continue', ':back'):
    b.choose('go floor')
    b.send(alias)
    assert b.view['kind'] == 'room' and b.view['room'] == 'attic-floor'
    b.choose('go table')
    b.continue_page()
b.close()

b = Book()
assert b.view['room'] == 'attic-floor'
assert Path(b.view['image']) == root / 'books/three-stars/illustrations/floor-show-cleared-room.png'
assert b.view['overlay'].endswith('/brass-star-floor-show-room.png')
assert {choice['command'] for choice in b.view['choices']} == {'take brass-star', 'go table'}

b.choose('take brass-star')
assert b.view['kind'] == 'beat' and b.view['image'].endswith('/floor-take-gold-star.png')
assert b.view['overlay'] == ''
b.continue_page()
assert b.view['image'].endswith('/floor-show-cleared-room.png') and b.view['overlay'] == ''
b.choose('go table')
assert b.view['room'] == 'writing-desk' and b.view['image'].endswith('/floor-climb-table.png')
b.continue_page()
assert b.view['image'].endswith('/table-show-cleared-desk.png')
assert b.view['overlay'].endswith('/copper-star-table-show-desk.png')
b.choose('take copper-star')
b.continue_page()
assert b.view['image'].endswith('/table-show-cleared-desk.png') and b.view['overlay'] == ''
b.choose('go sill')
assert b.view['room'] == 'window-sill' and b.view['image'].endswith('/table-climb-sill.png')
b.continue_page()
assert b.view['image'].endswith('/sill-show-cleared-window.png')
assert b.view['overlay'].endswith('/pearl-star-sill-show-window.png')
b.choose('take pearl-star')
assert b.view['kind'] == 'beat' and b.view['image'].endswith('/sill-take-pearl-star.png')
assert b.view['overlay'] == ''
b.continue_page()
assert b.view['kind'] == 'ended' and b.view['image'].endswith('/attic-return-stars.png')
assert 'три звёздочки' in b.view['text'].lower()
b.close()

# All collection orders exercise both stairs in both directions, repeated page
# construction, cleared rooms, and endings reached from each possible room.
locations = ['attic-floor', 'writing-desk', 'window-sill']
stars = ['brass-star', 'copper-star', 'pearl-star']
for order in permutations(range(len(stars))):
    b = Book()
    for position, target in enumerate(order):
        while b.view['room'] != locations[target]:
            here = locations.index(b.view['room'])
            destination = here + (1 if target > here else -1)
            b.choose('go ' + ['floor', 'table', 'sill'][destination])
            b.continue_page()
        command = 'take ' + stars[target]
        b.choose(command)
        if position < len(stars) - 1:
            b.continue_page()
            assert command not in [c['command'] for c in b.view['choices']]
        else:
            pickup_image = ['floor-take-gold-star.png', 'table-take-copper-star.png',
                            'sill-take-pearl-star.png'][target]
            assert b.view['kind'] == 'beat' and b.view['image'].endswith('/' + pickup_image)
            b.continue_page()
            ending = b.view
            assert ending['kind'] == 'ended'
            for ignored in (':choose 0', ':continue', ':back', ':focus brassstar', 'inventory', ':reload'):
                assert b.send(ignored) == ending
    b.close()

for source in root.rglob('*'):
    if not source.is_file() or '.git' in source.parts or 'build' in source.parts:
        continue
    assert source.suffix.lower() not in {'.lua', '.zil'}, f'legacy adventure source remains: {source}'

print('Book: typed pages, shared controls, Continue dispatch, all collection orders and endings passed')
