/*********************************************************************/
/* ST Star-Raiders GEM Interface.				     */
/*	 Copyright 1986 ATARI Corp.				     */
/* Modified from Mike Schmal's Original Menu Source		     */
/*********************************************************************/

/*********************************************************************/
/* INCLUDE FILES						     */
/*********************************************************************/

#include "define.h"
#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "menu.rsc"

/*********************************************************************/
/* generic DEFINES					   	     */
/*********************************************************************/

#define DISPLAY	1
#define	ERASE	0

/*********************************************************************/
/* EXTERNAL VARIABLES					   	     */
/*********************************************************************/

extern int	difficult;
extern char	highscores[];
extern int	memerror;

/*********************************************************************/
/* LOCAL VARIABLES					   	     */
/*********************************************************************/

 int	msgbuff[8];	/* event message buffer */
 int	key;		/* keyboard return variable */

 int hidden;		/* unneccessary variable */

 int bored;		/* End of Game Flag */

/****************************************************************/
/*  generic GSX UTILITY ROUTINES.				*/
/****************************************************************/

hide_mouse()
{
	if(! hidden){
		graf_mouse(256,0x0L);
		hidden=TRUE;
	}
}

show_mouse()
{
	if(hidden){
		graf_mouse(257,0x0L);
		hidden=FALSE;
	}
}

do_form(pt)
OBJECT *pt;
{
 int	x,y,w,h;
	w=pt->ob_width; h=pt->ob_height;
	pt->ob_x = x = (320-w)/2;
	pt->ob_y = y = (189-h)/2+11;
	x -= 3; y -= 3; w += 6; h += 6;
	form_dial(0,x+w/2,y+h/2,36,36,x,y,w,h);
	form_dial(1,x+w/2,y+h/2,36,36,x,y,w,h);
	objc_draw(pt, 0, MAX_DEPTH, 0,0,320,189);
	form_do(pt,0);
	form_dial(2,x+w/2,y+h/2,36,36,x,y,w,h);
	form_dial(3,x+w/2,y+h/2,36,36,x,y,w,h);
}


/****************************************************************/
/*		MainLine Init. Until First Event_Multi		*/
/****************************************************************/

 main()
{
int i;

	appl_init();

	if(memerror)
	form_alert(1,"[3][|This System Has Insufficient|Memory to play Star Raiders!][Get ROMs]");
	else{
	if(Getrez())
	form_alert(1,"[3][|Star Raiders must be seen in|Low-Rez to be appreciated!][GOSH]");
	else{
		for(i=0;i<12;i++) high_dia[i+5].ob_spec = highscores + 42*i;
		last_dia[1].ob_spec = highscores + 12*42;
		hide_mouse();
		titlescreen();
		menu_bar(menu,DISPLAY);
		show_mouse();
		graf_mouse(ARROW,0x0L);
		hidden=FALSE;
		bored = FALSE;
		multi();
		graf_mouse(HOURGLASS,0x0L);
		menu_bar(menu , ERASE);
	     }}
	appl_exit();
}


/****************************************************************/
/* dispatches all accessory tasks				*/
/****************************************************************/
multi()
{
int event,ret;

      do {
	event = evnt_multi(MU_MESAG | MU_KEYBD,
			1,0x1,0x1,
			0,0,0,0,0,
			0,0,0,0,0,
			msgbuff,0,0,&ret,&ret,&ret,&ret,&key,&ret);

	wind_update(TRUE);

	if ((event & MU_MESAG) && (msgbuff[0] = MN_SELECTED))
 	    do_menu();	

	if (event & MU_KEYBD)
 	    do_keybd();	

	menu_tnormal(menu, msgbuff[3], DISPLAY);

	wind_update(FALSE);

    }while( !bored );
}

/****************************************************************/
/* HANDLE KEYBOARD INPUT					*/
/****************************************************************/
do_keybd()
{
	if((key & 0x0ff) == ('C'-64))
		bored = TRUE;
	else
	if((key & 0x0ff) == ('S'-64))
		playgame();
}

/****************************************************************/
/* HANDLE MENU ITEMS						*/
/****************************************************************/
do_menu()
{

	switch( msgbuff[4]) {

	case COPYRIGHT:
		do_form(copy_dia);
		copy_dia[COPY_OK].ob_state = NORMAL;
	        hide_mouse();
	        titlescreen();
	        show_mouse();
		break;
	case START:
		playgame();
		break;
	case NOVICE:
	case PILOT:
	case WARRIOR:
	case COMMANDER:
		menu[NOVICE-difficulty].ob_state = NORMAL;
		menu[msgbuff[4]].ob_state |= CHECKED;
		difficulty = NOVICE - msgbuff[4];
		break;
	case QUIT:
		bored = TRUE;
		break;
	case HIGHSCOR:
		do_form(high_dia);
		high_dia[HIGH_OK].ob_state = NORMAL;
	        hide_mouse();
	        titlescreen();
	        show_mouse();
		break;
	case LASTSCOR:
		do_form(last_dia);
		last_dia[LAST_OK].ob_state = NORMAL;
	        hide_mouse();
	        titlescreen();
	        show_mouse();
		break;

	} /* end switch */
}

/****************************************************************/
/* Run the Game							*/
/****************************************************************/
playgame()
{
int	ret;
		while (evnt_multi(MU_TIMER|MU_KEYBD|MU_MESAG,
			0,0,0,0,0,0,0,0,0,0,0,0,0,
			msgbuff,0,0,&ret,&ret,&ret,&ret,&ret,&ret)!=MU_TIMER);

		hide_mouse();
		staraid();
		menu_bar(menu,DISPLAY);
		titlescreen();
		show_mouse();

}
