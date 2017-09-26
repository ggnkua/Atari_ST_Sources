/* UDP request */
/* Contact a server on a port and receive a request */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <sockinit.h>
#include <socket.h>
#include <sfcntl.h>
#include <types.h>
#include <sockios.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>
#include <atarierr.h>
#include <ext.h>

#define TOUT_SEK 4

/* Console output */
#define Con(a) Cconws(a)
#define crlf Con("\r\n")

void request(ulong ip, int port, char *msg);

void numout(int num)
{
	char nus[32];
	Con(itoa(num, nus, 10));
}

int msglen(char *msg)
{
	int l=0;
	while(msg[l++]);
	return(l-1);
}

void main(int argc, char *argv[])
{
	int			d;
	hostent	*he;
	servent	*se;
	
	d=sock_init();
	if(d < 0)
	{
		switch(d)
		{
			case SE_NINSTALL:
				Con("rudp: Sockets not installed.");crlf;
				Con("Put SOCKETS.PRG in the AUTO-folder.");crlf;
			break;
			case SE_NSUPP:
				Con("rudp: SOCKETS.PRG is too old.");crlf;
			break;
		}
		return;
	}
	
	/* Help needed? */
	if((argc!=4)||((argc>=2)&&(((char*)argv[0])[0]=='?')))
	{
		Con("UDP request v0.1 02.02.1997 Sven Kopacz");crlf;
		Con("usage:");crlf;
		Con("rudp <hostname> <service> <message>");crlf;
		Con("rudp will send <message> character to <hostname> on the");crlf;
		Con("port designated to <service> (see /etc/services) via UDP.");crlf;
		Con("Examples:");crlf;
		Con("<input>");crlf;
		Con("rudp ftp.uni-stuttgart.de echo WillItComeBack?");crlf;
		Con("<output>");crlf;
		Con("[ftp.uni-stuttgart.de=129.69.18.15]");crlf;
		Con("WillItComeBack?");crlf;

		return;
	}
	
	he=gethostbyname((char*)argv[1]);
	if(he==NULL)
	{
		Con("host ");
		Con((char*)argv[1]);
		Con(" was not found.");
		crlf;
		return;
	}

	if(!he->h_addr_list[0])
	{
		Con("host ");Con((char*)argv[1]);
		Con(" was not resolved to an IP address.");
		crlf;
		return;
	}
	
	/* number of port instead of service name? */
	if((d=atoi((char*)argv[2]))==0)
	{/* No, chech etc/services */
		se=getservbyname((char*)argv[2], "udp");
		if(se==NULL)
		{
			Con("service ");Con((char*)argv[2]);Con(" unknown.");
			crlf;
			return;
		}
		d=se->s_port;
	}
		
	Con("[");Con((char*)argv[1]);Con("=");
	Con(inet_ntoa(*(ulong*)(he->h_addr_list[0])));
	Con("]");crlf;
	request(*(ulong*)(he->h_addr_list[0]), d, (char*)argv[3]);
	crlf;
}

void request(ulong ip, int port, char *msg)
{
	sockaddr_in sad;
	int	s, ret;
	char	buf[501];
	fd_set	mask;
	timeval	tout;
	
	s=socket(AF_INET, SOCK_DGRAM, 0);

	if(s < 0)
	{
		Con("rudp: can\'t open socket.");crlf;
		return;
	}

	/* Send the message */
	sad.sin_port=port;
	sad.sin_addr=ip;
	ret=sendto(s, msg, msglen(msg), 0, &sad, (int)sizeof(sockaddr_in));
	if(ret < 0)
	{
		if(ret==ENHNDL)
			Con("rudp: internal error, no local ports available.");
		else if(ret==ENSMEM)
			Con("rudp: internal error, out of memory.");
		else /* Hmm? */
		{	Con("rudp: error sending message: "); numout(ret); }
		crlf;
		sclose(s);
		return;
	}
	
	/* Wait for TOUT_SEK seconds for reply */
	FD_ZERO(&mask);
	FD_SET(s, &mask);
	tout.tv_sec=TOUT_SEK;
	tout.tv_usec=0;

	ret=select(s+1, &mask, NULL, NULL, &tout);
	if(ret==0)
	{
		Con("rudp: no reply.");crlf;
		sclose(s);
		return;
	}

	sfcntl(s,F_SETFL,O_NDELAY);

	ret=(int)sread(s, buf, 500);
	if(ret < 0)
	{/* Error? What error?? */
		Con("rudp: error receiving message: ");numout(ret);crlf;
		sclose(s);
		return;
	}
	
	if(ret==0)
	{
		Con("rudp: received empty reply.");crlf;
		sclose(s);
		return;
	}
	
	/* Show message */
	do
	{
		buf[ret]=0;
		Con(buf);
		ret=(int)sread(s, buf, 500);
	}while(ret > 0);
	sclose(s);
}