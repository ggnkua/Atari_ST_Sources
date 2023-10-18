/****************************************************/
/*                                                  */
/*                  R E C O G                       */
/*                                                  */
/*          Wir schaben ASCII-Zeichen               */
/*          vom Bildschirm.                         */
/*          erstellt mit PURE C 1.0                 */
/*          lauffÑhig auf ST, STE und TT            */
/*                                                  */
/*          (c) 1992 by Richard Kurz                */
/*          Vogelherdbogen 62                       */
/*          7992 Tettnang                           */
/*                                                  */
/*          TOS Magazin, ICP Verlag                 */
/*                                                  */
/****************************************************/
/* In diesem Modul RECOG.C sind die Schrift-        */
/* erkennungsroutinen enthalten.                    */
/****************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <vdi.h>
#include <tos.h>
#include <string.h>
#include <linea.h>
#include "global.h"

extern int handle,max_x,max_y;

int tfp;
int Done, zbp;
int von=33, bis=126;
int loeschen=TRUE,buendig=FALSE;
int use_linea=TRUE;
int schwarz;

AFONT font;
BMAP codes[256];
ZBUFFER z_buffer[MAXZBP];

int point(int x, int y)
/* Ist ein PÅnktchen schwarz oder weiû? */
{
    int i,p;

    if(x<0 || x>max_x || y<0 || y>max_y) return(0);
    if(use_linea)
    {
        return(get_pixel(x,y)==schwarz ? 1 : 0);
    }
    v_get_pixel(handle,x,y,&p,&i);
    if(p) return(i==1 ? 1 : 0);
    return(FALSE);
} /* point */

void plot(int x, int y)
/* Ein Punkt wird gesetzt */
{
    int px[4];
    
    if(x<0 || x>max_x || y<0 || y>max_y) return;
    if(use_linea)
    {
        put_pixel(x,y,0);
    }
    else
    {
        px[0]=px[2]=x;
        px[1]=px[3]=y;
        v_pline(handle,2,px);
    }
} /* plot */

void init_font(void)
/* Der Font-Speicher will gelîscht sein */
{
    int i,j;
    
    for(i=0;i<=255;i++)
    {
        codes[i].hoehe=0;
        for(j=0;j<=15;j++)
        {
            codes[i].breite_r[j]=codes[i].bitr[j]=0;
            codes[i].breite_l[j]=codes[i].bitl[j]=0;
        }
    }
} /* init_screen */

int is_char(int x,int y, int *ch)
/* Handelt es sich bei dem, an x und y befindlichen,    */
/* Pixel-HÑufchen eventuell um einen Buchstaben?        */
{
    static unsigned int gbitr[16];  /* Alle Pixel rechts von x  */
    static unsigned int gbitl[16];  /* Dito links               */
    static char s[80];              /* FÅr form_alert           */
    register int i,j;               /* Fixe ZÑhler              */
    register unsigned int r,l;      /* Wie gbitr/l              */
    int z;                          /* Welches Zeichen ist dran */
    int gh=0;                       /* Wie hoch ?               */
    int y2,gef=0,xt,bf,h;           /* Puffer und Flags         */
    long w=0,gw=0;                  /* PrÅfsummen               */
    BMAP *c;                        /* Daten des PixelhÑufchens */

    for(j=0;j<=font.h+1;j++)        /* Das PixelhÑufchen wird   */
    {                               /* vom Bildschirm geholt    */
        gbitr[j]=0;
        gbitl[j]=0;
        for(i=0,y2=y+j;i<font.cw;i++)
        {
            if(point(x+i,y2))
            {
                gbitr[j] |= (0x8000>>i);
            }
            if(point(x-i,y2))
            {
                gbitl[j] |= (1<<i);
            }
        }
    }
    for(z=von;z<=bis;z++)           /* Die Daten werden mit     */
    {                               /* dem gelernten Font ver-  */
        c=&codes[z];                /* glichen                  */
        for(j=0,w=0;j<=c->hoehe;j++)
        {
            l=gbitl[j] << (font.k-c->breite_l[j]);
            if(l!=c->bitl[j]) break;
            r=gbitr[j] >> (font.k-c->breite_r[j]);          
            if(r!=c->bitr[j]) break;
            w+=l;
            w+=r;
        }
        if(j == c->hoehe+1)         /* Es war ein Zeichen       */
        {
            if(font.k==14)          /* Sollen auch "angeklebte" */
            {                       /* Zeichen erkannt werden?  */
                bf=FALSE;
                h=c->hoehe;
                for(xt=x-(c->breite_l[h]);xt<=x+(c->breite_r[h]);xt++)
                {
                    if(point(xt,y+c->hoehe+1))
                    {
                        bf=TRUE;
                        break;
                    }
                }
                if(bf)
                    continue;
            }
            if(gef)                 /* Haben wir schon eines    */
            {                       /* gefunden                 */
                if(c->hoehe == gh)
                {
                    if(w == gw)
                    {                       
                        sprintf(s,"[0][Konflikt bei x=%i,y=%i |Bitte wÑhlen ][ %i %c | %i %c | Keines ]",
                        x,y,gef,gef,z,z);
                        switch(form_alert(3,s))
                        {
                            case 2: gef=z; break;
                            case 3: gef=0; break;
                            default: break;
                        }
                    }
                    else if(w>gw)   /* Welches ist besser?      */
                    {
                        gef=z;
                        gh=c->hoehe;
                        gw=w;
                    }
                }
                else if(c->hoehe > gh)  /* Je hîher je lieber   */
                {
                    gef=z;
                    gh=c->hoehe;
                    gw=w;
                }
            }
            else                    /* Zeichen merken           */  
            {
                gef=z;
                gh=c->hoehe;
                gw=w;
            }
        }   
    }
    if(gef)
    {
        *ch=gef;
        return(TRUE);
    }
    return(FALSE);
} /* is_char */

void ch_gefunden(int x, int y, int ch)
/* Wir haben ein Zeichen gefunden! Juchu    */
/* Das Gefundene muû noch gemerkt werden    */
/* und das PixelhÑufchen wird gelîscht      */
{
    register int i,j,y2=y;

    for(i=0;i<=codes[ch].hoehe;i++,y++)     /* Lîschen          */
    {
        for(j=0;j<=codes[ch].breite_r[i];j++)
            plot(x+j,y);
        for(j=1;j<=codes[ch].breite_l[i];j++)
            plot(x-j,y);
    }
    z_buffer[zbp].c=ch;                     /* Merken           */
    z_buffer[zbp].x=x;
    z_buffer[zbp].y=y2;
    zbp++;
    if(zbp>=MAXZBP && !Done)
    {
        form_alert(1,"[3][ |Der Zeichenspeicher |ist voll!][ Schade]");
        Done=TRUE;
    }
} /* ch_gefunden */

void lerne_char(int x,int y,BMAP *c)
/* Die zu erkennenden Zeichen sollten gelernt werden */
{
    register int i,j,y2;
    
    c->hoehe=0;
    for(j=0;j<=font.h+1;j++)        /*  Sollange wie der Font   */
    {                               /*  hoch ist                */
        for(i=0,y2=y+j;i<font.cw;i++)   /* und solange ein      */
        {                           /*  Zeichen breit ist       */
            if(point(x+i,y2))       
            {
                c->bitr[j] |= (0x8000>>i);
                if(i>c->breite_r[j]) c->breite_r[j]=i;
                if(j>c->hoehe) c->hoehe=j;
            }
            if(point(x-i,y2))
            {
                c->bitl[j] |= (1<<i);
                if(i>c->breite_l[j]) c->breite_l[j]=i;
                if(j>c->hoehe) c->hoehe=j;
            }
        }
        c->bitr[j] >>= font.k-c->breite_r[j];           
        c->bitl[j] <<= font.k-c->breite_l[j];
    }
} /* lerne_char */

void lerne_satz(int ox, int oy)
/* Ein ganzer Zeichensatz wird gelernt  */
{
    int x,y,z;
    char s[2]; 

    for(z=1;z<=255;z++)
    {
        s[0]=z; s[1]=0;
        v_gtext(handle,ox-15,oy,s);
        for(y=oy-16;y<oy;y++)
        {
            for(x=ox-16;x<ox;x++)
            {
                if(point(x,y))
                {
                    lerne_char(x,y,&codes[z]);
                    goto weiter;    /* Ein GOTO Igitt   */
                }
            }
        }
        weiter:;
    }
} /* lerne_satz */

void scan_screen(int fx,int fy,int lx,int ly)
/* Der angegebene Bildschirmbereich wird nach   */
/* erkennbaren Zeichen durchforstet.            */
{
    int mx,my,mb,mk;    /* Maus-Parameter zum unterbrechen  */
    int x,y;            /* Position                         */
    int ch;             /* Ein Zeichen                      */

    for(y=fy;y<=ly;y++)
    {
        for(x=fx;x<=lx;x++)
        {
            if(point(x,y))  /* Kînnte es der Anfang eines   */
            {               /* Zeichens sein?               */
                graf_mkstate(&mx,&my,&mb,&mk);
                if(mb || mk)    /* Jemand will abbrechen    */
                {
                    return;
                }
                if(is_char(x,y,&ch))    /* Juchu wir haben  */
                {                       /* ein Zeichen      */
                    ch_gefunden(x,y,ch);
                    if(Done) return;
                }
                else if(loeschen)       /* Wenn es MÅll war */
                {                       /* lîschen          */
                    v_contourfill(handle,x,y,0); 
                }
                else
                    plot(x,y);
            }
        }
    }
} /* scan_screen */

int v_dif(int i)
/* Wie weit sind die Zeichen auseinander?   */
{
    int j;
    int xl,xr,x1,x2;

    for(j=0,xr=0;j<16;j++)
    {
        if(codes[z_buffer[i].c].breite_r[j]>xr)
            xr=codes[z_buffer[i].c].breite_r[j];
    }
    for(j=0,xl=0;j<16;j++)
    {
        if(codes[z_buffer[i+1].c].breite_l[j]>xl)
            xl=codes[z_buffer[i+1].c].breite_l[j];
    }
    
    x1=z_buffer[i].x+xr;
    x2=z_buffer[i+1].x-xl;
    return(x2-x1);
}

int qx_verg(ZBUFFER *e1,ZBUFFER *e2)
/* Vergleichsfunktion fÅr Quicksort */
{
    if(e1->x < e2->x) return(-1);
    if(e1->x > e2->x) return(1);
    return(0);
}

int qy_verg(ZBUFFER *e1, ZBUFFER *e2)
/* Vergleichsfunktion fÅr Quicksort */
{
    if(e1->y < e2->y) return(-1);
    if(e1->y > e2->y) return(1);
    return(0);
}

int wandle_ascii(void)
/* Die erkannten Zeichen werden in die richtige */
/* Reihenfolge gebracht                         */
{
    int i,j,k,bz,sp,vd; 
    int row,col;
    int ymin;
    char s[2];
            
    /* Zuerst werden die Zeichen nach der Hîhe sortiert */
    qsort(&z_buffer[0],zbp,sizeof(z_buffer[0]),qy_verg);
    for(i=0;i<zbp;i++)
    {
        bz=i;
        ymin=z_buffer[bz].y;
        while(i<zbp)    /* Solange wir in einer Zeile sind  */
        {
            i++;
            if(z_buffer[i].y<ymin) ymin=z_buffer[i].y;
            if(z_buffer[i].y-ymin >= font.h)
            {
                i--;
                break;
            }
        }
        if(i>=zbp) i=zbp-1;
        /* Wenn eine Zeile erkannt ist, werden die Zeichen  */
        /* nach Ihrem X-Wert sortiert                       */
        qsort(&z_buffer[bz],1+i-bz,sizeof(z_buffer[0]),qx_verg);
        sp=z_buffer[bz].x /font.cw;
        if(!buendig)
        {
            for(k=0;k<sp;k++)
            {
                if(!tfp) v_curtext(handle," ");
                else Fwrite(tfp,1L," ");
            }
        }
        for(j=bz;j<=i;j++)  /* Die Zeile ist fertig und     */
        {                   /* ausgegeben                   */
            s[0]=z_buffer[j].c;
            s[1]=0;
            if(!tfp) v_curtext(handle,s);
            else Fwrite(tfp,strlen(s),s);

            if(j+1<=i && (vd=v_dif(j))>font.cw)
            {   
                sp=vd/font.cw;
                for(k=0;k<sp;k++)
                {
                    if(!tfp) v_curtext(handle," ");
                    else Fwrite(tfp,1L," ");
                }
            }
        }
        if(!tfp)
        {
            vq_curaddress(handle,&row,&col);
            vs_curaddress(handle,row+1,1);
        }
        else
        {
            if(Fwrite(tfp,2L,"\r\n")!=2) return(FALSE);
        }
    }
    return(TRUE); 
} /* wandle_ascii(void) */

