/*........................ include header files ..............................*/

#include <vdibind.h>    /* VDI stuff */
#include <gemdefs.h>    /* AES stuff */
#include <obdefs.h>     /* more AES stuff */
#include <osbind.h>     /* GEMDOS, BIOS, XBIOS stuff */
#include <taddr.h>      /* OB macros */
#include <portab.h>     
#include <machine.h>    /* LW macros */
#include <cz_andrd.h>   /* created by RCS */

#include <defines.h>
#include <externs.h>

extern int sequence,pro_pass,timebomb;   /* stuff for copy-protection */
extern int Alock;

/*............................. hide an object ...............................*/

hide_obj(tree,obj)
long tree;
int obj;
{
   int state;
   state= LWGET(OB_FLAGS(obj));
   LWSET(OB_FLAGS(obj),state | HIDETREE);
}

/*.............................un-hide an object .............................*/

unhide_obj(tree,obj)
long tree;
int obj;
{
   int state;
   state= LWGET(OB_FLAGS(obj));
   LWSET(OB_FLAGS(obj),state & ~HIDETREE);
}

/*...........................send one voice to synth .........................*/

putsyn(slot,area,nameptr)   /* return 0 for ok, 1 for error */
int slot;   /* = 1-16 */
char area[];  /* 135 bytes */
char nameptr[];   /* 17 bytes */
{

   if ((syntype==3)&&(slot>4)) return(0);

/* channelize communication */   
   tocz1[4]= (tocz1[4] & 0xF0) | midi_ch;
   tocz2[4]= (tocz2[4] & 0xF0) | midi_ch;
/* program # */
   tocz1[6]= bankset+slot-1;
/* argument for writsyn */
   normtocz(area,nameptr);
   midiptr= &czbuf[0];
   writsyn();
   if (!midierr) return(0); /* good return */

/* an error has occurred */
   form_alert(1,BADSYN);
   return(1);
} /* end putsyn(slot,area,nameptr) */

/*...........................get one voice from synth ........................*/
   
getsyn(slot,area,nameptr)  /* return 0 for ok, 1 for error */
int slot;   /* = 1-16 */
char area[];   /* 135 bytes */
char nameptr[];   /* 17 bytes */
{ 

/* for CZ-230S slots = 1-2-3-4-1-2-3-4-1-2-3-4-1-2-3-4 */
   if (syntype==3) slot= (slot-1)%4 + 1;
      
/* channelize communication */
   fromcz1[4]= (fromcz1[4] & 0xF0) | midi_ch;
   fromcz2[4]= (fromcz2[4] & 0xF0) | midi_ch;
   fromcz3[0]= (fromcz3[0] & 0xF0) | midi_ch;
/* program # */
   fromcz1[6]= bankset+slot-1;
/* argument for readsyn */
   midiptr= &czbuf[0];
   readsyn();
   if (midierr)   /* an error has occurred */
   {
      form_alert(1,BADSYN);
      return(1);
   }
   cztonorm(area,nameptr);
   return(0);   
} /* end getsyn(slot,area,nameptr) */

/*...........................send all voices to synth ........................*/

putall(area,nameptr)   /* return 0 for ok, 1 for error */
char *area,*nameptr;
{
   register int i;

   for (i=1; i<=16; i++)
      if (   putsyn(i,&area[135*(i-1)],&nameptr[17*(i-1)])   ) return(1);

   return(0);
} /* end putall(area,nameptr) */

/*...........................get all voices from synth .......................*/

getall(area,nameptr)   /* return 0 for ok, 1 for error */
char *area,*nameptr;
{
   register int i;

   for (i=1; i<=16; i++)
      if (   getsyn(i,&area[135*(i-1)],&nameptr[17*(i-1)])   ) return(1);

   return(0);  
} /* end getall(area,nameptr) */

/*...............................copy/swap bytes .............................*/

copybyte(fromarea,toarea,nbytes)
char fromarea[],toarea[];
register int nbytes;
{
   register int i;

   for (i=0; i<nbytes; i++)
      toarea[i]= fromarea[i];
} /* end copybyte(fromarea,toarea,nbytes) */

swapbyte(fromarea,toarea,nbytes)
char fromarea[],toarea[];
register int nbytes;
{
   register int i;
   char c;

   for (i=0; i<nbytes; i++)
      {  c=fromarea[i]; fromarea[i]=toarea[i]; toarea[i]=c;   }

} /* end swapbyte(fromarea,toarea,nbytes) */

/*...............................distort an area..............................*/

do_dist(area)
char area[];   /* 135 bytes */
{
   register int i,k;

/* 1/4 of the time: line 1 become 1+1' and vice versa */
   if (!random(3)&&!area[126])
   {
      if (area[0]==0)
         area[0]=2;
      else
         if (area[0]==2) area[0]=0;
   }
   if (!random(7))    /* 1/8 of the time: oct goes up or down 1 */
   {                 
      if (area[1]==0)
      {
         if (random(1))
            area[1]=1;
         else
            area[1]=2;
      }
      else
         area[1]=0;
   }
   /* detune fine */
   if (random(1))
   {
      if (area[3]<=7)
         area[3]= random(7);
      else
         area[3]= randx(area[3],7,8,60);
   }
   if (random(1)) area[6]= random(3);                 /* vibrato waveform */
   for (i=0; i<=1; i++)           /* vibrato delay, rate */
      if (random(1)) area[i+7]= randx(area[i+7],3,0,99);
   if ((area[9]<=3)&&random(1)) area[9]=random(3);  /* vibrato depth */
   for (k=0; k<=58; k=k+58)       /* for line 1, then for line 2 */
   {  /* DCO wave 2 null is same as DCO wave 2 = DCO wave 1 */
      if (area[k+11]==8) area[k+11]= area[k+10]; 
      if ((area[k+11]>4)&&(area[k+10]>4)) area[k+11]=0; /* illegal */
      for (i=0; i<=1; i++)        /* for DCO wave 1, then 2 */
         if (area[k+10+i]<=4)    
            area[k+10+i]= randx(area[k+10+i],1,0,4);
         else
            area[k+10+i]= randx(area[k+10+i],1,5,7);
      for (i=0; i<=1; i++)        /* for DCA key follow, then DCW key follow */
         if (random(1)) area[k+12+i]= randx(area[k+12+i],3,0,9);
      for (i=0; i<=2*area[k+14]; i++)  /* distort DCA envelope to endpoint */
         if (random(1)) area[k+15+i]= randx(area[k+15+i],15,0,99);
      if (!random(7))                          /* move end point */
      {
         i=area[k+14];   /* save old end point */
         area[k+14]= randx(area[k+14],1,0,7);
         if ((area[k+14]<=area[k+31])&&(area[k+31]!=8))
            area[k+14]=i;
         else
            area[k+16+2*area[k+14]]= 0;            
      }
      for (i=0; i<=2*area[k+32]; i++)  /* distort DCW envelope to endpoint */
         if (random(1)) area[k+33+i]= randx(area[k+33+i],15,0,99);
      if (!random(3))                /* move sustain point */
      {
         i= random(7);
         if (i<area[k+32])
         {
            area[k+49]=i;
            area[k+34+2*area[k+49]]= randx(63,36,0,99);
         }
      }
      if (!random(7)) area[k+49]=8;         /* or get rid of sustain point */
      if (!random(3))                          /* move end point */
      {
         area[k+32]= randx(area[k+32],1,0,7);
         area[k+34+2*area[k+32]]= 0;
         if (area[k+49]==area[k+32]) area[k+49]=8;
      }

   } /* end for (k=0; k<=58; k=k+58) */
   /* don't change modulation or cz-1 parameters */

} /* end do_dist(area) */

/*............................... droid an area ..............................*/

do_droid(area)
char area[];   /* 135 bytes */
{
   register int i,k;

   area[0]= random(3);        /* line select: 0-3 */
   if (random(2))                /* octave */
      area[1]= 0;                /* 66% of the time: 0 */
   else
      area[1]= 1+ random(1);     /* 33% of the time: 1-2 */
   area[2]= random(1);        /* detune +/- : 0-1 */
   if (random(3))                /* octave detune */
   {
      area[4]= 0;                /* 75% of the time: 0 */
      area[3]= random(7);        /* fine detune: 0-7 */            
   }
   else
   {                                /* 25% of the time */
      area[3]= 0;                /* fine detune: 0 */
      if (area[2])
      {
         if (area[1]==2) area[4]= 0;
         if (area[1]==0) area[4]= 1;
         if (area[1]==1) area[4]= 1+random(1);
      }
      else
      {
         if (area[1]==2) area[4]= 1+random(2);
         if (area[1]==0) area[4]= 1+random(1);
         if (area[1]==1) area[4]= 1;
      }
   }
   area[5]= 0;                /* note detune: 0 */
   if (random(3))                /* vibrato wave */
      area[6]= 0;                /* 75% of the time: 0 */
   else
      area[6]= 1+ random(2);     /* 25% of the time: 1-3 */
   if (random(3))                /* vibrato delay */
      area[7]= 0;                /* 75% of the time: 0 */
   else
      area[7]= random(50);       /* 25% of the time: 0-50 */
   if (random(3))                /* vibrato rate */
      area[8]= 57;               /* 75% of the time: 57 */
   else
      area[8]= 57+ random(42);   /* 25% of the time: 57-99 */
   if (random(7))                /* vibrato depth */
      area[9]= 0;                /* 7/8 of the time: 0 */
   else
      area[9]= 10+ random(20);   /* 1/8 of the time: 10-30 */
   
   for (k=0; k<=58; k=k+58)         /* for line 1, then for line 2 */
   {
      area[k+10]= random(4);     /* DCO wave 1: 0-4 */                       
      area[k+11]= random(4);     /* DCO wave 2: 0-4 */                       
      if (!random(7)) area[k+11]= 8;    /* 1/8 of the time, wave 2 = null */
      area[k+12]= random(9);        /* DCA key follow: 0-9 */
      area[k+13]= random(9);        /* DCW key follow: 0-9 */
      dcawenv(&area[k+14]);         /* random DCA envelope */
      scalenv(&area[k+14]);         /* scale DCA envelope up to 99 */
      if (area[k+15]<65) area[k+15]= 65;  /* prevent slow envelopes */
      dcawenv(&area[k+32]);         /* random DCW envelope */
      dcoenv(&area[k+50]);          /* random DCO envelope */         
   } /* end for (k=0; k<=58; k=k+58) */
   area[126]= 0;                    /* modulation: off */
   area[127]=area[128]=area[129]=0; /* no velocities */
   area[131]=area[132]=area[133]=0; 
   area[130]=area[134]=15;          /* line levels */
   
} /* end do_droid(area) */

dcawenv(area)
char area[];  /* 18 bytes */
{
   int i,up,spike,nullstps;
   static char rutabl[15] = {40,50,60,70,80,90,99,99,99,99,99,99,99,99,99};
   static char rdtabl[7]  = {99,60,50,45,40,35,30};
   static char lutabl[11] = {50,55,60,65,70,75,80,85,90,95,99};
   static char ldtabl[6]  = { 0,10,20,30,40,50};

   if (!random(3))
   {                               /* no sustain point */
      area[17]= 8;
      if (random(3))
         area[0]= 1;
      else
         area[0]=  2*random(3) + 1;
   }
   else   
   {                         /* there is a sustain point */
      if (random(3))
         area[17]= random(1);
      else
         area[17]= random(3);
      area[0]= area[17]+1;
   }
   up=1;
   for (i=0; i<=area[0]; i++)
   {
      if (up)
      {
         area[2*i+1]= rutabl[random(14)];
         area[2*i+2]= lutabl[random(10)];
         up= 0;
      }
      else
      {
         area[2*i+1]= rdtabl[random(6)];
         area[2*i+2]= ldtabl[random(5)];
         up= 1;
      }
   } /* end for (i=0; i<=area[0]; i++) */
   area[2*area[0]+1]= rdtabl[random(6)];
   area[2*area[0]+2]= 0;
   
/* spike prevention */
   spike= 0;   
   if ((area[17]==8)||((area[17]!=8)&&(area[2+2*area[17]]<40)))
   {
      nullstps= 0;
      for (i=0; i<=(area[0]-1); i++)
         if ((area[2*i+2]<40)||((area[2*i+1]>60)&&(area[2*i+3]>60))) nullstps++;
      if (nullstps==area[0]) spike= 1;
   }
   if (spike) 
   {
      area[17]= 0;
      if (area[2]<40) area[2]= 40+random(59);
   }
   for (i=0; i<=(area[0]-1); i++)
      if ((i!=area[17])&&(area[2*i+1]>60)&&(area[2*i+3]>60)) area[2*i+3]=60;
   
} /* end dcawenv(area) */

dcoenv(area)
char area[];  /* 18 bytes */
{
   int i;

   area[0]= 7;             /* end point */
   for (i=0; i<=14; i=i+2)
   {
      area[1+i]= 50;     /* rates */
      area[2+i]= 0;      /* levels */
   }
   area[17]= 0;          /* sustain point */

} /* end dcoenv(area) */

scalenv(area)
char area[18];   /* 18 bytes */
{
   int i,j;

   if (!area[0]) return;   /* shouldn't ever happen */
   j=0;
   for (i=2; i<=2*area[0]; i=i+2)
      if (area[i]>j) j=area[i];
   j= 99-j;
   for (i=2; i<=2*area[0]; i=i+2)
      if (area[i]) area[i]= area[i]+j;
} /* end scalenv(area) */
   
/*...................... normalize from czbuf to area ........................*/

cztonorm(area,nameptr)
char area[];     /* 135 bytes */
char nameptr[];  /* 17 bytes */
{
   register int i,k,kk;
   char c;

   area[0]= czbuf[0] & 0x03;        /* line select = 0-3 */
   area[1]= (czbuf[0] & 0x0c)>>2;   /* octave = 0-2 */
   area[2]= czbuf[1] & 0x01;        /* detune +/- = 0-1 */
   area[3]= (czbuf[2]&0xff)>>2;     /* fine detune = 0-60 */
   if (area[3]>15) --area[3];
   if (area[3]>30) --area[3];
   if (area[3]>45) --area[3];
   area[4]= czbuf[3]/12;            /* octave detune = 0-3 */
   area[5]= czbuf[3]%12;            /* note detune = 0-11 */
   for (i=0; i<=3; i++)
      if (czbuf[4]==pvktabl[i]) area[6]= i;  /* vibrato waveform = 0-3 */
   for (i=0; i<=198; i=i+2)           /* vibrato delay = 0-99 */
      if ((czbuf[6]==pvdltabl[i])&&(czbuf[7]==pvdltabl[i+1])) area[7]= i/2;
   for (i=0; i<=198; i=i+2)           /* vibrato rate = 0-99 */
      if ((czbuf[9]==pvsdtabl[i])&&(czbuf[10]==pvsdtabl[i+1])) area[8]= i/2;
   for (i=0; i<=198; i=i+2)           /* vibrato depth = 0-99 */
      if ((czbuf[12]==pvdltabl[i+2])&&(czbuf[13]==pvdltabl[i+3])) area[9]= i/2;

   for (k=0; k<=57; k=k+57)               /* for line= 1, then 2 */
   {
      kk= 58*k/57;
      c= (czbuf[14+k]&0xff)>>5;              /* c = 3-bit 1st waveform */
      if (c==0) area[10+kk]= 0;          /* DCO first waveform = 0-7 */
      if (c==1) area[10+kk]= 1;
      if (c==2) area[10+kk]= 2;
      if (c==4) area[10+kk]= 3;
      if (c==5) area[10+kk]= 4;
      if (c==6) area[10+kk]= 4+ ((czbuf[15+k]&0xff)>>6);
      c= ((czbuf[14+k]&0xff)>>2) & 0x07;     /* c = 3-bit 2nd waveform */
      if (c==0) area[11+kk]= 0;          /* DCO second waveform = 0-8 */
      if (c==1) area[11+kk]= 1;
      if (c==2) area[11+kk]= 2;
      if (c==4) area[11+kk]= 3;
      if (c==5) area[11+kk]= 4;
      if (c==6) area[11+kk]= 4+ ((czbuf[15+k]&0xff)>>6);
      c= ((czbuf[14+k]&0xff)>>1) & 0x01;    /* c = 1-bit 2nd waveform on/off */
      if (c==0) area[11+kk]= 8;
      area[12+kk]= czbuf[16+k]&0x0f;  /* DCA key follow */
      area[13+kk]= czbuf[18+k];       /* DCW key follow */
      area[14+kk]= czbuf[20+k]&0x0f;  /* DCA envelope end step = 0-7 */
      for (i=15; i<=29; i=i+2)  /* DCA envelope rates, each = 0-99 */
      {
         c= czbuf[i+6+k] & 0x7F;   /* get rid of up/down bit */
         if (c==0)
            area[i+kk]= 0;
         else
         {
            if (c==0x77)
               area[i+kk]= 99;
            else
               area[i+kk]= ((99*c)/119) + 1;
         }
      }   
      for (i=16; i<=30; i=i+2)   /* DCA envelope levels, each= 0-99 */
      {
         c= czbuf[i+6+k] & 0x7F;    /* get rid of sustain bit */
         if (c==0)
            area[i+kk]= 0;
         else
            area[i+kk]= c-0x1c;
      }
      area[31+kk]= 8;            /* default: no DCA sustain point */
      for (i=0; i<=6; i++)       /* DCA envelope sustain point = 0-6 */
         if (czbuf[22+2*i+k]&0x80) area[31+kk]=i;  
      area[32+kk]= czbuf[37+k]&0x0f;    /* DCW envelope end step = 0-7 */
      for (i=33; i<=47; i=i+2)  /* DCW envelope rates, each = 0-99 */
      {
         c= (czbuf[i+5+k] & 0x7F) - 8;   /* get rid of up/down bit */
         if (c==0)
            area[i+kk]= 0;
         else
         {
            if (c==0x77)
               area[i+kk]= 99;
            else
               area[i+kk]= ((99*c)/119) + 1;
         }
      }   
      for (i=34; i<=48; i=i+2)   /* DCW envelope levels, each= 0-99 */
      {
         c= czbuf[i+5+k] & 0x7F;    /* get rid of sustain bit */
         if (c==0)
            area[i+kk]= 0;
         else
         {
            if (c==0x7F)
               area[i+kk]= 99;
            else
               area[i+kk]= ((99*c)/127) + 1;
         }
      }
      area[49+kk]= 8;            /* default: no DCW sustain point */
      for (i=0; i<=6; i++)       /* DCW envelope sustain point = 0-6 */
         if (czbuf[39+2*i+k]&0x80) area[49+kk]=i;  
      area[50+kk]= czbuf[54+k]&0x0f;    /* DCO envelope end step = 0-7 */
      for (i=51; i<=65; i=i+2)  /* DCO envelope rates, each = 0-99 */
      {
         c= czbuf[i+4+k] & 0x7F;   /* get rid of up/down bit */
         if (c==0)
            area[i+kk]= 0;
         else
         {
            if (c==0x7F)
               area[i+kk]= 99;
            else
               area[i+kk]= ((99*c)/127) + 1;
         }
      }   
      for (i=52; i<=66; i=i+2)   /* DCO envelope levels, each= 0-99 */
      {
         area[i+kk]= czbuf[i+4+k] & 0x7f;    /* get rid of sustain bit */
         if (area[i+kk]>63) area[i+kk]= area[i+kk]-4;
      }
      area[67+kk]= 8;            /* default: no DCO sustain point */
      for (i=0; i<=6; i++)       /* DCO envelope sustain point = 0-6 */
         if (czbuf[56+2*i+k]&0x80) area[67+kk]=i;  
   } /* end for (k=0; k<=57; k=k+57) */
   area[126]= ((czbuf[15]&0xff)>>3) & 0x07;    /* = modulation bits */
   if (area[126]==4) area[126]= 1;         /* ring mod on */
   if (area[126]==3) area[126]= 2;         /* noise on */        

/* cz-1 parameters */
   area[127]= (czbuf[20]&0xf0)>>4;        /* line 1 amp velocity */
   area[128]= (czbuf[37]&0xf0)>>4;        /* line 1 wave velocity */
   area[129]= (czbuf[54]&0xf0)>>4;        /* line 1 pitch velocity */
   area[130]= 15-((czbuf[16]&0xf0)>>4);   /* line 1 level */
   area[131]= (czbuf[77]&0xf0)>>4;        /* line 2 amp velocity */
   area[132]= (czbuf[94]&0xf0)>>4;        /* line 2 wave velocity */
   area[133]= (czbuf[111]&0xf0)>>4;       /* line 2 pitch velocity */
   area[134]= 15-((czbuf[73]&0xf0)>>4);   /* line 2 level */

/* name */
   if (syntype==2)
   {
      copybyte(&czbuf[128],&nameptr[0],16);
      nameptr[16]=0;
   }
   else
      copybyte(NONAME,&nameptr[0],17);

/* CZ interactions */
   if (area[0]<2) area[126]=0;
   area[16+2*area[14]]=0;
   area[34+2*area[32]]=0;
   area[52+2*area[50]]=0;
   area[74+2*area[72]]=0;
   area[92+2*area[90]]=0;
   area[110+2*area[108]]=0;
} /* end cztonorm(area,nameptr) */

/*.................... denormalize from area to czbuf ........................*/

normtocz(area,nameptr)
char area[];   /* 135 bytes */
char nameptr[];  /* 17 bytes */
{
   register int i,k,kk;
   char c;

   czbuf[0]= area[0]+(area[1]<<2);  /* line select / octave */
   czbuf[1]= area[2];                  /* detune +/- */
   i= area[3]<<2;                     /* fine detune */
   if (i>60)  i= i+4;
   if (i>124) i= i+4;
   if (i>188) i= i+4;
   czbuf[2]= i;
   czbuf[3]= 12*area[4] + area[5];   /* octave/note detune */
   czbuf[4]= pvktabl[area[6]];          /* vibrato waveform */
   czbuf[5]= area[7];                   /* vibrato delay */
   czbuf[6]= pvdltabl[2*area[7]];  
   czbuf[7]= pvdltabl[2*area[7]+1];  
   czbuf[8]= area[8];                   /* vibrato rate */
   czbuf[9]= pvsdtabl[2*area[8]];
   czbuf[10]= pvsdtabl[2*area[8]+1];   
   czbuf[11]= area[9];                  /* vibrato depth */
   czbuf[12]= pvdltabl[2*(area[9]+1)];
   czbuf[13]= pvdltabl[2*(area[9]+1)+1];

   for (k=0; k<=57; k=k+57)               /* for line= 1, then 2 */
   {
      kk= 58*k/57;
      czbuf[14+k]= czbuf[15+k]= 0;          /* build MFW */
      if (area[10+kk]==1) czbuf[14+k]=0x20;   
      if (area[10+kk]==2) czbuf[14+k]=0x40;
      if (area[10+kk]==3) czbuf[14+k]=0x80;
      if (area[10+kk]==4) czbuf[14+k]=0xa0;
      if (area[10+kk]>4)
      {
         czbuf[14+k]= 0xc0;
         czbuf[15+k]= (area[10+kk]-4)<<6;
      }
      else
         czbuf[15+k]= 0;
      if (area[11+kk]==0) czbuf[14+k]=czbuf[14+k] | 0x02;
      if (area[11+kk]==1) czbuf[14+k]=czbuf[14+k] | 0x06;
      if (area[11+kk]==2) czbuf[14+k]=czbuf[14+k] | 0x0a;
      if (area[11+kk]==3) czbuf[14+k]=czbuf[14+k] | 0x12;
      if (area[11+kk]==4) czbuf[14+k]=czbuf[14+k] | 0x16;
      if ((area[11+kk]>4)&&(area[11+kk]!=8))
      {
         czbuf[14+k]=czbuf[14+k] | 0x1a;
         czbuf[15+k]=(area[11+kk]-4)<<6;
      }
      if (k==0)
      {
         if (area[126]==1) czbuf[15]=czbuf[15] | 0x20;
         if (area[126]==2) czbuf[15]=czbuf[15] | 0x18;
      }
      czbuf[16+k]= area[12+kk];                 /* DCA key follow */
      czbuf[17+k]= mamdtabl[area[12+kk]];   
      czbuf[18+k]= area[13+kk];                 /* DCW key follow */
      if (syntype==2)
         czbuf[19+k]= mwhvtabl[area[13+kk]];   
      else
         czbuf[19+k]= mwmdtabl[area[13+kk]];        
      czbuf[20+k]= area[14+kk];                 /* DCA envelope end */
      for (i=21; i<=35; i=i+2)               /* DCA envelope rates */
         czbuf[i+k]= (119*area[i-6+kk])/99;
      for (i=22; i<=36; i=i+2)               /* DCA envelope levels */
         if (area[i-6+kk]==0) 
            czbuf[i+k]= 0;
         else
            czbuf[i+k]= area[i-6+kk]+0x1c;
      for (i=23; i<=35; i=i+2)              /* set rise/fall bits */
         if (czbuf[i-1+k]>czbuf[i+1+k])
            czbuf[i+k]= czbuf[i+k] | 0x80;
      if (area[31+kk]!=8)                   /* DCA sustain point */
         czbuf[k+22+2*area[31+kk]]=
         czbuf[k+22+2*area[31+kk]] | 0x80;
      czbuf[37+k]= area[32+kk];                 /* DCW envelope end */
      for (i=38; i<=52; i=i+2)               /* DCW envelope rates */
         czbuf[i+k]= (119*area[i-5+kk])/99+8;
      for (i=39; i<=53; i=i+2)               /* DCW envelope levels */
         czbuf[i+k]= (127*area[i-5+kk])/99;
      for (i=40; i<=52; i=i+2)              /* set rise/fall bits */
         if (czbuf[i-1+k]>czbuf[i+1+k])
            czbuf[i+k]= czbuf[i+k] | 0x80;
      if (area[49+kk]!=8)                   /* DCW sustain point */
         czbuf[k+39+2*area[49+kk]]=
         czbuf[k+39+2*area[49+kk]] | 0x80;
      czbuf[54+k]= area[50+kk];                 /* DCO envelope end */
      for (i=55; i<=69; i=i+2)               /* DCO envelope rates */
         czbuf[i+k]= (127*area[i-4+kk])/99;
      for (i=56; i<=70; i=i+2)               /* DCO envelope levels */
      {
         czbuf[i+k]= area[i-4+kk];
         if (czbuf[i+k]>63) czbuf[i+k]= czbuf[i+k]+4;
      }
      for (i=57; i<=69; i=i+2)              /* set rise/fall bits */
         if (czbuf[i-1+k]>czbuf[i+1+k])
            czbuf[i+k]= czbuf[i+k] | 0x80;
      if (area[67+kk]!=8)                   /* DCO sustain point */
         czbuf[k+56+2*area[67+kk]]= 
         czbuf[k+56+2*area[67+kk]] | 0x80;
   } /* end for (k=0; k<=57; k=k+57) */
/* cz-1 parameters */
   if (syntype==2)
   {
      czbuf[16]=czbuf[16]|((15-area[130])<<4); /* line 1 level */
      czbuf[20]=czbuf[20]|(area[127]<<4); /* line 1 amp velocity */
      czbuf[37]=czbuf[37]|(area[128]<<4); /* line 1 wave velocity */
      czbuf[54]=czbuf[54]|(area[129]<<4); /* line 1 pitch velocity */
      czbuf[73]=czbuf[73]|((15-area[134])<<4); /* line 2 level */
      czbuf[77]=czbuf[77]|(area[131]<<4); /* line 2 amp velocity */
      czbuf[94]=czbuf[94]|(area[132]<<4); /* line 2 wave velocity */
      czbuf[111]=czbuf[111]|(area[133]<<4); /* line 2 pitch velocity */
/* name */
      copybyte(&nameptr[0],&czbuf[128],16);
      k=0;
      for (i=0; i<=15; i++)
      {
         if (k)
            czbuf[128+i]=0x20;
         else
         {
            if (!czbuf[128+i])
               {   czbuf[128+i]=0x20;   k=1;   }
            else
            {
               if (czbuf[128+i]< 0x20) czbuf[128+i]=0x20;
               if (czbuf[128+i]> 0x7f) czbuf[128+i]=0x20;   
               if (czbuf[128+i]==0x7e) czbuf[128+i]=0x20;
               if (czbuf[128+i]==0x5c) czbuf[128+i]=0x20;
            }
         }
      } /* end for */
   } /* end if syntype==2 */
} /* end normtocz(area,nameptr) */

/*......................... generate random # ................................*/

random(limit)   /* return a random integer from 0 to limit */
register int limit;
{
   register int i;
   
   i= Random()&0x7FFF;    /* i = random # from 0 to 0x7FFF */
   return(i%(limit+1));
} /* end random(limit) */

/*............................. randomize a parameter ........................*/

randx(oldval,amt,low,high)
int oldval,amt,low,high;
{
   int i,difflo,diffhi;

   i= random(amt);
   difflo= oldval-i;
   diffhi= oldval+i;

   if (difflo<low)
   {
      if (diffhi>high)
         return(oldval);
      else
         return(diffhi);
   }
   if (diffhi>high) return(difflo);
   if (random(1))
      return(difflo);
   else
      return(diffhi);
} /* end randx(oldval,amt,low,high) */ 

/*...................... part of copy-protection scheme ......................*/

do_event()
{
   switch (sequence)
   {
      case 0:
         if (Alock)
            pro_pass=1;
         else
            pro_pass=0;
         break;
      case 1:
         if (pro_pass) break;
         if (!plover())
         {
            if (!xyzzy())
               pro_pass=1;
            else
               pro_pass=0;
         }
         else
            pro_pass=0;
         break;
      case 2:
         if (!pro_pass) timebomb= random(31)+1;
         break;
      case 3:
         if (pro_pass) break;
         if (!(timebomb--)) death();
   } /* end switch (sequence) */
   sequence++;
   if (sequence>3) sequence=3;
} /* end do_event() */

/* EOF */
