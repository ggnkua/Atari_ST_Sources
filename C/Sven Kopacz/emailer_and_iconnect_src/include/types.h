#if !defined ( __TYPES__ )
#define __TYPES__

/* This one belongs to time.h, but it isn't there... */
typedef struct
{
	int	tv_sec;		/* seconds */
	int	tv_usec;	/* microseconds (NOT milliseconds!!) */
}timeval;


/* Types, macros, etc. for select() */

#define MAXFUPLIM	2048

#ifndef FD_SETSIZE
#define FD_SETSIZE MAXFUPLIM
#endif

typedef long fd_mask;

#define NFDBITS (sizeof(fd_mask) * 8)  /* 8 bits per byte */
#ifndef howmany
#define howmany(x,y)  (((x)+((y)-1))/(y))
#endif

typedef struct fd_set
{
	fd_mask	fds_bits[howmany(FD_SETSIZE, NFDBITS)];
}fd_set;

#define FD_SET(n,p)  ((p)->fds_bits[(n)/NFDBITS] |= (1 << ((n) % NFDBITS)))
#define FD_CLR(n,p)  ((p)->fds_bits[(n)/NFDBITS] &= ~(1<< ((n) % NFDBITS)))
#define FD_ISSET(n,p) ((p)->fds_bits[(n)/NFDBITS] & (1 << ((n) % NFDBITS)))

#define FD_ZERO(p) memset((char*)(p), (char) 0, sizeof(*(p)))

#endif