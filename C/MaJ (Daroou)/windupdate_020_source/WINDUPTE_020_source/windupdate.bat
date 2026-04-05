
cd windupdate

m68k-atari-mint-gcc WindUpdate.c get_eddi.S -O2 -Wall -W -Wunused -Wcast-qual -m68000 -o WindUpdate68k.prg -lgem -lldg
m68k-atari-mint-strip WindUpdate68k.prg

m68k-atari-mint-gcc WindUpdate.c get_eddi.S -O2 -Wall -W -Wunused -Wcast-qual  -m68040 -o WindUpdate040.prg -lgem -lldg
m68k-atari-mint-strip WindUpdate040.prg

m68k-atari-mint-gcc WindUpdate.c get_eddi.S -O2 -Wall -W -Wunused -Wcast-qual  -m68060 -o WindUpdate060.prg -lgem -lldg
m68k-atari-mint-strip WindUpdate060.prg

m68k-atari-mint-gcc WindUpdate.c get_eddi.S -O2 -Wall -W -Wunused -Wcast-qual  -mcfv4e -o WindUpdatecfv4e.prg -lgem -lldg
m68k-atari-mint-strip WindUpdatecfv4e.prg
