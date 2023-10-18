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
/* In diesem Modul DO_GEM.C steht die Benutzerober- */
/* flÑche und der ganze GEM-Kram. Die eigentlichen  */
/* Schrifterkennungs-Routinen lÅmmeln sich im Modul */
/* RECOG.C.                                         */
/****************************************************/

#include <aes.h>
#include <vdi.h>
#include <linea.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"
#include "recog.h"

extern int Done,zbp,tfp;
extern int von,bis,loeschen,buendig;
extern int use_linea,schwarz;
extern AFONT font;

extern int _app;
int appl_id,menu_id;
int phys_handle,handle;
int gl_wchar,gl_hchar,gl_wbox,gl_hbox; 
int max_x,max_y;

int sys_speicher=FALSE;
char scbuf[SCREENSIZE];

MFDB buffer;
MFDB schirm={NULL};

int xdial,ydial,wdial,hdial;
int xwait,ywait,wwait,hwait;
int xtext,ytext,wtext,htext;

OBJECT *dialog;
OBJECT *wait;
OBJECT *text;
OBJECT *help;
OBJECT *info;

void init_prog(void)
/* Die Resource-Daten werden von Hand angepaût */
{
    rk_rsc_init();
    rk_rsrc_gaddr(DIALOG,&dialog);
    rk_rsrc_gaddr(WAIT,&wait);
    rk_rsrc_gaddr(TEXT,&text);
    rk_rsrc_gaddr(HELP,&help);
    rk_rsrc_gaddr(REINFO,&info);
    form_center(wait,&xwait,&ywait,&wwait,&hwait);  
    form_center(text,&xtext,&ytext,&wtext,&htext);  
    form_center(dialog,&xdial,&ydial,&wdial,&hdial);    
    dialog[TASCII].ob_y-=dialog[TASCII].ob_height/2;
    dialog[TSTYLE].ob_y-=dialog[TSTYLE].ob_height/2;
    dialog[TFONT].ob_y-=dialog[TFONT].ob_height/2;
    dialog[MINI].ob_y+=dialog[MINI].ob_height/4;
    dialog[MINI].ob_height=dialog[MINI].ob_height/2;
    dialog[KLEIN].ob_y+=dialog[KLEIN].ob_height/4;
    dialog[KLEIN].ob_height=dialog[KLEIN].ob_height/2;
    dialog[GROSS].ob_y+=dialog[GROSS].ob_height/4;
    dialog[GROSS].ob_height=dialog[GROSS].ob_height/2;
    dialog[BIS].ob_spec.obspec.character='û';
    if(gl_hchar<16)
    {
        dialog[KLEIN].ob_state |= SELECTED;
        dialog[GROSS].ob_state &= ~SELECTED;
    }
} /* init_prog */

void event_loop( void )
/* Die groûe Lauer auf die Aktivierung */
{
    int pipe[8];

    for(;;)
    {
        evnt_mesag(pipe);
        switch(pipe[0])
        {
            case AC_OPEN:
                if(pipe[4]==menu_id)
                    g_main();
                break;
            default: break;
        }
    }
} /* event_loop */

void main(void)
/* Wir richten uns ein */
{
    int i;
    int work_in[11];
    int work_out[57];

    appl_id=appl_init();
    if(appl_id!=-1)
    {
        for(i=0;i<10;i++) work_in[i]=1;
        work_in[10]=2;
        phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
        handle=phys_handle;
        v_opnvwk(work_in,&handle,work_out); 
        if(handle!=0)
        {
            max_x=work_out[0];
            max_y=work_out[1];
            schwarz=work_out[13]-1;
        
            if(!_app)
            {
                menu_id=menu_register(appl_id,"  Recog");
                init_prog();
                event_loop( );
            }
            else
            {
                init_prog();
                g_main();
            }
            v_clsvwk( handle ); 
        }
        appl_exit( );
    }
    exit(0);
} /* main */

int do_submenu(OBJECT *o, int w)
/* Selbstgestricktes PopUp */
{
    int vx,vy,vw,vh;
    int mx,my,mb,mk,nx,ny,e=0;
    int obj=-1, lobj=-1;
    
    o[w].ob_flags &= ~HIDETREE;
    objc_offset(o,w,&vx,&vy);
    vx--; vy--;
    vw=o[w].ob_width+4;
    vh=o[w].ob_height+4;
    objc_draw(o,w,1,vx,vy,vw,vh);
    mb=1; while(mb) graf_mkstate(&mx,&my,&mb,&mk);
    while(!(e & MU_BUTTON))
    {
        e=evnt_multi(MU_BUTTON | MU_M1,
            0x02,0x01,0x01,
            1,mx,my,1,1,
            0,0,0,0,
            0,0,0,0,
            &nx,&ny,&mb,&mk,&mk,&mk);
        mx=nx;
        my=ny;
        obj=objc_find(o,w,1,mx,my);
        if(obj != lobj)
        {
            if(lobj>=0)
            {
                    o[lobj].ob_state &= ~SELECTED;
                    objc_draw(o,lobj,2,vx,vy,vw,vh);
            }
            if(obj>=0 && !(o[obj].ob_state & DISABLED))
            {
                    o[obj].ob_state |= SELECTED;
                    objc_draw(o,obj,2,vx,vy,vw,vh);
                    lobj=obj;
            }
            else
                lobj=-1;
        }
    }
    if(lobj>=0) o[lobj].ob_state &= ~SELECTED;
    o[w].ob_flags |= HIDETREE;
    objc_draw(o,0,8,vx,vy,vw,vh);
    mb=1; while(mb) graf_mkstate(&mx,&my,&mb,&mk);
    return(lobj);
} /* do_submenu */

void fly_form_do(OBJECT *tree)
/* Freiheit fÅr die Dialogboxen, aber nur mit   */
/* Dragbox!                                     */
{
    int smx,smy;
    int fx,fy,fw,fh;
    int nx,ny,xoff,yoff;
    int work_out[57];

    vq_extnd(handle,0,work_out);
    smx=work_out[0]+1;
    smy=work_out[1]+1;  

    nx=tree[0].ob_x;
    ny=tree[0].ob_y;
    form_center(tree,&fx,&fy,&fw,&fh);
    xoff=tree[0].ob_x-fx;
    yoff=tree[0].ob_y-fy;
    tree[0].ob_x=nx;
    tree[0].ob_y=ny;

    handle_buffer(FMD_FINISH);
    graf_mouse(M_OFF,0);

    graf_dragbox(wdial,hdial,xdial,ydial,0,0,smx,smy,&nx,&ny);

    tree[0].ob_x=nx+xoff;
    tree[0].ob_y=ny+yoff;
    xdial=nx;
    ydial=ny;
    objc_draw(tree,0,8,xdial,ydial,wdial,hdial);
    graf_mouse(M_ON,0);
} /* fly_form_do */

int push_button(OBJECT *o,int e,int x,int y,int w,int h) 
/* Diese netten Buttons sind doch hÅbsch? */
{
    int em=e-1;
    int mx,my,mb,mk,nx,ny;
    int m=0,obj=-1,lobj=-1;
    
    if(o[e].ob_state & DISABLED) return(FALSE);
    graf_mkstate(&mx,&my,&mb,&mk);
    o[em].ob_state &= ~SHADOWED;
    objc_draw(o,em,2,x,y,w,h);
    while(!(m & MU_BUTTON))
    {
        m=evnt_multi(MU_BUTTON | MU_M1,
            0x01,0x01,0x00,
            1,mx,my,1,1,
            0,0,0,0,
            0,0,0,0,
            &nx,&ny,&mb,&mk,&mk,&mk);
        mx=nx; my=ny;
        obj=objc_find(o,e,1,mx,my);
        if(obj != lobj)
        {
            if(obj==e)
            {
                o[em].ob_state &= ~SHADOWED;
                objc_draw(o,em,2,x,y,w,h);
            }
            else
            {
                o[em].ob_state |= SHADOWED;
                objc_draw(o,em,2,x,y,w,h);
            }
            lobj=obj;
        }
    }
    o[em].ob_state |= SHADOWED;
    objc_draw(o,em,2,x,y,w,h);
    return(e==obj);
} /* push_button */

void font_info(void)
/* Welche Dimensionen hat der gewÅnschte Font? */
{
    int cv,cb,maxw,d[5],e[5];
    
    vqt_fontinfo(handle,&cv,&cb,d,&maxw,e);
    font.w+=e[0]+e[2];
    font.cw+=e[0]+e[2];
    if(font.w>16) font.w=16;
    if(font.cw>16) font.cw=16;
} /* font_info */

char *get_pfad(char *ext, char *text)
/* Der Pfadfinder (ein Wîlfling) */
{
    static char pfad[256];
    static char fname[14];
    static int first=TRUE;
    int ok,knopf;
    char *s;
    
    fname[0]=0;
    if(first)
    {
        first=FALSE;
        pfad[0]=Dgetdrv()+'A';
        pfad[1]=':';
        Dgetpath(&pfad[2],0);
        if(pfad[strlen(pfad)-1]!='\\') strcat(pfad,"\\");
    }
    s=strrchr(pfad,'\\');
    if(s!=NULL)
        strcpy(++s,"*.");
    else
        strcpy(pfad,"*.");
    strcat(pfad,ext);
    if((Sversion()>>8)<=20)
    {
        ok=fsel_input(pfad,fname,&knopf);
    }
    else
    {
        ok=fsel_exinput(pfad,fname,&knopf,text);
    }
    if(!ok || !knopf) return(NULL);
    
    s=strrchr(pfad,'\\');
    if(s != NULL)
        strcpy(++s,fname);
    else
        strcpy(pfad,fname);
    return(pfad);
}/* get_pfad */

int bild_laden(void)
/* Wenn RECOG als Programm gestartet wurde  */
/* kann ein Bild im Screen- (Doodle) oder   */ 
/* Degas-Format geladen werden.             */
{
    FILE *fp;
    char *pfad,*ext;
    int e;

    e=form_alert(3,"[2][     Bild laden| |    Welches Format ?][Degas|Screen|keines]");
    switch(e)
    {
        case 1: ext="PI?"; break;
        case 2: ext="DOO"; break;
        default: return(FALSE);
    }
    pfad=get_pfad(ext,"Bild laden");
    if(pfad==NULL) return(FALSE);
    
    fp=fopen(pfad,"rb");
    if(fp==NULL)
    {
        form_alert(1,"[3][ |Die Datei konnte nicht|geîffnet werden.][ Pech ]");
        return(FALSE);
    }
    if(e==1) fseek(fp,34L,SEEK_SET);
    graf_mouse(M_OFF,NULL);
    fread((void *)xbios(2),32000L,1L,fp);
    graf_mouse(M_ON,NULL);
    fclose(fp);
    return(TRUE);
} /* bild_laden */

void show_text(void)
/* Der erkannte Text will auch ausgegeben werden */
{
    int i;
    char *pfad;
        
    graf_mouse(M_OFF,NULL);
    v_enter_cur(handle);
    tfp=0; wandle_ascii();
    graf_mouse(M_ON,NULL);
    evnt_multi(MU_BUTTON | MU_KEYBD,
            0x01,0x01,0x01,
            0,0,0,0,0,
            0,0,0,0,
            0,0,0,0,
            &i,&i,&i,&i,&i,&i);
    if(zbp!=0)
    {
        objc_draw(text,0,1,xtext,ytext,wtext,htext);
        i=form_do(text,0);
        text[i].ob_state &= ~SELECTED;
        switch(i)
        {
            case TLOESCH: zbp=0; break;
            case TSICHERN:
                pfad=get_pfad("TXT","Text sichern");
                if(pfad==NULL) break;
                if((tfp=Fcreate(pfad,0))<0)
                {
                    form_alert(1,"[3][ |Die Datei konnte nicht|geîffnet werden.][ Pech ]");
                    break;
                }
                if(!wandle_ascii())
                    form_alert(1,"[3][ |Die Datei konnte nicht|geschrieben werden.][ Pech ]");
                Fclose(tfp);
                break;
            default: break;
        }
    }
    tfp=0;
    graf_mouse(M_OFF,NULL);
    v_exit_cur(handle);
    handle_buffer(FMD_FINISH);
    objc_draw(dialog,0,4,xdial,ydial,wdial,hdial);
    graf_mouse(M_ON,NULL);
} /* show_text */

int buffer_init(void)
/* Ein Puffer fÅr den Bildschirm wird eingerichtet  */
/* Im Programm ist ein Puffer fÅr die normalen ST   */
/* Auflîsungen vorgegeben. Ist der Bildschirm       */
/* grîûer (TT oder Karten) muû ein neuer Puffer     */
/* allokiert werden, dabei kînnen u.U. 32kB ver-    */
/* schwendet werden.                                */
{
    int workout[57];
    int xp,yp,pa;
    size_t bytes;
    
    vq_extnd(handle,0,workout);
    xp=workout[0]+1;
    yp=workout[1]+1;
    vq_extnd(handle,1,workout);
    pa=workout[4];
    
    buffer.fd_wdwidth=(xp+16)/16; 
    bytes=(long)buffer.fd_wdwidth*2*(long)yp*(long)pa;
    if(bytes<=SCREENSIZE)
        buffer.fd_addr=scbuf;
    else
    {
        buffer.fd_addr=malloc(bytes);
        sys_speicher=1;
    }
    if(buffer.fd_addr==NULL)
    {
        form_alert(1,"[3][ |Leider ist der Speicher|zu knapp][ Schade ]");
        return(FALSE);
    }
    buffer.fd_w=xp;
    buffer.fd_h=yp;
    buffer.fd_stand=1;
    buffer.fd_nplanes=pa;
    return(TRUE);
} /* buffer_init */

void handle_buffer(int f)
/* Speichert oder restauriert den Bildschirm    */
/* Als fauler Mensch verwende ich die Flags von */
/* form_dial().                                 */
{
    int p[10];

    graf_mouse(M_OFF,0);
    vs_clip(handle,0,p);

    p[0]=p[1]=p[4]=p[5]=0;
    p[2]=p[6]=max_x;
    p[3]=p[7]=max_y;

    if(f==FMD_START)
    {
        vro_cpyfm(handle,S_ONLY,p,&schirm,&buffer); 
    }
    else
    {
        vro_cpyfm(handle,S_ONLY,p,&buffer,&schirm); 
    }
    graf_mouse(M_ON,0);
} /* handle_buffer */

void check_fs(void)
/* HÑlt die "Erlaubnisse" auf dem laufenden */
{
    int style,n,k;

    style=0;
    if(dialog[HELL].ob_state & CROSSED)
        style |= 2; 
    if(dialog[KURSIV].ob_state & CROSSED)
        style |= 4; 
    if(dialog[FETT].ob_state & CROSSED)
        style |= 1; 
    if(dialog[OUTLINE].ob_state & CROSSED)
        style |= 16; 
    if(dialog[GROSS].ob_state & SELECTED)
        n=10;
    else if(dialog[KLEIN].ob_state & SELECTED)
        n=9;
    else
        n=8;
    if(dialog[KONTAKT].ob_state & CHECKED) k=15;
    else k=14;

    if(style==font.style && n==font.n && k==font.k)
    {
        if(dialog[START].ob_state & DISABLED)
        {
            dialog[START].ob_state &= ~DISABLED;
            dialog[FLERNEN].ob_state |= DISABLED;
            objc_draw(dialog,FLERNENB,2,xdial,ydial,wdial,hdial);
            objc_draw(dialog,STARTB,2,xdial,ydial,wdial,hdial);
        }
    }
    else
    {
        if(dialog[FLERNEN].ob_state & DISABLED)
        {
            dialog[FLERNEN].ob_state &= ~DISABLED;
            dialog[START].ob_state |= DISABLED;
            objc_draw(dialog,FLERNENB,2,xdial,ydial,wdial,hdial);
            objc_draw(dialog,STARTB,2,xdial,ydial,wdial,hdial);
        }
    }

} /* check_fs */

void g_main(void)
/* Die Hauptschleife!               */
/* Der Dialog wird hier verwaltet.  */
{

    int mx,my,lw,lh,mb,mk;
    int e;
    int first=TRUE;
    int i;
    
    Done=FALSE;
        
    if(!buffer_init()) return;
    vsf_interior(handle,1);
    vsf_color(handle,0);
    vsf_style(handle,0);
    vswr_mode(handle,MD_REPLACE);
    vsf_perimeter(handle,0);

    wind_update(BEG_MCTRL);
    wind_update(BEG_UPDATE);

    if(_app)
        bild_laden();
    else
        dialog[BLADEN].ob_state |= DISABLED;
    handle_buffer(FMD_START); 
    
    form_dial(FMD_GROW,0,0,0,0,xdial,ydial,wdial,hdial);
    dialog[RMENU].ob_flags |= HIDETREE;
    objc_draw(dialog,0,4,xdial,ydial,wdial,hdial);
    v_show_c(handle,0);
    graf_mouse(ARROW,NULL);
    while(!Done)
    {
        e=form_do(dialog,0) & 0x7fff; 
        if(e==START || e==FLERNEN)
        {
            if(!push_button(dialog,e,xdial,ydial,wdial,hdial))
                continue;
        }
        von=dialog[VON].ob_spec.obspec.character;
        bis=dialog[BIS].ob_spec.obspec.character;
        switch(e)
        {
            case VONR: case VONV: case BISR: case BISV:
                if(e==VONR) von--;
                else if(e==VONV) von++;
                else if(e==BISR) bis--;
                else if(e==BISV) bis++;
                
                if(von<1) von=1;
                else if(von>254) von=254;
                if(bis<=von) bis=von+1;
                if(bis<2) bis=2;
                else if(bis>255) bis=255;
                dialog[VON].ob_spec.obspec.character=von;
                dialog[BIS].ob_spec.obspec.character=bis;
                objc_draw(dialog,VON,1,xdial,ydial,wdial,hdial);
                objc_draw(dialog,BIS,1,xdial,ydial,wdial,hdial);
                continue;
            case GROSS: case KLEIN: case MINI:
                mb=1; while(mb) graf_mkstate(&mx,&my,&mb,&mk);
                check_fs();
                continue;
            case FETT: case HELL: case KURSIV: case OUTLINE:
                if(dialog[e].ob_state & CROSSED)
                    dialog[e].ob_state &= ~CROSSED;
                else
                    dialog[e].ob_state |= CROSSED;
                objc_draw(dialog,e,1,xdial,ydial,wdial,hdial);
                mb=1; while(mb) graf_mkstate(&mx,&my,&mb,&mk);
                check_fs();
                continue;
            case OPTIONEN:
                dialog[e].ob_state |= SELECTED;
                objc_draw(dialog,e,1,xdial,ydial,wdial,hdial);
                if(zbp==0)
                    dialog[TEXTSEHE].ob_state |= DISABLED;
                else
                    dialog[TEXTSEHE].ob_state &= ~DISABLED;
                i=do_submenu(dialog,RMENU);
                dialog[e].ob_state &= ~SELECTED;
                objc_draw(dialog,e,1,xdial,ydial,wdial,hdial);
                switch(i)
                {
                    case USEVDI:
                        dialog[USELA].ob_state &= ~CHECKED;
                        dialog[USEVDI].ob_state |= CHECKED;
                        dialog[BLADEN].ob_state |= DISABLED;
                        break;
                    case USELA:
                        dialog[USEVDI].ob_state &= ~CHECKED;
                        dialog[USELA].ob_state |= CHECKED;
                        if(_app)
                            dialog[BLADEN].ob_state &= ~DISABLED;
                        break;
                    case LOESCHEN: case BUENDIG: 
                    case TEXTMISC: case KONTAKT:
                        if(dialog[i].ob_state & CHECKED)
                            dialog[i].ob_state &= ~CHECKED;
                        else
                            dialog[i].ob_state |= CHECKED;
                        if(dialog[LOESCHEN].ob_state & CHECKED)
                            loeschen=TRUE;
                        else
                            loeschen=FALSE;
                        if(dialog[BUENDIG].ob_state & CHECKED)
                            buendig=TRUE;
                        else
                            buendig=FALSE;
                        if(i==KONTAKT)check_fs();
                        break;
                    case TEXTSEHE:
                        show_text();
                        break;
                    case BLADEN:
                        if(bild_laden())
                            handle_buffer(FMD_START); 
                        else
                            handle_buffer(FMD_FINISH);
                        objc_draw(dialog,0,4,xdial,ydial,wdial,hdial);
                        break;
                    default:
                        break;
                }
                continue;
            case RMOVE:
                fly_form_do(dialog);
                continue;

            case START:
                if(dialog[USELA].ob_state & CHECKED)
                {
                    use_linea=TRUE;
                    if(first)
                    {
                        first=FALSE;
                        linea_init();
                    }
                }
                else
                {
                    use_linea=FALSE;
                }
                handle_buffer(FMD_FINISH);
                graf_mouse(POINT_HAND,NULL);
                for(mb=0;!mb;graf_mkstate(&mx,&my,&mb,&mk));
                graf_rubbox(mx,my,8,8,&lw,&lh);
                graf_mouse(ARROW,NULL);
                graf_mouse(M_OFF,NULL);
                if(!(dialog[TEXTMISC].ob_state & CHECKED))
                    zbp=0; 
                vsl_color(handle,0);
                scan_screen(mx,my,mx+lw-1,my+lh-1);
                vsl_color(handle,1);
                graf_mouse(M_ON,NULL);
                show_text();
                break;
            case FLERNEN:
                if(dialog[USELA].ob_state & CHECKED)
                {
                    use_linea=TRUE;
                    if(first)
                    {
                        first=FALSE;
                        linea_init();
                    }
                }
                else
                {
                    use_linea=FALSE;
                }
                if(dialog[KONTAKT].ob_state & CHECKED) font.k=15;
                else font.k=14;
                font.style=0;
                if(dialog[HELL].ob_state & CROSSED)
                    font.style |= 2; 
                if(dialog[KURSIV].ob_state & CROSSED)
                    font.style |= 4; 
                if(dialog[FETT].ob_state & CROSSED)
                    font.style |= 1; 
                if(dialog[OUTLINE].ob_state & CROSSED)
                    font.style |= 16; 
                if(dialog[GROSS].ob_state & SELECTED)
                    font.n=10;
                else if(dialog[KLEIN].ob_state & SELECTED)
                    font.n=9;
                else
                    font.n=8;
                vst_point(handle,font.n,&font.w,&font.h,&font.cw,&font.ch);
                vst_effects (handle,font.style);
                font_info();    
                graf_mouse(M_OFF,NULL);
                init_font();
                objc_draw(wait,0,1,xwait,ywait,wwait,hwait);
                objc_offset(wait,LERNCHAR,&mx,&my);
                lerne_satz(mx,my);
                handle_buffer(FMD_FINISH);
                dialog[START].ob_state &= ~DISABLED;
                dialog[FLERNEN].ob_state |= DISABLED;
                objc_draw(dialog,0,4,xdial,ydial,wdial,hdial);
                graf_mouse(M_ON,NULL);
                break;
            case HILFE:
                help[0].ob_x=dialog[0].ob_x;
                help[0].ob_y=dialog[0].ob_y;;
                objc_draw(help,0,1,xdial,ydial,wdial,hdial);
                i=form_do(help,0);
                help[i].ob_state &= ~SELECTED;
                objc_draw(dialog,0,4,xdial,ydial,wdial,hdial);
                break;
            case RINFO:
                info[0].ob_x=dialog[0].ob_x;
                info[0].ob_y=dialog[0].ob_y;;
                objc_draw(info,0,1,xdial,ydial,wdial,hdial);
                i=form_do(info,0);
                info[i].ob_state &= ~SELECTED;
                objc_draw(dialog,0,4,xdial,ydial,wdial,hdial);
                break;
            case ENDE:
                Done=TRUE;
                break;
            default:
                break;
        }
        dialog[e].ob_state &= ~SELECTED;
        objc_draw(dialog,e,1,xdial,ydial,wdial,hdial);
    }
    
    handle_buffer(FMD_FINISH);
    finito:;
    wind_update(END_UPDATE);
    wind_update(END_MCTRL);
    if(sys_speicher) free(buffer.fd_addr);
}/* g_main */

