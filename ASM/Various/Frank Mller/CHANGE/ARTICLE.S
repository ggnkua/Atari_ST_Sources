; Ersatzloader fÅr Bootsektoren
; by Frank MÅller  (c) 1992 MAXON Computer
TEXT

move.l   4(sp),a0
move.l   $0c(A0),a1
add.l    $14(A0),a1
add.l    $1C(A0),a1
add.l    #4256,a1    ; Stack + BasepagelÑnge 
move.l   a0,sp       ; Stack...
adda.l   a1,sp       ; ... ans Programmende
move.l   a1,-(sp)    ; Grîûe
move.l   a0,-(sp)    ; Adresse
clr.w    -(sp)       ; Dummy-Null
move.w   #$4A,-(sp)  ; Gemdos 74
trap     #1
add.l    #12,sp

pea      info        ; Aufforderung zum 
move.w   #9,-(sp)    ; Diskettenwechsel
trap     #1          ; ausgeben
addq.l   #6,sp

move.w   #1,-(sp)    ; Auf Tastendruck
trap     #1          ; warten
addq.l   #2,sp

move.w   #1,-(sp)    ; 1 Sektor
move.w   #0,-(sp)    ; Seite 0
move.w   #0,-(sp)    ; Track 0
move.w   #1,-(sp)    ; Sektor 1 (Bootsektor)
move.w   #0,-(sp)    ; Laufwerk a
clr.l    -(sp)
move.l   #DISK,-(sp)
move.w   #8,-(sp)
trap     #14         ; lesen
add.w    #20,sp

clr.w    D0
move.w   #256, D1    ; siehe Artikel
lea      DISK,A0
mark: 
add.w    (A0)+,D0
subq.w   #1,D1
cmpi.w   #0,D1
bne mark

cmpi.w   #4660,D0   ; 4660 = $1234
beq do_it
pea      warn       ; WARNMELDUNG 
move.w   #9,-(sp)   ; (NO MAGIC)
trap     #1         ; ausgeben
addq.l   #6,sp     

move.w   #1,-(sp)   ; Taste einlesen
trap     #1          
addq.l   #2,sp
cmpi     #'j',D0
beq do_it

move.w  #0,-(sp)
trap    #1          ; ENDE

do_it:
move.l  #0,-(SP)
move.w  #$20,-(SP)
trap    #1
addq.l  #6,SP
jmp DISK   
;RÅckkehr gibt's keine. 
 
.data
info: dc.b 27,'E',"Bitte Bootdiskette einlegen"
      dc.b "(RETURN)",0
warn: dc.b 27,'E',"BOOTSEKTOR NICHT AUSFöHRBAR."
      dc.b "TROTZDEM WEITER (j/n)?",0
even
DISK: ds 514     ; Platz fÅr Bootsektor
.end
