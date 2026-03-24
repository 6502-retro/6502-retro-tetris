# 6502-Retro-Tetris

## Game Mechanics

This version of Tetris is mostly based on the Nintendo GameBoy version with the
following differences:

- No soft drop.
- Joy stick input is single button only, so when playing with the joystick,
  only clockwise rotation is allowed.
- There are no additional points for distance traveled in a hard drop.  NOTE:
  This might change in future.
- Music is probably different
- This game does _not_ implement the Tetris Guideline Super Rotation System.

## Levels

A new level is achieved every 10 cleared lines.  The speed of the game increases with each level attained to a maximum of 20 levels.

## Score

Scoring is calculated based on the current level and the number of lines cleared at once.

- 1 line:  100 x level
- 2 lines: 300 x level
- 3 lines: 500 x level
- 4 lines: 800 x level

## Controls

If you press `SPACE` to start a game from the menu, then the game will accept keyboard controls.

If you press `FIRE` on your joystick to start a game from the menu, then the game will accept joystick controls.

- Joystick controls:
  - `FIRE` rotate cw
  - `LEFT` move left
  - `RIGHT` move right
  - `DOWN` hard drop
- Keyboard controls:
  - `z` rotate ccw
  - `x` rotate cw
  - `,` move left
  - `.` move right
  - ` ` hard drop

## References and Acknowledgements

Random function taken directly from CC65 `libsrc/common/_rand.s`
