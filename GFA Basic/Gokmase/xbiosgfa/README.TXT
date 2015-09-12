XBIOSGFA.LST                    2000-04-20
==========================================


This GFA-code will allow you to playback AVR-samples on any machine that
has XBIOS-sound compatibility. This sound call was introduced on the
Falcon but can also be added to STe and TT (and maybe other setups with
DMA-sound) by using a TSR-program called X-SOUND by the german author
Thomas Huth, aka Thothy.



SAMPLE FORMAT


The XBIOS-function can probably deal with other sample formats than 
AVR, but I have chosen to use AVR since it is a very common format on 
Atari and the only one I found the format definition for. 
This definition is also included in the LST-file.


WHAT DOES THIS CODE DO?


First procedure in LST will allocate memory and load the sample into 
that reserved area. Memory is reserved using MALLOC, but you might want 
to use mxmalloc if you want this to work with memory prot.

Second procedure will check the header of AVR-sample and decide stuff 
important to playback the sample correctly. (Freq/mono or stereo/8 or 
16 bits)

Third procedure contains the actual XBIOS calls and were originally 
written by Anthony Jacques in C so this is almost an exact GFA-translation
of his work. I have added one thing though, a check for any sample
currently being played.


WHY USE XBIOS?


XBIOS-sound seemed like a nice and simple way to add sound support for 
applications that would not keep the main program on hold while 
playing the sample in single-TOS. Thothys X-SOUND is even available in
non-DMA version, but that version is still quite buggy. Thothy has ceased
to develop the program but he has made the sources (in asm) available 
for anyone that would like to take it up.

It would be especially nice if the non-DMA version could be improved 
to be as stable as the DMA dito.


==========================================================================

Feel free to contact me if you have comments on my code or want to 
contribute with adding support for other sample files.

Joakim H”gberg
Bodgatan 22
S-931 53 Skellefte†
SWEDEN


http://hem.passagen.se/gokmase/atari

gokmase@bigfoot.com



 