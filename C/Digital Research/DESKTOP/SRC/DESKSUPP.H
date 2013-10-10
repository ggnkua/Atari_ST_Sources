#ifndef DESKSUP_H

#define DESKSUPP_H

EXTERN	VOID desk_clear(WORD wh);
EXTERN	VOID desk_verify(WORD wh, WORD changed);
EXTERN	WORD do_wredraw(WORD w_handle, WORD xc, WORD yc, WORD wc, WORD hc);
EXTERN	VOID get_xywh(OBJECT olist[], WORD obj, WORD *px, WORD *py, WORD *pw, WORD *ph);
EXTERN	ICONBLK  *get_spec(OBJECT olist[], WORD obj);
EXTERN	VOID do_xyfix(WORD *px, WORD *py);
EXTERN	VOID do_wopen(WORD new_win, WORD wh, WORD curr, WORD x, WORD y, WORD w, WORD h);
EXTERN	VOID do_wfull(WORD wh);
EXTERN	WORD do_diropen(WNODE *pw, WORD new_win, WORD curr_icon, WORD drv, BYTE *ppath, BYTE *pname, BYTE *pext, GRECT *pt, WORD redraw);
EXTERN	WORD do_aopen(ANODE *pa, WORD isapp, WORD curr, WORD drv, BYTE *ppath, BYTE *pname);
EXTERN	WORD do_dopen(WORD curr);
EXTERN	VOID do_fopen(WNODE *pw, WORD curr, WORD drv, BYTE *ppath, BYTE *pname, BYTE *pext, WORD chkall, WORD redraw);
EXTERN	WORD do_open(WORD curr);
EXTERN	WORD do_info(WORD curr);
#if I8086
EXTERN	VOID romerr(WORD curr);
#endif
EXTERN	VOID do_format(WORD curr);
EXTERN	VOID do_chkall(WORD redraw);

#endif
