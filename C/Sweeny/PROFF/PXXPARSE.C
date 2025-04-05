#include <stdio.h>
#include <ctype.h>
#include "proff.h"
#include "debug.h"
#include "lextab.h"

#define brk brrk

#define RUNOFF	1 		/* recognise RUNOFF commands */

char literal = NO;		/* literal flag		     */

/*
 * command - perform formatting command
 *
 */
command(buf)
char buf[];
{
	char token[MAXTOK], xtoken[MAXTOK], variable[MAXTOK], *defn;
	char special[MAXTOK];
	int argtyp, ct, at, spval, i, flags;
	register int val, n, rest;
	char onflag = FALSE;
	char offlag = FALSE;
	struct lexlist *xp;

	dovar(tbuf1,buf);	/* use scratch buffer to expand variables */
	strcpy(buf,tbuf1);

	i = 1;
	n = getwrd(buf, &i, token);	/* get the command token */
	rest = i;			/* remaining string */
	ct = comtype(token, n, &defn, &flags);
	if (ct == UNKNOWN)
		return;
	if (literal && ct != ELT) {	/* ignore while literal  */
		put(buf);
		return;
	}

#ifdef DOUBLEWORD
	if (flags == 2) {	/* check for 2-word command */
		n = getwrd(buf, &i, xtoken);
		if (n == 0) {
			fprintf(stderr,"%c%s what ?\n", cchar, token);
			return;
		}
		if ((at = comtype(xtoken, n, &defn, &flags)) == UNKNOWN) {
			fprintf(stderr,"%c%s %s unknown.\n", cchar,
			token,
			xtoken);
			return;
		}
		else
			ct += at;
	}
#endif

	doesc(buf, variable, MAXLINE);	/* expand escapes */
	n = getarg(buf, &i, xtoken);	/* first parameter*/
	argtyp = '\n';	/* defaulted ** cludge ** */
	val = 0;
	if (n > 0) {
		if (*xtoken == '+' || *xtoken == '-') {
			argtyp = *xtoken;
			val = atoi(xtoken+1);
		}
		else if (isdigit(*xtoken)) {
			argtyp = 0;
			val = atoi(xtoken);
		}
		else {
			/* check some common flags */
			if (strcmp("on",xtoken) == 0)
				onflag = TRUE;
			else if (strcmp("off",xtoken) == 0)
				offlag = TRUE;
		}
	}

	switch(ct) {

	case MACRO:
		eval(buf, defn);
		break;
	case FI:
		brk();
		fill = YES;
		break;
	case NF:
		brk();
		fill = NO;
		break;
	case BR:
		brk();
		break;
	case LS:
		set(&lsval, val, argtyp, 1, 1, HUGE);
		break;
	case CE:
		brk();
		if (onflag)
			CEon = TRUE;
		else if (offlag) {
			CEon = FALSE;
			ceval = 0;		/* reset */
		}
		else
			set(&ceval, val, argtyp, 1, 0, HUGE);
		break;
	case UL:
		if (onflag) {
			ULon = TRUE;
			break;
		}
		else if (offlag) {
			ULon = FALSE;
	 		ulval = 0;		/* reset */
			break;
		}
		else
			set(&ulval, val, argtyp, 0, 1, HUGE);

		if (!isdigit(*xtoken)) {
			if (strcmp("all",xtoken) == 0) {
					ulblnk = '_';
					ulval = 0;
			}
			else if (strcmp("words",xtoken) == 0) {
				ulblnk = ' ';
				ulval = 0;
			}
		}
		break;
	case BD:
		if (bolding == YES) {
			if (onflag)
				BDon = TRUE;
			else if (offlag) {
				BDon = FALSE;
				boval = 0;	/* reset */
			}
			else
				set(&boval, val, argtyp, 0, 1, HUGE);
		}
		break;
	case HE:
		gettl(buf, ehead, ehlim);
		gettl(buf, ohead, ohlim);
		break;
	case FO:
		gettl(buf, efoot, eflim);
		gettl(buf, ofoot, oflim);
		break;
	case BP:
		if (paging == NO)
			break;
		brk();
		if (lineno > 0)
			space(HUGE);
		set(&curpag, val, argtyp, curpag+1, -HUGE, HUGE);
		newpag = curpag;
		break;
	case SP:
		set(&spval, val, argtyp, 1, 0, HUGE);
		space(spval);
		break;
	case IN:
		brk();
		set(&inval, val, argtyp, 0, 0, rmval-1);
		tival = inval;
		break;
	case RM:
		set(&rmval, val, argtyp, PAGEWIDTH, tival+1, HUGE);
		break;
	case TI:
		brk();
		set(&tival, val, argtyp, 0, 0, rmval);
		break;
	case LEX:	/****/
		if ((xp = remove(xtoken,lextab)) != NULL) {
			if (getwrd(buf, &i, variable) != 0)
				lexinstal(variable,xp->val,xp->flag,lextab);
		}
		else
		    fprintf(stderr,"%s undefined.\n",xtoken);
		break;
	case PN:	/****/
		if (strcmp(xtoken,"roman") == 0)
			roman = TRUE;
		else if (strcmp(xtoken,"arabic") == 0)
			roman = FALSE;
		else
			fprintf(stderr,"%c%s does not have %s option.\n",
			cchar,token,xtoken);
		break;
	case IG:	/****/
		break;
	case SET:	/****/
		if (n > 0) {
			if (isdigit(*xtoken)) {
				fprintf(stderr,"illegal variable name %s\n",
				xtoken);
				break;
			}
			*variable = '\0';
			n = getarg(buf, &i, variable);
			if (n <= 0) {
				fprintf(stderr,"%s: ", xtoken);
				gets(variable);

			}
			if (*variable != '\0')
				install(xtoken, variable, gentab);
		}
		else
			fprintf(stderr,"%c%s needs a variable name.\n",
			cchar, token);
		break;
	case GET:	/****/
		if (n > 0) {
			if (isdigit(*xtoken)) {
				fprintf(stderr,"illegal variable name %s\n",
				xtoken);
				break;
			}
			*variable = '\0';
			n = getarg(buf, &i, tbuf3); /* using temp buf3 */
			if (n > 0) {
				fprintf(stderr,"%s", tbuf3);
				gets(variable);

			}
			if (*variable != '\0')
				install(xtoken,variable, gentab);
		}
		else
			fprintf(stderr,"%c%s needs a variable name.\n",
			cchar, token);
		break;
	case CL:	/****/
		if (argtyp == '\n') {
			clast->level = 0;
			clast->str = NULL;
		}
		else {
			skipbl(buf,&i);
			if (*(buf+i) == '\0')
				break;		/* no contents line here ! */
			clast->level = val * 3; /* level * indent 	   */
			n = i;
			while(*(buf+n) != '\n')
				n++;
			*(buf+n) = '\0';	/* destroy CR with a null  */
			clast->str = strsave(buf+i);
			clast->page = curpag;
		}
		clast->nextc = (struct clist *) malloc(sizeof(struct clist));
		p_memoryus += sizeof(struct clist);
		clast = clast->nextc;
		clast->nextc = NULL;
		break;
	case PC:	/****/
		brk();
		clast = chead;
		while(clast->nextc != NULL) {
			if (clast->str == NULL)
				put("\n");
			else {
				tival = (int) clast->level + inval;
				i = rmval - tival;
				docline(variable, i, clast->str, clast->page);
				put(variable);
			}
			clast = clast->nextc;
		}
		break;
	case DBO:	/****/
		bolding = NO;
		break;
	case EBO:	/****/
		bolding = YES;
		break;
	case AP:	/****/
		autopar = YES;
		break;
	case NAP:	/****/
		autopar = NO;
		break;
	case SAV:	/****/
		brk();
		save();
		break;
	case RST:	/****/
		brk();
		restore();
		break;
	case NPA:	/****/
		paging = NO;
		savpl = plval;
		plval = HUGE;
		bottom = plval - m3val - m4val;
		break;
	case PGI:	/****/
		bottom = lineno - 1;	/* force end-of-page */
		brk();
		plval = savpl;
		break;
	case LTR:	/****/
		brk();
		if (save()) {
			inval = 0;
			rmval = 132;
			autopar = NO;
			lsval = 0;
			fill = NO;
			literal = YES;
		}
		break;
	case ELT:	/****/
		restore();
		literal = NO;
		break;
	case WR:	/****/
		brk();
		getpstr(buf+rest,special);
		defn = special;
		while(*defn)
			putchar(*defn++);
		break;
	case PL:
		if (paging == NO)
			break;
		set(&plval, val, argtyp, PAGELEN,
		m1val + m2val + m3val + m4val + 1, HUGE);
		bottom = plval - m3val - m4val;
		break;
	case PO:
		set(&offset, val, argtyp, 0, 0, rmval - 1);
		break;
	case M1:
		set(&m1val, val, argtyp, 3, 0,
		plval - m2val - m3val - m4val - 1);
		break;
	case M2:
		set(&m2val, val, argtyp, 2, 0,
		plval - m1val - m3val - m4val - 1);
		break;
	case M3:
		set(&m3val, val, argtyp, 2, 0,
		plval - m1val - m2val - m4val - 1);
		bottom = plval - m3val - m4val;
		break;
	case M4:
		set(&m4val, val, argtyp, 3, 0,
		plval - m1val - m2val - m3val - 1);
		bottom = plval - m3val - m4val;
		break;
	case EH:
		gettl(buf, ehead, ehlim);
		break;
	case OH:
		gettl(buf, ohead, ohlim);
		break;
	case EF:
		gettl(buf, efoot, eflim);
		break;
	case OF:
		gettl(buf, ofoot, oflim);
		break;
	case CC:
		cchar = *xtoken;
		if (cchar == '\0' || cchar == '\n')
			cchar = '.';
		if ((lineno + val) > bottom && lineno <= bottom) {
			space(val);
			lineno = 0;
		}
		break;
	case EC:
		genesc = *xtoken;
		if (genesc == '\0' || genesc == '\n')
			genesc = '_';
		break;
	case NE:
		if ((lineno + val) > bottom && lineno <= bottom) {
			space(val);
			lineno = 0;
		}
		break;
	case BS:
		set(&bsval, val, argtyp, 1, 0, HUGE);
		break;
	case JU:
		rjust = YES;
		break;
	case NJ:
		rjust = NO;
		break;
	case SO:
		if (n <= 0)
			return;
		if (level + 1 == NFILES)
			error("? SO commands nested too deeply.");
		if ((infile[level + 1] = fopen(xtoken, "r")) != NULL) {
			level++;
			if (verbose == YES)
#ifdef rainbow
				fprintf(stderr,"source \033[7m%s\033[0m\n",
					xtoken);
#else
				fprintf(stderr,"source %s\n",xtoken);
#endif
		}
		else
			fprintf(stderr,"%s: cannot open.\n",xtoken);
		break;
	case OU:	/*****/
		/* skip for now. */
		break;

	case OE:	/*****/
		/* skip for now. */
		break;

	case CU:
		ulblnk = '_';
		set(&ulval, val, argtyp, 0, 1, HUGE);
		break;
	case DE:

#ifdef DEBUG
printf("Command++: calling dodef Fp %ld\n",infile[level]);
#endif
		dodef(buf, infile[level]);
		break;
	case NR:
		if (n <= 0)
			return;
		if (*xtoken < 'a' || *xtoken > 'z')
			error("invalid number register [%c].",*xtoken);

		val = getval(buf, &i, &argtyp);
		set(&nr[xtoken[0] - 'a'], val, argtyp, 0, -HUGE, HUGE);
		break;
	case ST:
		if (argtyp == '-')
			spval = plval;
		else
			spval = 0;
		set(&spval, val, argtyp, 0, 1, bottom);
		if (spval > lineno && lineno == 0)
			phead();
		if (spval > lineno)
			space(spval - lineno);
		break;
	case RESET:	/****/
		finit();
		break;
	default:
		error("? Botch in command.");
		break;
	}
}

/*
 * comtype - decode the command type
 *
 */
int
comtype(buf, siz, defn, flags)
char buf[];
int siz;
char **defn;
int *flags;
{

	struct hashlist *np;
	struct lexlist *xp;
	extern	struct lexlist *lexlook();
	int i,comtyp;
	char c1,c2;


#ifdef DEBUG
	printf("comtype:  (token)\n");
#endif

	if ((np = lookup(buf, macrotab)) != NULL) {
		*defn=np->def;
		return(MACRO);
	}
	comtyp = UNKNOWN;

	if (*buf == '#' || *buf == '!')
		return(comtyp);

	if ((xp = lexlook(buf,lextab)) != NULL)
		if (onlyrunoff && (xp->flag != RUNOFF)) {
			fprintf(stderr,"%c%s is not a runoff command.\n",
			cchar,buf);
			return(UNKNOWN);
		}
		else {	
			comtyp = xp->val;
			*flags = xp->flag;
		}

	if (comtyp == UNKNOWN)
		fprintf(stderr,"unknown command %c%s\n",cchar,buf);
	return(comtyp);
}
