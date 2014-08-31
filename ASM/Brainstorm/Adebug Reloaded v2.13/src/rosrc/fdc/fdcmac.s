;fdcmac.s
;  #[ Equs:
WAITVALUE	EQU	$20
ASP_DEBUG	EQU	1

	IFNE	ASP_DEBUG
asp	EQUR	a4
	ELSEIF
asp	EQUR	sp
	ENDC

depl	equ	0
base	equ	$fa01
dmalow 		equ 	$860D-base+depl
dmamid 		equ 	$860B-base+depl
dmahigh		equ	$8609-base+depl
giselect	equ	$8800-base+depl
giwrite		equ	$8802-base+depl
dmascnt		equ	$8604-base+depl
dmawrite	equ	$8604-base+depl
dmastatus	equ	$8604-base+depl
dmamode		equ	$8606-base+depl
mfp		equ	$fa01-base+depl
	;ordres de lecture
srcmd		equ		$0
srtrk		equ		$1
srsec		equ		$2
srdat		equ		$3
srcnt		equ		$90
	;ordres d'‚criture
swcmd		equ		$0
swtrk		equ		$1
swsec		equ		$2
swdat		equ		$3
swcnt		equ		$190
;  #] Equs:
;  #[ Macros:
	; #[ WAITQ:\waitvalue
WAITQ:	MACRO
	moveq	\1,d0
	dc.l	$51c8fffe
	ENDM
	; #] WAITQ:
	; #[ WAIT:\waitvalue
WAIT:	MACRO
	move.w	\1,d0
	dc.l	$51c8fffe
	ENDM
	; #] WAIT:
	; #[ DMA_IN:\none
;void void
;used:none
DMA_IN:	MACRO
	move.w	#srcnt,dmamode(asp)			;lecture
	move.w	#swcnt,dmamode(asp)			;‚criture->FIFO vide
	move.w	#srcnt,dmamode(asp)			;lecture
	WAITQ	#WAITVALUE
	move.w	#$1F,dmascnt(asp)			;1F=31 blocs de 512 octets
	WAITQ	#WAITVALUE
	ENDM
	; #] DMA_IN:
	; #[ WD_WRITE:\type de cmd \cmd
;gestion du verify fdc,du seekrate,de la precompensation ?
WD_WRITE:	MACRO
	moveq	\1,d0
	add.w	d0,d0
	addi.w	#$80,d0
	move.w	d0,dmamode(asp)
	WAITQ	#WAITVALUE
	move.w	\2,d0
	andi.w	#$FF,d0
	move.w	d0,dmascnt(asp)
	ENDM
	; #] WD_WRITE:
	; #[ SET_DMA:\address
;a faire en movep
SET_DMA:	MACRO
	move.l		\1,D0
	move.b		D0,dmalow(asp)
	lsr.l		#8,D0
	move.b		D0,dmamid(asp)
	lsr.l		#8,D0
	move.b		D0,dmahigh(asp)
	ENDM
	; #] SET_DMA:
	; #[ WAIT_DONE:\none
WAIT_DONE:	MACRO
	;384 dbf = 8+10*384+14 cycles = 0.48ms
	WAIT	#384
	moveq	#4,d0
	swap	d0
;.again:
	btst	#5,mfp(asp)

;--------------------;*
	dc.w	$6706;
;	beq.s	.fini;
;--------------------;

	subq.l	#1,d0

;---------------------;*
	dc.w	$66f4 ;
;	bne.s	.again;
;---------------------;

;--------------------;*
	dc.w	$6014;
;	bra.s	.err ;
;--------------------;

;.fini:
	move.w	dmastatus(asp),d0
	btst	#3,d0
;--------------------;*
	dc.w	$660a;
;	bne.s	.err ;
;--------------------;
	btst	#4,d0
;--------------------;*
	dc.w	$6604;
;	bne.s	.err ;
;--------------------;
	moveq	#0,d0
;--------------------;*
	dc.w	$6002;
;	bra.s	.end ;
;--------------------;
;.err:
	moveq	#-1,d0
;.end:
	ENDM
	; #] WAIT_DONE:
	; #[ RESTORE:	;0000 HVR1R0
RESTORE:	MACRO
	WD_WRITE	#srcmd,#%00000011
	WAIT_DONE
	ENDM
	; #] RESTORE:
	; #[ SEEK_TRACK:\track #	;0001 HVR1R0
;\1 = track #
SEEK_TRACK:	MACRO
	WD_WRITE	#srdat,\1
	WAIT	#WAITVALUE
	WD_WRITE	#srcmd,#%00010011
	WAIT_DONE
	ENDM
	; #] SEEK_TRACK:
	; #[ READ_ADDRESS:\address \Ids #	;1100 HE00
;ajouter 16 octets = 3 Id pour etre sur d'avoir ts les Ids demandes
READ_ADDRESS:	MACRO
	SET_DMA	\1
	move.w	\2,d2
	DMA_IN
.ra\@:
	WD_WRITE	#srcmd,#%11000011
	WAIT_DONE
	bne.s	.fin_ra\@
	dbne	d2,.ra\@
	moveq	#0,d0
.fin_ra\@:
	ENDM
	; #] READ_ADDRESS:
	; #[ READ_TRACK:\address	;1110 HE00
READ_TRACK:	MACRO
	SET_DMA	\1
	DMA_IN
	WD_WRITE	#srcmd,#%11100111
	WAIT_DONE
	ENDM
	; #] READ_TRACK:
	; #[ READ_SECTOR:\address	;100m HE00
READ_SECTOR:	MACRO
	SET_DMA	\1
	DMA_IN
	WD_WRITE	#srdat,\1
	WAIT	#WAITVALUE
	WD_WRITE	#srcmd,#%10001000
	WAIT_DONE
	ENDM
	; #] READ_SECTOR:

	; #[ SET_DRIVE:\drive \side
SET_DRIVE:	MACRO
	moveq		#%10,d1
	;drive 0?
	;oui alors mettre bit 1 … 1
;	bset		#1,d1
	;side:D1=%0 ou %1
	or.b		\2,d1
	;ici d1 vaut:
	;%010	=A 0
	;%100	=B	0
	;%011	=A	1
	;%101	=B	1
	;inverser les bits
	eori.b	#%00000111,d1
	andi.b	#%00000111,d1
	;s‚lectionner le port #14
	move.b	#14,giselect(asp)
	;lire ce qu'il y avait d‚j…
	move.b	giselect(asp),D0
	;effacer les 3 premiers bits
	andi.b	#$F8,D0
	;fixer les bits du drive et du side
	or.b	D0,d1
	move.b	d1,giwrite(asp)
	ENDM
	; #] SET_DRIVE:
	; #[ UNSET_DRIVE:\none
UNSET_DRIVE:	MACRO
	WAITQ	#WAITVALUE
	moveq	#30,d1
.ud\@
	WAITQ	#-1
	dbf	d1,.ud\@
	move.b	#14,giselect(asp)
	move.b	giselect(asp),D0
	ori.b	#%00000111,D0
	move.b	D0,giwrite(asp)
	ENDM
	; #] UNSET_DRIVE:
;  #] Macros:
	move.w	#base,asp

