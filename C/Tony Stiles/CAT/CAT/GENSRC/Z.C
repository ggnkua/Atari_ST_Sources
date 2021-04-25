#include <stdio.h>
	
#define CLIB TRUE

static	char	*_strtok = '\0';	/* local token pointer */

char *strchr(string, symbol)
register char *string;
register char symbol;
{
   do
   {
      if(*string == symbol)
         return(string);
   } while(*string++);
   return(NULL);
}

char *strstr(string, pattern)
register char *string, *pattern;
{
   register int plen;
   char *strchr();

   plen = strlen(pattern);
   while((string=strchr(string, *pattern))!='\0')
   {
      if(strncmp(string, pattern, plen) == 0)
         break;
         ++string;
   }
   return(string);
}

char *strtok(string, delim)
register char *string, *delim;
{
   register char *p;
   char *strchr();

   if (string == '\0')
      string = _strtok;
   while(*string && strchr(delim, *string))
      ++string;
   if(*string == '\0')		/* no more tokens */
      return('\0');
   p = string;
   while(*string && !strchr(delim, *string))
      ++string;
   if(*string != '\0')
      *string++ = '\0';
   _strtok = string;
   return(p);
}

char *memcpy(dst, src, cnt)
register char *dst, *src;
register int cnt;
{
   char *t;
   
   t= dst;
   
   while(cnt--)
      *dst++ = *src++;
   return(t);
}

