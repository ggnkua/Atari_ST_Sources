/*
 * Aes form library extension of MagiC
 * modified: ol -- olivier.landemarre.free.fr
 *
 */
#include "mgemx.h"


int mt_form_popup(OBJECT *tree, int x, int y, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={135,2,1,1,0};
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

                    
	aes_intin[0] = x;
	aes_intin[1] = y;
	aes_addrin[0] = (long)tree;

	aes(&aes_params);

	return aes_intout[0];
}

int form_popup(OBJECT *tree, int x, int y)
{
	return(mt_form_popup(tree, x, y, aes_global));
}

int mt_form_wbutton(OBJECT *fo_btree, int fo_bobject, int fo_bclicks, INT16 *fo_bnxtobj, int whandle, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={63,3,2,1,0};
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

                    
	aes_intin[0] = fo_bobject;
	aes_intin[1] = fo_bclicks;
	aes_intin[2] = whandle;
	aes_addrin[0] = (long)fo_btree;

	aes(&aes_params);

	*fo_bnxtobj = aes_intout[1];
	return aes_intout[0];
}

int form_wbutton(OBJECT *fo_btree, int fo_bobject, int fo_bclicks, INT16 *fo_bnxtobj, int whandle)
{
	return(mt_form_wbutton(fo_btree, fo_bobject, fo_bclicks, fo_bnxtobj, whandle, aes_global));
}

int mt_form_wkeybd(OBJECT *fo_ktree, int fo_kobject, int fo_kobnext, int fo_kchar, 
					INT16 *fo_knxtobject, INT16 *fo_knxtchar, int whandle, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={64,4,3,1,0};
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

                    
	aes_intin[0] = fo_kobject;
	aes_intin[1] = fo_kchar;
	aes_intin[2] = fo_kobnext;
	aes_intin[3] = whandle;
	aes_addrin[0] =(long)fo_ktree;

	aes(&aes_params);

	*fo_knxtobject = aes_intout[1];
	*fo_knxtchar = aes_intout[2];
	return aes_intout[0];
}

int form_wkeybd(OBJECT *fo_ktree, int fo_kobject, int fo_kobnext, int fo_kchar, 
					INT16 *fo_knxtobject, INT16 *fo_knxtchar, int whandle)
{
	return(mt_form_wkeybd(fo_ktree, fo_kobject, fo_kobnext, fo_kchar, fo_knxtobject, fo_knxtchar, whandle, aes_global));
}

int mt_form_xdial(int fo_diflag, int fo_dilittlx, int fo_dilittly, int fo_dilittlw, 
					int fo_dilittlh, int fo_dibigx, int fo_dibigy, int fo_dibigw, 
					int fo_dibigh, void **flydial, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={51,9,1,1,0};
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

                    
	aes_intin[0] = fo_diflag;
	aes_intin[1] = fo_dilittlx;
	aes_intin[2] = fo_dilittly;
	aes_intin[3] = fo_dilittlw;
	aes_intin[4] = fo_dilittlh;
	aes_intin[5] = fo_dibigx;
	aes_intin[6] = fo_dibigy;
	aes_intin[7] = fo_dibigw;
	aes_intin[8] = fo_dibigh;
	aes_addrin[0] = (long)flydial;

	aes(&aes_params);

	return aes_intout[0];
}

int form_xdial(int fo_diflag, int fo_dilittlx, int fo_dilittly, int fo_dilittlw, 
					int fo_dilittlh, int fo_dibigx, int fo_dibigy, int fo_dibigw, 
					int fo_dibigh, void **flydial)
{
	return(mt_form_xdial(fo_diflag, fo_dilittlx, fo_dilittly, fo_dilittlw, fo_dilittlh, fo_dibigx, fo_dibigy, fo_dibigw, fo_dibigh, flydial,aes_global));
}

int mt_form_xdo(OBJECT *tree, int startob, INT16 *lastcrsr, XDO_INF *tabs, void *flydial, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={50,1,2,3,0};
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

                    
	aes_intin[0] = startob;
	aes_addrin[0] = (long)tree;
	aes_addrin[1] = (long)tabs;
	aes_addrin[2] = (long)flydial;

	aes(&aes_params);

	*lastcrsr = aes_intout[1];
	return aes_intout[0];
}

int form_xdo(OBJECT *tree, int startob, INT16 *lastcrsr, XDO_INF *tabs, void *flydial)
{
	return(mt_form_xdo(tree, startob, lastcrsr, tabs, flydial, aes_global));
}

int mt_form_xerr(long errcode, char *errfile, INT16 *global_aes)
{
	unsigned INT16 *i = (unsigned INT16 *)&errcode;
	static INT16 	aes_control[AES_CTRLMAX]={136,2,1,1,0};
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

                    
	aes_intin[0] = i[1];
	aes_intin[1] = i[0];
	aes_addrin[0] = (long)errfile;

	aes(&aes_params);

	return aes_intout[0];
}

int form_xerr(long errcode, char *errfile)
{
	return(mt_form_xerr(errcode, errfile, aes_global));
}
