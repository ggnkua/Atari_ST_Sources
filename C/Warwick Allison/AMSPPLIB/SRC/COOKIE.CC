#include <stdio.h>
#include <osbind.h>
#include <sysvars.h>

static int cookie;
static int cookieval;
static int getcookie()
{
	if (*_p_cookies) {
		cookieval=(*_p_cookies)[cookie*2+1];
		cookie=(*_p_cookies)[cookie*2];
	} else {
		cookie=0;
		cookieval=0;
	}
}
static int findcookie()
{
	if (*_p_cookies) {
		int i;
		for (i=0; (*_p_cookies)[i] && (*_p_cookies)[i]!=cookie; i+=2)
			;
		if ((*_p_cookies)[i]==cookie) {
			cookieval=(*_p_cookies)[i+1];
		} else {
			cookie=0;
			cookieval=0;
		}
	} else {
		cookie=0;
		cookieval=0;
	}
}

int GetCookieByNumber(int i)
{
	cookie=i;
	Supexec(getcookie);
	return cookie;
}

int GetCookie(int i)
{
	cookie=i;
	Supexec(findcookie);
	return cookieval;
}

int GetCookieNamed(char name[4])
{
	return GetCookie((name[0]<<24)|(name[1]<<16)|(name[2]<<8)|name[3]);
}
