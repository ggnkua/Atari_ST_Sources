#include <sockinit.h>
#include <socket.h>
#include <sfcntl.h>
#include <sockios.h>
#include <in.h>
#include <inet.h>
#include <netdb.h>
#include <rsdaemon.h>
#include <icon_msg.h>

#include <sockerr.h>
#include <atarierr.h>


#define DEFAULT_POP3_PORT	110
#define DEFAULT_SMTP_PORT	25
#define DEFAULT_NNTP_PORT 119
#define TO_REPLY_SEK 90			/* Seconds to wait for reply */
#define CONNECT_COUNT	900		/* Counts in 100ms for Connection-Timeout */

#define ES_INITIAL	0
#define ES_INWAIT		1
#define ES_CONNSMTP 2
#define ES_SENDPM		3
#define ES_CONNPOP	4
#define ES_GETPM		5
#define ES_CONNNNTP	6
#define ES_GRPLIST	7
#define ES_SENDOM		8
#define ES_GETOM		9
#define ES_GETGROUPS 10
#define ES_DONE			11

#define SS_ENTER 0
#define SS_CONNECT 1
#define SS_CONT		2
#define SS_DONE	3

typedef struct
{
	int		flags;
	long	size;
	char	head[2048];
}PMAIL;
/* Flags: */
#define PMF_GET	1
#define	PMF_DEL 2
#define PMF_DELETED 4
#define PMF_GOT	8

typedef struct
{
	int		me_connect;
	int		always_show;

	int		do_om;
	int		do_pm;
		
	ulong	filter_entries;

	ulong	local_ip;
		
	ulong	smtp_ip;
	int		smtp_port;
	char	email[66];
	char	real_name[66*3+18];	/* Worst case fÅr quoted printable */
	ulong	send_pms;
	ulong	send_bytes;

	ulong	pop_ip;
	int		pop_port;
	char	pop_user[64];
	char	pop_pass[64];
	ulong	mem_old_pms;	/* Keeps value */
	ulong	old_pms;	/* Counting down to zero when getting list */
	ulong	new_pms;	/* Counting up when getting list */
	ulong	total_pms;	/* Countint up when getting list */
	long	offset;	/* Dialogue */
	PMAIL	*pms;

	ulong	nntp_ip;
	int		nntp_port;
	char	nntp_user[64];
	char	nntp_pass[64];
	ulong	send_oms;
	ulong	send_obytes;
}ONLINE_INFO;



extern WINDOW	wonline;
extern DINFO		donline;
extern OBJECT	*oonline;

extern int			logh;

extern ONLINE_INFO minf;


void Flog(char *c);
void set_stat(int ob);
void set_act(char *text);
void set_process(long is, long will);
int send_string(int s, char *msg, int cr);
void run_jobs(void);

int get_pm_list(int s);
int user_pm_list(int s);

int	stop_download_filter(void);
int check_download_filter(char *head, int *del);
int check_grp_download_filter(int fh, long len);
void run_filters(int fh, ulong num);
