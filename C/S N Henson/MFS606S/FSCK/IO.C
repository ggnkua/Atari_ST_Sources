/* The functions read_blocks(start,count,buff) and write_blocks(), read/write
 * 'count' 1K blocks from disk starting at block 'start' into the buffer
 * pointed to by 'buff' . The function init_device(name,rw) initialises the 
 * device 'name' so that read_blocks() and write_blocks() use it. Since this
 * is called once initially, any other machine dependent initialisation can be
 * put here, if it returns non-zero then the operation failed. If 'rw' is not
 * zero, write access is sought also for this device. The function set_size is
 * used to tell the I/O routines the size of the filesystems being accessed,
 * so any special arrangements can be made. If this function rewturns non-zero
 * then the operation failed and the filesystem cannot be accessed.
 */

#ifdef atarist

#include <stdio.h>
#include <mintbind.h>
#include "fs.h"
#include "global.h"
#include "proto.h"

int _device,_write_ok,shift;

void read_blocks(start,count,buff)
long start;
unsigned count;
void *buff;
{

	long ret;
	ret=block_rwabs(0,buff,count,start,&hdinf);
	if(ret) printf("Rwabs read returned %ld\n",ret);
}

void write_blocks(start,count,buff)
long start;
unsigned count;
void *buff;
{
	long ret;
if(start==0){
 printf("Illegal Write\n");
return;
}
	if(!_write_ok)
	{
		printf("Internal error : Illegal write\n");
		printf("Start %ld Count %d\n",(long)start,count);
		return;
	}
	modified=1;
	ret=block_rwabs(1,buff,count,start,&hdinf);
	if(ret) printf("Rwabs write returned %ld\n",ret);
}

int init_device(name,rw)
char *name;
int rw;
{
	long err;
	if(name[1]==':')
	{
		struct 
		{
			long start;
			long finish;
			char shadow;
			char scsiz;
		} pp;
		_device=(name[0]-'A') & ~32;
		if( (_device < 0) || (_device > 32) ) return 1;
		Dcntl(0x109,name,&pp);
		if(pp.start!=-1) /* Is this a physical partition ? */
		{
			hdinf.start=pp.start;
			hdinf.size=pp.finish-hdinf.start+1;
			hdinf.scsiz=pp.scsiz;
			hdinf.major = pp.shadow;
			(void)Getbpb(_device); 	/* Satisfy disk changes */
			hdinf.rwmode = RW_PHYS;
			if(hdinf.start > 0xfff0)
			{
				if(no_plrecno(hdinf.major)) return 1;
				hdinf.rwmode |= RW_LRECNO;
			}
		}
		else if( (err=get_hddinf(_device,&hdinf,0)) ) 
		{
			fprintf(stderr,"Drive %s %s\n",name,hdd_err[err]);
			return 1;
		}
		if(rw) _write_ok=1;

		Dcntl(0x10b,name,1);	/* Suspend update */
		/* Sync the filesytem and lock the device */
		if(Dcntl(0x101,name,0) || Dlock(1,_device) )
		{
			close_device();
			return 1;
		}
		return 0;
	}
	return 1;
}

void close_device()
{
	extern char *drvnam;
	(void) Dlock(0,_device);	/* Unlock drive */
	Dcntl(0x10b,drvnam,2);		/* Restart update */
}

int set_size(nblocks)
long nblocks;
{
	return set_lrecno(&hdinf,nblocks);
}

#endif
