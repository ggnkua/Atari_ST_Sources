/*
	Carthesian -> Polar coordinates mapper (swirl texture converter)
	quickhack, by ray//.tSCc. 2007
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#define XRES 256L	/* Texture resolution in pixels */
#define YRES 256L

#define ANG 256L	/* Polar coordinate texture resolution*/
#define RAD 256L

int main(int argc, char * argv[]) {

	FILE * infile;
	FILE * outfile;
	char outname[80];
	char * strptr;
	char * texture_in;
	char * texture_out;

	int phi,r;
	int x,y;

	printf("Carthesian -> polar coordinate converter, ray//.tSCc. 2007\n");
	if (argc < 2) {
		printf("You need to specify an input file.\n\n");
		return 0;
	}

	if ((infile = fopen(argv[1], "rb")) == NULL) {
		printf("Error opening %s.\n\n", argv[1]);
		return 0;
	}

	
	if ((texture_in = (char*) malloc(XRES*YRES)) == NULL || (texture_out = (char*) malloc(ANG*RAD)) == NULL) {
		printf("Error allocating texture space.\n\n");
		return 0;
	}	

	printf("Reading %s: ", argv[1]);
	fread(texture_in, XRES*YRES, sizeof(char), infile);
	fclose(infile);
	printf("ok.\n");

	printf("Remapping: ");

	/* This is where the coordinate transform is being performed */
	for (r=0;r<RAD;r++) {
		for (phi=0;phi<ANG;phi++) {

			/* Scan the texture along concentric circles seeded around 
			the center of the initial rectangular texture */
			x = (int)(cos(phi*2*M_PI/ANG)*r*(XRES/2)/(RAD-1))+XRES/2;
			y = (int)(sin(phi*2*M_PI/ANG)*r*(YRES/2)/(RAD-1))+YRES/2;

			/* Preshift and store pixel */
			texture_out[r*ANG+phi] = (texture_in[y*XRES+x] & 0x0f) << 2;
		}
	}

	printf("ok.\n");

	strcpy(outname,argv[1]);
	if ((strptr = strchr(outname,'.')) == NULL) {
		printf("Error creating output filename.\n\n");
		return 0;	
	}
	strcpy(strptr,".OUT");

	if ((outfile = fopen(outname,"wb")) == NULL) {
		printf("Error creating %s.\n\n", outname);
		return 0;
	}

	printf("Writing %s: ", outname);
	fwrite(texture_out, ANG*RAD, sizeof(char), outfile);
	printf("ok.\n\n");

	fclose(outfile);

	return 0;
}
