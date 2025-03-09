/*
 * Listing 1.17, Datei : mkdir.c
 * Programm            : MKDIR - Erzeugen von
 *                       Unterverzeichnissen
 * Modifikationsdatum  : 15-Nov-89
 * Abh„ngigkeiten      : stdio.h, osbind.h, local.h
 */

#include <stdio.h>
#include <osbind.h>
#include "local.h"

/*
 * Funktion     : mkdir
 *
 * Parameter    : ok = mkdir(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos mkdir.
 */

BOOLEAN mkdir(argc, argv)
short argc;
char  *argv[];
{   short i;

    if (argc >= 2) {
        for (i = 1; i < argc; i++) {
            if (Dcreate(argv[i]) != 0) {
                fprintf(stderr,
                  "mkdir: can't create %s\n",
                  argv[i]);
                return(FALSE);
            }
        }
    }
    else {
        fprintf(stderr,
           "mkdir: need at least one parameter\n");
        return(FALSE);
    }
    return(TRUE);
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!mkdir(argc, argv))
        exit(1);
    exit(0);
}
