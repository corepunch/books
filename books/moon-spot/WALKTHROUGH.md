# Walkthrough — Мира и лунный зайчик

Captions as the reader sees them. «Дальше» is the Continue button.

## Golden path (basket ending, four choices)

1. *Запрыгнуть на табурет?* → Дальше
2. *Толкнуть зеркальце?* → Дальше
3. *Повернуть зайчика к корзинке?* — ending «в корзинке».

## Бублик's ending

1. *Запрыгнуть на табурет?* → Дальше
2. *Толкнуть зеркальце?* → Дальше
3. *Спуститься на пол?* → Дальше
4. *Поговорить с Бубликом?* → Дальше
5. *Лечь к Бублику?* — ending «вдвоём».

## Alternatives

- **Ask Бублик first.** *Разбудить Бублика?* gives the clue "the spot comes
  from the window" and his invitation. The floor page changes, and after the
  push the awake floor offers *Лечь к Бублику?* at once. The basket ending then
  adds his sleepy «Я же говорил — с окна».
- **Jokes.** *Поймать зайчика?* on the floor and *Поймать занавеску?* on the
  table are short funny beats that return to the same page; each repeats a clue.
- **Going back.** *Спуститься на пол?* before the push returns to the unchanged
  kitchen.

`tests/test_moon-spot.py` walks all of these and checks that every page camera
is reached.
