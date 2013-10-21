#include <osbind.h>
#include <vdibind.h>
#include <aesbind.h>
#include <gemdefs.h>
#include <stdio.h>
#include "joystick.h"
#include "joystick.inc"

/****************************************/
/*             EQUATES			*/
/****************************************/

#define    ARROW_MOUSE    graf_mouse(ARROW, &dummy)
#define    HIDE_MOUSE     graf_mouse(M_OFF, &dummy)

/************************************************************************/
/*  GEM System stuff.													*/
/************************************************************************/
int		work_in[256];
int		work_out[256];
int		dummy,handle;
int 	contrl[12], ptsin[256], ptsout[256], intin[256], intout[256];

char	somestring[3];

/************************************************************************/
/*  GLOBAL Variables													*/
/************************************************************************/


/****************************************************************/
/*  Main Loop Begins Here.										*/
/****************************************************************/
main()
{
	void read_joystick_matrix();

	int i;					/* loop control */

	appl_init();
	handle = graf_handle(&dummy,&dummy,&dummy,&dummy);
	for (i=1; i<10; ++i)
		work_in[i] = 1;
	work_in[0] = Getrez() + 2;
	work_in[10] = 2;
	v_opnvwk(work_in, &handle, work_out);	/* open the workstation */
	HIDE_MOUSE;
	v_clrwk(handle);			/* clear the screen */

	v_gtext(handle,150,20,"Joystick PortA      Joystick PortB");
	v_gtext(handle,250,150,"Press Any Key to Exit");

	while(Cconis() ==0)
	{

		Supexec(read_joystick_matrix);

		display_joypad_result();
		display_fire_result();
		display_keypad_result();

	}

	i = Cconin();								/* eat the character */
	v_clsvwk();
	ARROW_MOUSE;
	appl_exit();

}

/************************************************************************/
/*  Functions Begin Here.												*/
/************************************************************************/
display_joypad_result()
{
	v_gtext(handle,40,40,"JOYPAD        =>");

	switch(joypad_cur[0])
	{
		case JOYBIT_UP:
			v_gtext(handle,190,40,"UP             ");
			break;
		case JOYBIT_DOWN:
			v_gtext(handle,190,40,"DOWN           ");
			break;
		case JOYBIT_LEFT:
			v_gtext(handle,190,40,"LEFT           ");
			break;
		case JOYBIT_RIGHT:
			v_gtext(handle,190,40,"RIGHT          ");
			break;
		case JOYBIT_UPRIGHT:
			v_gtext(handle,190,40,"UP RIGHT       ");
			break;
		case JOYBIT_UPLEFT:
			v_gtext(handle,190,40,"UP LEFT        ");
			break;
		case JOYBIT_DOWNRIGHT:
			v_gtext(handle,190,40,"DOWN RIGHT     ");
			break;
		case JOYBIT_DOWNLEFT:
			v_gtext(handle,190,40,"DOWN LEFT      ");
			break;
                default:
			v_gtext(handle,190,40,"NEUTRAL        ");
			break;
	}
	switch(joypad_cur[1])
	{
		case JOYBIT_UP:
			v_gtext(handle,350,40,"UP             ");
			break;
		case JOYBIT_DOWN:
			v_gtext(handle,350,40,"DOWN           ");
			break;
		case JOYBIT_LEFT:
			v_gtext(handle,350,40,"LEFT           ");
			break;
		case JOYBIT_RIGHT:
			v_gtext(handle,350,40,"RIGHT          ");
			break;
		case JOYBIT_UPRIGHT:
			v_gtext(handle,350,40,"UP RIGHT       ");
			break;
		case JOYBIT_UPLEFT:
			v_gtext(handle,350,40,"UP LEFT        ");
			break;
		case JOYBIT_DOWNRIGHT:
			v_gtext(handle,350,40,"DOWN RIGHT     ");
			break;
		case JOYBIT_DOWNLEFT:
			v_gtext(handle,350,40,"DOWN LEFT      ");
			break;
                default:
			v_gtext(handle,350,40,"NEUTRAL        ");
			break;
	}
}

display_fire_result()
{
	v_gtext(handle,40,60,"FIRE BUTTONS  =>");

	switch(firebuttons_cur[0])
	{
		case FIREBIT_0:
			v_gtext(handle,190,60,"FIRE 0  ");
			break;
		case FIREBIT_1:
			v_gtext(handle,190,60,"FIRE 1  ");
			break;
		case FIREBIT_2:
			v_gtext(handle,190,60,"FIRE 2  ");
			break;
		case FIREBIT_PAUSE:
			v_gtext(handle,190,60,"PAUSE   ");
			break;
		case FIREBIT_OPTION:
			v_gtext(handle,190,60,"OPTION  ");
			break;
                default:
			v_gtext(handle,190,60,"NEUTRAL ");
			break;
	}
	switch(firebuttons_cur[1])
	{
		case FIREBIT_0:
			v_gtext(handle,350,60,"FIRE 0  ");
			break;
		case FIREBIT_1:
			v_gtext(handle,350,60,"FIRE 1  ");
			break;
		case FIREBIT_2:
			v_gtext(handle,350,60,"FIRE 2  ");
			break;
		case FIREBIT_PAUSE:
			v_gtext(handle,350,60,"PAUSE   ");
			break;
		case FIREBIT_OPTION:
			v_gtext(handle,350,60,"OPTION  ");
			break;
                default:
			v_gtext(handle,350,60,"NEUTRAL ");
			break;
	}
}

display_keypad_result()
{
	v_gtext(handle,40,80,"KEYPAD        =>");

	switch(keypad_cur[0])
	{
		case KEYBIT_POUND:
			v_gtext(handle,190,80,"#       ");
			break;
		case KEYBIT_0:
			v_gtext(handle,190,80,"0       ");
			break;
		case KEYBIT_STAR:
			v_gtext(handle,190,80,"*       ");
			break;
		case KEYBIT_9:
			v_gtext(handle,190,80,"9       ");
			break;
		case KEYBIT_8:
			v_gtext(handle,190,80,"8       ");
			break;
		case KEYBIT_7:
			v_gtext(handle,190,80,"7       ");
			break;
		case KEYBIT_6:
			v_gtext(handle,190,80,"6       ");
			break;
		case KEYBIT_5:
			v_gtext(handle,190,80,"5       ");
			break;
		case KEYBIT_4:
			v_gtext(handle,190,80,"4       ");
			break;
		case KEYBIT_3:
			v_gtext(handle,190,80,"3       ");
			break;
		case KEYBIT_2:
			v_gtext(handle,190,80,"2       ");
			break;
		case KEYBIT_1:
			v_gtext(handle,190,80,"1       ");
			break;
                default:
			v_gtext(handle,190,80,"NEUTRAL ");
			break;
	}
	switch(keypad_cur[1])
	{
		case KEYBIT_POUND:
			v_gtext(handle,350,80,"#       ");
			break;
		case KEYBIT_0:
			v_gtext(handle,350,80,"0       ");
			break;
		case KEYBIT_STAR:
			v_gtext(handle,350,80,"*       ");
			break;
		case KEYBIT_9:
			v_gtext(handle,350,80,"9       ");
			break;
		case KEYBIT_8:
			v_gtext(handle,350,80,"8       ");
			break;
		case KEYBIT_7:
			v_gtext(handle,350,80,"7       ");
			break;
		case KEYBIT_6:
			v_gtext(handle,350,80,"6       ");
			break;
		case KEYBIT_5:
			v_gtext(handle,350,80,"5       ");
			break;
		case KEYBIT_4:
			v_gtext(handle,350,80,"4       ");
			break;
		case KEYBIT_3:
			v_gtext(handle,350,80,"3       ");
			break;
		case KEYBIT_2:
			v_gtext(handle,350,80,"2       ");
			break;
		case KEYBIT_1:
			v_gtext(handle,350,80,"1       ");
			break;
                default:
			v_gtext(handle,350,80,"NEUTRAL ");
			break;
	}
}

void read_joystick_matrix()
{
	get_joystick();
	get_firebuttons();
	get_keypad();
}


