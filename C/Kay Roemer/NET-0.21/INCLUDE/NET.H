/*
 *	Definitions for the socket layer.
 *
 *	09/27/93, kay roemer
 */
 
#ifndef _NET_H
#define _NET_H

#include "socket.h"
#include "iov.h"

/* possible socket states */
enum so_state {
	SS_VIRGIN = 0,
	SS_ISUNCONNECTED,
	SS_ISCONNECTING,
	SS_ISCONNECTED,
	SS_ISDISCONNECTING,
	SS_ISDISCONNECTED
};

/* possible socket flags */
#define SO_ACCEPTCON	0x0001		/* socket is accepting connections */
#define SO_RCVATMARK	0x0002		/* in-band and oob data are in sync */
#define SO_CANTRCVMORE	0x0004		/* shut down for receives */
#define SO_CANTSNDMORE	0x0008		/* shut down for sends */

struct socket {
	enum so_type	type;		/* socket type: SOCK_* */
	enum so_state	state;		/* socket state: SS_* */
	short		flags;		/* socket flags: SO_* */
	struct socket	*conn;		/* peer socket */
	struct socket	*iconn_q;	/* queue of imcomplete connections */
	struct socket	*next;		/* next connecting socket in list */
	struct dom_ops	*ops;		/* domain specific operations */
	void		*data;		/* domain specific data */
	short		error;		/* async. error */
	short		pgrp;		/* process group to send sinals to */
	long		rsel;		/* process selecting for reading */
	long		wsel;		/* process selecting for writing */
	short		date;		/* date stamp */
	short		time;		/* time stamp */
	short		lockpid;	/* pid of locking process */
};

/* domain, as the socket level sees it */
struct dom_ops {
	short		domain;
	struct dom_ops	*next;
	long	(*attach)	(struct socket *s, short proto);
	long	(*dup)		(struct socket *news, struct socket *olds);
	long	(*abort)	(struct socket *s, enum so_state ostate);
	long	(*detach)	(struct socket *s);
	long	(*bind)		(struct socket *s, struct sockaddr *addr,
				short addrlen);

	long	(*connect)	(struct socket *s, struct sockaddr *addr,
				short addrlen, short flags);

	long	(*socketpair)	(struct socket *s1, struct socket *s2);
	long	(*accept)	(struct socket *s, struct socket *new,
			 	short flags);

	long	(*getname)	(struct socket *s, struct sockaddr *addr,
			 	short *addrlen, short peer);
#define PEER_ADDR	0
#define SOCK_ADDR	1
	long	(*select)	(struct socket *s, short sel_type, long proc);
	long	(*ioctl)	(struct socket *s, short cmd, void *arg);
	long	(*listen)	(struct socket *s, short backlog);
	long	(*send)		(struct socket *s, struct iovec *iov,
				short niov, short block, short flags,
				struct sockaddr *addr, short addrlen);

	long	(*recv)		(struct socket *s, struct iovec *iov,
				short niov, short block, short flags,
				struct sockaddr *addr, short *addrlen);

	long	(*shutdown)	(struct socket *s, short flags);
	long	(*setsockopt)	(struct socket *s, short level, short optname,
			 	char *optval, long optlen);

	long	(*getsockopt)	(struct socket *s, short level, short optname,
			 	char *optval, long *optlen);
};

/* create a new socket */
extern struct socket 	*so_create (void);

/* release socket to unconnecting state */
extern void	so_release (struct socket *so);

/* register/unregister domains */
extern void	so_register (short dom, struct dom_ops *ops);
extern void	so_unregister (short dom);

/* add seleting proc's to the socket */
extern long	so_rselect (struct socket *s, long proc);
extern long	so_wselect (struct socket *s, long proc);

/* wake selecting proc's */
extern void	so_wakersel (struct socket *s);
extern void	so_wakewsel (struct socket *s);

/* make so1 and so2 a connected pair of sockets */
extern void	so_sockpair (struct socket *so1, struct socket *so2);

/* Put `client' on the queue of incomplete connections of `server'.
 * Blocks until the connection is accepted or it's impossible to
 * establish the connection, unless nonblock != 0.
 * `Backlog' is the number of pending connections allowed for `server'.
 * so_connect() will fail if there are already `backlog' clients on the
 * server queue.
 */
extern long	so_connect (struct socket *server, struct socket *client,
			   short backlog, short nonblock);

/* Take the first waiting client from `server's incomplete connection
 * queue and connect `newsock' to it.
 * Blocks until a connection request is available, unless nonblock != 0.
 */
extern long	so_accept (struct socket *server, struct socket *newsock,
			  short nonblock);

/* sleep and watch for interrupts */
extern short	isleep (short queue, long cond);

#endif /* _NET_H */
