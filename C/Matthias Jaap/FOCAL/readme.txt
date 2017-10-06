Focal-81
--------

This is the Atari ST port of the Focal programming language.

This version of Focal was basically written in 1981 for the then-famous
PDP-8 machines. The source was designed to run on Unix, VMS and VAX (the
machine that was used to design the first ST's!). Focal-81 is very portabel -
I didn't have to modify the sources for the ST.

Running programs can be a bit tricky. Nothing will happen if you drag a Focal
program on Focal.tos. There is a built-in command line interpreter. To start
queens.foc type:
lib call queens.foc
g

A couple of files are included:
focal0, focal1, focal2, focal3, focal.h, proto.h
	The source code
focal.prj
	PureC project file.
Makefile
	Makefile for GnuC
makefile.dos
	Makefile for DOS.
queens.foc, sieve.foc
	Two sample programs
Install
	Original installation notes
focal.doc
	Language description
readme
	notes about the list of modifications
	



The Atari version was compiled using PureC 1.1.

Have Fun!
Matthias Jaap
mjaap@atariuptodate.de
http://www.mypenguin.de/prg/
