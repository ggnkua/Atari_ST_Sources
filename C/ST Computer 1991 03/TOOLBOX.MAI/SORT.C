/*
 * Listing 2.7, Datei  : sort.c
 * Programm            : SORT - Die Sortierung von
 *                       Textdateien
 * Modifikationsdatum  : 04-MÑr-90
 * AbhÑngigkeiten      : stdio.h, string.h, ctype.h,
 *                       math.h, local.h, atom.h,
 *                       atom2.h, expand.h
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include "local.h"
#include "atom.h"
#include "atom2.h"
#include "expand.h"

/*
 * Konstanten   : MAXSTRLEN, STDTABSIZ, STACKSIZE
 *                MAXPATHLEN
 *
 * Aufgabe      :
 *
 * Festlegung interner Voreinstellung/Begrenzungen.
 * Im einzelnen:
 *
 * STDTABSIZ   Voreinstellung fÅr die Feldgrîûe.
 * STACKSIZE   Vorgabe fÅr den Programmstack von SORT.
 * MAXSTRLEN   Die maximale ZeilenlÑnge.
 * MAXPATHLEN  Die maximale LÑnge von Dateinamen.
 */

#define STDTABSIZ  100
#define STACKSIZE  65536L
#define MAXSTRLEN  256
#define MAXPATHLEN 100

/*
 * Datentypen   : ORDER, SORTREL, SORTLIST_ITEM,
 *                SORTLIST, SORTRELATION
 *
 * Aufgabe      :
 *
 * Aufnahme der Sortieroptionen bei der Interpretation
 * der Kommandozeile.
 */

typedef enum {
    SIMPLE,
    DICTIONARY,
    KALENDARY,
    NUMERIC
} ORDER;

typedef struct {
    short   sword;
    BOOLEAN blank,
            fold,
            revert;
    ORDER   order;
} SORTREL;

typedef struct sortlist_item {
    SORTREL              sortrel;
    struct sortlist_item *next;
} SORTLIST_ITEM, *SORTLIST;

typedef struct {
    short    command;           /* 0 Order ununique,
                                   1 Order unique,
                                   2 Check */
    short    line_or_word_rel;  /* 0 line-Relation,
                                   1 word-Relation */
    SORTREL  line_relation;
    char     word_separator;
    SORTLIST word_relation;
    short    tablesize;
} SORTRELATION;

/*
 * Funktionen   : output_sortrel, output_sortlist
 *                output_rel
 *
 * Parameter    : output_sortrel(rel, wordnumber);
 *                output_sortlist(list, wordnumber)
 *                output_rel(&rel)
 *                SORTREL rel;
 *                short   wordnumber;
 *                SORTLIST list;
 *                SORTRELATION rel;
 *
 * Aufgabe      :
 *
 * Ausgabe einer Relationsbeschreibung innerhalb des
 * verbose-Modus ("-V" Option ist gesetzt. Die Ausgabe
 * erfolgt in die Datei "SORT.TXT".
 */

FILE *voutput;

void output_sortrel(rel, wordnumber)
SORTREL rel;
short   wordnumber;
{   if (wordnumber > 0)
        fprintf(voutput, "%d. sort field:  ",
                wordnumber);
    if (rel.sword != -1)
        fprintf(voutput, "Startpos=%d  ", rel.sword);
    switch(rel.order) {
        case 0:
            fprintf(voutput, "Order=SIMPLE  ");
            break;
        case 1:
            fprintf(voutput, "Order=DICTIONARY  ");
            break;
        case 2:
            fprintf(voutput, "Order=KALENDARY  ");
            break;
        case 3:
            fprintf(voutput, "Order=NUMERIC  ");
            break;
    }
    if (rel.blank)
        fprintf(voutput, "IGNORE WS  ");
    if (rel.fold)
        fprintf(voutput, "FOLD IN UPPER CASE  ");
    if (rel.revert)
        fprintf(voutput, "REVERT");
    fprintf(voutput, "\n");
}

void output_sortlist(list, wordnumber)
SORTLIST list;
short    wordnumber;
{   if (list != NULL) {
        output_sortrel(list->sortrel, wordnumber);
        output_sortlist(list->next, wordnumber + 1);
    }
}

void output_rel(rel)
SORTRELATION *rel;
{   voutput = fopen("sort.txt", "w");
    switch(rel->command) {
        case 0:
            fprintf(voutput,
                    "Command  : Order ununique\n");
            break;
        case 1:
            fprintf(voutput,
                    "Command  : Order unique\n");
            break;
        case 2:
            fprintf(voutput,
                    "Command  : Check\n");
            break;
    }
    switch (rel->line_or_word_rel) {
        case 0:
            fprintf(voutput, "Relation : line\n");
            fprintf(voutput, "Options  :\n");
            output_sortrel(rel->line_relation, 0);
            break;
        case 1:
            fprintf(voutput, "Relation : word\n");
            if (rel->word_separator == 0)
                fprintf(voutput,
                        "Separator: WHITE SPACE\n");
            else
                fprintf(voutput, "Separator: %c\n",
                        rel->word_separator);
            fprintf(voutput, "Options  :\n");
            output_sortlist(rel->word_relation, 1);
            break;
    }
    fprintf(voutput, "Tablesize: %d\n",
            rel->tablesize);
    fclose(voutput);
}

/*
 * Funktionen   : curcopy, month_order,
 *                simplerel, separate, sortrel
 *
 * Parameter    : curcopy(srcword, destword, blank,
 *                        fold);
 *                ordernum = month_order(string);
 *                relerg = simplerel(word1, word2,
 *                                   rel);
 *                separate(line, word, separator,
 *                         rel);
 *                relerg = sortrel(line1, line2, srel);
 *                char         *srcword,
 *                             *destword;
 *                BOOLEAN      blank,
 *                             fold;
 *                short        ordernum;
 *                char         *string;
 *                short        relerg;
 *                char         *word1,
 *                             *word2;
 *                SORTREL      rel;
 *                char         *line,
 *                             *word,
 *                             separator,
 *                             *line1,
 *                             *line2;
 *                SORTRELATION srel;
 *
 * Aufgabe      :
 *
 * Obwohl die Bezeichnungen und Parameter der fÅnf
 * nachfolgenden Funktionen vielfÑltig sind, dienen
 * sie alle einer einzigen Aufgabe: Auf Basis einer
 * innerhalb der <SORTRELATION> <rel> abgelegten
 * Zeilenrelation soll der Wert dieser Relation fÅr
 * zwei Zeilen bestimmt werden. Die Funktionen
 * Åbernehmen folgende Teilaufgaben bei der Relations-
 * auswertung:
 *
 * curcopy:
 * Kopieren eines Strings von <srcword> nach <destword>
 * unter BerÅcksichtigung der Optionen <blank> und
 * <fold>.
 *
 * month_order:
 * Zuordnung einer ganzen Zahl zu einem String, gemÑû
 * der auf Kalendermonaten festgelegten Ordnung.
 *
 * simplerel:
 * Auswertung der Relation fÅr zwei Worte.
 *
 * separate:
 * Separierung von Worten aus Zeilen.
 *
 * sortrel:
 * Auswertung der Relation fÅr zwei Zeilen.
 */

void curcopy(srcword, destword, blank, fold)
char    *srcword,
        *destword;
BOOLEAN blank,
        fold;
{   char *work;

    work = srcword;
    if (blank) {
        while (work[0] != 0 &&
               (work[0] == ' ' ||
                work[0] == '\t'))
            work++;
    }
    strcpy(destword, work);
    if (fold)
        convupper(destword);
}

short month_order(string)
char *string;
{   if (strcmp(string, "JAN") == 0)
        return(1);
    if (strcmp(string, "FEB") == 0)
        return(2);
    if (strcmp(string, "MAR") == 0)
        return(3);
    if (strcmp(string, "APR") == 0)
        return(4);
    if (strcmp(string, "MAY") == 0)
        return(5);
    if (strcmp(string, "JUN") == 0)
        return(6);
    if (strcmp(string, "JUL") == 0)
        return(7);
    if (strcmp(string, "AUG") == 0)
        return(8);
    if (strcmp(string, "SEP") == 0)
        return(9);
    if (strcmp(string, "OCT") == 0)
        return(10);
    if (strcmp(string, "NOV") == 0)
        return(11);
    if (strcmp(string, "DEC") == 0)
        return(12);
    return(0);
}

short simplerel(word1, word2, rel)
char    *word1,
        *word2;
SORTREL rel;
{   char   cword1[MAXSTRLEN],
           cword2[MAXSTRLEN];
    short  erg,
           mord1,
           mord2;
    double real1,
           real2;
         
    curcopy(word1, cword1, rel.blank, rel.fold);
    curcopy(word2, cword2, rel.blank, rel.fold);
    switch (rel.order) {
        case DICTIONARY:
            filter_dict(cword1);
            filter_dict(cword2);
        case SIMPLE:
            if (strcmp(cword1, cword2) < 0)
                erg = -1;
            else if (strcmp(cword1, cword2) == 0)
                erg = 0;
            else
                erg = 1;
            break;
        case KALENDARY:
            if (strlen(cword1) >= 3)
                cword1[3] = 0;
            mord1 = month_order(cword1);
            if (strlen(cword2) >= 3)
                cword2[3] = 0;
            mord2 = month_order(cword2);
            if (mord1 < mord2)
                erg = -1;
            else if (mord1 == mord2)
                erg = 0;
            else
                erg = 1;
            break;
        case NUMERIC:
            real1 = atof(cword1);
            real2 = atof(cword2);
            if (real1 < real2)
                erg = -1;
            else if (real1 == real2)
                erg = 0;
            else
                erg = 1;
            break;
    }
    if (rel.revert)
        if (erg == 1)
            erg = -1;
        else if (erg == -1)
            erg = 1;
    return(erg);
}

void separate(line, word, separator, rel)
char    *line,
        *word;
char    separator;
SORTREL rel;
{   short cword = 0,
          iword = 0;

    if (separator == 0)
        while (line[0] != 0 &&
               (line[0] == ' ' || line[0] == '\t'))
            line++;
    while (line[0] != 0) {
        if ((separator == 0 &&
            (line[0] == ' ' || line[0] == '\t')) ||
            (separator != 0 && line[0] == separator)) {
            line++;
            if (separator == 0)
                while (line[0] != 0 &&
                       (line[0] == ' ' ||
                        line[0] == '\t'))
                    line++;
            cword++;
        }
        else {
            if (rel.sword == cword)
                word[iword++] = line[0];
            line++;
        }
    }
    word[iword] = 0;
}

short sortrel(line1, line2, srel)
char         *line1,
             *line2;
SORTRELATION srel;
{   char     word1[MAXSTRLEN],
             word2[MAXSTRLEN];
    SORTLIST rlist;
    short    wordrel;

    if (srel.line_or_word_rel == 0)
        return(simplerel(line1, line2,
               srel.line_relation));
    else {
        rlist = srel.word_relation;
        while (rlist != NULL) {
            separate(line1, word1, srel.word_separator,
                     rlist->sortrel);
            separate(line2, word2, srel.word_separator,
                     rlist->sortrel);
            wordrel = simplerel(word1, word2,
                                rlist->sortrel);
            if (wordrel != 0)
                rlist = NULL;
            else
                rlist = rlist->next;
        }
        return(wordrel);
    }
}

/*
 * Variablen/
 * Datentypen   : field, filename, infile, outfile,
 *                noutput, MERGE_ITEM, MERGE_LIST
 *
 * Aufgabe      :
 *
 * Einige globale Vereinbarungen, die bei der
 * Sortierung funktionsÅbergreifend benîtigt werden.
 */

char **field,
     filename[MAXPATHLEN];
FILE *infile,
     *outfile,
     *noutput;

typedef struct merge_list {
    long              start,
                      stop;
    char              string[MAXSTRLEN];
    struct merge_list *next;
} MERGE_ITEM, *MERGE_LIST;

/*
 * Funktionen   : read_line, read_field, quicksort,
 *                insert, order, check
 *                
 *
 * Parameter    : line = read_line(string);
 *                rcnt = read_field(cnt)
 *                quicksort(left, right, rel);
 *                insert(newnode, &list, rel);
 *                order(rel);
 *                checkerg = check(rel);
 *                char         *line,
 *                             *string;
 *                short        rcnt,
 *                             cnt,
 *                             left,
 *                             right;
 *                SORTRELATION rel;
 *                MERGE_LIST   newnode,
 *                             list;
 *                BOOLEAN      checkerg;
 *
 * Aufgabe      :
 *
 * DurchfÅhrung der Sortierung, bzw. Check der
 * Ordnung. Die Funktionen besitzen folgende Einzel-
 * aufgaben:
 *
 * read_line:
 * Lesen der nÑchsten Zeile aus der Dateisequenz.
 *
 * read_field:
 * Einlesen eines ganzen Zeilenfeldes in die globale
 * Variable <field>.
 *
 * quicksort:
 * Internes Sortierverfahren auf <field>.
 *
 * insert:
 * Hilfsfunktion. EinfÅgen eines Eintrags in die beim
 * Sortieren benutzte, sortierte Listenstruktur.
 *
 * order:
 * DurchfÅhrung der Sortierung mit interner Vor-
 * sortierung durch <quicksort> und einer integrierten
 * Variante eines Mischsortierverfahrens.
 *
 * check:
 * öberprÅfen der Ordnung.
 */

char *read_line(string)
char *string;
{   char lbuffer[MAXSTRLEN],
         *ptr;

    strcpy(lbuffer, "");
    ptr = fgets(lbuffer, MAXSTRLEN, infile);
    while (strcmp(lbuffer, "") == 0 && ptr == NULL) {
        fclose(infile);
        if (fscanf(noutput, "%s", filename) == EOF)
            return(NULL);
        infile = fopen(filename, "r");
        strcpy(lbuffer, "");
        ptr = fgets(lbuffer, MAXSTRLEN, infile);
    }
    strcpy(string, lbuffer);
    return(string);
}

short read_field(cnt)
short cnt;
{   short i;
    char  *help;

    for (i = 0; i < cnt; i++) {
        help = read_line(field[i]);
        if (help == NULL)
            return(i);
    }
}

void quicksort(left, right, rel)
short        left,
             right;
SORTRELATION rel;
{   short i     = left,
          j     = right;
    char  *pivot = field[(left + right) / 2],
          *help;

    do {
        while (sortrel(field[i], pivot, rel) < 0)
            i++;
        while (sortrel(pivot, field[j], rel) < 0)
            j--;
        if (i <= j) {
            help = field[i];
            field[i] = field[j];
            field[j] = help;
            i++;
            j--;
        }
    } while (i <= j);
    if (left < j)
        quicksort(left, j, rel);
    if (i < right)
        quicksort(i, right, rel);
}

void insert(newnode, list, rel)
MERGE_LIST   newnode,
             *list;
SORTRELATION rel;
{    if (*list == NULL)
         *list = newnode;
     else if (sortrel((*list)->string,
              newnode->string, rel) < 0)
         insert(newnode, &(*list)->next, rel);
     else {
         newnode->next = *list;
         *list = newnode;
     }
}

void order(rel)
SORTRELATION rel;
{   short      cnt,
               i;
    MERGE_LIST mlist = NULL,
               nlist;
    char       lbuffer[MAXSTRLEN],
               *ptr,
               dummy;
    BOOLEAN    start_unique = TRUE;
    char       pre_unique[MAXSTRLEN];
    
    field = (char **)malloc(rel.tablesize *
                            sizeof(field[0]));
    for (i = 0; i < rel.tablesize; i++)
        field[i] = malloc(MAXSTRLEN);
    noutput = fopen("SORT.NAM", "r");
    if (fscanf(noutput, "%s", filename) == EOF)
        return ;
    infile = fopen(filename, "r");
    outfile = fopen("SORT.TMP", "bw");
    do {
        cnt = read_field(rel.tablesize);
        if (cnt > 0) {
            quicksort(0, cnt - 1, rel);
            nlist = (MERGE_LIST)malloc(
                    sizeof(MERGE_ITEM));
            strcpy(nlist->string, field[0]);
            nlist->next = NULL;
            for (i = 0; i < cnt; i++) {
                fprintf(outfile, "%s", field[i]);
                if (i == 0)
                    nlist->start = ftell(outfile);
            }
            nlist->stop = ftell(outfile);
            insert(nlist, &mlist, rel);
        }
    } while (cnt > 0);
    fclose(outfile);
    fclose(infile);
    fclose(noutput);
    for (i = 0; i < rel.tablesize; i++)
        free(field[i]);
    free((char *)field);
    outfile = fopen("SORT.TMP", "br");
    while (mlist != NULL) {
        if (rel.command == 0)
            printf("%s", mlist->string);
        else if (start_unique) {
            start_unique = FALSE;
            strcpy(pre_unique, mlist->string);
            printf("%s", mlist->string);
        }
        else if (sortrel(pre_unique, mlist->string,
                         rel) != 0) {
            printf("%s", mlist->string);
            strcpy(pre_unique, mlist->string);
        }
        if (mlist->start == mlist->stop) {
            nlist = mlist;
            mlist = mlist->next;
            free((MERGE_LIST)nlist);
        }
        else {
            fseek(outfile, mlist->start, 0);
            strcpy(lbuffer, "");
            ptr = fgets(lbuffer, MAXSTRLEN, outfile);
            nlist = mlist;
            mlist = mlist->next;
            strcpy(nlist->string, lbuffer);
            nlist->start = ftell(outfile);
            nlist->next = NULL;
            insert(nlist, &mlist, rel);
        }
    }
}

BOOLEAN check(rel)
SORTRELATION rel;
{   short   cnt,
            i;
    char    lbuffer[MAXSTRLEN],
            previous[MAXSTRLEN];
    BOOLEAN start = TRUE;
    
    field = (char **)malloc(rel.tablesize *
                            sizeof(field[0]));
    for (i = 0; i < rel.tablesize; i++)
        field[i] = malloc(MAXSTRLEN);
    noutput = fopen("SORT.NAM", "r");
    if (fscanf(noutput, "%s", filename) == EOF)
        return(TRUE);
    infile = fopen(filename, "r");
    do {
        cnt = read_field(rel.tablesize);
        if (cnt > 0) {
            for (i = 0; i < cnt; i++)
                if (start) {
                    start = FALSE;
                    strcpy(previous, field[0]);
                }
                else if (strcmp(previous,
                                field[i]) > 0) {
                    fprintf(stderr,
                           "SORT: order violated\n");
                    return(FALSE);
                }
                else
                    strcpy(previous, field[i]);
        }
    } while (cnt > 0);
    fclose(infile);
    fclose(noutput);
    fprintf(stderr, "SORT: files are in order\n");
    return(TRUE);
}

/*
 * Funktionen   : make_flist, make_dir,
 *                make_dlist
 *
 * Parameter    : make_flist(path, flist);
 *                make_dir(dir);
 *                make_dlist(dlist);
 *                char           *path;
 *                FILE_DESC_LIST flist;
 *                DIR_DESC_ITEM  dir;
 *                DIR_DESC_LIST  dlist;
 *
 * Aufgabe      :
 *
 * In der Datei "SORT.NAM" wird eine Liste aller
 * zu sortierenden Dateien aufgebaut. Diese Liste
 * dient dazu, die Dateien zu einem spÑteren
 * Zeitpunkt sequentiell bearbeiten zu kînnen.
 */

void make_flist(path, list)
char           *path;
FILE_DESC_LIST list;
{   FILE_DESC_LIST work;
    char           filepath[MAXPATHLEN];

    while (list != NULL) {
        if (!(list->fdesc.fattr & 0x10))
            fprintf(noutput, "%s\\%s\n", path,
                    list->fdesc.fname);
        list = list->next;
    }
}

void make_dir(dir)
DIR_DESC_ITEM dir;
{   if (strlen(dir.dirpath) == 3 &&
        dir.dirpath[2] == '\\')
        dir.dirpath[2] = 0;
    make_flist(dir.dirpath, dir.flist);
}

void make_dlist(dlist)
DIR_DESC_LIST dlist;
{   if (dlist != NULL) {
        make_dir(*dlist);
        make_dlist(dlist->next);
    }
}

/*
 * Funktion     : eval_sfalgs, eval_tflag, eval_sfield,
 *                eval_cmd, eval_sfsize, sort
 *
 * Parameter    : new_pos = eval_sflags(pos, argc,
 *                                    argv, &sortrel);
 *                new_pos = eval_tflag(pos, argc,
 *                                    argv, &chr)
 *                new_pos = eval_sfield(pos, argc,
 *                                    argv, &sortrel);
 *                new_pos = eval_cmd(pos, argc, argv,
 *                                &command, &verbose);
 *                new_pos = eval_sfsize(pos, argc,
 *                                      argv, &rel);
 *                sort(argc, argv);
 *                short        new_pos,
 *                             pos,
 *                             argc;
 *                char         *argv[];
 *                SORTREL      sortrel;
 *                char         chr;
 *                short        command;
 *                BOOLEAN      verbose;
 *                SORTRELATION rel;
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gemÑû den Fest-
 * legungen des Kommandos SORT. Da SORT gegenÅber den
 * bisherigen Kommandos eine reichhaltige Kommando-
 * Syntax besitzt, erfolgt die Interpretierung in
 * mehreren Schritten, die in den Funktionen mit dem
 * Prefix <eval_> untergebracht sind. Im einzelnen:
 *
 * <eval_sflags> lieût die Sortieroptionen.
 * <eval_tflag>  lieût das Worttrennsymbol.
 * <eval_sfield> lieût einzelne Sortierfelder.
 * <eval_cmd>    lieût die Sortieranweisung.
 * <eval_sfsize> lieût die Grîûe des internen
 *               Sortierfeldes.
 * <sort>        koordiniert die Optionsinterpretation
 *               und leitet die Sortieroperation ein.
 */

short eval_sflags(pos, argc, argv, sortrel)
short   pos,
        argc;
char    **argv;
SORTREL *sortrel;
{   while (pos < argc) {
        if (strcmp(argv[pos], "-b") == 0 ||
            strcmp(argv[pos], "-B") == 0)
            sortrel->blank = TRUE;
        else if (strcmp(argv[pos], "-d") == 0 ||
            strcmp(argv[pos], "-D") == 0) {
            sortrel->fold = FALSE;
            sortrel->order = DICTIONARY;
        }
        else if (strcmp(argv[pos], "-f") == 0 ||
            strcmp(argv[pos], "-F") == 0) {
            sortrel->fold = TRUE;
            sortrel->order = DICTIONARY;
        }
        else if (strcmp(argv[pos], "-m") == 0 ||
            strcmp(argv[pos], "-M") == 0) {
            sortrel->fold = TRUE;
            sortrel->blank = TRUE;
            sortrel->order = KALENDARY;
        }
        else if (strcmp(argv[pos], "-n") == 0 ||
            strcmp(argv[pos], "-N") == 0) {
            sortrel->fold = FALSE;
            sortrel->blank = TRUE;
            sortrel->order = NUMERIC;
        }
        else if (strcmp(argv[pos], "-r") == 0 ||
            strcmp(argv[pos], "-R") == 0)
            sortrel->revert = TRUE;
        else
            return(pos);
        pos++;
    }
    return(pos);
}

short eval_tflag(pos, argc, argv, chr)
short   pos,
        argc;
char    **argv,
        *chr;
{   if (pos < argc) {
        if (strlen(argv[pos]) == 3 &&
            argv[pos][0] == '-' &&
            (argv[pos][1] == 't' ||
             argv[pos][1] == 'T')) {
            *chr = argv[pos][2];
            pos++;
        }
    }
    return(pos);
}

short eval_sfield(pos, argc, argv, sortrel)
short   pos,
        argc;
char    **argv;
SORTREL *sortrel;
{   if (pos < argc)
        if (argv[pos][0] == '+') {
            argv[pos]++;
            sortrel->sword = atoi(argv[pos]);
            if (++pos == argc)
                return(pos);
            pos = eval_sflags(pos, argc, argv,
                              sortrel);
        }
    return(pos);
}

short eval_cmd(pos, argc, argv, command, verbose)
short   pos,
        argc;
char    **argv;
short   *command;
BOOLEAN *verbose;
{   while (pos < argc) {
        if (strcmp(argv[pos], "-u") == 0 ||
            strcmp(argv[pos], "-U") == 0)
            *command = 1;
        else if (strcmp(argv[pos], "-c") == 0 ||
            strcmp(argv[pos], "-C") == 0)
            *command = 2;
        else if (strcmp(argv[pos], "-v") == 0 ||
            strcmp(argv[pos], "-V") == 0)
            *verbose = TRUE;
        else
            return(pos);
        pos++;
    }
}

short eval_sfsize(pos, argc, argv, rel)
short        pos,
             argc;
char         **argv;
SORTRELATION *rel;
{   if (pos < argc) {
        if (strlen(argv[pos]) > 2 &&
            argv[pos][0] == '-' &&
            (argv[pos][1] == 's' ||
             argv[pos][1] == 'S')) {
            argv[pos] += 2;
            rel->tablesize = atoi(argv[pos]);
            argv[pos] -= 2;
            if (rel->tablesize < 10)
                rel->tablesize = STDTABSIZ;
            pos++;
        }
    }
    return(pos);
}

BOOLEAN sort(argc, argv)
short argc;
char  *argv[];
{   DIR_DESC_LIST dlist;
    SORTRELATION  rel;
    SORTREL       sortfield;
    SORTLIST      new,
                  ptr = NULL;
    BOOLEAN       verbose = FALSE,
                  start   = TRUE,
                  breturn;
    short         pos = 1,
                  newpos,
                  cmd;
    
    rel.command              = 0;
    rel.line_or_word_rel     = 0;
    rel.line_relation.sword  = -1;
    rel.line_relation.blank  = FALSE;
    rel.line_relation.fold   = FALSE;
    rel.line_relation.revert = FALSE;
    rel.line_relation.order  = SIMPLE;
    rel.word_separator       = 0;
    rel.word_relation        = NULL;
    rel.tablesize            = STDTABSIZ;
    pos = eval_sflags(pos, argc, argv,
                      &rel.line_relation);
    pos = eval_tflag(pos, argc, argv,
                     &rel.word_separator);
    while (pos < argc) {
        sortfield = rel.line_relation;
        newpos = eval_sfield(pos, argc, argv,
                             &sortfield);
        if (newpos == pos)
            break;
        else {
            pos = newpos;
            rel.line_or_word_rel = 1;
            new = (SORTLIST)malloc(
                              sizeof(SORTLIST_ITEM));
            new->sortrel = sortfield;
            new->next = NULL;
            if (ptr == NULL) {
                rel.word_relation = new;
                ptr = new;
            }
            else {
                ptr->next = new;
                ptr = new;
            }
        }
    }
    pos = eval_cmd(pos, argc, argv, &rel.command,
                   &verbose);
    pos = eval_sfsize(pos, argc, argv, &rel);
    while (pos < argc) {
        if (start) {
            dlist = built_dlist(argv[pos], FALSE,
                                TRUE, FALSE, 0);
            start = dlist->flist == 
                    (FILE_DESC_LIST)ERROR;
        }
        else
            dlist = expand_dlist(dlist, argv[pos],
                          FALSE, TRUE, FALSE, 0);
        pos++;
    }
    if (verbose)
        output_rel(&rel);
    if (!start) {
        noutput = fopen("SORT.NAM", "w");
        make_dlist(dlist);
        fclose(noutput);
        drop_dlist(dlist);
        if (rel.command == 2) {
            breturn = check(rel);
            unlink("SORT.NAM");
            return(breturn);
        }
        else {
            order(rel);
            unlink("SORT.NAM");
            unlink("SORT.TMP");
            return(TRUE);
        }
    }
    else {
        fprintf(stderr, "SORT: Nothing to sort.\n");
        return(FALSE);
    }
}

/* Vergrîûern des Stapels auf STACKSIZE Bytes */

long _stksize = STACKSIZE;

void main(argc, argv)
short argc;
char  *argv[];
{   if (!sort(argc, argv))
        exit(1);
    exit(0);
}
