struct bit_plane
    {
    unsigned WORD words_per_line;
    unsigned WORD width;
    unsigned WORD height;
    WORD *plane;
    };
typedef struct bit_plane Bit_plane;

struct byte_plane
    {
    unsigned WORD words_per_line;
    unsigned WORD width;
    unsigned WORD height;
    WORD *plane;
    };
typedef struct byte_plane Byte_plane;

struct byte_bit_plane
    {
    unsigned WORD words_per_line;
    unsigned WORD width;
    unsigned WORD height;
    WORD *plane;
    unsigned WORD swords_per_line;
    WORD *stencil;
    };

struct BitMap 
    {
    unsigned WORD BytesPerRow;
    unsigned WORD Rows;
    char Flags;
    char Depth;
    unsigned WORD width;
    WORD *Planes[8];
    };
/*  struct BitMap adopted from amiga */

struct text_stamp
    {
    WORD width, height;
    char *string;
    };

struct atari_cel
	{
	int width;
	int height;
	int plane_ct;
	char id[4];
	int fg_col;	/*pad for me*/
	int bg_col;	/*likewise pad*/
	int xoff;	/*generally zero*/
	int yoff;	/*generally zero*/
	WORD *form;	/*the binary image*/
	int nxwd;	/*resolution dependent, 8 at low res*/
	int nxln;	/*Bytes Per Row ...*/
	int nxpl;	/*Always 2*/
	WORD *mask;
	};

#ifdef AMIGA
extern struct BitMap *load_background(), *load_window();
extern struct BitMap *init_BitMap(), *clone_BitMap(), *dummy_BitMap();
#endif AMIGA

#ifdef ATARI
extern WORD *load_background();
extern struct atari_cel *load_window();
extern struct atari_cel *init_atari_cel(), *dummy_atari_cel();
#endif ATARI

#ifdef SUN
extern struct byte_plane *load_background(), *load_window();
extern struct byte_plane *init_byte_plane(), *clone_byte_plane();
#endif SUN

extern struct bit_plane *init_bit_plane(), *clone_bit_plane();
extern struct bit_plane *dummy_bitplane();
extern struct bit_plane *load_msk();

typedef int * RASTER_POINTER;
struct raster_list
    {
    struct raster_list *next;
    char *name;
    WORD type;
    RASTER_POINTER  raster;
    RASTER_POINTER  scaled;
    WORD status;
    WORD links;
    WORD xoff;
    WORD yoff;
    };
struct raster_list *add_new_raster();
/*defs for raster_list->status */
#define NOT_FOUND 	0
#define ON_DISK		1
#define IN_MEMORY 	2

/*line_bytes = the number of words * 2 (for bytes) a raster line takes up */
#define line_bytes(width)	(((width+15)>>4)<<1)
/* psize - size in bytes (an even number) of a raster image given
   width and height */
#define psize(width, height) ( line_bytes(width)*height)

#define ralloc alloc
#define rfree mfree

