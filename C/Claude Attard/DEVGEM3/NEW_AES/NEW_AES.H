/* NEW_AES.H
 *
 * D‚finitions et prototypages des nouvelles fonctions AES >= 3.30
 *
 * Janvier 1993 par Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
 * 
 * Adaptation par Claude ATTARD pour ST Mag - Mars 94
 */

#if !defined( __AES__ )
#include <aes.h>
#endif

typedef struct
{
	OBJECT *mn_tree;
	int mn_menu;
	int mn_item;
	int mn_scroll;
} MENU;

typedef struct
{
	long Display;
	long Drag;
	long Delay;
	long Speed;
	int Height;
} MN_SET;

int menu_popup(MENU *me_menu,int me_xpos,int me_ypos,MENU *me_mdata);
int menu_attach(int me_flag,OBJECT *me_tree,int me_item,MENU *me_mdata);
int menu_istart(int me_flag,OBJECT *me_tree,int me_imenu,int me_item);
int menu_settings(int me_flag,MN_SET *me_values);
