#include <string.h>
#include <stdlib.h>
#include <in.h>
#include <inet.h>
#include "network.h"

/* Utility */
#define isdigit(a)	((a>='0')&&(a<='9'))
#define isxdigit(a) (((a>='A')&&(a<='F'))||((a>='a')&&(a<='f')))
#define islower(a)	(a>='a')
#define isspace(a)	(a==' ')


/* * Ascii internet address interpretation routine. * The value returned is in network order. */ulong inet_addr(const char *cpp){	register const char *cp=cpp;	struct in_addr val;	if (inet_aton(cp, &val))		return (val.s_addr);	return(INADDR_NONE);}/*  * Check whether "cp" is a valid ascii representation * of an Internet address and convert to a binary address. * Returns 1 if the address is valid, 0 if not. * This replaces inet_addr, the return value from which * cannot distinguish between failure and a local broadcast address. */unsigned long inet_aton(const char *cpp, struct in_addr *addr){	register const char *cp=cpp;	register ulong val, base, n;	register char c;	ulong parts[4], *pp = parts;	for (;;) {		/*		 * Collect number up to ``.''.		 * Values are specified as for C:		 * 0x=hex, 0=octal, other=decimal.		 */		val = 0; base = 10;		if (*cp == '0') {			if (*++cp == 'x' || *cp == 'X')				base = 16, cp++;			else				base = 8;		}		while ((c = *cp) != '\0') {			if (isdigit(c)) {				val = (val * base) + (c - '0');				cp++;				continue;			}			if (base == 16 && isxdigit(c)) {				val = (val << 4) + 					(c + 10 - (islower(c) ? 'a' : 'A'));				cp++;				continue;			}			break;		}		if (*cp == '.') {			/*			 * Internet format:			 *	a.b.c.d			 *	a.b.c	(with c treated as 16-bits)			 *	a.b	(with b treated as 24 bits)			 */			if (pp >= parts + 3 || val > 0xff)				return (0);			*pp++ = val, cp++;		} else			break;	}	/*	 * Check for trailing characters.	 */	if (*cp && (!isspace(*cp)))		return (0);	/*	 * Concoct the address according to	 * the number of parts specified.	 */	n = pp - parts + 1;	switch ((int)n) {	case 1:				/* a -- 32 bits */		break;	case 2:				/* a.b -- 8.24 bits */		if (val > 0xffffffl)			return (0);		val |= parts[0] << 24;		break;	case 3:				/* a.b.c -- 8.8.16 bits */		if (val > 0xffff)			return (0);		val |= (parts[0] << 24) | (parts[1] << 16);		break;	case 4:				/* a.b.c.d -- 8.8.8.8 bits */		if (val > 0xff)			return (0);		val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);		break;	}	if (addr)		addr->s_addr = htonl(val);	return (1);}

ulong inet_network(const char *cp)
{/* From Mint-Net */
	register ulong val, base, n;	register char c;	ulong parts[4], *pp = parts;	register int i;again:	val = 0; base = 10;	if (*cp == '0')		base = 8, cp++;	if (*cp == 'x' || *cp == 'X')		base = 16, cp++;	while ((c = *cp)!=0) {		if (isdigit(c)) {			val = (val * base) + (c - '0');			cp++;			continue;		}		if (base == 16 && isxdigit(c)) {			val = (val << 4) + (c + 10 - (islower(c) ? 'a' : 'A'));			cp++;			continue;		}		break;	}	if (*cp == '.') {		if (pp >= parts + 4)			return (INADDR_NONE);		*pp++ = val, cp++;		goto again;	}	if (*cp && !isspace(*cp))		return (INADDR_NONE);	*pp++ = val;	n = pp - parts;	if (n > 4)		return (INADDR_NONE);	for (val = 0, i = 0; i < n; i++) {		val <<= 8;		val |= parts[i] & 0xff;	}	return (val);}

unsigned long inet_lnaof(struct in_addr in){	register ulong i = ntohl(in.s_addr);	if (IN_CLASSA(i))		return ((i)&IN_CLASSA_HOST);	else if (IN_CLASSB(i))		return ((i)&IN_CLASSB_HOST);	else		return ((i)&IN_CLASSC_HOST);}
struct in_addr inet_makeaddr(ulong net, ulong host){	ulong addr;	if (net < 128)		addr = (net << IN_CLASSA_NSHIFT) | (host & IN_CLASSA_HOST);	else if (net < 65536l)		addr = (net << IN_CLASSB_NSHIFT) | (host & IN_CLASSB_HOST);	else if (net < 16777216L)		addr = (net << IN_CLASSC_NSHIFT) | (host & IN_CLASSC_HOST);	else		addr = net | host;	addr = htonl(addr);	return (*(struct in_addr *)&addr);}
char *inet_ntoa(ulong in)
{
	ulong	a,b,c,d;
	char	num[20];
	static char	buf[20];
	
	a=in >> 24;
	b=(in >> 16) & 0xff;
	c=(in >> 8) & 0xff;
	d=in & 0xff;
	
	buf[0]=0;
	strcpy(buf, ultoa(a, num, 10));
	strcat(buf, ".");
	strcat(buf, ultoa(b, num, 10));
	strcat(buf, ".");
	strcat(buf, ultoa(c, num, 10));
	strcat(buf, ".");
	strcat(buf, ultoa(d, num, 10));
	
	return(buf);
}