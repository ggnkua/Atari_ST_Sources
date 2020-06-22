/*  OP_FILE.C
 *
 *  aus: Wir basteln uns ein CPX
 *       CPX-Kurs Teil 2
 *       TOS Magazin
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *
 *  Erstellt mit Pure C
 */
 
#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <portab.h>
#include "cpx.h"
#include "link_glo.h"

/* Nur zur Beruhigung von Pure C.    */
struct foobar
{
    WORD    dummy;
    WORD    *image;
};

/* Globale Variablen zur Dateipfad-Verwaltung.					*/
static char i_pfad[128]="x:\\";
static char h_pfad[128]="x:\\";
static char cp_pfad[128]="x:\\";
static char cx_pfad[128]="x:\\";
static char i_name[14]="";
static char h_name[14]="";
static char cp_name[14]="";
static char cx_name[14]="";

/* errno steckt in cpxstart.s und wird von den Pure C Datei-	*/
/* Funktionen verwendet.										*/
extern int errno;

static void do_fehler(FILE *fp,char *fn)
/* Fehlerbehandlung bei Dateifehlern.							*/
{
	static char s[128];
	
	if(fp!=NULL)
	{
		sprintf(s,"[3][Fehler beim lesen/schreiben|in %s][ OK ]",fn);
		fclose(fp);
	}
	else sprintf(s,"[3] Datei %s|konnte nicht ge”ffnet werden][ OK ]",fn);
	form_alert(1,s);
} /* do_fehler */

static int fselect(char *pfad,char *fname,char *ext, char *text)
/* Komfortion”se Datei-Auswahl.									*/
{
	int ok,knopf;
	char *s;
	
	s=strrchr(pfad,'\\');
	if(s!=NULL)
		strcpy(++s,"*.");
	else
		strcpy(pfad,"*.");
	strcat(pfad,ext);

	if((Sversion()>>8)<=20)	ok=fsel_input(pfad,fname,&knopf);
	else ok=fsel_exinput(pfad,fname,&knopf,text);

	if(!ok || !knopf)
	{
		s=strrchr(pfad,'\\');
			if(s != NULL)
				pfad[s+1]=0;
			else
				pfad[0]=0;
		return(FALSE);
	}
	
	s=strrchr(pfad,'\\');
	if(s != NULL)
		strcpy(++s,fname);
	else
		strcpy(pfad,fname);
	return(TRUE);
}/* fselect */

static void get_pfad(char *p)
/* Verwaltet die Zugriffs-Pfade.								*/
{
	static char tp[128];
	
	if(i_pfad[0]!='x') strcpy(p,i_pfad);
	else if(h_pfad[0]!='x') strcpy(p,h_pfad);
	else if(cp_pfad[0]!='x') strcpy(p,cp_pfad);
	else if(cx_pfad[0]!='x') strcpy(p,cx_pfad);
	else
	{
		Dgetpath(tp,0);
		if(tp[strlen(tp)-1]!='\\') strcat(tp,"\\");
		strcpy(&p[2],tp);
		p[0]='A'+Dgetdrv(); p[1]=':';
	}
} /* get_pfad */

UWORD *read_icon(void)
/* L„dt ein Icon.												*/
{
	static UWORD icn[48];
	static char z[81];
	char *e;
	int i,j,ip;
	FILE *fp;

	if(i_pfad[0]=='x') get_pfad(i_pfad);

	i=fselect(i_pfad,i_name,"ICN","Quellcode lesen");
	if(!i) return(NULL);
	
	fp=fopen(i_pfad,"r");
	if(fp==NULL) goto fehler;

	for(i=0;i<5;i++)
		if(fgets(z,80,fp)==NULL) goto fehler;

	for(ip=0,i=0;i<12;i++)
	{
		if(fgets(z,80,fp)==NULL) goto fehler;
		if(i==0) z[0]=' ';
		icn[ip]=(UWORD)strtoul(z,&e,0);
		ip++;
		e++;
		for(j=0;j<3;j++,ip++)
		{
			icn[ip]=(UWORD)strtoul(e,&e,0);
			e++;
		}
	}
	fclose(fp);
	return(icn);

fehler:
	do_fehler(fp,i_name);
	return(NULL);
} /* read_icon */

void write_icon(UWORD *icn)
/* Icon sichern.												*/
{
	static char z[81];
	int i,ip;
	FILE *fp;

	if(i_pfad[0]=='x') get_pfad(i_pfad);

	i=fselect(i_pfad,i_name,"ICN","Quellcode schreiben");
	if(!i) return;
	
	fp=fopen(i_pfad,"w");
	if(fp==NULL) goto fehler;

	if(fputs("/* GEM Icon Definition: */\n",fp)==EOF) goto fehler;
	if(fputs("#define ICON_W 0x0020\n",fp)==EOF) goto fehler;
	if(fputs("#define ICON_H 0x0018\n",fp)==EOF) goto fehler;
	if(fputs("#define DATASIZE 0x0030\n",fp)==EOF) goto fehler;
	if(fputs("UWORD icon[DATASIZE] =\n",fp)==EOF) goto fehler;
	for(i=0,ip=0;i<12;i++,ip+=4)
	{
		if(i==0)
			sprintf(z,"{ 0x%X, 0x%X, 0x%X, 0x%X,\n",icn[ip],icn[ip+1],icn[ip+2],icn[ip+3]);
		else if(i==11)
			sprintf(z,"  0x%X, 0x%X, 0x%X, 0x%X\n};\n",icn[ip],icn[ip+1],icn[ip+2],icn[ip+3]);
		else 
			sprintf(z,"  0x%X, 0x%X, 0x%X, 0x%X,\n",icn[ip],icn[ip+1],icn[ip+2],icn[ip+3]);
		if(fputs(z,fp)==EOF) goto fehler;
	}
	fclose(fp);
	return;

fehler:
	do_fehler(fp,i_name);
}/* write_icon */

int read_header(CPXHEAD *head, char *ext)
/* Header holen.												*/
{
	static CPXHEAD	h;
	long i;
	FILE *fp;

	if(ext[0]=='H')
	{
		if(h_pfad[0]=='x') get_pfad(h_pfad);
		i=fselect(h_pfad,h_name,ext,"Header lesen");
		if(!i) return(FALSE);
		fp=fopen(h_pfad,"rb");
	}
	else
	{
		if(cx_pfad[0]=='x') get_pfad(cx_pfad);
		i=fselect(cx_pfad,cx_name,ext,"Header lesen");
		if(!i) return(FALSE);
		fp=fopen(cx_pfad,"rb");
	}

	if(fp==NULL) goto fehler;
	if(fread(&h,1,sizeof(CPXHEAD),fp)!=sizeof(CPXHEAD)) goto fehler;
	fclose(fp);
	memcpy(head,&h,sizeof(CPXHEAD));
	return(TRUE);
fehler:	
	if(ext[0]=='H')	do_fehler(fp,h_name);
	else do_fehler(fp,cx_name);
	return(FALSE);
} /* read_header */

void write_header(CPXHEAD *h)
/* Header schreiben.											*/
{
	long i;
	FILE *fp;

	if(h_pfad[0]=='x') get_pfad(h_pfad);
	i=fselect(h_pfad,h_name,"HDR","Header schreiben");
	if(!i) return;
	fp=fopen(h_pfad,"wb");
	if(fp==NULL) goto fehler;
	if(fwrite(h,1,sizeof(CPXHEAD),fp)!=sizeof(CPXHEAD)) goto fehler;
	fclose(fp);
	return;
fehler:	
	do_fehler(fp,h_name);
} /* write_header */

void write_to_cpx(CPXHEAD *h)
/* Header in CPX-Modul schreiben.								*/
{
	long i;
	FILE *fp;

	if(cx_pfad[0]=='x') get_pfad(cx_pfad);
	i=fselect(cx_pfad,cx_name,"CPX","In CPX schreiben");
	if(!i) return;
	fp=fopen(cx_pfad,"rb+");
	if(fp==NULL) goto fehler;
	if(fwrite(h,1,sizeof(CPXHEAD),fp)!=sizeof(CPXHEAD)) goto fehler;
	fclose(fp);
	return;
fehler:	
	do_fehler(fp,cx_name);
} /* write_to_cpx */

void link_cpx(CPXHEAD *h)
/* Erstellt aus einem Header und einem *.CP ein CPX-Modul.		*/
{
	long i;
	FILE *cp_fp,*cx_fp;

	if(cx_pfad[0]=='x') get_pfad(cx_pfad);
	i=fselect(cx_pfad,cx_name,"CPX","Welches CPX soll's werden?");
	if(!i) return;
	if(cp_pfad[0]=='x') get_pfad(cp_pfad);
	i=fselect(cp_pfad,cp_name,"CP","Programmteil *.CP ”ffnen");
	if(!i) return;

	cx_fp=fopen(cx_pfad,"wb");
	if(cx_fp==NULL) goto xfehler;
	cp_fp=fopen(cp_pfad,"rb");
	if(cp_fp==NULL) goto fehler;

	setvbuf(cx_fp,NULL,_IOFBF,0x2800L);
	setvbuf(cp_fp,NULL,_IOFBF,0x2800L);
	if(fwrite(h,1,sizeof(CPXHEAD),cx_fp)!=sizeof(CPXHEAD)) goto xfehler;
	for(errno=FALSE;;)
    {
        i=getc(cp_fp);
        if(i==EOF) if(errno)goto fehler; else break;
        if(putc((int)i,cx_fp)==EOF) goto xfehler;
    }
	fclose(cx_fp);
	fclose(cp_fp);
	return;
fehler:	
	if(cx_fp) fclose(cx_fp);
	do_fehler(cx_fp,cp_name);
	return;
xfehler:
	if(cp_fp) fclose(cp_fp);
	do_fehler(cx_fp,cx_name);
	return;
} /* link_cpx */