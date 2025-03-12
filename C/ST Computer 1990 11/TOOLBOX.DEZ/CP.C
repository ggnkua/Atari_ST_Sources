/*
 * Listing 1.13, Datei : cp.c
 * Programm            : CP - Dateien kopieren
 * Modifikationsdatum  : 20-Nov-89
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
 * Funktionen   : cp_flist, cp_dir, cp_dlist
 *
 * Parameter    : cp_flist(srcpath, destpath,
 *                         flist, inter);
 *                cp_dir(dir, cpath, inter);
 *                cp_dlist(dlist, cpath, inter);
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
 * Rekursives Kopieren der Dateien aus <dlist>,
 * relativ zum Quellpfad <srcpath> und zum Zielpfad
 * <destpath>. Gem„ž dem Wert von <inter> wird beim
 * šberschreiben von bestehenden Dateien entweder
 * "interaktiv" zurckgefragt, oder nicht.
 */

void cp_flist(srcpath, destpath, list, inter)
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
                    return ;
                }
            cp_flist(srcfile, destfile, list->down,
                     inter);
        }
        else if (!acp(srcfile, destfile, inter))
            fprintf(stderr, "Can't copy %s to %s\n",
                    srcfile, destfile);
        list = list->next;
    }
}

void cp_dir(dir, cpath, inter)
DIR_DESC_ITEM dir;
char          *cpath;
BOOLEAN       inter;
{   if (strlen(dir.dirpath) == 3 &&
        dir.dirpath[2] == '\\')
        dir.dirpath[2] = 0;
    if (strlen(cpath) == 3 &&
        cpath[2] == '\\')
        cpath[2] = 0;
    cp_flist(dir.dirpath, cpath, dir.flist, inter);
}

void cp_dlist(dlist, cpath, inter)
DIR_DESC_LIST dlist;
char          *cpath;
BOOLEAN       inter;
{   if (dlist != NULL) {
        cp_dir(*dlist, cpath, inter);
        cp_dlist(dlist->next, cpath, inter);
    }
}

/*
 * Funktion     : cp
 *
 * Parameter    : ok = cp(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos cp.
 */

static BOOLEAN echeck(okflag)
BOOLEAN okflag;
{   if (!okflag)
        fprintf(stderr, "SYNOPSIS:\n%s\n%s\n",
           "cp [ -i ] filename1 filename2",
           "cp [ -i ] filename... directory");
    return(okflag);
}

BOOLEAN cp(argc, argv)
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
                    !(dlist->flist->fdesc.fattr & 0x10) &&
                    !fisdir(argv[argc - 1]))
                    return(echeck(acp(argv[argc - 2],
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
                    cp_dlist(dlist, cpath, inter);
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
{   if (!cp(argc, argv))
        exit(1);
    exit(0);
}
