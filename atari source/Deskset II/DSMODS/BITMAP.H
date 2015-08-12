/*************************************************************************
**	bitmap.h							**
**	---------------------------------------------------------	**
**	Copyright 1986 by Compugraphic, Inc. All rights reserved.	**
**************************************************************************
	Product:	Intellifont Sub-System
	Component:	Character bit map structure
	Author:		Al Ristow
*************************************************************************/
/*	The following defines the structure of the character bit map
	produced by the Intellifont process.
*/

#define		BMP_HEADER_SIZE		26

struct	bit_map_type {
	int	width;		/* bit map width (words)		*/
	int	depth;		/* "	"  depth (pixels)		*/
	int	left_indent;	/* left indent to black box (pixels)	*/
	int	top_indent;	/* top	"	"	"	"	*/
	int	black_width;	/* character black box	width (pixels)	*/
	int	black_depth;	/*	"	"	depth	"	*/
	int	base_pix;	/* top of bit map to baseline (pixels)	*/
	int	bot_bearing;		/*	reserved	*/
	int	new_lsb;	/* new	left	side bearing (scan)	*/
	int	new_rsb;	/* "	right	"	"	"	*/
	int	old_lsb;	/* original left side bearing (scan)	*/
	int	old_rsb;	/* "	    right	"	"	*/
	int	body_width;	/* character body width (scan)		*/
	unsigned bm[4];		/* character bit map			*/
};
