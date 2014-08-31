/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	"PIC.H"

int16	IMG_open( int8 *name, IMG_REF *pic, int16 vdi_handle );
int16	IMG_close( IMG_REF *pic );
int16	IMG_read_slice( IMG_REF *pic, PIC_BUFFER *buf, int16 y1, int16 y2 );
