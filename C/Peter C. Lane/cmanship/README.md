# cmanship

This repository contains a selection of the examples from CManShip rewritten,
with appropriate project files, to compile on the
[Firebee](http://acp.atari.org/) and Atari STe using
[AHCC](http://members.chello.nl/h.robbers/).  RSC file are created using 
ResourceMaster.

The main changes are:

* C89 syntax (especially function signatures)
* changes to headers and library calls for compatibility with AHCC

Minor changes to the .PRJ files are needed to compile on other Atari GEM systems.
See files \*ST.\* for examples.

CManShip was written by Clayton Walnum, and is available from AtariForge:

* CManShip [HYP](http://dev-docs.atariforge.org/files/cmanship.hyp)
* CManShip [disk](http://dev-docs.atariforge.org/files/cmanship.zip)

## Contents

* chapter 10: some VDI graphics calls.  (Best run without MINT, so the graphics don't get drawn over.)
* chapter 12: dialog to change mouse pointer.  (Under MINT, dialog disappears with program still running.)
* chapter 13: file selector.
* chapter 16: menu.
* chapter 17: windows 1.
* chapter 18: windows 2 - resizing.
* chapter 20: windows 4 - sliders.
* chapter 22: date/clock dialog.
* chapter 23: date/clock dialog as a desk accessory.  
  Note, rename DATE23.rsh to DATE.rsh before compiling,
  unless you create a new version from RSM.

For chapters 18 and 20 ensure the compiler options have 
'-i include' to use 'gemf.h'.

