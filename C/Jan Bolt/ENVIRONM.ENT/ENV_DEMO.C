/*===============================================================*
 *                                                               *
 * env_demo.c                                                    *
 *                                                               *
 * Demo Environment-Strings                                      *
 *                                                               *
 *                                                               *
 * 17.02.90 Jan Bolt                                             *
 *                                                               *
 * Turbo C                                                       *
 *===============================================================*/
 
#include <tos.h>

int main()
    {
    static char env[] = "Diese Environment-Strings haben nur \
Demo-Charakter.\0\
Die Åbliche Form ist:\0\
Variable=Wert\0\
z.B.:\0\
PATH=c:\\bin;c:\\turbo_c\\bin;.\0\
SHELL=c:\\bin\\mupfel.prg\0";
    
    Pexec(0, "env.tos", (COMMAND *)"", env);
    
    return 0;
    }

