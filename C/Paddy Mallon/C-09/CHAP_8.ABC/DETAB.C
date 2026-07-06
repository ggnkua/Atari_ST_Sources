/*  p156 ABC     */
/* DETAB - convert tabs to appropriate number of spaces.    */
/* Transcribed from Kernighan & Plauger's "Software Tools"  */
/****************
 * STYLE = 82.7 *
 ****************/

#include stdio.h
#define MAXLINE 132
#define TABSIZE 8

main()
     {    int ch,tabs[MAXLINE],col=1;
          settabs(tabs);
          while(( ch=getchar()) != EOF )
               if ( ch == '\t' )
                    do    { putchar(' '); col++;}
                    while ( !tabpos(col,tabs) );
               else if   ( ch == '\n' )
                         { putchar('\n'); col=1;
               else      { putchar(ch); col++;}
     }

settabs(tabs)
/* set up tab positions   */

     int tabs[MAXLINE];
     {    int i;
          for ( i=1;i<=MAXLINE; i++)
               if ( ( i%TABSIZE ) == 1)    tabs[i]=1;  
               else                        tabs[i]=0;
     }

tabpos(col,tabs)
/* see if we're at a tab position  */

     int col ,tabs[MAXLINE];
     {
          if ( col > MAXLINE ) return(1) ; else return(tabs[col]);
     }

