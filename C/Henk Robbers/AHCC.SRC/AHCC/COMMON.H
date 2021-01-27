/* Copyright (c) 1990 - present by H. Robbers.
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

/* a multitude of common variables put in a single struct.
   reduces number of external names, reduces name space confusion.
 */

#include "common/hierarch.h"

typedef struct
{
	bool noregs, new_peep;
} PRAGMATS;

typedef struct common
{
/* Pure C compatible options */
	bool
		i2_68020,
		i2_68030,
		i2_68040,
		i2_68060,
		use_FPU,
		Coldfire,
		prelude,
		a_strict_ANSI,
		b_output_DRI,
		c_nested_comments;
	short
		e_max_errors,
		f_max_warnings,
		l_identifier_max_length;

	bool
		g_optimum_size,
		h_cdecl_calling,
		j_no_jump_optimization,
		k_char_is_unsigned,
		m_string_merging,
		n_nmlist,
		p_absolute_calls,
		q_pascal_calling,
		s_frame_pointer,
		t_stack_checking;
	short
		v_Cverbosity;
	bool
		x_add_underline,
		y_debugging,
		z_register_reload;
/* end of Pure C compatible options */

/* AHCC specific options */
#if BIP_ASM || FOR_A
	TP 	last_decl;
	short
		lang,
	    xlang,
		asm_if;			/* 04'12 HR: allow single = for 'equals' */
#endif
	bool
		ab_no_branch_reversals,
		ac_cache_headers,
		ae_no_extracodes,
		ag_nogoto,
		al_list_stats,
		af_func_tree,
		ah_project_help,
		ai_int32,
		aj_auto_depend,
		au_supervisor,
		an_no_O,
		ar_no_registerization,
		at_Tony,
		ad_new_peep,
		aw_Xnl,
/* end of AHCC specific options */

/* internal switches */
		skip_X,
		in_if_X,
		incbin,			/* incbin (include binary file in asm) */
		in_def,
		skip_id,
		eof,
		first_declare;

	short
		yflags[26],		/* lower case debug flags */
		xflags[26],		/* upper case debug flags */
		anydebug,
		nmerrors, egiven,nmwarns, wgiven, nmmessages,
		npred,
		idir_n,
		idir_put,
		lblnum,
		tk_flags;

	PRAGMATS pragmats;

	enum cpus CPU;

	AHCOUT
		*output;

	S_path
		output_name,
		input_name,		/* for optimizer */
		input_dir,
		lastdir,
		includer;

	VP	iftab,
		inctab,
		flow_chart,
		fltab;

	NP	strsave, strlast,
		consave, conlast;

	XP	holdtok,
		expanding;

	TP	optab,
		casttab,
		tagtab;
#if PRLN
	void *
		To_prln;		/* for dynamic print node */
#endif
#if BIP_ASM
	TP	dot_labels, asmvars;
	bool
		dot_seen,			/* for bra .label; the dot is eaten by isize() */
		need_second_pass;	/* 05'13 v4.15 */
	XP equs;				/* list of equ'd expressions */
#endif

	FP	prtab;
	SCP scope;

	short
		asm_clo,
		asm_clock;

	LEX_RECORD
		* save_LEX;

	long
		lineno,
		clockopt,
		C_bytes;
#if NODESTATS
	long ncnt[LASTTY-FIRSTTY];
	long operators,ids,symbols,defs,
		 strcode,npcode,xcopied;
#endif
} COMMON;

extern COMMON G;
