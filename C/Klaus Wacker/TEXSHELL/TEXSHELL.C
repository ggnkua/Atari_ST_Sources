/*
     tools TeX Shell
     von Klaus Wacker 
     6. M„rz 1988
     
     Grundstruktur und Teile des 
     Codes stammen aus der
     \begin{quote}
     Pro Fortran 77 Shell 1.11
     von Daniel Roth
     1987 sinccom software
     Public Domain
     \end{quote}
*/

#include <define.h>
#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>
#include <string.h>

#include "texshell.h"

#define RSCNAME "texshell.rsc"

#define NOGEM 0
#define GEM 1
#define WARTENICHT 0
#define WARTE 1

#define DESK 0

#define LORES 0
#define MIDRES 1
#define HIRES 2
#define menu_text(A) &(((TEDINFO *)menu_ptr[A].ob_spec)->te_ptext)

#define NTEXTE 30
#define WOLLENSI 0
#define WIRKLICH 1
#define NKLOESCH 2
#define NKUMBEN 3
#define KOPIEVON 4
#define KOPIENAC 5
#define NKSPEIC 6
#define BLOKEDI 7
#define ERSTTEX 8
#define KANNEDI1 9
#define KANNEDI2 10
#define NIZUKOP 11
#define KOPIJN1 12
#define NACH 13
#define KOPIJANE 14
#define NKOPIER 15
#define NKANNOP 16
#define ZIELEX 17
#define NZIELOP 18
#define FEHLSCHL 19
#define NZURAUM 20
#define BITASTE 21
#define KEINAPPL 22
#define ANDRAUFL 23
#define RSCFEHLT 24
#define RSCKAPUT 25
#define PLAIN 26
#define PLAING 27
#define LPLAIN 28
#define LPLAING 29

int     contrl[12];
int     intin[128];
int     ptsin[128];
int     intout[128];
int     ptsout[128];

int     int_in[11];
int     int_out[57];
int     msgbuff[8];
int     handle;
int     xdesk,ydesk,wdesk,hdesk;
int     infox,infoy,infow,infoh;
int     editx,edity,editw,edith;
int     ttpx,ttpy,ttpw,ttph;
int     dummy;

OBJECT     *desktop;
OBJECT     *menu_ptr;
OBJECT     *info_ptr;
OBJECT     *edit_ptr;
OBJECT     *ttp_ptr;

FILE     *fopen(),*fp;

typedef struct dta {
     char reserved[20];   /* reserved for OS use */
     char attributes;     /* file's attributes */
     int time_stamp;      /* file's time stamp */
     int date_stamp;      /* file's date stamp */
     long file_size;      /* file's size */
     char file_name[13];  /* file's name and extension */
} DTA; 

DTA *dta_ptr;

typedef struct datime {
     int time;
     int date;
} DATIME;

DATIME TeX_start,TeX_stop,file_datime;

char     quellpfad[80],quellname[13],arbeit[150];
char     prgpfad[80],prgname[13];
char     fmtpfad[80],fmtname[13];
char     lokpfad[80],lokname[13];
char     altpfad[80],altname[13];
char     logpfad[80],auxpfad[80],outputpfad[80];
char     editorpfad[80];
char     texpfad[80];
char     dvipfad[80];
char     shellpfad[80];
char     endung[10];
char     text[100];
char     neuername[15];
char     cur_driv[3];

char *texte[NTEXTE+1];

int     ausgewaehlt=NO;
int     texdone=NO;
int     tex_und_dvi;
int     plain;
int     latex;
int     eigenfmt;
int     deutsch;
int     texwarte;
int     log_edit;

main()
{
     anfang();
     menu();
     ende();
}

menu()
{
     int     nochmal=YES;
     
     do
     {
          evnt_mesag(msgbuff);
          if (msgbuff[0]=MN_SELECTED)
          {
               switch(msgbuff[3])
               {
                    case DESKTITL:
                         switch(msgbuff[4])
                         {
                              case INFO:
                                   info();
                                   break;
                         }    
                         break;
                    case DATEI:
                         switch(msgbuff[4])
                         {
                              case AUSWAEHL:
                                   datei_auswaehlen();
                                   break;
                              case DATLOESH:
                                   loeschen();
                                   break;
                              case DATUMBEN:
                                   umbenennen();
                                   break;
                              case DATKOPIE:
                                   kopiere();
                                   break;
                              case QUIT:
                                   nochmal=NO;
                                   break;
                              case AUXRETTE:
                                   aux_rette();
                                   break;
                              case DVIRETTE:
                                   dvi_rette();
                                   break;
                              case SAUBER:
                                   sauber();
                                   break;
                         }    
                         break;
                    case AUSFUEHR:
                         switch(msgbuff[4])
                         {
                              case EDITIERE:
                                   editieren();
                                   break;
                              case ALTEDIT:
                                   alt_edit();
                                   break;
                              case DOTEX:
                                   do_TeX();
                                   break;
                              case DODVI:
                                   do_DVI();
                                   break;
                              case ANDERES:
                                   anderes();
                                   break;
                         }    
                         break;
                    case LOKALISI:
                         switch(msgbuff[4])
                         {
                              case LOKEDITO:
                                   lok_editor();
                                   break;
                              case LOKTEX:
                                   lok_TeX();
                                   break;
                              case LOKDVI:
                                   lok_DVI();
                                   break;
                              case ENVEDIT:
                                   env_edit();
                                   break;
                              case EINSTESI:
                                   einstellungen();
                                   break;
                         }    
                         break;
                    case OPTIONEN:
                         switch(msgbuff[4])
                         {
                              case PLAINOPT:
                                   t_plain();
                                   break;
                              case LATEXOPT:
                                   t_latex();
                                   break;
                              case EIGENFMT:
                                   t_eigenfmt(YES);
                                   break;
                              case DEUTSCHO:
                                   t_deutsch();
                                   break;
                              case TEXDVI:
                                   t_texdvi();
                                   break;
                              case WARTEOPT:
                                   t_texwarte();
                                   break;
                         }    
                         break;
               }
               menu_tnormal(menu_ptr,msgbuff[3],TRUE);
          }
     } while (nochmal);
}

info()
{
     form_dial(FMD_START,0,0,0,0,infox,infoy,infow,infoh);
     form_dial(FMD_GROW,
               menu_ptr[INFO].ob_x,menu_ptr[INFO].ob_y,
               menu_ptr[INFO].ob_width,menu_ptr[INFO].ob_height,
               infox,infoy,infow,infoh);
     objc_draw(info_ptr,ROOT,MAX_DEPTH,infox,infoy,infow,infoh);
     form_do(info_ptr,0);
     objc_change(info_ptr,KNOPF,0,infox,infoy,infow,infoh,NORMAL,0);
     form_dial(FMD_SHRINK,
               menu_ptr[DESKTITL].ob_x,menu_ptr[DESKTITL].ob_y,
               menu_ptr[DESKTITL].ob_width,menu_ptr[DESKTITL].ob_height,
               infox,infoy,infow,infoh);
     form_dial(FMD_FINISH,0,0,0,0,infox,infoy,infow,infoh);
}

datei_auswaehlen()
{
     int taste;
     
     fsel_caption(quellpfad,quellname,&taste,menu_text(AUSWAEHL));
     if ((taste==1)&&strlen(quellname)!=0)
     {
          ausgewaehlt=YES;
          texdone=NO;
          get_fmt();
          strcpy(altpfad,quellpfad);
     }
}

loeschen()
{
     int taste;
     
     strcpy(lokpfad,cur_driv);
     strcat(lokpfad,"\\*.*");
     strcpy(lokname,"");
     fsel_caption(lokpfad,lokname,&taste,menu_text(DATLOESH));
     if ((taste==1)&&strlen(lokname)!=0)
     {
          chop_fn(arbeit,lokpfad);
          strcat(arbeit,lokname);
          entferne(arbeit);
     }
}

char *strlcat(s1,s2,n) /* concatenate last n characters of s2 to s1 */
char *s1, *s2;
int n;
{
     int l;
     
     return( strcat(s1,&s2[ (l=strlen(s2))>n ? l-n : 0 ]));
}

entferne(name)
char name[];
{
     int pos;
     
     strcpy(text,texte[WOLLENSI]);
     strlcat(text,name,30); 
     strcat(text,texte[WIRKLICH]);
     if (form_alert(2,text)==1)
     {
          if (Fdelete(name)<0)
               form_alert(1,texte[NKLOESCH]);
     }
}

umbenennen()
{
     int taste,pos;
     
     strcpy(lokpfad,cur_driv);
     strcat(lokpfad,"\\*.*");
     strcpy(lokname,"");
     fsel_caption(lokpfad,lokname,&taste,menu_text(DATUMBEN));
     if ((taste==1)&&strlen(lokname)!=0)
     {
          strcpy(neuername,lokname);
          form_dial(FMD_START,0,0,0,0,editx,edity,editw,edith);
          form_dial(FMD_GROW,0,0,0,0,editx,edity,editw,edith);
          objc_draw(edit_ptr,ROOT,MAX_DEPTH,editx,edity,editw,edith);
          taste=form_do(edit_ptr,1);
          objc_change(edit_ptr,taste,0,editx,edity,editw,edith,NORMAL,0);
          form_dial(FMD_SHRINK,140,0,0,0,editx,edity,editw,edith);
          form_dial(FMD_FINISH,0,0,0,0,editx,edity,editw,edith);
          if (taste==EDITX)
          {
               if ((strcmp(neuername,lokname)!=NULL)&&strlen(neuername)!=0)
               {
                    pos=chop_fn(arbeit,lokpfad);
                    strcpy(&arbeit[++pos],lokname);
                    strcpy(&lokpfad[pos],neuername);
                    if (Frename(0,arbeit,lokpfad)!=0)
                         form_alert(1,texte[NKUMBEN]);
               }
          }
     }
}

kopiere()
{
     int taste,pos;
     
     strcpy(lokpfad,cur_driv);
     strcat(lokpfad,"\\*.*");
     strcpy(lokname,"");
     fsel_caption(lokpfad,lokname,&taste,texte[KOPIEVON]);
     if ((taste==1)&&strlen(lokname)!=0)
     {
          chop_fn(arbeit,lokpfad);
          strcat(arbeit,lokname);
          fsel_caption(lokpfad,lokname,&taste,texte[KOPIENAC]);
          if ((taste==1)&&strlen(lokname)!=0)
          {
               chop_fn(lokpfad,lokpfad);
               strcat(lokpfad,lokname);
               copyfile(lokpfad,arbeit);
          }
     }
}

einstellungen()
{
     if ((fp=fopen(shellpfad,"w"))==NULL)
          form_alert(1,texte[NKSPEIC]);
     else
     {
          fprintf(fp,"%s %d %s %s %s %d %d %d %d %d %d",
                    editorpfad,log_edit,texpfad,dvipfad,fmtname,
                    plain,latex,eigenfmt,deutsch,tex_und_dvi,texwarte);
          fclose(fp);
     }
}

editieren()
{
     int pos;
     
     if (!ausgewaehlt)
          datei_auswaehlen();
     if (ausgewaehlt)
     {
          pos=1;
          pos+=chop_fn(&arbeit[pos],quellpfad);
          strcpy(&arbeit[++pos],quellname);
          if (log_edit)
          {
               pos=chop_fn(lokpfad,logpfad);
               strcat(lokpfad,quellname); 
               while (lokpfad[pos] !='.' && lokpfad[pos] != '\0')
                    pos++;
               lokpfad[pos] = '\0';
               strcat(lokpfad,".LOG");
               if (Fsfirst(lokpfad,0)>=0)
               {
                    strcat(arbeit," ");
                    strcat(arbeit,lokpfad);
               }
          }
          arbeit[0]=strlen(arbeit)-1;
          if (execute(editorpfad,arbeit,GEM,WARTENICHT)<0)
               form_alert(1,texte[BLOKEDI]);
          else
               get_fmt();
     }
     texdone=NO; 
}

alt_edit()
{
     int pos,button;
     
     fsel_caption(altpfad,altname,&button,menu_text(ALTEDIT));
     if (button==1)
     { 
          pos=1;
          pos+=chop_fn(&arbeit[pos],altpfad);
          strcpy(&arbeit[++pos],altname);
          arbeit[0]=strlen(arbeit)-1;
          if (execute(editorpfad,arbeit,GEM,WARTENICHT)<0)
               form_alert(1,texte[BLOKEDI]);
     }
}

env_edit()
{
     chop_fn(&arbeit[1],texpfad);
     strcat(arbeit,"ENVIRONM.ENT");
     arbeit[0]=strlen(arbeit)-1;
     if (execute(editorpfad,arbeit,GEM,WARTENICHT)<0)
          form_alert(1,texte[BLOKEDI]);
     get_environ();
}

do_TeX()
{
     int pos;
   
     if (!ausgewaehlt)
          datei_auswaehlen();
     if (ausgewaehlt)
     {
          strcpy(arbeit," &");
          if (plain) 
          {
               if (deutsch)
                    strcat(arbeit,texte[PLAING]); 
               else 
                    strcat(arbeit,texte[PLAIN]); 
          } else 
          if (latex) 
          {
               if (deutsch)
                    strcat(arbeit,texte[LPLAING]); 
               else
                    strcat(arbeit,texte[LPLAIN]); 
          } else 
          if (eigenfmt) 
          {
               strcat(arbeit,fmtname);
          } else
               strcpy(arbeit,"");
          strcat(arbeit," ");
          pos=strlen(arbeit);
          pos+=chop_fn(&arbeit[pos],quellpfad);
          strcpy(&arbeit[++pos],quellname);
          while ((arbeit[pos]!='.')&&(arbeit[pos]!='\0')) pos++;
          strcpy(&arbeit[pos],"");
          arbeit[0]=strlen(arbeit)-1;
          /* Change \ to / */
          for (pos=1; arbeit[pos]!='\0'; pos++)
               if (arbeit[pos]=='\\') arbeit[pos]='/';
          TeX_start.date = Tgetdate();
          TeX_start.time = Tgettime();
          if (execute(texpfad,arbeit,NOGEM,texwarte)>=0)
          {
               texdone=YES;
               TeX_stop.date = Tgetdate();
               TeX_stop.time = Tgettime();
               if (tex_und_dvi)
                    do_DVI();
          }
     }
}

do_DVI()
{
     int pos,taste;

     if (!texdone)
          taste=form_alert(1,texte[ERSTTEX]);
     if (texdone||taste==2)
     {
          arbeit[0]=' ';
          pos=1;
          if (ausgewaehlt)
          {
               pos+=chop_fn(&arbeit[pos],texpfad);
               strcpy(&arbeit[++pos],quellname);
               while ((arbeit[pos]!='.')&&(arbeit[pos]!='\0')) 
                    pos++;
          }
          strcpy(&arbeit[pos],"");
          arbeit[0]=strlen(arbeit)-1;
          execute(dvipfad,arbeit,GEM,WARTENICHT);
     }
}

anderes()
{
     int pos,taste;
     char param[80];
     
     fsel_caption(prgpfad,prgname,&taste,menu_text(ANDERES));
     if ((taste==1)&&strlen(prgname)!=0)
     {
          pos=chop_fn(arbeit,prgpfad);
          strcpy(&arbeit[++pos],prgname);
          while ((arbeit[pos]!='.')&&(arbeit[pos]!='\0')) pos++;
          strcpy(endung,&arbeit[++pos]);
          if ((strcmp(endung,"PRG")==0)||(strcmp(endung,"APP")==0))
               execute(arbeit,"",GEM,WARTENICHT);
          if (strcmp(endung,"TOS")==0)
               execute(arbeit,"",NOGEM,texwarte);
          if (strcmp(endung,"TTP")==0)
          {
               param[0]=0;
               param[1]='\0';
               ((TEDINFO *)ttp_ptr[TTPARAM].ob_spec)->te_ptext=&param[1];
               ((TEDINFO *)ttp_ptr[TTPNAME].ob_spec)->te_ptext=prgname;
               ((TEDINFO *)ttp_ptr[TTPNAME].ob_spec)->te_txtlen=strlen(prgname);
               form_dial(FMD_START,0,0,0,0,ttpx,ttpy,ttpw,ttph);
               objc_draw(ttp_ptr,ROOT,MAX_DEPTH,ttpx,ttpy,ttpw,ttph);
               taste = form_do(ttp_ptr,TTPARAM);
               objc_change(ttp_ptr,taste,0,ttpx,ttpy,ttpw,ttph,NORMAL,0);
               form_dial(FMD_FINISH,0,0,0,0,ttpx,ttpy,ttpw,ttph);
               if (taste==TTPOK)
               {
                    param[0] = strlen(&param[1]);
                    execute(arbeit,param,NOGEM,texwarte);
               }
          }
     }
}

lok_editor()
{
     int taste,pos;

     pos=chop_fn(lokpfad,editorpfad);
     strcat(lokpfad,"*.*");
     strcpy(lokname,&editorpfad[pos+1]);
     fsel_caption(lokpfad,lokname,&taste,menu_text(LOKEDITO));
     if ((taste==1)&&strlen(lokname)!=0)
     {
          pos=chop_fn(editorpfad,lokpfad);
          strcpy(&editorpfad[++pos],lokname);
          strcpy(text,texte[KANNEDI1]);
          strcat(text,lokname);
          strcat(text,texte[KANNEDI2]);
          log_edit=(form_alert(1,text)==1);
     }
}

lok_TeX()
{
     int taste,pos;

     pos=chop_fn(lokpfad,texpfad);
     strcat(lokpfad,"*.*");
     strcpy(lokname,&texpfad[pos+1]);
     fsel_caption(lokpfad,lokname,&taste,menu_text(LOKTEX));
     if ((taste==1)&&strlen(lokname)!=0)
     {
          pos=chop_fn(texpfad,lokpfad);
          strcpy(&texpfad[++pos],lokname);
          if (texpfad[1]==':')
          {
               cur_driv[0]=texpfad[0];
               Dsetdrv(texpfad[0]-'A');
          }
          get_environ();
     }
}

lok_DVI()
{
     int taste,pos;

     pos=chop_fn(lokpfad,dvipfad);
     strcat(lokpfad,"*.*");
     strcpy(lokname,&dvipfad[pos+1]);
     fsel_caption(lokpfad,lokname,&taste,menu_text(LOKDVI));
     if ((taste==1)&&strlen(lokname)!=0)
     {
          pos=chop_fn(dvipfad,lokpfad);
          strcpy(&dvipfad[++pos],lokname);
     }
}

t_texdvi()
{
     tex_und_dvi=!tex_und_dvi;
     menu_icheck(menu_ptr,TEXDVI,tex_und_dvi);
}

t_texwarte()
{
     texwarte=!texwarte;
     menu_icheck(menu_ptr,WARTEOPT,texwarte);
}

t_plain()
{
     plain=!plain;
     menu_icheck(menu_ptr,PLAINOPT,plain);
     if (plain)
     {
          if (latex)
               t_latex();
          if (eigenfmt)
               t_eigenfmt(NO);
          menu_ienable(menu_ptr,DEUTSCHO,YES);
     } else
     {
          if (!latex)
               menu_ienable(menu_ptr,DEUTSCHO,NO);
     }
}

t_latex()
{
     latex=!latex;
     menu_icheck(menu_ptr,LATEXOPT,latex);
     if (latex)
     {
          if (plain)
               t_plain();
          if (eigenfmt)
               t_eigenfmt(NO);
          menu_ienable(menu_ptr,DEUTSCHO,YES);
     } else
     {
          if (!plain)
               menu_ienable(menu_ptr,DEUTSCHO,NO);
     }
}

t_eigenfmt(ask)
int ask;
{
     int taste,pos;
     
     eigenfmt=!eigenfmt;
     if (eigenfmt && ask)
     {
          chop_fn(lokpfad,fmtpfad);
          strcat(lokpfad,"*.FMT");
          strcpy(lokname,fmtname);
          strcat(lokname,".FMT");
          fsel_caption(lokpfad,lokname,&taste,menu_text(EIGENFMT));
          if ((taste==1)&&strlen(lokname)!=0)
          {
               for (pos=0; (lokname[pos]!='.') && (lokname[pos]!='\0'); pos++)
                    fmtname[pos]=lokname[pos];
               fmtname[++pos]='\0';
          } else
               eigenfmt=NO;
     }
     menu_icheck(menu_ptr,EIGENFMT,eigenfmt);
     if (eigenfmt)
     {
          if (plain)
               t_plain();
          if (latex)
               t_latex();
          menu_ienable(menu_ptr,DEUTSCHO,NO);
     }
}

t_deutsch()
{
     deutsch=!deutsch;
     menu_icheck(menu_ptr,DEUTSCHO,deutsch);
}

dvi_rette()
{
     int pos;
        
     if (!ausgewaehlt)
          datei_auswaehlen();
     if (ausgewaehlt)
     {
          pos=chop_fn(arbeit,quellpfad);
          strcpy(&arbeit[++pos],quellname);
          while ((arbeit[pos]!='.')&&(arbeit[pos]!='\0')) pos++;
          strcpy(&arbeit[pos],".DVI");
          pos=chop_fn(lokpfad,outputpfad);
          strcpy(&lokpfad[++pos],quellname);
          while ((lokpfad[pos]!='.')&&(lokpfad[pos]!='\0')) pos++;
          strcpy(&lokpfad[pos],".DVI");
          if (Fsfirst(lokpfad,0)>=0)
               ask_copy(arbeit,lokpfad);
          else
               form_alert(1,texte[NIZUKOP]);
     }
}

ask_copy(s1,s2)
char s1[],s2[];
{
     strcpy(text,"[2][");
     strcat(text,texte[KOPIJN1]);
     strlcat(text,s2,30);
     strcat(text,texte[NACH]);
     strlcat(text,s1,30);
     strcat(text,texte[KOPIJANE]);
     if (form_alert(1,text)==1)
          copyfile(s1,s2);
}

aux_rette()
{
     int pos,posl,Fs_err,ncopy;
     char *tail;
     
     ncopy=0;
     if (texdone)
     {
          posl=chop_fn(lokpfad,quellpfad)+1;
          pos=chop_fn(arbeit,auxpfad)+1;
          strcpy(&arbeit[pos],"*.*");
          dta_ptr = (DTA *)Fgetdta();
          Fs_err=Fsfirst(arbeit,0);
          while(Fs_err>=0)
          {
               file_datime.time = dta_ptr->time_stamp;
               file_datime.date = dta_ptr->date_stamp;
               if (timecmp(&TeX_start,&file_datime)<=0 && timecmp(&TeX_stop,&file_datime)>=0)
               {
                    ncopy++;
                    tail=index(dta_ptr->file_name,'.');
                    if(strcmp(tail,".DVI")!=0 && strcmp(tail,".LOG")!=0)
                    {
                         strcpy(&arbeit[pos],dta_ptr->file_name);
                         strcpy(&lokpfad[posl],dta_ptr->file_name);
                         ask_copy(lokpfad,arbeit);
                         strcpy(&arbeit[pos],"*.*");
                    }
               }
               Fs_err=Fsnext();
          }
     }
     if (ncopy==0)
          form_alert(1,texte[NIZUKOP]);
}

chop_fn(pfad,file_spec)
char pfad[],file_spec[];
/* chop filename portion off of file_spec and copy to pfad */
{
     int pos;

     for (pos=strlen(file_spec); pos>=0 && file_spec[pos]!='\\'; pos--)
          ;
     strncpy(pfad,file_spec,++pos);
     pfad[pos]='\0';
     return (--pos);
}

int timecmp(t1,t2)
DATIME *t1,*t2;
{
     if (t1->date > t2->date)
          return(1);
     if (t1->date == t2->date)
     {
          if (t1->time > t2->time)
               return(1);
          if (t1->time == t2->time)
               return(0);
          return(-1); 
     }
     return(-1);
}

copyfile(to_fspec,from_fspec)
char to_fspec[],from_fspec[];
{
     int fd_from,fd_to,iread;
     char buf[512];
     
     if (strcmp(to_fspec,from_fspec)==0)
          form_alert(1,texte[NKOPIER]);
     else
     {
          if ( (fd_from = open(from_fspec,O_RDONLY|O_BINARY)) == -1)
               form_alert(1,texte[NKANNOP]);
          else 
          {
               if ((Fsfirst(to_fspec,0) < 0) ||
                    (form_alert(1,texte[ZIELEX]) == 2))
               {     
                    if ( (fd_to = creat(to_fspec,O_BINARY)) == -1)
                         form_alert(1,texte[NZIELOP]);
                    else
                    {
                         while ( (iread = read(fd_from,buf,512)) > 0)
                         {
                              if ( write(fd_to,buf,iread) != iread )
                              {
                                   form_alert(1,texte[FEHLSCHL]);
                                   break;
                              }
                         }
                         close(fd_to);
                    }
               }
               close(fd_from);
          }
     }
}

sauber()
{
     char *tail;
     int pos,nsauber,Fs_err;

     nsauber=0;
     pos=chop_fn(arbeit,logpfad);
     strcat(arbeit,quellname); 
     while (arbeit[pos] != '\0' && arbeit[pos] != '.')
          pos++;
     arbeit[pos] = '\0';
     strcat(arbeit,".LOG");
     if (Fsfirst(arbeit,0)>=0)
     {
          nsauber++;
          entferne(arbeit);
     }
     
     if (texdone)
     {
          pos=chop_fn(arbeit,auxpfad)+1;
          strcpy(&arbeit[pos],"*.*");
          dta_ptr = (DTA *)Fgetdta();
          Fs_err=Fsfirst(arbeit,0);
          while(Fs_err>=0)
          {
               file_datime.time = dta_ptr->time_stamp;
               file_datime.date = dta_ptr->date_stamp;
               if (timecmp(&TeX_start,&file_datime)<0 && timecmp(&TeX_stop,&file_datime)>0)
               {
                    nsauber++;
                    tail=index(dta_ptr->file_name,'.');
                    if(strcmp(tail,".DVI")!=0 && strcmp(tail,".LOG")!=0)
                    {
                         strcpy(&arbeit[pos],dta_ptr->file_name);
                         entferne(arbeit);
                         strcpy(&arbeit[pos],"*.*");
                    }
               }
               Fs_err=Fsnext();
          }
     }
     
     pos=chop_fn(arbeit,outputpfad);
     strcat(arbeit,quellname); 
     while (arbeit[pos] != '\0' && arbeit[pos] != '.')
          pos++;
     arbeit[pos] = '\0';
     strcat(arbeit,".DVI");
     if (Fsfirst(arbeit,0)>=0)
     {
          nsauber++;
          entferne(arbeit);
     }
     
     if (nsauber==0)
          form_alert(1,texte[NZURAUM]);
}

int execute(name,arbeit,art,pause)
char *name,*arbeit;
int art,pause;
{
     int error,pos;
     char pfad[67];
     
     pos=chop_fn(pfad,name);
     if(name[1]==':')
          Dsetdrv(name[0]-'A');
     if(pos>=0)
          Dsetpath(pfad);
     menu_bar(menu_ptr,FALSE);
     if (art==NOGEM)
     {
          graf_mouse(M_OFF,0L);
          v_enter_cur(handle);
     }
     error=Pexec(0,name,arbeit,0L);
     if (pause==WARTE)
     {
          printf("\nReturn code = %d\n%s\n",error,texte[BITASTE]);
          Crawcin();
     }
     if (art==NOGEM)
     {
          v_exit_cur(handle);
          graf_mouse(M_ON,0L);
     } else
          wind_set(DESK,WF_NEWDESK,desktop,0,0);
     form_dial(FMD_FINISH,0,0,0,0,xdesk,ydesk,wdesk,hdesk);
     menu_bar(menu_ptr,TRUE);
     fenster_loeschen();
     return(error);
}

fenster_loeschen()
{
     int fenster;
     
     wind_get(0,WF_TOP,&fenster,&dummy,&dummy,&dummy);
     while (fenster!=0)
     {
          wind_close(fenster);
          wind_delete(fenster);
          wind_get(0,WF_TOP,&fenster,&dummy,&dummy,&dummy);
     }
}

anfang()
{
     int     i;
     
     cur_driv[0] = 'A' + Dgetdrv();
     cur_driv[1] = ':';
     cur_driv[2] = '\0';
     strcpy(prgpfad,cur_driv);
     strcat(prgpfad,"\\*.*");
     strcpy(prgname,"");
     strcpy(fmtname,"*");
     strcpy(shellpfad,cur_driv);
     Dgetpath(&shellpfad[2],0);
     strcat(shellpfad,"\\TEXSHELL.INF");
     read_txt();
     if (appl_init()==-1)
     {
          form_alert(1,texte[KEINAPPL]);
          exit(1);
     }
     if (Getrez()==LORES)
     {
          form_alert(1,texte[ANDRAUFL]);
          exit(1);
     }
     handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
     for (i=1; i<10; i++)
          int_in[i]=1;
     int_in[10]=2;
     v_opnvwk(int_in,&handle,int_out);
     if (!rsrc_load(RSCNAME))
     {
          form_alert(1,texte[RSCFEHLT]);
          v_clsvwk();
          exit(1);
     }
     wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
     if (!rsrc_gaddr(R_TREE,MENU,&menu_ptr))
     {
          form_alert(1,texte[RSCKAPUT]);
          rsrc_free();
          v_clsvwk();
          exit(1);
     }
     rsrc_gaddr(R_TREE,TOP,&desktop);
     if (Getrez()==MIDRES)
          desktop->ob_spec=(char *)0x173;
     desktop->ob_width=640;
     desktop->ob_height=400;
     wind_set(DESK,WF_NEWDESK,desktop,0,0);
     objc_draw(desktop,ROOT,MAX_DEPTH,xdesk,ydesk,wdesk,hdesk);
     rsrc_gaddr(R_TREE,FSHELLIN,&info_ptr);
     form_center(info_ptr,&infox,&infoy,&infow,&infoh);
     rsrc_gaddr(R_TREE,UMBENNEN,&edit_ptr);
     form_center(edit_ptr,&editx,&edity,&editw,&edith);
     ((TEDINFO *)edit_ptr[EDIT].ob_spec)->te_ptext=neuername;
     ((TEDINFO *)edit_ptr[EDIT].ob_spec)->te_txtlen=13;
     rsrc_gaddr(R_TREE,TTPBOX,&ttp_ptr);
     form_center(ttp_ptr,&ttpx,&ttpy,&ttpw,&ttph);
     menu_bar(menu_ptr,TRUE);
     graf_mouse(ARROW,0L);
     if ((fp=fopen(shellpfad,"r"))==NULL)
     {
          strcpy(editorpfad,cur_driv);
          strcat(editorpfad,"\\EDITOR.PRG");
          strcpy(texpfad,cur_driv);
          strcat(texpfad,"\\TEX.PRG");
          strcpy(dvipfad,cur_driv);
          strcat(dvipfad,"\\DVI.PRG");
          tex_und_dvi=YES;
          deutsch=YES;
          latex=YES;
          plain=NO;
          texwarte=NO;
     } else
     {
          fscanf(fp,"%s %d %s %s %s %d %d %d %d %d %d",
                    editorpfad,&log_edit,texpfad,dvipfad,fmtname,
                    &plain,&latex,&eigenfmt,&deutsch,&tex_und_dvi,&texwarte);
          fclose(fp);
          if (texpfad[1]==':')
          {
               cur_driv[0]=texpfad[0];
               Dsetdrv(texpfad[0]-'A');
          }
     }
     strcpy(quellname,"");
     strcpy(quellpfad,cur_driv);
     strcat(quellpfad,"\\*.TEX");
     strcpy(altname,"");
     strcpy(altpfad,cur_driv);
     strcat(altpfad,"\\*.TEX");
     get_environ();
     menu_icheck(menu_ptr,TEXDVI,tex_und_dvi);
     menu_icheck(menu_ptr,DEUTSCHO,deutsch);
     menu_icheck(menu_ptr,LATEXOPT,latex);
     menu_icheck(menu_ptr,PLAINOPT,plain);
     menu_icheck(menu_ptr,EIGENFMT,eigenfmt);
     menu_icheck(menu_ptr,WARTEOPT,texwarte);
     menu_ienable(menu_ptr,DEUTSCHO,latex || plain);
     fenster_loeschen();
}

read_txt()
{
     int i,pos;
     
     chop_fn(arbeit,shellpfad);
     strcat(arbeit,"TEXSHELL.TXT");
     if ((fp=fopen(arbeit,"r"))==NULL)
     {
          printf("TEXSHELL.TXT not found - Stop\n");
          Crawcin();
          exit(1);
     }  else
     {
          fseek(fp,0L,2); /* end of file */
          texte[0]=malloc((unsigned)(ftell(fp)+NTEXTE));
          rewind(fp);
          if (texte[0]==NULL)
          {
               printf("malloc failed - Stop\n");
               Crawcin();
               exit(1);
          } else
          {
               for (i=0; fgets(texte[i],100,fp)!=0 && i<NTEXTE; i++)
               {
                    for (pos=strlen(texte[i])-1; pos>=0 && iscntrl(texte[i][pos]); pos--)
                         ;
                    texte[i][pos+1]='\0';
                    texte[i+1]=texte[i]+strlen(texte[i])+1;
               }
               if (i<NTEXTE)
               {
                    printf("Something is wrong with TEXSHELL.TXT - Stop\n");
                    Crawcin();
                    exit(1);
               }
          }
          fclose(fp);
     }
}

get_fmt()
{
     char line[80];
     int pos,pose,nline;
     
     chop_fn(arbeit,quellpfad);
     strcat(arbeit,quellname);
     if ((fp=fopen(arbeit,"r"))!=NULL)
     {
          nline=0;
          while (nline<10 && fgets(line,80,fp)!=0)
          {
               nline++;
               for (pos=0; isspace(line[pos]); pos++)
                    ;
               if (line[pos++]!='%')
                    continue;
               while (isspace(line[pos]))
                    pos++;
               for (pose=pos; line[pose]!='\0' && line[pose]!='='; pose++)
                    ;
               if (line[pose]!='=')
                    continue;
               line[pose]='\0';
               if (strcmp(&line[pos],"macropackage")==0)
               {
                    for (pos=0, pose++; line[pose]!='\0' && !isspace(line[pose]); pos++, pose++)
                         fmtname[pos]=toupper(line[pose]);
                    fmtname[pos]='\0';
                    if (strcmp(fmtname,texte[PLAIN])==0)
                    {
                         if (!plain)
                              t_plain();
                         if (deutsch)
                              t_deutsch();
                    }
                    else if (strcmp(fmtname,texte[PLAING])==0)
                    {
                         if (!plain)
                              t_plain();
                         if (!deutsch)
                              t_deutsch();
                    }
                    else if (strcmp(fmtname,texte[LPLAIN])==0)
                    {
                         if (!latex)
                              t_latex();
                         if (deutsch)
                              t_deutsch();
                    }
                    else if (strcmp(fmtname,texte[LPLAING])==0)
                    {
                         if (!latex)
                              t_latex();
                         if (!deutsch)
                              t_deutsch();
                    }
                    else
                    {
                         if (!eigenfmt)
                              t_eigenfmt(NO);
                    }
                    break;
               }
          }
          fclose(fp);
     }
}

get_environ()
{
     char line[80],envpfad[80];
     int pos;
     
     chop_fn(auxpfad,texpfad);
     chop_fn(logpfad,texpfad);
     chop_fn(outputpfad,texpfad);
     chop_fn(fmtpfad,texpfad);
     chop_fn(envpfad,texpfad);
     strcat(envpfad,"ENVIRONM.ENT");
     if ((fp=fopen(envpfad,"r"))!=NULL)
     {
          while (fgets(line,80,fp)!=0)
          {
               for (pos=strlen(line)-1; pos>=0 && iscntrl(line[pos]); pos--)
                    ;
               line[pos+1]='\0';
               for (pos=0; line[pos]!='=' && pos<80; pos++)
                    ;
               if (line[pos]=='=')
               {
                    line[pos] = '\0';
                    backslash(&line[pos+1]);
                    if (strcmp(line,"TEXTRANSCRIPT")==0)
                         strcpy(logpfad,&line[pos+1]);
                    else if (strcmp(line,"TEXWRITE")==0)
                         strcpy(auxpfad,&line[pos+1]);
                    else if (strcmp(line,"TEXOUTPUT")==0)
                         strcpy(outputpfad,&line[pos+1]);
                    else if (strcmp(line,"TEXFORMATS")==0)
                         strcpy(fmtpfad,&line[pos+1]);
               }
          }
     fclose(fp);
     }
}

fsel_caption(path,name,button,caption)
char *path,*name,*caption;
int *button;
{
     static int first=YES;
     static int captx,capty,captw,capth;
     static OBJECT *capt_ptr;
     int fsel_result;
     
     if (first)
     {
          rsrc_gaddr(R_TREE,FSELCAP,&capt_ptr);
          form_center(capt_ptr,&captx,&capty,&captw,&capth);
          capt_ptr->ob_y = capty = (Getrez()==HIRES)?20:10;
          first = NO;
     }
     ((TEDINFO *)capt_ptr[FSELCAPT].ob_spec)->te_ptext=caption;
     ((TEDINFO *)capt_ptr[FSELCAPT].ob_spec)->te_txtlen=strlen(caption);
     form_dial(FMD_START,0,0,0,0,captx,capty,captw,capth);
     objc_draw(capt_ptr,ROOT,MAX_DEPTH,captx,capty,captw,capth);
     fsel_result = fsel_input(path,name,button);
     form_dial(FMD_FINISH,0,0,0,0,captx,capty,captw,capth);
     return(fsel_result);
} 

backslash(string)
char string[];
{
     int pos;
     
     for (pos=0; string[pos]!='\0'; pos++)
          if (string[pos]=='/') string[pos] = '\\';
     if (string[pos-1]!='\\')
     {
          string[pos++] = '\\';
          string[pos] = '\0';
     }
}
       
ende()
{
     menu_bar(menu_ptr,FALSE);
     rsrc_free();
     v_clsvwk();
     appl_exit();
}

