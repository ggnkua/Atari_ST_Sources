/*	BitRip Copyleft !(c) 2019, Michael S. Walker <mwalk762@mtroyal.ca>
 *	All Rights Unreserved in all Federations, including Alpha Centauris.
 *
 *	.--. https://github.com/heapsmash/Monochrome-Bitmap-Converter ---------.
 *	|  |    Header Name    | Value |              Description              |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | type:             | 4d42  | (Magic identifier: 0x4d42)            |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | size:             | 258   | (File size in bytes)                  |
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
 *	|  | height_px:        | 32    | (Height of the image)                 |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | num_planes:       | 1     | (Number of color planes)              |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | bits_per_pixel:   | 1     | (Bits per pixel)                      |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | compression:      | 0     | (Compression type)                    |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | image_size_bytes: | 128   | (Image size in bytes)                 |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | x_resolution_ppm: | 11811 | (Pixels per meter)                    |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | y_resolution_ppm: | 11811 | (Pixels per meter)                    |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | num_colors:       | 2     | (Number of colors)                    |
 *	:--+-------------------+-------+---------------------------------------:
 *	|  | important_colors: | 2     | (Important colors)                    |
 *	:--+-------------------+-------+---------------------------------------:
 */

int g_p1_walk_height = 32; /* height in bits */ 
int g_p1_walk_width = 32; /* width in bits */
int g_p1_walk_size = 128; /* total bytes */

const uint32_t p1_walk[] = {
	0x00000000,
	0x00000000,
	0x00000000,
	0x000fc000,
	0x000fc000,
	0x7ffffffc,
	0x01ffff00,
	0x00788800,
	0x007ff800,
	0x003ff000,
	0x001f2000,
	0x001fc000,
	0x001f8000,
	0x01fff800,
	0x033f0c00,
	0x033f0c00,
	0x033f0c00,
	0x033f8c00,
	0x033f8c00,
	0x033fcc00,
	0x033fec00,
	0x033fec00,
	0x033fec00,
	0x03bfe800,
	0x01fff800,
	0x007ff000,
	0x003fe000,
	0x003df000,
	0x0079fc00,
	0x00707c00,
	0x00fc0000,
	0x007c0000,
}; /* Generated with BitRip <mwalk762@mtroyal.ca> */ 

