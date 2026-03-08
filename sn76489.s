; vim: set ft=asm_ca65 ts=4 sw=4 et cc=80:
; 6502-Retro-Tetris Game
;
; Copyright (c) 2026 David Latham
;
; This code is licensed under the MIT license
;
; https://github.com/6502-retro/6502-retro-tetris


.include "io.inc"
.include "bios.inc"
.export sn_start, sn_stop, sn_silence, sn_play_note, sn_send, sn_noise

FIRST   = %10000000
SECOND  = %00000000
CHAN_1  = %00000000
CHAN_2  = %00100000
CHAN_3  = %01000000
CHAN_N  = %01100000
TONE    = %00000000
VOL     = %00010000
VOL_OFF = %00001111
VOL_MAX = %00000000


.zeropage

.code

sn_start:
    jsr sn_silence
    rts

sn_stop:
    jsr sn_silence
    rts

sn_silence:
    lda #(FIRST|CHAN_1|VOL|VOL_OFF)
    jsr sn_send
    lda #(FIRST|CHAN_2|VOL|VOL_OFF)
    jsr sn_send
    lda #(FIRST|CHAN_3|VOL|VOL_OFF)
    jsr sn_send
    lda #(FIRST|CHAN_N|VOL|VOL_OFF)
    jsr sn_send
    rts

sn_noise:
    lda #4
    ora #(FIRST|CHAN_N)
    jsr sn_send
    lda #(FIRST|CHAN_N|VOL|VOL_MAX)
    jsr sn_send
    rts

sn_play_note:
    lda #(FIRST|CHAN_1|TONE)
    jsr sn_send
    tya
    ora #(SECOND|CHAN_1|TONE)
    jsr sn_send
    lda #(FIRST|CHAN_1|VOL|$04)
    jsr sn_send
    rts

; Byte to send in A
sn_send:
    sta via_portb
    ldx #(SD_SCK|SD_CS|SD_MOSI|SN_WE)
    stx via_porta
    ldx #(SD_SCK|SD_CS|SD_MOSI)
    stx via_porta
    jsr sn_wait
    ldx #(SD_SCK|SD_CS|SD_MOSI|SN_WE)
    stx via_porta
    rts

sn_wait:
    lda via_porta
    and #SN_READY
    bne sn_wait
    rts

