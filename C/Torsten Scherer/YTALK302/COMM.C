/* comm.c -- firewall between socket and terminal I/O */

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
#include "socket.h"
#include "menu.h"
#include <sys/uio.h>
#ifdef __MINT__
# include <time.h>
#endif

ychar *io_ptr;		/* user input pointer */
int    io_len = 0;	/* user input count */

extern int input_flag;	/* see fd.c */

/* ---- local functions ---- */

static y_parm parm;
static v2_pack v2p;
static v3_pack v3p;
static v3_flags v3f;
static v3_winch v3w;

/* Set up a drain of out-of-band data.
 */
static void
drain_user(user, len, func)
  yuser *user;
  int len;
  void (*func)();
{
    if(len > user->dbuf_size)
    {
	user->dbuf_size = len + 64;
	user->dbuf = (ychar *)realloc_mem(user->dbuf, user->dbuf_size);
    }
    user->drain = len;
    user->dptr = user->dbuf;
    user->dfunc = func;
}

/* Send out-of-band data.
 */
static void
send_oob(fd, ptr, len)
  int fd;
  yaddr ptr;
  int len;
{
    ychar oob, size;
    static struct iovec iov[3];

    if(len <= 0 || len > V3_MAXPACK)
    {
	errno = 0;
	show_error("send_oob: packet too large");
	return;
    }

    oob = V3_OOB;
    iov[0].iov_base = (yaddr)(&oob);
    iov[0].iov_len = 1;

    size = len;
    iov[1].iov_base = (yaddr)(&size);
    iov[1].iov_len = 1;

    iov[2].iov_base = ptr;
    iov[2].iov_len = len;

    if(writev(fd, iov, 3) != len + 2)
	show_error("send_oob: write failed");
}

/* Ask another ytalk connection if he wants to import a user I've
 * just now connected to.
 */
static void
send_import(to, from)
  yuser *to, *from;
{
    if(to->remote.vmajor > 2)
    {
	v3p.code = V3_IMPORT;
	v3p.host_addr = htonl(from->host_addr);
	v3p.pid = htonl(from->remote.pid);
	strncpy(v3p.name, from->user_name, V3_NAMELEN);
	strncpy(v3p.host, from->host_name, V3_HOSTLEN);
	send_oob(to->fd, &v3p, V3_PACKLEN);
    }
    else if(to->remote.vmajor == 2)
    {
	v2p.code = V2_IMPORT;
	strncpy(v2p.name, from->user_name, V2_NAMELEN);
	strncpy(v2p.host, from->host_name, V2_HOSTLEN);
	(void)write(to->fd, &v2p, V2_PACKLEN);
    }
}

/* Tell another ytalk connection to connect to a user.
 */
static void
send_accept(to, from)
  yuser *to, *from;
{
    if(to->remote.vmajor > 2)
    {
	v3p.code = V3_ACCEPT;
	v3p.host_addr = htonl(from->host_addr);
	v3p.pid = htonl(from->remote.pid);
	strncpy(v3p.name, from->user_name, V3_NAMELEN);
	strncpy(v3p.host, from->host_name, V3_HOSTLEN);
	send_oob(to->fd, &v3p, V3_PACKLEN);
    }
    else if(to->remote.vmajor == 2)
    {
	v2p.code = V2_ACCEPT;
	strncpy(v2p.name, from->user_name, V2_NAMELEN);
	strncpy(v2p.host, from->host_name, V2_HOSTLEN);
	(void)write(to->fd, &v2p, V2_PACKLEN);
    }
}

/* Process a Ytalk version 2.? data packet.
 */
static void
v2_process(user, pack)
  yuser *user;
  v2_pack *pack;
{
    register yuser *u;
    ylong host_addr;
    static char name[V2_NAMELEN + 1];
    static char host[V2_HOSTLEN + 1];
    static char estr[V2_NAMELEN + V2_HOSTLEN + 20];

    /* Ytalk version 2.* didn't have very clever import/export
     * capabilities.  We'll just go with the flow.
     */
    strncpy(name, pack->name, V2_NAMELEN);
    strncpy(host, pack->host, V2_HOSTLEN);
    name[V2_NAMELEN] = '\0';
    host[V2_HOSTLEN] = '\0';
    if((host_addr = get_host_addr(host)) == (ylong)-1)
    {
	errno = 0;
	sprintf(errstr, "unknown host: '%s'", host);
	show_error(errstr);
	show_error("port from ytalk V2.? failed");
	return;
    }
    switch(pack->code)
    {
	case V2_IMPORT:
	    /* Don't import a user with the same name of an existing
	     * user at this end.  yukk.
	     */
	    if(find_user(name, host_addr, (ylong)-1) != NULL)
		break;
	    if(!(def_flags & FL_IMPORT))
	    {
		sprintf(estr, "Import %s@%s?", name, host);
		if(yes_no(estr) == 'n')
		    break;
	    }

	    /* invite him but don't ring him */

	    sprintf(estr, "%s@%s", name, host);
	    invite(estr, 0);

	    /* now tell him to connect to us */

	    pack->code = V2_EXPORT;
	    (void)write(user->fd, pack, V2_PACKLEN);

	    break;
	case V2_EXPORT:
	    /* We don't need to check if he's not connected, since
	     * send_accept() will think his version number is zero
	     * and won't send anything.
	     */
	    if((u = find_user(name, host_addr, (ylong)-1)) == NULL)
		break;
	    send_accept(u, user);
	    break;
	case V2_ACCEPT:
	    sprintf(estr, "%s@%s", name, host);
	    invite(estr, 1);	/* we should be expected */
	    break;
    }
}

/* Process a Ytalk version 3.? data packet.
 */
static void
v3_process_pack(user, pack)
  yuser *user;
  v3_pack *pack;
{
    register yuser *u;
    ylong host_addr, pid;
    static char name[V3_NAMELEN + 1];
    static char host[V3_HOSTLEN + 1];
    static char estr[V3_NAMELEN + V3_HOSTLEN + 20];

    strncpy(name, pack->name, V3_NAMELEN);
    strncpy(host, pack->host, V3_HOSTLEN);
    name[V3_NAMELEN] = '\0';
    host[V3_HOSTLEN] = '\0';
    if((host_addr = get_host_addr(host)) == (ylong)-1)
	host_addr = ntohl(pack->host_addr);
    pid = ntohl(pack->pid);

    switch(pack->code)
    {
	case V3_IMPORT:
	    /* Don't import a user which is already in this
	     * session.  This is defined as a user with a matching
	     * name, host address, and process id.
	     */
	    if(find_user(name, host_addr, pid) != NULL)
		break;
	    if(!(def_flags & FL_IMPORT))
	    {
		sprintf(estr, "Import %s@%s?", name, host);
		if(yes_no(estr) == 'n')
		    break;
	    }

	    /* invite him but don't ring him */

	    sprintf(estr, "%s@%s", name, host);
	    invite(estr, 0);

	    /* now tell him to connect to us */

	    pack->code = V3_EXPORT;
	    send_oob(user->fd, pack, V3_PACKLEN);

	    break;
	case V3_EXPORT:
	    /* We don't need to check if he's not connected, since
	     * send_accept() will think his version number is zero
	     * and won't send anything.
	     */
	    if((u = find_user(name, host_addr, pid)) == NULL)
		break;
	    send_accept(u, user);
	    break;
	case V3_ACCEPT:
	    sprintf(estr, "%s@%s", name, host);
	    invite(estr, 1);	/* we should be expected */
	    break;
    }
}

/* Process a Ytalk version 3.? flags packet.  Other users can request
 * that their flags be locked to a particular value until they unlock
 * them later.
 */
static void
v3_process_flags(user, pack)
  yuser *user;
  v3_flags *pack;
{
    switch(pack->code)
    {
	case V3_LOCKF:
	    user->flags = ntohl(pack->flags) | FL_LOCKED;
	    break;
	case V3_UNLOCKF:
	    user->flags = def_flags;
	    break;
    }
}

/* Process a Ytalk version 3.? winch packet.
 */
static void
v3_process_winch(user, pack)
  yuser *user;
  v3_winch *pack;
{
    switch(pack->code)
    {
	case V3_YOURWIN:
	    user->remote.my_rows = ntohs(pack->rows);
	    user->remote.my_cols = ntohs(pack->cols);
	    winch_exec();
	    break;
	case V3_MYWIN:
	    user->remote.rows = ntohs(pack->rows);
	    user->remote.cols = ntohs(pack->cols);
	    break;
	case V3_REGION:
	    pack->rows = ntohs(pack->rows);
	    pack->cols = ntohs(pack->cols);
	    if(pack->rows > 0)
		set_win_region(user, (int)(pack->rows), (int)(pack->cols));
	    else
		end_win_region(user);
	    break;
    }
    user_winch = 1;
}

/* Process a Ytalk version 3.? out-of-band packet.  Call the appropriate
 * function based on the type of packet.
 */
static void
v3_process(user, ptr)
  yuser *user;
  yaddr ptr;
{
    ychar *str;

    /* ignore anything we don't understand */

    str = (ychar *)ptr;
    switch(*str)
    {
	case V3_IMPORT:
	case V3_EXPORT:
	case V3_ACCEPT:
	    v3_process_pack(user, (v3_pack *)ptr);
	    break;
	case V3_LOCKF:
	case V3_UNLOCKF:
	    v3_process_flags(user, (v3_flags *)ptr);
	    break;
	case V3_YOURWIN:
	case V3_MYWIN:
	case V3_REGION:
	    v3_process_winch(user, (v3_winch *)ptr);
	    break;
    }
}

/* Take input from a connected user.  If necessary, drain out-of-band
 * data from the canonical input stream.
 */
static void
read_user(fd)
  int fd;
{
    register ychar *c, *p;
    register int rc;
    register yuser *user;
    static ychar buf[512];

    if(input_flag)
    {
	/* tell input_loop() to ignore this function for now */
	input_flag = 0;
	return;
    }
    if((user = fd_to_user[fd]) == NULL)
    {
	remove_fd(fd);
	show_error("read_user: unknown contact");
	return;
    }
    if((rc = read(fd, buf, 512)) <= 0)
    {
	if(rc < 0)
	    show_error("read_user: read() failed");
	free_user(user);
	return;
    }
    c = buf;
    while(rc > 0)
    {
	if(user->drain > 0)	/* there is still some OOB data to drain */
	{
	    if(rc < user->drain)
	    {
		(void)memcpy(user->dptr, c, rc);
		user->dptr += rc;
		user->drain -= rc;
		rc = 0;
	    }
	    else
	    {
		(void)memcpy(user->dptr, c, user->drain);
		rc -= user->drain;
		c += user->drain;
		user->drain = 0;
		user->dfunc(user, user->dbuf);
	    }
	}
	else
	{
	    /* Ytalk version 3.0 Out-Of-Band data protocol:
	     *
	     *    If I receive a V3_OOB character, I look at the next
	     *    character.  If the next character is V3_OOB, then I
	     *    send one V3_OOB through transparently.  Else, the
	     *    next character is a packet length to be drained.
	     *    The packet length can never be V3_OOB because the
	     *    maximum out-of-band packet length is (V3_OOB - 1) bytes.
	     *    If any packet requires more information, then it can
	     *    always kick off another drain_user() inside v3_process().
	     */
	    p = buf;
	    if(user->got_oob)
	    {
		user->got_oob = 0;
		if(*c <= V3_MAXPACK)
		{
		    drain_user(user, *c, v3_process);
		    c++, rc--;
		    continue;
		}
		*(p++) = *c;
		c++, rc--;
	    }
	    for(; rc > 0; c++, rc--)
	    {
		if(*c > 127)			/* could be inline data */
		{
		    if(user->remote.vmajor > 2)		/* ytalk 3.0+ */
		    {
			if(*c == V3_OOB)
			{
			    c++, rc--;
			    if(rc > 0)
			    {
				if(*c <= V3_MAXPACK)
				{
				    drain_user(user, *c, v3_process);
				    c++, rc--;
				    break;
				}
			    }
			    else
			    {
				user->got_oob = 1;
				break;
			    }
			}
		    }
		    else if(user->remote.vmajor == 2)	/* ytalk 2.0+ */
		    {
			/* Version 2.* didn't support data transparency */

			if(*c == V2_IMPORT || *c == V2_EXPORT
			|| *c == V2_ACCEPT || *c == V2_AUTO)
			{
			    drain_user(user, V2_PACKLEN, v2_process);
			    /* don't increment c or decrement rc -- they're
			     * part of the drain.  :-)
			     */
			    break;
			}
		    }
		}
		*(p++) = *c;
	    }
	    if(p > buf)
	    {
		if(user->output_fd > 0)
		    if(write(user->output_fd, buf, p - buf) <= 0)
		    {
			show_error("write to user output file failed");
			close(user->output_fd);
			user->output_fd = 0;
		    }
		show_input(user, buf, p - buf);
	    }
	}
    }
}

/* Initial Handshaking:  read the parameter pack from another ytalk user.
 */
static void
ytalk_user(fd)
  int fd;
{
    register yuser *user, *u;
    u_short cols;

    if((user = fd_to_user[fd]) == NULL)
    {
	remove_fd(fd);
	show_error("ytalk_user: unknown contact");
	return;
    }
    if(full_read(user->fd, &parm, sizeof(y_parm)) < 0)
    {
	free_user(user);
	show_error("ytalk_user: bad ytalk contact");
	return;
    }
    switch(parm.protocol)
    {
	case YTP_OLD:
	    cols = parm.w_cols;
	    (void)memset(&parm, 0, sizeof(y_parm));
	    parm.vmajor = 2;
	    parm.cols = cols;
	    parm.my_cols = cols;
	    spew_term(me, fd, me->t_rows, parm.cols);
	    break;
	case YTP_NEW:
	    parm.vmajor = ntohs(parm.vmajor);
	    parm.vminor = ntohs(parm.vminor);
	    parm.rows = ntohs(parm.rows);
	    parm.cols = ntohs(parm.cols);
	    parm.my_rows = ntohs(parm.my_rows);
	    parm.my_cols = ntohs(parm.my_cols);
	    parm.pid = ntohl(parm.pid);
	    /* we spew_term later */
	    break;
	default:
	    free_user(user);
	    show_error("ytalk_user: unsupported ytalk protocol");
	    return;
    }
    user->remote = parm;
    user_winch = 1;
    add_fd(fd, read_user);

    /* update the lists */

    if(user == wait_list)
	wait_list = user->next;
    else
	for(u = wait_list; u; u = u->next)
	    if(u->next == user)
	    {
		u->next = user->next;
		break;
	    }
    user->next = connect_list;
    connect_list = user;

    /* send him my status */

    if(user->remote.vmajor > 2)
    {
	if(me->region_set)
	{
	    v3w.code = V3_REGION;
	    v3w.rows = htons(me->rows);
	    v3w.cols = htons(me->cols);
	    send_oob(fd, &v3w, V3_WINCHLEN);
	    winch_exec();
	    spew_term(me, fd, me->rows, me->cols);
	}
	else
	    spew_term(me, fd, parm.rows, parm.cols);

	if(me->flags & FL_LOCKED)
	{
	    v3f.code = V3_LOCKF;
	    v3f.flags = htonl(me->flags);
	    send_oob(fd, &v3f, V3_FLAGSLEN);
	}
    }

    /* tell everybody else he's here! */

    for(u = connect_list; u; u = u->next)
	if(u != user)
	    send_import(u, user);
}

/* Initial Handshaking:  read the edit keys and determine whether or not
 * this is another ytalk user.
 */
static void
connect_user(fd)
  int fd;
{
    register yuser *user, *u;

    if((user = fd_to_user[fd]) == NULL)
    {
	remove_fd(fd);
	show_error("connect_user: unknown contact");
	return;
    }
    if(full_read(fd, user->edit, 3) < 0)
    {
	free_user(user);
	show_error("connect_user: bad read");
	return;
    }
    if(open_term(user, user->full_name) < 0)
    {
	free_user(user);
	show_error("connect_user: open_term() failed");
	return;
    }

    /* check for ytalk connection */

    if(user->RUB == RUBDEF)
    {
	(void)memset(&parm, 0, sizeof(y_parm));
	parm.protocol = YTP_NEW;
	parm.vmajor = htons(VMAJOR);
	parm.vminor = htons(VMINOR);
	parm.rows = htons(me->t_rows);
	parm.cols = htons(me->t_cols);
	parm.my_rows = htons(user->t_rows);
	parm.my_cols = htons(user->t_cols);
	parm.w_rows = parm.rows;
	parm.w_cols = parm.cols;
	parm.pid = htonl(me->remote.pid);
	(void)write(user->fd, &parm, sizeof(y_parm));
	add_fd(fd, ytalk_user);
    }
    else
    {
	/* update the lists */

	if(user == wait_list)
	    wait_list = user->next;
	else
	    for(u = wait_list; u; u = u->next)
		if(u->next == user)
		{
		    u->next = user->next;
		    break;
		}
	user->next = connect_list;
	connect_list = user;

	spew_term(me, fd, me->t_rows, me->t_cols);
	user_winch = 1;
	add_fd(fd, read_user);
    }
}

/* Initial Handshaking:  delete his invitation (if it exists) and send
 * my edit keys.
 */
static void
contact_user(fd)
  int fd;
{
    register yuser *user;
    register int n;
    int socklen;

    remove_fd(fd);
    if((user = fd_to_user[fd]) == NULL)
    {
	show_error("contact_user: unknown contact");
	return;
    }
    (void)send_dgram(user, DELETE_INVITE);
    socklen = sizeof(struct sockaddr_in);
    if((n = accept(fd, (struct sockaddr *) &(user->sock), &socklen)) < 0)
    {
	free_user(user);
	show_error("connect_user: accept() failed");
	return;
    }
    close(fd);
    fd_to_user[fd] = NULL;

    user->fd = n;
    fd_to_user[user->fd] = user;
    add_fd(user->fd, connect_user);
    (void)write(user->fd, me->edit, 3);	/* send the edit keys */
}

/* Do a word wrap.
 */
static int
word_wrap(user)
  register yuser *user;
{
    register int i, x, bound;
    static ychar temp[20];

    x = user->x;
    if((bound = (x >> 1)) > 20)
	bound = 20;
    for(i = 1; i < bound && user->scr[user->y][x-i] != ' '; i++)
	temp[i] = user->scr[user->y][x-i];
    if(i >= bound)
	return -1;
    move_term(user, user->y, x - i);
    clreol_term(user);
    newline_term(user);
    for(i--; i >= 1; i--)
	addch_term(user, temp[i]);
    return 0;
}

/* Ring a user.  If he has an auto-invitation port established then talk
 * to that instead of messing up his screen.
 */
static int
announce(user)
  yuser *user;
{
    register int rc, fd;

    errno = 0;
    while((rc = send_dgram(user, AUTO_LOOK_UP)) == 0)
    {
	/* he has an auto-invite port established */

	if((fd = connect_to(NULL)) < 0)
	{
	    if(fd == -3) /* it's one of my sockets... *sigh* */
		break;
	    if(fd == -2) /* connection refused -- they hung up! */
	    {
		(void)send_dgram(user, AUTO_DELETE);
		errno = 0;
		continue;
	    }
	    return -1;
	}
	/* Go ahead and use the Ytalk version 2.? auto-announce
	 * packet.
	 */
	v2p.code = V2_AUTO;
	strncpy(v2p.name, me->user_name, V2_NAMELEN);
	strncpy(v2p.host, me->host_name, V2_HOSTLEN);
	v2p.name[V2_NAMELEN-1] = '\0';
	v2p.host[V2_HOSTLEN-1] = '\0';
	(void)write(fd, &v2p, V2_PACKLEN);
	close(fd);
	return 0;
    }
    if(rc == -1)
	return -1;

    errno = 0;
    if((rc = send_dgram(user, ANNOUNCE)) == 0)
	return 0;
    if(rc == 4)	/* mesg n (refusing messages) */
	return 1;
    return -1;
}

/* ---- global functions ---- */

/* Invite a user into the conversation.
 */
void
invite(name, send_announce)
  register char *name;
  int send_announce;
{
    register int rc;
    char *hisname, *hishost, *histty;
    yuser *user;

    /* First break down the username into login name and login host,
     * assuming our host as a default.
     */

    hisname = str_copy(name);
    hishost = NULL;
    histty  = NULL;
    for(name = hisname; *name; name++)
    {
	if(*name == '@')
	{
	    *name = '\0';
	    hishost = name+1;
	}
	if(*name == '#')
	{
	    *name = '\0';
	    histty = name+1;
	}
    }
    user = new_user(hisname, hishost, histty);
    free(hisname);
    if(user == NULL)
	return;

    /* Now send off the invitation */

    user->next = wait_list;
    wait_list = user;
    user_winch = 1;
    while((rc = send_dgram(user, LOOK_UP)) == 0)
    {
	/* We are expected... */
	if((rc = connect_to(user)) < 0)
	{
	    if(rc == -3) /* it's one of my sockets... *sigh* */
		break;
	    if(rc == -2) /* connection refused -- they hung up! */
	    {
		(void)send_dgram(user, DELETE);
		continue;
	    }
	    free_user(user);
	    return;
	}
	user->last_invite = (ylong)time(NULL);
	add_fd(user->fd, connect_user);
	(void)write(user->fd, me->edit, 3);	/* send the edit keys */
	return;
    }
    if(rc == -1)
	return;

    /* Leave an invitation for him, and announce ourselves. */

    if(send_announce)
    {
	sprintf(errstr, "Ringing %s...", user->user_name);
	msg_term(me, errstr);
    }
    if(newsock(user) != 0)
    {
	free_user(user);
	return;
    }
    (void)send_dgram(user, LEAVE_INVITE);
    user->last_invite = (ylong)time(NULL);
    if(send_announce && (rc = announce(user)) != 0)
    {
	(void)send_dgram(user, DELETE_INVITE);
	if(rc > 0)
	    sprintf(errstr, "%s refusing messages", user->full_name);
	else
	    sprintf(errstr, "%s not logged in", user->full_name);
	show_error(errstr);
	free_user(user);
	return;
    }
    add_fd(user->fd, contact_user);
}

/* Periodic housecleaning.
 */
void
house_clean()
{
    register yuser *u, *next;
    ylong t;
    static char estr[80];
    static ylong last_auto = 0;
    int answer, rc;

    t = (ylong)time(NULL);

    if(t - last_auto >= 30)
    {
	last_auto = t;
	if(send_auto(LEAVE_INVITE) != 0)
	{
	    show_error("house_clean: send_auto() failed");
	    kill_auto();
	}
    }

    for(u = wait_list; u; u = next)
    {
	next = u->next;
	if(t - u->last_invite >= 30)
	{
	    (void)send_dgram(u, LEAVE_INVITE);
	    u->last_invite = t = (ylong)time(NULL);
	    if(!(def_flags & FL_RING))
	    {
		if(input_flag)
		    continue;
		sprintf(estr, "Rering %s?", u->full_name);
		answer = yes_no(estr);
		t = (ylong)time(NULL);
		if(answer == 'n')
		    continue;
	    }
	    if((rc = announce(u)) != 0)
	    {
		(void)send_dgram(u, DELETE_INVITE);
		if(rc > 0)
		    sprintf(errstr, "%s refusing messages", u->full_name);
		else
		    sprintf(errstr, "%s not logged in", u->full_name);
		show_error(errstr);
		free_user(u);
	    }
	}
    }
}

void
send_winch(user)
  yuser *user;
{
    register yuser *u;

    v3w.rows = htons(user->t_rows);
    v3w.cols = htons(user->t_cols);

    if(user == me)
    {
	v3w.code = V3_MYWIN;
	for(u = connect_list; u; u = u->next)
	    if(u->remote.vmajor > 2)
		send_oob(u->fd, &v3w, V3_WINCHLEN);
	winch_exec();
    }
    else if(user->remote.vmajor > 2)
    {
	v3w.code = V3_YOURWIN;
	send_oob(user->fd, &v3w, V3_WINCHLEN);
    }
}

void
send_region()
{
    register yuser *u;

    v3w.code = V3_REGION;
    v3w.rows = htons(me->rows);
    v3w.cols = htons(me->cols);

    for(u = connect_list; u; u = u->next)
	if(u->remote.vmajor > 2)
	    send_oob(u->fd, &v3w, V3_WINCHLEN);
}

void
send_end_region()
{
    register yuser *u;

    v3w.code = V3_REGION;
    v3w.rows = htons(0);
    v3w.cols = htons(0);

    for(u = connect_list; u; u = u->next)
	if(u->remote.vmajor > 2)
	    send_oob(u->fd, &v3w, V3_WINCHLEN);
}

/* Send some output to a given user.  Sends the output to all connected
 * users if the given user is either "me" or NULL.
 */
void
send_users(user, buf, len)
  yuser *user;
  ychar *buf;
  register int len;
{
    register ychar *o, *b;
    register yuser *u;
    static ychar *o_buf = NULL;
    static int o_len = 0;

    /* data transparency */

    if((len << 1) > o_len)
    {
	o_len = (len << 1) + 512;
	o_buf = (ychar *)realloc_mem(o_buf, o_len);
    }
    for(b = buf, o = o_buf; len > 0; b++, len--)
    {
	*(o++) = *b;
	if(*b == V3_OOB)
	    *(o++) = V3_OOB;
    }

    if(user && user != me)
    {
	if(user->fd > 0)	/* just to be sure... */
	{
	    if(user->remote.vmajor > 2)
		(void)write(user->fd, o_buf, o - o_buf);
	    else
		(void)write(user->fd, buf, b - buf);
	}
    }
    else
	for(u = connect_list; u; u = u->next)
	    if(u->remote.vmajor > 2)
		(void)write(u->fd, o_buf, o - o_buf);
	    else
		(void)write(u->fd, buf, b - buf);
}

/* Display user input.  Emulate ANSI.
 */
void
show_input(user, buf, len)
  yuser *user;
  register ychar *buf;
  register int len;
{
    if(user->got_esc)
    {
process_esc:
	for(; len > 0; len--, buf++)
	{
	    if(*buf >= '0' && *buf <= '9' && user->got_esc > 1)
	    {
		user->av[user->ac] = (user->av[user->ac] * 10) + (*buf - '0');
		continue;
	    }
	    switch(*buf)
	    {
		case ';':	/* arg separator */
		    if(user->ac < MAXARG-1)
			user->av[++(user->ac)] = 0;
		    break;
		case '[':
		    user->got_esc = 2;
		    break;
		case '?':
		    if(user->got_esc == 2)
			user->got_esc = 3;
		    else
			user->got_esc = 0;
		    break;
		case '7':	/* save cursor */
		    user->sy = user->y;
		    user->sx = user->x;
		    user->got_esc = 0;
		    break;
		case '8':	/* restore cursor */
		    move_term(user, user->sy, user->sx);
		    user->got_esc = 0;
		    break;
		case '@':
		    if(user->got_esc == 2)	/* add char */
		    {
			if(user->av[0] == 0)
			    add_char_term(user, 1);
			else
			    add_char_term(user, user->av[0]);
		    }
		    user->got_esc = 0;
		    break;
		case 'A':	/* move up */
		    if(user->av[0] == 0)
			move_term(user, user->y - 1, user->x);
		    else if(user->av[0] > user->y)
			move_term(user, 0, user->x);
		    else
			move_term(user, user->y - user->av[0], user->x);
		    user->got_esc = 0;
		    break;
		case 'B':	/* move down */
		    if(user->av[0] == 0)
			move_term(user, user->y + 1, user->x);
		    else
			move_term(user, user->y + user->av[0], user->x);
		    user->got_esc = 0;
		    break;
		case 'C':	/* move right */
		    if(user->av[0] == 0)
			move_term(user, user->y, user->x + 1);
		    else
			move_term(user, user->y, user->x + user->av[0]);
		    user->got_esc = 0;
		    break;
		case 'D':	/* move left */
		    if(user->av[0] == 0)
			move_term(user, user->y, user->x - 1);
		    else if(user->av[0] > user->x)
			move_term(user, user->y, 0);
		    else
			move_term(user, user->y, user->x - user->av[0]);
		    user->got_esc = 0;
		    break;
		case 'H':	/* move */
		    if(user->av[0] > 0)
			user->av[0]--;
		    if(user->av[1] > 0)
			user->av[1]--;
		    move_term(user, user->av[0], user->av[1]);
		    user->got_esc = 0;
		    break;
		case 'J':	/* clear to end of screen */
		    clreos_term(user);
		    user->got_esc = 0;
		    break;
		case 'K':	/* clear to end of line */
		    clreol_term(user);
		    user->got_esc = 0;
		    break;
		case 'L':
		    if(user->got_esc == 2)	/* add line */
		    {
			if(user->av[0] == 0)
			    add_line_term(user, 1);
			else
			    add_line_term(user, user->av[0]);
		    }
		    user->got_esc = 0;
		    break;
		case 'M':
		    if(user->got_esc == 2)	/* delete line */
		    {
			if(user->av[0] == 0)
			    del_line_term(user, 1);
			else
			    del_line_term(user, user->av[0]);
		    }
		    else			/* reverse scroll */
			rev_scroll_term(user);
		    user->got_esc = 0;
		    break;
		case 'P':
		    if(user->got_esc == 2)	/* del char */
		    {
			if(user->av[0] == 0)
			    del_char_term(user, 1);
			else
			    del_char_term(user, user->av[0]);
		    }
		    user->got_esc = 0;
		    break;
		case 'S':	/* forward scroll */
		    scroll_term(user);
		    user->got_esc = 0;
		    break;
		case 'r':	/* set scroll region */
		    if(user->av[0] > 0)
			user->av[0]--;
		    if(user->av[1] > 0)
			user->av[1]--;
		    set_scroll_region(user, user->av[0], user->av[1]);
		    user->got_esc = 0;
		    break;
		default:
		    user->got_esc = 0;
	    }
	    if(user->got_esc == 0)
	    {
		len--, buf++;
		break;
	    }
	}
    }
    for(; len > 0; len--, buf++)
    {
	if(*buf >= ' ' && *buf <= '~')
	{
	    if(user->x + 1 >= user->cols)
	    {
		if(user->flags & FL_WRAP)
		{
		    if(*buf == ' ')
			newline_term(user);
		    else if(word_wrap(user) >= 0)
			addch_term(user, *buf);
		    else
		    {
			addch_term(user, *buf);
			newline_term(user);
		    }
		}
		else
		{
		    addch_term(user, *buf);
		    newline_term(user);
		}
	    }
	    else
		addch_term(user, *buf);
	}
	else if(*buf == user->RUB && !(user->flags & FL_RAW))
	    rub_term(user);
	else if(*buf == user->WORD && !(user->flags & FL_RAW))
	    (void)word_term(user);
	else if(*buf == user->KILL && !(user->flags & FL_RAW))
	    kill_term(user);
	else
	{
	    switch(*buf)
	    {
		case 7:		/* Bell */
		    putc(7, stderr);
		    break;
		case 8:		/* Backspace */
		    if(user->x > 0)
			move_term(user, user->y, user->x - 1);
		    break;
		case 9:		/* Tab */
		    tab_term(user);
		    break;
		case 10:	/* Newline */
		    newline_term(user);
		    break;
		case 13:	/* Return */
		    if(user->flags & FL_RAW)
			move_term(user, user->y, 0);
		    else
			newline_term(user);
		    break;
		case 27:	/* Escape */
		    user->got_esc = 1;
		    user->ac = 0;
		    user->av[0] = 0;
		    user->av[1] = 0;
		    len--, buf++;
		    goto process_esc;	/* ugly but _fast_ */
		default:
		    if(*buf < ' ')
		    {
			/* show a control char */
		    }
	    }
	}
    }
    flush_term(user);
}

/* Process keyboard input.
 */
void
my_input(user, buf, len)
  yuser *user;
  register ychar *buf;
  int len;
{
    register ychar *c;
    register int i;

    /* If someone's waiting for input, give it to them! */

    if(input_flag)
    {
	io_ptr = buf;
	io_len = len;
	return;
    }

    /* Process input normally */

    while(len > 0)
    {
	/* check for a menu in process */

	if(menu_ptr)
	{
	    io_ptr = buf;
	    io_len = len;
	    update_menu();
	    buf = io_ptr;
	    len = io_len;
	    io_len = 0;
	}

	/* check for a running process */

	if(running_process)
	{
	    io_ptr = buf;
	    io_len = len;
	    update_exec();
	    buf = io_ptr;
	    len = io_len;
	    io_len = 0;
	}
	else
	{
	    /* do normal input */

	    while(len > 0)
	    {
		c = buf;
		for(; len > 0; buf++, len--)
		{
		    if(*buf == me->old_rub)
			*buf = me->RUB;
		    else if(*buf == '\r')
			*buf = '\n';
		    else if(*buf == 3)	/* Ctrl-C */
			bail(0);
		    else if(*buf == 27)	/* Esc */
			break;
		    else if(*buf == 12 || *buf == 18) /* ^L or ^R */
			break;
		}
		if((i = buf - c) > 0)
		{
		    if(user != NULL && user != me && !(def_flags & FL_ASIDE))
			putc(7, stderr);
		    else
		    {
			show_input(me, c, i);
			send_users(user, c, i);
		    }
		}
		if(len > 0)	/* we broke for a special char */
		{
		    if(*buf == 27) /* ESC */
			break;
		    if(*buf == 12 || *buf == 18) /* ^L or ^R */
		    {
			redraw_all_terms();
			buf++, len--;
		    }
		}
	    }
	}

	/* start a menu if necessary */

	if(len > 0)
	{
	    buf++, len--;
	    show_main_menu();
	    if(len <= 0)
		update_menu();
	}
    }
}

void
lock_flags(flags)
  ylong flags;
{
    register yuser *u;

    me->flags = flags | FL_LOCKED;

    /* send to connected users... */

    v3f.code = V3_LOCKF;
    v3f.flags = htonl(me->flags);
    for(u = connect_list; u; u = u->next)
	if(u->remote.vmajor > 2)
	    send_oob(u->fd, &v3f, V3_FLAGSLEN);
}

void
unlock_flags()
{
    register yuser *u;

    me->flags = def_flags;

    /* send to connected users... */

    v3f.code = V3_UNLOCKF;
    v3f.flags = htonl(me->flags);
    for(u = connect_list; u; u = u->next)
	if(u->remote.vmajor > 2)
	    send_oob(u->fd, &v3f, V3_FLAGSLEN);
}
