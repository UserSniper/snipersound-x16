__CX16__ = 1
.include "cx16.inc"
.include "cbm_kernal.inc"

FETCH = $ff74


.segment "JUMPTABLE"

jmp ss_init

jmp ss_init

jmp ss_song_tick
jmp ss_song_play


.segment "BUFFER"
    ss_v_psg_buffer:  .res (16*4)

.segment "BSS"
    ss_v_song_bank:         .res 1
    
    ;; pointers to stuff
    ss_v_instruments_ptr:   .res 2
    ss_v_samples_ptr:       .res 2

    ss_v_pattern_ptr_lo:    .res 16
    ss_v_pattern_ptr_hi:    .res 16

    ;; speed n whatnot
    ss_v_speed:             .res 1
    ss_v_tempo:             .res 2

    ss_v_do_tick: .res 1
    ss_v_tempo_accumulator: .res 2

    ;; channel-specific stuff
    ss_v_current_channel:   .res 1
    ss_v_ch_ticks_to_wait:  .res 16

    ss_scratch:             .res 1
    ss_v_ch_ref_note_count: .res 16
    ss_v_ch_ref_ptr_lo:     .res 16
    ss_v_ch_ref_ptr_hi:     .res 16

    ; envelopes
    ss_v_ch_instrument:     .res 16
    ss_v_ch_vol_env_pos:    .res 16


.segment "CODE"


;
; INITIALIZE THE SOUND DRIVER
; args: A: bank where the song is located
;
.proc ss_init
    sta ss_v_song_bank

    ;; ok so first we need to clear the psg buffer
    ; set address
    lda #<ss_v_psg_buffer 
    ldx #>ss_v_psg_buffer 
    sta gREG::r0L
    stx gREG::r0H
    ; set byte count
    lda #64
    sta gREG::r1L
    stz gREG::r1H
    ; what to fill with
    lda #0
    ; fill memory
    jmp MEMORY_FILL
.endproc


;
;
;
.proc ss_song_tick
    inc ss_scratch
    stz ss_v_current_channel

    @LOOP_POINT:

        ; check channel count
        ldx ss_v_current_channel
        cpx #$02
        bne :+
            jmp @EXIT_LOOP_POINT
        :

        ; check if it's time to update
        bit ss_v_do_tick
        bmi :+
            jmp @END_OF_TICK
        :
        
        ; check if we're waiting ticks
        ldx ss_v_current_channel
        lda ss_v_ch_ticks_to_wait, x
        beq :+
            dec ss_v_ch_ticks_to_wait, x
            jmp @END_OF_TICK
        :

        ldy ss_v_current_channel
        lda ss_v_pattern_ptr_lo, y
        ldx ss_v_pattern_ptr_hi, y
        sta gREG::r15L
        stx gREG::r15H

        ldy #0
        jsr ss_fetch

        ; hey yo, the opcode is now in A
        sta gREG::r12L
        bit gREG::r12L

        ; if bit 7 is set, it's either an instrument
        ; or an amount of rows to wait. 
        bmi @bit7

        ; if bit 6 is set, it's a song opcode.
        bvs @is_opcode

        ; neither are set? it's a note.
        @is_note:
            ; BUT WE'RE NOT DONE YET!
            ; if the byte grabbed is zero, we need to stop the note.
            beq @stop_note

            tay ; grab the pitch of the note
            lda ss_d_psg_tuning_table_lo-1, y
            ldx ss_d_psg_tuning_table_hi-1, y

            ; do some register fuckery to get the
            ; channel index and multiply it by 4
            pha
            lda ss_v_current_channel
            asl
            asl
            tay
            pla

            sta ss_v_psg_buffer + 0, y;
            txa ; why is there not a stx abs, y AAAAAA
            sta ss_v_psg_buffer + 1, y;

            ldx ss_v_current_channel
            inc ss_v_pattern_ptr_lo, x
            bne :+
                inc ss_v_pattern_ptr_hi, x
            :

            ; before end of tick, check if reference point is enabled
            jsr ss_41_check_reference_point
            jmp @END_OF_TICK

            @stop_note:
                lda ss_v_current_channel
                asl
                asl
                tax
                stz ss_v_psg_buffer + 0, x;
                stz ss_v_psg_buffer + 1, x;

                ldx ss_v_current_channel
                inc ss_v_pattern_ptr_lo, x
                bne :+
                    inc ss_v_pattern_ptr_hi, x
                :
                jsr ss_41_check_reference_point
                jmp @END_OF_TICK

                
        @bit7:
            ; from here, if bit 6 is set, it's rows to wait.
            ; otherwise, it's an instrument number.
            ldx ss_v_current_channel
            bvs @is_wait

            @is_instrument:
                inc ss_v_pattern_ptr_lo, x
                bne :+
                    inc ss_v_pattern_ptr_hi, x
                :
                jmp @LOOP_POINT

            @is_wait:
                and #%00111111
                sta ss_v_ch_ticks_to_wait,x

                inc ss_v_pattern_ptr_lo, x
                bne :+
                    inc ss_v_pattern_ptr_hi, x
                :
                jsr ss_41_check_reference_point
                inc ss_v_current_channel
                jmp @LOOP_POINT

        @is_opcode:
            ;cmp #$46
            ;bne @h + 2
            and #%00111111
            tay 
            lda ss_d_channel_opcode_table_lo, y
            ldx ss_d_channel_opcode_table_hi, y
            sta @h + 1
            stx @h + 2
            ; SELF MODIFYING CODE, BAYBEE
        @h: jsr $ffff

            jmp @LOOP_POINT



    @END_OF_TICK:
        ;jsr tick_envelope
        inc ss_v_current_channel
        jmp @LOOP_POINT



    @EXIT_LOOP_POINT:
    ;; END OF LOOP POINT
    stz ss_v_do_tick

    ; add tempo accumulator
    lda ss_v_tempo_accumulator + 0
    clc
    adc ss_v_tempo + 0
    sta ss_v_tempo_accumulator + 0

    lda ss_v_tempo_accumulator + 1
    adc ss_v_tempo + 1

    cmp ss_v_speed
    bcc :+  ; if hi byte of tempo accumulator is greater than speed,
        dec ss_v_do_tick
        sec ; subtract speed value from it
        sbc ss_v_speed
    :
    sta ss_v_tempo_accumulator + 1

    jmp ss_copy_buffer_to_vera
.endproc




ss_40_extended_note:
    ldy #1
    jsr ss_fetch

    tay ; grab the pitch of the note
    lda ss_d_psg_tuning_table_lo_ext-1, y
    ldx ss_d_psg_tuning_table_hi_ext-1, y

    ; do some register fuckery to get the
    ; channel index and multiply it by 4
    pha
    lda ss_v_current_channel
    asl
    asl
    tay
    pla

    sta ss_v_psg_buffer + 0, y;
    txa ; why is there not a stx abs, y AAAAAA
    sta ss_v_psg_buffer + 1, y;
    
    ldx ss_v_current_channel
    lda ss_v_pattern_ptr_lo, x
    clc
    adc #2
    sta ss_v_pattern_ptr_lo, x
    bne :+
        inc ss_v_pattern_ptr_hi, x
    :
    jsr ss_41_check_reference_point
    inc ss_v_current_channel
    rts


ss_41_set_reference_point:
    ldy #1
    jsr ss_fetch

    eor #%10000000
    ldx ss_v_current_channel
    sta ss_v_ch_ref_note_count, x

    lda ss_v_pattern_ptr_lo, x
    clc
    adc #4
    sta ss_v_ch_ref_ptr_lo, x
    bne :+
        inc ss_v_pattern_ptr_hi, x
    :
    lda ss_v_pattern_ptr_hi, x
    sta ss_v_ch_ref_ptr_hi, x

    ldy #3
    jsr ss_fetch
    pha
    ldy #2
    jsr ss_fetch

    ldy ss_v_current_channel
    sta ss_v_pattern_ptr_lo, y
    sta gREG::r15L
    pla
    sta ss_v_pattern_ptr_hi, y
    sta gREG::r15H

    rts

ss_41_check_reference_point:
    bit ss_v_ch_ref_ptr_hi, x
    bpl :+ ; if disabled, skip
        dec ss_v_ch_ref_note_count, x
        bmi :+ ; if bit 7 reset, return to reference point
            lda ss_v_ch_ref_ptr_lo, x
            sta ss_v_pattern_ptr_lo, x
            sta gREG::r15L
            lda ss_v_ch_ref_ptr_hi, x
            sta ss_v_pattern_ptr_hi, x
            sta gREG::r15H

            stz ss_v_ch_ref_ptr_hi, x
            stz ss_v_ch_ref_note_count, x
        :
    :
    rts

ss_42_loop:
    ;low byte
    ldy #1
    jsr ss_fetch

    ldx ss_v_current_channel
    sta ss_v_pattern_ptr_lo, x


    ;high byte
    ldy #2
    jsr ss_fetch

    ldx ss_v_current_channel
    sta ss_v_pattern_ptr_hi, x

    rts


ss_46_speed:
    ldy #1  ; +1 = speed value that follows the opcode
    jsr ss_fetch

    ; new speed is at da ready
    sta ss_v_speed

    ldx ss_v_current_channel
    lda ss_v_pattern_ptr_lo, x
    clc
    adc #2
    sta ss_v_pattern_ptr_lo, x
    bne :+
        inc ss_v_pattern_ptr_hi, x
    :
    rts


ss_d_channel_opcode_table_lo:
    .byte <ss_40_extended_note 
    .byte <ss_41_set_reference_point 
    .byte <ss_42_loop 
    .byte <0
    .byte <0
    .byte <0
    .byte <ss_46_speed 
ss_d_channel_opcode_table_hi:
    .byte >ss_40_extended_note 
    .byte >ss_41_set_reference_point 
    .byte >ss_42_loop 
    .byte >0
    .byte >0
    .byte >0
    .byte >ss_46_speed 







.proc ss_song_play
    ;; set up the zeropage register we need to fetch bytes
    ldx #$a0
    stz gREG::r15L
    stx gREG::r15H
    
    ;; fetch the instrument/sample pointers
    ldy #0
    :
        jsr ss_fetch

        ; the byte fetched is now in A
        sta ss_v_instruments_ptr, y

        iny
        cpy #4
        bne :-

    lda gREG::r15L
    clc
    adc #4
    sta gREG::r15L
    bcc :+
        inc gREG::r15H
    :

    ;; alright so channel pointers are a bit weird
    ;; since they're split into lo/hi pairs, this needs to
    ;; be done with two indirect pointers.
    ;; r13/r14 will be our victims
    lda #<ss_v_pattern_ptr_lo
    ldx #>ss_v_pattern_ptr_lo
    sta gREG::r13L
    stx gREG::r13H

    lda #<ss_v_pattern_ptr_hi
    ldx #>ss_v_pattern_ptr_hi
    sta gREG::r14L
    stx gREG::r14H

    ;; fetch the channel pointers
    ldy #0
    @ch_loop:
        ; low byte
        jsr ss_fetch

        sta (gREG::r13)
        

        iny
        ; high byte
        jsr ss_fetch

        sta (gREG::r14)
        

        inc gREG::r13L
        bne :+
            inc gREG::r13H
        :  
        inc gREG::r14L
        bne :+
            inc gREG::r14H
        :  

        iny
        cpy # 16*2
        bne @ch_loop

    ;; get tempo
    ; low byte
    jsr ss_fetch
    sta ss_v_tempo + 0

    iny
    ; high byte
    jsr ss_fetch
    sta ss_v_tempo + 1


    rts
.endproc



;
; internal routines (DO NOT CALL OUTSIDE OF THE DRIVER)
;
.proc ss_fetch
    ldx ss_v_song_bank
    lda #<gREG::r15
    jmp FETCH
.endproc

.proc ss_copy_buffer_to_vera
    ; preserve vram address
    lda VERA::CTRL 
    pha
    lda VERA::ADDR + 0
    pha
    lda VERA::ADDR + 1
    pha
    lda VERA::ADDR + 2
    pha

    ; set new vram address
    stz VERA::CTRL ; first address
    lda #$c0
    ldx #$f9
    ldy #%00010001
    sta VERA::ADDR + 0
    stx VERA::ADDR + 1
    sty VERA::ADDR + 2

    ; set source address
    lda #<ss_v_psg_buffer 
    ldx #>ss_v_psg_buffer 
    sta gREG::r0L
    stx gREG::r0H

    ; set destination address
    lda #<VERA::DATA0 
    ldx #>VERA::DATA0 
    sta gREG::r1L
    stx gREG::r1H

    ; set byte count
    lda #$40
    ;ldx #0
    sta gREG::r2L
    stz gREG::r2H

    jsr MEMORY_COPY

    ; restore vram address
    pla
    sta VERA::ADDR + 2
    pla
    sta VERA::ADDR + 1
    pla
    sta VERA::ADDR + 0
    pla
    sta VERA::CTRL 
    rts
.endproc

;
; the tuning table!
; split for extra speed!
;
ss_d_psg_tuning_table_lo_ext:
    ;       C   C#  D   D#  E   F   F#  G   G#  A   A#  B
    .byte  $58,$5d,$63,$68,$6f,$75,$7c,$84,$8b,$94,$9c,$a6  ;1  ;0c
ss_d_psg_tuning_table_lo:
    .byte  $b0,$ba,$c5,$d1,$dd,$ea,$f8,$07,$17,$27,$39,$4b  ;2  ;18
    .byte  $5f,$74,$8a,$a2,$ba,$d5,$f1,$0e,$2d,$4f,$72,$97  ;3  ;24
    .byte  $be,$e8,$14,$43,$75,$a9,$e1,$1c,$5b,$9d,$e3,$2e  ;4  ;30
    .byte  $7d,$d0,$29,$86,$ea,$53,$c2,$39,$b6,$3a,$c7,$5c  ;5  ;3c
    .byte  $f9,$a0,$51      ; the split point; you can only
    ; access up to here with a 1-byte note. use the extended
    ; note opcode to use the rest of the table
    .byte              $0d,$d3,$a6,$85,$71,$6b,$71,$8d,$b7  ;6  ;48
    .byte  $f2,$40,$a2,$19,$a7,$4c,$0a,$e2,$d7,$e9,$1b,$6e  ;7  ;54

ss_d_psg_tuning_table_hi_ext:
    ;       C   C#  D   D#  E   F   F#  G   G#  A   A#  B
    .byte  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  ;1  ;0c
ss_d_psg_tuning_table_hi:
    .byte  $00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01  ;2  ;18
    .byte  $01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02  ;3  ;24
    .byte  $02,$02,$03,$03,$03,$03,$03,$04,$04,$04,$04,$05  ;4  ;30
    .byte  $05,$05,$06,$06,$06,$07,$07,$08,$08,$09,$09,$0a  ;5  ;3c
    .byte  $0a,$0b,$0c      ; the split point; you can only
    ; access up to here with a 1-byte note. use the extended
    ; note opcode to use the rest of the table
    .byte              $0d,$0d,$0e,$0f,$10,$11,$12,$13,$14  ;6  ;48
    .byte  $15,$17,$18,$1a,$1b,$1d,$1f,$20,$22,$24,$27,$29  ;7  ;54