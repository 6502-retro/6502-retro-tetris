; vim: set ft=asm_ca65 ts=4 sw=4 et cc=80:
; 6502-Retro-Tetris Game
;
; Copyright (c) 2026 David Latham
;
; This code is licensed under the MIT license
;
; https://github.com/6502-retro/6502-retro-tetris

PLAYFIELD_X_OFFSET = 5

LEFT_COLLISION  = 1
RIGHT_COLLISION = 2
FLOOR_COLLISION = 3
PIECE_COLLISION = 4

rotations:
    ; I piece
    .byte $00,$01, $01,$01, $02,$01, $03,$01
    .byte $02,$00, $02,$01, $02,$02, $02,$03
    .byte $00,$02, $01,$02, $02,$02, $03,$02
    .byte $01,$00, $01,$01, $01,$02, $01,$03
    ; T piece
    .byte $FF,$00, $00,$FF, $01,$00, $00,$00
    .byte $00,$FF, $01,$00, $00,$01, $00,$00
    .byte $FF,$00, $00,$01, $01,$00, $00,$00
    .byte $FF,$00, $00,$FF, $00,$01, $00,$00

