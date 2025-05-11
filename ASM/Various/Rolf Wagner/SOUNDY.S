;===============================================================
;=                     S O U N D Y                             =
;=        6-BIT SOUND-DIGITIZER fr ATARI ST COMPUTER          =
;=        -------------------------------------------          =
;=                         by                                  =
;=                                                             =
;=     Rolf Wagner          &           Oliver Strunk          =
;=     Sulzbrunn 3                      Am G”hlenbach 57       =
;=     8961 Sulzberg                    8960 Kempten           =
;=                                                             =
;=       (Software)                       (Hardware)           =
;=                                                             =
;===============================================================
;
;
;-----------------------------------
; sound-chip-register initialisieren
;-----------------------------------
reg_init:
 move.l #sound,a0
sound_loop:
 move.w (a0)+,d0
 bmi reg_init_exit
 move.b d0,register
 move.w (a0)+,d0
 move.b d0,value

 jsr output
 bra sound_loop

reg_init_exit:
 rts
;
;----------------------------
; sound-chip-register ausgabe
;----------------------------
output:
 move.b register,d1
 cmp.b #7,d1
 bne sound_out2
 move.b d1,$ffff8800
 move.b $ffff8800,d2
 and.b #%11000000,d2
 or.b value,d2
 move.b d2,$ffff8802
 rts

sound_out2:
 move.b register,$ffff8800
 move.b value,$ffff8802
 rts

;----------------------------------------------    
; programmende: interrupts etc wiederherstellen
;----------------------------------------------
bpp:
 move.b save7,$fffffa07
 move.b save9,$fffffa09
 move.w #$2308,sr
 move.l stackptr,-(sp)
 move.w #$20,-(sp)
 trap #1
 add.l #6,sp

 move.w #5,d0
wait_2:
 move.w #$ffff,d1
wait_1: dbra d1,wait_1
 dbra d0,wait_2
bp:
 rts


;-----------
; variablen 
;-----------
register: blk.w 1,0
value: blk.w 1,0

stackptr: blk.l 1,0

mem_start:blk.l 1,0
mem_end:blk.l 1,0

save7: blk.w 1,0
save9: blk.w 1,0

sound_sign: blk.w 1,0
speed: blk.w 1,0

;--------------------------------------
; initialisierungs-werte fr sound-chip
;--------------------------------------
sound: dc.w  0,255, 1,255, 2,255, 3,255, 4,255, 5,255, 6,0, 7,%00111111
       dc.w  8,0, 9,0, 10,0, -1,-1

;------------------------------------------
; lautst„rke-stufen fr lautst„rke-register
;------------------------------------------
poketab:
 dc.l $08000000 ,$09000000, $0a000000     ; 00
 dc.l $08000000 ,$09000000, $0a000200     ; 01
 dc.l $08000000 ,$09000000, $0a000300     ; 02
 dc.l $08000200 ,$09000200, $0a000200     ; 03
 dc.l $08000500 ,$09000000, $0a000000     ; 04
 dc.l $08000500 ,$09000200, $0a000000     ; 05
 dc.l $08000600 ,$09000100, $0a000000     ; 06
 dc.l $08000600 ,$09000200, $0a000100     ; 07
 dc.l $08000700 ,$09000100, $0a000000     ; 08
 dc.l $08000700 ,$09000200, $0a000000     ; 09
 dc.l $08000700 ,$09000300, $0a000100     ; 0a
 dc.l $08000800 ,$09000000, $0a000000     ; 0b
 dc.l $08000800 ,$09000200, $0a000000     ; 0c
 dc.l $08000800 ,$09000300, $0a000100     ; 0d
 dc.l $08000800 ,$09000400, $0a000100     ; 0e
 dc.l $08000900 ,$09000000, $0a000000     ; 0f
 dc.l $08000900 ,$09000200, $0a000000     ; 10
 dc.l $08000900 ,$09000300, $0a000100     ; 11
 dc.l $08000900 ,$09000400, $0a000100     ; 12
 dc.l $08000900 ,$09000500, $0a000000     ; 13
 dc.l $08000900 ,$09000500, $0a000200     ; 14
 dc.l $08000900 ,$09000600, $0a000000     ; 15
 dc.l $08000900 ,$09000600, $0a000200     ; 16
 dc.l $08000a00 ,$09000200, $0a000000     ; 17
 dc.l $08000a00 ,$09000200, $0a000200     ; 18
 dc.l $08000a00 ,$09000400, $0a000100     ; 19
 dc.l $08000a00 ,$09000500, $0a000000     ; 1a
 dc.l $08000a00 ,$09000500, $0a000200     ; 1b
 dc.l $08000a00 ,$09000600, $0a000100     ; 1c
 dc.l $08000a00 ,$09000600, $0a000300     ; 1d
 dc.l $08000b00 ,$09000100, $0a000000     ; 1e
 dc.l $08000b00 ,$09000200, $0a000100     ; 1f
 dc.l $08000b00 ,$09000300, $0a000100     ; 20
 dc.l $08000b00 ,$09000400, $0a000100     ; 21
 dc.l $08000b00 ,$09000500, $0a000100     ; 22
 dc.l $08000b00 ,$09000600, $0a000000     ; 23
 dc.l $08000b00 ,$09000600, $0a000200     ; 24
 dc.l $08000b00 ,$09000700, $0a000000     ; 25
 dc.l $08000b00 ,$09000700, $0a000100     ; 26
 dc.l $08000b00 ,$09000700, $0a000300     ; 27
 dc.l $08000b00 ,$09000700, $0a000400     ; 28
 dc.l $08000b00 ,$09000800, $0a000100     ; 29
 dc.l $08000b00 ,$09000800, $0a000300     ; 2a
 dc.l $08000b00 ,$09000800, $0a000400     ; 2b
 dc.l $08000b00 ,$09000800, $0a000500     ; 2c
 dc.l $08000b00 ,$09000800, $0a000500     ; 2d
 dc.l $08000c00 ,$09000200, $0a000000     ; 2e
 dc.l $08000c00 ,$09000200, $0a000200     ; 2f
 dc.l $08000c00 ,$09000400, $0a000100     ; 30
 dc.l $08000c00 ,$09000500, $0a000000     ; 31
 dc.l $08000c00 ,$09000500, $0a000300     ; 32
 dc.l $08000c00 ,$09000600, $0a000000     ; 33
 dc.l $08000c00 ,$09000600, $0a000200     ; 34
 dc.l $08000c00 ,$09000700, $0a000000     ; 35
 dc.l $08000c00 ,$09000700, $0a000300     ; 36
 dc.l $08000c00 ,$09000700, $0a000400     ; 37
 dc.l $08000c00 ,$09000800, $0a000000     ; 38
 dc.l $08000c00 ,$09000800, $0a000300     ; 39
 dc.l $08000c00 ,$09000800, $0a000400     ; 3a 
 dc.l $08000c00 ,$09000800, $0a000500     ; 3b
 dc.l $08000c00 ,$09000900, $0a000000     ; 3c
 dc.l $08000c00 ,$09000900, $0a000300     ; 3d
 dc.l $08000c00 ,$09000900, $0a000400     ; 3e
 dc.l $08000c00 ,$09000900, $0a000500     ; 3f
 dc.l $08000c00 ,$09000900, $0a000500     ; 40


;--------------------------------------------------------------
; hier beginnt das hauptprogramm: einsprung nach 'in' bzw 'out'
;--------------------------------------------------------------
;
;
;------------------- digi-sound-input ------------------------------
;
;
in:
 clr.l -(sp)                  ; supervisor-modus einschalten
 move.w #$20,-(sp)            ;             "
 trap #1                      ;             "
 add.l #6,sp                  ;             "
 move.l d0,stackptr           ;             "

 jsr reg_init                 ; sound-chip register initialieren

 move.l #$20000,d0            ; speicher-startadresse (=$50000)
 move.l d0,mem_start
 add.l  #550000,d0            ; anzahl bytes zu samplen (500 kb)
 move.l d0,mem_end            ; (max bis speicherobergrenze) 

 move.b $fffffa07,save7       ; interrupts ausschalten
 move.b $fffffa09,save9       ;              "
 move.b #0,$fffffa07          ;              "
 move.b #%01000000,$fffffa09  ;              "
 and.w #%1111100011111111,sr  ;              "
 or.w #$500,sr                ;              "

 clr.l d2                     ; ersten strobe - high senden
 move.b #$20,d2               ; damit wird der digitizer
 move.b #14,$ffff8800         ; gestartet
 move.b $ffff8800,d3          ;              
 or.b d2,d3                  ;
 move.b d3,$ffff8802          ;

 move.b #7,$ffff8800          ; port b des sound-chips
 move.b $ffff8800,d0          ; fr die eingabe vorbereiten
 and.b #%01111111,d0          ;              "
 move.b d0,$ffff8802          ;              "

 move.l mem_start,a2          ; speicher-start
 move.l #poketab,a1           ; startadresse der lautst„rke-werte


;-------- eigentliche eingabe-hauptschleife

inloop:
 mulu d6,d6
 mulu d6,d6                   ; ein bichen warten ....

 clr.l d5                   
 move.b #15,$ffff8800         ; register 15 des sound-chips selektieren
 move.b $ffff8800,d5          ; und sound-daten holen (reg 15 = port b)

 move.b #14,$ffff8800         ; strobe low ausgeben
 move.b $ffff8800,d1          ;        "     
 and.b #$df,d1                ;        "
 move.b d1,$ffff8802          ;        "
 move.b $ffff8800,d1          ; strobe high ausgeben
 or.b #$20,d1                 ;        "
 move.b d1,$ffff8802          ;        "

 move.b d5,(a2)+              ; daten in speicher schreiben
 cmp.l mem_end,a2             ; speicher-ende ??
 bgt bpp                      ; ja, zum programm-ende

                              ; sound gleich ausgeben...
 and.w #%11111100,d5          ; nur bits 2-7
 move.w d5,d1                 ; multiplikation mal 3 (2+1)
 lsl.w #1,d1                  ;          "
 add.w d1,d5                  ;          "
 movem.l (a1,d5),d1-d3        ; register-tripel laden
 movem.l d1-d3,$ff8800        ; daten in sound-register schreiben
                              ; damit man mit-h”ren kann...

 bra inloop                   ; zurck zum anfang

;
;
;
;---------------- digi-sound-output -----------------------------
;
;
;
;
out:
 clr.l -(sp)                  ; supervisor-mode einschalten
 move.w #$20,-(sp)            ;              "
 trap #1                      ;              "
 add.l #6,sp                  ;              "
 move.l d0,stackptr           ;              "

 jsr reg_init                 ; sound-chip register initialisieren

 move.b $fffffa07,save7       ; interrupts ausschalten
 move.b $fffffa09,save9       ;              "
 move.b #0,$fffffa07          ;              "
 move.b #%01000000,$fffffa09  ;              "
 and.w #%1111100011111111,sr  ;              "
 or.w #$500,sr                ;              "

;------ hier beginnt die eigentliche sample-hauptschleife --------

 move.l #poketab,a1           ; adresse der lautst„rkewerte
 move.l #sampletab,a0         ; adresse der sample-daten

sample_repeat:
 move.l (a0)+,mem_start       ; sample-start-adresse
 bmi bpp                      ; bei -1 abbruch
 clr.w sound_sign             ; sound-sign = 1 fr rckw„rts-sound
 move.l (a0)+,mem_end         ; sample-end-adresse
 move.w (a0)+,speed           ; ausgabe-geschwindigkeit
 move.w (a0)+,d7              ; anzahl der wiederhohlungen
 bpl repeat                   ; bei >0 normal spielen
 move.w d7,sound_sign         ; sound-sign setzten 
 move.w #-1,d5                ; vorzeichen „ndern (wiederholungsanzahl)
 sub.w d7,d5                  ;         "    
 move.w d5,d7                 ; wiederholungsanzahl nach d7

repeat:
 move.l mem_start,a2          ; daten-start-adresse
 move.l mem_end,a3            ; daten-end-adresse

outloop:
 move.w speed,d6                ; warteschleife
out_wait: dbra d6,out_wait    ;      "

 clr.l d5
 tst.w sound_sign             ; test auf rckw„rts-sound
 bne back_sound               ; ja !!

 move.b (a2)+,d5              ; daten aus speicher lesen
 cmp.l a3,a2                  ; speicher-ende ???
 bgt end_repeat               ; ja !!

sound_cont:
 and.w #%11111100,d5          ; nur bits 2-7
 move.w d5,d1                 ; multiplikation mal 3 (2+1)
 lsl.w #1,d1
 add.w d1,d5                  ;          "
 movem.l (a1,d5),d1-d3        ; register-tripel laden
 movem.l d1-d3,$ff8800        ; daten in sound-register schreiben
                       
 bra outloop                  ; zurck zum anfang

back_sound:
 move.b -(a3),d5              ; rckw„rts-sound
 cmp.l a2,a3                  ;        "
 blt end_repeat               ;        "
 bra sound_cont               ;        "

end_repeat:
 dbra d7,repeat               ; sound wiederholen
 bra sample_repeat            ;         "


;-------------------------------------------------------------------
;       sample-data : startdresse (long), endadresse (long)
;                     geschwindigkeit (word)(normal 14)
;                     anzahl der wiederholungen (word)
;                     ( positiv: 0 = einmal spielen 
;                                1=  zweimal   "   , usw.
;
;                       negativ:-1 = einmal rckw„rts spielen
;                               -2 = zweimal    "        "   , usw.)  
;-------------------------------------------------------------------
sampletab:

 dc.l $20000,$20000+570000    ; startadresse,endadresse
 dc.w  14,0                   ; geschwindigkeit, wiederholungsanzahl
 
 dc.l -1,-1                   ; ende der daten-liste (nicht vergessen!!)

end

