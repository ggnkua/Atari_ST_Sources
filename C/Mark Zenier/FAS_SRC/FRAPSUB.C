/*
HEADER: 	;
TITLE: 		Frankenstein Cross Assemblers;
VERSION: 	2.0;
DESCRIPTION: "	Reconfigurable Cross-assembler producing Intel (TM)
		Hex format object records.  ";
SYSTEM: 	UNIX, MS-Dos ;
FILENAME: 	frapsub.c ;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.  "  ;
SEE-ALSO: 	frasmain.c;
AUTHORS: 	Mark Zenier;
*/

/*
	description	Parser phase utility routines
	History		September 1987
			September 14, 1990 Dosify, 6 char unique names
*/

#include "fragcon.h"
#include <stdio.h>
#include "frasmdat.h"

#define STRALLOCSZ 4096

	local char *currstr;

char * savestring(stx, len)
	char *stx;
	int len;
/*
	description	save a character string in permanent (interpass) memory
	parameters	the string and its length
	globals 	the string pool
	return		a pointer to the saved string
*/
{
	char * rv;
	static int savestrleft = 0;

	if( savestrleft < (len+1))
	{
		if((currstr = malloc(STRALLOCSZ)) == (char *)NULL)
		{
			frafatal("cannot allocate string storage");
		}
		savestrleft = STRALLOCSZ;
	}

	savestrleft -= (len+1);

	rv = currstr;
	for(; len > 0; len--)
		*currstr++ = *stx++;
	*currstr++ = '\0';

	return rv;
}

/* expression node operations */

/* expression tree element */
struct etelem
{
	int	evs;
	int	op;
	int	left, right;
	long	val;
	struct symel *sym;
};

#define NUMENODE INBUFFSZ
struct etelem enode[NUMENODE];

local int nextenode = 1;

/* non general, one exprlist or stringlist per line */
int nextexprs = 0;
int nextstrs = 0;

clrexpr()
/*
	description	clear out the stuff used for each line
			the temporary string pool
			the expression tree storage pool
			the string and expression lists
*/
{
	nextenode = 1;
	nextexprs = nextstrs = 0;
}

exprnode(swact, left, op, right, value, symbol)
	int swact, left, op, right;
	long value;
	struct symel * symbol;
/*
	description	add an element to the expression tree pool
	parameters	swact, the action performed by the switch in
				the polish conversion routine, the category
				of the expression node.
			left, right  the subscripts of the decendent nodes
					of the expression tree element
			op, the operation to preform
			value, a constant value (maybe)
			symbol, a pointer to a symbol element (maybe)
	globals		the next available table element
	return		the subscript of the expression node
*/
{
	if(nextenode >= NUMENODE)
	{
		frafatal("excessive number of subexpressions");
	}

	enode [nextenode].evs = swact;
	enode [nextenode].left = left;
	enode [nextenode].op = op;
	enode [nextenode].right = right;
	enode [nextenode].val = value;
	enode [nextenode].sym = symbol;

	return nextenode ++;
}

int nextsymnum = 1;

local struct symel *syallob;
#define SYELPB 512
local int nxtsyel = SYELPB;

struct symel *allocsym()
/*
	description	allocate a symbol table element, and allocate
			a block if the current one is empty.  A fatal
			error if no more space can be gotten
	globals		the pointer to the current symbol table block
			the count of elements used in the block
	return		a pointer to the symbol table element
*/
{

	if(nxtsyel >= SYELPB)
	{
		if( (syallob = (struct symel *)calloc(
			SYELPB , sizeof(struct symel)))
		 == (struct symel *)NULL)
		{
			frafatal("cannot allocate symbol space");
		}

		nxtsyel = 0;
	}

	return &syallob[nxtsyel++];
}


#define SYHASHOFF 13
#define SYHASHSZ 1023

int syhash(str)
	register char *str;
/*
	description	produce a hash index from a character string for
			the symbol table.
	parameters 	a character string
	return		an integer related in some way to the character string
*/
{
	unsigned rv = 0;
	register int offset = 1;
	register int c;

	while((c = *(str++)) > 0)
	{
		rv += (c - ' ') * offset;
		offset *= SYHASHOFF;
	}

	return rv % SYHASHSZ;
}

local struct symel * (shashtab[SYHASHSZ]);

static struct symel *getsymslot(str)
	char * str;
/*
	description	find an existing symbol in the symbol table, or
			allocate an new element if the symbol doen't exist.
			action: hash the string
				if there are no symbols for the hash value
					create one for this string
				otherwise
				scan the linked list until the symbol is 
				found or the end of the list is found
				if the symbol was found
					exit
				if the symbol was not found, allocate and
				add at the end of the linked list
				fill out the symbol
	parameters	the character string 
	globals		all the symbol table
	return		a pointer to the symbol table element for this
			character string
*/
{
	struct symel *currel, *prevel;
	int hv;

	if( (currel = shashtab[hv = syhash(str)])
	    == (struct symel *)NULL)
	{
		shashtab[hv] = currel = allocsym();
	}
	else
	{
		do  {
			if(strcmp(currel -> symstr, str) == 0)
			{
				return currel;
			}
			else
			{
				prevel = currel;
				currel = currel -> nextsym;
			}
		} while( currel != (struct symel *)NULL);

		prevel -> nextsym = currel = allocsym();
	}

	currel -> symstr = savestring(str, strlen(str));
	currel -> nextsym = (struct symel *)NULL;
	currel -> tok = 0;
	currel -> value = 0;
	currel -> seg = SSG_UNUSED;

	return currel;
}

struct symel * symbentry(str,toktyp)
	char * str;
	int toktyp;
/*
	description	find or add a nonreserved symbol to the symbol table
	parameters	the character string
			the syntactic token type for this charcter string
				(this is a parameter so the routine doesn't
				have to be recompiled since the yacc grammer
				provides the value)
	globals		the symbol table in all its messy glory
	return		a pointer to the symbol table element
*/
{
	struct symel * rv;

	rv = getsymslot(str);

	if(rv -> seg == SSG_UNUSED)
	{
		rv -> tok = toktyp;
		rv -> symnum = nextsymnum ++;
		rv -> seg = SSG_UNDEF;
	}

	return rv;
}

void reservedsym(str, tok, value)
	char * str;
	int tok;
	int value;
/*
	description	add a reserved symbol to the symbol table.
	parameters	the character string, must be a constant as
			the symbol table does not copy it, only point to it.
			The syntactic token value.
			The associated value of the symbol.
*/
{
	struct symel * tv;

	tv = getsymslot(str);

	if(tv -> seg != SSG_UNUSED)
	{
		frafatal("cannot redefine reserved symbol");
	}

	tv -> symnum = 0;
	tv -> tok = tok;
	tv -> seg = SSG_RESV;
	tv -> value = value;

}

buildsymbolindex()
/*
	description	allocate and fill an array that points to each
			nonreserved symbol table element, used to reference
			the symbols in the intermediate file, in the output
			pass.
	globals		the symbol table
*/
{
	int hi;
	struct symel *curr;

	if((symbindex = (struct symel **)calloc((unsigned)nextsymnum, 
			sizeof (struct symel *))) == (struct symel **)NULL)
	{
		frafatal(" unable to allocate symbol index");
	}

	for(hi = 0; hi < SYHASHSZ; hi++)
	{
		if( (curr = shashtab[hi]) != SYMNULL)
		{
			do  {
				if( curr -> symnum)
					symbindex[curr -> symnum] = curr;

				curr = curr -> nextsym;
			}  while(curr != SYMNULL);
		}
	}
}

/* opcode symbol table */

#define OPHASHOFF 13
#define OPHASHSZ 1023

local int ohashtab[OPHASHSZ];

setophash()
/*
	description	set up the linked list hash table for the
			opcode symbols 
	globals		the opcode hash table
			the opcode table
*/
{
	int opn, pl, hv;

		/* optab[0] is reserved for the "invalid" entry */
		/*  opcode subscripts range from 0 to numopcode - 1 */
	for(opn = 1; opn < gnumopcode; opn++)
	{
		hv = opcodehash(optab[opn].opstr);

		if( (pl = ohashtab[hv]) == 0)
		{
			ohashtab[hv] = opn;
		}
		else
		{
			while( ophashlnk[pl] != 0)
			{
				pl = ophashlnk[pl];
			}

			ophashlnk[pl] = opn;
			ophashlnk[opn] = 0;
		}
	}
}


int findop(str)
	char *str;
/*
	description	find an opcode table subscript
	parameters	the character string
	globals		the opcode hash linked list table
			the opcode table
	return		0 if not found
			the subscript of the matching element if found
*/
{
	int ts;

	if( (ts = ohashtab[opcodehash(str)]) == 0)
	{
		return 0;
	}

	do  {
		if(strcmp(str,optab[ts].opstr) == 0)
		{
			return ts;
		}
		else
		{
			ts = ophashlnk[ts];
		}
	} while (ts != 0);

	return 0;
}


int opcodehash(str)
	char *str;
/*
	description	hash a character string
	return		an integer related somehow to the character string
*/
{
	unsigned rv = 0;
	int offset = 1, c;

	while((c = *(str++)) > 0)
	{
		rv += (c - ' ') * offset;
		offset *= OPHASHOFF;
	}

	return rv % OPHASHSZ;
}


char * findgen(op, syntax, crit)
	int	op, syntax, crit;
/*
	description	given the subscript of the opcode table element,
			find the instruction generation string for the
			opcode with the given syntax and fitting the
			given criteria.  This implement a sparse matrix
			for  the dimensions [opcode, syntax] and then
			points to a list of generation elements that
			are matched to the criteria (binary set) that
			are provided by the action in the grammer for that
			specific syntax.
	parameters	Opcode table subscript
				note 0 is the value which points to an
				syntax list that will accept anything
				and gives the invalid instruction error
			Syntax, a selector, a set member
			Criteria, a integer used a a group of bit sets
	globals		the opcode table, the opcode syntax table, the
			instruction generation table
	return		a pointer to a character string, either a
			error message, or the generation string for the
			instruction
*/
{
	int	sys = optab[op].subsyn, stc, gsub = 0, dctr;

	for(stc = optab[op].numsyn; stc > 0; stc--)
	{
		if( (ostab[sys].syntaxgrp & syntax) != 0)
		{
			gsub = ostab[sys].gentabsub;
			break;
		}
		else
			sys++;
	}

	if(gsub == 0)
		return ignosyn;

	for(dctr = ostab[sys].elcnt; dctr > 0; dctr--)
	{
		if( (igtab[gsub].selmask & crit) == igtab[gsub].criteria)
		{
			return igtab[gsub].genstr;
		}
		else
		{
			gsub++;
		}
	}

	return ignosel;
}


genlocrec(seg, loc)
	int seg;
	long loc;
/*
	description	output to the intermediate file, a 'P' record
			giving the current location counter.  Segment
			is not used at this time.
*/
{
	fprintf(intermedf, "P:%x:%lx\n", seg, loc);
}

#define GSTR_PASS 0
#define GSTR_PROCESS 1

local char *goutptr, goutbuff[INBUFFSZ] = "D:";

void goutch(ch)
	char ch;
/*
	description	put a character in the intermediate file buffer
			for 'D' data records
	globals		the buffer, its current position pointer
*/
{
	if(goutptr < &goutbuff[INBUFFSZ-1])
	{
		*goutptr ++ = ch;
	}
	else
	{
		goutbuff[INBUFFSZ-1] = '\0';
		goutptr = &goutbuff[INBUFFSZ]; 
		fraerror("overflow in instruction generation");
	}
}


gout2hex(inv)
	int inv;
/*
	description	output to the 'D' buffer, a byte in ascii hexidecimal
*/
{
	goutch(hexch( inv>>4 ));
	goutch(hexch( inv ));
}


goutxnum(num)
	unsigned long num;
/*
	description	output to the 'D' record buffer a long integer in
			hexidecimal
*/
{
	if(num > 15)
		goutxnum(num>>4);
	goutch(hexch((int) num ));
}


int geninstr(str)
	register char * str;
/*
	description	Process an instruction generation string, from
			the parser, into a polish form expression line
			in a 'D' record in the intermediate file, after
			merging in the expression results.
	parameters	the instruction generation string
	globals		the evaluation results 
				evalr[].value	a numeric value known at
						the time of the first pass
				evalr[].exprstr  a polish form expression
						derived from the expression
						parse tree, to be evaluated in
						the output phase.
	return		the length of the instruction (machine code bytes)
*/
{
	int len = 0;
	int state = GSTR_PASS;
	int innum = 0;

	register char *exp;

	goutptr = &goutbuff[2];

	while( *str != '\0')
	{
		if(state == GSTR_PASS)
		{
			switch(*str)
			{
			case IG_START:
				state = GSTR_PROCESS;
				innum = 0;
				str++;
				break;

			case IFC_EMU8:
			case IFC_EMS7:
				len++;
				goutch(*str++);
				break;

			case IFC_EM16:
			case IFC_EMBR16:
				len += 2;
				goutch(*str++);
				break;

			default:
				goutch(*str++);
				break;
			}
		}
		else
		{
			switch(*str)
			{
			case IG_END:
				state = GSTR_PASS;
				str++;
				break;
			
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				innum = (innum << 4) + (*str++) - '0';
				break;
			
			case 'a':
			case 'b':
			case 'c':
			case 'd':
			case 'e':
			case 'f':
				innum = (innum << 4) + (*str++) - 'a' + 10;
				break;
			
			case 'A':
			case 'B':
			case 'C':
			case 'D':
			case 'E':
			case 'F':
				innum = (innum << 4) + (*str++) - 'A' + 10;
				break;
			
			case IG_CPCON:
				goutxnum((unsigned long)evalr[innum].value);
				innum = 0;
				str++;
				break;

			case IG_CPEXPR:
				exp = &evalr[innum].exprstr[0];
				innum = 0;
				while(*exp != '\0')
					goutch(*exp++);
				str++;
				break;
			
			case IG_ERROR:
				fraerror(++str);
				return 0;
			
			default:
				fraerror(
				"invalid char in instruction generation");
				break;
			}
		}
	}

	if(goutptr > &goutbuff[2])
	{
		goutch('\n');
		fwrite(goutbuff,sizeof (char), goutptr - &goutbuff[0], 
			intermedf);
	}

	return len;
}

int 	chtnxalph = 1, *chtcpoint = (int *)NULL, *chtnpoint = (int *)NULL;

int chtcreate()
/*
	description	allocate and initialize a character translate
			table
	return		0 for error, subscript into chtatab to pointer
			to the allocated block
*/
{
	int *trantab, cnt;

	if(chtnxalph >= NUM_CHTA)
		return 0; /* too many */

	if( (trantab =  (int *)calloc(512, sizeof (int))) == (int *) NULL)
		return 0;

	for(cnt = 0; cnt < 512; cnt++)
		trantab[cnt] = -1;
	
	chtatab[chtnxalph] = chtnpoint = trantab;

	return chtnxalph++;
}


int chtcfind(chtab, sourcepnt, tabpnt, numret)
/*
	description	find a character in a translate table
	parameters	pointer to translate table
			pointer to pointer to input string
			pointer to return value integer pointer
			pointer to numeric return
	return		status of search
*/
	int *chtab;
	char **sourcepnt; 
	int **tabpnt;
	int *numret;
{
	int numval, *valaddr;
	char *sptr, cv;

	sptr = *sourcepnt;

	switch( cv = *sptr)
	{
	case '\0':
		return CF_END;

	default:
		if( chtab == (int *)NULL)
		{
			*numret = *sptr;
			*sourcepnt = ++sptr;
			return CF_NUMBER;
		}
		else
		{
			valaddr = &(chtab[cv & 0xff]);
			*sourcepnt = ++sptr;
			*tabpnt = valaddr;
			return (*valaddr == -1) ?
				CF_UNDEF : CF_CHAR;
		}
		
	case '\\':
		switch(cv =  *(++sptr) )
		{
		case '\0':
			*sourcepnt = sptr;
			return CF_INVALID;
		
		case '\'':
		case '\"':
		case '\\':
			if( chtab == (int *)NULL)
			{
				*numret = *sptr;
				*sourcepnt = ++sptr;
				return CF_NUMBER;
			}
			else
			{
				valaddr = &(chtab[(cv & 0xff) + 256]);
				*sourcepnt = ++sptr;
				*tabpnt = valaddr;
				return (*valaddr == -1) ?
					CF_UNDEF : CF_CHAR;
			}


		default:
			if( chtab == (int *)NULL)
			{
				*sourcepnt = ++sptr;
				return CF_INVALID;
			}
			else
			{
				valaddr = &(chtab[(cv & 0xff) + 256]);
				*sourcepnt = ++sptr;
				*tabpnt = valaddr;
				return (*valaddr == -1) ?
					CF_UNDEF : CF_CHAR;
			}

		case '0': case '1': case '2': case '3':
		case '4': case '5': case '6': case '7':
			{
				numval = cv - '0';
				cv =  *(++sptr);
				if(cv >= '0' && cv <= '7')
				{
					numval = numval * 8 +
						cv - '0';

					cv = *(++sptr);
					if(cv >= '0' && cv <= '7')
					{
						numval = numval * 8 +
							cv - '0';
						++sptr;
					}
				}
				*sourcepnt = sptr;
				*numret = numval & 0xff;
				return CF_NUMBER;
			}

		case 'x':
			switch(cv = *(++sptr))
			{
			case '0': case '1': case '2': case '3':
			case '4': case '5': case '6': case '7':
			case '8': case '9':
				numval = cv - '0';
				break;
			
			case 'a': case 'b': case 'c':
			case 'd': case 'e': case 'f':
				numval = cv - 'a' + 10; 
				break;
			
			case 'A': case 'B': case 'C':
			case 'D': case 'E': case 'F':
				numval = cv - 'A' + 10;
				break;
			
			default:
				*sourcepnt = sptr;
				return CF_INVALID;
			}

			switch(cv = *(++sptr))
			{
			case '0': case '1': case '2': case '3':
			case '4': case '5': case '6': case '7':
			case '8': case '9':
				numval = numval * 16 + cv - '0';
				++sptr;
				break;
			
			case 'a': case 'b': case 'c': 
			case 'd': case 'e': case 'f':
				numval = numval * 16 + cv - 'a' + 10; 
				++sptr;
				break;
			
			case 'A': case 'B': case 'C':
			case 'D': case 'E': case 'F':
				numval = numval * 16 + cv - 'A' + 10;
				++sptr;
				break;
			
			default:
				break;
			}

			*sourcepnt = sptr;
			*numret = numval;
			return CF_NUMBER;
		}
	}
}

int chtran(sourceptr)
	char **sourceptr;
{
	int numval;
	int *retptr;
	char *beforeptr = *sourceptr;

	switch(chtcfind(chtcpoint, sourceptr, &retptr, &numval))
	{
	case CF_END:
	default:
		return 0;
	
	case CF_INVALID:
		fracherror("invalid character constant", beforeptr, *sourceptr);
		return 0;

	case CF_UNDEF:
		fracherror("undefined character value", beforeptr, *sourceptr);
		return 0;

	case CF_NUMBER:
		return numval;

	case CF_CHAR:
		return *retptr;
	}
}


int genstring(str)
	char *str;
/*
	description	Produce 'D' records for a ascii string constant
			by chopping it up into lengths that will fit
			in the intermediate file
	parameters	a character string
	return		the length of the string total (machine code bytes)
*/
{
#define STCHPERLINE 20
	int rvlen = 0, linecount;

	while(*str != '\0')
	{
		goutptr = &goutbuff[2];

		for( linecount = 0; 
			linecount < STCHPERLINE && *str != '\0';
			linecount++)
		{
			gout2hex(chtran(&str));
			goutch(IFC_EMU8);
			rvlen++;
		}

		if(goutptr > &goutbuff[2])
		{
			goutch('\n');
			fwrite(goutbuff,sizeof (char), goutptr - &goutbuff[0], 
				intermedf);
		}
	}

	return rvlen;
}
	
static char *pepolptr;
static int pepolcnt;
static long etop;
static int	etopseg;
#define STACKALLOWANCE 4 /* number of level used outside polish expr */

pevalexpr(sub, exn)
	int sub, exn;
/*
	description	evaluate and save the results of an expression tree
	parameters	the subscript to the evalr element to place the results
			the subscript of the root node of a parser expression
				tree
	globals		the evaluation results array
			the expression stack
			the expression tree node array
	return		in evalr[sub].seg == SSG_UNDEF if the polish expression
			conversion overflowed, or any undefined symbols were
			referenced.
*/
{
	etop = 0;
	etopseg = SSG_UNUSED;
	estkm1p = &estk[0];

	pepolptr = &evalr[sub].exprstr[0];
	pepolcnt = PPEXPRLEN;

	if(pepolcon(exn))
	{
		evalr[sub].seg = etopseg;
		evalr[sub].value = etop;
		polout('\0');
	}
	else
	{
		evalr[sub].exprstr[0] = '\0';
		evalr[sub].seg = SSG_UNDEF;
	}
}

polout(ch)
	char ch;
/*
	description	output a character to a evar[?].exprstr array
	globals		parser expression to polish pointer pepolptr
*/
{
	if(pepolcnt > 1)
	{
		*pepolptr++ = ch;
		pepolcnt --;
	}
	else
	{
		*pepolptr = '\0';
		fraerror("overflow in polish expression conversion");
	}
}

polnumout(inv)
	unsigned long inv;
/*
	description	output a long constant to a polish expression
*/
{
	if( inv > 15)
		polnumout(inv >> 4);
	polout(hexch((int) inv ));
}

pepolcon(esub)
	int esub;
/*
	description	convert an expression tree to polish notation
			and do a preliminary evaluation of the numeric value
			of the expression
	parameters	the subscript of an expression node
	globals		the expression stack
			the polish expression string in an evalr element
	return		False if the expression stack overflowed

			The expression stack top contains the
			value and segment for the result of the expression
			which are propgated along as numeric operators are
			evaluated.  Undefined references result in an
			undefined result.
*/
{
	switch(enode[esub].evs)
	{
	case  PCCASE_UN:
		{
			if( ! pepolcon(enode[esub].left))
				return FALSE;

			polout(enode[esub].op);

			switch(enode[esub].op)
			{
#include "fraeuni.h"
			}
		}
		break;

	case  PCCASE_BIN:
		{
			if( ! pepolcon(enode[esub].left))
				return FALSE;

			polout(IFC_LOAD);

			if(estkm1p >= &estk[PESTKDEPTH-1-STACKALLOWANCE])
			{
				fraerror("expression stack overflow");
				return FALSE;
			}

			(++estkm1p)->v = etop;
			estkm1p -> s = etopseg;
			etopseg = SSG_UNUSED;	
			etop = 0;

			if( ! pepolcon(enode[esub].right))
				return FALSE;

			polout(enode[esub].op);

			if(estkm1p -> s != SSG_ABS)
				etopseg = estkm1p -> s;

			switch(enode[esub].op)
			{
#include "fraebin.h"
			}
		}
		break;

	case  PCCASE_DEF:
		if(enode[esub].sym -> seg > 0)
		{
			polnumout(1L);
			etop = 1;
			etopseg = SSG_ABS;
		}
		else
		{
			polnumout(0L);
			etop = 0;
			etopseg = SSG_ABS;
		}
		break;

	case  PCCASE_SYMB:
		etop = (enode[esub].sym) -> value;
		etopseg = (enode[esub].sym) -> seg;
		if(etopseg == SSG_EQU ||
		   etopseg == SSG_SET ) 
		{
			etopseg = SSG_ABS;
			polnumout((unsigned long)(enode[esub].sym) -> value);
		}
		else
		{
			polnumout((unsigned long)(enode[esub].sym) -> symnum);
			polout(IFC_SYMB);
		}
		break;
			
	case  PCCASE_PROGC:
		polout(IFC_PROGCTR);
		etop = locctr;
		etopseg = SSG_ABS;
		break;
			
	case  PCCASE_CONS:
		polnumout((unsigned long)enode[esub].val);
		etop = enode[esub].val;
		etopseg = SSG_ABS;
		break;

	}
	return TRUE;
}
