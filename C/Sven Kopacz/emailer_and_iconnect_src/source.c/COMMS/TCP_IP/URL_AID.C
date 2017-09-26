#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>
#include <url_aid.h>

/* If URL contains no prepending service (<service://>) use: */

int	cdecl parse_url(char *s, URL *url, int default_port, char *default_name)
{/* 0 ok, -1=unknown service */
	char	*host, *path, *a, copy[512];
	servent	*se;
	int		x;
	
	strncpy(copy, s, 511);
	copy[511]=0;
	s=copy;
	
	url->port=-1;
	
	a=strchr(s, ':');
	if(a==NULL)
	{/* Only host[path] */
		url->port=default_port;
		strcpy(url->service, default_name);
		host=s;
		goto _host_found;
	}

	if((a[1]!='/')||(a[2]!='/'))
	{/* Only host[:port[path]] */
		url->port=default_port;
		strcpy(url->service, default_name);
		host=s;
		goto _host_found;
	}

	/* s points to service, a to ':' prepending service */
	*a=0;
	host=a+3;
	if((!stricmp(s, default_name))||(*s==0))
	{	
		url->port=default_port;
		strcpy(url->service, default_name);
		goto _host_found;
	}
	
	/* Other service */
	strncpy(url->service, s, 13); url->service[13]=0;
	if(default_port <= 0)
		url->port=-1;
	else
		url->port=default_port;
	
_host_found:
	/* Host prepended by port number? */
	a=strchr(host, ':');
	if((a==NULL) || (a > strchr(host, '/'))) /* ':' could also occur in path */
	{
		a=host;
		goto _no_extra_port;
	}

	*a++=0;			/* host-string now terminated */
	x=atoi(a);	/* New port? */
	if(x!=0)
		url->port=x;

_no_extra_port:
	/* Do we have a port number now? */
	if(url->port <= 0)
	{
		se=getservbyname(url->service, "tcp");
		if(se==NULL)
			return(-1);
		url->port=se->s_port;
	}

	/* Find path */
	while(*a && (*a!='/'))++a;
	if(*a)
	{
		*a++=0;
		path=a;
	}
	else
		path=a;

	url->host[127]=0;
	url->path[511]=0;

	/* Copy host name */
	if(strchr(host, '.')==NULL)
	{/* Only middle-name given, add "www.<host>.com" */
		strcpy(url->host, "www.");
		strncat(url->host, host, 119);
		url->host[123]=0;
		strcat(url->host, ".com");
	}
	else
		strncpy(url->host, host, 127);
	
	if(path[0]!='/')
		strcpy(url->path,"/");
	else
		url->path[0]=0;
	strncat(url->path,path,509);

	/* Done */
	return(0);	
}
