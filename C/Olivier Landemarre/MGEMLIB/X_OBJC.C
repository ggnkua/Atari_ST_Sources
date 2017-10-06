/*
 * Aes object library extension of MagiC
 * modified: ol -- olivier.landemarre.free.fr
 *
 */
#include "mgemx.h"


void mt_objc_wchange(OBJECT *tree, int obj, int new_state, GRECT *clip,  int whandle, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={61,3,0,2,0};
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
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

	aes_addrin[1] = (long)clip;

	aes_intin[0] = obj;
	aes_intin[1] = new_state;
	aes_intin[2] = whandle;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);
}

void objc_wchange(OBJECT *tree, int obj, int new_state, GRECT *clip,  int whandle)
{
	mt_objc_wchange(tree, obj, new_state, clip,  whandle, aes_global);
}

void mt_objc_wdraw(OBJECT *tree, int start, int depth, GRECT *clip,  int whandle, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={60,3,0,2,0};
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
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

	aes_addrin[1] = (long)clip;
	aes_intin[0] = start;
	aes_intin[1] = depth;
	aes_intin[2] = whandle;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);
}

void objc_wdraw(OBJECT *tree, int start, int depth, GRECT *clip,  int whandle)
{
	mt_objc_wdraw(tree, start, depth, clip,  whandle, aes_global);
}

int mt_objc_wedit(OBJECT *tree, int obj, int key, INT16 *idx, int kind, int whandle, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={65,5,2,1,0};
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
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

	aes_intin[0] = obj;
	aes_intin[1] = key;
	aes_intin[2] = *idx;
	aes_intin[3] = kind;
	aes_intin[4] = whandle;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	*idx = aes_intout[1];
	return aes_intout[0];
}

int objc_wedit(OBJECT *tree, int obj, int key, INT16 *idx, int kind, int whandle)
{
	return(mt_objc_wedit(tree, obj, key, idx, kind, whandle, aes_global));
}

int mt_objc_xedit(OBJECT *tree, int obj, int key, INT16 *xpos, int subfn, GRECT *r, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={46,4,2,2,0};
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
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

	aes_addrin[1] = (long)r;
	aes_intin[0] = obj;
	aes_intin[1] = key;
	aes_intin[2] = *xpos;
	aes_intin[3] = subfn;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	*xpos = aes_intout[1];
	return aes_intout[0];
}

int objc_xedit(OBJECT *tree, int obj, int key, INT16 *xpos, int subfn, GRECT *r)
{
	return(mt_objc_xedit(tree, obj, key, xpos, subfn, r, aes_global));
}
