
This is the source code to MadMac, resurrected from some very old
backups that I found a while back.  At the moment I have no idea how
well this works, but it is compiling again under GCC on my Ubuntu
Linux machine, and I haven't seen in crash yet.

This code has not aged well, nor is it the latest MadMac (it forked
when I left Atari; Alan Pratt fixed some bugs, maybe some nasty ones).
Any work that was done for Jaguar or 68020 support is not here (I
don't know if MadMac was modified for these, but if it was, I don't
have those changes).

As I was saying, the code is pretty bad; lots of hard-coded constants,
use of 'gets', it plays fast and loose with types (ints are pointers,
right?).  It uses K&R C (v7 Unix style) and could use a good swabbing
out with ANSI C function prototypes, and unions where the code is
cheating badly.

I haven't tried this out except to see if the ".s" files here make it
through without generating errors; I haven't looked at the output to
see if the correct stuff is being emitted.

You're pretty much on your own at this point.  Frankly I'm not sure if
this code will do you any favors, but you're welcome to it.


-landon
