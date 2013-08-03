/*
 * BDY READER BY NO/ESCAPE
 *
 * This is a routine to print information about a bdy 3D object.
 * Its argument is:
 * - a pointer the the bdy data
 */

#include <stdio.h>

int errno=1;	/* I dont know why */

/*** FILE FORMAT DESCRIPTION OF BDY FILES ***/

#define ushort unsigned short
#define uchar  unsigned char

struct bdy_header {
	char	format_ident[10];	/* format identifier "RIP OBJ.:\O" */
	char	version;			/* must be 6 */
	char	reserved;
	ushort 	byteorder;			/* 0x0100 -> intel format */
	ushort 	num_of_points;
	ushort	num_of_polys;
	ushort	num_of_materials;
	ushort	num_of_morphs;
	ushort	curr_morph_phase;
};


/* PRINT OUT HEADER INFORMATION ABOUT THE BDY FILE */
void print_header_info(struct bdy_header *header) {
	printf("BDY FILE INFORMATION:\n");
	printf("format_ident:     ");
	printf((char *)&header->format_ident);
	printf("\n");

	printf("version:          %u\n",(unsigned int)header->version);
	printf("byteorder:        %u\n",header->byteorder);
	printf("num_of_points:    %u\n",header->num_of_points);
	printf("num_of_polys:     %u\n",header->num_of_polys);
	printf("num_of_morphs:    %u\n",header->num_of_morphs);
	printf("curr_morph_phase: %u\n",header->curr_morph_phase);

}
