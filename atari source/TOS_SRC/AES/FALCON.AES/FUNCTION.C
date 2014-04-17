/*	Functions.c				7/14/92		D.Mui		*/

#include <portab.h>
#include <machine.h>
#include <taddr.h>
#include <obdefs.h>



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




/* 	Routine to set the variables x,y,w,h to the values found
*	in an x,y,w,h block (grect)
*/

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

r_set(pxywh, x, y, w, h)
	REG WORD	*pxywh;
	WORD		x, y, w, h;
{
	pxywh[0] = x;
	pxywh[1] = y;
	pxywh[2] = w;
	pxywh[3] = h;
}

/* 	Copy src xywh block to dest xywh block.		*/

rc_copy(psxywh, pdxywh)
	REG WORD	*psxywh;
	REG WORD	*pdxywh;
{
	*pdxywh++ = *psxywh++;
	*pdxywh++ = *psxywh++;
	*pdxywh++ = *psxywh++;
	*pdxywh++ = *psxywh++;
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


/* 	Routine to constrain a box within another box.  This is done by
*	seting the x,y of the inner box to remain within the
*	constraining box.
*/

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
	LSTCPY(*ptext, pstr);
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

	fs_sset(tree, obj, ADDR(pstr), &text, &txtlen);
}


	VOID
fs_sget(tree, obj, pstr)
	LONG		tree;
	WORD		obj;
	LONG		pstr;
{
	LONG		ptext;

	ptext = LLGET( LLGET(OB_SPEC(obj)) );
	LSTCPY(pstr, ptext);
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
	fs_sget(tree, obj, ADDR(pstr));
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



	WORD
merge_str(pdst, ptmp, parms)
	REG BYTE	*pdst;
	REG BYTE	*ptmp;
	UWORD		parms[];	
{
	REG WORD		num;
	WORD		do_value;
	BYTE		lholder[12];
	REG BYTE		*pnum;
	BYTE		*psrc;
	REG LONG		lvalue, divten;
	WORD		digit;

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
		lvalue = *((LONG *) &parms[num]);
		num += 2;
		do_value = TRUE;
		break;
	      case 'W':
		lvalue = parms[num];
		num += 2;
		do_value = TRUE;
		break;
	      case 'S':
		psrc = (BYTE *) parms[num]; 
		num += 2;
		while(*psrc)
		  *pdst++ = *psrc++;
		break;
	    }
	    if (do_value)
	    {
	      pnum = &lholder[0];
	      while(lvalue)
	      {
		divten = lvalue / 10;
		digit = (WORD) lvalue - (divten * 10);
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

