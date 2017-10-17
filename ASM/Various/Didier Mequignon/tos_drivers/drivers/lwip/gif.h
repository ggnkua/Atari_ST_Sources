/*
 *  This is the header file interface to the gif.c file.
 *
 *  Requires that the app.h header be loaded first.
 */

/*
 *  Gif structures:
 */
 
typedef struct {
		char alpha;
		char red;
		char green;
		char blue;
	} Colour;

typedef struct {
    int      length;
    Colour * colours;
  } GifPalette;

typedef struct {
    int          width, height;
    int          has_cmap, color_res, sorted, cmap_depth;
    int          bgcolour, aspect;
    GifPalette * cmap;
  } GifScreen;

typedef struct {
    int             byte_count;
    unsigned char * bytes;
  } GifData;

typedef struct {
    int        marker;
    int        data_count;
    GifData ** data;
  } GifExtension;

typedef struct {
    int              left, top, width, height;
    int              has_cmap, interlace, sorted, reserved, cmap_depth;
    GifPalette *     cmap;
    unsigned char ** data;
  } GifPicture;

typedef struct {
    int            intro;
    GifPicture *   pic;
    GifExtension * ext;
  } GifBlock;

typedef struct {
    char        header[8];
    GifScreen * screen;
    int         block_count;
    GifBlock ** blocks;
  } Gif;


/*
 *  Gif internal definitions:
 */

#define LZ_MAX_CODE     4095    /* Largest 12 bit code */
#define LZ_BITS         12

#define FLUSH_OUTPUT    4096    /* Impossible code = flush */
#define FIRST_CODE      4097    /* Impossible code = first */
#define NO_SUCH_CODE    4098    /* Impossible code = empty */

#define HT_SIZE         8192    /* 13 bit hash table size */
#define HT_KEY_MASK     0x1FFF  /* 13 bit key mask */

#define IMAGE_SAVING    0       /* file_state = processing */
#define IMAGE_COMPLETE  1       /* finished reading or writing */

typedef struct {
    char **file;
    int depth,
        clear_code, eof_code,
        running_code, running_bits,
        max_code_plus_one,
	prev_code, current_code,
        stack_ptr,
        shift_state;
    unsigned long shift_data;
    unsigned long pixel_count;
    int           file_state, position, bufsize;
    unsigned char buf[256];
    unsigned long hash_table[HT_SIZE];
  } GifEncoder;

void * gif_alloc(long bytes);

void	write_gif_int(char **file, int output);

GifData * new_gif_data(int size);
void	del_gif_data(GifData *data);
void	write_gif_data(char **file, GifData *data);

GifPalette * new_gif_palette(void);
void	del_gif_palette(GifPalette *cmap);
void	write_gif_palette(char **file, GifPalette *cmap);

GifScreen * new_gif_screen(void);
void	del_gif_screen(GifScreen *screen);
void	write_gif_screen(char **file, GifScreen *screen);

GifExtension *new_gif_extension(void);
void	del_gif_extension(GifExtension *ext);
void	write_gif_extension(char **file, GifExtension *ext);

GifEncoder * new_gif_encoder(void);
void	del_gif_encoder(GifEncoder *encoder);
void	write_gif_code(char **file, GifEncoder *encoder, int code);
void	init_gif_encoder(char **file, GifEncoder *encoder, int depth);
void	write_gif_line(char **file, GifEncoder *encoder, unsigned char *line, int length);
void	flush_gif_encoder(char **file, GifEncoder *encoder);

GifPicture * new_gif_picture(void);
void	del_gif_picture(GifPicture *pic);
void	write_gif_picture(char **file, GifPicture *pic);

GifBlock *new_gif_block(void);
void	del_gif_block(GifBlock *block);
void	write_gif_block(char **file, GifBlock *block);

Gif *	new_gif(void);
void	del_gif(Gif *gif);
void	write_gif(char **file, Gif *gif);

