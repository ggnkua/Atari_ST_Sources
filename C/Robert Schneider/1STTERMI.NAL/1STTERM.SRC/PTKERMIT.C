#define STRING01 "Kermit : %d. Datei senden!"
#define STRING02 " Kermit-Debug (Level=%d) "
#define STRING03 " Rechte Maustaste  Stop\\Go "
#define STRING04 "Debugging level = %d\15\12\12"
#define STRING05 "Send command\15\12\12"
#define STRING06 "Receive command\15\12\12"
#define STRING07 "Kermit"
#define STRING08 "Senden"
#define STRING09 "Status : %c\15\12"
#define STRING10 "ôffne\15\12'%s'\15\12zum Senden.\15\12"
#define STRING11 "Kann '%s' nicht îffnen."
#define STRING12 "Sende '%s'\15\12als '%s'\15\12"
#define STRING14 "NÑchste Datei ist \15\12'%s'\15\12"
#define STRING15 "Empfangen"
#define STRING17 "Kann '%s' nicht einrichten."
#define STRING18 "Empfange %s\15\12als %s\15\12"
#define STRING19 "Packetsendung:\15\12"
#define STRING20 "   Typ   :  %c\15\12"
#define STRING21 "   Nummer:  %d\15\12"
#define STRING22 "   LÑnge :  %d\15\12"
#define STRING23 "   Daten :  '%s'\15\12"
#define STRING24 "Packetempfang:\15\12"
 
#define FORM01 "[2][Kermit :|%d Dateien senden.][OK|Abbruch]"
#define FORM02 "[1][Kein Window mehr zur VerfÅgung !|Debug wird abgeschaltet !][OK]"
#define FORM03 "[1][öbertragung fehlgeschlagen !][OK]"
#define FORM04 "[1][öbertragung erfolgreich beendet !][OK]"
#define FORM08 "[2][10. Versuch erreicht !|Noch 10 Versuche ?][Ja|Nein]"
#define FORM09 "[1][Abbruch durch Fehlerpaket|%s|vom Host][OK]"
#define FORM10 "[2][öbertragung beenden ?][Ja|Nein]"

overlay "kermit"

#include <stdio.h>
#include <osbind.h>
#include <megatadd.h>

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

#include "ptvars.h"

#define MAXPACKSIZ 94
#define SOH 1
#define CR 13
#define SP 32
#define DEL 127
#define ESCCHR '^'
#define MAXTRY 10
#define MYQUOTE '#'
#define MYPAD 0
#define MYPCHAR 0
#define MYEOL '\r'
#define MYTIME 10
#define MAXTIM 60
#define MINTIM 2
#define TRUE -1
#define FALSE 0
#define tochar(ch) ((ch) + ' ')
#define unchar(ch) ((ch) - ' ')
#define ctl(ch)    ((ch) ^ 64 )

int size;
int rpsiz;
int spsiz;
int pad;
int timint;
int n;
int numtry;
int oldtry;
int image;
int debug;
int filnamcnv;
int filecount;
int kerm_blk;
int wi_kerm;
int  fp;

char state;
char padchar;
char eol;
char escchr;
char quote;
char k_names[20][80];
char *k_string[20];
char **filelist;
char *filnam;
char recpkt[MAXPACKSIZ];
char packet[MAXPACKSIZ];

static willst_raus();
static rdaux();
static wraux();
static prinwin();
static nochmal();
static info();
static printmsg();
static prerrpkt();
static bufill();
static bufemp();
static spar();
static rpar();
static spack();
static rpack();
static sinit();
static sfiledata();
static rfile();
static rinitdata();
static sw();

extern char *ptadr();

extern int VAR_TEMP(), OUT_KERMIT();

/* what = 1 fÅr senden und 0 fÅr empfangen
   deb  = 0 keine Ausgabe, 1 wichtigsten Meldungen, 2 alle Meldungen
   im   = 0 -> 7 Bit 1 -> 8 Bit öbertragung
   fil  = 0 -> keine Filenamekonvertierung, 1 -> Filenamekonvertierung  */

asm{
DC.B "KERMIT"
   }

willst_raus() 
{
   if(debug)
      mouseset(0,0);

   if(brain_alert(1,FORM10)==1)
   {
      if(debug)
         mouseset(1,1);	
      state='E';
      seofbreak(1); 
      asm
      {
         JMP   OUT_KERMIT(PC)
      }
   }
   else
      if(debug)
         mouseset(1,1);
}


rdaux()
{
   long timeout=*seconds;

   while(!Cauxis())
   {
      if(mouse_but&1)
         willst_raus();
      if(*seconds-timeout>MYTIME)
         return(-1);
   }
   return((int)Cauxin());
}

wraux(string,anz)
char *string;
int anz;
{
   int a;
   int b=0;

   for(a=0; a<anz; a++)
   {
      if(mouse_but&1)
         b=1;
      Cauxout(*string++);
   }

   if(mouse_but&1||b)
      willst_raus();
}

prinwin(fmt,a1,a2,a3,a4,a5)
char *fmt;
long a1,a2,a3,a4,a5;
{
   int a;
   char string[200];

   sprintf(string,fmt,a1,a2,a3,a4,a5);
   for(a=0;a<200;a++)
   {
      if(!string[a])
         break;
      out_c(string[a]);
      while(mouse_but&2);
   }
}

nochmal()
{
   if(numtry++ > MAXTRY)
   {
      Bconout(2,7);
      if(brain_alert(1,FORM08)==1)
         numtry=0;
      else
         return(1);
   }

   sprintf(ptadr(proto_di,XM_TRIES,0),"%3d",numtry);
   objc_update(proto_di,XM_TRIES,0);
   return(0);
}


info(what,type,num,len,data)
char type, *data;
int num, len;
{
   if(debug<2)
      return;   

   prinwin(what? STRING19 : STRING24);
   prinwin(STRING20,type);
   prinwin(STRING21,num);
   prinwin(STRING22,len);

   if(data != NULL)
   {
      data[len] = '\0';
      prinwin(STRING23,data);
   }
}


printmsg(fmt,a1,a2)
char *fmt;
{
   char msg[80];

   sprintf(msg,fmt,a1,a2);
   strncpy(ptadr(proto_di,XM___ERR,0),msg,35);
   objc_update(proto_di,XM_ERRUP,1);
}

prerrpkt(msg)
char *msg;
{
   char string[200];

   sprintf(string,FORM09,msg);
   Bconout(2,7);
   brain_alert(1,string);
   return;
}

bufill(buffer)
char buffer[];
{
   int i;
   char t7;
   unsigned char t;

   i = 0;
   while(Fread(fp,1l,&t) == 1l)
   {
      t7 = t & 0177;

      if(t7 < SP || t7 == DEL || t7 == quote)
      {
         if (t=='\n' && !image)
         {
            buffer[i++] = quote;
            buffer[i++] = ctl('\r');
         }
         buffer[i++] = quote;
         if(t7 != quote)
         {
            t = ctl(t);
            t7= ctl(t7);
         }
      }
      if(image)
         buffer[i++]=t;
      else
         buffer[i++]=t7;

      if(i >= spsiz-8)
         break;
   }
   if(i==0)
      return(EOF);

   kerm_blk++;
   set_number(kerm_blk);
   return(i);
}

bufemp(buffer,len)
char buffer[];
int len;
{
   int i;
   char t;

   for(i=0; i<len; i++)
   {
      t = buffer[i];
      if(t == MYQUOTE)
      {
         t = buffer[++i];
         if((t & 0177) != MYQUOTE)
            t = ctl(t);
      }
      if(t==CR && !image)
         continue;

      Fwrite(fp,1l,&t);
   }
   kerm_blk++;
   set_number(kerm_blk);
}

spar(data)
char data[];
{
   data[0] = tochar(MAXPACKSIZ);
   data[1] = tochar(MYTIME);
   data[2] = tochar(MYPAD);
   data[3] = ctl(MYPCHAR);
   data[4] = tochar(MYEOL);
   data[5] = MYQUOTE;
}

rpar(data)
char data[];
{
   spsiz = unchar(data[0]);
   timint= unchar(data[1]);
   pad   = unchar(data[2]);
   padchar=ctl(data[3]);
   eol = unchar(data[4]);
   quote  = data[5];
}

spack(type,num,len,data)
char type, *data;
int num, len;
{
   int i;
   char buffer[100];
   register char *bufp, chksum;

   info(1,type,num,len,data);	
   bufp = buffer;
   for(i=1; i<=pad; i++)
      Cauxout(padchar);

   *bufp++ = SOH;
   chksum  = ( *bufp++ = tochar(len+3));
   chksum += ( *bufp++ = tochar(num));
   chksum += ( *bufp++ = type);

   for(i=0; i<len; i++)
      chksum += (*bufp++ = data[i]);

   chksum = (((chksum&0300) >> 6)+chksum)&077;
   *bufp++ = tochar(chksum);
   *bufp   = eol;

   wraux(buffer,bufp-buffer+1);
}

rpack(len,num,data)
int *len, *num;
char *data;
{
   int i, done, step;
   char  cchksum2, type, rchksum;
   register char t, cchksum;

   while(t != SOH)
   {
      if((t=rdaux())==-1)
         return('T');
      t &= 0177;
   }
   step = cchksum = 0;
   done = i = 0;
   while(!done)
   {
      if((t=rdaux())==-1)
         return('T');
      if(!image)
         t &= 0177;
      if(t == SOH)
         continue;
      cchksum += t;
      switch(step)
      {

         case 0 : *len = unchar(t)-3;
                  break;

         case 1 : *num = unchar(t);
                  break;

         case 2 : type = t;
		  if(! *len)
                  {
		     cchksum2=cchksum;
                     rchksum=unchar(rdaux());			
                     step++;
                  }
                  break;

         case 3 : data[i++] = t;
                  if (i < *len)
                     continue;
                  data[*len] = 0;
		  cchksum2=cchksum;
                  rchksum = unchar(rdaux());
                  break;

         default: done = 1;
      }
      step++;
   }

   info(0,type,*num,*len,data);

   cchksum2 = (((cchksum2&0300) >> 6)+cchksum2)&077;

   if(cchksum2 != rchksum)
      return(FALSE);

   return(type);
}

sinit()
{
   int num, len;

   if(nochmal())
      return('A');

   spar(packet);

   spack('S',n,6,packet);
   switch((char)rpack(&len,&num,recpkt))
   {


      case 'Y':
         if(n != num)
            return(state);
         rpar(recpkt);
         if(!eol)
            eol = '\n';
         if(!quote)
            quote = '#';
         numtry = 0;
         n = (n+1)%64;
         return('F');

      case 'T':
      case 'N':
      case FALSE:
         return(state);

      case 'E':
         prerrpkt(recpkt);

      default: return('A');
   }
}

sfiledata()
{
   int num, len;
   char filnam1[50];
   char *newfilnam;
   char *cp;
   long length;

   if( state == 'F')
   {
      if(fp == NULL)
      {
         if(debug)
            prinwin(STRING10,filnam);
 
         fp= Fopen(filnam,0);
         if(fp < 6)
         {
            printmsg(STRING11,filnam);
            return('A');
         }
     }

      strcpy(ptadr(proto_di,XMFILNAM,0),filnam);
      objc_update(proto_di,XMFILNAM,0);

      strcpy(filnam1,filnam);
      newfilnam= cp = filnam1+2;
      while(*cp != '\0')
         if(*cp++ == '\\')
            newfilnam = cp;

      if(filnamcnv)
         for(cp = newfilnam; *cp != '\0'; cp++)
            if(*cp >= 'a' && *cp <= 'z')
               *cp ^= 040;

      len = cp - newfilnam;

      if(debug)
         prinwin(STRING12,filnam,newfilnam);
   }

   if(nochmal())
      return('A');

   if(state == 'F')
      spack('F',n,len,newfilnam);
   else
      spack('D',n,size,packet);

   switch((char)rpack(&len,&num,recpkt))
   {

      case 'N':
         num = (--num<0 ? 63 : num);

      case 'Y':
         if(n != num)
            return(state);
         numtry = 0;
         n = (n+1)%64;
         if((size = bufill(packet))==EOF)
            return('Z');
         return('D');

      case 'T':
      case FALSE:
          return(state);

      case 'E':
         prerrpkt(recpkt);

      default   : return('A');
   }
}


seofbreak(what)
int what;
{
   int num , len;


   if(nochmal())
      return('A');

   spack(state,n,0,packet);

   if(what)
      return('B');

   switch((char)rpack(&len,&num,recpkt))
   {
      case 'N':
         num = (--num<0 ? 63 : num);

      case 'Y':
         if(n != num)
            return(state);
         numtry = 0;
         n = (n+1)%64;
         if(state=='B')
            return('C');

         Fclose(fp);
         fp = NULL;

         if(!filecount--)
            return('B');

         filnam = *(filelist++);

         if(debug)
            prinwin(STRING14,filnam);
         return('F');

      case 'T':
      case FALSE:
         return(state);

      case 'E':
         prerrpkt(recpkt);

      default   : return('A');
   }
}

rfile()
{
   int num, len;
   char filnam1[50],rp;

   if(nochmal())
      return('A');
   rp=rpack(&len,&num,packet);
   switch(rp)
   {
      case 'S':
      case 'Z':
         if(num == ((n==0) ? 63 : n-1))
         {
            spar(packet);
            rp=='S'? spack('Y',num,6,packet) : spack('Y',num,0,0l);
            numtry = 0;
            return(state);
         }
         else
            return('A');

      case 'F':
         if(num != n)
            return('A');
         strcpy(filnam1,packet);

         if((fp=Fcreate(filnam1,0))<6)
         {
            printmsg(STRING17,filnam1);
            return('A');
         }
         else
         {
            sprintf(ptadr(proto_di,XMFILNAM,0),"%s",filnam1);
            objc_update(proto_di,XMFILNAM,0);
            if(debug)
               prinwin(STRING18,packet,filnam1);
         }

         spack('Y',n,0,0l);
         numtry = 0;
         n = (n+1)%64;
         return('D');

      case 'B':
         if(num != n)
            return('A');
         spack('Y',n,0,0l);
         return('C');

      case 'T':
      case FALSE:
         spack('N',n,0,0l);
         return(state);

      case 'E':
         prerrpkt(recpkt);

      default: return('A');
   }
}

rinitdata()
{
   int num, len;
   if(nochmal())
      return('A');

   sprintf(ptadr(proto_di,XM_TRIES,0),"%3d",numtry);
   objc_update(proto_di,XM_TRIES,0);

   switch((char)rpack(&len,&num,packet))
   {
      case 'D':
         if(num != n)
         {
            if(num == ((n==0) ? 63 : n-1))
            {
               spack('Y',num,6,packet);
               numtry = 0;
               return(state);
            }
            else
               return('A');
         }
         bufemp(packet,len);
         spack('Y',n,0,0l);
         
         numtry = 0;
         n = (n+1)%64;
         return('D');

      case 'F':
         if(num == ((n==0) ? 63 : n-1))
         {
            spack('Y',num,0,0l);
            numtry = 0;
            return(state);
         }
         else
            return('A');

      case 'S':
         rpar(packet);
         spar(packet);
         spack('Y',n,6,packet);
         numtry = 0;
         n = (n+1)%64;
         return('F');

      case 'Z':
         if(num != n)
            return('A');
         spack('Y',n,0,0l);
         Fclose(fp);
         n = (n+1)%64;
         return('F');

      case FALSE:
         spack('N',n,0,0l);
         return(state);

      case 'E':
         prerrpkt(recpkt);

      default: return('A');
   }
}

sw(what)
{
   kerm_blk=0;
   set_number(kerm_blk);
   strcpy(ptadr(proto_di,XMPRONAM,0),STRING07);
   strcpy(ptadr(proto_di,XM_INOUT,0),what ? STRING08 : STRING15);
   ptadr(proto_di,XM___ERR,1);
   objc_update(proto_di,XMPRONAM,0);
   objc_update(proto_di,XM_INOUT,0);
   objc_update(proto_di,XM___ERR,0);

   while(Bconstat(2))
      Bconin(2);
   while(Cauxis())
      rdaux();

   state = what ? 'S' : 'R';
   n = 0;
   numtry = 0;
   while(1)
   {
      if(debug)
         prinwin(STRING09,state);
      if(what)
         switch(state)
         {
            case 'S': state = sinit(); break;
            case 'F': 
            case 'D': state = sfiledata(); break;
            case 'Z': 
            case 'B': state = seofbreak(0);break;
            case 'C': return(TRUE);
            default : return(FALSE);
         }
      else
         switch(state)
         {
            case 'F': state = rfile(); break;
            case 'R': 
            case 'D': state = rinitdata(); break;
            case 'C': return(TRUE);
            default : return(FALSE);
        }
   }
}

kermit(what)
int what;
{
   char pfad[80],name[80],string[60];
   int a,b,c,x;
   int old_when_cr=when_cr;
   int vt_save = onli_vt52;
   GRECT box,win,menbuf;

   if(online)
      wind_update(END_MCTRL);

   if(what)
   {
      pfad[0]=name[0]=0;
      filecount=0;
      do
      {
         sprintf(string,STRING01,filecount+1);	
         c=file_select(string,pfad,name,"*.*");
         if(c)
         {
            strcpy(&k_names[filecount][0],pfad);
            strcat(&k_names[filecount][0],name);
            k_string[filecount]=&k_names[filecount][0];
            filecount++;
         }
      }while(filecount<20&&c);
      if(filecount==0)
         return;
      sprintf(string,FORM01,filecount);
      if(brain_alert(1,string)==2)
         return;
   }

   eol = CR;
   quote = '#';
   pad = 0;
   padchar = NULL;


   escchr = ESCCHR;

   x = OB_X(proto_di,XMODEMDI);
   ptadr(proto_di,XMFILNAM,0);
   ptadr(proto_di,XM_INOUT,0);
   strcpy(ptadr(proto_di,XMBLKANZ,0),"???");
   ptadr(proto_di,XM___ERR,0);
   objc_xywh(mainmenu,buf,&menbuf);
   form_center(proto_di,&box.g_x,&box.g_y,&box.g_w,&box.g_h);

   if(debug)
   {
      wind_get(0,WF_WORKXYWH,&win.g_x,&win.g_y,&win.g_w,&win.g_h);
#ifdef COLOR
      win.g_x=(box.g_w&0xfff0)+15;
      win.g_w=((640-box.g_w)&0xfff0)+2;
#else
      win.g_x=(box.g_w&0xfff0)-1;
      win.g_w=((640-box.g_w)&0xfff0)+2;
#endif
      win.g_y+=5;
      win.g_h-=10;

      wi_kerm=wind_create((NAME|MOVER|INFO),win);
      if(wi_kerm<=0)
      {
         brain_alert(1,FORM02);
         debug=0;
      }
   }	

   if(debug)
   {
      box.g_x=OB_X(proto_di,0)=0;
      OB_WIDTH(proto_di,0)--;
      sprintf(string,STRING02,debug);
      wind_set(wi_kerm,WF_NAME,string);
      wind_set(wi_kerm,WF_INFO,STRING03);
      hide_mouse();
      onli_vt52=0;
      wind_open(wi_kerm,win);
      set_xy_cur(wi_kerm);
      clr_window(wi_kerm);
      when_cr=max_xcur;
      show_mouse();
      mouseset(1);
   
      prinwin(STRING04,debug);

      if(what)
         prinwin(STRING05);
      else
         prinwin(STRING06);
    
   }
   graf_growbox(menbuf,box);
   form_dial(1,0l,0l,box);
   objc_draw(proto_di,0,8,SXY,SWH);

   asm
   {
      LEA      VAR_TEMP(PC), A0
      MOVE.L   A6, (A0)+
      MOVE.L   A7, (A0)
      BRA      OVER_VAR

VAR_TEMP:
      DC.W     0X4E71,0X4E71,0X4E71,0X4E71
OVER_VAR:
   }

   fp = NULL;
   filelist = (char **)k_string;
   filnam = *filelist++;
   filecount--;
   a=sw(what);
   Bconout(2,7);

   asm
   {
OUT_KERMIT:
      LEA      VAR_TEMP(PC), A0
      MOVEA.L  (A0)+, A6
      MOVEA.L  (A0), A7
   }

   if(debug)
   {
      hide_mouse();
      OB_X(proto_di,0)=x;
      OB_WIDTH(proto_di,0)++;
      wind_close(wi_kerm);
      wind_delete(wi_kerm);
      when_cr=old_when_cr;
      onli_vt52 = vt_save;
      set_xy_cur(top_window);
      mouseset(0,0);
      show_mouse();
   }

   graf_shrink(menbuf,box);
   form_dial(3,0l,SXY,SWH);

   if(online)
      wind_update(BEG_MCTRL);
}
