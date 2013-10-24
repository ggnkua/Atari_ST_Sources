; -------------------------------------------------------
; - Bernd Hbenett (RxT) 01.04.1994 Obertshausen	*
; -							*
; - Dieses Program liefert nur im DC oder True-Color	*
; - Mode des Falcon030 vernnftige Ergebnisse.		*
; - Das Programm sollte nur in Aufl”sungen mit		*
; - 320 Pixeln in X gestartet werden.			*
; - 26.07.1994 RxT: Es sieht so aus als ob seit		*
; - 07:20 Uhr Frac_2.Lod endlich einwandfrei		*
; - arbeitet.						*
; - 27.07.1994 : Langsam mit Optimierungen begonnen.	*
; -------------------------------------------------------

cnecin		EQU 8
logbase		EQU 3
super		EQU 32
vsync		EQU 37

start:		pea	0
		move.w  #super,-(SP)
		trap    #1
		addq.l  #6,SP
		move.l  D0,ssp

		move.w  #logbase,-(SP)
		trap    #14
		addq.l  #2,SP
		move.l  D0,scr

; --- Aus debugging Zwecken aužer Bertrieb
;		lea     bin_file,A0     ; Startadress of the BIN-File
;               move.l  (A0)+,D0        ; lenght in DSP-Words
;              move.w  #3,-(SP)        ; 3 Bytes = DSP-Word
;             move.l  D0,-(SP)        ; Lenght
;            move.l  A0,-(SP)        ; DSP-Data
;           move.w  #109,-(SP)      ; DSP-ExecProg
;          trap    #14
;         lea     12(SP),SP

; 31.05.1994 RxT Bernd Hbenett
; Der folgende DSP_LoadProg XBIOS-Aufruf arbeitet
; mit Fractal.Lod (=Ursprung) einwandfrei.
		pea     bild
		move.w  #3,-(SP)
		pea     lod_file
		move.w  #108,-(SP)
		trap    #14
		lea     12(SP),SP

		lea     $FFFFA200,A2
		movea.l scr,A1
		move.w  #199,D2
		lea     koordinaten,A0
mainloop:       move.w  #4,D1
host_send:      move.l  (A0)+,$FFFFA204 ; CPU->DSP via Host-Interface (Parameter)
		dbra    D1,host_send

host_receive:   btst    #0,$FFFFA202    ; Warten bis der
		beq.s   host_receive    ; DSP fertig ist

		move.w  #319,D1         ; 320 Pixel
rec_loop:       move.w  $FFFFA206,(A1)+ ; DSP->CPU via Host-Interface (16-Bit)
		dbra    D1,rec_loop

		lea     koordinaten,A0
		move.l  16(A0),D3
		move.l  20(A0),D4
		add.l   D3,D4
		move.l  D4,16(A0)

		dbra    D2,mainloop


tastatur:       move.w  #7,-(SP)
		trap    #1
		addq.l  #2,SP

raus:           move.l  ssp,-(SP)
		move.w  #super,-(SP)
		trap    #1
		addq.l  #6,SP

		clr.w   -(SP)
		trap    #1

		DATA
koordinaten:    DC.L $24        ; depth		       Offset 0
		DC.L $FFE66667  ; x1h		         Offset 4
		DC.L $4CCC      ; xdelta		      Offset 8
		DC.L $0140      ; width = 320		 Offset 12
		DC.L $FFE051EC  ; y1h		         Offset 16
		DC.L $51EB      ; ydelta		      Offset 20
		DC.L $C7        ; height = 199		Offset 24
		EVEN
bin_file:       incbin	'FRAC_2.BIN'
		EVEN
lod_file:       DC.B 'FRAC_2.LOD',0
		BSS
oldmode:        DS.L 1
oldphys:        DS.L 1
oldlog:         DS.L 1
scr:            DS.L 1
ssp:            DS.L 1
dta:            DS.B 30
		EVEN
bild:           DS.L 50000
video_room:
		END
