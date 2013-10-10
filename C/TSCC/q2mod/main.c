/*
 * Quartett to mod converter
 *   03.02.2000 by Settel
 */


// Includes /*fold00*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>
#include <math.h>
#include "pattern.h"
#include "voice.h"
#include "common.h"
#include "mod.h"

// Defines /*fold00*/
#define BASEFREQ 0x879c
#define SAMPLESTRETCH 0.95
#define SPEED 0x80

#define PITCH_TOO_LOW    0x10000
#define PITCH_TOO_HIGH   0x20000
#define VOICE_MAP_LOWER  0x100
#define VOICE_MAP_HIGHER 0x200

// Globals /*fold00*/
char *pattern_buf=NULL;
char *voices_buf=NULL;
int pattern_buf_len=0;
int voices_buf_len=0;
struct channel chan[4];

int min_step_width=1<<16;
int num_steps=0;

int mod_patterns_num=0;
char *mod_patterns_buf=NULL;

struct sample samples[20];
int voice_map[31|VOICE_MAP_HIGHER|VOICE_MAP_LOWER];
int voice_rev_map[31];

int mod_pitch_tab[36];

// init_mod_pitch_tab /*fold00*/
void init_mod_pitch_tab(){
#if 1
   int i;
   for(i=0;i<36;i++) mod_pitch_tab[i]=freqtab[i];
#else
   int i;
   double c=exp(log(2)/12.0);

   char buf[4096];
   int fd;

   fd=open("freq.mod",O_RDONLY);
   if(fd<0){
      perror("open()");
      exit(1);
   }
   read(fd,buf,sizeof(buf));
   close(fd);

   for(i=0;i<36;i++) mod_pitch_tab[i]=(int)((856.0/pow(c,i))+0.5);

   for(i=0;i<36;i++){
      fd=X32(*((unsigned long *)(buf+i*16+1084)));
      fd>>=16;
      fd&=0x7FFF;
      printf("%2i: %3i <-> %3i  (%3i)\n",i,mod_pitch_tab[i],fd,mod_pitch_tab[i]-fd);

   }
#endif
}

// read_4v /*fold00*/
void read_4v(char *name){
   int fd;
   struct stat stat_buf;
   int len;

   if(stat(name,&stat_buf)){
      perror("stat()");
      exit(1);
   }
   pattern_buf_len=stat_buf.st_size;
   pattern_buf=(char *)malloc(pattern_buf_len);
   if(!pattern_buf){
      pattern_buf_len=0;
      perror("malloc()");
      exit(1);
   }

   fd=open(name,O_RDONLY);
   if(fd<0){
      perror("open()");
      exit(1);
   }

   len=read(fd,pattern_buf,pattern_buf_len);
   if(len<0){
      perror("read()");
      exit(1);
   }else if(len!=pattern_buf_len){
      fprintf(stderr,"read incomplete\n");
      exit(1);
   }

   close(fd);
}

// read_set /*fold00*/
void read_set(char *name){
   int fd;
   struct stat stat_buf;
   int len;

   if(stat(name,&stat_buf)){
      perror("stat()");
      exit(1);
   }
   voices_buf_len=stat_buf.st_size;
   voices_buf=(char *)malloc(voices_buf_len+32768);
   if(!voices_buf){
      voices_buf_len=0;
      perror("malloc()");
      exit(1);
   }

   fd=open(name,O_RDONLY);
   if(fd<0){
      perror("open()");
      exit(1);
   }

   len=read(fd,voices_buf,voices_buf_len);
   if(len<0){
      perror("read()");
      exit(1);
   }else if(len!=voices_buf_len){
      fprintf(stderr,"read incomplete\n");
      exit(1);
   }

   close(fd);
}

// dump_channel /*fold00*/
void dump_channel(int i){
   struct note *note;

   for(note=chan[i].start;note<chan[i].end;note++){
      printf(" %3i:  %c %5i %08lx %08lx\n",note-chan[i].start,
             note->cmd,note->delay,
             note->val1,note->val2);
   }
}

// preprocess_4v /*fold00*/
void preprocess_4v(){
   int i;
   struct note *note;

   note=(struct note*)(pattern_buf+16);
   for(i=0;i<4;i++){
      printf("process channel %i: ",i);
      chan[i].start=note;
      while(1){
         note->cmd=X16(note->cmd);
         note->delay=X16(note->delay);
         note->val1=X32(note->val1);
         note->val2=X32(note->val2);

         switch(note->cmd){
         case NOTE_LOOPSTART:
         case NOTE_LOOPEND:
         case NOTE_VOICE:
            note->delay=0;
            break;
         }

         if(note->cmd==NOTE_END) break;
         note++;
      }
      chan[i].end=note;
      note++;
      printf("length %i\n",chan[i].end-chan[i].start);

   }
}

// preprocess_set /*fold00*/
void preprocess_set(){
   int i,j;
   struct setheader *setheader=(struct setheader *)voices_buf;
   unsigned long *offset;

   memset(voice_map,-1,sizeof(voice_map));
   memset(voice_rev_map,-1,sizeof(voice_rev_map));
   memset(samples,0,sizeof(samples));
   for(i=0;i<20;i++){
      strncpy(samples[i].name,setheader->name[i],6);
      offset=(unsigned long *)setheader->offset;
      offset+=i;
      samples[i].descr=(struct sam_descr *)(voices_buf+X32(*offset));
      if(X32(*offset)==0 || ((char *)samples[i].descr)+8>voices_buf+voices_buf_len){
         samples[i].descr=NULL;
         samples[i].start=NULL;
         samples[i].len=0;
         samples[i].repstart=0;
         samples[i].replen=0;
         voice_map[i]=-1;
      }else{
         voice_map[i]=i;
         voice_rev_map[i]=i;
         samples[i].start=voices_buf+X32(*offset)+8;
         samples[i].len=X16(samples[i].descr->len)&0x7FFF;
         samples[i].repstart=(X16(samples[i].descr->len)&0x7FFF)-
            (X16(samples[i].descr->replen)&0x7FFF);
         samples[i].replen=X16(samples[i].descr->replen)&0x7FFF;

         for(j=0;j<i;j++){
            if(samples[j].descr==samples[i].descr){
               samples[i].descr=NULL;
               samples[i].start=NULL;
               samples[i].len=0;
               samples[i].repstart=0;
               samples[i].replen=0;

               voice_map[i]=j;
               voice_rev_map[i]=-1;
               break;
            }
         }
      }
      printf("sam %2i: mapped to %2i,",i,voice_map[i]);
      if(voice_map[i]>=0){
         printf(" \"%6s\", %6i\n",samples[voice_map[i]].name,samples[voice_map[i]].len);
      }else{
         printf("\n");
      }
   }
}

// count_steps /*fold00*/
void count_steps(){
   int count_steps_sub(struct note *start,struct note *end){
      struct note *note;
      struct note *loopstart;
      struct note *loopend;
      int count=0;
      int count2;
      int depth=0;

      for(note=start,loopstart=start;note<=end;note++){
         switch(note->cmd){
         case NOTE_LOOPSTART:
            if(depth++==0) loopstart=note+1;
            break;
         case NOTE_LOOPEND:
            if(--depth==0){
               loopend=note-1;
               count2=count_steps_sub(loopstart,loopend);
               loopstart=start;
               count2+=note->delay;
               count-=note->delay;
               count+=count2*(NOTE_LOOP_CNT(note));
            }
            break;
         }

         count+=note->delay;
         if(note->delay>0){
            min_step_width=min_step_width>note->delay?note->delay:min_step_width;
         }
      }
      return count;
   }

   int i;
   int count;

   for(i=0;i<4;i++){
      count=0;
      count=count_steps_sub(chan[i].start,chan[i].end-1);
      printf("pattern %i has %i steps\n",i,count);
      if(count>num_steps) num_steps=count;
   }
   printf("min. step width is %i\n",min_step_width);
}


// write_mod /*fold00*/
void write_mod(char *name){
   struct mod_header mod_header;
   double stretch=SAMPLESTRETCH;
   int newlen[32];
   int fd;
   int len,pos;
   int i,j;
   int samnr;

   memset(newlen,0,sizeof(newlen));
   printf("creating MOD header\n");
   memset(&mod_header,0,sizeof(mod_header));
   mod_header.magic[0]='M';
   mod_header.magic[1]='.';
   mod_header.magic[2]='K';
   mod_header.magic[3]='.';

   mod_header.num_pos=mod_patterns_num;
   mod_header.repstartpos=0;
   for(i=0;i<mod_patterns_num;i++)
       mod_header.poslist[i]=i;

   for(j=0;j<19;j++) mod_header.name[j]=(j<(signed int)strlen(name))?name[j]:' ';
   mod_header.name[19]=0;

   printf("creating sample table\n");
   for(i=0;i<31;i++){
      samnr=voice_rev_map[i];
      if(samnr>=0){
         struct mod_saminfo *sam=&mod_header.saminfo[i];

         for(j=0;j<20;j++) sam->name[j]=(j<(signed int)strlen(samples[samnr].name))?samples[samnr].name[j]:' ';

         if(samnr&(VOICE_MAP_HIGHER|VOICE_MAP_LOWER)){
            sam->name[17]='(';
            sam->name[18]='T';
            sam->name[19]=')';
         }

         sam->finetune=Y16(0);
         newlen[i]=(unsigned short)(samples[samnr].len*stretch);
         sam->len=Y16(newlen[i]>>1);
         sam->vol=Y16(VOL_MAX);
         if(samples[samnr].replen==0xffff || samples[samnr].repstart==samples[samnr].len){
            sam->repstart=Y16(0);
            sam->replen=Y16(1);
         }else{
            sam->repstart=Y16((unsigned short)(samples[samnr].repstart*stretch)>>1);
            sam->replen=Y16((unsigned short)(samples[samnr].replen*stretch)>>1);
         }
      }
   }

   printf("writing mod: \n");
   fd=open(name,O_WRONLY|O_CREAT,0666);
   if(fd<0){
      perror("open()");
      exit(1);
   }
   printf("header\n");
   len=write(fd,&mod_header,sizeof(mod_header));
   if(len!=sizeof(mod_header)){
      fprintf(stderr,"write incomplete\n");
      exit(1);
   }

   printf("patterns\n");

   // insert speed command
   {
	   unsigned long l;
	   l=X32(*(unsigned long *)mod_patterns_buf);
	   l&=0xFFFFF000;
	   l|=0x00000F06;
	   *(unsigned long *)mod_patterns_buf=Y32(l);

	   l=X32(*(unsigned long *)(mod_patterns_buf+4));
	   l&=0xFFFFF000;
	   l|=0x00000F00+SPEED;
	   *(unsigned long *)(mod_patterns_buf+4)=Y32(l);
   }

   for(pos=0;pos<mod_patterns_num*1024;){
      len=write(fd,mod_patterns_buf+pos,mod_patterns_num*1024-pos);
      if(len<0) break;
      pos+=len;
   }
   if(pos!=mod_patterns_num*1024){
      fprintf(stderr,"write incomplete\n");
      exit(1);
   }

   for(i=0;i<32;i++){
      unsigned char newsample[65536];

      samnr=voice_rev_map[i];
      if(samnr<0) continue;
      printf("sample %2i; start: %#08lx, len: %8i\n",i,(unsigned long)samples[samnr].start,samples[samnr].len);
      // if(samnr&(VOICE_MAP_HIGHER|VOICE_MAP_LOWER)){
      // }else{

#if 0
      // save sample without processing
	  char *x;
      for(j=0,x=samples[samnr].start;j<samples[samnr].len;j++,x++){
          // if(samnr==14) printf("%8i\n",j);
         *x=((unsigned char)*x)-0x80;
      }
      // }
      len=write(fd,samples[samnr].start,samples[samnr].len);
      if(len!=samples[samnr].len){
         fprintf(stderr,"write incomplete\n");
         exit(1);
      }
#else
      // resample
      for(j=0;j<newlen[i];j++){
          newsample[j]=((unsigned char)(samples[samnr].start[(int)(j/stretch)]))-0x80;
      }
      len=write(fd,newsample,newlen[i]);
      if(len!=newlen[i]){
         fprintf(stderr,"write incomplete (%i != %i)\n",len,newlen[i]);
         exit(1);
      }
#endif
   }

   close(fd);
}

// pitch2mod_pitch /*fold00*/
int pitch2mod_pitch(long pitch){
   int note_nr;

   note_nr=(int)(
                 (
                  12.0/log(2.0)*
                  (
                   log((double)pitch)-log((double)BASEFREQ)
                  )
                 )
                 +0.5
                );

   if(note_nr<0){
      note_nr+=12;
      if(note_nr<0){
         fprintf(stderr,"note too low!\n");
         return 0;
      }
      return mod_pitch_tab[note_nr] | PITCH_TOO_LOW;
   }
   if(note_nr>35){
      note_nr-=12;
      if(note_nr>35){
         fprintf(stderr,"note too high!\n");
         return 0;
      }
      return mod_pitch_tab[note_nr] | PITCH_TOO_HIGH;
   }

   return mod_pitch_tab[note_nr];

}
// mod_insert_note /*fold00*/
void mod_insert_note(int nr,int pos,short voice,long pitch,int vol,short cmd){
   char *mod_note;
   int i;
   unsigned short mod_pitch;

   mod_pitch=pitch>0?pitch2mod_pitch(pitch):0;

   mod_note=mod_patterns_buf+nr*4+pos*16;
   mod_note[0]=0;
   mod_note[1]=0;
   mod_note[2]=(cmd>>8)&0xf;
   mod_note[3]=cmd&0xff;

   if(voice>=0){
      voice=voice>>2;
      if(mod_pitch&PITCH_TOO_HIGH){ // need to transpose?
         i=voice_map[voice|VOICE_MAP_HIGHER]+1;
         printf("note too high, transposing\n");
         if(!i){ // no transposed voice available?
            int j,found;
            for(j=0,found=0;j<31&&!found;j++){

               if(voice_rev_map[j]==-1){
                  found=1;
                  voice_rev_map[j]=voice|VOICE_MAP_HIGHER;
                  voice_map[voice|VOICE_MAP_HIGHER]=j;
               }
            }
            if(!found) i=0;  // sorry, out of samples
         }
      // }else if(mod_pitch&PITCH_TOO_LOW){
      //    i=voice_map[voice|VOICE_MAP_LOWER]+1;
      }else{
         i=voice_map[voice]+1;
      }
      if(i>0){
         mod_note[2]|=(i&0xf)<<4;
         if(i&0x10) mod_note[0]|=0x8000;
      }
   }
   if(vol>=0){
      mod_note[2]&=0xf0;
      mod_note[2]|=0xc;
      mod_note[3]=vol;
   }
   if(mod_pitch){
      mod_note[1]=mod_pitch&0xFF;
      mod_note[0]=(mod_pitch>>8)&0xFF;
   }
}

// process_channel /*FOLD00*/
void process_channel(int nr){
   void process_channel_sub(int nr,struct note *start,struct note *end){
      struct note *note;
      //struct note *loopstart=start,*loopend=start;
      struct note *loopstart[10];
      int depth=0;
      int i;
      short cmd,cmd2;
      int slide;

      loopstart[0]=start;

      for(note=start;note<=end;note++){
         cmd2=cmd=0;

         switch(note->cmd){
         case NOTE_VOICE:
            chan[nr].voice=NOTE_VOICE_VOICE(note);
            break;
         case NOTE_SLIDE:
            if(!NOTE_SLIDE_ADD(note)&&chan[nr].pitch==NOTE_SLIDE_PITCH(note))
               break;

            chan[nr].pitch=NOTE_SLIDE_PITCH(note);
            slide=NOTE_SLIDE_ADD(note);
            if(slide>0){
               cmd=0x300;
            }else{
               slide=-slide;
               cmd=0x300;
            }
            cmd+=(slide>>7)&0xff;
            cmd2=cmd;
            if((slide>>6)&1) cmd+=1;

            mod_insert_note(nr,chan[nr].pos,-1,chan[nr].pitch,VOL_NOP,cmd);
            break;
         case NOTE_PLAY:
            chan[nr].pitch=NOTE_PLAY_PITCH(note);
            mod_insert_note(nr,chan[nr].pos,chan[nr].voice,chan[nr].pitch,VOL_MAX,0);
            break;
         case NOTE_STOP:
            mod_insert_note(nr,chan[nr].pos,-1,-1,VOL_SILENCE,0);
            break;
         case NOTE_LOOPSTART:
            loopstart[depth++]=note+1;
            //if(depth++==0)
            //  loopstart=note+1;

            break;
         case NOTE_LOOPEND:
            {
               int repcnt;
               int loopend=note-1;
               depth--;
               for(repcnt=0;(unsigned int)repcnt<NOTE_LOOP_CNT(note);repcnt++)
                  process_channel_sub(nr,loopstart[depth],loopend);
            }
            break;
         }

         i=chan[nr].pos+1;
         chan[nr].pos+=note->delay/min_step_width;
         for(;i<chan[nr].pos;i++){
            mod_insert_note(nr,i,-1,-1,VOL_NOP,i&1?cmd:cmd2);
         }
      }
   }

   printf("processing channel %i\n",nr);
   chan[nr].pos=0;
   chan[nr].pitch=0;
   chan[nr].voice=0;
   process_channel_sub(nr,chan[nr].start,chan[nr].end-1);
}

// main /*fold00*/
int main(int argc,char **argv){
   char in_4v[512];
   char in_set[512];
   char out_mod[512];

   switch(argc){
   case 2:
      strncpy(in_4v,argv[1],sizeof(in_4v));
      strncpy(in_set,argv[1],sizeof(in_set));
      strncat(in_4v,".4v",sizeof(in_4v)-strlen(in_4v));
      strncat(in_set,".set",sizeof(in_set)-strlen(in_set));
      strncpy(out_mod,argv[1],sizeof(out_mod));
      strncat(out_mod,".mod",sizeof(out_mod)-strlen(out_mod));
      break;
   case 3:
      strncpy(in_4v,argv[1],sizeof(in_4v));
      strncpy(in_set,argv[1],sizeof(in_set));
      strncat(in_4v,".4v",sizeof(in_4v)-strlen(in_4v));
      strncat(in_set,".set",sizeof(in_set)-strlen(in_set));
      strncpy(out_mod,argv[2],sizeof(out_mod));
      break;
   case 4:
      strncpy(in_4v,argv[1],sizeof(in_4v));
      strncpy(in_set,argv[2],sizeof(in_set));
      strncpy(out_mod,argv[3],sizeof(out_mod));
      break;
   default:
      printf("usage: %s <in.4v> <in.set> <out.mod>   or\n",argv[0]);
      printf("       %s <in>             <out.mod>   or\n",argv[0]);
      printf("       %s <name>\n",argv[0]);
      exit(1);
   }

   init_mod_pitch_tab();

   read_4v(in_4v);
   read_set(in_set);

   preprocess_4v();
   preprocess_set();

   count_steps();
   mod_patterns_num=(num_steps+min_step_width-1)/min_step_width;
   mod_patterns_num+=63;
   mod_patterns_num/=64;
   printf("we need %i patterns\n",mod_patterns_num);
   mod_patterns_buf=(char *)malloc(mod_patterns_num*1024);
   if(!mod_patterns_buf){
      perror("malloc()");
      exit(1);
   }
   memset(mod_patterns_buf,0,mod_patterns_num*1024);

   process_channel(0);
   process_channel(1);
   process_channel(2);
   process_channel(3);

   write_mod(out_mod);

   return 0;
}
