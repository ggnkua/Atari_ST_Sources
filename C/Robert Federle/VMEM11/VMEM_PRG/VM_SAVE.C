#include "vmem.h"

/****************************************************/
/* Speichern eines Bereiches in den virt. Speicher: */
/****************************************************/

long vm_save (source, destination, count)
	char	*source;
	V_ADR	destination;
	long	count;
{
	BYTE	*page_ptr;
	VPAGE	vmempage;
	WORD	start_offset;
	long	entry_size;

	vmempage = GET_PAGE (destination);
	start_offset = GET_OFFSET (destination);

#ifdef DEBUG
	printf ("VM_SAVE: page: %x  offset: %x\n", vmempage, start_offset);
#endif

	if ((vmempage >= info.count_page) || (flags [vmempage] == FREE))
		return (ILLEGAL_ADDRESS);

	if ((count == 0) || (count < -1))
		return (ILLEGAL_COUNT);

	entry_size = PAGE_TO_ADDR (MD_COUNT (md_find (vmempage)));

	if (count == -1)
		count = entry_size - start_offset;
	else
		entry_size = count = MIN (count, (entry_size - start_offset));

	if (start_offset > 0)
	{
		long	size = info.page_size - start_offset;
		
		page_ptr = load_page (vmempage++, CACHE_WRITE) + start_offset;
		if (count <= size)
		{
			memcpy (page_ptr, source, count);
			return (count);
		}
		else
		{
			memcpy (page_ptr, source, size);
			source += size;
			entry_size -= size;
		}
	}

	if (entry_size >= info.page_size)
	{
		WORD	wcount;
		long	size;

		start_offset = GET_PAGE (entry_size);
		cache_clr (0, MIN (start_offset, info.cache_count));

		while (start_offset > 0)
		{
			wcount = MIN (start_offset, info.cache_count);
			size = PAGE_TO_ADDR (wcount);

			memcopy (cache, source, size);
			write_sequence (0, wcount, vmempage);

			source += size;
			entry_size -= size;
			vmempage += wcount;
			start_offset -= wcount;
		}
	}

	if (entry_size > 0)
	{
		page_ptr = load_page (vmempage, CACHE_WRITE);
		memcpy (page_ptr, source, entry_size);
	}

	return (count);
}
