JOVE for the Atari - MiNT
=========================

This is my port of JOVE, version 4.16. As the name says JOVE (Jonathan's Own
Version Of Emacs) is an Emacs like Editor. But in contrast to Emacs, it's
completely written in C and requires much less space.

This port only runs under MiNT. Most of the parts should be installed on a
file system that supports long filenames (Minix FS). I compiled, tested and
use it on an Atari ST running MiNT 4.14.6 in the KGMD environment.

There are some other files you might find on various ftp archives:
- jove_s01.zoo
- jove_b01.zoo
- jove_d01.zoo
They all belong to a former port of JOVE (Version 4.14.6) I did several years
ago. That port should be obsolete by this one (although it still works under
MiNT. It's main disadvantages were that it was only able to handle file names
with lower case letters; in the current port I tried to support pseudo ttys
which definitively didn't work in the old port).

This port comes in two parts:

- jove416b.tgz
  This archive only contains the executables. They are ready to be installed.

- jove416s.tgz
  This archive contains the ported sources. Object files and executables are
  omitted in this archive. You will want to get this archive file if you intend
  to make your own improvements - or if you just want to see what I did.


This README file gives you information on both of those archive files as well
as general information on my port.

I hope you will like JOVE as much as I do. Please send questions, bug reports,
bug fixes or whatever else you like to me. I'd also like to know who
downloaded my port - maybe I did it solely my me alone? So please give me some
feedback!

My (hopefully everlasting) email address is:
streibel@usa.net

June, 5th, 1998

Hans Streibel


****************
* jove416b.tgz *
****************

I am sure first of all you want to know how to install it. First of all - of
course - you have to unpack the whole stuff. The archive is packed with tar
and compressed by gzip. Obviously you already unpacked the archive or else you
wouldn't be able to read this file. But please be sure that you unpack the
archive on a file system supporting long filenames! Some files are longer than
8+3 characters, for instance the program teachjove.

The next tasks should be performed as root. JOVE can be installed in
directories local to a user (owned by a different user than root) but the
default locations are only writable by root.

Before I forget:

- The directories you will choose below for
  - LIBDIR
  - SHAREDIR
  - BINDIR
  - MANDIR
  should all be on a file system supporting long filenames.

- Besides, this port assumes that the directory storing temporary files is on
  a filesystem supporting long filenames. The default for this is /usr/tmp
  (see the section on environment variables below).

- Your home directory can be on a TOS FS. But if you want to run teachjove
  it must be on a filesystem supporting long filenames. If you want to
  run teachjove and your home directory is on a TOS FS then temporarily set
  the environment variable HOME to a directory on a filesystem with long
  filenames.

Ok, let's start the installation.

Installation Procedure 1
------------------------

If you have make, take a look into the Makefile. If you are satisfied by the
settings just type:
- make install
That's all you have to do. You should have a working installation now. If are
short in time you can quit reading here. But you should go on reading README
as it describes some usefuls changes that could be applied to files executed
at system startup (/etc/rc*). And I think it's a good idea to look at least at
the section below describing possible environment variables. And the section
about documentation will tell you how you can get acquainted with JOVE. Ok, I
see I have to suggest to go on reading anyway...

If you have make but you are not satisfied by the settings in the Makefile
(notable SHARELIB, LIBDIR, BINDIR, MANDIR) change those and type:
- make install
You will have to define some environment variables that will help JOVE to find
the locations where you put the various parts of the installation. They will
be described below.


Installation Procedure 2
------------------------

If you don't have make, it's a little bit harder. First choose directories
for:

- SHAREDIR
  This directory will hold the online documentation and the system wide
  initialization file. Compiled in default is /usr/local/lib/jove.

- LIBDIR
  This directory will hold the executable programs portsrv and recover.
  Compiled in default is /usr/local/lib/jove.

- BINDIR
  This is where JOVE and teachjove will be put in.
  Default is /usr/local/bin - not compiled in into any of the executables.

- MANDIR
  The man pages for JOVE, recover and teachjove will be copied into this
  directory.
  Default is is /usr/local/man/man1 - also not compiled in.

Create the directories if they don't yet exist. And please remember that you
presumably will have to be root to perform the following tasks:

- copy doc/teach-jove to SHAREDIR/teach-jove. Change the mode to 644.

- copy doc/cmds.doc to SHAREDIR/cmds.doc. Change to mode to 644

- copy
  doc/jove.rc.sun, doc/keychart.sun, doc/jove.rc.sun-cmd,
  doc/keychart.sun-cmd, doc/jove.rc.vt100, doc/keychart.vt100,
  doc/jove.rc.wyse, doc/keychart.wyse, doc/jove.rc.xterm, doc/keychart.xterm,
  doc/jove.rc.z29, doc/keychart.z29, doc/jove.rc.3022, doc/keychart.3022,
  doc/keychart., doc/XTermresource, doc/jove.rc.st52, doc/jove.rc.stv52
  to
  SHAREDIR.
  Change their modes to 644.

- copy portsrv to LIBDIR. Change the mode to 755.

- copy recover to LIBDIR. Change the mode to 755.

- copy jjove to BINDIR/jove (it has to be renamed). Change the mode to 755.

- copy teachjove to BINDIR. Change the mode to 755.

- you have to substitute the strings <TMPDIR>, <LIBDIR>, <SHAREDIR> and
  <SHELL> in doc/jove.nr. Please substitute
  - <TMPDIR> by /usr/tmp (that's what is compiled in)
  - <SHELL> by /bin/sh (that's what is compiled in)
  - <SHAREDIR> by your choise for SHAREDIR
  - <LIBDIR> by your choice for LIBDIR
  Take a look into Makefile to get an idea on how this can easily be done
  using sed. Look for a line containing the string doc/jove.nr.
  Copy the result to MANDIR/jove.X where X is the extension for the manual
  volume.
  To make life easier for you I include the file file doc/jove.nr.port
  where all the strings given above already have been replaced by their
  default settings.
  Change the mode of the resulting file to 644.

- make exactly the same procedure as described just above for the file
  doc/teachjove.nr. Again, for convenience I include a file
  doc/teachjove.nr.port here where the changes are already made - using the
  default settings.

- copy doc/jove.rc to SHAREDIR. Change the mode to 644.

Uff - you got it!


*****************
* Documentation *
*****************

- If you're new to JOVE it's presumably best to start with the tutorial.
  You start it by just typing:
  - teachjove
  Your home directory must be able to store long filenames.

- There is a very detailed description in doc/jove.man.
  Note for those who only got jove416s.tgz: You will get this file by typing:
  make doc/jove.man

- Take a look at the manual pages you just installed:
  - jove
  - teachjove
  For those who don't have nroff I also include the results by running these
  manual pages thru nroff:
  - doc/jove.1.man
  - doc/teachjove.1.man

- A quick reference is given in doc/jove.qref.



*************************
* Environment Variables *
*************************

Yes, there are several environment variables that you might want to set.

- PATH
  BINDIR should be included in your search path for executables. The compiled
  in path is /usr/local/bin and this directory should normally be mentioned in
  your PATH.

- MANPATH
  Hmm, I'm somewhat unsure about this variable. MANPATH is like the PATH
  variable in that all the directories given there are searched by the man
  command. The default location where the manual pages are put in in this port
  (MANDIR) is /usr/local/man/man1. I'm able to run the man program
  successfully for the jove manfiles without mentioning /usr/local/man in
  MANPATH.

- JOVERC
  This environment variable is unique to this port. When JOVE starts up it
  tries to read a user local initialization file. By default it looks for
  them in your home directory ($HOME):
  - first it looks for $HOME/.joverc
  - if that file isn't found JOVE looks for $HOME/jove.rc
  - this default lookup sequence can be overwritten by setting the environment
    variable JOVERC to the file that has to be executed at startup. Please
    note that I speak of the user initialization file here. The global
    initialization file will be executed anyway (if you don't disable it by
    giving the option -J to jove).
  Please note that the default behavior lets your keep your home directory on
  a TOS FS - by naming the initialization file jove.rc.

- METAKEY
  I don't know what will happen if you set this variable (you see I didn't
  read all of the docs yet - although I'm using JOVE now for more than 10
  years). The value doesn't matter; it can be NULL.
  Just set this variable, see what happens - and send an email to me.

- HOME
  Of course this should always be set. The local initialization file for JOVE
  is looked for in this directory.

- JOVESHARE
  If you chose a different directory for SHAREDIR above from what is compiled
  in into JOVE (/usr/local/lib/jove) you have to set JOVESHARE to SHAREDIR.

- JOVELIB
  If you chose a different directory for LIBDIR above from what is compiled
  in into JOVE (/usr/local/lib/jove) you have to set JOVELIB to LIBDIR.

- TMP
- TMPDIR
- TEMPDIR
  These variables are special to this port (ok at least TMP and TEMPDIR). You
  should set one of them if you're not satisfied with the default compiled in
  location for temporary files (/usr/tmp).
  If more than one of these environment variables are set, they are regarded
  in this order:
  - TMP
  - TMPDIR
  - TEMPDIR
  The chosen directory must be on a filesystem supporting long filenames!
  Hmm I just see that "recover" only looks for files in TMPDIR for files that
  can be recovered. I'll have to fix this in the next port. In the meantime
  please set TMPDIR to your chosen directory for temporary files (too) - if
  it's different from the compiled in default (/usr/tmp).

- SHELL
  If you start a shell from within JOVE the shell named in this variable will
  be used. Note that there is still a bug in MiNT/JOVE here. See below.

- MAIL
  The name of your mailbox file. JOVE will inform you when new mail arrives.

- TERM
  Names your terminal. Should always be set.


************************************************************
* Changes in JOVE done for Atari/MiNT - Hints - Known Bugs *
************************************************************
  
- there are some environment variables special to this port:
  - JOVERC
  - TMP
  - TEMPDIR
  They are describes above in the section on environment variables.

- the files doc/jove.rc.st52 and doc/joverc.stv52 (a link to the former
  one) are special for this port. Upto now they just describe the cursor keys
  for an Atari terminal.

- I changed the global initialization file to the settings I like most. It is
  given in doc/jove.rc. You can find the file from the original distribution
  in doc/jove.rc.orig.

- for new users:
  - the sequence "control-x" "control-c" is (almost) the only way to quit JOVE
  - the command "search-forward" isn't bound to "control-s" (typing control-s
    will hold your terminal; reactivate it by control-q). Type "control-<"
    instead. At least this works on a German keyboard.
  - the command set-mark can be typed in by "control-<space>" or
    "control-2". At least this works on a German keyboard.

- This port assumes that everything is done on the unified drive U:
  However I tried to build in support for volumes on an Atari. It's not
  perfect (next port?).
  - find-file a:\xyz.txt
    works
  - ESC-x cd a:\
    doesn't work
  
- JOVE only recognizes UNIX style end-of-line delimiters, that is just NEWLINE
  (NL, \n). I don't deal at all with old TOS (MSDOS) newline
  delimiters (carriage-return newline).

- JOVE is 8 bit clean. I compiled JOVE using the internal page for ISO-8859-1.
  However - behavior is somewhat strange:
  - All seems to be fine if you installed KGMD and run JOVE in that
    environment. For instance, the German "Umlaut" ä (for those who can't read
    this: letter a with two dots on it - I will refer to it as "ae") is
    displayed correctly, commands for transforming it to upper case and then to
    lower case again work fine. It's also saved with the correct value, \344,
    (according to ISO-8859-1) to a file.
  - If you're in a shell and type:
       cat > xyz
       ae
       control-d
    you'll find the code \204 inside the file xyz instead of \344 that I would
    expect here. Even in the KGMD environment.
  - If you just start MiNT and don't start KGMD JOVE will use the code
    \204 for ae! Even if you run "ttyvfont iso-atari-16.fnt" which is normally
    started when running KGMD.
  Sorry I have really no idea on what's going wrong here.
  But, despite the fact that some special characters are not displayed
  properly respectively are not inserted correctly, existing files having 8 bit
  characters CAN be loaded and saved again without damaging them. At least
  that's my experience upto now. Please don't rely on it too much. Make your
  own tests and send your experiences to me via email!
  MiNT developers:
  I had to compile JOVE with the internal codepage for ISO-8859-1 as MiNT does
  not yet support a "locale" other than "C" (at least in the Mintlibs, the
  function setlocale is only defined for the "C" locale). Could you work on
  this?

- shell commands (ESC-x shell) from within JOVE DO work - but:
  - JOVE has to open a pseudo tty (short pty) for this.
    In the current implementation of MiNT (I was using 4.14.6) a pty can only
    be created by root as some entries have to be written to locations that
    are only writable by root: /pipe, /dev (KGMD environment).
  - so you might consider JOVE running SUID root (chmod 4755 jove).
    Shell commands do work now! But all files written will belong to root
    now. Presumably that's not what you want to have.
    Besides, you CAN start a bourne shell but you CAN'T start a csh(tcsh). For
    starting a csh(tcsh), both the effective and the real user must be same
    (or something like this). Of course this could be enforced inside the
    program but I didn't include such a hack in my port because I think:
    JOVE SHOULD NOT BE RUN AS SUID ROOT!
  So MiNT developers: Do you have a solution for this?

- there is code in the original posting for JOVE version 4.16 that supports
  JOVE under X-Windows. I didn't do a port for this. The source can be found
  in the xjove subdirectory.

- I compiled JOVE for an Atari ST. Thus the code is for the 68000 CPU. Does
  this run on all other platforms (Falcon, TT, Medusa ...)? If not, just grab
  jove416s.tgz, modify the Makefile and compile your own JOVE.

- Finally JOVE has so many functionalities. I didn't test everything
  thoroughly. But most should be working fine. I'm currently typing this file
  using my new port and I didn't experience any problems at all.


****************
* JOVE416s.tgz *
****************

This archive contains the sources of JOVE - with changes for compiling and
running it under MiNT.

- all changes to the sources are #ifdef-ed by MINT. The compiler I used, gcc,
  defines the symbol MINT by default.

- the Makefile is changed so that JOVE compiles for MiNT.
  The Makefile of the original distribution can be found in Makefile.orig.

- I compiled everything in the KGMD environment:
  - MiNT version 4.14.6 (ok, newer than what comes with KGMD)
  - gcc, version 2.5.8
  - gas, version 1.38 PL4
  - Mintlibs, version ??? (came with KGMD)

- I didn't make a try to port xjove. Thus everything in the subdirectory
  xjove is untouched.

- A try to compile JOVE with baserel unfortunately failed. The data and bss
  size together is about 90KB. I think the limit for baserel is at 32KB?
  Does anyone have an idea on what to do to manage it to compile JOVE with
  baserel?

- all the bugs I found and tried to work around in my first port some years
  ago vanished. So the bell rings, setjmp doesn't crash any more when doing a
  "cd ~" and the screen gets updated after every keystroke.

- I added the files doc/jove.rc.st52 and doc/jove.rc.stv52.
  They define the cursor keys for the terminals ST52 and STV52.

- In the file doc/jove.rc I made local changes to what I like.
  doc/jove.rc.orig is the original version of the distribution.
