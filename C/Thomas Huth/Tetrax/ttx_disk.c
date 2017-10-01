/* *** TTX_DISK.C - Disk and memory stuff*** */

#include <aes.h>
#include <osbind.h>
#ifdef SOZOBON
#include <basepage.h>
#include <osheader.h>
#endif
#include <string.h>
#include <signal.h>

#include "ttx_main.h"
#include "ttx_rsc.h"
#include "xgriff.h"

#ifdef SOZOBON
extern short _app;					/* Are we an application or an accessory? */
#define aesversion  gl_apversion	/* Depends on your GEM-Lib */
#endif

#ifdef __TURBOC__ /* Turbo-C GEM Lib */
#define aesversion _GemParBlk.global[0]
#define BASEPAGE BASPAG
#define OSHEADER SYSHDR
#define p_run _run
#define _base _BasPag
#define lmemcpy memcpy
#define	Syield()	gemdos(0xff)#endif

char pathname[256];
char filename[64];


/* **Special malloc for accessories** */
void *accmalloc(long amount)
{
 void *adr;
 void *oldsp;
 OSHEADER *oshead;
 BASEPAGE *oldbp;

 if(!_app && aesversion<0x0399)		/* If we are an acc, we must fix the p_run os-variable */
  {
   oldsp=(void *)Super(0L);
   oshead=(OSHEADER *)*(long *)0x4F2;	/* Get the header */
   oldbp=*(oshead->p_run);		/* Get the old basepage in p_run */
   *(oshead->p_run)=_base;		/* Set our basepage in p_run */
  }

 adr=(void *)Mxalloc(amount, 2);
 if((long)adr==-32L)
  adr=(void *)Malloc(amount);

 if(!_app && aesversion<0x0399)
  {
   *(oshead->p_run)=oldbp;		/* Set the old basepage in p_run */
   Super(oldsp);
  }

 return(adr);
}

/* **Special mfree for accessories** */
void accmfree(void *adr)
{
 void *oldsp;
 OSHEADER *oshead;
 BASEPAGE *oldbp;

 if(!_app && aesversion<0x0399)  /* If we are an acc, we must fix the p_run os-variable */
  {
   oldsp=(void *)Super(0L);
   oshead=(OSHEADER *)*(long *)0x04F2; /* Get the header */
   oldbp=*(oshead->p_run);   /* Get the old basepage in p_run */
   *(oshead->p_run)=_base;   /* Set our basepage in p_run */
  }


 Mfree(adr);

 if(!_app && aesversion<0x0399)
  {
   *(oshead->p_run)=oldbp;   /* Set the old basepage in p_run */
   Super(oldsp);
  }
}


/* *** Get the size of a file *** */
long fgetsize(short fh)
{
 long oldoffset, fgsize;

 oldoffset=Fseek(0L, fh, 1);
 fgsize=Fseek(0L, fh, 2);
 Fseek(oldoffset, fh, 0);

 return(fgsize);
}

/* *** Load a module *** */
void load_mod(void)
{
 int fh;
 long len;
 char pathnfname[280];
 char modmagic[6];

 strcpy(pathnfname, pathname);
 strcat(pathnfname, filename);

 if( (fh=Fopen(pathnfname, 0)) < 0L )
  {
   char errtxt[100];
   strcpy(errtxt, "[3][Can't open file:|");
   strcat(errtxt, pathnfname);
   strcat(errtxt, "][OK]");
   form_alert(1, errtxt);
   return;
  }

 len=fgetsize(fh);
 if(len <= 0)
  {
   form_alert(1, "[3][Can't get size of file!][OK]");
   Fclose(fh);
   return;
  }

 if(modbuf)  accmfree(modbuf);

 strcpy(modulename, "None");

 modbuf=accmalloc(len);
 if(modbuf<=0L)
  {
   form_alert(1, "[3][Can't reserve memory!][OK]");
   modbuf=0L;
   Fclose(fh);
   return;
  }

 if( Fread(fh, len, modbuf) < len )
  {
   form_alert(1, "[3][Can't read file!][OK]");
   accmfree(modbuf); modbuf=0L;
   Fclose(fh);
   return;
  }

 Fclose(fh);

#ifndef TTX_DSP
 /* Check if the MOD is really a MOD: */
 memcpy(modmagic, ((char *)modbuf)+1080, 4);
 modmagic[4]=0;
 if( strcmp(modmagic, "M.K.")!=0 &&  strcmp(modmagic, "M!K!")!=0
    &&  strcmp(modmagic, "M&K&")!=0 &&  strcmp(modmagic, "FLT4")!=0 )
  {
   int i;
   char *oldbuf;
   i=form_alert(2,"[3][Tetrax-Warning: This is NOT a|"
       "supported MOD type (4 channels|and 31 instruments)! It might|"
       "be a 15 instruments MOD.|Shall I try to load it?][Load it|Abort]");
   if(i==2)
    {  accmfree(modbuf); modbuf=0L; return;  }
   /* Convert 15-instr.-MOD to 31 instr.-MOD: */
   oldbuf=modbuf;
   modbuf=accmalloc(len+16*30);
   if(modbuf<=0L)
    {
     form_alert(1, "[3][Can't reserve memory!][OK]");
     modbuf=0L; accmfree(oldbuf);  return;
    }
   memcpy(modbuf, oldbuf, 20+15*30);
   memset( ((char *)modbuf)+20+15*30, 0, 16*30);
   lmemcpy( ((char *)modbuf)+20+31*30, oldbuf+20+15*30, len-(20+15*30) );
  }
#endif

 if( *(char *)modbuf )  /* Get the name */
   strncpy(modulename, modbuf, 20);
  else
   strcpy(modulename, "No name");
}


/* *** Get the mod from a command line *** */
void getcommand(char *cmnd)
{
 int i;

 strcpy(pathname, cmnd);
 for(i=strlen(pathname) ; i>=0; i--)
   if( pathname[i]=='\\' ) break;
 strcpy(filename, &pathname[i+1]);
 pathname[i+1]=0;
 mod_stop();
 load_mod();
}


#define DD_OK  0
#define DD_NAK 1

char pipename[]="U:\\PIPE\\DRAGDROP.XX";

/* *** The drag&drop function *** */
/* *I guess it is very buggy, but it works...* */
short dragdrop(short ddnum)
{
 short fd, i;
 char buf[256];
 long datatyp, size;
 short headsize;

 for(fd=0; fd<34; fd++)  buf[fd]=0;	/* Clear the buffer */

 pipename[17]=(char)(ddnum>>8);     /* Create the pipename */
 pipename[18]=(char)ddnum;

 if( (fd=Fopen(pipename, 2))<0L )   return(-1);    /* Open the pipe */

 buf[0]=DD_OK;
 strcpy(&buf[1], "ARGS");

 Fwrite(fd, 33L, buf);

 Syield();

 Fread(fd, 2L, &headsize);
 Fread(fd, 4L, &datatyp);  /* Get the type */
 Fread(fd, 4L, &size);     /* Get the size */

 Fread(fd, (long)headsize-8, buf);

 if(datatyp!=(long)'ARGS')
  {
   buf[0]=DD_NAK;
   Fwrite(fd, 1L, buf);
   Fclose(fd);
   return(-1);
  }

 buf[0]=DD_OK;
 Fwrite(fd, 1L, buf);

 Syield();

 Fread(fd, size, buf);
 buf[size]=0;

 Fclose(fd);

 getcommand(buf);

 return(0);
}
