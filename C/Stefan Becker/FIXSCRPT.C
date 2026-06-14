
/**************************************************************
 * FIXSCRPT.C                                                 *
 **************************************************************
 * Dies Programm speichert ein mit Script-ST mitgeschriebenes *
 * Ausgabeprotokoll in eine Datei ab.                         *
 **************************************************************
 * (C)1989 by Stefan Becker                                   *
 **************************************************************
 * Rechner: Atari-ST | Compiler: Turbo-C 1.1 | Tab:4          *
 **************************************************************/

#include    <stdlib.h>
#include    <stdio.h>
#include    <tos.h>

/**************
 * Konstanten *
 **************/

#define     NIL         ((INFO*)0)  /* Nullzeiger                 */
#define     MARKER      0x53435249  /* Markierung fr Script-ST   */
#define     SWV_VEC     0x46e       /* Systemvariable SWV-VEC     */
#define     SCR_OFFSET  8           /* Offset fr Script-Struktur */

/********************
 * Typendeklaration *
 ********************/

typedef struct info
    {
        long    kennung;
        char    *bstart;
        char    *bptr;
        long    size;
        long    fflag;
    } INFO;

/*****************
 * Hauptprogramm *
 *****************/

main()
{
    void    error(char*),ende(void),clearbuf(INFO*),printinfos(INFO*);
    char    ch,cmd[80];
    int     savebuf(INFO*),t=1;
    INFO    *installed(void);
    INFO    *infptr;

    puts("\nScript-ST-Speicherprogramm by Stefan Becker (C)1989\n");
    if((infptr=installed())==NIL)
        error("Script-ST ist nicht installiert!");
    printf("Script-ST ist installiert. OK.\n");
    printinfos(infptr);
    do
    {
        puts("\nWollen Sie das Script");
        puts(" [A] Abspeichern oder");
        puts(" [L] l”schen?");
        puts(" [Q] Programmende\n");
        printf("Ihre Wahl =>?%c",(char)8);
        gets(cmd);
        ch=cmd[0];
        switch(ch)
        {
            case    'a':
            case    'A':if(!savebuf(infptr))
                            puts("Huch, Schreibfehler!?");
                        break;
            case    'l':
            case    'L':clearbuf(infptr);
                        puts("Puffer gel”scht!");
                        break;
            case    'q':
            case    'Q':ende();
            default    :putchar((char)7);
        }
    } while(t);
    return 0;
}

/******************
 * Unterprogramme *
 ******************/

void printinfos(INFO *p)
{
    long    l;

    printf("Pufferstart bei: $%06lx\n",p->bstart);
    printf("Pufferzeiger   : $%06lx\n",p->bptr);
    printf("Puffergr”že    :  %6ld\n",p->size);
    l=(long)(p->bptr)-(long)(p->bstart);
    printf("     d.h. L„nge:  %6ld (=$%lx)\n",l,l);
    printf("Fllstand      : %s\n",(p->fflag) ? "voll" : "noch Platz");
    puts("");
}

void ende(void)
{
    puts("Es war mir ein ganz besonderes Vergngen!\Bye Bye!");
    exit(0);
}

void error(char *s)
{
    printf("Fehler: %s\nBitte Taste drcken!",s);
    Bconin(2);
    ende();
}

void clearbuf(INFO *ptr) /* Puffer l”schen */
{
    ptr->bptr=ptr->bstart;
    ptr->fflag=0L;
}

int savebuf(INFO *ptr) /* Puffer auf Disk schreiben */
{
    char    name[80];
    int     handle;
    long    l;

    printf("Filename (RETURN=Abbruch) =>");
    gets(name);
    if(name[0]=='\0')
        return 1;
    if((handle=Fcreate(name,0))<0)
        return 0;
    l=(long)(ptr->bptr)-(long)(ptr->bstart);
    if(Fwrite(handle,l,ptr->bstart)!=l)
    {
        Fclose(handle);
        return 0;
    }
    Fclose(handle);
    return 1;
}

INFO *installed(void) /* Teste, ob Script resident. Ja => Zeiger auf INFO */
{
    long    savessp,*ptr;
    int     erg;

    savessp=Super(0L);
    ptr=(long*)*((long*)SWV_VEC);
    erg=(*(long*)((long)ptr+SCR_OFFSET)==MARKER);
    Super((void*)savessp);
    if(erg) /* Script da? */
        return (INFO*)(ptr+2);
    else
        return NIL;
}

/* The end */

