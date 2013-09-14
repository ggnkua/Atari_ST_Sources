/*
 * gemout.h -- Miscellaneous definitions of GEM objects and archives;
 * mostly for the benefit of ST-native 'file' program.
 *
 * Copyright (c) 1986-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */
#define GEMNSEG		4		/* # of ST segments */
#define GEMOMAGIC	0x601A		/* ST magic number */

/* GEM object header */
struct gemohdr {
	short	g_magic;		/* Magic number */
	long	g_ssize[GEMNSEG];	/* Segment sizes */
	long	g_reserved;		/* Reserved, always zero */
	long	g_entry;
	short	g_relflag;		/* != 0 if stripped */
};

#define GO_TEXT		0		/* Text segment */
#define GO_DATA		1		/* Data segment */
#define GO_BSS		2		/* Block storage segment */
#define GO_SYM		3		/* Symbol table */
/*
 * GEM object symbol structure
 */
struct gemsym {
	char gs_name[8];
	int gs_type;
	long gs_value;
};

/*
 * GEM archive format,
 * with DRI modification of additional two bytes to header.
 */
#define GEMAMAGIC	0177545

struct gemahdr {
	char	ga_name[14];
	long	ga_date;
	char	ga_uid;
	char	ga_gid;
	short	ga_mode;
	long	ga_size;
	short	ga_fill;
};

/* End of gemout.h */
