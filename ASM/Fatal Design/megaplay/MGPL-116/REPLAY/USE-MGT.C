/************************************************************/
/*												*/
/*		De l'utilisation du Replay DSP MegaTracker		*/
/*												*/
/*		Of Use of the MegaTracker DSP Replay			*/
/*												*/
/*		Par Simplet / FATAL DESIGN					*/
/*												*/
/************************************************************/

#include <tos.h>
#include <screen.h>
#include <unpack.h>
#include <mgt-play.h>

#define MAXSIZE 350000
#define MODNAME "E:\\SNDTRACK\\DEPACK\\CCITY12.MGT"

void main(void);
 
void main(void)
{
	long		adr,length;
	int		dummy,handle,freq_div = 1;
	char		tch;
	DTA		*buf;
	char		packers[6][17]	=
	{"Unpacked...","Atomik 3.5...",
	"Speedpacker 3...","Pack Ice 2.4...",
	"Powerpacker 2...","Sentry 2.0..."};

	Cconws(CLEAR_HOME);
	Cconws("MegaTracker¿ v1.1 DSP-Replay Routine by Simplet / FATAL DESIGN\r\n");
	Cconws("--------------------------------------------------------------\r\n\n");

	Cconws("Allocating Memory...");

	adr=Malloc(MAXSIZE);
	if (adr<=0)
		{
		Cconws("Error!\r\n");
		Cconws("Not enough Memory!\r\n");
		Cconws("Press any key...");
		Crawcin();exit();
		}
	
	Cconws("Ok!\r\nLoading Module...");

	dummy=Fsfirst(MODNAME,0);
	buf=Fgetdta();
	length=buf->d_length;
	
	if ((dummy!=0) || (length > MAXSIZE))
		{
		if (dummy!=0) Cconws("Disk Error!\r\n");
		else	Cconws("Not enough Memory to load!\r\n");
		Cconws("Press any key...");
		Crawcin();exit();
		}

	handle=Fopen(MODNAME,FO_READ);

	dummy=Unpack_Detect_Disk(handle,MAXSIZE);

	if (dummy<0)
		{
		Fclose(handle);
		switch (dummy)
			{
			case -1:	Cconws("Unavailable packer!\r\n");break;
			case -2:	Cconws("Not enough Memory to unpack!\r\n");break;
			}
			Cconws("Press any key...");
			Crawcin();exit();
		}
	else	{
		Fread(handle,length,adr);
		Fclose(handle);
		if (dummy==0) Cconws("Unpacked!");
		else {
			Cconws("Ok!\r\nUnpacking ");
			Cconws(packers[dummy]);
			Unpack_All(adr,length);
			Cconws("Ok!");
			}
		}

	Cconws("\r\nInitialising Module and Samples...");

	dummy=MGTK_Init_Module_Samples(adr,adr+MAXSIZE);
	if (dummy!=0)
		{
		Cconws("Error!\r\n");
		switch (dummy)
			{
			case -1:	Cconws("This is not a MegaTracker module!\r\n");break;
			case -2:	Cconws("Not enough workspace to depack tracks!\r\n");break;
			case -3:	Cconws("Not enough workspace to prepare samples!\r\n");break;
			case -4:	Cconws("No samples in this module!\r\n");break;
			}
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
	MGTK_Play_Music(0);

	Cconws("You can use the following keys :\r\n");
	Cconws("  - or + for previous or next music\r\n");
	Cconws("  ( or ) for previous or next music position\r\n");
	Cconws("  / or * for previous or next replay frequency\r\n");
	Cconws("  L for play, P for pause, S for stop\r\n");
	Cconws("  Space to quit\r\n");

	do
		{
		tch=Crawcin();
		switch ( tch-32*((97<=tch) && (tch<=122)) )
			{
			case	'-':	MGTK_Previous_Music();break;
			case '+':	MGTK_Next_Music();break;
			case	'(':	MGTK_Previous_Position();break;
			case ')':	MGTK_Next_Position();break;
			case '/':	if (freq_div>1)
					MGTK_Set_Replay_Frequency(--freq_div);break;
			case '*':	if (freq_div<5)
					MGTK_Set_Replay_Frequency(++freq_div);break;
			case	'L':	MGTK_Play_Music(0);break;
			case	'P':	MGTK_Pause_Music();break;
			case	'S':	MGTK_Stop_Music();break;
			}
		}
	while (tch!=*" ");
		
	MGTK_Stop_Music();
	MGTK_Restore_Sound();
}
