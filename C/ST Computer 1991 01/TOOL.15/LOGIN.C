/*
 * Listing 3.11, Datei : login.c
 * Programm            : LOGIN - Einloggen in das
 *                       System
 * Modifikationsdatum  : 6-Jan-90
 * Abh„ngigkeiten      : stdio.h, osbind.h, local.h,
 *                       usermain.h crypt.h
 */

#include <stdio.h>
#include <osbind.h>
#include "local.h"
#include "usermain.h"
#include "crypt.h"

/*
 * Funktion     : login
 *
 * Parameter    : login(argc, argv);
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos LOGIN.
 */

#define MAXSTR 100

void login(argc, argv)
short argc;
char  *argv[];
{   USER_LIST list;
    char      user[MAXSTR],
              passwd[MAXSTR],
              pdummy[MAXSTR];

    if (argc == 1) {
        input("login:", user, TRUE);
        input("password:", passwd, FALSE);
        load_user_data();
        list = find_user(user);
        if (list != NULL) {
            if ((strcmp(list->passwd, "ohne") == 0
                 && strcmp(passwd, "ohne") == 0) ||
                (strcmp(list->passwd, 
                crypt(passwd, list->passwd)) == 0)) {
                
                /* login correct => shell starten
                 */

                pdummy[0] == 0;
                Pexec(0, list->shell, pdummy, "");
            }
            else
                printf("login incorrect\n");
        }
        else {
            crypt("Mit irgendwas", "ausbremsen");
            printf("login incorrect\n");
        }
    }
    else {
        fprintf(stderr, "SYNOPSIS: login\n");
        return;
    }
    return;
}

void main(argc, argv)
short argc;
char  *argv[];
{   do {
        login(argc, argv);
    }
    while(TRUE);
}
