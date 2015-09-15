; PRTKL881 - Protokoll fÅr M68881 - Version 2.0
; programmiert von Volker Hemsen, August 1993, Public Domain

; Dieses Programm ist Public Domain! Es ist unverkÑuflich und darf von jeder-
; man benutzt und kopiert werden. Es ist unverkÑuflich!
; Hiermit wird ausdrÅcklich erlaubt, den Quellcode zu verÑndern und zu
; erweitern!

; Folgende Befehle werden nicht bearbeitet:
; fscc '), fdbcc '), ftrapcc, fbcc.l '), fsave, frestore, fmovem ')
; verwendete Literatur: Atari Profibuch ST-STE-TT, Sybex Verlag

; ') 1995 H.Robbers; Verwendete Literatur:
;		MOTOROLA
;		MC68881/MC68882 Floating point Coprocessor User's Manual
;		Prentice Hall   ISBN 0-13-566936-7
;		paragraph numbers refer to this publication

;		use USP !!
;		fbcc now works incl. both .w and .l
;		fdbcc & fscc incorporated.
;		fmovem incorporated, along with
;		response 'transfer single main processor register' now works

;		Furthermore it is delicately optimized for speed
;		Time is as expensive as ever.
;		computer memory gets cheaper and cheaper.

		globl	FPEM_lineF,FPEM_oldF

LINE_F	equ		0xfffffa40

; usage of registers	a0 = pc

a_wk	equ 	a2			; !! use only between put_regs & get_regs
a_ea	equ 	a1			; produced by getea

d_wk 	equ		d3			; see a2
d_ct	equ 	d2
d_rp	equ 	d1

XL		equ		12

		offset
FP_resp:
		ds		1			; response primitive
FP_cntl:
		ds		1			; control
FP_save:
		ds		1			; save
FP_restore:
		ds		1			; restore
		ds		1
FP_cmd:	ds		1			; command
		ds		1
FP_ccr:	ds		1			; condition code
FP_opnd:
		ds.l	1			; operand
FP_xsel:
		ds		1			; register mask
		ds		1
FP_iadr:
		ds.l	1
		ds.l	1

		data
ea_adr:
		dc.l	ea_d				; 0
		dc.l	ea_a				; 1
		dc.l	ea_ai				; 2
		dc.l	ea_aip				; 3
		dc.l	ea_aim				; 4
AIM		equ		4
		dc.l	ea_aid				; 5
		dc.l	ea_aidr				; 6
		dc.l	ea_erweitert		; 7

ea_adrerw:
		dc.l	ea_wadr				; 7,0
		dc.l	ea_ladr				; 7,1
		dc.l	ea_pcd				; 7,2
		dc.l	ea_pcdr				; 7,3
		dc.l	ea_konst			; 7,4

; source specifier to size conversion
; spectol:
;		dc		4,4,12,12,2,8,1,3
;				L S  X  P W D B bomb

		bss
register:
datenreg:
		ds.l	3				; Platz fÅr 8 Datenregister
d_reg:
		ds.l	5
adressreg:
		ds.l	2				; Platz fÅr 7 Adreûregister
a_reg:
		ds.l	5
stackpointer:
		ds.l	1				; + Platz fÅr user Stackpointer
op_pc:
		ds.l	1				; Programmcounter bei Exeption

eam:	ds  	1
xsel:	ds  	1
opc:	ds  	1

macro	put_regs
		movem.l	d3-d7,d_reg
		movem.l	a2-a6,a_reg
		move	usp,a_wk
		move.l	a_wk,stackpointer
endm
macro	get_regs
		move.l	stackpointer,a_wk
		move	a_wk,usp
		movem.l	d_reg,d3-d7
		movem.l	a_reg,a2-a6
endm
macro	wait	x
local	r_r
r_r:	move  	LINE_F + FP_resp,x	; Read response primitive
		cmp 	#0x8900,x
		beq		r_r
endm

		text
		dc.l	'XBRA'
		dc.l	'FPCP'
FPEM_oldF:
		dc.l	0
FPEM_lineF:
; Try to use as few registers as possible
		movem.l	d0-d2,datenreg
		movem.l	a0-a1,adressreg

		movea.l	2(sp),a0			; a0=Returnadresse  (PC)
		move.l	a0,op_pc
		move  	(a0)+,d0			; opcode
		move	d0,opc
		move  	d0,LINE_F + FP_cntl	; Write to control CIR --> abort current actions in progress, NO other meaning

; first evaluate bits 8,7 & 6 of the f word

		btst 	#8,d0				; fsave, frestore not implemented.
		bne 	r_x				; no command word

l0:		and   	#0xC0,d0
		beq  	g_000

		cmp 	#0x80,d0		; ') bit 7 = 1, bit 6 = 0  
		beq		fbcc_w
		cmp 	#0xC0,d0		; ') bit 7 = 1, bit 6 = 1
		beq 	fbcc_l
lfscc:
		move  	(a0)+,d0		; conditional predicate in command word
		and		#0x3f,d0
		move  	d0,LINE_F + FP_ccr

		wait	d_rp

		moveq	#1,d_ct			; size = byte
		put_regs
		bsr		getea

		cmp 	#1,eam			; fscc  mode 1 = fdbcc
		beq		lfdbcc

		btst	#0,d_rp			; True/False-Bit
		sne		(a_ea)			; true = 255, false = 0
		get_regs
		bra		r_x

lfdbcc:
		btst	#0,d_rp			; True/False-Bit
		bne		r_j				; TRUE: no operation

		move	opc,d0
		and 	#7,d0			; get datareg
		lsl 	#2,d0
		put_regs
		lea		register,a_wk
		subq	#1,0(a_wk,d0)
		move	0(a_wk,d0),d0
		get_regs
		cmp 	#-1,d0
		beq		r_nx			; count = -1: next instruction
		bra 	r_j				; jump

fbcc_w:
		move  	opc,d0
		and  	#0x3F,d0		; conditional predicate in f word
		move  	d0,LINE_F + FP_ccr

		wait 	d0

		btst	#0,d0			; True/False-Bit
		beq  	r_nx
r_j:	adda  	(a0),a0			; .w-SprÅnge
		bra  	r_x
r_nx:	addq	#2,a0			; ') correction fbcc
		bra 	r_x

fbcc_l:							; ')
		move  	opc,d0
		and  	#0x3F,d0		; conditional predicate in f word
		move  	d0,LINE_F + FP_ccr

		wait	d0

		btst	#0,d0			; True/False-Bit
		beq  	r_nxl
		adda.l 	(a0),a0			; .l-SprÅnge
		bra  	r_x
r_nxl:	addq	#4,a0			; ') correction fbcc
		bra		r_x
		
g_000:
		move  	(a0)+,LINE_F + FP_cmd

;		15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0
;		CA PC DR             IA                   PF TF
;
; No exception processing, so PC is ignored

response:
		wait	d0
		move  	d0,d_rp
		blt		CA				; This is for speed		7.4.2.7 (see summary table 7-7)

;		cmp 	#0x0802,d0
;		beq 	r_x				; idle (most often after fp reg tp fp reg operation)

		and  	#0x1F00,d0		; %0001 1111 0000 0000					7.4.2.5 &
		cmp 	#0x0E00,d0		; %0001 1100 0000 0000		excep		7.4.2.6
		bge		r_x

		cmp  	#0x1000,d0		; bit 12 =1 bit 11 = 0
		blt  	r_x				;     10,9,8 xxx

; response evaluate effective address and transfer data		CA = 0	7.4.2.2
tr_data:
		moveq	#0,d_ct			; d_ct=LÑnge
		move.b	d_rp,d_ct			; HR: size now also used by getea

		put_regs
		bsr		getea
		bsr		trans
		get_regs
		bra 	r_x

CA:
		and  	#0x1F00,d0		; %0001 1111 0000 0000
		cmp  	#0x1000,d0		; bit 12 =1 bit 11 = 0
		blt  	l1				;     10,9,8 xxx

; response evaluate effective address and transfer data		CA = 1	7.4.2.2
tr_dat_ca:
		moveq	#0,d_ct			; d_ct=LÑnge
		move.b	d_rp,d_ct			; HR: size now also used by getea

		put_regs
		bsr		getea
		bsr		trans
		get_regs
		bra 	response
				
l1:		cmp  	#0x0C00,d0		; %0000 1100 0000 0000 
		bne		l3

; response transfer single main processor register		7.4.2.3
; only used for fmovem Dn,<ea> -- <ea>,Dn for the
; coprocessor to obtain the register list in Dn
tr_single:
		put_regs				; only when needed
		lea		datenreg,a_ea
		move  	d_rp,d0
		and		#0xf,d0			; HR: mask out bit 11 & 10
		lsl  	#2,d0
		move.l	0(a_ea,d0),LINE_F + FP_opnd
		get_regs
		bra		response		; we know CA = 1

l3:		cmp  	#0x0100,d0		; bit 8
		bne		r_x

; response transfer multiple coprocessor registers		7.4.2.4
;		fmovem
tr_mult:
		move	LINE_F + FP_xsel,d0

		put_regs				; only when needed

		moveq	#0,d_ct			; determine number of bytes involved
		moveq	#7,d_wk			; count number of bits in mask
l4:		tst  	d0
		bge  	l5
		add  	#XL,d_ct		; for (An)+ & -(An) the An update
l5:		lsl		#1,d0
		dbf		d_wk,l4

		bsr		getea
		get_regs

		cmp  	#AIM,eam
		beq		l7

		btst	#13,d_rp		; direction
		beq		l6a

; reg to mem
l6:		tst  	d_ct
		ble		response
		move.l	LINE_F + FP_opnd,(a_ea)+
		move.l	LINE_F + FP_opnd,(a_ea)+
		move.l	LINE_F + FP_opnd,(a_ea)+
		sub  	#XL,d_ct
		bra		l6

; mem to reg
l6a:	tst  	d_ct
		ble		response
		move.l	(a_ea)+,LINE_F + FP_opnd
		move.l	(a_ea)+,LINE_F + FP_opnd
		move.l	(a_ea)+,LINE_F + FP_opnd
		sub  	#XL,d_ct
		bra		l6a

l7:
		add		d_ct,a_ea			; a_ea back to start
l8:		tst  	d_ct
		ble		response
		sub		#XL,a_ea			; predecrement; reg to mem only
		move.l	LINE_F + FP_opnd, (a_ea)
		move.l	LINE_F + FP_opnd,4(a_ea)
		move.l	LINE_F + FP_opnd,8(a_ea)
		sub  	#XL,d_ct
		bra		l8

; response take pre-instruction exception				7.4.2.5
; response take mid-instruction exception				7.4.2.6
;   No exception processing yet

r_x:	move.l	a0,2(sp)
		movem.l	datenreg,d0-d2
		movem.l	adressreg,a0-a1
		rte


trans:							; DONT change d0, d1, d_ct
		btst	#13,d_rp		; Datenrichtung  (bit 13)
		beq  	tdwrite			; only 1,2 & 4,8 or XL are defined
		cmp 	#1,d_ct
		beq  	tdreadb
		cmp  	#2,d_ct
		beq  	tdreadw
		move.l	LINE_F + FP_opnd,(a_ea)
		cmp  	#4,d_ct
		ble		tdr1
		move.l	LINE_F + FP_opnd,4(a_ea)	; HR: dont want to change a_ea
		cmp		#8,d_ct
		ble		tdr1
		move.l	LINE_F + FP_opnd,8(a_ea)
tdr1:	rts
tdreadb:
		move.b	LINE_F + FP_opnd,(a_ea)
		rts
tdreadw:
		move  	LINE_F + FP_opnd,(a_ea)
		rts

tdwrite:
		cmp  	#1,d_ct
		beq  	tdwriteb
		cmp  	#2,d_ct
		beq  	tdwritew
		move.l	(a_ea),LINE_F + FP_opnd
		cmp  	#4,d_ct
		ble		tdw1
		move.l	4(a_ea),LINE_F + FP_opnd
		cmp		#8,d_ct
		ble		tdw1
		move.l	8(a_ea),LINE_F + FP_opnd		
tdw1:	rts
tdwriteb:
		move.b	(a_ea),LINE_F + FP_opnd
		rts
tdwritew:
		move  	(a_ea),LINE_F + FP_opnd
		rts

getea:							; parameter in d_ct = length
		move	opc,d0			; opcode
		move  	d0,d_wk

		and  	#7,d_wk			; d_wk = R : Register

		lsr  	#3,d0
		and  	#7,d0			; d0 = M : Modus
		move	d0,eam

		lsl 	#2,d0
		lea		ea_adr,a_ea	 ; weitere Routine nach
		movea.l	0(a_ea,d0),a_ea  	 ; Modus auswÑhlen
		jmp		(a_ea)

ea_a:
		bset	#3,d_wk			; Adressregister direkt
ea_d:
		lea		datenreg,a_ea		; Datenregister direkt
		lsl  	#2,d_wk
		cmp  	#1,d_ct			; byte?
		bne  	ea_xb
		addq.l	#3,a_ea
ea_xb:
		cmp  	#2,d_ct			; word ?
		bne  	ea_xw
		addq.l	#2,a_ea
ea_xw:
		adda  	d_wk,a_ea
		rts

ea_ai:
		lea		adressreg,a_wk	; Adressregister indirekt
		lsl  	#2,d_wk
		movea.l	0(a_wk,d_wk),a_ea
		rts

ea_aip:							; Adressregister indirekt (a)+
		lea		adressreg,a_wk
		lsl  	#2,d_wk
		movea.l	0(a_wk,d_wk),a_ea
		add.l	d_ct,0(a_wk,d_wk)
		rts
ea_aim:							; Adressregister indirekt -(a)
		lea		adressreg,a_wk
		lsl  	#2,d_wk
		movea.l	0(a_wk,d_wk),a_ea
		sub.l	d_ct,0(a_wk,d_wk)
		sub 	d_ct,a_ea
		rts

ea_aid:							; Adressregister indirekt d(a)
		lea		adressreg,a_wk
		lsl  	#2,d_wk
		movea.l	0(a_wk,d_wk),a_ea
		adda  	(a0)+,a_ea
		rts

ea_aidr:						; Adressregister indirekt d(a,r.?)
		lea		adressreg,a_wk
		lsl  	#2,d_wk
		movea.l	0(a_wk,d_wk),a_ea

; 	folgendes gilt auch fÅr d(pc,r.?)
ea_eidr:
		move  	(a0)+,d_wk		; Zusatzwort holen
		move  	d_wk,d0			; offset addieren
		ext  	d0
		adda  	d0,a_ea
		move  	d_wk,d0
		rol  	#6,d0			; Registernummer extrahieren und *4
		and  	#%111100,d0
		lea		register,a_wk
		adda  	d0,a_wk
		btst	#11,d_wk
		bne  	ea_aidrl
		adda  	2(a_wk),a_ea
		rts

ea_aidrl:
		adda.l	(a_wk),a_ea
		rts

ea_erweitert:
		lea		ea_adrerw,a_ea
		lsl  	#2,d_wk
		movea.l	0(a_ea,d_wk),a_ea		; weitere Routine nach
		jmp		(a_ea)			; Register auswÑhlen

ea_wadr:
		suba.l	a_ea,a_ea			; Speicher direkt, kurz
		movea  	(a0)+,a_ea
		rts

ea_ladr:
		movea.l	(a0)+,a_ea		; Speicher direkt, lang
		rts

ea_pcd:
		movea.l	a0,a_ea			; a0 ist neuer pc!
		adda  	(a0)+,a_ea
		rts

ea_pcdr:
		movea.l	a0,a_ea
		bra  	ea_eidr

ea_konst:
		movea.l	a0,a_ea			; Adresse holen
		adda.l	d_ct,a0			; a0 weiterschalten
		cmp  	#1,d_ct			; auf BytelÑnge testen
		bne  	ea_konstrts
		addq.l	#1,a_ea
		addq.l	#1,a0
ea_konstrts:
		rts

		end
