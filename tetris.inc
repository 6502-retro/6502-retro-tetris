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

I_block: ; $80 - cyan
    .byte $FF,$C3,$A5,$99,$99,$A5,$C3,$FF
T_block: ; $88 - magenta
    .byte $FF,$81,$A5,$9D,$9D,$BD,$81,$FF
Z_block: ; $90 - dark red
    .byte $FF,$FF,$FF,$E7,$E7,$FF,$FF,$FF
S_block: ; $98 - light green
    .byte $FF,$FF,$C3,$C3,$C3,$C3,$FF,$FF
L_block: ; $A0 - light red
    .byte $FF,$81,$BD,$A5,$A5,$BD,$81,$FF
J_block: ; $A8 - light blue
    .byte $FF,$81,$BD,$A5,$A5,$BD,$81,$FF
O_block: ; $B0 - light yellow
    .byte $FF,$81,$BD,$A5,$A5,$BD,$81,$FF

tet_blocks:
    .byte $80,$88,$90,$98,$A0,$A8,$B0

colortable:
        ;  00  08  10  18  20  28  30  38  40  48  50  58  60  68  70  78 
    .byte $E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1
        ;  80  88  90  98  a0  a8  b0  b8  c0  c8  d0  d8  e0  e8  f0  f8 
    .byte $71,$D1,$31,$91,$81,$B1,$B1,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1,$E1

map:
    .byte "+          +----------+",$80
    .byte "|          |  TETRIS  |",$80
    .byte "+          +----------+",$80
    .byte "|          |          |",$80
    .byte "|          |          |",$80
    .byte "|          |          |",$80
    .byte "|          |          |",$80
    .byte "|          +----------+",$80
    .byte "|  START   |          |",$80
    .byte "| [SPACE]  |  SCORE   |",$80
    .byte "|          |          |",$80
    .byte "|  EXIT!   |          |",$80
    .byte "| [ ESC ]  +----------+",$80
    .byte "|          |          |",$80
    .byte "|          |  LEVEL   |",$80
    .byte "|          |          |",$80
    .byte "|          |          |",$80
    .byte "|          +----------+",$80
    .byte "|          |          |",$80
    .byte "|          |  LINES   |",$80
    .byte "|          |          |",$80
    .byte "|          |          |",$80
    .byte "+==========+----------+",$80
    .byte "productiondave     2026",$FF

; --- SINGLE (100 * Level) ---
single_mid:  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20
single_high: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; --- DOUBLE (300 * Level) ---
double_mid:  .byte $00,$03,$06,$09,$12,$15,$18,$21,$24,$27,$30,$33,$36,$39,$42,$45,$48,$51,$54,$57,$60
double_high: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; --- TRIPLE (500 * Level) ---
triple_mid:  .byte $00,$05,$10,$15,$20,$25,$30,$35,$40,$45,$50,$55,$60,$65,$70,$75,$80,$85,$90,$95,$00
triple_high: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01

; --- TETRIS (800 * Level) ---
tetris_mid:  .byte $00,$08,$16,$24,$32,$40,$48,$56,$64,$72,$80,$88,$96,$04,$12,$20,$28,$36,$44,$52,$60
tetris_high: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01


