Welcome to "cs", a C source code examiner.  Those familiar with "cscope"
will feel at home here in "cs".  Written and maintained by
Michael Haardt, I found this to be an invaluable tool when examining 
unfamiliar source code.  Hence the port to MiNT.

Enclosed you'll find the (-very- slightly modified) MiNT version.  Michael
Haardt has been kind enough to include the changes needed for MiNT
in future releases.

Making cs
---------
To make cs, you'll needed ncurses 4.1.  I imagine anything newer than
4.1 is also acceptable.  After that, it's simply a matter of typing
"make".  The enclosed binary was made using gcc version 2.5.8, PL 1.
The libraries are whatever were installed by the KGMD package (sorry
for the ambiguity).  This should run on any 68k machine, although
I have not tested it on anything other than a Falcon with an Afterburner.

What all you MiNT owners need to run cs
---------------------------------------
As with making "cs", the primary package needed for MiNT is ncurses 4.1 (or
newer is also most likely acceptable).  ncurses 4.1 can be obtain from
<insert URL here> or probably a number of FTP sites.
Dont forget to set the TERMCAP and TERMINFO variables appropriately, e.g.:

TERMCAP=/etc/termcap
TERMINFO=/usr/share/terminfo

Make sure you set your EDITOR variable.  I believe "emacs" is
the supported editor, but I'm a "vi" guy.  I just need to construct the
tags file for "vi" (some waaayy off thing to do).

Known Problems
--------------
These are problems I know of in cs.  I've sent these to the author, so
he'll know.  I doubt he'll get around to fixing the Atari specific ones.

1)  You must strip out the carriage returns in your source code.  This can be
    easily accomplished using "crlf".  Otherwise, the found text will be
    invisible, and the next starting of "cs" will crash (just "cs", not
    your system, of course). 

2)  cs only works in the Minix file system.  Don't try to run within a
    GEM partition, or else you'll see the same symptoms as #1 above.

Finally, note that this is still an early version.  Users of cscope will find
that a number of things are quite different, but I believe "cs" has
quite a bit of potential.

Happy Coding!

Michael White
michael@fastlane.net
