#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sockerr.h>
#include <socket.h>
#include <netdb.h>
#include <in.h>
#include <inet.h>
#include <tos.h>
#include <atarierr.h>

#include "getent.h"
/* Needed to separate DNS-hostent-FNs from etc/hosts-FNs */
#include "network.h"
extern cookie_struct *sint;

static UNI_ENT	uni;

static R_ENT	r_host={-1,0,HOSTS};
static R_ENT	r_net={-1,0,NETWORKS};
static R_ENT	r_serv={-1,0,SERVICES};
static R_ENT	r_proto={-1,0,PROTOKOLS};
static R_ENT	r_rpc={-1,0,RPC};

/* TOS File handling */

int Eopen(char *fname)
{/* Open file <fname> in etc/ */
	char path[256], *p;
	
	p=getenv("ETCPATH");
	if(p==NULL) return(-1);
	strcpy(path, p);
	if(path[strlen(path)-1]!='\\')
		strcat(path,"\\");
	strcat(path, fname);
	
	return((int)Fopen(path, FO_READ));
}

int Freads(int fh, char *buf, int len)
{/* Liest bis LF. Gibt Bytes oder <=0(error) zurck */
	register int red;
	register char *b;
	char					ign;
	register long err;
	long					opos;

	/* Fill buffer */
	while(1)
	{
		opos=Fseek(0,fh,1);
		/* Reserve one Byte for Memory-Termination, if last line in
				file is not terminated */
		err=Fread(fh, len-1, buf);
		if(err <=0) return((int)err);
	
		/* Search for end of buffer (Line Feed) */
		b=buf;
		red=0;
		while((b[red] !=10) && (red <err))++red;
	
		if(b[red]==10)	/* End found */
		{
			++red;	/* Count LF byte */
			Fseek(opos+red, fh,0);	/* correct Fpos */
			return(red);
		}

		/* No LF found, Line too long or last line in File is unterminated */
		if((err<len-1)||(Fread(fh, 1, &ign)==0))	/* EOF */
		{
			buf[red++]=10;	/* Terminate in Memory and count LF byte*/
			return(red);
		}
		
		/* Line longer than buf, ignore it */
		while(ign!=10)
		{
			err=Fread(fh, 1, &ign);
			if(err<=0) return((int)err);	/* Error or EOF */
		}
	}
}

/* unique */

int setent(R_ENT *r_ent, int stayopen)
{
	/* File already open? */
	if(r_ent->fhandle > -1)
		Fclose(r_ent->fhandle);
		
	/* Open File */
	r_ent->fhandle=Eopen(r_ent->basefile);
	r_ent->stayopen=stayopen;
	if(r_ent->fhandle >= 0)
		return(E_OK);
	return(r_ent->fhandle);
}

int endent(R_ENT *r_ent)
{
	if(r_ent->fhandle > -1)
	{
		Fclose(r_ent->fhandle);
		r_ent->fhandle=-1;
	}
	return(E_OK);
}

int getent(R_ENT *r_ent)
{/* Return 0 or number of words in line */
	register int 	ix;
	register char	*p;
	
	if(r_ent->fhandle < 0)
		if(setent(r_ent, 0) < 0)
			return(0);
	
	/* Read one line */
	do
	{
		if(Freads(r_ent->fhandle, uni.first, MAX_LINE) <= 0)
			return(0);
	
		/* Put EOL */
		p=uni.first;
		while((*p!='#')&&(*p!=10)&&(*p!=13))++p;
		*p=0;
	}while(strlen(uni.first)==0);
	
	/* Split line */
	p=uni.first; ix=0;
	
	while(1)
	{
		while(*p && (*p!=' ') && (*p!=9))++p;	/* Omit word */
		if(!*p) break;									/* Break on EOL */
		*p++=0; 												/* Terminate string */
		while((*p==' ')||(*p==9)) ++p;	/* Omit whitespace */
		if(!*p) break;									/* Break on EOL */
		uni.others[ix++]=p;							/* Set pointer to new word */
		if(ix==MAX_ENT) break;					/* Break on static limit */
	}

	uni.others[ix++]=NULL;
	
	if(r_ent->stayopen==0)
		endnetent();
		
	return(ix);
}	

/* host */

hostent		*gethostbyname(const char *name)
{
	register hostent *p;	register char **cp;
	if(sint->defs->name_server_ip!=INADDR_NONE)
		return(dns_gethostbyname(name));
			sethostent(r_host.stayopen);	while ((p = gethostent())!=NULL)
  {		if (stricmp(p->h_name, name) == 0)			break;		for (cp = p->h_aliases; *cp != 0; cp++)			if (stricmp(*cp, name) == 0)				goto found;	}found:	if (!r_host.stayopen)		endhostent();	return (p);}

hostent		*gethostbyaddr(const char *addr, int len, int type)
{
	register	hostent *p;	register	unsigned long	soll;
	register	int	ix;

	if(sint->defs->name_server_ip!=INADDR_NONE)
		return(dns_gethostbyaddr(addr, len, type));
			
	if(type!=AF_INET) return(NULL);
	if(len!=(int)sizeof(unsigned long)) return(NULL);
	
	soll=*(ulong*)addr;
		sethostent(r_host.stayopen);	while ((p = gethostent())!=NULL)
	{
		ix=0;
		do
		{
			if(soll==*(ulong*)(p->h_addr_list[ix++]))				goto found;
		}while(p->h_addr_list[ix]);
		p=NULL;	}
found:	if (!r_net.stayopen)		endnetent();	return (p);}

hostent		*gethostent(void)
{
	static	unsigned long addr_list[MAX_ADD];
	static	unsigned long	*p_addr_list[MAX_ADD+1];
	static 	hostent	my_ent;
	int 		ret,n;
	unsigned long	addr;
	
	if(sint->defs->name_server_ip!=INADDR_NONE)
		return(dns_gethostent());
		
	ret=getent(&r_host);
	if(ret<1) return(NULL);
	
	/* read all internet addresses of host */
	addr=inet_addr(uni.first);
	if(addr!=INADDR_NONE)
	{
		addr_list[0]=addr;
		p_addr_list[0]=&(addr_list[0]);
	}
	n=1;
	while((addr!=INADDR_NONE) && (n < ret))
	{
		addr=inet_addr(uni.others[n-1]);
		if(addr!=INADDR_NONE)
		{
			if(n<MAX_ADD)
			{
				addr_list[n]=addr;
				p_addr_list[n]=&(addr_list[n]);
			}
			++n;
		}
	}
	if(n>=MAX_ADD)
		p_addr_list[MAX_ADD+1]=NULL;
	else
		p_addr_list[n]=NULL;
		
	if(n>=ret) /* Illegal line, get next */
		return(gethostent());
		
	my_ent.h_name=uni.others[n-1];
	my_ent.h_aliases=&(uni.others[n]);
	my_ent.h_addrtype=AF_INET;
	my_ent.h_length=(int)sizeof(unsigned long);
	(ulong**)(my_ent.h_addr_list)=&(p_addr_list[0]);
	return(&my_ent);
}

int			sethostent(int stayopen)
{
	if(sint->defs->name_server_ip!=INADDR_NONE)
		return(dns_sethostent(stayopen));
		
	return(setent(&r_host, stayopen));
}

int			endhostent(void)
{
	if(sint->defs->name_server_ip!=INADDR_NONE)
		return(dns_endhostent());
		
	return(endent(&r_host));
}

/* net */

netent		*getnetbyname(const char *name)
{
	register netent *p;	register char **cp;	setnetent(r_net.stayopen);	while ((p = getnetent())!=NULL)
  {		if (strcmp(p->n_name, name) == 0)			break;		for (cp = p->n_aliases; *cp != 0; cp++)			if (strcmp(*cp, name) == 0)				goto found;	}found:	if (!r_net.stayopen)		endnetent();	return (p);}

netent		*getnetbyaddr(int net, int type)
{
	register netent *p;	setnetent(r_net.stayopen);	while ((p = getnetent())!=NULL)
	{		if ((p->n_net==net)&&(p->n_addrtype==type))			break;	}	if (!r_net.stayopen)		endnetent();	return (p);}

netent		*getnetent(void)
{
	static netent	my_ent;
	int ret=getent(&r_net);
	
	if(ret<1) return(NULL);
	if(ret<2) return(getnetent()); /* Ilegal line->get next */
		
	my_ent.n_name=uni.first;
	my_ent.n_aliases=&(uni.others[1]);
	my_ent.n_addrtype=AF_INET;
	my_ent.n_net=atoi(uni.others[0]);
	return(&my_ent);
}

int			setnetent(int stayopen)
{
	return(setent(&r_net, stayopen));
}

int			endnetent(void)
{
	return(endent(&r_net));
}

/* serv */

servent	*getservbyname(const char *name, const char *proto){	register servent *p;	register char **cp;	setservent(r_serv.stayopen);	while ((p = getservent())!=NULL)
  {		if(strcmp(p->s_proto, proto)!=0)
			continue;
					if (strcmp(p->s_name, name) == 0)
			break;

		for (cp = p->s_aliases; *cp != 0; cp++)			if (strcmp(*cp, name) == 0)
				goto found;	}found:	if (!r_serv.stayopen)		endservent();	return (p);}
servent	*getservbyport(int port, const char *proto){	register  servent *p;	setservent(r_serv.stayopen);	while ((p = getservent())!=NULL)
  {		if (p->s_port != port)			continue;		if (proto == 0 || strcmp(p->s_proto, proto) == 0)			break;	}	if (!r_serv.stayopen)		endservent();	return (p);}
servent	*getservent(void){	static servent	my_ent;
	int ret=getent(&r_serv);
	char	*slash;
	
	if(ret<1) return(NULL);
	if(ret<2) return(getservent()); /* Illegal line->get next */
	
	slash=strchr(uni.others[0],'/');
	if(slash==NULL) return(getservent()); /* Illegal line->get next */
	*slash++=0;
	
	my_ent.s_name=uni.first;
	my_ent.s_aliases=&(uni.others[1]);
	my_ent.s_port=atoi(uni.others[0]);
	my_ent.s_proto=slash;
	return(&my_ent);
}
int			setservent(int stayopen){	return(setent(&r_serv, stayopen));
}
int			endservent(void){	return(endent(&r_serv));
}
/* proto */

protoent	*getprotobyname(const char *name){	register protoent *p;	register char **cp;	setprotoent(r_proto.stayopen);	while ((p = getprotoent())!=NULL)
  {		if (strcmp(p->p_name, name) == 0)			break;		for (cp = p->p_aliases; *cp != 0; cp++)			if (strcmp(*cp, name) == 0)				goto found;	}found:	if (!r_proto.stayopen)		endprotoent();	return (p);}
protoent	*getprotobynumber(int proto){	register protoent *p;	setprotoent(r_proto.stayopen);	while ((p = getprotoent())!=NULL)
	{		if (p->p_proto==proto)
			break;	}	if (!r_proto.stayopen)		endprotoent();	return (p);}
protoent	*getprotoent(void){	static protoent	my_ent;
	int ret=getent(&r_proto);
	
	if(ret<1) return(NULL);
	if(ret<2) return(getprotoent()); /* Illegal line->get next */
	
	my_ent.p_name=uni.first;
	my_ent.p_aliases=&(uni.others[1]);
	my_ent.p_proto=atoi(uni.others[0]);
	return(&my_ent);
}
int			setprotoent(int stayopen){	return(setent(&r_proto, stayopen));
}
int			endprotoent(void){	return(endent(&r_proto));
}
/* rpc */

rpcent		*getrpcbyname(const char *name){	register rpcent *p;	register char **cp;	setrpcent(r_rpc.stayopen);	while ((p = getrpcent())!=NULL)
  {		if (strcmp(p->r_name, name) == 0)			break;		for (cp = p->r_aliases; *cp != 0; cp++)			if (strcmp(*cp, name) == 0)				goto found;	}found:	if (!r_rpc.stayopen)		endrpcent();	return (p);}
rpcent		*getrpcbynumber(long number){	register rpcent *p;	setrpcent(r_rpc.stayopen);	while ((p = getrpcent())!=NULL)
	{		if (p->r_number==number)
			break;	}	if (!r_rpc.stayopen)		endrpcent();	return (p);}
rpcent		*getrpcent(void){	static rpcent	my_ent;
	int ret=getent(&r_rpc);
	
	if(ret<1) return(NULL);
	if(ret<2) return(getrpcent()); /* Illegal line->get next */
		
	my_ent.r_name=uni.first;
	my_ent.r_aliases=&(uni.others[1]);
	my_ent.r_number=atol(uni.others[0]);
	return(&my_ent);
}
int			setrpcent(int stayopen){	return(setent(&r_rpc, stayopen));
}
int			endrpcent(void){	return(endent(&r_rpc));
}
