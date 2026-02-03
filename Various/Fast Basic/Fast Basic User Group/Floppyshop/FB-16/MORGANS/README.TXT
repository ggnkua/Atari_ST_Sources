                                             24/10/88

Dear Simon,
     Thanks for an interesting magazine. I sincerely hope it 
develops into a free-flowing information exchange environment. 

     To answer(?) queries 3 and 4 from your #5 Issue help page; 
Capslock can be set/reset by placing 16 in D0 for ON, and 0 in D0 
for off, using the following assembler code:-

caps_on_off
        MOVE.W  D0,-(SP)
        MOVE.W  #11,-(SP)
        TRAP    #13
        ADDQ.L  #4,SP
        RTS
... although I can't see much use for it except formatting 
output.

     As for making accessories, although I haven't tried it yet, 
I have, at last(!) just come across the necessary info in the 
Abacus book,"ST Disk Drives: Inside and Out" on p182 dealing with 
RamDisc installation - I will write again if I am successful!! 

     What a great pity that Computer Concepts was lured away to 
the Archimedes before they wrote a compiler for Fast Basic - 
subsequently, I have moved over to HiSoft's excellent 
environment, albeit back to rotten old Microsoft dialect! There 
ain't no justice or much in the way of ethics, these days.

Comments on the enclosed folders....

1) CAPS Folder:-
     The programmes are a 'quick and dirty' way to show that the 
capslock key is/is not operative. Two versions are given because 
the prog makes a direct access to system variables space - which 
inevitably changes between ROM versions. CAPSLOCK.PRG works with 
all pre-blitter ROM's, whereas CAPSLCK2.PRG is for Vers 1.02/DOS 
19. 

     Not a good example of assembler programming, by any means, 
as the symbol, shown in the top left-hand corner of the screen, 
is also activated by the other special keys!!

     I started out trying to use BIOS kbshift, but found that a 
TSR prog installed on the VBL queue doesn't seem to like BIOS 
calls, in general. Same applies to trying to auto-boot VBL progs, 
as I haven't had any luck there; perhaps it would work using a 
system timer, but I haven't had the time or inclination to try.

     Computer Concepts and GST (in Wordplus), obviously have a 
far more elegant solution to this one!

2)FB_FILES Folder:-
     A bunch of oddities from a year or so ago. MFPREGS might 
help anybody learning about the 68901 chip. BLIZZARD is just for 
a couple of minutes amusement - it was written during a 
Mediterranean heatwave! PHIDAISY shows some correlation between 
Mathematics and Nature. LINELIGHT is a routine from a Database I 
was writing. UCASE is my response to Mr.G.Buzzacott's Callcaps 
procedure in the #5 Issue of your Magazine. Although his proc 
appears very clever, it cannot handle strings passed down with 
embedded punctuation characters.

3)FB_ASTRO Folder:-
     I cherished dreams of a genuine animated portrayal of the 
Jovian satellite system...
     Well, it seemed a good idea at the time, but HOW do they do 
the equivalent so smoothly in MEGAROIDS????????? Any help or 
suggestions on this one would make my year!!

     I look forward to Issue #6 of your/our mag, but don't expect 
any personal feedback to this lot...

               Cheers,

                    Neil A.Morgan.

P.S. Does anyone have any comments to make on KSWITCH2 and/or 
SUPERBASE, if so I would like to be put in touch with them, 
please.

