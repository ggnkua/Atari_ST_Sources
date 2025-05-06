/* user.c -- user database */

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
#include <pwd.h>
#ifdef __MINT__
# include <support.h>
#endif

extern char *getlogin();

yuser *me;			/* my user information */
yuser *user_list;		/* list of invited/connected users */
yuser *connect_list;		/* list of connected users */
yuser *wait_list;		/* list of connected users */
yuser *fd_to_user[MAX_FILES];	/* convert file descriptors to users */
yuser *key_to_user[128];	/* convert menu ident chars to users */
ylong def_flags = 0L;		/* default FL_* flags */
static ylong daemon_id;	/* running daemon ID counter */

/* ---- local functions ----- */

static int passwd_opened = 0;

static int
user_id(name)
  char *name;
{
    register struct passwd *pw;
    passwd_opened = 1;
    if((pw = getpwnam(name)) == NULL)
	return -60000;	/* for most archs, an impossible user ID */
    return pw->pw_uid;
}

static char *
user_name(uid)
  int uid;
{
    register struct passwd *pw;
    passwd_opened = 1;
    if((pw = getpwuid(uid)) == NULL)
	return NULL;
    return pw->pw_name;
}

static void
close_passwd()
{
    if(passwd_opened)
    {
	(void)endpwent();
	passwd_opened = 0;
    }
}

static void
generate_full_name(user)
  yuser *user;
{
    register char *c, *d, *ce;

    if(user->full_name == NULL)
	user->full_name = get_mem(50);
    c = user->full_name, ce = user->full_name + 49;

    for(d = user->user_name; *d && c < ce; d++)
	*(c++) = *d;

    if(c < ce)
	*(c++) = '@';
    for(d = user->host_name; *d && c < ce; d++)
	*(c++) = *d;

    if(user->tty_name[0])
    {
	if(c < ce)
	    *(c++) = '#';
	for(d = user->tty_name; *d && c < ce; d++)
	    *(c++) = *d;
    }

    *c = '\0';
}

static void
assign_key(user)
  yuser *user;
{
    register ychar old;
    static ychar key = 'a';

    if(user->key != '\0' || user == me || user_list == NULL)
	return;
    old = key;
    do {
	if(key_to_user[key] == NULL)
	{
	    key_to_user[key] = user;
	    user->key = key;
	    return;
	}

	if(key == 'z')
	    key = 'A';
	else if(key == 'Z')
	    key = 'a';
	else
	    key++;
    } while(old != key);
    user->key = '\0';
}

/* ---- global functions ----- */

/* Initialize user data structures.
 */
void
init_user()
{
    int my_uid;
    char *my_name;
    char my_host[100];

    user_list = NULL;
    connect_list = NULL;
    wait_list = NULL;
    daemon_id = getpid() << 10;
    (void)memset(fd_to_user, 0, MAX_FILES * sizeof(yuser *));
    (void)memset(key_to_user, 0, 128 * sizeof(yuser *));
    my_uid = getuid();

    /* get my username */

    if((my_name = getlogin()) != NULL)
	if(user_id(my_name) != my_uid)
	    my_name = NULL;
    if(my_name == NULL)
	my_name = user_name(my_uid);
    if(my_name == NULL)
	my_name = getlogin();
    if(my_name == NULL || my_name[0] == '\0')
    {
	show_error("Who are you?");
	bail(YTE_ERROR);
    }

    /* get my hostname */

    if(gethostname(my_host, 100) < 0)
    {
	show_error("init_user: gethostname() failed");
	bail(YTE_ERROR);
    }

    /* get my user record */

    if((me = new_user(my_name, my_host, NULL)) == NULL)
	bail(YTE_ERROR);
    me->remote.protocol = YTP_NEW;
    me->remote.vmajor = VMAJOR;
    me->remote.vminor = VMINOR;
    me->remote.pid = getpid();

    close_passwd();
}

/* Create a new user record.
 */
yuser *
new_user(name, hostname, tty)
  char *name, *hostname, *tty;
{
    register yuser *out, *u;
    ylong addr;

    /* find the host address */

    if(hostname == NULL || *hostname == '\0')
    {
	hostname = me->host_name;
	addr = me->host_addr;
    }
    else if((addr = get_host_addr(hostname)) == (ylong)-1)
    {
	sprintf(errstr, "new_user: bad host: '%s'", hostname);
	show_error(errstr);
	return NULL;
    }

    /* create the user record */

    out = (yuser *)get_mem(sizeof(yuser));
    (void)memset(out, 0, sizeof(yuser));
    out->user_name = str_copy(name);
    out->host_name = str_copy(hostname);
    out->host_addr = addr;
    if(tty)
	out->tty_name = str_copy(tty);
    else
	out->tty_name = str_copy("");
    out->d_id = daemon_id++;
    generate_full_name(out);
    assign_key(out);
    out->flags = def_flags;

    /* Actually make an effort to keep the user list in order */

    if(user_list == NULL || out->key <= user_list->key)
    {
	out->unext = user_list;
	user_list = out;
    }
    else
    {
	for(u = user_list; u->unext != NULL; u = u->unext)
	    if(out->key <= u->unext->key)
		break;
	out->unext = u->unext;
	u->unext = out;
    }
    return out;
}

void
free_user(user)
  yuser *user;
{
    register yuser *u;

    /* remove him from the various blacklists */

    if(user == user_list)
	user_list = user->unext;
    else
	for(u = user_list; u; u = u->unext)
	    if(u->unext == user)
	    {
		u->unext = user->unext;
		break;
	    }

    if(user == connect_list)
	connect_list = user->next;
    else
	for(u = connect_list; u; u = u->next)
	    if(u->next == user)
	    {
		u->next = user->next;
		break;
	    }

    if(user == wait_list)
	wait_list = user->next;
    else
	for(u = wait_list; u; u = u->next)
	    if(u->next == user)
	    {
		u->next = user->next;
		break;
	    }

    /* close him down */

    close_term(user);
    free(user->full_name);
    free(user->user_name);
    free(user->host_name);
    free(user->tty_name);
    if(user->dbuf)
	free(user->dbuf);
    if(user->output_fd > 0)
	close(user->output_fd);
    if(user->fd)
    {
	remove_fd(user->fd);
	fd_to_user[user->fd] = NULL;
	close(user->fd);
    }
    if(user->key != '\0')
	key_to_user[user->key] = NULL;
    free(user);
    if(connect_list == NULL && wait_list != NULL)
	msg_term(me, "Waiting for connection...");
    user_winch = 1;
}

/* Find a user by name/host/pid.  If name is NULL, then it is not checked.
 * If host_addr is (ylong)-1 then it is not checked.  If pid is (ylong)-1
 * then it is not checked.
 */
yuser *
find_user(name, host_addr, pid)
  char *name;
  ylong host_addr, pid;
{
    register yuser *u;

    for(u = user_list; u; u = u->unext)
	if(name == NULL || strcmp(u->user_name, name) == 0)
	    if(host_addr == (ylong)-1 || u->host_addr == host_addr)
		if(pid == (ylong)-1 || u->remote.pid == pid)
		    return u;
    
    /* it could be _me_! */

    if(name == NULL || strcmp(me->user_name, name) == 0)
	if(host_addr == (ylong)-1 || me->host_addr == host_addr)
	    if(pid == (ylong)-1 || me->remote.pid == pid)
		return me;

    /* nobody I know */

    return NULL;
}
