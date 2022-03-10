#include "vmem.h"

/**********************************************/
/* Kopieren eines Bereiches in einen anderen: */
/**********************************************/

long vm_copy (source, destination, long)
	V_ADR source, destination;
	long count;
{
	BYTE	*page_ptr;
	VPAGE	page_s, page_d;
	WORD	offset_s, offset_d;
	long	entry_size, size_s, size_d;

	page_s = GET_PAGE (source);
	offset_s = GET_OFFSET (source);
	page_d = GET_PAGE (destination);
	offset_d = GET_OFFSET (destination);

#ifdef DEBUG
	printf ("VM_LOAD: page_s: %x  offset_s: %x\n", page_s, offset_s);
	printf ("         page_d: %x  offset_d: %x\n", page_d, offset_d);
#endif

	if ((page_s >= info.count_page) || (flags [page_s] == FREE)
	||  (page_d >= info.count_page) || (flags [page_d] == FREE))
		return (ILLEGAL_ADDRESS);

	if ((count == 0) || (count < -1))
		return (ILLEGAL_COUNT);

	size_s = PAGE_TO_ADDR (MD_COUNT (md_find (page_s)));
	size_d = PAGE_TO_ADDR (MD_COUNT (md_find (page_d)));

	if (count == -1)
		count = MIN ((size_s - offset_s), (size_d - offset_d));
	else
		count = MIN (count, MIN ((size_s - offset_s), (size_d - offset_d)));

	entry_size = count;

	if (offset_s > 0)
	{
		long	size = info.page_size - offset_s;
		
		page_ptr = load_page (vmem_page++, CACHE_READ) + start_offset;
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
		do
		{
			page_ptr = load_page (vmem_page++, CACHE_READ);
			memcpy (destination, page_ptr, info.page_size);
			destination += info.page_size;
			entry_size -= info.page_size;
		}
		while (entry_size >= info.page_size);
	}

	if (entry_size > 0)
	{
		page_ptr = load_page (vmem_page, CACHE_READ);
		memcpy (destination, page_ptr, entry_size);
	}

	return (count);
}
