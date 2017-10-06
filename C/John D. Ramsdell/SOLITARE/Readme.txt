		saa - Streets and Alleys Solitaire

This is README version 1.1 of 91/05/17 for Streets and Alleys.

saa is an implementation of the solitaire game Streets and Alleys for
Posix compliant machines that also provide the curses terminal screen
handling and optimization package.

To create an executable named `saa', type `make'.  If the compilation
fails because stdlib.h is missing, type `make "CFLAGS=-O -DNON_ANSI_C"'.

To learn how play the game, type `saa help', or start saa and type
`?'.  You can play streets and alleys with a reduced sized deck by
giving saa the number of ranks with which you wish to play.

Enjoy!
John

Copyright 1991 by John D. Ramsdell.

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies.  John
Ramsdell makes no representations about the suitability of this
software for any purpose.  It is provided "as is" without express or
implied warranty.
