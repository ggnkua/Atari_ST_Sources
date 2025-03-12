/*===============================================================*
 *                                                               *
 * xargdemo.c                                                    *
 *                                                               *
 * Demo XARG-Verfahren                                           *
 *                                                               *
 * muž mit putenv.o gelinkt werden                               *
 *                                                               *
 * 17.02.90 Jan Bolt  Version 210990                             *
 *                                                               *
 * Turbo C                                                       *
 *===============================================================*/
 
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

typedef struct
        {
        char     xarg_magic[4];  /* enth„lt "xArg" */
        int      xargc;          /* argc */
        char     **xargv;        /* argv */
        char     *xiovector;     /* bisher unbenutzt */
        BASPAG   *xparent;       /* Zeiger auf aufrufendes Prg */
        } XARG;

/*======================= Hauptprogramm =========================*/

main()
    {
    int putenv(char *entry);
    extern BASPAG *_BasPag;  /* Zeiger auf eigene Basepage */
    char env[14], *p;
    static char cmd[] = "\x8p1 p2 p3";
    static char *xargs[] = {"startup",
                            "xp1",
                            "xp2",
                            "xp3",
                            NULL};

    static XARG xarg = {'x','A','r','g',4,xargs,NULL,NULL};

    xarg.xparent = _BasPag;

    /* Parameter per Kommandozeile */
    Pexec(0, "startup.ttp", (COMMAND *)cmd, NULL);
    getchar();

    /* Parameter per XARG */
    sprintf(env, "xArg=%08lX", &xarg); /* Zeiger auf xarg in  */
    if (!putenv(env))                  /* in xArg= uebergeben */
       fprintf(stderr, "environment overflow !\n");
    else
       Pexec(0, "startup.ttp", (COMMAND *)cmd, NULL);
    getchar();
    putenv("xArg");                   /* xArg l”schen */

    /* Parameter per ARGV */
    if (!putenv("ARGV= startup ap1 ap2 ap3"))
       fprintf(stderr, "environment overflow !\n");
    else
       {
       /* Argumente durch 0 trennen */
       p = getenv("ARGV");
       while (*p)
             if (*p++ == ' ')
                p[-1] = 0;
       cmd[0] = 127;
       Pexec(0, "startup.ttp", (COMMAND *)cmd, NULL);
       }
    getchar();

    return 0;
    }

