/*
 *	Aes menu library interface
 *
 *	++jrb	bammi@cadence.com
 *	modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cf -- felsch@tu-harburg.de
 */
#include "gem.h"


int menu_attach(int me_flag, OBJECT *me_tree, int me_item, MENU *me_mdata)
{
	aes_intin[0] = me_flag;
	aes_intin[1] = me_item;
	aes_addrin[0] = (long)me_tree;
	aes_addrin[1] = (long)me_mdata;
	aes_control[0] = 37;
	aes_control[1] = 2;
	aes_control[2] = 1;
	aes_control[3] = 2;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int menu_bar(void *Tree, int ShowFlag)
{
	aes_intin[0] = ShowFlag;
	aes_addrin[0] = (long)Tree;
	aes_control[0] = 30;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int menu_click(int click, int setit)
{
	aes_intin[0] = click;
	aes_intin[1] = setit;
	aes_control[0] = 37;
	aes_control[1] = 2;
	aes_control[2] = 1;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
} 


int menu_icheck(void *Tree, int Item, int CheckFlag)
{
	aes_intin[0] = Item;
	aes_intin[1] = CheckFlag;
	aes_addrin[0] = (long)Tree;
	aes_control[0] = 31;
	aes_control[1] = 2;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int menu_ienable(void *Tree, int Item, int EnableFlag)
{
	aes_addrin[0] = (long)Tree;
	aes_intin[0] = Item;
	aes_intin[1] = EnableFlag;
	aes_control[0] = 32;
	aes_control[1] = 2;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int menu_istart(int me_flag, OBJECT *me_tree, int me_imenu, int me_item)
{
	aes_intin[0] = me_flag;
	aes_intin[1] = me_imenu;
	aes_intin[2] = me_item;
	aes_addrin[0] = (long)me_tree;
	aes_control[0] = 38;
	aes_control[1] = 3;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int menu_popup(MENU *me_menu, int me_xpos, int me_ypos, MENU *me_mdata)
{
	aes_intin[0] = me_xpos;
	aes_intin[1] = me_ypos;
	aes_addrin[0] = (long)me_menu;
	aes_addrin[1] = (long)me_mdata;
	aes_control[0] = 36;
	aes_control[1] = 2;
	aes_control[2] = 1;
	aes_control[3] = 2;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int menu_register(int ApId, char *MenuText)
{
	aes_intin[0] = ApId;
	aes_addrin[0] = (long)MenuText;
	aes_control[0] = 35;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int menu_settings(int me_flag, MN_SET *me_values)
{
	aes_intin[0] = me_flag;
	aes_addrin[0] = (long)me_values;
	aes_control[0] = 39;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}	  


int menu_text(void *Tree, int Item, char *Text)
{
	aes_addrin[0] = (long)Tree;
	aes_addrin[1] = (long)Text;
	aes_intin[0] = Item;
	aes_control[0] = 34;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 2;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int menu_tnormal(void *Tree, int Item, int NormalFlag)
{
	aes_addrin[0] = (long)Tree;
	aes_intin[0] = Item;
	aes_intin[1] = NormalFlag;
	aes_control[0] = 33;
	aes_control[1] = 2;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}


int menu_unregister(int id)
{
	aes_intin[0] = id;
	aes_control[0] = 36;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}
