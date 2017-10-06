/*
 *	Aes menu library interface
 *
 *	++jrb	bammi@cadence.com
 *	modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cf -- felsch@tu-harburg.de
 * modified: ol -- olivier.landemarre.free.fr
 */
#include "mgem.h"


int mt_menu_attach(int me_flag, OBJECT *me_tree, int me_item, MENU *me_mdata, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={37,2,1,2,0};
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

                    
	aes_intin[0] = me_flag;
	aes_intin[1] = me_item;
	aes_addrin[0] = (long)me_tree;
	aes_addrin[1] = (long)me_mdata;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef menu_attach
#undef menu_attach
#endif
int menu_attach(int me_flag, OBJECT *me_tree, int me_item, MENU *me_mdata)
{
	return(mt_menu_attach( me_flag, me_tree, me_item, me_mdata, aes_global));
}


int mt_menu_bar(void *Tree, int ShowFlag, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={30,1,1,1,0};
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

                    
	aes_intin[0] = ShowFlag;
	aes_addrin[0] = (long)Tree;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef menu_bar
#undef menu_bar
#endif
int menu_bar(void *Tree, int ShowFlag)
{
	return(mt_menu_bar(Tree, ShowFlag, aes_global));
}

int mt_menu_click(int click, int setit, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={37,2,1,0,0};
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

                    
	aes_intin[0] = click;
	aes_intin[1] = setit;

	aes(&aes_params);

	return aes_intout[0];
} 

#ifdef menu_click
#undef menu_click
#endif
int menu_click(int click, int setit)
{
	return(mt_menu_click( click, setit, aes_global));
}


int mt_menu_icheck(void *Tree, int Item, int CheckFlag, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={31,2,1,1,0};
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

                    
	aes_intin[0] = Item;
	aes_intin[1] = CheckFlag;
	aes_addrin[0] = (long)Tree;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef menu_icheck
#undef menu_icheck
#endif
int menu_icheck(void *Tree, int Item, int CheckFlag)
{
	return(mt_menu_icheck(Tree, Item, CheckFlag, aes_global));
}


int mt_menu_ienable(void *Tree, int Item, int EnableFlag, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={32,2,1,1,0};
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

                    
	aes_addrin[0] = (long)Tree;
	aes_intin[0] = Item;
	aes_intin[1] = EnableFlag;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef menu_ienable
#undef menu_ienable
#endif
int menu_ienable(void *Tree, int Item, int EnableFlag)
{
	return(mt_menu_ienable(Tree, Item, EnableFlag,aes_global));
}


int mt_menu_istart(int me_flag, OBJECT *me_tree, int me_imenu, int me_item, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={38,3,1,1,0};
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

                    
	aes_intin[0] = me_flag;
	aes_intin[1] = me_imenu;
	aes_intin[2] = me_item;
	aes_addrin[0] = (long)me_tree;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef menu_istart
#undef menu_istart
#endif
int menu_istart(int me_flag, OBJECT *me_tree, int me_imenu, int me_item)
{
	return(mt_menu_istart(me_flag, me_tree, me_imenu, me_item, aes_global));
}

int mt_menu_popup(MENU *me_menu, int me_xpos, int me_ypos, MENU *me_mdata, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={36,2,1,2,0};
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

                    
	aes_intin[0] = me_xpos;
	aes_intin[1] = me_ypos;
	aes_addrin[0] = (long)me_menu;
	aes_addrin[1] = (long)me_mdata;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef menu_popup
#undef menu_popup
#endif
int menu_popup(MENU *me_menu, int me_xpos, int me_ypos, MENU *me_mdata)
{
	return(mt_menu_popup(me_menu, me_xpos, me_ypos, me_mdata, aes_global));
}


int mt_menu_register(int ApId, char *MenuText, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={35,1,1,1,0};
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

                    
	aes_intin[0] = ApId;
	aes_addrin[0] = (long)MenuText;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef menu_register
#undef menu_register
#endif
int menu_register(int ApId, char *MenuText)
{
	return(mt_menu_register(ApId, MenuText, aes_global));
}


int mt_menu_settings(int me_flag, MN_SET *me_values, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={39,1,1,1,0};
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

                    
	aes_intin[0] = me_flag;
	aes_addrin[0] = (long)me_values;

	aes(&aes_params);

	return aes_intout[0];
}	  

#ifdef menu_settings
#undef menu_settings
#endif
int menu_settings(int me_flag, MN_SET *me_values)
{
	return(mt_menu_settings(me_flag, me_values, aes_global));
}


int mt_menu_text(void *Tree, int Item, char *Text, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={34,1,1,2,0};
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

                    
	aes_addrin[0] = (long)Tree;
	aes_addrin[1] = (long)Text;
	aes_intin[0] = Item;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef menu_text
#undef menu_text
#endif
int menu_text(void *Tree, int Item, char *Text)
{
	return(mt_menu_text(Tree, Item, Text, aes_global));
}


int mt_menu_tnormal(void *Tree, int Item, int NormalFlag, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={33,2,1,1,0};
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

                    
	aes_addrin[0] = (long)Tree;
	aes_intin[0] = Item;
	aes_intin[1] = NormalFlag;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef menu_tnormal
#undef menu_tnormal
#endif
int menu_tnormal(void *Tree, int Item, int NormalFlag)
{
	return(mt_menu_tnormal(Tree, Item, NormalFlag, aes_global));
}

int mt_menu_unregister(int id, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={36,1,1,0,0};
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
                    
	aes_intin[0] = id;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef menu_unregister
#undef menu_unregister
#endif
int menu_unregister(int id)
{
	return(mt_menu_unregister(id, aes_global));
}
