/* NEW_AES.C
 *
 * Librairie pour les nouveaux appels AES >= 3.30
 *
 * Janvier 1993 par Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
 * 
 * Adaptation par Claude ATTARD pour ST Mag - Mars 94
 */

#include "new_aes.h"

typedef struct 
{
	int *contrl;
	int *global;
	int *intin;
	int *intout;
	void **addrin;
	void **addrout;
} AESPARBLK;

AESPARBLK _AesParBlk;			/* Le bloc de paramätres pour l'AES */

void CallAes(AESPARBLK *APB);	/* L'appel des fonctions en assembleur */

static void do_aes(void)
/* PrÇparation des paramätres AES */
{
	_AesParBlk.contrl=_GemParBlk.contrl;
	_AesParBlk.global=_GemParBlk.global;
	_AesParBlk.intin=_GemParBlk.intin;
	_AesParBlk.intout=_GemParBlk.intout;
	_AesParBlk.addrin=_GemParBlk.addrin;
	_AesParBlk.addrout=_GemParBlk.addrout;
	CallAes(&_AesParBlk);
} /* do_aes */


/* Les nouvelles fonctions */

int menu_popup(MENU *me_menu,int me_xpos,int me_ypos,MENU *me_mdata)
{
	_GemParBlk.contrl[0]=36;
	_GemParBlk.contrl[1]=2;
	_GemParBlk.contrl[2]=1;
	_GemParBlk.contrl[3]=2;
	_GemParBlk.contrl[4]=0;

	_GemParBlk.intin[0]=me_xpos;
	_GemParBlk.intin[1]=me_ypos;

	_GemParBlk.addrin[0]=me_menu;
	_GemParBlk.addrin[1]=me_mdata;

	do_aes();
	return(_GemParBlk.intout[0]);
} /* menu_popup */

int menu_attach(int me_flag,OBJECT *me_tree,int me_item,MENU *me_mdata)
{
	_GemParBlk.contrl[0]=37;
	_GemParBlk.contrl[1]=2;
	_GemParBlk.contrl[2]=1;
	_GemParBlk.contrl[3]=2;
	_GemParBlk.contrl[4]=0;

	_GemParBlk.intin[0]=me_flag;	
	_GemParBlk.intin[1]=me_item;

	_GemParBlk.addrin[0]=me_tree;
	_GemParBlk.addrin[1]=me_mdata;

	do_aes();
	return(_GemParBlk.intout[0]);
} /* menu_attach */

int menu_istart(int me_flag,OBJECT *me_tree,int me_imenu,int me_item)
{
	_GemParBlk.contrl[0]=38;
	_GemParBlk.contrl[1]=3;
	_GemParBlk.contrl[2]=1;
	_GemParBlk.contrl[3]=1;
	_GemParBlk.contrl[4]=0;

	_GemParBlk.intin[0]=me_flag;
	_GemParBlk.intin[1]=me_imenu;
	_GemParBlk.intin[2]=me_item;

	_GemParBlk.addrin[0]=me_tree;

	do_aes();
	return(_GemParBlk.intout[0]);
} /* menu_istart */

int menu_settings(int me_flag,MN_SET *me_values)
{
	_GemParBlk.contrl[0]=39;
	_GemParBlk.contrl[1]=1;
	_GemParBlk.contrl[2]=1;
	_GemParBlk.contrl[3]=1;
	_GemParBlk.contrl[4]=0;

	_GemParBlk.intin[0]=me_flag;

	_GemParBlk.addrin[0]=me_values;
	
	do_aes();
	return(_GemParBlk.intout[0]);
} /* menu_settings */

