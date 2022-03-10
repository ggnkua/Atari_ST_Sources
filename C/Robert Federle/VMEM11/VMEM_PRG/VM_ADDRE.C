#include "vmem.h"

/******************************************/
/* Adressierung des virtuellen Speichers: */
/******************************************/

char *vm_address (address, window_size, mode)
	V_ADR address;
	long *window_size;
	int mode;
{
	VPAGE	vmempage, lastpage;
	CPAGE	select;
	WORD	start_offset, count, i;

	vmempage = GET_PAGE (address);
	start_offset = GET_OFFSET (address);

#ifdef DEBUG
	printf ("\nVM_ADDRESS: page: %x  offset: %x", vmempage, start_offset);
#endif

	if ((vmempage >= info.count_page) || (flags [vmempage] == FREE))
		return ((char *) ILLEGAL_ADDRESS);
	
	if (*window_size <= 0)
		return ((char *) ILLEGAL_COUNT);

	if ((mode != READ_MODE) && (mode != WRITE_MODE))
		return ((char *) ILLEGAL_MODE);

	*window_size = MIN (*window_size, info.cache_size - start_offset);
	count = GET_COUNT (*window_size + start_offset);
	lastpage = vmempage + count - 1;

/* Sequenz im Cache suchen: Algorithmus 1 */

	if ((select = search_sequence (vmempage, lastpage)) == EMPTY_ENTRY)
	{
		ULONG	age, best_age;

/* keine geeignete Sequenz im Cache gefunden: Algorithmus 2 starten */
	
		select = 0;
		age = 0;
	
/* Gesamt-Alter der 1. Cache-Sequenz bestimmen: */
	
		for (i = 0; i < count; i++)
			age += (ULONG) cache_age [i];
	
		best_age = age;
	
/* "jÅngere" Cache-Sequenz suchen: */
	
		for ( ; i < info.cache_count; i++)
		{
			age = age - (ULONG) cache_age [i-count] + (ULONG) cache_age [i];
			if (age < best_age)
			{
				best_age = age;
				select = i - count + 1;
			}
		}
	}

#ifdef DEBUG
	printf ("\nVM_ADDRESS: %x PAGES FROM CACHE %x", count, select);
#endif

/* Belegte unbrauchbare Seiten innerhalb der Cache-Sequenz auslagern: */

	for (i = select; i < (select + count); i++)
	{
		if (cache_flags [i] != CACHE_FREE)
		{
			VPAGE	vpage = cache_page [i];

			if (OUTSIDE (vpage, vmempage, lastpage))
			{
#ifdef DEBUG
	printf ("\nVM_ADDRESS: REMOVE CACHE %x (PAGE: %x, Flag: %x)",
	i, cache_page [i], cache_flags [i]);
#endif
				if (cache_flags [i] == CACHE_WRITE)
					write_page (CACHE_ADDRESS (i), vpage);
				else
					CACHE_TO_FILE (vpage);
				FREE_CACHE (i);
			}
		}
	}

/* Durchsuchen des Caches nach Seiten, die zur Sequenz gehîren: */

	for (i = 0; i < info.cache_count; i++)
	{
		if (cache_flags [i] != CACHE_FREE)
		{
			VPAGE	vpage = cache_page [i];

			if (INSIDE (vpage, vmempage, lastpage))
			{
				WORD	source, dest;

				dest = vpage - vmempage + select;
				source = search_cache (vpage);

				if (source != dest)
				{
					if (cache_flags [dest] == CACHE_FREE)
					{
						COPY_CACHE (CACHE_ADDRESS (dest), CACHE_ADDRESS (source));
						ALLOC_CACHE (dest, cache_flags [source], vpage);
						FREE_CACHE (source);
					}
					else	/* CACHE is used */
					{
						WORD	other = cache_page [dest] - vmempage + select;
						
						if (cache_flags [other] == CACHE_FREE)
						{
							COPY_CACHE (CACHE_ADDRESS (other), CACHE_ADDRESS (dest));
							ALLOC_CACHE (other, cache_flags [dest], cache_page [dest]);
							COPY_CACHE (CACHE_ADDRESS (dest), CACHE_ADDRESS (source));
							ALLOC_CACHE (dest, cache_flags [source], vpage);
							FREE_CACHE (source);
						}
						else	/* CACHE is used */
						{
							if (cache_flags [dest] == CACHE_WRITE)
								write_page (CACHE_ADDRESS (dest), cache_page [dest]);
							else
								CACHE_TO_FILE (cache_page [dest]);

							COPY_CACHE (CACHE_ADDRESS (dest), CACHE_ADDRESS (source));
							ALLOC_CACHE (dest, cache_flags [source], vpage);
							FREE_CACHE (source);
						}
					}
				}
			}
		}
	}

/* restliche Seiten in den Cache einlagern: */

	for (i = select; i < (select + count); i++)
	{
		if (cache_flags [i] == CACHE_FREE)
		{
			VPAGE	vpage = vmempage + i - select;
			
			read_page (CACHE_ADDRESS (i), vpage);
			FILE_TO_CACHE (vpage);
			ALLOC_CACHE (i, mode, vpage);
		}
		else
		{
			UPDATE_FLAG (i, mode);
#ifdef DEBUG2
	printf ("\nUPDATE 2: CACHE %x WITH %x", i, mode);
#endif
		}
		ACCESSED (i);
	}

	return ((char *) (CACHE_ADDRESS (select) + start_offset));
}


/* alle Sequenzen im Cache untersuchen: */

WORD search_sequence (vmempage, lastpage)
	VPAGE	vmempage, lastpage;
{
	SEQ		*sequences, *seq2;
	WORD	scount, soldpage, border, i;

	sequences = (SEQ *) buffer;
	sequences->count = 0;
	scount = 0;
	soldpage = EMPTY_ENTRY;
	border = (lastpage - vmempage + 2) >> 1;

/* alle gÅltigen Sequenzen erstellen: */

	for (i = 0; i < info.cache_count; i++)
	{
		if (cache_flags [i] == CACHE_FREE)
		{
			if (scount >= border)
			{
				sequences->count = scount;
				sequences++;
				sequences->count = 0;
			}

			scount = 0;
			soldpage = EMPTY_ENTRY;
		}
		else	/* CACHE is used */
		{
			if (OUTSIDE (cache_page [i], vmempage, lastpage))
			{
				if (scount >= border)
				{
					sequences->count = scount;
					sequences++;
					sequences->count = 0;
				}

				scount = 0;
				soldpage = EMPTY_ENTRY;
			}
			else	/* INSIDE */
			{
				if (cache_page [i] != (soldpage + scount))
				{
					if (scount >= border)
					{
						sequences->count = scount;
						sequences++;
						sequences->count = 0;
					}

					scount = 1;
					sequences->cachepage = i;
					sequences->vmempage = soldpage = cache_page [i];
				}
				else	/* Sequence continues */
				{
					scount++;
				}
			}
		}
	}

/* Sequenz suchen, die alle gewÅnschten Seiten beinhaltet: */

	sequences = (SEQ *) buffer;
	while (sequences->count != 0)
	{
		if ((sequences->vmempage <= vmempage)
			&& ((sequences->vmempage + sequences->count) > lastpage))
		{
			return (sequences->cachepage - (sequences->vmempage - vmempage));
		}
		sequences++;	/* Zeiger auf nÑchste gefundene Sequenz */
	}

/* Sequenz suchen, bei der am Anfang und am Ende angefÅgt werden kann: */

	for (;;)
	{
		seq2 = sequences = (SEQ *) buffer;
		scount = 0;
		while (seq2->count != 0)
		{
			if (seq2->count > scount)
			{
				scount = seq2->count;
				sequences = seq2;
			}
			seq2++;
		}

/* War die Suche vergeblich ? */

		if (scount <= 1)
			return (EMPTY_ENTRY);

/* Kînnen Seiten am Anfang eingelagert werden ? */

		if (sequences->vmempage > vmempage)
		{
			if ((sequences->vmempage - vmempage) <= sequences->cachepage)
				scount = 1;
			else
				scount = 0;
		}
		else
			scount = 1;

/* Kînnen Seiten am Ende eingelagert werden ? */

		if ((sequences->vmempage + sequences->count - 1) < lastpage)
		{
			if ((info.cache_count - sequences->cachepage)
				>= (lastpage + 1 - sequences->vmempage))
			{
				scount += 2;
			}
		}
		else
			scount += 2;

/* Platz am Anfang und am Ende ? */

		if (scount == 3)
			return (sequences->cachepage - (sequences->vmempage - vmempage));

/* Feld lîschen; Suche fortsetzen: */

		sequences->count = 1;
	}
}
