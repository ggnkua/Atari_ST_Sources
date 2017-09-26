#include <netdb.h>
#include "tcp.h"

#include <ec_gem.h>
#include <hsmod.h>
#include <sockinit.h>
#include <socket.h>
#include <sockios.h>
#include <sfcntl.h>
#include <types.h>
#include <in.h>
#include <inet.h>

#include "client.h"

#define BUFSIZE 200

int cx, cy, ok, sx, sy, sw, sh, sock=-1, sock2=-1;
char	*line[BUFSIZE], path[128];
char *statx[]=
{
"CLOSED     ",
"LISTEN     ",
"SYNSENT    ",
"SYNRCVD    ",
"ESTABLISHED",
"FINWAIT1   ",
"FINWAIT2   ",
"CLOSEWAIT  ",
"LASTACK    ",
"CLOSING    ",
"TIMEWAIT   "
};

WINDOW	win, wdial;
DINFO		ddial;
OBJECT	*odial;

int	mode=0;

void quit(WINDOW *win);
int init(void);
void zock(void);

void main(void)
{
	e_start_as(ACC|PRG,"Client");
	
	if(ap_type & (ACC|PRG))
	{
		wind_get(0,WF_WORKXYWH,&sx,&sy,&sw,&sh);
		if(init())
			zock();
	}
	
	e_quit();
}

ulong w_ip(uchar i1, uchar i2, uchar i3, uchar i4)
{
	ulong ip;
	
	ip=((ulong)i1<<24)+((ulong)i2<<16)+((ulong)i3<<8)+(ulong)i4;
	return(ip);
}
ulong calc_ip(int ob)
{
	char	n[4];
	uchar i1, i2, i3, i4;
	ulong ip;

	n[3]=0;
	strncpy(n, odial[ob].ob_spec.tedinfo->te_ptext, 3);
	i1=(uchar)atoi(n);
	strncpy(n, &(odial[ob].ob_spec.tedinfo->te_ptext[3]), 3);
	i2=(uchar)atoi(n);
	strncpy(n, &(odial[ob].ob_spec.tedinfo->te_ptext[6]), 3);
	i3=(uchar)atoi(n);
	strncpy(n, &(odial[ob].ob_spec.tedinfo->te_ptext[9]), 3);
	i4=(uchar)atoi(n);
	ip=((ulong)i1<<24)+((ulong)i2<<16)+((ulong)i3<<8)+(ulong)i4;
	return(ip);
}


void zock(void)
{
	int		dum, evnt;
	int		ostate=-1;
	char	*cp, buf[1024];
	sockaddr_in	ad;
  fd_set  rfds;
	timeval tv;
	
	ok=1;
	while(ok)
	{
		w_dtimevent(&evnt, &dum, &dum, &dum, &dum, 100,0);
		if(evnt & MU_TIMER)
		{
			if(mode==1) /* Listen */
			{
				sock=accept(sock2, &ad, &dum);
				if(sock > -1) mode=2;
			}
			if(sock > -1)
			{
				if(mode==4)
				{/*DGRAM*/
					if(ostate==-1)
					{
						ostate=1;
						strcpy(odial[STATUS].ob_spec.tedinfo->te_ptext, "DGRAM");
						w_objc_draw(&wdial, STATUS, 2, sx ,sy,sw, sh);
					}
				}
				else
				{
					dum=status(sock,NULL);
					if((dum > -1 && dum < 11) && (dum != ostate))
					{
						ostate=dum;
						strcpy(odial[STATUS].ob_spec.tedinfo->te_ptext, statx[dum]);
						w_objc_draw(&wdial, STATUS, 2, sx ,sy,sw, sh);
					}
				}
	      FD_ZERO(&rfds);
  	    FD_SET(sock,&rfds);
	      tv.tv_sec=0;
 	     tv.tv_usec=0;
  	    dum=select(sock+1, &rfds, NULL, NULL, &tv);
  	    if(dum > 0)
					dum=(int)recv(sock, buf, 1024, 0);
				else
					dum=0;
				if(dum > 0)
				{
					cp=buf;
					strncpy(odial[CRMSG].ob_spec.tedinfo->te_ptext, cp, 40);
					if(dum > 40)
					{
						(odial[CRMSG].ob_spec.tedinfo->te_ptext)[40]=0;
						cp+=40;
						dum-=40;
						strncpy(odial[CRMSG2].ob_spec.tedinfo->te_ptext, cp, 40);
						if(dum > 40)
						{
							(odial[CRMSG2].ob_spec.tedinfo->te_ptext)[40]=0;
							cp+=40;
							dum-=40;
							strncpy(odial[CRMSG3].ob_spec.tedinfo->te_ptext, cp, 40);
							(odial[CRMSG3].ob_spec.tedinfo->te_ptext)[40]=0;
						}
						else
							(odial[CRMSG3].ob_spec.tedinfo->te_ptext)[0]=0;
					}
					else
						(odial[CRMSG2].ob_spec.tedinfo->te_ptext)[0]=0;
					s_redraw(&wdial);
				}
			}
		}
	}
	shutdown(sock2, 2);
	if(mode < 4)
	{/*STREAM*/
		do
		{
			w_dtimevent(&evnt, &dum, &dum, &dum, &dum, 100,0);
			dum=status(sock2,NULL);
			if(dum > -1 && dum < 11)
			{
				strcpy(odial[STATUS].ob_spec.tedinfo->te_ptext, statx[dum]);
				w_objc_draw(&wdial, STATUS, 2, sx ,sy,sw, sh);
			}
		}while((dum > -1) && (dum != TCPS_CLOSED));
	}
	sclose(sock2);
	w_kill(&wdial);
}

void lisn(void)
{
	sockaddr_in sad;

	sock2=sock=socket(AF_INET, SOCK_STREAM, 0);

	if(sock < 0)
	{
		form_alert(1,"[3][Can't open Socket!][Cancel]");
		return;
	}

	sfcntl(sock, F_SETFL, O_NDELAY);
	sad.sin_port=atoi(odial[CLOCAL].ob_spec.tedinfo->te_ptext);
	sad.sin_addr=gethostid();
	bind(sock, &sad, (int)sizeof(sockaddr_in));
	listen(sock, 1);
	mode=1;
	odial[CONNECT].ob_flags&=(~DEFAULT);
	odial[SEND].ob_flags|=DEFAULT;
	odial[CONNECT].ob_state |= DISABLED;
	odial[BIND].ob_state |= DISABLED;
	odial[LISTEN].ob_state |= DISABLED;	
	s_redraw(&wdial);
}

void mbind(void)
{
	sockaddr_in sad;
	int	ret;
	
	sock2=sock=socket(AF_INET, SOCK_DGRAM, 0);

	if(sock < 0)
	{
		form_alert(1,"[3][Can't open Socket!][Cancel]");
		return;
	}

/*	sfcntl(sock, F_SETFL, O_NDELAY);*/
	sad.sin_port=atoi(odial[CLOCAL].ob_spec.tedinfo->te_ptext);
	sad.sin_addr=gethostid();
	ret=bind(sock, &sad, (int)sizeof(sockaddr_in));
	if(ret < 0)
	{
		close(sock);
		return;
	}
	
	mode=4;
	odial[CONNECT].ob_flags&=(~DEFAULT);
	odial[SEND].ob_flags|=DEFAULT;
	odial[BIND].ob_state |= DISABLED;
	odial[LISTEN].ob_state |= DISABLED;	
	s_redraw(&wdial);
}

void conn(void)
{
	sockaddr_in sad;

	if(mode != 4)
	{
		sock2=sock=socket(AF_INET, SOCK_STREAM, 0);
	
		if(sock < 0)
		{
			form_alert(1,"[3][Can't open Socket!][Cancel]");
			return;
		}
	
/*		sfcntl(sock, F_SETFL, O_NDELAY);*/
		sad.sin_port=atoi(odial[CLOCAL].ob_spec.tedinfo->te_ptext);
		sad.sin_addr=gethostid();
		bind(sock, &sad, (int)sizeof(sockaddr_in));
		mode=3;
	}
	
	sad.sin_port=atoi(odial[CPORT].ob_spec.tedinfo->te_ptext);
	sad.sin_addr=calc_ip(CIP);
	connect(sock, &sad, (int)sizeof(sockaddr_in));

	odial[CONNECT].ob_flags&=(~DEFAULT);
	odial[SEND].ob_flags|=DEFAULT;
	odial[CONNECT].ob_state |= DISABLED;
	odial[BIND].ob_state |= DISABLED;
	odial[LISTEN].ob_state |= DISABLED;	
	s_redraw(&wdial);
}
void snd(void)
{
	char sst[100];
	
	strcpy(sst, odial[CMSG].ob_spec.tedinfo->te_ptext);
	strcat(sst, "\r\n");
	send(sock, sst,(int)strlen(sst), 0);
}

void clse(void)
{
	shutdown(sock, 2);
	odial[CONNECT].ob_flags|=DEFAULT;
	odial[SEND].ob_flags&=(~DEFAULT);
	s_redraw(&wdial);
}

void abrt(void)
{
	sclose(sock);
}

void do_dial(int ob)
{
	switch(ob)
	{
		case LISTEN:
			w_unsel(&wdial, ob);
			lisn();
		break;
		case BIND:
			w_unsel(&wdial, ob);
			mbind();
		break;
		case CONNECT:
			w_unsel(&wdial, ob);
			conn();
		break;
		case SEND:
			w_unsel(&wdial, ob);
			snd();
		break;
		case CCLOSE:
			w_unsel(&wdial, ob);
			clse();
		break;
		case QUIT:
			abrt();
			ok=0;
		break;
	}
}

int init(void)
{
	if(sock_init() < 0)
	{
		form_alert(1,"[3][Slip not installed/up.][Cancel]");
		return(0);
	}
	rsrc_load("CLIENT.RSC");
	rsrc_gaddr(0,DIAL,&odial);
	gethostname(odial[LIP].ob_spec.tedinfo->te_ptext, 16);
	odial[CIP].ob_spec.tedinfo->te_ptext[0]=0;
	odial[CPORT].ob_spec.tedinfo->te_ptext[0]=0;
	odial[CLOCAL].ob_spec.tedinfo->te_ptext[0]=0;
	odial[CMSG].ob_spec.tedinfo->te_ptext[0]=0;
	odial[CRMSG].ob_spec.tedinfo->te_ptext[0]=0;
	odial[CRMSG2].ob_spec.tedinfo->te_ptext[0]=0;
	odial[CRMSG3].ob_spec.tedinfo->te_ptext[0]=0;
	odial[CONNECT].ob_flags|=DEFAULT;
	strcpy(odial[STATUS].ob_spec.tedinfo->te_ptext, "00");
	ddial.tree=odial;
	ddial.support=0;
	ddial.dservice=do_dial;
	ddial.osmax=0;
	ddial.odmax=8;
	w_dinit(&wdial);
	wdial.dinfo=&ddial;
	w_dial(&wdial, D_CENTER);
	ddial.dedit=CLOCAL;
	w_open(&wdial);
	return(1);
}
