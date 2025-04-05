/**************************************/
/*                                    */
/*    TGS.C ist PD-SOURCE-SOFTWARE    */
/*                                    */
/*         by G. Gerhardt             */
/*            Siekhammer 34           */
/*            4930  Detmold           */
/*                                    */
/**************************************/

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>

#include "tgs.h"

#define LIN 30

int handle,gl_wchar,gl_hchar;
int contrl[12],intin[128],intout[128],ptsin[128],ptsout[128],buff[57];
int mfd1[10],mfd2[10];
int xpos,ypos;
int msgbuff[8];
int ret;
int mx,my,ms,mk;
int quit,abort;
int textlen,modif;
int deskis;
char tgspath[128];
char path[128],fname[13];
char msg[128];
char lines[LIN][61];
char texte[10000];
char params[10][61];
int lastpar=PAFIRST;
int lasttgs=THE;

OBJECT *menu,*dtop,*ftop,*editbox,*parmbox,*tgsbox;

initdesk()
{
    int x,y,w,h;

    v_show_c(handle,0);
    if (deskis==1) return;
    wind_update(BEG_UPDATE);
    Bconout(2,27);Bconout(2,'f');
    wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);
    dtop->ob_x=x-1;
    dtop->ob_y=y;
    dtop->ob_width=w+2;
    dtop->ob_height=h;
    wind_set(0,WF_NEWDESK,dtop,0,0);
    form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
    graf_mouse(ARROW);
    menu_bar(menu,1);
    wind_update(END_UPDATE);
    deskis=1;
}

gemdesk()
{
    int x,y,w,h;

    v_show_c(handle,0);
    wind_update(BEG_UPDATE);
    Bconout(2,27);Bconout(2,'f');
    wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);
    ftop->ob_x=x-1;
    ftop->ob_y=y;
    ftop->ob_width=w+2;
    ftop->ob_height=h;
    wind_set(0,WF_NEWDESK,ftop,0,0);
    form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
    graf_mouse(ARROW);
    menu_bar(menu,1);
    wind_update(END_UPDATE);
    menu_bar(menu,0);
    deskis=2;
}

tosdesk()
{
    v_show_c(handle,0);
    v_hide_c(handle);
    Bconout(2,27);Bconout(2,'e');
    if (deskis==3) return;
    Bconout(2,27);Bconout(2,'E');
    deskis=3;
}

int suffix(p,s)
register char *p,*s;
{
    register int l;

    l=strlen(p)-strlen(s);
    if (l<0) return 0;
    p+=l;
    while (*s)
        if ((0xdf & *p++)!=*s++) return 0;
    return 1;
}

newdesk(prg)
register char *prg;
{
    if (suffix(prg,"TOS")) tosdesk();
    else
    if (suffix(prg,"TTP")) tosdesk();
    else
    if (suffix(prg,"PRG")) gemdesk();
    else
    if (suffix(prg,"APP")) gemdesk();
}

int message(d,s)
int d;
char *s;
{
    register int b;

    v_show_c(handle,0);
    b=form_alert(d,s);
    if (deskis==3) v_hide_c(handle);
    return b;
}

char *tail(p)
register char *p;
{
    register char *m;

    m=p;
    do if (*p=='\\') m=p+1; while (*p++);
    return m;
}

head(p)
char *p;
{
    *tail(p)=0;
}

int fsel(p)
register char *p;
{
    int ok;

    strcat(p,"*.*");
    while (!fsel_input(p,fname,&ok));
    head(p);
    strcat(p,fname);
    return ok;
}

multi()
{
    register int event;

    do
    {
        event = evnt_multi(MU_BUTTON | MU_MESAG | MU_TIMER | MU_KEYBD,
                1,1,1,
                0,0,0,0,0,
                0,0,0,0,0,
                msgbuff,1000,0,&mx,&my,&ms,&mk,&ret,&ret);
        if (event & MU_BUTTON && !wind_find(mx,my))
            hndl_button();
        if (event & MU_MESAG)
            hndl_menu();
        if (event & MU_TIMER)
            hndl_tgs();
    }
    while (!quit);
    gemdesk();
    v_clsvwk(handle);
    appl_exit();
}

setstat(ob,s)
int ob,s;
{
    register OBJECT *o;
    int x,y;

    o=dtop+ob;
    o->ob_state=s;
    objc_offset(dtop,ob,&x,&y);
    wind_update(BEG_UPDATE);
    form_dial(FMD_FINISH,0,0,0,0,x-3,y-3,o->ob_width+5,o->ob_height+5);
    wind_update(END_UPDATE);
}

blockmv(s,h,d)
register int s,h,d;
{
    int xy[8];

    s=ypos+s*gl_hchar;
    d=ypos+d*gl_hchar;
    h*=gl_hchar;
    xy[0]=xpos;xy[1]=s;xy[2]=xpos+60*gl_wchar-1;xy[3]=s+h-1;
    xy[4]=xpos;xy[5]=d;xy[6]=xy[2];xy[7]=d+h-1;
    graf_mouse(M_OFF);
    vro_cpyfm(handle,S_ONLY,xy,mfd1,mfd2);
    graf_mouse(M_ON);
}

setlines(ln)
register int ln;
{
    register int i;

    for (i=0;i<10;i++)
        ((TEDINFO *)editbox[EDFIRST+i].ob_spec)->te_ptext=(long)lines[i+ln];
}

cpylines(f,t,i,e)
register int f,t,i,e;
{
    while (f!=e)
    {
        strcpy(lines[t],lines[f]);
        f+=i;t+=i;
    }
}

char *nextline(p)
register char *p;
{
    while (*p++);
    return p;
}

char *nextblock(p)
register char *p;
{
    p++;
    do p=nextline(p); while (*p);
    return p+1;
}

char *findlines(ob)
register int ob;
{
    register char *p;

    ob-=FIRST-'A';
    p=texte;
    while (*p && *p!=ob) p=nextblock(p);
    return p;
}

getlines(ob,en)
int ob;
register char *en;
{
    register char *p;
    register int i;

    for (i=0;i<LIN;i++) lines[i][0]=0;
    *en=0;
    p=findlines(ob);
    if (*p++)
    {
        strcpy(en,p);
        p=nextline(p);
        i=0;
        while (*p)
        {
            strcpy(lines[i++],p);
            p=nextline(p);
        }
    }
}

putlines(ob,en)
int ob;
char *en;
{
    register char *p,*q,*t;
    register int i,mo=0,tr=0;

    p=findlines(ob);
    if (*p)
    {
        q=nextblock(p);
        t=texte+textlen;
        while (q<t) *p++=*q++;
        textlen=p-texte;
    }
    p=texte+textlen-1;
    *p++=ob-FIRST+'A';
    strcpy(p,en);
    p=nextline(p);
    *p=0;
    mo=*en;
    for (i=0;i<LIN;i++)
    {
        if (lines[i][0])
        {
            if (p-texte>9900) tr=1;
            else
            {
                mo=1;
                strcpy(p,lines[i]);
                p=nextline(p);
                *p=0;
            }
        }
    }
    if (mo) *++p=0;
    else
    {
        p-=2;
        *p=0;
    }
    p++;
    textlen=p-texte;
    if (tr) form_alert(1,"[1][|   Buffer full :| Input truncated !][ OK ]");
}

setspecs()
{
    register int ob;
    register char *p;

    for (ob=FIRST;ob<FIRST+30;ob++)
    {
        p=findlines(ob);
        dtop[ob].ob_spec=*p?(long)(p+1):(long)"";
    }
}

edit(ob)
int ob;
{
    int x,y,w,h;
    register int bt,ln,idx,n;
    register char *en;

    editbox[EDEDIT].ob_state=SELECTED|OUTLINED;
    editbox[EDDELETE].ob_state=OUTLINED;
    editbox[EDINSERT].ob_state=OUTLINED;
    editbox[EDUP].ob_flags&=~HIDETREE;
    editbox[EDDOWN].ob_flags&=~HIDETREE;
    en=(char *)((TEDINFO *)editbox[EDNAME].ob_spec)->te_ptext;
    getlines(ob,en);
    setlines(ln=0);
    wind_update(BEG_UPDATE);
    form_center(editbox,&x,&y,&w,&h);
    objc_offset(editbox,EDFIRST,&xpos,&ypos);
    form_dial(FMD_START,0,0,0,0,x,y,w,h);
    objc_draw(editbox,ROOT,MAX_DEPTH,x,y,w,h);
    editbox[EDUP].ob_flags|=HIDETREE;
    if (*en) idx=EDFIRST;
    else idx=EDNAME;
    do
    {
        bt=form_do(editbox,idx)&0x7fff;
        if (bt==EDUP)
        {
            objc_change(editbox,bt,0,x,y,w,h,SELECTED,1);
            blockmv(0,9,1);
            setlines(--ln);
            objc_draw(editbox,EDFIRST,0,x,y,w,h);
            if (!ln)
                editbox[EDUP].ob_flags|=HIDETREE;
            if (ln==LIN-11)
                editbox[EDDOWN].ob_flags&=~HIDETREE;
            objc_change(editbox,bt,0,x,y,w,h,NORMAL,1);
        }
        if (bt==EDDOWN)
        {
            objc_change(editbox,bt,0,x,y,w,h,SELECTED,1);
            blockmv(1,9,0);
            setlines(++ln);
            objc_draw(editbox,EDFIRST+9,0,x,y,w,h);
            if (ln==LIN-10)
                editbox[EDDOWN].ob_flags|=HIDETREE;
            if (ln)
                editbox[EDUP].ob_flags&=~HIDETREE;
            objc_change(editbox,bt,0,x,y,w,h,NORMAL,1);
        }
        if (bt>=EDFIRST && bt<=EDFIRST+9)
        {
            idx=bt;
            n=bt-EDFIRST;
            if (editbox[EDDELETE].ob_state&SELECTED)
            {
                cpylines(ln+n+1,ln+n,1,LIN);
                strcpy(lines[LIN-1],"");
                if (n<9)
                    blockmv(n+1,9-n,n);
                objc_draw(editbox,EDFIRST+9,0,x,y,w,h);
            }
            if (editbox[EDINSERT].ob_state&SELECTED)
            {
                cpylines(LIN-2,LIN-1,-1,ln+n-1);
                strcpy(lines[ln+n],"");
                if (n<9)
                    blockmv(n,9-n,n+1);
                objc_draw(editbox,bt,0,x,y,w,h);
            }
            release();
        }
    }
    while (bt!=EDOK && bt!=EDCANCEL);
    if (bt==EDOK)
    {
        modif=1;
        putlines(ob,en);
        setspecs();
    }
    form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
    editbox[bt].ob_state=NORMAL;
    wind_update(END_UPDATE);
}

edparm()
{
    int x,y,w,h;
    register int bt,i;
    register TEDINFO *t;
    char para[10][61];

    for (i=0;i<10;i++)
    {
        strcpy(para[i],params[i]);
        t=(TEDINFO *)parmbox[PAFIRST+i].ob_spec;
        t->te_ptext=(long)para[i];
    }
    wind_update(BEG_UPDATE);
    form_center(parmbox,&x,&y,&w,&h);
    form_dial(FMD_START,0,0,0,0,x,y,w,h);
    objc_draw(parmbox,ROOT,MAX_DEPTH,x,y,w,h);
    do
    {
        bt=form_do(parmbox,lastpar)&0x7fff;
        if (bt>=PAFIRST && bt<=PAFIRST+9)
        {
            parmbox[lastpar].ob_flags&=~EDITABLE;
            lastpar=bt;
            parmbox[lastpar].ob_flags|=EDITABLE;
            release();
        }
        if (bt==PAFSEL)
        {
            if (fsel(path))
                strncpy(para[lastpar-PAFIRST],path,60);
            parmbox[bt].ob_state=OUTLINED;
            objc_draw(parmbox,ROOT,MAX_DEPTH,x,y,w,h);
            head(path);
        }
    }
    while (bt!=PACANCEL && bt!=PAOK);
    if (bt==PAOK)
    {
        modif=1;
        for (i=0;i<10;i++) strcpy(params[i],para[i]);
    }
    form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
    parmbox[bt].ob_state=NORMAL;
    wind_update(END_UPDATE);
}

release()
{
    evnt_button(1,1,0,&ret,&ret,&ret,&ret);
}

movebt(ob)
int ob;
{
    OBJECT *o;
    int x,y,w,h,xo,yo,ot;
    register char *p,*q,c;

    o=dtop+ob;
    objc_offset(dtop,ob,&xo,&yo);
    objc_offset(dtop,FIRST,&x,&y);
    objc_offset(dtop,FIRST+29,&w,&h);
    w+=o->ob_width-x;
    h+=o->ob_height-y;
    wind_update(BEG_UPDATE);
    graf_dragbox(o->ob_width,o->ob_height,xo,yo,
        x,y,w,h,&ret,&ret);
    wind_update(END_UPDATE);
    graf_mkstate(&mx,&my,&ms,&mk);
    ot=objc_find(dtop,ROOT,MAX_DEPTH,mx,my);
    if (ot>=FIRST && ot!=ob)
    {
        modif=1;
        p=findlines(ob);
        q=findlines(ot);
        if (*p)
        {
            if (*q)
            {
                c=*p;*p=*q;*q=c;
            }
            else *p=ot-FIRST+'A';
        }
        else
            if (*q) *q=ob-FIRST+'A';
        setspecs();
        setstat(ob,NORMAL);
        setstat(ot,NORMAL);
    }
}

numtostr(n,s)
register int n;
char *s;
{
    char c[2];

    if (n>9) numtostr(n/10,s);
    c[0]=n%10+'0';
    c[1]=0;
    strcat(s,c);
}

int read(h,c)
int h;
char *c;
{
    static char buf[512];
    static int ptr1=0,ptr2=0;

    if (ptr1==ptr2)
    {
        if ((ptr2=Fread(h,512L,buf))<=0) return 0;
        ptr1=0;
    }
    *c=buf[ptr1++];
    return 1;
}

int readln(h,s,maxlen)
int h;
register char *s;
register int maxlen;
{
    char c[2];

    *s=0;
    c[1]=0;
    while (read(h,c))
    {
        if (*c=='\n') return 0;
        if (*c!='\r')
        {
            if (!maxlen) return 1;
            strcat(s,c);
            maxlen--;
        }
    }
    return 2;
}

load()
{
    register int h,err,lin,lnr;
    register char *p,*mp;

    textlen=1;
    *texte=0;
    h=Fopen("TGS.SET",0);
    if (h<0) return;
    mp=p=texte;
    err=readln(h,p,1);
    lnr=1;
    if (err==2)
    {
        *texte=0;
        return;
    }
    while (!err)
    {
        if (*p>='A' && *p<='^')
        {
            p++;
            err=readln(h,p,20);
            lnr++;
            if (err) break;
            lin=0;
            do
            {
                if (lin++>LIN) err=1;
                else
                {
                    p=nextline(p);
                    err=readln(h,p,60);
                    lnr++;
                    if (p-texte>9900) err=1;
                }
            }
            while (!err && *p);
            if (err) break;
            p++;
            mp=p;
        }
        else if (*p>='0' && *p<='9')
        {
            err=readln(h,params[*p-'0'],60);
            lnr++;
            if (err) break;
        }
        else if (*p)
        {
            err=1;
            break;
        }
        err=readln(h,p,1);
        lnr++;
        if (err==2)
        {
            err=0;
            break;
        }
    }
    if (err)
    {
        strcpy(msg,"[1][| Error in TGS.SET line ");
        numtostr(lnr,msg);
        strcat(msg,"][ OK ]");
        form_alert(1,msg);
    }
    *mp++=0;
    textlen=mp-texte;
    Fclose(h);
}

newline(h)
int h;
{
    Fwrite(h,2L,"\r\n");
}

save()
{
    register int h;
    char c,fn[128];
    register char *p;
    strcpy(fn,tgspath);
    strcat(fn,"TGS.SET");
    h=Fcreate(fn,0);
    if (h>=0)
    {
        p=texte;
        while (*p)
        {
            Fwrite(h,1L,p++);
            newline(h);
            Fwrite(h,(long)strlen(p),p);
            p=nextline(p);
            newline(h);
            while (*p)
            {
                Fwrite(h,(long)strlen(p),p);
                p=nextline(p);
                newline(h);
            }
            newline(h);
            p++;
        }
        for (c=0;c<10;c++)
            if (params[c][0])
            {
                c+='0';
                Fwrite(h,1L,&c);
                c-='0';
                newline(h);
                Fwrite(h,(long)strlen(params[c]),params[c]);
                newline(h);
            }
        Fclose(h);
        modif=0;
    }
    else form_alert(1,"[1][| Can't create TGS.SET !][ OK ]");
}

char *skipblnk(p)
register char *p;
{
    while (*p==' ') p++;
    return p;
}

char *skiplbl(p)
register char *p;
{
    while (*p>='0' && *p<='9') p++;
    return skipblnk(p);
}

char *getnpar(s,p,n)
register char *s,*p;
int n;
{
    strncpy(s,params[*p-'0'],n);
    return s+strlen(s);
}

getfile(s,n)
char *s;
int n;
{
    int ok;

    if (deskis==3) gemdesk();
    wind_update(BEG_UPDATE);
    ok=fsel(path);
    wind_update(END_UPDATE);
    if (ok) strncpy(s,path,n);
    else abort=1;
    head(path);
}

char *transfm(s,p,n,c)
register char *s,*p;
register int n;
char c;
{
    char *m;

    if (*p=='$' && p[1]>='=' && p[1]<='z')
    {
        *s++=*p++;
        *s++=*p++;
        n=0;
    }
    while (*p && *p!=c && n)
    {
        if (*p=='$' && ((p[1]>='0' && p[1]<='9') || p[1]=='$'))
        {
            if (p[1]=='$')
            {
                getfile(s,n);
                if (abort) return p;
                n-=strlen(s);
                s+=strlen(s);
                p+=2;
            }
            else
            {
                m=s;
                s=getnpar(s,++p,n);
                n-=s-m;
                p++;
            }
        }
        else
        {
            *s++=*p++;
            n--;
        }
    }
    *s=0;
    return p;
}

char *getncmd(s,p,n)
register char *s,*p;
int n;
{
    p=skipblnk(p);
    return transfm(s,p,n,' ');
}

int checkal(s,p)
register char *s;
char **p;
{
    register int i;

    if (*s++!='[') return 0;
    if (*s<'0' || *s++>'3') return 0;
    if (*s++!=']') return 0;
    for (i=0;i<2;i++)
    {
        if (*s++!='[') return 0;
        while (*s && *s!=']') s++;
        if (*s++!=']') return 0;
    }
    *p=s;
    return 1;
}

char *tstcond(p,cond)
register char *p;
register int *cond;
{
    register int neg=0;
    char f1[128],f2[128],*nextp;
    register int h1,h2;
    unsigned int t1[2],t2[2];
    unsigned long z1,z2;

    *cond=0;
    if (*p=='\'') return p;
    *cond=1;
    if (*p=='$')
    {
        p++;
        if (*p=='!')
        {
            neg=1;
            p++;
        }
        switch (*p++)
        {
            case 'e':case 'E':
                p=getncmd(f1,p,127);
                if (abort) return p;
                h1=Fopen(f1,0);
                if (h1<0) *cond=neg;
                else *cond=1^neg;
                Fclose(h1);
                break;
            case 'm':case 'M':
                p=getncmd(f1,p,127);
                if (abort) return p;
                p=getncmd(f2,p,127);
                if (abort) return p;
                h1=Fopen(f1,0);
                if (h1<0)
                {
                    *cond=neg;
                    break;
                }
                h2=Fopen(f2,0);
                if (h2<0)
                {
                    Fclose(h1);
                    *cond=1^neg;
                    break;
                }
                Fdatime(t1,h1,0);
                Fdatime(t2,h2,0);
                Fclose(h1);
                Fclose(h2);
                z1=(t1[1]<<16L)+t1[0];
                z2=(t2[1]<<16L)+t2[0];
                *cond=(z1>z2)^neg;
                break;
            case 'i':case 'I':
                p=skipblnk(p);
                if (checkal(p,&nextp))
                {
                    strncpy(f1,p,nextp-p);
                    *cond=(message(1,f1)==1)^neg;
                    p=nextp;
                }
                else
                {
                    message(1,"[1][|Invalid alert string !][ OK ]");
                    abort=1;
                    return p;
                }
                break;
            default:
                p-=2;
                if (neg) p--;
        }
    }
    return p;
}

getnum(l,q)
register char *l,*q;
{
    register int n=9;

    while (*q>='0' && *q<='9' && n--) *l++=*q++;
    *l=0;
}

char *findlabel(q,lbl)
register char *q,*lbl;
{
    char lin[10];

    while (*q)
    {
        getnum(lin,q);
        if (!strcmp(lin,lbl)) return q;
        q=nextline(q);
    }
    return 0L;
}

int cont(s)
register char *s;
{
    register char c;

    while (*s) Bconout(2,*s++);
    do c=Crawcin(); while (c!='Y' && c!='y' && c!='N' && c!='n' && c!='\r');
    Bconout(2,c);
    return c=='N' || c=='n';
}

int getabo(d)
int d;
{
    if (deskis==3) return cont("\r\nContinue ? (Y/N) ");
    return message(d,"[0][Continue ?][YES|NO]")==2;
}

char *exec_cmd(p,q)
register char *p,*q;
{
    register long err;
    char lbl[10],prg[128],par[128],nam[128],*dummy;
    register int l;

    p=getncmd(prg,p,127);
    if (abort) return p;
    if (*prg=='$')
    {
        switch (prg[1])
        {
            case 'a':case 'A':
                p=skipblnk(p);
                if (checkal(p,&dummy)) message(1,p);
                else message(1,"[1][|Invalid alert string !][ OK ]");
                return nextline(p);
            case 'g':case 'G':
                p=skipblnk(p);
                getnum(lbl,p);
                if (l=strlen(lbl))
                {
                    q=findlabel(q,lbl);
                    if (q) return q;
                }
                else l=9;
                strcpy(msg,"[1][|Label '");
                strncat(msg,p,l);
                strcat(msg,"' not found !][ ABORT ]");
                message(1,msg);
                abort=1;
                return p;
            case 'w':case 'W':
                abort=getabo(1);
                return nextline(p);
            case 's':case 'S':
                abort=1;
                return p;
            case '=':
                p=skipblnk(p);
                if (*p>='0' && *p<='9')
                {
                    getfile(params[*p-'0'],60);
                    if (abort) return p;
                    modif=1;
                }
                else
                {
                    message(1,"[1][|Only $=0 .. $=9 allowed !][ ABORT ]");
                    abort=1;
                    return p;
                }
                return nextline(p);
            default:
                strcpy(msg,"[1][|Invalid command '$");
                strncat(msg,prg+1,1);
                strcat(msg,"'][ ABORT ]");
                message(1,msg);
                abort=1;
                return p;
        }
    }
    transfm(par,p,127,'\0');
    if (abort) return p;
    if (*par) *par=strlen(par)-1;
    newdesk(prg);
    if (strlen(prg)>2)
    {
        strcpy(nam,prg);
        if (nam[1]==':')
        {
            if (nam[0]>='A' && nam[0]<='Z') Dsetdrv(nam[0]-'A');
            if (nam[0]>='a' && nam[0]<='z') Dsetdrv(nam[0]-'a');
            strcpy(nam,nam+2);
        }
        strcpy(prg,tail(nam));
        head(nam);
        Dsetpath(nam);
    }
    if (strlen(prg)>4) err=Pexec(0,prg,par,"");
    else err=-1L;
    if (err<0L)
    {
        strcpy(msg,"[1][|Can't execute the program|'");
        strncat(msg,prg,28);
        strcat(msg,"'][ ABORT | CONTINUE ]");
        if (message(1,msg)==1) abort=1;
    }
    return nextline(p);
}

exec_script(ob)
int ob;
{
    register char *p,*q;
    int cond;

    abort=0;
    p=findlines(ob);
    if (!*p) return;
    p=nextline(p+1);
    q=p;
    while (!abort && *p)
    {
        Dsetdrv(tgspath[0]-'A');
        Dsetpath(tgspath);
        p=skiplbl(p);
        p=tstcond(p,&cond);
        if (abort) cond=0;
        if (cond) p=exec_cmd(p,q);
        else p=nextline(p);
        if (Cconis())
        {
            do Crawcin(); while (Cconis());
            if (!abort) abort=getabo(2);
        }
    }
    initdesk();
}

hndl_button()
{
    register int ob;

    ob=objc_find(dtop,ROOT,MAX_DEPTH,mx,my);
    if (ob==EXECUTE || ob==EDIT || ob==MOVE)
    {
        if (!dtop[ob].ob_state)
        {
            if (dtop[EXECUTE].ob_state) setstat(EXECUTE,NORMAL);
            if (dtop[EDIT].ob_state) setstat(EDIT,NORMAL);
            if (dtop[MOVE].ob_state) setstat(MOVE,NORMAL);
            setstat(ob,SELECTED|OUTLINED);
        }
        return;
    }
    if (ob>=FIRST && dtop[MOVE].ob_state)
    {
        movebt(ob);
        return;
    }
    if (ob==PARAMS || ob==SAVE || ob==QUIT || ob>=FIRST)
    {
        setstat(ob,SELECTED|OUTLINED);
        do
        {
            graf_mkstate(&mx,&my,&ms,&mk);
        }
        while (ob==objc_find(dtop,ROOT,MAX_DEPTH,mx,my) && ms);
        if (ms)
        {
            setstat(ob,NORMAL);
            return;
        }
    }
    else return;
    switch (ob)
    {
        case PARAMS:
            edparm();
            break;
        case SAVE:
            save();
            break;
        case QUIT:
            if (!modif || form_alert(1,"[2][| Really quit ?][ YES | NO ]")==1)
                quit=1;
            break;
        default:
            if (dtop[EXECUTE].ob_state) exec_script(ob);
            else edit(ob);
    }
    setstat(ob,NORMAL);
}

hndl_menu()
{
    int x,y,w,h;

    wind_update(BEG_UPDATE);
    form_center(tgsbox,&x,&y,&w,&h);
    form_dial(FMD_START,0,0,0,0,x,y,w,h);
    objc_draw(tgsbox,ROOT,MAX_DEPTH,x,y,w,h);
    form_do(tgsbox,0);
    tgsbox[TGSOK].ob_state&=~SELECTED;
    form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
    menu_tnormal(menu,DESK,1);
    wind_update(END_UPDATE);
}

hndl_tgs()
{
    int topw;

    wind_update(BEG_UPDATE);
    wind_get(0,WF_TOP,&topw,&ret,&ret,&ret);
    if (!topw)
    {
        dtop[lasttgs].ob_state^=DISABLED;
        objc_draw(dtop,lasttgs,0,0,0,640,400);
        if (++lasttgs>SHELL) lasttgs=THE;
    }
    wind_update(END_UPDATE);
}

main()
{
    register int i;
    register TEDINFO *t,*u;

    appl_init();
    if (rsrc_load("TGS.RSC"))
    {
        load();
        handle=graf_handle(&gl_wchar,&gl_hchar,&ret,&ret);
        v_opnvwk(buff,&handle,buff);
        rsrc_gaddr(R_TREE,MENU,&menu);
        rsrc_gaddr(R_TREE,DTOP,&dtop);
        rsrc_gaddr(R_TREE,FTOP,&ftop);
        rsrc_gaddr(R_TREE,EDITBOX,&editbox);
        rsrc_gaddr(R_TREE,PARMBOX,&parmbox);
        rsrc_gaddr(R_TREE,TGSBOX,&tgsbox);
        dtop[EXECUTE].ob_state=SELECTED|OUTLINED;
        setspecs();
        for (i=0;i<10;i++)
        {
            t=(TEDINFO *)editbox[EDFIRST+i].ob_spec;
            t->te_ptmplt=(long)
            "____________________________________________________________";
            t->te_tmplen=61;
            t->te_pvalid=(long)"X";
            t->te_txtlen=61;
            u=(TEDINFO *)parmbox[PAFIRST+i].ob_spec;
            u->te_ptmplt=t->te_ptmplt;
            u->te_tmplen=61;
            u->te_pvalid=t->te_pvalid;
            u->te_txtlen=61;
        }
        tgspath[0]=Dgetdrv()+'A';
        tgspath[1]=':';
        Dgetpath(tgspath+2,Dgetdrv()+1);
        strcat(tgspath,"\\");
        strcpy(path,tgspath);
        initdesk();
        multi();
        Dsetdrv(tgspath[0]-'A');
        Dsetpath(tgspath);
    }
    else
    {
        form_alert(1,"[1][| TGS.RSC not found !][ QUIT ]");
        appl_exit();
    }
}

