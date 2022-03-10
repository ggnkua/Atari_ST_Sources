#include "vmem.h"

/*********************************************************/
/* Laden eines Speicherbereiches aus dem virt. Speicher: */
/*********************************************************/

long vm_load (source, destination, count)
	V_ADR	source;
	char	*destination;
	long	count;
{
	BYTE	*page_ptr;
	VPAGE	vmempage;
	WORD	start_offset;
	long	entry_size;

	vmempage = GET_PAGE (source);
	start_offset = GET_OFFSET (source);

#ifdef DEBUG
	printf ("VM_LOAD: page: %x  offset: %x\n", vmempage, start_offset);
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
		long	size;
		
		size = info.page_size - start_offset;
		page_ptr = load_page (vmempage++, CACHE_READ) + start_offset;

		if (count <= size)
		{
			memcpy (destination, page_ptr, count);
			return (count);
		}
		else
		{
			memcpy (destination, page_ptr, size);
			destination += size;
			entry_size -= size;
		}
	}

	if (entry_size >= info.page_size)
	{
		WORD	rcount;
		long	size;

		start_offset = GET_PAGE (entry_size);
		cache_clr (0, MIN (start_offset, info.cache_count));

		while (start_offset > 0)
		{
			rcount = MIN (start_offset, info.cache_count);
			size = PAGE_TO_ADDR (rcount);

			read_sequence (0, rcount, vmempage);
			memcopy (destination, cache, size);

			destination += size;
			entry_size -= size;
			vmempage += rcount;
			start_offset -= rcount;
		}
	}

	if (entry_size > 0)
	{
		page_ptr = load_page (vmempage, CACHE_READ);
		memcpy (destination, page_ptr, entry_size);
	}

	return (count);
}
