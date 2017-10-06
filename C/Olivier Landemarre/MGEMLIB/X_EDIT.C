/*
*
* Extension for MT_AES, contains the
* binding for the editor functions Andreas Kromke
*
* 14.01.2001 olivier.landemarre@utbm.fr 
*/
#include "mgemx.h"
/****************************************************************
*
* (210)	edit_create
*
****************************************************************/

XEDITINFO *mt_edit_create( INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={210,0,0,0,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/

	aes(&aes_params);

	return( (XEDITINFO *) aes_addrout[0] );
}


/****************************************************************
*
* (211)	edit_open
*
****************************************************************/

int mt_edit_open(OBJECT *tree, int obj, INT16 *global_aes)
{	static INT16 aes_control[AES_CTRLMAX]={211,1,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/
	

	aes_intin[0] = obj;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	return( aes_intout[0] );
}


/****************************************************************
*
* (212)	edit_close
*
****************************************************************/

void mt_edit_close(OBJECT *tree, int obj, INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={212,1,0,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/

	aes_intin[0] = obj;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);
}


/****************************************************************
*
* (213)	edit_delete
*
****************************************************************/

void mt_edit_delete( XEDITINFO *xi, INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={213,0,0,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/

	aes_addrin[0] = (long)xi;

	aes(&aes_params);
}


/****************************************************************
*
* (214)	edit_cursor
*
****************************************************************/

int mt_edit_cursor(OBJECT *tree, int obj, int whdl,
					int show, INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={214,3,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/
	
	aes_intin[0] = obj;
	aes_intin[1] = whdl;
	aes_intin[2] = show;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	return(aes_intout[0]);
}

/****************************************************************
*
* (215)	edit_evnt
*
****************************************************************/

int mt_edit_evnt(OBJECT *tree, int obj, int whdl,
				EVNT *ev, long *errc, INT16 *global_aes)
{
	static INT16 aes_control[AES_CTRLMAX]={215,2,3,2,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/


	aes_intin[0] = obj;
	aes_intin[1] = whdl;
	aes_addrin[0] = (long)tree;
	aes_addrin[1] = (long)ev;
	*((long *) (aes_intout+1)) = 0L;	/* For old SLB */

	aes(&aes_params);

	*errc = *((long *) (aes_intout+1));
	return(aes_intout[0]);
}


/****************************************************************
*
* (216)	edit_get
*
****************************************************************/

int mt_edit_get_buf( OBJECT *tree, int obj,
					char **buf, long *buflen,
					long *txtlen,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={216,2,5,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/

	aes_intin[0] = obj;
	aes_intin[1] = 0;		/* Subcode 0 */
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	*buf = (char *)aes_addrout[0];
	*buflen = *((long *) (aes_intout+1));
	*txtlen = *((long *) (aes_intout+3));
	return(aes_intout[0]);
}

int mt_edit_get_format( OBJECT *tree, int obj,
					INT16 *tabwidth, INT16 *autowrap,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={216,2,3,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/

	aes_intin[0] = obj;
	aes_intin[1] = 1;		/* Subcode 1 */
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	*tabwidth = aes_intout[1];
	*autowrap = aes_intout[2];
	return(aes_intout[0]);
}

int mt_edit_get_colour( OBJECT *tree, int obj,
					INT16 *tcolour, INT16 *bcolour,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={216,2,3,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/

	aes_intin[0] = obj;
	aes_intin[1] = 2;		/* Subcode 2 */
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	*tcolour = aes_intout[1];
	*bcolour = aes_intout[2];
	return(aes_intout[0]);
}

int mt_edit_get_font( OBJECT *tree, int obj,
					INT16 *fontID, INT16 *fontH,
					INT16 *fontPix, INT16 *mono,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={216,2,5,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/
	
	aes_intin[0] = obj;
	aes_intin[1] = 3;		/* Subcode 3 */
	aes_addrin[0] = (long)tree;
	aes_intout[4] = 0/*FALSE*/;	/* For old libraries */

	aes(&aes_params);

	*fontID = aes_intout[1];
	*fontH = aes_intout[2];
	*fontPix = aes_intout[4];
	*mono = aes_intout[3];
	return(aes_intout[0]);
}

int mt_edit_get_cursor( OBJECT *tree, int obj,
					char **cursorpos, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={216,2,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/


	aes_intin[0] = obj;
	aes_intin[1] = 4;		/* Subcode 4 */
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	*cursorpos = (char *)aes_addrout[0];
	return(aes_intout[0]);
}

void mt_edit_get_pos( OBJECT *tree, int obj,
					INT16 *xscroll,
					long *yscroll,
					char **cyscroll,
					char **cursorpos,
					INT16 *cx,
					INT16 *cy,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={216,2,6,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/

	aes_intin[0] = obj;
	aes_intin[1] = 5;		/* Subcode 5 */
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	*xscroll = aes_intout[1];
	*yscroll = *((long *) (aes_intout+2));
	*cyscroll = (char *)aes_addrout[0];
	*cx = aes_intout[4];
	*cy = aes_intout[5];
	*cursorpos = (char *)aes_addrout[1];
}

int mt_edit_get_dirty( OBJECT *tree, int obj,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={216,2,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/


	aes_intin[0] = obj;
	aes_intin[1] = 7;		/* Subcode 7 */
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	return(aes_intout[0]);
}

void mt_edit_get_sel( OBJECT *tree, int obj,
					char **bsel, char **esel,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={216,2,0,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/


	aes_intin[0] = obj;
	aes_intin[1] = 8;		/* Subcode 8 */
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	*bsel = (char *)aes_addrout[0];
	*esel = (char *)aes_addrout[1];
}

void mt_edit_get_scrollinfo( OBJECT *tree, int obj,
					long *nlines, long *yscroll, INT16 *yvis, INT16 *yval,
					INT16 *ncols, INT16 *xscroll, INT16 *xvis,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={216,2,6,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
  AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/

	aes_intin[0] = obj;
	aes_intin[1] = 9;		/* Subcode 9 */
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	*nlines = *((long *) (aes_intout+1));
	*yscroll = *((long *) (aes_intout+3));
	*yvis = aes_intout[5];
	*yval = aes_intout[6];
	*ncols = aes_intout[7];
	*xscroll = aes_intout[8];
	*xvis = aes_intout[9];
}


/****************************************************************
*
* (217)	edit_set
*
****************************************************************/

void mt_edit_set_buf( OBJECT *tree, int obj,
					char *buf, long buflen, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={217,4,0,2,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/
	

	aes_intin[0] = obj;
	aes_intin[1] = 0;		/* Subcode 0 */
	*(long *) (aes_intin+2) = buflen;
	aes_addrin[0] = (long)tree;
	aes_addrin[1] = (long)buf;

	aes(&aes_params);
}

void mt_edit_set_format( OBJECT *tree, int obj,
					int tabwidth, int autowrap,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={217,4,0,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/
	
	aes_intin[0] = obj;
	aes_intin[1] = 1;		/* Subcode 1 */
	aes_intin[2] = tabwidth;
	aes_intin[3] = autowrap;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);
}

void mt_edit_set_colour( OBJECT *tree, int obj,
					int tcolour, int bcolour,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={217,4,0,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/
	
	aes_intin[0] = obj;
	aes_intin[1] = 2;		/* Subcode 2 */
	aes_intin[2] = tcolour;
	aes_intin[3] = bcolour;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);
}

void mt_edit_set_font( OBJECT *tree, int obj,
					int fontID, int fontH, int fontPix,
					int mono, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={217,6,0,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/
	

	aes_intin[0] = obj;
	aes_intin[1] = 3;		/* Subcode 3 */
	aes_intin[2] = fontID;
	aes_intin[3] = fontH;
	aes_intin[4] = mono;
	aes_intin[5] = fontPix;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);
}

void mt_edit_set_cursor( OBJECT *tree, int obj,
					char *cursorpos,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={217,2,0,2,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/
	

	aes_intin[0] = obj;
	aes_intin[1] = 4;		/* Subcode 4 */
	aes_addrin[0] = (long)tree;
	aes_addrin[1] = (long)cursorpos;

	aes(&aes_params);
}

void mt_edit_set_pos( OBJECT *tree, int obj,
					int xscroll,
					long yscroll,
					char *cyscroll,
					char *cursorpos,
					int cx,
					int cy,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={217,7,0,3,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/


	aes_intin[0] = obj;
	aes_intin[1] = 5;		/* Subcode 5 */
	aes_intin[2] = xscroll;
	*(long *) (aes_intin+3) = yscroll;
	aes_intin[5] = cx;
	aes_intin[6] = cy;
	aes_addrin[0] = (long)tree;
	aes_addrin[1] = (long)cyscroll;
	aes_addrin[2] = (long)cursorpos;

	aes(&aes_params);
}

int mt_edit_resized( OBJECT *tree, int obj,
					INT16 *oldrh, INT16 *newrh,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={217,2,3,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/

	aes_intin[0] = obj;
	aes_intin[1] = 6;		/* Subcode 6 */
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	*oldrh = aes_intout[1];
	*newrh = aes_intout[2];
	return(aes_intout[0]);
}

void mt_edit_set_dirty( OBJECT *tree, int obj,
					int dirty,
					INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={217,2,0,2,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/


	aes_intin[0] = obj;
	aes_intin[1] = 7;		/* Subcode 7 */
	aes_intin[2] = dirty;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);
}

int mt_edit_scroll( OBJECT *tree, int obj,
				int whdl,
				long yscroll, int xscroll, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={217,6,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
				aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
				aes_addrout[AES_ADDROUTMAX];
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */       
  	aes_params.addrout = &aes_addrout[0];   /* output address array  		*/


	aes_intin[0] = obj;
	aes_intin[1] = 9;		/* Subcode 9 */
	aes_intin[2] = whdl;
	*(long *) (aes_intin+3) = yscroll;
	aes_intin[5] = xscroll;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	return(aes_intout[0]);
}
