/*
 * cmp.c
 *
 * module to allocate memory and compare two files.
 *
 * Roy Bixler
 * March 15, 1991
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 1, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */



#include <fcntl.h>
#include <types.h>	/* must be included before stat.h */
#include <stat.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "cmp.h"



#define CMP_FILE_BUF_SIZE 0xfffe



/*
 * alloc_file_buffers
 *
 * allocate two file buffers in preparation for a file compare.  The
 * size of the two buffers starts at 64K or the file size (whichever is
 * smaller) and works its way down.  Returns zero on total failure and the
 * allocated buffer size otherwise.
 */
unsigned int alloc_file_buffers(char **buf1, char **buf2, long file_size)

{
	unsigned int buf_size = (unsigned int) ((file_size <=
											((long) CMP_FILE_BUF_SIZE))
										   ? file_size
										   : CMP_FILE_BUF_SIZE);

	*buf1 = *buf2 = NULL;
	while ((((*buf1 = malloc((size_t) buf_size)) == NULL) ||
			((*buf2 = malloc((size_t) buf_size)) == NULL)) &&
		   (buf_size > 0)) {
		if (*buf1 != NULL)
			free(*buf1);
		if (*buf2 != NULL)
			free(*buf2);
		buf_size >>= 1;
	}

	return buf_size;
}



/*
 * do_compare_files
 *
 * given handles of 2 files opened for read, compare the contents of the two
 * and return non-zero if they are the same, zero if not.
 */
int do_compare_files(int file1, int file2)

{
	struct stat tmp1, tmp2;
	char *buf1, *buf2;
	int ret_val = 1;
	unsigned int buf_len;
	long i, read1, read2, file_len;

	fstat(file1, &tmp1);
	fstat(file2, &tmp2);
	if ((file_len = tmp1.st_size) != tmp2.st_size)
		return 0;
	else if (!file_len)
		return 1;
	else if (!(buf_len = alloc_file_buffers(&buf1, &buf2, file_len))) {
		printf("could not allocate compare file buffers - file length = %ld\n", file_len);
		exit(-1);
	}

	for (i=0; i<file_len; i += buf_len) {
		read1 = read(file1, buf1, buf_len);
		read2 = read(file2, buf2, buf_len);
		if ((read1 != read2) || (memcmp(buf1, buf2, (size_t) buf_len))) {
			ret_val = 0;
			break;
		}
	}

	free(buf1);
	free(buf2);

	return ret_val;
}



/*
 * compare_files
 *
 * given a pair of files specified by path and name, return non-zero if their
 * contents match, zero if contents don't match.
 *
 * Note: If both files can't be opened, it reports they are the same
 * (i.e. non-existent)!
 */
int compare_files(char *file1, char *file2)

{
	int ret_val, in1, in2;

	if (((in1 = open(file1, O_RDONLY, 0)) < 0) ||
		((in2 = open(file2, O_RDONLY, 0)) < 0)) {
		printf("file compare failed to open both files\n");
		if (in1 >= 0)
			close(in1);
		ret_val = ((in1 < 0) && (in2 < 0));
	}
	else {
		ret_val = do_compare_files(in1, in2);
		close(in1);
		close(in2);
	}

	return ret_val;
}
