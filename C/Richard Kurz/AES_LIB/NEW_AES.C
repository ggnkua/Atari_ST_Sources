/* NEW_AES.C
 *
 * Libary fÅr die neuen AES-Funktionen ab AES 4.0 MultiTOS 0.82û
 *
 * Januar 1993 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
 * Fido 2:241/7232.5
 * FÅr's TOS-Magazin
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

AESPARBLK _AesParBlk;			/* Der Parameterblock fÅr's AES 	*/

void CallAes(AESPARBLK *APB);	/* Trap-Aufruf siehe Assembler-Teil	*/

static void do_aes(void)
/* öbergiebt die Parameter an das AES	*/
{
	_AesParBlk.contrl=_GemParBlk.contrl;
	_AesParBlk.global=_GemParBlk.global;
	_AesParBlk.intin=_GemParBlk.intin;
	_AesParBlk.intout=_GemParBlk.intout;
	_AesParBlk.addrin=_GemParBlk.addrin;
	_AesParBlk.addrout=_GemParBlk.addrout;
	CallAes(&_AesParBlk);
}/* do_aes */


/* Die neuen Funktionen	*/

int appl_search(int ap_smode,char *ap_sname,int *ap_stype,int *ap_sid)
{
    _GemParBlk.contrl[0]=18;
    _GemParBlk.contrl[1]=1;
    _GemParBlk.contrl[2]=3;
    _GemParBlk.contrl[3]=1;
    _GemParBlk.contrl[4]=0;

    _GemParBlk.intin[0]=ap_smode;
    _GemParBlk.addrin[0]=ap_sname;

	do_aes();

    *ap_stype=_GemParBlk.intout[1];
    *ap_sid=_GemParBlk.intout[2];

    return(_GemParBlk.intout[0]);
} /* appl_search */

int appl_getinfo(int ap_gtype,int *ap_gout1, int *ap_gout2, int *ap_gout3, int *ap_gout4)
{
    _GemParBlk.contrl[0]=130;
    _GemParBlk.contrl[1]=1;
    _GemParBlk.contrl[2]=5;
    _GemParBlk.contrl[3]=0;
    _GemParBlk.contrl[4]=0;

    _GemParBlk.intin[0]=ap_gtype;

	do_aes();

    *ap_gout1=_GemParBlk.intout[1];
    *ap_gout2=_GemParBlk.intout[2];
    *ap_gout3=_GemParBlk.intout[3];
    *ap_gout4=_GemParBlk.intout[4];

    return(_GemParBlk.intout[0]);
} /* appl_getinfo */

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
}/* menu_popup */

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
}/* menu_attach */

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

int rsrc_rcfix(RSHDR *rc_header)
{
	_GemParBlk.contrl[0]=115;
    _GemParBlk.contrl[1]=0;
    _GemParBlk.contrl[2]=1;
    _GemParBlk.contrl[3]=1;
    _GemParBlk.contrl[4]=0;

    _GemParBlk.addrin[0]=rc_header;

	do_aes();
    return(_GemParBlk.intout[0]);
} /* rsrc_rcfix */
