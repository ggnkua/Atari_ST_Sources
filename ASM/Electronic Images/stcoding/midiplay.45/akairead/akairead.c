/*
 *		
 *		(C) 1994 Griff
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

#define DEVICE (13)			/* SCSI Device 5 */
#define SECTORSIZE 2048l
#define NOSECTS 48
char read_buffer[SECTORSIZE * NOSECTS];
char *sam_buffer;
char alpha[] = "0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ";

typedef struct
{	char	name[12];
	long	offset;
} akai_dir_entry;
void do_read(char *buf,long start,long sectors)
{	while (sectors > 256)
	{	DMAread(start,256,buf,DEVICE);
		start += 256;
		sectors -= 256;
		buf += (256*SECTORSIZE);
	}
	if (sectors > 0)
		DMAread(start,sectors,buf,DEVICE);
}

char partition_directory[100][16];
void main(void)
{		register long i,j,off,num;
		sam_buffer = malloc((long) 2000*SECTORSIZE);
		while(DMAread(0,NOSECTS,&read_buffer[0],DEVICE)!=0);
		{		unsigned char *p = &read_buffer[202];
				for (i=	0 ; i < 100 ; i++)
				{		for (j=0 ; j<12 ; j++)
							p[j] = alpha[p[j]];
						off = ( ((unsigned long)p[15]<<8) | ((unsigned long)p[14]))*4;
						num = 1;
						p+=16;
						do_read(sam_buffer,off,num);
						for (j =0 ; j < num*SECTORSIZE ; j++)
							sam_buffer[j]= alpha[sam_buffer[j]];

						/*{	long handle;
							if ((handle = Fcreate("e:\\test.dat",0)) >=0 ) 
							{	Fwrite(handle,2000*SECTORSIZE,sam_buffer);
								Fclose(handle);
							}
						}*/			
				}
		}
}
