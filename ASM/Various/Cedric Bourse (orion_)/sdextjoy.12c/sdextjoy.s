;
; SD card driver for Atari STe extended Joystick Port A
;
; by Orion_ April / May / August / September 2020
;
; Extended Joystick Port: Computer Side
;    _______________________________
;    \   5   4    3    2    1      /
;     \     10   9    8    7   6  /
;      \ 15  14   13  12   11    /
;       \_______________________/
;
; 4 - MOSI
; 3 - SCK
; 2 - CS
; 6 - MISO
; 7 - VCC
; 9 - GND

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;========================================>

JOY_ADRS_OUTPUT		equ	$FF9202
JOY_SPI_CS_HIGH		equ	%1111111111111100
JOY_SPI_CS_LOW		equ	%1111111111111000
JOY_SPI_SCK_HIGH	equ	%0000000000000010
JOY_SPI_SCK_LOW		equ	%0000000000000000
JOY_SPI_DATA_1		equ	%0000000000000001	; MOSI must be bit 0 for the routine to work
JOY_SPI_DATA_0		equ	%0000000000000000

JOY_ADRS_INPUT_b	equ	$FF9201
JOY_SPI_MISO_BIT	equ	0

tos_bpb_recsiz		equ	0	; sector size in bytes
tos_bpb_clsiz		equ	2	; cluster size in sectors
tos_bpb_clsizb		equ	4	; cluster size in bytes
tos_bpb_rdlen		equ	6	; root directory length in records
tos_bpb_fsiz		equ	8	; FAT size in records
tos_bpb_fatrec		equ	10	; first FAT record (of last FAT)
tos_bpb_datrec		equ	12	; first data record
tos_bpb_numcl		equ	14	; number of data clusters available
tos_bpb_b_flags		equ	16	; flags (see below)

mbr_partition_offset		equ	446
mbr_partition_next		equ	16
mbr_n_partitions		equ	4

mbr_boot_type_b			equ	0
mbr_firstSector_l		equ	8
mbr_totalSectors_l		equ	12

mbr_magic_word_w		equ	510

bpb_bytesPerSector_w		equ	11
bpb_sectorsPerCluster_b		equ	13
bpb_reservedSectorCount_w	equ	14
bpb_fatCount_b			equ	16
bpb_rootDirEntryCount_w		equ	17
bpb_totalSectors16_w		equ	19
bpb_mediaType_b			equ	21
bpb_sectorsPerFat16_w		equ	22
bpb_sectorsPerTrtack_w		equ	24
bpb_headCount_w			equ	26
bpb_totalSectors32_l		equ	32
bpb_size			equ	9
bpb_size_b			equ	(bpb_size*2)

MAX_FAT16_CLUSTERS		equ	65524
MAX_FAT12_CLUSTERS		equ	4084

DATA_RES_MASK			equ	$1F
DATA_RES_ACCEPTED		equ	$05

INSTALL_MARKER			equ	$CEDBCEDB

;========================================>
;
; Program Init
;

	section	text

	move.l	4(a7),a0	; basepage address
	move.l	24(a0),a1	; bss ptr
	adda.l	28(a0),a1	; bss size
;	adda.l	#2048,a1	; internal stack size
;	move.l	a1,a7		; setup our internal stack
	suba.l	a0,a1		; global size of our program

	move.l	a1,GlobalProgramSize	; for later Ptermres

;	move.l	a1,-(a7)	; program size
;	move.l	a0,-(a7)	; start ptr
;	clr.w	-(a7)
;	move.w	#$4A,-(a7)	; Mshrink
;	trap	#1
;	lea	12(a7),a7

;========================================>
;
; Main Start
;

	lea	MsgInit,a0
	bsr	PrintMsg

	clr.l	-(a7)		; Supervisor Mode
	move.w	#$20,-(a7)	; Super(NULL);
	trap	#1
	addq.l	#6,a7
	move.l	d0,sstack

	move.l	$472.w,a0	; hdv_bpb
	cmpi.l	#INSTALL_MARKER,-10(a0)
	bne.s	.notInstalled

	lea	MsgAlreadyInstalled,a0
	bra	.fail

.notInstalled:
	bsr	SD_Init
	tst.b	d0
	bne	.ERRfail

	lea	MsgOK,a0
	bsr	PrintMsg
	lea	MsgMBR,a0
	bsr	PrintMsg

	clr.l	sd_good_partition		; Clear All Good Partition

	moveq	#0,d0				; Read MBR
	move.l	d0,sd_first_sector
	moveq	#1,d1
	lea	data,a0
	bsr	SD_ReadData

	lea	data,a1
	lea	mbr_magic_word_w(a1),a0
	bsr	LE_2_BE_W
	cmpi.w	#$AA55,d0			; Check MBR Signature
	bne	.MBRfail

	lea	mbr_partition_offset(a1),a1	; Partitions table
	lea	sd_first_sector,a2
	moveq	#0,d2				; Sectors Sum
	moveq	#mbr_n_partitions-1,d1
.checkPartition:
	clr.l	(a2)				; Clear sd_first_sector

	lea	mbr_totalSectors_l(a1),a0
	bsr	LE_2_BE_L
	cmpi.l	#100,d0				; totalSectors must be >= 100
	blt.s	.partfail

	move.b	mbr_boot_type_b(a1),d0
	andi.b	#$7F,d0				; partition boot type & $7F == 0
	bne.s	.partfail

	lea	mbr_firstSector_l(a1),a0
	bsr	LE_2_BE_L
	move.l	d0,(a2)				; Store in sd_first_sector
	add.l	d0,d2				; Sum up sectors, so we can check that we have at least one partition valid

.partfail:
	addq.l	#4,a2				; Next sd_first_sector
	lea	mbr_partition_next(a1),a1	; Next Partition
	dbra	d1,.checkPartition

	tst.l	d2				; BPB sector must not be 0 (we need at least one partition valid)
	beq.s	.MBRfail

	lea	MsgOK,a0
	bsr	PrintMsg

	lea	sd_first_sector,a3
	lea	tos_bpb,a4		; Fill TOS BPB while checking DOS BPB
	lea	sd_good_partition,a5
	moveq	#0,d6
	moveq	#mbr_n_partitions-1,d7
.readBPBs:
	move.l	(a3)+,d0		; sd_first_sector
	beq.s	.nextPart
	moveq	#1,d1			; read one sector
	lea	data,a0
	bsr	SD_ReadData		; Read BPB
	bsr.s	CheckBPB
	add.b	d0,d6			; Add Good return
	move.b	d0,(a5)			; Store Good Partition
.nextPart:
	addq.l	#1,a5
	lea	bpb_size_b(a4),a4	; next tos_bpb structure
	dbra	d7,.readBPBs

	tst.b	d6			; Any Good partition ?
	beq.s	.ERRfail
	bra.s	.ProcessHook

.MBRfail:
	lea	MsgErr,a0
	bsr	PrintMsg

	; Check only one partition without MBR

	lea	tos_bpb,a4		; Fill TOS BPB while checking DOS BPB
	bsr.s	CheckBPB
	tst.b	d0
	beq.s	.ERRfail

	move.b	#1,sd_good_partition	; At least first is good (without MBR, first sector = 0)

.ProcessHook:
	lea	MsgHook,a0
	bsr	PrintMsg
	bsr	HookupXbiosVectors

	; Restore User Mode
	move.l	sstack,-(a7)
	move.w	#$20,-(a7)		; Super(sstack);
	trap	#1
	addq.l	#6,a7

	clr.w	-(a7)			; Keep Driver in Memory
	move.l	GlobalProgramSize,-(a7)	; Ptermres
	move.w	#$31,-(a7)
	trap	#1

.ERRfail:
	lea	MsgErr,a0
.fail:	bsr	PrintMsg

	; Restore User Mode
	move.l	sstack,-(a7)
	move.w	#$20,-(a7)	; Super(sstack);
	trap	#1
	addq.l	#6,a7

	clr.w	-(a7)		; Pterm0
	trap	#1

;-------------------------------

CheckBPB:			; a4 = tos_bpb stucture to fill
	lea	MsgBPB,a0
	bsr	PrintMsg

	lea	data,a1
	move.l	a4,a2	; tos_bpb

	lea	mbr_magic_word_w(a1),a0
	bsr	LE_2_BE_W
	cmpi.w	#$AA55,d0	; Check BPB Signature
	bne	.BPBfail

	move.b	bpb_fatCount_b(a1),d0
	beq	.BPBfail	; must not be 0

	lea	bpb_bytesPerSector_w(a1),a0
	bsr	LE_2_BE_W
	cmpi.w	#512,d0		; bytesPerSector must be = 512
	bne	.BPBfail
	move.w	d0,(a2)+	; tos_bpb.recsiz = sector size in bytes

	moveq	#0,d3
	move.b	bpb_sectorsPerCluster_b(a1),d3
	beq	.BPBfail	; must not be 0
	move.w	d3,(a2)+	; tos_bpb.clsiz = cluster size in sectors

	move.w	d3,d1
	mulu.w	d0,d1		; tos_bpb.recsiz * tos_bpb.clsiz
	move.w	d1,(a2)+	; -> tos_bpb.clsizb = cluster size in bytes

	move.w	d0,d1
	moveq	#0,d0
	lea	bpb_rootDirEntryCount_w(a1),a0
	bsr	LE_2_BE_W
	lsl.l	#5,d0		; LE_2_BE_W(&bpb_rootDirEntryCount_w) * 32
	addi.l	#511,d0		; (tos_bpb.recsiz - 1)
	divu.w	d1,d0		; / tos_bpb.recsiz
	move.w	d0,(a2)+	; -> tos_bpb.rdlen = root directory length in records
	move.w	d0,d2

	lea	bpb_sectorsPerFat16_w(a1),a0
	bsr	LE_2_BE_W
	move.w	d0,(a2)+	; tos_bpb.fsiz = FAT size in records
	move.w	d0,d1

	lea	bpb_reservedSectorCount_w(a1),a0
	bsr	LE_2_BE_W
	tst.w	d0
	beq	.BPBfail	; must not be 0
	add.w	d1,d0		; + tos_bpb.fsiz
	move.w	d0,(a2)+	; -> tos_bpb.fatrec = first FAT record (of last FAT)

	add.w	d0,d1		; tos_bpb.fatrec + tos_bpb.fsiz
	add.w	d2,d1		; + tos_bpb.rdlen
	move.w	d1,(a2)+	; -> tos_bpb.datrec = first data record

	moveq	#0,d0
	lea	bpb_totalSectors16_w(a1),a0
	bsr	LE_2_BE_W
	tst.w	d0
	bne.s	.tsect16
	lea	bpb_totalSectors32_l(a1),a0
	bsr	LE_2_BE_L
.tsect16:
	ext.l	d1
	sub.l	d1,d0		; - tos_bpb.datrec
	move.w	d3,d1		; bpb_sectorsPerCluster_b
	bsr	DivU32ByPowerOfTwo

	cmpi.l	#MAX_FAT16_CLUSTERS,d0
	ble.s	.checkFAT16

	; FAT32
	lea	MsgF32,a0
	bra.s	.fail

.checkFAT16:
	move.w	d0,(a2)+	; tos_bpb.numcl = number of data clusters available
	lea	MsgF16,a0
	moveq	#1,d1		; FAT16: b_flags = 1
	cmpi.l	#MAX_FAT12_CLUSTERS,d0
	bgt.s	.FAT16
	lea	MsgF12,a0
	moveq	#0,d1		; FAT12: b_flags = 0
.FAT16:	move.w	d1,(a2)		; tos_bpb.b_flags
	bsr	PrintMsg

	moveq	#1,d0
	rts

.BPBfail:
	lea	MsgErr,a0
.fail:	bsr	PrintMsg

	moveq	#0,d0
	rts

;---------------------------------------------

;========================================>
;
; SD SPI bit bang routines
;

spi_initialise:
spi_cs_high:
	move.w	#JOY_SPI_CS_HIGH,d0
	move.w	d0,spi_status
	or.w	#JOY_SPI_SCK_LOW|JOY_SPI_DATA_1,d0
	move.w	d0,JOY_ADRS_OUTPUT
	rts

spi_cs_low:
	move.w	#JOY_SPI_CS_LOW,d0
	move.w	d0,spi_status
	or.w	#JOY_SPI_SCK_LOW|JOY_SPI_DATA_1,d0
	move.w	d0,JOY_ADRS_OUTPUT
	rts

;========================================>

spi_send_buffer:		; a0 = data, d0 = length
	subq.w	#1,d0		; dbra
	bpl.s	.ok
	rts
.ok:
	move.w	d3,-(a7)
	move.w	d4,-(a7)

	lea	JOY_ADRS_OUTPUT,a1

	move.w	spi_status,d1
	lsr.w	#1,d1		; preshift data for later roxl.w #1,dN
	move.w	#JOY_SPI_SCK_HIGH,d2

.nextbyte:
	move.b	(a0)+,d4	; Get byte to send from buffer
	roxl.b	#1,d4		; 8 Shift the Data Byte MSB in X flag

				; Stable 200khz loop (68k @ 8mhz)
	REPT	8
	move.w	d1,d3		; 4 CS status with SCK LOW and DATA LOW (preshifted)
	roxl.w	#1,d3		; 8 Shift in the X flag in MOSI
	move.w	d3,(a1)		; 8 Send Data with SCK LOW
	or.w	d2,d3		; 4 Add SCK HIGH
	roxl.b	#1,d4		; 8 Shift the Data Byte MSB in X flag
	move.w	d3,(a1)		; 8 Send Data with SCK HIGH
	ENDR
	dbra	d0,.nextbyte

	add.w	d1,d1		; shift back spi_status
	ori.w	#JOY_SPI_DATA_1,d1
	move.w	d1,(a1)		; SCK LOW / 1

	move.w	(a7)+,d4
	move.w	(a7)+,d3
	rts

;========================================>

spi_recv_byte:
	moveq	#0,d0

	lea	JOY_ADRS_OUTPUT,a0
	lea	JOY_ADRS_INPUT_b,a1
	lea	ReverseByteTable,a2

	move.w	spi_status,d1
	move.w	d1,d2
	or.w	#JOY_SPI_SCK_HIGH|JOY_SPI_DATA_1,d1
	or.w	#JOY_SPI_SCK_LOW|JOY_SPI_DATA_1,d2

	REPT	8
	move.w	d1,(a0)			; SCK HIGH
	move.b	(a1),d0			; Get bit
	move.w	d2,(a0)			; SCK LOW
	ror.w	#1,d0			; store in MSB (reversed !)
	ENDR
	lsr.w	#8,d0			; get byte in LSB
	move.b	(a2,d0.w),d0		; table to reverse the byte from LSB -> MSB to MSB -> LSB
	rts

;========================================>

spi_fast_recv_block:		; a0 = buffer
	lea	JOY_ADRS_OUTPUT,a1
	lea	JOY_ADRS_INPUT_b,a2
	lea	ReverseByteTable,a3

	move.w	spi_status,d1
	move.w	d1,d2
	or.w	#JOY_SPI_SCK_HIGH|JOY_SPI_DATA_1,d1
	or.w	#JOY_SPI_SCK_LOW|JOY_SPI_DATA_1,d2

.nextblock:
	moveq	#0,d4		; retry count
.retry:
	REPT	8
	move.w	d1,(a1)		; 8 SCK HIGH : 250khz with 68k @ 8mhz
	move.b	(a2),d3		; 8 Get data bit
	move.w	d2,(a1)		; 8 SCK LOW
	ror.w	#1,d3		; 8 store in LSB -> MSB order
	ENDR

	lsr.w	#8,d3		; 22 Get the byte
	cmpi.b	#$FF,d3		; 10 SD Busy
	bne.s	.notbusy	; 12/8
	addq.b	#1,d4
	bne.s	.retry
.notbusy:
	cmpi.b	#$7F,d3		; 8  DATA_START_BLOCK ($FE bit reversed = $7F)
	bne	.out		; 12

	move.w	#512-1,d4	; 8 One block of 512 bytes
.nextbyte:
	REPT	8
	move.w	d1,(a1)		; 8 SCK HIGH
	move.b	(a2),d3		; 8 Get data bit
	move.w	d2,(a1)		; 8 SCK LOW
	ror.w	#1,d3		; 8 store in LSB -> MSB order
	ENDR

	lsr.w	#8,d3		; 22 Get the byte
	move.b	(a3,d3.w),(a0)+	; 18 Table to reverse the byte from LSB -> MSB to MSB -> LSB

	dbra	d4,.nextbyte	; 12/16 We lose 1kb/s with this dbra, but we gain 35kb of unrolled code

				; Skip CRC : Warning 500khz (68k @ 8mhz)
	REPT	8*2
	move.w	d1,(a1)		; 8 SCK HIGH
	move.w	d2,(a1)		; 8 SCK LOW
	ENDR

	moveq	#0,d0
	rts

.out:	moveq	#-1,d0
	rts

;========================================>
;
; SD Protocol Routines
;

;========================================>

SD_waitNotBusy:
	movem.l	d0-d3/a0-a2,-(a7)
	move.w	#$2000,d3
.retry:	bsr	spi_recv_byte
	cmpi.b	#$FF,d0
	beq.s	.ok
	dbra	d3,.retry
	movem.l	(a7)+,d0-d3/a0-a2
	move.w	#4,CCR		; Zflag = 1 / Error: Timeout
	rts
.ok:	movem.l	(a7)+,d0-d3/a0-a2
;	move.w	#0,CCR		; Zflag = 0 / OK
	rts

;========================================>

SD_cardCommand:
	bsr	SD_waitNotBusy
	bsr	spi_send_buffer
	moveq	#0,d3		; Retry counter
.retry:	bsr	spi_recv_byte
	btst	#7,d0
	beq.s	.ok
	addq.b	#1,d3
	bne.s	.retry
.ok:	rts

;========================================>

SD_ReadData:	; d0 = sector, d1 = nsectors, a0 = dest
	move.w	#$2700,SR	; no Interrupts during transfer
	movem.l	d3-d6/a3-a4,-(a7)

	move.l	a0,a4		; save dest buffer
	move.w	d1,d5		; save nsectors

	move.b	sd_type,d2
	cmpi.b	#3,d2		; SD_CARD_TYPE_SDHC
	beq.s	.SDHC
	lsl.l	#8,d0
	add.l	d0,d0		; sector * 512 bytes per sector
.SDHC:
	move.l	d0,d2		; save sector in d2
	move.l	d0,d6
	bsr	spi_cs_low

.nextblockk:
	move.l	d6,d2

	moveq	#6,d0
	lea	CMD_READ_SINGLE_BLOCK,a0
.single:
	lea	5(a0),a1	; put 32bits sector in CMD argument
	move.b	d2,-(a1)
	lsr.w	#8,d2
	move.b	d2,-(a1)
	swap	d2
	move.b	d2,-(a1)
	lsr.w	#8,d2
	move.b	d2,-(a1)

	bsr	SD_cardCommand
	tst.b	d0
	bne.s	.fail

	move.l	a4,a0			; restore dest buffer
	bsr	spi_fast_recv_block	; destroy d0-d4/a0-a3
	tst.b	d0
	bne.s	.fail

	lea	512(a4),a4
;	addi.l	#512,d6
	addq.l	#1,d6			; SDHC Patch by umatthe
	move.b	sd_type,d2
	cmpi.b	#3,d2			; SD_CARD_TYPE_SDHC
	beq.s	.SDHC1
	addi.l	#511,d6
.SDHC1:

	subq.w	#1,d5
	bne.s	.nextblockk

.nstop:
	bsr	spi_cs_high
	moveq	#0,d0		; E_OK
	movem.l	(a7)+,d3-d6/a3-a4
	move.w	#$2300,SR	; restore Interrupts
	rts
.fail:
	bsr	spi_cs_high
	moveq	#-1,d0		; ERR
	movem.l	(a7)+,d3-d6/a3-a4
	move.w	#$2300,SR	; restore Interrupts
	rts

;========================================>

SD_WriteData:	; d0 = sector, d1 = nsectors, a0 = src
	move.w	#$2700,SR	; no Interrupts during transfer
	movem.l	d3-d6/a3-a4,-(a7)

	move.l	a0,a4		; save src buffer
	move.w	d1,d5		; save nsectors

	move.b	sd_type,d2
	cmpi.b	#3,d2		; SD_CARD_TYPE_SDHC
	beq.s	.SDHC
	lsl.l	#8,d0
	add.l	d0,d0		; sector * 512 bytes per sector
.SDHC:
	move.l	d0,d2		; save sector in d2
	move.l	d0,d6
	bsr	spi_cs_low

.nextblockk:
	move.l	d6,d2

	moveq	#6,d0
	lea	CMD_WRITE_BLOCK,a0
.single:
	lea	5(a0),a1	; put 32bits sector in CMD argument
	move.b	d2,-(a1)
	lsr.w	#8,d2
	move.b	d2,-(a1)
	swap	d2
	move.b	d2,-(a1)
	lsr.w	#8,d2
	move.b	d2,-(a1)

	bsr	SD_cardCommand
	tst.b	d0
	bne.s	.fail

	lea	WRITE_DATA_START,a0
	moveq	#1,d0
	bsr	spi_send_buffer

	move.l	a4,a0			; restore src buffer
	move.w	#512+2,d0		; send one block + Dummy CRC
	bsr	spi_send_buffer		; destroy d0-d4/a0-a3

	bsr	spi_recv_byte
	andi.b	#DATA_RES_MASK,d0
	cmpi.b	#DATA_RES_ACCEPTED,d0
	bne.s	.fail

	lea	512(a4),a4
;	addi.l	#512,d6
	addq.l	#1,d6			; SDHC Patch by umatthe
	move.b	sd_type,d2
	cmpi.b	#3,d2			; SD_CARD_TYPE_SDHC
	beq.s	.SDHC1
	addi.l	#511,d6
.SDHC1:
	subq.w	#1,d5
	bne.s	.nextblockk

.nstop:
	bsr	spi_cs_high
	moveq	#0,d0		; E_OK
	movem.l	(a7)+,d3-d6/a3-a4
	move.w	#$2300,SR	; restore Interrupts
	rts
.fail:
	bsr	spi_cs_high
	moveq	#-1,d0		; ERR
	movem.l	(a7)+,d3-d6/a3-a4
	move.w	#$2300,SR	; restore Interrupts
	rts

;========================================>

SD_Init:
	move.w	#$2700,SR	; no Interrupts during transfer
	move.l	d3,-(a7)
	move.l	d4,-(a7)

	bsr	spi_initialise		; CS High
	lea	CMD_INIT,a0
	moveq	#10,d0			; 80 clock cycles with CS high.
	bsr	spi_send_buffer
	bsr	spi_cs_low

	moveq	#127,d4			; Retry counter
.retry:	moveq	#6,d0
	lea	CMD_GO_IDLE_STATE,a0
	bsr	SD_cardCommand
	cmpi.b	#1,d0			; R1_IDLE_STATE
	beq.s	.ok
	subq.b	#1,d4
	bne.s	.retry
	bra	.error
.ok:
	move.b	#1,sd_type		; default SD_CARD_TYPE_SD1
	clr.b	ACMD_SD_SEND_OP_COND+1	; arg = $00000000 for SD_CARD_TYPE_SD1
	moveq	#6,d0
	lea	CMD_SEND_IF_COND,a0
	bsr	SD_cardCommand
	btst	#2,d0			; R1_ILLEGAL_COMMAND
	bne.s	.sd_type
.sd_type2:
	move.b	#2,sd_type		; SD_CARD_TYPE_SD2
	move.b	#$40,ACMD_SD_SEND_OP_COND+1	; arg = $40000000 for SD_CARD_TYPE_SD2
	bsr	spi_recv_byte
	bsr	spi_recv_byte
	bsr	spi_recv_byte
	bsr	spi_recv_byte
	cmpi.b	#$AA,d0
	bne.s	.error
.sd_type:

	moveq	#127,d4			; Retry counter
.Aretry:
	moveq	#6,d0
	lea	CMD_APP_CMD,a0		; SD_cardAcmd
	bsr	SD_cardCommand
	moveq	#6,d0
	lea	ACMD_SD_SEND_OP_COND,a0
	bsr	SD_cardCommand
	tst.b	d0			; R1_READY_STATE
	beq.s	.Aok
	subq.b	#1,d4
	bne.s	.Aretry
	bra.s	.error
.Aok:

	move.b	sd_type,d0
	cmpi.b	#2,d0			; SD_CARD_TYPE_SD2
	bne.s	.noOCR

	moveq	#6,d0
	lea	CMD_READ_OCR,a0
	bsr	SD_cardCommand
	tst.b	d0
	bne.s	.error
	bsr	spi_recv_byte
	move.b	#$C0,d1
	and.b	d1,d0
	cmp.b	d1,d0
	bne.s	.noSDHC
	addq.b	#1,sd_type		; SD_CARD_TYPE_SDHC
.noSDHC:
	bsr	spi_recv_byte
	bsr	spi_recv_byte
	bsr	spi_recv_byte
.noOCR:
	bsr	spi_cs_high
	moveq	#0,d0
	move.l	(a7)+,d3
	move.l	(a7)+,d4
	move.w	#$2300,SR	; restore Interrupts
	rts
.error:
	bsr	spi_cs_high
	moveq	#1,d0
	move.l	(a7)+,d3
	move.l	(a7)+,d4
	move.w	#$2300,SR	; restore Interrupts
	rts

;========================================>
;
; Xbios harddrive routines hook for SD card
;

HookupXbiosVectors:
	lea	sd_drive,a0
	lea	sd_good_partition,a1

	move.l	$4C2.w,d0		; Get _drvbits
	moveq	#2,d1			; start from drive C
	moveq	#mbr_n_partitions-1,d2
.next_part:
	tst.b	(a1)+			; Good partition ?
	bne.s	.next_drive
	clr.w	(a0)+			; No ? then clear drive number
	bra.s	.nxt
.next_drive:
	btst.l	d1,d0			; test drive bit
	beq.s	.drive_available
	addq.b	#1,d1			; try next drive bit
	bra.s	.next_drive
.drive_available:
	move.w	d1,(a0)+		; Save drive number
	bset.l	d1,d0			; Set new drive bit
.nxt:	dbra	d2,.next_part

	move.l	d0,$4C2.w		; Update _drvbits

	lea	$472.w,a0		; hdv_bpb
	lea	old_hdv_bpb+2,a1
	move.l	(a0),(a1)+		; set old vector in jmp adrs
	move.l	a1,(a0)+		; set new vector after the jmp

	lea	old_hdv_rw+2,a1
	move.l	(a0),(a1)+		; set old vector in jmp adrs
	move.l	a1,(a0)+		; set new vector after the jmp

	tst.l	(a0)+			; skip hdv_boot

	lea	old_hdv_mediach+2,a1
	move.l	(a0),(a1)+		; set old vector in jmp adrs
	move.l	a1,(a0)			; set new vector after the jmp

	rts

;========================================>

	dc.l	INSTALL_MARKER	; Marker to verify presence
old_hdv_bpb:
	jmp	$CEDBCEDB
hdv_bpb:
	lea	sd_drive,a0
	lea	tos_bpb,a1
	moveq	#mbr_n_partitions-1,d1
.next:	move.w	(a0)+,d0
	cmp.w	4(a7),d0		; dev
	beq.s	.ok
	lea	bpb_size_b(a1),a1	; next tos_bpb structure
	dbra	d1,.next
	bra.s	old_hdv_bpb
.ok:	move.l	a1,d0			; return corresponding tos_bpb
	rts

;========================================>

old_hdv_rw:
	jmp	$CEDBCEDB
hdv_rw:				; LONG hdv_rw(WORD rw, UBYTE *buf, WORD count, WORD recno, WORD dev, LONG lrecno)
	lea	sd_drive,a0
	lea	sd_first_sector,a1
	moveq	#mbr_n_partitions-1,d1
.next:	move.w	(a0)+,d0
	cmp.w	14(a7),d0	; dev
	beq.s	.DevOK
	addq.l	#4,a1		; next sd_first_sector
	dbra	d1,.next
	bra.s	old_hdv_rw

.DevOK:	move.l	6(a7),a0	; buf
	move.w	10(a7),d1	; sector count

	moveq	#0,d0
	move.w	12(a7),d0	; recno
	bpl.s	.ok
	move.l	16(a7),d0	; lrecno
.ok:
	add.l	(a1),d0		; corresponding sd_first_sector

	btst.b	#0,5(a7)	; test Read/Write bit (rw)
	beq	SD_ReadData
	bra	SD_WriteData

;	moveq	#-13,d0		; EWRPRO / write protect
;	rts

;========================================>

old_hdv_mediach:
	jmp	$CEDBCEDB
hdv_mediach:
	lea	sd_drive,a0
	moveq	#mbr_n_partitions-1,d1
.next:	move.w	(a0)+,d0
	cmp.w	4(a7),d0		; dev
	beq.s	.ok
	dbra	d1,.next
	bra.s	old_hdv_mediach
.ok	moveq	#0,d0			; MEDIANOCHANGE
	rts

;========================================>
; Utils

PrintMsg:
	move.l	a0,-(a7)
	move.w	#$09,-(a7)	; Cconws
	trap	#1
	addq.l	#6,a7
	rts

LE_2_BE_W:
	move.b	1(a0),d0
	lsl.w	#8,d0		; Convert to Big Endian
	move.b	(a0),d0
	rts

LE_2_BE_L:
	addq.l	#4,a0
	move.b	-(a0),d0
	lsl.w	#8,d0		; Convert to Big Endian
	move.b	-(a0),d0
	swap	d0
	move.b	-(a0),d0
	lsl.w	#8,d0
	move.b	-(a0),d0
	rts

DivU32ByPowerOfTwo:	; d0 = number to divide, d1 = power of two divisor (1/2/4/8/16/32/128/256)
	moveq	#0,d2
	moveq	#1,d3
.again:	cmp.w	d1,d3	; Search the binary shift corresponding to power of two divisor
	bge.s	.found
	addq.w	#1,d2
	add.w	d3,d3
	bne.s	.again	; Avoid an infinite loop if we don't find the correct shift value (but result will be wrong)
.found:	lsr.l	d2,d0
	rts

;========================================>

	section	data

	even

ReverseByteTable:
	dc.b	$00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
	dc.b	$08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
	dc.b	$04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
	dc.b	$0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
	dc.b	$02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
	dc.b	$0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
	dc.b	$06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
	dc.b	$0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
	dc.b	$01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
	dc.b	$09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
	dc.b	$05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
	dc.b	$0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
	dc.b	$03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
	dc.b	$0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
	dc.b	$07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
	dc.b	$0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF

CMD_INIT:			dc.b	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
CMD_GO_IDLE_STATE:		dc.b	$40,$00,$00,$00,$00,$95
CMD_SEND_IF_COND:		dc.b	$48,$00,$00,$01,$AA,$87
CMD_APP_CMD:			dc.b	$77,$00,$00,$00,$00,$FF
ACMD_SD_SEND_OP_COND:		dc.b	$69,$40,$00,$00,$00,$FF
CMD_READ_OCR:			dc.b	$7A,$00,$00,$00,$00,$FF
CMD_READ_SINGLE_BLOCK:		dc.b	$51,$00,$00,$00,$00,$FF
CMD_WRITE_BLOCK:		dc.b	$58,$00,$00,$00,$00,$FF
WRITE_DATA_START:		dc.b	$FE

MsgInit:
	dc.b	$0D,$0A,$1B,$70				; Reverse Video
	dc.b	"SD Card on Extended Joystick Port A"
	dc.b	$0D,$0A,$1B,$71				; Normal Video
	dc.b	"Original Idea and Help by Zerosquare",$0D,$0A
	dc.b	"Driver v1.2c by Orion_ [2020]",$0D,$0A
	dc.b	"SD Init: ",0

MsgAlreadyInstalled:	dc.b	"Driver already installed !",$0D,$0A,0

MsgOK:	dc.b	"OK",$0D,$0A,0
MsgErr:	dc.b	"Error",$0D,$0A,0
MsgF32:	dc.b	"Error: Not "
MsgF16:	dc.b	"FAT16",$0D,$0A,0
MsgF12:	dc.b	"FAT12",$0D,$0A,0

MsgHook:
	dc.b	"Hooking Up Xbios Vectors",$0D,$0A,0

MsgMBR:	dc.b	"Reading MBR: ",0
MsgBPB:	dc.b	"Reading BPB: ",0

;========================================>

	section	bss

	even

GlobalProgramSize:	ds.l	1
sstack:			ds.l	1
spi_status:		ds.w	1
sd_drive:		ds.w	mbr_n_partitions
sd_first_sector:	ds.l	mbr_n_partitions
sd_good_partition:	ds.b	mbr_n_partitions
data:			ds.b	512
tos_bpb:		ds.w	bpb_size*mbr_n_partitions
sd_type:		ds.b	1
