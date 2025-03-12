/*
 * Listing 1.12, Datei : ls.c
 * Programm            : LS - Anzeigen von Datei-
 *                       informationen
 * Modifikationsdatum  : 15-Nov-89
 * Abh„ngigkeiten      : stdio.h, ctype.h, string.h,
 *                       osbind.h, local.h, atom.h,
 *                       expand.h
 */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <osbind.h>
#include "local.h"
#include "atom.h"
#include "expand.h"

/*
 * Funktionen   : list_flist, list_dir, list_dlist
 *
 * Parameter    : list_flist(path, flist, lversion);
 *                list_dir(dir, lversion);
 *                list_dlist(dlist, lversion);
 *                char           *path;
 *                FILE_DESC_LIST flist;
 *                BOOLEAN        lversion;
 *                DIR_DESC_ITEM  dir;
 *                DIR_DESC_LIST  dlist;
 *
 * Aufgabe      :
 *
 * Ausgabe der mit den Funktionen <built_flist>,
 * <concat_flist>, <built_dir>, <built_dlist> und
 * <expand_dlist> erzeugten Datenstruktur. Je nach
 * Verwendung des Parameters <lversion> wird dabei
 * der gesamte Informationsgehalt ausgegeben
 * (<lversion> ist TRUE) oder nur der Name der
 * Datei. <path> gibt dabei den jeweiligen Pfad-
 * prefix an und wird beim rekursiven Abstieg in
 * die Datenstruktur <DIR_DESC_LIST> expandiert.
 */

static void list_date(date, time)
unsigned date,
         time;
{   unsigned year  = ((date & 0xfe00) >> 9) + 80,
             month = (date & 0x01e0) >> 5,
             day   = (date & 0x001f),
             hour  = (time & 0xf800) >> 11,
             minute = (time & 0x07e0) >> 5,
             second = (time & 0x001f) * 2;
          
    printf("%02d-%02d-%02d  ", day, month, year);
    printf("%02d:%02d:%02d  ", hour, minute, second);
}

static void outname(list)
FILE_DESC_LIST *list;
{   if (*list != NULL) {
        printf("%-14.14s", (*list)->fdesc.fname);
        *list = (*list)->next;
    }
}

void list_flist(path, list, lversion, rec)
char           *path;
FILE_DESC_LIST list;
BOOLEAN        lversion,
               rec;
{   FILE_DESC_LIST work;
    char           *newpath[100];
    short          count,
                   length,
                   lnum,
                   i,
                   j;
    FILE_DESC_LIST plist[5];

    printf("\n%s\n", path);
    if (list == NULL) {
        printf(" {empty}\n");
        return;
    }
    if (lversion) {
        work = list;
        while(work != NULL) {
            if (work->fdesc.fattr & 0x10)
                printf(" d");
            else
                printf(" -");
            if (work->fdesc.fattr & 0x01)
                printf("r-  ");
            else
                printf("rw  ");
            printf("%-14.14s   ", work->fdesc.fname);
            list_date(work->fdesc.fdate,
                      work->fdesc.ftime);
            printf("%8ld\n", work->fdesc.fsize);
            work = work->next;
        }
    }
    else {
        count = 0;
        work = list;
        while (work != NULL) {
            count++;
            work = work->next;
        }
        length = (count - 1) / 5 + 1;
        work = list;
        lnum = 0;
        count = length - 1;
        for (i = 0; i <= 4; i++)
            plist[i] = NULL;
        while (work != NULL) {
            count++;
            if (count == length) {
                plist[lnum] = work;
                lnum++;
                count = 0;
            }
            work = work->next;
        }
        for (j = 1; j <= length; j++) {
            printf(" ");
            for (i = 0; i <= 4; i++)
                outname(&plist[i]);
            printf("\n");
        }
    }
    work = list;
    while(rec && work != NULL) {
        if (work->fdesc.fattr & 0x10) {
            strcpy(newpath, path);
            strcat(newpath, "\\");
            strcat(newpath, work->fdesc.fname);
            list_flist(newpath, work->down,
                       lversion, rec);
        }
        work = work->next;
    }
}

void list_dir(dir, lversion, rec)
DIR_DESC_ITEM dir;
BOOLEAN  lversion,
         rec;
{   if (strlen(dir.dirpath) == 3 &&
        dir.dirpath[2] == '\\')
        dir.dirpath[2] = 0;
    list_flist(dir.dirpath, dir.flist, lversion, rec);
}

void list_dlist(dlist, lversion, rec)
DIR_DESC_LIST dlist;
BOOLEAN       lversion,
              rec;
{   if (dlist != NULL) {
        list_dir(*dlist, lversion, rec);
        list_dlist(dlist->next, lversion, rec);
    }
}

/*
 * Funktion     : ls
 *
 * Parameter    : ls(argc, argv);
 *                short argc;
 *                char  *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos ls.
 */

void ls(argc, argv)
short argc;
char  *argv[];
{   DIR_DESC_LIST dlist;
    char          path[100];
    BOOLEAN       option   = TRUE,
                  argument = FALSE,
                  start    = TRUE,
                  all      = FALSE,
                  dir      = FALSE,
                  rec      = FALSE,
                  lver     = FALSE;
    short         stype    = 1,
                  i;

    for (i = 1; i < argc; i++) {
        convupper(argv[i]);
        if (option && argv[i][0] == '-') {
            if (strcmp(argv[i], "-A") == 0)
                all = TRUE;
            else if (strcmp(argv[i], "-D") == 0) {
                dir = TRUE;
                rec = FALSE;
            }
            else if (strcmp(argv[i], "-L") == 0)
                lver = TRUE;
            else if (strcmp(argv[i], "-R") == 0) {
                rec = TRUE;
                dir = FALSE;
            }
            else if (strcmp(argv[i], "-T") == 0)
                stype = 2;
            else
                fprintf(stderr,
                   "Unknown option %s\n", argv[i]);
        }
        else {
            option = FALSE;
            argument = TRUE;
            if (start) {
                dlist = built_dlist(argv[i], all,
                                  dir, rec, stype);
                start = dlist->flist == 
                        (FILE_DESC_LIST)ERROR;
            }
            else
                dlist = expand_dlist(dlist, argv[i],
                              all, dir, rec, stype);
        }
    }
    if (!argument) {
        dlist = built_dlist(".", all, dir, rec,
                            stype);
        start = dlist->flist == 
                (FILE_DESC_LIST)ERROR;
    }
    if (!start)
        list_dlist(dlist, lver, rec);
    drop_dlist(dlist);
}

void main(argc, argv)
short argc;
char  *argv[];
{   ls(argc, argv);
    exit(0);
}
