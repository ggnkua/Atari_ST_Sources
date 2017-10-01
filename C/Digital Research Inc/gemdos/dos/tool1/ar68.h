/*
	Copyright 1983
	Alcyon Corporation
	8716 Production Ave.
	San Diego, CA  92121

	@(#)ar68.h	1.5    11/28/83  REGULUS 4.1
*/

#define LIBMAGIC	(unsigned short)0xff65
#define LIBRMAGIC	(unsigned short)0xff66
#define LIBHDSIZE	sizeof( struct libhdr )
#define LIBNSIZE	14

struct libhdr {
	char lfname[LIBNSIZE];
	long lmodti;
	char luserid;
	char lgid;
	unsigned short lfimode;
	long lfsize;
#ifdef DRI
	short ljunk;
#endif
};
