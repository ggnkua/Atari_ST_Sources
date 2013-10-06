

header          EQU 256         ; Truepaint = 128


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
        	lea     tru_filename(pc),a5
        	lea     tpi_filename(pc),a4
copy_command:
        	move.b  (a6),(a5)+              ;1 Zeichen rÅber
        	move.b  (a6)+,(a4)+
        	dbra    d0,copy_command
change_to_dit_loop:
        	cmp.b   #".",-(a5)              ;Punkt erreicht?
        	bne.s   change_to_dit_loop
		move.b	#".",(a5)+
		move.b	#"t",(a5)+
		move.b	#"p",(a5)+
		move.b	#"i",(a5)+
        	clr.b   (a6)                    ;0-Byte 
        	clr.b   (a5)                    ;0-Byte     
        	clr.b   (a4)                    ;0-Byte


                bsr.s   file_lesen
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

usage_text	dc.b	"Usage: Input  xxxxxxxx.tru (320x240)",13,10
		dc.b	"       Output xxxxxxxx.tpi",13,10,0
		even

;************************************************

file_lesen:     
                clr.w   -(SP)
                pea     tpi_filename(PC)
                move.w  #61,-(SP)
                trap    #1
                addq.l  #8,SP
                move.w  D0,D7

                pea     file
                move.l  #320*240*2+header,-(SP)
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
                pea     tru_filename
                move.w  #60,-(SP)
                trap    #1
                addq.l  #8,SP
                move.w  D0,D7

                pea    	indypaint
                move.l  #128,-(SP)
                move.w  D7,-(SP)
                move.w  #64,-(SP)
                trap    #1
                lea     12(SP),SP

                pea    	file+header
                move.l  #320*240*2,-(SP)
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


                DATA

tpi_filename	ds.b	256
tru_filename	ds.b	256

indypaint	incbin	"g:\running\tpi\320x240l.tpi"


                BSS

file		ds.b	header
		ds.b	320*240*2


                END
