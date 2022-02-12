/*	nonamed 1.7 - not a name daemon, but plays one on TV.
 *							Author: Kees J. Bot
 *								29 Nov 1994
 */

/* Use the file reading gethostent() family of functions. */
#define sethostent	_sethostent
#define endhostent	_endhostent
#define gethostent	_gethostent
#define gethostbyname	_gethostbyname
#define gethostbyaddr	_gethostbyaddr

#define nil 0
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <limits.h>
#include <signal.h>
#include <assert.h>
#include <sys/ioctl.h>
#include <sys/asynchio.h>
#include <net/hton.h>
#include <net/netlib.h>
#include <net/gen/in.h>
#include <net/gen/inet.h>
#include <net/gen/nameser.h>
#include <net/gen/resolv.h>
#include <net/gen/netdb.h>
#include <net/gen/socket.h>
#include <net/gen/tcp.h>
#include <net/gen/tcp_io.h>
#include <net/gen/udp.h>
#include <net/gen/udp_hdr.h>
#include <net/gen/udp_io.h>

#define TTL		3600	/* Time to live for any kind of information. */
#define SHORT_TIMEOUT	   2	/* If you expect an answer soon. */
#define MEDIUM_TIMEOUT	   4	/* Soon, but not that soon. */
#define LONG_TIMEOUT	 300	/* For stream connections to a real named. */
#define N_SEARCHES	   5	/* Send out this many named broadcasts. */
#define N_EXPECTS	   2	/* This many expect timeouts worry us. */
#define N_IDS		 256	/* Keep track of this many queries. */
#define NO_IP	HTONL(0x00000000L)	/* IP address unknown. */
#define NO_FD		(-1)	/* No name daemon channel here. */

unsigned debug= 0;		/* Debug level. */

#define arraysize(a)	(sizeof(a) / sizeof((a)[0]))
#define arraylimit(a)	((a) + arraysize(a))
#define between(a, c, z) ((unsigned) ((c) - (a)) <= (unsigned) ((z) - (a)))

void report(const char *label)
{
	fprintf(stderr, "nonamed: %s: %s\n", label, strerror(errno));
}

void fatal(const char *label)
{
	report(label);
	if (debug >= 3) { fflush(nil); abort(); }
	exit(1);
}

void *allocate(void *mem, size_t size)
{
	if ((mem= mem == nil ? malloc(size) : realloc(mem, size)) == nil)
		fatal("malloc()");
	return mem;
}

void deallocate(void *mem)
{
	if (mem != nil) free(mem);
}

typedef int handler_t(void *data, int expired);

/* All actions are in the form of "jobs". */
typedef struct job {
	struct job	*next, **prev;	/* To make a job queue. */
	handler_t	*handler;	/* Function to handle this job. */
	time_t		timeout;	/* Moment it times out. */
	void		*data;		/* Data associated with the job. */
} job_t;

/* Some jobs don't time out. */
#define NEVER		((time_t) ((time_t) -1 < 0 ? LONG_MAX : ULONG_MAX))

/* Others are immediate. */
#define IMMEDIATE	((time_t) 0)

job_t *queue;		/* Main job queue. */

void newjob(handler_t *handler, time_t timeout, void *data)
/* Create a new job with the given handler, timeout time and data. */
{
	job_t *job, **prev;

	job= allocate(nil, sizeof(*job));
	job->handler= handler;
	job->timeout= timeout;
	job->data= data;

	for (prev= &queue; *prev != nil; prev= &(*prev)->next) {
		if (job->timeout < (*prev)->timeout) break;
	}
	job->next= *prev;
	job->prev= prev;
	*prev= job;
	if (job->next != nil) job->next->prev= &job->next;
}

int execjob(job_t *job, int expired)
/* Execute a job by calling the handler.  Remove the job if it returns true,
 * indicating that it is done.  Expired is set if the job timed out.  It is
 * otherwise called to check for I/O.
 */
{
	if ((*job->handler)(job->data, expired)) {
		*job->prev= job->next;
		if (job->next != nil) job->next->prev= job->prev;
		deallocate(job);
		return 1;
	}
	return 0;
}

void force_expire(handler_t *handler)
/* Force jobs to expire immediately, the named searcher for instance. */
{
	job_t *job, **prev= &queue;

	while ((job= *prev) != nil) {
		if (job->handler == handler && job->timeout != IMMEDIATE) {
			*prev= job->next;
			if (job->next != nil) job->next->prev= prev;
			newjob(job->handler, IMMEDIATE, job->data);
			deallocate(job);
		} else {
			prev= &job->next;
		}
	}
}

char *itoa(char *fmt, u32_t i)
{
	static char output[32 + 3 * sizeof(i)];

	sprintf(output, fmt, (unsigned long) i);
	return output;
}

void pack16(u8_t *buf, u16_t s)
/* Pack a 16 bit value into a byte array. */
{
	buf[0]= ((u8_t *) &s)[0];
	buf[1]= ((u8_t *) &s)[1];
}

void pack32(u8_t *buf, u32_t l)
/* Pack a 32 bit value into a byte array. */
{
	buf[0]= ((u8_t *) &l)[0];
	buf[1]= ((u8_t *) &l)[1];
	buf[2]= ((u8_t *) &l)[2];
	buf[3]= ((u8_t *) &l)[3];
}

u16_t upack16(u8_t *buf)
/* Unpack a 16 bit value in network byte order from a byte array. */
{
	u16_t s;

	((u8_t *) &s)[0]= buf[0];
	((u8_t *) &s)[1]= buf[1];
	return s;
}

u32_t upack32(u8_t *buf)
/* Unpack a 32 bit value in network byte order from a byte array. */
{
	u32_t l;

	((u8_t *) &l)[0]= buf[0];
	((u8_t *) &l)[1]= buf[1];
	((u8_t *) &l)[2]= buf[2];
	((u8_t *) &l)[3]= buf[3];
	return l;
}

void dns_tell(u8_t *buf, size_t size)
/* Explain a DNS packet, for debug purposes. */
{
	dns_hdr_t *hp= (dns_hdr_t *) buf;
	u8_t *cp, *end;
	int r, i, j;
	u16_t type, class, rdlength;
	u32_t ttl;
	u8_t name[MAXDNAME];
	u16_t counts[3];
	static char labels[3][4]= { "AN:", "NS:", "AR:" };

	if (size < sizeof(dns_hdr_t)) return;

	printf("DNS %s:", (hp->dh_flag1 & DHF_QR) ? "reply" : "query");
	r= hp->dh_flag2 & DHF_RCODE;
	printf(" %s", r == NOERROR ? "NOERROR" :
			r == FORMERR ? "FORMERR" :
			r == SERVFAIL ? "SERVFAIL" :
			r == NXDOMAIN ? "NXDOMAIN" :
			r == NOTIMP ? "NOTIMP" :
			r == REFUSED ? "REFUSED" : itoa("ERR_%lu", r));
	if (hp->dh_flag1 & DHF_AA) printf(" AA");
	if (hp->dh_flag1 & DHF_TC) printf(" TC");
	if (hp->dh_flag1 & DHF_RD) printf(" RD");
	if (hp->dh_flag1 & DHF_RA) printf(" RA");
	if (hp->dh_flag1 & DHF_PR) printf(" PR");
	fputc('\n', stdout);
	cp = buf + sizeof(dns_hdr_t);
	end= buf + size;
	for (i= 0; i < ntohs(hp->dh_qdcount); i++) {
		r= dn_expand(buf, end, cp, name, MAXDNAME);
		if (r == -1) return;
		cp+= r;
		if (cp + 2 * sizeof(u16_t) > end) return;
		type= ntohs(upack16(cp));
		cp+= sizeof(u16_t);
		class= ntohs(upack16(cp));
		cp+= sizeof(u16_t);
		printf("  QD: %-20s", (char *) name);
		printf(" %3s", class == C_IN ? "IN" : itoa("C_%lu", class));
		printf(" %3s\n", type == T_A ? "A" :
				type == T_MX ? "MX" :
				type == T_NS ? "NS" :
				type == T_ANY ? "ANY" :
				type == T_PTR ? "PTR" : itoa("T_%lu", type));
	}
	counts[0]= ntohs(hp->dh_ancount);
	counts[1]= ntohs(hp->dh_nscount);
	counts[2]= ntohs(hp->dh_arcount);
	for (i= 0; i < 3; i++) {
		for (j= 0; j < counts[i]; j++) {
			r= dn_expand(buf, end, cp, name, MAXDNAME);
			if (r == -1) return;
			cp+= r;
			type= ntohs(upack16(cp));
			cp+= sizeof(u16_t);
			class= ntohs(upack16(cp));
			cp+= sizeof(u16_t);
			ttl= ntohl(upack32(cp));
			cp+= sizeof(u32_t);
			rdlength= ntohs(upack16(cp));
			cp+= sizeof(u16_t);
			printf("  %s %-20s", labels[i], (char *) name);
			printf(" %6lu", ttl);
			printf(" %3s", class == C_IN ? "IN" :
						itoa("C_%lu", class));
			printf(" %3s", type == T_A ? "A" :
					type == T_MX ? "MX" :
					type == T_NS ? "NS" :
					type == T_ANY ? "ANY" :
					type == T_PTR ? "PTR" :
						itoa("T_%lu", type));
			if (type == T_PTR || type == T_NS) {
				r= dn_expand(buf, end, cp, name, MAXDNAME);
				if (r == -1) strcpy((char *) name, "???");
				printf("  %s\n", (char *) name);
			} else
			if (type == T_A && rdlength == sizeof(ipaddr_t)) {
				printf("  %s\n", inet_ntoa(upack32(cp)));
			} else
			if (type == T_MX) {
				printf("  %5u", ntohs(upack16(cp)));
				r= dn_expand(buf, end, cp + sizeof(u16_t),
							name, MAXDNAME);
				if (r == -1) strcpy((char *) name, "???");
				printf("  %s\n", (char *) name);
			} else {
				printf("  ...\n");
			}
			cp+= rdlength;
		}
	}
}

int dns_decode(u8_t *buf, size_t size, u8_t *name)
/* Decode a DNS message, but only if it is an "IN" or "IN" query.  Return
 * -1 on error, 0 if can't be answered, and the query type if it may possibly
 * be answered.  In the latter case the name array is filled with the null
 * terminated name whose address is queried.  Name must be MAXDNAME+1 bytes.
 */
{
	dns_hdr_t *hp= (dns_hdr_t *) buf;
	u8_t *cp, *end;
	int r;
	u16_t qtype, qclass;

	if (size < sizeof(dns_hdr_t)) return -1;

	if ((hp->dh_flag1 & DHF_QR) != 0) return 0;
	if ((hp->dh_flag1 & DHF_OPCODE) != (QUERY << 3)) return 0;
	if ((hp->dh_flag1 & DHF_TC) != 0) return 0;
	if (ntohs(hp->dh_qdcount) != 1) return 0;	/* ? */
	if (ntohs(hp->dh_ancount) != 0) return 0;
	if (ntohs(hp->dh_nscount) != 0) return 0;
	if (ntohs(hp->dh_arcount) != 0) return 0;

	cp = buf + sizeof(dns_hdr_t);
	end= buf + size;
	r= dn_expand(buf, end, cp, name, MAXDNAME);
	if (r == -1) return -1;
	cp+= r;
	if (cp + 2 * sizeof(u16_t) > end) return -1;
	qtype= upack16(cp);
	cp+= sizeof(u16_t);
	qclass= upack16(cp);
	cp+= sizeof(u16_t);
	if (qclass != HTONS(C_IN)) return 0;
	return ntohs(qtype);
}

ipaddr_t arpa_addr(u8_t *name)
/* Change a name in the ARPA domain to an IP address. */
{
	u8_t octets[4];
	int i, d;

	/* Expect four dot separated decimal numbers and a dot. */
	for (i= 0; i < 4; i++) {
		d= 0;
		do {
			if (!between('0', *name, '9')) return NO_IP;
			d= 10*d + (*name++ - '0');
			if (d > 0xFF) return NO_IP;
		} while (between('0', *name, '9'));
		if (*name++ != '.') return NO_IP;
		octets[i]= d;
	}
	if (strcasecmp((char *) name, "IN-ADDR.ARPA") != 0) return NO_IP;

	return htonl(	  ((ipaddr_t) octets[0] <<  0)
			| ((ipaddr_t) octets[1] <<  8)
			| ((ipaddr_t) octets[2] << 16)
			| ((ipaddr_t) octets[3] << 24));
}

typedef struct id2id {
	u16_t		id;		/* ID of old query. */
	u16_t		port;		/* Reply port. */
	ipaddr_t	ip;		/* Reply address. */
} id2id_t;

id2id_t id2id[N_IDS];
u16_t id_counter;

u16_t new_id(u16_t in_id, u16_t in_port, ipaddr_t in_ip)
/* An incoming UDP query must be relabeled with a new ID before it can be
 * send on to a real name daemon.
 */
{
	static int init;
	id2id_t *idp;
	u16_t id;

	if (!init) {
		for (idp= id2id; idp < arraylimit(id2id); idp++) idp->ip= NO_IP;
		init= 1;
	}
	id= id_counter++;
	idp= &id2id[id % N_IDS];
	idp->id= in_id;
	idp->port= in_port;
	idp->ip= in_ip;
	return htons(id);
}

int old_id(u16_t id, u16_t *out_id, u16_t *out_port, ipaddr_t *out_ip)
/* Translate an reply id back to the id, port, and address used in the query.
 * Return true if the translation is possible.
 */
{
	id= ntohs(id);
	if ((u16_t) (id_counter - id) > N_IDS) {
		/* Too old. */
		return 0;
	} else {
		/* We know this one. */
		id2id_t *idp= &id2id[id % N_IDS];

		if (idp->ip == NO_IP) return 0;
		*out_id= idp->id;
		*out_port= idp->port;
		*out_ip= idp->ip;
		return 1;
	}
}

char *tcp_device, *udp_device;		/* TCP and UDP device names. */
int udp_fd;				/* To send or receive UDP packets. */
time_t now;				/* Current time. */
asynchio_t asyn;			/* For I/O in progress. */
ipaddr_t named_ip = NO_IP;		/* Address of a real name server. */
int search_ct= -1;			/* Real named search status. */
int do_fail;				/* Do failure replies if true. */
int expect_ct= 0;			/* Goes up when expecting answers. */
ipaddr_t my_ip;				/* IP address of this machine. */
u16_t my_port, named_port;		/* Port numbers, normally "domain". */

#define searching()		(search_ct > 0)
#define start_searching()	((void) (search_ct= -1))
#define stop_searching()	((void) (search_ct= 0))
#define expecting()		(expect_ct > 0)
#define start_expect()		((void) (expect_ct= N_EXPECTS))
#define stop_expect()		((void) (expect_ct= 0))

handler_t job_setup_listen, job_listen, job_setup_connect, job_connect;
handler_t job_read_udp, job_read_query, job_write_query, job_read_reply;
handler_t job_write_query, job_write_reply, job_find_named, job_expect_named;

typedef struct data_cl {	/* Data for connect or listen jobs. */
	int		fd;		/* Open TCP channel. */
	int		dn_fd;		/* TCP channel to the name daemon. */
	int		retry;		/* Retrying a connect? */
	nwio_tcpcl_t	tcpcl;		/* Flags. */
} data_cl_t;

typedef struct data_rw {	/* Data for TCP read or write jobs. */
	int		r_fd;		/* Read from this TCP channel. */
	int		w_fd;		/* And write to this TCP channel. */
	struct data_rw	*rev;		/* Optional reverse TCP channel. */
	u8_t		*buf;		/* Buffer for bytes to transfer. */
	ssize_t		offset;		/* Offset in buf to r/w at. */
	size_t		size;		/* Size of buf. */
} data_rw_t;

void named_search(void)
/* Start a search for a new name daemon. */
{
	if (named_ip != NO_IP) {
		/* Forget the current name daemon if there is a hosts file
		 * with a "localhost" entry.
		 */
		struct hostent *he;
		ipaddr_t ip;

		while ((he= gethostent()) != nil) {
			memcpy(&ip, he->h_addr, sizeof(ip));
			if ((ntohl(ip) & 0xFF000000L) == 0x7F000000L) {
				do_fail= 0;
				named_ip= NO_IP;
			}
		}
		endhostent();
	}
	start_searching();
	force_expire(job_find_named);
}

#if __minix_vmd
int job_setup_listen(void *data, int expired)
/* Set up a listening channel for TCP DNS queries. */
{
	data_cl_t *data_cl= data;
	nwio_tcpconf_t tcpconf;
	nwio_tcpopt_t tcpopt;
	int fd;

	if (!expired) return 0;
	if (debug >= 2) printf(": Setup listen\n");

	if (data_cl == nil) {
		if ((fd= open(tcp_device, O_RDWR)) < 0) {
			if (errno != EMFILE) report(tcp_device);
			newjob(job_setup_listen, now + SHORT_TIMEOUT, nil);
			return 1;
		}

		tcpconf.nwtc_flags= NWTC_SHARED | NWTC_LP_SET | NWTC_UNSET_RA
							| NWTC_UNSET_RP;
		tcpconf.nwtc_locport= my_port;
		if (ioctl(fd, NWIOSTCPCONF, &tcpconf) == -1) fatal(tcp_device);

		tcpopt.nwto_flags= NWTO_DEL_RST;
		if (ioctl(fd, NWIOSTCPOPT, &tcpopt) == -1) fatal(tcp_device);

		data_cl= allocate(nil, sizeof(*data_cl));
		data_cl->fd= fd;
		data_cl->tcpcl.nwtcl_flags= 0;
	}
	/* And listen. */
	newjob(job_listen, NEVER, data_cl);
	return 1;
}

int job_listen(void *data, int expired)
/* A connection on the TCP DNS query channel. */
{
	data_cl_t *data_cl= data;

	/* Wait for a client. */
	if (asyn_ioctl(&asyn, data_cl->fd, NWIOTCPLISTEN, &data_cl->tcpcl) < 0)
	{
		if (errno == EINPROGRESS) return 0;
		report(tcp_device);

		/* Try again after a short time. */
		newjob(job_setup_listen, now + SHORT_TIMEOUT, data_cl);
		return 1;
	}
	if (debug >= 2) printf(": Listen\n");

	/* Immediately resume listening. */
	newjob(job_setup_listen, IMMEDIATE, nil);

	/* Set up a connect to the real name daemon in one second. */
	data_cl->retry= 0;
	newjob(job_setup_connect, IMMEDIATE, data_cl);
	return 1;
}

void start_relay(int fd, int dn_fd)
/* Start one or two read jobs after job_setup_connect() or job_connect(). */
{
	data_rw_t *query;	/* Client to DNS daemon relay. */
	data_rw_t *reply;	/* DNS daemon to client relay. */

	query= allocate(nil, sizeof(*query));
	query->r_fd= fd;
	query->buf= allocate(nil, sizeof(u16_t));
	query->offset= 0;
	query->size= sizeof(u16_t);
	if (dn_fd == NO_FD) {
		/* Answer mode. */
		query->w_fd= fd;
		query->rev= nil;
	} else {
		/* Relay mode. */
		reply= allocate(nil, sizeof(*reply));
		reply->r_fd= dn_fd;
		reply->w_fd= fd;
		reply->buf= allocate(nil, sizeof(u16_t));
		reply->offset= 0;
		reply->size= sizeof(u16_t);
		reply->rev= query;
		query->w_fd= dn_fd;
		query->rev= reply;
		newjob(job_read_reply, now + LONG_TIMEOUT, reply);
	}
	newjob(job_read_query, now + LONG_TIMEOUT, query);
}

void close_relay(data_rw_t *data_rw)
/* Close a relay channel. */
{
	if (data_rw->rev != nil) {
		/* Other end still active, signal EOF. */
		(void) ioctl(data_rw->w_fd, NWIOTCPSHUTDOWN, nil);
		data_rw->rev->rev= nil;
	} else {
		/* Close both ends down. */
		asyn_close(&asyn, data_rw->r_fd);
		close(data_rw->r_fd);
		if (data_rw->w_fd != data_rw->r_fd) {
			asyn_close(&asyn, data_rw->w_fd);
			close(data_rw->w_fd);
		}
	}
	deallocate(data_rw->buf);
	deallocate(data_rw);
}

int job_setup_connect(void *data, int expired)
/* Set up a connect for a TCP channel to the real name daemon. */
{
	nwio_tcpconf_t tcpconf;
	int dn_fd;
	data_cl_t *data_cl= data;

	if (!expired) return 0;
	if (debug >= 2) printf(": Setup connect\n");

	if (named_ip == NO_IP) {
		if (searching()) {
			/* Wait for a name daemon to be found. */
			newjob(job_setup_connect, NEVER, data_cl);
			return 1;
		}
		/* Continue with the read job. */
		start_relay(data_cl->fd, NO_FD);
		deallocate(data_cl);
		return 1;
	}

	if ((dn_fd= open(tcp_device, O_RDWR)) < 0) {
		if (errno != EMFILE) report(tcp_device);
		if (++data_cl->retry < 5) {
			/* Retry. */
			newjob(job_setup_connect, now + SHORT_TIMEOUT, data_cl);
		} else {
			/* Reply myself (bound to fail). */
			start_relay(data_cl->fd, NO_FD);
			deallocate(data_cl);
		}
		return 1;
	}

	tcpconf.nwtc_flags= NWTC_LP_SEL | NWTC_SET_RA | NWTC_SET_RP;
	tcpconf.nwtc_remaddr= named_ip;
	tcpconf.nwtc_remport= named_port;
	if (ioctl(dn_fd, NWIOSTCPCONF, &tcpconf) == -1) fatal(tcp_device);

	/* And connect. */
	data_cl->dn_fd= dn_fd;
	data_cl->tcpcl.nwtcl_flags= 0;
	newjob(job_connect, NEVER, data_cl);
	return 1;
}

int job_connect(void *data, int expired)
/* Connect to a TCP DNS query channel. */
{
	data_cl_t *data_cl= data;

	/* Try to connect. */
	if (asyn_ioctl(&asyn, data_cl->dn_fd, NWIOTCPCONN, &data_cl->tcpcl) < 0)
	{
		if (errno == EINPROGRESS) return 0;
		if (errno == EIO) fatal(tcp_device);

		/* Connection refused. */
		if (debug >= 2) printf(": Connect: %s\n", strerror(errno));
		asyn_close(&asyn, data_cl->dn_fd);
		close(data_cl->dn_fd);
		data_cl->dn_fd= NO_FD;
		if (++data_cl->retry < 5) {
			/* Search a new name daemon. */
			if (!searching()) named_search();
			newjob(job_setup_connect, NEVER, data_cl);
			return 1;
		}
		/* Reply with a failure eventually. */
	}
	if (debug >= 2) printf(": Connect\n");

	/* Read the query from the user, send on to the name daemon, etc. */
	start_relay(data_cl->fd, data_cl->dn_fd);
	deallocate(data_cl);
	return 1;
}
#else /* !__minix_vmd */

int job_dummy(void *data, int expired)
{
	return 1;
}
#define job_setup_listen	job_dummy
#define job_setup_connect	job_dummy
#endif /* !__minix_vmd */

size_t compose_reply(u8_t *qbuf, size_t qsize, u8_t *rbuf, size_t rsize)
/* Build a reply message in rbuf as answer to the query in qbuf. */
{
	dns_hdr_t *qhp= (dns_hdr_t *) qbuf;
	dns_hdr_t *rhp= (dns_hdr_t *) rbuf;
	u8_t *cp0, *cp= (u8_t *) (rhp + 1);
	u8_t *dnptrs[32];
	struct hostent *he;
	u8_t name[MAXDNAME+1];
	int r;
	u16_t qtype;
	ipaddr_t ip;
	char *dot;

	rhp->dh_id= qhp->dh_id;
	rhp->dh_flag1= (qhp->dh_flag1 | DHF_QR | DHF_AA) & ~(DHF_TC);
	rhp->dh_flag2= (qhp->dh_flag2)
			& ~(DHF_RA | DHF_PR | DHF_UNUSED | DHF_RCODE);
	rhp->dh_qdcount= HTONS(0);
	rhp->dh_ancount= HTONS(0);
	rhp->dh_nscount= HTONS(0);
	rhp->dh_arcount= HTONS(0);
	dnptrs[0]= (u8_t *) rhp;
	dnptrs[1]= nil;

	/* Check and decode the query. */
	r= dns_decode(qbuf, qsize, name);

	if (r <= 0) {
		rhp->dh_flag2|= (r == 0 ? NOTIMP : FORMERR);
		return sizeof(*rhp);
	}

	qtype= r;
	/* Repeat the question in the answer. */
	r= dn_comp(name, cp, rsize - (rbuf - cp), dnptrs, arraylimit(dnptrs));
	if (r == -1) {
		rhp->dh_flag2 |= FORMERR;
		return sizeof(*rhp);
	}
	cp+= r;
	pack16(cp, htons(qtype));
	cp+= sizeof(u16_t);
	pack16(cp, HTONS(C_IN));
	cp+= sizeof(u16_t);
	rhp->dh_qdcount= HTONS(1);

	if (qtype == T_PTR) {
		/* Reverse lookup. */
		he= nil;
		if ((ip= arpa_addr(name)) != NO_IP)
			he= gethostbyaddr((char *) &ip, sizeof(ip), AF_INET);
	} else
	if ((he= gethostbyname((char *) name)) != nil) {
		/* Normal name match. */
		;
	} else
	if ((dot= strchr((char *) name, '.')) != nil) {
		/* We are desparate for a match; strip the domain. */
		char domain[MAXDNAME];

		*dot= 0;
		if (getdomainname(domain, sizeof(domain)) != -1
					&& strcasecmp(dot+1, domain) == 0) {
			he= gethostbyname((char *) name);
		}
		*dot= '.';
	}
	if (he == nil) {
		rhp->dh_flag2 |= NXDOMAIN;
		return cp - rbuf;
	}
	if (qtype != T_PTR && qtype != T_A && qtype != T_ANY) {
		/* Succeed, but the answer is empty. */
		return cp - rbuf;
	}
	/* Make an answer that looks one of these two:
	 *   42.231.31.192.in-addr.arpa  3600  IN  PTR  star.cs.vu.nl
	 *   star.cs.vu.nl               3600  IN    A  192.31.231.42
	 */
	r= dn_comp(name, cp, rsize - (rbuf - cp), dnptrs, arraylimit(dnptrs));
	if (r == -1) {
		rhp->dh_flag2 |= FORMERR;
		return cp - rbuf;
	}
	cp0= cp;
	cp+= r;
	pack16(cp, qtype == T_PTR ? HTONS(T_PTR) : HTONS(T_A));
	cp+= sizeof(u16_t);
	pack16(cp, HTONS(C_IN));
	cp+= sizeof(u16_t);
	pack32(cp, HTONL((long) TTL));
	cp+= sizeof(u32_t);
	if (qtype == T_PTR) {
		r= dn_comp((u8_t *) he->h_name,
			cp + sizeof(u16_t),
			rsize - sizeof(u16_t) - (rbuf - cp),
			dnptrs, arraylimit(dnptrs));
		if (r == -1) {
			rhp->dh_flag2 |= FORMERR;
			return cp0 - rbuf;
		}
		pack16(cp, htons(r));
		cp+= sizeof(u16_t) + r;
	} else {
		/* T_A */
		pack16(cp, HTONS(sizeof(u32_t)));
		cp+= sizeof(u16_t);
		memcpy(cp, he->h_addr, sizeof(u32_t));
		cp+= sizeof(u32_t);
	}
	rhp->dh_ancount= HTONS(1);
	return cp - rbuf;
}

/* Max DNS datagram with UDP header. */
#define UDP_PACKETSZ	(sizeof(udp_io_hdr_t) + PACKETSZ)

int job_read_udp(void *data, int expired)
/* Read UDP queries and replies. */
{
	ssize_t count;
	static union {
		udp_io_hdr_t hdr;
		char buf[UDP_PACKETSZ];
	} u;
	dns_hdr_t *hp;
	u16_t id, port;
	ipaddr_t ip;

	assert(!expired);

	/* Try to read a packet. */
	count= asyn_read(&asyn, udp_fd, u.buf, UDP_PACKETSZ);

	if (count < 0) {
		if (errno == EINPROGRESS && !expired) return 0;
		if (errno == EIO) fatal(tcp_device);

		if (debug >= 2) printf(": UDP read: %s\n", strerror(errno));
	} else {
		if (debug >= 2) {
			printf(": UDP read, %d bytes\n",
						count - sizeof(udp_io_hdr_t));
		}
	}
	/* Restart job no matter what. */
	newjob(job_read_udp, NEVER, nil);

	if (count < (ssize_t) (sizeof(udp_io_hdr_t) + sizeof(dns_hdr_t)))
		return 1;

	hp= (dns_hdr_t *) (&u.hdr + 1);

	if (debug >= 1) {
		printf("%s/%u UDP ", inet_ntoa(u.hdr.uih_src_addr),
					ntohs(u.hdr.uih_src_port));
		dns_tell((u8_t *) hp, count - sizeof(udp_io_hdr_t));
	}

	if (hp->dh_flag1 & DHF_QR) {
		/* This is a remote named reply, not a query. */

		if (expecting()) {
			stop_expect();
			force_expire(job_expect_named);
		}

		/* Response to a query once relayed? */
		if (!old_id(hp->dh_id, &id, &port, &ip)) return 1;

		if (port == my_port && ip == my_ip) {
			/* We have found a name server! */
			if (searching()) {
				named_ip= u.hdr.uih_src_addr;
				if (debug >= 1) {
					printf("Real named = %s\n",
							inet_ntoa(named_ip));
				}
				stop_searching();
				force_expire(job_find_named);
				force_expire(job_setup_connect);
			}
			return 1;
		}

		/* Send the reply to the process that asked for it. */
		hp->dh_id= id;
		u.hdr.uih_src_addr= my_ip;
		u.hdr.uih_dst_addr= ip;
		u.hdr.uih_src_port= my_port;
		u.hdr.uih_dst_port= port;
		if (debug >= 1) {
			printf("To client %s/%u\n", inet_ntoa(ip),
							ntohs(port));
		}
		if (write(udp_fd, u.buf, count) < 0) fatal(udp_device);
	} else
	if (named_ip != NO_IP) {
		/* We have a real name daemon to handle the query. */
		id= new_id(hp->dh_id, u.hdr.uih_src_port, u.hdr.uih_src_addr);
		hp->dh_id= id;
		u.hdr.uih_src_addr= my_ip;
		u.hdr.uih_dst_addr= named_ip;
		u.hdr.uih_src_port= my_port;
		u.hdr.uih_dst_port= named_port;
		if (debug >= 1) {
			printf("To named %s/%u\n", inet_ntoa(named_ip),
							ntohs(named_port));
		}
		if (write(udp_fd, u.buf, count) < 0) fatal(udp_device);
		if (!expecting()) {
			start_expect();
			newjob(job_expect_named, now + MEDIUM_TIMEOUT, nil);
		}
	} else {
		/* No real name daemon around, so use the hosts file. */
		u8_t rbuf[UDP_PACKETSZ + 32];
		size_t rsize;
		udp_io_hdr_t *rhdr= (udp_io_hdr_t *) rbuf;
		dns_hdr_t *rhp= (dns_hdr_t *) (rhdr + 1);

		/* Build a reply packet. */
		rsize= compose_reply((u8_t *) hp,
					count - sizeof(udp_io_hdr_t),
					rbuf + sizeof(udp_io_hdr_t),
					PACKETSZ);

		rhdr->uih_src_addr= my_ip;
		rhdr->uih_dst_addr= u.hdr.uih_src_addr;
		rhdr->uih_src_port= my_port;
		rhdr->uih_dst_port= u.hdr.uih_src_port;
		rhdr->uih_ip_opt_len= 0;
		rhdr->uih_data_len= rsize;

		/* Don't send failure messages at startup. */
		if (!do_fail && (rhp->dh_flag2 & DHF_RCODE) != 0)
			return 1;

		/* Send a DNS reply. */
		if (debug >= 1) {
			printf("%s/%u UDP ", inet_ntoa(rhdr->uih_dst_addr),
						ntohs(rhdr->uih_dst_port));
			dns_tell(rbuf + sizeof(udp_io_hdr_t), rsize);
		}
		if (write(udp_fd, rbuf, sizeof(udp_io_hdr_t) + rsize) < 0)
			fatal(udp_device);
	}
	return 1;
}

#if __minix_vmd
char *tcp_dns_tell(int fd, u8_t *buf)
/* Tell about a DNS packet on a TCP channel. */
{
	nwio_tcpconf_t tcpconf;

	if (ioctl(fd, NWIOGTCPCONF, &tcpconf) < 0) {
		printf("??\?/?? TCP ");
	} else {
		printf("%s/%u TCP ", inet_ntoa(tcpconf.nwtc_remaddr),
					ntohs(tcpconf.nwtc_remport));
	}
	dns_tell(buf + sizeof(u16_t), ntohs(upack16(buf)));
}

int job_read_query(void *data, int expired)
/* Read TCP queries. */
{
	data_rw_t *data_rw= data;
	ssize_t count;
	dns_hdr_t *hp;

	/* Try to read count bytes. */
	count= asyn_read(&asyn, data_rw->r_fd,
				data_rw->buf + data_rw->offset,
				data_rw->size - data_rw->offset);

	if (count < 0) {
		if (errno == EINPROGRESS && !expired) return 0;
		if (errno == EIO) fatal(tcp_device);

		/* Remote end is late, or an error occurred. */
		if (debug >= 2)
			printf(": TCP read query: %s\n", strerror(errno));
		close_relay(data_rw);
		return 1;
	}

	if (debug >= 2) {
		printf(": TCP read query, %d/%u bytes\n",
				data_rw->offset + count, data_rw->size);
	}
	if (count == 0) {
		/* EOF. */
		close_relay(data_rw);
		return 1;
	}
	data_rw->offset+= count;
	if (data_rw->offset == data_rw->size) {
		data_rw->size= sizeof(u16_t) + ntohs(upack16(data_rw->buf));
		if (data_rw->size < sizeof(u16_t)) {
			/* Malformed. */
			close_relay(data_rw);
			return 1;
		}
		if (data_rw->offset < data_rw->size) {
			/* Query not complete, read more. */
			data_rw->buf= allocate(data_rw->buf, data_rw->size);
			newjob(job_read_query, now + LONG_TIMEOUT, data_rw);
			return 1;
		}
	}
	if (debug >= 1) tcp_dns_tell(data_rw->r_fd, data_rw->buf);

	/* Relay or reply. */
	count= data_rw->size;
	hp= (dns_hdr_t *) (data_rw->buf + sizeof(u16_t));

	if (count < sizeof(u16_t) + sizeof(dns_hdr_t)) {
		close_relay(data_rw);
		return 1;
	}

	if (data_rw->w_fd != data_rw->r_fd) {
		/* We have a real name daemon to do the work. */
		data_rw->offset= 0;
		newjob(job_write_query, now + LONG_TIMEOUT, data_rw);
	} else {
		/* No real name daemon around, so use the hosts file. */
		u8_t rbuf[sizeof(u16_t) + PACKETSZ + 32];

		/* Build a reply packet. */
		count= compose_reply((u8_t *) hp,
					count - sizeof(u16_t),
					rbuf + sizeof(u16_t),
					PACKETSZ);

		pack16(rbuf, htons(count));

		/* Start a reply write. */
		data_rw->size= sizeof(u16_t) + count;
		data_rw->buf= allocate(data_rw->buf, data_rw->size);
		memcpy(data_rw->buf, rbuf, data_rw->size);
		data_rw->offset= 0;
		newjob(job_write_reply, now + LONG_TIMEOUT, data_rw);
	}
	return 1;
}

int job_write_query(void *data, int expired)
/* Relay a TCP query to the name daemon. */
{
	data_rw_t *data_rw= data;
	ssize_t count;

	/* Try to write count bytes to the name daemon. */
	count= asyn_write(&asyn, data_rw->w_fd,
				data_rw->buf + data_rw->offset,
				data_rw->size - data_rw->offset);

	if (count <= 0) {
		if (errno == EINPROGRESS && !expired) return 0;
		if (errno == EIO) fatal(tcp_device);

		/* A write expired or failed (usually a broken connection.) */
		if (debug >= 2)
			printf(": TCP write query: %s\n", strerror(errno));
		close_relay(data_rw);
		return 1;
	}

	if (debug >= 2) {
		printf(": TCP write query, %d/%u bytes\n",
				data_rw->offset + count, data_rw->size);
	}
	data_rw->offset+= count;
	if (data_rw->offset < data_rw->size) {
		/* Partial write, continue. */
		newjob(job_write_query, now + LONG_TIMEOUT, data_rw);
		return 1;
	}
	if (debug >= 1) tcp_dns_tell(data_rw->w_fd, data_rw->buf);

	/* Query fully send on, go read more queries. */
	data_rw->offset= 0;
	data_rw->size= sizeof(u16_t);
	newjob(job_read_query, now + LONG_TIMEOUT, data_rw);
	return 1;
}

int job_read_reply(void *data, int expired)
/* Real a TCP reply from the real name daemon. */
{
	data_rw_t *data_rw= data;
	ssize_t count;

	/* Try to read count bytes. */
	count= asyn_read(&asyn, data_rw->r_fd,
				data_rw->buf + data_rw->offset,
				data_rw->size - data_rw->offset);

	if (count < 0) {
		if (errno == EINPROGRESS && !expired) return 0;
		if (errno == EIO) fatal(tcp_device);

		/* Remote end is late, or an error occurred. */
		if (debug >= 2)
			printf(": TCP read reply: %s\n", strerror(errno));
		close_relay(data_rw);
		return 1;
	}

	if (debug >= 2) {
		printf(": TCP read reply, %d/%u bytes\n",
				data_rw->offset + count, data_rw->size);
	}
	if (count == 0) {
		/* EOF. */
		close_relay(data_rw);
		return 1;
	}
	data_rw->offset+= count;
	if (data_rw->offset == data_rw->size) {
		data_rw->size= sizeof(u16_t) + ntohs(upack16(data_rw->buf));
		if (data_rw->size < sizeof(u16_t)) {
			/* Malformed. */
			close_relay(data_rw);
			return 1;
		}
		if (data_rw->offset < data_rw->size) {
			/* Reply not complete, read more. */
			data_rw->buf= allocate(data_rw->buf, data_rw->size);
			newjob(job_read_reply, now + LONG_TIMEOUT, data_rw);
			return 1;
		}
	}
	if (debug >= 1) tcp_dns_tell(data_rw->r_fd, data_rw->buf);

	/* Reply fully read, send it on. */
	data_rw->offset= 0;
	newjob(job_write_reply, now + LONG_TIMEOUT, data_rw);
	return 1;
}

int job_write_reply(void *data, int expired)
/* Send a TCP reply to the client. */
{
	data_rw_t *data_rw= data;
	ssize_t count;

	/* Try to write count bytes to the client. */
	count= asyn_write(&asyn, data_rw->w_fd,
				data_rw->buf + data_rw->offset,
				data_rw->size - data_rw->offset);

	if (count <= 0) {
		if (errno == EINPROGRESS && !expired) return 0;
		if (errno == EIO) fatal(tcp_device);

		/* A write expired or failed (usually a broken connection.) */
		if (debug >= 2)
			printf(": TCP write reply: %s\n", strerror(errno));
		close_relay(data_rw);
		return 1;
	}

	if (debug >= 2) {
		printf(": TCP write reply, %d/%u bytes\n",
				data_rw->offset + count, data_rw->size);
	}
	data_rw->offset+= count;
	if (data_rw->offset < data_rw->size) {
		/* Partial write, continue. */
		newjob(job_write_reply, now + LONG_TIMEOUT, data_rw);
		return 1;
	}
	if (debug >= 1) tcp_dns_tell(data_rw->w_fd, data_rw->buf);

	/* Reply fully send on, go read more replies (or queries). */
	data_rw->offset= 0;
	data_rw->size= sizeof(u16_t);
	newjob(data_rw->w_fd != data_rw->r_fd
			? job_read_reply : job_read_query,
				now + LONG_TIMEOUT, data_rw);
	return 1;
}
#endif /* __minix_vmd */

void named_probe(ipaddr_t ip)
/* Probe a name daemon, either direct or by broadcast. */
{
	u8_t udp_buf[sizeof(udp_io_hdr_t) + PACKETSZ];
	udp_io_hdr_t *udp_hdr= (udp_io_hdr_t *) udp_buf;
	dns_hdr_t *dns_hdr= (dns_hdr_t *) (udp_hdr + 1);
	u8_t *cp= (u8_t *) (dns_hdr + 1);
	int len;

	/* Send a simple DNS query that all name servers can answer easily:
	 * "What are the name servers for the root domain?"
	 */
	dns_hdr->dh_id= new_id(0, my_port, my_ip);
	dns_hdr->dh_flag1= 0;
	dns_hdr->dh_flag2= 0;
	dns_hdr->dh_qdcount= HTONS(1);
	dns_hdr->dh_ancount= HTONS(0);
	dns_hdr->dh_nscount= HTONS(0);
	dns_hdr->dh_arcount= HTONS(0);

	*cp++= 0;	/* Null name. */
	pack16(cp, HTONS(T_NS));
	cp+= sizeof(u16_t);
	pack16(cp, HTONS(C_IN));
	cp+= sizeof(u16_t);
	if (debug >= 1) {
		printf("PROBE %s ", inet_ntoa(ip));
		dns_tell((u8_t *) dns_hdr, cp - (u8_t *) dns_hdr);
	}

	udp_hdr->uih_src_addr= my_ip;
	udp_hdr->uih_dst_addr= ip;
	udp_hdr->uih_src_port= my_port;
	udp_hdr->uih_dst_port= named_port;
	udp_hdr->uih_ip_opt_len= 0;
	udp_hdr->uih_data_len= cp - udp_buf - sizeof(*udp_hdr);

	if (write(udp_fd, udp_buf, cp - udp_buf) < 0) fatal(udp_device);
}

int job_find_named(void *data, int expired)
/* Look for a real name daemon to answer real DNS queries. */
{
	if (!expired) return 0;
	if (debug >= 2) printf(": Find named\n");

	/* New search? */
	if (search_ct < 0) search_ct= N_SEARCHES;

	if (--search_ct < 0) {
		/* End of search.  Failure replies may be sent if we didn't
		 * find a name daemon.  Search again after a long time.
		 */
		do_fail= 1;
		newjob(job_find_named, now + TTL, nil);
		force_expire(job_setup_connect);
		return 1;
	}

	/* Broadcast a named probe. */
	named_probe(HTONL(0xFFFFFFFFL));

	/* Schedule the next call. */
	newjob(job_find_named, now + SHORT_TIMEOUT, nil);
	return 1;
}

int job_expect_named(void *data, int expired)
/* The real name server is expected to answer by now. */
{
	if (!expired) return 0;
	if (debug >= 2) printf(": Expect named\n");

	if (expect_ct > 0) {
		if (--expect_ct > 0) {
			/* Probe the current name daemon. */
			named_probe(named_ip);
			newjob(job_expect_named, now + SHORT_TIMEOUT, nil);
		} else {
			/* Still no answer. */
			if (!searching()) named_search();
		}
	}
	return 1;
}

int force_search;

void sig_handler(int sig)
/* A signal forces a search for a real name daemon, etc. */
{
	switch (sig) {
	case SIGHUP:	force_search= 1;	break;
	case SIGUSR1:	debug++;		break;
	case SIGUSR2:	debug= 0;		break;
	}
}

void usage(void)
{
	fprintf(stderr,
		"Usage: nonamed [-d[level]] [-p port] [-n address[/port]]\n");
	exit(1);
}

void main(int argc, char **argv)
{
	job_t *job;
	nwio_udpopt_t udpopt;
	int i;
	struct servent *servent;
	struct sigaction sa;

	if ((servent= getservbyname("domain", nil)) == nil) {
		fprintf(stderr, "nonamed: \"domain\": unknown service\n");
		exit(1);
	}
	my_port= servent->s_port;
	named_port= servent->s_port;

	i= 1;
	while (i < argc) {
		char *opt= argv[i++], *p, *end;

		if (*opt++ != '-') usage();
		if (opt[0] == '-' && opt[1] == 0) break;

		switch (*opt++) {
		case 'd':
			debug= 1;
			if (*opt != 0) {
				debug= strtoul(opt, &end, 10);
				if (*end != 0) usage();
			}
			break;
		case 'p':
			if (*opt == 0) {
				if (i == argc) usage();
				opt= argv[i++];
			}
			my_port= htons(strtoul(opt, &end, 0));
			if (opt == end || *end != 0) usage();
			break;
		case 'n':
			if (*opt == 0) {
				if (i == argc) usage();
				opt= argv[i++];
			}
			if ((p= strchr(opt, '/')) != nil) *p++= 0;
			if (!inet_aton(opt, &named_ip)) usage();
			if (p != nil) {
				named_port= htons(strtoul(p, &end, 0));
				if (p == end || *end != 0) usage();
				p[-1]= '/';
			}
			stop_searching();
			break;
		default:
			usage();
		}
	}
	if (i != argc) usage();

	/* Don't die on broken pipes, seek a real name daemon on hangup, etc. */
	sa.sa_handler= SIG_IGN;
	sigemptyset(&sa.sa_mask);
	sa.sa_flags= 0;
	sigaction(SIGPIPE, &sa, nil);
	sa.sa_handler= sig_handler;
	sigaction(SIGHUP, &sa, nil);
	sigaction(SIGUSR1, &sa, nil);
	sigaction(SIGUSR2, &sa, nil);

	/* TCP and UDP device names. */
	if ((tcp_device= getenv("TCP_DEVICE")) == nil) tcp_device= TCP_DEVICE;
	if ((udp_device= getenv("UDP_DEVICE")) == nil) udp_device= UDP_DEVICE;

	/* Open an UDP channel for incoming DNS queries. */
	if ((udp_fd= open(udp_device, O_RDWR)) < 0) fatal(udp_device);

	udpopt.nwuo_flags= NWUO_EXCL | NWUO_LP_SET | NWUO_EN_LOC
		| NWUO_DI_BROAD | NWUO_RP_ANY | NWUO_RA_ANY | NWUO_RWDATALL
		| NWUO_DI_IPOPT;
	udpopt.nwuo_locport= my_port;
	if (ioctl(udp_fd, NWIOSUDPOPT, &udpopt) == -1) fatal(udp_device);

	/* Get the local machine's IP address. */
	if (ioctl(udp_fd, NWIOGUDPOPT, &udpopt) == -1) fatal(udp_device);
	my_ip= udpopt.nwuo_locaddr;
	if (debug >= 2) printf("my IP address is %s\n", inet_ntoa(my_ip));

	/* Jobs that start the ball rolling. */
	newjob(job_read_udp, NEVER, nil);
	newjob(job_setup_listen, IMMEDIATE, nil);
	newjob(job_find_named, IMMEDIATE, nil);

	now= time(nil);

	while (1) {
		/* There is always something in the queue with a timeout. */
		assert(queue != nil);
		assert(queue->timeout != NEVER);

		/* Any expired jobs? */
		while (queue->timeout <= now) {
			(void) execjob(queue, 1);
			assert(queue != nil);
			assert(queue->timeout != NEVER);
		}

		/* Check I/O jobs. */
		for (job= queue; job != nil; job= job->next) {
			if (execjob(job, 0)) break;
		}

		if (queue->timeout != IMMEDIATE) {
			struct timeval tv;

			tv.tv_sec= queue->timeout;
			tv.tv_usec= 0;
			if (debug >= 2) {
				unsigned long s= tv.tv_sec - now;
				printf("I/O wait (expire in %02ld:%02ld)\n",
							s / 60, s % 60);
			}
			fflush(stdout);

			if (asyn_wait(&asyn, 0, &tv) < 0) {
				if (errno != EINTR && errno != EAGAIN)
					fatal("fwait()");
			}
			now= time(nil);
		}

		if (force_search) {
			/* Hangup makes us go back to square one. */
			force_search= 0;
			named_search();
		}
	}
}
