                opt D+

test            equ 0

                >PART

                if test
                lea     coso+2782,a0
                else
                lea     coso,a0
                endc
                moveq   #1,d0
                bsr.s   sound

                pea     _play
                move.w  #246,-(sp)
                move.w  #7,-(sp)
                move.w  #1,-(sp)
                move.w  #$1f,-(sp)
                trap    #14
                lea     12(sp),sp

                move.w  #8,-(sp)
                move.w  #$1b,-(sp)
                trap    #14
                addq.l  #4,sp

                move.w  #1,-(sp)
                trap    #1
                addq.l  #2,sp

                move.w  #8,-(sp)
                move.w  #$1a,-(sp)
                trap    #14
                addq.l  #4,sp


                clr.w   -(sp)
                trap    #1

_play:          movem.l d0-a6,-(sp)
                bsr.s   sound+2*4
                movem.l (sp)+,d0-a6
                bclr    #0,$fffffa0f.w
                rte
                endpart

**********************************************
*        Mad Max's Soundchip-Driver          *
*                                            *
*        reassembled by bITmASTER            *
**********************************************

ym_r0           equ 2
ym_r1           equ 6
ym_r2           equ 10
ym_r3           equ 14
ym_r4           equ 18
ym_r5           equ 22
ym_r6           equ 26
ym_r7           equ 30
ym_r8           equ 34
ym_r9           equ 38
ym_r10          equ 42
ym_r11          equ 46
ym_r12          equ 50
ym_r13          equ 54

track_base      equ 0                   ;.l
track_index     equ 4                   ;.w
seq_note        equ 6                   ;.b
seq_hkurve      equ 7                   ;.b
hkurve_base     equ 8                   ;.l
hkurve_index    equ 12                  ;.w
instr_base      equ 14                  ;.l
instr_index     equ 18                  ;.w
track_hkurve    equ 20                  ;.b
track_note      equ 21                  ;.b
hkurve_time     equ 22                  ;.b
hkurve_time_init equ 23                 ;.b
hkurve_count    equ 24                  ;.b
instr_count     equ 25                  ;.b
instr_note      equ 26                  ;.b
delta_f         equ 27                  ;.b
mod_f_max       equ 28                  ;.b
mod_f_work      equ 29                  ;.b
tfmx_count      equ 30                  ;.b
flags           equ 31                  ;.b
seq_instr       equ 32                  ;.b
noise_freq      equ 33                  ;.b
voice_nr        equ 34                  ;.b
hkurve_amplitude equ 35                 ;.b
track_dÑmpfung  equ 36                  ;.b
dÑmpfung        equ 37                  ;.b
tune_noise      equ 38                  ;.b
not_used1       equ 39                  ;.b
seq_ptr         equ 40                  ;.l
seq_time        equ 44                  ;.b
seq_time_init   equ 45                  ;.b
bend_var        equ 46                  ;.l
track_count     equ 50                  ;.w
not_used2       equ 52                  ;.w

sound:          bra     select_snd
                bra     L0001           ;GerÑusche
                bra     play            ;alle 20 ms
                bra     L0000

                pea     (a0)
                lea     L0063(pc),a0
                move.b  d0,(a0)
                movea.l (sp)+,a0
                rts

L0000:          pea     (a0)
                andi.b  #$1f,d0
                lea     L004F(pc),a0
                move.b  d0,(a0)+
                move.b  d0,(a0)+
                move.b  #0,(a0)+
                movea.l (sp)+,a0
                rts

*************** GerÑusche **************************************************

L0001:          movem.l d0-a6,-(sp)
                lea     coso(pc),a0
                bsr     reloziere
                movea.l gerÑusch_nr(pc),a1
                add.w   d0,d0           ;*4
                add.w   d0,d0
                adda.w  d0,a1
                lea     start_gerÑusch(pc),a6
                move.w  (a1)+,(a6)      ;Start GerÑusch
                moveq   #0,d0
                move.w  (a1)+,d0        ;LÑnge
                bsr     play_gerÑusch
                movem.l (sp)+,d0-a6
                rts

*************** Musik auswÑhlen & initialisieren ******************************

select_snd:     movem.l d0-a6,-(sp)
                bsr.s   L0003
                movem.l (sp)+,d0-a6
                rts

*************** a0 zeigt auf Sounddaten (COSO) ! ******************************

L0003:          nop
                nop
                bsr.s   reloziere
                tst.w   d0
                beq.s   L0004
                subq.w  #1,d0
                movea.l L005E(pc),a1
                mulu    #6,d0
                adda.w  d0,a1
                move.w  (a1)+,d0        ;Start
                move.w  (a1)+,d1        ;End
                lea     play_speed(pc),a6
                move.w  (a1)+,(a6)      ;Play-Speed
                bsr     init_voice
                rts

L0004:          lea     L0053(pc),a0
                st      (a0)
                bra     play

reloziere:      move.w  L004D(pc),d7
                nop
                lea     mmme_flag(pc),a1
                sf      (a1)
                cmpi.l  #"MMME",32(a0)
                bne.s   L0006
                move.b  #1,(a1)         ;MMME-Driver
L0006:          lea     adr_coso(pc),a6
                move.l  a0,(a6)
                movea.l track_index(a0),a1
                adda.l  a0,a1
                lea     inst(pc),a6
                move.l  a1,(a6)
                movea.l hkurve_base(a0),a1
                adda.l  a0,a1
                lea     hÅll_kurve(pc),a6
                move.l  a1,(a6)
                movea.l hkurve_index(a0),a1
                adda.l  a0,a1
                lea     sequenz(pc),a6
                move.l  a1,(a6)
                movea.l 16(a0),a1
                adda.l  a0,a1
                lea     tracks(pc),a6
                move.l  a1,(a6)
                movea.l track_hkurve(a0),a1
                adda.l  a0,a1
                lea     L005E(pc),a6
                move.l  a1,(a6)+
                movea.l hkurve_count(a0),a1
                adda.l  a0,a1
                move.l  a1,(a6)+
                lea     L004D(pc),a6
                st      (a6)
                lea     L0060(pc),a6
                move.w  #0,(a6)
                rts

*****************************************************************************
*               alle 20 ms                                                  *
*****************************************************************************

play:           lea     L004F(pc),a0    ;nach Init 0
                tst.b   (a0)
                beq.s   L0009
                subq.b  #1,1(a0)
                bpl.s   L0009
                move.b  (a0),1(a0)
                addq.w  #1,2(a0)
                move.w  2(a0),d0
                cmp.w   #$0a,d0
                bne.s   L0008
                clr.l   (a0)
                lea     L0053(pc),a0
                st      (a0)
                bra.s   L0009
L0008:          lea     L004E(pc),a0
                move.b  0(a0,d0.w),d0

                lea     L0055(pc),a0
                move.b  d0,(a0)
                move.b  d0,54(a0)
                move.b  d0,108(a0)

L0009:          lea     ym_set(pc),a6
                lea     play_speed_count(pc),a5
                tst.b   4(a5)
                beq.s   L000B
                tst.b   5(a5)
                bne.s   L000A
                st      5(a5)
                moveq   #0,d0
                move.b  d0,ym_r8(a6)    ;alle Amplituden 0
                move.b  d0,ym_r9(a6)
                move.b  d0,ym_r10(a6)
                move.b  L0063(pc),d1
                bne.s   L000A
                movem.l ym_7-ym_set(a6),d0-d3
                movem.l d0-d3,$ffff8800.w
L000A:          rts

L000B:          lea     L0050(pc),a5

                lea     voice0(pc),a0
                bsr     work_voice
                move.w  d0,-(sp)        ;Frequenz A
                move.b  (sp)+,ym_r1(a6) ;grob
                move.b  d0,ym_r0(a6)    ;fein
                move.b  d1,ym_r8(a6)    ;Amplitude A

                lea     voice1(pc),a0
                bsr     work_voice
                move.w  d0,-(sp)        ;Frequenz B
                move.b  (sp)+,ym_r3(a6) ;grob
                move.b  d0,ym_r2(a6)    ;fein
                move.b  d1,ym_r9(a6)    ;Amplitude B

                lea     voice2(pc),a0
                bsr     work_voice
                move.w  d0,-(sp)        ;Frequenz C
                move.b  (sp)+,ym_r5(a6) ;grob
                move.b  d0,ym_r4(a6)    ;fein
                move.b  d1,ym_r10(a6)   ;Amplitude C

*************** Voice fÅr GerÑusche ******************************************

                PART
                move.w  4(a5),d0        ;3. Voice ?
                beq.s   L000D           ;nein
                move.w  d0,-(sp)        ;retten
                lea     gerÑusch_voice(pc),a0 ;Voice 3
                bsr     work_voice
                movea.l hkurve_base(a0),a1 ;HÅllkurven
                adda.w  hkurve_index(a0),a1 ;Index
                cmpi.b  #$e1,(a1)       ;Ende ?
                bne.s   L000C           ;nein
                clr.w   4(a5)           ;voice3 aus
L000C:          move.w  (sp)+,d7        ;zurÅck
                lea     voice3_channel(pc),a1 ;eine Tabelle
                add.w   d7,d7           ;auf welcher Hardwarekanal soll Voice3
                add.w   d7,d7           ;eingestellt werden
                adda.w  d7,a1           ;Adr bestimmen
                moveq   #0,d6
                move.b  (a1)+,d6        ;ym-Reg-Nr holen holen
                move.w  d0,-(sp)        ;Frequenz
                move.b  d0,0(a6,d6.w)   ;Frequenz NWT
                move.b  (a1)+,d6        ;ym-Reg-Nr
                move.b  (sp)+,0(a6,d6.w) ;HWT
                move.b  (a1)+,d6        ;ym-Reg-Nr
                move.b  d1,0(a6,d6.w)   ;Amplitude
                endpart

*************** Voice3 Ende **********************************************

L000D:          move.b  (a5)+,d7
                ori.b   #$c0,d7
                move.b  d7,ym_r7(a6)    ;Noise / Tune
                move.b  (a5)+,ym_r6(a6) ;Noisefrequenz
                move.b  L0063(pc),d0
                bne.s   interpreter

                movem.l (a6),d0-a2      ;Soundchip programmieren
                movem.l d0-a2,$ffff8840.w

interpreter:    lea     play_speed_count(pc),a5
                subq.w  #1,(a5)+        ;was tun ?
                bne.s   L000F           ;nein
                move.w  (a5),-(a5)      ;ja, play_speed_count initialisieren
                moveq   #0,d5
                moveq   #0,d4
                lea     voice0(pc),a0
                bsr     sequenzer
                st      d4
                lea     voice1(pc),a0
                bsr     sequenzer
                lea     voice2(pc),a0
                bsr     sequenzer
L000F:          rts


sequenzer:      PART 'Sequenzer'
                subq.b  #1,seq_time(a0)
                bpl.s   L000F           ;nix tun
                move.b  seq_time_init(a0),seq_time(a0) ;Counter neu initialisieren
L0011:          movea.l seq_ptr(a0),a1  ;Adr der aktuellen Sequenz
L0012:          move.b  (a1)+,d0        ;Sequenz-Byte holen
                cmp.b   #-1,d0          ;Sequenz zu Ende ?
                bne     L0016           ;nein

*************** Tracks interpretieren *****************************************

                movea.l track_base(a0),a2 ;adr Tracks
                adda.w  track_index(a0),a2 ;+Index
                tst.b   d4              ;Voice 0 ?
                bne.s   L0013           ;nein
                subq.w  #1,track_count(a0) ;dec Track-Counter
                bpl.s   L0013           ;nee
                move.w  track_length(pc),track_count(a0) ;ja, LÑnge neu initialisieren
                move.w  d5,track_index+0*54(a0) ;Track-Index = 0 auf allen 3 Voices
                move.w  d5,track_index+1*54(a0)
                move.w  d5,track_index+2*54(a0)
                movea.l track_base(a0),a2 ;Tracks wieder von vorne
L0013:          moveq   #0,d1
                move.b  (a2),d1         ;Sequenz-Nr
                move.b  1(a2),track_note(a0) ;Tonhîhe der Sequenz
                move.b  2(a2),track_hkurve(a0) ;Trackparameter 2
                move.b  3(a2),d0        ;Trackparameter 3
                move.b  d0,d2
                andi.w  #$f0,d2         ;die obersten 4 Bits
                cmp.w   #$f0,d2         ;alle an ?
                bne.s   L0014           ;nein
                move.b  d0,d2           ;ja
                andi.b  #$0f,d2         ;und nun die untersten 4 Bits
                move.b  d2,track_dÑmpfung(a0) ;= DÑmpfung
                bra.s   L0015
L0014:          cmp.b   #$e0,d2         ;obersten 3 Bits 1 ?
                bne.s   L0015           ;nî
                move.b  d0,d2
                andi.w  #$0f,d2         ;die untersten 4 Bits
                move.w  d2,2(a5)        ;neues play_speed setzen
L0015:          add.w   d1,d1           ;Seq-Nr *2
                movea.l sequenz(pc),a3  ;sequenz-Tabelle
                movea.w 0(a3,d1.w),a3   ;Adr der Sequenz bestimmen
                adda.l  adr_coso(pc),a3 ;relozieren
                move.l  a3,seq_ptr(a0)  ;neue Adr aktuelle Sequenz
                addi.w  #12,track_index(a0) ;nexte Track-Eintrag
                bra     L0011

;Sequenz abarbeiten

L0016:          cmp.b   #$fe,d0         ;$fe-Sequenz
                bne.s   L0017           ;nî
                move.b  (a1),seq_time_init(a0) ;counter
                move.b  (a1)+,seq_time(a0) ;counter-init
                bra     L0012           ;next Byte

L0017:          cmp.b   #$fd,d0         ;$fd-Sequenz
                bne.s   L0018           ;nî

;-------------- Pause ------------------------------------------------

                move.b  (a1),seq_time_init(a0) ;counter
                move.b  (a1)+,seq_time(a0) ;counter-init
                move.l  a1,seq_ptr(a0)  ;neu aktuelle Sequenz-Adresse
                rts                     ;das war's

; kein $fe oder $fd - Sequenz

L0018:          move.b  d0,seq_note(a0) ;Tonhîhe
                move.b  (a1)+,d1        ;2.Sequenzbyte
                move.b  d1,seq_hkurve(a0) ;hkurve (0...31)
                andi.w  #$e0,d1         ;obersten 3 Bits = 0 ?
                beq.s   L0019           ;ja
                move.b  (a1)+,seq_instr(a0) ;3.Sequenzbyte
L0019:          move.l  a1,seq_ptr(a0)  ;aktuelle Sequenz-Adresse
                move.l  d5,bend_var(a0)
                tst.b   d0              ;Tonhîhe negativ ?
                bmi.s   L001B           ;ja
                move.b  seq_hkurve(a0),d1 ;
                move.b  d1,d0
                andi.w  #$1f,d1
                add.b   track_hkurve(a0),d1 ;Track-hkurve
                movea.l hÅll_kurve(pc),a2
                add.w   d1,d1           ;*2
                movea.w 0(a2,d1.w),a2   ;Adr der HÅllkurve
                adda.l  adr_coso(pc),a2 ;relozieren
                move.w  d5,hkurve_index(a0)
                move.b  (a2),hkurve_time_init(a0) ;Init fÅr Counter
                move.b  (a2)+,hkurve_time(a0) ;der Counter
                moveq   #0,d1
                move.b  (a2)+,d1        ;Instument (aus hkurve)
                move.b  (a2)+,delta_f(a0)
                move.b  #$40,flags(a0)
                move.b  (a2),mod_f_max(a0)
                move.b  (a2)+,mod_f_work(a0)
                move.b  (a2)+,tfmx_count(a0)
                move.l  a2,hkurve_base(a0) ;HÅllkurven-Ptr merken
                andi.b  #$40,d0         ;seq_hkurve
                beq.s   L001A           ;Instr aus hkurve Åbernehmen
                move.b  seq_instr(a0),d1 ;anderes Instrument setzem
L001A:          movea.l inst(pc),a2     ;
                add.w   d1,d1           ;*2
                movea.w 0(a2,d1.w),a2   ;Adresse des Instruments
                adda.l  adr_coso(pc),a2 ;relozieren
                move.l  a2,instr_base(a0) ;Adr merken
                move.w  d5,instr_index(a0) ;Instr-Index = 0
                move.b  d5,instr_count(a0) ;0
                move.b  d5,hkurve_count(a0) ;0
L001B:          rts
                endpart

init_voice:     PART
                lea     L004F(pc),a0
                clr.l   (a0)
                move.l  d0,d7           ;Start
                move.l  d1,d6           ;End
                sub.l   d0,d1           ;End-Start=LÑnge
                addq.l  #1,d6           ;End+1
                mulu    #12,d7          ;Start*12
                mulu    #12,d6          ;End*12
                lea     track_length(pc),a0
                move.w  d1,(a0)         ;LÑnge merken
                moveq   #2,d0           ;3 Voice
                lea     voice0(pc),a0
                lea     default_hÅll(pc),a1
                lea     voice_nr_tab(pc),a2 ; Tabelle fÅr die Voice-Nr ( 0, 1, 2 )
init_voice1:    move.l  a1,instr_base(a0)
                clr.w   instr_index(a0)
                move.l  a1,hkurve_base(a0)
                clr.w   hkurve_index(a0)
                sf      seq_note(a0)
                sf      seq_hkurve(a0)
                sf      instr_note(a0)
                sf      hkurve_amplitude(a0)
                move.b  #1,hkurve_time_init(a0)
                move.b  #1,hkurve_time(a0)
                sf      hkurve_count(a0)
                sf      instr_count(a0)
                sf      delta_f(a0)
                sf      mod_f_max(a0)
                sf      mod_f_work(a0)
                sf      tfmx_count(a0)
                sf      seq_instr(a0)
                sf      noise_freq(a0)
                move.b  (a2),d3         ;Voice-Nr
                andi.w  #$0f,d3
                add.w   d3,d3           ;*4
                add.w   d3,d3
                move.b  (a2)+,voice_nr(a0) ;Voice-Nr merken
                movea.l tracks(pc),a3
                adda.l  d7,a3           ;Startpunkt in der Sequenz-Tabelle
                adda.w  d3,a3           ;Voice 0, 1, 2
                move.l  a3,track_base(a0) ;Voice berÅcksichtigen
                move.w  #12,track_index(a0) ;sizeof
                move.w  track_length(pc),track_count(a0) ;LÑnge
                moveq   #0,d1
                move.b  (a3)+,d1        ;die Nr der 1.Sequenz
                add.w   d1,d1           ;* 2
                movea.l sequenz(pc),a4
                movea.w 0(a4,d1.w),a4   ;Adr der 1. Sequenz
                adda.l  adr_coso(pc),a4 ;relozieren
                move.l  a4,seq_ptr(a0)
                clr.w   seq_time(a0)
                move.b  #2,tune_noise(a0)
                move.b  (a3)+,track_note(a0) ;Sequenzparameter 1
                move.b  (a3)+,track_hkurve(a0) ;Sequenzparameter 2
                sf      dÑmpfung(a0)
                sf      track_dÑmpfung(a0)
                move.b  (a3)+,d1        ;Sequenzparameter 3
                move.b  d1,d2
                andi.w  #$f0,d1
                cmp.w   #$f0,d1
                bne.s   L001E
                sub.b   d1,d2
                move.b  d2,track_dÑmpfung(a0)
L001E:          clr.l   bend_var(a0)
                lea     54(a0),a0       ;next Voice
                dbra    d0,init_voice1
                lea     play_speed_count(pc),a0
                move.w  #1,(a0)
                clr.w   track_index(a0)
                rts
                endpart

play_gerÑusch:  PART
                move.w  start_gerÑusch(pc),d2
                move.w  L0060(pc),d1
                tst.w   d2
                beq     L0020           ;nix tun
                lea     gerÑusch_voice(pc),a0
                lea     L0050(pc),a5
                move.b  d2,seq_note(a0)
                move.b  d1,voice_nr(a0)
                sf      track_note(a0)
                moveq   #0,d5
                andi.w  #$ff,d0
                movea.l hÅll_kurve(pc),a2
                add.w   d0,d0
                movea.w 0(a2,d0.w),a2
                adda.l  adr_coso(pc),a2
                move.w  d5,hkurve_index(a0)
                move.b  (a2),hkurve_time_init(a0)
                move.b  (a2)+,hkurve_time(a0)
                move.b  (a2)+,d0
                andi.w  #$ff,d0
                move.b  (a2)+,delta_f(a0)
                move.b  #$40,flags(a0)
                move.b  (a2),mod_f_max(a0)
                move.b  (a2)+,mod_f_work(a0)
                move.b  (a2)+,tfmx_count(a0)
                move.l  a2,hkurve_base(a0)
                movea.l inst(pc),a2
                add.w   d0,d0
                movea.w 0(a2,d0.w),a2
                adda.l  adr_coso(pc),a2
                move.l  a2,instr_base(a0)
                move.w  d5,instr_index(a0)
                sf      hkurve_count(a0)
                sf      instr_count(a0)
                clr.l   bend_var(a0)
                sf      track_dÑmpfung(a0)
                sf      seq_instr(a0)
                addq.w  #1,d1
                move.w  d1,4(a5)
L0020:          rts
                endpart

*************************************************************************
*
*in:  a0: Pointer auf Voice-Area
*out: d0: Teilerfaktor
*     d1: Amplitude
*************************************************************************

work_voice:     moveq   #0,d7
                move.b  d7,noise_freq(a0)

*************** Instrument ************************************

L0022:          tst.b   instr_count(a0) ;0 erreicht ?
                beq.s   L0023           ;ja
                subq.b  #1,instr_count(a0) ;weiter dec
                bra     L0028           ;nix tun
L0023:          movea.l instr_base(a0),a1 ;Instrument
                adda.w  instr_index(a0),a1 ;Index
L0024:          move.b  (a1)+,d0        ;laden
                moveq   #0,d1
                move.b  d0,d1
                subi.w  #$e0,d1         ; < $e0 ?
                bmi     L0027           ;ja
                add.w   d1,d1           ;Ende der Instr-tabelle erreicht ,*2
                move.w  jmp_tab1(pc,d1.w),d1
                jmp     L0026(pc,d1.w)

jmp_tab1:       dc.w i0-L0026           ;$e0
                dc.w i1-L0026           ;$e1
                dc.w i2-L0026           ;$e2
                dc.w i3-L0026           ;$e3
                dc.w i4-L0026           ;$e4
                dc.w i5-L0026           ;$e5
                dc.w i6-L0026           ;$e6
                dc.w i7-L0026           ;$e7
                dc.w i8-L0026           ;$e8
                dc.w i9-L0026           ;$e9
                dc.w i10-L0026          ;$ea

L0026:

;-------------- absoluter JMP ----------------------------------------

i0:             moveq   #0,d0
                move.b  (a1)+,d0        ;nexte Byte
                move.w  d0,instr_index(a0) ;Index setzen
                movea.l instr_base(a0),a1 ;Inst
                adda.l  d0,a1           ;neuen Index dazuaddieren
                bra.s   L0024           ;next Bytes

;-------------- $e1: Ende ---------------------------------------

i1:             move.b  -2(a1),instr_note(a0) ;halten
                bra     L0028           ;und Ende

;-------------- $e2: Reset HÅllkurvenindex ----------------------

i2:             move.w  d7,hkurve_index(a0) ;HÅllkurvenindex=0
                move.b  #1,hkurve_time(a0) ;1
                addq.w  #1,instr_index(a0) ;Index erhîhen
                bra.s   L0024           ;next Bytes

;-------------- $e3: Parameter fur Frequenzmodulation -------------------

i3:             move.b  (a1)+,delta_f(a0)
                move.b  (a1)+,mod_f_max(a0)
                addq.w  #3,instr_index(a0) ;Index
                bra     L0024           ;next Bytes

;-------------- $e4: Noise & Tune on  -----------------------------------

i4:             move.b  d7,tune_noise(a0) ;Ton & Rauschen an
                move.b  (a1)+,noise_freq(a0)
                addq.w  #2,instr_index(a0) ;Index
                bra     L0024           ;next Bytes

;-------------- $e5: Noise on Tune off ----------------------------------

i5:             move.b  #1,tune_noise(a0)
                addq.w  #1,instr_index(a0) ;Index
                bra     L0024           ;next Bytes

;-------------- $e6: Noise off, Tune on ---------------------------------

i6:             move.b  #2,tune_noise(a0)
                addq.w  #1,instr_index(a0) ;Index
                bra     L0024           ;next Bytes

;-------------- $e7: select Instrumentengruppe --------------------------

i7:             move.b  #0,d1
                move.b  (a1)+,d1
                lsl.w   #6,d1           ;*64
                movea.l inst(pc),a1
                adda.w  d1,a1
                move.l  a1,instr_base(a0)
                move.w  d7,instr_index(a0) ;Index=0
                bra     L0024           ;next Bytes

;-------------- $e8: set Instumentcounter -----------------------

i8:             move.b  (a1)+,instr_count(a0)
                addq.w  #2,instr_index(a0) ;Index
                bra     L0022           ;von vorne

;-------------- $e9: Dreieck -----------------------------------

i9:             movea.w #$8870,a3       ;Soundchip
                move.b  #11,(a3)        ;Hardware-HÅllkurve
                move.b  (a1)+,2(a3)     ;Feineinstellung
                move.l  #$0c000d0a,d0   ;Grobeinstellung = 0 & \/\/
                movep.l d0,8(a3)
                addq.w  #2,instr_index(a0) ;Index
                bra     L0024           ;next Bytes

;-------------- $ea:

i10:            move.b  #$20,seq_hkurve(a0)
                move.b  (a1)+,seq_instr(a0)
                addq.w  #2,instr_index(a0) ;Index
                bra     L0024           ;next Bytes


L0027:          move.b  d0,instr_note(a0) ;Byte < $e0 merken
                addq.w  #1,instr_index(a0) ;next

*************** Ende Instr ********************************


*************** HÅllkurve *********************************

L0028:          tst.b   hkurve_count(a0) ;0 erreicht ?
                beq.s   L0029           ;ja
                subq.b  #1,hkurve_count(a0) ;weiter dec
                bra.s   L002E           ;nix tun

L0029:          subq.b  #1,hkurve_time(a0) ;HÅllkurven-Time
                bne.s   L002E           ;nix tun
                move.b  hkurve_time_init(a0),hkurve_time(a0) ;neu setzen

                movea.l hkurve_base(a0),a1 ;HÅllkurve
                adda.w  hkurve_index(a0),a1 ;Index
L002A:          moveq   #0,d1
                move.b  (a1)+,d0        ;Amplitude laden
                move.b  d0,d1
                subi.w  #$e0,d1         ; < $e0 ?
                bmi.s   L002D           ;ja
                add.w   d1,d1
                move.w  jmp_tab2(pc,d1.w),d1
                jmp     L002C(pc,d1.w)

jmp_tab2:       dc.w j1-L002C
                dc.w j2-L002C
                dc.w j0-L002C
                dc.w j0-L002C
                dc.w j0-L002C
                dc.w j0-L002C
                dc.w j0-L002C
                dc.w j0-L002C
                dc.w j3-L002C

L002C:

;-------------- $e2, $e3, $e4, $e5, $e7, $e7 -------------------------

j0:             rts                     ;Abbruch

;-------------- $e0: absoluter JMP -------------------------------

j1:             moveq   #0,d1
                move.b  (a1)+,d1
                subq.w  #5,d1           ;5 Parameterbytes abziehen
                move.w  d1,hkurve_index(a0) ;HÅllkurven-Index
                movea.l hkurve_base(a0),a1
                adda.w  d1,a1           ;neue Adr
                bra.s   L002A           ;next Byte

;-------------- $e1: Ende --------------------------------------

j2:             move.b  -2(a1),hkurve_amplitude(a0) ;Amplitude halten
                bra.s   L002E           ;und fertig

;-------------- $e8: set HÅllkurvencounter ---------------------

j3:             addq.w  #2,hkurve_index(a0) ;Index
                move.b  (a1),hkurve_count(a0)
                bra.s   L0028

L002D:          move.b  d0,hkurve_amplitude(a0) ;Amplitude merken
                addq.w  #1,hkurve_index(a0) ;next HÅllkurven-Index

*************** Ende HÅllkurve *******************************************


L002E:          move.b  instr_note(a0),d0 ; Tonhîhe des Instruments
                bmi.s   L002F           ;negativ
                add.b   seq_note(a0),d0 ;Tonhîhe der Sequenz
                add.b   track_note(a0),d0 ;Track-Note
L002F:          andi.w  #$7f,d0
                lea     teiler_faktor(pc),a1
                add.w   d0,d0           ;*2
                move.w  d0,d1
                move.w  0(a1,d0.w),d0   ;Teilerfaktor fÅr YM 2149

*************** Tongeneratoren & Rauschen ein/ausschalten *******************

                move.b  voice_nr(a0),d3 ;Voice-Nr
                move.b  tune_noise(a0),d2 ;Ton & Noise ?
                bne.s   L0030           ;nein
                bclr    d3,(a5)         ;Ton  einschalten
                addq.w  #3,d3           ;Noise
                bclr    d3,(a5)         ;und das Rauschen dazu einschalten
                bra.s   L0033

L0030:          cmp.b   #1,d2
                bne.s   L0032
                bset    d3,(a5)         ;Ton aus
                addq.w  #3,d3
                bclr    d3,(a5)         ;Rauschen an
                move.b  seq_note(a0),noise_freq(a0)
                move.b  instr_note(a0),d4 ; wenn Instument-Note negativ
                bpl.s   L0031           ;kann die Tonhîhe nicht beeinfluût
                andi.b  #$7f,d4         ;werden
                move.b  d4,noise_freq(a0) ;noise_freq := instr_note
                bra.s   L0033
L0031:          add.b   d4,noise_freq(a0)
                bra.s   L0033

L0032:          bclr    d3,(a5)         ;Ton an
                addq.w  #3,d3
                bset    d3,(a5)         ;Rauschen aus
L0033:          tst.b   noise_freq(a0)  ;Rauschfrequenz definiert ?
                beq.s   L0034           ;nî
                move.b  noise_freq(a0),d3
                not.b   d3
                andi.b  #$1f,d3
                move.b  d3,1(a5)        ;Rauschfrequenz setzen

L0034:                                  ;bra     L0047
                move.b  mmme_flag(pc),d2
                beq     tfmx            ;TFMX-Driver

*************** MMME-Driver **********************************************

                tst.b   tfmx_count(a0)
                beq.s   L0035
                subq.b  #1,tfmx_count(a0)
                bra.s   L0038           ;nix tun

L0035:          moveq   #0,d1
                moveq   #0,d2
                moveq   #0,d3
                move.b  mod_f_work(a0),d1
                move.b  mod_f_max(a0),d2
                move.w  d2,d5
                add.w   d5,d5
                move.b  delta_f(a0),d3
                move.b  flags(a0),d4
                btst    #5,d4
                beq.s   L0036           ;b5=0, addieren

;-------------- subtrahieren ---------------------------------------------

                sub.w   d3,d1
                bpl.s   L0037           ;>0
                moveq   #0,d1           ;minimal 0
                bchg    #5,d4           ;auf add umschalten
                bra.s   L0037

;-------------- addieren -------------------------------------------------

L0036:          add.w   d3,d1
                cmp.w   d5,d1           ;< mof_f_max ?
                ble.s   L0037           ;ja
                move.w  d5,d1           ;auf mod_f_max begrenzen
                bchg    #5,d4           ;auf sub umschalten

L0037:          move.b  d1,mod_f_work(a0)
                move.b  d4,flags(a0)
                sub.w   d2,d1           ;trandformieren, -mod_f_max .... +mod_d_max
                ext.l   d1
                muls    d0,d1
                asr.l   #8,d1           ;/1024
                asr.l   #2,d1
                add.w   d1,d0           ;f := f + f * mod_f_work / 1024

;-------------- Bender ----------------------------------------------------

L0038:          btst    #5,seq_hkurve(a0)
                beq.s   L0039           ;nix benden

                moveq   #0,d1           ;bend_var += (long) seq_instr
                move.b  seq_instr(a0),d1
                ext.w   d1
                ext.l   d1
                move.l  bend_var(a0),d2
                add.l   d1,d2
                move.l  d2,bend_var(a0)

                muls    d0,d2           ;f := f - f * bend_var
                asr.l   #8,d2
                asr.w   #2,d2
                sub.w   d2,d0

L0039:          move.b  hkurve_amplitude(a0),d1 ;Amplitude
                sub.b   track_dÑmpfung(a0),d1
                sub.b   dÑmpfung(a0),d1
                bpl.s   L003A           ;positiv
                moveq   #0,d1           ;wenn negativ, dann 0
L003A:          rts

*************** TFMX-Driver ***********************************
*               Frequenz-Modulation                           *
;d0 : Frequenz fÅr YM
;d1 : Note * 2
;

tfmx:           tst.b   tfmx_count(a0)
                beq.s   L003C
                subq.b  #1,tfmx_count(a0)
                bra.s   L0046           ;nix tun

;die Frequenz wird zwischen -mod_f_max/2 und +mod_f_max/2 in der Schrittweite
;delta_f moduliert
;Wertebereich mod_f_max: 0...127   entspricht 0...254 in 2er Schritten
;                        128...255 entspricht 0... 127

L003C:          move.b  d1,d5           ;Note*2
                move.b  flags(a0),d6    ;Flags
                move.b  mod_f_max(a0),d4 ;max. Frequenzoffset

;Wertebereich vom mod_f_max bestimmen

                bmi.s   L003D
                add.b   d4,d4           ;positiv, *2
                bra.s   L003E
L003D:          andi.b  #$7f,d4         ;negativ, Bit 7 ausblenden

L003E:          move.b  mod_f_work(a0),d1
                tst.b   d6              ;b7 = 0?
                bpl.s   L003F           ;ja
                btst    d7,d6           ;btst #0,d6
                bne.s   L0042           ;b0=1, nicht addieren | subtrahieren
L003F:          btst    #5,d6           ;b5 = 1 ?
                bne.s   L0040           ;ja

;-------------- b5 = 0, subtrahieren ------------------------------

                sub.b   delta_f(a0),d1  ;
                bcc.s   L0041           ;positive
                bset    #5,d6           ;b5 = 1, jetzt addieren
                moveq   #0,d1           ;0
                bra.s   L0041

;-------------- b5 = 1, addieren ----------------------------------

L0040:          add.b   delta_f(a0),d1  ;
                cmp.b   d4,d1           ;mod_f_max  > d1 ?
                bcs.s   L0041           ;ja
                bclr    #5,d6           ;mod_f_max < d1, jetzt subtrahieren
                move.b  d4,d1           ;auf mod_f_max_setzen

L0041:          move.b  d1,mod_f_work(a0) ;verÑnderter Wert zurÅck

L0042:          lsr.b   #1,d4           ;/2
                sub.b   d4,d1           ;Null-Linie auf die Mitte verschieben
                bcc.s   L0043           ;d1 ist positiv
                subi.w  #$0100,d1       ;obere Byte = $ff
L0043:          addi.b  #160,d5         ;2*48+160=256
                bcs.s   L0045           ;>$ff,die oberen 4 Oktaven werden
;                                       ;direkt mit den berechneten delta f
;                                       ;moduliert, da die Teilerfaktoren
;                                       ;relative kleine Werte haben

;die unteren 4 Oktaven: der Frequenzhub wird fÅr jede Oktave verdoppelt
;(logo, da eine Oktave auch einer Frequenzverdopllung entspricht )

L0044:          add.w   d1,d1           ;*2
                addi.b  #24,d5          ;2*12, um eine Oktave erhîhen
                bcc.s   L0044           ;<= $ff

L0045:          add.w   d1,d0           ;Frequenz modulieren
                bchg    d7,d6           ;bchg #0,d6
                move.b  d6,flags(a0)    ;Flags speichern

*************** Frequenz-Bender  *******************************************

;bend_var ist eine Festkommazahl, d.h. obere Word ist der Int-Teil
;das untere Word enthÑlt die Nachkomma-Stellen
;gebendet wird um seq_instr, dort ist das obere Nibbel der Int-Teil und
;das untere Nibbel die Nachkommastellen

L0046:          btst    #5,seq_hkurve(a0)
                beq.s   L0047           ;nix tun
                moveq   #0,d1
                move.b  seq_instr(a0),d1
                ext.w   d1
                swap    d1
                asr.l   #4,d1           ;vvvvvvvv vvvvxxxx xxxx0000 00000000
                move.l  bend_var(a0),d2 ;holen
                add.l   d1,d2           ;was dazuaddieren
                move.l  d2,bend_var(a0) ;wieder Speichern
                swap    d2              ;Integer-Anteil
                sub.w   d2,d0           ;von der Frequenz abziehen

L0047:          move.b  hkurve_amplitude(a0),d1 ;Amplitude
                sub.b   track_dÑmpfung(a0),d1
                sub.b   dÑmpfung(a0),d1
                bpl.s   L0048           ;positiv
                moveq   #0,d1           ;wenn negativ, dann 0
L0048:          rts


default_hÅll:   dc.b $01,$00,$00,$00,$00
                dc.b $00,$00,$e1

voice_nr_tab:   dc.b $00,$01,$02
                dc.b $00

ym_set:         dc.l $00                ;diese Werte werden dann in den
                dc.l $01010000          ;Soundchip Åbertragen
                dc.l $02020000
                dc.l $03030000
                dc.l $04040000
                dc.l $05050000
                dc.l $06060000
ym_7:           dc.l $0707ffff          ;alles aus
                dc.l $08080000
                dc.l $09090000
                dc.l $0a0a0000

voice3_channel: dc.b 0,0,0,0
                dc.b 2,6,34,0           ;YM-Reg 0, 1, 8
                dc.b 10,14,38,0         ;YM-Reg 2, 3, 9
                dc.b 18,22,42,0         ;YM-Reg 4, 5, 10

L004D:          ds.w 1
L004E:          dc.b $00,$01,$02,$03,$04,$05,$06,$07
                dc.b $08,$09,$0a,$0b,$0f,$0f,$0f,$0f
                dc.b $0f,$0f
L004F:          ds.w 2
L0050:          ds.b 8
play_speed_count:dc.w $04
play_speed:     dc.w $04
L0053:          dc.b $ff,$00

voice0:         ds.w 18
                dc.b $00
L0055:          dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00
                ds.w 4
voice1:         ds.b 54
voice2:         ds.b 54
gerÑusch_voice: ds.b 54
                dc.b $00,$40
track_length:   ds.w 1
sequenz:        ds.w 2
inst:           ds.w 2
hÅll_kurve:     ds.w 2
tracks:         ds.w 3
L005E:          ds.w 2
gerÑusch_nr:    ds.w 2
L0060:          ds.w 1
start_gerÑusch: ds.w 1
adr_coso:       ds.l 1
L0063:          dc.b $00
mmme_flag:      dc.b $00

* 8 Oktaven von c1...h1 ( 32,7 ... 61,7 Hz )
*           bis c5...h5 (4186 ... 7902,1 Hz ) ( die hohen Freq sind leider
*                                               etwas ungenau )


teiler_faktor:  dc.w 3822,3607,3405,3214,3033,2863,2702,2551,2407,2272,2145,2024
                dc.w 1911,1803,1702,1607,1516,1431,1351,1275,1203,1136,1072,1012
                dc.w 955,901,851,803,758,715,675,637,601,568,536,506
                dc.w 477,450,425,401,379,357,337,318,300,284,268,253
                dc.w 238,225,212,200,189,178,168,159,150,142,134,126
                dc.w 119,112,106,100,94,89,84,79,75,71,67,63
                dc.w 59,56,53,50,47,44,42,39,37,35,33,31
                dc.w 29,28,26,25,23,22,21,19,18,17,16,15
                ds.w 32

coso:
                if test
                path 'F:\MUSIC\'
                ibytes 'ELANDS4.MUS'
                else
                dc.l 'COSO'
                dc.l s1-coso            ;Instrumente
                dc.l s2-coso            ;HÅllkurven
                dc.l s3-coso            ;Sequenzen
                dc.l s4-coso            ;Tracks
                dc.l s5-coso            ;Sound-Nr Tabelle
                dc.l s6-coso            ;Effekte (?)
                dc.l coso-coso
                dc.l 'TFMX'

* dc.w Anz der Instr - 1, Anz der HÅllkurven - 1, Anz der Sequenzen - 1

                dc.w $0f,$15,$77,$da,$40,$04,$01,$00,$00,$00,$00,$00,$00,$00

s1:
* ( 64 )
* 16 Instrumente

                dc.b $00,$60,$00,$65,$00,$6b,$00,$79
                dc.b $00,$8a,$00,$8e,$00,$cc,$00,$d6
                dc.b $00,$e0,$01,$0a,$01,$0e,$01,$14
                dc.b $01,$1a,$01,$20,$01,$2c,$01,$39

; Reset hkurven-Index, Noise off / Tune on, Note1, Note 2, Ende

                dc.b $e2,$e6,12,0,$e1

                dc.b $e2,$e5,$96,$e6,$00,$e1

                dc.b $e2,$e5,$96,$e6,$97
                dc.b $93,$8d,$88,$85,$8c,$8d,$8b,$85,$e1

                dc.b $e2,$e5,$96,$e6,$9e,$9f,$e4
                dc.b $96,$9e,$9e,$9d,$9d,$9c,$9c,$e5
                dc.b $96,$e1,$e2,$e5,$9f,$e1,$e2,$e6
                dc.b $00,$00,$e8,$10,$00,$00,$e3,$02
                dc.b $04,$00,$00,$e8,$10,$00,$e3,$03
                dc.b $05,$00,$00,$e8,$10,$00,$e3,$04
                dc.b $06,$00,$00,$e8,$10,$00,$e3,$05
                dc.b $07,$00,$00,$e8,$10,$00,$e3,$06
                dc.b $07,$00,$00,$e8,$10,$00,$e3,$07
                dc.b $07,$00,$00,$e8,$10,$00,$e3,$08
                dc.b $08,$00,$00,$e1,$e2,$e6,$00,$00
                dc.b $03,$03,$07,$07,$e0,$02,$e2,$e6
                dc.b $00,$00,$02,$02,$07,$07,$e0,$02
                dc.b $e2,$e5,$96,$e6,$24,$23,$22,$21
                dc.b $20,$1f,$1e,$1d,$1c,$1b,$1a,$19
                dc.b $18,$17,$16,$15,$14,$13,$12,$11
                dc.b $10,$0f,$0e,$0d,$0c,$0b,$0a,$09
                dc.b $08,$07,$06,$05,$04,$03,$02,$01
                dc.b $00,$e1,$e2,$e6,$bd,$e1,$e2,$e9
                dc.b $3c,$e6,$00,$e1,$e2,$e9,$43,$e6
                dc.b $00,$e1,$e2,$e9,$4a,$e6,$00,$e1
                dc.b $e2,$e6,$0c,$00,$e8,$20,$00,$e3
                dc.b $01,$02,$00,$e1,$e2,$e6,$0c,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$e0
                dc.b $01,$e2,$e6,$00,$e1,$00

* Die 22 HÅllkurven *
* ( 318 )

s2:             dc.b $01,$6a,$01,$80,$01,$a6,$01,$c8
                dc.b $01,$e5,$01,$f3,$02,$02,$02,$0a
                dc.b $02,$1f,$02,$28,$02,$3d,$02,$52
                dc.b $02,$5f,$02,$9f,$02,$b6,$02,$cc
                dc.b $02,$d3,$02,$da,$02,$e1,$02,$ec
                dc.b $03,$1e,$03,$26


                dc.b $03,$00,$02,$03,$04
                dc.b $0f,$0e,$0d,$0c,$0b,$0a,$09
                dc.b $08,$07,$06,$05,$04,$03,$02,$01
                dc.b $00,$e1


                dc.b $01,$01,$01,$01,$00
                dc.b $0d,$0f,$0f,$0e,$0e,$0d,$0d,$0c,$0c
                dc.b $0b,$0b,$0a,$0a,$09,$09,$08,$08
                dc.b $07,$07,$06,$06,$05,$05,$04,$04
                dc.b $03,$03,$02,$02,$01,$01,$00,$e1


                dc.b $01,$01,$01,$01,$00,$0c,$0d,$0d
                dc.b $0c,$0c,$0b,$0b,$0a,$0a,$09,$09
                dc.b $08,$08,$07,$07,$06,$06,$05,$05
                dc.b $04,$04,$03,$03,$02,$02,$01,$01
                dc.b $00,$e1

                dc.b $01,$01,$00,$00,$00,$0a
                dc.b $0b,$0b,$0a,$0a,$09,$09,$08,$08
                dc.b $07,$07,$06,$06,$05,$05,$04,$04
                dc.b $03,$03,$02,$02,$01,$00,$e1

                dc.b $01
                dc.b $02,$00,$00,$00,$0e,$0f,$0f,$0f
                dc.b $0f,$0c,$0a,$00,$e1,$01,$03,$00
                dc.b $00,$00,$0d,$0f,$0f,$0f,$0e,$0d
                dc.b $0c,$0a,$00,$e1,$01,$04,$00,$00
                dc.b $00,$0e,$00,$e1,$03,$05,$01,$01
                dc.b $04,$0e,$0d,$0c,$0b,$0a,$09,$08
                dc.b $07,$06,$05,$04,$03,$02,$01,$00
                dc.b $e1,$01,$05,$01,$01,$00,$0e,$0d
                dc.b $0c,$e1,$03,$06,$00,$00,$00,$0e
                dc.b $0d,$0c,$0b,$0a,$09,$08,$07,$06
                dc.b $05,$04,$03,$02,$01,$00,$e1,$03
                dc.b $07,$00,$00,$00,$0e,$0d,$0c,$0b
                dc.b $0a,$09,$08,$07,$06,$05,$04,$03
                dc.b $02,$01,$00,$e1,$01,$08,$00,$00
                dc.b $00,$0d,$0f,$0f,$0c,$0c,$0a,$00
                dc.b $e1,$01,$09,$0c,$04,$00,$0d,$0e
                dc.b $0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d
                dc.b $0d,$0d,$0c,$0c,$0c,$0c,$0b,$0b
                dc.b $0b,$0b,$0a,$0a,$0a,$0a,$0a,$0a
                dc.b $0a,$09,$09,$09,$09,$08,$08,$08
                dc.b $08,$07,$07,$07,$07,$06,$06,$06
                dc.b $06,$05,$05,$05,$05,$05,$04,$04
                dc.b $04,$04,$04,$03,$03,$03,$02,$01
                dc.b $e1,$01,$09,$0c,$04,$00,$0e,$0e
                dc.b $0d,$0d,$0c,$0b,$0a,$09,$08,$07
                dc.b $06,$05,$04,$03,$02,$01,$00,$e1
                dc.b $01,$05,$01,$01,$06,$0d,$0e,$0d
                dc.b $0c,$0b,$0a,$09,$08,$07,$06,$05
                dc.b $04,$03,$02,$01,$00,$e1,$02,$0a
                dc.b $03,$02,$00,$10,$e1,$02,$0b,$01
                dc.b $02,$00,$10,$e1,$01,$0c,$00,$00
                dc.b $00,$10,$e1,$04,$0d,$01,$01,$0f
                dc.b $0c,$0d,$0e,$0d,$0c,$e1,$02,$0e
                dc.b $01,$02,$04,$0f,$0e,$0d,$0c,$0d
                dc.b $0c,$0b,$0a,$0c,$0b,$0a,$09,$0b
                dc.b $0a,$09,$08,$0a,$09,$08,$07,$09
                dc.b $08,$07,$06,$08,$07,$06,$05,$07
                dc.b $06,$05,$04,$06,$05,$04,$03,$05
                dc.b $04,$03,$02,$03,$02,$01,$00,$e1
                dc.b $01,$0f,$01,$02,$07,$0e,$0d,$e1
                dc.b $05,$0f,$01,$02,$0a,$08,$09,$0a
                dc.b $0b,$0c,$0d,$0e,$0d,$0c,$0d,$0c
                dc.b $0b,$0a,$0b,$e0,$0d,$00

*               die Sequenzen (828)
s3:
                dc.w $042c,$042f,$0456,$0477
                dc.b $04,$8e,$04,$a9,$04,$cc,$04,$ef
                dc.b $05,$00,$05,$1b,$05,$40,$05,$65
                dc.b $05,$8a,$05,$af,$05,$d4,$05,$f7
                dc.b $06,$1a,$06,$3d,$06,$61,$06,$85
                dc.b $06,$9a,$06,$c1,$06,$e6,$07,$0d
                dc.b $07,$34,$07,$57,$07,$7a,$07,$9d
                dc.b $07,$c0,$07,$e3,$08,$06,$08,$29
                dc.b $08,$4c,$08,$6f,$08,$92,$08,$b5
                dc.b $08,$d8,$08,$fb,$09,$22,$09,$49
                dc.b $09,$8c,$09,$a4,$09,$b5,$09,$ce
                dc.b $09,$eb,$0a,$0c,$0a,$17,$0a,$3b
                dc.b $0a,$55,$0a,$98,$0a,$db,$0b,$1e
                dc.b $0b,$27,$0b,$34,$0b,$3e,$0b,$4b
                dc.b $0b,$55,$0b,$5f,$0b,$68,$0b,$8b
                dc.b $0b,$b4,$0b,$d7,$0b,$f0,$0c,$09
                dc.b $0c,$1e,$0c,$4b,$0c,$5c,$0c,$73
                dc.b $0c,$98,$0c,$ab,$0c,$b0,$0c,$d4
                dc.b $0c,$f7,$0d,$1a,$0d,$33,$0d,$58
                dc.b $0d,$5d,$0d,$68,$0d,$6f,$0d,$74
                dc.b $0d,$7f,$0d,$88,$0d,$9f,$0d,$ac
                dc.b $0d,$b5,$0d,$c8,$0d,$db,$0d,$ee
                dc.b $0d,$ff,$0e,$12,$0e,$25,$0e,$34
                dc.b $0e,$39,$0e,$3c,$0e,$3f,$0e,$42
                dc.b $0e,$61,$0e,$84,$0e,$ab,$0e,$cc
                dc.b $0e,$d7,$0e,$e2,$0e,$f7,$0f,$1a
                dc.b $0f,$2b,$0f,$4e,$0f,$71,$0f,$94
                dc.b $0f,$99,$0f,$c0,$0f,$e3,$10,$06
                dc.b $10,$29,$10,$2e,$10,$39,$10,$3e
                dc.b $10,$43,$10,$48,$10,$4d,$10,$52

*               (1068)


                dc.b $fd,$1f,$ff        ;Pause
;3

* $fd, time     Pause
* $fe, time     Wartezeit bis zur nÑchsten Note
* Tonhîhe, Instrument

                dc.b $fe,$05,$0c,$00    ;seq 1
                dc.b $fe,$01,$0c,$00
                dc.b $fe,$03,$18,$00
                dc.b $fe,$01,$0c,$00
                dc.b $fe,$03,$14,$00
                dc.b $fe,$01,$0c,$00
                dc.b $fe,$03,$13,$00
                dc.b $fe,$01,$11,$00
                dc.b $0f,$00
                dc.b $0a,$00
                dc.b $0b,$00
                dc.b $ff
;42
                dc.b $fe,$05,$0c,$00    ;seq 2
                dc.b $fe,$01,$0c,$00
                dc.b $fe,$03,$18,$00,$fe,$01
                dc.b $0c,$00,$fe,$03,$14,$00,$13,$00
                dc.b $11,$00,$fe,$01,$0f,$00,$0a,$00
                dc.b $0b,$00,$ff,$fe,$03,$30,$00,$2b
                dc.b $00,$fe,$05,$2e,$00,$fe,$03,$29
                dc.b $00,$2b,$00,$2e,$00,$fe,$05,$30
                dc.b $00,$ff,$fe,$03,$30,$00,$2b,$00
                dc.b $fe,$05,$2e,$00,$fe,$03,$29,$00
                dc.b $fe,$01,$2b,$00,$fe,$03,$29,$00
                dc.b $27,$00,$24,$00,$ff,$fe,$01,$30
                dc.b $00,$30,$01,$2b,$00,$2b,$01,$2e
                dc.b $00,$2e,$01,$2e,$02,$29,$00,$29
                dc.b $01,$2b,$00,$2b,$01,$2e,$00,$2e
                dc.b $01,$30,$00,$30,$01,$30,$02,$ff
                dc.b $fe,$01,$30,$00,$30,$01,$2b,$00
                dc.b $2b,$01,$2e,$00,$2e,$01,$2e,$02
                dc.b $29,$00,$29,$02,$2b,$00,$29,$00
                dc.b $29,$01,$27,$00,$27,$01,$24,$00
                dc.b $24,$01,$ff,$fe,$03,$0c,$04,$fe
                dc.b $0b,$18,$0f,$fe,$03,$0c,$04,$fe
                dc.b $0b,$18,$0f,$ff,$fe,$03,$0c,$04
                dc.b $fe,$0b,$18,$0f,$fe,$01,$0c,$04
                dc.b $0c,$05,$18,$0f,$0c,$05,$24,$0f
                dc.b $0c,$05,$18,$0f,$18,$0f,$ff,$fe
                dc.b $01,$0c,$00,$18,$0b,$24,$0b,$0c
                dc.b $00,$0c,$00,$18,$0b,$0c,$0b,$0c
                dc.b $00,$18,$0b,$24,$0b,$0c,$00,$fe
                dc.b $03,$18,$0b,$fe,$01,$0c,$00,$18
                dc.b $0b,$0c,$00,$ff,$fe,$01,$0c,$00
                dc.b $24,$0b,$18,$0b,$0c,$00,$0c,$00
                dc.b $fe,$03,$24,$0b,$fe,$01,$0c,$00
                dc.b $18,$0b,$0c,$00,$0c,$00,$18,$0b
                dc.b $0c,$00,$18,$0b,$0c,$00,$24,$0b
                dc.b $ff,$fe,$01,$0c,$00,$24,$0b,$18
                dc.b $0b,$0c,$00,$0c,$01,$24,$0b,$18
                dc.b $0b,$0c,$00,$fe,$03,$18,$0b,$fe
                dc.b $01,$0c,$00,$24,$0b,$0c,$01,$0c
                dc.b $00,$18,$0b,$0c,$00,$ff,$fe,$01
                dc.b $0c,$00,$24,$0b,$18,$0b,$0c,$00
                dc.b $0c,$01,$fe,$03,$24,$0b,$fe,$01
                dc.b $0c,$00,$18,$0b,$0c,$01,$0c,$00
                dc.b $24,$0b,$0c,$01,$18,$0b,$0c,$01
                dc.b $24,$0b,$ff,$fe,$01,$0c,$00,$24
                dc.b $0b,$18,$0b,$0c,$00,$0c,$01,$fe
                dc.b $03,$24,$0b,$fe,$01,$0c,$00,$24
                dc.b $0b,$0c,$00,$0c,$00,$24,$0b,$0c
                dc.b $01,$18,$0b,$0c,$00,$0c,$00,$ff
                dc.b $fe,$01,$0c,$00,$0c,$02,$0c,$02
                dc.b $0c,$00,$0c,$01,$0c,$02,$0c,$02
                dc.b $0c,$00,$0c,$02,$0c,$02,$0c,$00
                dc.b $0c,$02,$0c,$01,$0c,$00,$0c,$02
                dc.b $0c,$00,$ff,$fe,$01,$0c,$00,$0c
                dc.b $02,$0c,$02,$0c,$00,$0c,$01,$0c
                dc.b $02,$0c,$02,$0c,$00,$0c,$02,$0c
                dc.b $00,$0c,$00,$0c,$02,$0c,$01,$0c
                dc.b $02,$0c,$00,$0c,$00,$ff,$fe,$01
                dc.b $0c,$00,$0c,$02,$0c,$02,$0c,$00
                dc.b $0c,$01,$0c,$02,$0c,$02,$0c,$00
                dc.b $0c,$02,$0c,$01,$0c,$00,$0c,$02
                dc.b $0c,$01,$0c,$02,$0c,$01,$0c,$02
                dc.b $ff,$fe,$01,$30,$00,$30,$00,$33
                dc.b $00,$30,$00,$33,$00,$35,$00,$36
                dc.b $00,$36,$20,$10,$b7,$00,$36,$00
                dc.b $37,$00,$3a,$00,$3c,$00,$3f,$00
                dc.b $41,$00,$3f,$00,$ff,$fe,$01,$41
                dc.b $00,$41,$00,$3f,$00,$3f,$20,$21
                dc.b $c1,$00,$3f,$00,$41,$00,$3f,$00
                dc.b $3c,$00,$3a,$00,$35,$00,$37,$00
                dc.b $33,$00,$30,$00,$36,$00,$37,$00
                dc.b $ff,$fe,$01,$33,$00,$fe,$11,$33
                dc.b $00,$fe,$03,$33,$00,$fe,$01,$30
                dc.b $00,$fe,$05,$2e,$00,$ff,$fe,$01
                dc.b $0c,$00,$0c,$00,$fe,$03,$07,$00
                dc.b $fe,$01,$0a,$00,$07,$00,$0a,$00
                dc.b $fe,$03,$0c,$00,$fe,$01,$0f,$00
                dc.b $11,$00,$12,$00,$13,$00,$16,$00
                dc.b $18,$00,$0b,$00,$ff,$fe,$01,$0a
                dc.b $00,$0a,$00,$16,$00,$fe,$03,$0a
                dc.b $00,$fe,$01,$0a,$00,$0a,$00,$0c
                dc.b $00,$0e,$00,$0a,$00,$0a,$00,$0a
                dc.b $00,$16,$00,$0a,$00,$16,$00,$15
                dc.b $00,$ff,$fe,$01,$08,$00,$08,$00
                dc.b $14,$00,$fe,$03,$08,$00,$fe,$01
                dc.b $08,$00,$fe,$03,$14,$00,$fe,$01
                dc.b $14,$00,$08,$00,$0a,$00,$08,$00
                dc.b $0b,$00,$08,$00,$0f,$00,$16,$00
                dc.b $ff,$fe,$01,$0c,$00,$0c,$00,$fe
                dc.b $03,$07,$00,$fe,$01,$0a,$00,$07
                dc.b $00,$0b,$00,$fe,$03,$0c,$00,$fe
                dc.b $01,$18,$00,$16,$00,$13,$00,$11
                dc.b $00,$12,$00,$13,$00,$16,$00,$ff
                dc.b $fe,$01,$3c,$00,$37,$00,$3a,$00
                dc.b $37,$00,$3c,$00,$37,$00,$3f,$00
                dc.b $3c,$00,$36,$00,$37,$00,$3a,$00
                dc.b $3c,$00,$3f,$00,$41,$00,$42,$00
                dc.b $43,$00,$ff,$fe,$01,$43,$00,$46
                dc.b $00,$48,$00,$41,$00,$46,$00,$48
                dc.b $00,$43,$00,$46,$00,$48,$00,$41
                dc.b $00,$46,$00,$48,$00,$43,$00,$42
                dc.b $00,$41,$00,$3f,$00,$ff,$fe,$01
                dc.b $3f,$00,$41,$00,$42,$00,$43,$00
                dc.b $46,$00,$48,$00,$4b,$00,$46,$00
                dc.b $48,$00,$46,$00,$43,$00,$41,$00
                dc.b $3f,$00,$3c,$00,$3a,$00,$3b,$00
                dc.b $ff,$fe,$01,$3c,$00,$37,$00,$3a
                dc.b $00,$37,$00,$3c,$00,$37,$00,$3f
                dc.b $00,$3c,$00,$3f,$00,$35,$00,$36
                dc.b $00,$37,$00,$3a,$00,$37,$00,$3a
                dc.b $00,$3b,$00,$ff,$fe,$01,$3c,$00
                dc.b $37,$00,$3a,$00,$37,$00,$3c,$00
                dc.b $37,$00,$3f,$00,$3c,$00,$3f,$00
                dc.b $41,$00,$42,$00,$43,$00,$46,$00
                dc.b $43,$00,$46,$00,$47,$00,$ff,$fe
                dc.b $01,$48,$00,$43,$00,$46,$00,$47
                dc.b $00,$48,$00,$46,$00,$43,$00,$46
                dc.b $00,$4b,$00,$41,$00,$46,$00,$48
                dc.b $00,$46,$00,$43,$00,$42,$00,$41
                dc.b $00,$ff,$fe,$01,$3f,$00,$41,$00
                dc.b $43,$00,$41,$00,$42,$00,$43,$00
                dc.b $41,$00,$43,$00,$46,$00,$43,$00
                dc.b $46,$00,$47,$00,$46,$00,$48,$00
                dc.b $4b,$00,$4d,$00,$ff,$fe,$01,$4d
                dc.b $00,$4b,$00,$4d,$00,$4e,$00,$4f
                dc.b $00,$4e,$00,$4d,$00,$4b,$00,$4d
                dc.b $00,$4f,$00,$52,$00,$4d,$00,$4f
                dc.b $00,$52,$00,$4f,$00,$52,$00,$ff
                dc.b $fe,$01,$54,$00,$52,$00,$4f,$00
                dc.b $4d,$00,$4f,$00,$4d,$00,$4b,$00
                dc.b $48,$00,$46,$00,$48,$00,$4b,$00
                dc.b $4d,$00,$4e,$00,$4f,$00,$52,$00
                dc.b $53,$00,$ff,$fe,$01,$54,$00,$52
                dc.b $00,$4f,$00,$57,$00,$52,$00,$4f
                dc.b $00,$56,$00,$52,$00,$4f,$00,$4d
                dc.b $00,$4f,$00,$4d,$00,$4b,$00,$4d
                dc.b $00,$52,$00,$53,$00,$ff,$fe,$01
                dc.b $54,$00,$52,$00,$4f,$00,$57,$00
                dc.b $52,$00,$4f,$00,$56,$00,$52,$00
                dc.b $4f,$00,$4d,$00,$4b,$00,$48,$00
                dc.b $46,$00,$43,$00,$46,$00,$47,$00
                dc.b $ff,$fe,$01,$3c,$00,$37,$00,$3a
                dc.b $00,$37,$00,$3c,$00,$3a,$00,$3f
                dc.b $00,$3c,$00,$36,$00,$37,$00,$3a
                dc.b $00,$3c,$00,$3f,$00,$41,$00,$42
                dc.b $00,$43,$00,$ff,$fe,$01,$43,$00
                dc.b $46,$00,$48,$00,$41,$00,$46,$00
                dc.b $4a,$00,$43,$00,$46,$00,$4b,$00
                dc.b $41,$00,$46,$00,$4a,$00,$43,$00
                dc.b $42,$00,$41,$00,$3f,$00,$ff,$fe
                dc.b $01,$48,$00,$48,$00,$46,$20,$20
                dc.b $48,$00,$48,$00,$46,$20,$20,$48
                dc.b $00,$48,$00,$4b,$00,$46,$20,$20
                dc.b $48,$00,$48,$00,$4b,$00,$4d,$00
                dc.b $4b,$00,$46,$20,$20,$ff,$fe,$01
                dc.b $48,$00,$48,$00,$46,$20,$20,$48
                dc.b $00,$4b,$00,$46,$20,$20,$48,$00
                dc.b $4b,$00,$4d,$00,$46,$20,$20,$48
                dc.b $00,$48,$00,$4b,$00,$4d,$00,$4b
                dc.b $00,$46,$20,$20,$ff,$fe,$00,$54
                dc.b $00,$52,$00,$4f,$00,$4d,$00,$4f
                dc.b $00,$4d,$00,$4b,$00,$48,$00,$4b
                dc.b $00,$48,$00,$46,$00,$43,$00,$46
                dc.b $00,$43,$00,$41,$00,$3f,$00,$41
                dc.b $00,$3f,$00,$3c,$00,$3a,$00,$3c
                dc.b $00,$3a,$00,$37,$00,$35,$00,$37
                dc.b $00,$35,$00,$33,$00,$30,$00,$2e
                dc.b $00,$30,$00,$33,$00,$35,$00,$ff
                dc.b $fe,$0d,$30,$01,$fe,$01,$2e,$21
                dc.b $60,$fe,$07,$b0,$00,$fe,$01,$33
                dc.b $00,$35,$00,$36,$00,$37,$00,$ff
                dc.b $fd,$11,$fe,$05,$18,$00,$fe,$03
                dc.b $18,$00,$fe,$01,$18,$00,$18,$00
                dc.b $ff,$fe,$05,$0c,$00,$fe,$01,$0c
                dc.b $00,$fe,$05,$0c,$00,$0c,$00,$0c
                dc.b $00,$fe,$03,$0c,$00,$fe,$01,$0c
                dc.b $00,$ff,$fe,$05,$0c,$00,$fe,$01
                dc.b $0c,$00,$fe,$05,$0c,$00,$0c,$00
                dc.b $fe,$01,$0c,$00,$07,$00,$0a,$00
                dc.b $07,$00,$05,$00,$06,$00,$ff,$fe
                dc.b $05,$0c,$00,$fe,$01,$0c,$00,$fe
                dc.b $05,$0c,$00,$fe,$03,$0c,$00,$fe
                dc.b $01,$0c,$00,$0f,$00,$0c,$00,$0f
                dc.b $00,$11,$00,$12,$00,$16,$00,$ff
                dc.b $fe,$13,$30,$00,$fe,$05,$30,$00
                dc.b $2e,$01,$ff,$fe,$01,$41,$00,$41
                dc.b $00,$3f,$00,$3f,$20,$21,$c1,$00
                dc.b $3f,$00,$41,$00,$43,$00,$46,$00
                dc.b $41,$00,$42,$00,$43,$00,$41,$00
                dc.b $3f,$00,$3c,$00,$3a,$00,$ff,$fe
                dc.b $0d,$30,$01,$fe,$01,$2e,$21,$30
                dc.b $b0,$00,$2e,$00,$30,$00,$2e,$00
                dc.b $30,$00,$2e,$00,$2b,$00,$27,$00
                dc.b $ff,$fe,$00,$48,$00,$43,$00,$46
                dc.b $00,$43,$00,$4a,$00,$43,$00,$46
                dc.b $00,$43,$00,$48,$00,$43,$00,$46
                dc.b $00,$43,$00,$4a,$00,$43,$00,$46
                dc.b $00,$43,$00,$4b,$00,$43,$00,$46
                dc.b $00,$43,$00,$4f,$00,$43,$00,$46
                dc.b $00,$43,$00,$4d,$00,$43,$00,$46
                dc.b $00,$43,$00,$4b,$00,$43,$00,$46
                dc.b $00,$43,$00,$ff,$fe,$00,$48,$00
                dc.b $43,$00,$46,$00,$43,$00,$4a,$00
                dc.b $43,$00,$46,$00,$43,$00,$4b,$00
                dc.b $43,$00,$46,$00,$43,$00,$48,$00
                dc.b $43,$00,$46,$00,$43,$00,$4d,$00
                dc.b $43,$00,$46,$00,$43,$00,$4b,$00
                dc.b $43,$00,$46,$00,$43,$00,$4a,$00
                dc.b $43,$00,$46,$00,$43,$00,$48,$00
                dc.b $43,$00,$46,$00,$43,$00,$ff,$fe
                dc.b $00,$54,$00,$52,$00,$4f,$00,$4d
                dc.b $00,$4f,$00,$4d,$00,$4b,$00,$48
                dc.b $00,$4b,$00,$48,$00,$46,$00,$43
                dc.b $00,$46,$00,$43,$00,$41,$00,$3f
                dc.b $00,$3c,$00,$3f,$00,$41,$00,$43
                dc.b $00,$41,$00,$43,$00,$46,$00,$48
                dc.b $00,$46,$00,$48,$00,$4b,$00,$4d
                dc.b $00,$4b,$00,$4d,$00,$52,$00,$53
                dc.b $00,$ff,$fe,$19,$3c,$00,$fe,$05
                dc.b $3c,$00,$ff,$fe,$17,$3f,$00,$fe
                dc.b $01,$3a,$00,$fe,$05,$3c,$00,$ff
                dc.b $fe,$07,$3a,$20,$0c,$fe,$17,$bc
                dc.b $00,$ff,$fe,$17,$3f,$00,$fe,$01
                dc.b $41,$00,$fe,$05,$42,$00,$ff,$fe
                dc.b $07,$41,$20,$08,$fe,$17,$43,$00
                dc.b $ff,$fe,$07,$3a,$20,$04,$fe,$17
                dc.b $bc,$00,$ff,$fe,$01,$0c,$00,$fe
                dc.b $1d,$0c,$00,$ff,$fe,$01,$0c,$00
                dc.b $0c,$00,$0c,$02,$0c,$02,$0c,$01
                dc.b $0c,$02,$0c,$02,$0c,$00,$0c,$02
                dc.b $0c,$01,$0c,$00,$0c,$02,$0c,$01
                dc.b $0c,$02,$0c,$02,$0c,$01,$ff,$fe
                dc.b $01,$0c,$00,$0c,$00,$0c,$02,$0c
                dc.b $02,$0c,$01,$0c,$00,$0c,$02,$0c
                dc.b $00,$0c,$02,$0c,$01,$0c,$00,$0c
                dc.b $02,$0c,$01,$0c,$02,$fe,$00,$0c
                dc.b $01,$0c,$01,$0c,$01,$0c,$01,$ff
                dc.b $fe,$01,$0c,$00,$0c,$02,$0c,$00
                dc.b $0c,$02,$0c,$01,$0c,$02,$0c,$00
                dc.b $0c,$00,$0c,$02,$0c,$01,$0c,$00
                dc.b $0c,$02,$0c,$01,$0c,$02,$0c,$01
                dc.b $0c,$01,$ff,$fe,$01,$0c,$00,$fe
                dc.b $0f,$0c,$00,$fe,$01,$0f,$00,$0c
                dc.b $00,$0a,$00,$0c,$00,$0f,$00,$11
                dc.b $00,$12,$00,$ff,$fe,$01,$0c,$00
                dc.b $fe,$0f,$0c,$00,$fe,$01,$18,$00
                dc.b $16,$00,$13,$00,$12,$00,$11,$00
                dc.b $0f,$00,$0a,$00,$ff,$fe,$03,$3c
                dc.b $01,$fe,$05,$3c,$02,$3c,$02,$3c
                dc.b $02,$3c,$02,$fe,$01,$3c,$02,$3c
                dc.b $02,$ff,$fe,$03,$3c,$01,$fe,$01
                dc.b $3c,$02,$fe,$03,$18,$00,$3c,$02
                dc.b $fe,$01,$18,$00,$fe,$03,$3c,$02
                dc.b $fe,$01,$18,$00,$fe,$03,$3c,$02
                dc.b $fe,$01,$18,$00,$fe,$00,$3c,$02
                dc.b $18,$00,$fe,$01,$3c,$02,$ff,$fe
                dc.b $01,$13,$00,$fe,$17,$13,$00,$fe
                dc.b $01,$13,$00,$16,$00,$18,$00,$ff
                dc.b $fe,$01,$0c,$00,$fe,$11,$0c,$00
                dc.b $fe,$03,$0c,$00,$fe,$01,$11,$00
                dc.b $12,$00,$13,$00,$11,$00,$ff,$fe
                dc.b $01,$0c,$00,$fe,$03,$0c,$00,$fe
                dc.b $01,$0c,$00,$fe,$05,$0c,$00,$fe
                dc.b $03,$0c,$01,$fe,$01,$0c,$01,$fe
                dc.b $03,$0c,$01,$0c,$01,$fe,$01,$0c
                dc.b $01,$0c,$01,$ff,$fe,$03,$0c,$01
                dc.b $fe,$13,$0c,$02,$fe,$01,$18,$00
                dc.b $16,$00,$13,$00,$11,$00,$ff,$fe
                dc.b $1f,$0c,$00,$ff,$fe,$01,$41,$00
                dc.b $41,$00,$3f,$00,$3f,$20,$21,$c1
                dc.b $00,$3f,$00,$41,$00,$3f,$00,$3c
                dc.b $00,$3a,$00,$37,$00,$35,$00,$37
                dc.b $00,$3a,$00,$3b,$00,$3c,$00,$ff
                dc.b $fe,$01,$0c,$00,$0c,$02,$0c,$02
                dc.b $0c,$00,$0c,$05,$0c,$02,$0c,$02
                dc.b $0c,$00,$0c,$02,$0c,$02,$0c,$00
                dc.b $0c,$02,$0c,$05,$0c,$00,$0c,$02
                dc.b $0c,$00,$ff,$fe,$01,$0c,$00,$0c
                dc.b $02,$0c,$02,$0c,$00,$0c,$05,$0c
                dc.b $02,$0c,$02,$0c,$00,$0c,$02,$0c
                dc.b $05,$0c,$00,$0c,$02,$0c,$05,$0c
                dc.b $02,$0c,$05,$0c,$05,$ff,$fe,$01
                dc.b $0c,$04,$fe,$0f,$0c,$04,$fe,$01
                dc.b $0c,$05,$0c,$05,$0c,$05,$0c,$05
                dc.b $0c,$05,$0c,$05,$0c,$05,$ff,$fe
                dc.b $01,$0c,$00,$fe,$05,$0c,$00,$fe
                dc.b $01,$0f,$00,$11,$00,$12,$00,$fe
                dc.b $03,$13,$00,$fe,$01,$13,$00,$16
                dc.b $00,$18,$00,$1d,$00,$1b,$00,$16
                dc.b $00,$17,$00,$ff,$fe,$1f,$27,$00
                dc.b $ff,$fe,$1b,$27,$00,$fe,$01,$28
                dc.b $00,$27,$00,$ff,$fe,$0f,$30,$00
                dc.b $33,$00,$ff,$fe,$1f,$0c,$00,$ff
                dc.b $fe,$0f,$32,$00,$fe,$07,$33,$00
                dc.b $35,$00,$ff,$fe,$1b,$37,$00,$fe
                dc.b $03,$35,$00,$ff,$fe,$07,$37,$00
                dc.b $fe,$03,$35,$00,$33,$00,$fe,$07
                dc.b $32,$00,$fe,$01,$2e,$00,$fe,$05
                dc.b $30,$00,$ff,$fe,$00,$48,$00,$3c
                dc.b $00,$30,$00,$fe,$1c,$24,$00,$ff
                dc.b $fe,$17,$0c,$00,$fe,$07,$0c,$00
                dc.b $ff,$fe,$03,$33,$00,$33,$00,$33
                dc.b $00,$33,$00,$33,$00,$33,$00,$37
                dc.b $00,$37,$00,$ff,$fe,$03,$35,$00
                dc.b $35,$00,$35,$00,$35,$00,$38,$00
                dc.b $38,$00,$38,$00,$38,$00,$ff,$fe
                dc.b $03,$37,$00,$37,$00,$37,$00,$37
                dc.b $00,$37,$00,$37,$00,$37,$00,$37
                dc.b $00,$ff,$fe,$07,$0c,$00,$fe,$0f
                dc.b $0c,$00,$fe,$05,$0c,$00,$fe,$01
                dc.b $0c,$00,$ff,$fe,$03,$38,$00,$38
                dc.b $00,$38,$00,$38,$00,$3a,$00,$3a
                dc.b $00,$3a,$00,$3a,$00,$ff,$fe,$03
                dc.b $37,$00,$37,$00,$37,$00,$37,$00
                dc.b $30,$00,$30,$00,$30,$00,$32,$00
                dc.b $ff,$fe,$01,$0c,$00,$18,$00,$fe
                dc.b $0b,$0c,$00,$fe,$0f,$0c,$00,$ff
                dc.b $fe,$1f,$30,$00,$ff,$fd,$1f,$ff
                dc.b $fd,$1f,$ff,$fd,$1f,$ff,$fe,$07
                dc.b $3c,$00,$fe,$03,$3a,$00,$38,$00
                dc.b $fe,$00,$37,$00,$38,$00,$fe,$01
                dc.b $37,$00,$38,$00,$35,$00,$fe,$03
                dc.b $37,$00,$33,$00,$ff,$fe,$03,$35
                dc.b $00,$fe,$01,$37,$00,$38,$00,$fe
                dc.b $03,$3a,$00,$38,$00,$fe,$00,$37
                dc.b $00,$38,$00,$37,$00,$38,$00,$fe
                dc.b $03,$35,$00,$fe,$07,$37,$00,$ff
                dc.b $fe,$03,$33,$00,$fe,$01,$35,$00
                dc.b $37,$00,$fe,$03,$35,$00,$33,$00
                dc.b $fe,$00,$32,$00,$33,$00,$32,$00
                dc.b $33,$00,$32,$00,$33,$00,$fe,$01
                dc.b $32,$00,$fe,$07,$30,$00,$ff,$fe
                dc.b $03,$38,$00,$fe,$01,$3a,$00,$38
                dc.b $00,$fe,$03,$37,$00,$fe,$01,$35
                dc.b $00,$33,$00,$35,$00,$37,$00,$38
                dc.b $00,$35,$00,$fe,$07,$37,$00,$ff
                dc.b $fe,$07,$0c,$00,$0c,$00,$11,$00
                dc.b $11,$00,$ff,$fe,$07,$13,$00,$13
                dc.b $00,$07,$00,$07,$00,$ff,$fe,$07
                dc.b $13,$00,$13,$00,$fe,$03,$0c,$00
                dc.b $fe,$01,$0c,$00,$0c,$00,$fe,$07
                dc.b $0c,$00,$ff,$fe,$03,$30,$00,$fe
                dc.b $01,$30,$00,$30,$00,$fe,$03,$30
                dc.b $00,$30,$00,$fe,$01,$30,$00,$30
                dc.b $00,$fe,$03,$30,$00,$30,$00,$fe
                dc.b $01,$30,$00,$30,$00,$ff,$fe,$07
                dc.b $0c,$00,$fe,$03,$0c,$01,$0c,$00
                dc.b $fe,$07,$0c,$00,$0c,$01,$ff,$fe
                dc.b $01,$0c,$00,$0c,$03,$18,$03,$0c
                dc.b $03,$0c,$01,$0c,$03,$0c,$00,$0c
                dc.b $03,$0c,$00,$0c,$03,$18,$03,$0c
                dc.b $03,$0c,$01,$18,$03,$0c,$03,$18
                dc.b $03,$ff,$fe,$01,$13,$00,$13,$03
                dc.b $1f,$03,$13,$03,$13,$01,$13,$03
                dc.b $13,$00,$13,$03,$13,$00,$13,$03
                dc.b $1f,$03,$13,$03,$0c,$01,$18,$03
                dc.b $0c,$03,$18,$03,$ff,$fe,$03,$2b
                dc.b $00,$fe,$01,$2b,$00,$2b,$00,$fe
                dc.b $03,$2b,$00,$2b,$00,$fe,$01,$2b
                dc.b $00,$2b,$00,$fe,$03,$2b,$00,$30
                dc.b $00,$fe,$01,$30,$00,$30,$00,$ff
                dc.b $fe,$1f,$0c,$00,$ff,$fe,$01,$0c
                dc.b $00,$0c,$00,$fe,$03,$07,$00,$fe
                dc.b $01,$0a,$00,$07,$00,$0b,$00,$fe
                dc.b $03,$0c,$00,$fe,$01,$18,$00,$16
                dc.b $00,$13,$00,$12,$00,$11,$00,$0f
                dc.b $00,$0a,$00,$ff,$fe,$01,$0c,$04
                dc.b $24,$01,$30,$01,$24,$01,$0c,$05
                dc.b $24,$01,$0c,$04,$30,$01,$0c,$04
                dc.b $2e,$01,$2e,$02,$2b,$01,$0c,$05
                dc.b $2e,$01,$30,$01,$30,$02,$ff,$fe
                dc.b $01,$24,$00,$27,$00,$2b,$00,$30
                dc.b $00,$2b,$00,$27,$00,$35,$00,$37
                dc.b $00,$3a,$00,$3c,$00,$35,$00,$37
                dc.b $00,$3a,$00,$3c,$00,$3f,$00,$3e
                dc.b $00,$ff,$fe,$01,$3a,$00,$3c,$00
                dc.b $3f,$00,$3a,$00,$3c,$00,$41,$00
                dc.b $3a,$00,$3c,$00,$43,$00,$3a,$00
                dc.b $3c,$00,$41,$00,$3a,$00,$3c,$00
                dc.b $3f,$00,$3c,$00,$ff,$fe,$1f,$30
                dc.b $00,$ff,$fe,$0f,$33,$00,$fe,$07
                dc.b $32,$00,$30,$00,$ff,$fe,$1f,$32
                dc.b $00,$ff,$fe,$1f,$33,$00,$ff,$fe
                dc.b $1f,$37,$00,$ff,$fe,$1f,$3a,$00
                dc.b $ff,$fe,$1f,$3e,$00,$ff,$fe,$0f
                dc.b $24,$00,$a4,$20,$80,$ff


s4:
*               die Tracks
*               4 Bytes Voice 1, 4 Bytes Voice 2, 4 Bytes Voice 3

* 1. Byte: Sequenz
* 2. Byte: Tonhîhe mit der die Sequenz transformiert wird
* 3. Byte: Instrument

                dc.b $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

                dc.b $01,$00,$00,$00,$4b,$00,$12,$00,$00,$00,$00,$ff
                dc.b $02,$00,$00,$00,$4b,$ff,$12,$00,$00,$00,$00,$00
                dc.b $01,$00,$00,$00,$4b,$fb,$12,$00,$00,$00,$00,$00
                dc.b $02,$00,$00,$00,$4b,$f9,$12,$00,$00,$00,$00,$00
                dc.b $01,$00,$00,$00,$4b,$f8,$12,$00,$00,$00,$00,$00
                dc.b $02,$00,$00,$00,$4b,$f6,$12,$00,$00,$00,$00,$00
                dc.b $01,$00,$00,$00,$4b,$f8,$12,$00,$00,$00,$00,$00
                dc.b $02,$00,$00,$00,$00,$f8,$12,$00,$00,$00,$00,$00
                dc.b $01,$00,$00,$00,$4b,$00,$12,$00,$03,$00,$01,$f0
                dc.b $02,$00,$00,$00,$4b,$ff,$12,$00,$04,$00,$01,$00
                dc.b $01,$00,$00,$00,$4b,$fb,$12,$00,$03,$00,$01,$00
                dc.b $02,$00,$00,$00,$4b,$f9,$12,$00,$04,$00,$01,$00
                dc.b $01,$00,$00,$00,$4b,$f8,$12,$00,$03,$00,$01,$00
                dc.b $02,$00,$00,$00,$4b,$f6,$12,$00,$04,$00,$01,$00
                dc.b $01,$00,$00,$00,$4b,$f8,$12,$00,$03,$00,$01,$00
                dc.b $02,$00,$00,$00,$00,$f8,$12,$00,$04,$00,$01,$00
                dc.b $01,$00,$00,$00,$4b,$00,$12,$00,$05,$00,$01,$00
                dc.b $02,$00,$00,$00,$4b,$02,$12,$00,$06,$00,$01,$00
                dc.b $01,$00,$00,$00,$4b,$04,$12,$00,$05,$00,$01,$00
                dc.b $02,$00,$00,$00,$4b,$05,$12,$00,$06,$00,$01,$00
                dc.b $01,$00,$00,$00,$4b,$04,$12,$00,$05,$00,$01,$00
                dc.b $02,$00,$00,$00,$4b,$07,$12,$00,$06,$00,$01,$00
                dc.b $01,$00,$00,$00,$4b,$09,$12,$00,$05,$00,$01,$00
                dc.b $02,$00,$00,$00,$00,$09,$12,$00,$06,$00,$01,$00
                dc.b $01,$00,$00,$00,$4b,$f6,$12,$00,$05,$00,$01,$00
                dc.b $02,$00,$00,$00,$4b,$f4,$12,$00,$06,$00,$01,$00
                dc.b $01,$00,$00,$00,$4c,$f3,$12,$00,$05,$00,$01,$00
                dc.b $02,$00,$00,$00,$4b,$f1,$12,$00,$06,$00,$01,$00
                dc.b $01,$00,$00,$00,$4b,$f1,$0f,$00,$05,$00,$01,$00
                dc.b $02,$00,$00,$00,$00,$f1,$00,$00,$06,$00,$01,$00
                dc.b $01,$00,$00,$00,$07,$00,$00,$00,$05,$00,$01,$00
                dc.b $02,$00,$00,$00,$07,$00,$00,$00,$06,$00,$01,$00
                dc.b $01,$00,$00,$00,$07,$00,$00,$00,$05,$00,$01,$00
                dc.b $02,$00,$00,$00,$06,$00,$01,$00,$08,$00,$00,$00
                dc.b $01,$00,$00,$00,$05,$00,$01,$00,$09,$00,$04,$00
                dc.b $02,$00,$00,$00,$06,$00,$01,$00,$0a,$00,$04,$00
                dc.b $01,$00,$00,$00,$05,$00,$01,$00,$09,$00,$04,$00
                dc.b $02,$00,$00,$00,$06,$00,$01,$00,$0a,$00,$04,$00
                dc.b $01,$00,$00,$00,$05,$00,$01,$00,$0b,$00,$04,$00
                dc.b $02,$00,$00,$00,$06,$00,$01,$00,$0d,$00,$04,$00
                dc.b $01,$00,$00,$00,$05,$00,$01,$00,$0b,$00,$04,$00
                dc.b $02,$00,$00,$00,$06,$00,$01,$00,$0c,$00,$04,$00
                dc.b $2a,$00,$00,$00,$00,$00,$00,$00,$0e,$00,$04,$00
                dc.b $2b,$00,$00,$00,$29,$00,$0b,$00,$0f,$00,$04,$00
                dc.b $2a,$00,$00,$00,$00,$00,$00,$00,$0e,$00,$04,$00
                dc.b $2c,$00,$00,$00,$29,$00,$0b,$00,$10,$00,$04,$00
                dc.b $14,$00,$00,$00,$4e,$0c,$0f,$00,$0e,$00,$04,$00
                dc.b $15,$00,$00,$00,$4e,$0a,$10,$00,$0f,$00,$04,$00
                dc.b $16,$00,$00,$00,$4e,$08,$11,$00,$0e,$00,$04,$00
                dc.b $17,$00,$00,$00,$4e,$0c,$0f,$00,$10,$00,$04,$00
                dc.b $14,$00,$00,$00,$4e,$0c,$0f,$00,$0e,$00,$04,$00
                dc.b $15,$00,$00,$00,$4e,$0a,$10,$00,$0f,$00,$04,$00
                dc.b $16,$00,$00,$00,$4e,$08,$11,$00,$0e,$00,$04,$00
                dc.b $17,$00,$00,$00,$4e,$0c,$0f,$00,$10,$00,$04,$00
                dc.b $14,$00,$00,$00,$11,$f4,$07,$00,$0e,$00,$04,$00

                dc.b $15,$00,$00,$00,$12,$f4,$07,$00,$0f,$00,$04,$00
                dc.b $16,$00,$00,$00,$13,$f4,$07,$00,$0e,$00,$04,$00
                dc.b $17,$00,$00,$00,$28,$f4,$07,$00,$10,$00,$04,$00
                dc.b $14,$00,$00,$00,$11,$f4,$07,$00,$0e,$00,$04,$00
                dc.b $15,$00,$00,$00,$2e,$f4,$07,$00,$0f,$00,$04,$00
                dc.b $16,$00,$00,$00,$13,$00,$07,$00,$0e,$00,$04,$00
                dc.b $17,$00,$00,$00,$2f,$00,$07,$00,$10,$00,$04,$00
                dc.b $14,$00,$00,$00,$00,$00,$00,$00,$0e,$00,$04,$00
                dc.b $15,$00,$00,$00,$00,$00,$00,$00,$0f,$00,$04,$00
                dc.b $16,$00,$00,$00,$00,$00,$00,$00,$0e,$00,$04,$00
                dc.b $17,$00,$00,$00,$00,$00,$00,$00,$10,$00,$04,$00
                dc.b $14,$00,$00,$00,$00,$00,$00,$00,$0e,$00,$04,$00
                dc.b $15,$00,$00,$00,$00,$00,$00,$00,$0f,$00,$04,$00
                dc.b $16,$00,$00,$00,$00,$00,$00,$00,$0e,$00,$04,$00
                dc.b $17,$00,$00,$00,$00,$00,$00,$00,$10,$00,$04,$00
                dc.b $14,$00,$00,$00,$1d,$f4,$07,$00,$0e,$00,$04,$00
                dc.b $15,$00,$00,$00,$46,$f4,$07,$00,$0f,$00,$04,$00
                dc.b $16,$00,$00,$00,$18,$f4,$07,$00,$0e,$00,$04,$00
                dc.b $17,$00,$00,$00,$19,$f4,$07,$00,$10,$00,$04,$00
                dc.b $14,$00,$00,$00,$11,$f4,$07,$00,$0e,$00,$04,$00
                dc.b $15,$00,$00,$00,$2e,$f4,$07,$00,$0f,$00,$04,$00
                dc.b $16,$00,$00,$00,$1e,$f4,$07,$00,$0e,$00,$04,$00
                dc.b $17,$00,$00,$00,$27,$f4,$07,$00,$10,$00,$04,$00
                dc.b $39,$00,$00,$00,$39,$f4,$00,$00,$0e,$0c,$00,$00
                dc.b $3d,$00,$00,$00,$39,$f4,$00,$00,$0f,$0c,$00,$00
                dc.b $39,$00,$00,$00,$39,$f4,$00,$00,$0e,$0c,$00,$00
                dc.b $3e,$00,$00,$00,$39,$f4,$00,$00,$10,$0c,$00,$00
                dc.b $39,$00,$00,$00,$39,$f4,$00,$00,$47,$0c,$00,$00
                dc.b $3d,$00,$00,$00,$39,$f4,$00,$00,$48,$0c,$00,$00
                dc.b $39,$00,$00,$00,$39,$f4,$00,$00,$47,$0c,$00,$00
                dc.b $4a,$00,$00,$00,$39,$f4,$00,$00,$49,$00,$00,$00
                dc.b $00,$00,$00,$00,$66,$00,$09,$00,$4e,$00,$0f,$00
                dc.b $00,$00,$00,$00,$66,$00,$09,$00,$4e,$00,$0f,$00
                dc.b $00,$00,$00,$00,$66,$fb,$09,$00,$4e,$00,$0f,$00
                dc.b $00,$00,$00,$00,$66,$fb,$09,$00,$4e,$00,$0f,$00
                dc.b $00,$00,$00,$00,$66,$00,$09,$00,$4e,$00,$0f,$00
                dc.b $00,$00,$00,$00,$66,$00,$09,$00,$4e,$00,$0f,$00
                dc.b $00,$00,$00,$00,$66,$fb,$09,$00,$4e,$00,$0f,$00
                dc.b $00,$00,$00,$00,$66,$fb,$09,$00,$4e,$00,$0f,$00
                dc.b $67,$00,$04,$00,$66,$00,$09,$00,$4e,$00,$0f,$00
                dc.b $67,$00,$04,$00,$66,$00,$09,$00,$4e,$00,$0f,$00
                dc.b $67,$00,$04,$00,$66,$fb,$09,$00,$4e,$00,$0f,$00
                dc.b $67,$00,$04,$00,$66,$fb,$09,$00,$4e,$00,$0f,$00
                dc.b $68,$00,$04,$00,$66,$00,$09,$00,$00,$00,$00,$ff
                dc.b $68,$00,$04,$00,$66,$00,$09,$00,$00,$00,$00,$00
                dc.b $68,$07,$04,$00,$66,$fb,$09,$00,$00,$00,$00,$00
                dc.b $68,$07,$04,$00,$66,$fb,$09,$00,$00,$00,$00,$00
                dc.b $68,$00,$04,$00,$66,$00,$09,$00,$5f,$00,$14,$f0
                dc.b $68,$00,$04,$00,$66,$00,$09,$00,$62,$00,$14,$00
                dc.b $68,$07,$04,$00,$66,$fb,$09,$00,$60,$00,$14,$00
                dc.b $69,$00,$04,$00,$6a,$00,$09,$00,$61,$00,$14,$00
                dc.b $68,$00,$04,$00,$66,$00,$09,$00,$5f,$00,$14,$00
                dc.b $68,$00,$04,$00,$66,$00,$09,$00,$62,$00,$14,$00
                dc.b $68,$07,$04,$00,$66,$fb,$09,$00,$60,$00,$14,$00
                dc.b $69,$00,$04,$00,$6a,$00,$09,$00,$61,$00,$14,$00
                dc.b $68,$00,$04,$00,$66,$00,$09,$00,$5f,$00,$13,$00
                dc.b $68,$00,$04,$00,$66,$00,$09,$00,$62,$00,$13,$00
                dc.b $68,$07,$04,$00,$66,$fb,$09,$00,$60,$00,$13,$00
                dc.b $69,$00,$04,$00,$6a,$00,$09,$00,$61,$00,$13,$00
                dc.b $53,$00,$13,$00,$5f,$00,$14,$f3,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$60,$00,$14,$03,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$62,$00,$14,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$61,$00,$14,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$5f,$0c,$13,$00,$4e,$00,$0f,$00
                dc.b $53,$00,$13,$00,$60,$0c,$13,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$62,$0c,$13,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$61,$0c,$13,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$00,$0c,$00,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$00,$0c,$00,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$00,$0c,$00,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$00,$0c,$00,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$54,$00,$00,$f3,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$55,$00,$00,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$56,$00,$00,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$56,$fe,$00,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$56,$fc,$00,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$56,$fb,$00,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$56,$f9,$00,$00,$00,$00,$00,$00
                dc.b $53,$00,$13,$00,$56,$f9,$00,$00,$00,$00,$00,$00
                dc.b $57,$00,$13,$00,$54,$00,$00,$00,$66,$00,$09,$f2
                dc.b $53,$00,$13,$00,$58,$00,$00,$00,$66,$00,$09,$00
                dc.b $57,$00,$13,$00,$56,$00,$00,$00,$66,$00,$09,$00
                dc.b $53,$00,$13,$00,$58,$fd,$00,$00,$66,$00,$09,$00
                dc.b $57,$00,$13,$00,$56,$fc,$00,$00,$66,$00,$09,$00
                dc.b $53,$00,$13,$00,$56,$fb,$00,$00,$66,$00,$0a,$00
                dc.b $57,$00,$13,$00,$56,$f9,$00,$00,$66,$00,$09,$00
                dc.b $53,$00,$13,$00,$59,$fe,$00,$00,$66,$00,$0a,$00
                dc.b $57,$00,$13,$00,$56,$f9,$00,$00,$66,$00,$09,$00
                dc.b $5a,$00,$13,$00,$56,$f9,$00,$00,$66,$00,$09,$00
                dc.b $57,$00,$13,$00,$56,$f9,$00,$00,$66,$0c,$09,$00
                dc.b $57,$00,$13,$00,$56,$f9,$00,$00,$66,$0c,$09,$00
                dc.b $57,$00,$13,$00,$56,$f9,$00,$00,$66,$07,$09,$00
                dc.b $57,$00,$13,$00,$56,$f9,$00,$00,$66,$07,$09,$00
                dc.b $57,$00,$13,$00,$56,$f9,$00,$00,$66,$0c,$09,$00
                dc.b $57,$00,$13,$00,$56,$f9,$00,$00,$66,$0c,$09,$00
                dc.b $6b,$18,$15,$f0,$6b,$1b,$15,$f0,$6b,$1f,$15,$f0
                dc.b $6b,$18,$15,$00,$6b,$1b,$15,$00,$6b,$20,$15,$00
                dc.b $6b,$18,$15,$00,$6b,$1b,$15,$00,$6b,$1f,$15,$00
                dc.b $6b,$18,$15,$00,$6b,$1b,$15,$00,$6b,$1d,$15,$00
                dc.b $6b,$18,$15,$00,$6b,$13,$15,$00,$6b,$1b,$15,$00
                dc.b $6b,$18,$15,$00,$6b,$13,$15,$00,$6b,$1a,$15,$00
                dc.b $6b,$17,$15,$00,$6b,$13,$15,$00,$6b,$1a,$15,$00
                dc.b $6b,$17,$15,$00,$6b,$1a,$15,$00,$6b,$1f,$15,$00
                dc.b $6b,$18,$15,$00,$6b,$1f,$15,$00,$6b,$24,$15,$00
                dc.b $6b,$18,$15,$00,$6b,$1f,$15,$00,$6b,$22,$15,$00
                dc.b $6b,$18,$15,$00,$6b,$1d,$15,$00,$6b,$20,$15,$00
                dc.b $6b,$18,$15,$00,$6b,$1b,$15,$00,$6b,$1f,$15,$00
                dc.b $6b,$18,$15,$00,$6b,$1a,$15,$00,$6b,$1d,$15,$00
                dc.b $6b,$16,$15,$00,$6b,$1a,$15,$00,$6b,$1d,$15,$00
                dc.b $6b,$18,$15,$00,$6b,$1b,$15,$00,$6b,$13,$15,$00
                dc.b $6b,$18,$15,$00,$6b,$0f,$15,$00,$6b,$13,$15,$00
                dc.b $66,$00,$09,$00,$6b,$1b,$15,$00,$6b,$13,$15,$00
                dc.b $66,$00,$09,$00,$6b,$1d,$15,$00,$6b,$14,$15,$00
                dc.b $66,$00,$09,$00,$6b,$1b,$15,$00,$6b,$13,$15,$00
                dc.b $66,$00,$0a,$00,$6b,$1a,$15,$00,$6b,$13,$15,$00
                dc.b $66,$00,$09,$00,$6b,$18,$15,$00,$6b,$13,$15,$00
                dc.b $66,$00,$09,$00,$6b,$0c,$15,$00,$6b,$13,$15,$00
                dc.b $66,$00,$09,$00,$6b,$0c,$15,$00,$6b,$00,$15,$00
                dc.b $66,$00,$09,$00,$6b,$00,$15,$00,$4e,$00,$0f,$00
                dc.b $66,$00,$09,$00,$00,$00,$15,$00,$00,$00,$0f,$00
                dc.b $66,$00,$09,$f1,$6d,$00,$00,$f0,$00,$00,$00,$f0
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$00,$00,$00,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$6e,$0c,$0e,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$6f,$0c,$0e,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$6e,$07,$0e,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$6f,$07,$0e,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$6e,$0c,$0e,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$6f,$0c,$0e,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$6e,$07,$0e,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$6f,$07,$0e,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$70,$00,$14,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$71,$00,$14,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$72,$00,$14,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$00,$00,$14,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$73,$00,$14,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$74,$00,$14,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$75,$00,$14,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$76,$00,$14,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$73,$0c,$14,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$70,$0c,$14,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$75,$00,$14,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$76,$00,$14,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$73,$0c,$14,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$70,$0c,$14,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$76,$00,$14,$00
                dc.b $66,$07,$09,$00,$6d,$07,$00,$00,$00,$00,$14,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$77,$00,$14,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$00,$00,$14,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$4e,$00,$0f,$00
                dc.b $66,$00,$09,$00,$6d,$00,$00,$00,$00,$00,$0f,$00
                dc.b $00,$00,$00,$00,$6d,$00,$00,$00,$00,$00,$0f,$00
                dc.b $00,$00,$00,$00,$6d,$00,$00,$00,$00,$00,$0f,$00
                dc.b $00,$00,$00,$00,$6d,$00,$00,$00,$00,$00,$0f,$00
                dc.b $00,$00,$00,$00,$6d,$00,$00,$00,$00,$00,$0f,$00
                dc.b $00,$00,$00,$00,$67,$00,$04,$00,$00,$00,$0f,$00
                dc.b $00,$00,$00,$00,$67,$00,$04,$00,$00,$00,$0f,$00
                dc.b $4e,$0c,$0f,$f0,$4e,$f4,$0f,$00,$00,$00,$0f,$00
                dc.b $00,$0c,$00,$00,$00,$f4,$00,$00,$00,$00,$0f,$00
                dc.b $00,$0c,$00,$00,$00,$f4,$00,$00,$00,$00,$0f,$00
                dc.b $00,$0c,$00,$00,$00,$f4,$00,$00,$00,$00,$0f,$00

s5:

*               dc.w  start, length, speed

                dc.w $00,$da,$04
                dc.w $00,$00,$00
s6:
                dc.b $00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$07,$77,$0f,$75,$07,$6c
                dc.b $0e,$db,$0d,$ca,$0c,$39,$04,$21
                dc.b $0b,$98,$0a,$10,$02,$80,$04,$77
                dc.b $03,$66,$02,$55,$01,$44,$00,$33
                dc.b $00,$00,$00,$00,$00,$00
                endc
                end
