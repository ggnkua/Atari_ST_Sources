/*
 *		
 *		(C) 1994 Griff
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>

#define DEVICE (13)			/* SCSI Device 5 */
#define SECTORSIZE 2048l
#define NOSECTS 48
unsigned char read_buffer[SECTORSIZE * NOSECTS];
unsigned char sam_data[500000l];
unsigned char *sam_buffer;
char alpha[] = "0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ";

typedef struct
{	char	name[12];
	long	offset;
} akai_dir_entry;

void save_file(char *name,char *buf,long length)
{	long handle;
	if ((handle = Fcreate(name,0)) >=0 ) 
	{	
		Fwrite(handle,length,buf);
		Fclose(handle);
	}
}

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
{	register long i,j,k,off,num;
	sam_buffer = malloc((long) 4000*SECTORSIZE);
	/*do_read(sam_buffer,0,4000);
	save_file("f:\akai.dat",sam_buffer,4000*SECTORSIZE);
	return;*/
	
	while(DMAread(0,NOSECTS,&read_buffer[0],DEVICE)!=0);
	{		unsigned char *p = &read_buffer[202];
			for (i=	0 ; i < 100 ; i++)
			{		for (j=0 ; j<12 ; j++)
					{	p[j] = alpha[p[j]];
						putchar(p[j]);
					}	
					putchar('\n');
					off = ( ((unsigned long)p[15]<<8) | ((unsigned long)p[14]))*4;
					p+=16;
					do_read(sam_buffer,off,1);
					for (j =0 ; j < SECTORSIZE ; j+=24)
					{	for (k = 0 ; k < 12 ; k++)
						{	sam_buffer[k+j]= alpha[sam_buffer[k+j]];
							putchar(sam_buffer[k+j]);
						}
						putchar(' ');
						off = ( ((unsigned long)sam_buffer[j+21]<<8) + ((unsigned long)sam_buffer[j+20]))*8;
						num = ( ((unsigned long)sam_buffer[j+19]<<16) + ((unsigned long)sam_buffer[j+18]<<8) + ((unsigned long)sam_buffer[j+17]));
						printf("%lu %lu\n",off,num);
						
					}
			}
	}
}
