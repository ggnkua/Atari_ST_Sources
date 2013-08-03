/************************************************************/
/*												*/
/*		De l'utilisation du Replay DSP Amiga			*/
/*												*/
/*		Of Use of the Amiga DSP-Replay				*/
/*												*/
/*		Par Simplet / FATAL DESIGN					*/
/*												*/
/************************************************************/

#include <tos.h>
#include <screen.h>
#include <amigadsp.h>

#define MODNAME "E:\\SNDTRACK\\DEPACK\\NEXUS-7.MOD"

void main(void);
 
void main(void)
{
	long		adr,max,length;
	int		dummy,handle,freq_div=1;
	char		tch;
	DTA		*buf;

	Cconws(CLEAR_HOME);
	Cconws("Amiga 4/6/8 voices & xxCH DSP Replay Routine by Simplet / FATAL DESIGN\r\n");
	Cconws("----------------------------------------------------------------------\r\n\n");

	dummy=Fsfirst(MODNAME,0);
	buf=Fgetdta();
	length=buf->d_length;
	
	if (dummy!=0)
		{
		Cconws("Disk Error!\r\nPress any key...");
		Crawcin();exit();
		}

	Cconws("Allocating Memory...");

	adr=Malloc(length+20832);		/* Workspace takes up to 20832 bytes */
	if (adr<=0)
		{
		Cconws("Error!\r\nNot enough Memory to load!\r\nPress any key...");
		Crawcin();exit();
		}
	
	Cconws("Ok!\r\nLoading Module...");

	handle=Fopen(MODNAME,FO_READ);
	Fread(handle,length,adr);
	Fclose(handle);

	Cconws("\r\nInitialising Module and Samples...");

	dummy=MGTK_Init_Module_Samples(adr,adr+length+20832);
	if (dummy==-3)
		{
		Cconws("Error!\r\n");
		Cconws("Not enough workspace to prepare samples!\r\n");
		Cconws("Press any key...");
		Crawcin();exit();
		}

	Cconws("Ok!\r\nInitialising DSP Program...");

	dummy=MGTK_Init_DSP();
	if (dummy!=0)
		{
		Cconws("Error!\r\n");
		Cconws("DSP Program couldn't be loaded!\r\n");
		Cconws("Press any key...");
		Crawcin();exit();
		}

	Cconws("Ok!\r\n\n");

	MGTK_Save_Sound();
	MGTK_Init_Sound();
	MGTK_Set_Replay_Frequency(freq_div);
	MGTK_Restart_Loop=-1;
	MGTK_Play_Music();

	Cconws("You can use the following keys :\r\n");
	Cconws("  - or + for previous or next music position\r\n");
	Cconws("  / or * for previous or next replay frequency\r\n");
	Cconws("  L for play, P for pause, S for stop\r\n");
	Cconws("  Space to quit\r\n");

	do
		{
		tch=Crawcin();
		switch ( tch-32*((97<=tch) && (tch<=122)) )
			{
			case	'-':	MGTK_Previous_Position();break;
			case '+':	MGTK_Next_Position();break;
			case '/':	if (freq_div>1)
					MGTK_Set_Replay_Frequency(--freq_div);break;
			case '*':	if (freq_div<5)
					MGTK_Set_Replay_Frequency(++freq_div);break;
			case	'L':	MGTK_Play_Music();break;
			case	'P':	MGTK_Pause_Music();break;
			case	'S':	MGTK_Stop_Music();break;
			}
		}
	while (tch!=*" ");
		
	MGTK_Stop_Music();
	MGTK_Restore_Sound();
}
