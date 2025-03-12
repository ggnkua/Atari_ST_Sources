/*
 * Listing 2.3, Datei : echo.c
 * Programm           : ECHO - Ausgabe der Argumente
 *                      auf der Standardausgabe
 * Modifikationsdatum : 17-Dez-89
 * AbhÑngigkeiten     : ctype.h, stdio.h, string.h,
 *                      local.h
 */

#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include "local.h"

/*
 * Funktion     : print
 *
 * Parameter    : print(line);
 *                char *line;
 *
 * Aufgabe      :
 *
 * Die Zeile <line> wird auf dem Standardausgabekanal
 * ausgegeben. Dabei sind die C-Ersatzdarstellungen
 * zu berÅcksichtigen und innerhalb von <print>
 * entsprechend zu interpretieren.
 */

void print(line)
char *line;
{   short   i = 0,
            len = strlen(line);

    while (i < len) {
        if (line[i] == '\\' )
            if (i + 1 == len)
                return ;
            else {
                i++;
                switch(line[i]) {
                    case 'n' :
                        putchar('\n');
                        break;
                    case 't' :
                        putchar('\t');
                        break;
                    case 'b' :
                        putchar('\b');
                        break;
                    case 'r' :
                        putchar('\r');
                        break;
                    case 'f' :
                        putchar('\f');
                        break;
                    case '\"' :
                        putchar('\"');
                        break;
                    case '\'' :
                        putchar('\'');
                        break;
                    default:
                        if (isoctal(line[i])) {
                            if (i + 2 < len &&
                              isoctal(line[i + 1]) &&
                              isoctal(line[i + 2])) {
                              putchar(
                                todigit(line[i + 1])*8 +
                                todigit(line[i + 2]));
                              i += 2;
                            }
                        }
                        else
                            putchar(line[i]);
                        break;
                }
            }
        else if (line[i] != '\"')
            putchar(line[i]);
        i++;
    }
}

/*
 * Funktion     : echo
 *
 * Parameter    : echo(argc, argv);
 *                short argc;
 *                char  *argv[];
 *
 * Aufgabe      :
 *
 * Interpretation der durch <argc> und <argv>
 * spezifizierten Parameterliste gemÑû den Fest-
 * legungen des Kommandos ECHO.
 */

void echo(argc, argv)
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
            print(argv[i]);
    }
    if (newline)
        printf("\n");
}

short main(argc, argv)
short argc;
char  *argv[];
{   echo(argc, argv);
    exit(0);
}

