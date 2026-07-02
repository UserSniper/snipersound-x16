.include "cx16.inc"
.include "cbm_kernal.inc"

SS_psg_buffer = $bfc0

SS_TESTFUNC = $a000
SS_INIT = $a003
SS_SONG_TICK = $a006
SS_SONG_PLAY = $a009



.org $080D
.segment "ONCE"
    
start:

    stz $00
    inc $00 ; ram bank to 1


    lda #2
    jsr SS_INIT
    ;jsr SS_SONG_TICK
    jsr SS_SONG_PLAY

    ;lda #$00
    ;sta $bfc0
    ;lda #$01
    ;sta $bfc1
    lda # $3b | %11000000
    sta $bfc2
    sta $bfc2+4
    ;sta $bfc2+8
    ;sta $bfc2+$c

    lda # $1f
    sta $bfc3
    sta $bfc3+4


    lda #$32
    ldx #0
    @el_loop:
        wai
        ;lda $bfc0, x
        ;clc
        ;adc #$7
        ;sta $bfc0, x
        ;inx
        ;cpx #$40
        ;bcc :+
        ;    pha
        ;    txa
        ;    sec
        ;    sbc #$40
        ;    tax
        ;    pla
        ;:
        ;phx

        stz VERA::CTRL

        inc VERA::DISP::FRAME
        jsr SS_SONG_TICK
        stz VERA::DISP::FRAME
        
        bra @el_loop
    rts