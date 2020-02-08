***********************************************
; 		DMA SOUND MODPLAYER Abspielroutine
;
;			Grundfunktionen von CHECKSUM - EQUINOX
;
;			Erweiterungen:
;			
;			Lautst„rkenreglung
;			DMA Sound
;			div. Optimierungen
;
; 		K. R™MER und K.D. Pollack
;
:			

				EXPORT	PLAY

				TEXT

PLAY:		movem.l D0-A6,-(SP) 		;retten der Register
				movea.l A0,A6  
				clr.l 	-(SP)
				move.w  #$20,-(SP)  		;Umschalten in den Supervisormodus
				trap 	#1
				move.l  D0,2(SP)	
				clr.b   $FFFFFA09.w  		;interupt enable B l”schen 
									 							;Interupt Blitter,Tastatur,Schnittstellen etc. sperren 
				movea.l	A6,A0
				bsr 	mt_init
				
				
				lea		$FFFF8902.w,A0
				pea     puffer3(PC)
				move.b	1(SP),$01(A0)                
                move.b	2(SP),$03(A0)
                move.b	3(SP),$05(A0)
                addq.l	#8,(SP)
                move.b	1(SP),$0D(A0)
                move.b  2(SP),$0F(A0)
                move.b  3(SP),$11(A0)
                addq.l	#4,SP
				move.b	#2,$1F(A0)
				move.b	#3,-$1(A0)
				
				
key_wait:		cmp.b   #$39,$FFFFFC02.w 			;Wartet auf Space (Scancode $39)
						bne.s   key_wait							;Loop
						move    #$2700,SR 						;alle Interupts Sperren
				
				
						bsr.w	mt_end				
						move.b  #$64,$FFFFFA09.w 		;Interupts vom Interupt enable B wieder zulassen 
						move		#$2300,SR 					;interupt Maske wieder runtersetzen 
						move.w  #4000,D0
mfp_wait:		move.b  $FFFFFC02.w,D1
						dbra	D0,mfp_wait 				;Bitte warten (Tastatur Chip)
						trap 	#1									;zurck aus dem Supervisor (Stand noch auf dem Stack)
						addq.l 	#6,SP
						movem.l (SP)+,D0-A6 		;Register zurck
						rts 										;und wieder in's C Programm

				
; 4 Laust„rken fr 4 Stimmen 

level1:         DS.W 1 
level2:         DS.W 1
level3:         DS.W 1
level4:         DS.W 1

mt_init:		
				
                lea     mt_data(PC),A1 	;Musik Daten
                move.l  A0,(A1)  				;A0 ist jetzt dessen Adresse
                move.l  #472,D0 
                move.l  #600,D1
                cmpi.l  #$4D2E4B2E,1080(A0) ;berprfen welche Art 
                bne.s   mt_oldversion 			;neues oder altes Modul und entsprechend
                move.l  #$03B8,D0 					;den Quellcode
                move.l  #$043C,D1
mt_oldversion:
                lea     mt_nbr1(PC),A1 ;MODIFIZIEREN (nicht sehr fein)
                move.l  D0,2(A1) 		;aber sehr effektiv
                lea     mt_nbr2(PC),A1 
                move.l  D1,2(A1)
                lea     mt_nbr3(PC),A1
                move.l  D0,2(A1)
                lea     mt_nbr4(PC),A1
                move.l  D1,2(A1)
                adda.l  D0,A0
                moveq   #$7F,D0
                moveq   #0,D1
mt_init1:
                move.l  D1,D2 ;Z„hlregister anpassen
                subq.w  #1,D0 ;D0 um 1 erh”hen
mt_init2:
                move.b  (A0)+,D1 ;musicdaten
                cmp.b   D2,D1 ;Wenn D2 gr”žer D1
                bgt.s   mt_init1 ;gehe  mt_init1
                dbra    D0,mt_init2
                addq.b  #1,D2 ;erh”he D2 um eins

mt_init3:
                movea.l mt_data(PC),A0
                lea     mt_sample1(PC),A1
                asl.l   #8,D2
                asl.l   #2,D2
mt_nbr4:        add.l   #$12345678,D2
                add.l   A0,D2
                moveq   #30,D0
mt_init4:
                move.l  D2,(A1)+
                moveq   #0,D1
                move.w  42(A0),D1
                asl.l   #1,D1
                add.l   D1,D2
                adda.l  #30,A0
                dbra    D0,mt_init4
                movea.l D2,A1
                movea.l mt_sample1(PC),A0
mt_init5:
                eori.b  #128,(A0)
                tst.b   (A0)
                bne.s   mt_init6
                addq.b  #1,(A0)
mt_init6:
                addq.l  #1,A0
                cmpa.l  A0,A1
                bgt.s   mt_init5
                lea     mt_sample1(PC),A0
                moveq   #4,D0
mt_clear:
                movea.l 0(A0,D0.w),A1
                clr.l   -4(A1)
                addq.w  #4,D0
                cmp.w   #$7C,D0
                bne.s   mt_clear
                move    #$2700,SR
                lea     $FFFF8800.w,A0
                moveq   #10,D0
mt_yamahaclear:
                move.b  D0,(A0)
                clr.b   2(A0)
                dbra    D0,mt_yamahaclear
                clr.b   (A0)
                clr.b   2(A0)
                move.b  #7,(A0)
                move.b  #$FF,2(A0)
                move.b  #$08,$FFFA19
                move.b  #1,$FFFA1F
                bclr    #3,$FFFA17
                bset    #5,$FFFA07
                bset    #5,$FFFA13
                lea     timer_a(PC),A0
                move.l  A0,$0134.w
                lea     mt_partnrplay(PC),A0
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                clr.w   (A0)
                lea     mt_cool(PC),A0
                move.w  #6,2(A0)
                movea.l mt_data(PC),A0
mt_nbr3:        adda.l  #$12345678,A0
                lea     mt_maxpart(PC),A1
                move.b  -2(A0),1(A1)
                lea     mt_cool(PC),A0
                move.b  #6,3(A0)
                move.b  $FB0001,D7
                lea     no_noise(PC),A2
                lea     voice1(PC),A3
                lea     voice2(PC),A4
                lea     voice3(PC),A5
                lea     voice4(PC),A6
                move.l  A2,16(A3)
                move.l  A2,16(A4)
                move.l  A2,16(A5)
                move.l  A2,16(A6)
                movea.l A2,A3
                movea.l A3,A4
                movea.l A4,A5
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                lea     $FA0000,A6
                lea     mt_selection(PC),A0
                moveq   #0,D6
                move.b  D7,D6
                and.b   #$F0,D6
                cmp.b   #$70,D6
                bne.s   mt_testbat
                move.w  #$601A,(A0)
                move    #$2500,SR
                rts
mt_testbat:
                cmp.b   #$FF,D7
                beq.s   mt_monitor_outpout
                move.w  #$6024,(A0)
                move    #$2500,SR
                rts
mt_monitor_outpout:
                move.w  #$0246,(A0)
                move    #$2500,SR
                rts

mt_end:
                bset    #3,$FFFA17
                andi.b  #$DF,$FFFA07
                andi.b  #$DF,$FFFA13
                clr.b	$FFFF8901.w	
                rts



mt_music:
                movem.l D0-D1/A0-A1,-(SP) 	;rette Register
                lea     mt_counter(PC),A0		;Z„hler in A0  
                addq.w  #1,(A0) 						;Inhalt des Z„hlers um 1 Wort erh”hen
mt_cool:
                cmpi.w  #6,(A0) 				;ist der Z„hler 6 ?
                bne.s   mt_notsix 			;Nein dann gehe zu mt_notsix
                clr.w   (A0) 						;Inhalt des Z„hlers l”schen 
                bra.w   mt_rout2 				;Springe zu mt_rout2

mt_notsix:		
                lea     mt_aud1temp(PC),A1 	;Effekte !!! Zwischenspeicheraderesse in A1
                tst.b   3(A1) 							;testen und Statusregister setzen
                beq.s   mt_arp1 						;gleich null Appregiator 1 
                lea     voice1(PC),A0 		
                bsr.s   mt_arprout 			
mt_arp1:
                lea     mt_aud2temp(PC),A1
                tst.b   3(A1)
                beq.s   mt_arp2
                lea     voice2(PC),A0
                bsr.s   mt_arprout
mt_arp2:		
                lea     mt_aud3temp(PC),A1
                tst.b   3(A1)
                beq.s   mt_arp3
                lea     voice3(PC),A0
                bsr.s   mt_arprout
mt_arp3:
                lea     mt_aud4temp(PC),A1
                tst.b   3(A1)
                beq.s   mt_arp4
                lea     voice4(PC),A0
                bsr.s   mt_arprout
mt_arp4:
                movem.l (SP)+,D0-D1/A0-A1
                rts


mt_arprout:		
                move.b  2(A1),D0 
                and.b   #$0F,D0 			;wirlklich appregiato
                tst.b   D0 
                beq     mt_arpegrt 		;ja - dann mt_apegrt
                cmp.b   #1,D0 				;dann vieleicht portamento hoch
                beq     mt_portup 		;JA ?
                cmp.b   #2,D0  				;oder 
                beq     mt_portdown 	;portamento runter
                rts


mt_portup:  ;*Portamento Stimme zieht nach oben
                moveq   #0,D0  
                move.b  3(A1),D0
                sub.w   D0,22(A1) 						;hier neue Frequenz 
                cmpi.w  #$71,22(A1) 					;schon so hoch (Frequenz)
                bpl.s   mt_ok1 								;wenn positiv
                move.w  #$71,22(A1) 					;setzt Abbruchbedingung
mt_ok1:         move.w  22(A1),D0 						;setze Frequenz auf Abbruchbedingung
                lea     mt_frequences(PC),A1 	;Frequenztabelle in A1
                asl.l   #2,D0 								;Umrechnen fr die Denise Emulation
                move.l  0(A1,D0.w),2(A0)
                rts

mt_portdown: * Portamento Stimme zieht nach unten
                moveq   #0,D0
                move.b  3(A1),D0
                add.w   D0,22(A1) 			;hier neue Frequenz
                cmpi.w  #$0358,22(A1) 	;schon so tief (Frequenz)
                bmi.s   mt_ok2 					;wenn negativ
                move.w  #$0358,22(A1) 	;setze Frequenz auf Abbruchbedingung
mt_ok2:         bra.w   mt_ok1


mt_arpegrt:
                move.w  mt_counter(PC),D0
                cmp.w   #1,D0
                beq.s   mt_loop2
                cmp.w   #2,D0
                beq.s   mt_loop3
                cmp.w   #3,D0
                beq.s   mt_loop4
                cmp.w   #4,D0
                beq.s   mt_loop2
                cmp.w   #5,D0
                beq.s   mt_loop3
                rts

mt_loop2:
                moveq   #0,D0
                move.b  3(A1),D0
                lsr.b   #4,D0
                bra.s   mt_cont
mt_loop3:
                moveq   #0,D0
                move.b  3(A1),D0
                and.b   #$0F,D0
                bra.s   mt_cont
mt_loop4:
                moveq   #0,D1
                move.w  16(A1),D1
                bra.s   mt_endpart
mt_cont:
                add.w   D0,D0
                moveq   #0,D1
                move.w  16(A1),D1
                and.w   #$0FFF,D1
                lea     mt_arpeggio(PC),A1
mt_loop5:
                cmp.w   (A1),D1
                beq.s   loop5_exit
                addq.l  #2,A1
                bra.s   mt_loop5
loop5_exit:
                move.w  0(A1,D0.w),D1
mt_endpart:
                lea     mt_frequences(PC),A1
                asl.l   #2,D1
                move.l  0(A1,D1.w),2(A0)
                rts

mt_rout2:		movea.l mt_data(PC),A0
                lea     mt_soundpref(PC),A1
                move.l  A0,(A1)
                addi.l  #42,(A1)
                movea.l A0,A1
mt_nbr1:        adda.l  #$12345678,A1
mt_nbr2:        adda.l  #$12345678,A0
                move.l  A1,-(SP)
                lea     mt_firstpattern(PC),A1
                move.l  A0,(A1)
                movea.l (SP)+,A1
                moveq   #0,D1
                move.l  mt_partnrplay(PC),D0
                move.b  0(A1,D0.w),D1
                asl.l   #8,D1
                asl.l   #2,D1
                add.l   mt_partnote(PC),D1
                lea     mt_aud1temp(PC),A1
                bsr.w   mt_playit
                lea     mt_aud2temp(PC),A1
                move.l  mt_currentpos(PC),D1
                bsr.w   mt_playit
                lea     mt_aud3temp(PC),A1
                move.l  mt_currentpos(PC),D1
                bsr.w   mt_playit
                lea     mt_aud4temp(PC),A1
                move.l  mt_currentpos(PC),D1
                bsr.w   mt_playit
                move    #$2700,SR
mt_voice1:
                lea     voice1(PC),A0
                lea     mt_aud1temp(PC),A1
; here is for setting volume
				move.b	25(A1),27(A0)                
                
                tst.w   (A1)
                beq.s   mt_voice2
; here is for equa inf
                move.l  A0,-(SP)
                lea     level1(PC),A0
                move.w  18(A1),(A0)
                movea.l (SP)+,A0
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                move.w  D0,16(A1)
                move.w  D0,22(A1)
                movea.l 4(A1),A2
                moveq   #0,D2
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                asl.l   #2,D0
                move.l  A1,-(SP)
                lea     mt_frequences(PC),A1
                move.l  0(A1,D0.w),2(A0)
                movea.l (SP)+,A1
                tst.w   14(A1)
                beq.s   mt_norepeat1
                move.l  10(A1),16(A0)
                bra.s   mt_voice2
mt_norepeat1:
                lea     no_noise(PC),A1
                move.l  A1,16(A0)
mt_voice2:
                lea     voice2(PC),A0
                lea     mt_aud2temp(PC),A1
; here is for setting volume
				move.b	25(A1),27(A0)
                
                tst.w   (A1)
                beq.s   mt_voice3
; here is for equa inf
                move.l  A0,-(SP)
                lea     level2(PC),A0
                move.w  18(A1),(A0)
                movea.l (SP)+,A0
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                move.w  D0,16(A1)
                move.w  D0,22(A1)
                movea.l 4(A1),A3
                moveq   #0,D3
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                asl.l   #2,D0
                move.l  A1,-(SP)
                lea     mt_frequences(PC),A1
                move.l  0(A1,D0.w),2(A0)
                movea.l (SP)+,A1
                tst.w   14(A1)
                beq.s   mt_norepeat2
                move.l  10(A1),16(A0)
                bra.s   mt_voice3
mt_norepeat2:
                lea     no_noise(PC),A1
                move.l  A1,16(A0)
mt_voice3:
                lea     voice3(PC),A0
                lea     mt_aud3temp(PC),A1
; here is for setting volume
				move.b	25(A1),27(A0)

                tst.w   (A1)
                beq.s   mt_voice4
; here is for equa inf
                move.l  A0,-(SP)
                lea     level3(PC),A0
                move.w  18(A1),(A0)
                movea.l (SP)+,A0
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                move.w  D0,16(A1)
                move.w  D0,22(A1)
                movea.l 4(A1),A4
                moveq   #0,D4
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                asl.l   #2,D0
                move.l  A1,-(SP)
                lea     mt_frequences(PC),A1
                move.l  0(A1,D0.w),2(A0)
                movea.l (SP)+,A1
                tst.w   14(A1)
                beq.s   mt_norepeat3
                move.l  10(A1),16(A0)
                bra.s   mt_voice4
mt_norepeat3:
                lea     no_noise(PC),A1
                move.l  A1,16(A0)
mt_voice4:
                lea     voice4(PC),A0
                lea     mt_aud4temp(PC),A1
; here  is for setting volume
				move.b	25(A1),27(A0)

                tst.w   (A1)
                beq.s   mt_voice0
; here is for equa inf
                move.l  A0,-(SP)
                lea     level4(PC),A0
                move.w  18(A1),(A0)
                movea.l (SP)+,A0
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                move.w  D0,16(A1)
                move.w  D0,22(A1)
                movea.l 4(A1),A5
                moveq   #0,D5
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                asl.l   #2,D0
                move.l  A1,-(SP)
                lea     mt_frequences(PC),A1
                move.l  0(A1,D0.w),2(A0)
                movea.l (SP)+,A1
                tst.w   14(A1)
                beq.s   mt_norepeat4
                move.l  10(A1),16(A0)
                bra.s   mt_voice0
mt_norepeat4:
                lea     no_noise(PC),A1
                move.l  A1,16(A0)
mt_voice0:
; here is for setting volume 
				
				lea		setvol1+2(PC),A1
				move.w	#128*2,(A1)
				lea 	VOLUME(PC),A0
				moveq	#0,D0
				moveq	#127,D1
				add.w	mt_aud1temp+24(PC),D1
				move.b	0(A0,D1.w),D0
				sub.w	D0,(A1)
				moveq	#127,D1
				add.w	mt_aud2temp+24(PC),D1
				move.b	0(A0,D1.w),D0
				sub.w	D0,(A1)
				
				lea		setvol2+2(PC),A1
				move.w	#128*2,(A1)
				moveq	#0,D0
				moveq	#127,D1
				add.w	mt_aud3temp+24(PC),D1
				move.b	0(A0,D1.w),D0
				sub.w	D0,(A1)
				moveq	#127,D1
				add.w	mt_aud4temp+24(PC),D1
				move.b	0(A0,D1.w),D0
				sub.w	D0,(A1)
				


                move    #$2400,SR
                lea     mt_partnote(PC),A0
                addi.l  #16,(A0)
                cmpi.l  #64*16,(A0)
                bne     mt_nonewpat
mt_higher:
                clr.l   (A0)
                lea     mt_partnrplay(PC),A0
                addq.l  #1,(A0)
                moveq   #0,D0
                move.w  mt_maxpart(PC),D0
                move.l  (A0),D1
                cmp.l   D0,D1
                bne.s   mt_nonewpat
                clr.l   (A0)
mt_nonewpat:
                lea     mt_status(PC),A0
                tst.w   (A0)
                beq.s   mt_stop
                clr.w   (A0)
                lea     mt_partnote(PC),A0
                bra.s   mt_higher
mt_stop:
                movem.l (SP)+,D0-D1/A0-A1
                rts


mt_playit: * Sequenzer
                movea.l mt_firstpattern(PC),A0
                move.l  0(A0,D1.l),(A1)
                addq.l  #4,D1
                lea     mt_currentpos(PC),A0
                move.l  D1,(A0)
                moveq   #0,D1
                move.b  2(A1),D1
                lsr.b   #4,D1
                moveq   #0,D0
                move.b  (A1),D0
                and.b   #$F0,D0
                or.b    D0,D1
                tst.b   D1
                beq.w   mt_nosamplechange
                move.l  D1,D0
                asl.l   #2,D1
                subq.b  #1,D0
                mulu    #30,D0
                lea     mt_samples(PC),A0
                move.l  0(A0,D1.l),4(A1)
                movea.l mt_soundpref(PC),A0
                move.w  0(A0,D0.l),8(A1)
                tst.w   8(A1)
                bne.s   mt_sample_exist
                move.l  A0,-(SP)
                lea     no_noise(PC),A0
                move.l  A0,4(A1)
                movea.l (SP)+,A0
mt_sample_exist:
                moveq   #0,D1
                move.w  4(A0,D0.l),D1
                add.l   4(A1),D1
                move.l  D1,10(A1)
                move.w  6(A0,D0.l),14(A1)
                move.w  2(A0,D0.l),18(A1)
                cmpi.w  #1,14(A1)
                bne.w   mt_nosamplechange
                clr.w   14(A1)
mt_nosamplechange:
                moveq   #0,D0
                move.b  2(A1),D0
                and.w   #$0F,D0
                cmp.b   #$0B,D0
                beq.s   mt_posjmp
                cmp.b   #$0C,D0
                beq.s   mt_setvol
                cmp.b   #$0D,D0
                beq.s   mt_break
                cmp.b   #$0E,D0
                beq.s   mt_setfil
                cmp.b   #$0F,D0
                beq.s   mt_setspeed
                rts

mt_posjmp:
                lea     mt_status(PC),A0
                not.w   (A0)
                moveq   #0,D0
                move.b  3(A1),D0
                subq.b  #1,D0
                lea     mt_partnrplay(PC),A0
                move.l  D0,(A0)
                rts

mt_setvol:
; perhaps another time
                moveq   #0,D0
                move.b  3(A1),D0
                tst.b   D0
                bne.s   mt_vol
                lea     no_noise(PC),A0
                move.l  A0,4(A1)
                move.w  #1,(A1)
                rts
                
mt_vol:			lsl.b 	#2,D0
				sub.b   #128,D0
				ext.w	D0
				move.w 	D0,24(A1)
				rts
                

mt_break:
                lea     mt_status(PC),A0
                not.w   (A0)
                rts
mt_setfil:
; a filter ?? i would like have it !!!!
                
                rts

mt_setspeed:		move.b  3(A1),D0
                and.b   #$0F,D0
                beq.s   mt_back
                lea     mt_counter(PC),A0
                clr.w   (A0)
                lea     mt_cool(PC),A0
                move.b  D0,3(A0)
mt_back:        rts



;this is the emulation of amiga sound processor !


****************Timer A********************************************************
; Fllen der Puffer fr den DMA Sound



timer_a:        lea     _status(PC),A0
                not.w   (A0)
                lea 	$FFFF8902.w,A0
                lea		VOLUME(PC),A1
                beq.s   _puf2

_puf1:          lea		puffer2(PC),A6
                bsr		puf_fill
                bsr		mt_music
				
								pea     puffer2(PC)
								move.b	1(SP),$01(A0)                
                
                move.b	2(SP),$03(A0)
                move.b	3(SP),$05(A0)
                addi.l	#1000,(SP)
                move.b	1(SP),$0D(A0)
                move.b  2(SP),$0F(A0)
                move.b  3(SP),$11(A0)
                addq.l	#4,SP
				
								rte

_puf2:          lea		puffer1(PC),A6
								
								bsr		puf_fill
								bsr		mt_music
				
								pea  	puffer1(PC)
								move.b	1(SP),$01(A0)                
      
                move.b	2(SP),$03(A0)
                move.b	3(SP),$05(A0)
                addi.l	#1000,(SP)
                move.b	1(SP),$0D(A0)
                move.b  2(SP),$0F(A0)
                move.b  3(SP),$11(A0)
                addq.l	#4,SP
                rte

puf_fill:       move.w  #499,D0

denise:			


setvol1:				move.w	#$1234,D6
								moveq	#0,D7		

voice3:         add.l   #$12345678,D4           ;16
                swap    D4              ; 4
                move.b  0(A4,D4.w),D7   ;12
                bne.s   no_ini3         ; 8
                lea     $12345678,A4    ;12
                moveq   #0,D4           ; 4
                moveq   #$7F,D7         ; 4

no_ini3:        move.b	124(A1,D7.w),D7
								add.w   D7,D6   
								 
voice2:         add.l   #$12345678,D3           ;16
                swap    D3              ; 4
                move.b  0(A3,D3.w),D7   ;12
                bne.s   no_ini2         ; 8
                lea     $12345678,A3    ;12
                moveq   #0,D3           ; 4
                moveq   #$7F,D7         ; 4
no_ini2:        move.b	124(A1,D7.w),D7				
								add.w   D7,D6           ;                				

        	      
       	      	lsr.w  	#1,D6           ; 8
                sub.b	#128,D6
                move.b  D6,(A6)+        ; 8                  	      

setvol2:				move.w	#$1234,D6
 								moveq	#0,D7	
							
voice1:         add.l   #$12345678,D2           ;16
                swap    D2              ; 4
                move.b  0(A2,D2.w),D7   ;12
                bne.s   no_ini1         ; 8
                lea     $12345678,A2    ;12
                moveq   #0,D2           ; 4
                moveq   #$7F,D7         ; 4

no_ini1:				move.b	124(A1,D7.w),D7
								add.w	D7,D6              

voice4:         add.l   #$12345678,D5           ;16
                swap    D5              ; 4
                move.b  0(A5,D5.w),D7   ;12
                bne.s   no_ini4         ; 8
                lea     $12345678,A5    ;12
                moveq   #0,D5           ; 4
                moveq   #$7F,D7         ; 4
no_ini4:        move.b	124(A1,D7.w),D7
								
								add.w   D7,D6           ; 4
                
                lsr.w  	#1,D6           ; 8
                sub.b	#128,D6
                move.b  D6,(A6)+        ; 8

                swap    D2              ; 4
                swap    D3              ; 4
                swap    D4              ; 4
                swap    D5              ; 4
                dbra    D0,denise
                rts                     ;-------> 316 ???

_status:		dc.w	0
********************************************************************************
mt_selection:
                and.w   #$FFFC,D6
                rte
*******************************************************************************


                DC.B $00,$00,$00,$00,$00,$00,$00,$00
                DC.B $00,$00,$00,$00,$00,$00,$00,$00
                DC.B $00,$00,$00,$00,$01,$01,$01,$01
                DC.B $01,$01,$01,$01,$01,$01,$01,$01
                DC.B $01,$01,$01,$01,$01,$01,$01,$01
                DC.B $02,$02,$02,$02,$02,$02,$02,$02
                DC.B $02,$02,$02,$02,$02,$02,$03,$03
                DC.B $03,$03,$03,$03,$03,$03,$03,$03
                DC.B $04,$04,$04,$04,$04,$04,$04,$04
                DC.B $05,$05,$05,$05,$05,$05,$06,$06
                DC.B $06,$06,$07,$07,$07,$07,$08,$08
                DC.B $08,$08,$08,$09,$09,$09,$09,$09
                DC.B $0A,$0A,$0A,$0A,$0A,$0B,$0B,$0B
                DC.B $0B,$0B,$0C,$0C,$0C,$0C,$0D,$0D
                DC.B $0D,$0D,$0D,$0E,$0E,$0E,$0E,$0E
                DC.B $0F,$0F,$0F,$10,$10,$10,$10,$11
VOLUME:         DC.B $11,$11,$12,$12,$12,$12,$13,$13
                DC.B $13,$13,$14,$14,$14,$15,$15,$15
                DC.B $16,$16,$16,$16,$17,$17,$17,$17
                DC.B $18,$18,$18,$18,$19,$19,$19,$1A
                DC.B $1A,$1A,$1B,$1B,$1B,$1C,$1C,$1C
                DC.B $1D,$1D,$1D,$1E,$1E,$1E,$1F,$1F
                DC.B $1F,$20,$20,$20,$21,$21,$22,$22
                DC.B $22,$23,$23,$23,$24,$24,$25,$25
                DC.B $25,$26,$26,$27,$27,$27,$28,$28
                DC.B $28,$29,$29,$2A,$2A,$2B,$2B,$2B
                DC.B $2C,$2C,$2D,$2D,$2D,$2E,$2E,$2F
                DC.B $2F,$2F,$30,$30,$31,$31,$32,$32
                DC.B $32,$33,$33,$34,$34,$35,$35,$36
                DC.B $36,$37,$37,$38,$38,$39,$39,$3A
                DC.B $3A,$3B,$3B,$3C,$3C,$3D,$3D,$3E
                DC.B $3E,$3F,$3F,$40,$40,$41,$41,$42
                DC.B $42,$43,$43,$44,$44,$45,$45,$46
                DC.B $46,$47,$47,$48,$48,$49,$49,$4A
                DC.B $4B,$4B,$4C,$4C,$4D,$4D,$4E,$4F
                DC.B $4F,$50,$50,$51,$51,$52,$52,$53
                DC.B $54,$54,$55,$55,$56,$56,$57,$57
                DC.B $58,$59,$59,$5A,$5A,$5B,$5C,$5C
                DC.B $5D,$5E,$5E,$5F,$5F,$60,$61,$61
                DC.B $62,$63,$63,$64,$64,$65,$66,$66
                DC.B $67,$67,$68,$69,$69,$6A,$6B,$6B
                DC.B $6C,$6D,$6D,$6E,$6F,$6F,$70,$71
                DC.B $71,$72,$73,$73,$74,$75,$75,$76
                DC.B $77,$77,$78,$79,$7A,$7A,$7B,$7C
                DC.B $7C,$7D,$7E,$7E,$7F,$80,$80,$81
                DC.B $82,$83,$83,$84,$85,$85,$86,$87
                DC.B $87,$88,$89,$89,$8A,$8B,$8C,$8D
                DC.B $8D,$8E,$8F,$8F,$90,$91,$92,$93
                DC.B $93,$94,$95,$96,$96,$97,$98,$99
                DC.B $9A,$9A,$9B,$9C,$9D,$9D,$9E,$9F
                DC.B $A0,$A1,$A1,$A2,$A3,$A4,$A5,$A6
                DC.B $A7,$A8,$A9,$AA,$AB,$AB,$AC,$AD
                DC.B $AE,$AF,$AF,$B0,$B1,$B2,$B3,$B3
                DC.B $B4,$B5,$B6,$B6,$B7,$B8,$B9,$BA
                DC.B $BB,$BC,$BD,$BD,$BE,$BF,$C0,$C1
                DC.B $C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8
                DC.B $C9,$CA,$CB,$CB,$CC,$CD,$CE,$CF
                DC.B $D0,$D1,$D1,$D2,$D3,$D4,$D5,$D6
                DC.B $D7,$D8,$D9,$D9,$DA,$DB,$DC,$DD
                DC.B $DE,$DF,$E0,$E0,$E1,$E2,$E3,$E4
                DC.B $E5,$E6,$E7,$E8,$E8,$E9,$EA,$EB
                DC.B $EC,$ED,$EE,$EF,$F0,$F1,$F2,$F3
                DC.B $F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB
                DC.B $FC,$FD,$FE,$FF


                EVEN
mt_aud1temp:    DS.B 26
mt_aud2temp:    DS.B 26
mt_aud3temp:    DS.B 26
mt_aud4temp:    DS.B 26
mt_partnrplay:  DS.L 1
mt_partnote:    DS.L 1
mt_firstpattern:DS.L 1
mt_counter:     DS.W 1
mt_samples:     DS.L 1
mt_sample1:     DS.L 31
mt_maxpart:     DS.W 1
mt_status:      DS.W 1
mt_register:    DS.L 1
mt_currentpos:  DS.L 1
mt_soundpref:   DS.L 1
mt_debpat:      DS.L 1
mt_data:        DS.L 1
mt_adrsave:     DS.L 1
mt_arpeggio:    DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C
                DC.W $023A,$021A,$01FC,$01E0,$01C5,$01AC,$0194,$017D
                DC.W $0168,$0153,$0140,$012E,$011D,$010D,$FE,$F0
                DC.W $E2,$D6,$CA,$BE,$B4,$AA,$A0,$97
                DC.W $8F,$87,$7F,$78,$71,$00,$00,$00
no_noise:
                REPT 512
                DC.L $7F7F7F7F
                ENDM
                DC.L 0
mt_frequences: ;25 kHz TT/Falcon
                DC.L 0
				dc.w	$0000,$0000,$0048,$1909,$0030,$10B0,$0024,$0C84 
				dc.w	$001C,$D6D0,$0018,$0858,$0014,$9970,$0012,$0642 
				dc.w	$0010,$0590,$000E,$6B68,$000D,$1BD3,$000C,$042C 
				dc.w	$000B,$178B,$000A,$4CB8,$0009,$9CF0,$0009,$0321 
				dc.w	$0008,$7B6A,$0008,$02C8,$0007,$96D8,$0007,$35B4 
				dc.w	$0006,$DDD0,$0006,$8DE9,$0006,$44F5,$0006,$0216 
				dc.w	$0005,$C490,$0005,$8BC5,$0005,$5730,$0005,$265C 
				dc.w	$0004,$F8E6,$0004,$CE78,$0004,$A6C6,$0004,$8190 
				dc.w	$0004,$5E9B,$0004,$3DB5,$0004,$1EB0,$0004,$0164 
				dc.w	$0003,$E5AD,$0003,$CB6C,$0003,$B283,$0003,$9ADA 
				dc.w	$0003,$8457,$0003,$6EE8,$0003,$5A77,$0003,$46F4 
				dc.w	$0003,$3450,$0003,$227A,$0003,$1167,$0003,$010B 
				dc.w	$0002,$F159,$0002,$E248,$0002,$D3CE,$0002,$C5E2 
				dc.w	$0002,$B87D,$0002,$AB98,$0002,$9F2A,$0002,$932E 
				dc.w	$0002,$879D,$0002,$7C73,$0002,$71A9,$0002,$673C 
				dc.w	$0002,$5D26,$0002,$5363,$0002,$49F0,$0002,$40C8 
				dc.w	$0002,$37E8,$0002,$2F4D,$0002,$26F4,$0002,$1EDA 
				dc.w	$0002,$16FC,$0002,$0F58,$0002,$07EA,$0002,$00B2 
				dc.w	$0001,$F9AC,$0001,$F2D6,$0001,$EC30,$0001,$E5B6 
				dc.w	$0001,$DF67,$0001,$D941,$0001,$D344,$0001,$CD6D 
				dc.w	$0001,$C7BA,$0001,$C22B,$0001,$BCBF,$0001,$B774 
				dc.w	$0001,$B248,$0001,$AD3B,$0001,$A84C,$0001,$A37A 
				dc.w	$0001,$9EC3,$0001,$9A28,$0001,$95A6,$0001,$913D 
				dc.w	$0001,$8CEC,$0001,$88B3,$0001,$8491,$0001,$8085 
				dc.w	$0001,$7C8E,$0001,$78AC,$0001,$74DE,$0001,$7124 
				dc.w	$0001,$6D7C,$0001,$69E7,$0001,$6663,$0001,$62F1 
				dc.w	$0001,$5F90,$0001,$5C3E,$0001,$58FD,$0001,$55CC 
				dc.w	$0001,$52A9,$0001,$4F95,$0001,$4C8F,$0001,$4997 
				dc.w	$0001,$46AC,$0001,$43CE,$0001,$40FD,$0001,$3E39 
				dc.w	$0001,$3B81,$0001,$38D4,$0001,$3633,$0001,$339E 
				dc.w	$0001,$3113,$0001,$2E93,$0001,$2C1D,$0001,$29B1 
				dc.w	$0001,$2750,$0001,$24F8,$0001,$22A9,$0001,$2064 
				dc.w	$0001,$1E27,$0001,$1BF4,$0001,$19C9,$0001,$17A6 
				dc.w	$0001,$158C,$0001,$137A,$0001,$1170,$0001,$0F6D 
				dc.w	$0001,$0D72,$0001,$0B7E,$0001,$0991,$0001,$07AC 
				dc.w	$0001,$05CD,$0001,$03F5,$0001,$0223,$0001,$0059 
				dc.w	$0000,$FE94,$0000,$FCD6,$0000,$FB1D,$0000,$F96B 
				dc.w	$0000,$F7BE,$0000,$F618,$0000,$F476,$0000,$F2DB 
				dc.w	$0000,$F144,$0000,$EFB3,$0000,$EE27,$0000,$ECA0 
				dc.w	$0000,$EB1F,$0000,$E9A2,$0000,$E829,$0000,$E6B6 
				dc.w	$0000,$E547,$0000,$E3DD,$0000,$E277,$0000,$E115 
				dc.w	$0000,$DFB8,$0000,$DE5F,$0000,$DD0A,$0000,$DBBA 
				dc.w	$0000,$DA6D,$0000,$D924,$0000,$D7DF,$0000,$D69D 
				dc.w	$0000,$D560,$0000,$D426,$0000,$D2F0,$0000,$D1BD 
				dc.w	$0000,$D08D,$0000,$CF61,$0000,$CE39,$0000,$CD14 
				dc.w	$0000,$CBF1,$0000,$CAD3,$0000,$C9B7,$0000,$C89E 
				dc.w	$0000,$C789,$0000,$C676,$0000,$C566,$0000,$C459 
				dc.w	$0000,$C350,$0000,$C248,$0000,$C144,$0000,$C042 
				dc.w	$0000,$BF43,$0000,$BE47,$0000,$BD4D,$0000,$BC56 
				dc.w	$0000,$BB61,$0000,$BA6F,$0000,$B97F,$0000,$B892 
				dc.w	$0000,$B7A6,$0000,$B6BE,$0000,$B5D7,$0000,$B4F3 
				dc.w	$0000,$B411,$0000,$B331,$0000,$B254,$0000,$B178 
				dc.w	$0000,$B09F,$0000,$AFC8,$0000,$AEF2,$0000,$AE1F 
				dc.w	$0000,$AD4E,$0000,$AC7E,$0000,$ABB1,$0000,$AAE6 
				dc.w	$0000,$AA1C,$0000,$A954,$0000,$A88E,$0000,$A7CA 
				dc.w	$0000,$A708,$0000,$A647,$0000,$A588,$0000,$A4CB 
				dc.w	$0000,$A410,$0000,$A356,$0000,$A29D,$0000,$A1E7 
				dc.w	$0000,$A132,$0000,$A07E,$0000,$9FCD,$0000,$9F1C 
				dc.w	$0000,$9E6D,$0000,$9DC0,$0000,$9D14,$0000,$9C6A 
				dc.w	$0000,$9BC1,$0000,$9B19,$0000,$9A73,$0000,$99CF 
				dc.w	$0000,$992B,$0000,$9889,$0000,$97E8,$0000,$9749 
				dc.w	$0000,$96AB,$0000,$960E,$0000,$9573,$0000,$94D8 
				dc.w	$0000,$943F,$0000,$93A8,$0000,$9311,$0000,$927C 
				dc.w	$0000,$91E7,$0000,$9154,$0000,$90C2,$0000,$9032 
				dc.w	$0000,$8FA2,$0000,$8F13,$0000,$8E86,$0000,$8DFA 
				dc.w	$0000,$8D6E,$0000,$8CE4,$0000,$8C5B,$0000,$8BD3 
				dc.w	$0000,$8B4C,$0000,$8AC6,$0000,$8A41,$0000,$89BD 
				dc.w	$0000,$893A,$0000,$88B8,$0000,$8836,$0000,$87B6 
				dc.w	$0000,$8737,$0000,$86B9,$0000,$863B,$0000,$85BF 
				dc.w	$0000,$8543,$0000,$84C8,$0000,$844E,$0000,$83D6 
				dc.w	$0000,$835D,$0000,$82E6,$0000,$8270,$0000,$81FA 
				dc.w	$0000,$8185,$0000,$8111,$0000,$809E,$0000,$802C 
				dc.w	$0000,$7FBA,$0000,$7F4A,$0000,$7EDA,$0000,$7E6B 
				dc.w	$0000,$7DFC,$0000,$7D8E,$0000,$7D21,$0000,$7CB5 
				dc.w	$0000,$7C4A,$0000,$7BDF,$0000,$7B75,$0000,$7B0C 
				dc.w	$0000,$7AA3,$0000,$7A3B,$0000,$79D4,$0000,$796D 
				dc.w	$0000,$7907,$0000,$78A2,$0000,$783D,$0000,$77D9 
				dc.w	$0000,$7776,$0000,$7713,$0000,$76B1,$0000,$7650 
				dc.w	$0000,$75EF,$0000,$758F,$0000,$7530,$0000,$74D1 
				dc.w	$0000,$7472,$0000,$7414,$0000,$73B7,$0000,$735B 
				dc.w	$0000,$72FF,$0000,$72A3,$0000,$7248,$0000,$71EE 
				dc.w	$0000,$7194,$0000,$713B,$0000,$70E3,$0000,$708A 
				dc.w	$0000,$7033,$0000,$6FDC,$0000,$6F85,$0000,$6F2F 
				dc.w	$0000,$6EDA,$0000,$6E85,$0000,$6E30,$0000,$6DDD 
				dc.w	$0000,$6D89,$0000,$6D36,$0000,$6CE4,$0000,$6C92 
				dc.w	$0000,$6C40,$0000,$6BEF,$0000,$6B9F,$0000,$6B4E 
				dc.w	$0000,$6AFF,$0000,$6AB0,$0000,$6A61,$0000,$6A13 
				dc.w	$0000,$69C5,$0000,$6978,$0000,$692B,$0000,$68DE 
				dc.w	$0000,$6892,$0000,$6846,$0000,$67FB,$0000,$67B0 
				dc.w	$0000,$6766,$0000,$671C,$0000,$66D3,$0000,$668A 
				dc.w	$0000,$6641,$0000,$65F8,$0000,$65B1,$0000,$6569 
				dc.w	$0000,$6522,$0000,$64DB,$0000,$6495,$0000,$644F 
				dc.w	$0000,$6409,$0000,$63C4,$0000,$637F,$0000,$633B 
				dc.w	$0000,$62F7,$0000,$62B3,$0000,$6270,$0000,$622C 
				dc.w	$0000,$61EA,$0000,$61A8,$0000,$6166,$0000,$6124 
				dc.w	$0000,$60E3,$0000,$60A2,$0000,$6061,$0000,$6021 
				dc.w	$0000,$5FE1,$0000,$5FA1,$0000,$5F62,$0000,$5F23 
				dc.w	$0000,$5EE5,$0000,$5EA6,$0000,$5E68,$0000,$5E2B 
				dc.w	$0000,$5DED,$0000,$5DB0,$0000,$5D74,$0000,$5D37 
				dc.w	$0000,$5CFB,$0000,$5CBF,$0000,$5C84,$0000,$5C49 
				dc.w	$0000,$5C0E,$0000,$5BD3,$0000,$5B99,$0000,$5B5F 
				dc.w	$0000,$5B25,$0000,$5AEB,$0000,$5AB2,$0000,$5A79 
				dc.w	$0000,$5A41,$0000,$5A08,$0000,$59D0,$0000,$5998 
				dc.w	$0000,$5961,$0000,$592A,$0000,$58F3,$0000,$58BC 
				dc.w	$0000,$5885,$0000,$584F,$0000,$5819,$0000,$57E4 
				dc.w	$0000,$57AE,$0000,$5779,$0000,$5744,$0000,$570F 
				dc.w	$0000,$56DB,$0000,$56A7,$0000,$5673,$0000,$563F 
				dc.w	$0000,$560B,$0000,$55D8,$0000,$55A5,$0000,$5573 
				dc.w	$0000,$5540,$0000,$550E,$0000,$54DC,$0000,$54AA 
				dc.w	$0000,$5478,$0000,$5447,$0000,$5416,$0000,$53E5 
				dc.w	$0000,$53B4,$0000,$5384,$0000,$5353,$0000,$5323 
				dc.w	$0000,$52F3,$0000,$52C4,$0000,$5294,$0000,$5265 
				dc.w	$0000,$5236,$0000,$5208,$0000,$51D9,$0000,$51AB 
				dc.w	$0000,$517C,$0000,$514E,$0000,$5121,$0000,$50F3 
				dc.w	$0000,$50C6,$0000,$5099,$0000,$506C,$0000,$503F 
				dc.w	$0000,$5012,$0000,$4FE6,$0000,$4FBA,$0000,$4F8E 
				dc.w	$0000,$4F62,$0000,$4F36,$0000,$4F0B,$0000,$4EE0 
				dc.w	$0000,$4EB5,$0000,$4E8A,$0000,$4E5F,$0000,$4E35 
				dc.w	$0000,$4E0A,$0000,$4DE0,$0000,$4DB6,$0000,$4D8C 
				dc.w	$0000,$4D63,$0000,$4D39,$0000,$4D10,$0000,$4CE7 
				dc.w	$0000,$4CBE,$0000,$4C95,$0000,$4C6D,$0000,$4C44 
				dc.w	$0000,$4C1C,$0000,$4BF4,$0000,$4BCC,$0000,$4BA4 
				dc.w	$0000,$4B7D,$0000,$4B55,$0000,$4B2E,$0000,$4B07 
				dc.w	$0000,$4AE0,$0000,$4AB9,$0000,$4A92,$0000,$4A6C 
				dc.w	$0000,$4A46,$0000,$4A1F,$0000,$49F9,$0000,$49D4 
				dc.w	$0000,$49AE,$0000,$4988,$0000,$4963,$0000,$493E 
				dc.w	$0000,$4918,$0000,$48F3,$0000,$48CF,$0000,$48AA 
				dc.w	$0000,$4885,$0000,$4861,$0000,$483D,$0000,$4819 
				dc.w	$0000,$47F5,$0000,$47D1,$0000,$47AD,$0000,$4789 
				dc.w	$0000,$4766,$0000,$4743,$0000,$4720,$0000,$46FD 
				dc.w	$0000,$46DA,$0000,$46B7,$0000,$4694,$0000,$4672 
				dc.w	$0000,$4650,$0000,$462D,$0000,$460B,$0000,$45E9 
				dc.w	$0000,$45C7,$0000,$45A6,$0000,$4584,$0000,$4563 
				dc.w	$0000,$4541,$0000,$4520,$0000,$44FF,$0000,$44DE 
				dc.w	$0000,$44BD,$0000,$449D,$0000,$447C,$0000,$445C 
				dc.w	$0000,$443B,$0000,$441B,$0000,$43FB,$0000,$43DB 
				dc.w	$0000,$43BB,$0000,$439B,$0000,$437C,$0000,$435C 
				dc.w	$0000,$433D,$0000,$431D,$0000,$42FE,$0000,$42DF 
				dc.w	$0000,$42C0,$0000,$42A1,$0000,$4283,$0000,$4264 
				dc.w	$0000,$4245,$0000,$4227,$0000,$4209,$0000,$41EB 
				dc.w	$0000,$41CC,$0000,$41AE,$0000,$4191,$0000,$4173 
				dc.w	$0000,$4155,$0000,$4138,$0000,$411A,$0000,$40FD 
				dc.w	$0000,$40E0,$0000,$40C2,$0000,$40A5,$0000,$4088 
				dc.w	$0000,$406C,$0000,$404F,$0000,$4032,$0000,$4016 
				dc.w	$0000,$3FF9,$0000,$3FDD,$0000,$3FC1,$0000,$3FA5 
				dc.w	$0000,$3F89,$0000,$3F6D,$0000,$3F51,$0000,$3F35 
				dc.w	$0000,$3F19,$0000,$3EFE,$0000,$3EE2,$0000,$3EC7 
				dc.w	$0000,$3EAC,$0000,$3E90,$0000,$3E75,$0000,$3E5A 
				dc.w	$0000,$3E3F,$0000,$3E25,$0000,$3E0A,$0000,$3DEF 
				dc.w	$0000,$3DD5,$0000,$3DBA,$0000,$3DA0,$0000,$3D86 
				dc.w	$0000,$3D6B,$0000,$3D51,$0000,$3D37,$0000,$3D1D 
				dc.w	$0000,$3D03,$0000,$3CEA,$0000,$3CD0,$0000,$3CB6 
				dc.w	$0000,$3C9D,$0000,$3C83,$0000,$3C6A,$0000,$3C51 
				dc.w	$0000,$3C37,$0000,$3C1E,$0000,$3C05,$0000,$3BEC 
				dc.w	$0000,$3BD4,$0000,$3BBB,$0000,$3BA2,$0000,$3B89 
				dc.w	$0000,$3B71,$0000,$3B58,$0000,$3B40,$0000,$3B28 
				dc.w	$0000,$3B10,$0000,$3AF7,$0000,$3ADF,$0000,$3AC7 
				dc.w	$0000,$3AAF,$0000,$3A98,$0000,$3A80,$0000,$3A68 
				dc.w	$0000,$3A50,$0000,$3A39,$0000,$3A21,$0000,$3A0A 
				dc.w	$0000,$39F3,$0000,$39DB,$0000,$39C4,$0000,$39AD 
				dc.w	$0000,$3996,$0000,$397F,$0000,$3968,$0000,$3951 
				dc.w	$0000,$393B,$0000,$3924,$0000,$390D,$0000,$38F7 
				dc.w	$0000,$38E0,$0000,$38CA,$0000,$38B4,$0000,$389D 
				dc.w	$0000,$3887,$0000,$3871,$0000,$385B,$0000,$3845 
				dc.w	$0000,$382F,$0000,$3819,$0000,$3803,$0000,$37EE 
				dc.w	$0000,$37D8,$0000,$37C2,$0000,$37AD,$0000,$3797 
				dc.w	$0000,$3782,$0000,$376D,$0000,$3757,$0000,$3742 
				dc.w	$0000,$372D,$0000,$3718,$0000,$3703,$0000,$36EE 
				dc.w	$0000,$36D9,$0000,$36C4,$0000,$36B0,$0000,$369B 
				dc.w	$0000,$3686,$0000,$3672,$0000,$365D,$0000,$3649 
				dc.w	$0000,$3634,$0000,$3620,$0000,$360C,$0000,$35F7 
				dc.w	$0000,$35E3,$0000,$35CF,$0000,$35BB,$0000,$35A7 
				dc.w	$0000,$3593,$0000,$357F,$0000,$356B,$0000,$3558 
				dc.w	$0000,$3544,$0000,$3530,$0000,$351D,$0000,$3509 
				dc.w	$0000,$34F6,$0000,$34E2,$0000,$34CF,$0000,$34BC 
				dc.w	$0000,$34A8,$0000,$3495,$0000,$3482,$0000,$346F 
				dc.w	$0000,$345C,$0000,$3449,$0000,$3436,$0000,$3423 
				dc.w	$0000,$3410,$0000,$33FD,$0000,$33EB,$0000,$33D8 
				dc.w	$0000,$33C5,$0000,$33B3,$0000,$33A0,$0000,$338E 
				dc.w	$0000,$337B,$0000,$3369,$0000,$3357,$0000,$3345 
				dc.w	$0000,$3332,$0000,$3320,$0000,$330E,$0000,$32FC 
				dc.w	$0000,$32EA,$0000,$32D8,$0000,$32C6,$0000,$32B4 
				dc.w	$0000,$32A2,$0000,$3291,$0000,$327F,$0000,$326D 
				dc.w	$0000,$325C,$0000,$324A,$0000,$3239,$0000,$3227 
				dc.w	$0000,$3216,$0000,$3204,$0000,$31F3,$0000,$31E2 
				dc.w	$0000,$31D1,$0000,$31BF,$0000,$31AE,$0000,$319D 
				dc.w	$0000,$318C,$0000,$317B,$0000,$316A,$0000,$3159 
				dc.w	$0000,$3148,$0000,$3138,$0000,$3127,$0000,$3116 
				dc.w	$0000,$3105,$0000,$30F5,$0000,$30E4,$0000,$30D4 
				dc.w	$0000,$30C3,$0000,$30B3,$0000,$30A2,$0000,$3092 
				dc.w	$0000,$3081,$0000,$3071,$0000,$3061,$0000,$3051 
				dc.w	$0000,$3040,$0000,$3030,$0000,$3020,$0000,$3010 
				dc.w	$0000,$3000,$0000,$2FF0,$0000,$2FE0,$0000,$2FD0 
				dc.w	$0000,$2FC1,$0000,$2FB1,$0000,$2FA1,$0000,$2F91 
				dc.w	$0000,$2F82,$0000,$2F72,$0000,$2F62,$0000,$2F53 
				dc.w	$0000,$2F43,$0000,$2F34,$0000,$2F24,$0000,$2F15 
				dc.w	$0000,$2F06,$0000,$2EF6,$0000,$2EE7,$0000,$2ED8 
				dc.w	$0000,$2EC9,$0000,$2EBA,$0000,$2EAA,$0000,$2E9B 
				dc.w	$0000,$2E8C,$0000,$2E7D,$0000,$2E6E,$0000,$2E5F 
				dc.w	$0000,$2E50,$0000,$2E42,$0000,$2E33,$0000,$2E24 
				dc.w	$0000,$2E15,$0000,$2E07,$0000,$2DF8,$0000,$2DE9 
				dc.w	$0000,$2DDB,$0000,$2DCC,$0000,$2DBE,$0000,$2DAF 
				dc.w	$0000,$2DA1,$0000,$2D92,$0000,$2D84,$0000,$2D75 
				dc.w	$0000,$2D67,$0000,$2D59,$0000,$2D4B,$0000,$2D3C 
				dc.w	$0000,$2D2E,$0000,$2D20,$0000,$2D12,$0000,$2D04 
				dc.w	$0000,$2CF6,$0000,$2CE8,$0000,$2CDA,$0000,$2CCC 
				dc.w	$0000,$2CBE,$0000,$2CB0,$0000,$2CA2,$0000,$2C95 
				dc.w	$0000,$2C87,$0000,$2C79,$0000,$2C6B,$0000,$2C5E 
				dc.w	$0000,$2C50,$0000,$2C42,$0000,$2C35,$0000,$2C27 
				dc.w	$0000,$2C1A,$0000,$2C0C,$0000,$2BFF,$0000,$2BF2 
				dc.w	$0000,$2BE4,$0000,$2BD7,$0000,$2BC9,$0000,$2BBC 
				dc.w	$0000,$2BAF,$0000,$2BA2,$0000,$2B95,$0000,$2B87 
				dc.w	$0000,$2B7A,$0000,$2B6D,$0000,$2B60,$0000,$2B53 
				dc.w	$0000,$2B46,$0000,$2B39,$0000,$2B2C,$0000,$2B1F 

	
			BSS

puffer1:	ds.b 		1000
puffer2:	ds.b    1000			
puffer3:	ds.b	  10

fin:
