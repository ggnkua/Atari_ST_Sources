/*  GEMSOUND.C
 *  Main-Teil
 *
 *  aus: GEM Sound
 *       TOS Magazin
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *  Fido 2:241/7232
 *
 *  Erstellt mit Pure C
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <screen.h>
#include "sounds.h"

/* Prototypen aus dem Assemblerteil             */
long set_gem(void);
long set_click(void);
void start_sound(char *a,char *e,int reset);

/* Prototypen fr die Cookieverwaltung          */
int get_cookie(unsigned long cookie,unsigned long *value);
int make_cookie(unsigned long cookie,unsigned long value);

/* globale Variablen                            */
C_SOUNDS si;        /* Struktur fr den Austausch mit dem CPX-Modul */
int error=FALSE;    /* Fehler-Flag */

void play_it(SINF *sound,int super)
/* Spielt einen Sound */
{
    long stack;

    if(super) stack=Super(0L);
    start_sound((char *)(sound->anfang),(char *)((char *)(sound->anfang)+sound->laenge),si.r_flag);
    if(super)Super((void *)stack);
    return;
} /* play_it */

int do_it(int d)
/* sucht den Sound zu einem AES-Aufruf und spielt ihn ab */
{
    int i;
    
    if(si.ruhe) return(TRUE);
    
    for(i=0;i<MAX_SAMP;i++)
    {
        if(si.gem_inf[i].nr==d)
        {
            if(si.gem_inf[i].an)
            {
                play_it(&si.sounds[si.gem_inf[i].sound],FALSE);
                return(FALSE);
            }
            break;
        }
    }
    return(TRUE);
} /* do_it */

int load_smp(char *pfad, int nr)
/* Ein Sample wird geladen  */
{
    long len;
    int fp;
    static char puffer[350];

    fp = Fopen(pfad,0);
    if(fp<0) return(-1);                     
    Fread(fp,4L,puffer);                   
	if(*((long*)puffer)!=0x7E817E81L)
	{
        Fclose(fp);
        return(-2);
	}
    Fread(fp,4L,&puffer[4]);
    len=(long)(*((int*)&puffer[4]) + *((int*)&puffer[6]));
    Fread(fp,len,&puffer[8]);
    si.sounds[nr].laenge=len= *((long*) &puffer[8]);
    si.sounds[nr].anfang=(long *)malloc(len);
    if(si.sounds[nr].anfang==NULL)
    {
        Fclose(fp);
        return(-3);
    }
    Fread(fp,len,si.sounds[nr].anfang);
    Fclose(fp);
    return(FALSE);
} /* load_smp */

int main(void)
/* Nu geht's awer los   */
{
    DTA dt,*dto;
    int i,g;
    unsigned long cok;
    char  s[255],*c;
    C_SOUNDS *nsi;
    
    Clear_home();
    Rev_on();
    puts("      GEM Sound V1.0     ");
    puts("                         ");
    puts(" (c)1992 by Richard Kurz ");
    puts(" Vogelherdbogen 62       ");
    puts(" 7992 Tettnang           ");
    puts(" Fido 2:241/7232         ");
    puts("                         ");
    puts(" Fr's TOS Magazin!!!!   ");
    Rev_off();
    puts("");
    
    /* Test auf DMA-SOUND */    
    if(!get_cookie('_SND',&cok) || !(cok&2))
    {
        puts("FEHLER:");
        puts("GEM Sound l„uft leider nur mit DMA-Sound (STE/TT)");
        puts("\n<RETURN>");
        getchar();
        return(1);
    }
    /* Sind wir schon installiert? */
    if(get_cookie('GSND',(unsigned long*)(&nsi)))
    {
        puts("FEHLER:");
        puts("Bin schon da");
        puts("\n<RETURN>");
        getchar();
        return(1);
    }
    
    /* Die Samples werden geladen */
    dto=Fgetdta();
    Fsetdta(&dt);
    g=Fsfirst("samples\\*.smp",FA_READONLY|FA_ARCHIVE);
    for(i=0;!g && i<MAX_SAMP;i++)
    {
        strcpy(s,"samples\\");
        strcat(s,dt.d_fname);
        strcpy(si.sounds[i].name,dt.d_fname);
        c=strchr(si.sounds[i].name,'.');
        if(c) *c=0;
     	puts(s);
       	error=load_smp(s,i);
        if(error) break;
        g=Fsnext();
    }
    if(!error) si.max_sound=i;
    else si.max_sound=0;
    Fsetdta(dto);

    /* Wir richten uns ein */
    if(!error && si.max_sound<=0) error=-4;
    if(error)
    {
        puts("FEHLER:");
        switch (error)
        {
            case -1: puts("Datei nicht gefunden"); break;
            case -2: puts("Kein SampleWizard-Format"); break;
            case -3: puts("Nicht genug Speicher frei"); break;
            default: puts("Samples konnten nicht geladen werden"); break;
        }
        puts("\n<RETURN>");
        getchar();
        return(1);
    }
    si.fix=FALSE;
    si.play=play_it;
    si.set_vec=set_gem;
    if(make_cookie('GSND',(unsigned long)&si))
    {
        Supexec(set_click);
        Ptermres(_PgmSize,0);
    }
    puts("FEHLER:");
    puts("Das Cookie GSND konnte nicht angelegt werden");
    puts("\n<RETURN>");
    getchar();
    return(1);
} /* main */
