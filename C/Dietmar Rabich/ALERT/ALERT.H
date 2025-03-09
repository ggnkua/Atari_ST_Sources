/* Headerdatei zu ALERT */

#ifndef	__ALERT
#define	__ALERT

#include <aes.h>

BITBLK* BitblkCalculator(void);
int do_alert(BITBLK*, const char*,
             const char*, int);

#endif
