/**************************************/
/*                                    */
/*    TFU.C ist PD-SOURCE-SOFTWARE    */
/*                                    */
/*         by G. Gerhardt             */
/*            Siekhammer 34           */
/*            4930  Detmold           */
/*                                    */
/**************************************/

#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>

#include "tfu.h"

#define MAXDIRLEN 256

typedef struct direntry
{
    char attr[2];
    char time[2];
    char date[2];
    char size[4];
    char name[14];
} DIRENTRY;

typedef struct filebox
{
    char path[128];
    DIRENTRY dir[MAXDIRLEN];
    int len,pos;
} FILEBOX;

extern int gl_apid;

int cheight;
int infomode,drvchng;
long savt,savg;
OBJECT *tfubox;
char dta[44];
FILEBOX *fb1,*fb2;

numtostr(n,s,l,f)
long n;
char *s;
int l,f;
{
    char h[2];

    if (n>=10L) numtostr(n/10L,s,l-1,f);
    else
        while (l-->1)
            if (f) strcat(s," ");
            else strcat(s,"0");
    h[0]=n%10L+'0';h[1]=0;
    strcat(s,h);
}

dattostr(d,s)
int d;
char *s;
{
    char h[9];
    int t;

    t=d&0x1f;
    h[0]=t/10+'0';
    h[1]=t%10+'0';
    h[2]='.';
    d>>=5;
    t=d&0xf;
    h[3]=t/10+'0';
    h[4]=t%10+'0';
    h[5]='.';
    d>>=4;
    t=((d&0x7f)+80)%100;
    h[6]=t/10+'0';
    h[7]=t%10+'0';
    h[8]=0;
    strcat(s,h);
}

timtostr(d,s)
int d;
char *s;
{
    char h[9];
    int t;

    t=(d&0x1f)<<1;
    h[5]=':';
    h[6]=t/10+'0';
    h[7]=t%10+'0';
    d>>=5;
    t=d&0x3f;
    h[2]=':';
    h[3]=t/10+'0';
    h[4]=t%10+'0';
    d>>=6;
    t=d&0x1f;
    h[0]=t/10+'0';
    h[1]=t%10+'0';
    strcat(s,h);
}

sort(fb)
FILEBOX *fb;
{
    int i,j,m;
    DIRENTRY d;

    for (i=0;i<fb->len-1;i++)
    {
        m=i;
        for (j=i+1;j<fb->len;j++)
        {
            if (fb->dir[j].attr[1]&0x10)
                if (!(fb->dir[m].attr[1]&0x10)) m=j;
                else
                {
                    if (strcmp(fb->dir[j].name,fb->dir[m].name)<0) m=j;
                }
            else
                if (!(fb->dir[m].attr[1]&0x10))
                    if (strcmp(fb->dir[j].name,fb->dir[m].name)<0) m=j;
        }
        if (m!=i)
        {
            d=fb->dir[i];fb->dir[i]=fb->dir[m];fb->dir[m]=d;
        }
    }
}

patch(fname)
char *fname;
{
    int i,j;
    char *f;

    i=0;
    f=fname;
    while (*f!='.' && *f) i++,f++;
    if (*f)
    {
        while (i<8)
        {
            for (j=i+4;j>=i;j--) fname[j+1]=fname[j];
            i++,*f++=' ';
        }
        while (*f) i++,f++;
    }
    while (i<12) i++,*f++=' ';
    *f=0;
}

long etv_critic()
{
    return -1L;
}

change_etv()
{
    static long etvsav=0L;
    long *etv=(long *)0x404L;

    if (etvsav)
    {
        *etv=etvsav;
        etvsav=0L;
    }
    else
    {
        etvsav=*etv;
        *etv=(long)etv_critic;
    }
}

long test_b()
{
    return *(int *)0x4a6L<2;
}

char get_drives()
{
    long map;
    char d,c;
    int i;

    d='A';
    map=Drvmap()>>1;
    if (Supexec(test_b)) map&=~1;
    for (c='B';c<='G';c++)
    {
        i=c+DRIVE-'A';
        if (map&1)
        {
            if (c!='B') d=c;
            tfubox[i].ob_state&=~DISABLED;
            tfubox[i+FBOX2-FBOX1].ob_state&=~DISABLED;
        }
        else
        {
            tfubox[i].ob_state|=DISABLED;
            tfubox[i+FBOX2-FBOX1].ob_state|=DISABLED;
        }
        map>>=1;
    }
    return d;
}

set_files(fb)
FILEBOX *fb;
{
    int l,h;
    OBJECT *fob,*iob;
    DIRENTRY *d;
    char fn[14];

    if (fb==fb1) h=FBOX1;
    else h=FBOX2;
    for (l=0;l<10;l++)
    {
        fob=&tfubox[FILE+h-FBOX1+l];
        iob=&tfubox[INFOLINE+l];
        if (fb->pos+l<fb->len)
        {
            d=&fb->dir[fb->pos+l];
            fob->ob_state=d->attr[0];
            if (d->attr[1]&0x10)
            {
                strcpy(fob->ob_spec,"    ");
                if (h==FBOX1) strcpy(iob->ob_spec,"        ");
            }
            else
            {
                strcpy(fob->ob_spec,"     ");
                if (h==FBOX1)
                {
                    *(char *)iob->ob_spec=0;
                    numtostr(*(long *)d->size,iob->ob_spec,8,1);
                }
            }
            if (h==FBOX1)
            {
                strcat(iob->ob_spec,"    ");
                dattostr(*(int *)d->date,iob->ob_spec);
                strcat(iob->ob_spec,"    ");
                timtostr(*(int *)d->time,iob->ob_spec);
            }
            strcpy(fn,d->name);
            patch(fn);
            strcat(fob->ob_spec,fn);
        }
        else
        {
            fob->ob_state=NORMAL;
            strcpy(fob->ob_spec,"");
            if (h==FBOX1) strcpy(iob->ob_spec,"");
        }
    }
}

show_file(fb,l)
FILEBOX *fb;
int l;
{
    int h,x,y,dh;
    OBJECT *ob;

    if (fb==fb1) h=FBOX1;
    else h=FBOX2;
    ob=&tfubox[FILE+h-FBOX1+l];
    ob->ob_state^=SELECTED;
    objc_offset(tfubox,FILE+h-FBOX1+l,&x,&y);
    dh=0;
    if (l==0) y++,dh=1;
    if (l==9) dh=1;
    objc_draw(tfubox,h,MAX_DEPTH,
        x+1,y,ob->ob_width-2,cheight-dh);
}

show_dir(fb,pflag,iflag)
FILEBOX *fb;
int pflag,iflag;
{
    int h,x,y;
    OBJECT *ob;

    set_files(fb);
    if (fb==fb1) h=FBOX1;
    else h=FBOX2;
    graf_mouse(M_OFF);
    if (pflag)
    {
        ob=&tfubox[PATH+h-FBOX1];
        objc_offset(tfubox,PATH+h-FBOX1,&x,&y);
        objc_draw(tfubox,h,MAX_DEPTH,
            x+1,y+1,ob->ob_width-2,cheight-2);
    }
    ob=&tfubox[FILE+h-FBOX1];
    objc_offset(tfubox,FILE+h-FBOX1,&x,&y);
    objc_draw(tfubox,h,MAX_DEPTH,
        x+1,y+1,ob->ob_width-2,cheight*10-2);
    if (infomode)
    {
        ob=&tfubox[IBOX];
        objc_offset(tfubox,IBOX,&x,&y);
        objc_draw(tfubox,IBOX,MAX_DEPTH,
            x,y+cheight,ob->ob_width,ob->ob_height-(cheight<<1)-1);
        if (iflag)
        {
            ob=&tfubox[FREELINE];
            objc_offset(tfubox,FREELINE,&x,&y);
            objc_draw(tfubox,IBOX,MAX_DEPTH,
                x,y,ob->ob_width,cheight);
        }
    }
    graf_mouse(M_ON);
}

get_dfree()
{
    long b[4];
    char *s;

    s=(char *)tfubox[FREELINE].ob_spec;
    strcpy(s,"A:");*s=fb1->path[0];
    Dfree(b,*s-'A'+1);
    numtostr((b[0]*b[2]*b[3])>>10L,s,5,1);
    strcat(s,"KB Free ");
    numtostr(((b[1]-b[0])*b[2]*b[3])>>10L,s,5,1);
    strcat(s,"KB Used");
}

get_dir(fb)
FILEBOX *fb;
{
    int found,cnt,i;
    char *d,p[128];

    cnt=0;
    Fsetdta(dta);
    strcpy(p,fb->path);
    strcat(p,"*.*");
    found=Fsfirst(p,0x10);
    while (found==0 && cnt<MAXDIRLEN)
    {
        if (strcmp(dta+30,".") && strcmp(dta+30,".."))
        {
            d=&fb->dir[cnt].attr[0];
            *d++=NORMAL;
            for (i=21;i<44;i++) *d++=dta[i];
            cnt++;
        }
        found=Fsnext();
    }
    fb->len=cnt;
    fb->pos=0;
    sort(fb);
}

release()
{
    int x,y,m,k;

    do graf_mkstate(&x,&y,&m,&k); while (m&1);
}

int stopped()
{
    int x,y,m,k;

    graf_mkstate(&x,&y,&m,&k);
    if (objc_find(tfubox,GG,0,x,y)==GG) return 1;
    return 0;
}

head(path)
char *path;
{
    char *m;

    m=path+strlen(path)-2;
    while (*m!='\\') m--;
    *++m=0;
}

int get_sel()
{
    int i;

    for (i=0;i<fb1->len;i++)
        if (fb1->dir[i].attr[0]&SELECTED) return i;
    return -1;
}

de_sel(n)
int n;
{
    fb1->dir[n].attr[0]^=SELECTED;
    n-=fb1->pos;
    if (n>=0 && n<=9)
        show_file(fb1,n);
}

redraw_fb1()
{
    int x,y,w,h;

    objc_offset(tfubox,FBOX1,&x,&y);
    x+=tfubox[FBOX2].ob_width+1;
    y-=4;
    objc_offset(tfubox,FBOX2,&w,&h);
    w+=tfubox[FBOX2].ob_width-x+4;
    h=tfubox[FBOX1].ob_height+8;
    objc_draw(tfubox,ROOT,MAX_DEPTH,x,y,w,h);
}

redraw_title()
{
    int x,y;

    objc_offset(tfubox,TFU,&x,&y);
    objc_draw(tfubox,TFU,MAX_DEPTH,
        x,y,tfubox[TFU].ob_width,cheight);
}

redraw_gg()
{
    int x,y;

    objc_offset(tfubox,GG,&x,&y);
    objc_draw(tfubox,GG,MAX_DEPTH,
        x,y,tfubox[GG].ob_width,cheight);
}

save_title(s)
char *s;
{
    TEDINFO *t;

    savt=tfubox[TFU].ob_spec;
    tfubox[TFU].ob_spec=(long)s;
    t=(TEDINFO *)tfubox[GG].ob_spec;
    savg=t->te_ptext;
    t->te_ptext=(long)"STOP";
    redraw_title();
    redraw_gg();
}

restore_title()
{
    tfubox[TFU].ob_spec=savt;
    ((TEDINFO *)tfubox[GG].ob_spec)->te_ptext=savg;
    redraw_title();
    redraw_gg();
}

int rename(n)
int n;
{
    int bt;
    char fn[14],pno[128],pnn[128];
    DIRENTRY *d;

    d=&fb1->dir[n];
    tfubox[FBOX1].ob_flags|=HIDETREE;
    tfubox[FBOX2].ob_flags|=HIDETREE;
    tfubox[BBOX].ob_flags|=HIDETREE;
    tfubox[RBOX].ob_flags|=EDITABLE|DEFAULT|EXIT;
    bt=form_do(tfubox,RBOX)&0x7fff;
    if (bt==RBOX) objc_change(tfubox,RBOX,0,0,0,640,400,OUTLINED,1);
    tfubox[FBOX1].ob_flags&=~HIDETREE;
    tfubox[FBOX2].ob_flags&=~HIDETREE;
    tfubox[BBOX].ob_flags&=~HIDETREE;
    tfubox[RBOX].ob_flags&=~(EDITABLE|DEFAULT|EXIT);
    if (bt==GG) return 1;
    strcpy(fn,((TEDINFO *)tfubox[RBOX].ob_spec)->te_ptext);
    if (!strcmp(fn,d->name)) return 0;
    strcpy(pno,fb1->path);
    strcpy(pnn,pno);
    strcat(pno,d->name);
    strcat(pnn,fn);
    return Frename(0,pno,pnn);
}

int copy(n)
int n;
{
    int h1,h2;
    char *buffer,pn1[128],pn2[128];
    long rlen,wlen,bsize,err;
    DIRENTRY *d;

    d=&fb1->dir[n];
    bsize=Malloc(-1L)-32768L;
    if (bsize<1024L) return 1;
    strcpy(pn1,fb1->path);
    strcat(pn1,d->name);
    h1=Fopen(pn1,0);
    if (h1<0) return 2;
    strcpy(pn2,fb2->path);
    strcat(pn2,d->name);
    h2=Fcreate(pn2,0);
    if (h2<0)
    {
        Fclose(h1);
        return 3;
    }
    buffer=(char *)Malloc(bsize);
    if (buffer<=0L)
    {
        Fclose(h1);
        Fclose(h2);
        return 1;
    }
    do
    {
        wlen=0L;
        rlen=Fread(h1,bsize,buffer);
        if (rlen>0L)
        {
            wlen=Fwrite(h2,rlen,buffer);
            if (wlen!=rlen) wlen=-1L;
        }
    }
    while (rlen>0L && wlen>0L);
    Mfree(buffer);
    Fclose(h1);
    err=Fclose(h2);
    if (rlen<0L) return 4;
    if (wlen<0L) return 5;
    return err;
}

do_info()
{
    tfubox[BBOX].ob_flags|=HIDETREE;
    tfubox[FBOX2].ob_flags|=HIDETREE;
    tfubox[IBOX].ob_flags&=~HIDETREE;
    tfubox[INFO].ob_state&=~SELECTED;
    tfubox[EXIT].ob_flags&=~DEFAULT;
    tfubox[FBOX1].ob_width+=tfubox[FBOX2].ob_x-tfubox[FBOX1].ob_x;
    if (drvchng) get_dfree();
    drvchng=0;
    redraw_fb1();
    infomode=1;
}

do_close(bt)
int bt;
{
    FILEBOX *fb;

    if (bt==CLOSE) fb=fb1;
    else fb=fb2;
    if (strlen(fb->path)>3)
    {
        head(fb->path);
        get_dir(fb);
        show_dir(fb,1,0);
    }
    release();
}

do_up(bt)
int bt;
{
    FILEBOX *fb;

    if (bt==UP) fb=fb1;
    else fb=fb2;
    if (fb->pos)
    {
        fb->pos-=10;
        show_dir(fb,0,0);
    }
}

do_down(bt)
int bt;
{
    FILEBOX *fb;

    if (bt==DOWN) fb=fb1;
    else fb=fb2;
    if (fb->pos+10<fb->len)
    {
        fb->pos+=10;
        show_dir(fb,0,0);
    }
}

do_file(bt)
int bt;
{
    FILEBOX *fb;
    int l;

    if (bt<=FILE+9)
    {
        fb=fb1;
        l=bt-FILE;
    }
    else
    {
        fb=fb2;
        l=bt-FBOX2+FBOX1-FILE;
    }
    if (fb->pos+l<fb->len)
    {
        if (fb->dir[fb->pos+l].attr[1]&0x10)
        {
            strcat(fb->path,fb->dir[fb->pos+l].name);
            strcat(fb->path,"\\");
            get_dir(fb);
            show_dir(fb,1,0);
        }
        else
        {
            if (bt<=FILE+9)
            {
                fb->dir[fb->pos+l].attr[0]^=SELECTED;
                show_file(fb,l);
            }
        }
    }
    release();
}

do_drive(bt)
int bt;
{
    FILEBOX *fb;

    if (bt<=DRIVE+6)
    {
        fb=fb1;
        bt-=DRIVE;
    }
    else
    {
        fb=fb2;
        bt-=FBOX2-FBOX1+DRIVE;
    }
    fb->path[0]=bt+'A';
    fb->path[3]=0;
    get_dir(fb);
    if (infomode) get_dfree();
    else if (fb==fb1) drvchng=1;
    show_dir(fb,1,1);
    release();
}

do_ok(bt)
int bt;
{
    tfubox[BBOX].ob_flags&=~HIDETREE;
    tfubox[FBOX2].ob_flags&=~HIDETREE;
    tfubox[IBOX].ob_flags|=HIDETREE;
    tfubox[OK].ob_state&=~SELECTED;
    tfubox[EXIT].ob_flags|=DEFAULT;
    tfubox[FBOX1].ob_width=tfubox[FBOX2].ob_width;
    redraw_fb1();
    infomode=0;
}

int do_delrencpy(str1,str2,fkt)
char *str1,*str2;
int fkt;
{
    int n,err;
    char s[128],pn[128],fn[14],a[80];

    if ((n=get_sel())<0) return 0;
    *s=0;
    save_title(s);
    if (fkt==1)
        tfubox[RBOX].ob_flags&=~HIDETREE;
    do
    {
        strcpy(fn,fb1->dir[n].name);
        strcpy(s,str1);
        if (fkt==1)
            strcpy(((TEDINFO *)tfubox[RBOX].ob_spec)->te_ptext,fn);
        else
        {
            strcat(s,fb1->path);
            strcat(s,fn);
        }
        redraw_title();
        switch (fkt)
        {
            case 0:
                strcpy(pn,fb1->path);
                strcat(pn,fn);
                err=Fdelete(pn);
                break;
            case 1:
                err=rename(n);
                break;
            case 2:
                err=copy(n);
                break;
        }
        if (fkt==1 && err==1) break;
        if (err)
        {
            strcpy(a,str2);
            strcat(a,"'");
            strcat(a,fn);
            strcat(a,"' !][ CONT | STOP ]");
            if (form_alert(1,a)==2) break;
        }
        de_sel(n);
        if (stopped()) break;
        n=get_sel();
    }
    while (n>=0);
    if (fkt==1)
        tfubox[RBOX].ob_flags|=HIDETREE;
    restore_title();
    return 1;
}

do_delete()
{
    int pos;

    if (do_delrencpy("DELETING ","[1][|Can't delete ",0))
    {
        pos=fb1->pos;
        get_dir(fb1);
        if (pos<fb1->len) fb1->pos=pos;
        show_dir(fb1,0,0);
        drvchng=1;
        if (!strcmp(fb1->path,fb2->path))
        {
            pos=fb2->pos;
            get_dir(fb2);
            if (pos<fb2->len) fb2->pos=pos;
            show_dir(fb2,0,0);
        }
    }
    objc_change(tfubox,DELETE,0,0,0,640,400,OUTLINED,1);
}

do_rename()
{
    int pos;

    if (do_delrencpy("","[1][|Can't rename ",1))
    {
        pos=fb1->pos;
        get_dir(fb1);
        if (pos<fb1->len) fb1->pos=pos;
        show_dir(fb1,0,0);
        if (!strcmp(fb1->path,fb2->path))
        {
            pos=fb2->pos;
            get_dir(fb2);
            if (pos<fb2->len) fb2->pos=pos;
            show_dir(fb2,0,0);
        }
    }
    objc_change(tfubox,RENAME,0,0,0,640,400,OUTLINED,1);
}

do_copy()
{
    int pos;

    if (!strcmp(fb1->path,fb2->path))
        form_alert(1,"[1][|Can't copy to same directory][ CANCEL ]");
    else
    {
        if (do_delrencpy("COPYING ","[1][|Can't copy ",2))
        {
            pos=fb2->pos;
            get_dir(fb2);
            if (pos<fb2->len) fb2->pos=pos;
            show_dir(fb2,0,0);
            if (fb1->path[0]==fb2->path[0]) drvchng=1;
        }
    }
    objc_change(tfubox,COPY,0,0,0,640,400,OUTLINED,1);
}

do_tfubox()
{
    int x,y,w,h,bt;

    Supexec(change_etv);
    get_drives();
    get_dir(fb1);
    get_dir(fb2);
    drvchng=1;
    wind_update(BEG_UPDATE);
    form_center(tfubox,&x,&y,&w,&h);
    form_dial(FMD_START,0,0,0,0,x,y,w,h);
    set_files(fb1);
    set_files(fb2);
    objc_draw(tfubox,ROOT,MAX_DEPTH,x,y,w,h);
    do
    {
        bt=form_do(tfubox,0)&0x7fff;
        if (bt==INFO) do_info();
        if (bt==CLOSE || bt==FBOX2-FBOX1+CLOSE) do_close(bt);
        if (bt==UP || bt==FBOX2-FBOX1+UP) do_up(bt);
        if (bt==DOWN || bt==FBOX2-FBOX1+DOWN) do_down(bt);
        if (bt>=FILE && bt<=FILE+9 ||
            bt>=FBOX2-FBOX1+FILE && bt<=FBOX2-FBOX1+FILE+9)
            do_file(bt);
        if (bt>=DRIVE && bt<=DRIVE+6 ||
            bt>=FBOX2-FBOX1+DRIVE && bt<=FBOX2-FBOX1+DRIVE+6)
            if (!(tfubox[bt].ob_state&DISABLED)) do_drive(bt);
        if (bt==OK) do_ok();
        if (bt==DELETE) do_delete();
        if (bt==RENAME) do_rename();
        if (bt==COPY) do_copy();
    }
    while (bt!=EXIT);
    form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
    tfubox[bt].ob_state&=~SELECTED;
    wind_update(END_UPDATE);
    Supexec(change_etv);
}

mesag()
{
    int buff[8];

    while (1)
    {
        evnt_mesag(buff);
        if (*buff==AC_OPEN) do_tfubox();
    }
}

main()
{
    appl_init();
    if (!rsrc_load("TFU.RSC"))
    {
        form_alert(1,"[1][|TFU.RSC not found !][ ABORT ]");
    }
    else
    {
        rsrc_gaddr(R_TREE,TFUBOX,&tfubox);
        menu_register(gl_apid,"  The File Utility");
        fb1=(FILEBOX *)Malloc((long)sizeof(FILEBOX));
        fb2=(FILEBOX *)Malloc((long)sizeof(FILEBOX));
        strcpy(fb1->path,"A:\\");
        fb1->path[0]=get_drives();
        strcpy(fb2->path,fb1->path);
        ((TEDINFO *)tfubox[PATH].ob_spec)->te_ptext=
            (long)fb1->path;
        ((TEDINFO *)tfubox[FBOX2-FBOX1+PATH].ob_spec)->te_ptext=
            (long)fb2->path;
        cheight=tfubox[PATH].ob_height;
    }
    mesag();
}


