/*===============================================================*
 *                                                               *
 * ff_demo.c                                                     *
 *                                                               *
 * Demo findfile                                                 *
 *                                                               *
 * muž mit putenv.o, findfile.o gelinkt werden                   *
 *                                                               *
 * 24.05.90 Jan Bolt                                             *
 *                                                               *
 * Turbo C                                                       *
 *===============================================================*/
 
#include <stdio.h>
#include <stdlib.h>

/*======================= Hauptprogramm =========================*/

int main()
    {
    static char file[] = "env.tos";
    char *p, *findfile(char *file);
    int putenv(char *entry);
    
    if (getenv("PATH") == NULL)
       putenv("PATH=\\bin;bin;.");
    
    if ((p = findfile(file)) == NULL)
       printf("%s nicht gefunden !\n", file);
    else
       printf("%s\n", p);

    getchar();
    
    return 0;
    }

