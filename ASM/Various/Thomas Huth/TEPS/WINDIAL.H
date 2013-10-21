// *** Prototypen der Window-Dialog-Library ***

#ifndef __AES__
#include <aes.h>
#endif

/* Prototypen: */
int wdial_init(OBJECT *tree, char *title);
void wdial_close(int dwhndl);
void wdial_redraw(int dwhndl, OBJECT *tree, GRECT *redrwrect);
short wdial_formdo(int dwhndl, OBJECT *tree, short strt_fld, void (*msghndl)(int msgbf[]), long msec, void (*tmrhndlr)());
int wdial_popup(OBJECT *ptree, short *pitem, short popupx, short popupy, void (*msghndlr)(int msgbf[]), unsigned long msec, void (*tmrhndlr)());
int wdial_popupbutn(OBJECT *buttree, int butnr, OBJECT *ptree, int *pitem);
