/* LOAD_SND.C
 *
 * Routinen zum Laden diverser Sampleformate:
 * HSN, AVR, SMP, SND, IFF, WAV, VOC und Unbekannte
 *
 * Erstellt mit Pure C
 *
 * (c)Mai 1993 by Richard Kurz, Vogelherdbogen 62, 88069 Tettnang
 *
 * Fido 2:241/7232.5
 * Maus @ UN
 * Compuserve 100025,2263
 *
 * Vertrieb/Weitergabe nur durch das TOS-Magazin
 */

#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "load_snd.h"

#define E_MEM       -1
#define E_8BIT      -2
#define E_NOPEN     -4
#define E_UNKNOWN   -5

static char puffer[512];

static int load_hsn(int fp, SOUNDINFO *sin)
{
    HSN_NEW s;
    
    Fread(fp,sizeof(s),&s);
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(s.laenge);
    if(sin->anfang==NULL) return(E_MEM);
    sin->laenge=s.laenge;
    sin->frequenz=s.frequenz;
    sin->stereo=s.stereo;
    sin->bitsps=s.bitsps;
    Fread(fp,s.laenge,sin->anfang);
    return(0);
}/* load_hsn */

static int load_hsn_alt(int fp, SOUNDINFO *sin)
{
    HSN_ALT s;

    Fread(fp,sizeof(s),&s);
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(s.laenge);
    if(sin->anfang==NULL) return(E_MEM);
    sin->laenge=s.laenge;
    sin->frequenz=s.frequenz;
    sin->stereo=s.stereo;
    sin->bitsps=s.bitsps;
    Fread(fp,s.laenge,sin->anfang);
    return(0);
}/* load_hsn_alt */

static int load_avr(int fp, SOUNDINFO *sin)
{
    long l;
    int sign;

    Fread(fp,0x80L,puffer);
                       
    l= *((long*) &puffer[26]);
    if(puffer[15]>8)
    {
        sin->bitsps=16;
        l*=2;
    }
    if(puffer[12])
    {
        sin->stereo=TRUE;
        l*=2;
    }
    else sin->stereo=FALSE;
    sign=puffer[17];
	
    sin->laenge=l;
    puffer[22]=0;
    sin->frequenz=(int)(*((long*) &puffer[22])/10);
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL) return(E_MEM);
    Fread(fp,l,sin->anfang);
    if(!sign) change_vorz(sin);
    return(0);
} /* load_avr */

static int load_smp(int fp, SOUNDINFO *sin)
{
    long l;

    Fread(fp,8L,puffer);                   
    l=(long)(*((int*)&puffer[4]) + *((int*)&puffer[6]));
    Fread(fp,l,&puffer[8]);
    if((int)puffer[16]!=8)  return(E_8BIT);
    sin->laenge=l= *((long*) &puffer[8]);
    sin->stereo=(int)puffer[23]-1;
    sin->frequenz=(int)(*((long*) &puffer[18])/10L);

    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL)return(E_MEM);
    Fread(fp,l,sin->anfang);
    change_vorz(sin);
    return(0);
} /* load_smp */

static int load_snd(int fp, SOUNDINFO *sin)
{
    long l;

    l=Fseek(0,fp,2)-10;
    Fseek(0,fp,0);
    Fread(fp,10L,puffer);                   

    sin->laenge=l;
    if(puffer[9]&0x80)
    {
        sin->stereo=FALSE;
        puffer[9]&=~0x80;
    }
    else
    {
        sin->stereo=TRUE;
    }
    switch(puffer[9])
    {
        case 0: sin->frequenz=625; break;
        case 1: sin->frequenz=1250; break;
        case 2: sin->frequenz=2500; break;
        case 3: sin->frequenz=5000; break;
        default: sin->frequenz=1250; break;
    }
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL)return(E_MEM);
    Fread(fp,l,sin->anfang);
    return(0);
} /* load_snd */

static int load_iff(int fp, SOUNDINFO *sin)
{
    long l,i,j;

    Fseek(0,fp,0);
    Fread(fp,48L,puffer);                   

    sin->frequenz=(*(int*)&puffer[32])/10;
    if(*((long*)&puffer[40])!='BODY')
    {
        l=(*(long*)&puffer[44]);l+=l%2;
        for(i=0;i<10;i++)
        {
            if(l>510) return(E_UNKNOWN);
            Fread(fp,l+8L,puffer);                   
            if(*((long*)&puffer[l])=='BODY')
            {
                j=l+4;
                break;
            }
            l=(*(long*)&puffer[l+4]);l+=l%2;
        }
    }
    else j=44;
    sin->laenge=l=(*(long*)&puffer[j]);
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL)return(E_MEM);
    Fread(fp,l,sin->anfang);
    return(0);
} /* load_iff */

static int load_blob(int fp, SOUNDINFO *sin)
{
    long l;

    l=Fseek(0,fp,2);
    Fseek(0,fp,0);
    sin->laenge=l;
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL) return(E_MEM);
    Fread(fp,l,sin->anfang);
    return(0);
} /* load_blob */

/* Konvertierungsroutinen --> Intel nach Motorola */

static long l_i2m(char *s)
/* Intel LONG nach Motorola LONG */
{
    char p[4];
    
    p[0]=s[3];
    p[1]=s[2];
    p[2]=s[1];
    p[3]=s[0];
    
    return(*((long*)p));
}/* l_i2m */

static long l3_i2m(char *s)
/* Intel 3Byte-Zahl nach Motorola LONG */
{
    char p[4];
    
    p[0]=0;
    p[1]=s[2];
    p[2]=s[1];
    p[3]=s[0];
    
    return(*((long*)p));
}/* l3_i2m */

static int w_i2m(char *s)
/* Intel WORD nach Motorola WORD */
{
    char p[2];
    
    p[0]=s[1];
    p[1]=s[0];
    
    return(*((int*)p));
}/* w_i2m */

static int load_wav(int fp, SOUNDINFO *sin)
{
    long l;

    l=Fseek(0,fp,2)-48;
    Fseek(0,fp,0);
    Fread(fp,44L,puffer);                   

    if(puffer[34]>8)
    {
        sin->bitsps=16;
    }
    sin->laenge=l;
    sin->frequenz=(int)l_i2m(&puffer[24])/10;
    
    sin->stereo=puffer[22]-1;
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL)return(E_MEM);
    Fread(fp,l,sin->anfang);
    change_vorz(sin);
    return(0);
} /* load_wav */

static int load_voc(int fp, SOUNDINFO *sin)
{
    long l,ss,i,ofs;
    int ok,first=TRUE;
    char *z;
    
    Fseek(0,fp,0);

    Fread(fp,25L,puffer);                   
    ofs=w_i2m(&puffer[20]);
    if(puffer[22]>10 || puffer[23]!=01) return(E_UNKNOWN);

    Fseek(ofs,fp,0);
    l=0;
    for(ok=TRUE;ok;)
    {
        Fread(fp,1,puffer);
        switch(puffer[0])
        {
            case 0:
                ok=FALSE;break;
            case 1:
                Fread(fp,5,puffer);
                ss=l3_i2m(puffer)-2;
                if(first)
                {
                    sin->frequenz=(int)((-1000000L/((unsigned char)puffer[3]-256L))/10L);
                    first=FALSE;
                }
                l+=ss;
                if(Fseek(ss,fp,1)<0) return(E_UNKNOWN);
                break;
            case 2:
                Fread(fp,3,puffer);
                ss=l3_i2m(puffer)-2;
                l+=ss;
                if(Fseek(ss,fp,1)<0) return(E_UNKNOWN);
                break;
            case 3:
                if(Fread(fp,6,puffer)<0) return(E_UNKNOWN);
                ss=l3_i2m(puffer);
                l+=ss;
                break;
            default:
                return(E_UNKNOWN);
        }
    }
    
    sin->laenge=l;
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL)return(E_MEM);
    z=sin->anfang;
    
    Fseek(ofs,fp,0);
    for(ok=TRUE;ok;)
    {
        Fread(fp,1,puffer);
        switch(puffer[0])
        {
            case 0:
                ok=FALSE;break;
            case 1:
                Fread(fp,5,puffer);
                ss=l3_i2m(puffer)-2;
                if(Fread(fp,ss,z)<0) return(E_UNKNOWN);
                z+=ss;
                break;
            case 2:
                Fread(fp,3,puffer);
                ss=l3_i2m(puffer)-2;
                if(Fread(fp,ss,z)<0) return(E_UNKNOWN);
                z+=ss;
                break;
            case 3:
                if(Fread(fp,6,puffer)<0) return(E_UNKNOWN);
                ss=l3_i2m(puffer);
                for(i=0;i<ss;i++,z++) *z=0;
                break;
            default:
                return(E_UNKNOWN);
        }
    }
    change_vorz(sin);
    return(0);
} /* load_voc */


static int file_fehler(int f)
{
    int i;
    
    switch(f)
    {
        case E_8BIT:
            i=form_alert(1,"[2][|Das ist kein 8 Bit Sample!| |Trotzdem laden?][ Ja | Nein ]");
            break;
        case E_UNKNOWN:
            i=form_alert(1,"[2][|Unbekanntes Sample-Format!| |Trotzdem laden?][ Ja | Nein ]");
            break;
        case E_MEM:
            form_alert(1,"[3][|Nicht genug Speicher frei!][ Abbruch ]");
            return(FALSE);
        case E_NOPEN:
            form_alert(1,"[3][|Datei konnte nicht|ge”ffnet werden!][ Abbruch ]");
            return(FALSE);
        default: 
            form_alert(1,"[3][|Allgemeiner Fehler!][ Abbruch ]");
            return(FALSE);
    }
    if(i==1) return(TRUE);
    return(FALSE);
}/* file_fehler */


void change_vorz(SOUNDINFO *si)
/* Macht aus signed Samples unsigned und zurck */
{
    long i;
    char *p;
    int *wp;
    
    if(si->bitsps<=8)
    {   
        for(i=0,p=si->anfang;i<si->laenge;i++)
            p[i]^=0x80;
    }
    else
    {
        for(i=0,wp=(int *)si->anfang;i<(si->laenge/2);i++)
            wp[i]^=0x8000;
    }
        
}/* change_vorz */

void get_pfad(char *p)
/* L„dt den kompletten Zugriffs-Pfad.                           */
{
    static char tp[128];
    
    Dgetpath(tp,0);
    if(tp[strlen(tp)-1]!='\\') strcat(tp,"\\");
    strcpy(&p[2],tp);
    p[0]='A'+Dgetdrv(); p[1]=':';
} /* get_pfad */

int fselect(char *pfad,char *fname, char *ext, char *text)
/* Komfortion”se Datei-Auswahl.                                 */
{
    int ok,knopf;
    char *s;
    
    s=strrchr(pfad,'\\');
    if(s!=NULL) strcpy(++s,"*.");
    else strcpy(pfad,"*.");
    strcat(pfad,ext);

    if((Sversion()>>8)<=20) ok=fsel_input(pfad,fname,&knopf);
    else ok=fsel_exinput(pfad,fname,&knopf,text);

    if(!ok || !knopf)
    {
        s=strrchr(pfad,'\\');
        if(s!=NULL) s[1]=0;
        else pfad[0]=0;
        return(FALSE);
    }
    
    s=strrchr(pfad,'\\');
    if(s != NULL) strcpy(++s,fname);
    else strcpy(pfad,fname);
    return(TRUE);
}/* fselect */

int load_sound(SOUNDINFO *sin, char *path)
/* L„dt ein Sample und gibt bei Erfolg eine positive Nummer zurck, */
/* sonst FALSE. Die Daten des Samples werden in 'sin' eingetragen.  */
/* Wird in 'path' NULL bergeben, kommt die File-Select-Box zum     */
/* Einsatz.                                                         */
{
    static char sal_pfad[256];
    static char sal_name[20];
    int fp,typ,re;
    char *s;

    if(path)
    {   
        fp=Fopen(path,0);
        if(fp<0)
        {
            file_fehler(E_NOPEN);
            return(FALSE);                     
        }
        strcpy(sal_pfad,path);
        s=strrchr(path,'\\');
        if(s) strcpy(sal_name,++s);
        else
        {
            s=strrchr(path,':');
            if(s) strcpy(sal_name,++s);
            else strcpy(sal_name,path);
        }
    }
    else
    {
        if(!sal_pfad[0]) get_pfad(sal_pfad);
        if(!fselect(sal_pfad,sal_name,"*","Sample laden"))
            return(E_MEM);
        fp=Fopen(sal_pfad,0);
        if(fp<0)
        {
            file_fehler(E_NOPEN);
            return(FALSE);                     
        }
    }
    
    memset(puffer,0,128);
    Fread(fp,128L,puffer);
    Fseek(0,fp,0);

    if(!strncmp(puffer,"HSND1.0",7))            typ=1;  /* HSN */
    else if(!strncmp(puffer,"HSND1.1",7))       typ=2;  /* HSN */
    else if(*((long*)puffer)=='2BIT')           typ=3;  /* AVR */
    else if(*((long*)puffer)==0x7E817E81L)      typ=4;  /* SMP */
    else if(*((long*)puffer)=='STE.')           typ=5;  /* SND */
    else if((*((long*)puffer)=='FORM')&&
            (*((long*)&puffer[8])=='8SVX')&&
            (*((long*)&puffer[12])=='VHDR'))    typ=6;  /* IFF */
    else if((*((long*)puffer)=='RIFF')&&
            (*((long*)&puffer[8])=='WAVE')&&
            (*((long*)&puffer[12])=='fmt '))    typ=7;  /* WAV */
    else if(!strncmp(puffer,
            "Creative Voice File\032",19))      typ=8;  /* VOC */
    else                                        typ=99; /* ??? */
        
    sin->frequenz=1250;
    sin->stereo=FALSE;
    sin->bitsps=8;

    switch(typ)
    {
        case 1: re=load_hsn_alt(fp,sin); break;
        case 2: re=load_hsn(fp,sin); break;
        case 3: re=load_avr(fp,sin); break;
        case 4: re=load_smp(fp,sin); break;
        case 5: re=load_snd(fp,sin); break;
        case 6: re=load_iff(fp,sin); break;
        case 7: re=load_wav(fp,sin); break;
        case 8: re=load_voc(fp,sin); break;
        default: re=E_UNKNOWN; break;
    }

    if(re)
    {
        if(file_fehler(re))
        {
            Fseek(0,fp,0);
            re=load_blob(fp,sin);
            if(re)
            {
                Fclose(fp);
                file_fehler(re);
                return(FALSE);
            }
        }
        else
        {
            Fclose(fp);
            return(FALSE);
        }
    }

    Fclose(fp);
    strcpy(sin->name,sal_name);

    if(sin->frequenz>6000||sin->frequenz<=0) sin->frequenz=1250;
    else if(sin->frequenz>623&&sin->frequenz<627) sin->frequenz=625;
    else if(sin->frequenz>817&&sin->frequenz<821) sin->frequenz=819;
    else if(sin->frequenz>981&&sin->frequenz<985) sin->frequenz=983;
    else if(sin->frequenz>1227&&sin->frequenz<1231) sin->frequenz=1229;
    else if(sin->frequenz>1248&&sin->frequenz<1252) sin->frequenz=1250;
    else if(sin->frequenz>1692&&sin->frequenz<1696) sin->frequenz=1694;
    else if(sin->frequenz>2075&&sin->frequenz<2079) sin->frequenz=2077;
    else if(sin->frequenz>2456&&sin->frequenz<2460) sin->frequenz=2458;
    else if(sin->frequenz>2498&&sin->frequenz<2502) sin->frequenz=2500;
    else if(sin->frequenz>3386&&sin->frequenz<3390) sin->frequenz=3388;
    else if(sin->frequenz>4915&&sin->frequenz<4919) sin->frequenz=4917;
    else if(sin->frequenz>4998&&sin->frequenz<5002) sin->frequenz=5000;

    return(typ);
}/* load_sound */
