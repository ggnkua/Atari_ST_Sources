; --- maniŠre de noter une ligne devenue inutile
; du moins on le suppose...


STE equ 0		; 1 pour STE, 0 pour TT et Falcon

LANG equ 0		; 0 = francais, 1 = anglais

DEFNUM	equ 8 ; limite des premiers mots cr‚ant d'autres (variable..)

VERSION macro
	dc.b "0.4.0"
	endm

DATE macro
	if LANG=0
		dc.b "09/06/2022"
	else
		dc.b "06/09/2022"
	endif
	endm


;*************************************
;*                                   *
;*       F O R T H     1989          *
;*                                   *
;*************************************


	if STE=0
		if LANG=0
   		OUTPUT "FORTH.PRG"
   	else
   		OUTPUT "ENGLISH\FORTH.PRG"
   	endif
   	opt w+,P=68030,P=68882
   else
   	if LANG=0
      	OUTPUT "FORTHSTE.PRG"
      else
      	OUTPUT "ENGLISH\FORTHSTE.PRG"
      endif
   	opt w+,P=68000
   endif

TRC MACRO
   movem.l d0-d2/a0-a1,-(sp)
	move #7,-(sp)
	move #2,-(sp)
	move #3,-(sp)
	trap #13
	addq.l #6,sp
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
	movem.l (sp)+,d0-d2/a0-a1
	ENDM

NON MACRO
   dc.w 0
   ENDM

GOSUB MACRO
	if STE=0
		bsr.l \1
	else
		jsr \1
	endif
	ENDM

COPIE MACRO         ; debut, fin [ , flag-FORTH.LIB ]
   ifd   LIB
      if \#=3
         dc.w 3   ; si LIB et 3 arguments, pas de copie mais SAUT
      else
         dc.w ((\2-\1)/2-1)
         dc.w 2
      endif
   else
      dc.w ((\2-\1)/2-1)   ; nombre de mots moins 1 ( dbra )
      dc.w 2
   endif
   ENDM

; copie optimis‚e si l'instruction pr‚c‚dente est une constante
; and/or/xor

COPIE_OPT4 MACRO         ; debut, fin, code instruction
	dc.w \3			 ; instruction rempla‡ant move.l #xxx,-(a6)
   dc.w ((\2-\1)/2-1)   ; nombre de mots moins 1 ( dbra )
   dc.w $4002
   ENDM

; optimisation pour add/sub (avec addq/subq possible)

COPIE_OPT5 MACRO         ; debut, fin, code instruction
	dc.w \3			 ; instruction rempla‡ant move.l #xxx,-(a6)
   dc.w ((\2-\1)/2-1)   ; nombre de mots moins 1 ( dbra )
   dc.w $5002
   ENDM

; optimisation pour <,>,=,<>

COPIE_OPT6 MACRO         ; debut, fin
   dc.w ((\2-\1)/2-1)   ; nombre de mots moins 1 ( dbra )
   dc.w $6002
   ENDM

SAUT MACRO
   dc.w 3
   ENDM

ASS MACRO
   dc.w \1
   ENDM

UP MACRO
   addq.l #4,a6
   ENDM

DW MACRO
   subq.l #4,a6
   ENDM

XBIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

BIOS MACRO    ; fn,pile
   move #\1,-(sp)
   trap #13
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEMDOS MACRO    ; fn,pile
   move #\1,-(sp)
   trap #1
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

VCONTROL MACRO      ; fn,pts,int,subfn
	if STE=0
	   lea (control.l,pc),a0
	else
		lea control,a0
	endif
   move #\1,(a0)+
   move #\2,(a0)
   addq.l #4,a0
   move #\3,(a0)
   addq.l #4,a0
   move #\4,(a0)+
   move handle,(a0)
   ENDM

VDI MACRO
   move.l #vdipb,d1
   moveq #$73,d0
   trap #2
   ENDM

AES MACRO
   move.l #aespb,d1
   move.l #$c8,d0
   trap #2
   ENDM

ACONTROL MACRO         ;   fn,int,into,add
   if STE=0
	   lea (control.l,pc),a0
	else
		lea control,a0
	endif
   move #\1,(a0)+
   move #\2,(a0)+
   move #\3,(a0)+
   move #\4,(a0)+
   clr (a0)
   ENDM

GEM_AES MACRO
   move.l #\1,d1
   move.l #$c8,d0
   trap #2
   ENDM

GEM_VDI MACRO
   move.l #\1,a0
   move.l a0,d1
   move.l (a0),a0
   move i_handle,12(a0)
   moveq #$73,d0
   trap #2
   ENDM

 data
 even

aespb: dc.l control,global,intin,intout,addrin,addrout
vdipb: dc.l control,intin,ptsin,intout,ptsout

; --- vdiedit: dc.l contedit,intedit,dum,dum,dum
; --- vdifen: dc.l contedit,intfen,dum,dum,dum

	if STE=0
info: dc.b "FORTH.INF",0
	else
info: dc.b "FORTHSTE.INF",0
	endif
	if LANG=0
w_titre: dc.b "Mon Bon FORTH "
	VERSION
	dc.b 0,0
w_edit: dc.b "Mon Bon Editeur",0,0
bloc0: dc.b " Aucun bloc n'est marqu‚",0
bloc1: dc.b " Un bloc est marqu‚",0

 even
avert: dc.b "[2][ Inserer la diquette     | … formater | dans le lecteur "
avertd: dc.b "A ][Ca y est|Annuler]",0
avert1: dc.b "[1][ L'imprimante n'est pas | | prete … recevoir. ]"
        dc.b "[Annuler|Imprimer]",0
		even
exep0: dc.b "[1][ Alerte: x BOMBES | "
		dc.b	"                     | (Pointeur d'ex‚cution | sur la pile )][ Stop ]",0
		even
exep2: dc.b "erreur de bus       "
exep3: dc.b "erreur d'adresse    "
exep4: dc.b "instruction ill‚gale"
exep5: dc.b "division par z‚ro   "

pasbon: dc.b "Ce n'est pas un mot utitlisateur",0

	else
w_titre: dc.b "My Good FORTH "
	VERSION
	dc.b 0,0
w_edit: dc.b "My Good Editor",0,0
bloc0: dc.b " No block selected",0
bloc1: dc.b " A block is selected",0

 even
avert: dc.b "[2][ Insery the floopy disk   | to be fomatted | into drive "
avertd: dc.b "A ][ Done | Cancel ]",0
avert1: dc.b "[1][ Printer is not | | ready. ]"
        dc.b "[ Cancel | Print ]",0
		even
exep0: dc.b "[1][ Alert : x BOMBS  | "
		dc.b	"                     | (execution pointer | left on the stack)][ Stop ]",0
		even
exep2: dc.b "bus error           "
exep3: dc.b "address error       "
exep4: dc.b "illegal instruction "
exep5: dc.b "division by zero    "

pasbon: dc.b "This is not a user word",0

	endif

 even

pilptr: dc.l pile+4100
topedit: dc.w 0
retptr: dc.l retour+4100
base: dc.l 10
indptr: dc.l indice
; laisser cons‚cutifs
debutb: dc.w -1
finb: dc.w -1
ligne: dc.w -1
; jusque l…
editb: dc.w 0
trc: dc.w 0
trcmot: dc.w 0
ecran: dc.w 0
formptr: dc.l form+80
opt_count: dc.l 0					; global-4 compte les optimisations de compilb
global: dc.l 0,0,0,0,0,0,0,0
	dc.l 0	; valeur supp … global indiquant le type d'AES
				; 0: normal, 1 MyAES, 2 XaAES, 3 NAES
sizeptr: dc.w 1
lstptr: dc.l arrptr+4
arrptr: dc.l lstdata
        dcb.l 10,0
lst: dc.l 0
remb: dc.l remdata
stt: dc.w 0
accuptr: dc.l accudat
isfast: dc.w 0						; par d‚faut, mode slow
isbomb: dc.w 1						; par d‚faut, vecteurs bombes d‚tourn‚s
alert_mask: dc.w -1				; toutes les alerts valid‚es par d‚faut
							; bit 0 avertir si ‚crasement fichier en sauvegarde
							; bit 1 avertir si bloc … sauvegarder au lieu de tout
							; bit 2 avertir si on quitte et que l'‚dition a chang‚ depuis
dpth: dc.w 53
dpthln: dc.w 52
dpthex: dc.w 50
pilbase: dc.l pile+4100
isret: dc.w 0
help: dc.w 0
screen_percent: dc.w 100		; defaut 100% ‚cran
langage: dc.w -1				; fix‚ par FORTH.INI ou … d‚faut par la ROM


 bss
 even

          ds.b 3000        ; pour les ordres en fin de zone data
; ne pas s‚parer
mod_options: ds.l 1
chemin_mod:	ds.b 128
; jusqu'ici^^^
inc_ptr: ds.l 1	; pointeur sur la chaine des bloc d'>include FOR ou z‚ro
						;chaque bloc, 256 octets:
						; LONG pointeur bloc suivant
						; WORD handler fichier ouvert
						; WORD nbr de lignes restantes
						; LONG taille fichier puis sauvegarde compilptr
						; le reste correspond … une ligne du fichier + WORD taille ligne suivant
						; dernier octet du bloc = 00 (FOR), FF (DEF)
slider: ds.w 2		; valeurs de ligne d‚but et nbr lignes du slider sous l'‚diteur
in_data: ds.w 1	; garde valeur topedit en entrant dans edit
			ds.l 1	; garde valeur pointeur de fin de texte
change_flag: ds.w 1 ; FF si les donn‚es ont chang‚ entre entr‚e et sortie de edit
						; remis … z‚ro par saveb/export sur l'ensemble du fichier
zone:     ds.l 16
topsav2:  ds.l 1
topsave:  ds.l 1
form:     ds.b 80
; --- trcreg:   ds.l 16
bfsize:   ds.l 1
bfptr:    ds.l 1
ksize:    ds.w 1
savpil:   ds.l 1
handle:   ds.w 1
i_handle: ds.w 1
g_handle: ds.w 1
intin:    ds.w 128
intout:   ds.w 272
i_intout: ds.w 128
addrin:   ds.l 64
addrout:  ds.l 64
ptsin:    ds.w 128
ptsout:   ds.w 128
vt_int:	ds.w 128 ; avant d‚clar‚ par dessus les 514 w de intedit
lignes:   ds.w 1
demi_ecran: ds.w 1
colonnes: ds.w 1
dum:      ds.w 2
	; un tread est organis‚ ainsi:
	; +0		*WORD code du mot … ex‚cuter	(les 4 lignes * sont la partie ex‚cutable!)
	; +2		*WORD 0 (=empiler valeur)
	; +4		*LONG id (celui pass‚ … thread, id=0 pour le mode direct)
	; +8		*WORD code thkill
	; +10		LONG next (adr next thread ou z‚ro si fin)
	; +14		LONG state (masque de bits)
	; +18		LONG a4,a5
	; +26		WORD base actuelle
	; +28    WORD station VDI ‚ventuelle...
	; +30		LONG indptr
	; +34		LONG adresse pile (pass‚e … thread)
	; +38		LONG adresse retours
	; +42		LONG adresse page(pass‚e … thread)
	; +46		128 longs (la structure indptr)
	; +558	1025 longs (la pile des retours)
	; +4658  fin retours
	; debut thread0
	; state: xxxxxxxx xxxxxxxx xxxxxxxx smtt xxvr
	; r=1 running, 0=pause (ou synch)
	; v=1 si station VDI ouverte
	; s=1 sync, m=1 syncmain, tt=indice tableau synchro 0 … 3
thread0:	ds.b 46
indice:   ds.l 128
retour:   ds.l 1025
	; fin thread0
thhead:	ds.l 1		; pointeur sur la tˆte de liste des threads (ou 0)
thptr:	ds.l 1		; pointeur thread courant (ou 0)
thsynctab: ds.b 4		; tableau de 4 valeurs de synchro
pile:     ds.l 1025
debut_prog: ds.l 1
program:  ds.l 1
topprg:   ds.l 1
edbuf:    ds.b 1724
edsav:    ds.b 512*4		; 4 buffers de sauvegarde
edoffset: ds.w 1			; pointeur 0,512,1024,1536 dans les buffers de sauvegarde
def:      ds.w 1
forth:    ds.w 1
forthsav: ds.w 1
dicco:    ds.w 1
sommet:   ds.l 1
somsave:  ds.l 1
mot:      ds.b 42
erreur:   ds.w 1
exebuf:   ds.b 1604
doesreg:  ds.l 2
regist:   ds.l 16
tamp:     ds.b 40
pad:      ds.b 1028
dtabuf:   ds.b 44
; laisser cons‚cutifs
fhdl:     ds.w 1
ldbuf:    ds.b 6
cmplptr:  ds.l 1
fincomp:  ds.w 1
; jusque l…
formbuf:  ds.l 1
uspile:   ds.l 1
vectbuf:  ds.l 4		; 4 vecteurs bombes
old_joyst: ds.l 1		; le vecteur joystick
old_mouse: ds.l 1
lstdata:  ds.l 256
remdata:  ds.l 50
basesav:  ds.l 1
sttdata:  ds.b 1024
sttptr:   ds.l 1
accudat:  ds.b 1024
setdat:   ds.b 8198
setdeb:   ds.w 1
setnbr:   ds.w 1
signe:    ds.b 1
modulo:   ds.b 1
affbuf:   ds.b 28
fixn:     ds.w 1
courant:  ds.w 1
save:     ds.l 3
szone:    ds.l 1
topmem:   ds.l 1
botmem:   ds.l 1
in_def:	 ds.w 1
; ne pas s‚parer
ass:      ds.w 1
find:     ds.w 1
; -----
but:      ds.l 2
indexadr: ds.l 1
indextab: ds.b 128
mfdb_s:   ds.w 10
mfdb_d:   ds.w 10
copy_pts: ds.w 8
mf1:      ds.w 18
mf2:      ds.w 18
edit_haut: ds.w 8
edit_bas: ds.w 8
end_keys: ds.l 1
; ne pas s‚parer
agi_intout: ds.w 5			; capacit‚s de l'AES
planes: ds.w 1
work_out: ds.w 57
; jusqu'ici
redrawdat: ds.w 6 ; flag, handle, x,y,x',y'
bspage: ds.l 1
_app_flag: ds.l 1
wd_table: ds.l 20		; 20 dialogues en fenˆtres simultan‚s
trace_win: ds.w 9		; fenetre TRACE + nombre de caractŠres par ligne
trc_aff: ds.b 200		; 160 caractŠres en 1280x960.
commande_buf: ds.b 512	; pour >exec et >export
chemin: ds.b 80
fichier: ds.b 100
source: ds.b 100
chetxt: ds.b 80
fichtxt: ds.b 100
gcard: ds.l 1			; vaut 0 pour un mode Shifter compatile Atari, 1 si c'est unmode de carte graphique
cpu_value: ds.l 1		; CPU cookie
mch_value: ds.l 1		; MCH cookie
snd_value: ds.l 1		; SND cookie
apk_value: ds.l 1		; APK cookie
mouse_on: ds.b 1		; flag pour laisser la souris "on"
ass_const: ds.b 1		; si constante empil‚e pour optimiser instruction suivante
is_saga:	ds.b 1
	even

	

 text

   jmp initial

debut:
   bsr cr
   lea ok(pc),a0
   bsr write_str
   move.l edb(pc),a0     ; buffer de ligne
   tst erreur
   bne.s .suite          ; il y a eu une erreur, remet la mˆme ligne
   bsr treat_saveline
.suite: clr erreur
   clr def
   move #510,d6          ; taille maxi
   ext.l d6
   move.l #prompt_list,end_keys
   bsr edition           ; edition.
   cmp #$5400,d0			 ; Shift F1 = Help
   beq.s .lb1a
   cmp #$6200,d0			 ; help?
   bne.s .lb1
.lb1a:
   jsr help_display_prompt
   move #1,erreur			 ; astuce pour qu'il recopie la ligne en cours!
   bra.s debut
.lb1:
   cmp #$6100,d0         ; UNDO ?
   beq debut	          ; si oui, ne fait rien de cette ligne
   cmp #$5500,d0			 ; Shift F2 simule UNDO
   beq debut
   cmp #$5D00,d0			 ; Shift F10 = Shift Insert
   beq.s .lb1b
   cmp #$5230,d0         ; shift INSERT
   bne.s .quoi           ; non, ligne normale
.lb1b:
	bsr treat_shiftins
   bra.s .suite
.quoi:
   bsr cr                ; saut de ligne
ici: movem.l a4-a6,-(a7) ; sauve l'essentiel
   move.l edb(pc),a0
   move finb,ligne
   bsr compil            ; compile
   tst erreur
   bne.s .lb1
   cmp.l pilptr,a6       ; d‚passement de pile ?
   beq.s .lb1
   move #1,erreur        ; si oui, on le signale
   bsr cr
   lea bugpil(pc),a0
   bsr write_str
.lb1:
   movem.l (a7)+,a4-a6
   tst erreur
   bne debut
   tst trc
   beq.s .exe1
   bsr exetrc
   bra debut
.exe1: bsr execut
   bra debut

treat_shiftins:
	move edoffset,d5
	move.b #'',okmem+2
.lb1bb:
	move.l d5,-(sp)
   bsr cr
   lea okmem(pc),a0
   addq.b #1,2(a0)
   cmp.b #'',2(a0)
   bmi.s .lb0
   move.b #'',2(a0)
.lb0:
   bsr write_str
   move.l (sp)+,d5
   move.l #edsav,a1
   sub #512,d5
   and #$7ff,d5
   add.w d5,a1
   move.l edb(pc),a0	 ; lea ([edb,pc]),a0
   move.l a0,a2
.copie:
   move.b (a1)+,(a2)+
   bne.s .copie
   move.l d5,-(sp)
   bsr write_str
   move.l (sp)+,d5
.shift:
	bsr.s .get_time
	move.l d0,d4
	add.l #200,d4
.wait:
	move.l kbshift,a0
	move.b (a0),d0
	and.b #$03,d0				; shift toujours appuy‚?
	beq.s .exit					; non, on quitte
	bsr.s .get_time
	cmp.l d0,d4
	bpl.s .wait					; attendre une seconde
	bra.s .lb1bb				; sinon, remettre ligne d'avant
.exit:
   bsr cr
   lea ok(pc),a0
   bsr write_str
	move.l edb(pc),a0
	rts
.get_time:
	pea .timer(pc)
	XBIOS 38,6
	rts
.timer:
	move.l $4ba.w,d0
	rts

; a0 pointe sur la ligne de commande … sauver
; rien n'est modifi‚ si la ligne est vide ou
; si elle et ‚gale … une ligne d‚j… sauv‚e (deux fois la mˆme commande entr‚e)

treat_saveline:
	tst.b (a0)				; vide?
	beq.s .exit				; oui, rien … sauver
	move.l #edsav,a1		; zone de sauvegarde
	moveq #3,d0
.again:
	move.l a1,a2
.comp:
	cmp.b (a0)+,(a2)+
	bne.s .pas_egal
	tst.b -1(a0)			; chaine finie?
	bne.s .comp
	bra.s .exit1			; chaines ‚gales, on ne sauve pas !
.pas_egal:
	move.l edb(pc),a0		; retour au d‚but
	lea 512(a1),a1			; chaine suivante
	dbf d0,.again			; compare aux 4 chaines....
   move.l #edsav,a1     ; sinon, on recopie le tout dans le buffer annexe
   move edoffset,d0
   add.w d0,a1
   add #512,d0				; buffer suivant
   and #$7FF,d0			; boucle
   move d0,edoffset
.lb0: move.b (a0)+,(a1)+
   bne.s .lb0
.exit1:
   move.l edb(pc),a0
   clr.b (a0)
.exit:
	rts

; retour au bureau

fin:
	tst change_flag
	beq.s .lb0					; pas de changement, on quitte
	btst #2,alert_mask+1		; voulait-on l'alerte?
	beq.s .lb0					; non, on quitte!
   lea saveb3,a0
   jsr forth_alert
   beq.s .lb0					; l'utilisateur confime, on quitte|
	rts							; sinon retour, comme une fonction normale
	
.lb0:
	bsr mouse			; remet vecteur joystick et r‚glages souris
   move #2,-(sp)
   move #15,-(sp)
   XBIOS 35,6

	tst.w isbomb			; vecteurs d‚tourn‚s?
	beq.s .no_detour
   clr.l -(sp)
   GEMDOS 32,6
   move.w  #8,a0
   move.l  #vectbuf,a1
   moveq #3,d1
.hgf: move.l (a1)+,(a0)+
   dbf d1,.hgf
   move.l  d0,-(sp)
   GEMDOS 32,6
.no_detour:

   bsr fastclose
   GEM_VDI show_mouse
   GEM_VDI close_work     ; ferme la station interne
   move handle,i_handle
   GEM_VDI close_work     ; puis ferme l'externe
   GEM_AES appl_exit

   move.l uspile,a7
   GEMDOS 0,2                 ; bye !

; procedures d'exeption nø2 … 5

gloups2: move.l #exep2,a0
	moveq #'2',d0
   bra.s gloups_com

gloups3: move.l #exep3,a0
	moveq #'3',d0
   bra.s gloups_com

gloups4: move.l #exep4,a0
	moveq #'4',d0
   bra.s gloups_com

gloups5: move.l #exep5,a0
	moveq #'5',d0

gloups_com:
	lea exep0,a1
	move.l a1,addrin		; pour l'alerte
	lea 13(a1),a1
	move.b d0,(a1)+		; num‚ro de bombes
	move.l #' BOM',(a1)+
	if LANG=0
		move.l #'BES ',(a1)+
	else
		move.l #'BS  ',(a1)+
	endif
	addq.l #2,a1			; le d‚tail
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+	; copie 20 caractŠres
	move.l uspile,a1
   move a1,usp
   move.l #aff_gloups,2(sp) ; mon PC
   and.b #$f,6(sp)			; format 0 de sauvegarde!
   move.l a4,retptr
   move.l a6,d0
   bclr #0,d0
   move.l d0,a6
   move.l a5,-(a6)		; le pointeur d'ex‚cution (pour info)
   move.l a6,pilptr
   rte

aff_gloups:
	jsr _forth_alert
	bra debut

ok:      dc.b "Ok > ",0
okmem:	dc.b " {0} ",0

 even

	if LANG=0

eedd: dc.b " Ligne: 00000   Libre: 000 Ko",0

help_txt: dc.b " F1 d‚but texte    F10 fin texte",0
			dc.b  " F2 page haut      F9 page bas",0
			dc.b  " F3 d‚but bloc     F4 fin bloc",0
			dc.b  "F3 <<aller bloc  F4 aller bloc>>",0
			dc.b  " F5 cache bloc    F5 efface bloc",0
			dc.b  "F6 d‚place bloc  F7 colle bloc",0
			dc.b  " F7 cherche      F8 cherche suivant",0
			dc.b  " Esc quitte  F2\UNDO annule ligne",0
			dc.b  "^Del efface ligne  F6 aller ligne",0
			dc.b 0

help_prompt: dc.b " ENTER   ex‚cute la ligne",0
				dc.b  " UNDO    (F2 ou Esc)annule la ligne",0
				dc.b  " Ins    (F10)rappelle ligne sauv‚e",0
				dc.b  "         garder Shift=autres lignes",0
				dc.b  " edit    passe sous l'‚diteur",0
				dc.b  " system  quitte l'interpr‚teur",0
				dc.b  " loadb   charge un fichier",0
				dc.b  " saveb   sauve un fichier",0
				dc.b  " buf!    efface texte ‚dit‚",0
				dc.b  " compilb compile le source",0
				dc.b  " desk    accŠs menu/acc/fenˆtre",0
				dc.b 0

bugass: dc.b "  --->  Mot non assemblable",0
bugundef: dc.b " Placer >comp avant :: xxx ; pour d‚finir les variables !",0
cbug0: dc.b " Format d'un nombre r‚el incorrect",0
cbug1: dc.b " Mot manquant aprŠs un mot de d‚finition",0
cbug2: dc.b " Chaine absente ou incomplŠte aprŠs .",34," ou ",34,0
cbug3: dc.b " Mot inconnu ou nombre exprim‚ dans une mauvaise base : ",0
cbug4: dc.b " Buffer d'ex‚cution plein ( utiliser >comp ) -> ",0
cbug5: dc.b " Fichier … inclure dans une d‚finition!",0
cbug6: dc.b " D‚finitions … inclure hors d'une d‚finition!",0
cbug7: dc.b " Erreur >include: format PRG/FOR/DEF non reconnu!",0
cbug8: dc.b " Erreur >include: chargement impossible!",0
cbug9: dc.b " Erreur >include: masque d'options absent sur la pile!",0
cbug10: dc.b " Erreur >include: chaine fichier mal ferm‚e!",0
cbug11: dc.b " Erreur >include: m‚moire insuffisante!",0
cbug12: dc.b " Erreur >true/>false: nø de flag incorrect!",0
cbug13: dc.b " Erreur >prgflags: trois constantes attendues sur la pile!",0
cbug14: dc.b " Red‚finition d'un mot existant : ",0
troplong: dc.b " Mot trop long ( 40 caractŠres maximum )",0
bugpil: dc.b " Then, repeat, ->. ou endcase manquant",0

	else

eedd: dc.b " Line : 00000   Free : 000 Ko",0

help_txt: dc.b " F1 text start    F10 text end",0
			dc.b  " F2 page up       F9 page down",0
			dc.b  " F3 block start   F4 block end",0
			dc.b  "F3 <<go block   F4 go block>>",0
			dc.b  " F5 hide block   F5 delete block",0
			dc.b  "F6 move block   F7 paste block",0
			dc.b  " F7 find        F8 find next",0
			dc.b  " Esc quit   F2\UNDO cancel line",0
			dc.b  "^Del delete line  F6 goto line",0
			dc.b 0

help_prompt: dc.b " ENTER   execute current line",0
				dc.b  " UNDO    (F2/Esc)del current ligne",0
				dc.b  " Ins    (F10)recall saved line",0
				dc.b  "         Shift pressed=other lines",0
				dc.b  " edit    enter the editor",0
				dc.b  " system  exit to desktop",0
				dc.b  " loadb   load a file",0
				dc.b  " saveb   save a file",0
				dc.b  " buf!    delete text from editor",0
				dc.b  " compilb compile text",0
				dc.b  " desk    access to menu/acc/window",0
				dc.b 0

bugass: dc.b "  --->  Can't be assembled",0
bugundef: dc.b " Place >comp before :: xxx ; to define variables !",0
cbug0: dc.b " Bad format for a real number",0
cbug1: dc.b " Missing word after a definition word",0
cbug2: dc.b " Missing or not ending string after .",34," or ",34,0
cbug3: dc.b " Unknown word or bad number in current base : ",0
cbug4: dc.b " Execution buffer is full ( use >comp ) -> ",0
cbug5: dc.b " Included file within a definition!",0
cbug6: dc.b " D‚finitions … inclure hors d'une d‚finition!",0
cbug7: dc.b " Error >include: bad PRG/FOR/DEF format!",0
cbug8: dc.b " Error >include: can't load file!",0
cbug9: dc.b " Error >include: missing option mask on stack!",0
cbug10: dc.b " Error >include: file string not closed!",0
cbug11: dc.b " Error >include: not enough memory!",0
cbug12: dc.b " Error >true/>false: bad flag number!",0
cbug13: dc.b " Error >prgflags: three constants are expected on stack!",0
cbug14: dc.b " Attempt to redefine an existing word : ",0
troplong: dc.b " Word too long ( 40 characters maximum )",0
bugpil: dc.b " Missing Then, repeat, ->. or endcase",0

	endif

 even

; en mode direct, les touches ENTER,sh INSERT et UNDO mettent fin … l'‚dition
; HELP
; la touche BACKSPACE sur la prmiŠre colonne non.
; emulation: Shift F1 = HELP et Shift F10 = Shift Insert, Shift F2 = UNDO

prompt_list: dc.w 0,$1c0d,$720d,$6100,$5230,$6200,$5400,$5D00,$5500,0

; sous l'‚diteur, ENTER, UNDO, ESC, UP, DOWN, ^DEL, F1 …F10, F15 … F17
; et F11 pour simuler Help, F12 UNDO
; la touche BACKSPACE sur la premiŠre colonne oui
; HELP, F13/F14

edit_list: dc.w 1,$1c0d,$720d,$6100,$011b,$4800,$4838,$5000,$5032,$531f
           dc.w $3b00,$3c00,$3d00,$3e00,$3f00,$4000,$4100,$4200,$4300,$4400
           dc.w $5800,$5900,$5a00,$5500,$6200,$5600,$5700,$5400,0

; execution d'une phrase

execut:  move.l #exebuf,a5
         move.l pilptr,a6
         move.l retptr,a4
         tst isfast
         beq slowexe
fastexe: move (a5)+,d1
         cmp #diko,d1
         bpl.s .lab1
			if STE=0
	         jsr ([adresse,pc,d1.w*4])
	      else
	      	move.w d1,d0
	      	asl #2,d0
	      	lea adresse,a0
	      	move.l (a0,d0.w),a0
	      	jsr (a0)
	      endif
         bra.s fastexe
.lab1:   move.l a5,-(a4)
			if STE=0
	         move.l (adresse,pc,d1.w*4),a5
	      else
	      	asl #2,d1
	      	lea adresse,a0
	      	move.l (a0,d1.w),a5
	      endif
         bra.s fastexe

; execution en mode trace

exetrc:  move.l #exebuf,a5
         move.l pilptr,a6
         move.l retptr,a4
tracexe: move (a5)+,d4
         ext.l d4
         move #diko,d2
         cmp d2,d4
         bpl .lb1
         tst trcmot
         beq.s .non
			bsr.s aff_trc
         beq.s exefin
.non:    move d4,d1				; utile pour routines tos
			lsl.l #2,d4
			lea adresse,a1
         move.l  0(a1,d4),a1
         jsr (a1)
         bra.s tracexe
.lb1:
			bsr.s aff_trc
			beq.s exefin
         move.l a5,-(a4)
         lsl.l #2,d4
         lea adresse,a1
         move.l  0(a1,d4),a5
         bra.s tracexe
exefin:  move.l a4,retptr
         move.l a6,pilptr
         rts

aff_trc:
         lea ordres,a3
         lea trc_aff,a2		; chaine de sortie
			move d4,d0
.lb:
         move.b (a3)+,d1
         ext.w d1
         ext.l d1
         subq #1,d0
         bmi.s .lb0
         add.l d1,a3
         bra.s .lb
.lb0:    moveq #15,d0				; nombre maxi de caractŠres
			sub d1,d0
			bpl.s .lb2
			moveq #15,d1
			moveq #0,d0
.lb2:
			subq #1,d1
.lb1:    move.b (a3)+,(a2)+
         dbf d1,.lb1
.lb3:
         move.b #32,(a2)+
         dbf d0,.lb3
         move.b #':',(a2)+
         move.b #32,(a2)+
         move.l d4,-(sp)
         move.l fenetre,-(sp)
         move.l a2,-(sp)
         lea trace_win,a0
         GOSUB _setp
         bsr cr
         move.l (sp)+,a2
         move.l a6,-(sp)		; sauve la pile
         move #1,ecran			; ne pas afficher encore
         move #198,d7		; taille maxi de la chaine
         cmp trace_win+16,d7	; largeur maxi … l'‚cran
         bmi.s .lb6				; en dessous, ‡a va
         move trace_win+16,d7
.lb6:
			sub #17,d7				; le mot est d‚j… dans la chaine
.lb5:
         cmp.l pilbase,a6
         bpl.s .lb4
     		jsr point
			move.l a1,d0			; chaine renvoy‚e
.lb7:
			tst.b (a1)+
			bne.s .lb7
			sub.l d0,a1
			subq.l #1,a1
			cmp a1,d7
			bmi.s .lb4				; plus assez de place, on sort
			sub a1,d7
			move.l d0,a1			; reprend la chaine
.lb8:
			move.b (a1)+,(a2)+	; copie
			bne.s .lb8
			subq.l #1,a2			; ote le z‚ro
			move.b #32,(a2)+
			subq #1,d7				; moins l'espace
			bmi.s .lb4
			beq.s .lb4
			bra.s .lb5
.lb4:
			clr ecran
			clr.b -(a2)				; enlŠve le dernier espace
			move.l (sp)+,a6		; r‚cupŠre la pile
         lea trc_aff,a0
         move trace_win+16,d7
         cmp #199,d7
         bmi.s .lb9
         move #199,d7
.lb9:
         clr.b 0(a0,d7.w)		; par s‚curit‚, termine la chaine
         bsr write_str
         move.l (sp)+,a0
         if STE=1
         	jsr _setp
         else
	         bsr _setp
	      endif
         move.l (sp)+,d4
.wait:   move #$ff,-(sp)
         GEMDOS 6,4
         tst.l d0
         beq.s .wait
         cmp.l #$1001b,d0
         rts


slowexe: move (a5)+,d1
         lea adresse,a1
         moveq #15,d0
         move.l kbshift,a0
         and.b (a0),d0
         cmp.b #15,d0
         beq.s .break
         cmp.l pilbase,a6
         bgt.s .bug
         cmp #diko,d1
         bpl.s .lab1
         lsl #2,d1
         move.l  0(a1,d1.w),a1
         lsr #2,d1
         jsr (a1)
         bra.s slowexe
.lab1:   move.l a5,-(a4)
         lsl #2,d1
         move.l  0(a1,d1.w),a5
         bra.s slowexe
.break:  pea .brktext(pc)
         bra.s .lab2
.bug:    pea .bug0(pc)
         move.l pilbase,a6
.lab2:
			lea exep0,a0
			lea 13(a0),a1
			move.l #'    ',d0
			move.b d0,(a1)+
			move.l d0,(a1)+
			move.l d0,(a1)+	; efface les ‚ventuelles bombes
			addq.l #2,a1
			move.l (sp)+,a2
			move.l (a2)+,(a1)+	; copie le message dans l'alerte
			move.l (a2)+,(a1)+
			move.l (a2)+,(a1)+
			move.l (a2)+,(a1)+
			move.l (a2)+,(a1)+
         move.l a5,-(a6)
         jsr forth_alert
         bra exefin
	if LANG=0
.brktext: dc.b "Arrˆt utilisateur ! "
.bug0:   dc.b  "La pile est vide !  "
	else
.brktext: dc.b "User interruption ! "
.bug0:	dc.b  "Stack is empty !    "
	endif

 even

; recherche du mot suivant dans la phrase

motsuiv: move.l #mot,a1
         moveq #0,d1
         moveq #32,d2
.loop:   tst.b (a0)			; fin de ligne ?
         bne.s .lb0
         tst.l inc_ptr		; nous incluons un autre fichier depuis le disque?
         beq.s .ram
			bsr _load_line		; oui, on charge la ligne suivante!
			bra.s .loop
.ram:
         move ligne,d0
         cmp finb,d0
         beq.s .fin
         tst (a0)
         beq.s .fin
         addq.l #3,a0
         addq #1,ligne
         bra.s .loop
.lb0:    cmp.b (a0)+,d2
         beq.s .loop
         subq.l #1,a0
.lab1:   move.b (a0)+,d2
         bne.s .lab2
         subq.l #1,a0
         bra.s .sortie
.lab2:   cmp.b #32,d2
         beq.s .sortie
         move.b d2,(a1)+
         addq #1,d1
         cmp #41,d1
         bne.s .lab1
         bra.s .bug
.fin:    move #-1,fincomp
.sortie: clr.b (a1)
         move.b d1,d7
         cmp.b #1,d1
         bne.s .out
         cmp.b #'\',-(a1)
         bne.s .out
.lab3:   tst.b (a0)+
         bne.s .lab3
         subq.l #1,a0
         bra.s motsuiv
.out:    rts
.bug:    lea troplong(pc),a0
         bsr write_str
         addq.l #4,a7
         move #1,erreur
         move.l basesav,base
         move.l somsave,a6
         clr.b (a6)
         move.l a6,sommet
         move forthsav,forth
         move.l topsave,topprg
         rts

	; charge une nouvelle ligne
	; (a0) pointe sur le mot "taille" $00ss
	; en retour a0 pointe sur la nouvelle ligne (1er caractŠre r‚el)
	;           EQ si dans le mˆme fichier
	;				NE si on a d– fermer.

_load_line:
			movem.l d0-d4/a1-a3,-(sp)
			move.l inc_ptr,a3
			addq.l #4,a3		; skip chain address
			move (a3)+,d4		; file handle
			subq #1,(a3)+		; one line less
			bmi.s .ll1			; no more, close file !
			addq.l #4,a3		; skip saved compilptr
			move.l a3,-(sp)	; pour charger
			move (a0),d0		; size of next line
			ext.l d0
			move.l d0,-(sp)
			move d4,-(sp)
			GEMDOS 63,12		; fread
			tst.b 255-12(a3)	; dernier octet du buffer
			beq.s .for			; si 00, fichier FOR
			lea 128(a3),a0		; ici un DEF, va construire une ligne FOR
			move #$0010,-(a0)	; marqueur de fin de ligne 00 16
			moveq #32,d1		; espace
			move.b d1,-(a0)
			lea 16(a3),a3		; fin de ligne DEF
			moveq #7,d2
.copy_name:
			move.b -(a3),d0
			bne.s .ll3
			move.b d1,d0
.ll3:
			move.b d0,-(a0)	; copie le nom en repla‡ant les 00 par des espaces
			dbf d2,.copy_name
			move.b d1,-(a0)
			move.l #'tant',-(a0)
			move.l #'cons',-(a0)
			move.b d1,-(a0)
			move.b -3(a3),d1	; valeur de la constante !
			moveq #2,d2
.ll4:
			divs #10,d1			; la valeur sur 3 octets
			swap d1
			add.b #'0',d1
			move.b d1,-(a0)
			clr d1
			swap d1
			dbf d2,.ll4			; au final a0 pointe sur "nnn constant XXXXXXXX "+00+16
			moveq #0,d0
			bra.s .ll2			; renvoie EQ, mˆme fichier !			
.for:
			clr.b 0(a3,d0.l)	; ajoute un z‚ro en cas de derniŠre ligne vide
			lea 1(a3),a0		; skip "tab" byte in source code
			moveq #0,d0			; renvoie EQ si mˆme fichier
			bra.s .ll2
.ll1:
			move.l (a3),-(sp)	; original compilptr
			jsr depile_inc		; remove block from chain and close file
			move.l (sp)+,a0	; back on original compilptr
			moveq #1,d0			; renvoie NE si fichier ferm‚
.ll2:
			movem.l (sp)+,d0-d4/a1-a3
			rts

; compilation d'une phrase
; en entr‚e : a0 adresse du buffer
;             ligne : nombre de lignes d‚j… faites
;             finb :  nombre maxi de lignes … faire - 1


compil:  ;move.l a0,-(sp)
			;move.l (sp)+,a0
			clr.l ass
			clr in_def
			sf ass_const
         move.l #exebuf,a2
         move.l pilptr,a6
         move.l #exebuf+1588,but
         move.l botmem,but+4
         move forth,forthsav
         move.l sommet,somsave
         move.l topprg,topsave
.suite:  cmp.l but,a2		; fin buffer ?
         bpl .bug4			; erreur
         bsr motsuiv			; sinon mot suivant
         moveq #0,d4
         tst.b d1				; trouv‚?
         bne.s .lab1			; oui, on traite
.sortie: 
			move #146,(a2)		; sinon code [qt]
         move.l a0,cmplptr	; et on s'en va!
         bsr cache_off
         rts
.lab1:   cmp.b #1,d1			; 1 seul caractere?
			beq.s .pasquote
			lea mot,a4
			cmp.b #39,(a4)		; commence par quote?
			bne.s .pasquote
			subq #1,d1			; un caratere de moins
			move #-1,find
.decale:
			move.b 1(a4),(a4)+
			bne.s .decale
.pasquote:
			bsr find_word		; cherche le mot dans le dicco D4 = code mot
			beq .findic			; if EQ, then not found
         tst find
         beq.s .lb66
         clr find				; mode find xxx -> on va empiler
         move.l base,basesav
         move d4,d5			; code … empiler
         ext.l d5
         bra .lab5
.lb66:   cmp #171,d4    ; >comp
         beq .sortie
         cmp #113,d4    ; find
         bne.s .lb60
         move #-1,find
         bra .suite
.lb60:   cmp #862,d4		; >include
			bne.s .lb6o
			bsr inclure
			beq .bug			; si 0, une erreur, a0 d‚j… charg‚ avec la chaine
			bra .suite
.lb6o:
			cmp #863,d4		; >true
			bne.s .lb6a
.lb6b:
			bsr flag_cond
			beq .bug
			bra .suite
.lb6a:
			cmp #864,d4		; >false
			beq.s .lb6b
			cmp #865,d4		; >export
			bne.s .lb6c
			bsr export_source
			beq .bug
			bra .suite
.lb6c:
			cmp #866,d4
			bne.s .lb6d		; >exec
			bsr exec_prog
			beq .bug
			bra .suite
.lb6d:
			cmp #867,d4		; >prgflags (ignor‚ ici!)
			bne.s .lb6e
			bsr prg_flags
			bne .bug13		; manque les constantes !
			bra .suite
.lb6e:
			cmp #868,d4		; >ifflag
			bne.s .lb6f
			bsr ifflag		; saute jusqu'au >endf si if flag est faux, sinon compile en s‚quence
			beq .bug
			bra .suite
.lb6f:
			cmp #869,d4		; >endf
			beq .suite		; simplement ignor‚
			cmp #501,d4
			beq .suite
			cmp #502,d4
			beq .suite		; ( ) ignor‚s, servent … la lisibilit‚
			cmp #78,d4     ; :
         beq.s .lb61
         cmp #571,d4    ; ::
         bne .lab2
         move #1,ass
.lb61:   move forth,courant
			move #1,in_def	; au milieu d'une def
.nouvo:  bsr motsuiv			; mot … cr‚er
         tst.b d1
         beq .bug1			; vide, erreur
         movem.l d4,-(sp)
         bsr find_word		; mot d‚j… existant?
         movem.l (sp)+,d4
         bne .bug14			; si NE c'est que le mot existe d‚j…|
         cmp #78,d4
         beq.s .bon
         cmp #571,d4
         beq.s .bon
         move forth,(a2)+	; code du nouveau mot (variable)
.bon:    move.l sommet,a3	; va ajouter le mot au vocabulaire
         move.b d1,(a3)+	; sa taille
         subq #1,d1
         move.l #mot,a4
.lab7:   move.b (a4)+,(a3)+	; copie le mot
         dbf d1,.lab7
         move.l a3,sommet
         clr.b (a3)			; marque la fin
         cmp #78,d4
         beq.s .lb71
         cmp #571,d4
         bne.s .lb1
.lb71:   move.l a2,topsav2
         move.l #but,a2
         move.l (a2)+,d0
         move.l (a2),-4(a2)
         move.l d0,(a2)
         move.l topprg,a2
.lb1:    move forth,d0
         lsl #2,d0
         lea adresse,a3
         move.l a2,0(a3,d0.w)
         addq #1,forth
         cmp #78,d4			; une def?
         beq .suite			; oui, tout est ok
         cmp #571,d4			; un assemblage?
         bne.s .lb1z			; non alors c'est une variable !!
         move #437,(a2)+	; pour assembleur, le code
         bra .suite
.lb1z:	move.l #.undef,0(a3,d0.w)	; met une adresse qui pointe vers un mot g‚n‚rique
			bra .suite
.undef:	dc.w $7FFF			; code pour undefined -> erreur d'assemblage et demander ">comp"
.lab2:   tst ass				; ici cas g‚n‚ral
         beq.s .lb21
         jsr assemblons
         tst erreur
         beq .suite
         bra .bugend
.lb21:   move d4,(a2)+		; on met notre code
         cmp #DEFNUM,d4			; cr‚e un mot? (comme variable...)
         bmi .nouvo
         move.b mot,d2
         cmp.b #"&",d2		; idem ceux commen‡ant par &xx cr‚ent un mot
         beq .nouvo
; ici cas particuliers de compilation
         cmp #79,d4			; le ";" qui termine une def
         bne.s .lb0
         move.l a2,topprg
         move.l #but,a2
         move.l (a2)+,d0
         move.l (a2),-4(a2)
         move.l d0,(a2)
         move.l topsav2,a2
         clr in_def
         bra .suite
.lb0:    cmp #66,d4
         beq.s .lb8
         cmp #700,d4
         beq.s .lb8
         cmp #701,d4
         beq.s .lb8
         cmp #702,d4
         beq.s .lb8
         cmp #712,d4
         beq.s .lb8
         cmp #714,d4
         beq.s .lb8
         cmp #69,d4
         beq.s .lb8
         cmp #62,d4
         bne.s .lb9
.lb8:    move.l a2,-(a6) ; if, while, of et ses d‚riv‚s, and->, or->
         addq.l #2,a2
         bra .suite
.lb9:    cmp #71,d4
         beq.s .lb10
         cmp #63,d4
         bne.s .lb11
.lb10:   tst.l (a6)+       ; then ou repeat
         beq .suite        ; then suit un godo
         move.l a2,d4
         subq.l #2,d4
         sub.l -(a6),d4
         move.l (a6)+,a3
         move d4,(a3)
         bra .suite
.lb11:   cmp #70,d4
         beq.s .lb12
         cmp #67,d4
         bne.s .lb13
.lb12:   move.l a2,d4      ; else ou endof
         sub.l (a6),d4
         move.l (a6),a3
         move d4,(a3)
         move.l a2,(a6)
         addq.l #2,a2
         bra .suite
.lb13:   cmp #138,d4			; ."
         beq.s .lb14
         cmp #139,d4			; "
         bne.s .lb16
.lb14:   addq.l #2,a2   ; place pour la taille
			move.l a2,-(a6) ; … retenir
         tst.b (a0)  ; (") ou (.")
         beq .bug2
.lb15:   move.b (a0)+,d4
         beq .bug22			; fin de ligne, voir si elle se finit par \\
         cmp.l but,a2
         bpl .bug4			; buffer plein
         move.b d4,(a2)+
         cmp.b #34,d4
         bne.s .lb15
         clr.b -1(a2)   ; un z‚ro terminal au lieu du "
         move.l a2,d4
         and #1,d4
         add.w d4,a2
         move.l a2,d4
         move.l (a6)+,a3
         sub.l a3,d4      ; taille de la chaine
         move d4,-(a3)    ; qu'on place
         bra .suite
.lb16:   cmp #65,d4
         bne.s .lb17
.lab16:  clr.l -(a6)    ; case ou ->
         bra .suite
.lb17:   cmp #711,d4
         beq.s .lab16
         cmp #68,d4
         beq.s .lb18
         cmp #713,d4
         bne.s .lb20
.lb18:   tst.l (a6)+  ; ->. , endcase
         beq .suite
         move.l a2,d4
         subq.l #2,d4
         sub.l -(a6),d4
         move.l (a6)+,a3
         move d4,(a3)
         bra.s .lb18
.lb20:   cmp #368,d4      ; exe+
         bne.s .lb22
         move courant,d1
         ext.l d1
         clr -2(a2)
         move.l d1,(a2)+
         move d4,(a2)+
         bra .suite
.lb22:   bra .suite

; ici on cherche si un mot est un nombre
.findic: moveq #0,d5
         move.l base,basesav
         clr d6
         move d1,d4
         subq #1,d4
         move.l #mot,a4
         move.b (a4),d0
         cmp.b #"%",d0
         bne.s .f5
         addq.l #1,a4
         subq #2,d4
         move.b (a4)+,d0
         cmp.b #"f",d0
         bne.s .f0
         movem.l d2-d7/a0-a3,zone
         move.l a4,a0
         bsr subval
         tst erreur
         bne .bug0
         movem.l zone,d2-d7/a0-a3
         move #637,d4
         tst ass
         beq.s .f00
         jsr assemblons
         bra .suite
.f00:    move d4,(a2)+
         move.l d1,(a2)+
         move.l d0,(a2)+
         bra .suite
.f0:     cmp.b #"b",d0
         bne.s .f2
         moveq #2,d0
         bra.s .f1
.f2:     cmp.b #"d",d0
         bne.s .f3
         moveq #10,d0
         bra.s .f1
.f3:     cmp.b #"o",d0
         bne.s .f4
         moveq #8,d0
         bra.s .f1
.f4:     cmp.b #"h",d0
         bne .bug3
         moveq #16,d0
.f1:     move.l d0,base
.f5:     move.b (a4),d0
         cmp.b #"-",d0
         bne.s .lab3
         addq.l #1,a4
         subq #1,d4
         move #1,d6
.lab3:   if STE=1
	         move.l base,-(a6)
				move.l d5,-(a6)
				bsr mul
				move.l (a6)+,d5
			else
				muls.l base,d5
			endif
         moveq #0,d3
         move.b (a4)+,d3
         sub.l #"0",d3
         bmi.s .bug3
         cmp.l #10,d3
         bmi.s .lab4
         subq.l #7,d3
         cmp #36,d3
         bmi.s .lab4
         sub.l #32,d3
.lab4:   cmp.l base,d3
         bpl.s .bug3
         add.l d3,d5
         dbf d4,.lab3
         tst d6
         beq.s .lab5
         neg.l d5
.lab5:   tst ass						; ici empile une constante
         beq.s .lab23				; si c'est interpr‚t‚
         clr d4						; 0 pour constante
         jsr assemblons				; assembler le code
         bra.s .lab24
.lab23:  clr (a2)+					; sinon 0 pour empiler
         move.l d5,(a2)+			; valeur constante
.lab24:  move.l basesav,base
         bra .suite
.bug14:  lea cbug14(pc),a0
			bra.s .bug31
.bug13:	lea cbug13(pc),a0
			bra.s .bug
.bug0:   lea cbug0(pc),a0
         bra.s .bug
.bug1:   lea cbug1(pc),a0
         bra.s .bug
.bug2:   lea cbug2(pc),a0
         bra.s .bug
.bug4:   lea cbug4(pc),a0
         bra.s .bug31
.bug3:   lea cbug3(pc),a0
.bug31:  bsr write_str
         lea mot,a0
.bug:    bsr write_str
         move #1,erreur
.bugend: move.l basesav,base
         move.l somsave,a6
         clr.b (a6)
         move.l a6,sommet
         move forthsav,forth
         move.l topsave,topprg
         bsr cache_off
         rts
.bug22:					; dans ." et " voir si la chaine se poursuit … la ligne suivante
	move.b -(a2),d0
	cmp.b #'\',d0
	beq.s .found
	cmp.b #32,d0
	beq.s .bug22
	bra.s .bug2			; ni espace ni \, mauvaise fin de chaine
.found:
	cmp.b #'\',-(a2)
	bne.s .bug			; pas le signe \\

	tst.l inc_ptr		; en inclusion?
	beq.s .no_inc

	subq.l #1,a0		; retour sur le mot de taille
	bsr _load_line
	bne.s .bug2			; chaine incomplete, pas de ligne suivante...
	bra.s .ok2			; a0 est d‚j… positionnn‚ aprŠs tabulations

.no_inc:
	move ligne,d0
	cmp finb,d0			; fin du bloc??
	beq .bug2			; chaine incomplete, bloc fini

	addq #1,ligne

	tst.b (a0)+			; taille ligne
	beq .bug2			; chaine incomplete, fin de texte
	addq.l #1,a0		; saute les tabulations
.ok2:
	bra .lb15



flags: dcb.b 14,-1			; true de 0 … 13 (13 vrai car interpr‚teur)
	if STE=0
		dc.b -1					; flag 14 vrai si 68030
	else
		dc.b 0					; faux si 68000
	endif
	if LANG=0
		dc.b -1					; flag 15 vrai si fran‡ais
	else
		dc.b 0					; faux si anglais
	endif

	; cherche un mot dans le dictionnaire
	; … la fois lors de la compilation
	; mais aussi lors de la cr‚ation d'un nouveau mot
	; pour s'assurer qu'il n'y a pas de red‚finition

find_word:
			lea ordres,a3
         moveq #0,d2
.autre:  move.b (a3)+,d2
         beq .findic
         cmp.b d1,d2
         beq.s .voyons
.bennon: add.l d2,a3
         addq.l #1,d4
         bra.s .autre
.voyons: move.l #mot,a4
         move d2,d7
         subq #1,d7
         move.l a3,a5
.lab6:   cmp.b (a4)+,(a5)+
         dbne d7,.lab6
         bne.s .bennon
.findic:
			tst.b d2				; renvoie EQ si fin du dictionnaire
			rts					; NE si mot trouv‚

ifflag:
	move.l -(a2),d7
	swap d7						; +/- n dans le mot haut
	clr d7						; annule le bas
	move.l d7,(a2)+
	bsr mot_commande
	bne .bug1
	tst.l d7
	bmi.s .ok					; si le flag est VRAI, on ne fait rien, la compilation continue
.lb0:
	move.l #'endf',d0
	bsr une_ligne				; avancer jusqu'… >endf
	bne.s .lb0
	cmp #0,a1					; >comp trouv‚, ok
	beq.s .ok
	lea .ibug2(pc),a0
	cmp #1,a1					; pas de >comp
	beq.s .erreur
	lea .ibug3(pc),a0			; si a1=2, fin de bloc
	bra.s .erreur
.ok:
	moveq #1,d0					; NE ok
	rts
.bug1:
	lea .ibug1(pc),a0
.erreur:
	moveq #0,d0					; EQ erreur
	rts
	if STE=0
.ibug1: dc.b " Erreur >ifflag: mauvais mot de commande.",0
.ibug2: dc.b " Erreur >ifflag: >endf manquant!",0
.ibug3: dc.b " Erreur >ifflag: fin de bloc avant >endf !",0
	else
.ibug1: dc.b " Error >ifflag: bad command word!",0
.ibug2: dc.b " Error >ifflag: missing >endf !",0
.ibug3: dc.b " Error >ifflag: block end before >endf !",0
	endif
	even

; traite le mot de commande de la forme
; %h 000n dddd
; n=num‚ro de flag (0-15)
; dddd une donn‚e selon la commande
; si le mot est n‚gatif c'est pour valider si le flag est faux
; renvoie:
; NE si mauvais mot de commande
; EQ si ok et D7 = xxxx dddd
; xxxx = 0 si FAUX et FFFF si vrai
; dddd = valeur conserv‚e

mot_commande:
			move.l -(a2),d7	; mot de commande
			bpl.s .lb1			; si positif, normal
			neg.l d7				; sinon, on inversera l'‚tat du flag
.lb1:
			swap d7				; le num‚ro du flag
			and #$F,d7			; de 0 … 15
			move.l a2,-(sp)
			lea flags,a2
			move.b 0(a2,d7.w),d7	; true ou flase
			ext.w d7				; FFFF ou 0000
			move.l (sp)+,a2
			tst.b (a2)			; ‚tait n‚gatif ou non?
			bpl.s .lb2			; positif, flag normal
			not d7				; sinon, prendre le contraire
.lb2:
			swap d7
_is_constant:
			move.w -(a2),d0	; 0 en interpr‚t‚ et move.l #...,-(a6) en compil‚
			tst ass
			beq.s .lb0
			cmp.w #$2D3C,d0	; move.l #
			bra.s .ok
.lb0:		tst d0
.ok:		rts					; renvoit NE en cas de prob ou EQ si Ok

	; v‚rifie qu'il y a bien une constant juste avant
	; sinon aucune action

prg_flags:
			move.l -(a2),d0		; flags
			bsr.s _is_constant
			bne.s .oups
			move.l -(a2),d0		; % ‚cran
			bsr.s _is_constant
			bne.s .oups
			move.l -(a2),d0		; langue qu'on force
			move d0,langage
			bra.s _is_constant
.oups:	rts

inclure:
			bsr.s mot_commande
			bne .bug1
.ok:
			tst.b (a0)
			beq .bug2			; chaine mal form‚e
			cmp.b #34,(a0)+		; cherche le " de d‚part
			bne.s .ok
			move.l a0,a1		; d‚but du nom
.lb1:
			tst.b (a0)
			beq .bug2
			cmp.b #34,(a0)+		; cherche le " final
			bne.s .lb1

			tst.l d7					; le flag
			bpl .ignorer			; ignorer, le flag n'est pas … -1

			tst in_def
			bne.s .deja_dico

			move d7,d0
			and #$9,d0
			cmp #9,d0
			beq.s .deja_dico		; pas de changement si c'est l'inclusion d'un FOR

		 	move.l a2,topsav2
         move.l #but,a2
         move.l (a2)+,d0
         move.l (a2),-4(a2)
         move.l d0,(a2)
         move.l topprg,a2	; passe dans le dicco

.deja_dico:
			move.l a0,a4		; conserve la fin
			clr.b -(a4)			; vire le " momentan‚ment
			move.l a2,a3		; au cas o— GEMDOS le d‚truise!

			move.l a2,a0		; c'est topprg en cours si dans une def
			tst in_def
			bne.s .deja_dico2
			move.l topprg,a0	; zone libre pour le chemin+nom
.deja_dico2:
			sf (a0)				; chaine normale+0
			jsr expand_path	; ‚tend les % de (a1)  avec le chemin actuel

			clr -(sp)
			move.l a0,-(sp)
			GEMDOS 61,8			; fopen
			move.b #34,(a4)+
			move.l a4,a0		; en cas de bug33 revenir sur le z‚ro final = fin de ligne
			move d0,d4			; le handle!
			bmi .bug33

			btst #0,d7			; =0 programme PRG, =1 autre
			beq .prg

			move #2,-(sp)
			move d4,-(sp)
			clr.l -(sp)
			GEMDOS 66,10
			move.l d0,d5		; taille totale du fichier
			bmi .bug3			; erreur de lecture

			clr -(sp)
			move d4,-(sp)
			clr.l -(sp)
			GEMDOS 66,10		; revient au d‚but du fichier
			tst.l d0
			bmi .bug3

			btst #3,d7			; fichier FOR ? ou DEF (constantes RSC) ?
			beq .autre2

			move.l #256,-(sp)	; reserve un nouveau bloc
		   GEMDOS 72,6
		   move.l d0,a0		; nouvelle adresse
		   lea inc_ptr,a1
		   move.l (a1),(a0)+	; chaine
		   move.l d0,(a1)		; nouveau pointeur courant
		   move d4,(a0)+		; garde le handle

			pea (a0)
			moveq #8,d0
			move.l d0,-(sp)	; 8 octets du header
			move d4,-(sp)
			GEMDOS 63,12		; fread
			cmp #8,d0
			bne .bug3

			btst #4,d7			; bit … 0, c'est un simple fichier FOR
			beq.s .verif_for
			
			clr -(sp)			; ici c'est un DEF (constantes RSC)
			move d4,-(sp)
			clr.l -(sp)
			GEMDOS 66,10		; retour au d‚but du fichier !
			move.l inc_ptr,a0
			st 255(a0)			; dernier octet = FF (DEF)
			addq.l #6,a0		; nombre de constantes (ou de lignes)
			moveq #0,d0
			move (a0)+,d0
			lsl.l #4,d0			; *16 = taille du fichier
			move #$0010,4(a0)	; simule une fin de ligne avec 16 octets … suivre
			bra.s .verif_taille
			
.verif_for:
			move.l inc_ptr,a0
			sf 255(a0)			; dernier octet = 00 (FOR)
			addq.l #8,a0		; saute chainage + handle + nbr ligne
			move.l (a0),d0		; normalement taille fichier - 6
			addq.l #6,d0
.verif_taille:
			cmp.l d0,d5
			bne .bug4			; format non reconnu
			move.l a4,(a0)+	; sauvegarde compilptr
			tst.b (a0)			; normalement nul, c'est le d‚but d'une ligne !
			bne .bug4			; format non reconnu
			move.l a3,a2		; celui qui a ‚t‚ sauv‚
			bra .ignorer		; sortie avec Ok !

.autre2:
			lea 0(a3,d5.l),a2
			move.l a2,-(sp)
			move.l a2,-(sp)
			move.l a2,-(sp)	; pour rester compatible avec les autres cas
			bra.s .lire

.prg:
			move.l a3,-(sp)	; pour charger
			moveq #28,d0
			move.l d0,-(sp)	; 28 octets du header
			move d4,-(sp)
			GEMDOS 63,12		; fread
			cmp #28,d0
			bne .bug3

			cmp #$601a,(a3)	; header?
			bne .bug4
			move.l 2(a3),d5	; taille TEXT
			move.l a3,-(sp)	; sauve d‚but text
			pea 0(a3,d5.l)		; sauve d‚but data
			add.l 6(a3),d5		; taille text+data
			pea 0(a3,d5.l)		; sauve fin DATA
			add.l d5,d0			; text+data+header
			add.l 14(a3),d0	; plus symboles -> offset pour le relogement
			move.l d0,off_relog

.lire:
			lea 0(a3,d5.l),a2
			cmp.l but,a2
			bpl .bug7			; pas assez de m‚moire

			move.l a3,-(sp)
			move.l d5,-(sp)
			move d4,-(sp)
			GEMDOS 63,12		; fread

			cmp.l d5,d0
			beq .lb2
			lea 12(sp),sp		; vire les trois .L sauv‚s
			bra .bug3

.lb2:

			move.l (sp)+,d0	; fin data
			move.l (sp)+,a3	; d‚but data
			move.l (sp)+,a2	; d‚but TEXT

			btst #0,d7
			bne .raw			; chargement brut
			cmp.l #"ADD_",(a3)+
			bne .raw
			cmp.l #"DEFS",(a3)+
			bne .raw

			lea -8(a3),a0		; arret du relogement aux datas
			bsr reloge_ferme	; reloge ‚ventuellemnt et ferme le fichier
			move.l a4,a0		; restaure le pointeur de texte

			tst in_def
			bne .bug6			; def dans def!
.ok2:
			move.l a3,d0
			subq.l #8,d0		; d0 pointe sur d‚but DATA
			moveq #0,d1			; aucun mot par d‚faut
.lb3:
			move.l (a3)+,d2	; adresse
			bmi.s .lb4			; si <0, c'est la fin
			addq #1,d1			; un mot de plus
			add.l a2,d2			; offset TEXT
			lea adresse,a1
			move forth,d4
			lsl #2,d4
			move.l d2,0(a1,d4.w)	; range l'adresse
			addq #1,forth
			bra.s .lb3
.lb5:		move.l sommet,a2
			lea 1(a2),a1
.lb6:
			move.b (a3)+,(a1)+
			bne.s .lb6
			subq.l #1,a1
			move.l a1,sommet
			sub.l a2,a1
			subq #1,a1
			move a1,d2
			move.b d2,(a2)			; sa taille
.lb4:
			dbf d1,.lb5
			move.l d0,a2		; pointeur au d‚but des DATAS (ignor‚s donc!)
			bra.s .fin_ok
.raw:
			move.l d0,a0		; arret du relogement en fin de datas
			bsr reloge_ferme	; reloge ‚ventuellement et ferme le fichier
			move.l a4,a0		; restaure le pointeur de texte
			tst in_def
			beq .bug5
			move.l d0,a2		; pointeur en fin de DATAS
.fin_ok:
			btst #1,d7			; =1 ignorer parit‚ dicco, =0 assurer parit‚
			bne.s .pas_pair
			move.l a2,d0
			addq.l #1,d0
			bclr #0,d0
			move.l d0,a2		; rend a2 pair (avec ‚ventuellement +1)

.pas_pair:
			tst in_def
			bne.s .deja_dico_2

			move.l a2,topprg	; ressort du dicco
         move.l #but,a2
         move.l (a2)+,d0
         move.l (a2),-4(a2)
         move.l d0,(a2)
         move.l topsav2,a2

.deja_dico_2:
.ignorer:
			moveq #1,d0			; renvoit NE
			rts
.bug1:   lea cbug9(pc),a0
			bra.s .fin_bug
.bug2:   lea cbug10(pc),a0
			bra.s .fin_bug
.bug33:  cmp.b #$FF,edsav+1	; marqueur pour premier appel AUTOEXEC
			bne.s .bug3				; erreur normale
			clr.b edbuf				; pas de AUTOEXEC trouv‚ annuler ligne de commande
			sf edsav+1				; vire le marqueur
			bra.s .ignorer
.bug3:	lea cbug8(pc),a0
			bra.s .fin_bug
.bug4:   lea cbug7(pc),a0
			bra.s .fin_bug
.bug5:   lea cbug5(pc),a0
			bra.s .fin_bug
.bug6:	lea cbug6(pc),a0
			bra.s .fin_bug
.bug7:   move d4,-(sp)
			GEMDOS 62,4			; ferme le fichier
			lea cbug11(pc),a0
			bra.s .fin_bug

			nop
.fin_bug:
			sub d0,d0			; pour avoir EQ au retour
			rts

flag_cond:
	bsr mot_commande
	bne .bug1					; mot de commande absent
	and #$f,d7
	beq .bug1
	move.l a2,-(sp)
	lea flags,a2
	cmp #863,d4					; si=863, true sinon false
	seq 0(a2,d7.w)
	move.l (sp)+,a2
	moveq #1,d0
	rts
.bug1: lea cbug12(pc),a0
	moveq #0,d0
	rts

	if 0
debal:
	move.l (sp)+,.truc			; adresse retour
	move.l (sp)+,.truc+4		; paramŠtre
	move.l .truc(pc),-(sp)	; remet le retour
	movem.l d0-d2/a0-a2,-(sp)
	move.l .truc+4,d0
	lea .val(pc),a0
	moveq #7,d1
.lb0:
	move d0,d2
	and #$F,d2
	add #'0',d2
	cmp #'9'+1,d2
	bmi.s .lb1
	add #'A'-'9'-1,d2
.lb1:
	move.b d2,-(a0)
	lsr.l #4,d0
	dbf d1,.lb0
	lea .alerte(pc),a0
	jsr forth_alert	
	movem.l (sp)+,d0-d2/a0-a2
	rts
.truc: dc.l 0,0
.alerte: dc.b "[1][ Valeur : 00000000"
.val:	dc.b " ][ Ok ]",0
	even
	
	endif

off_relog: dc.l 0			; offset de la table de relogement

; attend a0:finde la zone … reloger
;			a2:d‚but de la zone et debut de text aussi
;			d0:fin zone data (donc l… ou on peut charger la table)

reloge_ferme:
	movem.l d0/a3,-(sp)
	btst #0,d7
	bne.s .fin			; pas un programme! juste fermer
	move.l d0,a3		; adresse ou charger
	btst #2,d7
	bne.s .fin			; bit mis, pas de relogement
	move.l a0,-(sp)	; sauve critŠre de fin
	clr -(sp)			; … partir du d‚but du fichier
	move d4,-(sp)		; handle
	move.l off_relog,-(sp)
	GEMDOS 66,10
	move.l a3,-(sp)	; adresse ou charger
	move.l #$7fffffff,-(sp) ; jusqu'au bout
	move d4,-(sp)
	GEMDOS 63,12
	move.l (sp)+,a0	; le critŠre de fin
	move.l a2,a1
	move.l a2,d1
	tst.l (a3)			; pr‚sence d'une table ou non?
	beq.s .fin			; non...
	add.l (a3)+,a1		; premiŠre location
	moveq #0,d0
.loop:
	cmp.l a0,a1			; critŠre de fin
	bpl.s .fin			; on d‚passe de la zone … reloger
	add.l d1,(a1)		; reloge
.lb1:
	move.b (a3)+,d0
	beq.s .fin			; un z‚ro? c'est fini
	cmp #1,d0
	beq.s .lb0			; 1? il faut avancer de 254...
	add.w d0,a1			; sinon, c'est un offset
	bra.s .loop
.lb0:
	add.w #254,a1
	bra.s .lb1
.fin:
	move d4,-(sp)		; ferme le fichier
	GEMDOS 62,4
	movem.l (sp)+,d0/a3
	rts

export_source:
	bsr mot_commande
	bne .bug1					; mot de commande absent
	swap d7						; 0 ou -1
.ok:
	tst.b (a0)
	beq .bug2			; chaine mal form‚e
	cmp.b #34,(a0)+		; cherche le " de d‚part
	bne.s .ok
	move.l a0,a1		; d‚but du nom
.lb1:
	tst.b (a0)
	beq .bug2
	cmp.b #34,(a0)+		; cherche le " final
	bne.s .lb1

	tst d7
	beq.s .lb0			; pas d'export, on simule!

	move.l a0,a4		; conserve la fin
	clr.b -(a4)			; vire le " momentan‚ment

	movem.l a0/a2,-(sp)
	move.l topprg,a0	; zone libre pour path complet
	sf (a0)				; chaine normale + 0
	jsr expand_path

	clr -(sp)
	move.l a0,-(sp)
	GEMDOS 60,8			; fcreate
	move.b #34,(a4)	; remet "
	movem.l (sp)+,a0/a2
	move d0,d6			; handle
	bmi .bug3			; cr‚ation impossible

.lb0:
	move.l #'comp',d0	; critŠre de fin
	bsr une_ligne
	beq .fin
	tst d7 				; simuler ou sauver?
	beq .lb0

	movem.l a0/a2,-(sp)
	move.l a1,-(sp)	; adresse d‚but ligne
	move.l d1,-(sp)	; taille ligne
	move d6,-(sp)
	GEMDOS 64,12		; fwrite
	movem.l (sp)+,a0/a2
	tst d0
	bmi .bug4			; erreur d'‚criture
	bra.s .lb0

.fin:
	tst d7
	beq.s .lb2			; on simule

	movem.l a0-a2,-(sp)
	move d6,-(sp)
	GEMDOS 62,4
	movem.l (sp)+,a0-a2

	cmp #1,a1			; a1=1 si >comp manque!
	beq .bug5			; >comp manquant
	cmp #2,a1			; a1=2 si fin de bloc
	beq .bug6

.lb2:
	moveq #1,d0			; pas d'erreur!
	rts
.bug1: lea .ex_bug1(pc),a0
	bra.s .fin_bug
.bug2: lea .ex_bug2(pc),a0
	bra.s .fin_bug
.bug3: lea .ex_bug3(pc),a0
	bra.s .fin_bug
.bug4: lea .ex_bug4(pc),a0
	bra.s .fin_bug
.bug5: lea .ex_bug5(pc),a0
	bra.s .fin_bug
.bug6: lea .ex_bug6(pc),a0
.fin_bug:
	sub d0,d0
	rts

	if LANG=0
.ex_bug1: dc.b " Erreur >export: mauvais mot de commande!",0
.ex_bug2: dc.b " Erreur >export: chaine incomplŠte!",0
.ex_bug3: dc.b " Erreur >export: cr‚ation du fichier impossible!",0
.ex_bug4: dc.b " Erreur >export: ‚criture sur fichier impossible!",0
.ex_bug5: dc.b " Erreur >export: >comp manquant!",0
.ex_bug6: dc.b " Erreur >export: fin de bloc avant >comp!",0
	else
.ex_bug1: dc.b " Error >export: bad command word!",0
.ex_bug2: dc.b " Error >export: uncomplete string!",0
.ex_bug3: dc.b " Error >export: can't create file!",0
.ex_bug4: dc.b " Error >export: can't write to file!",0
.ex_bug5: dc.b " Error >export: missing >comp !",0
.ex_bug6: dc.b " Error >export: block end before >comp!",0
	endif
	even

une_ligne:
	move.l d0,.end_criter	; 'comp' ou 'endf'
.lb00:
	tst.b (a0)+
	bne.s .lb00				; avancer jusqu'… la ligne suivante
	tst.l inc_ptr			; sommes nous en inclusion?
	beq.s .no_inc
	subq.l #1,a0			; retour sur le mot de taille
	move (a0),d1			; taille ligne
	bsr _load_line
	bne.s .erreur			; fichier ferm‚ sans avoir trouv‚ le critŠre de fin
	subq.l #1,a0			; retour sur la tabulation
	bra.s .commun
.no_inc:
	move ligne,d0
	cmp finb,d0
	beq.s .bug_bloc
	addq #1,ligne
	subq.l #1,a0
	move.w (a0)+,d1		; taille ligne
	beq .erreur				; fin de source sans >comp!
.commun:
	moveq #0,d0
	move.b (a0)+,d0		; tabulation+1
	lea commande_buf,a1			; pour construire la ligne
	subq #1,d0
	bra.s .lb1
.lb0:
	move.b #' ',(a1)+
.lb1:
	dbf d0,.lb0				; les espaces au d‚but
	cmp.b #'>',(a0)
	bne.s .normal
	move.l .end_criter(pc),d0	; comp ou endf
	cmp.l 1(a0),d0
	beq.s .fin
.normal:
	subq #4,d1				; moins taille et tab
.copie:
	move.b (a0)+,(a1)+
	dbf d1,.copie
	cmp.b #32,-1(a1)
	bne.s .lb2
	subq.l #1,a1
.lb2:
	move.b #13,(a1)+
	move.b #10,(a1)+
	move.l a1,d1
	lea commande_buf,a1			; d‚but ligne
	sub.l a1,d1				; taille ligne
	moveq #1,d0				; renvoit NE, ok!
	rts
.fin:
	move #0,a1				; pas d'erreur, mais un >comp!, a0 reste sur >comp.
	bra.s .sortie
.bug_bloc:
	move #2,a1
	bra.s .sortie
.erreur:
	move #1,a1				; grosse erreur
.sortie:
	moveq #0,d0				; renvoit EQ
	rts
.end_criter:
	dc.l 0

exec_prog:
	bsr mot_commande
	bne .bug1				; pas de mot de commande
	lea commande_buf,a1			; les chaines
.ok:
	tst.b (a0)
	beq .bug2			; chaine mal form‚e
	cmp.b #34,(a0)+		; cherche le " de d‚part
	bne.s .ok
.lb1:
	move.b (a0)+,d0
	beq .bug2				; mal ternim‚e!
	cmp.b #34,d0		; cherche le " final
	beq.s .lb3
	move.b d0,(a1)+
	bra.s .lb1
.lb3:
	clr.b (a1)+

.lb4:
	tst.b (a0)+
	bne.s .lb4			; fin de cette ligne

	tst.l inc_ptr		; en inclusion?
	beq.s .no_inc

	subq.l #1,a0		; retour sur le mot de taille
	bsr _load_line
	bne .bug3			; chaine paramŠtres absente dans ce fichier
	bra.s .ok2			; a0 est d‚j… positionnn‚ aprŠs tabulations

.no_inc:
	move ligne,d0
	cmp finb,d0			; fin du bloc??
	beq .bug7

	addq #1,ligne

	tst.b (a0)+			; taille ligne
	beq .bug3			; chaine absente
	addq.l #1,a0		; saute les tabulations

.ok2:
	tst.b (a0)
	beq .bug2			; chaine mal form‚e
	cmp.b #34,(a0)+		; cherche le " de d‚part
	bne.s .ok2
	move.l a0,d1		; emplacement initial
.lb12:
	move.b (a0)+,d0
	beq .bug2				; mal ternim‚e!
	cmp.b #34,d0		; cherche le " final
	bne.s .lb12
	lea -1(a0),a4		; garde le "
	clr.b (a4)

	move.l a1,a0		; l… ou ‚tendre la chaine
	st (a0)				; chaine avec taille initiale
	move.l d1,a1		; chaine … ‚tendre
	jsr expand_path
	move.b #34,(a4)+	; remet la chaine
	exg.l a0,a4			; a0 redevient le pointeur de compilation
							; a4 adresse de la chaine ‚tendue

	tst.l d7
	bpl .lb5				; si non n‚gatif, flag invalid‚ on saute!

	movem.l a0/a2,-(sp)

	btst #3,d7
	bne.s .lb9			; ignorer fenˆtre

	tst w_hand
	bmi.s .lb9			; d‚j… ferm‚e

	move.l a1,-(sp)
	lea wg_int,a0
	move.l (a0),d4
	move w_hand,(a0)+
	move #5,(a0)		; espace total
	GEM_AES wind_get0	; taille dans wg_out
	GEM_AES wind_close
	move.l (sp)+,a1
.lb9:
	pea -2(a1)			; environnement nul
	pea (a4)				; commande
	pea commande_buf	; programme
	clr -(sp)			; mode load and go
	GEMDOS 75,16
	movem.l (sp)+,a0/a2
	move.l d0,d6		; valeur renvoy‚e
	bpl.s .pas_bell
	move.l #$20007,-(sp)
	move #3,-(sp)
	trap #13
	addq.l #6,sp		; son de cloche, erreur PEXEC!
.pas_bell:
	moveq #0,d5			; pas d'arrˆt
	btst #0,d7
	bne.s .lb6			; pas de touche
	movem.l a0/a2,-(sp)
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
	cmp.b #27,d0
	seq d5				; d5=FF si touche escape
	movem.l (sp)+,a0/a2
.lb6:

	btst #3,d7
	bne.s .lb7			; ignorer fenˆtre

	tst w_hand
	bmi.s .lb7			; n'‚tait pas ouverte avant...

	movem.l a0/a2,-(sp)
	move w_hand,wg_out
	move.l d4,wg_int
	GEM_AES wind_open
	jsr cls
	movem.l (sp)+,a0/a2

.lb7:
	tst.l d6
	bmi .bug4			; erreur GEMDOS au chargement

	btst #1,d7
	bne.s .lb8			; pas v‚rifier si renvoi < 0
	tst d6
	bmi .bug5			; valeur renvoy‚e n‚gative!
.lb8:
	btst #2,d7
	bne.s .lb5
	tst d6
	beq.s .lb15
	bpl.s .bug5
.lb15:
	tst.b d5
	bne .bug6			; arrˆt utilisateur!

.lb5:
	moveq #1,d0
	rts					; tout est ok!
.bug1: lea .ex_bug1(pc),a0
	bra.s .fin_bug
.bug2: lea .ex_bug2(pc),a0
	bra.s .fin_bug
.bug3: lea .ex_bug3(pc),a0
	bra.s .fin_bug
.bug4: lea .ex_bug4(pc),a0
	bra.s .fin_bug
.bug5:
	move.l pilptr,a6
	ext.l d6					; d‚poser code d'erreur sur la pile!
	move.l d6,-(a6)
	move.l a6,pilptr
	lea .ex_bug5(pc),a0
	bra.s .fin_bug
.bug6:
	lea .ex_bug6(pc),a0
	bra.s .fin_bug
.bug7:
	lea .ex_bug7(pc),a0
.fin_bug:
	moveq #0,d0
	rts
	if LANG=0
.ex_bug1: dc.b " Erreur >exec: mauvais mot de commande!",0
.ex_bug2: dc.b " Erreur >exec: chaine incomplŠte!",0
.ex_bug3: dc.b " Erreur >exec: chaine commande absente!",0
.ex_bug4: dc.b " Erreur >exec: impossible de lancer le programme!",0
.ex_bug5: dc.b " Erreur >exec: le programme lanc‚ signale une erreur!",0
.ex_bug6: dc.b " Message >exec: compilation interrompue.",0
.ex_bug7: dc.b " Erreur >exec: fin de bloc en milieu de commande!",0
	else
.ex_bug1: dc.b " Error >exec: bad command word!",0
.ex_bug2: dc.b " Error >exec: uncomplete string!",0
.ex_bug3: dc.b " Error >exec: missing command string!",0
.ex_bug4: dc.b " Error >exec: can't run program!",0
.ex_bug5: dc.b " Error >exec: the child process returns an error!",0
.ex_bug6: dc.b " Message >exec: compilation was stopped.",0
.ex_bug7: dc.b " Error >exec: unexpected end of block!",0
	endif
	even

; ah, les jolies routines
; chacune pr‚c‚d‚e de 2 octets
;          code d'assemblage :
; 0 non
; 2 recopie du code : deux octets encore en amont indiquent la taille
;                     en mots moins 1
; 3 saut ( jsr vers cette routine )
; autres, assemblages particuliers

   NON
fff: bsr ttt
   move #580,(a2)+
   move forth,(a2)+
   move.l sommet,(a2)+
   addq.l #4,a2
   move.l a2,-4(a2)
   move.l a2,(a0)
   rts

 include "commun.s"

   NON
trace: move.l (a6)+,d1
   move d1,trcmot
   move #-1,trc
   move.l #tracexe,(sp)
   rts

   NON
untrc: clr trc
	tst isfast
	bne.s .lb0
	move.l #slowexe,(sp)
   rts
.lb0:
	move.l #fastexe,(sp)
	rts

   COPIE selplus,y300
selplus: move #-1,selmode
y300: rts

   COPIE selmoins,y301
selmoins: clr selmode
y301: rts

   SAUT
loadb: tst selmode
   bne.s .lb0
   move.l (a6)+,a0
   bra lll7
.lb0:
	move.l #chemin,addrin
   move.l #fichier,addrin+4
	bsr selecteur
	beq finl
lll7: move #0,-(sp)
   move.l a0,-(sp)
   GEMDOS $3d,8
   tst.l d0
   bpl.s .lb2
   ACONTROL 53,1,1,0
   move #2,intin	; file not found
   AES
   bra.s finl
.lb2: move d0,fhdl
.boucle: move.l #ldbuf,-(sp)
   move.l #6,-(sp)
   move fhdl,-(sp)
   GEMDOS 63,12
   cmp #6,d0
   bne.s .fin
   move ldbuf,d6
   move.l ldbuf+2,d7
   move.l bfptr,-(sp)
   move.l d7,-(sp)
   move fhdl,-(sp)
   GEMDOS 63,12
   cmp.l d0,d7
   bne.s .fin
   add d6,topedit
   add.l d7,bfptr
   bra.s .boucle
.fin: move.l bfptr,a0
   clr (a0)
   move fhdl,-(sp)
   GEMDOS 62,4
finl: rts

selmode: dc.w -1
beuf:    dc.l 0

   SAUT
append: moveq #-1,d6
   bra.s ssav

   SAUT
saveb: moveq #0,d6
ssav: tst topedit
   bne.s .lb0
.fin: rts
.lb0: tst selmode
   bne.s .aes
   move.l (a6)+,d7
   bra .suite
.aes:
	move.l #chemin,addrin
   move.l #fichier,addrin+4
	bsr selecteur
	beq .fin
	move.l a0,d7
.suite:
	tst debutb			; un bloc marqu‚?
	bmi.s .suite2		; non !
	btst #1,alert_mask+1	; alerte demand‚e?
	beq.s .suite2		; non !
	lea saveb2(pc),a0
	bsr forth_alert			; on avertit!
	beq .fin				; annuler
	cmp #2,d0			; sauver bloc?
	beq.s .suite2		; oui, ne rien changer
	move.l #-1,debutb	; sinon, effacer marquage bloc pour sauver tout
.suite2:
   move #1,-(sp)
   move.l d7,-(sp)
   GEMDOS $3d,8		; d'abord on ouvre pour voir si il existe
   move d0,fhdl
   bmi.s .creer		; si le fichier n'existe pas, on cr‚e (append ou saveb)
   tst d6
   bmi.s .lb1			; si il existe et mode append=-1, continuer, c'est normal
   move d0,-(sp)		; en mode saveb=0, on referme le fichier
   GEMDOS $3e,4
   btst #0,alert_mask+1		; alerte demand‚e si effacement?
   beq.s .creer				; non, donc on efface sans demander
   lea saveb1(pc),a0
   bsr forth_alert
   beq .fin						; annuler
.creer: move #0,-(sp)
   move.l d7,-(sp)
   GEMDOS $3c,8
   move d0,fhdl
   bmi .fin
.lb1: clr d1
   move.l beuf(pc),a3
   move debutb,d0
   bmi.s .lb4
   cmp topedit,d0
   bpl .fin
   bra.s .lb3
.lb2: add.w (a3),a3
.lb3: dbf d0,.lb2
.lb4: move.l a3,a2
   move finb,d0
.lb5: move (a2),d2
   beq.s .lb6
   addq #1,d1
   add.w d2,a2
   dbf d0,.lb5
.lb6: move.l #ldbuf,a0
   move.l a0,-(sp)
   move.l #6,-(sp)
   move d1,(a0)+
   sub.l a3,a2
   move.l a2,(a0)
   move fhdl,-(sp)
   move #2,-(sp)
   move fhdl,-(sp)
   clr.l -(sp)
   GEMDOS $42,10
   GEMDOS $40,12
   move.l a3,-(sp)
   move.l a2,-(sp)
   move fhdl,-(sp)
   GEMDOS $40,12
   move fhdl,-(sp)
   GEMDOS $3e,4
   tst debutb			; si un bloc est marqu‚, rien changer
   bpl.s .exit
   sf change_flag		; sinon, reset le flag de modification
.exit:
   rts
forth_alert:
	move.l a0,addrin
_forth_alert:			; ici si addrin d‚j… charg‚
	GEM_VDI show_mouse
   ACONTROL 52,1,1,1
   move #1,intin		; premier bouton d‚faut (annuler)
   AES
   move intout,-(sp)
   GEM_VDI hide_mouse
   jsr souris_visible
   move (sp)+,d0
   cmp #1,d0			; renvoie EQ si annuler, NE si poursuivre
   rts

	if LANG=0
saveb1: dc.b "[1][ Le fichier existe ! | Doit-on l'‚craser? ][ Annuler | Ecraser ]",0
saveb2: dc.b "[1][ Un bloc est marqu‚, | que doit-on sauver ? ][ Annuler | Bloc | Tout ]",0
saveb3: dc.b "[1][ Le texte ‚dit‚ | a ‚t‚ modifi‚. | Vraiment quitter? ][ Oui | Non ]",0
	else
saveb1: dc.b "[1][ The file exists ! | Should I ... ][ Cancel | Overwrite ]",0
saveb2: dc.b "[1][ A block is marked, | what should I save ? ][ Cancel | Block | All ]",0
saveb3: dc.b "[1][ The edited text | has been modified. | Really quit ? ][ Yes | Non ]",0
	endif
	even

; ouvre le selecteur, renvoit EQ si Annuler
; renvoit NE et a0=source=adresse du chemin complet

selecteur:
   GEM_VDI show_mouse
   ACONTROL 90,0,2,2
   AES
   move intout+2,-(sp)
   GEM_VDI hide_mouse
   GOSUB cls
	jsr souris_visible
   tst (sp)+
   bne.s .lb3
   moveq #0,d0				; renvoit EQ
   rts
.lb3: move.l #source,a0
   move.l addrin,a1
.lb4: move.b (a1)+,(a0)+
   bne.s .lb4
   moveq #'\',d0
.lb1: cmp.b -(a0),d0
   bne.s .lb1
   addq.l #1,a0
   move.l addrin+4,a1
.lb11: move.b (a1)+,(a0)+
   bne.s .lb11
   move.l #source,a0
   moveq #1,d0				; renvoit NE
   rts



   NON
forget: move (a5)+,d1
   lea ordres,a0
   move d1,forth
   cmp dicco,d1
   bpl.s .lb1
   move d1,dicco
.lb1: lea adresse(pc),a1
   move d1,d2
   subq #1,d1
   ext.l d2
   lsl.l #2,d2
   move.l  0(a1,d2),d2
   move.l d2,topprg
   cmp.l program,d2
   bpl.s .lb2
   move.l program,topprg
.lb2: move.b (a0)+,d2
   ext.w d2
   add.w d2,a0
   dbf d1,.lb2
   clr.b (a0)
   move.l a0,sommet
   rts

   SAUT
vlist: move.l topprg,a1
   move dicco,d1
   lea ordres,a0
   subq #1,d1
.lb1: move.b (a0)+,d2
   ext.w d2
   add.w d2,a0
   dbf d1,.lb1
.lb2: move.b (a0)+,d1
   beq.s .lb4
   ext.w d1
   subq #1,d1
.lb3: move.b (a0)+,(a1)+
   dbf d1,.lb3
   move.b #32,(a1)+
   bra.s .lb2
.lb4: clr.b (a1)
   move.l topprg,a0
   GOSUB write_str
   rts

   ASS 18
quit: move.l a6,pilptr
   move.l a4,retptr
   addq.l #4,sp
   rts

   NON
qt1: move.l a6,pilptr
   move.l a4,retptr
   addq.l #4,sp
   rts

polyline: dc.l pl_cont,dum,pl_pts,dum,dum
pl_cont: dc.w 6,2,0,0,0,0,0,0,0,0,0,0
pl_pts: dc.w 0,0,0,0

   SAUT
edit:
	lea in_data,a1
	move topedit,(a1)+	; sauvegarde pour v‚rifier si le fichier a chang‚
	move.l bfptr,(a1)		; ainsi qu'adresse de fin
	move.l #$AAAAAAAA,slider		; valeur impossible pour forcer redessin
   move.l #edit_list,end_keys
   movem.l a4-a6,regist+52
        ; cr‚ation des diff‚rentes fenetres ( titres, s‚parations )
   move.l #fenetre0,-(a6) ; l'‚cran de base
   bsr setp             ; un bout de clipping, histoire de...
   GOSUB cls            ; vide l'‚cran
   lea fenetre0,a0
   lea edit_haut,a1   ; X Y     L h     0 0 l h
   lea edit_bas,a2    ; X Y+h+2 L H-h-2 0 ? l h
   lea pl_pts,a3      ; X Y+h+1 X+L-1 Y+h+1
   move 14(a0),d0     ; h
   move.l (a0),(a3)+
   move.l (a0),(a1)+
   move.l (a0)+,(a2)+
   add d0,-2(a2)
   addq #2,-2(a2)
   add d0,-2(a3)
   addq #1,-2(a3)
   move.l -4(a3),(a3)
   move (a0)+,d1
   add d1,(a3)
   subq #1,(a3)
   move d1,(a1)+
   move d0,(a1)+
   move d1,(a2)+
   move (a0)+,(a2)
   sub d0,(a2)
   subq #2,(a2)+
   clr.l (a1)+
   clr.l (a2)+
   addq.l #4,a0
   move.l (a0),(a1)
   move.l (a0),(a2)
   move.l #w_edit,wst_in+4
   GEM_AES wind_set_title  ; le titre de l'‚diteur
   GEM_VDI polyline

         ; calcul des lignes et colonnes disponibles

   lea edit_bas,a0
   moveq #0,d0
   move 6(a0),d0      ; hauteur d'‚dition
   divs 14(a0),d0     ; nombre de lignes utiles
   subq #1,d0
   move d0,lignes     ; lignes utiles-1
   asr #1,d0
   move d0,demi_ecran
   moveq #0,d0
   move 4(a0),d0      ; largeur totale
   divs 12(a0),d0     ; nombre de colonnes
   move d0,colonnes

       ; la ligne … ‚diter

   move editb,d5 ; ligne ‚dit‚e
   move #-1,ksize ; taille maxi

.lb1reset:
   moveq #0,d7
   moveq #0,d4  ; et sur la premiŠre colonne

       ; efface tout l'‚cran, calcule la ligne du haut
       ; et v‚rifie celle ‚dit‚e
.lb1:
   move.l #edit_bas,fenetre
   GOSUB cls
   move.l beuf(pc),a6
   cmp topedit,d5
   bmi.s .lb2
   move topedit,d5  ; nø ligne trop grand
.lb2: move d5,d0
   bpl.s .lb3
   clr d5           ; nø ligne trop petit
   clr d0
.lb3: sub demi_ecran,d0
   bpl.s .lb4
   clr d0
.lb4: move d0,d6    ; ligne du haut
   bra.s .lb6
.lb5: add (a6),a6
.lb6: dbf d0,.lb5   ; a6:adr de la ligne du haut
   move.l a6,a5
   move d5,d0
   sub d6,d0
   bra.s .lb8
.lb7: add (a5),a5
.lb8: dbf d0,.lb7   ; a5:adr de la ligne ‚dit‚e

       ; affichage des lignes ( ‚cran entier )

   move lignes,d2     ; indice pour les lignes
   movem.l d4-d7,regist
.loop:
   tst (a6)+
   beq.s .lb13      ; si derniŠre ligne
   cmp lignes,d2    ; sur la premiŠre ligne, pas de saut
   beq.s .truc
   GOSUB cr
.truc:
   move.l edb(pc),a0
   move.b (a6)+,d0
   ext.w d0
   subq #1,d0       ; tabulation
   moveq #32,d1
   bra.s .lb10
.lb9: move.b d1,(a0)+  ; copie autant de blancs que voulu
.lb10: dbf d0,.lb9
.lb11: move.b (a6)+,(a0)+
   bne.s .lb11      ; transfert du reste
   subq.l #1,a6     ; revient sur le z‚ro
   subq.l #1,a0
   cmp.b -1(a0),d1  ; au cas ou ce soit un espace en dernier caractŠre
   bne.s .lb12
   subq.l #1,a0     ; alors on recule
.lb12: clr.b (a0)   ; fin de chaine virtuelle
   move.l edb(pc),a0    ; reprend le d‚but
   move colonnes,d0
   clr.b (a0,d0.w)     ; fin de chaine physique ( si ‚cran trop petit )
   move d2,a3
	if STE=1
		jsr write_str
	else
	   bsr.l write_str
	endif
   move a3,d2
   dbf d2,.loop
.lb13:
   movem.l regist,d4-d7
.bc1:
   bsr lgnaff        ; num‚ro de la ligne
   bsr update_slider	; vertical slider selon le bloc
   if STE=0
	   lea ([edb,pc],8),a0 ; buffer plus 8
	else
		move.l edb(pc),a0
		addq.l #8,a0
	endif
   move.l a0,a2
   moveq #4,d0
   move.l #$20202020,d1
.lb14: move.l d1,(a0)+
   move.l d1,(a0)+
   move.l d1,(a0)+
   move.l d1,(a0)+
   dbf d0,.lb14      ; pr‚pare 80 blancs pour la ligne
   clr.b (a0)

   move d5,d3        ; calcule les coordonn‚es du curseur
   sub d6,d3         ; nøde ligne … l'‚cran
   lea edit_bas,a1
   muls 14(a1),d3    ; fois h, coordonn‚e du curseur en points
   move.l d3,8(a1)   ; avec 0 pour x dans le mot sup‚rieur
   move.l a1,fenetre

   move.l a5,a1
   tst (a1)+
   beq.s .bc3        ; ligne vide, pas de transfert
   move.b (a1)+,d0
   ext.w d0
   subq #1,d0
   add.w d0,a2       ; on saute la tabulation
.lb15: move.b (a1)+,(a2)+
   bne.s .lb15       ; on tranfert la ligne
   move.b d1,-(a2)
.bc3:
   if STE=0
   	lea ([edb,pc],8),a0
   else
   	move.l edb(pc),a0
   	addq.l #8,a0
   endif
   movem.l d5-d6,regist
   moveq #-80,d6     ; nombre maxi de caractŠres … lire ( d4/d7 colonne )
   jsr edition
   movem.l regist,d5-d6

   bsr propre    ; traite les cas de RETURN ( nouvelle ligne )
                 ; BACKSPACE ( collage de deux lignes )
                 ; Control DEL ( vire une ligne )
                 ; et UNDO = Shift F2 ( ne fait rien )
                 ; renvoit un code
                 ; >0 si on doit traiter une touche encore
                 ; 0 si l'‚cran est correct ( .bc1 )
                 ; -1 si il faut redessiner ( .lb1 )
   tst d0
   beq .bc1
   bmi .lb1
   cmp #$5400,d0	; Shift F1 simule Help
   beq.s .tta1
   cmp #$6200,d0	; HELP afficher aide
   bne.s .tta
.tta1:
   bsr help_display
   move #2,-(sp)
   BIOS 2,4			; attendre touche
   bra .lb1			; tout reconstruire
.tta:
   cmp #$3b00,d0 ; F1 : top of file
   bne.s .tt0
   clr d5
   bra .lb1
.tt0:
   cmp #$3c00,d0 ; F2 : screen up
   bne.s .tt01
.f2:
   move demi_ecran,d0
   asr #1,d0
   sub d0,d6
   move d6,d5
   bra .lb1
.tt01:
   cmp #$3d00,d0 ; F3 : bloc start
   bne.s .tt02
   move d5,debutb
;   move #-1,finb
	move topedit,d0
	sub d5,d0
	move d0,finb
;
   bra .bc1
.tt02:
	cmp #$5600,d0		; shift F3 aller au d‚but du bloc
	bne.s .tt02a
	move debutb,d0
	bmi .bc1			; pas de bloc, rien … faire
	move d0,d5
	bra .lb1
.tt02a:
   cmp #$3e00,d0 ; F4 : bloc end
   bne.s .tt03
   move debutb,d0
   bmi .bc1			; pas de bloc marqu‚, on saute
   sub d5,d0
   bmi.s .tt02b	; fin aprŠs d‚but, ok on garde
   move d5,debutb	; sinon, d5 devient d‚but !
   bra.s .tt02c
.tt02b:
   neg d0
.tt02c:
   move d0,finb
   bra .bc1
.tt03:
	cmp #$5700,d0	; Shift F4: aller … la fin du bloc
	bne.s .tt03a
	move debutb,d0
	bmi .bc1			; pas de bloc...
	move finb,d5
	bmi .tt2a		; si n‚gatif, bloc jusqu'… la fin, prendre topedit
	add d0,d5		; sinon calcule fin de bloc
	bra .lb1	
.tt03a:
   cmp #$3f00,d0 ; F5 : bloc hide
   bne.s .tt1
   move.l #-1,debutb
   bra .bc1
.tt1:
   cmp #$4000,d0  ; F6
   bne.s .ttt1
   bsr aller
   bra .lb1
.ttt1:
   cmp #$4100,d0 ; F7 : find
   bne.s .ttt2
   bsr chercher
   bra .lb1
.ttt2:
   cmp #$4200,d0 ; F8 : find next
   bne.s .ttt3
   bsr chsuiv
   bra .lb1
.ttt3:
   cmp #$5800,d0 ; Shift F5 : bloc delete
   bne.s .ttt4
   bsr bloc
   beq .bc1
   bsr effbloc
   bra .lb1reset
.ttt4:
   cmp #$5900,d0 ; Shift F6 : bloc move
   bne.s .ttt5
   bsr bloc
   beq .bc1
   tst d0
   beq .bc1
   bsr mvbloc
   bra .lb1reset
.ttt5:
   cmp #$5a00,d0 ; Shift f7 : bloc copy
   bne.s .ttt6
   bsr bloc
   beq .bc1
   tst d0
   beq .bc1
   bsr cpbloc
   bra .lb1reset
.ttt6:
   cmp #$4300,d0 ; F9 : screen down
   bne.s .tt2
.f9:
   move lignes,d0
   add d0,d6
   asr #2,d0
   add d0,d6
   move d6,d5
   bra .lb1
.tt2:
   cmp #$4400,d0 ; F10 : end of file
   bne.s .tt3
.tt2a:
   move topedit,d5
   bra .lb1
.tt3:
   cmp #$011b,d0 ; ESC
   beq .fin

   cmp #$4838,d0       ; shift UP
   beq .f2

   cmp #$4800,d0       ; up
   bne.s .tt9
   tst d5
   beq .bc1            ; d‚j… au d‚but
   cmp d5,d6
   bne.s .lb24
   moveq #3,d0         ; ins‚rer en haut
   bsr copy_up
   subq #1,d6
.lb24: tst.b -(a5)     ; recule d'une ligne jusqu'au z‚ro de l'autre
   bne.s .lb24
   subq #1,d5
   bra .bc1
.tt9: cmp #$5032,d0    ; shift DOWN
   beq .f9

   cmp #$5000,d0       ; DOWN
   bne .lb1            ; autre touche ? bizarre...
   cmp topedit,d5
   beq .bc1            ; d‚j… au bout !
   move lignes,d0
   add d6,d0           ; num‚ro de la ligne du bas
   cmp d5,d0
   bne.s .lb25          ; pas en bas encore, on peut descendre
   bsr copy_down
   addq #1,d6
.lb25: addq #1,d5
   add.w (a5),a5
   bra .bc1
.fin:
   move d5,editb
   lea in_data,a0
   move (a0)+,d0
   cmp topedit,d0			; topedit a chang‚?
   sne change_flag
   bne.s .fin1				; un changement, pas besoin de v‚rifier l'adresse
   move.l (a0),d0
	cmp.l bfptr,d0			; mˆme adresse de fin?
	sne change_flag		; change_flag = FF si buffer modifi‚ !   
.fin1:
   moveq #1,d4
   moveq #1,d5
   moveq #-1,d6	; pour juste reset slider
   bsr update_slider
   move.l #w_titre,wst_in+4
   GEM_AES wind_set_title  ; le titre normal
   move.l #fenetre0,fenetre
   GOSUB cls
   lea bloc0,a0
   tst debutb
   bmi.s .fin2
   lea bloc1,a0
.fin2:
	if STE=1
		jsr write_str
	else
	   bsr.l write_str
	endif
   movem.l regist+52,a4-a6
   rts

copy_up:
   moveq #0,d0    ; ligne 0 au d‚part
   moveq #1,d1    ; +1 vers le bas
   move lignes,d3 ; lignes-1 … d‚caler
   bsr _deplace
   rts

copy_down:
   moveq #1,d0    ; premiŠre ligne
   moveq #-1,d1   ; -1 vers le haut
   move lignes,d3
   bsr _deplace
   rts

copy_del:
   move d5,d0
   sub d6,d0
   move lignes,d3
   sub d0,d3      ; nombre de lignes
   addq #1,d0     ; source sous d5
   moveq #-1,d1   ; vers le haut
   bsr _deplace
   move lignes,d0 ; afficher la derniŠre ligne
   bsr _ecrire
   rts


copy_ret:
   move d5,d0
   sub d6,d0
   move lignes,d3
   sub d0,d3
   bgt.s .lb0     ; ok, pas sur la derniŠre ligne
   moveq #-1,d0   ; sinon, redessiner entiŠrement l'‚cran
   rts
.lb0:
   moveq #1,d1
   bsr _deplace
   move d5,d0
   sub d6,d0      ; transforme en offset pour la routine _ecrire
   subq #1,d0     ; afficher ligne pr‚c‚dente ( qui a ‚t‚ coup‚e )
   bsr _ecrire
   moveq #0,d0    ; pas d'‚cran … redessiner.
   rts

copy_back:
   move d5,d0
   sub d6,d0
   move lignes,d3
   sub d0,d3
   addq #2,d0
   subq #1,d3
   moveq #-1,d1
   bsr _deplace
   move lignes,d0
   bsr _ecrire
   rts

; d0 ligne de d‚part dans edit_bas
; d1 offset en lignes ( + ou -1 en g‚n‚ral )
; d3 nombre de lignes

_deplace:
   tst d3
   bgt.s .ok
   rts
.ok:
   move #3,copy_int
   lea edit_bas,a0
   lea copy_pts,a1
   muls 14(a0),d0
   muls 14(a0),d1
   muls 14(a0),d3    ; convertit les lignes en points
   add.l (a0)+,d0    ; X:Y+D0
   move.l d0,(a1)+
   swap d3
   move (a0),d3      ; L
   swap d3           ; L et h
   add.l d0,d3       ; X+L:Y+D0+D3
   sub.l #$10001,d3  ; ajuste
   move.l d3,(a1)+   ; coin inf‚rieur droit
   add.l d1,d0
   move.l d0,(a1)+   ; rectangle dest
   add.l d1,d3
   move.l d3,(a1)    ; coin inf‚rieur droit
   clr.l mf1
   clr.l mf2
   GEM_VDI hide_mouse
   GEM_VDI copy_tab
   GEM_VDI show_mouse
   rts

; en entr‚e d0, num‚ro de la ligne … r‚‚crire ( en offset par rapport … d6 )

_ecrire:
   move d0,d1
   add d6,d1            ; num‚ro absolu de ligne
   move.l beuf(pc),a1
   bra.s .lb1
.lb0:
   add.w (a1),a1        ; recherche l'adresse de la ligne
.lb1: dbf d1,.lb0
   move.l edb(pc),a0
   move.l a0,a2
   move.l #$20202020,d1
   moveq #19,d2
.lb2:
   move.l d1,(a2)+
   dbf d2,.lb2
   clr.b (a2)       ; la fin
   tst (a1)+
   beq.s .vide
   move.b (a1)+,d2
   ext.w d2         ; tabulation
   lea -1(a0,d2.w),a2
.lb3:
   move.b (a1)+,(a2)+
   bne.s .lb3
   move.b d1,-(a2)
.vide:
   move colonnes,d2
   clr.b (a0,d2.w)     ; fin de chaine physique ( si ‚cran trop petit )
   move.l #edit_bas,a1
   move.l a1,fenetre
   muls 14(a1),d0     ; curseur ( avec 0 pour x )
   move.l d0,8(a1)
   move.l d4,a3
   jsr write_str
   move.l a3,d4
   rts

; en entr‚e [edb(pc)]+8 contient les octets avec 0
; a5 pointe sur l'ancienne ligne
; utilise a0,a1,a3,a4,d1,d2
; renvoit 0 dans d0 si la touche est trait‚e
; renvoit le code si elle ne l'est pas encore

propre:
	cmp #$5500,d0		 ; Shift F2 simule UNDO
	beq.s .special
   cmp #$6100,d0      ; UNDO, ne pas tenir compte des modifications
   bne.s .lb_0
.special:
   moveq #0,d0
   rts
.lb_0:
   cmp #$531f,d0      ; control DEL
   bne.s .lb_1
      cmp topedit,d5
      bne.s .k0
      clr (a5)
      move.l a5,bfptr      ; dans la fin du texte
      bra.s .special
   .k0:
   	bsr where_in_block
   	bgt.s .k0a				; GT rien … faire, au dela du bloc
   	beq.s .k0b				; EQ dans le bloc
   	subq #1,debutb			; MI, avant le bloc, ajuster d‚but
   	bra.s .k0a
   .k0b:
   	subq #1,finb			; EQ, une ligne de moins dans le bloc, ajuster taille
   	bpl.s .k0a				; si >=0 ok
   	move #-1,debutb		; sinon, bloc disparu !
   .k0a:
   	subq #1,topedit
      move.l a5,a0
      add (a5),a0          ; source
      move.l a5,a1         ; dest
      bsr _copie
      bsr copy_del
      bra.s .special
.lb_1:
	cmp.b #13,d0       ; l'un des ENTER
	bne .lb_2
		bsr where_in_block
		bgt.s .k1a			; GT rien … faire, au dela du bloc
		beq.s .k1b			; EQ dans le bloc
		addq #1,debutb		; MI avant le bloc, le d‚caler
		bra.s .k1a		
	.k1b:
		addq #1,finb		; dans le bloc: une ligne de plus
	.k1a:
	   move.l edb(pc),a0
	   lea 8(a0),a1
	   lea 2(a0),a3
	   move d7,d0
	   add d4,d0       ; taille
	   move.b (a1,d0.w),d3 ; c'est l… que ENTER coupe
	   clr.b (a1,d0.w)  ; on simule la fin de ligne
      bsr _formater
      move.b d3,(a1)   ; remet l'octet
      move.l a3,a0     ; nouvelle ligne en a3
      lea 2(a0),a3     ; la tabulation
      bsr _formater
		if STE=0
	      move.b ([edb,pc],2),d4  ; ancienne tabulation
	   else
	   	move.l a0,d7
	   	move.l edb(pc),a0
	   	move.b 2(a0),d4
	   	move.l d7,a0
	   endif
      subq.b #1,d4     ; moins l'offset
      add.b d4,2(a0)   ; d‚cale la ligne suivante
      ext.w d4
      moveq #0,d7      ; nouvelle position du curseur
      move colonnes,d3
   .k1:
      cmp d3,d4        ; hors de la fenetre
      bmi.s .k2
      sub d3,d4        ; alors avance d'une fenetre
      add d3,d7
      bra.s .k1
   .k2:
      move.l a3,d2
		if STE=0
	      sub.l (edb,pc),d2
	   else
	   	sub.l edb(pc),d2
	   endif
      bsr _insertion
      add.w (a5),a5
      addq #1,d5
      addq #1,topedit
      bsr copy_ret
		rts
.lb_2:
   cmp #$0e08,d0      ; BACKSPACE
   bne.s .normal
      bra .special    ; pas implant‚ encore...
      bsr copy_back
      bra .special
.normal:              ; touches sans suppression ou ajout de lignes
   move.l edb(pc),a0
   lea 8(a0),a1
   lea 2(a0),a3
   bsr _formater
   bsr _insertion
   rts

; en entr‚e, a5 pointe sur l'ancienne ligne
; d2 contient la taille de la nouvelle ligne
; nouvelle ligne en edb(pc)

_insertion:
   move (a5),d1       ; taille de la ligne avant
   lea (a5,d1.w),a0   ; d‚but de la ligne suiavnte avant
   lea (a5,d2.w),a1   ; d‚but de la ligne suivante voulu
   sub d2,d1          ; diff‚rence ?
   beq.s .lb9         ; aucune, rien … d‚placer
   bsr _copie
.lb9:
   move.l edb(pc),a0
   move.l a5,a1
   lsr #1,d2          ; en mots
   bra.s .lb11
.lb10: move (a0)+,(a1)+
.lb11: dbf d2,.lb10
   rts

; en entr‚e a1 pointe sur le texte
; a0 pointe sur le d‚but de ligne formatt‚
; a3 pointe sur a0+2
; en sortie a3 pointe sur la fin de la ligne
; d2.l contient la taille
; a1 pointe sur le z‚ro terminal
; a0 pointe toujours sur le d‚but de la ligne

_formater:
   moveq #0,d1
.lb0: move.b (a1)+,d2
   beq.s .vide
   addq #1,d1
   cmp.b #32,d2
   beq.s .lb0
   move.b d1,(a3)+    ; nombre +1 d'espaces avant ( tabulation )
   subq.l #1,a1
.lb1: move.b (a1)+,(a3)+
   bne.s .lb1         ; copie la ligne
   subq.l #1,a3       ; revient sur le z‚ro
.lb2: cmp.b #32,-(a3)
   beq.s .lb2         ; revient sur les espaces de fin de ligne
   addq.l #1,a3
   move.b #32,(a3)+   ; un espace au cas o— (pour adresse paire)
   move.l a3,d2
   bclr #0,d2         ; adresse paire
   move.l d2,a3
   sub.l a0,d2        ; taille de la ligne
   move d2,(a0)
   bra.s .lb8
.vide: move.l a0,a3
   moveq #4,d2
   move.l #$40120,(a3)+
.lb8: subq.l #1,a1    ; a1 pointe sur le z‚ro terminal
   rts

; a0 source, a1 dest copie de a0 jusqu'a bfptr ( mis … jour en cons‚quence )
; modifie a0,a1,d1

_copie:
	move.l bfptr,d1
	sub.l a0,d1      ; octets … copier
   ror.l #4,d1      ; paquets de 16
   cmp.l a0,a1
   bpl.s .lb4
   bra.s .lb1
.lb0:
   move.l (a0)+,(a1)+
   move.l (a0)+,(a1)+
   move.l (a0)+,(a1)+
   move.l (a0)+,(a1)+
.lb1: dbf d1,.lb0
   rol.l #3,d1      ; reste en mots
   and #7,d1
   bra.s .lb3
.lb2:
   move (a0)+,(a1)+
.lb3: dbf d1,.lb2
   clr (a1)         ; fin de texte
   move.l a1,bfptr
   rts
.lb4: sub.l a0,a1
   move.l bfptr,a0
   add.l a0,a1
   clr (a1)       ; fin de texte
   move.l a1,bfptr
   bra.s .lb6
.lb5:
   move.l -(a0),-(a1)
   move.l -(a0),-(a1)
   move.l -(a0),-(a1)
   move.l -(a0),-(a1)
.lb6: dbf d1,.lb5
   rol.l #3,d1
   and #7,d1
   bra.s .lb8
.lb7:
   move -(a0),-(a1)
.lb8: dbf d1,.lb7
   rts

	; d5 = ligne qui va ˆtre supprim‚e ou ins‚r‚e
	; compar‚e … la position du bloc
	; revoie MI si D5 avant le bloc
	; renvoie EQ si D5 dans le bloc
	; renvoie GT si D5 aprŠs le bloc ou si pas de bloc
	; utilise d0
		
where_in_block:
	move debutb,d0
	bmi.s .rien
	cmp d0,d5
	bmi.s .exit		; renvoie MI, d5 avant le bloc
	tst finb
	bpl.s .lb0
	move topedit,finb
	sub d0,finb
.lb0:
	add finb,d0		; derniŠre ligne du bloc
	cmp d5,d0
	bmi.s .rien		; si au dessus on saute
.dans:
	moveq #0,d0		; renvoie EQ si dans le bloc
	bra.s .exit
.rien:
	moveq #1,d0		; ici, on est aprŠs le bloc, pas d'influence
.exit:
	rts
	

res: dc.w 0

aller: lea .prompt(pc),a5
   moveq #5,d6      ; taille maxi
   bsr _dialogue
   moveq #0,d4		 ; remet le curseur au d‚but
   moveq #0,d7
   lea 2(a5),a5
   clr d5
.lb0:
   move.b (a5)+,d1
   beq.s .fin
   muls #10,d5
   sub.b #'0',d1
   ext.w d1
   add d1,d5
   bra.s .lb0
.fin: rts
	if LANG=0
.prompt: dc.b "Aller en : ",0
	else
.prompt: dc.b "   Go to : ",0
	endif

   even

chercher: lea .prompt(pc),a5
   moveq #20,d6
   bsr _dialogue
   move (a5)+,d0
   beq.s .fin
   clr d3
   bsr.s fouille
   moveq #0,d4
   moveq #0,d7
.fin: rts
	if LANG=0
.prompt: dc.b "Chercher : ",0
	else
.prompt: dc.b "  Search : ",0
	endif

 even

chsuiv: lea mot,a5
   move (a5)+,d0
   beq.s .fin
   move d5,d3
   addq #1,d3
   bsr.s fouille
   moveq #0,d4
   moveq #0,d7
.fin: rts

fouille: cmp topedit,d3
   bpl.s .fin
   move.l beuf(pc),a0
   move d3,d1
   bra.s .lb1
.lb0: add.w (a0),a0
.lb1: dbf d1,.lb0
   move.b (a5)+,d4
.loop: move (a0),d2
   beq.s .fin
   move.l a0,a1
   addq.l #2,a1
   move.l a1,a4
   addq.l #1,a1
   add.w d2,a0
   subq #2,d2
   sub d0,d2
   bmi.s .lb4
   bra.s .lb3
.lb2: cmp.b (a1)+,d4
   bne.s .lb3
   move d0,d1
   move.l a1,a2
   move.l a5,a3
   subq #1,d1
   clr d6
   bra.s .lb5
.lb6: cmp.b (a2)+,(a3)+
.lb5: dbne d1,.lb6
   beq.s .lb7
.lb3: dbf d2,.lb2
.lb4: addq #1,d3
   bra.s .loop
.lb7: moveq #82,d4
   move.b (a4),d1
   ext.w d1
   sub d1,d4
   sub.l a4,a1
   sub a1,d4
   move d3,d5
   rts
.fin: moveq #79,d4
   move #7,-(sp)
   move #2,-(sp)
   BIOS 3,6
   rts

_dialogue:
	move.l #edit_haut,fenetre
	GOSUB cls
	move.l a5,a0
	jsr write_str
   move.l #mot,a5
   clr.l (a5)
   lea 2(a5),a0
   move d5,-(sp)
   move.l #user_keys,end_keys
   jsr edition
   move.l #edit_list,end_keys
   move (sp)+,d5
   lea 2(a5),a0
.lb0:
   tst.b (a0)+
   bne.s .lb0
   sub.l a5,a0
   subq #3,a0
   move a0,(a5)
   move.l #edit_bas,fenetre
   rts

bloc: ; bsr propre    ; renvoit  a0 : debut de bloc
   move debutb,d0   ;          a1 : fin
   bpl.s .lb0       ;          d0 : 0 si le curseur dans le bloc
.lb: clr d0         ;         CCR : nul si bloc non valide
   rts              ;          d1 : taille
.lb0: cmp topedit,d0 ;         d3 : nbr de lignes
   bpl.s .lb
   move finb,d1
   bmi.s .lb1
   add d0,d1
   cmp topedit,d1
   bgt.s .lb
   bra.s .lb2
.lb1: move topedit,d1
.lb2: cmp topedit,d1
   bne.s .lb22
   subq #1,d1
.lb22:   move.l beuf(pc),a0
   move d0,d2
   bra.s .lb4
.lb3: add.w (a0),a0
.lb4: dbf d2,.lb3
   move d1,d2
   sub d0,d2
   move d2,d3
   addq #1,d3
   move.l a0,a1
.lb5: add.w (a1),a1
   dbf d2,.lb5
   cmp d5,d0
   bpl.s .lb6
   cmp.l d1,d5
   bpl.s .lb6
   moveq #0,d0
   bra.s .lb7
.lb6: moveq #1,d0
.lb7: move.l a1,d1
   sub.l a0,d1
   rts

effbloc: cmp.l a0,a5
   bmi.s .lb
   cmp.l a5,a1
   bpl.s .lba
   sub d3,d5
   bra.s .lb
.lba: move debutb,d5
.lb: sub d3,topedit
   move.l bfptr,d0
   sub.l a1,d0
   addq.l #2,d0
   lsr.l #1,d0
   move d0,d1
   and #7,d1
   lsr.l #3,d0
   bra.s .lb1
.lb0: move.l (a1)+,(a0)+
   move.l (a1)+,(a0)+
   move.l (a1)+,(a0)+
   move.l (a1)+,(a0)+
.lb1: dbf d0,.lb0
   bra.s .lb3
.lb2: move.w (a1)+,(a0)+
.lb3: dbf d1,.lb2
	ext.l d1
   move.l d1,debutb
   subq.l #2,a0
   move.l a0,bfptr
   rts

mvbloc: cmp.l a0,a5
   beq.s .fin
   bpl.s .lb
   exg.l a0,a5
   exg.l a5,a1
   bra.s .lb0
.lb: sub d3,d5
.lb0: move d5,debutb
   move.l a5,d0
   sub.l a0,d0
   move.l a5,d1
   sub.l a1,d1
   beq.s .fin
   move.l d0,d7
   lsr.l #1,d7
   bra.s .lb3
.lb1: add.l d1,a1
   cmp.l a5,a1
   bmi.s .lb2
   sub.l d0,a1
.lb2: move (a1),d3
   move d2,(a1)
   move d3,d2
   cmp.l a1,a0
   bne.s .lb4
   addq.l #2,a1
   cmp.l a5,a1
   bmi.s .lb3
   sub.l d0,a1
.lb3: move (a1),d2
   move.l a1,a0
.lb4: subq.l #1,d7
   bpl.s .lb1
.fin: rts

cpbloc: move.l bfptr,a2
   addq.l #2,a2
   move.l a2,a3
   add.l d1,a3
   add.l d1,bfptr
   add d3,topedit
   move.l a2,d0
   sub.l a5,d0
   lsr.l #1,d0
   move d0,d2
   and #$7,d2
   lsr.l #3,d0
   bra.s .lb1
.lb0: move.l -(a2),-(a3)
   move.l -(a2),-(a3)
   move.l -(a2),-(a3)
   move.l -(a2),-(a3)
.lb1: dbf d0,.lb0
   bra.s .lb3
.lb2: move -(a2),-(a3)
.lb3: dbf d2,.lb2
   cmp.l a5,a0
   bmi.s .lb4
   add.l d1,a0
   add d3,debutb
.lb4: lsr.l #1,d1
   move.l d1,d0
   and #$7,d0
   lsr.l #3,d1
   bra.s .lb6
.lb5: move.l (a0)+,(a5)+
   move.l (a0)+,(a5)+
   move.l (a0)+,(a5)+
   move.l (a0)+,(a5)+
.lb6: dbf d1,.lb5
   bra.s .lb8
.lb7: move (a0)+,(a5)+
.lb8: dbf d0,.lb7
   rts

; d5 num‚ro de ligne
; calcule aussi la taille restante en Ko
; utilise a0,a1,a2 et d0,d1,d2,d3
; restaure la structure fenetre

lgnaff:
   lea eedd,a0
   lea 13(a0),a1
   move d5,d0
   moveq #4,d1
.lb0:
   ext.l d0
   divs #10,d0
   swap d0
   add.b #"0",d0
   move.b d0,-(a1)
   swap d0
   dbf d1,.lb0
   move.l bfsize,d0
   add.l beuf(pc),d0
   sub.l bfptr,d0
   divs #1024,d0
   cmp ksize,d0
   beq.s .fin
   move d0,ksize
   lea 26(a0),a1
   moveq #2,d1
.lb1:
   ext.l d0
	divs #10,d0
	swap d0
	add.b #"0",d0
	move.b d0,-(a1)
	swap d0
	dbf d1,.lb1
.fin:
   lea edit_haut,a1
   clr.l 8(a1)
   move.l fenetre,-(sp)
   move.l a1,fenetre
   move.l d4,-(sp)
   jsr write_str
   move.l (sp)+,d4
   move.l (sp)+,fenetre
   rts

help_display_prompt:
	movem.l d4-d7/a3/a6,-(sp)
	lea help_prompt,a6
	GOSUB cr
	move.l fenetre,a0
	moveq #0,d6
	move 4(a0),d6			; largeur fenetre
	divs 12(a0),d6			; /largeur caractŠre nombre de colonnes
	move d6,colonnes
	bra.s _help_comm
help_display:
	movem.l d4-d7/a3/a6,-(sp)
	GOSUB cls
	lea help_txt,a6
_help_comm:
.loop:
	move.l a6,a0			; one line
.lb0:
	tst.b (a6)+
	bne.s .lb0				; a6 sur la fin de chaine
	move colonnes(pc),d6
	lea 0(a0,d6.w),a3
	move.b (a3),d7			; sauvegarde un octet
	clr.b (a3)				; fin physique au cas o—
	jsr write_str
	move.b d7,(a3)			; remet l'octet
	tst.b (a6)				; fin des chaines?
	beq.s .exit
	GOSUB cr
	bra.s .loop
.exit:
	movem.l (sp)+,d4-d7/a3/a6
	rts

	; a1 = chaine … ‚tendre
	; a0 = zone o— ‚tendre
	; entr‚e si (a0) = 0 chaine normale
	; si (a0)=FF chaine avec taille devant

expand_path:
	movem.l d1/a0/a2-a4,-(sp)
	move.l a1,a3
	move.l a0,a1
	move.l a0,a4
	move.b (a0),d1
	beq.s .lb0			; chaine normale
	addq.l #1,a1		; saute l'octet taille
.lb0:
	move.b (a3)+,d0	; un caractŠre source
	cmp.b #'%',d0
	bne.s .lb1			; ce n'est pas un %
	cmp.b #'%',(a3)
	bne.s .lb2
	move.b d0,(a1)+	; un double %% = %
	addq.l #1,a3
	bra.s .lb0
.lb2:
	lea chemin,a0
	bsr _copy_path
	move.l a2,a1		; reprendre au dernier "\"
	bra.s .lb0
.lb1:
	move.b d0,(a1)+
	bne.s .lb0			; pas z‚ro final, on continue
	tst.b d1
	beq.s .exit
	move.l a1,d1
	sub.l a4,d1			; taille + z‚ro final + octet taille
	subq.l #2,d1
	move.b d1,(a4)		; stocke la taille
.exit:
	movem.l (sp)+,d1/a0/a2-a4
	rts

update_slider:
	movem.l d3-d5/d7/a3,-(sp)
	moveq #0,d3
	tst d6					; <0 si appel‚ en fin d'‚dition
	bmi .modif
	move topedit,d0
	move d6,d7
	add lignes,d7			; nø de ligne de fin
	cmp d0,d7
	bmi.s .lb0
	move d0,d7				; limite … topedit
.lb0:
	move debutb,d4
	bmi.s .rien				; pas de bloc!
	cmp d7,d4
	bgt.s .rien				; bloc au dela de la fenˆtre
	move d4,d5
	cmp d6,d4
	bpl.s .lb1
	move d6,d4				; le bloc commence avant la fenˆtre, on remonte
.lb1:
	move finb,d1
	bpl.s .lb2
	move d0,d5				; si finb<0 aller jusqu'… la fin topedit
	bra.s .lb3
.lb2:
	add d1,d5				; sinon, derniŠre ligne du bloc
.lb3:
	cmp d6,d5
	bmi.s .rien				; tout le bloc est avant la fenˆtre
	cmp d7,d5
	bmi.s .compare
	move d7,d5				; si le bloc d‚borde du bas de la fenˆtre, on limite
	bra.s .compare	
.rien:
	moveq #0,d4
	moveq #-1,d5
.compare:	
	sub d4,d5
	addq #1,d5					; nombre de lignes
	sub d6,d4					; ramŠne le num‚ro de ligne en relatif/d‚but page
	lea slider,a0
	cmp 2(a0),d5			; d‚j… la mˆme taille?
	seq d3					; conserve...
	bne.s .recalc
	cmp (a0),d4				; d‚j… la mˆme valeur de d‚part?
	beq.s .sortie				
.recalc:
	move d4,(a0)+				; nouvelles valeurs
	move d5,(a0)
	bne.s .normal				; si d5<>0, un vrai slider
	moveq #1,d4					; sinon pas de bloc apparent, slider en haut
	moveq #1,d5
	bra.s .modif
.normal:
	lea fenetre0,a1
	move 14(a1),d0				; h d'un caractŠre
	move 6(a1),d1				; H fenˆtre
	addq #1,d4
	muls d0,d4					; h*(x+1) (ligne de d‚part)
	addq.l #2,d4				; pour la ligne de s‚paration
	muls d0,d5					; h*n (taille du slider)
	move d1,d0
	sub d5,d0					; taille restante H-h*n
	muls #1000,d5
	divs d1,d5					; taille slider h*n*1000/H
	muls #1000,d4
	divs d0,d4					; position slider (h*(x+1)+2)*1000/(H-h*n)
.modif:
	lea ws_int+2,a3
	tst.b d3
	bne.s .same_size
	move #16,(a3)				; set size
	move d5,2(a3)
	GEM_AES wind_set
.same_size:
	move #9,(a3)+
	move d4,(a3)				; set pos
	GEM_AES wind_set
.sortie:
	movem.l (sp)+,d3-d5/d7/a3
	rts
	
   COPIE lmax,y302
lmax: move.l #topedit,-(a6)
y302: rts

   COPIE bsize,y303
bsize: move.l #finb,-(a6)
y303:  rts

   COPIE   bfinit,y304
bfinit: clr topedit
	moveq.l #-1,d0
   move.l d0,debutb
   move.l beuf,a0
   move.l a0,bfptr
   clr (a0)
   sf change_flag			; remise … z‚ro du flag changement
y304: rts

init_ptr:
	moveq #0,d7
	move.l d7,inc_ptr			; reset la chaine des fichiers inclus
	move.l d7,opt_count		; remet … z‚ro le compte des optimisations (en global-4)
	rts

   SAUT
compilb: 
	bsr.s init_ptr
   bra.s ccmmpp

   SAUT
eval: moveq #-1,d7
ccmmpp: move.l #1624,-(sp)	; reserve un nouveau bloc
   GEMDOS 72,6
   move.l d0,a1
   move.l a5,(a1)+			; sauve les pointeurs
   move.l a4,(a1)+
   move.l a4,retptr
   move.l #debutb,a0
   move (a0)+,d3				; debut bloc
   move d3,(a1)+				; les infos de bloc
   move (a0)+,d4				; fin de bloc
   move d4,(a1)+
   move (a0),(a1)+
   move.l #cmplptr,a0
   move.l (a0)+,(a1)+
   move (a0),(a1)+
   move.l #exebuf,a0			; et sauvegarde le buffer d'ex‚cution qui va ˆtre utilis‚
   moveq #99,d1
.loop0: move.l (a0)+,(a1)+
   move.l (a0)+,(a1)+
   move.l (a0)+,(a1)+
   move.l (a0)+,(a1)+
   dbf d1,.loop0
   move.l (a0),(a1)
   move.l d0,(a0)				; adresse du buffer sauv‚e
   move.l a6,pilptr
   clr fincomp
   tst d7
   beq.s .cmp
   move finb,ligne
   move.l (a6),a0
   addq.l #4,pilptr
   bra.s .boucle
.cmp: move topedit,d5
   beq .fin
   tst d3
   bpl.s .lb0
   clr d3
.lb0: cmp d5,d3
   bpl .fin
   move d3,debutb
   tst d4
   bpl.s .lb1
   move d5,d4
   sub d3,d4
   subq #1,d4
.lb1: move d4,finb
   clr ligne
   move.l beuf(pc),a0
   bra.s .lb3
.lb2: add.w (a0),a0
.lb3: dbf d3,.lb2
   addq.l #3,a0
.boucle: jsr compil
   tst erreur
   bne.s .bug2
   cmp.l pilptr,a6
   bne.s .bug1
   tst trc
   bne.s .lb4
   jsr execut
   bra.s .lb5
.lb4: jsr exetrc
.lb5: tst fincomp
   bne.s .fin
   move.l cmplptr,a0
   bra.s .boucle
.bug1: lea bugpil,a0
   jsr write_str
   move #1,erreur
.bug2: move debutb,d3
   add ligne,d3
   move d3,editb
.fin: clr fincomp
   move.l #exebuf,a1
   move.l 1600(a1),a0
   move.l a0,-(sp)
   move.l (a0)+,a5
   move.l (a0)+,a4
   move.l #debutb,a2
   move.l (a0)+,(a2)+
   move (a0)+,(a2)
   move.l #cmplptr,a2
   move.l (a0)+,(a2)+
   move (a0)+,(a2)
   moveq #99,d0
.loop1: move.l (a0)+,(a1)+
   move.l (a0)+,(a1)+
   move.l (a0)+,(a1)+
   move.l (a0)+,(a1)+
   dbf d0,.loop1
   move.l (a0),(a1)
   move.l pilptr,a6
   GEMDOS 73,6
.vider_inclusions:
	tst.l inc_ptr
	beq.s .exit				; chaine vide
	bsr.s depile_inc
	bra.s .vider_inclusions
.exit:
   rts

depile_inc:
	move.l inc_ptr,d0
	beq.s .fin
	move.l d0,a0
	pea (a0)				; pour mfree
	move.l (a0)+,inc_ptr	; nouveau pointeur
	move (a0),-(sp)		; handle
	move (a0),d0
	GEMDOS 62,4				; fclose
	GEMDOS 73,6				; mfree
.fin:
	rts


   SAUT
format: moveq #1,d3               ; interleave par d‚faut
   move.l (a6)+,d7                ; sect par piste 9 ou 10
   bpl.s .lb
   moveq #9,d7                    ; sinon 9 secteurs
   moveq #11,d3                   ; et 11 en interleave
.lb: move.l (a6)+,d6              ; pistes par face 80, 81 ou 82
   move.l (a6)+,d5                ; faces 1 ou 2
   move.l (a6),d4                 ; unit‚ 0:A, 1:B
   move.b d4,d0
   add.b #'A',d0
   move.b d0,avertd
   ACONTROL 52,1,1,1
   move #2,intin
   move.l #avert,addrin
   AES
   move intout,d0
   cmp #2,d0
   bne.s .lb0
   rts
.lb0: move.l #11576,-(sp)             ; reserve 11*80*2*512+512
   GEMDOS 72,6                        ; place d'une piste 2 faces 11 sect
   move.l d0,formbuf                  ; plus le boot 512 octets
   bpl.s .lb1
   bra.s .fin
.bug: move.l formbuf,-(sp)
   GEMDOS 73,6                        ; libŠre la place
.fin: move.l d0,(a6)
   rts
.lb1: clr -(sp)                       ; non ex‚cutable
   move.w #3,-(sp)                    ; type 80/9/2faces
   move.l #$0603,-(sp)                ; nøserie (3.60 cod‚)
   add.l #11064,d0                    ; a la fin du buffer
   move.l d0,-(sp)
   XBIOS 18,14                        ; cr‚e un Boot secteur
   tst.l d0
   bmi.s .bug
   move.l formbuf,a3
   move.b d5,26+11064(a3)             ; ajuste le boot : faces
   move.b d7,24+11064(a3)             ; sect par piste
   move.l d7,d0
   muls d6,d0
   muls d5,d0                         ; d0=sect*pist*faces
   move.b d0,19+11064(a3)             ; total des secteurs
   lsr.w #8,d0
   move.b d0,20+11064(a3)             ; cod‚ a l'envers...
   bra.s .lb3
.lb2: move.w #$e5e5,-(sp)                 ; remplissage
   move.l #$87654321,-(sp)                ; magic
   move d3,-(sp)                          ; interleave
   clr -(sp)                              ; face 0
   move.w d6,-(sp)                        ; nøpiste
   move.w d7,-(sp)                        ; sect/piste
   move.w d4,-(sp)                        ; unit‚
   clr.l -(sp)
   move.l a3,-(sp)                        ; buffer
   XBIOS 10,26                            ; formate
   tst.l d0
   bmi.s .bug
   cmp #2,d5
   bne.s .lb3                             ; si une face on saute
   move.w #$e5e5,-(sp)
   move.l #$87654321,-(sp)
   move #1,-(sp)
   move #1,-(sp)                          ; meme chose face 1
   move.w d6,-(sp)
   move.w d7,-(sp)
   move.w d4,-(sp)
   clr.l -(sp)
   move.l a3,-(sp)
   XBIOS 10,26
   tst.l d0
   bmi .bug
.lb3: dbf d6,.lb2                         ; on boucle sur le nombre de pistes
   move.l a3,a0
   moveq #0,d0                            ; on vide 11064 octets
   move #460,d1
.lb4: move.l d0,(a0)+                     ; 461 * 24 = 11064
   move.l d0,(a0)+
   move.l d0,(a0)+
   move.l d0,(a0)+
   move.l d0,(a0)+
   move.l d0,(a0)+
   dbf d1,.lb4
   move d7,-(sp)                          ; nbr de sect
   clr.l -(sp)                            ; face 0 piste 0
   move #1,-(sp)                          ; … partir du secteur 1
   move d4,-(sp)                          ; unit‚
   clr.l -(sp)
   move.l a3,-(sp)                        ; buffer vide
   XBIOS 9,20                             ; ‚crit 0 sur la FAT et DIR
   tst.l d0
   bmi .bug
   cmp #2,d5                              ; si il y a 2 faces meme chose
   bne.s .lb5
   move d7,-(sp)
   move #1,-(sp)                          ; face 1
   clr -(sp)
   move #1,-(sp)
   move d4,-(sp)
   clr.l -(sp)
   move.l a3,-(sp)
   XBIOS 9,20
   tst.l d0
   bmi .bug
.lb5: add.w #11064,a3                     ; adresse du BOOT en m‚moire
   move #1,-(sp)                          ; 1 secteur
   clr.l -(sp)                            ; piste 0 face 0
   move #1,-(sp)                          ; secteur 1
   move d4,-(sp)                          ; unit‚
   clr.l -(sp)
   move.l a3,-(sp)                        ; adresse BOOT
   XBIOS 9,20                             ; qu'on ‚crit
   bra .bug

   SAUT
word: lea ordres,a0
   move.l #pad+2,a1
   move.l (a6),d0
   move.l a1,(a6)
   tst d0
   bmi.s .lb4
   cmp forth,d0
   bpl.s .lb4
   moveq #0,d1
   bra.s .lb0
.lb1: move.b (a0)+,d1
   add.w d1,a0
.lb0: dbf d0,.lb1
   move.b (a0)+,d1
   bra.s .lb2
.lb3: move.b (a0)+,(a1)+
.lb2: dbf d1,.lb3
.lb4: clr.b (a1)
   rts

	; certaines instructions peuvent ˆtre optimis‚es si une constante les pr‚cŠde
	; (code $4002) par exemple  26 and
	; au lieu move.l #26,-(a6) // move.l (a6)+,d1 // and.l d1,(a6)
	; on fera andi.l #26,(a6)
	; (code $5002) pour + et - si l'argument est de+/-1 … 8 on utilisera en plus:
	; addq/subq.l #n,(a6)
	; (code $6002) pour =,<,>,<> remplace le passage par la pile par D1 directement
	; et utilisation de moveq si -128/+12

optimise:
	cmp #$4002,d2			; simple remplacement?
	bne.s .lb0
.normal:
   move -6(a4),-6(a2)	; remplace move.l par le code de l'instruction optimis‚e
.optimisation:
	addq #1,opt_count
   rts
.lb0:
	cmp #$5002,d2			; add/sub ?
	bne.s .lb1
	move.l -4(a2),d2		; la constante
	bsr.s .un_huit			; renvoit EQ si de -1/-8 ou de 1/8
	bne.s .normal			; utlise addi et subi
	cmp #32,d4				; instruction "-"?
	bne.s .lb2
	neg.l d2					; donc ajouter l'oppos‚
.lb2:
	tst.l d2
	bmi.s .sous
	ror.w #7,d2
	or #$5096,d2			; addq
.ascomm:
	subq.l #6,a2
	move d2,(a2)+
	bra.s .optimisation
.sous:
	neg.l d2
	ror.w #7,d2
	or #$5196,d2			; subq
	bra.s .ascomm
.lb1:
	cmp #$6002,d2			; <,>,=,<> ?
	bne.s .lb3
	bsr.s optimise_move
   move -4(a4),d2      ; taille … copier en mots -1
   addq.l #2,a4			; saute le premier mot
   bra.s .cc2				; et donc en copie encore un de moins
.cc1: move (a4)+,(a2)+
.cc2:
   dbf d2,.cc1
	bra.s .optimisation
.lb3:
	rts
.un_huit:
	beq.s .non				; z‚ro est refus‚
	cmp.l #-8,d2
	bmi.s .non				; en dessous de -8?
	cmp.l #9,d2				; au dessus de 8?
	bpl.s .non
	cmp d2,d2				; renvoie EQ si ok
	rts
.non:
	moveq #-1,d2			; renvoie NE si refus‚
	rts

	; optimise array, array$, table, warray

optimise_array:
	tst.b ass_const
	bne.s .opt
	move (a5)+,(a2)+		; pas d'optimisation, instruction move normale
	rts
.opt:
	addq.l #2,a5			; saute le move
	sf ass_const			; et annule le flag
	addq #1,opt_count
	bra.s optimise_move

	; optimise les of,<of,>of,<>of si il y a une constante

optimise_of:
	tst.b ass_const
	bne.s .opt
	move (a4)+,(a2)+		; pas d'optimisation, instruction move normale
	rts
.opt:
	addq #1,opt_count
	addq.l #2,a4			; saute le move
	; continue sur optimise move

	; remplace un move.l #nnn,-(a6)
	; par move.l #nnn,d1
	; ou bien par moveq.l #nnn,d1	si -128/+127

optimise_move:
	move.l -4(a2),d2		; valeur
	bpl.s .cc3
	neg.l d2
	cmp.l #128,d2			; cas particulier
	beq.s .cc2
.cc3:
	and.l #$FFFFFF80,d2
	bne.s .cc4				; c'est en dehors de -128/+127
.cc2:
	subq.l #6,a2
	move.b #$72,(a2)+
	move.b 4(a2),(a2)+	; fabrique moveq.l #nn,d1
	bra.s .cc5
.cc4:
	move #$223c,-6(a2)	; remplace move.l #xxx,-(a6) en move.l #xxx,d1
.cc5:
	rts

	; tente d'‚viter ces cas, par exemple:
	; routine qui finit par move.l d1,-(a6)
	; suivie d'une qui commence par move.l (a6)+,d1
optimise_chaine:
	cmp #$2d00,-2(a2)		; d0,-(a6) … la derniŠre?
	bne.s .lb1
	cmp #$221e,(a4)		; et (a6)+,d1 … la suivante?
	bne.s .no_opt
	move #$2200,-2(a2)	; remplace par d0,d1
	bra.s .comm
.lb1:
	cmp #$2d01,-2(a2)		; d1,-(a6) … la derniŠre instruction?
	bne.s .no_opt
	cmp #$221e,(a4)		; (a6)+,d1 sur la suivante?
	bne.s .lb0
	subq.l #2,a2			; vire move.l d1,-(a6)
.comm:
	addq.l #2,a4			; vire move.l (a6)+,d1 ou (a6)+,a2
	subq #1,d2				; un mot de moins … copier
	addq #1,opt_count+2	; statistiques!
	rts
.lb0:
	cmp #$245e,(a4)		; (a6)+,a2 sur la suivante?
	bne.s .no_opt
	move #$2441,-2(a2)	; remplace par move.l d1,a2
	bra.s .comm
.no_opt:
	rts

assemblons:
	if STE=0
	   move.l (adresse,pc,d4.w*4),a4     ;  adresse du mot
	else
		lea adresse,a4
		add d4,a4
		add d4,a4
		add d4,a4
		move.l 0(a4,d4.w),a4
	endif
   tst d4
   bne.s .lb00
   move .emp(pc),(a2)+     ; constante entiŠre
   move.l d5,(a2)+
   st ass_const				; flag pour constante empil‚e
   rts
.lb00: cmp #637,d4       ; constante r‚elle
   bne.s .lb0
   move #$2d3c,(a2)+
   move.l d1,(a2)+
   move #$2d3c,(a2)+
   move.l d0,(a2)+
.sortie:
   sf ass_const
	rts
.lb0: cmp #diko,d4
   bpl .us             ; si c'est un mot "user"
   move -2(a4),d2      ; code juste avant la routine
   cmp.b #2,d2           ; recopie du code
   bne.s .lb2
   cmp #2,d2				; sans optimisation? (code 0002)
   beq.s .no_opt			; c'est ‡a, copier normalement
   tst.b ass_const		; d‚j… une constante
   beq.s .no_opt			; ben non, copier normalement
	bsr optimise			; va optimiser !
   bra.s .sortie
.no_opt:
   move -4(a4),d2      ; taille … copier en mots -1
   bsr optimise_chaine	; tente d'optimiser l'enchainement (pour ‚viter la pile)
.lb1: move (a4)+,(a2)+
   dbf d2,.lb1
   bra.s .sortie
.lb2:
	tst d2
   beq .bug1           ; non assemblable
   bmi .fin            ; -1 pour ";"
	cmp.b #3,d2        ; cr‚ation de "jsr adresse"
   bne.s .lb3
.saut: move .type3(pc),(a2)+
   move.l a4,(a2)+
   bra .sortie
.lb3: cmp.b #12,d2       ; exit
   bne.s .lb4
   move #$4e75,(a2)+
   bra .sortie
.lb4: cmp.b #17,d2       ; vdi ou aes
   bne.s .lb5
   addq.l #2,a4          ; passe l'opcode de sub
   sub (a4)+,d4          ; soustrait le d‚calage
   move .type17(pc),(a2)+
   move d4,(a2)+
   bra.s .saut
.lb5: cmp.b #6,d2        ; do
   bne.s .lb7
   lea .type6(pc),a4
.lb6: move (a4)+,(a2)+
   bne.s .lb6
   subq.l #2,a2
   move.l a2,-(a6)
   bra .sortie
.lb7: cmp.b #4,d2        ; loop
   bne.s .lb9
   lea .type4(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   move.l (a6)+,d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #2,a4
   move.l (a4)+,(a2)+
   move.l (a4),(a2)+
   bra .sortie
.lb9: cmp.b #13,d2      ; if
   beq.s .lb9b
   cmp.b #10,d2         ; while
   bne.s .lb10
.lb9b: lea.l .type13(pc),a4
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   move.l a2,-(a6)
   addq.l #4,a2
   bra .sortie
.lb10: cmp.b #14,d2     ; else ou endof
   bne.s .lb11
   move .type14(pc),(a2)+
   move.l (a6),a4
   move.l a2,(a6)
   addq.l #4,a2
   move.l a2,(a4)
   bra .sortie
.lb11: cmp.b #15,d2     ; then
   bne.s .lb12
   move.l (a6)+,a4
   move.l a2,(a4)
   bra .sortie
.lb12: cmp.b #5,d2      ; +loop
   bne.s .lb14
   lea .type5(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   move.l (a6),d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #2,a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a6)+,d2
   sub.l a2,d2
   move d2,(a2)+
   move 2(a4),(a2)+
   bra .sortie
.lb14: cmp.b #16,d2     ; ifloop
   bne.s .lb16
   lea .type16(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   move.l (a6)+,d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #2,a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   bra .sortie
.lb16: cmp.b #7,d2      ; begin
   bne.s .lb17
   move.l a2,-(a6)
   bra .sortie
.lb17: cmp.b #8,d2      ; again
   bne.s .lb18
   move .type14(pc),(a2)+
   move.l (a6)+,(a2)+
   bra .sortie
.lb18: cmp.b #9,d2      ; until
   bne.s .lb19
   lea .type13(pc),a4
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   move.l (a6)+,(a2)+
   bra .sortie
.lb19: cmp.b #11,d2     ; repeat
   bne.s .lb20
   move .type14(pc),(a2)+
   move.l (a6)+,a4
   move.l (a6)+,(a2)+
   move.l a2,(a4)
   bra .sortie
.lb20: cmp.b #18,d2      ; quit
   bne.s .lb21
   lea .type18(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   bra .sortie
.lb21: cmp.b #1,d2       ; un gemdos
   bne.s .lb23
   lea gblk-1476(pc),a4
   move #$4e41,d2
.lb22:
	if STE=0
		lea 0(a4,d4.w*4),a4
	else
		add d4,a4
		add d4,a4
		add d4,a4
		add d4,a4
	endif
   lea .tos(pc),a5
   move.l (a5)+,(a2)+
   move (a5)+,(a2)+
   move.b (a4)+,d0
   move.b (a4)+,d1
   bmi.s .tos1
   ext.w d1
.tos0: btst d1,d0
   bne.s .tos2
   move.l 2(a5),(a2)+
   bra.s .tos3
.tos2: move (a5),(a2)+
.tos3: dbf d1,.tos0
.tos1: addq.l #6,a5
   move (a5)+,(a2)+
   move.b (a4)+,d0
   ext.w d0
   move d0,(a2)+
   move d2,(a2)+
   addq.l #2,a5
   move (a5)+,(a2)+
   move.l (a5)+,(a2)+
   tst.b (a4)
   beq.s .tos4
   move (a5),(a2)+
.tos4: bra .sortie
.lb23: cmp.b #21,d2      ; un bios
   bne.s .lb24
   lea bblk-1588(pc),a4
   move #$4e4d,d2
   bra.s .lb22
.lb24: cmp.b #22,d2      ; un xbios
   bne.s .lb25
   lea xblk-1632(pc),a4
   move #$4e4e,d2
   bra.s .lb22
.lb25: cmp.b #19,d2      ; ."
   bne.s .lb26
   lea .type19(pc),a5
   move.l (a5)+,(a2)+
   move.l (a5)+,(a2)+
	move.l (a5)+,(a2)+
   addq.l #2,a2         ; saute l'offset
   bsr .ch
   addq #2,d2
   move d2,-(a5)
   bra .sortie
.lb26: cmp.b #20,d2      ; "
   bne.s .lb27
	lea .type20(pc),a5
	move.l (a5)+,(a2)+
	move.l (a5),(a2)+
   addq.l #4,a2
   bsr .ch
   move d2,-(a5)
   addq #4,d2
   move d2,-(a5)
	bra .sortie
.lb27: cmp.b #23,d2      ; case
   bne.s .lb28
   clr.l -(a6)
   bra .sortie
.lb28: cmp.b #25,d2      ; of
   bne.s .lb281
   lea .type25(pc),a4
.lb280:
	bsr optimise_of
	move.w (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l a2,-(a6)
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   bra .sortie
.lb281: cmp.b #33,d2      ; <>of
   bne.s .lb282
   lea .type33(pc),a4
   bra.s .lb280
.lb282: cmp.b #34,d2      ; >of
   bne.s .lb283
   lea .type34(pc),a4
   bra.s .lb280
.lb283: cmp.b #35,d2      ; <of
   bne.s .lb29
   lea .type35(pc),a4
   bra.s .lb280
.lb29: cmp.b #24,d2      ; endcase
   bne.s .lb31
.lb30: move.l (a6)+,d2
   beq .sortie
   move.l d2,a4
   move.l a2,(a4)
   bra.s .lb30
.lb31: cmp.b #26,d2      ; ndo
   bne.s .lb32
   lea .type26(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4),(a2)+
   move.l a2,-(a6)
   bra .sortie
.lb32: cmp.b #27,d2      ; nloop
   bne.s .lb33
   lea .type27(pc),a4
   move.l (a4),(a2)+
   move.l (a6)+,d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #6,a4
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   subq #8,d2
   move d2,(a2)+
   move 2(a4),(a2)+
   bra .sortie
.lb33: cmp.b #28,d2      ; fast ou slow
   beq .sortie
   cmp.b #29,d2      ; exe+
   bne.s .lb34
   move #$0696,(a2)+  ; addi.l #....,(a6)
   clr (a2)+
   move courant,(a2)+
   bra.s .exec
.lb34: cmp.b #30,d2      ; exec
   bne.s .lb35
.exec: lea .type30(pc),a4
   moveq #6,d2
.exe0: move.l (a4)+,(a2)+
   dbf d2,.exe0
   move (a4),(a2)+
   bra .sortie
.lb35: cmp.b #32,d2      ; dolist
   bne.s .lb36
   move #$4eb9,(a2)+
   move.l #dlcomp,(a2)+
   move.l a2,-(a6)
   bra .sortie
.lb36: cmp.b #31,d2      ; lloop
   bne .bug
   lea .type31(pc),a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a6)+,d2
   sub.l a2,d2
   move d2,(a2)+
   addq.l #2,a4
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move.l (a4)+,(a2)+
   move (a4)+,(a2)+
   bra .sortie
.fin: move #$4e75,(a2)+
   move.l a2,topprg
   move.l #but,a2
   move.l (a2)+,d0
   move.l (a2),-4(a2)
   move.l d0,(a2)
   move.l topsav2,a2
   clr ass
   clr in_def
   bra .sortie
.ch: move.l a2,a5
.ch3: move.b (a0)+,d2
   beq.s .ch2
   cmp.b #34,d2
   beq.s .ch1
   move.b d2,(a2)+
   bra.s .ch3
.ch1: clr.b (a2)+
   move.l a2,d2
   addq.l #1,d2
   bclr #0,d2
   move.l d2,a2    ; sur une adresse paire
   sub.l a5,d2     ; taille de la chaine
   rts
.ch2: addq.l #4,sp
	lea cbug2,a0
	bra .bug_comm
.us:                    ; mot "user"
   move (a4)+,d2		; quel type ? ($7FFF si ind‚fini pour l'instant)
   cmp #$7FFF,d2
   beq .bug_indef
	cmp #142,d2        ; array
   bne.s .u3
   lea .t142(pc),a5
   bsr optimise_array
   move.l (a5)+,(a2)+
   move.l a4,(a2)+
   addq.l #4,a5
   move (a5),(a2)+
   rts
.u3:
	cmp #144,d2        ; array$
   bne.s .u6
   lea .t144(pc),a5
   bsr optimise_array
   move (a4)+,d2
   addq #4,d2
   bclr #0,d2
   move (a5)+,(a2)+
   move d2,(a2)+
   addq.l #2,a5
   move (a5),(a2)+
   move.l a4,(a2)+
   move 6(a5),(a2)+
   rts
.u6: cmp #145,d2        ; table
   bne.s .u5
   lea .t145(pc),a5
   bsr optimise_array
   move.l (a5)+,(a2)+
   move.l a4,(a2)+
   move.l 4(a5),(a2)+
   rts
.u5:
	cmp #706,d2        ; [war]
   bne.s .u8
   lea .t706(pc),a5
   bsr optimise_array
   move.l (a5)+,(a2)+
   subq.l #2,a4
   move.l a4,(a2)+
   move 4(a5),(a2)+
   rts
.u8:
	sf ass_const			; pour tous les autres, on annule le flag inutile
	cmp #530,d2				; thvariable
	bne.s .u0
	move .emp(pc),(a2)+
	move.l a4,(a2)+		; empile l'adresse de d‚but du tableau-2 (avec taille donn‚es)
	move #$4eb9,(a2)+
	move.l #thvar,(a2)+	; et cr‚e jsr thvar
	rts
.u0:
   cmp #437,d2          ; "&assembler" ou ":: ;"
   bne.s .u1
   move #$4eb9,(a2)+
   move.l a4,(a2)+
   rts
.u1: cmp #140,d2        ; variable
   bne.s .u2
   move .emp(pc),(a2)+
   move.l a4,(a2)+
   rts
.u2: cmp #141,d2        ; constant
   bne.s .u4
   move .emp1(pc),(a2)+
   move.l a4,(a2)+
   rts
.u4: cmp #143,d2        ; string
   bne.s .u7
   addq.l #2,a4
   move .emp(pc),(a2)+
   move.l a4,(a2)+
   rts
.u7: cmp #628,d2        ; [&]
   bne.s .bug2
   ext.l d4
   move .emp(pc),(a2)+
   move.l d4,(a2)+
   rts
.bug2:
.bug1: lea ordres,a0		; mot non assemblable
   move.l #mot,a1
   move.b #32,(a1)+		; un espace
.blb1: subq #1,d4
   bmi.s .blb2
   move.b (a0)+,d2
   ext.w d2
   ext.l d2
   add.l d2,a0
   bra.s .blb1
.blb2: move.b (a0)+,d1
   ext.w d1
   subq #1,d1
.blb3: move.b (a0)+,(a1)+
   dbf d1,.blb3
   clr.b (a1)
   lea mot,a0
   jsr write_str
.bug: lea bugass,a0
.bug_comm:
   jsr write_str
   move #1,erreur
   rts
.bug_indef:
	lea bugundef,a0
	bra.s .bug_comm

.emp: move.l #2,-(a6)
.type3: dc.w $4eb9
.type17: move #100,d1
.type6: subq.l #8,a4
   move.l (a6)+,(a4)
   move.l (a6)+,4(a4)
   move.l #indptr,a1
   addq.l #4,(a1)
   move.l (a1),a2
   move.l a4,(a2)
   dc.w 0
.type4: addq.l #1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bmi .type13
   addq.l #8,a4
   subq.l #4,indptr
.type13: tst.l (a6)+
   bne.s .type5
.type14: dc.w $4ef9,0,0
.type5: move.l (a6)+,d1
   ble.s .ttt5
   add.l d1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bmi .type16
.tt5: addq.l #8,a4
   subq.l #4,indptr
   bra.s .type16
.ttt5: add.l d1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bpl .type16
   bra.s .tt5
.type16: tst.l (a6)+
   beq.s .t16
   addq.l #1,(a4)
   move.l (a4),d1
   cmp.l 4(a4),d1
   bmi .type18
.t16: move.l (a4),-(a6)
   addq.l #8,a4
   subq.l #4,indptr.l
.type18: move.l uspile,a7
   dc.w $4ef9
   dc.l debut
.t142: move.l (a6)+,d1
   asl.l #2,d1
   add.l #1212,d1
   move.l d1,-(a6)
.t144: move.l (a6)+,d1
   muls #1212,d1
   add.l #1212,d1
   move.l d1,-(a6)
.t145: move.l (a6)+,d1
   asl.l #2,d1
   move.l #1212,a0
   move.l (a0,d1),-(a6)
.t706: move.l (a6)+,d1
   add.l d1,d1
   add.l #1212,d1
   move.l d1,-(a6)
.tos: move.l a7,topsave.l
   move.l (a6)+,-(a7)
   move.l (a6)+,d0
   move d0,-(a7)
   move #1212,-(a7)
   move.l topsave.l,a7
   move.l d0,-(a6)
.type19: lea .type20(pc),a0
   jsr write_str
   bra .type19
.type20: lea .type25+2(pc),a0
   move.l a0,-(a6)
   bra .type20
.type25: move.l (a6)+,d1
   cmp.l (a6),d1
   beq.s .t25
   dc.w $4ef9,0,0
.t25: UP
.type33: move.l (a6)+,d1
   cmp.l (a6),d1
   bne.s .t33
   dc.w $4ef9,0,0
.t33: UP
.type34: move.l (a6)+,d1
   cmp.l (a6),d1
   bmi.s .t34
   dc.w $4ef9,0,0
.t34: UP
.type35: move.l (a6)+,d1
   cmp.l (a6),d1
   bgt.s .t35
   dc.w $4ef9,0,0
.t35: UP
.type26: clr.l -(a4)
   move.l (a6)+,d0
   subq.l #1,d0
   swap d0
   move.l d0,-(a4)
.type27: subq #1,(a4)
   bcc .type30
   subq #1,2(a4)
   bcc .type30
   addq.l #8,a4
.type30: moveq #2,d0
   move.l (a6)+,d1
   cmp dicco,d1
   bpl.s .t30
   moveq #0,d0
.t30: asl #2,d1
   move.l #adresse,a1
   move.l  0(a1,d1.w),a1
   add.w d0,a1
   jsr (a1)
.emp1: move.l $fffff.l,-(a6)
.type31: move.l indptr,a1
   addq.l #4,(a1)
   subq.l #1,(a4)
   bne .typee1
   addq.l #8,a4
   subq.l #4,lstptr
   subq.l #4,indptr
.typee1: rts

   NON
fff1: move (a5)+,forth
   move.l (a5)+,a0
   clr.b (a0)
   move.l a0,sommet
   move.l (a5),topprg
   move.l (a4)+,a5
   rts

   COPIE bstart,y305
bstart: move.l #debutb,-(a6)
y305: rts

   SAUT
buf0: move.l beuf(pc),-(a6)
   rts

   SAUT
writeb: move debutb,d3
   bpl.s .lb0
   clr d3
.lb0: move topedit,d5
   cmp d5,d3
   bpl.s .fin
   move finb,d4
   move.l beuf(pc),a3
   bra.s .lb2
.lb1: add.w (a3),a3
.lb2: dbf d3,.lb1
.lb3: move #0,-(sp)
   BIOS 8,4
   tst.l d0
   bne.s .lb4
   ACONTROL 52,1,1,1
   move #2,intin
   move.l #avert1,addrin
   AES
   move intout,d0
   cmp #2,d0
   beq.s .lb3
.fin: rts
.lb4: move #13,-(sp)
   clr -(sp)
   BIOS 3,6
   move #10,-(sp)
   clr -(sp)
   BIOS 3,6
   tst (a3)+
   beq.s .fin
   move.b (a3)+,d5
   bra.s .lb42
.lb41: move #32,-(sp)
   clr -(sp)
   BIOS 3,6
.lb42: subq.b #1,d5
   bne.s .lb41
   clr d5
.lb5: move.b (a3)+,d5
   beq.s .lb6
   move d5,-(sp)
   clr -(sp)
   BIOS 3,6
   bra.s .lb5
.lb6: subq.l #1,a3
   dbf d4,.lb4
   rts

   SAUT
import:
	move.l #chetxt,addrin
	move.l #fichtxt,addrin+4
	bsr selecteur
	bne.s .lb0
.fin:
	rts
.lb0:
	clr -(sp)
	move.l a0,-(sp)
	GEMDOS 61,8
	move.l d0,d7
	bmi.s .fin
	move.l bfptr,a3			; adresse derniŠre ligne
	move.l #setdat,d6			; critŠre d'arrˆt
	move.l d6,a0
.boucle:
	move.l a3,a2				; place pour la taille de la ligne
	clr (a3)+					; … z‚ro la taile (en cas de fin)
	clr.b (a3)					; la tabulation
.tab:
	bsr .suivant
	addq.b #1,(a3)				; une tabulation
	cmp.b #32,d0
	beq.s .tab
	cmp.b #9,(a3)				; TAB ?
	bne.s .lb2
	addq.b #3,(a3)
	bra.s .tab
.lb2:
	addq.l #1,a3
.ligne:
	cmp.b #13,d0				; fin de ligne?
	beq.s .fin_l
	cmp.b #9,d0
	bne.s .lb1
	moveq #32,d0
	move.b d0,(a3)+
	move.b d0,(a3)+
.lb1:
	move.b d0,(a3)+
	bsr .suivant
	bra.s .ligne
.fin_l:
	bsr .suivant				; le #10
	move.l a3,d0
	btst #0,d0					; adresse impaire?
	beq.s .paire
	move.b #32,(a3)+			; complŠte avec un espace
.paire:
	move.l a3,bfptr			; nouveau pointeur
	addq #1,topedit			; une ligne de plus
	move.l a3,d0
	sub.l a2,d0					; taille de la ligne
	move d0,(a2)
	bra.s .boucle
.suivant:
	cmp.l d6,a0
	bpl.s .read
	move.b (a0)+,d0
	rts
.read:
	pea setdat
	move.l #8192,-(sp)		; 16 secteurs de 512 octets
	move d7,-(sp)
	GEMDOS 63,12
	move.l d0,d6				; nombre d'octets lus
   bmi.s .sortie				; une erreur
   beq.s .sortie				; plus d'octets
   lea setdat,a0
   add.l a0,d6
   bra.s .suivant
.sortie:
	move d7,-(sp)
	GEMDOS 62,8					; sp+8 au lieu de +4 pour oter bsr
	rts

	SAUT
export:
	move.l #chetxt,addrin
	move.l #fichtxt,addrin+4
	bsr selecteur
	bne.s .lb0
.fin:
	rts
.lb0:
	move debutb,d6
   bpl.s .lb1
   clr d6
.lb1: move topedit,d5
   cmp d5,d6
   bpl.s .fin
   clr -(sp)
   move.l a0,-(sp)
   GEMDOS 60,8
   move.l d0,d7
   bmi.s .fin
   move finb,d4
   move.l beuf(pc),a3
   bra.s .lb3
.lb2: add.w (a3),a3
.lb3: dbf d6,.lb2
.boucle:
	lea setdat,a0
	moveq #98,d0
.boucle99:
   tst (a3)+
   bne.s .lb4
   bsr .write
   bra .close
.lb4:
   move.b (a3)+,d5
   ext.w d5
   subq #1,d5
   bra.s .lb42
.lb41: move.b #32,(a0)+
.lb42: dbf d5,.lb41
.lb5: move.b (a3)+,(a0)+
   bne.s .lb5
   subq.l #2,a0
   cmp.b #32,(a0)
   beq.s .lb6
   addq.l #1,a0
.lb6:
	move.b #13,(a0)+
	move.b #10,(a0)+
   subq.l #1,a3
   subq #1,d0
   bpl.s .lb7
   bsr .write
.lb7:
   dbf d4,.boucle99
   bsr .write
.close:
	move d7,-(sp)
	GEMDOS 62,4
   rts
.write:
	move.l #setdat,d0
	sub.l d0,a0
	cmp.l #0,a0
	beq.s .w1
	move.l d0,-(sp)
	move.l a0,-(sp)
	move d7,-(sp)
	GEMDOS 64,12
.w1: lea setdat,a0
	moveq #98,d0
	rts

   COPIE buf,y306
buf: move.l #bfptr,-(a6)
y306: rts

	SAUT
_trace_win:
	move.l (a6)+,d1
	move.l (a6)+,d0
	bsr.s trace_window
	rts

; d0 position verticale (en lignes textes) de la fenetre trace, si n‚gatif
; position … partir du bas
; d1 hauteur de la fenetre trace (en lignes textes)

trace_window:
	lea trace_win,a0			; la fenˆtre
	clr (a0)+					; X=0
	move.l work_out,d2      ; L-1,H-1
	addq #1,d2					; H
	move.l fenetre0+12,d3	; l,h (pour un caractŠre)
	muls d3,d0					; position Y
	bpl.s .lb0					; si positif, c'‚tait … partir du haut
	add d2,d0					; si n‚gatif Y'=H-Y
.lb0:
	bpl.s .lb1
	clr d0
.lb1:
	move d2,d4
	sub d3,d4
	sub d3,d4
	sub d3,d4					; H-3lignes
	cmp d4,d0
	bmi.s .lb2
	move d4,d0					; si trop bas, on remonte pour avoir 3 lignes
.lb2:
	move d0,(a0)+				; Y d‚finitif
	swap d2						; L-1
	addq #1,d2					; L
	move d2,(a0)+				; L
	swap d2
	move d3,d4					; hauteur caractŠre
	cmp #3,d1
	bpl.s .lb3
	moveq #3,d1					; 3 lignes au moins
.lb3:
	muls d1,d4					; hauteur fenˆtre
	add d4,d0					; fin fenˆtre
	cmp d0,d2					; compar‚ … H total
	bpl.s .lb4					; bon
	move d2,d4
	sub d0,d4					; hauteur maxi
.lb4:
	move d4,(a0)+ 	   		; H
	clr.l (a0)+					; x y curseur
	move.l d3,(a0)+			; l h caractŠre
	clr d2
	swap d2						; L
	swap d3						; l d'un caractŠre
	divs d3,d2					; caractŠres pas ligne
	move d2,(a0)+				; rang‚s … la fin de fenetre
	rts

adresse:
 dc.l empile,vayab,const,array,string,charray,table,thvayab,ret2,raff,dup2
 dc.l depth,drop,dup,over,pick,rzer,roll,rot,rpinit,wdmod
 dc.l rpaff,s0,spinit,wmod,spaff,swap,mul,mulw,wdiv,plus
 dc.l plm,moins,div,divm,inf0,eg0,sup0,sup,inf,egal
 dc.l plus1,moins1,plus2,moins2,mul2,div2,abs,and,max,min
 dc.l mod,neg,not,or,xor,loop,looppls,do,again,begin
 dc.l until,while,repeat,exit,case,of,else,endcase,if,else
 dc.l then,appl_find,i,j,k,leave,virg,0,pvirg,allot
 dc.l chsto,chplus,chegal,chinf,chsup,asc,bbase,chr,decimal,hex
 dc.l instr,len,left,mid,mlen,ppad,right,str,append,val
 dc.l sto,stop,stom,stop1,stom1,trace,untrc,aff,rcl,selplus
 dc.l carsto,carrcl,0,cls,addrsto,forget,selmoins,bin,here,dupm
 dc.l dropm,fin,vlist,point,term,bl,cr,emit,expect,inkey
 dc.l input,inputc,key,spc,spcs,type,quit,disply,chain,var1
 dc.l cons1,arr1,str1,char1,tab1,qt1,timer,dif,free,full
 dc.l pilaf,allot0,does,0,doesa,ifloop,edit,eval,bsize
 dc.l stform,diese,hold,dieses,edform
 dc.l call,loadb,saveb,lmax,bfinit,compilb,0,top
 dc.l aess,vdii,ctrl,iin,pin,iout,pout,ain,aout,wrcl
 dc.l wsto,hdl,vctrl,actrl,seizeb,vint,ptinsto,aint,gmds,bioss
 dc.l xbioss,wvirg,ebw,ebl,ewl,puts,gets,fcr,fop,fcl
 dc.l frd,fwr,fgd,fdl,ffs,fnx,dta,fsd,fsk,fsk1
 dc.l fsk2,xv_opnwk,xv_updwk,_global,vq_aes,vsync,joyst,mouse,jx0,jy0
 dc.l fire0,jx1,jy1,fire1,mousx,mousy,mousk,hadr,super,user
 dc.l v_opnvwk,vst_load_fonts,vst_unload_fonts,vs_clip,v_pline,v_pmarker
 dc.l v_gtext,v_fillarea,v_contourfill,v_recfl,vswr_mode
 dc.l vs_color,vsl_type,vsl_udsty,vsl_width,vsl_color
 dc.l vsl_ends,vsm_type,vsm_height,vsm_color,vst_height
 dc.l vst_point,vst_rotation,vst_font,vst_color
 dc.l vst_effects,vst_alignment,vsf_interior,vsf_style
 dc.l vsf_color,vsf_perimeter,vsf_udpat,vsc_form,vex_timv
 dc.l v_show_c,vq_color,vqt_extent,vqt_width,vqt_name
 dc.l v_clsvwk,v_clrwk,v_hide_c,vq_key_s,vql_attributes
 dc.l vqm_attributes,vqf_attributes,vqt_attributes
 dc.l vqt_fontinfo,v_bar,v_arc,v_pieslice,v_circle
 dc.l v_ellipse,v_ellarc,v_ellpie,v_rbox,v_rfbox
 dc.l v_justified,vq_chcells,v_exit_cur,v_enter_cur
 dc.l v_curup,v_curdown,v_curright,v_curleft,v_curhome
 dc.l v_eeos,v_eeol,vs_curaddress,v_curtext,v_rvon
 dc.l v_rvoff,vq_curaddress,vq_tabstatus,v_hardcopy
 dc.l _appl_init,graf_handle,evnt_keybd
 dc.l rsrc_free,wind_get,_wind_create,_wind_open,wind_delete
 dc.l _wind_set,wind_find,_wind_update,_wind_calc
 dc.l evnt_button,evnt_mouse,evnt_timer,form_error
 dc.l _wind_close,graf_rubberbox,graf_dragbox,graf_movebox
 dc.l graf_growbox,graf_shrinkbox,graf_mkstate,evnt_dclick
 dc.l evnt_mesag,evnt_multi,appl_read,appl_write
 dc.l objc_draw,objc_find,objc_offset,objc_edit
 dc.l objc_change,rsrc_load,rsrc_saddr,form_do,form_dial
 dc.l form_center,form_alert,menu_icheck,menu_ienable
 dc.l menu_tnormal,menu_register,graf_watchbox,graf_slidebox
 dc.l graf_mouse,scrp_read,scrp_write,shel_get,shel_put
 dc.l shel_find,rsrc_gaddr,menu_text,fsel_input
 dc.l shel_read,shel_write,shel_envrn,format
 dc.l menu_bar,xcut,xplus
 rept 28
   dc.l blockgds
 endr
 rept 11
   dc.l blockbs
 endr
 rept 28
   dc.l blockxbs
 endr
 dc.l st,ass1,tt,count,pair,sizeb,sizeb,sizew,sizel
 dc.l timera,timerb,timerc,timerd,timer_calc
 dc.l sc_load,sc_unload,sc_dma,sc_boot,sc_sendm,sc_getm
 dc.l sc_exec,sc_xsendm,sc_xgetm,sc_xsendb,sc_xgetb,sc_adr
 dc.l sc_check,sc_status,ifsto,ifrcl,isto,ircl,iwsto,iwrcl
 dc.l aligne,ver,screen_info
; dcb.l 23,0
 dc.l sizeb,sizew,sizel,rcl_ind,sto_ind,uhpt,ubpt
 dc.l modset,modload,modunload,modsname,modlname,modver
 dc.l modfmt,modtype,modinfo,modpal,modexe,fillmfdb
 dc.l fopsize,imagesize,dorim,dowim,doifx,dotrm
 dc.l graphic_card,modmload,modmunload,0,0
 dc.l savebitmap,loadbitmap,rsrc_mono,datetostr,strtodate
 dc.l timetostr,strtotime,tgetdate,tgettime,tsetdate,tsettime
 dc.l setsubpage,getsubpage,thread,thnext,thkill,thpause
 dc.l thwake,thrun,thid,thsync,thsyncmain,thnsync
 dc.l thkillall,thstat,st3,ret1,thv1,vthread
; dcb.l 75,0
 dcb.l 19,0
 dc.l vdisto,aessto,pre1,pre2,pre3,pre4
 dc.l post1,post2,post3,post4,siz,cvirg,wmulsto,wdivsto,mulsto2
 dc.l divsto2,deces,segferme,segouvert,word,0,ndo,nloop,list,dolist
 dc.l lloop,remember,restore,fff,fff1,bpt,dpt,opt,hpt,struct,pointer
 dc.l name,sizeof,schain,unchain,next,previous,screate,sdel,empty
 dc.l view,inchain,pchain,punchain,pinchain,ssto,bstart,fast,slow
 dc.l start,pushs,pushv,pushc,display,dir,ouvert,et,ferme,setof
 dc.l setplus,setfois,setmoins,card,setegal,setin,elmtrcl,elmtplus
 dc.l elmtmoins,elmtin,initset,pads,segment,et1,fplus,fmoins,ffois
 dc.l fdiv,fdup,fdrop,fpt,fval,empilfl,fswap,fover,fptpt,float
 dc.l frcl,fsto,fegal,fsup,appl_getinfo,sqr,fabs,appl_search,islast,appl_tplay,pempty
 dc.l writeb,ltype,0,setsto,compset,pint,pstr,pflt,pset,pstruc
 dc.l rint,rstr,rflt,rset,rstruc,cmove,pee,sin,cos,tan,atn,fneg,inv
 dc.l carre,expo,loga,flint,intfl,sincos,power,int,frac,appl_trecord
 dc.l ffois2,round,sign,fsurr,rsurf,frot,fpick,vqt_devinfo,vm_filename
 dc.l v_meta_extents,vm_pagesize
 dc.l stallot,ttallot,play,difof,supof,infof,wvar,setable
 dc.l warray,war,buf,setdigits,buf0,getfmt,fleche,andfl,andorpt,orfl
 dc.l pageclip,v_ftext,v_clear_disp_list,v_updwk,stack,st1,st2,current,stack0
 dc.l page,defp,setp,absolute,relative,fastcl,page0,fastop,desk,cache
 dc.l menu,setmenu,gemindex,strindex,dialogue,lastobj,child,parent
 rept 6
   dc.l objets
 endr
 rept 4
   dc.l boxtext
 endr
 dc.l image,userdef,get_xywh,set_redraw,_redraw,_work_out,get_xyxy,vst_arbpt
 dc.l vqt_f_extent,vst_setsize,vst_skew,icon,mfdbs,mfdbd,vr_trnfm,vrt_cpyfm,vro_cpyfm
 dc.l topsur,surtop,setplay,path,loadbin,savebin,setreplay,replay,savevdipal
 dc.l setvdipal,replay_end,cookie,vm_coords,v_opnwk,v_clswk,_page,import
 dc.l export,v_alpha_text,v_bez,v_bez_fill,v_bez_off,v_bez_on,v_bez_qual
 dc.l v_bit_image,v_fulshcache,v_fontinit,v_form_adv,v_ftext16,v_ftext_offset
 dc.l v_ftext_offset16,v_getbitmap_info,v_getoutline,v_get_pixel,v_loadcache
 dc.l v_output_window,v_pgcount,v_savecache,v_set_app_buff,v_write_meta
 dc.l vex_butv,vex_curv,vex_motv,vq_extnd,vq_gdos,_vq_mouse,vq_scan
 dc.l vqt_advance32,vqt_advance,vqt_cachesize,vqt_f_extent16,vqt_fontheader
 dc.l vqt_get_table,vqt_pairkern,vqt_trackkern,vst_arbpt32,vst_charmap
 dc.l vst_error,vst_kern,vst_scratch,vst_setsize32
 dc.l form_button,form_keybd,fsel_exinput,menu_attach,menu_istart,menu_popup
 dc.l menu_settings,objc_add,objc_delete,objc_order,objc_sysvar,rsrc_obfix
 dc.l rsrc_rcfix,wind_new,basepage,_app,reserve,nvmaccess,wdial_create,wdial_open
 dc.l wdial_close,wdial_formdo,wdial_change,wdial_evnt
 dc.l vq_margin,vq_driver_info,vq_bit_image,vs_page_info
 dc.l vs_crop,vq_image_type,nul_char,_trace_win,0,0,0,0,0,0,0	; >include … >ifflag
 dc.l 0	; >endf
 dc.l solve,gauss
 if 0
 	dc.l maximum,minimum
 endif
 dc.l _fpu


adrfin: dcb.l 10,0

diko equ (adrfin-adresse)/4

; flags dans le fichier INI:
; lettre Wnnn = nnn% de l'‚cran pour la fenetre, d‚faut full screen
; lettre M = Mouse On, sinon, souris effac‚e par d‚faut.
; lettre F = mode fast, depuis 0.2.2 mode slow par d‚faut
; lettre B = vecteurs bombes laiss‚s au systŠme, d‚tourn‚s par d‚faut
; lettre Annn = masque de bits sur les diff‚rentes alertes
;					bit0 = signaler si fichier FOR/TXT existe quand on ‚crit dessus
;				   bit1 = signaler si un bloc marqu‚ lorsqu'on sauve
; lettre Lnnn = langage n (utilis‚ pour le format de date)


read_flags:
	sf mouse_on
	cmp.b #'#',(a6)+
	bne.s .exit			; pas de #? pas de flags!
.encore:
	move.b (a6)+,d0
	cmp.b #33,d0
	bmi.s .fin			; fin de ligne?
	or.b #32,d0			; minuscule
	cmp.b #'w',d0
	bne.s .lb0
	bsr.s .get_number
	tst d1
	beq.s .encore			; refuser z‚ro
	move d1,screen_percent	; sinon, pourcentage valid‚
	bra.s .encore
.lb0:
	cmp.b #'m',d0
	bne.s .lb1
	st mouse_on
	bra.s .encore
.lb1:
	cmp.b #'f',d0
	bne.s .lb2
	move #1,isfast		; defaut slow mode, f=fast
	bra.s .encore
.lb2:
	cmp.b #'b',d0
	bne.s .lb3
	clr isbomb			; defaut d‚tourner bombes, si B, on laisse
	bra.s .encore
.lb3:
	cmp.b #'a',d0
	bne.s .lb4
	bsr.s .get_number
	move d1,alert_mask
	bra.s .encore
.lb4:
	cmp.b #'l',d0
	bne.s .lb5
	bsr.s .get_number
	move d1,langage	; cela peut recouvrir la valeur trouv‚e dans la ROM
	bra.s .encore
.lb5:
	bra.s .encore
.fin:
	cmp.b #33,(a6)+	; avance jusqu'… la ligne suivante
	bmi.s .fin
.exit:
	subq.l #1,a6
	rts
.get_number:			; for parameters with a number, D1=value
	moveq #0,d1
.next_digit:
	move.b (a6)+,d0
	sub.b #'0',d0
	bmi.s .end_size
	cmp.b #9,d0
	bgt.s .end_size
	muls #10,d1
	add d0,d1
	bra.s .next_digit
.end_size:
	subq.l #1,a6
	rts

alloc_edit:
	tst d7
	bmi.s .defaut
	move.b (a6)+,d0
	cmp.b #'%',d0
	bne.s .defaut
	moveq #0,d6
.lb1:
	move.b (a6)+,d0
	beq.s .defaut
	cmp.b #"+",d0
	beq.s .suite
	cmp.b #"-",d0
	beq.s .suite
	cmp.b #13,d0
	beq.s .defaut
	cmp.b #10,d0
	beq.s .defaut
	muls #10,d6
	sub.b #'0',d0
	add.b d0,d6
	bra.s .lb1
.suite:
	moveq #0,d5
.lb2:
	move.b (a6)+,d1
	beq.s .defaut
	cmp.b #13,d1
	beq.s .fin
	cmp.b #10,d1
	beq.s .fin
	muls #10,d5
	sub.b #'0',d1
	ext.w d1
	ext.l d1
	add.l d1,d5
	bra.s .lb2
.fin:
	cmp.b #'+',d0
	beq.s .fin2
	neg.l d5
.fin2:
	rts
.defaut:
	moveq #-1,d7
	moveq #17,d6
	moveq #0,d5
	rts

alloc_dicco:
	tst d7
	bmi.s .defaut
.lb0:
	move.b (a6)+,d0
	beq.s .defaut		; pas normal
	cmp.b #'%',d0
	bne.s .lb0
	moveq #0,d6
.lb1:
	move.b (a6)+,d0
	beq.s .defaut
	cmp.b #"+",d0
	beq.s .suite
	cmp.b #"-",d0
	beq.s .suite
	cmp.b #13,d0
	beq.s .defaut
	cmp.b #10,d0
	beq.s .defaut
	muls #10,d6
	sub.b #'0',d0
	add.b d0,d6
	bra.s .lb1
.suite:
	moveq #0,d5
.lb2:
	move.b (a6)+,d1
	beq.s .defaut
	cmp.b #13,d1
	beq.s .fin
	cmp.b #10,d1
	beq.s .fin
	muls #10,d5
	sub.b #'0',d1
	ext.w d1
	ext.l d1
	add.l d1,d5
	bra.s .lb2
.fin:
	cmp.b #'+',d0
	beq.s .fin2
	neg.w d5
.fin2
	rts
.defaut:
	moveq #-1,d7
	moveq #75,d6
	moveq #0,d5
	rts

copie_chemins:
	lea chemin,a0
	lea chetxt,a1
.lb0:
	move.b (a6)+,d0
	beq.s .defaut
	cmp.b #32,d0
	bmi.s .lb0
	subq.l #1,a6
.lb1:
	move.b (a6)+,d0
	beq.s .defaut
	cmp.b #13,d0
	beq.s .suite
	cmp.b #10,d0
	beq.s .suite
	move.b d0,(a0)+
	bra.s .lb1
.suite:
	clr.b (a0)
.lb2:
	move.b (a6)+,d0
	beq.s .defaut
	cmp.b #32,d0
	bmi.s .lb2
	subq.l #1,a6
.lb3:
	move.b (a6)+,d0
	beq.s .fin
	cmp.b #13,d0
	beq.s .fin
	cmp.b #10,d0
	beq.s .fin
	move.b d0,(a1)+
	bra.s .lb3
.fin:
	clr.b (a1)
	rts
.defaut:
	lea chemin,a0
	lea chetxt,a1
	move.l #'*.FO',(a0)+
	move.w #$5200,(a0)	; le R et z‚ro
	move.l #'*.TX',(a1)+
	move.w #$5400,(a1)	; le T et z‚ro
	rts

initial:
   move.l  4(a7),a5
   move.l a5,bspage           ; basepage rang‚e
   move.l #-1,_app_flag 		; pas un accessoire
   move.l $18(a5),d0
   add.l $1c(a5),d0
   add.l #$1100,d0
   and.b #$FC,d0					; multiple de 4 !
   move.l d0,sp
   lea -128(sp),sp				; de la marge en cas de foutoir
   sub.l a5,d0
   move.l  d0,-(sp)
   move.l  a5,-(sp)
   clr -(sp)
   GEMDOS $4a,12              ; r‚duit l'espace
   GEM_AES appl_init
   bsr aes_info					; teste la version et ses possibilit‚s
; 	bsr detect_aes
   GEM_AES graf_hand
   move.l intout+2,fenetre0+12  ; l et h d'un caractŠre.
   move intout,d7
   move d7,i_handle
   move d7,g_handle
   XBIOS 4,2
	add d0,ow_int              ; getrez+2
	GEM_VDI open_work          ; station interne
   move ow_cont+12,d6         ; garde le handle interne au FORTH
   GEM_VDI open_work          ; station pour l'utilisateur
   move ow_cont+12,handle
   move d6,i_handle
   GEM_VDI hide_mouse

   moveq #1,d0						; allow direct access
   moveq #1,d5						; allow AES calls
   jsr ScreenEncoding
   move.l d0,code_ecran
   move.l d1,gcard				; 0 SHIFTER, 1 VDI en liaison avec les modules M&E

   clr.b edbuf
   lea edsav,a0
   clr.w (a0)						; 0 + 0 si pas d'autoexec et 0 + FF si tester autoexec
   clr.w 512(a0)
   clr.w 1024(a0)
   clr.w 1536(a0)
	clr.w edoffset					; pointe sur le premier buffer
   clr -(sp)
   pea info
   GEMDOS 61,8						; fopen 'FORTH.INF'
   lea pad+2,a6
   move d0,d7						; handle
   bmi.s .pas_inf
   move.l a6,-(sp)
   move.l #1024,-(sp)			; 1028 octets maxi!
   move d7,-(sp)
   GEMDOS 63,12					; fread
   tst.l d0
   bmi.s .pas_inf
   clr.b 0(a6,d0.l)				; ajoute un z‚ro
   move d7,-(sp)
   GEMDOS 62,4						; fclose!
   lea .auto(pc),a0
   lea edbuf,a1
.lb3:
	move.b (a0)+,(a1)+
	bne.s .lb3
	st edsav+1				; FF pour marquer ce premier appel
   bra.s .lb1
.auto: dc.b "9 >include ",34,"%AUTOEXEC.FOR",34,0
	even
.pas_inf:
	moveq #-1,d7
.lb1:
	bsr read_flags					; quelques r‚glages par d‚faut
	bsr alloc_edit					; renvoit dans D6 le pourcentage
										; dans d5 le + ou - kilo octets
.encore:
   move.l  #-1,-(sp)          ; taille maxi
   GEMDOS $48,6
   moveq #12,d1
   lsr.l d1,d0
;   ext.l d0
	divs #25,d0					; d6% du total
	muls d6,d0
	add.l d5,d0						; + d5 kilo
   cmp.l #520,d0
   bmi.s .premier
   move.l #520,d0               ; mais limit‚ … 520 ko de source
.premier:
   lsl.l d1,d0                ; retour en octets
   move.l  d0,bfsize          ; taille buffer
   move.l  d0,-(sp)
   GEMDOS $48,6               ; allocation
   move.l  d0,beuf
   bpl.s .ok1
   moveq #17,d6
   moveq #0,d5						; sinon, retour … 17% et rien de plus
   bra.s .encore
.ok1:
   move.l  d0,bfptr           ; adresse gard‚e
   move.l  d0,a0
   clr (a0)                   ; 0 sur la premiŠre ligne
	bsr alloc_dicco				; renvoit d6 et d5 (% et +/-)
.encore2:
   move.l  #-1,-(sp)          ; taille restante
   GEMDOS $48,6
   moveq #10,d1
   lsr.l d1,d0
	divs #100,d0					; d6% du total
	muls d6,d0
	add.l d5,d0						; + d5 kilo
   lsl.l d1,d0                ; retour en octets
   move.l  d0,d6              ; on garde la taille
   move.l  d0,-(sp)
   GEMDOS $48,6               ; alloue le bloc dicco
   move.l  d0,program         ; on garde l'adresse
   move.l d0,debut_prog
   bpl.s .ok2
   moveq #75,d6					; sinon, 75%
   moveq #0,d5						; plus rien
   bra.s .encore2
.ok2:
   move.l  d0,topprg          ; dicco vide, on pointe au d‚but
   add.l d0,d6                ; fin du dico
   subq.l #4,d6
   move.l  d6,topmem          ; pour la gestion de l'allocation dynamique
   move.l  d6,botmem
   move.l  #1028,-(sp)        ; bloc pour la gestion dynamique
   GEMDOS $48,6
   move.l  d0,a0
   move.l  d0,szone           ; gard‚ dans szone
   clr.l (a0)+                ; aucun libre ni occup‚
   clr.l (a0)+
   moveq #-1,d0               ; fin de bloc
   move.l  d0,(a0)
   bsr copie_chemins				; celui des *.FOR et *.TXT
   move #1024,pad             ; taille de la chaine
   move #3,-(sp)
   move #15,-(sp)
   XBIOS 35,6           ; ralentit la r‚p‚tition du clavier
   lea ordres,a0        ; les mots du forth
   moveq #0,d1
   moveq #0,d2
.labell: move.b (a0)+,d2  ; taille du mot
   beq.s .label1          ; si 0, c'est fini
   addq #1,d1             ; sinon, un mot de plus
   add.l d2,a0            ; au suivant
   bra.s .labell
.label1: move d1,dicco    ; nombre de mots dans dicco
   move d1,forth          ; nombre de mots de base
   subq.l #1,a0           ; revient sur le z‚ro final
   move.l a0,sommet       ; c'est l… qu'on placera le mot suivant

   jsr read_cookies		; _MCH, _SND, _CPU, _APK

   clr def
   GEM_AES mouse_form
   clr.l remdata
   XBIOS 34,2				  ; kbdvbase
   move.l d0,a0
   lea 24(a0),a0
   move.l a0,joystick	  ; adresse ou mettre notre routine en cas de joyst
   move.l (a0),old_joyst  ; conserve l'ancien pointeur
   move.l -8(a0),old_mouse	; idem pour la souris (pour capter mousek=2)
   move.l  a7,uspile      ; garde la pile en cas de plantage
   clr.l -(sp)
   GEMDOS 32,6            ; superviseur
   move.l $4f2.w,a0       ; d‚but ROM
   move 2(a0),d4          ; version
	cmp #$0100,d4
	beq.s .lb2
	move.l 36(a0),kbshift	; pour TOS>1.00 on actualise la variable
.lb2:
	tst langage
	bpl.s .lb4					; d‚j… modifi‚ par FORTH.INI
	move 28(a0),d1				; os_conf
	lsr #1,d1					; enlŠve le bit du mode video
	cmp #127,d1					; tous langages?
	bne.s .lb5					; non, donc c'est le bon code
	move.l apk_value,d1		; si! aller voir dans APK
	lsr #8,d1
.lb5:
	move d1,langage
.lb4:
	

	tst isbomb
	beq.s .no_detour

   move.w #8,a0
   move.l #vectbuf,a1
   move.l (a0),(a1)+
   move.l #gloups2,(a0)+
   move.l (a0),(a1)+
   move.l #gloups3,(a0)+
   move.l (a0),(a1)+
   move.l #gloups4,(a0)+
   move.l (a0),(a1)
   move.l #gloups5,(a0)

.no_detour:

   jsr nova_init


   move.l d0,-(sp)
   GEMDOS 32,6           ; mode USER
	move #9,fixn          ; 9 chiffres pour l'affichage r‚el

   if STE=1
   	jsr test_fpu
   endif
	jsr test_mxalloc

	moveq #-4,d0			; FC !
	and.b d0,retptr+3	; multiple de 4
	and.b d0,pilbase+3
	lea pilptr,a6
	and.b d0,3(a6)		; multiple de 4
   move.l (a6),a6			; pile
   jsr fastopen         ; ouvre une fenetre sur tout l'‚cran ou half screen selon flag
   
   jsr init_thread0

   jsr le_menu

   moveq #-3,d0			 ; 3 lignes … parir du bas
   moveq #3,d1				 ; 3 lignes en tout
   jsr trace_window		 ; pr‚pare la fenˆtre pour TRACE

   tst mint_flag
   beq.s .monotache
   GEM_AES menu_reg      ; nom de l'application dans le menu MINT
.monotache:
	bsr init_ptr			 ; les pointeurs d'inclusion ou de compilation
	jsr souris_visible
   move.l bspage,a0
   add.w #$80,a0         ; adresse de la ligne de commande
   move.b (a0)+,d0       ; taille
   beq.s .sortie         ; nulle? donc rien … charger
   ext.w d0
   clr.b 0(a0,d0.w)      ; ajoute un z‚ro final
   bsr lll7              ; charge le fichier
.sortie: 
	tst.b edbuf				 ; si 0, pas de fichier FORTH.INF avec chemins par d‚faut
	bne.s .autoexec
.annule:
	jmp debut				; donc on commence normalement
.autoexec:
   moveq #3,d0
   move.l kbshift,a0
   and.b (a0),d0			; une touche Shift appuy‚e?
   bne.s .annule			; oui, donc ne pas essayer AUTOEXEC.FOR
	jmp ici					; sinon, on essaye d'inclure AUTOEXEC.FOR

 even

gblk: dc.b 0,-1,0,0,1,1,49,0,0,0,76,0,%1110,3,75,1,0,0,14,1,0,-1,25,1,1,0,59,1
      dc.b 1,1,71,1,1,1,54,0,1,0,57,1,1,0,58,1,%110,2,86,1,1,2,67,1,0,0,69,1
      dc.b 0,1,70,1,1,0,72,1,1,0,73,1,%110,2,74,1,0,-1,3,1,0,0,4,0,0,0,5,1
      dc.b 0,0,6,1,1,0,9,0,1,0,10,1,0,-1,11,1,0,-1,17,1,0,-1,18,1,0,-1,19,1

bblk: dc.b 0,0,1,1,0,0,8,1,0,0,2,1,0,1,3,0,%10,4,4,1,0,0,9,1,0,-1,10,1
      dc.b 1,0,0,0,0,0,7,1,0,0,11,1,%10,1,5,0

xblk: dc.b 0,-1,2,1,0,-1,3,1,0,-1,4,1,%11,2,5,0,1,0,6,0,0,1,7,0,%11,6,8,1
      dc.b %11,6,9,1,%11,6,19,1,%10,1,13,0,0,0,26,0,0,0,27,0,%1000,3,31,0
      dc.b 0,-1,34,1,%10,1,12,0,0,1,28,1,1,0,32,0,0,0,29,0,0,0,30,0,0,0,33,1
      dc.b 0,5,15,0,0,0,14,1,%110,2,0,0,%111,2,16,0,0,-1,24,0,0,1,35,1
      dc.b 0,-1,17,1,1,0,38,0

 data
 even

; puissances de 10 de 10^-1 … 10^-256

negdata:  dc.l $3fb99999,$9999999a
          dc.l $3f847ae1,$47ae147a
          dc.l $3f1a36e2,$eb1c432c
          dc.l $3e45798e,$e2308c38
          dc.l $3c9cd2b2,$97d889b7
          dc.l $3949f623,$d5a8a729
          dc.l $32a50ffd,$44f4a72d
          dc.l $255bba08,$cf8c9771
          dc.l $0ac80628,$64ac6ef7

; puissances de 10 de 10^1 … 10^256

posdata: dc.l $40240000,0
         dc.l $40590000,0
         dc.l $40c38800,0
         dc.l $4197d784,0
         dc.l $4341c379,$37e08000
         dc.l $4693b8b5,$b5056e16
         dc.l $4d384f03,$e93ff9f3
         dc.l $5a827748,$f9301d2e
         dc.l $75154fdd,$7f73bf33

; nombres r‚els de 1 … 9

chdata:  dc.w $3ff0,$4000,$4008,$4010,$4014,$4018,$401c,$4020,$4022

; donn‚es pour le CORDIC

cordk:  dc.l $3fe36e9d,$b5086bcb
        dc.l $3ff351e8,$7200eec2
pi:     dc.w $4009,$21fb,$5444,$2d18
pisur2: dc.w $3ff9,$21fb,$5444,$2d18

 even
ordres:
 dc.b 6,"[empl]",8,"variable",8,"constant",5,"array",6,"string"
 dc.b 6,"array$",5,"table",10,"thvariable",2,"r>",2,"r@",4,"?dup"
 dc.b 5,"depth",4,"drop",3,"dup",4,"over",4,"pick",2,"r0"
 dc.b 4,"roll",3,"rot",3,"rp!",5,"w/mod",3,"rp@",2,"s0",3,"sp!"
 dc.b 4,"wmod",3,"sp@",4,"swap",1,"*",2,"w*",2,"w/",1,"+",2,"+-"
 dc.b 1,"-",1,"/",4,"/mod",2,"0<",2,"0=",2,"0>",1,">",1,"<",1,"="
 dc.b 2,"1+",2,"1-",2,"2+",2,"2-",2,"2*",2,"2/",3,"abs",3,"and"
 dc.b 3,"max",3,"min",3,"mod",6,"negate",3,"not",2,"or",3,"xor"
 dc.b 4,"loop",5,"+loop",2,"do",5,"again",5,"begin",5,"until"
 dc.b 5,"while",6,"repeat",4,"exit",4,"case",2,"of",5,"endof"
 dc.b 7,"endcase",2,"if",4,"else",4,"then",9,"appl_find",1,"i",1,"j"
 dc.b 1,"k",5,"leave",1,44,1,":",1,";",5,"allot",2,"$!",2,"$+"
 dc.b 2,"$=",2,"$<",2,"$>",3,"asc",4,"base",4,"chr$",7,"decimal"
 dc.b 3,"hex",5,"instr",3,"len",5,"left$",4,"mid$",4,"mlen"
 dc.b 3,"pad",6,"right$",4,"str$",6,"append",3,"val",1,"!"
 dc.b 2,"+!",2,"-!",3,"1+!",3,"1-!",5,"trace",7,"untrace",1,"?"
 dc.b 1,"@",7,"select+",2,"c!",2,"c@",4,"find",3,"cls",7,"addrin!"
 dc.b 6,"forget",7,"select-",3,"bin",4,"here",4,"dupm",5,"dropm"
 dc.b 6,"system",5,"vlist",1,".",9,"?terminal",2,"bl",2,"cr",4,"emit"
 dc.b 6,"expect",5,"inkey",5,"input",6,"input$",3,"key"
 dc.b 5,"space",6,"spaces",4,"type",4,"quit",2,46,34,1,34
 dc.b 5,"[var]",5,"[cst]",5,"[arr]",5,"[str]",5,"[ar$]"
 dc.b 5,"[tab]",4,"[qt]",5,"timer",2,"<>"
 dc.b 4,"free",4,"full",2,".s",6,"allot0",6,":does>",4,";end"
 dc.b 7,"::does>",6,"ifloop",4,"edit",4,"eval",5,"bsize"
 dc.b 2,"<#",1,"#",4,"hold",2,"#s",2,"#>",4,"call",5,"loadb"
 dc.b 5,"saveb",4,"lmax",4,"buf!",7,"compilb",5,">comp",3,"top"
 dc.b 3,"aes",3,"vdi",7,"control",5,"intin",5,"ptsin",6,"intout"
 dc.b 6,"ptsout",6,"addrin",7,"addrout",2,"w@",2,"w!",6,"handle"
 dc.b 5,"vctrl",5,"actrl",4,"16b$",7,"vintin!",6,"ptsin!"
 dc.b 7,"aintin!",6,"gemdos",4,"bios",5,"xbios",2,"w",44,5,"extbw"
 dc.b 5,"extbl",5,"extwl",4,"puts",4,"gets",7,"fcreate",5,"fopen"
 dc.b 6,"fclose",5,"fread",6,"fwrite",7,"fgetdta",7,"fdelete"
 dc.b 6,"ffirst",5,"fnext",3,"dta",7,"fsetdta",5,"fseek",6,"fseek>"
 dc.b 6,"fseek<",8,"xv_opnwk",8,"xv_updwk",6,"global",6,"vq_aes"
 dc.b 5,"vsync",5,"joyst",5,"mouse",3,"jx0",3,"jy0",5,"fire0"
 dc.b 3,"jx1",3,"jy1",5,"fire1",6,"mousex",6,"mousey",6,"mousek"
 dc.b 6,"adress",5,"super",4,"user"
 dc.b 8,"v_opnvwk",14,"vst_load_fonts"
 dc.b 16,"vst_unload_fonts",7,"vs_clip",7,"v_pline",9,"v_pmarker"
 dc.b 7,"v_gtext",10,"v_fillarea",13,"v_contourfill",7,"v_recfl",9,"vswr_mode"
 dc.b 8,"vs_color",8,"vsl_type",9,"vsl_udsty",9,"vsl_width",9,"vsl_color"
 dc.b 8,"vsl_ends",8,"vsm_type",10,"vsm_height",9,"vsm_color",10,"vst_height"
 dc.b 9,"vst_point",12,"vst_rotation",8,"vst_font",9,"vst_color"
 dc.b 11,"vst_effects",13,"vst_alignment",12,"vsf_interior",9,"vsf_style"
 dc.b 9,"vsf_color",13,"vsf_perimeter",9,"vsf_udpat",8,"vsc_form",8,"vex_timv"
 dc.b 8,"v_show_c",8,"vq_color",10,"vqt_extent",9,"vqt_width",8,"vqt_name"
 dc.b 8,"v_clsvwk",7,"v_clrwk",8,"v_hide_c",8,"vq_key_s",14,"vql_attributes"
 dc.b 14,"vqm_attributes",14,"vqf_attributes",14,"vqt_attributes"
 dc.b 12,"vqt_fontinfo",5,"v_bar",5,"v_arc",10,"v_pieslice",8,"v_circle"
 dc.b 9,"v_ellipse",8,"v_ellarc",8,"v_ellpie",6,"v_rbox",7,"v_rfbox"
 dc.b 11,"v_justified",10,"vq_chcells",10,"v_exit_cur",11,"v_enter_cur"
 dc.b 7,"v_curup",9,"v_curdown",10,"v_curright",9,"v_curleft",9,"v_curhome"
 dc.b 6,"v_eeos",6,"v_eeol",13,"vs_curaddress",9,"v_curtext",6,"v_rvon"
 dc.b 7,"v_rvoff",13,"vq_curaddress",12,"vq_tabstatus",10,"v_hardcopy"
 dc.b 9,"appl_init",11,"graf_handle",10,"evnt_keybd"
 dc.b 9,"rsrc_free",8,"wind_get",11,"wind_create",9,"wind_open",11,"wind_delete"
 dc.b 8,"wind_set",9,"wind_find",11,"wind_update",9,"wind_calc"
 dc.b 11,"evnt_button",10,"evnt_mouse",10,"evnt_timer",10,"form_error"
 dc.b 10,"wind_close",14,"graf_rubberbox",12,"graf_dragbox",12,"graf_movebox"
 dc.b 12,"graf_growbox",14,"graf_shrinkbox",12,"graf_mkstate",11,"evnt_dclick"
 dc.b 10,"evnt_mesag",10,"evnt_multi",9,"appl_read",10,"appl_write"
 dc.b 9,"objc_draw",9,"objc_find",11,"objc_offset",9,"objc_edit"
 dc.b 11,"objc_change",9,"rsrc_load",10,"rsrc_saddr",7,"form_do",9,"form_dial"
 dc.b 11,"form_center",10,"form_alert",11,"menu_icheck",12,"menu_ienable"
 dc.b 12,"menu_tnormal",13,"menu_register",13,"graf_watchbox",13,"graf_slidebox"
 dc.b 10,"graf_mouse",9,"scrp_read",10,"scrp_write",8,"shel_get",8,"shel_put"
 dc.b 9,"shel_find",10,"rsrc_gaddr",9,"menu_text",10,"fsel_input"
 dc.b 9,"shel_read",10,"shel_write",10,"shel_envrn",6,"format"
 dc.b 8,"menu_bar",4,"exec",4,"exe+",6,"pterm0",8,"ptermres",5,"pterm"
 dc.b 5,"pexec",7,"dsetdrv",7,"dgetdrv",8,"dsetpath",8,"dgetpath"
 dc.b 5,"dfree",7,"dcreate",7,"ddelete",7,"frename",7,"fattrib"
 dc.b 7,"fduplic",6,"fforce",6,"malloc",5,"mfree",7,"mshrink",6,"cauxin"
 dc.b 7,"cauxout",7,"cprnout",6,"crawio",6,"cconws",6,"cconrs"
 dc.b 6,"cconis",6,"cprnos",6,"cauxis",6,"cauxos",8,"bconstat"
 dc.b 7,"bcostat",6,"bconin",7,"bconout",5,"rwabs",7,"mediach"
 dc.b 6,"drvmap",6,"getmpb",6,"getbpb",7,"kbshift",7,"setexec"
 dc.b 8,"physbase",7,"logbase",6,"getrez",9,"setscreen",10,"setpalette"
 dc.b 8,"setcolor",6,"floprd",6,"flopwr",7,"flopver",6,"mfpint"
 dc.b 7,"jdisint",8,"jenabint",7,"xbtimer",8,"kbdvbase",6,"midiws"
 dc.b 8,"giaccess",7,"dosound",8,"offgibit",7,"ongibit",6,"setprt"
 dc.b 6,"rsconf",5,"iorec",8,"initmous",6,"keytbl",8,"bioskeys"
 dc.b 6,"kbrate",6,"random",7,"supexec",6,"MFP_ST",5,"[ass]"
 dc.b 6,"MFP_TT",5,"count",4,"even",5,"delay",8,"auto_end",8,"soft_end"
 dc.b 10,"timer_stop",6,"timerA",6,"timerB",6,"timerC",6,"timerD"
 dc.b 10,"timer_calc"
 dc.b 7,"sc_load",9,"sc_unload",6,"sc_dma",7,"sc_boot",8,"sc_sendm",7,"sc_getm"
 dc.b 7,"sc_exec",9,"sc_xsendm",8,"sc_xgetm",9,"sc_xsendb",8,"sc_xgetb",6,"sc_adr"
 dc.b 8,"sc_check",9,"sc_status",3,"if!",3,"if@",2,"i!",2,"i@",3,"iw!",3,"iw@"
 dc.b 5,"align",3,"ver",11,"screen_info"
 dc.b 2,".b",2,".w",2,".l",2,")@",2,")!",3,"uh.",3,"ub."
 dc.b 6,"modset",7,"modload",9,"modunload",8,"modsname",8,"modlname",6,"modver"
 dc.b 6,"modfmt",7,"modtype",7,"modinfo",6,"modpal",6,"modexe",8,"fillmfdb"
 dc.b 9,"fopensize",9,"imagesize",5,"dorim",5,"dowim",5,"doifx",5,"dotrm"
 dc.b 12,"graphic_card",8,"modmload",10,"modmunload",1,"(",1,")"
 dc.b 10,"savebitmap",10,"loadbitmap",9,"rsrc_mono",9,"datetostr",9,"strtodate"
 dc.b 9,"timetostr",9,"strtotime",8,"tgetdate",8,"tgettime",8,"tsetdate",8,"tsettime"
 dc.b 10,"setsubpage",10,"getsubpage",6,"thread",6,"thnext",6,"thkill",7,"thpause"
 dc.b 6,"thwake",5,"thrun",4,"thid",6,"thsync",10,"thsyncmain",7,"thnsync"
 dc.b 9,"thkillall",6,"thstat",3,"st@",2,">r",5,"[thv]",7,"vthread"
 rept 19
 dc.b 1,"¹"
 endr
 dc.b 4,"vdi!",4,"aes!",3,"-(@",3,"-(!"
 dc.b 3,"+(@",3,"+(!",3,")-@",3,")-!",3,")+@",3,")+!",4,"size",2,"c"
 dc.b 44,3,"w*!",3,"w/!",3,"2*!",3,"2/!",3,"dcs",5,"<seg>",5,">seg<"
 dc.b 5,"word$",2,"::",3,"ndo",5,"nloop",4,"list",6,"dolist",5,"lloop"
 dc.b 8,"remember",7,"restore",2,"&f",3,"[f]",2,"b.",2,"d.",2,"o."
 dc.b 2,"h.",6,"struct",8,"&pointer",5,"&name",6,"sizeof"
 dc.b 5,"chain",7,"unchain",4,"next",8,"previous",7,"screate"
 dc.b 7,"sdelete",5,"empty",2,"..",7,"inchain",6,"pchain"
 dc.b 8,"punchain",8,"pinchain",2,"s!",6,"bstart",4,"fast",4,"slow"
 dc.b 5,"start",5,"pushs",5,"pushv",5,"pushc",7,"display",3,"dir"
 dc.b 2,"&(",1,"&",2,"&)",6,"&setof",4,"set+",4,"set*",4,"set-"
 dc.b 4,"card",4,"set=",5,"setin",5,"elmt@",5,"elmt+",5,"elmt-"
 dc.b 6,"elmtin",7,"initset",4,"pads",8,"&segment",3,"[&]",2,"f+"
 dc.b 2,"f-",2,"f*",2,"f/",4,"fdup",5,"fdrop",2,"f.",4,"fval"
 dc.b 4,"[fl]",5,"fswap",5,"fover",3,"f..",6,"&float",2,"f@",2,"f!"
 dc.b 2,"f=",2,"f>",12,"appl_getinfo",3,"sqr",4,"fabs",11,"appl_search",6,"islast"
 dc.b 10,"appl_tplay",6,"pempty",6,"writeb",5,"ltype",1,"¹",4,"set!"
 dc.b 4,"-set",4,"int>",4,"str>",4,"flt>",4,"set>",6,"struc>",4,">int"
 dc.b 4,">str",4,">flt",4,">set",6,">struc",5,"cmove",2,"pi",3,"sin"
 dc.b 3,"cos",3,"tan",3,"atn",4,"fneg",3,"1/x",3,"x^2",3,"exp",3,"log"
 dc.b 4,"ftoi",4,"itof",6,"sincos",3,"x^y",3,"int",4,"frac"
 dc.b 12,"appl_trecord",5,"f*2^n",5,"round",4,"sign",3,"f>r",3,"r>f"
 dc.b 4,"frot",5,"fpick",11,"vqt_devinfo",11,"vm_filename"
 dc.b 14,"v_meta_extents",11,"vm_pagesize"
 dc.b 7,"stallot",7,"ttallot",4,"play",4,"<>of",3,">of",3,"<of"
 dc.b 5,"&wvar",7,"setable",7,"&warray",5,"[war]",3,"buf",9,"setdigits"
 dc.b 4,"buf0",6,"getfmt",2,"->",5,"and->",3,"->.",4,"or->",8,"pageclip"
 dc.b 7,"v_ftext",17,"v_clear_disp_list",7,"v_updwk",6,"&stack",3,">st",3,"st>"
 dc.b 7,"current",6,"stack0",5,"&page",7,"defpage",7,"setpage",8,"absolute"
 dc.b 8,"relative",9,"fastclose",5,"page0",8,"fastopen",4,"desk",5,"cache"
 dc.b 4,"menu",7,"setmenu",8,"gemindex",8,"strindex",8,"dialogue",7,"lastobj"
 dc.b 7,"child<<",2,">>",3,"BOX",4,"IBOX",7,"BOXCHAR",6,"BUTTON"
 dc.b 6,"STRING",5,"TITLE",4,"TEXT",7,"BOXTEXT",5,"FTEXT",8,"FBOXTEXT"
 dc.b 5,"IMAGE",7,"USERDEF",8,"get_xywh",10,"set_redraw",6,"redraw",8,"work_out"
 dc.b 8,"get_xyxy",9,"vst_arbpt",12,"vqt_f_extent",11,"vst_setsize"
 dc.b 8,"vst_skew",4,"ICON"
 dc.b 5,"mfdbs",5,"mfdbd",8,"vr_trnfm",9,"vrt_cpyfm",9,"vro_cpyfm",4,"top>"
 dc.b 4,">top",7,"setplay",4,"path",7,"loadbin",7,"savebin",9,"setreplay"
 dc.b 6,"replay",10,"savevdipal",9,"setvdipal",10,"replay_end",7,"&cookie"
 dc.b 9,"vm_coords",7,"v_opnwk",7,"v_clswk",4,"page",6,"import",6,"export"
 dc.b 12,"v_alpha_text",5,"v_bez",10,"v_bez_fill",9,"v_bez_off",8,"v_bez_on"
 dc.b 10,"v_bez_qual",11,"v_bit_image",12,"v_fulshcache",10,"v_fontinit"
 dc.b 10,"v_form_adv",9,"v_ftext16",14,"v_ftext_offset",16,"v_ftext_offset16"
 dc.b 16,"v_getbitmap_info",12,"v_getoutline",11,"v_get_pixel",11,"v_loadcache"
 dc.b 15,"v_output_window",9,"v_pgcount",11,"v_savecache",14,"v_set_app_buff"
 dc.b 12,"v_write_meta",8,"vex_butv",8,"vex_curv",8,"vex_motv",8,"vq_extnd"
 dc.b 7,"vq_gdos",8,"vq_mouse",7,"vq_scan",13,"vqt_advance32",11,"vqt_advance"
 dc.b 13,"vqt_cachesize",14,"vqt_f_extent16",14,"vqt_fontheader",13,"vqt_get_table"
 dc.b 12,"vqt_pairkern",13,"vqt_trackkern",11,"vst_arbpt32",11,"vst_charmap"
 dc.b 9,"vst_error",8,"vst_kern",11,"vst_scratch",13,"vst_setsize32",11,"form_button"
 dc.b 10,"form_keybd",12,"fsel_exinput",11,"menu_attach",11,"menu_istart",10,"menu_popup"
 dc.b 13,"menu_settings",8,"objc_add",11,"objc_delete",10,"objc_order",11,"objc_sysvar"
 dc.b 10,"rsrc_obfix",10,"rsrc_rcfix",8,"wind_new",8,"basepage",4,"_app"
 dc.b 7,"reserve",9,"nvmaccess",13,"&wdial_create",10,"wdial_open",11,"wdial_close"
 dc.b 12,"wdial_formdo",12,"wdial_change",10,"wdial_evnt"
 dc.b 9,"vq_margin",14,"vq_driver_info",12,"vq_bit_image",12,"vs_page_info"
 dc.b 7,"vs_crop",13,"vq_image_type",9,"#nul_char",9,"trace_win",8,">include"	; ne pas d‚placer
 dc.b 5,">true",6,">false",7,">export",5,">exec",9,">prgflags",7,">ifflag"	; ces ordres ont une valeur absolue
 dc.b 5,">endf"
 dc.b 5,"solve",5,"gauss"
 if 0
 	dc.b 7,"maximum",7,"minimum"
 endif
 dc.b 4,"_fpu"
 dc.b 0

	even

 end