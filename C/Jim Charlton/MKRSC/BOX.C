#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"


do_boxt(result)	/* for G_BOX and G_IBOX only	*/
	int result;
{
	OBJECT	*objptr;
	int i, button, nstate, nflag;
	char *strptr;
	COLORINT cint;
    int cx, cy, cw, ch;  /* dialog box dimensions  */
	long lcint, lob_spec, lthick;
	int thick, sthick;

	objptr = thefrontwin->inwindow->objt;
	boxt[YEXAMPLE].ob_spec = objptr[result].ob_spec;

/* deselect selectable objects in the boxt dialog box	*/

	for(i=0;i<15;i++)
		boxt[i].ob_state &= ~SELECTED;

	cint.whole = (int)(((long)objptr[result].ob_spec) & 0xFFFFL);
	thick = (int)((((long)objptr[result].ob_spec)  >> 16) & 0x00FF);
/*	if a negative one byte number then sign extend	*/
	if(thick & 0x80)
		thick |= 0xFF00;

	strptr = boxt[YBDCOLOR].ob_spec;
	sprintf(strptr,"%02d",(int)cint.part.bdcolor);
	strptr = boxt[YFILL].ob_spec;
	sprintf(strptr,"%02d",(int)cint.part.fillmode);
	strptr = boxt[YBGCOLOR].ob_spec;
	sprintf(strptr,"%02d",(int)cint.part.bgcolor);
	strptr = boxt[YLINE].ob_spec;
	sprintf(strptr,"%4d",thick);

	i = objptr[result].ob_state;
	if(i & 2)
		boxt[YCROSS].ob_state ^= SELECTED;
	if(i & 4)
		boxt[YCHECKED].ob_state ^= SELECTED;
	if(i & 8)
		boxt[YDISABLE].ob_state ^= SELECTED;
	if(i & 16)
		boxt[YOUTLINE].ob_state ^= SELECTED;
	if(i & 32)
		boxt[YSHADOW].ob_state ^= SELECTED;
	
	i = objptr[result].ob_flags;
	if(i & 1)
		boxt[YSELECT].ob_state ^= SELECTED;
	if(i & 2)
		boxt[YDEFAULT].ob_state ^= SELECTED;
	if(i & 4)
		boxt[YEXIT].ob_state ^= SELECTED;
	if(i & 8)
		boxt[YEDITABL].ob_state ^= SELECTED;
	if(i & 16)
		boxt[YRADBUT].ob_state ^= SELECTED;
	if(i & 0x40)
		boxt[YTOUCHEX].ob_state ^= SELECTED;

	if(objptr[result].ob_type == G_IBOX)
	{	boxt[YBGUP].ob_state = DISABLED;
		boxt[YBGDWN].ob_state = DISABLED;
		boxt[YFUP].ob_state = DISABLED;
		boxt[YFDWN].ob_state = DISABLED;
	}
	else
	{	boxt[YBGUP].ob_state = NORMAL;
		boxt[YBGDWN].ob_state = NORMAL;
		boxt[YFUP].ob_state = NORMAL;
		boxt[YFDWN].ob_state = NORMAL;
	}
/* now draw the dialog box and process the selected objects	*/
		
	form_center(boxt, &cx, &cy, &cw, &ch);
	form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
	objc_draw(boxt, 0, 10, cx, cy, cw, ch);
	button = 0;
	while( (button != YOK) && (button != YCANCEL) ) 
	{	button = form_do(boxt, 0);
		switch (button)
		{
		case YBDUP	:
			strptr = boxt[YBDCOLOR].ob_spec;
			if(cint.part.bdcolor <15)
				cint.part.bdcolor++;
			sprintf(strptr,"%02d",(int)cint.part.bdcolor);
			boxt[YBDUP].ob_state &= ~SELECTED;
			objc_draw(boxt,YBDBOX,2,cx,cy,cw,ch);
			break;
		case YBDDWN	:
			strptr = boxt[YBDCOLOR].ob_spec;
			if(cint.part.bdcolor >0)
				cint.part.bdcolor--;
			sprintf(strptr,"%02d",(int)cint.part.bdcolor);
			boxt[YBDDWN].ob_state &= ~SELECTED;
			objc_draw(boxt,YBDBOX,2,cx,cy,cw,ch);
			break;
		case YFDWN	:
			strptr = boxt[YFILL].ob_spec;
			if(cint.part.fillmode >0)
				cint.part.fillmode--;
			sprintf(strptr,"%02d",(int)cint.part.fillmode);
			boxt[YFDWN].ob_state &= ~SELECTED;
			objc_draw(boxt,YFBOX,2,cx,cy,cw,ch);
			break;
		case YFUP	:
			strptr = boxt[YFILL].ob_spec;
			if(cint.part.fillmode < 7)
				cint.part.fillmode++;
			sprintf(strptr,"%02d",(int)cint.part.fillmode);
			boxt[YFUP].ob_state &= ~SELECTED;
			objc_draw(boxt,YFBOX,2,cx,cy,cw,ch);
			break;
		case YBGDWN	:
			strptr = boxt[YBGCOLOR].ob_spec;
			if(cint.part.bgcolor >0)
				cint.part.bgcolor--;
			sprintf(strptr,"%02d",(int)cint.part.bgcolor);
			boxt[YBGDWN].ob_state &= ~SELECTED;
			objc_draw(boxt,YBGBOX,2,cx,cy,cw,ch);
			break;
		case YBGUP	:
			strptr = boxt[YBGCOLOR].ob_spec;
			if(cint.part.bgcolor < 15)
				cint.part.bgcolor++;
			sprintf(strptr,"%02d",(int)cint.part.bgcolor);
			boxt[YBGUP].ob_state &= ~SELECTED;
			objc_draw(boxt,YBGBOX,2,cx,cy,cw,ch);
			break;
		case YLUP	:
			strptr = boxt[YLINE].ob_spec;
			if(thick < 25)
				thick += 1;
			sprintf(strptr,"%4d",thick);
			boxt[YLUP].ob_state &= ~SELECTED;
			objc_draw(boxt,YLBOX,2,cx,cy,cw,ch);
			break;
		case YLDWN	:
			strptr = boxt[YLINE].ob_spec;
			if(thick > -25)
				thick -= 1;
			sprintf(strptr,"%4d",thick);
			boxt[YLDWN].ob_state &= ~SELECTED;
			objc_draw(boxt,YLBOX,2,cx,cy,cw,ch);
			break;
		}
	strptr = boxt[YBDCOLOR].ob_spec;
	cint.part.bdcolor = atoi(strptr);


	strptr = boxt[YLINE].ob_spec;
	sscanf(strptr,"%d",&thick);
	sthick = thick & 0x00FF;
	lthick = ((long)sthick) << 16;

	lcint = cint.whole;
	lcint &= 0x0000FFFFL;
	lob_spec = 0L;
	lob_spec |= lthick;
	lob_spec |= lcint;

	nstate = (boxt[YCROSS].ob_state & 1)*2
				+ (boxt[YCHECKED].ob_state & 1)*4
				+ (boxt[YDISABLE].ob_state & 1)*8
				+ (boxt[YOUTLINE].ob_state & 1)*16
				+ (boxt[YSHADOW].ob_state & 1)*32;

	nflag =	(boxt[YSELECT].ob_state & 1)
				+ (boxt[YDEFAULT].ob_state & 1)*2
				+ (boxt[YEXIT].ob_state & 1)*4
				+ (boxt[YEDITABL].ob_state & 1)*8
				+ (boxt[YRADBUT].ob_state & 1)*16
				+ (boxt[YTOUCHEX].ob_state & 1)*0x40;

	boxt[YEXAMPLE].ob_spec = (char *)lob_spec;
	objc_draw(boxt,YEXBOX,2,cx,cy,cw,ch);

	}
		form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);

	if (button == YCANCEL)
		return;
	
	objptr[result].ob_spec = (char *)lob_spec;

	objptr[result].ob_state = nstate;

	objptr[result].ob_flags = nflag;
	

}


do_boxct(result)
	int result;
{
	OBJECT	*objptr;
	int i, button, nstate, nflag;
	char *strptr, *chptr;
	COLORINT cint;
    int cx, cy, cw, ch;  /* dialog box dimensions  */
	long lcint, lob_spec, lthick;
	TEDINFO *tiptr1;
	int thick, sthick;

	objptr = thefrontwin->inwindow->objt;
	boxct[XEXAMPLE].ob_spec = objptr[result].ob_spec;

/* chptr points a 2 char string. Point the boxct tedinfo string to it.	*/

	tiptr1 = (TEDINFO *)boxct[XBOXCHAR].ob_spec;

	chptr = " ";
	tiptr1->te_ptext = chptr;
	tiptr1->te_txtlen = 2;
	tiptr1->te_tmplen = 2;

/* copy the boxchar to the string	*/

	lob_spec = (long)objptr[result].ob_spec;
	chptr[0] = (char)(lob_spec >> 24);

/* deselect selectable objects in the boxct dialog box	*/

	for(i=0;i<15;i++)
		boxct[i].ob_state &= ~SELECTED;

	cint.whole = (int)(lob_spec & 0xFFFFL);
	thick = (int)((lob_spec  >> 16) & 0x00FF);
/*	if a negative one byte number then sign extend	*/
	if(thick & 0x80)
		thick |= 0xFF00;

	strptr = boxct[XLINE].ob_spec;
	sprintf(strptr,"%4d",thick);
	strptr = boxct[XBDCOLOR].ob_spec;
	sprintf(strptr,"%02d",(int)cint.part.bdcolor);
	strptr = boxct[XFILL].ob_spec;
	sprintf(strptr,"%02d",(int)cint.part.fillmode);
	strptr = boxct[XBGCOLOR].ob_spec;
	sprintf(strptr,"%02d",(int)cint.part.bgcolor);
	strptr = boxct[XTCOLOR].ob_spec;
	sprintf(strptr,"%02d",(int)cint.part.tcolor);
	if((int)cint.part.wrmode)
	{	boxct[XMR].ob_state |= SELECTED;
		boxct[XMT].ob_state &= ~SELECTED;
	}
	else
	{	boxct[XMT].ob_state |= SELECTED;
		boxct[XMR].ob_state &= ~SELECTED;
	}

	i = objptr[result].ob_state;
	if(i & 2)
		boxct[XCROSS].ob_state ^= SELECTED;
	if(i & 4)
		boxct[XCHECKED].ob_state ^= SELECTED;
	if(i & 8)
		boxct[XDISABLE].ob_state ^= SELECTED;
	if(i & 16)
		boxct[XOUTLINE].ob_state ^= SELECTED;
	if(i & 32)
		boxct[XSHADOW].ob_state ^= SELECTED;
	
	i = objptr[result].ob_flags;
	if(i & 1)
		boxct[XSELECT].ob_state ^= SELECTED;
	if(i & 2)
		boxct[XDEFAULT].ob_state ^= SELECTED;
	if(i & 4)
		boxct[XEXIT].ob_state ^= SELECTED;
	if(i & 8)
		boxct[XEDITABL].ob_state ^= SELECTED;
	if(i & 16)
		boxct[XRADBUT].ob_state ^= SELECTED;
	if(i & 0x40)
		boxct[XTOUCHEX].ob_state ^= SELECTED;

/* now draw the dialog box and process the selected objects	*/
		
	form_center(boxct, &cx, &cy, &cw, &ch);
	form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
	objc_draw(boxct, 0, 10, cx, cy, cw, ch);
	button = 0;
	while( (button != XOK) && (button != XCANCEL) ) 
	{	button = form_do(boxct, 0);
		switch (button)
		{
		case XBDUP	:
			strptr = boxct[XBDCOLOR].ob_spec;
			if(cint.part.bdcolor <15)
				cint.part.bdcolor++;
			sprintf(strptr,"%02d",(int)cint.part.bdcolor);
			boxct[XBDUP].ob_state &= ~SELECTED;
			objc_draw(boxct,XBDBOX,2,cx,cy,cw,ch);
			break;
		case XBDDWN	:
			strptr = boxct[XBDCOLOR].ob_spec;
			if(cint.part.bdcolor >0)
				cint.part.bdcolor--;
			sprintf(strptr,"%02d",(int)cint.part.bdcolor);
			boxct[XBDDWN].ob_state &= ~SELECTED;
			objc_draw(boxct,XBDBOX,2,cx,cy,cw,ch);
			break;
		case XFDWN	:
			strptr = boxct[XFILL].ob_spec;
			if(cint.part.fillmode >0)
				cint.part.fillmode--;
			sprintf(strptr,"%02d",(int)cint.part.fillmode);
			boxct[XFDWN].ob_state &= ~SELECTED;
			objc_draw(boxct,XFBOX,2,cx,cy,cw,ch);
			break;
		case XFUP	:
			strptr = boxct[XFILL].ob_spec;
			if(cint.part.fillmode < 7)
				cint.part.fillmode++;
			sprintf(strptr,"%02d",(int)cint.part.fillmode);
			boxct[XFUP].ob_state &= ~SELECTED;
			objc_draw(boxct,XFBOX,2,cx,cy,cw,ch);
			break;
		case XBGDWN	:
			strptr = boxct[XBGCOLOR].ob_spec;
			if(cint.part.bgcolor >0)
				cint.part.bgcolor--;
			sprintf(strptr,"%02d",(int)cint.part.bgcolor);
			boxct[XBGDWN].ob_state &= ~SELECTED;
			objc_draw(boxct,XBGBOX,2,cx,cy,cw,ch);
			break;
		case XBGUP	:
			strptr = boxct[XBGCOLOR].ob_spec;
			if(cint.part.bgcolor < 15)
				cint.part.bgcolor++;
			sprintf(strptr,"%02d",(int)cint.part.bgcolor);
			boxct[XBGUP].ob_state &= ~SELECTED;
			objc_draw(boxct,XBGBOX,2,cx,cy,cw,ch);
			break;
		case XTDWN	:
			strptr = boxct[XTCOLOR].ob_spec;
			if(cint.part.tcolor >0)
				cint.part.tcolor--;
			sprintf(strptr,"%02d",(int)cint.part.tcolor);
			boxct[XTDWN].ob_state &= ~SELECTED;
			objc_draw(boxct,XTBOX,2,cx,cy,cw,ch);
			break;
		case XTUP	:
			strptr = boxct[XTCOLOR].ob_spec;
			if(cint.part.tcolor < 15)
				cint.part.tcolor++;
			sprintf(strptr,"%02d",(int)cint.part.tcolor);
			boxct[XTUP].ob_state &= ~SELECTED;
			objc_draw(boxct,XTBOX,2,cx,cy,cw,ch);
			break;
		case XLUP	:
			strptr = boxct[XLINE].ob_spec;
			if(thick < 25)
				thick += 1;
			sprintf(strptr,"%4d",thick);
			boxct[YLUP].ob_state &= ~SELECTED;
			objc_draw(boxct,XLBOX,2,cx,cy,cw,ch);
			break;
		case XLDWN	:
			strptr = boxct[XLINE].ob_spec;
			if(thick > -25)
				thick -= 1;
			sprintf(strptr,"%4d",thick);
			boxct[XLDWN].ob_state &= ~SELECTED;
			objc_draw(boxct,XLBOX,2,cx,cy,cw,ch);
			break;
		}

	strptr = boxct[XBDCOLOR].ob_spec;
	cint.part.bdcolor = atoi(strptr);

	strptr = boxct[XFILL].ob_spec;
	cint.part.fillmode = atoi(strptr);
	strptr = boxct[XBGCOLOR].ob_spec;
	cint.part.bgcolor = atoi(strptr);
	strptr = boxct[XTCOLOR].ob_spec;
	cint.part.tcolor = atoi(strptr);

	if(boxct[XMR].ob_state & SELECTED)
		cint.part.wrmode = 1;
	else
		cint.part.wrmode = 0;

	strptr = boxct[XLINE].ob_spec;
	sscanf(strptr,"%d",&thick);
	sthick = thick & 0x00FF;
	lthick = ((long)sthick) << 16;

	lcint = cint.whole;
	lcint &= 0x0000FFFFL;
	lob_spec = chptr[0];
	lob_spec = lob_spec << 24;
	lob_spec |= lthick;
	lob_spec |= lcint;

	nstate = (boxct[XCROSS].ob_state & 1)*2
				+ (boxct[XCHECKED].ob_state & 1)*4
				+ (boxct[XDISABLE].ob_state & 1)*8
				+ (boxct[XOUTLINE].ob_state & 1)*16
				+ (boxct[XSHADOW].ob_state & 1)*32;

	nflag =	(boxct[XSELECT].ob_state & 1)
				+ (boxct[XDEFAULT].ob_state & 1)*2
				+ (boxct[XEXIT].ob_state & 1)*4
				+ (boxct[XEDITABL].ob_state & 1)*8
				+ (boxct[XRADBUT].ob_state & 1)*16
				+ (boxct[XTOUCHEX].ob_state & 1)*0x40;

	boxct[XEXAMPLE].ob_spec = (char *)lob_spec;
	objc_draw(boxct,XEXBOX,2,cx,cy,cw,ch);
	}
		form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);

	if (button == XCANCEL)
		return;

	objptr[result].ob_spec = (char *)lob_spec;

	objptr[result].ob_state = nstate;

	objptr[result].ob_flags = nflag;
	
}
