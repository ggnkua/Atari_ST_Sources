#include <tos.h>
#include "\..\network.h"

#include <ec_gem.h>
#include <time.h>
#include <hsmod.h>
#include <inet.h>
#include <stic.h>

#include <sockinit.h>
#include <rsdaemon.h>
#include <icon_msg.h>
#include <gscript.h>

#include <atarierr.h>
#include "iconnect.h"
#include "iconfmem.h"

#include "stip_def.h"
#include "stipsync.h"

#define set_ext_type(tree,ob,val)	tree[ob].ob_type &=255; tree[ob].ob_type |= (((char)val)<<8);
#define obj_type(a, b) (a[b].ob_type & 0xff)
#define ext_type(a, b) (a[b].ob_type >> 8)

/* -------------------------------------- */
typedef struct
{
	long	magic;	/* 'ICWP'	(IConnect Window Position) */
	int		wx,wy;	/*	Window x & y */
}ICON_SETUP;

/* Global constants */
#define MAX_SEND_TRY	5			/* Timeout in seconds to get a
															 script-send-string over the port */

#define TERM_BUF_LINES	200	/* Buffered lines in terminal */

#define SCRIPT_IN_BUF	1024	/* Size of in-buf when running script */

#define PPP_NEG_TO	30			/* PPP-Negotiation Timeout in seconds */

#define MAX_READ_IP	16			/* Buffer for reading IP (Object "CONCMD"-length - "Read IP: ") */

#define CMD_MAX_LEN	25			/* String-len of Status and Command-Display */
/* -------------------------------------- */
/* GemScript constants */
/* Commands */
static char *GS_SET_SETUP="set_dial_setup";
static char *GS_SET_SERV="set_service_setup";
static char *GS_SYNC_RES="sync_resolve";
static char *GS_DIAL_IN="dial_in";
static char *GS_HANG_UP="hang_up";
static char *GS_SYNC_ONLINE="sync_online";

/* Results */
static char *GS_RES_RESOLVED="1\0\0"; /* resolved */
static char *GS_RES_ONLINE="1\0\0"; /* online */

/* Errors */
static char *GS_ERR_NONL="-1\0\0"; /* IConnect not online */
static char *GS_ERR_SNOF="-2\0\0"; /* Setup not found     */
static char *GS_ERR_NOFL="-3\0\0"; /* IConnect not offline */
static char *GS_ERR_NOCON="-4\0\0"; /* Connection not in progress */

/* Globvars */
WINDOW					*intro_wind, *online_wind;	/* Remote-Control by other_messages */
int							sx,sy,sw,sh;	/* Screen work area */
int							objects_started=0;
int							g_resolve_count=0;	/* Pending RSDaemon requests */
SETUP						*g_sets;				/* All loaded setups (remain in memory until iconnect quits) */
int							g_sets_count;		/* Number of loaded setups */
SETUP						set;					/* Selected setup to connect */
cookie_struct		*socks;				/* socket kernel cookie */
int							rsd_id=-1;		/* App-ID of RSDAEMON */

char						start_path[256];
char						setup_path[256];
ICON_SETUP			setup;

GS_INFO					ap_gi={sizeof(GS_INFO), 0x0100, GSM_COMMAND, 0};

char						conn_msg[64];	/* "CONNECTED"-Meldung des Modems */
#define CLEAR_STRING "                                "
#define OTHER_STRING "                                "

int	hang_up_state;
int	gdebug;

int	global_state;

clock_t initial, now;
ONLINE_TIME *_ol_;
BYTE_EXCHANGE *_be_;
/* -------------------------------------- */

/* Userobjects in windows */
typedef struct
{
	char	*mem;	/* Zeiger auf Setups */
	int		num;	/* Anzahl der Setups */
}U_INTRO;


/* -------------------------------------- */

/* Protos */
void	rsrc_init(void);
void	dial_intro_win(void);
void	do_intro(WINDOW *win, int ob);
void	setpopup(WINDOW *wdial, char *sets, int num);
int		load_setup(char **mem, long *len, int *dix);
int		do_popup(WINDOW *root, int parent, OBJECT *pop);
int		connect_win(void);
void	do_connect(WINDOW *win, int ob);
void	do_userpass(WINDOW *win, int ob);
void	establish(int *status, WINDOW *win);
void	ppp_error(void);
int		esettext(OBJECT *oerrep, int ob, int yn);
void	set_sock_inits(int fh);
void	time_wait(int ms);
int		do_step(int type, int ix, WINDOW *win, int fh, SCRIPT_STEP *script_step, int wait_to, int restart_to);
int		find_string(char *buf, int len, char *search, int *found_ix, int *searched);
int		find_char(char *buf, int len, char search, int *searched);
int		find_ip(char *buf, int len, char *store, int *found_ix, int *searched);
void	set_read_ip(char *rip);
void	do_terminal(int port);
void	new_line(char **line, int *cy);
void	enter_ip(void);
ulong fetch_ip(OBJECT *tree, int ob);
void	store_ip(OBJECT *tree, int ob, ulong ip);
int		user_input(char *titel, char *text);
int		secret_input(char *titel, char *text);
int		send_buf(char *sbuf, int fh);
void	set_cmd(WINDOW *win, char *cmd);
void	set_win(WINDOW *win, int stat, char *cmd, int process);
void	online_win(void);
void	do_online(WINDOW *win, int ob);
void	logout_win(void);
void	do_logoff(WINDOW *win, int ob);
void	logout_script(int *status, WINDOW *win);
int		change_to_set_bit(int fh);
void	change_to_8bit(int fh);
int		open_port(void);
void	hang_up(void);
void	encode(char *string, int len);
void	decode(char *string, int len);
void	sign_off(void);
void	read_service_ips(void);
void	read_proxy_ips(void);
void	log_online(void);
void	log_offline(void);

int		start_rsd_daemon(void);
void	term_rsd_daemon(void);
int		start_stip_app(void);
void	term_stip_app(void);
int		start_idp_server(void);
void	term_idp_server(void);
int		start_objects(void);
void	stop_objects(void);

int 	cdecl usis(USIS_REQUEST *request);
int		find_proxy(ulong *ip, int *port, char *service, char *host);
int		wild(char *string, char *pattern);
char	*gettext(int ob);

void	other_messages(int *pbuf);

int		check_preemptive(void);

/* -------------------------------------- */

void DTR_Fclose(int hd)
{
	long var=0;

	Fcntl(hd, (long)&var, TIOCOBAUD);
	var=0;
	Fcntl(hd, (long)&var, TIOCIBAUD);
	Fclose(hd);
}

int main(void)
{
	int ap_id2, fh;
	
	e_start_as(ACC|PRG,"IConnect fÅr PPP-Connect");
	ap_info.gunknown=other_messages;
	/* Accepts AP_TERM */
	shel_write(SHW_INFRECGN,1,0,NULL,NULL);
	
	/* Startpfad fÅr's spÑtere Speichern des Logfiles merken */
	strcpy(start_path, "x:\\");
	Dgetpath(&(start_path[3]), 0);
	start_path[0]=(char)Dgetdrv()+'A';
	if(start_path[strlen(start_path)-1]!='\\')
		strcat(start_path, "\\");

	strcpy(setup_path, "ICONNECT.CFG");
	setup.magic=0;
	if(shel_find(setup_path)!=0)
	{/* Setup laden */
		fh=(int)Fopen(setup_path, FO_READ);
		if(fh >= 0)
		{
			Fread(fh, sizeof(ICON_SETUP), &setup);
			Fclose(fh);
		}
	}
	if(ap_type & (ACC|PRG))
	{
		if(rsrc_load("ICONNECT.RSC")==0)
		{
			form_alert(1,"[3][Error reading RSC.][Cancel]");
			goto fin;
		}
		else
		{
			if(!find_cookie('SLIP', (long*)&socks))
			{
				form_alert(1,gettext(A1));
				goto rfin;
			}
			sock_init();
			_ol_=&(socks->defs->usis_time);
			_be_=&(socks->defs->usis_bytes);
			ap_id2=appl_find("ICONNECT");
			if(ap_id2 < 0) ap_id2=ap_id;
			if((socks->sys->server_pd != NULL) || (ap_id != ap_id2))
			{
				form_alert(1,gettext(A2));
				goto rfin;
			}
			/* Be sure to clear off serving flag on crash */
			Setexc(258,sign_off);		
			socks->sys->close_port();
			wind_get(0,WF_WORKXYWH,&sx,&sy,&sw,&sh);
			uses_vdi();
			uses_txwin();
			rsrc_init();
			if(start_rsd_daemon())
			do
			{
				if(ap_type==ACC)
					evnt_mesag(pbuf);
				else
					pbuf[0]=AC_OPEN;
				if(pbuf[0]==AC_OPEN)
					dial_intro_win();
			}while(ap_type==ACC);
		}
	}

rfin:
	if(objects_started) stop_objects();
	term_rsd_daemon();
	term_stip_app();
	term_idp_server();
	rsrc_free();
fin:
	if(ap_type==ACC)	/* DO NOT QUIT! */
	{
		while(1) evnt_timer(32767, 32767);
	}
	
	e_quit();
	return(0);
}

/* -------------------------------------- */

char *gettext(int ob)
{
	OBJECT *text_tree;
	
	rsrc_gaddr(0, STRINGS, &text_tree);
	return(text_tree[ob].ob_spec.free_string);
}

/* -------------------------------------- */

void rsrc_init(void)
{
	int a;
	OBJECT *odial;
	
	rsrc_gaddr(0,CONNECT,&odial);
	for(a=CONICON1; a <= CONICONLAST; ++a)
		odial[a].ob_y-=3;
	unselect_3d(odial, CONFRAME);

	rsrc_gaddr(0,ONLINE, &odial);
	unselect_3d(odial, ONLINEFRAME);
}

/* -------------------------------------- */

void dial_intro_win(void)
{
	char		*setsmem, *mem;
	long		setslen;
	int			dum, a, dix;
	WINDOW	wdial;
	DINFO		ddial;
	OBJECT	*odial;
	U_INTRO	uintro;
	STIC		*cp;
		
	if(load_setup(&setsmem, &setslen, &dix)==0) return;

	if(find_cookie('StIc', (long*)(&cp))==1)
	{
		rsrc_gaddr(0,STICICON,&odial);
		cp->ext_icon(ap_id, &(odial[BIGICON]), &(odial[SMALLICON]), 1);
	}

	rsrc_gaddr(0,INTRO,&odial);
	mem=setsmem;
	set_ext_type(odial, SETPOP, dix);
	while(dix--)
		mem+=sizeof(SETUP);
	strcpy(odial[SETPOP].ob_spec.free_string, mem);
	strcpy(odial[MAINVERSION].ob_spec.tedinfo->te_ptext, ICON_VERSION);
	strcpy(odial[MAINDATE].ob_spec.tedinfo->te_ptext, __DATE__);

	w_dinit(&wdial);
	g_sets=(SETUP*)setsmem;
	uintro.mem=setsmem;
	g_sets_count=uintro.num=(int)(setslen/sizeof(SETUP));
	(U_INTRO*)(wdial.user)=&uintro;	/* Anzahl der Setups */
	ddial.tree=odial;
	ddial.support=0;
	ddial.osmax=0;
	ddial.odmax=8;
	wdial.dinfo=&ddial;
	w_dial(&wdial, D_CENTER);
	ddial.dservice=NULL;
	ddial.dwservice=do_intro;
	ddial.dedit=0;

	do
	{
		global_state=ICMS_OFFLINE;
		intro_wind=&wdial;
		w_open(&wdial);
		
		while(wdial.open)
			w_devent(&dum,&dum,&dum,&dum,&dum);
		
		if(odial[MAINCANCEL].ob_state & SELECTED) 
		{
			odial[MAINCANCEL].ob_state &= (~SELECTED);
			w_kill(&wdial);
			free(setsmem);
			goto main_fin;
		}
		odial[MAINCONNECT].ob_state &= (~SELECTED);
		
		a=ext_type(odial, SETPOP);
		mem=setsmem;
		while(a--)
			mem+=sizeof(SETUP);
			
		set=*(SETUP*)mem;
		decode(set.ppp_auth_user, 80);
		decode(set.ppp_auth_pass, 80);
		decode(set.pop_user, 80);
		decode(set.pop_pass, 80);
		decode(set.nntp_user, 80);
		decode(set.nntp_pass, 80);
		/* Connect starten */
	}while(connect_win()==0);

main_fin:
	w_kill(&wdial);
	free(setsmem);
	if(find_cookie('StIc', (long*)(&cp))==1)
	{
		rsrc_gaddr(0,STICICON,&odial);
		cp->ext_icon(ap_id, &(odial[BIGICON]), &(odial[SMALLICON]), 0);
	}
}

/* -------------------------------------- */

void do_intro(WINDOW *win, int ob)
{
	switch(ob)
	{
		case SETPOP:
			setpopup(win, ((U_INTRO*)(win->user))->mem, ((U_INTRO*)(win->user))->num);
		break;
		case MAINCONNECT:
			if(check_preemptive()==0)
			{
				form_alert(1, gettext(NOPREEMPTIVE));
				w_unsel(win, ob);
				break;
			}
			if(Kbshift(-1) & 8)
			{
				form_alert(1,"[1][DEBUG option active][OK]");
				gdebug=1;
			}
			else
				gdebug=0;
		case MAINCANCEL:
			w_close(win);
		break;
	}
}

/* -------------------------------------- */

int check_userpass(void)
{
	int			dum, evnt;
	WINDOW	wdial;
	DINFO		ddial;
	OBJECT	*odial;

	/* Beides gesetzt oder via Mac-OS = OK */
	if((set.port==-1) || (set.ppp_auth_user[0] && set.ppp_auth_pass[0])) 
		return(1);
	
	rsrc_gaddr(0,USERPASS,&odial);
	objc_xted(odial, USERINPUT, 64, 0);
	objc_xted(odial, PASSINPUT, 64, '*');
	((CICONBLK*)(odial[ICON1].ob_spec.iconblk))->monoblk.ib_wtext=0;
	((CICONBLK*)(odial[ICON2].ob_spec.iconblk))->monoblk.ib_wtext=0;
	objc_xtedcpy(odial,USERINPUT, set.ppp_auth_user);
	objc_xtedcpy(odial,PASSINPUT, set.ppp_auth_pass);
	odial[ENTRYCANCEL].ob_state &= (~SELECTED);
	odial[ENTRYOK].ob_state &= (~SELECTED);
	
	w_dinit(&wdial);
	ddial.tree=odial;
	ddial.support=0;
	ddial.osmax=0;
	ddial.odmax=8;
	wdial.dinfo=&ddial;
	w_dial(&wdial, D_CENTER);
	ddial.dservice=NULL;
	ddial.dwservice=do_userpass;
	if(set.ppp_auth_user[0])
		ddial.dedit=PASSINPUT;
	else
		ddial.dedit=USERINPUT;
	wdial.name=set.name;
	w_set(&wdial, NAME);
	w_open(&wdial);

	while(wdial.open)
		w_dtimevent(&evnt,&dum,&dum,&dum,&dum,100,0);
	
	w_kill(&wdial);

	if(odial[ENTRYCANCEL].ob_state & SELECTED) return(0);

	strcpy(set.ppp_auth_user, xted(odial,USERINPUT)->te_ptext);
	strcpy(set.ppp_auth_pass, xted(odial,PASSINPUT)->te_ptext);

	return(1);
}

/* -------------------------------------- */

void do_userpass(WINDOW *win, int ob)
{
	if(ob)	/* Avoid Compiler-Warning! */
		w_close(win);
}

/* -------------------------------------- */

int run_mac_link(void)
{/* Cookie prÅfen (AUTOSTIP) und STIP nachstarten 
		ret: 1=OK, 0=Fehler */
	long	dum;
	
	if(find_cookie('STip', &dum)==0)
	{
		form_alert(1, gettext(NOAUTOSTIP));
		return(0);
	}
	return(start_stip_app());
}

/* -------------------------------------- */

int connect_win(void)
{
	int			dum, evnt, status;
	WINDOW	wdial;
	DINFO		ddial;
	OBJECT	*odial;

	/* Via Mac-OS und STIP installiert? */
	if(set.port==-1)
		if(run_mac_link()==0) return(0);
		
	global_state=ICMS_CONNECTING;
		
	if(check_userpass()==0) return(0);
	
	rsrc_gaddr(0,CONNECT,&odial);
	odial[CONPROCESS].ob_width=5;
	odial[CONPROCESS].ob_x=0;
	odial[CONSTATUS].ob_spec.tedinfo->te_ptext[0]=0;
	odial[CONCMD].ob_spec.tedinfo->te_ptext[0]=0;
	odial[CONCANCEL].ob_state &= (~SELECTED);
	odial[CONN_MESSAGE].ob_spec.tedinfo->te_ptext=CLEAR_STRING;
	
	w_dinit(&wdial);
	ddial.tree=odial;
	ddial.support=0;
	ddial.osmax=0;
	ddial.odmax=8;
	wdial.dinfo=&ddial;
	w_dial(&wdial, D_CENTER);
	ddial.dservice=NULL;
	ddial.dwservice=do_connect;
	ddial.dedit=0;
	wdial.name=set.name;
	w_set(&wdial, NAME);
	w_open(&wdial);

	status=ES_INITIAL;	
	while(wdial.open)
	{
		w_dtimevent(&evnt,&dum,&dum,&dum,&dum,100,0);
		/* Durch w_dtimevent kann der Event-Handler das
		   Fenster geschlossen haben (Abbruch-Button),
		   deshalb vor dem Timer nochmal prÅfen, ob das
		   Fenster noch offen ist */
		if(wdial.open && (evnt & MU_TIMER)) establish(&status, &wdial);
	}
	
	w_kill(&wdial);
	socks->defs->ppp_auth_user[0]=0;
	socks->defs->ppp_auth_pass[0]=0;
	
	if(odial[CONCANCEL].ob_state & SELECTED) 
		return(0);
	
	/* Online-Fenster starten */
	start_idp_server();
	objects_started=start_objects();
	online_win();
	return(1);
}

/* -------------------------------------- */

void do_connect(WINDOW *win, int ob)
{
	switch(ob)
	{
		case CONCANCEL:
			ob=ES_BREAK;
			establish(&ob, win);
		break;
	}
}

/* -------------------------------------- */

void establish(int *status, WINDOW *win)
{
	static 	int fh, script_step, step_complete, ppp_timeout, retry, buf_use;
	static	char	sbuf[51];
	int			res;
	ulong		tip, dns_delay;
	char		alert[128], *c, *d;
		
	switch(*status)
	{
		case ES_INITIAL:
			win->dinfo->tree[CONN_MESSAGE].ob_spec.tedinfo->te_ptext=CLEAR_STRING;
			w_objc_draw(win, CONN_MESSAGE, 8, sx,sy,sw,sh);
			if(set.port==-1)
			{
				initial=clock();
				set_win(win, STAT_MAC, "", 1);
				if(Test_Sync()==FALSE)
				{
					form_alert(1,gettext(NOMACSTIP));
					win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
					w_close(win);
					return;
				}
				*status=ES_INIT_SOCK;
				return;
			}
			hang_up_state=0;
			set_win(win, STAT_OPEN, "", 1);
			fh=open_port();
			if(fh <= 0)
			{
				win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
				w_close(win);
				return;
			}
			*status=ES_INIT_MODEM;
		break;

		case ES_INIT_MODEM:
			if(set.modem_init[0]==0)
			{
				*status=ES_DIAL;
				return;
			}
			set_win(win, STAT_MODEM, set.modem_init,2);
			/* Modempuffer leeren */
			Fwrite(fh, 1, "\r");
			while(Fread(fh, 20, sbuf));
			evnt_timer(100,0);

			strcpy(sbuf, set.modem_init); 
			if(send_buf(sbuf, fh)==0)
			{
				DTR_Fclose(fh);
				win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
				w_close(win);
				return;
			}
			evnt_timer(100,0);
			Fwrite(fh, 1, "\r");
			evnt_timer(100,0);
			retry=0;
			buf_use=0;
			*status=ES_WAIT_MODEM;
		break;
		
		case ES_WAIT_MODEM:
			++retry;	/* 1/10 Sekunden */
			if(retry > 100)	/* 10 Sekunden */
			{
				DTR_Fclose(fh);
				form_alert(1, gettext(A15));
				win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
				w_close(win);
				return;
			}
			res=(int)Fread(fh, 50-buf_use, &(sbuf[buf_use]));
			if(res < 0)
			{
				DTR_Fclose(fh);
				gemdos_alert(gettext(A17), res);
				win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
				w_close(win);
				return;
			}
			buf_use+=res;
			sbuf[buf_use]=0;
			if(strstr(sbuf, "OK"))
				*status=ES_DIAL;
		break;
		
		case ES_DIAL:
			hang_up_state=1;
			if(set.phone_number[0]==0)
			{
				*status=ES_START_SCRIPT;
				return;
			}
			set_win(win, STAT_DIAL, set.phone_number, 2);
			switch(set.dial_type)
			{
				case 0: strcpy(sbuf, "atdt "); break;
				case 1:	strcpy(sbuf, "atdp "); break;
				case 2: strcpy(sbuf, "atdi "); break;
			}
			strcat(sbuf, set.phone_number);
			strcat(sbuf, "\r");
			if(send_buf(sbuf, fh)==0)
			{
				DTR_Fclose(fh);
				win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
				w_close(win);
				return;
			}
			retry=0;
			buf_use=0;
			*status=ES_WAIT_DIAL;
		break;
		
		case ES_WAIT_DIAL:
			res=(int)Fread(fh, 50-buf_use, &(sbuf[buf_use]));
			if(res < 0)
			{
				gemdos_alert(gettext(A17), res);
				Fclose(fh);
				set_win(win, STAT_HANG_UP, "", 1);
				hang_up();
				win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
				w_close(win);
				return;
			}
			++retry;
			if(retry==600)	/* 60 Sekunden=Timeout */
			{
				form_alert(1, gettext(A16));
				Fclose(fh);
				set_win(win, STAT_HANG_UP, "", 1);
				hang_up();
				win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
				w_close(win);
				return;
			}
			buf_use+=res;
			sbuf[buf_use]=0;
			if( ((strstr(sbuf, "CONN")) || (strstr(sbuf, "CARR"))) && (!strstr(sbuf, "NO CARR")) )
			{
				c=sbuf; while((*c==13)||(*c==10)||(*c==' '))++c;
				strncpy(conn_msg, c, 63); conn_msg[63]=0;
				if((c=strchr(conn_msg, 13))==NULL) c=strchr(conn_msg, 10);
				if(!c) return;	/* Message noch nicht komplett */
				*c=0;
				win->dinfo->tree[CONN_MESSAGE].ob_spec.tedinfo->te_ptext=OTHER_STRING;
				strncpy(win->dinfo->tree[CONN_MESSAGE].ob_spec.tedinfo->te_ptext, conn_msg, 32);
				win->dinfo->tree[CONN_MESSAGE].ob_spec.tedinfo->te_ptext[32]=0;
				w_objc_draw(win, CONN_MESSAGE, 8, sx,sy,sw,sh);
				*status=ES_START_SCRIPT;
				return;
			}
			else if(strstr(sbuf, "BUSY"))
			{
				DTR_Fclose(fh);
				retry=set.redial_wait*10;
				*status=ES_RESTART_SCRIPT;
				set_win(win, STAT_BUSY, "", 0);
				win->dinfo->tree[CONN_MESSAGE].ob_spec.tedinfo->te_ptext=CLEAR_STRING;
				w_objc_draw(win, CONN_MESSAGE, 8, sx,sy,sw,sh);
				return;
			}
			else if(strnicmp(sbuf, "atd", 3))	/* Kein lokales Echo an oder wegkopiert*/
			{
				/* FÅhrende ZeilenumbrÅche und Leerzeichen entfernen */
				c=sbuf;
				while((*c==13)||(*c==10)||(*c==' ')) 
				{
					++c;
					d=c;
					while(*d) {*(d-1)=*d++; --buf_use;}
				}
				sbuf[buf_use]=0;

				/* Wenn jetzt immer noch Umbruch drin ist, ist eine Nachricht angekommen */				
				if(strchr(sbuf, 13) || strchr(sbuf, 10))
				{
					strcpy(alert, gettext(A18));	strcat(alert, sbuf);	
					strcat(alert, gettext(A19));
					c=alert;
					while(*c)
					{
						if((*c==13)||(*c==10)) *c=' ';
						++c;
					}
					form_alert(1,alert);
					DTR_Fclose(fh);
					win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
					w_close(win);
					return;
				}
			}
			else if(!strnicmp(sbuf, "atd", 3))	/* Mit lokalen Echo */
			{
				if( ((c=strchr(sbuf, 13))==NULL) && ((c=strchr(sbuf, 10))==NULL) )
					return; /* Echo noch nicht komplett */
				while((*c==13)||(*c==10)) ++c;
				/* Echo wegkopieren */
				buf_use=0;
				while(*c) sbuf[buf_use++]=*c++;
				sbuf[buf_use]=0;
			}
		break;

		case ES_START_SCRIPT:
			initial=clock();
			change_to_set_bit(fh);
			set_win(win, STAT_RUN, "", 3);
			script_step=0;
			step_complete=1;
			*status=ES_RUN_SCRIPT;
		break;
		
		case ES_RUN_SCRIPT:
			if(step_complete)	/* Next step */
				res=do_step(STEP_NEW,script_step, win, fh, set.login_step, set.login_wait_to, set.login_restart_to);
			else
				res=do_step(STEP_CONT,script_step, win, fh, set.login_step, set.login_wait_to, set.login_restart_to);
			switch(res)
			{
				case STEP_AGAIN: step_complete=0; return;
				case STEP_COMPLETE:
					step_complete=1;
					if(set.login_step[script_step].action != SC_DONE)
					{
						++script_step;
						return;
					}
					/* Script Done */
					if(set.login_step[script_step].param==1)
						socks->defs->using_ppp=1;
					else
						socks->defs->using_ppp=0;
					*status=ES_INIT_SOCK;
					set_win(win, STAT_RUN, "", 4);
				break;
				case STEP_RETRY:
					Fclose(fh);
					set_win(win, STAT_HANG_UP, "", 1);
					hang_up();
					retry=set.login_restart_to*10;
					*status=ES_RESTART_SCRIPT;
					set_win(win, STAT_WAITING, "", 0);
					win->dinfo->tree[CONN_MESSAGE].ob_spec.tedinfo->te_ptext=CLEAR_STRING;
					w_objc_draw(win, CONN_MESSAGE, 8, sx,sy,sw,sh);
				break;
				case STEP_CANCEL:
					Fclose(fh);
					set_win(win, STAT_HANG_UP, "", 1);
					hang_up();
					win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
					w_close(win);
				break;
			}
		break;
		
		case ES_RESTART_SCRIPT:
			hang_up_state=0;
			--retry;
			if((retry/10)*10 != ((retry+1)/10)*10)	/* Nur Neuaufbau wenn nîtig */
			{
				strcpy(sbuf, "Retry ");
				itoa(retry/10, &(sbuf[strlen(sbuf)]), 10);
				set_cmd(win, sbuf);
			}
			if(retry<=0)
				*status=ES_INITIAL;
		break;
		
		case ES_INIT_SOCK:
			set_win(win, STAT_SOCKET, "", 5);
			evnt_timer(1000,0); /* T-Online ISDN needs a break here */
			set_sock_inits(fh);
			set_win(win, STAT_SOCKET, "", 6);
			if((set.port==-1) && (socks->defs->stip_mem_ok==0))
			{
				form_alert(1, gettext(NOSTIPINIT));
				win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
				w_close(win);
				return;
			}
			
			if(socks->defs->using_ppp==1)
				*status=ES_INIT_PPP;
			else
				*status=ES_INIT_SLIP;
		break;

		case ES_INIT_PPP:
			set_win(win, STAT_PPP, "", 7);
			socks->sys->ppp_event(PEV_LOW_UP);
			socks->sys->ppp_event(PEV_ADMIN_OPEN);
			ppp_timeout=PPP_NEG_TO*10;
			*status=ES_LINK_PPP;
		break;
		case ES_LINK_PPP:
			if(--ppp_timeout <= 0)	/* Not connected in time */
			{
				ppp_error();
				set_win(win, STAT_HANG_UP, "", 1);
				w_redraw(win, sx,sy,sw,sh, 0);
				socks->sys->close_port();
				hang_up();
				win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
				w_close(win);
				return;
			}
			socks->sys->timer_jobs();
			if(socks->defs->ppp_suc)	/* Sign up complete */
			{/* Did i get local IP and DNS? */
				tip=socks->defs->my_ip;
				if((tip==0) || (tip==0xfffffffful))
				{
					ppp_error();
					set_win(win, STAT_HANG_UP, "", 1);
					w_redraw(win, sx,sy,sw,sh, 0);
					socks->sys->close_port();
					hang_up();
					win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
					w_close(win);
					return;
				}
				tip=socks->defs->name_server_ip;
				if((tip==0) || (tip==0xfffffffful))
				{
					ppp_error();
					set_win(win, STAT_HANG_UP, "", 1);
					w_redraw(win, sx,sy,sw,sh, 0);
					socks->sys->close_port();
					Fclose(fh);
					hang_up();
					win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
					w_close(win);
					return;
				}
				/* PPP successfull */
				set_win(win, STAT_PPP, "", 8);
				*status=ES_DONE;
			}
		break;
		
		case ES_INIT_SLIP:
		/* Only show */
			set_win(win, STAT_SLIP, "", 7);
			evnt_timer(100,0);
			set_win(win, STAT_SLIP, "", 8);
			*status=ES_DONE;
		break;
		
		case ES_DONE:
		/* Server und Proxies lesen */
			if(set.dns_initial_delay_set)
				dns_delay=set.dns_initial_delay*1000;
			else
				dns_delay=1000;
			if(dns_delay)
			{
				set_win(win, STAT_DNS_WAIT, "", 8);
				graf_mouse(BUSYBEE, NULL);
				evnt_timer((int)(dns_delay & 0xffff),(int) (dns_delay >> 16));	
				graf_mouse(ARROW, NULL);
			}
			set_win(win, STAT_GET_IP, "Service-EintrÑge", 8);
			read_service_ips();
			set_win(win, STAT_GET_IP, "Proxy-EintrÑge", 8);
			read_proxy_ips();
			w_close(win);
		break;
		
		case ES_BREAK:
			set_win(win, STAT_HANG_UP, "", 1);
			socks->sys->close_port();
			Fclose(fh);
			if(hang_up_state)
				hang_up();
			win->dinfo->tree[CONCANCEL].ob_state |= SELECTED;
			w_close(win);
		break;
	}
}

/* -------------------------------------- */

void ppp_error(void)
{
	int to_err;
	OBJECT *oerrrep;

	if(socks->defs->ppp_auth_nak)
		form_alert(1,gettext(A3));
	
	/* Prepare and show Error-Report */
	to_err=0;
	rsrc_gaddr(0, ERRREP, &oerrrep);
	to_err+=esettext(oerrrep, ERR1, socks->defs->ppp_crj_sent);
	to_err+=esettext(oerrrep, ERR2, socks->defs->ppp_crj_recv);
	to_err+=esettext(oerrrep, ERR3, socks->defs->ppp_prj_sent);
	to_err+=esettext(oerrrep, ERR4, socks->defs->ppp_prj_recv);
	to_err+=esettext(oerrrep, ERR5, socks->defs->ppp_auth_req);
	to_err+=esettext(oerrrep, ERR6, socks->defs->ppp_lqp_req);
	to_err+=esettext(oerrrep, ERR7, socks->defs->ipcp_address_rej);
	to_err+=esettext(oerrrep, ERR8, socks->defs->ipcp_dns_rej);
	if(to_err)	/* No Timeout-Error */
		esettext(oerrrep, ERR9, 0);
	else
		esettext(oerrrep, ERR9, 1);
	
	w_do_dial(oerrrep);
	oerrrep[ERRCANCEL].ob_state &= (~SELECTED);
}

int esettext(OBJECT *oerrrep, int ob, int yn)
{/* Set YES/no-text on yn 1/0 in ob of oerrrep */
 /* Return yn */
 
 if(yn)
 	strcpy(oerrrep[ob].ob_spec.free_string, gettext(SYES));
 else
 	strcpy(oerrrep[ob].ob_spec.free_string, gettext(SNO));

 return(yn);
}

/* -------------------------------------- */

ulong get_mac_ip(void)
{
	ulong ip, dum;
	
	if(GetMyIPAddr_Sync(&ip, &dum)==FALSE) return(0);
	return(ip);
}

/* -------------------------------------- */

void set_sock_inits(int fh)
{
	const 	int	ctick=20;			/* 10 */
	const		int ms_tick=50;		/* 100 */
	
	if(set.port==-1)
		socks->defs->using_mac_os=1;
	else
	{
		socks->defs->using_mac_os=0;
		socks->sys->terminate();
	}
	socks->defs->clk_tck=ctick;
	if(set.port==-1)
	{
		socks->defs->my_ip=get_mac_ip();
	}
	else if(socks->defs->using_ppp)
		socks->defs->my_ip=set.ppp_default_ip;
	else
		socks->defs->my_ip=set.default_ip;
	socks->defs->name_server_ip=set.dns_ip;
	socks->sys->emalloc=malloc;
	socks->sys->efree=free;
	socks->sys->etimer=time_wait;
	socks->sys->server_pd=_BasPag;
	socks->sys->_debug=(void*)gdebug;
	socks->user->usis=usis;
	socks->defs->dns_timeout=set.query_to;
	socks->defs->dns_retry=set.query_rt;
	socks->defs->ppp_max_configure=set.conf_retry;
	socks->defs->ppp_default_timer=set.conf_to/ms_tick;
	socks->defs->ppp_max_terminate=set.term_retry;
	socks->defs->ppp_terminate_timer=set.term_to/ms_tick;
	socks->defs->ppp_max_failure=set.nak_ack;
	socks->defs->ppp_lcp_echo_sec=set.lcp_echo_sec;
	socks->defs->port_init=set.min_port;
	socks->defs->port_max=set.max_port;
	socks->defs->max_listen=set.max_backlog;
	socks->defs->connection_timeout=set.conn_to;
	socks->defs->user_timeout=set.trans_to;
	if((socks->defs->snd_wnd=set.default_snd_win)==0)
		socks->defs->snd_wnd=512;
	socks->defs->rcv_wnd=set.default_rcv_win;
	socks->defs->allow_precedence_raise=set.precedence_raise & 1;
	socks->defs->disable_send_ahead=set.precedence_raise & 2;
	socks->defs->udp_count=set.max_udp_ports;
	socks->defs->kill_ip_timer=set.in_queue_to*ctick;
#ifdef TOS
#undef TOS
#endif
	socks->defs->TOS=set.tos;
#define TOS 8
	socks->defs->precedence=set.precedence;
	socks->defs->TTL=set.ttl;
	socks->defs->MTU=set.mtu;
	strcpy(socks->defs->ppp_auth_user, set.ppp_auth_user);
	strcpy(socks->defs->ppp_auth_pass, set.ppp_auth_pass);
	if(set.port > -1)
	{
		change_to_8bit(fh);
		socks->sys->open_port(fh);
	}
	else
	{
		socks->defs->stip_mem_ok=socks->sys->stip_init();
	}
}
void time_wait(int ms)
{
	evnt_timer(ms,0);
}

/* -------------------------------------- */

int do_step(int type, int ix, WINDOW *win, int fh, SCRIPT_STEP *script_step, int wait_to, int restart_to)
{/* type=STEP_NEW->new script step, STEP_CONT->continue with old step
		ix=index to login-script
		fh=File handle for modem port
		return:
		STEP_AGAIN=step not completed yet, call again with type=STEP_CONT
		STEP_COMPLETE=step completet, call with next step and type=STEP_NEW
		STEP_RETRY=timeout and retry occured
		STEP_CANCEL=timeout and cancel or fatal error occured
	*/
	
	static	int		timer, found_ix, buf_use=0, searched=0;
	static	char	inbuf[SCRIPT_IN_BUF], read_ip[MAX_READ_IP+1];	/* Trailing zero! */
					char	sbuf[40];
					int		a;
	
	/* Remove searched bytes from buffer */
	for(a=searched; a < buf_use; ++a)
		inbuf[a-searched]=inbuf[a];
	buf_use-=searched;
	searched=0;
	
	a=(int)Fread(fh, SCRIPT_IN_BUF-buf_use, &(inbuf[buf_use]));
	if(a < 0)
	{
		gemdos_alert(gettext(A11),buf_use);
		return(STEP_CANCEL);
	}
	buf_use+=a;
	if(type==STEP_NEW)
	{
		switch(script_step[ix].action)
		{
			case SC_DONE:
			return(STEP_COMPLETE);
			
			case SC_SEND_STRING:
				searched=buf_use;
				set_cmd(win, "Send String");
				strcpy(sbuf, script_step[ix].free_string);
				if(script_step[ix].param)	/* CR */
					strcat(sbuf, "\r");
				if(send_buf(sbuf, fh)==0) return(STEP_CANCEL);
			return(STEP_COMPLETE);

			case SC_SEND_CHAR:
				searched=buf_use;
				set_cmd(win, "Send Char");
				sbuf[0]=(char)(script_step[ix].param);
				sbuf[1]=0;
				if(send_buf(sbuf,fh)==0) return(STEP_CANCEL);
			return(STEP_COMPLETE);

			case SC_PAUSE:
				searched=buf_use;
				timer=script_step[ix].param*10;
				strcpy(sbuf, "Pause ");
				itoa(timer/10, &(sbuf[strlen(sbuf)]), 10);
				set_cmd(win, sbuf);
			return(STEP_AGAIN);

			case SC_WAIT_FOR:
				timer=wait_to*10;
				found_ix=0;
				strcpy(sbuf, "Wait for \"");
				strncat(sbuf, script_step[ix].free_string, 11);
				sbuf[20]=0;
				strcat(sbuf, "\" ");
				if(timer)
					itoa(timer/10, &(sbuf[strlen(sbuf)]), 10);
				else
					strcat(sbuf, "\xDF");		/* Indefinitely */
				set_cmd(win, sbuf);
				if(find_string(inbuf, buf_use, script_step[ix].free_string, &found_ix, &searched))
					return(STEP_COMPLETE);
			return(STEP_AGAIN);

			case SC_WAIT_CHAR:
				timer=wait_to*10;
				strcpy(sbuf, "Wait Char ");
				if(timer)
					itoa(timer/10, &(sbuf[strlen(sbuf)]), 10);
				else
					strcat(sbuf, "\xDF");		/* Indefinitely */
				set_cmd(win, sbuf);
				if(find_char(inbuf, buf_use, (char)(script_step[ix].param), &searched))
					return(STEP_COMPLETE);
			return(STEP_AGAIN);

/*
			case SC_USER_INPUT:
				searched=buf_use;
				set_cmd(win, "User input");
				sbuf[0]=0;
				if(user_input(script_step[ix].free_string, sbuf)==USERCANCEL) return(STEP_CANCEL);
				if(script_step[ix].param) strcat(sbuf, "\r");
				if(send_buf(sbuf, fh)==0) return(STEP_CANCEL);
			return(STEP_COMPLETE);

			case SC_SECRET_INPUT:
				searched=buf_use;
				set_cmd(win, "Secret input");
				sbuf[0]=0;
				if(secret_input(script_step[ix].free_string, sbuf)==USERCANCEL) return(STEP_CANCEL);
				if(script_step[ix].param) strcat(sbuf, "\r");
				if(send_buf(sbuf, fh)==0) return(STEP_CANCEL);
			return(STEP_COMPLETE);
*/
			case SC_USER_INPUT:
				searched=buf_use;
				set_cmd(win, "Send Username");
				strcpy(sbuf, set.ppp_auth_user);
				if(script_step[ix].param)	/* CR */
					strcat(sbuf, "\r");
				if(send_buf(sbuf, fh)==0) return(STEP_CANCEL);
			return(STEP_COMPLETE);

			case SC_SECRET_INPUT:
				searched=buf_use;
				set_cmd(win, "Send Password");
				strcpy(sbuf, set.ppp_auth_pass);
				if(script_step[ix].param)	/* CR */
					strcat(sbuf, "\r");
				if(send_buf(sbuf, fh)==0) return(STEP_CANCEL);
			return(STEP_COMPLETE);

			case SC_READ_IP:
				found_ix=0;
				a=find_ip(inbuf, buf_use, read_ip, &found_ix, &searched);
				strcpy(sbuf, "Read IP: ");
				strcat(sbuf, read_ip);
				set_cmd(win, sbuf);
				if(a)
				{
					set_read_ip(read_ip);
					return(STEP_COMPLETE);
				}
			return(STEP_AGAIN);

			case SC_TERMINAL_ON:
				searched=buf_use;
				set_cmd(win, "Terminal on");
				do_terminal(fh);
			return(STEP_COMPLETE);

			default:	/* Should never occur, unknown Script-step */
				form_alert(1,gettext(A4));
			return(STEP_CANCEL);
		}
	}
	
	/* type==STEP_CONT */
	switch(script_step[ix].action)
	{
		case SC_PAUSE:
			searched=buf_use;
			--timer;
			if((timer/10)*10 != ((timer+1)/10)*10)	/* Nur Neuaufbau wenn nîtig */
			{
				strcpy(sbuf, "Pause ");
				itoa(timer/10, &(sbuf[strlen(sbuf)]), 10);
				set_cmd(win, sbuf);
			}
			if(timer <= 0)
				return(STEP_COMPLETE);
		return(STEP_AGAIN);

		case SC_WAIT_FOR:
			if(timer != 0)	/* Timer in use */
			{
				--timer;
				if((timer/10)*10 != ((timer+1)/10)*10)	/* Nur Neuaufbau wenn nîtig */
				{
					strcpy(sbuf, "Wait for \"");
					strncat(sbuf, script_step[ix].free_string, 11);
					sbuf[20]=0;
					strcat(sbuf, "\" ");
					itoa(timer/10, &(sbuf[strlen(sbuf)]), 10);
					set_cmd(win, sbuf);
				}
				if(timer <= 0)	/* Timer expired */
				{
					if(restart_to==0) 
					{
						searched=buf_use;
						form_alert(1,gettext(A5));
						return(STEP_CANCEL);	/* No retry */
					}
					return(STEP_RETRY);
				}
			}
			if(find_string(inbuf, buf_use, script_step[ix].free_string, &found_ix, &searched))
				return(STEP_COMPLETE);
		return(STEP_AGAIN);

		case SC_WAIT_CHAR:
			if(timer != 0)	/* Timer in use */
			{
				--timer;
				if((timer/10)*10 != ((timer+1)/10)*10)	/* Nur Neuaufbau wenn nîtig */
				{
					strcpy(sbuf, "Wait Char ");
					itoa(timer/10, &(sbuf[strlen(sbuf)]), 10);
					set_cmd(win, sbuf);
				}
				if(timer <= 0)	/* Timer expired */
				{
					if(restart_to==0) 
					{
						searched=buf_use;
						form_alert(1,gettext(A6));
						return(STEP_CANCEL);	/* No retry */
					}
					return(STEP_RETRY);
				}
			}
			if(find_char(inbuf, buf_use, (char)(script_step[ix].param), &searched))
				return(STEP_COMPLETE);
		return(STEP_AGAIN);

		case SC_READ_IP:
			a=find_ip(inbuf, buf_use, read_ip, &found_ix, &searched);
			strcpy(sbuf, "Read IP: ");
			strcat(sbuf, read_ip);
			set_cmd(win, sbuf);
			if(a)
			{
				set_read_ip(read_ip);
				return(STEP_COMPLETE);
			}
		return(STEP_AGAIN);
	}

	/* Illegal STEP_AGAIN->internal error */
	form_alert(1,"[3][Internal error:|Illegal step call.][Cancel]");
	return(STEP_CANCEL);
}

/* -------------------------------------- */

int find_ip(char *buf, int len, char *store, int *found_ix, int *searched)
{
	if(*found_ix)	/* Search final space or ctrl-char */
	while(len--)
	{
		++*searched;

		if((store[(*found_ix)++]=*buf++)<=' ')
		{
			store[*found_ix]=0;
			return(1);
		}

		if(*found_ix==MAX_READ_IP-1)
		{
			store[MAX_READ_IP]=0;
			return(1);	/* Not finished, but regard it as complete (arghl) */
		}			
	}
	else while(len--)	/* Search for starting space or ctrl-char */
	{
		++*searched;
		
		if(*buf++ > ' ')
		{
			store[0]=*(buf-1);
			store[1]=0;
			*found_ix=1;
			return(find_ip(buf, len, store, found_ix, searched));
		}
	}
	store[*found_ix]=0;	
	return(0);
}

/* -------------------------------------- */

void set_read_ip(char *rip)
{
	set.default_ip=inet_addr(rip);
}

/* -------------------------------------- */

int find_string(char *buf, int len, char *search, int *found_ix, int *searched)
{
	int	flen=(int)strlen(search);
	
	while(len--)
	{
		++*searched;
		
		if(search[*found_ix]!=*buf)
			*found_ix=0;
			
		if(search[*found_ix]==*buf++)
		{
			++*found_ix;
			if(*found_ix==flen)	/* String complete */
				return(1);
		}
	}
	return(0);
}

/* -------------------------------------- */

int find_char(char *buf, int len, char search, int *searched)
{
	while(len--)
	{
		++*searched;
		if(*buf++==search) return(1);
	}
	return(0);
}

/* -------------------------------------- */
/* -------------------------------------- */

void do_terminal(int port)
{/* Opens the terminal, returns when closed 
		<port> ist the file handle of the Modem-port */
	WINDOW	win;
	TINFO		twin;
	char		*line[TERM_BUF_LINES];
	int			a, evnt, dum, swt, key, evret, ocy=0, cx, cy;
	char		buf[1024];
	long 		s_in, cnt;
	
	for(a=0; a < TERM_BUF_LINES; ++a)
	{
		line[a]=(char*)malloc(256);
		line[a][0]=0;
	}
	for(a=0; a < 25; ++a)
	{
		line[a][0]=' ';
		line[a][1]=0;
	}

	cx=0;
	cy=0;

	w_init(&win);
	twin.text=line;
	win.tinfo=&twin;
	win.name="Iconnect Terminal";
	w_text(&win);
	win.do_align=SIZE;
	
	strcpy(line[cy++], "Iconnect Terminal");
	strcpy(line[cy++], "-----------------");
	strcpy(line[cy++], "Press Alt+I to enter local IP");
	strcpy(line[cy++], "Press Alt+U to close terminal");
	strcpy(line[cy++], "(or click on the close-gadget)");
	
	while(strlen(line[0]) < 80) strcat(line[0],  " ");

	t_calc(&win);
	w_open(&win);
	w_txchange(&win);
	w_txfit(&win, T_HFIT|T_VFIT);
	
	line[cy][0]='_';
	line[cy][1]=0;

	w_modal(&win, MODAL_ON);
	while(win.open)
	{
		evret=w_dtimevent(&evnt, &dum, &dum, &swt, &key, 100,0);
		if(((evret==-2) || (evret==0)) && (port >= 0))
		{
			if(evnt & MU_KEYBD)
			{
				buf[0]=key & 255;
				if(swt==8) /* Alt-Kombination werden nicht abgeschickt */
				{
					if((key>>8)==22)	/* Alt+U */
						w_close(&win);
					else if((key>>8)==23)	/* Alt+I */
						enter_ip();
				}
				else if(buf[0])
					Fwrite(port, 1, buf);
			}
			if(evnt & MU_TIMER)
			{
				s_in=Fread(port, 1024, buf);
				cnt=0;

				while(cnt < s_in)
				{
					while(cnt < s_in)
					{
						if(cx >= 255)
						{
							line[cy][255]=0;
							new_line(line, &cy);
							cx=0;
						}
						if(buf[cnt] > 31)
							line[cy][cx++]=buf[cnt];
						else if(buf[cnt] == 13)
						{
							if(cx == 0)
								line[cy][cx++]=' ';
							line[cy][cx]=0;
							new_line(line, &cy);
							cx=0;
							strcpy(line[cy], " ");
						}
						else if(buf[cnt] == 8)
						{
							--cx;
							if(cx < 0)
								cx=0;
						}
						++cnt;
					}
				}
				if(cx >= 255)
				{
					line[cy][cx]=0;
					new_line(line, &cy);
					cx=0;
				}
				line[cy][cx]='_';
				line[cy][cx+1]=0;
				line[cy+1][0]=0;
				if(s_in)
				{
					if(ocy==cy)
						w_txlinechange(&win, cy);
					else
					{
						ocy=cy;
						w_txchange(&win);
						w_txgoto(&win, 0, cy-1);
					}
				}
			}
		}
	}

	w_modal(&win, MODAL_OFF);

	w_kill(&win);

	for(a=0; a < TERM_BUF_LINES; ++a)
		free(line[a]);
}

/* -------------------------------------- */

void new_line(char **line, int *cy)
{
	int		a;
	char	*ml=line[0];
	
	++*cy;
	if(*cy < TERM_BUF_LINES-1)
		return;
		
	for(a=0; a < TERM_BUF_LINES-1; ++a)
		line[a]=line[a+1];

	*cy=TERM_BUF_LINES-2;
	line[*cy]=ml;
	line[*cy][0]=0;
}


/* -------------------------------------- */

void enter_ip(void)
{
	OBJECT *iptree;
	
	rsrc_gaddr(0, LOCALIP, &iptree);
	store_ip(iptree, IPTEXT, set.default_ip);
	if(w_do_dial(iptree)==IPCANCEL)	return;
	set.default_ip=fetch_ip(iptree, IPTEXT);
}

/* -------------------------------------- */

ulong fetch_ip(OBJECT *tree, int ob)
{
	char	n[4];
	uchar i1, i2, i3, i4, len;
	ulong ip;

	len=(uchar)strlen(tree[ob].ob_spec.tedinfo->te_ptext);
	
	n[3]=0;
	strncpy(n, tree[ob].ob_spec.tedinfo->te_ptext, 3);
	i1=(uchar)atoi(n);
	if(len>3)
		i2=atoi(strncpy(n, &(tree[ob].ob_spec.tedinfo->te_ptext[3]), 3));
	else
		i2=0;
	if(len>6)
		i3=atoi(strncpy(n, &(tree[ob].ob_spec.tedinfo->te_ptext[6]), 3));
	else
		i3=0;
	if(len>9)
		i4=atoi(strncpy(n, &(tree[ob].ob_spec.tedinfo->te_ptext[9]), 3));
	else
		i4=0;

	ip=((ulong)i1<<24)+((ulong)i2<<16)+((ulong)i3<<8)+(ulong)i4;
	return(ip);
}

/* -------------------------------------- */

void store_ip(OBJECT *tree, int ob, ulong ip)
{
	int		one;
	char	num[4];
	
	one=(int)(ip>>24);
	itoa(one, num, 10);
	while(strlen(num)<3)strcat(num, " ");
	strcpy(tree[ob].ob_spec.tedinfo->te_ptext, num);

	one=(int)((ip>>16) & 255);
	itoa(one, num, 10);
	while(strlen(num)<3)strcat(num, " ");
	strcpy(&(tree[ob].ob_spec.tedinfo->te_ptext[3]), num);

	one=(int)((ip>>8) & 255);
	itoa(one, num, 10);
	while(strlen(num)<3)strcat(num, " ");
	strcpy(&(tree[ob].ob_spec.tedinfo->te_ptext[6]), num);

	one=(int)(ip & 255);
	itoa(one, num, 10);
	while(strlen(num)<3)strcat(num, " ");
	strcpy(&(tree[ob].ob_spec.tedinfo->te_ptext[9]), num);
}

/* -------------------------------------- */
/* -------------------------------------- */

int user_input(char *titel, char *text)
{
	OBJECT *user;
	
	rsrc_gaddr(0, USERENTRY, &user);

	user[USEROK].ob_state &= (~SELECTED);
	user[USERCANCEL].ob_state &= (~SELECTED);

	((TED_COLOR*)&(user[USERINPUT].ob_spec.tedinfo->te_color))->text_color=1;	/* Black */
	strcpy(user[USERTITEL].ob_spec.tedinfo->te_ptext, titel);
	user[USERINPUT].ob_spec.tedinfo->te_ptext=text;
	return(w_do_dial(user));
}

/* -------------------------------------- */

int secret_input(char *titel, char *text)
{
	OBJECT *user;
	
	rsrc_gaddr(0, USERENTRY, &user);

	user[USEROK].ob_state &= (~SELECTED);
	user[USERCANCEL].ob_state &= (~SELECTED);
	
	((TED_COLOR*)&(user[USERINPUT].ob_spec.tedinfo->te_color))->text_color=0;	/* White */
	strcpy(user[USERTITEL].ob_spec.tedinfo->te_ptext, titel);
	user[USERINPUT].ob_spec.tedinfo->te_ptext=text;
	return(w_do_dial(user));
}

/* -------------------------------------- */

int send_buf(char *sbuf, int fh)
{/* Send buf (0-terminated string) on handle fh 
		return: 1=success, 0=no way
	*/
	int		left, dum, maxtry;
	long	ret;

	left=(int)strlen(sbuf);
	maxtry=MAX_SEND_TRY*10;

	do
	{	
	/*
		if(set.dbits)	/* Nicht 8-Bit, einzeln verschicken */
			ret=Fwrite(fh, 1, sbuf);
		else */
			ret=Fwrite(fh, left, sbuf);
		if(ret < 0) {gemdos_alert(gettext(A11),ret); return(0);}
		sbuf+=ret;
		left-=(int)ret;
		w_dtimevent(&dum,&dum,&dum,&dum,&dum,100,0);
		--maxtry;
		if(maxtry==0) 
		{
			form_alert(1,gettext(A7));
			return(0);
		}
	}while(left > 0);
	
	return(1);
}

/* -------------------------------------- */

void set_cmd(WINDOW *win, char *cmd)
{
	if(win->dinfo->tree[0].ob_flags & RBUTTON)	/* Logoff-Script */
	{
		strcpy(win->dinfo->tree[CONOFFCMD].ob_spec.tedinfo->te_ptext, cmd);
		while(strlen(win->dinfo->tree[CONOFFCMD].ob_spec.tedinfo->te_ptext) < CMD_MAX_LEN)
			strcat(win->dinfo->tree[CONOFFCMD].ob_spec.tedinfo->te_ptext," ");
		w_objc_draw(win, CONOFFCMD, 8, sx,sy,sw,sh);
	}
	else
	{
		strcpy(win->dinfo->tree[CONCMD].ob_spec.tedinfo->te_ptext, cmd);
		while(strlen(win->dinfo->tree[CONCMD].ob_spec.tedinfo->te_ptext) < CMD_MAX_LEN)
			strcat(win->dinfo->tree[CONCMD].ob_spec.tedinfo->te_ptext," ");
		w_objc_draw(win, CONCMD, 8, sx,sy,sw,sh);
	}
}

/* -------------------------------------- */

void set_win(WINDOW *win, int stat, char *cmd, int process)
{
	OBJECT *stati;
	int		 pnum;
	
	rsrc_gaddr(0, STATIKA, &stati);

	strcpy(win->dinfo->tree[CONSTATUS].ob_spec.tedinfo->te_ptext, stati[stat].ob_spec.free_string);
	while(strlen(win->dinfo->tree[CONSTATUS].ob_spec.tedinfo->te_ptext) < CMD_MAX_LEN)
		strcat(win->dinfo->tree[CONSTATUS].ob_spec.tedinfo->te_ptext," ");
	strcpy(win->dinfo->tree[CONCMD].ob_spec.tedinfo->te_ptext, cmd);
	while(strlen(win->dinfo->tree[CONCMD].ob_spec.tedinfo->te_ptext) < CMD_MAX_LEN)
		strcat(win->dinfo->tree[CONCMD].ob_spec.tedinfo->te_ptext," ");
	pnum=(CONICONLAST-CONICON1+1)*2;
	if((win->dinfo->tree[CONPROCESS].ob_width=(win->dinfo->tree[CONFRAME].ob_width*process)/pnum) < 5)
		win->dinfo->tree[CONPROCESS].ob_width=5;
		
	w_objc_draw(win, CONDRAWFRAME, 8, sx,sy,sw,sh);
	w_objc_draw(win, CONSTATUS, 8, sx,sy,sw,sh);
	w_objc_draw(win, CONCMD, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */
/* -------------------------------------- */

void save_setup(void)
{
	int fh;
	
	fh=(int)Fcreate(setup_path, 0);
	if(fh < 0) return;
	Fwrite(fh, sizeof(ICON_SETUP), &setup);
	Fclose(fh);
}

void make_byte_string(long bytes, char *dst)
{/* Erstellt anhand 'bytes' einen String in dst,
		der nie lÑnger als 12 Zeichen ist.
		(xxxx.x XByte)
		'Bytes' wird je nach Grîûe in Byte, KByte, MByte oder GByte
		angegeben (mit einer Nachkommastelle), anschlieûend ein
		Leerzeichen und das Byte-KÅrzel eingefÅgt.
	*/
	char	*fak="Byte";
	long 	ac=0;
	
	if(bytes > 1024)
	{
		ac=bytes-(bytes/1024)*1024;
		bytes/=1024; fak="KByte";
	}
	if(bytes > 1024)
	{
		ac=bytes-(bytes/1024)*1024;
		bytes/=1024; fak="MByte";
	}
	if(bytes > 1024)
	{
		ac=bytes-(bytes/1024)*1024;
		bytes/=1024; fak="GByte";
	}
	
	ltoa(bytes, dst, 10);
	if(ac)
	{
		ac/=102;
		strcat(dst, ".");
		dst[strlen(dst)+1]=0;
		dst[strlen(dst)]=(char)ac+'0';
	}
	strcat(dst, " ");
	strcat(dst, fak);
}

void online_win(void)
{
	static	char lasttime[10];
	char		*titel="PPP-Connect";
	int			dum, evnt;
	WINDOW	wdial;
	DINFO		ddial;
	OBJECT	*odial;
	long		seconds, hours, minutes;

	#define timeob odial[ONLINETIME].ob_spec.tedinfo->te_ptext
	#define timelob &(timeob[strlen(timeob)])
	
	global_state=ICMS_ONLINE;

	log_online();

	online_wind=&wdial;
		
	rsrc_gaddr(0,ONLINE, &odial);
	strcpy(odial[ONLINENAME].ob_spec.tedinfo->te_ptext, set.name);
	strcpy(odial[LOCAL_IP].ob_spec.tedinfo->te_ptext, inet_ntoa(socks->defs->my_ip));
	strcpy(timeob, "00:00:00");
	strcpy(lasttime, "00:00:00");
	odial[ULED].ob_flags|=HIDETREE;
	
	w_dinit(&wdial);
	ddial.tree=odial;
	ddial.support=0;
	ddial.osmax=0;
	ddial.odmax=8;
	wdial.dinfo=&ddial;
	w_dial(&wdial, D_CENTER);
	ddial.dservice=NULL;
	ddial.dwservice=do_online;
	ddial.dedit=0;
	if(setup.magic=='ICWP')	/* Fensterpos setzen */
	{
		if(setup.wx < sx) setup.wx=sx;
		if(setup.wx + wdial.ww > sx+sw)	setup.wx=sx+sw-wdial.ww;
		if(setup.wy < sy) setup.wy=sy;
		if(setup.wy + wdial.wh > sy+sh) setup.wy=sy+sh-wdial.wh;
		wdial.wx=setup.wx;
		wdial.wy=setup.wy;
		w_calc(&wdial);
		odial[0].ob_x=wdial.ax+ddial.xdif;
		odial[0].ob_y=wdial.ay+ddial.ydif;
	}
	wdial.name=titel;
	w_set(&wdial, NAME);
	w_open(&wdial);

	while(wdial.open)
	{
		w_dtimevent(&evnt,&dum,&dum,&dum,&dum,50,0);	/* 100, 0 */
		if(!(evnt & MU_TIMER))
			continue;
		
		socks->sys->timer_jobs();
		/* Update timer */
		now=clock()-initial; _ol_->total_sec=now;
		seconds=(long)now/CLK_TCK;
		hours=seconds/3600; seconds-=hours*3600;
		minutes=seconds/60; seconds-=minutes*60;
		_ol_->hours=(int)hours; _ol_->minutes=(int)minutes; _ol_->seconds=(int)seconds;
		timeob[0]=0;
		while(hours > 100) hours-=100;
		if(hours < 10) strcpy(timeob, "0");
		ltoa(hours, timelob, 10);
		strcat(timeob, ":");
		if(minutes < 10) strcat(timeob, "0");
		ltoa(minutes, timelob, 10);
		strcat(timeob, ":");
		if(seconds < 10) strcat(timeob, "0");
		ltoa(seconds, timelob, 10);
		if(strcmp(timeob, lasttime))
		{
			strcpy(lasttime, timeob);
			w_objc_draw(&wdial, ONLINETIME, 8, sx,sy,sw,sh);
		}
		strcpy(_ol_->hh_mm_ss, timeob);
		
		/* Bytes exchange-ob setzen */
		_be_->bytes_sent=socks->defs->bytes_sent;
		_be_->bytes_rcvd=socks->defs->bytes_rcvd;
		make_byte_string(_be_->bytes_sent, _be_->t_sent);
		make_byte_string(_be_->bytes_rcvd, _be_->t_rcvd);
		
		/* LED anzeigen */
		if(g_resolve_count)
		{
			if(odial[ULED].ob_flags & HIDETREE)
			{
				odial[ULED].ob_flags &= (~HIDETREE);
				w_objc_draw(&wdial, ULED, 8, sx,sy,sw,sh);
			}
		}
		else if(!(odial[ULED].ob_flags & HIDETREE))
		{
			odial[ULED].ob_flags |= HIDETREE;
			w_objc_draw(&wdial, 0, 8, sx,sy,sw,sh); /* Redraw whole window to delete LED */
		}
	}

	save_setup();
	log_offline();
	w_kill(&wdial);

	logout_win();
}

/* -------------------------------------- */

void do_online(WINDOW *win, int ob)
{
	if(ob==ONLINECLOSE)
	{
		if(form_alert(1,gettext(A8))==2)
		{
			w_unsel(win, ob);
			return;
		}
		w_get(win);
		setup.magic='ICWP';
		setup.wx=win->wx;
		setup.wy=win->wy;
		w_close(win);
	}
}

/* -------------------------------------- */
/* -------------------------------------- */

void logout_win(void)
{
	int			dum, evnt, status, timeout=set.logout_hangup_to*10;
	WINDOW	wdial;
	DINFO		ddial;
	OBJECT	*odial;
	
	global_state=ICMS_CLOSING;

	rsrc_gaddr(0,LOGOFF,&odial);
	odial[CONOFFCMD].ob_spec.tedinfo->te_ptext[0]=0;
	odial[CONOFFCANCEL].ob_state &= (~SELECTED);
	odial[EXIT_SEL_OB].ob_state &= (~SELECTED);
	strcpy(odial[LOGOFFSTRING].ob_spec.tedinfo->te_ptext, gettext(STAT_NETCLOSE));
	w_dinit(&wdial);
	ddial.tree=odial;
	ddial.support=0;
	ddial.osmax=0;
	ddial.odmax=8;
	wdial.dinfo=&ddial;
	w_dial(&wdial, D_CENTER);
	ddial.dservice=NULL;
	ddial.dwservice=do_logoff;
	ddial.dedit=0;
	w_open(&wdial);
	
	/* Warten bis Fenster gezeichnet ist */
	do
	{
		w_dtimevent(&evnt,&dum,&dum,&dum,&dum,100,0);
	}while(evnt & MU_MESAG);

	/* Netzwerk abbauen */	
	graf_mouse(BUSYBEE, NULL);
	socks->sys->terminate();
	if(set.port > -1) socks->sys->close_port();
	socks->sys->server_pd=NULL;
	graf_mouse(ARROW, NULL);

	if((set.port == -1) || (set.logout_step[0].action == SC_DONE)) goto _no_script;

	strcpy(odial[LOGOFFSTRING].ob_spec.tedinfo->te_ptext, gettext(STAT_LOGOFFSCR));
	w_objc_draw(&wdial, LOGOFFSTRING, 8, sx,sy,sw,sh);
	status=ES_INITIAL;	
	
	if(timeout==0)	while(!(odial[EXIT_SEL_OB].ob_state & SELECTED))
	{
		w_dtimevent(&evnt,&dum,&dum,&dum,&dum,100,0);
		if(evnt & MU_TIMER) logout_script(&status, &wdial);
	}
	else	while(!(odial[EXIT_SEL_OB].ob_state & SELECTED))
	{
		w_dtimevent(&evnt,&dum,&dum,&dum,&dum,100,0);
		if(--timeout<=0)
			status=ES_BREAK;
		if(evnt & MU_TIMER) logout_script(&status, &wdial);
	}

_no_script:

	/* Modem auflegen */
	if(set.port==-1)
	{
		/* Verbindung kann jetzt auf Mac-Seite beendet werden */
		/* form_alert(1, gettext(MACHANGUP)); */
	}
	else
	{
		strcpy(odial[LOGOFFSTRING].ob_spec.tedinfo->te_ptext, gettext(STAT_HANGUP));
		w_objc_draw(&wdial, LOGOFFSTRING, 8, sx,sy,sw,sh);
	
		hang_up();
	}
	w_close(&wdial);
	w_kill(&wdial);
}

/* -------------------------------------- */

void do_logoff(WINDOW *win, int ob)
{
	if(ob==CONOFFCANCEL)
	{
		ob=ES_BREAK;
		logout_script(&ob, win);
	}
}

/* -------------------------------------- */

void logout_script(int *status, WINDOW *win)
{
	static 	int fh, script_step, step_complete;
	int			res;
	
	switch(*status)
	{
		case ES_INITIAL:
			fh=open_port();
			if(fh <= 0)
			{
				win->dinfo->tree[CONOFFCANCEL].ob_state |= SELECTED;
				win->dinfo->tree[EXIT_SEL_OB].ob_state |= SELECTED;
				return;
			}
			*status=ES_START_SCRIPT;
		break;
		
		case ES_START_SCRIPT:
			script_step=0;
			step_complete=1;
			*status=ES_RUN_SCRIPT;
		break;
		
		case ES_RUN_SCRIPT:
			if(step_complete)	/* Next step */
				res=do_step(STEP_NEW,script_step, win, fh, set.logout_step, set.logout_wait_to, 0);
			else
				res=do_step(STEP_CONT,script_step, win, fh, set.logout_step, set.logout_wait_to, 0);
			switch(res)
			{
				case STEP_AGAIN: step_complete=0; return;
				case STEP_COMPLETE:
					step_complete=1;
					++script_step;
					if(set.logout_step[script_step].action != SC_DONE) return;
					/* Script Done */
					Fclose(fh);
					*status=ES_DONE;
				break;
				case STEP_CANCEL:
					Fclose(fh);
					win->dinfo->tree[CONOFFCANCEL].ob_state |= SELECTED;
					win->dinfo->tree[EXIT_SEL_OB].ob_state |= SELECTED;
				break;
			}
		break;

		case ES_DONE:
			win->dinfo->tree[EXIT_SEL_OB].ob_state |= SELECTED;
		break;
		
		case ES_BREAK:
			Fclose(fh);
			win->dinfo->tree[CONOFFCANCEL].ob_state |= SELECTED;
			win->dinfo->tree[EXIT_SEL_OB].ob_state |= SELECTED;
		break;
	}
}

/* -------------------------------------- */
/* -------------------------------------- */

void my_gethostbyname(char *c, int request_id)
{
	int	pbuf[8];
	
	pbuf[0]=RSDAEMON_MSG;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	pbuf[3]=RSD_REQUEST_IP;
	pbuf[4]=request_id;
	*(char**)(&(pbuf[5]))=c;
	appl_write(rsd_id, 16, pbuf);
	g_resolve_count++;
}

void enter_rsdaemon_reply(int *pbuf)
{/* Antwort von Rsdaemon einordnen */
	int	index;
	ulong		*act_ip;
	
	/* HellgrÅne LED */
	online_wind->dinfo->tree[ULED].ob_spec.bitblk->bi_color=3;
	w_objc_draw(online_wind, ULED, 8, sx,sy,sw,sh);

	g_resolve_count--; 
	if(g_resolve_count < 0) g_resolve_count=0;	/* You'll never know... */
	
	index=pbuf[4] & 0x3f;	/* Bit 6 (0x40) steht fÅr Proxy-Anfrage, Bit 7 unbenutzt, trotzdem ausmaskieren */

	if(pbuf[4] & 0x40) 	/* War Proxy-Anfrage */
	{
		if(pbuf[3]==RSD_IP_UNKNOWN)
			set.proxies[index].ip=0;
		else
			set.proxies[index].ip=*(ulong*)(&(pbuf[5]));
	}
	else							/* War Service Anfrage */
	{
		act_ip=&(set.pop_ip);
		while(index--) ++act_ip;
		if(pbuf[3]==RSD_IP_UNKNOWN)
			*act_ip=0;
		else
			*act_ip=*(ulong*)(&(pbuf[5]));
	}
	/* DunkelgrÅne LED */

	evnt_timer(100,0);
	online_wind->dinfo->tree[ULED].ob_spec.bitblk->bi_color=11;
	w_objc_draw(online_wind, ULED, 8, sx,sy,sw,sh);
}

void	read_service_ips(void)
{
	int 		a;
	ulong		*act_ip;
	char		*act_serv;

	g_resolve_count=0;
		
	act_ip=&(set.pop_ip);
	act_serv=&(set.service_names[0][0]);
	
	for(a=0; a < 24; ++a)
	{
		if((*act_ip == 0) && (act_serv[0]!=0))
			my_gethostbyname(act_serv, a);
		else 
			*act_ip=0;
		++act_ip;
		act_serv+=66;	/* 66 Zeichen pro Eintrag */
	}
}

void	read_proxy_ips(void)
{
	int 		a;
	ulong		*act_ip;
	char		*act_serv;
	
	act_serv=&(set.proxy_names[0][0]);
	
	for(a=0; a < 10; ++a)
	{
		act_ip=&(set.proxies[a].ip);
		if((*act_ip == 0) && (act_serv[0]!=0))
			my_gethostbyname(act_serv, a | 0x40);	/* Bit 6 steht fÅr Proxy-Anfrage */
		else
			*act_ip=0;
		act_serv+=66;	/* 66 Zeichen pro Eintrag */
	}
}

/* -------------------------------------- */
/* -------------------------------------- */

void setpopup(WINDOW *wdial, char *sets, int num)
{/* Popup aller Setups erstellen, aufrufen und Auswahl in Poproot und
		ext_ob eintragen. Neues Setup darstellen */
	OBJECT 	*tree, *root;
	char		*strings;
	int			a;
	long		slen;
	
	/* Sets ok? */
	if(num==0) return;

	rsrc_gaddr(0, SETUPPOP, &root);
	slen=strlen(root[1].ob_spec.free_string)+4; /* Zwei Space vorne, eins hinten, eine 0 */
	
	tree=malloc((num+1)*sizeof(OBJECT)+num*slen);
	strings=(char*)&(tree[num+1]);
	tree[0]=root[0];
	tree[0].ob_tail=num;
	tree[0].ob_height=root[1].ob_height*num;
	for(a=1; a <= num; ++a)
	{
		tree[a]=root[1];
		tree[a].ob_next=a+1;
		tree[a].ob_flags &=(~LASTOB);
		tree[a].ob_spec.free_string=strings;
		strcpy(strings, "  ");
		strcat(strings, sets);
		strings+=slen;
		tree[a].ob_y=root[1].ob_height*(a-1);
		sets+=sizeof(SETUP);
	}
	tree[num].ob_next=0;
	tree[num].ob_flags|=LASTOB;
	a=do_popup(wdial, SETPOP, tree);
	free(tree);
}

/* -------------------------------------- */

int load_setup(char **mem, long *len, int *dix)
{/* File format:
		4 Bytes magic : ICFG
		2 Bytes int:    sizeof(SETUP)
		2 Bytes int:    number of following entries
		<number> * sizeof(SETUP) Bytes=Setup data equal to SETUP-struct
		
		return 1 on success, else 0
 */
	#ifdef gemret
		#undef gemret
	#endif
	#define gemret(a,b) {gemdos_alert(a,b);Fclose(fh);return(0);}
	long	fhl, id;
	int 	fh, setsize, entries, a;
	char	path[256];
	SETUP	*setup;
	
	strcpy(path, "ICONFSET.CFG");
	/* Datei da? */
	if(shel_find(path)==0)
	{
		form_alert(1,gettext(A9));
		return(0);
	}
	
	fhl=Fopen(path, FO_READ);
	fh=(int)fhl;
	if(fhl < 0) gemret("Can\'t open INCONFSET.CFG", fhl);
	
	fhl=Fread(fh, 4, &id);
	if(fhl < 0) gemret("Can\'t read file ID", fhl);
	if(fhl < 4) {Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|File size too small (<4).][Cancel]"); return(0);}
	
	if(id != 'ICFG')
		{Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|Wrong ID.][Cancel]"); return(0);}

	fhl=Fread(fh, 2, &setsize);
	if(fhl < 0) gemret("Can\'t read size of entries", fhl);
	if(fhl < 2) {Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|File size too small (<6).][Cancel]"); return(0);}
	if(setsize != sizeof(SETUP))
		if(setsize != sizeof(SETUP)-2*80)	/* Falsches Dateiformat */
			if(setsize != sizeof(SETUP)-2*80-34*66)
				{Fclose(fh); form_alert(1,"[3][Wrong format in ICONFSET.CFG.|Get a newer version of ICONFSET.PRG.][Cancel]"); return(0);}

	fhl=Fread(fh, 2, &entries);
	if(fhl < 0) gemret("Can\'t read number of entries", fhl);
	if(fhl < 2) {Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|File size too small (<8).][Cancel]"); return(0);}
	if(entries < 1)
		{Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|Illegal number of setups.][Cancel]"); return(0);}

	fhl=Fread(fh, 2, dix);
	if(fhl < 0) gemret("Can\'t read default setup", fhl);
	if(fhl < 2) {Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|File size too small (<10).][Cancel]"); return(0);}
	if(*dix >= entries)
		{Fclose(fh); form_alert(1,"[3][ICONFSET.CFG is corrupted.|Illegal default setup.][Cancel]"); return(0);}

	*len=(long)((long)sizeof(SETUP)*(long)entries);
	*mem=(char*)malloc(*len);
	if(mem==NULL) gemret("Can\'t load setups.", ENSMEM);

	/* Altes Format */	
	if(setsize == sizeof(SETUP)-2*80-2*80-34*66)
	{/* Version 0 */
		setup=(SETUP*)*mem;
		while(entries--)
		{
			fhl=Fread(fh, setsize, setup);
			if(fhl < 0)	{free(*mem); gemret("Error reading Setup",fhl);}
			if(fhl < setsize)
			{
				Fclose(fh);
				free(*mem);
				form_alert(1,"[3][ICONFSET.CFG is corrupted.|File too small, setup incomplete.][Cancel]");
				return(0);
			}
			setup->version=ICON_SETUP_VERSION;
			for(a=0; a < 24; ++a)	setup->service_names[a][0]=0;
			for(a=0; a < 10; ++a)	setup->proxy_names[a][0]=0;
			setup->pop_user[0]=0;
			setup->pop_pass[0]=0;
			setup->nntp_user[0]=0;
			setup->nntp_pass[0]=0;
			++setup;
		}
	}
	else if(setsize == sizeof(SETUP)-2*80-2*80)
	{/* Version 1 */
		setup=(SETUP*)*mem;
		while(entries--)
		{
			fhl=Fread(fh, setsize, setup);
			if(fhl < 0)	{free(*mem); gemret("Error reading Setup",fhl);}
			if(fhl < setsize)
			{
				Fclose(fh);
				free(*mem);
				form_alert(1,"[3][ICONFSET.CFG is corrupted.|File too small, setup incomplete.][Cancel]");
				return(0);
			}
			setup->version=ICON_SETUP_VERSION;
			setup->pop_user[0]=0;
			setup->pop_pass[0]=0;
			setup->nntp_user[0]=0;
			setup->nntp_pass[0]=0;
			++setup;
		}
	}
	else if(setsize == sizeof(SETUP)-2*80)
	{/* Version 2 */
		setup=(SETUP*)*mem;
		while(entries--)
		{
			fhl=Fread(fh, setsize, setup);
			if(fhl < 0)	{free(*mem); gemret("Error reading Setup",fhl);}
			if(fhl < setsize)
			{
				Fclose(fh);
				free(*mem);
				form_alert(1,"[3][ICONFSET.CFG is corrupted.|File too small, setup incomplete.][Cancel]");
				return(0);
			}
			setup->version=ICON_SETUP_VERSION;
			setup->nntp_user[0]=0;
			setup->nntp_pass[0]=0;
			++setup;
		}
	}
	else
	{/* Version 3 */
		fhl=Fread(fh, *len, *mem);
		if(fhl < 0)	{free(*mem); gemret("Error reading Setup",fhl);}
		if(fhl < *len)
		{
			Fclose(fh);
			free(*mem);
			form_alert(1,"[3][ICONFSET.CFG is corrupted.|File too small, setup incomplete.][Cancel]");
			return(0);
		}
	}
					
	Fclose(fh);	
	return(1);
}

/* -------------------------------------- */

int do_popup(WINDOW *root, int parent, OBJECT *pop)
{/* ôffnet das Popup pop an x/y von root->dinfo->dtree[PRPOP]
		Vorauswahl (Check) und Y-Pos. werden an root-ext_type
		angepaût.
		Wenn Auswahl getroffen wird, wird Text aus pop ohne die
		ersten zwei Zeichen nach root kopiert und fÅr dieses ein
		Redraw ausgelîst.
		Gibt 1 zurÅck, wenn énderung vorgenommen wurde, sonst 0
 */
    
	int 	x,y,a,b;
	OBJECT *oroot=root->dinfo->tree;
	
	b=oroot[parent].ob_type >> 8;
		
	a=0;
	do
	{
		++a;
		pop[a].ob_state &= (~CHECKED);
	}while(!(pop[a].ob_flags & LASTOB));

	pop[b+1].ob_state |= CHECKED;
	objc_offset(oroot, parent, &x, &y);
	y-=b*pop[1].ob_height;

	if(y < sy) y=sy;
	if(y+pop[0].ob_height > sy+sh)
		y=sy+sh-pop[0].ob_height;
	if(x < sx) x=sx;
	if(x+pop[0].ob_width > sx+sw)
		x=sx+sw-pop[0].ob_width;

	a=form_popup(pop, x, y)-1;
	if((a > -1) && (a != b))
	{
		strcpy(oroot[parent].ob_spec.free_string,	&(pop[a+1].ob_spec.free_string[2]));
		w_objc_draw(root, parent, 8, sx, sy, sw, sh);		
		set_ext_type(oroot,parent,a);
		return(1);
	}
	return(0);
}

/* -------------------------------------- */

int change_to_set_bit(int fh)
{
	uint var;

	if(set.dbits==0) return(fh);	/* Steht schon auf 8Bit */
	
	var=0;
	Fcntl(fh, (long)&var, TIOCGFLAGS);

	/* Zu Ñndernde Parameter ausmaskieren */
	var&=(~(TF_STOPBITS|TF_CHARBITS|TF_FLAG));
	evnt_timer(1000,0);
	/* Parameter reinodern */
	switch(set.parity) /* Parity: off, odd, even */
	{
		case 1: var|=T_ODDP; break;
		case 2: var|=T_EVENP; break;
	}
	switch(set.dbits) /* Datenbits: 8,7,6,5 */
	{
		case 0: var|=TF_8BIT; break;
		case 1: var|=TF_7BIT; break;
		case 2: var|=TF_6BIT; break;
		case 3: var|=TF_5BIT; break;
	}
	switch(set.sbits) /* Stopbits: 1, 1.5, 2 */
	{
		case 0: var|=TF_1STOP; break;
		case 1: var|=TF_15STOP; break;
		case 2: var|=TF_2STOP; break;
	}
	Fcntl(fh, (long)&var, TIOCSFLAGS);

	return(fh);
}

/* -------------------------------------- */

void change_to_8bit(int fh)
{
	uint	var;

	if(set.dbits==0) return;	/* Steht schon auf 8Bit */

	var=0;
	Fcntl(fh, (long)&var, TIOCGFLAGS);

	/* Zu Ñndernde Parameter ausmaskieren */
	var&=(~(TF_STOPBITS|TF_CHARBITS|TF_FLAG));

	/* Parameter reinodern */
	/* Keine Parity=0 */
	var|=TF_8BIT;
	var|=TF_1STOP;

	Fcntl(fh, (long)&var, TIOCSFLAGS);
	return;
}

/* -------------------------------------- */

int open_port(void)
{/* Versucht den Port mit den Parametern aus Dialog einzustellen 
	r: >=1=ok, Filehandle fÅr Port , 0=Fehler 
*/

	long hd, var, var2;
	int	 hdi;
	char path[256];
	#define NUM_BAUD 16
	char *baud_names[NUM_BAUD]=
	{"230400","115200","57600","38400","28800","19200","14400","9600",
 	"4800","3600","2400","2000","1800","1200","600","300"};

	#ifdef gemret
		#undef gemret
	#endif
	#define gemret(a) {gemdos_alert(a, hd); Fclose(hdi); return(0);}

	strcpy(path, "U:\\DEV\\");
	strcat(path, set.port_name);
	hd=Fopen(path, FO_RW);
	if(hd < 0)	{gemdos_alert(gettext(A13),hd);return(0);}

	hdi=(int)hd;	
	/* Parameter setzen */
	var=atol(baud_names[set.baud]);
	hd=Fcntl(hdi, (long)&var, TIOCIBAUD);
	if(hd < 0)	gemret("Can\'t set baud-in-rate.");

	var=atol(baud_names[set.baud]);
	hd=Fcntl(hdi, (long)&var, TIOCOBAUD);
	if(hd < 0)	gemret("Can\'t set baud-out-rate.");

	var=0;
	hd=Fcntl(hdi, (long)&var, TIOCGFLAGS);
	if(hd < 0)	gemret("Can\'t request port-setup.");

	/* Zu Ñndernde Parameter ausmaskieren */
	var2=TF_STOPBITS|TF_CHARBITS|TF_FLAG;
	var2<<=16;
	var2=~var2;
	var&=var2;

	var2=0;
	/* Parameter reinodern */
	switch(set.hshake)	/* Handshake: off,xon/xoff,rts/cts */
	{
		case 1:	var2|=T_TANDEM; break;
		case 2: var2|=T_RTSCTS; break;
	}
	
	/* Parity immmer aus, erst beim Script umstellen */
	/* var2|=0; */
	/* Datenbits immer 8, erst beim Script umstellen */
	var2|=TF_8BIT;
	/* Stopbits immer 1, erst beim Scrip umstellen */
	var2|=TF_1STOP;

	/* Gesamtvariable setzen */
	var2<<=16;
	var|=var2;
	
	hd=Fcntl(hdi, (long)&var, TIOCSFLAGS);
	if(hd < 0) gemret("Can\'t set port parameters.");

	return(hdi);
}

/* -------------------------------------- */

void hang_up(void)
{
	int	 hdi;
	long	var;
	char	path[256];
	
	strcpy(path, "U:\\DEV\\");
	strcat(path, set.port_name);

	if((hdi=open_port())==0)
	{
		form_alert(1,gettext(A10));
		return;
	}

	graf_mouse(BUSYBEE, NULL);

	if(set.hang_use_dtr)
	{	/* DTR Parameter setzen (Baud=0) */
		var=0;
		Fcntl(hdi, (long)&var, TIOCOBAUD);
		var=0;
		Fcntl(hdi, (long)&var, TIOCIBAUD);
		evnt_timer(2000, 0);
		Fclose(hdi);
		/* MagiCMac-Special: */
		if(find_cookie('MgMc', &var)) Fdelete(path);

		graf_mouse(ARROW, NULL);
		return;
	}

	/* Befehle ausfÅhren */
	evnt_timer(set.hang_wait*1000, 0);
	send_buf(set.hang_escape, hdi);
	evnt_timer(set.hang_wait*1000, 0);
	send_buf(set.hang_at, hdi);
	send_buf("\r", hdi);
	Fcntl( hdi, -5, TIOCFLUSH); /* Flush Send-buffer, 1 sec. timeout */
	Fcntl( hdi, 1, TIOCFLUSH); 	/* Flush Recv-buffer */
	/* Drop DTR */
	var=0;
	Fcntl(hdi, (long)&var, TIOCOBAUD);
	var=0;
	Fcntl(hdi, (long)&var, TIOCIBAUD);
	Fclose(hdi);

	/* MagiCMac-Special: Lîschen der Schnittstelle = Auflegen */
/*	if(find_cookie('MgMc', &var)) Fdelete(path);*/
	graf_mouse(ARROW, NULL);
}

/* -------------------------------------- */

void encode(char *string, int len)
{
	uchar	seed, *str=(uchar*)string;
	int a;
	
	seed=(uchar)clock();
	
	str[len-1]=seed;

	srand(seed);

	for(a=0; a < (len-1); ++a)
	{
		str[a]^=(uchar)random(256);
	}
}

void decode(char *string, int len)
{
	uchar	seed, *str=(uchar*)string;
	int		a;
	
	seed=str[len-1];
	
	srand(seed);

	for(a=0; a < (len-1); ++a)
	{
		str[a]^=(uchar)random(256);
	}
	str[len-1]=0;
}

/* -------------------------------------- */
/* -------------------------------------- */


void write_log_entry(char *text)
{
	int 		fh;
	char 		log_path[256];
	time_t	tt=time(NULL);
	
	strcpy(log_path, start_path);
	strcat(log_path, "ONLINE.LOG");
	
	fh=(int)Fopen(log_path, FO_WRITE);
	if(fh < 0) /* Datei gibt's wohl noch nicht. */
	{
		fh=(int)Fcreate(log_path, 0);
		if(fh < 0) return;
	}

	Fseek(0, fh, 2);	
	Fwrite(fh, strlen(text), text);
	Fwrite(fh, 1, "\t");	/* Tabstop */
	Fwrite(fh, strlen(ctime(&tt)), ctime(&tt));
	Fclose(fh);
}

void log_online(void)
{
	char text[50];
	
	strcpy(text, "ONLINE ");
	strcat(text, set.name);
	write_log_entry(text);
}

void log_offline(void)
{
	char text[50];

	strcpy(text, "OFFLINE ");
	strcat(text, set.name);
	write_log_entry(text);
}

/* -------------------------------------- */

void start_file(char *file)
{
	pbuf[0]=AV_STARTPROG;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	*((char**)(&pbuf[3]))=file;
	pbuf[5]=pbuf[6]=0;
	pbuf[7]=3210; /* Magic */
	appl_write(0, 16, pbuf);

	pbuf[0]=0;
	do
	{
		socks->sys->timer_jobs();
		evnt_timer(20,0);
		appl_read(-1, 16, pbuf);	
	}while(pbuf[0]!=VA_PROGSTART);
}

void stop_file(char *file)
{
	int id;
	char	app[9];
	
	strncpy(app, file, 8); app[8]=0;
	if(strchr(app, '.')) *strchr(app, '.')=0;
	while(strlen(app) < 8) strcat(app, " ");
	if((id=appl_find(app)) < 0) return;
	
	pbuf[0]=AP_TERM;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	appl_write(id, 16, pbuf);
}

int start_objects(void)
{
	char	search_path[256];
	char	run_path[256];
	DTA	dta, *old_dta=Fgetdta();
	
	strcpy(search_path, start_path);
	strcat(search_path, "START\\*.*");
	Fsetdta(&dta);
	if(!Fsfirst(search_path, 0))	do
	{
		strcpy(run_path, start_path);
		strcat(run_path, "START\\");
		strcat(run_path, dta.d_fname);
		start_file(run_path);
	} while(!Fsnext());
	Fsetdta(old_dta);	
	return(1);
}

void stop_objects(void)
{
	char	search_path[256], *c;
	char	run_path[256];
	DTA	dta, *old_dta=Fgetdta();
	
	strcpy(search_path, start_path);
	strcat(search_path, "STOP\\*.*");
	Fsetdta(&dta);
	if(!Fsfirst(search_path, 0))	do
	{
		strcpy(run_path, start_path);
		strcat(run_path, "STOP\\");
		strcat(run_path, dta.d_fname);
		c=&(dta.d_fname[strlen(dta.d_fname)-3]);
		if( (!stricmp(c, "PRG")) || (!stricmp(c, "APP")) )
			stop_file(dta.d_fname);
		else
			start_file(run_path);
	} while(!Fsnext());
	Fsetdta(old_dta);	
}

/* -------------------------------------- */

int start_rsd_daemon(void)
{
	char	rsd_path[256];

	rsd_id=appl_find("RSDAEMON");
	if(rsd_id > -1) return(1);
	
	strcpy(rsd_path, "RSDAEMON.PRG");
	if(shel_find(rsd_path)==0) 
	{
		form_alert(1,gettext(A14));
		return(0);	/* Nix gefunden */
	}
	shel_write(1,1,SHW_PARALLEL,rsd_path,"");
	do
	{
		evnt_timer(100,0);	/* Wait for RSD-Init */
		rsd_id=appl_find("RSDAEMON");
	}while(rsd_id < 0);
	return(1);
}

int start_stip_app(void)
{
	char	rsd_path[256];

	if(appl_find("STIP    ") > -1) return(1);
	
	strcpy(rsd_path, "STIP.PRG");
	if(shel_find(rsd_path)==0) 
	{
		form_alert(1,gettext(NOAPPSTIP));
		return(0);	/* Nix gefunden */
	}
	shel_write(1,1,SHW_PARALLEL,rsd_path,"");
	return(1);
}

int start_idp_server(void)
{
	char	rsd_path[256];

	if(appl_find("IDPSERV ") > -1) return(1);
	
	strcpy(rsd_path, "IDPSERV.PRG");
	if(shel_find(rsd_path)==0) 
		return(0);	/* Nix gefunden */
	shel_write(1,1,SHW_PARALLEL,rsd_path,"");
	return(1);
}

void term_rsd_daemon(void)
{
	int pbuf[8];

	if(rsd_id < 0) return;
	pbuf[0]=AP_TERM;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	appl_write(rsd_id, 16, pbuf);
}

void term_stip_app(void)
{
	int pbuf[8], stip_id;

	stip_id=appl_find("STIP    ");
	if(stip_id < 0) return;
	pbuf[0]=AP_TERM;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	appl_write(stip_id, 16, pbuf);
}

void term_idp_server(void)
{
	int pbuf[8], idp_id;

	idp_id=appl_find("IDPSERV ");
	if(idp_id < 0) return;
	pbuf[0]=AP_TERM;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	appl_write(idp_id, 16, pbuf);
}

/* -------------------------------------- */

int check_preemptive(void)
{ /* preemptives Multitasking ÅberprÅfen
			return: 1=ist an, 0=ist aus, -1=ist nicht MagiC */
	MAGX_COOKIE *mgc;
	typedef struct
	{	
		char	off[0x64];
		int		(*pmt)(long magic);
	}TEMP_STRUCT;
		
  /* MagiC-Cookie */
	if(find_cookie('MagX', (long*)(&mgc))==0) return(-1);
	
	/* Zeiger auf AES-Variablen, 	Offset $64 gibt Zeiger auf 
	   eine Funktion.
		 Dieser Funktion in d0 den Wert 0xfffefffe Åbergeben. 
		 Liefert als RÅckgabewert in d0.w:
			-1 falls PMT nicht aktiv cdecl
	*/
	if( ((TEMP_STRUCT*)(mgc->aesvars))->pmt(0xfffefffel) == -1) return(0);
	return (1);
}

/* -------------------------------------- */
/* -------------------------------------- */

void sign_off(void)
{/* Crash clear */
	socks->sys->server_pd=NULL;
}

/* -------------------------------------- */
/* -------------------------------------- */

int cdecl usis(USIS_REQUEST *request)
{
	char *p;
		
	switch(request->request)
	{
		case UR_ETC_PATH:
			if(set.path_env)
			{
				p=getenv(set.etc_env);
				if(p==NULL) return(UA_NOTSET);
				strcpy(request->result, p);
			}
			else
				strcpy(request->result, set.etc_path);
			if(request->result[strlen(request->result)-1]!='\\')
				strcat(request->result,"\\");
		return(UA_FOUND);

		case UR_LOCAL_IP:
			if(socks->defs->my_ip==0) return(UA_NOTSET);
			request->ip=socks->defs->my_ip;
		return(UA_FOUND);
		
		case UR_REMOTE_IP:
			if(socks->defs->peer_ip==0) return(UA_NOTSET);
			request->ip=socks->defs->peer_ip;
		return(UA_FOUND);
		
		case UR_DNS_IP:
			if(socks->defs->name_server_ip==0) return(UA_NOTSET);
			request->ip=socks->defs->name_server_ip;
		return(UA_FOUND);

		case UR_POP_IP:
			if(set.pop_ip==0) return(UA_NOTSET);
			request->ip=set.pop_ip;
		return(UA_FOUND);
		
		case UR_SMTP_IP:
			if(set.smtp_ip==0) return(UA_NOTSET);
			request->ip=set.smtp_ip;
		return(UA_FOUND);

		case UR_NEWS_IP:
			if(set.news_ip==0) return(UA_NOTSET);
			request->ip=set.news_ip;
		return(UA_FOUND);

		case UR_TIME_IP:
			if(set.time_ip==0) return(UA_NOTSET);
			request->ip=set.time_ip;
		return(UA_FOUND);

		case	UR_EMAIL_ADDR:
			if(set.email[0]==0) return(UA_NOTSET);
			strcpy(request->result, set.email);
		return(UA_FOUND);
		
		case	UR_PROXY_IP:
			if(find_proxy(&(request->ip), &(request->port), request->free1, request->free2)==0)
				return(UA_NOTSET);
		return(UA_FOUND);

		case UR_POP_USER:
			if(set.pop_user[0]==0) return(UA_NOTSET);
			strcpy(request->result, set.pop_user);
		return(UA_FOUND);

		case UR_POP_PASS:
			if(set.pop_pass[0]==0) return(UA_NOTSET);
			strcpy(request->result, set.pop_pass);
		return(UA_FOUND);
	
		case UR_REAL_NAME:
			if(set.real_name[0]==0) return(UA_NOTSET);
			strcpy(request->result, set.real_name);
		return(UA_FOUND);
		
		case UR_ONLINE_TIME:
			request->other=_ol_;
		return(UA_FOUND);
		
		case UR_BYTES:
			request->other=_be_;
		return(UA_FOUND);
		
		case UR_CONN_MSG:
			if(conn_msg[0]==0) return(UA_NOTSET);
			strcpy(request->result, conn_msg);
		return(UA_FOUND);
		
		case UR_NNTP_USER:
			if(set.nntp_user[0]==0) return(UA_NOTSET);
			strcpy(request->result, set.nntp_user);
		return(UA_FOUND);

		case UR_NNTP_PASS:
			if(set.nntp_pass[0]==0) return(UA_NOTSET);
			strcpy(request->result, set.nntp_pass);
		return(UA_FOUND);

		case UR_VERSION:
			request->ip=ICON_VERSION_LONG;
		return(UA_FOUND);
		
		case UR_RESOLVED:
			if(g_resolve_count != 0) return(UA_NOTSET);
		return(UA_FOUND);
		
		default:
		return(UA_UNKNOWN);
	}
}

/* -------------------------------------- */

int find_proxy(ulong *ip, int *port, char *service, char *host)
{/* Lookup a proxy-IP for service/host. Write to <ip> and <port>
		return 1 on success, 0 else */

	int 		a;
	PROXY		*pr=NULL;
	char		*p1, *p2, mem, buf[6*41+2];
	servent	*getport;
	for(a=0; a < 10; ++a)
	{
		if(!(stricmp(set.proxies[a].service, service)))
		{
			pr=&(set.proxies[a]);
			break;
		}
	}
	if(pr==NULL) pr=&(set.proxies[9]);	/* <any other>-Proxy */
	if(pr->ip==0) return(0);
	
	/* Check for <not_use> entries on host */
	/* Cat all entries */
	strcpy(buf, pr->not_use);
	strcat(buf, " ");
	strcat(buf, &(pr->not_use[40]));
	strcat(buf, " ");
	strcat(buf, &(pr->not_use[80]));
	strcat(buf, " ");
	strcat(buf, &(pr->not_use[120]));
	strcat(buf, " ");
	strcat(buf, &(pr->not_use[160]));
	strcat(buf, " ");
	strcat(buf, &(pr->not_use[200]));
	
	p1=buf;

	if((host!=NULL) && (host[0]!=0))
	while(*p1)
	{	/* Compare host by host */
		p2=p1;
		while(*p2==' ') ++p2;	/* Find start of hostname */
		p1=p2;
		while((*p2!=' ') && (*p2!=0)) ++p2;
		/* p1=Start, p2=End */
		/* Terminate host */
		mem=*p2;
		*p2=0;
		if(wild(host, p1))
		{
			*p2=mem; return(UA_NOTSET);
		}
		p1=p2;
	}
	/* Get port */
	if(pr->port)
	{
		*port=pr->port;
		*ip=pr->ip;
		return(1);
	}

	getport=getservbyname(service, "tcp");
	if(getport==NULL) return(0);
	*port=getport->s_port;
	*ip=pr->ip;
	return(1);
}

/* -------------------------------------- */

int wild(char *string, char *pattern)
{
    register int    match;
    register char   c1, c2;

    match = 0;
    switch (*pattern) {
        case '*':
            pattern++;
            do {
                match = wild(string, pattern);
            } while (!match && *string++ != 0);
            break;
        case '?':
            if (*string != 0)
                match = wild(++string, ++pattern);
            break;
        case 0:
            if (*string == 0)
                match = 1;
            break;
        default:
            c1 = *string++;
            if (c1>='a' && c1<='z') c1 -= 32;
            c2 = *pattern++;
            if (c2>='a' && c2<='z') c2 -= 32;
            if (c1 == c2)
                match = wild(string, pattern);
            else
                match = 0;
            break;
    }
    return (match);
}

/* -------------------------------------- */

void process_icon_msg(int *pbuf)
{
	int rep_id; 

	switch(pbuf[3])
	{
		case ICM_STATUS_REQUEST:
			rep_id=pbuf[1];
			pbuf[1]=ap_id;
			pbuf[3]=ICM_STATUS_REPLY;
			pbuf[4]=global_state;
			pbuf[5]=pbuf[6]=0;
			appl_write(rep_id, 16, pbuf);
		break;	
		
		case ICM_CONNECTION_REQUEST:
			rep_id=pbuf[1];
			pbuf[1]=ap_id;
			pbuf[3]=ICM_CONNECTION_REPLY;
			if(global_state != ICMS_OFFLINE)
				pbuf[4]=ICMC_NOT_OFFLINE;
			else
			{
				pbuf[4]=ICMC_CONNECTING;
				intro_wind->dinfo->tree[MAINCONNECT].ob_state |= SELECTED;
				do_intro(intro_wind, MAINCONNECT);
			}
			pbuf[5]=pbuf[6]=0;
			appl_write(rep_id, 16, pbuf);
		break;
		
		case ICM_SHUTDOWN_REQUEST:
			rep_id=pbuf[1];
			pbuf[1]=ap_id;
			pbuf[3]=ICM_SHUTDOWN_REPLY;
			if(global_state != ICMS_ONLINE)
				pbuf[4]=ICMH_NOT_ONLINE;
			else
			{
				pbuf[4]=ICMH_DISCONNECTING;
				w_get(online_wind);
				setup.magic='ICWP';
				setup.wx=online_wind->wx;
				setup.wy=online_wind->wy;
				w_close(online_wind);
			}
			pbuf[5]=pbuf[6]=0;
			appl_write(rep_id, 16, pbuf);
		break;

		default:
			rep_id=pbuf[1];
			pbuf[1]=ap_id;
			pbuf[3]=ICM_UNKNOWN_REQUEST;
			appl_write(rep_id, 16, pbuf);
		break;
	}
}

/* -------------------------------------- */

void process_gs_request(int *pbuf)
{
	int request_id=pbuf[7], rep_id=pbuf[1];
	
	pbuf[0]=GS_REPLY;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	*(GS_INFO**)(&(pbuf[3]))=&ap_gi;
	pbuf[5]=pbuf[6]=0;
	pbuf[7]=request_id;
	appl_write(rep_id, 16, pbuf);
}

/* -------------------------------------- */

void set_dial_setup(int ix)
{
	SETUP	*new=&(g_sets[ix]);
	
	strcpy(intro_wind->dinfo->tree[SETPOP].ob_spec.free_string,	new->name);
	w_objc_draw(intro_wind, SETPOP, 8, sx, sy, sw, sh);		
	set_ext_type(intro_wind->dinfo->tree,SETPOP,ix);
}

/* -------------------------------------- */

void change_service_setup(int ix)
{/* Use service entries of loaded setup #ix */
	SETUP	*new=&(g_sets[ix]);
	ulong *src_ip, *dst_ip;
	int		cnt;
	
	/* Copy Services */
	strcpy(set.email, new->email);
	strcpy(set.real_name, new->real_name);

	cnt=0; src_ip=&(new->pop_ip); dst_ip=&(set.pop_ip);
	while(cnt < 24)
	{		*dst_ip++=*src_ip++;	++cnt; }

	cnt=0;
	while(cnt < 24)
	{
		strcpy(set.service_names[cnt], new->service_names[cnt]);
		cnt++;
	}

	memcpy(set.pop_user, new->pop_user, 80);
	memcpy(set.pop_pass, new->pop_pass, 80);
	memcpy(set.nntp_user, new->nntp_user, 80);
	memcpy(set.nntp_pass, new->nntp_pass, 80);	

	decode(set.pop_user, 80);
	decode(set.pop_pass, 80);
	decode(set.nntp_user, 80);
	decode(set.nntp_pass, 80);

	read_service_ips();
}

/* -------------------------------------- */

void process_gs_command(int *pbuf)
{
	int rep_id=pbuf[1], result=GSACK_UNKNOWN;
	int	ix;
	char *cmd=*(char**)(&(pbuf[3])), *my_err;

	if(!stricmp(cmd, GS_SET_SETUP))
	{/* Setup kann nur im offline-Betrieb gewechselt werden */
		if(global_state != ICMS_OFFLINE)
		{
			result=GSACK_ERROR; my_err=GS_ERR_NOFL;
		}
		else
		{
			cmd+=strlen(GS_SET_SETUP)+1; /* Zeigt jetzt auf Parameter = Name des Setups */
			ix=0; result=GSACK_ERROR; my_err=GS_ERR_SNOF;
			while(ix < g_sets_count)
			{
				if(!stricmp(g_sets[ix].name, cmd))
				{
					set_dial_setup(ix);
					result=GSACK_OK;
					my_err=NULL;
					break;
				}
				++ix;
			}
		}
	}
	else if(!stricmp(cmd, GS_SET_SERV))
	{/* Service Setup kann nur im online-Betrieb gewechselt werden */
		if(global_state != ICMS_ONLINE)
		{
			result=GSACK_ERROR; my_err=GS_ERR_NONL;
		}
		else
		{
			cmd+=strlen(GS_SET_SERV)+1; /* Zeigt jetzt auf Parameter = Name des Setups */
			ix=0; result=GSACK_ERROR; my_err=GS_ERR_SNOF;
			while(ix < g_sets_count)
			{
				if(!stricmp(g_sets[ix].name, cmd))
				{
					change_service_setup(ix);
					result=GSACK_OK;
					my_err=NULL;
					break;
				}
				++ix;
			}
		}
	}
	else if(!stricmp(cmd, GS_SYNC_RES))
	{/* Wait for resolver */
		result=GSACK_OK;
		if(g_resolve_count == 0) 
			my_err=GS_RES_RESOLVED;
		else 
			my_err=NULL;
	}
	else if(!stricmp(cmd, GS_DIAL_IN))
	{/* Dial in nur im offline Betrieb mîglich */
		if(global_state != ICMS_OFFLINE)
		{
			result=GSACK_ERROR; my_err=GS_ERR_NOFL;
		}
		else
		{
			result=GSACK_OK;	my_err=NULL;
			intro_wind->dinfo->tree[MAINCONNECT].ob_state |= SELECTED;
			do_intro(intro_wind, MAINCONNECT);
		}
	}
	else if(!stricmp(cmd, GS_SYNC_ONLINE))
	{/* Wait for connection */
		if(global_state == ICMS_OFFLINE)
		{/* No connection in progress, sync will never work */
			result=GSACK_ERROR; my_err=GS_ERR_NOCON;
		}
		else
		{
			result=GSACK_OK;
			if(global_state == ICMS_ONLINE)
				my_err=GS_RES_ONLINE;
			else
				my_err=NULL;
		}
	}
	else if(!stricmp(cmd, GS_HANG_UP))
	{/* Hang up nur im online-Betrieb mîglich */
		if(global_state != ICMS_ONLINE)
		{
			result=GSACK_ERROR; my_err=GS_ERR_NONL;
		}
		else
		{
			result=GSACK_OK; my_err=NULL;
			w_get(online_wind);
			setup.magic='ICWP';
			setup.wx=online_wind->wx;
			setup.wy=online_wind->wy;
			w_close(online_wind);
		}
	}
	
	pbuf[0]=GS_ACK;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	/* leave pbuf[3/4] untouched */
	*(char**)(&(pbuf[5]))=my_err;
	pbuf[7]=result;
	appl_write(rep_id, 16, pbuf);
}

/* -------------------------------------- */

void other_messages(int *pbuf)
{
	switch(pbuf[0])
	{
		case RSDAEMON_MSG:
			enter_rsdaemon_reply(pbuf);
		break;
		
		case ICON_MSG:
			process_icon_msg(pbuf);
		break;
		
		case GS_REQUEST:
			process_gs_request(pbuf);
		break;
		
		case GS_COMMAND:
			process_gs_command(pbuf);
		break;
		
		case AP_TERM: case AP_RESCHG:
			if(global_state == ICMS_ONLINE)
			{
				pbuf[4]=ICMH_DISCONNECTING;
				w_get(online_wind);
				setup.magic='ICWP';
				setup.wx=online_wind->wx;
				setup.wy=online_wind->wy;
				w_close(online_wind);
			}
			else if(global_state == ICMS_OFFLINE)
			{
				intro_wind->dinfo->tree[MAINCANCEL].ob_state |= SELECTED;
				w_close(intro_wind);
			}
			/* WÑhrend Connecting wird AP_TERM ignoriert,
			   wÑhrend Disconnecting wird sowieso bald terminiert */
		break;
	}
}