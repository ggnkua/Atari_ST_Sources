/*
 * CALCUTIL.C
 *   Utilities for the START Desk Calculator
 *
 *  by Alex Leavens
 *  Rev 1.060387
 *  Copyright 1987 by Dynamic Software Design
 */

#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"
#include "strtcalc.h"
#include "aesbind.h"
#include "stdio.h"
#include "math.h"
#include "errno.h"
/**********
#include "calcdefn.h"
***********/

#define NO_OP	1000
#define RN_ST	1001
#define STFLG	1002
#define SUBRT	1003
#define LABEL	1004
#define GO_TO	1005
#define PAUSE	1006
#define XEQT	1007
#define XNET	1008
#define XLTT	1009
#define XGTT	1010
#define IFFLG	1011
#define DSZ	1012
#define A_LBL	1013
#define B_LBL	1014
#define C_LBL	1015
#define D_LBL	1016
#define E_LBL	1017
#define A'LBL	1018
#define B'LBL	1019
#define C'LBL	1020
#define D'LBL	1021
#define E'LBL	1022
#define IFNOT	1023
#define RETRN   1024
#define CRFLG	1025
#define DSNZ	1026
#define XLET	1027
#define XGET	1028

#define YROOTX  999

#define F_OK 1

extern long menuadd;
extern long boxadd;

extern int	label_offset[];
extern char	*operands[];
extern char	*oper_codes[];
extern char	*label_display[];

extern OBJECT *rsc_pointer;
extern TEDINFO *ted_pointer;
extern TEDINFO *ted2_pointer;

extern int	msgbuff[8];	/* event message buffer */
extern int	keycode;	/* keycode returned by event-keyboard */
extern int	mx,my;		/* mouse x and y pos. */
extern int	butdown;	/* button state tested for, UP/DOWN */
extern int	ret;		/* dummy return variable */
extern int	dummy;		/* another dummy return variable */
extern int	i;

extern int	f_handle;
extern int     cur_drive;
extern char    cur_dir[68];
extern char	tbuf[108];	/* Strings for handling string input	*/
extern char	path_buf[108];	/* stuff...				*/
extern char	wild_buf[108];

extern int	key_trans[10];

extern double	pi;

/********************* Calculator related variables ********/

extern int	orig_stack_pointer;	/* original stack pointer value    */
extern int	ted_index;		/* How many digits in the display? */
extern int	decimal_flag;		/* has the '.' key been pressed?   */
extern int	exp_flag;		/* Exponent on?			   */
extern int	enter_exp_flag;		/* Just hit the EE key?		   */
extern int	result_flag;		/* has a result been generated?    */
extern int	error_flag;		/* Error occurred?		   */
extern int	exponent_value;		/* Value of the exponent...	   */
extern int	processor_mode;		/* Calculating or processing       */

extern int	label_positions[50];	/* label addresses...		   */
extern int	subroutine_stack[30];	/* Subroutine return addresses...  */
extern int	sub_stack_pointer;	/* Pointer to next open subroutine */

extern double   x_register;		/* Initial (immediate) register    */
extern double   t_register;		/* Test register		   */

extern int	recursion_level;	/* Number of recursive calls	   */

extern struct stack_frame {
	double	math_value;
	int	op_code;
} math_stack[10][100];

extern int	stack_level;		/* Which stack frame?		   */
extern int	stack_pointer[10];	/* Pointer to stack stuff... 	   */
extern int	parens;			/* Number of    open parentheses   */

extern char	converter[50];		/* Array for converting to/from    */
				/* Numbers to ASCII		   */

extern int	trig_flag;		/* Degree or radian mode?	   */

extern int	program_counter;	/* Who am I?	*/
extern int	old_ppc;

extern int 	editing, obj_found;
extern int 	wonger;
extern int 	foobar;
extern int 	tick;
extern int 	x,y,w,h;
extern int 	what_tree, tree_offset;
extern int 	second_flag;		/* 2nd Key pressed ? */
extern int	inverse_flag;		/* Inverse key pressed ? */
extern char 	is_key;
extern int 	butt_direction;		/* Direction of mouse button in event */

extern int	mem_loc;		/* Pointer to memory location */
extern int	program_pointer;	/* Program to next step in memory */
extern int	flags[10];		/* Flag registers 	*/
extern double	memories[100];		/* Data Memories... */
extern int	program[1000];

extern char	temp1, temp2;		/* You're not serious... */

/******* End Calculator related variables ********/
/* Does anybody actually _read_ these comments?? */

extern int	xdesk, ydesk, wdesk, hdesk;	/* window variables */
extern int	xwork, ywork, wwork, hwork;	/* workstation sizes */
extern int 	xleft, yleft, wleft, hleft;	/* window size 	*/
extern int	xmunge, ymunge, wmunge, hmunge; /* window interior size */
extern int 	xdial,ydial,wdial,hdial;

extern int	hidden;		/* state of mouse pointer */

extern int	num_colors;		/* number of possible screen colors */
extern int	xres, yres;		/* screen x and y resolutions	    */
extern int	nplanes;		/* number of planes of the screen   */

extern int	handle;		/* system handle */
extern int	wi_handle;	/* window handle */

extern int	gl_hchar;
extern int	gl_wchar;
extern int	gl_wbox;
extern int	gl_hbox;	/* system sizes */

extern int	contrl[12];
extern int	intin[128];
extern int	ptsin[128];
extern int	intout[128];
extern int	ptsout[128];	/* storage wasted for idiotic bindings */

extern int work_in[11];	/* Input to GSX parameter array */
extern int work_out[57];	/* Output from GSX parameter array */
extern int pxyarray[10];	/* input point array */

/***********************************
 *
 * DO_LEARN()
 *	Enter learn mode, and teach the calculator a few things...
 *
 */
 
do_learn()
{
	int i;
	int dead_dog;

	for (i = 0; i <= 25; i++)
		ted2_pointer->te_ptext[i] = 0x20;

	display_pc();
	redraw();

	dead_dog = TRUE;

	while(dead_dog)
	{
	  
	  wonger = evnt_multi( MU_BUTTON | MU_KEYBD | MU_MESAG,
		1,1,butt_direction,	/*evnt_button*/
		0,0,0,0,0,		/*evnt_mouse1*/
		0,0,0,0,0,		/*evnt_mouse2*/
		msgbuff,		/*evnt_mesg*/
		100,0,			/*evnt_timer*/
		&mx,&my,		/*mouse x,y*/
		&foobar,		/*mouse button*/
		&foobar,		/*shift keys*/
		&keycode,		/*evnt_keyboard*/
		&foobar);		/*number of clicks*/

	  if ((wonger & MU_BUTTON) &&	/* User clicked on something.. */
	      (butt_direction == DOWN))
	  {
	    butt_direction = UP;
	    obj_found = objc_find(boxadd, CALCPAD, 2, mx, my);
	    
	    switch(obj_found){

		case CALCOFF:
		case LEARN:
			dead_dog = FALSE;
			break;

		case RUNSTOP:
			push_program(RN_ST);
			break;
		
		case KZEROA:
			if (second_flag == TRUE)
			{
			    if (inverse_flag != TRUE)
				push_program(DSZ);
			    else
			    	push_program(DSNZ);
			}
			else
				push_program(obj_found);
			break;

		case KONEA:
			if (second_flag == TRUE)
			{
			    if (inverse_flag != TRUE)
				push_program(IFFLG);
			    else
			    	push_program(IFNOT);
			}
			else
				push_program(obj_found);
			break;
		case KFOURA:
			if (second_flag == TRUE)
			{
			    if (inverse_flag != TRUE)
				push_program(XGET);
			    else
			    	push_program(XLTT);
			}
			else
				push_program(obj_found);
			break;
		case KFIVEA:
			if (second_flag == TRUE)
			{
			    if (inverse_flag != TRUE)
				push_program(XLET);
			    else
			    	push_program(XGTT);
			}
			else
				push_program(obj_found);
			break;
		case KSIXA:
			if (second_flag == TRUE)
				push_program(RETRN);
			else
				push_program(obj_found);
			break;
		case KSEVENA:
			if (second_flag == TRUE)
				push_program(XEQT);
			else
				push_program(obj_found);
			break;
		case KEIGHTA:
			if (second_flag == TRUE)
				push_program(XNET);
			else
				push_program(obj_found);
			break;
		case KNINEA:
			if (second_flag == TRUE)
				push_program(NO_OP);
			else
				push_program(obj_found);
			break;
		case RESET:
			if (second_flag == TRUE)
			{
			    if (inverse_flag != TRUE)
				push_program(STFLG);
			    else
			    	push_program(CRFLG);
			}
			else
			{
				program_counter = 0;
				display_pc();
			}
			break;
		case SUBROUTI:
			redraw();
			if (second_flag == TRUE)
			{
				second_flag = FALSE;
				set_label();	/* Set Label Address Here  */
				display_pc();
			}
			else
				push_program(SUBRT);
			break;
		case KGOTO:
			if (second_flag == TRUE)
				push_program(PAUSE);
			else
				push_program(GO_TO);
			break;

		case EQUALS:
			if (second_flag == TRUE)	/* Delete */
			{
			    for (i = program_counter; i <= 998; i++)
			    	program[i] = program[i + 1];
			    for (i = 0; i <= 42; i++)
			    {
			    	if (label_positions[i] > program_counter)
			    	    label_positions[i]--;
			    	else if (label_positions[i] == program_counter)
			    	    label_positions[i] = 1001;
			    }
			    program[999] = NO_OP;
			    display_pc();
			}
			else
				push_program(obj_found);
			break;

		case KPLUS:
			if (second_flag == TRUE)	/* Insert */
			{
			    for (i = 998; i >= program_counter; i--)
			    	program[i + 1] = program[i];
			    for (i = 0; i <= 42; i++)
			    {
			    	if (label_positions[i] == 999)
			    	    label_positions[i] = 1001;
			    	else if (label_positions[i] >= program_counter)
			    	    label_positions[i]++;
			    }
			    program[program_counter] = NO_OP;
			    display_pc();
			}
			else
				push_program(obj_found);
			break;

		case KEYA:
		case KEYB:
		case KEYC:
		case KEYD:
		case KEYE:
		case KTWOA:
		case KTHREEA:
		case KPOINT:
		case XXCHANGT:
		case STO:
		case RCL:
		case OPENPARN:
		case CLOSPARN:
		case KEYCOS:
		case KEYSIN:
		case KEYTAN:
		case SUM:
		case CLEAR:
		case CE:
		case TIMES:
		case MINUS:
		case DIVIDED:
		case XSQUARED:
		case ROOTX:
		case LNX:
		case LOGX:
		case ONEOVERX:
		case YTOTHEX:
		case EE:
		case PLUSMINU:
			if (second_flag == TRUE)
				push_program(SECOND);
			if (inverse_flag == TRUE)
				push_program(INVERSE);
			push_program(obj_found);
			break;

		case SECOND:
			redraw();
			second_flag = TRUE;
			break;

		case INVERSE:
			redraw();
			inverse_flag = TRUE;
			break;

		default:
			break;

	    } /* End switch(obj_found) */

	    if ((obj_found != SECOND) &&  (obj_found != INVERSE))
	    {
		second_flag = FALSE;
	  	inverse_flag = FALSE;
	    }

	  } /* End if((wonger & MU_BUTTON) && (butt_direction == DOWN)) */

	  /* Ok, read the button again... */

	  else if ((wonger & MU_BUTTON) &&
	  	   (butt_direction == UP))
	  	   	butt_direction = DOWN;

	  else if (wonger & MU_MESAG)
	  {
	    switch (msgbuff[0]) {

		case WM_CLOSED:
		    dead_dog = 0;
		    break;

		case WM_NEWTOP:
		case WM_TOPPED:
			wind_set(wi_handle,WF_TOP,0,0,0,0);
			break;
			
		default:
		    wind_update(TRUE);
		    objc_draw(boxadd, CALCPAD, 2, xdial, ydial, wdial, hdial);
		    wind_update(FALSE);
		    break;

	    } /* switch (msgbuff[0]) */
	  }

	  else if (wonger & MU_KEYBD)
	  {
		/* Test for valid keys... */
		switch(keycode){

		case 0x4800:		/* Up arrow */
			if (program_counter >= 1)
				program_counter--;
			display_pc();
			keycode = 0;
			break;
		case 0x5000:		/* Down arrow */
			if (program_counter <= 998)
				program_counter++;
			display_pc();
			keycode = 0;
			break;
		default:
			break;
		}
	  }
	} /* end while(dead_dog) */
}
/************************
 *
 * DISPLAY_PC()
 */
 
display_pc()
{
	int a, b, c;

	for (a = 0; a <= 10; a++)
	    ted2_pointer->te_ptext[a] = 0x20;

	for (a = 0; a <= 42; a++)
	{
	    if (label_positions[a] == program_counter)
	    {
	    	ted2_pointer->te_ptext[1] = 'L';
	    	ted2_pointer->te_ptext[2] = 'b';
	    	ted2_pointer->te_ptext[3] = ':';
	    	for (b = 0; b <= 4; b++)
	    	{
		    ted2_pointer->te_ptext[4+b] = label_display[a][b];
		}
		break;
	    }
	}
	    	
	a = program_counter;
	b = c = 0;
	while(a >= 100)
	{
		c++;
		a -= 100;
	}
	while(a >= 10)
	{
		b++;
		a -= 10;
	}
	ted2_pointer->te_ptext[10] = '0' + c;
	ted2_pointer->te_ptext[11] = '0' + b;
	ted2_pointer->te_ptext[12] = '0' + a;

	dummy = program[program_counter];

	if (dummy > 1000)
	{
		a = dummy - 1000;
		for (i = 0; i < 5; i++)
			ted2_pointer->te_ptext[20+i] = operands[a][i];
	}
	else
	{
	    switch(dummy){
	    
	    case KZEROA:
	    	a = 0;
	    	break;
	    case KONEA:
	    	a = 1;
	    	break;
	    case KTWOA:
	    	a = 2;
	    	break;
	    case KTHREEA:
	    	a = 3;
	    	break;
	    case KFOURA:
	    	a = 4;
	    	break;
	    case KFIVEA:
	    	a = 5;
	    	break;
	    case KSIXA:
	    	a = 6;
	    	break;
	    case KSEVENA:
	    	a = 7;
	    	break;
	    case KEIGHTA:
	    	a = 8;
	    	break;
	    case KNINEA:
	    	a = 9;
	    	break;
	    case EE:
	    	a = 10;
	    	break;
	    case OPENPARN:
	    	a = 11;
	    	break;
	    case CLOSPARN:
	    	a = 12;
	    	break;
	    case KPOINT:
	    	a = 13;
	    	break;
	    case PLUSMINU:
	    	a = 14;
	    	break;
	    case DIVIDED:
	    	a = 15;
	    	break;
	    case TIMES:
	    	a = 16;
	    	break;
	    case MINUS:
	    	a = 17;
	    	break;
	    case KPLUS:
	    	a = 18;
	    	break;
	    case SECOND:
	    	a = 19;
	    	break;
	    case INVERSE:
	    	a = 20;
	    	break;
	    case KEYSIN:
	    	a = 21;
	    	break;
	    case KEYCOS:
	    	a = 22;
	    	break;
	    case KEYTAN:
	    	a = 23;
	    	break;
	    case LNX:
	    	a = 24;
	    	break;
	    case LOGX:
	    	a = 25;
	    	break;
	    case XSQUARED:
	    	a = 26;
	    	break;
	    case ROOTX:
	    	a = 27;
	    	break;
	    case ONEOVERX:
	    	a = 28;
	    	break;
	    case XXCHANGT:
	    	a = 29;
	    	break;
	    case STO:
	    	a = 30;
	    	break;
	    case RCL:
	    	a = 31;
	    	break;
	    case SUM:
	    	a = 32;
	    	break;
	    case YTOTHEX:
	    	a = 33;
	    	break;
	    case CLEAR:
	    	a = 34;
	    	break;
	    case CE:
	    	a = 35;
	    	break;
	    case EQUALS:
	    	a = 36;
	    	break;
	    case KEYA:
	    	a = 38;
	    	break;
	    case KEYB:
	    	a = 39;
	    	break;
	    case KEYC:
	    	a = 40;
	    	break;
	    case KEYD:
	    	a = 41;
	    	break;
	    case KEYE:
	    	a = 42;
	    	break;
	    default:
		a = 37;
		break;
	    }
	    for (i = 0; i < 5; i++)
		ted2_pointer->te_ptext[20+i] = oper_codes[a][i];
	    
	}

	redraw();
}
/**************************
 *
 * PUSH_PROGRAM()
 *   Push op code into program memory
 */
 
push_program(what_op)
int what_op;
{
	program[program_counter] = what_op;
	if (program_counter <= 998)
		program_counter++;
	display_pc();
}
/***********
 *
 * DO_MINUS()
 */
do_minus()
{
	recursion_level = 0;
	if (second_flag == TRUE)
	{
	    to_number(TRUE);
	    if (trig_flag != RADIANS)
		    to_radians();
	    to_ascii(FALSE);
	    trig_flag = RADIANS;
	    enter_exp_flag = FALSE;
	    result_flag = TRUE;
	    decimal_flag = FALSE;
	}
	else
	{
	    to_number(FALSE);
	    push_stack(MINUS);
	    to_ascii(TRUE);
	    enter_exp_flag = FALSE;
	    result_flag = TRUE;
	    decimal_flag = FALSE;
	}
	redraw();
}
/*****************
 *
 * DO_EQUALS()
 */
do_equals()
{
	int foobar;

	to_number(FALSE);
	if ((math_stack[stack_level][stack_pointer[stack_level]].op_code == OPENPARN) ||
	    (math_stack[stack_level][stack_pointer[stack_level]].op_code == YTOTHEX))
	{
		errno = ERANGE;
		set_error();
		redraw();
		return;
	}
	push_stack(EQUALS);
	push_stack(NO_OP);
	recursion_level = 0;
	parens = 0;
	orig_stack_pointer = stack_pointer[stack_level];
	foobar = evaluate_stack(0);
	to_ascii(TRUE);
	enter_exp_flag = FALSE;
	result_flag = ALL_DONE;
	decimal_flag = FALSE;
	redraw();
}	
/*****************
 *
 * DO_OPEN_PARN()
 */
 
do_open_parn()
{
	if (stack_level <= 8)
		stack_level++;
	else
	{
		error_flag = ERANGE;
		set_error();
		return;
	}
	x_register = 0;
	recursion_level = 0;
	push_stack(NO_OP);
	stack_pointer[stack_level] = 0;
	redraw();
}
/*****************
 *
 * DO_CLOSE_PARN()
 */
do_close_parn()
{
	to_number(FALSE);
	push_stack(EQUALS);
	push_stack(NO_OP);
	recursion_level = 0;
	parens = 0;
	orig_stack_pointer = stack_pointer[stack_level];
	foobar = evaluate_stack(0);
	to_ascii(TRUE);
	if (stack_level >= 1)
		stack_level--;
	else
	{
		error_flag = ERANGE;
		set_error();
		return;
	}
	
	enter_exp_flag = FALSE;
	result_flag = ALL_DONE;
	decimal_flag = FALSE;
	redraw();
}
/***************
 *
 * DO_Y_TO_THE_X()
 */
do_y_to_the_x()
{
	to_number(FALSE);
	recursion_level = 0;
	if (inverse_flag != TRUE)
		push_stack(YTOTHEX);
	else
		push_stack(YROOTX);
	enter_exp_flag = FALSE;
	result_flag = TRUE;
	decimal_flag = FALSE;
	to_ascii(TRUE);
	redraw();
}
/*page*/
/****************************
 *
 * SHO_1FORM()
 *
 * Sho_1form displays a dialog window (Such as "Do you really want to quit?"),
 * accepts the input from the user (and locks everything else up until the
 * user inputs an answer), resets the object to non-highlighted (NORMAL),
 * and then returns to the calling routine what button was pressed to
 * exit the dialog...
 *
 */

sho_1form(what_tree, tree_offset)

int what_tree, tree_offset;
{
	int dummy;
	long boxadd;
	int x,y,w,h,xdial,ydial,wdial,hdial;
	int what_key;

	graf_mouse(0,&dummy);
	x=y=w=h=0;
	rsrc_gaddr(0, what_tree, &boxadd);
	form_center ( boxadd, &xdial, &ydial, &wdial, &hdial );
	wind_update(TRUE);
	form_dial ( 0, x, y, w, h, xdial, ydial, wdial, hdial );
	form_dial ( 1, x, y, w, h, xdial, ydial, wdial, hdial ); 
	objc_draw ( boxadd, CALCPAD, 2, xdial, ydial, wdial, hdial );
	what_key = form_do ( boxadd, 0 ); 
	rsc_pointer[tree_offset + what_key].ob_state = NORMAL;
	form_dial ( 2, x, y, w, h, xdial, ydial, wdial, hdial ); 
	form_dial ( 3, x, y, w, h, xdial, ydial, wdial, hdial ); 
	wind_update(FALSE);
	return(what_key);
}
/*************************
 *
 * RUN_CALC()
 *
 */
 
run_calc()
{
    int a_temp, temp1, temp2;
    int type;
    int keystate, mx, my, buttons;

    while((processor_mode == RUNNING) || (processor_mode == SINGLE_STEP))
    {
    	temp1 = graf_mkstate(&mx, &my, &buttons, &keystate);
    	if ((buttons & 0x01) == 1)
    	{
	    temp1 = objc_find(boxadd, CALCPAD, 2, mx, my);
	    if (temp1 == RUNSTOP)
	    {
	    	processor_mode = STOPPED;
	    	redraw();
	    	return;
	    }
	}
    	
	obj_found = program[program_counter];	/* Get next op code */

	switch(obj_found){

	    case RN_ST:
		bump_ppc();
		if (processor_mode == RUNNING)
		{
			processor_mode = STOPPED;
			second_flag = FALSE;
			inverse_flag = FALSE;
			redraw();
		}
		obj_found = EQUALS;
		break;

	    case GO_TO:
		bump_ppc();
		obj_found = program[program_counter];
		if (obj_found == SECOND)
		{
			second_flag = TRUE;
			bump_ppc();
			obj_found = program[program_counter];
		}
		do_go_to();
		break;

	    case NO_OP:
	    	bump_ppc();
	    	break;

	    case RETRN:
	    	if (sub_stack_pointer >= 1)
	    		sub_stack_pointer--;
	    	program_counter = subroutine_stack[sub_stack_pointer];
		second_flag = FALSE;
		inverse_flag = FALSE;
	    	break;

	    case SUBRT:
		bump_ppc();
		obj_found = program[program_counter];
		if (obj_found == SECOND)
		{
			second_flag = TRUE;
			bump_ppc();
			obj_found = program[program_counter];
		}
		do_go_to();
	    	subroutine_stack[sub_stack_pointer] = old_ppc;
		if (sub_stack_pointer <= 29)
		    	sub_stack_pointer++;
		break;
		
	    case STFLG:
	    case CRFLG:
	    	type = obj_found;
	    	bump_ppc();
	    	obj_found = program[program_counter];
	    	a_temp = make_integer();
	    	if (a_temp != 10)
	    	    if (type == STFLG)
			flags[a_temp] = IS_SET;
		    else
		    	flags[a_temp] = IS_CLEAR;
	    	bump_ppc();
		second_flag = FALSE;
		inverse_flag = FALSE;
	    	break;
	    		
	    case IFFLG:
	    case IFNOT:
	        type = obj_found;
	    	bump_ppc();
	    	obj_found = program[program_counter];
	    	a_temp = make_integer();
		bump_ppc();		/* Get label here */
	    	if (a_temp != 10)
	    	{
	    	    if ((( flags[a_temp] == IS_SET ) && ( type == IFFLG )) ||
	    	        (( flags[a_temp] == IS_CLEAR ) && (type == IFNOT)))
	    	    {
			obj_found = program[program_counter];
			if (obj_found == SECOND)
			{
			    second_flag = TRUE;
			    bump_ppc();
			    obj_found = program[program_counter];
			}
			do_go_to();
		    }
		    else
		    	bump_ppc();
		}
		else
		    bump_ppc();
		second_flag = FALSE;
		inverse_flag = FALSE;
		break;
		
	    case PAUSE:
		to_ascii(TRUE);
		processor_mode = STOPPED;
		redraw();
		processor_mode = RUNNING;
		for (a_temp = 1; a_temp < 5000; a_temp++)
		{
		}
		bump_ppc();
		break;

	    case DSZ:
	    case DSNZ:
	        type = obj_found;
	    	bump_ppc();		/* Get register to decrement */
	    	obj_found = program[program_counter];
	    	a_temp = make_integer();
	    	bump_ppc();		/* Get the label to go to... */
	    	if (a_temp != 10)
	    	{
	    	    memories[ a_temp ]--;
	    	    if ((( memories[a_temp] == 0 ) && (type == DSZ)) ||
	    	        (( memories[a_temp] != 0 ) && (type == DSNZ)))
	    	    {
			obj_found = program[program_counter];
		    	if (obj_found == SECOND)
		        {
  			    second_flag = TRUE;
			    bump_ppc();
			    obj_found = program[program_counter];
			}
			do_go_to();
		    }
		    else
		    	bump_ppc();
		}
		else
		    bump_ppc();
		second_flag = FALSE;
		inverse_flag = FALSE;
		break;
	    	
	    case STO:
		bump_ppc();
		obj_found = program[program_counter];
		bump_ppc();
	    	temp1 = make_integer();
		if (temp1 != 10)
		{
		    obj_found = program[program_counter];
		    bump_ppc();
		    temp2 = make_integer();
		    if (temp2 != 10)
		    {
			mem_loc = (temp1 * 10) + temp2;
			to_number(TRUE);
			do_store();
			to_ascii(FALSE);
			enter_exp_flag = FALSE;
			result_flag = TRUE;
			decimal_flag = FALSE;
		    }
		}
		second_flag = FALSE;
		inverse_flag = FALSE;
		break;			
		
	    case RCL:	
		bump_ppc();
		obj_found = program[program_counter];
		bump_ppc();
	    	temp1 = make_integer();
		if (temp1 != 10)
		{
		    obj_found = program[program_counter];
		    bump_ppc();
		    temp2 = make_integer();
		    if (temp2 != 10)
		    {
			mem_loc = (temp1 * 10) + temp2;
			to_number(TRUE);
			if (second_flag != TRUE)
				do_recall();
			else
			{
				to_number(TRUE);
				do_swap();
			}
			to_ascii(FALSE);
			enter_exp_flag = FALSE;
			result_flag = TRUE;
			decimal_flag = FALSE;
		    }
		}
		second_flag = FALSE;
		inverse_flag = FALSE;
		break;			
		
	case SUM:	
		bump_ppc();
		obj_found = program[program_counter];
		bump_ppc();
	    	temp1 = make_integer();
		if (temp1 != 10)
		{
		    obj_found = program[program_counter];
		    bump_ppc();
		    temp2 = make_integer();
		    if (temp2 != 10)
		    {
			mem_loc = (temp1 * 10) + temp2;
			to_number(TRUE);
			if (second_flag != TRUE)
			{
			    if (inverse_flag != TRUE)
				do_sum();
			    else
			    	do_inv_sum();
			}
			else
			{
			    if (inverse_flag != TRUE)
				do_product();
			    else
			    	do_inv_product();
			}
			to_ascii(FALSE);
			enter_exp_flag = FALSE;
			result_flag = TRUE;
			decimal_flag = FALSE;
			redraw();
		    }
		}
		second_flag = FALSE;
		inverse_flag = FALSE;
		break;	
			
	    case XEQT:
	    case XNET:
	    case XLTT:
	    case XGTT:
	    case XGET:
	    case XLET:
	        type = obj_found;
	        to_number(FALSE);	/* Convert current display value */
	        
	    	bump_ppc();		/* Get the label to go to... */
		a_temp = FALSE;
		switch (type){
			case XEQT:
			    if (x_register == t_register)
			    	a_temp = TRUE;
			    break;
			case XNET:
			    if (x_register != t_register)
			    	a_temp = TRUE;
			    break;
			case XLTT:
			    if (x_register < t_register)
			    	a_temp = TRUE;
			    break;
			case XGTT:
			    if (x_register > t_register)
			    	a_temp = TRUE;
			    break;
			case XGET:
			    if (x_register >= t_register)
			    	a_temp = TRUE;
			    break;
			case XLET:
			    if (x_register <= t_register)
			    	a_temp = TRUE;
			    break;
			default:
			    break;
		}
		if (a_temp == TRUE)
		{
		    obj_found = program[program_counter];
		    if (obj_found == SECOND)
		    {
  		  	second_flag = TRUE;
			bump_ppc();
			obj_found = program[program_counter];
		    }
		    do_go_to();
		}
		else
		    bump_ppc();
		second_flag = FALSE;
		inverse_flag = FALSE;
		break;
	    	
	    default:
		do_everything();
		bump_ppc();
		break;
	}
	if (processor_mode == SINGLE_STEP)
		return;
    }
}
/********************
 *
 * SET_LABEL()
 *
 * label map: label_positions[x] =
 *	0 - A
 *	1 - A'
 *	2 - B
 *	3 - B'
 *	4 - C
 *	5 - C'
 *	6 - D
 *	7 - D'
 *	8 - E
 *	9 - E'
 *     10 - SIN
 *     11 - COS
 *     12 - TAN
 *     13 - LNX
 *     14 - LOGX
 *     15 - XSQUARED
 *     16 - ROOTX
 *     17 - ONEOVERX
 *     18 - XXCHANGT
 *     19 - STO
 *     20 - RCL
 *     21 - SUM
 *     22 - YTOTHEX
 *     23 - EQUALS
 *     24 - KPLUS
 *     25 - MINUS
 *     26 - TIMES
 *     27 - DIVIDED
 *     28 - PLUSMINU
 *     29 - KPOINT
 *     30 - KZEROA
 *     31 -> 39 - KONEA -> KNINEA
 *     40 - OPENPARN
 *     41 - CLOSPARN
 *     42 - EE
 */
 
set_label()
{
	int dead_cat, dead_mouse;
	int set_address;

	if (inverse_flag == TRUE)
		set_address = 1001;	/* Clear label out.. */
	else
		set_address = program_counter;

	dead_cat = 1;
	while(dead_cat == 1)
	{
	    monitor_mouse();

	    switch(obj_found){
	    	case KEYA:
			redraw();
	    		if (second_flag != TRUE)
	    			label_positions[0] = set_address;
	    		else
	    			label_positions[1] = set_address;
	    		dead_cat = 0;
	    		break;
	    	case KEYB:
	    		redraw();
	    		if (second_flag != TRUE)
	    			label_positions[2] = set_address;
	    		else
	    			label_positions[3] = set_address;
	    		dead_cat = 0;
	    		break;
	    	case KEYC:
	    		redraw();
	    		if (second_flag != TRUE)
	    			label_positions[4] = set_address;
	    		else
	    			label_positions[5] = set_address;
	    		dead_cat = 0;
	    		break;
	    	case KEYD:
	    		redraw();
	    		if (second_flag != TRUE)
	    			label_positions[6] = set_address;
	    		else
	    			label_positions[7] = set_address;
	    		dead_cat = 0;
	    		break;
	    	case KEYE:
	    		redraw();
	    		if (second_flag != TRUE)
	    			label_positions[8] = set_address;
	    		else
	    			label_positions[9] = set_address;
	    		dead_cat = 0;
	    		break;

		case KEYSIN:
		case KEYCOS:
		case KEYTAN:
		case LNX:
		case LOGX:
		case XSQUARED:
		case ROOTX:
		case ONEOVERX:
		case XXCHANGT:
		case STO:
		case RCL:
		case SUM:
		case YTOTHEX:
		case EQUALS:
		case KPLUS:
		case MINUS:
		case TIMES:
		case DIVIDED:
		case PLUSMINU:
		case KPOINT:
		case KZEROA:
		case KONEA:
		case KTWOA:
		case KTHREEA:
		case KFOURA:
		case KFIVEA:
		case KSIXA:
		case KSEVENA:
		case KEIGHTA:
		case KNINEA:
		case OPENPARN:
		case CLOSPARN:
		case EE:
			redraw();
			for (dead_mouse = 10; dead_mouse <= 42; dead_mouse++)
			{
			    if (label_offset[dead_mouse] == obj_found)
			    	label_positions[dead_mouse] = set_address;
			}
			dead_cat = 0;
			break;

	    	case SECOND:
	    		redraw();
	    		second_flag = TRUE;
	    		break;
	    	default:
	    		dead_cat = 0;
	    		second_flag = FALSE;
	    		break;
	    	}
	}    /* End while(dead_cat == 1) */
}
/********************
 *
 * MONITOR_MOUSE()
 *
 *  Return a mouse press inside a valid button...
 */
 
monitor_mouse()
{
	int  dead_duck;

	dead_duck = 1;

	while(dead_duck)
	{
	  wonger = evnt_multi( MU_BUTTON | MU_KEYBD | MU_MESAG,
		1,1,butt_direction,	/*evnt_button*/
		0,0,0,0,0,		/*evnt_mouse1*/
		0,0,0,0,0,		/*evnt_mouse2*/
		msgbuff,		/*evnt_mesg*/
		100,0,			/*evnt_timer*/
		&mx,&my,		/*mouse x,y*/
		&foobar,		/*mouse button*/
		&foobar,		/*shift keys*/
		&keycode,		/*evnt_keyboard*/
		&foobar);		/*number of clicks*/

	  if ((wonger & MU_BUTTON) &&	/* User clicked on something.. */
	      (butt_direction == DOWN))
	  {
	    butt_direction = UP;
	    obj_found = objc_find(boxadd, CALCPAD, 2, mx, my);
	    dead_duck = 0;
	  }
	  else if ((wonger & MU_BUTTON) &&
	  	   (butt_direction == UP))
	  {
	  	   	butt_direction = DOWN;
	  }
	}
}
/*****************
 *
 * DO_GO_TO()
 *
 */
do_go_to()
{
	int tabby;
	int temp1, temp2, temp3;

	temp1 = FALSE;
	for (tabby = 0; tabby <= 42; tabby++)
	{
	    if (label_offset[tabby] == obj_found)
	    {
	    	bump_ppc();
	    	redraw();
	    	if (second_flag == TRUE)
	    	{
	    		tabby++;
	    		second_flag = FALSE;
	    	}
		if (label_positions[tabby] != 1001)
		{
		    	program_counter = label_positions[tabby];
		    	return;
		}
		else if((tabby >= 30) && (tabby <= 39))
		{
		    program_counter -= 1;
		    break;
		}
	    }
	}
	if (temp1 == FALSE)	/* Then it isn't a label, must be a # */
	{
	    redraw();
	    temp1 = perform_trans();
	    if (temp1 == BOGUS)
	    	return;
	    if (processor_mode == STOPPED)	/* Keyboard... */
	    {
	    	temp2 = get_numb_key();
	    	if ((temp2 == 0x13) ||
	    	    (temp2 == BOGUS))
	    	    	return;
	    	temp3 = get_numb_key();
	    	if ((temp3 == 0x13) ||
	    	    (temp3 == BOGUS))
	    	    	return;
	    	program_counter = temp1 * 100 + temp2 * 10 + temp3;
	    	return;
	    }
	    else				/* From program memory */
	    {
	    	temp2 = build_address();
	    	if (temp2 == BOGUS)
	    		return;
	    	program_counter = temp1 * 100 + temp2;
	    	return;
	    }
	}
}
/***************
 *
 * PERFORM_TRANS()
 *
 */
 
perform_trans()
{
	switch(obj_found){
	    case KZEROA:
	    	return(0);
	    case KONEA:
	    	return(1);
	    case KTWOA:
	    	return(2);
	    case KTHREEA:
	    	return(3);
	    case KFOURA:
	    	return(4);
	    case KFIVEA:
	    	return(5);
	    case KSIXA:
	    	return(6);
	    case KSEVENA:
	    	return(7);
	    case KEIGHTA:
	    	return(8);
	    case KNINEA:
	    	return(9);
	    default:
	    	set_error();
	    	redraw();
	    	return(BOGUS);
	    	break;
	}
	return(BOGUS);
}	
/******************
 *
 * BUILD_ADDRESS()
 *    Builds an address for
 * a running program from a three digit
 * number
 */

build_address()
{
	int temp2, temp3;
	
	bump_ppc();
	obj_found = program[program_counter];
    	temp2 = perform_trans();
    	if (temp2 == BOGUS)
    		return(BOGUS);
	bump_ppc();
	obj_found = program[program_counter];
    	temp3 = perform_trans();
	bump_ppc();
    	if (temp3 == BOGUS)
    		return(BOGUS);
    	return(temp2 * 10 + temp3);
}
/************
 *
 * BUMP_PPC()
 *    Bump program counter
 */
bump_ppc()
{
	if (program_counter <= 998)
		program_counter++;
	old_ppc = program_counter;
}
/*************
 *
 * MAKE_INTEGER()
 *
 */
 
make_integer()
{
	int a_temp;

    	switch(obj_found){
    	    case KZEROA:
    	    	a_temp = 0;
    	    	break;
    	    case KONEA:
    	    	a_temp = 1;
    	    	break;
    	    case KTWOA:
    	    	a_temp = 2;
    	    	break;
    	    case KTHREEA:
    	    	a_temp = 3;
    	    	break;
    	    case KFOURA:
    	    	a_temp = 4;
    	    	break;
    	    case KFIVEA:
    	    	a_temp = 5;
    	    	break;
    	    case KSIXA:
    	    	a_temp = 6;
    	    	break;
    	    case KSEVENA:
    	    	a_temp = 7;
    	    	break;
    	    case KEIGHTA:
    	    	a_temp = 8;
    	    	break;
    	    case KNINEA:
    	    	a_temp = 9;
    	    	break;
    	    default:
    	    	a_temp = 10;
    	    	break;
    	}
    	return(a_temp);
}
/*********************************************
 *
 * DO_FILE_STUFF
 *	Handles the fsel_input end of the program, getting
 * the lesson number...
 *
 */

do_file_stuff()
{
	int	fs_ireturn, fs_iexbutton;
	int	i, j;
	char	new_dir[108];

	new_dir[0] = 0;

	for(i = 0; i <= 107; i++)
	{
		wild_buf[i] = 0;
		tbuf[i] = 0;
	}
			
	cur_drive = Dgetdrv();
	Dgetpath(cur_dir, 0);
	wild_buf[0] = cur_drive + 'A';
	wild_buf[1] = ':';
	strcat(wild_buf, cur_dir);
	strcat(wild_buf, "\\");
	strcat(wild_buf, "*.PGM");

	wind_update(TRUE);	
	fs_ireturn = fsel_input(wild_buf, tbuf, &fs_iexbutton);
	wind_update(FALSE);

	if(fs_ireturn == 0)
	{
		set_error();
		redraw();
	}
	else
	{
		for (i = 0; i <= 107; i++)
		{
			if(wild_buf[i] == 0x2A)	/* asterisk... */
			{
				j = i;
				break;
			}
		}
		for (i = 0; i <= (107 - j); i++)
		{
			wild_buf[i + j] = tbuf[i];
			if(tbuf[i] == 0)
				break;
		}
		for (i = 0; i <= 107; i++)
		{
			tbuf[i] = wild_buf[i];
		}
	}
	return(fs_iexbutton);	
}
/********************
 *
 * LOAD_FILE()
 *
 */
 
load_file()
{
    int i;

    i = do_file_stuff();
    if (i == F_OK)
    {
	f_handle = Fopen(&tbuf[0], 0);
	if (f_handle < 0)
	{
	   i = sho_1form(FILERROR, T2OBJ);
	   return;
	}
	else
	{
	    i = Fread(f_handle, 2000L, program);
	    if (i != 2000)
	    {
	   	i = sho_1form(FILERROR, T2OBJ);
	   	Fclose(f_handle);
	   	return;
	    }
	    i = Fread(f_handle, 100L, label_positions);
	    if (i != 100)
	    {
	   	i = sho_1form(FILERROR, T2OBJ);
	    }
	    Fclose(f_handle);
	}
    }
}
/********************
 *
 * SAVE_FILE()
 *
 */
 
save_file()
{
    int i;

    i = do_file_stuff();
    if (i == F_OK)
    {
	f_handle = Fcreate(&tbuf[0], 0);
	if (f_handle < 0)
	{
	   i = sho_1form(FILERROR, T2OBJ);
	   return;
	}
	else
	{
	    i = Fwrite(f_handle, 2000L, program);
	    if (i != 2000)
	    {
		i = sho_1form(FILERROR, T2OBJ);
		Fclose(f_handle);
		return;
	    }
	    i = Fwrite(f_handle, 100L, label_positions);
	    if (i != 100)
	    {
		i = sho_1form(FILERROR, T2OBJ);
	    }
	    Fclose(f_handle);
	}
    }
}
