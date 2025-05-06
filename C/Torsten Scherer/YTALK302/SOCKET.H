/* socket.h */

#include <netdb.h>

/* ---- talk daemon information structure ---- */

#define MAXDAEMON	5

struct _talkd {
    struct sockaddr_in sock;	/* socket */
    int fd;			/* socket file descriptor */
    short port;			/* port number */
    yaddr mptr;			/* message pointer */
    int mlen;			/* message length */
    yaddr rptr;			/* response pointer */
    int rlen;			/* response length */
};

typedef struct _hostinfo {
    struct _hostinfo *next;	/* next in linked list */
    ylong host_addr;		/* host address */
    int dtype;			/* active daemon types bitmask */
} hostinfo;

typedef struct _readdr {
    struct _readdr *next;	/* next in linked list */
    ylong addr;		/* this net address [group?], */
    ylong mask;		/* with this mask, */
    ylong id_addr;		/* thinks I'm at this net address, */
    ylong id_mask;		/* with this mask. */
} readdr;

extern struct _talkd talkd[MAXDAEMON+1];
extern int daemons;

/* ---- talk daemon I/O structures ---- */

#define NAME_SIZE 9
#define TTY_SIZE 16

/* Control Message structure for earlier than BSD4.2
 */
typedef struct {
	char	type;
	char	l_name[NAME_SIZE];
	char	r_name[NAME_SIZE];
	char	filler;
	ylong	id_num;
	ylong	pid;
	char	r_tty[TTY_SIZE];
	struct	sockaddr_in addr;
	struct	sockaddr_in ctl_addr;
} CTL_MSG;

/* Control Response structure for earlier than BSD4.2
 */
typedef struct {
	char	type;
	char	answer;
	u_short	filler;
	ylong	id_num;
	struct	sockaddr_in addr;
} CTL_RESPONSE;

/* Control Message structure for BSD4.2
 */
typedef struct {
	u_char	vers;
	char	type;
	u_short	filler;
	ylong	id_num;
	struct	sockaddr_in addr;
	struct	sockaddr_in ctl_addr;
	ylong	pid;
	char	l_name[NAME_SIZE];
	char	l_name_filler[3];
	char	r_name[NAME_SIZE];
	char	r_name_filler[3];
	char	r_tty[TTY_SIZE];
} CTL_MSG42;

/* Control Response structure for BSD4.2
 */
typedef struct {
	u_char	vers;
	char	type;
	char	answer;
	char	filler;
	ylong	id_num;
	struct	sockaddr_in addr;
} CTL_RESPONSE42;

#define	TALK_VERSION	1		/* protocol version */

/* Dgram Types.
 *
 * These are the "type" arguments to feed to send_dgram().  Each acts
 * either on the remote daemon or the local daemon, as marked.
 */

#define LEAVE_INVITE	0	/* leave an invitation (local) */
#define LOOK_UP		1	/* look up an invitation (remote) */
#define DELETE		2	/* delete erroneous invitation (remote) */
#define ANNOUNCE	3	/* ring a user (remote) */
#define DELETE_INVITE	4	/* delete my invitation (local) */
#define AUTO_LOOK_UP	5	/* look up auto-invitation (remote) */
#define AUTO_DELETE	6	/* delete erroneous auto-invitation (remote) */

/* EOF */
