/*===============================================================*
 *                                                               *
 * startup.c                                                     *
 *                                                               *
 * Startup Modul fÅr Turbo C                                     *
 *                                                               *
 * - Verarbeitung von XARG Argumenten                            *
 * - Verarbeitung von ARGV Argumenten                            *
 *                                                               *
 * 07.06.90 Jan Bolt   Version 210990                            *
 *                                                               *
 * Turbo C                                                       *
 *===============================================================*/
     
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>

/*================= Hauptprogramm =====================*/

int do_main(int argc, char *argv[])
    {
    int i;

    for (i = 0; i < argc; i++)
        printf("argv[%d]='%s'\n", i, argv[i]);

    return 0;
    }

/* strdup() fehlt in TC Lib */

char *strdup(const char *str)
     {
     char *p;
     
     if ((p = malloc(strlen(str)+1)) != NULL)
        strcpy(p, str);
     return p;
     }

/*========== XARG-, ARGV- Verarbeitung ================*/

#define ENSMEM -39            /* TOS-Fehler out of mem */
#define XARG_MAGIC 0x78417267 /* "xArg" */

typedef struct                /* XARG - Struktur */
        {
        char   xarg_magic[4];
        int    xargc;
        char   **xargv;
        char   *xiovector;
        BASPAG *xparent;
        } XARG;
   
int main(int nargc, char *nargv[])
    {
    extern BASPAG *_BasPag;
    XARG *xarg;
    int argc, i, rv;
    char *xenv, **argv;
     
    if ((xenv = getenv("xArg")) != NULL &&
        (xarg = (XARG *)strtoul(xenv, NULL, 16)) != NULL &&
        ((long)xarg & 1) == 0 &&
        *(long *)xarg->xarg_magic == XARG_MAGIC &&
        xarg->xparent == _BasPag->p_parent)
       {
       printf("XARG:\n");
       /* XARG-Struktur ist gÅltig. Argumente mÅssen kopiert */
       /* werden, sie befinden sich im Speicher des Parent.  */
       /* Speicher wird dynamisch mit malloc zugewiesen      */
       argc = xarg->xargc;
       if ((argv = malloc((argc+1)*sizeof(char *))) == NULL)
          return ENSMEM;
       argv[argc] = NULL;
       for (i = 0; i < argc; i++)
           if ((argv[i] = strdup(xarg->xargv[i])) == NULL)
              return ENSMEM;

       rv = do_main(argc, argv);

       for (i = 0; i < argc; i++)
           free(argv[i]);
       free(argv);
       
       return rv;
       }

    if ((xenv = getenv("ARGV")) != NULL &&
       *_BasPag->p_cmdlin == 127) /* LÑnge Kommandozeile = 127 ? */
       {
       printf("ARGV:\n");
       /* ARGV ist gÅltig. Es gilt einen Vektor von      */
       /* Zeigern auf die Argumente zu bilden, argc      */
       /* ist zu diesem Zeitpunkt leider nicht bekannt.  */
       /* Speicher wird dynamisch mit malloc zugewiesen. */
       xenv[-5] = '\0';  /* "ARGV=" lîschen */
       while (*xenv++)   /* ggf Wert Åberspringen */
             ;
       argc = 0;
       if ((argv = malloc(sizeof(char *))) == NULL)
          return ENSMEM;
       while (*xenv)
             {
             argv[argc++] = xenv;
             if ((argv = realloc(argv, (argc+1)*sizeof(char *))) == NULL)
                return ENSMEM;
             while (*xenv++)
                   ;
             }
       argv[argc] = NULL;

       rv = do_main(argc, argv);

       free(argv);

       return rv;
       }

    printf("Kommandozeile:\n");
    return do_main(nargc, nargv);
    }
 
