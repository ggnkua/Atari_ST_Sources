/*
	Vdi common code, used by AES and VDI demo programs

	Copyright (C) 2002	Patrice Mandin

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include <stdio.h>
#include <string.h>

#include <gem.h>
#include <mint/osbind.h>
#include <mint/cookie.h>

#include "rgb.h"
#include "eddi_s.h"
#include "mxalloc.h"
#include "param.h"

/*--- Variables ---*/

short vdi_workin[12], vdi_workout[272];
short vdi_handle;

/* Hardware -> vdi palette mapping */
unsigned char vdi_index[256] = {
	0,  2,  3,  6,  4,  7,  5,   8,
	9, 10, 11, 14, 12, 15, 13, 255
};

/* Current VDI palette */
short vdi_palette[256][3];

/*--- Functions prototypes ---*/

static void VDI_ReadEddiInfos(framebuffer_t *framebuffer);

/*--- Functions ---*/

int VDI_OpenWorkstation(int apid)
{
	int i;
	unsigned short dummy;

	/* Init VDI workstation */
	vdi_workin[0]=Getrez()+2;
	for(i = 1; i < 10; i++)
		vdi_workin[i] = 1;
	vdi_workin[10] = 2;

	if (apid>=0) {
		vdi_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);
		if (vdi_handle<1) {
			fprintf(stderr,"Wrong VDI handle %d returned by AES\n",vdi_handle);
			return -1;
		}

		v_opnvwk(vdi_workin, &vdi_handle, vdi_workout);
	} else {
		vdi_handle = -1;
		v_opnwk(vdi_workin, &vdi_handle, vdi_workout);
	}

	if (vdi_handle == 0) {
		fprintf(stderr,"Can not open VDI workstation\n");
		return -1;
	}

	return 0;
}

void VDI_CloseWorkstation(int apid)
{
	if (vdi_handle<=0)
		return;

	if (apid>=0) {
		v_clsvwk(vdi_handle);
	} else {
		v_clswk(vdi_handle);
	}
}

void VDI_SavePalette(framebuffer_t *framebuffer)
{
	short rgb[3];
	int i, bpp;

	bpp = framebuffer->bpp;
	if (bpp>8) {
		bpp = 8;
	}

	for(i = 0; i < (1<<bpp); i++) {
		vq_color(vdi_handle, i, 0, rgb);
		vdi_palette[i][0] = rgb[0];
		vdi_palette[i][1] = rgb[1];
		vdi_palette[i][2] = rgb[2];
	}
}

void VDI_RestorePalette(framebuffer_t *framebuffer)
{
	short rgb[3];
	int i, bpp;

	bpp = framebuffer->bpp;
	if (bpp>8) {
		bpp = 8;
	}

	for(i = 0; i < (1<<bpp); i++) {
		rgb[0] = vdi_palette[i][0];
		rgb[1] = vdi_palette[i][1];
		rgb[2] = vdi_palette[i][2];
		vs_color(vdi_handle, i, rgb);
	}
}

void VDI_InitPalette(framebuffer_t *framebuffer)
{
	short rgb[3];
	int i, numshades, bpp;

	bpp = framebuffer->bpp;
	if (bpp>8) {
		return;
	}

	numshades = ((1<<bpp)-1)/3;

	/* R */
	rgb[0] = rgb[1] = rgb[2] = 0;
	for (i=0;i<numshades;i++) {
		if (numshades == 1) {
			rgb[0] = 1000;
		} else {
			rgb[0] = (i*1000)/(numshades-1);
		}
		vs_color(vdi_handle, vdi_index[i+1], rgb);
	}

	/* G */
	rgb[0] = rgb[1] = rgb[2] = 0;
	for (i=0;i<numshades;i++) {
		if (numshades == 1) {
			rgb[1] = 1000;
		} else {
			rgb[1] = (i*1000)/(numshades-1);
		}
		vs_color(vdi_handle, vdi_index[i+1+numshades], rgb);
	}

	/* B */
	rgb[0] = rgb[1] = rgb[2] = 0;
	for (i=0;i<numshades;i++) {
		if (numshades == 1) {
			rgb[2] = 1000;
		} else {
			rgb[2] = (i*1000)/(numshades-1);
		}
		vs_color(vdi_handle, vdi_index[i+1+(numshades<<1)], rgb);
	}
}

void VDI_ReadInfos(framebuffer_t *framebuffer)
{
	unsigned short width, height, bpp;
	int i;

	/* Informations from v_open[v]wk() */
	fprintf(output_handle, "Standard workstation informations:\n");
	width = vdi_workout[0] + 1;
	height = vdi_workout[1] + 1;
	fprintf(output_handle, " Width=%d, Height=%d, Pens=%d\n", width, height, vdi_workout[13]);

	/* Informations from vq_extnd() */
	fprintf(output_handle, "Extended workstation informations:\n");
	vq_extnd(vdi_handle, 1, vdi_workout);
	bpp = vdi_workout[4];
	fprintf(output_handle, " %d bits per pixel, ", bpp);
	if (vdi_workout[5]) {
		fprintf(output_handle, "with palette\n");
	} else {
		fprintf(output_handle, "without palette\n");
	}
	
	/* Init hardware -> VDI palette mapping */
	for(i = 16; i < 255; i++) {
		vdi_index[i] = i;
	}
	vdi_index[255] = 1;
	if (bpp == 4) {
		vdi_index[15] = 1;
	}
	if (bpp == 2) {
		vdi_index[3] = 1;
	}

	RGB_InitFramebuffer(framebuffer, width, height, bpp);

	/* Informations from vq_scrninfo() */
	VDI_ReadEddiInfos(framebuffer);

	/* Display our infos */
	fprintf(output_handle, "Final workstation informations:\n");
	fprintf(output_handle, " Address=0x%08x,",framebuffer->buffer);
	fprintf(output_handle, " Pitch=%d,",framebuffer->pitch);
	fprintf(output_handle, " Format=");
	switch (framebuffer->format) {
		case FBFORMAT_BITPLANES:
			fprintf(output_handle, "bitplanes\n");
			break;
		case FBFORMAT_VDI:
			fprintf(output_handle, "vdi bitplanes\n");
			break;
		case FBFORMAT_PACKED:
			fprintf(output_handle, "packed pixels\n");
			break;
		default:
			fprintf(output_handle, "unknown\n");
			break;
	}
	fprintf(output_handle, " Width=%d,", framebuffer->width);
	fprintf(output_handle, " Height=%d,", framebuffer->height);
	fprintf(output_handle, " Depth=%d\n", framebuffer->bpp);
	if (framebuffer->bpp>8) {
		fprintf(output_handle, " A=0x%08x,", framebuffer->amask); 
		fprintf(output_handle, " R=0x%08x,", framebuffer->rmask); 
		fprintf(output_handle, " G=0x%08x,", framebuffer->gmask); 
		fprintf(output_handle, " B=0x%08x\n", framebuffer->bmask); 
	}
}

static void VDI_ReadEddiInfos(framebuffer_t *framebuffer)
{
	unsigned long EdDI_version;
	unsigned long cookie_EdDI;

	unsigned long num_colours, num_bits, clut_type, bigendian;

	/* Read cookie */
	if  (Getcookie(C_EdDI, &cookie_EdDI) == C_NOTFOUND) {
		return;
	}

	EdDI_version=get_EdDI_version( (void *)cookie_EdDI);

	vq_scrninfo(vdi_handle, vdi_workout);
	fprintf(output_handle, "EdDI workstation informations:\n");
	fprintf(output_handle, " EdDI version %02x.%02x\n",
		(EdDI_version>>8) & 0xff,
		EdDI_version & 0xff
	);

	framebuffer->format = (fbformat_t) vdi_workout[0];
	switch(framebuffer->format) {
		case FBFORMAT_BITPLANES:
			fprintf(output_handle, " Interleaved bitplanes\n");
			break;
		case FBFORMAT_VDI:
			fprintf(output_handle, " VDI independent format\n");
			break;
		case FBFORMAT_PACKED:
			fprintf(output_handle, " Packed pixels\n");
			break;
		default:
			fprintf(output_handle, " Unknown bitplane organization\n");
			break;
	}

	clut_type = vdi_workout[1];

	num_bits = vdi_workout[2];
	fprintf(output_handle, " %d bitplanes,", num_bits);
	num_colours = *((unsigned long *) &vdi_workout[3]);
	fprintf(output_handle, " %ld colours\n", num_colours);

	if (EdDI_version >= EDDI_11) {
		fprintf(output_handle, "EdDI 1.1 screen format: 0x%04x\n",vdi_workout[14]);

		framebuffer->buffer = (void *) *((unsigned long *) &vdi_workout[6]);
		fprintf(output_handle, " Address=0x%08x,", framebuffer->buffer);
		framebuffer->pitch = vdi_workout[5];
		fprintf(output_handle, " Pitch=%d\n", framebuffer->pitch);

		bigendian = ((vdi_workout[14] & (1<<7))==0);

		switch(num_colours) {
			case 32768UL:
				fprintf(output_handle, " A1R5G5B5: ");
				if (bigendian) {
					if (vdi_workout[14] & (1<<1)) {
						fprintf(output_handle, "RRRRRGGG GGABBBBB\n");
						FBMASK(1<<5, 31<<11, 31<<6, 31);
						FBSHIFT(5, 11, 6, 0);
					} else {
						fprintf(output_handle, "ARRRRRGG GGGBBBBB\n");
					}
				} else {
					if (vdi_workout[14] & (1<<1)) {
						fprintf(output_handle, "GGABBBBB RRRRRGGG\n");
						FBMASK(1<<13, 31<<3, (3 << 14) | 7, 31 << 8);
						FBLOSS(7, 3, 5, 3);
						FBSHIFT(13, 3, 0, 8);
					} else {
						fprintf(output_handle, "GGGBBBBB ARRRRRGG\n");
						FBMASK(1<<7, 31<<2, (7 << 13) | 3, 31 << 8);
						FBLOSS(7, 3, 6, 3);
						FBSHIFT(7, 2, 0, 8);
					}
				}
				break;
			case 65536UL:
				fprintf(output_handle, " A0R5G6B5: ");
				if (bigendian) {
					fprintf(output_handle, "RRRRRGGG GGGBBBBB\n");
				} else {
					fprintf(output_handle, "GGGBBBBB RRRRRGGG\n");
					FBMASK(0, 31<<3, (7<<13)|7, 31<<8);
					FBLOSS(8, 3, 5, 3);
					FBSHIFT(0, 3, 0, 8);
				}
				break;
			case 16777216UL:
				switch(framebuffer->bpp) {
					case 24:
						fprintf(output_handle, " A0R8G8B8: ");
						if (bigendian) {
							fprintf(output_handle, "RRRRRRRR GGGGGGGG BBBBBBBB\n");
						} else {
							fprintf(output_handle, "BBBBBBBB GGGGGGGG RRRRRRRR\n");
							FBMASK(0, 255, 255<<8, 255<<16);
							FBSHIFT(0, 0, 8, 16);
						}					
						break;
					case 32:
						fprintf(output_handle, " A8R8G8B8: ");
						if (bigendian) {
							if (vdi_workout[14] & (1<<1)) {
								fprintf(output_handle, "AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR\n");
								FBMASK(255<<24, 255, 255<<8, 255<<16);
								FBSHIFT(24, 0, 8, 16);
							} else {
								fprintf(output_handle, "AAAAAAAA RRRRRRRR GGGGGGGG BBBBBBBB\n");
							}
						} else {
							if (vdi_workout[14] & (1<<1)) {
								fprintf(output_handle, "RRRRRRRR GGGGGGGG BBBBBBBB AAAAAAAA\n");
								FBMASK(255, 255<<24, 255<<16, 255<<8);
								FBSHIFT(0, 24, 16, 8);
							} else {
								fprintf(output_handle, "BBBBBBBB GGGGGGGG RRRRRRRR AAAAAAAA\n");
								FBMASK(255, 255<<8, 255<<16, 255<<16);
								FBSHIFT(0, 8, 16, 24);
							}
						}
						break;
				}					
				break;
			default:
				fprintf(output_handle, " Paletted mode\n");
				break;
		}

		if (framebuffer->bpp>8) {
			if (bigendian) {
				fprintf(output_handle, " Big endian,");
			} else {
				fprintf(output_handle, " Little endian,");
			}

			fprintf(output_handle, " A=0x%08x,", framebuffer->amask); 
			fprintf(output_handle, " R=0x%08x,", framebuffer->rmask); 
			fprintf(output_handle, " G=0x%08x,", framebuffer->gmask); 
			fprintf(output_handle, " B=0x%08x\n", framebuffer->bmask); 
		}
	}

	fprintf(output_handle, "EdDI screen format:\n");
	switch(clut_type) {
		case CLUT_HARDWARE:
			{
				int i;
				unsigned short *tmp_p;

				tmp_p = (unsigned short *)&vdi_workout[16];

				for (i=0;i<256;i++) {
					vdi_index[*tmp_p++] = i;
				}

				fprintf(output_handle, " Paletted mode\n"); 
			}
			break;
		case CLUT_SOFTWARE:
			{
				int component; /* red, green, blue, alpha, overlay */
				int num_bit;
				unsigned short *tmp_p;
				unsigned long new_amask, new_gmask, new_rmask, new_bmask;
				unsigned char *component_name[5]={"red","green","blue","alpha","overlay"};

				new_amask = new_rmask = new_gmask = new_bmask = 0;

				tmp_p = (unsigned short *) &vdi_workout[16];
				for (component=0;component<5;component++) {
					for (num_bit=0;num_bit<16;num_bit++) {
						unsigned short valeur;

						valeur = *tmp_p++;

						if (valeur == 0xffff) {
							continue;
						}

						fprintf(output_handle, " Bit %d of %s is at position %d\n",num_bit,component_name[component],valeur);

						switch(component) {
							case 0:
								new_rmask |= 1<< valeur;
								break;
							case 1:
								new_gmask |= 1<< valeur;
								break;
							case 2:
								new_bmask |= 1<< valeur;
								break;
							case 3:
								new_amask |= 1<< valeur;
								break;
						}
					}
				}					

				switch(num_colours) {
					case 32768UL:
						fprintf(output_handle, " A1R5G5B5: ");
						switch(new_rmask) {
							case 31<<11:
								fprintf(output_handle, "RRRRRGGG GGABBBBB\n");
								bigendian=1;
								FBLOSS(7, 3, 3, 3);
								FBSHIFT(5, 11, 6, 0);
								break;
							case 31<<10:
								fprintf(output_handle, "ARRRRRGG GGGBBBBB\n");
								bigendian=1;
								FBLOSS(7, 3, 3, 3);
								FBSHIFT(15, 10, 5, 0);
								break;
							case 31<<3:
								fprintf(output_handle, "GGABBBBB RRRRRGGG\n");
								bigendian=0;
								FBLOSS(7, 3, 5, 3);
								FBSHIFT(13, 3, 0, 8);
								break;
							case 31<<2:
								fprintf(output_handle, "GGGBBBBB ARRRRRGG\n");
								bigendian=0;
								FBLOSS(7, 3, 6, 3);
								FBSHIFT(7, 2, 0, 8);
								break;
						}
						break;
					case 65536UL:
						fprintf(output_handle, " A0R5G6B5: ");
						switch(new_rmask) {
							case 31<<11:
								fprintf(output_handle, "RRRRRGGG GGGBBBBB\n");
								bigendian=1;
								FBLOSS(8, 3, 2, 3);
								FBSHIFT(0, 11, 5, 0);
								break;
							case 31<<3:
								fprintf(output_handle, "GGGBBBBB RRRRRGGG\n");
								bigendian=0;
								FBLOSS(8, 3, 5, 3);
								FBSHIFT(0, 3, 0, 8);
								break;
						}
						break;
					case 16777216UL:
						switch(framebuffer->bpp) {
							case 24:
								fprintf(output_handle, " A0R8G8B8: ");
								FBLOSS(0, 0, 0, 0);
								switch(new_rmask) {
									case 255<<16:
										fprintf(output_handle, "RRRRRRRR GGGGGGGG BBBBBBBB\n");
										bigendian=1;
										FBSHIFT(0, 16, 8, 0);
										break;
									case 255:
										fprintf(output_handle, "BBBBBBBB GGGGGGGG RRRRRRRR\n");
										bigendian=0;
										FBSHIFT(0, 0, 8, 16);
										break;
								}
								break;
							case 32:
								fprintf(output_handle, " A8R8G8B8: ");
								FBLOSS(0, 0, 0, 0);
								switch(new_rmask) {
									case 255<<16:
										fprintf(output_handle, "AAAAAAAA RRRRRRRR GGGGGGGG BBBBBBBB\n");
										bigendian=1;
										FBSHIFT(24, 16, 8, 0);
										break;
									case 255<<24:
										fprintf(output_handle, "RRRRRRRR GGGGGGGG BBBBBBBB AAAAAAAA\n");
										bigendian=1;
										FBSHIFT(0, 24, 16, 8);
										break;
									case 255:
										fprintf(output_handle, "AAAAAAAA BBBBBBBB GGGGGGGG RRRRRRRR\n");
										bigendian=0;
										FBSHIFT(24, 0, 8, 16);
										break;
									case 255<<8:
										fprintf(output_handle, "BBBBBBBB GGGGGGGG RRRRRRRR AAAAAAAA\n");
										bigendian=0;
										FBSHIFT(0, 8, 16, 24);
										break;
								}
								break;
						}
						break;
				}
				FBMASK(new_amask, new_rmask, new_gmask, new_bmask);

				if (bigendian) {
					fprintf(output_handle, " Big endian,");
				} else {
					fprintf(output_handle, " Little endian,");
				}
				fprintf(output_handle, " A=0x%08x,", framebuffer->amask); 
				fprintf(output_handle, " R=0x%08x,", framebuffer->rmask); 
				fprintf(output_handle, " G=0x%08x,", framebuffer->gmask); 
				fprintf(output_handle, " B=0x%08x\n", framebuffer->bmask); 

				new_amask = (0xff>>framebuffer->aloss)<<framebuffer->ashift;
				new_rmask = (0xff>>framebuffer->rloss)<<framebuffer->rshift;
				new_gmask = (0xff>>framebuffer->gloss)<<framebuffer->gshift;
				new_bmask = (0xff>>framebuffer->bloss)<<framebuffer->bshift;

				fprintf(output_handle, " Deduced: A=0x%08x,", new_amask); 
				fprintf(output_handle, " R=0x%08x,", new_rmask); 
				fprintf(output_handle, " G=0x%08x,", new_gmask); 
				fprintf(output_handle, " B=0x%08x\n", new_bmask); 
			}
			break;
	}
}

void VDI_ClearScreen(framebuffer_t *framebuffer)
{
	short rgb[3]={0,0,0};
	short pxy[4];

	/* Set color 0 to black */
	if (framebuffer->bpp > 1) {
		vs_color(vdi_handle, vdi_index[0], rgb);
	}
	vsf_color(vdi_handle,0);
	vsf_interior(vdi_handle,1);
	vsf_perimeter(vdi_handle,0);

	/* Draw a filled rectangle */
	pxy[0] = pxy[1] = 0;
	pxy[2] = framebuffer->width - 1;
	pxy[3] = framebuffer->height - 1;
	v_bar(vdi_handle,pxy);
}

unsigned long VDI_AllocateIndirectBuffer(framebuffer_t *framebuffer)
{
	unsigned long screensize;

	if (framebuffer->bpp >= 8) {
		screensize = framebuffer->width * framebuffer->pixsize;
	} else {
		screensize = (framebuffer->width * framebuffer->bpp)>>3;
	}
	screensize *= framebuffer->height;

	framebuffer->buffer = (void *) Atari_SysMalloc(screensize, MX_PREFTTRAM);
	if (framebuffer->buffer!=NULL) {
		memset(framebuffer->buffer, 0, screensize);
	} else {
		fprintf(stderr, "Could not allocate %d bytes for indirect rendering\n",screensize);		
		screensize = 0;
	}

	return screensize;
}

void VDI_FreeIndirectBuffer(framebuffer_t *framebuffer)
{
	if (framebuffer->buffer) {
		Mfree(framebuffer->buffer);
		framebuffer->buffer=NULL;
	}
}

void VDI_DrawBars_vrocpyfm(framebuffer_t *framebuffer, fbrect_t *rect)
{
	MFDB src_mfdb, dst_mfdb;
	short blitcoords[8], x1, y1, x2, y2;

	if (framebuffer->buffer==NULL)
		return;

	/* vro_cpyfm() output is not clipped by vs_clip() */
	x1 = rect->x;
	if (x1<0) x1=0;
	if (x1>=framebuffer->width) x1=framebuffer->width-1;

	y1 = rect->y;
	if (y1<0) y1=0;
	if (y1>=framebuffer->height) y1=framebuffer->height-1;

	x2 = rect->x + rect->w - 1;
	if (x2<0) x2=0;
	if (x2>=framebuffer->width) x2=framebuffer->width-1;

	y2 = rect->y + rect->h - 1;
	if (y2<0) y2=0;
	if (y2>=framebuffer->height) y2=framebuffer->height-1;

	if ((x1==x2) || (y1==y2))
		return;

	/* Source mfdb */
	src_mfdb.fd_addr=framebuffer->buffer;
	src_mfdb.fd_w=framebuffer->width;
	src_mfdb.fd_h=framebuffer->height;
	src_mfdb.fd_wdwidth=(framebuffer->width) >> 4;
	src_mfdb.fd_stand=0;
	src_mfdb.fd_nplanes=framebuffer->bpp;
	src_mfdb.fd_r1=0;
	src_mfdb.fd_r2=0;
	src_mfdb.fd_r3=0;

	/* Destination mfdb */
	dst_mfdb.fd_addr = NULL;

	/* Source coordinates */
	blitcoords[0] = x1;
	blitcoords[1] = y1;
	blitcoords[2] = x2;
	blitcoords[3] = y2;

	/* Destination coordinates */
	blitcoords[4] = x1;
	blitcoords[5] = y1;
	blitcoords[6] = x2;
	blitcoords[7] = y2;

	vro_cpyfm(vdi_handle, S_ONLY, blitcoords, &src_mfdb, &dst_mfdb);
}

void VDI_DrawBars_vbar(framebuffer_t *framebuffer, fbrect_t *rect, int component)
{
	short rgb[3], pxy[4];
	int i, x, numshades;

	vsf_color(vdi_handle,0);
	vsf_interior(vdi_handle,1);
	vsf_perimeter(vdi_handle,0);

	if (framebuffer->bpp <= 8) {
		numshades = ((1<<framebuffer->bpp)-1)/3;
	} else {
		numshades = 0;
	}

	for (i=0; i<rect->w;i++) {
		if (framebuffer->bpp > 8) {
			/* Set color 0 to current position */
			rgb[0] = rgb[1] = rgb[2] = 0;
			switch(component) {
				case COMPONENT_RED: rgb[0] = (i*1000)/(rect->w-1); break;
				case COMPONENT_GREEN: rgb[1] = (i*1000)/(rect->w-1); break;
				case COMPONENT_BLUE: rgb[2] = (i*1000)/(rect->w-1); break;
			}
			vs_color(vdi_handle, vdi_index[0], rgb);
		} else {
			x = (i*numshades)/(rect->w-1);
			switch(component) {
				case COMPONENT_RED: x += 0; break;
				case COMPONENT_GREEN: x+= numshades; break;
				case COMPONENT_BLUE: x += numshades<<1; break;
			}
			vsf_color(vdi_handle, vdi_index[x+1]);
		}

		/* Draw a filled rectangle */
		pxy[0] = rect->x + i;
		pxy[1] = rect->y + 0;
		pxy[2] = pxy[0] + 0;
		pxy[3] = pxy[1] + rect->h;
		v_bar(vdi_handle,pxy);
	}
}
