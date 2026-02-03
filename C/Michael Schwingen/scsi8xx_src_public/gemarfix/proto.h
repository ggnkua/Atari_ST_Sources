#ifndef _PROTO_H
#define _PROTO_H

#include <portab.h>

/* scsidrv.c */
extern LONG sd_init(void);

/* printf.c */
extern void bprintf(const char*,...);

/* cookie.s */
extern void *GetSCSICookie(void);

#endif