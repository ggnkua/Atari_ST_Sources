#include "pictran.h"

int contrl[12],
        intin[128],
        ptsin[128],
        intout[128],
        ptsout[128],
        msg[16];

int work_out[57],
        work_in[12];

int     handle,
        gl_hhbox,gl_hwbox,
        gl_hhchar,gl_hwchar;

long mptr,screen,page;

char pfadname[255];

int format,hilfe,palette[16],oldpal[16];

extern long sxbios();

open_work()
{
        int i;
        appl_init();
        handle=graf_handle(&gl_hwchar,&gl_hhchar,&gl_hwbox,&gl_hhbox);
        for(i=0;i<10;work_in[i++]=1);
        work_in[10]=2;
        v_opnvwk(work_in,&handle,work_out);
}

close_work()
{
        v_clsvwk(handle);
        appl_exit();
}

str_copy(ziel,quelle)
char *ziel,*quelle;
{
     while(*ziel++ = *quelle++);
}

str_concat(ziel,quelle)
char *ziel,*quelle;
{
     char name[255];
     while(*ziel++);
     ziel--;
     while((*(ziel--) != 92) && (*ziel != 0));
     ziel++;
     ziel++;
     while(*ziel++ = *quelle++);
}

int dauswahl(filename)
char *filename;
{
char name[255],path[255];
int ok;
str_copy(name,"");
path[0]=sgemdos(0x19)+65;
switch(format)
        {
        case NEO:       str_copy(&path[1],":\*.NEO");
                        break;
        case DEGAS:     str_copy(&path[1],":\*.PI1");
                        break;
        case DOODLE:    str_copy(&path[1],":\*.DOO");
                        break;
        case COMPACT:   str_copy(&path[1],":\*.CMP");
                        break;
        }
fsel_input(path,name,&ok);
update();
str_copy(filename,path);
str_concat(filename,name);
return(ok);
}

check()
{
    menu_icheck(mptr,format,0);
    format=msg[4];
    menu_icheck(mptr,format,1);
}

update()
{
        v_hide_c(handle);
        copyscreen(page,screen,11,199);
        v_show_c(handle,1);
}

extern long getpage();
extern long calpage();

haupt()
{
palget(oldpal);
screen=sxbios(2);
page=getpage();
page=calpage(page);
clearscreen(page,0,199);
format=NEO;
open_work();
rsrc_load("pictran.rsc");
rsrc_gaddr(0,MENU,&mptr);
menu_bar(mptr,1);
update();

do
        {
        graf_mouse(3,&hilfe);
        evnt_mesag(msg);
        switch(msg[4])
                {
                case NEO:       check();
                                break;
                case DEGAS:     check();
                                break;
                case DOODLE:    check();
                                break;
                case COMPACT:   check();
                                break;
                case PICINFO:   form_alert(1,"[1][ |Picture-Transformer|by Frank Mathy|(C) 1987 M & T][ OK ]");
                                break;
                case LOAD:      hilfe=dauswahl(pfadname);
                                if(hilfe==1)
                                    {
                                    graf_mouse(2,&hilfe);
                                    switch(format)
                                        {
                                        case NEO:      hilfe=picload(pfadname,page,palette,0);
                                                       break;
                                        case DEGAS:    hilfe=picload(pfadname,page,palette,1);
                                                       break;
                                        case DOODLE:   hilfe=picload(pfadname,page,palette,-1);
                                                       break;
                                        case COMPACT:  hilfe=cload(pfadname,page,32000L,palette);
                                                       break;
                                        };
                                    if (hilfe>=0)
                                                {
                                                if (format != DOODLE) sxbios(6,palette);
                                                update();
                                                }
                                    else form_alert(1,"[1][ |Ladefehler...][ OK ]");
                                    }
                                break;
                case SAVE:      hilfe=dauswahl(pfadname);
                                if(hilfe==1)
                                    {
                                    graf_mouse(2,&hilfe);
                                    switch(format)
                                        {
                                        case NEO:      hilfe=picsave(pfadname,page,palette,0);
                                                       break;
                                        case DEGAS:    hilfe=picsave(pfadname,page,palette,1);
                                                       break;
                                        case DOODLE:   hilfe=picsave(pfadname,page,palette,-1);
                                                       break;
                                        case COMPACT:  hilfe=csave(pfadname,page,32000L,palette);
                                                       break;
                                        };
                                    if (hilfe<=0) form_alert(1,"[1][ |Fehler beim|Saven...][ OK ]");
                                    }
                                break;
                case HARDCOPY:  hilfe=sgemdos(0x11);
                                if (hilfe!=0)
                                        {
                                        v_hide_c(handle);
                                        sxbios(5,page,-1L,-1);
                                        sxbios(20);
                                        sxbios(5,screen,-1L,-1);
                                        v_show_c(handle,1);
                                        }
                                else form_alert(1,"[1][ |Drucker nicht|bereit...][ OK ]");
                                break;
                case INVERT:    opscreen(page,page,0,199,3);
                                update();
                                break;
                case XMIRROR:   xmirror(page,0,199);
                                update();
                                break;
                case YMIRROR:   graf_mouse(2,&hilfe);
                                ymirror(page,0,199);
                                update();
                                break;
                case ROT180:    graf_mouse(2,&hilfe);
                                xmirror(page,0,199);
                                ymirror(page,0,199);
                                update();
                                break;
                }
    menu_tnormal(mptr,msg[3],1);
    }
while(msg[4]!=QUIT);

menu_bar(mptr,0);
rsrc_free();
close_work();
freepage(page);
sxbios(6,oldpal);
}

main()
{
if (sxbios(4)==0) haupt();
     else       {
                open_work();
                form_alert(1,"[1][Pic-Transformer|(C) Frank Mathy|Nur im|320x200-Modus...][ OK ]");
                close_work();
                }
}

