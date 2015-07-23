start
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	file_table,a0
.loop	move.w	(a0)+,d1
	move.w	(a0)+,d2
	
	movem.l	a0/d0-d3,-(a7)
	moveq.l	#8,d0
	moveq.l	#0,d3
	lea	$100000,a0
	jsr	loader
	move.l	4(a0),d7
	jsr	loader+1046
	move.l	d7,length
	move.l	a0,start_add
	bsr	save_file
	movem.l	(a7)+,a0/d0-d3

	bra	.loop	

save_file
	lea	chars,a5
	lea	file_bit,a1
	move.w	d1,d2
	lsr.l	#8,d2
	lsr.l	#4,d2
	and.w	#$000f,d2
	move.b	0(a5,d2.w),d2
	move.b	d2,(a1)+
	move.w	d1,d2
	lsr.l	#8,d2
	and.w	#$000f,d2
	move.b	0(a5,d2.w),d2
	move.b	d2,(a1)+
	move.w	d1,d2
	lsr.l	#4,d2
	and.w	#$000f,d2
	move.b	0(a5,d2.w),d2
	move.b	d2,(a1)+
	move.w	d1,d2
	and.w	#$000f,d2
	move.b	0(a5,d2.w),d2
	move.b	d2,(a1)+


	move.w	#0,-(a7)
	move.l	#filename,-(a7)
	move.w	#60,-(a7)
	trap	#1
	add.w	#8,a7
	move.w	d0,d7
	
	move.l	start_add,-(a7)
	move.l	length,-(a7)
	move.w	d7,-(a7)
	move.w	#64,-(a7)
	trap	#1
	add.w	#12,a7
	
	move.w	d7,-(a7)
	move.w	#62,-(a7)
	trap	#1
	add.w	#4,a7
	rts

start_add	dc.l	0
length		dc.l	0
chars		dc.b	'0123456789ABCDEF'
filename	dc.b	'b:\POCK'
file_bit	dc.b	'0000',0

loader		incbin	a:\loader
file_table	incbin	a:\table

	end
*------------------------------------------------------------------------------
* Copylock(tm) ST - Disk Protection System for the Atari ST/STE
*
* (c)1988-90 Rob Northen Computing, U.K. All Rights Reserved.
*
* Title  : diskio.s
*
* Date   : 12.07.90
*------------------------------------------------------------------------------

*-----------------------------------------------------------------------------
* Low Level Disk Code for Copylock ST Key Disks
* on entry,
*	d0.w = drive no. and access mode
*		0 = drive A side 0            (sectors 0-799)
*		1 = drive B side 0            (sectors 0-799)
*		4 = drive A side 1            (sectors 0-799)	
*		5 = drive B side 1            (sectors 0-799)
*		8 = drive A double sided mode (sectors 0-1599)
*		9 = drive B double sided mode (sectors 0-1599)
*
*	d1.w = sector offset
*	d2.w = sectors to read/write
*	d3.w = function
*		0 = read sectors
*		1 = write sectors
*		2 = format track
*	bit 15 of d3.w controls whether the drive motor is turned off
*	after use. If bit 15 is clear the drive motor is left on. If
*	bit 15 is set the drive motor is turned off. Leave the drive
*	motor on if another disk operation is to be made soon after
*	the current one.
*
*	a0.l = disk buffer address
* on exit,
*	d0.l = result
*		00 = no error
*		21 = sector not found
*		24 = sector-id crc error
*		25 = data field crc error
*		28 = disk write protected
*		-1 = timeout
*
* Note: Diskio must be called from supervisor mode.
*	The drive step rate is 3ms.
*
* Example 1 - reading from a single sided disk
* 		moveq.l	#0,d0		drive A, single sided
*		moveq.l	#10,d1		track 1, side 0, sector 1
*		move.w	#100,d2		100 sectors
*		move.w	#$8000,d3	read, turn motor off
*		lea	disk_buffer(pc),a0
*		bsr	diskio		read 50K
*		tst.l	d0
*		bne.s	disk_error	branch if error
*
* Example 2 - reading from a double sided disk
* 		moveq.l	#8,d0		drive A, double sided
*		moveq.l	#10,d1		track 0, side 1, sector 1
*		move.w	#100,d2		100 sectors
*		moveq.l	#0,d3		read, leave motor on
*		lea	disk_buffer(pc),a0
*		bsr	diskio		read 50K
*		tst.l	d0
*		bne.s	disk_error	branch if error
*
* disk_error
*
*-----------------------------------------------------------------------------
diskio
		dc.l $48E778C0,$4E56FFE4,$38000244,$00013D44,$FFE43D41,$FFEA3D42,$FFEE3D43,$FFF82D48
		dc.l $FFF4E698,$02400001,$0A000001,$52003D40,$FFF04240,$E3983D40,$FFF27015,$D441B47C
		dc.l $06406E00,$009C48C1,$82FC000A,$0C6E0001,$FFF06702,$D2413D41,$FFE64841,$52413D41
		dc.l $FFE86100,$0244302E,$FFE8720B,$9240B26E,$FFEE6F04,$322EFFEE,$3D41FFEC,$61000070
		dc.l $66347000,$0C2E0002,$FFF9672A,$302EFFEE,$906EFFEC,$67203D40,$FFEE302E,$FFECE188
		dc.l $D080D1AE,$FFF43D7C,$0001FFE8,$302EFFF0,$D16EFFE6,$60B02200,$67260200,$0058721C
		dc.l $B03C0050,$671A7219,$B03C0008,$67127218,$B03C0018,$670A7215,$B03C0010,$670272FF
		dc.l $61000200,$4E5E2001,$4CDF031E,$4E756100,$022E363C,$0002600A,$B03C0010,$660E6100
		dc.l $0192302E,$FFE6E248,$6100016A,$206EFFF4,$322EFFE8,$342EFFEC,$61000010,$4A406708
		dc.l $B07C0040,$57CBFFD2,$4E754A2E,$FFF96704,$6000009E,$61000116,$33FC0090,$00FF8606
		dc.l $33FC0190,$00FF8606,$33FC0090,$00FF8606,$70003002,$61000294,$E188D080,$2248D3C0
		dc.l $33FC0080,$00FF8606,$303C0090,$6100027C,$203C0004,$000042AE,$FFFC0839,$000500FF
		dc.l $FA016726,$53806740,$1D7900FF,$8609FFFD,$1D7900FF,$860BFFFE,$1D7900FF,$860DFFFF
		dc.l $B3EEFFFC,$6ED46100,$020633FC,$009000FF,$86063039,$00FF8606,$08000000,$670E6100
		dc.l $02100200,$00184E75,$610001E4,$70FF4E75,$6100007A,$33FC0190,$00FF8606,$33FC0090
		dc.l $00FF8606,$33FC0190,$00FF8606,$70010C2E,$0001FFF9,$6702701F,$610001F0,$33FC0180
		dc.l $00FF8606,$303C00A0,$0C2E0001,$FFF96706,$303C00F0,$74016100,$01D2203C,$00040000
		dc.l $08390005,$00FFFA01,$670C5380,$66F26100,$017E70FF,$4E756100,$018E0200,$005C660A
		dc.l $41E80200,$52015302,$66864E75,$200813C0,$00FF860D,$E08813C0,$00FF860B,$E08813C0
		dc.l $00FF8609,$33FC0084,$00FF8606,$30016100,$017A4E75,$4A40671A,$33FC0086,$00FF8606
		dc.l $61000168,$303C0010,$610000F2,$6B027000,$4E757000,$610000E6,$6B0C0A00,$00040800
		dc.l $00026602,$70004E75,$3D790000,$043EFFFA,$50F90000,$043E6100,$0066302E,$FFE4D040
		dc.l $33FC0082,$00FF8606,$41FA0144,$30300000,$E2486100,$0116B07C,$00A06D04,$6100FFB4
		dc.l $4E7548E7,$C000302E,$FFE4D040,$41FA0120,$322EFFE6,$31810000,$4A6EFFF8,$6A0A203C
		dc.l $000C3500,$61000102,$103C0007,$6100004A,$33EEFFFA,$0000043E,$4CDF0003,$4E753F00
		dc.l $302EFFE4,$02400001,$5200D000,$3F00302E,$FFF0B07C,$00016706,$302EFFF2,$6008302E
		dc.l $FFE60240,$0001805F,$0A000007,$02000007,$61000006,$301F4E75,$40E7007C,$070013FC
		dc.l $000E00FF,$88001239,$00FF8800,$020100F8,$820013C1,$00FF8802,$46DF4E75,$B03C0080
		dc.l $64040000,$000333FC,$008000FF,$86066100,$005A203C,$00060000,$08390005,$00FFFA01
		dc.l $672E5380,$66F26100,$000670FF,$4E7533FC,$008000FF,$8606303C,$00D06100,$002E700F
		dc.l $61000046,$600A33FC,$018000FF,$86066008,$33FC0080,$00FF8606,$6100001A,$303900FF
		dc.l $86040280,$000000FF,$600A6100,$000833C0,$00FF8604,$40E73F00,$203C0000,$00186100
		dc.l $0008301F,$46DF4E75,$538066FC,$4E75FFFF,$FFFFFFFF
		dc.w $FFFF
