/*===============================================================*
 *                                                               *
 * grep.c                      Version 150590                    *
 *                                                               *
 * sucht String in Textdateien                                   *
 *                                                               *
 * Aufruf: grep [-cdhilnv] String Dateien [>[>]output]           *
 *                                                               *
 *          -c zeige nur Anzahl der gefundenen Zeilen            *
 *          -d warte vor Programmende auf Taste                  *
 *          -h keine Dateinamen anzeigen                         *
 *          -i ignoriere Groû/Klein                              *
 *          -l liste Dateien, die String enthalten               *
 *          -n Ausgabe jeder gefundenen Zeile mit Zeilennummer   *
 *          -v liste Zeilen, die String nicht enthalten          *
 *          >output Ausgabeumlenkung                             *
 *          >>output Ausgabeumlenkung Append-Modus               *
 *                                                               *
 * z.B. grep -i move.w *.s                                       *
 *      grep "int print (void)" *.c >prn:                        *
 *      grep -in include *.c *.s *.mac                           *
 *                                                               *
 * RÅckgabe: 0 Zeile(n) gefunden                                 *
 *           1 keine Zeile gefunden                              *
 *           2 Fehler aufgetreten                                *
 *                                                               *
 * 22.01.90 Jan Bolt                                             *
 *                                                               *
 * TURBO C                                                       *
 *===============================================================*/

#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <tos.h>
#include <string.h>

#define FALSE 0
#define TRUE 1
#define MAX_ARGS 30
#define MAX_FILES 10
#define MATCH 0

/* globale Variablen */
char myname[] = "grep";
unsigned long mlines = 0;  /* Anz gefundener Zeilen */

char *pattern = "";        /* Suchstring  */
/* Dateimuster */
char *files[MAX_FILES] = {NULL,NULL,NULL,NULL,NULL,
                          NULL,NULL,NULL,NULL,NULL};
int cflag = FALSE;         /* c Option    */
int dflag = FALSE;         /* d Option    */
int hflag = FALSE;         /* h Option    */
int iflag = FALSE;         /* i Option    */
int lflag = FALSE;         /* l Option    */
int nflag = FALSE;         /* n Option    */
int vflag = FALSE;         /* v Option    */

void usage (void)
     {
     fprintf (stderr,"Usage: %s -cdhilnv pattern file ...\n",myname);

     exit (2);
     }
     
void error (int err,char *msg)
     {
     static char *errors[] = {"can't open",
                              "invalid redirection to",
                              "unterminated string"};
                              
     fprintf (stderr,"%s: %s %s\n",myname,errors[err-1],msg);

     exit (2);
     }
     
void message (char *msg)
     {
     fprintf (stderr,"%s: %s\n",myname,msg);
     }
      
FILE *redirect (char *out,char *mode)
     {
     FILE *red;
     
     if ((red=freopen(out,mode,stdout)) == NULL)
        error (2,out);

     return red;
     }

/* Feststellen, ob pattern in zeile enthalten ist */
/* liefert Zeiger auf 1. Vorkommen von pattern in */
/* zeile oder NULL (erweiterungsfÑhig)            */
char *get_match (char *zeile,char *pattern)
     {
     return strstr (zeile,pattern);
     }

void do_file (char *file)
     {
     char zeile[256], uzeile[256];
     int match;
     unsigned long znr = 0;
 
     while (fgets(zeile,255,stdin) != NULL)
           {
           strcpy (uzeile,zeile);
           znr++;
           if (iflag)
              strupr (uzeile);
           match = FALSE;
           if (get_match(uzeile,pattern) != NULL)
              match = TRUE;
           if (match ^ vflag) 
              {
              mlines++;
              if (!cflag)
                 {
                 if (lflag)
                    {
                    printf ("%s\n",file);
                    break;
                    }
                 if (!hflag)
                    printf ("%s:",file);
                 if (nflag)
                    printf ("%lu:",znr);
                 printf ("%s",zeile);
                 }
              }
           }
     }
 
void do_grep (void)
     {
     int i, exist;
     int match = FALSE;
     DTA *dta_pnt;
     FILE *fp;
     char path[65];
     char *p;
 
     dta_pnt = Fgetdta ();
     if (iflag)
        strupr (pattern);
     i = 0;
     
     /* falls kein file angegeben, von stdin lesen */
     if (files[i] == NULL)
        {
        match = TRUE;
        do_file ("");
        return;
        }
        
     while (files[i] != NULL)
           {
           /* Pfad isolieren */
           strncpy (path,files[i],64);
           path[64] = '\0';
           if ((p=strrchr(path,'\\')) != NULL)
              p++;
           else
              p = path;
           
           exist = Fsfirst(files[i],0);
   
           while (exist == MATCH)
                 {
                 match = TRUE;
                 strcpy (p,dta_pnt->filename);
                 strlwr (path);
                 if ((fp=freopen(path,"r",stdin)) == NULL)
                    error (1,path);
                 
                 do_file (p);
                 fclose (fp);
                 exist = Fsnext ();
                 }
           i++;
           }
     if (!match)
        message ("no match.");
     else
     if (cflag)
        printf ("%lu\n",mlines);
     }
     
int do_main (int argc,char *argv[])
    {
    char opt;
    int i, k;

    if (argc < 2)
       usage ();

    /* Optionen lesen */
    i = 1;
    if (*(argv[i]) == '-')
       {
       for (k=1; (opt=*(argv[i]+k) & 0xdf) != '\0'; k++)
           {
           switch (opt)
                  {
                  case 'C' : cflag = TRUE; break;
                  case 'D' : dflag = TRUE; break;
                  case 'H' : hflag = TRUE; break;
                  case 'I' : iflag = TRUE; break;
                  case 'L' : lflag = TRUE; break;
                  case 'N' : nflag = TRUE; break;
                  case 'V' : vflag = TRUE; break;
                  }
           }
       i++;
       }
       
    /* String lesen */
    if (argc <= i)
       usage ();
    pattern = argv[i++];
    
    /* Dateimuster lesen */
    k = 0;
    while ((k < MAX_FILES) && (argc > i))
          files[k++] = argv[i++];

    do_grep ();
    
    if (dflag)
       {
       message ("hit Return to continue...");
       getch();
       }
       
    if (mlines)
       return 0;
    else
       return 1;
    }
         
/*======================= Hauptprogramm =========================*/

/* eigene Verarbeitung Kommandozeile, wegen " " und > */

int main ()
    {
    extern BASPAG *_BasPag;               /* Zeiger auf eigene Basepage */
    int argc, cmdlen;
    static char *argv[MAX_ARGS+1];
    char first;
    char *cmdline, *p, *a;
    static char cmd[128];
    static char rmode[] = "w";
    
    cmdline = _BasPag->p_cmdlin;          /* Zeiger auf Kommandozeile */
    cmdlen = (int)*cmdline;               /* LÑnge Kommandozeile      */
    strncpy(cmd,&cmdline[1],cmdlen);
    cmd[cmdlen] = '\0';

    argc = 1;
    argv[0] = myname;
     
    p = cmd;

    while ((argc <= MAX_ARGS) && (*p))
          {                    
          while ((*p) && (*p == ' '))
                p++;
          if (!*p)
             break;
          a = p;
          first = *p;
          switch (first)
                 {
                 case '\'' :
                 case '\"' :
                       a++;
                       while (*++p != first)
                             if (!*p)
                                error(3,"in commandline");
                       *p++ = '\0';
                       argv[argc++] = a;
                       break;
                 case '>'  :
                       if (*(++p) == '>')
                          {
                          rmode[0] = 'a';
                          p++;
                          }
                       while ((*p) && (*p == ' '))
                             p++;
                       if (!*p)
                          error(2,"?");
                       a = p;
                       while ((*p) && (*p != ' '))
                             p++;
                       if (*p == ' ')
                          *p++ = '\0';
                       redirect (a,rmode);
                       break;
                 default   :
                       while ((*p) && (*p != ' '))
                             p++;
                       if (*p == ' ')
                          *p++ = '\0';
                       argv[argc++] = a;
                }
          
          }

    return do_main(argc,argv);
    }

