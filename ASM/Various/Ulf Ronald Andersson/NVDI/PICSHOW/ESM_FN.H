/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	"PIC.H"
#include	"ESM.H"

int16	ESM_open( int8 *name, IMG_REF *pic, int16 vdi_handle );
int16	ESM_close( IMG_REF *pic );
int16	ESM_read_slice( IMG_REF *pic, PIC_BUFFER *buf, int16 y1, int16 y2 );
