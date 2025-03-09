/*
 * Listing 1.6, Datei : pwd.c
 * Programm           : PWD - Ausgabe des Arbeits-
 *                      verzeichnisses
 * Modifikationsdatum : 15-Nov-89
 * Abh„ngigkeiten     : stdio.h, osbind.h, local.h,
 *                      atom.h
 */

#include <stdio.h>
#include <osbind.h>
#include "local.h"

/*
 * Funktion     : pwd
 *
 * Parameter    : ok = pwd(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos pwd.
 */

BOOLEAN pwd(argc, argv)
short argc;
char  *argv[];
{   char actdir[100];

    if (argc == 1) {
        apwd(actdir);
        printf("%s\n", actdir);
        return(TRUE);
    }
    fprintf(stderr, "pwd: no parameter expected\n");
    return(FALSE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!pwd(argc, argv))
        exit(1);
    exit(0);
}
