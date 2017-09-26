#if  !defined( __RESOLVER__ )
#define __RESOLVER__


/*
 * Internet nameserver port number
 */
#define NAMESERVER_PORT 53

/*
 * Currently defined opcodes
 */
#define QUERY   0x0   /* standard query */
#define IQUERY    0x1   /* inverse query */
#define STATUS    0x2   /* nameserver status query */
/*#define xxx   0x3      0x3 reserved */
  /* non standard */
#define UPDATEA   0x9   /* add resource record */
#define UPDATED   0xa   /* delete a specific resource record */
#define UPDATEDA  0xb   /* delete all nemed resource record */
#define UPDATEM   0xc   /* modify a specific resource record */
#define UPDATEMA  0xd   /* modify all named resource record */

#define ZONEINIT  0xe   /* initial zone transfer */
#define ZONEREF   0xf   /* incremental zone referesh */

/*
 * Currently defined response codes
 */
#define NOERROR   0   /* no error */
#define FORMERR   1   /* format error */
#define SERVFAIL  2   /* server failure */
#define NXDOMAIN  3   /* non existent domain */
#define NOTIMP    4   /* not implemented */
#define REFUSED   5   /* query refused */
  /* non standard */
#define NOCHANGE  0xf   /* update failed to change db */

/*
 * Type values for resources and queries
 */
#define T_A   1   /* host address */
#define T_NS    2   /* authoritative server */
#define T_MD    3   /* mail destination (obsolete, use T_MX) */
#define T_MF    4   /* mail forwarder (obsolete, use T_MX) */
#define T_CNAME   5   /* connonical name */
#define T_SOA   6   /* start of authority zone */
#define T_MB    7   /* mailbox domain name */
#define T_MG    8   /* mail group member */
#define T_MR    9   /* mail rename name */
#define T_NULL    10    /* null resource record */
#define T_WKS   11    /* well known service */
#define T_PTR   12    /* domain name pointer */
#define T_HINFO   13    /* host information */
#define T_MINFO   14    /* mailbox information */
#define T_MX    15    /* mail routing information */
#define T_TXT   16    /* text strings */
  /* non standard */
#define T_UINFO   100   /* user (finger) information */
#define T_UID   101   /* user ID */
#define T_GID   102   /* group ID */
#define T_UNSPEC  103   /* Unspecified format (binary data) */
  /* Query type values which do not appear in resource records */
#define T_AXFR    252   /* transfer zone of authority */
#define T_MAILB   253   /* transfer mailbox records */
#define T_MAILA   254   /* transfer mail agent records */
#define T_ANY   255   /* wildcard match */

/*
 * Values for class field
 */

#define C_IN    1   /* the arpa internet */
#define C_CHAOS   3   /* for chaos net at MIT */
#define C_HS    4   /* for Hesiod name server at MIT */
  /* Query class values which do not appear in resource records */
#define C_ANY   255   /* wildcard match */

/*
 * Errors from res_xxx
 */

#define HOST_NOT_FOUND 1
#define TRY_AGAIN 2
#define NO_RECOVERY 3
#define NO_ADDRESS 4
#define NO_DATA NO_ADDRESS


/*
 * structs
 */

/* Resource record */
typedef struct
{
  uint	r_zone;     /* zone number */
  uint	r_type;     /* type number */
  uint	r_class;    /* class number */
  ulong	r_ttl;      /* time to live */
  uint  r_size;     /* size of data area */
  char  r_data[0];    /* data */
}rrec;

typedef struct
{
	uint	id;
	byte	val1;
	byte 	val2;
	/* val1 */
	#define QR 128							/* Query (0) or Response (1) */
	#define Opcode (64|32|16|8)	/* See "Currently defined opcodes" */
	#define AA 4								/* This is an Authoritative Answer Yes/No */
	#define TC 2								/* Message is truncated */
	#define RD 1								/* Recursion desired (by client) */
	/* val2 */
	#define RA 128							/* Recursion available (by server) */
	#define Z  (64|32|16)				/* reserved - must be zero */
	#define RCODE (8|4|2|1)			/* See "Currently defined response codes" */
	
	uint qdcount;		/* Following queries (format QNAME/QTYPE/QCLASS) */
	uint ancount;		/* Answers (resource records) */
	uint nscount;		/* Nameservers (resource records) */
	uint arcount;		/* Additional (resource records) */
	
	rrec records[0];
}dns_header;


void res_init(void);
int res_query(char *dname, int class, int type, uchar *answer, int anslen);
int res_search(char *dname, int class, int type, uchar *answer, int anslen);
int res_mkquery(int op, char *dname, int class, int type, char *data, int datalen, void *notused, char *buf, int buflen);
int res_send(char *msg, int msglen, char *answer, int anslen);
int dn_expand(uchar *msg, uchar *eomorig, uchar *comp_dn, uchar *exp_dn, int length);
int dn_comp(uchar *exp_dn, uchar *comp_dn, uchar **dnptrs, uchar **lastdnptr, int length);

#endif