#include <atarierr.h>

#define	READ_SIZE	2048
#define	KEEPINFO	50

typedef struct
	{
	char	request[128];
	char	site[128];
	char	path[1024];
	char	port[50];
	} URL;

extern	char	gbuf[];
extern	browser_info_t *browser;
extern	FILE	*ep;
extern	char	*version;

URL	*___CDECL _parseURL(char *url);
void	___CDECL ierror(char *format,...);
URL	*___CDECL _parseURL(char *url);
char	*http_proxy(char *s);
char	*ftp_proxy(char *s);
char	*wais_proxy(char *s);
char	*gopher_proxy(char *s);
char	*news_proxy(char *s);
int	rev_strcmp(const char *s1,const char *s2);
int	no_proxy(char *s);
URL	*___CDECL parseURL(char *url);
int OpenConnection(char *host, char *service);
long readline(int zeroit,int s,char *buf,int limit);
int xwrite(int fd, char *p, long i);
long ___CDECL _get_url(char *url, char *filename,char *kind);
long	make_unix_time(char *s);

