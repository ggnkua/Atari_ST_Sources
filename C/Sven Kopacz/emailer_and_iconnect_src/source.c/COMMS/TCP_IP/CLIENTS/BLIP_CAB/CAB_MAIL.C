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
	ulong	smtp_ip;
	uint	smtp_port;
	char	*from;
	char	*to;
	char	*subject;
	char	*buf;
	long	len;
}MAIL_INFO;

int prepare(int s, char *out)
{/* Write to one block and send whenever full */
	#define SBUFSIZ 4096
	int			ret;
	static char block[SBUFSIZ];
	static long used=0;
	
	if(out==NULL) /* flush buffer */
	{
		if(used==0) return(0);
		ret=send_string(s, block, 0);
		/* Give CAB some time */
		if(browser->aes_events(100) == -1) /* User canceled */
			return(-1);

		return(ret);
	}
	if(used+strlen(out)+3 > SBUFSIZ)
	{/* Send and clear */
		if(send_string(s,block, 0)<0) return(-1);
		used=0;
		/* Give CAB some time */
		if(browser->aes_events(100) == -1) /* User canceled */
			return(-1);
	}

	if(used==0) block[0]=0;
	
	if(out[0]=='.')
	{	strcat(block,"."); ++used;}
	strcat(block,out);
	used+=strlen(out);
	strcat(block,"\r\n");
	used+=2;
	return(0);
}

int send_message(int s, MAIL_INFO *minf)
{
	register long lstart, lpos;
	register char	*tstr, *buf;
	time_t	tim;
	time(&tim);
	
	buf=minf->buf;

	browser->msg_status(STATUS_SENDING_REQUEST,0);
	if(send_string(s,"Date: ",0)<0)return(-1);
	tstr=ctime(&tim);
	/* Cut off traling \n */
	tstr[strlen(tstr)-1]=0;
	if(send_string(s,tstr,1)<0) return(-1);
	if(send_string(s,"From: ",0)<0)return(-1);
	if(send_string(s,minf->from,1)<0)return(-1);
	if(send_string(s,"Subject: ",0)<0)return(-1);
	if(send_string(s,minf->subject,1)<0)return(-1);
	if(send_string(s,"To: ",0)<0)return(-1);
	if(send_string(s,minf->to,1)<0)return(-1);
	if(send_string(s,"\r\n",0)<0)return(-1);
		
	lstart=lpos=0;
	while(lpos < minf->len)
	{
		if((buf[lpos]==13)||(buf[lpos]==10))
		{
			buf[lpos++]=0;
			if(prepare(s,(char*)&(buf[lstart]))<0) return(-1);
			while((lpos<minf->len)&&((buf[lpos]==13)||(buf[lpos]==10)))++lpos;
			lstart=lpos;
		}
		else
			buf[lpos++]&=127;
	}
	if(lstart < minf->len)
	/* Didn't stop with CR/LF */
	if(prepare(s,(char*)&(buf[lstart]))<0) return(-1);
	/* Flush buffer */
	if(prepare(s,NULL) < 0) return(-1);
	return(0);
}

int mailer(MAIL_INFO *minf)
{
	sockaddr_in sad;
	int	s, ret;

	s=socket(AF_INET, SOCK_STREAM, 0);

	if(s < 0) return(-1);

	/* connect to remote host */
	browser->msg_status(STATUS_CONNECTING_HOST,0);	sad.sin_family=AF_INET;
	sad.sin_port=minf->smtp_port;
	sad.sin_addr=minf->smtp_ip;
	ret=to_connect(s, &sad, (int)sizeof(sockaddr_in));
	if(ret < 0)
	{
		/*
		switch(ret)
		{
			case EADDRINUSE: Con("Connection in use."); break;
			case ENSMEM: Con("Insufficient memory.");break;
			case ENETDOWN: Con("No socket server active.");break;
			case ETIMEDOUT: Con("timeout");break;
			case ECONNREFUSED: Con("refused");break;
			default: Con("error ");numout(ret);Con(" occured.");
		}
		*/
		sclose(s);
		return(-1);
	}
	
	/* Wait for OK response */
	if(get_reply(s)!=2){sclose(s); return(-1);} /* 220 expected */
	
	/* Send the message */
	if(send_string(s,"MAIL FROM:",0)<0) return(-1);
	if(send_string(s,minf->from,1)<0) return(-1);
	if(get_reply(s)!=2){shutdown(s, 2);sclose(s); return(-1);} /* 250 */
	
	if(send_string(s,"RCPT TO:",0)<0) return(-1);
	if(send_string(s,minf->to,1)<0) return(-1);
	if(get_reply(s)!=2){shutdown(s, 2);sclose(s); return(-1);} /*250/51*/
	
	if(send_string(s,"DATA",1)<0) return(-1);
	if(get_reply(s)!=3){shutdown(s, 2);sclose(s); return(-1);} /* 354 */

	if(send_message(s,minf)<0){shutdown(s,2);sclose(s); return(-1);}
	
	if(send_string(s,"\r\n.\r\n",0)<0) return(-1);
	if(get_reply(s)!=2){shutdown(s, 2);sclose(s); return(-1);} /* 250 */

	if(send_string(s,"QUIT",1)<0) return(-1);
	get_reply(s);
	shutdown(s,2);
	sclose(s);
	return(0);
}


/* 
	Sichtbar
*/

long send_mail(char *url, char *subject, char *filename)
{/* Return 0=OK, -1=Fehler */
	int						fh;
	USIS_REQUEST	ur;
	MAIL_INFO			minf;
	static char		email_addr[65];

	/* Server von USIS */	
	ur.request=UR_SMTP_IP;
	if(usis_query(&ur)!=UA_FOUND) return(-1);
	minf.smtp_ip=ur.ip;
	
	/* Port aus Module-Init */
	minf.smtp_port=smtp_port;

	/* Absender (eigene eMail-Adresse) von USIS */	
	ur.request=UR_EMAIL_ADDR;
	ur.result=email_addr;
	if(usis_query(&ur)!=UA_FOUND) return(-1);
	minf.from=email_addr;

	/* Empf„nger aus URL */
	if((minf.to=strchr(url, ':'))==NULL) return(-1);
	++(minf.to);

	/* Subject und Datei von CAB */
	minf.subject=subject;	

	fh=(int)Fopen(filename, FO_READ);
	if(fh < 0) return(-1);
	minf.len=Fseek(0, fh, 2);
	Fseek(0, fh, 0);
	minf.buf=(char*)Malloc(minf.len+1);
	if(minf.buf==NULL)	{Fclose(fh); return(-1);}
	Fread(fh, minf.len, minf.buf);
	Fclose(fh);
	minf.buf[minf.len]=0;
	fh=mailer(&minf);
	
	Mfree(minf.buf);
	return(fh);
}