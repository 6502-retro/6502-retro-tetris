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
TOP_COLLISION   = 5

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
    ; Z
    .byte $FF,$FF, $00,$FF, $01,$00, $00,$00
    .byte $01,$FF, $01,$00, $00,$01, $00,$00
    .byte $FF,$00, $00,$01, $01,$01, $00,$00
    .byte $00,$FF, $FF,$00, $FF,$01, $00,$00
    ; S
    .byte $FF,$00, $00,$FF, $01,$FF, $00,$00
    .byte $00,$FF, $01,$00, $01,$01, $00,$00
    .byte $FF,$01, $00,$01, $01,$00, $00,$00
    .byte $FF,$FF, $FF,$00, $00,$01, $00,$00
    ;L
    .byte $FF,$00, $01,$00, $01,$FF, $00,$00
    .byte $00,$FF, $00,$01, $01,$01, $00,$00
    .byte $FF,$00, $FF,$01, $01,$00, $00,$00
    .byte $FF,$FF, $00,$FF, $00,$01, $00,$00
    ;J
    .byte $FF,$FF, $FF,$00, $01,$00, $00,$00
    .byte $00,$FF, $01,$FF, $00,$01, $00,$00
    .byte $FF,$00, $01,$00, $01,$01, $00,$00
    .byte $00,$FF, $00,$01, $FF,$01, $00,$00
    ;O
    .byte $01,$00, $00,$01, $01,$01, $00,$00
    .byte $01,$00, $00,$01, $01,$01, $00,$00
    .byte $01,$00, $00,$01, $01,$01, $00,$00
    .byte $01,$00, $00,$01, $01,$01, $00,$00

map:
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "+          +",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "|          |",$80
    .byte "+==========+",$FF


kicks_common:
    ; 0 -> 1 (Clockwise)
    .byte $00,$00, $FF,$00, $FF,$FF, $00,$02, $FF,$02
    ; 1 -> 2 (Clockwise)
    .byte $00,$00, $01,$00, $01,$01, $00,$FE, $01,$FE
    ; 2 -> 3 (Clockwise)
    .byte $00,$00, $01,$00, $01,$FF, $00,$02, $01,$02
    ; 3 -> 0 (Clockwise)
    .byte $00,$00, $FF,$00, $FF,$01, $00,$FE, $FF,$FE

    ; 0 -> 3 (Counter-Clockwise)
    .byte $00,$00, $01,$00, $01,$FF, $00,$02, $01,$02
    ; 3 -> 2 (Counter-Clockwise)
    .byte $00,$00, $FF,$00, $FF,$01, $00,$FE, $FF,$FE
    ; 2 -> 1 (Counter-Clockwise)
    .byte $00,$00, $FF,$00, $FF,$FF, $00,$02, $FF,$02
    ; 1 -> 0 (Counter-Clockwise)
    .byte $00,$00, $01,$00, $01,$01, $00,$FE, $01,$FE


kicks_I:
    ; 0 -> 1 (CW)
    .byte $00,$00, $FE,$00, $01,$00, $FE,$01, $01,$FE
    ; 1 -> 2 (CW)
    .byte $00,$00, $FF,$00, $02,$00, $FF,$FE, $02,$01
    ; 2 -> 3 (CW)
    .byte $00,$00, $02,$00, $FF,$00, $02,$FF, $FF,$02
    ; 3 -> 0 (CW)
    .byte $00,$00, $01,$00, $FE,$00, $01,$02, $FE,$FF

    ; 0 -> 3 (CCW)
    .byte $00,$00, $FF,$00, $02,$00, $FF,$FE, $02,$01
    ; 3 -> 2 (CCW)
    .byte $00,$00, $FE,$00, $01,$00, $FE,$01, $01,$FE
    ; 2 -> 1 (CCW)
    .byte $00,$00, $01,$00, $FE,$00, $01,$02, $FE,$FF
    ; 1 -> 0 (CCW)
    .byte $00,$00, $02,$00, $FF,$00, $02,$FF, $FF,$02

