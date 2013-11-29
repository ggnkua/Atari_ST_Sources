/* **** IMG Lader - Dank an Alexander Kirchner, der mit Thrust **** */
/* **** einen (Oberon-)Source eines IMG-Laders verteilt hat.   **** */

#include <osbind.h>
#include <vdi.h>

#include <string.h>

#include "st_debug.h"

#ifndef NULL
#define NULL 0L
#endif
#ifndef FALSE
#define FALSE 0
#define TRUE (!0)
#endif


short hw2vdic8[256]={ 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,255,16,
 17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,
 33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,
 49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,
 65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,
 81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,
 97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,
 113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,
 129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,
 145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,
 161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,
 177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,
 193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,
 209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,
 225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,
 241,242,243,244,245,246,247,248,249,250,251,252,253,254,1 };
short hw2vdic4[16]={ 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1 };
short hw2vdic2[4]={ 0,2,3,1 };

/* Der Kopf einer IMG-Datei: */
typedef struct
{
 short Version;
 short Length;
 short Planes;
 short PatternLength;
 short PixelWidth;
 short PixelHeight;
 short LineWidth;
 short Lines;
} IMGHEAD;

/* Der Kopf einer XIMG-Datei: */
typedef struct
{
 short Version;
 short Length;
 short Planes;
 short PatternLength;
 short PixelWidth;
 short PixelHeight;
 short LineWidth;
 short Lines;
 long  palmagic;   /* = 'XIMG' */
 short color_model;
} XIMGHEAD;


/* *** IMG entpacken *** */
void Decompress(IMGHEAD *img, char *dest)
{
 short repetitions, count, k, l, p, z, LineBytes, LineB2;
 unsigned char *source;
 long i, j, off, PlaneBytes;

 source = (unsigned char *)img + 2 * img->Length;
 LineBytes = (img->LineWidth + 7) / 8;
 LineB2 = (img->LineWidth + 15) / 16 * 2;
 PlaneBytes = (long)LineB2 * img->Lines;
 i = 0; z = 0;

 do /* FÅr jede Zeile */
  {
   repetitions = 1;
   if( source[i]==0 && source[i+1]==0 && source[i+2]==255 )
    {
     repetitions = source[i+3];
     i+=4;
    }

   for( p = 0; p <= img->Planes-1; p++) /* FÅr jede Farbebene */
    {
     off = (long)p * PlaneBytes + (long)z * LineB2;
     j = 0;
     do
      {
       if( source[i]==0 ) /* Pattern Run */
        {
         ++i; count = source[i];
         for( k = 1; k <= count; k++)
           for( l = 1; l <= img->PatternLength; l++)
             { dest[j+off] = source[i+l]; ++j; }
         i+=img->PatternLength + 1;
        }
        else if(source[i]==128) /* Bitstring */
        {
         ++i; count = source[i]; ++i;
         for( k = 1; k <= count; k++)
          {
           dest[j+off] = source[i]; ++j; ++i;
          }
        }
        else if( source[i] < 128 ) /* Solid Run mit 0 */
        {
         count = source[i] % 128; ++i;
         for( k = 1; k<=count; k++)
          {
           dest[j+off] = 0; ++j;
          }
        }
        else /* Solid Run mit 1 */
        {
         count = source[i] % 128; ++i;
         for( k = 1; k<=count; k++)
          {
           dest[j+off] = 255; ++j;
          }
        }
      }  
     while( j < LineBytes);
    } /* Farbebene */

   ++z;

   while( repetitions > 1)
    {
     --repetitions;
     for(p = 0; p <= img->Planes-1; p++)
      {
       off = (long)p * PlaneBytes + (long)z * LineB2;
       for( k = 0; k <= LineB2-1; k++)
          dest[off+k] = dest[off+k-LineB2];
      }
     ++z;
    }

  }
 while( z < img->Lines );
}


/* *** Die Laderoutine *** */
int LoadImg(char *Filename, MFDB *raster)
{
 IMGHEAD *img;
 long Length;
 int fhndl;

 fhndl=Fopen(Filename, 0);
 if(fhndl<0) return(fhndl);
 Length=Fseek(0L, fhndl, 2);
 Fseek(0L, fhndl, 0);
 img=(void *)Mxalloc(Length, 0);
 if( ((signed long)img)==-32L )  img=(void *)Malloc(Length);
 if( (signed long)img<=0L) { Fclose(fhndl); return((int)img); }
 Fread(fhndl, Length, img);		/* IMG einlesen */
 Fclose(fhndl);

 raster->fd_w = img->LineWidth;
 raster->fd_h = img->Lines;
 raster->fd_wdwidth = (raster->fd_w + 15) / 16;
 raster->fd_stand = 1;
 raster->fd_nplanes = img->Planes;

 Length=(long)raster->fd_wdwidth * 2L * raster->fd_h * raster->fd_nplanes;
 raster->fd_addr=(void *)Mxalloc(Length, 0);
 if( ((signed long)raster->fd_addr)==-32L )
   raster->fd_addr=(void *)Malloc(Length);
 if( (signed long)raster->fd_addr<=0L )  return((int)raster->fd_addr);

 Decompress(img, raster->fd_addr);

 Mfree(img);
 return(0);
}


/* *** Palette aus XIMG auslesen *** */
int getximgpal(char *filename, int pal[][3])
{
 XIMGHEAD ximg;
 int fhndl;
 int i,j;

 fhndl=Fopen(filename, 0);
 if(fhndl<0) return(fhndl);
 Fread(fhndl, sizeof(XIMGHEAD), &ximg);		/* IMG einlesen */

 if(ximg.palmagic!=0x58494D47L || ximg.color_model!=0)  /* 0x58494D47L='XIMG' */
  { Fclose(fhndl); return(1); }

 if(ximg.Planes>1 && ximg.Planes<=8)
  for(i=0; i<(1<<ximg.Planes); i++)
   {
    switch(ximg.Planes)
     {
      case 2: j=hw2vdic2[i]; break;
      case 4: j=hw2vdic4[i]; break;
      case 8: j=hw2vdic8[i]; break;
      default: j=i; break;
     }
    Fread(fhndl, 6L, &pal[j][0]);
   }
 Fclose(fhndl);

 return 0;
}



#if 1 /* Use new routine */


/*  The new transform truecolor
 *
 *  This routine borrows heavily on two sources.
 *  1. Mario Becrofts transform function
 *  2. Eero Tammiens dither function
 *
 *  Marios routine never worked for me properly under PureC,
 * it's very possible that was my fault.  However on reflection
 * I saw that what he was doing was very similar to the dither
 * routine I was already using.  So I used Mario Becrofts strategy
 * combined with Eero Tammiens tactics and came up with the following
 * routine.
 * 
 *  I can see the possibility of a few minor tweaks that may make
 * this routine faster.  For the moment I'm happy with it.  Its significantly
 * faster than the old one I wrote (which still exists in the code for
 * anyone interested in porting this program to a non motorola platform)
 * 
 *  variables
 * MFDB *image -> MFDB of the image we want to convert to the current bit depth
 * size		   -> size of buffer of the image. (could probably reconstruct, but
 *												we already have this value beforehand)
 * planes	   -> Number of planes = current bit depth
 * img_handle  -> Our VDI_handle for vdi functions	
 *
 * Dan Ackerman ( March 7, 2000)
 */


int 
transform_truecolor( MFDB *image, long size, int planes, int img_handle)
{
 int i, bit, color, mask;
 short first_plane[32], *plane, *idx, *new_addr;
 short *color_table, *bit_location, *temp_addr;
 int tot_colors = (1 << image->fd_nplanes);
 char used_colors[256];
 int x, y;
 MFDB tempscreen;
 MFDB temp;
 int pxy[8], colors[2];
 long temp_size, j;
 int oldplanes;

 oldplanes = image->fd_nplanes;
/*  
  if (image->fd_nplanes == 1)
	return(mono_transform(image, size, planes, img_handle, 1, 0));
*/
  /* memory for the device raster */
  if( (long)(new_addr = (short *) Malloc( (size << 1) * planes )) <= 0L )
    return( FALSE );

/*  memset(new_addr,0,((size << 1) * planes));*/	/*	-> fill with 0-planes */
/* Sozobon memset does not like long counters... */
  temp_addr=new_addr;
  for(j=0; j<size*planes; j++)
   *temp_addr++=0;

  /* fill in the descriptions   */
  image->fd_nplanes = planes;
  tempscreen = *image;		/* copy MFDB       */
  image->fd_stand = 1;	/* standard format */
  tempscreen.fd_addr = new_addr;

  temp = *image;
  temp.fd_stand = 0;
  temp.fd_nplanes = 1;
  temp.fd_h = tot_colors;

  temp_size = tot_colors * temp.fd_wdwidth;
  temp_size <<= 1;

  if( (long)(temp_addr = (short *) Malloc(temp_size)) <= 0L )
   	return( FALSE );

  memset(temp_addr,255,(size_t)temp_size);	/*	-> fill with 0-planes */
  
  temp.fd_addr = temp_addr;
  
  pxy[0] = pxy[4] = 0;
  pxy[1] = pxy[5] = 0;
  pxy[2] = pxy[6] = image->fd_w-1;
  pxy[3] = pxy[7] = image->fd_h-1;

  /* If you don't do the following monochrome images are inverted */
  colors[1] = 0;

  mask = tot_colors - 1;

  idx = (short *)image->fd_addr;
  
  bit_location = color_table = (short *)temp_addr;
  
  for (y=0; y < image->fd_h; y++)
	{
		memset(temp_addr,0,(size_t)temp_size);
		memset(used_colors, 0, sizeof(used_colors) );
	
		for (x = 0; x < image->fd_wdwidth; x++)
		{
		    /* go through all bitplanes */
		    plane = first_plane;

		    for( i = 0; i < image->fd_nplanes; i ++ )
		    {
		      /* get one word from a bitplane */
		      *(plane ++) = *(idx + size * (long)i);
		    }

		    /* go through one word */
		    for( bit = 15; bit >= 0; bit -- )
		    {
		      color = 0;
		      plane = first_plane;

		      /* OR all 'bit' bits from all bitplanes together */
		      for( i = 0; i < image->fd_nplanes; i ++ )
		        color |= ((*(plane ++) >> bit) & 1) << i;
      
			  color &= mask;

		      used_colors[color] = 1;

		      bit_location =  (short *)(color_table + (temp.fd_wdwidth * (long)color) + x);
	
		      *bit_location |= 1 << bit;
			}

			idx++; /* increment idx */
		}

	    /* if we've gone to the end of a row update now */

		pxy[5] = pxy[7] = y;

		for (i=0;i<tot_colors;i++)
		{
		  	if(used_colors[i])
		  	{
				switch(oldplanes)
				 {
				  case 2: colors[0]=hw2vdic2[i]; break;
				  case 4: colors[0]=hw2vdic4[i]; break;
				  case 8: colors[0]=hw2vdic8[i]; break;
				  default: colors[0]=i; break;
				 }
			  	pxy[1] = pxy[3] = i;
		  	  	vrt_cpyfm( img_handle, MD_TRANS, pxy, &temp, &tempscreen, colors );
			}

		}

	}

  Mfree(temp_addr);
  Mfree(image->fd_addr);
  image->fd_stand = 0;	/* standard format */

  image->fd_addr = new_addr;
  return( TRUE );
}



#else   /* Old routine follows */


/*
 * transform_truecolor
 *
 * MFDB *image -> image of bitmap you want converted
 * long size -> size in words of necessary buffer
 * int planes -> number of planes you wish to convert bitmap to
 * int img_handle -> vdi_handle for current work
 *
 * This routine isn't the fastest thing on the planet but it works
 * and should be readily understandable.
 *
 * Mario Becroft has a routine that is much faster in a lib
 * he is working on at the moment.
 * However he's not quite ready to release it yet (august 1999)
 *  - Dan Ackerman (baldrick@netset.com) august 1999
 */

int transform_truecolor(MFDB *image, long size, int planes, int img_handle)
{
  char *new_addr, *monotmp;
  MFDB tempscreen;
  MFDB temp;
  MFDB monotemp;
  int pxy[8];
  int colors[2];
  register int i,ccount;
  int tot_colors = (1 << image->fd_nplanes);
  int oldplanes;
  char *plane8, *plane7, *plane6, *plane5, *plane4, *plane3, *plane2, *plane1;

  oldplanes = image->fd_nplanes;

  /* convert size from words to bytes */
  size <<= 1;

  /* memory for the device raster */
  if( (new_addr = (char *) Malloc( size * planes )) <= NULL )
    return( FALSE );

  memset(new_addr,0,(size * planes));	/*	-> fill with 0-planes */

  if( (monotmp = (char *) Malloc( size)) <= NULL )
	return( FALSE );

  memset(monotmp,0,(size));
		
  /* fill in the descriptions   */
  image->fd_nplanes = planes;
  tempscreen = *image;		/* copy MFDB       */
  image->fd_stand = 1;	/* standard format */
  tempscreen.fd_addr = new_addr;

  monotemp = temp = *image;
  monotemp.fd_stand = temp.fd_stand = 0;
  monotemp.fd_nplanes = temp.fd_nplanes = 1;
  pxy[0] = pxy[4] = 0;
  pxy[1] = pxy[5] = 0;
  pxy[2] = pxy[6] = image->fd_w - 1;
  pxy[3] = pxy[7] = image->fd_h - 1;

  
  /* If you don't do the following monochrome images are inverted */
  if (oldplanes == 1)
  	{
  	  colors[0] = 0;
	  colors[1] = 1;
	 }	
  else
  	{
  	  colors[0] = 0;
	  colors[1] = 0;
	}
	
  vrt_cpyfm( img_handle,MD_REPLACE,pxy,&temp,&tempscreen,colors);

  monotemp.fd_addr = monotmp;

  if(oldplanes > 1)
  	{
		plane1 = (char*)image->fd_addr;
		plane2 = (char*)image->fd_addr + size;
		plane3 = (char*)image->fd_addr + (size * 2);
		plane4 = (char*)image->fd_addr + (size * 3);
		plane5 = (char*)image->fd_addr + (size * 4);
		plane6 = (char*)image->fd_addr + (size * 5);
		plane7 = (char*)image->fd_addr + (size * 6);
		plane8 = (char*)image->fd_addr + (size * 7);
		
		for (i = 1; i < tot_colors; i++)
			{
				/* set ccount to current index */
				ccount = i;
			
				/*evnt_timer(0,0);*/
			
				memset(monotmp,255,(size));

				if (tot_colors > 16)
					{
						if (ccount & 0x80)
							{
						  		temp.fd_addr = plane8;
								vro_cpyfm( img_handle,S_AND_D,pxy,&temp,&monotemp);
							}
							
						if (ccount & 0x40)
							{
								temp.fd_addr = plane7;
						  		vro_cpyfm( img_handle,S_AND_D,pxy,&temp,&monotemp);
							}
						
						if (ccount & 0x20)
							{
								temp.fd_addr = plane6;
						  		vro_cpyfm( img_handle,S_AND_D,pxy,&temp,&monotemp);
							}
							
						if (ccount & 0x10)
							{
								temp.fd_addr = plane5;
								vro_cpyfm( img_handle,S_AND_D,pxy,&temp,&monotemp);
							}
					}	

				if (ccount & 0x08)
					{
						temp.fd_addr = plane4;
						vro_cpyfm( img_handle,S_AND_D,pxy,&temp,&monotemp);
					}
							
				if (ccount & 0x04)
					{
						temp.fd_addr = plane3;
						vro_cpyfm( img_handle,S_AND_D,pxy,&temp,&monotemp);
					}
							
				if (ccount & 0x02)
					{
						temp.fd_addr = plane2;
						vro_cpyfm( img_handle,S_AND_D,pxy,&temp,&monotemp);
					}
							
				if (ccount & 0x01)
					{
						temp.fd_addr = plane1;
						vro_cpyfm( img_handle,S_AND_D,pxy,&temp,&monotemp);
					}

				switch(oldplanes)
				 {
				  case 2: colors[0]=hw2vdic2[i]; break;
				  case 4: colors[0]=hw2vdic4[i]; break;
				  case 8: colors[0]=hw2vdic8[i]; break;
				  default: colors[0]=i; break;
				 }
			
				vrt_cpyfm(img_handle,MD_TRANS,pxy,&monotemp,&tempscreen,colors);
			}
  	}

  Mfree(monotmp);
  Mfree(image->fd_addr);

  /* change image description */
  image->fd_stand = 0;		/* device format */
  image->fd_addr = new_addr;

  return( TRUE );

}

#endif
