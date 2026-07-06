/* ABC p75   eg. 8.1               */
/*    CLARITY                      */
/* compare this (eg 8.1 ) with program DETAB. Both do the same job 
   ie.  replace  TAB characters in a file  with  the  appropriate 
   number of spaces.                                           */
/* These programs are given a mark out of 100  for style       */
/*****************
 * style = 24.6  *
 *****************/

#include stdio.h

main()
     {
          int c,i,tabs[132],col=1;
          settabs(tabs);

          while(( c= getchar())!= EOF)
               if (c=='\t')
                    do { putchar(' ');col++;} while(!tabpos(col,tabs));
               else if (c=='\n'){putchar('\n'); col=1;}
                    else  {putchar(c);col++;}
     }

settabs(tabs)

     int tabs[132];
     { int i ;
          for(i=1;i<=132;i++)
               if ((i%8)==1) tabs[i]=1;else tabs[i]=0;
     }

tabpos(col,tabs)
     int col,tabs[132];
     {
          if(col>132) return(1);else return(tabs[col]);
     }

