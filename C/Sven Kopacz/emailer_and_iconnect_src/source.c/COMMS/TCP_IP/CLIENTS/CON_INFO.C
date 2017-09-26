#include <ec_gem.h>
#include <inet.h>
#include <usis.h>
#include <sockinit.h>

#include "con_info.h"

WINDOW	wdial;

ONLINE_TIME *source_time;
BYTE_EXCHANGE *source_bytes;
int	sx,sy,sw,sh;

void other_message(int *pbuf)
{
	if((pbuf[0]==AP_TERM) || (pbuf[0]==AP_RESCHG))
	{
		wdial.closed(&wdial);
	}
}

char *gettext(int ob)
{
	OBJECT *tree;
	rsrc_gaddr(0, STRINGS, &tree);
	return(tree[ob].ob_spec.free_string);
}

void make_version_string(OBJECT *tree, long ver)
{
	unsigned int	pre, post;
	int	pos=0;

	pre=(unsigned int)(ver>>16);
	post=(unsigned int)(ver & 0xffffl);

	if(pre & 0xff00l)
	{
		tree[ICONVERS].ob_spec.tedinfo->te_ptext[pos++]=((pre & 0xff00l)>>8)+'0';
		pre&=0xff;
	}
	tree[ICONVERS].ob_spec.tedinfo->te_ptext[pos++]=pre+'0';
	tree[ICONVERS].ob_spec.tedinfo->te_ptext[pos++]='.';
	tree[ICONVERS].ob_spec.tedinfo->te_ptext[pos++]=((post & 0xff00l)>>8)+'0';
	post&=0xff;
	tree[ICONVERS].ob_spec.tedinfo->te_ptext[pos++]=post+'0';
	while(pos < 5)
		tree[ICONVERS].ob_spec.tedinfo->te_ptext[pos++]=' ';
	tree[ICONVERS].ob_spec.tedinfo->te_ptext[pos]=0;
}

void init_dial(OBJECT *tree)
{
	USIS_REQUEST ure;
	char res[66];

	ure.request=UR_CONN_MSG;
	ure.result=res;
	if(usis_query(&ure)==UA_FOUND)
	{
		strncpy(tree[CONN_MSG].ob_spec.free_string, res, 29);
		tree[CONN_MSG].ob_spec.free_string[29]=0;	
	}
	else
		strcpy(tree[CONN_MSG].ob_spec.free_string, gettext(UNKNOWN));
	
	ure.request=UR_LOCAL_IP;
	if(usis_query(&ure)==UA_FOUND)
		strcpy(tree[LOCIP].ob_spec.free_string, inet_ntoa(ure.ip));
	else
		strcpy(tree[LOCIP].ob_spec.free_string, gettext(UNKNOWN));

	ure.request=UR_REMOTE_IP;
	if(usis_query(&ure)==UA_FOUND)
		strcpy(tree[REMIP].ob_spec.free_string, inet_ntoa(ure.ip));
	else
		strcpy(tree[REMIP].ob_spec.free_string, gettext(UNKNOWN));
	
	ure.request=UR_DNS_IP;
	if(usis_query(&ure)==UA_FOUND)
		strcpy(tree[DNSIP].ob_spec.free_string, inet_ntoa(ure.ip));
	else
		strcpy(tree[DNSIP].ob_spec.free_string, gettext(UNKNOWN));
	
	ure.request=UR_POP_IP;
	if(usis_query(&ure)==UA_FOUND)
		strcpy(tree[POPIP].ob_spec.free_string, inet_ntoa(ure.ip));
	else
		strcpy(tree[POPIP].ob_spec.free_string, gettext(UNKNOWN));
	ure.request=UR_SMTP_IP;
	if(usis_query(&ure)==UA_FOUND)
		strcpy(tree[SMTPIP].ob_spec.free_string, inet_ntoa(ure.ip));
	else
		strcpy(tree[SMTPIP].ob_spec.free_string, gettext(UNKNOWN));
	ure.request=UR_NEWS_IP;
	if(usis_query(&ure)==UA_FOUND)
		strcpy(tree[NEWSIP].ob_spec.free_string, inet_ntoa(ure.ip));
	else
		strcpy(tree[NEWSIP].ob_spec.free_string, gettext(UNKNOWN));
	ure.request=UR_TIME_IP;
	if(usis_query(&ure)==UA_FOUND)
		strcpy(tree[TIMEIP].ob_spec.free_string, inet_ntoa(ure.ip));
	else
		strcpy(tree[TIMEIP].ob_spec.free_string, gettext(UNKNOWN));
		
	ure.result=res;
	ure.request=UR_EMAIL_ADDR;
	if(usis_query(&ure)==UA_FOUND)
		strncpy(tree[EMAIL].ob_spec.free_string, res, 30);
	else
		strcpy(tree[EMAIL].ob_spec.free_string, gettext(UNKNOWN));
	ure.request=UR_REAL_NAME;
	if(usis_query(&ure)==UA_FOUND)
		strncpy(tree[REAL].ob_spec.free_string, res, 30);
	else
		strcpy(tree[REAL].ob_spec.free_string, gettext(UNKNOWN));
		
	ure.request=UR_VERSION;
	if(usis_query(&ure)==UA_FOUND)
		make_version_string(tree, ure.ip);
	else
		strcpy(tree[ICONVERS].ob_spec.tedinfo->te_ptext, "?    ");
}

void get_dynamic_infos(OBJECT *tree)	
{
	USIS_REQUEST ure;

	ure.request=UR_ONLINE_TIME;
	if(usis_query(&ure)==UA_FOUND)
		source_time=(ONLINE_TIME*)(ure.other);
	else
	{
		source_time=NULL;
		strcpy(tree[TIME].ob_spec.tedinfo->te_ptext, "??:??");
	}
	
	ure.request=UR_BYTES;
	if(usis_query(&ure)==UA_FOUND)
		source_bytes=(BYTE_EXCHANGE*)(ure.other);
	else
	{
		source_bytes=NULL;
		strcpy(tree[BSENT].ob_spec.tedinfo->te_ptext, "?");
		strcpy(tree[BRCVD].ob_spec.tedinfo->te_ptext, "?");
	}
}

void check_update(WINDOW *win)
{
	static int state=0;
	int	update=0;
	USIS_REQUEST 	ure;
	
	switch(state)
	{
		case 0:	/* Init */
			update=1;
			state=1;
			if(appl_find("ICONNECT") < 0) break;
			ure.request=UR_LOCAL_IP;
			if(usis_query(&ure)==UA_OFFLINE) break;
			state=2;
		break;
		case 1:	/* War letztes mal nicht da oder nicht online */
			if(appl_find("ICONNECT") < 0) break;
			ure.request=UR_LOCAL_IP;
			if(usis_query(&ure)==UA_OFFLINE) break;
			update=1;
			state=2;
		break;
/* Ausklammsert: Alle 10 Sekunden total-Update wegen
   der neuen M”glichkeit, in IConnect online das Setup zu wechseln
   
		case 2:	/* War letztes mal da und online */
			if(appl_find("ICONNECT") > -1) break;
			ure.request=UR_LOCAL_IP;
			if(usis_query(&ure)!=UA_OFFLINE) break;
			update=1;
			state=1;
		break;
*/
		case 2:	/* War letztes mal da und online */
			if(appl_find("ICONNECT") < 0) {state=1; break;}
			update=1;
		break;
	}
	if(update==0) return;
	init_dial(win->dinfo->tree);
	s_redraw(win);
}

void show_dial(void)
{
	int			dum, evnt, swt, key, cnt=0;
	DINFO		ddial;
	OBJECT	*odial;
		
	rsrc_gaddr(0,MAIN,&odial);
	init_dial(odial);
	
	w_dinit(&wdial);
	ddial.tree=odial;
	ddial.support=0;
	ddial.osmax=0;
	ddial.odmax=8;
	wdial.dinfo=&ddial;

	if(!w_kdial(&wdial, D_CENTER, MOVE|NAME|BACKDROP|CLOSE))
	{/* Kann kein Fenster mehr ”ffnen */
		form_alert(1,"[3][No window available.][Cancel]");
		return;
	}
	wdial.closed=closed;
	ddial.dservice=NULL;
	ddial.dwservice=NULL;

	w_open(&wdial);
	while(wdial.open)
	{
		++cnt;
		if(cnt==3) /* Alle 6 Sekunden auf komplett Update prfen */
		{
			cnt=0;
			check_update(&wdial);
		}
		get_dynamic_infos(odial);
		if(source_time)
			strncpy(odial[TIME].ob_spec.tedinfo->te_ptext, source_time->hh_mm_ss, 5);
		w_objc_draw(&wdial, TIME, 8, sx,sy,sw,sh);
		if(source_bytes)		
		{
			strcpy(odial[BSENT].ob_spec.tedinfo->te_ptext, source_bytes->t_sent);
			while(strlen(odial[BSENT].ob_spec.tedinfo->te_ptext) < 12) strcat(odial[BSENT].ob_spec.tedinfo->te_ptext, " ");
			strcpy(odial[BRCVD].ob_spec.tedinfo->te_ptext, source_bytes->t_rcvd);
			while(strlen(odial[BRCVD].ob_spec.tedinfo->te_ptext) < 12) strcat(odial[BRCVD].ob_spec.tedinfo->te_ptext, " ");
		}
		w_objc_draw(&wdial, BSENT, 8, sx,sy,sw,sh);
		w_objc_draw(&wdial, BRCVD, 8, sx,sy,sw,sh);
		
		w_dtimevent(&evnt,&dum,&dum,&swt,&key, 2000, 0);
		if(evnt & MU_KEYBD)
		{	/* Vielleicht CTRL+U oder CTRL+Q? */
			if((swt==4) && (((key>>8)==22)||((key>>8)==16)))
				wdial.closed(&wdial);
		}
	}

	w_kill(&wdial);
}

int main(void)
{
	e_start_as(PRG, "Connection Info");
	ap_info.gunknown=other_message;
	if(!(ap_type & PRG))
		goto fin;
	if(rsrc_load("CON_INFO.RSC")==0)
	{
		form_alert(1,"[3][Error reading RSC.][Cancel]");
		goto fin;
	}
	switch(sock_init())
	{
		case SE_NINSTALL:
			form_alert(1,"[3][Sockets not installed.][Cancel]");
		goto rfin;
		case SE_NSUPP:
			form_alert(1,"[3][Newer version of SOCKETS.PRG|needed.][Cancel]");
		goto rfin;
	}
	wind_get(0, WF_WORKXYWH, &sx, &sy, &sw, &sh);
	show_dial();
	
rfin:
	rsrc_free();	
fin:	
	e_quit();
	return(0);
}