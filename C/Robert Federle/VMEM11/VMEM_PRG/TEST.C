#include "vmem.h"

long clock (void);
int printf(const char *format, ... );

#define	ALLOC_SIZE	(128*1024L)

char memory [ALLOC_SIZE];

int main (void)
{
	V_INFO	*infoblk;
	char	*cacheadr;
	TAB		parameter;
	V_ADR	testadr;
	long	ret_code;
	int		handle, i;
	long	time1, time2;

	time1 = clock ();

#if 0
	parameter.version = 0x100;
	parameter.count_page = 256;
	parameter.cache_size = 50;
	parameter.page_type = SIZE_4096;
	parameter.fill_value = 0;
	parameter.drive_no = 'C' - 'C' + 3;
#else
	parameter.version = 0x100;
	parameter.count_page = 100;
	parameter.cache_size = 6;
	parameter.page_type = SIZE_32768;
	parameter.fill_value = 0;
	parameter.drive_no = 'C' - 'C' + 3;
#endif

printf ("\nVM_CONFIG: $%lx", &parameter);

	ret_code = vm_config (&parameter);
	if (ret_code != OK)
	{
		printf (" !!! => %ld\n", ret_code);
		return (1);
	}



	infoblk = vm_info ();

printf ("\nVM_INFO: => $%lx", infoblk);

	printf ("\nVersion:\t$%x\n", infoblk->version);
	printf ("count page:\t#$%x\n", infoblk->count_page);
	printf ("count blocks:\t#$%x\n", infoblk->count_blocks);
	printf ("free blocks:\t#$%x\n", infoblk->free_blocks);
	printf ("fill value:\t$%x\n", infoblk->fill_value);
	printf ("cache size:\t$%lx bytes\n", infoblk->cache_size);
	printf ("cache count:\t$%x\n", infoblk->cache_count);
	printf ("page size:\t$%lx bytes\n", infoblk->page_size);
	printf ("max size:\t$%lx bytes\n", infoblk->max_size);
	printf ("max alloc:\t$%lx bytes\n", infoblk->max_alloc);
	printf ("drive no:\t#%x\n", infoblk->drive_no);
	printf ("Drive %c free:\t%ld bytes\n\n", (infoblk->drive_no + '@'), infoblk->drive_free);



printf ("\nVM_ALLOC: $%lx", ALLOC_SIZE);

	testadr = vm_alloc (ALLOC_SIZE);



printf ("\nVM_FILL: $%lx $%lx $%x", testadr, ALLOC_SIZE, 0xff);

	ret_code = vm_fill (testadr, ALLOC_SIZE, 0xff);
	if (ret_code != ALLOC_SIZE)
		printf ("%ld\n", ret_code);



	memcpy (memory, (char *) 0x100000L, 128*1024L);



printf ("\nVM_SAVE: $%lx $%lx $%lx", memory, testadr, ALLOC_SIZE);

	ret_code = vm_save (memory, testadr, ALLOC_SIZE);
	if (ret_code != ALLOC_SIZE)
		printf ("%ld\n", ret_code);



	handle = Fcreate ("C:\\TEST1.TMP", 0);

printf ("\nVM_WRITE: $%x $%lx $%lx", handle, ALLOC_SIZE, testadr);

	ret_code = vm_write (handle, ALLOC_SIZE, testadr);
	if (ret_code != ALLOC_SIZE)
		printf ("%ld\n", ret_code);

	Fclose (handle);


	handle = Fopen ("C:\\TEST1.TMP", 0);

printf ("\nVM_READ: $%x $%lx $%lx", handle, ALLOC_SIZE, testadr);

	ret_code = vm_read (handle, ALLOC_SIZE, testadr);
	if (ret_code != ALLOC_SIZE)
		printf ("%ld\n", ret_code);

	Fclose (handle);



	ret_code = 15000L;

printf ("\nVM_ADDRESS: $%lx $%lx $%x", testadr+0x123, &ret_code, WRITE_MODE);

	cacheadr = vm_address (testadr+0x123, &ret_code, WRITE_MODE);

printf ("\n => $%lx $%lx", cacheadr, ret_code);

#ifdef FILL
	memset (cacheadr, 0x61, ret_code);
#endif


	ret_code = 10000L;

printf ("\nVM_ADDRESS: $%lx $%lx $%x", testadr+0x823, &ret_code, WRITE_MODE);

	cacheadr = vm_address (testadr+0x823, &ret_code, WRITE_MODE);

printf ("\n => $%lx $%lx", cacheadr, ret_code);

#ifdef FILL
	memset (cacheadr, 0x62, ret_code);
#endif



	ret_code = 20000L;

printf ("\nVM_ADDRESS: $%lx $%lx $%x", testadr+0x1023, &ret_code, WRITE_MODE);

	cacheadr = vm_address (testadr+0x1023, &ret_code, WRITE_MODE);

printf ("\n => $%lx $%lx", cacheadr, ret_code);

#ifdef FILL
	memset (cacheadr, 0x63, ret_code);
#endif


#ifdef FILL
	for (i=7; i>=3; i--)
	{
		COPY_CACHE (CACHE_ADDRESS (i+1), CACHE_ADDRESS (i));
		ALLOC_CACHE (i+1, cache_flags [i], cache_page [i]);
		FREE_CACHE (i);
	}

	COPY_CACHE (CACHE_ADDRESS (0), CACHE_ADDRESS (2));
	ALLOC_CACHE (0, cache_flags [2], cache_page [2]);
	FREE_CACHE (2);

	COPY_CACHE (CACHE_ADDRESS (2), CACHE_ADDRESS (4));
	ALLOC_CACHE (2, cache_flags [4], cache_page [4]);
	FREE_CACHE (4);
#endif


	ret_code = 30000L;

printf ("\nVM_ADDRESS: $%lx $%lx $%x", testadr+0x223, &ret_code, READ_MODE);

	cacheadr = vm_address (testadr+0x223, &ret_code, READ_MODE);

printf ("\n => $%lx $%lx", cacheadr, ret_code);



	handle = Fcreate ("C:\\TEST2.TMP", 0);

printf ("\nVM_WRITE: $%x $%lx $%lx", handle, ALLOC_SIZE, testadr);

	ret_code = vm_write (handle, ALLOC_SIZE, testadr);
	if (ret_code != ALLOC_SIZE)
		printf ("%ld\n", ret_code);

	Fclose (handle);


	handle = Fcreate ("C:\\TEST2.TM", 0);

printf ("\nVM_WRITE: $%x $%lx $%lx", handle, ALLOC_SIZE, testadr);

	ret_code = vm_write (handle, ALLOC_SIZE, testadr);
	if (ret_code != ALLOC_SIZE)
		printf ("%ld\n", ret_code);

	Fclose (handle);



printf ("\nVM_FREE: $%lx", testadr);

	vm_free (testadr);



printf ("\nVM_CLOSE:\n");

	vm_close ();

	time2 = clock ();
	printf ("\nZeit: %ld Einheiten\n", (time2 - time1));

	return (0);
}
