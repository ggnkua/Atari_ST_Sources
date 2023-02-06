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

int g_p2_normal_height = 32; /* height in bits */ 
int g_p2_normal_width = 32; /* width in bits */
int g_p2_normal_size = 128; /* total bytes */

const uint32_t p2_normal[] = {
	0x0007e000,
	0x0007e000,
	0x7ffffffc,
	0x01ffff00,
	0x00223c00,
	0x003ffc00,
	0x001ff800,
	0x0009f000,
	0x0007f000,
	0x0003f000,
	0x0000f000,
	0x0000f000,
	0x0000f000,
	0x003fff00,
	0x0061f980,
	0x0061f980,
	0x0061f980,
	0x0063f980,
	0x0063f980,
	0x0067f980,
	0x006ff980,
	0x006ff980,
	0x006ff980,
	0x002ffb80,
	0x003fff00,
	0x001ffc00,
	0x000ff800,
	0x000f7800,
	0x000e3800,
	0x000e1800,
	0x003f3e00,
	0x007c1f00,
}; /* Generated with BitRip <mwalk762@mtroyal.ca> */ 

