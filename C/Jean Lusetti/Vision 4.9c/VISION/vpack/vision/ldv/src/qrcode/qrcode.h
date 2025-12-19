#ifndef __QRCODE_H
#define __QRCODE_H


#ifndef MFDB
#include <vdi.h>
#endif

/* Interface to QRCODE.LIB library */
/* Provided by Guillaume Tello     */
typedef struct _QRINFO
{
  unsigned long  size ;
  unsigned short version ;
  unsigned short w ;
  unsigned short h ;
}
QRINFO, *PQRINFO ;

/* In QRCODE.LIB */
long QRinfo(char* text, long level, QRINFO* qrinfo) ;
long QRcode(void* buffer, MFDB* src) ;

/* Little macro to test return value of QRCODE lib */
#define QRF_OK(x) ((x)==0L) 

#endif
