head	1.3;
access;
symbols
	TRLPR11B:1.3
	TRLPR10B:1.2
	TRLPR09B:1.1;
locks
	Thomas:1.3; strict;
comment	@# @;


1.3
date	99.12.30.13.11.26;	author Thomas;	state Exp;
branches;
next	1.2;

1.2
date	99.11.13.17.12.52;	author Thomas;	state Exp;
branches;
next	1.1;

1.1
date	99.03.08.21.25.30;	author Thomas;	state Exp;
branches;
next	;


desc
@"What is it" for lpr.ttp
@


1.3
log
@*** empty log message ***
@
text
@Readme.txt for Thomas' lpr remote printing clients and server.     
1999-12-28


What does this package provide?

You want to print from your Atari-ST compatible computer on a printer
connected to a remote computer?
The printer connected to your ST shall be usable from a remote machine?

Well, here is the solution provided you have:

-       The remote printer(s) are attached to remote host(s) that are
        reachable via TCP/IP and have a lpd printer spooler daemon running.
        This may also be an Atari-ST compatible machine.

-       The Atari-ST machine(s) run(s) a TOS compatible OS

-       Peter Rottengatters STinG TCP/IP software is up and running on the
        ST(s).


Please read the manual lpr.txt on how to install and use this package, 
license, etc.


Manifest

You should have the archive file TRLPR11B.LZH consisting of the following
files:

lpr.txt         User Manual for the whole package
lpr.prg         GEM executable to drop files to be printed on (client)
lp.dev          Device driver with lpr functionality to be used with the
                MagiC operating system (client)
lpd.prg         Printer spooler daemon. GEM executable to be run in the
                background under a multitasking OS or as an accessory under
                single TOS (server)
lpr-man.txt     Reference page describing lpr.prg
lp-man.txt      Reference page describing lp.dev
lpd-man.txt     Reference page describing lpd.prg
readme.txt      This file

Enjoy it!
Thomas

@


1.2
log
@Added TaTa for lp.dev
@
text
@d1 2
a2 1
Readme.txt for Thomas' lpr remote printing client.                 1999-11-08
d5 1
a5 1
What is this?
d7 3
a9 2
Have you linked your Atari-ST compatible computer to other machines with a
network and want to print on a printer connected to a remote computer?
d13 3
a15 1
-	Atari-ST compatible machine running a TOS compatible OS
d17 1
a17 1
-	Peter Rottengatters STinG TCP/IP stack up and running
d19 2
a20 1
-	Any remote host reachable via TCP/IP with lpd spooler daemon running.
d23 2
a24 3
This package contains a little program called lpr. It closely resembles the 
line printer client software that comes with most TCP/IP networking software, 
for example in Linux.
a25 2
If, in addition you are running MagiC, version 5 or later, you get the additional
capability to print directly using a networked printer device.
a26 2


d29 1
a29 1
You should have the archive file TRLPR10B.LZH consisting of the following 
d32 11
a42 6
lpr.txt		Installation instructions, license. Please read this too!
lpr.ttp		TOS executable to be run from the command line
lpr-man.txt	Un*x style manual page describing lpr.ttp command line options
lp.dev		Device driver with lpr functionality to use under the MagiC operating system
lp-man.txt	Un*x style manual page describing lp.dev
readme.txt	This file
@


1.1
log
@Initial revision
@
text
@d1 1
a1 1
Readme.txt for Thomas' lpr remote printing client.                 1998-11-10
d22 2
d26 1
d29 1
a29 1
You should have the archive file TRLPR09B.LZH consisting of the following 
d34 3
a36 1
lpr-man.txt	Un*x style manual page describing command line options
@
