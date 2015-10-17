	opt o+,ow-
*MOD_BOX=1
*MOD_HEXA=1
*MOD_DECI=1

	; Revues : 24/7/93 : 27/7/93 : 29/7/93 : 07/08/93 : 14/08/93 : 23/08/93
	; 24/8/93 : 03-IX-93 : 04-IX-93 : 06-IX-93 : 11-IX-93 : 29-X-93
	; 27-XI-93 : 05-XII-93 : 18-XII
	; Last revue : Gen&wax

dos	= 1
bios	= 13
xbios	= 14
esc	= 27
lf	= 10
rc	= 13

ecran	= $44e
futur_ecran = $45e
vbl_cpt	= $466
cpt_200	= $4ba
vblqueue	= $4ce+4
enable_vbl  = $452
hbl	= $68
palette	= $ffff8240
palette256	= $ffff9800
chipsonore	= $ffff8800
chipvideo	= $ffff8205
clavier	= $fffffc02
dma	= $ffff8604
datac	= $fffffa23
datad	= $fffffa25
ctrlcd	= $fffffa1d
timera	= $134
dataa	= $fffffa1f
ctrla	= $fffffa19
timerb	= $120
datab	= $fffffa21
ctrlb	= $fffffa1b
zilog8530	= $ffff8c85
zilogrs	= $ffff8c87		; zilog send/receive register
dsp_host_isr= $ffffa202
dsp_host	= $ffffa204

read=0			; pour file open, write ...
write=1
read_write=2

res64048016vga	= $3a	; pour set mode : tout est en PAL
res640480256vga	= $3b
res320480tcvga	= $34
res32020016vga	= $1b2	; compatible basse
res32024016vga	= $132
res32048016vga	= $32
res320240256vga	= $133
res320240tcvga	= $134
res64040016tv	= $12a
res640400256tv	= $12b
res320400tctv	= $124
res32020016tv	= $a2	; compatible basse
res320200256tv	= $23
res320200tctv	= $24

freq8	= %00001011
freq10	= %00001001
freq12	= %00000111
freq16	= %00000101
freq20	= %00000100
freq25	= %00000011
freq33	= %00000010
freq49	= %00000001

SAVE:	macro
	movem.l \1,-(sp)
	endm

LOAD:	macro
	movem.l (sp)+,\1
	endm

APPEL:	macro
	move.w #\2,-(sp)
	trap #\1
	add.l #\3,sp
	endm

WAIT:	macro
	appel dos,7,2
	endm

INIT:	macro
	move.l a7,a5
	lea pile,a7
	move.l 4(a5),a5
	move.l 12(a5),d0
	add.l 20(a5),d0
	add.l 28(a5),d0
	add.l #$100,d0
	and.l #-2,d0
	add.l #2,d0
	move.l d0,-(sp)
	move.l a5,-(sp)
	clr.w -(sp)
	appel dos,$4a,12
	BSS
	ds.l 4096
pile:	ds.l 1
	TEXT
	endm

SUPERVISOR:	macro
	clr.l -(sp)
	appel dos,$20,6
	move.l d0,old_stack
	endm
	BSS
old_stack:	ds.l 1
	TEXT

USER:	macro
	move.l old_stack,-(sp)
	appel dos,$20,6
	endm

SUP_EXEC:	macro
	pea \1
	appel xbios,38,6
	endm

SYNCRO:	macro
	appel xbios,$25,2
	endm
	
SYNCRO_GEM:	macro
\@wait_nul:	appel dos,$0b,2	; teste du buffer ...
	tst.w d0
	beq.s \@the_end	; pas de touche en buffer ?
	wait
	bra.s \@wait_nul
\@the_end:	syncro
	syncro
	endm

RESOLUT:	macro		; \1=vid‚o mode,\2=0:ST / \2=3:FALC
	move.w \1,-(sp)
	move.w \2,-(sp)
	move.l \3,-(sp)
	move.l \3,-(sp)
	appel xbios,5,14
	syncro_gem
	endm

SET_MODE:	macro
	move.w \1,-(sp)
	appel xbios,88,4
	endm

MOUSEOFF:	macro
	pea inhibe
	move.w #1-1,-(sp)
	appel xbios,25,8
	DATA
inhibe:	dc.b $12
	even
	TEXT
	endm

MOUSEON:	macro
	pea default
	move.w #2-1,-(sp)
	appel xbios,25,8
	endm
	DATA
default:	dc.b $80,$01
	TEXT

WRITE:	macro
	pea \1
	appel dos,9,6
	endm

SET_GEM:	macro
	init
	ifne MOD_BOX
	bsr init_box
	endc
	endm

RESTORE_GEM:macro
	syncro_gem
	ifne MOD_BOX
	bsr end_box
	endc
	move.w erreur_fils,-(sp)
	appel dos,$4c,4	; Pterm
 DATA
erreur_fils:dc.w 0
 TEXT
	endm

RESTORE_GEM_RES:macro		; \1=taille … prot‚ger
	syncro_gem
	ifne MOD_BOX
	save \1
	bsr end_box
	load \1
	endc
	clr.w -(sp)
	move.l \1,-(sp)
	appel dos,$31,8	; laisse r‚sident le programme
	endm

RESTORE_GEM_ERR:macro
	move.w \1,erreur_fils
	restore_gem
	endm

FILE_OPEN:	macro		; \1=read/write \2=name
	ifeq \1-1		; 0=lecture,other=write
	clr.w -(sp)
	pea \2
	appel dos,$3c,8	; file create
	endc
	ifeq \1
	clr.w -(sp)
	pea \2
	appel dos,$3d,8	; file open
	endc
	ifeq \1-2
	move.w #2,-(sp)
	pea \2
	appel dos,$3d,8
	endc
	endm

FILE_READ:	macro		; \1 =ad. \2=nb. \3=handle
	move.l \1,-(sp)
	move.l \2,-(sp)	; nb
	move.w \3,-(sp)
	appel dos,$3f,12	; file read
	endm

FILE_WRITE:	macro		; \1 =ad. \2=nb. \3=handle
	move.l \1,-(sp)
	move.l \2,-(sp)
	move.w \3,-(sp)
	appel dos,$40,12	; file write
	endm

FILE_SEEK:	macro		; \1 =seekmode, \2=handle, \3=offset.l
	move.w \1,-(sp)
	move.w \2,-(sp)
	move.l \3,-(sp)
	appel dos,$42,10	; file seek
	endm

FILE_CLOSE:	macro		; \1=handle
	move.w \1,-(sp)	; fclose
	appel dos,$3e,4
	endm

FS_FIRST:	macro
	move.w \1,-(sp)
	pea \2
	appel dos,$4e,8	; fsfirst
	endm

FS_NEXT:	macro
	appel dos,$4f,2	; fsnext
	endm

GET_DRIVE:	macro
	appel dos,$19,2	; get current drive
	endm

SET_DRIVE:	macro
	move \1,-(sp)
	appel dos,$e,4	; d_set_drive
	endm

GET_PATH:	macro
	move.w \1,-(sp)
	pea \2		; + \sources\
	appel dos,$47,8	; get_path
	endm

SET_PATH:	macro
	pea \1
	appel dos,$3b,6	; d_set_path
	endm

SET_DTA:	macro
	pea \1
	appel dos,$1a,6	; fset dta
	endm

GET_DTA:	macro
	appel dos,$2f,2	; fget dta
	endm

RESERVE_SCREENS:macro		; \1=nb.ecr \2=resolut
			; + x_max_p,y_max_p,nb_bits_per_pix
	move.l #screens,d0
	and.l #$ffffff00,d0
	add.l #$100,d0
	move.l d0,a0
	lea ecrans,a1

	move #\1-1,d0
.raz_screens:move.l a0,(a1)+
	move.l #x_max_p*y_max_p*nb_bits_per_pix/8/4,d1
.raz_screen:clr.l (a0)+
	subq.l #1,d1
	bne.s .raz_screen
	dbf d0,.raz_screens

	move.l ecran,save_ad_ecr
	set_mode #-1
	move d0,save_mode

	move #\2,d1
	btst #5,d0
	bne.s .pal_modus
	bclr #5,d1

.pal_modus:	btst #4,d0		; tv
	bne.s .vga_modus
	bclr #4,d1		; tv
	bchg #8,d1		; vertical mode
.vga_modus:
	ifne (\2-res32020016tv)*(\2-res32020016vga)
	resolut d1,#3,ecrans,ecrans
	else
	resolut d1,#0,ecrans,ecrans
	endc
	*set_mode \2		; toujours aprŠs resolut !

	BSS
save_mode:	ds.w 1
save_ad_ecr:ds.l 1
ecrans:	ds.l \1
screens:	ds.l \1*x_max_p*y_max_p*nb_bits_per_pix/8/4
	ds.b 256
	TEXT
	endm

RESTORE_SCREENS:macro
	resolut save_mode,#3,save_ad_ecr,save_ad_ecr
	*set_mode save_mode
	endm

SAVE_PALETTES:macro
	syncro
	lea palette256,a0
	lea old_palette256,a1
	move #256-1,d0
.cop_p:	move.l (a0)+,(a1)+
	dbf d0,.cop_p
	lea palette,a0
	lea old_palette16,a1
	move #16-1,d0
.cop_p1:	move.w (a0)+,(a1)+
	dbf d0,.cop_p1
	BSS
old_palette256:ds.l 256
old_palette16:ds.w 16
	TEXT
	endm

RESTORE_PALETTES:macro
	syncro
	lea old_palette256,a0
	lea palette256,a1
	move #256-1,d0
.res_p:	move.l (a0)+,(a1)+
	dbf d0,.res_p
	lea old_palette16,a0
	lea palette,a1
	move #16-1,d0
.res_p1:	move.w (a0)+,(a1)+
	dbf d0,.res_p1
	endm

COLOR256:	macro
	ifne TCOLOR
	move.l \1,palette256
	endc
	endm

COLOR:	macro
	ifne TCOLOR
	move.w \1,palette
	endc
	endm

ZILOGR:	macro		; zilog read : \1=register \2=byte
	move.b \1,zilog8530
	move.b zilog8530,\2
	endm

ZILOGW:	macro		; zilog write : \1=register \2=byte
	move.b \1,zilog8530
	move.b \2,zilog8530
	endm
***************************************************************************

	ifne MOD_BOX+MOD_HEXA+MOD_DECI
START_CODE:	bra debut
	endc

	ifne MOD_BOX
	include gemmacro.i
***************************************************************************
	; lea boite,a0 : bsr ALERT_BOX ou bsr FILESELECT
	; pour fileselect => tst d4 : beq annule
 TEXT
init_box:	appl_init
	move.w d0,ap_id	; store the application id
	rts

end_box:	appl_exit
	rts

init_mouse:	graf_mouse #257
	graf_mouse #0
	rts

desact_mouse:
	graf_mouse #256
	rts

;--------------------------------------------------------------
; retourne dans d0 le num‚ro du bouton 1..3
ALERT_BOX:	form_alert default_button,a0	; bouton gauche par d‚faut
	move.w int_out,d0		; quel bouton ?
	rts

;--------------------------------------------------------------
copy_in2_select:
	lea text_fsel,a1
.recop_fsel:move.b (a0)+,(a1)+
	tst.b -1(a0)
	bne.s .recop_fsel
	rts

FILESELECT:	get_drive		; d_get_driv

	lea disk_path,a4
	move.b #'A',(a4)
	add.b d0,(a4)+
	move.b #':',(a4)+	; A: ou B: ...

	get_path #0,(a4)

.trouv_zer:	tst.b (a4)+
	bne.s .trouv_zer	; on rajoute \ … la fin
	move.b #'\',-1(a4)
	clr.b (a4)
	
	lea whato,a0
.recop_whato:
	move.b (a0)+,(a4)+	; ajoute le masque
	tst.b -1(a4)
	bne.s .recop_whato

	sup_exec tos_version
	move tos_ver,d7
	cmp.w #$0104,d7
	bge.s its_a_ste
	fsel_input #disk_path,#params_it
	bra.s its_no_a_ste
its_a_ste:	fsel_exinput #disk_path,#params_it,#text_fsel
its_no_a_ste:
	tst.w d0
	beq.s .problem
	move.w int_out+2,d4	; 'ANNULE','CONFIRME'

	lea disk_path,a2
.pas0:	tst.b (a2)+
	bne.s .pas0
.pas_trouv_d:
	cmpi.b #'\',-(a2)
	beq.s .found_slash
	cmpi.b #':',(a2)
	bne.s .pas_trouv_d
	addq.l #1,a2
	move.b #'\',(a2)		; root
.found_slash:clr.b 1(a2)		; chemin fini par 0
	lea disk_path,a4
	cmpi.b #':',1(a4)
	bne.s .pas_driv
	clr d0
	move.b (a4),d0
	ori.b #32,d0
	subi.b #'a',d0
	set_drive d0
	addq.l #2,a4

.pas_driv:	set_path (a4)
	tst d0
	bne.s .problem

	lea params_it,a2
	tst.b (a2)
	bne.s .o_k		; si plante ouvrir n'importe (le 1er)
	move.l #'*.*'*256,(a2)	; *.* 0
.o_k:
.problem:	rts

tos_version:move.l $4f2.w,a0		; Adresse de la ROM
	move.w 2(a0),tos_ver
	rts

test_slct:	move.l $5a0.w,a0
	cmp.l #0,a0
	beq.s notfound
.next:	tst.l (a0)
	beq.s notfound
	cmp.l #'FSEL',(a0)
	beq.s .found
	lea 8(a0),a0
	bra.s .next
.found:	move.l 4(a0),a0
	cmp.l #'SLCT',(a0)
	bne.s notfound
	move.l a0,sltr_adress
	lea 4+2+2+2+2+4+2+4(a0),a0
	move.l a0,sltr_communication_word
	lea 2+2+4(a0),a0
	move.l a0,sltr_out_counter
	lea 2(a0),a0
	move.l a0,sltr_out_pointer
notfound:	rts
 BSS
tos_ver:		ds.w 1
sltr_adress:	ds.l 1		; Selctrix base adress (0 si pas s‚lectrix)
sltr_communication_word:ds.l 1		; ad. du word communication
sltr_out_counter:	ds.l 1		; ad. du compteur sortie
sltr_out_pointer:	ds.l 1		; ad. du pointeur sortie
 TEXT
;--------------------------------------------------------------
	include aeslib.s
;--------------------------------------------------------------
 DATA
 even
default_button:
	dc.w 1

whato:	dc.b '*.*',0,0,0
text_fsel:	dc.b 'Choose The File :'
	dcb.b 80,0
 even
 BSS
ap_id:	ds.w 1

disk_path:	ds.b 256
params_it:	ds.b 8+1+3+1	; fileselect filename.
 even
 TEXT
***************************************************************************
	endc

	ifne MOD_HEXA
***************************************************************************
HEXA:	sub #4,d1		; sous routine d'affichage hexa d'1 registre
	move.l d0,d2	; d1=nb bits
	lsr.l d1,d2		; d0=donn‚e
	and.w #$f,d2
	cmp #$a,d2
	bge.s .lettr
	add.b #'0',d2
	bra.s .fin_lettr
.lettr:	add.b #'A'-$a,d2
.fin_lettr:	save d0-d2/a0
	move.w d2,-(sp)
	appel dos,2,4
	load d0-d2/a0
	tst d1
	bgt.s hexa
	rts
***************************************************************************
	endc

	ifne MOD_DECI
***************************************************************************
DECI:	lea affiche_decim,a0	; dans d0 la donn‚e … afficher 0<9999
	*ext.l d0

	tst.l d0
	beq .it_s_0

	move.l #10000000*10,d2	; sur 8 d‚cimales max

.until_frac0:divul #10,d3:d2	; reste:fraction
	tst.l d2
	beq.s .dernier

	divul d2,d1:d0	; reste:fraction
	add.b #'0',d0
	move.b d0,(a0)+
	move.l d1,d0
	bra.s .until_frac0

.dernier:	clr.b (a0)+

	lea affiche_decim,a0
.first_non0:cmp.b #'0',(a0)+
	beq.s .first_non0
	lea -1(a0),a0
.reb:	write (a0)
	rts

.it_s_0:	move.w #'0'*256,affiche_decim
	bra.s .reb

	BSS
affiche_decim:
	ds.b 8+1
	even
	TEXT
***************************************************************************
	endc
	
;SAVE		sauve une s‚rie de registres (movem)
;LOAD		restaure "
;APPEL
;WAIT
;INIT
;SUPERVISOR
;USER		~aprŠs SUPERVISOR~
;SUP_EXEC		PEA \1 = adresse
;SYNCRO
;SYNCRO_GEM
;RESOLUT		\1=vid‚o mode,\2=0:ST / \2=3:FALC
;SET_MODE
;MOUSEOFF
;MOUSEON
;WRITE		PEA\1 texte
;SET_GEM
;RESTORE_GEM		~aprŠs~ SET_GEM
;RESTORE_GEM_RES	~aprŠs~ SET_GEM  \1=taille … prot‚ger
;RESTORE_GEM_ERR	~aprŠs~ SET_GEM  \1=code … renvoyer … l'appelant
;FILE_OPEN		\1=read/write PEA\2=name
;FILE_READ		\1 =ad. \2=nb. \3=handle
;FILE_WRITE		\1 =ad. \2=nb. \3=handle
;FILE_SEEK		\1 =seekmode, \2=handle, \3=offset.l
;FILE_CLOSE		\1=handle
;FS_FIRST		\1=#type(fichier,directory), PEA\2=name
;FS_NEXT
;GET_DRIVE		renvoie d0=unit‚
;SET_DRIVE		\1=unit‚
;GET_PATH		\1=unit‚ (0=current), PEA\2=adresse de destination
;SET_PATH		PEA\1=path d‚sir‚
;GET_DTA		renvoie d0=adresse
;SET_DTA		PEA\1=adresse
;GET_DTA		d0=adresse

;RESERVE_SCREENS	~en superviseur~ \1=nb.ecr \2=resolut
;		+ variables : x_max_p,y_max_p,nb_bits_per_pix
;RESTORE_SCREENS
;SAVE_PALETTE
;RESTORE_PALETTE	~aprŠs SAVE_PALETTE~
;COLOR256		tests color‚s en 256 couleurs
;COLOR		idem en 16
;ZILOGR:		zilog read : \1=register \2=byte
;ZILOGW:		zilog write : \1=register \2=byte

;	move.l #'*.*'*256,whato
;	lea texte,a0		; 35 chars max.
;	bsr copy_in2_select
;	bsr fileselect
;	tst d4
;	beq.s annule
