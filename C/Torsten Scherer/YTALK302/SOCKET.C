/* socket.c - socket functions */

/*			   NOTICE
 *
 * Copyright (c) 1990,1992,1993 Britt Yenne.  All rights reserved.
 * 
 * This software is provided AS-IS.  The author gives no warranty,
 * real or assumed, and takes no responsibility whatsoever for any 
 * use or misuse of this software, or any damage created by its use
 * or misuse.
 * 
 * This software may be freely copied and distributed provided that
 * no part of this NOTICE is deleted or edited in any manner.
 * 
 */

/* Mail comments or questions to ytalk@austin.eds.com */

#include "header.h"
#include "menu.h"
#include "socket.h"
#include <sys/time.h>
#ifdef _AIX
# include <sys/select.h>
#endif

struct _talkd talkd[MAXDAEMON+1];
int daemons = 0;

static int otalk, ntalk;		/* daemon numbers */
static CTL_MSG omsg;			/* old talk message */
static CTL_RESPONSE orsp;		/* old talk response */
static CTL_MSG42 nmsg;			/* new talk message */
static CTL_RESPONSE42 nrsp;		/* new talk response */

static int autofd = -1;			/* auto invite socket fd */
static struct sockaddr_in autosock;	/* auto invite socket */
static ylong autoid[MAXDAEMON+1];	/* auto invite seq numbers */
static ylong announce_id = 0;		/* announce sequence id */
static readdr *readdr_list = NULL;	/* list of re-addresses */

#define IN_ADDR(s)	((s).sin_addr.s_addr)
#define IN_PORT(s)	((s).sin_port)
#define SOCK_EQUAL(s,c)	(IN_PORT(s) == IN_PORT(c) && IN_ADDR(s) == IN_ADDR(c))

/* ---- local functions ---- */

/* Create a datagram socket.
 */
static int
init_dgram(sock)
  struct sockaddr_in *sock;
{
    int fd, socklen;

    sock->sin_family = AF_INET;
    IN_ADDR(*sock) = INADDR_ANY;
    IN_PORT(*sock) = 0;
    if((fd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
    {
	show_error("init_dgram: socket() failed");
	bail(YTE_ERROR);
    }
    if(bind(fd, (struct sockaddr *)sock, sizeof(struct sockaddr_in)) != 0)
    {
	close(fd);
	show_error("init_dgram: bind() failed");
	bail(YTE_ERROR);
    }
    socklen = sizeof(struct sockaddr_in);
    if(getsockname(fd, (struct sockaddr *)sock, &socklen) < 0)
    {
	close(fd);
	show_error("init_dgram: getsockname() failed");
	bail(YTE_ERROR);
    }
    IN_ADDR(*sock) = me->host_addr;
    return fd;
}

/* Initialize a new daemon structure.
 */
static int
init_daemon(name, port, mptr, mlen, rptr, rlen)
  char *name;
  short port;
  yaddr mptr, rptr;
  int mlen, rlen;
{
    struct servent *serv;
    int d;

    if(daemons >= MAXDAEMON)
    {
	show_error("init_daemon: too many daemons");
	bail(YTE_ERROR);
    }
    d = ++daemons;	/* daemon number zero is not defined */

    if((serv = getservbyname(name, "udp")) != NULL)
	talkd[d].port = serv->s_port;
    else
	talkd[d].port = port;
    
    talkd[d].fd = init_dgram(&(talkd[d].sock));
    talkd[d].mptr = mptr;
    talkd[d].mlen = mlen;
    talkd[d].rptr = rptr;
    talkd[d].rlen = rlen;
    return d;
}

static void
read_autoport(fd)
  int fd;
{
    int socklen;
    static v2_pack pack;
    static char estr[V2_NAMELEN + V2_HOSTLEN + 20];
    static struct sockaddr_in temp;

    /* accept the connection */

    socklen = sizeof(struct sockaddr_in);
    if((fd = accept(autofd, (struct sockaddr *) &temp, &socklen)) == -1)
    {
	show_error("read_autoport: accept() failed");
	return;
    }

    /* The autoport socket just uses the old Ytalk version 2.?
     * packet.
     */
    errno = 0;
    if(full_read(fd, &pack, V2_PACKLEN) < 0 || pack.code != V2_AUTO)
    {
	show_error("read_autoport: unknown auto-invite connection");
	close(fd);
	return;
    }
    close(fd);
    if(!(def_flags & FL_INVITE))
    {
	sprintf(estr, "Talk to %s@%s?", pack.name, pack.host);
	if(yes_no(estr) == 'n')
	    return;
    }
    sprintf(estr, "%s@%s", pack.name, pack.host);
    invite(estr, 1);	/* we should be expected */
}

/* Create and initialize the auto-invitation socket.
 */
static void
init_autoport()
{
    int socklen;

    autosock.sin_family = AF_INET;
    IN_ADDR(autosock) = INADDR_ANY;
    IN_PORT(autosock) = 0;
    if((autofd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
	show_error("init_autoport: socket() failed");
	return;
    }
    if(bind(autofd, (struct sockaddr *)&autosock,
	sizeof(struct sockaddr_in)) < 0)
    {
	close(autofd);
	autofd = -1;
	show_error("init_autoport: bind() failed");
	return;
    }
    socklen = sizeof(struct sockaddr_in);
    if(getsockname(autofd, (struct sockaddr *)&autosock, &socklen) < 0)
    {
	close(autofd);
	autofd = -1;
	show_error("init_autoport: getsockname() failed");
	return;
    }
    IN_ADDR(autosock) = me->host_addr;
    if(listen(autofd, 5) < 0)
    {
	close(autofd);
	autofd = -1;
	show_error("init_autoport: listen() failed");
	return;
    }
    (void)memset(autoid, 0, (MAXDAEMON + 1) * sizeof(ylong));
    add_fd(autofd, read_autoport);
}

/* Fill the socket address field with the appropriate return address for
 * the host I'm sending to.
 */
static void
place_my_address(sock, addr)
  struct sockaddr_in *sock;
  register ylong addr;
{
    register readdr *r;

    for(r = readdr_list; r != NULL; r = r->next)
	if((addr & r->mask) == r->addr)
	{
	    addr = (r->id_addr & r->id_mask) |
		   (me->host_addr & (~(r->id_mask)));
	    IN_ADDR(*sock) = addr;
	    break;
	}
    if(r == NULL)
	IN_ADDR(*sock) = me->host_addr;
    sock->sin_family = htons(AF_INET);
}

/* sendit() sends the completed message to the talk daemon at the given
 * hostname, then reads a response packet.
 */
static int
sendit(addr, d)
  ylong addr;	/* host internet address */
  int d;	/* daemon number */
{
    int n;
    struct sockaddr_in daemon;
    struct timeval tv;
    char *rtype, *mtype;
    fd_set sel;

    /* set up the appropriate message structure */

    if(d == ntalk)
    {
	nmsg.vers = TALK_VERSION;
	place_my_address(&(nmsg.ctl_addr), addr);
	mtype = &(nmsg.type);
	rtype = &(nrsp.type);
    }
    else if(d == otalk)
    {
	omsg.type = nmsg.type;
	omsg.addr = nmsg.addr;
	omsg.id_num = nmsg.id_num;
	omsg.pid = nmsg.pid;
	strncpy(omsg.l_name, nmsg.l_name, NAME_SIZE);
	strncpy(omsg.r_name, nmsg.r_name, NAME_SIZE);
	strncpy(omsg.r_tty, nmsg.r_tty, TTY_SIZE);
	place_my_address(&(omsg.ctl_addr), addr);
	mtype = &(omsg.type);
	rtype = &(orsp.type);
    }
    else
    {
	sprintf(errstr, "Unkown daemon type: %d", d);
	show_error(errstr);
	return -1;
    }

    /* set up a sockaddr_in for the daemon we're sending to */

    daemon.sin_family = AF_INET;
    IN_ADDR(daemon) = addr;
    IN_PORT(daemon) = talkd[d].port;

    /* flush any lingering input */

    FD_ZERO(&sel);
    for(;;)
    {
	tv.tv_sec = 0L;
	tv.tv_usec = 0L;
	FD_SET(talkd[d].fd, &sel);
	if((n = select(talkd[d].fd + 1, &sel, 0, 0, &tv)) < 0)
	{
	    show_error("sendit: flush select() failed");
	    return -1;
	}
	if(n <= 0)
	    break;
	if(recv(talkd[d].fd, talkd[d].rptr, talkd[d].rlen, 0) < 0)
	{
	    show_error("sendit: flush recv() failed");
	    return -1;
	}
    }

    /* Now we need to send the actual packet.  Due to unreliability of
     * DGRAM sockets, we must resend the packet until we get a response
     * from the server.  Geez... two different daemons, both on unreliable
     * sockets, and maybe even different daemons on different machines.
     * Is *nothing* reliable anymore???
     */
    do
    {
    	do
	{
	    n = sendto(talkd[d].fd, talkd[d].mptr, talkd[d].mlen,
		0, (struct sockaddr *) &daemon, sizeof(daemon));
	    if(n != talkd[d].mlen)
	    {
		show_error("sendit: sendto() failed");
		return -1;
	    }

	    tv.tv_sec = 5L;
	    tv.tv_usec = 0L;
	    FD_SET(talkd[d].fd, &sel);
	    if((n = select(talkd[d].fd + 1, &sel, 0, 0, &tv)) < 0)
	    {
		show_error("sendit: first select() failed");
		return -1;
	    }
 	} while (n <= 0);	/* ie: until we receive a reply */

    	do
	{
	    n = recv(talkd[d].fd, talkd[d].rptr, talkd[d].rlen, 0);
	    if(n < 0)
	    {
		show_error("sendit: recv() failed");
		return -1;
	    }

	    if(*rtype != *mtype)
		tv.tv_sec = 5L;
	    else
		tv.tv_sec = 0L;
	    tv.tv_usec = 0L;
	    FD_SET(talkd[d].fd, &sel);
	    if((n = select(talkd[d].fd + 1, &sel, 0, 0, &tv)) < 0)
	    {
		show_error("sendit: second select() failed");
		return -1;
	    }
    	} while(n > 0 && *rtype != *mtype);
    } while(*rtype != *mtype);

    /* WHEW */

    /* Just because a person is a SYSADMIN doesn't necessarily mean he/she
     * knows everything about installing software.  In fact, many have been
     * known to install the talk daemon without setting the option required
     * to pad out the structures so that "long"s are on four-byte boundaries
     * on machines where "long"s can be on two-byte boundaries.  This "bug"
     * cost me about four hours of debugging to discover, so I'm not happy
     * right now.  Anyway, here's a quick hack to fix this problem.
     */
    if(d == otalk && nrsp.type == LOOK_UP && nrsp.answer == 0)
    {
	u_short t;
	(void)memcpy((char *)&t, ((char *)&orsp.addr.sin_family)-2, sizeof(t));
	if(ntohs(t) == AF_INET && ntohs(orsp.addr.sin_family) != AF_INET)
	{
	    char *c;
	    c = ((char *)&orsp) + sizeof(orsp) - 1;
	    for(; c >= (char *)&orsp.id_num; c--)
		*c = *(c-2);
	}
    }

    /* Fill in the new talk response structure if we just read an
     * old one.
     */
    if(d == otalk)
    {
	nrsp.type = orsp.type;
	nrsp.answer = orsp.answer;
	nrsp.id_num = orsp.id_num;
	nrsp.addr = orsp.addr;
    }

    return 0;
}

/* find_daemon() locates the talk daemon(s) on a machine and determines
 * what version(s) of the daemon are running.
 */
static int
find_daemon(addr)
  ylong addr;
{
    register hostinfo *h;
    register int n, i, d;
    CTL_MSG m1;
    CTL_MSG42 m2;
    struct sockaddr_in daemon;
    struct timeval tv;
    int sel, out;
    static hostinfo *host_head = NULL;

    /* If we've already used this host, look it up instead of blitting to
     * the daemons again...
     */
    for(h = host_head; h; h = h->next)
	if(h->host_addr == addr)
	    return h->dtype;

    daemon.sin_family = AF_INET;
    IN_ADDR(daemon) = addr;

    m1 = omsg;
    m2 = nmsg;
    m1.ctl_addr = talkd[otalk].sock;
    place_my_address(&(m1.ctl_addr), addr);
    m2.ctl_addr = talkd[ntalk].sock;
    place_my_address(&(m2.ctl_addr), addr);
    m1.type = m2.type = LOOK_UP;
    m1.id_num = m2.id_num = htonl(0);
    m1.r_tty[0] = m2.r_tty[0] = '\0';
    strcpy(m1.r_name, "ytalk");
    strcpy(m2.r_name, "ytalk");
    m1.addr.sin_family = m2.addr.sin_family = htons(AF_INET);

    out = 0;
    for(i = 0; i < 5; i++)
    {
	IN_PORT(daemon) = talkd[ntalk].port;
	n = sendto(talkd[ntalk].fd, &m2, sizeof(m2),
	    0, (struct sockaddr *) &daemon, sizeof(daemon));
	if(n != sizeof(m2))
	    show_error("Warning: cannot write to new talk daemon");

	IN_PORT(daemon) = talkd[otalk].port;
	n = sendto(talkd[otalk].fd, &m1, sizeof(m1),
	    0, (struct sockaddr *) &daemon, sizeof(daemon));
	if(n != sizeof(m1))
	    show_error("Warning: cannot write to old talk daemon");

	tv.tv_sec = 4L;
	tv.tv_usec = 0L;
	sel = (1 << talkd[ntalk].fd) | (1 << talkd[otalk].fd);
	if((n = select(32, &sel, 0, 0, &tv)) < 0)
	{
	    show_error("find_daemon: first select() failed");
	    continue;
	}
	if(n == 0)
	    continue;

	do
	{
	    for(d = 1; d <= daemons; d++)
		if(sel & (1 << talkd[d].fd))
		{
		    out |= (1 << d);
		    if(recv(talkd[d].fd, errstr, talkd[d].rlen, 0) < 0)
			show_error("find_daemon: recv() failed");
		}

	    tv.tv_sec = 0L;
	    tv.tv_usec = 500000L;	/* give the other daemon a chance */
	    sel = (1 << talkd[ntalk].fd) | (1 << talkd[otalk].fd);
	    if((n = select(32, &sel, 0, 0, &tv)) < 0)
		show_error("find_daemon: second select() failed");
	} while(n > 0);

	h = (hostinfo *)get_mem(sizeof(hostinfo));
	h->next = host_head;
	host_head = h;
	h->host_addr = addr;
	h->dtype = out;
	return out;
    }
    sprintf(errstr, "No talk daemon on %s", host_name(addr));
    show_error(errstr);
    return 0;
}

static ylong
make_net_mask(addr)
  ylong addr;
{
    if(addr & (ylong)0xff)
	return (ylong)0xffffffff;
    if(addr & (ylong)0xffff)
	return (ylong)0xffffff00;
    if(addr & (ylong)0xffffff)
	return (ylong)0xffff0000;
    if(addr)
	return (ylong)0xff000000;
    return (ylong)0;
}

/* ---- global functions ---- */

/* Initialize sockets and message parameters.
 */
void
init_socket()
{
    /* init daemons in order of preference */

    ntalk = init_daemon("ntalk", 518, &nmsg, sizeof(nmsg),
	&nrsp, sizeof(nrsp));
    otalk = init_daemon("talk", 517, &omsg, sizeof(omsg),
	&orsp, sizeof(orsp));

    strncpy(nmsg.l_name, me->user_name, NAME_SIZE);

    omsg.ctl_addr = talkd[otalk].sock;
    nmsg.ctl_addr = talkd[ntalk].sock;
    nmsg.vers = TALK_VERSION;

    (void)find_daemon(me->host_addr);
    init_autoport();
}

/* Close every open descriptor.  This should only be used for a quick
 * exit... it does not gracefully shut systems down.
 */
void
close_all()
{
    register yuser *u;
    register int d;

    for(u = user_list; u; u = u->unext)
    {
	if(u->fd > 0)
	    close(u->fd);
	if(u->output_fd > 0)
	    close(u->output_fd);
    }
    if(autofd > 0)
	close(autofd);
    for(d = 1; d <= daemons; d++)
	close(talkd[d].fd);
}

/* The following routines send a request across the DGRAM socket to the
 * talk daemons.
 */

/* First, a quick and easy interface for the user sockets.
 */
int
send_dgram(user, type)
  yuser *user;
  u_char type;
{
    ylong addr;
    int d;

    /* set up the message type and where to send it */

    switch(type)
    {
	case LEAVE_INVITE:	/* leave an invite on my machine */
	    addr = me->host_addr;
	    nmsg.type = LEAVE_INVITE;
	    nmsg.id_num = htonl(user->l_id);
	    break;
	case DELETE_INVITE:	/* delete my invite on my machine */
	    addr = me->host_addr;
	    nmsg.type = DELETE;
	    nmsg.id_num = htonl(user->l_id);
	    break;
	case ANNOUNCE:		/* ring a user */
	    addr = user->host_addr;
	    nmsg.type = ANNOUNCE;
	    announce_id += 5;	/* no guesswork here */
	    nmsg.id_num = htonl(announce_id);
	    break;
	case LOOK_UP:		/* look up remote invitation */
	    addr = user->host_addr;
	    nmsg.type = LOOK_UP;
	    nmsg.id_num = htonl(user->r_id);
	    break;
	case DELETE:		/* delete erroneous remote invitation */
	    addr = user->host_addr;
	    nmsg.type = DELETE;
	    nmsg.id_num = htonl(user->r_id);
	    break;
	case AUTO_LOOK_UP:	/* look up remote auto-invitation */
	    addr = user->host_addr;
	    nmsg.type = LOOK_UP;
	    nmsg.id_num = htonl(user->r_id);
	    break;
	case AUTO_DELETE:	/* delete erroneous remote auto-invitation */
	    addr = user->host_addr;
	    nmsg.type = DELETE;
	    nmsg.id_num = htonl(user->r_id);
	    break;
	default:
	    errno = 0;
	    show_error("send_dgram: unknown type");
	    return -1;
    }

    /* find a common daemon, if possible */

    if(user->daemon != 0)
	d = user->daemon;
    else
    {
	int dtype, d1, d2;

	/* Find the daemon(s) their host supports.  If our two machines
	 * support a daemon in common, use that one.  Else, normal UNIX
	 * "talk" is already screwed to the wall, but YTalk will at least
	 * work.
	 */
	d1 = find_daemon(user->host_addr);
	d2 = find_daemon(me->host_addr);
	dtype = d1 & d2;

	if(d1 == 0 || d2 == 0)
	    return -1;
	if(dtype == 0)
	{
	    dtype = find_daemon(addr);
	    for(d = 1; d <= daemons; d++)
		if(dtype & (1<<d))
		    break;
	    if(d > daemons)
		return -1;
	}
	else
	{
	    for(d = 1; d <= daemons; d++)
		if(dtype & (1<<d))
		{
		    user->daemon = d;
		    break;
		}
	    if(d > daemons)
		return -1;
	}
    }

    /* Each user has his own unique daemon id.  Why?  Tsch.  Why.
     * Well, the talk daemons consider two users equivalent if their
     * usernames and machine names match.  Hence, the daemons will not
     * allow ytalk to talk with two different users with the same name
     * on some machine.  By assigning unique process id's, we trick
     * the daemons into thinking we're several different users trying
     * to talk to the same person.  Sick?  Don't blame me.
     */
    nmsg.pid = htonl(user->d_id);
    if(type == AUTO_LOOK_UP || type == AUTO_DELETE)
    {
	strcpy(nmsg.l_name, "+AUTO");	/* put on my mask... */
	strncpy(nmsg.r_name, user->user_name, NAME_SIZE);
	nmsg.r_tty[0] = '\0';
    }
    else
    {
	strncpy(nmsg.r_name, user->user_name, NAME_SIZE);
	strncpy(nmsg.r_tty, user->tty_name, TTY_SIZE);
    }
    nmsg.addr = user->sock;
    nmsg.addr.sin_family = htons(AF_INET);
    if(sendit(addr, d) != 0)
    {
	if(type == AUTO_LOOK_UP || type == AUTO_DELETE)
	    strncpy(nmsg.l_name, me->user_name, NAME_SIZE);
	return -2;
    }

    switch(type)
    {
	case LEAVE_INVITE:
	    user->l_id = ntohl(nrsp.id_num);
	    break;
	case LOOK_UP:
	    user->r_id = ntohl(nrsp.id_num);
	    break;
	case AUTO_LOOK_UP:
	    strncpy(nmsg.l_name, me->user_name, NAME_SIZE);
	    user->r_id = ntohl(nrsp.id_num);
	    break;
	case AUTO_DELETE:
	    strncpy(nmsg.l_name, me->user_name, NAME_SIZE);
	    break;
    }
    return nrsp.answer;
}

/* Next, an interface for the auto-invite socket.  The auto-invite socket
 * always sends to the caller's host, and always does just an invite.
 */
int
send_auto(type)
  u_char type;
{
    int dtype, d, rc;

    if(autofd < 0)
	return 0;
    nmsg.type = type;
    strcpy(nmsg.r_name, "+AUTO");
    nmsg.r_tty[0] = '\0';
    nmsg.addr = autosock;
    nmsg.addr.sin_family = htons(AF_INET);

    rc = 0;
    dtype = find_daemon(me->host_addr);
    for(d = daemons; d >= 1; d--)
	if(dtype & (1<<d))
	{
	    nmsg.id_num = htonl(autoid[d]);
	    nmsg.pid = htonl(1);
	    if(sendit(me->host_addr, d) < 0)
		rc = -1;
	    else
		autoid[d] = ntohl(nrsp.id_num);
	}

    if(rc)
	return rc;
    if(type == LEAVE_INVITE)
	return 0;
    return nrsp.answer;
}

/* Shut down the auto-invitation system.
 */
void
kill_auto()
{
    if(autofd < 0)
	return;
    (void)send_auto(DELETE);
    remove_fd(autofd);
    close(autofd);
    autofd = -1;
}

/* Create a TCP socket for communication with other talk users.
 */
int
newsock(user)
  yuser *user;
{
    int socklen, fd;

    user->sock.sin_family = AF_INET;
    IN_ADDR(user->sock) = INADDR_ANY;
    IN_PORT(user->sock) = 0;
    if((fd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
	show_error("newsock: socket() failed");
	return -1;
    }
    if(bind(fd, (struct sockaddr *)&user->sock, sizeof(struct sockaddr_in)) < 0)
    {
	close(fd);
	show_error("newsock: bind() failed");
	return -1;
    }
    socklen = sizeof(struct sockaddr_in);
    if(getsockname(fd, (struct sockaddr *)&user->sock, &socklen) < 0)
    {
	close(fd);
	show_error("newsock: getsockname() failed");
	return -1;
    }
    place_my_address(&(user->sock), user->host_addr);
    if(listen(fd, 5) < 0)
    {
	close(fd);
	show_error("newsock: listen() failed");
	return -1;
    }
    user->fd = fd;
    fd_to_user[user->fd] = user;
    user->orig_sock = user->sock;
    return 0;
}

/* Connect to another user's communication socket.
 */
int
connect_to(user)
  yuser *user;
{
    register yuser *u;
    int socklen, fd;
    struct sockaddr_in sock, orig_sock;

    orig_sock = *(struct sockaddr_in *)&nrsp.addr;
    orig_sock.sin_family = AF_INET;

    /* it could be one of mine... */
    for(u = user_list; u; u = u->unext)
	if(SOCK_EQUAL(orig_sock, u->orig_sock))
	    return -3;
    if(SOCK_EQUAL(orig_sock, autosock))
	return -3;

    sock = orig_sock;
    if((fd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
	show_error("connect_to: socket() failed");
	return -1;
    }
    if(connect(fd, (struct sockaddr *)&sock, sizeof(struct sockaddr_in)) < 0)
    {
	close(fd);
	if(errno == ECONNREFUSED)
	{
	    errno = 0;
	    return -2;
	}
	show_error("connect_to: connect() failed");
	return -1;
    }
    socklen = sizeof(struct sockaddr_in);
    if(getsockname(fd, (struct sockaddr *)&sock, &socklen) < 0)
    {
	close(fd);
	show_error("connect_to: getsockname() failed");
	return -1;
    }
    if(user)
    {
	user->sock = sock;
	user->orig_sock = orig_sock;
	user->fd = fd;
	fd_to_user[user->fd] = user;
    }
    return fd;
}

/* Find a host's address.
 */
ylong
get_host_addr(hostname)
  char *hostname;
{
    struct hostent *host;
    ylong addr;
    ylong inet_addr();

    errno = 0;
    if((host = (struct hostent *) gethostbyname(hostname)) != NULL) {
	if(host->h_length != sizeof(addr)) {
	    sprintf(errstr, "Bad IN addr: %s", hostname);
	    show_error(errstr);
	    return (ylong)-1;
	}
	(void)memcpy(&addr, host->h_addr, sizeof(addr));
    } else
	if((addr = (ylong)inet_addr(hostname)) == (ylong)-1)
		return (ylong)-1;

    return addr;
}

/* Find a host name by host address.
 */
char *
host_name(addr)
  ylong addr;
{
    struct hostent *host;
    char *inet_ntoa();

    if((host = gethostbyaddr((char *) &addr, sizeof(addr), AF_INET)) == NULL)
    {
	struct in_addr tmp;
	tmp.s_addr = addr;
	return inet_ntoa(tmp);
    }
    return host->h_name;
}

/* Re-address a given host ("from_id") to the given address or host
 * id ("to_id") when communicating with some other host id ("on_id").
 * This is useful especially over routers where "foo.com" is known
 * as the differently-addressed "bar.com" to host "xyzzy.com".
 */
void
readdress_host(from_id, to_id, on_id)
  char *from_id, *to_id, *on_id;
{
    register readdr *new;
    ylong from_addr, to_addr, on_addr;
    ylong from_mask, to_mask, on_mask;

    if((from_addr = get_host_addr(from_id)) == (ylong)-1)
    {
	sprintf(errstr, "Unknown host: '%s'", from_id);
	show_error(errstr);
	return;
    }
    if((to_addr = get_host_addr(to_id)) == (ylong)-1)
    {
	sprintf(errstr, "Unknown host: '%s'", to_id);
	show_error(errstr);
	return;
    }
    if((on_addr = get_host_addr(on_id)) == (ylong)-1)
    {
	sprintf(errstr, "Unknown host: '%s'", on_id);
	show_error(errstr);
	return;
    }
    from_mask = make_net_mask(from_addr);
    to_mask = make_net_mask(to_addr);
    on_mask = make_net_mask(on_addr);
    
    if((from_addr & from_mask) != (me->host_addr & from_mask))
	return;
    if(from_addr == to_addr)
	return;

    new = (readdr *)get_mem(sizeof(readdr));
    new->addr = on_addr;
    new->mask = on_mask;
    new->id_addr = to_addr;
    new->id_mask = to_mask;
    new->next = readdr_list;
    readdr_list = new;
}
