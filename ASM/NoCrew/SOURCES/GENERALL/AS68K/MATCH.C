#include <stdio.h>
#include "as.h"
#include "table.h"
#include "lookup.h"

#define MAXEA   30

struct ea Eas[MAXEA] = {0};   /* parsed ea's */
extern char *Optr;
extern char *skip_white();
extern int Debug;
extern int Size;
extern int Fwdsize;
extern int Force;

char *eanames[] = {
	"---", "Dn", "An", "(An)", "(An)+", "-(An)",
	"indexed", "expr", "#imm", "pc-indexed",
	"Dn:Dn", "(Rn):(Rn)", "RList", "{Dn/#:Dn/#}",
	"Cn", "CCR", "SR", "FPn", "FPCn", "FPList",
	"FPn:FPn", "FPClist", "{Dn}", "{#}", "Pn", "String",
	"Rn", "AnyEA", "CtlEA", "AltMem", "DataAlt", "Alterable",
	"Data", "--CtlAlt", "Ctl++", "CtlAlt", "Memory", "Dn/Cn/Mask",
	"ExprList",
	0
	};

/*
 *      tmpl_match --- match size and operands of instruction
 *
 *      Given a pointer to N entries in the template table, scan
 *      and try to match the operand field of the line with one of
 *      them.  Return NULL if nothing matches, otherwise a pointer
 *      to the matching entry.
 *
 *      A successful match will leave the processed operands in the Eas
 *      array.  The first unused entry in Eas will have a type of EMPTY.
 *
 *      To be a successful match, the template must first match the
 *      size field.  After this, if the type is EMPTY the match
 *      is successful.  Also, if the type is MULTI, an open ended
 *      number of EXPR's will be scanned.
 */
struct tmpl *
tmpl_match(p,n)
struct tmpl *p;         /* first one to test */
int n;                  /* number of templates to check */
{
	register struct ea *e = Eas;
	int i;

	if( Size&p->sizes ){    /* quick test for MULTI/EMPTY templates */
		if(p->modes[0] == EMPTY )
			return(p);
		if(p->modes[0] == MULTI ){
			do_multi();
			return(p);
			}
		}

	/* otherwise there are 1 to 4 operands */
	Eas[0].type = Eas[1].type = Eas[2].type = Eas[3].type = EMPTY;
	scanea(e++);
	if( *Optr == ',' || *Optr=='{' ){
		if(*Optr==',')
			Optr++;
		scanea(e++);
		if( *Optr == ',' || *Optr=='{' ){
			if(*Optr==',')
				Optr++;
			scanea(e++);
			if( *Optr == ',' || *Optr=='{' ){
				if(*Optr==',')
					Optr++;
				scanea(e++);
				}
			}
		}
	/* 1-4 ea's now in Eas */
if(Debug&MATCH){
	printf("Match:");
	for(i=0;i<4;i++)
		printf(" %s",eanames[ Eas[i].type ]);
	printf("\n");
	}

	while(n--){
		if( (Size&p->sizes) &&
		    eamatch(p->modes[0],Eas[0].type) &&
		    eamatch(p->modes[1],Eas[1].type) &&
		    eamatch(p->modes[2],Eas[2].type) &&
		    eamatch(p->modes[3],Eas[3].type) )
			return(p);
		p++;
		}
	return(NULL);
}

#define sDN     (1<<DN)
#define sAN     (1<<AN)
#define sANI    (1<<ANI)
#define sPREDEC (1<<PREDEC)
#define sPSTINC (1<<PSTINC)
#define sINDEX  (1<<INDEX)
#define sEXPR   (1<<EXPR)
#define sIMMED  (1<<IMMED)
#define sPCINDEX (1<<PCINDEX)
#define sCN     (1<<CN)

/*
 *      eatab --- bit map of legal modes for composite EA types
 */
int eatab[] = {
    sDN|sAN,                                                   /* Rn */
    sDN|sAN|sANI|sPREDEC|sPSTINC|sINDEX|sEXPR|sIMMED|sPCINDEX, /* anyea */
	    sANI|                sINDEX|sEXPR|       sPCINDEX, /* control */
	    sANI|sPREDEC|sPSTINC|sINDEX|sEXPR,                 /* altmem */
    sDN|    sANI|sPREDEC|sPSTINC|sINDEX|sEXPR,                 /* datalt */
    sDN|sAN|sANI|sPREDEC|sPSTINC|sINDEX|sEXPR,                 /* alter */
    sDN|    sANI|sPREDEC|sPSTINC|sINDEX|sEXPR|sIMMED|sPCINDEX, /* data */
	    sANI|sPREDEC|        sINDEX|sEXPR,                 /* caltpr */
	    sANI|        sPSTINC|sINDEX|sEXPR|       sPCINDEX, /* ctlpst */
	    sANI|                sINDEX|sEXPR,                 /* ctlalt */
	    sANI|sPREDEC|sPSTINC|sINDEX|sEXPR|sIMMED|sPCINDEX, /* memory */
    sDN|sEXPR|sCN,                                             /* PEA1  */
    0                                                          /* multi */
    };

/*
 *      eamatch --- match a general ea class against the specific operand
 *
 *      gen is taken from the template, and spec comes from
 *      the type field of the scanned ea.  Gen classes less than
 *      RN are basic types, classes RN and above are composite
 *      types.  This routine will break if there are more basic
 *      types than bits in an int.
 */
eamatch(gen,spec)
int gen;        /* general addressing mode class */
int spec;       /* specific ea for an operand */
{
	if(gen<RN) return( gen==spec );
	return( eatab[gen-RN] & (1<<spec));
}

/*
 *      scanea --- convert next item in Operand to ea structure
 */
scanea(e)
register struct ea *e;
{
	register char *saveoptr = Optr+1; /* in case we need to backup */

	e->type = EMPTY;  e->itype = EMPTY;
	e->reg = e->const = e->reg2 = e->const2 = 0;
	e->stat = e->br_sup = e->stat2 = e->xn_sup = 0;
	e->force = e->siz = e->scl = 0;

	switch(*Optr++){
	case '#':       /* looks like immediate */
		if( eval(&e->const) != SYM )
			error("Expected expression");
		else
			e->type = IMMED;
		break;
	case '{':       /* FIELD,DYNK,STATK */
		switch( eval(&e->const) ){
		case DREG:
			e->type = DYNK;
			e->reg = e->const;
			break;
		case SYM:
			e->type = STATK;
			e->stat = 1;   /* in case it turns out to be FIELD */
			break;
		default:
			error("Bad specifier");
			break;
			}
		if(*Optr== ':' ){       /* it's a field specifier */
			Optr++;
			switch( eval(&e->const2) ){
			case DREG:
				e->reg2 = e->const2;
				break;
			case SYM:
				e->stat2 = 1;
				break;
			default:
				error("Bad specifer");
				break;
				}
			if( *Optr++ == '}' )
				e->type = FIELD;
			else{
				error("Missing } on bit field spec.");
				e->type = EMPTY;
				}
			}
		else if( *Optr == '}' )
			Optr++;
		else
			warn("Missing }?");
		break;
	case '\(':       /* could be almost anything */
		if( *Optr == '[' ){
			Optr++;
			oh_shit(e);
			break;
			}
		switch( eval(&e->const) ){
		case AREG:
			if( *Optr == '\)' ){
				e->reg = e->const;
				Optr++;
				e->type = ANI;
				if( *Optr== '+' ){
					Optr++;
					e->type = PSTINC;
					}
				else if( *Optr == ':'){  /* possibly RPAIR */
					e->type = RPAIR;
					Optr++;
					if( *Optr++ == '\(' ){
						e->stat = 1;
						e->stat2 = eval(&e->reg2);
						if( *Optr++ != '\)' ){
							error("Bad reg. pair");
							e->type = EMPTY;
							}
						else if( e->stat2 == AREG )
							e->stat2 = 1;
						else if( e->stat2 == DREG )
							e->stat2 = 0;
						else{
							error("Bad type in register pair");
							e->type = EMPTY;
							}
						}
					else{
						error("Expected Reg. pair");
						e->type = EMPTY;
						}
					}
				}
			else if( index(",.*",*Optr) ){ /* possibly indexed */
				Optr = saveoptr; /* backup to An again */
				e->const = 0;	/* zero base displacement */
				do_indexed(e);
				}
			else{
				error("Expected '\)'");
				e->type = EMPTY;
				}
			break;
		case DREG:      /* register pair or (Dn) indexing */
			if( *Optr == '\)' &&
			    *(Optr+1) == ':' &&
			    *(Optr+2) == '\(' ){
				Optr += 3;
				e->type = RPAIR;
				e->reg = e->const;
				e->stat2 = eval(&e->reg2);
				if( *Optr++ != '\)' ){
					error("Expected '\)'");
					e->type == EMPTY;
					}
				else if( e->stat2 == DREG )
					e->stat2 = 0;
				else if( e->stat2 == AREG )
					e->stat2 = 1;
				else{
					error("Bad register pair");
					e->type == EMPTY;
					}
				}
			else{
				Optr = saveoptr;
				e->const = 0;	/* zero base displacement */
				do_indexed(e);
				}
			break;
		case SYM:       /* could be EXPR,INDEX or PCINDEX */
			if( *Optr == '\)' ){
				Optr++;
				e->type = EXPR;
				e->force = Force;
				e->siz = optsize(e->const);/* .[WL] allowed */
				}
			else if( *Optr == ',' ){
				Optr++;
				do_indexed(e);
				}
			else
				error("Expression syntax");
			break;
		case ZAREG:
		case ZDREG:
		case PC:
		case ZPC:
			Optr = saveoptr;
			e->const = 0;	/* supressed base register */
			do_indexed(e);
			break;
		default:
			error("Expression syntax");
			break;
			}
		break;
	case '-':       /* could be -(An) */
		if(*Optr == '\(' ){
			Optr++;
			if( eval(&e->reg) == AREG && (*Optr++ == '\)') )
				e->type = PREDEC;
			else
				error("Expected Address register");
			break;
			}
		/* fall through, it might be a negative expr. */
	default:        /* something starting with an expression */
		Optr--;
		switch( eval(&e->const) ){
		case DREG:
			e->type = DN;
			e->reg = e->const;
			checkpair(e);
			checklist(e);
			break;
		case AREG:
			e->type = AN;
			e->reg = e->const;
			checkpair(e);
			checklist(e);
			break;
		case CREG:
			e->type = CN;
			e->reg = e->const;
			break;
		case PREG:
			e->type = PN;
			e->reg = e->const;
			break;
		case FREG:
			e->type = FN;
			e->reg = e->const;
			checkpair(e);
			checklist(e);
			break;
		case FCREG:
			e->type = FCN;
			e->reg = e->const;
			checklist(e);
			break;
		case SREG:
			e->type = e->const;
			break;
		case SYM:
			if( *Optr == '\(' ){
				Optr++;
				do_indexed(e);
				}
			else{
				e->type = EXPR;
				e->force = Force;
				e->siz = optsize(e->const);
				}
			break;
		case QSTR:
			e->type = STRING;
			break;
		default:
			error("Expression syntax");
			break;
			}
		break;
		}
}

/*
 *      do_multi --- scan multiple EXPR/STRING ea's
 */
do_multi()
{
	int eatotal = 0;
	register struct ea *e = Eas;

	do{
		Optr = skip_white(Optr);
		scanea(e);
		if( e->type == EXPR || e->type == STRING ){
			eatotal++;
			e++;
			}
		else{
			error("Expected expression");
			break;
			}
	}while(eatotal<MAXEA && *Optr++==',');
	e->type = EMPTY;        /* end+1 of valid ea's is marked EMPTY */
}

/*
 *      optsize --- allow optional .W or .L
 *
 *      A .W or .L following an expression will determine the size of
 *      the most recent expression evaluation.  If there is no following
 *      size specification, the assembler will choose the size based
 *      on the Force (forward ref) flag, and/or the value of the expression.
 */
optsize(v)
int v;  /* value */
{
	int s;

	if( *Optr == '.' ){
		switch( *(Optr+1) ){
		case 'w':
		case 'W':  s = W; Optr += 2; break;
		case 'l':
		case 'L':  s = L; Optr += 2; break;
		default:
			if(Force || v<MINWORD || v>MAXWORD)
				s = L;
			else
				s = Fwdsize;
			}
		}
	else if(Force || v<MINWORD || v>MAXWORD )
		s = L;
	else
		s = Fwdsize;
	return(s);
}

/*
 *      optscale --- allow optional *1, *2, *4 or *8
 */
optscale()
{
	int s = 0;

	if( *Optr == '*' )
	switch( *(Optr+1) ){
	case '1':  s = 0; Optr += 2; break;
	case '2':  s = 1; Optr += 2; break;
	case '4':  s = 2; Optr += 2; break;
	case '8':  s = 3; Optr += 2; break;
		}
	return(s);
}

/*
 *      do_indexed --- handle simple indexed addressing cases
 *
 *      The first part of an indexed addressing mode has been
 *      seen.  Either 'SYM(' or '(SYM,' has been evaluated,
 *      with the value of SYM placed in e->const.  The remaining
 *      part should be either 'AN)' or 'AN,RN[.siz][*scale])'.
 *      AN could also be PC at this point.
 *
 *	For 'AN)' or 'PC)', the selected mode will be D16AN if the
 *	SYM part is not a forward ref, and will fit in a 16-bit
 *	field.  Otherwise, the FULL format is used with xn_sup set.
 *
 *	If DREG,ZAREG,ZDREG or ZPC is seen, it is assumed that
 *	the base register is to be supressed.  Also, if AN is
 *	followed by a '.' or '*', we assume that it is the index
 *	register, not the base.
 */
do_indexed(e)
struct ea *e;
{
	char *saveoptr = Optr;	/* in case it's not what I expect */
	extern int Pc;

	e->type = INDEX;	/* the common case */
	switch( eval(&e->reg) ){
	case AREG:
		if(*Optr == '\)' ){
			Optr++;
			if( e->force || 
			    e->const < MINWORD ||
			    e->const > MAXWORD){
				e->itype = FULL;
				e->bdsiz = 3;	/* 32 bits */
				e->xn_sup = 1;
				e->odsiz = 0;	/* empty */
				}
			else
				e->itype = D16AN;
			return;
			}
		if( *Optr == ',')
			Optr++;		/* must be the base reg */
		else{
			Optr = saveoptr;
			e->br_sup = 1;	/* assume we just saw Xn */
			}
		break;
	case ZPC:
		e->br_sup = 1;	/* supress PC */
	case PC:
		e->type = PCINDEX;
		if(*Optr == '\)' ){
			Optr++;
			if( e->br_sup )
				error("illegal use of ZPC");
			if( e->force || 
			    (e->const-Pc) < MINWORD ||
			    (e->const-Pc) > MAXWORD){
				e->itype = FULL;
				e->bdsiz = 3;	/* 32 bits */
				e->xn_sup = 1;
				e->odsiz = 0;	/* empty */
				}
			else
				e->itype = D16AN;
			return;
			}
		if( *Optr++ != ',')
			error("Expected ,");
		break;
	case DREG:
	case ZAREG:
	case ZDREG:
		Optr = saveoptr;	/* backup to let do_xn handle it */
		e->br_sup = 1;		/* supress base register */
		break;
	default:
		e->type = EMPTY;
		error("Bad indexed addressing syntax");
		return;
		}
	do_xn(e);
	/* Try to pick the format based on the base displacement */
	/* If it's a forward ref, won't fit within a byte, */
	/* or has either the base or index register supressed */
	/* switch to the FULL format */
	if( e->force || e->xn_sup || e->br_sup 
		|| e->const <MINBYTE || e->const >MAXBYTE){
		if( e->force || e->const <MINWORD || e->const>MAXWORD)
			e->bdsiz = 3;	/* force 32-bit displacement */
		else if( e->const != 0)
			e->bdsiz = 2;	/* try 16-bit displacement */
		else
			e->bdsiz = 1;	/* no displacement at all */
		e->odsiz = 0;	/* and supressed outer displacement */
		e->itype = FULL;
		}
	else
		e->itype = BRIEF;
	if( *Optr++ != '\)')
		error("Expected )");
}

/*
 *      do_xn --- collect Xn.siz*scl (sets reg2,stat2,siz,scl,xn_sup)
 */
do_xn(e)
struct ea *e;
{
	switch( eval(&e->reg2) ){
	case DREG:
		break;
	case ZDREG:
		e->xn_sup = 1;
		break;
	case AREG:
		e->stat2 = 1;
		break;
	case ZAREG:
		e->stat2 = 1;
		e->xn_sup = 1;
		break;
	default:
		error("Index register");
		e->type = EMPTY;
		break;
		}
	e->siz = optsize(0);
	e->scl = optscale();
}

/*
 *      checkpair --- see if register name is followed by :reg
 *
 *      If the next char is : and the next item is the same type
 *      as the one already scanned, change the type of this ea
 *      to PAIR.  Only Dn, and FPn pairs are currently allowed.
 */
checkpair(e)
struct ea *e;
{
	if( *Optr == ':' ){
		Optr++;
		switch( eval(&e->reg2) ){
		case DREG:
			if( e->type == DN )
				e->type = DPAIR;
			else
				error("Dn pair expected");
			break;
		case FREG:
			if( e->type == FN )
				e->type = FPAIR;
			else
				error("FPn pair expected");
			break;
		default:
			error("Register pair?");
			break;
			}
		}
}

/*
 *      checklist --- see if register name is beginning of a reg. list
 *
 *      If the next char is - or /, then this is a register list type
 *      of field.  If the next char is - then the next item must
 *      be of the same type, and have a register value greater than
 *      the first reg.  If the next char is / then the next item
 *      may be any legal register name for the class.  Currently,
 *      register lists may be constructed from (AN,DN), FPN and FCLIST
 *      type items.
 *
 *      A successful match will leave the e->reg value with a
 *      bit map of the registers specified.
 */
checklist(e)
struct ea *e;
{
	int mask = 0;
	int i;

	if( *Optr!= '-' && *Optr != '/' )
		return;

	while( *Optr=='-' || *Optr=='/' ){
		mask |= regbit(e->type,e->reg); /* add current reg to mask */
		if( *Optr++ == '/' ){
			switch( eval(&e->reg) ){
			case DREG:
				if( e->type == DN )
					;
				else if(e->type == AN )
					e->type = DN;
				else
					error("Register list");
				break;
			case AREG:
				if( e->type == AN )
					;
				else if(e->type == DN )
					e->type = AN;
				else
					error("Register list");
				break;
			case FREG:
				if( e->type != FN )
					error("Register list");
				break;
			case FCREG:
				if( e->type != FCN )
					error("Register list");
				break;
			default:
				error("Register list");
				break;
				}
			}

		else{   /* range of regs */
			switch( eval(&e->reg2) ){
			case AREG:
				if( e->type != AN )
					error("Register list");
				break;
			case DREG:
				if( e->type != DN )
					error("Register list");
				break;
			case FREG:
				if( e->type != FN )
					error("Register list");
				break;
			case FCREG:
				if( e->type != FCN )
					error("Register list");
				break;
			default:
				error("Register list");
				break;
				}
			if( e->reg2 > e->reg )
				for(i= e->reg; i <= e->reg2; i++)
					mask |= regbit(e->type,i);
			else
				for(i= e->reg2; i <= e->reg; i++)
					mask |= regbit(e->type,i);
			}
		}

	mask |= regbit(e->type,e->reg); /* pickup last reg */
	switch(e->type){
	case DN:
	case AN:
		e->type = RLIST;
		break;
	case FN:
		e->type = FLIST;
		break;
	case FCN:
		e->type = FCLIST;
		break;
	case EMPTY: /* there was a problem somewhere */
		break;
	default:
		fatal("Botch in checklist");
		}
	e->reg = mask;
}

/*
 *      regbit --- convert register number to bit position
 */
regbit(type,reg)
int type;
int reg;
{
	switch(type){
	case AN:
		reg += 8;
	case DN:
	case FN:
		return( 1 << reg);
	case FCN:
		return(reg);
	default:
		fatal("Botch in regbit");
		}
}

/*
 *      oh_shit --- handle indexed indirect addressing
 *
 *      The first part of an indexed indirect addressing mode has
 *      been seen: '(['.  Parse the rest and put it in an ea structure.
 */
oh_shit(e)
struct ea *e;
{
	struct {
		int     i_type;
		int     i_val;
		int     i_force;        /* set if i_val is fwd ref */
		int     i_siz;
		int     i_scale;
	} idx[4];

	register int i = -1;
	register int iflag = -1; /* ] appears after iflag'th item */
	int j;
	int     base,xreg;
	extern char *tnames[];

	while( *Optr && (*Optr != '\)') ){
		Optr = skip_white(Optr);
		if( *Optr == ']' ){
			iflag = i;    /* remember were ] was placed */
			Optr++;
			}
		else if( *Optr == ',')
			Optr++;
		else{
			i++;
			if( i > 3 )
				break;  /* too many items */
			idx[i].i_type = eval(&idx[i].i_val);
			idx[i].i_force = Force;
			idx[i].i_siz = optsize(idx[i].i_val);
			idx[i].i_scale = optscale();
			}
		}

#ifdef M68020
if(Debug&XDEBUG){
	printf("Indir:");
	for(j=0;j<=i;j++)
		printf(" (%s %x %x %x)",tnames[idx[j].i_type],idx[j].i_val,
					idx[j].i_siz,idx[j].i_scale);
	printf(" iflag:%d\n",iflag);
	}

	/* some sanity checks */
	if( (*Optr++ != '\)') || iflag<0 || iflag>2 || i<0 || i>3){
		error("Indexed indirect syntax");
		e->type = EMPTY;
		return;
		}

	/* start with everything supressed */
	e->type  = INDEX;
	e->itype = FULL;
	e->reg   = 0;
	e->reg2  = 0;
	e->stat2 = 0;   /* default is DREG */
	e->const = 0;
	e->const2= 0;
	e->odsiz = 1;
	e->bdsiz = 1;
	e->siz   = 0;   /* word indexing */
	e->scl   = 0;   /* *1 scaling */
	e->br_sup   = 1;
	e->xn_sup  = 1;
	e->prepst= 0;   /* pre indexing */
	e->force = 0;
	e->force2= 0;

	if( idx[0].i_type == SYM ){  /* base displacement */
		e->bdsiz = (idx[0].i_siz==L ? 3 : 2);
		e->const = idx[0].i_val;
		e->force = idx[0].i_force;
		base = 1;
		}
	else
		base = 0;

	if( i>0 && idx[i].i_type == SYM){ /* outer displacement */
		e->odsiz = (idx[i].i_siz==L ? 3 : 2);
		e->const2 = idx[i].i_val;
		e->force2 = idx[i].i_force;
		xreg = i-1;
		}
	else
		xreg = i;

	/* Possible base and outer displacements have been stripped off */
	/* base and xreg point to what's left */

	if( xreg < base){       /* nothing left, must be mem indir */
		if( iflag != 0 )
		     error("Memory Indirect syntax");
		return;
		}

	if( xreg != base ){     /* [An,Xn] or [An],Xn */
		switch( idx[base].i_type ){
		case AREG:
		     e->br_sup = 0;
		case ZAREG:
		     e->reg = idx[base].i_val;
		     break;
		case PC:
		     e->br_sup = 0;
		case ZPC:
		     e->type = PCINDEX;
		     break;
		default:
		     error("Base register expected");
		     e->type = EMPTY;
		     break;
		     }
		}
	if( base==xreg && (idx[xreg].i_type==PC || idx[xreg].i_type==ZPC)){
		/* ([PC]) or ([ZPC]) */
		e->type = PCINDEX;
		if( idx[xreg].i_type == PC )
			e->br_sup = 0;
		return;
		}

	/* remaining item is Xreg */
	switch( idx[xreg].i_type ){
	case AREG:
		e->xn_sup = 0;
	case ZAREG:
		e->stat2 = 1;   /* remember that Xn is an AREG */
		break;
	case DREG:
		e->xn_sup = 0;
	case ZDREG:
		break;
	default:
		error("Index Register Expected");
		e->type = EMPTY;
		break;
		}
	e->siz = idx[xreg].i_siz;
	e->scl = idx[xreg].i_scale;
	e->reg2 = idx[xreg].i_val;
	if( xreg > iflag )
		e->prepst = 1;  /* post indexing */
#endif
#ifdef M68HC16
	error("Indirect addressing not supported");
	e->type = EMPTY;
#endif
}

/*
 *      dump_comp --- display composite EA classes
 */
dump_comp()
{
	int i;
	int j;
	unsigned mask;

	printf("Composite EA classes:\n");
	for(i=RN; i<MULTI; i++ ){
		printf("%s:\t",eanames[i]);
		mask = eatab[i-RN];
		j = 0;
		while(mask){
			if( mask&1)
				printf("%s ",eanames[j]);
			j++;
			mask >>= 1;
			}
		printf("\n");
		}
	printf("\n");
}

/*
 *      dump_mne --- display mnemonic/template tables
 */
dump_mne()
{
	struct mne *m;
	struct tmpl *t;
	int     i,j;
	extern struct mne mnemonic[];
	extern struct tmpl template[];
	extern int Nmne;

	printf("Legal mnemonic/size/ea combinations:\n");
	for( m =mnemonic; m < &mnemonic[Nmne]; m++ ){
		printf("%s",m->mne_name);
		t = m->ptmpl;
		i = m->ntmpl;
		while(i--){
			printf("\t");
			psize(t->sizes);
			for(j=0;j<4;j++){
				if( t->modes[j] == EMPTY )
					break;
				printf("\t%s",eanames[t->modes[j]]);
				}
			printf("\n");
			t++;
			}
		}
	printf("\n");
}

psize(s)
int s;
{
	if( s&B )printf("b");
	if( s&W )printf("w");
	if( s&L )printf("l");
	if( s&S )printf("s");
	if( s&D )printf("d");
	if( s&X )printf("x");
	if( s&P )printf("p");
	if( s&U )printf("u");
}
