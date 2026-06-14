/****************************************************************
 * Speichert einen mit Text-Hardcopy gescannten Bereich in eine *
 * Datei. (C)1988 Stefan Becker | Compiler: Turbo-C Ver. 1.0    *
 ****************************************************************/
 
#include        <stdio.h>
#include        <stdlib.h>
#include        <tos.h>

#define         VBLQUEUE        0x456L

char            *txtadr;

main()
{
        void    error(char*),savebuff(char*);
        char    *ptr=(char*)VBLQUEUE,*txtadr;
    long    savessp,marker=0x48445458;

        puts("");
    printf("                         ");
    puts("HD-Fix by Stefan Becker (C)1988");
    printf("                         ");
    puts("===============================\n");
    savessp=Super(0L);    
    ptr=(char*)*((long*)ptr); /* Lese VBL-Slot 0 aus! */
    ptr=(char*)*((long*)ptr);
    ptr+=2;     /* evtl. "bra.s" berspringen */
    if(*((long*)ptr)==marker) /* Steht hier Text-Hardcopy? */
    { /* Ja! */
        ptr+=4; /* Puferadresse auslesen... */
        txtadr=(char*)(*((long*)ptr));
    }
    else
        txtadr=(char*)0; /* Nein! */
    Super((char*)savessp);
    if((long)txtadr==0L)
        error("Text-Hardcopy ist nicht resident!");
    printf("Text-Hardcopy ist resident vorhanden.\nPufferadresse: $%lx\n",
           txtadr);
    savebuff(txtadr);
    Bconin(2);
    return 0;
}

void savebuff(char *ptr)
{
        void    killspaces(char*),error(char*);
        char    *makestr(char*),*s,filename[80],crlf[3];
        int             i;
        FILE    *fhandle;
        
        sprintf(crlf,"\n");
        printf("\nDateiname ([RETURN]=Abbruch) =>");gets(filename);
        if(filename[0]==(char)0)
        {
                puts("Abbruch! O.K.!");
                exit(0);
        }
        if((fhandle=fopen(filename,"w"))==NULL)
                error("Datei kann nicht er”ffnet werden!");
        puts("Es wird geschrieben...");
        for(i=0;i<25;i++,ptr+=80)
        {
                s=makestr(ptr);
                printf("%02d:%s\n",i,s);
                killspaces(s);
                if(fputs(s,fhandle)==EOF)
                        error("Disk-Schreibfehler!");
                if(fputs(crlf,fhandle)==EOF)
                        error("Disk-Schreibfehler!");
        }
        if(fclose(fhandle)==EOF)
                error("Datei kann nicht geschlossen werden!");
        puts("Datei wurde korrekt geschrieben!");
}

void killspaces(char s[])
{
        int     i;
        
        for(i=79;i>=0 && s[i]==' ';i--);
        s[i+1]=(char)0;
}

char *makestr(char *ptr)
{
        int             i;
        static  char str[81];
        
        for(i=0;i<80;i++,ptr++)
                str[i]=*ptr;
        str[80]=(char)0;
        return &str[0];
}

void error(char *s)
{
    printf("Fehler: %s\nBitte Taste drcken!\n",s);
    Bconin(2);
    exit(0);
}

/* The end... */
