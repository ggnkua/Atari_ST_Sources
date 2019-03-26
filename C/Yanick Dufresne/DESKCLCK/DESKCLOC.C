#include <string.h>			/*Standard includes*/
#include <stddef.h>
#include <aes.h>
#include <NEW_AES.h>
#include <time.h>
#include <stdlib.h>


int main(int, char *[] );	/*variables definitions*/
short app_id, menu_id;
char time_title[9] = "  Time: ";
char display[20] = "  Time:";
char real_time[13];
char *infostring = "[0][Desk clock accessory by |Yanick Dufresne|Email: y.dufresne|Version 1.0|(C) 1994, Freeware!][OK]";
char *errstring = "[3][menu_register() returned -1][exit]";
int msg[8], minute=-1;
EVENT my_event= {MU_MESAG|MU_TIMER,		/* Event definition: message and timer */
						0,0,0,
						0,0,0,0,0,
						0,0,0,0,0,
						2000,0,			/* 2000 ms or 2 sec delay */
						0,0,0,0,0,0,0,0};

typedef long time_t;
time_t cal;
struct tm *ptable;
char *fmt = "%a, %H:%M";


int
main ()				/* Main program */
{

	if( (app_id = appl_init() )== -1)		/* Initialize AES */
		return -1;							/* return -1 if error */
		
	if((menu_id = menu_register(app_id, display)) == -1) /* register in menu*/
		{
		form_alert( 1, errstring);		/* Alert and return if error*/
		return -1;
		}

	for(;;)		/* Infinite loop  */
	{

		cal = time (0);					/* Set calander time in cal */
		ptable = localtime ( &cal );	/* Translate to local time */

		if(!( minute == ptable->tm_min))  /* update if one minute has passed */
		{
			minute = ptable->tm_min;
			strftime( &real_time[0], 12, fmt, ptable ); /* format it */
			strcpy( display,time_title );	/* set display to time_title */
			strcat( display, real_time );	/* + real_time */
	
			if(_app) menu_register(app_id, display); /* if run as PRG, update tear-offs */
		}
		
		
		
		EvntMulti (&my_event);			/* ZZZZZZ */

		if(my_event.ev_mwich & MU_MESAG		/* is it a message? */
			&& my_event.ev_mmgpbuf[0] == AC_OPEN) 	/* to open? */
				form_alert(2, infostring);			/* hello, it's me! */
	
			/* else, the event was timer and it's time to update */

	}
}