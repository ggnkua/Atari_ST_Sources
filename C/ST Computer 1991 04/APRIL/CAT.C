/*
 * Listing 2.4, Datei  : cat.c
 * Programm            : CAT - Verschmelzen und
 *                       Anzeigen von Dateien
 * Modifikationsdatum  : 25-Jan-90
 * Abh„ngigkeiten      : stdio.h, string.h, local.h,
 *                       atom.h, atom2.h, expand.h
 */

#include <stdio.h>
#include <string.h>
#include "local.h"
#include "atom.h"
#include "atom2.h"
#include "expand.h"

#define MAXSTRLEN  256
#define MAXPATHLEN 100

/*
 * Funktionen   : acat, cat_flist, cat_dir, cat_dlist
 *
 * Parameter    : acat(num, numall, subst);
 *                cat_flist(path, flist, num, numall,
 *                          subst);
 *                cat_dir(dir, num, numall, subst);
 *                cat_dlist(dlist, num, numall, subst);
 *                char           *path;
 *                FILE_DESC_LIST flist;
 *                BOOLEAN        num,
 *                               numall,
 *                               subst;
 *                DIR_DESC_ITEM  dir;
 *                DIR_DESC_LIST  dlist;
 *
 * Aufgabe      :
 *
 * Durchlauf der mit den Funktionen <built_dlist> und
 * <expand_dlist> erzeugten Datenstruktur. Die so
 * durchlaufenen Dateien werden gem„ž den drei Optionen
 * <num>, <numall> und <subst> auf die Standardausgabe
 * geschrieben. Dabei wird die Funktion <acat> benutzt,
 * um die Ausgabe vorzunehmen.
 */

void acat(num, numall, subst)
BOOLEAN num,
        numall,
        subst;
{   long    lnum = 1L;
    char    lbuffer[MAXSTRLEN],
            *ptr;
    BOOLEAN previous = FALSE;

    strcpy(lbuffer, "");
    ptr = gets(lbuffer);
    while(!(strcmp(lbuffer, "") == 0 && ptr == NULL)) {
        if (!(subst && previous && onlyws(lbuffer))) {
            if (num) {
                if (onlyws(lbuffer)) {
                    printf("      %s\n", lbuffer);
                    previous = TRUE;
                }
                else {
                    printf("%4ld  %s\n", lnum,
                           lbuffer);
                    previous = FALSE;
                    lnum++;
                }
            }
            else if (numall) {
                printf("%4ld  %s\n", lnum, lbuffer);
                lnum++;
                previous = subst && onlyws(lbuffer);
            }
            else {
                printf("%s\n", lbuffer);
                previous = subst && onlyws(lbuffer);
            }
        }
        strcpy(lbuffer, "");
        ptr = gets(lbuffer);
    }
}

void cat_flist(path, list, num, numall, subst)
char           *path;
FILE_DESC_LIST list;
BOOLEAN        num,
               numall,
               subst;
{   FILE_DESC_LIST work;
    char           filepath[MAXPATHLEN];

    while (list != NULL) {
        if (!(list->fdesc.fattr & 0x10)) {
            sprintf(filepath, "%s\\%s", path,
                    list->fdesc.fname);
            freopen(filepath, "r", stdin);
            acat(num, numall, subst);
        }
        list = list->next;
    }
}

void cat_dir(dir, num, numall, subst)
DIR_DESC_ITEM dir;
BOOLEAN       num,
              numall,
              subst;
{   if (strlen(dir.dirpath) == 3 &&
        dir.dirpath[2] == '\\')
        dir.dirpath[2] = 0;
    cat_flist(dir.dirpath, dir.flist, num, numall,
              subst);
}

void cat_dlist(dlist, num, numall, subst)
DIR_DESC_LIST dlist;
BOOLEAN       num,
              numall,
              subst;
{   if (dlist != NULL) {
        cat_dir(*dlist, num, numall, subst);
        cat_dlist(dlist->next, num, numall, subst);
    }
}

/*
 * Funktion     : cat
 *
 * Parameter    : cat(argc, argv);
 *                short argc;
 *                char  *argv[];
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos CAT.
 */

void cat(argc, argv)
short argc;
char  *argv[];
{   DIR_DESC_LIST dlist;
    char          path[MAXPATHLEN];
    BOOLEAN       option   = TRUE,
                  argument = FALSE,
                  start    = TRUE,
                  num      = FALSE,
                  numall   = FALSE,
                  subst    = FALSE;
    short         i;

    for (i = 1; i < argc; i++) {
        convupper(argv[i]);
        if (option && argv[i][0] == '-') {
            if (strcmp(argv[i], "-B") == 0) {
                num = TRUE;
                numall = FALSE;
            }
            else if (strcmp(argv[i], "-N") == 0) {
                numall = TRUE;
                num = FALSE;
            }
            else if (strcmp(argv[i], "-S") == 0)
                subst = TRUE;
            else
                fprintf(stderr,
                   "Unknown option %s\n", argv[i]);
        }
        else {
            option = FALSE;
            argument = TRUE;
            if (start) {
                dlist = built_dlist(argv[i], FALSE,
                                  TRUE, FALSE, 0);
                start = dlist->flist == 
                        (FILE_DESC_LIST)ERROR;
            }
            else
                dlist = expand_dlist(dlist, argv[i],
                              FALSE, TRUE, FALSE, 0);
        }
    }
    if (!argument)
        acat(num, numall, subst);
    else {
        if (!start)
            cat_dlist(dlist, num, numall, subst);
        drop_dlist(dlist);
    }
}

void main(argc, argv)
short argc;
char  *argv[];
{   cat(argc, argv);
    exit(0);
}
