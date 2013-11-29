;***************************************************************************
;    CECILE Device Driver
;    Copyright (C) 1999-2006  David Godec  (david.godec@online.fr)
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;
;***************************************************************************

;Opcode 1: LONG XHInqTarget (UWORD major, UWORD minor, ULONG *blocksize,
;                            ULONG *device_flags, char *product_name);
;
;Returns information about the device specified by `major' and `minor'. 
;Reservation made with `XHReserve()' are reflected in `device_flags'.
;
;block_size:   Block size for this device (important for `XHReadWrite()').
;              Usually 512.
;
;device_flags: (Bit set -> Capability available)
;
;      Bit 0:  Device is stoppable (XH_TARGET_STOPPABLE)
;      Bit 1:  The medium is removable (XH_TARGET_REMOVABLE)
;      Bit 2:  The eject mechanism can be locked 
;              (XH_TARGET_LOCKABLE)
;      Bit 3:  The device can physically eject the medium
;              (XH_TARGET_EJECTABLE)
;      Bit 29: Eject mechanism has been locked by the driver
;              (XH_TARGET_LOCKED, from XHDI 1.25 up)
;      Bit 30: Device has been stopped by the driver (XH_TARGET_STOPPED,
;              from XHDI 1.25 up)
;      Bit 31: The device is currently reserved (XH_TARGET_RESERVED)
;
;              All other bits are reserved, drivers should set them to zero.
;
;product_name: Product name of the device, similar to the information
;              returned by the SCSI command INQUIRE (max. 33 characters
;              incl. terminating zero). If this information is not
;              available, the driver should return a zero length string.
;
;Note: the caller may pass a zero pointer for `blocksize', `device_flags' 
;and `product_name'.
;
;Note: for IDE devices, product name information might have to be truncated 
;to fit into 32 characters. See `XHInqTarget2'.

		****
		
		rsset	8
_xh1_opcode	rs.w	1	; stacked opcode
_xh1_major	rs.w	1	; dev's major
_xh1_minor	rs.w	1	; dev's minor
_xh1_blksize	rs.l	1	; for return of blocksize
_xh1_flags	rs.l	1	; for return of flags
_xh1_name		rs.l	1	; for return of name
		
		****
XHInqTarget:
		movem.l	d1-d2/a0-a2,-(sp)
		
		moveq	#0,d0
		move.w	_xh1_major(a6),d0
		
		; don't support ACSI,lowest is scsi#0
		
		subq.w	#8,d0
		bmi.s	.undev
		
		; don't support above ide#1
		
		cmp.w	#9,d0
		bgt.s	.undev
		
		cmp.w	#8,d0
		blt.s	.scsi
		
		****
		****
.ide
		; for the ide we'll just look at the internal
		; device data table to tell the device name but
		; the block size must be treated separately depending
		; on whether it's a ata or atapi device...
		
		lea	cooky(pc),a0
		move.l	(a0),a0
		
		addq.l	#8,d0
		lsl.l	#7,d0
		add.l	d0,a0
		
		tst.l	(a0)
		beq.s	.undev
		
		tst.l	_xh1_blksize(a6)
		beq.s	.hop1
			
			move.l	#512,([_xh1_blksize.w,a6])
.hop1	
		tst.l	_xh1_flags(a6)
		beq.s	.hop2
			
			clr.l	([_xh1_flags.w,a6])
.hop2		
		tst.l	_xh1_name(a6)
		beq.s	.hop3
		
			move.l	_xh1_name(a6),a1
			lea	27*2(a0),a2
			moveq	#20-1,d0
.icstr		
			move.b	(a2)+,(a1)+
			dbf	d0,.icstr
		
			moveq	#12-1,d0
.ipad			
			clr.b	(a1)+
			dbf	d0,.ipad
.hop3
		bra	.eok
		
		****
		****
.scsi		
		lea	cooky(pc),a0
		move.l	(a0),a0
		
		addq.l	#8,d0
		lsl.l	#7,d0
		add.l	d0,a0
		
		tst.l	(a0)
		beq.s	.undev
		
		tst.l	_xh1_blksize(a6)
		beq.s	.sop1
		
			move.w	d0,-(sp)
			Bios	scSelect
		
			pea	(cdb_read_capacity.w,pc)
			move.w	#10,-(sp)
			Bios	scCmd
		
			lea	(tib_read_capacity.w,pc),a0
			lea	dev_capacity(pc),a1
			move.l	a1,2(a0)
		
			pea	(a0)
			Bios	scRead
		
			pea	dev_status(pc)
			pea	dev_msg(pc)
			pea	100.w
			Bios	scComplete
			
			lea	dev_capacity+4(pc),a1
			move.l	(a1),([_xh1_blksize.w,a6])
.sop1	
		tst.l	_xh1_name(a6)
		beq.s	.sop2
		
			move.l	_xh1_name(a6),a1
			lea	16(a0),a2
			moveq	#32-1,d0
.scstr		
			move.b	(a2)+,(a1)+
			dbf	d0,.scstr
.sop2
		tst.l	_xh1_flags(a6)
		beq.s	.sop3
			
			clr.l	([_xh1_flags.w,a6])
.sop3		
		****
		****
.eok
		moveq	#E_OK,d0
.exit		
		movem.l	(sp)+,d1-d2/a0-a2
		rts
		
		****
.undev
		moveq	#E_UNDEV,d0
		bra.s	.exit
				
		****

****************************************************************
		
		****
		DATA
		****
cdb_read_capacity:
		dc.b	$25,0,0,0,0,0,0,0,0,0
		
tib_read_capacity:
		dc.w	scNoInc
		dc.l	0
		dc.l	2*4
		
		dc.w	scStop
		dc.l	0
		dc.l	0

dev_status	dc.b	0
dev_msg		dc.b	0

dev_capacity	dc.l	0,0

		****

****************************************************************
