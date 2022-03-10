#include "vmem.h"

/************************************************/
/* Speichern einer Datei in den virt. Speicher: */
/************************************************/

long vm_read (handle, count, destination)
	int		handle;
	V_ADR	destination;
	long	count;
{
	BYTE	*page_ptr;
	VPAGE	vmempage;
	WORD	start_offset;
	long	entry_size, fullsize, rsize, size;

	vmempage = GET_PAGE (destination);
	start_offset = GET_OFFSET (destination);

#ifdef DEBUG
	printf ("VM_READ: page: %x  offset: %x\n", vmempage, start_offset);
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
		
		page_ptr = load_page (vmempage++, CACHE_WRITE) + start_offset;
		if (count <= size)
			return (Fread (handle, count, page_ptr));
		else
		{
			if ((rsize = Fread (handle, size, page_ptr)) != size)
				return (rsize);
			fullsize = rsize;
			entry_size -= size;
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
			if ((rsize = Fread (handle, size, cache)) != size)
			{
				if (rsize < 0)
					return (rsize);
				else
				{
					fullsize += rsize;
					wcount = GET_PAGE (rsize);
					rsize = GET_OFFSET (rsize);
					if (wcount > 0)
						write_sequence (0, wcount, vmempage);
					vmempage += wcount;
					if (rsize > 0)
					{
						BYTE	*page_ptr;

						memcpy (buffer, CACHE_ADDRESS (wcount), rsize);
						page_ptr = load_page (vmempage, CACHE_WRITE);
						memcpy (page_ptr, buffer, rsize);
					}

					return (fullsize);
				}
			}

			write_sequence (0, wcount, vmempage);
			vmempage += wcount;
			start_offset -= wcount;
			fullsize += rsize;
		}
	}

	if ((size = GET_OFFSET (entry_size)) > 0)
	{
		BYTE	*page_ptr;

		if ((rsize = Fread (handle, size, buffer)) != size)
		{
			if (rsize < 0)
				return (rsize);
		}

		fullsize += rsize;
		page_ptr = load_page (vmempage, CACHE_WRITE);
		memcpy (page_ptr, buffer, rsize);
	}

	return (fullsize);
}
