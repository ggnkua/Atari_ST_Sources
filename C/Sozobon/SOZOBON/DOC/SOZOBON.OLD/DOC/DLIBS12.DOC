
dLibs v1.2							10/19/87


  So, you gotten the v1.2 release of dLibs.  NOW what!

  Well, hopefully, now you start writing (or porting) better programs.
That's really what good libraries are all about, isn't it...  a
collection of useful routines that you don't have to rewrite for
yourself in each program you create.  That's what dLibs is meant to be.
Since many C compilers (particularly Alcyon) come with buggy and/or
incomplete libraries, and you RARELY get to see the source code, dLibs
was created to fill that gap.

  The SRC archive is the source code (.s and .c) for all the library
routines.  The H archive is the \usr\include header files.  The SYS_H
archive is the \usr\include\sys header files.  GIFTS contains some
sample programs.  The library, it's index file (for ALN), the docs,
and the startup module are all in the root of the archive.

  I'd like to see these routines distributed as widely as possible as I
feel they will be a benefit to many people.  The only restriction I'd
like to place on the use of dLibs is this.  If you modify the source
code, please don't redistribute it under the name "dLibs".  I encourage
people to look at, play with, modify and improve the source code as
much as they want, and would gladly accept suggestions (preferrably
with source code) for changes/additions to dLibs.  I simply want to
avoid the problem of digressive versions of dLibs.

  This is now the third release of dLibs and so far I've been pretty
happy with the way people have been using these routines, though I
would like to see them used a little more widely.  I expect now that
I'm going to become more active with Minix, and since dLibs is being
released with Sozobon C, they will be getting more exposure.

  I must thank the developers of Sozobon C for getting me off my
posterior and encouraging me to collect up all the changes I had
sitting on my system for a new release.  In the process, I decided it
was time to add many more functions to come closer to the X3J11
proposed C standard.  The end of DLIBS.DOC contains a sketchy history
of changes since v1.0, and mentions most of the new additions.

  In particular, I've included a getopt() function derived from a
publicly posted version from Doug Gwyn.  I've modified the routine to
accept more variations in command line format, but the original
stricter version can be obtained by #define'ing STRICT and recompiling
that module.  This is a very useful function, for those who haven't
used it before.  I've included a couple of sample programs which show
it's use (as well as a few other functions).

  One of the sample programs (in the GIFTS archive) is a newer version
of the substitution stream editor (SSED) that I included with the v1.1
release.  This version is more flexible, although it still only
implements the most commonly used sed command, [s]ubstitute.

  As usual, this release was not a single-person effort.  I want to
thank the Sozobon developers, Tony Andrews, Johann Ruegg and Joe Treat,
for numerous helpful hints and additions as well as their making
changes to the compiler to help implement some of the functionality in
the current dLibs;  John Stanley has again been a great help in
debugging, particularly with the printf/scanf functions which are his
creation;  Doug Gwyn, as stated before, wrote the code on which my
getopt() is based;  Charles Anderson and David (orc) Parsons helped
with analysis and design of the improved tty handling code for the
completely rewritten standard i/o functions;  My wife Ruth has been
very patient with my late evening hours;  And numerous others have
assisted with their comments and suggestions.

--
      Dale Schumacher                         399 Beacon Ave.
      (alias: Dalnefre')                      St. Paul, MN  55104
      dal@syntel.UUCP                         United States of America
    "It's not reality that's important, but how you perceive things."
