#!/usr/bin/env python3
"""Read Мира и лунный зайчик through its headless page interface: every route and ending."""
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

from headless_book import Book as HeadlessBook

binary, root = (Path(value).resolve() for value in sys.argv[1:3])
reached = set()


def Book():
    book = HeadlessBook(binary, root, 'moon-spot')
    reached.add(book.camera())
    return book


def step(book, command):
    """Take a published choice (or tap Continue) and record the camera it shows."""
    if command == 'continue':
        book.continue_page()
    else:
        book.choose(command)
    reached.add(book.camera())
    assert Path(book.view['image']) == book.image(book.camera()), book.view['image']
    return book.view


def walk(book, *commands):
    for command in commands:
        step(book, command)
    return book.view


def page(book, kind, camera, commands=()):
    view = book.view
    assert (view['kind'], book.camera()) == (kind, camera), (view['kind'], book.camera())
    assert sorted(c['command'] for c in view['choices'] if c['command']) == sorted(commands), view['choices']


# Opening page: three circles on their anchors; invalid or stale input changes nothing.
b = Book()
page(b, 'room', 'floor-show-kitchen', ['catch spot', 'wake bublik', 'climb stool'])
assert b.view['room'] == 'kitchen-floor'
assert {h['object'] for h in b.view['hotspots']} == {'moonspot', 'bublik', 'stool'}
initial = b.view
for invalid in (':choose -1', ':choose 9', ':continue', ':back', ':focus mirror', 'push mirror', 'inventory'):
    assert b.send(invalid) == initial
# A caption is part of its choice: tapping the label acts like tapping the circle.
caption = next(c for c in b.view['controls'] if c['circle'] and c['choice'] == 0)['caption']
b.send(f":tap {caption['x'] + caption['width'] / 2} {caption['y'] + caption['height'] / 2}")
reached.add(b.camera())
page(b, 'beat', 'floor-pounce-spot')
beat = b.view
for ignored in ('catch spot', ':focus stool', ':reload'):
    assert b.send(ignored) == beat
walk(b, 'continue')
page(b, 'room', 'floor-show-kitchen', ['catch spot', 'wake bublik', 'climb stool'])
assert b.view['text'] == initial['text']
b.close()

# Golden path: stool, mirror, aim at the basket. Бублик never spoke, so he does not mumble.
b = Book()
walk(b, 'climb stool')
page(b, 'beat', 'floor-climb-stool')
assert b.view['room'] == 'kitchen-table'
walk(b, 'continue')
page(b, 'room', 'table-show-mirror', ['push mirror', 'catch curtain', 'go floor'])
assert {h['object'] for h in b.view['hotspots']} == {'mirror', 'curtain', 'stool'}
walk(b, 'catch curtain')
page(b, 'beat', 'table-catch-curtain')
walk(b, 'continue', 'push mirror')
page(b, 'beat', 'table-push-mirror')
walk(b, 'continue')
page(b, 'room', 'table-show-turned', ['aim mirror', 'catch curtain', 'go floor'])
walk(b, 'catch curtain', 'continue')
page(b, 'room', 'table-show-turned', ['aim mirror', 'catch curtain', 'go floor'])
walk(b, 'aim mirror')
page(b, 'ended', 'kitchen-sleep-basket')
assert 'корзинку' in b.view['text'] and 'Я же говорил' not in b.view['text']
ending = b.view
for ignored in (':choose 0', ':continue', ':back', 'aim mirror', ':reload'):
    assert b.send(ignored) == ending
b.close()

# Waking Бублик first gives the clue, changes the floor page, and is remembered by the basket ending.
b = Book()
walk(b, 'wake bublik')
page(b, 'beat', 'floor-wake-bublik')
walk(b, 'continue')
page(b, 'room', 'floor-show-kitchen', ['catch spot', 'climb stool'])
assert 'с окна' in b.view['text'] and b.view['text'] != initial['text']
walk(b, 'climb stool', 'continue', 'push mirror', 'continue', 'go floor')
page(b, 'beat', 'table-go-floor')
walk(b, 'continue')
# Already invited: the awake floor offers his ending straight away.
page(b, 'room', 'floor-show-awake', ['lie bublik', 'climb stool'])
walk(b, 'climb stool', 'continue')
page(b, 'room', 'table-show-turned', ['aim mirror', 'catch curtain', 'go floor'])
walk(b, 'aim mirror')
page(b, 'ended', 'kitchen-sleep-basket')
assert 'Я же говорил' in b.view['text']
b.close()

# Бублик's ending: push first, go down, make peace with the sneezing dog, lie down with him.
b = Book()
walk(b, 'climb stool', 'continue', 'push mirror', 'continue', 'go floor', 'continue')
page(b, 'room', 'floor-show-awake', ['talk bublik', 'climb stool'])
assert {h['object'] for h in b.view['hotspots']} == {'bublik', 'stool'}
walk(b, 'talk bublik')
page(b, 'beat', 'floor-talk-bublik')
walk(b, 'continue')
page(b, 'room', 'floor-show-awake', ['lie bublik', 'climb stool'])
assert 'ложись' in b.view['text']
walk(b, 'lie bublik')
page(b, 'ended', 'kitchen-sleep-bublik')
assert 'фотографии' in b.view['text']
b.close()

# Going down before the push returns to the unchanged kitchen.
b = Book()
walk(b, 'climb stool', 'continue', 'go floor', 'continue')
page(b, 'room', 'floor-show-kitchen', ['catch spot', 'wake bublik', 'climb stool'])
b.close()

# Every page camera in the scene is reached; the cover is the only non-page camera.
scene = ET.parse(root / 'books/moon-spot/rooms/kitchen.blks').getroot()
cameras = {camera.attrib['name'] for camera in scene.findall('camera')}
assert reached == cameras - {'cover'}, (cameras - reached, reached - cameras)
for camera in cameras:
    assert (root / f'books/moon-spot/rooms/{camera}.jpg').is_file(), camera

print(f'Moon Spot: {len(reached)} pages, both endings, both fact variants and every route passed')
