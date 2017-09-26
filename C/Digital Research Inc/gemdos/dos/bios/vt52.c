
/*	@(#)vt52.c	3.6		*/
/*	Copyright 1984, Motorola Inc.	*/
/******************************************************************************

Function Name:	cons_out

Description:	Main entry point for the VME/10 screen driver.  This
		VME/10 screen driver is an implementation of the VT52.
		It supports the following functions:

		carriage return - cursor is placed at column 0 on the 
			current line.
			How Recognized : <cr> = 0D(hex)

		line feed - cursor is placed at the same column on the next
			line.
			How Recognized : <lf> = 0A(hex)

		backspace - cursor will move 1 column to the left on the 
			screen.  If the cursor is already at column zero then
			it will be placed at the last column of the previous 
			line.  If the cursor is currently on the top line of
			the display at column zero; it will remain where it is.
			How Recognized : <bs> = 08(hex)

		tab - cursor moves to next tab stop on current line.  Cursor
			moves to end of line if there are no more
			tab stop on the line.  Tab stops are set every eight
			columns.
			How Recognized : <tab> = 09(hex)

		clear to end of screen - blanks are written to the cursor
			and all positions on the screen following the
			cursor.  The cursor will remain in its current
			position.
			How Recognized : <esc>J = 1B 4A (hex)

		clear to end of line - blanks are written to the cursor
			and all positions on the line following the cursor.
			The cursor will remain in its current position.
			How Recognized : <esc>K = 1B 4B (hex)

		home cursor - cursor will be placed on the first line at the
			first column on the screen.
			How Recognized : <esc>H = 1B 48 (hex)

		move cursor right - cursor will be moved one character position
			right without affecting the character at that position.
			The cursor will not move past the right margin.
			How Recognized : <esc>C = 1B 43 (hex)

		move cursor up - cursor will be moved one up one line.  If the
			cursor is on the top line then it will stay there.
			How Recognized : <esc>A = 1B 41 (hex)

		reverse line feed - move the cursor up one line.  If the cursor
			was already on the top line the screen will be scrolled
			down one line.  The line at the top of the screen will
			be cleared.  The cursor will remain in the same column.
			How Recognized : <esc>I = 1B 49 (hex)

		position cursor - cursor will be moved to the specified line
			and column.  If either value is beyond the edge of the
			screen then the maximum value for that argument will
			be used.  The line position is sent before the column
			position.  Both values are added to the ASCII space
			character value so that the values received are
			printable characters.
			How Recognized : <esc>Y<line+' '><col+' '> = 1B 59 (hex)

		place character - will place any printable character (i.e.
			20 - 7E (hex)) at the present cursor position on the
			screen.
			How Recognized : any printable character (which is not
					part of a control function sequence).

Inputs:		char - a 7-bit ascii character.

Outputs:	None.

External variables: None

******************************************************************************/

#define MAXCOLS		79	/*last column on physical screen     */
#define MAXLINES	23	/*last line on physical screen 	     */
#define ESC		0x1b	/* <esc> character		     */
#define TAB		0x09	/* <tab> character		     */
#define CR		0x0d	/* carriage return		     */
#define LF		0x0a	/* line feed      		     */
#define BS		0x08	/* back space			     */
#define INITATTR	0x4400	/*default attributes in character RAM*/
#define FALSE		0
#define TRUE		1
#define UP		0	/*indicates scroll screen up	     */
#define DOWN		1	/*indicates scroll screen down	     */

/*	states in which the screen driver can exist whenever a character
	is received.  Basically indicates possible previous sequences of 
	characters which have been received.				     */

#define any_char	0	/* ready to receive any character    */
#define esc		1	/* last character was an <esc>	     */
#define curs_line	2	/* next char is encoded cursor line pos */
#define curs_col	3	/* next char is encoded cursor column pos */

/*	Logical Screen Control Block - contains information on each logical
	screen (i.e., window) which is available on the physical screen of the
	VME/10  (the first version only supports 1 logical screen and it is
	mapped to all but the last line of the physical screen.		     */

typedef struct
	{
	short	cur_line;	/*current line cursor is on	     */
	short	cur_col;	/*current column cursor is at	     */
	short	cur_cursor;	/*current offset of cursor on the 
				  screen; first position = 0;	     */
	short	base_line;	/*first line of the logical screen   */
	short	base_col;	/*first column of the logical screen */
	short	max_line;	/*last line on screen relative to base*/
	short	max_col;	/*last col on screen relative to base*/
	char	tabstop[MAXCOLS+1];/*the element corresponding to each
				   column on the screen contains the 
				   column where the next tabstop is 
				   located.			     */
	} lscb;

/*	chr_map describes the word in the character and attribute RAM which
	corresponds to a character on the screen.  Note that the chr field 
	in the declaration is 8 bits.  This assumes that software attribute
	bit 2 is not being used.					     */

typedef struct
	{
	char	attr;		/*attributes of character:
				  bit 7 - software attribute 1	 
				  bit 6 - don't display character
				  bit 5 - blink character     	
				  bit 4 - underline character 
				  bit 3 - inverse video	
				  bit 2 - color or intensity bit 1
				  bit 1 - color or intensity bit 2
				  bit 0 - color or intensity bit 3   */
	char	chr;		/* 7 - bit ascii character	     */
	} chr_map;

/*	attribute and character RAM area 
	maps the VME/10 screen for regular character I/O		     */

#define SCRN_ADDR	((short (*)[80])0xf17000) /*address of character RAM*/

/*	information necessary to access the CRTC (the screen controller)     */

typedef struct			/*map of the registers for the CRTC  */
	{
	char	addr_reg;	/*address register selects which 
				  register to write in register file */
	char	fill2, reg_file;/*data to registers goes here	     */
	} crtc_map;

#define CRTC_ADDR	((crtc_map *)0xf1a021) /*address of the CRTC	     */
#define CURHIGH		14
#define CURLOW		15

/*	VARIABLE DECLARATIONS						     */

static int	state;		/* current state of screen driver    */
static lscb	scrn_tbl = {	/* Logical Screen Control Table	     */
		MAXLINES,	/* current line			     */
		0,		/* current column  		     */
		0,		/* current cursor		     */
		0,		/* base line			     */
		0,		/* base column			     */
		MAXLINES,	/*max line on screen relative to base*/
		MAXCOLS,	/*max col for screen relative to base*/
		/* tab stops */
		 8,  8,  8,  8,  8,  8,  8,  8, 16, 16, 16, 16, /*  0-11 */
		16, 16, 16, 16, 24, 24, 24, 24, 24, 24, 24, 24, /* 12-23 */
		32, 32, 32, 32, 32, 32, 32, 32, 40, 40, 40, 40, /* 24-35 */
		40, 40, 40, 40, 48, 48, 48, 48, 48, 48, 48, 48, /* 36-47 */
		56, 56, 56, 56, 56, 56, 56, 56, 64, 64, 64, 64, /* 48-59 */
		64, 64, 64, 64, 72, 72, 72, 72, 72, 72, 72, 72, /* 60-71 */
		79, 79, 79, 79, 79, 79, 79, 79			/* 72-79 */
		};
static short	mcurslin;	/* move cursor - line position */
static short	char_mask = {INITATTR};/*attribute & character mask  */
char		scrver[] = "screen driver 3.6";

cons_out(chr)
char	chr;			/*7-bit ascii character		     */
{
	chr &= 0x7f;		/*strip the high order bit	     */

	switch ((int)state)	/*perform action based on the current*/
	{			/*state of the screen handler.	     */
	case any_char:		/*waiting to accept any character (i.e.
				  are not processing control sequence*/
		switch (chr)
		{
		case ESC:	/*received an <esc> character	     */
			state = esc;
			break;

		case TAB:	/*received a <tab> character	     */
			scrn_tbl.cur_col = scrn_tbl.tabstop[scrn_tbl.cur_col];
			pos_cursor(FALSE);
			break;

		case CR:	/*received a carriage return	     */
			scrn_tbl.cur_col = 0;
			pos_cursor(FALSE); /*position cursor per scrn_tbl*/
			break;

		case LF:	/*received a line feed		     */
			/*at end of screen?*/
			if (scrn_tbl.cur_line == scrn_tbl.max_line)
				scroll(UP, MAXCOLS); 	/* scroll up 1 line */
			else
				scrn_tbl.cur_line++;	/* cursor down 1 line */
			pos_cursor(FALSE);	/*position cursor per scrn_tbl*/
			break;

		case BS:	/*received a back space character    */
			/*at beginning of a line? */
			if (scrn_tbl.cur_col == 0)
			{
				if (scrn_tbl.cur_line != 0)
				{	/* not at first line of display */
					/*place cursor at last column of
					  previous line */
					scrn_tbl.cur_line--;
					scrn_tbl.cur_col = scrn_tbl.max_col;
				}
				else
					break;	/* at first line of display */
			}
			else	/* not at beginning of a line */
				scrn_tbl.cur_col--;
			pos_cursor(FALSE); /*position cursor per scrn_tbl */
			break;

		default:
			{
			/* character and attributes for RAM */
			register short	chr_attr;

			if (chr >= ' ')	/* printable character? */
				{
				/* chr in 16-bit template */
				chr_attr = char_mask | (short)chr;
				/*place character on the screen    */
				(SCRN_ADDR[scrn_tbl.base_line+scrn_tbl.cur_line]
				[scrn_tbl.base_col+scrn_tbl.cur_col])=chr_attr;
				pos_cursor(TRUE); /* put cursor at next pos */
				}
			}
		} /* end of switch(chr) */
		break;

	case esc:		/* process a control function sequence */
		state = any_char; /* except position cursor is special */
		switch (chr)
		{
		case 'A':	/* cursor up a line */
			if ( scrn_tbl.cur_line != scrn_tbl.base_line )
				scrn_tbl.cur_line--;
			pos_cursor(FALSE);
			break;

		case 'C':	/* nondestructive space */
			pos_cursor(TRUE);
			break;

		case 'H':	/* home cursor */
			scrn_tbl.cur_col  = scrn_tbl.base_col;
			scrn_tbl.cur_line = scrn_tbl.base_line;
			pos_cursor(FALSE);	/* position the cursor */
			break;

		case 'I':	/* reverse line feed */
			if ( scrn_tbl.cur_line != scrn_tbl.base_line )
				scrn_tbl.cur_line--;
			else
				scroll(DOWN, MAXCOLS);
			pos_cursor(FALSE);
			break;

		case 'J':	/* clear display from cursor */
			{
			int line;

			line = scrn_tbl.cur_line;
			clr_line(line++,scrn_tbl.cur_col);
			while ( line <= scrn_tbl.max_line )
				clr_line(line++,scrn_tbl.base_col);
			}
			break;

		case 'K':	/* clear line from cursor */
			clr_line(scrn_tbl.cur_line,scrn_tbl.cur_col);
			break;

		case 'Y':	/* position cursor */
			state = curs_line;	/* next comes cursor line */
			break;
		}
		break;

	case curs_line:
		mcurslin = chr - ' ';		/* save new line position */
		if ( mcurslin > MAXLINES ) mcurslin = MAXLINES; /* limit it */
		state = curs_col;		/* next comes cursor column */
		break;

	case curs_col:
		scrn_tbl.cur_line = mcurslin;	/* update cursor position */
		chr = chr - ' ';
		if ( chr > MAXCOLS ) chr = MAXCOLS; /* limit position */
		scrn_tbl.cur_col = chr;
		pos_cursor(FALSE);		/* move it */
		state = any_char;
		break;

	} /* end of switch(state) */
}

pos_cursor(incr)
short	incr;
{
	register short	curpos;	/*byte offset to cursor postion  */

	if (incr)		/*bump cursor 1 postion or does screen
				  table already have correct position?*/
	{			/*bump cursor			     */
		if (scrn_tbl.cur_col != scrn_tbl.max_col) /*end of line?*/
			scrn_tbl.cur_col++; /*no, bump cursor position*/
	}

	curpos = (scrn_tbl.base_line + scrn_tbl.cur_line) * (MAXCOLS + 1)
		 + (scrn_tbl.base_col + scrn_tbl.cur_col);
	CRTC_ADDR->addr_reg = CURLOW;
	CRTC_ADDR->reg_file = (char)curpos;
	CRTC_ADDR->addr_reg = CURHIGH;
	CRTC_ADDR->reg_file = (char)(curpos >> 8);
}

clr_line(line,col)	/* clear to end of line starting at col */
int	line, col;
{
	register short	chr_attr;	/* attribute & character */
	register int	j;
	register short	*p;		/* address of character */

	/*set up to move blanks to screen RAM*/
	chr_attr = char_mask | 0x0020;
	j = scrn_tbl.max_col + 1 - col; /*decremented for each char */
	/*address of 1st charactr*/
	p = &(SCRN_ADDR[line][col]);
	do { /*write blanks to line */
		*p++ = chr_attr;	/*write blank to a char pos*/
	} while (--j);
}

scroll(direction, num_chrs)
int	direction;	/*direction to scroll the screen */
int	num_chrs;	/*number of characters to scroll */
{
register int	i, j, line;
register short	chr_attr;	/*attribute & character */
register short	*p1, *p2;	/*address of character */

	if (direction == UP)	/*scroll screen text up */
	{
		line = scrn_tbl.base_line; /*used to step down lines */
		i = scrn_tbl.max_line;	/*decremented for each line */
		do {
			j = scrn_tbl.max_col + 1; /*decremented for each char */
			/*address of 1st charactr*/
			p1 = &(SCRN_ADDR[line++][scrn_tbl.base_col]);
			p2 = &(SCRN_ADDR[line][scrn_tbl.base_col]);
			do {		/*move a line at a time	*/
				*p1++ = *p2++;	/*move character up a line */
			} while (--j);
		} while (--i);
	}
	else /*direction == DOWN*/
	{
		line = scrn_tbl.max_line; /*used to step up lines */
		i = scrn_tbl.max_line;	/*decremented for each line */
		do {
			j = scrn_tbl.max_col + 1; /*decremented for each char */
			/*address of 1st charactr*/
			p1 = &(SCRN_ADDR[line--][scrn_tbl.base_col]);
			p2 = &(SCRN_ADDR[line][scrn_tbl.base_col]);
			do {		/*move a line at a time	*/
				*p1++ = *p2++;	/*move character up a line */
			} while (--j);
		} while (--i);
	}

	chr_attr = char_mask | 0x0020;	/*move blanks to screen RAM*/
	/*address of 1st character */
	p1 = &(SCRN_ADDR[line][scrn_tbl.base_col]);
	j = scrn_tbl.max_col + 1;	/*decremented for each char */
	do {				/*write blanks to a line */
		*p1++ = chr_attr;	/*write blank to a char pos*/
	} while (--j);
}

