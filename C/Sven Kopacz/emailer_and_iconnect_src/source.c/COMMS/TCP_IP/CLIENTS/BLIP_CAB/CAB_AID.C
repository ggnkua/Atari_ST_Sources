#include "module.h"#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <time.h>
#include <sockinit.h>
#include <socket.h>
#include <sfcntl.h>
#include <types.h>
#include <sockios.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>
#include <atarierr.h>
#include <sockerr.h>
#include <ext.h>
#include <url_aid.h>
#include <usis.h>
#include <rsdaemon.h>
#include "blip_cab.h"

#define TOUT_SEK 90
#define CONNECT_COUNT	200		/* Counts in 100ms for Connection-Timeout */
#define HEAD_BUF	1024			/* Buffer-size for HTTP-Header */

long lmsglen(char *msg)
{
	long l=0;
	while(msg[l++]);
	return(l-1);
}

int g_appl_find(char *name)
{
	browser->aes_control[0]=13;
	browser->aes_control[1]=0;
	browser->aes_control[2]=1;
	browser->aes_control[3]=1;
	browser->aes_control[4]=0;
	browser->aes_addrin[0]=(long)name;
	browser->aes_crystal();
	return(browser->aes_intout[0]);
}

void g_appl_write(int ap, int len, int *buf)
{
	browser->aes_control[0]=12;
	browser->aes_control[1]=2;
	browser->aes_control[2]=1;
	browser->aes_control[3]=1;
	browser->aes_control[4]=0;
	browser->aes_intin[0]=ap;
	browser->aes_intin[1]=len;
	browser->aes_addrin[0]=(long)buf;
	browser->aes_crystal();
	return;
}

ulong norm_gethostbyname(char *c)
{
	hostent				*he;

	he=gethostbyname(c);
	if(he==NULL)
		return(0);	/* Host not found */

	if(!he->h_addr_list[0])
		return(0);	/* Host found, but no IP-Adress given */
	
	return(*(ulong*)(he->h_addr_list[0]));
}

ulong my_gethostbyname(char *c)
{
	static int	req_id=0;
	int		pbuf[8], *mbuf, rsd_id;
	long	res;
	
	rsd_id=g_appl_find("RSDAEMON");
	if(rsd_id < 0)
		return(norm_gethostbyname(c));
	
	pbuf[0]=RSDAEMON_MSG;
	pbuf[1]=browser->aes_global[2];
	pbuf[2]=0;
	pbuf[3]=RSD_REQUEST_IP;
	pbuf[4]=++req_id;
	*(char**)(&(pbuf[5]))=c;
	g_appl_write(rsd_id, 16, pbuf);
	do
	{
		res=browser->aes_events(20);
		if(res == -1) return(0);
		if(res)
		{
			mbuf=(int*)res;
			if(mbuf[0]==RSDAEMON_MSG)
			{
				if((mbuf[3]==RSD_IP_UNKNOWN) && (mbuf[4]==req_id))
					return(0);
				if((mbuf[3]==RSD_IP_FOUND) && (mbuf[4]==req_id))
					return(*(long*)(&(mbuf[5])));
			}
			res=0;
		}
	}while(1);
}

int send_string(int s, char *msg, int cr)
{
	int ret;
	long msglength=lmsglen(msg);
	int	 wblock=10000;
	
	browser->msg_status(STATUS_SENDING_REQUEST,0);
	while(msglength)
	{	
		if(msglength < wblock)
			wblock=(int)msglength;
		msglength-=wblock;
		ret=swrite(s, msg, wblock);
		msg+=wblock;
		if(ret < 0)
		{/*
			switch(ret)
			{
				case ENOTCONN: Con("connection broke down.");break;
				case EPIPE: Con("connection closing.");break;
				case ENSMEM: Con("insufficient memory.");break;
				default: numout(ret);
			}
			*/
			shutdown(s,2);
			sclose(s);
			return(-1);
		}
	}
	
	if(cr)
	{
		ret=swrite(s, "\r\n", 2);
		if(ret < 0)
		{/*
			switch(ret)
			{
				case ENOTCONN: Con("connection broke down.");break;
				case EPIPE: Con("connection closing.");break;
				case ENSMEM: Con("insufficient memory.");break;
				default: numout(ret);
			}
			*/
			shutdown(s,2);
			sclose(s);
			return(-1);
		}
	}
	return(0);
}

int get_reply(int s)
{/* s=socket, Return class of reply, e.g. 250=class 2 */
 /* Receives until a line starting with a 3-digit-number and
 		ending with CR/LF is received */
 	time_t	now;
	int			ret, a, line_pos=0;
	char		buf[501], act_line[501];
	fd_set	mask;
	timeval	tout;

	browser->msg_status(STATUS_WAITING_RESPONSE,0);
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
			if(ret < 0)	/* Foreign closed, error */
				break;
			/* Maybe a segment just arrived between select and sread */
			if(ret > 0) goto _mail_incoming;
			
			if(time(NULL)-now < TOUT_SEK)
			{/* Give CAB some time */
				if(browser->aes_events(100) == -1) /* User canceled */
					break;

				continue;
			}
			break;	/* Timeout */
		}

		/* Incoming data, reset timeout */
		
		ret=(int)sread(s, buf, 500);
		if(ret < 0)	/* Foreign closed, error */
			break;
		
_mail_incoming:
		now=time(NULL);

		if(ret==0)	continue;	/* Empty reply, continue waiting */

		a=0;
		while(a < ret)
		{
			act_line[line_pos]=buf[a++];
			if((act_line[line_pos]==13) || (act_line[line_pos]==10))
			{/* Line ends */
				if(act_line[3]==' ')	/* Last line received */
					return(atoi(act_line)/100);

				line_pos=0;	/* else reset line-buffer */
			}
			else
				++line_pos;
		}
		
	}while(1);

	shutdown(s,2);
	sclose(s);
	return(-1);
}

int to_connect(int s, const void *addr, int addrlen)
{
	int			ret, to_count=CONNECT_COUNT;
	fd_set	mask;
	timeval	tout;

	ret=connect(s, addr, addrlen);
	if(ret != EINPROGRESS)
		return(ret);
	
	FD_ZERO(&mask);
	FD_SET(s, &mask);
	tout.tv_sec=0;
	tout.tv_usec=0;

	do
	{
		ret=select(s+1, NULL, &mask, NULL, &tout);
		if(ret==1) return(E_OK);
		if(browser->aes_events(100) == -1) return(-1); /* User canceled */
	}while(to_count--);

	shutdown(s,2);
	return(ETIMEDOUT);
}

