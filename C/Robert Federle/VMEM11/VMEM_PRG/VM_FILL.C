#include "vmem.h"

/***********************************/
/* Fllen eines Speicherbereiches: */
/***********************************/

long vm_fill (address, count, value)
	V_ADR address;
	long count;
	int value;
{
	BYTE	*page_ptr;
	VPAGE	vmempage;
	WORD	start_offset;
	long	entry_size;

	vmempage = GET_PAGE (address);
	start_offset = GET_OFFSET (address);

#ifdef DEBUG
	printf ("VM_FILL: page: %x  offset: %x\n", vmempage, start_offset);
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
			memset (page_ptr, value, count);
			return (count);
		}
		else
		{
			memset (page_ptr, value, size);
			entry_size -= size;
		}
	}

	if (entry_size >= info.page_size)
	{
		FILL_CACHE (buffer, value);
/*	memset (buffer, value, info.page_size);*/

		do
		{
			save_page (buffer, vmempage++);
			entry_size -= info.page_size;
		}
		while (entry_size >= info.page_size);
	}

	if (entry_size > 0)
	{
		page_ptr = load_page (vmempage, CACHE_WRITE);
		memset (page_ptr, value, entry_size);
	}

	return (count);
}
