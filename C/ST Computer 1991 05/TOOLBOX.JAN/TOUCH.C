/*
 * Listing 1.19, Datei : touch.c
 * Programm            : TOUCH - Aktualisierung der
 *                       Modifikationszeit von
 *                       Dateien
 * Modifikationsdatum  : 16-Nov-89
 * Abh„ngigkeiten      : stdio.h, string.h, osbind.h,
 *                       local.h, atom.h, expand.h
 */
 
#include <stdio.h>
#include <string.h>
#include <osbind.h>
#include "local.h"
#include "atom.h"
#include "expand.h"

/*
 * Funktionen   : touch_flist, touch_dir, touch_dlist
 *
 * Parameter    : touch_flist(path, flist);
 *                touch_dir(dir);
 *                touch_dlist(dlist);
 *                char           *path;
 *                FILE_DESC_LIST flist;
 *                DIR_DESC_ITEM  dir;
 *                DIR_DESC_LIST  dlist;
 *
 * Aufgabe      :
 *
 * Aktualisierung der Modifikationszeit aller in
 * <dlist> befindlichen Dateien oder Verzeichnisse.
 */

void touch_flist(path, list)
char           *path;
FILE_DESC_LIST list;
{   char  filepath[100];
    short fhandle;

    while (list != NULL) {
        if (!(list->fdesc.fattr & 0x10)) {
            sprintf(filepath, "%s\\%s", path,
                    list->fdesc.fname);
            if (!ftouch(filepath))
                fprintf(stderr,
                        "touch: Can't touch %s",
                        filepath);
        }
        list = list->next;
    }
}

void touch_dir(dir)
DIR_DESC_ITEM dir;
{   if (strlen(dir.dirpath) == 3 &&
        dir.dirpath[2] == '\\')
        dir.dirpath[2] = 0;
    touch_flist(dir.dirpath, dir.flist);
}

void touch_dlist(dlist)
DIR_DESC_LIST dlist;
{   if (dlist != NULL) {
        touch_dir(*dlist);
        touch_dlist(dlist->next);
    }
}

/*
 * Funktion     : touch
 *
 * Parameter    : ok = touch(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos touch.
 */

BOOLEAN touch(argc, argv)
short argc;
char  *argv[];
{   DIR_DESC_LIST dlist;
    BOOLEAN       start = TRUE;
    short         i;

    if (argc >= 2) {
        for (i = 1; i < argc; i++) {
            if (start) {
                dlist = built_dlist(argv[i],
                                    FALSE, TRUE,
                                    FALSE, 0);
                start = dlist->flist ==
                        (FILE_DESC_LIST)ERROR;
            }
            else
                dlist = expand_dlist(dlist, argv[i],
                                     FALSE, TRUE,
                                     FALSE, 0);
        }
        if (!start) {
            touch_dlist(dlist);
            drop_dlist(dlist);
        }
    }
    else {
        fprintf(stderr,
            "touch: need at least one parameter\n");
        return(FALSE);
    }
    return(TRUE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!touch(argc, argv))
        exit(1);
    exit(0);
}
