/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>

#ifndef	__ICTAB__

#define	__ICTAB__

#define	INVERSE_CTAB	ICTAB
#define	INVERSE_CTAB_MAGIC	'itab'

typedef struct																/* inverse Farbtabelle */
{
	int32	magic;															/* 'itab' */
	int32	length;
	int32	format;															/* Format (0) */
	int32	reserved;
	
	int32	map_id;															/* Kennung der Farbtabelle */
	int16	no_bits;															/* Aufl”sung pro Farbkomponente: 3, 4 oder 5 Bits */
	int16	levels;															/* Anzahl der Abstufungen pro Komponente: 2^no_bits */
	int32	flags;
	int32	no_colors;

	int32	reserved1;
	int32	reserved2;
	int32	reserved3;
	int32	no_hidden_values;
	uint8	hidden_values[256];

	uint8	values[];
} INVERSE_CTAB;

#endif
