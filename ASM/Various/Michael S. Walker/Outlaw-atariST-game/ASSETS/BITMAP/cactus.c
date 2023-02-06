/*	BitRip Copyleft !(c) 2020, Michael S. Walker <mwalk762@mtroyal.ca>
 *	All Rights Unreserved in all Federations, including Alpha Centauris.
 *
 *	.--. https://github.com/heapsmash/Monochrome-Bitmap-Converter ---------.
 *	|  |    Header Name    | Value |              Description              |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | type:             | 4d42  | (Magic identifier: 0x4d42)            |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | size:             | 930   | (File size in bytes)                  |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | reserved1:        | 0     | (NOT USED)                            |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | reserved2:        | 0     | (NOT USED)                            |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | offset:           | 130   | (Offset to image data [54 bytes])     |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | dib_header_size:  | 108   | (DIB Header size in bytes [40 bytes]) |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | width_px:         | 32    | (Width of the image)                  |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | height_px:        | 200   | (Height of the image)                 |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | num_planes:       | 1     | (Number of color planes)              |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | bits_per_pixel:   | 1     | (Bits per pixel)                      |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | compression:      | 0     | (Compression type)                    |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | image_size_bytes: | 800   | (Image size in bytes)                 |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | x_resolution_ppm: | 2835  | (Pixels per meter)                    |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | y_resolution_ppm: | 2835  | (Pixels per meter)                    |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | num_colors:       | 2     | (Number of colors)                    |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | important_colors: | 2     | (Important colors)                    |
 *	:--+-------------------+-------+---------------------------------------:
 */

int g_cactus_height = 200; /* height in bits */ 
int g_cactus_width = 32; /* width in bits */
int g_cactus_size = 800; /* total bytes */

const uint32_t cactus[] = {
	0x00018000,	0x00018000,	0x00018000,	0x00038000,
	0x000bc000,	0x000ff800,	0x001ff000,	0x000ff000,
	0x000ff800,	0x000ff000,	0x001ff000,	0x000ff000,
	0x000ff800,	0x001ffc00,	0x001ffc00,	0x001ffe00,
	0x001ffc00,	0x003ffc00,	0x001ffc00,	0x001ffe00,
	0x301ffc00,	0x301ffc00,	0x303ffe00,	0xfe1ffc00,
	0xfc1ffc00,	0xfc1ffc00,	0xfe1ffe00,	0xfc3ffc00,
	0xfc1ffc00,	0xfe1ffc00,	0xfc1ffe00,	0xfc3ffc00,
	0xfc1ffc00,	0xfc1ffe04,	0xfc1ffc0c,	0xfe3ffc0c,
	0xfc1ffc1e,	0xfc1ffe3e,	0xfe3ffc3e,	0xfc3ffc3f,
	0xfc3ffc7f,	0xfc3ffe3f,	0xfc3ffc7f,	0xfc3ffc3f,
	0xfe3ffc3f,	0xfc3ffc3f,	0xfc3ffe7f,	0xfc7ffc3f,
	0xfc3ffc7f,	0xfe3ffc3f,	0xfd3ffc7f,	0xfebffe7f,
	0xfc7ffcff,	0xfc3ffc7f,	0xfc3ffc7f,	0xfe3ffc7f,
	0xfc3ffc7f,	0xfc3ffc7f,	0xfc3ffcff,	0xfc7ffc7f,
	0xfc3ffc7f,	0xfc3ffe7f,	0xfc3ffc7f,	0xfcbffc7f,
	0xfffffc7f,	0xfffffe7f,	0xfffffdff,	0xfffffcff,
	0xfffffe7f,	0xfffffc7f,	0xfffffc7f,	0xfffffc7f,
	0xfffffc7f,	0xfffffcff,	0xfffffc7f,	0xfffffc7f,
	0xfffffe7f,	0xfffffc7f,	0xfffffc7f,	0xfffffc7f,
	0xfffffe7f,	0xfffffc7f,	0xfffffc7f,	0xfffffcff,
	0xfffffc7f,	0xfffffc7f,	0xfffffc7f,	0xfffffd7f,
	0xffffffff,	0x7fffffff,	0x7fffffff,	0x093fffff,
	0x007fffff,	0x003fffff,	0x003fffff,	0x003fffff,
	0x003fffff,	0x007fffff,	0x003fffff,	0x003fffff,
	0x003fffff,	0x003fffff,	0x007fffff,	0x003fffff,
	0x003fffff,	0x003fffff,	0x003fffff,	0x003fffff,
	0x007fffff,	0x003fffff,	0x003ffc72,	0x003ffc10,
	0x007ffc00,	0x003ffc00,	0x003ffe00,	0x007ffc00,
	0x003ffc00,	0x007ffc00,	0x003ffc00,	0x003ffe00,
	0x003ffc00,	0x003ffc00,	0x007ffc00,	0x003ffc00,
	0x003ffe00,	0x003ffc00,	0x007ffc00,	0x003ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffc00,	0x003ffe00,
	0x007ffc00,	0x003ffc00,	0x003ffc00,	0x003ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffc00,	0x007ffc00,
	0x003ffc00,	0x003ffe00,	0x003ffc00,	0x003ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffc00,	0x007ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffc00,	0x003ffe00,
	0x003ffc00,	0x003ffc00,	0x007ffc00,	0x003ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffe00,	0x003ffc00,
	0x003ffc00,	0x007ffc00,	0x003ffc00,	0x003ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffc00,	0x003ffc00,
	0x003ffc00,	0x007ffc00,	0x003ffc00,	0x003ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffe00,	0x003ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffc00,	0x003ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffc00,	0x007ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffc00,	0x003ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffc00,	0x003ffc00,
	0x003ffc00,	0x007ffe00,	0x003ffc00,	0x003ffc00,
	0x003ffc00,	0x003ffc00,	0x003ffc00,	0x007ffc00,
}; /* Generated with BitRip <mwalk762@mtroyal.ca> */ 

