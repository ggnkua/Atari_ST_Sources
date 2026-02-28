
cd offscreen





m68k-atari-mint-gcc offscreen.c get_eddi.S -O3 -Wall -W -Wunused -Wcast-qual -s -m68000 -DCPU_68K -o ../EXE_offscreen/offscreen68k.prg -lgem -lldg
m68k-atari-mint-gcc offscreen.c get_eddi.S -O3 -Wall -W -Wunused -Wcast-qual -s -m68000 -DCPU_68K -DLOG_FILE -o ../EXE_offscreen/offscreen68kdb.prg -lgem -lldg


m68k-atari-mint-gcc offscreen.c get_eddi.S -O3 -Wall -W -Wunused -Wcast-qual -s -m68030 -DCPU_030 -o ../EXE_offscreen/offscreen030.prg -lgem -lldg

m68k-atari-mint-gcc offscreen.c get_eddi.S -O3 -Wall -W -Wunused -Wcast-qual -s -m68040 -DCPU_040 -o ../EXE_offscreen/offscreen040.prg -lgem -lldg

m68k-atari-mint-gcc offscreen.c get_eddi.S -O3 -Wall -W -Wunused -Wcast-qual -s -m68060 -DCPU_060 -o ../EXE_offscreen/offscreen060.prg -lgem -lldg


m68k-atari-mint-gcc offscreen.c get_eddi.S -O3 -Wall -W -Wunused -Wcast-qual -s -mcfv4e -DCPU_CFV4E -o ../EXE_offscreen/offscreencfv4e.prg -lgem -lldg
m68k-atari-mint-gcc offscreen.c get_eddi.S -O3 -Wall -W -Wunused -Wcast-qual -s -mcfv4e -DCPU_CFV4E -DLOG_FILE -o ../EXE_offscreen/offscreencfv4e_db.prg -lgem -lldg

