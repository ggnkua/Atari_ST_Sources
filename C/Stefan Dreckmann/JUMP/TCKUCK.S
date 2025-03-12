;die Assemblerroutine kuckma_rein() in Trap #2

GLOBL kuckma_rein ;Einsprungadresse der Funktion
GLOBL trapZwoAdr  ;alte Einsprungadresse Trap #2
GLOBL formDo      ;Flag form_do
GLOBL objcDraw    ;Flag objc_draw
GLOBL TCobjAdr    ;fÅr Zeiger auf Adresse des 
                                   ;Objektbaums

vdi EQU 115       ;Opcode VDI
obdra EQU 42      ;Opcode objc_draw()
fodo EQU 50       ;Opcode form_do()

kuckma_rein:
  cmpi.w #vdi,d0         ;falls VDI Routine...
  beq ausgang            ;...nichts machen
  
  move.l d1,a0           ;Adresse AESPB holen
  move.l (a0),a1         ;Adresse CONTROL-Feld 
                                          ;holen

  cmpi.w #obdra,(a1)     ;Opcode fÅr objc_draw()?
  bne next               ;nein: keine Aktion
  addq.w #1,objcDraw     ;Flag setzen
  move.l 16(a0),TCobjAdr ;Zeiger auf Adresse des
                           ;Objekbaums Åbergeben

next:
  cmpi.w #fodo,(a1)        ;Opcode fÅr form_do()?
  bne ausgang              ;nein: keine Aktion
  addq.w #1,formDo         ;Flag setzen
  
ausgang:
  move.l trapZwoAdr,a0     ;alte Trap-Adresse
                                          ;holen
  jmp  (a0)                ;dort fortfahren