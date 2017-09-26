/*------------------------------------------------------------------------*/
/* Funktionen zu Verbindung mit den Sockets																*/

#include <cflib.h>

#include "types.h"
#include "itime.h"
#include "main.h"
#include "rsc.h"
#include "setup.h"

/*------------------------------------------------------------------------*/
/* EXTERNE VARIABLE																												*/

/*------------------------------------------------------------------------*/
/* EXTPORTIERTE VARIABLE																									*/

int x_pos = -1;
int y_pos = -1;															/* Position des Dialoges			*/
WDIALOG	*wonline;

/*------------------------------------------------------------------------*/
/* DEFINES																																*/

/*------------------------------------------------------------------------*/
/* TYPES																																	*/

/*------------------------------------------------------------------------*/
/* FUNKTIONS																															*/

/*------------------------------------------------------------------------*/
/* LOCALE VARIABLES																												*/

/*------------------------------------------------------------------------*/
/* Programm beenden																												*/

int online_close(WDIALOG *dial,int obj)
{
	int close;
	int w,h;
	
	close = 0;
	switch(obj)
	{
		case ONLINE_SETUP:											/* Setup aufrufen							*/
			start_setup();
			set_state(dial->tree, ONLINE_SETUP, SELECTED, FALSE);
			redraw_obj(dial->tree, ONLINE_SETUP);
		break;
		case ONLINE_ENDE:
		case WD_CLOSER:
			wind_get(dial->win_handle,WF_CURRXYWH,&x_pos,&y_pos,&w,&h);
			x_pos=dial->tree[0].ob_x;
			y_pos--;
			abort_prog = 1;												/* Programm beenden						*/
			close = 1;
		break;
	}
	return close;
}

/*------------------------------------------------------------------------*/

bool init_online(void)
{
	wonline=create_wdial(Online,NULL,0,WOCB_NULL,online_close);
	if(wonline)
	{
		open_wdial( wonline, x_pos, y_pos );
		return TRUE;
	}
	return FALSE;
}

/*------------------------------------------------------------------------*/

void term_online(void)
{
	if(wonline!=NULL)
		delete_wdial(wonline);
}
