.segment "RODATA"


music:
    .word @instruments
    .word @samples
; 00 : test song
    .word @songch0
    .word @songch1
    .word @songch2
    .word @songch3
    .word @songch4
    .word @songch5
    .word @songch6
    .word @songch7
    .word @songch8
    .word @songch9
    .word @songchA
    .word @songchB
    .word @songchC
    .word @songchD
    .word @songchE
    .word @songchS
    ; TEMPO
    ; in the famistudio driver, there were two numbers here:
    ; PAL and NTSC. since the cx16 is NTSC only, that means
    ; only one word! :yippee:
    ; here's how you calculate this number:
    ; floor(256 * virtualTempo / (60*60/24))
    .word 256

; .export music
; .global whateverthefuck

@instruments:
    ; instrument 0
    .word @Venv0, @Aenv0, @Denv0, @Penv0, @Wenv0, @LRenv0, $0000, $0000

    ; ENVELOPE FORMAT
    ; volume, arpeggio, duty, pitch, waveform, panning, UNUSED, UNUSED
@Venv0:
    .byte $01,$bc,$b8,$b3,$b0,$ae,$ad, $00,$06
@Aenv0:
    .byte $01,$80,$00,$01
@Denv0:
    .byte $01,$bf,$00,$01
@Penv0:
    .byte $01,$c0,$00,$01
@Wenv0:
    .byte $01,$80,$00,$01
@LRenv0:
    .byte $01,$83,$00,$01

@samples:
    .byte $00, $80  ; first sample i guess. i'll make this more elaborate


@songch0:
    .byte $46, $0b  ; set speed to 5
    @songch0loop:
    @songch0pat00:
        .byte $80       ; set instrument to 0

        .byte $31, $38, $31, $38, $31, $38, $31, $38
        .byte $2c, $33, $2c, $33, $2c, $33, $2c, $33
        .byte $2e, $35, $2e, $35, $2e, $35, $2e, $35
        .byte $2a, $31, $2a, $31, $2a, $31, $2a, $31

        .byte $42
        .word @songch0loop
@songch1:
    @songch1loop:
    @songch1pat00:
        .byte $80

        .byte $0d, $c6
        .byte $08, $c6
        .byte $0a, $c6
        .byte $06, $c6

        .byte $42
        .word @songch1loop



@songchS:
@songchE:
@songchD:
@songchC:
@songchB:
@songchA:
@songch9:
@songch8:
@songch7:
@songch6:
@songch5:
@songch4:
@songch3:
@songch2:
@songch2loop:
    .byte $c1
    .byte $42   ; loop
    .word @songch2loop