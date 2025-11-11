#include <stdio.h>
#include <osbind.h> /* Needed for Cconws() and Crawcin() */

extern char *getenv();

int daysinmonth[12] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

main(argc, argv)
int argc;
char *argv[];
{
     int debug = 0, i, j, month;
     char *eargv[20], *eenv[2], label[10], picture[14], sday[2], smonth[3];

     if (argc < 4) {
          Cconws("Usage: ");
          Cconws(argv[0]);
          Cconws(" <month> <year> <arguments ... >\r\n");
          Cconws("       <month> is an integer from 1 to 12.\r\n");
          Cconws("       <year> is a four-digit integer.\r\n");
          Cconws("       <arguments> are passed to starst.\r\n");
          Cconws("Portions of this program, copyright 1984, ");
          Cconws("Mark Williams Company.\r\n");
          /* We want to hold the screen if invoked from the GEM desktop;
             the desktop doesn't usually set any environment variables,
             and if getenv() does find anything, it's probably a NULL string. */
          if (((getenv("PATH")) == 0) || (strlen(getenv("PATH")) == 0)) {
               Cconws("press any key to continue:  ");
               i = Crawcin(); /* Read raw character input */
          }
          exit(1);
     }
     if (strlen(argv[2]) != 4) {
          Cconws("Year must be in 4-digit form (e.g. 1988).\r\n");
          if (((getenv("PATH")) == 0) || (strlen(getenv("PATH")) == 0)) {
               Cconws("press any key to continue:  ");
               i = Crawcin(); /* Read raw character input */
          }
          exit(1);
     }
     if ((month = atoi(argv[1])) > 100) {
          month -= 100;
          ++debug;
     }
     if ((month < 1) || (month > 12)) {
          Cconws("Month must be an integer from 1 to 12.\r\n");
          if (((getenv("PATH")) == 0) || (strlen(getenv("PATH")) == 0)) {
               Cconws("press any key to continue:  ");
               i = Crawcin(); /* Read raw character input */
          }
          exit(1);
     }
     for (i = 1; i <= daysinmonth[month - 1]; i++) {
          sprintf(smonth, "%d", month);
          sprintf(sday, "%d", i);
          eargv[0]  = "planet.ttp";
          eargv[1]  = "-y";
          eargv[2]  = argv[2];
          eargv[3]  = "-m";
          eargv[4]  = smonth;
          eargv[5]  = "-d";
          eargv[6]  = sday;
          eargv[7]  = "-t";
          eargv[8]  = "12";
          eargv[9]  = "-z";
          eargv[10] = "0";
          eargv[11] = eenv[1] = 0;
          eenv[0] = "PATH=."; /* Make programs think they came from shell */
          if (debug) {
               Cconws("\r\n");
               for (j = 0; eargv[j] != '\0'; j++) {
                    Cconws(eargv[j]);
                    Cconws(" ");
               }
          } else {
               execve(eargv[0], eargv, eenv);
          }
          sprintf(label, "%02d/%02d/%2s", month, i, argv[2] + 2);
          sprintf(picture, "star%02d%02d.pi1", month, i);
          eargv[0]  = "starst.ttp";
          eargv[1]  = "-t";
          eargv[2]  = label;
          eargv[3]  = "-x";
          eargv[4]  = picture;
          for (j = 3; j < argc; j++) {
               eargv[j + 2] = argv[j];
          }
          eargv[j + 2] = '\0';
          if (debug) {
               Cconws("\r\n");
               for (j = 0; eargv[j] != '\0'; j++) {
                    Cconws(eargv[j]);
                    Cconws(" ");
               }
               Cconws("\r\n");
          } else {
               execve(eargv[0], eargv, eenv);
          }
     } /* End of "for" loop */
     if (debug && ((getenv("PATH")) == 0) || (strlen(getenv("PATH")) == 0)) {
          Cconws("press any key to continue:  ");
          i = Crawcin(); /* Read raw character input */
     }
}
