; vim: set ft=asm_ca65 ts=4 sw=4 et:vdp
.macro div8
    .repeat 3
        lsr
    .endrepeat
.endmacro

.macro mul2
    asl
.endmacro

.macro mul4
    .repeat 2
        asl
    .endrepeat
.endmacro

.macro mul8
    .repeat 3
        asl
    .endrepeat
.endmacro

.macro mul32
    .repeat 5
        asl
    .endrepeat
.endmacro

