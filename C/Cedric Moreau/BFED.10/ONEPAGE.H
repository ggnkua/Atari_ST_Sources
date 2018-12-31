/*********************************************
	file: onepage.h
	utility: header file of onepage.c
	date: 16 dec 96
	author: C.Moreau
	modifications:
	comments: 
*********************************************/

#ifndef _ONEPAGE_H
#define _ONEPAGE_H

/*********************************************
	includes
*********************************************/
#ifdef __PUREC__
#include <aes.h>
#else
#include <aesbind.h>
#endif

#include "wind.h"

/*********************************************
	defines
*********************************************/
#define BLANK ' '
#define DOUBLE_BLANK	"  "

/*********************************************
	types definitions
*********************************************/

/*********************************************
	globals variables declarations
*********************************************/
	/* haxedecimal string and ascii string */
extern unsigned char hexa_str[80], ascii_str[80];
	/* hexa to ascii conversion table */
extern unsigned char table[600];

/*********************************************
	globals functions declarations
*********************************************/
extern void one_page(windowptr thewin, GRECT *r1);
extern unsigned getbyte(windowptr thewin,long pos);
extern void putbyte(windowptr	thewin,long	pos, long lnum);
extern void one_line2(windowptr	thewin,long 		pos);
extern void set_table(void);

#endif