/* UDP-Test client */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <sockinit.h>
#include <socket.h>
#include <sockios.h>
#include <sfcntl.h>
#include <types.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>
#include <atarierr.h>
#include <sockerr.h>
#include <ext.h>

/* Console output */
#define Con(a) Cconws(a)
/* Carriage Return+New Line on Console */
#define crlf Con("\r\n")

/* program info */
#define prg_info	Con("UDP interactive, v0.1 05.02.1997 Sven Kopacz");crlf
/* Prompt */
#define prompt Con("udp>")

int	sock, auto_rcv=-1;

ulong resolve(char *name);
int		service(char *name);

void numout(long num)
{
	char nus[32];
	Con(ltoa(num, nus, 10));
}

void help(void)
{
	Con("? - this list of commands");crlf;
	Con("l - show local parameters");crlf;
	Con("p <service> - set local port to <service>");crlf;
	Con("c <host> <service> - connect (virtualy) to <host> on <service>");crlf;
	Con("d - disconnect");crlf;
	Con("w <message> - write <message> to connected port");crlf;
	Con("s <host> <service> <message> - send <message> to <host> on <service>");crlf;
	Con("        Note: on \'w\' and \'s\' a cr/lf will be added to the");crlf;
	Con("        <message>.");crlf;
	Con("r [n] - receive message, timeout n seconds");crlf;
	Con("        If n is 0 or omitted, r returns immediately");crlf;
	Con("a <n> - auto-receive after send/write. <n> is the timeout in");crlf;
	Con("        seconds or omitted to turn Auto-Receive off.");crlf;
	Con("v <host> - resolve <host>\'s IP address");crlf;
	Con("q - quit");crlf;crlf;
	Con("If the local port is connected to a destination port,");crlf;
	Con("\'s\' will return an error if the destination address");crlf;
	Con("is different from the connected address and \'r\' will");crlf;
	Con("only accept messages from the destination port.");crlf;
	Con("If the local port is not connected, you must use \'s\' to");crlf;
	Con("send messages. \'r\' will accept any data designated to the");crlf;
	Con("local port.");
	crlf;
}

void show_local(void)
{
	sockaddr_in	sa;
	int					len=(int)sizeof(sockaddr_in), err;
	
	err=getsockname(sock, &sa, &len);
	if(err!=E_OK)
	{
		Con("error requesting local parameters: ");
		numout(err);
		crlf;
		return;
	}
	Con("local IP: ");
	Con(inet_ntoa(sa.sin_addr)); crlf;
	Con("local port: ");
	numout(sa.sin_port);
	crlf;
	
	err=getpeername(sock, &sa, &len);
	if(err!=E_OK)
	{
		if(err==ENOTCONN)
			Con("not connected");
		else
		{
			Con("error requesting connected port: ");
			numout(err);
		}
		crlf;
		return;
	}
	Con("virtualiy connected to: ");
	Con(inet_ntoa(sa.sin_addr)); crlf;
	Con(" on port ");
	numout(sa.sin_port);
	crlf;
}

void set_port(char *name)
{
	sockaddr_in sad;
	int err;
	
	sad.sin_port=service(name);
	if(sad.sin_port<=0)
	{
		Con("unknown service ");Con(name);crlf;
		return;
	}
	sad.sin_addr=gethostid();
	err=bind(sock, &sad, (int)sizeof(sockaddr_in));
	if(err < 0)
	{
		Con("error setting local port: ");
		if(err==EINVAL)
			Con("local port already assigned.");
		else if(err==EADDRINUSE)
			Con("local port already in use.");
		else if(err==ENSMEM)
			Con("insufficient memory.");
		else if(err==ENHNDL)
			Con("UDP is out of ports.");
		else
			numout(err);
		crlf;
		return;
	}
	Con("local port set to ");
	Con(name);
	crlf;
}

void connect_to(char *dest)
{
	sockaddr_in sad;
	int 				err;
	char				*dport, *dip=dest;
	
	while(*dest && (*dest!=' '))++dest;
	if(*dest==0)
	{
		Con("missing destination port.");crlf;
		return;
	}
	dport=dest+1;
	*dest=0;
	sad.sin_addr=resolve(dip);
	sad.sin_port=service(dport);
	if(sad.sin_addr==(unsigned long)-1)
	{/* Error output by resolver */
		return;
	}
	if(sad.sin_port <=0)
	{
		Con("illegal destination port");crlf;
		return;
	}

	err=connect(sock, &sad, (int)sizeof(sockaddr_in));
	if(err < 0)
	{/* error? */
		Con("error connecting: ");
		numout(err);
		crlf;
		return;
	}
	Con("virtualy connected to ");
	Con(dip);
	Con(" on port ");
	Con(dport);
	crlf;
}

void disconnect(void)
{
	int err;
	
	err=connect(sock, NULL, (int)sizeof(sockaddr_in));
	if(err==E_OK)
	{
		Con("disconnected.");crlf;
		return;
	}
	Con("error disconnecting: ");
	numout(err);
	crlf;
}

void write_msg(char *msg)
{
	int err;
	
	err=swrite(sock, msg, (int)strlen(msg));
	if(err >= 0)
	{
		numout(err);
		Con(" bytes written."); crlf;
		return;
	}
	Con("error writing message: ");
	if(err==EDESTADDRREQ)
		Con("destination address required (use \'c\' or \'s\')");
	else if(err==ENHNDL)
		Con("no local portnumbers left.");
	else if(err==ENSMEM)
		Con("insufficient memory.");
	else
		numout(err);
	crlf;
	return;
}

void send_msg_to(char *dest)
{
	sockaddr_in sad;
	int 				err;
	char				*dip=dest, *dport, *msg;
	
	while(*dest && (*dest!=' '))++dest;
	if(*dest==0)
	{
		Con("missing destination port.");crlf;
		return;
	}
	*dest++=0;
	dport=dest;
	
	while(*dest && (*dest!=' '))++dest;
	if(*dest==0)
	{
		Con("missing message.");crlf;
		return;
	}
	msg=dest+1;
	*dest=0;

	sad.sin_addr=resolve(dip);
	sad.sin_port=service(dport);

	if(sad.sin_addr==(unsigned long)-1)
	{/* Error output by resolver */
		return;
	}
	if(sad.sin_port <=0)
	{
		Con("illegal destination port");crlf;
		return;
	}

	err=sendto(sock, msg, (int)strlen(msg), 0, &sad, (int)sizeof(sockaddr_in));
	if(err < 0)
	{
		Con("error sending: ");
		if(err==EISCONN)
		{
			Con("local port is already connected");
			crlf;
			Con("use \'d\' to disconnect");
		}
		else if(err==ENHNDL)
			Con("no local portnumbers left");
		else if(err==ENSMEM)
			Con("insufficient memory");
		else
			numout(err);
		crlf;
		return;
	}
	
	numout(err);
	Con(" bytes sent.");
	crlf;
	return;
}

void recv_msg(int tout_sec)
{
	int		ret;
	char	buf[501];
	fd_set	mask;
	timeval	tout;

	/* Wait for tout seconds for reply */
	FD_ZERO(&mask);
	FD_SET(sock, &mask);
	tout.tv_sec=tout_sec;
	tout.tv_usec=0;

	ret=select(sock+1, &mask, NULL, NULL, &tout);
	if(ret==0)
	{
		Con("nothing received.");crlf;
		return;
	}

	ret=(int)sread(sock, buf, 500);
	if(ret < 0)
	{/* Error? What error?? */
		Con("error receiving message: ");
		numout(ret);
		crlf;
		return;
	}
	
	if(ret==0)
	{
		Con("nothing received.");crlf;
		return;
	}
	
	/* Read complete message */
	sfcntl(sock,F_SETFL,O_NDELAY);
	do
	{
		buf[ret]=0;
		Con(buf);
		ret=(int)sread(sock, buf, 500);
	}while(ret > 0);
	sfcntl(sock,F_SETFL,0);
}

void input(void)
{
	char entry[260], cmd;
	int	param;
	
	do
	{
		prompt;
		entry[0]=255; /* 2 struct bytes, 255 user, 2 my cr/fl, 1 0-term = 260 */
		do
		{
			Cconrs((LINE*)entry);
		}while(!entry[1]);
		crlf;
		entry[entry[1]+2]=0;
		strcpy(entry, &entry[2]);
		
		param=-1;
		if(strlen(entry) > 2)
			param=atoi(&(entry[2]));
				
		cmd=entry[0] & 95;
		if(strlen(entry)==0) continue;
		
		switch(cmd)
		{
			case 31 :	help(); break;	/* '?' & 95=31 */
			case 'L': show_local(); break;
			case 'P': 
				if(strlen(entry) < 3)
				{Con("service required.");crlf;break;}
				set_port(&(entry[2]));
			break;
			case 'C': 
				if(strlen(entry) < 3)
				{Con("destination required.");crlf;break;}
				connect_to(&(entry[2])); 
			break;
			case 'D': disconnect(); break;
			case 'W':
				if(strlen(entry) < 3)
				{Con("message required.");crlf;break;}
				strcat(entry, "\r\n");
				write_msg(&(entry[2]));
				if(auto_rcv > -1)
					recv_msg(auto_rcv);
			break;
			case 'S': 
				if(strlen(entry) < 3)
				{Con("destination & message required.");crlf;break;}
				strcat(entry, "\r\n");
				send_msg_to(&(entry[2])); 
				if(auto_rcv > -1)
					recv_msg(auto_rcv);
			break;
			case 'R': 
				if(param > -1)
				{	recv_msg(param); break;}
				recv_msg(0);
			break;
			case 'A':
				auto_rcv=param;
				if(auto_rcv <0)
					Con("auto-receive off.");
				else
				{	Con("auto-receive on, timeout ");numout(auto_rcv);Con(" seconds.");}
				crlf;
			break;
			case 'V': resolve(&(entry[2])); break;
			case 'Q': break;
			default: Con("unknown command"); break;
		}
		crlf;
	}
	while(cmd!='Q');
}

void main(int argc, char *argv[])
{
	int d;

	prg_info;
	
	d=sock_init();
	if(d < 0)
	{
		switch(d)
		{
			case SE_NINSTALL:
				Con("Sockets not installed.");crlf;
				Con("Put SOCKETS.PRG in the AUTO-folder.");crlf;
			break;
			case SE_NSUPP:
				Con("SOCKETS.PRG is too old.");crlf;
			break;
		}
		return;
	}

	sock=socket(AF_INET, SOCK_DGRAM, 0);
	if(sock < 0)
	{
		Con("error creating socket: ");
		if(sock==ENSMEM)
			Con("no memory");
		else
			numout(sock);
		crlf;
		return;
	}
	
	/* Help needed? */
	if((argc>=2)&&(((char*)argv[0])[0]=='?'))
	{
		Con("usage:");crlf;
		Con("udp_cli");crlf;
		Con("A prompt will appear, use the following commands:");crlf;
		help();
		return;
	}

	input();
	sclose(sock);
}

/* ************* internal ***************** */

ulong resolve(char *name)
{		
	hostent	*he;

	he=gethostbyname(name);
	if(he)
	{
		if(!he->h_addr_list[0])
		{
			Con("host \'");Con(name);
			Con("\' was not resolved to an IP address.");
			crlf;
			return((ulong)-1);
		}
		else	
		{
			Con("IP: ");
			Con(inet_ntoa(*(ulong*)(he->h_addr_list[0]))); 
			crlf;
			return(*(ulong*)(he->h_addr_list[0]));
		}
	}

	Con("host \'");Con(name);
	Con("\' was not found.");
	crlf;
	return((ulong)-1);
}

int service(char *name)
{
	servent	*se;
	int			d;
	
	/* number of port instead of service name? */
	if((d=atoi(name))==0)
	{/* No, check etc/services */
		se=getservbyname(name, "tcp");
		if(se==NULL)
			return(-1);
		d=se->s_port;
	}
	return(d);
}
