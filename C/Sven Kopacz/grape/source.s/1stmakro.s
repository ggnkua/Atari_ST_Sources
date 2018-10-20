;
; 1st_Makro Version 1.0
;
; Mal sehen, ob wirs hinkriegen
; Start-Sequenz aus PureC Assembler Demo:
; Achtung! Nur wenn A0=0 ist (=Start als Programm)
; sonst Start als Accessory, d.h. TPA wird automatisch geMSHRINKt
; und es muû nur noch eigener Stack eingerichtet werden.

start:          move.l  a0,d0										;Dummy-Operation
								bne     Access									;Als Accessory->
								lea.l   start-256, a1           ; Start der Basepage
                move.l  12(a1), d1              ; Grîûe des Textsegments
                add.l   20(a1), d1              ; Grîûe des Datensegments
                add.l   28(a1), d1              ; Grîûe des BSS-Segments
                add.l   #256,   d1              ; Grîûe der Basepage

                move.l  d1,  -(sp)              ; Benîtigter Speicher
                move.l  a1,  -(sp)              ; Startadresse
                clr     -(sp)                   ; dummy
                move    #74, -(sp)              ; Mshrink
                trap    #1                      ; Gemdos

                add.l   a1, d1                  ; new stack
                and.b   #$fc, d1                ; gerade Adresse
                move.l  d1, sp                  ; Stack liegt im BSS
								bra.s		Init										; genauer: am Ende
;
Access:         lea     Stackend(PC),SP 				;eigener Stack

; Und jetzt von Sven:

Init:           moveq   #10,D0          ;beim AES anmelden
                moveq   #0,D1
                moveq   #1,D2
                moveq   #0,D3
                bsr     aes
                move.w  intout(PC),appl_id
                move.w  appl_id(PC),D0  ;GÅltige Anmeldung?
                cmpi.w  #-1,D0
                bne.s   allesok         ;Ja->

;Anmeldung hat nicht geklappt,ENDE
;(erst noch ALERT ausgeben)
malad:          move.w  #1,intin
                move.l  #Endetext,addrin
                moveq   #52,D0          ;FORM_ALERT
                moveq   #1,D1
                moveq   #1,D2
                moveq   #1,D3
                bsr     aes

                move.w  #0,-(SP)
                trap    #1
;
allesok:        move.w  appl_id(PC),intin	;In Accessory-Zeile
                move.l  #menutitle,addrin	;registrieren lassen
                moveq   #35,D0
                moveq   #1,D1
                moveq   #1,D2
                moveq   #1,D3
                bsr     aes
								move.w 	intout(PC),D0			;RÅckgabewert prÅfen
								cmpi.w	#-1,D0						;Malaise-Code
								beq			malad							; dann ALERT und tschÅû..

; Jetzt geht's erst richtig los
; Tastaturfeld holen
;
                move.w  #1,-(SP)        ;Parameter 1(=KBD)
                move.w  #14,-(SP)       ;Funktion 14
                trap    #14             ;XBIOS
                addq.w  #4,SP
                move.l  D0,KeyPar       ;Adresse Block retten
                movea.l D0,A0           ;Und fÅr nachher in a0
                addq.l  #6,D0
                move.l  D0,smpoint      ;Adr. Schreibzeiger
                addq.l  #2,D0
                move.l  D0,lmpoint      ;Adr. Lesezeiger

                move.l  (A0),D0         ;und ersten Eintrag lesen=
                move.l  D0,pufferadr    ;Adr. Tastpuffer
;
                movea.l smpoint(PC),A0  ;momentane Schreibmarke
                move.w  (A0),asmarke    ;speichern

                bsr     turnoff         ;Anfangsstatus=Aus, Recplay=0


;
;
Hauptschleife:  bsr     event

                move.w  intout2(PC),D0  ;Was isch passiert?
                andi.w  #16,D0          ;Messagecode=16?
                beq     timeev          ;nicht dabei,dann Timer-Event
;Message-Event
                move.w  msgpuffer(PC),D0 ;Welche Nachricht?
                cmpi.w  #40,D0          ;Acc Open?
                bne.s   Sonstwas        ;Nein-Weiter->
;ACC-Open:
                bsr     alert           ;Alertbox ausgeben und
                bra.s   Hauptschleife   ;Parameter setzen

Sonstwas:       cmpi.w  #41,D0          ;Acc Close?
                bne     Warnix          ;Nein-Ende->

Sonstiges:      move.l  #-1,-(SP)       ;VerfÅgbaren Speicher
                move.w  #72,-(SP)       ;GEMDOS-MALLOC
                trap    #1
                addq.l  #6,SP
                move.l  D0,Speicher     ;wert speichern

Wartenoch:      move.w  #200,intin      ;Timer setzen
                move.w  #0,intin+2
                moveq   #24,D0          ;warten, da ACC-Close
                moveq   #2,D1           ;vermutlich vom PRG-Starten
                moveq   #1,D2           ;kommt,bis sich der verfÅgbare
                moveq   #0,D3           ;Speicher Ñndert
                bsr     aes             ;

                move.l  #-1,-(SP)       ;Freien Speicher
                move.w  #72,-(SP)       ;holen...
                trap    #1
                addq.l  #6,SP
                cmp.l   Speicher(PC),D0 ;Immer noch gleich?
                beq.s   Wartenoch       ;Dann weiter warten
                bhi.s   daswars         ;Neuer Block ist grîûer->Ende


                move.w  #1000,intin     ;Noch eine Sekunde
                move.w  #0,intin+2      ;warten, damit
                moveq   #24,D0          ;sich das PRG
                moveq   #2,D1           ;anmelden
                moveq   #1,D2           ;kann
                moveq   #0,D3
                bsr     aes


                move.l  #filename,addrin ;Mal sehen

                moveq   #13,D0          ;ob wir alleine sind,
                moveq   #0,D1           ;oder ob WORDPLUS
                moveq   #1,D2           ;auch da ist
                moveq   #1,D3           ;(mittels APPL_FIND)
                bsr     aes
                move.w  intout(PC),D0   ;Ergebnis holen
                cmpi.w  #-1,D0
                beq.s   daswars         ;Tja, kein WP da->weiter
                bsr     turnon          ;ACC EINSCHALTEN
                bra     Hauptschleife
daswars:        bsr     turnoff         ;ACC AUSSCHALTEN
                bra     Hauptschleife


; Timer-Event:
;
timeev:         movea.l smpoint(PC),A0  ;Puffer checken
                move.w  (A0),nsmarke    ;Neue Schreibmarke holen
                move.w  asmarke(PC),D0  ;Alte und
                move.w  nsmarke(PC),D1  ;neue Schreibmarke
                cmp.w   D0,D1           ;vergleichen...
                beq     Warnixend       ;immer noch gleich->Ende

;
                move.w  D1,asmarke      ;alt=neu
                movea.l pufferadr(PC),A0
                move.l  0(A0,D1.w),D2   ;Code aus Puffer holen
								move.l  D2,Keycode 			;, sichern... 
                swap    D2              ;und Scancode (3.Byte)
                andi.w  #255,D2         ;isolieren
								move.w  D2,Whichkey			;Code retten

                cmpi.w  #119,D2         ;Taste Alt 1..
                bmi		  Testtwo         ;...zu klein
                cmpi.w  #130,D2         ;Taste Alt 0
                bhi     Testtwo         ;..zu groû
								bra.s		Treffer					;Taste war dabei

Testtwo: 				cmpi.w	#1,D2						;Taste 1 pur
								bmi			Warnix					;...zu klein								
								cmpi.w	#12,D2					;Taste 0 pur
								bhi			Warnix					;...zu hoch
								addi.w  #118,D2					;auf richtigen Code drehen
								move.w	D2,Whichkey
; Switchtasten testen:
Treffer:        move.w  #-1,-(SP)       ;Parameter Status holen
                move.w  #11,-(SP)       ;Funktion Kbshift
                trap    #13             ;BIOS
                addq.l  #4,SP
;
                cmpi.b  #8,D0           ;Alternate ?!
                beq     keyout          ;Ja->vielleicht abspielen
								cmpi.b  #4,D0					  ;CTRL ?!
								bne			Warnix					;Nein->Ende
;Modus Record/Play umschalten
								move.w 	Recplay,D0			;Erst mal Modus holen
								bne			Switchplay			;->Aufnahme aus
;Aufnahme einschalten
								bsr			Ping
								move.w  Whichkey,D2     ;Tastencode holen
                subi.w  #120,D2         ;Code in 0-9 Wandeln
                lsl.w   #2,D2           ;*4
                lea     adressen(PC),A0 ;Adresse des entspr.
                move.l  0(A0,D2.w),D0   ;Textes holen
                move.l	D0,Recadr				;und abspeichern
                move.w	#0,Recpos				;Posiotion Reset
                move.w	#1,Recplay			;und Record an
               	move.w	#20,time2				;Timer Beschleunigen (x10)
                bra 		Hauptschleife		;und von vorn
                
;Aufnahme ausschalten																
Switchplay:			bsr			Ping
							  movea.l	Recadr,A0 			;Makro mit 0-Byte
                move.w  Recpos,D1				;terminieren
                move.l  #0,0(A0,D1.w)
								move.w	#0,Recplay			;und Record aus
								move.w	#200,time2			;Puls wieder reduzieren
								bra			Hauptschleife		;und von vorn
; Hier evtl. Taste abspielen:
;
keyout:					move.w	Recplay,d0			;1=record 0=play
								bne			Switchplay			;Im Record-Modus Alternate
																				;plus 1-0 gedrÅckt->Record 
																				;ausschalten
; Jetzt auf jeden Fall abspielen:																				
			          movea.l smpoint(PC),A0  ;Tastaturpuffer lîschen
                movea.l lmpoint(PC),A1  ;durch Schreib-=
                move.w  (A1),(A0)       ;Lesezeiger
								move.w  Whichkey,D2     ;Tastencode holen
                subi.w  #120,D2         ;Code in 0-9 Wandeln
                lsl.w   #2,D2           ;*4
                lea     adressen(PC),A0 ;Adresse des entspr.
                movea.l 0(A0,D2.w),A3   ;Textes holen
;

                clr.l   D1              ;Zaehler
Schleife:       clr.l   D0
                move.l  0(A3,D1.w),D0   ;Zeichen holen
                beq.s   Warnix          ;Nullbyte=Endezeichen
                movea.l lmpoint(PC),A2  ;Lesezeiger
                move.w  (A2),D2         ;holen
                addq.w  #4,D2           ;Zeiger erhîhen
                andi.w  #255,D2         ;Und öberlauf weg

ok:             movea.l pufferadr(PC),A0 ;

                move.l  D0,0(A0,D2.w)   ;Zeichen in Puffer
                move.w  D2,(A2)         ;und Zeiger zurÅckschreiben
                move.w  D1,Zaehler       ;Zaehler retten

Warte:          move.w  #20,intin       ;Zeit
                move.w  #0,intin+2
                moveq   #24,D0          ;EVNT-TIMER
                moveq   #2,D1
                moveq   #1,D2
                moveq   #0,D3
                bsr     aes
;Schauen, ob Tastpuffer leer:
                movea.l smpoint(PC),A0  ;Zeiger fÅr S&L
                movea.l lmpoint(PC),A1  ;holen
                move.w  (A0),D0         ;Inhalt
                move.w  (A1),D1         ;holen
                cmp.w   D0,D1           ;und vergleichen
                bne.s   Warte           ;noch nicht gleich
; Jetzt leer, nÑchstes Zeichen
                move.w  Zaehler(PC),D1
                addq.w  #4,D1
                bra.s   Schleife

;
Warnix:         move.w	Recplay,D0			;Vielleicht
								beq			Warnixend				;(nein->Ende)
;Schnell noch Zeichen aufnehmen								
                movea.l Recadr,A0 ;Adresse und
                move.w  Recpos,D1	 ;Position fÅr Aufnahme holen
                move.l  Keycode,D2 ;Tastencode holen
                move.l  D2,0(A0,D1.w)  ;und Schreiben
								addq.w  #04,D1		 ;Position erhîhen(Langwort!)
								move.w	D1,Recpos	 ;und speichern
								cmpi.w	#128,D1		 ;wenn Ende von Makro erreicht
								beq			Switchplay ;Aufnahme automatisch aus
								
								
Warnixend:			bra     Hauptschleife




alert:          lea     antext(PC),A0
                move.w  status(PC),D0   ;An/Aus-Text
                cmpi.w  #1,D0
                beq.s   weiter
                lea     austext(PC),A0
weiter:         clr.l   D0
                clr.l   D1
                lea     anaustext(PC),A1

textloop:       move.b  0(A0,D0.w),D1   ;Zeichen holen
                beq.s   textende        ;Nullzeichen=Ende->
                move.b  D1,0(A1,D0.w)
                addq.w  #1,D0           ;Zaehler+1
                bra.s   textloop

textende:       move.w  status(PC),intin
                move.l  #alerttext,addrin
                moveq   #52,D0          ;FORM_ALERT
                moveq   #1,D1
                moveq   #1,D2
                moveq   #1,D3
                bsr     aes
                move.w  #0,intin
                move.l  #0,addrin
                move.w  intout(PC),D0   ;Neuen Status holen
                eori.w  #3,D0           ;1->2, 2->1
                move.w  D0,status       ;und schreiben
                cmpi.w  #1,D0
                bne.s   ausschalten
; Einschalten: Multi-event 48,timer 200
                move.w  #48,intin2      ;msg+Timer
                move.w  #200,time2      ;Time=200
                bra.s   endealert
ausschalten:
                move.w  #16,intin2      ;nur msg
                move.w  #0,time2        ;Zeit=0 fÅr alle FÑlle

endealert:      rts



turnoff:        move.w  #2,status
                move.w  #16,intin2
                move.w  #0,time2
                
                move.w  Recplay,D0	;Falls gerade Aufnahme
                beq			turnoffend  ;(nein->Ende)
                movea.l Recadr,A0 	;dann mit 0-Byte terminieren
                move.w  Recpos,D1		
                move.l  #0,0(A0,D1.w)
                
turnoffend:     rts

turnon:         move.w  #1,status
                move.w  #48,intin2
                move.w  #200,time2
                move.w	#0,Recplay
                rts



event:          moveq   #25,D0          ;EVNT_MULTI
                moveq   #16,D1
                moveq   #7,D2
                moveq   #1,D3
                moveq   #0,D4
                movem.w D0-D4,contrl2
                move.l  #AESpar2,D1
                move.w  #200,D0
                trap    #2
                rts

;
aes:            moveq   #0,D4           ;GEM-AES
                movem.w D0-D4,contrl
                move.l  #AESpar,D1
                move.w  #200,D0
                trap    #2
                rts

Ping:						move.w	#7,-(sp)		;Character=Bell
								move.w	#2,-(sp)		;Device=Konsole
								move.w	#3,-(sp)		;Bconout
								trap		#13					;BIOS
								addq.l	#6,sp
								rts
								

                EVEN

;
                DATA

status:         DC.W 1

;Texte
adressen:       DC.L t1,t2,t3,t4,t5,t6,t7,t8,t9,t0
                DC.B '1234567810' ;magic

t1:             DCB.L 33,0
t2:             DCB.L 33,0
t3:             DCB.L 33,0
t4:             DCB.L 33,0
t5:             DCB.L 33,0
t6:             DCB.L 33,0
t7:             DCB.L 33,0
t8:             DCB.L 33,0
t9:             DCB.L 33,0
t0:             DCB.L 33,0

                EVEN
antext:         DC.B 'aktiv.  ',0
                EVEN
austext:        DC.B 'inaktiv.',0
                EVEN
alerttext:      DC.B '[1][ 1st-Makro ist | '
anaustext:      DC.B 'xxxxxxxx ][ Aus | Ein ]',0

                EVEN
Endetext:       DC.B '[3][ 1st-Makro kann sich | nicht anmelden. | '
                DC.B 'Evtl. schon 6 ACCs. | geladen? ][ OK ]',0,0
                EVEN

filename:       DC.B 'WORDPLUS'
                DC.B 0,0,0,0,0,0,0,0

                EVEN

menutitle:      DC.B '  1st-Makro ',0,0,0,0,0,0,0,0,0,0
                EVEN

;AES-Aufruf fÅr Multi (Timer & Message)
;Paramter Block-adressen:
AESpar2:        DC.L contrl2,globl2,intin2,intout2,addrin2,addrout2
;Datenfelder:
contrl2:        DS.W 5
globl2:         DS.W 12
intin2:         DC.W 48,0,0,0,0,0,0,0,0,0,0,0,0,0
time2:          DC.W 200,0

intout2:        DS.W 7
addrin2:        DC.L msgpuffer
                DS.L 1

addrout2:       DS.L 1

;
;AES-Parameter Block fÅr allg. Aufrufe
AESpar:         DC.L contrl,globl,intin,intout,addrin,addrout
;
                BSS
                EVEN

msgpuffer:      DS.B 16

;
Zaehler:         DS.W 1
;
asmarke:        DS.W 1
nsmarke:        DS.W 1
;

contrl:         DS.W 5          ;AES-Datenfelder
globl:          DS.W 12
intin:          DS.W 16
intout:         DS.W 7
addrin:         DS.L 2
addrout:        DS.L 1
;
appl_id:        DS.W 1
;
Speicher:       DS.L 1
;
KeyPar:         DS.L 1          ;Tastaturpufferparameterblockadresse
pufferadr:      DS.L 1
smpoint:        DS.L 1
lmpoint:        DS.L 1
Keycode:				DS.L 1
Whichkey:				DS.W 1
Recplay:				DS.W 1
Recadr:					DS.L 1
Recpos:					DS.W 1

Stack:					DS.B 4096
Stackend:      
                END
