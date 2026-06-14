
/**********************************************************
 * Drivemap (C)1988 by Stefan Becker / Atari ST / Turbo-C *
 **********************************************************
 * Programm erzeugt eine Karte eines Laufwerks mit Infor- *
 * mationen Åber die Lage von Directory, Fat und Dateien. *
 **********************************************************/

#include    <stdio.h>
#include    <tos.h>
#include    <ext.h>
#include    <ctype.h>
#include    <stdlib.h>

/****************
 * Definitionen *
 ****************/

#define     RETRIES     4   /* Wiederholungen bei Disk-Error */
#define     CR          13  /* Code d. Return-Zeichens       */
#define     NIL         ((struct DIR_TYPE*)0L)

/* Interne Codierung der "Karte": */

#define     FREE         1  /* Freier Cluster                    */
#define     BAD          2  /* Kaputter Cluster                  */
#define     DATA         3  /* Cluster gehîrt zu einer Datei     */
#define     STRANGE      4  /* Seltsamer Cluster!? (unbekannt)   */

#define     REV_ON       "\033p"    /* VT52: Cursor invers       */
#define     REV_OFF      "\033q"    /* VT52: Cursor normal       */

/*********************
 * Typendefinitionen *
 *********************/

typedef struct DIR_TYPE     /* Typ: Directory-Eintrag    */
    {
        unsigned char   fname[13];  /* 12 Zeichen Name           */
        unsigned char   time[9];    /* XX:XX:XX                  */
        unsigned char   date[11];   /* XX.XX.XXXX                */
        unsigned char   flags;      /* 1 Byte-Filetyp            */
        unsigned int    startcl;    /* Startcluster              */
        unsigned long   flength;    /* FilelÑnge                 */
    };

typedef struct MAP_TYPE
    {
        unsigned int file;   /* Nummer des Files in der Directory         */
        unsigned int trace;  /* Nr. des Clusters innnerhalb der Datei     */
        unsigned int last;   /* Flagge: Letzter Eintrag diese Files? 1=Ja */
        int          typ;    /* Sorte des Karteneintrags (Frei,Dir,...)   */
    };

/**********************
 * Globale Variablen: *
 **********************/

int     drive;      /* benutztes Laufwerk                   */
int     ssize;      /* Bytes/Sektor                         */
int     csize;      /* Sektoren/Cluster                     */
int     fstart;     /* Startsektor der FAT                  */
int     fsize;      /* Grîûe der FAT in Sektoren            */
int     dstart;     /* Startsektor des Haupt-Directory      */
int     dsize;      /* Directorygrîûe in Sektoren           */
int     fatbits;    /* Anzahl der Bits/Fateintrag (12|16)   */
int     startdta;   /* Start des Datenbereichs              */
int     maxfat;     /* Maximaler FAT-Eintrag!               */

char    *fat;       /* Zeiger auf eingelesene FAT             */
char    *dir;       /* Zeiger auf eingelesenes Root-Directory */

struct  MAP_TYPE    *map; /* Zeiger auf interne Karte.            */
int     fileno;     /* Nummer der aktuellen Datei im Directory    */

/*****************
 * Hauptprogramm *
 *****************/

main()
{
    void    docheck(int);
    int     code;
    int     getdrive(void),getmap(int),check(int),askyesno(char*);

    while((drive=getdrive())>=0)
    {
        if((code=getmap(drive))<0)
        {
            puts("Fehler beim Erstellen der Karte:");
            switch(code)
            {
                case -1 :   puts("Getbpb liefert NIL!???");
                            break;
                case -2 :   puts("FAT kann nicht gelesen werden!");
                            puts("Lesefehler oder zu wenig Speicher!");
                            break;
                case -3 :   puts("Directory kann nicht gelesen werden!");
                            puts("Lesefehler oder zu wenig Speicher!");
                            break;
                case -4 :   puts("Zu wenig Speicher um Directory zu lesen!");
                            break;
                case -5 :   puts("Zu wenig Speicher um 'Karte' zu erzeugen!");
                            break;
                case -6 :   puts("Falscher Subdirectory-Zeiger!");
                            break;
                default :   puts("Unbekannter Fehler!");
                            break;
            }
            continue;
        }
/*      if(askyesno("Soll noch ein Bad-Sector-Check durchgefÅhrt werden?"))
            docheck(drive); */
    }
    return 0;
}

/***************************************
 * Schreibe einen Eintrag in die Karte *
 ***************************************/

void writemap(unsigned int pos, struct MAP_TYPE w)
{
    struct  MAP_TYPE    *ptr=map;
    void                error(char*);

    if(pos>maxfat)
        error("Falscher Writemap-Aufruf!");
    ptr+=(unsigned long)pos;
    *ptr=w;
}

/************************************
 * Lese einen Eintrag aus der Karte *
 ************************************/

struct MAP_TYPE readmap(int pos)
{
    void                        error(char*);
    struct          MAP_TYPE    *ptr=map;

    if(pos>maxfat)
        error("Falscher Readmap-Aufruf!");
    ptr+=(long)pos;
    return *ptr;
}

/************************************************
 * Schreibe eine Frage und lese die Antwort ein *
 ************************************************/

int askyesno(char *s)
{
    char    c;

    printf("%s [J/N] ?",s);
    do
    {
        c=toupper(getch());
    }   while(c!='J' && c!='N');
    printf("%c\n",c);
    return (c=='J') ? 1 : 0;
}

/******************************************************
 * Wandle eine Intel-Integer in eine Motorola-Integer *
 ******************************************************/

unsigned int moto16(unsigned int n)
{
    return ((n<<8) | (n>>8));
}

/**********************************************
 * Wandle ein Intel-Long in ein Motorola-Long *
 **********************************************/

long moto32(long n)
{
    unsigned char   *ptr=(unsigned char*)&n,trick[4];

    trick[3]=*(ptr);    trick[2]=*(ptr+1);
    trick[1]=*(ptr+2);  trick[0]=*(ptr+3);
    return *(long*)&trick[0];
}

/******************************************
 * Lese einen Eintrag in einer 12 Bit-FAT *
 ******************************************/

int next12bit(int nr)
{
    int     odd,inh;
    char    trick[2];

    odd=nr&1;                   /* Offset gerade oder ungerade?           */
    nr+=(nr>>1);                /* nr*=1.5 (Offset in FAT berechnen)        */
    trick[0]=*(fat+(long)nr);trick[1]=*(fat+(long)nr+1);
    inh=moto16(*(unsigned int*)&trick[0]);
    return (odd) ? (((unsigned)inh)>>4) : (inh & 0xFFF); /* Richtige Maske*/
}

/******************************************
 * Lese einen Eintrag in einer 16 Bit-FAT *
 ******************************************/

int next16bit(int nr)
{
    nr<<=1; /* nr*=2 */
    return moto16(*(unsigned int*)(fat+(long)nr));
}

/***********************************
 * Lese einen Eintrag in einer FAT *
 ***********************************/

int next(int nr)
{
        return (fatbits==16) ? next16bit(nr) : next12bit(nr);
}

/************************************************
 * Verfolge die Spur (Clusterfolge) einer Datei *
 * und markiere sie in der Karte.               *
 ************************************************/

void trace(unsigned int start)
{
    unsigned int    count=0,ende;
    struct MAP_TYPE m;

    ende= (unsigned int)((fatbits==12) ? 0xFF7 : 0xFFF7);
    do
    {
        if(start>maxfat || start>=ende)
            break;
/*
        m=readmap(start);
        if(m.typ!=FREE)
            puts("\n!!!!! Datei verwendet belegten Cluster !!!!!\n");
*/
        m.file=fileno;
        m.trace=count++;
        m.typ=DATA;
        m.last=(next(start)>=ende);
        writemap(start,m);
        start=next(start);
    } while(start!=0 && start<=maxfat && start>0);
}

/******************************************************
 * Lese die Informationen eines Directoryeintrags und *
 * bringe Sie in eine les- und brauchbare Form.       *
 ******************************************************/

struct DIR_TYPE *getdir(unsigned char *adr)
{
    static   struct  DIR_TYPE   dir;
    char                        name[9],ext[4],z[20];
    unsigned int                i,x1,x2,x3;

    if(*adr==(char)0)
        return NIL;

    name[8]=(char)0;
    for(i=0;i<8;i++)            /* Filenamen auslesen: */
        name[i]=*(adr+(long)i);
    for(i=0;i<=7 && name[i]!=' ';i++);
    name[i]=(char)0;

    for(i=8;i<11;i++)
        ext[i-8]=*(adr+(long)i);
    ext[3]=(char)0;
    for(i=0;i<=2 && ext[i]!=' ';i++);
    ext[i]=(char)0;

    sprintf(z,"%s.%s",name,ext);
    for(i=0;z[i]!=(char)0 && i<14;i++);
    if(i>0 && z[i-1]=='.')
        z[i-1]=(char)0;
    sprintf(dir.fname,"%-12s",z);

    dir.flags=*(adr+(long)11);          /* Filetyp lesen        */
    i=moto16(*(unsigned int*)(adr+(long)22));   /* Zeit lesen           */
    x1=((i&31)<<1);                     /* Bit 0-4: Sekunden/2  */
    x2=((i>>5)&63);                     /* Bit 5-10: Minuten    */
    x3=(i>>11);                         /* Bit 11-15: Stunden   */
    sprintf(&dir.time[0],"%02d:%02d:%02d",x3,x2,x1);
    i=moto16(*(unsigned int*)(adr+(long)24));   /* Datum lesen */
    x1=i&31;                            /* Bit 0-4: Tag */
    x2=(i>>5)&15;                       /* Bit 5-8: Monat */
    x3=(i>>9)+1980;                     /* Bit 9-15: Jahr-1980 */
    sprintf(&dir.date[0],"%02d.%02d.%4d",x1,x2,x3);
    dir.startcl=moto16(*(unsigned int*)(adr+(long)26)); /* Startcluster lesen */
    dir.flength=moto32(*(unsigned long*)(adr+(long)28)); /* FilelÑnge */
    return &dir;                /* Gib berechneten Eintrag zurÅck! */
}

/******************************************************
 * Schreibe einen Directoryeintrag auf den Bildschirm *
 ******************************************************/

void printentry(struct DIR_TYPE *p,int level)
{
    int     i,flags,torec(int);

    if(fileno==1)
        puts("Format: Filename / LÑnge / Zeit / Datum / Startcl /Startsec\n");
    printf("%4d: ",fileno);
    for(i=0;i<level*3-1;i++)
        putchar('-');
    if(level>0)
        putchar('>');
    printf("%s %6ld %8s %10s %4d %4d ",
            p->fname,p->flength,p->time,p->date,p->startcl,torec(p->startcl));
    flags=p->flags;
    printf(REV_ON);
    if(flags&8)
        printf("Volume");
    else
    {
        trace(p->startcl);
        if(flags&16)
            printf("Dir");
        if(flags&1)
            printf("RO ");
        if(flags&6)
            printf("Hid ");
    }
    printf(REV_OFF);
    puts("");
    fileno++;
}

/**********************************************************
 * Berechne die Grîûe eines Directoryeintrags in Clustern *
 **********************************************************/

int size(int start)
{
    int i,ende,sum=0;

    ende=((fatbits==12) ? 0xFF7 : 0xFFF7);
    do
    {
        sum++;
        start=next(start);
    } while(start!=0 && start<ende && start<=maxfat);
    return sum;
}

/**********************************************
 * Lese einen Bereich von der Disk und reser- *
 * viere gleich den Speicher dafÅr.             *
 **********************************************/

char *rdalloc(int start,int len,long ramsize)
{
    char    *ptr;

    if((ptr=malloc(ramsize))==NULL)
        return NULL;
    if(Rwabs(0,ptr,len,start,drive)!=0)
    {
        free(ptr);
        return NULL;
    }
    return ptr;
}

/********************************************
 * Lese einen Bereich von der Disk in einen *
 * bereits reservierten Speicherbereich.    *
 ********************************************/

int readdisk(char *buf, int start, int len)
{
    int i,error;

    for(i=0;i<RETRIES+1 && (error=Rwabs(2,buf,len,start,drive))!=0;i++);
    return (error) ? -1 : 0;
}

/*****************************************
 * Bearbeitung eines Ordners (rekursiv!) *
 *****************************************/

int subdir(int start,int level)
{
    char            *sdbuf,*dptr;
    int             size(int),next(int),torec(int);
    int             sdirsize,i;
    struct DIR_TYPE *p,*getdir(char*);

    if(start>maxfat || start<0)
        return -2;
    sdirsize=size(start);
    if((sdbuf=(char*)malloc((long)sdirsize*(long)ssize*(long)csize))==NULL)
        return -1;
    for(i=0,dptr=sdbuf;
        i<sdirsize;
        i++,dptr+=(long)ssize*(long)csize,start=next(start))
            readdisk(dptr,torec(start),csize);
    for(    dptr=sdbuf;
            ((dptr-sdbuf) <= ((long)sdirsize*(long)ssize*(long)csize));
            dptr+=32 )
    {
        if((p=getdir(dptr))==NIL) /* Lese nÑchsten Directory-Eintrag... */
            break; /* Ende des Directorys => Abbruch! */
        if((unsigned int)(p->fname[0])==0xE5) /* gelîschte Datei? */
            continue;
        if(p->fname[0]=='.') /* . oder .. nicht weiterverfolgen! */
            continue;
        printentry(p,level); /* Eintrag rausschreiben... */
        if(!(p->flags&8) && (p->flags&16)) /* Subdirectory bearbeiten? */
            if(subdir(p->startcl,level+1)<0)
            {
                free(sdbuf);    /* Fehler! Erst Speicher freigeben,  */
                return -1;      /* dann mit Fehlermeldung abbrechen. */
            }
    }
    free(sdbuf); /* Speicher freigeben */
    return 0;    /* Alles O.K.         */
}

/***********************************
 * Bearbeitung des Hauptdirectorys *
 ***********************************/

int maindir(void)
{
    char            *dptr;
    int             error;
    struct DIR_TYPE *p,*getdir(char*);

    fileno=1; /* Directory mit File 1 beginnen lassen */
    printf("Die Files auf Drive %c:\n",drive+'A');
    for(dptr=dir;((dptr-dir) <= ((long)dsize*(long)ssize));dptr+=32)
    {
        if((p=getdir(dptr))==NIL) /* Lese nÑchsten Directory-Eintrag... */
        {
            puts("Ende des Directorys.");
            break; /* Ende des Directorys => Abbruch! */
        }
        if((unsigned int)(p->fname[0])==0xE5) /* gelîschte Datei? */
            continue;
        printentry(p,0); /* Eintrag rausschreiben... */
        if(!(p->flags&8) && (p->flags&16)) /* Subdirectory bearbeiten? */
            if((error=subdir(p->startcl,1))<0)
                return error;
    }
    puts("");
    return 0;
}

/********************************
 * Rechne Cluster in Records um *
 ********************************/

int torec(int clus)
{
    return startdta+(clus-2)*csize;
}

/************************************
 * Lese das gewÅnschte Laufwerk ein *
*************************************/

int getdrive(void)
{
    char    upcase(char),c;
    int     i,d;
    long    drivebits;

    drivebits=Drvmap();
    puts("\nBitte Laufwerk angeben:");
    printf("(Mîglich:");
    for(i=0;i<32;i++)
        if(drivebits & (1L<<i))
            putchar('A'+i);
    printf(" ,[RETURN]=Abbruch) =>");
    do
    {
        if( (c=toupper(getch()))==(char)CR)
            return -1;
        d=c-'A';
    } while(d<0 || d>31 || !(drivebits & (1L<<d)) );
    printf("%c\n",c);
    return d;
}

/**************************************************
 * Schreibe die Informationen aus "Getbpb" heraus *
 **************************************************/

void print_infos(BPB *b)
{
    printf("Informationen Åber Laufwerk %c:\n",drive+'A');
    printf("  %4d Bytes/Sektor\n",b->recsiz);
    printf("  %4d Sektoren/Cluster\n",b->clsiz);
    printf("  %4d Bytes/Cluster\n",b->clsizb);
    printf("  %4d Sektoren Directory\n",b->rdlen);
    printf("  %4d Sektoren FAT\n",b->fsiz);
    printf("  %4d Start von FAT2\n",b->fatrec);
    printf("  %4d Anfang des Datenbereichs\n",b->datrec);
    printf("  %4d Gesamtzahl der Cluster\n",b->numcl);
    printf(" $%04x Flaggen ",b->bflags);
    if(b->bflags)
        puts("(d.h. 16 Bit-FAT / Harddisk!)");
    else
        puts("(d.h. 12 Bit-FAT / normale Diskette/Ramdisk)");
    puts("Das waren die Infos aus dem Bios-Parameterblock.\n");
}

/*****************************************
 * Gebe die FAT unbearbeitet einfach aus *
 *****************************************/

void showfat(int numentry)
{
    int     i,count=0,free=0;

    printf("Die %2d-Bit FAT mit %d EintrÑgen:\n",
            fatbits,numentry);
    if(fatbits==12)
        for(i=0;i<numentry;i++)
        {
            if(count++%16==0)
                printf("\n%03X: ",i);
            printf("%03X %s",next(i),
                   (count%4==0) ? " " : "");
            if(i>1 && next(i)==0)
                free++;
        }
    else
        for(i=0;i<numentry;i++)
        {
            if(count++%12==0)
                printf("\n%04X: ",i);
            printf("%04X %s",next(i),
                (count%4==0) ? " " : "");
            if(i>1 && next(i)==0)
                free++;
        }
    printf("\n%d von insgesamt %d FAT-EintrÑgen %s frei.\n\n",
             free,numentry,(free==1) ? "ist" : "sind");
}

/***************************************************
 * Setze die globalen Variablen auf korrekte Werte *
 ***************************************************/

void setglobals(BPB *b)
{
     ssize=b->recsiz;
     csize=b->clsiz;
     fstart=1;
     fsize=b->fsiz;
     dstart=fsize*2+1;
     dsize=b->rdlen;
     startdta=b->datrec;
     maxfat=b->numcl;
     fatbits= (b->bflags) ? 16 : 12;
}

/********************************************************
 * Routine zum Reservieren und Initialisieren der Karte *
 ********************************************************/

int initmap(int entries)
{
    int                 i,bad;
    struct  MAP_TYPE    strange= { 0, 0, 0, STRANGE };
    struct  MAP_TYPE    proto=   { 0, 0, 0, FREE    };
    struct  MAP_TYPE    badcl=   { 0, 0, 0, BAD     };

    map=(struct MAP_TYPE*)malloc(
        (long)sizeof(struct MAP_TYPE)*(long)entries );
    if(map==(struct MAP_TYPE*)NULL)
        return -1;
    writemap(0,strange); /* Diese 2 EintrÑge sind ja undefiniert! */
    writemap(1,strange);
    bad= ((fatbits==12) ? 0xFF7 : 0xFFF7);
    for(i=2;i<entries;i++)
    {
        if(next(i)==bad)
        {
            writemap(i,badcl);
            continue;
        }
/*
        if(!(next(i)>bad) && (next(i)>maxfat))
        {
            writemap(i,strange);
            continue;
        }
*/
        writemap(i,proto);
    }
    return 0;
}

/**********************************
 * Routine zum Ausgeben der Karte *
 **********************************/

void printmap(void)
{
    int             i,count=0;
    struct MAP_TYPE m;

    puts("Die Volume-'Karte' (nach FAT-Clustern):");
    puts("(Umrechnung von FAT-Clustern nach Sektornr: Sei Cl der FAT-Cluster");
    printf("und Sec der zu berechnende Sektor. Formel: Sec=%d+(Cl-2)*%d\n\n",
            startdta,csize);
    for(i=0;i<maxfat;i++)
    {
        if(count++%5==0)
            printf("\n%04d:",i);
        m=readmap(i);
        switch(m.typ)
        {
            case    BAD     :   printf("[--Defekt!!--] ");
                                break;
            case    STRANGE :   printf("[Undefiniert!] ");
                                break;
            case    FREE    :   printf("[---Frei!!---] ");
                                break;
            case    DATA    :   printf("[%4d(%3d)%s ] ",
                                    m.file,m.trace,
                                    (m.last) ? "//" : "  ");
                                break;
            default         :   error("Falscher Karteneintrag!????");
                                break;
        }
    }
    puts("\nEnde der Karte!");
}

/******************************************
 * Haupt-Routine zum Erzeugen der Karte + *
 * initialisiere die globalen Variablen   *
 ******************************************/

int getmap(int volume)
{
    char    *rdalloc(int,int,long);
    int     error;
    long    fatbytes;
    BPB     *bpb;

    if((long)(bpb=Getbpb(volume))==0L)
        return -1;
    setglobals(bpb);
    print_infos(bpb);
    fatbytes=(long)(bpb->recsiz)*(long)(bpb->fsiz);
    printf("Ich lese die FAT ein (Sektoren %d-%d)...\n",
             1,fsize);
    if( (fat=rdalloc(1,bpb->fsiz,fatbytes))==NULL )
        return -2;
    if(askyesno("Soll die unbearbeitete FAT angezeigt werden?"))
        showfat(bpb->numcl);
    if(initmap(bpb->numcl)<0)
    {
        free(fat);
        return -5;
    }
    printf("Ich lese das Root-Directory ein (Sektoren %d-%d)...\n",
        dstart,dstart+dsize-1);
    if( (dir=rdalloc(dstart,dsize,(long)dsize*(long)ssize))==NULL )
    {
        free(map);
        free(fat);
        return -3;
    }
    if((error=maindir())<0)
    {
        free(dir);
        free(map);
        free(fat);
        return ((error==-1) ? -4 : -6);
    }
    printmap();
    free(dir); /* Speicher fÅr Directory freigeben   */
    free(map); /* Speicher fÅr Karte freigeben       */
    free(fat); /* Speicher fÅr FAT freigeben         */
    return 0;   /* kein Fehler */
}

/***********************************
 * Teste auf defekte Sektoren und  *
 * suche ggf. dazugehîrige Dateien *
 ***********************************/

void docheck(int drive)
{
    drive=drive;
    return;
}

/**************************************************
 * Schwerer Fehler! Meldung + Programm abbrechen. *
 **************************************************/

void error(char *s)
{
    printf("%s\nBitte Taste drÅcken!\n",s);
    Bconin(2);
    exit(0);
}
/* The end... */

