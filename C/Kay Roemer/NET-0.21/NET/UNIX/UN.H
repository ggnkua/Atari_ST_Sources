/*
 *	Definitions for the UNIX communication domain.
 *
 *	09/26/93, kay roemer.
 */

#ifndef _UN_H
#define _UN_H

#include "socket.h"

struct sockaddr_un {
	short	sun_family;
	char	sun_path[128];
};

#define UN_PATH_OFFSET	((short)((struct sockaddr_un *)0)->sun_path)
#define UN_ADDR_SIZE	(sizeof (struct sockaddr_un))

/* Possible unix socket flags */
#define UN_ISBOUND	0x0001
#define UN_ISCONNECTED	0x0002

struct un_data {
	short		proto;		/* protocol, only 0 is allowed */
	short		flags;		/* unix socket flags */
	struct socket	*sock;		/* socket this un_data belongs to */
	long		index2;		/* index of the peer address (dgram) */
	short		head;		/* buffer head */
	short		tail;		/* buffer tail */
	short		buflen;		/* current buffer size */
	char		*buf;		/* buffer data */
	struct un_data	*next;		/* link to next un_data */
	short		backlog;	/* max. # of pending connections */
	struct sockaddr_un addr;	/* local address */
	short		addrlen;	/* length of local address */
};

/* datagram header */
struct dgram_hdr {
	short	nbytes;			/* # of bytes in the datagram */
	long	sender;			/* index of sender of this dgram */
};

static inline void
un_store_header (un, hdr)
	struct un_data *un;
	struct dgram_hdr *hdr;
{
	short i, tail;
	char *d, *s;

	tail = un->tail;
	s = (char *)hdr;
	d = un->buf;
	i = sizeof (*hdr);
	
	while (i--) {
		d[tail++] = *s++;
		if (tail >= un->buflen) tail = 0;
	}
	un->tail = tail;
}

static inline void
un_read_header (un, hdr, modify)
	struct un_data *un;
	struct dgram_hdr *hdr;
	short modify;
{
	short head, i;
	char *s, *d;

	head = un->head;
	s = un->buf;
	d = (char *)hdr;
	i = sizeof (*hdr);

	while (i--) {
		*d++ = s[head++];
		if (head >= un->buflen) head = 0;
	}
	if (modify) un->head = head;
}

#define UN_MINBUF	4096
#define UN_MAXBUF	32000

static inline short
UN_USED (un)
	struct un_data *un;
{
	register short space = un->tail - un->head;
	if (space < 0) space += un->buflen;
	return space;
}

#define UN_FREE(un)	((un)->buflen - UN_USED (un) - 1)

#define UN_HASH(i)	(((i) ^ ((i)>>8) ^ ((i)>>16) ^ ((i)>>24)) & 0xff)
#define UN_HASH_SIZE	256

#define UN_INDEX(u)	((long)(u))

/* Unix socket utility functions */
extern struct un_data	*un_lookup (long, enum so_type);
extern void		un_put (struct un_data *);
extern void		un_remove (struct un_data *);
extern long		un_resize (struct un_data *, long);
extern long		un_namei (struct sockaddr *, short, long *);	

/* Unix filename lookup cache functions */
extern void		un_cache_init (void);
extern long		un_cache_lookup (char *, long *);
extern void		un_cache_remove (char *);

/* /dev/unix initialization function */
extern long		unixdev_init (void);

#endif /* _UN_H */
