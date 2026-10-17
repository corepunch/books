#!/usr/bin/env python3
"""Play The Salt Ledger: hubs and circles, documents, shots, every ending."""
from pathlib import Path
import subprocess
import sys
import xml.etree.ElementTree as ET

from headless_book import Book as HeadlessBook

binary, root = (Path(value).resolve() for value in sys.argv[1:3])
CLIPS = (
    'visit', 'window', 'marsh', 'water', 'below', 'street', 'bakery', 'lamp',
    'penry', 'penry-voss', 'penry-wash', 'penry-rail',
    'marsh-voss', 'marsh-floor', 'marsh-boat', 'marsh-dry',
)
HUBS = {
    'office', 'wharf', 'wharf-book', 'marsh', 'marsh-later', 'shack', 'shack-after',
    'alley', 'penry', 'sluice', 'sluice-warned', 'landing-man', 'landing-empty', 'office-return',
}
# Continue exists only while something is being read.
READS = {'office-file', 'shack-ledger', 'alley-board', 'sluice-grate', 'office-remind'}


def Book(viewport=(1100, 800)):
    return HeadlessBook(binary, root, 'salt', viewport)


def commands(view):
    return {choice['command'] for choice in view['choices'] if choice['kind'] in ('object', 'ask', 'end')}


def labels(view):
    return {choice['label'] for choice in view['choices'] if choice['kind'] in ('object', 'ask', 'end')}


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


DECISIONS, PASSAGES = {'view', 'charview', 'map'}, {'asset', 'conversation'}
CIRCLES = ('nav', 'explorable', 'charview', 'destination')


def story_pages():
    """Page graph from books/salt/title.xml and locations/, enough to check the screen rules."""
    book = root / 'books/salt'
    locations = [location.get('id') for location in ET.parse(book / 'title.xml').getroot().iter('location')]
    pages = {}

    def add(page, parent=None):
        kind = page.tag
        if kind == 'conversation' and page.get('id') is None:
            return
        if kind == 'charview':
            choices = [line for line in page if line.tag == 'conversation']
        else:
            choices = [circle for circle in page if circle.tag in CIRCLES]
        pages[page.get('id')] = {
            'kind': kind,
            'read': page.get('read') == 'true',
            'camera': page.get('camera'),
            'clip': page.get('clip'),
            'next': page.get('next') or parent,
            'gotos': [goto.get('target') for goto in page.iter('goto')],
            'choices': [{'target': choice.get('target') or choice.get('id'), 'held': choice.get('with') is not None}
                        for choice in choices],
        }
        for child in page:
            if child.tag in ('charview', 'conversation'):
                add(child, page.get('id') if child.tag == 'conversation' else None)

    for location in locations:
        for top in ET.parse(book / 'locations' / f'{location}.xml').getroot():
            for page in (top if top.tag == 'viewpoint' else [top]):
                if page.tag not in ('text', 'trigger'):
                    add(page)
    return pages


def landings(pages, ident, seen=None):
    seen = set() if seen is None else set(seen)
    if ident in seen:
        raise AssertionError(ident)
    page = pages[ident]
    if page['kind'] != 'actionlist':
        return [page['kind']]
    seen.add(ident)
    return [kind for target in page['gotos'] for kind in landings(pages, target, seen)]


pages = story_pages()
assert {ident for ident, page in pages.items() if page['read']} == READS
for ident, page in pages.items():
    if page['kind'] not in PASSAGES:
        continue
    reached = landings(pages, page['next'])
    assert all(kind not in PASSAGES for kind in reached), (ident, reached)
for ident, page in pages.items():
    if page['kind'] not in DECISIONS:
        continue
    plain = [choice['target'] for choice in page['choices'] if not choice['held']]
    assert len(plain) == len(set(plain)) and len(plain) >= 2, (ident, plain)
    if ident in HUBS:
        assert len(plain) >= 3, (ident, plain)
    held = [choice['target'] for choice in page['choices'] if choice['held']]
    assert len(held) == len(set(held)) and len(plain) <= 5 and len(held) <= 5, (ident, plain, held)

assert {page['clip'] for page in pages.values() if page['clip']} == set(CLIPS)
assert not {page['camera'] for page in pages.values()} & {'steps', 'chapel', 'yard', 'stair'}

# Exits only, plus the three discoveries, then every close-up on the way home.
TO_DOCK = [
    'continue', 'office-file', 'continue', 'office-phone', 'continue', 'office-lamp', 'continue',
    'window-seen', 'continue', 'office-door', 'continue',
]
TO_BOOK = TO_DOCK + [
    'water-seen', 'continue', 'marsh-intro', 'continue', 'marsh-thomas', 'continue',
    'marsh-boat', 'continue', 'marsh-floor', 'continue', 'dock-back', 'shack-check',
    'shack-coat', 'continue', 'shack-ledger', 'continue', 'shack-coat-bare', 'continue',
    'hold:ledger', 'hold:ledger', 'dock-back', 'marsh-intro', 'hold:ledger', 'marsh-refuse',
    'continue', 'dock-back',
]
TO_ROOM = TO_BOOK + [
    'hold:ledger', 'hold:ledger', 'lane-shut', 'continue', 'alley-window', 'continue',
    'alley-board', 'continue', 'penry-greet', 'continue', 'penry-thomas', 'continue', 'penry-chalk', 'continue',
    'penry-bridge', 'continue', 'hold:ledger', 'alley', 'sluice-entry', 'sluice-look', 'continue',
    'sluice-grate', 'continue', 'hold:ledger', 'hold:ledger', 'landing-entry',
    'hold:ledger', 'hold:ledger', 'landing-window', 'continue', 'lamp-meet', 'continue',
    'lamp-still', 'continue', 'hall', 'continue', 'locket', 'continue', 'office-look', 'continue',
    'office-remind', 'continue',
]
BEST = TO_ROOM + ['hold:ledger', 'best-check']
QUIET = [
    'continue', 'office-file', 'continue', 'office-door', 'continue', 'shack-check',
    'shack-ledger', 'continue', 'dock-back', 'lane-shut', 'continue', 'sluice-entry',
    'landing-entry', 'hall', 'continue', 'hold:ledger', 'best-check',
]
TRAP = ['continue', 'office-file', 'continue', 'office-door', 'continue', 'shack-check', 'ending-below']
TRAP_KNEW = [
    'continue', 'office-file', 'continue', 'office-door', 'continue', 'shack-check',
    'shack-ledger', 'continue', 'ending-below-knew',
]
HOME = ['continue', 'office-file', 'continue', 'office-door', 'continue', 'ending-home']

book = Book()
assert book.view['id'] == 'visit' and book.view['kind'] == 'beat' and book.view['text'] == ''
assert not book.view['choices'] and book.view['clip'].endswith('/clips/visit.mp4')
book.continue_page()
assert book.camera() == 'office' and book.view['kind'] == 'room' and book.view['text'] == ''
assert 'office-door' not in commands(book.view)
assert {'office-file', 'window-seen', 'office-phone', 'office-lamp'} <= commands(book.view)
book.choose('office-file')
assert book.view['read'] and book.view['choices'][0]['kind'] == 'continue'
assert 'Not to the water' in book.view['text']
book.continue_page()
assert 'office-door' in commands(book.view) and len(labels(book.view)) == 5
play(book, BEST[3:])
assert book.view['id'] == 'ending-best' and book.view['ending'] == 'success'
assert book.view['text'] == '' and book.view['clip'] == ''
book.retry()
assert book.camera() == 'visit'
book.close()

book = Book()
play(book, QUIET)
assert book.view['id'] == 'ending-quiet' and book.view['ending'] == 'success' and book.view['text'] == ''
book.close()

book = Book()
play(book, TRAP)
assert book.view['ending'] == 'failure' and book.view['clip'].endswith('/clips/below.mp4')
book.retry()
assert book.camera() == 'shack' and 'ledger' not in carried(book.view)
book.close()

book = Book()
play(book, TRAP_KNEW)
assert book.view['id'] == 'ending-below-knew' and book.view['ending'] == 'failure' and book.view['text'] == ''
book.retry()
assert book.camera() == 'shack-bare' and 'ledger' in carried(book.view)
book.close()

book = Book()
play(book, HOME)
assert book.view['id'] == 'ending-home' and book.view['ending'] == 'failure'
assert book.view['clip'] == '' and book.view['text'] == '' and book.camera() == 'street'
book.retry()
assert book.camera() == 'wharf' and 'ledger' not in carried(book.view)
book.close()

# The wharf replaces its doors while the book is open. The fog goes to the bend.
book = Book()
play(book, TO_BOOK)
assert 'To the fog' not in labels(book.view) and 'The lane' in labels(book.view)
held = book.hold('ledger')
assert held['text'] == ''
assert labels(held) == {'To the water', 'To the fog', 'The lane', 'The mate'}
book.choose('fog-spent')
assert book.view['kind'] == 'beat' and book.view['clip'].endswith('/clips/street.mp4')
book.continue_page()
assert book.camera() == 'corner' and {'ending-stair', 'ending-face'} <= commands(book.view)
book.choose('ending-stair')
assert book.view['id'] == 'ending-stair' and book.view['ending'] == 'partial'
assert book.view['clip'] == '' and book.view['text'] == ''
book.retry()
assert book.camera() == 'wharf' and 'ledger' in carried(book.view)
book.close()

book = Book()
play(book, TO_BOOK)
book.hold('ledger')
book.choose('fog-spent')
book.continue_page()
book.choose('ending-face')
assert book.view['ending'] == 'failure' and book.camera() == 'coat' and book.view['clip'] == ''
book.retry()
assert 'ledger' in carried(book.view)
book.hold('ledger')
book.choose('ending-tide')
assert book.view['ending'] == 'failure' and book.camera() == 'water'
book.retry()
book.choose('marsh-intro')
assert book.view['kind'] == 'room' and book.view['clip'] == '' and book.camera() == 'marsh'
book.close()

# Before the face, the open book still talks about the dry room. Marsh refuses it.
book = Book()
play(book, [
    'continue', 'office-file', 'continue', 'office-door', 'continue', 'shack-check',
    'shack-ledger', 'continue', 'dock-back',
])
held = book.hold('ledger')
assert held['text'] == '' and 'To the water' in labels(held)
book.choose('wharf-refuse')
assert book.view['id'] == 'wharf-refuse' and book.view['text'] == ''
assert book.view['clip'].endswith('/clips/marsh-dry.mp4')
book.continue_page()
assert book.camera() == 'wharf' and book.view['kind'] == 'room' and 'The shack' in labels(book.view)
book.close()

# A second look does not replay the summons. The window, once seen, is a still.
book = Book()
play(book, ['continue', 'office-file', 'continue', 'office-door', 'continue', 'water-seen', 'continue'])
assert book.camera() == 'wharf'
book.choose('water-seen')
assert book.view['kind'] == 'beat' and book.view['clip'] == ''
book.continue_page()
book.close()

book = Book()
book.continue_page()
book.choose('window-seen')
assert book.view['kind'] == 'beat' and book.view['clip'].endswith('/clips/window.mp4')
book.continue_page()
book.choose('window-seen')
assert book.view['id'] == 'window-again' and book.view['kind'] == 'beat'
assert book.view['clip'] == '' and book.view['text'] == ''
book.close()

# Penry's lines. The chalk waits on the board. An answered line leaves.
# The bridge appears once he has said what he did to the board. That's all stays last.
book = Book()
play(book, TO_BOOK + ['lane-shut', 'continue', 'penry-greet', 'continue'])
assert book.camera() == 'penry'
assert 'penry-chalk' not in commands(book.view) and 'penry-bridge' not in commands(book.view)
assert {'penry-thomas', 'alley'} <= commands(book.view)
book.choose('penry-thomas')
assert book.view['clip'].endswith('/clips/penry-voss.mp4')
book.continue_page()
assert 'penry-thomas' not in commands(book.view) and 'alley' in commands(book.view)
end = next(c for c in book.view['controls'] if c['kind'] == 'end')
book.tap_choice(end['choice'])
assert book.camera() == 'alley'
book.choose('alley-board')
book.continue_page()
book.choose('penry-greet')
book.continue_page()
assert 'penry-thomas' not in commands(book.view)
assert 'penry-chalk' in commands(book.view) and 'penry-bridge' not in commands(book.view)
book.choose('penry-chalk')
assert book.view['clip'].endswith('/clips/penry-wash.mp4')
book.continue_page()
assert 'penry-chalk' not in commands(book.view) and 'penry-bridge' in commands(book.view)
book.choose('penry-bridge')
assert book.view['clip'].endswith('/clips/penry-rail.mp4')
book.continue_page()
assert commands(book.view) == {'alley'}
held = book.hold('ledger')
assert held['text'] == '' and labels(held) == {"That's all"}
book.close()

# The sluice, before Penry and after. The grating changes the empty lamp.
book = Book()
play(book, QUIET[:-2])
assert book.view['id'] == 'office-return' and book.camera() == 'visit' and book.view['text'] == ''
book.choose('dock-back')
book.choose('lane-shut')
book.continue_page()
book.choose('sluice-entry')
assert book.view['id'] == 'sluice' and book.view['text'] == ''
assert {'sluice-look', 'sluice-grate', 'landing-entry', 'alley'} <= commands(book.view)
book.choose('sluice-look')
assert book.view['id'] == 'sluice-look-plain' and book.view['text'] == ''
book.continue_page()
book.choose('alley')
book.choose('alley-board')
book.continue_page()
book.choose('penry-greet')
book.continue_page()
book.choose('penry-chalk')
book.continue_page()
book.choose('alley')
book.choose('sluice-entry')
assert book.view['id'] == 'sluice-warned' and book.view['text'] == ''
book.choose('sluice-grate')
assert book.view['read'] and 'VOSS' in book.view['text'] and book.view['clip'] == ''
book.continue_page()
book.choose('landing-entry')
assert book.view['id'] == 'landing-empty' and book.camera() == 'landing' and book.view['text'] == ''
book.choose('lamp-still')
assert book.view['id'] == 'lamp-peg' and book.view['text'] == ''
book.continue_page()
book.close()

# Seen from the office, he is under the lamp, and then he is not.
book = Book()
play(book, TO_BOOK + ['lane-shut', 'continue', 'sluice-entry', 'landing-entry'])
assert book.view['id'] == 'landing-man' and book.view['text'] == '' and book.view['clip'] == ''
book.choose('lamp-meet')
assert book.view['id'] == 'lamp-meet' and book.view['text'] == ''
assert book.view['clip'].endswith('/clips/lamp.mp4')
book.continue_page()
assert book.view['id'] == 'landing-empty' and book.view['text'] == ''
held = book.hold('ledger')
assert labels(held) == {'To the lamp', 'The door', 'The stair'}
book.choose('ending-lamp-clear')
assert book.view['ending'] == 'failure' and book.camera() == 'landing' and book.view['clip'] == ''
book.retry()
assert book.camera() == 'landing' and 'ledger' in carried(book.view) and 'The stair' in labels(book.view)
book.close()

# Reading to the sluice spends the hour and returns to the bridge you stood on.
book = Book()
play(book, TO_BOOK + ['lane-shut', 'continue', 'sluice-entry'])
held = book.hold('ledger')
assert 'To the water' in labels(held) and 'The grating' not in labels(held) and 'The stair' in labels(held)
book.choose('ending-sluice')
assert book.view['ending'] == 'failure' and book.camera() == 'sluice' and book.view['clip'] == ''
book.retry()
assert book.camera() == 'sluice' and 'ledger' in carried(book.view) and 'The stair' in labels(book.view)
book.close()

book = Book()
play(book, TO_ROOM)
assert book.camera() == 'visit'
book.choose('dock-back')
assert book.camera() == 'wharf' and 'ledger' in carried(book.view)
book.choose('lane-shut')
play(book, ['continue', 'sluice-entry', 'landing-entry', 'hall', 'continue'])
book.hold('ledger')
book.choose('ending-glass')
assert book.view['ending'] == 'failure' and book.view['clip'] == ''
book.retry()
assert book.camera() == 'visit' and 'ledger' in carried(book.view)
held = book.hold('ledger')
assert labels(held) == {'To the folder', 'To the glass', 'The door'}
book.close()

# Holding the book on Marsh's deck is the one circle, and the hour is not spent.
book = Book()
play(book, TO_DOCK + ['shack-check', 'shack-ledger', 'continue', 'dock-back', 'marsh-intro', 'continue'])
assert book.view['id'] == 'marsh' and book.view['kind'] == 'room' and book.view['text'] == ''
book.choose('marsh-floor')
assert book.view['id'] == 'marsh-floor' and book.view['text'] == ''
assert book.view['clip'].endswith('/clips/marsh-floor.mp4')
book.continue_page()
assert book.view['id'] == 'marsh-later' and book.view['text'] == ''
held = book.hold('ledger')
assert labels(held) == {'The hour'}
book.choose('marsh-refuse')
book.continue_page()
assert book.view['kind'] == 'room' and 'The dock' in labels(book.view)
book.close()

for clip in CLIPS:
    path = root / f'books/salt/clips/{clip}.mp4'
    assert path.is_file(), clip
    info = subprocess.check_output(['afinfo', str(path)], text=True, stderr=subprocess.STDOUT)
    duration = float(info.split('estimated duration:', 1)[1].split('sec', 1)[0])
    assert duration >= 5, (clip, duration)

for viewport in ((1024, 768), (1133, 744), (1366, 1024)):
    for route in (BEST, QUIET, TRAP, HOME,
                  TO_BOOK + ['hold:ledger', 'fog-spent', 'continue', 'ending-stair'],
                  TO_BOOK + ['hold:ledger', 'fog-spent', 'continue', 'ending-face'],
                  TO_BOOK + ['lane-shut', 'continue', 'sluice-entry', 'hold:ledger', 'ending-sluice'],
                  TO_BOOK + ['lane-shut', 'continue', 'sluice-entry', 'landing-entry',
                             'hold:ledger', 'ending-lamp']):
        book = Book(viewport)
        play(book, route)
        book.close()

print('Salt Ledger: hubs, sixteen clips, documents, and every ending passed')
