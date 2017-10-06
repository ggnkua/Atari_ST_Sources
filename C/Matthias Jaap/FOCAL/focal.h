/*
 * Focal, 1981.
 * Dedicated to the old times,
 * when an 8k PDP-8 was considered
 * a BIG machine.
 * Data definitions and macros.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <ctype.h>
#include <setjmp.h>
#include <signal.h>
#include <math.h>

#define	FUNCTIONS			/* enable functions */
#define	NID	16			/* # characters in id */

struct	line
{
	struct	line	*l_fp;		/* Link */
	char	l_lno;			/* Line */
	char	l_gno;			/* Group */
	char	l_text[1];		/* Text */
};

struct	lno
{
	char	ln_lno;			/* Line */
	char	ln_gno;			/* Group */
	int	ln_type;		/* Type */
};

#define	LN_ALL	0			/* All */
#define	LN_GRP	1			/* Group */
#define	LN_LINE	2			/* Line */
#define	LN_NONE	3			/* No number */

struct	control
{
	struct	control	*c_fp;		/* Link */
	int	c_mode;			/* Control mode */
	struct	line	*c_lp;		/* Saved current line */
	char	*c_tp;			/* Saved text pointer */
	struct	sym	*c_sp;		/* Symbol (for) */
	double	c_limit;		/* Limit (for) */
	double	c_step;			/* Step (for) */
};

#define	C_TOP	0			/* Top level */
#define	C_DLINE	1			/* Do line */
#define	C_DGRP	2			/* Do group */
#define	C_DALL	3			/* Do all */
#define	C_FOR	4			/* FOR loop */

struct	sym
{
	struct	sym	*s_fp;		/* Link */
	int	s_type;			/* Type of entry */
	int	s_subs;			/* Subscript */
	union	{
		double	s_value;	/* The data */
		double	(*s_fp)();	/* Function pointer */
	} s_un;
	char	s_id[1];			/* Name */
};

#define	S_SCAL	0			/* Scalar */
#define	S_ARRAY	1			/* An array */
#define	S_FUNC	2			/* A function */

extern	char	cbuf[];
extern	int	intflag;
extern	char	abuf[];
extern	char	*ctp;
extern	struct	line	*line;
extern	struct	line	*clp;
extern	int	mode;
extern	struct	sym	*forsp;
extern	double	forlimit;
extern	double	forstep;
extern	struct	control	*control;
extern	jmp_buf	env;

/*
 * Manage symbols in hash table.
 * -- added by Akira KIDA
 */
#define	N_HASH	255
#define	hash(x)	((int)(((unsigned int)(x)) & N_HASH))
#define	hashid(str)	(((unsigned char)(str)[1] << 5) + (unsigned char)(str)[0])
#define	hashname(str)	hash(hashid(str))
#define	hashsym(str, type, subs)	hash((type == S_ARRAY) ? (hashid(str) + ((subs) << 3)) : hashid(str))
extern	struct	sym	*sym[N_HASH + 1];

#include "proto.h"
