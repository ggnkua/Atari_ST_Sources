/*  @(#)CD-REC 1.03, Dirk Haun, 06.07.1995
 */

#define __MAIN
#define HEXVERSION 0x0103

#include <stdio.h>
#include <portab.h>
#include <tos.h>
#include <string.h>
#include <mystring.h>
#include <stdlib.h>
#include <stdtos.h>
#include <aes.h>
#include <aesmore.h>
#include <mygem.h>
#include <terralib.h>
#include <mapkey.h>
#include <ctype.h>
#include "cd.h"
#include "cdrec.h"
#include "cdrec.rh"

#define ENSMEM -39

#define FIRSTTR  TRACK01
#define LASTTR   TRACK48

/* Header eines AVR-Samples */

typedef struct
{
 long magic;             /* ="2BIT"; */
 char name[8];           /* null-padded sample name */
 short mono;             /* 0 = mono, 0xffff = stereo */
 short rez;              /* 8 = 8 bit, 16 = 16 bit */
 short sign;             /* 0 = unsigned, 0xffff = signed */
 short loop;             /* 0 = no loop, 0xffff = looping sample */
 short midi;             /* 0xffff = no MIDI note assigned,
                            0xffXX = single key note assignment
                            0xLLHH = key split, low/hi note */
 long rate;              /* sample frequency in hertz */
 long size;              /* sample length in bytes or words (see rez) */
 long lbeg;              /* offset to start of loop in bytes or words.
                            set to zero if unused. */
 long lend;              /* offset to end of loop in bytes or words.
                            set to sample length if unused. */
 short res1;             /* Reserved, MIDI keyboard split */
 short res2;             /* Reserved, sample compression */
 short res3;             /* Reserved */
 char ext[20];           /* Additional filename space, used
                            if (name[7] != 0) */
 char user[64];          /* User defined. Typically ASCII message. */
} AVR_HEAD;

typedef struct
{
 long main_chunk;
 long main_length;
 long chunk_type;
 long sub_chunk;
 long sub_length;
 int format;
 int modus;
 long sample_fq;
 long byte_p_sec;
 int byte_p_spl;
 int bit_p_spl;
 long data_chunk;
 long data_length;
} WAV_HEAD;

#define AVR 1
#define WAV 2

struct cdrom_msf tracktime[100];
unsigned char trackflags[100];
int x, y, w, h, tracks, first_track, last_track, drv=-1, __magx,
    bits=16, half=FALSE, stereo=TRUE, format=AVR, three_d=FALSE;
OBJECT *tree;
char path[128], fname[16], logpath[128];

#define min(a,b) (a<b ? a : b)
#define fileselect(a,b,c,d) file_select(a,a,b,c,d)
int file_select(char *pfname, char *pname, char *fname, const char *ext, char *title);
void record(void);
int do_dialog(OBJECT *tree,int *ed_obj);
void init_objects(void);
void hide_buttons(int anz);
void calc_size(struct cdrom_msf *time);
void disable_ret(void);
extern void wri_long(void *intel,long motorola);
extern void wri_int(void *intel,int motorola);
extern int intel_int(void *adr);

void edit2time(const char *string,int *min,int *sec,int *frame)
{
 char z[10], *cp=(char*)string;

 memcpy(z,cp,2); z[2]='\0';
 *min=atoi(z);
 cp+=2;
 memcpy(z,cp,2); z[2]='\0';
 *sec=atoi(z);
 cp+=2;
 memcpy(z,cp,2); z[2]='\0';
 *frame=atoi(z);
}

void update_size(void)
{
 int min, sec, frame;
 struct cdrom_msf calc;

 edit2time(tree[EDSTART].ob_spec.tedinfo->te_ptext,&min,&sec,&frame);
 calc.cdmsf_min0=min;
 calc.cdmsf_sec0=sec;
 calc.cdmsf_frame0=frame;
 edit2time(tree[EDEND].ob_spec.tedinfo->te_ptext,&min,&sec,&frame);
 calc.cdmsf_min1=min;
 calc.cdmsf_sec1=sec;
 calc.cdmsf_frame1=frame;
 calc_size(&calc);
 objc_draw(tree,RECSIZE,1,x,y,w,h);
}

int main(void)
{
 int ret, i, j, curtrindex, min, sec, frame, editobj=EDSTART;
 long d;
 META_INFO_1 m1;
 META_DRVINFO md;
 struct cdrom_tochdr tn;
 struct cdrom_tocentry te;
 struct cdrom_msf play;
 struct cdrom_subchnl pos;

 if((gl_apid=appl_init())<0) return(ENSMEM);
 i=Dgetdrv();
 Dgetpath(logpath,i+1);
 if(logpath[0]=='\0' || lastchr(logpath)!='\\') chrcat(logpath,'\\');
 strcat(logpath,"cd-rec.log");
 if(logpath[1]!=':')
 {
  insert(logpath,0,"A:");
  logpath[0]=i+'A';
 }
 __magx=InqMagX();
 if(__magx<0) __magx=0;
 init_objects();
 path[0]='\0'; strcpy(fname,"cdrec.avr");
 memset(&m1,0,sizeof(META_INFO_1));
 Metainit(&m1);
 if(m1.mi_drivemap)
 {
  d=1;
  for(i=0;i<32;i++)
  {
   if(m1.mi_drivemap&d)
   {
    memset(&md,0,sizeof(META_DRVINFO));
    if(Metaopen(i+'A',&md)==0)
    {
     if(md.mdr_name)
     {
      if(drv<0 && md.mdr_name[0]=='C' && md.mdr_name[1]=='D') drv=i+'A';
     }
    }
    Metaclose(i+'A');
    if(drv>0) break;
   }
   d<<=1;
  }
  if(drv>=0)
  {
   do
   {
    memset(&md,0,sizeof(META_DRVINFO));
    tracks=-1;
    if(Metaopen(drv,&md)==0)
    {
     if(Metaioctl(drv,'FCTL',CDROMREADTOCHDR,&tn)<0) break;
     if(tn.cdth_trk0==0 && tn.cdth_trk1==0)
     {
      Metaclose(drv);
      tracks=0;
      set_mouse(ARROW);
      i=form_alert(1,"[2][CD-REC:|Keine CD eingelegt?][nochmal| Abbruch ]");
      if(i==2) break;
     }
     else tracks=tn.cdth_trk1-tn.cdth_trk0+1;
    }
    else break;
   }
   while(tracks<=0);
   if(tracks>0)
   {
    first_track=tn.cdth_trk0;
    last_track=tn.cdth_trk1;
    for(i=first_track;i<=last_track;i++)
    {
     j=i-first_track;
     memset(&te,0,sizeof(struct cdrom_tocentry));
     te.cdte_track=i;
     te.cdte_format=CDROM_MSF;
     Metaioctl(drv,'FCTL',CDROMREADTOCENTRY,&te);
     tracktime[j].cdmsf_min0=te.dte_addr.msf.minute;
     tracktime[j].cdmsf_sec0=te.dte_addr.msf.second;
     tracktime[j].cdmsf_frame0=te.dte_addr.msf.frame;
     if(j>0)
     {
      tracktime[j-1].cdmsf_min1=te.dte_addr.msf.minute;
      tracktime[j-1].cdmsf_sec1=te.dte_addr.msf.second;
      tracktime[j-1].cdmsf_frame1=te.dte_addr.msf.frame;
     }
     trackflags[j]=te.cdte_ctrl;
    }
    j=i-first_track;
    memset(&te,0,sizeof(struct cdrom_tocentry));
    te.cdte_track=CDROM_LEADOUT;
    te.cdte_format=CDROM_MSF;
    Metaioctl(drv,'FCTL',CDROMREADTOCENTRY,&te);
    tracktime[j-1].cdmsf_min1=te.dte_addr.msf.minute;
    tracktime[j-1].cdmsf_sec1=te.dte_addr.msf.second;
    tracktime[j-1].cdmsf_frame1=te.dte_addr.msf.frame;

    for(i=FIRSTTR;i<=LASTTR;i++) tree[i].ob_state&=~SELECTED;
    hide_buttons(tracks);
    for(i=first_track;i<=last_track;i++)
    {
     j=i-first_track;
     if((trackflags[j]&4)==0)
     {
      tree[j+FIRSTTR].ob_state|=SELECTED;
      curtrindex=j;
      break;
     }
    }
    sprintf(tree[EDSTART].ob_spec.tedinfo->te_ptext,"%02d%02d%02d",tracktime[curtrindex].cdmsf_min0,tracktime[curtrindex].cdmsf_sec0,tracktime[curtrindex].cdmsf_frame0);
    sprintf(tree[EDEND].ob_spec.tedinfo->te_ptext,"%02d%02d%02d",tracktime[curtrindex].cdmsf_min1,tracktime[curtrindex].cdmsf_sec1,tracktime[curtrindex].cdmsf_frame1);
    calc_size(&tracktime[curtrindex]);

    wind_update(BEG_UPDATE);
    wind_update(BEG_MCTRL);
    form_center(tree,&x,&y,&w,&h);
    form_dial(FMD_START,0,0,0,0,x,y,w,h);
    objc_draw(tree,ROOT,MAX_DEPTH,x-3,y-3,w+6,h+6);
    set_mouse(ARROW);
    do
    {
     ret=do_dialog(tree,&editobj);
     if(ret>=FIRSTTR && ret<=LASTTR)
     {
      i=ret-FIRSTTR;
      curtrindex=i;
      sprintf(tree[EDSTART].ob_spec.tedinfo->te_ptext,"%02d%02d%02d",tracktime[i].cdmsf_min0,tracktime[i].cdmsf_sec0,tracktime[i].cdmsf_frame0);
      sprintf(tree[EDEND].ob_spec.tedinfo->te_ptext,"%02d%02d%02d",tracktime[i].cdmsf_min1,tracktime[i].cdmsf_sec1,tracktime[i].cdmsf_frame1);
      objc_draw(tree,EDSTART,1,x,y,w,h);
      objc_draw(tree,EDEND,1,x,y,w,h);
      calc_size(&tracktime[i]);
      objc_draw(tree,RECSIZE,1,x,y,w,h);
     }
     else switch(ret)
     {
      case CDSAVE:   update_size();
                     record();
                     Metaioctl(drv,'FCTL',CDROMPAUSE,0L);
                     objc_change(tree,ret,0,x,y,w,h,NORMAL,TRUE);
                     break;
      case PLYSTART: edit2time(tree[EDSTART].ob_spec.tedinfo->te_ptext,&min,&sec,&frame);
                     play.cdmsf_min0=min;
                     play.cdmsf_sec0=sec;
                     play.cdmsf_frame0=frame;
                     edit2time(tree[EDEND].ob_spec.tedinfo->te_ptext,&min,&sec,&frame);
                     play.cdmsf_min1=min;
                     play.cdmsf_sec1=sec;
                     play.cdmsf_frame1=frame;
                     Metaioctl(drv,'FCTL',CDROMPLAYMSF,&play);
                     calc_size(&play);
                     objc_draw(tree,RECSIZE,1,x,y,w,h);
                     objc_change(tree,ret,0,x,y,w,h,NORMAL,TRUE);
                     break;
      case PLYEND:   edit2time(tree[EDEND].ob_spec.tedinfo->te_ptext,&min,&sec,&frame);
                     play.cdmsf_min1=min;
                     play.cdmsf_sec1=sec;
                     play.cdmsf_frame1=frame;
                     if(sec>5) sec-=5;
                     else
                     {
                      if(min>0)
                      {
                       i=min*60+sec;
                       i-=5;
                       min=i/60;
                       sec=i%60;
                      }
                      else
                      {
                       min=0;
                       sec=2;
                       frame=0;
                      }
                     }
                     play.cdmsf_sec0=sec;
                     play.cdmsf_min0=min;
                     play.cdmsf_frame0=frame;
                     Metaioctl(drv,'FCTL',CDROMPLAYMSF,&play);
                     update_size();
                     objc_change(tree,ret,0,x,y,w,h,NORMAL,TRUE);
                     break;
      case STOPIT:   memset(&pos,0,sizeof(struct cdrom_subchnl));
                     pos.cdsc_format=CDROM_MSF;
                     Metaioctl(drv,'FCTL',CDROMSUBCHNL,&pos);
                     sprintf(tree[CURPOS].ob_spec.tedinfo->te_ptext,"%02d%02d%02d",pos.cdsc_absaddr.msf.minute,pos.cdsc_absaddr.msf.second,pos.cdsc_absaddr.msf.frame);
                     Metaioctl(drv,'FCTL',CDROMPAUSE,0L);
                     objc_draw(tree,CURPOS,1,x,y,w,h);
                     objc_change(tree,ret,0,x,y,w,h,NORMAL,TRUE);
                     break;
      case TAKEST:   edit2time(tree[CURPOS].ob_spec.tedinfo->te_ptext,&min,&sec,&frame);
                     if(min || sec || frame)
                     {
                      play.cdmsf_min0=min;
                      play.cdmsf_sec0=sec;
                      play.cdmsf_frame0=frame;
                      sprintf(tree[EDSTART].ob_spec.tedinfo->te_ptext,"%02d%02d%02d",min,sec,frame);
                      calc_size(&play);
                      objc_draw(tree,RECSIZE,1,x,y,w,h);
                      objc_draw(tree,EDSTART,1,x,y,w,h);
                      editobj=EDSTART;
                     }
                     objc_change(tree,ret,0,x,y,w,h,NORMAL,TRUE);
                     break;
      case TAKEEN:   edit2time(tree[CURPOS].ob_spec.tedinfo->te_ptext,&min,&sec,&frame);
                     if(min || sec || frame)
                     {
                      play.cdmsf_min1=min;
                      play.cdmsf_sec1=sec;
                      play.cdmsf_frame1=frame;
                      sprintf(tree[EDEND].ob_spec.tedinfo->te_ptext,"%02d%02d%02d",min,sec,frame);
                      calc_size(&play);
                      objc_draw(tree,RECSIZE,1,x,y,w,h);
                      objc_draw(tree,EDEND,1,x,y,w,h);
                      editobj=EDEND;
                     }
                     objc_change(tree,ret,0,x,y,w,h,NORMAL,TRUE);
                     break;
      case STEREO:   stereo=TRUE;
                     update_size();
                     break;
      case MONO:     stereo=FALSE;
                     update_size();
                     break;
      case EIGHT:    bits=8;
                     update_size();
                     break;
      case SIXTEEN:  bits=16;
                     update_size();
                     break;
      case HALFFREQ: half=!half;
                     update_size();
                     break;
      case SAVEAVR:  format=AVR;
                     update_size();
                     break;
      case SAVEWAV:  format=WAV;
                     update_size();
                     break;
     }
    }
    while(ret!=CDCANCEL);
    form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
    /* Metaioctl(drv,'FCTL',CDROMPAUSE,0L); st”rt bei Toshiba 3401? */
    Metaclose(drv);

    wind_update(END_MCTRL);
    wind_update(END_UPDATE);
   }
   else if(tracks<0)
   {
    set_mouse(ARROW);
    form_alert(1,"[2][CD-REC:|Metaioctl() fehlgeschlagen!|Vermutlich untersttzt der|Treiber keine Audio-Kommandos.][ Abbruch ]");
   }
  }
  else
  {
   set_mouse(ARROW);
   form_alert(1,"[2][CD-REC:|Kein CD-ROM gefunden!][ Abbruch ]");
  }
 }
 else
 {
  set_mouse(ARROW);
  form_alert(1,"[2][CD-REC:|Kein MetaDOS? Oder kein passender|Treiber?|Jedenfalls geht\'s nicht!][ Abbruch ]");
 }
 appl_exit();
 return(0);
}

void dreher(char *start,char *end) /* Intel l„žt gržen ... */
{
 char *p=start;

 while(start<end)
 {
  *p++=*(start+1);
  *p++=*start;
  start+=2;
 }
}

static void make_unsigned(char *start,char *stop)
{
 while(stop>start) *--stop+=128;
}

void eightbits(char *buffer,long len)
{
 char *rp, *wp;
 long i;

 rp=wp=buffer;
 if(format==AVR)
 {
  for(i=0;i<len;i+=2)
  {
   *wp++=*rp;
   rp+=2;
  }
 }
 else
 {
  for(i=0;i<len;i+=2)
  {
   rp++;
   *wp++=*rp++;
  }
 }
}

void half_freq(void *buffer,long len)
{
 int *rw, *ww, bsum;
 char *rb, *wb;
 long i, wsum;

 if(stereo)
 {
  if(bits==8)
  {
   rb=wb=buffer;
   for(i=0;i<len;i+=4)
   {
    bsum=*rb;
    bsum+=*(rb+2);
    *wb++=(char)(bsum/2);
    bsum=*(rb+1);
    bsum+=*(rb+3);
    *wb++=(char)(bsum/2);
    rb+=4;
   }
  }
  else
  {
   rw=ww=buffer;
   if(format==AVR)
   {
    for(i=0;i<len;i+=8)
    {
     wsum=*rw;
     wsum+=*(rw+2);
     *ww++=(int)(wsum/2);
     wsum=*(rw+1);
     wsum+=*(rw+3);
     *ww++=(int)(wsum/2);
     rw+=4;
    }
   }
   else
   {
    for(i=0;i<len;i+=8)
    {
     wsum=intel_int(rw);
     wsum+=intel_int(rw+2);
     wri_int(ww++,(int)(wsum/2));
     wsum=intel_int(rw+1);
     wsum+=intel_int(rw+3);
     wri_int(ww++,(int)(wsum/2));
     rw+=4;
    }
   }
  }
 }
 else
 {
  if(bits==8)
  {
   rb=wb=buffer;
   for(i=0;i<len;i+=2)
   {
    bsum=*rb++;
    bsum+=*rb++;
    *wb++=(char)(bsum/2);
   }
  }
  else
  {
   if(format==AVR)
   {
    for(i=0;i<len;i+=4)
    {
     wsum=*rw++;
     wsum+=*rw++;
     *ww++=(int)(wsum/2);
    }
   }
   else
   {
    for(i=0;i<len;i+=4)
    {
     wsum=intel_int(rw++);
     wsum+=intel_int(rw++);
     wri_int(ww++,(int)(wsum/2));
    }
   }
  }
 }
}

void make_mono(void *buffer,long len)
{
 long i, wsum;
 int *rw, *ww, bsum;
 char *rb, *wb;

 if(bits==8)
 {
  rb=wb=buffer;
  for(i=0;i<len;i+=2)
  {
   bsum=*rb++;
   bsum+=*rb++;
   *wb++=(char)(bsum/2);
  }
 }
 else /* if(bits==16) */
 {
  rw=ww=buffer;
  if(format==AVR)
  {
   for(i=0;i<len;i+=4)
   {
    wsum=*rw++;
    wsum+=*rw++;
    *ww++=(int)(wsum/2);
   }
  }
  else
  {
   for(i=0;i<len;i+=4)
   {
    wsum=intel_int(rw++);
    wsum+=intel_int(rw++);
    wri_int(ww++,(int)(wsum/2));
   }
  }
 }
}

void set_counter(int cnt)
{
 int i;
 char *cp=tree[COUNTER].ob_spec.tedinfo->te_ptext;

 sprintf(cp,"%03d",cnt);
 for(i=0;i<3;i++,cp++) *cp=(*cp)-32;
 objc_draw(tree,COUNTER,1,x,y,w,h);
}

void logfile(char *fname)
{
 int min0, min1, sec0, sec1, frame0, frame1;
 char date[16], time[16];
 FILE *log;

 log=fopen(logpath,"a");
 if(log)
 {
  edit2time(tree[EDSTART].ob_spec.tedinfo->te_ptext,&min0,&sec0,&frame0);
  edit2time(tree[EDEND].ob_spec.tedinfo->te_ptext,&min1,&sec1,&frame1);
  gdtoa(Tgetdate(),date);
  gttoa(Tgettime(),time);
  fprintf(log,"* %s %s %-12s %02d:%02d.%02d-%02d:%02d.%02d\n",date,time,fname,min0,sec0,frame0,min1,sec1,frame1);
  fclose(log);
 }
}

void record(void)
{
 int fh, pos, min, sec, frame, cnt;
 long t, mem, realsize, st, et, offset, rate, ret;
 char *buffer, *cp, alert[128];
 struct cdrom_read rd;
 AVR_HEAD avr;
 WAV_HEAD wav;

 if(fname[0]=='\0') strcpy(fname,(format==AVR ? "cdrec.avr" : "cdrec.wav"));
 else
 {
  cp=strchr(fname,'.');
  if(!cp)
  {
   chrcat(fname,'.');
   cp=fname+strlen(fname)-1;
  }
  strcpy(cp+1,(format==AVR ? "avr" : "wav"));
 }
 offset=2*75; /* 2-Sekunden-Offset */
 edit2time(tree[EDSTART].ob_spec.tedinfo->te_ptext,&min,&sec,&frame);
 t=min;
 t*=60;
 t+=sec;
 t*=75;
 t+=frame;
 t-=offset;
 st=t;
 edit2time(tree[EDEND].ob_spec.tedinfo->te_ptext,&min,&sec,&frame);
 t=min;
 t*=60;
 t+=sec;
 t*=75;
 t+=frame;
 t-=offset;
 et=t;
 t=et-st;
 t*=2352;
 mem=t;
 do
 {
  buffer=Malloc(mem);
  if(buffer==0L)
  {
   mem/=2;
   mem/=2352;
   mem*=2352;
  }
 }
 while(buffer==0L && mem>16384L);
 if(buffer)
 {
  if(fileselect(path,fname,(format==AVR ? "*.avr" : "*.wav"),"Speichern als ...") && fname[0])
  {
   set_mouse(BUSYBEE);
   fh=(int)Fcreate(path,0);
   if(fh>0)
   {
    logfile(fname);
    cnt=(int)(t/mem);
    if(cnt*mem<t) cnt++;
    set_counter(cnt);
    realsize=t;
    if(bits==8) realsize/=2;
    if(half) realsize/=2;
    if(!stereo) realsize/=2;
    if(format==AVR)
    {
     memset(&avr,0,sizeof(AVR_HEAD));
     avr.magic='2BIT';
     avr.mono=(stereo ? 0xffff : 0);
     avr.rez=bits;
     avr.sign=0xffff;
     avr.midi=0xffff;
     avr.rate=44100L;
     if(half) avr.rate/=2;
     avr.size=realsize/2; /* size in Words(!) */
     pos=chrfind(fname,'.');
     if(pos>0) memcpy(avr.name,fname,min(8,pos));
     strcpy(avr.user,"CD-REC ");
     strcat(avr.user,&tree[TITEL].ob_spec.free_string[strlen(tree[TITEL].ob_spec.free_string)-4]);
     /*strcat(avr.user,", written by Dirk Haun");*/
     Fwrite(fh,sizeof(AVR_HEAD),&avr);
    }
    else
    {
     memset(&wav,0,sizeof(WAV_HEAD));
     wav.main_chunk='RIFF';
     wri_long(&wav.main_length,realsize+sizeof(WAV_HEAD));
     wav.chunk_type='WAVE';
     wav.sub_chunk='fmt ';
     wri_long(&wav.sub_length,16L);
     wri_int(&wav.format,1);
     wri_int(&wav.modus,(stereo ? 2 : 1));
     rate=(half ? 22050L : 44100L);
     wri_long(&wav.sample_fq,rate);
     if(bits==16) rate*=2;
     if(stereo) rate*=2;
     wri_long(&wav.byte_p_sec,rate);
     pos=1;
     if(bits==16) pos*=2;
     if(stereo) pos*=2;
     wri_int(&wav.byte_p_spl,pos);
     wri_int(&wav.bit_p_spl,bits);
     wav.data_chunk='data';
     wri_long(&wav.data_length,realsize);
     Fwrite(fh,sizeof(WAV_HEAD),&wav);
    }
    do
    {
     rd.cdread_lba=st;
     rd.cdread_bufaddr=buffer;
     rd.cdread_buflen=min(mem,t);
     ret=Metaioctl(drv,'FCTL',CDROMREADDA,&rd);
     if(ret<0)
     {
      sprintf(alert,"[2][CD-REC:|Fehler bei der Aufnahme|(Returncode %ld)!][ Abbruch ]");
      set_mouse(ARROW);
      form_alert(1,alert);
      break;
     }
     realsize=min(mem,t);
     if(format==AVR) dreher(buffer,buffer+mem);
     if(bits==8)
     {
      eightbits(buffer,realsize);
      realsize/=2;
     }
     if(half)
     {
      half_freq(buffer,realsize);
      realsize/=2;
     }
     if(!stereo)
     {
      make_mono(buffer,realsize);
      realsize/=2;
     }
     if(format==WAV && bits==8) make_unsigned(buffer,buffer+realsize);
     if(Fwrite(fh,realsize,buffer)!=realsize)
     {
      set_mouse(ARROW);
      form_alert(1,"[2][CD-REC:|Schreibfehler!|Evtl. Laufwerk voll?][ Abbruch ]");
      break;
     }
     t-=mem;
     if(t>0)
     {
      st+=(mem/2352);
      cnt--;
      set_counter(cnt);
     }
    }
    while(t>0);
    Fclose(fh);
    set_counter(0);
   }
   else
   {
    set_mouse(ARROW);
    form_alert(1,"[2][CD-REC:|Kann Ausgabedatei nicht ”ffnen!][ Abbruch ]");
   }
  }
  Mfree(buffer);
  set_mouse(ARROW);
 }
 else form_alert(1,"[2][CD-REC:|Sorry, nicht genug Speicher ...][ Abbruch ]");
}

/*---------------------------------------- Dialog-Krempel --------------------------------------------------------------*/

void objcxywh(OBJECT *tree, int obj, GRECT *p);
int formbutton(OBJECT *tree,int obj,int clicks,int *nextobj,int realclick);
int formkeybd(OBJECT *tree,int editobj,int kr,int *outobj,int *okr);

#define wobj_edit(tree,obj,inchar,idx,kind) objc_edit(tree,obj,inchar,idx,kind)

typedef struct
{
 int key, object;
} DIALKEY;

const DIALKEY keys[] = {
                        0x20                             , STOPIT,
                        (KbALT|'A')                      , CDCANCEL,
                        (KbSCAN|KbUNDO)                  , CDCANCEL,
                        13                               , CDSAVE,
                        (KbALT|'U')                      , CDSAVE,
                        0                                , -1
                       };

void disable_ret(void)
{
 int i;

 for(i=0;keys[i].object>0;i++)
 {
  if(keys[i].key==13)
  {
   keys[i].object=CDCANCEL;
   break;
  }
 }
}

int do_dialog(OBJECT *tree,int *ed_obj)
{
 int i, mkey, fm_cont, event, obj, nextobj, editobj, index=0;
 struct cdrom_subchnl pos;
 cd_ad old = { 0L };
 GRECT rect;
 EVENT evm = { MU_KEYBD|MU_BUTTON|MU_TIMER, 1, 1, 1, 0,0,0,0,0, 0,0,0,0,0, 200,0,
               0, 0,0,0,0,0,0, {0,0,0,0,0,0,0,0} };


 objcxywh(tree,ROOT,&rect);
 editobj=*ed_obj;
 if(editobj && (tree[editobj].ob_flags&EDITABLE)==0) editobj=0;
 if(editobj) wobj_edit(tree,editobj,0,&index,ED_INIT);
 do
 {
  event=EvntMulti(&evm);
  fm_cont=TRUE;
  if(event&MU_BUTTON)
  {
   obj=objc_find(tree,ROOT,MAX_DEPTH,evm.ev_mmox,evm.ev_mmoy);
   if(obj<0) bell();
   else if(tree[obj].ob_flags&(SELECTABLE|TOUCHEXIT))
   {
    fm_cont=formbutton(tree,obj,evm.ev_mbreturn,&obj,TRUE);
   }
  }
  if(event&MU_KEYBD)
  {
   mkey=MapKey(evm.ev_mkreturn);
   if((mkey&KbNUM) && (mkey&0xff00)==KbNUM) mkey&=0x8fff;
   else mkey&=0xcfff;
   if((mkey&(KbSCAN|KbNUM))==0 && (mkey&0xff)>=32) mkey=(mkey&0xfc00)|toupper(mkey&0xff);
   if(mkey&KbSHIFT) mkey|=KbSHIFT;
   obj=0;
   for(i=0;keys[i].key;i++)
   {
    if(mkey==keys[i].key)
    {
     obj=keys[i].object;
     if(!(tree[obj].ob_flags&(SELECTABLE|TOUCHEXIT))) obj=0;
     break;
    }
   }
   if(obj>0)
   {
    if(tree[obj].ob_flags&(SELECTABLE|TOUCHEXIT)) fm_cont=formbutton(tree,obj,1,&obj,FALSE);
   }
   else if(obj==0 && editobj)
   {
    fm_cont=formkeybd(tree,editobj,evm.ev_mkreturn,&nextobj,&evm.ev_mkreturn);
   }
   if(evm.ev_mkreturn)
   {
    if(!(mkey&KbALT) && !(mkey&KbCONTROL) && evm.ev_mkreturn!=0x6200/* && !(mkey&KbSCAN)*/)
    {
     wobj_edit(tree,editobj,evm.ev_mkreturn,&index,ED_CHAR);
    }
   }
   if((fm_cont) && (nextobj) && (nextobj!=editobj))
   {
    wobj_edit(tree,editobj,0,&index,ED_END);
    wobj_edit(tree,nextobj,0,&index,ED_INIT);
    editobj=nextobj;
   }
  }
  if(event==MU_TIMER) /* nur(!) Timer */
  {
   memset(&pos,0,sizeof(struct cdrom_subchnl));
   pos.cdsc_format=CDROM_MSF;
   Metaioctl(drv,'FCTL',CDROMSUBCHNL,&pos);
   if(pos.cdsc_audiostatus!=0x11) memset(&pos.cdsc_absaddr,0,sizeof(cd_ad));
   if(pos.cdsc_absaddr.lba!=old.lba)
   {
    sprintf(tree[CURPOS].ob_spec.tedinfo->te_ptext,"%02d%02d%02d",pos.cdsc_absaddr.msf.minute,pos.cdsc_absaddr.msf.second,pos.cdsc_absaddr.msf.frame);
    objc_draw(tree,CURPOS,1,rect.g_x,rect.g_y,rect.g_w,rect.g_h);
    old=pos.cdsc_absaddr;
   }
  }
 }
 while(fm_cont);
 if(editobj) wobj_edit(tree,editobj,0,&index,ED_END);
 *ed_obj=editobj;
 return(obj);
}

void objcxywh(OBJECT *tree, int obj, GRECT *p)
{
 int type, frame;

 objc_offset(tree, obj, &p->g_x, &p->g_y);
 p->g_w = tree[obj].ob_width;
 p->g_h = tree[obj].ob_height;
 if(obj && tree[obj].ob_flags&FL3DMASK) /* 3D-Objekt */
 {
  p->g_x-=2; p->g_y-=2;
  p->g_w+=4; p->g_h+=4;
 }
 else if(tree[obj].ob_state&OUTLINED)
 {
  p->g_x-=3; p->g_y-=3;
  p->g_w+=6; p->g_h+=6;
 }
 else
 {
  type=tree[obj].ob_type&0xff;
  if(type==G_BOXCHAR || type==G_BOX || type==G_IBOX)
  {
   frame=tree[obj].ob_spec.obspec.framesize;
   if(frame<0)
   {
    p->g_x+=frame;
    p->g_y+=frame;
    p->g_w-=(frame+frame);
    p->g_h-=(frame+frame);
   }
  }
 }
}

void objctoggle(OBJECT *tree,int obj)             /* Reverse the SELECT state of an object, and redraw */
{                                                        /* it immediately.          */
 int state, newstate, ch=FALSE;
 GRECT root, gob, desk;

 objcxywh(tree,ROOT,&root);
 objcxywh(tree,obj,&gob);
 state=tree[obj].ob_state;
 newstate=state^SELECTED;
 wind_get(0,WF_WORKXYWH,&desk.g_x,&desk.g_y,&desk.g_w,&desk.g_h);
 hide_mouse();
 objc_change(tree,obj,0,root.g_x,root.g_y,root.g_w,root.g_h,newstate,1);
 ch=TRUE;
 show_mouse();
 if(!ch) tree[obj].ob_state=newstate;
}

static void objcsel(OBJECT *tree,int obj)                /* If the object is not already SELECTED, make it so. */
{
 if(!(tree[obj].ob_state&SELECTED)) objctoggle(tree,obj);
}

static void objcdsel(OBJECT *tree,int obj)               /* If the object is SELECTED, deselect it. */
{
 if(tree[obj].ob_state&SELECTED) objctoggle(tree,obj);
}

#define NIL (-1)

static int getparent(OBJECT *tree,int obj)               /* Find the parent object of by traversing right until we */
{                                                        /* find nodes whose NEXT and TAIL links point to each other. */
 int pobj;

 if(obj==NIL) return(NIL);
 pobj=tree[obj].ob_next;
 if(pobj!=NIL)
 {
  while(tree[pobj].ob_tail!=obj)
  {
   obj=pobj;
   pobj=tree[obj].ob_next;
  }
 }
 return(pobj);
}

static void doradio(OBJECT *tree,int obj)
{
 GRECT root;
 int pobj, sobj;

 objcxywh(tree,ROOT,&root);
 pobj=getparent(tree,obj);                               /* Get the object's parent */
 for(sobj=tree[pobj].ob_head;sobj!=pobj;sobj=tree[sobj].ob_next)
 {                                                       /* Deselect all but...     */
  if(sobj!=obj) objcdsel(tree,sobj);
 }
 objcsel(tree,obj);                                      /* the one being SELECTED  */
}

static int formbutton(OBJECT *tree,int obj,int clicks,int *nextobj,int realclick)
{
 int flags, state, hibit, texit, sble, dsbld, edit, instate, wbexit;

 flags=tree[obj].ob_flags;                               /* Get flags and states   */
 state=tree[obj].ob_state;
 texit=flags&TOUCHEXIT;
 sble=flags&SELECTABLE;
 dsbld=state&DISABLED;
 edit=flags&EDITABLE;
 if(!texit && (!sble || dsbld) && !edit)                 /* This is not an      */
 {                                                       /* interesting object  */
  *nextobj=0;
  return(TRUE);
 }
 if(texit && clicks==2) hibit=0x8000;                    /* Preset special flag  */
 else hibit=0x0;
 if(sble && !dsbld)                                      /* Hot stuff!           */
 {
  if(flags&RBUTTON) doradio(tree,obj);                   /* Process radio buttons immediately! */
  else if(!texit)
  {
   instate=state^SELECTED;                               /* Already toggled ? */
   if(realclick)
   {
    wbexit=graf_watchbox(tree,obj,instate,instate^SELECTED);
    if(!wbexit)
    {                                                     /* He gave up...  */
     *nextobj=0;
     return(TRUE);
    }
   }
   else objctoggle(tree,obj);
  }
  else objctoggle(tree,obj);            /* Force SELECTED       */
 }
 if(texit || (flags&EXIT))                               /* Exit conditions.             */
 {
  *nextobj=obj|hibit;
  return(FALSE);                                         /* Time to leave!               */
 }
 else if(!edit) *nextobj=0;                              /* Clear object unless tabbing  */
 return (TRUE);
}

static int fnobj, fndir, fnprev, fnlast;

static int finddef(OBJECT *tree,int obj)                 /* Check if the object is DEFAULT       */
{
 if(HIDETREE&tree[obj].ob_flags) return(FALSE);          /* Is sub-tree hidden?                  */
 if(DEFAULT&tree[obj].ob_flags)                          /* Must be DEFAULT and not DISABLED     */
   if(!(DISABLED&tree[obj].ob_state)) fnobj=obj;         /* Record object number                 */
 return (TRUE);
}

static int findtab(OBJECT *tree,int obj)                 /* Look for target of TAB operation.    */
{
 if(HIDETREE&tree[obj].ob_flags) return(FALSE);          /* Check for hiddens subtree.           */
 if(!(EDITABLE&tree[obj].ob_flags)) return(TRUE);        /* If not EDITABLE, who cares?          */
 if(fndir && fnprev==fnlast) fnobj=obj;                  /* Check for forward tab match          */
 if(!fndir && obj==fnlast) fnobj=fnprev;                 /* Check for backward tab match         */
 fnprev=obj;                                             /* Record object for next call.         */
 return(TRUE);
}

static void maptree(OBJECT *tree,int this,int last,int (*routine)(OBJECT *tree,int obj))
{                                                        /* Non-cursive traverse of an object tree. */
 int tmp1;

 tmp1=this;                                              /* Initialize to impossible value: */
                                                         /* TAIL won't point to self!       */
                                                         /* Look until final node, or off   */
                                                         /* the end of tree                 */
 while(this!=last && this!=NIL)                          /* Did we 'pop' into this node for the second time? */
   if(tree[this].ob_tail!=tmp1)
   {
    tmp1=this;                                           /* This is a new node       */
    this=NIL;
                                                         /* Apply operation, testing for rejection of sub-tree */
    if((*routine)(tree,tmp1)) this=tree[tmp1].ob_head;   /* Subtree path not taken, so traverse right         */
    if(this==NIL) this=tree[tmp1].ob_next;
   }
   else                                                  /* Revisiting parent: No operation, move right  */
   {
    tmp1=this;
    this=tree[tmp1].ob_next;
   }
}

#ifdef TAB
# undef TAB
#endif
#define TAB     0x0009
#ifdef CR
# undef CR
#endif
#define CR      0x000D
#define BTAB    0x0f00
#define UP      0x4800
#define DOWN    0x5000

static int formkeybd(OBJECT *tree,int editobj,int kr,int *outobj,int *okr)
{
 if(kr&0xff) kr&=0xff;                                   /* If lower byte valid, mask out extended code byte. */
 fndir=0;                                                /* Default tab direction if backward.   */
 *outobj=0;
 switch(kr)
 {
  case CR:   *okr=0;                                     /* Zap character.                       */
             fnobj=NIL;                                  /* Look for a DEFAULT object.           */
             maptree(tree,ROOT,NIL,finddef);
             if(fnobj!=NIL)                              /* If found, SELECT and force exit.     */
             {
              objcsel(tree,fnobj);
              *outobj=fnobj;
              return(FALSE);
             }                                           /* Falls through to     */
  case TAB:                                              /* tab if no default    */
  case DOWN: fndir=1;                                    /* Set fwd direction    */
  case BTAB:
  case UP:   *okr=0;                                     /* Zap character        */
             fnlast=editobj;
             fnprev=fnobj=NIL;                           /* Look for TAB object    */
             maptree(tree,ROOT,NIL,findtab);
             if(fnobj==NIL) maptree(tree,ROOT,NIL,findtab); /* try to wrap around   */
             if(fnobj!=NIL) *outobj=fnobj;
             break;
  default:   *outobj=editobj;
             return (TRUE);                              /* Pass other chars     */
 }
 return(TRUE);
}

int file_select(char *pfname, char *pname, char *fname, const char *ext, char *title)
{
	int	but;
	char	*p;
	long a;
	static unsigned int v_tos=0;

	if(v_tos==0) v_tos=tos_version();
  if(!fname[0])
	{
		p = strrchr(pfname, '\\');
		if(p)
			strcpy(fname, p+1);
		else
			strcpy(fname, pfname);
	}
	if(!pname[0])
	{
		p = strrchr(pfname, '\\');
		if(p)
		{
			p[1] = '\0';
			strcpy(pname, pfname);
		}
	}
	else if(pname[strlen(pname)-1] != '\\')
		strcat(pname, "\\");
	strcat(pname, ext);

	if(get_cookie('FSEL',&a) || (v_tos >= 0x0104))
		fsel_exinput(pname, fname, &but, title);
	else
		fsel_input(pname, fname, &but);
  objc_draw(tree,ROOT,MAX_DEPTH,tree[0].ob_x-3,tree[0].ob_y-3,tree[0].ob_width+6,tree[0].ob_height+6);

	p = strrchr(pname, '\\');
	if(p)
		*p = '\0';
	strcpy(pfname, pname);
	strcat(pfname, "\\");
	strcat(pfname, fname);
	return(but);
}

#define TRACKSPL 12
#define TRLINES  4

void init_objects(void)
{
 int i, j, xdiff, ydiff;
 char *cp;

 if(appl_xgetinfo(13,&i,&dummy,&dummy,&dummy))
 {
  if(i&1) three_d=TRUE;
 }
 tree=rs_trindex[MAIN];
 for(i=0;i<NUM_OBS;i++) rsrc_obfix(tree,i);
 tree[CDSAVE].ob_y--;
 tree[CDSAVE].ob_height+=2;
 tree[CDCANCEL].ob_y--;
 tree[CDCANCEL].ob_height+=2;
 cp=tree[TITEL].ob_spec.free_string;
 cp+=strlen(cp);
 cp-=4;
 *cp++=(HEXVERSION>>8)+'0';
 *cp++='.';
 *cp++=((HEXVERSION>>4)&0x0f)+'0';
 *cp++=(HEXVERSION&0x0f)+'0';
 tree[UNDERLINE].ob_x--;
 tree[UNDERLINE].ob_width+=2;
 xdiff=tree[FIRSTTR+1].ob_x-(tree[FIRSTTR].ob_x+tree[FIRSTTR].ob_width);
 ydiff=tree[FIRSTTR+TRACKSPL].ob_y-(tree[FIRSTTR].ob_y+tree[FIRSTTR].ob_height);
 if(ydiff>xdiff)
 {
  for(i=1;i<TRLINES;i++)
  {
   for(j=0;j<TRACKSPL;j++)
   {
    tree[FIRSTTR+i*TRACKSPL+j].ob_y-=((ydiff-xdiff)*i);
   }
  }
  j=(ydiff-xdiff)*3;
  tree[ROOT].ob_height-=j;
  tree[FIRSTTR-1].ob_height-=j;
  for(i=LASTTR+1;i<NUM_OBS;i++)
  {
   tree[i].ob_y-=j;
   if(tree[i].ob_head!=-1) i=tree[i].ob_next-1;
  }
 }
 if(__magx && three_d)
 {
  tree[EDSTART].ob_spec.tedinfo->te_thickness=-2;
  tree[EDEND].ob_spec.tedinfo->te_thickness=-2;
  tree[CURPOS].ob_spec.tedinfo->te_thickness=-2;
  tree[RECSIZE].ob_spec.tedinfo->te_thickness=-2;
 }
 if(three_d)
 {
  tree[COUNTER].ob_flags|=FL3DACT;
  tree[COUNTER].ob_state|=SELECTED;
  if(__magx<0x0300) tree[COUNTER].ob_spec.tedinfo->te_thickness=0;
  tree[COUNTER].ob_y--;
  tree[COUNTER].ob_height+=2;
 }
}

void hide_buttons(int anz)
{
 int i, z, y, data;

 if(anz>(LASTTR-FIRSTTR+1)) anz=(LASTTR-FIRSTTR+1);
 if(anz<1) anz=1;
 z=anz/TRACKSPL;
 if(anz%TRACKSPL) z++;
 if(z<TRLINES)
 {
  for(i=tracks+FIRSTTR;i<=LASTTR;i++)
  {
   tree[i].ob_flags&=~(SELECTABLE|EXIT);
   tree[i].ob_flags|=HIDETREE;
  }
  y=(tree[FIRSTTR+TRACKSPL].ob_y-tree[FIRSTTR].ob_y)*(TRLINES-z);
  for(i=LASTTR+1;i<NUM_OBS;i++)
  {
   tree[i].ob_y-=y;
   if(tree[i].ob_head!=-1) i=tree[i].ob_next-1;
  }
  tree[ROOT].ob_height-=y;
 }
 data=0;
 for(i=0;i<anz;i++)
 {
  if(trackflags[i]&4)
  {
   tree[i+FIRSTTR].ob_flags&=~(SELECTABLE|EXIT|TOUCHEXIT);
   tree[i+FIRSTTR].ob_state|=DISABLED;
   data++;
  }
 }
 if(data==anz)
 {
  for(i=LASTTR+1;i<NUM_OBS;i++)
  {
   tree[i].ob_flags&=~(SELECTABLE|TOUCHEXIT|EXIT|EDITABLE|DEFAULT);
   tree[i].ob_state&=~SELECTED;
   if((tree[i].ob_type&0x00ff)!=G_IBOX) tree[i].ob_state|=DISABLED;
  }
  tree[CDCANCEL].ob_flags=SELECTABLE|DEFAULT|EXIT;
  if(three_d) tree[CDCANCEL].ob_flags|=FL3DACT;
  tree[CDCANCEL].ob_state=NORMAL|WHITEBAK;
  tree[DHCOPY].ob_state=NORMAL;
  disable_ret();
 }
 tree[TYPEACD].ob_flags|=HIDETREE;
 tree[TYPEDCD].ob_flags|=HIDETREE;
 tree[TYPEMCD].ob_flags|=HIDETREE;
 if(data==0 && anz>0) tree[TYPEACD].ob_flags&=~HIDETREE;
 else if(data==anz) tree[TYPEDCD].ob_flags&=~HIDETREE;
 else tree[TYPEMCD].ob_flags&=~HIDETREE;
}

void calc_size(struct cdrom_msf *time)
{
 int len;
 long start, end, size;

 start=time->cdmsf_min0;
 start*=60;
 start+=time->cdmsf_sec0;
 start*=75;
 start+=time->cdmsf_frame0;
 end=time->cdmsf_min1;
 end*=60;
 end+=time->cdmsf_sec1;
 end*=75;
 end+=time->cdmsf_frame1;
 size=end-start;
 if(size<0) size=0;
 else size*=2352;
 if(bits==8) size/=2;
 if(half) size/=2;
 if(!stereo) size/=2;
 size/=1024;
 ltoa(size,tree[RECSIZE].ob_spec.tedinfo->te_ptext,10);
 len=(int)strlen(tree[RECSIZE].ob_spec.tedinfo->te_ptext);
 if(len<6) insertc(tree[RECSIZE].ob_spec.tedinfo->te_ptext,0,6-len,' ');
 /*strcat(tree[RECSIZE].ob_spec.tedinfo->te_ptext," KByte");*/
}
