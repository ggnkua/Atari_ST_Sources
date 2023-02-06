/*	BitRip Copyleft !(c) 2019, Michael S. Walker <sigmatau@heapsmash.com>
 *	All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#ifndef BMP_RIP_BMP_H
#define BMP_RIP_BMP_H

#include <stdint.h> /* for uintxx_t */
#include <errno.h>  /* for CHECK_SIZE */
#include <endian.h>

#if __BYTE_ORDER == __BIG_ENDIAN

#define ENDIAN16(val) val
#define ENDIAN32(val) val
#define ENDIAN64(val) val
#else

#define ENDIAN16(val) \
 ( (((val) >> 8) & 0x00FF) | (((val) << 8) & 0xFF00) )

#define ENDIAN32(val) \
 ( (((val) >> 24) & 0x000000FF) | (((val) >>  8) & 0x0000FF00) | \
   (((val) <<  8) & 0x00FF0000) | (((val) << 24) & 0xFF000000) )

#define ENDIAN64(val) \
 ( (((val) >> 56) & 0x00000000000000FF) | (((val) >> 40) & 0x000000000000FF00) | \
   (((val) >> 24) & 0x0000000000FF0000) | (((val) >>  8) & 0x00000000FF000000) | \
   (((val) <<  8) & 0x000000FF00000000) | (((val) << 24) & 0x0000FF0000000000) | \
   (((val) << 40) & 0x00FF000000000000) | (((val) << 56) & 0xFF00000000000000) )
#endif //__BYTE_ORDER == __BIG_ENDIAN

#if defined(__linux__) && defined(__x86_64__)

#define __FILE_MAX__ FILENAME_MAX
#define __ARRAY_MAX__ 25
#else

#define __FILE_MAX__ 10 /* Size depends on system, 10 seems like a safe number */
#define __ARRAY_MAX__ __FILE_MAX__
#endif //defined(__linux__) && defined(__x86_64__)

#define CHECK_SIZE(arg, x) if (strlen((arg)) >= (x)) { \
    errno = 36; \
    PRINT_ERRNO_AND_RETURN("optarg error"); \
    }

#define UMASK 0664 /* [User: rw] [Group: rw] [Other: r] */

const char *g_header_names[] = {
		"type:",
		"size:",
		"reserved1:",
		"reserved2:",
		"offset:",
		"dib_header_size:",
		"width_px:",
		"height_px:",
		"num_planes:",
		"bits_per_pixel:",
		"compression:",
		"image_size_bytes:",
		"x_resolution_ppm:",
		"y_resolution_ppm:",
		"num_colors:",
		"important_colors:"
};

const char *g_header_description[] = {
		"(Magic identifier: 0x4d42)",
		"(File size in bytes)",
		"(NOT USED)",
		"(NOT USED)",
		"(Offset to image data [54 bytes])",
		"(DIB Header size in bytes [40 bytes])",
		"(Width of the image)",
		"(Height of the image)",
		"(Number of color planes)",
		"(Bits per pixel)",
		"(Compression type)",
		"(Image size in bytes)",
		"(Pixels per meter)",
		"(Pixels per meter)",
		"(Number of colors)",
		"(Important colors)"
};

const char *g_usage = "g_usage: ./bit_rip [-n number of columns to write] -f <input filename . bmp>  -a <array name for bitmap> -s <output file name . c>";

typedef struct _BMPHeader {    /* Total: 54 bytes */
	uint16_t type;             /* Magic identifier: 0x4d42 */
	uint32_t size;             /* File size in bytes */
	uint16_t reserved1;        /* NOT USED */
	uint16_t reserved2;        /* NOT USED */
	uint32_t offset;           /* Offset to image data in bytes from beginning of file (54 bytes) */
	uint32_t dib_header_size;  /* DIB Header size in bytes (40 bytes) */
	int32_t width_px;          /* Width of the image */
	int32_t height_px;         /* Height of the image */
	uint16_t num_planes;       /* Number of color planes */
	uint16_t bits_per_pixel;   /* Bits per pixel */
	uint32_t compression;      /* Compression type */
	uint32_t image_size_bytes; /* Image size in bytes */
	int32_t x_resolution_ppm;  /* Pixels per meter */
	int32_t y_resolution_ppm;  /* Pixels per meter */
	uint32_t num_colors;       /* Number of colors */
	uint32_t important_colors; /* Important colors */
} BMPHeader;

typedef struct _BMPImageTools {
	BMPHeader header;
	size_t ncols_per_row;
	int bitmap_to_read_fd, c_file_to_write_fd;
	char *file_name_to_save, *file_name_to_read, *array_name_to_store;
} BitRipTools;

void WriteCommentToFile(BitRipTools data);
int ReadBitmapHeader(BitRipTools *data);
int WriteDataUint8(BitRipTools *data);
int WriteDataUint16(BitRipTools *data); 
int WriteDataUint32(BitRipTools *data);

#endif //BMP_RIP_BMP_H
