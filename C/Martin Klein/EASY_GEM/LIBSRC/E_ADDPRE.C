#include <string.h>

char *add_prefix(char *name,char *add)
{
   char *p,*end;
   
   end=p=name+strlen(name)-1;
   while(!(p==name || *p=='\\' || *p=='.'))
      p--;
   if(*p=='.') return name;   /* Prefix schon vorhanden */
   if(p!=end && p!=name)      /* Prefix mu noch angefgt werden */
   {
      strcat(name,".");
      strcat(name,add);
      return name;
   }
   return (char *)0;          /* kein gltiger Pfadname */
}