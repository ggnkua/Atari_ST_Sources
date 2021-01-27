/*  Copyright (c) 1993 - 2008 by Henk Robbers Amsterdam.
 *
 * This file is part of CALC.
 *
 * CALC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * CALC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CALC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* 	SHEET.H
 *	=======
 */

#ifndef SHEET_H
#define SHEET_H

#include <stddef.h>

#define MAXCOLS 26   /* WARNING: MAXCOLS*MAXROWS*4 < 32767 !!! */
#define MAXROWS 99
#define DEFCOLW 12
#define TOPMARGIN deskw.unit.h
#define LEFTMARGIN (4*deskw.unit.w)

#define MAXI 128
#define MAXD 6
#define NAML 12

/* Beware! bits are numbered 15-0, Not 0-15 !!!! */
typedef union
{
	ushort d;
	struct
	{
		ubits y: 7;
		ubits m: 4;
		ubits d: 5;
	} dd;
} Tdate;

typedef
enum
{
	TXT,VAL,FORM,FUN,LAB
} SH_ATTR;

typedef struct
{
	char name[NAML];
	int cols,rows,colwsize;
	unsigned char colw[MAXCOLS];
#if sizeof(colw)&1
	char vul;
#endif
} SH_HDR;

typedef struct
{
	int size,cosize,ty,col,row;
	unsigned int attr,flags;
	double val;
	char text[MAXI+1],
	     comm[MAXI+1];
	Tdate cre, upd;	/* dates */
} SH_CELL;										/* 1 cell */

typedef struct identifier
{
	struct identifier *next;
	int ty, col, row;
	char name[32];
} IDES;

typedef SH_CELL  *CELLP;							/* ptr to 1 cell */
typedef    CELLP   SH_TAB[MAXCOLS] [MAXROWS];	/* table of ptrs to cell */
typedef SH_TAB   *SH_SHEET;						/* ptr to table of ptrs to cell */

typedef struct
{
	int col, row;
	SH_CELL sbuf, z;
	SH_SHEET copies;
	RECT copy_rect;
} SH;

CELLP get_c(int col, int row);
double shparse(SH_SHEET c, IDES *ides, char *s, unsigned int *att);
int fdenotation_space(int big, int root);
bool cellname(char **, int *, int *, int, int);
bool rellname(char **, int *, int *, int, int);
char * absname(char **, int *, int *, int *);
char * is_label(char *s, int *ty);
char * dcol(unsigned short i);
char * drow(unsigned short i);
void   sh_kolom(struct it *w, int i, bool hide);
typedef void SHEET_ACT(void *vw, CELLP c);

#define get_cell(w,i,j) (*(w)->wks.tab )[(i)][(j)]
#define get_save(w,i,j) (*sh.copies)[(i)][(j)]
#define pget_c(c,i,j)   (*(c))[(i)][(j)]			/* voor parser */

extern SH sh;
#endif
