/* fmt: einfacher Textformatierer
**
**	von Wolfram Rîsler
**	Augustastr. 44-46
**	W-5100 Aachen
**	Tel. 0241-534596
**	E-Mail: wr@bara.oche.de
**	Maus: @ AC2
**
** Dieses Programm ist Freeware
*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

int cpl = 72;		/* Zeichen pro Zeile */
int Indent = 0;		/* EinrÅckung */
int CenterFlag = 0;	/* zentrieren */
int NofillFlag = 0;	/* nicht fÅllen */

extern int getopt(int argc,char **argv,char *opts);
void printbuf(char *St);

void DoIndent(void)
{
  int i;
  for(i=Indent;i>0;i--)
    putchar(' ');
}

/* String zentriert ausgeben, `cpl' Zeichen pro Zeile */
void cputs(char *s)
{
  int i;
  for(i=(cpl-(int)strlen(s))/2;i>0;i--)
    putchar(' ');
  puts(s);
}

void myputs(char *s)
{
  if (CenterFlag)
    cputs(s);
  else
    puts(s);
}

/* stdin -> stdout */
int Fmt(void)
{
  char Buf[2000];
  char Line[2000];

  if (cpl>sizeof(Buf)-1)
  {
    puts("Maximal: -l 2000");
    return 1;
  }

  *Buf = 0;
  while(fgets(Line,(int)sizeof(Line),stdin))
  {
    char *p,*l;

    /* Leerzeichen hinten */
    for(p=Line+strlen(Line)-1;p>Line&&isspace(*p);p--);
    p[1]='\0';
    /* und vorne */
    for(l=Line;isspace(*l);l++);
    
    if (!*l)	/* Leerzeile */
    {
      DoIndent();
      myputs(Buf);
      putchar('\n');
      *Buf = '\0';
      continue;
    }
    
    for(p=strtok(l," \t");p;p=strtok((char*)0," \t"))
    {
      if (strlen(Buf)+strlen(p)<cpl)
      {
        strcat(Buf,p);
        strcat(Buf," ");
      }
      else
      {
        printbuf(Buf);
        strcpy(Buf,p);
        strcat(Buf," ");
      }
    }
  }

  DoIndent();
  myputs(Buf);
  return 0;
}

/* aus miniroff.c: */
void printbuf(char *St)
{
  long d,n,i,left;
  long *Sp,*s;
  char *p;

  /* Leerzeichen hinten */
  for(p=St+strlen(St)-1;p>St&&isspace(*p);p--);
  p[1]='\0';

  if (!*St)
    return;

  DoIndent();

  if (CenterFlag)
  {
    cputs(St);
    return;
  }

  if (NofillFlag)
  {
    puts(St);
    return;
  }

  d = cpl-strlen(St);

  if (d<=0 || !strchr(St,' '))	/* line too long or no spaces */
  {
    puts(St);
    return;
  }

  for(p=St,n=0;*p;p++)
    if (*p==' ')
      n++;

  if (d%n==0)
  {
    for(p=St;*p;p++)
    {
      if (*p==' ')
      {
        for(i = 1 + d/n;i>0;i--)
          putchar(' ');
      }
      else
        putchar(*p);
    }
    putchar('\n');
    return;
  }

  Sp = calloc(n,sizeof(*Sp));
  if (Sp==NULL)
  {
    puts(St);
    return;
  }

  left = d;

  for(i=0,s=Sp;i<n;i++,s++)
  {
    *s = 1 + d/n;
    left -= d/n;
  }
  
  /* d%n spaces left */

  while(left>0)
  {
    for(p=St,s=Sp;*p;p++)
    {
      if (*p==' ')
      {
        if (strchr(",.!?;:-)}]\"'",p[-1]))
        {
          (*s)++;
          left--;
          if (left==0)
            break;
        }
        s++;
      }
    }
    if (left==0)
      break;

    for(p=St,s=Sp;*p;p++)
    {
      if (*p==' ')
      {
        (*s)++;
        left--;
        if (left==0)
          break;
        s++;
      }
    }
  }

  for(p=St,s=Sp;*p;p++)
  {
    if (*p==' ')
    {
      for(i=*s;i>0;i--)
        putchar(' ');
      s++;
    }
    else
      putchar(*p);
  }
  free(Sp);
  putchar('\n');
}

void Usage(void)
{
  puts("Verwendung: fmt {Flags} <eingabe >ausgabe\n"
  	"Flags:\n"
  	"\t-l n\t`n' Zeichen pro Zeile\n"
  	"\t-i n\t`n' Zeichen EinrÅckung pro Zeile\n"
  	"\t-c\tzentrieren\n"
  	"\t-n\tkein Blocksatz (no fill)\n"
  	"\t-v\tVersionsnummer ausgeben & exit\n"
  	"Default: -l72 -i0"
  );
}

int main(int argc,char **argv)
{
  int c;
  extern char *optarg;

  while((c=getopt(argc,argv,"l:i:cnv?"))!=EOF)
  {
    switch(c)
    {
      case 'v':
        puts("fmt von Wolfram Rîsler <wr@bara.oche.de>\n"
		"kompiliert " __DATE__ " " __TIME__);
        return 0;
      case 'l':
        cpl = atoi(optarg);
        break;
      case 'i':
        Indent = atoi(optarg);
        break;
      case 'c':
        CenterFlag = 1;
        break;
      case 'n':
        NofillFlag = 1;
        break;
      default:
        Usage();
        return 1;
    }
  }

  return Fmt();
}