The following defines are the addresses of the internal registers of the
NCR 5380 SCSI controller in the Mac Plus, SE, and II.

#define SCSIBase68000	0x580000
#define SCSIBase68020	0x50F10000

#define RdData	0x00
#define WrData	0x01
#define RdInitCmd	0x10
#define WrInitCmd	0x11
#define RdMode	0x20
#define WrMode	0x21
#define RdTargCmd	0x30
#define WrTargCmd	0x31
#define RdStatus	0x40
#define RdBusStat	0x50


;Subroutine scuzzy_select selects the target specified by D1.
;Once this routine is called, you must not perform any "normal"
;SCSI operations until you call scuzzy-deselect.
;On entry, D1 contains expanded target ID, e.g. if ID = 2, D1 = 00000100.
;A0 contains base address of 5380.
;On return, D0 contains error code:
;	0 = no error, 1 = SCSI bus occupied, 2 = target not responding

scuzzy_select:
	Debugger
	move.b	#0x0,WrTargCmd(A0)	;Set bus phase to free.
	move.b	#0x40,WrMode(A0)	;Set target mode.
	btst.b	#6,RdStatus(A0)		;bus should be free, BSY deasserted.	beq	@busfree		;jump if bus free 
	move.w	#1,D0		;Someone else is on the bus, set 	bra	@restore_scsi		;error code to 1 and return.

busfree:		;Nobody will reselect, bus is all ours.
	move.b	#0x0,WrTargCmd(A0)	;Set bus phase to free.
	move.b	#0x1,WrInitCmd(A0)	;assert data bus.
	move.b	D1,WrData(A0)		;Put target ID on bus.
	move.b	#0x5,WrInitCmd(A0)	;Assert SEL
	move.w	#10,D0		;set up D0 as timeout counter 	
select_lp:
	btst.b	#6,RdStatus(A0)		;look for BSY asserted 
	bne	@selected		;jump if it is
	dbra	D0,@select_lp		;if not, loop up to 10 times				
timeout:			;If timed out, set error code to
	move.w	#2,D0		;target not responding.
	bra	@restore_scsi		;return
	
selected:
	move.b	#0x0,WrInitCmd(A0)	;deassert SEL,data bus
	rts			;return.  Target now on SCSI bus



;Subroutine write_address updates the interface address register with the
;8-bit address passed in D0.
;On entry, A0 contains base address of 5380

write_address:
	move.b	#0x3,WrTargCmd(A0)	;assert i/o and c/d, deassert msg
	move.b	#0x1,WrInitCmd(A0)	;assert data bus
	move.b	D0,WrData(A0)		;address out to scsi bus
	move.b	#0xB,WrTargCmd(A0)	;assert REQ
	move.b	#0x3,WrTargCmd(A0)	;deassert REQ
	move.b	#0x0,WrInitCmd(A0)	;deassert data bus
	rts


;Subroutine write_data writes the 8-bit data in D0 to the interface.
;On entry, A0 contains base address of 5380

write_data:
	move.b	#0x1,WrTargCmd(A0)	;assert i/o deassert c/d  msg
	move.b	#0x1,WrInitCmd(A0)	;assert data bus
	move.b	D0,WrData(A0)		;data out to scsi bus
	move.b	#0x9,WrTargCmd(A0)	;assert REQ
	move.b	#0x1,WrTargCmd(A0)	;deassert REQ
	move.b	#0x0,WrInitCmd(A0)	;deassert data bus
	rts
	
	
;Subroutine read_data reads the 8-bit data from the interface to D0.
;On entry, A0 contains base address of 5380
	
read_data:
	move.b	#0x0,WrTargCmd(A0)	;deassert i/o  c/d  msg
	move.b	#0x8,WrTargCmd(A0)	;assert REQ
	move.b	RdData(A0),D0		;data in from scsi bus
	move.b	#0x0,WrTargCmd(A0)	;deassert REQ
	rts


;Subroutine scuzzy-deselect removes the interface from the scsi bus,
;and returns the bus to normal operation.
;On entry, A0 contains base address of 5380
;On return, D0 contains error code:
;	0 = no error, 3 = target stuck on bus.

scuzzy_deselect:
	move.b	#0,D0		;set return error to 0
	move.b	#0x2,WrTargCmd(A0)	;deassert i/o  msg , assert c/d
	move.b	#0xA,WrTargCmd(A0)	;assert REQ
	move.b	#0x2,WrTargCmd(A0)	;deassert REQ
	nop			;give BSY time to
	nop			;get off the bus
	nop
	nop
	btst.b	#6,RdStatus(A0)		;look for BSY still asserted 
	beq	@restore_scsi		;jump if it is not
	move.b	#3,D0		;it is, target stuck on bus
restore_scsi:
	move.b	#0x0,WrInitCmd(A0)	;restore 5380 registers 
	move.b	#0x0,WrMode(A0)	
	move.b	#0x7,WrTargCmd(A0)
	move.b	#0x0,WrData(A0)
	rts

