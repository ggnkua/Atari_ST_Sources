/* ****** TTX_AES.H: Prototypes for TTX_AES.C ****** */

#ifndef _TTX_AES_H
#define _TTX_AES_H

#include <aes.h>

void wdial_redraw(int dwhndl, OBJECT *tree, GRECT *redrwrect);
void redraw_objc(short obnum);
void sendmesag(short dest_id, short msgtype);
short fselector(char *pname, char *fname, int *retbut, char *fstitle);
int wdial_popupbutn(OBJECT *buttree, int butnr, OBJECT *ptree, int *pitem);

#endif
