Compiling Instructions for ScoreST

ScoreST was compiled using Laser C V2.1. If you have Laser C, you shouldn't
have too much trouble compiling ScoreST. If you don't, you may run into these
problems:

	1) Language incompatibilities

	2) Library incompatibilities

Each of these is described below.

Language Incompatibilities:

ScoreST is written in straight Kernighan and Ritchie C, with a few 
exceptions:

	1) The file graphics.h contains enumerated types ("enums").

	2) The file entity.c contains a function (copyEnt) that uses
	   inline assembler.

	3) The variable names are not guarenteed to be unique within the
	   first 8 characters.

	4) The type "void" is used (though not consistently) for functions that
	   don't return anything.

	5) Laser C requires that functions declared "static" be declared or
	   defined before they're referenced. This may confuse other compilers.

Library Incompatibilities:

Laser C provides a comprehensive library that may include functions not
available with other compilers. Most notably, these are the Unix compatible
functions.

The Unix compatible functions are used for file I/O, memory copying and
comparison, string manipulation, and transcendental math. Some of these may
be provided with the public domain "Sozobon" C compiler library.


Source Files:

Here's a brief tour through the ScoreST source files:

config.h: Definitions used to read and write SCOREST.CFG

dialog.c: Functions that manipulate Dialogs and Alerts

dialog.h: Definitions needed to use the functions in dialog.c

edit.c: Functions that perform the operations under the "Edit" menu

entity.c: Functions that manipulate "entities". An entity is a symbol drawn
	on a page.

entity.h: Definitions needed to use the functions in entity.c

eventmsg.h: Offsets for the messages returned by event_multi and event_msg

file.c: Functions that perform the operations under the "File" menu

graph.c: Miscelaneous graphics-related functions

graph.h: Definitions needed to use the functions in graph.c

graphics.h: Some standard graphics types and macros

instsst.c: Source to instsst.tos

list.c: Functions that perform opertions on doubly-linked lists. ScoreST uses
	lists to store pages, entities, selected entities, and entities in the
	clipboard.

list.h: Definitions needed to use the functions in list.c

makefile: Script used by the "make" program to build SCOREST.PRG and
	INSTSST.TOS. If you don't have "make", this file won't be of much
	use except to tell you what must be linked together to build these
	programs.

menu.c: Functions that perform operations on menus. These functions enable
	and disable menu items based on the context and support keyboard
	equivalents for menu selections.

menu.h: Definitions needed to use the functions in menu.c

mylib.h: Some standard types and macros

option.c: Functions that perform the operations under the "Options" menu

page.c: Functions that perform operations on pages. Each page contains a list
	of the entities appearing on it. A ScoreST file is a list of pages.

page.h: Definitions needed to use the functions in page.c

printer.c: Functions used to print scores. ScoreST uses the same clumsy print
	scheme used by many paint programs: it draws each page on a virtual
	screen, then prints the bits from the virtual screen. The code inside
	this file has been highly optimized for speed.

scoredef.h: General constants used throughout the program.

scorest.c: The ScoreST mainline. Functions in this file set the program up
	and catch and dispatch events.

scorest.def: File used by the Laser C resource editor. I'm not sure if this
	file can be read by other resource editors.

scorest.h: Object names produced by the Laser C resource editor.

select.c: Functions that select entities and perform operations on selected
	entities. Selected entities are stored in a list.

symbol.c: Functions that perform operations on symbols. A symbol is the
	template for an entity -- it describes an entity in a general way,
	but doesn't actually exist (a symbol is like a cookie cutter, and an
	entity is like a cookie).

symbol.h: Definitions needed to use the functions in symbol.c

test.sco: A test file containing an entity of each type.

util.c: Some miscelaneous utility functions.

version.c: The version number and creation date of this ScoreST version

vwk.c: Functions that open and close a virtual workstation. Also contains the
	"idiotic binding" variables.

window.c: Functions that perform operations on the editing window.
