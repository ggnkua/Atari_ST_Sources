/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module:	DISPLAY -- high-level graphics

	get_wind, find_wind, find_row, find_tag, tag_window, disp_window, find_param
	disp_name, draw_screen

******************************************************************************/

overlay "gr"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "externs.h"

/* is a given set of parameters somewhere on the screen? ....................*/

get_wind(seq,type)	/* returns window # -1 for none */
int seq,type;
{
	register int i;
	
	for (i=0; i<NWIND; i++)
		if ((wind_seq[i]==seq)&&(wind_type[i]==type)) return(i);
	return(-1);
}	/* end get_wind() */

/* given y-coord is in which window? ........................................*/
/* returns window #, -1 for none */

find_wind(my)
int my;
{
	register int wind;

	for (wind=1; wind<NWIND; wind++) if (my<wind_y[wind]) break;
	wind--;
	return(wind);
}	/* end find_wind() */

/* y-coord + window y-coord = parameter row # ...............................*/
/* returns row # 0 - NROW-1, -1 for none */

find_row(my,y)
int my,y;
{
	register int temp,row;

	temp= rez<<3;
	for (row=0; row<NROW; row++)
		if ( (my>=y+val_y[row]) && (my<=y+val_y[row]+temp) ) return(row);
	return(-1);
}	/* end find_row() */

/* y-coord + window y-coord = tag row # .....................................*/
/* returns row # 0 - NTAG-1, -1 for none */

find_tag(my,y)
int my,y;
{
	register int temp,row;

	temp= rez<<3;
	for (row=0; row<NTAG; row++)
		if ( (my>=y+tag_y[row]) && (my<=y+tag_y[row]+temp) ) return(row);
	return(-1);
}	/* end find_tag() */

/* "tag" a window ...........................................................*/

tag_window(wind)
int wind;		/* 0 - NWIND-1 */
{
	register int y= wind_y[wind];
	register int temp;

	outchar('1'+wind_seq[wind],X_SEQX,y+tag_y[0]);
	outchar(typetags[wind_type[wind]],X_TYPE,y+tag_y[1]);
	if (wind_type[wind]!=V_TYPE)
	{
		temp= wind_start[wind];
		outchar(*int1char[temp/100],X_TYPE-1,y+tag_y[2]);
		gr_text(int2char[temp%100],X_TYPE,y+tag_y[2]);
	}
}	/* end tag_window() */

/* display all parameters in a window .......................................*/

disp_window(i)
register int i;		/* window # 0 - NWIND-1 */
{
	register int y,n;
	register char *seqptr;
	register PARAM *paramptr;
	int val,start,type;
	PARAM param;
	long offset;

	paramptr= params[type=wind_type[i]];
	y=	wind_y[i];
	start= 2*wind_start[i];
	seqptr= seq1data[wind_seq[i]];
	n= nparams[type];

	HIDEMOUSE;
	xor_lock=1;
	for (i=0; i<n; i++)
	{
		build_any();
		param= *paramptr++;
		offset= param.offset;
		/* is it an operator or operand? */
		if ( ((type==P_TYPE)||(type==R_TYPE)) && (i<2*NPERPAGE) ) offset+=start;
		val= param.nbytes > 1 ?
			*(int*)(seqptr+offset) : seqptr[offset] ;
		gr_text(param.encode[val],param.col,y+val_y[param.row]);
	}
	xor_lock=0;
	SHOWMOUSE;

}	/* end disp_window() */

/* given column, row, and type, what parameter is there? ....................*/
/* returns parameter # (index into params arrays), -1 for none ..............*/
find_param(col,row,type)
int col,row,type;
{
	register int i;
	
	for (i=0; i<nparams[type]; i++)
		if ( (row == params[type][i].row) &&
			  (col >= params[type][i].col) &&
			  (col <= params[type][i].col + params[type][i].ncols - 1 ) )
		return(i);
	return(-1);
}	/* end find_param() */

/* show song name in upper right corner .....................................*/

disp_name()
{
	if (play_mode) return;		/* don't do it if there's no menu bar there */
	HIDEMOUSE;
	gr_text("            ",65,1);
	gr_text(songname,65,1);
	SHOWMOUSE;
}	/* end disp_name() */

/* complete redraw screen ...................................................*/

draw_screen()
{
	register int i;

	HIDEMOUSE;
	for (i=0; i<NWIND; i++)
	{
		if (play_mode)
		{
			if (xorc_col[i]) outcurs(xorc_col[i],xorc_row[i]);
			xorc_col[i]=0;
			if (xorp_col[i]) outcurs(xorp_col[i],xorp_row[i]);
			xorp_col[i]=0;
		}
		draw_wind(wind_type[i],i);
		tag_window(i);
		disp_window(i);
	}
	SHOWMOUSE;
}	/* end draw_screen() */

/* EOF disp.c */
