/*************************************************
		LHarc version 1.13 (c)Yoshi, 1988-89.
		utility module : 1989/ 5/ 4

	adaption to ATARI ST with TURBO-C 1.1
	by J. Moeller 1990/01/31

HTAB = 4
*************************************************/

#include <stddef.h>
#include <ctype.h>

#ifndef __TOS__
#include <dos.h>
#else
#include <tos.h>
#endif

typedef unsigned char uchar;
typedef unsigned int  uint;
typedef unsigned long ulong;

#ifdef Japanese

#define iskanji(c) ((uchar)(c) >= 0x80 && (uchar)(c) <= 0x9f || \
		    (uchar)(c) >= 0xe0 && (uchar)(c) <= 0xfd)

/*******************************
	strupr for Japanese strings
*******************************/
uchar *j_strupr(uchar *p)
{
	uchar *q;

	for (q = p; *q; q++) {
		if (iskanji(*q)) {
			q++;
			if (*q == 0)
				break;
		} else {
			*q = toupper(*q);
		}
	}
	return p;
}

/*******************************
	strcmp for Japanese strings
*******************************/
int j_strcmp(char *p, char *q)
{
	int c, md0, md1;

	for (md0 = 0;
	     ((c = (uchar)*p - (uchar)*q) == 0) && (*p != 0); p++, q++) {
		if (md0) {
			md0 = 0;
		} else {
			md0 = iskanji((uchar)*p);
		}
	}
	if (md0 == 0) {
		md0  = iskanji((uchar)*p);
		md1 = iskanji((uchar)*q);
		if (md0) {
			if (md1 == 0) return 1;
		} else {
			if (md1) return -1;
		}
	}
	return c;
}

/*******************************
  strchr for Japanese strings
	(subset of jstrchr)
  can't search Kanji character
*******************************/
uchar *j_strchr(char *p, uint c)
{
	uchar *q, a;

	q = (uchar *)p;
	while ((a = *q) != c) {
		if (a == 0) return NULL;
		if (iskanji(a)) {
			if (*++q == 0) return NULL;
		}
		q++;
	}
	return q;
}

/*******************************
  strrchr for Japanese strings
	(subset of jstrrchr)
  can't search Kanji character
*******************************/
uchar *j_strrchr(char *p, uint c)
{
	uchar *q, *r;

	q = p - 1;
	while ((r = j_strchr(q + 1, c)) != NULL) {
		q = r;
	}
	if (q < p) return NULL;
	return q;
}
#endif

/*******************************
	get file attributes
*******************************/
int getfattr(uchar *fn)
{
#ifndef __TOS__
	_DX = (uint)fn;
	_CX = 0x8000;
	_AX = 0x4300;
	__int__(0x21);
	return _CX;
#else
	return Fattrib (fn, 0, 0);
#endif
}

/*******************************
	set file attributes
*******************************/
void setfattr(uchar *fn, int attr)
{
#ifndef __TOS__
	_DX = (uint)fn;
	_CX = attr;
	_AX = 0x4301;
	__int__(0x21);
#else
	Fattrib (fn, 1, attr);
#endif
}

/*******************************
	get the setting of
	switch character
*******************************/
#ifndef __TOS__
uchar getswchar(void)
{
	_AX = 0x3700;
	__int__(0x21);
	return _DL;
}
#endif

/*******************************
	convert '/' to '\'
	('\' code is assigned to
	the Yen-mark in Japan.)
*******************************/
void slash2yen(uchar *p)
{
	for (; *p != '\0'; p++) {
		if (*p == '/')
			*p = '\\';
	}
}

void yen2slash(uchar *p)
{
	for (; *p != '\0'; p++) {
		if (*p == '\\')
			*p = '/';
	}
}

#ifdef __TOS__
/*******************************
	copy string and return
	position of last character
*******************************/

char *stpcpy (register char *dest, register char *source)
{
	if (source == NULL)
		*dest++ = '\0';
	else
		while ((*dest++ = *source++) != '\0');

	return dest - 1;
}

/*******************************
	create a directory
*******************************/

int mkdir (char *path)
{
	return Dcreate (path);
}
#endif
