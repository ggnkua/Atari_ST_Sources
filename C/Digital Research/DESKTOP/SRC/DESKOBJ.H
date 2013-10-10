#ifndef DESKOBJ_H

#define DESKOBJ_H

EXTERN	VOID obj_init(VOID);
EXTERN	WORD obj_walloc(WORD x, WORD y, WORD w, WORD h);
EXTERN	VOID obj_wfree(WORD obj, WORD x, WORD y, WORD w, WORD h);
EXTERN	WORD obj_ialloc(WORD wparent, WORD x, WORD y, WORD w, WORD h);

#endif
