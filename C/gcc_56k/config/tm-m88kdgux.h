/* $Id: tm-m88kdgux.h,v 1.1 91/06/17 14:59:18 pete Exp $ */
/* This file contains changes made by Data General, December 1989.  */

/* Definitions of target machine for GNU compiler.
   Motorola m88100 running DG/UX.
   Copyright (C) 1988, 1989, 1990 Free Software Foundation, Inc.
   Contributed by Michael Tiemann (tiemann@mcc.com)
   Enhanced by Michael Meissner (meissner@osf.org)
   Currently supported by Tom Wood (wood@dg-rtp.dg.com)

   This is not an official release from FSF.  (The integration of
   these changes is expected to occur in version 2.0.)  Please report
   bugs to wood@dg-rtp.dg.com, not to the mailing lists.  If you are a
   DG customer, please be aware that no support is offered with this
   version and that you should report bugs through official channels.

   The current port of GNU CC to the m88100 is available via anonymous
   ftp to dg-rtp.dg.com.  Please be aware that these sources aren't
   expected to support targets other than the m88100.

This file is part of GNU CC.

GNU CC is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

GNU CC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU CC; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.  */

#include "tm-m88k.h"

/* Identify the compiler.  */
#undef  VERSION_INFO
#define VERSION_INFO "88open OCS/BCS, DG-"

/* Default switches */
#undef	TARGET_DEFAULT
#define TARGET_DEFAULT	(MASK_CHECK_ZERO_DIV	 | \
			 MASK_OPTIMIZE_ARG_AREA  | \
			 MASK_OCS_DEBUG_INFO	 | \
			 MASK_OCS_FRAME_POSITION)

/* Macros to be automatically defined.  */
#undef	CPP_PREDEFINES
#define CPP_PREDEFINES "-Dm88000 -Dm88k -Dunix -DDGUX -D__CLASSIFY_TYPE__"

/* If not -ansi, -traditional, or restricting include files to one
   specific source target, specify full DG/UX features.  */
#undef	CPP_SPEC
#define	CPP_SPEC "\
	%{!ansi:%{!traditional:-D__OPEN_NAMESPACE__}} \
	%{ansi:-D__CLASSIFY_TYPE__}"

/* Assembler support (-V, silicon filter, legends for mxdb).  */
#undef	ASM_SPEC
#define ASM_SPEC "\
%{V} %{v:%{!V:-V}} %{pipe: - }\
%{mlegend:-Wc,-fix-bb,-h\"gcc-1.37.29\",-s\"%i\"\
%{traditional:,-lc}%{!traditional:,-lansi-c}\
%{mkeep-coff:,-keep-coff}\
%{mocs-frame-position:,-ocs}\
%{mexternal-legend:,-external}}"

/* Linker and library spec's.  */
#undef	LIB_SPEC
#define LIB_SPEC	"-lc"
/* -static, -shared, -symbolic, -h* and -z* access AT&T V.4 link options.  */
#undef	LINK_SPEC
#define LINK_SPEC "%{static:-dn -Bstatic} %{shared:-G -dy} %{symbolic:-Bsymbolic -G -dy} \
		   %{z*} %{h*} %{V} %{v:%{!V:-V}} %{pg:-L/usr/lib/libp} %{p:-L/usr/lib/libp}"
/* -svr4 instructs gcc to place /usr/lib/values-X[cat].o on link the line  */
#undef	STARTFILE_SPEC
#define STARTFILE_SPEC "%{pg:gcrt0.o%s}%{!pg:%{p:/lib/mcrt0.o}%{!p:/lib/crt0.o}} \
			%{svr4:%{ansi:/lib/values-Xc.o} \
			%{!ansi:%{traditional:/lib/values-Xt.o}%{!traditional:/usr/lib/values-Xa.o}}}"

/* Fast DG/UX version of profiler that does not require lots of
   registers to be stored.  */
#undef	FUNCTION_PROFILER
#define FUNCTION_PROFILER(FILE, LABELNO) \
  output_function_profiler (FILE, LABELNO, "gcc.mcount", 0)

/* DGUX V.4 isn't quite ELF.  */
#undef  VERSION_0300_SYNTAX
#define VERSION_0300_SYNTAX (0)

/* Output the legend info for mxdb.  */
#undef  ASM_FIRST_LINE
#define ASM_FIRST_LINE(FILE)						\
  fprintf (FILE, ";legend_info -fix-bb -h\"gcc-1.37.29\""		\
	       " -s\"%s\" %s\n", main_input_filename,			\
	       (flag_traditional ? "-lc" : "-lansi-c"));		\
