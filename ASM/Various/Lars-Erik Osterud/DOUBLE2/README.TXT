Double Screen-Heigh emulator for STE, MEGA STE (and TT ??)  VERSION 2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""  """""""""
WHY A NEW VERSION ?  Well, the old version allocated 64000 bytes for
the new screen in low memory.  But the old screen still took up the
32000 bytes in high memory and that was a big waste (especially for
those with 520 and 1040 machines).  Instead of allocating 64000 new
bytes for the new screen version 2 expands the old screen by 32000
bytes (moving the top of memory down) and then saves 32000 bytes !!!
Version 2 takes up totally 32522 bytes including the resident code
and should be the smallest big-screen emulator available for the STE.

Why does this program only work om STE and not on standard ST ????
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Both the display modes uses new hardware registers on the STE to
make the code small.  The interlace emulation could not be made
on the ST without moving the whole screen all the time and taking up
all the CPU-time.  On the STE it takes a few instrutions each VBL.

Read this before you install DOUBLE2.PRG in your AUTO-folder
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
To install DOUBLE2.PRG just put it in your auto-folder as early as
possible (and be sure it's before Quick-ST etc).  If you have any
programs that allocates reset-resident memory by moving the screen
(like Harlekins RESETMEM) you MUST put DOUBLE2.PRG after those !!!
If you use Harlekin you MUST use RESETMEM.PRG first in AUTO-folder.
When the computer boots DOUBLE2.PRG will NOT install itself unless
you are holding down one of the SHIFT keys.  If installed in mono it
will emulate a 640 x 800 screen (double height) and if installed in
color (desktop.inf must be medium res) a 640 x 400 screen.  

RIGHT-SHIFT while booting --> Up/Down scrolling emulator
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
When you move the mouse close to the top or bottom of the visible
screen area the screen will scroll down or up to display more of the
screen.  Think of your monitor screen as a window showing a part of
the whole area.  In this mode text-based program (TOS etc) will still
use only the upper half of the screen (the normal area) as this worked
best with the programs I tested.  Most GEM based programs will use the
whole screen (I made it for use with Calamus DTP and Timeworks DTP).

LEFT-SHIFT while booting --> Interlaced screen display
""""""""""""""""""""""""""""""""""""""""""""""""""""""
This will double the number of lines WITHOUT having to scroll the
screen by condensing the screen display.  This mode will flicker some
(users of color monitors or TV should use 60 Hz) but you might get a
better result by adjusting the contrast (yes, it looks like an Amiga).
In this mode both TOS and GEM-programs will use the whole screen area.

Please Support my ShareWare and Public Domain developement
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Send 150 NKr (equals $20, DM35, 15 pounds, 40 guilders) by cheque or to
norwegian postgiro account 0537 6846174 (see your local post office for 
a transfer card, "Service des cheques postaux, Avis de versement VP1").
Payable to:  Lars-Erik 0sterud, Blinken 37 c, N-1349 Rykkinn, Norway.

If you have any problem, ideas, bug-reports, wishes etc contact me !!
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Lars-Erik ²sterud	Phone:		+47 21 91 91 65
Badebakken 4		Mobile:		+47 906 98 710
N-0467 Oslo		E-mail:		larse@chello.no
Norway			Homepage:	http://home.chello.no/~larse/
