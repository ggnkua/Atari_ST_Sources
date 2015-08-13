#include <stdio.h>
#include <ctype.h>
#include "as.h"
#include "table.h"
#include "lookup.h"

int     Line_num = 0;           /* current line number                  */
char    *File_name = "";        /* current file name                    */
int     Err_count = 0;          /* total number of errors               */
char    Line[MAXBUF] = {0};     /* input line buffer                    */
char    Label[MAXLAB] = {0};    /* label on current line                */
char    Op[MAXOP] = {0};        /* opcode mnemonic on current line      */
char    Ext = 'u';              /* optional size after mnemonic         */
char    *Optr = 0;              /* pointer into current Operand field   */
int     Size;                   /* bitmap form of Ext                   */
int     Pc = 0;                 /* Program Counter                      */
int     Old_pc = 0;             /* Program Counter at beginning         */
int     Pass = 1;               /* Current pass #                       */

int     Lflag = 1;              /* listing flag 0=nolist, 1=list        */
int     Debug = 0;              /* debug flag                           */

extern int E_total;
int     Fwdsize = W;            /* default fwd ref size                 */
extern int P_total;

/*
 *      as ---  cross assembler main program
 */
main(argc,argv)
int     argc;
char    **argv;
{
	int     xargc;
	char    **xargv;

	if(argc < 2){
		printf("Usage: %s [files]\n",*argv);
		exit(1);
		}
	Line[MAXBUF-1] = '\n';	/* guard against garbage input */
	exprinit();	/* forward ref init */
	localinit();	/* target machine specific init. */

	xargc = argc;
	xargv = argv;
	while( --xargc ){
		xargv++;
		if( **xargv == '-' )
			doflag(*xargv);
		else
			make_pass(*xargv);
		}
	if( Err_count == 0 ){
		Pass++;
		Pc      = 0;
		E_total = 0;
		P_total = 0;
		Lflag   = 1;
		expreinit();
		srecinit(OBJNAME);
		while(--argc){
			argv++;
			if( **argv == '-' )
				 ;
			else
				make_pass(*argv);
			}
		srecend(0);		/* end of S-records */
		}
if(Debug&DUMP){
	dump_regs();
	dump_comp();
	dump_mne();
	}
	exit(Err_count);
}

/*
 *      doflag --- process optional flag argument
 */
doflag(s)
char *s;
{
	switch( *(s+1) ){
	case 'x':       Debug = atoi(s+2); break;
	case 'l':       Lflag = 1; break;
	case 'f':       Fwdsize = L; break;
	default:
		serror("Unrecognized flag: -%s",s);
	}
}

/*
 *      make_pass --- read source code lines and generate code
 */
make_pass(s)
char *s;
{
	int     saveline = Line_num;
	char    *savefile = File_name;
	int     savelflag = Lflag;
	FILE    *f;
	FILE    *fopen();
	extern int P_force;

	Line_num = 0;
	File_name = s;

	if( (f = fopen(s,"r")) == NULL )
		error("Can't find file");
	else{
		while( getaline(f) ){
			P_force = 0;    /* No force unless bytes emitted */
			if(parse_line())
				process();
			if(Pass == 2 && Lflag)
				print_line();
			P_total = 0;    /* reset byte count */
			}
		f_record();
		fclose(f);
		}
	Line_num = saveline;
	File_name = savefile;
	Lflag = savelflag;
}

/*
 *      getaline --- collect (possibly continued) an input line
 */
getaline(f)
FILE *f;
{
	char *fgets();
	register char *p = Line;
	int remaining = MAXBUF-2;       /* space left in Line */
	int len;                        /* line length */

	while( fgets(p,remaining,f) != (char *)NULL ){
		Line_num++;
		if((len = strlen(p)-2)<=0)
			return(1);      /* just an empty line */
		p += len;
		if( *p != '\\' )
			return(1);      /* not a continuation */
		remaining -= len+2;
		if(remaining<3)
			warn("Continuation too long");
		}
	return(0);
}

/*
 *      parse_line --- split input line into label, op and operand
 */
parse_line()
{
	register char *ptrfrm = Line;
	register char *ptrto = Label;
	register int mnelen;
	char	*skip_white();

	if( *ptrfrm == '*' || *ptrfrm == '#' || *ptrfrm == '\n' )
		return(0);      /* a comment line */

	while( !delim(*ptrfrm) )
		*ptrto++ = *ptrfrm++;
	if(*--ptrto != ':')ptrto++;     /* allow trailing : */
	*ptrto = '\0';

	ptrfrm = skip_white(ptrfrm);

	ptrto = Op;
	while( !delim(*ptrfrm) )
		*ptrto++ = mapdn(*ptrfrm++);
	*ptrto = '\0';

	Ext = 'u';              /* default extension */
	if( (mnelen = strlen(Op))>2 && Op[mnelen-2]=='.'){
		if( alpha(Op[mnelen-1]) ){
			Ext = mapdn(Op[mnelen-1]);
			Op[mnelen-2] = '\0';
			}
		}

	ptrfrm = skip_white(ptrfrm);
	Optr = ptrfrm;

if(Debug&PARSE)printf("Parseline: <%s> <%s.%c> <%s",Label,Op,Ext,Optr);
	return(1);
}

/* convert ascii Ext on mnemonic to bit map form */
int etos[] = {0, B, 0, D, 0, 0, 0, 0, 0, 0, 0, L, 0,
	      0, 0, P, 0, 0, S, 0, U, 0, W, X, 0, 0};

/*
 *	process --- determine mnemonic class and act on it
 */
process()
{
	register struct mne  *m;
	register struct tmpl *t;
	struct mne *mne_look();
	struct tmpl *tmpl_match();

	Old_pc = Pc;            /* setup `old' program counter */
	Size = etos[Ext-'a'];   /* setup size from extension */

	if(*Op=='\0'){           /* no mnemonic */
		if(*Label)
			install(Label,Pc,SYM);
		}
	else if( (m = mne_look(Op))== NULL)
		serror("Unrecognized Mnemonic: %s",Op);
	else if( (t = tmpl_match(m->ptmpl,m->ntmpl))==NULL)
		error("Bad size or wrong operand(s)");
	else{
		if( *Label && t->class != EQU && t->class != FEQU )
			install(Label,Pc,SYM);
		do_op(t->class,t->op,t->op2);
		}
}
