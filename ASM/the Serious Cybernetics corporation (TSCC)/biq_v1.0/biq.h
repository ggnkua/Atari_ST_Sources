#ifndef BIQ_H
#define BIQ_H


/*!
	\brief BiQ file structure
*/
struct biqstruct {
	
	/*! \brief ident header "_BiQ" */
	ulong ident;
	/*! \brief file type (0x00=8bpp greyscale, 0x01=8bpp indexed,
	                      0x02=24bpp RGB, 0x03=16bpp CrY (not yet supported)) */
	ushort type;
	/*! \brief image width in pixels. */
	ushort width;
	/*! \brief image height in pixels. */	
	ushort height;
	/*! \brief pointer to CLUT (NULL if none) */
	struct rgb * clut;
	/*! \brief pointer to (encoded) DWT coefficients */
	uchar * coeff;
};



/*
	BiQ type strings for valid image types
*/

static char btype1[] = { "8bpp greyscale." };
static char btype2[] = { "8bpp color mapped." };
static char btype3[] = { "24bpp RGB color." };
static char btype4[] = { "16bpp CrY color." };

static char * biqtype[] = { btype1, btype2, btype3, btype4 };


/*!
	\brief Load a BiQ image from the given file(name).
*/
struct biqstruct * loadBiQ(char filename[]);


/*!
	\brief Convert a given targa image to a BiQ image.
	
	Q gives the quantization strength (=[0..1]), the resulting BiQ image will
	be stored in the given file. Returns the achieved compression ratio
	in 1:X.
*/
ushort saveBiQ(struct targa * tga, struct biqstruct * biq, float Q, char filename[]);

#endif
