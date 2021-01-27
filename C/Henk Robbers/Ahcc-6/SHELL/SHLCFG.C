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
 *	SHLCFG.C
 *
 */

#include <string.h>
#include "common/aaaa_lib.h"
#include "aaaa.h"
#include "sheldefs.h"
#include "common/kit.h"
#include "shlcfg.h"

extern
SHEL_CONFIG SHL_cfg;

#if GEMSHELL
global
OpEntry shel_tab[]=
{
	{"SHEL= {\n",0,nil},			/* nil stops recursion */
	{"UDIR=%s\n",DIR_MAX,idir.s	,0,0},			/* locations */
	{"MAKN=%s\n",DIR_MAX,mkfn.s	,0,0},
#ifdef CONDBG
	{"NBUG=%d\n",6,&SHL_cfg.no_xy_debugging,0,0,CONDBG,AMENU},
#else
	{"NBUG=%d\n",-1},
#endif

#ifdef KIT								/* options ex options dialogue */
#ifdef COC
	{"CMPT=%d\n",6,&SHL_cfg.c_nested_comments,	COC,KIT},	/* nested comments			*/
#else
	{"CMPT=%d\n",-1},	/* nested comments			*/
#endif
	{"VOPT=%d\n",6,&SHL_cfg.v, 					COV0,KIT},	/* 4 levels of verbosity				*/
	{"V1PT=%d\n",6,&SHL_cfg.v1,					COV1,KIT},
	{"V2PT=%d\n",6,&SHL_cfg.v2,					COV2,KIT},
	{"V3PT=%d\n",6,&SHL_cfg.v3,					COV3,KIT},
#ifdef COH
	{"COPT=%d\n",6,&SHL_cfg.ac_cache_headers,	COH,KIT},	/* cache headers			*/
#else
	{"COPT=%d\n",-1},
#endif
	{"SOPT=%d\n",-1},
#ifdef COK
	{"KOPT=%d\n",6,&SHL_cfg.k_char_is_unsigned,	COK,KIT},	/* default char is unsigned	*/
#else
	{"KOPT=%d\n",-1},
#endif
#ifdef CO2
	{"OPT2=%d\n",6,&SHL_cfg.i2_68020,			CO2,KIT},	/* >= 68020					*/
	{"FOPT=%d\n",6,&SHL_cfg.use_FPU,			CO8,KIT},	/* 68881/2					*/
#else
	{"OPT2=%d\n",-1},
	{"FOPT=%d\n",-1},
#endif
#ifdef CO1
	{"FOP1=%d\n",6,&SHL_cfg.Coldfire,			CO1,KIT},	/* double is 64 bits		*/
#else
	{"FOP1=%d\n",-1},
#endif
#ifdef COPH
	{"PHOP=%d\n",6,&SHL_cfg.ah_project_help,	COPH,KIT},	/* Project database (HELP)	*/
#else
	{"PHOP=%d\n",-1},
#endif
#ifdef COFT
	{"FTOP=%d\n",6,&SHL_cfg.af_func_tree,		COFT,KIT},	/* Function tree view		*/
#else
	{"FTOP=%d\n",-1},
#endif
#ifdef CODM
	{"PDOM=%d\n",6,&SHL_cfg.am_match,			CODM,KIT},  /* Use extra wildcare for make */
#else
	{"PDOM=%d\n",-1},
#endif
#ifdef COAP
	{"APOP=%d\n",6,&SHL_cfg.aj_auto_depend,		COAP,KIT},	/* Autodependencies			*/
#else
	{"APOP=%d\n",-1},
#endif
#ifdef COINH
	{"COIH=%d\n",6,&SHL_cfg.opt_inherit,		COINH,KIT},	/* Inherit options from parent project */
#else
	{"COIH=%d\n",-1},
#endif
#ifdef CORP
	{"XOPT=%d\n",6,&SHL_cfg.h_cdecl_calling,	CORP,KIT},	/* standard calling, not Pure C calling */
#else
	{"XOPT=%d\n",-1},
#endif
#ifdef CO32
	{"LOPT=%d\n",6,&SHL_cfg.ai_int32,			CO32,KIT},	/* default int is 32 bits	*/
#else
	{"LOPT=%d\n",-1},
#endif
#ifdef COSUP
	{"SUPT=%d\n",6,&SHL_cfg.au_supervisor,		COSUP,KIT},	/* default .super in assembly */
#else
	{"SUPT=%d\n",-1},
#endif
#ifdef COXNL
	{"XOPL=%d\n",6,&SHL_cfg.aw_Xnl,				COXNL,KIT},	/* default Xn is long (EmuTos) */
#else
	{"XOPL=%d\n",-1},
#endif
#ifdef COT
	{"TOPT=%d\n",6,&SHL_cfg.lt_load_map,		COT,KIT},	/* load map					*/
	{"TOPN=%d\n",6,&SHL_cfg.ln_nm_list,			COSY,KIT},	/* 'nm' symbol list			*/

	{"FLPT=%d\n",6,&SHL_cfg.lf_load_slow,		COFL,KIT},	/* dont set fast load		*/
	{"LSPT=%d\n",6,&SHL_cfg.lr_load_ST,			COLST,KIT},
	{"MSPT=%d\n",6,&SHL_cfg.lm_malloc_ST,		COMST,KIT},

	{"JOPT=%d\n",6,&SHL_cfg.lj_make_object,		COJ,KIT},	/* make object file			*/
	{"GSOP=%d\n",6,&SHL_cfg.lg_global_symbols,	COG,KIT},	/* global symbols			*/
	{"LSOP=%d\n",6,&SHL_cfg.ll_local_symbols,	COL,KIT},	/* local symbols			*/
#else
	{"TOPT=%d\n",-1},
	{"TOPN=%d\n",-1},

	{"FLPT=%d\n",-1},
	{"LSPT=%d\n",-1},
	{"MSPT=%d\n",-1},

	{"JOPT=%d\n",-1},
	{"GSOP=%d\n",-1},
	{"LSOP=%d\n",-1},
#endif
#ifdef COGO
	{"GTPT=%d\n",6,&SHL_cfg.ag_nogoto,			COGO,KIT},	/* warn goto's				*/
#else
	{"GTPT=%d\n",-1},
#endif

	{"ERFT=%d\n",6,&SHL_cfg.max_errors,			0,KIT},
	{"ERPT=%d\n",6,&SHL_cfg.e_max_errors,		COE,KIT},

	{"WOFT=%d\n",6,&SHL_cfg.max_warnings,		0,KIT},
	{"WOPT=%d\n",6,&SHL_cfg.f_max_warnings,		COF,KIT},

	{"DEFT=%s\n",DIR_MAX,SHL_cfg.definestr     [0]},
	{"DEPT=%d\n",6,     &SHL_cfg.d_define_macro[0],COD,  KIT},
	{"DEF1=%s\n",DIR_MAX,SHL_cfg.definestr     [1]},
	{"DEP1=%d\n",6,     &SHL_cfg.d_define_macro[1],COD1, KIT},
	{"DEF2=%s\n",DIR_MAX,SHL_cfg.definestr     [2]},
	{"DEP2=%d\n",6,     &SHL_cfg.d_define_macro[2],COD2, KIT},
	{"DEF3=%s\n",DIR_MAX,SHL_cfg.definestr     [3]},
	{"DEP3=%d\n",6,     &SHL_cfg.d_define_macro[3],COD3, KIT},
	{"DEF4=%s\n",DIR_MAX,SHL_cfg.definestr     [4]},
	{"DEP4=%d\n",6,     &SHL_cfg.d_define_macro[4],COD4, KIT},

	{"IOFT=%s\n",DIR_MAX,SHL_cfg.inclstr      [0]},
	{"IOPT=%d\n",6,     &SHL_cfg.i_include_dir[0],COI ,KIT},
	{"IOF1=%s\n",DIR_MAX,SHL_cfg.inclstr      [1]},
	{"IOP1=%d\n",6,     &SHL_cfg.i_include_dir[1],COI1,KIT},
	{"IOF2=%s\n",DIR_MAX,SHL_cfg.inclstr      [2]},
	{"IOP2=%d\n",6,     &SHL_cfg.i_include_dir[2],COI2,KIT},
	{"IOF3=%s\n",DIR_MAX,SHL_cfg.inclstr      [3]},
	{"IOP3=%d\n",6,     &SHL_cfg.i_include_dir[3],COI3,KIT},
	{"IOF4=%s\n",DIR_MAX,SHL_cfg.inclstr      [4]},
	{"IOP4=%d\n",6,     &SHL_cfg.i_include_dir[4],COI4,KIT},

#ifdef COMATCH
	{"DOMT=%s\n",DIR_MAX,SHL_cfg.matchstr},
#else
	{"DOMT=%s\n",-1},
#endif

#ifdef COLIB
	{"DOFT=%s\n",DIR_MAX,SHL_cfg.libstr},
	{"DOPT=%d\n",6,     &SHL_cfg.d_lib_dir,		COLIB,KIT},
#else
	{"DOFT=%s\n",-1},
	{"DOPT=%d\n",-1},
#endif
#ifdef CORN
	{"RTFU=%s\n",TCSL,   SHL_cfg.rootname},
#endif
#ifdef LOADS
	{"LOAD=%d\n",6,     &SHL_cfg.loads},
#endif
#ifdef MAKES
	{"MAKE=%d\n",6,     &SHL_cfg.makes},
#endif

#endif

#ifdef AH1
	{"AHF1=%d\n",6,     &SHL_cfg.f1,AH1,KIT},
 #ifdef AH2
	{"AHF2=%d\n",6,     &SHL_cfg.f2,AH2,KIT},
 #endif
 #ifdef AH3
	{"AHF3=%d\n",6,     &SHL_cfg.f3,AH3,KIT},
 #endif
 #ifdef AH4
	{"AHF4=%d\n",6,     &SHL_cfg.f4,AH4,KIT},
 #endif
 #ifdef AH5
	{"AHF5=%d\n",6,     &SHL_cfg.f5,AH5,KIT},
 #endif
#else
	{"AHF1=%d\n",-1},			/* accept, dont write */
	{"AHF2=%d\n",-1},
	{"AHF3=%d\n",-1},
	{"AHF4=%d\n",-1},
	{"AHF5=%d\n",-1},
#endif

	{"KLOP=%d\n",-1},

#ifdef BUGGER
	{"TOPB=%d\n",-1},
	{"SOPB=%d\n",6,&SHL_cfg.al_list_stats,	COLN,BUGGER},
	{"NOPB=%d\n",6,&SHL_cfg.ad_nopeep,		CONN,BUGGER},


	{"AOPB=%d\n",6,&SHL_cfg.aa_debugging,	COA,BUGGER},
	{"ZOPB=%d\n",6,&SHL_cfg.az_debugging,	COZ,BUGGER},

	{"XDFB=%s\n",DIR_MAX,SHL_cfg.xoptstr},
	{"XDPB=%d\n",6,&SHL_cfg.ax_debugging,	COX,BUGGER},

	{"YDFB=%s\n",DIR_MAX,SHL_cfg.yoptstr},
	{"YDPB=%d\n",6,&SHL_cfg.ay_debugging,	COY,BUGGER},

#else
	{"TOPB=%d\n",-1},
	{"SOPB=%d\n",-1},

	{"AOPB=%d\n",-1},
	{"ZOPB=%d\n",-1},

	{"XDFB=%s\n",DIR_MAX,SHL_cfg.xoptstr},
	{"XDPB=%d\n",-1},

	{"YDFB=%s\n",DIR_MAX,SHL_cfg.yoptstr},
	{"YDPB=%d\n",-1},
#endif
	{"}      \n"},
	{"\0"}
};
#endif

#if defined BUGGER && DEBUG && MTDEBUG
global
OBJECT *db2;		/*	b2 debug options dialogue */

global
TEDINFO *b2xoptstr,
		*b2yoptstr;

global
void dial_b2(short hl)
{
	char *d;  short obno;
	SHEL_CONFIG savefl=SHL_cfg;

	keusaf(db2[B2OK]);
	keusaf(db2[B2CANC]);
	strcpy( b2xoptstr ->text,SHL_cfg.xoptstr);
	strcpy( b2yoptstr ->text,SHL_cfg.yoptstr);
	options(shel_tab,OSET);
	d=form_save(db2,0,hl);
	do
	{
		obno=form_move(db2,hl,d,TRUE,0,B2MOVER,B2CANC,&screct);
		if (findopt(shel_tab,obno,BUGGER) ne nil)
		{
			opt_to_cfg(shel_tab, obno, BUGGER, db2, Menu);
			draw_ob(db2,obno,screct);
		}
	} while ( obno ne B2OK and obno ne B2CANC);
	if (obno ne B2CANC )
	{
		strcpy(SHL_cfg.xoptstr,  b2xoptstr ->text);
		strcpy(SHL_cfg.yoptstr,  b2yoptstr ->text);
	othw
		SHL_cfg=savefl;
	}
	form_rest(db2,0,hl,d);
}
#endif

global
void cfg_to_rsc(void)
{
	KIT_REFS *k = &pkit;
	short i;

	loop(i, 5)
		strcpy( k->definestr[i]->text, SHL_cfg.definestr[i]);
	loop(i, 5)
		strcpy( k->inclstr  [i]->text, SHL_cfg.inclstr  [i]);
#ifdef COMATCH
	strcpy( k->matchstr     ->text, SHL_cfg.matchstr);
#endif
#ifdef COLIBDIR
	strcpy( k->libstr       ->text, SHL_cfg.libstr);
#endif
#ifdef CORN
	strcpy( k->rootname     ->text, SHL_cfg.rootname);
#endif
	sprintf(k->max_errors   ->text, "%d",SHL_cfg.max_errors);
	sprintf(k->max_warnings ->text, "%d",SHL_cfg.max_warnings);
#ifdef LOADS
	sprintf(k->loads        ->text, "%d",++SHL_cfg.loads);
#endif
#ifdef MAKES
	sprintf(k->makes        ->text, "%d",SHL_cfg.makes);
#endif
	options(shel_tab, OSET);	/* put options in rsc */
}

global
void rsc_to_cfg(void)
{
	KIT_REFS *k = &pkit;
	short i;

	options(shel_tab, OGET);	/* get options in cfg for output */
	loop(i, 5)
		strcpy(SHL_cfg.definestr[i], k->definestr[i]->text);
	loop(i, 5)
		strcpy(SHL_cfg.inclstr  [i], k->inclstr[i]  ->text);
#ifdef COMATCH
	strcpy(SHL_cfg.matchstr, 	k->matchstr    ->text);
#endif
#ifdef COLIBDIR
	strcpy(SHL_cfg.libstr,      k->libstr      ->text);
#endif
#ifdef CORN
	strcpy(SHL_cfg.rootname,    k->rootname    ->text);
#endif
	SHL_cfg.max_errors   = cdbv(k->max_errors  ->text);
	SHL_cfg.max_warnings = cdbv(k->max_warnings->text);
#ifdef LOADS
	SHL_cfg.loads        = cdbv(k->loads       ->text);
#endif
#ifdef MAKES
	SHL_cfg.makes       = cdbv(k->makes       ->text);
	SHL_cfg.makes+=SHL_cfg.makesall;
#endif
}

void *subst_objects( OBJECT  *obs, bool menu );
void  subst_free   ( USERBLK *ublks );

USERBLK *ubdb2 = nil;

global
void kit_for_shell(void)
{
	KIT_REFS *k = &pkit;

#if defined BUGGER && DEBUG && MTDEBUG
	rsrc_gaddr(0,BUGGER,&db2);
	ubdb2 = subst_objects(db2,false);
	form_align(db2,TRUE,Menu[MTDEBUG].x+3*scr.wchar,20,&screct);
	b2xoptstr =get_tedinfo(db2,COXL);
	b2yoptstr =get_tedinfo(db2,COYL);
#endif
	k->definestr[0] = get_tedinfo(k->tree,CODEF);
	k->definestr[1] = get_tedinfo(k->tree,CODEF1);
	k->definestr[2] = get_tedinfo(k->tree,CODEF2);
	k->definestr[3] = get_tedinfo(k->tree,CODEF3);
	k->definestr[4] = get_tedinfo(k->tree,CODEF4);
	k->inclstr  [0] = get_tedinfo(k->tree,COINCL);
	k->inclstr  [1] = get_tedinfo(k->tree,COINCL1);
	k->inclstr  [2] = get_tedinfo(k->tree,COINCL2);
	k->inclstr  [3] = get_tedinfo(k->tree,COINCL3);
	k->inclstr  [4] = get_tedinfo(k->tree,COINCL4);
#ifdef COMATCH
	k->matchstr     = get_tedinfo(k->tree,COMATCH);
#endif
#ifdef COLIBDIR
	k->libstr       = get_tedinfo(k->tree,COLIBDIR);
#endif
#ifdef CORN
	k->rootname     = get_tedinfo(k->tree,CORN);
#endif
#ifdef LOADS
	k->loads		= get_tedinfo(k->tree,LOADS);
#endif
#ifdef MAKES
	k->makes		= get_tedinfo(k->tree,MAKES);
#endif
	k->max_errors   = get_tedinfo(k->tree,COEN);
	k->max_warnings = get_tedinfo(k->tree,COWN);
}

global
Cstr get_definestr(short i)
{
	return pkit.definestr[i]->text;
}
global
Cstr get_inclstr(short i)
{
	return pkit.inclstr[i]->text;
}
global
Cstr get_matchstr(void)
{
#if COMATCH
	return pkit.matchstr->text;
#else
	return "";
#endif
}
global
Cstr get_libstr(void)
{
	return pkit.libstr->text;
}
global
Cstr get_rootname(void)
{
#ifdef CORN
	return pkit.rootname->text;
#else
	return "main";
#endif
}
global
short get_max_errors(void)
{
	return cdbv(pkit.max_errors->text);
}
global
short get_max_warnings(void)
{
	return cdbv(pkit.max_warnings->text);
}

global
CFGNEST shell_cfg		/* FILE *fp, OpEntry **tab, short lvl, short io */
{
	if (io eq 1)
		saveconfig(fp, shel_tab, lvl+1);
	else
		loadconfig(fp, shel_tab, lvl+1);
}

global
void end_shlcfg(void)
{
 	#if defined BUGGER && DEBUG && MTDEBUG
	subst_free(ubdb2);
	#endif
}