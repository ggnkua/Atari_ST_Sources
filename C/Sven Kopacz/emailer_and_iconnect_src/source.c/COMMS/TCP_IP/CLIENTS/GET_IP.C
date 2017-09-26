#include <ec_gem.h>
#include <sockinit.h>
#include <socket.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>
#include <rsdaemon.h>

#include "get_ip.h"

/* -------------------------------------- */
/* Globals */

int							sx,sy,sw,sh;	/* Screen work area */
int	req_id=0;

/* -------------------------------------- */
/* Protos */

void	dial_win(void);
void	do_dial(WINDOW *win, int ob);
ulong	resolve(char *host);
void	clip_write(char *text);
void	set_ip(WINDOW *win, char *ip);

/* -------------------------------------- */

char *gettext(int ob)
{
	OBJECT *text_tree;
	
	rsrc_gaddr(0, STRINGS, &text_tree);
	return(text_tree[ob].ob_spec.free_string);
}

/* -------------------------------------- */

int main(void)
{
	e_start_as(PRG,"Get IP");
	
	if(!(ap_type & PRG))
		goto fin;
	
	uses_vdi();
	if(rsrc_load("GET_IP.RSC")==0)
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

	wind_get(0,WF_WORKXYWH,&sx,&sy,&sw,&sh);
	dial_win();

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
	WINDOW	wdial;
	DINFO		ddial;
	OBJECT	*odial;
		
	rsrc_gaddr(0,MAIN,&odial);
	objc_xted(odial, HOST, 64, 0);
	odial[HOST].ob_spec.tedinfo->te_ptext[0]=0;
	odial[IP].ob_spec.tedinfo->te_ptext[0]=0;
	odial[RESOLVE].ob_y-=odial[RESOLVE].ob_height/2;

	w_dinit(&wdial);
	ddial.tree=odial;
	ddial.support=0;
	ddial.osmax=0;
	ddial.odmax=8;
	wdial.dinfo=&ddial;

	if(!w_kdial(&wdial, D_CENTER, MOVE|NAME|BACKDROP|CLOSE))
	{/* Kann kein Fenster mehr ”ffnen */
		form_alert(1,gettext(A5));
		return;
	}
	wdial.closed=closed;
	ddial.dservice=NULL;
	ddial.dwservice=do_dial;
	ddial.dedit=HOST;

	w_open(&wdial);
		
	while(wdial.open)
	{
		w_devent(&evnt,&dum,&dum,&swt,&key);
		if(evnt & MU_KEYBD)
		{	/* Evtl. Alt+C gedrckt? */
			if((swt==8) && ((key>>8)==46))
				clip_write(odial[IP].ob_spec.tedinfo->te_ptext);
			/* Vielleicht CTRL+U oder CTRL+Q? */
			else if((swt==4) && (((key>>8)==22)||((key>>8)==16)))
				wdial.closed(&wdial);
		}
		if(evnt & MU_MESAG)
		{
			if((pbuf[0]==RSDAEMON_MSG) && (pbuf[4]==req_id))
			{
				if(pbuf[3]==RSD_IP_UNKNOWN)
					set_ip(&wdial, gettext(A7));
				else
					set_ip(&wdial, inet_ntoa(*(ulong*)&(pbuf[5])));
			}
			else if((pbuf[0]==AP_TERM)||(pbuf[0]==AP_RESCHG))
				wdial.closed(&wdial);
		}
	}

	w_kill(&wdial);
}

/* -------------------------------------- */

void set_ip(WINDOW *win, char *ip)
{
	strcpy(win->dinfo->tree[IP].ob_spec.tedinfo->te_ptext, ip);
	while(strlen(win->dinfo->tree[IP].ob_spec.tedinfo->te_ptext) < strlen("123.123.123.123"))
		strcat(win->dinfo->tree[IP].ob_spec.tedinfo->te_ptext, " ");
	w_objc_draw(win, IP, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void do_dial(WINDOW *win, int ob)
{
	ulong	ip;
	
	switch(ob)
	{
		case RESOLVE:
			graf_mouse(BUSYBEE, NULL);
			set_ip(win, gettext(A6));
			ip=resolve(win->dinfo->tree[HOST].ob_spec.tedinfo->te_ptext);
			graf_mouse(ARROW, NULL);
			w_unsel(win, ob);
			if(ip==0)
			{
				set_ip(win, gettext(A7));
				return;
			}
			if(ip==1)
				return;
			/* Set IP */
			set_ip(win, inet_ntoa(ip));
		break;
		case COPY:
			clip_write(win->dinfo->tree[IP].ob_spec.tedinfo->te_ptext);
		break;
	}
}

/* -------------------------------------- */

int request_daemon(int r_id, char *host)
{
	pbuf[0]=RSDAEMON_MSG;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	pbuf[3]=RSD_REQUEST_IP;
	pbuf[4]=++req_id;
	*(char**)(&(pbuf[5]))=host;
	appl_write(r_id, 16, pbuf);
	return(1);
}

/* -------------------------------------- */

ulong resolve(char *host)
{
	int r_id;
	hostent	*he;

	if((r_id=appl_find("RSDAEMON")) > -1)
		return(request_daemon(r_id, host));

	he=gethostbyname(host);
	if(he==NULL)
	{
		form_alert(1,gettext(A3));
		return(0);
	}

	if(he->h_addr_list[0]==0)
	{
		form_alert(1,gettext(A4));
		return(0);
	}
	
	return(*(ulong*)(he->h_addr_list[0]));
}

/* -------------------------------------- */

void clip_write(char *text)
{/* Eingabe: IP im Format "<a>.<b>.<c>.<d>{ }"
		Wird ins Clipboard geschrieben, wobei ggf.
		anh„ngende Spaces abgeschnitten werden */
		
	int 	fh;
	char	*ip="123.123.123.123";
	
	graf_mouse(BUSYBEE, NULL);

	strcpy(ip, text);
	while(ip[strlen(ip)-1]==' ')
		ip[strlen(ip)-1]=0;	
	
	fh=write_clipboard("SCRAP.TXT");
	if(fh < 0)
	{
		graf_mouse(ARROW, NULL);
		gemdos_alert("Can\'t write to clipboard.", fh);
		return;
	}
	
	Fwrite(fh, strlen(ip), ip);
	Fclose(fh);
	graf_mouse(ARROW, NULL);
}
