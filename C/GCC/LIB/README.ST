
This is the runtime library for my port of GNU CC and related tools.

This should live in \gnu\lib\ on your GNU device, or wherever you want
to keep library code.  Set your env var GNULIB to point to that
directory, without the trailing backslash.

This is a pretty motley collection of code.  It comes from various
places; some is from DLIBS, some is from the public archives on
SIMTEL20, some is from the MUN GCC cross-compiler, some from various
repositories of GNU stuff at MIT.  Some I wrote myself.

Notable kludges to watch out for:

The double-float support (in flonum.s) is pretty ragged.  It's really
just kludged up calls to the single-float stuff.  I suppose I'll get
around to re-writing it one of these days, but if someone else wants
to do it first...

The trap stuff (for TOS calls) is somewhat gross.  Because of this
brain-damage of random-sized args, GCC won't push the right stuff on
the stack for traps, so it has to be done by hand.  Fortunately, there
aren't too many variants, so a smallish number of routines does the
job, but it's still gross.  Hopefully, I'll get around to figuring out
how to use GCC's classy user-definable instruction generation facility
to do the right thing, but for now it's a kludge.


To my knowledge, this code works pretty well, but there are likely
still bugs in it; I'm still finding them fairly frequently.

I guess that's it.  Good luck.

JRD@Stony-brook.SCRC.Symbolics.COM
