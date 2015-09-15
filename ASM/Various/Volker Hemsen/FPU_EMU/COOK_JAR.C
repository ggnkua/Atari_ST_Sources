#include <prelude.h>
#include <tos_gem.h>

typedef struct
{
	long id,val;
} COOKIE;

long stackcorr,			/* make _longframe globally available */
	 *sstack;

#define JAR			(long *)0x5a0L
#define ROM			(long *)0x4f2L
#define SFRAMEXT	(int  *)0x59eL

COOKIE * install_cookie_jar(long n)
{
	COOKIE *cookie=Malloc(sizeof(COOKIE) * n);

	if (!cookie)
		return 0L;
	(long)sstack=Super(0L);
	*JAR=(long)cookie;
	Super(sstack);
	cookie->id=0L;
	cookie->val=n;
	return cookie;
}

bool new_cookie(long cook_id,long cook_val)
{
	COOKIE *cookie,*cookieo;
	int ncookie=0;
	long jarsize;
	SYSHDR *eerste_rom,*rom_start;

	(long)sstack=Super(0L);
	{
		eerste_rom=(SYSHDR *)*ROM;
		stackcorr=*SFRAMEXT ? 8 : 6;
		if (eerste_rom->os_version >= 0x0200)
			cookie=(COOKIE *)*JAR;
	}
	Super(sstack);

	if (eerste_rom->os_version >= 0x0200)	/* context voor cookie_jar */
	{
		cookieo=cookie;
		if (!cookie)
		{
			cookie=install_cookie_jar(16);
			ncookie=0;
		othw
			for
			(
				;
				cookie->id and cookie->id ne cook_id;
				cookie++,ncookie++
			);
		}
		
		if ( cookie->id )		/* reeds geinstalleerd */
			return FALSE;

		if (cookie->val <= ncookie)
		{
			cookie=install_cookie_jar(cookie->val+8);
			for
			(
				;
				cookie->id;
				*cookie++=*cookieo++
			)
			cookie->id=0;
			cookie->val=cookieo->val+8;
		}
		jarsize=cookie->val;
		cookie->id=cook_id;
		cookie->val=cook_val;
		cookie++;
		cookie->id=0L;
		cookie->val=jarsize;
	}
	return TRUE;
}

bool get_cookie(long cookie, long *value)
{
	COOKIE *jar;

	(long)sstack = Super(0L);
	jar = *(COOKIE **)0x5a0L; /* JAR (long *)0x5a0L */
	Super(sstack);

	if (!jar)
		return FALSE;

	while(jar->id)
	{
		if (jar->id eq cookie)
		{
			if (value)
				*value = jar->val;
			return TRUE;
		}
		jar++;
	}
	return FALSE;
}
