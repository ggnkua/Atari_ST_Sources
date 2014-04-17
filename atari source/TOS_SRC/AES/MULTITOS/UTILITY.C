/*	UTILITY.C	9/4/90			D.Mui			*/
/*	Restore back to C from V3.01					*/
/*	OPTIMIZE.C	1/25/84 - 01/27/85	Lee Jay Lorenzen	*/
/*	reg op 68k	2/10/85 - 04/03/85	LKW			*/
/*	remove mid,cmps 06/10/85		Mike Schmal		*/
/*		bit_num	06/10/85		Mike Schmal		*/
/*	Fix the bfill	4/3/86			Derek Mui		*/
/*	02/16/93	cjg	Convert to Lattice C 5.51		*/
/*	02/22/93	cjg	Force the use of prototypes		*/

/*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/
#include "pmisc.h"

#include "machine.h"
#include "objaddr.h"
#include "vdomode.h"

EXTERN WORD	gl_wchar;
EXTERN WORD	gl_hchar;
EXTERN WORD	gl_vdo;



	BYTE	
*r_slash( path )
	REG BYTE	*path;
{
	BYTE	*start;

	start = path;

	while( *path )
	  path++;

	while( *path != '\\' )
	{
	  if ( path == start )
	    break;

	  path--;
	}
	return( path );
}


/*	This routine convert binary number to hex value	*/

	VOID
lbintohex( longval, buffer ) 
	LONG	longval;
	BYTE	buffer[];
{
	WORD	i,j,k;
	LONG	value;
	BYTE	digit;
	BYTE	buf1[12];

	for ( i = 0,j = 0; j < 8; j++ )
	{
	  value = longval & 0x0000000FL;
	  longval >>= 4;
	  if ( ( value >= 0 ) && ( value <= 9 ) )
	    digit = (BYTE)(value) + '0';
	  else
	    digit = (BYTE)(value) + 0x37;

	  buf1[i++] = digit;
	    
	  if ( !longval )
	    break;
	}

	k = 0;

	for ( j = i - 1; j >= 0; j-- )
	  buffer[k++] = buf1[j];

	buffer[k] = 0;
}


/*	This routine convert binary number to ascii value	*/

	VOID
lbintoasc( longval, buffer ) 
	REG LONG	longval;
	REG BYTE	buffer[];
{
	REG WORD	i;
	UWORD	digit;
	WORD	j,k;
	LONG	divten;
	BYTE	buf1[12];

	i = 0;
	k = 0;
	if ( !longval )
	  buffer[k++] = '0';
	else
	{
	  while( longval )
	  {
	    divten = longval / 10L;
	    digit = (int)(longval - ( divten * 0x0AL ));
	    buf1[i++] = '0' + digit;
	    longval = divten;
	  }

	  for ( j = i - 1; j >= 0; j-- )
	    buffer[k++] = buf1[j];
	}

	buffer[k] = 0;
}


/*	change from ascii to binary value	*/
/*	TRUE is OK otherwise it is FALSE	*/

	WORD
asctobin( ptr, value )
	BYTE	*ptr;
	LONG	*value;
{
	LONG	n, n1;

	for ( n = 0, n1 = 0; *ptr; ptr++ )
	{
	  if ( ( *ptr >= '0' ) && ( *ptr <= '9' ) )
	  {
	    n1 = ( 10L * n1 ) + (LONG)( *ptr - '0' );
	    if ( n1 >= n )
	      n = n1;
	    else
	      return( FALSE );
	  }
	  else
	    return( FALSE );
	}	     	
	
	*value = n;
	return ( TRUE );
}


/* 	Routine to set the variables x,y,w,h to the values found
*	in an x,y,w,h block (grect)
*/
	VOID
r_get(pxywh, px, py, pw, ph)
	REG WORD	*pxywh;
	WORD		*px, *py, *pw, *ph;
{
	*px = pxywh[0];
	*py = pxywh[1];
	*pw = pxywh[2];
	*ph = pxywh[3];
}


/* 	Routine to set a x,y,w,h block to the x,y,w,h  
*	values passed in.
*/
	VOID
r_set(pxywh, x, y, w, h)
	REG WORD	*pxywh;
	WORD		x, y, w, h;
{
	pxywh[0] = x;
	pxywh[1] = y;
	pxywh[2] = w;
	pxywh[3] = h;
}


/* 	Routine to constrain a box within another box.  This is done by
*	seting the x,y of the inner box to remain within the
*	constraining box.
*/
	VOID
rc_constrain(pc, pt)
	REG GRECT	*pc;
	REG GRECT	*pt;
{
	  if (pt->g_x < pc->g_x)
	    pt->g_x = pc->g_x;
	  if (pt->g_y < pc->g_y)
	    pt->g_y = pc->g_y;
	  if ((pt->g_x + pt->g_w) > (pc->g_x + pc->g_w))
	    pt->g_x = (pc->g_x + pc->g_w) - pt->g_w;
	  if ((pt->g_y + pt->g_h) > (pc->g_y + pc->g_h))
	    pt->g_y = (pc->g_y + pc->g_h) - pt->g_h;
}


/* 	Copy src xywh block to dest xywh block.		*/
	VOID
rc_copy(psxywh, pdxywh)
	REG WORD	*psxywh;
	REG WORD	*pdxywh;
{
	*pdxywh++ = *psxywh++;
	*pdxywh++ = *psxywh++;
	*pdxywh++ = *psxywh++;
	*pdxywh = *psxywh;
}


/* 	Returns the union of two rectangles in ptr2.	*/
/*	Don't pass in 0s in x,y,w,h 			*/

	VOID
rc_union(p1, p2)
	REG GRECT	*p1, *p2;
{
	REG WORD	tx, ty, tw, th;

	tw = max(p1->g_x + p1->g_w, p2->g_x + p2->g_w);
	th = max(p1->g_y + p1->g_h, p2->g_y + p2->g_h);
	tx = min(p1->g_x, p2->g_x);
	ty = min(p1->g_y, p2->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
}

/* 	Returns the intersection of two rectangles in ptr2.
*	Returns true if there was an intersection where the width
*	is greater than x and the height is greater than y.
*/

	WORD
rc_intersect(p1, p2)
	REG GRECT	*p1, *p2;
{
	REG WORD	tx, ty, tw, th;

	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = max(p2->g_x, p1->g_x);
	ty = max(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return( (tw > tx) && (th > ty) );
}


/* 	Return true if the x,y position is within the grect	*/

	UWORD
inside(x, y, pt)
	REG WORD	x, y;
	REG GRECT	*pt;
{
	if ( (x >= pt->g_x) && (y >= pt->g_y) &&
	     (x < pt->g_x + pt->g_w) && (y < pt->g_y + pt->g_h) )
	  return(TRUE);
	else
	  return(FALSE);
} /* inside */


/* 	Returns true if the two grects are equal.	*/

	WORD
rc_equal(p1, p2)
	REG WORD	*p1, *p2;
{
	REG WORD	i;

	for(i=0; i<4; i++)
	{
	  if (*p1++ != *p2++)
	    return(FALSE);
	}
	return(TRUE);
}


/* 	move bytes from source to dest for a count of N	*/

	VOID
movs(num, ps, pd)
	REG WORD	num;
	REG BYTE	*ps, *pd;
{
	do
	  *pd++ = *ps++;
	while (--num);
}


/* 	Returns minimum value of two words	*/

	WORD
min(a, b)
	WORD		a, b;
{
	return( (a < b) ? a : b );
}


/* 	Returns maximum value of two words	*/

	WORD
max(a, b)
	WORD		a, b;
{
	return( (a > b) ? a : b );
}


/* 	Copy the byte passed in to the dest pointer for a count of N	*/

	VOID
bfill(num, bval, addr)
	REG WORD	num;
	REG BYTE	bval;
	REG BYTE	*addr;
{
	while(num)
	{
	  *addr++ = bval;
	  num --;
	}
}


/* 	Return upper case value		*/

	BYTE
toupper(ch)
	REG BYTE	ch;
{
	if ( (ch >= 'a') &&
	     (ch <= 'z') )
	  return(ch - 32);
	else
	  return(ch);
}


/*	Set upper case to a string	*/

	VOID
upperstr( str )
	BYTE	*str;
{
	BYTE	c;

	  while( c = *str )
	    *str++ = toupper( c );
}


/* 	Returns a byte pointer pointing to the matched byte or
*	the end of the string.
*/

	BYTE
*scasb(p, b)
	REG BYTE		*p;
	REG BYTE		b;
{
	for(; *p && *p != b; p++);
	return (p);
}


/*	Length of a string	*/

	WORD
strlen(p1)
	REG BYTE	*p1;
{
	REG WORD	len;

	len = 0;
	while( *p1++ )
	  len++;

	return(len);
}


	WORD
strcmp(p1, p2)
	REG BYTE	*p1, *p2;
{
	while(*p1)
	{
	  if (*p1++ != *p2++)
	    return(FALSE);
	}
	if (*p2)
	  return(FALSE);
	return(TRUE);
}


/*	P1 is the source and is NULL terminated		*/
/*	'?' in the p1 matches a character		*/
/*	'\' causes the matching to quit			*/
/*	P2 is the target is NULL or SPACE terminated	*/

	WORD
nstrcmp( p1, dest )
	BYTE	*p1,**dest;
{
	BYTE	*p2;

	p2 = *dest;

	while( *p1 )
	{
	  if ( *p1 == '\\' )
	  {
	    *dest = p2;
	    return( TRUE );
	  }

	  if ( ( *p1 != *p2 ) && ( *p1 != '?' ) )
	    break;

	   p1++;
	   p2++;	    
	}

	if ( ( !*p1 ) && ( ( !*p2 ) || ( *p2 == ' ' ) ) )
	{
	  p2++;
	  *dest = p2;
	  return(TRUE);
	}

	return( FALSE );
}





/* 	This is the true version of strcmp. Shall we remove the
*	other -we shall see!!!
*	Returns	- <0 if(str1<str2), 0 if(str1=str2), >0 if(str1>str2)
*/

	WORD
strchk(s, t)
	REG BYTE	s[], t[];
{
	REG WORD	i;

	i = 0;
	while( s[i] == t[i] )
	  if (s[i++] == NULL)
	    return(0);
	return(s[i] - t[i]);
}


	BYTE
*strcpy(ps, pd)
	REG BYTE	*ps, *pd;
{
	while(*pd++ = *ps++)
	  ;
	return(pd);
}


/* 	copy the src to destination untill we are out of characters
*	or we get a char match.
*/

	BYTE
*strscn(ps, pd, stop)
	REG BYTE	*ps, *pd, stop;
{
	while ( (*ps) &&
		(*ps != stop) )
	  *pd++ = *ps++;
	return(pd);
}


	BYTE
*strcat(ps, pd)
	REG BYTE	*ps, *pd;
{
	while(*pd)
	  pd++;
	while(*pd++ = *ps++)
	  ;
	return(pd);
}


/*
*	Strip out period and turn into raw data.
*/
	VOID		/* 9/4/90	*/
fmt_str(instr, outstr)
	REG BYTE	*instr;
	REG BYTE	*outstr;
{
	WORD		i;

	for ( i = 0; i < 8; i++ )
	{
	  if ( ( *instr ) && ( *instr != '.' ) )
	    *outstr++ = *instr++;
	  else
	  {
	    if ( *instr )
	      *outstr++ = ' ';
	    else
	      break;
	  }
	}

	if ( *instr )		/* must be a dot	*/
	  instr++;

	while( *instr )
	  *outstr++ = *instr++;

	*outstr = NULL;
}


/*
*	Insert in period and make into true data.
*/
	VOID			/* 9/4/90	*/
unfmt_str(instr, outstr)
	REG BYTE	*instr;
	REG BYTE	*outstr;
{
	WORD		i;
	BYTE		temp;		

	for( i = 0; i < 8; i++ )
	{
	  temp = *instr++;

	  if ( ( temp ) && ( temp != ' ' ) )
	    *outstr++ = temp;	
	  else
	  {
	    if ( !temp )	/* at the end ?	*/	
	      goto u_1;
	  }
	}

	if ( *instr )		/* any extension ? */
	{
	  *outstr++ = '.';
	  while (*instr)
	    *outstr++ = *instr++;
	}
u_1:
	*outstr = NULL;
}


/* 	Copy the long in the ob_spec field to the callers variable
*	ptext.  Next copy the string located at the ob_spec long to the
*	callers pstr.  Finally copy the length of the tedinfo string
*	to the callers ptxtlen.
*/

	VOID
fs_sset(tree, obj, pstr, ptext, ptxtlen)
	LONG		tree;
	WORD		obj;
	LONG		pstr;
	REG LONG	*ptext;
	WORD		*ptxtlen;
{
	REG LONG	spec;

	*ptext = LLGET( spec = LLGET(OB_SPEC(obj)) );
	LSTCPY( ( BYTE *)*ptext, ( BYTE *)pstr);
	*ptxtlen = LWGET( spec + 24 );
}


	VOID
inf_sset(tree, obj, pstr)
	LONG		tree;
	WORD		obj;
	BYTE		*pstr;
{
	LONG		text;
	WORD		txtlen;

/*	fs_sset(tree, obj, ADDR(pstr), &text, &txtlen);*/
	fs_sset( tree, obj, ( LONG )pstr, &text, &txtlen );
}


	VOID
fs_sget(tree, obj, pstr)
	LONG		tree;
	WORD		obj;
	LONG		pstr;
{
	LONG		ptext;

	ptext = LLGET( LLGET(OB_SPEC(obj)) );
	LSTCPY( ( BYTE *)pstr, ( BYTE *)ptext);
}


/* 	inf_sget, fs_sget
* 	This routine copies the tedinfo string to the dst pointer.
*	The function inf_sget was the same as fs_sget.
*/

	VOID
inf_sget(tree, obj, pstr)
	LONG		tree;
	WORD		obj;
	BYTE		*pstr;
{
/*	fs_sget(tree, obj, ADDR(pstr));*/
	fs_sget(tree, obj, ( LONG )pstr );
}


/* 	This routine is used to set an objects flags based on 
*	the outcome of a 'and' operation.  The word is set to
*	the 'truestate' if the operation is true else set to
*	'falsestate'
*/

	VOID
inf_fldset(tree, obj, testfld, testbit, truestate, falsestate)
	LONG		tree;
	WORD		obj;
	UWORD		testfld, testbit;
	UWORD		truestate, falsestate;
{
	LWSET(OB_STATE(obj), (testfld & testbit) ? truestate : falsestate);
}


/* inf_gindex	for each object from baseobj for N objects return the object
*		that is selected or -1 if no objects are selected.
*/

	WORD
inf_gindex(tree, baseobj, numobj)
	LONG		tree;
	WORD		baseobj;
	WORD		numobj;
{
	WORD		retobj;

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

	WORD
inf_what(tree, ok, cncl)
	REG LONG		tree;
	REG WORD		ok, cncl;
{
	REG WORD		field;

	field = inf_gindex(tree, ok, 2);

	if (field != -1)
	{
	  LWSET(OB_STATE(ok + field), NORMAL);
	  field = (field == 0);
	}
	return(field);
}


	VOID
merge_str(pdst, ptmp, parms)
	REG BYTE	*pdst;
	REG BYTE	*ptmp;
	UWORD		parms[];	
{
	REG WORD	num;
	WORD		do_value;
	BYTE		lholder[12];
	REG BYTE	*pnum;
	BYTE		*psrc;
	REG LONG	lvalue, divten;
	WORD		digit;
	LONG		*parms2;
	WORD		*wtmp;

	parms2 = (LONG *)parms;
	num = 0;
	while(*ptmp)
	{
	  if (*ptmp != '%')
	    *pdst++ = *ptmp++;
	  else
	  {
	    ptmp++;
	    do_value = FALSE;
	    switch(*ptmp++)
	    {
	      case '%':
		*pdst++ = '%';
		break;
	      case 'L':
		lvalue = *((LONG *) &parms2[num]);
		num += 1;
		do_value = TRUE;
		break;
	      case 'W':
		wtmp = (WORD *)&parms2[num];
		lvalue = *wtmp;
		num += 1;
		do_value = TRUE;
		break;
	      case 'S':
		lvalue = *((LONG *) &parms2[num]);
		psrc = (BYTE *) lvalue; 
		num += 1;
		while(*psrc)
		  *pdst++ = *psrc++;
		break;
	    }
	    if (do_value)
	    {
	      pnum = &lholder[0];
	      while(lvalue)
	      {
		divten = lvalue / 10L;
		digit = (WORD)( lvalue - (divten * 10L));
		*pnum++ = '0' + digit;
		lvalue = divten;
	      }
	      if (pnum == &lholder[0])
		*pdst++ = '0';
	      else
	      {
		while(pnum != &lholder[0])
		  *pdst++ = *--pnum;
	      }
	    }
	  }
	}
	*pdst = NULL;
}


	WORD
wildcmp(pwild, ptest)
	REG BYTE		*pwild;
	REG BYTE		*ptest;
{
	while( (*ptest) && 
	       (*pwild) )
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
	        return(FALSE);
	    }
	  }
	}
						/* eat up remaining 	*/
						/*   wildcard chars	*/
	while( (*pwild == '*') ||
	       (*pwild == '?') ||
	       (*pwild == '.') )
	  pwild++;
						/* if any part of wild-	*/
						/*   card or test is	*/
						/*   left then no match	*/
	if ( (*pwild) ||
	     (*ptest) )
	  return(FALSE);
	else
	  return(TRUE);
}


/*	Copy the string not to exceed n characters	*/

	BYTE
*nstrcpy( src, dest, n )
	BYTE	*src,*dest;
	WORD	n;
{
	WORD len;

	len = strlen( src );
	if (len >= n)
	  len = n - 1;

	while (len-- > 0)
	 *dest++ = *src++;
	*dest++ = 0;
	return( dest );
}


/*
 * convert from an ST resolution to a Falcon mode word
 */

WORD
res2mode( WORD res )
{
    WORD monitor_type;	/* 0: ST mono monitor, 1,3: color monitor or TV,
			   2: VGA monitor
			 */
    WORD modecode;
    WORD oldmode;
    WORD rowlow;	/* OR with this to get a 200 pixel screen */
    WORD rowhi;		/* OR with this to get a 400 pixel screen */

    if ((gl_vdo & HIGHWORD) == FALCON)
    {
        monitor_type = mon_type();
        oldmode = setmode(-1);
    } else {
	monitor_type = 2;	/* assume VGA */
	oldmode = 0;
    }
    modecode = oldmode & PAL;

    if (!monitor_type) {
	return oldmode;
    } else if (monitor_type == 2) {
	rowlow = VERTFLAG;
	rowhi = 0;
	modecode |= VGA;
    } else {
	rowlow = 0;
	rowhi = VERTFLAG;
    }

    switch(res) {
    case 1: /* ST low */
	modecode |= STMODES|BPS4|COL40|rowlow;
	break;
    case 2: /* ST medium */
	modecode |= STMODES|BPS2|COL80|rowlow;
	break;
    case 3: /* ST high */
	modecode |= STMODES|BPS1|COL80|rowhi;
	break;
    case 4: /* TT medium */
	modecode |= BPS4|COL80|rowhi;
	break;
    case 5: /* TT high */
	modecode |= BPS1|COL80|rowhi;
	break;
    case 6: /* TT low */
	modecode |= BPS8|COL40|rowlow;
	break;
    default:
	modecode = oldmode;
	break;
    }
    return modecode;
}

/*
 * try to guess the resolution closest to the Falcon video mode
 * given to us
 */

WORD
mode2res( WORD mode )
{
    WORD bps;
    WORD columns;

    bps = mode & NUMCOLS;
    columns = (mode & COL80);

    if (mode & STMODES) {
	switch(bps) {
	    case BPS1:
	        return 3;	/* ST high */
	    case BPS2:
		return 2;	/* ST medium */
	    default:
		return 1;	/* ST low */
	}
    }
    if (bps == 1)
	return (columns == COL80) ? 5 : 1;	/* TT high */
    if (bps == 2)
	return (columns == COL80) ? 2 : 1;
    if (bps == 4)
	return (columns == COL80) ? 4 : 1;
    if (bps == 8)
	return 6;	/* TT LOW */
    return 1;
}

