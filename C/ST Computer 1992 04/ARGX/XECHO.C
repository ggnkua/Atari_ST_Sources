/*
 * XECHO.C
 *
 * Testprogramm zur automatischen Argument-Expansion.
 */

#include "stdstuff.h"
#include "argx.h"

void main(argc, argv, env)
int argc;
char **argv;
char **env;                     /* nicht etwa `char *env;'! */
{
    int i;

    for (i = 0; i < argc; i++)
        printf("%d: %s\n", i, argv[i]);
    printf("\n");
    for (i = 0; env[i] != NULL; i++)
        printf("%s\n", env[i]);
    exit(0);
}

