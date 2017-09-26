 #define DEB_OVER 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <aes.h>
#include <socket.h>
#include <sockios.h>
#include <sfcntl.h>

#include "network.h"
#include "slip.h"
#include "ip.h"
#include "tcp.h"
#include "ppp.h"
#include "resolver.h"
#include "socksys.h"
#include "stiplink.h"

#define SlipID 'SLIP'
#define sliptext "Sockets for MagiC V1.8 01.03.2000"
#define slip_alert "[1][Sockets for MagiC V1.8 01.03.2000|by Sven Kopacz - Installed|(C) Application Systems Heidelberg][OK]"
#define slip_err_alert "[1][Sockets for MagiC V1.8 01.03.2000|by Sven Kopacz|ERROR: Already installed|(C) Application Systems Heidelberg][OK]"
#define COOK_VERS 4

#define ADDCKI 10l
#define AUTO 1
#define APP 2
#define ACC 3

/* -------------------------------------- */

/* Registrierungsdaten */

char	*reg_active="rMa*paTB*R#-n";
char	*reg_name="nnnnnnnnnnnnnnnnnnnnnnnnnnnnnn";
char	*reg_firma="ffffffffffffffffffffffffffffff";
char	*reg_serial="ssssssssss";


char	mset=0;
ulong	mlen=0;
void	*madr=0;
void timer_malloc(void);
void *(*iimalloc)(ulong len);
void (*iifree)(void *block);
void (*iwait)(int ms);

/* -------------------------------------- */

typedef struct
{
	long id, val;
}COOKIE;

/* -------------------------------------- */

extern void install(void);
extern int	counter;
extern int init_ok;	/* Stip-Init */

extern	sock_dscr	*first_sock;

/* -------------------------------------- */

BASPAG					**act_pd;
user_interface	u_functions;
sys_interface		s_functions;
default_values	defaults;
cookie_struct		cook;
int							port_handle=-1, db_handle=-1;	/* Used by Slip */

unsigned long		super_stack;

/* -------------------------------------- */

void	init(void);
int 	check_reg(void);

/* -------------------------------------- */

void timer_jobs(void)
{
	timer_malloc();
	if(defaults.using_mac_os)
		x_timer_jobs();
	else
	{
		tcp_timer_jobs();
		ip_timer_jobs();
		if(defaults.using_ppp)
			ppp_timer_jobs();
		else
			slip_timer_jobs();
	}
}

/* -------------------------------------- */

void ifree(void *block)
{
	while(!set_flag(MEMSYS_SEM));
	iifree(block);
	clear_flag(MEMSYS_SEM);
}
/* -------------------------------------- */

void *imalloc(ulong len)
{
	void *p;
	
	while(!set_flag(MEMSYS_SEM));
	p=iimalloc(len);
	clear_flag(MEMSYS_SEM);
	return(p);
}
/* -------------------------------------- */

void close_port(void)
{

/*	Psemaphore(1, 'WAIT', 0);*/
	if(port_handle > -1) /* Connected */
	{
		Fclose(port_handle);
	}
	port_handle=-1;
	if(db_handle > -1)
	{
		Fclose(db_handle);
	}
	db_handle=-1;
	
	init();
	ppp_init();
}
/* -------------------------------------- */

void wait_ms(int ms)
{/* wait for ms milliseconds */

/*	Psemaphore(2,'WAIT',ms);*/
	int when=counter+ms/5;
	
	while(counter < when)	Syield();
}
/* -------------------------------------- */

int		stip_init(void)
{
	iimalloc=s_functions.emalloc;
	iifree=s_functions.efree;
	/* Kromke problem */
 	iwait=wait_ms;

	if(s_functions._debug != NULL)
		db_handle=(int)Fcreate("DEBUG.LOG",0);
	else
		db_handle=-1;

 	return(stiplink_init());
}

void open_port(int port_hdl)
{
	iimalloc=s_functions.emalloc;
	iifree=s_functions.efree;
	/* Kromke problem */
 	iwait=wait_ms;
	/* Auch nicht besser */
	/*	iwait=s_functions.etimer; */
	
	if(s_functions._debug != NULL)
		db_handle=(int)Fcreate("DEBUG.LOG",0);
	else
		db_handle=-1;

	port_handle=port_hdl;

	ppp_init();
/* Set buffer size, not supported by HSMODEM 
	bufs[0]=1024;
	bufs[1]=-1;
	bufs[2]=-1;
	bufs[3]=1024;
	#define TIOCBUFFER (('T'<<8) | 128) 
	ierr=Fcntl(port_handle, (long)bufs, TIOCBUFFER);
*/
}
/* -------------------------------------- */

void terminate(void)
{
	sockets_abort();
	init_ok=0;
}
/* -------------------------------------- */

void *tmalloc(ulong len)
{/* Malloc via timer */
	if(s_functions.server_pd==NULL)	/* No Server available */
		return(NULL);
		
	if(*act_pd==s_functions.server_pd)
	{/* Call from Timer-Routine is a call from the Server */
	 /* Malloc immediately */
	 	return(imalloc(len));
	}

	/* Get the semaphore */
	while(!set_flag(MEM_SEM));
	/* Set the parameters */
	mset=0;
	mlen=len;
	/* Wait for answer */
	while(mset==0);
	clear_flag(MEM_SEM);
	return(madr);
}
/* -------------------------------------- */

void check_malloc(void)
{/* Do the timer-malloc if the server is pending in an set_flag */

	if(*act_pd==s_functions.server_pd)	/* It's the kernel-server */
		timer_malloc();
}
/* -------------------------------------- */

void timer_malloc(void)
{
	if(mlen==0) return; /* No Request */
	/* Else allocate Memory */
	madr=imalloc(mlen);
	mlen=0;
	mset=1;
}
/* -------------------------------------- */

int cdecl usis_dummy(USIS_REQUEST *r)
{
	if(r==NULL) r=r;	/* Supress compiler warning */
	return(UA_OFFLINE);
}
/* -------------------------------------- */

void init(void)
{
	int	ms=100; /* time between timer_jobs calls by server in ms */

	port_handle=-1;

	u_functions.version=COOK_VERS;
	u_functions.socket=socket;
	u_functions.bind=bind;
	u_functions.listen=listen;
	u_functions.accept=accept;
	u_functions.connect=connect;

	u_functions.write=swrite;
	u_functions.send=send;
	u_functions.sendto=sendto;

	u_functions.read=sread;
	u_functions.recv=recv;
	u_functions.recvfrom=recvfrom;
	
	u_functions.select=select;
	u_functions.status=status;
	u_functions.shutdown=shutdown;
	u_functions.close=sclose;

	u_functions.sfcntl=sfcntl;
	u_functions.getsockopt=getsockopt;
	u_functions.setsockopt=setsockopt;
	u_functions.getsockname=getsockname;
	u_functions.getpeername=getpeername;
	
	u_functions.res_init=res_init;
	u_functions.res_query=res_query;
	u_functions.res_search=res_search;
	u_functions.res_mkquery=res_mkquery;
	u_functions.res_send=res_send;
	u_functions.dn_expand=dn_expand;
	u_functions.dn_comp=dn_comp;

	u_functions.usis=usis_dummy;

	s_functions.timer_jobs=timer_jobs;
	s_functions.open_port=open_port;
	s_functions.ppp_event=ppp_automaton;
	s_functions.close_port=close_port;
	s_functions.terminate=terminate;
	s_functions.server_pd=NULL;
	s_functions._debug=NULL;
	s_functions.stip_init=stip_init;
	
	defaults.my_ip=0;
	defaults.peer_ip=0;
	defaults.name_server_ip=0;
	defaults.clk_tck=1000/ms;	/* Ticks per second by timer_jobs */
	
	defaults.port_init=1025;
	defaults.port_max=4999;
	defaults.max_listen=16;
	
	defaults.dns_timeout=6;
	defaults.dns_retry=4;
	
	defaults.udp_count=64;
	
	defaults.user_timeout=60;
	defaults.connection_timeout=60;
	defaults.snd_wnd=512;
	defaults.rcv_wnd=2048;
	defaults.allow_precedence_raise=1;
	defaults.disable_send_ahead=0;
	
	defaults.kill_ip_timer=350;
	defaults.security=0;
	defaults.precedence=0;
	defaults.TOS=0;
	defaults.TTL=64;
	defaults.MTU=576;	/* 576 rec. minimum */
	
	defaults.ppp_warn_illegal=0;
	defaults.ppp_max_terminate=2;
	defaults.ppp_max_configure=10;
	defaults.ppp_max_failure=5;
	defaults.ppp_default_timer=500/defaults.clk_tck;	/* 500 ms */
	defaults.ppp_terminate_timer=1000/defaults.clk_tck; /* 1 sec. */
	defaults.ppp_mru=1500;		/* Max. receive unit */
	defaults.ppp_tls=0;				/* Not Started */
	defaults.ppp_suc=0;				/* sign_up complete? */
	defaults.ppp_crj_sent=0;	/* code reject sent? */
	defaults.ppp_crj_recv=0;	/* code reject sent? */
	defaults.ppp_prj_sent=0;	/* protocol reject sent? */
	defaults.ppp_prj_recv=0;	/* protocol reject sent? */
	defaults.ppp_auth_req=0;	/* authenticate request? */
	defaults.ppp_lqp_req=0;		/* link quality report request? */

	defaults.ppp_authenticate=0;
	defaults.ppp_auth_nak=0;
	defaults.ppp_auth_user[0]=0;
	defaults.ppp_auth_pass[0]=0;

	defaults.ppp_lcp_echo_sec=0;
	
	defaults.ipcp_address_rej=0;	/* errors during ipcp-config */
	defaults.ipcp_dns_rej=0;

	defaults.using_ppp=0;
	defaults.using_mac_os=0;
	
	defaults.bytes_sent=0;
	defaults.bytes_rcvd=0;

	cook.defs=&defaults;
	cook.user=&u_functions;
	cook.sys=&s_functions;
	
	res_init();
}

/* -------------------------------------- */

COOKIE *install_cookie_jar(long n)
{
	COOKIE *cookie;
	
	cookie=Malloc(sizeof(COOKIE)*n);
	super_stack=Super(0l);
	*(long*)0x5a0l=(long)cookie;
	Super((void*)super_stack);
	cookie->id=0l;
	cookie->val=n;
	return(cookie);
}
/* -------------------------------------- */

int main(void)
{
	COOKIE	*cookie, *cookieo;
	int			ncookie=0, ap_type, me_id, ap_id, pbuf[32], r=0;
	long		jarsize;
	
	ap_type=0;
	
	if(check_reg()==0) return(-1);

	if (_app)
	{ /* Als Programm gestartet */
		(_GemParBlk.global[0])=0;
		ap_id=appl_init();
		if (_GemParBlk.global[0])
		{/* Nicht aus Auto-Ordner gestartet */
			ap_type=APP;
		}
		else
		{/* Aus Auto-Ordner gestartet... */
			ap_type=AUTO;
		}
	}
	else /* Als Accessory gestartet */
	{
		ap_id=appl_init();
		if(ap_id >= 0)
		{
			ap_type=ACC;
			me_id=menu_register(ap_id,"  Sockets (Fehlstart)");
			if(me_id != -1)
			{
				while(1) evnt_timer(32767,32767);
			}
			else /* Fehler beim Registrieren im Men */
			{	appl_exit();}
		}
		else
			return(0);
	}

	if (ap_type==AUTO)
	{
		Cconws("\33p");
		Cconws(sliptext);
		Cconws("\r\n(C) Application Systems Heidelberg\r\n");
		Cconws("\33q\n\r");
		Cconws("By Sven Kopacz\n\r");
		Cconws("Registriert auf:\r\n");
		Cconws(reg_name);
		Cconws("\r\n");
		Cconws(reg_firma);
		Cconws("\r\n\r\n");
	}

	super_stack=Super(0L);
	cookie=cookieo=(COOKIE*)(*(long*)0x5a0l);
	act_pd=(BASPAG**)(((SYSHDR*)(*(long*)0x4f2l))->_run);
	Super((void*)super_stack);

	if (!cookie)
	{
		cookie=install_cookie_jar(ADDCKI);
		ncookie=0;
	}
	else
	{
		for(;((cookie->id)&&(cookie->id!=SlipID));cookie++,ncookie++);
	}
	/* cookie zeigt auf Slipcookie oder Nullcookie */
	if (!cookie->id)
	{ /* Noch nicht installiert */
		if ( ((ap_type==AUTO) && (cookie->val-ncookie < ADDCKI)) ||
				 ((ap_type==APP) && (cookie->val-ncookie < 2)) )
		{/* Jar vergr”žern */

		#ifndef DEB_OVER
			if(ap_type==APP)
			{
				form_alert(1,"[3][Ihr Cookie-Jar ist zu klein.|Starten Sie SOCKETS.PRG aus dem|AUTO-Ordner.][Abbruch]");
				return(0);
			}
		#endif

			cookie=install_cookie_jar(cookie->val+ADDCKI-(cookie->val-ncookie));

			for (;cookieo->id!=0L;
					(*cookie++)=(*cookieo++));
			cookie->id=0L;
			cookie->val=cookieo->val+ADDCKI-(cookieo->val-ncookie);
		}

		/* Cookie eintragen */
		jarsize=cookie->val;
		cookie->id=SlipID;
		cookie++->val=(long)&cook;
		cookie->id=0L;
		cookie->val=jarsize;
#ifdef DEB_OVER
_OVER:
#endif
		init();
		/* Timer installieren */
		counter=0;
		install();

		if(ap_type==AUTO)
		{
			Cconws("Installiert");
			Ptermres(_PgmSize,0);
		}
		else if(ap_type==APP)
		{
			form_alert(1,slip_alert);
			appl_exit();
			Ptermres(_PgmSize,0);
		}
		else do
		{
			evnt_mesag(pbuf);
			if(pbuf[0] == AC_OPEN)
				form_alert(1,slip_alert);
		}while (1);
	}
	else
	{
		/* DEBUG OVERWRITE */
#ifdef DEB_OVER
		cookie->val=(long)&cook;
		goto _OVER;
#endif
		
		if(ap_type==AUTO)
			Cconws("Fehler: Bereits installiert");
		else if(ap_type==APP)
			form_alert(1,slip_err_alert);
		else do
		{
			evnt_mesag(pbuf);
			if(pbuf[0] == AC_OPEN)
				form_alert(1,slip_err_alert);
		}while (1);
		r=1;
	}

	return(r);
}
/* -------------------------------------- */

/* Util for realloc replacement */
void block_copy(uchar *idst, uchar *isrc, long ilen)
{
	register long 	len=ilen;
	register uchar	*dst=idst, *src=isrc;
	
	while(len--)
		*dst++=*src++;
}

/* Utils to avoid odd address access by typecasts in
	 byte streams */
/* ------------------------------- */

int	get_int(uchar *c)
{
	int i;
	
	i=*c++; i<<=8; i+=*c;
	return(i);
}

uint get_uint(uchar *c)
{
	uint i;
	
	i=*c++; i<<=8; i+=*c;
	return(i);
}

ulong get_ulong(uchar *c)
{
	ulong l;
	
	l=*c++; l<<=8;
	l=*c++; l<<=8;
	l=*c++; l<<=8;
	l=*c;
	return(l);
}

void set_int(char *p, int i)
{
	*p++=(char)(i>>8);
	*p++=(char)(i & 255);
}

void uset_int(uchar *p, int i)
{
	*p++=(char)(i>>8);
	*p++=(char)(i & 255);
}

/*------------------------------- */

/* Utility for Debugging  */
long mstrlen(char *text)
{
	long l=0;
	while(text[l++]);
	return(l-1);
}

void Dftext(char *text)
{
	if(db_handle < 0) return;

	Fwrite(db_handle, mstrlen(text), text);
}

void Dfnumber(long number)
{
	char num[32];

	if(db_handle < 0) return;

	ltoa(number, num, 10);
	Fwrite(db_handle, mstrlen(num), num);
}

void Dfdump(uchar *buf, ulong len)
{
	int crcn=0, ch, cl;
	char	c[2];
	c[1]=0;
	
	if(db_handle < 0) return;
	
	while(len--)
	{
		cl=*buf++;
		ch=cl/16; cl-=ch*16;
		if(ch < 10) c[0]=ch+'0';
		else c[0]=ch+'A'-10;
		Dftext(c);
		if(cl < 10) c[0]=cl+'0';
		else c[0]=cl+'A'-10;
		Dftext(c);
		Dftext(" ");
		if(++crcn == 16)
		{
			crcn=0;
			Dftext("\r\n");
		}
	}
}


/* -------------------------------------- */

void code_name(char *ps,char *name)
{
    int i, len;
    len = (int) strlen(name);
    for (i=0; i < len; i++)
    {
        ps[i] = 255 ^name[i];
    }
    ps[len] = 0;
}

int checkser(char *sernum)
{
    long ser,ch;
    char s[7];
    int i;
    for(i=2;i<8;i++)
        s[i-2]=sernum[i];
    s[6]='\0';
    ser=atol(s); ch=sernum[9]-48;
    if(((ser&5)==ch)&&
        (strncmp(sernum,"31",2)==0)&&
        (sernum[8]=='0')&&
        (strcmp(sernum+2,"00000000")!=0))
        return(1);

    return(0); 
}

int check_reg(void)
{
	if(reg_active[strlen(reg_active)-1]!='n')
	{
		char	buf[32];
	
		code_name(buf, reg_name);
		strcpy(reg_name, buf);
		code_name(buf, reg_firma);
		strcpy(reg_firma, buf);
		
		code_name(buf, reg_serial);
		return(checkser(buf));
	}		

	/*	else */
	strcpy(reg_name, "BETAVERSION");
	strcpy(reg_firma, "");
	return(1);
}

/* -------------------------------------- */

/*
The following are recommended values for TOS:


            ----- Type-of-Service Value -----

Protocol           TOS Value

TELNET (1)         1000                 (minimize delay)

FTP
  Control          1000                 (minimize delay)
  Data (2)         0100                 (maximize throughput)

TFTP               1000                 (minimize delay)

SMTP (3)
  Command phase    1000                 (minimize delay)
  DATA phase       0100                 (maximize throughput)

Domain Name Service
  UDP Query        1000                 (minimize delay)
  TCP Query        0000
  Zone Transfer    0100                 (maximize throughput)

NNTP               0001                 (minimize monetary cost)

ICMP



Reynolds & Postel                                              [Page 65]

RFC 1700                    Assigned Numbers                October 1994


  Errors           0000
  Requests         0000 (4)
  Responses        <same as request> (4)

Any IGP            0010                 (maximize reliability)

EGP                0000

SNMP               0010                 (maximize reliability)

BOOTP              0000
*/