#if  !defined( __GETENT__ )
#define __GETENT__

/* Maximum line length for reading etc/-lines*/
#define MAX_LINE 256

/* Maximum entries (separated by whitespace) per line */
#define MAX_ENT 11

/* Maximum numbers of IP-addresses for one host in etc/hosts */
#define MAX_ADD 3

/* Universal entry struct */
typedef struct
{
	char	first[MAX_LINE];		/* Type, Name etc.., whole line buffer */
	char	*others[MAX_ENT+1];			/* All pointers point somewhere in <first>, last is NULL */
}UNI_ENT;

/* Filestruct to use universal File-FNs */
typedef struct
{
	int		fhandle;
	int		stayopen;
	char	basefile[10];	/* 8 filename + term 0 + padbyte */
}R_ENT;

/* Names of files in etc/ */
#define HOSTS 		"hosts"
#define NETWORKS	"networks"
#define SERVICES	"services"
#define PROTOKOLS	"protocol"
#define RPC				"rpc"


extern hostent	*dns_gethostbyname(const char *name);
extern hostent	*dns_gethostbyaddr(const char *addr, int len, int type);
extern hostent	*dns_gethostent(void);
extern int			dns_sethostent(int stayopen);
extern int			dns_endhostent(void);


#endif