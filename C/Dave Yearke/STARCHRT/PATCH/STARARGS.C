/*
** Written by Dave Yearke (dgy@sigmast), September 1988.
** Portions of this program (c) Mark Williams Company.
*/

#include <osbind.h> /* Needed for Cconws() and Crawcin() */

main()
{
     char *argptr, command[130], *eargv[20], *eenv[2];
     int i;

     Cconws("STARARGS - Utility for running Starchart ");
     Cconws("software from the desktop.\r\n");
     Cconws("Portions of this program, copyright 1984, ");
     Cconws("Mark Williams Company.");
     for (;;) {
          *command = 128; /* Number of characters Cconrs() should read */
          Cursconf(1, 0); /* Show cursor */
          Cconws("\r\n\nPlease enter the full name of the program to be run ");
          Cconws("(e.g. starst.ttp)\r\n");
          Cconws("and its arguments, or an empty line to quit:\r\n");
          Cconrs(command); /* Read an edited string from standard input */
          if (*(command + 1) == 0) /* Number of chars actually read */
               exit();
          Cconws("\r\n");
          command[*(command + 1) + 2] = '\0'; /* Make sure it's terminated */
          i = 0;
          argptr = command + 2;
          do {
               eargv[i] = argptr;
               while ((*++argptr != ' ') && (*argptr != '\0'))
                    ; /* Browse until space or end of string */
               if (*argptr == ' ') /* If we found a space */
                    *argptr++ = '\0'; /* End the string preceding this point */
               while ((*argptr == ' ') && (*argptr != '\0'))
                    ++argptr; /* Browse until non-space or end of string */
               Cconws(eargv[i++]);
               Cconws(" ");
          } while (*argptr != '\0');
          eargv[i] = eenv[1] = 0;
          eenv[0] = "PATH=."; /* The programs will think they're being run */
          Cconws("\r\n");     /* from a shell. */
          execve(eargv[0], eargv, eenv);
     }
}
