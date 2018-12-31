#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mydefs.h>

char buf[4096];
char spath[128];
char fpath[128];
char files[128][14];
long fleng[128],l;

static char *sext  = "\\*.SND";
static char *slash = "\\\0";
static char *crlf = "\015\012";

long getline(
        char    *dest,
        char    *buf,
        long    start,
        long    max)
        {
        long p,q;
        
        q = 0L;
        p = start;
        while((p<max)&&(*(buf+p)<0x20))
                ++p;
        while((p<max)&&(*(buf+p)>0x1f))
                {
                *(dest+q)=*(buf+p);
                ++p;
                ++q;
                }
        *(dest+q) = 0;
        return(p);
        }

void main(void)
        {
        int fd;
        DTA *d;
        unt u;
        uln     r;

        puts("NBRSS V1.0 - with Turbo C 2.0");
        puts("NewBell Random Sound Selector");
        puts("BY Gregory Mathias Lemperle-Kerr");

        if (Fsfirst("NEWBELL.DAT",0)>=0)
                {
                d=Fgetdta();
                l=d->d_length;
                puts("Using NEWBELL.DAT for paths...");
                fd=Fopen("NEWBELL.DAT",1);
                Fread(fd,l,buf);
                Fclose(fd);
                getline(spath,buf,0,l);
                }
        else
                strcpy(spath,"C:\AUTO\SOUNDS\DEFAULT.SND");
        for(r=strlen(spath);r>0;r--)
                if (*(spath+r)=='\\')
                        break;
        *(spath+r)=0;
        strcpy(fpath,spath);
        strcat(spath,sext);
        puts(spath);
        u = 0;
        if ((fd=Fsfirst(spath,0))>=0) while (fd>=0)
                {
                d=Fgetdta();
                strncpy(files[u],d->d_fname,14);
                fleng[u]=d->d_length;
                fd = Fsnext();
                ++u;
                }
        else
                {
                puts("NO DIGITIZED SOUND FILES FOUND!\007");
                return;
                }
        r=(Random()+Gettime())%u;
        puts(files[r]);
        puts("Writing...");
        if(Fsfirst("NEWBELL.DAT",0)>=0)
                Fdelete("NEWBELL.DAT");
        strcat(fpath,slash);
        strcat(fpath,files[r]);
        strcat(fpath,crlf);
        fd=Fcreate("NEWBELL.DAT",0);
        Fclose(fd);
        fd=Fopen("NEWBELL.DAT",WRITE);
        Fwrite(fd,strlen(fpath),fpath);
        Fclose(fd);
        }
