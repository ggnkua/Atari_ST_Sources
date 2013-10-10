#include <stdio.h>
#include <ctype.h>
#include "as.h"
#include "lookup.h"

int	Force = 0;	/* Result should be a long when set	*/
int	Exprnum = 1;	/* which expression is being evaluated  */
int	Fexpr = 0;	/* next expression with a fwd ref	*/

#define MAXFWD  1000
 int *Fbase = NULL;
 int *Fnext = NULL;
 int Fleft = 0;

extern int Old_pc;
extern char *Optr;
extern int Pass;

char *tnames[] = {
	"SYM", "SREG", "Dn", "An", "Cn", "FPn", "FPCn", "PC",
	"ZPC", "ZAn", "ZDn", "Pn", "String"
	};

/*
 *	exprinit --- initialize forward ref array
 */
exprinit()
{
	Fbase = ( int *)malloc( sizeof( int) * MAXFWD );
	if( Fbase == ( int *)ERR )
		fatal("No mem for fwd refs");
	Fnext = Fbase;
	Fleft = MAXFWD-1;
}

/*
 *	expreinit --- re-initialize forward ref mechanism
 */
expreinit()
{
	*Fnext = 0;	/* mark last element in fwd refs */
	Exprnum = 1;
	Fnext = Fbase;  /* reset fwd ref ptr */
	Fexpr = *Fnext++;
}

/*
 *	eval --- evaluate expression
 *
 *	an expression is constructed like this:
 *
 *	expr ::=  expr + term |
 *		  expr - term ;
 *		  expr * term ;
 *		  expr / term ;
 *		  expr | term ;
 *		  expr & term ;
 *		  expr % term ;
 *		  expr ^ term ;
 *
 *	term ::=  symbol |
 *		  * |
 *		  constant ;
 *
 *	symbol ::=  string of alphanumerics with non-initial digit
 *
 *	constant ::= hex constant |
 *			binary constant |
 *			octal constant |
 *			decimal constant |
 *			ascii constant;
 *
 *	hex constant ::= '$' {hex digits};
 *
 *	octal constant ::= '@' {octal digits};
 *
 *	binary constant ::= '%' { 1 | 0 };
 *
 *	decimal constant ::= {decimal digits};
 *
 *	ascii constant ::= ''' any printing char;
 *
 */
eval(result)
int *result;	/* where to place result */
{
	int	left,right;	/* left and right terms for expression */
	int	ltype,rtype;
	char	o;		/* operator character */
	extern int Debug;

if(Debug&EVAL)printf("Eval at %s",Optr);
	Force = 0;

	ltype = get_term(&left);	  /* pickup first part of expression */
	if( ltype == SYM ){
		while( any(*Optr,"+-*/&%|^") ){
			o = *Optr++; /* pickup connector and skip */
			if( (rtype = get_term(&right)) != SYM ){ /* pickup current rightmost side */
				error("Expression");
				break;
				}
			switch(o){
				case '+': left += right; break;
				case '-': left -= right; break;
				case '*': left *= right; break;
				case '/': left /= right; break;
				case '|': left |= right; break;
				case '&': left &= right; break;
				case '%': left %= right; break;
				case '^': left = left^right; break;
				}
			}
		}
if(Debug&EVAL)printf("Eval Result=%x(%s) %s\n",left,tnames[ltype],Force? "Fwdref":"");
if(Debug&EVAL)printf("Eval done at %s\n",Optr);
	Exprnum++;
	*result = left;
	return(ltype);
}

/*
 *	get_term --- evaluate a single item in an expression
 */
get_term(result)
int *result;	/* place result here */
{
	char	hold[MAXBUF];
	char	*tmp;
	int	val = 0;	/* local value being built */
	int	minus = 0;	/* unary minus flag */
	int	ttype = SYM;	/* type of term scanned */
	struct nlist *np;	/* if term is looked up */

	if( *Optr == '-' ){
		Optr++;
		minus = 1;
		}

	/* look at rest of expression */

	if(*Optr=='%'){ /* binary constant */
		Optr++;
		while( any(*Optr,"01"))
			val = (val * 2) + ( (*Optr++)-'0');
		}
	else if(*Optr=='@'){ /* octal constant */
		Optr++;
		while( any(*Optr,"01234567"))
			val = (val * 8) + ((*Optr++)-'0');
		}
	else if(*Optr=='$'){ /* hex constant */
		Optr++;
		while( any(*Optr,"0123456789abcdefABCDEF"))
			if( isdigit(*Optr) )
				val = (val * 16) + ((*Optr++)-'0');
			else
				val = (val * 16) + 10 + (mapdn(*Optr++)-'a');
		}
/*
	else if(*Optr==':'){
		Optr++;
		tmp = malloc(12);
		val = (int)tmp;
		for(i=0;i<12;i++){

		while( any(*Optr,"0123456789abcdefABCDEF_"))
			if( *Optr == '_' )
				Optr++;
			else if( isdigit(*Optr) )
				val = (val * 16) + ((*Optr++)-'0');
			else
				val = (val * 16) + 10 + (mapdn(*Optr++)-'a');
		ttype = FSYM;
		}
*/
	else if(isdigit(*Optr)){ /* decimal constant */
		while( isdigit(*Optr))
			val = (val * 10) + ( (*Optr++)-'0');
		}
	else if(*Optr=='*'){	/* current location counter */
		Optr++;
		val = Old_pc;
		}
	else if(*Optr=='\''){	/* character literal */
		Optr++;
		tmp = hold;
		while( *Optr && (*Optr != '\''))
			*tmp++ = *Optr++;
		*tmp = '\0';
		if(*Optr == '\'')
			Optr++;
		else
			error("Bad string");
		val = (int)strcpy(malloc(strlen(hold)+1),hold);
		minus = 0;
		ttype = QSTR;
		}
	else if( alpha(*Optr) ){ /* a symbol */
		tmp = hold;	/* collect symbol name */
		while(alphan(*Optr))
			*tmp++ = *Optr++;
		*tmp = '\0';
		if( (np=lookup(hold)) != NULL){
			val =	np->sym_def;
			ttype = np->sym_type;
			}
		else{
			if(Pass==1){	/* forward ref here */
				if(Fleft){
					*Fnext++ = Exprnum;
					Fleft--;
					}
				else
					error("No space for fwd refs");
				Force=1;
				}
			}
		if(Pass==2 && Exprnum==Fexpr){
			Force=1;
			Fexpr = *Fnext++;
			}
		}
	else
		/* none of the above */
		val = 0;

	if(minus)
		*result = -val;
	else
		*result = val;

	return(ttype);
}
