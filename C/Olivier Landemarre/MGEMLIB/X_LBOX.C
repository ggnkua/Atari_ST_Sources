/*
 * Aes extension for Magic (Lbox)
 * From MT_AES of Andrea Kromke
 * 09.01.2001 olivier.landemarre@utbm.fr from MT_AES of Magic documentation
*/
#include "mgemx.h"

/****************************************************************
*
* (170)	lbox_create
*
****************************************************************/

LIST_BOX *mt_lbox_create( OBJECT *tree, SLCT_ITEM slct,
					SET_ITEM set, LBOX_ITEM *items,
					int visible_a, int first_a,
					INT16 *ctrl_objs, INT16 *objs, int flags,
					int pause_a, void *user_data,
					void *dialog, int visible_b,
					int first_b, int entries_b,
					int pause_b, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={170,8,0,8,0};
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


	aes_intin[0]	= visible_a;
	aes_intin[1]	= first_a;
	aes_intin[2]	= flags;
	aes_intin[3]	= pause_a;
	aes_intin[4]	= visible_b;
	aes_intin[5]	= first_b;
	aes_intin[6]	= entries_b;
	aes_intin[7]	= pause_b;
	aes_addrin[0]	= (long)tree;
	aes_addrin[1]	= (long)slct;
	aes_addrin[2]	= (long)set;
	aes_addrin[3]	= (long)items;
	aes_addrin[4]	= (long)ctrl_objs;
	aes_addrin[5]	= (long)objs;
	aes_addrin[6]	= (long)user_data;
	aes_addrin[7]	= (long)dialog;

	aes(&aes_params);

	return((LIST_BOX *)aes_addrout[0]);
}


/****************************************************************
*
* (171)	lbox_update
*
****************************************************************/

void	mt_lbox_update( LIST_BOX *box, GRECT *rect, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={171,0,0,2,0};
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

	aes_addrin[0]	= (long)box;
	aes_addrin[1]	= (long)rect;

	aes(&aes_params);
}



/****************************************************************
*
* (172)	lbox_do
*
****************************************************************/

int	mt_lbox_do( LIST_BOX *box, int obj, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={172,1,1,1,0};
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
	aes_addrin[0]	= (long)box;

	aes(&aes_params);
	return(aes_intout[0]);
}



/****************************************************************
*
* (173)	lbox_delete
*
****************************************************************/

int	mt_lbox_delete( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={173,0,1,1,0};
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

	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return(aes_intout[0]);
}



/****************************************************************
*
* (174)	lbox_get
*
****************************************************************/

int	mt_lbox_cnt_items( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,1,1,0};
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
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return(aes_intout[0]);
}



OBJECT  *mt_lbox_get_tree( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,0,1,0};
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
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return((OBJECT  *)aes_addrout[0]);
}


int	mt_box_get_visible( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,1,1,0};
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
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return(aes_intout[0]);
}


void	*mt_lbox_get_udata( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,0,1,0};
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
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return((void	*)aes_addrout[0]);
}



int	mt_lbox_get_afirst( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,1,1,0};
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
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return(aes_intout[0]);
}



int	mt_lbox_get_slct_idx( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,1,1,0};
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

	aes_intin[0]	= 5;
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return(aes_intout[0]);
}



LBOX_ITEM  *mt_lbox_get_items( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,0,1,0};
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

	aes_intin[0]	= 6;
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return((LBOX_ITEM  *)aes_addrout[0]);
}


LBOX_ITEM  *mt_lbox_get_item( LIST_BOX *box, int n, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,2,0,1,0};
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

	aes_intin[0]	= 7;
	aes_intin[1]	= n;
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return((LBOX_ITEM  *)aes_addrout[0]);
}


LBOX_ITEM	*mt_lbox_get_slct_item( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,0,1,0};
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

	aes_intin[0]	= 8;
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return((LBOX_ITEM  *)aes_addrout[0]);
}


int	mt_lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,1,2,0};
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

	aes_intin[0]	= 9;
	aes_addrin[0]	= (long)items;
	aes_addrin[1]	= (long)search;

	aes(&aes_params);

	return(aes_intout[0]);
}


int	mt_lbox_get_bvis( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,1,1,0};
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

	aes_intin[0]	= 10;
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return(aes_intout[0]);
}


int	mt_lbox_get_bentries( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,1,1,0};
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

	aes_intin[0]	= 11;
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return(aes_intout[0]);
}



int	mt_lbox_get_bfirst( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={174,1,1,1,0};
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

	aes_intin[0]	= 12;
	aes_addrin[0]	= (long)box;

	aes(&aes_params);

	return(aes_intout[0]);
}



/****************************************************************
*
* (175)	lbox_set
*
****************************************************************/

void	mt_lbox_set_asldr( LIST_BOX *box, int first, GRECT *rect, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={175,2,0,2,0};
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
	aes_intin[1]	= first;
	aes_addrin[0]	= (long)box;
	aes_addrin[1]	= (long)rect;

	aes(&aes_params);
}


void	mt_lbox_set_items( LIST_BOX *box, LBOX_ITEM *items, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={175,1,0,2,0};
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
	aes_addrin[0]	= (long)box;
	aes_addrin[1]	= (long)items;

	aes(&aes_params);
}


void	mt_lbox_free_items( LIST_BOX *box, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={175,1,0,1,0};
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
	aes_addrin[0]	= (long)box;

	aes(&aes_params);
}


void	mt_lbox_free_list( LBOX_ITEM *items, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={175,1,0,1,0};
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
	aes_addrin[0]	= (long)items;

	aes(&aes_params);
}


void	mt_lbox_ascroll_to( LIST_BOX *box, int first, GRECT *box_rect,
					GRECT *slider_rect, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={175,2,0,3,0};
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
	aes_intin[1]	= first;
	aes_addrin[0]	= (long)box;
	aes_addrin[1]	= (long)box_rect;
	aes_addrin[2]	= (long)slider_rect;

	aes(&aes_params);
}



void	mt_lbox_set_bsldr( LIST_BOX *box, int first, GRECT *rect, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={175,2,0,2,0};
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

	aes_intin[0]	= 5;
	aes_intin[1]	= first;
	aes_addrin[0]	= (long)box;
	aes_addrin[1]	= (long)rect;

	aes(&aes_params);
}


void	mt_lbox_set_bentries( LIST_BOX *box, int entries, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={175,2,0,1,0};
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

	aes_intin[0]	= 6;
	aes_intin[1]	= entries;
	aes_addrin[0]	= (long)box;

	aes(&aes_params);
}



void	mt_lbox_bscroll_to( LIST_BOX *box, int first, GRECT *box_rect,
					GRECT *slider_rect, INT16 *global_aes )
{
	static INT16 aes_control[AES_CTRLMAX]={175,2,0,3,0};
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

	aes_intin[0]	= 7;
	aes_intin[1]	= first;
	aes_addrin[0]	= (long)box;
	aes_addrin[1]	= (long)box_rect;
	aes_addrin[2]	= (long)slider_rect;

	aes(&aes_params);
}


