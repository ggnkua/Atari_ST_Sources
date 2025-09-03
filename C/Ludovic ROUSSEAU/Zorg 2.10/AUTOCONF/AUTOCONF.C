#include <stdio.h>
#include <tos.h>
#include <stdlib.h>
#include <portab.h>
#include <string.h>

int		my_DMAread( long sector, int count, char *buffer, int devno );
int		hard_read( long debut, int nombre, char *buffer, int control );
void	traite( int unit, long secteur, int level );
void	traite_util( int unit, long secteur );
void	indent( int level );

#define TRUE 1
#define FALSE 0

int Partition = 0;	/* num‚ro de la partition en cours */

/********************************************************************
*																	*
*								main								*
*																	*
********************************************************************/
int main()
{
	char ligne[80];
	int device;
	int unit;

	puts("Automatic creation of the partitions table for ZORG.INF");
	puts("Realised by Ludovic Rousseau (Ludovic.Rousseau@cnam.cnam.fr), 27 November 1993");
	puts("Last update: " __DATE__ "\n");

	printf("Which Device [0:ASCI, 1:SCSI, 2:IDE, 3:ZORG] : ");
	gets(ligne);
	device = atoi(ligne);

	printf("Which Unit [0-7] : ");
	gets(ligne);
	unit = atoi(ligne);

	unit += device*8;

	printf("Verbose ? [y]");
	gets(ligne);

	if (ligne[0] == 'n')
	{
		printf("First partition of the disk [C:] : ");
		gets(ligne);

		if (ligne[0] == '\0')
			Partition = 2;
		else
			Partition = (ligne[0] | ('a'-'A')) - 'a';

		traite_util(unit, 0L);
	}
	else
		traite(unit, 0L, 0);

	Cconin();

	return 0;
} /* main */

/********************************************************************
*																	*
*				DMAread ou ma routine suivant devno					*
*																	*
********************************************************************/
int my_DMAread(sector, count, buffer, devno)
	long sector;
	int count;
	char *buffer;
	int devno;
{
	if (devno < 24)
	{
		if (DMAread(sector, count, buffer, devno))
			return 11;
	}
	else
		if (hard_read(sector, count, buffer, devno - 16))
			return 1;

	return 0;
} /* my_DMAread */

/********************************************************************
*																	*
*						Traite un boot sector						*
*																	*
********************************************************************/
void traite(unit, secteur, level)
	int unit;
	long secteur;
	int level;
{
	char buffer[512];

	if (my_DMAread(secteur, 1, buffer, unit))
	{
		printf("Error in reading sector %ld of Unit %d\n", secteur, unit);
		return;
	}

	if (*(UBYTE *)(buffer+0x1c6) & 1)
	{
		indent(level);
		puts(" Partition 0");

		indent(level);
		printf("  Identification : %c%c%c\n", *(UBYTE *)(buffer+0x1c7),  *(UBYTE *)(buffer+0x1c8),  *(UBYTE *)(buffer+0x1c9));
		indent(level);
		printf("  First sector of the partition : %ld (Real first sector : %ld)\n", *(ULONG *)(buffer+0x1ca), secteur+*(ULONG *)(buffer+0x1ca));
		indent(level);
		printf("  Size of the partition : %ld sectors, %ld bytes\n\n", *(ULONG *)(buffer+0x1ce), (*(ULONG *)(buffer+0x1ce))*512);

		if (memcmp(buffer+0x1c7, "XGM", 3) == 0)
			traite(unit, secteur + *(ULONG *)(buffer+0x1ca), level +1);
	}

	if (*(UBYTE *)(buffer+0x1d2) & 1)
	{
		indent(level);
		puts(" Partition 1");

		indent(level);
		printf("  Identification : %c%c%c\n", *(UBYTE *)(buffer+0x1d3),  *(UBYTE *)(buffer+0x1d4),  *(UBYTE *)(buffer+0x1d5));
		indent(level);
		printf("  First sector of the partition : %ld (Real first sector : %ld)\n", *(ULONG *)(buffer+0x1d6), secteur+*(ULONG *)(buffer+0x1d6));
		indent(level);
		printf("  Size of the partition : %ld sectors, %ld bytes\n\n", *(ULONG *)(buffer+0x1da), (*(ULONG *)(buffer+0x1da))*512);

		if (memcmp(buffer+0x1d3, "XGM", 3) == 0)
	/* on n'utilise pas le champ permier secteur mais la somme premier secteur de celle d'avant + taille */
	/* C'est un bug ? une feature de AHDI ? */
			traite(unit, secteur + *(ULONG *)(buffer+0x1ca) + *(ULONG *)(buffer+0x1ce), level+1);
	}

	if (*(UBYTE *)(buffer+0x1de) & 1)
	{
		indent(level);
		puts(" Partition 2");

		indent(level);
		printf("  Identification : %c%c%c\n", *(UBYTE *)(buffer+0x1df),  *(UBYTE *)(buffer+0x1e0),  *(UBYTE *)(buffer+0x1e1));
		indent(level);
		printf("  First sector of the partition : %ld (Real first sector : %ld)\n", *(ULONG *)(buffer+0x1e2), secteur+*(ULONG *)(buffer+0x1e2));
		indent(level);
		printf("  Size of the partition : %ld sectors, %ld bytes\n\n", *(ULONG *)(buffer+0x1e6), (*(ULONG *)(buffer+0x1e6))*512);

		if (memcmp(buffer+0x1df, "XGM", 3) == 0)
			traite(unit, secteur + *(ULONG *)(buffer+0x1e2), level+1);
	}

	if (*(UBYTE *)(buffer+0x1ea) & 1)
	{
		puts(" Partition 3");

		indent(level);
		printf("  Identification : %c%c%c\n", *(UBYTE *)(buffer+0x1eb),  *(UBYTE *)(buffer+0x1ec),  *(UBYTE *)(buffer+0x1ed));
		indent(level);
		printf("  First sector of the partition : %ld (Real first sector : %ld)\n", *(ULONG *)(buffer+0x1ee), secteur+*(ULONG *)(buffer+0x1ee));
		indent(level);
		printf("  Size of the partition : %ld sectors, %ld bytes\n\n", *(ULONG *)(buffer+0x1f2), (*(ULONG *)(buffer+0x1f2))*512);

		if (memcmp(buffer+0x1eb, "XGM", 3) == 0)
			traite(unit, secteur + *(ULONG *)(buffer+0x1ee), level+1);
	}
} /* traite */

/********************************************************************
*																	*
*						Traite un boot sector						*
*																	*
********************************************************************/
void traite_util(unit, secteur)
	int unit;
	long secteur;
{
	char buffer[512];

	if (my_DMAread(secteur, 1, buffer, unit))
	{
		printf("Error in reading sector %ld of Unit %d\n", secteur, unit);
		return;
	}

	if (*(UBYTE *)(buffer+0x1c6) & 1)
	{
		if (memcmp(buffer+0x1c7, "BGM", 3) == 0 || memcmp(buffer+0x1c7, "GEM", 3)== 0)
			printf("DEVICE %d %d %ld %ld\n", unit, Partition++, secteur+*(ULONG *)(buffer+0x1ca), *(ULONG *)(buffer+0x1ce));

		if (memcmp(buffer+0x1c7, "XGM", 3) == 0)
			traite_util(unit, secteur + *(ULONG *)(buffer+0x1ca));
	}

	if (*(UBYTE *)(buffer+0x1d2) & 1)
	{
		if (memcmp(buffer+0x1d3, "BGM", 3) == 0 || memcmp(buffer+0x1d3, "GEM", 3)== 0)
			printf("DEVICE %d %d %ld %ld\n", unit, Partition++, secteur+*(ULONG *)(buffer+0x1d6), *(ULONG *)(buffer+0x1da));

		if (memcmp(buffer+0x1d3, "XGM", 3) == 0)
	/* on n'utilise pas le champ permier secteur mais la somme premier secteur de celle d'avant + taille */
	/* C'est un bug ? une feature de AHDI ? */
			traite_util(unit, secteur + *(ULONG *)(buffer+0x1ca) + *(ULONG *)(buffer+0x1ce));
	}

	if (*(UBYTE *)(buffer+0x1de) & 1)
	{
		if (memcmp(buffer+0x1df, "BGM", 3) == 0 || memcmp(buffer+0x1df, "GEM", 3)== 0)
			printf("DEVICE %d %d %ld %ld\n", unit, Partition++, secteur+*(ULONG *)(buffer+0x1e2), *(ULONG *)(buffer+0x1e6));

		if (memcmp(buffer+0x1df, "XGM", 3) == 0)
			traite_util(unit, secteur + *(ULONG *)(buffer+0x1e2));
	}

	if (*(UBYTE *)(buffer+0x1ea) & 1)
	{
		if (memcmp(buffer+0x1eb, "BGM", 3) == 0 || memcmp(buffer+0x1eb, "GEM", 3)== 0)
			printf("DEVICE %d %d %ld %ld\n", unit, Partition++, secteur+*(ULONG *)(buffer+0x1ee), *(ULONG *)(buffer+0x1f2));

		if (memcmp(buffer+0x1eb, "XGM", 3) == 0)
			traite_util(unit, secteur + *(ULONG *)(buffer+0x1ee));
	}
} /* traite_util */

/********************************************************************
*																	*
*							indent le texte							*
*																	*
********************************************************************/
void indent(level)
	int level;
{
	for (; level; level--)
		Cconout('\t');
} /* indent */
