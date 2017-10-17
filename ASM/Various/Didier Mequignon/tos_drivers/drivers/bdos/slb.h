#ifndef _SLB_H
#define _SLB_H

#define MAXPD 32

#define SLB_HEADER_MAGIC 0x70004afcL

#define SLB_INIT_STACK	1024L

typedef struct shared_lib SHARED_LIB;
typedef struct slb_head SLB_HEAD;

typedef long (*SLB_EXEC)(SHARED_LIB *sl, long fn, short nargs, ...);
typedef long (*SLB_FUNC)(long pid, long fn, short nargs, ...);

/* The file header of a shared library */
struct slb_head
{
	long		slh_magic;	/* Magic value (0x70004afc) */
	char		*slh_name;	/* Name of the library */
	long		slh_version;	/* Version number */
	long		slh_flags;	/* Flags, currently 0L and unused */
	long		(*slh_slb_init)(void);
					/* Pointer to init()-function */
	void		(*slh_slb_exit)(void);
					/* Pointer to exit()-function */
	long		(*slh_slb_open)(PD *b);
					/* Pointer to open()-function */
	long		(*slh_slb_close)(PD *b);
					/* Pointer to close()-function */
	char		**slh_names;	/* Pointer to functions names, or 0L */
	long		slh_reserved[8];/* Currently 0L and unused */
	long		slh_no_funcs;	/* Number of functions */
	SLB_FUNC	slh_functions[0];
					/* The function pointers */
};

/*
 * Shared library structure, contents is completely _private_, i.e. MUST NOT
 * be used in applications
 */
struct shared_lib
{
	SHARED_LIB	*slb_next; /* Pointer to next element in list */
	SLB_HEAD	*slb_head;	 /* Pointer to library header */
	long		slb_version;	 /* Version number */
	short		slb_used;      /* Usage counter */
	PD		*slb_users[MAXPD]; /* List of using processes */
	SLB_EXEC	*slb_exec;   /* Pointer to execution function */
	long		slb_region;    /* Region of this structure */
	char		slb_name[1];   /* last element */
};

long xslbopen(char *name, char *path, long min_ver, SHARED_LIB **sl, SLB_EXEC *fn);
long xslbclose(SHARED_LIB *sl);

# endif /* _SLB_H */
