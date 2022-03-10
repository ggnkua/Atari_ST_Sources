LazyTick Readme - version 0.3

LazyTick is a public domain Tick utility (file mailer) for
Fidonet(tm) systems using a Pandora message base and a TheBox or
Binkley outbound directory.  More doc in lazytick.txt.

It has been tested on the Atari ST, but should be portable enough 
to work on most systems with a C compiler with slight editing of 
the tick.h config file. Binkley outbound names should be checked.

You can eventually contact the original author on:
    Franck Arnaud @ Fidonet 2:320/100 
    (freq LAZYTICK on 2:320/100 for latest version)
    Nonsupport BBS +33-1-49650542

KNOWN BUGS
==========

-copyfile is slow

TODO
====

These are ideas. I don't need those features now so 
implementation is not planned (by me at least, you're 
welcome to do it :-)).

-support new binkley outbound format (4D)?
-support "replaces" TIC keyword (it's simply passed thru currently)?
-support incoming multiple seen-by on a seenby line (like filemgr)
-reject TICs with bad password (simply logs currently)

HISTORY
=======

0.1beta FA  First public release
0.2beta FA  Config/Misc adapted for LazyFix compatibility
        FA  Various small bugs fixed, unknown lines now passed-thru
        FA  Improved announces to nicely display descriptions
        FA  Should support points and long lines in incoming .TIC
        FA  Password now correct for points of secundary aka
        FA  Hatch and usage added
        FA  get_area now case insensitive
0.3beta FA  strins dependency removed (improved portab)
