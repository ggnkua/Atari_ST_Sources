#define	VERSION			0x102		/* Versionsnummer */
#define	START_BLOCK		1
#define	MAX_BLOCKS		256

#undef	STAT			/* print CACHE-Statistics */

#define	TMP_FILE		"C:\\VMEM_TMP.$$$"
#define	DIR_FILE		"VMEM_TMP$$$"

#define	EMPTY_ENTRY		0xffff		/* illegale Seiten-Nr. */
#define	CACHE_EMPTY		0
#define	_NULL			(0L)		/* fÅr V_ADR */
#define	NIL				(-1)		/* fÅr Memory Deskriptor */
#define	FREE_MD			0			/* freier MD */

typedef int				MD;			/* Memory Deskriptor */
typedef unsigned char	BYTE;
typedef unsigned int	WORD;
typedef unsigned int	VPAGE;
typedef unsigned int	CPAGE;
typedef unsigned int	SECTOR;
typedef unsigned long	ULONG;
typedef unsigned long	V_ADR;

#define	MEMORY	struct memory
#define	V_INFO	struct v_info
#define	TAB		struct tab
#define	SEQ		struct seq

#define	SIZE_1024		0	/* Page-Types */
#define	SIZE_2048		1
#define	SIZE_4096		2
#define	SIZE_8192		3
#define	SIZE_16384		4
#define	SIZE_32768		5

#define	NEW				0	/* Flags */
#define	OLD				1
#define	FILE			0
#define	CACHE			2
#define	FREE			0
#define	USED			4

#define	CACHE_FREE		0	/* Cache-Flags */
#define	CACHE_READ		2
#define	CACHE_WRITE		4

/*************************/
/* Include-Definitionen: */
/*************************/

/**********************/
/* #include <stdio.h> */
/**********************/

typedef unsigned long   size_t;
#define   NULL   ( (void*) 0L )
int     printf (const char *format, ...);

/***********************/
/* #include <stdlib.h> */
/***********************/

void    exit (int status);

/***********************/
/* #include <string.h> */
/***********************/

typedef unsigned long    size_t;
void    *memcpy (void *dest, const void *src, size_t len);
void    *memset (void *ptr, int val, size_t len);
int		strncmp (char *s1, char *s2, size_t maxlen);

/********************/
/* #include <tos.h> */
/********************/

typedef struct
{
    unsigned long   b_free;
    unsigned long   b_total;
    unsigned long   b_secsiz;
    unsigned long   b_clsiz;
} DISKINFO;

typedef struct
{
	int recsiz;		/* Bytes pro Sektor */
	int clsiz;		/* Sektoren pro Cluster */
	int clsizb;		/* Bytes pro Cluster */
	int rdlen;		/* VerzeichnislÑnge */
	int fsiz;		/* LÑnge der FAT */
	int fatrec;		/* Start der 2. FAT */
	int datrec;		/* 1. freier Sektor */
	int numcl;		/* Gesamtzahl an Cluster */
	int bflags;		/* Flags */
} BPB ;

#define Malloc malloc
#define Mfree free

void    *Malloc (long number);
int     Mfree (void *block);
int     Fopen (const char *filename, int mode);
int     Fcreate (const char *filename, int attr);
int     Fclose (int handle);
int     Fdelete (const char *filename);
long    Fread (int handle, long count, void *buf);
long    Fwrite (int handle, long count, void *buf);
long    Fseek (long offset, int handle, int seekmode);
int     Dfree (DISKINFO *buf, int driveno);
long	Drvmap (void);
BPB		*Getbpb (int dev);
long	Rwabs (int rwflag, void *buff, int cnt, int recnr, int dev);

/***********************/
/* Makro-Definitionen: */
/***********************/

#define	DO_NOTHING
#define	MIN(a,b)		(((a) < (b)) ? (a) : (b))
#define	MAX(a,b)		(((a) > (b)) ? (a) : (b))

#define	MD_START(a)		md_array [(a)].start
#define	MD_COUNT(a)		md_array [(a)].count
#define	MD_NEXT(a)		md_array [(a)].next
#define	INSERT_MD(a,b,c,d)	{ MD_START (a) = b; \
							MD_COUNT (a) = c;   \
							MD_NEXT (a) = d; }
#define	DELETE_MD(a)		{ MD_START (a) = FREE_MD; \
							MD_COUNT (a) = 0;         \
							MD_NEXT (a) = NIL; }

#define	NEW_FLAG(a)		(flags [a] & 1)
#define	WHERE_FLAG(a)	(flags [a] & 2)

#define	INSIDE(a,b,c)	(((a) >= (b)) && ((a) <= (c)))
#define	OUTSIDE(a,b,c)	(((a) < (b)) || ((a) > (c)))

#define	MALLOC(a,b,c)	{ if (((a) = (b *) Malloc (sizeof(b) * (long) (c))) == NULL) \
							return (OUT_OF_MEMORY); }

#define	PAGE(a)			((a) >> offset_bits)
#define	OFFSET(a)		((a) & offset_mask)
#define	GET_PAGE(a)		((WORD) (PAGE (a)))
#define	GET_OFFSET(a)	((WORD) (OFFSET (a)))
#define	GET_COUNT(a)	((WORD) ((OFFSET (a)) ? (PAGE (a) + 1) : PAGE (a)))
#define	PAGE_TO_ADDR(a)	(((long) (a)) << offset_bits)

#define	ACCESSED(a)		{ cache_age [a] = lru_count++; }

#define	CACHE_ADDRESS(a)	((BYTE *) (cache + PAGE_TO_ADDR (a)))

#define	CACHE_TO_FILE(a)	flags [a] &= (~CACHE)
#define	FILE_TO_CACHE(a)	flags [a] |= CACHE
#define	MAKE_OLD(a)			flags [a] |= OLD
#define	UPDATE_FLAG(a,b)	{ if (b > cache_flags [a])       \
								{ MAKE_OLD (cache_page [a]); \
								cache_flags [a] = b; } }
#define	SET_FLAG(a,b)		cache_flags [a] = b

#define	INIT_CACHE(a)		memset ((a), info.fill_value, info.page_size)
#define	FILL_CACHE(a,b)		memset ((a), (b), info.page_size)
#define	COPY_CACHE(a,b)		memcopy ((a), (b), info.page_size)
#define	SWAP_CACHE(a,b)		memswap ((a), (b), info.page_size)

#define	ALLOC_CACHE(a,b,c)	{ cache_flags [a] = b; cache_page [a] = c; }
#define	FREE_CACHE(a)		{ cache_flags [a] = CACHE_FREE; \
							cache_page [a] = CACHE_EMPTY; }

#define	FSEEK(a)			Fseek (PAGE_TO_ADDR ((a)-1), tmp_handle, 0)
#define	FREAD(a,b)			Fread (tmp_handle, (a), (b))
#define	FWRITE(a,b)			Fwrite (tmp_handle, (a), (b))

#define	READ_SECTOR(a,b,c)	{ if (Rwabs (0, (a), (b), (c), drive) < 0) \
							{ printf ("READ-Error $%lx $%x $%x!!\n", (a), (b), (c)); vm_close (); exit (5); } }
#define	WRITE_SECTOR(a,b,c)	{ if (Rwabs (1, (a), (b), (c), drive) < 0) \
							{ printf ("WRITE-Error $%lx $%x $%x!!\n", (a), (b), (c)); vm_close (); exit (6); } }

/************************/
/* Funktions-Meldungen: */
/************************/

/* vm_config: */

#define	OK					0
#define	WRONG_CACHE_SIZE	-256
#define	WRONG_PAGE_TYPE		-257
#define	OUT_OF_MEMORY		-258
#define	FILE_ERROR			-259
#define	ILLEGAL_DRIVE		-260
#define	ILLEGAL_FATSIZE		-265

/* vm_free: */

#define	NOT_OK				-261

/* vm_fill / vm_copy / vm_load / vm_save / vm_read / vm_write: */

#define	ILLEGAL_ADDRESS		-262
#define	ILLEGAL_COUNT		-263
#define	ILLEGAL_MODE		-264

/************************/
/* Funktions-Parameter: */
/************************/

#define	DRIVE_C				3	/* vm_config */
#define	DRIVE_D				4
#define	DRIVE_E				5

#define	NORMAL_MODE			0	/* vm_read / vm_write */
#define	BURST_MODE			1

#define	READ_MODE			CACHE_READ	/* vm_address */
#define	WRITE_MODE			CACHE_WRITE

/***************/
/* Strukturen: */
/***************/

V_INFO
{
	WORD	version;		/* Versionsnummer */

	WORD	count_page;		/* Maximalanzahl an Seiten */

	WORD	count_blocks;	/* Maximale Anzahl an Blîcken */
	WORD	free_blocks;	/* Anzahl der noch verfÅgbaren Blîcke */

	int		fill_value;		/* FÅllwert */

	long	cache_size;		/* Grîûe des Caches in Bytes */
	WORD	cache_count;	/* Grîûe des Caches in Seiten */

	long	page_size;		/* Grîûe einer Seite in Bytes */

	long	max_size;		/* Maximalgrîûe des virtuellen Speichers */
	long	max_alloc;		/* Maximalgrîûe eines einzelnen Blocks */

	int		drive_no;		/* TMP-Laufwerk (A=1, B=2, C=3, ...) */
	long	drive_free;		/* freier Speicher auf dem TMP-Laufwerk */
};

TAB
{
	WORD	version;
	WORD	count_page;
	WORD	cache_size;
	WORD	page_type;
	int		fill_value;
	int		drive_no;
};

MEMORY
{
	WORD	start;			/* Nr. der ersten Seite */
	WORD	count;			/* Anzahl der belegten Seiten */
	MD		next;			/* Index des Nachfolgers bzw. -1 */
};

SEQ
{
	WORD	count;			/* Anzahl der aufeinanderfolgenden Seiten */
	WORD	cachepage;		/* Position der ersten Seite im Cache */
	WORD	vmempage;		/* erste Seite dieser Sequenz */
};

/***************/
/* Prototypen: */
/***************/

/* VMEM.C: */

int		vm_config	(TAB *parameter);
void	vm_close	(void);
V_INFO	*vm_info	(void);
void	vm_clrcache	(void);

/* VM_ADDRE.C: */

char	*vm_address		(V_ADR address, long *window_size, int mode);
WORD	search_sequence	(VPAGE vmempage, VPAGE lastpage);

/* VM_FILL.C: */

long	vm_fill		(V_ADR address, long count, int value);

/* VM_COPY.C: */

long	vm_copy		(V_ADR source, V_ADR destination, long count);

/* VM_LOAD.C: */

long	vm_load		(V_ADR source, char *destination, long count);

/* VM_SAVE.C: */

long	vm_save		(char *source, V_ADR destination, long count);

/* VM_WRITE.C: */

long	vm_write	(int handle, long count, V_ADR source);

/* VM_READ.C: */

long	vm_read		(int handle, long count, V_ADR destination);

/* VM_ALLOC.C: */

V_ADR	vm_alloc	(long size);
int		vm_free		(V_ADR address);
void	md_delete	(MD before, MD pointer);
void	md_merge	(MD before, MD current, MD next);
MD		md_find		(VPAGE vmempage);

/* VSUBROUT.C: */

BYTE	*load_page		(VPAGE page, int flag);
void	save_page		(BYTE *block, VPAGE vmempage);
CPAGE	find_cache		(void);
void	read_page		(BYTE *buff, VPAGE vmempage);
void	write_page		(BYTE *buff, VPAGE vmempage);
int		init_pages		(VPAGE vmempage, WORD count);
void	cache_clr		(CPAGE cachepage, WORD count);
void	write_sequence	(CPAGE cachepage, WORD count, VPAGE vmempage);
void	read_sequence	(CPAGE cachepage, WORD count, VPAGE vmempage);
MD		get_free_md		(void);
int		alloc_sector	(VPAGE vmempage, WORD count);
void	free_sector		(VPAGE vmempage, WORD count);

/* VMEM_ASS.S: */

void	aging			(void);
CPAGE	get_oldest		(void);
CPAGE	search_cache	(VPAGE vmempage);
WORD	read_test		(VPAGE vmempage, WORD count);
WORD	write_test		(VPAGE vmempage, WORD count);
void	memcopy			(void *destination, void *source, long count);
/*void	memfill			(void *destination, int value, long count);*/
/*void	memswap			(void *destination, void *source, long count);*/

/**********************/
/* Externe Variablen: */
/**********************/

extern ULONG	*cache_age;
extern VPAGE	*cache_page;
extern SECTOR	*sector_no;
extern BYTE		*cache_flags, *flags;
extern BYTE		*cache, *buffer;
extern BPB		*bpb_block;
extern WORD		offset_bits, offset_mask, free_mem, age_count,
				max_page, record_bits, cluster_bits, sector_mask,
				size_bits, cluster_size, sectors, drive;
extern ULONG	lru_count;
extern V_INFO	info;
extern MD		used_list, free_list;
extern MEMORY	md_array [];
extern int		tmp_handle, sector_flag;

#ifdef STAT
extern WORD		stat_access, stat_read, stat_write;
#endif
