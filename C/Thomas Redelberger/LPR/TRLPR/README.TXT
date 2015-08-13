Readme.txt for Thomas' lpr remote printing clients and server.     
2000-06-03


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

You should have the archive file TRLPR11.LZH consisting of the following
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

