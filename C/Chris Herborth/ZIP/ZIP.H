/* This is a dummy zip.h to allow crypt.c from Zip to compile for UnZip */

#ifndef __zip_h   /* don't include more than once */
#define __zip_h

#include "unzip.h"

#define decrypt_member decrypt  /* for compatibility with zcrypt20 */
#define local static
#define CRC32(c, b)    (crc_32_tab[((int)(c) ^ (b)) & 0xff] ^ ((c) >> 8))

#ifdef FUNZIP
   extern ulg near crc_32_tab[];
#else
   extern ulg *crc_32_tab;
#endif

#endif /* !__zip_h */
