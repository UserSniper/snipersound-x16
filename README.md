# SniperSound-X16
SniperSound is an optimizing sound driver for the Commander X16 8-bit computer.


# How to Use
1. Load the driver (`SNIPERSOUND.BIN`) into any High RAM bank at $a000.
2. Load any SniperSound-compatible song (file extension will be `.SSS`) into any High RAM bank, also at $a000.
3. Run `JSR $a003` in the bank where the driver is located, with the song bank in the A register.
4. Run `JSR $a009` to start playback of the song!

From there, all you have to do is run `JSR $a006` to tick the driver once per frame. 
