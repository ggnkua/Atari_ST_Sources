
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>
#include <math.h>
#include <conio.h>

#include "main.h"
#include "datatypes.h"
#include "filestuff.h"
#include "arj_convert.h"
#include "image.h"

u8 image[1024*1024];

u8 b512[512];
u8 disk_info_buffer[512];

#define MAX_FILES 31
#define KERNEL_SECTORS 6

int sectors	= 10;
int tracks	= 80;	//0...80
int sides	= 2;

int max_secside = sectors*(tracks+1);
int max_sectors = max_secside*sides;

int image_size;

u8 * ak_dir_adress;

int start_logic_sector;




void logic_sector_to_physsec(int log_sec,int *sector,int *track,int *side)
{
	*sector = 1+(log_sec%sectors);
	*side   = log_sec/max_secside;
	*track	= (log_sec%max_secside)/sectors;
}


void write_sector(int trk, int sec, int side, u8 *buffer)
{
	int offset;
	u8 *img = image;
	offset = (sec-1) + trk*sides*sectors + side*sectors;
	offset = offset*512;
	
	img+=offset;
	memcpy(img,buffer,512);
}

void read_sector(int trk, int sec, int side, u8 *buffer)
{
	int offset;
	u8 *img = image;
	offset = (sec-1) + trk*sides*sectors + side*sectors;
	offset = offset*512;
	
	img+=offset;
	memcpy(buffer,img,512);
}

void write_boot()
{
	u8 *boot_in,*boot,*p;
	int i;
	u16 c;
	boot_in = (u8*)(calloc(4096,1));
	boot	= (u8*)(calloc(4096,1));

	load_file(boot_fn,boot_in);
	
	read_sector(0,1,0,boot);
	boot[0] = 0x60;		// boot branch
	boot[1] = 0x1C;

	p=boot+0x1E;
	for(i=0;i<512-0x1e-2;i++)
	{
		*p++=boot_in[i];
	}

	// make checksum
	p=boot;
	c=0;
	for(i=0;i<510/2;i++)
	{
		c+= read16(p); p+=2;
	}
	c=0x1234-c;
	write16(p,c);

	write_sector(0,1,0,boot);

	free(boot_in);
	free(boot);
}

void write_kernel()
{
	u8 *kernel;
	int i;
	int log_sec,sector,track,side;

	i = get_filesize(kernel_fn);
	kernel = (u8*)(calloc(i+4096,1));
	load_file(kernel_fn,kernel);

	log_sec = 2;
	for(i=0;i<KERNEL_SECTORS;i++)
	{
		logic_sector_to_physsec(log_sec,&sector,&track,&side);
		write_sector(track,sector,side, kernel+i*512);
		log_sec++;
	}
}



void init_disk()
{
	char idf[] = "--------.---";	// 12 bytes
	int i,j;
	u8 *p = b512;

	write16(p,sectors); p+=2;	// start of first free sector

	for(i=0;i<MAX_FILES;i++)
	{
		for(j=0;j<12;j++) *p++=idf[j];
		write16(p,0); p+=2;		// start log. sector
		write16(p,0); p+=2;		// length in sectors
	}

	write_sector(0,2,0,b512);
}

void load_disk_info()
{
	read_sector(0,2,0,disk_info_buffer);
}

void save_disk_info()
{
	write_sector(0,2,0,disk_info_buffer);
}

int get_dir_adress()
{
	int i;
	u8 *p = disk_info_buffer;

	start_logic_sector = read16(disk_info_buffer);

	p+=2;	// start logic sector

	for(i=0;i<MAX_FILES;i++)
	{
		if(*p=='-')		// free?
		{
			ak_dir_adress = p;
			write16(p+12,start_logic_sector);	// file start
			return 0;
		}
		p+=16;		// next entry
	}
	printf("\n\n**ERROR** Not enough space for directory!");
	getch();
	return -1;
}




void copy_filename_to_dir(char *fname)
{
	char c;
	u8 *p;
	int i,j,k;
	int slen=strlen(fname);

	for(i=slen-1;i>=0;i--)
	{
		c = fname[i];
		if(c=='\\')
		{
			i++;
			break;
		}
	}

	p = ak_dir_adress;

	for(j=0;j<12;j++) p[j]=' ';
	p[8] = '.';

	k = 0;							// output index
	for(j=0;j<8+1+3;j++)
	{
		if(fname[j+i] == 0) break;

		if(fname[j+i] == '.')
		{
			p = ak_dir_adress+9;	// extension
			k=0;					// reset index
		}
		else
		{
			p[k] = fname[j+i];
			k++;					// inc index
		}
	}
}


int write_file_to_disk(char *fname)
{
	int file_length,i,j;
	int sek_length;
	int log_sec;
	int sector,track,side;

	u8 *load_buffer;
	u8 *p;

	load_disk_info();
	get_dir_adress();
	copy_filename_to_dir(fname);

	file_length = get_filesize(fname);
	load_buffer = (u8*)calloc(file_length+4096,1);
	load_file(fname,load_buffer);

	// round to 512 boundary
	i = file_length&511;
	if(i!=0)
	{
		file_length+=512-i;
	}

	sek_length = file_length/512;

	write16(ak_dir_adress+2+12, sek_length); // amount sectors

	log_sec = read16(ak_dir_adress+12);

	logic_sector_to_physsec(log_sec,&sector,&track,&side);

	
	// start writing to image
	p = load_buffer;
	for(i=0;i<sek_length;i++)
	{
		logic_sector_to_physsec(log_sec,&sector,&track,&side);
		write_sector(track,sector,side, p);

		j = 1+read16(disk_info_buffer); write16(disk_info_buffer,j);
		log_sec++;
		p+=512;
	}

	save_disk_info();

	free(load_buffer);
	return 0;
}

int load_imagefile()
{
	image_size = get_filesize(image_fn);

	load_file(image_fn,image);

	init_disk();

	return 0;
}

int save_imagefile()
{
	int secused;

	printf("\nsaving image file: %s",image_fn);

	save_file(image_fn,image,image_size);

	secused = read16(disk_info_buffer);

	printf("\nsectors used: %i / %i",secused, max_sectors);
	printf("\nbytes left  : %i\n",(max_sectors-secused)*512);


	//printf("\n%i --> %i\n",max_sectors,max_sectors*512);

	return 0;
}