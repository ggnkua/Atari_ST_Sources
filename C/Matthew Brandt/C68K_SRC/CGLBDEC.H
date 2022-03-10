 /*
 *	68000 C compiler
 *
 *	Copyright 1984, 1985, 1986 Matthew Brandt.
 *  all commercial rights reserved.
 *
 *	This compiler is intended as an instructive tool for personal use. Any
 *	use for profit without the written consent of the author is prohibited.
 *
 *	This compiler may be distributed freely for non-commercial use as long
 *	as this notice stays intact. Please forward any enhancements or questions
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */

/*      global declarations     */

extern FILE             *input,
                        *list,
                        *output;

extern int              lineno;
extern int              nextlabel;
extern int              lastch;
extern int              lastst;
extern char             lastid[20];
extern char             laststr[MAX_STLP1];
extern long             ival;
extern double           rval;

extern TABLE            gsyms,
                        lsyms;
extern SYM              *lasthead;
extern struct slit      *strtab;
extern int              lc_static;
extern int              lc_auto;
extern struct snode     *bodyptr;       /* parse tree for function */
extern int              global_flag;
extern TABLE            defsyms;
extern int              save_mask;      /* register save mask */

