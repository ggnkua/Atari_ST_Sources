#include "vmem.h"

/**************************************/
/* Einlesen einer Seite in den Cache: */
/**************************************/

BYTE *load_page (vmempage, flag)
	VPAGE	vmempage;
	int		flag;
{
	CPAGE	cachepage;
	BYTE	*cacheaddr;

#ifdef STAT
	stat_access++;
#endif

	if (WHERE_FLAG (vmempage) == CACHE)
	{
		cachepage = search_cache (vmempage);	/* Seite im Cache suchen */

#ifdef DEBUG
	printf ("LOAD_PAGE (Flag: %x): %x from CACHE %x (Flag: %x)\n",
	flag, vmempage, cachepage, cache_flags [cachepage]);
#endif

		ACCESSED (cachepage);
		UPDATE_FLAG (cachepage, flag);
		return (CACHE_ADDRESS (cachepage));
	}


	cachepage = find_cache ();		/* „lteste Seite im Cache suchen */

	FILE_TO_CACHE (vmempage);
	ALLOC_CACHE (cachepage, flag, vmempage);	/* Cache-Seite belegen */
	cacheaddr = CACHE_ADDRESS (cachepage);

#ifdef DEBUG	
	if (NEW_FLAG (vmempage) == NEW)
	{
		printf ("LOAD_PAGE (Flag: %x): NEW PAGE %x\n",
		flag, vmempage);
	}
	else
	{
		printf ("LOAD_PAGE (Flag: %x): %x from CACHE %x (Flag: %x)\n",
		flag, vmempage, cachepage, cache_flags [cachepage]);
	}
#endif

	read_page (cacheaddr, vmempage);
	if (flag == CACHE_WRITE)
		MAKE_OLD (vmempage);

	return (cacheaddr);
}


/******************************************/
/* Schreiben eines Puffers in eine Seite: */
/******************************************/

void save_page (block, vmempage)
	BYTE	*block;
	VPAGE	vmempage;
{
	CPAGE	cachepage;

#ifdef STAT
	stat_access++;
#endif

	if (WHERE_FLAG (vmempage) == CACHE)
	{
		cachepage = search_cache (vmempage);	/* Seite im Cache suchen */

#ifdef DEBUG
	printf ("SAVE_PAGE: %x into CACHE %x\n",
	vmempage, cachepage);
#endif

		ACCESSED (cachepage);					/* Zugriff auf <cachepage> */
		SET_FLAG (cachepage, CACHE_WRITE);		/* Cache-Flag aktualisieren */
		MAKE_OLD (vmempage);
		COPY_CACHE (CACHE_ADDRESS (cachepage), block);
		return;
	}

	if (NEW_FLAG (vmempage) == NEW)
	{
		cachepage = find_cache ();

#ifdef DEBUG
	printf ("SAVE_PAGE: NEW PAGE %x into CACHE %x\n",
	vmempage, cachepage);
#endif	

		ALLOC_CACHE (cachepage, CACHE_WRITE, vmempage);
		FILE_TO_CACHE (vmempage);
		MAKE_OLD (vmempage);
		COPY_CACHE (CACHE_ADDRESS (cachepage), block);
	}
	else
	{
#ifdef DEBUG
	printf ("SAVE_PAGE: WRITE %x\n", vmempage);
#endif	
		write_page (block, vmempage);
	}
}


/************************************************************/
/* Suchen einer freien Seite im Cache; falls kein Treffer:  */
/* Auslagern der Seite, die den geringsten Aufwand ben”tigt */
/************************************************************/

CPAGE find_cache ()
{
	CPAGE	cachepage;
	VPAGE	vmempage;

	for (cachepage = 0; cachepage < info.cache_count; cachepage++)
	{
		if (cache_flags [cachepage] == CACHE_FREE)
		{
			ACCESSED (cachepage);
			return (cachepage);
		}
	}

/* Auswahl einer zu verdr„ngenden Seite: */

#ifdef DEBUG
	printf ("  AGE: ");
	{
		int j;
		
		for (j=0; j < age_count; j++)
			printf ("%02x ", cache_age [j]);
		printf ("\n");
	}
#endif

	cachepage = get_oldest ();
	vmempage = cache_page [cachepage];

/* Auslagern dieser Seite, falls n”tig */

	if (cache_flags [cachepage] == CACHE_WRITE)
	{
		write_page (CACHE_ADDRESS (cachepage), vmempage);

#ifdef DEBUG
	printf ("FIND_CACHE: WRITE CACHE %x (%x) ==>  ",
	cachepage, vmempage);
#endif

	}
	else
	{

#ifdef DEBUG
	printf ("FIND_CACHE: DELETE CACHE %x (%x) ==>  ",
	cachepage, vmempage);
#endif

		CACHE_TO_FILE (vmempage);
	}

	ACCESSED (cachepage);
	FREE_CACHE (cachepage);
	return (cachepage);
}


/*********************************************************************/
/* Einlesen einer Seite aus dem virtuellen Speicher in einen Puffer: */
/*********************************************************************/

void read_page (block, vmempage)
	BYTE	*block;
	VPAGE	vmempage;
{
	long	rsize;
	
#ifdef STAT
	stat_read++;
#endif

	if (NEW_FLAG (vmempage) == NEW)
	{
		INIT_CACHE (block);
	}
	else
	{
		if (sector_flag)
		{
			READ_SECTOR (block, cluster_size, sector_no [vmempage]);
		}
		else
		{
			FSEEK (vmempage);
			if ((rsize = FREAD (info.page_size, block)) != info.page_size)
			{
				printf ("Fread-Error #%ld!!\nPage: %x  Offset: %ld\n",
					rsize, vmempage, PAGE_TO_ADDR (vmempage));
				vm_close ();
				exit (3);
			}
		}
	}
}


/*******************************************************************/
/* Schreiben eines Puffers in eine Seite des virtuellen Speichers: */
/*******************************************************************/

void write_page (block, vmempage)
	BYTE	*block;
	VPAGE	vmempage;
{
	long	wsize;

#ifdef STAT
	stat_write++;
#endif

	CACHE_TO_FILE (vmempage);
	MAKE_OLD (vmempage);

	if (sector_flag)
	{
		WRITE_SECTOR (block, cluster_size, sector_no [vmempage]);
	}
	else
	{
		FSEEK (vmempage);
		if ((wsize = FWRITE (info.page_size, block)) != info.page_size)
		{
			printf ("Fwrite-Error #%ld!!\nPage: %x  Offset: %ld\n",
				wsize, vmempage, PAGE_TO_ADDR (vmempage));
			vm_close ();
			exit (4);
		}
	}
}


/*************************************/
/* Initialisierung der Datei-Seiten: */
/*************************************/

int init_pages (vmempage, count)
	VPAGE	vmempage;
	WORD	count;
{
	long	size, size2;

	if (sector_flag)
	{
		if (alloc_sector (vmempage, count) == OK)
			return (OK);
		else
		{
			free_sector (vmempage, count);
			return (NOT_OK);
		}
	}

	if ((vmempage + count) <= max_page)
		return (OK);

	FSEEK (max_page);
	size = PAGE_TO_ADDR ((vmempage + count) - max_page);
	max_page = vmempage + count - 1;

	while (size > 0)
	{
		size2 = MIN (size, info.cache_size);
		if (FWRITE (size2, cache) != size2)
			return (FILE_ERROR);

		size -= size2;
	}
	return (OK);
}


/********************************************************************/
/* <count> CACHE-Seiten ab <cachepage> rausschreiben und freigeben: */
/********************************************************************/

void cache_clr (cachepage, count)
	CPAGE	cachepage;
	WORD	count;
{
	VPAGE	vmempage;

	while (count-- > 0)
	{
		vmempage = cache_page [cachepage];
		switch (cache_flags [cachepage])
		{
			case CACHE_WRITE:
				write_page (CACHE_ADDRESS (cachepage), vmempage);

#ifdef DEBUG
	printf ("CACHE_CLR: WRITE CACHE %x (%x)\n",
	cachepage, vmempage);
#endif

				FREE_CACHE (cachepage);
				break;

			case CACHE_READ:

#ifdef DEBUG
	printf ("CACHE_CLR: DELETE CACHE %x (%x)\n", cachepage, vmempage);
#endif

				CACHE_TO_FILE (vmempage);
				FREE_CACHE (cachepage);
				break;
		}
		cache_age [cachepage++] = 0;
	}
}


/***********************************************************************/
/* Schreiben einer Sequenz im Cache in die Datei-Seiten ab <vmempage>: */
/***********************************************************************/

void write_sequence (cachepage, count, vmempage)
	CPAGE	cachepage;
	WORD	count;
	VPAGE	vmempage;
{
	CPAGE	i;
	VPAGE	vpage;
	char	*block;
	
	vpage = vmempage;
	block = CACHE_ADDRESS (cachepage);

	if (write_test (vmempage, count) == count)
	{
		CPAGE	select;

		for (i = cachepage; i < (cachepage + count); i++)
		{
			select = search_cache (vmempage);	/* Seite im Cache suchen */
			ACCESSED (select);					/* Zugriff auf <select> */
			SET_FLAG (select, CACHE_WRITE);		/* Cache-Flag aktualisieren */
			MAKE_OLD (vmempage);
			COPY_CACHE (CACHE_ADDRESS (select), block);
			block += info.page_size;
		}
		return;
	}

	for (i = cachepage; i < (cachepage + count); i++)
	{
		if (WHERE_FLAG (vpage) == CACHE)
		{
			CACHE_TO_FILE (vpage);
			FREE_CACHE (search_cache (vpage));
		}
		MAKE_OLD (vpage++);
	}

	if (sector_flag)
	{
		for (i = cachepage; i < (cachepage + count); i++)
		{
			WRITE_SECTOR (block, cluster_size, sector_no [vmempage++]);
			block += info.page_size;
		}
	}
	else
	{
		long	size, wsize;

		size = PAGE_TO_ADDR (count);
		FSEEK (vmempage);
		if ((wsize = FWRITE (size, block)) != size)
		{
			printf ("Fwrite-Error #%ld!!\nPage: %x  Offset: %ld\n",
				wsize, vmempage, PAGE_TO_ADDR (vmempage));
			vm_close ();
			exit (4);
		}
	}
}


/**************************************************************/
/* Lesen einer Sequenz von Seiten ab <vmempage> in den Cache: */
/**************************************************************/

void read_sequence (cachepage, count, vmempage)
	CPAGE	cachepage;
	WORD	count;
	VPAGE	vmempage;
{
	CPAGE	i, select;
	VPAGE	vpage;
	char	*block;

	vpage = vmempage;
	block = CACHE_ADDRESS (cachepage);

	if (read_test (vmempage, count) == count)
	{
		for (i = cachepage; i < (cachepage + count); i++)
		{
			if (WHERE_FLAG (vmempage) == CACHE)
			{
				select = search_cache (vmempage);	/* Seite im Cache suchen */
				ACCESSED (select);					/* Zugriff auf <select> */
				COPY_CACHE (block, CACHE_ADDRESS (select));
			}
			else
			{
				INIT_CACHE (block);
			}
			block += info.page_size;
		}
		return;
	}

	if (sector_flag)
	{
		for (i = cachepage; i < (cachepage + count); i++)
		{
			READ_SECTOR (block, cluster_size, sector_no [vpage++]);
			block += info.page_size;
		}
	}
	else
	{
		long	size, rsize;

		size = PAGE_TO_ADDR (count);
		FSEEK (vmempage);
		if ((rsize = FREAD (size, block)) != size)
		{
			printf ("Fread-Error #%ld!!\nPage: %x  Offset: %ld\n",
				rsize, vmempage, PAGE_TO_ADDR (vmempage));
			vm_close ();
			exit (3);
		}
	}

	for (i = cachepage; i < (cachepage + count); i++)
	{
		if (WHERE_FLAG (vmempage) == CACHE)
		{
			select = search_cache (vmempage);	/* Seite im Cache suchen */
			ACCESSED (select);
			COPY_CACHE (CACHE_ADDRESS (i), CACHE_ADDRESS (select));
		}
		else
		{
			if (NEW_FLAG (vmempage) == NEW)
			{
				INIT_CACHE (CACHE_ADDRESS (i));
			}
		}
		vmempage++;
	}
}


/************************************/
/* freien Memory Deskriptor suchen: */
/************************************/

MD get_free_md (void)
{
	MD mem;

	mem = 0;
	while (MD_START (mem) != FREE_MD)
		mem++;

	return (mem);
}


/*****************************/
/* Sektoren in FAT2 belegen: */
/*****************************/

int alloc_sector (vmempage, count)
	VPAGE	vmempage;
	WORD	count;
{
	WORD	fat1, fat2, sector, offset, cluster;

	fat2 = bpb_block->fatrec;
	fat1 = fat2 - bpb_block->fsiz;
	sector = 0;
	offset = 4;
	READ_SECTOR (buffer, 1, fat2);

	while (count > 0)
	{
		if (offset >= bpb_block->recsiz)
		{
			WRITE_SECTOR (buffer, 1, fat1+sector);
			WRITE_SECTOR (buffer, 1, fat2+sector);
			if (++sector > bpb_block->fsiz)
				return (NOT_OK);
			offset = 0;
			READ_SECTOR (buffer, 1, fat2+sector);
		}

		switch (size_bits)
		{
			case 0:
				if (*((WORD *) (buffer + offset)) == 0)
				{
					*((WORD *) (buffer + offset)) = 0xFFFF;
					cluster = sector << (record_bits - cluster_bits);
					cluster += (offset >> 1) - 2;
					cluster <<= cluster_bits;
					cluster += bpb_block->datrec;
					sector_no [vmempage++] = cluster;
					--count;
				}
				offset += 2;
				break;
			case 1:
				if ((offset + 4) < bpb_block->recsiz)
				{
					if (*((ULONG *) (buffer + offset)) == 0)
					{
						*((ULONG *) (buffer + offset)) = 0xFFFFFFFFL;
						cluster = sector << (record_bits - cluster_bits);
						cluster += (offset >> 1) - 2;
						cluster <<= cluster_bits;
						cluster += bpb_block->datrec;
						sector_no [vmempage++] = cluster;
						offset += 4;
						--count;
						break;
					}
				}
				offset += 2;
				break;
			case 2:
				if ((offset + 8) < bpb_block->recsiz)
				{
					if ((*((ULONG *) (buffer + offset)) == 0)
						&& (*((ULONG *) (buffer + offset + 4)) == 0))
					{
						*((ULONG *) (buffer + offset)) = 0xFFFFFFFFL;
						*((ULONG *) (buffer + offset + 4)) = 0xFFFFFFFFL;
						cluster = sector << (record_bits - cluster_bits);
						cluster += (offset >> 1) - 2;
						cluster <<= cluster_bits;
						cluster += bpb_block->datrec;
						sector_no [vmempage++] = cluster;
						offset += 8;
						--count;
						break;
					}
				}
				offset += 2;
				break;
		}
	}
	WRITE_SECTOR (buffer, 1, fat1+sector);
	WRITE_SECTOR (buffer, 1, fat2+sector);

	if (cluster > sectors)
		return (NOT_OK);
	else
		return (OK);
}


/*******************************/
/* Sektoren in FAT2 freigeben: */
/*******************************/

void free_sector (vmempage, count)
	VPAGE	vmempage;
	WORD	count;
{
	WORD	fat1, fat2, sector, sector_alt, offset;
	
	fat2 = bpb_block->fatrec;
	fat1 = fat2 - bpb_block->fsiz;
	sector_alt = EMPTY_ENTRY;

	while (count-- > 0)
	{
		sector = sector_no [vmempage++] - bpb_block->datrec;
		sector >>= cluster_bits;
		offset = sector = sector + 2;
		sector >>= (record_bits - cluster_bits);
		offset &= sector_mask;
		offset += offset;

		if (sector != sector_alt)
		{
			if (sector_alt != EMPTY_ENTRY)
			{
				WRITE_SECTOR (buffer, 1, fat1+sector_alt);
				WRITE_SECTOR (buffer, 1, fat2+sector_alt);
			}
			READ_SECTOR (buffer, 1, fat2+sector);
			sector_alt = sector;
		}

		switch (size_bits)
		{
			case 0:
				*((WORD *) (buffer + offset)) = 0;
				break;
			case 1:
				*((ULONG *) (buffer + offset)) = 0;
				break;
			case 2:
				*((ULONG *) (buffer + offset)) = 0;
				*((ULONG *) (buffer + offset + 4)) = 0;
				break;
		}
	}
	WRITE_SECTOR (buffer, 1, fat1+sector);
	WRITE_SECTOR (buffer, 1, fat2+sector);
}
