/* IDP-Server */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <aes.h>
#include <sockinit.h>
#include <socket.h>
#include <sockios.h>
#include <sfcntl.h>
#include <in.h>
#include <inet.h>
#include <types.h>
#include <netdb.h>
#include <atarierr.h>
#include <sockerr.h>
#include <ext.h>

int	sock;

int recv_msg(char *buf)
{
	int		ret, pnt;
	fd_set	mask;
	timeval	tout;

	FD_ZERO(&mask);
	FD_SET(sock, &mask);
	tout.tv_sec=0;
	tout.tv_usec=0;

	ret=select(sock+1, &mask, NULL, NULL, &tout);
	if(ret==0) return(0);

	ret=(int)sread(sock, buf, 500);
	if(ret < 0) return(-1);
	
	if(ret==0) return(0);
	
	pnt=ret;
	sfcntl(sock,F_SETFL,O_NDELAY);
	do
	{
		ret=(int)sread(sock, &(buf[pnt+1]), 500);
		if(ret > 0) pnt+=ret;
	}while((ret > 0) && (buf[pnt]!=13) && (buf[pnt]!=10) && (buf[pnt]));
	buf[pnt+1]=0;
	sfcntl(sock,F_SETFL,0);
	return(pnt);
}

void get_con(void)
{
	int		tc;
	char buf[500];
	int ret, len=(int)sizeof(sockaddr_in);
	sockaddr_in sa;
	
	sfcntl(sock,F_SETFL,O_NONBLOCK);
	ret=accept(sock, &sa, &len);
	sfcntl(sock,F_SETFL,0);
	
	if(ret<=0) return;
	
	/* close listen socket */
	sclose(sock);
	/* accepted connection now active socket */
	sock=ret;

	tc=0;
	do	/* wait for request */
	{	
		ret=recv_msg(buf);
		if(ret==-1) {shutdown(sock, 2); sclose(sock); sock=-1; return;}	
		if(ret==0) evnt_timer(100,0);
	}
	while((ret==0) && (tc < 10));
	if(ret==0) {shutdown(sock, 2); sclose(sock); sock=-1; return;}	
	
	while((buf[ret]==13)||(buf[ret]==10)) buf[ret--]=0;
	
	strcat(buf, " : USERID : OTHER : USER\r\n");
	swrite(sock, buf, (int)strlen(buf));
	shutdown(sock, 2);
	sclose(sock);
	sock=-1;
}

void sock_loop(void)
{	
	sockaddr_in sad;

	/* Socket aufmachen? */
	if(sock==-1)
	{
		sock=socket(AF_INET, SOCK_STREAM, 0);

		if(sock < 0)
		{	
			sock=-1;	
			return;
		}

		sad.sin_port=113;
		sad.sin_addr=gethostid();
		if(bind(sock, &sad, (int)sizeof(sockaddr_in))<0)
		{
			sclose(sock);
			sock=-1;
			return;
		}
		
		if(listen(sock, 1) < 0)
		{
			sclose(sock);
			sock=-1;
			return;
		}
		return;
	}

	/* Socket schon offen, Verbindung da? */
	get_con();
}

void main(void)
{
	int d, pbuf[8];

	appl_init();
	
	d=sock_init();
	if(d < 0)
	{
		switch(d)
		{
			case SE_NINSTALL:
				form_alert(1, "[3][Sockets not installed.|Put SOCKETS.PRG in the|AUTO-folder][Cancel]");
			break;
			case SE_NSUPP:
				form_alert(1, "[3][SOCKETS.PRG is too old.]");
			break;
		}
		return;
	}

	sock=-1;
	do
	{
		if(!appl_read(-1, 16, pbuf)) pbuf[0]=0;
		sock_loop();
		evnt_timer(100,0);
	}while(pbuf[0]!=AP_TERM);

	if(sock!=-1)
	{
		shutdown(sock, 2);
		sclose(sock);
	}
	
	appl_exit();
}


