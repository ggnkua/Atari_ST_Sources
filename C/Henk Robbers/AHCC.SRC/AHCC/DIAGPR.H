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
 *	diagpr.h
 */

VpV		printtoks;
void	printnode(void *vp, bool wait);
void	print_node(void *vp, char * t, bool wait, bool dbgT);	/* No debugN */
VpT		printlist;
VpN		pm_print,
		frcprnode;

void	postmort	(char *to, void *va, short n, bool printable),
		pnode_1		(void *vp, Cstr txt, bool wait);

Cstr	preg		(short r),	/* diagnostic */
		ptok		(short ty),
		prtok		(void *),
		pntype		(short ty),
		petype		(NP np),
		psclass		(NP sc),
		prcntxt		(short context),
		pcoflags    (short flags),
		pdoflags	(short flags),
		preflags	(short flags),
		pclflags	(short flags),
		pty			(short sty);

Cstr	sss			(Cstr);
