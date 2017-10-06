/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_FSEL_H_
#define _XA_FSEL_H_

enum
{
	DP_NOTRUNC,
	DP_AUTOTRUNC,
	DP_DOSTRUNC,
	DP_SENITIVE   = 0,
	DP_NOSENSITIVE,
	DP_SAVE_ONLY,
	DP_TRUNC      = 5,
	DP_CASE
};

#define slash '/'
#define sslash "/"
#define bslash '\\'
#define sbslash "\\"

#define DRV_MAX ('z'-('a'-1) + '9'-('0'-1))

bool inq_xfs(char *p, char *dirsep);

void open_fileselector(LOCK lock, short pid, char *path, char *title, fsel_handler *s, fsel_handler *c);
void fs_updir(XA_WINDOW *w);
void init_fsel(void);

#endif
