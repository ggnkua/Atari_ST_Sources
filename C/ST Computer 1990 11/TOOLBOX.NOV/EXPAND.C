/*
 * Listing 1.10, Datei : expand.c
 * Modul               : EXPAND - Argumentexpansion
 * Modifikationsdatum  : 17-Nov-89
 * AbhÑngigkeiten      : stdio.h, ctype.h, string.h,
 *                       osbind.h, local.h, atom.h
 */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <osbind.h>
#include "local.h"
#include "atom.h"

/*
 * Datentypen   : FILE_DESC, FILE_DESC_ITEM, 
 *                FILE_DESC_LIST DIR_DESC_ITEM, 
 *                DIR_DESC_LIST
 *
 * Aufgabe      :
 *
 * Aufnahme der ausgewÑhlten Dateiinformationen.
 */

typedef struct {
    char  reserved[21],
          fattr;
    short ftime,
          fdate;
    long  fsize;
    char  fname[14];
} FILE_DESC;

typedef struct file_desc_item {
    FILE_DESC             fdesc;
    struct file_desc_item *next,
                          *down;
} FILE_DESC_ITEM, *FILE_DESC_LIST;

typedef struct dir_desc_item {
    char                 dirpath[100];
    FILE_DESC_LIST       flist;
    struct dir_desc_item *next;
} DIR_DESC_ITEM, *DIR_DESC_LIST;

/*
 * Funktionen   : built_flist, concat_flist, 
 *                built_dir, built_dlist,
 *                expand_dlist
 *
 * Parameter    : flist = built_flist(directory,
 *                            filename, all,
 *                            rec, rel);
 *                concat_flist(&destlist, &srclist,
 *                             rel);
 *                direc = built_dir(argument, all,
 *                                  dir, rec,
 *                                  relation);
 *                dlist = built_dlist(argument, all,
 *                                   rec, dir, 
 *                                   relation);
 *                dlist = expand_dlist(dlist,
 *                                   argument, all,
 *                                   dir, rec,
 *                                   relation);
 *                FILE_DESC_LIST flist,
 *                               destlist,
 *                               srclist;
 *                DIR_DESC_ITEM  direc;
 *                DIR_DESC_LIST  dlist;
 *                char           *directory,
 *                               *filename,
 *                               *argument;
 *                BOOLEAN        all,
 *                               dir,
 *                               rec;
 *                short          (*rel)(),
 *                               relation;
 *
 * Aufgabe      :
 *
 * Die obigen Funktionen dienen alle zum Aufbau der
 * Datentypen, die Dateiinformationen aufnehmen
 * kînnen. Diese Datenstruktur ist durch die
 * Parameter <argument>, <all>, <dir>, <rec> und
 * <relation> parametriesiert. <argument> gibt an,
 * welche Dateien ausgewÑhlt werden sollen; <all>
 * gibt an, ob auch Dateien mit einem fÅhrenden
 * Punkt ausgewÑhlt werden sollen. <dir> gibt an ob
 * Verzeichnisse komplett durchsucht werden sollen
 * oder nicht. <rec> charakterisiert die rekursive
 * Suche nach Dateiinhalten und <relation> letzt-
 * lich gibt an, in welcher Reihenfolge die
 * Ergebnisse in der Datenstruktur DIR_DESC_LIST
 * angeordnet werden. Hier stehen folgende Werte
 * fÅr folgende Reihenfolgen:
 *
 * 0  unsortiert
 * 1  nach dem Dateinamen sortiert
 * 2  nach dem Modifikationsdatum sortiert
 *
 * Alle Åbrigen Werte sind unzulÑssig.
 */

FILE_DESC_LIST built_flist(directory, filename,
                           all, rec, rel)
char    *directory,
        *filename;
BOOLEAN all,
        rec;
short   (*rel)();
{   FILE_DESC_LIST start = NULL,
                   work,
                   prework,
                   new;
    long           olddta;
    FILE_DESC      newdta;
    char           oldpath[100],
                   actpath[100];
    short          fserg;
    
    olddta = Fgetdta();
    Fsetdta(&newdta);
    apwd(oldpath);
    if (!acd(directory))
        return((FILE_DESC_LIST)ERROR);
    fserg = Fsfirst(filename, 0x0037);
    if (fserg < 0)
        return(NULL);
    while (fserg >= 0) {
        if (all || (strcmp(".", newdta.fname) != 0
            && strcmp("..", newdta.fname) != 0)) {
            new = (FILE_DESC_LIST)malloc(
                       sizeof(FILE_DESC_ITEM));
            new->fdesc = newdta;
            new->next = NULL;
            new->down = NULL;
            if (start == NULL)
                start = new;
            else {
                work = start;
                prework = NULL;
                while (work != NULL) {
                    if ((*rel)(work->fdesc,
                               new->fdesc) < 0) {
                        prework = work;
                        work = work->next;
                    }
                    else {
                        new->next = work;
                        if (prework == NULL)
                            start = new;
                        else
                            prework->next = new;
                        break;
                    }
                }
                if (work == NULL)
                    prework->next = new;
            }
        }
        fserg = Fsnext();
    }
    if (rec) {
        work = start;
        while (work != NULL) {
            if ((work->fdesc.fattr & 0x10) &&
             strcmp(".", work->fdesc.fname) != 0 &&
             strcmp("..", work->fdesc.fname) != 0)
                work->down = built_flist(
                      work->fdesc.fname,
                      "*.*", all, rec, rel);
            work = work->next;
        }
    }
    acd(oldpath);
    Fsetdta(olddta);
    return(start);
}

void concat_flist(destlist, srclist, rel)
FILE_DESC_LIST *destlist,
               *srclist;
short          (*rel)();
{   FILE_DESC_LIST new,
                   newlist,
                   work,
                   prework;
                   
    newlist = *srclist;
    while (newlist != NULL) {
        new = newlist;
        newlist = newlist->next;
        new->next = NULL;
        work = *destlist;
        prework = NULL;
        while (work != NULL) {
            if ((*rel)(work->fdesc,
                 new->fdesc) < 0) {
                prework = work;
                work = work->next;
            }
            else if ((*rel)(work->fdesc,
                     new->fdesc) == 0) {
                free(new);
                break;
            }
            else {
                new->next = work;
                if (prework == NULL)
                    *destlist = new;
                else
                    prework->next = new;
                break;
            }
        }
        if (work == NULL)
            prework->next = new;
    }
}

static short relunsorted(desc1, desc2)
FILE_DESC desc1, desc2;
{   return(-1);
}

static short relname(desc1, desc2)
FILE_DESC desc1, desc2;
{   return(strcmp(desc1.fname, desc2.fname));
}

static short reltime(desc1, desc2)
FILE_DESC desc1, desc2;
{   if (desc1.fdate < desc2.fdate)
        return(-1);
    else if (desc1.fdate == desc2.fdate)
        if (desc1.ftime < desc2.ftime)
            return(-1);
        else if (desc1.ftime == desc2.ftime)
            return(0);
        else
            return(1);
    else
        return(1);
}

DIR_DESC_ITEM built_dir(argument, all, dir,
                        rec, relation)
char    *argument;
BOOLEAN all,
        dir,
        rec;
short   relation;
{   DIR_DESC_ITEM erg;
    char          actpath[100],
                  wrkpath[100],
                  directory[100],
                  filename[100];
    short         (*rel)();

    switch(relation) {
        case 0:
            rel = relunsorted;
            break;
        case 1:
            rel = relname;
            break;
        case 2:
            rel = reltime;
            break;
    }
    erg.next = NULL;
    apwd(actpath);
    if (!dir && fisdir(argument)) {
        strcpy(filename, "");
        acd(argument);
        apwd(erg.dirpath);
    }
    else {
        pathsplit(argument, directory, filename);
        if (strcmp(directory, "") == 0)
            strcpy(erg.dirpath, actpath);
        else {
            if (!acd(directory)) {
                strcpy(erg.dirpath, "");
                erg.flist = NULL;
                return(erg);
            }
            apwd(wrkpath);
            strcpy(erg.dirpath, wrkpath);
        }
    }
    if (strcmp(filename, "") == 0)
        erg.flist = built_flist(erg.dirpath, "*.*",
                          all, rec, rel);
    else
        erg.flist = built_flist(erg.dirpath,
                          filename, all, rec, rel);
    acd(actpath);
    return(erg);
}

DIR_DESC_LIST built_dlist(argument, all, dir,
                          rec, relation)
char    *argument;
BOOLEAN all,
        dir,
        rec;
short   relation;
{   DIR_DESC_LIST new;

    new = (DIR_DESC_LIST)malloc(
                        sizeof(DIR_DESC_ITEM));
    *new = built_dir(argument, all, dir, rec,
                     relation);
    if (new->flist == (FILE_DESC_LIST)ERROR)
     fprintf(stderr, "xp: Unknown filename %s\n",
             argument);
    return(new);
}

DIR_DESC_LIST expand_dlist(dlist, argument, all,
                           dir, rec, relation)
DIR_DESC_LIST dlist;
char          *argument;
BOOLEAN       all,
              dir,
              rec;
short         relation;
{   DIR_DESC_LIST new,
                  prework,
                  work;
    short         (*rel)();

    new = (DIR_DESC_LIST)malloc(
                           sizeof(DIR_DESC_ITEM));
    *new = built_dir(argument, all, dir, rec,
                     relation);
    if (new->flist == (FILE_DESC_LIST)ERROR) {
     fprintf(stderr, "xp: Unknown filename %s\n",
            argument);
        return(dlist);
    }
    work = dlist;
    prework = NULL;
    while (work != NULL) {
        if (strcmp(work->dirpath,
            new->dirpath) < 0) {
            prework = work;
            work = work->next;
        }
        else if (strcmp(work->dirpath,
                 new->dirpath) == 0) {
            switch(relation) {
                case 0:
                    rel = relunsorted;
                    break;
                case 1:
                    rel = relname;
                    break;
                case 2:
                    rel = reltime;
                    break;
                }
            concat_flist(&work->flist, &new->flist,
                         rel);
            return(dlist);
        }
        else {
            if (prework == NULL) {
                new->next = dlist;
                dlist = new;
            }
            else {
                new->next = work;
                prework->next = new;
            }
            return(dlist);
        }
    }
    prework->next = new;
    return(dlist);
}

/*
 * Funktionen   : drop_flist, drop_dir, drop_flist
 *
 * Parameter    : drop_flist(flist);
 *                drop_dir(dir);
 *                drop_dlist(dlist);
 *                FILE_DESC_LIST flist;
 *                DIR_DESC_ITEM  dir;
 *                DIR_DESC_LIST  dlist;
 *
 * Aufgabe      :
 *
 * Freigabe der mit den Funktionen <built_flist>,
 * <concat_flist>, <built_dir>, <built_dlist> und
 * <expand_dlist> erzeugten Datenstruktur.
 */

void drop_flist(flist)
FILE_DESC_LIST flist;
{   if (flist != NULL || flist != 
        (FILE_DESC_LIST)ERROR) {
        drop_flist(flist->down);
        drop_flist(flist->next);
        free(flist);
    }
}

void drop_dir(dir)
DIR_DESC_ITEM dir;
{   drop_flist(dir.flist);
}

void drop_dlist(dlist)
DIR_DESC_LIST dlist;
{   if (dlist != NULL) {
        drop_dlist(dlist->next);
        free(dlist);
    }
}
