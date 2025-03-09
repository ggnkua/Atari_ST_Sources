/*
 * Listing 1.2, Datei : echosimp.c
 * Programm           : ECHOSIMP - Ausgabe der
 *                      Argumente auf der Standard-
 *                      ausgabe (einfache Version)
 * Modifikationsdatum : 17-Nov-89
 * Abh„ngigkeiten     : stdio.h, string.h, local.h
 */

#include <stdio.h>
#include <string.h>
#include "local.h"

/*
 * Funktion     : echosimp
 *
 * Parameter    : echosimp(argc, argv);
 *                short argc;
 *                char  *argv[];
 *
 * Aufgabe      :
 *
 * Interpretierung der durch <argc> und <argv>
 * spezifizierten Parameterliste gem„ž den Fest-
 * legungen des Kommandos echosimp.
 */

void echosimp(argc, argv)
short argc;
char  *argv[];
{   short   i,
            start = 1;
    BOOLEAN newline = TRUE;

    if (argc > 1) {
        if (strcmp(argv[1], "-N") == 0 ||
            strcmp(argv[1], "-n") == 0) {
            newline = FALSE;
            start = 2;
        }
        for (i = start; i < argc; i++)
            printf("%s", argv[i]);
    }
    if (newline)
        printf("\n");
}

void main(argc, argv)
short argc;
char  *argv[];
{   echosimp(argc, argv);
    exit(0);
}
