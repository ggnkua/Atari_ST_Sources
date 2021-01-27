/* Copyright (c) 2004 - present by H. Robbers Amsterdam.
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
 * pdb.h			defines for the projects database.
 */

#ifndef PDB_H
#define PDB_H

#include <prelude.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ahcm.h>

#include "common/hierarch.h"

typedef enum
{
	TRV_DO     =  1,
	TRV_DEPEND =  2,
	TRV_OUT    =  4,
	TRV_IN     =  8,
	TRV_HD     = 16
}DFLGS;

typedef struct pdb
{
	struct pdb *pnext, *less, *great;
	long line_number;
	short scope, file_number;
	short n;
	ushort flags;
	const char name[0];
} PDB;

typedef struct pdb_base
{
	PDB *cur, *first, *last;
} PDB_BASE;

typedef struct dep
{
	struct dep *dnext,
	           *depend;		/* non recursive */
/*	struct dep *ddeep;		/* recursive (atm not set, hence not used :-) */
*/	PDB *data;
} DEP, *DPP;

extern DPP auto_dependencies,
           prj_dependencies,
           fun_dependencies;
extern PDB_BASE identifiers;
extern PDB_BASE filenames;
extern bool dep_changed;
extern short filecount, high_prj;
extern S_path depfn, mkfn;

void 	pdb_mark			(DPP dp, short mark, short fu);
void	pdb_init			(void);
void	pdb_list			(FILE *fp, DPP dp, short lvl);
DPP 	pdb_find			(DPP root, Cstr name);
DPP 	pdb_new				(DPP *in, Cstr name);
void 	pdb_fileno			(DPP  dp, short count);
Cstr	pdb_file_by_number	(DPP  root, short number);
void	pdb_free_dep		(void);
void	pdb_write_dep		(void);
DPP  	pdb_read_dep		(void);
PDB *	pdb_find_ide		(PDB_BASE *ides, Cstr n);
PDB *	pdb_new_ide			(PDB_BASE *ides, Cstr ide, short file, long line, short ty);
void	pdb_list_ides		(FILE *fp, PDB *x);
void	pdb_list_ordered	(FILE *fp, PDB *x, char arrow, short lvl);
void	pdb_fdepend			(DPP *, Cstr, Cstr, short, short);
void	pdb_depend			(DPP *, Cstr, Cstr);
#endif
