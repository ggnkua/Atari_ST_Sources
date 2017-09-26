/*------------------------------------------------------------------------*/
/* Funktionen zu Verbindung mit den Sockets																*/

#include <cflib.h>

#include <..\atarierr.h>
#include <..\in.h>
#include <..\inet.h>
#include <..\netdb.h>
#include <..\sfcntl.h>
#include <..\socket.h>
#include <..\sockinit.h>
#include <..\usis.h>

#include "types.h"
#include "global.h"
#include "internet.h"
#include "setup.h"

/*------------------------------------------------------------------------*/
/* EXTERNE VARIABLE																												*/

/*------------------------------------------------------------------------*/
/* EXTPORTIERTE VARIABLE																									*/

/*------------------------------------------------------------------------*/
/* DEFINES																																*/

/*------------------------------------------------------------------------*/
/* TYPES																																	*/


/*------------------------------------------------------------------------*/
/* FUNKTIONS																															*/

static int init_IConnet(void);
static int init_STinG(void);

/*------------------------------------------------------------------------*/
/* LOCALE VARIABLES																												*/

static int	socket_typ = 0;

/*------------------------------------------------------------------------*/
/* Zeichnet die Online-Time irgendwo hin																	*/

void online_time(void)
{
	byte ZStr[30];
	int ret;
	int x, y;
	int pxyarray[8];
	
	USIS_REQUEST IConnect;
	ONLINE_TIME  *IConnect_Zeit;
	
	ZStr[0]=0;
	switch(socket_typ)
	{
		case ICONNET:
			IConnect.request=UR_ONLINE_TIME;
			ret = usis_query(&IConnect);
			if(ret == UA_FOUND)
			{
				IConnect_Zeit = (ONLINE_TIME *) IConnect.other;
				strcpy(ZStr, IConnect_Zeit->hh_mm_ss);
			}
			else
				strcpy(ZStr, "Offline ");
		break;
		case STING:
		break;
		case DRACONIS:
		break;
		default:
			strcpy(ZStr, "Socket? ");		
		break;
	}
	vqt_extent(vdi_handle,ZStr,pxyarray);
	x = w_max - pxyarray[2] - rechterRand;
	y = pxyarray[1];
	if(!quick_draw)
	{
		pxyarray[0] = (w_max - pxyarray[2] - rechterRand);
		pxyarray[2] = (w_max - rechterRand);
		pxyarray[4] = pxyarray[2];
		pxyarray[6] = pxyarray[0];
	}
	wind_update(BEG_UPDATE);
	if(!quick_draw)
		v_fillarea(vdi_handle,4,pxyarray);
	v_gtext(vdi_handle,x,y,ZStr);
	wind_update(END_UPDATE);
}

/*------------------------------------------------------------------------*/
/* Init Modu Internet																											*/
/* Rckgabe: TRUE = ein Socket gefunden																		*/

int init_internet(void)
{
	socket_typ=0;
	if(init_IConnet())												/* Nach IConnect suchen				*/
		socket_typ=ICONNET;
	if(init_STinG())
		socket_typ |=STING;
	return socket_typ;
}

/*------------------------------------------------------------------------*/
/* Init IConnect																													*/

int init_IConnet(void)
{
	int i,ret;

	ret=0;

	i=sock_init();
	switch(i)
	{
		case SE_NSUPP:
			do_walert(1,1,"[3][Die verwendete Library pažt nicht zu IConnect.|"
												     "Bitte setzen Sie sich mit dem Autor in|"
												     "Verbindung.][[OK]","ITime");
		break;
		case E_OK:
			ret=1;
		break;
		default:
		break;
	}
	return ret;
}

/*------------------------------------------------------------------------*/
/* Init IConnect																													*/

int init_STinG(void)
{
	return FALSE;
}

/*------------------------------------------------------------------------*/

void term_internet(void)
{
	int pxyarray[8];

	vswr_mode(vdi_handle,MD_REPLACE);
	if(hintergrund && gl_planes>=4)
		vsf_color(vdi_handle,LWHITE);
	else
		vsf_color(vdi_handle,WHITE);
	vqt_extent(vdi_handle,"Offline ",pxyarray);
	pxyarray[0] = (w_max - pxyarray[2] - rechterRand);
	pxyarray[2] = (w_max - rechterRand);
	pxyarray[4] = pxyarray[2];
	pxyarray[6] = pxyarray[0];
	wind_update(BEG_UPDATE);
	v_fillarea(vdi_handle,4,pxyarray);
	wind_update(END_UPDATE);
}
