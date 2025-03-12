/*
 * Listing 2.6, Datei  : grep.c
 * Programm            : GREP - Durchsuchen von Dateien
 *                       nach Textmustern
 * Modifikationsdatum  : 30-Jan-90
 * AbhÑngigkeiten      : stdio.h, string.h, local.h,
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
 * Funktionen   : agrep, grep_flist, grep_dir,
 *                grep_dlist
 *
 * Parameter    : agrep(pattern, count, hide, num,
 *                      invert);
 *                grep_flist(path, flist, num, numall,
 *                          subst);
 *                grep_dir(dir, pattern, count, hide,
 *                         num, invert);
 *                grep_dlist(dlist, pattern, count,
 *                           hide, num, invert);
 *                char           *path,
 *                               *pattern;
 *                FILE_DESC_LIST flist;
 *                BOOLEAN        count,
 *                               hide,
 *                               num,
 *                               invert;
 *                DIR_DESC_ITEM  dir;
 *                DIR_DESC_LIST  dlist;
 *
 * Aufgabe      :
 *
 * Durchlauf der mit den Funktionen <built_dlist> und
 * <expand_dlist> erzeugten Datenstruktur. Die
 * durchlaufenen Dateien werden nach Zeilen mit dem
 * Muster <pattern> untersucht. Werden Zeilen gefunden,
 * auf die das Muster <pattern> zutrifft, dann wird eine
 * entsprechende Ausgabe auf der Standardausgabe
 * erzeugt. Im Normalfall beinhaltet diese Ausgabe den
 * Dateinamen und die Zeile mit der öbereinstimmung.
 * Die Åbrigen Parameter besitzen folgende Bedeutung:
 * 
 * <count>:
 * Ausgabe der Anzahl der öbereinstimmungen anstelle der
 * betroffenen Zeilen.
 *
 * <hide>:
 * Ausgabe ohne Nennung des Dateinamens.
 *
 * <num>:
 * Ausgabe mit Zeilennummer.
 *
 * <revert>:
 * Ausgabe aller Textstellen, auf die das Muster <pattern>
 * nicht zutrifft.
 */

void agrep(filepath, pattern, count, hide,
           num, invert)
char    *filepath,
        *pattern;
BOOLEAN count,
        hide,
        num,
        invert;
{   long    lnum = 1L;
    char    lbuffer[MAXSTRLEN],
            *ptr;
    short   number = 0;
    BOOLEAN matching;

    strcat(lbuffer, "");
    ptr = gets(lbuffer);
    while(!(strcmp(lbuffer, "") == 0 && ptr == NULL)) {
        matching = patmat(pattern, lbuffer);
        if (invert)
            matching = !matching;
        if (matching) {
            if (count)
                number++;
            else {
                if (!hide)
                    printf("%s: ", filepath);
                if (num)
                    printf("%ld ", lnum);
                printf("%s\n", lbuffer);
            }
            
        }
        strcat(lbuffer, "");
        ptr = gets(lbuffer);
        lnum++;
    }
    if (count && number > 0) {
        if (!hide)
            printf("%s: ", filepath);
        printf("%d occurence(s) of %s\n", number, pattern);
    }
}

void grep_flist(path, list, pattern, count, hide, num,
                invert)
char           *path;
FILE_DESC_LIST list;
char           *pattern;
BOOLEAN        count,
               hide,
               num,
               invert;
{   FILE_DESC_LIST work;
    char           filepath[MAXPATHLEN];

    while (list != NULL) {
        if (!(list->fdesc.fattr & 0x10)) {
            sprintf(filepath, "%s\\%s", path,
                    list->fdesc.fname);
            freopen(filepath, "r", stdin);
            agrep(filepath, pattern, count, hide, num,
                  invert);
        }
        list = list->next;
    }
}

void grep_dir(dir, pattern, count, hide, num, invert)
DIR_DESC_ITEM dir;
char          *pattern;
BOOLEAN       count,
              hide,
              num,
              invert;
{   if (strlen(dir.dirpath) == 3 &&
        dir.dirpath[2] == '\\')
        dir.dirpath[2] = 0;
    grep_flist(dir.dirpath, dir.flist, pattern,
               count, hide, num, invert);
}

void grep_dlist(dlist, pattern, count, hide, num,
                invert)
DIR_DESC_LIST dlist;
char          *pattern;
BOOLEAN       count,
              hide,
              num,
              invert;
{   if (dlist != NULL) {
        grep_dir(*dlist, pattern, count, hide, num,
                 invert);
        grep_dlist(dlist->next, pattern, count, hide,
                   num, invert);
    }
}

/*
 * Funktion     : grep
 *
 * Parameter    : grep(argc, argv);
 *                short argc;
 *                char  *argv[];
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gemÑû den Fest-
 * legungen des Kommandos GREP.
 */

BOOLEAN grep(argc, argv)
short argc;
char  *argv[];
{   DIR_DESC_LIST dlist;
    char          path[MAXPATHLEN],
                  pattern[MAXSTRLEN];
    BOOLEAN       option   = TRUE,
                  argument = FALSE,
                  start    = TRUE,
                  count    = FALSE,
                  hide     = FALSE,
                  num      = FALSE,
                  invert   = FALSE;
    short         i;

    i = 1;
    while (i < argc) {
        if (option && argv[i][0] == '-') {
            convupper(argv[i]);
            if (strcmp(argv[i], "-C") == 0)
                count = TRUE;
            else if (strcmp(argv[i], "-H") == 0)
                hide = TRUE;
            else if (strcmp(argv[i], "-N") == 0)
                num = TRUE;
            else if (strcmp(argv[i], "-V") == 0)
                invert = TRUE;
            else
                fprintf(stderr,
                   "Unknown option %s\n", argv[i]);
        }
        else {
            option = FALSE;
            argument = TRUE;
            if (start) {
                strcpy(pattern, argv[i]);
                i++;
                if (i < argc) {
                    dlist = built_dlist(argv[i], FALSE,
                                      TRUE, FALSE, 0);
                    start = dlist->flist == 
                            (FILE_DESC_LIST)ERROR;
                }
                else {
                    fprintf(stderr, "SYNOPSIS:\n%s\n",
                  "GREP [ -CHNV ] pattern filename...");
                    return(FALSE);
                }
            }
            else
                dlist = expand_dlist(dlist, argv[i],
                              FALSE, TRUE, FALSE, 0);
        }
        i++;
    }
    if (!start) {
        grep_dlist(dlist, pattern, count, hide, num,
                   invert);
        drop_dlist(dlist);
        return(TRUE);
    }
    else {
        fprintf(stderr, "SYNOPSIS:\n%s\n",
                "GREP [ -CHNV ] pattern filename...");
        return(FALSE);
    }
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!grep(argc, argv))
        exit(1);
    exit(0);
}
