/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Johann Ruegg
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
 *		Some usefull prototypes involving node types.
 */

typedef short 	IpV		(void),
				IpI		(short);
typedef void	VpV		(void),
            	VpI		(short),
            	VpL		(long),
            	VpuL	(ulong),
            	VpII	(short, short),
             	VpCa	(Cstr);

typedef NP		NpV		(void),
				NpI		(short),
				NpN		(NP),
				NpT		(TP),
				NpTI	(TP, short),
				NpNI	(NP np, short i),
				NpNN	(NP, NP);
typedef XP		XpV		(void);
typedef TP		TpV		(void),
				TpT		(TP),
				TpTI	(TP, short),
				TpTT	(TP, TP),
				TpNT	(NP, TP),
				TpNTI	(NP, TP, short),
				TpN		(NP),
				TpNI	(NP, short);
typedef void	VpNT	(NP, TP),
				VpN		(NP np),
				VpT		(TP),
				VpIT	(short, TP),
				VpX		(XP),
				VpF		(FP),
				VpNN	(NP, NP),
				VpTT	(TP, TP),
				VpNI	(NP np, short i),
				VpNL	(NP, long),
				VpNII	(NP, short, short),
				VpTI	(TP, short),
				VpNNI	(NP, NP, short);
typedef bool	BpV		(void),
				BpI		(short),
				BpII	(short, short),
				BpN		(NP np),
				BpT		(TP np),
				BpNI	(NP np, short i),
				BpNII	(NP, short, short),
				BpNT	(NP np, TP tp),
				BpTT	(TP, TP),
				BpS 	(Cstr);
typedef short 	IpN		(NP np),
				IpT		(TP);
