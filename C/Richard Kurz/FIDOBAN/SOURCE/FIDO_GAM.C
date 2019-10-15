/* FIDO_GAM.C
 * Die Spielroutinen fÅr FIDOBAN
 * 1992 by Richard Kurz
 * Vogelherdbogen 62
 * 7992 Tettnang
 * Fido: 2:241/7232.5
 *
 * fÅr's TOS Magazin
 * ICP Verlag
 */

#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <time.h>
#include "fidoban.h"

/* Das Spielfeld */
char g_feld[20][20];
/* Ein Backup desselben */
char l_feld[20][20];
/* Die Spielerposition */
int sx,sy;

int load_feld(level)
/* Laedt einen Level */
{
    int f,x,y;
    char c;
    static char pfad[256];
    static char s[40];

    memset(pfad,0,255);
    pfad[0]=Dgetdrv()+'A';
    pfad[1]=':';
    Dgetpath(&pfad[2],0);
    if(pfad[strlen(pfad)-1]!='\\') strcat(pfad,"\\");
    strcat(pfad,"screens\\screen.");
    sprintf(s,"%i",level);
    strcat(pfad,s);
    f=open(pfad,O_RDONLY);
    if(f<0) return(FALSE);
    
    for(x=0;x<20;x++)
        for(y=0;y<20;y++)
            g_feld[x][y]=l_feld[x][y]=' ';
            
    x=0;y=0;
    while(read(f,&c,1)==1)
    {
        if(c=='@'){sx=x;sy=y;}
        if(c==10) continue;
        if(c!=13) 
            g_feld[x][y]=c;
        else
            x=20;
        if(++x>=20)
        {
            x=0;
            if(++y>=20) break;
        }
    }

    for(x=0;x<20;x++)
        for(y=0;y<20;y++)
        {
            switch(g_feld[x][y])
            {
                case '@':
                    sx=x; sy=y;
                    l_feld[x][y]=' ';
                    break;
                case '$':
                    l_feld[x][y]=' ';
                    break;
                case '*':
                    l_feld[x][y]='.';
                    g_feld[x][y]='$';
                    break;
                case '.':
                case '#':
                case ' ':
                    l_feld[x][y]=g_feld[x][y];
                    break;
                default:
                    g_feld[x][y]=l_feld[x][y]=' ';
                    break;
            }
        }
    return(TRUE);
}/* load_feld */

int check_game(void)
/* Ist der Level schon gelîst? */
{
    int x,y,l,b;
    
    l=0;b=0;
    for(x=0;x<20;x++)
    {
        for(y=0;y<20;y++)
        {
            if(l_feld[x][y]=='.' && g_feld[x][y] !='$') l++;
            if(g_feld[x][y]=='$' && l_feld[x][y] !='.') b++;
        }
    }
    if(!l || !b) return(TRUE);
    return(FALSE);
}/* check_game */

int spieler_zug(int r)
/* Die Spielerfigur wird bewegt */
{
    int zx,zy,bx,by;
    
    zx=sx;
    zy=sy;

    switch(r)
    {
        case RAUF:      if(--zy < 0) zy=0 ; break;
        case RUNTER:    if(++zy >19) zy=19; break;
        case LINKS:     if(--zx < 0) zx=0 ; break;
        case RECHTS:    if(++zx >19) zx=19; break;
    }
    switch(g_feld[zx][zy])
    {
        case '.':
        case ' ':
        case '$': break;
        default: return(BOING);
    }

    bx=-1;by=-1;
    switch(g_feld[zx][zy])
    {
        case '$':
            if((zx<sx)&&(g_feld[zx-1][zy]==' ' || g_feld[zx-1][zy]=='.'))
            {bx=zx-1;by=zy;}
            else if((zx>sx)&&(g_feld[zx+1][zy]==' ' || g_feld[zx+1][zy]=='.'))
            {bx=zx+1;by=zy;}
            else if((zy<sy)&&(g_feld[zx][zy-1]==' ' || g_feld[zx][zy-1]=='.'))
            {bx=zx;by=zy-1;}
            else if((zy>sy)&&(g_feld[zx][zy+1]==' ' || g_feld[zx][zy+1]=='.'))
            {bx=zx;by=zy+1;}
            else
            {
                return(BOING);
            }
        case '.':
        case ' ':
            g_feld[sx][sy]=l_feld[sx][sy];
            g_feld[zx][zy]='@';
            setze_stein(sx,sy,l_feld[sx][sy]);
            setze_stein(zx,zy,l_feld[zx][zy]);
            if(bx>0)
            {
                g_feld[bx][by]='$';
                setze_stein(bx,by,'$');
                if(check_game()) return(FERTIG);
            }
            setze_stein(zx,zy,'@');
            sx=zx;
            sy=zy;
            break;
        default:
                return(BOING);
    }
    return(OKAY);
} /* spieler_zug */
