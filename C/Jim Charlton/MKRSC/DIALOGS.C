#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"

do_buttont(result)
	int result;
{
	int nstate, nflag, button, i;
	OBJECT	*objptr;
	TEDINFO	*tiptr1;
	TEDINFO *tiptr2;
	char *chptr, savestr[80];

	objptr = thefrontwin->inwindow->objt;
	tiptr1 = (TEDINFO *)(buttont[BEDITSTR].ob_spec);

/* chptr points to the string in the button/string/title object	*/

	chptr  = (char *)(objptr[result].ob_spec);
	strcpy(savestr,chptr);	
	tiptr1->te_ptext = chptr;
	tiptr1->te_txtlen = 36;
	
/* deselect all buttons in buttont	*/	
	
	for(i=0;i<16;i++)
		buttont[i].ob_state &= ~SELECTED;
		
/* set appropriate selection of objects in buttont for current object	*/

	i = objptr[result].ob_state;
	if(i & 2)
		buttont[BCROSSED].ob_state ^= SELECTED;
	if(i & 4)
		buttont[BCHECKED].ob_state ^= SELECTED;
	if(i & 8)
		buttont[BDISABLE].ob_state ^= SELECTED;
	if(i & 16)
		buttont[BOUTLINE].ob_state ^= SELECTED;
	if(i & 32)
		buttont[BSHADOW].ob_state ^= SELECTED;

	i = objptr[result].ob_flags;
	if(i & 1)
		buttont[BSELECT].ob_state ^= SELECTED;
	if(i & 2)
		buttont[BDEFAULT].ob_state ^= SELECTED;
	if(i & 4)
		buttont[BEXIT].ob_state ^= SELECTED;
	if(i & 8)
		buttont[BEDITABL].ob_state ^= SELECTED;
	if(i & 16)
		buttont[BRADBUT].ob_state ^= SELECTED;
	if(i & 0x40)
		buttont[BTOUCHEX].ob_state ^= SELECTED;
		
	button = do_dialog(buttont,0);
	if (button == BCANCEL)
	{	strcpy(chptr,savestr);
		return;
	}
	
	nstate = (buttont[BCROSSED].ob_state & 1)*2
				+ (buttont[BCHECKED].ob_state & 1)*4
				+ (buttont[BDISABLE].ob_state & 1)*8
				+ (buttont[BOUTLINE].ob_state & 1)*16
				+ (buttont[BSHADOW].ob_state & 1)*32;

	objptr[result].ob_state = nstate;

	nflag =	(buttont[BSELECT].ob_state & 1)
				+ (buttont[BDEFAULT].ob_state & 1)*2
				+ (buttont[BEXIT].ob_state & 1)*4
				+ (buttont[BEDITABL].ob_state & 1)*8
				+ (buttont[BRADBUT].ob_state & 1)*16
				+ (buttont[ BTOUCHEX].ob_state & 1)*0x40;

	objptr[result].ob_flags = nflag;

	if(objptr[result].ob_width < (gl_wchar * strlen(chptr)))
		objptr[result].ob_width = (gl_wchar * strlen(chptr));
	
}

do_tist(result)
	int result;
{	
	TEDINFO *tiptr1, *tiptr2;
	TEDINFO *txtptr, *tmpptr, *valptr;
	OBJECT	*objptr;
	char svetxt[80], svetmp[80], sveval[80];
	int i, button, nstate, nflag;
	char *strptr;
	COLORINT cint;
    int cx, cy, cw, ch;  /* dialog box dimensions  */
	int thick, minw;

/* define some pointers	*/

	txtptr = (TEDINFO *)(tist[TTEXT].ob_spec);
	tmpptr = (TEDINFO *)(tist[TTMPLT].ob_spec);
	valptr = (TEDINFO *)(tist[TVALID].ob_spec);
	
	objptr = thefrontwin->inwindow->objt;
	tiptr2 = (TEDINFO *)(objptr[result].ob_spec);
	tiptr1 = (TEDINFO *)(tist[TIEXAMPL].ob_spec);
	tiptr1->te_color = tiptr2->te_color;
	tiptr1->te_thickness = tiptr2->te_thickness;
	thick = tiptr2->te_thickness;
	if(thick & 0x80)
		thick |= 0xFF00;
	strptr = tist[TILINE].ob_spec;
	sprintf(strptr,"%4d",thick);


/* save the original strings in case of a CANCEL	*/

	strcpy(svetxt,tiptr2->te_ptext);
	strcpy(svetmp,tiptr2->te_ptmplt);
	strcpy(sveval,tiptr2->te_pvalid);
	
/*	point the dialog box text pointers to the strings to edit	*/

	txtptr->te_ptext = tiptr2->te_ptext;
	tmpptr->te_ptext = tiptr2->te_ptmplt;
	valptr->te_ptext = tiptr2->te_pvalid;

	txtptr->te_txtlen = 40;
	tmpptr->te_txtlen = 40;
	valptr->te_tmplen = 40;
	txtptr->te_tmplen = 40;
	tmpptr->te_tmplen = 40;
	valptr->te_txtlen = 40;

	
/* deselect selectable objects in the tist dialog box	*/

	for(i=0;i<15;i++)
		tist[i].ob_state &= ~SELECTED;

/* set the state of other selectable objects in tist appropriately	*/

	cint.whole = tiptr2->te_color;

	strptr = tist[TIBDCOLO].ob_spec;
	sprintf(strptr,"%02d",(int)cint.part.bdcolor);
	strptr = tist[TITCOLOR].ob_spec;
	sprintf(strptr,"%02d",(int)cint.part.tcolor);
	if((int)cint.part.wrmode)
	{	tist[TIMR].ob_state |= SELECTED;
		tist[TIMT].ob_state &= ~SELECTED;
	}
	else
	{	tist[TIMT].ob_state |= SELECTED;
		tist[TIMR].ob_state &= ~SELECTED;
	}
	strptr = tist[TIFILL].ob_spec;
	sprintf(strptr,"%02d",(int)cint.part.fillmode);
	strptr = tist[TIBGCOLO].ob_spec;
	sprintf(strptr,"%02d",(int)cint.part.bgcolor);

	if(tiptr2->te_font == 5)
	{	tist[TIFS].ob_state |= SELECTED;
		tist[TIFL].ob_state &= ~SELECTED;
	}
	else
	{	tist[TIFL].ob_state |= SELECTED;
		tist[TIFS].ob_state &= ~SELECTED;
	}
	switch (tiptr2->te_just)
	{	
		case 0 : 	tist[TIJL].ob_state |= SELECTED;
					tist[TIJC].ob_state &= ~SELECTED;
					tist[TIJR].ob_state &= ~SELECTED;
					break;
		case 1 : 	tist[TIJR].ob_state |= SELECTED;
					tist[TIJL].ob_state &= ~SELECTED;
					tist[TIJC].ob_state &= ~SELECTED;
					break;
		case 2 : 	tist[TIJC].ob_state |= SELECTED;
					tist[TIJR].ob_state &= ~SELECTED;
					tist[TIJL].ob_state &= ~SELECTED;
					break;
	}


	i = objptr[result].ob_state;
	if(i & 2)
		tist[TCROSS].ob_state ^= SELECTED;
	if(i & 4)
		tist[TCHECKED].ob_state ^= SELECTED;
	if(i & 8)
		tist[TDISABLE].ob_state ^= SELECTED;
	if(i & 16)
		tist[TOUTLINE].ob_state ^= SELECTED;
	if(i & 32)
		tist[TSHADOW].ob_state ^= SELECTED;
	
	i = objptr[result].ob_flags;
	if(i & 1)
		tist[TSELECT].ob_state ^= SELECTED;
	if(i & 2)
		tist[TDEFAULT].ob_state ^= SELECTED;
	if(i & 4)
		tist[TEXIT].ob_state ^= SELECTED;
	if(i & 8)
		tist[TEDITABL].ob_state ^= SELECTED;
	if(i & 16)
		tist[TRADBUT].ob_state ^= SELECTED;
	if(i & 0x40)
		tist[TTOUCHEX].ob_state ^= SELECTED;
		
/* now draw the dialog box and process the selected objects	*/
		
	form_center(tist, &cx, &cy, &cw, &ch);
	form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
	objc_draw(tist, 0, 10, cx, cy, cw, ch);
	button = 0;
	while( (button != TOK) && (button != TCANCEL) ) 
	{	button = form_do(tist, 0);
		switch (button)
		{
		case TIBDUP	:
			strptr = tist[TIBDCOLO].ob_spec;
			if(cint.part.bdcolor <15)
				cint.part.bdcolor++;
			sprintf(strptr,"%02d",(int)cint.part.bdcolor);
			tist[TIBDUP].ob_state &= ~SELECTED;
			objc_draw(tist,TIBDBOX,2,cx,cy,cw,ch);
			break;
		case TIBDDWN	:
			strptr = tist[TIBDCOLO].ob_spec;
			if(cint.part.bdcolor >0)
				cint.part.bdcolor--;
			sprintf(strptr,"%02d",(int)cint.part.bdcolor);
			tist[TIBDDWN].ob_state &= ~SELECTED;
			objc_draw(tist,TIBDBOX,2,cx,cy,cw,ch);
			break;
		case TIFDWN	:
			strptr = tist[TIFILL].ob_spec;
			if(cint.part.fillmode >0)
				cint.part.fillmode--;
			sprintf(strptr,"%02d",(int)cint.part.fillmode);
			tist[TIFDWN].ob_state &= ~SELECTED;
			objc_draw(tist,TIFBOX,2,cx,cy,cw,ch);
			break;
		case TIFUP	:
			strptr = tist[TIFILL].ob_spec;
			if(cint.part.fillmode < 7)
				cint.part.fillmode++;
			sprintf(strptr,"%02d",(int)cint.part.fillmode);
			tist[TIFUP].ob_state &= ~SELECTED;
			objc_draw(tist,TIFBOX,2,cx,cy,cw,ch);
			break;
		case TITDWN	:
			strptr = tist[TITCOLOR].ob_spec;
			if(cint.part.tcolor >0)
				cint.part.tcolor--;
			sprintf(strptr,"%02d",(int)cint.part.tcolor);
			tist[TITDWN].ob_state &= ~SELECTED;
			objc_draw(tist,TITBOX,2,cx,cy,cw,ch);
			break;
		case TITUP	:
			strptr = tist[TITCOLOR].ob_spec;
			if(cint.part.tcolor < 15)
				cint.part.tcolor++;
			sprintf(strptr,"%02d",(int)cint.part.tcolor);
			tist[TITUP].ob_state &= ~SELECTED;
			objc_draw(tist,TITBOX,2,cx,cy,cw,ch);
			break;
		case TIBGDWN	:
			strptr = tist[TIBGCOLO].ob_spec;
			if(cint.part.bgcolor >0)
				cint.part.bgcolor--;
			sprintf(strptr,"%02d",(int)cint.part.bgcolor);
			tist[TIBGDWN].ob_state &= ~SELECTED;
			objc_draw(tist,TIBGBOX,2,cx,cy,cw,ch);
			break;
		case TIBGUP	:
			strptr = tist[TIBGCOLO].ob_spec;
			if(cint.part.bgcolor < 15)
				cint.part.bgcolor++;
			sprintf(strptr,"%02d",(int)cint.part.bgcolor);
			tist[TIBGUP].ob_state &= ~SELECTED;
			objc_draw(tist,TIBGBOX,2,cx,cy,cw,ch);
			break;
		case TILUP	:
			strptr = tist[TILINE].ob_spec;
			if(thick < 25)
				thick += 1;
			sprintf(strptr,"%4d",thick);
			tist[TILUP].ob_state &= ~SELECTED;
			objc_draw(tist,TILBOX,2,cx,cy,cw,ch);
			break;
		case TILDWN	:
			strptr = tist[TILINE].ob_spec;
			if(thick > -25)
				thick -= 1;
			sprintf(strptr,"%4d",thick);
			tist[TILDWN].ob_state &= ~SELECTED;
			objc_draw(tist,TILBOX,2,cx,cy,cw,ch);
			break;
		}

	strptr = tist[TILINE].ob_spec;
	sscanf(strptr,"%d",&thick);

	strptr = tist[TIBDCOLO].ob_spec;
	cint.part.bdcolor = atoi(strptr);
	strptr = tist[TITCOLOR].ob_spec;
	cint.part.tcolor = atoi(strptr);

	if(tist[TIMR].ob_state & SELECTED)
		cint.part.wrmode = 1;
	else
		cint.part.wrmode = 0;

	strptr = tist[TIFILL].ob_spec;
	cint.part.fillmode = atoi(strptr);
	strptr = tist[TIBGCOLO].ob_spec;
	cint.part.bgcolor = atoi(strptr);

	tiptr1->te_color = cint.whole;
	tiptr1->te_thickness = thick & 0xFF;

	if(tist[TIFS].ob_state & SELECTED)
		tiptr1->te_font = 5;
	else
		tiptr1->te_font = 3;

	if(tist[TIJL].ob_state & SELECTED)
		tiptr1->te_just = 0;
	else if(tist[TIJC].ob_state & SELECTED)
		tiptr1->te_just = 2;
	else
		tiptr1->te_just = 1;

	nstate = (tist[TCROSS].ob_state & 1)*2
				+ (tist[TCHECKED].ob_state & 1)*4
				+ (tist[TDISABLE].ob_state & 1)*8
				+ (tist[TOUTLINE].ob_state & 1)*16
				+ (tist[TSHADOW].ob_state & 1)*32;

	nflag =	(tist[TSELECT].ob_state & 1)
				+ (tist[TDEFAULT].ob_state & 1)*2
				+ (tist[TEXIT].ob_state & 1)*4
				+ (tist[TEDITABL].ob_state & 1)*8
				+ (tist[TRADBUT].ob_state & 1)*16
				+ (tist[TTOUCHEX].ob_state & 1)*0x40;

	objc_draw(tist,TIEXBOX,2,cx,cy,cw,ch);
	}
		form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);

	if (button == TCANCEL)
	{	strcpy(tiptr2->te_ptext,svetxt);
		strcpy(tiptr2->te_ptmplt,svetmp);
		strcpy(tiptr2->te_pvalid,sveval);
		return;
	}
	
	objptr[result].ob_state = nstate;
	objptr[result].ob_flags = nflag;
	tiptr2->te_just = tiptr1->te_just;
	tiptr2->te_font = tiptr1->te_font;
	tiptr2->te_color = cint.whole;
	tiptr2->te_thickness = thick & 0xFF;


	minw = max(gl_wchar * strlen(tiptr2->te_ptmplt),gl_wchar);
	minw = max(gl_wchar * strlen(tiptr2->te_ptext),minw);
	if(objptr[result].ob_width < minw)
		objptr[result].ob_width = minw;

	tiptr2->te_tmplen = strlen(tiptr2->te_ptmplt);
	tiptr2->te_txtlen = strlen(tiptr2->te_pvalid);

}

