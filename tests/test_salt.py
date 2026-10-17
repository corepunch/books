#!/usr/bin/env python3
"""Play The Salt Ledger: views and turns, Marsh, Penry and the baker, the town map, the
telephone, the gates, and every ending, through the headless app and its page contract."""
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

from headless_book import Book as HeadlessBook

binary, root = (Path(value).resolve() for value in sys.argv[1:3])
book_dir = root / 'books/salt'
# Continue exists only while something is being read.
READS = {'office-file', 'shack-ledger', 'tide-book', 'tide-roster', 'alley-board', 'sluice-grate'}
ENDINGS = {
    'ending-best': 'success', 'ending-quiet': 'success', 'ending-stair': 'partial', 'ending-home': 'failure',
    'ending-glass': 'failure', 'ending-tide': 'failure', 'ending-face': 'failure', 'ending-below': 'failure',
    'ending-below-knew': 'failure', 'ending-line': 'failure', 'ending-sluice': 'failure', 'ending-lamp': 'failure',
}
PEOPLE = {'edith', 'edith-midnight', 'marsh', 'penry', 'baker'}


def Book(viewport=(1100, 800)):
    return HeadlessBook(binary, root, 'salt', viewport)


def commands(view):
    return {choice['command'] for choice in view['choices'] if choice['kind'] in ('object', 'ask', 'end')}


def carried(view):
    return {choice['command'] for choice in view['choices'] if choice['kind'] == 'item'}


def play(book, route):
    for command in route:
        if command == 'continue':
            book.continue_page()
        elif command == 'retry':
            book.retry()
        elif command.startswith('hold:'):
            book.hold(command[5:])
        else:
            book.choose(command)
    return book


# --- The page graph, read from the XML -------------------------------------------------

title = ET.parse(book_dir / 'title.xml').getroot()
pages = {}
for location in (location.get('id') for location in title.iter('location')):
    for element in ET.parse(book_dir / 'locations' / f'{location}.xml').getroot().iter():
        if element.tag in ('view', 'map', 'charview', 'asset', 'ending', 'actionlist') or (
                element.tag == 'conversation' and element.get('clip')):
            pages[element.get('id')] = element
assert {ident for ident, page in pages.items() if page.get('read') == 'true'} == READS
assert {ident: page.get('kind') for ident, page in pages.items() if page.tag == 'ending'} == ENDINGS
assert {ident for ident, page in pages.items() if page.tag == 'charview'} == PEOPLE
# An fmv book draws no prose on a shot, a reply or an ending: each is a clip, which carries it.
for ident, page in pages.items():
    if page.tag in ('asset', 'ending', 'conversation') and page.get('read') != 'true':
        assert page.get('clip'), ident
# Every place the reader stands offers at least two ways on, and no page more than six circles at once.
for ident, page in pages.items():
    if page.tag in ('view', 'map'):
        circles = [c for c in page if c.tag in ('nav', 'explorable', 'destination', 'charview')]
        plain = [c for c in circles if c.get('with') is None]
        assert len(plain) >= 2, ident
        for icon in {c.get('with') for c in circles}:
            assert len([c for c in circles if c.get('with') == icon]) <= 6, (ident, icon)

# --- Routes ----------------------------------------------------------------------------

INTRO = ['continue', 'edith-thomas', 'continue', 'edith-floor', 'continue', 'edith-hotel', 'continue',
         'edith-leaves', 'continue']
OUT = ['office-file', 'continue', 'door-side', 'town']
MARSH = ['berth', 'water-seen', 'continue', 'marsh-intro', 'continue', 'marsh-thomas-check', 'continue',
         'hold:floor', 'marsh-floor', 'continue', 'marsh-patience', 'continue', 'berth']
LEDGER = ['hold:key', 'shack-unlock', 'continue', 'shack-ledger', 'continue', 'shack-door-side', 'berth']
UP = ['pier-head', 'alley', 'penry-intro', 'continue', 'hold:dry-room', 'penry-dry', 'continue', 'penry-rail',
      'continue', 'alley', 'bridge-check', 'landing-entry']
BEST = INTRO + ['window-side', 'window-seen', 'continue', 'desk'] + OUT + MARSH + LEDGER + UP + [
    'lamp-check', 'continue', 'door-check', 'continue', 'continue', 'hold:ledger', 'best-check']

book = Book()
assert book.view['id'] == 'visit' and book.view['kind'] == 'beat' and book.view['text'] == ''
assert book.view['clip'].endswith('/clips/visit.mp4')
play(book, INTRO[:1])
# Edith is a conversation: questions in the band, one way out, the card in the row.
assert book.view['talk'] and commands(book.view) == {'edith-thomas', 'edith-hotel', 'edith-leaves'}, commands(book.view)
assert carried(book.view) == {'card'}
play(book, INTRO[1:])
assert book.view['id'] == 'desk' and book.camera() == 'office'
# Turning: the window on the right edge, the door on the left; the door out waits on the folder.
edges = {c['command']: c['edge'] for c in book.view['choices'] if c.get('edge')}
assert edges == {'window-side': 'right', 'door-side': 'left'}, edges
play(book, ['door-side'])
assert 'town' not in commands(book.view) and 'office-wait' in commands(book.view)
play(book, ['desk', 'office-file'])
assert book.view['read'] and 'Not to the water' in book.view['text']
play(book, ['continue'])
assert 'photograph' in carried(book.view)
play(book, ['door-side', 'town'])
assert book.view['id'] == 'town' and book.camera() == 'town-map'
assert commands(book.view) == {'desk', 'berth'}, commands(book.view)  # the harbour office and the row are not known
book.close()

book = Book()
play(book, BEST)
assert book.view['id'] == 'ending-best' and book.view['ending'] == 'success' and book.view['text'] == ''
book.retry()
assert book.view['id'] == 'visit'
book.close()

# The quiet night: no window, no water, Penry by the board, the lamp empty.
QUIET = INTRO + OUT + ['berth', 'marsh-intro', 'continue', 'marsh-thomas-check', 'continue', 'hold:floor',
                       'marsh-floor', 'continue', 'berth'] + LEDGER + [
    'pier-head', 'alley', 'alley-board', 'continue', 'penry-intro', 'continue', 'penry-wash', 'continue',
    'penry-rail', 'continue', 'alley', 'bridge-check', 'landing-entry', 'door-check', 'continue', 'continue',
    'hold:ledger', 'best-check']
book = Book()
play(book, QUIET)
assert book.view['id'] == 'ending-quiet' and book.view['ending'] == 'success'
book.close()

# Gates: the padlock wants Marsh's key, the bridge Penry's answer, the baker your card.
book = Book()
play(book, INTRO + OUT + ['berth', 'shack-check'])
assert book.view['id'] == 'shack-door'
play(book, ['continue', 'pier-head', 'alley', 'bridge-check'])
assert book.view['id'] == 'alley-chain'
play(book, ['continue', 'penry-intro', 'continue'])
assert 'penry-rail' not in commands(book.view) and 'penry-wash' not in commands(book.view)
play(book, ['alley', 'alley-down', 'baker', 'baker-blind', 'continue'])
assert 'baker-blind' in commands(book.view)
play(book, ['hold:card', 'baker-card', 'continue'])
assert 'baker-card' not in commands(book.view) and 'baker-blind' not in commands(book.view)  # she has spoken
play(book, ['alley-down', 'alley', 'bridge-check'])
assert book.view['id'] == 'alley-chain'  # what she saw is under a bridge Penry still keeps
book.close()

# The map: destinations open as the case finds them; with the ledger the office is walked to.
book = Book()
play(book, INTRO + ['office-phone', 'continue'] + OUT + ['berth', 'map:open'])
lines = {c['label']: c['command'] for c in book.view['choices'] if c['kind'] == 'ask'}
assert {'Your office', 'The harbour office', 'Phone'} <= set(lines) and 'Bakery Row' not in lines, lines
play(book, [lines['The harbour office']])
assert book.view['id'] == 'tide-office'
play(book, ['tide-wall', 'tide-roster', 'continue', 'map:open'])
lines = {c['label']: c['command'] for c in book.view['choices'] if c['kind'] == 'ask'}
assert 'Bakery Row' in lines, lines
# The telephone: Edith at the hotel, then back where you stood.
play(book, ['map:phone', 'map:key:3', 'map:key:0', 'map:key:7', 'map:key:1', 'map:dial'])
assert book.view['id'] == 'call-edith' and book.view['clip'].endswith('/clips/call-edith.mp4')
play(book, ['continue'])
assert book.view['id'] == 'tide-wall' or book.view['id'] == 'tide-office', book.view['id']
play(book, ['map:open', 'map:phone', 'map:key:2', 'map:key:1', 'map:key:4', 'map:dial'])
assert book.view['id'] == 'call-tide-ring'
book.close()

book = Book()
play(book, INTRO + OUT + MARSH + LEDGER + ['map:open'])
lines = {c['label'] for c in book.view['choices'] if c['kind'] == 'ask'}
assert 'Your office' not in lines, lines
book.close()

# Every other ending, and where Try again puts the reader.
FAILURES = [
    (INTRO + ['door-side', 'ending-home'], 'ending-home', 'door-side'),
    (INTRO + OUT + MARSH + LEDGER + ['hold:ledger', 'ending-tide'], 'ending-tide', 'berth'),
    (INTRO + OUT + MARSH + ['hold:key', 'shack-unlock', 'continue', 'ending-below'], 'ending-below', 'shack'),
    (INTRO + OUT + MARSH + ['hold:key', 'shack-unlock', 'continue', 'shack-ledger', 'continue', 'ending-below-knew'],
     'ending-below-knew', 'shack-bare'),
    (INTRO + OUT + MARSH + LEDGER + ['pier-head', 'hold:ledger', 'fog-spent', 'continue', 'ending-stair'],
     'ending-stair', 'pier-head'),
    (INTRO + OUT + MARSH + LEDGER + ['pier-head', 'hold:ledger', 'fog-spent', 'continue', 'ending-face'],
     'ending-face', 'pier-head'),
    (INTRO + OUT + MARSH + LEDGER + ['pier-head', 'tide-office', 'hold:ledger', 'ending-line'],
     'ending-line', 'tide-office'),
    (INTRO + OUT + MARSH + LEDGER + UP[:-1] + ['hold:ledger', 'ending-sluice'], 'ending-sluice', 'bridge'),
    (INTRO + ['window-side', 'window-seen', 'continue', 'desk'] + OUT + MARSH + LEDGER + UP +
     ['hold:ledger', 'ending-lamp'], 'ending-lamp', 'landing-man'),
    (INTRO + OUT + MARSH + LEDGER + UP + ['door-check', 'continue', 'continue', 'hold:ledger', 'ending-glass'],
     'ending-glass', 'dry-room'),
]
for route, ending, again in FAILURES:
    book = Book()
    play(book, route)
    assert book.view['id'] == ending and book.view['ending'] == ENDINGS[ending], (ending, book.view['id'])
    assert book.view['clip'].endswith(f'/clips/{ending}.mp4')
    book.retry()
    assert book.view['id'] == again, (ending, book.view['id'])
    book.close()

# The iPad viewport lays out the busiest pages too.
book = Book((1024, 768))
play(book, BEST[:-1])
book.close()
print(f'Salt: {len(pages)} pages, every ending, the map, the telephone and the gates passed')
