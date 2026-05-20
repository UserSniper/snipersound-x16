default: make

ARGS = --cpu 65C02

make:
	rm -f BRUH.PRG
	rm -f *.SSS
	
	ca65 $(ARGS) snipersound.s -o snipersound.o
	ld65 snipersound.o -C link_engine.cfg -o SNIPERSOUND.BIN

	ca65 $(ARGS) song.s -o song.o
	ld65 song.o -C link_song.cfg -o SONG.SSS

	cl65 -t cx16 prg.s -o BRUH.PRG

	rm *.o