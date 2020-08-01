Here is a port of perl 4.0 Patchlevel 10 to the atariST series.

What you'll need:
	- a decent shell (i use gulam for obvious reasons), other
	highly recommended ones are bash 1.08, gemini/mufpel, okami,
	microCsh, init from apratt for MiNT. avoid neodesk. avoid the
	desktop like the plague. The shell should be setup to use
	atari/mwc conventions for command lines and environment setup
	and passing. (in gulam be sure to `set env_stle mw').

	- a decent set of file utils (ls, rm, mv, etc etc) in your $PATH.
	if you dont have these, lookm on atari.archive. the gnuFileutils
	are available there.
	
	- included here are echo and perlglob that you will need.

	- setting UNIXMODE is recommended but not required. If you are
	going to run the perl tests, then set UNIXMODE to atleast
	"/.,LAd", else you will get a lot of unnecessary failures.
	(alternately you will have to go in and edit long path names.
	 get rid of things dealing with links, and rename paths
	 beginning with "/dev/..." etc)

	- if you are going to compile: you'll need gcc distribution,
	(i used gcc-1.40 and libs at Patchlevel 73). Also you will
	need the port of gdbm (i used v1.5). you'll also need bison.
	all these are available on atari.archive, in atari/gnustuff/tos
	(except gdbm, the diffs for gdbm are included here).
	
Compiling:
	- get and install gnu gdbm (i used v1.5 -- see README.ST in
	  the gdbm distribution on how to make the gdbm library).
	- get the perl kit at Patchlevel 10
	- copy config.h atarist.c wildmat.c perlglob.c echo.c 
	  makefile.std and makefile from this directory
	- apply the diffs in file `diffs' using patch
	- apply a second set of diffs in file `diffs2' using patch.
	- hit make -f makefile.st. (if you are not cross-compiling, 
	   you'll have to adjust the makefile yourself -- watchout for
	   perly.fixer).
	   This will result in 3 executables, perl.ttp, perlglob.ttp
	   and echo.ttp. Put all these executables in a sub-directory
	   in your $PATH
	(if you use makefile.std instead of makefile.st, the executable
	 will be called perld.ttp. this is perl compiled with
	 -DDEBUGGING)

Testing:
	- run perl from a decent shell. i use either gulam or bash
	if you are going to be running from gulam, be sure to
		set env_style mw
	(this can be done automatically by including the above
	 line in the gulam.g startup file). bash always uses
	atari/mwc conventions so you dont have to do anything special.
	(if you run perl from the desktop, you are asking for trouble!)

	- you'll have to run the tests by hand. Almost all the tests
	pass. You'll have to judge for yourself when a test fails
	if it should have. I was able to explain all failures. If you
	cant, ask me via mail. (one day i will cook up a script to
	do this).
	- It helps to have all the gnu fileutils in your PATH here.
	Especially echo.
	- Also a lot more tests will pass if you have UNIXMODE setup
	i use "/.,LAd". If you dont use UNIXMODE, you'll have to hack
	some of the tests.
	- You may have to fix up a few Pathnames in the tests if you
	are cd'ing to a particular sub-directory to run the tests.

	- Compare your tests with the results i got -- see file RESULTS.
	
General:
	- setenv PERLLIB to point at the subdirectory containing lib/*
	(if you want PERLLIB to contain more than one path, seperate
	 them with commas)
	- UNIXMODE is supported not required.
	- Pipes are a little flakey sometimes, but mostly work fine.
	- to force binary mode use "binary FILE"
	- browse thru config.h to see whats supported
	- should MiNT'ize this much more.
	- avoid using the backtick (`commands`). Use 'open(FOO, "command |")'
	and use the filehandle FOO as appro.
	- the command passed to system etc can contain
	redirections of stdin/out, but system does not understand
	fancy pipelines etc.
	- syscall() will be used to make gemdos/bios/xbios/lineA
	calls eventually. i have to complete this.
	(note: we dont use ioctl like messy-dos to do this, as we can do
	 real ioctl's on devices)
	- watch out for re-directions. TOS blows up if you try to
	re-direct a re-directed handle. atari has supposedly
	fixed this recently.
	- in the perl libs (particularly perldb.pl) you will
	need to s?/dev/tty?/dev/console?. perl -d works just fine.
	for instance: (for this to work, UNIXMODE should include the
	'd' option):
*** /home/bammi/etc/src/perl/lib/perldb.pl	Tue Jun 11 17:40:17 1991
--- perldb.pl	Mon Oct  7 21:46:28 1991
***************
*** 49,56 ****
  # 
  #
  
! open(IN, "</dev/tty") || open(IN,  "<&STDIN");	# so we don't dingle stdin
! open(OUT,">/dev/tty") || open(OUT, ">&STDOUT");	# so we don't dongle stdout
  select(OUT);
  $| = 1;				# for DB'OUT
  select(STDOUT);
--- 49,56 ----
  # 
  #
  
! open(IN, "</dev/console") || open(IN,  "<&STDIN");	# so we don't dingle stdin
! open(OUT,">/dev/console") || open(OUT, ">&STDOUT");	# so we don't dongle stdout
  select(OUT);
  $| = 1;				# for DB'OUT
  select(STDOUT);


cheers,
--
bang:   uunet!cadence!bammi			jwahar r. bammi
domain: bammi@cadence.com
GEnie:	J.Bammi
CIS:    71515,155
