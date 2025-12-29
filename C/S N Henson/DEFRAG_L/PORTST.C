#include <fcntl.h>
#include <mintbind.h>
#include <stdio.h>
#define PORTST
#include "portst.h"


/* C equivalents of bitop stuff ... maybe useable on other platforms */

int bit(map,bnum)
void *map;
long bnum;
{
	return ((unsigned short *)map)[bnum>>4] & (1<<(bnum & 0xf)) ? 1 : 0;
}

/* No return value , it isn't used at present */
void setbit(map,bnum)
void *map;
long bnum;
{
	((unsigned short *)map)[bnum>>4] |= 1<<(bnum & 0xf);
}

void clrbit(map,bnum)
void *map;
long bnum;
{
	((unsigned short *)map)[bnum>>4] &= ~(1<<(bnum & 0xf));
}

/* This stuff is *definitely* atari ST specific , there aren't any block special
 * files that correspond to the physical drives under TOS or MiNT so these are
 * simulated by trapping all open/read/write/lseek/close calls , which are only
 * (at present) used for disk access anyway . If this changes then something
 * cleverer will be required .
 */

#undef open
#undef close
#undef read
#undef write
#undef lseek

#include <unistd.h>

/* Global variables to keep track of whats going on */
static long block;	/* Physical sector pointed to */
static int infd;	/* The fd used for access (ignored for now) */
static int _write_ok;	/* Write allowed */
static struct hdinfo _hdinf; /* Hard disk info */
static char *devname;  /* copy of device name */
static int device;

int new_open(char *file,int mode,unsigned omode)
{
	int err;
	if(mode==O_RDWR) _write_ok=1;
	device=(file[0] & ~32) - 'A' ;
	if(file[1]!=':' || file[2] || device < 0 || device > 25 )
						return open(file,mode,omode);
	if( (err=get_hddinf(device,&_hdinf,0)) )
	{
		extern char *hdd_err[];
		fprintf(stderr,"Can't access %s: %s\n",file,hdd_err[err]);
		device=-1;
		return -1;
	}

	/* Flush minixfs buffers */
	Dcntl(0x101,file,0l);

	/* Suspend update */
	Dcntl(0x10b,file,1);

	(void)Dlock(1,device);

	devname=strdup(file);

	infd=10;

	return 10;	/* Anything valid */
}

int new_close(fd)
int fd;
{
	if(fd!=infd) return close(fd);
	(void)Dlock(0,device);
	Dcntl(0x10b,devname,2);
	return 0;
}

long new_lseek(fd,pos,whence)
int fd;
long pos;
int whence;
{
	if(fd!=infd) return lseek(fd,pos,whence);
	if(whence!=SEEK_SET)
	{
		fprintf(stderr,"Only SEEK_SET allowed\n");
		return -1;
	}
	block=pos/1024;
	return pos;	/* BUG: no check for bad sector number here */	
}

long new_read(fd,buf,len)
int fd;
void *buf;
long len;
{
	int ret;
	if(fd!=infd) return read(fd,buf,len);
	ret=block_rwabs(2,buf,len/1024,block,&_hdinf);
	if(ret) return 0;

	block+=len/1024;

	return len;
}

long new_write(fd,buf,len)
int fd;
void *buf;
long len;
{
	int ret;
	if(fd!=infd) return write(fd,buf,len);
	if(!_write_ok) return 0;
	ret=block_rwabs(3,buf,len/1024,block,&_hdinf);
	if(ret) return 0;

	block+=len/1024;
	return len;
}

void new_sync()
{
/* Do nothing */
}

long set_size(blocks)
long blocks;
{
	return set_lrecno(&_hdinf,blocks);
}
