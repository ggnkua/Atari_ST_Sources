/*********************************************
	file: cursor.h
	utility: header file of cursor.c
	date: 14 nov 96
	author: C.Moreau 
	modifications:
	comments: 
*********************************************/

#ifndef _CURSOR_H
#define _CURSOR_H

/*********************************************
	includes
*********************************************/

/*********************************************
	defines
*********************************************/
	/* number of data in 1 line in window */
#define NB_DATA_IN_LINE	16
	/* number of char for 1 hexadecimal data */
#define HEX_DATA_WSIZE	2
	/* number of char for 1 ascii data */
#define ASCII_DATA_WSIZE	1
	/* start column of ASCII data */
#define ASCII_DATA_OFFSET	48
 
/*********************************************
	types definitions
*********************************************/

/*********************************************
	globals variables declarations
*********************************************/
			/* offset in char for data in window */
extern int xoffset[];

/*********************************************
	globals functions declarations
*********************************************/
extern void putcur(void);

#endif