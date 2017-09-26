#include	"Draconis.h"

# define ST_FDSET_LONGS 8
typedef struct st_fd_set st_fd_set;
struct st_fd_set 
{
	uint32 fds_bits [ST_FDSET_LONGS];
};

int16 cdecl st_bind			(int32 fnc, int16 sfd, struct sockaddr *address, int16 addrlen);
int16 cdecl st_closesocket		(int32 fnc, int16 sfd);
int16 cdecl st_connect		(int32 fnc, int16 sfd, struct sockaddr *servaddr, int16 addrlen);
uint32 cdecl st_get_dns		(int32 fnc, int16 no);
void cdecl st_get_loginparams	(int32 fnc, char *user, char *pass);
int16 cdecl st_get_connected		(int32 fnc);
CFG_OPT * cdecl st_get_options		(int32 fnc);
struct hostent *	cdecl st_gethostbyname		(int32 fnc, char *name);
struct hostent *	cdecl st_gethostbyaddr		(int32 fnc, char *haddr, int16 len, int16 type);
int16 cdecl st_gethostname		(int32 fnc, char *name, int16 namelen);
int32 cdecl st_gethostid		(int32 fnc);
int32	cdecl st_gethostip		(int32 fnc);
struct servent * cdecl st_getservbyname		(int32 fnc, char *name, char *proto);
struct servent * cdecl st_getservbyport		(int32 fnc, int16 port, char *proto);
int16 cdecl st_getsockname		(int32 fnc, int16 sfd, struct sockaddr *addr, int16 *namelen);
int16	cdecl st_getpeername		(int32 fnc, int16 sfd, struct sockaddr *addr, int16 *namelen);
size_t cdecl st_read			(char *fnc, int16 sfd, void *buf, size_t len);
size_t cdecl st_recv			(char *fnc, int16 sfd, void * buf, size_t len, unsigned flags);
size_t cdecl st_recvfrom		(char *fnc, int16 sfd, void * buf, size_t len, unsigned flags, struct sockaddr *addr, int16 *addr_len);
size_t cdecl st_recvmsg		(char *fnc, int16 sfd, struct msghdr *msg, uint16 flags);					 
int16 cdecl st_seek			(char *fnc, int16 sfd, size_t offset, int16 whence);
size_t cdecl st_send			(char *fnc, int16 sfd, void *buf, size_t len, uint16 flags);
size_t cdecl st_sendto		(char *fnc, int16 sfd, void *buf, size_t len, uint16 flags, struct sockaddr *addr, int16 addr_len);
size_t cdecl st_sendmsg		(char *fnc, int16 sfd, struct msghdr *msg, uint16 flags);
void cdecl st_set_loginparams	(int32 fnc, char *user, char *pass);
void cdecl st_set_options		(int32 fnc, CFG_OPT *opt_ptr);
int16 cdecl st_sethostid		(int32 fnc, int32 new_id);
int16 cdecl st_sethostip		(int32 fnc, int32 new_id);
int16 cdecl st_shutdown		(int32 fnc, int16 sfd, int16 how);
int16 cdecl st_sock_accept		(int32 fnc, int16 sfd, struct sockaddr *addr, int16 *addr_len);
int16 cdecl st_sock_listen		(int32 fnc, int16 sfd, int16 backlog);
int16 cdecl st_socket		(int32 fnc, int16 domain, int16 type, int16 protocol);
int16 cdecl st_socket_select		(int32 fnc, int16 nfds, st_fd_set *readfds, st_fd_set *writefds, st_fd_set *exceptfds, struct timeval *timeout);
size_t cdecl st_write			(int32 fnc, int16 sfd, void *buf, size_t len);
int16	cdecl st_getsockopt (int16 sfd, int16 level, int16 optname, char *optval, int16 *optlen);
int16 cdecl st_setsockopt (int16 sfd, int16 level, int16 optname, char *optval, int16 optlen);
int32 cdecl st_sockfcntl (int16 sfd, int16 cmd, int32 args);
