/*
 * Listing 2.5, Datei  : more.c
 * Programm            : MORE - Anzeigen von
 *                       Textdateien
 * Modifikationsdatum  : 29-Jan-90
 * AbhÑngigkeiten      : stdio.h, string.h, osbind.h,
 *                       local.h, atom.h, atom2.h,
 *                       expand.h
 */

#include <stdio.h>
#include <string.h>
#include <osbind.h>
#include "local.h"
#include "atom.h"
#include "atom2.h"
#include "expand.h"

#define MAXSTRLEN  256
#define MAXPATHLEN 100

/*
 * Funktionen   : amore, more_flist, more_dir, more_dlist
 *
 * Parameter    : amore(filepath, mfiles, fold, subst,
 *                     lines, linenum, pldisc, pattern);
 *                more_flist(path, list, fold, subst,
 *                     lines, linenum, pldisc, pattern);
 *                more_dir(dir, fold, subst,
 *                     lines, linenum, pldisc, pattern);
 *                more_dlist(dlist, fold, subst,
 *                     lines, linenum, pldisc, pattern);
 *                char           *filepath;
 *                BOOLEAN        mfiles,
 *                               fold,
 *                               subst;
 *                short          lines,
 *                               linenum,
 *                               pldisc;
 *                char           *pattern,
 *                               *path;
 *                FILE_DESC_LIST list;
 *                DIR_DESC_ITEM  dir;
 *                DIR_DESC_LIST  dlist;
 *
 * Aufgabe      :
 *
 * Durchlauf der mit den Funktionen <built_dlist> und
 * <expand_dlist> erzeugten Datenstruktur. Die so
 * durchlaufenen Dateien werden gemÑû den drei Optionen
 * <mfiles>, <fold>, <subst> und <lines> durchblÑttert.
 * Der Wahrheitswert <mfiles> gibt dabei an, ob ein 
 * Dateikopf mit dem Dateinamen gedruckt werden soll.
 * <fold> gibt an, daû Åberlange Zeilen getrennt werden.
 * StandardmÑssig werden sie abgeschnitten. <subst> gibt
 * an, ob mehrere aufeinanderfolgende Leerzeilen durch
 * eine einzige Leerzeile ersetzt werden und <lines> ist
 * die jeweilige Grîûe der Ausgabeseite (in Zeilen).
 * <pldisc> ist ein Diskriminator, der darÅber entscheidet,
 * ob der Ausgabebeginn gemÑû dem ersten Vorkommen des
 * Musters <pattern> eingeleitet wird (<pldisc> hat den
 * Wert 1), oder ob ab der <linenum>-ten Zeile mit der
 * Ausgabe begonnen wird (<pldisc> hat den Wert 0.).
 */

void amore(filepath, mfiles, fold, subst,
           lines, linenum, pldisc, pattern)
char           *filepath;
BOOLEAN        mfiles,
               fold,
               subst;
short          lines,
               linenum,
               pldisc;
char           *pattern;
{   long    lnum = 1L;
    short   lcount = 0;
    char    lbuffer[MAXSTRLEN],
            *ptr,
            ch;
    BOOLEAN previous = FALSE,
            output   = FALSE;

    if (mfiles) {
        printf(
   "###############################################\n");
        printf("###   %s\n", filepath);
        printf(
   "###############################################\n");
        lcount = 3;
    }
    strcpy(lbuffer, "");
    ptr = gets(lbuffer);
    while(!(strcmp(lbuffer, "") == 0 && ptr == NULL)) {
        if (!output)
            if (pldisc == 0)
                output = lnum >= linenum;
            else
                output = patmat(pattern, lbuffer);
        if (output && 
            !(subst && previous && onlyws(lbuffer))) {
            outline(lbuffer, fold);
            previous = onlyws(lbuffer);
            lcount++;
            if (isatty(fileno(stdout)) &&
                lcount == lines) {
                do {
                    ch = Cnecin();
                    if (ch == ' ' || ch == 0)
                        lcount = 0;
                    else if (ch == 'q')
                        exit(0);
                    else if (ch == 13)
                        lcount--;
                }
                while (!(ch == ' ' || ch == 0 ||
                         ch == 13));
            }
        }
        strcpy(lbuffer, "");
        ptr = gets(lbuffer);
        lnum++;
    }
}

static BOOLEAN mfiles = FALSE;

void more_flist(path, list, fold, subst,
                lines, linenum, pldisc, pattern)
char           *path;
FILE_DESC_LIST list;
BOOLEAN        fold,
               subst;
short          lines,
               linenum,
               pldisc;
char           *pattern;
{   FILE_DESC_LIST work;
    char           filepath[MAXPATHLEN];

    while (list != NULL) {
        if (!(list->fdesc.fattr & 0x10)) {
            sprintf(filepath, "%s\\%s", path,
                    list->fdesc.fname);
            freopen(filepath, "r", stdin);
            mfiles = mfiles || list->next != NULL;
            amore(filepath, mfiles, fold, subst,
                  lines, linenum, pldisc, pattern);
        }
        list = list->next;
    }
}

void more_dir(dir, fold, subst,
              lines, linenum, pldisc, pattern)
DIR_DESC_ITEM dir;
BOOLEAN       fold,
              subst;
short         lines,
              linenum,
              pldisc;
char          *pattern;
{   if (strlen(dir.dirpath) == 3 &&
        dir.dirpath[2] == '\\')
        dir.dirpath[2] = 0;
    more_flist(dir.dirpath, dir.flist, 
               fold, subst, lines, linenum, pldisc,
               pattern);
}

void more_dlist(dlist, fold, subst,
                lines, linenum, pldisc, pattern)
DIR_DESC_LIST dlist;
BOOLEAN       fold,
              subst;
short         lines,
              linenum,
              pldisc;
char          *pattern;
{   if (dlist != NULL) {
        more_dir(*dlist, fold, subst, lines, linenum,
                 pldisc, pattern);
        more_dlist(dlist->next, fold, subst, lines,
                 linenum, pldisc, pattern);
    }
}

/*
 * Funktion     : more
 *
 * Parameter    : more(argc, argv);
 *                short argc;
 *                char  *argv[];
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gemÑû den Fest-
 * legungen des Kommandos MORE.
 */

void more(argc, argv)
short argc;
char  *argv[];
{   DIR_DESC_LIST dlist;
    char          path[MAXPATHLEN];
    BOOLEAN       option   = TRUE,
                  argument = FALSE,
                  start    = TRUE,
                  fold     = FALSE,
                  subst    = FALSE;
    short         lines    = 23,
                  linenum  = 1,
                  pldisc   = 0;
    char          pattern[MAXSTRLEN];
    short         i;

    strcpy(pattern, "");
    for (i = 1; i < argc; i++) {
        if (option) {
            if (argv[i][0] == '-') {
                if (strcmp(argv[i], "-F") == 0 ||
                    strcmp(argv[i], "-f") == 0)
                    fold = TRUE;
                else if (strcmp(argv[i], "-S") == 0 ||
                         strcmp(argv[i], "-s") == 0)
                    subst = TRUE;
                else {
                    lines = -atoi(argv[i]);
                    if (lines <= 0) {
                        fprintf(stderr,
                           "Unknown option %s\n", argv[i]);
                        lines = 23;
                    }
                }
            }
            else if (argv[i][0] == '+') {
                if (strlen(argv[i]) >= 2 && argv[i][1] == '/') {
                    argv[i] += 2;
                    strcpy(pattern, argv[i]);
                    pldisc = 1;
                }
                else {
                    linenum = atoi(++argv[i]);
                    pldisc = 0;
                    if (linenum <= 0) {
                        fprintf(stderr,
                           "Unknown option %s\n", --argv[i]);
                        linenum = 1;
                    }
                }
            }
            else {
                option = FALSE;
                argument = TRUE;
            }
        }
        if (argument) {
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
        amore("", mfiles, fold, subst,
              lines, linenum, pldisc, pattern);
    else {
        if (!start)
            more_dlist(dlist, fold, subst,
                       lines, linenum, pldisc, pattern);
        drop_dlist(dlist);
    }
}

void main(argc, argv)
short argc;
char  *argv[];
{   more(argc, argv);
    exit(0);
}
