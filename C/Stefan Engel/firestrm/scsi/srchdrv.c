/*{{{}}}*/
/****************************************************************************
 *
 * Beispiel fÅr die Benutzung des SCSI-Treibers
 * Suche nach vorhandenen GerÑten.
 *
 * $Source: /dev/f/kleister.ii/cbhd\RCS\srchdrv.c,v $
 *
 * $Revision: 1.4 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1995/11/14 22:15:26 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: srchdrv.c,v $
 * Revision 1.4  1995/11/14  22:15:26  S_Engel
 * Meldung von CanDisconnect und ScatterGather
 *
 * Revision 1.3  1995/10/22  15:42:28  S_Engel
 * Anpassung auf lange Handles
 *
 * Revision 1.2  1995/09/29  09:18:56  S_Engel
 * Jetzt ist es Warning Free :-)
 *
 * Revision 1.1  1995/06/16  12:06:46  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************/

#include <stdio.h>

#include <import.h>
#include <portab.h>

#include <scsiio.h>
#include <scsi.h>
#include <export.h>

#define MIN(A,B) A>B ? B:A

/* Bus nach GerÑten absuchen */

void scan_bus(tBusInfo Bus)
{{{
	tInqData	InqData;
	tDevInfo	Dev;
	tHandle 	handle;
	ULONG 		MaxLen;
	WORD			ret;
	char			Name[20];
	UWORD 		Features;

/* handle = scsicall->Open(1, 0, &MaxLen);*/


	SuperOn();
	ret = scsicall->InquireBus(cInqFirst, Bus.BusNo, &Dev);
	SuperOff();

	while (ret == 0)
	{
		printf("  Id %2ld ", Dev.Id.lo);
#if TRUE
		SuperOn();
		ret = scsicall->CheckDev(Bus.BusNo, &Dev.Id, Name, &Features);
		SuperOff();
		if (ret == 0)
			{
				printf("%s ", Name);
				if (Features & cArbit)
					printf(" arbit,");
				if (Features & cAllCmds)
					printf(" all cmds,");
				if (Features & cTargCtrl)
					printf(" target controlled,");
				if (Features & cTarget)
					printf(" target installable,");
				if (Features & cCanDisconnect)
					printf(" Disconnect possible,");
				if (Features & cScatterGather)
					printf(" scatter gather,");
				printf("\b \n     ");
			}
		else
			{

			}
#endif

		memset (&InqData, 0, sizeof (tInqData));

		SuperOn();
		handle = (tHandle) scsicall->Open(Bus.BusNo, &Dev.Id, &MaxLen);
		if (handle >= 0)
		{
			SetScsiUnit(handle, 0, MaxLen);
			/* erst den Header */
			ret = Inquiry(&InqData, FALSE, 0, 5);
			if (ret == 0L)
			{
				ret = Inquiry(&InqData, FALSE, 0, (WORD) MIN((WORD)5 + (WORD)InqData.AddLen, (WORD)sizeof(InqData)));
			}
			scsicall->Close(handle);
		}

		SuperOff();

		if (handle >= 0)
		{
			printf(" handle $%lx", handle);
		}

		printf(" MaxLen $%lx", MaxLen);

		if ((handle >= 0) && (ret == 0L))
		{
			InqData.Revision[0] = 0;
			printf(" %s ", InqData.Vendor);
			switch (InqData.Device & 0x1F) {
				case 0: printf ("direct access device");
								break;
				case 1: printf ("sequential access device");
								break;
				case 2: printf ("printer device");
								break;
				case 3: printf ("processor device");
								break;
				case 4: printf ("write-once device");
								break;
				case 5: printf ("CD-ROM device");
								break;
				case 6: printf ("scanner device");
								break;
				case 7: printf ("optical memory device");
								break;
				case 8: printf ("medium changer device");
								break;
				case 9: printf ("communications device");
								break;
				case 10:
				case 11: printf ("ASC IT 8 (graphic arts pre-press device)");
								break;
				case 0x1f: printf ("unknown device");
								break;

				default : printf(" reserved device tpye %h", InqData.Device);
			}
		}
		else
		{
			if (handle < 0)
				printf(": no Handle");
			else
				printf(": no Device ($%x)", ret);
		}
		printf("\n");

		SuperOn();
		ret = scsicall->InquireBus(cInqNext, Bus.BusNo, &Dev);
		SuperOff();

		} 	/* while */

}}}

void search_drives(void)
{{{
	LONG					ret;
	tBusInfo			Info;

	printf("\nsearching drives...\n");

	SuperOn();
	ret = scsicall->InquireSCSI(cInqFirst, &Info);
	SuperOff();
	while (ret == 0)
	{

		printf("\n Bus %s, No %d\n", Info.BusName, Info.BusNo);
		scan_bus(Info);

		SuperOn();
		ret = scsicall->InquireSCSI(cInqNext, &Info);
		SuperOff();
	}
}}}

WORD main(void)
{{{

	printf("Demo-Programm fÅr Benutzung der SCSI-Calls");
	printf("  Ω Steffen Engel 1995");

	if (init_scsiio() && init_scsi())
		search_drives();
	else
		printf("SCSI-Lib nicht benutzbar");

	printf("\n Taste drÅcken");
	do
	{
	} while (Cconis());
	Cconin();
/*
*/
	return (0);

}}}
				
				
				