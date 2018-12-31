#include <stdio.h>
#include <stdlib.h>
#ifdef __TURBOC__
#include <tos.h>
#else
#include <osbind.h>
#endif
#include <ctype.h>
#include <string.h>
#define DATAFIL "\\KILLDRV.INF"
#define MAXARG 40

void main(argc,argv)
int argc;
char *argv[];
{
 long *drives=(long *) 0x4c2; /* here the drive bits are... */
 long oldstack;				  /* got to remember the stack for Super */
 unsigned int drivene=0;	  /* this one holds drive-bits.  */
 register int i;
 FILE *filen;				  /* filen = Norwegian for "The file" :-> */
 char opsjoner[MAXARG];	      /* opsjoner = Norwegian for options :-> */
 
 puts("\nKilldrives ver. 1.0\n(c) Erling Henanger 1990\n");
 if(argc<2)			    /* are there any arguments out there ? */ 
   {					/* NO */
     if((filen=fopen(DATAFIL,"r"))!=(FILE *)0) /* does the file exist */
       {
         fgets(opsjoner,MAXARG,filen); 			/* yes, read it */
         fclose(filen);
       }
     else
       opsjoner[0]=0;		/* indicates empty string */
   }
 else	/* HOORRAAHH arguments !!! */
   strncpy(opsjoner,argv[1],(size_t)MAXARG); 
 if((opsjoner[0]!='+')&&(opsjoner[0]!='-')) /* checking sanity */
   {
     puts("useage : killdrv +/-[drv][drv]... f.inst. killdrv -fgh\n");
     exit(1);
   }
 for(i=1;i<=strlen(opsjoner),i<MAXARG;i++)
   {
     opsjoner[i]=toupper(opsjoner[i]);  /* both a and A allowed */
     drivene|=(1<<(opsjoner[i]-'A'));	/* set bit belonging to drive */
   }
 oldstack=Super(0L);		/* take good care of the stack 	*/
 if(opsjoner[0]=='-')       /* clear'em ??? */
   *drives &= ~drivene;		/* YES,clear selected bits */
 else
   *drives |= drivene;		/* must be + then, set selected bits */
 Super((void *)oldstack);	/* return to userstack */
 exit(0);
}