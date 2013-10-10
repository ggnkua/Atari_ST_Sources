codage	movea.l	#message,a2
	movea.l	#code,a1
	moveq	#0,d0

codag1	move.b	(a2),d0
	subi.b	#$20,d0
	move.b	(a1,d0.w),(a2)+
	cmpi.w	#$3b,d0
	bne	codag1

save	lea	nom,a0  
	lea	message,a1
	movea.l	#fmess-message,a2
	bsr	creat
	rts

nom	dc.b	"texte.mdk",0
	even

creat	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bpl	writ
	clr.w	-(sp)
	trap	#1

writ	move.w	d0,d3
	move.l	a1,-(sp)
	move.l	a2,-(sp)
	move.w	d3,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	adda.l	#12,sp

close	move.w	d3,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

code	dc.b	46,28,47,48,49,50,51,32,34,35,46,46,27,33,26,46
	dc.b	36,37,38,39,40,41,42,43,44,45
	dc.b	29,30,46,46,46,31,46,00,01,02,03,04,05,06,07,08,09
	dc.b	10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,52
	even
           
message	dc.b 	" "
	dc.b	"::::::::......LES.NULS.........PRESENTENT........."
	dc.b	"LED.STORM....DEPRO.PAR.LES.JOYEUSES.COPINES.BLOOD."
	dc.b	"ET.SHIMROD......LES.NULS..?'-..GUS.12.STDAN.45."
	dc.b	"THE.ECHO.().BLOOD.,!.ELRIC.12.SHIMROD.45.PATMAC.78."
	dc.b	"HAGGIS.().TOG.:...PETITS.BISOUS.A.JOE.LE.DINGUE.."
	dc.b	"ST.FORCE..RANK.XEROX..VENDREDI.TREIZE...STKC...."
	dc.b	"MERCI.ELWOOD.POUR.L.ORIGINAL....ENCORE.DES.BISOUS.A."
	dc.b	"SOFTWOLF..LA.FOUINE..NOTRE.GRANDE.COPINE.NIKKIE.,!."
	dc.b	"XFACTOR..SPACEBAR..ZKWYD..HIBOU.BISOUS.D.ELRIC.POUR."
	dc.b	"SPECTRE..CHUD.CHAMALOU....BISOUS.SPECIAUX.A.DEIRDRE."
	dc.b	"ET..STEP..AUSSI.A.BANANE.GOURMAND.SPOUTNIK.BOUGIE."
	dc.b	"ET..UN.GROS.BISOU.AU.BAISEUR.MASQUE............"
	dc.b	"::::::::::::::::::::::::::"
	dc.b 	"["
	even

fmess