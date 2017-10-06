/*
 * Aes windows Dialog extension for Magic (WDLG)
 * from MT_AES of Magic documentation, Andreas Kromke
 * 09.01.2001 olivier.landemarre@utbm.fr 
*/

#include "mgemx.h"
/****************************************************************
*
* (160)	wdlg_create
*
****************************************************************/
DIALOG *mt_wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree,
				void *user_data, int code, void *data,
				int flags, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={160,2,0,4,0};
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
	
	aes_intin[0]	= code;
	aes_intin[1]	= flags;
	aes_addrin[0]	= (long)handle_exit;
	aes_addrin[1]	= (long)tree;
	aes_addrin[2]	= (long)user_data;
	aes_addrin[3]	= (long)data;

	aes(&aes_params);

	return((DIALOG *)aes_addrout[0]);
}



/****************************************************************
*
* (161)	wdlg_open
*
****************************************************************/

INT16	mt_wdlg_open( DIALOG *dialog, char *title, int kind,
				int x, int y, int code, void *data, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={161,4,1,3,0};
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

	aes_intin[0]	= kind;
	aes_intin[1]	= x;
	aes_intin[2]	= y;
	aes_intin[3]	= code;
	aes_addrin[0]	= (long)dialog;
	aes_addrin[1]	= (long)title;
	aes_addrin[2]	= (long)data;

	aes(&aes_params);

	return(aes_intout[0]);
}



/****************************************************************
*
* (162)	wdlg_close
*
****************************************************************/


int	mt_wdlg_close( DIALOG *dialog, INT16 *x, INT16 *y, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={162,0,3,1,0};
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

	aes_intout[1] = -1;
	aes_intout[2] = -1;

	aes_addrin[0]	= (long)dialog;

	aes(&aes_params);

	if	( x )
		*x = aes_intout[1];
	if	( y )
		*y = aes_intout[2];

	return( aes_intout[0] );
}



/****************************************************************
*
* (163)	wdlg_delete
*
****************************************************************/

int	mt_wdlg_delete( DIALOG *dialog, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={163,0,1,1,0};
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

	aes_addrin[0]	= (long)dialog;

	aes(&aes_params);
	return(aes_intout[0]);
}



/****************************************************************
*
* (164)	wdlg_get
*
****************************************************************/

int	mt_wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT *r, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={164,1,1,3,0};
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

	aes_intin[0]	= 0;
	aes_addrin[0]	= (long)dialog;
	aes_addrin[1]	= (long)tree;
	aes_addrin[2]	= (long)r;

	aes(&aes_params);

	return(aes_intout[0]);
}



int	mt_wdlg_get_edit( DIALOG *dialog, INT16 *cursor, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={164,1,2,1,0};
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

	aes_intin[0]	= 1;
	aes_addrin[0]	= (long)dialog;

	aes(&aes_params);

	*cursor		= aes_intout[1];
	return(aes_intout[0]);
}


void	*mt_wdlg_get_udata( DIALOG *dialog, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={164,1,0,1,0};
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

	aes_intin[0]	= 2;
	aes_addrin[0]	= (long)dialog;

	aes(&aes_params);

	return((void *)aes_addrout[0]);
}


int	mt_wdlg_get_handle( DIALOG *dialog, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={164,1,1,1,0};
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

	aes_intin[0]	= 3;
	aes_addrin[0]	= (long)dialog;

	aes(&aes_params);
	return(aes_intout[0]);
}



/****************************************************************
*
* (165)	wdlg_set
*
****************************************************************/

int	mt_wdlg_set_edit( DIALOG *dialog, int obj, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={165,2,1,1,0};
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

	aes_intin[0]	= 0;
	aes_intin[1]	= obj;
	aes_addrin[0]	= (long)dialog;

	aes(&aes_params);

	return(aes_intout[0]);
}



int	mt_wdlg_set_tree( DIALOG *dialog, OBJECT *new_tree, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={165,1,1,2,0};
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

	aes_intin[0]	= 1;
	aes_addrin[0]	= (long)dialog;
	aes_addrin[1]	= (long)new_tree;

	aes(&aes_params);

	return(aes_intout[0]);
}


int	mt_wdlg_set_size( DIALOG *dialog, GRECT *new_size, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={165,1,1,2,0};
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

	aes_intin[0]	= 2;
	aes_addrin[0]	= (long)dialog;
	aes_addrin[1]	= (long)new_size;

	aes(&aes_params);

	return(aes_intout[0]);
}


int	mt_wdlg_set_iconify( DIALOG *dialog, GRECT *g, char *title,
					OBJECT *tree, int obj, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={165,2,1,4,0};
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

	aes_intin[0]	= 3;
	aes_intin[1]	= obj;
	aes_addrin[0]	= (long)dialog;
	aes_addrin[1]	= (long)g;
	aes_addrin[2]	= (long)title;
	aes_addrin[3]	= (long)tree;

	aes(&aes_params);

	return(aes_intout[0]);
}


int	mt_wdlg_set_uniconify( DIALOG *dialog, GRECT *g, char *title,
					OBJECT *tree, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={165,1,1,4,0};
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

	aes_intin[0]	= 4;
	aes_addrin[0]	= (long)dialog;
	aes_addrin[1]	= (long)g;
	aes_addrin[2]	= (long)title;
	aes_addrin[3]	= (long)tree;

	aes(&aes_params);

	return(aes_intout[0]);
}


/****************************************************************
*
* (166)	wdlg_evnt
*
****************************************************************/

int	mt_wdlg_evnt( DIALOG *dialog, EVNT *events, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={166,0,1,2,0};
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

	aes_addrin[0]	= (long)dialog;
	aes_addrin[1]	= (long)events;

	aes(&aes_params);

	return(aes_intout[0]);
}



/****************************************************************
*
* (167)	wdlg_redraw
*
****************************************************************/

void	mt_wdlg_redraw( DIALOG *dialog, GRECT *rect, int obj,
				int depth, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={167,2,0,2,0};
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

	aes_intin[0]	= obj;
	aes_intin[1]	= depth;
	aes_addrin[0]	= (long)dialog;
	aes_addrin[1]	= (long)rect;

	aes(&aes_params);
}

