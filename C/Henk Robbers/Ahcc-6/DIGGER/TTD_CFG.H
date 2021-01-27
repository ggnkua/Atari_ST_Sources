/*  Copyright (c) 1996 - 2008 by Henk Robbers Amsterdam.
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

/*	TTD_CFG.H
 *	=========
 */



extern TTD_PROF DIS_cfg;
extern TTD_CFG  DIS_cf;
extern D_CFG    dcfg,
                icfg;
extern char fx[];
extern bool startfiles;

void	init_ttdcfg		(KIT_REFS *k);
VpV 	load_disconfig, save_disconfig;
void	wincfg_to_tree	(KIT_REFS *k, TTD_PROF *w);
void	tree_to_wincfg	(KIT_REFS *k, TTD_PROF *w);
void	tree_to_cfg		(KIT_REFS *k, CONFIG *w);
void	cfg_to_tree		(KIT_REFS *k, CONFIG *w);
void	trans_vis		(TTD_PROF *c, CHARSET *new);
