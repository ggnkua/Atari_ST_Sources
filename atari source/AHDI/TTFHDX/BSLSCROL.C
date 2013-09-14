/*  BSLSCROL.C
/*	3/1/88		Derek Mui				*/
/*	4/29/88		Edited by ml. for use in factory HDX	*/


#include <obdefs.h>
#include <osbind.h>
#include <gemdefs.h>
#include "fhdx.h"
#include "define.h"
#include "addr.h"
#include "bsl.h"
#include "scroll.h"

int	topptr;		/* top pointer	*/
int	totcnt;		/* total number of items */
int	nent;		/* number of entries in BSL */
long	nspc;		/* number of sectors per cylinder */
BSLINFO	*bslinfo;	/* BSL info to be displayed */

extern int xdesk, ydesk, wdesk, hdesk;	/* dimensions of desktop */
extern char *bsl;
extern long bslsiz;
extern long gbslsiz();
extern long nument();
extern long get3bytes();

/*
 * Indices to entries in the window.
 */
int bslent[] = {
    BENTRY0, BENTRY1, BENTRY2, BENTRY3,
    BENTRY4, BENTRY5, BENTRY6, BENTRY7
};


dsplybsl(dev, nheads, nspt)
int dev;		/* physical device number (0 -> 7) */
UWORD nheads;		/* number of heads */
UWORD nspt;		/* number of sectors per track */
{
    int  i;	/* number of bsl entries to be displayed */
    long mul;
    int	 botptr, bret, value;
    int  xoff, yoff, mx, my;
    int  ret, cont;
    int  k1, k2;

    /* Find size of BSL */
    /*
    bslsiz = gbslsiz(dev);
    /**/
    /* Allocate memory for BSL */
    /*
    
    bsl = 0L;
    if ((bsl = (BYTE *)mymalloc((int)bslsiz << 9)) <= 0) {
	return err(nomemory);
    }
    
    if ((ret = rdbsl(dev)) != OK) {
	if (ret == INVALID)
	    err(cruptbsl);
	ret = ERROR;
	goto leavewin;
    }
    /**/
    
    nent = (int)nument(VENDOR);		/* find if there is any entry */
    nspc = (long)nheads * (long)nspt;
    
    /* Allocate memory to hold defects */
    bslinfo = 0L;
    if ((bslinfo = (BSLINFO *)mymalloc(nent*(sizeof(BSLINFO)))) <= 0) {
        ret = err(nomemory);
        goto leavewin;
    }
    
    for (i = 0; i < nent; i++) {
    	bslinfo[i].num = i+1;
    	bslinfo[i].sectnum = get3bytes(bsl + ((RENT + i) * BPE));
    	bslinfo[i].cylndr = (unsigned int)(bslinfo[i].sectnum / nspc);
    	bslinfo[i].head
    	    = (UWORD)((bslinfo[i].sectnum - bslinfo[i].cylndr * nspc) / nspt);
    }

    br_items();		/* read items */
    
    totcnt = nent;
    if (nent > NM_ITEMS)		/* bigger than one window */
	botptr = nent - NM_ITEMS;
    else
	botptr = 0;

    cont = TRUE;			/* control flag	*/
    while(cont) {
	bret = form_do(bslform, -1);
	graf_mkstate(&mx, &my, &k1, &k2);	/* graf mkstate	*/
	ret = bret & 0x7FFF;			/* mask off double click */
	LWSET(OB_STATE(bslform, ret), 0);
	value = 1;			/* scroll factor */

	switch (ret) {		/* Big Switch */
	    case BVSLID:		
		objc_offset(bslform, BVELEV, &xoff, &yoff);
		value = NM_ITEMS;		/* one full window size	*/
		if (my <= yoff)
		    goto bup;		
		goto bdown;

	    case BVELEV:
		value = graf_slidebox(bslform, BVSLID, BVELEV, TRUE);
		mul = (nent - NM_ITEMS) * value;
		mul /= 1000;
		value = (int)mul; 
		value = (topptr - value);
		if (value >= 0)
		    goto bup;			/* go up */
		else
		    value = -value;		/* go down */

bdown:	    case BDNAROW:			/* scroll down */
		if (topptr == botptr)
		    break;

		if ((topptr + value) <= botptr)
		    topptr += value;
		else
		    topptr = botptr;

		goto sbsl;			

bup:	    case BUPAROW:			/* scroll up */
		if (!topptr)
		    break;

		if ((topptr - value) >= 0)
		    topptr -= value;
		else
		    topptr = 0;

sbsl:	    br_show(topptr);		/* redisplay the file */
	    break;

	    case BCLSBOX:
	      cont = FALSE;
	      break;

	    default:
	      break;  
	}				/* end of switch */
    }			    	/* while */
    ret = TRUE;
leavewin:
    erasemsg();
    if (bsl > 0L) free(bsl);    
    if (bslinfo > 0L) free(bslinfo);
    return (ret);
}



/*---------------*/
/* read in items */
/*---------------*/

int	
br_items()
{
    int  h, status;
    int  full, i;
    char temp[10];

    topptr = 0;			/* reset top pointer	*/

    /* Feed the window with inputted entries */
    if (nent < NM_ITEMS)
        full = nent;
    else
        full = NM_ITEMS;
        
    for (i = 0; i < full; i++) {
    	/* count */
    	itoa(bslinfo[i].num, temp);
    	strcpy((bslform[bslent[i]].ob_spec)->te_ptext, temp);
    	if (bslinfo[i].num < 10)
	   strcat((bslform[bslent[i]].ob_spec)->te_ptext, "  ");
	else if (bslinfo[i].num < 100)
	   strcat((bslform[bslent[i]].ob_spec)->te_ptext, " ");
	   
    	/* Head number */
    	itoa(bslinfo[i].head, temp);
    	strcat((bslform[bslent[i]].ob_spec)->te_ptext, temp);
    	if (bslinfo[i].num < 10)
	   strcat((bslform[bslent[i]].ob_spec)->te_ptext, " ");
    	
    	/* Cylinder number */
    	itoa(bslinfo[i].cylndr, temp);
    	strcat((bslform[bslent[i]].ob_spec)->te_ptext, temp);
    	if (bslinfo[i].cylndr < 10)
	   strcat((bslform[bslent[i]].ob_spec)->te_ptext, "   ");
	else if (bslinfo[i].cylndr < 100)
	   strcat((bslform[bslent[i]].ob_spec)->te_ptext, "  ");
	else if (bslinfo[i].cylndr < 1000)
	   strcat((bslform[bslent[i]].ob_spec)->te_ptext, " ");
	   
	/* Sector Number */
    	ltoa(bslinfo[i].sectnum, temp);
    	strcat((bslform[bslent[i]].ob_spec)->te_ptext, temp);
    	
	LWSET(OB_STATE(bslform, bslent[i]), NORMAL);
    }
    
    for (; i < NM_ITEMS; i++) {
    	strcpy((bslform[bslent[i]].ob_spec)->te_ptext, "@");
	LWSET(OB_STATE(bslform, bslent[i]), DISABLED);
    }
    
    h = LWGET(OB_HEIGHT(bslform, BVSLID));

    if (nent > NM_ITEMS)
	h = (h * NM_ITEMS) / nent;

    LWSET(OB_Y(bslform, BVELEV), 0);		/* move it to the top */
    LWSET(OB_HEIGHT(bslform, BVELEV), h);	/* height of the elevator */
    graf_mouse(ARROW, 0L);
    dsplymsg(bslform);
}
	


/*----------------------------------------------*/
/*	show items and update the scroll bar	*/
/*----------------------------------------------*/

br_show(index)
int index;		/* where to start */
{	
    int  i, ndx, full, x, y;
    long h;
    char temp[10];
    BSLINFO *curbslinfo;
    int  curent;

    if ((full = index + NM_ITEMS) > nent)
        full = nent;
        
    /* Feed the window with inputted entries */
    for (i = index, ndx = 0; i < full; i++,ndx++) {
    	curbslinfo = bslinfo + i;
    	curent = bslent[ndx];
    	
    	/* count */
    	itoa(curbslinfo->num, temp);
    	strcpy((bslform[curent].ob_spec)->te_ptext, temp);
    	if (curbslinfo->num < 10)
	   strcat((bslform[curent].ob_spec)->te_ptext, "  ");
	else if (curbslinfo->num < 100)
	   strcat((bslform[curent].ob_spec)->te_ptext, " ");
	   
    	/* Head number */
    	itoa(curbslinfo->head, temp);
    	strcat((bslform[curent].ob_spec)->te_ptext, temp);
    	if (curbslinfo->head < 10)
	   strcat((bslform[curent].ob_spec)->te_ptext, " ");
    	
    	/* Cylinder number */
    	itoa(curbslinfo->cylndr, temp);
    	strcat((bslform[curent].ob_spec)->te_ptext, temp);
    	if (curbslinfo->cylndr < 10)
	   strcat((bslform[curent].ob_spec)->te_ptext, "   ");
	else if (curbslinfo->cylndr < 100)
	   strcat((bslform[curent].ob_spec)->te_ptext, "  ");
	else if (curbslinfo->cylndr < 1000)
	   strcat((bslform[curent].ob_spec)->te_ptext, " ");
	   
	/* Sector number */
    	ltoa(curbslinfo->sectnum, temp);
    	strcat((bslform[curent].ob_spec)->te_ptext, temp);
    	
    	LWSET(OB_STATE(bslform, curent), NORMAL);
	objc_draw(bslform, curent, 1, 0, 0, wdesk, hdesk);
    }
    
    for (; ndx < NM_ITEMS; ndx++) {
    	curent = bslent[ndx];
    	strcpy((bslform[curent].ob_spec)->te_ptext, "@");
    	LWSET(OB_STATE(bslform, curent), DISABLED);
	objc_draw(bslform, curent, 1, 0, 0, wdesk, hdesk);
    }
    	
    h = LWGET(OB_HEIGHT(bslform, BVSLID));
    h = topptr * h;
	
    if (totcnt)
	h = h / totcnt;

    LWSET(OB_Y(bslform, BVELEV), h);
    /* draw the new one */
    objc_draw(bslform, BVSLID, MAX_DEPTH, 0, 0, wdesk, hdesk);
}

