/*
 * Listing 3.3, Datei : geo.c
 * Programm           : GEO - VerschlÅsselung durch
 *                      Permutation mit Hilfe einer
 *                      Matrix
 * Modifikationsdatum : 15-Juli-1990
 * AbhÑngigkeiten     : stdio.h, local.h
 */

#include <stdio.h>
#include "local.h"

/*
 * Funktionen   : crypt, encrypt
 *
 * Parameter    : crypt(x, y);
 *                encrypt(x, y);
 *                short x, y;
 *
 * Aufgabe      :
 *
 * Ver- und EntschlÅsselung mit einem geometrischen
 * Verfahren. Die Eingabedaten werden in eine
 * Matrix eingetragen, deren Grîûe durch <x> und
 * <y> parametrisiert ist.
 */

void crypt(x, y)
short x, y;
{   short max_char,
          akt_char,
          xi,
          yi,
          px,
          py;
    char  *infield,
          help;

    max_char = x * y;
    infield = malloc(max_char);
    do {
        akt_char = 0;
        do {
            help = getchar();
            if (!feof(stdin)) {
                infield[akt_char] = help;
                akt_char++;
            }
        } while(!feof(stdin) && akt_char < max_char);
        for (xi = 0; xi < x; xi++)
            for (yi = 0; yi < y; yi++) {
                px = (xi + yi) % x;
                py = y - yi - 1;
                if (py * x + px < akt_char)
                    putchar(infield[py * x + px]);
            }
    } while (!feof(stdin));
    free(infield);
}

void encrypt(x, y)
short x, y;
{   short max_char,
          akt_char,
          xi,
          yi,
          px,
          py,
          i;
    char  *infield,
          *outfield,
          help;

    max_char = x * y;
    infield = malloc(max_char);
    outfield = malloc(max_char);
    do {
        akt_char = 0;
        do {
            help = getchar();
            if (!feof(stdin)) {
                infield[akt_char] = help;
                akt_char++;
            }
        } while(!feof(stdin) && akt_char < max_char);
        i = 0;
        for (xi = 0; xi < x; xi++)
            for (yi = 0; yi < y; yi++) {
                px = (xi + yi) % x;
                py = y - yi - 1;
                if (py * x + px < akt_char)
                    outfield[py * x + px] =
                                         infield[i++];
            }
        for (i = 0; i < akt_char; i++)
            putchar(outfield[i]);
    } while (!feof(stdin));
    free(infield);
    free(outfield);
}

/*
 * Funktion     : geo
 *
 * Parameter    : ok = geo(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gemÑû den Fest-
 * legungen des Kommandos GEO.
 */

BOOLEAN geo(argc, argv)
short argc;
char  *argv[];
{   short x, y;

    if (argc == 4) {
        x = atoi(argv[2]);
        y = atoi(argv[3]);
        if (x <= 0 || y <= 0) {
            fprintf(stderr,
     "geo: the keys have to be positive integers\n");
            return(FALSE);
        }
        if (strcmp(argv[1], "-e") == 0 ||
            strcmp(argv[1], "-E") == 0) {
            encrypt(x, y);
            return(TRUE);
        }
        else if (strcmp(argv[1], "-c") == 0 ||
                 strcmp(argv[1], "-C") == 0) {
            crypt(x, y);
            return(TRUE);
        }
        else {
            fprintf(stderr,
                 "geo: option -c or -e expected\n");
            return(FALSE);
        }
    }
    else {
        fprintf(stderr, "%s\n%s\n",
                "SYNOPSIS: geo -c key1 key2",
                "          geo -e key1 key2");
        return(FALSE);
    }
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!geo(argc, argv))
        exit(1);
    exit(0);
}
