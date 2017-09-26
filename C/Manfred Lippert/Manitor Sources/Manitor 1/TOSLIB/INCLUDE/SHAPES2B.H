/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>

#ifndef	__REGIONS__
#ifndef	__SHAPES__
#define	__SHAPES__

#pragma PRAGMA_PACKED_ALIGN											/* Strukturelemente byteweise anordnen */

typedef struct																/* Punkt für 16-Bit-Koordinaten */
{
	int16	x;
	int16	y;
} POINT16;

typedef struct																/* Punkt für 32-Bit-Koordinaten */
{
	int32	x;
	int32	y;
} POINT32;

typedef struct																/* Rechteck für 16-Bit-Koordinaten */
{
	int16	x1;
	int16	y1;
	int16	x2;
	int16	y2;
} RECT16;

typedef struct																/* Rechteck für 32-Bit-Koordinaten */
{
	int32	x1;
	int32	y1;
	int32	x2;
	int32	y2;
} RECT32;

#pragma PRAGMA_RESET_ALIGN												/* Einstellung zurücksetzen */

#endif
#endif