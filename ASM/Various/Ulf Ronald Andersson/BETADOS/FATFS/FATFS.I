;----------------------------------------------------------------------------
; File name:	RA_VFAT.I			Revision date:	2000.07.20
; Created by:	Ulf Ronald Andersson		Creation date:	2000.07.20
;----------------------------------------------------------------------------
; Purpose:
;	define structs and constants for access on VFAT filesystems
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_VFAT_defined
RA_VFAT_defined	set	1
;----------------------------------------------------------------------------
;	macro to reverse byte order	(needed for all data from disk)
;-------------------------------------
re_byte	MACRO	dreg
rev__ex	set	'\0'
	IFNE	(rev__ex>'Z')
rev__ex	set	rev__ex-32
	ENDC
	IFNE	(rev__ex='W')
	ror	#8,\1
	ENDC
	IFNE	(ref__ex='L')
	ror	#8,\1
	swap	\1
	ror	#8,\1
	ENDC
	ENDM
;----------------------------------------------------------------------------
;	FAT16 boot sector header:	(Also used for FAT12)
;-------------------------------------
	struct	F16_BSHD
	uint8	boot_jump[3];	;Boot strap short or near jump
	char	system_id[8];	;Name - can be used to special case partition manager volumes
;-------
	uint8	sector_size[2];	;bytes per logical sector
	uint8	cluster_size;	;sectors/cluster
	uint16	reserved;	;reserved sectors
	uint8	fats;		;number of FATs
	uint8	dir_entries[2];	;root directory entries
	uint8	sectors[2];	;number of sectors
	uint8	media;		;media code (unused)
	uint16	fat_length;	;sectors/FAT
	uint16	secs_track;	;sectors per track
	uint16	heads;		;number of heads
	uint32	hidden;		;hidden sectors (unused)
	uint32	total_sect;	;number of sectors (if sectors == 0)
	d_end	F16_BSHD
;----------------------------------------------------------------------------
;	FAT32 boot sector header:
;-------------------------------------
	struct	F32_BSHD
	s_struc	F32_fbs,F16_BSHD	;normal FAT boot sector
	uint32	fat32_length;		;sectors/FAT
;-------
	uint16	flags;			;bit 8: fat mirroring, low 4: active fat
FAT32_ActiveFAT_Mask	= $0f
FAT32_NoFAT_Mirror	= $80
;-------
	uint16	version;		;major, minor filesystem version
	uint32	root_cluster;		;first cluster in root directory
	uint16	info_sector;		;filesystem info sector
;-------
	uint16	backup_boot;		;backup boot sector
INVALID_SECTOR		= $ffff
;-------
	uint16	RESERVED2[6];		;Unused
	d_end	F32_BSHD
;----------------------------------------------------------------------------
;	FAT32 boot sector tail:		(at offset 480 from boot sector start)
;-------------------------------------
F32_BFSINFO_OFF	= 480		;offset from the beginning
;-------
	struct	F32_BFSINFO
	uint32	reserved1;	;Nothing as far as I can tell
;-------
	uint32	signature;	;0x61417272L
FAT32_FSINFOSIG	= 'aArr'
;-------
	uint32	free_clusters;	;Free cluster count.  -1 if unknown
	uint32	next_cluster;	;Most recently allocated cluster. Unused under Linux.
	uint32	reserved2[4];
	d_end	F32_BFSINFO
;----------------------------------------------------------------------------
;	FAT volume info:		(Used internally by MiNT)
;-------------------------------------
	struct	FAT_VI
	uint8	drive_number;	;BIOS drive number
	uint8	RESERVED;	;Unused
;-------
	uint8	ext_boot_sign;	;0x29 if fields below exist (DOS 3.3+)
EXT_INFO	= $29
;-------
	uint8	vol_id[4];	;Volume ID number
	char	vol_label[11];	;Volume label
	char	fs_type[8];	;Typically FAT12, FAT16, or FAT32
	d_end	FAT_VI
;----------------------------------------------------------------------------
	endc	;RA_VFAT_defined
;----------------------------------------------------------------------------
;End of file:	RA_VFAT.I
;----------------------------------------------------------------------------
