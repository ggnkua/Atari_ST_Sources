********************************************************
*                    MONO 2 COLOR V1.1                 *
*    Software zur automatischen Monitorumschaltbox     *
*                                                      *
*    by Thomas Peuss und Thomas Mokler                 *
*    in Assembler mit dem OMIKRON.Assembler V1.86      *
*                                                      *
*    (c) MAXON Computer 1991                           *
*                                                      *
********************************************************

resvector:      EQU $042A       ;Vector fÅr RESET
resvalid:       EQU $0426       ;RESET-Kennungs-Vector
xbios:          EQU 14
gemdos:         EQU 1
pi:             EQU $31415926
        move.w #4,-(SP) ;aktuelle Auflîsung feststellen
        trap #xbios     ;per XBIOS(Getrez)
        addq.l #2,SP
        cmp.w #2,D0     ;hoch?
        bne.s back      ;nein --> Prg beenden ;ja --> weiter

        bsr.s superv    ;in Supervisor-Modus
        lea oldmagic(PC),A0
        lea oldres(PC),A1
        move.l resvalid,(A0) ;alte "Magicnumber" sichern
        move.l resvector,(A1) ;alte Resetroutinenadresse sichern
        move.l #pi,resvalid ;neue "Magicnumber" eintragen (Pi!!)
        move.l #newrst,resvector ;neuen Resetroutine eintragen

        move.w #64,-(SP) ;Port B,Bit 6(GPO) einschalten
        move.w #30,-(SP) ;per XBIOS(Ongibit)
        trap #xbios
        addq.l #4,SP

        move.l #$0FFFFF,D0 ;auf
wait:   nop
        dbra D0,wait    ;warten

        pea msg         ;wenn kein Reset dann Meldung ausgeben
        move.w #9,-(SP) ;per GEMDOS(Cconws)
        trap #gemdos
        addq.l #6,SP

        move.w #7,-(SP) ;und auf Taste warten
        trap #gemdos    ;per GEMDOS(Crawcin)
        addq.l #2,SP
        bsr.s old_vec   ;alte Magicnumber und Resetadresse wieder eintragen
        bsr.s user      ;in User-Modus

back:   move.w #0,-(SP) ;Prg beenden
        trap #gemdos    ;per GEMDOS(Pterm0)

superv: move.l #0,-(SP) ;in Supervisor-Modus schalten
        move.w #$20,-(SP) ;per GEMDOS(Super)
        trap #gemdos
        addq.l #6,SP
        move.l D0,oldusp
        rts

user:   move.l oldusp(PC),-(SP) ;in User-Modus
        move.w #$20,-(SP) ;per GEMDOS(Super)
        trap #gemdos
        addq.l #6,SP
        rts

old_vec:move.l oldres(PC),resvector ;alte Resetadresse in den Vector
        move.l oldmagic(PC),resvalid ;alte Magicnumber in den Vector
        rts


newrst: move.w #0,-(SP) ;Auflîsung umschalten
        move.l #-1,-(SP) ;per XBIOS(Setscreen)
        move.l #-1,-(SP)
        move.w #5,-(SP)
        trap #xbios
        lea 12(SP),SP

        bsr.s old_vec   ;alte Magicnumber und Resetadresse wieder eintragen

        lea -$7800,A0   ;Hier wird ein Teil des ROM's ersetzt damit
        move.b #7,(A0)  ;GPO nicht wieder vom TOS umgeschaltet wird
        move.b #$C0,2(A0)
        move.b #$0E,(A0) ;bis hier alles aus dem ROM
        move.b #$47,2(A0) ;diese Zeile ist geÑndert

        move.b $FC0003,D0 ;TOS-Version holen
        ext.w D0
        lea tabelle(PC),A0 ;Adresse der Sprungtabelle holen
        adda.w 0(A0,D0.w),A6 ;Einsprungadresse ins ROM berechnen
        cmpi.l #$31415926,oldmagic ;Testen ob andere Resetroutine vorhanden
        beq.s another   ;ja --> anspringen
        jmp (A6)        ;nein --> ins ROM
another:movea.l oldres,A1 ;Routinenadresse holen
        jmp (A1)        ;anspringen

                DATA
msg:            DC.B 27,'E'     ;Clear Screen
                DC.B 13,10,"Monitorumschaltbox nicht angeschlossen oder gar defekt ?!"
                DC.B 13,10,"Bitte Taste drÅcken !",0
                EVEN
tabelle:        DC.W 62,62,68   ;Sprungweiten fÅr die verschiedenen TOS-Versionen
                EVEN            ;(1.0,1.2,1.4)
                BSS
oldusp:         DS.L 0
oldmagic:       DS.L 0
oldres:         DS.L 0
                END


