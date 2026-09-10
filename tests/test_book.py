#!/usr/bin/env python3
"""Exercise the real C host and ZIL coroutine, without a graphical context."""
import json
import math
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

binary, root = (Path(x).resolve() for x in sys.argv[1:3])

class Book:
    def __init__(self, assets=root, name='wondertown'):
        self.process = subprocess.Popen([str(binary), '--root', str(assets), '--book', name, '--headless'],
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
        index = next(i for i, c in enumerate(self.view['choices']) if c['command'] == command)
        return self.send(f':choose {index}')

    def focus(self, object_id):
        index = next(i for i, c in enumerate(self.view['choices'])
                     if c['object'] == object_id and not c['command'])
        return self.send(f':choose {index}')

    def close(self):
        self.process.stdin.close()
        assert self.process.wait(timeout=10) == 0, self.process.stderr.read()

b = Book()
assert b.view['room'] == 'workshop-floor'
assert Path(b.view['image']) == root / 'books/wondertown/rooms/workshop-floor-look.jpg'
assert len(b.view['hotspots']) == 10
# Check the C projection against the Scener camera and the oil-can anchor.
scene = ET.parse(root / 'books/wondertown/rooms/workshop-new.blks').getroot()
cam = next(c for c in scene.findall('camera') if c.get('name') == 'workshop-floor-look')
obj = next(c for c in scene.findall('group') if c.get('name') == 'OIL-CAN')
vec = lambda text: [float(n) for n in text.split()]
sub = lambda a, b: [x-y for x,y in zip(a,b)]
dot = lambda a,b: sum(x*y for x,y in zip(a,b))
norm = lambda a: [x/math.sqrt(dot(a,a)) for x in a]
cross = lambda a,b: [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]]
pos = vec(cam.get('pos'))
fwd = norm(sub(vec(cam.get('look')), pos))
right = norm(cross(fwd, [0,0,1]))
up = cross(right, fwd)
delta = sub(vec(obj.get('pos')), pos)
focal = 1440 / (2*math.tan(math.radians(float(cam.get('fov')))/2))
scale = max(1100/1920, 800/1440)
x = (960+dot(delta,right)*focal/dot(delta,fwd))*scale+(1100-1920*scale)/2
y = (720-dot(delta,up)*focal/dot(delta,fwd))*scale+(800-1440*scale)/2
spot = next(h for h in b.view['hotspots'] if h['object'] == 'oil-can')
assert abs(spot['x']-x) < 0.001 and abs(spot['y']-y) < 0.001

b.focus('workbench')
assert b.view['kind'] == 'focus' and b.view['image'].endswith('/workshop-floor-examine-workbench.jpg')
b.choose('climb bench')
assert b.view['room'] == 'workbench-top' and b.view['kind'] == 'beat'
b.send(':continue')
b.focus('repair-book')
assert "can't see" not in b.view['text']
b.choose('open book')
assert b.view['kind'] == 'beat' and 'cover opens' in b.view['text']
b.send(':continue')
assert any(c['command'] == 'close book' for c in b.view['choices'])
b.choose('read book')
assert 'read' in b.view['text'].lower() or 'Tolliver' in b.view['text']
b.send(':continue')
b.send(':back')
b.choose('down')  # a PER exit must remain visible and let ZIL enforce the rule
assert 'must be closed' in b.view['text']
b.send('close book')
b.send(':continue')
b.choose('down')
b.send(':continue')
assert b.view['room'] == 'workshop-floor'
b.focus('oil-can')
b.choose('take can')
assert 'Taken' in b.view['text']
b.send(':continue')
b.send(':back')
assert not any(h['object'] == 'oil-can' for h in b.view['hotspots'])
b.choose('north')
b.send(':continue')
assert b.view['room'] == 'snowy-alley' and not b.view['image']
b.choose('south')
b.send(':continue')
assert b.view['room'] == 'workshop-floor' and b.view['image'].endswith('/workshop-floor-look.jpg')
b.send(':reload')
b.close()

# A different ZIL book, with no C edits, presentation Lua, XML UI or manifest.
# Symlink only the VM/substrate; the small fixture stays outside the submodule.
with tempfile.TemporaryDirectory(prefix='book-engine-') as temp:
    assets = Path(temp)
    vm = assets / 'libs/zilscript'
    vm.mkdir(parents=True)
    for child in (root / 'libs/zilscript').iterdir():
        if child.name not in ('books', '.git'):
            (vm / child.name).symlink_to(child, target_is_directory=child.is_dir())
    source = vm / 'books/testbook'
    source.mkdir(parents=True)
    (source/'testbook.zil').write_text('''
<VERSION ZIP>
<CONSTANT RELEASEID 1>
<INSERT-FILE "infocom.zork1.main">
<INSERT-FILE "infocom.zork1.clock">
<INSERT-FILE "infocom.zork1.parser">
<INSERT-FILE "infocom.zork1.syntax">
<INSERT-FILE "infocom.zork1.macros">
<INSERT-FILE "infocom.zork1.verbs">
<INSERT-FILE "infocom.zork1.globals">
<DIRECTIONS NORTH SOUTH>
<ROOM TEST-ROOM (IN ROOMS) (DESC "Test room") (LDESC "A different book.")
 (NORTH TO NEXT-ROOM) (FLAGS RLANDBIT ONBIT)>
<ROOM NEXT-ROOM (IN ROOMS) (DESC "Next room") (LDESC "The next page.")
 (SOUTH TO TEST-ROOM) (FLAGS RLANDBIT ONBIT)>
<OBJECT TEST-TOY (IN TEST-ROOM) (SYNONYM TOY) (DESC "test toy")
 (FLAGS TAKEBIT) (TEXT "A small wooden toy.")>
<ROUTINE V-RESTART () <RESTART>>
<ROUTINE V-QUIT () <QUIT>>
<ROUTINE GO () <SETG HERE ,TEST-ROOM> <SETG WINNER ,ADVENTURER>
 <SETG PLAYER ,WINNER> <SETG LIT T> <MOVE ,WINNER ,HERE> <V-LOOK> <MAIN-LOOP>>
''')
    rooms = assets/'books/testbook/rooms'
    rooms.mkdir(parents=True)
    jpg = root/'books/wondertown/rooms/workshop-floor-look.jpg'
    for name in ('test-room-look', 'test-room-examine-test-toy', 'test-room-take-test-toy'):
        shutil.copyfile(jpg, rooms/f'{name}.jpg')
    (rooms/'shared.blks').write_text('''<scene up="z">
<camera name="test-room-look" pos="0 -200 100" look="0 0 100" fov="90"/>
<group pos="100 0 0" rot="0 0 90" scale="2 2 2">
  <group name="TEST-TOY" pos="0 50 50"/>
</group></scene>''')
    b = Book(assets, 'testbook')
    assert b.view['room'] == 'test-room' and b.view['image'].endswith('/test-room-look.jpg')
    assert b.view['hotspots'] == [{'object':'test-toy', 'x':550.0, 'y':400.0}]
    before = b.view
    b.send(':reload')
    assert b.view == before, 'metadata reload must not advance the story'
    b.focus('test-toy')
    assert b.view['image'].endswith('/test-room-examine-test-toy.jpg')
    b.choose('take toy')
    assert b.view['image'].endswith('/test-room-take-test-toy.jpg')
    b.send(':continue')
    b.send(':back')
    assert not b.view['hotspots']
    b.choose('north')
    b.send(':continue')
    assert b.view['room'] == 'next-room' and not b.view['image']
    b.choose('south')
    b.send(':continue')
    assert b.view['image'].endswith('/test-room-look.jpg')
    b.send('restart')
    b.send(':continue')
    assert b.view['room'] == 'test-room' and b.view['hotspots']
    b.send('quit')
    assert b.view['kind'] == 'ended' and not b.view['choices']
    b.close()

assert not [p for p in root.rglob('*.lua') if 'libs' not in p.parts and '.git' not in p.parts], 'Book must not depend on host Lua files'
print('Book: coroutine, automatic choices/images, focus, navigation, restart/quit and projection passed')
