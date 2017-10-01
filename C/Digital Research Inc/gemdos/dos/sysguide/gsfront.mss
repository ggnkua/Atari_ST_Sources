@part(gsfront.mss,root='sysroot.mss')
@preface[Foreword]

GEM DOS@+[TM] is a single-user, single-tasking operating system designed for 
the Motorola.. MC68000@+[TM] or compatible microprocessors.  This guide
describes the machine-level interface to GEM DOS, and is intended for
Original Equipment Manufacturers (OEMs) and others who want to implement 
GEM DOS on different computer systems.

@prefacesection[Audience]

This guide assumes you are an experienced systems programmer familiar with the 
Motorola 68000 assembly language and the C programming language.  If you 
are not familiar with GEM DOS, refer to the manuals listed at the end of
this foreword, especially 
the @ux[GEM DOS User's Guide].  If you are not familiar with the Motorola 
68000 assembly language or the C programming language, refer to the 
following manuals:

@begin(itemize)
@ux[16-Bit Microprocessor User's Manual], third edition MC68000UM(AD3)

@ux[MC68000 Resident Structured Assembler Reference Manual] M68KMASM(D4)

@ux[The C Programming Language,] Brian W. Kernigan & Dennis M. Ritchie, 
Prentice Hall Inc., Englewood Cliffs NJ, 07632

@end(itemize)

@prefacesection[Hardware Requirements]

GEM DOS requires the following minimum system configuration:

@begin(itemize,spread=0)
MC68000 or 68000-compatible microprocessor

128K bytes of Random Access Memory (RAM)

I/O device such as a serial terminal, console, with a mouse or other pointing 
device, etc.
@end(itemize)

@newpage
This configuration could more fully utilize GEM DOS capabilities.

@begin(itemize,spread=0)
68010, 68020, or 68070 advanced microprocessor

High-resolution, color bit-mapped display and controller (640 by 400 pixel 
resolution, barrel-shifter hardware for very high speed screen refresh)

256K bytes of RAM@foot[GEM DOS supports the full 68000 address range, and 
although it is better suited to contiguous RAM, it will support limited
fragmentation.]

Mouse or other pointing device

Disk drives and associated hardware

Optical drives and associated hardware

Printer and communication ports
@end(itemize)

@prefacesection[Software Requirements]

The main software tools referred to in this document are as follows:
@begin(list)

Alcyon C Compiler, CP68, C068 & C168

Alcyon Assembler, AS68

Digital Research Linker, LINK68 

Digital Research Linker/Loader, LO68

Digital Research Archive Utility, AR68

@end(list)

This document refers to these tools generically as the assembler, compiler, 
linker, etc.  These tools are described in the @ux(GEM DOS Programmer's 
Reference Guide).
 
@prefacesection[What's in this guide]

This guide contains information on the following:
@begin(list)
operating system initialization

system generation

BIOS functions

critical error handling

interrupt-driven character I/O
@end(list)

@prefacesection[More Information about GEM DOS]

This guide is part of a documentation set that also includes these manuals:

@begin(itemize)
The @ux[GEM DOS User's Guide]

The @ux[GEM DOS Programmer's Reference Guide]

The @ux(C Language Programming Guide for GEM DOS) (supplement to the 
@ux<C Language Programming Guide for CP/M-68K>@+[TM])

The @ux[Kermit User's Guide] prepared by Columbia University Center for 
Computing Activities

The @ux[GEM DOS Supplement to the Kermit User's Guide]
@end(itemize)

