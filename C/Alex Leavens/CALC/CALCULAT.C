/*
 * CALCULAT.C
 *
 * Programmable scientific desk calculator
 * desk accessory
 *
 * by Alex Leavens, for START Magazine
 * Rev. 1.052887
 *
 * M-M-M-Max Headroom here--we
 * we
 * we in-in-in-interrupt
 * this comment--
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
/*******
#include "calcdefn.h"
********/

#define YROOTX  999

#define READ_FILE 10
#define WRITE_FILE 11

extern int	gl_apid;	/* system id */
extern char	*fcvt();	/* floating point conversion */
extern char	*gcvt();
extern char 	*ecvt();

extern int		errno;		/* UNIX emulation system error */
extern int	label_offset[];
extern char	*operands[];
extern char	*oper_codes[];

long menuadd;
long boxadd;
OBJECT *rsc_pointer;
TEDINFO *ted_pointer;
TEDINFO *ted2_pointer;

int	msgbuff[8];	/* event message buffer */
int	keycode;	/* keycode returned by event-keyboard */
int	mx,my;		/* mouse x and y pos. */
int	butdown;	/* button state tested for, UP/DOWN */
int	ret;		/* dummy return variable */
int	dummy;		/* another dummy return variable */
int	i;

int	f_handle;
int     cur_drive;
char    cur_dir[68];
char	tbuf[108];	/* Strings for handling string input	*/
char	path_buf[108];	/* stuff...				*/
char	wild_buf[108];

int	key_trans[10]={
	KZEROA,
	KONEA,
	KTWOA,
	KTHREEA,
	KFOURA,
	KFIVEA,
	KSIXA,
	KSEVENA,
	KEIGHTA,
	KNINEA
};

double	pi = 3.14159265358979;

/********************* Calculator related variables ********/

int	orig_stack_pointer;	/* original stack pointer value    */
int	ted_index;		/* How many digits in the display? */
int	decimal_flag;		/* has the '.' key been pressed?   */
int	exp_flag;		/* Exponent on?			   */
int	enter_exp_flag;		/* Just hit the EE key?		   */
int	result_flag;		/* has a result been generated?    */
int	error_flag;		/* Error occurred?		   */
int	exponent_value;		/* Value of the exponent...	   */
int	processor_mode;		/* Calculating or processing       */

int	label_positions[50];	/* label addresses...		   */
int	subroutine_stack[30];	/* Subroutine return addresses...  */
int	sub_stack_pointer;	/* Pointer to next open subroutine */

double	x_register;		/* Initial (immediate) register    */
double  t_register;		/* Test register		   */

int	recursion_level;	/* Number of recursive calls	   */

struct stack_frame {
	double	math_value;
	int	op_code;
} math_stack[10][100];

int	stack_level;		/* Which stack frame?		   */
int	stack_pointer[10];	/* Pointer to stack stuff... 	   */
int	parens;			/* Number of    open parentheses   */

char	converter[50];		/* Array for converting to/from    */
				/* Numbers to ASCII		   */

int	trig_flag;		/* Degree or radian mode?	   */

int	program_counter;	/* Where am I?	*/
int	old_ppc;

int 	editing, obj_found;
int 	wonger;
int 	foobar;
int 	tick;
int 	x,y,w,h;
int 	what_tree, tree_offset;
int 	second_flag;		/* 2nd Key pressed ? */
int	inverse_flag;		/* Inverse key pressed ? */
char 	is_key;
int 	butt_direction;		/* Direction of mouse button in event */

int	mem_loc;		/* Pointer to memory location */
int	program_pointer;	/* Program to next step in memory */
int	flags[10];		/* Flag registers 	*/
double	memories[100];		/* Data Memories... */
int	program[1000];		/* program memory */

char	temp1, temp2;		/* You're not serious... */

/******* End Calculator related variables ********/


int	xdesk, ydesk, wdesk, hdesk;	/* window variables */
int	xwork, ywork, wwork, hwork;	/* workstation sizes */
int 	xleft, yleft, wleft, hleft;	/* window size 	*/
int	xmunge, ymunge, wmunge, hmunge; /* window interior size */
int 	xdial,ydial,wdial,hdial;

int	hidden;		/* state of mouse pointer */

int	num_colors;		/* number of possible screen colors */
int	xres, yres;		/* screen x and y resolutions	    */
int	nplanes;		/* number of planes of the screen   */

int	handle;		/* system handle */
int	wi_handle;	/* window handle */

int	gl_hchar;
int	gl_wchar;
int	gl_wbox;
int	gl_hbox;	/* system sizes */

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];	/* storage wasted for idiotic bindings */

int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */
int pxyarray[10];	/* input point array */

/******************************
 *
 * MAIN()
 *   Driver module for the calculator...
 *
 */

main()
{
	int i;
	int fur_ball;
	int event;
	int menu_id;	/* Program's desk acc handle */

	appl_init();
	handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);

	/* Now determine if calculator can run (lo res, it can't)  */


	/* Load the calculator into the accessory bar... */

	menu_id = menu_register(gl_apid,"  START Calc ");
	if(menu_id == -1)
	{
		i = form_alert(1, "[3][ERROR! No accessory slots left | for the Calculator!][ What a drag...]");
		goto exit;
	}

	/* Get the resource for the program... */

	i = rsrc_load("STRTCALC.RSC");
	if (i == 0)
	{
	    i = form_alert(1, "[3][ERROR! STRTCALC.RSC not found!|The calculator won't run | without it!][ Bummer... ]");
	    goto exit;
	}

	rsrc_gaddr(0, CALCPAD, &menuadd);
	rsc_pointer = (OBJECT *)menuadd;

	hidden = FALSE;
	trig_flag = DEGREES;
	clear_memories();
	clear_program();

run_time:

	while(1)
	{
	  event = evnt_multi(MU_MESAG,
		  1,1,1,
		  0,0,0,0,0,
		  0,0,0,0,0,
		  msgbuff,
		  0,0,
		  &dummy, &dummy, &dummy,
		  &dummy, &dummy, &dummy);

	  if (event & MU_MESAG)
	  {
	      switch(msgbuff[0]){

		case AC_OPEN:
			if (msgbuff[4] == menu_id)
			{
do_it_again:		    i = do_pad();
			    fur_ball = FALSE;
			    switch(i){
			    	case TRUE:
			    	    i = sho_1form(ABOUTCAL, T1OBJ);
			    	    break;
			    	case READ_FILE:
			    	    load_file();
			    	    break;
			    	case WRITE_FILE:
			    	    save_file();
			    	    break;
			    	default:
			    	    fur_ball = TRUE;
			    	    break;
			    }
			    if (fur_ball != TRUE)
				goto do_it_again;
			}
			break;

		default:
			break;
		}
	  }
	}

	goto run_time;	/* Shouldn't get to here, but if it does, */
			/* restart the desk acc...		  */


exit:	goto exit;	/* Do nothing... */

}
/*page*/
/******************************
 *
 * OPEN_VWORK()
 * Open a virtual workstation to the
 * screen...
 *
 */
open_vwork()
{
	int i;

	for( i = 0; i < 10; work_in[i++] = 1);
	work_in[10]=2;
	v_opnvwk(work_in,&handle,work_out);

	num_colors = work_out[13];
	xres=work_out[0]+1;
	yres=work_out[1]+1;
	vq_extnd(handle,1,work_out);
	nplanes=work_out[4];


}
/*page*/
/****************************
 *
 * SHO_1OBJMENU()
 *
 * Handles the actual calculator keypad...
 *
 */

sho_1objmenu()
{
	what_tree = CALCPAD;
	tree_offset = T0OBJ;
		
	graf_mouse(0,&dummy);

	x=y=w=h=0;	/* variables for growbox */

	ted2_pointer = (TEDINFO *)rsc_pointer[tree_offset + CDISPLAY].ob_spec;

	for (i = 0; i <= 25; i++)
	    ted2_pointer->te_ptext[i] = 0x20;

	ted2_pointer->te_ptext[21] = '0';
	ted2_pointer->te_ptext[26] = 0;

	/* Set up various variables used for things */
	
	ted_index = 21;
	program_counter = 0;
	decimal_flag = FALSE;
	exp_flag = FALSE;
	processor_mode = STOPPED;
	result_flag = FALSE;
	error_flag = FALSE;
    	enter_exp_flag = FALSE;
	clear_calc();

	for (i = 0; i <= 9; i++)
	    stack_pointer[0] = 0;
	
	/* get address of parent object */
	rsrc_gaddr(0, CALCPAD, &boxadd);

	/* find out the size and position of a centered box */
	form_center ( boxadd, &xdial, &ydial, &wdial, &hdial );

	/* reserve room on the screen */
	form_dial ( 0, x, y, w, h, xdial, ydial, wdial, hdial );

	/* allow user input */
	editing = TRUE;
	tick = 0;
	butt_direction = DOWN;
	
	while(editing)
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
	    
	    if (error_flag != TRUE)
	    {
	      i = do_everything();
	      switch(i){
	      	case TRUE:
	      	case READ_FILE:
	      	case WRITE_FILE:
	      	    return(i);
	      	default:
	      	    break;
	      }

	      /* Check for calculation overflow here... */
	    
	      if ((errno == ERANGE) || (errno == EDOM))
	      {
	      		errno = 0;
	      		set_error();
	      		redraw();
	      }
	      
	      if ((obj_found != -1) && (obj_found != 0))
	      {
		  /* redraw the dialog box, to update changes to the screen */
		  wind_update(TRUE);
		  objc_draw (boxadd, obj_found, 2, 
				xdial, ydial, wdial, hdial );
		  wind_update(FALSE);
	      }
	    } /* End if (error_flag != TRUE) */

	    else	/* Error flag is set, only key allowed is CLR */
	    		/* Oh, yeah, OFF is ok, too. 		      */
	    {
	      switch(obj_found){
		case CALCOFF:
			editing = FALSE;
			break;

		case CLEAR:
			clear_calc();
			redraw();
			break;
		default:
			break;
		}
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
		    editing = 0;
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
		dummy = keycode & 0xFF;	/* First test for number keys... */
		
		switch(dummy){
			
		case 'S':
		case 's':
			processor_mode = SINGLE_STEP;
			run_calc();
			processor_mode = STOPPED;
			redraw();
			break;

		case 'C':
		case 'c':
			clear_calc();
			redraw();
			break;
			
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			obj_found = key_trans[dummy - '0'];
			do_keys(TRUE);
			break;
		case '.':
			obj_found = KPOINT;
			do_keys(TRUE);
			break;
		case '+':
			do_plus();
			break;
		case '-':
			do_minus();
			break;
		case '/':
			do_divided();
			break;
		case '*':
			do_times();
			break;
		case '(':
			do_open_parn();
			break;
		case ')':
			do_close_parn();
			break;
		case '=':
		case 0x0D:
			do_equals();
			break;
		default:
			obj_found = 0;
			redraw();
			break;
		}
	  }

	} /* end while(editing)	*/

	/* draw shrinking box */
	form_dial ( 2, x, y, w, h, xdial, ydial, wdial, hdial ); 

	/* free up screen area */
	form_dial ( 3, x, y, w, h, xdial, ydial, wdial, hdial ); 

	return(FALSE);
}
/*page*/
/********************
 *
 * DO_PAD()
 *    Starts up the calculator pad...
 *
 */

do_pad()
{
	int temp[4];
	int bug_puss;

	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	open_vwork();
        open_window();
	graf_mouse(ARROW,0x0L);

    if (nplanes >= 3)
    {
	    i = form_alert(1, "[3][Note! The calculator does not run | in this resolution.][ What a drag...]");
	    wind_close(wi_handle);
	    graf_shrinkbox(xwork+wwork/2,ywork+hwork/2,gl_wbox,gl_hbox,
      	 	       xleft,yleft,wleft,hleft);
	    wind_delete(wi_handle);
	    v_clsvwk(handle);
	    return(FALSE);
    }

    else
    {

	hide_mouse();
	vsf_interior(handle, 1);
	vsf_color(handle, 0);
	vswr_mode(handle, 1);
	temp[0]=xmunge;
	temp[1]=ymunge;
	temp[2]=xmunge + wmunge-1;
	temp[3]=ymunge + hmunge-1;
	v_bar(handle,temp);		/* blank the interior */
	show_mouse();

	bug_puss = sho_1objmenu();

	wind_close(wi_handle);
	graf_shrinkbox(xwork+wwork/2,ywork+hwork/2,gl_wbox,gl_hbox,
      	 	       xleft,yleft,wleft,hleft);
	wind_delete(wi_handle);
	v_clsvwk(handle);
	return(bug_puss);
    } 
}
/*page*/
/********************************
 *
 * OPEN_WINDOW()
 * Open the calculator window
 *
 */
open_window()
{
	form_center ( menuadd, &xmunge, &ymunge, &wmunge, &hmunge );

	wi_handle=wind_create(WI_KIND,xdesk,ydesk,wdesk,hdesk);

	wind_calc(0, WI_KIND, xmunge, ymunge, wmunge, hmunge,
		  &xleft, &yleft, &wleft, &hleft);

	wind_set(wi_handle, WF_NAME, " The START Scientific Calculator ",0,0);

	graf_growbox(xdesk+wdesk/2,ydesk+hdesk/2,gl_wbox,gl_hbox,
			xleft,yleft,wleft,hleft);

	wind_open(wi_handle,xleft,yleft,wleft,hleft);
}
/***************************
 *
 * Utility routines to hide and
 * show the mouse...
 */

hide_mouse()
{
	if(! hidden){
		graf_mouse(M_OFF,0x0L);
		hidden=TRUE;
	}
}

show_mouse()
{
	if(hidden){
		graf_mouse(M_ON,0x0L);
		hidden=FALSE;
	}
}

/*********************
 *
 * CLEAR_CALC()
 *
 * Clears the calculator, zeroes out the
 * stack, and all register variables.
 * Does not clear program or data memories
 *
 */
 
clear_calc()
{
	int i,j;

	t_register = 0;
	
	for (j = 0; i <= 9; j++)
	{
	    for (i = 0; i <= 99; i++)
	    {
		math_stack[j][i].math_value = 0.0;
		math_stack[j][i].op_code = 0;
	    }
	}

	stack_level = 0;

	for (i = 0; i <= 25; i++)
	    ted2_pointer->te_ptext[i] = 0x20;

	for (i = 0; i <= 9; i++)
	    stack_pointer[0] = 0;

	parens = 0;

	ted2_pointer->te_ptext[21] = '0';
	ted2_pointer->te_ptext[26] = 0;

	ted_index = 21;
	decimal_flag = FALSE;
	exp_flag = FALSE;
	result_flag = FALSE;
	error_flag = FALSE;
    	enter_exp_flag = FALSE;
}

/**********************
 *
 * CLEAR_ENTRY()
 *   Clears the X register
 *
 */
 
clear_entry()
{
	int i;

	if (result_flag == TRUE)
		return;

	for (i = 0; i <= 25; i++)
	    ted2_pointer->te_ptext[i] = 0x20;

	ted2_pointer->te_ptext[21] = '0';
	ted2_pointer->te_ptext[26] = 0;

	ted_index = 21;
	decimal_flag = FALSE;
	exp_flag = FALSE;
	result_flag = FALSE;
	error_flag = FALSE;
    	enter_exp_flag = FALSE;
}

/****************************
 *
 * REDRAW()
 *   Redraw the calculator display panel
 *
 */
 
redraw()
{
	if (processor_mode == RUNNING)
		return;
	wind_update(TRUE);
	hide_mouse();
	objc_draw (boxadd, CDISPLAY, 2, 
		   xdial, ydial, wdial, hdial );
	show_mouse();
	wind_update(FALSE);
}

/*********************
 *
 * TO_NUMBER()
 *   Converts the display into 
 * a floating point number...
 *
 */
 
to_number(pop_flag)
int	pop_flag;
{
    int i;
   
    for (i = 0; i <= 16; i++)
    	converter[i] = ted2_pointer->te_ptext[i + 5];

    if (exp_flag == TRUE)
    {
    	converter[17] = 'E';
    	if (ted2_pointer->te_ptext[23] == '-')
    	{
    		converter[18] = '-';
    		converter[19] = ted2_pointer->te_ptext[24];
    		converter[20] = ted2_pointer->te_ptext[25];
    	}
    	else
    	{
    		converter[18] = ted2_pointer->te_ptext[24];
    		converter[19] = ted2_pointer->te_ptext[25];
    	}
    }
    		
    if (decimal_flag = TRUE)
    	x_register = (double) atof(converter);
    else
    	x_register = (double) atol(converter);

    /* Now, check to see if we stick this value into the */
    /* first location of the stack.  For immediate mode  */
    /* calls, the answer is yes (ie, 1/x, log(x), etc.)  */
    /* For extended mode calls, (ie, 2 * 3), the initial */
    /* entry on the stack contains the _first_ value,    */
    /* which we do not want to overwrite, thus we won't  */
    /* push this value there.				 */

    if (pop_flag == TRUE)
    {
    	math_stack[stack_level][stack_pointer[stack_level]].math_value = x_register;
    	math_stack[stack_level][stack_pointer[stack_level]].op_code = NO_OP;
    }
}
/**********************
 *
 * TO_ASCII()
 *   Converts the X register to
 * an ASCII representation...
 *
 */
 
to_ascii(stfm_flag)
int stfm_flag;
{
	double  real_x;
	int	a, b, i;
	int	sign, position;
	char    *upsy;
	int	offset;
char	who_am_i[16];

	/* Clear exponent area... */

	for (i = 0; i < 4; i++)
		ted2_pointer->te_ptext[22 + i] = ' ';

	for (i = 0; i < 25; i++)
		converter[i] = 0x20;

who_am_i[15] = 0;

	if(stfm_flag == FALSE)
	{
		real_x = 
			math_stack[stack_level]
				  [stack_pointer[stack_level]].math_value;
	}
	else
	{
	    if (stack_pointer[stack_level] == 0)
		real_x = math_stack[stack_level][0].math_value;
	    else
		real_x = 
			math_stack[stack_level]
				  [stack_pointer[stack_level] - 1].math_value;
	}

	upsy = ecvt(real_x, 15, &position, &sign);

	if (sign == 0)
	{
	    offset = 0;
	}
	else
	{
	    converter[0] = '-';
	    offset = 1;
	}

	/* No exponent need if within 15... */
	/* and not in EE mode... 	    */
	
	if (((position < 10) && (position > -10)) && (exp_flag != TRUE))
	{
	    for (i = 0; i < 4; i++)
	    	ted2_pointer->te_ptext[22+i] = ' ';
	    if (position > 0)
	    {
		for (i = 0; i < position; i++)
			converter[i] = *(upsy++);
		converter[position] = '.';
		for (i = position + 1; i < 15; i++)
		    converter[i] = *(upsy++);
	    }
	    else if (position <  0)
	    {
	    	position *= -1;
	    	converter[0] = '.';
	    	for (i = 0; i < position; i++)
	    		converter[i+1] = '0';
	    	for (i = position; i < 15; i++)
	    		converter[i+1] = *(upsy++);
	    }
	    else
	    {
	    	converter[0] = '.';
		for (i = 1; i <= 15; i++)
		    converter[i] = *(upsy++);
	    }
	    	
	}

	/* Exponent present, so let's convert it... */
	
	else
	{
	    exp_flag = TRUE;
	    converter[offset] = *(upsy++);
	    converter[offset+1] = '.';
	    for (i = offset+2; i <= 15; i++)
	        converter[i] = *(upsy++);
	    position--;
	    if (position < 0)
	    {
	    	ted2_pointer->te_ptext[23] = '-';
	    	position *= -1;
	    }
	    else
	    	ted2_pointer->te_ptext[23] = ' ';

	    i = position;
	    if ((i >= 100) || (i <= -100))
	    {
	    	errno = ERANGE;
	    	return;
	    }

	    if (i < 0)
	    	i *= -1;
	    a = 0;
	    while(i > 10)
	    {
		a++;
	    	i -= 10;
	    }
	    ted2_pointer->te_ptext[24] = '0' + a;
	    ted2_pointer->te_ptext[25] = '0' + i;
	    exponent_value = position;
	    position = 1;
	    	    
	}

	/* Now examine everything right of the decimal point */

	a = TRUE;
	for (i = 14; i > position; i--)
	{
	    if (converter[i] != '0')
	    {
    		a = FALSE;
	    	b = i;
	    	break;
	    }
	}

	for (i = 0; i <= 21; i++)
		ted2_pointer->te_ptext[i] = 0x20;

	if (a == TRUE)
	{
	    b = 21;
	    for (i = position; i >= 0; i--)
		ted2_pointer->te_ptext[b--] = converter[i];
	    if (sign != 0)
	    	ted2_pointer->te_ptext[b] = '-';
	}
	else
	{
	    a = 21;
	    for (i = b; i >= 0; i--)
		ted2_pointer->te_ptext[a--] = converter[i];
	    if (sign != 0)
	    	ted2_pointer->te_ptext[a] = '-';
	}

	/* Check for real zero... */
	if (real_x == 0)
	{
		ted2_pointer->te_ptext[20] = '0';
		ted2_pointer->te_ptext[21] = '.';
	}
}
/**********************
 *
 * NATURAL()
 *   Calculate the natural
 * (base e) log of a number
 *
 */
 
natural()
{
    math_stack[stack_level][stack_pointer[stack_level]].math_value = 
    			log( math_stack[stack_level][stack_pointer[stack_level]].math_value );
}
/*****************
 *
 * INV_NATURAL()
 *    e to the x...
 */
 
inv_natural()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			exp(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/***************
 *
 * INV_COMMON()
 *   10 to the x (inverse of common log)
 */
 
inv_common()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			pow(10.0, math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/***********************
 *
 * SET_ERROR()
 *   The user has attempted to
 * calculate an invalid number
 * (ie, log of a negative number)
 *
 */
 
set_error()
{
	int i;
	
	for (i = 0; i <= 25; i++)
	    ted2_pointer->te_ptext[i] = 0x20;


	ted2_pointer->te_ptext[15] = 'E';
	ted2_pointer->te_ptext[16] = 'R';
	ted2_pointer->te_ptext[17] = 'R';
	ted2_pointer->te_ptext[18] = 'O';
	ted2_pointer->te_ptext[19] = 'R';

	ted2_pointer->te_ptext[26] = 0;

	error_flag = TRUE;

	processor_mode = STOPPED;
}
/**********************
 *
 * SQUARE()
 *   Square x...
 *
 */
 
square()
{	
	double faces;

	faces = math_stack[stack_level][stack_pointer[stack_level]].math_value;
	math_stack[stack_level][stack_pointer[stack_level]].math_value = pow(faces, 2.0);
}
/**********************
 *
 * SQUARE_ROOT()
 *	square root of x
 */
 
square_root()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			sqrt(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/******************
 *
 * COMMON()
 *   Common log of x
 *
 */
 
common()
{
    math_stack[stack_level][stack_pointer[stack_level]].math_value = 
    			log10( math_stack[stack_level][stack_pointer[stack_level]].math_value );
}	
/*******************
 *
 * ONE_OVER
 *    1/x
 *
 */
 
one_over()
{
	if (math_stack[stack_level][stack_pointer[stack_level]].math_value <= 0)
		errno = ERANGE;
	else
		math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			1 / math_stack[stack_level][stack_pointer[stack_level]].math_value;
}
/****************
 *
 * SINX()
 *
 */
 
sinx()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			sin(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/**************
 *
 * ASINX()
 */

asinx()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			asin(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/***************
 *
 * COSX()
 *
 */
 
cosx()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			cos(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/*****************
 *
 * ACOSX()
 */
 
acosx()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			acos(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/****************
 *
 * TANX
 *  You're welcome...
 */
 
tanx()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			tan(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/**************
 *
 * ATANX()
 *   and Btanks, too...
 */
 
atanx()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			atan(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/*********************
 *
 * ABSOLUTE()
 *
 */
 
absolute()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			fabs(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/*********************
 *
 * GET_INTEGER()
 *
 */
 
get_integer()
{
	double intgral, real;
	
	real = modf(math_stack[stack_level][stack_pointer[stack_level]].math_value, &intgral);
	math_stack[stack_level][stack_pointer[stack_level]].math_value = intgral;
}
/******************
 *
 * CLEAR_TED()
 *    Clears tedinfo structure
 *
 */
 
clear_ted()
{
	int i;

	for (i = 5; i <= 21; i++)
		ted2_pointer->te_ptext[i] = 0x20;
}
/**************************
 *
 * DO_KEYS()
 *
 * Processes a key for a numeric entry...
 *
 */
 
do_keys(into_display)
int	into_display;	/* If TRUE, display it, else, just return */
{
	switch(obj_found){

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
	case KPOINT:
		switch(obj_found){
			case KZEROA:
				is_key = '0';
				break;
			case KONEA:
				is_key = '1';
				break;
			case KTWOA:
				is_key = '2';
				break;
			case KTHREEA:
				is_key = '3';
				break;
			case KFOURA:
				is_key = '4';
				break;
			case KFIVEA:
				is_key = '5';
				break;
			case KSIXA:
				is_key = '6';
				break;
			case KSEVENA:
				is_key = '7';
				break;
			case KEIGHTA:
				is_key = '8';
				break;
			case KNINEA:
				is_key = '9';
				break;
			case KPOINT:
				if (decimal_flag != TRUE)
				{
				    is_key = '.';
				    decimal_flag = MAYBE;
				}
				break;
			}

		if (into_display == FALSE)	/* Just wanted the key... */
						/* thanks, anyway... */
			return;

		/* Ok, still room in display... */
		/* for this digit... 	        */

		if (ted_index > 5)
		{
		  /* If key wasn't decimal point, do it... */
		  
		  if(obj_found != KPOINT)
		  {
		    if (result_flag == ALL_DONE)
		    {
		    	stack_pointer[stack_level] = 0;
		    	result_flag = TRUE;
		    }
		    if (enter_exp_flag == TRUE) /* Number goes in */
		    {				/* exponent field */
		      ted2_pointer->te_ptext[24] = 
		      			ted2_pointer->te_ptext[25];
		      ted2_pointer->te_ptext[25] = is_key;
		    }
		    else			/* Number goes in */
		    {				/* number field   */
		      if (result_flag == TRUE)  /* Previous result */
		      {
		     	ted_index = 21;
		     	for (i = 5; i <= 21; i++)
		     		ted2_pointer->te_ptext[i] = 0x20;
		     	result_flag = FALSE;
		      }
		      if (ted_index != 21)
		      {
		        for (i = 5; i < 21; i++)
		        {
		    	  ted2_pointer->te_ptext[i] = 
		    		    ted2_pointer->te_ptext[i + 1];
		        }
		      }
		      ted2_pointer->te_ptext[21] = is_key;
		      ted_index--;
		    }
		  }

		  /* Ok, key _was_ decimal point.  Did they */
		  /* already enter one?			    */

		  else
		  {
		    if (decimal_flag == MAYBE)
		    {
		    	enter_exp_flag = FALSE;
		    	decimal_flag = TRUE;
		    	if (result_flag == TRUE)
		    	{
		    		ted_index = 21;
		    		result_flag = FALSE;
		    		clear_ted();
		    		ted2_pointer->te_ptext[20] = '0';
		    		ted2_pointer->te_ptext[21] = '.';
		    		ted_index -= 2;
		    		redraw();
		    		return;
		    	}
		    	if (ted_index != 21)
		    	{
		          for (i = 5; i < 21; i++)
		          {
		    		ted2_pointer->te_ptext[i] = 
		    		    ted2_pointer->te_ptext[i + 1];
		          }
		        }
		        ted2_pointer->te_ptext[21] = is_key;
		        ted_index--;
		    }
		  }
		}
		redraw();
		break;
	default:
		break;
	}
}
/********************
 *
 * DO_PI()
 */
 
do_pi()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = pi;
}
/******************
 *
 * EXCHANGE()
 *
 */
 
exchange()
{
    double my_temp;
	
    my_temp = math_stack[stack_level][stack_pointer[stack_level]].math_value;
    math_stack[stack_level][stack_pointer[stack_level]].math_value = t_register;
    t_register = my_temp;
}
/*******************
 *
 * DO_STORE()
 *
 */
 
do_store()
{
	memories[mem_loc] = math_stack[stack_level][stack_pointer[stack_level]].math_value;
}
/***************
 *
 * DO_RECALL()
 */
 
do_recall()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = memories[mem_loc];
}
/**************
 *
 * DO_SWAP()
 */
 
do_swap()
{
	double face_ball;

	face_ball = math_stack[stack_level][stack_pointer[stack_level]].math_value;
	math_stack[stack_level][stack_pointer[stack_level]].math_value = memories[mem_loc];
	memories[mem_loc] = face_ball;
}
/*************
 *
 * DO_SUM()
 */
 
do_sum()
{
	memories[mem_loc] += math_stack[stack_level][stack_pointer[stack_level]].math_value;
}
/**********
 *
 * DO_PRODUCT()
 */
 
do_product()
{
	memories[mem_loc] *= math_stack[stack_level][stack_pointer[stack_level]].math_value;
}
/**********
 *
 * DO_INV_SUM()
 */
 
do_inv_sum()
{
	memories[mem_loc] -= math_stack[stack_level][stack_pointer[stack_level]].math_value;
}
/***********
 *
 * DO_INV_PRODUCT()
 */
 
do_inv_product()
{
	memories[mem_loc] /= math_stack[stack_level][stack_pointer[stack_level]].math_value;
}
/************
 *
 * MON_KEYS()
 *   Monitors keys--must be a numeric entry ONLY
 *
 */
 
mon_keys()
{
butt_direction = UP;

while(1)
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
		&keycode,		/*keystroke */
		&foobar);		/*number of clicks*/

  if ((wonger & MU_BUTTON) &&	/* User clicked on something.. */
      (butt_direction == DOWN))
  {
   butt_direction = UP;
   obj_found = objc_find(boxadd, CALCPAD, 2, mx, my);
    
   switch(obj_found){

	case CLEAR:
		clear_calc();
		redraw();
		is_key = 'C';
		break;
		
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
		do_keys(FALSE);
		break;
	default:
		is_key = '.';
		break;
	}
     break;
   }
   else if ((wonger & MU_BUTTON) && (butt_direction == UP))
   {
   	butt_direction = DOWN;
   }
   else if (wonger & MU_KEYBD)
   {
   	dummy = keycode & 0xFF;
	switch(dummy){
			
	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
		obj_found = key_trans[dummy - '0'];
		do_keys(FALSE);
		break;

	default:
		is_key = '.';
		break;
	}
	break;
   }

   else
   {
   	is_key = '.';
   	break;
   }
}
   return(is_key);
}

/***************
 *
 * TO_DEGREES()
 *
 */
 
to_degrees()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			180 / pi * math_stack[stack_level][stack_pointer[stack_level]].math_value;
}
/**************
 *
 * TO_RADIANS()
 *
 */
 
to_radians()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			(pi * math_stack[stack_level][stack_pointer[stack_level]].math_value) / 180;
}
/***************
 *
 * ANGLE_CONVERT()
 *
 */
 
angle_convert()
{
	if (trig_flag == DEGREES)
		to_radians();
}
/*****************
 *
 * ANGLE_DECONVERT()
 *
 */
 
angle_deconvert()
{
	if (trig_flag == DEGREES)
		to_degrees();
}
/**************
 *
 * SINH()
 *
 */
 
sinhyp()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			sinh(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/************
 *
 * COSH()
 */
 
coshyp()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			cosh(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/************
 *
 * TANH()
 */
 
tanhyp()
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
			tanh(math_stack[stack_level][stack_pointer[stack_level]].math_value);
}
/***********
 *
 * INV_SINH()
 *   inverse hyperbolic sin
 */
 
inv_sinh()
{
	double late_temp;

	late_temp = sqrt(math_stack[stack_level][stack_pointer[stack_level]].math_value * 
		    math_stack[stack_level][stack_pointer[stack_level]].math_value + 1);
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
		log(math_stack[stack_level][stack_pointer[stack_level]].math_value + late_temp);
}
/************
 *
 * INV_COSH()
 */
 
inv_cosh()
{
	double late_temp;

	if (math_stack[stack_level][stack_pointer[stack_level]].math_value < 1)
	{
		errno = ERANGE;
		return;
	}
	late_temp = sqrt(math_stack[stack_level][stack_pointer[stack_level]].math_value * 
			math_stack[stack_level][stack_pointer[stack_level]].math_value - 1);
	math_stack[stack_level][stack_pointer[stack_level]].math_value = 
		log(math_stack[stack_level][stack_pointer[stack_level]].math_value + late_temp);
}
/***********
 *
 * INV_TANH()
 */
 
inv_tanh()
{
	if ((math_stack[stack_level][stack_pointer[stack_level]].math_value <= -1) || 
	    (math_stack[stack_level][stack_pointer[stack_level]].math_value >= 1))
	{
		errno = ERANGE;
		return;
	}

	math_stack[stack_level][stack_pointer[stack_level]].math_value = .5 * 
		log((1 + math_stack[stack_level][stack_pointer[stack_level]].math_value) /
		(1 - math_stack[stack_level][stack_pointer[stack_level]].math_value));
}

/****************
 *
 * PUSH_STACK()
 *   Pushes an operation (and associated value)
 * onto the stack.
 */
 
push_stack(op_code_is)
int op_code_is;
{
	math_stack[stack_level][stack_pointer[stack_level]].math_value = x_register;
	math_stack[stack_level][stack_pointer[stack_level]].op_code = op_code_is;

	stack_pointer[stack_level]++;
	/* Check for stack overflow... */
	if (stack_pointer[stack_level] >= 100)
	{
		errno = EDOM;
		set_error();
	}
}
/****************
 *
 * CLEAR_MEMORIES()
 *	Clear memory registers
 */
 
clear_memories()
{
	int i;

	for (i = 0; i <= 99; i++)
		memories[i] = 0;
}
/******************
 *
 * CLEAR_PROGRAM()
 */
clear_program()
{
	int i;

	for (i = 0; i <= 999; i++)
		program[i] = 1000;
	for (i = 0; i <= 49; i++)
		label_positions[i] = 1001;
	for (i = 0; i <= 29; i++)
		subroutine_stack[i] = 1001;
	sub_stack_pointer = 0;

	for (i = 0; i <= 9; i++)
		flags[i] = IS_CLEAR;
}		
/*****************
 *
 * EVALUATE_STACK()
 *	Dig through the stack frame,
 * and see how much of it we can
 * evaluate...
 * TIMES
 * DIVIDED
 * KPLUS
 * MINUS
 */
 
evaluate_stack(stack_phooey)
int stack_phooey;
{
	int	i;
	int	prev_op, next_op;
	int	equals_flag;
	int	evaluate_it;
	int	pointer_level;
	double	temporary;
	int	loop_control;

	if (recursion_level > 40)
	{
	    i = form_alert(1, "[3][FATAL! Stack overflow | in _evaluate_stack_ ][ What a drag...]");
	    errno = ERANGE;
	    return;
	}
	recursion_level++;

	equals_flag = FALSE;

	pointer_level = stack_pointer[stack_level];
	for (loop_control = 0; loop_control < 100; loop_control++)
	{
		switch(math_stack[stack_level][stack_phooey].op_code){
			case EQUALS:
			    prev_op = stack_phooey - 1;
			    if (prev_op >= 0)
			    {
			      if ((math_stack[stack_level][prev_op].op_code == TIMES) ||
				  (math_stack[stack_level][prev_op].op_code == DIVIDED) ||
				  (math_stack[stack_level][prev_op].op_code == KPLUS) ||
				  (math_stack[stack_level][prev_op].op_code == MINUS) ||
				  (math_stack[stack_level][prev_op].op_code ==  YROOTX) ||
				  (math_stack[stack_level][prev_op].op_code == YTOTHEX))
				  {
				      stack_phooey = 
				      	    evaluate_stack(stack_phooey - 1);
				      if ((math_stack[stack_level][0].op_code == EQUALS) &&
				          (math_stack[stack_level][1].op_code == NO_OP))
				          return(0);
				  }
			      else
			      	collapse_stack(stack_phooey + 1);
			    }
			    else
			    {
			    	stack_pointer[stack_level] = 0;
				to_ascii(TRUE);
				redraw();
			    	return(0);
			    }
			    break;

			case YTOTHEX:
			    temporary = pow(math_stack[stack_level][stack_phooey].math_value,
			    		    math_stack[stack_level][stack_phooey + 1].math_value);
			    math_stack[stack_level][stack_phooey].math_value = temporary;
			    math_stack[stack_level][stack_phooey].op_code = 
			        	math_stack[stack_level][stack_phooey + 1].op_code;
			    collapse_stack(stack_phooey + 1);
			    break;

			case YROOTX:
			    temporary = pow(math_stack[stack_level][stack_phooey].math_value,
			    		    1 / math_stack[stack_level][stack_phooey + 1].math_value);
			    math_stack[stack_level][stack_phooey].math_value = temporary;
			    math_stack[stack_level][stack_phooey].op_code = 
			        	math_stack[stack_level][stack_phooey + 1].op_code;
			    collapse_stack(stack_phooey + 1);
			    break;
				
			case TIMES:
			    evaluate_it = TRUE;
			    prev_op = stack_phooey - 1;
			    next_op = stack_phooey + 1;
			    if (next_op < stack_pointer[stack_level])
			    {
			      if ((math_stack[stack_level][next_op].op_code == YTOTHEX) ||
				  (math_stack[stack_level][prev_op].op_code ==  YROOTX))
			      {
				stack_phooey = evaluate_stack(stack_phooey + 1);
			    	if ((math_stack[stack_level][0].op_code == EQUALS) &&
			            (math_stack[stack_level][1].op_code == NO_OP))
			          	return(0);
			      }
			    }
			    if (evaluate_it == TRUE)
			    {
			        temporary = math_stack[stack_level][stack_phooey].math_value *
			    		    math_stack[stack_level][next_op].math_value;
			        math_stack[stack_level][stack_phooey].math_value = temporary;
			        math_stack[stack_level][stack_phooey].op_code = 
			        		math_stack[stack_level][next_op].op_code;
			        collapse_stack(stack_phooey + 1);
			    }
			    break;
			    
			case DIVIDED:
			    evaluate_it = TRUE;
			    prev_op = stack_phooey - 1;
			    next_op = stack_phooey + 1;

			    if (next_op < stack_pointer[stack_level])
			    {
			      if((math_stack[stack_level][next_op].op_code == YTOTHEX) ||
				 (math_stack[stack_level][prev_op].op_code ==  YROOTX))
			      
			      {
			        stack_phooey = evaluate_stack(stack_phooey + 1);
			    	if ((math_stack[stack_level][0].op_code == EQUALS) &&
			            (math_stack[stack_level][1].op_code == NO_OP))
				          return(0);
			      }
			    }
			    if (evaluate_it == TRUE)
			    {
			        temporary = math_stack[stack_level][stack_phooey].math_value /
			    		    math_stack[stack_level][next_op].math_value;
			        math_stack[stack_level][stack_phooey].math_value = temporary;
			        math_stack[stack_level][stack_phooey].op_code = 
			        		math_stack[stack_level][next_op].op_code;
			        collapse_stack(stack_phooey + 1);
			    }
			    break;
			
			case KPLUS:
			    evaluate_it = TRUE;
			    next_op = stack_phooey + 1;
			    prev_op = stack_phooey - 1;
			    if (prev_op >= 0)
			    {
			      if ((math_stack[stack_level][prev_op].op_code == TIMES) ||
				  (math_stack[stack_level][prev_op].op_code == DIVIDED) ||
				  (math_stack[stack_level][prev_op].op_code ==  YROOTX) ||
				  (math_stack[stack_level][prev_op].op_code == YTOTHEX))
				  {
				      stack_phooey = 
				      	    evaluate_stack(stack_phooey - 1);
			 	      if ((math_stack[stack_level][0].op_code == EQUALS) &&
			                  (math_stack[stack_level][1].op_code == NO_OP))
				          	return(0);
				  }
			    }
			    if (next_op < stack_pointer[stack_level])
			    {
			      if ((math_stack[stack_level][next_op].op_code == TIMES) ||
				  (math_stack[stack_level][next_op].op_code == DIVIDED) ||
				  (math_stack[stack_level][prev_op].op_code ==  YROOTX) ||
				  (math_stack[stack_level][next_op].op_code == YTOTHEX))
				  {
				      stack_phooey =
				   	        evaluate_stack(stack_phooey + 1);
			  	      if ((math_stack[stack_level][0].op_code == EQUALS) &&
			            	  (math_stack[stack_level][1].op_code == NO_OP))
				          	return(0);
				  }
			    }
			    if (evaluate_it == TRUE)
			    {
			        temporary = math_stack[stack_level][stack_phooey].math_value +
			    		    math_stack[stack_level][next_op].math_value;
			        math_stack[stack_level][stack_phooey].math_value = temporary;
			        math_stack[stack_level][stack_phooey].op_code = 
			        		math_stack[stack_level][next_op].op_code;
			        collapse_stack(stack_phooey + 1);
			    }
			    break;

			case MINUS:
			    evaluate_it = TRUE;
			    next_op = stack_phooey + 1;
			    prev_op = stack_phooey - 1;
			    if (prev_op >= 0)
			    {
			      if ((math_stack[stack_level][prev_op].op_code == TIMES) ||
				  (math_stack[stack_level][prev_op].op_code == DIVIDED) ||
				  (math_stack[stack_level][prev_op].op_code ==  YROOTX) ||
				  (math_stack[stack_level][prev_op].op_code == YTOTHEX))
				  {
				      stack_phooey = 
				      	    evaluate_stack(stack_phooey - 1);
			    	      if ((math_stack[stack_level][0].op_code == EQUALS) &&
			                  (math_stack[stack_level][1].op_code == NO_OP))
				          	return(0);
				  }
			    }
			    if (next_op < stack_pointer[stack_level])
			    {
			      if ((math_stack[stack_level][next_op].op_code == TIMES) ||
				  (math_stack[stack_level][next_op].op_code == DIVIDED) ||
				  (math_stack[stack_level][prev_op].op_code ==  YROOTX) ||
				  (math_stack[stack_level][next_op].op_code == YTOTHEX))
				  {
				      stack_phooey = 
				      	    evaluate_stack(stack_phooey + 1);
			    	      if ((math_stack[stack_level][0].op_code == EQUALS) &&
			                  (math_stack[stack_level][1].op_code == NO_OP))
				          	return(0);
				  }
			    }
			    if (evaluate_it == TRUE)
			    {
			        temporary = math_stack[stack_level][stack_phooey].math_value -
			    		    math_stack[stack_level][next_op].math_value;
			        math_stack[stack_level][stack_phooey].math_value = temporary;
			        math_stack[stack_level][stack_phooey].op_code = 
			        		math_stack[stack_level][next_op].op_code;
			        collapse_stack(stack_phooey + 1);
			    }
			    break;

			case NO_OP:
			    return(0);
			    break;

			default:
			    return(0);
			    break;
			    
		} /* End switch (op_code) */

	} /* End for (i = ...) */

	stack_pointer[stack_level]--;
	to_ascii(TRUE);
	stack_pointer[stack_level]++;
	redraw();

	if (math_stack[stack_level][stack_phooey].op_code == EQUALS)
		return(stack_phooey);
	else
		return(stack_phooey - 1);
}
/******************
 * 
 * COLLAPSE_STACK()
 *   Collapses the stack down onto an intermediate result
 */
 
collapse_stack(index)
int	index;
{
	int i;

	if ((math_stack[stack_level][0].op_code == EQUALS) &&
	    (math_stack[stack_level][1].op_code == NO_OP))
		return;

	if (index < 1)
		return;

	for (i = index; i < orig_stack_pointer; i++)
	{
		math_stack[stack_level][i].math_value = math_stack[stack_level][i + 1].math_value;
		math_stack[stack_level][i].op_code = math_stack[stack_level][i + 1].op_code;
	}

	if (stack_pointer[stack_level] > 0)
		stack_pointer[stack_level]--;
}
/*******************
 *
 * DO_TIMES()
 */
do_times()
{ 
	recursion_level = 0;
	if (second_flag == TRUE)
	{
	    to_number(TRUE);
	    if (trig_flag != DEGREES)
		    to_degrees();
	    to_ascii(FALSE);
	    trig_flag = DEGREES;
	    enter_exp_flag = FALSE;
	    result_flag = TRUE;
	    decimal_flag = FALSE;
	}
	else
	{
	    to_number(FALSE);
	    push_stack(TIMES);
	    to_ascii(TRUE);
	    enter_exp_flag = FALSE;
	    result_flag = TRUE;
	    decimal_flag = FALSE;
	}
	redraw();
}
/*************
 *
 * DO_DIVIDED()
 *
 */
do_divided()
{
	recursion_level = 0;
	if (second_flag != TRUE)
	{
		to_number(FALSE);
		push_stack(DIVIDED);
		to_ascii(TRUE);
	}
	else
	{
		to_number(TRUE);
		absolute();
		to_ascii(FALSE);
	}
	enter_exp_flag = FALSE;
	result_flag = TRUE;
	decimal_flag = FALSE;
	redraw();
}
/************
 *
 * DO_PLUS()
 */
do_plus()
{
	to_number(FALSE);
	recursion_level = 0;
	push_stack(KPLUS);
	enter_exp_flag = FALSE;
	result_flag = TRUE;
	decimal_flag = FALSE;
	to_ascii(TRUE);
	redraw();
}
/**************
 *
 * DO_EVERYTHING()
 *
 */
do_everything()
{
      int  tabby;

      switch(obj_found){
	case HAPPY:
		return(TRUE);
		break;

	case LEARN:
		do_learn();
		clear_calc();
		redraw();
		break;

	case KGOTO:
		redraw();
		butt_direction = UP;
		tabby = 1;
		while(tabby == 1)
		{
		    monitor_mouse();
		    switch(obj_found){
		    	case SECOND:
		    		second_flag = TRUE;
		    		break;
		    	default:
		    		tabby = 0;
		    		break;
		    	}
		}
		do_go_to();
		break;

	case RESET:
		redraw();
		program_counter = 0;
		break;

	case KEYA:
	case KEYB:
	case KEYC:
	case KEYD:
	case KEYE:
	case RUNSTOP:
		redraw();
		if (processor_mode == STOPPED)
		{
			processor_mode = RUNNING;
			if (obj_found != RUNSTOP)
			{
			    for (tabby = 0; tabby <= 8; tabby += 2)
			    {
			    	if (label_offset[tabby] == obj_found)
			    	{
			    	    if (second_flag == TRUE)
			    	    	tabby++;
				    if (label_positions[tabby] != 1001)
			    	        program_counter = 
			    	        	label_positions[tabby];
			    	    break;
			    	}
			    }
			}
			run_calc();
		}
		break;
		
	case CALCOFF:
		editing = FALSE;
		break;

	case KTHREEA:
		if (second_flag != TRUE)
			do_keys(TRUE);	
		else
		{
			result_flag = TRUE;
			enter_exp_flag = FALSE;
			decimal_flag = TRUE;
			do_pi();
			to_ascii(FALSE);
			redraw();
		}
		break;

	case KPOINT:
		if (second_flag == TRUE)
		    return(READ_FILE);
		else
		    do_keys(TRUE);
		break;

	case KZEROA:
	case KONEA:
	case KTWOA:
	case KFOURA:
	case KFIVEA:
	case KSIXA:
	case KSEVENA:
	case KEIGHTA:
	case KNINEA:
		do_keys(TRUE);
		break;
		
	case XXCHANGT:
		if (second_flag == TRUE)
		{
			redraw();
			clear_program();
		}
		else
		{
			to_number(TRUE);
			exchange();
			to_ascii(FALSE);
			enter_exp_flag = FALSE;
			result_flag = TRUE;
			decimal_flag = FALSE;
			redraw();
		}
		break;

	case STO:
	    redraw();
	    if (second_flag != TRUE)
	    {
	    	temp1 = get_numb_key();
	    	if ((temp1 == 0x13) ||
	  	    (temp1 == BOGUS))
	    		break;
		temp2 = get_numb_key();
		if ((temp2 == 0x13) ||	/* User can always CLEAR */
		    (temp2 == BOGUS))
			break;
		redraw();	
		mem_loc = (temp1 * 10) + temp2;
		to_number(TRUE);
		do_store();
		to_ascii(FALSE);
		enter_exp_flag = FALSE;
		result_flag = TRUE;
		decimal_flag = FALSE;
		redraw();
	    }
	    else
	    {
	    	clear_memories();
	    }
	    break;			
		
	case RCL:	
		redraw();
		temp1 = get_numb_key();
		if ((temp1 == 0x13) ||	/* User can always CLEAR */
	  	    (temp1 == BOGUS))
			break;	
		temp2 = get_numb_key();
		if ((temp2 == 0x13) ||	/* User can always CLEAR */
		    (temp2 == BOGUS))
			break;	
		redraw();
		mem_loc = (temp1 * 10) + temp2;
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
		redraw();
		break;			
			
	case SUM:	
		redraw();
		to_number(TRUE);
		temp1 = get_numb_key();
		if ((temp1 == 0x13) ||	/* User can always CLEAR */
	  	    (temp1 == BOGUS))
			break;	
		temp2 = get_numb_key();
		if ((temp2 == 0x13) ||	/* User can always CLEAR */
		    (temp2 == BOGUS))
			break;	
		mem_loc = (temp1 * 10) + temp2;
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
		break;	
			
	case CLEAR:
		clear_calc();
		redraw();
		break;

	case CE:
		clear_entry();
		redraw();
		break;

	case EQUALS:
		do_equals();
		break;

	case TIMES:
		do_times();
		break;
			
	case KPLUS:
		do_plus();
		break;
			
	case MINUS:
		do_minus();
		break;
		
	case DIVIDED:
		do_divided();
		break;

	case KEYSIN:
		to_number(TRUE);
		if (second_flag != TRUE)
		{
		    if (inverse_flag != TRUE)
		    {
			angle_convert();
			sinx();
		    }
		    else
		    {
			asinx();
			angle_deconvert();
		    }
		}
		else
		{
		    if (inverse_flag != TRUE)
		    {
			angle_convert();
			sinhyp();
		    }
		    else
		    {
			inv_sinh();
			angle_deconvert();
		    }
		}
		to_ascii(FALSE);
		enter_exp_flag = FALSE;
		result_flag = TRUE;
		decimal_flag = FALSE;
		redraw();
		break;

	case KEYCOS:
		to_number(TRUE);
		if (second_flag != TRUE)
		{
		    if (inverse_flag != TRUE)
		    {
			angle_convert();
			cosx();
		    }
		    else
		    {
			acosx();
			angle_deconvert();
		    }
		}
		else
		{
		    if (inverse_flag != TRUE)
		    {
			angle_convert();
			coshyp();
		    }
		    else
		    {
			inv_cosh();
			angle_deconvert();
		    }
		}
		to_ascii(FALSE);
		enter_exp_flag = FALSE;
		result_flag = TRUE;
		decimal_flag = FALSE;
		redraw();
		break;

	case KEYTAN:
		to_number(TRUE);
		if (second_flag != TRUE)
		{
		    if (inverse_flag != TRUE)
		    {
			angle_convert();
			tanx();
		    }
		    else
		    {
			atanx();
			angle_deconvert();
		    }
		}
		else
		{
		    if (inverse_flag != TRUE)
		    {
			angle_convert();
			tanhyp();
		    }
		    else
		    {
			inv_tanh();
			angle_deconvert();
		    }
		}
		to_ascii(FALSE);
		enter_exp_flag = FALSE;
		result_flag = TRUE;
		decimal_flag = FALSE;
		redraw();
		break;
	
	case XSQUARED:
		to_number(TRUE);
		square();
		to_ascii(FALSE);
		enter_exp_flag = FALSE;
		result_flag = TRUE;
		decimal_flag = FALSE;
		redraw();
		break;

	case ROOTX:
		to_number(TRUE);
		square_root();
		to_ascii(FALSE);
		enter_exp_flag = FALSE;
		result_flag = TRUE;
		decimal_flag = FALSE;
		redraw();
		break;
		
	case LNX:
		to_number(TRUE);
		if (inverse_flag != TRUE)
			natural();
		else
			inv_natural();
		to_ascii(FALSE);
		enter_exp_flag = FALSE;
		result_flag = TRUE;
		decimal_flag = FALSE;
		redraw();
		break;

	case LOGX:
		to_number(TRUE);
		if (inverse_flag != TRUE)
			common();
		else
			inv_common();
		to_ascii(FALSE);
		enter_exp_flag = FALSE;
		result_flag = TRUE;
		decimal_flag = FALSE;
		redraw();
		break;
		
	case ONEOVERX:
		to_number(TRUE);
		one_over();
		to_ascii(FALSE);
		enter_exp_flag = FALSE;
		result_flag = TRUE;
		decimal_flag = FALSE;
		redraw();
		break;

	case OPENPARN:
		do_open_parn();
		break;

	case CLOSPARN:
		do_close_parn();
		break;
		
	case YTOTHEX:
		do_y_to_the_x();
		break;
		
	case SECOND:
		redraw();
		second_flag = TRUE;
		break;

	case INVERSE:
		redraw();
		inverse_flag = TRUE;
		break;

	case EE:
		exp_flag = TRUE;
		if (decimal_flag != TRUE)
		{
			decimal_flag = TRUE;
			obj_found = KPOINT;
			do_keys(TRUE);
		}
		ted2_pointer->te_ptext[24] = '0';
		ted2_pointer->te_ptext[25] = '0';
		enter_exp_flag = TRUE;
		redraw();
		break;
			
	case PLUSMINU:
	    if (second_flag == TRUE)
		return(WRITE_FILE);
	    else
	    {
		if (enter_exp_flag == TRUE)
		{
		    if (ted2_pointer->te_ptext[23] == 0x20)
		    	ted2_pointer->te_ptext[23] = '-';
		    else
		    	ted2_pointer->te_ptext[23] = 0x20;
		}
		else
		{
		    if (ted2_pointer->te_ptext[ted_index] == 0x20)
		    	ted2_pointer->te_ptext[ted_index] = '-';
		    else
		    	ted2_pointer->te_ptext[ted_index] = 0x20;
		}
		redraw();
	    }
	    break;
		
	default:
		break;

	}
	if ((obj_found != SECOND) && (obj_found != INVERSE))
	{
		second_flag = FALSE;
		inverse_flag = FALSE;
	}


	return(FALSE);
}
/*********************
 *
 * GET_NUMB_KEY()
 *
 * Returns a 0x13 if user cleared,
 * BOGUS if key was bad, else 0->9
 *
 */
get_numb_key()
{
	int temp1;

	temp1 = mon_keys();
	if (temp1 == 'C')
	{
		/* nada */
	}
	else if ((temp1 < '0') || (temp1 > '9'))
	{
		set_error();
		redraw();
		return(BOGUS);
	}
	redraw();
	temp1 -= '0';	
	return(temp1);
}
