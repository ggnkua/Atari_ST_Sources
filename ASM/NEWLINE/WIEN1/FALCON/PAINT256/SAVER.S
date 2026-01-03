;Werte zur Programmierung der Videohardwareregister:
vertflag        EQU $0100
stmodes         EQU $800
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

		bsr	save	


my_mode          EQU pal|vga|col80|bps8 ;VGA-Monitor

                move.w  #getmode,-(SP)
                move.w  #88,-(SP)
                trap    #14
                addq.l  #4,SP
                move.w  D0,old_modecode

                move.l  scr_adr(PC),D0
                move.w  #my_mode,D1     ;"True Color"
	
set_scr_adr
	move.w  D1,-(SP)
	move.w  #3,-(SP)
	move.l  #-1,-(SP)
	move.l  #-1,-(SP)
	move.w  #5,-(SP)
	trap    #14

        move.w  #$25,-(SP)      ;VSYNC
        trap    #14
        lea     16(SP),SP
        rts
