/* TCP-Test client */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
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

/* Console output */
#define Con(a) Cconws(a)
/* Carriage Return+New Line on Console */
#define crlf Con("\r\n")

/* program info */
#define prg_info	Con("TCP interactive client, v0.1 05.02.1997 Sven Kopacz");crlf
/* Prompt */
#define prompt Con("tcp>")

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
	Con("i - listen mode");crlf;
	Con("g - get incoming connection from listening");crlf;
	Con("c <host> <service> - connect to <host> on <service>");crlf;
	Con("w [<message>] - write <message> to connected port. A cr/lf");crlf;
	Con("             	 will be added automaticaly. If <message>");crlf;
	Con("                is omitted, only a cr/lf will be send.");crlf;
	Con("r [n] - receive message, timeout n seconds");crlf;
	Con("        If n is 0 or omitted, r returns immediately");crlf;
	Con("o <n> - Continuous receive for <n> seconds");crlf;
	Con("a <n> - auto-receive after \'w\'. <n> is the timeout in");crlf;
	Con("        seconds or omitted to turn auto-receive off.");crlf;
	Con("d - disconnect. Also creates new socket, so you have");crlf;
	Con("    to reuse \'p\' if you want to use the same local");crlf;
	Con("    port again.");crlf;
	Con("v <host> - resolve <host>\'s IP address");crlf;
	Con("q - quit");crlf;crlf;
	Con("The TCP connection is a true connection (not virtual as");crlf;
	Con("an UDP connection). Thus usage of \'c\' or \'d\' will");crlf;
	Con("take some time, as the socket kernel tries to (dis)connect");crlf;
	Con("(from)to the requested host.");
	Con("Using \'i\' or \'c\' sets the local socket to passive or");crlf;
	Con("active connection until \'d\' is used.");crlf;
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
		else if(err==EINPROGRESS)
			Con("connection in progress.");
		else
		{
			Con("error requesting connected port: ");
			numout(err);
		}
		crlf;
		return;
	}
	Con("connected to: ");
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
		else
			numout(err);
		crlf;
		return;
	}
	Con("Local port set to ");
	Con(name);
	crlf;
}

void listen_mode(void)
{
	int ret;
	
	ret=listen(sock, 1);
	switch(ret)
	{
		case E_OK:
			Con("listen mode on.");break;
		case EINVAL:
		case EISCONN:
			Con("you are already connected");break;
		case EINPROGRESS:
			Con("connection already in progress");break;
		default:
			{Con("error listening: ");numout(ret);}
	}
	crlf;
}

void get_con(void)
{
	int ret, len=(int)sizeof(sockaddr_in);
	sockaddr_in sa;
	
	sfcntl(sock,F_SETFL,O_NONBLOCK);
	ret=accept(sock, &sa, &len);
	sfcntl(sock,F_SETFL,0);
	
	if(ret<=0) 
	{
		switch(ret)
		{
			case EINVAL:
				Con("socket not in listen mode.");break;
			case EWOULDBLOCK:
				Con("no incoming connection yet.");break;
			default:
				{Con("error listening: ");numout(ret);}
		}
		crlf;
		return;
	}
	
	/* close listen socket */
	sclose(sock);
	/* accepted connection now active socket */
	sock=ret;
	Con("accepted connection from ");
	Con(inet_ntoa(sa.sin_addr));
	Con(" on port ");
	numout(sa.sin_port);
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
	{
		Con("illegal IP address");crlf;
		return;
	}
	if(sad.sin_port <=0)
	{
		Con("illegal destination port");crlf;
		return;
	}

	err=connect(sock, &sad, (int)sizeof(sockaddr_in));
	if((err < 0) && (err != EINPROGRESS))
	{
		Con("error connecting: ");
		switch(err)
		{
			case EINVAL:
				Con("last connection closing. Try again later."); break;
			case EALREADY:
				Con("connection already initiated."); break;
			case EISCONN:
				Con("connection already established."); break;
			case EADDRINUSE:
				Con("connection already in use. Try different local port/destination."); break;
			case ETIMEDOUT:
				Con("no reply/timeout."); break;
			case ECONNREFUSED:
				Con("connection refused by remote host.");break;
			default:
				numout(err);
		}
		crlf;
		return;
	}
	
	if(err==EINPROGRESS)
		Con("connecting to: ");
	else
		Con("connected to: ");
	Con(dip);
	Con(" on port ");
	Con(dport);
	crlf;
}

void disconnect(void)
{
	int err;
	
	err=shutdown(sock, 2);
	if(err!=E_OK)
	{
		Con("error disconnecting: ");
		if(err==ESHUTDOWN)
			Con("disconnection already initiated.");
		else
			numout(err);
		crlf;
		return;
	}
	
	sclose(sock);
	sock=socket(AF_INET, SOCK_STREAM, 0);
	if(sock < 0)
	{
		Con("error creating socket: ");
		if(sock==ENSMEM)
			Con("no memory");
		else /* What else could happen? */
			numout(sock);
		crlf;
		exit(0);
	}
	
	Con("disconnected.");
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
		Con("destination address required (use \'c\')");
	else if(err==ENHNDL)
		Con("no local portnumbers left.");
	else if(err==ENSMEM)
		Con("insufficient memory.");
	else
		numout(err);
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

void cont_recv(int sec)
{
	time_t start;
	
	start=time(NULL);
	while(time(NULL)-start < sec)
		recv_msg(1);
}

void input(void)
{
	char entry[260], cmd;
	int	param;
		
	do
	{
		prompt;
		entry[0]=255;
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
				{	Con("service required."); crlf; break;}
				set_port(&(entry[2]));
			break;
			case 'I': listen_mode();break;
			case 'G': get_con();break;
			case 'C': 
				if(strlen(entry) < 3)
				{Con("destination required.");crlf;break;}
				connect_to(&(entry[2]));
			break;
			case 'D': disconnect(); break;
			case 'W': 
				if(strlen(entry) < 3)
					write_msg("\r\n"); 
				else
				{
					strcat(entry, "\r\n");
					write_msg(&(entry[2])); 
				}
				if(auto_rcv > -1)
					recv_msg(auto_rcv);
			break;
			case 'R': 
				if(param > -1)
				{	recv_msg(param); break;}
				recv_msg(0); 
			break;
			case 'O':
				if(strlen(entry) < 3)
				{Con("time required.");crlf;break;}
				cont_recv(param);
			break;
			case 'A':
				auto_rcv=param;
				if(auto_rcv <0)
					Con("auto-receive off.");
				else
				{	Con("auto-receive on, timeout ");numout(auto_rcv);Con(" seconds.");}
				crlf;
			break;
			case 'V': 
				if(strlen(entry) < 3)
				{Con("hostname required.");crlf;break;}
				resolve(&(entry[2])); break;
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

	sock=socket(AF_INET, SOCK_STREAM, 0);
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
	if((argc>1)&&(((char*)argv[0])[0]=='?'))
	{
		Con("usage:");crlf;
		Con("tcp_cli");crlf;
		Con("A prompt will appear, use the following commands:");crlf;
		help();
		return;
	}

	input();
	shutdown(sock,2);
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
