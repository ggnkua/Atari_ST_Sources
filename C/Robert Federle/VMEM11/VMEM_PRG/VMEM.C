#include "vmem.h"

/**********************/
/* Globale Variablen: */
/**********************/

V_INFO		info;		/* Informationsblock */

WORD	max_page;		/* bisher gr”žte Datei-Seiten-Nummer */

BYTE	*flags;			/* Flags fr den virtuellen Speicher */

CPAGE	*cache_page;	/* Umsetztabelle Cache-Seite => Speicher-Seite */
BYTE	*cache_flags;	/* Flags fr den Cache */
ULONG	*cache_age;		/* LRU-Age fr den Cache */
WORD	age_count;		/* Anzahl der Age-LONGS */
ULONG	lru_count;		/* Timer fr LRU-Aging */

BYTE	*cache;			/* eigentlicher Seiten-Cache */
BYTE	*buffer;		/* Puffer fr eine Seite */

int		sector_flag;	/* Flag fr die Verwendung von BIOS-Routinen */
WORD	*sector_no;		/* Sektor-Nummern der jeweiligen Seiten */

BPB		*bpb_block;		/* Zeiger auf aktuellen BPB-Block */
WORD	size_bits;
WORD	record_bits;
WORD	cluster_bits;
WORD	cluster_size;
WORD	sector_mask;
WORD	sectors;
WORD	drive;

WORD	offset_bits;	/* Anzahl der Bits, die den Offset bestimmen */
WORD	offset_mask;	/* Maske fr die Offset-Bits */

MD		used_list;		/* Belegtliste */
MD		free_list;		/* Freiliste */

MEMORY	md_array [MAX_BLOCKS];	/* Speicher fr Memory Deskriptoren */

int		tmp_handle;				/* Handle fr die tempor„re Datei */
char	tmp_file [] = TMP_FILE;	/* Name und Pfad der tempor„ren Datei */

/********************************************************/
/* Konfiguration des Caches sowie der n”tigen Tabellen: */
/********************************************************/

int vm_config (parameter)
	TAB	*parameter;
{
	DISKINFO	dbuffer;
	int			i;
	long		drivemap;

	if (info.version != 0)				/* schon mal konfiguriert ? */
		vm_close ();

	if (parameter->cache_size < 4)		/* mindestens 4 Seiten */
		return (WRONG_CACHE_SIZE);

	if (parameter->page_type > SIZE_32768)
		return (WRONG_PAGE_TYPE);

	drivemap = Drvmap ();
	info.drive_no = parameter->drive_no;
	drive = parameter->drive_no - 1;

	if ((drive < 2)
	|| ((drivemap & (1 << drive)) == 0))
		return (ILLEGAL_DRIVE);

	bpb_block = Getbpb (drive);
	if (bpb_block->bflags != 1)
		return (ILLEGAL_FATSIZE);

	record_bits = 0;
	i = bpb_block->recsiz;
	while (i >>= 1)
		++record_bits;

	cluster_bits = 0;
	i = bpb_block->clsiz;
	while (i >>= 1)
		++cluster_bits;

	sector_mask = (1 << (record_bits - cluster_bits)) - 1;
	sectors = 1 + bpb_block->fsiz * 2 + bpb_block->rdlen
			+ (bpb_block->numcl * bpb_block->clsiz);

	Dfree (&dbuffer, info.drive_no);
	info.drive_free = dbuffer.b_free << 10;

	offset_bits = 10 + parameter->page_type;
	offset_mask = (1 << offset_bits) - 1;

	lru_count = 0;

	age_count = parameter->cache_size;

	info.version = VERSION;
	info.count_page = parameter->count_page;
	info.count_blocks = info.free_blocks = MAX_BLOCKS;
	info.fill_value = parameter->fill_value;
	info.page_size = PAGE_TO_ADDR (1);
	info.cache_size = PAGE_TO_ADDR (parameter->cache_size);
	info.cache_count = parameter->cache_size;
	info.max_size = PAGE_TO_ADDR (info.count_page);
	info.max_alloc = PAGE_TO_ADDR (info.count_page);

	cluster_size = bpb_block->clsiz;
	if (info.page_size == bpb_block->clsizb)
	{
		size_bits = 0;
		sector_flag = 1;
	}
	else if (info.page_size == (bpb_block->clsizb + bpb_block->clsizb))
	{
		cluster_size += cluster_size;
		size_bits = 1;
		sector_flag = 1;
	}
	else if (info.page_size == (bpb_block->clsizb << 2))
	{
		cluster_size <<= 2;
		size_bits = 2;
		sector_flag = 1;
	}
/*	else*/
	{
		tmp_file [0] = 'C' - 3 + info.drive_no;
		Fdelete (tmp_file);
		if ((tmp_handle = Fcreate (tmp_file, 0)) < 0)
			return (tmp_handle);
		sector_flag = 0;
	}

/* Speicheranforderung der ben”tigten Arrays: */

	MALLOC (flags, BYTE, info.count_page+1);
	if (sector_flag)
	{
		MALLOC (sector_no, SECTOR, info.count_page+1);
	}
	else
		sector_no = NULL;
	MALLOC (cache_page, VPAGE, info.cache_count);
	MALLOC (cache_flags, BYTE, info.cache_count);
	MALLOC (cache_age, ULONG, info.cache_count);
	MALLOC (cache, BYTE, info.cache_size);
	MALLOC (buffer, BYTE, info.page_size);

/* Initialisierung der ben”tigten Arrays: */

	max_page = 1;

	if (!sector_flag)
	{
		if ((i = init_pages (1, 1)) != OK)
			return (i);

		Fclose (tmp_handle);

		if ((tmp_handle = Fopen (tmp_file, 2)) < 0)
			return (tmp_handle);
	}

	for (i = 0; i < info.count_page; i++)		/* Datei-Parameter */
		flags [i] = FREE;

	if (sector_flag)
		for (i = 0; i < info.count_page; i++)	/* Sektor-Daten */
			sector_no [i] = EMPTY_ENTRY;

	for (i = 0; i < info.cache_count; i++)		/* Cache-Parameter */
		FREE_CACHE (i);

	for (i = 0; i < (age_count + 4); i++)
		cache_age [i] = 0;

	used_list = NIL;
	free_list = 0;
	INSERT_MD (0, 1, info.count_page, NIL);

	for (i = 1; i < MAX_BLOCKS; i++)
		DELETE_MD (i);

	return (OK);
}


/***********************************/
/* Schliežen der tempor„ren Datei: */
/***********************************/

void vm_close ()
{
	if (!sector_flag)
	{
		Fclose (tmp_handle);	/* Datei schliežen, */
		Fdelete (tmp_file);
	}

	Mfree (buffer);
	Mfree (cache);
	Mfree (cache_age);
	Mfree (cache_flags);
	Mfree (cache_page);
	if (sector_flag)
		Mfree (sector_no);
	Mfree (flags);
}

/*********************************/
/* šbergabe der V_INFO-Struktur: */
/*********************************/

V_INFO *vm_info (void)
{
	return (&info);
}

/********************************************/
/* Neu-Initialisierung des gesamten Caches: */
/********************************************/

void vm_clrcache (void)
{
	cache_clr (0, info.cache_count);
}
