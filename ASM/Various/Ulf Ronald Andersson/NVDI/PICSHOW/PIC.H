/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>

#include	"ESM.H"															/* Strukturdefinitionen fÅr ESM-Bilder */
#include	"IMG.H"															/* Strukturdefinitionen fÅr (X)IMG-Bilder */

#ifndef	__PIC_STRUCT__
#define	__PIC_STRUCT__

typedef struct
{
	void	*addr;															/* Bufferadresse */
	int32	line_width;														/* Breite einer Bufferzeile in Bytes */
	int32	width;															/* Breite einer Bufferzeile in Pixeln (Vielfaches von 16) */
	int32	height;															/* Hîhe des Buffers in Zeilen */
	int16	planes;
	int32	len;																/* LÑnge des Buffers in Bytes */

	int16	y1;
	int16	y2;

} PIC_BUFFER;

typedef struct _picture
{
	int16	file_handle;
	
	int16	width;															/* Breite des Bilds in Pixeln */
	int16	height;															/* Hîhe des Bilds in Zeilen */
	int16	planes;															/* Tiefe des Bilds */

	int32	max_buffer_size;
	int32	min_reserve_size;
	PIC_BUFFER	buffer;
	
	COLOR_TAB256	ctab;													/* Farbtabelle */

	int16	(*img_open)( int8 *name, struct _picture *pic, int16 vdi_handle );
	int16	(*img_close)( struct _picture *pic);
	int16	(*img_read_slice)( struct _picture *pic, PIC_BUFFER *buf, int16 y1, int16 y2 );

	union
	{
		ESM_HEAD	*esm;
		IMGHDR	*img;
	} head;

	void	*format_specific_data;
} IMG_REF;

#endif