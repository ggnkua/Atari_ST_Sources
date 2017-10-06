/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>

#ifndef	__COLORMAP__
#define	__COLORMAP__

enum
{
	CSPACE_RGB		=	'RGB ',
	CSPACE_CMY		=	'CMY ',
	CSPACE_CMYK		=	'CMYK'
};

enum
{
	CSPACE_1COMPONENT		=	0x0001,
	CSPACE_2COMPONENTS	=	0x0002,
	CSPACE_3COMPONENTS	= 	0x0003,
	CSPACE_4COMPONENTS	=	0x0004
};

typedef struct
{
	uint16	red;
	uint16	green;
	uint16	blue;
	uint16	reserved;
} COLOR_RGB;

typedef struct
{
	uint16	cyan;
	uint16	magenta;
	uint16	yellow;
	uint16	reserved;
} COLOR_CMY;

typedef struct
{
	uint16	cyan;
	uint16	magenta;
	uint16	yellow;
	uint16	black;
} COLOR_CMYK;

typedef union
{
	COLOR_RGB	rgb;
	COLOR_CMY	cmy;
	COLOR_CMYK	cmyk;
} COLOR_ENTRY;

typedef struct
{
	int32	magic;															/* 'cmap' */
	int32	length;
	int32	format;
	int32	reserved;
	
	int32	map_id;
	int32	color_space;
	int32	flags;
	int32	no_colors;

	int32	reserved1;
	int32	reserved2;
	int32	reserved3;
	int32	reserved4;

	COLOR_ENTRY	colors[];
} COLOR_MAP;

typedef struct
{
	int32	magic;															/* 'imap' */
	int32	length;
	int32	format;
	int32	reserved;
	
	int32	map_id;
	int16	no_bits;
	int16	levels;
	int32	flags;
	int32	no_colors;

	int32	reserved1;
	int32	reserved2;
	int32	reserved3;
	int32	no_hidden_values;
	uint8	hidden_values[256];

	uint8	values[];
} INVERSE_CMAP;

INVERSE_CMAP	*create_inverse_cmap( COLOR_MAP *cmap, int16 no_bits, int16 levels );
int16	delete_inverse_cmap( INVERSE_CMAP *inverse_cmap );
int32	rgb_to_value( uint16 red, uint16 green, uint16 blue, COLOR_MAP *cmap, INVERSE_CMAP *inverse_cmap );

#endif