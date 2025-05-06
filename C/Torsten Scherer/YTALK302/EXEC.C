/* exec.c -- run a command inside a window */

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
#include <fcntl.h>
#include <signal.h>
#include <sys/wait.h>
#ifdef USE_SGTTY
# include <sys/ioctl.h>
# ifdef hpux
#  include <sys/bsdtty.h>
#  include <sgtty.h>
# endif
#endif

int running_process = 0;	/* flag: is process running? */
static int pid;			/* currently executing process id */
static int pfd;			/* currently executing process fd */
static int prows, pcols;	/* saved rows, cols */

/* ---- local functions ---- */

#ifdef USE_SGTTY
static int
setsid()
{
    register int fd;

    if((fd = open("/dev/tty", O_RDWR)) >= 0)
    {
	ioctl(fd, TIOCNOTTY);
	close(fd);
    }
    return fd;
}
#endif

static int
getpty(name)
  char *name;
{
#ifdef __MINT__
    errno = ENOENT;
    return -1;
#else
    register int pty, tty;
    char *pty_dev = "/dev/ptc", *tt;
    extern char *ttyname();

    /* first look for a SYSV-type pseudo device */

    if((pty = open(pty_dev, O_RDWR)) >= 0)
    {
	if((tt = ttyname(pty)) != NULL)
	{
	    strcpy(name, tt);
	    return pty;
	}
	close(pty);
    }

    /* scan Berkeley-style */

    strcpy(name, "/dev/ptyp0");
    while(access(name, 0) == 0)
    {
	if((pty = open(name, O_RDWR)) >= 0)
	{
	    name[5] = 't';
	    if((tty = open(name, O_RDWR)) >= 0)
	    {
		close(tty);
		return pty;
	    }
	    name[5] = 'p';
	    close(pty);
	}

	/* get next pty name */

	if(name[9] == 'f')
	{
	    name[8]++;
	    name[9] = '0';
	}
	else if(name[9] == '9')
	    name[9] = 'a';
	else
	    name[9]++;
    }
    errno = ENOENT;
    return -1;
#endif
}

static void
exec_input(fd)
  int fd;
{
    register int rc;
    static ychar buf[MAXBUF];

    if((rc = read(fd, buf, MAXBUF)) <= 0)
    {
	kill_exec();
	errno = 0;
	show_error("command shell terminated");
	return;
    }
    show_input(me, buf, rc);
    send_users(me, buf, rc);
}

static void
calculate_size(rows, cols)
  int *rows, *cols;
{
    register yuser *u;

    *rows = me->t_rows;
    *cols = me->t_cols;

    for(u = connect_list; u; u = u->next)
	if(u->remote.vmajor > 2)
	{
	    if(u->remote.my_rows > 1 && u->remote.my_rows < *rows)
		*rows = u->remote.my_rows;
	    if(u->remote.my_cols > 1 && u->remote.my_cols < *cols)
		*cols = u->remote.my_cols;
	}
}

/* ---- global functions ---- */

/* Execute a command inside my window.  If command is NULL, then execute
 * a shell.
 */
void
execute(command)
  char *command;
{
    int fd;
    char name[20], *shell;

    if(me->flags & FL_LOCKED)
    {
	errno = 0;
	show_error("alternate mode already running");
	return;
    }
    if((fd = getpty(name)) < 0)
    {
	msg_term(me, "cannot get pseudo terminal");
	return;
    }
    if((shell = (char *)getenv("SHELL")) == NULL)
	shell = "/bin/sh";
    calculate_size(&prows, &pcols);
    if((pid = fork()) == 0)
    {
	close(fd);
	close_all();
        if(setsid() < 0)
            exit(-1);
        if((fd = open(name, O_RDWR)) < 0)
            exit(-1);
        dup2(fd, 0);
        dup2(fd, 1);
        dup2(fd, 2);

	/* tricky bit -- ignore WINCH */

#ifdef SIGWINCH
	signal(SIGWINCH, SIG_IGN);
#endif

	/* set terminal characteristics */

	set_terminal_flags(fd);
	set_terminal_size(fd, prows, pcols);
#ifndef NeXT
	putenv("TERM=vt100");
#endif

	/* execute the command */

	if(command)
	    execl(shell, shell, "-c", command, NULL);
	else
	    execl(shell, shell, NULL);
	perror("execl");
	(void)exit(-1);
    }
    if(pid < 0)
    {
	show_error("fork() failed");
	return;
    }
    set_win_region(me, prows, pcols);
    sleep(1);
    pfd = fd;
    running_process = 1;
    lock_flags(FL_RAW | FL_SCROLL);
    set_raw_term();
    add_fd(fd, exec_input);
}

/* Send input to the command shell.
 */
void
update_exec()
{
    (void)write(pfd, io_ptr, io_len);
    io_len = 0;
}

/* Kill the command shell.
 */
void
kill_exec()
{
    if(!running_process)
	return;
    remove_fd(pfd);
    close(pfd);
    running_process = 0;
    unlock_flags();
    set_cooked_term();
    end_win_region(me);
}

/* Send a SIGWINCH to the process.
 */
void
winch_exec()
{
    int rows, cols;

    if(!running_process)
	return;

    /* if the winch has no effect, return now */

    calculate_size(&rows, &cols);
    if(rows == prows && cols == pcols)
    {
	if(prows != me->rows || pcols != me->cols)
	    set_win_region(me, prows, pcols);
	return;
    }

    /* oh well -- redo everything */

    prows = rows;
    pcols = cols;
    set_terminal_size(pfd, prows, pcols);
    set_win_region(me, prows, pcols);
#ifdef SIGWINCH
    kill(pid, SIGWINCH);
#endif
}
