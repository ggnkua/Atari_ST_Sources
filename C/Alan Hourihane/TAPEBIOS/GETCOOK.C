#include "cookie.h"
#include <osbind.h>

extern int strncmp();

static long cookie_value;
static const char *cookie;

static void
snatch_it()
{
	COOKIE *jar;

	jar = *CJAR;			/* CJAR defined in cookie.h */
	if (jar) {
		while (jar->tag.aslong != 0) {
			if (!strncmp(jar->tag.aschar, cookie, 4)) {
				cookie_value = jar->value;
				return;
			}
			jar++;
		}
	}
	cookie_value = 0;
}

long
get_cookie(ckie)
const char *ckie;
{	
	cookie = ckie;
	(void)Supexec(snatch_it);
	return cookie_value;
}
