/*
 * 	The Digital Sound Module.
 * 	(c) 1994 Martin Griffithis
 */ 

#include <stdio.h>
#include <e_gem.h>
#include <ext.h>
#include "types.h"

#define DMAPLAY (0)
#define DSPXMIT (1)
#define EXTINP  (2)
#define ADC     (3)
#define DMAREC  (1)
#define DSPRECV (2)
#define EXTOUT  (4)
#define DAC     (8)
#define CLK_25M (0)
#define CLK_EXT (1)
#define CLK_32M (2)
#define CLK_COMPAT (0)
#define CLK_50K (1)
#define CLK_33K (2)
#define CLK_25K (3)
#define CLK_20K (4)
#define CLK_16K (5)
#define CLK_12K (7)
#define CLK_10K (9)
#define CLK_8K  (11)
#define HANDSHAKE (0)
#define NO_SHAKE (1)
#define HF_CLEAR (0)
#define HF_SET (1)
#define HF_INQUIRE (-1)

static int our_ability;
static long x_avail,y_avail;
extern long DSP_Initial_Sync(void);
extern long Sound_Interrupt_ON(void);
extern long Sound_Interrupt_OFF(void);

alloc16 octave;
alloc16 volume;
extern void *vol_conv_tab_ptr;
extern void *octave_table_ptr;

Bool DSP_Init(void)
{	char dsp_buf[14000];
	char cwd_path[256];
	char lod_path[256];
	char oct_path[256];
	char vol_path[256];
	if (Dsp_GetWordSize() != 3)
	{	xalert(	1,1,X_ICN_ALERT,NULL,BUTTONS_CENTERED,TRUE,title,
				" This Program requires a 24bit DSP 56001, "," [Quit ");
		return FALSE;
	}
	
	while (Dsp_Lock() != 0) 
	{	int res=xalert(	1,1,X_ICN_ALERT,NULL,BUTTONS_CENTERED,TRUE,title,
							" The DSP is locked for use by another Application "," [Retry | [Ignore | [Quit ");
		if (res == 2)
			return FALSE;
		if (res == 1)
			break;
	}
	
	Dsp_Hf0(HF_CLEAR);
	Dsp_Hf1(HF_CLEAR);
	Dsp_FlushSubroutines();
	Dsp_Available(&x_avail,&y_avail);		
	
	if (Dsp_Reserve(x_avail,y_avail) == -1)
	{	xalert(	1,1,X_ICN_ALERT,NULL,BUTTONS_CENTERED,TRUE,title,
				"  Sorry, not enough DSP memory available.  "," [Quit ");
	}
	
	our_ability = Dsp_RequestUniqueAbility();
	getcwd(&cwd_path, 255);
	if (cwd_path[strlen(cwd_path)-1] != '\\')
		strcat(cwd_path,"\\");
	strcpy(lod_path,cwd_path);
	strcpy(oct_path,cwd_path);
	strcpy(vol_path,cwd_path);
	strcat(lod_path,LOD_FILENAME);
	strcat(oct_path,"data.inc\\octave.dat");
	strcat(vol_path,"data.inc\\vol_conv.dat");
	if (Alloc_Read_File(oct_path,&octave) == FALSE)
	{
		xalert(	1,1,X_ICN_ALERT,NULL,BUTTONS_CENTERED,TRUE,title,
				"  Failed to Load Octave Conversion Table  "," [Quit ");
		return FALSE;

	}
	if (Alloc_Read_File(vol_path,&volume) == FALSE)
	{
		xalert(	1,1,X_ICN_ALERT,NULL,BUTTONS_CENTERED,TRUE,title,
				"  Failed to Load Volume Conversion Table  "," [Quit ");
		return FALSE;
	}
	
	if (Dsp_LoadProg(lod_path,our_ability,dsp_buf) < 0)
	{	
		xalert(	1,1,X_ICN_ALERT,NULL,BUTTONS_CENTERED,TRUE,title,
				"  The DSP .LOD File could not be found.  "," [Quit ");
		return FALSE;		
	}

	vol_conv_tab_ptr = volume.ptr;
	octave_table_ptr = octave.ptr;

	dsptristate(1,1);		/* connect dsp to sound matrix */
	devconnect(DMAPLAY,EXTOUT,CLK_32M,CLK_33K,NO_SHAKE);
	devconnect(DSPXMIT,DAC,CLK_32M,CLK_33K,NO_SHAKE);
	devconnect(EXTINP,EXTOUT,CLK_32M,CLK_33K,NO_SHAKE);
	devconnect(ADC,EXTOUT,CLK_32M,CLK_33K,NO_SHAKE);	
	Dsp_RemoveInterrupts(3);			/* disable interrupts */
	Supexec(*DSP_Initial_Sync);
	Supexec(*Sound_Interrupt_ON);
	return TRUE;

}

void DSP_DeInit(void)
{
	free16 (&octave);
	free16 (&volume);
	Supexec(*Sound_Interrupt_OFF);
	Dsp_Unlock();
}

