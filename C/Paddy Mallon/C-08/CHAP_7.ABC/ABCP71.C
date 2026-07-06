/* ABC p71  eg. 7.7                                */
/*  arrays - has some differences to the book due to GST C and typos */
/*  tested and working 10/12/86                    */

/* Soundex code generator:   to transform a string */
/* into a code that tends to bring together all    */
/* variants of the same name (usually surname).    */
/*     -[Knuth. 1973]                              */

#include <stdio.h>
int ticks = 200;
static char code[]="01230120022455012623010202";

main()
     { char str[20];
          printf("\ncharacter string? ");
          scanf("%s",str);

          encode(str);

          dumpdups(str);

          dumpzeros(str);

          fixup(str);

          printf("\nSoundex code is  :  %s\n",str);

     delay(ticks);
     }

encode(s)
     char *s;

     {

          while(*++s) *s=code[*s-'a'];
     }

dumpdups(s)
     char *s;
     {
          char *t;
          while(*s)
               if(*s==*(s+1))
                    {
                         t=s+1;
                         while(*t=*(t+1)) t++;
                    }
               else
                         s++;
     }

dumpzeros(s)
     char *s;
     {
          char *t;
          while(*s)
               if (*s=='0')
                    {
                         t=s;
                         while(*t=*(t+1)) t++;
                    }
                else 
                         s++;
     }

fixup(s)
     char *s;
     {
          int i ;
          for(i=1;*++s && i<4; i++);
          for( ;i<4;i++) *s++ ='0';
          *s=('0');
     }



     
