/*===============================================================*
 *                                                               *
 * demo2.c                                                       *
 *                                                               *
 * putenv Demo, muž mit putenv.o gelinkt werden                  *
 *                                                               *
 * 23.05.90 Jan Bolt                                             *
 *                                                               *
 * Turbo C                                                       *
 *===============================================================*/

#include <stdio.h>
#include <tos.h>

int putenv(char *entry);
 
/*======================= Hauptprogramm =========================*/

int main()
    {
    static char cmd[] = "";
    
    putenv("Variable=Wert");
    Pexec(0, "env.tos", (COMMAND *)cmd, NULL);
    putenv("PATH=\\bin;bin;c:\\turbo_c\\bin");
    Pexec(0, "env.tos", (COMMAND *)cmd, NULL);
    putenv("Variable=neuer_Wert");
    Pexec(0, "env.tos", (COMMAND *)cmd, NULL);
    putenv("Variable");
    Pexec(0, "env.tos", (COMMAND *)cmd, NULL);

    return 0;
    }

