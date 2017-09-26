/*------------------------------------------------------------------------*/
/* Funktionen zu Verbindung mit den Sockets																*/

#include <cflib.h>

#include "types.h"
#include "event.h"
#include "global.h"
#include "itime.h"
#include "rsc.h"

/*------------------------------------------------------------------------*/
/* EXTERNE VARIABLE																												*/

/*------------------------------------------------------------------------*/
/* EXTPORTIERTE VARIABLE																									*/

int rechterRand = 0;

/*------------------------------------------------------------------------*/
/* DEFINES																																*/

/*------------------------------------------------------------------------*/
/* TYPES																																	*/

/*------------------------------------------------------------------------*/
/* FUNKTIONS																															*/

static void setup_open(WDIALOG *dial);
static int setup_close(WDIALOG *dial,int obj);

/*------------------------------------------------------------------------*/
/* LOCALE VARIABLES																												*/

static WDIALOG	*wsetup;

/*------------------------------------------------------------------------*/

void start_setup(void)
{
	if(wsetup!=NULL)
		open_wdial( wsetup, -1, -1 );
}

/*------------------------------------------------------------------------*/

void setup_open(WDIALOG *dial)
{
  set_state(dial->tree, MAIN_GRAUERHINTER, SELECTED, hintergrund);
	if(gl_planes<4)
	  set_state(dial->tree, MAIN_GRAUERHINTER, DISABLED, TRUE);
		
  set_int(dial->tree, MAIN_RECHTERRAND, rechterRand);
  set_int(dial->tree, MAIN_INTERVALL, intervall / 1000);
}

/*------------------------------------------------------------------------*/
/* Exit-Button im Setup bet„tigt																					*/

int setup_close(WDIALOG *dial,int obj)
{
	int close;
	
	close = FALSE;
	switch(obj)
	{
		case MAIN_OK:														/* Setup bernehmen						*/
			hintergrund=get_state(dial->tree,MAIN_GRAUERHINTER,SELECTED);
			set_hintergrund();
			rechterRand=get_int(dial->tree, MAIN_RECHTERRAND);
			intervall=get_int(dial->tree, MAIN_INTERVALL) * 1000;
		case MAIN_ABBRUCH:											/* Setup beenden							*/
		case WD_CLOSER:
			close = TRUE;
		break;
	}
	return close;
}

/*------------------------------------------------------------------------*/

bool init_setup(void)
{
	wsetup=create_wdial(Setup,NULL,0,setup_open,setup_close);
	if(wsetup)
		return TRUE;
	return FALSE;
}

/*------------------------------------------------------------------------*/

void term_setup(void)
{
	if(wsetup!=NULL)
		delete_wdial(wsetup);
}
