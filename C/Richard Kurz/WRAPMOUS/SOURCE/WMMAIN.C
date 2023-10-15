/*  WRAP Mouse
 *  Main-Teil
 *
 *  (c)1992 by Richard Kurz
 *  Vogelherdbogen 62
 *  7992 Tettnang
 *  Fido 2:241/7232
 *
 *  FÅr's TOS-Magazin
 *
 *  Erstellt mit Pure C
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <screen.h>
#include <linea.h>
#include <wrapauto.h>


/* globale Variablen                            */
SYSHDR *sh;
INF inf;
long stackcorr;
int ap=0;

/* externe Variablen aus dem Assemblerteil      */
extern void new_mouse(void);
extern long old_mouse;
extern void new_dos(void);
extern long old_dos;
extern void new_joy(void);
extern long old_joy;
extern long init_vbl(void);

/* externe Variablen aus dem RS232-Teil         */
void init_rs(void);
extern unsigned char rs[50];
extern int rsf;

long init_mouse(void)
{
    KBDVBASE *kb;
    long ssp;
    
    linea_init();

    ssp=Super(0L);
    sh=(SYSHDR*)(*(long*)0x4f2L);
    stackcorr=(*(int *)0x59eL)? 8:6;
    Super((void *)ssp);

    kb=Kbdvbase();
    old_mouse=(long)kb->kb_mousevec;
    kb->kb_mousevec=new_mouse;
    old_joy=(long)kb->kb_joyvec;
    kb->kb_joyvec=new_joy;
    old_dos=(long)Setexc(33,new_dos);
    Supexec(init_vbl);
    if(inf.r_flag) init_rs();

    return(TRUE);
}/* init_mouse */

int get_aes(void)
{
    appl_init();
    if(_GemParBlk.global[0])
        return(TRUE);
    else
        return(FALSE);
}/* get_aes */

int main(void)
{
    unsigned long d;
    int ae;

    inf.d[0].mw[0]=inf.d[1].mw[0]=inf.d[2].mw[0]=2;
    inf.d[0].mw[1]=inf.d[1].mw[1]=inf.d[2].mw[1]=3;
    inf.d[0].mw[2]=inf.d[1].mw[2]=inf.d[2].mw[2]=4;
    inf.d[0].mw[3]=inf.d[1].mw[3]=inf.d[2].mw[3]=5;
    inf.d[0].mw[4]=inf.d[1].mw[4]=inf.d[2].mw[4]=6;
    inf.d[0].mw[5]=inf.d[1].mw[5]=inf.d[2].mw[5]=8;

    inf.d[0].mf[0]=inf.d[1].mf[0]=inf.d[2].mf[0]=20;
    inf.d[0].mf[1]=inf.d[1].mf[1]=inf.d[2].mf[1]=20;
    inf.d[0].mf[2]=inf.d[1].mf[2]=inf.d[2].mf[2]=20;
    inf.d[0].mf[3]=inf.d[1].mf[3]=inf.d[2].mf[3]=20;
    inf.d[0].mf[4]=inf.d[1].mf[4]=inf.d[2].mf[4]=20;
    inf.d[0].mf[5]=inf.d[1].mf[5]=inf.d[2].mf[5]=20;

    inf.d[0].rand[0]=inf.d[1].rand[0]=inf.d[2].rand[0]=60;
    inf.d[0].rand[1]=inf.d[1].rand[1]=inf.d[2].rand[1]=60;
    inf.d[0].rand[2]=inf.d[1].rand[2]=inf.d[2].rand[2]=60;
    inf.d[0].rand[3]=inf.d[1].rand[3]=inf.d[2].rand[3]=60;

    inf.d[0].s_flag=inf.d[1].s_flag=inf.d[2].s_flag=TRUE;
    inf.d[0].w_flag=inf.d[1].w_flag=inf.d[2].w_flag=TRUE;

    inf.rp_flag=1;
    inf.r_flag=TRUE;
    inf.j_flag=TRUE;
    
    strcpy(inf.pf[0].name,"Allgemein");
    
    ae=get_aes();
    if(ae) form_alert(1,"[1][Wrap Mouse V1.0|(c)1992 by Richard Kurz|Vogelherdbogen 62|7992 Tettnang][ OK ]");
    else
    {
        puts("");
        Rev_on();
        puts("     Wrap Mouse V1.0     ");
        Rev_off();
        puts("(c)1992 by Richard Kurz");
        puts("Vogelherdbogen 62");
        puts("7992 Tettnang");
        puts("Fido 2:241/7232.5");
        puts("");
        puts("FÅr's TOS-Magazin");
        puts("");
    }
        
    if(get_cookie('WrAp',&d))
    {
        if(ae) form_alert(1,"[3][ |Fehler:|Wrap Mouse ist bereits|installiert!][ OK ]");
        else
        {
            puts("FEHLER:");
            puts("Bin schon da");
            puts("\n<RETURN>");
            getchar();
        }
        if(ae) appl_exit();
        return(1);
    }
    inf.set_vec=init_mouse;

    if(make_cookie('WrAp',(unsigned long)&inf))
    {
        if(ae)
        {
            init_mouse();
            inf.fix=TRUE;
            appl_exit();
        }
        else inf.fix=FALSE;
        Ptermres(_PgmSize,0);
    }
    if(ae) form_alert(1,"[3][ |Fehler:|Das Cookie WrAp konnte|nicht angelegt werden!][ OK ]");
    else
    {
        puts("FEHLER:");
        puts("Das Cookie WrAp konnte nicht angelegt werden");
        puts("\n<RETURN>");
        getchar();
    }
    if(ae) appl_exit();
    return(1);
} /* main */
