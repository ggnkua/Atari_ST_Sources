/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#define	ESM_MONOCHROME	
#define	ESM_GRAYSCALE	2

typedef struct
{
	LONG	magic;															/* 'TMS\0' */
	WORD	size;																/* LÑnge des Headers in Bytes (0x032c) */

	WORD	width;															/* Breite in Pixeln */
	WORD	height;															/* Hîhe in Zeilen */

	WORD	planes;															/* Bits pro Pixel */
	WORD	format;															/* Bildtyp */

	WORD	r_bits;															/* Anzahl der Bits fÅr Rot */
	WORD	g_bits;															/* Anzahl der Bits fÅr GrÅn */
	WORD	b_bits;															/* Anzahl der Bis fÅr Blau */
	WORD	k_bits;															/* Anzahl der Bits fÅr Schwarz (??) */	

	WORD	version;															/* Versionsnummer */
	WORD	hdpi;																/* horizontale Auflîsung in dpi */
	WORD	vdpi;																/* vertikale Auflîsung in dpi */

	WORD	file_height;
	WORD	y1;																/* erste anzuzeigende Zeile */
	WORD	y2;																/* letzte anzuzeigende Zeile */

	WORD	mask;																/* Maske */

	UBYTE	red[256];														/* Rot-IntensitÑten */
	UBYTE	green[256];														/* GrÅn-IntensitÑten */
	UBYTE	blue[256];														/* Blau-IntensitÑten */

} ESM_HEAD;







