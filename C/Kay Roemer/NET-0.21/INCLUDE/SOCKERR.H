/*
 *	Socket related errors.
 *
 *	09/26/93, kay roemer.
 */

#ifndef _SOCKERR_H
#define _SOCKERR_H

#define	ENOTSOCK	-300	/* Socket operation on non-socket */
#define	EDESTADDRREQ	-301	/* Destination address required */
#define	EMSGSIZE	-302	/* Message too long */
#define	EPROTOTYPE	-303	/* Protocol wrong type for socket */
#define	ENOPROTOOPT	-304	/* Protocol not available */
#define	EPROTONOSUPPORT	-305	/* Protocol not supported */
#define	ESOCKTNOSUPPORT	-306	/* Socket type not supported */
#define	EOPNOTSUPP	-307	/* Operation not supported */
#define	EPFNOSUPPORT	-308	/* Protocol family not supported */
#define	EAFNOSUPPORT	-309	/* Address family not supported by protocol */
#define	EADDRINUSE	-310	/* Address already in use */
#define	EADDRNOTAVAIL	-311	/* Cannot assign requested address */
#define	ENETDOWN	-312	/* Network is down */
#define	ENETUNREACH	-313	/* Network is unreachable */
#define	ENETRESET	-314	/* Network dropped conn. because of reset */
#define	ECONNABORTED	-315	/* Software caused connection abort */
#define	ECONNRESET	-316	/* Connection reset by peer */
#define	EISCONN		-317	/* Socket is already connected */
#define	ENOTCONN	-318	/* Socket is not connected */
#define	ESHUTDOWN	-319	/* Cannot send after shutdown */
#define	ETIMEDOUT	-320	/* Connection timed out */
#define	ECONNREFUSED	-321	/* Connection refused */
#define	EHOSTDOWN	-322	/* Host is down */
#define	EHOSTUNREACH	-323	/* No route to host */
#define	EALREADY	-324	/* Operation already in progress */
#define	EINPROGRESS	-325	/* Operation now in progress */

/* These are not really socket errors */
#define EWOULDBLOCK	-326	/* Operation would block */
#define EINTR		-128	/* System call was interrupted */

#endif /* _SOCKERR_H */
