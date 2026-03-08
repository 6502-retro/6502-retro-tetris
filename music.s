; vim: set ft=asm_ca65 ts=4 sw=4 et cc=80:
; 6502-Retro-Tetris Game
;
; Copyright (c) 2026 David Latham
;
; This code is licensed under the MIT license
;
; https://github.com/6502-retro/6502-retro-tetris


NT_NOTE_OFF = 1
NT_NOTE_ON  = 2
NT_LOOP     = 3

.rodata

NOTES_FINE:
        .byte   $0B ; C2   0x00
        .byte   $05 ; C#2  0x02
        .byte   $03 ; D2   0x04
        .byte   $03 ; D#2  0x06
        .byte   $06 ; E2   0x08
        .byte   $0B ; F2   0x0a
        .byte   $03 ; F#2  0x0c
        .byte   $0D ; G2   0x0e
        .byte   $09 ; G#2  0x10
        .byte   $08 ; A3   0x12
        .byte   $08 ; A#3  0x14
        .byte   $0A ; B3   0x16
        .byte   $0D ; C3   0x18
        .byte   $02 ; C#3  0x1a
        .byte   $09 ; D3   0x1c
        .byte   $01 ; D#3  0x1e
        .byte   $0B ; E3   0x20
        .byte   $05 ; F3   0x22
        .byte   $01 ; F#3  0x24
        .byte   $0E ; G3   0x26
        .byte   $0C ; G#3  0x28
        .byte   $0C ; A4   0x2a
        .byte   $0C ; A#4  0x2c
        .byte   $0D ; B4   0x2e
        .byte   $0E ; C4   0x30
        .byte   $01 ; C#4  0x32
        .byte   $04 ; D4   0x34
        .byte   $08 ; D#4  0x36
        .byte   $0D ; E4   0x38
        .byte   $02 ; F4   0x3a
        .byte   $08 ; F#4  0x3c
        .byte   $0F ; G4   0x3e
        .byte   $06 ; G#4  0x40
        .byte   $0E ; A5   0x42
        .byte   $06 ; A#5  0x44
        .byte   $0E ; B5   0x46
        .byte   $07 ; C5   0x48
        .byte   $00 ; C#5  0x4a
        .byte   $0A ; D5   0x4c
        .byte   $04 ; D#5  0x4e
        .byte   $0E ; E5   0x50
        .byte   $09 ; F5   0x52
        .byte   $04 ; F#5  0x54
        .byte   $0F ; G5   0x56
        .byte   $0B ; G#5  0x58
        .byte   $07 ; A6   0x5a
        .byte   $03 ; A#6  0x5c
        .byte   $0F ; B6   0x5e
        .byte   $0B ; C6   0x60
        .byte   $08 ; C#6  0x62
        .byte   $05 ; D6   0x64
        .byte   $02 ; D#6  0x66
        .byte   $0F ; E6   0x68
        .byte   $0C ; F6   0x6a
        .byte   $0A ; F#6  0x6c
        .byte   $07 ; G6   0x6e
        .byte   $05 ; G#6  0x70
        .byte   $03 ; A7   0x72
        .byte   $01 ; A#7  0x74
        .byte   $0F ; B7   0x76
        .byte   $0D ; C7   0x78
        .byte   $0C ; C#7  0x7a
        .byte   $0A ; D7   0x7c
        .byte   $09 ; D#7  0x7e
        .byte   $07 ; E7   0x80
        .byte   $06 ; F7   0x82
        .byte   $05 ; F#7  0x84
        .byte   $03 ; G7   0x86
        .byte   $02 ; G#7  0x88
NOTES_COURSE:
        .byte   $3B ; C2   0x00
        .byte   $38 ; C#2  0x02
        .byte   $35 ; D2   0x04
        .byte   $32 ; D#2  0x06
        .byte   $2F ; E2   0x08
        .byte   $2C ; F2   0x0a
        .byte   $2A ; F#2  0x0c
        .byte   $27 ; G2   0x0e
        .byte   $25 ; G#2  0x10
        .byte   $23 ; A3   0x12
        .byte   $21 ; A#3  0x14
        .byte   $1F ; B3   0x16
        .byte   $1D ; C3   0x18
        .byte   $1C ; C#3  0x1a
        .byte   $1A ; D3   0x1c
        .byte   $19 ; D#3  0x1e
        .byte   $17 ; E3   0x20
        .byte   $16 ; F3   0x22
        .byte   $15 ; F#3  0x24
        .byte   $13 ; G3   0x26
        .byte   $12 ; G#3  0x28
        .byte   $11 ; A4   0x2a
        .byte   $10 ; A#4  0x2c
        .byte   $0F ; B4   0x2e
        .byte   $0E ; C4   0x30
        .byte   $0E ; C#4  0x32
        .byte   $0D ; D4   0x34
        .byte   $0C ; D#4  0x36
        .byte   $0B ; E4   0x38
        .byte   $0B ; F4   0x3a
        .byte   $0A ; F#4  0x3c
        .byte   $09 ; G4   0x3e
        .byte   $09 ; G#4  0x40
        .byte   $08 ; A5   0x42
        .byte   $08 ; A#5  0x44
        .byte   $07 ; B5   0x46
        .byte   $07 ; C5   0x48
        .byte   $07 ; C#5  0x4a
        .byte   $06 ; D5   0x4c
        .byte   $06 ; D#5  0x4e
        .byte   $05 ; E5   0x50
        .byte   $05 ; F5   0x52
        .byte   $05 ; F#5  0x54
        .byte   $04 ; G5   0x56
        .byte   $04 ; G#5  0x58
        .byte   $04 ; A6   0x5a
        .byte   $04 ; A#6  0x5c
        .byte   $03 ; B6   0x5e
        .byte   $03 ; C6   0x60
        .byte   $03 ; C#6  0x62
        .byte   $03 ; D6   0x64
        .byte   $03 ; D#6  0x66
        .byte   $02 ; E6   0x68
        .byte   $02 ; F6   0x6a
        .byte   $02 ; F#6  0x6c
        .byte   $02 ; G6   0x6e
        .byte   $02 ; G#6  0x70
        .byte   $02 ; A7   0x72
        .byte   $02 ; A#7  0x74
        .byte   $01 ; B7   0x76
        .byte   $01 ; C7   0x78
        .byte   $01 ; C#7  0x7a
        .byte   $01 ; D7   0x7c
        .byte   $01 ; D#7  0x7e
        .byte   $01 ; E7   0x80
        .byte   $01 ; F7   0x82
        .byte   $01 ; F#7  0x84
        .byte   $01 ; G7   0x86
        .byte   $01 ; G#7  0x88

MUSIC:
    .word 0
    .byte NT_NOTE_ON, 0, 40, 8 ; E5
    .word 0
    .byte NT_NOTE_ON, 1, 16, 12  ; E3
    .word 2
    .byte NT_NOTE_OFF, 0
    .word 2
    .byte NT_NOTE_ON, 0, 28, 8 ; E4
    .word 4
    .byte NT_NOTE_OFF, 0
    .word 4
    .byte NT_NOTE_OFF, 1
    .word 4
    .byte NT_NOTE_ON, 0, 35, 8 ; B4
    .word 4
    .byte NT_NOTE_ON, 1, 16, 12  ; E3
    .word 5
    .byte NT_NOTE_OFF, 0
    .word 6
    .byte NT_NOTE_OFF, 1
    .word 6
    .byte NT_NOTE_ON, 0, 36, 8 ; C5
    .word 6
    .byte NT_NOTE_ON, 1, 28, 12  ; E4
    .word 7
    .byte NT_NOTE_OFF, 0
    .word 8
    .byte NT_NOTE_OFF, 1
    .word 8
    .byte NT_NOTE_ON, 0, 38, 8 ; D5
    .word 8
    .byte NT_NOTE_ON, 1, 16, 12  ; E3
    .word 10
    .byte NT_NOTE_OFF, 0
    .word 10
    .byte NT_NOTE_ON, 0, 28, 8 ; E4
    .word 12
    .byte NT_NOTE_OFF, 0
    .word 12
    .byte NT_NOTE_OFF, 1
    .word 12
    .byte NT_NOTE_ON, 0, 36, 8 ; C5
    .word 12
    .byte NT_NOTE_ON, 1, 16, 12  ; E3
    .word 13
    .byte NT_NOTE_OFF, 0
    .word 14
    .byte NT_NOTE_OFF, 1
    .word 14
    .byte NT_NOTE_ON, 0, 35, 8 ; B4
    .word 14
    .byte NT_NOTE_ON, 1, 28, 12  ; E4
    .word 15
    .byte NT_NOTE_OFF, 0
    .word 16
    .byte NT_NOTE_OFF, 1
    .word 16
    .byte NT_NOTE_ON, 0, 33, 8 ; A4
    .word 16
    .byte NT_NOTE_ON, 1, 9, 12   ; A2
    .word 18
    .byte NT_NOTE_OFF, 0
    .word 18
    .byte NT_NOTE_ON, 0, 21, 8 ; A3
    .word 20
    .byte NT_NOTE_OFF, 0
    .word 20
    .byte NT_NOTE_OFF, 1
    .word 20
    .byte NT_NOTE_ON, 0, 33, 8 ; A4
    .word 20
    .byte NT_NOTE_ON, 1, 9, 12   ; A2
    .word 21
    .byte NT_NOTE_OFF, 0
    .word 22
    .byte NT_NOTE_OFF, 1
    .word 22
    .byte NT_NOTE_ON, 0, 36, 8 ; C5
    .word 22
    .byte NT_NOTE_ON, 1, 21, 12  ; A3
    .word 23
    .byte NT_NOTE_OFF, 0
    .word 24
    .byte NT_NOTE_OFF, 1
    .word 24
    .byte NT_NOTE_ON, 0, 40, 8 ; E5
    .word 24
    .byte NT_NOTE_ON, 1, 9, 12   ; A2
    .word 26
    .byte NT_NOTE_OFF, 0
    .word 26
    .byte NT_NOTE_ON, 0, 21, 8 ; A3
    .word 28
    .byte NT_NOTE_OFF, 0
    .word 28
    .byte NT_NOTE_OFF, 1
    .word 28
    .byte NT_NOTE_ON, 0, 38, 8 ; D5
    .word 28
    .byte NT_NOTE_ON, 1, 9, 12   ; A2
    .word 29
    .byte NT_NOTE_OFF, 0
    .word 30
    .byte NT_NOTE_OFF, 1
    .word 30
    .byte NT_NOTE_ON, 0, 36, 8 ; C5
    .word 30
    .byte NT_NOTE_ON, 1, 21, 12  ; A3
    .word 31
    .byte NT_NOTE_OFF, 0
    .word 32
    .byte NT_NOTE_OFF, 1
    .word 32
    .byte NT_NOTE_ON, 0, 35, 8 ; B4
    .word 32
    .byte NT_NOTE_ON, 1, 8, 12   ; G#2
    .word 34
    .byte NT_NOTE_OFF, 0
    .word 34
    .byte NT_NOTE_ON, 0, 20, 8 
    .word 36
    .byte NT_NOTE_OFF, 0
    .word 36
    .byte NT_NOTE_OFF, 1
    .word 36
    .byte NT_NOTE_ON, 0, 35, 8 
    .word 36
    .byte NT_NOTE_ON, 1, 8, 12
    .word 37
    .byte NT_NOTE_OFF, 0
    .word 38
    .byte NT_NOTE_OFF, 1
    .word 38
    .byte NT_NOTE_ON, 0, 36, 8 
    .word 38
    .byte NT_NOTE_ON, 1, 20, 12
    .word 39
    .byte NT_NOTE_OFF, 0
    .word 40
    .byte NT_NOTE_OFF, 1
    .word 40
    .byte NT_NOTE_ON, 0, 38, 8
    .word 40
    .byte NT_NOTE_ON, 1, 8, 12
    .word 42
    .byte NT_NOTE_OFF, 0
    .word 42
    .byte NT_NOTE_ON, 0, 20, 8 
    .word 44
    .byte NT_NOTE_OFF, 0
    .word 44
    .byte NT_NOTE_OFF, 1
    .word 44
    .byte NT_NOTE_ON, 0, 40, 8
    .word 44
    .byte NT_NOTE_ON, 1, 8, 12 
    .word 46
    .byte NT_NOTE_OFF, 0
    .word 46
    .byte NT_NOTE_ON, 0, 20, 8
    .word 47
    .byte NT_NOTE_OFF, 0
    .word 48
    .byte NT_NOTE_OFF, 1
    .word 48
    .byte NT_NOTE_ON, 0, 36, 8
    .word 48
    .byte NT_NOTE_ON, 1, 9, 12
    .word 50
    .byte NT_NOTE_OFF, 0
    .word 50
    .byte NT_NOTE_ON, 0, 21, 8
    .word 52
    .byte NT_NOTE_OFF, 0
    .word 52
    .byte NT_NOTE_OFF, 1
    .word 52
    .byte NT_NOTE_ON, 0, 33, 8
    .word 52
    .byte NT_NOTE_ON, 1, 9, 12
    .word 54
    .byte NT_NOTE_OFF, 0
    .word 54
    .byte NT_NOTE_ON, 0, 21, 8
    .word 56
    .byte NT_NOTE_OFF, 0
    .word 56
    .byte NT_NOTE_OFF, 1
    .word 56
    .byte NT_NOTE_ON, 0, 33, 8
    .word 56
    .byte NT_NOTE_ON, 1, 9, 12
    .word 58
    .byte NT_NOTE_OFF, 0
    .word 58
    .byte NT_NOTE_ON, 0, 21, 8
    .word 60
    .byte NT_NOTE_OFF, 0
    .word 60
    .byte NT_NOTE_OFF, 1
    .word 60
    .byte NT_NOTE_ON, 0, 11, 8
    .word 60
    .byte NT_NOTE_ON, 1, 23, 12
    .word 61
    .byte NT_NOTE_OFF, 0
    .word 62
    .byte NT_NOTE_OFF, 1
    .word 62
    .byte NT_NOTE_ON, 0, 12, 8
    .word 62
    .byte NT_NOTE_ON, 1, 24, 12
    .word 63
    .byte NT_NOTE_OFF, 0
    .word 64
    .byte NT_NOTE_OFF, 1
    .word 64
    .byte NT_NOTE_ON, 0, 14, 8
    .word 66
    .byte NT_NOTE_OFF, 0
    .word 66
    .byte NT_NOTE_ON, 0, 26, 8
    .word 68
    .byte NT_NOTE_OFF, 0
    .word 68
    .byte NT_NOTE_ON, 0, 38, 8
    .word 68
    .byte NT_NOTE_ON, 1, 14, 12
    .word 70
    .byte NT_NOTE_OFF, 0
    .word 70
    .byte NT_NOTE_ON, 0, 26, 8
    .word 72
    .byte NT_NOTE_OFF, 0
    .word 72
    .byte NT_NOTE_OFF, 1
    .word 72
    .byte NT_NOTE_ON, 0, 41, 8
    .word 72
    .byte NT_NOTE_ON, 1, 14, 12
    .word 73
    .byte NT_NOTE_OFF, 0
    .word 74
    .byte NT_NOTE_OFF, 1
    .word 74
    .byte NT_NOTE_ON, 0, 45, 8
    .word 74
    .byte NT_NOTE_ON, 1, 26, 12
    .word 76
    .byte NT_NOTE_OFF, 0
    .word 76
    .byte NT_NOTE_ON, 0, 14, 8
    .word 77
    .byte NT_NOTE_OFF, 0
    .word 78
    .byte NT_NOTE_OFF, 1
    .word 78
    .byte NT_NOTE_ON, 0, 26, 8
    .word 80
    .byte NT_NOTE_OFF, 0
    .word 80
    .byte NT_NOTE_ON, 0, 43, 8
    .word 80
    .byte NT_NOTE_ON, 1, 14, 12
    .word 82
    .byte NT_NOTE_OFF, 0
    .word 82
    .byte NT_NOTE_OFF, 1
    .word 82
    .byte NT_NOTE_ON, 0, 41, 8
    .word 82
    .byte NT_NOTE_ON, 1, 26, 12
    .word 83
    .byte NT_NOTE_OFF, 0
    .word 84
    .byte NT_NOTE_OFF, 1
    .word 84
    .byte NT_NOTE_ON, 0, 40, 8
    .word 84
    .byte NT_NOTE_ON, 1, 12, 12
    .word 86
    .byte NT_NOTE_OFF, 0
    .word 86
    .byte NT_NOTE_ON, 0, 24, 8
    .word 88
    .byte NT_NOTE_OFF, 0
    .word 88
    .byte NT_NOTE_ON, 0, 12, 8
    .word 90
    .byte NT_NOTE_OFF, 0
    .word 90
    .byte NT_NOTE_ON, 0, 24, 8
    .word 92
    .byte NT_NOTE_OFF, 0
    .word 92
    .byte NT_NOTE_OFF, 1
    .word 92
    .byte NT_NOTE_ON, 0, 36, 8
    .word 92
    .byte NT_NOTE_ON, 1, 12, 12
    .word 93
    .byte NT_NOTE_OFF, 0
    .word 94
    .byte NT_NOTE_OFF, 1
    .word 94
    .byte NT_NOTE_ON, 0, 40, 8
    .word 94
    .byte NT_NOTE_ON, 1, 24, 12
    .word 96
    .byte NT_NOTE_OFF, 0
    .word 96
    .byte NT_NOTE_ON, 0, 12, 8
    .word 98
    .byte NT_NOTE_OFF, 0
    .word 98
    .byte NT_NOTE_ON, 0, 24, 8
    .word 100
    .byte NT_NOTE_OFF, 0
    .word 100
    .byte NT_NOTE_OFF, 1
    .word 100
    .byte NT_NOTE_ON, 0, 38, 8
    .word 100
    .byte NT_NOTE_ON, 1, 12, 12
    .word 102
    .byte NT_NOTE_OFF, 0
    .word 102
    .byte NT_NOTE_OFF, 1
    .word 102
    .byte NT_NOTE_ON, 0, 36, 8
    .word 102
    .byte NT_NOTE_ON, 1, 24, 12
    .word 103
    .byte NT_NOTE_OFF, 0
    .word 104
    .byte NT_NOTE_OFF, 1
    .word 104
    .byte NT_NOTE_ON, 0, 35, 8
    .word 104
    .byte NT_NOTE_ON, 1, 8, 12
    .word 106
    .byte NT_NOTE_OFF, 0
    .word 106
    .byte NT_NOTE_ON, 0, 20, 8
    .word 108
    .byte NT_NOTE_OFF, 0
    .word 108
    .byte NT_NOTE_ON, 0, 8, 8
    .word 110
    .byte NT_NOTE_OFF, 0
    .word 110
    .byte NT_NOTE_OFF, 1
    .word 110
    .byte NT_NOTE_ON, 0, 36, 8
    .word 110
    .byte NT_NOTE_ON, 1, 20, 12
    .word 111
    .byte NT_NOTE_OFF, 0
    .word 112
    .byte NT_NOTE_OFF, 1
    .word 112
    .byte NT_NOTE_ON, 0, 38, 8
    .word 112
    .byte NT_NOTE_ON, 1, 8, 12
    .word 114
    .byte NT_NOTE_OFF, 0
    .word 114
    .byte NT_NOTE_ON, 0, 20, 8
    .word 115
    .byte NT_NOTE_OFF, 0
    .word 116
    .byte NT_NOTE_OFF, 1
    .word 116
    .byte NT_NOTE_ON, 0, 40, 8
    .word 116
    .byte NT_NOTE_ON, 1, 8, 12
    .word 118
    .byte NT_NOTE_OFF, 0
    .word 118
    .byte NT_NOTE_ON, 0, 20, 8
    .word 120
    .byte NT_NOTE_OFF, 0
    .word 120
    .byte NT_NOTE_OFF, 1
    .word 120
    .byte NT_NOTE_ON, 0, 36, 8
    .word 120
    .byte NT_NOTE_ON, 1, 9, 12
    .word 122
    .byte NT_NOTE_OFF, 0
    .word 122
    .byte NT_NOTE_ON, 0, 21, 8
    .word 124
    .byte NT_NOTE_OFF, 0
    .word 124
    .byte NT_NOTE_OFF, 1
    .word 124
    .byte NT_NOTE_ON, 0, 33, 8
    .word 124
    .byte NT_NOTE_ON, 1, 9, 12
    .word 126
    .byte NT_NOTE_OFF, 0
    .word 126
    .byte NT_NOTE_ON, 0, 21, 8
    .word 127
    .byte NT_NOTE_OFF, 0
    .word 128
    .byte NT_NOTE_OFF, 1
    .word 128
    .byte NT_NOTE_ON, 0, 33, 8
    .word 128
    .byte NT_NOTE_ON, 1, 9, 12
    .word 130
    .byte NT_NOTE_OFF, 0
    .word 130
    .byte NT_NOTE_ON, 0, 21, 8
    .word 132
    .byte NT_NOTE_OFF, 0
    .word 132
    .byte NT_NOTE_OFF, 1
    .word 132
    .byte NT_NOTE_ON, 0, 9, 8
    .word 134
    .byte NT_NOTE_OFF, 0
    .word 134
    .byte NT_NOTE_ON, 0, 21, 8
    .word 136
    .byte NT_NOTE_OFF, 0
    .word 144
    .byte NT_NOTE_ON, 0, 40, 8
    .word 144
    .byte NT_NOTE_ON, 1, 9, 12
    .word 146
    .byte NT_NOTE_OFF, 0
    .word 146
    .byte NT_NOTE_ON, 0, 21, 8
    .word 148
    .byte NT_NOTE_OFF, 0
    .word 148
    .byte NT_NOTE_ON, 0, 9, 8
    .word 150
    .byte NT_NOTE_OFF, 0
    .word 150
    .byte NT_NOTE_ON, 0, 21, 8
    .word 152
    .byte NT_NOTE_OFF, 0
    .word 152
    .byte NT_NOTE_OFF, 1
    .word 152
    .byte NT_NOTE_ON, 0, 36, 8
    .word 152
    .byte NT_NOTE_ON, 1, 9, 12
    .word 154
    .byte NT_NOTE_OFF, 0
    .word 154
    .byte NT_NOTE_ON, 0, 21, 8
    .word 156
    .byte NT_NOTE_OFF, 0
    .word 156
    .byte NT_NOTE_ON, 0, 9, 8
    .word 158
    .byte NT_NOTE_OFF, 0
    .word 158
    .byte NT_NOTE_ON, 0, 21, 8
    .word 159
    .byte NT_NOTE_OFF, 0
    .word 160
    .byte NT_NOTE_OFF, 1
    .word 160
    .byte NT_NOTE_ON, 0, 38, 8
    .word 160
    .byte NT_NOTE_ON, 1, 8, 12
    .word 162
    .byte NT_NOTE_OFF, 0
    .word 162
    .byte NT_NOTE_ON, 0, 20, 8
    .word 164
    .byte NT_NOTE_OFF, 0
    .word 164
    .byte NT_NOTE_ON, 0, 8, 8
    .word 166
    .byte NT_NOTE_OFF, 0
    .word 166
    .byte NT_NOTE_ON, 0, 20, 8
    .word 168
    .byte NT_NOTE_OFF, 0
    .word 168
    .byte NT_NOTE_OFF, 1
    .word 168
    .byte NT_NOTE_ON, 0, 35, 8
    .word 168
    .byte NT_NOTE_ON, 1, 8, 12
    .word 170
    .byte NT_NOTE_OFF, 0
    .word 170
    .byte NT_NOTE_ON, 0, 20, 8
    .word 172
    .byte NT_NOTE_OFF, 0
    .word 172
    .byte NT_NOTE_ON, 0, 8, 8
    .word 174
    .byte NT_NOTE_OFF, 0
    .word 174
    .byte NT_NOTE_ON, 0, 20, 8
    .word 175
    .byte NT_NOTE_OFF, 0
    .word 176
    .byte NT_NOTE_OFF, 1
    .word 176
    .byte NT_NOTE_ON, 0, 36, 8
    .word 176
    .byte NT_NOTE_ON, 1, 9, 12
    .word 178
    .byte NT_NOTE_OFF, 0
    .word 178
    .byte NT_NOTE_ON, 0, 21, 8
    .word 180
    .byte NT_NOTE_OFF, 0
    .word 180
    .byte NT_NOTE_ON, 0, 9, 8
    .word 182
    .byte NT_NOTE_OFF, 0
    .word 182
    .byte NT_NOTE_ON, 0, 21, 8
    .word 184
    .byte NT_NOTE_OFF, 0
    .word 184
    .byte NT_NOTE_OFF, 1
    .word 184
    .byte NT_NOTE_ON, 0, 33, 8
    .word 184
    .byte NT_NOTE_ON, 1, 9, 12
    .word 186
    .byte NT_NOTE_OFF, 0
    .word 186
    .byte NT_NOTE_ON, 0, 21, 8
    .word 188
    .byte NT_NOTE_OFF, 0
    .word 188
    .byte NT_NOTE_ON, 0, 9, 8
    .word 190
    .byte NT_NOTE_OFF, 0
    .word 190
    .byte NT_NOTE_ON, 0, 21, 8
    .word 191
    .byte NT_NOTE_OFF, 0
    .word 192
    .byte NT_NOTE_OFF, 1
    .word 192
    .byte NT_NOTE_ON, 0, 32, 8
    .word 192
    .byte NT_NOTE_ON, 1, 8, 12
    .word 194
    .byte NT_NOTE_OFF, 0
    .word 194
    .byte NT_NOTE_ON, 0, 20, 8
    .word 196
    .byte NT_NOTE_OFF, 0
    .word 196
    .byte NT_NOTE_ON, 0, 8, 8
    .word 198
    .byte NT_NOTE_OFF, 0
    .word 198
    .byte NT_NOTE_ON, 0, 20, 8
    .word 200
    .byte NT_NOTE_OFF, 0
    .word 200
    .byte NT_NOTE_OFF, 1
    .word 200
    .byte NT_NOTE_ON, 0, 35, 8
    .word 200
    .byte NT_NOTE_ON, 1, 8, 12
    .word 202
    .byte NT_NOTE_OFF, 0
    .word 202
    .byte NT_NOTE_ON, 0, 20, 8
    .word 204
    .byte NT_NOTE_OFF, 0
    .word 204
    .byte NT_NOTE_ON, 0, 8, 8
    .word 206
    .byte NT_NOTE_OFF, 0
    .word 206
    .byte NT_NOTE_ON, 0, 20, 8
    .word 207
    .byte NT_NOTE_OFF, 0
    .word 208
    .byte NT_NOTE_OFF, 1
    .word 208
    .byte NT_NOTE_ON, 0, 40, 8
    .word 208
    .byte NT_NOTE_ON, 1, 9, 12
    .word 210
    .byte NT_NOTE_OFF, 0
    .word 210
    .byte NT_NOTE_ON, 0, 21, 8
    .word 212
    .byte NT_NOTE_OFF, 0
    .word 212
    .byte NT_NOTE_ON, 0, 9, 8
    .word 214
    .byte NT_NOTE_OFF, 0
    .word 214
    .byte NT_NOTE_ON, 0, 21, 8
    .word 216
    .byte NT_NOTE_OFF, 0
    .word 216
    .byte NT_NOTE_OFF, 1
    .word 216
    .byte NT_NOTE_ON, 0, 36, 8
    .word 216
    .byte NT_NOTE_ON, 1, 9, 12
    .word 218
    .byte NT_NOTE_OFF, 0
    .word 218
    .byte NT_NOTE_ON, 0, 21, 8
    .word 220
    .byte NT_NOTE_OFF, 0
    .word 220
    .byte NT_NOTE_ON, 0, 9, 8
    .word 222
    .byte NT_NOTE_OFF, 0
    .word 222
    .byte NT_NOTE_ON, 0, 21, 8
    .word 223
    .byte NT_NOTE_OFF, 0
    .word 224
    .byte NT_NOTE_OFF, 1
    .word 224
    .byte NT_NOTE_ON, 0, 38, 8
    .word 224
    .byte NT_NOTE_ON, 1, 8, 12
    .word 226
    .byte NT_NOTE_OFF, 0
    .word 226
    .byte NT_NOTE_ON, 0, 20, 8
    .word 228
    .byte NT_NOTE_OFF, 0
    .word 228
    .byte NT_NOTE_ON, 0, 8, 8
    .word 230
    .byte NT_NOTE_OFF, 0
    .word 230
    .byte NT_NOTE_ON, 0, 20, 8
    .word 232
    .byte NT_NOTE_OFF, 0
    .word 232
    .byte NT_NOTE_OFF, 1
    .word 232
    .byte NT_NOTE_ON, 0, 35, 8
    .word 232
    .byte NT_NOTE_ON, 1, 8, 12
    .word 234
    .byte NT_NOTE_OFF, 0
    .word 234
    .byte NT_NOTE_ON, 0, 20, 8
    .word 236
    .byte NT_NOTE_OFF, 0
    .word 236
    .byte NT_NOTE_ON, 0, 8, 8
    .word 238
    .byte NT_NOTE_OFF, 0
    .word 238
    .byte NT_NOTE_ON, 0, 20, 8
    .word 239
    .byte NT_NOTE_OFF, 0
    .word 240
    .byte NT_NOTE_OFF, 1
    .word 240
    .byte NT_NOTE_ON, 0, 36, 8
    .word 240
    .byte NT_NOTE_ON, 1, 9, 12
    .word 242
    .byte NT_NOTE_OFF, 0
    .word 242
    .byte NT_NOTE_ON, 0, 21, 8
    .word 244
    .byte NT_NOTE_OFF, 0
    .word 244
    .byte NT_NOTE_OFF, 0
    .word 244
    .byte NT_NOTE_ON, 0, 40, 8
    .word 244
    .byte NT_NOTE_ON, 1, 9, 12
    .word 246
    .byte NT_NOTE_OFF, 0
    .word 246
    .byte NT_NOTE_ON, 0, 21, 8
    .word 248
    .byte NT_NOTE_OFF, 0
    .word 248
    .byte NT_NOTE_OFF, 1
    .word 248
    .byte NT_NOTE_ON, 0, 45, 8
    .word 248
    .byte NT_NOTE_ON, 1, 9, 12
    .word 250
    .byte NT_NOTE_OFF, 0
    .word 250
    .byte NT_NOTE_ON, 0, 21, 8
    .word 252
    .byte NT_NOTE_OFF, 0
    .word 252
    .byte NT_NOTE_ON, 0, 9, 8
    .word 254
    .byte NT_NOTE_OFF, 0
    .word 254
    .byte NT_NOTE_OFF, 1
    .word 254
    .byte NT_NOTE_ON, 0, 21, 8
    .word 255
    .byte NT_NOTE_OFF, 0
    .word 256
    .byte NT_NOTE_OFF, 1
    .word 256
    .byte NT_NOTE_ON, 0, 44, 8
    .word 256
    .byte NT_NOTE_ON, 1, 8, 12
    .word 258
    .byte NT_NOTE_OFF, 0
    .word 258
    .byte NT_NOTE_ON, 0, 20, 8
    .word 260
    .byte NT_NOTE_OFF, 0
    .word 260
    .byte NT_NOTE_ON, 0, 8, 8
    .word 262
    .byte NT_NOTE_OFF, 0
    .word 262
    .byte NT_NOTE_ON, 0, 20, 8
    .word 264
    .byte NT_NOTE_OFF, 0
    .word 264
    .byte NT_NOTE_ON, 0, 8, 8
    .word 266
    .byte NT_NOTE_OFF, 0
    .word 266
    .byte NT_NOTE_ON, 0, 20, 8
    .word 268
    .byte NT_NOTE_OFF, 0
    .word 268
    .byte NT_NOTE_ON, 0, 8, 8
    .word 270
    .byte NT_NOTE_OFF, 0
    .word 270
    .byte NT_NOTE_ON, 0, 20, 8
    .word 271
    .byte NT_NOTE_OFF, 0
    .word 272
    .byte NT_NOTE_OFF, 1
    .word 272
    .byte NT_LOOP
