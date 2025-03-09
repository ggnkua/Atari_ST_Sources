/*
 * Listing 3.1, Datei : caesar.c
 * Programm           : CAESAR - Ein einfaches Ver-
 *                      schlÅsselungsverfahren
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
 *                unsigned char key;
 *
 * Aufgabe      :
 *
 * Ver- und EntschlÅsselung mit dem CAESAR-Verfahren.
 * Der SchlÅssel <key> wird als Parameter Åbergeben.
 * Als Ein- und Ausgabe dienen die beiden Standard-
 * kanÑle.
 */

void crypt(key)
unsigned char key;
{   short help;

    while (!feof(stdin)) {
        help = getchar() + key;
        if (help > 255)
            help -= 256;
        if (!feof(stdin))
            putchar((unsigned char)help);
    }
}

void encrypt(key)
unsigned char key;
{   short help;

    while (!feof(stdin)) {
        help = getchar() - key;
        if (help < 0)
            help += 256;
        if (!feof(stdin))
            putchar((unsigned char)help);
    }
}

/*
 * Funktion     : caesar
 *
 * Parameter    : ok = caesar(argc, argv);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    *argv[];
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gemÑû den Fest-
 * legungen des Kommandos CAESAR.
 */

BOOLEAN caesar(argc, argv)
short argc;
char  *argv[];
{   unsigned char key;

    if (argc == 3) {
        if (strlen(argv[2]) == 1)
            key = argv[2][0];
        else {
            fprintf(stderr,
       "caesar: command expects a letter for key\n");
            return(FALSE);
        }
        if (strcmp(argv[1], "-e") == 0 ||
            strcmp(argv[1], "-E") == 0) {
            encrypt(key);
            return(TRUE);
        }
        else if (strcmp(argv[1], "-c") == 0 ||
                 strcmp(argv[1], "-C") == 0) {
            crypt(key);
            return(TRUE);
        }
        else {
            fprintf(stderr,
                "caesar: option -c or -e expected\n");
            return(FALSE);
        }
    }
    else {
        fprintf(stderr, "%s\n%s\n",
                "SYNOPSIS: caesar -c key",
                "          caesar -e key");
        return(FALSE);
    }
}

void main(argc, argv)
short argc;
char  *argv[];
{   if (!caesar(argc, argv))
        exit(1);
    exit(0);
}

