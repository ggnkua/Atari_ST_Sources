/*---------------------------------------------------------------------------------*/
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <windows.h>
#include <math.h>
/*---------------------------------------------------------------------------------*/
#include "datatypes.h"
#include "filestuff.h"
#include "display.h"
#include "bresenham_line.h"

#include "main.h"
/*---------------------------------------------------------------------------------*/


#define BMP_WIDTH  0x12
#define BMP_HEIGHT 0x16



// chunky_to_rgb();

char curr_fname[512];
char curr_stat_fname[512];


int bmp_x,bmp_y;

u8 bmp_data[512][512];


int colorstat[256];

int print_mc_color = 0;


void display_bmp_data()
{
	int x,y;

	for(y=0;y<bmp_y;y++)
	{
		for(x=0;x<bmp_x;x++)
		{
			chunkyBuffer[y][x] = bmp_data[y][x];
		}
	}
	
	chunky_to_rgb();
}

void make_colorstat()
{
	int x,y,c,i;
	int used_colors;
	FILE *foutput;

	foutput = stdout;
	print_mc_color = 0;

	printf("\n\nOutput stats to file ");
	if (get_yes_no() )
	{
		printf("\n\nWriting stats to: %s\n\n",curr_stat_fname);
		foutput = fopen(curr_stat_fname,"w");
	}

	printf("\nOutput used colors/line ");
	if (get_yes_no() )
	{
		print_mc_color = 1;
	}


	for(y=0;y<bmp_y;y++)
	{
		fprintf(foutput, "\n\nline %i\n",y);

		for(i=0;i<256;i++) colorstat[i] = 0;
		
		for(x=0;x<bmp_x;x++)
		{
			c = bmp_data[y][x];
			colorstat[c]++;
		}

		used_colors=0;
		for(i=1;i<256;i++)
		{
			if(colorstat[i])
			{
				used_colors++;
				if(print_mc_color) fprintf(foutput, "%i ",i);
			}
		}
		fprintf(foutput, "\n%i colors\n",used_colors);
	}

	if(foutput!=stdout)
	{
		fclose(foutput);
	}

	printf("\n\nSTATS DONE!\n\n");


//getch();
}




int	load_bmp(char *fname)
{
	u32 r,g,b;
	int i,x,y;
	u8  *p;
	u8  c;
	
	int fsize = get_filesize(fname);
	u8  *bmp_buffer;
	printf("\n\n%s -> %i bytes\n",fname,fsize);

	strcpy(curr_fname,		fname);
	strcpy(curr_stat_fname, fname);
	strcat(curr_stat_fname, ".STATS.TXT");

//	printf("\n%s",curr_stat_fname);
//	getch();


	bmp_buffer = (u8*)malloc(fsize+4096);

	load_file(fname,bmp_buffer);

	bmp_x = read32_LE(BMP_WIDTH  + bmp_buffer);
	bmp_y = read32_LE(BMP_HEIGHT + bmp_buffer);

	printf("\nbmp_x: %i",bmp_x);
	printf("\nbmp_y: %i",bmp_y);

	//colortable
	p =bmp_buffer;
	p+=54;			// skip header
	for(i=0;i<256;i++)
	{
		b=*p++;
		g=*p++;
		r=*p++;
		p++;
		colortable[i] = (r<<16) | (g<<8) | b;
	}

	//gfx data
	p =bmp_buffer;
	p+=1078;	// skip header & colortable
	for(y=0;y<bmp_y;y++)
	{
		for(x=0;x<bmp_x;x++)
		{
			c = *p++;
			bmp_data[bmp_y-1-y][x] = c;
		}
	}


	free(bmp_buffer);

	display_bmp_data();


	make_colorstat();

//	getch();

	return 0;
}