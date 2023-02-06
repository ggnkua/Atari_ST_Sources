/*	BitRip Copyleft !(c) 2019, Michael S. Walker <sigmatau@heapsmash.com>
 *	All Rights Unreserved in all Federations, including Alpha Centauris.
 * 
 * 	chmod ugo+rwx make.sh
 * 	sh make.sh
 * 	./bit_rip -n 2 -f badguy.bmp -a badguy -s badguy.c
 */

#pragma clang diagnostic push
#pragma ide diagnostic ignored "hicpp-signed-bitwise"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <limits.h>
#include <sys/types.h>
#include <sys/syscall.h>

#include "syscalls.h"
#include "bmp.h"

#define _VERBOSE 0 /* For error output (1) is very verbose */ 

int main(int argc, char *argv[], char *envp[])
{
	int opt, 
		return_status = 0, /* success */ 
		(*WriteDataToArray)(BitRipTools *) = NULL;

	BitRipTools bitmap;

	bitmap.ncols_per_row = 1;
	bitmap.file_name_to_read = bitmap.array_name_to_store = bitmap.file_name_to_save = NULL;
	while ((opt = getopt(argc, argv, "n:f:a:s:")) != -1) {
		switch (opt) {
			case 'f':
				CHECK_SIZE(optarg, __FILE_MAX__)
				bitmap.file_name_to_read = optarg; /* the file_name.bmp to extract */
				break;
			case 'a':
				CHECK_SIZE(optarg, __ARRAY_MAX__)
				bitmap.array_name_to_store = optarg; /* the array name */
				break;
			case 's':
				CHECK_SIZE(optarg, __FILE_MAX__)
				bitmap.file_name_to_save = optarg; /* the file_name.c to save (.c must be included in the name) */
				break;
			case 'n':
				bitmap.ncols_per_row = strtol(optarg, NULL, 10);
				break;
			default :
			PRINT_ERR_AND_RETURN("%s", g_usage)
		}
	}

	/* if NULL argv was left out */
	if (!bitmap.file_name_to_read || !bitmap.array_name_to_store || !bitmap.file_name_to_save) {
		PRINT_ERR_AND_RETURN("%s", g_usage)
	}

	/* sanity check */
	if ((errno == ERANGE && (bitmap.ncols_per_row == LONG_MAX || bitmap.ncols_per_row == LONG_MIN)) ||
		(errno != 0 && bitmap.ncols_per_row == 0)) {
		PRINT_ERRNO_AND_RETURN("-n value spurious")
	}

	bitmap.bitmap_to_read_fd = Open(bitmap.file_name_to_read, O_RDONLY, 0);
	bitmap.c_file_to_write_fd = Open(bitmap.file_name_to_save, O_RDWR | O_CREAT | O_TRUNC, UMASK);

	if (ReadBitmapHeader(&bitmap) < 0 ) {
		#if _VERBOSE == 1
			PRINT_ERR("ReadBitmapHeader failed")
		#endif // _VERBOSE
		return_status = 1; /* fail */

		goto close_fd; 
	}

	switch (bitmap.header.width_px) {
		case 16:
			WriteDataToArray = WriteDataUint16;
			break;
		case 8:
			WriteDataToArray = WriteDataUint8;
			break;
		default:
			WriteDataToArray = WriteDataUint32;
			break;
	}

	WriteCommentToFile(bitmap);
	if (WriteDataToArray(&bitmap) < 0) {
		#if _VERBOSE == 1
			PRINT_ERR("WriteDataToArray failed")
		#endif //_VERBOSE == 1

		return_status = 1; /* fail */
	}

close_fd:
	Close(bitmap.bitmap_to_read_fd);
	Close(bitmap.c_file_to_write_fd);

	return return_status;
}


int WriteDataUint8(BitRipTools *data)
{
	int nread, write_status = -1;
	uint32_t *temp_data = calloc((data->header.height_px * data->header.width_px) + 1, 1);

	if (Lseek(data->bitmap_to_read_fd, data->header.offset, SEEK_SET) != data->header.offset) {
		#if _VERBOSE == 1
			PRINT_ERRNO("Lseek failed")
		#endif //_VERBOSE == 1

		goto io_error;
	}

	nread = IoRead(data->bitmap_to_read_fd, temp_data, data->header.image_size_bytes);
	if (nread < 0) {
		#if _VERBOSE == 1
			PRINT_ERRNO("IoRead error")
		#endif //_VERBOSE == 1

		goto io_error; 
	}

	nread >>= 2;
	Print(data->c_file_to_write_fd, "int g_%s_height = %d; /* height in bits */ \n", data->array_name_to_store, data->header.height_px);
	Print(data->c_file_to_write_fd, "int g_%s_width = %d; /* width in bits */\n", data->array_name_to_store, data->header.width_px);
	Print(data->c_file_to_write_fd, "int g_%s_size = %d; /* total bytes */\n\n", data->array_name_to_store, data->header.image_size_bytes);

	Print(data->c_file_to_write_fd, "const uint%d_t %s[] = {\n", data->header.width_px, data->array_name_to_store);
	for (nread = nread - 1; nread >= 0; nread--) {
		temp_data[nread] = ~temp_data[nread];
		temp_data[nread] = temp_data[nread] & 0x000000ff;
		Print(data->c_file_to_write_fd, "\t0x%02x,", temp_data[nread]);
		if (nread % data->ncols_per_row == 0)
			Print(data->c_file_to_write_fd, "\n");
		}

	Print(data->c_file_to_write_fd, "}; /* Generated with BitRip <mwalk762@mtroyal.ca> */ \n\n");
	write_status = 0;

io_error:
	return write_status;
}


int WriteDataUint16(BitRipTools *data)
{
	int nread, write_status = -1;
	uint32_t *temp_data = calloc((data->header.height_px * data->header.width_px) + 1, 1);

	if (Lseek(data->bitmap_to_read_fd, data->header.offset, SEEK_SET) != data->header.offset) {
		#if _VERBOSE == 1
			PRINT_ERRNO("Lseek failed")
		#endif //_VERBOSE == 1

		goto io_error;
	}

	nread = IoRead(data->bitmap_to_read_fd, temp_data, data->header.image_size_bytes);
	if (nread < 0) {
		#if _VERBOSE == 1
			PRINT_ERRNO("IoRead error")
		#endif //_VERBOSE == 1

		goto io_error; 
	}

	nread >>= 2;
	Print(data->c_file_to_write_fd, "int g_%s_height = %d; /* height in bits */ \n", data->array_name_to_store, data->header.height_px);
	Print(data->c_file_to_write_fd, "int g_%s_width = %d; /* width in bits */\n", data->array_name_to_store, data->header.width_px);
	Print(data->c_file_to_write_fd, "int g_%s_size = %d; /* total bytes */\n\n", data->array_name_to_store, data->header.image_size_bytes);

	Print(data->c_file_to_write_fd, "const uint%d_t %s[] = {\n", data->header.width_px, data->array_name_to_store);
	for (nread = nread - 1; nread >= 0; nread--) {
		temp_data[nread] = ENDIAN16(temp_data[nread]);
		temp_data[nread] = ~temp_data[nread];
		temp_data[nread] &= 0x0000ffff;
		Print(data->c_file_to_write_fd, "\t0x%04x,", temp_data[nread]);
		if (nread % data->ncols_per_row == 0)
			Print(data->c_file_to_write_fd, "\n");
	}

	Print(data->c_file_to_write_fd, "}; /* Generated with BitRip <mwalk762@mtroyal.ca> */ \n\n");
	write_status = 0;

io_error:
	return write_status;
}


int WriteDataUint32(BitRipTools *data)
{
	int nread, write_status = -1;
	uint32_t *temp_data = calloc((data->header.height_px * data->header.width_px) + 1, 1);

	if (Lseek(data->bitmap_to_read_fd, data->header.offset, SEEK_SET) != data->header.offset) {
		#if _VERBOSE == 1
			PRINT_ERRNO("Lseek failed")
		#endif //_VERBOSE == 1

		goto io_error;
	}

	nread = IoRead(data->bitmap_to_read_fd, temp_data, data->header.image_size_bytes);
	if (nread < 0) {
		#if _VERBOSE == 1
			PRINT_ERRNO("IoRead error")
		#endif //_VERBOSE == 1

		goto io_error; 
	}

	nread >>= 2;
	Print(data->c_file_to_write_fd, "int g_%s_height = %d; /* height in bits */ \n", data->array_name_to_store, data->header.height_px);
	Print(data->c_file_to_write_fd, "int g_%s_width = %d; /* width in bits */\n", data->array_name_to_store, data->header.width_px);
	Print(data->c_file_to_write_fd, "int g_%s_size = %d; /* total bytes */\n\n", data->array_name_to_store, data->header.image_size_bytes);

	Print(data->c_file_to_write_fd, "const uint%d_t %s[] = {\n", data->header.width_px, data->array_name_to_store);
	for (nread = nread - 1; nread >= 0; nread--) {
		temp_data[nread] = ENDIAN32(temp_data[nread]);
		temp_data[nread] = ~temp_data[nread];
		Print(data->c_file_to_write_fd, "\t0x%08x,", temp_data[nread]);
		if (nread % data->ncols_per_row == 0)
			Print(data->c_file_to_write_fd, "\n");
	}

	Print(data->c_file_to_write_fd, "}; /* Generated with BitRip <mwalk762@mtroyal.ca> */ \n\n");
	write_status = 0;

io_error:
	return write_status;
}


int ReadBitmapHeader(BitRipTools *data)
{
	/* Update to read once and parse (54 bytes) */
	if (IoRead(data->bitmap_to_read_fd, &data->header.type, 2) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.size, 4) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.reserved1, 2) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.reserved2, 2) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.offset, 4) < 0)
		return -1;

	if (IoRead(data->bitmap_to_read_fd, &data->header.dib_header_size, 4) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.width_px, 4) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.height_px, 4) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.num_planes, 2) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.bits_per_pixel, 2) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.compression, 4) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.image_size_bytes, 4) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.x_resolution_ppm, 4) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.y_resolution_ppm, 4) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.num_colors, 4) < 0)
		return -1; 

	if (IoRead(data->bitmap_to_read_fd, &data->header.important_colors, 4) < 0)
		return -1; 
}


void WriteCommentToFile(BitRipTools data)
{
	size_t i;
	const int header_values[] = {
			data.header.type,
			data.header.size,
			data.header.reserved1,
			data.header.reserved2,
			data.header.offset,
			data.header.dib_header_size,
			data.header.width_px,
			data.header.height_px,
			data.header.num_planes,
			data.header.bits_per_pixel,
			data.header.compression,
			data.header.image_size_bytes,
			data.header.x_resolution_ppm,
			data.header.y_resolution_ppm,
			data.header.num_colors,
			data.header.important_colors
	};

	Print(data.c_file_to_write_fd, "/*\tBitRip Copyleft !(c) 2020, Michael S. Walker <mwalk762@mtroyal.ca>\n");
	Print(data.c_file_to_write_fd, " *\tAll Rights Unreserved in all Federations, including Alpha Centauris.\n");
	Print(data.c_file_to_write_fd, " *\n");
	Print(data.c_file_to_write_fd, " *\t.--. https://github.com/heapsmash/Monochrome-Bitmap-Converter ---------.\n");
	Print(data.c_file_to_write_fd, " *\t|  |    Header Name    | Value |              Description              |\n");
	Print(data.c_file_to_write_fd, " *\t:--+-------------------+-------+---------------------------------------:\n");
	Print(data.c_file_to_write_fd, " *\t|  | %-17s | %-5x | %-37s |\n", g_header_names[0], header_values[0], g_header_description[0]);
	Print(data.c_file_to_write_fd, " *\t:--+-------------------+-------+---------------------------------------:\n");

	for (i = 1; i < sizeof header_values / sizeof(int); i++) {
		Print(data.c_file_to_write_fd, " *\t|  | %-17s | %-5d | %-37s |\n", g_header_names[i], header_values[i], g_header_description[i]);
		Print(data.c_file_to_write_fd, " *\t:--+-------------------+-------+---------------------------------------:\n");
	}
	Print(data.c_file_to_write_fd, " */\n\n");
}


#pragma clang diagnostic pop
