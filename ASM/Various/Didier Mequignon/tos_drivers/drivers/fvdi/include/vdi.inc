/****
* fVDI VDI declarations, by Johan Klockars
*
* $Id: vdi.inc,v 1.5 2002/07/10 21:59:29 johan Exp $
*
* This file is put in the public domain.
* It is not copyrighted or under any sort of license.
****/

#define CHUNKY			1
#define TRUE_COLOUR		2

#define WHITE		 	0
#define BLACK 			1
#define EFFECTS			0x3f		// %00111111

#define only_fvdi		1

/*
* VDI array
*/
#define control			0
#define intin			4
#define ptsin			8
#define intout			12
#define ptsout			16

/*
* Control
*/
#define function		0
#define L_ptsin			2
#define L_ptsout		4
#define L_intin			6
#define L_intout		8
#define subfunction		10
#define handle			12


*
* VDI struct
* Font struct
*
#include	"types.inc"
