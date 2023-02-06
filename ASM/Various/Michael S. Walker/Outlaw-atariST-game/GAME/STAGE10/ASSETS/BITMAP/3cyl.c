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

int g_3_cylinder_height = 32; /* height in bits */
int g_3_cylinder_width = 32;  /* width in bits */
int g_3_cylinder_size = 128;  /* total bytes */

const uint32_t cylinder_3[] = {
	0x001ff000,
	0x00101000,
	0x00701e00,
	0x00600e00,
	0x1fc003f8,
	0x3000000c,
	0x60000006,
	0x400001f2,
	0xc00003fb,
	0xc00007fb,
	0x80000739,
	0x80000739,
	0xc00003f7,
	0x600381f6,
	0x7006c1ee,
	0x700c600e,
	0x700c600e,
	0x4006c1f2,
	0xc00383fb,
	0x800007fd,
	0x800007cd,
	0x800007cd,
	0x800787fd,
	0xc00fc3fb,
	0x600fe1f6,
	0x701ce00e,
	0x3f1ce0fc,
	0x19cfe398,
	0x006fce00,
	0x00279800,
	0x00201000,
	0x003ff000,
}; /* Generated with BitRip <mwalk762@mtroyal.ca> */
