#include <stdio.h>
#include <math.h>
#include "defs.h"
#include "targa.h"
#include "biq.h"
#include "codec.h"
#include "lz78.h"


struct biqstruct * loadBiQ(char filename[]) {
	
	/* _BYTES_ per pel for each valid filetype */
	const ushort bytes[4] = { 1, 1, 3, 2 };
	
	uint i;
	
	struct biqstruct * image = malloc(sizeof(struct biqstruct));
	FILE * imagefile = fopen(filename,"rb");

	if (image==NULL) {
		printf("Failed to allocate BiQ resource.\n");
		return NULL;
	}
	if (imagefile==NULL) {
		printf("Failed to open %s.\n",filename);
		return NULL;
	}
	
	/* Read in file header */
	fread(image, 1, sizeof(struct biqstruct)-2*sizeof(void *)-2, imagefile);

	/* Swap byte order on little endian machines*/
#ifndef BIGENDIAN
	image->type   = BYTESWAP(image->type);
	image->width  = BYTESWAP(image->width);
	image->height = BYTESWAP(image->height);	
#endif

	/* Check id header */
#ifdef BIGENDIAN
	if (image->ident != '_BiQ')
#else
	if (image->ident != 'QiB_')
#endif
	{
		printf("Invalid filetype.\n");
		return NULL;
	}


	/* Color mapped type?  */
	if (image->type == 0x01) {
		
		/* Try to allocate and load in palette resource if so */
		if ((image->clut = malloc(NUM_COLORS*sizeof(struct rgb))) == NULL) {
			printf("Failed to create BiQ color lookup table.");
			return NULL;
		}

		for (i=0;i<NUM_COLORS;i++) {
			image->clut[i].r = getc(imagefile);
			image->clut[i].g = getc(imagefile);
			image->clut[i].b = getc(imagefile);						
		}
		
	} else
		image->clut = NULL;

	
	/* Allocate coefficient buffer */
	image->coeff = malloc((long)bytes[image->type]*sizeof(uchar)*image->width*image->height);

	if (image->coeff==NULL) {
		printf("Failed to create BiQ coefficient buffer.\n");
		return NULL;
	}

	/* Decode DWT coefficient (lz78) stream */
	deLZ78(imagefile,image->coeff);

	fclose(imagefile);
	return(image);
}


ushort saveBiQ(struct targa * tga, struct biqstruct * biq, float Q, char filename[]) {

	FILE * file = fopen(filename,"wb");
	
	ulong orisize = (long)tga->width*tga->height*(tga->bits/8)*sizeof(uchar);
	ulong outsize;
	
	uint i;
	
	/* Type conversion table */
	const ushort biqtypes[4] = { 0x00, 0x01, 0x02, 0x00 };


	if (file == NULL) {
		printf("Failed to create %s.\n",filename);
		return 0;
	}
	
	/* Compute quantization value (exponentially) */	
	Q = (exp(Q)-1)/(exp(1)-1);
	Q = Q*Q/0.849455238f;
	
	
	/* Perform Wavelet transform (L layers) */
	transform(tga,biq,L,Q);

	/* Initialize BiQ header records */
	biq->type   = biqtypes[tga->type];
	biq->width  = tga->width;
	biq->height = tga->height;

	/* Write file header, this works on both big and little endian machines */
	putc('_',file);
	putc('B',file);
	putc('i',file);
	putc('Q',file);

	putc((uchar)(biq->type>>8),file);
	putc((uchar)(biq->type),file);
	
	putc((uchar)(biq->width>>8),file);
	putc((uchar)(biq->width),file);
	putc((uchar)(biq->height>>8),file);
	putc((uchar)(biq->height),file);
			



	/* Color mapped filetype? */
	if (tga->type==0x01) {
		/*biq->clut = tga->clut;*/
		
		/* Write out color map to file */
		for (i=0;i<NUM_COLORS;i++) {
			putc(tga->clut[i].r,file);
			putc(tga->clut[i].g,file);
			putc(tga->clut[i].b,file);
		}
	}
	
	
	/* Encode and save DWT coefficients */
	enLZ78(biq->coeff,
		   (long)biq->width*biq->height*(tga->bits/8)*sizeof(uchar),
		   file);
		   

	outsize = ftell(file);
	fclose(file);
	
	return ((ushort)(0.5f+(float)orisize/(float)outsize));
}
