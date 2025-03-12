
; Bios Parameter Block Structure

			rsreset
BPB_SecSize		rs.w	1
BPB_SecsPerClust	rs.w	1
BPB_ClustSize		rs.w	1
BPB_RootDirSecs		rs.w	1
BPB_FATSecs		rs.w	1
BPB_FAT2Start		rs.w	1
BPB_DataStart		rs.w	1
BPB_DataClust		rs.w	1
BPB_Flags		rs.w	1

; Flag structure in BPB_Flags

			rsreset
BPBF_16BitFAT		rs.b	1

; FAT entry codes (note that some are ranges)

FAT_Free	= 0
FAT_Invalid	= 1
FAT_FirstValid	= 2
FAT_Bad1	= $fff0
FAT_Bad2	= $fff7
FAT_EOF1	= $fff8
FAT_EOF2	= $ffff

; Mask to convert our entry codes to work with 12 bit FAT entries

FAT_Mask12	= $fff

; Macro to convert a cluster number to a logical sector
; Result returned in d0

FS_LogicalSector	macro Cluster,SecsPerCluster
	move.w	\1,d0
	subq.w	#FAT_FirstValid,d0
	mulu	\2,d0
	endm

