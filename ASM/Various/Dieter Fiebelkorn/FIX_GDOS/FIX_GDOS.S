; Fix GDOS
;
SUPER:
;
start:                                  ;lea.l  start-256, a1
                movea.l SP,A1
                movea.l 4(A1),A1        ; start der Basepage
                move.l  12(A1),D1       ; textsegmentsize
                add.l   20(A1),D1       ; datasegementsize
                add.l   28(A1),D1       ; bssegmentsize
                add.l   #324,D1         ; basepagesize

                move.l  A1,D0
                add.l   D1,D0           ; new stack
                and.b   #$FC,D0         ; gerade Adresse
                movea.l D0,SP           ; Stack liegt im BSS

                move.l  D1,-(SP)        ; ben”tigter Speicher
                move.l  A1,-(SP)        ; Startadresse
                clr.w   -(SP)           ; dummy
                move.w  #74,-(SP)       ; Mshrink
                trap    #1              ; Gemdos
                lea     12(SP),SP

                clr.w   -(SP)
                move.l  D1,-(SP)
                move.l  A1,base_page
                add.l   A1,D1
                and.b   #$FE,D1
                move.l  D1,base_page+4
                
				bsr		vq_aes
				move.w	D0,auto_start
                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                move.l  D0,super_ret
                addq.l  #6,SP

				tst.w	auto_start
				beq.b	install
				move.l	#$0BFFFFFF,$002C
				move.l  #$04CE,A0
loop_vbl:
				addq.l  #4,A0
				move.l  (A0),D0
				bne.b   loop_vbl
				move.l  A0,vbl_slot
				move.l	#wait_for_aes,(A0)
				bra.b	leave
install:
				bsr		look_fixgdos
				tst.l   D0
				bne.b   is_init

init_rout:
                move.l  $88,old_vect
                move.l  #trap_2,$88

				move.w	auto_start,D0
				bne		return
leave:
                move.l  super_ret,-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

                pea     init_msg
                move.w  #$09,-(SP)
                trap    #1
                addq.l  #6,SP
                
                move.w  #$31,-(SP)
                trap    #1

is_init:
				move.w	auto_start,D0
				bne		return
                move.l  super_ret,-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

                pea     exit_msg
                move.w  #$09,-(SP)
                trap    #1
                addq.l  #6,SP

                move.l  (SP)+,D0
                trap    #1

;
base_page:
                DC.L 0
                DC.L 0

                DC.B 'XBRA'
my:
                DC.B 'dfGD'
old_vect:
                DC.L 0

;
trap_2:
                cmpi.w  #$73,D0         ; vdi ?
                bne.b   old_trap
                movea.l D1,A0
                movea.l 0(A0),A1
                cmpi.w  #100,(A1)       ; v_opnvwk ?
                beq.b   own_trap
old_trap:
                movea.l old_vect,A0
                jmp     (A0)
own_trap:
                cmpi.w  #0,12(A1)
                bne.b   own2trap
                move.w  #1,12(A1)
own2trap:
				movea.l 4(A0),A1
				cmpi.w  #0,0(A1)
				bne.b   old_trap
				move.w  #1,0(A1)
                bra.b   old_trap
;
look_fixgdos:
                movea.l $88,A0
loop:
                suba.l  #$0C,A0
                lea     xbra,A1
                move.l  #3,D1
loop1:
                move.b  (A0)+,D0
                cmp.b   (A1)+,D0
                dbne    D1,loop1
                cmpi.w  #-1,D1
                bne     to_init_rout

                lea     my,A1
                move.l  #3,D1
loop2:
                move.b  (A0)+,D0
                cmp.b   (A1)+,D0
                dbne    D1,loop2
                cmpi.w  #-1,D1
                beq     to_is_init

                movea.l 0(A0,D1.w),A0
                bra     loop
to_init_rout:
				move.l	#0,D0
				rts
to_is_init:
				move.l	#1,D0
				rts
				
                DC.B 'XBRA'
                DC.B 'dfGD'
                DC.L 0
wait_for_aes:
				cmpi.w	#$FFFF,counter
				beq.b	waiting
				sub.w	#1,counter
				bne.b	return
				
				bsr		look_fixgdos
				tst.l   D0
				bne.b   clr_vbl
				move.w	#$80, tested
				bra     install
clr_vbl:
				sub.w	#1,tested
				bne.b	wait2
				move.l	vbl_slot,A0
				clr.l	(A0)
				rts
waiting:
				move.l	$002C,D0
				cmpi.l	#$0BFFFFFF,D0
wait2:
				move.w	#$0090,counter
return:
				rts
;
vq_aes:
				move.w	#$C9,D0
				trap	#2
				tst.w	D0
				sne.b	D0
				ext.w	D0
				rts
;
                DATA
super_ret:
                DC.L 0
vbl_slot:
				DC.L 0
auto_start:
				DC.W 0
counter:
				DC.W $FFFF
tested:
				DC.W $0080
xbra:
                DC.B 'XBRA'
init_msg:
                DC.B 13,10,"Initialize Fix-GDOS !  (c)'91 Dieter Fiebelkorn",13,10,0
exit_msg:
                DC.B 13,10,"*** Fix-GDOS is already in use ! ***",13,10,0
;

                END
