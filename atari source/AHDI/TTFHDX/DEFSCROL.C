/*  DEFSCROL.C							*/
/*	3/1/88		Derek Mui				*/
/*	3/2/88		Edited by ml. for use in factory HDX	*/


#include <obdefs.h>
#include <osbind.h>
#include <gemdefs.h>
#include "fhdx.h"
#include "define.h"
#include "addr.h"
#include "deflst.h"
#include "scroll.h"

int	topptr;		/* top pointer	*/
int	totcnt;		/* total number of items */
PADDR	*xampaddr;	/* defect list to be examined */

extern int xdesk, ydesk, wdesk, hdesk;	/* dimensions of desktop */
extern int npndefs;
extern PADDR *nppaddr;

/*
 * Indices to entries in the window.
 */
int defent[] = {
    ENTRY0, ENTRY1, ENTRY2, ENTRY3,
    ENTRY4, ENTRY5, ENTRY6, ENTRY7
};


xamdeflst()
{
    long mul;
    int	 botptr, bret, value;
    int  xoff, yoff, mx, my;
    int  i, ret, cont;
    int  np, xam;
    int  k1, k2;

    /* Allocate memory to hold defects */
    if ((xampaddr = mymalloc(npndefs*(sizeof(PADDR)))) <= 0) {
        return err(nomemory);
    }
    
    for (np = 0; np < npndefs; np++) {
    	xampaddr[np].exist = nppaddr[np].exist;
    	xampaddr[np].head = nppaddr[np].head;
    	xampaddr[np].cylndr = nppaddr[np].cylndr;
    	xampaddr[np].btoffst = nppaddr[np].btoffst;
    }
    
    r_items();		/* read items */
    
    totcnt = npndefs;
    if (npndefs > NM_ITEMS)		/* bigger than one window */
	botptr = npndefs - NM_ITEMS;
    else
	botptr = 0;

    cont = TRUE;			/* control flag	*/
    while(cont) {
	bret = form_do(xamform, -1);
	graf_mkstate(&mx, &my, &k1, &k2);	/* graf mkstate	*/
	ret = bret & 0x7FFF;			/* mask off double click */
	LWSET(OB_STATE(xamform, ret), 0);
	value = 1;			/* scroll factor */

	switch (ret) {		/* Big Switch */
	    case FSVSLID:		
		objc_offset(xamform, FSVELEV, &xoff, &yoff);
		value = NM_ITEMS;		/* one full window size	*/
		if (my <= yoff)
		    goto up;		
		goto down;

	    case FSVELEV:
		value = graf_slidebox(xamform, FSVSLID, FSVELEV, TRUE);
		mul = (npndefs - NM_ITEMS) * value;
		mul /= 1000;
		value = (int)mul; 
		value = (topptr - value);
		if (value >= 0)
		    goto up;			/* go up */
		else
		    value = -value;		/* go down */

down:	    case FDNAROW:			/* scroll down */
		if (topptr == botptr)
		    break;

		if ((topptr + value) <= botptr)
		    topptr += value;
		else
		    topptr = botptr;

		goto sfiles;			

up:	    case FUPAROW:			/* scroll up */
		if (!topptr)
		    break;

		if ((topptr - value) >= 0)
		    topptr -= value;
		else
		    topptr = 0;

sfiles:	    r_show(topptr);		/* redisplay the file */
	    break;

	    case FCLSBOX:
	      cont = FALSE;
	      break;

	    default:
	      if (ret >= ENTRY0 && ret <= ENTRY7) {
	      	  erasemsg();		/* erase EXAMINING box */
	      	  want2edt(ret);	/* let user edit entry */
	      	  dsplymsg(xamform);	/* redraw EXAMINING box */
	      }
	      break;  
	}				/* end of switch */
    }			    	/* while */
    erasemsg();
    
    /* New inputted list = Examined list */
    for (xam = 0, np = 0; xam < npndefs; xam++) {
    	if (xampaddr[xam].exist) {
    	    nppaddr[np].head = xampaddr[xam].head;
    	    nppaddr[np].cylndr = xampaddr[xam].cylndr;
    	    nppaddr[np].btoffst = xampaddr[xam].btoffst;
    	    np++;
    	}
    }
    npndefs = np;	/* current number of input entries */
    free(xampaddr);
    return (TRUE);
}



/*---------------*/
/* read in items */
/*---------------*/

int	
r_items()
{
    int  h, status;
    int  full, i;
    char temp[10];

    topptr = 0;			/* reset top pointer	*/

    /* Feed the window with inputted entries */
    if (npndefs < NM_ITEMS)
        full = npndefs;
    else
        full = NM_ITEMS;
        
    for (i = 0; i < full; i++) {
    	/* Head number */
    	itoa(xampaddr[i].head, (xamform[defent[i]].ob_spec)->te_ptext);
    	
    	/* Cylinder number */
    	itoa(xampaddr[i].cylndr, temp);
    	strcat((xamform[defent[i]].ob_spec)->te_ptext, temp);
    	if (xampaddr[i].cylndr < 10)
	   strcat((xamform[defent[i]].ob_spec)->te_ptext, "   ");
	else if (xampaddr[i].cylndr < 100)
	   strcat((xamform[defent[i]].ob_spec)->te_ptext, "  ");
	else if (xampaddr[i].cylndr < 1000)
	   strcat((xamform[defent[i]].ob_spec)->te_ptext, " ");
	   
	/* Byte offset */
    	itoa(xampaddr[i].btoffst, temp);
    	strcat((xamform[defent[i]].ob_spec)->te_ptext, temp);

	xamform[defent[i]].ob_flags |= (SELECTABLE | TOUCHEXIT);
    	LWSET(OB_STATE(xamform, defent[i]), NORMAL);
    }
    
    for (; i < NM_ITEMS; i++) {
	strcpy((xamform[defent[i]].ob_spec)->te_ptext, "@");
	xamform[defent[i]].ob_flags &= ~(SELECTABLE | TOUCHEXIT);
    	LWSET(OB_STATE(xamform, defent[i]), DISABLED);
    }
    
    h = LWGET(OB_HEIGHT(xamform, FSVSLID));

    if (npndefs > NM_ITEMS)
	h = (h * NM_ITEMS) / npndefs;

    LWSET(OB_Y(xamform, FSVELEV), 0);	  /* move it to the top */
    LWSET(OB_HEIGHT(xamform, FSVELEV), h);  /* height of the elevator */
    dsplymsg(xamform);
}
	


/*----------------------------------------------*/
/*	show items and update the scroll bar	*/
/*----------------------------------------------*/

r_show(index)
int index;		/* where to start */
{	
    int  i, ndx, full, x, y;
    long h;
    char temp[10];
    PADDR *curpaddr;
    int  curent;
	

    if ((full = index + NM_ITEMS) > npndefs)
        full = npndefs;
        
    /* Feed the window with inputted entries */
    for (i = index, ndx = 0; i < full; i++,ndx++) {
    	curpaddr = xampaddr + i;
    	curent = defent[ndx];
    	
    	/* Head number */
    	itoa(curpaddr->head, (xamform[curent].ob_spec)->te_ptext);
    	
    	/* Cylinder number */
    	itoa(curpaddr->cylndr, temp);
    	strcat((xamform[curent].ob_spec)->te_ptext, temp);
    	if (curpaddr->cylndr < 10)
	   strcat((xamform[curent].ob_spec)->te_ptext, "   ");
	else if (curpaddr->cylndr < 100)
	   strcat((xamform[curent].ob_spec)->te_ptext, "  ");
	else if (curpaddr->cylndr < 1000)
	   strcat((xamform[curent].ob_spec)->te_ptext, " ");
	   
	/* Byte offset */
    	itoa(curpaddr->btoffst, temp);
    	strcat((xamform[curent].ob_spec)->te_ptext, temp);
    	
    	if (!curpaddr->exist) {
    	    xamform[curent].ob_state = DISABLED;
    	    xamform[curent].ob_flags &= ~(SELECTABLE | TOUCHEXIT);
	} else {
	    xamform[curent].ob_state = NORMAL;
    	    xamform[curent].ob_flags |= (SELECTABLE | TOUCHEXIT);
	}
    	
	objc_draw(xamform, curent, 1, 0, 0, wdesk, hdesk);
    }
    
    for (; ndx < NM_ITEMS; ndx++) {
    	curent = defent[ndx];
	xamform[curent].ob_state = DISABLED;
    	xamform[curent].ob_flags &= ~(SELECTABLE | TOUCHEXIT);
    	strcpy((xamform[curent].ob_spec)->te_ptext, "@");
	objc_draw(xamform, curent, 1, 0, 0, wdesk, hdesk);
    }
    	

    h = LWGET(OB_HEIGHT(xamform, FSVSLID));
    h = topptr * h;
	
    if (totcnt)
	h = h / totcnt;

    LWSET(OB_Y(xamform, FSVELEV), h);
    /* draw the new one */
    objc_draw(xamform, FSVSLID, MAX_DEPTH, 0, 0, wdesk, hdesk);
}


/*
 *  An entry is selected while examining to be edited.
 */
want2edt(ent)
int ent;
{
    int i, stat, stent;
    PADDR *curpaddr;
    char temp[10];
    
    for (i = 0; i < NM_ITEMS; i++) {
    	if (ent == defent[i]) {
    	    curpaddr = xampaddr + topptr + i;
    	    itoa(curpaddr->head, edtform[EDHDNUM].ob_spec->te_ptext);
    	    itoa(curpaddr->cylndr, edtform[EDCYLNUM].ob_spec->te_ptext);
    	    itoa(curpaddr->btoffst, edtform[EDBYTOFF].ob_spec->te_ptext);
    	    edtform[EDTCN].ob_state = NORMAL;
    	    edtform[EDTDEL].ob_state = NORMAL;
    	    edtform[EDTOK].ob_state = NORMAL;
    	    graf_mouse(ARROW, 0L);
    	    dsplymsg(edtform);
    	    stent = EDHDNUM;
    	    
redoent:    edtform[EDTOK].ob_state = NORMAL;
    	    objc_draw(edtform, EDTOK, 1, 0, 0, wdesk, hdesk);
	    stat = form_do(edtform, stent);

    	    switch (stat) {
    	    	case EDTDEL:
    	    	    curpaddr->exist = FALSE;
    	    	    xamform[ent].ob_state = DISABLED;
    	    	    xamform[ent].ob_flags &= ~(SELECTABLE | TOUCHEXIT);
    	    	    break;
    	    	    
    	    	case EDTOK:
		    /* Check validity of input and perform appropiate action */
		    switch (chknput(edtform, EDHDNUM, EDCYLNUM, EDBYTOFF)) {
        	
			case OK:
			    /* Update entry */
			    gpaddr(curpaddr, edtform, EDHDNUM, EDCYLNUM,
			    	    EDBYTOFF);
			    	    
			    /* Update head number on screen */
			    itoa(curpaddr->head,
			    	    xamform[ent].ob_spec->te_ptext);
			    	    
			    /* Update cylinder number on screen */
			    itoa(curpaddr->cylndr, temp);
			    strcat(xamform[ent].ob_spec->te_ptext, temp);
			    if (curpaddr->cylndr < 10)
			        strcat(xamform[ent].ob_spec->te_ptext, "   ");
			    else if (curpaddr->cylndr < 100)
			        strcat(xamform[ent].ob_spec->te_ptext, "  ");
			    else if (curpaddr->cylndr < 1000)
			        strcat(xamform[ent].ob_spec->te_ptext, " ");
			    
			    /* Update byte offset on screen */
			    itoa(curpaddr->btoffst, temp);
			    strcat(xamform[ent].ob_spec->te_ptext, temp);
			    break;
                
			case INCMPL:
			case EMPTY:
			    form_alert(1, npcmpent);
			    stent = EDHDNUM;
			    goto redoent;
                
			case HD2BIG:
			    form_alert(1, bghdnum);
			    clrnput(edtform, EDHDNUM, -1, -1, EDTBOX);
			    stent = EDHDNUM;
			    goto redoent;

			case CYL2BIG:
			    form_alert(1, bgcylnum);
			    clrnput(edtform, -1, EDCYLNUM, -1, EDTBOX);
			    stent = EDCYLNUM;
			    goto redoent;

			case BYT2BIG:
			    form_alert(1, bgbytnum);
			    clrnput(edtform, -1, -1, EDBYTOFF, EDTBOX);
			    stent = EDBYTOFF;
			    goto redoent;
                
			default:
			    break;
		    }
    	    	    
    	    	case EDTCN:
    	    	    break;

		default:
		    break;    	    	    
	    }
	    erasemsg();
	    break;
    	}
    }
}
