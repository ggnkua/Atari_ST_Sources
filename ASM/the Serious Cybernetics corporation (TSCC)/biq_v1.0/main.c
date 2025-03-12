/************************************************************************
*                          BIQ Image Codec v1.0                         *
*************************************************************************
* by ray//.tSCc.                                              2005-2006 *
*                                                                       *
* www: http://ray.tscc.de                                               *
* eml: ray@tscc.de                                                      *
*************************************************************************
* This program is free software; you can redistribute it and/or modify  *
* it under the terms of the GNU General Public License as published by  *
* the Free Software Foundation; either version 2 of the License, or     *
* (at your option) any later version.                                   *
************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "defs.h"
#include "targa.h"
#include "biq.h"
#include "codec.h"


/*!
	\brief Main program
*/
int main(int argc, char * argv[]) {

	struct targa * tga;
	struct biqstruct * biq;
		
	char out[80];
	char * outname;
	char * inname;	
	uint ratio;
	uint pelsize;
	float Q;		/* Quantization threshold */
		


	printf("p BIQ image codec v1.0  (c) ray/.tSCc. 2005-2006 q\n\n");

	if ((argc!=3)&&(argc!=2)) {
		printf("Usage:\n");
		printf("   biq 99 img.tga  Encode img.tga -> img.biq (q=99)\n");
		printf("   biq img.biq     Decode img.biq -> img.tga\n\n");
		printf("   Valid quantization values are q=[0..99].s\n");
		return 0;
	}

	outname = out;
	
	
	/* Decompress BiQ file */
	if (argc==2) {
		/* Copy input filename */
		inname=argv[1];		
		while((*inname != '.') && (*inname != 0)) *outname++ = *inname++;
		
		/* Append ".tga" */
		strcpy(outname,".tga");
		
		/* Load in source image */
		printf("Loading %s: ",argv[1]);

		if ((biq = loadBiQ(argv[1]))==NULL) {
			printf("Error.\n");
			return 0;
		}
		else {
			printf("ok.\n");
			printf("Image type: %s\n",biqtype[(biq->type)%4]);
			printf("Image size: %d x %d pixels.\n",biq->width,biq->height);
		}
		
		/* 24bpp RGB or 16bpp CrY? */
		pelsize = (biq->type==0x02||biq->type==0x03)? 3*sizeof(uchar):sizeof(uchar);	

		/* Create new TGA structure*/
		if ((tga = malloc(sizeof(struct targa)))==NULL) {
			printf("Failed to create TGA structure.\n");
			return 0;
		}
		if ((tga->pels = malloc((long)biq->width*biq->height*pelsize))==NULL) {
			printf("Failed to create TGA pixel buffer.\n");
			return 0;
		}
		
		printf("Decoding: ");
		saveTGA(biq, tga, out);
		printf("ok.\n");	
	}
	
	
	/* Compress TGA file */
	else {
		inname=argv[2];
		while((*inname != '.') && (*inname != 0)) *outname++ = *inname++;
		
		/* Append ".biq" */
		strcpy(outname,".biq");
		
	
		/* Load in source image */
		printf("Loading %s: ",argv[2]);

		if ((tga = loadTarga(argv[2]))==NULL) {
			printf("Error.\n");
			return 0;
		}
		else {
			if ((tga->width&((1<<L)-1))||(tga->height&((1<<L)-1))) {
				printf("unsupported size.\n");
				return 0;
			}
			else {
				printf("ok.\n");
				printf("Image type: %s\n",targatype[(tga->type-1)%3]);
				printf("Image size: %d x %d pixels.\n",tga->width,tga->height);
			}
		}
		
		pelsize = (tga->type==0x03)? sizeof(uchar):3*sizeof(uchar);	

		/* Create new BiQ structure*/
		if ((biq = malloc(sizeof(struct biqstruct)))==NULL) {
			printf("Failed to create BiQ structure.\n");
			return 0;
		}

		if ((biq->coeff = malloc((long)tga->width*tga->height*pelsize))==NULL) {
			printf("Failed to create BiQ coefficient buffer.\n");
			return 0;
		}
		
		/* Convert quantization parameter 0..99->0..0.99 */
		Q = (float)(((uint)strtof(argv[1],0))%100)/100;
	
		printf("Encoding: ");

		ratio = saveBiQ(tga, biq, Q, out);	
		
		printf("ok.\n");	
		printf("Ratio: 1:%d (%.3f bpp).\n",ratio,8.0f/ratio);
		
	}


/*	free(biq->clut);*/
	free(biq->coeff);
	free(biq);

/*	free(tga->clut);*/
	free(tga->pels);
	free(tga);


	return 0;
}
