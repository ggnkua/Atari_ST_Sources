/* gif.h:
 *
 * gifin.h
 * kirk johnson
 * november 1989
 * external interface to gifin.c
 *
 * Copyright 1989 Kirk L. Johnson (see the included file
 * "kljcpyrght.h" for complete copyright information)
 */

/*
 * gifin return codes
 */
#define GIFIN_SUCCESS       0   /* success */
#define GIFIN_DONE          1   /* no more images */

#define GIFIN_ERR_BAD_SD   -1   /* bad screen descriptor */
#define GIFIN_ERR_BAD_SEP  -2   /* bad image separator */
#define GIFIN_ERR_BAD_SIG  -3   /* bad signature */
#define GIFIN_ERR_EOD      -4   /* unexpected end of raster data */
#define GIFIN_ERR_EOF      -5   /* unexpected end of input stream */
#define GIFIN_ERR_FAO      -6   /* file already open */
#define GIFIN_ERR_IAO      -7   /* image already open */
#define GIFIN_ERR_NFO      -8   /* no file open */
#define GIFIN_ERR_NIO      -9   /* no image open */

/*
 * colormap indices 
 */

#define GIF_RED  0
#define GIF_GRN  1
#define GIF_BLU  2

/*
 * typedef BYTE for convenience
 */

typedef unsigned char BYTE;

static int gifin_open_file();
static int gifin_open_image();
static int gifin_get_pixel();
static int gifin_close_image();
static int gifin_close_file();
static int gifin_load_cmap();
static int gifin_skip_extension();
static int gifin_read_data_block();
static int gifin_push_string();
static int gifin_add_string();
static int gifin_fatal();

/* #defines, typedefs, and such
 */

#define GIF_SIG      "GIF87a"
#define GIF_SIG_LEN  6          /* GIF signature length */
#define GIF_SD_SIZE  7          /* GIF screen descriptor size */
#define GIF_ID_SIZE  9          /* GIF image descriptor size */

#define GIF_SEPARATOR   ','     /* GIF image separator */
#define GIF_EXTENSION   '!'     /* GIF extension block marker */
#define GIF_TERMINATOR  ';'     /* GIF terminator */

#define STAB_SIZE  4096         /* string table size */
#define PSTK_SIZE  1024         /* pixel stack size */

#define NULL_CODE  -1           /* string table null code */

BOOLEAN gifLoad();
