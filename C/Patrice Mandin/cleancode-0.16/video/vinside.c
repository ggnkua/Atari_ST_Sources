/*
	Videl Inside 2 video modes

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#include <fcntl.h>
#include <unistd.h>

#include <mint/osbind.h>
#include <mint/sysvars.h>

#include "vinside.h"
#include "param.h"
#include "endian.h"

/*--- Constants ---*/

const vi_limits_t vi_limits[4]={
	{31000,33000, 500,750}, /* Monochrome monitor */
	{15000,16000, 475,610},	/* RGB monitor */
	{31000,35000, 500,750},	/* VGA monitor */
	{15000,16000, 475,610},	/* TV monitor */
};

/*--- Functions ---*/

vi_header_t *VI_LoadModes(void)
{
	unsigned char filename[16];
	unsigned char bootdrive;
	int handle, length;
	vi_header_t *buffer;
	void *oldpile;
	unsigned char id[8];

	/* Find boot drive */
	oldpile = (void *)Super(NULL);
	bootdrive='A'+ *((volatile unsigned short *)_bootdev);
	Super(oldpile);

	sprintf(&filename[0], "%c%s", bootdrive, ":\\vi2.dat");

	/* Load file */
	handle = open(filename, O_RDONLY);
	if (handle<0) {
		fprintf(output_handle, "Unable to open %s\n", filename);	
		return NULL;
	}

	length = lseek(handle, 0, SEEK_END);
	lseek(handle, 0, SEEK_SET); 	

	buffer = (vi_header_t *)malloc(length);
	if (buffer==NULL) {
		fprintf(output_handle, "Unable to allocate %d bytes\n", length);
		return NULL;
	}

	read(handle, buffer, length);
	close(handle);

	/* Check if header correct */
	if (strcmp(buffer->name, "DATFILE\0")!=0) {
		fprintf(output_handle, "Wrong file\n");
		return NULL;
	}

	if (GET_BE_WORD(buffer,version) != 0x0103) {
		fprintf(output_handle, "Wrong version\n");
		return NULL;
	}

	return buffer;
}
