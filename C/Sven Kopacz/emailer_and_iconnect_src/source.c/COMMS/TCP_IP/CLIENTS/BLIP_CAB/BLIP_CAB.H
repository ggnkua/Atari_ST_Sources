
typedef struct
{
	char	url[512];
	
	int		http_vers;	/* Version*10, 9=0.9, 10=1.0 etc */
	long	recv_bytes;	/* Bytes written to file */

	/* Following fields only valid if http_vers > 9 */
	int		res_code;		/* result code, usualy 200-5xx */
	long	timestamp;	/* seconds since 01.01.1970 00:00 or -1*/
	long	size;				/* Size of file or -1 */

	char	cont_encod[250];	/* Type of content encoding or \0 */
	char	cont_type[250];		/* Well, guess what (or \0) */
	char	location[512];		/* New location in redirection */
	
	int		basic_auth;	/* "WWW-Authentication: Basic" found 0/1 */
	char	auth_realm[128];
}RECV_INFO;

void debug_on(void);
void debug_off(void);
void Dftext(char *c);
void Dfnumber(long i);

long download_url(char *url, char *path, char *cookie);
long download_mod_url(char *url, char *path, long *timep, char *cookie);
long header_of_url(char *url, RECV_INFO *rinf);
long post_data(char *url, char *content, char *enctype, char *path, char *cookie);
long send_mail(char *url, char *subject, char *filename);
long download_news(char *url, char *path);

int to_connect(int s, const void *addr, int addrlen);

long lmsglen(char *msg);
int send_string(int s, char *msg, int cr);
int get_reply(int s);
unsigned long my_gethostbyname(char *c);

extern browser_info_t *browser;
extern int http_port;
extern int smtp_port;
extern int nntp_port;
#define DEFAULT_HTTP_PORT	80
#define DEFAULT_SMTP_PORT	25
#define DEFAULT_NNTP_PORT 119