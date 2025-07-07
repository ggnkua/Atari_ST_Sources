/*
 * Copyright 1992 Eric R. Smith. All rights reserved.
 * Redistribution is permitted only if the distribution
 * is not for profit, and only if all documentation
 * (including, in particular, the file "copying")
 * is included in the distribution in unmodified form.
 * THIS PROGRAM COMES WITH ABSOLUTELY NO WARRANTY, NOT
 * EVEN THE IMPLIED WARRANTIES OF MERCHANTIBILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN
 * RISK.
 */
#include <osbind.h>
#include <gemfast.h>
#include <aesbind.h>
#include <stdlib.h>
#include <string.h>
#include "xgem.h"
#include "toswin_w.h"
#include "twdefs.h"
#include "twproto.h"

static char spath[128];
static char sname[128];

static char *default_spath[] =
{
	"C:\\CLIPBRD",
	"U:\\CLIPBRD",
	"A:\\CLIPBRD",
	0
};

static void
massage(path)
	char *path;
{
	char *s;

	if (!*path) {
		*path++ = '\\';
		*path = 0;
	}
	for (s = path; *s; s++) ;

	if (s[-1] == '\\')
		return;		/* already canonical form */

	strcpy(s, "\\*.*");
	if (Fsfirst(s, 0xff) == 0) {	/* OK, this is a real directory */
		s[1] = 0;
		return;
	}
	while (s > path && *s != '\\') --s;
	if (s == path)
		*s++ = '\\';
	else
		s++;

	*s = 0;
}

static int
exists(x)
	char *x;
{
	return Fsfirst(x, 0xff) == 0;
}

void
write_scrap(file, data, len)
	char *file, *data;
	int len;
{
	int i, fd;
	char *s, *t;
	char *dta;

	spath[0] = 0;
	i = scrp_read(spath);
	if (i == 0 || !spath[0]) {	/* error -- no scrap directory */
		for (i = 0; default_spath[i]; i++) {
			if (exists(default_spath[i])) {
				strcpy(spath, default_spath[i]);
				break;
			}
		}
		if (!default_spath[i]) {
			strcpy(spath, default_spath[0]);
			if ((Dsetdrv(Dgetdrv()) & 0x4) == 0)
				spath[0] = 'A';
			(void)Dcreate(spath);
		}
	}
	massage(spath);		/* get it into canonical format */

/* clear the scrapboard directory */
	dta = (char *)Fgetdta();
	s = sname;
	t = spath;
	while (*t) {
		*s++ = *t++;
	}
	strcpy(s, "SCRAP.*");
	i = Fsfirst(sname, 2);
	while (i == 0) {
		strcpy(s, dta+30);
		(void)Fdelete(sname);
		i = Fsnext();
	}
	strcpy(s, file);
	fd = Fcreate(sname, 0);
	if (fd < 0) {
		form_alert(1, AlertStrng(NOSCRAP));
		return;
	}
	i = Fwrite(fd, (long)len, data);
	if (i != len) {
		form_alert(1, AlertStrng(SCRAPERR));
	}
	(void)Fclose(fd);
	scrp_write(spath);
}

char *
read_scrap(name)
	char *name;
{
	int i;
	int fd;
	long len, r;
	char *data;

	i = scrp_read(spath);
	if (i == 0) return 0;

	massage(spath);
	strcpy(sname, spath);
	strcat(sname, name);

	fd = Fopen(sname, 0);
	if (fd < 0)
		return 0;

	len = Fseek(0L, fd, 2);
	(void)Fseek(0L, fd, 0);
	if (len >= 0) {
		data = malloc((size_t)len+1);
		if (data) {
			r = Fread(fd, len, data);
			if (r <= 0) {
				free(data);
				data = 0;
			} else {
				data[r] = 0;
			}
		}
	} else {
		data = 0;
	}
	(void)Fclose(fd);
	return data;
}

int
scrap_exists(name)
	char *name;
{
	int i, fd;

	i = scrp_read(spath);
	if (i == 0) return 0;
	massage(spath);
	strcpy(sname, spath);
	strcat(sname, name);
	fd = Fopen(sname, 0);
	if (fd < 0)
		return 0;
	(void)Fclose(fd);
	return 1;
}
