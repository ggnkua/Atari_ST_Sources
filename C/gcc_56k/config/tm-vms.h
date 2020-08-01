/* Output variables, constants and external declarations, for GNU compiler.
   Copyright (C) 1988 Free Software Foundation, Inc.

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

#include "tm-vax.h"

#undef CPP_PREDEFINES
#undef TARGET_VERSION
#undef TARGET_DEFAULT
#undef CALL_USED_REGISTERS
#undef MAYBE_VMS_FUNCTION_PROLOGUE

/* Predefine this in CPP because VMS limits the size of command options
   and GNU CPP is not used on VMS except with GNU C.  */
#define CPP_PREDEFINES "-Dvax -Dvms -DVMS -D__GNU__ -D__GNUC__"

/* By default, allow $ to be part of an identifier.  */
#define DOLLARS_IN_IDENTIFIERS 1

#define TARGET_DEFAULT 1
#define TARGET_VERSION fprintf (stderr, " (vax vms)");

#define CALL_USED_REGISTERS {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1}

#define MAYBE_VMS_FUNCTION_PROLOGUE(FILE)	\
{ extern char *current_function_name;		\
  if (!strcmp ("main", current_function_name))	\
    fprintf(FILE, "\tjsb _c$main_args\n"); }

#define ASM_OUTPUT_EXTERNAL(FILE,DECL,NAME)		\
{ if (DECL_INITIAL (DECL) == 0 && TREE_CODE (DECL) != FUNCTION_DECL)	\
    fprintf (FILE, ".comm _%s,0\n", NAME); }
