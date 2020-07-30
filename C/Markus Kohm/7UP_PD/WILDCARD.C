/* Suchen mit DOS-Wildcards */
/*****************************************************************************
*
*											  7UP
*									  Modul: WILDCARD.C
*									 (c) by TheoSoft '93
*							 Ersatz fÅr rekursive alte Funktion
*
*****************************************************************************/
#include <stdio.h>

char *match(char *first, register char *string, register char *pattern, int *len, char all, char one);
char *imatch(char *first, register char *string, register char *pattern, int *len, char all, char one);

char *match(char *first, register char *string, register char *pattern, int *len, char all, char one)
{
   register char *s, *p, *f=NULL;
   s=string; 
   p=pattern;

   while(*p == all || *p == one)
   {
      if(*p == all)
      {
         f=first;
         break;
      }
      p++;
	}
   p=pattern;

   do
   {
      if((*p != all) && (*p != one) && (*p != *s))
      {
      	string++;
      	s=string;
      	p=pattern;
      }
      else
      {
         if(*p == all)
         {
            while((*p == all) || (*p == one))
               p++;
/* '*' soll 0-max. Widerholungen sein.
            s++;
*/
				while(*s && (*s != *p))
           		s++;
         }
         else
         {
            s++;
            p++;
         }
      }
   }
   while(*string && *p);
   if(f)
	   *len=(int)(s-f);
   else
	   *len=(int)(s-string);
   return(*string?(f?f:string):NULL);
}

char *imatch(char *first, register char *string, register char *pattern, int *len, char all, char one)
{
   register char *s, *p, *f=NULL;
   s=string; 
   p=pattern;
   
   while(*p == all || *p == one)
   {
      if(*p == all)
      {
         f=first;
         break;
      }
      p++;
	}
   p=pattern;

   do
   {
      if((*p != all) && (*p != one) && (__tolower(*p) != __tolower(*s)))
      {
      	string++;
      	s=string;
      	p=pattern;
      }
      else
      {
         if(*p == all)
         {
            while((*p == all) || (*p == one))
               p++;
/* '*' soll 0-max. Widerholungen sein.
            s++;
*/
				while(*s && (__tolower(*s) != __tolower(*p)))
           		s++;
         }
         else
         {
            s++;
            p++;
         }
      }
   }
   while(*string && *p);
   if(f)
	   *len=(int)(s-f);
   else
	   *len=(int)(s-string);
   return(*string?(f?f:string):NULL);
}

char *rmatch(char *str, register int index, register char *pattern, int *len, char all, char one)
{
	register int i;
	register char *cp;
	for(i=index; i>=0; i--)
	{
      if((cp=match(str,&str[i],pattern,len,all,one))!=NULL)
	      return(cp);
	}
	return(NULL);
}

char *rimatch(char *str, register int index, register char *pattern, int *len, char all, char one)
{
	register int i,k;
	register char *cp;
	for(i=index; i>=0; i--)
	{
      if((cp=imatch(str,&str[i],pattern,len,all,one))!=NULL)
	      return(cp);
	}
	return(NULL);
}

/*
main()
{
   int len=0;
   char *cp;
appl_init();
   cp=match("ng der Infozeile beim Blockmarkieren mit der Maus.","ei*x",&len, '*', '?');
   if(cp)
	   printf("\33H|%s|%d",cp,len);
	else
	   printf("\33Hnegativ");
appl_exit();
}

*/
