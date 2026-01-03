/* PROGRAMM TIME
 * VERSION  1.0
 * DATUM    20. Juli 1987
 * AUTOR    Uwe Sauerland
 * ZWECK    Startet das im 1. Argument angegebene Programm als Kind-Prozess
 *          und gibt die verbrauchte Zeit in Sekunden zurÅck
 *
 */

#include <stdio.h>
#include <osbind.h>

static long *clock = 0x04BAL;

long timer()
{
    long oldstack, result;

    oldstack = Super(NULL);
    result = (long) *clock;
    Super(oldstack);
    return result;
}

#define ARGLEN  1024

double difftime(t1, t0)
long t1, t0;
{
    return (double) (t1 - t0) / 200.0;
}

main(argc, argv)
int argc;
char *argv[];
{
    char args[ARGLEN];
    int i;
    long t0, t1;

    if (argc < 2)
        printf("usage: mtime <executable file> [<parameter list>]\n");
    else {
        strcpy(args, "");
        for (i = 2; i < argc; i++) {
            strcat(args, argv[i]);
            strcat(args, " ");
        }
        t0 = timer();
        if (Pexec(0, argv[1], args, NULL) >= 0) {
            t1 = timer();
            printf("Execution of process \"%s\" took ", argv[1]);
            printf("%.2f seconds.\n", difftime(t1, t0));
        } else
            printf("Error: Process could not be startet.\n");
    }
    puts("press [RETURN] to continue...");  /* so it can be run from GEM */
    gets(args);                             /* there's space left here   */
}

