Tos040 MC68030 cpu compilation:

Compile the <make68k.c> file with a C-compiler.
It will create a program named <make68k.exe>

Run this program and it will create the following files:

- m68030.asm	The emulator
- comptab.asm	The jump-table used by the emulator

The emulator emulates the MC68030 at approximately
80 Mhz on a Pentium III 800, 64Mhz on a Pentium III 550
and 42Mhz on a PII 350.

The except.asm was ripped out of the m68030.asm to be
able to re-write that part. Unfortunately I did not get
the time to do so.


D68030.asm is a disassembler for the MC68030. It is used
by the debugger, which is reached by pressing the <~> key
or at start-up.


hardware.asm	emulates the Falcon hardware address- and buserrors.

Frans van Nispen,
xlr8@tref.nl,
leden.tref.nl/~xlr00000,
www.Blackend-Software.com.
