/*                                                                           */
/*                   Reviver Program                                	     */
/*	                Dave Small				    	     */
/*        written in desperation, November, 1986   		    	     */
/*                                                                           */ 
/*		   START, the ST Quarterly				     */
/*		   Issue 4, Spring 1987 				     */
/*                 Copyright (c) 1987 by ANTIC Publishing                    */
/*									     */
/* 								    */
/*       Revives a sick autoboot hard disk.                         */
/*                                                                  */
/*    Dedicated to:                                                 */
/*                                                                  */
/*     Rosebud (The X-15 Cruise Basselope),                         */
/*      as a cure for "one of those days".                          */
/*                                                                  */
/* Loosely based on something Patrick Bass did many issues back for */
/*   ANTIC. */

#include  <portab.h>		/* The Same Old Tripe */
#include  <obdefs.h>
#include  <define.h>
#include  <gemdefs.h>
#include  <osbind.h>

/* GEM stuff */
	int  contrl[12], intin[256], ptsin[256], intout[256], ptsout[256];
	int  l_intin[20], l_ptsin[20], l_out[100];

	int  handle;  /* from v_opnvwk */
	int  height,width; /* from graf_handle */
	int  i; /* for init loop */
	int  dummy; /* for graf_handle call */
	int  key_state; /* for keyboard call */
/* defines for protobt */
	int  buffer[256]; /* 512 byte bugger area */
	long buf,serialno;  /* for protobt */
	int  disktype,execflag; /* for protobt */
/* defines for flopwr, floprd */
	int  wrstatus; /* how the write went */
	int  rdstatus; /* how the read went */
/*   long buf;       already defined in protobt */
	long      filler;   /* unused */
	int  devno,sectno,trackno,sideno,count;
			/* devno=floppy (0=a,1=b),sectno =sector 1-9) */
			/* trackno=track (0-79),sideno=side(1=back?) */
			/* count is # of sectors to write (.le. # on track) */
/* defines for slow-it-down */
	int  slowcnt; /* for slow-it-down loop */

/* ********************************************** */
/* slow is just a delay loop. Counts up to 32000. */
/* inputs: nothing.                               */
/* outputs: nothing.                              */
/* ********************************************** */
slow()
{
	slowcnt = 0;
	for (slowcnt=1;slowcnt<32000;slowcnt++); /* count it up */
}
/* *************************************** */
/* Loop, waiting for a shift-alt-ctrl key. */
/* inputs: nothing.                        */
/* outputs: nothing.                       */
/* *************************************** */     
waitkey()
{    key_state=0;   /* init for following loop */
	while (key_state == 0) {
		vq_key_s(handle, &key_state) ; /* get state into keystate */
	}    /* loop until it is nonzero */
	slow();   /* debounce the key */
}
/* *********************** */
/* Main program segment.   */        
/* Setup screen & prompts  */
/* Read boot sector        */
/* Patch it. Feed to protobot     */
/* Write it to    boot     */
/* Exit.                   */   
/* *********************** */
main()
{
	appl_init(); /* magic */
	
	handle=graf_handle(&width,&height,&dummy,&dummy); /* more magic */

/* initialize workstation input params */

	for(i=0; i<10; i++)
	{
	l_intin[i]=1; /* set them all to 1 */
	}
	l_intin[10]=2; /* except for the last one (which is 2) */

	v_opnvwk(l_intin, &handle, l_out);
	v_clrwk(handle);

/* ******************* */
/* This does most of de stuff */


/* plot title page */

	v_gtext(handle,0,height*01,"  Hard Disk De-booter.");
	v_gtext(handle,0,height*02," Makes a bootable floppy that ");
	v_gtext(handle,0,height*03," lets you boot system with bad hard disk");
	v_gtext(handle,0,height*04," by screwing up the auto HD boot process.");
	v_gtext(handle,0,height*05," Put Bootable Single Sided Disk in Drive A,");
	v_gtext(handle,0,height*06," then press the SHIFT key.");
/* big do-while loop. Exits when read status goes ok. */
	do {

	waitkey(); /* wait fer his shift key */

/* zap read status message in case this is a reloop */
    v_gtext(handle,0,height*9,"                                             ");

	v_gtext(handle,0,height*8," Now reading boot sector. ");

/* Read in the boot sector.. loader stuff. */
/* set read params */
/*   buf=&buffer;           (already done upstairs) */
	filler=0;           /* unused longword */
	devno=0;       /* drive a */
	sectno=1;           /* sector 1 */
	trackno=0;          /* track # 0 */
	sideno=0;           /* side 0 */
	count=1;       /* # of sectors to write */
/* do read */
	rdstatus=xbios(8,&buffer,filler,devno,sectno,trackno,sideno,count);
/* status message */
	if (rdstatus==0) {
		v_gtext(handle,0,height*9," Sector read in ok. ");
	}
	else {
 v_gtext(handle,0,height*9," Error reading sector. Press SHIFT to retry.");
	}
/* decide to retry/go on */
    } while (rdstatus !=0); /* exit when rdstatus goes to 0, else reloop */
/* ******************* */

v_gtext(handle,0,height*12," Now modifying boot sector in memory.. ");

/* Add branch at start (+0)  object =  0x601c  .. start at $1e */
	*buffer = 0x601c;   /* bra.s to code */

/* Add at $1e: addq.l #4,a7  object = 584f */
	buffer[0x0f] = 0x584f;

/* Add at $20: jmp  $fc 03da     object = 4ef9 00fc03da */
	buffer[0x10] = 0x4ef9;
	buffer[0x11] = 0x00fc;
	buffer[0x12] = 0x03da;

/* set prototype params */

		serialno=0x00654321; /* generate serial # */
		disktype=2;    /* sng side 80 trk */
		execflag=1;    /* executable */

/* make prototype boot sector */
		xbios(18,&buffer,serialno,disktype,execflag);

/* ********************** */

/* another big do-while loop until wrstatus = 0.. */

	do {

	v_gtext(handle,0,height*15," Put a disk to write boot sector on");
	v_gtext(handle,0,height*16," in drive A, then press the SHIFT key.");

	waitkey();

	v_gtext(handle,0,height*18," Now writing boot sector..");

/* blank fill in case of reloop */

  v_gtext(handle,0,height*20,"                                              ");
	
/* set write params */
/*   buf=&buffer;           (already done upstairs) */
	filler=0;           /* unused longword */
	devno=0;       	    /* drive a */
	sectno=1;           /* sector 1 */
	trackno=0;          /* track # 0 */
	sideno=0;           /* side 0 */
	count=1;            /* # of sectors to write */
/* do write */
	wrstatus=xbios(9,&buffer,filler,devno,sectno,trackno,sideno,count);
/* status message */
	if (wrstatus==0) {
		v_gtext(handle,0,height*20," Sector wrote out ok. ");
	}
	else {
  v_gtext(handle,0,height*20," Error writing sector. Press SHIFT to retry.");
	}

/* decide to retry/go on (end of big do loop) */

    } while (wrstatus !=0); /* exit when rdstatus goes to 0, else reloop */

/* friendly wave bye-bye */

v_gtext(handle,0,height*22,"Remove floppy.");
v_gtext(handle,0,height*23,"Then, press the SHIFT key to exit to GEM desktop.");

	waitkey();

/* exit, stage left */
	
	v_clsvwk(handle);
	appl_exit();
}
