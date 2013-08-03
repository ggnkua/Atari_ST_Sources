/************************************************************/
/*												*/
/*		De l'utilisation du Replay 030 Amiga			*/
/*												*/
/*		Of Use of the Amiga 030 Replay				*/
/*												*/
/*		Par Simplet / FATAL DESIGN					*/
/*												*/
/************************************************************/

#include <tos.h>
#include <screen.h>
#include <amiga030.h>

#define MODNAME "E:\\SNDTRACK\\DEPACK\\NEXUS-7.MOD"

void main(void);
 
void main(void)
{
	long		adr,max,length;
	int		dummy,handle;
	char		tch;
	DTA		*buf;

	Cconws(CLEAR_HOME);
	Cconws("Amiga 4 interlaced voices 030 Replay Routine by Simplet / FATAL DESIGN\r\n");
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

	Cconws("Ok!\r\n\n");

	MGTK_Save_Sound();
	MGTK_Init_Sound();
	MGTK_Restart_Loop=-1;
	MGTK_Play_Music();

	Cconws("You can use the following keys :\r\n");
	Cconws("  - or + for previous or next music position\r\n");
	Cconws("  L for play, P for pause, S for stop\r\n");
	Cconws("  Space to quit\r\n");

	do
		{
		tch=Crawcin();
		switch ( tch-32*((97<=tch) && (tch<=122)) )
			{
			case	'-':	MGTK_Previous_Position();break;
			case '+':	MGTK_Next_Position();break;
			case	'L':	MGTK_Play_Music();break;
			case	'P':	MGTK_Pause_Music();break;
			case	'S':	MGTK_Stop_Music();break;
			}
		}
	while (tch!=*" ");
		
	MGTK_Stop_Music();
	MGTK_Restore_Sound();
}
