/*	GEMOBED.C	05/29/84 - 02/10/85		Gregg Morris	*/
/*	Reg Opt		03/08/85 - 03/09/85		Derek Mui	*/
/*	1.1		03/21/85 - 04/05/85		Lowell Webster	*/
/*	Redefine del code 	   05/24/85		Derek Mui	*/
/*	Trying 1.2		   10/14/85		Derek Mui	*/
/*	Fix at ob_center	   3/16/87		Derek Mui	*/
/*	Modify rsc constants	   11/25/87		D.Mui		*/
/*	Fix at find_pos		   03/25/88		D.Mui		*/
/*	Inclined code of ob_getsp  03/25/88		D.Mui		*/
/*	Change at ob_center for 3D buttons	7/7/92	D.Mui		*/
/*  	02/16/93	cjg	Convert to Lattice C 5.51		*/
/*	02/23/93	cjg	Force the use of prototypes		*/
/*	Fix at pxl_rect to use ob_offset again  2/25/93 H.M.Krober	*/
/*	Add GDOS font support to TEDINFO	5/21/93 H.M.Krober	*/
/*	Now proportional FONTS work with FTEXT	6/15/93 H.M.Krober	*/
/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "objaddr.h"
#include "gemusa.h"

#define BACKSPACE 0x0E08			/* backspace		*/
#define SPACE 0x3920				/* ASCII <space>	*/
#define UP 0x4800				/* up arrow		*/
#define DOWN 0x5000				/* down arrow		*/
#define LEFTKEY 0x4B00				/* left arrow		*/
#define RIGHTKEY 0x4D00				/* right arrow		*/
#define DELETE 0x537f				/* keypad delete	*/
#define TAB 0x0F09				/* tab			*/
#define BACKTAB 0x0F00				/* backtab		*/
#define RETURN 0x1C0D				/* carriage return	*/
#define ENTER 0x720D				/* enter key on keypad	*/
#define ESCAPE 0x011B				/* escape		*/
#define BYTESPACE 0x20				/* ascii space in bytes	*/

EXTERN WORD	gl_wchar;
EXTERN WORD	gl_hchar;
EXTERN WORD	gl_hbox;
EXTERN WORD	gl_width;
EXTERN WORD	gl_height;
EXTERN WORD	gl_wschar;
EXTERN WORD	gl_hschar;
EXTERN WORD	cu_wchar;
EXTERN WORD	cu_hchar;

EXTERN THEGLO	D;

EXTERN GRECT	gl_rzero;

/*
 *	These are needed for proportional GDOS Fonts
 *	+++ 6/14/94 HMK
 */
MLOCAL WORD	old_w;		/* old width   of TEDINFO 	*/
MLOCAL WORD	new_w;		/* new width   of TEDINFO 	*/
MLOCAL WORD	old_x;		/* old x coord of TEDINFO 	*/

	VOID
ob_center(tree, pt)
	LONG		tree;
	GRECT		*pt;
{
	REG WORD		xd, yd, wd, hd;
	REG LONG		plong;
	
	WORD		iword,th;
	LONG		ilong;
	GRECT		rec;	

	plong = OB_X(ROOT);
	wd = LWGET(plong + 0x04L);
	hd = LWGET(plong + 0x06L); /* pixel center, no character snap 881101 */
	xd = ((gl_width - wd) / 2) /* / gl_wchar * gl_wchar */;
	yd = gl_hbox + ((gl_height - gl_hbox - hd) / 2);
	LWSET(plong, xd);
	LWSET(plong + 0x02L, yd);

						/* account for outline	*/
	if ( LWGET(OB_STATE(ROOT)) & OUTLINED )
	{
	  xd -= (xd >= 3) ? 3 : xd;		/* don't go off the screen */
	  yd -= (yd >= 3) ? 3 : yd;
 	  wd += 6;
	  hd += 6;
	}

	if ( LWGET(OB_STATE(ROOT)) & SHADOWED )
	{
	  ob_sst( tree, ROOT, &ilong, &iword, &iword, &iword, &rec, &th );
	  th = ( th > 0 ) ? th : -th;
	  th = 2 * th;
	  wd += th;
	  hd += th;
	}

	r_set( ( WORD *)pt, xd, yd, wd, hd);
}


/*
*	Routine to scan thru a string looking for the occurrence of
*	the specified character.  IDX is updated as we go based on
*	the '_' characters that are encountered.  The reason for
*	this routine is so that if a user types a template character
*	during field entry the cursor will jump to the first 
*	raw string underscore after that character.
*/
	WORD
scan_to_end(pstr, idx, chr)
	REG BYTE		*pstr;
	REG WORD		idx;
	BYTE		chr;
{
	while( (*pstr) &&
	       (*pstr != chr) )
	{
	  if (*pstr++ == '_')
	    idx++;
	}
	return(idx);
}


/*
*	Routine to insert a character in a string by
*/
	VOID
ins_char(str, pos, chr, tot_len)
	REG BYTE		*str;
	WORD		pos;
	BYTE		chr;
	REG WORD		tot_len;
{
	REG WORD		ii, len;

	len = strlen(str);

	for (ii = len; ii > pos; ii--)
	  str[ii] = str[ii-1];
	str[ii] = chr;
	if (len+1 < tot_len)
	  str[len+1] = NULL;
	else
	  str[tot_len-1] = NULL;
}


/*
*       Routine that returns a format/template string relative number
*       for the position that was input (in raw string relative numbers).
*       The returned position will always be right before an '_'.
*/
        WORD
find_pos(str, pos)
        REG BYTE                *str;
        REG WORD                pos;
{
        REG WORD                i;


        for (i=0; pos > 0; i++) 
        {
          if (str[i] == '_')
            pos--;
        }
                                                /* skip to first one    */
        while( (str[i]) &&
               (str[i] != '_') )
          i++;
/* here we may have come to the end of the string without finding a field
	backup to the last position where there was one and advance one
	position past it...						*/

	if (str[i]==0)
	{
		while ((str[i] != '_') && i >= 0 ) i--;
		if ( str[i] ) i++;
	}
        return(i);
}


	VOID
pxl_rect(tree, obj, ch_pos, pt, edblk)
	REG LONG	tree;
	REG WORD	obj;
	WORD		ch_pos;
	REG GRECT	*pt;
	TEDINFO		*edblk;
{
	GRECT		o;
	WORD		numchs;
	WORD		wc, hc;
	WORD		thickness;
	WORD		type;
	REG THEGLO	*DGLO;

	DGLO = &D;

#if 0	/* ++HMK 02/25/93 
	/* Since of 08/06/92 ob_actxywh is no longer using  */
	/* ob_offset to calculate the size. Now it's using  */
	/* ob_gclip which will also takes OUTLINE, SHADOW   */
	/* and borders in consideration. But this will      */
	/* mess up the position of the cursor when the      */
	/* object is left or right aligend. So we call good */
	/* old ob_offset directly.			    */

	ob_actxywh(tree, obj, &o);

#else
	ob_offset(tree, obj, &o.g_x, &o.g_y);
	o.g_w = LWGET(OB_WIDTH(obj));
	o.g_h = LWGET(OB_HEIGHT(obj));
#endif			
	/*			
	 * +++ 6/14/93 HMK 
	 * Changed from edblk->te_tmplt to DGLO->g_fmtstr[0]
	 * Because of proportional fonts we need	|
	 * to know the width of the actual 		|
	 * string					V
	 */
	numchs = gr_just(edblk->te_just, &DGLO->g_fmtstr[0], 
			o.g_w, o.g_h, &o);

#if 0
	pt->g_x = o.g_x + (ch_pos * gl_wchar);
#endif
			/* ++HMK: "edblk->thickness stuff added "  added 02/25/93 */

	type = LWGET(OB_TYPE(obj));
	if ((type == G_FBOXTEXT) || (type == G_BOXTEXT)) {
		thickness = edblk->te_thickness;
		if (edblk->te_just == TE_RIGHT)
			thickness = (thickness < 0) ? 1 : thickness;
		else if (edblk->te_just == TE_LEFT)
			thickness = (thickness < 0) ? 0 : (-thickness);
		else
			thickness = 0;
	} else
		thickness = 0;

	if (edblk->te_font == GDOS_MONO) {	/* Monospace Font */
		pt->g_x = o.g_x + (ch_pos * cu_wchar) - thickness;
		pt->g_y = o.g_y;
		pt->g_w = cu_wchar;
		pt->g_h = cu_hchar;
	} else if ((edblk->te_font == GDOS_PROP) || (edblk->te_font == GDOS_BITM)) {
		WORD		wc;			/* Proportional Font */
		WORD		dummy;
		WORD		pptw = 0;
		REG WORD	i;
		REG BYTE 	*s;

		s = &DGLO->g_fmtstr[0];
		for (i = 0 ; i < ch_pos ; i++, s++) {
			vqt_width(*s, &wc, &dummy, &dummy);
			pptw += wc;
		}
		vqt_width(*s, &wc, &dummy, &dummy);

		pt->g_x = o.g_x + pptw - thickness; 
		pt->g_y = o.g_y;
		pt->g_w = wc;
		pt->g_h = cu_hchar;
	} else {					/* System Font */
		if (edblk->te_font == SMALL) {
			wc = gl_wschar;
			hc = gl_hschar;	
		} else {
			wc = gl_wchar;
			hc = gl_hchar;	
		}	
		pt->g_x = o.g_x + (ch_pos * wc) - thickness;
		pt->g_y = o.g_y;
		pt->g_w = wc;
		pt->g_h = hc;
	}
}


/*
*	Routine to redraw the cursor or the field being editted.
*/
	VOID
curfld(tree, obj, new_pos, dist, edblk)
	OBJECT		*tree;
	WORD		obj, new_pos;
	WORD		dist;
	TEDINFO		*edblk;
{
	GRECT		oc, t;
	WORD		wc, dummy;
	WORD		prop;
	REG THEGLO	*DGLO;

	DGLO = &D;
	prop = FALSE;
	if (edblk->te_font == GDOS_MONO) {
		wc = cu_wchar;
	} else if ((edblk->te_font == GDOS_PROP) || (edblk->te_font == GDOS_BITM)) {
		vqt_width(((BYTE*)edblk->te_ptext)[new_pos], &wc, &dummy, &dummy);
	} else {
		if (edblk->te_font == SMALL) {
			wc = gl_wschar;
		} else {
			wc = gl_wchar;
		}	
	}
        pxl_rect((LONG)tree, obj, new_pos, &t, edblk);

	if (dist) {	/* redraw text */
	  if ((edblk->te_font == GDOS_PROP) || (edblk->te_font == GDOS_BITM)) {
		WORD		pptw = 0;
		WORD		dummy;
		REG WORD	i, l;
		REG BYTE 	*s;

		s = &DGLO->g_fmtstr[new_pos];
		l = strlen(s);
		for (i = 0 ; i < l; i++, s++) {		/* get width of str portion */
			vqt_width(*s, &wc, &dummy, &dummy);
			pptw += wc;
		}
		t.g_w += pptw + 1;
		prop = TRUE;
	  } else 
		  t.g_w += (dist - 1) * wc + 1;	/* ++ERS: "+1" added 1/19/93 */

	  if ((tree[obj].ob_flags & IS3DOBJ) )
	  {
	    WORD tmpx;

	    Debug7("\r\ncurfld: is 3d obj\r\n");
	    tmpx = ADJ3DPIX;
	    t.g_x -= tmpx;		/* expand object to accomodate */
	    t.g_y -= tmpx;		/*  hi-lights for 3D */
	    t.g_w += (tmpx << 1);
	    t.g_h += (tmpx << 1);
	  }
	} 
        else	/* redraw cursor */
	{
	  gsx_attr(FALSE, MD_XOR, BLACK);
	  t.g_y -= 3; 
	  t.g_h += 6; 
	}
						/* set the new clip rect */
	gsx_gclip(&oc);
	gsx_sclip(&t);

						/* redraw the field	*/
	if (dist) {
	  if ( prop ) {
		GRECT	s, sc;
		OBJECT	*o;
		WORD	ox, oy, d;

		o = &((OBJECT *)tree)[obj];
		ob_offset((LONG)tree, obj, &ox, &oy);

		d = 0;
		if (((edblk->te_just == GDOS_PROP) || (edblk->te_font == GDOS_BITM)) 
		&& (old_w > new_w)) {
			s.g_x = ox + new_w;
			s.g_w = old_w - new_w;
			s.g_y = oy;
			s.g_h = o->ob_height;
			d = 1;
		} else if (edblk->te_just != TE_LEFT) {
			s.g_x = ox;
			s.g_y = oy;
			s.g_w = o->ob_width;
			s.g_h = o->ob_height;		      /* compute text area */
			gr_just(edblk->te_just, &DGLO->g_fmtstr[0], s.g_w, s.g_h, &s);
			ox = old_x;
			old_x = s.g_x;
			if (old_w > new_w) {
				s.g_w = old_w;
				s.g_x = ox;
			} 
			d = 2;
		}
		if (d > 0) {
			gsx_gclip(&sc);
			gsx_sclip(&s);

			bb_fill(MD_REPLACE, FIS_SOLID, IP_SOLID, 
		  		s.g_x, s.g_y, s.g_w, s.g_h);	/* clear */
		}
		if (d == 1)
			gsx_sclip(&sc);
	  }

	  ob_draw((LONG)tree, obj, 0);
				/* since ob_draw reset the font back to */
				/* IBM, we have to set it again!!!	*/
	  set_cufont(edblk->te_font, edblk->te_fontid, edblk->te_fontsize);
	} else
	  gsx_cline(t.g_x, t.g_y, t.g_x, t.g_y+t.g_h-1);
						/* turn on cursor in	*/
						/*   new position	*/
       gsx_sclip(&oc);
}


/*
*	Routine to check to see if given character is in the desired 
*	range.  The character ranges are
*	stored as enumerated characters (xyz) or ranges (x..z)
*/
	WORD
instr(chr, str)
	REG BYTE		chr;
	REG BYTE		*str;
{
	REG BYTE		test1, test2;

	while(*str)
	{
	  test1 = test2 = *str++;
	  if ( (*str == '.') &&
	       (*(str+1) == '.') )
	  {
	    str += 2;
	    test2 = *str++;
	  }
	  if ( (chr >= test1) &&
	       (chr <= test2) )
	    return(TRUE);
	}
	return(FALSE);
}


/*
*	Routine to verify that the character matches the validation
*	string.  If necessary, upshift it.
*/
	WORD
check(in_char, valchar)
	REG BYTE		*in_char;
	BYTE		valchar;
{
	REG WORD		upcase;
	REG WORD		rstr;

	upcase = TRUE;
	rstr = -1;
	switch(valchar)
	{
	  case '9':				/* 0..9			*/
	    rstr = ST9VAL;
	    upcase = FALSE;
	    break;
	  case 'A':				/* A..Z, <space>	*/
	    rstr = STAVAL;
	    break;
	  case 'N':				/* 0..9, A..Z, <SPACE>	*/
	    rstr = STNVAL;
	    break;
	  case 'P':		/* DOS pathname + '\', '?', '*', ':','.'*/
	    rstr = STPVAL;
	    break;
	  case 'p':			/* DOS pathname + '\` + ':'	*/
	    rstr = STLPVAL;
	    break;
	  case 'F':		/* DOS filename + ':', '?' + '*'	*/
	    rstr = STFVAL;
	    break;
	  case 'f':				/* DOS filename */
	    rstr = STLFVAL;
	    break;
	  case 'a':				/* a..z, A..Z, <SPACE>	*/
	    rstr = STLAVAL;
	    upcase = FALSE;
	    break;
	  case 'n':				/* 0..9, a..z, A..Z,<SP>*/
	    rstr = STLNVAL;
	    upcase = FALSE;
	    break;
	  case 'x':				/* anything, but upcase	*/
	    *in_char = toupper(*in_char);
	    return(TRUE);
	  case 'X':				/* anything		*/
	    return(TRUE);
	}
	if (rstr != -1)
	{
	  if ( instr(*in_char, rs_str(rstr)) )
	  {
	     if (upcase)
	       *in_char = toupper(*in_char);
	     return(TRUE);
	  }
	}

	return(FALSE);
}


/*
*	Find STart and FiNish of a raw string relative to the template
*	string.  The start is determined by the InDeX position given.
*/
	VOID
ob_stfn(idx, pstart, pfinish)
	WORD		idx;
	WORD		*pstart, *pfinish;
{
	REG THEGLO	*DGLO;

	DGLO = &D;
	*pstart = find_pos(&DGLO->g_tmpstr[0], idx);
	*pfinish = find_pos(&DGLO->g_tmpstr[0], strlen(&DGLO->g_rawstr[0]) );
}


	WORD
ob_delit(idx)
	WORD		idx;
{
	REG THEGLO	*DGLO;

	DGLO = &D;
	if (DGLO->g_rawstr[idx])
	{
	  strcpy(&DGLO->g_rawstr[idx+1], &DGLO->g_rawstr[idx]);
	  return(FALSE);
	}
	return(TRUE);
}


	WORD
ob_edit(tree, obj, in_char, idx, kind)
	REG LONG	tree;
	REG WORD	obj;
	WORD		in_char;
	REG WORD	*idx;	/* rel. to raw data	*/
	WORD		kind;
{
	REG LONG	spec;
	REG WORD	tmp_back, cur_pos;
	WORD		pos,len,flags,dist;
/*	GRECT		t, c, oc;	*/
	WORD		ii, no_redraw, start;
	WORD		finish, nstart, nfinish;
	BYTE		bin_char;
	REG THEGLO	*DGLO;
	TEDINFO		edblk;	
	GRECT		s;

	DGLO = &D;

	if ( (kind == EDSTART) || (obj <= 0) ) 
	  return(TRUE);

						/* copy TEDINFO struct	*/
						/*   to local struct	*/
/*	ob_getsp(tree, obj, &edblk);	*/

	flags = LWGET( OB_FLAGS( obj ) );
	spec = LLGET( OB_SPEC( obj ) );
	if ( flags & INDIRECT )
	  spec = LLGET( spec );
	
	LBCOPY( ( BYTE *)&edblk, ( BYTE *)spec, sizeof(TEDINFO));

						/* copy passed in strs	*/
						/*   to local strs	*/
 	LSTCPY(&DGLO->g_tmpstr[0], ( BYTE *)edblk.te_ptmplt);
 	LSTCPY(&DGLO->g_rawstr[0], ( BYTE *)edblk.te_ptext);
 	len = ii = LSTCPY(&DGLO->g_valstr[0], ( BYTE *)edblk.te_pvalid);
						/* expand out valid str	*/
	while ( (ii > 0) &&
		(len < edblk.te_tmplen) )
	  DGLO->g_valstr[len++] = DGLO->g_valstr[ii-1];
	DGLO->g_valstr[len] = NULL;

	set_cufont(edblk.te_font, edblk.te_fontid, edblk.te_fontsize);
						/* init formatted	*/
						/*   string		*/
	ob_format(edblk.te_just, &DGLO->g_rawstr[0], &DGLO->g_tmpstr[0], 
			&DGLO->g_fmtstr[0]);

	switch(kind)
	{
	  case EDINIT:
		*idx = strlen(&DGLO->g_rawstr[0]);

		if ((edblk.te_font == GDOS_PROP) || (edblk.te_font == GDOS_BITM)) {
			ob_offset(tree, obj, &s.g_x, &s.g_y);	
			s.g_w = ((OBJECT*)tree)[obj].ob_width;
			s.g_h = ((OBJECT*)tree)[obj].ob_height;
			/* get text area */
			gr_just(edblk.te_just, &DGLO->g_fmtstr[0], s.g_w, s.g_h, &s);
			new_w = s.g_w;
			old_x = s.g_x;
		}
		break;

	  case EDCHAR:
		/* at this point, DGLO->g_fmtstr has already been formatted--*/
		/*   it has both template & data. now update DGLO->g_fmtstr  */
		/*   with in_char; return it; strip out junk & update	*/
		/*   ptext string.					*/
		no_redraw = TRUE;
						/* find cursor & turn	*/
						/*   it off		*/
		ob_stfn(*idx, &start, &finish);
						/* turn cursor off	*/
		cur_pos = start;
		curfld((OBJECT *)tree, obj, cur_pos, 0, &edblk);

		switch(in_char)
		{
		  case BACKSPACE:
			if (*idx > 0)
			{
			  *idx -= 1;
			  no_redraw = ob_delit(*idx);
			}
			break;
		  case ESCAPE:
			*idx = 0;
			DGLO->g_rawstr[0] = NULL;
			no_redraw = FALSE;
			break;
		  case DELETE:
			if (*idx <= (edblk.te_txtlen - 2))
		 	  no_redraw = ob_delit(*idx);
			break;
		  case LEFTKEY:
			if (*idx > 0)
		  	  *idx -= 1;
			break;
		  case RIGHTKEY:
			if ( *idx < strlen(&DGLO->g_rawstr[0]) )
			  *idx += 1;
			break;
		  default:
			tmp_back = FALSE;
			if (*idx > (edblk.te_txtlen - 2))
			{
			  cur_pos--;
			  start = cur_pos;
			  tmp_back = TRUE;
			  *idx -= 1;
			}
			bin_char = in_char & 0x00ff;
			
		    if( bin_char)
		    {				/* make sure char is	*/
						/*   in specified set	*/
			if ( check(&bin_char, DGLO->g_valstr[*idx]) )
			{
			  ins_char(&DGLO->g_rawstr[0], *idx, bin_char, 
					edblk.te_txtlen);
			  *idx += 1;
			  no_redraw = FALSE;
			}
		  	else
			{		/* see if we can skip ahead	*/
			  if (tmp_back)
			  {
		  	    *idx += 1;
			    cur_pos++;
			  }
		 	  pos = scan_to_end(&DGLO->g_tmpstr[0]+cur_pos, *idx,
								 bin_char);

		 	  if (pos < (edblk.te_txtlen - 2) )
			  {
			    bfill(pos - *idx, BYTESPACE, &DGLO->g_rawstr[*idx]);




			    DGLO->g_rawstr[pos] = NULL;
			    *idx = pos;
		 	    no_redraw = FALSE;
			  }
			}
		     }
		     break;
		}

		LSTCPY( ( BYTE *)edblk.te_ptext, &DGLO->g_rawstr[0]);

		if (!no_redraw)
		{
		  ob_format(edblk.te_just, &DGLO->g_rawstr[0], &DGLO->g_tmpstr[0], &DGLO->g_fmtstr[0]);
		  ob_stfn(*idx, &nstart, &nfinish);
		  start = min(start, nstart);
		  dist = max(finish, nfinish) - start;

		  if (dist) {
			if ((edblk.te_font == GDOS_PROP) || (edblk.te_font == GDOS_BITM)) {
			    old_w = new_w;
			    new_w = propStrWidth(&DGLO->g_fmtstr[0]); /* get text width */
			}
		    curfld((OBJECT *)tree, obj, start, dist, &edblk);
		  }
		} /* switch */
	        break;
	  case EDEND:
		break;
	} /* switch */
						/* draw/erase the cursor*/
	cur_pos = find_pos(&DGLO->g_tmpstr[0], *idx);
	curfld((OBJECT *)tree, obj, cur_pos, 0, &edblk);

	set_cufont(IBM, 0, 0);			/* just to make sure ... */
	return(TRUE);
}


	WORD
propStrWidth(s)		/* +++ HMK 6/14/93 compute width of proportinal text */
	REG BYTE	*s;
{
	REG WORD pptw;
	WORD	 wc, dummy;

	for (pptw = 0 ; *s; s++) {
		vqt_width(*s, &wc, &dummy, &dummy);
		pptw += wc;
	}
	return pptw;
}
