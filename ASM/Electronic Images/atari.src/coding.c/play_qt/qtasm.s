

			EXPORT	SETVGA,SETTV,go,start_time,end_time,frame_count,Save_Rez,Restore_Rez
			IMPORT Log_base,Phy_base
			IMPORT Cconis,alloc_display,init_display

; Falcon video register equates

vhz	        EQU $FFFF820A
voff_nl     EQU $FFFF820E
vwrap       EQU $FFFF8210
_stshift	EQU $FFFF8260
_spshift    EQU $FFFF8266
hht         EQU $FFFF8282
hbb         EQU $FFFF8284
hbe         EQU $FFFF8286
hdb         EQU $FFFF8288
hde         EQU $FFFF828A
hss         EQU $FFFF828C
hfs         EQU $FFFF828E
hee         EQU $FFFF8290
vft         EQU $FFFF82A2
vbb         EQU $FFFF82A4
vbe         EQU $FFFF82A6
vdb         EQU $FFFF82A8
vde         EQU $FFFF82AA
vss         EQU $FFFF82AC
vco_hi      EQU $FFFF82C0
vco         EQU $FFFF82C2


swap_screens:
			move.l	Log_base(pc),d0
			move.l	Phy_base(pc),d1
			move.l	d0,Phy_base
			move.l	d1,Log_base
			move.b	d0,$ffff820d.w
			lsr.w	#8,d0
			move.l	d0,$ffff8200.w
			addq.l	#1,frame_count
			rts

go:			move.w	#$2500,sr
			movem.l	d2-d7/a2-a6,-(sp)
			clr.l	frame_count

			move.l	$4ba.w,start_time
loop:		
			bsr		Cconis
			tst.l	d0
			beq.s	loop
			
itends:		move.l	$4ba.w,end_time
			movem.l	(sp)+,d2-d7/a2-a6
			move.w	#$2300,sr
			moveq	#0,d0
			rts
notmpeg:	movem.l	(sp)+,d2-d7/a2-a6
			move.w	#$2300,sr
			moveq	#-1,d0
			rts
			
frame_count:dc.l	0
start_time:	dc.l	0
end_time:	dc.l	0
			
; Set Video Mode to VGA True Colour 320x200.
; (hit the h/ware directly)

SETTV:
			move.w	#320,line_width
			lea	TC320_TV(PC),A0
			clr.w	(_spshift.w)
			LEA (hht).w,A1
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			move.W	#$0271,(vft.w)
			move.w	vertical_size(pc),d1
			add.w	d1,d1				; *4
			move.w	#480,d0
			sub.w	d1,d0
			lsr.w	#1,d0
			add.w	#$3f,d0
			add.w	d0,d1
			move.w	d0,(vbe.w)  ; top border display end (3f)
			move.w	d1,(vbb.w)	; bottom border (3ff)
			move.w	d0,(vdb.w)	; display start (3f)
			move.w	d1,(vde.w)	; display end   (3ff)
			move.w	#$026b,(vss.w)
	    	move.w  (a0)+,(voff_nl.w)
			MOVE.W  (a0)+,(vwrap.w)
	        move.w  (a0)+,(vco.w)
	        move.w  (a0)+,(vco_hi.w)
			move.w  (a0)+,(vhz.w)
			move.w  (a0),(_spshift)
			rts

SETVGA:		lea	TC320_VGA(PC),A0
			move.w horizontal_size(pc),d0
			move.w vertical_size(pc),d1
			cmp.w	#320,d0
			bhi.s	.set480
			cmp.w	#240,d1
			bhi.s	.set480
			move.w	#320,line_width
			clr.w	(_spshift.w)
			LEA (hht).w,A1
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			move.W	#$0419,(vft.w)
			lsl.w	#2,d1				; *4
			move.w	#960,d0
			sub.w	d1,d0
			lsr.w	#1,d0
			add.w	#$3f,d0
			add.w	d0,d1
			move.w	d0,(vbe.w)  ; top border display end (3f)
			move.w	d1,(vbb.w)	; bottom border (3ff)
			move.w	d0,(vdb.w)	; display start (3f)
			move.w	d1,(vde.w)	; display end   (3ff)
			move.w	#$0415,(vss.w)
		    move.w  (a0)+,(voff_nl.w)
			MOVE.W  (a0)+,(vwrap.w)
	        move.w  (a0)+,(vco.w)
	        move.w  (a0)+,(vco_hi.w)
			move.w  (a0)+,(vhz.w)
			move.w  (a0),(_spshift)
			RTS
.set480:	lea	TC480_VGA(PC),A0
			move.w	#480,line_width
			clr.w	(_spshift.w)
			LEA (hht).w,A1
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			move.W	#$0319,(vft.w)
			lsl.w	#1,d1				; *4
			move.w	#768-64,d0
			sub.w	d1,d0
			lsr.w	#1,d0
			add.w	#$3f,d0
			add.w	d0,d1
			move.w	d0,(vbe.w)  ; top border display end (3f)
			move.w	d1,(vbb.w)	; bottom border (3ff)
			move.w	d0,(vdb.w)	; display start (3f)
			move.w	d1,(vde.w)	; display end   (3ff)
			move.w	#$0315,(vss.w)
		    move.w  (a0)+,(voff_nl.w)
			MOVE.W  (a0)+,(vwrap.w)
	        move.w  (a0)+,(vco.w)
	        move.w  (a0)+,(vco_hi.w)
			move.w  (a0)+,(vhz.w)
			move.w  (a0),(_spshift)
			RTS

line_width:	dc.w 	0

Save_Rez:	move.w	#37,-(sp)
			trap	#14
			addq.l	#2,sp
			lea		saved_res,a0
		    move.w  (voff_nl.w),(a0)+
			MOVE.W  (vwrap.w),(a0)+
			move.l  (_spshift.w)-2,(a0)+		
			LEA 	(hht).w,A1
			MOVE.L	(a1)+,(A0)+
			MOVE.L	(a1)+,(A0)+
			MOVE.L	(a1)+,(A0)+
			MOVE.L	(a1)+,(A0)+
			move.W	(vft.w),(a0)+
			move.w	(vbe.w),(a0)+ 
			move.w 	(vbb.w),(a0)+	
			move.w	(vdb.w),(a0)+
			move.w	(vde.w),(a0)+
			move.w	(vss.w),(a0)+
	        move.l  (vco_hi.w),(a0)+
			move.w  (vhz.w),(a0)+
			RTS
			
Restore_Rez:LEA		saved_res,a0
		    move.w  (a0)+,(voff_nl.w)
			MOVE.W  (a0)+,(vwrap.w)
			move.l  (a0)+,(_spshift.w)-2
			LEA 	(hht).w,A1
			MOVE.L	(a0)+,(a1)+
			MOVE.L	(a0)+,(a1)+
			MOVE.L	(a0)+,(a1)+
			MOVE.L	(a0)+,(a1)+
			move.W	(a0)+,(vft.w)
			move.w	(a0)+,(vbe.w)
			move.w 	(a0)+,(vbb.w)
			move.w	(a0)+,(vdb.w)
			move.w	(a0)+,(vde.w)
			move.w	(a0)+,(vss.w)
	        move.l  (a0)+,(vco_hi.w)
			move.w  (a0)+,(vhz.w)
			RTS
			
			data	

TC320_VGA:	DC.W	$00C6 ; hht
			DC.W	$008D ; hbb
			DC.W	$0015 ; hbe
			DC.W	$02AC ; hdb
			DC.W	$0091 ; hde (horizontal display end, 0 == middle
			DC.W	$0096 ; hss
			DC.W	$0000 ; hfs
			DC.W	$0000 ; hee
			DC.W	$0000 ; next line offset
			DC.W	$0140 ; vwrap
			DC.W	$0005 ; vco
			DC.W	$0186 ; vco hi
			DC.W	$0000 ; $ffff820a
			DC.W	$0100 ; spshift

TC480_VGA:	DC.W	$011C ; hht
			DC.W	$00D7 ; hbb
			DC.W	$0015 ; hbe
			DC.W	$0302 ; hdb
			DC.W	$00DB ; hde
			DC.W	$00F0 ; hss
			DC.W	$0000 ; hfs
			DC.W	$0000 ; hee
			DC.W	$0000 ; next line offset
			DC.W	$01E0 ; vwrap
			DC.W	$0004 ; vco
			DC.W	$0182 ; vco hi
			DC.W	$0000 ; $ffff820a
			DC.W	$0100 ; spshift


TC320_TV:	DC.W	$00FE ; hht
			DC.W	$00CB ; hbb
			DC.W	$0027 ; hbe
			DC.W	$002E ; hdb
			DC.W	$008F ; hde
			DC.W	$00D8 ; hss
			DC.W	$0000 ; hfs
			DC.W	$0000 ; hee
			DC.W	$0000 ; next line offset
			DC.W	$0140 ; vwrap
			DC.W	$0000 ; vco
			DC.W	$0183 ; vco hi
			DC.W	$0200 ; $ffff820a
			DC.W	$0100 ; spshift

			.ALIGN 16

last_vert:	dc.w	-1
ld_rdptr:	ds.l	1
ld_quant_scale:
			ds.l	1
MBAmax:		ds.l	1
dc_dct_pred:ds.w 	3
horizontal_size:
			ds.w	1
vertical_size:
			ds.w	1
mb_width:	ds.w	1
mb_height:	ds.w	1
coded_picture_width:
			ds.w	1
coded_picture_height:
			ds.w	1

			.ALIGN 16
			

			bss
			
saved_res:	ds.l	32
temp:		ds.l 	1024
