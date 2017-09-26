#include <ec_gem.h>
#include <usis.h>
#include <icon_msg.h>

#include "io.h"
#include "ioglobal.h"
#include "online.h"
#include "indexer.h"

/* Blocksize for Upload */
#define UP_BLOCK	4096
/* Puffer-Hi-Water */
#define PUSH_BLOCK	50000l

WINDOW	wonline;
DINFO		donline;
OBJECT	*oonline;

int			logh, filt_h;

int			sent_pm, new_pm, ord_pm, new_om, ord_om;

long		onl_err;

char		*single_send, message_id[82];

extern char r_iso8859_1[];
extern int autotausch_on_startup;

ONLINE_INFO minf;

void	count_send_pms(ulong *cnt, ulong *bytes);
void	count_send_oms(ulong *cnt, ulong *bytes);
void	do_online(int ob);
void	online_automat(int cmd);
int		get_num_reply(int s);

void Flog(char *c)
{
	if(logh < 0) return;
	Fwrite(logh, strlen(c), c);
}

void open_log(void)
{
	time_t	ts;
	long		fhl;
	char		path[256];
	
	strcpy(path, db_path);
	strcat(path, "\\IN.LOG");
	fhl=Fcreate(path, 0);
	if(fhl < 0) {logh=-1; return;}
	logh=(int)fhl;
	Flog("eMailer Logfile ");
	ts=time(NULL);
	Flog(ctime(&ts));
	Flog("\r\n\r\n");
}
void open_filt(void)
{
	long		fhl;
	char		path[256];
	
	strcpy(path, db_path);
	strcat(path, "\\FILT.DAT");
	fhl=Fcreate(path, 0);
	if(fhl < 0) {filt_h=-1; return;}
	filt_h=(int)fhl;
}
void filt_log(char *c)
{
	if(filt_h < 0) return;
	Fwrite(filt_h, strlen(c)+1, c);	/* 0 mitschreiben */
	++minf.filter_entries;
}
void kill_filt_file(void)
{
	char		path[256];
	
	strcpy(path, db_path);
	strcat(path, "\\FILT.DAT");
	Fdelete(path);
}

void close_log(void)
{
	time_t	ts=time(NULL);

	Flog("\r\n");
	Flog("\r\n");
	Flog(ctime(&ts));
	Flog("\r\n-END OF FILE-\r\n");
	Fclose(logh);
}

void check_name_encoding(void)
{/* Real-Name ggf. quoted printable codieren */
	uchar *c=(uchar*)(minf.real_name), *d, buf[68], x, y, cnt;
	
	while(*c) {if((*c < 32) || (*c > 127)) goto _encode; ++c;}
	/* Standard-Ascii */
	return;

_encode:
	strcpy((char*)buf, minf.real_name);
	strcpy(minf.real_name, "=?ISO-8859-1?Q?");
	c=buf; d=(uchar*)&(minf.real_name[15]); cnt=15;
	while(*c)
	{
		if((*c > 31)&&(*c < 128)) {*d++=*c++; ++cnt;}
		else
		{
			x=r_iso8859_1[*c++];
			y=x>>4;
			x-=y<<4;
			*d++='=';
			if(y > 9)
				*d++=y-10+'A';
			else
				*d++=y+'0';
			if(x > 9)
				*d++=x-10+'A';
			else
				*d++=x+'0';
			cnt+=3;
		}
	}
	*d++='?';
	*d++='=';
	*d=0;
}

int init_minf(void)
{/* Return: 1=Ok, 0=Fehler */
	USIS_REQUEST	ur;
	servent	*se;
	char	path[256];
	long	fhl;
	
	minf.pms=0;
	minf.total_pms=0;
	minf.filter_entries=0;

	/* Lokale IP */
	ur.request=UR_LOCAL_IP;
	if(usis_query(&ur)!=UA_FOUND) minf.local_ip=0;
	else minf.local_ip=ur.ip;
	/* Server von USIS */	
	ur.request=UR_SMTP_IP;
	if(usis_query(&ur)!=UA_FOUND) minf.smtp_ip=0;
	else minf.smtp_ip=ur.ip;
	ur.request=UR_POP_IP;
	if(usis_query(&ur)!=UA_FOUND) minf.pop_ip=0;
	else minf.pop_ip=ur.ip;
	ur.request=UR_NEWS_IP;
	if(usis_query(&ur)!=UA_FOUND) minf.nntp_ip=0;
	else minf.nntp_ip=ur.ip;
	
	if(((minf.smtp_ip==0)||(minf.pop_ip==0))&&(minf.nntp_ip==0))
		{form_alert(1, gettext(NOSERVICE)); return(0);}

	minf.email[0]=0;
	ur.request=UR_EMAIL_ADDR;
	ur.result=minf.email;
	usis_query(&ur);
	if(minf.email[0]==0) {form_alert(1, gettext(NOEMAIL)); return(0);}

	minf.real_name[0]=0;
	ur.request=UR_REAL_NAME;
	ur.result=minf.real_name;
	usis_query(&ur);
	if(minf.real_name[0]) check_name_encoding();
	
	minf.pop_user[0]=0;
	minf.pop_pass[0]=0;
	if(minf.pop_ip!=0)
	{
		ur.request=UR_POP_USER;
		ur.result=minf.pop_user;
		usis_query(&ur);
		ur.request=UR_POP_PASS;
		ur.result=minf.pop_pass;
		usis_query(&ur);
		if((minf.pop_user[0]==0)||(minf.pop_pass[0]==0)) {form_alert(1, gettext(NOPOPUSER)); return(0);}
	}

	minf.nntp_user[0]=0;
	minf.nntp_pass[0]=0;
	if(minf.nntp_ip!=0)
	{
		ur.request=UR_NNTP_USER;
		ur.result=minf.nntp_user;
		usis_query(&ur);
		ur.request=UR_NNTP_PASS;
		ur.result=minf.nntp_pass;
		usis_query(&ur);
	}
	
	/* Ports */
	se=getservbyname("pop3", "tcp");
	if(se==NULL)
		minf.pop_port=DEFAULT_POP3_PORT;
	else
		minf.pop_port=se->s_port;
	se=getservbyname("smtp", "tcp");
	if(se==NULL)
		minf.smtp_port=DEFAULT_SMTP_PORT;
	else
		minf.smtp_port=se->s_port;
	se=getservbyname("nntp", "tcp");
	if(se==NULL)
		minf.nntp_port=DEFAULT_NNTP_PORT;
	else
		minf.nntp_port=se->s_port;

	count_send_pms(&(minf.send_pms), &(minf.send_bytes));	
	count_send_oms(&(minf.send_oms), &(minf.send_obytes));	

	strcpy(path, db_path);
	strcat(path, "\\PM.IDX");	
	fhl=Fopen(path, FO_READ);
	if(fhl < 0) {minf.old_pms=0; return(1);}
	Fread((int)fhl, 4, &(minf.old_pms));
	Fclose((int)fhl);
	minf.mem_old_pms=minf.old_pms;
	return(1);
}

void write_server_left(void)
{
	long	fhl, cnt;
	int		fh;
	char path[256];
	
	strcpy(path, db_path);
	strcat(path, "\\PM.IDX");	
	fhl=Fcreate(path, 0);
	if(fhl < 0) {gemdos_alert(gettext(CREATEERR), fhl); return;}
	fh=(int)fhl;
	fhl=cnt=0;
	while(fhl < minf.total_pms)
	{
		if(!(minf.pms[fhl].flags & PMF_DELETED)) ++cnt;
		++fhl;
	}
	Fwrite(fh, 4, &cnt);
	cnt=0;
	while(cnt < minf.total_pms)
	{
		if(!(minf.pms[cnt].flags & PMF_DELETED))
		{
			Fwrite(fh, 2, &(minf.pms[cnt].flags));
			Fwrite(fh, 4, &(minf.pms[cnt].size));
		}
		++cnt;
	}	
	Fclose(fh);
}

void do_prevonline(WINDOW *win, int ob)
{
	switch(ob)
	{
		case POLSTART: case IPOLSTART:
			if(w_wo_ibut_sel(win, ob)==0) return;
			w_wo_ibut_unsel(win, ob);
			if(ob==IPOLSTART) ob=POLSTART;
		case POLABBRUCH:
			*(int*)(win->user)=ob;
			w_close(win);
		break;
	}
}

void set_num(OBJECT *tree, int ob, int cnt)
{
	char num[10];
	
	itoa(cnt, num, 10);
	strncpy(tree[ob].ob_spec.free_string, num, 4);
	tree[ob].ob_spec.free_string[4]=0;
}

void show_download_info(void)
{
	OBJECT *tree;

	if(ios.tausch_info==0) return;
	if((new_pm+ord_pm+new_om+ord_om)==0) return;
		
	rsrc_gaddr(0, DOWNLOADS, &tree);
	set_num(tree, NEW_PM, new_pm);
	set_num(tree, ORD_PM, ord_pm);
	set_num(tree, NEW_OM, new_om);
	set_num(tree, ORD_OM, ord_om);

	lock_menu(omenu);	
	tree[w_do_dial(tree)].ob_state &= (~SELECTED);
	unlock_menu(omenu);	
}

void script_online(int do_pm, int do_om, int do_warn)
{/* Tausch-Aufruf per Script */
	minf.do_pm=do_pm;
	minf.do_om=do_om;
	minf.always_show=do_warn;

	single_send=NULL;

	run_jobs();
}

void online(void)
{
	OBJECT *tree;

	if(autotausch_on_startup)
	{/* Keinen Dialog anzeigen */
		minf.always_show=ios.show_pm_list;
		minf.do_om=ios.om_exchange;
		minf.do_pm=ios.pm_exchange;
	}
	else
	{
		rsrc_gaddr(0, PREVONLINE, &tree);
		if(ios.pm_exchange)
			tree[POL_PM].ob_state |= SELECTED;
		else
			tree[POL_PM].ob_state &= (~SELECTED);
		if(ios.om_exchange)
			tree[POL_OM].ob_state |= SELECTED;
		else
			tree[POL_OM].ob_state &= (~SELECTED);
		if(ios.show_pm_list)
			tree[POLSHOWLIST].ob_state |= SELECTED;
		else
			tree[POLSHOWLIST].ob_state &= (~SELECTED);
		tree[POLABBRUCH].ob_state &= (~SELECTED);
		if(w_do_opt_dial(tree, do_prevonline)==POLABBRUCH) return;
		
		ios.show_pm_list=minf.always_show=tree[POLSHOWLIST].ob_state & SELECTED;
		ios.om_exchange=minf.do_om=tree[POL_OM].ob_state & SELECTED;
		ios.pm_exchange=minf.do_pm=tree[POL_PM].ob_state & SELECTED;
	}
	single_send=NULL;

	if((minf.do_om==0)&&(minf.do_pm==0)) {form_alert(1, gettext(NO_DO_ONLINE)); return;}
	run_jobs();
}

void run_jobs(void)
{
	static 	char	path[256];
	int			ic_id, evnt, dum;

	onl_err=0;
	
	sent_pm=new_pm=ord_pm=new_om=ord_om=0;
	
	switch(sock_init())
	{
		case SE_NINSTALL:
			form_alert(1,gettext(A1));
		return;				
		case SE_NSUPP:
			form_alert(1,gettext(A2));
		return;			
	}

	rsrc_gaddr(0, ONLINE, &oonline);

	oonline[CONPROCESS].ob_width=5;
	oonline[CONSTATUS].ob_spec.tedinfo->te_ptext[0]=0;
	oonline[CONACTION].ob_spec.tedinfo->te_ptext[0]=0;
	oonline[CONCANCEL].ob_state &= (~SELECTED);

	open_log();
	open_filt();
	
	w_dinit(&wonline);
	donline.tree=oonline;
	donline.support=0;
	donline.osmax=0;
	donline.odmax=8;
	wonline.dinfo=&donline;
	w_dial(&wonline, D_CENTER);
	donline.dservice=do_online;
	donline.dedit=0;
	w_open(&wonline);

	w_modal(&wonline, MODAL_ON);

	online_automat(0);
	while(wonline.open)
	{
		w_dtimevent(&evnt,&dum,&dum,&dum,&dum,100,0);
		if(evnt & MU_TIMER) online_automat(1);
	}

	w_modal(&wonline, MODAL_OFF);
	
	w_kill(&wonline);

	if((minf.me_connect) && ((ic_id=appl_find("ICONNECT"))>0))
	{
		pbuf[0]=ICON_MSG;
		pbuf[1]=ap_id;
		pbuf[2]=0;
		pbuf[3]=ICM_SHUTDOWN_REQUEST;
		pbuf[4]=0;
		pbuf[5]=pbuf[6]=0;
		pbuf[7]=1237; /* Magic */
		appl_write(ic_id, 16, pbuf);
	}
	if(filt_h > -1)
	{
		Flog("\r\nScanning downloads...\r\n");
		run_filters(filt_h, minf.filter_entries);
		Fclose(filt_h);
		kill_filt_file();
	}
	close_log();

	show_download_info();
	if(db_mode) 
	{
		if(sent_pm|new_pm|ord_pm|new_om|ord_om)
			Import_files(1);
	}
	
	if(onl_err)
	{
		strcpy(path, db_path);
		strcat(path, "\\IN.LOG");
		if(form_alert(1, gettext(ONLINE_ERROR))==2) return;
		pbuf[0]=AV_STARTPROG;
		pbuf[1]=ap_id;
		pbuf[2]=0;
		*((char**)(&pbuf[3]))=path;
		pbuf[5]=pbuf[6]=0;
		pbuf[7]=1234; /* Magic */
		appl_write(0, 16, pbuf);
	}
}

void do_online(int ob)
{
	if(ob==CONCANCEL)
	{
		if(form_alert(1, gettext(ONLINEREALQUIT))==2)
		{
			w_unsel(&wonline, ob);
			return;
		}
		online_automat(-1);
	}
}

void set_stat(int ob)
{
	oonline[CONSTATUS].ob_spec.tedinfo->te_ptext=gettext(ob);
	w_objc_draw(&wonline, CONSTATUS, 8, sx,sy,sw,sh);
}

void set_act(char *text)
{
	strncpy(oonline[CONACTION].ob_spec.tedinfo->te_ptext, text, 27);
	oonline[CONACTION].ob_spec.tedinfo->te_ptext[27]=0;
	while(strlen(oonline[CONACTION].ob_spec.tedinfo->te_ptext) < 27)
		strcat(oonline[CONACTION].ob_spec.tedinfo->te_ptext, " ");
	w_objc_draw(&wonline, CONACTION, 8, sx,sy,sw,sh);
}

void set_process(long is, long will)
{
	/* is/will = slide/bar  --> is*bar / will = slide */

	is*=(long)(oonline[CONFRAME].ob_width);
	is/=will;
	if(is<5) is=5;
	if(is > oonline[CONFRAME].ob_width) is=oonline[CONFRAME].ob_width;
	if(is < oonline[CONPROCESS].ob_width)
	{/* Balken verkrzt->Rahmen zeichnen */
		oonline[CONPROCESS].ob_width=(int)is;
		w_objc_draw(&wonline, CONFRAME, 8, sx,sy,sw,sh);
	}
	else
	{/* Balken verl„ngert->nur Balken zeichnen */
		oonline[CONPROCESS].ob_width=(int)is;
		w_objc_draw(&wonline, CONPROCESS, 8, sx,sy,sw,sh);
	}
}

int start_iconnect(void)
{
	int evt, dum, cnt;
	
#define arr_ret(a) {graf_mouse(ARROW, NULL); return(a);}
#define alert_ret(a, b) {graf_mouse(ARROW, NULL); form_alert(1, gettext(a)); return(b);}

_si_find_iconnect:
	graf_mouse(BUSYBEE, NULL);
	if(appl_find("ICONNECT") > -1) arr_ret(1);
	if(ios.autoicon==0) 
	{
		graf_mouse(ARROW, NULL);		
		if(form_alert(1,gettext(NO_ICONNECT))==2) return(0);
		goto _si_find_iconnect;
	}
	/* Iconnect starten */
	pbuf[0]=AV_STARTPROG;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	*((char**)(&pbuf[3]))="ICONFSET.CFG";
	pbuf[5]=pbuf[6]=0;
	pbuf[7]=1234; /* Magic */
	appl_write(0, 16, pbuf);
	cnt=0;
	do
	{
    evt=evnt_multi(MU_MESAG|MU_TIMER, 
                0,0,0,0,0,0,0,0,0,0,0,0,0,  
                pbuf,100,0,&dum,&dum,&dum,&dum,&dum,&dum); 
     if(evt & MU_MESAG)
     {
     	if((pbuf[0]==VA_PROGSTART) && (pbuf[7]==1234))
     	{
     		if(pbuf[3]==0) alert_ret(NO_DESKSTART, 0);
     		evnt_timer(500,0);
     		if(appl_find("ICONNECT")<0) alert_ret(NO_DESKSTART, 0);
     		arr_ret(1);
     	}
     	else
     		w_dispatch(pbuf);
     }
     else ++cnt;
	}while(cnt < 100);	/* Max 10 Sekunden */
	alert_ret(NO_DESKSTART, 0);
}

int get_stat(int ic_id)
{
	int evt, dum, cnt;

	/* Iconnect-Status */
	pbuf[0]=ICON_MSG;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	pbuf[3]=ICM_STATUS_REQUEST;
	pbuf[4]=0;
	pbuf[5]=pbuf[6]=0;
	pbuf[7]=1235; /* Magic */
	appl_write(ic_id, 16, pbuf);
	cnt=0;
	do
	{
    evt=evnt_multi(MU_MESAG|MU_TIMER, 
                0,0,0,0,0,0,0,0,0,0,0,0,0,  
                pbuf,100,0,&dum,&dum,&dum,&dum,&dum,&dum); 
     if(evt & MU_MESAG)
     {
     	if((pbuf[3]==ICM_STATUS_REPLY) && (pbuf[7]==1235))
     		return(pbuf[4]);
     	else
     		w_dispatch(pbuf);
     }
     else ++cnt;
	}while(cnt < 50);	/* Max 5 Sekunden */
	return(-1);
}

int iconnect(void)
{
	int ic_id, evt, dum, cnt;
	
#define arr_ret(a) {graf_mouse(ARROW, NULL); return(a);}
#define alert_ret(a, b) {graf_mouse(ARROW, NULL); form_alert(1, gettext(a)); return(b);}

_ic_run_iconnect:
	graf_mouse(BUSYBEE, NULL);
	if((ic_id=appl_find("ICONNECT")) < 0) alert_ret(UPS_ICONNECT, 0);
	/* Verbindung schon veranlasst? */
	if((dum=get_stat(ic_id)) > ICMS_OFFLINE) arr_ret(1);
	if(dum==-1) alert_ret(OLD_ICONNECT, 0);
	/* Verbindung veranlassen? */
	if(ios.autodial==0) 
	{
		graf_mouse(ARROW,NULL);
		if(form_alert(1,gettext(NO_ICONNECT))==2) return(0);
		goto _ic_run_iconnect;
	}

	minf.me_connect=1;
	pbuf[0]=ICON_MSG;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	pbuf[3]=ICM_CONNECTION_REQUEST;
	pbuf[4]=0;
	pbuf[5]=pbuf[6]=0;
	pbuf[7]=1236; /* Magic */
	appl_write(ic_id, 16, pbuf);
	cnt=0;
	do
	{
    evt=evnt_multi(MU_MESAG|MU_TIMER, 
                0,0,0,0,0,0,0,0,0,0,0,0,0,  
                pbuf,100,0,&dum,&dum,&dum,&dum,&dum,&dum); 
     if(evt & MU_MESAG)
     {
     	if((pbuf[3]==ICM_CONNECTION_REPLY) && (pbuf[7]==1236))
     		arr_ret(1)
     	else
     		w_dispatch(pbuf);
     }
     else ++cnt;
	}while(cnt < 50);	/* Max 5 Sekunden */
	alert_ret(OLD_ICONNECT, 0);
}

void count_send_pms(ulong *cnt, ulong *bytes)
{
	long	fhl;
	char	bpath[256];
	DTA		*old=Fgetdta(), dta;

	if(single_send)
	{
		*cnt=1;
		fhl=Fopen(single_send, FO_READ);
		if(fhl < 0) {*bytes=1000; return;} /* Besser als nix? */
		*bytes=(ulong)Fseek(0, (int)fhl, 2);
		Fclose((int)fhl);
		return;
	}
	
	*cnt=0; *bytes=0;
	strcpy(bpath, db_path);
	strcat(bpath, "\\PM\\*.SND");
	Fsetdta(&dta);
	if(!Fsfirst(bpath, 0))
	do
	{ ++*cnt; *bytes+=dta.d_length;}while(!Fsnext());
	Fsetdta(old);
	return;
}
void count_send_oms(ulong *cnt, ulong *bytes)
{
	char	bpath[256];
	DTA		*old=Fgetdta(), dta;

	*cnt=0; *bytes=0;
	strcpy(bpath, db_path);
	strcat(bpath, "\\OM\\SEND\\*.SND");
	Fsetdta(&dta);
	if(!Fsfirst(bpath, 0))
	do
	{ ++*cnt; *bytes+=dta.d_length;}while(!Fsnext());
	Fsetdta(old);
	return;
}

int to_connect(int s, const void *addr, int addrlen, int cmd)
{/* cmd: -1=Abbruch, 0=Init, 1=Check */
	/* return: 0=E_OK or E* (<0) =ERROR or (cmd=1) 1=connected */

	static int to_count;
	int			ret;
	fd_set	mask;
	timeval	tout;

	if(cmd==-1)
	{
		shutdown(s,2);
		return(0);
	}
	
	if(cmd==0)
	{
		Flog("Connecting to server\r\n");
		to_count=CONNECT_COUNT;
		ret=connect(s, addr, addrlen);
		if(ret != EINPROGRESS)
			return(ret);
		return(0);
	}
	
	FD_ZERO(&mask);
	FD_SET(s, &mask);
	tout.tv_sec=0;
	tout.tv_usec=0;

	if(to_count--)
	{
		ret=select(s+1, NULL, &mask, NULL, &tout);
		if(ret==1) return(1);
		return(0);
	}

	shutdown(s,2);
	return(ETIMEDOUT);
}

int nntp_authenticate(int sock, int code)
{
	/* Return: 1=Auth successfull, 0=failed */
	char	txt[120];
	int		ret;
	
	if(minf.nntp_user[0]==0) return(0);
	
	switch(code)
	{
		case 480:
			strcpy(txt, "AUTHINFO USER ");
			strcat(txt, minf.nntp_user);
			strcat(txt, "\r\n");
			if((ret=send_string(sock,txt,0))<0) return((int)ret);
			ret=get_num_reply(sock);
			if(ret==281) return(1);
			if(ret!=381) return(0);
			if(minf.nntp_pass[0]==0) return(0);
			strcpy(txt, "AUTHINFO PASS ");
			strcat(txt, minf.nntp_pass);
			strcat(txt, "\r\n");
			if((ret=send_string(sock,txt,0))<0) return((int)ret);
			ret=get_num_reply(sock);
			if(ret==281) return(1);
		return(0);

		case 450:
			strcpy(txt, "AUTHINFO SIMPLE\r\n");
			if((ret=send_string(sock,txt,0))<0) return((int)ret);
			ret=get_num_reply(sock);
			if(ret!=350) return(0);
			strcpy(txt, minf.nntp_user);
			strcat(txt, " ");
			strcat(txt, minf.nntp_pass);
			strcat(txt, "\r\n");
			if((ret=send_string(sock,txt,0))<0) return((int)ret);
			ret=get_num_reply(sock);
			if(ret==250) return(1);
		return(0);

		default:
		return(0);
	}
}

void net_alert(int code)
{
	char	alert[512], num[10];

	strcpy(alert, "[3][Network-Error:|");
	switch(code)
	{
		case ENOTSOCK: return;	/* Doppelt ge-closed oder so, ignorieren */
		case EADDRINUSE: strcat(alert, "Connection in use."); break;
		case ENSMEM: strcat(alert, "Insufficient memory.");break;
		case ENETDOWN: strcat(alert, "Network is down.");break;
		case ETIMEDOUT: strcat(alert, "Timeout.");break;
		case ECONNREFUSED: strcat(alert, "Connection refused.");break;
		case ENOTCONN: strcat(alert, "Connection broke down.");break;
		case EPIPE: strcat(alert, "Connection closing.");break;
		case ECONNRESET: strcat(alert, "Connection reset by peer.");break;
		default: strcat(alert, itoa(code, num, 10)); break;
	}
	strcat(alert, "]");
	Flog(alert);
	strcat(alert, "[Cancel]");
	form_alert(1, alert);
}

int send_string(int s, char *msg, int cr)
{
	int ret;
	long msglength=strlen(msg);
	int	 wblock=UP_BLOCK; /* +++ */

	if(msglength < 1000)
	{
		Flog(msg);
		if(cr) Flog("\r\n");
	}
		
	while(msglength)
	{	
		if(msglength < wblock)
			wblock=(int)msglength;
		msglength-=wblock;
		ret=swrite(s, msg, wblock);
		msg+=wblock;
		if(ret < 0) return(ret);
	}
	
	if(cr)
	{
		ret=swrite(s, "\r\n", 2);
		if(ret < 0) return(ret);
	}
	return(0);
}

int get_full_num_reply(int s, char *retbuf)
{/* s=socket, Return full reply, e.g. 250 */
 /* Receives until a line starting with a 3-digit-number and
 		ending with CR/LF is received.
 		Up to 256 chars of reply are stored in retbuf. */
 	time_t	now;
	int			ret, a, line_pos=0;
	char		buf[501], act_line[501];
	fd_set	mask;
	timeval	tout;

	sfcntl(s,F_SETFL,O_NDELAY);
	now=time(NULL);

	do
	{
		FD_ZERO(&mask);
		FD_SET(s, &mask);
		tout.tv_sec=0;
		tout.tv_usec=0;
		
		ret=select(s+1, &mask, NULL, NULL, &tout);
		if(ret==0)
		{
			ret=(int)sread(s, buf, 500);
			if(ret < 0)	return(ret);
			/* Maybe a segment just arrived between select and sread */
			if(ret > 0) goto _reply_incoming;
			
			if(time(NULL)-now < TO_REPLY_SEK)
			{
				evnt_timer(100,0);
				continue;
			}
			return(ETIMEDOUT);
		}

		/* Incoming data, reset timeout */
		
		ret=(int)sread(s, buf, 500);
		if(ret < 0)	return(ret); /* Foreign closed, error */
		
_reply_incoming:
		now=time(NULL);

		if(ret==0)	continue;	/* Empty reply, continue waiting */

		a=0;
		while(a < ret)
		{
			act_line[line_pos]=buf[a++];
			if((act_line[line_pos]==13) || (act_line[line_pos]==10))
			{/* Line ends */
				Fwrite(logh, line_pos, act_line);Fwrite(logh, 2, "\r\n");
				if(act_line[3]==' ')	/* Last line received */
				{
					if(retbuf) 
					{
						strncpy(retbuf, act_line, 255);
						retbuf[255]=0;
					}
					return(atoi(act_line));
				}
				line_pos=0;	/* else reset line-buffer */
			}
			else
				++line_pos;
		}
	}while(1);
}

int get_full_reply(int s, char *retbuf)
{/* s=socket, Return class of reply, e.g. 250=class 2 */
 /* Receives until a line starting with a 3-digit-number and
 		ending with CR/LF is received.
 		Up to 256 chars of reply are stored in retbuf. */

 	int ret=get_full_num_reply(s, retbuf);
 	
 	if(ret > 100) return(ret/100);
 	return(ret);
}

int get_full_nntp_reply(int s, char *retbuf, char *command)
{/* s=socket, Return class of reply, e.g. 250=class 2 */
 /* Receives until a line starting with a 3-digit-number and
 		ending with CR/LF is received.
 		Up to 256 chars of reply are stored in retbuf. */
	int	ret;
	 		
 	ret=get_full_num_reply(s, retbuf);
 	if((ret==450)||(ret==480))
 	{
 		if(nntp_authenticate(s, ret)==0) return(ret/100);
 		if((ret=send_string(s, command, 0)) < 0) return(ret);
 		return(get_full_reply(s, retbuf));
 	}
 	return(ret/100);
}

int get_reply(int s)
{/* s=socket, Return class of reply, e.g. 250=class 2 */
 /* Receives until a line starting with a 3-digit-number and
 		ending with CR/LF is received */
 		
 	return(get_full_reply(s, NULL));
}

int get_nntp_reply(int s, char *command)
{/* s=socket, Return class of reply, e.g. 250=class 2 */
 /* Receives until a line starting with a 3-digit-number and
 		ending with CR/LF is received */
	int	ret;
	 		
 	ret=get_full_num_reply(s, NULL);
 	if((ret==450)||(ret==480))
 	{
 		if(nntp_authenticate(s, ret)==0) return(ret/100);
 		if((ret=send_string(s, command, 0)) < 0) return(ret);
 		return(get_reply(s));
 	}
 	return(ret/100);
}

int get_num_reply(int s)
{/* s=socket, Return full reply, e.g. 250 */
 /* Receives until a line starting with a 3-digit-number and
 		ending with CR/LF is received */
 		
 	return(get_full_num_reply(s, NULL));
}

char get_pop_reply(int s)
{/* s=socket, Return class of reply, '+' or '-' */
 /* Receives until CR/LF is received */
 	time_t	now;
	int			ret, a, line_pos=0;
	char		buf[501], act_line[501];
	fd_set	mask;
	timeval	tout;

	now=time(NULL);

	do
	{
		FD_ZERO(&mask);
		FD_SET(s, &mask);
		tout.tv_sec=0;
		tout.tv_usec=0;
		
		ret=select(s+1, &mask, NULL, NULL, &tout);
		if(ret==0)
		{
			ret=(int)sread(s, buf, 500);
			if(ret < 0)	return(ret);
			/* Maybe a segment just arrived between select and sread */
			if(ret > 0) goto _pop_reply_incoming;
			
			if(time(NULL)-now < TO_REPLY_SEK)
			{
				evnt_timer(100,0);
				continue;
			}
			return(ETIMEDOUT);
		}

		/* Incoming data, reset timeout */
		
		ret=(int)sread(s, buf, 500);
		if(ret < 0)	return(ret); /* Foreign closed, error */
		
_pop_reply_incoming:
		now=time(NULL);

		if(ret==0)	continue;	/* Empty reply, continue waiting */

		a=0;
		while(a < ret)
		{
			act_line[line_pos]=buf[a++];
			if((act_line[line_pos]==13) || (act_line[line_pos]==10))
			{/* Line ends */
				act_line[line_pos]=0;
				Fwrite(logh, line_pos, act_line); Fwrite(logh, 2, "\r\n");
				line_pos=0;
				while(act_line[line_pos] && (act_line[line_pos]!='+')&&(act_line[line_pos]!='-')) 
					++line_pos; 
				if(!act_line[line_pos]) line_pos=0;	/* Reset and wait for next line */
				else return(act_line[line_pos]);
			}
			else
				++line_pos;
		}
	}while(1);
}

int send_rcps(int s, char *buf)
{/* Alle "To", "Cc" und "Bcc" als Empf„nger eintragen */
 /* return: <0=Error, 0=No Rcps, >0=Ok, send Mail */
	char	*d, *e, *x, mem, *s_field[]={"To:", "Cc:", "Bcc:"}, xmem;
	char	rcp_buf[128];	/* lt. RFC sowieso sind eMail-Adressen nur 64 Zeichen lang */
	int		accepted=0, a, ret; 	
	
	x=strstr(buf, "\r\n\r\n"); /* Headerende */
	if(x==NULL) x=strstr(buf, "\r\n\n");
	if(x==NULL) x=strstr(buf, "\n\n");
	if(x==NULL) return(0);
	xmem=*x; *x=0;

	a=-1;
	while(++a < 3) if((d=stristr(buf, s_field[a]))!=NULL)
	{
		d+=strlen(s_field[a]); while((*d==' ')||(*d==9))++d;
		do /* Empf„nger angeben */
		{
			e=d;
			while(*e&&(*e!=',')&&(*e!=13)) ++e;
			mem=*e; *e=0;
			strcpy(rcp_buf, "RCPT TO:");
			/* Frame recipient by "<" */
			if(d[0] != '<') strcat(rcp_buf, "<");
			strcat(rcp_buf, d);
			/* cut trailing spaces */
			while(strlen(rcp_buf) && (rcp_buf[strlen(rcp_buf)]==' ')) rcp_buf[strlen(rcp_buf)]=0;
			/* Frame recipient by ">" */
			if(d[strlen(d)-1] != '>') strcat(rcp_buf, ">");
			strcat(rcp_buf, "\r\n");
			if((ret=send_string(s,rcp_buf,0))<0) {*x=xmem; *e=mem; return(ret);}
			if((ret=get_reply(s))<0) {*x=xmem; *e=mem; return(ret);}
			if(ret==2) ++accepted;
			else	++onl_err;
			*e=mem; d=e;
			while((*d==' ')||(*d==',')) ++d;
			if(*d==13) /* ignore-Umbruch? */
			{
				++d;	/* 10 bergehen */
				if((*(d+1)==' ')||(*(d+1)==9))
				{
					++d;
					while((*d==' ')||(*d==9)) ++d;
				}
				else
					d=NULL;
			}
		}while(d);
	}
	*x=xmem;
	return(accepted);	
}

int send_block(int s, char **rbuf, long *bytes_pushed)
{/* rbuf=Nullterminiert. Versendet max. UP_BLOCK Bytes ber <s>
 		(bzw. Restl„nge von buf), setzt buf und bytes_pushed hoch 
 		Žndert "\r\n.\r\n" in "\r\n..\r\n" 
 		*/
	int		ret;
	long	msglength=strlen(*rbuf);
	int	 	wblock=UP_BLOCK;
	char	*c, mem;

	if(msglength < wblock)
		wblock=(int)msglength;
	
	mem=(*rbuf)[wblock]; (*rbuf)[wblock]=0;
	if((c=strstr(*rbuf, "\n."))!=NULL)
	{/* Nur bis Punkt versenden. Block k”nnte weiteren einzel-Punkt
			enthalten oder "halbe" Sequenz am Ende. Wird dann beim n„chsten
			Aufruf erkannt */
		(*rbuf)[wblock]=mem;
		*(c+1)=0; 
		ret=swrite(s, *rbuf, (int)strlen(*rbuf));
		if(ret < 0) return(ret);
		ret=swrite(s, "..", 2);
		if(ret < 0) return(ret);
		wblock=(int)strlen(*rbuf)+1;
		*(c+1)='.';
		*rbuf+=wblock;
		*bytes_pushed+=wblock;	
		return(E_OK);
	}
	(*rbuf)[wblock]=mem;
	if(wblock > 1) wblock-=1;		/* Wenn letztes Zeichen \n ist, kann \n.-Sequenz im n„chsten Durchgang gefunden werden */
	ret=swrite(s, *rbuf, wblock);
	if(ret < 0) return(ret);

	*rbuf+=wblock;
	*bytes_pushed+=wblock;	

	return(E_OK);
}

void make_message_id(void)
{
	char *c, cbuf[64];
	
	strcpy(message_id, "<");

	/* Zehn Zeichen aus: Sekunden seit 1.1.1970 */
	ltoa(time(NULL), cbuf, 10);
	if(strlen(cbuf) > 10)
		strcat(message_id, &(cbuf[strlen(cbuf)-10]));
	else
		strcat(message_id, cbuf);

	strcat(message_id, "-");	

	/* 6 Zeichen aus: System-Uptime in 200Hz-Ticks */
	ltoa(clock(), cbuf, 10);
	if(strlen(cbuf) > 6)
		strcat(message_id, &(cbuf[strlen(cbuf)-6]));
	else
		strcat(message_id, cbuf);

	/* Domain aus Email-Adresse */	
	strcat(message_id, "AEicMi");	/* AshEmailerInternalCreatedMessageId */
	if((c=strchr(minf.email, '\@'))==NULL)
		c="@localhost";

	strcat(message_id, c);
	strcat(message_id, ">");
}

int send_message_head(int s, char *buf, char **rbuf, int supress_id, int is_om)
{/* If is_om is 1, send_message_head checks if the different <from>
    adress has to be used (set by the user in the addresses-dialogue) */
    
	char *x, *c, *d, mem, tbuf[256], sender[66];
	int ret;

	if( is_om && ios.fake_news_from && (ios.fake_news_adr[0]))
	{
		if(ios.fake_news_adr[0] != '<') strcpy(sender, "<");
		strcat(sender, ios.fake_news_adr);
		if(ios.fake_news_adr[strlen(ios.fake_news_adr)-1]!='>') strcat(sender, ">");
	}
	else
	{
		if(minf.email[0] != '<') strcpy(sender, "<");
		strcat(sender, minf.email);
		if(minf.email[strlen(minf.email)-1]!='>') strcat(sender, ">");
	}
	
	x=strstr(buf, "\r\n\r\n"); /* Headerende */
	if(x==NULL) x=strstr(buf, "\r\n\n");
	if(x==NULL) x=strstr(buf, "\n\n");
	if(x)
	{
		if(!supress_id)
		{
			/* Message-ID */
			make_message_id();
			strcpy(tbuf, "Message-ID: ");
			strcat(tbuf, message_id);
			strcat(tbuf, "\r\n");
			ret=send_string(s, tbuf, 0);
			if(ret < 0) return(ret);
		}
		c=stristr(buf, "Bcc:");
		d=stristr(buf, "From: <local>\r\n");
		if(d==NULL) d=stristr(buf, "Resent-From: <local>\r\n");
		if(d < c) {x=c; c=d; d=x;}
		if(c)
		{
			mem=*c; *c=0;
			ret=send_string(s, buf, 0);
			if(ret < 0) return(ret);
			switch(mem)
			{
				case 'R':
					strcpy(tbuf, "Resent-From: ");
					if(minf.real_name[0])
					{
						strcat(tbuf, minf.real_name);
						strcat(tbuf, " "); 
					}
					strcat(tbuf, sender);
					strcat(tbuf, "\r\n");
					ret=send_string(s, tbuf, 0); if(ret < 0) return(ret);
				break;
				case 'F':
					strcpy(tbuf, "From: ");
					if(minf.real_name[0])
					{
						strcat(tbuf, minf.real_name);
						strcat(tbuf, " "); 
					}
					strcat(tbuf, sender);
					strcat(tbuf, "\r\n");
					ret=send_string(s, tbuf, 0); if(ret < 0) return(ret);
				break;
			}
			*c=mem;
			while(1)
			{
				while(*c&&(*c!=13)) ++c;
				while((*c==13)||(*c==10))++c;
				if((*c!=' ')&&(*c!=9)) break;				
			}
		}
		else
			c=buf;
		if(d)
		{
			mem=*d; *d=0;
			ret=send_string(s, c, 0);
			if(ret < 0) return(ret);
			switch(mem)
			{
				case 'R':
					strcpy(tbuf, "Resent-From: ");
					if(minf.real_name[0])
					{
						strcat(tbuf, minf.real_name);
						strcat(tbuf, " "); 
					}
					strcat(tbuf, sender);
					strcat(tbuf, "\r\n");
					ret=send_string(s, tbuf, 0); if(ret < 0) return(ret);
				break;
				case 'F':
					strcpy(tbuf, "From: ");
					if(minf.real_name[0])
					{
						strcat(tbuf, minf.real_name);
						strcat(tbuf, " "); 
					}
					strcat(tbuf, sender);
					strcat(tbuf, "\r\n");
					ret=send_string(s, tbuf, 0); if(ret < 0) return(ret);
				break;
			}
			*d=mem;
			while(1)
			{
				while(*d&&(*d!=13)) ++d;
				while((*d==13)||(*d==10))++d;
				if((*d!=' ')&&(*d!=9)) break;				
			}
		}
		else
			d=c;
	}
	else
		d=buf;

	*rbuf=d;
	return(E_OK);
}

void save_mail_sent(char *path, char *buf, long len)
{
	long	fhl;
	int		fh;
	char	*x, *c, mem, xmem;

	path[strlen(path)-1]='T';	/* SND->SNT */
	fhl=Fcreate(path, 0);
	if(fhl < 0) return;
	filt_log(path);
	path[strlen(path)-1]='D';
	Fdelete(path);
	fh=(int)fhl;

	x=strstr(buf, "\r\n\r\n"); /* Headerende */
	if(x==NULL) x=strstr(buf, "\r\n\n");
	if(x==NULL) x=strstr(buf, "\n\n");
	if(x)
	{
		/* Message-ID global erhalten! */
		Fwrite(fh, strlen("Message-ID: "), "Message-ID: ");
		Fwrite(fh, strlen(message_id), message_id);
		Fwrite(fh, 2, "\r\n");

		xmem=*x; *x=0;
		c=stristr(buf, "From: <local>\r\n");
		if(c==NULL) c=stristr(buf, "Resent-From: <local>\r\n");
		*x=xmem;
		if(c)
		{
			mem=*c; *c=0;
			if(mem=='F')
				Fwrite(fh, 6, "From: ");
			else
				Fwrite(fh, 13, "Resent-From: ");
			if(minf.real_name[0])
			{
				Fwrite(fh, strlen(minf.real_name), minf.real_name);
				Fwrite(fh, 1, " ");
			}
			if(minf.email[0] != '<') Fwrite(fh, 1, "<");
			Fwrite(fh, strlen(minf.email), minf.email);
			if(minf.email[strlen(minf.email)-1]!='>') Fwrite(fh,1, ">");
			Fwrite(fh, 2, "\r\n");
			if(c > buf) Fwrite(fh, c-buf, buf);
	
			*c=mem;
			while(1)
			{
				while(*c&&(*c!=13)) ++c;
				while((*c==13)||(*c==10))++c;
				if((*c!=' ')&&(*c!=9)) break;				
			}
			len-=c-buf;
		}
		else
			c=buf;
	}
	else
		c=buf;
	
	Fwrite(fh, len, c);
	Fclose(fh);
}

int send_pm(int s, int cmd)
{/* cmd: -1=Abbrechen, 0=Init, 1=Cont */
 /* Return: 0=Cont, 1=Done,  <0=Error */
	char	txt[256], num[10];
	int		dum;
	static int state, single_count;
	#define SPS_NEXT 0
	#define SPS_HEAD 1
	#define SPS_BODY 2
	#define SPS_WAIT 3
	#define SPS_FINAL 4
	static char *buf, *rbuf, pmpath[256], mailpath[256];
	static long buflen, mail_cnt;
	static long bytes_pushed, bytes_to_send, bytes_sent, total_sent;
	static DTA		*old, dta;
	long		ret, bytes_left;
	
	switch(cmd)
	{
		case -1:	/* Abbrechen */
			if(buf) free(buf);
			if(!single_send)	Fsetdta(old);
		return(1);

		case 0:		/* Init */
			state=SPS_NEXT;
			buf=NULL;
			buflen=mail_cnt=0;
			single_count=0;
			total_sent=0;
			if(!single_send)
			{
				old=Fgetdta();
				Fsetdta(&dta);
				strcpy(pmpath, db_path);
				strcat(pmpath, "\\PM\\*.SND");
			}
		break;
		case 1:	/* Cont */
			switch(state)
			{
				case SPS_NEXT:
					if(single_send)
					{
						++single_count;
						if(single_count==2) return(1);	/* Fertig, zweiter Durchgang durch Fehler mit return(0) */
						strcpy(mailpath, single_send);
						buflen=minf.send_bytes;
					}
					else
					{
						if(!mail_cnt)
						{
							if(Fsfirst(pmpath, 0)) {Fsetdta(old); return(1);}	/* No more mails */
						}
						else
						{
							if(Fsnext()) {Fsetdta(old); return(1);} /* No more mails */
						}
						strcpy(mailpath, db_path);
						strcat(mailpath, "\\PM\\");
						strcat(mailpath, dta.d_fname);
						buflen=(long)(dta.d_length+1);
					}
					if(buf) free(buf);
					buf=malloc(buflen);
					if(buf==NULL) return(0);	/* Continue with next mail */
					ret=Fopen(mailpath, FO_READ);
					if(ret < 0) {free(buf); buf=NULL; return(0);} /* Next mail */
					Fread((int)ret, buflen-1, buf);
					Fclose((int)ret);
					buf[buflen-1]=0;
					mail_cnt++;
					state=SPS_HEAD;
				break;
				
				case SPS_HEAD:
					/* Send the message */
					set_act("Mail from...");
					strcpy(txt, "MAIL FROM:");
					if(minf.email[0] != '<') strcat(txt, "<");
					strcat(txt, minf.email);
					if(minf.email[strlen(minf.email)-1]!='>') strcat(txt, ">");
					strcat(txt, "\r\n");
					if((ret=send_string(s,txt,0))<0) return((int)ret);
					if((ret=get_num_reply(s))<0) return((int)ret);
					if((ret!=503)&&(ret/100!=2)) {++onl_err; state=SPS_NEXT; return(0);} /* 250 */
					set_act("Recipients...");
					if((ret=send_rcps(s, buf))<0)return((int)ret);
					if(ret==0) {++onl_err; state=SPS_NEXT; Flog("No recipients accepted or specified in mail.\r\n");return(0);} /* No rcps */
					if((ret=send_string(s,"DATA\r\n",0))<0) return((int)ret);
					if((ret=get_reply(s))<0) return((int)ret);
					if(ret!=3) {++onl_err; state=SPS_NEXT; return(0);} /* 354 */
					bytes_sent=0;
					state=SPS_BODY;
				break;
				case SPS_BODY:				
					strcpy(txt, ltoa(mail_cnt, num, 10));
					strcat(txt, "/");
					strcat(txt, ltoa(minf.send_pms, num, 10));
					set_act(txt);
					/* Attention! send_message_head creates message_id and
							must thus be followed by save_mail_sent! */
					if((ret=send_message_head(s,buf, &rbuf,0, 0))<0) return((int)ret);
					bytes_to_send=strlen(rbuf)+(rbuf-buf);
					bytes_pushed=rbuf-buf;
					state=SPS_WAIT;
				break;
				case SPS_WAIT:
					dum=(int)sizeof(long);
					getsockopt(s, SOL_SOCKET, SO_SNDBUF, &bytes_left, &dum);
					bytes_sent=bytes_pushed-bytes_left;
					if((bytes_left < PUSH_BLOCK)&&(bytes_pushed < bytes_to_send))
						if((ret=send_block(s,&rbuf,&bytes_pushed))<0) return((int)ret);
					set_process(total_sent+bytes_sent, minf.send_bytes);
					if(bytes_sent==bytes_to_send) state=SPS_FINAL;
				break;
				case SPS_FINAL:
					if((ret=send_string(s,"\r\n.\r\n",0))<0) return((int)ret);
					if((ret=get_reply(s))<0) return((int)ret);
					if(ret!=2) {++onl_err; state=SPS_NEXT; return(0);}
					total_sent+=bytes_to_send;
					/* Nachricht als Versendet speichern */
					save_mail_sent(mailpath, buf, buflen-1);
					++sent_pm;
					state=SPS_NEXT;
					if(single_send) return(1);	/* Done */
				break;
			}
		break;
	}	
	return(0);
}

int rcv_nntp_block(int s, int fh, long *bytes_rcvd)
{
	static int answer=0, lastcr=0, done_state=0;
						/* done_state: 0=Wait CR 1; 1=Wait .; 2=Wait CR 2; 3=Ok */
	int			ret, a;
	long		l;
	static long		line_pos=0;
	static char		act_line[1024];
	char		buf[5001];
	fd_set	mask;
	timeval	tout;

	FD_ZERO(&mask);
	FD_SET(s, &mask);
	tout.tv_sec=0;
	tout.tv_usec=0;
		
	ret=select(s+1, &mask, NULL, NULL, &tout);
	if(ret==0)
	{
		ret=(int)sread(s, buf, 5000);
		if(ret < 0)	
		{
			line_pos=0; answer=0; lastcr=0; done_state=0;
			return(ret);
		}
		/* Maybe a segment just arrived between select and sread */
		if(ret > 0) goto _get_block1_incoming;
		return(0);		
	}

	/* Incoming data, reset timeout */
	
	ret=(int)sread(s, buf, 5000);
	if(ret < 0)	
	{
		line_pos=0; answer=0; lastcr=0; done_state=0;
		return(ret); /* Foreign closed, error */
	}
	
_get_block1_incoming:

	if(ret==0)	return(0);

	a=0;
	while(a < ret) 
	{
		act_line[line_pos]=buf[a++];
		if(act_line[line_pos]=='.')
		{
			++line_pos;
			if(done_state==1) done_state=2;
			else done_state=0;
		}
		else if((act_line[line_pos]==13) || (act_line[line_pos]==10))
		{/* Line ends */
			/* Ignore LF after CR */
			if((act_line[line_pos]==10)&&(lastcr)) {line_pos=0; lastcr=0; continue;}
			if(act_line[line_pos]==13)
			{
				if(done_state==0) done_state=1;
				else if(done_state==2) done_state=3;
				lastcr=1; 
			}
			else 
			{
				lastcr=0;
			}
			act_line[line_pos]=0;
			line_pos=0;
			while((act_line[line_pos]==10)||(act_line[line_pos]==13))++line_pos;
			if(!answer)
			{
				if(act_line[line_pos]!='2')	/* Reply-Line, ERR */
				{
					ret=1;
					Flog(act_line);Flog("\r\n");
					if(nntp_authenticate(s, atoi(&(act_line[line_pos])))) 
						ret=2;
					else
						++onl_err;
					line_pos=0; answer=0; lastcr=0; done_state=0;
					return(ret);
				}
				if(act_line[line_pos]=='2') /* Reply-Line, OK */
				{
					Flog(act_line);Flog("\r\n");
					answer=1;
					line_pos=0; continue;
				}
				line_pos=0;	/* Forget this line */
				return(0);
			}
			if(done_state==3)
			{/* Done */
				line_pos=0; answer=0; lastcr=0; done_state=0;
				return(1);
			}
			if((act_line[line_pos]=='.') && (act_line[line_pos+1]=='.'))
				++line_pos;
				
			l=strlen(&(act_line[line_pos]));
			Fwrite(fh, l, &(act_line[line_pos]));
			line_pos=0;
			Fwrite(fh, 2, "\r\n");
			*bytes_rcvd+=l;
		}
		else
		{
			++line_pos;
			if(line_pos > 1020)
			{ /* Flush buffer */
				act_line[line_pos]=0;
				l=strlen(&(act_line[line_pos]));
				Fwrite(fh, l, &(act_line[line_pos]));
				line_pos=0;
				*bytes_rcvd+=l;
			}
			done_state=0;
		}
	}
	return(0);
}

int rcv_pop_block(int s, int fh, long *bytes_rcvd)
{
	static int answer=0, lastcr=0, done_state=0;
						/* done_state: 0=Wait CR 1; 1=Wait .; 2=Wait CR 2; 3=Ok */
	int			ret, a;
	long		l;
	static long		line_pos=0;
	static char		act_line[1024];
	char		buf[5001];
	fd_set	mask;
	timeval	tout;

	FD_ZERO(&mask);
	FD_SET(s, &mask);
	tout.tv_sec=0;
	tout.tv_usec=0;
		
	ret=select(s+1, &mask, NULL, NULL, &tout);
	if(ret==0)
	{
		ret=(int)sread(s, buf, 5000);
		if(ret < 0)	
		{
			line_pos=0; answer=0; lastcr=0, done_state=0;
			return(ret);
		}
		/* Maybe a segment just arrived between select and sread */
		if(ret > 0) goto _get_block_incoming;
		return(0);		
	}

	/* Incoming data, reset timeout */
	
	ret=(int)sread(s, buf, 5000);
	if(ret < 0)	
	{
		line_pos=0; answer=0; lastcr=0, done_state=0;
		return(ret); /* Foreign closed, error */
	}
	
_get_block_incoming:

	if(ret==0)	return(0);

	a=0;
	while(a < ret) 
	{
		act_line[line_pos]=buf[a++];
		if(act_line[line_pos]=='.')
		{
			++line_pos;
			if(done_state==1) done_state=2;
			else done_state=0;
		}
		else if((act_line[line_pos]==13) || (act_line[line_pos]==10))
		{/* Line ends */
			/* Ignore LF after CR */
			if((act_line[line_pos]==10)&&(lastcr)) {line_pos=0; lastcr=0; continue;}
			if(act_line[line_pos]==13)
			{
				if(done_state==0) done_state=1;
				else if(done_state==2) done_state=3;
				lastcr=1; 
			}
			else 
			{
				lastcr=0;
			}
			act_line[line_pos]=0;
			line_pos=0;
			while((act_line[line_pos]==10)||(act_line[line_pos]==13))++line_pos;
			if(!answer)
			{
				if(act_line[line_pos]=='-')	/* Reply-Line, ERR */
				{
					Flog(act_line);Flog("\r\n");++onl_err;
					line_pos=0; answer=0; lastcr=0, done_state=0;
					return(1);
				}
				if(act_line[line_pos]=='+') /* Reply-Line, OK */
				{
					Flog(act_line);Flog("\r\n");
					answer=1;
					line_pos=0; continue;
				}
				line_pos=0;	/* Forget this line */
				return(0);
			}
			if(done_state==3)
			{/* Done */
				line_pos=0; answer=0; lastcr=0, done_state=0;
				return(1);
			}
			if((act_line[line_pos]=='.') && (act_line[line_pos+1]=='.'))
				++line_pos;
				
			l=strlen(&(act_line[line_pos]));
			Fwrite(fh, l, &(act_line[line_pos]));
			line_pos=0;
			Fwrite(fh, 2, "\r\n");
			*bytes_rcvd+=l;
		}
		else
		{
			++line_pos;
			if(line_pos > 1020)
			{ /* Flush buffer */
				act_line[line_pos]=0;
				l=strlen(&(act_line[line_pos]));
				Fwrite(fh, l, &(act_line[line_pos]));
				line_pos=0;
				*bytes_rcvd+=l;
			}
			done_state=0;
		}
	}
	return(0);
}

int get_pm(int s, int cmd)
{/* cmd: -1=Abbrechen, 0=Init, 1=Cont */
 /* Return: 0=Cont, 1=Done,  <0=Error */
	char	txt[30], num[10];
	static int state, fh;
	#define SPG_NEXT 0
	#define SPG_RETR 1
	#define SPG_READ 2
	#define SPG_INIDELETE 3
	#define SPG_DELETE 4
	char 		pmpath[256];
	static 	long mail_ix, mail_cnt, mail_max;
	static	long bytes_to_recv, bytes_rcvd, fnamenum;
	long		ret;
	
	switch(cmd)
	{
		case -1:	/* Abbrechen */
			Fclose(fh);
		return(1);

		case 0:		/* Init */
			state=SPG_NEXT;
			mail_cnt=bytes_rcvd=0;
			mail_ix=-1;
			bytes_to_recv=mail_max=0;
			ret=0;
			while(ret < minf.total_pms)
			{
				if(minf.pms[ret].flags & PMF_GET)
				{
					++mail_max;
					bytes_to_recv+=minf.pms[ret].size;
				}
				++ret;
			}
			strcpy(pmpath, db_path);
			strcat(pmpath, "\\PM\\");
			fnamenum=atol(get_free_file(pmpath));
			if(mail_max) state=SPG_NEXT;
			else state=SPG_INIDELETE;
		break;
		case 1:	/* Cont */
			switch(state)
			{
				case SPG_NEXT:
					strcpy(pmpath, db_path);
					strcat(pmpath, "\\PM\\");
					ltoa(fnamenum++, &(pmpath[strlen(pmpath)]), 10);
					strcat(pmpath, ".NEW");
					ret=Fcreate(pmpath, 0);
					if(ret < 0) {gemdos_alert(gettext(CREATEERR), ret); return(0);} /* Next mail */
					filt_log(pmpath);
					fh=(int)ret;
					mail_cnt++;
					strcpy(txt, ltoa(mail_cnt, num, 10));
					strcat(txt, "/");
					strcat(txt, ltoa(mail_max, num, 10));
					set_act(txt);
					++mail_ix;
					while(!(minf.pms[mail_ix].flags & PMF_GET)) ++mail_ix;
					state=SPG_RETR;
				break;
				
				case SPG_RETR:
					strcpy(txt, "RETR ");
					strcat(txt, ltoa(mail_ix+1, num, 10));
					strcat(txt, "\r\n");
					/* Bei Fehler total_pms zurcksetzen, damit folgende
							nicht als "gesehen" vermerkt werden */
					if((ret=send_string(s,txt,0))<0) {minf.total_pms=mail_ix; return((int)ret);}
					state=SPG_READ;
				break;
				
				case SPG_READ:
					/* Read the message */
					/* Bei Fehler total_pms zurcksetzen, damit folgende
							nicht als "gesehen" vermerkt werden */
					if((ret=rcv_pop_block(s, fh, &bytes_rcvd))<0)	{minf.total_pms=mail_ix; return((int)ret);}
					set_process(bytes_rcvd, bytes_to_recv);
					if(ret==1)
					{/* Fertig */
						Fclose(fh);
						minf.pms[mail_ix].flags |= PMF_GOT;
						++new_pm;
						if(mail_cnt==mail_max) state=SPG_INIDELETE;
						else state=SPG_NEXT;
					}
				break;
				
				case SPG_INIDELETE: /* Delete messages */
					mail_cnt=mail_ix=mail_max=0;
					ret=0;
					while(ret < minf.total_pms)
					{
						if(minf.pms[ret].flags & PMF_DEL)
							++mail_max;
						++ret;
					}
					state=SPG_DELETE;
				break;
				case SPG_DELETE: /* Delete messages */
					if(mail_cnt < mail_max)
					{
						++mail_cnt;
						strcpy(txt, "Delete ");
						strcat(txt, ltoa(mail_cnt, num, 10));
						strcat(txt, "/");
						strcat(txt, ltoa(mail_max, num, 10));
						set_act(txt);
						set_process(mail_cnt-1, mail_max);
						while(!(minf.pms[mail_ix].flags & PMF_DEL)) ++mail_ix;
						strcpy(txt, "DELE ");
						/* mail_ix+1 muž als Text gesendet werden (Server z„hlt ab 1, ich ab 0)
							und mail_ix muž fr n„chsten Durchgang erh”ht werden (sonst wird wieder
							gleiche Mail gel”scht), deshalb: */
						++mail_ix; 
						strcat(txt, ltoa(mail_ix, num, 10));
						strcat(txt, "\r\n");
						send_string(s, txt, 0);
						if((ret=get_pop_reply(s))<0)	return((int)ret);
						if(ret=='+')
						{
							minf.pms[mail_ix-1].flags |= (PMF_DELETED);
							set_process(mail_cnt, mail_max);
						}
						else ++onl_err;
					}
					else return(1);
				break;
			}
		break;
	}	
	return(0);
}

int rcv_grp_list(int s, int fh, long *groups_rcvd)
{
	static int answer=0, lastcr=0;
	int			ret, a;
	long		l;
	static long		line_pos=0;
	static char		act_line[1024];
	char		buf[5001], *c;
	fd_set	mask;
	timeval	tout;

	FD_ZERO(&mask);
	FD_SET(s, &mask);
	tout.tv_sec=0;
	tout.tv_usec=0;
		
	ret=select(s+1, &mask, NULL, NULL, &tout);
	if(ret==0)
	{
		ret=(int)sread(s, buf, 5000);
		if(ret < 0)	
		{
			line_pos=0; answer=0, lastcr=0;
			return(ret);
		}
		/* Maybe a segment just arrived between select and sread */
		if(ret > 0) goto _get_grplist_incoming;
		return(0);		
	}

	/* Incoming data, reset timeout */
	
	ret=(int)sread(s, buf, 5000);
	if(ret < 0)	
	{
		line_pos=0; answer=0; lastcr=0;
		return(ret); /* Foreign closed, error */
	}
	
_get_grplist_incoming:

	if(ret==0)	return(0);

	a=0;
	while(a < ret) 
	{
		act_line[line_pos]=buf[a++];
		if((act_line[line_pos]==13) || (act_line[line_pos]==10))
		{/* Line ends */
			/* Ignore LF after CR */
			if((act_line[line_pos]==10)&&(lastcr)){line_pos=0; lastcr=0; continue;}
			if(act_line[line_pos]==13) lastcr=1; else lastcr=0;
			act_line[line_pos]=0;
			line_pos=0;
			while((act_line[line_pos]==10)||(act_line[line_pos]==13))++line_pos;
			if(!answer)
			{
				if(act_line[line_pos]!='2')	/* Reply-Line, ERR */
				{
					ret=1;
					Flog(act_line);Flog("\r\n");
					if(nntp_authenticate(s, atoi(&(act_line[line_pos])))) 
						ret=2;
					else
						++onl_err;
					line_pos=0; answer=0; lastcr=0;
					return(ret);
				}
				if(act_line[line_pos]=='2') /* Reply-Line, OK */
				{
					Flog(act_line);Flog("\r\n");
					answer=1;
					line_pos=0; continue;
				}
				line_pos=0;	/* Forget this line */
				return(0);
			}
			if((act_line[line_pos]=='.')&&(act_line[line_pos+1]==0))
			{/* Done */
				line_pos=0; answer=0; lastcr=0;
				return(1);
			}

			c=strchr(&(act_line[line_pos]), ' '); 	/* name is preceeded by <last> <first> <posting allowed> */
			if(c==NULL) c=strchr(&(act_line[line_pos]), 9);
			if(c!=NULL) *c=0;	/* Terminate String */
			/* Kleinschreibung des Gruppennamens! */
			act_line[line_pos]|=32;
			l=strlen(&(act_line[line_pos]));
			Fwrite(fh, l, &(act_line[line_pos]));
			line_pos=0;
			Fwrite(fh, 2, "\r\n");
			++*groups_rcvd;
		}
		else
			++line_pos;
	}
	return(0);
}

int check_grplist_time(DOSTIME *dtime)
{/* Ret: 0=Ok, 1=Muž aktualisiert werden */
	int day, month, year, check;
	int tday, tmonth, tyear;
	uint	tg;
	
	day=(int)((long)(dtime->date & 31l));
	month=(int)((long)((dtime->date & 480l)/32l));
	year=(int)((long)((dtime->date & 65024l)/512l))+1980;

	tg=Tgetdate();
	tday=(int)((long)(tg & 31l));
	tmonth=(int)((long)((tg & 480l)/32l));
	tyear=(int)((long)((tg & 65024l)/512l))+1980;
	
	check=ios.newslist_days;
	while(check--)
	{
		++day;
		if((day>30) && ((month==4)||(month==6)||(month==9)||(month==11)))
		{
			++month; day-=30;
		}
		else if((day > 28) && (month==2))
		{
			if(((year>>2)<<2)==year)
			{
				if(day > 29) {++month; day-=29;}
			}
			else
			{
				++month; day-=28;
			}
		}
		else if(day > 31)
		{
			++month;
			day+=31;
		}
		if(month > 12)
		{
			month-=12; ++year;
		}
	}	
	
	/* Ist heute schon gr”žer als letzte Aktualisierung plus
			Wartetage? */
	if((tyear>=year)&&(tmonth>=month)&&(tday>=day)) return(1);
	return(0);
}

char *dostime2asc(DOSTIME *dtime)
{
	int min, hr, day, month, year;
	char  num[32], text[16];
	
	text[0]=0;
	
	min=(int)((long)((dtime->time & 2016l)/32l));
	hr=(int)((long)((dtime->time & 63488l)/2048l));
	
	day=(int)((long)(dtime->date & 31l));
	month=(int)((long)((dtime->date & 480l)/32l));
	year=(int)((long)((dtime->date & 65024l)/512l))+1980;
	year-=1900; while(year > 100) year-=100;	/* year nur zweistellig! */
	
	strcat(text, itoa2(year, num));
	strcat(text, itoa2(month, num));
	strcat(text, itoa2(day, num));
	strcat(text, " ");
	strcat(text, itoa2(hr, num));
	strcat(text, itoa2(min, num));
	strcat(text, "00");
	return(text);
}

int actize_group_list(int s, int cmd)
{/* cmd: -1=Abbruch, 0=Init, 1=Cont,
		return: -1=Abbruch (nur bei Init), 0=Cont, 1=Done, <0 Error */
	static char	txt[30];
	DOSTIME	dtime;
	static int fh;
	char 		path[256], num[32];
	static 	long cnt;
	long		ret;
	
	switch(cmd)
	{
		case -1:	/* Abbrechen */
			Fclose(fh);
		return(1);

		case 0:		/* Init */
			/* Gruppenliste existiert? */
			strcpy(path, db_path);
			strcat(path, "\\GRPLIST.TXT");
			ret=Fopen(path, FO_RW);
			if(ret < 0)
			{/* Gruppenliste nicht da */
				if(ret!=EFILNF) {gemdos_alert(gettext(NOOPEN), ret); return(-1);}
				if(form_alert(1, gettext(GETGRPLIST))==2) return(-1);
				ret=Fcreate(path, 0);
				if(ret < 0){gemdos_alert(gettext(CREATEERR), ret); return(-1);}
				fh=(int)ret;
				set_act("List...");
				strcpy(txt, "LIST\r\n");
			}
			else
			{/* Gruppenliste aktualisieren? */
				fh=(int)ret;
				Fdatime(&dtime, fh, 0);
				if(check_grplist_time(&dtime)==0) {Fclose(fh);return(1);}
				dtime.time=Tgettime();
				dtime.date=Tgetdate();
				Fdatime(&dtime, fh, 1);
				Fseek(0, fh, 2);
				set_act("Newgroups...");
				strcpy(txt, "NEWGROUPS ");
				strcat(txt, dostime2asc(&dtime));
				strcat(txt, "\r\n");
			}
			if((ret=send_string(s,txt,0))<0) {Fclose(fh);return((int)ret);}
			cnt=0;
		break;
		case 1:	/* Cont */
			/* Read the list */
			if((ret=rcv_grp_list(s, fh, &cnt))<0) return((int)ret);
			if(ret==2)
			{/* Authentication war n”tig und erfolgreich, Anfrage nochmal
					schicken */
				if((ret=send_string(s,txt,0))<0) {Fclose(fh);return((int)ret);}
				return(0);
			}
			set_act(ltoa(cnt, num, 10));
			if(ret==1) {Fclose(fh); return(1);}
		break;
	}	
	return(0);
}

int send_om(int s, int cmd)
{/* cmd: -1=Abbrechen, 0=Init, 1=Cont */
 /* Return: 0=Cont, 1=Done,  <0=Error */
	char	txt[30], num[10];
	int		dum;
	static int state;
	#define SPOS_NEXT 0
	#define SPOS_POST 1
	#define SPOS_SEND 2
	#define SPOS_WAIT 3
	#define SPOS_FINAL 4
	static char *buf, *rbuf, ompath[256], mailpath[256];
	static long buflen, mail_cnt;
	static long bytes_pushed, bytes_to_send, bytes_sent, total_sent;
	static DTA		*old, dta;
	long		ret, bytes_left;
	
	switch(cmd)
	{
		case -1:	/* Abbrechen */
			if(buf) free(buf);
			Fsetdta(old);
		return(1);

		case 0:		/* Init */
			state=SPOS_NEXT;
			buf=NULL;
			buflen=mail_cnt=0;
			total_sent=0;
			old=Fgetdta();
			Fsetdta(&dta);
			strcpy(ompath, db_path);
			strcat(ompath, "\\OM\\SEND\\*.SND");
		break;
		case 1:	/* Cont */
			switch(state)
			{
				case SPOS_NEXT:
					if(!mail_cnt)
					{
						if(Fsfirst(ompath, 0)) {Fsetdta(old); return(1);}	/* No more mails */
					}
					else
					{
						if(Fsnext()) {Fsetdta(old); return(1);} /* No more mails */
					}
					strcpy(mailpath, db_path);
					strcat(mailpath, "\\OM\\SEND\\");
					strcat(mailpath, dta.d_fname);
					if(buf) free(buf);
					buf=malloc(dta.d_length+1);
					if(buf==NULL) 
					{
						Flog("!!! EMailer Error: Not enough memory to send mail.\r\n");
						Flog("!!! Sending next mail...\r\n");
						++onl_err;
						return(0);	/* Continue with next mail */
					}
					buflen=(long)(dta.d_length+1);
					ret=Fopen(mailpath, FO_READ);
					if(ret < 0) 
					{/* Next mail */
						Flog("!!! EMailer Error: Unable to open mail file\r\n");
						Flog("!!! Sending with next mail...\r\n");
						++onl_err;
						free(buf); buf=NULL; return(0);
					}
					Fread((int)ret, buflen-1, buf);
					Fclose((int)ret);
					buf[buflen-1]=0;
					mail_cnt++;
					state=SPOS_POST;
				break;
				
				case SPOS_POST:
					/* Send the message */
					set_act("Post...");
					if((ret=send_string(s,"POST\r\n",0))<0) return((int)ret);
					if((ret=get_nntp_reply(s, "POST\r\n"))<0) return((int)ret);
					if(ret!=3) {++onl_err; state=SPOS_NEXT; return(0);} /* 340 */
					bytes_sent=0;
					state=SPOS_SEND;
				break;
				case SPOS_SEND:				
					strcpy(txt, ltoa(mail_cnt, num, 10));
					strcat(txt, "/");
					strcat(txt, ltoa(minf.send_oms, num, 10));
					set_act(txt);
					if((ret=send_message_head(s,buf, &rbuf,ios.no_grp_msg_id, 1))<0) return((int)ret);
					bytes_to_send=strlen(rbuf)+(rbuf-buf);
					bytes_pushed=rbuf-buf;
					state=SPOS_WAIT;
				break;
				case SPOS_WAIT:
					dum=(int)sizeof(long);
					getsockopt(s, SOL_SOCKET, SO_SNDBUF, &bytes_left, &dum);
					bytes_sent=bytes_pushed-bytes_left;
					if((bytes_left < PUSH_BLOCK)&&(bytes_pushed < bytes_to_send))
						if((ret=send_block(s,&rbuf,&bytes_pushed))<0) return((int)ret);
					set_process(total_sent+bytes_sent, minf.send_obytes);
					if(bytes_sent==bytes_to_send) state=SPOS_FINAL;
				break;
				case SPOS_FINAL:
					if((ret=send_string(s,"\r\n.\r\n",0))<0) return((int)ret);
					if((ret=get_reply(s))<0) return((int)ret);
					if(ret!=2) {++onl_err; state=SPOS_NEXT; return(0);}
					total_sent+=bytes_to_send;
					/* Versendete Nachricht l”schen */
					Fdelete(mailpath);
					state=SPOS_NEXT;
				break;
			}
		break;
	}	
	return(0);
}

int get_abo_group(int next, char *name, long *read_mark)
{/* next=0/1, 0=first, 1=next
		name=mem by caller, name of group is copied to it
		read_mark=Index of highest message read or -1
		return: 1=abo-group found
						0=no more abo groups */

	static char *c;
	long				cnt,ret;
	char				*d, mem, path[256];

	if(!next) c=grp_inf.oaddr;
	if(!c) return(0);
	while(*c)
	{
		d=c;
		while(*d&&(*d!=13)&&(*d!=10)) ++d;
		mem=*d; *d=0;
		if(!(*c & 32)) 	/* Grožgeschrieben=Abo */
		{
			strcpy(name, c);
			name[0]|=32;
			*d=mem; c=d; 
			while((*c==13)||(*c==10))++c;
			goto _abo_found;
		}
		*d=mem; c=d; 
		while((*c==13)||(*c==10))++c;
	}
	return(0);
	
_abo_found:
	/* Name gefunden, Datei dazu suchen */
	cnt=0;
	*read_mark=-1;
	while(cnt < grp_inf.flds_c)
	{
		if(!stricmp(name, grp_inf.flds[cnt].from))
		{
			strcpy(path, db_path); strcat(path, "\\OM\\");
			strcat(path, grp_inf.flds[cnt].fspec.fname);
			strcat(path, ".IDX");
			ret=Fopen(path, FO_READ);
			if(ret < 0) break;
			Fread((int)ret, sizeof(long), read_mark);
			Fclose((int)ret);
			break;
		}
		++cnt;
	}
	return(1);
}

long find_or_make_group(char *grpname)
{
	long cnt=0;
	
	while(cnt < grp_inf.flds_c)
	{
		if(!stricmp(grpname, grp_inf.flds[cnt].from))
			return(atol(grp_inf.flds[cnt].fspec.fname));
		++cnt;
	}
	/* Gruppe erzeugen */
	cnt=make_group(grpname);
	if(cnt > -1)
		get_groups(&(grp_inf.flds), &(grp_inf.flds_c));
	return(cnt);
}

void store_grp_read_index(long grp_file_num, long read_mark)
{
	char path[256];
	long	ret;
	
	strcpy(path, db_path);
	strcat(path, "\\OM\\");
	ltoa(grp_file_num, &(path[strlen(path)]), 10);
	strcat(path, ".IDX");
	ret=Fcreate(path, 0);
	if(ret < 0) return;
	Fwrite((int)ret, sizeof(long), &read_mark);
	Fclose((int)ret);
}

int get_om(int s, int cmd)
{/* cmd: -1=Abbrechen, 0=Init, 1=Cont */
 /* Return: 0=Cont, 1=Done,  <0=Error */
 	static char grpname[256];
	char	txt[263], cmd_line[263], num[10], *c, *d;
	static int state, grpinit, fh;
	#define SPOG_NEXTGRP 0
	#define SPOG_STAT 1
	#define SPOG_HEAD 2
	#define SPOG_HEAD_WAIT 3
	#define SPOG_BODY 4
	#define SPOG_BODY_WAIT 5
	#define SPOG_ARTICLE 6
	#define SPOG_ARTICLE_WAIT 7
	#define SPOG_NEXT 8
	static	long rcvd_bytes;
	static	long	read_mark, low_mark, hi_mark;
	static	long grp_file_num, om_file_num;
	static 	int	 hb_mode;
	long		ret, fhl;
	
	switch(cmd)
	{
		case -1:	/* Abbrechen */
			Fclose(fh);
		return(1);

		case 0:		/* Init */
			state=SPOG_NEXTGRP;
			grpinit=0;
			/* Head/Body-Modus aktivieren, falls ein Download-Filter aktiv ist */
			hb_mode=stop_download_filter();
		break;
		case 1:	/* Cont */
			switch(state)
			{
				case SPOG_NEXTGRP:
					if(get_abo_group(grpinit, grpname, &read_mark)==0) return(1); /* No more groups */
					grpinit=1;
					set_process(0, 1);
					set_act("Group...");
					strcpy(txt, "GROUP ");
					strcat(txt, grpname);
					strcat(txt, "\r\n");
					strcpy(cmd_line, txt);
					if((ret=send_string(s,txt,0))<0) return((int)ret);
					if((ret=get_full_nntp_reply(s,txt,cmd_line))<0) return((int)ret);
					if(ret!=2) {++onl_err; return(0);} /* 211 -> next group */
					c=strchr(txt, ' ');
					if(c==NULL) return(0); /* No <number> */
					c=strchr(c+1, ' ');
					if(c==NULL) return(0); /* No <first> */
					++c;
					d=strchr(c, ' ');
					if(d==NULL) return(0); /* No <last> */
					*d=0;
					low_mark=atol(c);
					c=d+1;
					d=strchr(c, ' ');
					if(d==NULL) return(0); /* No <name> */
					*d=0;
					hi_mark=atol(c);
					++read_mark;
					if(read_mark < low_mark) read_mark=low_mark;
					/* Start-Index setzen */
					if(ios.news_new)
						if((read_mark+ios.news_num) < hi_mark)
							read_mark=hi_mark-ios.news_num+1;
					low_mark=read_mark;
					/* Neue Nachrichten? */
					if(hi_mark < low_mark) return(0);
					state=SPOG_STAT;
				break;
				
				case SPOG_STAT:
					/* Set read-index */
					do
					{
						strcpy(txt, "STAT ");
						strcat(txt, ltoa(read_mark, num, 10));
						set_act(txt);
						strcat(txt, "\r\n");
						if((ret=send_string(s,txt,0))<0) {state=SPOG_NEXTGRP; return((int)ret);}
						if((ret=get_nntp_reply(s,txt))<0) {state=SPOG_NEXTGRP; return((int)ret);}
						if(ret==4) /* 423 No such mail -> try next */
						{
							++read_mark;
							if(read_mark > hi_mark) {state=SPOG_NEXTGRP; return(0);} /* next group */
							continue;
						}
						if(ret!=2) {state=SPOG_NEXTGRP; return(0);} /* 223 -> next group */
					}
					while(ret!=2);
					ret=find_or_make_group(grpname);
					if(ret < 0) {state=SPOG_NEXTGRP; return(0);} /* next group */
					grp_file_num=ret;
					strcpy(txt, db_path);
					strcat(txt, "\\OM\\");
					strcat(txt, ltoa(grp_file_num, num, 10));
					strcat(txt, "\\");
					om_file_num=atol(get_free_file(txt));
					if(hb_mode)
						state=SPOG_HEAD;
					else
						state=SPOG_ARTICLE;
				break;
				
				case SPOG_HEAD:
					strcpy(txt, "Head ");
					strcat(txt, ltoa(read_mark-low_mark+1, num, 10));
					strcat(txt, "/");
					strcat(txt, ltoa(hi_mark-low_mark+1, num, 10));
					set_act(txt);
					strcpy(txt, db_path);
					strcat(txt, "\\OM\\");
					strcat(txt, ltoa(grp_file_num, num, 10));
					strcat(txt, "\\");
					strcat(txt, ltoa(om_file_num, num, 10));
					strcat(txt, ".NEW");
					fhl=Fcreate(txt, 0);
					if(fhl < 0) {state=SPOG_NEXT; return(0);}
					filt_log(txt);
					fh=(int)fhl;
					if((ret=send_string(s,"HEAD\r\n",0))<0) {Fclose(fh);state=SPOG_NEXTGRP; return((int)ret);}
					state=SPOG_HEAD_WAIT;
					rcvd_bytes=0;
				break;
				
				case SPOG_HEAD_WAIT:
					if((ret=rcv_nntp_block(s, fh, &rcvd_bytes))<0) {Fclose(fh); state=SPOG_NEXT; return((int)ret);}
					if(ret==1)
					{
						if(rcvd_bytes==0) {Fclose(fh); state=SPOG_NEXT; return(0);}
						Fwrite(fh, 2, "\r\n");
						if(check_grp_download_filter(fh, rcvd_bytes))
						{
							Fclose(fh); state=SPOG_NEXT; return(0);
						}
						state=SPOG_BODY;
					}
					else if(ret==2)
					{ /* Authentication war notwendig und erfolgreich, Anfrage wiederholen */
						if((ret=send_string(s,"HEAD\r\n",0))<0) {Fclose(fh);state=SPOG_NEXT; return((int)ret);}
					}
				break;
		
				case SPOG_BODY:
					strcpy(txt, "Body ");
					strcat(txt, ltoa(read_mark-low_mark+1, num, 10));
					strcat(txt, "/");
					strcat(txt, ltoa(hi_mark-low_mark+1, num, 10));
					set_act(txt);
					if((ret=send_string(s,"BODY\r\n",0))<0) {Fclose(fh);state=SPOG_NEXTGRP; return((int)ret);}
					state=SPOG_BODY_WAIT;
					rcvd_bytes=0;
				break;

				case SPOG_BODY_WAIT:
					if((ret=rcv_nntp_block(s, fh, &rcvd_bytes))<0) {Fclose(fh); state=SPOG_NEXT; return((int)ret);}
					if(ret==1)
					{
						Fclose(fh);
						++om_file_num;
						++new_om;
						set_process(read_mark-low_mark+1, hi_mark-low_mark+1);
						state=SPOG_NEXT;
					}
					else if(ret==2)
					{ /* Authentication war notwendig und erfolgreich, Anfrage wiederholen */
						if((ret=send_string(s,"BODY\r\n",0))<0) {Fclose(fh);state=SPOG_NEXT; return((int)ret);}
					}
				break;

				case SPOG_ARTICLE:
					strcpy(txt, "Article ");
					strcat(txt, ltoa(read_mark-low_mark+1, num, 10));
					strcat(txt, "/");
					strcat(txt, ltoa(hi_mark-low_mark+1, num, 10));
					set_act(txt);
					strcpy(txt, db_path);
					strcat(txt, "\\OM\\");
					strcat(txt, ltoa(grp_file_num, num, 10));
					strcat(txt, "\\");
					strcat(txt, ltoa(om_file_num, num, 10));
					strcat(txt, ".NEW");
					fhl=Fcreate(txt, 0);
					if(fhl < 0) {state=SPOG_NEXT; return(0);}
					filt_log(txt);
					fh=(int)fhl;
					if((ret=send_string(s,"ARTICLE\r\n",0))<0) {Fclose(fh);state=SPOG_NEXTGRP; return((int)ret);}
					state=SPOG_ARTICLE_WAIT;
					rcvd_bytes=0;
				break;

				case SPOG_ARTICLE_WAIT:
					if((ret=rcv_nntp_block(s, fh, &rcvd_bytes))<0) {Fclose(fh); state=SPOG_NEXT; return((int)ret);}
					if(ret==1)
					{
						Fclose(fh);
						++om_file_num;
						++new_om;
						set_process(read_mark-low_mark+1, hi_mark-low_mark+1);
						state=SPOG_NEXT;
					}
					else if(ret==2)
					{ /* Authentication war notwendig und erfolgreich, Anfrage wiederholen */
						if((ret=send_string(s,"ARTICLE\r\n",0))<0) {Fclose(fh);state=SPOG_NEXT; return((int)ret);}
					}
				break;

				case SPOG_NEXT:
					state=SPOG_NEXTGRP; 
					set_act("Next...");
					if((ret=send_string(s,"NEXT\r\n",0))<0) return((int)ret);
					if((ret=get_full_reply(s, txt))<0) return((int)ret);
					if(ret!=2) 
					{/* Group done */
						store_grp_read_index(grp_file_num, read_mark);
						return(0);
					}
					c=strchr(txt, ' ');
					if(c==NULL) {store_grp_read_index(grp_file_num, read_mark); return(0);} /* No <number> */
					++c;
					d=strchr(c, ' ');
					if(d==NULL) {store_grp_read_index(grp_file_num, read_mark); return(0);} /* No <number> */
					*d=0;
					ret=atol(c);
					if(ret <= read_mark) {store_grp_read_index(grp_file_num, read_mark); return(0);} /* No <number> */
					read_mark=ret;
					if(hb_mode)
						state=SPOG_HEAD;
					else
						state=SPOG_ARTICLE;
				break;
			}
		break;
	}	
	return(0);
}

void online_automat(int cmd)
{/* cmd: -1=Abbrechen, 0=Init, 1=Cont */
	static int status, sub_state, cnt, ic_id, sock;
	static 	sockaddr_in sad;
	char		buf[128];
	int	ret, first_try;
	USIS_REQUEST	ur;
			
	if(cmd==-1)
	{
		switch(status)
		{
			case ES_INITIAL:
			case ES_INWAIT:
				/* Aufgelegt wird vom Aufrufer */
			break;
			case ES_CONNSMTP:
			case ES_CONNPOP:
			case ES_CONNNNTP:
				to_connect(sock, &sad, (int)sizeof(sockaddr_in), -1);
			break;
			case ES_SENDPM:	send_pm(sock, -1); break;
			case ES_GETPM:	get_pm(sock, -1); break;
			case ES_GRPLIST: actize_group_list(sock, -1); break;
			case ES_SENDOM: send_om(sock, -1); break;
			case ES_GETOM: get_om(sock, -1); break;
		}
		shutdown(sock,2);
		sclose(sock);
		w_close(&wonline); 
		return;
	}
	
	if(cmd==0) 
	{
		status=ES_INITIAL;
		return;
	}
	
	switch(status)
	{
		case ES_INITIAL:
			minf.me_connect=0;
			set_stat(OL1); set_act("");
			if(start_iconnect()==0) {w_close(&wonline); return;}
			if(iconnect()==0) {w_close(&wonline); return;}
			evnt_timer(1000,0);
			cnt=0;
			ic_id=appl_find("ICONNECT");
			status=ES_INWAIT;
			sub_state=SS_ENTER;
			first_try=1;
		break;
		
		case ES_INWAIT:
			if(cnt==0)
			{
				switch(sub_state)
				{
					case SS_ENTER:
						if((ret=get_stat(ic_id))==ICMS_ONLINE) /* Connected */
						{
							sub_state=SS_CONT;
							return;
						}
						/* If this is the second time we come here and the state
						   is ICMS_OFFLINE something has gone wrong (IConnect 
						   should be in connecting state) */
						if((!first_try) && (ret==ICMS_OFFLINE)) 
						{
							if(form_alert(1, gettext(NO_ICONNECT))==2)
							{ 
								w_close(&wonline); 
								return;
							}
						}
						first_try=0;
					break;				
					case SS_CONT:
					/* Check if the services are already available */
						ur.request=UR_RESOLVED;
						if(usis_query(&ur)!=UA_NOTSET) sub_state=SS_DONE;
					break;
					case SS_DONE:
					/* Get the service entries */
						set_stat(OL1_1);
						if(init_minf()==0) {w_close(&wonline); return;}
						status=ES_CONNPOP; 
						sub_state=SS_ENTER; 
					return;
				}
				cnt=10;	/* ca. 1 Sek. */
			}
			else
				--cnt;
		break;

		/* ----------- POP -------------- */

		case ES_CONNPOP:
			switch(sub_state)
			{
				case SS_ENTER:
					Flog("\r\n\r\nPOP-");
					if(minf.do_pm==0) {Flog("dialogue override\r\n");status=ES_CONNNNTP; return;}
					set_process(0, 1);
					if(single_send) {Flog("no job\r\n");status=ES_CONNSMTP; return;}
					if(minf.pop_ip==0) {Flog("no IP\r\n");status=ES_CONNNNTP; return;}
					Flog("Session:\r\n");
					sock=socket(AF_INET, SOCK_STREAM, 0);
					if(sock < 0) return;
					/* connect to remote host */
					sfcntl(sock,F_SETFL,O_NDELAY);
					set_stat(OL4);
					sad.sin_family=AF_INET;
					sad.sin_port=minf.pop_port;
					sad.sin_addr=minf.pop_ip;
					ret=to_connect(sock, &sad, (int)sizeof(sockaddr_in), 0);
					if(ret < 0)
					{
						net_alert(ret);
						sclose(sock);
						w_close(&wonline);
						return;
					}
					sub_state=SS_CONNECT;
				break;
				case SS_CONNECT:
					ret=to_connect(sock, &sad, (int)sizeof(sockaddr_in), 1);
					if(ret==ETIMEDOUT)
					{
						net_alert(ret);
						sclose(sock);
						w_close(&wonline);
						return;
					}
					if(ret==1) 
					{
						/* Wait for OK response */
						if((ret=get_pop_reply(sock))<0)	{net_alert(ret);sclose(sock);w_close(&wonline);return;}
						if(ret=='-'){++onl_err; sclose(sock); status=ES_CONNSMTP; sub_state=SS_ENTER; return;} /* +OK expected */
						status=ES_GETPM; sub_state=SS_ENTER;
						return;
					}
				break;
			}
		break;
		case ES_GETPM:
			switch(sub_state)
			{
				case SS_ENTER:
					set_stat(OL4B);
					set_act("User");
					strcpy(buf, "USER "); strcat(buf, minf.pop_user);
					strcat(buf, "\r\n");
					send_string(sock, buf,0);
					if((ret=get_pop_reply(sock))<0)	{net_alert(ret);sclose(sock);w_close(&wonline);return;}
					if(ret=='-'){sclose(sock); form_alert(1, gettext(ERRPOPUSER)); status=ES_CONNSMTP; sub_state=SS_ENTER;return;} /* +OK expected */
					set_act("Pass");
					strcpy(buf, "PASS "); strcat(buf, minf.pop_pass);
					strcat(buf, "\r\n");
					send_string(sock, buf,0);
					if((ret=get_pop_reply(sock))<0)	{net_alert(ret);sclose(sock);w_close(&wonline);return;}
					if(ret=='-'){sclose(sock); form_alert(1, gettext(ERRPOPPASS)); status=ES_CONNSMTP; sub_state=SS_ENTER;return;} /* +OK expected */
					set_act("List...");
					send_string(sock, "LIST\r\n", 0);
					if((ret=get_pm_list(sock))<0){net_alert(ret);sclose(sock);w_close(&wonline);return;}
					if(user_pm_list(sock)==0)
					{/* Nothing to do */
						send_string(sock, "QUIT\r\n",0);
						get_pop_reply(sock);
						sclose(sock);
						status=ES_CONNSMTP; sub_state=SS_ENTER;
						return;
					}
					sub_state=SS_CONT;
					set_stat(OL5);
					get_pm(sock, 0);
				break;
				case SS_CONT:
					switch(ret=get_pm(sock, 1))
					{
						case 0:	/* Continue */
						break;
						case 1:	/* Done */
							set_process(0, 1);
							set_act("Quit...");
							send_string(sock,"QUIT\r\n",0);
							get_pop_reply(sock);
							shutdown(sock,2);
							sclose(sock);
							sub_state=SS_DONE;
						break;
						default:	/* Error-Codes */
							get_pm(sock, -1);
							net_alert(ret);
							shutdown(sock,2);
							sclose(sock);
							sub_state=SS_DONE;
						break;
					}
				break;
				case SS_DONE:
					/* Auf Server gebliebene Dateien merken */
					write_server_left();
					status=ES_CONNSMTP;
					sub_state=SS_ENTER;
				break;
			}
		break;

		/* ----------- SMTP -------------- */

		case ES_CONNSMTP:
			switch(sub_state)
			{
				case SS_ENTER:
					Flog("SMTP-");
					if(minf.send_pms==0) {Flog("no job\r\n");status=ES_CONNNNTP; return;}
					if(minf.smtp_ip==0) {Flog("no IP\r\n");status=ES_CONNNNTP; return;}
					Flog("Session:\r\n");
					sock=socket(AF_INET, SOCK_STREAM, 0);
					if(sock < 0) return;
					/* connect to remote host */
					sfcntl(sock,F_SETFL,O_NDELAY);
					set_stat(OL2);
					sad.sin_family=AF_INET;
					sad.sin_port=minf.smtp_port;
					sad.sin_addr=minf.smtp_ip;
					ret=to_connect(sock, &sad, (int)sizeof(sockaddr_in), 0);
					if(ret < 0)
					{
						net_alert(ret);
						sclose(sock);
						w_close(&wonline);
						return;
					}
					sub_state=SS_CONNECT;
				break;
				case SS_CONNECT:
					ret=to_connect(sock, &sad, (int)sizeof(sockaddr_in), 1);
					if(ret==ETIMEDOUT)
					{
						net_alert(ret);
						sclose(sock);
						w_close(&wonline);
						return;
					}
					if(ret==1) 
					{
						/* Wait for OK response */
						if((ret=get_reply(sock))<0)	{net_alert(ret);sclose(sock);w_close(&wonline);return;}
						if(ret!=2){++onl_err; sclose(sock); status=ES_CONNNNTP; sub_state=SS_ENTER; return;} /* 220 expected */
						status=ES_SENDPM; sub_state=SS_ENTER;
						return;
					}
				break;
			}
		break;
		
		case ES_SENDPM:
			switch(sub_state)
			{
				case SS_ENTER:
					set_act("HELO");
					strcpy(buf, "HELO "); strcat(buf, inet_ntoa(minf.local_ip));
					strcat(buf, "\r\n");
					send_string(sock, buf,0);
					if((ret=get_reply(sock))<0)	{net_alert(ret);sclose(sock);w_close(&wonline);return;}
					if(ret!=2){++onl_err; sclose(sock); form_alert(1, gettext(ERRPOPUSER)); status=ES_CONNNNTP; sub_state=SS_ENTER;return;} /* +OK expected */
					set_stat(OL3);
					send_pm(sock, 0);
					sub_state=SS_CONT;
				break;
				case SS_CONT:
					switch(ret=send_pm(sock, 1))
					{
						case 0:	/* Continue */
						break;
						case 1:	/* Done */
							send_string(sock,"QUIT\r\n",0);
							get_reply(sock);
							shutdown(sock,2);
							sclose(sock);
							status=ES_CONNNNTP;
							sub_state=SS_ENTER;
						break;
						default:	/* Error-Codes */
							send_pm(sock, -1);
							net_alert(ret);
							shutdown(sock,2);
							sclose(sock);
							status=ES_CONNNNTP;
							sub_state=SS_ENTER;
						break;
					}
				break;
			}
		break;

		/* ----------- NNTP -------------- */

		case ES_CONNNNTP:
			switch(sub_state)
			{
				case SS_ENTER:
					Flog("\r\n\r\nNNTP-");
					set_process(0, 1);
					if(minf.do_om==0) {Flog("dialogue override\r\n");status=ES_DONE; return;}
					if(minf.nntp_ip==0) {Flog("no IP\r\n");status=ES_DONE; return;}
					Flog("Session:\r\n");
					sock=socket(AF_INET, SOCK_STREAM, 0);
					if(sock < 0) return;
					/* connect to remote host */
					sfcntl(sock,F_SETFL,O_NDELAY);
					set_stat(OL6);
					set_act("");
					sad.sin_family=AF_INET;
					sad.sin_port=minf.nntp_port;
					sad.sin_addr=minf.nntp_ip;
					ret=to_connect(sock, &sad, (int)sizeof(sockaddr_in), 0);
					if(ret < 0)
					{
						net_alert(ret);
						sclose(sock);
						w_close(&wonline);
						return;
					}
					sub_state=SS_CONNECT;
				break;
				case SS_CONNECT:
					ret=to_connect(sock, &sad, (int)sizeof(sockaddr_in), 1);
					if(ret==ETIMEDOUT)
					{
						net_alert(ret);
						sclose(sock);
						w_close(&wonline);
						return;
					}
					if(ret==1) 
					{
						/* Wait for OK response */
						if((ret=get_reply(sock))<0)	{net_alert(ret);sclose(sock);w_close(&wonline);return;}
						if(ret!=2){++onl_err; sclose(sock); status=ES_DONE; return;} /* 220/221 expected */
						status=ES_GRPLIST; sub_state=SS_ENTER;
						return;
					}
				break;
			}
		break;
		
		case ES_GRPLIST:
			switch(sub_state)
			{
				case SS_ENTER:
					switch(ret=actize_group_list(sock, 0))
					{
						case -1: /* User-Abbruch bei Donwload-Alert */
							shutdown(sock, 2); 
							sclose(sock); 
							status=ES_DONE; 
						break;
						case 1:	/* Fertig (nichts zu holen) */
							status=ES_SENDOM; 
							sub_state=SS_ENTER; 
						break;
						case 0:	/* Weitermachen */
							set_stat(OL9);
							sub_state=SS_CONT;
						break;
						default:	/* Error-Codes */
							net_alert(ret);
							shutdown(sock,2);
							sclose(sock);
							sub_state=ES_DONE;	/* Leave Internet */
						break;
					}
				break;
				case SS_CONT:
					switch(ret=actize_group_list(sock, 1))
					{
						case 0:	/* Continue */
						break;
						case 1:	/* Done */
							status=ES_SENDOM; 
							sub_state=SS_ENTER; 
						break;
						default:	/* Error-Codes */
							actize_group_list(sock, -1);
							net_alert(ret);
							shutdown(sock,2);
							sclose(sock);
							sub_state=ES_DONE;	/* Leave Internet */
						break;
					}
				break;
			}
		break;
		
		case ES_SENDOM:
			switch(sub_state)
			{
				case SS_ENTER:
					if(minf.send_oms==0) {status=ES_GETOM; return;}
					set_stat(OL8);
					send_om(sock, 0);
					sub_state=SS_CONT;
				break;
				case SS_CONT:
					switch(ret=send_om(sock, 1))
					{
						case 0:	/* Continue */
						break;
						case 1:	/* Done */
							status=ES_GETOM;
							sub_state=SS_ENTER;
						break;
						default:	/* Error-Codes */
							send_om(sock, -1);
							net_alert(ret);
							shutdown(sock,2);
							sclose(sock);
							status=ES_DONE;
						break;
					}
				break;
			}
		break;

		case ES_GETOM:
			switch(sub_state)
			{
				case SS_ENTER:
					set_stat(OL7);
					get_om(sock, 0);
					sub_state=SS_CONT;
				break;
				case SS_CONT:
					switch(ret=get_om(sock, 1))
					{
						case 0:	/* Continue */
						break;
						case 1:	/* Done */
							send_string(sock,"QUIT\r\n",0);
							get_reply(sock);
							shutdown(sock,2);
							sclose(sock);
							status=ES_DONE;
						break;
						default:	/* Error-Codes */
							get_om(sock, -1);
							net_alert(ret);
							shutdown(sock,2);
							sclose(sock);
							status=ES_DONE;
						break;
					}
				break;
			}
		break;

		case ES_DONE:
			w_close(&wonline); 
		break;
	}
}

/* ------------------------------- */

void send_now(char *file)
{
	if(form_alert(1, gettext(SENDNOW))==2) return;
	minf.always_show=0;
	minf.do_pm=1;
	minf.do_om=0;
	single_send=file;
	run_jobs();	
}