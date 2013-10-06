#ifndef DEFS_H
#define DEFS_H

/* Lets you select between bigendian and little endian target */
#define BIGENDIAN

/* Global typedefs */
typedef unsigned char uchar;
typedef unsigned short ushort;
typedef unsigned int uint;
typedef unsigned long ulong;
typedef char bool;

#define true 0xff
#define false 0x00


#define BYTESWAP(a) ((a>>8)&0x00ff)|((a<<8)&0xff00);

#endif
