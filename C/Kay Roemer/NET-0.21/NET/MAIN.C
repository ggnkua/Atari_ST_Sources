#include "config.h"
#include "version.h"

#ifndef XDD
#include <minimal.h>
#include <basepage.h>
#include <mintbind.h>
#include <osbind.h>
#define BP _base
#endif

#include "atarierr.h"
#include "file.h"
#include "kerbind.h"


extern struct dev_descr sockdev_descr;
struct kerinfo *KERINFO;
char sockdev_name[] = "u:\\dev\\socket";

static void	welcome (void);

/* Put initializer functions for your modules here. */
extern void	unix_init (void);

void (*init_func[]) (void) = {
	unix_init,
	0
};

#ifdef XDD
DEVDRV *
init (info)
	struct kerinfo *info;
{
	short i;
	long r;
	
	KERINFO = info;
	welcome ();

	r = d_cntl (DEV_INSTALL, sockdev_name, &sockdev_descr);
	if (!r || r == EINVFN) {
		c_conws ("Cannot install socket device\r\n");
		return (DEVDRV *)0;
	}
	for (i = 0; init_func[i]; ++i) {
		(*init_func[i]) ();
	}
	return (DEVDRV *)1;
}

void
welcome (void)
{
	c_conws ("MiNT-Net " stringify(NET_MAJ) "." stringify(NET_MIN)
		 " PL " stringify(NET_PL) ", "  NET_STATUS "\r\n");
	c_conws ("(w) 1993, Kay Roemer.\r\n\r\n");
}

#else

int
main (argc, argv)
	short argc;
	char *argv[];
{
	short i;

	welcome ();
	KERINFO = (struct kerinfo *)Dcntl (DEV_INSTALL, sockdev_name,
					   &sockdev_descr);
	if (!KERINFO || ((long)KERINFO) == EINVFN) {
		Cconws ("Cannot install socket device\r\n");
		Pterm (1);
	}
	for (i = 0; init_func[i]; ++i) {
		(*init_func[i]) ();
	}
	Ptermres(256L + BP->p_tlen + BP->p_dlen + BP->p_blen, 0);
	/* NOTREACHED */
	return 0;
}

void
welcome (void)
{
	Cconws ("MiNT-Net " stringify(NET_MAJ) "." stringify(NET_MIN)
		" PL " stringify(NET_PL) ", " NET_STATUS "\r\n");
	Cconws ("(w) 1993, Kay Roemer.\r\n\r\n");
}
#endif
