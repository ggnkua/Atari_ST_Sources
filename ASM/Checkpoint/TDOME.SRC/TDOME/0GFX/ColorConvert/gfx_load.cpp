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


u32 remap_colortable[256];


int bmp_x,bmp_y;

u8 bmp_data[512][512];


//int colorstat[256];

typedef struct colorstat_struct
{
	int index;
	int count;
}colorstat_struct;

colorstat_struct colorstat[256];


typedef struct rgb_table_struct
{
	int r,g,b;
}rgb_table_struct;

rgb_table_struct rgb_table16[16];
rgb_table_struct rgb_table256[256];



int print_mc_color = 0;

int used_colors;


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



void display_colorstat()
{
	int i;
	printf("\ncurrent colorstat:\n");
	for(i=0;i<256;i++)
	{
		if(colorstat[i].count) printf("(%i):%i ",colorstat[i].index, colorstat[i].count);
	}
}


void make_colorstat(int y)
{
	int i,c,x;
	for(i=0;i<256;i++)
	{
		colorstat[i].index = i;
		colorstat[i].count = 0;
	}
		
	for(x=0;x<bmp_x;x++)
	{
		c = bmp_data[y][x];
		colorstat[c].count++;
	}

	used_colors=0;
	for(i=1;i<256;i++)
	{
		if(colorstat[i].count) used_colors++;
	}
}


void swap_int(int *a, int *b)
{
	int t=*a;
	*a=*b;
	*b=t;
}

void sort_colorstat()
{
	// lame bubblesort
	int i,k;
	int index,count;
	for(i=0;i<256;i++)
	{
		index = colorstat[i].index;
		count = colorstat[i].count;

		for(k=i+1;k<256;k++)
		{
			if(colorstat[k].count>count)
			{
				swap_int( &(colorstat[i].index), &(colorstat[k].index) );
				swap_int( &(colorstat[i].count), &(colorstat[k].count) );
				index = colorstat[i].index;		// update variables
				count = colorstat[i].count;
			}
		}
	}
}



int process16_line_DEBUG = 0;


void crgb_to_rgb(u32 crgb, int *r, int *g, int *b)
{
	*r = (crgb>>16)&255;
	*g = (crgb>>8)&255;
	*b = (crgb)&255;
}


void make_remap16_colortable()
{
	int i,j;
	int index;
	int crgb;
	int ri,gi,bi;
	int rj,gj,bj;
	int distance,distance_min;
	int min_index;

	// remap_colortable

	for(i=0;i<256;i++)
	{
		crgb = colortable[i];
		crgb_to_rgb(crgb, &ri,&gi,&bi);

		distance_min	= 0x7fffffff;
		min_index		= 0;

		for(j=0;j<16;j++)
		{
			index = colorstat[j].index;
			crgb  = colortable[index];
			crgb_to_rgb(crgb, &rj,&gj,&bj);
			
			rj = (rj-ri);
			gj = (gj-gi);
			bj = (bj-bi);
			distance = rj*rj + gj*gj + bj*bj;

			if(distance<distance_min)
			{
				distance_min	= distance;
				min_index		= index;
			}
		}

		crgb = colortable[min_index];
//crgb = (ri<<16) | (gi<<8) | bi;
		remap_colortable[i] = crgb;
	}

}


void remap16_line(int y)
{
	int x,c,crgb;

	make_remap16_colortable();

	for(x=0;x<bmp_x;x++)
	{
		c = bmp_data[y][x];

//		crgb = (r<<16) | (g<<8) | b;

		rgbBuffer[y][x] = remap_colortable[c];
	}
}


void process16_line(int y)
{
	make_colorstat(y);

if(process16_line_DEBUG)
{
printf("\nline %i : %i",y,used_colors);
}

//	display_colorstat();

	sort_colorstat();

//	display_colorstat();

	remap16_line(y);

//	getch();

}


void make_colorstat()
{
	int x,y,c,i;
	int used_colors;
	FILE *foutput;

	foutput = stdout;
	print_mc_color = 0;
/*
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
*/

	for(y=0;y<bmp_y;y++)
	{
		process16_line(y);
	}


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

		rgb_table256[i].r = r;
		rgb_table256[i].g = g;
		rgb_table256[i].b = b;
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

	// display_bmp_data();


	make_colorstat();

//	getch();

	return 0;
}