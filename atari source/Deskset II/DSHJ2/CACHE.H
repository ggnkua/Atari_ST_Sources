/*************************************************************************
**	cache.h								**
**	---------------------------------------------------------	**
**	Copyright 1986 by Compugraphic, Inc. All rights reserved.	**
**************************************************************************
	Product:	Intellifont Sub-System
	Component:	Cache structure definitions
	Author:		Ed Gavrin
*************************************************************************/
/*	History:						*/
/* cache.h	29-Sep-86	awr added contents of lnk.h	*/
/* cache.h	29-Aug-86	awr combined 3 include files	*/
/* charl3.i	07-Jun-86	awr slot LRU added		*/
/* charl2.i	22-mar-86	jmm LRU for RAM sizes		*/
/*fm_charlist.i	26-nov-85	egv Date created		*/

/*	Requires include file	bitmap.h	*/

struct	dll_type {
	struct dll_type	*fptr;		/* forward pointer	*/
	struct dll_type *bptr;		/* backward pointer	*/
};	/*---- struct size = 8 bytes ----*/

/*	Character data		*/
struct	cdata_type {
	int font_id;	/* font number	of character (-1 : not set)	*/
	int point_size;	/* point size	of character in 1/8th points	*/
	int set_size;	/* set	 size	of character in 1/8th points	*/
	int italic_angle;/* pseudo italic angle of char in 1/4 degrees	*/
	int rotate_angle;/* rotation	  angle of char in 1/8 degrees	*/
	char bold;	/* bold flag	of character			*/
	char devnum;	/* device #	of character (0...7)		*/
};	/*---- struct size = 12 bytes ----*/

/*	Cache character entry		*/
struct	charlist_type {
	struct dll_type	char_thread;	/* list of fonts for flash  8	*/
	struct dll_type lru_slot;	/* "	"	"    slot   8	*/
	struct cdata_type cd;		/* char data stuff	    12	*/
	unsigned	total_wc;	/* word count of bitmap	    2	*/
	struct bit_map_type *block_ptr; /* pointer to bitmap	    4	*/
};	/*---- struct size = 34 bytes ----*/

/*	Font manager input packet	*/
struct	packet_type {
	int			flash_pos;
	struct cdata_type	p_cd;
        struct charlist_type	*char_ptr;
};	/*---- struct size = 18 bytes ----*/
