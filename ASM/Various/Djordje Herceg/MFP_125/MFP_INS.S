;
; MFP MODULE INSTALLATION UTILITY v1.01 of 15.10.1989. (c) 1989 DJHSoftware
; --> File: MFP_INS.S
;
;############# ACESSORY #############
	lea	stack,sp
	bsr	acc_init
acc_test:
	lea	mes_buf,a5
	bsr	evnt_mesag
	cmp.w	#40,(a5)
	bne.s	acc_test
	bsr.s	acc_exec
	bra.s	acc_test
;########## ACC Podprogram ##########
acc_exec:
	tst.l	mfm_test		;Is the module installed?
	beq.s	nomod		;No!

yesmod:	lea	alert_2,a5	;Remove, Cancel or Info ?
	bsr	form_alert	
	cmpi.w	#2,d0
	blt.s	mfm_remove	;Remove!
	bra.s	otherw		;For other cases use existing BCCs.

nomod:	lea	alert_1,a5	;Install, Cancel or Info ?
	bsr  	form_alert
	cmpi.w	#2,d0
  	blt.s	mfm_install	;Install!
otherw:	beq.s	acc_exit		;Cancel --> exit
;	bgt.s	info_message	;Info --> exit

info_message:
	lea	alert_3,a5 	;Info Message
	bsr	form_alert

acc_exit:
	rts			;Exit to GEM!

mfm_remove:	move.l	mfm_addr,a3	;a3=start of module
		move.l	#0,2(a3)		;set deinstall mode
		jsr	(a3)		;remove VBL queue
		move.l	#0,mfm_test	;module is not installed

		move.w   #135,-(sp)	;gi mixer
		move.w	#255,-(sp)	;enable A: & B:, stop sound
		move.w	#28,-(sp)
		trap	#14		;XBIOS Giaccess
		addq.l	#6,sp

		bsr	mfm_free
		bra.s	acc_exit	


mfm_install:	clr.w	-(sp)
		pea	fpath
		move.w	#$47,-(sp)
		trap	#1		;GEMDOS Getdir
		addq.l	#8,sp
		lea	fpath,a3
		clr.l	d0
loop1:		tst.b	(a3,d0)		;look for the [0] 
		beq.s	exit1		;byte in fpath
		addq.l	#1,d0
		bra.s	loop1
exit1:
		add.l	d0,a3		;a3=end of path
		lea	fmask,a2		;a2=fmask^
		move.l	#6,d0
loop2:		move.b	(a2)+,(a3)+	;copy mask to path
		dbra	d0,loop2	
	
		lea	fpath,a4
		lea	ffile,a5
		bsr	fsel_input	;AES Fsel_Input
		cmpi.w	#1,d0		;Cancel pressed?
		bne	acc_exit		;yes - exit

		lea	fpath,a3		
		clr.l	d0
loop3:		move.b	(a3,d0),d1	;look for the asterisk
		cmpi.b	#42,d1		;asc("*")=#42
		beq.s	exit3		;exit if '*' was found
		cmpi.l	#119,d0		;exit if maxlen was achieved
		bge.s	exit3
		addq.l	#1,d0
		bra.s	loop3		
exit3:		add.l	d0,a3		;a3=end of text

		lea	ffile,a4
		clr.l	d0
loop4:		move.b	(a4)+,d1		;copy file name to
		tst.b	d1		;the path and so make
		beq.s	exit4		;path+name
		move.b	d1,(a3)+
		addq.l	#1,d0
		bra.s	loop4		
exit4:		move.b	#0,(a3)		;set end of name


 		move.w	#$2f,-(sp)
		trap	#1		;GEMDOS Getdta
		addq.l	#2,sp
		move.l	d0,fdta		;save dta

		move.w	#0,-(sp)
		pea	fpath
		move.w	#$4e,-(sp)
		trap	#1		;GEMDOS Sfirst
		addq.l	#8,sp
		tst.l	d0		;was the file found?
		bmi	disk_exit	;no - acc_exit

		move.l	fdta,a3		;a3=dta^
		move.l	26(a3),flen     	;get file len

		move.l	#-1,-(sp)	
		move.w	#$48,-(sp)
		trap	#1		;GEMDOS Malloc
		addq.l	#6,sp
		sub.l	flen,d0		;mfree-flen
		cmp.l	#37536,d0	;is (mfree-flen)<37536?
		blt	mem_exit		;yes!
	
		move.l	flen,-(sp)	;put file length in stack
		move.w	#$48,-(sp)
		trap	#1		;GEMDOS Malloc
		addq.l	#6,sp
		tst.l	d0		;error Malloc?
		bmi	mem_exit		;yes - acc_exit
		move.l	d0,mfm_addr	;no - save module address

loadmfm:		move.w	#0,-(sp)		;attrib=RO
		pea	fpath
		move.w	#$3d,-(sp)
		trap	#1		;GEMDOS Open
		addq.l	#8,sp
		tst.w	d0		;file open error?
		bmi	dmsk_exit	;yes - acc_exit
skipload:	move.w	d0,fhandle	;save handle

		move.l	mfm_addr,-(sp)	
		move.l	flen,-(sp)
		move.w	fhandle,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		add.l	#12,sp
		tst.l	d0		;file read error?
		bmi	dhsk_exit	;yes - acc_exit
		cmp.l	flen,d0		;lengths fit?
		bne	dhsk_exit	;no - acc_exit

		move.w	fhandle,-(sp)	;load successful - now close
		move.w	#$3e,-(sp)
		trap	#1		;GEMDOS Close
		addq.l	#4,sp
		tst.w	d0		;file close error?
		bmi	disk_exit	;yes - acc_exit

checkmod:	move.l	mfm_addr,a3	;a3=start of module
		lea	txt_mod,a4	;a4='MFP SONG MODULE v1.0[CR][LF]'
		add.l	#3500,a3
		move.l	#21,d0
loop5:		move.b	(a3,d0),d1
		cmp.b	(a4,d0),d1	;Is it a module?
		bne.s	exit5		;No - then exit
		dbra	d0,loop5		

		move.l	mfm_addr,a3	;YES
		add.l	#3522,a3		;a3=song_name^
		lea	alert_2,a4
		add.l	#82,a4		;a4=alert_song_name^
		move.l	#23,d0
loop6:		move.b	(a3)+,d1
		tst.b	d1		;is char=#0?
		bne.s	skip6		;yes - make it be a SPACE (#32)
		move.b	#32,d1
skip6:		move.b	d1,(a4)+		;copy module name to alert
		dbra	d0,loop6
		bra.s	install		;Install VBL

exit5:		bsr.s	mfm_free		;Free allocated memory
		bra.s	notm_exit	;error - not a module

install:          lea	mfm_test,a3	;Install VBL
		move.l	#-1,(a3)
		move.l	mfm_addr,a3	;a3=start of module
		move.l	#1,2(a3)		;set install mode
		jsr	(a3)		;install VBL queue
		bra	acc_exit		;finally exit this ACC!

;########### PROCEDURES ###########
mem_exit:	lea	alert_5,a5	;error - not enough RAM
		bsr	form_alert
		bra	acc_exit

dhsk_exit:	move.w	fhandle,-(sp)
		move.w	#$3e,-(sp)
		trap	#1		;GEMDOS Close
		addq.l	#4,sp

dmsk_exit:	bsr.s	mfm_free		;Free allocated memory

disk_exit:	lea	alert_4,a5	;error - file not found
		bsr	form_alert
		bra	acc_exit

notm_exit:	lea	alert_6,a5	;error - file is not a module
		bsr	form_alert
		bra	acc_exit

mfm_free:	move.l	mfm_addr,-(sp)	;Free allocated memory
		move.w	#$49,-(sp)
		trap	#1		;GEMDOS Mfree
		addq.l	#6,sp
		rts
;########### VARIABLES ############
	even
mfm_test	dc.l	0	;module flag (0=no, 1=installed)
mfm_addr	dc.l	0	;module address	
	
acc_name	dc.b	"  MFP Install",0
txt_mod	dc.b	"MFP SONG MODULE v1.0",13,10
	even
alert_1  dc.b 	0,1,"[2][MFP Module Install Utility|===/(c) 1989 DJHSoftware/=|Currenlty installed: none][Install| Cancel | Info ]",0
	even
alert_2  dc.b 	0,1,"[2][MFP Module Install Utility|===/(c) 1989 DJHSoftware/=|Currenlty installed:|>                        <][Remove| Cancel | Info ]",0
	even
alert_3  dc.b 	0,1,"[1][Version 1.0 of 15.10.1989.|Coding by Djordje Herceg|Lukijana Musickog 18|21000 Novi Sad, YUGOSLAVIA][   Ok   ]",0
	even
alert_4  dc.b 	0,1,"[3][** DISK I/O ERROR **|====================|Error reading file -|installation aborted.][ Cancel ]",0
	even
alert_5  dc.b 	0,1,"[3][*** MEMORY ERROR ***|====================|Not enough memory -|installation aborted.][ Cancel ]",0
	even
alert_6	dc.b	0,1,"[3][**** FILE ERROR ****|====================|Not a MFP module -|installation aborted.][ Cancel ]",0
	even
fmask 	dc.b	"\*.MFM",0
	even
fpath	ds.b	160
	even
ffile	ds.b	16
fdta	dc.l	0
fhandle	dc.w	0
flen	dc.l	0

;######################################
;#           GEM Podprogrami          #
;######################################
	even
evnt_mesag:
	lea	contrl,a6
	move.w	#23,(a6)+
	move.l	#1,(a6)+
	move.l	#$10000,(a6)
	lea 	addrin,a6
	move.l	a5,(a6)
	bra	aes
form_alert:
	lea	contrl,a6
	move.w	#52,(a6)+
	move.l	#$10001,(a6)+
	move.l	#$10000,(a6)
	move.w	(a5)+,intin
	move.l	a5,addrin
	bsr	aes
	move.w	intout,d0
	rts
fsel_input:
	lea	contrl,a6
	move.w	#90,(a6)+
	move.l	#$2,(a6)+
	move.l	#$20000,(a6)
	move.l	a4,addrin
	move.l	a5,4+addrin
	bsr	aes
	move.w	2+intout,d0
	rts
;########### GEM+ACC Init #############
acc_init:
	lea	vdipb+20,a6
	exg.l	a6,a7
	pea	ptsout
	pea	intout
	pea	ptsin
	pea	intin
	pea	contrl
	pea	addrout
	pea	addrin
	pea	intout
	pea	intin
	pea 	global
	pea	contrl
	pea	vdipb
	pea	aespb
	exg.l	a6,a7
	lea	contrl,a6
	move.w	#10,(a6)+
	move.l	#1,(a6)+
	clr.l	(a6)
	bsr	aes
	move.w	intout,ap_id
	lea	contrl,a6
	move.w	#77,(a6)+
	move.l	#5,(a6)+
	clr.l	(a6)
	bsr.s	aes
	move.w	intout,d0
	move.w	d0,g_handle
	lea	contrl,a6
	move.w	#100,(a6)+
	clr.w	(a6)
	move.w	#11,4(a6)
	move.w	d0,10(a6)
	lea	intin,a6
	moveq	#9,d0
loop:	moveq	#1,d1
	move.w	d1,(a6)+
	dbra	d0,loop
	move.w	#2,(a6)
	bsr.s	vdi
	move.w	contrl+12,v_handle
	lea	contrl,a6
	move.w	#35,(a6)+
	move.l	#$10001,(a6)+
	move.l	#$10000,(a6)
	move.w	ap_id,intin
	lea	addrin,a6
	lea	acc_name,a5
	move.l	a5,(a6)
	bsr.s	aes
	move.w	intout,ac_id
	rts
aes:
	move.l	aesptr,d1
	move.w	#$c8,d0
	trap	#2
	rts
vdi:
	move.l	vdiptr,d1
	moveq	#$73,d0
	trap	#2
	rts

;~~~~~~~~~~~~ Reserve ~~~~~~~~~~~~~
bss
ap_id		dc.w	0
ac_id		dc.w	0
g_handle		dc.w	0
v_handle		dc.w	0
mes_buf		ds.w	8
aesptr		dc.l	0
vdiptr		dc.l	0
aespb		ds.l	6
vdipb		ds.l	5
contrl		ds.w	11
global		ds.w	15
intin		ds.w	128
ptsin		ds.w	128
intout		ds.w	128
ptsout		ds.w	128
addrin		ds.w	128
addrout		ds.w	128
		ds.l	128
stack		dc.l	0