VolksForth Readme

Version 1.0
10. August 2005 (cas)

VolksForth is a 16bit Forth System produced by the german Forth Gesellschaft
e.V. Main development of this system was done between 1985 until 1989. The
VolksForth Project was revived in 2005 with the goal to produce a managable
Forthsystem for computer systems with restricted system resources. 

Some modern Forth Systems were influenced by or were derived from VolksForth
(GNU-Forth, bigForth).

The current Version of VolskForth is 3.81. Work on Version 3.90 has started.

At this time VolksForth is available for this Systems:

VolksForth MS-DOS (Intel x86 Architecture i8086-ia64)
VolksForth 6502 (Commodore 64, Commodore Plus 4)
VolksForth Z80 (CP/M, Schneider CPC)
VolksForth 68000 (Atari ST)

Copyright

The VolksForth Sources are made available under the terms of the
BSD Lizenz - http://www.opensource.org/licenses/bsd-license.php

The Handbook is Copyright (c) 1985 - 2005 Forth Gesellschaft
e.V. ( Klaus Schleisiek, Ulrich Hoffmann, Bernd Pennemann, Georg Rehfeld
and Dietrich Weineck).

The Handbook, binary Files and Sourcecode for VolksForth as well as Information
about Forth Gesellschaft are available on the Forth Gesellschaft Webserver at
http://www.forth-ev.de/

(most of the Information is still in german. We are planning to provide future
versions with englisch documentation)

Information and Help about the Programming Language Forth can be found in the
Internet, starting with the Website of the Forthgesellschaft, or in the Usenet Forum
de.comp.lang.forth (via Google Groups: http://groups.google.de/group/de.comp.lang.forth )

Details on VolksForth 68000 (Atari ST)

* Requirements
  Atari ST with at least 520 KB RAM, Floppy or Harddisk

* Files 

  This is list of VolksForth Files in this Distribution. Shadowscreens
  with additional Information are marked with (*).

     ASSEMBLE.SCR   the volksFORTH-83 Assembler.
     RELOCATE.SCR * Relocator to adapt the System to use more or less
                    Diskbuffers and therefor more or less memory for the
                    Forth Dictionary
     ALLOCATE.SCR * contains OS-Libraryroutines to allocate and free
                    memory
     DIVERSES.SCR * small, often used definitions
     FORTHKER.PRG   contains the Forth-Kernel including the Fileinterface.
     EDIICON.SCR    Definitions for the Editor-Resource; created with the 
                    Resource Construction Set
     EDITOR.SCR   * the GEM-Editor.
     EDWINDOW.SCR * the window for the editor
     STRINGS.SCR  * Basic String-Operations
     STARTUP.SCR    Loadscreen to create a work-system
     TOOLS.SCR      Decompiler and Tracer.
     INDEX.SCR    * Definition of the Word "INDEX".
     PRINTER.SCR  * Printer-Interface.
     FORTH_83.SCR   Sourcecode of the VolksForth 3.81
     DISASS.SCR     the Disassembler.
     FILEINT.SCR  * the File-Interface.
     LINE_A.SCR   * the Basic Words for Line_A Graphic.
     DEMO.SCR       Graphic-Demos with Line_A Graphic.
     TASKER.SCR     the Multitasker.
     RAMDISK.SCR  * With this RAM-Disk free RAM outside the Forth System
                    can be used for Diskbuffers
     TUTORIAL.SCR   A short Tutorial for the Editor
     ERRORBOX.SCR * reroutes Errormessages into Alter-Boxes. Example for
                    the use of Alert Boxes from Forth

     Subdirectory GEM

     BASICS.SCR     Basic Words, Definition of Arrays etc.
     VDI.SCR        the VDI-Library.
     AES.SCR        the AES-Library.
     GEMDEFS.SCR    Definitions for Windows Parameters and Labels
     SUPERGEM.SCR * useful words to ease the use of GEM

* Installation
  Copy the Diskimages to Atari Disks (360KB) or copy the files from the "Harddisk"
  directory to harddisk or on Disks. Start the Program File "4th.prg" from TOS.

* Emulator
  VolksForth Atari ST 3.81 has been tested in the Atari ST Emulator "HATARI"
  (hatari.sourceforge.net) with EmuTos (emutos.sourceforge.net). VolksForth 3.81 has
  some display problems with screen resolutions above 640x480. We try to solve this in
  later versions.

The Forth Live-Linux CD-ROM (available in the Downloadsection of the Forth
Gesellschaft Website) includes the current Versions of VolksForth direct usable
without Installation including the Handbooks as PDF-Files.

Have fun with VolksForth
the VolksForth Team


