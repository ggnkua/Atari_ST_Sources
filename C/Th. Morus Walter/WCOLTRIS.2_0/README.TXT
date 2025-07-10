WinColTris  V2.0  27.12.1994

yet another COLUMNS and TETRIS version

written by Th. Morus Walter
(c) 1994 by Never Ready Software, Morus Walter

This program is FREEWARE!

Th. Morus Walter
Schulstr. 22
93080 Pentling
FEDERAL REPUBLIC of germany

 - - - - -

First of all, I want to apologize for my bad english and all the mistakes
i made

 - - - - -

WinColTris V2.0 is a new version of ColTris V1.0.
Since there was already a tetris-program called ColTris, I decided to
use a new name for my ColTris. The Win stands for window (not Windows,
and not MS-Windows at all). However I will sometimes use the old name
COLTRIS in this document.

When writing V1.0, I thought windows would be to much work and not very
neccessory. This has changed in V2.0.
The other new feature in V2.0 is the support of color-resolution. This
is not quite as fast as monochrom, since WinColTris uses the VDI in
color-resolutions, but I think it is fast enauge. (You should NVDI
or something else to speed up things).

Preface to V1.0 (partially)
---------------------------
yet another COLUMNS and TETRIS version - why?

There are a lot of columns and tetris versions, so why another one?
Until now, I used PCM van der Arends COLUMNS and STETRIS. I liked these
versions but they don't run with MagiX (especially not if you use
AutoswitchOverscan).
So I needed an alternative and couldn't find one I liked (although
there were a lot of programs).
Therefore I wrote my own program (using PCM van der Arends programs as
a model) and here it is.

Compared to PCM van der Arends programs there are some missing features,
on the other hand there are some advantages.

 - - - - -

COLTRIS should run on every ST/TT/Falcon.

COLTRIS works under MagiX (I guess also MultiTOS but I couldn't check);
in the 'multi'-Mode of COLTRIS you can play without blocking the screen.

 - - - - -

I guess everyone knows columns and tetris, so I won't explain the games.

 - - - - -

COLTRIS V2.0 runs - other than V1.0 did - only as a program, since it uses
a pulldown menu. You can't use it as a accessory.

WinColTris uses up to four windows, for the game itself, the scoring, the
preview and a statistic.

After starting the program the main window, more windows if active and the
menu is displayed.

WinColTris provides the following menu items:

menu 'WinColTris' entry 'about WinColTris':
you guess it...

menu 'File':
  entry 'Play'
	Hmm, what might this mean.
	If you reach a new hiscore, you will be ask to enter your name at
	the end...
  entry 'Hiscore'
    show the hiscore-table of the active game
	If the last result was a new hiscore, it's entry will be marked
	by '*'
  entry 'Save'
	Save hiscore AND options
	The hiscore is not save automatic.
	Together with the options, the window postions are save. This is
	done separate for up to 8 screen resolutions.
  entry 'Quit'
	lets go...

menu: 'Options':
  entry 'Tetris'
    set playmode to tetris
  entry 'Columns'
    set playmode to columns
   if the playmode is changed, the main window is adjusted and the other
   windows are shown according to the settings for the game, this means
   you can toggle the preview on for tetris and off for columns...
  entry 'Score'
   toggle the score-window
  entry 'Preview'
   toggle the preview
  entry 'Statistic'
   toggle the statistic
  entry 'Options'
    set options
	These are partially separate for columns and tetris, so you get
	the tetris options if 'tetris' is selected and the columns options
	if 'columns' is selected (together with the common options).
	First you can select the start level for the game. Second you can
	select some random preset for the game.
	The rest of the options is common.
	There are two graphics modes in COLTRIS. If the screen is comparable
	to ST-high-res (just the organisation of the bitmap, this does not
	mean that you have to have 640x400 pixels) you might use 'ST'. The blocks
	are then copied to the screen directly. LineA variables are used
	to get the screen width and Logbase() to get the screen adress in this mode
	(COLTRIS does NOT use LineA besides this).
	Otherwise use 'VDI'. The blocks are then copied to the screen by the VDI.
	The VDI is slower than my assembler routines, but there should be no
	flickering since there is a buffer.
	In color resolutions VDI is used automaticly.
	Next you can select the playmode: in the mode 'single' WinColTris takes
	control over screen and mouse, so window-operations etc. are impossible,
	other programs (under multitasking) can't do any output (this causes
	a minor problem if you toggle the windows during game (see below).
	If you switch of a window and the background is another window
	this window can't be redrawn. So the window seems to stays on the screen.
	If the background is the desktop the screenmanager does redraw (don't
	understand that), so the problem is relevant under multitasking only...).
	In the other mode ('multi') WinColTris simply tops it's windows.
	Mouse- and screen-control isn't taken, so other programs can do
	output, windows can be moved... This mode is slower, since the window
	has been checked every output. The WinColTris' menu items can be
	used partialy, however shortcuts aren't possible. The AV/VA send-key
	message, which is used to send unrecognized keys to the AV/VA-server
	(if there is one, e.g. gemini or ease, in multitasking), is not used.
	PLEASE NOTE: even if the names of the modes sound like, you don't have
	to use 'single' under single-tos and 'multi' under multitasking.
	Both modi are possible unter both OS...
	Next you can select the AV/VA mode, which is interesting in multitasking
	if you have an good desktop like gemini or ease. You can set, which
	windows WinColTris should tell the desktop, so that they participate
	in the window cycling (via Ctrl-W).
	The last button is to set, wether all windows or the main window only
	should be raised when starting a game.
	With the last option you can choose the user-defined keys. You can
	define (additional) keys for the basic functions (stone left, stone
	right, rotate stone and drop stone).

 - - - - -

Shortcuts:
besides the shortcuts shown in the menu you have the following possibilities:

all commands apart from 'ctrl S' and 'ctrl Q' can be used without ctrl.
'return' and 'enter' start the game.

 - - - - -

While playing several keys are predefined:

7#     stone left
9#     stone right
8#     rotate stone
4#     drop stone
space  drop stone
q      quit game
esc    quit game
s      stop game (continue with any key)
l      increase level
*#     increase level
n      toggle preview (next)
b      toggle statistics
i 	   toggle score

The hash (#) indicates keys on the num-pad (COLTRIS uses scancodes, however
there shouldn't be problems with non-german keyboards).
Userdefined keys are interpreted first, so they may overwrite the predefined
keys (defining a user key 'n' for example disables the toggling of the
preview during the game).

If you toggle a window during game, it's old value will be restored at the
end of the game.

 - - - - -

Sprites:

At first i wrote WinColTris for monochrom resolutions only. The only
sprites included are for this case.
In other cases (four or more colors) the sprites are loaded from
IMG-files (without color-table). You can do that also in monochrom,
but then WinColTris uses the VDI-mode for graphic output.

The files have the names COLUMNSx.IMG und TETRISx.IMG, where x means
the number of planes (4 colors -> 2 planes, 16 colors -> 4 planes,
256 colors -> 8 planes, True/HiColor is impossible).
There are separate files for columns and tetris, however you might
use the same file twice (note: tetris is 10x20, columns 6x16 stones).

The stones can have any size. There is no check wether the main window
fits on the screen.

The IMG-files has to contain one line with 16 sprites, where

the first one is empty (it's used to delete),
the second to the eighth are the differant colors of the stones
  (column does not use the last one)
the nineth to thirteenth are shown as a 'film' before stones are removed
the last three stones are unused (they have to be there, otherwise
  the width can't be calculated correctly).

The stones don't have to be quadratic, however all stones have to
have the same width.

The colortable of a XIMG-file is ignored.

The example files (equal for columns and tetris) are very ugly.
They should be used to create one stones not to play (I don't use
color...)

 - - - - -

known bugs (not everything below is really a bug):

there is almost NO error handling on reading and writing the opts file
(COLTRIS.SET).


