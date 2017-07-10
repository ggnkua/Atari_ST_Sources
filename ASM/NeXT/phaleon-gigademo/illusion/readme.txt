----------------------------------------------------------------
Please ! Do not spread this package without this README file
----------------------------------------------------------------

Hello dudes !
Due to some request, I finaly releases the source code of the STE screen of the
Phaleon Gigademo...
This screen can be found on the 4th disk of the demo, under the name "Illusion".
Do not make any mistake ! This not the "Illusion demo" released long time after !

This screen features:
- Soundtrack music (12.5khz stereo, bad quality, using STE DMA sound)
- FullScreen in all parts (except in transitions)
- Savage blittering (color blitting, masking...)
- Savage screen woblers, using STE capabilities.

It's suppose to work on MegaSTE (with 8mhz clock, cache OFF), but some MegaSTE don't like
that code !

-------------------------------------
For the sources, now:
-------------------------------------
- All the comments are in French. I'm sorry, but I was not thinking they will be wide
spreaded one day.
- It can be recompiled only with GenST, since I'm a stupid guy that put some accents in
labels... And even without that, it seems that TurboAss cannot manage too much calculations,
and since I use plenty of things like
	dcb.w 4096-(33+58*2)*4+23,$4e71....
that cannot be changed while releasing the demo !
- You must select CASE UNSENSITIVE since some labels are sometimes in upper case and sometimes
in lower case.
- Theses sources are not supposed to be the cleanest or fastest demo-sources even found on
Atari. But I think you can find valuables informations on Blitter utilisations, fullscreen
programming, exception handling (I make fullscreen temporisations with TRAPS instructions since
it uses little room in code for a LONG execution time !)
- The mod player uses a weird format created my MIT, so don't blame me if it is hard to use.
Anyway, you can download the original "ILLUSION.MOD" on my page.

What can I say about this screen ?

It takes me a very long time to develop the main routine.
All the effects are done using only ONE routine (and some derivatives ones), that is full of
weird things like 
JSR "(^$)" 
DC.B "Dbug"
DC.B "neXT"
that are patched with the required instruction depending on wich part it is running.
The physical size of the screen memory vary from standard fullscreen (approx: 384*270) to
a single line (384*1) or sometimes a scrolling slice of screen (3000*32)...
All of that is made by tricking the video chip, the blitter...
It's hard to code from scratch, but I think it will be easier now !

When we were coding the Phaleon, I planned to add a BIG FULLSCREEN ROTATING 3D CUBE, but due to
time, I could not do it.
The idea was that in a 3D cube, you can see a maximum 4 different colors on a single scan line.
(background-side 1-side 2-side 3-bacground again), and so it was possible to precompute some 
single video lines that will be selected dynamically while drawing screen...
But no time for doing it !
If someone is ok to try ?


-------------------------------------
Concerning the AUTO folder:
-------------------------------------
The auto folder contains a reset-resistent-withCRC-ramdisk.
It contains an ANTI-VIRUS, and a key combination (like ALT+[num]*) that reset the screen.
I do not exactly remember how it works... It's a custom version I create from an original
ramdisk that I find somewhere. If I remember well there is also a boot checking so I can
insert a Phaleon disk or Charts disk without having the boot sector destroyed by the anti-virus.
One of the version was doing RamDisk transfert with Blitter, and was absolutely FAST !

The RamBoot.PRG file reads the RAMBOOT.LST file, and put all the files in the RamDisk.
So, the idea is that you boot on the disk, it creates the ramdisk, the ST resets.
At the second boot, the Ramdisk is resident and validated, so RamBoot is executed, and loads
all the files in the ramdisk if they are not presents.

So, you can after that launch GenST, load the ILLUS_xxx.S on the disk (A:), and compil all the
rest from the ramdisk.
If you crashed the ST, just press reset !
If the ramdisk has not been altered, the ST will boot in few seconds with all files still in the
ramdisk.
Cool no ?
With that system, on my 4 meg STE I was able to assemble my sources about 2.5 times faster that a
friend on his harddrive ! (Except the first boot that is really long !)
-------------------------------------


About the coderight:
- I do not claim any coderight on these source-codes, but if you use something, or if you learn 
something, please send me an e-mail, and/or some credits in your productions.
- I you do not understand something, you can mail me questions at the folling adress:
- If you crash your computer because of theses sources, it's all your responsability !
- If a file is missing, or corrupted, contact me.
- If you cannot reassemble the files, same thing.
- If you are interested by other code-sources, just ask. If I still have the sources, I will
put them public. But don't ask me to check if everything works fine !

- And please ! Do not spread this package without this README files


If you have Oric hardware/software, I'm interested !
If you like the Phaleon Demo, or the Charts, please let me know it !


Mike/Dbug II from NeXT

mpointie@hol.fr				(please, no Spaming !)
http://wwwperso.hol.fr/~mpointie	(plenty of stuff for Oric/Atari :)

Productions on Atari ST:
- Charts (including Official 1991 Charts Compilation)
- Phaleon Demo

On Falcon:
- Rembrandt 3 (last beta version is 3.06)

On Oric:
- Oric MegaDemo

On PC:
- TimeCommando (Adeline Software)

On PlayStation:
- TimeCommando
- Little Big Adventure (Adeline Software)

