#include "vmem.h"

/************************/
/* Speicheranforderung: */
/************************/

V_ADR vm_alloc (size)
	long size;
{
	VPAGE	vmempage;
	WORD	count;
	MD		entry;
	int		before, pointer;

	if (size < 0)		/* freien Speicher ermitteln */
	{
		count = 0;
		pointer = free_list;
		while (pointer != NIL)
		{
			if (MD_COUNT (pointer) > count)
				count = MD_COUNT (pointer);
			pointer = MD_NEXT (pointer);
		}
	
		return (PAGE_TO_ADDR (count));
	}

	count = GET_COUNT (size);
	if ((count == 0) || (info.free_blocks == 0))
		return (_NULL);

	before = NIL;
	pointer = free_list;
	while (pointer != NIL)
	{
		if (MD_COUNT (pointer) >= count)
		{
			vmempage = MD_START (pointer);

			if (init_pages (vmempage, count) != OK)
				return (_NULL);

			MD_START (pointer) += count;
			if ((MD_COUNT (pointer) -= count) == 0)
				md_delete (before, pointer);

/* Suchen des Nachfolgers in der Belegtliste: */

			before = NIL;
			pointer = used_list;
			while ((pointer != NIL) && (MD_START (pointer) < vmempage))
			{
				before = pointer;
				pointer = MD_NEXT (pointer);
			}

/* Einh„ngen des neuen MD in die Belegtliste: */

			entry = get_free_md ();
			INSERT_MD (entry, vmempage, count, pointer);
			if (before == NIL)
				used_list = entry;
			else
				MD_NEXT (before) = entry;

/* Initialisierung der Seiten: */

			entry = vmempage;
			do
				flags [entry++] = (NEW | FILE | USED);
			while (--count > 0);

			info.free_blocks--;

			return (PAGE_TO_ADDR (vmempage));
		}
		before = pointer;
		pointer = MD_NEXT (pointer);
	}
	return (_NULL);
}


/*********************/
/* Speicherfreigabe: */
/*********************/

int vm_free (address)
	V_ADR address;
{
	VPAGE	vmempage, lastpage;
	WORD	count;
	MD		entry;
	int		before, pointer, before2, pointer2;

	vmempage = GET_PAGE (address);
	count = GET_OFFSET (address);
	lastpage = vmempage + count - 1;
	if (count != 0)
		return (NOT_OK);

	before = NIL;
	pointer = used_list;
	while (pointer != NIL)
	{
		if (MD_START (pointer) == vmempage)
		{
/* MD aus der Belegtliste ausketten: */

			if (sector_flag)
				free_sector (vmempage, MD_COUNT (pointer));

			if (before == NIL)
				used_list = MD_NEXT (pointer);
			else
				MD_NEXT (before) = MD_NEXT (pointer);

/* Platz des MDs in der Freiliste suchen: */

			before2 = NIL;
			pointer2 = free_list;
			while ((pointer2 != NIL) && (MD_START (pointer2) < vmempage))
			{
				before2 = pointer2;
				pointer2 = MD_NEXT (pointer2);
			}

/* MD in die Freiliste einketten: */

			if (before2 == NIL)
				free_list = pointer;
			else
				MD_NEXT (before2) = pointer;

/* Nachfolger des MD ist nun in der Freiliste: */
			
			MD_NEXT (pointer) = pointer2;

/* Speicherkompression: */

			md_merge (before2, pointer, pointer2);

/* Freigabe der sich im CACHE befindenden Seiten: */

			for (entry = 0; entry < info.cache_count; entry++)
			{
				if (cache_flags [entry] != CACHE_FREE)
				{
					if (INSIDE (cache_page [entry], vmempage, lastpage))
						FREE_CACHE (entry);
				}
			}

/* Seiten initialisieren: */

			do
				flags [vmempage++] = FREE;
			while (--count > 0);

			info.free_blocks++;
			if (info.free_blocks == MAX_BLOCKS)
			{
				for (entry=0; entry < (age_count + 4); entry++)
				{
					FREE_CACHE (entry);
					cache_age [entry] = 0;
				}
			}

			return (OK);
		}
		before = pointer;
		pointer = MD_NEXT (pointer);
	}
	return (NOT_OK);
}


/********************************************/
/* Ausketten und L”schen einer MD-Struktur: */
/********************************************/

void md_delete (before, pointer)
	MD	before, pointer;
{
	if (before == NIL)
		free_list = MD_NEXT (pointer);
	else
		MD_NEXT (before) = MD_NEXT (pointer);

	DELETE_MD (pointer);
}


/****************************/
/* Verketten freier Bl”cke: */
/****************************/

void md_merge (before, current, next)
	MD	before, current, next;
{
	if (before != NIL)
	{
		if ((MD_START (before) + MD_COUNT (before)) == MD_START (current))
		{
			MD_COUNT (before) += MD_COUNT (current);
			md_delete (before, current);
			current = before;
		}
	}
	
	if (next != NIL)
	{
		if ((MD_START (current) + MD_COUNT (current)) == MD_START (next))
		{
			MD_COUNT (current) += MD_COUNT (next);
			md_delete (current, next);
		}
	}
}


/******************************************/
/* Suchen eines Eintrags der Belegtliste: */
/******************************************/

MD md_find (vmempage)
	VPAGE	vmempage;
{
	MD	before, pointer;

	before = used_list;
	pointer = MD_NEXT (before);

	while ((pointer != NIL) && (MD_START (pointer) < vmempage))
	{
		before = pointer;
		pointer = MD_NEXT (pointer);
	}

	return (before);
}
