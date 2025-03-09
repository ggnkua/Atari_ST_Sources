/*===============================================================*
 *                                                               *
 * env.c                                                         *
 *                                                               *
 * Demo getenv                                                   *
 *                                                               *
 * 23.05.90 Jan Bolt                                             *
 *                                                               *
 * Turbo C                                                       *
 *===============================================================*/
 
#include <stdio.h>
#include <stdlib.h>

/*======================= Hauptprogramm =========================*/

int main()
    {
    char *p;
    
    if ((p = getenv("PATH")) != NULL)
       printf("PATH=%s\n",p);
    else
       printf("PATH ist nicht gesetzt !\n");

    getchar();

    return 0;
    }

