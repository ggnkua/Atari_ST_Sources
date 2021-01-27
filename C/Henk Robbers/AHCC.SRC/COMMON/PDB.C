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
 * pdb.c			the projects database.
 */

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <tos.h>
#include "mallocs.h"
#include "aaaa_lib.h"
#include "hierarch.h"

#include "aaaa_ini.h"
#include "pdb.h"
#include "config.h"
#include "shell/shlcfg.h"
#include "ipff.h"
#include "qmem.h"

MEMBASE pdb_mem;

DPP auto_dependencies = nil,
    prj_dependencies = nil,
    fun_dependencies = nil;

PDB_BASE identifiers = { nil, nil, nil },
         filenames   = { nil, nil, nil };		/* 04'09 */

bool dep_changed = false;

void	send_msg	(Cstr text, ...);

static
void ftab(FILE *fp, short lvl)
{
	if (lvl > 0)
		while (lvl--)
			fprintf(fp, "\t");
}

global
void pdb_list(FILE *fp, DPP root, short lvl)
{
	DPP dp = root;
	if (fp eq stdout)
	{
		while (dp)
		{
#if 0
			send_msg("%d>[%d]%s\n", lvl, dp->data->file_number, dp->data->name);
#else
			send_msg("%d>%s\n", lvl, dp->data->name);
#endif
			pdb_list(fp, dp->depend, lvl + 1);
			dp = dp->dnext;
		}
	othw
		if (root)
		{
			ftab(fp, lvl - 1);
			fprintf(fp, "{\n");
		}
		while (dp)
		{
			ftab(fp, lvl);
			fprintf(fp, "[%d]%s\n", dp->data->file_number, dp->data->name);
			pdb_list(fp, dp->depend, lvl + 1);

			dp = dp->dnext;
		}
		if (root)
		{
			ftab(fp, lvl - 1);
			fprintf(fp, "}\n");
		}
	}
}

static
void pdb_free_files(DPP root)
{
	DPP dp = root;

	while (dp)
	{
		DPP nx = dp->dnext;
		pdb_free_files(dp->depend);
		free(dp);
		dp = nx;
	}
}

global
void pdb_list_ides(FILE *fp, PDB *x)
{
	while (x)
	{
		if break_in
			break;

		if (fp eq stdout)
			send_msg("%5d [%d/%ld]\t%s\n", x->n, x->file_number, x->line_number, x->name);
		else
		{
			fprintf(fp, "\t[%d/%ld", x->file_number, x->line_number);
			if (x->scope)
				fprintf(fp, ",%d", x->scope);
			fprintf(fp,"]%s\n", x->name);
		}
		x = x->pnext;
	}
}

global
void pdb_list_ordered(FILE *fp, PDB *x, char arrow, short lvl)
{
	if (x)
	{
		if (fp eq stdout)
		{
			if break_in
				return;

			pdb_list_ordered(fp, x->less,  '<', lvl + 1);
#if 0
			send_msg("%d>%c[%d/%ld]\t%s\t%d\n", lvl, arrow, x->file_number, x->line_number, x->name, x->n);
#else
			send_msg("%5d [%d/%ld]\t%s\t\n", x->n, x->file_number, x->line_number, x->name);
#endif
			pdb_list_ordered(fp, x->great, '>', lvl + 1);
		othw
			pdb_list_ordered(fp, x->less,  0, lvl + 1);
#if 0
			ftab(fp, lvl - 1);
#endif
			fprintf(fp, "\t[%d/%ld", x->file_number, x->line_number);
			if (x->scope)
				fprintf(fp, ",%d", x->scope);
			fprintf(fp,"]%s\n", x->name);
			pdb_list_ordered(fp, x->great, 0, lvl + 1);
		}
	}
}

global
DPP pdb_find(DPP root, Cstr name)
{
	DPP dp = root;

	while (dp)
	{
		if (strcmp(name, dp->data->name) eq 0)
			return dp;

		dp = dp->dnext;
	}

	return dp;
}

global
void pdb_fdepend(DPP *tto, Cstr toname, Cstr name, short fileno, short which)
{
	DPP to = *tto, dp, root;

	dp = pdb_find(to, name);

	if (!dp)
	{
		dp = pdb_new(tto, name);
		pdb_fileno(dp, fileno);
	}

	if (dp)
	{
		if (toname)
		{
			root = pdb_find(to, toname);

			if (root)
			{
				DPP ddp = pdb_find(root->depend, name);

				if (!ddp)
				{
					short fc = dp->data->file_number;
					DPP pp = pdb_new(&root->depend, name);
					pdb_fileno(pp, fc);
				}
			}
		}
	}
}

global
void pdb_depend(DPP *tto, Cstr toname, Cstr name)
{
	DPP to = *tto, dp, root;

	dp = pdb_find(to, name);

	if (!dp)
		dp = pdb_new(tto, name);

	if (dp)
	{
		if (toname)
		{
			root = pdb_find(to, toname);

			if (root)
			{
				DPP ddp = pdb_find(root->depend, name);

				if (!ddp)
					pdb_new(&root->depend, name);
			}
		}
	}
}

#if 0
static
void dep_change(bool b)
{
	if (b ne dep_changed)
		send_msg("dep_changed --> %d\n", b);
	dep_changed = b;
}
#else
#define dep_change(b) dep_changed = b
#endif

global
DPP pdb_new(DPP *in, Cstr name)
{
	DPP last,dp;

	last = *in;
	dp   = xcalloc(1,sizeof(*dp), AH_PRJ);

	if (!dp)
		send_msg("ran out of memory for project database\n");
	else
	{
		dp->data = pdb_new_ide(&filenames, name, 0, 0, 0);
		if (dp->data)
		{
			if (last)
			{
				while(last->dnext)
					last = last->dnext;
				last->dnext = dp;
			}
			else
				*in = dp;

			dp->dnext = nil;
			dp->depend = nil;				/* later */
		}
		dep_change(true);
	}

	return dp;
}

global
void pdb_fileno(DPP dp, short count)
{
	if (dp)
	{
		if (count < 0)
			dp->data->file_number = ++filecount;
		else
		{
			dp->data->file_number = count;
			if (count > filecount)
				filecount = count;
		}
	}
}

global
Cstr pdb_file_by_number(DPP root, short number)
{
	DPP dp = root;

	while (dp)
	{
		if (dp->data->file_number eq number)
			return dp->data->name;
		dp = dp->dnext;
	}

	return "~~~";
}

global
void pdb_init(void)
{
	init_membase(&pdb_mem, 8192, 0, "pdb memory base", nil);
	auto_dependencies = nil;
	prj_dependencies  = nil;
	fun_dependencies  = nil;
	identifiers.cur   = nil;
	identifiers.first = nil;
	identifiers.last  = nil;
	filenames.cur     = nil;
	filenames.first   = nil;
	filenames.last    = nil;
	dep_change(false);
	filecount = 0;
}

global
void pdb_free_dep(void)
{
	XA_free_all(nil, AH_PDB, -1);
	pdb_free_files(auto_dependencies);
	pdb_free_files(prj_dependencies);
	pdb_free_files(fun_dependencies);
	auto_dependencies = nil;
	prj_dependencies = nil;
	fun_dependencies  = nil;
	free_membase(&pdb_mem);
	identifiers.cur   = nil;
	identifiers.first = nil;
	identifiers.last  = nil;
	filenames.cur     = nil;
	filenames.first   = nil;
	filenames.last    = nil;
	filecount = high_prj;		/* reset highest file number */
	dep_change(false);
}

global
void pdb_write_dep(void)
{
	FILE *fp;
	char buf[8200];
#if GEMSHELL
	mbumble;
#endif
	fp = fopen(depfn.s, "w");
	setvbuf(fp, buf, _IOFBF, 8192);			/* set full buffereing (Doesnt flush at newline!!!) */
	if (fp eq nil)
		send_msg("Cant create %s\n", depfn.s);
	else
	{
		extern Cstr ahcc_version;
		fprintf(fp, "ahcc_dep AHCC %s project database\n", ahcc_version);
		fprintf(fp, "files %d\n", filecount);
		fprintf(fp, "dependencies\n");
		pdb_list(fp, auto_dependencies, 1);
		if (identifiers.first)
		{
			fprintf(fp, "\nidentifiers\n{\n");
			pdb_list_ides(fp, identifiers.first);
			fprintf(fp,"}\n");
		}
#if FU_TREE
		if (fun_dependencies)
		{
			fprintf(fp, "\ncall_tree\n");
			pdb_list(fp, fun_dependencies, 1);
		}
#endif
		fclose(fp);
	}

	if (SHL_cfg.v)
		send_msg("saved dependencies %s\n", depfn.s);
#if GEMSHELL
	mpijl;
#endif
}

static
void match_prj(char *fn, short fileno)
{
	DPP x = pdb_find(prj_dependencies, fn);
	if (x)
	{
		if (x->data->file_number ne fileno)
			x->data->file_number = fileno;
	}
}

static
void match_deps(DPP deps)
{
	if (deps)
	{
		DPP jp = prj_dependencies;

		while (jp)
		{
			Cstr fn = jp->data->name;
			short fileno = jp->data->file_number;

			DPP x = pdb_find(deps, fn);

			if (x eq nil)		/* new file in project */
			{
				Cstr f;
				f = pdb_file_by_number(deps, fileno);		/* is the number in use? */
				if (*f ne '~')
					jp->data->file_number = ++filecount;
			}

			jp = jp->dnext;
		}
	}
}

static
DPP pdb_read(short lvl, bool f)
{
	DPP deps = nil;

	do{
		if (sk() eq '[')
		{
			DPP this;
			short fileno = 0; char fn[256];
			if (sk() eq '[')
			{
				skc();
				fileno = idec();
				if (f)
					if (fileno > filecount)			/* 04'09 */
						filecount = fileno;
				if (sk() eq ']') skc();
			}
			fstr(fn);
			this = pdb_new(&deps, fn);
			pdb_fileno(this, fileno);
			if (lvl eq 0)
				match_prj(fn, fileno);		/* transfer autodep filename to prj */
			if (sk() eq '{')
			{
				skc();
				if (this)
					this->depend = pdb_read(lvl + 1, f);
				if (sk() eq '}') skc();
			}
		}
		else
			break;
	}od

	return deps;
}

static
short cmp;
static
Cstr r;
static
PDB *last;

static
short bfind_ide(PDB *x)
{
	if (x)
	{
		last = x;
		if (r eq x->name) return 0; /* same address is surely equal */
		cmp = strcmp(r, x->name);
		if (cmp < 0)
			return bfind_ide(x->less);
		if (cmp > 0)
			return bfind_ide(x->great);
	}
	return cmp;
}

global
PDB *pdb_find_ide(PDB_BASE *ides, Cstr n)
{
	cmp = 1;
	last = nil;
	r = n;
	cmp = bfind_ide(ides->cur);
	return cmp eq 0 ? last : nil;
}

static
void ins_ide(PDB_BASE *ides, PDB *x)
{
	if (ides->cur)
	{
		if (cmp < 0)
			last->less = x;
		else
			last->great = x;
	}
	else
		ides->cur = x;

	if (ides->first eq nil)
	{
		ides->first = ides->last = x;
		x->n = 1;
	othw
		x->n = ides->last->n + 1;
		ides->last->pnext = x;
		ides->last = x;
	}

	x->pnext = nil;
}

void console(char *,...);

global
PDB * pdb_new_ide(PDB_BASE *ides, Cstr ide, short file, long line, short scope)
{
	PDB *x = pdb_find_ide(ides, ide);
	if (x)
	{
		if (scope > x->scope)			/* keep highest scope */
		{
			x->scope = scope;
			x->line_number = line;
			x->file_number = file;
			dep_change(true);
		}
		elif (    scope eq x->scope
		      and scope ne -1
		      and(x->line_number ne line or x->file_number ne file))
		{
			x->line_number = line;
			x->file_number = file;
			dep_change(true);
		}
	/*	else
			unchanged */
	othw
		short l = strlen(ide);
		x = qalloc(&pdb_mem, sizeof(*x) + l + 1);
		if (x)
		{
			x->line_number = line;
			x->file_number = file;
			x->scope = scope;
			x->flags = 0;
			strcpy((Wstr)x->name, ide);
			x->less = nil;
			x->great = nil;
			ins_ide(ides, x);
			dep_change(true);
		}
		else
			console("ran out of memory on help database\n");
	}

	return x;
}

static
void pdb_read_ides(PDB_BASE *ides)
{
	ides->cur = nil;

	if (sk() eq '{')
	{
		skc();

		do{
			if (sk() eq '[')
			{
				char rstr[IPFF_L + 2];
				short fileno = 0, ty = 0;
				long lineno = 1;

				skc();
				fileno = idec();
				if (sk() eq '/')
				{
					skc();
					lineno = dec();
				}
				if (sk() eq ',')
				{
					skc();
					ty = idec();
				}
				if (sk() eq ']') skc();
				str(rstr);
				if (*rstr)
					pdb_new_ide(ides, rstr, fileno, lineno, ty);
			}
			else
				break;
		}od

		if (sk() eq '}') skc();
	}
}

global
DPP pdb_read_dep(void)
{
	short fl;
	long l;
	char *s;
	DPP deps = nil;

#if GEMSHELL
	mbumble;
#endif

	s = Fload(depfn.s, &fl, &l, AH_PDB);
	if (s)
	{
		char rstr[IPFF_L + 2];

		if (SHL_cfg.v)
			send_msg("Loading %s\n", depfn.s);

		ipff_in(s);
		sk();
		str(rstr);
		if (strcmp(rstr,"ahcc_dep") eq 0)
		{
			sknl();
			str(rstr);
			if (strcmp(rstr, "files") eq 0)
			{
				sk();
				filecount = idec();
				sk();
				str(rstr);

				if (strcmp(rstr, "dependencies") eq 0)
				{
					if (SHL_cfg.v)
						send_msg("%s present\n", rstr);
					if (sk() eq '{')
					{
						skc();
						deps = pdb_read(0, true);
						if (sk() eq '}') skc();
					}
				}

				sk();
				str(rstr);
				if (strcmp(rstr, "identifiers") eq 0)
				{
					if (SHL_cfg.v)
						send_msg("%s present\n", rstr);
					pdb_read_ides(&identifiers);
				}

	#if FU_TREE
				sk();
				str(rstr);
				if (strcmp(rstr, "call_tree") eq 0)
				{
					if (SHL_cfg.v)
						send_msg("%s present \n", rstr);
					if (sk() eq '{')
					{
						skc();
						fun_dependencies = pdb_read(0, false);
						if (sk() eq '}') skc();
					}
				}
	#endif
				ffree(s);
				dep_change(false);
				match_deps(deps);		/* renumber new project files not in auto_dependencies */

	#if GEMSHELL
				mpijl;
	#endif
				return deps;
			}
		}

		ffree(s);
		send_msg("Format error in %s\n", depfn.s);
	}
	else
		send_msg("No dependencies for %s\n", mkfn.s);

	dep_change(false);

#if GEMSHELL
	mpijl;		/* marrow() */
#endif
	return nil;
}
