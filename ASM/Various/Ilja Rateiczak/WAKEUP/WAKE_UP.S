; WAKE_UP 
; Version 1.0
; Copyrights by Ilja & Mitja Rateiczak 12.1993

.TEXT

; Speed auf maximum im Supervisormode

                          pea Speed
                          move.w #$38,-(sp)
		trap #14
		addq.l #2,sp
        		
; LautstÑrke- und Eingangspegeleinstellung fÅr Falcon030
	
		move.w #%01100000,-(sp) ;LautstÑrke links auf 9  ( 0 = 11110000)
		move.w #0,-(sp)         ;                    15 - 1  = 00010000              
		move.w #130,-(sp)       ;                    15 - 2  = 00100000 
		trap #14                ;                    15 - 4  = 01000000 
		add.l #6,sp             ;                    15 - 8  = 10000000 
		
		move.w #%01100000,-(sp) ;LautstÑrke rechts auf 9 (15 = 00000000)
		move.w #1,-(sp)
		move.w #130,-(sp)
		trap #14
		add.l #6,sp

		move.w #%00000000,-(sp) ;Eingangspegel links auf 0  ( 0 = 00000000)
		move.w #2,-(sp)         ;                       15 - 1  = 11100000   
		move.w #130,-(sp)       ;                       15 - 2  = 11010000 
		trap #14                ;                       15 - 4  = 10110000 
		add.l #6,sp             ;                       15 - 8  = 01110000 
		
		move.w #%00000000,-(sp) ;Eingangspegel rechts auf 0 (15 = 11110000)
		move.w #3,-(sp)
		move.w #130,-(sp)
		trap #14
		add.l #6,sp

; Textausgabe

        move.l #Text1,-(sp)
        move.w#9,-(sp)
        trap#1
        add.l#6,sp

; Programm beenden
		
		clr.w -(sp)             ;und Ende
		trap #1

; Pump up CPU

Speed:
                          bset #0,$ffff8007       ;CPU auf 16Mhz
		bset #2,$ffff8007       ;Blitter auf 16MHz
		move.l #$1111,d0        ;Alle Caches an
		movec d0,cacr           ;und auf Burst Mode!!!
                          rts                     ;zurÅck
		

.DATA

Text1:
        dc.b    $d, $a
        dc.b    $d, $a, $1b, $70, " WAKE_UP V1.0   CPU        16MHz ", $1b, $71  
        dc.b    $d, $a, $1b, $70, "                Blitter    16MHz ", $1b, $71
        dc.b    $d, $a, $1b, $70, "                Caches      ON   ", $1b, $71
        dc.b    $d, $a, $1b, $70, "                Volume out   9   ", $1b, $71
        dc.b    $d, $a, $1b, $70, "                Volume in    0   ", $1b, $71	
        dc.b    $d, $a,0
.END