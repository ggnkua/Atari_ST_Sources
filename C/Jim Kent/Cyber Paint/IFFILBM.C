

#include <osbind.h>
#include "flicker.h"
#include "jiff.h"


extern char *unpack_line();
extern long pt_to_long();

uncompress_body(s, d, width, height, planes, compressed)
register char *s;
register char *d;
WORD width, height;
WORD planes;
WORD compressed;
{
char *line_buf;
register WORD linebytes;
WORD clear_first;
WORD extra_planes;
register unsigned WORD plane_offset;
unsigned WORD next_line;
int i;
int copy_planes;
register int j;

next_line = linebytes = Mask_line(width);
next_line *= 4;
if ((line_buf = (char *)askmem(linebytes)) == NULL)
	{
	outta_memory();
	return(0);
	}
clear_first = (planes < 4);
extra_planes = planes - 4;
copy_planes = planes;
if (copy_planes > 4)
	copy_planes = 4;


i = height;
while (--i >= 0)
	{
	if (clear_first)
		word_zero(d, next_line/sizeof(WORD));
	j = copy_planes;
	plane_offset = 0;
	while (--j >= 0)
		{
		if (compressed)
			{
			s = unpack_line(s, line_buf, linebytes);
			unravel_line(line_buf, d+plane_offset, linebytes);
			}
		else
			{
			unravel_line(s, d+plane_offset, linebytes);
			s += linebytes;
			}
		plane_offset += sizeof(WORD);
		}
	j = extra_planes;
	while (--j >= 0)
		{
		if (compressed)
			s = unpack_line(s, line_buf, linebytes);
		else
			s += linebytes;
		}
	d += next_line;
	}
freemem(line_buf);
return(1);
}


uncode_ilbm(file, size)
char *file;
long size;
{
register struct iff_chunk *chunk;
char *end = file+size;
register struct BitMapHeader *header = NULL;


free_cel(clipping);
clipping = NULL;
file += 4;	/* skip over "ILBM" already ! */
while (pt_to_long(file) < pt_to_long(end) )
	{
	chunk = (struct iff_chunk *)file;
	file += sizeof(*chunk);
	switch (chunk->iff_type.b4_type)
		{
		case BMHD:
			header = (struct BitMapHeader *)file;
			free_cel(clipping);
			if ((clipping = alloc_cel(header->w, header->h)) == NULL)
				{
				outta_memory();
				return(0);
				}
			clipping->xoff = header->x;
			clipping->yoff = header->y;
			if (header->compression > 1 || header->masking)
				{
				mangled();
				return(0);
				}
		case CMAP:
			if (clipping != NULL)
				ea_to_st_cmap(file, clipping->cmap);
			else
				{
				mangled();
				return(0);
				}
			break;
		case BODY:
			if (clipping != NULL)
				{
				return(uncompress_body(file, clipping->image,
					header->w, header->h, 
					header->nPlanes, header->compression));
				}
			else
				{
				mangled();
				return(0);
				}
			break;
		}
	file += chunk->iff_length;
	}
}

ea_to_st_cmap(ea, st)
register unsigned char *ea;
register WORD *st;
{
register WORD i;

i = 16;
while (--i >= 0)
	{
	*st++ =  ((ea[0]&0xe0)<<7) + ((ea[1]&0xe0)<<3) + ((ea[2]&0xe0)>>1);
	ea += 3;
	}
}


load_bl1(name)
char *name;
{
int file;
struct iff_chunk main_chunk;
int success = 1;

if ((file = Fopen(name, 0)) <= 0)
	{
	couldnt_open(name);
	return(0);
	}
if (Fread(file, (long)sizeof(main_chunk), &main_chunk) < sizeof(main_chunk) )
	{
	file_truncated(name);
	Fclose(file);
	return(0);
	}
if (main_chunk.iff_type.b4_type != FORM)
	{
	mangled();
	Fclose(file);
	return(0);
	}
if (main_chunk.iff_length > 64000L)
	{
	too_big();
	Fclose(file);
	return(0);
	}
sub_ram_deltas(bscreen);
if (Fread(file, main_chunk.iff_length, prev_screen) < main_chunk.iff_length)
	{
	file_truncated(name);
	Fclose(file);
	success = 0;
	goto end;
	}
Fclose(file);
if (!uncode_ilbm(prev_screen, main_chunk.iff_length))
	{
	success = 0;
	goto end;
	}
if (!mask_cel(clipping))
	{
	outta_memory();
	free_cel(clipping);
	clipping = NULL;
	success = 0;
	goto end;
	}
end:
update_next_prev(bscreen);
return(success);
}


st_to_ea_cmap(st, ea)
register WORD *st;
register unsigned char *ea;
{
register WORD i;
register WORD ast;

i = 16;
while (--i >= 0)
	{
	ast = *st++;
	*ea++ = ((ast&0x700)>>3);
	*ea++ = ((ast&0x070)<<1);
	*ea++ = ((ast&0x007)<<5);
	}
}


save_bl1(name)
char *name;
{
int file;
struct form_chunk main_chunk;
struct iff_chunk ichunk;
struct BitMapHeader header;
char eacmap[3*COLORS];
int success = 1;
long bod_size;
int i;
register WORD *linebuffer;
register char *image;
register long linesize;
register WORD linebytes;

linebytes = Mask_line(clipping->width);
linesize = linebytes*BITPLANES;
if ((linebuffer = begmem((int)linesize)) == NULL)
	{
	return(0);
	}
Fdelete(name);
if ((file = Fcreate(name, 0)) < 0)
	{
	freemem(linebuffer);
	couldnt_open(name);
	return(0);
	}
bod_size = linesize*clipping->height;

main_chunk.fc_length = bod_size + 3*sizeof(ichunk) + 4 + sizeof(eacmap) +
	sizeof(header);
main_chunk.fc_type.b4_type = FORM;
main_chunk.fc_subtype.b4_type = ILBM;

if (Fwrite(file, (long)sizeof(main_chunk), &main_chunk) < sizeof(main_chunk) )
	{
	goto truncated;
	}
header.x = clipping->xoff;
header.y = clipping->yoff;
header.w = clipping->width;
header.h = clipping->height;
header.nPlanes = BITPLANES;
header.masking = header.compression = header.pad1 = 0;
header.transparentColor = 0;
header.xAspect = 10;
header.yAspect = 11;
header.pageWidth = 320;
header.pageHeight = 200;
ichunk.iff_type.b4_type = BMHD;
ichunk.iff_length = sizeof(header);
if (Fwrite(file, (long)sizeof(ichunk), &ichunk) < sizeof(ichunk) )
	{
	goto truncated;
	}
if (Fwrite(file, (long)sizeof(header), &header) < sizeof(header) )
	{
	goto truncated;
	}
st_to_ea_cmap(sys_cmap, eacmap);
ichunk.iff_type.b4_type = CMAP;
ichunk.iff_length = sizeof(eacmap);
if (Fwrite(file, (long)sizeof(ichunk), &ichunk) < sizeof(ichunk) )
	{
	goto truncated;
	}
if (Fwrite(file, (long)sizeof(eacmap), eacmap) < sizeof(eacmap) )
	{
	goto truncated;
	}
ichunk.iff_type.b4_type = BODY;
ichunk.iff_length = bod_size;
if (Fwrite(file, (long)sizeof(ichunk), &ichunk) < sizeof(ichunk) )
	{
	goto truncated;
	}
i = clipping->height;
image = (char *)clipping->image;
while (--i >= 0)
	{
	ravel_4line(image, linebuffer, linebytes);
	if (Fwrite(file, linesize, linebuffer) < linesize)
		{
		goto truncated;
		}
	image += linesize;
	}
goto end;

truncated:
	file_truncated(name);
	success = 0;
end:
	freemem(linebuffer);
	Fclose(file);
	return(success);
}
