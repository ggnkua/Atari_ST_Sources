/*  addr.c */

#include <obdefs.h>
#include "defs.h"
#include "hinstall.h"

/* Dialogue boxes */
OBJECT *menubar;	/* menu bar */
OBJECT *about;		/* release date of this version */
OBJECT *logdev;		/* logical device numbers */
OBJECT *instfnl;	/* final warning for installing driver */
OBJECT *unstfnl;	/* final warning for removing driver */

/* Error messages */
char *nomemory;		/* not enough memory */
char *noavdrv;		/* no available drive for installation */
char *cantinst;		/* cannot install driver */
char *rootread;		/* root sector read error */
char *rootwrit;		/* root sector write error */
char *bootread;		/* boot sector read error */
char *bootwrit;		/* boot sector write error */
char *wrdvrerr;		/* error when writing driver */
char *crdvrerr;		/* error when creating driver destination */
char *opdvrerr;		/* error when opening driver source */
char *nodriver;		/* no existing driver on disk */

getalladdr()
{
    /* get addresses of all dialogue boxes */
    if (rsrc_gaddr(0, MENUBAR, &menubar) == 0
	|| rsrc_gaddr(0, ABOUT, &about) == 0
	|| rsrc_gaddr(0, LOGDEV, &logdev) == 0
	|| rsrc_gaddr(0, INSTFNL, &instfnl) == 0
	|| rsrc_gaddr(0, UNSTFNL, &unstfnl) == 0)
	return ERROR;

    /* get addresses of all error messages */
    if (rsrc_gaddr(5, NOMEMORY, &nomemory) == 0
	|| rsrc_gaddr(5, NOAVDRV, &noavdrv) == 0
	|| rsrc_gaddr(5, CANTINST, &cantinst) == 0
	|| rsrc_gaddr(5, ROOTREAD, &rootread) == 0
	|| rsrc_gaddr(5, ROOTWRIT, &rootwrit) == 0
	|| rsrc_gaddr(5, BOOTREAD, &bootread) == 0
	|| rsrc_gaddr(5, BOOTWRIT, &bootwrit) == 0
	|| rsrc_gaddr(5, WRDVRERR, &wrdvrerr) == 0
	|| rsrc_gaddr(5, CRDVRERR, &crdvrerr) == 0
	|| rsrc_gaddr(5, OPDVRERR, &opdvrerr) == 0
	|| rsrc_gaddr(5, NODRIVER, &nodriver) == 0)
	return ERROR;
	
    return OK;
}

