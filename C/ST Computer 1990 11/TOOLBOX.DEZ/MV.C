/*
 * Listing 1.14, Datei : mv.c
 * Programm            : MV - Dateien bewegen
 * Modifikationsdatum  : 20-Nov-89
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
 * Funktionen   : mv_flist, mv_dir, mv_dlist
 *
 * Parameter    : mv_flist(srcpath, destpath,
 *                         flist, inter);
 *                mv_dir(dir, cpath, inter);
 *                mv_dlist(dlist, cpath, inter);
 *                char           *srcpath,
 *                               *destpath,
 *                               *cpath ;
 *                FILE_DESC_LIST flist;
 *                BOOLEAN        inter;
 *                DIR_DESC_ITEM  dir;
 *                DIR_DESC_LIST  dlist;
 *
 * Aufgabe      :
 *
 * Rekursives Bewegen der Dateien aus <dlist>,
 * relativ zum Quellpfad <srcpath> und zum Zielpfad
 * <destpath>. GemÑû dem Wert von <inter> wird beim
 * öberschreiben von bestehenden Dateien entweder
 * "interaktiv" zurÅckgefragt, oder nicht. Die Dateien
 * und Verzeichnisse aus <destpath> werden wenn
 * mîglich entfernt.
 */

void mv_flist(srcpath, destpath, list, inter)
char           *srcpath,
               *destpath;
FILE_DESC_LIST list;
BOOLEAN        inter;
{   char  srcfile[100],
          destfile[100];
    short attr;

    while (list != NULL) {
        sprintf(srcfile, "%s\\%s", srcpath,
                list->fdesc.fname);
        sprintf(destfile, "%s\\%s", destpath,
                list->fdesc.fname);
        if (list->fdesc.fattr & 0x10) {
            if (!fisdir(destfile))
                if (Dcreate(destfile) != 0) {
                    fprintf(stderr,
                      "Can't create %s\n", destfile);
                    return;
                }
            mv_flist(srcfile, destfile, list->down,
                     inter);
            if (Ddelete(srcfile) != 0) {
                fprintf(stderr, "Can't delete %s\n",
                        srcfile);
                return;
            }
        }
        else if (!amv(srcfile, destfile, inter))
            fprintf(stderr, "Can't move %s to %s\n",
                    srcfile, destfile);
        list = list->next;
    }
}

void mv_dir(dir, cpath, inter)
DIR_DESC_ITEM dir;
char          *cpath;
BOOLEAN       inter;
{   if (strlen(dir.dirpath) == 3 &&
        dir.dirpath[2] == '\\')
        dir.dirpath[2] = 0;
    if (strlen(cpath) == 3 &&
        cpath[2] == '\\')
        cpath[2] = 0;
    mv_flist(dir.dirpath, cpath, dir.flist, inter);
    if (Ddelete(dir.dirpath) != 0)
        fprintf(stderr, "Can't remove %s\n",
                dir.dirpath);
}

void mv_dlist(dlist, cpath, inter)
DIR_DESC_LIST dlist;
char          *cpath;
BOOLEAN       inter;
{   if (dlist != NULL) {
        mv_dir(*dlist, cpath, inter);
        mv_dlist(dlist->next, cpath, inter);
    }
}

/*
 * Funktion     : mv
 *
 * Parameter    : ok = mv(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gemÑû den Fest-
 * legungen des Kommandos mv.
 */

static BOOLEAN echeck(okflag)
BOOLEAN okflag;
{   if (!okflag)
        fprintf(stderr, "SYNOPSIS:\n%s\n%s\n",
                "mv [ -i ] filename1 filename2",
                "mv [ -i ] filename... directory");
    return(okflag);
}

BOOLEAN mv(argc, argv)
short argc;
char  *argv[];
{   DIR_DESC_LIST dlist;
    BOOLEAN       inter  = FALSE,
                  start  = TRUE,
                  ffirst,
                  flast,
                  dfirst,
                  dlast;
    short         i,
                  istart = 1;
    char          apath[100],
                  cpath[100];

    if (argc >= 3) {
        convupper(argv[1]);
        if (strcmp(argv[1], "-I") == 0) {
            inter = TRUE;
            istart = 2;
        }
        if (argc - istart < 2)
            return(echeck(FALSE));
        else {
            for (i = istart; i < argc - 1; i++)
                if (start) {
                    dlist = built_dlist(argv[i],
                                      FALSE, FALSE,
                                      TRUE, 0);
                    start = dlist->flist == 
                            (FILE_DESC_LIST)ERROR;
                }
                else
                    dlist = expand_dlist(dlist,
                                  argv[i], FALSE,
                                  FALSE, TRUE, 0);
            if (!start) {
                if (dlist->next == NULL &&
                    dlist->flist != NULL &&
                    dlist->flist->next == NULL &&
                    !(dlist->flist->fdesc.fattr & 0x10))
                    return(echeck(amv(argv[argc - 2],
                           argv[argc - 1], inter)));
                else {
                    apwd(apath);
                    if (!fisdir(argv[argc - 1]))
                        if (fexist(argv[argc - 1]))
                            return(echeck(FALSE));
                        else if (Dcreate(argv[argc - 1])
                                 != 0)
                            return(echeck(FALSE));
                    acd(argv[argc - 1]);
                    apwd(cpath);
                    acd(apath);
                    mv_dlist(dlist, cpath, inter);
                    if (inter)
                        printf("\n");
                    drop_dlist(dlist);
                 }
            }
            else
                return(echeck(FALSE));
        }
    }
    else
        return(echeck(FALSE));
    return(TRUE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!mv(argc, argv))
        exit(1);
    exit(0);
}
