/*
 * Listing 3.6, Datei : usermain.c
 * Modul              : USERMAIN - Benutzer-
 *                      Verwaltung
 * Modifikationsdatum : 27-Dez-1990
 * AbhÑngigkeiten     : stdio.h, string.h, ctype.h
 *                      osbind.h, local.h
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <osbind.h>
#include "local.h"

/*
 * Konstante    : PASSWD_FILENAME
 *
 * Aufgabe      :
 *
 * EnthÑlt den Dateiname in dem sich die
 * Benutzerdaten befinden.
 */

#define PASSWD_FILENAME "\\BIN\\PASSWD"

/*
 * Datentypen/
 * Variablen    : USER_LIST, USER_LIST_NODE/
 *                user_list, modified
 *
 * Aufgabe      :
 *
 * Interne Darstellung der Benutzerdaten.
 */

typedef struct user_list_node *USER_LIST;

typedef struct user_list_node {
    char      *user,
              *passwd,
              *shell;
    USER_LIST next;
} USER_LIST_NODE;

static USER_LIST user_list = NULL;
static BOOLEAN   modified  = FALSE;

/*
 * Funktionen   : load_user_data
 *
 * Parameter    : load_user_data();
 *
 * Aufgabe      :
 *
 * Laden der Benutzerdaten aus der Datei
 * <PASSWD_FILENAME>. Der Aufruf dieser Funktion
 * ist die Voraussetzung fÅr nachfolgende Zugriffe
 * mit <find_data>, <insert_replace_data> und
 * <delete_data>.
 */

void load_user_data()
{   FILE *file;
    char      user[100],
              passwd[100],
              shell[100];
    USER_LIST work,
              new;

    if (user_list != NULL)
        return ;
    file = fopen(PASSWD_FILENAME, "r");
    if (file == NULL)
        return ;
    while (!feof(file)) {
        fscanf(file, "%s|%s|%s", user, passwd,
               shell);
        if (!feof(file)) {
            new = (USER_LIST)malloc(
                         sizeof(USER_LIST_NODE));
            new->user = malloc(strlen(user) + 1);
            strcpy(new->user, user);
            new->passwd = malloc(strlen(passwd)+1);
            strcpy(new->passwd, passwd);
            new->shell = malloc(strlen(shell) + 1);
            strcpy(new->shell, shell);
            new->next = NULL;
            if (user_list == NULL) {
                user_list = new;
                work = new;
            }
            else {
                work->next = new;
                work = new;
            }
        }
    }
    fclose(file);
}

/*
 * Funktionen   : find_user
 *
 * Parameter    : list = find_user(user);
 *                USER_LIST list;
 *                char      *user;
 *
 * Aufgabe      :
 *
 * Durchsuchen der Benutzerdaten innerhalb der
 * <user_list> nach den Daten fÅr den Benutzer
 * <user>. Bei erfolgreicher Suche wird ein
 * entsprechender Zeiger zurÅckgegeben. Ansonsten
 * wird der Wert NULL zurÅckgegeben.
 */

USER_LIST find_user(user)
char *user;
{   USER_LIST work = user_list;

    while(work != NULL) {
        if (strcmp(user, work->user) == 0)
            return(work);
        work = work->next;
    }
    return(NULL);
}

/*
 * Funktionen   : insert_replace_user
 *
 * Parameter    : insert_replace_user(user, 
 *                           passwd, shell);
 *                char *user,
 *                     *passwd,
 *                     *shell;
 *
 * Aufgabe      :
 *
 * EinfÅgen oder Ersetzen der Benutzerdaten fÅr den
 * Benutzer <user>.
 */

void insert_replace_user(user, passwd, shell)
char *user,
     *passwd,
     *shell;
{   USER_LIST list,
              new;

    list = find_user(user);
    if (list == NULL) {
        new = (USER_LIST)malloc(
                           sizeof(USER_LIST_NODE));
        new->user = malloc(strlen(user) + 1);
        strcpy(new->user, user);
        new->passwd = malloc(strlen(passwd) + 1);
        strcpy(new->passwd, passwd);
        new->shell = malloc(strlen(shell) + 1);
        strcpy(new->shell, shell);
        new->next = user_list;
        user_list = new;
    }
    else {
        free(list->passwd);
        free(list->shell);
        list->passwd = malloc(strlen(passwd) + 1);
        strcpy(list->passwd, passwd);
        new->shell = malloc(strlen(shell) + 1);
        strcpy(new->shell, shell);
    }
    modified = TRUE;
}

/*
 * Funktionen   : delete_user
 *
 * Parameter    : delete_user(user);
 *                char *user;
 *
 * Aufgabe      :
 *
 * Lîschen der Daten des Benutzers <user>.
 */

void delete_user(user)
char *user;
{   USER_LIST prework = NULL,
              work    = user_list,
              old;
    
    while (work != NULL) {
        if (strcmp(work->user, user) == 0) {
            old = work;
            if (prework == NULL)
                user_list = work->next;
            else
                prework->next = work->next;
            free(work->user);
            free(work->passwd);
            free(work->shell);
            free((char *)work);
            modified = TRUE;
            return ;
        }
        prework = work;
        work = work->next;
    }
}

/*
 * Funktionen   : set_modification_bit
 *
 * Parameter    : set_modification_bit();
 *
 * Aufgabe      :
 *
 * Falls eine direkte externe Manipulation von
 * Benutzerdaten vorgenommen worden ist, dann kann
 * dies dem Modul USERMAIN mit <set_modification_bit>
 * mitgeteilt werden.
 */

void set_modification_bit()
{   modified = TRUE;
}

/*
 * Funktionen   : save_user_data
 *
 * Parameter    : save_user_data();
 *
 * Aufgabe      :
 *
 * Falls mit den vorangehenden Funktionen
 * énderungen an den Benutzerdaten vorgenommen
 * worden sind, dann werden diese énderungen durch
 * den Aufruf von <save_user_data> gespeichert.
 */

void save_user_data()
{   FILE      *file;
    USER_LIST old;

    if (!modified)
        return ;
    file = fopen(PASSWD_FILENAME, "w");
    if (file == NULL)
        return ;
    while (user_list != NULL) {
        fprintf(file, "%s | %s | %s\n",
                user_list->user,
                user_list->passwd,
                user_list->shell);
        old = user_list;
        user_list = user_list->next;
        free(old->user);
        free(old->passwd);
        free(old->shell);
        free((char *)old);
    }
    fclose(file);
    modified = FALSE;
}

/*
 * Funktionen   : input
 *
 * Parameter    : input(prompt, erg, echo);
 *                char    *prompt,
 *                        *erg;
 *                BOOLEAN echo;
 *
 * Aufgabe      :
 *
 * Einlesen einer Zeile mit oder ohne <echo>.
 * Mit <prompt> wird der Text Åbergeben, der als
 * Zeileninformation ausgegeben wird. Innerhalb
 * von <erg> wird der Zeileninhalt zurÅckgegeben.
 */

#define MAXSTR 100

void input(prompt, erg, echo)
char    *prompt,
        *erg;
BOOLEAN echo;
{   int  i = 0;
    char c;

    printf("%s ", prompt);
    fflush(stdout);
    do {
        if (echo)
            c = Cconin();
        else
            c = Cnecin();
        if (c == '\r') {
            while (i < MAXSTR) 
                erg[i++] = 0;
            printf("\n");
            break;
        }
        else if (isprint(c) && c != ' ')
            erg[i++] = c;
    }
    while(TRUE);
    if (strlen(erg) == 0)
        strcpy(erg, "ohne");
}
