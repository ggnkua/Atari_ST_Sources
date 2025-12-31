/********************************************************************
 *
 *  xfiles.c		gebiet : xcfile		projekt : xcarpet
 *-------------------------------------------------------------------
 *  fopen_wr (name)	datei zum shcreiben îffnen incl. rÅckfrage
 *  file_select (path, name)	dateiauswahl
 *  save_3d(fname)			ablegen auf Disk in DEGAS/DOODLE/STAD
 *
 *******************************************************************/
 
 /*   3. 6.88  stock  */

#include "..\carpet.h"
#include <portab.h>
#include <stdio.h>
#if COMPILER==MEGAMAX
	#include <obdefs.h>
	#include <gemdefs.h>
#endif
#if COMPILER==TURBOC
	#include <stdlib.h>
	#include <string.h>
	#include <vdi.h>
	#include <aes.h>
	#include "..\xfiles.h"
#endif


/* from MEMORY */
extern double *row_vector();
#if COMPILER==TURBOC
	#include "..\memory.h"
#endif


/* from INOUT */
extern int xlines,ylines;
#if COMPILER==TURBOC
	#include "..\inout.h"
#endif 


#if COMPILER==TURBOC
	#include "..\initexit.h"
#endif 


int file_select (path, name)
  char *path, *name;
{
  int ok, button, len;
  char datei [15];
  
  datei [0] = 0;
  ok = fsel_input (path, datei, &button)  &&  button;
  if (ok)
  {
    strcpy (name, path);
    len = strlen (name);
    while (name[--len] != '\\' && len);	/* wildcard trennen	*/
    strcpy (&name[len+1], datei);
  }
  return (ok);
}

FILE *fopen_wr (name)
  char *name;
{
  FILE *file;
  char text[140];
  static char *type[]= { "a","w" };
  
  int  oeffnen;
  
  if ((file=fopen(name,"r")) != NULL) { /* datei vorhanden ?	*/
    fclose(file);
    
    strcpy(text,"[2][    Vorhandene Datei !!  | |    >");
    strcat(text,name);
    strcat(text,"<| |  ][ Abbruch | Anhang |   Neu   ]");
    
    oeffnen=-1 + form_alert (2,text);
  }
  else
    oeffnen=2;
    
  if (oeffnen)			/* 	datei îffnen		*/
    file = fopen (name,type[oeffnen-1]);
  else
    file = NULL;
  
  return (file) ; 
}

/* Hier noch Funktionen zum SAVEN vom File */

static char *convasm(
#if COMPILER==TURBOC
							char *s, int format)
#else
							s,format)
char *s;
int format;
#endif
{
int counter=0;
static char s2[120]; /* nîtig, damit man static Strings nicht Ñndert */
              /* in ihnen steht nÑmlich default fÅr Digital RSC */
register char *s1=s;
register char *s3=s2;

while(*s1)
   *(s3++)=*(s1++);
*s3=*s1; /* NULL-BYTE */

if (s2[0]!='*' && format==1) /* converten to SEKA Format */
   while (s2[counter]!='\0')
      {
      if (s2[counter]=='.' && s2[counter+1]=='D' && s2[counter+2]=='C')
         s2[counter]=' ';
      if (s2[counter]=='*')
         s2[counter]=';'; /* Kommentar */   
      counter++;
      }
return s2;
}         
      
#define convert(a)    convasm(a,format)
#define TESTF			FALSE

void save_3d(fname) /* ablegen des 3D Arrays als STAD File */
char *fname;
{ /* fname ist Pointer auf den Filename */
char *convasm();
#if COMPILER==TURBOC
	char *convasm(char *,int);
#endif

FILE *fsave;
int  counter;
register int x_run,y_run;
register double *dp;
int kantenfeld[5];
static char question[]=
    "[2][In welchem Format sollte das|Assembler File abgelegt werden ?][SEKA|DIGITAL]";
int format;
#if COMPILER==TURBOC
	static char *filebegin[ ]= {
#else
	static char filebegin[][]= {
#endif 
"************************************************************************",
"* 3D-Objekt im STAD V1.0 Format, muss zuerst mit dem DRC Assembler be~ *",
"*                          handelt werden.                             *",
"* hergestellt vom CARPET DESIGNER, einem Programm von Tony Przygienda, *",
"*            erhÑltlich als Public Domain bei ST-Zeitschrift.          *",
"* Greetings to ST Freaks all over the WORLD, included all Hackers,Cra~ *",
"* ckers & BIT Fooders. Special Greetings to SWISS+MADE, GMC, SAM, RAM~ *",
"* Freak & all others. GOD SAVE TRAMIEL !!!                             *",
"************************************************************************",
"objtab:",
".DC.L obj1fin-objtab",
".DC.L 0,0,0,0,0,0,0,0,0",
".DC.L 0,0,0,0,0,0,0,0,0,0",
".DC.L 0,0,0,0,0,0,0,0,0,0",
".DC.L 0,0,0,0,0,0,0,0,0,0",
".DC.L 0,0,0,0,0,0,0,0,0,0",
".DC.L 0,0,0,0,0,0,0,0,0,0",
".DC.L 0,0,0,0,0,0,0,0,0,0",
".DC.L 0,0,0,0,0,0,0,0,0,0",
".DC.L 0,0,0,0,0,0,0,0,0,0",   
".DC.L 0,0,0,0,0,0,0,0,0,0", 
".DC.L $FFFF8FB2                * STAD Erkennung",
".DC.B '3D'                     * Drahtgitter",
".DC.W 0                        * Ecken der Rotationskîrper",
".DC.W 319,209                  * Mittelpunkt",
".DC.W 100,600,80               * Schaupunkt",
".DC.W 0,0,0                    * Drehwinkel",
".DC.W 256                      * Skalierungsfaktor",
".DC.L obj1ecken-objtab         * Eckenoffset",
".DC.L obj1kanten-objtab        * Kantenoffset",
".DC.L obj1flaechen-objtab      * FlÑchenoffset (fakultativ)",
".DC.B 'CARPETDS'               * Name, immer 8 Bytes !",
".DC.W 0                        * reserved",
"" };

#if TESTF
	printf("fname:%s\n",fname);
#endif
fsave=fopen(fname,"w");
if (fsave)
   {
#if TESTF
   printf("%lx\n",question);
#endif
   format=form_alert(0,question);
   graf_mouse(HOURGLASS,0x0L);

   counter=0;
   while (filebegin[counter][0]!='\0')
      {
      fputs(convert(filebegin[counter++]),fsave);
      fputc('\n',fsave);
      }
   fputs("obj1ecken:\n",fsave); 
   fprintf(fsave,convert(".DC.W %d  * Anzahl Ecken\n"),(xlines+1)*(ylines+1)); 

   for (x_run=1;x_run!=xlines+2; x_run++)
      {
      dp = row_vector (x_run-1);
      for (y_run=1; y_run!=ylines+2; y_run++)   
         {
         fprintf(fsave,convert(".DC.W %d,%d,%d\n"),
                       (int) *dp, (int) (*(dp+1)), (int) (*(dp+2)));
         dp+=3;
         }
      }
   fputs("obj1kanten:\n",fsave);
   fprintf(fsave,convert(".DC.W %d  * Anzahl Kanten\n"),2*xlines*(ylines+1));
   for (x_run=0;x_run!=xlines+1; x_run++)
      for (y_run=0; y_run!=ylines+1; y_run++)
         {
         if(y_run!=ylines)
            fprintf(fsave,convert(".DC.W %d,%d\n"),x_run*(ylines+1)+y_run,
                                   x_run*(ylines+1)+y_run+1); /* lÑngst */
         if(x_run!=xlines) /* quer */
            fprintf(fsave,convert(".DC.W %d,%d\n"),x_run*(ylines+1)+y_run,
                                   (x_run+1)*(ylines+1)+y_run);
         }
   fputs("obj1flaechen:\n",fsave);
   fprintf(fsave,convert(".DC.W %d  * Anzahl Flaechen\n"),xlines*ylines);
   for (x_run=0;x_run!=xlines; x_run++)
      for (y_run=0; y_run!=ylines; y_run++)
         {
         fputs(convert(".DC.W 4\n"),fsave);
         kantenfeld[0]=kantenfeld[4]=x_run*(ylines+1)+y_run;
         kantenfeld[1]=(x_run+1)*(ylines+1)+y_run;
         kantenfeld[2]=kantenfeld[1]+1;
         kantenfeld[3]=kantenfeld[0]+1;
         fputs(convert(".DC.W "),fsave);
         for (counter=0; counter<5; counter++)
             {
             fprintf(fsave,"%d",kantenfeld[counter]);
             fputc((counter!=4 ? ',':'\n'),fsave);
             } 
         }               
   fputs(convert("obj1fin:\n.DC.W 0\n"),fsave);
	fclose(fsave);
   }
}

void save_img(char *path)
/* speichert das aktuelle Bild als IMG! ab ohne Komprimierung	*/
/* Aufbau aus dem Supergraphikbuch rausgenommen						*/
{
/* Header  aus Words im INTEL! Format */
static WORD  header [8]    = { 01,     /* Versionnummer 	*/
										 0x8,	 	/* Words im Header 	*/ 
										 00,     /* Bits/Punkt zum ErgÑnzen */
										 0x2,		/* LÑnge im Pattern Run	*/
										 0x174,		/* etwa 1 Mill Breite 	*/
										 0x174,		/* und Hîhe */
										 00,		/* Punkte pro Zeile */
										 00 };	/* Zeilen pro Bild */
static BYTE linehead  [4]  = { 0,0,0xFF, 1 }; /* Linestart */
static BYTE bit_string[2]  = {0x80, 0}; 

int fsave;
register int counter;
MFDB stand;
register BYTE *tmp,*tmp2,*tmp3;
register tmpi=source.fd_nplanes;

							
/* header[2]=(source.fd_nplanes); */
header[2]=0;
while (tmpi>0)
	{
	header[2]++;  tmpi/=2;
	}

header[6]=(source.fd_w); 
header[7]=(source.fd_h);

bit_string[1]=source.fd_wdwidth*2 /* ? */ * source.fd_nplanes;

fsave=creat(path,0xFFFF);
if (fsave!=-1)
	{
	write(fsave,header,16);
	/* ich hoffe, die idiotische, nirgends!!! dokumentierte Standard-	*/
	/* rasterform entspricht dem IMG-File										*/
	stand=source;
	stand.fd_addr=malloc(screenbytes+3);
	if (stand.fd_addr!=NIL)
		{
		tmp=stand.fd_addr;
		vr_trnfm(handle,&target,&stand);
		linehead[3]=1; 
		for(counter=0; counter<source.fd_h; counter++)
			if (counter<source.fd_h-1 && linehead[3]<100)  /* d.h. nicht die letzte */
				{	
				tmp2=tmp;
				tmp3=tmp+source.fd_nplanes*source.fd_wdwidth*2; /* nÑchste Zeile */
				while ((tmp2<tmp+source.fd_nplanes*source.fd_wdwidth*2)
						 && (*tmp2==*tmp3))
					{
					tmp2++;
					tmp3++;
					}
				if (tmp2==tmp+source.fd_nplanes*source.fd_wdwidth*2)
					/* d.h. Zeilen gleich!	*/
					{
					tmp=tmp2;
					linehead[3]++;
					}
				else
					{	 
					write(fsave,linehead,4);
					linehead[3]=1;				
					write(fsave,bit_string,2);
					write(fsave,tmp,stand.fd_wdwidth*2*source.fd_nplanes);
					tmp+=stand.fd_wdwidth*2*source.fd_nplanes;
					}
				}
			else
				{
				write(fsave,linehead,4);
				linehead[3]=1;				
				write(fsave,bit_string,2);
				write(fsave,tmp,stand.fd_wdwidth*2*source.fd_nplanes);
				tmp+=stand.fd_wdwidth*2*source.fd_nplanes;
				}
		free(stand.fd_addr);
		}	
	close(fsave);
	}															 
}						 

/***********************************************************/