#include <tos.h>
#include "sd.h"

// Current speed: 20ko/s

extern uint32_t	GlobalProgramSize;

#define	mbr_boot_type_b				data[446+0]
#define	mbr_firstSector_l			data[446+8]
#define	mbr_totalSectors_l			data[446+12]
#define	mbr_magic_word_w			data[510]

#define	bpb_bytesPerSector_w		data[11]
#define	bpb_sectorsPerCluster_b		data[13]
#define	bpb_reservedSectorCount_w	data[14]
#define	bpb_fatCount_b				data[16]
#define	bpb_rootDirEntryCount_w		data[17]
#define	bpb_totalSectors16_w		data[19]
#define	bpb_mediaType_b				data[21]
#define	bpb_sectorsPerFat16_w		data[22]
#define	bpb_sectorsPerTrtack_w		data[24]
#define	bpb_headCount_w				data[26]
#define	bpb_totalSectors32_l		data[32]

#define	MAX_FAT16_CLUSTERS			65524
#define	MAX_FAT12_CLUSTERS			4084

typedef struct
{
	uint16_t	recsiz;       // sector size in bytes
	uint16_t	clsiz;        // cluster size in sectors
	uint16_t	clsizb;       // cluster size in bytes
	uint16_t	rdlen;        // root directory length in records
	uint16_t	fsiz;         // FAT size in records
	uint16_t	fatrec;       // first FAT record (of last FAT)
	uint16_t	datrec;       // first data record
	uint16_t	numcl;        // number of data clusters available
	uint16_t	b_flags;      // flags (see below)
}	tTosBPB;

tTosBPB	tos_bpb;

uint8_t 	data[512];
VOIDP		sstack;
uint32_t	sd_first_sector;

char		hexstr[] = "    \r\n";

uint16_t	LE_2_BE_W(__reg("a0") void *dataptr);
uint32_t	LE_2_BE_L(__reg("a0") void *dataptr);
void		HookupXbiosVectors(void);
void		WaitDemo(void);
void		Hex16ToASCII(__reg("d0") uint16_t hexnum, __reg("a0") void *str);

uint16_t	divu_lw(__reg("d0") uint32_t a, __reg("d1") uint16_t b) = "\t divu d1,d0\n";
uint16_t	mulu_ww(__reg("d0") uint16_t a, __reg("d1") uint16_t b) = "\t mulu d1,d0\n";


int		main(void)
{
	char	*err;

	sstack = Super(NULL);
	Cconws("\r\n\33pSD Card on Extended Joystick Port A\33q\r\nOriginal Idea and Help by Zerosquare\r\nDriver by Orion_ [2020]\r\nSD Init: ");
	err = SD_Init();
	if (!err)
	{
		sd_first_sector = 0;
		Cconws("OK\r\nReading MBR: ");
		SD_ReadData(sd_first_sector, data);	// Read MBR
		sd_first_sector = LE_2_BE_L(&mbr_firstSector_l);
		if ((LE_2_BE_W(&mbr_magic_word_w) == 0xAA55) && (!(mbr_boot_type_b & 0x7F)) && (sd_first_sector != 0) && (LE_2_BE_L(&mbr_totalSectors_l) >= 100))
		{
			Cconws("OK");
			SD_ReadData(sd_first_sector, data);	// Read Boot Sector
		}
		else
			Cconws("Error");

		Cconws("\r\nReading BPB: ");
		if ((LE_2_BE_W(&mbr_magic_word_w) == 0xAA55) && (LE_2_BE_W(&bpb_bytesPerSector_w) == 512) && (bpb_fatCount_b != 0) && (bpb_sectorsPerCluster_b != 0) && (LE_2_BE_W(&bpb_reservedSectorCount_w) != 0))
		{
			uint32_t	tmp;

			tos_bpb.recsiz = LE_2_BE_W(&bpb_bytesPerSector_w);	// sector size in bytes
			tos_bpb.clsiz = bpb_sectorsPerCluster_b;			// cluster size in sectors
			tos_bpb.clsizb = mulu_ww(tos_bpb.recsiz, tos_bpb.clsiz);					// cluster size in bytes
			tos_bpb.rdlen = divu_lw(((LE_2_BE_W(&bpb_rootDirEntryCount_w) * 32) + (tos_bpb.recsiz - 1)), tos_bpb.recsiz);        // root directory length in records
			tos_bpb.fsiz = LE_2_BE_W(&bpb_sectorsPerFat16_w);         // FAT size in records
			tos_bpb.fatrec = LE_2_BE_W(&bpb_reservedSectorCount_w) + tos_bpb.fsiz;       // first FAT record (of last FAT)
			tos_bpb.datrec = tos_bpb.fatrec + tos_bpb.fsiz + tos_bpb.rdlen;       // first data record
			tmp = LE_2_BE_W(&bpb_totalSectors16_w);
			if (!tmp)
				tmp = LE_2_BE_L(&bpb_totalSectors32_l);
			tmp = divu_lw(tmp - tos_bpb.datrec, bpb_sectorsPerCluster_b);	// TODO divu long
			if (tmp > MAX_FAT16_CLUSTERS)
			{
				Cconws("Error: Not FAT16\r\n");
				goto fail;
			}
			tos_bpb.numcl = tmp;        // number of data clusters available
			if (tos_bpb.numcl > MAX_FAT12_CLUSTERS)
			{
				tos_bpb.b_flags = 1;
				Cconws("FAT16\r\n");
			}
			else
			{
				tos_bpb.b_flags = 0;
				Cconws("FAT12\r\n");
			}

			Cconws("Hooking Up Xbios Vectors\r\n");
			HookupXbiosVectors();
			Super(sstack);
			Ptermres(GlobalProgramSize, 0);	// Keep the program in memory (TSR)
		}
		else
			Cconws("Error\r\n");
	}
	else
		Cconws(err);
fail:
	WaitDemo();
	Super(sstack);
	Pterm(0);
	return (0);
}
