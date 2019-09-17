/*     FILE.C   FILE.C    FILE.C    FILE.C    FILE.C    FILE.C

FILE INPUT AND OUTPUT         XXXXX  XXX  X      XXXXX
                              X       X   X      X
May 27, 1986                  X       X   X      X
                              XXX     X   X      XXX
                              X       X   X      X
                              X       X   X      X
                              X      XXX  XXXXX  XXXXX
*/
#include "stdio.h"
#include "struct.def"
int lastline = 0;
int arrowln = 0;
extern struct lines *top, *bot, *q, *p, *arrow, *trnsend;
extern struct vars allvars[];
extern int varinuse;
extern int printit;
extern char inline[];
extern int errcode;
extern int ignore;
extern int trnsattr;

/* ******************************************************** fileout */
/* This routine opens a disk file and writes the marked lines in the*/
/* transcript to that file.                                         */
fileout()
{
char *lpt, fileout[25];
struct lines *pt;
int i;
FILE *fp2;

   poscurs(23,1);                  /* read in filename to output to */
   printf("     filename >                    <");
   poscurs(23,17);
   for (i = 0;(fileout[i] = getchar()) != '\n';++i);
   fileout[i] = 0;                /* filename read in, ready to use */
   fp2 = fopen(fileout,"w");                           /* open file */
   pt = top;                        /* start at top of llinked list */
   do {
      lpt = pt->lineloc;                     /* line of text stored */
      if (pt->marked){                  /* only output marked lines */
         fputs(lpt,fp2);                           /* output a line */
         fputs("\n",fp2);                         /* and a linefeed */
      }
      pt = pt->dn;                             /* get the next line */
   } while (pt != NULL);
   fflush(fp2);                           /* flush the file to disk */
   fclose(fp2);                                   /* close the file */
   poscurs(23,7);
   printf("  input >                     "); 
}

/* ********************************************************* filein */
/* A diskfile is opened and read into the transcript window while   */
/* all calculations are done as the file is input. If any errors are*/
/* found, the calculations are not done, zero is returned as a      */
/* result and the remainder of the file is read in. It is assumed   */
/* that the equations are correct before the file was originally    */
/* written.                                                         */
char filenam[25] = "help";        /* default filename to start with */
filein()
{
char filein[25];
char *fc;
int i;
FILE *fp2;

   poscurs(23,1);                      /*read in filename for input */
   printf("     filename >                    <");
   poscurs(23,17);
   for (i = 0; (filein[i] = getchar()) != '\n';++i);
   filein[i] = 0;                /* filename read in , ready to use */
   if (filein[0] == 0)                  /* if no filename was input */
      strcpy(filein,filenam);            /* use last valid filemane */
   else
      strcpy(filenam,filein);                 /* save for later use */
   fp2 = fopen(filein,"r");                            /* open file */
   if (fp2 == NULL) {                         /* file doesn't exist */
      errcode = 11;
      errout();
   }
   else {  
      do {
         fc = (fgets(inline,62,fp2));
         if (fc == NULL) break;
         for (i=0;inline[i];++i);
         inline[i-1] = 0;
          parse();
         if ((ignore == 1) || errcode)
            strtrans(inline,0);
         else
            strtrans(inline,1); 
         transout();
      } while (i != NULL);
   }
   for (i = 0;i < 200;++i) inline[i] = 0;       /* clear input area */
   poscurs(23,7);
   printf("  input >                      ");
}

/* ******************************************************* strtrans */
/* A line from the input area or from a file input is stored in the */
/* transcript area. It is stored in the transcript array here, and  */
/* output to the transcript window in the "transout" function.      */
/* This function uses a linked list to store the lines of data.     */
strtrans(line,type)
char line[];
int type;
{
int i;
long int temp;
char *pt;
char buffer[25];     /* this is long enough to include an overwrite */
double xx;                                    /* temporary variable */
extern FILE *prtfile;                          /* print file output */

   p = (struct lines *)malloc(sizeof(struct lines));
   pt = (char *)malloc(1 + strlen(line));
   if ((p == NULL) || (pt == NULL)) {              /* out of memory */
      errcode = 13;
      errout();
   }

   else {                  /* there is enough memory for this entry */
      if (top == NULL){                               /* first entry */
          top = bot = p;
          p->dn = NULL;
          p->up = NULL;
      }
      else {                                  /* additional entries */
          bot->dn = p;
          p->up = bot;
          p->dn = NULL;
          bot = p;
      }

      p->lineloc = pt;
      i = strlen(line);
      p->isvalue = type;  
      p->marked = type;
      p->linelngt = i;
      if (type) {
         xx = allvars[varinuse].value;
         if (xx < 0.0) xx = -xx;
         if ((xx > 9999999.0) || (xx < .001))
            sprintf(buffer,"%12.5e",allvars[varinuse].value);
         else
            sprintf(buffer,"%12.6f",allvars[varinuse].value);
         buffer[12] = 0;
         if (varinuse > 5) {                /* variable I through N */
            temp = allvars[varinuse].value;
            temp = temp & 077777777;
            if (allvars[varinuse].outtype == 'D')
               sprintf(buffer,"(D) %8ld",temp);
            if (allvars[varinuse].outtype == 'O')
               sprintf(buffer,"(O) %8lo",temp);
            if ((allvars[varinuse].outtype == 'X') ||
                (allvars[varinuse].outtype == 'H'))
               sprintf(buffer,"(H) %8lx",temp);
         }
         strcpy(p->strval,buffer);
      }
      else
         strcpy(p->strval,"            ");
      line[i] = '\0';                            /* line terminator */
      strcpy(pt,line);
      if (type && printit){
         fprintf(prtfile,"%13s  %-62s\n",buffer,line);  
      }
      arrow = p;
      trnsend = p;
      lastline++;
      arrowln = lastline;
   }
}

/* ******************************************************* transout */
/* This function outputs the transcript to the transcript window    */
extern char strngout[];
transout()
{
int i;
int maxm = 13;       /* number of lines to output to the trans wind */
char *pt;
   p = trnsend;
   for (i = 0;i < maxm;++i){           /* count up max from trnsend */
      if (p->up == NULL) break;                /* stop if top found */
      p = p->up;
   }
   for (i = 0;i <= maxm;++i){       /* output max fields to viddisp */
      pt = p->lineloc;                 /* pt now points to the line */
      strcpy(strngout,p->strval);
      strngdis(8+i,1,trnsattr);       /* output the formatted value */
      strcpy(strngout,pt);
      blnkline(8+i,16);                     /* write blanks to line */
      if (p->marked)
         chardis(8+i,15,trnsattr,'*');          /* marked indicator */
      else 
         chardis(8+i,15,trnsattr,' ');                     /* blank */
      strngdis(8+i,17,trnsattr);
      if (arrow == p)
         chardis(8+i,14,trnsattr,16);                 /* arrow char */
      else
         chardis(8+i,14,trnsattr,' ');                     /* blank */
      if (p->dn == NULL) break;             /* stop if bottom found */
      p = p->dn;
   }
   poscurs(23,3);
   printf("%4d",arrowln);
}

/* ******************************************************* movarrow */
/* This function is used to move the arrow up or down in the window */
/* and to control where the window begins and ends in the transcript*/
/* data. The arrow is always two lines from the top or bottom if it */
/* is possible to do so.                                            */
movarrow(where)
int where;
{
int index;
struct lines *temp;
int iend, iarrow, itrnsend; 
   iend = iarrow = itrnsend = 0;
   if (where > 0) {
      for (index = where;index && (arrow != bot);--index)
         arrow = arrow->dn;                  /* move arrow down one */
      for (temp = top,index = 0;temp != bot;index++) {
         if (temp == arrow) iarrow = index;         /* locate arrow */
         if (temp == trnsend) itrnsend = index;  /* loc display end */
         temp = temp->dn;
      }
      if (temp == arrow) iarrow = index;          /* if they are at */
      if (temp == trnsend) itrnsend = index;      /* the bottom end */
      iend = index; 
           /* now trnsend must be >= arrow, but not by more than 10 */
      if (iarrow == iend) index = iend - itrnsend;
      else if (itrnsend < (iarrow+1)) index = iarrow - itrnsend + 1;
      else index = 0;       
   }
   else {
      for (index = -where;index && (arrow != top);--index)
         arrow = arrow->up;                    /* move arrow up one */
/*    if (arrow == top) arrow = arrow->dn;      move one field down */
      for (temp = top,index = 0;temp != bot;index++) {
         if (temp == arrow) iarrow = index;         /* locate arrow */
         if (temp == trnsend) itrnsend = index;  /* loc display end */
         temp = temp->dn;
      }
      if (temp == arrow) iarrow = index;          /* if they are at */
      if (temp == trnsend) itrnsend = index;      /* the bottom end */
      iend = index; 
           /* now trnsend must be >= arrow, but not by more than 12 */
      if (iarrow == 0) index = (iend > 13?13:iend) - itrnsend;
      else if ((itrnsend - iarrow) > 12) index = iarrow-itrnsend+12;
      else index = 0;
   }
   if (index > 0)
      for (;index > 0;--index)
         trnsend = trnsend->dn;
   else if (index < 0)
      for (;index < 0;++index)
         trnsend = trnsend->up;
   arrowln = iarrow;
   transout(); 
}
