#include "osbind.h"
#define MaxNumber 1500

int handle;

main()
{ char *p[MaxNumber];
  char *speicher;
  int i,k,s,flag;
  char c;

  speicher=(char *)Malloc((long)(MaxNumber*25));

  /* Einlesen */
  handle=(int)Fopen("D:DIR_PRG",0);
  i=0;
  s=1;
  p[0]=speicher;

  do
    { Fread(handle,1l,&c);
      speicher[i]=c;

      if (c=='\r')
       { p[s]=speicher+i+1;
         s++;}
   
      i++;
    }
  while (c!=0);
  Fclose(handle);
  s--;      /* s: anzahl der Programme*/


  /* ausgabe */
  printf("\n\rAnzahl der Programme:");
  printf("%d",s);printf("\n\r");
  for (i=0;i<s;i++)
    {Print(p[i]);}

  printf("\n\rIch sortiere...\n\r\n\r");


  /* Sortieren */
  do {flag=0;
      for(k=0;k<(s-1);k++)
       {if (cpstring(p[k],p[k+1])==1)
          { char *help;flag=1;
           help=p[k];p[k]=p[k+1];p[k+1]=help;}
       }
      }
  while(flag==1);

  /* ausgabe */

  handle=(int)Fcreate("D:DIR_PRG.ORD",0);
  for (i=0;i<s;i++)
   { PrintAndSave(p[i]);}
  Fclose(handle);

 } /* end main */




PrintAndSave(string)
 char *string;
{ int i;
  i=0;
  do
    { Cconout(string[i]);
      Fwrite(handle,1l,&string[i]);
      i++;
    }
  while (string[i-1]!='\r');
}


Print(string)
 char *string;
{ int i;
  i=0;
  do
    { Cconout(string[i]);
      i++;        }
  while (string[i-1]!='\r');
}

cpstring(s1,s2)
 char *s1,*s2;
{ int i,r;
  i=0;r=2;

  do
   { if (s1[i]>s2[i]) r=1;
     else if (s1[i]<s2[i]) r=0;
     i++;
   }
  while (r==2);
  return(r);
}
    



