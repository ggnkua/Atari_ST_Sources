/*
 *  libshare
 *
 */

/*  Global data of mintlib are replaced by global data of libshare.
 *  libshare allocate a memory bloc per process that contain such data.
 *
 *  This file provide mechanism to allocate/get/free the memory bloc
 *  attached to the current process.
 */

#include <stdlib.h>
#include <string.h>
#include <support.h>
#include <mint/mintbind.h>
#include <sys/ioctl.h>

#include <ldg.h>

#include "lib.h"
#include "libshare.h"

/*  singleTOS doesn't have SHM mechanism, so we use a chained list
 *  to simulate this feature and make libshare working on singleTOS
 */
struct singleTOS_shm {
	void * addr;
	char memory_name[8];
};

/* list of "shm" if the OS doesn't provide SHM mechanism
 * a free slot has addr=NULL and memory_name=""
 * the last slot has addr=NULL and memory_name="lastslot"
 * any other slot is occupied and has addr!=NULL
 */
static struct singleTOS_shm singleTOS_shm_list[] = 
{
	{ 0L, {""}},
	{ 0L, {""}},
	{ 0L, {""}},
	{ 0L, {""}},
	{ 0L, {""}},
	{ 0L, {""}},
	{ 0L, {""}},
	{ 0L, {""}},
	{ 0L, {"lastslot"}}
};

static void
get_shmfilename( const char * memory_name, char * filename)
{
	char strpid[3];
	long pid;
	
	pid = Pgetpid();
	
	_ltoa( pid, strpid, 10); 
	
	strcpy(filename,"/shm/");
	strcat(filename,memory_name);
	strcat(filename,".");
	strcat(filename,strpid);
}

static int has_shm( void)
{
	static int _has_shm = 0;
	
	if (! _has_shm)
	{
		/* check if the OS support SHM 
		 * and set _has_shm = 1 if the OS support SHM,
		 *     set _has_shm = -1 otherwise
		 */
		
		/* TODO */
	}
	
	return (_has_shm > 0) ? 1 : 0;
}

/*  return a pointer to the memory block attached to the current
 *  process, or NULL if such memory doesn't exist.
 *
 *  memory _name is the name of the SHM file.
 *  memory name shall up to 8 characters.
 *
 *  if memory_name is "libshare", and the current process ID is 5,
 *  this function will try to open the file "/shm/libshare.5"
 */
void *
libshare_getshm( const char * memory_name)
{
	if ( has_shm() )
	{
		char filename[32];
		long fd;
		void *addr;
	
		get_shmfilename( memory_name, filename);
		fd = Fopen(filename,0);
		if (fd <= 0) return NULL;
      	addr = (void *) Fcntl( fd, 0L, SHMGETBLK);
		Fclose(fd);
		return addr;
	}
	else
	{
		int shm_index = 0;
		
		while (1)
		{
			if ( singleTOS_shm_list[shm_index].addr == 0L 
			     && singleTOS_shm_list[shm_index].memory_name[0])
				return 0L;
			if ( strcmp(singleTOS_shm_list[shm_index].memory_name, memory_name) == 0)
				return singleTOS_shm_list[shm_index].addr;
			shm_index++;
		}
	}
	
	/* should never happen */
	return 0L;
}

/*  allocate global data (Mxalloc) and create a SHM file for this
 *  memory bloc.
 *  return the adress of the memory bloc allocated, or NULL in case
 *  of error (cannot create SHM, Mxalloc failed)
 */
void *
libshare_createshm( const char * memory_name, size_t size)
{
	void *addr = ldg_Malloc(size);
	
	if (addr==NULL) return NULL;
	
	if ( has_shm() )
	{
		char filename[32];
		long fd;
		
		get_shmfilename( memory_name, filename);
		
      	fd = Fcreate(filename,0);
		if( fd <= 0) {
			ldg_Free(addr);
			return NULL;
		}
		Fcntl( fd, (long)addr, SHMSETBLK);
		Fclose(fd);
		return addr;
	}
	else
	{
		int shm_index = 0;
		
		while (1)
		{
			if ( singleTOS_shm_list[shm_index].addr == 0L 
			     && singleTOS_shm_list[shm_index].memory_name[0])
				return 0L;
			if ( singleTOS_shm_list[shm_index].addr == 0L 
			     && singleTOS_shm_list[shm_index].memory_name[0] == 0)
			{
				singleTOS_shm_list[shm_index].addr = addr;
				strcpy(singleTOS_shm_list[shm_index].memory_name,memory_name);
				return addr;
			}
			shm_index++;
		}
	}
	
	/* should never happen */
	return 0L;
}


void
libshare_deleteshm( const char * memory_name)
{
	void *addr;
	
	if ( has_shm() )
	{
		char filename[32];
		long fd;
		
		get_shmfilename( memory_name, filename);
		
		fd = Fopen(filename,0);
		if (fd <= 0) return;
      	addr = (void *) Fcntl( fd, 0L, SHMGETBLK);
		Fclose(fd);
		ldg_Free(addr);
		Fdelete(filename);
		return;
		
	}
	else
	{
		int shm_index = 0;
		
		while (1)
		{
			if ( singleTOS_shm_list[shm_index].addr == 0L 
			     && singleTOS_shm_list[shm_index].memory_name[0])
				return;
			if ( strcmp(singleTOS_shm_list[shm_index].memory_name, memory_name) == 0)
			{
				ldg_Free( singleTOS_shm_list[shm_index].addr);
				singleTOS_shm_list[shm_index].addr = NULL;
				singleTOS_shm_list[shm_index].memory_name[0] = 0;
				return ;
			}
			shm_index++;
		}
	}
}
