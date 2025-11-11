#include <aesbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <xbios.h>
#include <math.h>

/* RESOURCE SET INDICES FOR CALC */

#define CALC		0	/* form / dialog */
#define DISPLAY		1	/* BUTTON in tree CALC */
#define NEGATE		2	/* BUTTON in tree CALC */
#define CLEARD		3	/* BUTTON in tree CALC */
#define CLEAR		4	/* BUTTON in tree CALC */
#define CBOX		5	/* IBOX   in tree CALC */
#define LPAREN		6	/* BUTTON in tree CALC */
#define RPAREN		7	/* BUTTON in tree CALC */
#define DIV		8	/* BUTTON in tree CALC */
#define MULT		9	/* BUTTON in tree CALC */
#define B7		10	/* BUTTON in tree CALC */
#define B8		11	/* BUTTON in tree CALC */
#define B9		12	/* BUTTON in tree CALC */
#define MINUS		13	/* BUTTON in tree CALC */
#define B4		14	/* BUTTON in tree CALC */
#define B5		15	/* BUTTON in tree CALC */
#define B6		16	/* BUTTON in tree CALC */
#define PLUS		17	/* BUTTON in tree CALC */
#define B1		18	/* BUTTON in tree CALC */
#define B2		19	/* BUTTON in tree CALC */
#define B3		20	/* BUTTON in tree CALC */
#define EQUALS		21	/* BUTTON in tree CALC */
#define B0		22	/* BUTTON in tree CALC */
#define DECIMAL		23	/* BUTTON in tree CALC */		

/* display control constants */

#define	MAX_DISP	9		/* display width, chars */
#define MAX_DIGS	MAX_DISP - 1	/* above, minus sign char */
#define NXTOLAST	MAX_DISP - 2	/* position left of decimal pt. */
#define VERYLAST	MAX_DISP - 1	/* last char in display */
#define SIGN		0		/* sign char offset */
#define FSTPOS		1		/* first digit position */
#define SNDPOS		2		/* second digit position */

/* ST numeric keypad scancodes */

#define K_CLHM		0x47		/* clear/ home key */
#define K_MINUS		0x4a		/* minus key */
#define K_PLUS		0x4e		/* plus key */
#define K_UNDO		0x61		/* UNDO key */
#define K_HELP		0x62		/* HELP key */
#define K_LP		0x63		/* left paren key */
#define K_EQ		0x72		/* enter key */

/* calculator machine states */

#define MNEWENTRY	0		/* start of operand input */
#define MENTRY		1		/* operand of input in progress */
#define MOPERATOR	2		/* operator key pressed */
#define MEQUALS		3		/* equals key pressed */

/* various and sundry defines */

#define NOWINDOW	-1			/* no window open */
#define WTYPE		(NAME | CLOSER | MOVER)	/* window attributes */
#define HI_RES		2			/* monochrome monitor */
#define NUM_OBJS	24			/* objects in resource */
#define NO_OBJ		-1			/* "no object" code */
#define MAX_PLEVELS	49			/* paren nesting limit */

/* Inline functions: push and pop operands, operators, flags, etc. */

#define push_opd(op)	(opd_stack[opdsp++] = (op))
#define pop_opd()	(opd_stack[--opdsp])

#define push_opr(op)	(opr_stack[oprsp++] = (op))
#define pop_opr()	(opr_stack[--oprsp])

#define push_opf(op)	(opf_stack[opfsp++] = (op))
#define pop_opf()	(opf_stack[--opfsp])

#define rdisp()		objc_draw(calc, DISPLAY, MAX_DEPTH, CRECT)
#define display		((char *) calc[DISPLAY].ob_spec)

/* convenience equates to shorten window-management expressions */

#define CX		calc[0].ob_x
#define CY		calc[0].ob_y
#define CW		calc[0].ob_width
#define CH		calc[0].ob_height
#define CRECT		CX, CY, CW, CH
#define CPRECT		&CX, &CY, &CW, &CH
#define WRECT		w.x, w.y, w.w, w.h
#define WPRECT		&w.x, &w.y, &w.w, &w.h
#define TRECT		t.x, t.y, t.w, t.h
#define TPRECT		&t.x, &t.y, &t.w, &t.h

/* globals */

/* calculator resource data structure -- generated from .RSC file */
			
OBJECT calc[] = 	{

0xFFFF,   0x1,    0x5, 0x14,  0x0, 0x0,     0x1173L, 0x15F,  0x9, 0x63, 0x53,
0x2,   0xFFFF, 0xFFFF, 0x1A,  0x0, 0x0, "       0.",   0x9,  0x2, 0x50,  0x8,
0x3,   0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "N",   0xA,  0xD, 0x10,  0x8,
0x4,   0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "D",  0x35,  0xD,  0xF,  0x8,
0x5,   0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "C",  0x49,  0xD, 0x10,  0x8,
0x0,      0x6,   0x17, 0x14,  0x0, 0x0,    0x11142L,   0x5, 0x17, 0x59, 0x3A,
0x7,   0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "(",   0x5,  0x3, 0x10,  0x8,
0x8,   0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         ")",  0x1A,  0x3, 0x10,  0x8,
0x9,   0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "/",  0x2F,  0x3, 0x10,  0x8,
0xA,   0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "*",  0x44,  0x3, 0x10,  0x8,
0xB,   0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "7",   0x5,  0xE, 0x10,  0x8,
0xC,   0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "8",  0x1A,  0xE, 0x10,  0x8,
0xD,   0xFFFF, 0xFFFF, 0x1A,0x841, 0x0,         "9",  0x2F,  0xE, 0x10,  0x8,
0xE,   0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "-",  0x44,  0xE, 0x10,  0x8,
0xF,   0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "4",   0x5, 0x19, 0x10,  0x8,
0x10,  0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "5",  0x1A, 0x19, 0x10,  0x8,
0x11,  0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "6",  0x2F, 0x19, 0x10,  0x8,
0x12,  0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "+",  0x44, 0x19, 0x10,  0x8,
0x13,  0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "1",   0x5, 0x24, 0x10,  0x8,
0x14,  0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "2",  0x1A, 0x24, 0x10,  0x8,
0x15,  0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "3",  0x2F, 0x24, 0x10,  0x8,
0x16,  0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "=",  0x44, 0x24, 0x10, 0x13,
0x17,  0xFFFF, 0xFFFF, 0x1A, 0x41, 0x0,         "0",   0x5, 0x2F, 0x25,  0x8,
0x5,   0xFFFF, 0xFFFF, 0x1A, 0x61, 0x0,         ".",  0x2F, 0x2F, 0x10,  0x8

			};


char *noblanks();		/* blank_stripping function */
char opr_stack[50];		/* operator stack */
double opd_stack[50];		/* operand stack */
char opf_stack[50];		/* flag stack */
int oprsp, opdsp, opfsp;	/* stack pointers */
int levels;			/* parenthesis levels */
int op = MNEWENTRY;		/* calculator state */


/******************************************************************************
			MAIN PROGRAM
******************************************************************************/

main()
{

	extern int gl_apid;
	
	appl_init();
	menu_register(gl_apid, "  Calculator");
	events();

}


/******************************************************************************
			ACCESSORY EVENT MANAGER
*******************************************************************************/

events()
{

	int ret, mx, my, key, dummy, message[8];
	Mouse mouse = { &mx, &my, &dummy, &dummy };
	Rect w, t;				/* window & temp rects */
	int win = NOWINDOW;			/* window handle */
	int obj;				/* object number */
	int xd, yd;				/* window offsets */
	int i;					/* looping variable */
	
	if (Getrez() == HI_RES)
		for (i = 0; i < NUM_OBJS; i++)	{
			calc[i].ob_height = calc[i].ob_height * 2;
			calc[i].ob_y = calc[i].ob_y * 2;
						}

	
	form_center(calc, CPRECT);		/* center calculator */
	wind_calc(0, WTYPE, CRECT, WPRECT);	/* get window coords */
	xd = CX - w.x; yd = CY - w.y;		/* set differences   */
				
	while (1)	{			/* endless loop */

		ret = evnt_multi(MU_KEYBD | MU_BUTTON | MU_MESAG, 1, 1, 1,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, message, 0, 0, mouse,
			&key, &dummy);
		
		if (ret & MU_MESAG)
						 
			switch(message[0])	{
				
				case (AC_OPEN):
					if (win == NOWINDOW)	{
					win = wind_create(WTYPE, WRECT);
					wind_set(win, WF_NAME, "BeanCalc",0,0);
					wind_open(win, WRECT);
								}
					else
					wind_set(win, WF_TOP, 0, 0, 0, 0);
					break;

/****** if the system is about to take the window away, give it up *******/

				case (AC_CLOSE):
					win = NOWINDOW;
					break;

/****** if someone wants the window shut down, close and delete it *******/

				case (WM_CLOSED):
					wind_close(win);	
					wind_delete(win);
					win = NOWINDOW;
					break;
/****** if someone moved it, update coordinates and reset it ************/

				case (WM_MOVED):
					w.x = message[4];
					w.y = message[5];
					CX = w.x + xd;
					CY = w.y + yd;
					wind_set(win, WF_CURRXYWH, WRECT);
					break;

/****** if system wants it on top, top it ********************************/

				case (WM_TOPPED):
				case (WM_NEWTOP):
					wind_set(win, WF_TOP, 0, 0, 0, 0);
					break;

/****** if system wants it redrawn, chase rectangle list to redraw it ****/

				case (WM_REDRAW):
					wind_update(BEG_UPDATE);
					graf_mouse(M_OFF, 0L);
					wind_get(win, WF_FIRSTXYWH, TPRECT);
					while (t.w && t.h)	{
					objc_draw(calc, 0, MAX_DEPTH, TRECT);
					wind_get(win, WF_NEXTXYWH, TPRECT);
								}
					graf_mouse(M_ON, 0L);
					wind_update(END_UPDATE);


					} /* end of switch(message[0]) */

/****** if we get a keyboard message, convert the key to an appropriate
ASCII value and send it to the calculator manager **********************/


		if (ret & MU_KEYBD)
			if (obj = keyconv(key >> 8))
				manage_calc(obj);

/****** if we get a mouse button message, determine which object the user
clicked, and manage the calculator **************************************/

		if (ret & MU_BUTTON)	{
			
			obj = objc_find(calc, CALC, MAX_DEPTH, mx, my);
			if (obj != NO_OBJ && obj != CALC && obj != CBOX
				&& obj != DISPLAY)
				manage_calc(obj);

					}


			}	/* end of while(1) */

}	/*************** end of events() ***********************/


/******************************************************************************
		CONVERT KEYBODE TO OBJECT NUMBER

	Most of this can be handled by using the scancode as an index into an
array.  Otherwise handle special cases via switch.
******************************************************************************/


keyconv(key)
unsigned int key;
{

	static int keypad[] = {
		LPAREN, RPAREN, DIV, MULT, 
		B7, B8, B9,
		B4, B5, B6,
		B1, B2, B3,
		B0, DECIMAL, EQUALS };

	if (key >= K_LP && key <= K_EQ)
		return(keypad[key - K_LP]);

	switch(key)	{
		case K_HELP:	return(NEGATE);
		case K_UNDO:	return(CLEAR);
		case K_CLHM:	return(CLEARD);
		case K_MINUS:	return(MINUS);
		case K_PLUS:	return(PLUS);
			}

	return(0);

}


/******************************************************************************
			MANAGE CALCULATOR
******************************************************************************/

manage_calc(obj)
int obj;
{

	static opf = 0;				/* operand flag */
	
	objc_change(calc, obj, 0, CRECT, SELECTED, 1);	/* select object */
				
	switch(obj)	{

	/* if the clear key has been pressed, zero all stack pointers and
	the level count, clear the display, and set for new entry */

		case (CLEAR):
			opf = opdsp = oprsp = levels = 0;
			clear_disp();
			op = MNEWENTRY;
			break;

	/* if the clear display key has been pressed and the machine is in
	the process of operand entry, clear the display and set as if operand
	entry were beginning */

		case (CLEARD):
			if (op == MENTRY)	{
				clear_disp();
				op = MNEWENTRY;
						}
				break;

	/* if an operator key has been pressed and the machine is awaiting
	operator entry, process the operator.  Start by pusing the operand
	on the display, and switch the operand count flag.  Call evaluate()
	if the operand count is > 0.  Then push the operator. */

		case (PLUS):
		case (MINUS):
		case (MULT):
		case (DIV):
			if (op == MENTRY || op == MEQUALS)	{
				push_opd(atof(noblanks()));
				opf++;
				if (opf == 2)	{
					evaluate();
					opf = 1;
						}
				push_opr(obj);
				op = MNEWENTRY;
								}
			break;

	/* If the equals key has been pressed and the machine is capable of
	performing a pending evaluation, push the operand on the display
	and do it. */

		case (EQUALS):
			if (op == MENTRY && opf == 1)	{
				push_opd(atof(noblanks()));
				evaluate();
				pop_opd();
				opf = 0;
				op = MEQUALS;
							}
			break;

	/* If the negate key has been pressed invert the sign of the display */

		case (NEGATE):
			display[SIGN] = (display[SIGN] == '-') ? ' ' : '-';
			rdisp();
			break;

	/* If the left paren key has been pressed and the machine is awaiting
	operand entry, bump up a paren level */

		case (LPAREN):
			if (op == MNEWENTRY && levels < MAX_PLEVELS)	{
				push_opf(opf);
				opdsp++;
				oprsp++;
				levels++;
				opf = 0;
									}
			break;

	/* If the right paren key has been pressed and the machine is
	capable of performing a pending evaluation, do it and jump down
	a paren level */

		case (RPAREN):
			if (op == MENTRY && opf && levels)	{
				push_opd(atof(noblanks()));
				evaluate();
				pop_opd();
				levels--;
				opdsp--;
				oprsp--;
				opf = pop_opf();
								}
			break;

	/* Otherwise it must be a number key or something similar, so pass
	it on to the operand entry manager */

		default:
			do_entry(obj);

			}	/* end of switch(obj) **********************/

	objc_change(calc, obj, 0, CRECT, NORMAL, 1);	/* deselect object */


}	/************** end of manage_calc(obj) *****************************/


/******************************************************************************
			CLEAR PHYSICAL DISPLAY
******************************************************************************/

clear_disp()
{

	strcpy(display, "       0.");
	rdisp();

}


/******************************************************************************
	MAKE ENTRY:  ENTER DIGIT OR DECIMAL, CHANGE SIGN
*******************************************************************************/

do_entry(v)
int v;
{

	static int dp = 0, nd = 0;

	if (op == MNEWENTRY)	{
		clear_disp();
		dp = nd = 0;
		if (v == B0)
			return;
				}

	if (v == DECIMAL)	{
		dp = 1;
		if (op == MNEWENTRY)
			nd = 1;
				}

	else	{
		if (op == MNEWENTRY || (display[SIGN] == '-' && nd == 0))
			display[NXTOLAST] = ' ';
		if ((nd + 1) < MAX_DIGS)	{
			strcpy(display + FSTPOS, display + SNDPOS);
			display[NXTOLAST + dp] =  *((char *) calc[v].ob_spec);
			if (!dp)
				display[VERYLAST] = '.';
			nd++;
						}
		rdisp();
		}

	op = MENTRY;


}	/********* end of do_entry(v) ****************************************/


/******************************************************************************
			EVALUATE A SUBEXPRESSION
******************************************************************************/

evaluate()
{

	float opd1, opd2;
	char oper;

	opd2 = pop_opd();	/* pop first operand (note reverse order) */
	opd1 = pop_opd();	/* pop second operand */
	oper = pop_opr();	/* pop operator */
				
	switch(oper)	{
		
		case (PLUS):
			push_opd(opd1 + opd2);
			break;
		case (MINUS):
			push_opd(opd1 - opd2);
			break;
		/* handle "divide by 0" errors here */
		case (DIV):
			if (opd2 == 0)
				push_opd((double) 0);
			else
				push_opd(opd1 / opd2);
			break;
		case (MULT):
			push_opd(opd1 * opd2);
			break;

			} /* end of switch(oper) ****/

	
	frame(opd_stack[opdsp - 1]);	/* display result */
	rdisp();


} /*********  end of evaluate() **********************************************/


/******************************************************************************
		FORMAT DOUBLE FOR DISPLAY
******************************************************************************/


frame(f)
double f;
{

	char buf[60];		/* 1.e+37 + 11 precision = 49 */
	
	sprintf(buf, "%8.6f", f);	/* convert to ASCII float format */

	if (ezdp(buf))	{		/* If <= 12 chars, minus tr. 0's... */

		strcpy(display, "         ");	/* clear display */
		display[SIGN] = (buf[SIGN] == '-') ? '-' : ' ';
		strcpy(display + MAX_DISP - strlen(buf) + (f < 0),
			buf + (f < 0));
			}

	else
		sprintf(display, "%.1e", f);

}


/******************************************************************************
			ELIMINATE TRAILING ZEROS IN BUFFER
******************************************************************************/


ezdp(s)
char *s;
{

	int i = strlen(s) - 1;

	while (s[i] == '0')
		s[i--] = '\0';

	return(strlen(s) <= MAX_DISP);

}


/******************************************************************************
		ELIMINATE BLANKS FROM BUFFER FOR ATOF()
******************************************************************************/


char *noblanks()
{

	static char buf[MAX_DISP];
	int i = 0, j = 0;

	for ( ; j < MAX_DISP; j++)
		if (display[j] != ' ')
			buf[i++] = display[j];

	buf[i] = '\0';
	return(buf);


}
