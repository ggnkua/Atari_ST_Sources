#ifndef TARGA_H
#define TARGA_H

/* Number of colors in the color mapped file types */
#define NUM_COLORS 256


/*
	24bpp color triplet
*/
struct rgb {
	uchar b;
	uchar g;
	uchar r;
};

/*!
	\brief Targa file structure
*/
struct targa {
	/*! \brief Size of ID field that follows 18 byte header (0 usually) */
	uchar ident;
	/*! \brief Type of colour map 0=none, 0x01=has palette */
	uchar hasclut;    
	/*! \brief Type of image 0=none,0x01=indexed,0x02=rgb,3=grey,+0x08=rle packed */    
	uchar type;
	/*! \brief Even address alignment byte */
	uchar reserved;	

	/*! \brief First entry in CLUT */
	ushort clutstart;

	/*! \brief Number of CLUT entries */
	ushort clutlen;

	/*! \brief x origin */
	ushort xstart;
	/*! \brief y origin */    
	ushort ystart;
	/*! \brief Width in pixels */    
	ushort width;
	/*! \brief Height in pixels */    
	ushort height;
	/*! \brief Bits per pel 0x08,0x10,24,0x20 */    
	uchar bits;
	/*! \brief Descriptor bits (vh flip bits) */    
	uchar descriptor;
	/*! \brief Color lookup table (if any) */    
	struct rgb * clut;
	/*! \brief Raw pixel data */
	uchar * pels;
};

/*
	Targa type strings for valid image types
*/
static char ttype1[] = { "8bpp color mapped." };
static char ttype2[] = { "24bpp RGB color." };
static char ttype3[] = { "8bpp greyscale." };

static char * targatype[] = { ttype1, ttype2, ttype3 };


/*!
	\brief Load in a targa image from a file
	
	Returns a pointer to the generated targa image in case of success, a NULL
	pointer otherwise. Supports 8bpp colormapped and greyscale images and 24bpp
	RGB color pictures.
*/
struct targa * loadTarga(char filename[]);



/*!
	\brief Save a targa image to a file with the given name.
*/
struct biqstruct {};
void saveTGA(struct biqstruct * biq, struct targa * tga, char filename[]);

#endif
