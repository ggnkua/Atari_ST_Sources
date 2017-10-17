VDI test
--------

VDI graphics output functionality test suite for testing (mainly)
EmuTOS VDI functionality and demonstrating its current & past bugs.

Code is tested with AHCC and VBCC/GEMlib, so I would assume it
to work fine also with GCC.

(C) 2011-2014 by Eero Tamminen.  Licensed under GPLv2+ (like EmuTOS).


Files
-----

- readme.txt -- this file
- Makefile   -- build file for doing gcc tests
- hmake      -- Hatari console script for building
- *.prj      -- AHCC build files

- contour.c  -- tests for VDI contour filling
- cos.h      -- cosine integer fraction lookup table
- fvdibug.c  -- tests for couple of fVDI specific bugs
- vdiblit.c  -- TODO: tests for VDI area blits
- vdicolor.c -- tests for VDI color setting/query
- vdifill.c  -- tests for filled VDI objects
- vdiline.c  -- tests for VDI line drawing operations
- vdimark.c  -- tests for VDI markers
- vditext.c  -- tests for VDI text functionality
- vdiutil.c  -- common functions for the tests
- vdiutil.h  -- header for above


Changelog
---------

2014-09-18:
- in vditext.c, output extents instead of char & cell height
- in vdifill.c, make objects smaller (not overlap) and
  additional pizza & pieslices to decrease, not just rotate
  (to demonstrate EmuTOS bug on small slices)

2013-10-06:
- really fix evnt_multi() time bug

2013-01-26:
- Fixed evnt_multi() timer bug and AHCC fvdibug.c compile
  issue introduced yesterday
- Added GCC support and fixed all new warnings
- Main Makefile is now for GCC/VBCC, AHCC one is Makefile.ahc
- Added fraction lookup table for sin/cos so that contour fill
  test doesn't need floating point

2013-01-25:
- Added contour.c contour filling test
- Made everything build with VBCC/GEMlib
  and added separate Makefile for VBCC
  - MTOS menu kludge is enabled only for AHCC

2012-09-12:
- Improved multitasking AES kludges

2012-09-10:
- Add fvdibug.c tests for fVDI specific bugs
- Use AES for input instead of BIOS and remove
  VDI call that crashes fVDI
- Add kludges (menu) necessary for getting screen fully
  redrawn with multitasking AES after program exits

2012-04-16:
- patch from Roger Burrows to remove C99 bool usage
  and to modify text tester a bit

2011-11-19:
- add vdimark.c markers test code
- rename vdilines.c to vdline.c

2011-11-18:
- add vdifill.c fill tests code

2011-11-13:
- add vditext.c text tests code

2011-11-11:
- have separate test program for each VDI functionality area;
  move color tests to vdicolor.c and common utility functions
  to vdiutil.c, rename remaining vditest.c code to vdilines.c
- add (elliptical) arc tests to vdilines.c
- add this readme

2011-10-19:
- add preliminary color tests

2011-10-13:
- text + mouse cursor & color setting & pixel check tests

2011-10-06:
- add clipping and writing mode change

2011-09-18:
  - first vditest.c version with line drawing test
