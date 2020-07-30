/*****************************************************************************
*
*                                   7UP
*                              Header: UNDO.H
*                            (c) by TheoSoft '92
*
*****************************************************************************/
#define LINEUNDO  (-1)
#define LINEPAST  (-2)
#define CUTLINE   (-3)
#define CUTPAST   (-4)
#define PASTCUT   (-5)
#define BACKSPACE (0x0008)
#define RETURN    (0x000D)

typedef struct
{
	int menu,item;                /* FÅr PASTE */
   LINESTRUCT *blkbeg, *blkend;  

	long wline, begline, endline; /* FÅr CUT   */
	int begcol, endcol; 
	int blktype;                  /* Blocktyp */

	char string[STRING_LENGTH+2]; /* Lineundo */
	char *cp;
	int row,col;
   int flag;
} UNDO;

extern UNDO undo;

