Sokoban
=======

This is a GEM version of the classic puzzle game.  

When started, the program displays a list of levels.  Double click on the 
level row to open that level.  Move your character (a circle with a cross) 
using the cursor keys, to guide the boxes onto the goals.  The game has 
unlimited undo: press 'u' or 'Undo' to move back one step.  Press 'r' to 
reset the level.  A count is kept of your moves and pushes, and your best 
scores are maintained on the level list.  The display size can be adjusted 
through the 'Scale' menu.  Press 'Help' to view a summary of the key controls.

New levels can be loaded from a text file using the 'Game/Open Levels' menu.
See the file TUTORIAL.TXT for a description of the level format (which is 
used by many level authors), and some examples, in case you want to try 
writing your own levels.  The game contains the original 50 levels of 
Thinking Rabbit built in: these levels can be retrieved using the 
'Game/Classic Levels' menu.

High scores are automatically maintained in a text file on disk.  Selecting 
'Game/Show statistics' opens a list showing how much of each set of levels 
you have completed.

The implementation is pure GEM and should run on all Atari machines, TOS 1.04
and higher.  If your display has less than 16 colours, Sokoban will switch 
to a monochrome output.  The program has been tested on a Firebee running 
MINT+XaAES, an STe running TOS 2.06 and, through Hatari, emulated Atari ST 
and Falcon machines running EmuTOS.

Installation
------------

Simply copy SOKOBAN.RSC and one of:

- SOKOBAN.PRG for the Firebee (a Coldfire build)
- SOKO_ST.PRG for the ST/STe (a 68000 build)
- SOKO_FAL.PRG for the Falcon (a 68000 build with TOS 4 features enabled)

to a convenient location, and run the PRG.

If updating an older version, retain the file "scores.txt" 
to preserve your previous scores.

Source/Issues
-------------

Source code is available: https://github.com/petercrlane/sokoban

Any problems/requests, please raise as github issues.

The code can be compiled with the AHCC C compiler using the provided .PRJ files. 

License
-------

This implementation of Sokoban is copyright (c) 2016, Peter Lane.

This is version 0.9.4 of the [Open Works License](http://owl.apotheon.org/)

Permission is hereby granted by the holder(s) of copyright or other legal
privileges, author(s) or assembler(s), and contributor(s) of this work, to any
person who obtains a copy of this work in any form, to reproduce, modify,
distribute, publish, sell, sublicense, use, and/or otherwise deal in the
licensed material without restriction, provided the following conditions are
met:

Redistributions, modified or unmodified, in whole or in part, must retain
applicable copyright and other legal privilege notices, the above license
notice, these conditions, and the following disclaimer.

NO WARRANTY OF ANY KIND IS IMPLIED BY, OR SHOULD BE INFERRED FROM, THIS LICENSE
OR THE ACT OF DISTRIBUTION UNDER THE TERMS OF THIS LICENSE, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS, ASSEMBLERS, OR HOLDERS OF
COPYRIGHT OR OTHER LEGAL PRIVILEGE BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER
LIABILITY, WHETHER IN ACTION OF CONTRACT, TORT, OR OTHERWISE ARISING FROM, OUT
OF, OR IN CONNECTION WITH THE WORK OR THE USE OF OR OTHER DEALINGS IN THE WORK.


