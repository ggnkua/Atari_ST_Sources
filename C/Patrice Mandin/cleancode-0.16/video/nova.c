/*
	NOVA video cards definitions

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

#include "nova.h"
#include "param.h"

/*--- Functions ---*/

nova_resolution_t *nova_LoadModes(int *num_modes)
{
	unsigned char filename[32];
	unsigned char bootdrive;
	void *oldstack;
	int handle, length;
	nova_resolution_t *buffer;

	/* Find boot drive */
	oldstack = (void *)Super(NULL);
	bootdrive='A'+ *((volatile unsigned short *)_bootdev);
	Super(oldstack);

	sprintf(&filename[0], "%c%s", bootdrive, ":\\auto\\sta_vdi.bib");

	/* Load file */
	handle = open(filename, O_RDONLY);
	if (handle<0) {
		fprintf(output_handle, "Unable to open %s\n", filename);	
		return NULL;
	}

	length = lseek(handle, 0, SEEK_END);
	lseek(handle, 0, SEEK_SET); 	

	buffer = (nova_resolution_t *)malloc(length);
	if (buffer==NULL) {
		fprintf(output_handle, "Unable to allocate %d bytes\n", length);
		return NULL;
	}

	read(handle, buffer, length);
	close(handle);
	
	if (num_modes!=NULL) {
		*num_modes=length/sizeof(nova_resolution_t);
	}

	return buffer;
}
