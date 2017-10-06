This is Atari-curses, read the curses.doc file about installing first.

The archive should contain the following files :

CURSES.C         Source for CURSES, compile once.
CURSES.H         Include file for CURSES.C and any program using CURSES.
CURSES.MAN       CURSES short docs, a manual page for UN*X-freaks.
CURSES.DOC       CURSES long docs, this is what you will want to read when
                 you are going to use CURSES.
README.TXT       This file.
TWINKLE.C        Sample application.
TWINKLE.TOS      Ready to run sample application.


This is essentially a shareware program, its usage is subject to the following
conditions :

PUBLIC-DOMAIN       : don't take the credit for it.
Commercial purposes : Send 5 US-dollars or equivalent currency and return
                      postage to me to get a written consent to use it.

CURSES may be distributed to anyone, provided that all of the above files
remain in the archive, and the various copyright notices remain intact.

Bug reports and suggestions are welcome, send me e-mail.

Rene van't Veen                  ( ...!mcvax!nikhefh!u13 )
Debussystraat 27
1817 GL Alkmaar
The Netherlands


		Notes for the Megamax Version of Curses

This version of curses compiles with the Megamax C compiler. A couple
of bug fixes were needed and the wgetstr routine was hacked quite a bit.


Notes:

1. The overlay() routine was renamed woverlay() to avoid a conflict with
   the Megamax reserved word.

2. The entire file was placed in an overlay because I needed the space.
   You may want to get rid of the overlay line in curses.c depending on
   what you're linking curses with.

3. The routines printw() and scanw() are implemented in the usual brute-
   force way since Megamax doesn't have varargs. These are at the end
   of curses.c.

4. Remember to change your init.c to get extra stack space.

5. The file portab.h contains the definitions needed from the Alcyon
   file of the same name. If you have a more complete version, use it.

6. twinkle.tos isn't in this distribution because I wanted to post this
   stuff as clear text.


Tony Andrews
ihnp4!onecom!wldrdg!tony
Wildridge Consulting, Inc.
Boulder, CO

