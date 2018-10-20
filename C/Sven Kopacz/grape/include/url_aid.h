#ifndef __URL_AID__
#define __URL_AID__

typedef struct
{
	int		port;
	char	service[14];
	char	host[128];
	char	path[512];
}URL;

extern int cdecl parse_url(char *s, URL *url, int default_port, char *default_name);

#endif