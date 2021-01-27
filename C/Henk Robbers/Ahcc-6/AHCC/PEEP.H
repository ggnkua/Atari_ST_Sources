/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Tony Andrews
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
 *	peep.h
 */

void	peep	(BP);

bool	not_cc	(IP,BP),
		peep2	(BP),
		peep3	(BP),
		p2_sets	(IP, ACC),
		p2_refs	(IP, ACC),
		p2_uses	(IP, ACC);

void	rhealth			(BP bp);
bool 	change_all_reg	(BP bp, short to, short fro);
bool	reg_used		(BP bp, IP ip, RMASK regs);
bool 	reg_changed		(BP bp, IP ip, short reg1, short reg2);
bool	change_reg		(IP ip, short to, short fro);
bool	coldfire_ok		(IP ip, OPND *, OPND *, short);
