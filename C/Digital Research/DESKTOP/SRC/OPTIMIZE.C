/*	OPTIMIZE.C	1/25/84 - 06/05/85	Lee Jay Lorenzen	*/
/*	merge source	5/28/87			mdf			*/

/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 2.3
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985 - 1987		Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <vdi.h>
#endif
#else
#include <obdefs.h>
#endif
#include "taddr.h"
#include "deskrsrc.h"
#include "deskgraf.h"
#include "optimize.h"

EXTERN UWORD	intin[];
EXTERN UWORD	intout[];
EXTERN UWORD	contrl[];

#if GEM & (GEM2 | GEM3 | XGEM)
EXTERN VOID gsx2(VOID);

WORD sound(WORD isfreq, WORD freq, WORD dura)
{
	WORD	cnt;

	intin[0] = freq;
	intin[1] = dura;
	if (isfreq)
	{
		/* make a sound */
		contrl[5] = 61;
		cnt = 2;
	}
	else
	{
		/* get / set mute status */
		contrl[5] = 62;
		cnt = 1;
	}
	contrl[0] = 5;
	contrl[1] = 0;
	contrl[3] = cnt;
	contrl[6] = gl_handle;
	gsx2();
	return(intout[0]);
}
#endif

WORD bit_num(UWORD flag)
{
	WORD	i;
	UWORD	test;

	if ( !flag )
		return(-1);
	else
	{
		for (i=0,test=1; !(flag & test); test <<= 1,i++)
			;
		return(i);
	}
}

WORD mid(WORD lo, WORD val, WORD hi)
{
	if (val < lo)
		return(lo);
	else if (val > hi)
		return(hi);
	else
		return(val);
}

BYTE *strscn(BYTE *ps, BYTE *pd, BYTE stop)
{
	while ( (*ps) && (*ps != stop) )
		*pd++ = *ps++;
	return(pd);
}

/* Strip out period and turn into raw data. */
VOID fmt_str(BYTE *instr, BYTE *outstr)
{
	WORD	count;
	BYTE	*pstr;

	pstr = instr;
	while( (*pstr) && (*pstr != '.') )
		*outstr++ = *pstr++;
	if (*pstr)
	{
		count = 8 - (WORD)(pstr - instr);
		while ( count-- )
			*outstr++ = ' ';
		pstr++;
		while (*pstr)
			*outstr++ = *pstr++;
	}
	*outstr = '\0';
}

/* Insert in period and make into true data. */
VOID unfmt_str(BYTE *instr, BYTE *outstr)
{
	BYTE	*pstr, temp;

	pstr = instr;
	while( (*pstr) && ((pstr - instr) < 8) )
	{
		temp = *pstr++;
		if (temp != ' ')
			*outstr++ = temp;
	}
	if (*pstr)
	{
		*outstr++ = '.';
		while (*pstr)
		{
			temp = *pstr++;
			if (temp != ' ')
				*outstr++ = temp;
		}
	}
	*outstr = NULL;
}

VOID fs_sset(LONG tree, WORD obj, LONG pstr, LONG *ptext, WORD *ptxtlen)
{
	LONG	spec;

	*ptext = LLGET( spec = LLGET(OB_SPEC(obj)) );
	LSTCPY(*ptext, pstr);
	*ptxtlen = LWGET( spec + 24 );
}

VOID inf_sset(LONG tree, WORD obj, BYTE *pstr)
{
	LONG	text;
	WORD	txtlen;

	fs_sset(tree, obj, (LONG)ADDR(pstr), &text, &txtlen);
}

VOID fs_sget(LONG tree, WORD obj, LONG pstr)
{
	LONG	ptext;

	ptext = LLGET( LLGET(OB_SPEC(obj)) );
	LSTCPY(pstr, ptext);
}

VOID inf_sget(LONG tree, WORD obj, BYTE *pstr)
{
	fs_sget(tree, obj, (LONG)ADDR(pstr));
}

VOID inf_fldset(LONG tree, WORD obj, UWORD testfld, UWORD testbit,
	UWORD truestate, UWORD falsestate)
{
	LWSET(OB_STATE(obj), (testfld & testbit) ? truestate : falsestate);
}

WORD inf_gindex(LONG tree, WORD baseobj, WORD numobj)
{
	WORD	retobj;

	for (retobj=0; retobj < numobj; retobj++)
	{
		if (LWGET(OB_STATE(baseobj+retobj)) & SELECTED)
			return(retobj);
	}
	return(-1);
}

/*
*	Return 0 if cancel was selected, 1 if okay was selected, -1 if
*	nothing was selected.
*/
WORD inf_what(LONG tree, WORD ok, WORD cncl)
{
	WORD	field;

	/* dangerous assumption! */
	field = inf_gindex(tree, ok, 2);
	if (field != -1)
	{
		LWSET(OB_STATE(ok + field), NORMAL);
		field = (field == 0);
	}
	return(field);
}

/*
*	Routine to see if the test filename matches one of a set of 
*	comma delimited wildcard strings.
*		e.g.,	pwld = "*.COM,*.EXE,*.BAT"
*		 	ptst = "MYFILE.BAT"
*/
WORD wildcmp(BYTE *pwld, BYTE *ptst)
{
	BYTE	*pwild;
	BYTE	*ptest;

	/* skip over *.*, and *.ext faster */
	while (*pwld)
	{
		ptest = ptst;
		pwild = pwld;
		/* move on to next set of wildcards */
		pwld = scasb(pwld, ',');
		if (*pwld)
			pwld++;
		/* start the checking */
		if (pwild[0] == '*')
		{
			if (pwild[2] == '*')
				return(TRUE);
			else
			{
				pwild = &pwild[2];
				ptest = scasb(ptest, '.');
				if (*ptest)
					ptest++;
			}
		}
		/* finish off comparison */
		while( (*ptest) && (*pwild) && (*pwild != ',') )
		{
			if (*pwild == '?')
			{
				pwild++;
				if (*ptest != '.')
					ptest++;
			}
			else
			{
				if (*pwild == '*')
				{
					if (*ptest != '.')
						ptest++;
					else		
						pwild++;
				}
				else
				{
					if (*ptest == *pwild)
					{
						pwild++;
						ptest++;
					}
					else
						break;
				}
			}
		}
		/* eat up remaining wildcard chars */
		while( (*pwild == '*') || (*pwild == '?') || (*pwild == '.') )
			pwild++;
		/* if any part of wildcard or test is */
		/* left then no match */
		if ( ((*pwild == NULL) || (*pwild == ',')) && (!*ptest) )
			return( TRUE );
	}
	return(FALSE);
}

/* Routine to insert a character in a string by */
VOID ins_char(REG BYTE *str, WORD pos, BYTE chr, REG WORD tot_len)
{
	REG WORD	ii, len;

	len = (WORD)strlen(str);

	for (ii = len; ii > pos; ii--)
		str[ii] = str[ii-1];
	str[ii] = chr;
	if (len+1 < tot_len)
		str[len+1] = NULL;
	else
		str[tot_len-1] = NULL;
}

BYTE *scasb(BYTE *p, BYTE b)
{
	REG BYTE	*lp;

	lp = p;
	while (*lp != b && *lp != '\0')
		lp++;
	return(lp);
}
