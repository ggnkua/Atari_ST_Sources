30-Oct-92
I compiled this cross-assembler for the DSP56001 on my Atari ST.
I tried to assemble some of the sources in the examples directory, and
it seems to work. In order to get a listing on disk or on the printer you
must redirect the standard output. I think this is a problem if you want
to start the program from the desktop.

I compiled the assembler with GCC version 1.40. I've used the gram.c and
lex.yy.c files from the original sources. I don't have a working version of
lex and yacc, so I can't create these files myself. But the program works,
so there's really no need to change the files. I renamed the file lex.yy.c
to lexyy.c, because some (most) Atari users won't be able to use filenames
with two dots.
I didn't change the sources, so they still have the Unix style End-Of-Lines.


Please send bug reports and other comments to the author of the program.
(Quinn C. Jensen, Email: jensenq@npd.novell.com or jensenq@qcj.icon.com)
If you have questions or comments on my Atari ST port then you can mail me.


Enjoy,

Ate Brink
Moderator of the Atari archive at the Utrecht university (ftp.cs.ruu.nl)
Email: ate@cs.ruu.nl

