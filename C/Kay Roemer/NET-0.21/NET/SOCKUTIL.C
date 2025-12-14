/*
 *	Socket utility functions that are used by the socket device
 *	and the communication domains.
 *
 *	10/08/93, kay roemer.
 */

#include "config.h"
#include "kerbind.h"
#include "atarierr.h"
#include "sockerr.h"
#include "socket.h"
#include "net.h"
#include "util.h"

/* Allocate a new socket struct and initialize it.
 * Returns the address of the newly allocated socket or NULL, indicating
 * `out of memory'.
 */
struct socket *
so_create (void)
{
	struct socket *so;

	so = kmalloc (sizeof (struct socket));
	if (!so) return 0;

	so->type =	(enum so_type)0;
	so->state =	SS_VIRGIN;
	so->flags =	0;
	so->conn =	(struct socket *)0;
	so->iconn_q =	(struct socket *)0;
	so->next =	(struct socket *)0;
	so->ops =	(struct dom_ops *)0;
	so->data =	(void *)0;
	so->error =	0;
	so->rsel =	0;
	so->wsel =	0;
	so->date =	t_getdate ();
	so->time =	t_gettime ();
	so->lockpid =	0;

	return so;
}

/* Release a socket to disconnected state. */ 
void
so_release (so)
	struct socket *so;
{
	struct socket *peer, *next;
	short ostate = so->state;
	
	if (ostate != SS_VIRGIN && ostate != SS_ISDISCONNECTED) {
		so->state = SS_ISDISCONNECTING;

/* Tell all clients waiting for connections that we are closing down.
   This is done by setting there `conn'-field to zero and waking them up.
   NOTE: setting clients state to SS_ISDISCONNECTING here causes the client
   not to be able to try a second connect(), unless somewhere else its
   state is reset to SS_ISUNCONNECTED */
		if (so->flags & SO_ACCEPTCON) {
			for (peer = so->iconn_q; peer; peer = next) {
				next = peer->next;
				peer->state = SS_ISDISCONNECTING;
				peer->conn = 0;
				(*peer->ops->abort) (peer, SS_ISCONNECTING);
			}
		}

/* Remove ourselves from the incomplete connection queue of some server.
   If we are on any queue, so->state is the server we are connecting to.
   so->state is set to 0 afterwards to indicate that connect() failed. */
		if (ostate == SS_ISCONNECTING) {
			struct socket *last, *server;
			short sr;

			server = so->conn;
			if (server) {
				sr = spl7 ();
				last = server->iconn_q;
				if (last == so) {
					server->iconn_q = so->next;
				} else {
					while (last && (last->next != so))
						last = last->next;
					if (last) last->next = so->next;
				}
				spl (sr);
				so->conn = 0;
			}			
		}

/* Tell the peer we are closing down, but let the underlying protocol
   do its part first. */
		if (ostate == SS_ISCONNECTED) {
			peer = so->conn;
			peer->state = SS_ISDISCONNECTING;
			(*so->ops->abort) (peer, SS_ISCONNECTED);
		}
		(*so->ops->detach) (so);

/* No protocol data attached anymore, so we are disconnected. */
		so->state = SS_ISDISCONNECTED;
		
/* Wake anyone waiting for `so', since its state changed. */
		wake (IO_Q, (long)so);
	}
}

void
so_sockpair (so1, so2)
	struct socket *so1, *so2;
{
	so1->conn = so2;
	so2->conn = so1;
	so1->state = SS_ISCONNECTED;
	so2->state = SS_ISCONNECTED;
}

/* Put `client' on the queue of incomplete connections of `server'.
 * Blocks until the connection is accepted or it's impossible to
 * establish the connection, unless `nonblock' != 0.
 * `Backlog' is the number of pending connections allowed for `server'.
 * so_connect() will fail if there are already `backlog' clients on the
 * server queue.
 * NOTE: Before using this function to connect `client' to `server',
 * you should do the following:
 *	if (client->state == SS_ISCONNECTING) return EALREADY;
 */
long
so_connect (server, client, backlog, nonblock)
	struct socket *server, *client;
	short backlog, nonblock;
{
	struct socket *last;
	short sr, clients;
	
	if (!(server->state & SO_ACCEPTCON)) {
		DEBUG (("sockdev: so_connect: server is not listening"));
		return EINVAL;
	}
	
/* Put client on the incomplete connection queue of server. */
	client->next = 0;
	sr = spl7 ();
	last = server->iconn_q;
	if (last) {
		for (clients = 1; last->next; last = last->next)
			++clients;
		if (clients >= backlog) {
			spl (sr);
			DEBUG (("sockdev: so_connect: backlog exeeded"));
			return ETIMEDOUT;
		}
		last->next = client;
	} else {
		if (backlog == 0) {
			spl (sr);
			DEBUG (("sockdev: so_connect: backlog exeeded"));
			return ETIMEDOUT;
		}
		server->iconn_q = client;
	}
	client->state = SS_ISCONNECTING;
	client->conn = server;
	spl (sr);

/* Wake proc's selecting for reading on server, which are waiting
   for a connection request on the listening server. */
	so_wakersel (server);

	wake (IO_Q, (long)server);
	if (nonblock)
		return EINPROGRESS;
	
	while (client->state == SS_ISCONNECTING) {
		if (isleep (IO_Q, (long)client)) {
			/* Maybe someone closed the client on us. */
			return EINTR;
		}
		if (!client->conn) {
			/* Server rejected us from its queue. */
			DEBUG (("sockdev: so_connect: connection refused"));
			return ECONNREFUSED;
		}
	}
/* Now we are (at least were) connected to server. */
	return 0;
}

/* Take the first waiting client from `server's incomplete connection
 * queue and connect `newsock' to it.
 * Blocks until a connection request is available, unless `nonblock' != 0.
 */
long
so_accept (server, newso, nonblock)
	struct socket *server, *newso;
	short nonblock;
{
	struct socket *client;
	short sr;

/* Remove the first waiting client from the queue of incomplete connections.
   Go to sleep if non is waiting, unless nonblocking mode is set. */
	sr = spl7 ();
	while (!server->iconn_q) {
		if (nonblock) {
			spl (sr);
			return EWOULDBLOCK;
		}
		if (server->flags & SO_CANTRCVMORE) {
			spl (sr);
			return ECONNABORTED;
		}
		if (isleep (IO_Q, (long)server)) {
			/* may be someone closed the server on us */
			spl (sr);
			return EINTR;
		}
	}
	client = server->iconn_q;
	server->iconn_q = client->next;
	spl (sr);

/* Connect the new socket and the client together. */
	client->next = 0;
	newso->conn = client;
	client->conn = newso;
	newso->state = SS_ISCONNECTED;
	client->state = SS_ISCONNECTED;

/* Wake proc's selecting for writing on client, which are waiting
   for a connect() to finish on a nonblocking socket. */
	so_wakewsel (client);
	
	wake (IO_Q, (long)client);
	return 0;
}

/* Register a new domain `domain'. Note that one can register several
 * domains with the same `domain' value. When looking up a domain, the
 * one which was last installed is chosen.
 */
extern struct dom_ops *alldomains;

void
so_register (domain, ops)
	short domain;
	struct dom_ops *ops;
{
	ops->domain = domain;
	ops->next = alldomains;
	alldomains = ops;
}

/* Unregister all registered domains whose domain-field equals
 * to `domain'.
 */
void
so_unregister (domain)
	short domain;
{
	struct dom_ops *ops;

	ops = alldomains;
	while (ops && (ops->domain == domain))
		ops = alldomains = ops->next;

	if (ops) do {
		while (ops->next && (ops->next->domain != domain))
			ops = ops->next;
		if (ops->next) ops->next = ops->next->next;
	} while (ops->next);
}

/* so_rselect(), so_wselect(), so_wakersel(), so_wakewsel() handle
 * processes for selecting.
 */
long
so_rselect (so, proc)
	struct socket *so;
	long proc;
{
#ifdef NEW_SELECT
	if (so->rsel) return 2;
#else
	if (so->rsel) return 0;
#endif
	else {
		so->rsel = proc;
		return 0;
	}
}

long
so_wselect (so, proc)
	struct socket *so;
	long proc;
{
#ifdef NEW_SELECT
	if (so->wsel) return 2;
#else
	if (so->wsel) return 0;
#endif
	else {
		so->wsel = proc;
		return 0;
	}
}

void
so_wakersel (so)
	struct socket *so;
{
	if (so->rsel) wakeselect (so->rsel);
}

void
so_wakewsel (so)
	struct socket *so;
{
	if (so->wsel) wakeselect (so->wsel);
}
