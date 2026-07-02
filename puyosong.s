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
    .byte $46, $07  ; set speed to 5
    .byte $80
    @songch0loop:
    @songch0pat00:
        ;.byte $80       ; set instrument to 0
        .byte $40,$0a,$c0, $40,$0a,$c0, $40,$0c,$c0, $40,$0c,$c0
        .byte $01,$c0,     $01,$c0,     $02,$c0,     $02,$c0
        .byte $03,$c0,     $03,$c0,     $07,$c0,     $07,$c0
        .byte $03,$c0,     $03,$c0,     $05,$c0,     $05,$c0

    ;pat01
        .byte $41, $1f
        .word @songch0loop
    ;pat02
        .byte $41, $1f
        .word @songch0loop
    ;pat03
        .byte $41, $1f
        .word @songch0loop
    ;pat04
        .byte $41, $1f
        .word @songch0loop
    ;pat05
        .byte $41, $1f
        .word @songch0loop
    ;pat06
        .byte $41, $1f
        .word @songch0loop
    ;pat07
        .byte $41, $1f
        .word @songch0loop
    ;pat08
        .byte $41, $1f
        .word @songch0loop
    ;pat09
        .byte $41, $1f
        .word @songch0loop
    ;pat0a
        .byte $41, $1f
        .word @songch0loop
    ;pat0b
        .byte $41, $1f
        .word @songch0loop
    ;pat0c
        .byte $41, $1f
        .word @songch0loop
    ;pat0d
        .byte $41, $1f
        .word @songch0loop

    @songch0pat0e:
        .byte $03,$c0,     $03,$c0,     $05,$c0,     $05,$c0
        .byte $07,$c0,     $07,$c0,     $09,$c0,     $09,$c0
        .byte $05,$c0,     $05,$c0,     $07,$c0,     $07,$c0
        .byte $09,$c0,     $09,$c0,     $0c,$c0,     $0c,$c0

    ;pat0f
        .byte $41, $1f
        .word @songch0pat0e
    ;pat10
        .byte $41, $1f
        .word @songch0pat0e

    @songch0pat11:
        .byte $80
        .byte $07,$c0,     $07,$c0,     $07,$c0,     $07,$c0
        .byte $07,$c0,     $07,$c0,     $07,$c0,     $07,$c0
        @songch0pat11xref0:
        .byte $03,$c0,     $03,$c0,     $03,$c0,     $03,$c0
        .byte $05,$c0,     $05,$c0,     $05,$c0,     $05,$c0
        
        .byte $41, $17
        .word @songch0pat11
        .byte $41, $07
        .word @songch0pat11xref0

        .byte $42
        .word @songch0loop

@songch1:
    @songch1loop:
    @songch1pat00:
        .byte $80

        .byte $1a,$c0,     $1a,$c0,     $1a,$c0,     $1a,$c0
        .byte $1a,$c0,     $1a,$c0,     $1a,$c0,     $1a,$c0
        .byte $1b,$c0,     $1b,$c0,     $1b,$c0,     $1b,$c0
        .byte $1b,$c0,     $1b,$c0,     $1b,$c0,     $1b,$c0
    
    ;pat01
        .byte $41, $1f
        .word @songch1pat00
    ;pat02
        .byte $41, $1f
        .word @songch1pat00
    ;pat03
        .byte $41, $1f
        .word @songch1pat00
    ;pat04
        .byte $41, $1f
        .word @songch1pat00
    ;pat05
        .byte $41, $1f
        .word @songch1pat00
    ;pat06
        .byte $41, $1f
        .word @songch1pat00
    ;pat07
        .byte $41, $1f
        .word @songch1pat00
    ;pat08
        .byte $41, $1f
        .word @songch1pat00
    ;pat09
        .byte $41, $1f
        .word @songch1pat00
    ;pat0a
        .byte $41, $1f
        .word @songch1pat00
    ;pat0b
        .byte $41, $1f
        .word @songch1pat00
    ;pat0c
        .byte $41, $1f
        .word @songch1pat00
    ;pat0d
        .byte $41, $11
        .word @songch1pat00

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
    .byte $c0
    .byte $42   ; loop
    .word @songch2loop