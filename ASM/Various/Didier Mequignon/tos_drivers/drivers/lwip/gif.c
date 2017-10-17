/*
 *  Cross platform GIF source code.
 *
 *  Platform: Neutral
 *
 *  Version: 2.30  1997/07/07  Original version by Lachlan Patrick.
 *  Version: 2.35  1998/09/09  Minor upgrade to list functions.
 *  Version: 2.50  2000/01/01  Added the ability to load an animated gif.
 *  Version: 3.00  2001/03/03  Fixed a few bugs and updated the interface.
 *  Version: 3.34  2002/12/18  Debugging code is now better encapsulated.
 *  Version: 3.56  2005/08/09  Silenced a size_t conversion warning.
 */

/* Copyright (c) L. Patrick

   This file is part of the App cross-platform programming package.
   You may redistribute it and/or modify it under the terms of the
   App Software License. See the file LICENSE.TXT for details.
*/

/* ------------------------ System includes ------------------------------- */
#include <string.h>

/* ------------------------ FreeRTOS includes ----------------------------- */
#include "../freertos/FreeRTOS.h"
#include "../freertos/task.h"
#include "../freertos/semphr.h"
#include "../freertos/portable.h"

/* ------------------------ Project includes ------------------------------ */
#include "config.h"
#include "net.h"
#include "gif.h"

#ifdef NETWORK
#ifdef LWIP

/*
 *  GIF memory allocation helper functions.
 */

void * gif_alloc(long bytes)
{
	void *ptr =	pvPortMalloc2(bytes);
	if(ptr != NULL)
		memset(ptr, 0, bytes);
	return ptr;
}

/*
 *  GIF file input/output functions.
 */

static int write_byte(char **file, int ch)
{
	**file = (char)ch;
	(*file)++;
	return 0;
}

static int write_stream(char **file, unsigned char buffer[], int length)
{
	int i;
	for(i=0; i<length; i++, (*file)++)
		**file = (char)buffer[i];
	return 0;
}

void write_gif_int(char **file, int output)
{
	**file = (char)output;
	(*file)++;
	**file = (char)(output >> 8);
	(*file)++;
}

/*
 *  Gif data blocks:
 */

GifData * new_gif_data(int size)
{
	GifData *data = gif_alloc(sizeof(GifData));
	if(data)
	{
		data->byte_count = size;
		data->bytes = gif_alloc(size * sizeof(unsigned char));
	}
	return data;
}

void del_gif_data(GifData *data)
{
	vPortFree2(data->bytes);
	vPortFree2(data);
}

/*
 *  Write a Gif data block to a file.
 *  A Gif data block is a size-byte followed by that many
 *  bytes of data (0 to 255 of them).
 */
void write_gif_data(char **file, GifData *data)
{
	if(data)
	{
		write_byte(file, data->byte_count);
		write_stream(file, data->bytes, data->byte_count);
	}
	else
		write_byte(file, 0);
}

/*
 *  Write a byte to a Gif file.
 *
 *  This function is aware of Gif block structure and buffers
 *  chars until 255 can be written, writing the size byte first.
 *  If FLUSH_OUTPUT is the char to be written, the buffer is
 *  written and an empty block appended.
 */
static void write_gif_byte(char **file, GifEncoder *encoder, int ch)
{
	unsigned char *buf = encoder->buf;
	if(encoder->file_state == IMAGE_COMPLETE)
		return;
	if(ch == FLUSH_OUTPUT)
	{
		if(encoder->bufsize)
		{
			write_byte(file, encoder->bufsize);
			write_stream(file, buf, encoder->bufsize);
			encoder->bufsize = 0;
		}
		/* write an empty block to mark end of data */
		write_byte(file, 0);
		encoder->file_state = IMAGE_COMPLETE;
	}
	else
	{
		if(encoder->bufsize == 255)
		{
			/* write this buffer to the file */
			write_byte(file, encoder->bufsize);
			write_stream(file, buf, encoder->bufsize);
			encoder->bufsize = 0;
		}
		buf[encoder->bufsize++] = ch;
	}
}

/*
 *  Colour maps:
 */

GifPalette * new_gif_palette(void)
{
	return gif_alloc(sizeof(GifPalette));
}

void del_gif_palette(GifPalette *cmap)
{
	vPortFree2(cmap->colours);
	vPortFree2(cmap);
}

void write_gif_palette(char **file, GifPalette *cmap)
{
	int i;
	Colour c;
	for(i=0; i<cmap->length; i++)
	{
		c = cmap->colours[i];
		write_byte(file, c.red);
		write_byte(file, c.green);
		write_byte(file, c.blue);
	}
}

/*
 *  GifScreen:
 */

GifScreen * new_gif_screen(void)
{
	GifScreen *screen = gif_alloc(sizeof(GifScreen));
	if(screen)
		screen->cmap = new_gif_palette();
	return screen;
}

void del_gif_screen(GifScreen *screen)
{
	del_gif_palette(screen->cmap);
	vPortFree2(screen);
}

void write_gif_screen(char **file, GifScreen *screen)
{
	unsigned char info;
	write_gif_int(file, screen->width);
	write_gif_int(file, screen->height);
	info = (screen->has_cmap ? 0x80 : 0x00);
	info = info | ((screen->color_res - 1) << 4);
	info = info | (screen->sorted ? 0x08 : 0x00);
	if(screen->cmap_depth > 0)
		info = info | ((screen->cmap_depth) - 1);
	write_byte(file, info);
	write_byte(file, screen->bgcolour);
	write_byte(file, screen->aspect);
	if(screen->has_cmap)
		write_gif_palette(file, screen->cmap);
}

/*
 *  GifExtension:
 */

GifExtension *new_gif_extension(void)
{
	return gif_alloc(sizeof(GifExtension));
}

void del_gif_extension(GifExtension *ext)
{
	int i;
	for(i=0; i < ext->data_count; i++)
		del_gif_data(ext->data[i]);
	vPortFree2(ext->data);
	vPortFree2(ext);
}

void write_gif_extension(char **file, GifExtension *ext)
{
	int i;
	write_byte(file, ext->marker);
	for(i=0; i < ext->data_count; i++)
		write_gif_data(file, ext->data[i]);
	write_gif_data(file, NULL);
}

/*
 *  Hash table:
 */

/*
 *  The 32 bits contain two parts: the key & code:
 *  The code is 12 bits since the algorithm is limited to 12 bits
 *  The key is a 12 bit prefix code + 8 bit new char = 20 bits.
 */
#define HT_GET_KEY(x)	((x) >> 12)
#define HT_GET_CODE(x)	((x) & 0x0FFF)
#define HT_PUT_KEY(x)	((x) << 12)
#define HT_PUT_CODE(x)	((x) & 0x0FFF)

/*
 *  Generate a hash key from the given unique key.
 *  The given key is assumed to be 20 bits as follows:
 *    lower 8 bits are the new postfix character,
 *    the upper 12 bits are the prefix code.
 */
static int gif_hash_key(unsigned long key)
{
	return(((key >> 12) ^ key) & HT_KEY_MASK);
}

/*
 *  Clear the hash_table to an empty state.
 */
static void clear_gif_hash_table(unsigned long *hash_table)
{
	int i;
	for(i=0; i<HT_SIZE; i++)
		hash_table[i] = 0xFFFFFFFFL;
}

/*
 *  Insert a new item into the hash_table.
 *  The data is assumed to be new.
 */
static void add_gif_hash_entry(unsigned long *hash_table, unsigned long key, int code)
{
	int hkey = gif_hash_key(key);
	while(HT_GET_KEY(hash_table[hkey]) != 0xFFFFFL)
		hkey = (hkey + 1) & HT_KEY_MASK;
	hash_table[hkey] = HT_PUT_KEY(key) | HT_PUT_CODE(code);
}

/*
 *  Determine if given key exists in hash_table and if so
 *  returns its code, otherwise returns -1.
 */
static int lookup_gif_hash(unsigned long *hash_table, unsigned long key)
{
	int hkey = gif_hash_key(key);
	unsigned long htkey;
	while((htkey = HT_GET_KEY(hash_table[hkey])) != 0xFFFFFL)
	{
		if(key == htkey)
			return HT_GET_CODE(hash_table[hkey]);
		hkey = (hkey + 1) & HT_KEY_MASK;
	}
	return -1;
}

/*
 *  GifEncoder:
 */

GifEncoder *new_gif_encoder(void)
{
	return gif_alloc(sizeof(GifEncoder));
}

void del_gif_encoder(GifEncoder *encoder)
{
	vPortFree2(encoder);
}

/*
 *  Write a Gif code word to the output file.
 *
 *  This function packages code words up into whole bytes
 *  before writing them. It uses the encoder to store
 *  codes until enough can be packaged into a whole byte.
 */
void write_gif_code(char **file, GifEncoder *encoder, int code)
{
	if(code == FLUSH_OUTPUT)
	{
		/* write all remaining data */
		while(encoder->shift_state > 0)
		{
			write_gif_byte(file, encoder, encoder->shift_data & 0xff);
			encoder->shift_data >>= 8;
			encoder->shift_state -= 8;
		}
		encoder->shift_state = 0;
		write_gif_byte(file, encoder, FLUSH_OUTPUT);
	}
	else
	{
		encoder->shift_data |= ((long) code) << encoder->shift_state;
		encoder->shift_state += encoder->running_bits;
		while(encoder->shift_state >= 8)
		{
			/* write full bytes */
			write_gif_byte(file, encoder,
			encoder->shift_data & 0xff);
			encoder->shift_data >>= 8;
			encoder->shift_state -= 8;
		}
	}
	/* If code can't fit into running_bits bits, raise its size.
	 * Note that codes above 4095 are for signalling. */
	if(encoder->running_code >= encoder->max_code_plus_one && code <= 4095)
		encoder->max_code_plus_one = 1 << ++encoder->running_bits;
}

/*
 *   Initialise the encoder, given a GifPalette depth.
 */
void init_gif_encoder(char **file, GifEncoder *encoder, int depth)
{
	int lzw_min = depth = (depth < 2 ? 2 : depth);
	encoder->file_state   = IMAGE_SAVING;
	encoder->position     = 0;
	encoder->bufsize      = 0;
	encoder->buf[0]       = 0;
	encoder->depth        = depth;
	encoder->clear_code   = (1 << depth);
	encoder->eof_code     = encoder->clear_code + 1;
	encoder->running_code = encoder->eof_code + 1;
	encoder->running_bits = depth + 1;
	encoder->max_code_plus_one = 1 << encoder->running_bits;
	encoder->current_code = FIRST_CODE;
	encoder->shift_state  = 0;
	encoder->shift_data   = 0;
	/* Write the LZW minimum code size: */
	write_byte(file, lzw_min);
	/* Clear hash table, output Clear code: */
	clear_gif_hash_table(encoder->hash_table);
	write_gif_code(file, encoder, encoder->clear_code);
}

/*
 *  Write one scanline of pixels out to the Gif file,
 *  compressing that line using LZW into a series of codes.
 */
void write_gif_line(char **file, GifEncoder *encoder, unsigned char *line, int length)
{
	int i = 0, current_code, new_code;
	unsigned long new_key;
	unsigned char pixval;
	unsigned long *hash_table;
	hash_table = encoder->hash_table;
	if(encoder->current_code == FIRST_CODE)
		current_code = line[i++];
	else
		current_code = encoder->current_code;
	while(i < length)
	{
		pixval = line[i++]; /* Fetch next pixel from stream */
		/* Form a new unique key to search hash table for the code
		 * Combines current_code as prefix string with pixval as
		 * postfix char */
		new_key = (((unsigned long) current_code) << 8) + pixval;
		if((new_code = lookup_gif_hash(hash_table, new_key)) >= 0)
		{
			/* This key is already there, or the string is old,
			 * so simply take new code as current_code */
			current_code = new_code;
		}
		else
		{
			/* Put it in hash table, output the prefix code,
			 * and make current_code equal to pixval */
			write_gif_code(file, encoder, current_code);
			current_code = pixval;
			/* If the hash_table if full, send a clear first
			 * then clear the hash table: */
			if(encoder->running_code >= LZ_MAX_CODE)
			{
				write_gif_code(file, encoder, encoder->clear_code);
				encoder->running_code = encoder->eof_code + 1;
				encoder->running_bits = encoder->depth + 1;
				encoder->max_code_plus_one = 1 << encoder->running_bits;
				clear_gif_hash_table(hash_table);
			}
			else
				/* Put this unique key with its relative code in hash table */
				add_gif_hash_entry(hash_table, new_key, encoder->running_code++);
		}
	}
	/* Preserve the current state of the compression algorithm: */
	encoder->current_code = current_code;
}

void flush_gif_encoder(char **file, GifEncoder *encoder)
{
	write_gif_code(file, encoder, encoder->current_code);
	write_gif_code(file, encoder, encoder->eof_code);
	write_gif_code(file, encoder, FLUSH_OUTPUT);
}

/*
 *  GifPicture:
 */

GifPicture * new_gif_picture(void)
{
	GifPicture *pic = gif_alloc(sizeof(GifPicture));
	if(pic)
	{
		pic->cmap = new_gif_palette();
		pic->data = NULL;
	}
	return pic;
}

void del_gif_picture(GifPicture *pic)
{
	int row;
	del_gif_palette(pic->cmap);
	if(pic->data)
	{
		for(row=0; row < pic->height; row++)
			vPortFree2(pic->data[row]);
		vPortFree2(pic->data);
	}
	vPortFree2(pic);
}

static void write_gif_picture_data(char **file, GifPicture *pic)
{
	GifEncoder *encoder;
	long w, h;
	int interlace_start[] = {0, 4, 2, 1};
	int interlace_step[]  = {8, 8, 4, 2};
	int scan_pass, row;
	w = pic->width;
	h = pic->height;
	encoder = new_gif_encoder();
	init_gif_encoder(file, encoder, pic->cmap_depth);
	if(pic->interlace)
	{
		for(scan_pass = 0; scan_pass < 4; scan_pass++)
		{
			row = interlace_start[scan_pass];
			while(row < h)
	    {
				write_gif_line(file, encoder, pic->data[row], w);
				row += interlace_step[scan_pass];
			}
		}
	}
	else
	{
		row = 0;
		while(row < h)
		{
			write_gif_line(file, encoder, pic->data[row], w);
			row += 1;
		}
	}
	flush_gif_encoder(file, encoder);
	del_gif_encoder(encoder);
}

void write_gif_picture(char **file, GifPicture *pic)
{
	unsigned char info;
	write_gif_int(file, pic->left);
	write_gif_int(file, pic->top);
	write_gif_int(file, pic->width);
	write_gif_int(file, pic->height);
	info = (pic->has_cmap    ? 0x80 : 0x00);
	info = info | (pic->interlace   ? 0x40 : 0x00);
	info = info | (pic->sorted      ? 0x20 : 0x00);
	info = info | ((pic->reserved << 3) & 0x18);
	if(pic->has_cmap)
		info = info | (pic->cmap_depth - 1);
	write_byte(file, info);
	if(pic->has_cmap)
		write_gif_palette(file, pic->cmap);
	write_gif_picture_data(file, pic);
}

/*
 *  GifBlock:
 */

GifBlock *new_gif_block(void)
{
	return gif_alloc(sizeof(GifBlock));
}

void del_gif_block(GifBlock *block)
{
	if(block->pic)
		del_gif_picture(block->pic);
	if(block->ext)
		del_gif_extension(block->ext);
	vPortFree2(block);
}

void write_gif_block(char **file, GifBlock *block)
{
	write_byte(file, block->intro);
	if(block->pic)
		write_gif_picture(file, block->pic);
	if(block->ext)
		write_gif_extension(file, block->ext);
}

/*
 *  Gif:
 */

Gif * new_gif(void)
{
	Gif *gif = gif_alloc(sizeof(Gif));
	if(gif)
	{
		strcpy(gif->header, "GIF87a");
		gif->screen = new_gif_screen();
		gif->blocks = NULL;
	}
	return gif;
}

void del_gif(Gif *gif)
{
	int i;
	del_gif_screen(gif->screen);
	for(i=0; i < gif->block_count; i++)
		del_gif_block(gif->blocks[i]);
	vPortFree2(gif);
}

void write_gif(char **file, Gif *gif)
{
	int i;
	strcpy(*file, gif->header);
	(*file) += strlen(*file);
	write_gif_screen(file, gif->screen);
	for(i=0; i < gif->block_count; i++)
		write_gif_block(file, gif->blocks[i]);
	write_byte(file, 0x3B);
}

#endif /* LWIP */
#endif /* NETWORK */

