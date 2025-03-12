/*
 * Listing 1.16, Datei : rmdir.c
 * Programm            : RMDIR - L”schen von
 *                       Unterverzeichnissen
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
 * Funktionen   : rmdir_flist, rmdir_dir, rmdir_dlist
 *
 * Parameter    : rmdir_flist(path, flist);
 *                rmdir_dir(dir);
 *                rmdir_dlist(dlist);
 *                char           *path;
 *                FILE_DESC_LIST flist;
 *                DIR_DESC_ITEM  dir;
 *                DIR_DESC_LIST  dlist;
 *
 * Aufgabe      :
 *
 * L”schen der in <dlist> befindlichen Verzeichnisse.
 * Die Verzeichnisse mssen leer sein.
 */

void rmdir_flist(path, list)
char           *path;
FILE_DESC_LIST list;
{   char  filepath[100];

    while (list != NULL) {
        if (list->fdesc.fattr & 0x10) {
            sprintf(filepath, "%s\\%s", path,
                    list->fdesc.fname);
            if (Ddelete(filepath) < 0)
                fprintf(stderr,
                        "rmdir: Can't delete %s\n",
                        filepath);
        }
        list = list->next;
    }
}

void rmdir_dir(dir)
DIR_DESC_ITEM dir;
{   if (strlen(dir.dirpath) == 3 &&
        dir.dirpath[2] == '\\')
        dir.dirpath[2] = 0;
    rmdir_flist(dir.dirpath, dir.flist);
}

void rmdir_dlist(dlist)
DIR_DESC_LIST dlist;
{   if (dlist != NULL) {
        rmdir_dir(*dlist);
        rmdir_dlist(dlist->next);
    }
}

/*
 * Funktion     : rmdir
 *
 * Parameter    : ok = rmdir(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos rmdir.
 */

BOOLEAN rmdir(argc, argv)
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
            rmdir_dlist(dlist);
            drop_dlist(dlist);
        }
    }
    else {
        fprintf(stderr,
            "rmdir: need at least one parameter\n");
        return(FALSE);
    }
    return(TRUE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!rmdir(argc, argv))
        exit(1);
    exit(0);
}
