; Shade-Bobs fÅr die True Color Modi des Falcon
; coded 1993 by Scandion of the Mugwumps / THE INDEPENDENT

spr_anz         EQU 60	        ;Anzahl der Sprites
offset	        EQU 12           ;Abstand zwischen den Sprites
shade_len	EQU 60		;LÑnge der Shade-Wurst

;Werte fÅr die verschiedenen Auflîsungen:
x_max           EQU 319         ;VGA
y_max           EQU 239         ;VGA

;Werte zur Programmierung der Videohardwareregister:
vertflag        EQU $0100
stmodes         EQU $80
overscan        EQU $40
pal             EQU $20
ntsc            EQU $00
vga             EQU $10
tv              EQU $00
col80           EQU $08
col40           EQU $00
bps16           EQU 4
bps8            EQU 3
bps4            EQU 2
bps2            EQU 1
bps1            EQU 0
getmode         EQU -1

;verschiedene "Modecodes":
my_mode         EQU vertflag|pal|vga|col40|bps16 ;VGA-Monitor

                TEXT
                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
		move.l	d0,old_ssp
                DC.W $A00A

                move.w  #3,-(SP)
                trap    #14
                addq.l  #2,SP
                move.l  D0,old_scr_adr

                move.w  #getmode,-(SP)
                move.w  #88,-(SP)
                trap    #14
                addq.l  #4,SP
                move.w  D0,old_modecode

                move.l  scr_adr(PC),D0
                move.w  #my_mode,D1     ;"True Color"
                bsr.s   set_scr_adr

                move.l  #(x_max+1)*(y_max+1),D0
                movea.l #scr_base,A0
		moveq	#0,d1
fill_lp:        move.l	d1,(A0)+
                subq.l  #1,D0
                bpl.s   fill_lp

                move.l  $0118.w,old_mkb+2
                move.l  $70.w,old_vbl
	        move.l  #shade,$70.w

wait:           cmpi.b  #$39,$FFFFFC02.w ;Auf Space warten
                bne.s   wait

                move    SR,-(SP)
                move    #$2700,SR
                move.l  old_vbl(PC),$70
                move.l  old_mkb+2(PC),$0118.w
                move    (SP)+,SR

                move.l  old_scr_adr(PC),D0
                move.w  old_modecode(PC),D1
                bsr.s   set_scr_adr

		move.l	old_ssp,-(sp)
		move.w 	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
	
                DC.W $A009
                clr.w   -(SP)
                trap    #1


set_scr_adr:    move.w  D1,-(SP)
                move.w  #3,-(SP)
                move.l  D0,-(SP)
                move.l  D0,-(SP)
                move.w  #5,-(SP)
                trap    #14

                move.w  #$25,-(SP)      ;VSYNC
                trap    #14
                lea     16(SP),SP
                rts


mkb:            move    #$2500,SR
old_mkb:        jmp     $0


shade:		movem.l d0-a6,-(sp)

		move.l  scr_adr(PC),log_scr_adr
scr_change:     addi.l  #(x_max+1)*(y_max+1)*2,scr_adr
                bchg    #1,scr_change
                move.b  scr_adr+1(PC),$FFFF8201.w ;HIGH
                move.b  scr_adr+2(PC),$FFFF8203.w ;MID
                move.b  scr_adr+3(PC),$FFFF820D.w ;LOW


		subq.w 	#1,wait_cn
		bpl	not_cls
		clr.w	wait_cn		

	        move.l	xy_pointer2(PC),a2
		move.l	xy_pointer3(pc),a3
                lea     offset_tab(PC),A5

                tst.w   1008(A2)            ;Ende der XY-Tabelle?
                bpl.s   go_on3
                move.l  #xy0,xy_pointer2
		lea 	xy0,a2
go_on3:         addq.l  #4,xy_pointer2

   		tst.w   1008(A3)          ;Ende der XY-Tabelle?
                bpl.s   go_on4
                move.l  #xy1,xy_pointer3
		lea 	xy1,a3
go_on4:         addq.l  #8,xy_pointer3

;lîschen
		move.w	#spr_anz-1,d7
spr_lp0:        move.w  (A2),D0
                move.w  2(A2),D1
		add.w 	(a3),d0                
		add.w	2(a3),d1
		lea	offset*4(a2),a2
			
		addq.l 	#4,a3
		
                movea.l log_scr_adr(PC),A1
		
		add.w   D0,D0           ;*2
                lea     0(A1,D0.w),A1
                asl.w   #2,D1           ;*4
                move.l  0(A5,D1.w),D1   ;Offset berechnen
                lea     0(A1,D1.l),A1

	        move.l 	#%0000100001000011,d1
;	        move.l 	#%00001000010000010000100001000001,d1
		moveq	#10-1,d2
lp1:		sub.w	d1,(a1)+
		sub.w	d1,(a1)+
		sub.w	d1,(a1)+
		sub.w	d1,(a1)+
		sub.w	d1,(a1)+
		sub.w	d1,(a1)+
		sub.w	d1,(a1)+
		sub.w	d1,(a1)+
		sub.w	d1,(a1)+
		sub.w	d1,(a1)+
		lea	(x_max+1-10)*2(a1),a1
              	dbra	d2,lp1
		dbra 	d7,spr_lp0


not_cls:        move.l	xy_pointer0(PC),a2
		move.l	xy_pointer1(pc),a3
                lea     offset_tab(PC),A5

                tst.w   1008(A2)            ;Ende der XY-Tabelle?
                bpl.s   go_on0
                move.l  #xy0,xy_pointer0
		lea 	xy0,a2
go_on0:         addq.l  #4,xy_pointer0

   		tst.w   1008(A3)          ;Ende der XY-Tabelle?
                bpl.s   go_on2
                move.l  #xy1,xy_pointer1
		lea 	xy1,a3
go_on2:         addq.l  #8,xy_pointer1


		move.w #spr_anz-1,d7
spr_lp1:	move.w  (A2),D0
                move.w  2(A2),D1
		add.w 	(a3),d0                
		add.w	2(a3),d1
		lea	offset*4(a2),a2
		addq.l 	#4,a3
		
                movea.l log_scr_adr(PC),A1
		
		add.w   D0,D0           ;*2
                lea     0(A1,D0.w),A1
                asl.w   #2,D1           ;*4
                move.l  0(A5,D1.w),D1   ;Offset berechnen
                lea     0(A1,D1.l),A1

	        move.l 	#%0000100001000011,d1
;	        move.l 	#%00001000010000010000100001000001,d1
		moveq	#10-1,d2
lp0:		add.w	d1,(a1)+
		add.w	d1,(a1)+
		add.w	d1,(a1)+
		add.w	d1,(a1)+
		add.w	d1,(a1)+
		add.w	d1,(a1)+
		add.w	d1,(a1)+
		add.w	d1,(a1)+
		add.w	d1,(a1)+
		add.w	d1,(a1)+
		lea	(x_max+1-10)*2(a1),a1
              	dbra	d2,lp0
		dbra 	d7,spr_lp1

;		bsr	showtime

		movem.l (sp)+,d0-a6
		rte


showtime:       pea	(a1)
		pea 	(a0)
		move.l	d0,-(sp)
		moveq	#0,d0
		move.b  $ffff8205.w,d0
		lsl.w 	#8,d0
		move.b	$ffff8207.w,d0
		lsl.l	#8,d0
		move.b	$ffff8209.w,d0
		move.l	d0,a0
		lea 	savebuf,a1
		moveq	#-1,d0 
               REPT 10
		move.w  (a0),(a1)+  			
		move.w	d0,(a0)+
               ENDR
		lea 	-20(a0),a0
		lea	-20(a1),a1
	       REPT 10
		move.w	(a1)+,(a0)+
	       ENDR
		movem.l (sp)+,d0/a0-a1	
		rts

wait_cn:	dc.w shade_len
savebuf:	ds.w 10	
old_ssp: 	ds.l 1
old_modecode:   DS.W 1
old_vbl:        DS.L 1
old_scr_adr:    DS.L 1
log_scr_adr:    DS.L 1
scr_adr:        DC.L scr_base+4
xy_pointer0:	dc.l xy0
xy_pointer1:	dc.l xy1
xy_pointer2:	dc.l xy0
xy_pointer3:	dc.l xy1

offset_tab:
count           SET 0
                REPT y_max
                DC.L count
count           SET count+(x_max+1)*2
                ENDR

xy0:            incbin XY3.BIN
		incbin xy3.bin     
           	DC.W -1
xy1: 		incbin xy4.bin
		incbin xy4.bin
		dc.w -1


                BSS
scr_base:       DS.W (x_max+1)*(y_max+1)*2
                END
