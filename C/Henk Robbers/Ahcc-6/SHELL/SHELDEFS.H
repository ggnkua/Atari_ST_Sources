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

/*		defines for the shell
 */

/*	development stages
	BIP_ED						/* editor built_in
		(In fact the shell is built in the editor, or more precise: editor and shell
		 both are components of the ultimate GEM program) */
	BIP_CC						/* compiler built_in 29 nov 93 */
	BIP_OPT						/* optimizer built_in in compiler */
	BIP_ASM						/* assembler built_in */
	BIP_LD						/* linker (loader) built_in */
*/

#define fslash '/'
#define sfslash "/"
#define bslash '\\'
#define sbslash "\\"

/*
 *	structs & defines & proc decl's		15 jan '91
 */

typedef short BIP(short argc, char argv[]);

typedef struct
{
	char	app[6];
	char	prg[6];
	char	ttp[6];
	char	tos[6];
	char	c  [6];
	char	a  [6];
	char	s  [6];
	char	o  [6];
	char	ovl[6];
	char	l  [6];
	char	lib[6];
	char    prj[6];
} SH_SUFS;

/*
 *	We build lists of the various file types we're given. Within each
 *	type, MAXF says how many we can deal with.
 */

typedef enum
{
	FTC,FTA,FTS,FTO,FTJ		/* 10'19 HR: v6 project nesting: FTJ */
} FTY;

typedef struct fcsol
{
	S_path f, nest;
	FTY csol;
	struct fcsol *next;
} FCSOADL;

typedef struct
{
	short n,d;
	FCSOADL *ft, *last;
} FN;

typedef struct
{
	FN in,    		/* .c .s .o .l .a .prj files */
	   h;			/* .h .i files */
	S_path op;		/* resulting output */
} SH_FTABS;

#define ALLC TRUE
#define INPL FALSE

extern short menu_prj_l;
extern SH_SUFS sufs;

typedef struct project
{
	struct project *next, *prior, *parent, *first, *last;
	
	S_path fn, pad;
	char *makeCoptions,
	     *makeSoptions,
	     *makeLoptions;

	bool makeLib;
	short depth;

	SH_FTABS files;

} PRJ;

extern PRJ root_project;

DOSTIME tostime			(void);
void	mklower			(char *s);
bool	inlist			(FN *t, S_path *f, short ty);
short 	putlist			(char *t[],short *tc,char *f);
bool 	is_suf			(char *f,char *s);
bool 	isfile			(char *f);
void 	myexit			(short);
S_path 	defofile		(PRJ *prj, S_path *output);
void	remove_project	(void);
void	printlists		(FILE *fp, PRJ *prj, char *pad);
void *	mmalloc			(long l, char *op1, char *op2, short key);
BIP		compiler,
        linker;
short 	tos_call		(void *, char *);

void	loadmake		(char *f, bool clean);
bool	warn_opt		(void);
void 	domakeall		(PRJ *prj);
short 	docomp			(PRJ *prj, char *f, char *o, bool asm);
void	do_compile		(PRJ *prj, char *f);
bool 	dold			(PRJ *prj);
void 	domake			(PRJ *prj, bool msg);
void	menu_prj		(char *pn);
void	prj_params		(char *);
Cstr	get_definestr	(short);
Cstr	get_inclstr		(short);
Cstr	get_matchstr	(void);
Cstr	get_libstr		(void);
short 	get_max_errors	(void);
short 	get_max_warnings(void);

extern
S_path mkpad, mkfn;

extern short pdrive;