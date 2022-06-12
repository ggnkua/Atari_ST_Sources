TI68k on Atari ST "Emulation"

 by Orion_ 07/2013


TI68k refers to TI89/TI92+/V200 etc...
These graphic calculators have a 68k as main processor (@12mhz)

This is an attempt at running TI68k program files on an Atari ST only using an overlay emulation (because it have the same processor)
The 'overlay' is, doing screen conversion on the fly (using the VBL interrupt) and rewriting the ROMCalls table that TI68k use.

This ROMCalls table contains functions that TI68k programs use to interact with the TI hardware.
The pointer of this table is at $C8 and can also be called using line F.

The ROMCalls table is huge and rewriting everything is really hard work.
But PpHd rewrote a complete OS for the TI68k from scratch, so, such routines exist and are available in the Pedrom project.

I used some of these routines in this project (see rc***.s files)
I made some modification to the routines for them to compile with vasm and this project.

ROMCalls routines from:
PedroM - Operating System for Ti-89/Ti-92+/V200.
Copyright (C) 2003, 2005-2008 Patrick Pelissier


For now it only runs very small asm only programs I made (see 89z folder)
Unfortunately I don't have enough knowledge of internal TI68k working to complete this emulator for the moment.
That's why I'm releasing the source, maybe someone can help me :)


Note: "mylib.s" is my general initialisation and utils library for the Atari ST computer.
