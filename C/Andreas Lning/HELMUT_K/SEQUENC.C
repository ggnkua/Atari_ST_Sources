

/* -----------------------------------------------------------------------*/
/* AS Sound Sampler  (Sequencer Demo Version Only)                        */
/* GEM Anwendung                                                          */
/* -----------------------------------------------------------------------*/
/* Written 1986 by Andreas LÅning                                          */
/* Application Service Software          Public Domain                     */
/* -----------------------------------------------------------------------*/
/* last Edit:  16.12.1986                                                 */
/* Linkfiles:  gemstart,samplnk,aesbind,vdibind,gemlib,osbind,libf        */
/* Hardware :  AD/DA Wandler am Centronics Druckerport                    */
/* -----------------------------------------------------------------------*/


/* Included Defs */
/*----------------------------------------------------------------------- */

#include "sequenc.h"
#include "sampinc.h"


/* Definitions */
/* ---------------------------------------------------------------------- */

#define  MAXSTEP        400
#define  MAXBLOCK       60

/* ------------------- */
/* etwas fuers Binding */
/* ------------------- */

int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

/* ------------------------------------------ */
/* Typenvereinbarungen zur Speicherverwaltung */
/* ------------------------------------------ */

typedef struct selmark
{
long  seqbegin;
long  seqlength;
char  seqname[20];
} BLOCK;

typedef struct sequenc
{
int   index;
int   speed;
int   repeat;
int   offset;
} SEQUENC;

/* globale Variablen */
/* ------------------------------------------------------------- */

int   handle;
int   phys_handle;


/* Speicher */
/* ------------------------- */

BLOCK    memblock[MAXBLOCK];
SEQUENC  seqlist[MAXSTEP];

long  g_len,g_buf;
long  r_len,r_buf;  

GRCT  desk;

/* Strings */
/* -------------------------- */

char  file_name[64] = { "" };
char  *wrterr       = { "[1][Write Error on your Disk][ Abort ]" };
char  *rderr        = { "[1][Read Error on your Disk][ Abort ]" };
char  *trouble      = { "[2][Trouble using your Disk][ Again | Abort ]" };
char  remark[160];

dialog(index,text)
int index,text;
{
long tree;
int  x,y,w,h;
int  ex_butt;

   resource(index);
   form_center(tree,&x,&y,&w,&h);
   form_dial(0,x,y,w,h,x,y,w,h);
   objc_draw(tree,0,8,desk.x,desk.y,desk.w,desk.h);
   ex_butt=form_do(tree,text);
   objc_change(tree,ex_butt,0,x,y,w,h,32,1);
   form_dial(3,x,y,w,h,x,y,w,h);
   return(ex_butt);
}


loadseq()
{
int  fhandle,i;
long length=0L;

   if(get_file("*.SEQ")==0) return(0);
   while((fhandle=Fopen(file_name,0))<0)
      if(form_alert(1,trouble)==2) return(0);

   if(Fread(fhandle,160L,remark)<0)
   {  form_alert(1,rderr);
      return(0);
   }

   for(i=0;i<MAXBLOCK;i++)
   {  if(Fread(fhandle,4L,&memblock[i].seqbegin)<0)
      {  form_alert(1,rderr);
         return(0);
      }
      if(memblock[i].seqbegin== -1L) break;
      memblock[i].seqbegin+=g_buf;
      if(Fread(fhandle,20L,&memblock[i].seqlength)<0)
      {  form_alert(1,rderr);
         return(0);
      }
      length+=memblock[i].seqlength;
   }

   if(length>g_len)
   {  form_alert(1,"[3][There is not enough|Memory to load the|Sequence][ OK ]");
      return(0);
      }

   for(i=0;i<MAXSTEP;i++)
   {  if(Fread(fhandle,2L,&seqlist[i].index)<0)
      {  form_alert(1,rderr);
         return(0);
      }
      if(seqlist[i].index== -1) break;
      if(Fread(fhandle,6L,&seqlist[i].speed)<0)
      {  form_alert(1,rderr);
         return(0);
      }
   }

   if(Fread(fhandle,length,g_buf)<0)
   {  form_alert(1,rderr);
      return(0);
   }

   Fclose(fhandle);
   return(1);
}

/* ------------- */
/* File Selector */
/* ------------- */

get_file(path)
char *path;
{
int   exbutt;
char  f_name[14];

   get_path(file_name,path);
   f_name[0]='\0';
   graf_mouse(M_ON,0L);
   fsel_input(file_name,f_name,&exbutt);
   graf_mouse(M_OFF,0L);
   if(exbutt)
   {  add_file_name(file_name,f_name);
      return(1);
   }
   else return(0);
}

get_path(path,spec)
char  *path,*spec;
{
int   drive;

   drive=Dgetdrv();
   path[0]=drive+'A';
   path[1]=':';
   path[2]='\\';
   Dgetpath(&path[3],drive+1);
   if(strlen(path)>3) strcat(path,"\\");
   else               path[3]='\0';
   strcat(path,spec);
}

add_file_name(dname,fname)
char  *dname,*fname;
{
char  c;
int   i;

   i=strlen(dname);
   while(i&&(((c=dname[i-1])!='\\')&&(c!=':'))) i--;
   dname[i]='\0';
   strcat(dname,fname);
}
/* ------------------ */
/* do_info            */
/* ------------------ */

do_info()
{
dialog(INF,0);
}


/* ------------------ */
/* Handle ANALOG-PORT */
/* ------------------ */

do_sequence(port)
int port;
{
int  i,r,block;
long buffer,length;

   graf_mouse(M_OFF,0L);
   Bconout(4,0x13);
   if(port) smpon();
   for(i=0;i<MAXSTEP;i++)
   {
      if(seqlist[i].index== -1) break;
      block=seqlist[i].index;
      buffer=memblock[block].seqbegin;
      length=memblock[block].seqlength;
      if(seqlist[i].offset<0) buffer+=length-1;
      for(r=0;r<seqlist[i].repeat;r++)
      {  if(port) speaker(buffer,length,(99-seqlist[i].speed)+6,seqlist[i].offset);
         else     output(buffer,length,(99-seqlist[i].speed)+9,seqlist[i].offset);
      }
   }
   if(port) smpoff();
   Bconout(4,0x11);
   graf_mouse(M_ON,0L);
}


/* ------------- */
/* Hauptprogramm */
/* ------------- */

main()
{
int   i;
int   dummy;
int   work_in[11],work_out[57];
int   end=0;

   appl_init();
   for(i=0;i<10;work_in[i++]=1);
   work_in[10]=2;
   v_opnvwk(work_in,&handle,work_out);

   wind_get(0,WF_WORKXYWH,&desk.x,&desk.y,&desk.w,&desk.h);
   graf_mouse(ARROW,0L);

   g_len=Malloc(-1L)-10000;

   if(g_len<0L)  form_alert(1,"[3][Out Of Memory][ OK ]");
   else
   {  g_buf=Malloc(g_len);              
      if(rsrc_load("sequenc.rsc")!=0)
      { graf_mouse(M_OFF,0L);
        if(loadseq())
        {  graf_mouse(M_ON,0L);
           while(!end)
              switch(dialog(BOX,0))
              {  
                  case DA: do_sequence(0);
                           break;
 
                  case SPEAKER: do_sequence(1);
                                break;
  
                  case QUIT: end=TRUE;
                             break;

                  case INFORMA: do_info();
                                break;
               }        
         }
      } 
  }

   v_clsvwk(handle);
   appl_exit();
}

