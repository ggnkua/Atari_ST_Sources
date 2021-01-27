/* Copyright (c) 1990 - present by H. Robbers Amsterdam.
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
 *	SHELL.C
 *
 *  common to GEM shell & TTP shell
 */

#include <tos.h>
#include <ctype.h>
#include <time.h>
#include "common/mallocs.h"
#include "common/aaaa_lib.h"
#include "common/hierarch.h"
#include "common/pdb.h"
#include "common/ipff.h"
#include "common/ahcm.h"
#include "aaaa_ini.h"
#include "common/config.h"
#include "common/dict.h"

#include "shlcfg.h"
#include "sheldefs.h"
#include "shell.h"

#define SHOWL 72

extern
OBJECT *menu;

#if ! BIP_CC
short filecount = 0, high_prj = 0;		/* otherwise in AHCC.C */
#endif

void send_msg(char *text, ...);

void free_cache(void);

/* If the program is started with an argument
	we want start with that file,
	not with the initial journal message,
	so this bool is defined by FILES.C */
extern
bool init_open_jrnl;

void dial_b2(void);
global
short pdrive;

static
char LTMP[] = "ldfile.tmp";		/* loader command file */

/*
 *	locations
 */
global
S_path
	mkpad = {""},				/* project path */
	mkfn  = {""},				/* settings */
	depfn = {""};				/* dependencies */

#if ! BIP_CC || defined TTPSHELL
static
S_path cerf;
#endif


/*
 * Standard filename extensions
 */

global
SH_SUFS sufs = {".app", ".prg", ".ttp", ".tos", ".c", ".a", ".h", ".d", ".s", ".o", ".l", ".lib", ".pr?"};

global
PRJ root_project;

SHEL_CONFIG SHL_cfg =
{
	"main",		/* name of root function */
	0,0,0,		/* loads, makes all     */
	1,			/* c_nested_comments	*/
	1,			/* e_max_errors			*/
	10,			/* max_errors			*/
	1,			/* f_max_warnings		*/
	50,			/* max_warnings			*/
	0,			/* h_cdecl_calling		*/
	0,0,0,0,0,	/* d_define_macro[5]	*/
	0,0,0,0,0,	/* i_include_dir [5]	*/
	1,			/* d_lib_dir			*/
	0,			/* k_char_is_unsigned	*/
	0,0,0,0,	/* v v1 v2 v3			*/

	0,			/* i2_68020				*/
	0,			/* i2_68030				*/
	0,			/* i2_68040				*/
	0,			/* i2_68060				*/
	0,			/* use_FPU				*/
	0,			/* Coldfire 			*/
#if C99
	0,			/* c99					*/
#endif
	0,			/* ac_cache_headers		*/
	0,			/* ag_nogoto			*/
	0,			/* af_func_tree			*/
	0,			/* ah_project_help		*/
	0,			/* am_match				*/
	0,			/* ai_int32				*/
	0,			/* au_supervisor		*/
	0,			/* al_list_stats		*/
	1,			/* opt_inherit			*/
	0,			/* aj_auto_depend		*/

	0,			/* ad_new_peep			*/
	0,			/* ak_token_list		*/

	0,			/* aw_Xnl				*/

	0,			/* ax_debugging			*/
	0,			/* ay_debugging			*/
	0,			/* aa_debugging			*/
	0,			/* az_debugging			*/

	0,			/* ln_nm_list			*/
	0,			/* lt_load_map			*/

	0,			/* lf_load_slow			*/
	0,			/* lr_load_ST			*/
	0,			/* lm_malloc_ST			*/

	0,			/* lj_make_object		*/
	0,			/* lg_global_symbols	*/
	0,			/* ll_local_symbols		*/
#ifdef AH1
	0,0,0,0,0,	/* AH1 - AH5 Ad hoc functions */
#endif
	1,			/* no_xy_debugging		*/

	"","","","","DEBUG=1",		/* definestr */
	"include","","","","",		/* inclstr	*/
	"*.C",		/* matchstr				*/
	"lib",
	"",""		/* xoptstr, yoptstr */
};

static
bool is_located(char *path)
{
	if (path)
	{
		short l = strlen(path) - 1;
		if (    *path ne 0
			and !(   path[l] eq fslash
			      or path[l] eq bslash
			     )
		   )
			return true;
	}
	return false;
}

static
char **make_argv(char *cmd)
{
	return nil;
}

static
short findupsuf(char *f, char *s)
{
	char *p; short i;

	p = f; i = strlen(f)-1;		/* No trailing spaces svp (after ;) */
	while (i)
		if (p[i] eq ' ' or p[i] eq '\t')
			i--;
		else
			break;

	p[i+1] = 0;

	if ((p = strrchr(f, '.')) ne nil)
	{
		if (strslash(p) eq nil)
			if ( stricmp(p, s) )	/* er is een suffix */
				return 0;	/* ongelijk fout */
			else
				return tolower(*(p+1));	/* gelijk return eerste letter */
	}
	return ' ';					/* geen  */
}

global
bool inlist(FN *t, S_path *f, short ty)
{
	FCSOADL *ft = t->ft;
	while (ft)
		if ((strcmp(ft->f.s, f->s)) eq 0)
			return true;
		else
			ft = ft->next;
	return false;
}

static
bool putflist(FN *t, S_path *f, short ty)
{
	if (!inlist(t, f, ty))
	{
		FCSOADL *last = t->last,
		      *new;

		new = xmalloc(sizeof(*new), AH_KEEPFILE);
		if (new)
		{
			DIRcpy(&new->f, f->s);
			new->next = nil;
			new->csol = ty;
			if (last)
				last->next = new;
			else
				t->ft = new;
			t->last = new;
			t->n += 1;
			return true;
		}
		else
			send_msg("insufficient memory for filenames in shell\n");

	}
	return false;
}

void console(Cstr, ...);
/*
 *  keepfile(prj, f, l) - remember the filename 'f' in the appropriate place
 */
static
short keepfile(PRJ *prj, S_path *f, short level)
{
	if (f eq nil)
		return 0;

	if (inq_xfs(f->s, nil) eq 0)
		strupr(f->s);

	if (*prj->files.op.s eq 0)  		/* first file is output */
	{
		DIRcpy(&prj->files.op, f->s);
		return 'p';
	}

	if (level eq -1)				/* start up code */
	{
		DIRcpy(&prj->files.up, f->s);
		return 'o';
	}
	elif (findupsuf(f->s, ".x") eq ' ' )  /* geen suffix */
	{
		S_path ps;
		ps = change_suffix(f, sufs.c);
		putflist(&prj->files.in, &ps, FTC);		/* default is .C */
		return 'c';
	}
	elif (   findupsuf(f->s, sufs.app)
	      or findupsuf(f->s, sufs.prg)
	      or findupsuf(f->s, sufs.ttp)
	      or findupsuf(f->s, sufs.tos)
	   )
	{
		if (*prj->files.op.s)
			send_msg("duplicate output file '%s'\n", f->s);
		DIRcpy(&prj->files.op, f->s);
		return 'p';
	}
	elif (findupsuf(f->s, sufs.c) )
	{
		putflist(&prj->files.in, f, FTC);
		return 'c';
	}
#if FOR_A
	elif (findupsuf(f->s, sufs.a) )
	{
		putflist(&prj->files.in, f, FTA);
		return 'a';
	}
	elif (findupsuf(f->s, sufs.d) )
	{
		putflist(&prj->files.h, f, FTD);
		return 'd';
	}
#endif
	elif (findupsuf(f->s, sufs.h) )
	{
		putflist(&prj->files.h, f, FTH);
		return 'h';
	}
	elif (findupsuf(f->s, sufs.s) )
	{
#if BIP_ASM
		putflist(&prj->files.in, f, FTS);
		return 's';
#else
		putflist(&prj->files.in, f, FTO);
		return 'o';
#endif
	}
	elif (findupsuf(f->s, sufs.o) )
	{
		putflist(&prj->files.in, f, FTO);
		return 'o';
	}
	elif (   findupsuf(f->s, sufs.a)
	      or findupsuf(f->s, sufs.lib)
	      or findupsuf(f->s, sufs.l))
	{
		putflist(&prj->files.in, f, FTL);
		return 'l';
	}
	else
	{
		send_msg("%d>project: unknown file suffix '%s'\n", level, f->s);
		return 0;
	}
}

global
S_path defofile(PRJ *prj, S_path *f)
{
	FCSOADL *ft = prj->files.in.ft;

	if (!f->s and ft)
	{
		if (*ft->f.s)
			return change_suffix(&ft->f, sufs.prg);
		else
		{
			S_path a;
			DIRcpy(&a, "A.PRG");
			return a;
		}
	}

	return *f;
}

static
void clear_files(FN *t, short level)
{
	FCSOADL *ft = t->ft;

	while (ft)
	{
		FCSOADL *nx = ft->next;
		free(ft);
		ft = nx;
	}
	t->last = nil;
	t->ft   = nil;
	t->n    = 0;
	t->d    = 0;
}

static
void clear_project(PRJ *prj, short level)
{
	if (prj)
	{
		PRJ *p = prj->first;

/*		send_msg("%d>clear_project for %s\n", level, prj->files.op.s);
*/
		while (p)
		{
			PRJ *nx = p->next;
			clear_project(p, level + 1);
			p = nx;
		}

		clear_files(&prj->files.in, level);
		clear_files(&prj->files.h,  level);

		xfree(prj->makeCoptions);
		xfree(prj->makeSoptions);
		xfree(prj->makeLoptions);

		prj->makeLib = false;

		if (prj->parent)		/* only root has no parent and is static */
			free(prj);
	}
}

global
void remove_project(void)
{
	filecount = 0;
	high_prj = 0;
	clear_project(&root_project, 0);
#if BIP_CC
	pdb_free_dep();
#endif
}

static
void showlist(FN *t, FILE *fp, char *pad)
{
	FCSOADL *ft = t->ft;
	while (ft)
	{
		if (fp eq stdout)
			send_msg("%s\n", delpad(ft->f.s, pad));
		else
			fprintf(fp, "%s\n", delpad(ft->f.s, pad));

		ft = ft->next;
	}
}

global
void printlists(FILE *fp, PRJ *prj, char *pad)
{
	if (*prj->files.op.s)
		if (fp eq stdout)
			send_msg("%s\n", delpad(prj->files.op.s, pad));
		else
			fprintf(fp, "%s\n", delpad(prj->files.op.s, pad));
	showlist(&prj->files.in, fp, pad);
	showlist(&prj->files.h,  fp, pad);
}

static
bool older(DOSTIME t1, DOSTIME t2)
		/* false: t1 jonger t2; true: t1 ouder t2
		 * gelijk is onbeslisbaar: (file's kunnen binnen
		 * 2 seconde best aangemaakt worden (RAMdisc)),
		 * maar de volgorde waarin is niet te bepalen;
		 * dus false
		 */
{
	if ((unsigned)t1.date < (unsigned)t2.date) return true;
	if ((unsigned)t1.date > (unsigned)t2.date) return false;
	if ((unsigned)t1.time < (unsigned)t2.time) return true;
	return false;
}

/* 05'12 HR void getstamp V4.12 */
static
void getstamp(DOSTIME *t, short h, Cstr f)
{
	Fdatime(t, h, 0);
	Fclose(h);
}


static
void touch(S_path *f)
{
	long h;
	DOSTIME t = {0, 0x21};	/* 00:00, 80-1-1 */

	if ( (h = Fopen(f->s, FO_READ)) >= 0 )
	{
		S_path o;

		Fclose(h);
		o = change_suffix(f, sufs.o);
		if ( (h = Fopen(o.s, FO_RW)) >= 0 )
		{
			Fdatime(&t, h, 1);		/* touch .o (datime --> 80-1-1) */
			Fclose(h);
		}
	}
}

static
short makeok(DPP dependencies, Cstr f, char *of, DOSTIME tp, short lvl)
{
	long  fh;			/* 05'12 HR long V4.12 */
	DOSTIME to, ts;

	fh = Fopen(of, 0);
	if (fh <= 0)
		return 1;		/* .o absent, must compile */

	getstamp(&to, fh, of);	 /* object (target) */
	fh = Fopen(f, 0);
	if (fh <= 0)
	{
		send_msg("%d>make: Can't open %s\n", lvl, f);
		return 0;
	}

	getstamp(&ts, fh, f);	 /* src */

	if (older(ts, to))		/* src ouder dan object */
	{
		if (older(tp, to) )	/* prg ouder .o or prg.date = 0 */
			return 2; 		/* alleen linken voldoende */
		else
		{
			DPP this;
			this = pdb_find(dependencies, f);
			if (this)
			{
				if (this->depend)
				{
					short ret;
					this = this->depend;
					while (this)
					{
						DPP that = pdb_find(dependencies, this->data->name);
						if (that)
						{
							ret = makeok(that, that->data->name, of, tp, lvl + 1);
							if (ret)
								return ret;
						}
						this = this->dnext;
					}
				}
			}
			return 0;
		}
	}
	else
		return 1;		/* compileren */
}

/*
 * docomp(prj, f) - run the compiler on the given apprpriate file
 */

global
short docomp(PRJ *prj, char *f, char *o, bool asm)
{
	short     warn;
	char    cmdln[4096];
	char	options[32], a_options[32];
	char   *opt = options, *a_opt = a_options;
	char   *space = " ";

#if ! BIP_CC || defined TTPSHELL
	P_path pn;

	pn.s = f;
	cerf = change_suffix(pn.t, ".err");
#endif

	/* many levels of verbosity */
	if (SHL_cfg.v)
	{
		short i = SHL_cfg.v;
		while (i--)
			*opt++ = 'v';
	}
	if (SHL_cfg.v1) *opt++ = 'v';
	if (SHL_cfg.v2) *opt++ = 'v';
	if (SHL_cfg.v3) *opt++ = 'v';
	if (SHL_cfg.c_nested_comments)		*opt++ = 'c';		/* nested comments */
	if (SHL_cfg.k_char_is_unsigned)		*opt++ = 'k';		/* default char is unsigned */
	if (SHL_cfg.h_cdecl_calling)		*opt++ = 'h';		/* cdecl calling */
#if FLOAT
	if (SHL_cfg.i2_68020)				*opt++ = '2';		/* >= 68020 */
	if (SHL_cfg.i2_68030)				*opt++ = '3';		/* 68030 */
	if (SHL_cfg.i2_68040)				*opt++ = '4';		/* 68040 */
	if (SHL_cfg.i2_68060)				*opt++ = '6';		/* 68060 */
	if (SHL_cfg.use_FPU)  				*opt++ = '8';		/* FPU */
#endif
#if COLDFIRE
	if (SHL_cfg.Coldfire)  				*opt++ = '7';		/* double is 64 bits */
#endif

#if C99
	if (SHL_cfg.c99)					*opt++ = '9';		/* accept C99 syntax and implement if supplied twice */
#endif
	if (SHL_cfg.ac_cache_headers)  		*a_opt++ = 'c';		/* cache headers */
	if (SHL_cfg.ag_nogoto)				*a_opt++ = 'g';		/* warn goto's */
	if (SHL_cfg.af_func_tree)			*a_opt++ = 'f';		/* Function tree database */
	if (SHL_cfg.ah_project_help) 		*a_opt++ = 'h';		/* project HELP */
	if (SHL_cfg.ai_int32)				*a_opt++ = 'i';		/* default int is 32 bits */
	if (SHL_cfg.aj_auto_depend)			*a_opt++ = 'j';		/* auto dependencies */
#if BIP_ASM
	if (SHL_cfg.au_supervisor)			*a_opt++ = 'u';		/* default .super in assembly */
#endif
	if (SHL_cfg.aw_Xnl)					*a_opt++ = 'w';		/* default Xn is long (EmuTos) */
#if DEBUG
	if (SHL_cfg.al_list_stats)			*a_opt++ = 'l';		/* nodestats */
	if (SHL_cfg.ad_new_peep)			*a_opt++ = 'd';		/* suppress newest peephole optimization */
	if (SHL_cfg.ak_token_list)			*a_opt++ = 'k';		/* print token list */
	if (SHL_cfg.no_xy_debugging eq 0)
	{
		if (SHL_cfg.aa_debugging)  		*a_opt++ = 'a';
		if (SHL_cfg.az_debugging) 		*a_opt++ = 'z';
	}
#endif
/*	*a_opt++ = 't'; */
#ifdef AH1
		if (SHL_cfg.f2)					*a_opt++ = 'e';		/* suppress extracodes (ahcc_rt.h) */
		if (SHL_cfg.f3)					*a_opt++ = 'r';		/* suppress registerization */
		if (SHL_cfg.f5)					*a_opt++ = 't';		/* Use Tony Andrews register health Thealth() */
#endif
	*opt = 0;
	*a_opt = 0;
	cmdln[0] = 0;

	if (opt ne options)			/* Pure C compatible options */
	{
		strcat(cmdln, "-");
		strcat(cmdln, options);
		strcat(cmdln, space);
	}

	if (a_opt ne a_options)		/* AHCC specific options */
	{
		strcat(cmdln, "-*");
		strcat(cmdln, a_options);
		strcat(cmdln, space);
	}

	if (asm and prj->makeSoptions)
		strcat(cmdln, prj->makeSoptions);
	elif (prj->makeCoptions)
		strcat(cmdln, prj->makeCoptions);

#if DEBUG
	if (SHL_cfg.no_xy_debugging eq 0)	/* These are for the compiler run */
	{
		if (SHL_cfg.ax_debugging)
		{
			strcat(cmdln, "-*x");
			strcat(cmdln, SHL_cfg.xoptstr);
			strcat(cmdln, space);
		}

		if (SHL_cfg.ay_debugging)
		{
			strcat(cmdln, "-*y");
			strcat(cmdln, SHL_cfg.yoptstr);
			strcat(cmdln, space);
		}
	}
#endif

	prj_params(cmdln);

	strcat(cmdln, f);

	if (o)
	{
		strcat(cmdln, " -O");	/* no change_suffix; the compiler does */
		strcat(cmdln, o);
	}

	send_msg("\n****  Compiling %s\n", f);

	if (SHL_cfg.v)
	{
		char line[256];
		char *fro = cmdln;

		while (*fro)
		{
			fro = delimited_copy(255, fro, line, ' ');
			send_msg("%s\n", line);
		}
	}

	if ( (warn = tos_call(compiler, cmdln)) > 0)
	{
		if (o)
		{
			Fdelete(o);
/*		othw
			P_path pn;
			pn.s = f;
			S_path sf;
			sf = change_suffix(pn.t, sufs.s);
			Fdelete(sf.s);
*/		}
		return warn;
	}

	if (warn eq 0)
	{
#if ! BIP_CC || defined TTPSHELL
		Fdelete(cerf.s);
#endif
#if ! DEBUG
		if (SHL_cfg.v)
#endif
		send_msg("compilation OK\n");
	}

	return warn;
}

static
bool look_CC(FILE *fp, char *s, char *msg)
{
	MAX_dir file;
	char *t = delpad(s, mkpad.s);
	Cstr lb = get_libstr();

#if CC_PATH
	sprintf(file, "%s%s" sbslash "%s", CC_path.s, lb, t);
#else
	sprintf(file, "%s" sbslash "%s", lb, t);
#endif

	if   (isfile(file))
		fprintf(fp, "%s\n", file);
	else
	{
		send_msg("cannot find %s '%s'\n", msg, file);
		return false;
	}

	return true;
}

/*
 * dold() - run the loader
 */

global
bool dold(PRJ *prj)
{
	FILE *fp;
	S_path ps;
	char cmdln[4096];
	short rep;

	if (prj->files.in.n eq 0)
	{
		send_msg("nothing to link\n");
		return false;
	}

	Fdelete(LTMP);

	/*
	 * Construct loader command file
	 */
	if ((fp = fopen(LTMP, "w")) eq nil)
	{
		extern short errno;
		send_msg("cannot open loader temp file; errno %d\n", errno);
		return false;
	}

	if (*prj->files.up.s)
	{
		char *up = prj->files.up.s;
		if (isfile(up))
			fprintf(fp, "%s\n", up);
		elif (!look_CC(fp, up, "start up"))
			return false;
	}

	if (prj->files.in.n)
	{
		FCSOADL *ft = prj->files.in.ft;

		while (ft)
		{
			char *s;
			switch(ft->csol)
			{
#if FOR_A
				case FTA:
#endif
				case FTC:
#if BIP_ASM
				case FTS:
#endif
					ps = change_suffix(&ft->f, sufs.o);
					fprintf(fp, "%s\n", ps.s);
				break;
				case FTO:
					fprintf(fp, "%s\n", ft->f.s);
				break;
				case FTL:			/* 04'09 preserve order */
					s = ft->f.s;
					if (isfile(s))
						fprintf(fp, "%s\n", s);
					elif (!look_CC(fp, s, "library"))
						return false;
				break;
			}
			ft = ft->next;
		}
	}

	fclose(fp);

	prj->files.op = defofile(prj, &prj->files.op);

	sprintf(cmdln, "%s%s%s%s %s %s %s %s %s %s %s %s %s -c=%s -o=%s",
	               SHL_cfg.v  ? "-v" : "",
	               SHL_cfg.v1 ? "v"  : "",
	               SHL_cfg.v2 ? "v"  : "",
	               SHL_cfg.v3 ? "v"  : "",
	               SHL_cfg.lg_global_symbols ? "-g" : "",
	               SHL_cfg.ll_local_symbols  ? "-l" : "",
	               SHL_cfg.lj_make_object    ? "-j" : "",
	               SHL_cfg.ln_nm_list        ? "-n" : "",
	               SHL_cfg.lt_load_map       ? "-p" : "",

	               SHL_cfg.lf_load_slow      ? "-f" : "",
	               SHL_cfg.lr_load_ST        ? "-r" : "",
	               SHL_cfg.lm_malloc_ST      ? "-m" : "",

	               prj->makeLoptions ? prj->makeLoptions : "",
	               LTMP,
	               prj->files.op.s);

	send_msg("\n****  Linking %s\n", prj->fn.s);
	
	if (SHL_cfg.v1 and strlen(cmdln) < 255)
		send_msg("-= %s =-\n", cmdln);

	rep = tos_call(linker, cmdln);
	if (rep)
	{
		send_msg("linker failed: %d\n", rep);
		fclose(fp);		/* 10'13 Gerhard Stoll */
		return false;	/* Dont delete the LTMP */
	}

	send_msg("Output file: '%s'\n", prj->files.op.s);

	Fdelete(LTMP);
	return true;
}

static
short make_prj(PRJ *prj, DPP dep, short level)
{
	short l, anycomp = 0;
	long fh;			/* 05'12 HR long V4.12 */
	DOSTIME tp;
	PRJ *p = prj->first;
	FCSOADL *ft;

	tp.date = 0;
	tp.time = 0;

	while (p)
	{
		/* the new output is detected via makeok in the outer prj */
		short r = make_prj(p, dep, level + 1);
		if (r eq -1)
			return -1;		/* errors */
		anycomp += r;		/* 03'09: pass it on */
		p = p->next;
	}

	if (*prj->files.op.s and (fh = Fopen(prj->files.op.s, 0)) > 0 )		/* 05'12 HR > 0 V4.12 */
	{
		getstamp(&tp, fh, prj->files.op.s);
		Fclose(fh);
	}

	ft = prj->files.in.ft;
	while (ft)
	{
#if FOR_A
		if (   ft->csol eq FTC
#if BIP_ASM
		    or ft->csol eq FTS
#endif
		    or ft->csol eq FTA
		   )
#elif BIP_ASM
		if (   ft->csol eq FTC
#if BIP_ASM
		    or ft->csol eq FTS
#endif
		   )
#else
		if (   ft->csol eq FTC
		   )
#endif
		{
			bool make = false;
			Cstr m = get_matchstr();
			HI_NAME *hn = hn_make(ft->f.s, ":\\.", 4);

			if (hn eq nil)
				make = true;
			else
			{
				if (!SHL_cfg.am_match or !*m)
					make = true;
				elif (SHL_cfg.am_match and match_pattern(hn->fn->n, m))
				   	make = true;
				hn_free(hn);
			}
			if (make)
			{
				S_path of = change_suffix(&ft->f, sufs.o);
				l = makeok(dep, ft->f.s, of.s, tp, 0);		/* recursive check timestamp */

				anycomp += l;				/* dan gatie linke */

				if (l eq 1) 				/* .o is er niet || .o is jonger */
					if (docomp(prj, ft->f.s, nil, ft->csol eq FTS) > 0)
						return -1;			/* errors */
			}
		}

		ft = ft->next;
	}

#if BIP_LD
	if (anycomp > 0)
		dold(prj);         		/* run the loader */
#endif
	return anycomp;
}

global
void domake(PRJ *prj, bool msg)
{
	short anycomp;
	DPP dep;

	if (prj->files.in.n eq 0)
		send_msg("nothing to make\n");
	else
	{
		if (SHL_cfg.aj_auto_depend)
		{
			dep = auto_dependencies;
			if (msg)
				send_msg("\nAuto make %s\n", mkfn.s);
		othw
			dep = prj_dependencies;
			if (msg)
				send_msg("\nPRJ make %s\n", mkfn.s);
		}

		anycomp = make_prj(prj, dep, 0);		/* recursive make */
		if (anycomp eq 0)
			send_msg("make: everything seems to be OK\n");
	}
}

static
void clear_dates(PRJ *prj, short level)
{
	FCSOADL *ft;
	PRJ *p = prj->first;

	while (p)
	{
		PRJ *nx = p->next;
		clear_dates(p, level + 1);
		p = nx;
	}

	ft = prj->files.in.ft;
	while (ft)
	{
		if (   ft->csol eq FTC
		    or ft->csol eq FTS
#if FOR_A
		    or ft->csol eq FTA
#endif
		   )
			touch(&ft->f);

		ft = ft->next;
	}
}

global
void domakeall(PRJ *prj)	/* updates all objects filestamp, call make */
{
	VpV init_stats, pr_stats;
#ifdef TOK_FREQ
	VpV zero_tok_freq, print_tok_freq;
	zero_tok_freq();
#endif

	init_stats();
	clear_dates(prj, 0);
	domake(prj, false);         		/* run make w/o msg */
	pr_stats();

#ifdef TOK_FREQ
	print_tok_freq();
#endif
}

static
void make_path(S_path *m, char *f)
{
	char *t;

	DIRcpy(m, f);
	t = strrslash(m->s);
	if (t)
	{
		*(t+1) = 0;

		if (inq_xfs(m->s, nil) eq 0)
			strupr(m->s);
	}
	else
		*m->s = 0;				/* 09'11 HR */
}

static
char ranout[] = "Ran out of memory for project file";

static
long add_options(char **fro, char **to, long co, short level)
{
	char *p, *s = *fro;
	long ol;

	if (sk() eq '[')
		skc();

	p = ipff_getp();
	s += strlen(s) - 1;

	if (*s eq ']')
		*s = 0;

	ol = strlen(p);
	ol += 2;
	*to = xrealloc(*to, co + ol, AH_COPT);

	if (*to)
	{
		if (co eq 0)
			*to[0] = 0;		/* first time */
		strcat(*to, p);
		strcat(*to, " ");
		co += ol;
	}
	else
		send_msg("%d>%s\n", level, ranout);

	*fro = s;
	return co;
}

static
void alert_braces(char *to, char *fro)
{
	while (*fro)
	{
		if (*fro eq '[')
			*to++ = '{';
		elif (*fro eq ']')
			*to++ = '}';
		else
			*to++ = *fro;
		fro++;
	}
	*to = 0;
}

static
bool load_prj(PRJ *prj, char *f, short level)
{
	FILE *fp;
	char st[1024];
	char *s, *t;
	short keep;
	long Coptl = 0, Soptl = 0, Loptl = 0;
	bool started = true;

	DIRcpy(&prj->fn, f);

	make_path(&prj->pad, f);

	if (SHL_cfg.opt_inherit and prj->parent)			/* 03'09: inherit options from parent project */
	{
		char *p = prj->parent->makeCoptions;		/* p protects Cstr pointer in parent */
		if (p)										/* 12'09 HR: if there */
		{
			ipff_in(p);
			Coptl = add_options(&p, &prj->makeCoptions, Coptl, level);
		}
		p = prj->parent->makeSoptions;
		if (p)
		{
			ipff_in(p);
			Soptl = add_options(&p, &prj->makeSoptions, Soptl, level);
		}
	}

	if ((fp = fopen(f, "r")) eq nil)
	{
		send_msg("%d>Can't open project file: %s\n", level, f);
		return false;
	}

	while (fgets(st, sizeof(st)-1, fp) ne nil )
	{
		short c;

		s = crlf(st);
		t = s;

		while(*t and *t ne ';') t++;	/* remove comment */
		if (*t eq ';')
			*t = 0;

		ipff_trail(s);		/* remove trailing space */

		if (*s)				/* anything left ? */
		{
			if (SHL_cfg.v1)
				send_msg("%d>'%s'\n", level, s);
			ipff_in(s);			/* ipff_init on s with defaults */

			c = sk();
			if (c eq '.' and !look("..", 2))
			{
				c = sk1();
				if (c eq 'C' or c eq 'c')
					skc(), Coptl = add_options(&s, &prj->makeCoptions, Coptl, level);
				elif (c eq 'S' or c eq 's')
					skc(), Soptl = add_options(&s, &prj->makeSoptions, Soptl, level);
				elif (c eq 'L' or c eq 'l')
					skc(), Loptl = add_options(&s, &prj->makeLoptions, Loptl, level);
			}
			elif (c eq '=')
				started = false;
			elif (c ne 0 and c ne '=')
			{
				S_path ps, fnm;

				s = ipff_getp();
				sk();
				fstr(fnm.s);
				ps = inspad(&fnm, prj->pad.s);

				if (!started)
				{
					started = true;

					if (level eq 0 and findupsuf(fnm.s, ".o") eq 'o')
					{
						keep = keepfile(prj, &ps, -1);
						continue;
					}
				}

				if (findupsuf(ps.s, ".prj") eq 'p')			/* nested project */
				{
					PRJ *new = xcalloc(1, sizeof(*new), AH_NEW_PRJ);
					if (new)
					{
						new->parent = prj;
						new->prior = prj->last;
						if (prj->first eq nil)
							prj->first = new;
						if (prj->last)
							prj->last->next = new;
						prj->last = new;
						load_prj(new, ps.s, level + 1);
						keep = keepfile(prj, &new->files.op, level);
					}
					else
						send_msg("%d>%s\n", level, ranout);
				}
#if ! BIP_CC
				keep = keepfile(prj, &ps, level);
#else
				elif ((keep = keepfile(prj, &ps, level)) ne 0)
				{
					DPP rp = pdb_find(prj_dependencies, ps.s);
					if (!rp)
					{
						rp = pdb_new(&prj_dependencies, ps.s);
						pdb_fileno(rp, -1);
	#ifdef COFT
						if (   keep eq 'c' or keep eq 's'
		#if FOR_A
	                        or keep eq 'a'
		#endif
						   )
							rp->data->flags |= TRV_IN;
						elif (keep eq 'p')
							rp->data->flags |= TRV_OUT;
	#endif
					}
					if (sk() eq '(')			/* has dependencies */
					{
						/* only for prj_dependencies */
						rp->data->flags |= TRV_DEPEND;
						do{
							skc();			/* either ( or , */
							fstr(fnm.s);
							if (fnm.s[0])
							{
								DPP dp, ddp; short fc;

								ps = inspad(&fnm, prj->pad.s);
								if (inq_xfs(ps.s, nil) eq 0)
									strupr(ps.s);

								dp = pdb_find(prj_dependencies, ps.s);

								if (!dp)
								{
									dp = pdb_new(&prj_dependencies, ps.s);
									pdb_fileno(dp, -1);
								}

								fc = dp->data->file_number;
								ddp = pdb_find(rp->depend, ps.s);

								if (!ddp)
								{
									DPP pp = pdb_new(&rp->depend, ps.s);
									pdb_fileno(pp, fc);
								}
							}

							if (sk() ne ',')
								break;
						}od
					}
				}
#endif
			}
		}
	}

	fclose(fp);

	return keep|true;		/* keep used */
}

global
void loadmake(char *f, bool clean)
{
	DIRcpy(&mkfn, f);

	if (SHL_cfg.v)
		send_msg("Loading project file %s\n", f);
	make_path(&mkpad, f);

#if BIP_CC
	if (auto_dependencies)
		pdb_write_dep();
#endif

	remove_project();
	zero(root_project);
#ifdef GEMSHELL
	menu_prj(nil);
#endif

#if BIP_CC
	pdb_free_dep();

	DIRcpy(&depfn, f);
	depfn = change_suffix(&depfn, ".adb");
#endif

	if (load_prj(&root_project, mkfn.s, 0))
	{
#ifdef GEMSHELL
		menu_prj(getfn(mkfn.s));
#endif
		if (SHL_cfg.v)
			send_msg("loaded project from: %s\n", f);


#if BIP_CC
		high_prj = filecount;
		if (    !clean
		    and (SHL_cfg.ah_project_help or SHL_cfg.aj_auto_depend)
		   )
		{
			auto_dependencies = pdb_read_dep();
	#ifdef MNJDEP
			if (SHL_cfg.v and SHL_cfg.v1)
			{
				void jnl_tree(DPP start, DPP root, short flag);
				jnl_tree(auto_dependencies, auto_dependencies, TRV_IN);
			}
	#endif
		}
#endif
	}
}

global
void init_make(char *argmake)
{
	if (argmake)
		DIRcpy(&mkfn, argmake);
	if (mkfn.s[0])
		loadmake(mkfn.s, 0);
}

global
void do_compile(PRJ *prj, char *f)
{
	if (f)
	{
		if (    tolower(findupsuf(f, sufs.c)) ne 'c'
		    and tolower(findupsuf(f, sufs.s)) ne 's'
#if FOR_A
			and tolower(findupsuf(f, sufs.a)) ne 'a'
#endif
		   )
			return;

		docomp(prj, f, nil, tolower(findupsuf(f, sufs.s)) eq 's');
	}
}

static
Cstr save_string(void)
{
	static char s[512];
	strcpy(s,"Saving ");
	if (SHL_cfg.aj_auto_depend)
	{
		strcat(s, "dependencies ");
		if (SHL_cfg.ah_project_help or SHL_cfg.af_func_tree) strcat(s, "and ");
	}
	if (SHL_cfg.ah_project_help or SHL_cfg.af_func_tree)
		strcat(s, "project database");
	return s;
}

global
void end_shell(void)
{
	VpV free_dictionary;

	if (    (SHL_cfg.aj_auto_depend or SHL_cfg.ah_project_help)
	    and (   (auto_dependencies and dep_changed)
	         or (fun_dependencies and dep_changed)
	        )
	   )
	{
		send_msg("\n**** %s %s, please wait\n", save_string(), depfn.s);
		pdb_write_dep();
	}
	remove_project();

#if BIP_CC && __COLDFIRE__
	free_dictionary();
#endif
}

global
void prj_params(char *cmdln)		/* called by docomp() */
{
	short i;
	char   *space=" ";

	loop(i, 5)
	{
		if (SHL_cfg.d_define_macro[i])
		{
			Cstr s = get_definestr(i);
			if (*s)
			{
				strcat(cmdln, "-D");
				strcat(cmdln, s);
				strcat(cmdln, space);
			}
		}
	}

	loop(i, 5)
	{
		if (SHL_cfg.i_include_dir[i])
		{
			Cstr s = get_inclstr(i);
			if (*s)
			{
				strcat(cmdln, "-I");
#if CC_PATH
				if (*(s + 1) ne ':')
					strcat(cmdln, CC_path.s);
#endif
				strcat(cmdln, s);
				strcat(cmdln, space);
			}
		}
	}

	if (SHL_cfg.e_max_errors)
	{
		strcat(cmdln, "-E");
		strcat(cmdln, cbdu(get_max_errors(),3,'0'));
		strcat(cmdln, space);
	}

	if (SHL_cfg.f_max_warnings)
	{
		strcat(cmdln, "-F");
		strcat(cmdln, cbdu(get_max_warnings(),3,'0'));
		strcat(cmdln, space);
	}
}

#ifdef TTPSHELL

/* project driven compiler and/or linker for the commandline */
global
Cstr get_matchstr(void)
{
	return SHL_cfg.matchstr;
}
global
Cstr get_definestr(short i)
{
	return SHL_cfg.definestr[i];
}
global
Cstr get_inclstr(short i)
{
	return SHL_cfg.inclstr[i];
}
global
Cstr get_libstr(void)
{
	return SHL_cfg.libstr;
}
global
short get_max_errors(void)
{
	return SHL_cfg.max_errors;
}
global
short get_max_warnings(void)
{
	return SHL_cfg.max_warnings;
}

void waitexit(short);

short wait_exit(short ret)
{
	send_msg("press any key\n>\r");
	bios(2, 2);
	return ret;
}

#if BIP_CC

/* project based compiler/linker */
static
bool make_all = false;

static
void doopt(char *s, SHEL_CONFIG *c)
{
	while (*s)
	{
		switch (tolower(*s))
		{
			case 'v':	c->v++;						break;
			case 'x':	make_all = true; 			break;
			case 'c':	c->ac_cache_headers = 1;	break;
			case 'f':	c->af_func_tree = 1;		break;
			case 'h':	c->ah_project_help = 1;		break;
			case 'j':	c->aj_auto_depend = 1;		break;
			case 'i':	c->opt_inherit = 1;			break;
			case 'g':	c->ag_nogoto = 1;			break;
			case 'n':	c->ln_nm_list = 1;			break;
			case 'p':	c->lt_load_map = 1;			break;
			default:
				send_msg("Usage: options not available in project file\n");
				send_msg("-v Vorbosity\n");
				send_msg("-x Make ALL\n");
				send_msg("-c Cache headers\n");
				send_msg("-h Project HELP\n");
				send_msg("-j Auto dependencies\n");
				send_msg("-i Inherit options from parent project\n");
				send_msg("-g Warn goto's\n");
				send_msg("-n 'nm' symbol list\n");
				send_msg("-p Load map\n");
		}

		s++;
	}
}

global
short main(short argc, char *argv[])
{
	short i;
	P_path prj;
	long alt = Kbshift(-1);		/* ALT pressed while dropping : make all */
	void tok_init(void);

	prj.s = nil;
	XA_set_base(nil, 1L<<14, 13, 0, nil, nil);

	for (i=1; i<argc; i++)
	{
		if (argv[i][0] eq '-')
			doopt(&argv[i][1], &SHL_cfg);
		else
			prj.s = argv[i];
	}

#if __COLDFIRE__
/*	send_msg("TTP shell: init dictionary\n"); */
	init_dictionary();
#endif
	tok_init();
	init_dir(0);		/* 0 = TOS */

	pdb_init();

	if (prj.s)
	{
		DIRcpy(&mkfn, prj.s);

		loadmake(mkfn.s, 0);

		if (make_all or (alt & 8) ne 0)
		{
			send_msg("\nMake all %s\n", mkfn.s);
			domakeall(&root_project);
		}
		else
			domake   (&root_project, true);
		end_shell();
		free_cache();
		return wait_exit(0);
	othw
		send_msg("needs name of project file\r\n");
		return wait_exit(1);
	}
}

#elif BIP_LD

/* project based LD */
static
void doopt(char *s, SHEL_CONFIG *c)
{
	while (*s)
	{
		switch (tolower(*s))
		{
			case 'v':	c->v++;						break;
			case 'n':	c->ln_nm_list = 1;			break;
			case 'p':	c->lt_load_map = 1;			break;
			default:
				send_msg("Usage: options not available in project file\n");
				send_msg("-v Vorbosity\n");
				send_msg("-n 'nm' symbol list\n");
				send_msg("-p Load map\n");
		}

		s++;
	}
}

global
short main(short argc, char *argv[])
{
	P_path prj;
	short i;

	prj.s = nil;
	XA_set_base(nil, 1L<<14, 13, 0, nil, nil);

	for (i=1; i<argc; i++)
		if (argv[i][0] eq '-')
			doopt(&argv[i][1], &SHL_cfg);
		else
			prj.s = argv[i];

	init_dir(0);		/* 0 = TOS */

	remove_project();

	if (prj.s)
	{
		DIRcpy(&mkfn, prj.s);

		loadmake(mkfn.s, 0);
		dold(&root_project);

		return wait_exit(0);
	othw
		send_msg("needs name of project file\r\n");
		return wait_exit(1);
	}
}
#else
	#error No build target
#endif

#endif
