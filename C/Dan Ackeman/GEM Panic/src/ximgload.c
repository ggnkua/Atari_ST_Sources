/********************************************
*           XIMGLOAD.C                      *
*                                           *
* Dan Ackerman - baldrick@netset.com 1999   *
*                                           *
* With thanks to Eero Tamien	            *
*                     Warwick Allison	    *
*                     and Mario Becroft	    *
* All of whom over the years gave me helpful*
*advice that I ignored to make this mess ;) *
*                                           *
* No really they were all very helpful      *
*
*  BIG NOTE
* 
* This file is still kind of a mess.  
* everything works, but it is kind of a 
* hodgepodge of routines / 2005
* 
********************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "global.h"

#define lmemcpy memcpy

RGB1000 image_colortab[256]; /* used to temp hold image pallette */

short vditodev8[] = {0,255,1,2,4,6,3,5,7,8,9,10,12,14,11,13,16,17,18,19,20,21,22,23,24,25,26
,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50
,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69
,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88
,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,
110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,
128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,
146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,
164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,
182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,
200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,
218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,
236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,
251,252,253,254,15};
short vditodev4[] = {0,15,1,2,4,6,3,5,7,8,9,10,12,14,11,13};
short vditodev2[] = {0,3,1,2};
short vditodev1[] = {0,1};

short id;
extern int phys_handle;
extern int vdi_handle;
extern int planes;

int junk;
extern int colortab[256][3]; /* used to save colors */
extern MFDB screen;
int no_colors, img_handle;
 

/* ---------------------------------- */

/* img_main()
 * 
 * a stub main() routine if you made this a standalone prg
 * probably wouldn't work anymore
 */
void 
img_main(char *file )
{
	struct IMG_HEADER img;
	int error = 1;

	img.addr = NULL;

	if( (error = depack_img( file, &img )) )
		show_error( error );
	else
		show_img( &img );

	Mfree( img.palette );
	Mfree( img.addr );
}

/* img_load()
 *
 * - loads an image to a buffer dynamically
 * allocating buffers.
 * raster is MFDB to load image to
 * file is image file to load
 * method = 0  - no modifications, image size same as in file
 *        = 1  - keep size from raster, tile image into buffer
 * mask is MFDB to create mask in.  If no mask Set to NULL
 * mask_color = the color you want to be mask
 */
short *
img_load(MFDB *raster, char *file, int method, MFDB *mask, int mask_color)
{
	struct IMG_HEADER img;
	int error = 1;
	short *temp_buffer;
	long mfdb_buffsize;

	img.addr = NULL;

	if( (error = depack_img( file, &img )) != 0)
		show_error( error );
	else
	{
		if (method == 0)
		{
			raster->fd_w = img.img_w;                /* width        */
			raster->fd_wdwidth = (img.img_w + 15) >> 4;    /* (words)      */
			raster->fd_h       = img.img_h;                /* height       */
		}
	
		raster->fd_stand   = 0;                         /* raster format = device */
		raster->fd_nplanes = img.planes;               /* bitplanes    */

		mfdb_buffsize = 2L*(long)raster->fd_wdwidth*(long)screen.fd_nplanes*(long)raster->fd_h;

		temp_buffer=(void *)Mxalloc(mfdb_buffsize, 0);

		if( ((signed long)temp_buffer)==-32L )
			temp_buffer=(void *)Malloc(mfdb_buffsize);
		if( (signed long)temp_buffer<=0L )
			return(temp_buffer);

		raster->fd_addr = temp_buffer;
   		
		if( (signed long)temp_buffer<=0L )
			return(temp_buffer);

		raster->fd_addr = temp_buffer;

		if (mask != (MFDB *)NULL)
			make_mask(&img, mask, mask_color);

		if (!copy_img( &img, raster ))
			printf("Copy Image failure\r\n");
	}

	Mfree( img.palette );
	Mfree( img.addr );

	return(raster->fd_addr);
}

/* show_error()
 * 
 * displays an error message to the screen in an alert
 */
void 
show_error( int error )
{
	char message[64];

	strcpy( message, "[1][" );

	switch( error )
	{
		case ERR_FILE:
			strcat( message, "File error.");
			break;
		case ERR_HEADER:
			strcat( message, "Invalid IMG-header.");
			break;
		case ERR_ALLOC:
			strcat( message, "Not enough memory.");
			break;
		case ERR_DEPACK:
			strcat( message, "Depacking error.");
			break;
	}
	
	strcat( message, " ][  OK  ]" );

	form_alert( 1, message );
}

/* depack_img()
 *
 * Loads & depacks IMG (0 if succeded, else error). 
 * Bitplanes are one after another in address IMG_HEADER.addr. 
 */
int 
depack_img( char *name, struct IMG_HEADER *pic )
{
	int   a, b, line, plane, width, word_aligned, opcode, patt_len, pal_size,
		byte_repeat, patt_repeat, scan_repeat, error = FALSE;
	char  buf[LINEBUF], pattern[16], *address, *to, *endline;
	long  size;
	FILE *fp;

	if( (fp = fopen( name, "rb")) == NULL )
		return( ERR_FILE );

	/* read header info (bw & ximg) into image structure */
	fread( (char *)&(pic->version), 2, 8+3, fp );

	/* if XIMG, read info */
	if( pic->magic == XIMG )
	{
		pal_size = (1 << pic->planes) * 3;

		if( (pic->palette = (int *)Malloc( pal_size * sizeof(pic->palette) )) )
			fread( (char *)pic->palette, 2, pal_size, fp );
	}
	else
		pic->palette = NULL;

	/* width in bytes word aliged */
	word_aligned = (pic->img_w + 15) >> 4;
	word_aligned <<= 1;

	/* width byte aligned */
	width = (pic->img_w + 7) >> 3;


	/* allocate memory for the picture */
	Mfree( pic->addr );
	size = (long) word_aligned * pic->img_h * pic->planes;

	/* check for header validity & malloc long... */

	if (pic->length > 7 && pic->planes < 33 && pic->img_w > 0 && pic->img_h > 0)
		pic->addr = (char *) Malloc( size );
	else
	{
		error = ERR_HEADER;
		goto end_depack;
	}

	/* if allocation succeded, proceed with depacking */
	if( pic->addr == NULL )
	{
		error = ERR_ALLOC;
		goto end_depack;
	}
	else
	{
		patt_len = pic->pat_len;
		endline = buf + width;

		/* jump over the header and possible (XIMG) info */
		fseek( fp, (long) pic->length * 2, SEEK_SET );

		/* depack whole img */
		for( line = 0; line < pic->img_h; line += scan_repeat )
		{
			scan_repeat = 1;
	
			/* depack one scan line */
			for( plane = 0; plane < pic->planes; plane ++)
			{
				to = buf;

				/* depack one line in one bitplane */
				do
				{
					opcode = fgetc( fp );

					switch( opcode )
					{
						/* pattern or scan repeat */
						case 0:
							patt_repeat = fgetc( fp );

							/* repeat a pattern */

							if( patt_repeat )
							{
								/* read pattern */
								for( b = 0; b < patt_len; b ++ )
									pattern[b] = fgetc( fp );

								/* copy pattern */
								for( a = 0; a < patt_repeat; a ++ )
								{
									/* in case it's odd amount... */
									for( b = 0; b < patt_len; b ++ )
										*(to ++) = pattern[b];
								}
							}
							else /* repeat a line */
							{
								if( fgetc( fp ) == 0xFF )
									scan_repeat = fgetc( fp );
								else
								{
									error = ERR_DEPACK;
									goto end_depack;
								}
							}
							break;

						/* repeat 'as is' */
						case 0x80:
							byte_repeat = fgetc( fp );

							for( ; byte_repeat > 0; byte_repeat -- )
								*(to ++) = fgetc( fp );

							break;

						/* repeat black or white */
						default:
							byte_repeat = opcode & 0x7F;

							if( opcode & 0x80 )
								opcode = 0xFF;
							else
								opcode = 0x00;

							for( ; byte_repeat > 0; byte_repeat -- )
								*(to ++) = opcode;
					}
				}  while( to < endline );

				if( to == endline && line + scan_repeat <= pic->img_h )
				{
					/* calculate address of a current line in a current bitplane */
					address = pic->addr  + 
					(long) line  * word_aligned +
					(long) plane * word_aligned * pic->img_h;

					/* copy line to image buffer */
					for( a = 0; a < scan_repeat; a ++ )
					{
						memcpy( address, buf, width );
						address += word_aligned;
					}
				}
				else
				{
					printf("line + sr = %d\r\n",(line+scan_repeat));
					printf("height = %d\r\n",pic->img_h);
					printf("endline = %ld\r\n",endline);
					printf("to = %ld\r\n",to);
        
					printf("second err depack\r\n");

					error = ERR_DEPACK;
					goto end_depack;
				}
			}
		}
	}

	end_depack:
	fclose( fp );
	return( error );
}

/* show_img()
 *
 * at one time this could be used to display an
 * an image on the screen that was larger than
 * the screen and you could pan around
 * it has been years since I even tried to run
 * this routine.
 */
int 
show_img( struct IMG_HEADER *pic)
{
	int screen_planes, screen_w, screen_h, buttons = 0, key,
		i, x1 = 0, y1 = 0, x2 = 0, y2 = 0, mx, my, xx, yy, cen_x, cen_y,
		redraw = TRUE, pxyarray[8],
		wg_x, wg_y, wg_w, wg_h;
	MFDB image, tmpscreen;

	/* Screen and Image VDI Memory Form Definitions. */
	tmpscreen.fd_addr   = 0;
	image.fd_addr    = pic->addr;                 /* address      */
	image.fd_w       = pic->img_w;                /* width        */
	image.fd_wdwidth = (pic->img_w + 15) >> 4;    /* (words)      */
	image.fd_h       = pic->img_h;                /* height       */
	image.fd_stand   = 0;                         /* raster format = device */
	image.fd_nplanes = pic->planes;               /* bitplanes    */

	/*** This could be as well *your* window's work area. ***/
	/* Desktop work area. */
	wind_get ( 0, WF_WORKXYWH, &wg_x, &wg_y, &wg_w, &wg_h );

	/* pic size on screen */
	xx = min( wg_w, pic->img_w );
	yy = min( wg_h, pic->img_h );

	/* for centering pic on screen */
	cen_x = ((wg_w - xx) >> 1) + wg_x;
	cen_y = ((wg_h - yy) >> 1) + wg_y;

	/* open virtual screen workstation (screen) */
	work_in[0] = 1; work_in[10] = 2;

	if (vq_gdos() == 0)
	{
		work_in[0] = 2 + Getrez(); 
	}

	img_handle = graf_handle( &i, &i, &i, &i );

	v_opnvwk( work_in, &img_handle, work_out );
	screen_w = work_out[0];
	screen_h = work_out[1];

	no_colors = work_out[13];
	/*save_colors(no_colors);*/

	/* get the number of bitplanes on screen */

	vq_extnd(img_handle, 1, work_out);
	screen_planes = work_out[4];

	/* convert image to the current screen format if necessary */
	if( !(transform_img( &image, screen_planes, pic->palette, img_handle )) )
	{
		/*reset_colors(no_colors);*/
		v_clsvwk( img_handle );
		return( FALSE );
	}

	/* suspend other screen activity */
	/*wind_update( BEG_UPDATE );
	form_dial( FMD_START, wg_x, wg_y, wg_w, wg_h, wg_x, wg_y, wg_w, wg_h );

	graf_mouse( M_OFF, 0 );
	*/

	do
	{
		/* get mouse position */
		graf_mkstate( &mx, &my, &buttons, &key );

		/* calculate new image place */
		x1 = (long) mx * (image.fd_w - xx) / screen_w;
		y1 = (long) my * (image.fd_h - yy) / screen_h;

		/* fit co-ordinates onto screen */
		x1 = min( x1, pic->img_w - xx );
		y1 = min( y1, pic->img_h - yy );
		x1 = max( 0, x1 );
		y1 = max( 0, y1 );

		/* draw image if necessary */
		if ( redraw || x1 != x2 || y1 != y2 )
		{
			/* put values into the co-ordinate array */
			pxyarray[0] = x1;
			pxyarray[1] = y1;
			pxyarray[2] = x1 + xx - 1;
			pxyarray[3] = y1 + yy - 1;
			pxyarray[4] = cen_x;
			pxyarray[5] = cen_y;
			pxyarray[6] = cen_x + xx - 1;
			pxyarray[7] = cen_y + yy - 1;

			/* throw onto screen */
			vro_cpyfm( img_handle, S_ONLY, pxyarray, &image, &tmpscreen); /* was source*/

			x2 = x1; y2 = y1;
			redraw = FALSE;
		}
		/* exit with right button */
	}
	while(buttons != 1);

	/*graf_mouse( M_ON, 0 );*/

	/* enable other screen activities */
	wind_update( END_UPDATE );

	/* redraw screen (really necessary with MTOS only) */
	form_dial( FMD_FINISH, wg_x, wg_y, wg_w, wg_h, wg_x, wg_y, wg_w, wg_h );

	/* close virtual... */
	/*reset_colors(no_colors);*/
	v_clsvwk( img_handle );

	/* if image was converted to device format, Mfree allcated memory */
	if( image.fd_addr != pic->addr )
		Mfree( image.fd_addr );

	return( TRUE );
}

/* copy_img()
 * 
 * copies img to MFDB 
 * Good for filling a backing store
 */
int 
copy_img( struct IMG_HEADER *pic, MFDB *image_buffer)
{
	int screen_planes, pxyarray[8];
	MFDB image;
	int curx,cury;
	GRECT max;
	GRECT min;

	/* Screen and Image VDI Memory Form Definitions. */
	image.fd_addr    = pic->addr;                 /* address      */
	image.fd_w       = pic->img_w;                /* width        */
	image.fd_wdwidth = (pic->img_w + 15) >> 4;    /* (words)      */
	image.fd_h       = pic->img_h;                /* height       */
	image.fd_stand   = 0;                         /* raster format = device */
	image.fd_nplanes = pic->planes;               /* bitplanes    */

	/* get the number of bitplanes for MFDB */

	screen_planes = screen.fd_nplanes;

	/* convert image to the current screen format if necessary */
	if( !(transform_img( &image, screen_planes, pic->palette, vdi_handle)) )
		return( FALSE );

	image_buffer->fd_nplanes = image.fd_nplanes;

	if (((image_buffer->fd_w - 1) <= image.fd_w)&&
	 ((image_buffer->fd_h - 1) <= image.fd_h))
	{	
		/* loaded image is larger than buffer */
		
		/* put values into the co-ordinate array */
		pxyarray[0] = pxyarray[4] = 0;
		pxyarray[1] = pxyarray[5] = 0;
		pxyarray[2] = pxyarray[6] = image_buffer->fd_w - 1;
		pxyarray[3] = pxyarray[7] = image_buffer->fd_h - 1;

		/* throw info buffer */
		vro_cpyfm( vdi_handle, S_ONLY, pxyarray, &image, image_buffer);
	}
	else
	{
		/* loaded image is smaller than buffer */
	
		max.g_x = max(image_buffer->fd_w,image.fd_w);
		max.g_y = max(image_buffer->fd_h,image.fd_h);
	
		if (max.g_x > image_buffer->fd_w)
			max.g_x = image_buffer->fd_w;
		
		if (max.g_y > image_buffer->fd_h)
			max.g_y = image_buffer->fd_h;

		min.g_x = min(max.g_x,image.fd_w);
		min.g_y = min(max.g_y,image.fd_h);
	
		curx = 0; /* initialize our x and y counters */
		cury = 0;
			
		for (curx = 0; curx <= image_buffer->fd_w;curx += image.fd_w)
		{
			if ((curx + image.fd_w)>image_buffer->fd_w)
				min.g_x = image_buffer->fd_w - curx;
			else
				min.g_x = min(max.g_x,image.fd_w);

			if (min.g_x < 0) min.g_x = 0;

			for(cury = 0; cury <= image_buffer->fd_h;cury += image.fd_h)
			{
				if ((cury + image.fd_h)>image_buffer->fd_h)
					min.g_y = image_buffer->fd_h - cury;
				else
					min.g_y = min(max.g_y,image.fd_h);

				if (min.g_y < 0) min.g_y = 0;
				
				/* put values into the co-ordinate array */									
				pxyarray[0] = 0;
				pxyarray[1] = 0;
				pxyarray[2] = min.g_x - 1;
				pxyarray[3] = min.g_y - 1;
				pxyarray[4] = curx;
				pxyarray[5] = cury;
				pxyarray[6] = curx + min.g_x - 1;
				pxyarray[7] = cury + min.g_y - 1;

				/* throw onto screen  as long as it's a real block*/
				if (min.g_x != 0 && min.g_y != 0)
					vro_cpyfm( vdi_handle, S_ONLY, pxyarray, &image, image_buffer); 
			}
		}
	}

	/* if image was converted to device format, Mfree allcated memory */
	if( image.fd_addr != pic->addr )
		Mfree( image.fd_addr );

	return( TRUE );
}

/* transform_img()
 *
 * converts a standard MFDB into a device MFDB for this
 * screen depth
 *
 * return FALSE if transformation was unsuccesful
 */
int 
transform_img( MFDB *image, int planes, int *palette, int img_handle)
{
	int factor;
	long size;

	size = (long)(image->fd_wdwidth * image->fd_h);

	if( planes == 1 )
	{
  		if( image->fd_nplanes > 1 )
		{
			if( dither((short **)&(image->fd_addr), size, image->fd_wdwidth, image->fd_nplanes, palette ) == FALSE )
			{
				show_error( ERR_ALLOC );
				return( FALSE );
			}

			image->fd_nplanes = 1;
		}

		return( TRUE );
	}
	else
	{
		if( image->fd_nplanes != 1 )
		{
			if (image->fd_nplanes>planes)
			{
				if( dither((short **)&(image->fd_addr), size, image->fd_wdwidth, image->fd_nplanes, palette ) == FALSE )
				{
					show_error( ERR_ALLOC );
					return( FALSE );
				}
				
				image->fd_nplanes = 1; /* I really want this to be planes;*/
			}
			else
			{
				if (planes > 8)
					truecolorimg_colors(image->fd_nplanes, palette, img_handle);
				else
					img_colors(image->fd_nplanes, palette, img_handle);

				;
			}
		}

		/* interleaved? */

		#if 0
		switch( rez )
		{
			case 0:
				/* low rez */
				factor = 4;
				break;
			case 1:
				/* med rez */
				factor = 2;
				break;
			default:
				factor = 0;
		}
		#endif

		factor = 0;

		if( factor )
		{
			/* Interleave bitplane information. */
			if( interleave( factor, (short **)&(image->fd_addr), size, image->fd_nplanes ) )
			{
				image->fd_nplanes = factor;
				return( TRUE );
			}
			else
				show_error( ERR_ALLOC );
		}
		else
		{
			if (planes > 8)
			{
				/* Non planar mode  don't use vr_trfm */

				if(transform_truecolor( image, size, planes, img_handle) )
					return(TRUE);
				else
					show_error(ERR_ALLOC);
			}
			else
			{
				#if 0
					/* Use vr_trfm(), which needs a bit more memory. */
					if( convert( image, size, planes, img_handle ) )	
				#endif

				if(transform_remap( image, size, planes, img_handle) )
					return( TRUE );
				else
					show_error( ERR_ALLOC );
			}
		}
	}
	
	return( FALSE );
}

/* dither()
 *
 * dither bitplanes into an bw one 
 */
int 
dither( short **addr, long size, int width, int planes, int *palette )
{
	int i, bit, result, color, pal_size, *mat,
		count = 0, row = 0, modulo = 0;
	short col_max = 0, col_min = 0, intensity[256],
		first_plane[32], *plane, *idx, *end, *new_addr, *new;

	/* ordered dithering matrix */
	static int matrix[16][16] =
	{{0x00, 0xc0, 0x30, 0xf0, 0x0c, 0xcc, 0x3c, 0xfc,
	 0x03, 0xc3, 0x33, 0xf3, 0x0f, 0xcf, 0x3f, 0xff},
	{0x80, 0x40, 0xb0, 0x70, 0x8c, 0x4c, 0xbc, 0x7c,
	 0x83, 0x43, 0xb3, 0x73, 0x8f, 0x4f, 0xbf, 0x7f},
	{0x20, 0xe0, 0x10, 0xd0, 0x2c, 0xec, 0x1c, 0xdc,
	 0x23, 0xe3, 0x13, 0xd3, 0x2f, 0xef, 0x1f, 0xdf},
	{0xa0, 0x60, 0x90, 0x50, 0xac, 0x6c, 0x9c, 0x5c,
	 0xa3, 0x63, 0x93, 0x53, 0xaf, 0x6f, 0x9f, 0x5f},
	{0x08, 0xc8, 0x38, 0xf8, 0x04, 0xc4, 0x34, 0xf4,
	 0x0b, 0xcb, 0x3b, 0xfb, 0x07, 0xc7, 0x37, 0xf7},
	{0x88, 0x48, 0xb8, 0x78, 0x84, 0x44, 0xb4, 0x74,
	 0x8b, 0x4b, 0xbb, 0x7b, 0x87, 0x47, 0xb7, 0x77},
	{0x28, 0xe8, 0x18, 0xd8, 0x24, 0xe4, 0x14, 0xd4,
	 0x2b, 0xeb, 0x1b, 0xdb, 0x27, 0xe7, 0x17, 0xd7},
	{0xa8, 0x68, 0x98, 0x58, 0xa4, 0x64, 0x94, 0x54,
	 0xab, 0x6b, 0x9b, 0x5b, 0xa7, 0x67, 0x97, 0x57},
	{0x02, 0xc2, 0x32, 0xf2, 0x0e, 0xce, 0x3e, 0xfe,
	 0x01, 0xc1, 0x31, 0xf1, 0x0d, 0xcd, 0x3d, 0xfd},
	{0x82, 0x42, 0xb2, 0x72, 0x8e, 0x4e, 0xbe, 0x7e,
	 0x81, 0x41, 0xb1, 0x71, 0x8d, 0x4d, 0xbd, 0x7d},
	{0x22, 0xe2, 0x12, 0xd2, 0x2e, 0xee, 0x1e, 0xde,
	 0x21, 0xe1, 0x11, 0xd1, 0x2d, 0xed, 0x1d, 0xdd},
	{0xa2, 0x62, 0x92, 0x52, 0xae, 0x6e, 0x9e, 0x5e,
	 0xa1, 0x61, 0x91, 0x51, 0xad, 0x6d, 0x9d, 0x5d},
	{0x0a, 0xca, 0x3a, 0xfa, 0x06, 0xc6, 0x36, 0xf6,
	 0x09, 0xc9, 0x39, 0xf9, 0x05, 0xc5, 0x35, 0xf5},
	{0x8a, 0x4a, 0xba, 0x7a, 0x86, 0x46, 0xb6, 0x76,
	 0x89, 0x49, 0xb9, 0x79, 0x85, 0x45, 0xb5, 0x75},
	{0x2a, 0xea, 0x1a, 0xda, 0x26, 0xe6, 0x16, 0xd6,
	 0x29, 0xe9, 0x19, 0xd9, 0x25, 0xe5, 0x15, 0xd5},
	{0xaa, 0x6a, 0x9a, 0x5a, 0xa6, 0x66, 0x96, 0x56,
	 0xa9, 0x69, 0x99, 0x59, 0xa5, 0x65, 0x95, 0x55}};

	/* allocate space for the new (dithered) bitmap */
	if( (new_addr = (short *) Malloc( size * sizeof(**addr) )) == NULL )
		return( FALSE );

	pal_size = (1 << planes);

	/* scan palette */
	if( pal_size <= 256 )
	{
		for( i = 0; i < pal_size; i ++ )
		{
			intensity[i] = 0;

			/* add register values together to get the grey level */
			for( bit = 0; bit < 3; bit ++ )
				intensity[i] += *(palette + 3 * i + bit);

			col_min = min( col_min, intensity[i] );
			col_max = max( col_max, intensity[i] );
		}

		/* scale color values to 0 - 255 range */
		for( i = 0; i < pal_size; i ++ )
			intensity[i] = (long)(intensity[i] - col_min) * 255 / (col_max - col_min);
	}

	/* destination pointer */
	new = new_addr;

	/* NOTICE: *addr + size = *addr + sizeof(**addr) * size!!! */
	end = *addr + size;

	/* remake first bitplane */
	for( idx = *addr; idx < end; idx ++ )
	{
		/* go through all bitplanes */
		plane = first_plane;

		/* get one word from a bitplane */
		for( i = 0; i < planes; i ++ )
			*(plane ++) = *(idx + size * (long)i);

		/* get row's modulo into dither matrix */
		if( ++ count == width )
		{
			count = 0;
			row ++;
			modulo = row % 16;
		}

		result = 0;
		mat = matrix[modulo];

		/* go through one word */
		for( bit = 15; bit >= 0; bit -- )
		{
			color = 0;
			plane = first_plane;

			/* OR all 'bit' bits from all bitplanes together */
			for( i = 0; i < planes; i ++ )
				color |= ((*(plane ++) >> bit) & 1) << i;

			/* set bit in resulting bitplane if it its' intensity demands it */
			if( intensity[color] < *(mat ++) )
				result |= (short) 1 << bit;
		}

		*(new ++) = result;
	}

	*addr = new_addr;
	return( TRUE );
}

/* interleave()
 *
 * convert bitplanes into interleaved bitplane 
 */
int 
interleave( int interleave, short **addr, long size, int planes )
{
	short *new_addr, *new, *idx, *start, *end;
	int plane, limit;

	if( (new_addr = (short *) Malloc( size * interleave * sizeof(*start) )) == NULL )
		return( FALSE );
	else	/* if enough memory */
	{
		/* NOTICE: start + size = start + sizeof(*start) * size!!! */
		start = *addr - size;
		end = *addr;
		limit = min( interleave, planes );

		/* interleave bitmaps (max. 'interleave' bitmaps) */
		for( plane = 0; plane < limit; plane ++ )
		{
			/* interleaved bitmap start address */
			new = new_addr + plane;

			/* current bitmap address */
			start += size;
			end   += size;

			/* copy one bitplane interleaved */
			for( idx = start; idx < end; idx ++ )
			{
      			*new = *idx;
        		new += interleave;
			}
		}

		/* if not enough bitmaps, interleave rest with previous bitmap */
		for( plane = limit; plane < interleave; plane ++ )
		{
			new = new_addr + plane;

			for( idx = start; idx < end; idx ++ )
			{
				*new = *idx;
				new += interleave;
			}
		}

		/* new address for the image (this one in device format) */
		*addr = new_addr;
	}

	return( TRUE );
}

/* convert()
 *
 * convert image using vr_trfm() 
 */
 
int 
convert( MFDB *image, long size, int planes, int img_handle )
{
	char *new_addr, *tmp;
	int plane;
	MFDB tempscreen;

	/* convert size from words to bytes */
	size <<= 1;

	/* memory for the device raster */
	if( (new_addr = (char *) Malloc( size * planes )) == NULL )
		return( FALSE );

	memset(new_addr,0,(size * planes));	/*	-> fill with 0-planes */

	/* do we need a temporary conversion source raster? */
	if( image->fd_nplanes < planes )
	{
		/* memory for the standard (bitplane) raster */
		if( (tmp = (char *) Malloc( size * planes )) == NULL )
			return( FALSE );

		memset(tmp,0,(size * planes));

		/* copy available bitplanes to the tmp */
		memcpy( tmp, image->fd_addr, size * (long)image->fd_nplanes );

		/* fill the rest with the first bitplane */
		for( plane = image->fd_nplanes; plane < planes; plane ++ )
			memcpy( tmp + size * (long)plane, image->fd_addr, size );
			 
		/* Mfree old image->fd_addr */
		Mfree(image->fd_addr);
	}
	else
		tmp = image->fd_addr;

	/* fill in the descriptions   */
	image->fd_nplanes = planes;
	tempscreen = *image;		/* copy MFDB */
	image->fd_stand = 1;	/* standard format */
	image->fd_addr = tmp;
	tempscreen.fd_addr = new_addr;

	/* convert image to current device raster format */
	vr_trnfm( img_handle, image, &tempscreen); 

	/* Mfree temporary space */
	if( tmp != image->fd_addr )
		Mfree( tmp );

	/* change image description */
	image->fd_stand = 0;		/* device format */
	image->fd_addr = new_addr;

	return( TRUE );
}

/*
 *  You may ask why there is a routine for truecolor palettes
 * and one for planar palettes...
 *
 *  Well one works for planar modes and the other for truecolor
 * but neither seem to work well for both.
 *
 * As I've already spent about a month longer on this than I wanted,
 * I decided to just do it the way that works.
 *
 *  Sorry for the terrible programming - Dan Ackerman 1999
 */


/* img_colors()
 *
 * Set the system colors to be the palette 
 */
int 
img_colors( int planes, int *palette , int col_handle)
{
	int i, pal_size,idx;

	vsm_type(col_handle, 1);
	pal_size = (1 << planes);

	/* scan palette */
	if( pal_size <= 256 )
	{
		/* Really shouldn't set the lower 16,
		but I do.  Sorry 
		 	
		Mario Becroft has some great routines
		that he will be releasing the source to.
		When that happens, most of the code in this
		C file should be replaced with his code.
		Faster and nicer. - Dan */

		for( i = 0; i < pal_size ; i ++ )
		{
			idx = i;
			
			image_colortab[idx].red = *(palette + 3 * i + 0);
			image_colortab[idx].green = *(palette + 3 * i + 1);
			image_colortab[idx].blue = *(palette + 3 * i + 2);
		}
	}

	return( TRUE );
}


/* truecolorimg_colors()
 *
 * Set the system colors to be the palette for Truecolor modes 
 */
 
int 
truecolorimg_colors( int planes, int *palette , int col_handle)
{
	int i, pal_size, idx;
	int rgb_in[3];
	int rgb_idx[256][3];

	pal_size = (1 << planes);

	/* scan palette */
	if( pal_size <= 256 )
	{
		for( i = 0; i < pal_size ; i ++ )
		{
			switch(planes)
			{
				case 2:
					idx = vditodev2[i];
					break;
				case 4:
					idx = vditodev4[i];
					break;
				case 8:
					idx = vditodev8[i];
					break;
				default:
					idx = i;
			}
 
			rgb_idx[idx][0] = *(palette + 3 * i + 0);
			rgb_idx[idx][1] = *(palette + 3 * i + 1);
			rgb_idx[idx][2] = *(palette + 3 * i + 2);
	
			rgb_in[0] = rgb_idx[idx][0];
			rgb_in[1] = rgb_idx[idx][1];
			rgb_in[2] = rgb_idx[idx][2];
		
			vs_color(col_handle,i,rgb_in);
		}
	}

	return( TRUE );
}

/* mono_transform()
 *
 *  This allows us to take a mono image up to a higher bit depth
 * and color it with a specified color.  So that mono images need
 * not remain mono.
 *
 * color flag is what color you want the foreground to be set to
 * keep_original - if true it does not free the original buffer
 */

int
mono_transform( MFDB *image, long size, int planes, int img_handle, int color, int keep_original)
{
	short *new_addr;
	MFDB tempscreen;
	MFDB temp;
	int pxy[8];
	int colors[2];

	/* convert size from words to bytes */
	size <<= 1;

	/* memory for the device raster */
	if( (new_addr = (char *) malloc( size * planes )) == NULL )
		return( FALSE );

	if (planes > 8)
		memset(new_addr,255,(size * planes));	/*	-> fill with 255-planes */
	else
		memset(new_addr,0,(size * planes));	/*	-> fill with 0-planes */

	/* fill in the descriptions */
	image->fd_nplanes = planes;
	tempscreen = *image;		/* copy MFDB */
	image->fd_stand = 0;	/* standard format */
	tempscreen.fd_addr = new_addr;

	temp = *image;
	temp.fd_stand = 0;
	temp.fd_nplanes = 1;
	pxy[0] = pxy[4] = 0;
	pxy[1] = pxy[5] = 0;
	pxy[2] = pxy[6] = image->fd_w - 1;
	pxy[3] = pxy[7] = image->fd_h - 1;

	/* If you don't do the following monochrome images are inverted */
	colors[0] = color;
	colors[1] = 1;
	
	vrt_cpyfm( img_handle,MD_TRANS,pxy,&temp,&tempscreen,colors);

	if (!keep_original)
		free(image->fd_addr);

	/* change image description */
	image->fd_stand = 0;		/* device format */
	image->fd_addr = new_addr;

	return( TRUE );
}

/* fix_image()
 *
 * takes a monochrome image and converts it to the current
 * color depth applying a color to it at the same time.
 * fix_image only works for mono_chrome image files 
 * color is the color you want the object to be on the screen
 */

int 
fix_image(MFDB *image, int color)
{
	long size;
	
	size = (long)(image->fd_wdwidth * image->fd_h);

	mono_transform( image, size, planes, vdi_handle, color, 1);

	return(TRUE);
}

/* transform_truecolor()
 *
 *  The new transform truecolor
 *
 *  This routine borrows heavily on two sources.
 *  1. Mario Becrofts transform function
 *  2. Eero Tammiens dither function
 *
 *  Marios routine never worked for me properly under PureC,
 * it's very possible that was my fault.  However on reflection
 * I saw that what he was doing was very similar to the dither
 * routine I was already using.  So I used Mario Becrofts strategy
 * combined with Eero Tammiens tactics and came up with the following
 * routine.
 * 
 *  I can see the possibility of a few minor tweaks that may make
 * this routine faster.  For the moment I'm happy with it.  Its significantly
 * faster than the old one I wrote (which still exists in the code for
 * anyone interested in porting this program to a non motorola platform)
 * 
 *  variables
 * MFDB *image -> MFDB of the image we want to convert to the current bit depth
 * size		   -> size of buffer of the image. (could probably reconstruct, but
 *												we already have this value beforehand)
 * planes	   -> Number of planes = current bit depth
 * img_handle  -> Our VDI_handle for vdi functions	
 *
 * Dan Ackerman ( March 7, 2000)
 */

int 
transform_truecolor( MFDB *image, long size, int planes, int img_handle)
{
	int i, bit, color, mask;
	short first_plane[32], *plane, *idx, *new_addr;
	short *color_table, *bit_location, *temp_addr;
	int tot_colors = (1 << image->fd_nplanes);
	char used_colors[256];
	int x, y;
	MFDB tempscreen;
	MFDB temp;
	int pxy[8], colors[2];
	long temp_size;

	if (image->fd_nplanes == 1)
		return(mono_transform(image, size, planes, img_handle, 1, 0));

	/* memory for the device raster */
	if( (new_addr = (short *) malloc( (size << 1) * planes )) == NULL )
		return( FALSE );

	memset(new_addr,0,((size << 1) * planes));	/*	-> fill with 0-planes */

	/* fill in the descriptions	 */
	image->fd_nplanes = planes;
	tempscreen = *image;		/* copy MFDB */
	image->fd_stand = 1;	/* standard format */
	tempscreen.fd_addr = new_addr;

	temp = *image;
	temp.fd_stand = 0;
	temp.fd_nplanes = 1;
	temp.fd_h = tot_colors;

	temp_size = tot_colors * temp.fd_wdwidth;
	temp_size <<= 1;

	if( (temp_addr = (short *) malloc(temp_size)) == NULL )
		return( FALSE );

	memset(temp_addr,255,(temp_size));	/*	-> fill with 0-planes */

	temp.fd_addr = temp_addr;

	pxy[0] = pxy[4] = 0;
	pxy[1] = pxy[5] = 0;
	pxy[2] = pxy[6] = image->fd_w-1;
	pxy[3] = pxy[7] = image->fd_h-1;

	/* If you don't do the following monochrome images are inverted */
	colors[1] = 0;

	mask = tot_colors - 1;

	idx = (short *)image->fd_addr;

	bit_location = color_table = (short *)temp_addr;

	for (y = 0; y < image->fd_h; y++)
	{
		memset(temp_addr,0,temp_size);
		memset( used_colors, 0, sizeof( used_colors ) );
	
		for (x = 0; x < image->fd_wdwidth; x++)
		{
			/* go through all bitplanes */
			plane = first_plane;

			/* get one word from a bitplane */
			for( i = 0; i < image->fd_nplanes; i ++ )
				*(plane ++) = *(idx + size * (long)i);

			/* go through one word */
			for( bit = 15; bit >= 0; bit -- )
			{
				color = 0;
				plane = first_plane;

				/* OR all 'bit' bits from all bitplanes together */
				for( i = 0; i < image->fd_nplanes; i ++ )
					color |= ((*(plane ++) >> bit) & 1) << i;

				color &= mask;

				used_colors[color] = 1;

				bit_location =  (short *)(color_table + (temp.fd_wdwidth * (long)color) + x);
	
				*bit_location |= 1 << bit;
			}

			idx++; /* increment idx */
		}

		/* if we've gone to the end of a row update now */

		pxy[5] = pxy[7] = y;

		for (i=0;i<tot_colors;i++)
		{
			if(used_colors[i])
			{
				colors[0] = i;
				pxy[1] = pxy[3] = i;
				vrt_cpyfm( img_handle, MD_TRANS, pxy, &temp, &tempscreen, colors );
			}
		}
	}

	free(temp_addr);
	free(image->fd_addr);
	image->fd_stand = 0;	/* standard format */

	image->fd_addr = new_addr;
	return( TRUE );
}

/* test_color()
 *
 * Tests a color, default set for large screens 
 */
 
int 
test_color( int color, int img_handle )
{
	int pxy[4];

	pxy[0] = 0;
	pxy[1] = 0+(10*color);
	pxy[2] = 10;
	pxy[3] = 10+(10*color);

	vsm_type(img_handle, 1);

	vsf_interior(img_handle,1);
	vsf_color(img_handle, color);
	v_bar(img_handle, pxy);
	
	return( TRUE );
}

/* transform_remap()
 *
 * The transform with remapping
 *
 *  This is a rework of transform_truecolor to handle
 * remapping to the system pallete on planar modes
 * 
 *  variables
 * MFDB *image -> MFDB of the image we want to convert to the current bit depth
 * size		   -> size of buffer of the image. (could probably reconstruct, but
 *												we already have this value beforehand)
 * planes	   -> Number of planes = current bit depth
 * img_handle  -> Our VDI_handle for vdi functions	
 *
 * Dan Ackerman ( March 7, 2000)
 */

int 
transform_remap( MFDB *image, long size, int planes, int img_handle)
{
	int i, ii, bit, color, mask;
	short first_plane[32], *plane, *idx, *new_addr;
	short *color_table, *bit_location, *temp_addr;
	int tot_colors = (1 << image->fd_nplanes);
	char used_colors[256];
	int remap_colors[256];
	int x, y;
	MFDB tempscreen;
	MFDB temp;
	int pxy[8], colors[2];
	long temp_size;
	int hit_color = 0;
	RGB1000 best; /* used to temp hold the difference best color match */
	int bestno; /* color index for best match */
	int res_colors = (1 << planes); /* Doesn't work in truecolor modes, only planar */

	if (image->fd_nplanes == 1)
		return(mono_transform(image, size, planes, img_handle, 1, 0));

	/* memory for the device raster */
	if( (new_addr = (short *) malloc( (size << 1) * planes )) == NULL )
		return( FALSE );

	memset(new_addr,0,((size << 1) * planes));	/*	-> fill with 0-planes */

	/* fill in the descriptions */
	image->fd_nplanes = planes;
	tempscreen = *image;		/* copy MFDB */
	image->fd_stand = 1;	/* standard format */
	tempscreen.fd_addr = new_addr;

	temp = *image;
	temp.fd_stand = 0;
	temp.fd_nplanes = 1;
	temp.fd_h = tot_colors;

	temp_size = tot_colors * temp.fd_wdwidth;
	temp_size <<= 1;
	
	if( (temp_addr = (short *) malloc(temp_size)) == NULL )
		return( FALSE );

	memset(temp_addr,255,(temp_size));	/*	-> fill with 0-planes */
	
	temp.fd_addr = temp_addr;
	
	/* remap the color pallete of image */
	
	for (i = 0; i < tot_colors; i++)
	{
		ii = 0;
		hit_color = 0;
		
		do
		{
			if ((image_colortab[i].red == screen_colortab[ii].red)&&
			(image_colortab[i].green == screen_colortab[ii].green)&&
			(image_colortab[i].blue == screen_colortab[ii].blue))
			{
				remap_colors[i] = ii;
				hit_color = 1;
				break;
			}		
			ii++;
		}while(ii < res_colors);
	
		/* We didn't get an exact match, so approximate */
		if(hit_color == 0)
		{
			/* set best color match to 0*/
			bestno = 0;

			/* set initial differences to 1000, ensures that initial value is worst possible */
			best.red = 1000;
			best.green = 1000;
			best.blue = 1000;

			ii = 0;

			do
			{
				if (image_colortab[i].red > screen_colortab[ii].red)
				{
					if((image_colortab[i].red - screen_colortab[ii].red) <= best.red)
					{
						if (image_colortab[i].green > screen_colortab[ii].green)
						{
							if((image_colortab[i].green - screen_colortab[ii].green) <= best.green)
							{
								if (image_colortab[i].blue > screen_colortab[ii].blue)
								{
									if((image_colortab[i].blue - screen_colortab[ii].blue) <= best.blue)
									{
										bestno = ii;
										best.red = (image_colortab[i].red - screen_colortab[ii].red);
										best.green = (image_colortab[i].green - screen_colortab[ii].green);
										best.blue = (image_colortab[i].blue - screen_colortab[ii].blue);
									}
								}
								else
								{
									if((screen_colortab[ii].blue - image_colortab[i].blue) <= best.blue)
									{
										bestno = ii;
										best.red = (image_colortab[i].red - screen_colortab[ii].red);
										best.green = (image_colortab[i].green - screen_colortab[ii].green);
										best.blue = (screen_colortab[ii].blue - image_colortab[i].blue);
									}							
								}
							}
						}
						else
						{
							if((screen_colortab[ii].green - image_colortab[i].green) <= best.green)
							{
								if (image_colortab[i].blue > screen_colortab[ii].blue)
								{
									if((image_colortab[i].blue - screen_colortab[ii].blue) <= best.blue)
									{
										bestno = ii;
										best.red = (image_colortab[i].red - screen_colortab[ii].red);
										best.green = (screen_colortab[ii].green - image_colortab[i].green);
										best.blue = (image_colortab[i].blue - screen_colortab[ii].blue);
									}
								}
								else
								{
									if((screen_colortab[ii].blue - image_colortab[i].blue) <= best.blue)
									{
										bestno = ii;
										best.red = (image_colortab[i].red - screen_colortab[ii].red);
										best.green = (screen_colortab[ii].green - image_colortab[i].green);
										best.blue = (screen_colortab[ii].blue - image_colortab[i].blue);
									}							
								}
							}
						}
					}	
				}
				else
				{
					if((screen_colortab[ii].red - image_colortab[i].red) <= best.red)
					{
						if (image_colortab[i].green > screen_colortab[ii].green)
						{
							if((image_colortab[i].green - screen_colortab[ii].green) <= best.green)
							{
								if (image_colortab[i].blue > screen_colortab[ii].blue)
								{
									if((image_colortab[i].blue - screen_colortab[ii].blue) <= best.blue)
									{
										bestno = ii;
										best.red = (screen_colortab[ii].red - image_colortab[i].red);
										best.green = (image_colortab[i].green - screen_colortab[ii].green);
										best.blue = (image_colortab[i].blue - screen_colortab[ii].blue);
									}
								}
								else
								{
									if((screen_colortab[ii].blue - image_colortab[i].blue) <= best.blue)
									{
										bestno = ii;
										best.red = (screen_colortab[ii].red - image_colortab[i].red);
										best.green = (image_colortab[i].green - screen_colortab[ii].green);
										best.blue = (screen_colortab[ii].blue - image_colortab[i].blue);
									}							
								}
							}
						}
						else
						{
							if((screen_colortab[ii].green - image_colortab[i].green) <= best.green)
							{
								if (image_colortab[i].blue > screen_colortab[ii].blue)
								{
									if((image_colortab[i].blue - screen_colortab[ii].blue) <= best.blue)
									{
										bestno = ii;
										best.red = (screen_colortab[ii].red - image_colortab[i].red);
										best.green = (screen_colortab[ii].green - image_colortab[i].green);
										best.blue = (image_colortab[i].blue - screen_colortab[ii].blue);
									}
								}
								else
								{
									if((screen_colortab[ii].blue - image_colortab[i].blue) <= best.blue)
									{
										bestno = ii;
										best.red = (screen_colortab[ii].red - image_colortab[i].red);
										best.green = (screen_colortab[ii].green - image_colortab[i].green);
										best.blue = (screen_colortab[ii].blue - image_colortab[i].blue);
									}							
								}
							}
						}
					}
				}
	
				ii++;
			}while(ii < res_colors);		
	
			remap_colors[i] = bestno;
		}
	}

	/* setup copy array */
	pxy[0] = pxy[4] = 0;
	pxy[1] = pxy[5] = 0;
	pxy[2] = pxy[6] = image->fd_w-1;
	pxy[3] = pxy[7] = image->fd_h-1;

	/* If you don't do the following monochrome images are inverted */
	colors[1] = 0;

	mask = tot_colors - 1;

	idx = (short *)image->fd_addr;
	
	bit_location = color_table = (short *)temp_addr;
	
	for (y = 0; y < image->fd_h; y++)
	{
		memset(temp_addr,0,temp_size);
		memset( used_colors, 0, sizeof( used_colors ) );
	
		for (x = 0; x < image->fd_wdwidth; x++)
		{
			/* go through all bitplanes */
			plane = first_plane;

			/* get one word from a bitplane */
			for( i = 0; i < image->fd_nplanes; i ++ )
				*(plane ++) = *(idx + size * (long)i);

			/* go through one word */
			for( bit = 15; bit >= 0; bit -- )
			{
				color = 0;
				plane = first_plane;

				/* OR all 'bit' bits from all bitplanes together */
				for( i = 0; i < image->fd_nplanes; i ++ )
					color |= ((*(plane ++) >> bit) & 1) << i;

				color &= mask;

				used_colors[color] = 1;

				bit_location =  (short *)(color_table + (temp.fd_wdwidth * (long)color) + x);
	
				*bit_location |= 1 << bit;
			}

			idx++; /* increment idx */
		}

		/* if we've gone to the end of a row update now */

		pxy[5] = pxy[7] = y;

		for (i=0;i<tot_colors;i++)
		{
			if(used_colors[i])
			{
				colors[0] = remap_colors[i];
				pxy[1] = pxy[3] = i;
				vrt_cpyfm( img_handle, MD_TRANS, pxy, &temp, &tempscreen, colors );
			}
		}
	}

	free(temp_addr);
	free(image->fd_addr);
	image->fd_stand = 0;	/* standard format */

	image->fd_addr = new_addr;
	return( TRUE );
}

/* make_make()
 * 
 * Takes a multiplane source and turns it into
 * a mono dest suitable for use as a mask
 *
 * This could be better.  I think something is wrong
 */

int 
make_mask(struct IMG_HEADER *src, MFDB *dest, int mask_color)
{
	int i,j;
	short *idx, *new_addr;
	long size;
	short *new, *end;
 
	dest->fd_w = src->img_w;              		/* width        */
	dest->fd_wdwidth = (src->img_w + 15) >> 4;	/* (words)      */
	dest->fd_h       = src->img_h;		        /* height       */
	dest->fd_stand   = 0;                 /* raster format = device */  
	dest->fd_nplanes = 1;                 /* bitplanes    */

	size = (long)(dest->fd_wdwidth * dest->fd_h);
	size <<= 1;

#if 0
	new_addr=(long *)malloc(2L * size);

	/* Profiler wants the next two lines to have shorts instead of longs */

	if( (long)new_addr <= 0 )
		return(-1);
#endif

	new_addr=(long *)Mxalloc((2L * size), 0);
	if( ((signed long)new_addr)==-32L )
		new_addr = (long *)Malloc((2L * size));
	if( (signed long)new_addr <= 0L )
		return(-1);
		 
	dest->fd_addr = new_addr;

	memset(dest->fd_addr,0,size);
	
	/* destination pointer */
	new = (short *)new_addr;

	idx = (short *)src->addr;

	end = idx + size;
  
	/* remake first bitplane */
	for(i = 0; i < src->planes; i++)
	{
		new = (short *)new_addr;

		for( j = 0; j < (src->img_h*dest->fd_wdwidth); j ++ )
			*new++ |= *idx++;
	}

	return( TRUE );
}

/* mfdb_make_mask()
 *
 * Takes an MFDB and creates a mask for it 
 *
 * This could be better.  I think something is wrong
 *
 * NOT WORKING
 */

int 
mfdb_make_mask(MFDB *src, MFDB *dest, int mask_color)
{
	int i,j;
	short *idx, *new_addr;
	long size;
	short *new, *end;
 
 	dest->fd_w = src->fd_w;              		/* width        */
	dest->fd_wdwidth = src->fd_wdwidth;	/* (words)      */
	dest->fd_h       = src->fd_h;		        /* height       */
	dest->fd_stand   = 0;                 /* raster format = device */
	dest->fd_nplanes = 1;                 /* bitplanes    */

	size = (long)(dest->fd_wdwidth * dest->fd_h);
	size <<= 1;

#if 0
/*	new_addr=(long *)malloc((2L * size), 0);*/
	new_addr=(long *)malloc(2L * size);
	if( ((signed long)new_addr)==-32L )
		new_addr = (long *)malloc((2L * size));
 	if( (signed long)new_addr <= 0L )
		return(-1);
#endif

	new_addr=(long *)Mxalloc((2L * size), 0);
	if( ((signed long)new_addr)==-32L )
		new_addr = (long *)Malloc((2L * size));
	if( (signed long)new_addr <= 0L )
		return(-1);
		 
	dest->fd_addr = new_addr;

	/* this should be 0, I'm just making a big fat block */
	memset(dest->fd_addr,1,size);

#if 0	
	/* destination pointer */
	new = (short *)new_addr;

	idx = (short *)src->addr;

	end = idx + size;
	
	/* remake first bitplane */
	for(i = 0; i < src->planes; i++)
	{
		new = (short *)new_addr;

		for( j = 0; j < (src->img_h*dest->fd_wdwidth); j ++ )
			*new++ |= *idx++;
	}
#endif 

	return( TRUE );
}

