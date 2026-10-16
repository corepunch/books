#!/usr/bin/env python3
"""Read Обратный отсчёт through its headless page interface: every page, held thing, route, ending and retry."""
from pathlib import Path
import ast
import re
import sys

from headless_book import Book as HeadlessBook

binary, root = (Path(value).resolve() for value in sys.argv[1:3])
source = (root / 'books/countdown.c').read_text()
cameras = set(re.findall(r'\.camera = "([^"]+)"', source))
item_ids = re.findall(r'\{\.item = \w+, \.id = "([^"]+)"', source)
ACTS = {'train': 1, 'gorge': 1, 'star': 2, 'fortress': 3, 'orbit': 3, 'obs': 4, 'ship': 4, 'red': 4, 'cmd': 4}


def Book(viewport=(1100, 800)):
    return HeadlessBook(binary, root, 'countdown', viewport)


def follow(book, route):
    """Replay a route: 'continue' taps the button, 'hold:<id>' taps a carried thing, else a choice command."""
    for command in route:
        if command == 'continue':
            book.continue_page()
        elif command.startswith('hold:'):
            book.hold(command[5:])
        else:
            book.choose(command)
    return book.view


def camera(view):
    return Path(view['image']).stem


def carried(view):
    return {c['command'] for c in view['choices'] if c['kind'] == 'item'}


def commands(view):
    return {c['command'] for c in view['choices'] if c['kind'] == 'object'}


assert len(item_ids) == len(set(item_ids)) == 10
for item in item_ids:
    assert (root / f'books/countdown/rooms/item-{item}.jpg').is_file(), item

# Track the passages that set hidden facts, rather than every optional conversation. Hearing and
# surveying can return to decisions; their order must not multiply identical worlds indefinitely.
# The exploration still enters every page through published choices, never by setting runtime state.
fact_passages = {}
for block in re.split(r'(?=    \{\.id = ")', source):
    if not re.search(r'\.sets = ', block):
        continue
    fact = re.search(r'\.sets = ([^,]+)', block).group(1)
    prose = re.search(r'\.text = ((?:"(?:[^"\\]|\\.)*"\s*)+)', block).group(1)
    fact_passages[''.join(ast.literal_eval(t) for t in re.findall(r'"(?:[^"\\]|\\.)*"', prose))] = fact

# On each room page hold and release every carried thing, recording all its uses. Hidden facts
# belong to one act, so revisit a page for each different fact history within that act.
seen, explored, endings, frontier = {}, set(), {}, [([], frozenset())]
while frontier:
    route, past = frontier.pop()
    book = Book()
    view = follow(book, route)
    act = ACTS[camera(view).split('-')[0]]
    state = (view['kind'], view['image'], view['text'], tuple(c['command'] for c in view['choices']))
    key = (state, frozenset(p for a, p in past if a == act))
    if key in explored:
        book.close()
        continue
    explored.add(key)
    seen.setdefault(state, route)
    if view['text'] in fact_passages:
        past = past | {(act, fact_passages[view['text']])}
    assert Path(view['image']).is_file(), f'missing picture for {route}: {view["image"]}'
    if view['kind'] == 'ended':
        endings[camera(view)] = (view['ending'], route)
    elif view['kind'] == 'beat':
        frontier.append((route + ['continue'], past))
    else:
        assert 1 <= len(commands(view)) <= 4, (route, view['choices'])
        frontier.extend((route + [c['command']], past) for c in view['choices'] if c['kind'] == 'object')
        for item in sorted(carried(view)):
            # Holding a thing keeps the picture, shows what it is and offers only its uses here.
            held = book.hold(item)
            assert held['held'] == item and held['image'] == view['image'] and held['text'] != view['text']
            assert carried(held) == carried(view)
            frontier.extend((route + ['hold:' + item, command], past) for command in commands(held))
            assert book.hold(item) == view
    book.close()

reached = {Path(state[1]).stem for state in seen}
assert reached == cameras, (cameras - reached, reached - cameras)
kinds = sorted(kind for kind, _ in endings.values())
assert kinds.count('success') == 1 and kinds.count('partial') == 3 and kinds.count('failure') == 8, endings

START = ['continue', 'train-lurch', 'continue', 'continue']

# The first fork: a power held in the inventory opens a way that plain choices do not.
book = Book()
follow(book, ['continue'])
assert commands(book.view) == {'train-lurch', 'train-early', 'train-conductor'}
assert carried(book.view) == {'heat', 'xray', 'breath', 'hearing', 'pass'}
book.hold('hearing')
assert book.view['held'] == 'hearing' and book.view['text'].startswith('Суперслух')
assert commands(book.view) == {'train-hear'}
book.hold('hearing')  # tapping it again puts it away
assert book.view['held'] == '' and commands(book.view) == {'train-lurch', 'train-early', 'train-conductor'}
book.hold('heat')
assert commands(book.view) == set()  # nothing here to heat
follow(book, ['hold:heat', 'train-lurch', 'continue', 'continue', 'hold:xray', 'train-xray', 'continue'])
assert camera(book.view) == 'train-show-panic' and commands(book.view) == {'restroom', 'end-exposed'}
book.hold('xray')
assert commands(book.view) == set()  # already looked ahead
follow(book, ['hold:xray', 'restroom', 'continue'])
assert commands(book.view) == {'gorge-bridge', 'end-headon', 'gorge-lift'}  # the timbers are now a way
book.close()

# Without a survey there is no bridge choice; surveying from outside still opens it.
book = Book()
follow(book, START + ['hold:hearing'])
panic_hearing = book.view['text']
assert commands(book.view) == {'train-hear-panic'}
follow(book, ['train-hear-panic', 'continue', 'restroom', 'continue', 'hold:hearing'])
assert commands(book.view) == {'gorge-hear'} and book.view['text'] != panic_hearing
follow(book, ['gorge-hear', 'continue', 'hold:xray', 'gorge-survey', 'continue'])
assert 'gorge-bridge' in commands(book.view)
book.close()

book = Book()
follow(book, START + ['restroom', 'continue'])
assert commands(book.view) == {'end-headon', 'gorge-lift'}
follow(book, ['gorge-lift', 'continue', 'hold:hearing'])
assert 'сцепки' in book.view['text'] and commands(book.view) == set()
follow(book, ['hold:heat', 'gorge-weld', 'continue', 'continue', 'train-report', 'continue', 'continue'])
assert camera(book.view) == 'star-show-gate'
# The press pass is the way in; it stays with the guard.
assert commands(book.view) == {'end-gate'}
follow(book, ['end-gate'])
assert book.view['ending'] == 'failure' and book.view['choices'][0]['command'] == 'star-gate'
book.retry()
assert camera(book.view) == 'star-show-gate' and 'pass' in carried(book.view)
follow(book, ['hold:pass', 'star-arrive'])
assert book.view['kind'] == 'beat'
follow(book, ['continue', 'continue'])
assert 'pass' not in carried(book.view)
# Taking the cable puts it in the inventory and off the floor; using it ties the men up.
follow(book, ['star-gas', 'continue'])
assert 'star-cable' in commands(book.view) and 'cable' not in carried(book.view)
follow(book, ['star-cable', 'continue'])
assert 'cable' in carried(book.view) and 'star-cable' not in commands(book.view)
follow(book, ['hold:cable', 'star-lasso'])
assert camera(book.view) == 'star-caught'
follow(book, ['continue', 'continue'])
assert 'cable' not in carried(book.view)
# The grenade goes to the Fortress, which turns it into the antidote sprayer.
follow(book, ['star-took-vial', 'continue', 'continue', 'hold:vial', 'fortress-analysis', 'continue', 'continue'])
assert camera(book.view) == 'orbit-show-belt'
assert 'vial' not in carried(book.view) and 'sprayer' in carried(book.view)
follow(book, ['hold:xray', 'orbit-xray', 'continue'])
assert commands(book.view) == {'end-meteors'}
book.hold('heat')
assert commands(book.view) == {'orbit-clear'}  # the trap first, now that lead has been seen
follow(book, ['orbit-clear', 'continue', 'continue', 'ship-fight', 'red-beam', 'continue'])
# The red sun takes heat vision and super-breath; X-ray and hearing stay.
assert camera(book.view) == 'red-show-brainiac'
follow(book, ['continue'])
assert carried(book.view) == {'xray', 'hearing', 'sprayer'}
follow(book, ['red-catch', 'continue'])
assert 'drone' in carried(book.view) and 'red-catch' not in commands(book.view)
follow(book, ['hold:drone', 'red-globe', 'continue'])
assert book.view['ending'] == 'failure'
book.retry()  # try again with the drone in hand, as at that moment
assert camera(book.view) == 'red-show-room' and 'drone' in carried(book.view)
follow(book, ['hold:drone', 'red-escape', 'continue'])
assert carried(book.view) == {'heat', 'xray', 'breath', 'hearing', 'sprayer'}
follow(book, ['command', 'continue'])
# Without the antidote in the tanks the trap is only a partial victory.
follow(book, ['cmd-took', 'continue', 'hold:canister', 'cmd-trap'])
assert book.view['ending'] == 'partial' and camera(book.view) == 'cmd-frozen'
book.retry()
assert camera(book.view) == 'cmd-show-brainiac' and 'canister' in carried(book.view)
follow(book, ['hold:sprayer', 'cmd-spray', 'continue', 'hold:canister', 'cmd-trap'])
assert book.view['ending'] == 'success' and camera(book.view) == 'cmd-victory'
assert [(c['kind'], c['label']) for c in book.view['choices']] == [('retry', 'Начать сначала')]
book.tap_choice(0)
assert camera(book.view) == 'train-show-clark' and book.view['kind'] == 'beat'
book.close()

# The authored reading areas, circles and inventory row must fit the landscape iPad shapes too.
# Replaying the longest routes checks every page on the way.
routes = sorted(seen.values(), key=len, reverse=True)
longest = []
for route in routes:
    if not any(other[:len(route)] == route for other in longest):
        longest.append(route)
for viewport in ((1024, 768), (1133, 744), (1366, 1024)):
    for route in longest:
        book = Book(viewport)
        follow(book, route)
        book.close()
    # Inspection responses without a target are not part of those routes. Check every train decision
    # and fact variant with every carried power at each crop, including releasing it to restore prose.
    for state, route in seen.items():
        if state[0] != 'room' or Path(state[1]).stem.split('-')[0] not in ('train', 'gorge'):
            continue
        book = Book(viewport)
        normal = follow(book, route)
        for item in sorted(carried(normal)):
            held = book.hold(item)
            assert held['text'] != normal['text']
            assert book.hold(item) == normal
        book.close()

print(f'Countdown: {len(seen)} page states, {len(cameras)} pictures, {len(endings)} endings, things and retries passed')
