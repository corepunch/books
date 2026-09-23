#!/usr/bin/env python3
"""Exercise the C Three Stars adventure through its headless page interface."""
import json
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
        return self.view

    def send(self, command):
        self.process.stdin.write(command + '\n')
        self.process.stdin.flush()
        return self.read()

    def choose(self, command):
        index = next(i for i, choice in enumerate(self.view['choices'])
                     if choice['command'] == command)
        return self.send(f':choose {index}')

    def close(self):
        self.process.stdin.close()
        assert self.process.wait(timeout=10) == 0, self.process.stderr.read()


b = Book()
assert b.view['room'] == 'attic-floor'
assert Path(b.view['image']) == root / 'books/three-stars/rooms/floor-show-room.jpg'
assert {choice['command'] for choice in b.view['choices']} == {'take brass-star', 'go table'}

b.choose('take brass-star')
assert b.view['kind'] == 'beat' and b.view['image'].endswith('/floor-take-gold-star.jpg')
b.send(':continue')
assert b.view['image'].endswith('/floor-show-cleared-room.jpg')
b.choose('go table')
assert b.view['room'] == 'writing-desk' and b.view['image'].endswith('/floor-climb-table.jpg')
b.send(':continue')
assert b.view['image'].endswith('/table-show-desk.jpg')
b.choose('take copper-star')
b.send(':continue')
assert b.view['image'].endswith('/table-show-cleared-desk.jpg')
b.choose('go sill')
assert b.view['room'] == 'window-sill' and b.view['image'].endswith('/table-climb-sill.jpg')
b.send(':continue')
assert b.view['image'].endswith('/sill-show-window.jpg')
b.choose('take pearl-star')
assert b.view['kind'] == 'ended' and b.view['image'].endswith('/attic-return-stars.jpg')
assert 'три звёздочки' in b.view['text'].lower()
b.close()

for source in root.rglob('*'):
    if not source.is_file() or '.git' in source.parts or 'build' in source.parts:
        continue
    assert source.suffix.lower() not in {'.lua', '.zil'}, f'legacy adventure source remains: {source}'

print('Book: C adventure route, images and ending passed')
