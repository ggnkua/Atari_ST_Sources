;-----------------------------------------------------------------------
; Mandelbrot Bootsector/Ripped Off Guest Disk CD 110
;
; (c)1991 Griff
;
;-----------------------------------------------------------------------

disk	EQU 0

	IFEQ disk
	clr.l -(sp)
	move #$20,-(sp)
	trap #1
	addq.l #6,sp
	clr -(sp)
	pea -1.w
	pea -1.w
	move #5,-(sp)
	trap #14
	lea 12(sp),sp
	move #37,-(sp)
	trap #14
	addq.l #2,sp
	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,oldpal
	bsr bootls
	movem.l oldpal(pc),d0-d7
	movem.l d0-d7,$ffff8240.w
	clr -(sp)
	trap #1
oldpal	ds.w 16
	ENDC

	pea	now(pc)		;Warn user of impending doom
	move.w	#9,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;
	move.w	#8,-(a7)	;wait-key
	trap	#1		;
	addq.l	#2,a7		;
	
* First Get old Sector!

go	move.w	#1,-(a7)	;1 Sector
	move.w	#0,-(a7)	;Side 1
	move.w	#0,-(a7)	;Track 0
	move.w	#1,-(a7)	;Sector 1
	move.w	#0,-(a7)	;Drive A
	move.l	#0,-(a7)	;DUMMY
	move.l	#bufty,-(a7)	;Buffer
	move.w	#$8,-(a7)	;_floprd
	trap	#14		;
	add.l	#20,a7		;

	lea	bufty+2,a0	;Copy important values to our bootsector
	lea	bootbl+2,a1	;Thus ensuring we don't fuck-up
	move.w	#13,d0		;the disk, if it already contains stuff
patsy_kensit			;
	move.w	(a0)+,(a1)+	;
	dbf	d0,patsy_kensit	;

	move.w	#1,-(a7)	;Make Our Sector EXECUTABLE
	move.w	#-1,-(a7)	;Use OLD values
	move.l	#-1,-(a7)	;Use OLD values
	move.l	#bootbl,-(a7)	;512 Byte buffer
	move	#18,-(a7)	;
	trap	#14		; _protobt
	add.l	#14,a7 		;
	pea	out		;Tell 'em about it!
	move.w	#9,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;
	move	#0,d1		;Track is 0
	move	#1,d0		;Sector is 1
	bsr	write		;Write the boot sector
	pea	done		;We're done!
	move.w	#9,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;
	move.w	#8,-(a7)	;Wait-key
	trap	#1		;
	addq.l	#2,a7		;
	move	#0,-(a7)	;PTerm0
	trap	#1		;
		
write	movem.l	d0-d2/a0-a2,-(a7)
	move	#1,-(a7)	;Number of sectors
	move	#0,-(a7)	;Side number
	move	d1,-(a7)	;Track number
	move	d0,-(a7)	;Start Sector
	move	#0,-(a7)	;Device number
	clr.l	-(a7)		;Not used
	move.l	#bootbl,-(a7)	;Buffer
	move	#9,-(a7)	;
	trap	#14		; _flopwr
	add.l	#20,a7		;
	movem.l	(a7)+,d0-d2/a0-a2
	rts
		
	even

now	dc.b	13,10,13,10,13,10
	dc.b	"Please insert disk to Groovify and Press a key!",13,10,0
	
	even
	
out	dc.b	13,10,13,10,"Writing Auto-Boot Disk Now!",0

	even
	
done	dc.b	13,10,13,10,"Finished.......Press a key to exit. ",13,10,0

	even
		
bufty	ds.b	512

	even
	
;-----------------------------------------------------------------------
	
; The Boot Sector
; Max code size = 480 bytes

ystart		EQU -$2100
xstart		EQU -$2233
yinc		EQU $16*4
xinc		EQU $E*4
		
bootbl		bra.s	bootls		;Branch to Boot code
		ds.b	6		;OEM area
		dc.b	$00,$00,$00	;Serial number
		dc.b	$00,$02		;Bytes/Sector
		dc.b	$02		;Sectors/Cluster
		dc.b	$01,$00		;No. of Reserved Sectors
		dc.b	$02		;No. of FATs
		dc.b	$70,$00		;No. of Directory Entries
		dc.b	$d0,$02		;No. of Sectors
		dc.b	$f8		;Media descriptor
		dc.b	$05,$00		;Sectors/FAT
		dc.b	$09,$00		;Sectors/Track
		dc.b	$01,$00		;Sides on media
		dc.b	$00,$00		;Hidden Sectors

bootls		LEA $FFFF8240.W,A6
		MOVE #$777,D7
.fade_downlp	BSR Wait_Vbl
		BSR Wait_Vbl
		MOVE.W D7,(A6)
		SUB #$111,D7
		BNE.S .fade_downlp
		MOVEQ #7,D6
.clear_pal	CLR.L (A6)+
		DBF D6,.clear_pal
		PEA message(PC)
		MOVE #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
.fade_uplp	BSR Wait_Vbl
		BSR Wait_Vbl
		MOVE.W D7,$FFFF825E.W
		ADD #$111,D7
		CMP.W #$888,D7
		BNE.S .fade_uplp

		MOVE.L #8000*100,D0
.lp		SUBQ.L #1,D0
		BNE.S .lp
		MOVEM.L pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
mandel_draw	MOVE #2,-(SP)
		TRAP #14		; phy base
		ADDQ.L #2,SP
		MOVE.L D0,A0		
		MOVE.L #$4000000,A4
		MOVE #200,d2
		MOVE #ystart,A3
y_lp		MOVE #xstart,A2
		MOVEQ #19,D1
xchunk_lp	MOVEQ #15,D4
xpixel_lp	MOVEQ #0,D5
		MOVEQ #0,D6
		MOVEQ #0,D0
		MOVE.L D5,A6
		MOVEQ #42,D3		;46/44/43
iterate_lp	SUB.L D0,A6		;x2-y2
		MOVE.L A6,D7
		ASL.L #4,D7
		SWAP D7
		ADD.W A2,D7		;x=x2-y2+u	
		MULS D5,D6		;y*x
		ASL.L #5,D6		;*2
		SWAP D6
		ADD.W A3,D6		;y=(2*x*y)+v
		MOVE D7,D5		
		MULS D7,D7		;x*x
		MOVE.L D7,A6		;x2=x*x
		MOVE D6,D0
		MULS D0,D0		;y*y
		ADD.L D0,D7		;x2+y2
		CMP.L A4,D7		>=4
		DBHI D3,iterate_lp
plot		LSR #1,D3
		ROXL (A0)+
		LSR #1,D3
		ROXL (A0)+
		LSR #1,D3
		ROXL (A0)+
		LSR #1,D3
		ROXL (A0)
		SUBQ.L #6,A0
		LEA xinc(A2),A2
		DBF D4,xpixel_lp
		ADDQ.L #8,A0
		DBF D1,xchunk_lp
		LEA yinc(A3),A3
		MOVEM.L D1-D7/A0-A4,-(SP)
		MOVE.L #$600FF,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		MOVEM.L (SP)+,D1-D7/A0-A4
		TST.L D0
		BNE.S .out
		DBF D2,y_lp
		MOVE #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
.out		PEA cls(PC)
		MOVE #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA $FFFF8240.W,A6
		MOVEQ #7,D6
.clear_pal	CLR.L (A6)+
		DBF D6,.clear_pal
		RTS
Wait_Vbl	MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		RTS
pal		DC.W $000,$010,$020,$030,$040,$050,$060,$070
		DC.W $071,$072,$073,$074,$076,$076,$077,$000
cls		dc.b	27,'E',0

message		dc.b	27,"Y",31+3,31+12
		dc.b	"Ripped Off CD 110"
		dc.b	27,"Y",31+5,31+7
		dc.b	"- Inner Circle Guest Disk -"
		dc.b	27,"Y",31+11,31+5
		dc.b	"MandelBrot BootSector! by Griff"
		dc.b	0

endof		ds.b	512		;Ensure enough data for full sector
		even
	
;-----------------------------------------------------------------------
	

