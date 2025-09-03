/*===============================================================*
 *                                                               *
 * touch.c                                                       *
 *                                                               *
 * update file date-/timestamp                                   *
 *                                                               *
 * usage: touch [-c] [-f] file ...                               *
 *               -c  do not create file if it does not exist     *
 *               -f  touch in spite of r/w permission            *
 *               file = valid Gemdos filename,                   *
 *                      path, wildcards allowed                  *
 *                                                               *
 *        e.g. touch *.c source.s\*.s                            *
 *                                                               *
 * 13.05.90 Jan Bolt                                             *
 *                                                               *
 * SOZOBON C                                                     *
 *===============================================================*/
 
#include <stdio.h>
#include <osbind.h>
#include <string.h>

long _STKSIZ = 8192;   /* more space for XARG */

typedef struct         /* date/time, Gemdos format */
        {
        int time;
        int date;
        } DOSTIME;

/* globals */
char myname[] = "touch";
int cflag = 0;
int fflag = 0;

usage()
     {
     Cconws("Usage: ");
     Cconws(myname);
     Cconws(" [-c] file...\r\n");
     exit(1);
     }

error(msg1,msg2)
     char *msg1;
     char *msg2;
     {
     Cconws(myname);
     Cconws(": ");
     Cconws(msg1);
     Cconws(" ");
     Cconws(msg2);
     }

/*======================= main program ===========================*/

main(argc,argv)
int argc;
register char *argv[];
    {
    register int i;
    register char *f, *p;
    char o;
    
    if (argc < 2)
       usage();
       
    for (i=1; i<argc; i++)
        {
        if (*argv[i] == '-')
           {
           o = *(argv[i]+1) & 0xdf; /* force upper case */
           if (o == 'C')
              cflag = 1;
           if (o == 'F')
              fflag = 1;
           }
        else
           {
           p = argv[i];
           if ( (strchr(p,'*') == NULL) &&
                (strchr(p,'?') == NULL) ) /* no wildcards */
              touch(p);
           else
              {
              while ((f=wildcard(p)) != NULL)
                    {
                    touch(f);
                    p = NULL;
                    }
              }
           }
        }
    }

touch(file)
register char *file;
     {
     DOSTIME dtime;
     register int fd;
     register long dt;
     int mode;

     mode = fflag;
     if ( ((fd=Fopen(file,mode)) == -36) && (fflag) )
        {
        error(file,"write protected, not touched");
        return;
        }
     if (fd == -33)
        {
        if (!cflag)
           fd = Fcreate(file,0);
        else
           return;
        }
     if (fd < 0)
        {
        error("cannot open",file);
        return;
        }
     dt = Gettime(); /* read IKBD- or realtime clock */
     dtime.time = dt;
     dtime.date = dt >> 16;
     Fdatime(&dtime,fd,1);
     Fclose(fd);
     }

