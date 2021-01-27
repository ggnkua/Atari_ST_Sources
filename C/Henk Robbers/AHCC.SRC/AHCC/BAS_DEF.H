/* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *		bas_def.h
 */

#define DBAS(n,s,a,ty) {n,s,a,ty},

/* ordered on coercion strength (and must be same order
                    as T_.... tokens in defs.h.
*/

	DBAS("bool",			SIZE_U,	 ALN_U,  ET_B)
	DBAS("char",			SIZE_C,  ALN_C,  ET_S)
	DBAS("unsigned char",	SIZE_C,  ALN_C,  ET_U)
	DBAS("short",			SIZE_S,  ALN_S,  ET_S)
	DBAS("unsigned short",	SIZE_S,  ALN_S,  ET_U)
	DBAS("int",				SIZE_I,  ALN_I,  ET_S)
#if FOR_A
	DBAS(nil,				SIZE_I,  ALN_I,  ET_S)	/* default type ? */
#endif
	DBAS("unsigned int",	SIZE_U,  ALN_U,  ET_U)
	DBAS("long",			SIZE_L,	 ALN_L,  ET_S)
	DBAS("unsigned long",	SIZE_L,  ALN_L,  ET_U)

#if LL
	DBAS("long long",		SIZE_LL, ALN_LL, ET_S)
#endif

	DBAS("pointer to",		SIZE_P,  ALN_P,  ET_P)

#if FLOAT
	DBAS("float",			SIZE_F,	 ALN_F,  ET_R)
	DBAS("real",			SIZE_X,  ALN_X,  ET_R)
#if FOR_A
	DBAS("string",	 SIZE_L+SIZE_P,  ALN_X,  ET_A)
	DBAS("complex", 	  2*SIZE_X,  ALN_X,  ET_A)
#endif
#endif

	DBAS("var_arg",			-1,		0	 , 0)
	DBAS("void",			0,		0	 , 0)
	DBAS("No type",			0,		0	 , 0)	/* used for ZERO */

#undef DBAS
