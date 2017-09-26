#include <ec_gem.h>
#include <sockinit.h>
#include <socket.h>
#include <sfcntl.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>
#include <usis.h>
#include <stic.h>

#include "net_time.h"
int get_timezone(void);

#define SERV_PORT	37

WINDOW	wdial;

/* -------------------------------------- */
/* Globals */

int	sx,sy,sw,sh;	/* Screen work area */
int	sock;

/* -------------------------------------- */
/* Protos */

void	dial_win(void);
void	get_net_time(WINDOW *win);

/* -------------------------------------- */

char *gettext(int ob)
{
	OBJECT *text_tree;
	
	rsrc_gaddr(0, STRINGS, &text_tree);
	return(text_tree[ob].ob_spec.free_string);
}

void other_message(int *pbuf)
{
	if((pbuf[0]==AP_TERM) || (pbuf[0]==AP_RESCHG))
	{
		wdial.closed(&wdial);
	}
}

/* -------------------------------------- */

int main(void)
{
	USIS_REQUEST ure;

	e_start_as(PRG,"Net Time");
	uses_txwin();	/* Nur fÅr unselect_3d */
	ap_info.gunknown=other_message;
	
	if(!(ap_type & PRG))
		goto fin;
		
	if(rsrc_load("NET_TIME.RSC")==0)
	{
		form_alert(1,"[3][Error reading RSC.][Cancel]");
		goto fin;
	}
	
	switch(sock_init())
	{
		case SE_NINSTALL:
			form_alert(1,gettext(A1));
		goto rfin;
		case SE_NSUPP:
			form_alert(1,gettext(A2));
		goto rfin;
	}

	ure.request=UR_TIME_IP;
	switch (usis_query(&ure))
	{
		case UA_NOTSET:
			form_alert(1,gettext(A4));
		goto rfin;
		case UA_UNKNOWN:
			form_alert(1,gettext(A6));
		goto rfin;
	}
	
	sock=socket(AF_INET, SOCK_DGRAM, 0);

	if(sock < 0)
	{
		form_alert(1,gettext(A3));
		goto rfin;
	}

	sfcntl(sock,F_SETFL,O_NDELAY);

	wind_get(0,WF_WORKXYWH,&sx,&sy,&sw,&sh);
	dial_win();

	sclose(sock);
	
rfin:
	rsrc_free();
fin:
	e_quit();
	return(0);
}

/* -------------------------------------- */

void dial_win(void)
{
	int			dum, evnt, swt, key;
	DINFO		ddial;
	OBJECT	*odial;
	STIC		*cp;

	if(find_cookie('StIc', (long*)(&cp))==1)
	{
		rsrc_gaddr(0,STICICON,&odial);
		cp->ext_icon(ap_id, &(odial[BIGICON]), &(odial[SMALLICON]), 1);
	}

	rsrc_gaddr(0,MAIN,&odial);

	odial[FRAME].ob_y/=2;
	unselect_3d(odial, FRAME);

	w_dinit(&wdial);
	ddial.tree=odial;
	ddial.support=0;
	ddial.osmax=0;
	ddial.odmax=8;
	wdial.dinfo=&ddial;

	if(!w_kdial(&wdial, D_CENTER, MOVE|NAME|BACKDROP|CLOSE))
	{/* Kann kein Fenster mehr îffnen */
		form_alert(1,gettext(A5));
		return;
	}
	wdial.closed=closed;
	ddial.dservice=NULL;
	ddial.dedit=0;

	w_open(&wdial);
		
	while(wdial.open)
	{
		w_dtimevent(&evnt,&dum,&dum,&swt,&key, 1000, 0);
		if(evnt & MU_TIMER)
			get_net_time(&wdial);
	}

	w_kill(&wdial);
	
	if(find_cookie('StIc', (long*)(&cp))==1)
	{
		rsrc_gaddr(0,STICICON,&odial);
		cp->ext_icon(ap_id, &(odial[BIGICON]), &(odial[SMALLICON]), 0);
	}
}

/* -------------------------------------- */

void clear_win(WINDOW *win)
{
	strcpy(win->dinfo->tree[TIME].ob_spec.tedinfo->te_ptext, "??:??");
	strcpy(win->dinfo->tree[DATE].ob_spec.tedinfo->te_ptext, "??.??.??");
	s_redraw(win);
}

/* -------------------------------------- */

void send_request(WINDOW *win)
{
	USIS_REQUEST ure;
	sockaddr_in sad;
	int					ret;
	char				alert[128];
	
	ure.request=UR_TIME_IP;
	switch (usis_query(&ure))
	{
		case UA_FOUND:
		break;
		case UA_NOTSET:
			form_alert(1,gettext(A4));
			clear_win(win);
		return;
		case UA_UNKNOWN:
			form_alert(1,gettext(A6));
			clear_win(win);
		return;
		case UA_OFFLINE:	/* Das kînnte sich noch Ñndern*/
			clear_win(win);
		return;
	}

	/* Send dummy message */
	sad.sin_port=SERV_PORT;
	sad.sin_addr=ure.ip;
	ret=sendto(sock, "?", 1, 0, &sad, (int)sizeof(sockaddr_in));
	if(ret < 0)
	{
		strcpy(alert, "[1][Socket send error:|)");
		itoa(ret, &(alert[strlen(alert)]), 10);
		strcat(alert,"][Cancel]");
		form_alert(1,alert);
	}
}

/* -------------------------------------- */

void num2(char *c, long num)
{
	char nb[3];
	int nr=(int)num;
	
	while(nr >= 100) nr-=100;	/* Fix */
	
	itoa(nr, nb, 10);
	
	if(nr < 10)
		strcat(c, "0"); 
	strcat(c, nb);
}

void recv_answer(WINDOW *win)
{
	char	buf[5];
	int		ret, gmt_offset, gmt_hour, gmt_minute;
	ulong	net_time, year, month, day, hour, minute, compare, a, *mm;
	ulong	mnorm[]={31,28,31,30,31,30,31,31,30,31,30,31};
	ulong	mschalt[]={31,29,31,30,31,30,31,31,30,31,30,31};
	
		
	ret=(int)sread(sock, buf, 4);
	if(ret < 0) return; /* Error? What error?? */
	if(ret < 4)	return;	/* Insufficient data */

	net_time=*(ulong*)(&buf[0]);
	
	/* Jahr */
	compare=60l*60l*24l*365l;	/* 1900 kein Schaltjahr! */
	a=year=0;
	while(net_time >= compare)
	{
		net_time-=compare;
		year++;
		a++;
		if(a==4)
		{
			a=0; compare=60l*60l*24l*366l;
		}
		else
			compare=60l*60l*24l*365l;
	}
	while(year >= 100)	year-=100;
	
	/* Monat */
	if(compare==60l*60l*24l*366l)
		mm=mschalt;
	else
		mm=mnorm;
	a=0;	
	month=1;
	while(net_time >= 60l*60l*24l*mm[a])
	{
		net_time-=60l*60l*24l*mm[a];
		++month;
		++a;
	}

	/* Tag */
	day=1;
	while(net_time >= 60l*60l*24l)	
	{
		net_time-=60l*60l*24l;
		++day;
	}
	
	/* Stunde */
	hour=0;
	while(net_time >= 60l*60l)
	{
		net_time-=60l*60l;
		++hour;
	}
	
	/* Minute */
	minute=0;
	while(net_time >= 60l)
	{
		net_time-=60l;
		++minute;
	}

	gmt_offset=get_timezone();
	if(gmt_offset != -99)
	{
		gmt_hour=gmt_offset/60;
		gmt_minute=gmt_offset-gmt_hour*60;
		hour+=gmt_hour;
		minute+=gmt_minute;
		if(minute < 0)
		{
			--hour; minute+=60;
		}
		else if(minute > 60)
		{
			++hour; minute-=60;
		}
		if(hour < 0) hour=24+hour;	/* We should correct the date here, too */
		else if(hour > 23) hour-=23; /* but we don't, it is too much work. */
		win->dinfo->tree[GMT].ob_flags|=HIDETREE;
	}
	else
		win->dinfo->tree[GMT].ob_flags|=(~HIDETREE);
		
	#define TX win->dinfo->tree[TIME].ob_spec.tedinfo->te_ptext
	#define DX win->dinfo->tree[DATE].ob_spec.tedinfo->te_ptext
	TX[0]=0;
	num2(TX, hour);
	strcat(TX, ":");
	num2(TX, minute);
	
	DX[0]=0;
	num2(DX, day);
	strcat(DX, ".");
	num2(DX, month);
	strcat(DX, ".");
	num2(DX, year);
	s_redraw(win);
}

/* -------------------------------------- */

void get_net_time(WINDOW *win)
{
	static int transmit;
	
	if(transmit==0)
		send_request(win);
	else
		recv_answer(win);
	
	++transmit;
	if(transmit==30) transmit=0;
}

/* -------------------------------------- */

int get_timezone(void)
{ /* Liefert GMT-Offset in Minuten zurÅck.
	Achtung: Kann positiv ODER negativ sein 
	Ist GMTC-Cookie nicht da, wird -99 geliefert! */
/*
 Cookie heiût 'GMTC', Inhalt:

Wert: 0xcccsdddd

wobei:
  ccc  codiert fÅr das CPX die Stadt (Anzeige mehrere StÑdte in einer
       Zeitzone)
  s    ist 1, wenn Sommerzeit, 0 wenn Winterzeit
  dddd gibt die Differenz zu GMT in Minuten an. (Minuten wegen
       Indischer Zeit: +5,5 Stunden) Sommerzeit ist hier nicht
       beachtet.
*/

	long	tz;
	int		t;
		
	if(find_cookie('GMTC', &tz)==0) return(-99);
	t=*(int*)&(((char*)&tz)[2]);

	if(((char*)&tz)[1] & 1) 
	{
		if(t < 0)
			t-=60;
		else
			t+=60;
	}
	return(t);
}
