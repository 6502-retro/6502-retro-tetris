; vim: set ft=asm_ca65 ts=4 sw=4 et cc=80:
; 6502-Retro-Tetris Game
;
; Copyright (c) 2026 David Latham
;
; This code is licensed under the MIT license
;
; https://github.com/6502-retro/6502-retro-tetris


.include "io.inc"
.include "app.inc"
.include "bios.inc"
.include "macro.inc"

.autoimport

.globalzp ptr1, ptr2

.zeropage
ptr1: .res 2
ptr2: .res 2

R0:   .res 1
R1:   .res 1
R2:   .res 1
R3:   .res 1
R4:   .res 1
R5:   .res 1
R6:   .res 1
R7:   .res 1
R8:   .res 1
R9:   .res 1
R10:  .res 1
R11:  .res 1

tmp1: .res 1
tmp2: .res 1

.bss

.align $100
collision_map: .res $300
regs: .res 12
framectr: .byte 0

.code
    ldx #$FF
    txs
    cld
    sei

    jmp start

crlf:
    lda #<str_crlf
    ldx #>str_crlf
    jmp bios_puts

start:
    jsr vdp_g1_init         ; Init the VDP and set up for graphics mode.  See
                            ; lib/vdp.s for detailed description of the mode used.

    lda #<font_start        ; load tile data (font and tiles)
    sta ptr1+0
    lda #>font_start
    sta ptr1+1
    lda #<font_end
    sta ptr2+0
    lda #>font_end
    sta ptr2+1
    jsr vdp_load_font_patterns

    lda #$31                ; set all tile colors to RED on LIGHT GREY
    jsr vdp_setup_colortable

    jsr init_music_tracker

    jsr clear_collision_map

    lda #<str_tetris
    sta ptr2+0
    lda #>str_tetris
    sta ptr2+1
    ldx #26
    ldy #23
    jsr vdp_print_xy
    jsr vdp_wait
    jsr vdp_flush

    jsr draw_map

    ; spawn one tet
    stz R0    ; rotation
    lda #1
    sta R1    ; tet id
    lda #10
    sta R2    ; tet -x
    lda #10
    sta R3    ; tet -y
    stz R4    ; save to collision map 0 = NO, != 0 = YES
    lda #'#'
    sta R5    ; tile pattern
    jsr draw_tet

    stz framectr

    cli                     ; ready to enable interrupts now.
    jsr vdp_wait
    jsr vdp_flush

; Game loop
game_loop:
    lda #' '
    sta R5
    jsr draw_tet
    lda #'#'
    sta R5
; Get input
    jsr bios_const
    cmp #'z'
    bne :+
    jmp @rotate_tet_ccw
:   cmp #'x'
    bne :+
    jmp @rotate_tet_cw
:   cmp #','
    bne :+
    jmp @move_tet_left
:   cmp #'.'
    bne :+
    jmp @move_tet_right
    ; =========================================================================
    ; All of this stuff is debugging stuff.vvvvvvvvvv 
    ; =========================================================================
:   cmp #'0'
    bne :+
    stz R1
    jmp @draw_tet
:   cmp #'1'
    bne :+
    lda #1
    sta R1
    stz R0
    jmp @draw_tet
:   cmp #'2'
    bne :+
    lda #2
    sta R1
    stz R0
    jmp @draw_tet
:   cmp #'3'
    bne :+
    lda #3
    sta R1
    stz R0
    jmp @draw_tet
:   cmp #'4'
    bne :+
    lda #4
    sta R1
    stz R0
    jmp @draw_tet
:   cmp #'5'
    bne :+
    lda #5
    sta R1
    stz R0
    jmp @draw_tet
:   cmp #'6'
    bne :+
    lda #6
    sta R1
    stz R0
    jmp @draw_tet
    ; =========================================================================
    ; All of this stuff is debugging stuff.^^^^^^^^^^ 
    ; =========================================================================
:   cmp #'q'
    beq :+
    jmp @draw_tet
:   jmp exit
@move_tet_left:
    jsr save_regs
    dec R2
    bra @draw_tet
@move_tet_right:
    jsr save_regs
    inc R2
    bra @draw_tet
@rotate_tet_cw:
    jsr save_regs
    lda #' '
    sta R5          ; erase
    jsr draw_tet
    lda R0          ; rotate
    inc 
    and #$03
    sta R0
    bra @draw_tet
@rotate_tet_ccw:
    jsr save_regs
    lda #' '
    sta R5          ; erase
    jsr draw_tet
    lda R0          ; rotate
    dec 
    and #$03
    sta R0
@draw_tet:
    jsr draw_tet
    bcc :+
    pha
    lda #<str_collision
    ldx #>str_collision
    jsr bios_puts
    pla
    jsr bios_prbyte ; print out the enum of the collision. See tetris.inc

    jsr restore_regs
    jsr draw_tet
:
    jsr vdp_wait
    jsr vdp_flush
    inc framectr
    lda framectr
    cmp #$7
    bne :+
    jsr handle_note
    stz framectr
:   jmp game_loop

; setup ptr1 with address of XY in collision map
xy_to_collision_map_ptr:
    stz ptr1                ; The low byte of the pointer will be zero due to
    lda #>collision_map     ; page alignment. Set ptr1+1 to high byte of
    sta ptr1+1              ; framebuffer address.

    tya                     ; Transfer Y to A for div8 macro
    div8                    ; divide A / 8 (lsr, lsr, lsr)
    clc                     ; prepare carry for add with carry.
    adc ptr1+1              ; Add to Y/8 to high byte of pointer
    sta ptr1+1
    tya                     ; Transfer Y to A for remainder of Y/8
    and  #$07               ; Find the remainder of Y/8
    mul32                   ; Multiply by 32 (asl, asl, asl, asl, asl) and save
    sta ptr1                ; to ptr1.
    ; add X to pointer
    clc                     ; Prepare carry for add with carry.
    txa                     ; Add X to the current value of ptr1 and then add
    adc ptr1                ; the value of the carry bit to ptr1+1 thus
    sta ptr1                ; the addition.
    lda #0
    adc ptr1+1
    sta ptr1+1
    rts

; given the new x and y position: we look at the
; collision map and test if each block in the new location is clear.
; return carry SET with collide condition status in A.  Or carry clear to indicate 
; no collision.
tile_test_collision:
    ; bounds checking
    txa
    cmp #PLAYFIELD_X_OFFSET
    bcc @left_collision_detected
    cmp #(PLAYFIELD_X_OFFSET + 10)
    bcs @right_collision_detected
    tya
    cmp #23
    bcs @floor_collision_detected

    jsr xy_to_collision_map_ptr
    ; read character at (ptr1)
    lda (ptr1)
    bne @collision_detected
    lda #0
    clc                     ; no collision detected
    rts
@floor_collision_detected:
    lda #FLOOR_COLLISION
    sec
    rts
@right_collision_detected:
    lda #RIGHT_COLLISION
    sec
    rts
@left_collision_detected:
    lda #LEFT_COLLISION
    sec
    rts
@collision_detected:
    lda #PIECE_COLLISION
    sec
    rts

; given the tet id in A and the rotation in R0, we calculate the rotation data
; offset and return it in Y
calculate_rotation_offset:
    lda R1
    mul32   ; tet id x 32
    sta tmp1; save to tmp
    lda R0  ; rotation
    mul8    ; offset by rot x 8
    clc     ; add to tmp
    adc tmp1
    tay     ; Y = tet_id * 32 + rotation * 8 - this is the offset into rotations
    rts

; given X in R2 and Y in R3, and rotation offset in Y, return new XY position
; in X and Y
calculate_xy_from_rotations:
    lda rotations,y
    clc
    adc R2  ; add to X
    tax
    iny     ; next value is Y offset
    lda rotations,y
    clc
    adc R3  ; add to Y
    tay
    rts

test_tet_colision:
    ; first test all positions of the tiles for collisions and out of bounds
    jsr calculate_rotation_offset
    ldx #4
@collision_loop:
    phx
    phy
    jsr calculate_xy_from_rotations
    jsr tile_test_collision
    bcc :+
    ply
    plx
    sec
    rts
:   ply
    iny
    iny
    plx
    dex
    bne @collision_loop
    clc
    rts

; NOTE: For wall kicks we need to know the previous rotation.  We figure out the transition
; Will use a lookup table for this?
;

; given the tet id, the rotation state and the x and y position: we plot the 
; 4 x,y offsets around the pivot point.
; INPUTS: A=tid, X=x of pivot, Y=y of pivot, R0 = rotation, R4 is draw to fb or map
; USES : R0-R4
draw_tet:
    jsr test_tet_colision
    bcc :+
    rts
:   ; if we get here it means we are safe to draw in new location.
    jsr calculate_rotation_offset
    ldx #4
@loop:
    phx     ; save block counter
    phy     ; save offset
    jsr calculate_xy_from_rotations
    lda R4
    bne :+
    lda R5  ; tet tile
    jsr vdp_char_xy
    bra :++
:   jsr plot_map_xy
:
    ply     ; restore offset
    iny     ; increment offset for next block
    iny     ;
    plx     ; restore block counter
    dex     ; decrement
    bne @loop ; loop if not finished.
    rts

; given a tet described by R0, R1, R2 and R3 we calculate the map offset and
; save the piece there.
plot_map_xy:
    jsr xy_to_collision_map_ptr
    lda #1
    sta (ptr1)
    rts

; Zero out the collision map.  We get some efficiency here because the map is
; page aligned.
clear_collision_map:
    lda #<collision_map
    sta ptr1+0
    lda #>collision_map
    sta ptr1+1
    ldx #3  ; we do 3 pages
    ldy #0
    lda #0
@L1:
    sta (ptr1),y
    iny
    bne @L1
    inc ptr1+1
    dex
    bne @L1
    rts

save_regs:
    pha
    phx
    ldx #11
@loop:
    lda R0,x
    sta regs,x
    dex
    bpl @loop
    plx
    pla
    rts

restore_regs:
    pha
    phx
    ldx #11
@loop:
    lda regs,x
    sta R0,x
    dex
    bpl @loop
    plx
    pla
    rts

; draws the map offset by PLAYFIELD_X_OFFSET starting at Y=0
draw_map:
    lda #<map
    sta ptr1+0
    lda #>map
    sta ptr1+1

    clc
    lda #<vdp_screenbuf
    adc #(PLAYFIELD_X_OFFSET-1)
    sta ptr2+0
    lda #>vdp_screenbuf
    sta ptr2+1

    ldy #0
@loop:
    lda (ptr1),y
    cmp #$80
    beq @next_line
    cmp #$FF
    beq @done
    sta (ptr2),y
    iny
    bra @loop
@next_line:
    clc
    lda ptr2+0 ; add 22 on to screen pointer
    adc #32
    sta ptr2+0
    lda ptr2+1
    adc #0
    sta ptr2+1

    clc
    lda ptr1+0
    adc #13
    sta ptr1+0
    lda ptr1+1
    adc #0
    sta ptr1+1
    ldy #0    ; reset y to 0
    bra @loop
@done:
    rts



exit:
    jsr sn_silence
    jmp bios_wboot

.rodata
; strings
str_space_to_start: .asciiz "UART: SPACE to start"
str_tetris:         .asciiz "Tetris"
str_by_pd:          .asciiz "By Productiondave"
str_cc2026:         .asciiz "2026"
str_collision:      .byte    10,13,"COLLISION DETECTED: ",0
str_crlf:           .byte    10,13,0

font_start:
    .include "font.s"
font_end:
    .include "tetris.inc"

