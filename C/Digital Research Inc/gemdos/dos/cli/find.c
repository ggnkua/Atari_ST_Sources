/****************************************************************************
*
*               C   R U N T I M E   G R E P   R O U T I N E
*               -------------------------------------------
*       Copyright 1983 by Digital Research Inc.  All rights reserved.
*
*       The routine "grep" searches for an ascii character pattern in
*       a series of files.  "Grep" allows the following options:
*
*       OPTION  FUNCTION
*       ------  --------
*       -v      Print only lines not matching the pattern
*       -c      Print only a count of the lines
*       -n      Print with line numbers
*       -s      Write out the sector number in which the pattern was found
*       -l      Write out a list of the files in which the pattern was found
*       -y      Do not distinguish between upper & lower case
*
*       Calling Sequence:
*
*               grep(options,expression,files);
*
*       Where:
*
*               options         Is a pointer to a string of options
*               expression      Is a pointer to the search pattern
*               files           Is an array of pointers to filenames
*
*****************************************************************************/
                                                /****************************/
                                                /*      INCLUDE FILES       */
                                                /****************************/
#include <stdio.h>                              /* standard I/O library     */
#include <portab.h>                             /* CP/M portability defines */
#include <ctype.h>                              /* char type definitions    */
                                                /****************************/
                                                /*     GLOBAL VARIABLES     */
                                                /****************************/
GLOBAL BYTE __match  = TRUE;                    /* Print Matching lines only*/
GLOBAL BYTE __count  = FALSE;                   /* Just count the lines     */
GLOBAL BYTE __num    = FALSE;                   /* Print line #'s           */
GLOBAL BYTE __sector = FALSE;                   /* Display the sector       */
GLOBAL BYTE __list   = FALSE;                   /* Display only a file list */
GLOBAL BYTE __nocase = FALSE;                   /* Distinguish between cases*/
GLOBAL FILE *fstream;                           /* file stream ptr          */
GLOBAL BYTE line[129];                          /* line buffer              */
GLOBAL BYTE line1[129];                         /* Temp line buffer         */
GLOBAL BYTE first = TRUE;                       /* used on the list option  */
GLOBAL UWORD numfound = 0;                      /* number of lines found    */
                                                /****************************/
                                                /*        FUNCTIONS         */
                                                /****************************/
FILE *fopenb();                                 /* returns a ptr to a file  */
                                                /****************************/
                                                /*          MAIN            */
main(argc,argv)                                 /* Entry point              */
WORD    argc;                                   /* = # args                 */
BYTE    **argv;                                 /* -> args                  */
{                                               /****************************/
        BYTE    *options;                       /* Option pointer           */
        BYTE    *expression;                    /* -> expression            */
        BYTE    **files;                        /* -> files                 */
                                                /*                          */
        if(argc < 3)                            /* Must have at least 2     */
        {                                       /*                          */
usage:    printf("Usage: find [-options] pattern files\n");
          exit();                               /*                          */
        }                                       /****************************/
                                                /*                          */
        options = "-ny";                        /* Set up option            */
        if(*argv[1] == '-')                     /* Options specified?       */
        {                                       /*                          */
                options = argv[1];              /* Yes, use them            */
                if(argc < 4) goto usage;        /* check for valid args     */
                expression = argv[2];           /* -> Pattern               */
                files = &argv[3];               /* -> file list             */
        }                                       /****************************/
        else {                                  /* No options               */
                expression = argv[1];           /* Expression               */
                files = &argv[2];               /* file list                */
        }                                       /****************************/
        return(grep(options,expression,files)); /* Call the real function   */
}                                               /*                          */
                                                /****************************/
grep(options,expression,files)                  /*                          */
REG BYTE *options;                              /* option list              */
REG BYTE *expression;                           /* pattern to search for    */
BYTE *files[];                                  /* array of files           */
{                                               /*                          */
        REG BYTE *p;                            /* temp pointer             */
        REG UWORD patt_cnt;                     /* pattern counter          */
        REG UWORD char_cnt;                     /* character count          */
        REG UWORD line_cnt;                     /* line count               */
        REG UWORD i;                            /* counter                  */
        UWORD length;                           /* length of pattern        */
        BYTE found;                             /* set if pattern is found  */
                                                /*                          */
                                                /*                          */
        if(*options != '-')                     /* Legal option list?       */
        {                                       /*                          */
          fprintf(stderr,"FIND--Illegal option list: %s\n",options); /*     */
          exit(-1);                             /* Just quit                */
        }                                       /****************************/
        while(*options)                         /* if found ........        */
        {                                       /*                          */
                switch(*++options)              /*                          */
                {                               /*                          */
                  case 'v' : __match = FALSE;   /* print non-matching lines */
                             break;             /*                          */
                  case 'c' : __count = TRUE;    /* print a count of lines   */
                             break;             /*                          */
                  case 'n' : __num   = TRUE;    /* number the lines         */
                             break;             /*                          */
                  case 's' : __sector= TRUE;    /* print sector number      */
                             break;             /*                          */
                  case 'l' : __list  = TRUE;    /* list the files           */
                             break;             /*                          */
                  case 'y' : __nocase= TRUE;    /* no case distinction      */
                             /*break;*/         /*                          */
                }                               /*                          */
        }                                       /*                          */
                                                /****************************/
        if(__list)                              /* list option has priority */
        {                                       /* over these.....          */
                __count = FALSE;                /*                          */
                __num = FALSE;                  /*                          */
                __sector = FALSE;               /*                          */
        }                                       /*                          */
        else                                    /*                          */
                if(__count)                     /* count option has priority*/
                {                               /* over these.....          */
                        __num = FALSE;          /*                          */
                        __sector = FALSE;       /*                          */
                }                               /*                          */
                else                            /*                          */
                        if(__num)               /* num option has priority  */
                        __sector = FALSE;       /* over the sector option   */
        if(__nocase)                            /* if no case destinction   */
        {                                       /*                          */
                p = expression;                 /*                          */
                while(*p)                       /* change expression to     */
                {                               /*                          */
                        *p = toupper(*p);       /* upper case letters       */
                        p++;                    /*                          */
                }                               /*                          */
        }                                       /*                          */
        length = strlen(expression);            /* count the characters in  */
                                                /* the pattern to match     */
        while(*files)                           /* search all the files     */
        {                                       /*                          */
           if((fstream = fopenb(*files,"r")) != NULL)/*try to open the file */
           {                                    /*                          */
              char_cnt = 0;                     /* initialize char count    */
              line_cnt = 0;                     /* initialize line # count  */
              numfound = 0;                     /* initialize # found       */
              first = TRUE;                     /* initialize for list      */
              if(!__list && !__count)           /* if these options are not */
              {                                 /* ON then print the file-  */
                printf("\nFILE:  %s\n",*files); /* name before each search  */
                printf("----\n");               /*                          */
              }                                 /*                          */
              while(!feof(fstream))             /* go until end of file     */
              {                                 /*                          */
                found = FALSE; patt_cnt = 0;    /*                          */
                p = expression;                 /*                          */
                for(i=0;i<129;i++)              /* Zap out the buffers      */
                        line[i]=line1[i]=0;     /*                          */
                fgets(line1,129,fstream);       /* read a line              */
                                                /****************************/
                for(i = 0;line1[i];i++)         /*                          */
                if(__nocase)                    /* Translate?               */
                     line[i] = toupper(line1[i]);/*                         */
                else                            /* Don't translate          */
                     line[i] = line1[i];        /* Just copy                */
                                                /****************************/
                i = 0;                          /*                          */
                while(line[i])                  /* scan until a NULL        */
                {                               /*                          */
                  char_cnt++;                   /* bump the char count      */
                  if(line[i] == *p)             /* check pattern            */
                  {                             /*                          */
                        p++;                    /* look for next char       */
                        patt_cnt++;             /* we found a character     */
                        if(patt_cnt == length)  /* Have we found the end ?  */
                        {                       /*                          */
                            found = TRUE;       /* set a flag               */
                            p = expression;     /*                          */
                            patt_cnt = 0;       /*                          */
                        }                       /*                          */
                  }                             /*                          */
                  else                          /*                          */
                  {                             /*                          */
                        p = expression;         /* reset the pattern ptr    */
                        patt_cnt = 0;           /* start the count over     */
                  }                             /*                          */
                  i++;                          /* check next character     */ 
                }                               /*                          */
                line[i-1] = NULL;               /* mask out extra LF        */
                line_cnt++;                     /* bump the line count      */
                prtline(found,char_cnt,line_cnt,files);/*then print routine */
              }                                 /*                          */
              if(__count)                       /* is count option ON ?     */
                printf("\n%s: %d",*files,numfound);/*print a count of # fnd */

           fclose(fstream);                     /* Close the file           */
           files++;                             /* go to next file          */
           }                                    /*                          */
           else {
                printf("\n%s not found\n",*files);/* file not exist         */
		exit();				/* terminate process        */
		}
        }                                       /*                          */
}                                               /****************************/
                                                /*      PRINT ROUTINE       */ 
prtline(found,char_cnt,line_cnt,files)          /****************************/
BYTE found;                                     /* does line contain pattern*/
UWORD char_cnt;                                 /* number of chars searched */
UWORD line_cnt;                                 /* number of lines searched */
BYTE *files[];                                  /* current file             */
{                                               /****************************/
        if((__match && found) ||                /* have we a line ?         */
          (!__match && !found))                 /*                          */
        {                                       /*                          */
                numfound++;                     /* count the # lines found  */
                if(__count) return;             /* nothing to do            */
                if(__list)                      /* if the list option       */
                {                               /*                          */
                        if(first)               /* FIRST pattern found ?    */
                        printf("\n%s",*files);  /* print the filename       */
                        first = FALSE;          /* turn off flag            */
                        return;                 /* and return..             */
                }                               /*                          */
                if(__sector)                    /* do we print the sector# ?*/
                {                               /*                          */
                      printf("\n%d",char_cnt/128);/* divide count by 128    */
                      return;                   /*                          */
                }                               /*                          */
                if(__num)                       /* do we print a line # ?   */
                {                               /*                          */
                        printf("%5d:  ",line_cnt); /*                       */
                }                               /* otherwise.....           */
                fputs(line1,stdout);            /* just print the line      */
        }                                       /*                          */ 
}                                               /****************************/


