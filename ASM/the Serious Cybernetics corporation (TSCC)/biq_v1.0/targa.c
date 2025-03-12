#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "defs.h"
#include "targa.h"
#include "biq.h"
#include "codec.h"


struct targa * loadTarga(char filename[]) {

	int x, y;
	uchar * dst;
	int pelsize;
	uint pixel;


	struct targa * image = malloc(sizeof(struct targa));
	FILE * imagefile = fopen(filename,"rb");

	if (image==NULL) {
		printf("Failed to allocate TARGA resource.\n");
		return NULL;
	}
	if (imagefile==NULL) {
		printf("Failed to open %s.\n",filename);
		return NULL;
	}

	/* Read in file header */
	fread(image, 1, sizeof(struct targa)-2*sizeof(void *)-2, imagefile);

#ifdef BIGENDIAN
	image->width  = BYTESWAP(image->width);
	image->height = BYTESWAP(image->height);
#endif

	/* No greyscale, 8bpp indexed or RGB type image? */
	if ((image->type!=0x01)&&(image->type!=0x02)&&(image->type!=0x03))
		return NULL;

	/* RGB type but not 24bpp? */
	if ((image->type==0x02)&&(image->bits!=24)) return NULL;

	/* Load color ramp (if any) */
	if ((image->hasclut)||(image->type==0x01)) {
		if ((image->clut=malloc((1<<image->bits)*sizeof(struct rgb)))==NULL)
			return NULL;
		else
			fread(image->clut,1<<image->bits,sizeof(struct rgb),imagefile);
	}

	/* 8bpp greyscale? */
	if (image->type==0x03)
		pelsize = 1*sizeof(uchar);
	else
		pelsize = 3*sizeof(uchar);

	if ((image->pels = malloc(image->width*image->height*pelsize))==NULL)
		return NULL;



	/* 24bpp RGB */
	if (image->bits==24) {

		for (y=image->height-1;y>=0;y--) {
			dst = &image->pels[y*image->width*sizeof(uchar)];

			for (x=0;x<image->width;x++) {

				/* Read R, G and B layer */
				dst[2*image->height*image->width*sizeof(uchar)] = getc(imagefile);
				dst[image->height*image->width*sizeof(uchar)]   = getc(imagefile);
				*dst++                                          = getc(imagefile);
			}
		}
	}

	/* 8bpp greyscale */
	else if (image->type==0x03) {

		dst=&image->pels[image->width*sizeof(uchar)*(image->bits/8)*(image->height-1)];
		do {
			fread(dst,image->width*sizeof(uchar),sizeof(uchar),imagefile);
		} while ((dst-= image->width*sizeof(uchar)) >= image->pels);

	}

	/* 8bpp colormapped -> convert to 24bpp RGB*/
	else {
			for (y=image->height-1;y>=0;y--) {
			dst = &image->pels[y*image->width*sizeof(uchar)];

			for (x=0;x<image->width;x++) {

				pixel = getc(imagefile);
				dst[2*image->height*image->width*sizeof(uchar)] = image->clut[pixel].b;
				dst[image->height*image->width*sizeof(uchar)]   = image->clut[pixel].g;
				*dst++                                          = image->clut[pixel].r;
			}
		}

	}

	fclose(imagefile);
	return image;
}


void saveTGA(struct biqstruct * biq, struct targa * tga, char filename[]) {

	uint i;
	int x,y;
	uchar * src;

	FILE * file = fopen(filename,"wb");

	/* Type conversion table */
	const uchar tgatypes[4] = { 0x03, 0x01, 0x02, 0x02 };
	const uchar biqbpp[4]   = { 8, 8, 24, 24 };

	if (file==NULL) {
		printf("Failed to create %s.\n",filename);
		return;
	}


	memset(tga, 0 , sizeof(struct targa)-2*sizeof(void *)-2);
	tga->type   = tgatypes[biq->type];

	/* Bugfix: set CLUT properties */
	if (tga->type==0x01) {
		tga->hasclut   = 0x01;
		tga->clutstart = 0x0000;
		tga->clutlen   = 0x1801;	/* This is very weird, but it seems to work */
	}

	tga->width  = biq->width;
	tga->height = biq->height;
	tga->bits   = biqbpp[biq->type];

#ifdef BIGENDIAN
/*	tga->clutstart = BYTESWAP(tga->clutstart); /* = 0, either way */
	tga->clutlen = BYTESWAP(tga->clutlen);

	tga->width  = BYTESWAP(tga->width);
	tga->height = BYTESWAP(tga->height);

#endif

	/* Write file header, this works on both big and little endian machines */
	fwrite(tga, 1, sizeof(struct targa)-2*sizeof(void *)-2, file);


	/* Color mapped filetype? */
	if (tga->type==0x01) {

		/* Write out color map to file */
		for (i=0;i<NUM_COLORS;i++) {
			putc(biq->clut[i].b,file);
			putc(biq->clut[i].g,file);
			putc(biq->clut[i].r,file);
		}
	}


	/* Perform inverse Wavelet transform */
	retransform(biq,tga,L);

	/* Save image (bottom to top)*/

	/* 24bpp */
	if (tga->bits==24) {

		for (y=biq->height-1;y>=0;y--) {
			src = &biq->coeff[y*biq->width*sizeof(uchar)];

			for (x=0;x<biq->width;x++) {

				/* Write B, G and R layers in interlaved order*/
				putc(src[2*biq->height*biq->width*sizeof(uchar)],file);
				putc(src[biq->height*biq->width*sizeof(uchar)],file);
				putc(*src++,file);
			}
		}
	}

	/* 8bpp */
	else {

		src=&biq->coeff[biq->width*sizeof(uchar)*(biq->height-1)];
		do {
			fwrite(src,biq->width*sizeof(uchar),sizeof(uchar),file);
		} while ((src -= biq->width*sizeof(uchar)) >= biq->coeff);

	}

	fclose(file);
}
