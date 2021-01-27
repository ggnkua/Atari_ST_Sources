/* Copyright (c) 1990 - present by H. Robbers Amsterdam. * * This file is part of AHCC. * * AHCC is free software; you can redistribute it and/or modify * it under the terms of the GNU General Public License as published by * the Free Software Foundation; either version 2 of the License, or * (at your option) any later version. * * AHCC is distributed in the hope that it will be useful, * but WITHOUT ANY WARRANTY; without even the implied warranty of * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the * GNU General Public License for more details. * * You should have received a copy of the GNU General Public License * along with AHCC; if not, write to the Free Software * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA */
/*
 *	SHLCFG.H
 *
 */

typedef struct shel_cfg
{
	TCS	rootname;
	short
		loads,					/* number of loads */
		makes,					/* all number of 'makes all' */
		makesall,				/* this number of 'makes all' */
	    c_nested_comments,		/* allow nested comments */
		e_max_errors,			/* max no of errors */
		  max_errors,
		f_max_warnings,			/* max no of warnings */
		  max_warnings,
		h_cdecl_calling,		/* standard (cdecl) calling, not Pure_C calling */
		d_define_macro[5],		/* define macro */
		i_include_dir [5],		/* include directory */
		d_lib_dir,				/* library directory */
		k_char_is_unsigned,		/* default char is unsigned */
	 	v,v1,v2,v3, 			/* 4 levels of verbosity */

		i2_68020,				/* >= 68020 */
		i2_68030,				/* 68030 */
		i2_68040,				/* 68040 */
		i2_68060,				/* 68060 */
		use_FPU,				/* enable floating point h/w */
		Coldfire,				/* Coldfire (double is 64 bits) */
#if C99
		c99,					/* 1 = accept C99 syntax, > 1 = implement. */
#endif
		ac_cache_headers,		/* cache headers */
		ag_nogoto,				/* warn goto's */
		af_func_tree,			/* Function tree database */
		ah_project_help,		/* Project help database */
		am_match,				/* Extra wildcard for make */
		ai_int32,				/* default int 32 bits */
		au_supervisor,			/* default .super in assembly */
		al_list_stats,			/* nodestats */
		opt_inherit,			/* Inherit options from parent project */
		aj_auto_depend,			/* Auto dependencies */
		ad_new_peep,			/* do newest peep */
		ak_token_list,			/* print token listing */
		aw_Xnl,					/* default Xn is long (EmuTos) */
	
		ax_debugging,			/* (x) upper case debug options */
		ay_debugging,			/* (y) lower case debug options */
		aa_debugging,			/* all debug flags except z */
		az_debugging,			/* all debug flags except printnode (n,o) */

		ln_nm_list,				/* display 'nm' symbol list */
		lt_load_map,			/* display load map */

		lf_load_slow,			/* dont set 'fast load' bit */
		lr_load_ST,				
		lm_malloc_ST,

		lj_make_object,			/* make object file */
		lg_global_symbols,		/* add global symbols */
		ll_local_symbols,		/* add local symbols */

#ifdef AH1
		f1,f2,f3,f4,f5,
#endif
		no_xy_debugging;		/* no (x,y) debug AT ALL */

	MAX_dir
	     definestr[5],
		 inclstr[5],
		 matchstr,
	     libstr,
		 xoptstr,
		 yoptstr;
} SHEL_CONFIG;

extern SHEL_CONFIG SHL_cfg;
extern OpEntry shel_tab[];

