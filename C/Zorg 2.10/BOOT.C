/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <e_gem.h>
#include <string.h>

#include "globals.h"
#include "zorg.h"

#include "boot.h"
#include "brut.h"
#include "dialog.h"
#include "fenetre.h"
#include "ouvre.h"

/********************************************************************
*																	*
*					Lecture d'un boot (secteur 0)					*
*																	*
********************************************************************/
void lire_boot(void)
{
	int devno, err;
	char text[80];

	devno = choix_unit();

	if (devno != FAIL)
	{
		sprintf(text, Messages(BOOT_1),
		 devno >= 24 ? devno - 24 : devno >= 16 ? devno-16 : devno >= 8 ? devno-8 : devno,
		 devno >= 24 ? "ZORG" : devno >= 16 ? "IDE" : devno >= 8 ? "SCSI" : "ACSI");
		ajoute(Firstwindow, text);

		if (Boot == NULL)
			Boot = malloc(512L);

		if ((err = my_DMAread(0L, 1, Boot, devno)) != 0)
		{
			error_msg(err);
			return;
		}

		if (DeadSector != NULL)
		{
			free(DeadSector);
			DeadSector = NULL;
		}

		if (*(ULONG *)(Boot+0x1fa))
		{
			DeadSector = malloc(*(ULONG *)(Boot+0x1fa)*512L);
			if ((err = my_DMAread(*(ULONG *)(Boot+0x1f6), (int)*(ULONG *)(Boot+0x1fa), DeadSector, devno)) != 0)
			{
				error_msg(err);
				return;
			}
		}

		menu_ienable(Menu, SAUVER_BOOT, 1);
		menu_ienable(Menu, ECRIRE_BOOT, 1);
		info_boot();
	}
} /* lire_boot */

/********************************************************************
*																	*
*				informations contenues dans le boot					*
*																	*
********************************************************************/
void info_boot(void)
{
	char text[80];
	int i, chksum;

	sprintf(text, Messages(BOOT_2), *(UWORD *)(Boot+0x1B6));
	ajoute(Firstwindow, text);

	sprintf(text, Messages(BOOT_3), *(UBYTE *)(Boot+0x1B8));
	ajoute(Firstwindow, text);

	sprintf(text, Messages(BOOT_4), *(UWORD *)(Boot+0x1BA));
	ajoute(Firstwindow, text);

	sprintf(text, Messages(BOOT_5), *(UWORD *)(Boot+0x1BC));
	ajoute(Firstwindow, text);

	sprintf(text, Messages(BOOT_6), *(UBYTE *)(Boot+0x1BE));
	ajoute(Firstwindow, text);

	sprintf(text, Messages(BOOT_7), *(UBYTE *)(Boot+0x1BF));
	ajoute(Firstwindow, text);

	sprintf(text, Messages(BOOT_8), *(UBYTE *)(Boot+0x1C0));
	ajoute(Firstwindow, text);

	sprintf(text, Messages(BOOT_9), *(UBYTE *)(Boot+0x1C1));
	ajoute(Firstwindow, text);

	sprintf(text, Messages(BOOT_10), *(ULONG *)(Boot+0x1C2), (*(ULONG *)(Boot+0x1C2))*512L);
	ajoute(Firstwindow, text);

	ajoute(Firstwindow, " Partition 0");
	if (*(UBYTE *)(Boot+0x1c6) & 1)
	{
		if (*(UBYTE *)(Boot+0x1c6) & 0x80)
			ajoute(Firstwindow, Messages(BOOT_11));
		sprintf(text, "  Identification : %c%c%c", *(UBYTE *)(Boot+0x1c7),  *(UBYTE *)(Boot+0x1c8),  *(UBYTE *)(Boot+0x1c9));
		ajoute(Firstwindow, text);
		sprintf(text, Messages(BOOT_12), *(ULONG *)(Boot+0x1ca));
		ajoute(Firstwindow, text);
		sprintf(text, Messages(BOOT_13), *(ULONG *)(Boot+0x1ce), (*(ULONG *)(Boot+0x1ce))*512L);
		ajoute(Firstwindow, text);
	}
	else
		ajoute(Firstwindow, Messages(BOOT_14));

	ajoute(Firstwindow, " Partition 1");
	if (*(UBYTE *)(Boot+0x1d2) & 1)
	{
		if (*(UBYTE *)(Boot+0x1d2) & 0x80)
			ajoute(Firstwindow, "  La partition est bootable");
		sprintf(text, "  Identification : %c%c%c", *(UBYTE *)(Boot+0x1d3),  *(UBYTE *)(Boot+0x1d4),  *(UBYTE *)(Boot+0x1d5));
		ajoute(Firstwindow, text);
		sprintf(text, Messages(BOOT_12), *(ULONG *)(Boot+0x1d6));
		ajoute(Firstwindow, text);
		sprintf(text, Messages(BOOT_13), *(ULONG *)(Boot+0x1da), (*(ULONG *)(Boot+0x1da))*512L);
		ajoute(Firstwindow, text);
	}
	else
		ajoute(Firstwindow, Messages(BOOT_14));

	ajoute(Firstwindow, " Partition 2");
	if (*(UBYTE *)(Boot+0x1de) & 1)
	{
		if (*(UBYTE *)(Boot+0x1de) & 0x80)
			ajoute(Firstwindow, "  La partition est bootable");
		sprintf(text, "  Identification : %c%c%c", *(UBYTE *)(Boot+0x1df),  *(UBYTE *)(Boot+0x1e0),  *(UBYTE *)(Boot+0x1e1));
		ajoute(Firstwindow, text);
		sprintf(text, Messages(BOOT_12), *(ULONG *)(Boot+0x1e2));
		ajoute(Firstwindow, text);
		sprintf(text, Messages(BOOT_13), *(ULONG *)(Boot+0x1e6), (*(ULONG *)(Boot+0x1e6))*512L);
		ajoute(Firstwindow, text);
	}
	else
		ajoute(Firstwindow, Messages(BOOT_14));

	ajoute(Firstwindow, " Partition 3");
	if (*(UBYTE *)(Boot+0x1ea) & 1)
	{
		if (*(UBYTE *)(Boot+0x1ea) & 0x80)
			ajoute(Firstwindow, "  La partition est bootable");
		sprintf(text, "  Identification : %c%c%c", *(UBYTE *)(Boot+0x1eb),  *(UBYTE *)(Boot+0x1ec),  *(UBYTE *)(Boot+0x1ed));
		ajoute(Firstwindow, text);
		sprintf(text, Messages(BOOT_12), *(ULONG *)(Boot+0x1ee));
		ajoute(Firstwindow, text);
		sprintf(text, Messages(BOOT_13), *(ULONG *)(Boot+0x1f2), (*(ULONG *)(Boot+0x1f2))*512L);
		ajoute(Firstwindow, text);
	}
	else
		ajoute(Firstwindow, Messages(BOOT_14));

	/* liste des secteurs d‚f‚ctueux */
	sprintf(text, Messages(BOOT_15), *(ULONG *)(Boot+0x1f6));
	ajoute(Firstwindow, text);
	sprintf(text, Messages(BOOT_16), *(ULONG *)(Boot+0x1fa));
	ajoute(Firstwindow, text);

	if (DeadSector)
	{
		sprintf(text, Messages(BOOT_28), (*(UWORD *)DeadSector << 8) + (*(UBYTE *)(DeadSector+2)));
		ajoute(Firstwindow, text);

		chksum = 0;
		for (i=0; i<*(ULONG *)(Boot+0x1fa) * 512; i++)
			chksum ^= DeadSector[i];

		if (chksum == 0xA5)
		{
			ajoute(Firstwindow, Messages(BOOT_29));
			for (i=0; i<(*(UWORD *)DeadSector << 8) + *(UBYTE *)(DeadSector+2); i++)
			{
				sprintf(text, Messages(BOOT_31), (*(UBYTE *)(DeadSector+i+6)<<16) + (*(UBYTE *)(DeadSector+i+7)<<8) + *(UBYTE *)(DeadSector+i+8));
				ajoute(Firstwindow, text);
			}
		}
		else
			ajoute(Firstwindow, Messages(BOOT_30));
	}
} /* info_boot */

/********************************************************************
*																	*
*					Ecriture d'un boot (secteur 0)					*
*																	*
********************************************************************/
#ifndef TEST_VERSION
void ecrire_boot(void)
{
	char text[80];
	int devno, err;

	if (my_alert(2, FAIL, X_ICN_STOP, Messages(BOOT_17), Messages(BOOT_32)) == 1)
		return;

	devno = choix_unit();

	if (devno != FAIL)
	{
		sprintf(text, Messages(BOOT_1),
		 devno >= 24 ? devno - 24 : devno >= 16 ? devno-16 : devno >= 8 ? devno-8 : devno,
		 devno >= 24 ? "ZORG" : devno >= 16 ? "IDE" : devno >= 8 ? "SCSI" : "ACSI");
		ajoute(Firstwindow, text);

		if ((err = my_DMAwrite(0L, 1, Boot, devno)) != 0)
		{
			error_msg(err);
			return;
		}
		ajoute(Firstwindow, Messages(BOOT_18));

		if ((err = my_DMAwrite(*(ULONG *)(Boot+0x1f6), (int)*(ULONG *)(Boot+0x1fa), DeadSector, devno)) != 0)
		{
			error_msg(err);
			return;
		}
		ajoute(Firstwindow, Messages(BOOT_19));
	}
} /* ecrire_boot */
#endif

/********************************************************************
*																	*
*				chargement d'un boot … partir du disque				*
*																	*
********************************************************************/
void charger_boot(void)
{
	int handle;
	char nom[FILENAME_MAX], text[FILENAME_MAX], tmp[FILENAME_MAX];

	strcpy(nom, "BOOT.ZRG");

	if(!selecteur(nom, "*.ZRG", Messages(BOOT_20)))
		return;

	get_max_name(nom, tmp, MAX_TITLE, FALSE);

	sprintf(text, Messages(BOOT_21), nom);
	ajoute(Firstwindow, text);

	if ((handle = (int)Fopen(nom, FO_READ)) >= 0)
	{
		int compte;

		if (Boot == NULL)
			Boot = malloc(512L);
		if (DeadSector != NULL)
		{
			free(DeadSector);
			DeadSector = NULL;
		}

		if ((compte = (int)Fread(handle, 512L, Boot)) != 512)
		{
			sprintf(nom, Messages(BOOT_22), compte);
			ajoute(Firstwindow, nom);
		}

		if (MIN(*(ULONG *)(Boot+0x1fa)*512L, 10*512L))
		{
			DeadSector = malloc(MIN(*(ULONG *)(Boot+0x1fa)*512L, 10*512L));
			if ((compte = (int)Fread(handle, *(ULONG *)(Boot+0x1fa)*512L, DeadSector)) != *(ULONG *)(Boot+0x1fa)*512L)
			{
				sprintf(nom, Messages(BOOT_22), compte);
				ajoute(Firstwindow, nom);
			}
		}

		Fclose(handle);

		menu_ienable(Menu, SAUVER_BOOT, 1);
		menu_ienable(Menu, ECRIRE_BOOT, 1);

		if (my_alert(1, 2, X_ICN_QUESTION, Messages(23), Messages(BOOT_32)) == 0)
			info_boot();
	}
	else
	{
		sprintf(text, Messages(BOOT_24), nom);
		ajoute(Firstwindow, text);
	}
} /* charger_boot */

/********************************************************************
*																	*
*					sauvegarde d'un boot sur disque					*
*																	*
********************************************************************/
void sauver_boot(void)
{
	int handle;
	char nom[FILENAME_MAX], text[FILENAME_MAX], tmp[FILENAME_MAX];
	int err;

	strcpy(nom, "BOOT.ZRG");

	if(!selecteur(nom, "*.ZRG", Messages(BOOT_25)))
		return;

	get_max_name(nom, tmp, MAX_TITLE, FALSE);

	sprintf(text, Messages(BOOT_26), tmp);
	ajoute(Firstwindow, text);

	if ((handle = (int)Fcreate(nom, 0)) >= 0)
	{
		if ((err = (int)Fwrite(handle, 512L, Boot)) < 0)
			error_msg(err);

		if ((err = (int)Fwrite(handle, *(ULONG *)(Boot+0x1fa)*512L, DeadSector)) < 0)
			error_msg(err);

		Fclose(handle);
	}
	else
		ajoute(Firstwindow, Messages(BOOT_27));
} /* sauver_boot */
