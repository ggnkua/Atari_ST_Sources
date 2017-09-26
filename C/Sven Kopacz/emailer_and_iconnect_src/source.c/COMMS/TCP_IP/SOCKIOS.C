/*#define iodebug*/

#include <stdio.h>
#include <stdlib.h>
#include <socket.h>
#include <sockerr.h>
#include <types.h>
#include <atarierr.h>
#include <string.h>

#include "network.h"
#include "tcp.h"
#include "udp.h"
#include "socksys.h"

#include "stiplink.h"

int cdecl getsockopt(int s, int level, int optname, void *optval, int *optlen)
{
	sock_dscr	*sd;

	while(!set_flag(SOCK_SEM));
	sd=find_sock(s);
	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}
	
	if(sd->flags & SF_SHUTDOWN)
	{
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}
		
	/* Nothing is supported on protocol level */
	if(level!=SOL_SOCKET)
	{
		clear_flag(SOCK_SEM);
		return(EOPNOTSUPP);
	}
		
	switch(optname)
	{
		/* Boolean options, on SOCK_STREAM only */
		case  SO_DEBUG				:
		case  SO_DONTROUTE		:
		case  SO_REUSEADDR		:
		case  SO_KEEPALIVE		:
		case  SO_LINGER				:
		case  SO_BROADCAST		:
		case  SO_USELOOPBACK	:
		case  SO_OOBINLINE		:
			if(sd->type==SOCK_DGRAM)
			{
				clear_flag(SOCK_SEM);
				return(EOPNOTSUPP);
			}
			if(sd->so_options & optname)
			{
				clear_flag(SOCK_SEM);
				return(E_OK);				/* = Boolean option set */
			}
			clear_flag(SOCK_SEM);
			return(ENOPROTOOPT);	/* = Boolean option not set */

		case  SO_ACCEPTCONN 	:	/* socket is listen socket? */
			if(sd->type==SOCK_DGRAM)
			{
				clear_flag(SOCK_SEM);
				return(EOPNOTSUPP);
			}
			if(sd->flags & SF_PARENT)
			{
				clear_flag(SOCK_SEM);
				return(E_OK);
			}
			clear_flag(SOCK_SEM);
			return(ENOPROTOOPT);

		/* Additonal options*/
		case  SO_SNDBUF				: /* Request sendbuffer size, opt is long, always max */
			if(*optlen < sizeof(long))
			{
				clear_flag(SOCK_SEM);
				return(EINVAL);
			}
			*optlen=(int)sizeof(long);
			*(long*)optval=x_tcp_get_sendbufsize(sd->tcp_handle);
			clear_flag(SOCK_SEM);
			return(E_OK);
			
		case  SO_RCVBUF				: /* Request recvbuffer size, opt is long, always max */
			if(*optlen < sizeof(long))
			{
				clear_flag(SOCK_SEM);
				return(EINVAL);
			}
			*optlen=(int)sizeof(long);
			*(long*)optval=0x0fffffffl;	/* due to dynamic allocation */
			clear_flag(SOCK_SEM);
			return(E_OK);
			
		case  SO_SNDLOWAT			:	/* Low water mark, always return 0 */
			if(*optlen < sizeof(long))
			{
				clear_flag(SOCK_SEM);
				return(EINVAL);
			}
			*optlen=(int)sizeof(long);
			*(long*)optval=0;
			clear_flag(SOCK_SEM);
			return(E_OK);

		case  SO_RCVLOWAT			:	/* Low water mark, always return 0 */
			if(*optlen < sizeof(long))
			{
				clear_flag(SOCK_SEM);
				return(EINVAL);
			}
			*optlen=(int)sizeof(long);
			*(long*)optval=0;
			clear_flag(SOCK_SEM);
			return(E_OK);

		case  SO_ERROR				:	/* so_error is int */
			if(*optlen < sizeof(int))
			{
				clear_flag(SOCK_SEM);
				return(EINVAL);
			}
			*optlen=(int)sizeof(int);
			*(int*)optval=sd->so_error;
			clear_flag(SOCK_SEM);
			return(sd->so_error=E_OK);

		case  SO_TYPE					:	/* type is int */
			if(*optlen < sizeof(int))
			{
				clear_flag(SOCK_SEM);
				return(EINVAL);
			}
			*optlen=(int)sizeof(int);
			*(int*)optval=sd->type;
			clear_flag(SOCK_SEM);
			return(E_OK);
		
		case  SO_SNDTIMEO			:	/* Timeout not supported */
		case  SO_RCVTIMEO			:
		case  SO_SND_COPYAVOID	:	/* Avoid copy not supported */
		case  SO_RCV_COPYAVOID	:
		default:	/* Unknown option */
			clear_flag(SOCK_SEM);
			return(EINVAL);
	}
}

int cdecl setsockopt(int s, int level, int optname, const void *optval, int *optlen)
{
	sock_dscr	*sd;

	while(!set_flag(SOCK_SEM));
	sd=find_sock(s);
	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}
	
	if(sd->flags & SF_SHUTDOWN)
	{
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}
		
	/* Nothing is supported on protocol level */
	if(level!=SOL_SOCKET)
	{
		clear_flag(SOCK_SEM);
		return(EOPNOTSUPP);
	}
		
	switch(optname)
	{
		/* Boolean options, on SOCK_STREAM only */
		/* Turn on by passing an int != 0 as optval */
		/* Turn off by passing NULL or an int==0 as optval */
		case  SO_DEBUG				:		/* ignored */
		case  SO_DONTROUTE		:		/* ignored */
		case  SO_REUSEADDR		:		/* always TRUE */
		case  SO_KEEPALIVE		:		/* ignored */
		case  SO_BROADCAST		:		/* ignored */
		case  SO_USELOOPBACK	:		/* ignored */
		case  SO_OOBINLINE		:		/* ignored */
			if(sd->type==SOCK_DGRAM)
			{
				clear_flag(SOCK_SEM);
				return(EOPNOTSUPP);
			}
			/* Set or delete */
			if(optval==NULL)
				sd->so_options&=(~optname);
			else
			{
				if(*optlen!=sizeof(int))
				{
					clear_flag(SOCK_SEM);
					return(EINVAL);
				}
				if(*(int*)optval)
					sd->so_options|=optname;
				else
					sd->so_options&=(~optname);
			}
			clear_flag(SOCK_SEM);
			return(E_OK);				

		case  SO_LINGER				:
			if(sd->type==SOCK_DGRAM)
			{
				clear_flag(SOCK_SEM);
				return(EOPNOTSUPP);
			}
			if(*optlen < sizeof(linger*))
			{
				clear_flag(SOCK_SEM);
				return(EINVAL);
			}
			if(optval==NULL)
				sd->so_options&=(~SO_LINGER);
			else
			{
				sd->so_options|=SO_LINGER;
				sd->l_onoff=((linger*)optval)->l_onoff;
				sd->l_linger=((linger*)optval)->l_linger;
			}
			clear_flag(SOCK_SEM);
			return(E_OK);
			
		case  SO_ACCEPTCONN 	:	/* only for getsockopt */
		case  SO_SNDLOWAT			:	
		case  SO_RCVLOWAT			:	
		case  SO_ERROR				:	
		case  SO_TYPE					:	
			clear_flag(SOCK_SEM);
			return(EINVAL);

		/* Additonal options*/
		case  SO_SNDBUF				: /* dynamic allocation, always ok */
		case  SO_RCVBUF				:
			clear_flag(SOCK_SEM);
			return(E_OK);
			
		case  SO_SNDTIMEO			:	/* Timeout not supported */
		case  SO_RCVTIMEO			:
		case  SO_SND_COPYAVOID	:	/* Avoid copy not supported */
		case  SO_RCV_COPYAVOID	:
		default:	/* Unknown option */
			clear_flag(SOCK_SEM);
			return(EINVAL);
	}
}


/* ms to wait when repeating select */
#define SEL_WAIT 100


int cdecl select(int nfds, fd_set	*readlist, fd_set *writelist, fd_set *exceptlist, timeval *TimeOut)
{
	sock_dscr	*sd;
	int				res, c, cont=1, wont, lookups, maxhndl, minhndl, in_this;
	long			to_wait, have_wait;
	tcb				mtcb;
	fd_set		mread, mwrite, mexce;

	#ifdef iodebug
	Dftext("[select]\r\n");
	#endif
		
	if(nfds > FD_SETSIZE)
		return(EINVAL);
		
	FD_ZERO(&mread); FD_ZERO(&mwrite); FD_ZERO(&mexce);

	if(TimeOut)
	{/* to_wait and have_wait both in ms */
		to_wait=TimeOut->tv_sec;
		to_wait*=1000l;
		to_wait+=TimeOut->tv_usec/1000;
		have_wait=0;
	}
	
	/* Count connections to look up and
	  get range of socket handles */
	lookups=0;
	maxhndl=0; minhndl=32767;
	c=nfds;
	while(c--)
	{
		/* Select readlist */
		if(readlist)
			if(FD_ISSET(c, readlist))
			{	++lookups; if(c > maxhndl) maxhndl=c; if(c < minhndl) minhndl=c;}
		/* Select writelist */
		if(writelist)
			if(FD_ISSET(c, writelist))
			{	++lookups; if(c > maxhndl) maxhndl=c; if(c < minhndl) minhndl=c;}
		if(exceptlist)
			if(FD_ISSET(c, exceptlist))
			{	++lookups; if(c > maxhndl) maxhndl=c; if(c < minhndl) minhndl=c;}
	}

	if(lookups==0)	/* Nothing to look up */
		return(0);
		
	res=0;	/* counts positive results */

	while(cont==1)
	{
		wont=0; /* counts connections that will never meet the criteria */
		c=maxhndl;
		/* Start loop upon all sockets */
		do
		{
			/* Count loopups on this socket-handle */
			in_this=0;
			if((readlist) && (FD_ISSET(c, readlist))) ++in_this;
			if((writelist) && (FD_ISSET(c, writelist))) ++in_this;
			if((exceptlist) && (FD_ISSET(c, exceptlist))) ++in_this;

			if(!in_this) continue; /* socket not of interest */

			/* socket selected, get handle */
			while(!set_flag(SOCK_SEM));
			sd=find_sock(c);
			if(sd==NULL)	/* This is no socket, selection impossible */
			{	wont+=in_this; clear_flag(SOCK_SEM); continue;}
	
			/* Get information from transport-layer */
			if(sd->type==SOCK_STREAM) /* TCP-Connection */
			{	
				if(sd->flags & SF_PARENT) /* Listen-socket */
				{
					in_this=x_check_assigned_tcb(sd->handle);
					if(in_this>=0)
						x_tcp_status(in_this, &mtcb);
					else /* No new connection, ignore this one */
					{clear_flag(SOCK_SEM); continue;}
				}
				else
				{
					if(sd->tcp_handle < 0)
						mtcb.state=TCPS_CLOSED;
					else if(x_tcp_status(sd->tcp_handle, &mtcb) < 0)	/* tcb was deletet (probably due to timeout on connection) */
						mtcb.state=TCPS_CLOSED;     /* 		^ This already puts info in mtcb */
				}
			}

			/* Select readlist */
			if((readlist) && (FD_ISSET(c, readlist)))
			{ /* TCP-Connection? */
				if(sd->type==SOCK_STREAM)
					switch(mtcb.state)
					{
						case TCPS_CLOSED:	case TCPS_CLOSING: case TCPS_LASTACK:	case TCPS_TIMEWAIT:
							++wont;
						break;
						case TCPS_CLOSEWAIT:
							/* remote host has send fin */
							if(mtcb.recv_buf_len > 0)
							{	++res; FD_SET(c, &mread); }
							else
								++wont;
						break;
						case TCPS_FINWAIT1: case TCPS_FINWAIT2: 
						case TCPS_ESTABLISHED: 
							if(mtcb.recv_buf_len > 0)
							{	++res; FD_SET(c, &mread); }
						break;
						/* Other states are ignored until they change to one of the above */
					}
				else /* UDP-Connection */
				{
					in_this=udp_status(sd->port);	/* returns number of recv- */
					if(in_this > 0)								/* buf Bytes or -1 of port */
					{	++res; FD_SET(c, &mread);	} /* not prepared for recv */
					else if(in_this < 0)
						++wont;
				}
			}
			
			/* Select writelist */
			if((writelist) && (FD_ISSET(c, writelist)))
			{
				if(sd->type==SOCK_STREAM) /* TCP-Connection */
					switch(mtcb.state)
					{
						case TCPS_CLOSED:	case TCPS_CLOSING: case TCPS_LASTACK:
						case TCPS_TIMEWAIT:	case TCPS_FINWAIT1:	case TCPS_FINWAIT2:
							++wont;
						break;
						case TCPS_ESTABLISHED: case TCPS_CLOSEWAIT:
							++res; FD_SET(c, &mwrite);
						break;
						/* Other states are ignored until they change to one of the above */
					}
				else	/* UDP-Connection, can always WRITE */
				{	++res; FD_SET(c, &mwrite);}
			}
			
			/* Select exceptlist */
			if((exceptlist) && (FD_ISSET(c, exceptlist)))
			{
				if(sd->type==SOCK_STREAM)	/* Exceptions can only occur on TCP */
				{/* and only when reading is possible */
					switch(mtcb.state)
					{
						case TCPS_CLOSED:	case TCPS_CLOSING: case TCPS_LASTACK: case TCPS_TIMEWAIT:
							++wont;
						break;
						case TCPS_ESTABLISHED: case TCPS_FINWAIT1: case TCPS_FINWAIT2: case TCPS_CLOSEWAIT:
							if(mtcb.recv_flags & 3) /* PSH or URG */
							{	++res; FD_SET(c, &mexce); }
						break;
						/* Other states are ignored until they change to one
							 of the above */
					}
				}
				else /* UPDs can never except */
					++wont;
			}

			clear_flag(SOCK_SEM);

		}while(c-- > minhndl);	/* endloop upon all sockets */
		
		if(res)
			cont=0;
		else if(wont == lookups)
			cont=-2;
		else /* Check for timeout */
		{
			if(TimeOut) /* Otherwise, wait indefinitely */
			{
				if((TimeOut->tv_sec==0) && (TimeOut->tv_usec==0))
					cont=-1;	/* Return immediately */
				else
				{/* Sleep for SEL_WAIT ms */
					iwait(SEL_WAIT);
					have_wait+=SEL_WAIT;
					if(have_wait >= to_wait)
						cont=-1;
				}
			}
		}
	}/* endwhile(cont==1) */

	if(cont==-1)	/* Timed out */
		return(0);

	if(cont==-2) /* Will never */
		return(0);
			
	/* Copy my fields to user-fields */
	/* DO NOT USE FD_ZERO ON *LIST
		 since this assumes a bitstring size of fd_set maximum */
	if(readlist)
	{
		c=maxhndl;
		do
		{
			if(FD_ISSET(c, &mread))		FD_SET(c, readlist);
			else											FD_CLR(c, readlist);
		}while(c-- > minhndl);
	}
	if(writelist)
	{
		c=maxhndl;
		do
		{
			if(FD_ISSET(c, &mwrite))	FD_SET(c, writelist);
			else											FD_CLR(c, writelist);
		}while(c-- > minhndl);
	}
	if(exceptlist)
	{
		c=maxhndl;
		do
		{
			if(FD_ISSET(c, &mexce))		FD_SET(c, exceptlist);
			else											FD_CLR(c, exceptlist);
		}while(c-- > minhndl);
	}

	return(res);
}
