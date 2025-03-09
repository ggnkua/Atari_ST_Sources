/* XBRA.TOS
 * Programm zur Anzeige von XBRA-Programmen
 * im Speicher und zum gezielten Deaktivieren
 * einzelner Programme.
 * Entwickelt mit Turbo C von Andreas Kohler
 * (c) 1992 MAXON Computer GmbH
 */
 
#include <stdio.h>
#include <tos.h>
#include <string.h>
#include <ctype.h>

/* Bildschirmsteuerung */
#define Cls()       printf("\033E")
#define Nowrap()    printf("\033w")
#define Top()       printf("\033H\033l")

typedef void **ADDR;

typedef struct {
    char    xb_magic[4];
    char    xb_id[4];
    void    *xb_vec;
} XBRA;

typedef struct {
    char    name[13];
    ADDR    addr;
} SYSVAR;

int varnum;
SYSVAR vars[] = {
    {"midivec", 0l},        {"vkbdvec", 0l},
    {"vmiderr", 0l},        {"statvec", 0l},
    {"mousevec", 0l},       {"clockvec", 0l},
    {"joyvec", 0l},         {"midisys", 0l},
    {"ikbdsys", 0l},        {"Trace", 0x24l},
    {"Line A", 0x28l},      {"Line F", 0x2Cl},
    {"Gemdos", 0x84l},      {"Bios", 0xB4l},
    {"Xbios", 0xB8l},       {"etv_timer", 0x400l},
    {"etv_critic", 0x404l}, {"etv_term", 0x408l},
    {"resvector", 0x42Al},  {"hdv_init", 0x46Al},
    {"swv_vec", 0x46El},    {"hdv_bpb", 0x472l},
    {"hdv_rw", 0x476l},     {"hdv_boot", 0x47Al},
    {"hdv_mediach", 0x47El},{"exec_os", 0x4FEl},
    {"dump_vec", 0x502l},   {"prt_stat", 0x506l},
    {"prt_vec", 0x50Al},    {"aux_stat", 0x50El},
    {"aux_vec", 0x512l},    {"", 0l}
};


void varinit()
{
    ADDR    lp;
    SYSVAR *sv;
    
    sv = vars;
    lp = (ADDR) Kbdvbase();
    for (; ! sv->addr; sv++)
        sv->addr = lp++;
}

int getxbra(vec, name, next)
ADDR vec;
char *name;
ADDR *next;
{
    XBRA *xbp;
    
    if ((long) vec % 2l)   /* ungerade Adresse */
        return (0);
    if ((long) *vec % 2l)
        return (0);
    if ((long) *vec < sizeof(XBRA))
        return (0);
    xbp = (XBRA *) *vec;
    xbp--;
    if (! strncmp(xbp->xb_magic, "XBRA", 4))
    {
        strncpy(name, xbp->xb_id, 4);
        name[4] = '\0';
        *next = &(xbp->xb_vec);
        return (1);
    }
    return (0);
}

void un_link(id)
char *id;
{
    register int i;
    char name[5];
    ADDR next, old;
    
    for (i = 0; i < varnum; i++)
    {
        old = vars[i].addr;
        while (getxbra(old, name, &next))
        {
            if (! strncmp(name, id, 4))
            {
                *old = *next;
                break;
            }
            old = next;
        }
    }
}

void prnpage(n)
int n;
{
    register int i;
    ADDR next;
    char name[5];
    
    Cls();
    printf(" 1... = Seitenwahl, R = Eintrag ");
    printf("entfernen, <ESC> = Abbruch ");
    for (i = 24 * n; i < varnum && i < (n+1) * 24; i++)
    {
        printf("\n%12s  $%04lX ", 
                vars[i].name, vars[i].addr);
        next = vars[i].addr;
        while (getxbra(next, name, &next))
            printf("%4s ", name);   
    }
}
        
main()
{
    long oldstack;
    int page, c;
    char rmid[5];
    
    Nowrap();
    oldstack = Super(NULL);
    varinit();
    for (varnum = 0; vars[varnum].addr; varnum++)
        ;
    prnpage(page = 0);      
    
    while ((c = toupper((int) Cnecin())) != 27)
    {
        if (c >= '1' && c <= '9')
        {
            if ((c - '1') * 24 <= varnum)
            {
                page = c - '1';
                prnpage(page);
            }
        }
        else if (c == 'R')
        {
            Top();
            printf(" Entfernen: ");
            scanf("%4s", rmid);
            Top();
            printf(" \'%s\' entfernen (J/N) ? ", rmid);
            if (toupper((int) Cnecin()) == 'J')
                un_link(rmid);
            prnpage(page);
        }
    }
    Super((void *) oldstack);
}
