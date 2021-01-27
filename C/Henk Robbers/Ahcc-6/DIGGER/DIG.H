/*  (c) 1987 - 1991 by Han  Driesen Leiden.
 *  (c) 1996 - 2008 by Henk Robbers Amsterdam.
 *
 * This file is part of Atari Digger.
 *
 * Digger is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Digger is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Digger; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*	DIGGER.H
 *	========
 */

extern M_S dmen;
extern COPRMSG ttd_msg;

VpV		end_disass,
		listconfig,
		switch_namA,
		write_incA;
void	save_incA		(short);
void	en_disass		(bool en);
FCLOSE	close_disass;
void	do_Ocopyright	(void);
void	load_dcfg		(void);
bool	locate			(bool *cfg, char *path, char *name, short msg);
void	dis_local		(IT *w);
IT *	make_w			(char *fn, short fl, D_CFG *q);
void	cleanup			(IT *w);
void	split_fn		(IT *w, char *fn);
void	get_Dwork		(IT *w);
