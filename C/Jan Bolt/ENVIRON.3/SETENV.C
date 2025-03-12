/*===============================================================*
 *                                                               *
 * setenv.c                                                      *
 *                                                               *
 * startet AES im AUTO-Ordner                                    *
 * und setzt Environment-Variablen                               *
 *                                                               *
 * sollte letztes Programm im AUTO-Ordner sein                   *
 *                                                               *
 * Linken mit Option -s=512 (512 byte Stack reichen)             *
 *                                                               *
 * 20.01.90 Jan Bolt                                             *
 *                                                               *
 * TURBO C                                                       *
 *===============================================================*/
 
#include <stdio.h>
#include <tos.h>

#define ENV_LEN 256

#define _bootdev  (int *)0x446
#define _cmdload  (int *)0x482
#define _sysbase  (void **)0x4f2
#define exec_os   (void **)0x4fe

#define ROM_START (void *)0xfc0000
    
char *envstr(void)      /* environment strings generieren */
     {
     char c;
     int fd, i = 0;
     
     static char env[ENV_LEN+1] = "PATH=;#:;.\0";
     
     if ((fd = Fopen("setenv.inf",0)) < 0)
        env[6] = 'a' + *_bootdev;
     else
        {
        while (Fread(fd, 1, &c) == 1 && i < (ENV_LEN-2))
              {
              switch (c)
                     {
                     case '\r' : break;
                     case '\n' : env[i++] = '\0'; break;
                     default   : env[i++] = c;
                     }
              }
        env[i++] = '\0';
        env[i] = '\0';
        Fclose(fd);
        }

     return env;
     }

void do_main(void)
     {
     BASPAG *basepage;
     char *envp;              /* Zeiger auf environment */
 
     *_sysbase = ROM_START;   /* Beginn OS setzen */
     
     if (*_cmdload)           /* command.prg starten */
        {
        Pexec(0, "command.prg", (COMMAND *)"", NULL);
        }
     else                     /* AES starten */
        {
        envp = envstr();      /* environment holen */
        basepage = (BASPAG *)Pexec(5, NULL, NULL, envp);
        basepage->p_tbase = *exec_os;
        Pexec(4, NULL, (void *)basepage, envp);
        }
     }
     
/*======================= Hauptprogramm =========================*/

int main()
    {
    Supexec(do_main);  /* do_main im Supervisor Modus ausfÅhren */
       
    return 0;
    }


