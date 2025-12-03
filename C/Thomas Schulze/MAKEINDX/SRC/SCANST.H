
/*
 *
 * Copyright (C) 1987 	Pehong Chen	(phc@renoir.berkeley.edu)
 * Computer Science Division
 * University of California at Berkeley
 *
 */

#define	COMMENT			'%'
#define	STR_DELIM		'"'
#define	CHR_DELIM		'\''

#define	KEYWORD			"keyword"
#define	AOPEN			"arg_open"
#define	ACLOSE			"arg_close"
#define ROPEN			"range_open"
#define RCLOSE			"range_close"
#define LEVEL			"level"
#define QUOTE			"quote"
#define ACTUAL			"actual"
#define ENCAP			"encap"
#define ESCAPE			"escape"

#define	IDX_KEYWORD		"\\indexentry"
#define	IDX_AOPEN		'{'
#define	IDX_ACLOSE		'}'
#define	IDX_ROPEN		'('
#define	IDX_RCLOSE		')'
#define	IDX_LEVEL		'!'
#define IDX_QUOTE		'"'
#define	IDX_ACTUAL		'@'
#define	IDX_ENCAP		'|'
#define	IDX_ESCAPE		'\\'

#define	COMPOSITOR		"page_compositor"
#define	COMPOSITOR_DEF		"-"
#define	PRECEDENCE		"page_precedence"
#define	PRECEDENCE_DEF		"rnaRA"
#define ROMAN_LOWER		'r'
#define ROMAN_UPPER		'R'
#define ARABIC			'n'
#define ALPHA_LOWER		'a'
#define ALPHA_UPPER		'A'
#define ROMAN_LOWER_OFFSET	10000
#define ROMAN_UPPER_OFFSET	10000
#define ARABIC_OFFSET		10000
#define ALPHA_LOWER_OFFSET	26
#define ALPHA_UPPER_OFFSET	26

#define PREAMBLE		"preamble"
#define PREAMBLE_DEF		"\\begin{theindex}\n"
#define PREAMBLE_LEN		1
#define	POSTAMBLE		"postamble"
#define	POSTAMBLE_DEF		"\n\n\\end{theindex}\n"
#define	POSTAMBLE_LEN		3

#define	SETPAGEOPEN		"setpage_prefix"
#define	SETPAGECLOSE		"setpage_suffix"

#if    KCC_20
/* KCC preprocessor bug collapses multiple blanks to single blank */
#define	SETPAGEOPEN_DEF		"\n\040\040\\setcounter{page}{"
#else
#define	SETPAGEOPEN_DEF		"\n  \\setcounter{page}{"
#endif

#define	SETPAGECLOSE_DEF	"}\n"
#define	SETPAGE_LEN		2

#define	GROUP_SKIP		"group_skip"

#if    KCC_20
/* KCC preprocessor bug collapses multiple blanks to single blank */
#define	GROUPSKIP_DEF		"\n\n\040\040\\indexspace\n"
#else
#define	GROUPSKIP_DEF		"\n\n  \\indexspace\n"
#endif

#define	GROUPSKIP_LEN		3
#define	LETHEAD_PRE		"lethead_prefix"
#define	LETHEADPRE_DEF		""
#define	LETHEADPRE_LEN		0
#define	LETHEAD_SUF		"lethead_suffix"
#define	LETHEADSUF_DEF		""
#define	LETHEADSUF_LEN		0
#define	LETHEAD_FLAG		"lethead_flag"
#define	LETHEADFLAG_DEF		0

#define	ITEM_0			"item_0"
#define	ITEM_1			"item_1"
#define	ITEM_2			"item_2"
#define	ITEM_01			"item_01"
#define	ITEM_x1			"item_x1"
#define	ITEM_12			"item_12"
#define	ITEM_x2			"item_x2"

#if    KCC_20
/* KCC preprocessor bug collapses multiple blanks to single blank */
#define	ITEM0_DEF		"\n\040\040\\item\040"
#define	ITEM1_DEF		"\n\040\040\040\040\\subitem\040"
#define	ITEM2_DEF		"\n\040\040\040\040\040\040\\subsubitem\040"
#else
#define	ITEM0_DEF		"\n  \\item "
#define	ITEM1_DEF		"\n    \\subitem "
#define	ITEM2_DEF		"\n      \\subsubitem "
#endif

#define	ITEM_LEN		1

#define	DELIM_0			"delim_0"
#define	DELIM_1			"delim_1"
#define	DELIM_2			"delim_2"
#define	DELIM_N			"delim_n"
#define	DELIM_R			"delim_r"
#define	DELIM_DEF		", "
#define	DELIMR_DEF		"--"

#define	ENCAP_0			"encap_prefix"
#define	ENCAP_1			"encap_infix"
#define	ENCAP_2			"encap_suffix"
#define	ENCAP0_DEF		"\\"
#define	ENCAP1_DEF		"{"
#define	ENCAP2_DEF		"}"

#define LINEMAX			"line_max"
#define INDENT_SPACE		"indent_space"
#define INDENT_LENGTH		"indent_length"
#define INDENTSPC_DEF		"\t\t"
#define INDENTLEN_DEF		16

#define STY_ERROR(F, D) { \
	if (idx_dot) { \
		fprintf(ilg_fp, "\n"); \
		idx_dot = FALSE; \
	} \
	fprintf(ilg_fp, "** Input style error (file = %s, line = %d):\n   -- ", \
			sty_fn, sty_lc); \
	fprintf(ilg_fp, F, D); \
	sty_ec++; \
	put_dot = FALSE; \
}

#if    KCC_20
/* KCC preprocessor bug collapses multiple blanks to single blank */
#define	STY_ERROR2(F, D1, D2) { \
 	if (idx_dot) { \
		fprintf(ilg_fp, "\n"); \
		idx_dot = FALSE; \
	} \
	fprintf(ilg_fp, "** Input style error (file = %s, line = %d):\n\040\040 -- ", \
			sty_fn, sty_lc); \
	fprintf(ilg_fp, F, D1, D2); \
	sty_ec++; \
	put_dot = FALSE; \
}
#else
#define	STY_ERROR2(F, D1, D2) { \
 	if (idx_dot) { \
		fprintf(ilg_fp, "\n"); \
		idx_dot = FALSE; \
	} \
	fprintf(ilg_fp, "** Input style error (file = %s, line = %d):\n   -- ", \
			sty_fn, sty_lc); \
	fprintf(ilg_fp, F, D1, D2); \
	sty_ec++; \
	put_dot = FALSE; \
}
#endif

#define STY_DOT	{ \
	idx_dot = TRUE; \
	if (verbose) \
		fprintf(stderr, DOT); \
	fprintf(ilg_fp, DOT); \
}

#define	STY_SKIPLINE { \
	while (GET_CHAR(sty_fp) != LFD); \
	sty_lc++; \
}

#define SCAN_NO(N) { \
	fscanf(sty_fp, "%d", N); \
}

#define MULTIPLE(C) { \
	STY_SKIPLINE; \
	STY_ERROR2("Multiple instances of type `%c' in page precedence specification `%s'.\n", C, page_prec); \
	return (FALSE); \
}

