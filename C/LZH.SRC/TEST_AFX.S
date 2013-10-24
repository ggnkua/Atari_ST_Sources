debug           EQU 0
_onoff          EQU 8

	export test_afx

; Modul testet, ob eine Datei mit AFX gepackt ist oder werden darf.
test_afx:       movem.l D1-a6,-(SP)
                moveq   #0,D0
                bsr     afxonoff        ; AFX ausschalten
                move.l  D0,-(SP)        ; Alten Zustand merken

                movea.l A0,A4
                pea     1026.w
                move.w  #$48,-(SP)      ; Malloc
                trap    #1
                addq.l  #6,SP
                addq.l  #1,D0
                and.b   #$FE,D0         ; auf gerade Adresse
                movea.l D0,A5           ; 1k Speicher


                clr.w   -(SP)
                move.l  A4,-(SP)        ; filename
                move.w  #$3D,-(SP)      ; fopen
                trap    #1
                addq.l  #8,SP
                tst.l   D0
                bmi.b   unpacked        ; micht gefunden
                move.l  D0,D3           ; Handle
                move.l  A5,-(SP)
                pea     1024.w
                move.w  D3,-(SP)        ; handle
                move.w  #$3F,-(SP)      ; fread
                trap    #1
                lea     12(SP),SP

                move.w  D3,-(SP)
                move.w  #$3E,-(SP)      ; close
                trap    #1
                addq.l  #4,SP

; A5 zeigt auf die ersten 1KB des Files. teste nun auf Programm und auf
; AFX.
                cmpi.w  #$601A,(A5)
                beq.b   is_prg          ; Ist eine Programmdatei

                movea.l A5,A0
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                move.b  (A0)+,D1
                move.b  (A0)+,D2
                subq.w  #1,D1
get_chk:        add.b   (A0)+,D0
                dbra    D1,get_chk
                cmp.b   D0,D2
                seq     D0              ; D0 = 0: Checksum stimmt nicht
                bne.b   unpacked        ; Stimmt nicht: Ungepackt
                cmpi.l  #'-afx',2(A5)
                beq.b   is_afx          ; Kein AFX
				cmpi.w  #'-l',2(a5)
				bne.b   unpacked
				cmpi.b  #'-',6(a5)
			    beq.b	is_lzh

unpacked:       moveq   #0,D3
                bra.b   testx
is_afx:         moveq   #1,D3
                bra.b   testx
is_lzh:         moveq   #2,D3
                bra.b   testx
is_prg:         moveq   #3,D3

testx:          move.l  A5,-(SP)
                move.w  #$49,-(SP)      ; Mfree
                trap    #1
                addq.l  #6,SP

                move.l  (SP)+,D0        ; Alter Status
                bsr.b   afxonoff        ; wiederherstellen
                move.l  D3,D0
                movem.l (SP)+,D1-a6

                rts



afxonoff:       movem.l D1-A6,-(SP)
                bsr.b   find_afx
                cmpa.l  #0,A4
                beq.b   onofX
                move.l  _onoff(A4),D1
                move.l  D0,_onoff(A4)
                move.l  D1,D0
onofX:          movem.l (SP)+,D1-A6
                rts




find_afx:       move.l  D0,-(SP)
                clr.l   -(SP)           ; stck
                move.w  #$20,-(SP)      ; super
                trap    #1
                addq.l  #6,SP
                move.l  D0,-(SP)
                move.w  #$20,-(SP)      ; super
                movea.l $84,A4
find_afx1:      cmpi.l  #'XBRA',-12(A4)
                bne.b   no_afx
                cmpi.l  #'AFX ',-8(A4)
                beq.b   found_afx
                movea.l -4(A4),A4
                bra.b   find_afx1
no_afx:         trap    #1
                addq.l  #6,SP
                suba.l  A4,A4
                move.l  (SP)+,D0
                rts
found_afx:      lea     -16(A4),A4
                move.l  (A4),D0
                lea     0(A4,D0.w),A4
                cmpi.l  #'PARX',-4(A4)
                bne.b   no_afx
                trap    #1
                addq.l  #6,SP
                move.l  (SP)+,D0
                rts

                IF debug
filename:
;                DC.B 'C:\SYSTEM\MISHELL.PRG',0
                DC.B 'E:\TEX\MISHELL\MB.TEX',0
                ENDC
                END
