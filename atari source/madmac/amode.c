/* amode.c */

/*
 *  Parse 68000/68020 addressing modes
 *	amode(n)
 *	reglist()
 *
 */
#include "as.h"
#include "amode.h"
#define DEF_KW
#include "kwtab.h"
#define DEF_MN
#include "mntab.h"

#define EXPRSIZE	128	/* maximum #tokens in an expression */


extern TOKEN *tok;

/*
 *  Address-mode information
 *
 */
int nmodes;			/* number of addr'ing modes found */
int am0;			/* addressing mode */
int a0reg;			/* register */
TOKEN a0expr[EXPRSIZE];		/* expression */
VALUE a0exval;			/* expression's value */
WORD a0exattr;			/* expression's attribute */
int a0ixreg;			/* index register */
int a0ixsiz;			/* index register size (and scale) */
TOKEN a0oexpr[EXPRSIZE];	/* outer displacement expression */
VALUE a0oexval;			/* outer displacement value */
WORD a0oexattr;			/* outer displacement attribute */
SYM *a0esym;			/* external symbol involved in expression */

int am1;			/* addressing mode */
int a1reg;			/* register */
TOKEN a1expr[EXPRSIZE];		/* expression */
VALUE a1exval;			/* expression's value */
WORD a1exattr;			/* expression's attribute */
int a1ixreg;			/* index register */
int a1ixsiz;			/* index register size (and scale) */
TOKEN a1oexpr[EXPRSIZE];	/* outer displacement expression */
VALUE a1oexval;			/* outer displacement value */
WORD a1oexattr;			/* outer displacement attribute */
SYM *a1esym;			/* external symbol involved in expression */


amode(acount)
int acount;		/* 1, parse two comma-seperated modes */
{

	/*
	 *  initialize global return values
	 */
	nmodes = a0reg = a1reg = 0;
	am0 = am1 = AM_NONE;
	a0expr[0] = a0oexpr[0] = a1expr[0] = a1oexpr[0] = ENDEXPR;
	a0exattr = a0oexattr = a1exattr = a1oexattr = 0;
	a0esym = a1esym = (SYM *)NULL;

	/*
	 *  if at EOL, then no addr modes at all
	 */
	if (*tok == EOL)
		return 0;


	/*
	 *  Parse first addressing mode
	 *
	 */
#define	AnOK	a0ok
#define	AMn	am0
#define	AnREG	a0reg
#define	AnIXREG	a0ixreg
#define	AnIXSIZ	a0ixsiz
#define	AnEXPR	a0expr
#define	AnEXVAL	a0exval
#define	AnEXATTR a0exattr
#define	AnOEXPR	a0oexpr
#define	AnOEXVAL a0oexval
#define	AnOEXATTR a0oexattr
#define AnESYM	a0esym
#define	AMn_IX0	am0_ix0
#define	AMn_IXN	am0_ixn
#include "parmode.c"

	/*
	 *  If caller wants only one mode, return just one (ignore comma);
	 *  if there is no second addressing mode (no comma), then return
	 *  just one anyway.
	 */
	nmodes = 1;
	if (acount == 0 ||
		  *tok != ',')
		return 1;
	++tok;			/* eat comma */

	/*
	 *  Parse second addressing mode
	 *
	 */
#define	AnOK	a1ok
#define	AMn	am1
#define	AnREG	a1reg
#define	AnIXREG	a1ixreg
#define	AnIXSIZ	a1ixsiz
#define	AnEXPR	a1expr
#define	AnEXVAL	a1exval
#define	AnEXATTR a1exattr
#define	AnOEXPR	a1oexpr
#define	AnOEXVAL a1oexval
#define	AnOEXATTR a1oexattr
#define AnESYM	a1esym
#define	AMn_IX0	am1_ix0
#define	AMn_IXN	am1_ixn
#include "parmode.c"

	nmodes = 2;
	return 2;

	/*
	 *  Error messages:
	 */
badmode:
	return error("addressing mode syntax");

unmode:
	return error("unimplemented addressing mode");
}


/*
 *  Parse register list
 */
reglist(a_rmask)
WORD *a_rmask;
{
	static WORD msktab[] = {
		0x0001, 0x0002, 0x0004, 0x0008,
		0x0010, 0x0020, 0x0040, 0x0080,
		0x0100, 0x0200, 0x0400, 0x0800,
		0x1000, 0x2000, 0x4000, 0x8000
	};
	register WORD rmask;
	register int r, cnt;

	rmask = 0;
	for (;;)
	{
		if (*tok >= KW_D0 && *tok <= KW_A7)
			r = *tok++ & 15;
		else break;

		if (*tok == '-')
		{
			++tok;
			if (*tok >= KW_D0 && *tok <= KW_A7)
				cnt = *tok++ & 15;
			else return error("register list syntax");

			if (cnt < r)
				return error("register list order");
			cnt -= r;
		}
		else cnt = 0;

		while (cnt-- >= 0)
			rmask |= msktab[r++];
		if (*tok != '/')
			break;
		++tok;
	}

	*a_rmask = rmask;
	return OK;
}
