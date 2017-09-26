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
#include "blip_cab.h"

#define TOUT_SEK 90
#define CONNECT_COUNT	200		/* Counts in 100ms for Connection-Timeout */
#define HEAD_BUF	1024			/* Buffer-size for HTTP-Header */


typedef struct
{
	ulong	nntp_ip;
	uint	nntp_port;
	char	*news_id;
	int		store_file; /* Gemdos-handle */
}NEWS_INFO;


int get_article(int s, int fh)
{/* s=socket, fh=dest file
		Receives and writes to fh until CR/LF/./CR/LF received
	*/
 	time_t	now;
	int			ret, a, crlf=0;
	char		buf[501];
	fd_set	mask;
	timeval	tout;

	browser->msg_status(STATUS_RECEIVING_DATA,-1);
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
			if(ret > 0) goto _news_incoming;
			
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
		
_news_incoming:
		now=time(NULL);

		if(ret==0)	continue;	/* Empty reply, continue waiting */

		/* Empfangenes speichern */
		Fwrite(fh, ret, buf);
		
		a=0;
		while(a < ret)
		{
			switch(buf[a++])
			{
				case 13:	/* CR */
					if(crlf==0) crlf=1;
					else if(crlf==3) crlf=4;
					else crlf=0;
				break;
				case 10:	/* LF */
					if(crlf==1) crlf=2;
					else if(crlf==4) return(0);	/* Done */
					else crlf=0;
				break;
				case '.':	/* Dot */
					if(crlf==2) crlf=3;
					else crlf=0;
				break;
				default:
					crlf=0;
				break;
			}
		}
	}while(1);

	shutdown(s,2);
	sclose(s);
	return(-1);
}

int get_news(NEWS_INFO *ninf)
{
	sockaddr_in sad;
	int	s, ret;

	s=socket(AF_INET, SOCK_STREAM, 0);

	if(s < 0) return(-1);

	/* connect to remote host */
	browser->msg_status(STATUS_CONNECTING_HOST,0);	sad.sin_family=AF_INET;
	sad.sin_port=ninf->nntp_port;
	sad.sin_addr=ninf->nntp_ip;
	ret=to_connect(s, &sad, (int)sizeof(sockaddr_in));
	if(ret < 0)
	{
		/* EADDRINUSE: ENSMEM: ENETDOWN: ETIMEDOUT: ECONNREFUSED: */
		sclose(s);
		return(ret);
	}
	
	/* Wait for OK response */
	if(get_reply(s)!=2){sclose(s); return(-1);} /* 200/201 expected */
	
	/* Request Article */
	if(send_string(s,"ARTICLE ",0)<0) return(-1);
	if(send_string(s,ninf->news_id,1)<0) return(-1);
	
	/* From now always return OK, since Error-LOGs are stored as news-file */
	if(get_article(s, ninf->store_file) < 0) return(0);
	if(send_string(s,"QUIT",1) < 0) return(0);
	get_reply(s);
	shutdown(s,2);
	sclose(s);
	return(0);
}


/* 
	Sichtbar
*/

long download_news(char *url, char *path)
{
	int						ret;
	USIS_REQUEST	ur;
	NEWS_INFO			ninf;
	char					news_id[128];
	
	/* Server von USIS */	
	ur.request=UR_NEWS_IP;
	if(usis_query(&ur)!=UA_FOUND) return(-1);
	ninf.nntp_ip=ur.ip;
	
	/* Port aus Module-Init */
	ninf.nntp_port=nntp_port;

	/* ID aus URL */
	strcpy(news_id, &(url[5]));	/* "nntp:" bergehen */
	if(strchr(news_id, '@')==NULL) return(-1);	/* Keine ID sondern Group */
	ninf.news_id=news_id;
	
	/* Ziel */
	ninf.store_file=(int)Fcreate(path, 0);
	if(ninf.store_file < 0)
		return(ninf.store_file);

	ret=get_news(&ninf);
	Fclose(ninf.store_file);
	return(ret);
}
