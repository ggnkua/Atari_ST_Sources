/* hosts/networks/services/protocols/rpc entry test */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <sockinit.h>
#include <socket.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>
#include <atarierr.h>
#include <sockerr.h>
#include <ext.h>

/* Console output */
#define Con(a) Cconws(a)
#define crlf Con("\r\n")

/* program info */
#define prg_info	Con("Test entry, v0.1 05.02.1997 Sven Kopacz");crlf
/* Prompt */
#define prompt Con("ent>")

void numout(long num)
{
	char nus[32];
	Con(ltoa(num, nus, 10));
}

void Conerr(char *errstr, int errnum)
{
	Con("Error ");
	Con(errstr);
	Con(": ");
	numout(errnum);
	crlf;
}

void help(void)
{
	Con("? - This list of commands");crlf;
	Con("q - quit");crlf;
	Con("r<type> - read all entries of <type>");crlf;
	Con("          allowed types: host/net/serv/proto/rpc");crlf;
	Con("hname <name> - gethostbyname");crlf;
	Con("haddr <IP> - gethostbyaddr");crlf;
	Con("nname <name> - getnetbyname");crlf;
	Con("naddr <number> - getnetbyaddr");crlf;
	Con("sname <name> <proto> - getservbyname");crlf;
	Con("sport <port> <proto> - getservbyport");crlf;
	Con("pname <name> - getprotobyname");crlf;
	Con("pnumber <proto> - getprotobynumber");crlf;
	Con("rname <name> - getrpcbyname");crlf;
	Con("rnumber <number> - getrpcbynumber");crlf;
	crlf;
}


/*  **************************************
  struct to Con
*/


void Conhost(hostent *p)
{
	char *c;
	int ix=0;

	if(p==NULL)	{Con("No entry.");crlf;return;}
		
	Con("[host entry]");crlf;
	Con("Realname: ");Con(p->h_name);crlf;
	while((c=p->h_aliases[ix++])!=NULL)
	{	Con("Alias: "); Con(c); crlf; }
	ix=0;
	while((c=p->h_addr_list[ix++])!=NULL)
	{	Con("IP: "); Con(inet_ntoa(*(ulong*)c)); crlf;}
	Con("---");crlf;
}

void Connet(netent *p)
{
	char *c;
	int ix=0;
	
	if(p==NULL)	{Con("No entry.");crlf;return;}

	Con("[net entry]");crlf;
	Con("Realname: ");Con(p->n_name);crlf;
	while((c=p->n_aliases[ix++])!=NULL)
	{	Con("Alias: "); Con(c); crlf;	}
	Con("Number: ");numout(p->n_net);crlf;
	Con("---");crlf;
}

void Conserv(servent *p)
{
	char *c;
	int ix=0;
	
	if(p==NULL)	{Con("No entry.");crlf;return;}

	Con("[serv entry]");crlf;
	Con("Realname: ");Con(p->s_name);crlf;
	while((c=p->s_aliases[ix++])!=NULL)
	{	Con("Alias: "); Con(c); crlf;	}
	Con("Port: ");numout(p->s_port);crlf;
	Con("Protocol: ");Con(p->s_proto);crlf;
	Con("---");crlf;
}

void Conproto(protoent *p)
{
	char *c;
	int ix=0;
	
	if(p==NULL)	{Con("No entry.");crlf;return;}

	Con("[proto entry]");crlf;
	Con("Realname: ");Con(p->p_name);crlf;
	while((c=p->p_aliases[ix++])!=NULL)
	{	Con("Alias: "); Con(c); crlf;	}
	Con("Number: ");numout(p->p_proto);crlf;
	Con("---");crlf;
}

void Conrpc(rpcent *p)
{
	char *c;
	int ix=0;
	
	if(p==NULL)	{Con("No entry.");crlf;return;}

	Con("[rpc entry]");crlf;
	Con("Realname: ");Con(p->r_name);crlf;
	while((c=p->r_aliases[ix++])!=NULL)
	{	Con("Alias: "); Con(c); crlf;	}
	Con("Number: ");numout(p->r_number);crlf;
	Con("---");crlf;
}


/*  **************************************
  set/get/end ent
*/


void read_host(void)
{
	hostent *p;
	
	int ret=sethostent(1);
	if(ret < 0){Conerr("sethostent",ret);return;}
		
	while((p=gethostent())!=NULL)
		Conhost(p);
	endhostent();
}

void read_net(void)
{
	netent *p;
	
	int ret=setnetent(1);
	if(ret < 0){Conerr("setnetent",ret);return;}
		
	while((p=getnetent())!=NULL)
		Connet(p);
	endnetent();
}

void read_serv(void)
{
	servent *p;
	
	int ret=setservent(1);
	if(ret < 0){Conerr("setservent",ret);return;}
		
	while((p=getservent())!=NULL)
		Conserv(p);
	endservent();
}

void read_proto(void)
{
	protoent *p;
	
	int ret=setprotoent(1);
	if(ret < 0){Conerr("setprotoent",ret);return;}
		
	while((p=getprotoent())!=NULL)
		Conproto(p);
	endprotoent();
}

void read_rpc(void)
{
	rpcent *p;
	
	int ret=setrpcent(1);
	if(ret < 0){Conerr("setrpcent",ret);return;}
		
	while((p=getrpcent())!=NULL)
		Conrpc(p);
	endrpcent();
}

void read_type(char *type)
{
	if(!stricmp(type, "host")){read_host();return;}
	if(!stricmp(type, "net")){read_net();return;}
	if(!stricmp(type, "serv")){read_serv();return;}
	if(!stricmp(type, "proto")){read_proto();return;}
	if(!stricmp(type, "rpc")){read_rpc();return;}
	Con("Unknown type");crlf;
}


/*  **************************************
		getby
*/

void hname(char *p)
{
	Conhost(gethostbyname(p));
}

void haddr(char *p)
{
	ulong ip=inet_addr(p);
	if(ip==INADDR_NONE){Con("Illegal IP");return;}
	Conhost(gethostbyaddr((char*)(&ip),(int)sizeof(ulong),AF_INET));
}

void nname(char *p)
{
	Connet(getnetbyname(p));
}

void naddr(char *p)
{
	Connet(getnetbyaddr(atoi(p),AF_INET));
}

void sname(char *p)
{
	char *name=p;
	while(*p && (*p!=' '))++p;
	if(!*p){Con("Missing protocol");crlf;return;}
	*p++=0;
	Conserv(getservbyname(name,p));
}

void sport(char *p)
{
	char *name=p;
	while(*p && (*p!=' '))++p;
	if(!*p){Con("Missing protocol");crlf;return;}
	*p++=0;
	Conserv(getservbyport(atoi(name),p));
}

void pname(char *p)
{
	Conproto(getprotobyname(p));
}

void pnumber(char *p)
{
	Conproto(getprotobynumber(atoi(p)));
}

void rname(char *p)
{
	Conrpc(getrpcbyname(p));
}

void rnumber(char *p)
{
	Conrpc(getrpcbynumber(atol(p)));
}


/*  **************************************
  cli
*/


void input(void)
{
	char entry[258], *p;
	
	do
	{
		crlf;
		prompt;
		entry[0]=255;
		do
		{
			Cconrs((LINE*)entry);
		}while(!entry[1]);
		crlf;
		entry[entry[1]+2]=0;
		strcpy(entry, &entry[2]);
		
		if(strlen(entry)==0) continue;
		
		p=entry;
		while(*p && (*p!=' '))++p;
		if(*p)
		{
			*p++=0;
			if(!stricmp(entry,"hname")) {hname(p); continue;}
			if(!stricmp(entry,"haddr")) {haddr(p); continue;}
			if(!stricmp(entry,"nname")) {nname(p); continue;}
			if(!stricmp(entry,"naddr")) {naddr(p); continue;}
			if(!stricmp(entry,"sname")) {sname(p); continue;}
			if(!stricmp(entry,"sport")) {sport(p); continue;}
			if(!stricmp(entry,"pname")) {pname(p); continue;}
			if(!stricmp(entry,"pnumber")) {pnumber(p); continue;}
			if(!stricmp(entry,"rname")) {rname(p); continue;}
			if(!stricmp(entry,"rnumber")) {rnumber(p); continue;}
		}
		if(entry[0]=='?') {help(); continue;}
		if((entry[0] & 95)=='R') {read_type(&(entry[1])); continue;}
		if((entry[0] & 95)!='Q')
			Con("Unknown command");
	}
	while((entry[0] & 95)!='Q');
}

void main(int argc, char *argv[])
{
	int d;

	d=sock_init();
	if(d < 0)
	{
		switch(d)
		{
			case SE_NINSTALL:
				Con("qotd: Sockets not installed.");crlf;
				Con("Put SOCKETS.PRG in the AUTO-folder.");crlf;
			break;
			case SE_NSUPP:
				Con("qotd: SOCKETS.PRG is too old.");crlf;
			break;
		}
		return;
	}

	/* Help needed? */
	if((argc>=2)&&(((char*)argv[0])[0]=='?'))
	{
		prg_info;
		Con("usage:");crlf;
		Con("test_ent");crlf;
		Con("A prompt will appear, use the following commands:");crlf;
		help();
		return;
	}

	input();
}

