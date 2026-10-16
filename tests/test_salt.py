#!/usr/bin/env python3
"""Play The Salt Ledger through every ending, the ledger, and the clips."""
from pathlib import Path
import subprocess
import sys

from headless_book import Book as HeadlessBook

binary, root = (Path(value).resolve() for value in sys.argv[1:3])
CLIPS = ('visit', 'window', 'marsh', 'water', 'below', 'street')


def Book(viewport=(1100, 800)):
    return HeadlessBook(binary, root, 'salt', viewport)


def commands(view):
    return {choice['command'] for choice in view['choices'] if choice['kind'] == 'object'}


def labels(view):
    return {choice['label'] for choice in view['choices'] if choice['kind'] == 'object'}


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


TO_BOOK = [
    'continue', 'office-file', 'continue', 'office-window', 'continue', 'office-door', 'continue',
    'water-seen', 'continue', 'marsh-route', 'continue', 'shack-check', 'shack-ledger', 'continue',
    'dock-back',
]
TO_ROOM = TO_BOOK + ['leave-check', 'continue']
BEST = TO_ROOM + ['office-remind', 'continue', 'hold:ledger', 'best-check']
QUIET = [
    'continue', 'office-file', 'continue', 'office-door', 'continue', 'shack-check',
    'shack-ledger', 'continue', 'dock-back', 'leave-check', 'continue', 'hold:ledger', 'best-check',
]
TRAP = ['continue', 'office-file', 'continue', 'office-door', 'continue', 'shack-check', 'ending-below']
TRAP_KNEW = [
    'continue', 'office-file', 'continue', 'office-door', 'continue', 'shack-check',
    'shack-ledger', 'continue', 'ending-below-knew',
]
HOME = ['continue', 'office-file', 'continue', 'office-door', 'continue', 'leave-check']

book = Book()
assert book.camera() == 'visit' and book.view['clip'].endswith('/clips/visit.mp4')
book.continue_page()
assert 'office-door' not in commands(book.view)
book.choose('office-file')
book.continue_page()
assert 'office-door' in commands(book.view)
play(book, BEST[3:])
assert book.view['kind'] == 'ended' and book.view['ending'] == 'success'
assert 'streetlamp stays empty' in book.view['text']
assert book.view['clip'] == ''
book.retry()
assert book.camera() == 'visit'
book.close()

book = Book()
play(book, QUIET)
assert book.view['ending'] == 'success' and 'only rain' in book.view['text']
book.close()

book = Book()
play(book, TRAP)
assert book.view['ending'] == 'failure' and book.view['clip'].endswith('/clips/below.mp4')
book.retry()
assert book.camera() == 'shack' and 'ledger' not in carried(book.view)
book.close()

book = Book()
play(book, TRAP_KNEW)
assert book.view['ending'] == 'failure' and 'brought his name' in book.view['text']
book.retry()
assert book.camera() == 'shack-bare' and 'ledger' in carried(book.view)
book.close()

book = Book()
play(book, HOME)
assert book.view['ending'] == 'failure' and book.view['clip'] == ''
assert book.camera() == 'street'
book.retry()
assert book.camera() == 'wharf' and 'ledger' not in carried(book.view)
book.close()

book = Book()
play(book, TO_BOOK)
assert 'To the fog' not in labels(book.view)
held = book.hold('ledger')
assert 'tide' in held['text'].lower() and 'To the fog' in labels(held)
book.choose('ending-street')
assert book.view['ending'] == 'partial' and book.view['clip'].endswith('/clips/street.mp4')
book.retry()
assert 'ledger' in carried(book.view)
book.hold('ledger')
book.choose('ending-tide')
assert book.view['ending'] == 'failure' and book.camera() == 'water'
book.retry()
book.choose('marsh-route')
book.continue_page()
assert book.camera() == 'wharf' and book.view['kind'] == 'room'
book.close()

book = Book()
play(book, TO_ROOM)
assert book.camera() == 'office'
book.choose('wharf-book')
assert book.camera() == 'wharf' and 'ledger' in carried(book.view)
book.choose('leave-check')
book.continue_page()
book.hold('ledger')
book.choose('ending-glass')
assert book.view['ending'] == 'failure' and book.view['clip'] == ''
book.retry()
assert book.camera() == 'office' and 'ledger' in carried(book.view)
book.close()

# A second look at the water does not replay the summons.
book = Book()
play(book, ['continue', 'office-file', 'continue', 'office-door', 'continue', 'water-seen', 'continue'])
assert book.camera() == 'wharf'
book.choose('water-seen')
assert book.view['kind'] == 'beat' and book.view['clip'] == ''
book.continue_page()
book.close()

for clip in CLIPS:
    path = root / f'books/salt/clips/{clip}.mp4'
    assert path.is_file(), clip
    info = subprocess.check_output(['afinfo', str(path)], text=True, stderr=subprocess.STDOUT)
    duration = float(info.split('estimated duration:', 1)[1].split('sec', 1)[0])
    assert duration >= 5, (clip, duration)

for viewport in ((1024, 768), (1133, 744), (1366, 1024)):
    for route in (BEST, QUIET, TRAP, HOME):
        book = Book(viewport)
        play(book, route)
        book.close()

print('Salt Ledger: six clips, the ledger, and every ending passed')
