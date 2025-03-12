/*
 * Header file for my Dynamic memory system..
 *
 *          Copyright 1993 Andrew L. Younger.
 */
#define NUMBLOCKS 100

/* Disk.c */
/* extern short LoadFile(char *filename, unsigned short unpack); */
extern long Fsize(char *filename);

/* Unpack.s */
extern void IceUnpack(unsigned short *src, unsigned short *dst);
extern void AtmUnpack(unsigned short *src, unsigned short *dst);

/* Dynamic.c */
extern void InitDynamic(void);
extern void ExitDynamic(void);
extern void InitMemMan(unsigned short *mem);
extern short AllocMem(unsigned long sizemem);
extern short *WhereMem(unsigned short handle);
extern void ResizeMem(unsigned short handle, unsigned long newsize);
extern void FreeMem(unsigned short handle);
extern long SizeMem(unsigned short handle);
extern void MoveMem(short *dst,short *src,long size);
extern void ClearMem(unsigned short handle);