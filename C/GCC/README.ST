
This is the set of common executables for my port of GNU C for Atari
STs.  

Before you go to far, please read the file COPYING.  It explains your
rights and responsibilities as a GNU user.  Basically, it just says
that GNUCC is free, and that nobody has the right to make it anything
other than free.  It also says that there's NO WARRANTY.

This arc contains the 'common' executables of the GNU compiler.  That
means the compiler driver (gcc.ttp), the preprocessor (gcc-cpp.ttp),
the main body (gcc-cc1.ttp), the assembler (gcc-as.ttp) and the linker
(gcc-ld.ttp).  It also contains gcc-ar.ttp, which is the object
library maintainer, for no particular reason other than that I had to
put it somewhere.

All this stuff should go in \gnu\exec\ on your gnu disk, or whatever
you've pointed the env var GCCEXEC at.

Installing:

All this stuff assumes you're running under Gulam.  It'll probly work
with other CLI's, but that's what I use, so I know it works.

To install this stuff, unpack the archive into whatever directory you
want to hold the executables.  I put everything in f:\gnu\exec\, but
you ought to be able to put them anywhere.  Define an env var called
GNULIB that contains the device/directory of the place you've put the
runtime library, header files etc.  That should have NO trailing
backslash.  Define another env var called GCCEXEC whose value is the
default prefix (ie the kind of thing you'd say after "-B") for the
compiler driver.  Note that this value is a
device/dir/partial-pathname, ie "f:\gnu\exec\gcc-".  If you like, you
can incorporate that into the alias for your CC command (ie alias cc
f:\gnu\exec\gcc) but due the all the problems around long command
lines, it's probably not worth the effort.  Finally, you'll need an
env var called TEMP.  It should be the name of a directory for temp
files; again, no trailing backslash. 

At that point, you're done!  You should be able to type "cc foo.c -o
foo.ttp" and have all the obvious things happen.

(A likely story... :-} )

In case of difficulty, I've included a copy of my config file, gnu.g.
Hopefully, if something's misbehaving, you can figure out what you've
done differently than me.

A few words about memory:

GCC loves memory.  A lot.  It loves to cons structures.  Lots of them.
It probably won't run at all in less than 1 Meg; this version will
probably need 2 Meg.  Later (after I get this release out) I plan to
come up with a better scheme for stack initialization, but this
version of cc1 has a 1/2 meg stack, and needs it for compiling large
files with optimization turned on.  Happily, it doesn't need all that
stack for smaller files, or even big files without -O, so it should be
feasible to make a compiler with a smaller stack.  If anyone is
desperate for a version with a different sized stack, let me know and
I'll see about coming up with one.  I may also be able to come up with
a patch that can be applied to an existing executable.

That's about it.  The sources to all these things are packaged
separately, so as to make them easier to distrubute; they should be
appearing on various servers about the time this gets there.

Good Luck.

JRD@Stony-Brook.SCRC.Symbolics.COM
