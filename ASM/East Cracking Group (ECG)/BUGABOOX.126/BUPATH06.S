*
* BUGABOO 1.26 PATCH-LOADER  (v0.6 +++)
* the east cracking group
*
                OPT D-

; v0.6:
;------
;       another E7D (or EDB) write found   (DRAGONFLIGHT crashte daher an 0xEBC)


; v0.5:
;-------
;       E7D / E9B


; v0.4:
;-------
;       trap #1  custom-handler works now
;       logical sector bug removed (crap on screen after dir on harddisks
;                                   with large logical sectors - you may
;                                   get a 'Åberlauf' when
;                                   doing <dir>, but it doesn't do any harm.
;                                   (I hope.))


start:
                movea.l 4(SP),A6
                lea     own_stk(PC),SP
                pea     ende-start+$0100.w ;ProgrammlÑnge
                move.l  A6,-(SP)
                move.l  #$4A0000,-(SP)
                trap    #1              ;Mshrink()
                lea     12(SP),SP

                pea     info(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
;
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                move.l  #$1C0000,D6
                moveq   #5,D7           ;6 numbers input
input_start:
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                moveq   #0,D1
                cmp.b   #$0D,D0
                beq.s   return
                cmp.b   #$30,D0
                blt.s   input_start     ;kleiner null
                cmp.b   #$39,D0
                ble.s   number_input
char_input:
                and.l   #%11111,D0
                cmp.b   #7,D0
                bge.s   input_start

                rol.l   #4,D5
                move.b  D0,D1
                add.b   #9,D1
                add.b   #$40,D0
                bra.s   out_number
number_input:
                rol.l   #4,D5
                and.l   #$FF,D0
                move.b  D0,D1
                and.l   #%1111,D1
out_number:
                moveq   #0,D2
                move.b  D7,D2
                subi.b  #1,D2
                move.l  #$0F,D3
rol:            rol.l   #4,D1
                rol.l   #4,D3
                dbra    D2,rol
                not.l   D3
                and.l   D3,D6
                or.l    D1,D6
                move.w  D0,-(SP)
                move.w  #6,-(SP)
                trap    #1
                addq.l  #4,SP
                dbra    D7,input_start
return:
                pea     out_cur(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP


                clr.b   sys_tf
                pea     sys_t(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP

                cmp.b   #'Y',D0
                bne.s   n_Y
                move.b  #1,sys_tf
n_Y:
                cmp.b   #'y',D0
                bne.s   n_y
                move.b  #1,sys_tf
n_y:



****
; d6- number
                movea.l $2C(A6),A5      ;Adresse des Environment-Strings
                movea.l A5,A0
loop:           tst.b   (A5)+           ;2 Nullbytes suchen
                bne.s   loop
                tst.b   (A5)+
                bne.s   loop
                suba.l  A0,A5           ;LÑnge des Environment-Strings

                pea     -1.w
                move.w  #$48,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,-(SP)
                move.w  #$48,-(SP)
                trap    #1              ;Malloc(all)
                addq.l  #6,SP           ;Anfangsadresse des freien Speichers
                tst.l   D0
                beq     abbruch         ;Speicher reichte nicht

                sub.l   D0,D6           ;- Anfangsadr des freien Speichers
                ble     abbruch         ;Adresse zu groû? Ja! =>

                move.l  D0,-(SP)
                move.w  #$49,-(SP)
                trap    #1              ;Mfree(all)
                addq.l  #6,SP

                move.l  D6,-(SP)
                move.w  #$48,-(SP)
                trap    #1              ;Malloc(Differenz)
                addq.l  #6,SP
                tst.l   D0              ;ist oben kein Speicher mehr frei?
                beq     abbruch         ;scheint so =>
                movea.l D0,A5           ;Adresse merken

                move.l  $2C(A6),-(SP)   ;Zeiger auf den Envionment-String
                pea     $80(A6)         ;Zeiger auf die Commandline
                pea     fname(PC)
                move.l  #$4B0003,-(SP)
                trap    #1              ;Pexec(load only)
                lea     16(SP),SP
                move.l  D0,D7           ;Basepageadr merken
                bmi     abbruch
;
                movea.l D0,A1
                adda.l  #256,A1


; PATCH BUGABOO
;              A1 - START TEXTSEGMENT BUGABOO

;----------------------------   v0.4 additions -----------------
;$84 stuff
;;      DC.L $4AFC4E71
                lea     (A1),A0
                adda.l  #$026C4E-$01E4EA-$0100,A0
                move.w  #$6026,(A0)
                nop
                lea     (A1),A0
                adda.l  #$026CB8-$01E4EA-$0100,A0
                move.w  #$6020,(A0)
                nop

;remove logical sector bug
                move.w  #$4E75,$023C8E-$01E4EA-$0100(A1)

;----------------------------   v0.4 additions  end ------------




                tst.b   sys_tf
                beq     keep_bugaboo



                move.l  #$4E714E71,D0
                move.w  D0,$A6(A1)      ;remove turbo-ass abfrage
                move.b  #$60,$C4(A1)
;patch systemvector - zugriffe
                lea     (A1),A2
                adda.l  #$AC96,A2
                move.w  #$4E75,(A2)     *
;
                move.l  D0,$50E4(A1)
                move.w  D0,$50E8(A1)    *

                lea     (A1),A2
                adda.l  #$BAA0,A2
                move.l  D0,(A2)         *

                lea     (A1),A2
                adda.l  #$BC0C,A2
                move.l  D0,(A2)         *

                lea     (A1),A2
                adda.l  #$BF28,A2
                move.l  D0,(A2)         *

                lea     (A1),A2
                adda.l  #$BF66,A2
                move.l  D0,(A2)
                move.w  D0,4(A2)        *
;
                lea     (A1),A2
                adda.l  #$8684,A2
                move.l  D0,(A2)
                move.l  D0,4(A2)        *

                lea     (A1),A2
                adda.l  #$86EA,A2
                move.l  D0,(A2)
                move.w  D0,4(A2)        *

                lea     (A1),A2
                adda.l  #$AB56,A2
                move.l  D0,(A2)
                move.w  D0,4(A2)        *

                lea     (A1),A2
                adda.l  #$AB70,A2
                move.l  D0,(A2)
                move.l  D0,4(A2)        *

                lea     (A1),A2
                adda.l  #$AEA0,A2
                move.l  D0,(A2)
                move.l  D0,4(A2)        *

;
                lea     (A1),A2
                adda.l  #$03AE,A2
                move.l  D0,(A2)         *

                lea     (A1),A2
                adda.l  #$BB84,A2
                move.l  D0,(A2)         *

                lea     (A1),A2
                adda.l  #$C7F4,A2
                move.l  D0,(A2)         *
;
;patch bugaboo vbl:
                lea     (A1),A2
                adda.l  #$C9B4,A2
;
                move.l  #$11FC0002,(A2)+
                move.l  #$820A4238,(A2)+
                move.w  #$FA1B,(A2)+
;
                move.w  #$4E73,(A2)     ;rte
;----------------------------------------------------------------------
; remove semaphores to low memory
;
; E7D (oder andere) changes          pointer: 1F0E(A4)
;
                move.w  D0,$70D6(A1)    ; was:  clr.b (a0)
                lea     (A1),A2
                adda.l  #$81EE,A2
                move.l  D0,(A2)         ; was:  andi.b #$10,(a0)
                lea     (A1),A2
                adda.l  #$A74E,A2
                move.l  D0,(A2)         ; was:  andi.b #$10,(a0)           *v06*

; E9B (oder andere) changes          pointer: 1EFA(A4)
                lea     (A1),A2
                adda.l  #$BFAC,A2
                move.w  D0,(A2)         ; was:  clr.b (a0)
keep_bugaboo:

;
                move.l  A5,-(SP)
                move.w  #$49,-(SP)
                trap    #1              ;Mfree(Differenz)
                addq.l  #6,SP
****************
ch_irqs:
                tst.b   sys_tf
                beq.s   keep_irqs

                movem.l D0-A6,-(SP)

                lea     (A1),A6
                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
;
                move.w  #$4E73,$34.w    ;rte
                lea     $68.w,A0
                moveq   #5,D1
c00:            move.l  #$34,(A0)+
                dbra    D1,c00
;
                lea     $C0.w,A0
                moveq   #32,D1
c01:            move.l  #$34,(A0)+
                dbra    D1,c01
;
;reset adress to $30 --> cartridge + F9
                lea     (A6),A4
                lea     (A6),A5
                adda.l  #$BCD2,A6
                move.l  A6,$30.w


;sub-rout fÅr $e7d und $e9b zugriffe
;--------- REMOVED -----------------


                move.w  #$70,$FFFF8240.w
;
                move.l  D0,-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

                movem.l (SP)+,D0-A6
;

keep_irqs:
                move.l  D7,-(SP)
                clr.l   -(SP)
                move.l  #$4B0004,-(SP)
                trap    #1              ;Pexec(Start)
                lea     12(SP),SP
                subq.l  #1,D0           ;Exitcode = 1?
                bne.s   abbruch         ;Nein! =>
                clr.w   -(SP)           ;Debugger soll resident bleiben!
                pea     128.w           ;nur ein Teil der Basepage bleibt resident
                move.w  #$31,-(SP)      ;Ptermres()
                trap    #1              ;damit der Debugger nicht gelîscht wird

abbruch:        clr.w   -(SP)
                trap    #1              ;Pterm0()


                DATA
info:
                DC.B 27,"H",27,"E"
                DC.B 27,"p"
                DC.B "*****************************",10,13
                DC.B "BUGABOO V1.26+++     v0.6    ",10,13
                DC.B "- - - - - - - - - - - - - - -",10,13
                DC.B "Patched version by the E.C.G.",10,13
                DC.B "- - - - - - - - - - - - - - -",10,13
                DC.B "Cartridge start: F9 - bugaboo",10,13
                DC.B "*****************************",10,13
                DC.B "- - - - - - - - - - - - - - -",10,13
                DC.B "v0.6: another e7b removed    ",10,13
                DC.B "v0.5: e7b/e9b write removed  ",10,13
                DC.B "v0.4: custom $84 works now   ",10,13
                DC.B "- - - - - - - - - - - - - - -",10,13
                DC.B 27,"q"
                DC.B 10,10,13
                DC.B "input start adress: $1C0000"
                REPT 6
                DC.B 27,"D"
                ENDR
                DC.B 27,"e"
                DC.B 0
out_cur:        DC.B 27,"f",0
sys_t:          DC.B 10,13,"Shutdown sysvecs (Y):",0

sys_tf:         DC.B 0

                EVEN
fname:          DC.B 'BUGABOO.PRG',0    ;Das wird geladen (der Debugger)
                BSS
                DS.L 256
own_stk:        DS.L 0                  ;Jedem seinen Stack
ende:           END




;sub-rout fÅr $e7d und $e9b zugriffe
                adda.l  #$011F04,A4
                adda.l  #$011EF0,A5
                lea     $0140.w,A0

                move.l  #$33FC0036,(A0)+
                move.l  A4,(A0)+        ;$e7d

                move.l  #$33FC0037,(A0)+
                move.l  A5,(A0)         ;$39b





                lea     $80.w,A0
                lea     old_80(PC),A1
                moveq   #16-1,D0
restore_traps:  move.l  (A1)+,(A0)+
                dbra    D0,restore_traps
                END
