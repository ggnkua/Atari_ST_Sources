/* Finger */

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
#include <sockerr.h>
#include <ext.h>


/* Console output */
#define Con(a) Cconws(a)
#define crlf Con("\r\n")

int TOUT_SEK=30;


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

void help(void)
{
	Con("finger-client v0.1 11.02.1997 Sven Kopacz");crlf;
	Con("usage:");crlf;
	Con("finger [-? ][-tn ][-c ][-8 ][-l ][<user>][@]<host>{@<host>}");crlf;
	Con("  -?   show this help page and exit");crlf;
	Con("  -tn  set timeout for reply to n seconds (default=30)");crlf;
	Con("  -c   allow ascii control characters (<32) to be received");crlf;
	Con("       Note: TAB (Ascii 9) and CR/LF (13/10) are always allowed");crlf;
	Con("  -8   allow eight bit ascii characters (>126) to be received");crlf;
	Con("       if -c/-8 is not set, spaces are displayed instead");crlf;
	Con("  -l   long output, forces <host> to resolve mail aliases or");crlf;
	Con("       send further information");crlf;
	Con("<user> a username or nickname");crlf;
	Con("       if <user> is omitted, <host> will prompt all known");crlf;
	Con("       users, if this option is supported.");crlf;
	Con("<host> the host where <user> is registered");crlf;
	Con("       multiple hosts will forward the request as long as");crlf;
	Con("       every host supports this option.");crlf;
	crlf;
}

void masked_output(char *buf, int lo, int hi)
{
	long l=strlen(buf)-1, a;
	char	*conbuf=buf;

	for(a=0;a < l; ++a)
	{
		if((buf[a] < 32) &&(lo==0)&&(buf[a]!=13)&&(buf[a]!=10)&&(buf[a]!=9))
			buf[a]=32;
		if((buf[a] > 126) && (hi==0))
			buf[a]=32;
		if((buf[a]==13)||(buf[a]==10))
		{
			buf[a]=0;
			Con(conbuf);crlf;
			while((a < l)&&((buf[a]==0)||(buf[a]==13)||(buf[a]==10)))++a;
			conbuf=&(buf[a]);
		}
	}
	/* Message ended without CR/LF? */
	if((buf[l-1]) && (buf[l-1]!=13) && (buf[l-1]!=10))
		Con(conbuf);
}

int read_sock(int s, int lo, int hi)
{
	char buf[501];
	int	 ret, total=0;
	
	while(1)
	{
		ret=(int)sread(s, buf, 500);
		if(ret < 0)
		{
			if(total > 0) return(total);
			Con("error receiving message: ");numout(ret);crlf;
			return(ret);
		}
		
		if(ret==0) return(total);
	
		total+=ret;
		/* Show message */
		buf[ret]=0;
		masked_output(buf, lo, hi);
	}
}

void request(ulong ip, int port, char *msg, int lo, int hi)
{
	sockaddr_in sad;
	int	s, ret, total_read=0;
	fd_set	mask;
	timeval	tout;

	s=socket(AF_INET, SOCK_STREAM, 0);

	if(s < 0)
	{
		Con("can\'t open socket.\r\n");
		return;
	}

	/* connect to remote host */
	Con("[connecting...");
	sad.sin_family=AF_INET;
	sad.sin_port=port;
	sad.sin_addr=ip;
	ret=connect(s, &sad, (int)sizeof(sockaddr_in));
	if(ret < 0)
	{
		Con("not successfull]");crlf;
		switch(ret)
		{
			case EADDRINUSE: Con("Connection in use."); break;
			case ENSMEM: Con("Insufficient memory.");break;
			case ENETDOWN: Con("No socket server active.");break;
			case ETIMEDOUT: Con("timeout");break;
			case ECONNREFUSED: Con("refused");break;
			default: Con("error ");numout(ret);Con(" occured.");
		}
		crlf;
		sclose(s);
		return;
	}
	Con("ok]");crlf;
	/* Send the message */
	ret=swrite(s, msg, msglen(msg));
	if(ret < 0)
	{
		Con("error sending message: ");
		switch(ret)
		{
			case ENOTCONN: Con("connection broke down.");break;
			case EPIPE: Con("connection closing.");break;
			case ENSMEM: Con("insufficient memory.");break;
			default: numout(ret);
		}
		shutdown(s,2);
		sclose(s);
		return;
	}

	sfcntl(s,F_SETFL,O_NDELAY);

	/* Wait for TOUT_SEK seconds for reply until remote closes conn*/

	while(1)
	{
		FD_ZERO(&mask);
		FD_SET(s, &mask);
		tout.tv_sec=TOUT_SEK;
		tout.tv_usec=0;

		/* select will return with 0 immediatly, when remote closed conn */
		/* so there's no waiting after complete message arrived */
		ret=select(s+1, &mask, NULL, NULL, &tout);

		if(ret==0)	break;
			
		ret=read_sock(s, lo, hi);
		if(ret < 0) break;
		
		total_read+=ret;
	}

	if(total_read==0)
	{	Con("no reply.");crlf;}
	
	shutdown(s,2);
	sclose(s);
}

void finger(char *host, char *cmd, int lo, int hi, int verbose)
{
	hostent	*he;
	servent	*se;
	char		cpl_cmd[205]; /* 200+"/W "+CRLF=205 */
	
	if(strlen(cmd) > 200)
	{
		Con("Commandline too long");crlf;
		return;
	}
	
	/* Make complete commandline */
	cpl_cmd[0]=0;
	if(verbose)
		strcat(cpl_cmd, "/W ");
	if(cmd!=NULL)
		strcat(cpl_cmd, cmd);
	strcat(cpl_cmd, "\r\n");

	/* Get destination IP */	
	he=gethostbyname(host);
	if(he==NULL)
	{
		Con("host ");
		Con(host);
		Con(" was not found.");
		crlf;
		return;
	}

	if(!he->h_addr_list[0])
	{
		Con("host ");Con(host);
		Con(" was not resolved to an IP address.");
		crlf;
		return;
	}

	/* Get destination port */	
	se=getservbyname("finger", "tcp");
	if(se==NULL)
	{
		Con("service \'finger\' unknown.");
		crlf;
		return;
	}
		
	Con("[");Con(host);Con("=");
	Con(inet_ntoa(*(ulong*)(he->h_addr_list[0])));
	Con("]");crlf;
	request(*(ulong*)(he->h_addr_list[0]), se->s_port, cpl_cmd, lo, hi);
	crlf;
}

void main(int argc, char *argv[])
{
	int			d;
	int			low_ascii=0, hi_ascii=0, verbose=0;
	char		*host=NULL, *command=NULL;
	
	d=sock_init();
	if(d < 0)
	{
		switch(d)
		{
			case SE_NINSTALL:
				Con("rtcp: Sockets not installed.\r\n");
				Con("Put SOCKETS.PRG in the AUTO-folder.\r\n");
			break;
			case SE_NSUPP:
				Con("rtcp: SOCKETS.PRG is too old.\r\n");
			break;
		}
		return;
	}

	while(argc-- > 1)
	{
		if( ((char*)argv[argc])[0]=='-' )
		{/* Options */
			if( (((char*)argv[argc])[1] & 95)=='C')
				low_ascii=1;
			else if( ((char*)argv[argc])[1]=='8')
				hi_ascii=1;
			else if( (((char*)argv[argc])[1] & 95)=='L')
				verbose=1;
			else if( (((char*)argv[argc])[1] & 95)=='T')
			{
				if((TOUT_SEK=atoi(&(((char*)argv[argc])[2])))==0)
				{
					Con("illegal timeout, using default");crlf;
					TOUT_SEK=20;
				}
			}
			else
			{
				help();
				return;
			}
		}
		else
		{/* User/Host */
			if((host!=NULL)||(command!=NULL))
			{ help(); return;}
			command=(char*)argv[argc];
			host=strrchr(command, '\@');
			if(host==NULL) /* only host */
			{host=command; command=NULL;}
			else if(host==command) /* first character ist '@', equals host only */
			{++host; command=NULL;}
			else /* host points at @, separating cmd from host to connect */
				*host++=0;
		}
	}
	/* Help needed? */
	if(host==NULL)
	{
		help(); return;
	}

	finger(host, command, low_ascii, hi_ascii, verbose);	
}
