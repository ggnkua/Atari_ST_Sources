/**************************************/
/*                                    */
/* EXAUTOCP.C ist PD-SOURCE-SOFTWARE  */
/*                                    */
/*         by G. Gerhardt             */
/*            Siekhammer 34           */
/*            4930  Detmold           */
/*                                    */
/**************************************/

#include <osbind.h>

int handle,errnum,recursiv,input=0,echo=1;
char line[128];
char *datfile;

wait()
{
    long i;

    for (i=0L;i<300000L;i++);
}

writestr(s)
char *s;
{
    while (*s) Cconout(*s++);
}

writenum(i)
int i;
{
    if (i<0) return(0);
    if (i>9) writenum(i/10);
    Cconout(i%10+'0');
}

char readchar()
{
    char c;
    static int len=0,bufptr=0;
    static char buffer[512];

    do
    {
        errnum=len;
        if (bufptr==len)
        {
            errnum=len=(int)Fread(handle,512L,buffer);
            bufptr=0;
        }
        c=buffer[bufptr++];
        if (errnum>0) Cconout(c);
        if (c>='a' && c<='z') c-='a'-'A';
    }
    while ((c==' ' || c==13 || c==9) && errnum>0);
    return c;
}

readcmd()
{
    int linptr=0,conlptr=2;
    char c,conl[82];

    if (input)
    {
        conl[0]=80;
        writestr("\033e");
        Cconrs(conl);
        writestr("\033f");
        writestr("\r\n");
        while (conl[1]--)
        {
            c=conl[conlptr++];
            if (c>='a' && c<='z') c-='a'-'A';
            if (c!=' ' && c!=9)
                line[linptr++]=c;
        }
        line[linptr]=0;
        errnum=1;
    }
    else
    {
        do line[linptr++]=readchar();
        while (errnum>0 && line[linptr-1]!=10 && linptr<128);
        line[linptr-1]=0;
        if (linptr==128) errnum=-1;
    }
}

errmsg(num)
int num;
{
    switch (num)
    {
        case 33:writestr("Datei nicht gefunden");break;
        case 34:writestr("Disk/Ordner nicht gefunden");break;
        case 36:writestr("Ordner ist nicht leer");break;
        case 50:writestr("Datei existiert schon");break;
        case 51:writestr("Disk voll");break;
        case 52:writestr("Fehler in ");writestr(datfile);break;
        case 53:writestr("Unbekanntes Kommando");break;
        case 54:writestr(datfile);writestr(" nicht gefunden");break;
        default:writestr("Fehler ");writenum(num);
    }
    writestr(" !\r\n");
}

head(p)
char *p;
{
    char *m;

    m=p;
    while (*p)
        if (*p=='\\' || *p==':') m=++p;
        else p++;
    *m=0;
}

pathcreate(p)
char *p;
{
    char *m;
    int z=0;

    m=p;
    while (*m)
    {
        if (*m=='\\')
        {
            if (z++)
            {
                *m=0;
                Dcreate(p);
                *m='\\';
            }
        }
        m++;
    }
}

cprm(copy,f1,f2)
int copy;
char *f1,*f2;
{
    char dta[44],*m1,*m2;
    int err;

    Fsetdta(dta);
    err=Fsfirst(copy?f1:f2,0x10);
    if (!err && !strcmp(dta+30,"."))
    {
        err=Fsnext();
        if (!err && !strcmp(dta+30,".."))
            err=Fsnext();
    }
    while (!err)
    {
        head(f1);
        strcat(f1,dta+30);
        head(f2);
        if (copy) pathcreate(f2);
        strcat(f2,dta+30);
        if (dta[21]&0x10)
        {
            if (copy)
            {
                if (echo)
                {
                    writestr("Erzeuge ");
                    writestr(f2);
                    writestr("\r\n");
                }
                errnum=Dcreate(f2);
                if (errnum==-36) errnum=0;
                if (errnum && echo) errmsg(-errnum);
            }
            if (recursiv)
            {
                m1=f1+strlen(f1);
                m2=f2+strlen(f2);
                strcat(f1,"\\*.*");
                strcat(f2,"\\*.*");
                cprm(copy,f1,f2);
                Fsetdta(dta);
                *m1=*m2=0;
            }
            if (!copy)
            {
                if (echo)
                {
                    writestr("L”sche ");
                    writestr(f2);
                    writestr("\r\n");
                }
                errnum=Ddelete(f2);
                if (errnum && echo) errmsg(-errnum);
            }
        }
        else
        {
            if (copy)
            {
                if (echo)
                {
                    writestr("Kopiere ");
                    writestr(f1);
                    writestr(" nach ");
                    writestr(f2);
                    writestr("\r\n");
                }
                filecopy(f1,f2);
                if (errnum<0 && echo) errmsg(-errnum);
            }
            else
            {
                if (echo)
                {
                    writestr("L”sche ");
                    writestr(f2);
                    writestr("\r\n");
                }
                errnum=Fdelete(f2);
                if (errnum && echo) errmsg(-errnum);
            }
        }
        err=Fsnext();
    }
}

filecopy(from,to)
char *from,*to;
{
    int handle1,handle2;
    long count1,count2;
    static char copybuf[9216];

    errnum=handle1=Fopen(from,0);
    if (handle1>0)
    {
        handle2=Fopen(to,0);
        if (handle2<0)
            errnum=handle2=Fcreate(to,0);
        else
        {
            Fclose(handle2);
            errnum=handle2=-50;
        }
        if (handle2>0)
        {
            do
            {
                count1=Fread(handle1,9216L,copybuf);
                if (count1>0L)
                    if (count1>(count2=Fwrite(handle2,count1,copybuf)))
                        if (count2>=0L) count1=-51L;
                        else count1=count2;
            }
            while (count1>0L);if (count1<0L) errnum=(int)count1;
            Fclose(handle2);
        }
        Fclose(handle1);
    }
}

main(argc,argv)
int argc;
char *argv[];
{
    int err,d,copy,last;
    long map;
    char src[256],dst[256],*sm,*dm;

    writestr("\033E>>>>> EXTENDED AUTOCOPY <<<<<\r\n");
    writestr(">> (C) 1987 by G. Gerhardt <<\r\n");
    if (argc>1) datfile=argv[1];
    else datfile="A:\\AUTO\\EXAUTOCP.DAT";
    handle=Fopen(datfile,0);
    if (handle<0)
    {
        errmsg(54);
        wait();
        exit(1);
    }
    strcpy(src,"A:\\");
    strcpy(dst,"C:\\");
    map=Drvmap()>>3;
    for (d='D';d<='Z';d++)
    {
        if (map&1) *dst=d;
        map>>=1;
    }
    do
    {
        readcmd();
        err=errnum;
        if (err<0)
        {
            errmsg(52);
            wait();
            exit(1);
        }
        if (err>0)
        {
            copy=0;
            switch (*line)
            {
                case 'S':
                    strcpy(src,line+1);
                    break;
                case 'D':
                    strcpy(dst,line+1);
                    break;
                case 'C':
                    copy=1;
                case 'R':
                    last=strlen(line)-1;
                    if (line[last]=='\\')
                    {
                        line[last]=0;
                        recursiv=1;
                    }
                    else recursiv=0;
                    sm=src+strlen(src);
                    dm=dst+strlen(dst);
                    strcat(src,line+1);
                    strcat(dst,line+1);
                    cprm(copy,src,dst);
                    *sm=*dm=0;
                    break;
                case 'I':
                    input=1;
                    break;
                case 'E':
                    echo=1;
                    break;
                case 'Q':
                    echo=0;
                    break;
                case 0:
                    input=0;
                    break;
                default:
                    errmsg(53);
            }
        }
    }
    while (err);
    Fclose(handle);
}

