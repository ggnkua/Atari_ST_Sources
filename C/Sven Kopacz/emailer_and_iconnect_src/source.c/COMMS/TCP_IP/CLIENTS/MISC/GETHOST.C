#include <stdio.h>
#include <tos.h>
#include <sockinit.h>
#include <socket.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>

/* Console output */
#define Con(a) Cconws(a)
#define crlf Con("\r\n")

void main(int argc, char *argv[])
{
	int c=1, d;
	hostent	*he;

	d=sock_init();
	if(d < 0)
	{
		switch(d)
		{
			case SE_NINSTALL:
				Con("gethost: Sockets not installed.");crlf;
				Con("Put SOCKETS.PRG in the AUTO-folder.");crlf;
			break;
			case SE_NSUPP:
				Con("gethost: SOCKETS.PRG is too old.");crlf;
			break;
		}
		return;
	}
	
	/* Help needed? */
	if((argc==1)||((argc==2)&&(((char*)argv[0])[0]=='?')))
	{
		Con("gethost v0.1 29.01.1997 Sven Kopacz");crlf;
		Con("usage:");crlf;
		Con("gethost {hostname }");crlf;
		Con("gethost will ask the resolver for aliases and IP-addresses");crlf;
		Con("of all hostnames. The resolver will contact the DNS.");crlf;
		Con("Example:");crlf;
		Con("[input:]");crlf;
		Con("gethost ftp.uni-stuttgart.de news.uni-stuttgart.de noname");crlf;
		Con("[output:]");crlf;
		Con("host: ftp.uni-stuttgart.de");crlf;
		Con("alias: info2.rus.uni-stuttgart.de");crlf;
		Con("IP: 129.69.18.15");crlf;crlf;
		Con("host: news.uni-stuttgart.de");crlf;
		Con("alias: info4.rus.uni-stuttgart.de");crlf;
		Con("IP: 129.69.1.13");crlf;crlf;
		Con("host: noname");crlf;
		Con("Not found.");crlf;
		return;
	}
	
	while(c < argc)
	{
		Con("host: ");
		Con((char*)argv[c]);
		crlf;
		he=gethostbyname((char*)argv[c]);
		if(he)
		{
			d=0;
			while(he->h_aliases[d])
			{
				Con("alias: ");
				Con(he->h_aliases[d++]); crlf;
			}
			d=0;
			while(he->h_addr_list[d])
			{
				Con("IP: ");
				Con(inet_ntoa(*(ulong*)(he->h_addr_list[d++]))); crlf;
			}
		}
		else
			Con("Not found."); crlf;
		++c;
	}
}
