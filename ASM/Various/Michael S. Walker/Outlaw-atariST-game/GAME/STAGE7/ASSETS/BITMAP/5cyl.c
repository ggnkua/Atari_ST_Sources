/*	BitRip Copyleft !(c) 2020, Michael S. Walker <mwalk762@mtroyal.ca>
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

int g_5_cylinder_height = 32; /* height in bits */
int g_5_cylinder_width = 32;  /* width in bits */
int g_5_cylinder_size = 128;  /* total bytes */

const uint32_t cylinder_5[] = {
	0x001ff000,
	0x00101000,
	0x00701e00,
	0x00600e00,
	0x1fc003f8,
	0x3000000c,
	0x60000006,
	0x4f8001f2,
	0xdfc003fb,
	0xdfe007fb,
	0x9ce00739,
	0x9ce00739,
	0xefc003f7,
	0x6f8381f6,
	0x7786c1ee,
	0x700c600e,
	0x700c600e,
	0x4f86c1f2,
	0xdfc383fb,
	0xbfe007fd,
	0xbce007cd,
	0xbce007cd,
	0xbfe787fd,
	0xdfcfc3fb,
	0x6f8fe1f6,
	0x701ce00e,
	0x3f1ce0fc,
	0x19cfe398,
	0x006fce00,
	0x00279800,
	0x00201000,
	0x003ff000,
}; /* Generated with BitRip <mwalk762@mtroyal.ca> */
