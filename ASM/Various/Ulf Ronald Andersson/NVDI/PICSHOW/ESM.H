/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>

#ifndef	__ESM_IMAGE__
#define	__ESM_IMAGE__

#define	ESM_MONOCHROME	
#define	ESM_GRAYSCALE	2

typedef struct
{
	int32	magic;															/* 'TMS\0' */
	int16	size;																/* LÑnge des Headers in Bytes (0x032c) */

	int16	width;															/* Breite in Pixeln */
	int16	height;															/* Hîhe in Zeilen */

	int16	planes;															/* Bits pro Pixel */
	int16	format;															/* Bildtyp */

	int16	r_bits;															/* Anzahl der Bits fÅr Rot */
	int16	g_bits;															/* Anzahl der Bits fÅr GrÅn */
	int16	b_bits;															/* Anzahl der Bis fÅr Blau */
	int16	k_bits;															/* Anzahl der Bits fÅr Schwarz (??) */	

	int16	version;															/* Versionsnummer */
	int16	hdpi;																/* horizontale Auflîsung in dpi */
	int16	vdpi;																/* vertikale Auflîsung in dpi */

	int16	file_height;
	int16	y1;																/* erste anzuzeigende Zeile */
	int16	y2;																/* letzte anzuzeigende Zeile */

	int16	mask;																/* Maske */

	uint8	red[256];														/* Rot-IntensitÑten */
	uint8	green[256];														/* GrÅn-IntensitÑten */
	uint8	blue[256];														/* Blau-IntensitÑten */

} ESM_HEAD;

#endif




