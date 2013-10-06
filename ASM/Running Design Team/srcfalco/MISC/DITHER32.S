;***
;*** Project RUNNING
;*** (C) 1994/1995 by Tarzan Boy of STAX
;***
;*** DITHERPROGRAMM V0.3
;*** Last updated: 2.3.1996

header          EQU 128         ; Truepaint = 128, Indypaint = 256


                TEXT


		move.l  4(sp),a5                ;Basepage-Adresse holen
        	lea     $80(a5),a6              ;Copmmand-Adresse holen

        	move.b  (a6)+,d0                ;LÑnge der Commandline holen
        	beq     usage_info

        	ext.w   d0
        	cmp.b   #13,(a6,d0.w)		;$0d als Endmarke?
        	bne.s   no_korr
        	subq.w  #1,d0                   ;$0d ignorieren
no_korr:
        	lea     dit_filename(pc),a5
        	lea     tpi_filename(pc),a4
copy_command:
        	move.b  (a6),(a5)+              ;1 Zeichen rÅber
        	move.b  (a6)+,(a4)+
        	dbra    d0,copy_command
change_to_dit_loop:
        	cmp.b   #".",-(a5)              ;Punkt erreicht?
        	bne.s   change_to_dit_loop
        	move.l  #".DIT",(a5)+           ;in .DIT wandeln
        	clr.b   (a6)                    ;0-Byte 
        	clr.b   (a5)                    ;0-Byte     
        	clr.b   (a4)                    ;0-Byte


                bsr.s   file_lesen
                bsr	convert
                bsr     rotate
                bsr	file_schreiben

out
                clr.w   -(SP)
                trap    #1

;************************************************

usage_info
		pea	usage_text(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp

		move.w	#7,-(sp)
		trap	#1
		addq.w	#2,sp

		bra	out

usage_text	dc.b	"Usage: Input  xxxxxxxx.tpi",13,10
		dc.b	"       Output xxxxxxxx.dit",13,10,0
		even

;************************************************

file_lesen:     
                clr.w   -(SP)
                pea     tpi_filename(PC)
                move.w  #61,-(SP)
                trap    #1
                addq.l  #8,SP
                move.w  D0,D7

                pea     inbuffer(PC)
                move.l  #256*256*2+header,-(SP)
                move.w  D7,-(SP)
                move.w  #63,-(SP)
                trap    #1
                lea     12(SP),SP

                move.w  D7,-(SP)
                move.w  #62,-(SP)
                trap    #1
                addq.l  #4,SP

                rts

;************************************************
                
file_schreiben: 
                clr.w   -(SP)
                pea     dit_filename(PC)
                move.w  #60,-(SP)
                trap    #1
                addq.l  #8,SP
                move.w  D0,D7

                pea     outbuffer2
                move.l  #256*256*2,-(SP)
                move.w  D7,-(SP)
                move.w  #64,-(SP)
                trap    #1
                lea     12(SP),SP

                move.w  D7,-(SP)
                move.w  #62,-(SP)
                trap    #1
                addq.l  #4,SP

                rts

;************************************************
                
convert:        
                lea     inbuffer+header(PC),A0
                lea     outbuffer,A1

                move.w  #255,D0
convert_loop1:  move.w  #255,D1
convert_loop2:  move.w  (A0)+,D2
                move.b  D2,D5
                lsr.w   #5,D2
                move.b  D2,D4
                lsr.w   #6,D2
                move.b  D2,D3

                andi.w  #%0000000000011111,D5 ; blue
                andi.w  #%0000000000111111,D4 ; green
                andi.w  #%0000000000011111,D3 ; red

                lsr.w   #1,D4

                lsl.w   #8,D3
		lsl.w	#2,D3
                lsl.w   #5,D4
                add.w   D5,D3
                add.w   D4,D3

                move.w  D3,(A1)+

                dbra    D1,convert_loop2
                dbra    D0,convert_loop1
                
		rts
                
;************************************************

rotate:         
                lea     outbuffer,A0
                lea     outbuffer2,A1

                adda.l  #255*512,A0

                move.w  #255,D0
rot1:           movea.l A0,A2

                move.w  #255,D1
rot2:           move.w  (A2),(A1)+

                suba.l  #512,A2

                dbra    D1,rot2

                addq.l  #2,A0

                dbra    D0,rot1

                rts

;************************************************


                DATA

tpi_filename	ds.b	256
dit_filename	ds.b	256


                BSS

inbuffer:       DS.B header
                DS.B 256*256*2

outbuffer:      DS.B 256*256*2
outbuffer2:     DS.B 256*256*2


                END
