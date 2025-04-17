/* Minix fixup , a quick hack to permit MINIX partitions to be (hopefully)
 * read by older versions of AHDI with a MiNT minix.xfs combination.
 */

/* This program was written by S N Henson in November 1991 and is released
 * into the public domain. Do what you want with it . If you want to be nice
 * keep my name attached to it, please.
 */

#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>

unsigned buf[512];

unsigned char *bfr=(unsigned char *)buf;

/* Change these lines if the magic number ever changes */

#define MAGIC_V1 0x137f

#define MAGIC_V2 0x2468

main(argc,argv)
int argc;
char **argv;
{
	int fd,i;
	char *fnam;
	int force;

	if(argc!=2 && argc!=3)
	{
		fprintf(stderr,"Usage : %s [-f] (device)\n",argv[0]);
		exit(1);
	}

	if(argc==3)
	{
		if(strcmp(argv[1],"-f"))
		{
			fprintf(stderr,"Invalid option %s\n",argv[2]);
			exit(1);
		}
		fnam=argv[2];
		force=1;
	}
	else
	{
		fnam=argv[1];
		force=0;
	}

	fd=open(fnam,O_RDWR);
	if(fd<0)
	{
		fprintf(stderr,"Cant open %s\n",argv[1]);
		exit(1);
	}

	/* OK , seek and read in the super block */

	lseek(fd,1024l,0);
	read(fd,buf,1024);
	
	if( (buf[8]!=MAGIC_V1) && (buf[8]!=MAGIC_V2) )
	{
		fprintf(stderr,"Fatal , invalid super block magic number\n");
		exit(1);
	}

	/* Now read in the boot block and check sector size */

	lseek(fd,0l,0);
	read(fd,buf,512);
	
	if(bfr[11]!=0 || bfr[12]!=2)
	{

		if(force)
		{
			bfr[11]=0;
			bfr[12]=2;
		}
		else
		{
			fprintf(stderr,"Sector size not 512 bytes.\n");
			fprintf(stderr,"Use the -f option to force sector\n");
			fprintf(stderr,"size to 512 if you really want to do this.\n");
			exit(1);
		}
	}

	/* 1 sector per FAT */
	bfr[22]=1;
	bfr[23]=0;

	/* 2 FATs */
	bfr[16]=2;

	/* 16 root dir entries==1 sector */
	bfr[17]=16;
	bfr[18]=0;

	/* write it out */
	lseek(fd,0l,0);
	write(fd,buf,512);

	/* Clear buffer and setup pseudo root directory */

	bzero(bfr,512);

	/* Fill up the pseudo root dir with volume labels */
	for(i=0;i<16;i++)
	{
		strcpy(&bfr[i<<5],"MINIXFS");
		bfr[11+(i<<5)]=0x08;
	}

	/* Finally write it out */
	lseek(fd,1536l,0);
	write(fd,buf,512);

	close(fd);

	exit(0);
}
