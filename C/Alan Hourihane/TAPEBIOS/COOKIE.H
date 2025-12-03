/* header file for dealing with the cookie jar */

#ifndef _COOKIE_H
#define _COOKIE_H

union clong {
	char	aschar[4];
	long	aslong;
};

struct cookie {
	union clong tag;
	long value;
};

typedef struct cookie COOKIE;

#define CJAR	((COOKIE **) 0x5a0)

#endif /* _COOKIE_H */
