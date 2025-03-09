/*
 * Listing 1.18, Datei : chmod.c
 * Programm            : CHMOD - éndern des
 *                       Zugriffsmodus
 * Modifikationsdatum  : 16-Nov-89
 * AbhÑngigkeiten      : stdio.h, string.h, osbind.h,
 *                       local.h, atom.h, expand.h
 */
 
#include <stdio.h>
#include <string.h>
#include <osbind.h>
#include "local.h"
#include "atom.h"
#include "expand.h"

/*
 * Funktionen   : chmod_flist, chmod_dir, chmod_dlist
 *
 * Parameter    : chmod_flist(path, flist, setrw);
 *                chmod_dir(dir, setrw);
 *                chmod_dlist(dlist, setrw);
 *                char           *path;
 *                FILE_DESC_LIST flist;
 *                BOOLEAN        setrw;
 *                DIR_DESC_ITEM  dir;
 *                DIR_DESC_LIST  dlist;
 *
 * Aufgabe      :
 *
 * éndern des Zugriffsmodus fÅr alle innerhalb von
 * <dlist> befindlichen Dateien. Je nach Wert von
 * <setrw> wird schreibender Zugriff entweder ver-
 * geben (<setrw> ist TRUE) oder entzogen (<setrw>
 * ist FALSE).
 */

void chmod_flist(path, list, setrw)
char           *path;
FILE_DESC_LIST list;
BOOLEAN        setrw;
{   char  filepath[100];
    short attr;

    while (list != NULL) {
        if (!(list->fdesc.fattr & 0x10)) {
            sprintf(filepath, "%s\\%s", path,
                    list->fdesc.fname);
            if (setrw)
                attr = list->fdesc.fattr | 0x01;
            else
                attr = list->fdesc.fattr & 0xfe;
            Fattrib(filepath, 1, attr);
        }
        list = list->next;
    }
}

void chmod_dir(dir, setrw)
DIR_DESC_ITEM dir;
BOOLEAN       setrw;
{   if (strlen(dir.dirpath) == 3 &&
        dir.dirpath[2] == '\\')
        dir.dirpath[2] = 0;
    chmod_flist(dir.dirpath, dir.flist, setrw);
}

void chmod_dlist(dlist, setrw)
DIR_DESC_LIST dlist;
BOOLEAN       setrw;
{   if (dlist != NULL) {
        chmod_dir(*dlist, setrw);
        chmod_dlist(dlist->next, setrw);
    }
}

/*
 * Funktion     : chmod
 *
 * Parameter    : ok = chmod(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gemÑû den Fest-
 * legungen des Kommandos chmod.
 */

BOOLEAN chmod(argc, argv)
short argc;
char  *argv[];
{   DIR_DESC_LIST dlist;
    BOOLEAN       setrw,
                  start = TRUE;
    short         i;

    if (argc >= 3) {
        convupper(argv[1]);
        if (strcmp(argv[1], "+W") == 0 ||
            strcmp(argv[1], "-W") == 0) {
            setrw = strcmp(argv[1], "-W") == 0;
            for (i = 2; i < argc; i++) {
                if (start) {
                    dlist = built_dlist(argv[i],
                                        FALSE,
                                        TRUE,
                                        FALSE, 0);
                    start = dlist->flist ==
                            (FILE_DESC_LIST)ERROR;
                }
                else
                    dlist = expand_dlist(dlist,
                                         argv[i],
                                         FALSE,
                                         TRUE,
                                         FALSE, 0);
            }
            if (!start) {
                chmod_dlist(dlist, setrw);
                drop_dlist(dlist);
            }
        }
        else {
            fprintf(stderr, "chmod: SYNOPSIS: %s\n",
                 "chmod [ +w ] [ -w ] Filename...");
            return(FALSE);
        }
    }
    else {
        fprintf(stderr,
            "chmod: need at least two parameter\n");
        return(FALSE);
    }
    return(TRUE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!chmod(argc, argv))
        exit(1);
    exit(0);
}
