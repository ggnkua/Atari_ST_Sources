/***************************************************************************
 *                           TGA to CRY convertor                          *
 ***************************************************************************
 *   Copyright (C) 2005 by                                                 *
 *   Reimund Dratwa <ray@tscc.de>                                          *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 ***************************************************************************/

#include <stdio.h>
#include <string.h>
#include "tga2cry.h"


int abs_(s16 a) {
	if (a < 0) return -a; else return a;
}


/*******************************************
*  24bpp RGB to 16bpp CRY conversion routine
*******************************************/

s16 HASH[65536];	/* Color hashing table for faster conversion */

void rgbToCry(u16 width, u16 height, pel src[], u8 dst[]) {
	u16 x,y;

	u16 RC,GC,BC,Y;
	s16 C;
	u16 match,delta,newdelta;

	memset(HASH,0xff,65535*sizeof(s16));

	for (y=0;y<height;y++) {
	
		printf("%3d%%\b\b\b\b",(y+1)*100/height);
		
		for (x=0;x<width;x++) {

			
			
			/* Compute the color's luminacne component (Y = max(r,g,b) )*/
			Y = src->r;
			if (src->g > Y) Y = src->g;
			if (src->b > Y) Y = src->b;				

			/* Normalize RGB vector discarding the luminance component */
			if (Y != 0) {
				RC = (u16)(src->r)*255/Y;
				GC = (u16)(src->g)*255/Y;
				BC = (u16)(src->b)*255/Y;
 	  			
 	  			/* Compute the color's C-R component by searching the closest
				   match in the CRY color table, added some hashing to improve
				   the conversion speed here. */
		
				if ((C=HASH[((RC>>3)<<11)|((GC>>2)<<5)|(BC>>3)]) == -1) { /* New color? */
				   
					C = 1;delta = 0x3fff;				   
					for (match=1;match<256;match++) {
					    if ((newdelta =
					    	 abs_(RC-cry[match*3])+abs_(GC-cry[match*3+1])+abs_(BC-cry[match*3+2])) <= delta) {
					        	delta = newdelta;
				        		C = match;
				        	}
					}
					/* Register Cr value */
					HASH[((RC>>3)<<11)|((GC>>2)<<5)|(BC>>3)] = C;
				}

				} else {
				   C = 128+7;
 	  			}
				

				src++;
				*dst++ = C;*dst++ = Y;

		}
	}

}


/*******************************************
* Main program
*******************************************/

int main(int argc, char * argv[]) {

	FILE * infile;
	FILE * outfile;

	targa tga;
	u32 type,p,len;
	u16 width, height, x, y;

	u16 * dst;		/* Destination image 16bit CRY */
	pel * src;
	char in[80], out[80];
	char * inp = in, * outp = out;
	char * i = argv[1], * o = argv[2];


	printf("p TGA2CRY converter  ¾ by ray//.tSCc. 2005 q\n");
	if (argc != 3) {
		printf("useage: tga2cry infile[.tga] outfile[.cry]\n");
		return 0;
	}



	/* Add the file extensions */
	while ((*i != 0) && (*i != '.')) { *inp++ = *i++; };
	while ((*o != 0) && (*o != '.')) { *outp++ = *o++; };

	/* Ugly but works on both little- and big-endian CPUs */
	*inp++ = '.'; *inp++ = 't';*inp++= 'g';*inp++= 'a'; *inp++= 0;
	*outp++ = '.'; *outp++ = 'c';*outp++= 'r';*outp++= 'y'; *outp++= 0;

	/* Try to open inputfile */
	if ((infile=fopen(in,"rb"))==NULL) {
		printf("Error opening %s.\n",in);
		return 0;
	}

	/* Try to create outputfile */
	if ((outfile=fopen(out,"wb"))==NULL) {
  		printf("Error creating %s.\n",out);
		return 0;
	 }

	/* Process the image */
	printf("Loading %s: ",in);

	/* Read targa header */
	fread(&tga,18,1,infile);

	if ((tga.imagetype!=2)||(tga.bits!=24)) {
 		printf("Invalid TGA type.\n");
 		return 0;
	}

#ifdef __BIGENDIAN__	/* Swap little endian records if necessary */
	tga.width  = (tga.width<<8)|(tga.width>>8);
	tga.height = (tga.height<<8)|(tga.height>>8);
#endif

	/* Reserve image and processing space */
	tga.pixels = (pel *) malloc((u32)tga.width*tga.height*sizeof(pel));
	dst        = (u16 *) malloc((u32)tga.width*tga.height*sizeof(u16));	

	/* Read Pixel data while flipping the image vertically */
	y=tga.height;
	src = &tga.pixels[tga.width*(tga.height-1)];

	while (y--) {
		for (x=tga.width;x--;) {
			fread(src++,sizeof(pel),1,infile);
		}
	src -= 2*tga.width;
	}

	printf("ok.\n");
	printf("Size: %d x %d px.\n",tga.width,tga.height);

	/* Convert image */
	printf("Converting: ");
	rgbToCry(tga.width,tga.height, &tga.pixels[0], (u8 *)&dst[0]);
	printf("\n");

	/* Write destination file */
	printf("Writing %s: ",out);
	width=tga.width;
	height=tga.height;

#ifndef __BIGENDIAN__	/* Swap little endian records if necessary */
	width  = (width<<8)|(width>>8);
	height = (height<<8)|(height>>8);
#endif

	/* Write header */
	fwrite(&width,1,2,outfile);
	fwrite(&height,1,2,outfile);
	height = 0;			/* Write 4 dummy bytes */
	fwrite(&height,1,2,outfile);
	fwrite(&height,1,2,outfile);
	
	fwrite(&dst[0],1,(u32)tga.width*tga.height*sizeof(u16),outfile);
		
	printf("ok.\n");

	free(dst);free(tga.pixels);
	fclose(infile);fclose(outfile);

	return 0;
}
