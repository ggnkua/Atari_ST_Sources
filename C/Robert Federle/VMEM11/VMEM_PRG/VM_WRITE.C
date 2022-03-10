#include "vmem.h"

/********************************************/
/* Speichern eines Bereiches in eine Datei: */
/********************************************/

long vm_write (handle, count, source)
	int		handle;
	V_ADR	source;
	long	count;
{
	BYTE	*page_ptr;
	VPAGE	vmempage;
	WORD	start_offset;
	long	entry_size, fullsize, wsize, size;

	vmempage = GET_PAGE (source);
	start_offset = GET_OFFSET (source);

#ifdef DEBUG
	printf ("VM_WRITE: page: %x  offset: %x\n", vmempage, start_offset);
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

	fullsize = 0;

	if (start_offset > 0)
	{
		long	size = info.page_size - start_offset;
		
		page_ptr = load_page (vmempage++, CACHE_READ) + start_offset;
		if (count <= size)
			return (Fwrite (handle, count, page_ptr));
		else
		{
			if ((wsize = Fwrite (handle, size, page_ptr)) != size)
				return (wsize);
			fullsize = wsize;
			entry_size -= wsize;
		}
	}

	start_offset = GET_PAGE (entry_size);

	if (start_offset > 0)
	{
		WORD	wcount;

		cache_clr (0, MIN (start_offset, info.cache_count));

		while (start_offset > 0)
		{
			wcount = MIN (start_offset, info.cache_count);
			size = PAGE_TO_ADDR (wcount);
			read_sequence (0, wcount, vmempage);
			if ((wsize = Fwrite (handle, size, cache)) != size)
			{
				if (wsize < 0)
					return (wsize);
				else
					return (fullsize + wsize);
			}

			fullsize += wsize;
			vmempage += wcount;
			start_offset -= wcount;
		}
	}

	if ((size = GET_OFFSET (entry_size)) > 0)
	{
		BYTE	*page_ptr;

		page_ptr = load_page (vmempage, CACHE_READ);
		if ((wsize = Fwrite (handle, size, page_ptr)) != size)
		{
			if (wsize < 0)
				return (wsize);
		}
		
		fullsize += wsize;
	}

	return (fullsize);
}
