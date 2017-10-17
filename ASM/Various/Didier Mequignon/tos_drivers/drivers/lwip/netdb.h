#ifndef _NETDB_H_
#define _NETDB_H_

/*
 * Structures returned by network data base library.  All addresses are
 * supplied in host order, and returned in network order (suitable for
 * use in system calls).
 */
struct hostent {
  char *h_name;	      /* official name of host */
  char **h_aliases;   /* alias list */
  int h_addrtype;     /* host address type */
  int h_length;       /* length of address */
  char **h_addr_list;	/* list of addresses from name server */
#define	h_addr h_addr_list[0]	/* address for backward compatiblity */
};

/* Error return codes from gethostbyname() */
extern int h_errno;

#define HOST_NOT_FOUND   1 /* Authoritative Answer Host not found */
#define TRY_AGAIN	       2 /* Non-Authoritive Host not found, or SERVERFAIL */
#define NO_RECOVERY    	 3 /* Non recoverable errors, FORMERR, REFUSED, NOTIMP */
#define NO_DATA	         4 /* Valid name, no data record of requested type */
#define NO_ADDRESS NO_DATA /* no address */

#ifndef gethostbyname
struct hostent *gethostbyname(const char *name);
#endif

#endif /* _NETDB_H_ */

