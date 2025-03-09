/*
 * Listing 1.15, Datei : rm.c
 * Programm            : RM - L”schen von Dateien
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
 * Funktionen   : rm_flist, rm_dir, rm_dlist
 *
 * Parameter    : rm_flist(path, flist, inter, rec);
 *                rm_dir(dir, inter, rec);
 *                rm_dlist(dlist, inter, rec);
 *                char           *path;
 *                FILE_DESC_LIST flist;
 *                BOOLEAN        inter,
 *                               rec;
 *                DIR_DESC_ITEM  dir;
 *                DIR_DESC_LIST  dlist;
 *
 * Aufgabe      :
 *
 * Rekursives L”schen der Dateien und Verzeichnisse
 * aus <dlist>, relativ zum Pfad <path>. Gem„ž dem
 * Wert von <inter> wird beim šberschreiben von
 * bestehenden Dateien entweder "interaktiv" zurck-
 * gefragt, oder nicht.
 */

void rm_flist(path, list, inter, rec)
char           *path;
FILE_DESC_LIST list;
BOOLEAN        inter,
               rec;
{   char  filepath[100],
          newfilepath[100];

    while (list != NULL) {
        sprintf(filepath, "%s\\%s", path,
                list->fdesc.fname);
        if (list->fdesc.fattr & 0x10) {
            if (rec) {
                rm_flist(filepath, list->down,
                         inter, rec);
                Ddelete(filepath);
            }
            else
                fprintf(stderr,
                        "rm: %s is a directory\n",
                        filepath);
        }
        else if (!arm(filepath, inter))
            fprintf(stderr, "rm: Can't delete %s\n",
                    filepath);
        list = list->next;
    }
}

void rm_dir(dir, inter, rec)
DIR_DESC_ITEM dir;
BOOLEAN       inter,
              rec;
{   if (strlen(dir.dirpath) == 3 &&
        dir.dirpath[2] == '\\')
        dir.dirpath[2] = 0;
    rm_flist(dir.dirpath, dir.flist, inter, rec);
    if (fisdir(dir.dirpath) && rec)
        Ddelete(dir.dirpath);
}

void rm_dlist(dlist, inter, rec)
DIR_DESC_LIST dlist;
BOOLEAN       inter,
              rec;
{   if (dlist != NULL) {
        rm_dir(*dlist, inter, rec);
        rm_dlist(dlist->next, inter, rec);
    }
}

/*
 * Funktion     : rm
 *
 * Parameter    : ok = rm(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos rm.
 */

BOOLEAN rm(argc, argv)
short argc;
char  *argv[];
{   DIR_DESC_LIST dlist;
    char          path[100];
    BOOLEAN       option   = TRUE,
                  start    = TRUE,
                  inter    = FALSE,
                  rec      = FALSE;
    short         i;

    for (i = 1; i < argc; i++) {
        convupper(argv[i]);
        if (option && argv[i][0] == '-') {
            if (strcmp(argv[i], "-I") == 0)
                inter = TRUE;
            else if (strcmp(argv[i], "-R") == 0)
                rec = TRUE;
            else 
                fprintf(stderr,
                   "Unknown option %s\n", argv[i]);
        }
        else {
            option = FALSE;
            if (start) {
                dlist = built_dlist(argv[i], FALSE,
                                  !rec, rec, 0);
                start = dlist->flist ==
                        (FILE_DESC_LIST)ERROR;
            }
            else
                dlist = expand_dlist(dlist, argv[i],
                           FALSE, !rec, rec, 0);
        }
    }
    if (!start) {
        rm_dlist(dlist, inter, rec);
        drop_dlist(dlist);
        if (inter)
            printf("\n");
    }
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!rm(argc, argv))
        exit(1);
    exit(0);
}
