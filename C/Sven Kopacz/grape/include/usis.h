#ifndef __USIS__

#define __USIS__

typedef struct
{
	long		total_sec;								/* Seconds total */
	
	int			hours, minutes, seconds;	/* Time in integers */
	char		hh_mm_ss[10];							/* Time as "HH:MM:SS\0" */
}ONLINE_TIME;

typedef struct
{
	long		bytes_sent;
	long		bytes_rcvd;
	
	char		t_sent[13];		/* "x[x[x[x[.x]]]] [K|M|G]Byte" */
	char		t_rcvd[13];
}BYTE_EXCHANGE;

typedef struct
{
	int							request;
	unsigned long		ip;
	int							port;
	char						*result;
	char						*free1;
	char						*free2;
	void						*other;
}USIS_REQUEST;

/* Usis requests */

#define UR_ETC_PATH		1
#define	UR_LOCAL_IP		2
#define UR_REMOTE_IP	3
#define UR_DNS_IP			4
#define UR_POP_IP			5
#define UR_SMTP_IP		6
#define UR_NEWS_IP		7
#define UR_TIME_IP		8
#define	UR_EMAIL_ADDR	9
#define	UR_PROXY_IP		10	/* free1=service, free2=host or "" */
#define UR_POP_USER		11
#define UR_POP_PASS		12
#define UR_REAL_NAME	13
#define UR_ONLINE_TIME 14	/* *other=(ONLINE_TIME*)_ol_ */
#define UR_BYTES			15	/* *other=(BYTES_EXCHANGE*)_be_ */
#define UR_CONN_MSG		16	/* Modem-Message copied to <result> */
#define UR_NNTP_USER	17
#define UR_NNTP_PASS	18
#define UR_VERSION		19
#define UR_RESOLVED		20

/* Usis answers */
#define	UA_FOUND			0
#define UA_NOTSET			-1
#define	UA_UNKNOWN		-2
#define UA_OFFLINE		-3		

extern int cdecl usis_query(USIS_REQUEST *ur);

#endif