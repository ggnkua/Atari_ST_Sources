#include "network.h"

/* Supported version: */
#define VERSION_SUP 1

typedef struct
{
	long id, val;
}COOKIE;
COOKIE	*jar_addres;
int	find_cookie(long cid, long *cval);


int	h_errno;

cookie_struct *sint;

int sock_init(void)
{/* Returns 0 if succesful, else: 
		-1 : Sockets no installed
		-2 : Socket-version too old
	*/
	
	if(!find_cookie('SLIP', (long*)&sint))
		return(-1);
	
	if(sint->user->version < VERSION_SUP)
		return(-2);
	
	return(0);
}

/* Map user-functions */

	/* sockets */
int		socket(int af, int type, int protocol)
{
	return(sint->user->socket(af, type, protocol));
}
int 	bind(int s, const void *addr, int addrlen)
{
	return(sint->user->bind(s, addr, addrlen));
}
int 	listen(int s, int backlog)
{
	return(sint->user->listen(s, backlog));
}
int 	accept(int s, const void *addr, int *addrlen)
{
	return(sint->user->accept(s, addr, addrlen));
}
int		connect(int s, const void *addr, int addrlen)
{
	return(sint->user->connect(s, addr, addrlen));
}

int 	swrite(int s, const void *msg, int len)
{
	return(sint->user->write(s, msg, len));
}
int		send(int s, const void *msg, int len, int flags)
{
	return(sint->user->send(s, msg, len, flags));
}
int 	sendto(int s, const void *msg, int len, int flags, void *to, int tolen)
{
	return(sint->user->sendto(s, msg, len, flags, to, tolen));
}

long 	sread(int s, void *buf, long len)
{
	return(sint->user->read(s, buf, len));
}
long	recv(int s, void *buf, long len, int flags)
{
	return(sint->user->recv(s, buf, len, flags));
}
long 	recvfrom(int s, void *buf, long len, int flags, void *from, int *fromlen)
{
	return(sint->user->recvfrom(s, buf, len, flags, from, fromlen));
}

int 	select(int nfds, fd_set	*readlist, fd_set *writelist, fd_set *exceptlist, timeval *TimeOut)
{
	return(sint->user->select(nfds, readlist, writelist, exceptlist, TimeOut));
}

int		status(int s, void *mtcb) /* is (tcb*) */
{
	return(sint->user->status(s, mtcb));
}
int		shutdown(int s, int how)
{
	return(sint->user->shutdown(s, how));
}
int		sclose(int s)
{
	return(sint->user->close(s));
}

	/* misc */
int getsockname(int s, void *addr, int *addrlen)
{
	return(sint->user->getsockname(s, addr, addrlen));
}
int getpeername(int s, void *addr, int *addrlen)
{
	return(sint->user->getpeername(s, addr, addrlen));
}

int getsockopt(int s, int level, int optname, void *optval, int *optlen)
{
	return(sint->user->getsockopt(s,level,optname,optval,optlen));
}
int setsockopt(int s, int level, int optname, const void *optval, int *optlen)
{
	return(sint->user->setsockopt(s,level,optname,optval,optlen));
}

long	sfcntl(int FileDescriptor, long Command, long Argument)
{
	return(sint->user->sfcntl(FileDescriptor, Command, Argument));
}

	/* resolver */
void 	res_init(void)
{
	sint->user->res_init();
}
int 	res_query(char *dname, int class, int type, uchar *answer, int anslen)
{
	return(sint->user->res_query(dname, class, type, answer, anslen));
}
int 	res_search(char *dname, int class, int type, uchar *answer, int anslen)
{
	return(sint->user->res_search(dname, class, type, answer, anslen));
}
int 	res_mkquery(int op, char *dname, int class, int type, char *data, int datalen, void *notused, char *buf, int buflen)
{
	return(sint->user->res_mkquery(op, dname, class, type, data, datalen, notused, buf, buflen));
}
int 	res_send(char *msg, int msglen, char *answer, int anslen)
{
	return(sint->user->res_send(msg, msglen, answer, anslen));
}
int 	dn_expand(uchar *msg, uchar *eomorig, uchar *comp_dn, uchar *exp_dn, int length)
{
	return(sint->user->dn_expand(msg, eomorig, comp_dn, exp_dn, length));
}
int 	dn_comp(uchar *exp_dn, uchar *comp_dn, uchar **dnptrs, uchar **lastdnptr, int length)
{
	return(sint->user->dn_comp(exp_dn, comp_dn, dnptrs, lastdnptr, length));
}



/* Cookies */


long	jaradres(void)
{
	jar_addres=(COOKIE*)(*(long*)0x5a0l);
	return((long)jar_addres);
}

int	find_cookie(long cid, long *cval)
{ /* Sucht den Cookie (cid) und liefert dessen Wert in cval */

  /* Liefert 1, falls der Cookie gefunden wurde, sonst 0 */
  
	COOKIE	*cookie;

	Supexec(jaradres);
	cookie=jar_addres;
		
	if (!cookie)
		return(0);
		
	for(;((cookie->id)&&(cookie->id!=cid));cookie++);

	/* cookie zeigt auf gesuchten Cookie oder Nullcookie */

	if (!cookie->id)
		return(0);
	else
	{
		*cval=cookie->val;
		return(1);
	}
}

