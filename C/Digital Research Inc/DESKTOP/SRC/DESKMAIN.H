#ifndef DESKMAIN_H

#define DESKMAIN_H

EXTERN	VOID copy_icon(LONG dst_tree, LONG tree, WORD dst_icon, WORD icon);
EXTERN	VOID fix_wins(VOID);
EXTERN	VOID desk_wait(WORD turnon);
EXTERN	VOID desk_all(WORD sort);
EXTERN	ANODE *i_find(WORD wh, WORD item, FNODE **ppf, WORD *pisapp);
EXTERN	VOID men_list(LONG mlist, BYTE *dlist, WORD enable);
EXTERN	VOID men_update(LONG tree);
EXTERN	WORD do_deskmenu(WORD item);
EXTERN	WORD do_filemenu(WORD item);
EXTERN	WORD do_viewmenu(WORD item);
EXTERN	WORD do_optnmenu(WORD item);
EXTERN	WORD hndl_button(WORD clicks, WORD mx, WORD my, WORD button, WORD keystate);
EXTERN	WORD hndl_kbd(WORD thechar);
EXTERN	WORD hndl_menu(WORD title, WORD item);
EXTERN	VOID hot_close(WORD wh);
EXTERN	WORD hndl_msg(VOID);
EXTERN	VOID cnx_put(VOID);
EXTERN	VOID cnx_open(WORD idx);
EXTERN	VOID cnx_get(VOID);
EXTERN	WORD gemain(VOID);

#endif
