/*
 * Listing 3.2, Datei : poly.c
 * Programm           : POLY - Polyalphabetische
 *                      VerschlÅsselung
 * Modifikationsdatum : 14-Juli-1990
 * AbhÑngigkeiten     : stdio.h, local.h
 */

#include <stdio.h>
#include "local.h"

/*
 * Funktionen   : crypt, encrypt
 *
 * Parameter    : crypt(key);
 *                encrypt(key);
 *                unsigned char *key;
 *
 * Aufgabe      :
 *
 * Ver- und EntschlÅsselung mit einem polyalphabeti-
 * schen Verfahren. <key> ist ein Zeiger auf eine
 * nullterminierte Zeichenkette.
 */

void crypt(key)
unsigned char *key;
{   short help,
          i = 0,
          l = strlen(key);

    while (!feof(stdin)) {
        help = getchar() + key[i];
        if (help > 255)
            help -= 256;
        if (!feof(stdin))
            putchar((unsigned char)help);
        i++;
        if (i == l)
            i = 0;
    }
}

void encrypt(key)
unsigned char *key;
{   short help,
          i = 0,
          l = strlen(key);

    while (!feof(stdin)) {
        help = getchar() - key[i];
        if (help < 0)
            help += 256;
        if (!feof(stdin))
            putchar((unsigned char)help);
        i++;
        if (i == l)
           i = 0;
    }
}

/*
 * Funktion     : poly
 *
 * Parameter    : ok = poly(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gemÑû den Fest-
 * legungen des Kommandos POLY.
 */

BOOLEAN poly(argc, argv)
short argc;
char  *argv[];
{   if (argc == 3) {
        if (strcmp(argv[1], "-e") == 0 ||
            strcmp(argv[1], "-E") == 0) {
            encrypt(argv[2]);
            return(TRUE);
        }
        else if (strcmp(argv[1], "-c") == 0 ||
                 strcmp(argv[1], "-C") == 0) {
            crypt(argv[2]);
            return(TRUE);
        }
        else {
            fprintf(stderr,
                 "poly: option -c or -e expected\n");
            return(FALSE);
        }
    }
    else {
        fprintf(stderr, "%s\n%s\n",
                "SYNOPSIS: poly -c key",
                "          poly -e key");
        return(FALSE);
    }
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!poly(argc, argv))
        exit(1);
    exit(0);
}

