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

tmp1: .res 1

.bss

regs:             .res 12
musicframectr:    .res 1
tetframectr:      .res 1
speed:            .res 1
speed_idx:        .res 1
seed:             .res 2
level:            .res 1
next_tet_regs:    .res 5
bag:              .res 1
line_ctr:         .res 1
lines:            .res 3
level_line_ctr:   .res 1     ; every 10 lines cleared rhe speed increases to a max of 20.
level_can_update: .res 1     ; start out as zero, set to 1 when level increases to 20
score:            .res 2

sprite_attributes:
sprite_wipe_y:    .res 1
sprite_wipe_x:    .res 1
sprite_wipe_p:    .res 1
sprite_wipe_c:    .res 1
sprite_attr_term: .res 1

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

wait_for_exit:
    lda #'>'
    jsr bios_conout
    jsr bios_conin
    jmp exit

dump_regs:
    jsr crlf
    ldx #0
:
    lda R0,x
    jsr bios_prbyte
    inx
    cpx #12
    bne :-
    rts

; AX points to 8 byte block pattern
; Y is the value in the name table for this block.  EG: $20 would be SPACE on a
; regular font.
set_block_pattern:
    pha                      ; save A and X so we can set the vdp write address
    phx

    lda #<PATTERNTABLE       ; vdp write address + (Y * 8)
    sta ptr1+0
    lda #>PATTERNTABLE
    sta ptr1+1

    tya
    clc
; multiply A by 8 into a 16 bit memory ptr2
    sta ptr2+0               ; save A into ptr2
    stz ptr2+1               ; zero ptr2+1
; x2
    asl ptr2+0               ; shift left low byte
    rol ptr2+1               ; rotate carry into high byte
; x4
    asl ptr2+0               ; shift left low byte 
    rol ptr2+1               ; rotate carry into high byte
; x8
    asl ptr2+0               ; shift left low byte
    rol ptr2+1               ; rotate carry into high byte

    clc
    lda ptr1+0               ; add ptr2 to ptr1
    adc ptr2+0
    sta ptr1+0
    lda ptr1+1
    adc ptr2+1
    tax
    lda ptr1+0               ; AX points to vdp memory address for start of block.
    jsr vdp_set_write_address

    plx                      ; restore A and X and use them to point to start of
    pla                      ; pattern data
    sta ptr1+0
    stx ptr1+1
    ldy #0                   ; count out 8 bytes
:   lda (ptr1),y             ; read byte
    sta vdp_ram              ; write to VRAM
    iny
    cpy #8                   ; have we written 8 bytes?
    bne :-                   ; no - loop
    rts

start:
    jsr vdp_g1_init          ; Init the VDP and set up for graphics mode.  See
; lib/vdp.s for detailed description of the mode used.

    lda #<font_start         ; load tile data (font and tiles)
    sta ptr1+0
    lda #>font_start
    sta ptr1+1
    lda #<font_end
    sta ptr2+0
    lda #>font_end
    sta ptr2+1
    jsr vdp_load_font_patterns

    lda #<sprite_patterns
    sta ptr1+0
    lda #>sprite_patterns
    sta ptr1+1
    lda #<sprite_patterns_end
    sta ptr2+0
    lda #>sprite_patterns_end
    sta ptr2+1
    jsr vdp_load_sprite_patterns

    lda #<colortable
    ldx #>colortable
    jsr vdp_load_colortable

    lda #<I_block
    ldx #>I_block
    ldy #$80
    jsr set_block_pattern

    lda #<T_block
    ldx #>T_block
    ldy #$88
    jsr set_block_pattern

    lda #<Z_block
    ldx #>Z_block
    ldy #$90
    jsr set_block_pattern

    lda #<S_block
    ldx #>S_block
    ldy #$98
    jsr set_block_pattern

    lda #<L_block
    ldx #>L_block
    ldy #$A0
    jsr set_block_pattern

    lda #<J_block
    ldx #>J_block
    ldy #$A8
    jsr set_block_pattern

    lda #<O_block
    ldx #>O_block
    ldy #$B0
    jsr set_block_pattern

    clc
    lda #<PATTERNTABLE        ; set pattern table to position of $b8 in name table
    adc #$c0                  ; 0xb8 * 8 = 0x5c0
    tay
    lda #>PATTERNTABLE
    adc #$5
    tax
    tya
    jsr vdp_set_write_address

    ldy #0
    lda #<bdr_vert_line
    sta ptr1+0
    lda #>bdr_vert_line
    sta ptr1+1
:   lda (ptr1),y
    sta vdp_ram
    iny                       ; copy 88 bytes into vram
    cpy #88
    bne :-

    ; set up sprite attributes
    lda #192
    sta sprite_wipe_y
    lda #1
    sta sprite_wipe_x
    lda #4
    sta sprite_wipe_p
    lda #$0F
    sta sprite_wipe_c
    lda #$D0
    sta sprite_attr_term

    jsr init_music_tracker
    jsr draw_map
    jsr vdp_wait
    jsr vdp_flush

;jmp menu fall through

; display the game start screen
; This is also where we keep incrementing the seed every frame to generate some
; kind of randomization to the game.
menu:
    stz seed
    stz seed+1
    stz level_can_update
    stz line_ctr
    stz level_line_ctr
    stz speed_idx

    stz lines+0
    stz lines+1
    stz lines+2

    stz musicframectr
    stz tetframectr

    ldx speed_idx
    lda speeds,x
    sta speed

    cli                      ; ready to enable interrupts now.
    jsr vdp_wait
    jsr vdp_flush

@menu_wait:
    inc seed
    bne :+
    inc seed+1
:   jsr bios_const
    cmp #' '
    bne :+
    bra @menu_play
:   cmp #$1B
    bne @menu_wait
    jmp exit
@menu_play:
    jsr clear_playfield

    stz score+0
    stz score+1
    stz score+2
    jsr print_score

    stz bag

    lda #1
    sta level
    ldx #PLAYFIELD_X_OFFSET+16
    ldy #16
    jsr byte_to_hex

    lda seed+0
    ldx seed+1
    jsr _srand

    jsr spawn_tet
    jsr spawn_tet            ; spawn two to make sure we don't get duplicates up front.

    jsr vdp_wait
    jsr vdp_flush

    jmp game_loop

clear_playfield:
    lda #' '
    ldy #0
@loop1:
    ldx #PLAYFIELD_X_OFFSET
@loop2:
    jsr vdp_char_xy
    inx
    cpx #PLAYFIELD_X_OFFSET + 10
    bne @loop2
    iny
    cpy #22
    bne @loop1
    rts

; copy next_tet regs to R0-R4.
; erase next tet from display
; create new next_tet and draw it.
spawn_tet:
    lda next_tet_regs + 4    ; save next tet block pattern
    pha
    lda #' '                 ; erase next tet
    sta next_tet_regs + 4    ; restore next tet block pattern
    jsr draw_next_tet
    pla
    sta next_tet_regs + 4

    ldx #4                   ; copy next tet to current tet.
:   lda next_tet_regs,x
    sta R0,x
    dex
    bpl :-

; make new next tet
    stz next_tet_regs + 0    ; rotation
    jsr bag_of_7             ; get next tet
    sta next_tet_regs + 1    ; tet id
    lda #(PLAYFIELD_X_OFFSET + 5)
    sta next_tet_regs + 2    ; tet -x
    lda #1
    sta next_tet_regs + 3    ; tet -y
    ldx next_tet_regs + 1 
    lda tet_blocks,x
    sta next_tet_regs + 4    ; tile pattern

    jsr draw_next_tet
    jsr vdp_wait
    jsr vdp_flush
    rts

bag_of_7:
    lda bag
    cmp #$7F
    bne @try_again
    stz bag                  ; bag was full, so empty it.
@try_again:
    jsr _rand
    and #$07
    cmp #7
    bcs @try_again           ; keep searching for a number between 0 and 6 inclusive

; we have a number between 0 and 6 (inclusive)
    sta R6                   ; save to temp var
    tax                      ; rotate carry left by number of times given by rand
    inx
    lda #0
    sec
:   rol
    dex
    bne :-
    sta R7                   ; save this in case we want to OR it with bag
    and bag                  ; test if the bit is already set in bag.
    bne @try_again           ; bit is set so try again.  we know there is room.
; bit is not set so set it.
    lda R7
    ora bag                  ; set new bit in 
    sta bag
    lda R6                   ; restore number from temp
    rts

; Game loop
game_loop:
    stz R5                   ; moving down flag false.  used in collision detection
    jsr save_regs            ; we only want to lock a piece if we were moving down.
    lda #' '
    sta R4
    jsr draw_tet             ; first we draw the tet as being empty (spaces)
    ldx R1
    lda tet_blocks,x
    sta R4
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
:   cmp #' '
    bne :+
    jmp @hard_drop_tet
:   cmp #$1B
    beq :+
    jmp @draw_tet
:   jmp exit
@move_tet_left:
    dec R2
    bra @draw_tet
@move_tet_right:
    inc R2
    bra @draw_tet
@rotate_tet_cw:
    lda R0                   ; rotate
    inc 
    and #$03
    sta R0
    bra @draw_tet
@rotate_tet_ccw:
    lda R0                   ; rotate
    dec 
    and #$03
    sta R0
    bra @draw_tet
;jmp @draw_tet           ; fall through
@hard_drop_tet:
    jmp hard_drop_tet
@draw_tet:
; check if it's time to move the piece down one line.
    lda tetframectr
    cmp speed
    bne @draw
    stz tetframectr
    inc R3
    inc R5                   ; moving down flag TRUE

@draw:

    jsr draw_tet
    bcc @flush
    cmp #PIECE_COLLISION
    beq @is_top_row
    cmp #FLOOR_COLLISION
    bne @restore             ; not floor collision, restore old position and draw
    bra @lock_piece
@is_top_row:
    lda R3
    dec                      ; we had already moved it so need to test where we were
    cmp #1
    bne @lock_piece
    lda #<str_game_over
    sta ptr2+0
    lda #>str_game_over
    sta ptr2+1
    ldx #PLAYFIELD_X_OFFSET + 1
    ldy #0
    jsr vdp_print_xy
    jmp menu
@lock_piece:
    lda R5
    beq @restore             ; were we moving down? YES then lock piece
    jsr restore_regs
    jsr draw_tet             ; draw in previous place
    jsr vdp_wait
    jsr vdp_flush
    jmp check_line_clear
@restore:
    jsr restore_regs
@flush:
    jsr vdp_wait
    jsr vdp_flush

    inc tetframectr

    inc musicframectr
    lda musicframectr
    cmp #$7
    bne :+
    jsr handle_note
    stz musicframectr
:   jmp game_loop


hard_drop_tet:
    lda #' '
    sta R4
    jsr draw_tet
    inc R3
    ldx R1
    lda tet_blocks,x
    sta R4
    jsr draw_tet
    bcc hard_drop_tet
    dec R3
    jsr draw_tet
    jmp check_line_clear
; jmp game_loop

; given a row in Y, check if each position along it's X axis is empty
; returns with Carry Set if row is full otherwise clear
check_line:
    ldx #PLAYFIELD_X_OFFSET
:   phx
    phy
    jsr vdp_read_char_xy
    cmp #' '
    beq @row_not_full
    ply
    plx
    inx
    cpx #PLAYFIELD_X_OFFSET+10
    bne :-
; row is full
    jsr wipe_line
    sec
    rts
@row_not_full:
    ply
    plx
    clc
    rts

; Y has the line to clear
wipe_line:
    ldx #PLAYFIELD_X_OFFSET
@loop:
    phy
    phx
    dey
    tya
    asl
    asl
    asl
    sta sprite_wipe_y
    txa
    asl
    asl
    asl
    sta sprite_wipe_x
    lda #<sprite_wipe_y
    sta ptr1+0
    lda #>sprite_wipe_y
    sta ptr1+1
    jsr vdp_wait
    jsr vdp_flush_sprite_attributes
    jsr vdp_flush

    plx
    ply
    lda #' '
    jsr vdp_char_xy
    inx
    cpx #PLAYFIELD_X_OFFSET+10
    bne @loop
    rts


; drop lines down to current line given by Y
drop_lines:
    sty R6                   ; save it in temp var
@line_loop:
    ldx #PLAYFIELD_X_OFFSET
@column_loop:
    dey
    jsr vdp_read_char_xy
    iny
    jsr vdp_char_xy
    inx
    cpx #PLAYFIELD_X_OFFSET+10
    bne @column_loop
    dey
    cpy #1
    bne @line_loop

    ldx #PLAYFIELD_X_OFFSET
    lda #' '
@clear_top_row_loop
    jsr vdp_char_xy
    inx
    cpx #PLAYFIELD_X_OFFSET+10
    bne @clear_top_row_loop
    ldy R6                   ; restore Y
    lda #192
    sta sprite_wipe_y
    jsr vdp_flush_sprite_attributes
    rts

check_line_clear:
; zero line counter
; loop through the rows starting at the bottom.
;   check the playfield for a tile at each horizontal position along the line
;     if empty, then next line
;   if all not empty, then:
;     increment line counter
;     add empty row at top of playfield
;     move all rows in playfield down by one row. (overwriting cleared line)
;   if line counter = 3 (max 4 lines from 0 - 3) then end loop.
;
; update score according to total number of lines cleared.
; finally spawn new tet
    stz line_ctr
@again:
    ldy #21
@next_line:
    jsr check_line
    bcs @row_full
    dey
    cpy #2
    bne @next_line
@break:
    sei
    sed
    clc

    lda line_ctr
    adc lines+0
    sta lines+0
    lda lines+1
    adc #0
    sta lines+1
    lda lines+2
    adc #0
    sta lines+2
    cld
    cli
    jsr print_lines
    jsr update_score
    jsr spawn_tet
    jmp game_loop
@row_full:
    jsr drop_lines           ; y contains line to drop to

    lda level_can_update
    bne :+

    inc level_line_ctr
    lda level_line_ctr
    cmp #10
    bne :+

    jsr increment_level
    stz level_line_ctr

:   inc line_ctr             ; we collect the lines that have been cleared.
    lda line_ctr
    cmp #4                   ; 4 is the maximum number of lines we can clear with
    beq @break               ; one piece.
    bra @again               ; if we cleared a row and dropped the lines, we need
; to start checking from th bottom again.

increment_level:
    sei
    sed
    clc
    lda level
    adc #1
    sta level

    cmp #20
    bne :+
    inc level_can_update
:   cld
    cli

    lda level
    ldx #PLAYFIELD_X_OFFSET+17
    ldy #16
    jsr byte_to_hex

    inc speed_idx
    ldx speed_idx
    lda speeds,x
    sta speed
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
    cmp #22
    bcs @floor_collision_detected

    jsr vdp_read_char_xy
    cmp #' '
    bne @collision_detected
    lda #0
    clc                      ; no collision detected
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

; given the tet id in A and the rotation in next_tet_regs + 0, we calculate the rotation data
; offset and return it in Y
calculate_rotation_offset_next_tet:
    lda next_tet_regs + 1
    mul32                    ; tet id x 32
    sta tmp1                 ; save to tmp
    lda next_tet_regs + 0    ; rotation
    mul8                     ; offset by rot x 8
    clc                      ; add to tmp
    adc tmp1
    tay                      ; Y = tet_id * 32 + rotation * 8 - this is the offset into rotations
    rts

; given the tet id in A and the rotation in R0, we calculate the rotation data
; offset and return it in Y
calculate_rotation_offset:
    lda R1
    mul32                    ; tet id x 32
    sta tmp1                 ; save to tmp
    lda R0                   ; rotation
    mul8                     ; offset by rot x 8
    clc                      ; add to tmp
    adc tmp1
    tay                      ; Y = tet_id * 32 + rotation * 8 - this is the offset into rotations
    rts

; given X in next_tet_regs+2 and Y in next_tet_regs+3, and rotation offset in
; Y, return new XY position in X and Y
calculate_xy_from_rotations_next_tet:
    lda rotations,y
    clc
    adc #20                  ; x
    tax
    iny                      ; next value is Y offset
    lda rotations,y
    clc
    adc #4                   ; y
    tay
    rts


; given X in R2 and Y in R3, and rotation offset in Y, return new XY position
; in X and Y
calculate_xy_from_rotations:
    lda rotations,y
    clc
    adc R2                   ; add to X
    tax
    iny                      ; next value is Y offset
    lda rotations,y
    clc
    adc R3                   ; add to Y
    tay
    rts

test_tet_collision:
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

; given tet details in next_tet_regs, draw it.
draw_next_tet:
    jsr calculate_rotation_offset_next_tet
    ldx #4
@loop:
    phx
    phy
    jsr calculate_xy_from_rotations_next_tet
    lda next_tet_regs+4
    jsr vdp_char_xy
    ply
    iny
    iny
    plx
    dex
    bne @loop
    clc
    rts


; given the tet id, the rotation state and the x and y position: we plot the 
; 4 x,y offsets around the pivot point.
; INPUTS: A=tid, X=x of pivot, Y=y of pivot, R0 = rotation,
; USES : R0-R4
draw_tet:
    lda R4
    cmp #' '                 ; do not test for collision if erasing tet
    beq :+
    jsr test_tet_collision
    bcc :+
    rts
:                            ; if we get here it means we are safe to draw in new location.
    jsr calculate_rotation_offset
    ldx #4
@loop:
    phx                      ; save block counter
    phy                      ; save offset
    jsr calculate_xy_from_rotations
    lda R4                   ; tet tile
    jsr vdp_char_xy
    ply                      ; restore offset
    iny                      ; increment offset for next block
    iny
    plx                      ; restore block counter
    dex                      ; decrement
    bne @loop                ; loop if not finished.
    clc
    rts

save_regs:
    pha
    phx
    ldx #7
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
    ldx #7
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
    lda ptr2+0
    adc #32
    sta ptr2+0
    lda ptr2+1
    adc #0
    sta ptr2+1

    clc
    lda ptr1+0
    adc #24
    sta ptr1+0
    lda ptr1+1
    adc #0
    sta ptr1+1
    ldy #0                   ; reset y to 0
    bra @loop
@done:
    rts

; scoring system from: https://harddrop.com/wiki/Scoring#Guideline_scoring_system
; Note that this game does not have the Super Rotation System so the additional scores
; for those moves are excluded here.
; Single    100 x level
; Double    300 x level
; Triple    500 x level
; Tetris    800 x level
; We use a lookup table to calculate the level multiplier.
; lookup table is values stored in BCD format.
update_score:
; we will use ptr2 to hold the mid and high values of the BCD encoded score.
    ldx level
    lda line_ctr
    cmp #1
    bne :+
    lda single_mid,x
    sta ptr2+0
    lda single_high,x
    sta ptr2+1
    bra @add_to_score
:   cmp #2
    bne :+
    lda double_mid,x
    sta ptr2+0
    lda double_high,x
    sta ptr2+1
    bra @add_to_score
:   cmp #3
    bne :+
    lda triple_mid,x
    sta ptr2+0
    lda triple_high,x
    sta ptr2+1
    bra @add_to_score
:   cmp #4
    bne :+
    lda tetris_mid,x
    sta ptr2+0
    lda tetris_high,x
    sta ptr2+1
    bra @add_to_score
:   rts
@add_to_score:
    sei                      ; disable interrupts during cld maths
    sed                      ; set BCD flag
    clc
    lda score+0
    adc ptr2+0
    sta score+0
    lda score+1
    adc ptr2+1
    sta score+1
    cld                      ; clear BCD flag
    cli
; fall through to print
print_score:
    lda #0
    ldx #PLAYFIELD_X_OFFSET+17
    ldy #11
    jsr byte_to_hex

    lda score+0
    beq :+
    ldx #PLAYFIELD_X_OFFSET+15
    ldy #11
    jsr byte_to_hex
:   lda score+1
    beq :+
    ldx #PLAYFIELD_X_OFFSET+13
    ldy #11
    jmp byte_to_hex
:   rts

print_lines:
    lda lines+0
    ldx #PLAYFIELD_X_OFFSET+17
    ldy #21
    jsr byte_to_hex
    lda lines+1
    bne :+
    ldx #PLAYFIELD_X_OFFSET+15
    ldy #21
    jsr byte_to_hex
:   lda lines+2
    bne :+
    ldx #PLAYFIELD_X_OFFSET+13
    ldy #21
    jsr byte_to_hex
:   rts

byte_to_hex:
    pha                      ; Save A for LSD.
    lsr
    lsr
    lsr                      ; MSD to LSD position.
    lsr
    jsr prhex                ; Output hex digit.
    inx 
    pla                      ; Restore A.
prhex:
    and #$0F                 ; Mask LSD for hex print.
    ora #$B0                 ; Add "0".
echo:
    and #$7F                 ; *Change to "standard ASCII"
    jsr vdp_char_xy
    rts

exit:
    jsr sn_silence
    jmp bios_wboot

.rodata
str_game_over:      .byte "GAMEOVER",0
str_crlf:           .byte    10,13,0
speeds:             .byte 53,49,45,41,37,33,28,22,17,11,10,9,8,7,6,6,5,5,4,4,3

font_start:
    .include "font.s"
font_end:
    .include "tetris.inc"

