******************************************************************************
*							*
*		G R A O U M F   T R A C K E R			*
*							*
*	Soundtracker Falcon 030 32 voies au DSP			*
*	Par Laurent de Soras (c) 1994-96				*
*____________________________________________________________________________*
*							*
*	Langage          :	Assembleur 68030 (sous Devpac 2.23)	*
*	Nom du source    :	DUMTRACK.S				*
*	Code gÇnÇrÇ      :	DUMTRACK.PGT			*
*	Include          :	-				*
*	IncBin           :	FONTE1.FNT				*
*	Version          :	0.862				*
*	Date             :	20/7/1996				*
*							*
*	Routines diverses pour le Graoumf Tracker :			*
*	Gestion de l'interface, conversions de modules, manipulations	*
*	de samples, depackage, etc...				*
*							*
*	Tab = 11						*
*							*
******************************************************************************


	opt	p=68030,x-,d-,e-,s-
	Output	f:\dev.gtk\sys\dumtrack.pgt



*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*
*	Constantes						*
*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*

MAX_SBYTE:		Equ	127
MIN_SBYTE:		Equ	-128
MAX_SWORD:		Equ	32767
MIN_SWORD:		Equ	-32768
MAX_SLONG:		Equ	$7fffffff
MIN_SLONG:		Equ	-$80000000

NBRSAMPLES_MAXI:	Equ	1+255	; Nombre maximum de samples (+1 vide)
NBRINSTR_MAXI:	Equ	1+255	; Nombre maximum d'instruments (+1 vide)
NBRPATTERNS_VIDES:	Equ	2	; Nombre de patterns vides
NBRPATTERNS_MAXI:	Equ	256+NBRPATTERNS_VIDES	; Nombre maximum de patterns (+n vides)
NBRVOLENV_MAXI:	Equ	1+63	; Nombre maximum d'enveloppes de volume (+1 vide)
NBRTONENV_MAXI:	Equ	1+63	; Nombre maximum d'enveloppes de tonalitÇ (+1 vide)
NBRPANENV_MAXI:	Equ	1+63	; Nombre maximum d'enveloppes de panning (+1 vide)



*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*
*	Structures						*
*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*

;--- Chunk de description des samples ----------------------------------------
		RsReset
chunkid_s:		Rs.l	1	; 'SAMP'
chunksz_s:		Rs.l	1	; Taille du chunk
number_s:		Rs.w	1	; NumÇro du sample
name_s:		Rs.b	28	; Nom du sample
stereo_s:		Rs.w	1	; 0 = mono, 1 = stereo
autobal_s:		Rs.w	1	; Balance automatique, -1 = rien
nbits_s:		Rs.w	1	; 1 = 8 bits, 2 = 16 bits
fech_s:		Rs.w	1	; FrÇquence d'Çchantillonnage du sample (8363 Hz par dÇfaut)
length_s:		Rs.l	1	; Longueur du sample
repeat_s:		Rs.l	1	; Point de bouclage
replen_s:		Rs.l	1	; Longueur de boucle
vol_s:		Rs.w	1	; Volume   \ *** Ne pas dissocier
ftune_s:		Rs.w	1	; Finetune /
codagev_s:		Rs.w	1	; Version de codage
data_s:		Rs	0	; DÇbut des donnÇes du sample

;--- Chunk de description des instruments ------------------------------------
		RsReset
chunkid_i:		Rs.l	1	; 'INST'
chunksz_i:		Rs.l	1	; Taille du chunk
number_i:		Rs.w	1	; NumÇro de l'instrument
name_i:		Rs.b	28	; Nom de l'instrument
type_i:		Rs.w	1	; Type de l'instrument (0 = sample)
vol_i:		Rs.w	1	; Volume
autobal_i:		Rs.w	1	; Autobalance
volenv_i:		Rs.w	1	; Enveloppe de volume
tonenv_i:		Rs.w	1	; Enveloppe de tonalitÇ
panenv_i:		Rs.w	1	; Enveloppe de panning
		Rs.b	10	; RÇservÇ
splnum_i:		Rs.b	128*2	; NumÇros de samples pour chaque note
transp_i:		Equ	splnum_i+1
next_i:		Rs	0

;--- Structure d'une boåte ---------------------------------------------------
		RsReset
c_colonne:		Rs.w	1
c_ligne:		Rs.w	1
c_large:		Rs.w	1
c_haut:		Rs.w	1
c_cfond:		Rs.b	1
c_cbordn:		Rs.b	1
c_cborde:		Rs.b	1
c_cbordo:		Rs.b	1

;--- Structure d'un sample Ö mixer -------------------------------------------
		RsReset
mix_nbits:		Rs.w	1	; Nombre d'octet par sample (1 ou 2)
mix_sadr:		Rs.l	1	; Adresse du sample
mix_reps:		Rs.l	1	; Point de dÇbut de rÇpÇtition
mix_repe:		Rs.l	1	; Point de fin de rÇpÇtition (fin du sample)
mix_pos:		Rs.l	1	; Position courante
mix_volh:		Rs.l	1	; Volume (du sample * master volume)
mix_voll:		Rs.l	1
mix_ivolh:		Rs.l	1	; IncrÇment de volume pour chaque sample
mix_ivoll:		Rs.l	1
mix_next:		Rs	1
		RsSet	-12
mix2_adrbuf:	Rs.l	1
mix2_lonbuf:	Rs.l	1
mix2_nbits:	Rs.w	1
mix2_nbrspl:	Rs.w	1

;--- Informations sur un sample Ö digitaliser --------------------------------
		RsReset
rec_adresse:	Rs.l	1	; Adresse de dÇbut d'enregistrement
rec_longueur:	Rs.l	1	; Longueur du sample Ö Çchantillonner
rec_position:	Rs.l	1	; Position courante d'Çchantillonnage
rec_flag_loop:	Rs.w	1	; bit 0 = Echantillonner en boucle (jusqu'Ö demande d'arràt)
				; bit 1 = Indique si on a dÇjÖ bouclÇ
rec_nbits:		Rs.w	1	; Nombre d'octets par sample (1 ou 2)
rec_canal:		Rs.w	1	; Canal d'enregistrement (1=L, 2=R, 3=L+R).
rec_trigger:	Rs.w	1	; Valeur mini Ö recevoir pour commencer l'Çch. (/32768)
rec_frequence:	Rs.w	1	; FrÇquence CODEC (valeur.w Ö placer en $FFFF8934)
rec_next:		Rs	1

;--- Informations sur l'effet de delay ---------------------------------------
		RsReset
dly_adrsource:	Rs.l	1	; Adresse source
dly_adrdest:	Rs.l	1	; Adresse destination
dly_adrbuf1:	Rs.l	1	; Adresse buffer de delay
dly_adrbuf2:	Rs.l	1	; Adresse du buffer de retardement
dly_sourcelen:	Rs.l	1	; Longueur source
dly_destlen:	Rs.l	1	; Longueur destination
dly_feedback:	Rs.l	1	; Feedback (/32768)
dly_timefeed:	Rs.l	1	; Time feed (en octets)
dly_time2:		Rs.l	1	; Longueur du buffer 2 (octets)
dly_drylevel:	Rs.l	1	; Dry level (/32768)
dly_mutein:	Rs.l	1	; Mute in (en octets)
dly_nbitssource:	Rs.b	1	; Nombre d'octets par sample (source)
dly_nbitsdest:	Rs.b	1	; Nombre d'octets par sample (destination)
dly_ntaps:		Rs.w	1	; Nombre de taps
dly_tapinfo:	Rs	1
		RsReset		; Puis pour chaque tap :
dly_taptime:	Rs.l	1	; Delay time
dly_taplevel:	Rs.l	1	; Level (/32768)
dly_tapnext:	Rs	1

;--- Informations sur l'effet de flanger -------------------------------------
		RsReset
fl_adrlspl:	Rs.l	1	; Adresse du sample left
fl_adrrspl:	Rs.l	1	; Adresse du sample right
fl_adrdest:	Rs.l	1	; Adresse du sample destination
fl_adrlbuf:	Rs.l	1	; Adresse du buffer gauche
fl_adrrbuf:	Rs.l	1	; Adresse du buffer droit
fl_adrsin:		Rs.l	1	; Adresse de la table des sinus (4096,/4096)
fl_lonlspl:	Rs.l	1	; Adresse du sample source left
fl_lonrspl:	Rs.l	1	; Adresse du sample source right
fl_londest:	Rs.l	1	; Longueur du sample destination, en octets
fl_lonbuf:		Rs.l	1	; Longueur du buffer gauche (et droit), en octets
fl_resoll:		Rs.w	1	; Nombre d'octets par sample (source left)
fl_resolr:		Rs.w	1	; Nombre d'octets par sample (source right)
fl_resold:		Rs.w	1	; Nombre d'octets par sample (destination)
fl_flags:		Rs.w	1	; Flags : +1 = dest left, +2 = dest right
fl_fdbkll:		Rs.l	1	; Feedback left -> left (/65536)
fl_fdbklr:		Rs.l	1	; Feedback left -> right(/65536)
fl_fdbkrl:		Rs.l	1	; Feedback right -> left (/65536)
fl_fdbkrr:		Rs.l	1	; Feedback right -> right (/65536)
fl_dryl:		Rs.l	1	; Dry level left
fl_dryr:		Rs.l	1	; Dry level right
fl_wetl:		Rs.l	1	; Wet level left
fl_wetr:		Rs.l	1	; Wet level right
fl_freq:		Rs.l	1	; Frequence du flanger (65536*4096/FreqEch -> 1 Hz)
fl_amp:		Rs.l	1	; Amplitude du flanger (en octets)
fl_time:		Rs.l	1	; Temps de flange : 0 < time-amp < time+amp < lonbuf
fl_initphase:	Rs.l	1	; Phase initiale (0-4095 -> [0,2„[)
; Informations gÇnÇrÇes pendant le calcul:
fl_destcpt:	Rs.l	1	; Compteur de samples
fl_lsplpos:	Rs.l	1	; Postition dans le sample left
fl_rsplpos:	Rs.l	1	; Postition dans le sample right
fl_bufpos:		Rs.l	1	; Position dans les buffer
fl_sincpt:		Rs.l	1	; Compteur de sinus
fl_inl:		Rs.w	1	; MÇmorisations des samples d'entrÇe left
fl_inr:		Rs.w	1	; et right

;--- Informations sur l'effet de rÇverbÇration -------------------------------
	; -  -  - Sous-structures -  -  -
		RsReset
rev_eref_tapdelay:	Rs.l	1	; Delay pour chaque tap de la rÇflexion primaire
rev_eref_taplevel:	Rs.l	1	; Niveau pour chaque tap de la rÇflexion primaire (/65536)
rev_eref_end:	Rs	1
		Rsreset
rev_comb_adrbuf:	Rs.l	1	; Adresses des buffers de chaque comb filter
rev_comb_lonbuf:	Rs.l	1	; Longueurs des buffers de chaque comb filter
rev_comb_delay:	Rs.l	1	; Delay de chaque comb filter
rev_comb_fdbk:	Rs.l	1	; Feedback de chaque comb filter (/65536)
rev_comb_lpfg:	Rs.l	1	; Gain LPF de chaque comb filter (/65536)
; DonnÇes gÇnÇrÇes pendant le calcul:
rev_comb_pos:	Rs.l	1	; Position dans les buffers de chaque comb filter
rev_comb_lpfbuf:	Rs.l	1	; Buffers LPF (1 sample 16 bits + 16 de signe) pour chaque comb filter
rev_comb_end	Rs	1
	; -  -  - Structure principale -  -  -
		RsReset
rev_adrsource:	Rs.l	1	; Adresse du sample source
rev_adrdest:	Rs.l	1	; Adresse du sample destination
rev_lonsource:	Rs.l	1	; Longueur du sample source, en octets
rev_londest:	Rs.l	1	; Longueur du sample destination, en octets
rev_resolsource:	Rs.w	1	; RÇsolution du sample source
rev_resoldest:	Rs.w	1	; RÇsolution du sample destination
rev_drylevel:	Rs.l	1	; Niveau dry (/65536)
rev_ereflevel:	Rs.l	1	; Niveau des rÇflections primaires(/65536)
rev_revlevel:	Rs.l	1	; Niveau de la reverb (/65536)
rev_adrerefbuf:	Rs.l	1	; Adresse du buffer des rÇflections primaires
rev_lonerefbuf:	Rs.l	1	; Longueur du buffer des rÇflections primaires
rev_adradlybuf:	Rs.l	1	; Adresse du buffer du delay d'alignement
rev_lonadlybuf:	Rs.l	1	; Longueur du buffer du delay d'alignement
rev_adraprbuf:	Rs.l	1	; Adresse du buffer de l'All Pass Reverb
rev_lonaprbuf:	Rs.l	1	; Longueur du buffer de l'All Pass Reverb
rev_aprg:		Rs.l	1	; Gain (feedback) de l'all pass reverb (/65536)
rev_aprgneg:	Rs.l	1	; Gain, nÇgatif de l'all pass reverb (/65536)
rev_apr1mg2:	Rs.l	1	; 1 - gain**2 de l'all pass reverb (/65536)
rev_erefntap:	Rs.w	1	; Nombre de taps pour la rÇflection primaire (16 maxi)
rev_earlyreflection:	Rs.b	16*rev_eref_end	; Early Reflection
rev_ncomb:		Rs.w	1	; Nombre de comb filters (8 maxi)
rev_comb:		Rs.b	8*rev_comb_end	; Comb filters
rev_aprdelay:	Rs.l	1	; Delay de l'All Pass Reverb
rev_adlydelay:	Rs.l	1	; Delay d'alignement
; Informations gÇnÇrÇes pendant le calcul:
rev_sourcepos:	Rs.l	1	; Position du sample source
rev_destpos:	Rs.l	1	; Position du sample destination
rev_erefpos:	Rs.l	1	; Position dans le buffer des rÇflections primaires
rev_aprpos:	Rs.l	1	; Position dans le buffer de l'All Pass Reverb
rev_adlypos:	Rs.l	1	; Position dans le buffer de l'Alignement Delay
rev_drysample:	Rs.l	1	; Sample dry 16 bits signÇ 32 bits, avec le gain
rev_erefspl0:	Rs.l	1	; Sample rÇflection primaire 16 bits signÇ 32 bits
rev_erefsample:	Rs.l	1	; Idem, avec le gain
rev_reverbsample:	Rs.l	1	; Sample rÇverb 16 bits signÇ 32 bits

;--- Informations sur l'effet de compression ---------------------------------
		RsReset
comp_adrsource:	Rs.l	1	; Adresse du sample source
comp_adrdest:	Rs.l	1	; Adresse du sample destination
comp_adrbuffer:	Rs.l	1	; Adresse du buffer de volume (16 bits)
comp_lonsource:	Rs.l	1	; Longueur du sample source
comp_lonbuffer:	Rs.l	1	; Longueur du buffer de volume (64Ko maxi)
comp_ressource:	Rs.w	1	; RÇsolution du sample source
comp_resdest:	Rs.w	1	; RÇsolution du sample destination
comp_speed:	Rs.l	1	; Vitesse de compression (0-...), 0 = träs ÇlevÇe
comp_level:	Rs.l	1	; Niveau de compression (/65536)
comp_initvolume:	Rs.l	1	; Volume prÇsumÇ de dÇpart (/65536)
; Informations gÇnÇrÇes pendant le calcul:
comp_volume:	Rs.l	1	; Volume maximum courant (/65536)
comp_ampli_int:	Rs.w	1	; Coef courant d'amplification (entier)
comp_ampli_frac:	Rs.l	1	; Coef courant d'amplification (fractionnaire)
comp_posbuffer:	Rs.l	1	; Position actuelle du buffer
comp_possource:	Rs.l	1	; Position actuelle de la source/dest



*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*
*	DÇfinition des macros					*
*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*

;----------------------------------------------------------------------------;
;	Transforme le paramätre de 4 bits en 4 registres contenant	;
;	la valeur boolÇenne de chaque bit (0.b ou -1.b) : d2-d5	;
;----------------------------------------------------------------------------;
prend_couleurs:	MACRO
	lsr.w	\1		; d2-d5 contiennent la valeur
	scs	d2		; de chaque plan
	lsr.w	\1
	scs	d3
	lsr.w	\1
	scs	d4
	lsr.w	\1
	scs	d5
	ENDM

;----------------------------------------------------------------------------;
;	Echange les mots forts et faibles de d2-d5, contenant des	;
;	plans de couleur					;
;----------------------------------------------------------------------------;
inverse_couleurs:	MACRO
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	ENDM

;----------------------------------------------------------------------------;
;	Affiche un pixel Ö l'adresse contenue dans a2		;
;	Les plans On/Off sont contenus dans les registres.b d2-d5	;
;	d1 contient le masque 1<<x, d0 le masque !(1<<x), oó x est le	;
;	numÇro de pixel Ö afficher (0-7)				;
;----------------------------------------------------------------------------;
affiche_1pixel:	MACRO
	tst.b	d2
	beq.s	.1\@
	or.b	d1,(a2)
	bra.s	.5\@
.1\@	and.b	d0,(a2)
.5\@	addq.l	#2,a2
	tst.b	d3
	beq.s	.2\@
	or.b	d1,(a2)
	bra.s	.6\@
.2\@	and.b	d0,(a2)
.6\@	addq.l	#2,a2
	tst.b	d4
	beq.s	.3\@
	or.b	d1,(a2)
	bra.s	.7\@
.3\@	and.b	d0,(a2)
.7\@	addq.l	#2,a2
	tst.b	d5
	beq.s	.4\@
	or.b	d1,(a2)
	bra.s	.8\@
.4\@	and.b	d0,(a2)
.8\@	
	ENDM

;----------------------------------------------------------------------------;
;	Colorie 8 pixels contigus Ö l'adresse a2, avec les plans	;
;	contenus dans les registres.b d2-d5			;
;----------------------------------------------------------------------------;
remplit8pixels:	MACRO
	move.b	d2,(a2)		; Remplit 8 pixels
	addq.l	#2,a2
	move.b	d3,(a2)
	addq.l	#2,a2
	move.b	d4,(a2)
	addq.l	#2,a2
	move.b	d5,(a2)
	ENDM



*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*
*	RÇcapitulatif des routines				*
*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*

; +00 : Reloge la routine. Renvoie l'adresse de adrecr
; +04 : CrÇe la fonte ombrÇe
; +08 : Dessine un cadre avec un texte centrÇ
; +0C : Dessine un cadre dont les contours sont Ö l'intÇrieur
; +10 : Dessine un cadre dont les contours sont Ö l'extÇrieur
; +14 : Affiche une chaåne de caractäres Ö l'Çcran, avec transparence
; +18 : Affiche une chaåne de caractäres ombrÇs Ö l'Çcran, avec transparence
; +1C : Affiche une chaåne de caractäres Ö l'Çcran, sans transparence
; +20 : Affiche un caractäre Ö l'Çcran, avec transparence
; +24 : Affiche un caractäre Ö l'Çcran, avec dÇcalage de 4 pixels Ö droite et transparence
; +28 : Affiche un caractäre Ö l'Çcran, avec transparence et dÇcalÇ d'un pixel en bas Ö droite
; +2C : Affiche un caractäre Ö l'Çcran, avec dÇcalage de 5 pixels Ö droite, 1 pixel vers le bas,
;       en transparence
; +30 : Affiche un caractäre Ö l'Çcran, sans transparence
; +34 : Affiche le pattern
; +38 : Affiche un bout de sample
; +3C : Convertit des patterns NoiseTracker au format .GTK
; +40 : Convertit un pattern 669 8 voies au foramt .GTK
; +44 : Convertit une voie au format MTM en voie au format GTK
; +48 : Signe un sample
; +4C : Convertit un sample stereo en mono (1 valeur sur 2)
; +50 : Convertit un sample stereo en mono (moyenne des 2 valeurs)
; +54 : Convertit un pattern OctaMED pro n voies en pattern GTK (n+1) voies
; +58 : Indique si une icìne a ÇtÇ pressÇe
; +5C : Convertit un pattern au format S3M en pattern au format GTK
; +60 : Convertit un sample 16 bits Intel en 16 bits Motorola
; +64 : Convertit un pattern ULT en pattern GTK (renvoie la longueur du pattern ULT)
; +68 : Convertit un groupe de patterns d'un ancien format<4 GTK de 4 bytes/note en GTK 5
;       octets/note
; +6C : Efface un bloc de notes
; +70 : Copie un bloc de notes
; +74 : DÇcompacte un fichier ATOMIK PACKER 3.5
; +78 : Echange 2 blocs de notes
; +7C : Transpose un bloc de notes
; +80 : DÇcompacte un fichier PACK ICE 2.1
; +84 : Inverse les octets ou mots d'un morceau de mÇmoire
; +88 : Affiche un marqueur de sample
; +8C : Efface un marqueur de sample
; +90 : Copie un sample 8 bits en un sample 16 bits
; +94 : Copie un sample 16 bits en un sample 8 bits
; +98 : Convertit une ligne GTK en ligne MOD
; +9C : Cherche le volume maximum d'un sample
; +A0 : Change le volume d'un sample
; +A4 : Mixage de plusieurs samples
; +A8 : Affichage d'un vumätre
; +AC : Commence l'enregistrement d'un sample
; +B0 : Cherche le volume des buffers stereo de digitalisation
; +B4 : RÇÇchantillonne un sample
; +B8 : TransformÇe de Fourier pour 1 frÇquence
; +BC : Effet de delay
; +C0 : Conversion d'un pattern Digital Tracker en pattern GT
; +C4 : Recherche du chunk suivant dans un module DTM
; +C8 : Conversion d'un patt GT en patt S3M
; +CC : Conversion d'un patt FT2 en patt GT
; +D0 : Conversion d'un sample absolu en delta packing
; +D4 : Conversion inverse
; +D8 : BMOVE rapide
; +DC : Effet de flanger stereo
; +E0 : Depackage ICE 2.4
; +E4 : Effet de rÇverbÇration
; +E8 : Grise une surface
; +EC : Conversion d'un sample 16 bits stereo en 8/16 bits mono/stereo, par moyenne.
; +F0 : Enregistrement d'un module sous forme de sample
; +F4 : Stoppe l'enregistrement d'un module sous forme de sample
; +F8 : Effet de compression
; +FC : Affichage de l'image de prÇsentation
; +100: Transforme les codes clavier et extrait le numÇro de fonction associÇ Ö la touche
; +104: Retrouve les instruments et samples utilisÇs dans le module
; +108: DÇcompression Speed Packer



*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*

	TEXT



;     Partie pour le GfA Basic. Il s'agit de sauter aux diffÇrentes routines,
; puis de rÇcupÇrer dans les registres les paramätres placÇs sur la pile par
; le GfA.

	bra	relocation
	bra	fabrique_fonte_ombr
	bra	gfa_cadre_centre
	bra	gfa_dessine_cadre_int

	bra	gfa_dessine_cadre_ext
	bra	gfa_affchaine_trans
	bra	gfa_affchaine_trans_ombr
	bra	gfa_affchaine_notrans

	bra	gfa_affcar8x6
	bra	gfa_affcar8x6_dec
	bra	gfa_affcar8x6_ombr
	bra	gfa_affcar8x6_ombr_dec

	bra	gfa_affcar8x6nt_ombr
	bra	gfa_affiche_pattern
	bra	gfa_affiche_sample
	bra	gfa_convert_nt_2_gtk

	bra	gfa_convert_669_2_gtk
	bra	gfa_convert_mtm_voice_2_gtk
	bra	gfa_signe_sample
	bra	gfa_stereo_2_mono_one

	bra	gfa_stereo_2_mono_ave
	bra	gfa_convert_mmd1_2_gtk
	bra	gfa_teste_icones
	bra	gfa_convert_s3m_2_gtk

	bra	gfa_intel_16_bits
	bra	gfa_convert_ult_2_gtk
	bra	gfa_convert_gtk_2_gtk_vol
	bra	gfa_clear_note_block

	bra	gfa_paste_note_block
	bra	gfa_atomik_35_unpack
	bra	gfa_swap_note_block
	bra	gfa_transpose_note_block

	bra	gfa_packice_21_unpack
	bra	gfa_invert_memory
	bra	gfa_affiche_marqueur_sample
	bra	gfa_efface_marqueur_sample

	bra	gfa_copy_sample_8_2_16
	bra	gfa_copy_sample_16_2_8
	bra	gfa_convert_gtk_2_nt
	bra	gfa_cherche_volume_sample

	bra	gfa_change_volume_sample
	bra	gfa_mixage_samples
	bra	gfa_affiche_vumetre
	bra	start_sample_recording

	bra	cherche_volume_buffer_stereo
	bra	gfa_change_sample_frequency
	bra	gfa_trans_fourier
	bra	gfa_fx_delay

	bra	gfa_convert_dtm_2_gtk
	bra	gfa_dtm_next_chunk
	bra	gfa_convert_gtk_2_s3m
	bra	gfa_convert_ft2_2_gtk

	bra	gfa_absolu_2_delta
	bra	gfa_delta_2_absolu
	bra	gfa_bmove
	bra	gfa_fx_stereo_flanger

	bra	gfa_packice_24_unpack
	bra	gfa_fx_reverberation
	bra	gfa_grise_surface
	bra	gfa_convert_stereo16

	bra	gfa_start_song_recording
	bra	gfa_stop_song_recording
	bra	gfa_fx_compression
	bra	gfa_affiche_image_presentation

	bra	gfa_find_key_function
	bra	gfa_find_used_samples_and_instruments
	bra	gfa_speedpacker_unpack



gfa_cadre_centre:
	movem.l	d0/a0/a1,-(sp)
	move.l	12+4(sp),a0
	move.l	12+8(sp),a1
	move.w	12+12(sp),d0
	bsr	cadre_centre
	movem.l	(sp)+,d0/a0/a1
	rts

gfa_dessine_cadre_int:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	dessine_cadre_int
	move.l	(sp)+,a0
	rts

gfa_dessine_cadre_ext:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	dessine_cadre_ext
	move.l	(sp)+,a0
	rts

gfa_affchaine_trans:
	movem.l	d0/d2/d3/a1,-(sp)
	move.l	16+4(sp),a1
	move.w	16+8(sp),d3
	move.w	16+10(sp),d2
	move.w	16+12(sp),d0
	bsr	affchaine_trans
	movem.l	(sp)+,d0/d2/d3/a1
	rts

gfa_affchaine_trans_ombr:
	movem.l	d0-d3/a1,-(sp)
	move.l	20+4(sp),a1
	move.w	20+8(sp),d3
	move.w	20+10(sp),d2
	move.w	20+12(sp),d1
	move.w	20+14(sp),d0
	bsr	affchaine_trans_ombr
	movem.l	(sp)+,d0-d3/a1
	rts

gfa_affchaine_notrans:
	movem.l	d0/d2/d3/a1,-(sp)
	move.l	16+4(sp),a1
	move.w	16+8(sp),d3
	move.w	16+10(sp),d2
	move.w	16+12(sp),d0
	bsr	affchaine_notrans
	movem.l	(sp)+,d0/d2/d3/a1
	rts

gfa_affcar8x6:
	movem.l	d0/d1/a0,-(sp)
	move.l	12+4(sp),a0
	move.w	12+8(sp),d1
	move.w	12+10(sp),d0
	bsr	affcar8x6
	movem.l	(sp)+,d0/d1/a0
	rts

gfa_affcar8x6_dec:
	movem.l	d0/d1/a0,-(sp)
	move.l	12+4(sp),a0
	move.w	12+8(sp),d1
	move.w	12+10(sp),d0
	bsr	affcar8x6_dec
	movem.l	(sp)+,d0/d1/a0
	rts

gfa_affcar8x6_ombr:
	movem.l	d0/d1/a0,-(sp)
	move.l	12+4(sp),a0
	move.w	12+8(sp),d1
	move.w	12+10(sp),d0
	bsr	affcar8x6_ombr
	movem.l	(sp)+,d0/d1/a0
	rts

gfa_affcar8x6_ombr_dec:
	movem.l	d0/d1/a0,-(sp)
	move.l	12+4(sp),a0
	move.w	12+8(sp),d1
	move.w	12+10(sp),d0
	bsr	affcar8x6_ombr_dec
	movem.l	(sp)+,d0/d1/a0
	rts

gfa_affcar8x6nt_ombr:
	movem.l	d0/d1/a0,-(sp)
	move.l	12+4(sp),a0
	move.w	12+8(sp),d1
	move.w	12+10(sp),d0
	bsr	affcar8x6nt_ombr
	movem.l	(sp)+,d0/d1/a0
	rts

gfa_affiche_pattern:
	movem.l	d0-d2/a0-a2,-(sp)
	move.w	24+4(sp),d0
	move.l	24+6(sp),a0
	move.l	24+10(sp),a1
	move.l	24+14(sp),a2
	move.w	24+18(sp),d1
	move.w	24+20(sp),d2
	bsr	affiche_pattern
	movem.l	(sp)+,d0-d2/a0-a2
	rts

gfa_affiche_sample:
	movem.l	d0-d4/a0,-(sp)
	move.l	24+4(sp),a0
	move.l	24+8(sp),d0
	move.w	24+12(sp),d1
	move.w	24+14(sp),d2
	move.w	24+16(sp),d3
	move.w	24+18(sp),d4
	bsr	affiche_sample
	movem.l	(sp)+,d0-d4/a0
	rts

gfa_convert_nt_2_gtk:
	movem.l	d0/a0,-(sp)
	move.l	8+4(sp),a0
	move.l	8+8(sp),d0
	bsr	convert_nt_2_gtk
	movem.l	(sp)+,d0/a0
	rts

gfa_convert_669_2_gtk:
	movem.l	a0/a1,-(sp)
	move.l	8+4(sp),a0
	move.l	8+8(sp),a1
	bsr	convert_669_2_gtk
	movem.l	(sp)+,a0/a1
	rts

gfa_convert_mtm_voice_2_gtk:
	movem.l	d0/d1/a0/a1,-(sp)
	move.l	16+4(sp),a0
	move.l	16+8(sp),a1
	move.w	16+12(sp),d0
	move.w	16+14(sp),d1
	bsr	convert_mtm_voice_2_gtk
	movem.l	(sp)+,d0/d1/a0/a1
	rts

gfa_signe_sample:
	movem.l	d0/d1/a0,-(sp)
	move.l	12+4(sp),a0
	move.l	12+8(sp),d0
	move.w	12+12(sp),d1
	bsr	signe_sample
	movem.l	(sp)+,d0/d1/a0
	rts

gfa_stereo_2_mono_one:
	movem.l	d0/d1/a0/a1,-(sp)
	move.l	16+4(sp),a0
	move.l	16+8(sp),a1
	move.l	16+12(sp),d0
	move.w	16+16(sp),d1
	bsr	stereo_2_mono_one
	movem.l	(sp)+,d0/d1/a0/a1
	rts

gfa_stereo_2_mono_ave:
	movem.l	d0/d1/a0/a1,-(sp)
	move.l	16+4(sp),a0
	move.l	16+8(sp),a1
	move.l	16+12(sp),d0
	move.w	16+16(sp),d1
	bsr	stereo_2_mono_ave
	movem.l	(sp)+,d0/d1/a0/a1
	rts

gfa_convert_mmd1_2_gtk:
	movem.l	d0/d1/d6/a0-a2,-(sp)
	move.l	24+4(sp),a0
	move.l	24+8(sp),a1
	move.l	24+12(sp),a2
	move.w	24+16(sp),d0
	move.w	24+18(sp),d1
	move.w	24+20(sp),d6
	bsr	convert_mmd1_2_gtk
	movem.l	(sp)+,d0/d1/d6/a0-a2
	rts

gfa_teste_icones:
	movem.l	d1/d2/a0,-(sp)
	move.l	12+4(sp),a0
	move.w	12+8(sp),d0
	move.w	12+10(sp),d1
	move.w	12+12(sp),d2
	bsr	teste_icones
	movem.l	(sp)+,d1/d2/a0
	rts

gfa_convert_s3m_2_gtk:
	movem.l	d0/a0-a2,-(sp)
	move.l	16+4(sp),a0
	move.l	16+8(sp),a1
	move.l	16+12(sp),a2
	move.w	16+16(sp),d0
	bsr	convert_s3m_2_gtk
	movem.l	(sp)+,d0/a0-a2
	rts

gfa_intel_16_bits:
	movem.l	d0/a0,-(sp)
	move.l	8+4(sp),a0
	move.l	8+8(sp),d0
	bsr	intel_16_bits
	movem.l	(sp)+,d0/a0
	rts

gfa_convert_ult_2_gtk:
	movem.l	a0/a1,-(sp)
	move.l	8+4(sp),a0
	move.l	8+8(sp),a1
	move.w	8+12(sp),d0
	bsr	convert_ult_2_gtk
	movem.l	(sp)+,a0/a1
	rts

gfa_convert_gtk_2_gtk_vol:
	movem.l	d0/a0,-(sp)
	move.l	8+4(sp),a0
	move.l	8+8(sp),d0
	bsr	convert_gtk_2_gtk_vol
	movem.l	(sp)+,d0/a0
	rts

gfa_clear_note_block:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	clear_note_block
	move.l	(sp)+,a0
	rts

gfa_paste_note_block:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	paste_note_block
	move.l	(sp)+,a0
	rts

gfa_atomik_35_unpack:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	atomik_35_unpack
	move.l	(sp)+,a0
	rts

gfa_swap_note_block:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	swap_note_block
	move.l	(sp)+,a0
	rts

gfa_transpose_note_block:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	transpose_note_block
	move.l	(sp)+,a0
	rts

gfa_packice_21_unpack:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	packice_21_unpack
	move.l	(sp)+,a0
	rts

gfa_invert_memory:
	movem.l	d0-d1/a0,-(sp)
	move.l	12+4(sp),a0
	move.l	12+8(sp),d0
	move.w	12+12(sp),d1
	bsr	invert_memory
	movem.l	(sp)+,d0-d1/a0
	rts

gfa_affiche_marqueur_sample:
	movem.l	d0-d6,-(sp)
	move.l	28+4(sp),d0
	move.w	28+8(sp),d1
	move.w	28+10(sp),d2
	move.w	28+12(sp),d3
	move.w	28+14(sp),d4
	move.l	28+16(sp),d5
	move.w	28+20(sp),d6
	bsr	affiche_marqueur_sample
	movem.l	(sp)+,d0-d6
	rts

gfa_efface_marqueur_sample:
	movem.l	d0-d6,-(sp)
	move.l	28+4(sp),d0
	move.w	28+8(sp),d1
	move.w	28+10(sp),d2
	move.w	28+12(sp),d3
	move.w	28+14(sp),d4
	move.l	28+16(sp),d5
	move.w	28+20(sp),d6
	bsr	efface_marqueur_sample
	movem.l	(sp)+,d0-d6
	rts

gfa_copy_sample_8_2_16:
	movem.l	d0/a0-a1,-(sp)
	move.l	12+4(sp),a0
	move.l	12+8(sp),a1
	move.l	12+12(sp),d0
	bsr	copy_sample_8_2_16
	movem.l	(sp)+,d0/a0-a1
	rts

gfa_copy_sample_16_2_8:
	movem.l	d0/a0-a1,-(sp)
	move.l	12+4(sp),a0
	move.l	12+8(sp),a1
	move.l	12+12(sp),d0
	bsr	copy_sample_16_2_8
	movem.l	(sp)+,d0/a0-a1
	rts

gfa_convert_gtk_2_nt:
	movem.l	d0/a0/a1/a3,-(sp)
	move.l	16+4(sp),a0
	move.l	16+8(sp),a1
	move.l	16+12(sp),a3
	move.w	16+16(sp),d0
	bsr	convert_gtk_2_nt
	movem.l	(sp)+,d0/a0/a1/a3
	rts

gfa_cherche_volume_sample:
	movem.l	d1-d2/a0,-(sp)
	move.l	12+4(sp),a0
	move.l	12+8(sp),d1
	move.w	12+12(sp),d2
	bsr	cherche_volume_sample
	movem.l	(sp)+,d1-d2/a0
	rts

gfa_change_volume_sample:
	movem.l	d0-d4/a0,-(sp)
	move.l	24+4(sp),a0
	move.l	24+8(sp),d0
	move.l	24+12(sp),d1
	move.l	24+16(sp),d2
	move.l	24+20(sp),d3
	move.w	24+24(sp),d4
	bsr	change_volume_sample
	movem.l	(sp)+,d0-d4/a0
	rts

gfa_mixage_samples:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	mixage_samples
	move.l	(sp)+,a0
	rts

gfa_affiche_vumetre:
	movem.l	d0-d4,-(sp)
	move.w	20+4(sp),d0
	move.w	20+6(sp),d1
	move.w	20+8(sp),d2
	move.w	20+10(sp),d3
	move.w	20+12(sp),d4
	bsr	affiche_vumetre
	movem.l	(sp)+,d0-d4
	rts

gfa_change_sample_frequency:
	movem.l	d0-d3/a0-a1,-(sp)
	move.l	24+4(sp),a0
	move.l	24+8(sp),a1
	move.l	24+12(sp),d0
	move.l	24+16(sp),d1
	move.w	24+20(sp),d2
	move.w	24+22(sp),d3
	bsr	change_sample_frequency
	movem.l	(sp)+,d0-d3/a0-a1
	rts

gfa_trans_fourier:
	movem.l	d1-d4/a0-a1,-(sp)
	move.l	24+4(sp),a0
	move.l	24+8(sp),d1
	move.l	24+12(sp),d2
	move.l	24+16(sp),d3
	move.w	24+20(sp),d4
	move.l	24+22(sp),a1
	bsr	trans_fourier
	movem.l	(sp)+,d1-d4/a0-a1
	rts

gfa_fx_delay:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	fx_delay
	move.l	(sp)+,a0
	rts

gfa_convert_dtm_2_gtk:
	movem.l	d0/a0-a1,-(sp)
	move.l	12+4(sp),a0
	move.l	12+8(sp),a1
	move.l	12+12(sp),d0
	bsr	convert_dtm_2_gtk
	movem.l	(sp)+,d0/a0-a1
	rts

gfa_dtm_next_chunk:
	movem.l	a0-a1,-(sp)
	move.l	8+4(sp),a0
	move.l	8+8(sp),a1
	bsr	dtm_next_chunk
	movem.l	(sp)+,a0-a1
	rts

gfa_convert_gtk_2_s3m:
	movem.l	d0-d1/a0-a1,-(sp)
	move.l	16+4(sp),a0
	move.l	16+8(sp),a1
	move.w	16+12(sp),d0
	move.w	16+14(sp),d1
	bsr	convert_gtk_2_s3m
	movem.l	(sp)+,d0-d1/a0-a1
	rts

gfa_convert_ft2_2_gtk:
	movem.l	d0-d1/a0-a1,-(sp)
	move.l	16+4(sp),a0
	move.l	16+8(sp),a1
	move.w	16+12(sp),d0
	move.w	16+14(sp),d1
	bsr	convert_ft2_2_gtk
	movem.l	(sp)+,d0-d1/a0-a1
	rts

gfa_absolu_2_delta:
	movem.l	d0-d1/a0,-(sp)
	move.l	12+4(sp),a0
	move.l	12+8(sp),d0
	move.w	12+12(sp),d1
	bsr	absolu_2_delta
	movem.l	(sp)+,d0-d1/a0
	rts

gfa_delta_2_absolu:
	movem.l	d0-d1/a0,-(sp)
	move.l	12+4(sp),a0
	move.l	12+8(sp),d0
	move.w	12+12(sp),d1
	bsr	delta_2_absolu
	movem.l	(sp)+,d0-d1/a0
	rts

gfa_bmove:
	movem.l	d0/a0-a1,-(sp)
	move.l	12+4(sp),a0
	move.l	12+8(sp),a1
	move.l	12+12(sp),d0
	bsr	quick_bmove
	movem.l	(sp)+,d0/a0-a1
	rts

gfa_fx_stereo_flanger:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	fx_stereo_flanger
	move.l	(sp)+,a0
	rts

gfa_packice_24_unpack:
	movem.l	a0/a3,-(sp)
	move.l	8+4(sp),a0
	bsr	packice_24_unpack
	movem.l	(sp)+,a0/a3
	rts

gfa_fx_reverberation:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	fx_reverberation
	move.l	(sp)+,a0
	rts

gfa_grise_surface:
	movem.l	d0-d3,-(sp)
	move.w	16+4(sp),d0
	move.w	16+6(sp),d1
	move.w	16+8(sp),d2
	move.w	16+10(sp),d3
	bsr	grise_surface
	movem.l	(sp)+,d0-d3
	rts

gfa_convert_stereo16:
	movem.l	d0-d2/a0-a1,-(sp)
	move.l	20+4(sp),a0
	move.l	20+8(sp),a1
	move.l	20+12(sp),d0
	move.w	20+16(sp),d1
	move.w	20+18(sp),d2
	bsr	convert_stereo16
	movem.l	(sp)+,d0-d2/a0-a1
	rts

gfa_start_song_recording:
	bsr	start_song_recording
	rts

gfa_stop_song_recording:
	bsr	stop_song_recording
	rts

gfa_fx_compression:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	bsr	fx_compression
	move.l	(sp)+,a0
	rts

gfa_affiche_image_presentation:
	movem.l	d0-d4/a0,-(sp)
	move.l	24+4(sp),a0
	move.w	24+8(sp),d0
	move.w	24+10(sp),d1
	move.w	24+12(sp),d2
	move.w	24+14(sp),d3
	move.w	24+16(sp),d4
	bsr	affiche_image_presentation
	movem.l	(sp)+,d0-d4/a0
	rts

gfa_find_key_function:
	movem.l	d1-d2/a0-a4,-(sp)
	move.l	28+4(sp),d0
	move.l	28+8(sp),d1
	move.w	28+12(sp),d2
	move.l	28+14(sp),a0
	move.l	28+18(sp),a1
	move.l	28+22(sp),a2
	move.l	28+26(sp),a3
	move.l	28+30(sp),a4
	bsr	find_key_function
	movem.l	(sp)+,d1-d2/a0-a4
	rts

gfa_find_used_samples_and_instruments:
	movem.l	a0-a3,-(sp)
	move.l	16+4(sp),a0
	move.l	16+8(sp),a1
	move.l	16+12(sp),a2
	move.l	16+16(sp),a3
	bsr	find_used_samples_and_instruments
	movem.l	(sp)+,a0-a3
	rts

gfa_speedpacker_unpack:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	60+4(sp),speedpacker_adr
	pea	speedpacker_unpack
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts



*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*

*============================================================================*
*	Routine de relocation des routines, servant au GfA Basic.	*
*	Ce sous-programme est appelÇ une seule fois au dÇbut, avant	*
*	toute opÇration.					*
*	Fournir l'adresse du PRG chargÇ en 4(sp)			*
*	Renvoie l'adresse de 'adrecr' dans d0			*
*============================================================================*
relocation:   
	movem.l	d1/a0-a2,-(sp)
	move.l	16+4(sp),a0	; 4(sp) : adresse du PRG
	move.l	2(a0),d0
	add.l	6(a0),d0
	add.l	14(a0),d0
	adda.l	#$1c,a0
	move.l	a0,d1
	movea.l	a0,a1
	movea.l	a1,a2
	adda.l	d0,a1
	move.l	(a1)+,d0
	adda.l	d0,a2
	add.l	d1,(a2)
	clr.l	d0
relocloop:	move.b	(a1)+,d0
	beq.s	reloc_end
	cmp.b	#1,d0
	beq.s	reloc_nxt
	adda.l	d0,a2
	add.l	d1,(a2)
	bra.s	relocloop
reloc_nxt:	adda.l	#$fe,a2
	bra.s	relocloop
reloc_end:
	clr.w	oldcolcurs
	clr.w	oldposcurs
	lea	adrecr(pc),a0
	move.l	a0,d0
	movem.l	(sp)+,d1/a0-a2
	rts



*============================================================================*
*	UNPACK source for SPACKERv3   (C)THE FIREHAWKS'92                 *
*	-------------------------------------------------                 *
*	in    a0: even address start packed block (pour .unpack)          *
*	out   d0: original length or 0 if not SPv3 packed                 *
*	=================================================                 *
*	Use AUTO_SP3.PRG for multiblk packed files                        *
*============================================================================*
speedpacker_unpack:
	move.l	speedpacker_adr(pc),a0

.unpack:
	moveq	#0,d0
	movem.l	d0-a6,-(sp)
	lea	sp3_53(pc),a6
	movea.l	a0,a1
	cmpi.l	#'SPv3',(a1)+
	bne.s	sp3_02
	tst.w	(a1)
	bne.s	sp3_02
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(sp)
	movea.l	a0,a2
	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(sp),a1
	lea	sp3_58-sp3_53(a6),a3
	moveq	#128-1,d0
sp3_01:	move.l	(a2)+,(a3)+
	dbf	d0,sp3_01
	suba.l	a2,a3
	move.l	a3,-(sp)
	bsr.s	sp3_03
	bsr	sp3_21
	move.b	-(a0),d0
	adda.l	(sp)+,a0
	move.b	d0,(a0)+
	lea	sp3_58-sp3_53(a6),a2
	bsr	sp3_22
	bsr	sp3_15
sp3_02:	movem.l	(sp)+,d0-a6
	rts
sp3_03:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_04
	move.w	$FFFF8240.W,2(a6)
	btst	#1,$FFFF8260.W
	bne.s	sp3_04
	swap	d5
sp3_04:	clr.w	d5
	move.w	-(a0),d6
	lea	sp3_54-sp3_53(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
sp3_05:	cmp.b	d6,d3
	bne.s	sp3_06
	addq.w	#2,d3
sp3_06:	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,sp3_05
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	sp3_57-sp3_53(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
sp3_07:	move.b	-(a0),-(a3)
	dbf	d4,sp3_07
	move.b	-(a0),-(a3)
	beq.s	sp3_08
	suba.w	d4,a0
sp3_08:	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
sp3_09:	bsr.s	sp3_10
	bsr.s	sp3_10
	dbf	d2,sp3_09
	rts
sp3_10:	not.w	d4
	add.b	d7,d7
	bne.s	sp3_11
	move.b	-(a0),d7
	addx.b	d7,d7
sp3_11:	bcs.s	sp3_12
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts
sp3_12:	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	beq.s	sp3_13
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	move.b	d0,-(a3)
	rts
sp3_13:	moveq	#2,d1
	bsr	sp3_44
	move.w	sp3_55-sp3_53(a6),d1
	add.w	d0,d0
	beq.s	sp3_14
	move.w	sp3_55+2-sp3_53(a6),d1
sp3_14:	or.w	d1,d0
	move.w	d0,-(a3)
	rts
sp3_15:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_16
	move.w	2(a6),$FFFF8240.W
sp3_16:	tst.w	d6
	bpl.s	sp3_20
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(sp),a3
sp3_17:	moveq	#3,d6
sp3_18:	move.w	(a2)+,d0
	moveq	#3,d5
sp3_19:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,sp3_19
	dbf	d6,sp3_18
	cmpa.l	a2,a3
	blt.s	sp3_20
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	sp3_17
sp3_20:	rts
sp3_21:	move.b	-(a0),-(a1)
sp3_22:	swap	d5
	beq.s	sp3_23
	move.w	d5,$FFFF8240.W
sp3_23:	lea	sp3_56+2-sp3_53(a6),a3
	cmpa.l	a0,a2
	blt.s	sp3_25
	rts
sp3_24:	adda.w	d3,a3
sp3_25:	add.b	d7,d7
	bcc.s	sp3_28
	beq.s	sp3_27
sp3_26:	move.w	(a3),d3
	bmi.s	sp3_24
	bra.s	sp3_29
sp3_27:	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	sp3_26
sp3_28:	move.w	-(a3),d3
	bmi.s	sp3_24
sp3_29:	ext.w	d3
	jmp	sp3_30(pc,d3.w)
sp3_30:	bra.s	sp3_30
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_37
	bra.s	sp3_36
	bra.s	sp3_32
	bra.s	sp3_33
	bra.s	sp3_31
	bra.s	sp3_34
	bra.s	sp3_21
sp3_31:	move.b	(a5),-(a1)
	bra.s	sp3_22
sp3_32:	bsr.s	sp3_43
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_33:	bsr.s	sp3_43
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_34:	moveq	#3,d1
	bsr.s	sp3_44
	lsr.w	#1,d0
	bcc.s	sp3_35
	not.w	d0
sp3_35:	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	sp3_22
sp3_36:	lea	sp3_52-2-sp3_53(a6),a4
	bsr.s	sp3_48
	addi.w	#16,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	sp3_22
sp3_37:	moveq	#3,d1
	bsr.s	sp3_44
	tst.w	d0
	beq.s	sp3_38
	addq.w	#5,d0
	bra.s	sp3_40
sp3_38:	move.b	-(a0),d0
	beq.s	sp3_39
	addi.w	#20,d0
	bra.s	sp3_40
sp3_39:	moveq	#13,d1
	bsr.s	sp3_44
	addi.w	#276,d0
sp3_40:	move.w	d0,d3
	add.w	d3,d3
sp3_41:	lea	sp3_52-sp3_53(a6),a4
	bsr.s	sp3_48
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
sp3_42:	move.b	-(a3),-(a1)
	dbf	d3,sp3_42
	bra	sp3_22
sp3_43:	moveq	#0,d1
	move.b	(a3),d1
sp3_44:	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	sp3_47
sp3_45:	add.b	d7,d7
	beq.s	sp3_46
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_46:	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_47:	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	sp3_45
	rts
sp3_48:	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	sp3_44
	tst.b	d6
	beq.s	sp3_51
	move.w	d0,d4
	andi.w	#$FFF0,d4
	andi.w	#$000F,d0
	beq.s	sp3_50
	lsr.w	#1,d0
	beq.s	sp3_49
	roxr.b	#1,d7
	bcc.s	sp3_50
	move.b	d7,(a0)+
	moveq	#-128,d7
	bra.s	sp3_50
sp3_49:	moveq	#2,d1
	bsr.s	sp3_44
	add.w	d0,d0
	or.w	d4,d0
	bra.s	sp3_51
sp3_50:	lea	sp3_54-sp3_53(a6),a3
	or.b	(a3,d0.w),d4
	move.w	d4,d0
sp3_51:	add.w	18(a4),d0
	rts

	DC.W	3
sp3_52:	DC.W	4,5,7,8,9,10,11,12
	DC.W	-16
	DC.W	0,32,96,352,864,1888,3936,8032

sp3_53:	DS.L	1
sp3_54:	DS.B	8
sp3_55:	DS.W	2*64
sp3_56:	DS.W	2
	DS.B	1
sp3_57:	DS.B	1
	DS.B	2*64
sp3_58:	DS.B	512



*============================================================================*
*	Trouve les samples et les instruments utilisÇs dans le module.	*
*	Regarde en fait si les longueurs et les noms ne sont pas Ö 0.	*
*	a0 = pointeur sur les adresses des samples			*
*	a1 = pointeur sur les chunks instruments (les uns Ö la suite	*
*	     des autres)					*
*	a2 = pointeur sur un tableau de flags (char) pour les samples.	*
*	     Ce tableau doit dÇjÖ àtre initialisÇ Ö 0.		*
*	a3 = idem, pour les instruments				*
*	Renvoie le nombre de samples dans le mot fort de d0, et le	*
*	nombre d'instruments dans le mot faible.			*
*============================================================================*
find_used_samples_and_instruments:
	movem.l	d1-a6,-(sp)
	moveq	#0,d0		; d0 = nombre de spl/instr utilisÇs

;--- Cherche les samples utilisÇs --------------------------------------------
	moveq	#0,d1
	move.w	#NBRSAMPLES_MAXI-1,d1	; d1 = Sample courant

.spl_loop:
	move.l	(a0,d1.w*4),a4	; a4 = adresse du chunk du sample
	tst.l	length_s(a4)
	bgt.s	.spl_ok		; Longueur > 0: ok

	lea	name_s(a4),a5	; a5 = adresse du nom
	moveq	#28-1,d2		; 28 caractäres Ö tester
.splname_loop:
	cmp.b	#' ',(a5)+
	bne.s	.spl_ok		; Nom utilisÇ: ok
	dbra	d2,.splname_loop
	bra.s	.spl_loopend

.spl_ok:	st	(a2,d1.w)
	addq.w	#1,d0

.spl_loopend:
	subq.w	#1,d1
	bgt.s	.spl_loop

;--- Cherche les instruments utilisÇs ----------------------------------------
	swap	d0		; Nbr d'instr en mot faible
	lea	(a1,next_i),a4	; Pointe sur l'instrument 1
	moveq	#1,d1		; d1 = instrument courant

.instr_loop:
	lea	name_i(a4),a5	; a5 = adresse du nom
	moveq	#28-1,d2		; 28 caractäres Ö tester
.instrname_loop:
	cmp.b	#' ',(a5)+
	bne.s	.instr_ok		; Nom utilisÇ: ok
	dbra	d2,.instrname_loop

	lea	splnum_i(a4),a5
	moveq	#0,d3
	moveq	#127,d2		; NumÇro de la note testÇe
.instr_splloop:
	move.b	(a5,d2.w*2),d3
	tst.b	(a2,d3.w)		; Utilise un sample utilisÇ ?
	beq.s	.instr_nextspl
	tst.l	([a0,d3.w*4],length_s)	; Longueur du sample > 0 ?
	bgt.s	.instr_ok
.instr_nextspl:
	dbra	d2,.instr_splloop
	bra.s	.instr_loopend

.instr_ok:	st	(a3,d1.w)
	addq.w	#1,d0

.instr_loopend:
	add.w	#next_i,a4
	addq.w	#1,d1
	cmp.w	#NBRINSTR_MAXI-1,d1
	ble.s	.instr_loop

	movem.l	(sp)+,d1-a6
	rts




*============================================================================*
*	DÇcode un code clavier et cherche le numÇro de la fonction	*
*	appelÇe.						*
*	d0 = code clavier.l (Crawcin + Kbshift sur l'octet fort)	*
*	d1 = Etat.l: variables play% en mot fort, edit% en mot faible.	*
*	d2 = Nombre.w de fonctions				*
*	a0 = adresse des masques des fonctions			*
*	a1 = adresse des comparateurs des fonctions			*
*	a2 = adresse des codes ascii pour la 1ere ligne de touches	*
*	a3 = idem, 2äme					*
*	a4 = idem, 3äme					*
*	Au retour:						*
*	d0 contient l'adresse d'une structure:			*
*	L : keycode complet					*
*	W : numÇro de touche (si groupement)			*
*	W : numÇro de fonction (-1 si pas trouvÇe)			*
*============================================================================*
find_key_function:
	movem.l	d1-a6,-(sp)



; Retrouve le code clavier complet 

;--- Repositionnement des bits -----------------------------------------------
; Shift
	btst	#24,d0		; Shift droit ?
	bne.s	.shiftok
	btst	#25,d0		; Shift gauche ?
	beq.s	.shiftend
.shiftok:	bset	#8,d0
.shiftend:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Mode utilisÇ

	tst.w	d1		; Edit ?
	beq.s	.playtst
	bset	#15,d0
.playtst:	swap	d1		; Play ?
	tst.w	d1
	beq.s	.playtend
	bset	#14,d0
.playtend:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Conversion du code ascii minuscules -> majuscules

	cmp.b	#'a',d0
	blt.s	.lowerend
	cmp.b	#'z',d0
	bgt.s	.lowerend
	and.b	#%11011111,d0
.lowerend:



;--- Modifie le code scan, en cas d'appui avec shift ou ctrl -----------------

	move.l	d0,d7
	swap	d7
	and.w	#$00FF,d7		; d7 = code scan
	moveq	#0,d6		; d6 = numÇro de touche (pour les groupements)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Ctrl + gauche ou droite

	cmp.b	#115,d7		; Fläche gauche
	bne.s	.right
	move.b	#75,d7
	bra	findkeyfunc_scancodeend

.right:	cmp.b	#116,d7		; Fläche droite
	bne.s	.rightend
	move.b	#77,d7
	bra	findkeyfunc_scancodeend
.rightend:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Touches de fonction

	cmp.b	#59,d7		; F1 Ö F10
	blt.s	.f11f20
	cmp.b	#68,d7
	bgt.s	.f11f20
	bset	#10,d0
	move.w	d7,d6
	sub.w	#59,d6		; Donne la position de la touche
	bra.s	findkeyfunc_scancodeend

.f11f20	cmp.b	#84,d7		; F11 Ö F20 ou shift + F1 Ö F10
	blt.s	.f11f20end
	cmp.b	#93,d7
	bgt.s	.f11f20end
	bset	#10,d0
	sub.w	#84-59,d7		; RÇtablit en F1 Ö F10
	bset	#8,d0		; On force Çgalement shift
	move.w	d7,d6
	sub.w	#59,d6		; Donne la position de la touche
	bra.s	findkeyfunc_scancodeend
.f11f20end:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Correction ASCII pour les lettres

	cmp.b	#16,d7		; Premiäre rangÇe de lettres
	blt.s	.row1end
	cmp.b	#25,d7
	bgt.s	.row1end
	move.b	-16(a2,d7.w),d0	; Cherche dans la table le code ASCII
	bra.s	findkeyfunc_scancodeend
.row1end:

	cmp.b	#30,d7		; Deuxiäme rangÇe de lettres
	blt.s	.row2end
	cmp.b	#39,d7
	bgt.s	.row2end
	move.b	-30(a3,d7.w),d0	; Cherche dans la table le code ASCII
	bra.s	findkeyfunc_scancodeend
.row2end:

	cmp.b	#44,d7		; Troisiäme rangÇe de lettres
	blt.s	.row3end
	cmp.b	#50,d7
	bgt.s	.row3end
	move.b	-44(a4,d7.w),d0	; Cherche dans la table le code ASCII
	bra.s	findkeyfunc_scancodeend
.row3end:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; PavÇ numÇrique

	lea	numericpad_scancodes(pc),a5
	moveq	#0,d6
.padloop:	cmp.b	(a5)+,d7
	bne.s	.padcont
	bset	#9,d0
	bra.s	findkeyfunc_scancodeend
.padcont:	addq.w	#1,d6
	cmp.w	#16,d6		; 16 touches en tout
	blt.s	.padloop
	moveq	#0,d6		; Pas trouvÇ

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
findkeyfunc_scancodeend:
	swap	d0		; Remet le bon code scan
	move.b	d7,d0
	swap	d0
	move.l	d0,keycode_result	; Sauve-moi tout áa
	move.w	d6,keycode_result+4



; Recherche de la fonction 
findkeyfunc_search:

	moveq	#0,d7		; NumÇro de la fonction testÇe
	subq.w	#1,d2		; Compteur de fonctions

.loop:
	move.l	(a0)+,d6		; 1äre tentative
	move.l	(a1)+,d5
	beq.s	.tente2
	and.l	d0,d6
	cmp.l	d5,d6
	beq.s	.found
.tente2:	move.l	(a0)+,d6		; 2äme tentative
	move.l	(a1)+,d5
	beq.s	.echec
	and.l	d0,d6
	cmp.l	d5,d6
	beq.s	.found
.echec:	addq.w	#1,d7
	dbra	d2,.loop

	move.w	#-1,keycode_result+6	; On, n'a rien trouvÇ
	bra.s	findkeyfunc_end

.found:
	move.w	d7,keycode_result+6	; Sauve le numÇro de la fonction

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

findkeyfunc_end:
	move.l	#keycode_result,d0	; Fournit l'adresse des rÇsultats

	movem.l	(sp)+,d1-a6
	rts



*============================================================================*
*	Affiche l'image de prÇsentation.				*
*	a0 = adresse de l'image avec son en-tàte			*
*	d0 = abscisse.w d'affichage, en colonne			*
*	d1 = ligne.w d'affichage				*
*	d2 = ligne.w dans l'image				*
*	d3 = nombre.w de lignes Ö afficher			*
*	d4 = -1.w si on doit sauter des lignes, 0 sinon		*
*============================================================================*
affiche_image_presentation:
	movem.l	d0-a6,-(sp)

	move.l	adrecr(pc),a1
	mulu.w	linewidth(pc),d1
	add.l	d1,a1
	move.w	d0,d1
	and.w	#1,d1		; d1 = paritÇ de la colonne.
	lsl.w	#2,d0
	and.w	#-8,d0
	add.w	d1,d0
	add.w	d0,a1		; a1 = adresse d'affichage

	mulu.w	2(a0),d2
	lea	8(a0,d2.l),a3	; a3 = adresse de l'image Ö la bonne ligne

	mulu.w	#6,d1
	addq.w	#1,d1
	move.w	d1,d0		; d0 = incrÇment d'adresse Çcran. Vaut 1 ou 7
	move.w	d4,d1		; d1 = flag de saut de ligne
	move.w	d3,d5
	subq.w	#1,d5		; d5 = compteur de lignes

.loop_y:
	move.l	a1,a2		; a2 = registre utilisÇ pour afficher les lignes
	move.l	(a0),d6
	lsr.l	#3,d6
	subq.w	#1,d6		; d6 = compteur de colonne
	movem.w	d0-d1/d5,-(sp)

.loop_x:
	movem.w	d0,-(sp)
	move.b	#%10000000,d1	; Masque de pixel: 1<<x
	moveq	#7,d7		; d7 = Compteur de pixels par colonne
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5

.loop_c:				; Transforme 8 pixels en 4 octets de bitplans
	move.b	(a3)+,d0
.plan1:	lsr.b	#1,d0
	bcc.s	.plan2
	add.b	d1,d2
.plan2:	lsr.b	#1,d0
	bcc.s	.plan3
	add.b	d1,d3
.plan3:	lsr.b	#1,d0
	bcc.s	.plan4
	add.b	d1,d4
.plan4:	lsr.b	#1,d0
	bcc.s	.finplans
	add.b	d1,d5
.finplans:
	lsr.b	#1,d1		; DÇcale le masque
	dbra	d7,.loop_c

	move.b	d2,(a2)		; Affiche les bitplans
	move.b	d3,2(a2)
	move.b	d4,4(a2)
	move.b	d5,6(a2)
	movem.w	(sp)+,d0
	add.w	d0,a2
	subq.w	#8,d0
	neg.w	d0
	dbra	d6,.loop_x

	movem.w	(sp)+,d0-d1/d5
	add.w	linewidth(pc),a1
	tst.w	d1
	beq.s	.no_lf		; Si on est en mode pixels rectangles,
	add.l	(a0),a3		; affiche une ligne sur deux.
.no_lf:	dbra	d5,.loop_y

	movem.l	(sp)+,d0-a6
	rts



*============================================================================*
*	Effet de compression					*
*	a0 = Adresse du bloc d'infos				*
*============================================================================*
fx_compression:
	movem.l	d0-a6,-(sp)

;--- Quelques tests de sÇcuritÇ ----------------------------------------------
	tst.l	comp_lonsource(a0)
	ble	fxcomp_end
	tst.l	comp_lonbuffer(a0)
	ble	fxcomp_end
	tst.l	comp_speed(a0)
	ble	fxcomp_end
	tst.l	comp_level(a0)
	ble	fxcomp_end

;--- Initialisation du buffer ------------------------------------------------
	move.l	comp_adrbuffer(a0),a1
	move.l	comp_lonbuffer(a0),d0
	move.l	comp_initvolume(a0),d1
	lsr.l	#1,d0		; Bytes -> samples
	lsr.l	#1,d1		; /65536 -> /32768
	cmp.l	#32767,d1		; Limitation du volume initial
	ble.s	.suite1
	move.l	#32767,d1
.suite1:	move.l	d1,comp_volume(a0)

	subq.l	#1,d0
	swap	d0		; Remplit le buffer avec des samples
fxcomp_initbuf_loop1:			; du volume initial
	swap	d0
fxcomp_initbuf_loop2:
	move.w	d1,(a1)+
	dbra	d0,fxcomp_initbuf_loop2
	swap	d0
	dbra	d0,fxcomp_initbuf_loop1

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	clr.l	comp_possource(a0)
	clr.l	comp_posbuffer(a0)
	move.w	#1,comp_ampli_int(a0)	; Coef d'ampli 1 par dÇfaut
	clr.l	comp_ampli_frac(a0)
	move.l	comp_adrsource(a0),a1	; a1 = adresse de la source
	move.l	comp_adrdest(a0),a2	; a2 = adresse de la destination
	move.l	comp_adrbuffer(a0),a3	; a3 = adresse du buffer
	move.l	comp_possource(a0),d1	; d1 = position courante dans le sample
	move.l	comp_posbuffer(a0),d2	; d2 = position courante dans le buffer

; Boucle principale 
fxcomp_mainloop:
	move.l	comp_speed(a0),d0	; d0 = compteur de samples Ö amplifier

;--- Boucle de copie et amplification de sample ------------------------------
	subq.l	#1,d0
	swap	d0
fxcomp_copyloop1:
	swap	d0
fxcomp_copyloop2:

	cmp.w	#2,comp_ressource(a0)	; Prend le nouveau sample dans d3
	beq.s	.s16bits
	move.b	(a1)+,d3
	lsl.w	#8,d3
	addq.l	#1,d1		; IncrÇmente la position du sample
	bra.s	.sfin
.s16bits:	move.w	(a1)+,d3
	addq.l	#2,d1		; IncrÇmente la position du sample
.sfin:	ext.l	d3

	move.w	d3,d5		; Valeur absolue de d5, limitÇe Ö 32767
	bpl.s	.absfin		; Positif, c'est fini
	neg.w	d5		; Renverse le signe
	bpl.s	.absfin		; Si c'est encore nÇgatif, c'est 32768
	move.w	#32767,d5
.absfin:	move.w	d5,(a3,d2.l)	; Insäre dans le buffer

	addq.l	#2,d2		; IncrÇmente la position du buffer
	cmp.l	comp_lonbuffer(a0),d2
	blt.s	.incbuffin
	moveq	#0,d2
.incbuffin:

	move.w	d3,d5		; Amplifie le sample
	muls.w	comp_ampli_int(a0),d5	; d5 = partie entiäre amplifiÇe
	moveq	#0,d6		; On ne prend que le frac de poids fort, áa suffit
	move.w	comp_ampli_frac(a0),d6
	muls.l	d6,d3
	swap	d3
	ext.l	d3
	add.l	d5,d3		; d3 contient maintenant le sample amplifiÇ

	cmp.l	#32767,d3		; Limite le sample
	ble.s	.limsuite
	move.w	#32767,d3		; Attention on ne remet qu'un mot court
	bra.s	.limfin
.limsuite:	cmp.l	#-32767,d3		; -32767 maxi!
	bge.s	.limfin
	move.w	#-32767,d3
.limfin:

	cmp.w	#2,comp_resdest(a0)	; Sauve le nouveau sample
	beq.s	.d16bits
	lsr.w	#8,d3
	move.b	d3,(a2)+
	bra.s	.dfin
.d16bits:	move.w	d3,(a2)+
.dfin:

	cmp.l	comp_lonsource(a0),d1	; On a fini ?
	bge	fxcomp_end

	dbra	d0,fxcomp_copyloop2
	swap	d0
	dbra	d0,fxcomp_copyloop1

;--- RÇÇvaluation du coef d'amplification ------------------------------------
	moveq	#0,d4
	move.l	a3,a4
	move.l	comp_lonbuffer(a0),d0
	lsr.l	#1,d0
	subq.l	#1,d0
	swap	d0
fxcomp_chmaxloop1:
	swap	d0
fxcomp_chmaxloop2:
	cmp.w	(a4)+,d4
	bge.s	.loopend
	move.w	-2(a4),d4
.loopend:	dbra	d0,fxcomp_chmaxloop2
	swap	d0
	dbra	d0,fxcomp_chmaxloop1
	lsl.l	#1,d4		; /32768 -> /65536
	move.l	d4,comp_volume(a0)

	tst.w	d4
	bne.s	.divvolok		; Volume non nul, on peut diviser
	moveq	#1,d3		; S'il est nul, on fait comme si coef 1
	moveq	#0,d6
	bra.s	.divvolf
.divvolok:	move.l	comp_level(a0),d3	; d3 = volume Ö atteindre
	divul.l	d4,d5:d3		; d3 = coef idÇal partie entiäre, d5 = reste
	divu.l	d4,d5:d6		; d6 = coef idÇal partie fractionnaire
.divvolf:	moveq	#0,d4
	move.w	comp_ampli_int(a0),d4	; d4 = ancien coef partie entiäre
	move.l	comp_ampli_frac(a0),d5	; d5 = ancien coef partie fractionnaire
	sub.l	d5,d6		; On va faire 15 * ancien + nouveau
	subx.l	d4,d3		; En fait (nouveau - ancien) + 16 * ancien
	Rept	4
	add.l	d5,d5		; 16 * ancien
	addx.l	d4,d4
	EndR
	add.l	d6,d5		; + (nouveau - ancien)
	addx.l	d3,d4
	Rept	4
	lsr.l	d4		; Divise le tout par 16
	roxr.l	d5
	EndR
	move.w	d4,comp_ampli_int(a0)
	move.l	d5,comp_ampli_frac(a0)

	bra	fxcomp_mainloop

fxcomp_end:
	movem.l	(sp)+,d0-a6
	rts



*============================================================================*
*	Enregistrement d'un module dans un sample			*
*	A exÇcuter apräs avoir lancÇ le DMA dans GTPLAY.PGT		*
*============================================================================*
start_song_recording:
	movem.l	d0-a6,-(sp)
	pea	start_song_recording2
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d0-a6
	rts

start_song_recording2:
	move.l	songrecord_paramadr(pc),a0
.waitloop:	cmp.w	#2,(a0)		; Attend que l'enregistrement ait commencÇ
	blt.s	.waitloop

	move.l	#0*4096,rec_sam_num_buf	; On est sur le 1er buffer

	pea	sample_rec_buffer2+4096
	pea	sample_rec_buffer2(pc)
	move.w	#1,-(sp)
	move.w	#$83,-(sp)		; Fixe le buffer d'enregistrement numÇro 2
	trap	#14
	lea	12(sp),sp

	move.w	#2,-(sp)		; Interruption Ö la fin de l'enregistrement
	move.w	#1,-(sp)		; sur MFP gpi7
	move.w	#$87,-(sp)
	trap	#14
	addq.l	#6,sp

	bclr	#7,$fffffa13.w	; Masque
	move.l	$13C.w,old_it_mfp15
	move.l	#interruption_rec_song,$13C.w
	bset	#7,$fffffa07.w	; MFP-15
	bset	#3,$fffffa17.w	; Fin d'it en soft
	bset	#7,$fffffa13.w	; DÇmasque : c'est parti mon kiki !

	rts



; Interruption (MFP 15) de conversion buffer -> sample 

interruption_rec_song:
	movem.l	d0-a6,-(sp)
	and.w	#%1111100011111111,sr
	bclr	#7,$fffffa0f.w

	move.l	songrecord_paramadr(pc),a0
	cmp.w	#4,(a0)		; Au bout de l'enregistrement ?
	beq	itrecsng_term
	tst.w	songrec_flag	; Ordre d'arràter ?
	beq	itrecsng_term

	lea	sample_rec_buffer(pc),a0	; a0 pointe sur un buffer
	add.l	rec_sam_num_buf(pc),a0	; Celui qu'on a enregistrÇ

	move.l	songrec_adr_buffer,a2	; a2 = adresse du buffer
	move.l	songrec_pos_buffer,d7	; d7 = position courante dans le buffer
	move.w	songrec_bits,d1
	move.w	songrec_stereo,d2
	moveq	#4,d6
	sub.w	d1,d6
	sub.w	d2,d6		; d6 = 2 - ((d1 - 1) + (d2 - 1))
	move.l	#4096,d5
	lsr.l	d6,d5		; d5 = Taille de la copie dans le buffer final
	move.l	d5,d4		; Sauve áa dans d4
	add.l	d7,d5		; ajoute la position courante
	cmp.l	songrec_lon_buffer,d5	; Y aura un dÇbordement ?
	blt.s	itrecsng_nooverflow	; Non, áa baigne

;--- Conversion avec dÇbordement (et Çventuellement bouclage) ----------------
	move.l	songrec_lon_buffer,d5
	sub.l	d7,d5		; d5 = taille qu'on peut placer avant la fin
	sub.l	d5,d4		; d4 = le reste
	move.l	d5,d0
	lsl.l	d6,d0		; Convertit en taille 16 bits/stereo
	lea	(a2,d7.l),a1
	bsr	convert_stereo16	; Conversion
	clr.l	d7
	move.l	d7,songrec_pos_buffer
	move.l	songrec_pos_sample,d6
	add.l	d5,d6
	move.l	d6,songrec_pos_sample
	cmp.l	songrec_lon_sample,d6	; Sample fini ?
	bge.s	itrecsng_term	; Oui, on s'en va
	tst.w	songrec_type	; Bouclage ?
	beq.s	itrecsng_term	; Non, c'est fini alors
	add.l	d0,a0		; Oui, on passe au reste
	tst.l	d4
	bge.s	itrecsng_nxtbuf

;--- Conversion sans dÇbordement ---------------------------------------------
itrecsng_nooverflow:
	lea	(a2,d7.l),a1
	move.l	d4,d0
	lsl.l	d6,d0
	bsr	convert_stereo16	; Conversion
	add.l	d4,d7
	move.l	d7,songrec_pos_buffer
	move.l	songrec_pos_sample,d6
	add.l	d4,d6
	move.l	d6,songrec_pos_sample
	cmp.l	songrec_lon_sample,d6	; Sample fini ?
	blt.s	itrecsng_nxtbuf

;--- Sample fini, arràt de l'interruption ------------------------------------
itrecsng_term:
	or.w	#$2700,sr		; Evite les problämes
	bsr	stopsngrec_rout
	bra.s	itsngrec_fin

;--- Programmation du buffer suivant -----------------------------------------
itrecsng_nxtbuf:
	move.l	#sample_rec_buffer,d0	; Pointe sur le buffer qu'il
	add.l	rec_sam_num_buf(pc),d0	; faut enregistrer la prochaine fois
	move.l	d0,d1		; d0 = adresse de dÇbut du nouveau buffer
	add.l	#4096,d1		; d1 = adresse de fin du nouveau buffer
	move.b	$ffff8901.w,d2	; Signale que c'est le buffer d'enregistrement
	or.b	#%10000000,d2	; qu'on veut fixer
	move.b	d2,$ffff8901.w	; Le nouveau buffer d'enregistrement est en fait
	move.b	d0,$ffff8907.w	; le màme que celui qu'on vient de convertir.
	lsr.w	#8,d0
	move.b	d0,$ffff8905.w
	swap	d0
	move.b	d0,$ffff8903.w
	move.b	d1,$ffff8913.w
	lsr.w	#8,d1
	move.b	d1,$ffff8911.w
	swap	d1
	move.b	d1,$ffff890f.w
	eor.l	#4096,rec_sam_num_buf	; Change le buffer de conversion pour la prochaine fois

itsngrec_fin:
	movem.l	(sp)+,d0-a6
	rte



*============================================================================*
*	Stoppe l'enregistrement du module			*
*============================================================================*
stop_song_recording
	movem.l	d0-a6,-(sp)
	pea	stopsngrec_rout
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d0-a6
	rts

stopsngrec_rout:
	clr.w	-(sp)		; Plus d'interruption Ö la fin de l'enregistrement
	move.w	#1,-(sp)		; sur MFP gpi7
	move.w	#$87,-(sp)
	trap	#14
	addq.l	#6,sp

	bclr	#7,$fffffa07.w	; Annule MFP-15
	bclr	#7,$fffffa13.w	; Masque l'interruption
	move.l	old_it_mfp15,$13C.w

	clr.w	-(sp)		; Arret de l'enregistrement
	move.w	#$88,-(sp)
	trap	#14
	addq.l	#4,sp

	clr.w	songrec_flag	; On a fini

	rts



*============================================================================*
*	Effet de rÇverbÇration				*
*	Les buffers doivent àtre dÇjÖ vides			*
*	a0 = adresse du bloc de donnÇes sur la reverb (voir les Rs avec	*
*	     les rev_ )					*
*============================================================================*
fx_reverberation:
	movem.l	d0-a6,-(sp)

	move.l	a0,d0		; Si a0 = 0, on doit reprendre Ö
	beq	fxrev_reprise	; partir de lÖ ou on en Çtait.
	move.l	#4096,d0		; Tous les 4096 on indique la progression
	move.l	d0,progression_step
	move.l	d0,progression_cpt
	move.l	rev_londest(a0),progression_len
	clr.l	progression_pos

;--- Initialisation ----------------------------------------------------------
	move.w	rev_ncomb(a0),d0
	clr.l	rev_sourcepos(a0)
	clr.l	rev_destpos(a0)
	clr.l	rev_erefpos(a0)
	clr.l	rev_aprpos(a0)
	clr.l	rev_adlypos(a0)
	lea	rev_comb(a0),a1
	move.w	rev_ncomb(a0),d0
	subq.w	#1,d0
.initloop:	clr.l	rev_comb_pos(a1)	; Position dans les buffers de comb filter Ö 0
	clr.l	rev_comb_lpfbuf(a1)	; Micro-buffer 1 sample des LPF pour comb filter effacÇ
	add.w	#rev_comb_end,a1
	dbra	d0,.initloop

;--- Boucle de l'effet -------------------------------------------------------
; Cherche le sample d'entrÇe
fxrev_loop:
	moveq	#0,d1		; Futur sample source
	move.l	rev_sourcepos(a0),d0
	cmp.l	rev_lonsource(a0),d0	; On a dÇpassÇ la fin ?
	bge.s	.sourcefini	; Oui, on laisse le sample dry Ö 0
	cmp.w	#2,rev_resolsource(a0)
	beq.s	.in16bits
	move.b	([rev_adrsource,a0],d0.l),d1	; En 8 bits
	lsl.w	#8,d1
	addq.l	#1,rev_sourcepos(a0)
	bra.s	.sourcefini
.in16bits:	move.w	([rev_adrsource,a0],d0.l),d1	; En 16 bits
	addq.l	#2,rev_sourcepos(a0)
.sourcefini:
	move.l	d1,d3
	swap	d3
	muls.l	rev_drylevel(a0),d2:d3	; Dry level
	move.l	d2,rev_drysample(a0)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; FIR for early relfections
	move.l	rev_adrerefbuf(a0),a1	; a1 = Adresse du buffer
	lea	rev_earlyreflection(a0),a2
	move.l	rev_erefpos(a0),d2	; d2 = Position courante dans le buffer

	move.w	d1,(a1,d2.l)	; L'entrÇe dans le buffer
	addq.l	#2,d2		; Le buffer avance (on fait áa
	cmp.l	rev_lonerefbuf(a0),d2	; au dÇbut cette fois-ci)
	blt.s	.erbufok
	moveq	#0,d2
.erbufok:	move.l	d2,rev_erefpos(a0)

	moveq	#0,d0		; d0 = mixage des taps
	move.w	rev_erefntap(a0),d1
	subq.w	#1,d1		; d1 = compteur de taps
.erefloop:
	move.l	d2,d3
	sub.l	(a2)+,d3			; d3 = position du tap
	bpl.s	.ermodok			; Pas de dÇpassement, ok
	add.l	rev_lonerefbuf(a0),d3		; Sinon modulo taille du buffer
.ermodok:	move.w	(a1,d3.l),d3		; Sample du tap dans d3
	swap	d3
	muls.l	(a2)+,d4:d3		; Ajuste au bon level
	add.l	d4,d0			; Mixe avec la totale

	dbra	d1,.erefloop	; Tap suivant
	move.l	d0,rev_erefspl0(a0)	; Sauve le rÇsultat sans gain, pour les combs
	muls.l	rev_ereflevel(a0),d1:d0
	move.w	d1,rev_erefsample(a0)	; Sauve le sample des rÇflections primaires,
	swap	d0		; Mot fort
	move.w	d0,rev_erefsample+2(a0)	; et mot faible

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Comb filters
	moveq	#0,d5		; Mixage des comb filters
	lea	rev_comb(a0),a1	; a1 pointe sur les infos Comb Filters
	move.w	rev_ncomb(a0),d0
	subq.w	#1,d0		; d0 = compteur de comb
.combloop:
	move.l	rev_comb_adrbuf(a1),a2	; a2 = adresse du buffer comb
	move.l	rev_comb_pos(a1),d1		; d1 = position dans le buffer
	move.l	d1,d2
	sub.l	rev_comb_delay(a1),d2		; d2 = position avec delay
	bpl.s	.combok
	add.l	rev_comb_lonbuf(a1),d2
.combok:	move.w	(a2,d2.l),d2		; d2 = sample en sortie de comb
	ext.l	d2
	add.l	d2,d5			; Mixe avec la totale

	move.l	rev_comb_lpfbuf(a1),d3	; Prend le sample dans le micro-buffer LPF
	muls.l	rev_comb_lpfg(a1),d4:d3	; Gain LPF
	move.w	d4,d3			; Rotation 16 bits vers la gauche
	swap	d3			; de d4:d3 (on garde que les bits 16-47)
	add.l	d2,d3			; Mixe avec la sortie de comb

	move.l	d3,rev_comb_lpfbuf(a1)	; On sauve le rÇsultat dans le
					; buffer LPF, en long
	muls.l	rev_comb_fdbk(a1),d4:d3	; Pouf, feedback
	move.w	d4,d3
	swap	d3
	add.l	rev_erefspl0(a0),d3		; On mixe avec l'Early Reflection
	cmp.l	#MAX_SWORD,d3		; On s'assure
	ble.s	.mixcok1			; qu'on tient bien dans 16
	move.w	#MAX_SWORD,d3		; bits, sinon on coupe au-
.mixcok1:	cmp.l	#MIN_SWORD,d3		; dessus et en au-dessous.
	bge.s	.mixcok2
	move.w	#MIN_SWORD,d3
.mixcok2:	move.w	d3,(a2,d1.l)		; Pof, dans le buffer

	addq.l	#2,d1			; Le buffer avance
	cmp.l	rev_comb_lonbuf(a1),d1
	blt.s	.cbufok
	moveq	#0,d1
.cbufok:	move.l	d1,rev_comb_pos(a1)

	add.w	#rev_comb_end,a1		; Comb suivant
	dbra	d0,.combloop

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; All Pass Unit Reverberator
	move.l	d5,d0		; d5 contenait l'entrÇe
	muls.l	rev_aprgneg(a0),d1:d0	; Traite d0 pour le dry de l'APUR
	swap	d1		; Entasse áa dans d1 qui servira de mixage
	swap	d0		; Rotation gauche de 16 bits de d1:d0
	move.w	d0,d1		;

	move.l	rev_adraprbuf(a0),a1	; a1 = adresse du buffer
	move.l	rev_aprpos(a0),d0	; d0 = position courante
	move.l	d0,d2
	sub.l	rev_aprdelay(a0),d2	; d2 = position+delay
	bpl.s	.apurok
	add.l	rev_lonaprbuf(a0),d2
.apurok:	move.w	(a1,d2.l),d2
	swap	d2		; d2 contient le sample retardÇ

	move.l	d2,d3
	muls.l	rev_aprg(a0),d4:d3	; Feedback
	add.l	d5,d4		; Mixe avec l'entrÇe
	cmp.l	#MAX_SWORD,d4	; On s'assure
	ble.s	.mxaprok1		; qu'on tient bien dans 16
	move.w	#MAX_SWORD,d4	; bits, sinon on coupe au-
.mxaprok1:	cmp.l	#MIN_SWORD,d4	; dessus et en au-dessous.
	bge.s	.mxaprok2
	move.w	#MIN_SWORD,d4
.mxaprok2:	move.w	d4,(a1,d0.l)	; Pof, dans le buffer

	addq.l	#2,d0		; Le buffer avance
	cmp.l	rev_lonaprbuf(a0),d0
	blt.s	.aprbufok
	moveq	#0,d0
.aprbufok:	move.l	d0,rev_aprpos(a0)

	muls.l	rev_apr1mg2(a0),d4:d2	; Sortie du delay, recalibrÇ
	add.l	d1,d4		; Mixe pour la sortie
	cmp.l	#MAX_SWORD,d4	; On s'assure
	ble.s	.mxaprok3		; qu'on tient bien dans 16
	move.w	#MAX_SWORD,d4	; bits, sinon on coupe au-
.mxaprok3:	cmp.l	#MIN_SWORD,d4	; dessus et en au-dessous.
	bge.s	.mxaprok4
	move.w	#MIN_SWORD,d4
.mxaprok4:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	move.l	rev_adlypos(a0),d0	; Position dans le delay d'alignement
	move.l	rev_adradlybuf(a0),a1
	move.w	d4,(a1,d0.l)	; Le rÇsultat de l'APR dans le buffer

	move.l	d0,d1
	sub.l	rev_adlydelay(a0),d1
	bpl.s	.adlyok
	add.l	rev_lonadlybuf(a0),d1
.adlyok:	move.w	(a1,d1.l),d1
	swap	d1
	muls.l	rev_revlevel(a0),d2:d1	; d2 = sortie du delay d'alignement

	addq.l	#2,d0		; Le buffer avance
	cmp.l	rev_lonadlybuf(a0),d0
	blt.s	.adbufok
	moveq	#0,d0
.adbufok:	move.l	d0,rev_adlypos(a0)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Mixage final
	add.l	rev_erefsample(a0),d2
	add.l	rev_drysample(a0),d2
	cmp.l	#MAX_SWORD,d2	; On s'assure
	ble.s	.mxfinok1		; qu'on tient bien dans 16
	move.w	#MAX_SWORD,d2	; bits, sinon on coupe au-
.mxfinok1:	cmp.l	#MIN_SWORD,d2	; dessus et en au-dessous.
	bge.s	.mxfinok2
	move.w	#MIN_SWORD,d2
.mxfinok2:
	move.l	rev_destpos(a0),d0	; On stoque le rÇsultat dans la destination
	cmp.l	rev_londest(a0),d0	; Mais vÇrifie d'abord que c'est pas fini
	bge.s	fxrev_fin		; Sinon on n'a plus rien Ö faire lÖ
	moveq	#0,d1
	move.w	rev_resoldest(a0),d1	; d1.l = nombre d'octets par sample (utilisÇ apräs)
	cmp.w	#2,d1
	beq.s	.fin16b
	asr.w	#8,d2
	move.b	d2,([rev_adrdest,a0],d0.l)
	addq.l	#1,d0
	bra	.fin816b
.fin16b:	move.w	d2,([rev_adrdest,a0],d0.l)
	addq.l	#2,d0
.fin816b:	move.l	d0,rev_destpos(a0)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Arràt momentanÇ pour affichage de la progression
	sub.l	d1,progression_cpt
	bgt	fxrev_loop
	move.l	progression_step(pc),d1
	move.l	d1,progression_cpt
	add.l	d1,progression_pos
	movem.l	d0-d7/a0-a6,progression_savedreg
	bra.s	fxrev_break

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Reprise apräs affichage de la progression
fxrev_reprise:
	movem.l	progression_savedreg,d0-d7/a0-a6
	bra	fxrev_loop

fxrev_fin:
	move.l	progression_len(pc),progression_pos	; Signale que tout est fini
fxrev_break:
	movem.l	(sp)+,d0-a6
	rts



*============================================================================*
*	Effet de stereo flanger				*
*	Les buffers doivent àtre dÇjÖ vides			*
*	a0 = adresse du bloc de donnÇes sur le flanger (voir les Rs avec	*
*	     les fl_ )					*
*	  - L : Adresse du sample left				*
*	  - L : Adresse du sample right				*
*	  - L : Adresse du sample destination			*
*	  - L : Adresse du buffer gauche				*
*	  - L : Adresse du buffer droit				*
*	  - L : Adresse de la table des sinus			*
*	  - L : Longueur du sample source left, en octets		*
*	  - L : Longueur du sample source right, en octets		*
*	  - L : Longueur du sample destination, en octets		*
*	  - L : Longueur du buffer 16 bits gauche (et droit), en octets	*
*	  - W : Nombre d'octets par sample (source left)		*
*	  - W : Nombre d'octets par sample (source right)		*
*	  - W : Nombre d'octets par sample (destination)		*
*	  - W : Flags : +1 = dest left,				*
*	                +2 = dest right,				*
*	                +4 = mixage mono si +1 et +2 sont mis		*
*	  - L : Feedback left -> left (/65536)			*
*	  - L : Feedback left -> right(/65536)			*
*	  - L : Feedback right -> left (/65536)			*
*	  - L : Feedback right -> right (/65536)			*
*	  - L : Dry level left				*
*	  - L : Dry level right				*
*	  - L : Wet level left				*
*	  - L : Wet level right				*
*	  - L : Frequence du flanger (65536*4096/FreqEch -> 1 Hz)	*
*	  - L : Amplitude du flanger (en octets)			*
*	  - L : Flange time (en octets)				*
*	  - W : Phase initiale (0-4095)				*
*============================================================================*
fx_stereo_flanger:
	movem.l	d0-a6,-(sp)

	move.l	a0,d0		; Si a0 = 0, on doit reprendre Ö
	beq	fxfl_reprise	; partir de lÖ ou on en Çtait.
	move.l	#4096,d0		; Tous les 4096 on indique la progression
	move.l	d0,progression_step
	move.l	d0,progression_cpt
	move.l	fl_londest(a0),progression_len
	clr.l	progression_pos


;--- Initialisation ----------------------------------------------------------
	move.l	fl_londest(a0),d0
	ble	fxfl_fin
	move.l	d0,fl_destcpt(a0)
	clr.l	fl_lsplpos(a0)
	clr.l	fl_rsplpos(a0)
	clr.l	fl_bufpos(a0)
	moveq	#0,d0
	move.w	fl_initphase(a0),d0
	swap	d0
	move.l	d0,fl_sincpt(a0)
	move.l	fl_adrdest(a0),a1	; a1 = adresse destination

;--- Boucle de l'effet -------------------------------------------------------
; Calcul de la position de lecture dans le buffer
fxfl_mainloop:
	move.l	fl_bufpos(a0),d0	; d0 = position courante dans le buffer
	move.l	fl_sincpt(a0),d1	; d1 = compteur de sinus
	move.l	d1,d2
	swap	d2		; d2 = mot fort du compteur de sinus
	move.w	([fl_adrsin,a0],d2.w*2),d1
	ext.l	d1
	muls.l	fl_amp(a0),d1
	asr.l	#8,d1
	asr.l	#4,d1		; d1 = sin(wt) * amp
	add.l	d1,d0
	sub.l	fl_time(a0),d0
	bpl.s	.sinok1
	add.l	fl_lonbuf(a0),d0
.sinok1:	cmp.l	fl_lonbuf(a0),d0
	blt.s	.sinok2
	sub.l	fl_lonbuf(a0),d0
.sinok2:	bclr	#0,d0		; d0 = position dans le buffer, lecture

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Mixage Wet (sortie buffer) + Dry Ö gauche
	move.l	fl_destcpt(a0),d7	; d7 = compteur de destination

.destleft:
	btst	#0,fl_flags+1(a0)		; Destination = left ?
	beq	.destrigh
	move.w	([fl_adrlbuf,a0],d0.l),d1	; d1 = sortie du buffer
	swap	d1
	muls.l	fl_wetl(a0),d2:d1
	ext.l	d2			; d2 = Wet
	clr.w	fl_inl(a0)
	move.l	fl_lsplpos(a0),d1
	bmi.s	.lsplfini		; Si pos<0, le sample source left Çtait fini
	cmp.w	#2,fl_resoll(a0)
	bne.s	.8dl
.16dl:	move.w	([fl_adrlspl,a0],d1.l),d3	; Source 16 bits
	addq.l	#2,d1			; IncrÇmente la position
	bra.s	.816dlfin
.8dl:	move.b	([fl_adrlspl,a0],d1.l),d3	; source 8 bits
	asl.w	#8,d3
	addq.l	#1,d1			; IncrÇmente la position
.816dlfin:	move.w	d3,fl_inl(a0)		; Sauve le sample 'in'
	swap	d3
	muls.l	fl_dryl(a0),d4:d3
	ext.l	d4			; d4 = Dry L
	add.l	d4,d2			; d2 = Dry + Wet
	cmp.l	fl_lonlspl(a0),d1
	blt.s	.lsplend
	moveq	#-1,d1
.lsplend:	move.l	d1,fl_lsplpos(a0)
.lsplfini:	cmp.w	#2,fl_resold(a0)
	bne.s	.8ldest
	move.l	d2,d3
	cmp.l	#MAX_SWORD,d3
	ble.s	.lsplok1
	move.w	#MAX_SWORD,d3
.lsplok1:	cmp.l	#MIN_SWORD,d3
	bge.s	.lsplok2
	move.w	#MIN_SWORD,d3
.lsplok2:	move.w	d3,(a1)+
	subq.l	#2,d7
	bra.s	.destrigh
.8ldest:	move.l	d2,d3
	asr.l	#8,d3
	cmp.w	#MAX_SBYTE,d3
	ble.s	.lsplok3
	moveq	#MAX_SBYTE,d3
.lsplok3:	cmp.w	#MIN_SBYTE,d3
	bge.s	.lsplok4
	moveq	#MIN_SBYTE,d3
.lsplok4:	move.b	d3,(a1)+
	subq.l	#1,d7

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Mixage Wet (sortie buffer) + Dry Ö droite
.destrigh:
	btst	#1,fl_flags+1(a0)		; Destination = right ?
	beq	.findest
	move.w	([fl_adrrbuf,a0],d0.l),d1	; d1 = sortie du buffer
	swap	d1
	muls.l	fl_wetr(a0),d6:d1
	ext.l	d6			; d6 = Wet
	clr.w	fl_inr(a0)
	move.l	fl_rsplpos(a0),d1
	bmi.s	.rsplfini		; Si pos<0, le sample source left Çtait fini
	cmp.w	#2,fl_resolr(a0)
	bne.s	.8dr
.16dr:	move.w	([fl_adrrspl,a0],d1.l),d5	; Source 16 bits
	addq.l	#2,d1			; IncrÇmente la position
	bra.s	.816drfin
.8dr:	move.b	([fl_adrrspl,a0],d1.l),d5	; source 8 bits
	asl.w	#8,d5
	addq.l	#1,d1			; IncrÇmente la position
.816drfin:	move.w	d5,fl_inr(a0)		; Sauve le sample 'in'
	swap	d5
	muls.l	fl_dryr(a0),d3:d5
	ext.l	d3			; d3 = Dry R
	add.l	d3,d6			; d6 = Dry + Wet
	cmp.l	fl_lonrspl(a0),d1
	blt.s	.rsplend
	moveq	#-4,d1
.rsplend:	move.l	d1,fl_rsplpos(a0)
.rsplfini:	move.l	d6,d5
	btst	#2,fl_flags+1(a0)		; Mixage G-D ?
	beq.s	.rnomix
	add.l	d2,d5
	subq.l	#1,a1
	addq.l	#1,d7
	cmp.w	#2,fl_resold(a0)
	bne.s	.8rdest
	subq.l	#1,a1
	addq.l	#1,d7
	bra.s	.16rdest
.rnomix:	cmp.w	#2,fl_resold(a0)
	bne.s	.8rdest
.16rdest:	cmp.l	#MAX_SWORD,d5
	ble.s	.rsplok1
	move.w	#MAX_SWORD,d5
.rsplok1:	cmp.l	#MIN_SWORD,d5
	bge.s	.rsplok2
	move.w	#MIN_SWORD,d5
.rsplok2:	move.w	d5,(a1)+
	subq.l	#2,d7
	bra.s	.findest
.8rdest:	asr.l	#8,d5
	cmp.w	#MAX_SBYTE,d5
	ble.s	.rsplok3
	moveq	#MAX_SBYTE,d5
.rsplok3:	cmp.w	#MIN_SBYTE,d5
	bge.s	.rsplok4
	moveq	#MIN_SBYTE,d5
.rsplok4:	move.b	d5,(a1)+
	subq.l	#1,d7
.findest:				; d0 = pos buf lect, d7 = cpt

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Test de sortie
	move.l	d7,fl_destcpt(a0)
	bmi	fxfl_fin
	
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Arràt momentanÇ pour affichage de la progression
	moveq	#0,d1
	move.w	fl_resold(a0),d1
	sub.l	d1,progression_cpt
	bgt.s	fxfl_feedback
	move.l	progression_step(pc),d1
	move.l	d1,progression_cpt
	add.l	d1,progression_pos
	movem.l	d0-d7/a0-a6,progression_savedreg
	bra	fxfl_break

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Reprise apräs affichage de la progression
fxfl_reprise:
	movem.l	progression_savedreg,d0-d7/a0-a6

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Feedback
fxfl_feedback:
	move.w	([fl_adrlbuf,a0],d0.l),d1	; d1 = sortie du buffer L
	swap	d1
	move.l	d1,d2
	muls.l	fl_fdbkll(a0),d3:d1
	ext.l	d3			; d3 = feedback L->L
	muls.l	fl_fdbklr(a0),d4:d2
	ext.l	d4			; d4 = feedback L->R
	move.w	([fl_adrrbuf,a0],d0.l),d1	; d1 = sortie du buffer L
	swap	d1
	move.l	d1,d2
	muls.l	fl_fdbkrl(a0),d5:d1
	ext.l	d5			; d5 = feedback R->L
	muls.l	fl_fdbkrr(a0),d6:d2
	ext.l	d6			; d6 = feedback R->R

	move.l	fl_bufpos(a0),d0	; d0 = position dans le buffer en Çcriture
	move.w	fl_inl(a0),d1	; Mixage entrÇe du buffer L
	ext.l	d1
	add.l	d3,d1
	add.l	d5,d1
	cmp.l	#MAX_SWORD,d1
	ble.s	.mixlok1
	move.w	#MAX_SWORD,d1
.mixlok1:	cmp.l	#MIN_SWORD,d1
	bge.s	.mixlok2
	move.w	#MIN_SWORD,d1
.mixlok2:	move.w	d1,([fl_adrlbuf,a0],d0.l)
	move.w	fl_inr(a0),d1	; Mixage entrÇe du buffer R
	ext.l	d1
	add.l	d4,d1
	add.l	d6,d1
	cmp.l	#MAX_SWORD,d1
	ble.s	.mixrok1
	move.w	#MAX_SWORD,d1
.mixrok1:	cmp.l	#MIN_SWORD,d1
	bge.s	.mixrok2
	move.w	#MIN_SWORD,d1
.mixrok2:	move.w	d1,([fl_adrrbuf,a0],d0.l)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Avance le buffer
	addq.l	#2,d0		; Nouvelle position d'Çcriture dans
	cmp.l	fl_lonbuf(a0),d0	; le buffer
	blt.s	.nbufok
	moveq	#0,d0
.nbufok:	move.l	d0,fl_bufpos(a0)
	move.l	fl_sincpt(a0),d0
	add.l	fl_freq(a0),d0
	and.l	#$FFFffff,d0
	move.l	d0,fl_sincpt(a0)
	bra	fxfl_mainloop

fxfl_fin:
	move.l	progression_len(pc),progression_pos	; Signale que tout est fini
fxfl_break:
	movem.l	(sp)+,d0-a6
	rts



*============================================================================*
*	BMOVE rapide					*
*	a0 = adresse source					*
*	a1 = adresse destination				*
*	d0 = longueur.l du bloc Ö dÇplacer, en octets		*
*============================================================================*
quick_bmove:
	movem.l	d0-d1/a0-a1,-(sp)
	tst.l	d0
	ble	.fin
	cmp.l	a0,a1
	bgt	.inverse
	beq	.fin

;--- Transfert dans le sens normal -------------------------------------------
	move.l	d0,d1
	lsr.l	#8,d0
	and.w	#255,d1
	subq.w	#1,d1
	bmi.s	.bloc256n
.loopn1:	move.b	(a0)+,(a1)+
	dbra	d1,.loopn1
.bloc256n:	subq.l	#1,d0
	bmi	.fin
	swap	d0
.loopn2:	swap	d0
.loopn3:
	Rept	64
	move.l	(a0)+,(a1)+
	EndR
	dbra	d0,.loopn3
	swap	d0
	dbra	d0,.loopn2
	bra	.fin

;--- Transfert dans le sens inverse ------------------------------------------
.inverse:
	add.l	d0,a0
	add.l	d0,a1
	move.l	d0,d1
	lsr.l	#8,d0
	and.w	#255,d1
	subq.w	#1,d1
	bmi.s	.bloc256i
.loopi1:	move.b	-(a0),-(a1)
	dbra	d1,.loopi1
.bloc256i:	subq.l	#1,d0
	bmi	.fin
	swap	d0
.loopi2:	swap	d0
.loopi3:
	Rept	64
	move.l	-(a0),-(a1)
	EndR
	dbra	d0,.loopi3
	swap	d0
	dbra	d0,.loopi2

.fin:	movem.l	(sp)+,d0-d1/a0-a1
	rts



*============================================================================*
*	Conversion d'un sample absolu (normal) en sample delta-packÇ	*
*	a0 = adresse du sample				*
*	d0 = longueur.l en octets				*
*	d1 = taille.w d'un sample (0 ou 1)			*
*============================================================================*
absolu_2_delta:
	movem.l	d0-d2/a0,-(sp)
	tst.l	d0
	beq.s	.fin
	moveq	#0,d2
	cmp.w	#2,d1
	beq.s	.16bits

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.8bits:	subq.l	#1,d0
	swap	d0
.8loop2:	swap	d0
.8loop1:	move.b	(a0),d1
	sub.b	d2,(a0)+
	move.b	d1,d2
	dbra	d0,.8loop1
	swap	d0
	dbra	d0,.8loop2
	bra.s	.fin

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.16bits:	lsr.l	#1,d0
	subq.l	#1,d0
	swap	d0
.16loop2:	swap	d0
.16loop1:	move.w	(a0),d1
	add.w	d2,(a0)+
	move.w	d1,d2
	dbra	d0,.16loop1
	swap	d0
	dbra	d0,.16loop2

.fin:	movem.l	(sp)+,d0-d2/a0
	rts



*============================================================================*
*	Conversion d'un sample delta-packÇ en sample absolu (normal)	*
*	a0 = adresse du sample				*
*	d0 = longueur.l en octets				*
*	d1 = taille.w d'un sample (0 ou 1)			*
*============================================================================*
delta_2_absolu:
	movem.l	d0-d2/a0,-(sp)
	tst.l	d0
	beq.s	.fin
	moveq	#0,d2
	cmp.w	#2,d1
	beq.s	.16bits

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.8bits:	subq.l	#1,d0
	swap	d0
.8loop2:	swap	d0
.8loop1:	add.b	d2,(a0)
	move.b	(a0)+,d2
	dbra	d0,.8loop1
	swap	d0
	dbra	d0,.8loop2
	bra.s	.fin

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.16bits:	lsr.l	#1,d0
	subq.l	#1,d0
	swap	d0
.16loop2:	swap	d0
.16loop1:	add.w	d2,(a0)
	move.w	(a0)+,d2
	dbra	d0,.16loop1
	swap	d0
	dbra	d0,.16loop2

.fin:	movem.l	(sp)+,d0-d2/a0
	rts



*============================================================================*
*	Convertit un pattern FT2 en GTK				*
*	a0 = adresse du pattern FT2				*
*	a1 = adresse du pattern GTK				*
*	d0 = nombre.w de voies				*
*	d1 = nombre.w de lignes				*
*============================================================================*
convert_ft2_2_gtk:
	movem.l	d0-a6,-(sp)
	mulu.w	d1,d0
	subq.w	#1,d0		; d0 = compteur de notes

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.noteloop:
	clr.l	(a1)		; Graoumf note vide
	clr.b	4(a1)
	moveq	#%11111,d1		; d1 = y a quoi dedans ?
	btst	#7,(a0)		; par dÇfaut, y a tout (note non packÇe)
	beq.s	.note
	move.b	(a0)+,d1		; Bit 7 mis, la note est packÇe

.note:
	btst	#0,d1
	beq.s	.instrument
	move.b	(a0)+,d3
	cmp.b	#97,d3		; ??? Effet de Note Cut ???
	bne.s	.notetest
	move.w	#$0A00,2(a1)
	bra.s	.instrument
.notetest:	cmp.b	#25,d3		; Si on tombe en dessous de C-0, (+1)
	bge.s	.noteok
	add.b	#12,d3		; on remonte d'une octave
	bra.s	.notetest
.noteok:	subq.b	#1,d3
	move.b	d3,(a1)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.instrument:
	btst	#1,d1
	beq.s	.volume
	move.b	(a0)+,1(a1)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.volume:
	moveq	#0,d2		; d2 = effet (rien pour l'instant)
	btst	#2,d1
	beq	.effettype
	moveq	#0,d3
	move.b	(a0)+,d3
	cmp.w	#$10,d3
	blt	.effettype
	cmp.w	#$50,d3
	bgt.s	.vols1
.volok:	sub.b	#$10,d3		; $10 - $50 : Volume
	lsl.w	#2,d3
	cmp.w	#$100,d3
	beq.s	.volmax
	tst.w	d3
	beq.s	.volnul
	move.b	d3,4(a1)
	bra	.effettype
.volnul:	move.w	#$2000,d2
	move.b	#1,4(a1)
	bra	.effettype
.volmax:	move.w	#$2100,d2
	move.b	#255,4(a1)
	bra	.effettype
.vols1:	cmp.w	#$60,d3
	blt	.effettype
	cmp.w	#$70,d3		; $60 - $6f : Vol slide down
	bge.s	.volslup
	and.b	#15,d3
	lsl.b	#4,d3
	move.w	#$1500,d2
	move.b	d3,d2
	bra	.effettype
.volslup:	cmp.w	#$80,d3		; $70 - $7f : Vol slide up
	bge.s	.fvolsldw
	and.b	#15,d3
	lsl.b	#4,d3
	move.w	#$1400,d2
	move.b	d3,d2
	bra	.effettype
.fvolsldw:	cmp.w	#$90,d3		; $80 - $8f : Fine vol slide down
	bge.s	.fvolslup
	and.b	#15,d3
	lsl.b	#4,d3
	move.w	#$A500,d2
	move.b	d3,d2
	bra	.effettype
.fvolslup:	cmp.w	#$A0,d3		; $90 - $9f : Fine vol slide up
	bge.s	.vibspd
	and.b	#15,d3
	lsl.b	#4,d3
	move.w	#$A400,d2
	move.b	d3,d2
	bra.s	.effettype
.vibspd:	cmp.w	#$b0,d3		; $a0 - $af : Set vibrato speed
	bge.s	.vibrato
	and.b	#15,d3
	lsl.b	#4,d3
	move.w	#$400,d2
	move.b	d3,d2
	bra.s	.effettype
.vibrato:	cmp.w	#$c0,d3		; $b0 - $bf : Vibrato
	bge.s	.setpan
	and.b	#15,d3
	move.w	#$400,d2
	move.b	d3,d2
	bra.s	.effettype
.setpan:	cmp.w	#$d0,d3		; $c0 - $cf : Set panning
	bge.s	.pansllft
	and.b	#15,d3
	lsl.w	#8,d3
	add.w	#$4000,d3
	move.w	d3,d2
	bra.s	.effettype
.pansllft:	cmp.w	#$e0,d3		; $d0 - $df : Panning slide left
	bge.s	.panslrig
	and.b	#15,d3
	lsl.b	#4,d3
	move.w	#$AE00,d2
	move.b	d3,d2
	bra.s	.effettype
.panslrig:	cmp.w	#$f0,d3		; $e0 - $ef : Panning slide right
	bge.s	.toneport
	and.b	#15,d3
	lsl.b	#4,d3
	move.w	#$AF00,d2
	move.b	d3,d2
	bra.s	.effettype
.toneport:	and.b	#15,d3		; $f0 - $ff : Tone portamento
	move.w	#$300,d2
	move.b	d3,d2

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.effettype:
	moveq	#0,d3
	btst	#3,d1
	beq.s	.effetparam
	move.b	(a0)+,d3		; d3 = numÇro d'effet

.effetparam:
	moveq	#0,d4
	btst	#4,d1
	beq.s	.fxconv
	move.b	(a0)+,d4		; d4 = paramätre de l'effet

.fxconv:
	bsr	convert_xmfx_2_gtkfx
	move.w	d2,2(a1)
	addq.l	#5,a1
	dbra	d0,.noteloop

	movem.l	(sp)+,d0-a6
	rts



*============================================================================*
*	Converti un effet Fast Tracker 2 en un effet Graoumf Tracker	*
*	d2 = Note.l au format Graoumf (sans effet)			*
*	d3 = effet.b protracker (0-F)				*
*	d4 = paramätre.w protracker (0-FF)			*
*	Attention, ces registres ne sont pas sauvÇs			*
*	Au retour :					*
*	d2 = Note + Effet					*
*============================================================================*
convert_xmfx_2_gtkfx:
	cmp.b	#1,d3		; Les effets qui ne changent pas
	beq.s	.nochange
	cmp.b	#2,d3
	beq.s	.nochange
	cmp.b	#3,d3
	beq.s	.nochange
	cmp.b	#4,d3
	beq.s	.nochange
	cmp.b	#7,d3
	beq.s	.nochange
	cmp.b	#$B,d3
	bne.s	.suite
.nochange:	move.w	d4,d2
	lsl.w	#8,d3
	add.w	d3,d2
	and.w	#$fff,d2
	bra	.fin

.suite:	tst.b	d3		; Arpeggio
	bne.s	.5
	tst.b	d4
	beq	.fin
	add.w	#$1000,d4
	move.w	d4,d2
	bra	.fin

.5:	cmp.b	#5,d3		; Vol slide + porta
	bne.s	.6
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.5neg
	add.w	#$1800,d4
	move.w	d4,d2
	bra	.fin
.5neg:	move.w	#$1900,d2
	sub.w	d4,d2
	bra	.fin

.6:	cmp.b	#6,d3		; Vol slide + vib
	bne.s	.8
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.6neg
	add.w	#$1c00,d4
	move.w	d4,d2
	bra	.fin
.6neg:	move.w	#$1d00,d2
	sub.w	d4,d2
	bra	.fin

.8:	cmp.b	#8,d3		; Set balance
	bne.s	.9
	add.w	#$400,d4
	lsl.w	#4,d4
	move.w	d4,d2
	bra	.fin

.9:	cmp.b	#9,d3		; Play part of sample
	bne.s	.a
	add.w	#$9000,d4
	move.w	d4,d2
	bra	.fin

.a:	cmp.b	#10,d3		; Vol slide
	bne.s	.c
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.aneg
	add.w	#$1400,d4
	move.w	d4,d2
	bra	.fin
.aneg:	move.w	#$1500,d2
	sub.w	d4,d2
	bra	.fin

.c:	cmp.b	#$c,d3		; Set volume
	bne.s	.d
	add.w	d4,d4
	add.w	d4,d4
	add.w	#$2000,d4
	move.w	d4,d2
	bra	.fin

.d:	cmp.b	#$d,d3		; Break pattern to line
	bne.s	.e
	move.w	d4,d3		; Conversion BCD -> Hexa
	lsr.w	#4,d4
	mulu.w	#10,d4
	and.b	#$f,d3
	add.b	d3,d4
	move.w	#$D00,d2
	move.b	d4,d2
	bra	.fin

.e:	cmp.b	#14,d3		; Effets Çtendus
	bne	.f
	move.w	d4,d3
	lsr.b	#4,d3
	and.b	#$f,d4
.e1:	cmp.b	#1,d3		; Fine porta up
	bne.s	.e2
	add.w	#$1100,d4
	move.w	d4,d2
	bra	.fin

.e2:	cmp.b	#2,d3		; Fine porta down
	bne.s	.e4
	add.w	#$1200,d4
	move.w	d4,d2
	bra	.fin

.e4:	cmp.b	#4,d3		; Set vib wave
	bne.s	.e5
	add.w	#$c00,d4
	move.w	d4,d2
	bra	.fin

.e5:	cmp.b	#5,d3		; Set finetune
	bne.s	.e6
	cmp.b	#7,d4
	bgt.s	.e5neg
	lsl.b	#4,d4
	add.w	#$800,d4
	move.w	d4,d2
	bra	.fin
.e5neg:	move.w	#$810,d2
	sub.w	d4,d2
	bra	.fin

.e6:	cmp.b	#6,d3		; Pattern loop
	bne.s	.e7
	add.w	#$b100,d4
	move.w	d4,d2
	bra	.fin

.e7:	cmp.b	#7,d3		; Set trem wave
	bne.s	.e8
	add.w	#$e00,d4
	move.w	d4,d2
	bra	.fin

.e8:	cmp.b	#8,d3		; Set balance (2)
	bne.s	.e9
	lsl.w	#8,d4
	add.w	#$4000,d4
	move.w	d4,d2
	bra	.fin

.e9:	cmp.b	#9,d3		; Retrig sample
	bne.s	.e10
	lsl.w	#8,d4
	add.w	#$7000,d4
	move.w	d4,d2
	bra	.fin

.e10:	cmp.b	#10,d3		; Fine vol up
	bne.s	.e11
	move.w	#$a400,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra	.fin

.e11:	cmp.b	#11,d3		; Fine vol down
	bne.s	.e12
	move.w	#$a500,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra	.fin

.e12:	cmp.b	#12,d3		; Note cut
	bne.s	.e13
	add.w	#$a00,d4
	move.w	d4,d2
	bra	.fin

.e13:	cmp.b	#13,d3		; Note delay
	bne.s	.ee
	add.w	#$900,d4
	move.w	d4,d2
	bra	.fin

.ee:	cmp.b	#$e,d3		; Pattern delay
	bne	.fin
	add.w	#$aa00,d4
	move.w	d4,d2
	bra	.fin

.f:	cmp.b	#15,d3		; Tempo
	bne.s	.k
	move.w	#$0F00,d2
	cmp.w	#$20,d4
	bge.s	.f_ok
	move.w	#$A800,d2
.f_ok:	move.b	d4,d2
	bra.s	.fin

.k:	cmp.b	#$14,d3		; Key off
	bne.s	.p
	move.w	#$0A00,d2
	bra.s	.fin

.p:	cmp.b	#$19,d3		; Panning slide
	bne.s	.r
	move.b	d4,d3
	lsr.b	#4,d3
	and.b	#15,d4
	sub.w	d3,d4
	bmi.s	.pneg
	move.w	#$AF00,d2
	move.b	d4,d2
	bra.s	.fin
.pneg:	move.w	#$AE00,d2
	sub.b	d4,d2
	bra.s	.fin

.r:	cmp.b	#$1b,d3		; Multi retrig note
	bne.s	.t
	move.w	#$1300,d2		; ??? Comme dans les S3M ???
	move.b	d4,d2
	bra.s	.fin

.t:	cmp.b	#$1d,d3		; Tremor
	bne.s	.x
	move.w	#$B000,d2
	move.b	d4,d2
	bra.s	.fin

.x:	cmp.b	#$21,d3		; Effets Çtendus II le retour
	bne.s	.fin
	move.b	d4,d3
	lsr.b	#4,d3
	and.b	#15,d4
.x1:	cmp.b	#$1,d3		; Extra fine porta up
	bne.s	.x2
	move.w	#$AC00,d2
	lsl.b	#2,d3		; 4x + prÇcis pour FT2 comme pour ST3 ?
	move.b	d3,d2
	bra.s	.fin

.x2:	cmp.b	#$2,d3		; Extra fine porta up
	bne.s	.fin
	move.w	#$AD00,d2
	lsl.b	#2,d3		; 4x + prÇcis pour FT2 comme pour ST3 ?
	move.b	d3,d2

.fin:	rts



*============================================================================*
*	Convertit un pattern GTK en S3M				*
*	a0 = adresse du pattern GTK				*
*	a1 = adresse du pattern S3M (pointe sur la longueur)		*
*	d0 = nombre.w de voies				*
*	d1 = nombre.w de lignes				*
*============================================================================*
convert_gtk_2_s3m:
	movem.l	d0-a6,-(sp)
	lea	2(a1),a2		; a2 pointe sur les donnÇes compressÇes
	moveq	#63,d2		; d2 = compteur de ligne

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.lineloop:
	moveq	#0,d3		; d3 = numÇro de la voie courante
	move.w	d0,d4
.trkloop:
	tst.l	(a0)		; Voie vide ?
	bne.s	.note
	tst.b	4(a0)
	beq	.nexttrack

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.note:
	move.l	a2,a3		; Sauve a2 dans a3
	clr.b	(a2)+
	move.b	d3,d4		; d4 = byte d'info
	tst.w	(a0)		; Note ou instr ?
	beq.s	.volume
	moveq	#0,d5
	move.b	(a0),d5		; Convertion de la note
	bne.s	.cvnote
	move.b	#255,(a2)+		; Si pas de note, 255
	bra.s	.cvinstr
.cvnote:	divu.w	#12,d5
	lsl.b	#4,d5
	move.b	d5,(a2)		; L'octave
	swap	d5
	add.b	d5,(a2)+		; Ajoute la note
.cvinstr:	move.b	1(a0),(a2)+
	or.b	#32,d4

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.volume:
	move.b	2(a0),d5
	and.b	#$f0,d5
	cmp.b	#$20,d5		; Volume par la commande 2xxx ?
	bne.s	.volume2
	move.w	2(a0),d5
	lsr.w	#2,d5
	and.b	#$7f,d5
	bra.s	.volok

.volume2:
	moveq	#0,d5
	move.b	4(a0),d5		; Volume sur la colonne ?
	beq.s	.effet
	addq.w	#1,d5
	lsr.w	#2,d5
.volok:	move.b	d5,(a2)+
	or.b	#64,d4

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.effet:
	tst.w	2(a0)
	beq	.fintrack
	move.w	2(a0),d5		; d5 = commande + paramätre
	move.b	2(a0),d6		; d6 = commande
	moveq	#0,d7
	move.b	d5,d7		; d7 = paramätre

.01:	cmp.b	#$01,d6		; Portamento up
	bne.s	.02
	add.w	#$600,d7
	bra	.fineffet
.02:	cmp.b	#$02,d6		; Portamento down
	bne.s	.03
	add.w	#$500,d7
	bra	.fineffet
.03:	cmp.b	#$03,d6		; Tone portamento
	beq.s	.03ok
.05:	cmp.b	#$05,d6		; Tone portamento (+ vibrato)
	bne.s	.04
.03ok:	add.w	#$700,d7
	bra	.fineffet
.04:	cmp.b	#$04,d6		; Vibrato
	beq.s	.04ok
.06:	cmp.b	#$06,d6		; Vibrato (+ tone porta)
	bne.s	.07
.04ok:	add.w	#$800,d7
	bra	.fineffet
.07:	cmp.b	#$07,d6		; Tremolo
	bne.s	.08
	add.w	#$1200,d7
	bra	.fineffet
.08:	cmp.b	#$08,d6		; Detune
	bne.s	.09
	move.b	d7,d6
	lsr.b	#4,d7
	sub.b	d6,d7
	and.b	#15,d7
	add.w	#$1320,d7
	bra	.fineffet
.09:	cmp.b	#$09,d6		; Note delay
	bne.s	.0A
	and.b	#15,d7
	add.w	#$13D0,d7
	bra	.fineffet
.0A:	cmp.b	#$0A,d6		; Note cut
	bne.s	.0B
	and.b	#15,d7
	add.w	#$13C0,d7
	bra	.fineffet
.0B:	cmp.b	#$0B,d6		; Jump to position
	bne.s	.0C
	add.w	#$200,d7
	bra	.fineffet
.0C:	cmp.b	#$0C,d6		; Set vibrato waveform
	bne.s	.0D
	and.b	#15,d7
	add.w	#$1330,d7
	bra	.fineffet
.0D:	cmp.b	#$0D,d6		; Break pattern
	bne.s	.0E
	move.l	d7,d5
	move.w	#$300,d7
	divu.w	#10,d5		; Conversion Hexa -> BCD
	lsl.b	#4,d5
	add.b	d5,d7
	swap	d5
	move.b	d5,d7
	bra	.fineffet
.0E:	cmp.b	#$0E,d6		; Set tremolo waveform
	bne.s	.0F
	add.w	#$1340,d7
	bra	.fineffet
.0F:	cmp.b	#$0F,d6		; Set speed/tempo
	bne.s	.10
	cmp.w	#$20,d7
	blt.s	.0Fspeed
	add.w	#$1400-$100,d7
.0Fspeed:	add.w	#$100,d7
	bra	.fineffet
.10:	cmp.b	#$10,d6		; Arpeggio
	bne.s	.11
	add.w	#$A00,d7
	bra	.fineffet
.11:	cmp.b	#$11,d6		; Fine portamento up
	bne.s	.12
	and.b	#15,d7
	add.w	#$6F0,d7
	bra	.fineffet
.12:	cmp.b	#$12,d6		; Fine portamento down
	bne.s	.13
	add.w	#$5F0,d7
	bra	.fineffet
.13:	cmp.b	#$13,d6		; Roll + volume slide
	bne.s	.14
	add.w	#$1100,d7
	bra	.fineffet
.14:	cmp.b	#$14,d6		; Linear volume slide up
	bne.s	.15
	lsl.b	#2,d7
	and.b	#$F0,d7
	add.w	#$400,d7
	bra	.fineffet
.15:	cmp.b	#$15,d6		; Linear volume slide down
	bne.s	.18
	lsr.b	#2,d7
	and.b	#$F,d7
	add.w	#$400,d7
	bra	.fineffet
.18:	cmp.b	#$18,d6		; Linear volume slide up + Tone portamento
	bne.s	.19
	lsl.b	#2,d7
	and.b	#$F0,d7
	add.w	#$C00,d7
	bra	.fineffet
.19:	cmp.b	#$19,d6		; Linear volume slide down + Tone portamento
	bne.s	.1C
	lsr.b	#2,d7
	and.b	#$F,d7
	add.w	#$C00,d7
	bra	.fineffet
.1C:	cmp.b	#$1C,d6		; Linear volume slide up + Vibrato
	bne.s	.1D
	lsl.b	#2,d7
	and.b	#$F0,d7
	add.w	#$B00,d7
	bra	.fineffet
.1D:	cmp.b	#$1D,d6		; Linear volume slide down + Vibrato
	bne.s	.A4
	lsr.b	#2,d7
	and.b	#$F,d7
	add.w	#$B00,d7
	bra	.fineffet
.A4:	cmp.b	#$A4,d6		; Fine linear volume slide up
	bne.s	.A5
	lsl.b	#2,d7
	and.b	#$F0,d7
	add.w	#$40F,d7
	bra	.fineffet
.A5:	cmp.b	#$A5,d6		; Fine linear volume slide down
	bne.s	.A8
	lsr.b	#2,d7
	and.b	#$F,d7
	add.w	#$4F0,d7
	bra	.fineffet
.A8:	cmp.b	#$A8,d6		; Set number of frames
	bne.s	.AA
	add.w	#$100,d7
	bra	.fineffet
.AA:	cmp.b	#$AA,d6		; Pattern delay
	bne.s	.AB
	and.b	#15,d7
	add.w	#$13E0,d7
	bra	.fineffet
.AB:	cmp.b	#$AB,d6		; Extra fine tone portamento
	bne.s	.AC
	lsr.b	#4,d7		; Pas d'Çquivalent -> Tone p. normal
	add.w	#$700,d7
	bra	.fineffet
.AC:	cmp.b	#$AC,d6		; Extra fine portamento up
	bne.s	.AD
	lsr.b	#2,d7
	and.b	#15,d7
	add.w	#$6E0,d7
	bra.s	.fineffet
.AD:	cmp.b	#$AD,d6		; Extra fine portamento down
	bne.s	.B0
	lsr.b	#2,d7
	and.b	#15,d7
	add.w	#$5E0,d7
	bra.s	.fineffet
.B0:	cmp.b	#$B0,d6		; Tremor
	bne.s	.B1
	add.w	#$900,d7
	bra.s	.fineffet
.B1:	cmp.b	#$B1,d6		; Pattern loop
	bne.s	.1chiffre
	and.b	#15,d7
	add.w	#$13B0,d7
	bra.s	.fineffet

.1chiffre:	lsr.b	#4,d6		; Les commandes qui ne prennent qu'un chiffre
	move.w	d5,d7
	and.w	#$fff,d7
.4:	cmp.b	#$4,d6		; Set balance
	bne.s	.7
	lsr.w	#8,d7
	add.w	#$1380,d7
	bra.s	.fineffet
.7:	cmp.b	#$7,d6		; Roll
	bne.s	.8
	lsr.w	#8,d7
	add.w	#$1100,d7
	bra.s	.fineffet
.8:	cmp.b	#$8,d6		; Roll + volume slide (+ set balance)
	bne.s	.9
	and.w	#$ff,d7
	add.w	#$1100,d7
	bra.s	.fineffet
.9:	cmp.b	#$9,d6		; Set sample offset
	bne.s	.paseffet		; Sinon pas d'effet
	and.w	#$ff,d7
	add.w	#$F00,d7
	bra.s	.fineffet

.paseffet:	clr.w	d7
.fineffet:	move.w	d7,(a2)+
	or.b	#128,d4

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.fintrack:
	move.b	d4,(a3)

.nexttrack:
	addq.l	#5,a0
	addq.w	#1,d3
	cmp.w	d0,d3
	blt	.trkloop
	clr.b	(a2)+
	dbra	d2,.lineloop
	sub.l	a1,a2		; Longueur du pattern compressÇ
	move.w	a2,(a1)
	movem.l	(sp)+,d0-a6
	rts



*============================================================================*
*	Cherche le chunk suivant dans un module .DTM		*
*	a0 = adresse du dÇbut de la recherche			*
*	a1 = adresse de fin de la recherche			*
*	Renvoie l'adresse trouvÇe dans d0			*
*============================================================================*
dtm_next_chunk:
	movem.l	a0-a1,-(sp)
.loop:	move.l	(a0),d0
	cmp.l	#'S.Q.',d0
	beq.s	.fin
	cmp.l	#'PATT',d0
	beq.s	.fin
	cmp.l	#'INST',d0
	beq.s	.fin
	cmp.l	#'DAPT',d0
	beq.s	.fin
	cmp.l	#'DAIT',d0
	beq.s	.fin
	addq.l	#1,a0
	cmp.l	a1,a0
	blt.s	.loop
.fin:	move.l	a0,d0
	movem.l	(sp)+,a0-a1
	rts



*============================================================================*
*	Convertit un pattern Digital Tracker en pattern G.T.		*
*	a0 = Adresse du pattern DTM				*
*	a1 = Adresse du pattern GTK				*
*	d0 = Nombre.l de nores Ö convertir			*
*============================================================================*
convert_dtm_2_gtk:
	movem.l	d0-d4/a0-a1,-(sp)

	subq.l	#1,d0
	swap	d0
.loop1:	swap	d0
.loop2:
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	moveq	#0,d2
	moveq	#0,d1
	move.b	(a0)+,d1
	beq.s	.pasnote
	move.b	d1,d2
	and.b	#15,d2
	subq.b	#1,d2
	lsr.b	#4,d1
	mulu.w	#12,d1
	add.b	d1,d2
.pasnote:	move.b	d2,(a1)		; Note ok
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	move.b	(a0),d1
	and.b	#$FC,d1
	move.b	d1,4(a1)		; Volume ok

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	move.w	(a0),d1
	lsr.w	#4,d1
	and.w	#63,d1
	move.b	d1,1(a1)		; Instrument ok
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	moveq	#0,d3
	moveq	#0,d4
	move.b	1(a0),d3
	and.b	#15,d3
	move.b	2(a0),d4
	moveq	#0,d2
	bsr	convert_dtmfx_2_gtkfx
	move.w	d2,2(a1)		; Effet ok
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	addq.l	#3,a0
	addq.l	#5,a1
	dbra	d0,.loop2
	swap	d0
	dbra	d0,.loop1

	movem.l	(sp)+,d0-d4/a0-a1
	rts



*============================================================================*
*	Converti un effet Digital Tracker en un effet Graoumf Tracker	*
*	d2 = Note.l au format Graoumf (sans effet)			*
*	d3 = effet.b protracker (0-F)				*
*	d4 = paramätre.w protracker (0-FF)			*
*	Attention, ces registres ne sont pas sauvÇs			*
*	Au retour :					*
*	d2 = Note + Effet					*
*============================================================================*
convert_dtmfx_2_gtkfx:
	cmp.b	#1,d3		; Les effets qui ne changent pas
	beq.s	.nochange
	cmp.b	#2,d3
	beq.s	.nochange
	cmp.b	#3,d3
	beq.s	.nochange
	cmp.b	#4,d3
	beq.s	.nochange
	cmp.b	#7,d3
	beq.s	.nochange
	cmp.b	#$B,d3
	bne.s	.suite
.nochange:	move.w	d4,d2
	lsl.w	#8,d3
	add.w	d3,d2
	and.w	#$fff,d2
	bra	.fin

.suite:	tst.b	d3		; Arpeggio
	bne.s	.5
	tst.b	d4
	beq	.fin
	clr.w	d2		; On inverse les paramätres
	move.b	d4,d2
	lsl.b	#4,d2
	lsr.b	#4,d4
	add.b	d4,d2
	add.w	#$1000,d2
	bra	.fin

.5:	cmp.b	#5,d3		; Vol slide + porta
	bne.s	.6
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.5neg
	add.w	#$1800,d4
	move.w	d4,d2
	bra	.fin
.5neg:	move.w	#$1900,d2
	sub.w	d4,d2
	bra	.fin

.6:	cmp.b	#6,d3		; Vol slide + vib
	bne.s	.8
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.6neg
	add.w	#$1c00,d4
	move.w	d4,d2
	bra	.fin
.6neg:	move.w	#$1d00,d2
	sub.w	d4,d2
	bra	.fin

.8:	cmp.b	#8,d3		; Set balance
	bne.s	.9
	add.w	#$400,d4
	lsl.w	#4,d4
	move.w	d4,d2
	bra	.fin

.9:	cmp.b	#9,d3		; Play part of sample
	bne.s	.a
	add.w	#$9000,d4
	move.w	d4,d2
	bra	.fin

.a:	cmp.b	#10,d3		; Vol slide
	bne.s	.c
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.aneg
	add.w	#$1400,d4
	move.w	d4,d2
	bra	.fin
.aneg:	move.w	#$1500,d2
	sub.w	d4,d2
	bra	.fin

.c:	cmp.b	#$c,d3		; Set volume
	bne.s	.d
	add.w	d4,d4
	add.w	d4,d4
	add.w	#$2000,d4
	move.w	d4,d2
	bra	.fin

.d:	cmp.b	#$d,d3		; Break pattern to line
	bne.s	.e
	move.w	d4,d3		; Conversion BCD -> Hexa
	lsr.w	#4,d4
	mulu.w	#10,d4
	and.b	#$f,d3
	add.b	d3,d4
	move.w	#$D00,d2
	move.b	d4,d2
	bra	.fin

.e:	cmp.b	#14,d3		; Effets Çtendus
	bne	.f
	move.w	d4,d3
	lsr.b	#4,d3
	and.b	#$f,d4
.e1:	cmp.b	#1,d3		; Fine porta up
	bne.s	.e2
	add.w	#$1100,d4
	move.w	d4,d2
	bra	.fin

.e2:	cmp.b	#2,d3		; Fine porta down
	bne.s	.e4
	add.w	#$1200,d4
	move.w	d4,d2
	bra	.fin

.e4:	cmp.b	#4,d3		; Set vib wave
	bne.s	.e5
	add.w	#$c00,d4
	move.w	d4,d2
	bra	.fin

.e5:	cmp.b	#5,d3		; Set finetune
	bne.s	.e6
	cmp.b	#7,d4
	bgt.s	.e5neg
	lsl.b	#4,d4
	add.w	#$800,d4
	move.w	d4,d2
	bra	.fin
.e5neg:	move.w	#$810,d2
	sub.w	d4,d2
	bra	.fin

.e6:	cmp.b	#6,d3		; Pattern loop
	bne.s	.e7
	add.w	#$b100,d4
	move.w	d4,d2
	bra	.fin

.e7:	cmp.b	#7,d3		; Set trem wave
	bne.s	.e8
	add.w	#$e00,d4
	move.w	d4,d2
	bra	.fin

.e8:	cmp.b	#8,d3		; Set balance (2)
	bne.s	.e9
	lsl.w	#8,d4
	add.w	#$4000,d4
	move.w	d4,d2
	bra	.fin

.e9:	cmp.b	#9,d3		; Retrig sample
	bne.s	.e10
	lsl.w	#8,d4
	add.w	#$7000,d4
	move.w	d4,d2
	bra	.fin

.e10:	cmp.b	#10,d3		; Fine vol up
	bne.s	.e11
	move.w	#$a400,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra	.fin

.e11:	cmp.b	#11,d3		; Fine vol down
	bne.s	.e12
	move.w	#$a500,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra	.fin

.e12:	cmp.b	#12,d3		; Note cut
	bne.s	.e13
	add.w	#$a00,d4
	move.w	d4,d2
	bra	.fin

.e13:	cmp.b	#13,d3		; Note delay
	bne.s	.ee
	add.w	#$900,d4
	move.w	d4,d2
	bra	.fin

.ee:	cmp.b	#$e,d3		; Pattern delay
	bne	.fin
	add.w	#$aa00,d4
	move.w	d4,d2
	bra	.fin

.f:	cmp.b	#15,d3		; Tempo
	bne.s	.fin
	move.w	#$0F00,d2
	cmp.w	#$20,d4
	bge.s	.f_ok
	move.w	#$A800,d2
.f_ok:	move.b	d4,d2

.fin:	rts



*============================================================================*
*	Effet de delay sur un Çchantillon. Les buffers sont supposÇs	*
*	dÇjÖ vides.					*
*	a0 = Adresse d'un bloc d'infos sur l'Çcho.			*
*	Ce bloc est composÇ de :				*
*	  - L : Adresse source				*
*	  - L : Adresse destination				*
*	  - L : Adresse buffer de delay				*
*	  - L : Adresse du buffer de retardement			*
*	  - L : Longueur source				*
*	  - L : Longueur destination				*
*	  - L : Feedback (/65536)				*
*	  - L : Time feed (en octets)				*
*	  - L : Longueur du buffer de retardement (octets)		*
*	  - L : Dry level (/65536)				*
*	  - L : Mute in (en SAMPLES) ($7fffffff si pas de mute)	*
*	  - B : Nombre d'octets par sample (source)			*
*	  - B : Nombre d'octets par sample (destination)		*
*	  - W : Nombre de taps				*
*	  Puis pour chaque tap :				*
*	    - L : Delay time (en octets)				*
*	    - L : Level (/65536)				*
*============================================================================*
fx_delay:
	movem.l	d0-a6,-(sp)
	move.l	a0,d0		; Si a0 = 0, on doit reprendre Ö
	bne.s	.new		; partir de lÖ ou on en Çtait.
	jmp	([progression_res_adr])
.new:
	move.l	#4096,d0		; Tous les 4096 on indique la progression
	move.l	d0,progression_step
	move.l	d0,progression_cpt
	move.l	dly_destlen(a0),progression_len
	clr.l	progression_pos
	moveq	#0,d5		; d5 = position dans le buffer 1
	moveq	#0,d6		; d6 = position dans le buffer 2
	move.l	dly_adrsource(a0),a1
	move.l	dly_adrdest(a0),a2
	move.l	dly_adrbuf1(a0),a4	; a4 = adresse du 1er buffer
	move.l	dly_adrbuf2(a0),a5	; a5 = adresse du 2äme buffer
	cmp.b	#2,dly_nbitsdest(a0)
	beq	fxdly_16bits

; Delay en 8 bits 
fxdly_8bits:
	move.w	(a4,d5.l),fxdly_deb1	; Le sample du buffer 1
	clr.w	(a4,d5.l)		; Vide le nouveau sample buffer 1
	move.w	(a5,d6.l),fxdly_deb2	; Le sample du buffer 2
	clr.w	(a5,d6.l)		; Vide le nouveau sample buffer 2
	clr.l	d7
	tst.l	dly_sourcelen(a0)
	ble	.suite1		; Plus de source, plus de tap

;--- Mixage des taps dans les buffers ----------------------------------------
	moveq	#0,d7
	move.b	(a1)+,d7
	lsl.w	#8,d7
	cmp.b	#2,dly_nbitssource(a0)
	bne.s	.sourok
	move.b	(a1)+,d7
	subq.l	#1,dly_sourcelen(a0)
.sourok:	subq.l	#1,dly_sourcelen(a0)
	swap	d7		; d7 = sample source
	tst.l	dly_mutein(a0)	; On coupe la source du delay ?
	ble	.suite1
	lea	dly_tapinfo(a0),a3
	move.l	dly_timefeed(a0),d1	; d1 = timefeed
	move.w	dly_ntaps(a0),d0	; d0 = nombre de taps
	subq.w	#1,d0

.taploop:
	move.l	dly_taptime(a3),d2	; d2 = longueur du tap
	beq.s	.debut1
	cmp.l	d1,d2		; Mise en attente ou directement sur le buffer ?
	bge.s	.tap_en_attente

; Tap directement sur le buffer (Delay time Û Time feed)
	add.l	d5,d2
	cmp.l	d1,d2
	blt.s	.buf1ok
	sub.l	d1,d2		; d2 = position (mÇmoire) dans le buffer
.buf1ok:	move.l	d7,d3
	muls.l	dly_taplevel(a3),d4:d3	; d4 = entrÇe dans le buffer au bon niveau
	move.w	(a4,d2.l),d3	; d3 = sample du buffer
	ext.l	d3
	add.l	d4,d3		; Mixage avec le contenu du buffer
	cmp.l	#MAX_SWORD,d3
	ble.s	.ok3
	move.w	#MAX_SWORD,d3
.ok3:	cmp.l	#MIN_SWORD,d3
	bge.s	.ok4
	move.w	#MIN_SWORD,d3
.ok4:	move.w	d3,(a4,d2.l)	; On remet tout áa dans le buffer
	bra	.nexttap

; Tap sur le buffer d'attente (Delay time Ú Timefeed)
.tap_en_attente:
	sub.l	d1,d2
	beq.s	.debut2
	move.l	dly_time2(a0),d3
	add.l	d6,d2
	cmp.l	d3,d2
	blt.s	.buf2ok
	sub.l	d3,d2		; d2 = position (mÇmoire) dans le buffer
.buf2ok:	move.l	d7,d3
	muls.l	dly_taplevel(a3),d4:d3	; d4 = entrÇe dans le buffer au bon niveau
	move.w	(a5,d2.l),d3	; d3 = sample du buffer
	ext.l	d3
	add.l	d4,d3		; Mixage avec le contenu du buffer
	cmp.l	#MAX_SWORD,d3
	ble.s	.ok5
	move.w	#MAX_SWORD,d3
.ok5:	cmp.l	#MIN_SWORD,d3
	bge.s	.ok6
	move.w	#MIN_SWORD,d3
.ok6:	move.w	d3,(a5,d2.l)	; On remet tout áa dans le buffer
	bra.s	.nexttap

; Mixage sur le dÇbut du buffer 1
.debut1:
	move.l	d7,d3
	muls.l	dly_taplevel(a3),d4:d3	; d4 = entrÇe dans le buffer au bon niveau
	move.w	fxdly_deb1(pc),d3	; d3 = sample du buffer
	ext.l	d3
	add.l	d4,d3		; Mixage avec le contenu du buffer
	cmp.l	#MAX_SWORD,d3
	ble.s	.ok7
	move.w	#MAX_SWORD,d3
.ok7:	cmp.l	#MIN_SWORD,d3
	bge.s	.ok8
	move.w	#MIN_SWORD,d3
.ok8:	move.w	d3,fxdly_deb1	; On remet tout áa dans le buffer
	bra.s	.nexttap

; Mixage sur le dÇbut du buffer 2
.debut2:
	move.l	d7,d3
	muls.l	dly_taplevel(a3),d4:d3	; d4 = entrÇe dans le buffer au bon niveau
	move.w	fxdly_deb2(pc),d3	; d3 = sample du buffer
	ext.l	d3
	add.l	d4,d3		; Mixage avec le contenu du buffer
	cmp.l	#MAX_SWORD,d3
	ble.s	.ok9
	move.w	#MAX_SWORD,d3
.ok9:	cmp.l	#MIN_SWORD,d3
	bge.s	.ok10
	move.w	#MIN_SWORD,d3
.ok10:	move.w	d3,fxdly_deb2	; On remet tout áa dans le buffer

.nexttap:	addq.l	#dly_tapnext,a3
	dbra	d0,.taploop
	subq.l	#1,dly_mutein(a0)

;--- Feedback ----------------------------------------------------------------
.suite1:
	move.w	(a4,d5.l),d0
	ext.l	d0
	moveq	#0,d1
	move.w	fxdly_deb1,d1	; Le sample du buffer 1
	swap	d1
	muls.l	dly_feedback(a0),d2:d1	; Feedback
	add.l	d0,d2		; Mixage avec avec les nouveaux ÇlÇments
	cmp.l	#MAX_SWORD,d2
	ble.s	.ok11
	move.w	#MAX_SWORD,d2
.ok11:	cmp.l	#MIN_SWORD,d2
	bge.s	.ok12
	move.w	#MIN_SWORD,d2
.ok12:	move.w	d2,(a4,d5.l)	; Replace dans le buffer 1

;--- Mixage du dÇbut du buffer 2 sur la fin du 1 -----------------------------
	move.w	fxdly_deb2,d0
	ext.l	d0
	move.w	(a4,d5.l),d1
	ext.l	d1
	add.l	d1,d0
	cmp.l	#MAX_SWORD,d0
	ble.s	.ok13
	move.w	#MAX_SWORD,d0
.ok13:	cmp.l	#MIN_SWORD,d0
	bge.s	.ok14
	move.w	#MIN_SWORD,d0
.ok14:	move.w	d0,(a4,d5.l)

;--- Mixage dry/wet ----------------------------------------------------------
	moveq	#0,d0
	move.l	d7,d0	; Reprend le sample source
	muls.l	dly_drylevel(a0),d1:d0	; d1 contient le dry au bon niveau
	move.w	fxdly_deb1,d2	; d2 = wet
	ext.l	d2
	add.l	d2,d1
	cmp.l	#MAX_SWORD,d1
	ble.s	.ok1
	move.w	#MAX_SWORD,d1
.ok1:	cmp.l	#MIN_SWORD,d1
	bge.s	.ok2
	move.w	#MIN_SWORD,d1
.ok2:	lsr.w	#8,d1		; d1 = mixage dry/wet
	move.b	d1,(a2)+		; Sample dest ok

;--- Nouvelles positions -----------------------------------------------------
	addq.l	#2,d5		; Nouvelle position du buffer 1
	cmp.l	dly_timefeed(a0),d5
	blt.s	.ok15
	moveq	#0,d5
.ok15:	addq.l	#2,d6		; Nouvelle position du buffer 2
	cmp.l	dly_time2(a0),d6
	blt.s	.ok16
	moveq	#0,d6
.ok16:	move.l	dly_destlen(a0),d0
	subq.l	#1,d0
	bgt.s	.noend
	move.l	progression_len(pc),progression_pos	; Signale que tout est fini
	bra	fxdly_fin	
.noend:	move.l	d0,dly_destlen(a0)
	subq.l	#1,progression_cpt
	bgt	fxdly_8bits

;--- Arràt momentanÇ pour affichage de la progression ------------------------
	move.l	progression_step(pc),d0
	move.l	d0,progression_cpt
	add.l	d0,progression_pos
	movem.l	d0-d7/a0-a6,progression_savedreg
	move.l	#fxdly_reprise8bits,progression_res_adr
.fin:
	bra	fxdly_fin

;--- Reprise apräs affichage de la progression -------------------------------
fxdly_reprise8bits
	movem.l	progression_savedreg,d0-d7/a0-a6
	bra	fxdly_8bits



; Delay en 16 bits 
fxdly_16bits:
	move.w	(a4,d5.l),fxdly_deb1	; Le sample du buffer 1
	clr.w	(a4,d5.l)		; Vide le nouveau sample buffer 1
	move.w	(a5,d6.l),fxdly_deb2	; Le sample du buffer 2
	clr.w	(a5,d6.l)		; Vide le nouveau sample buffer 2
	clr.l	d7
	tst.l	dly_sourcelen(a0)
	ble	.suite1		; Plus de source, plus de tap

;--- Mixage des taps dans les buffers ----------------------------------------
	moveq	#0,d7
	move.b	(a1)+,d7
	lsl.w	#8,d7
	cmp.b	#2,dly_nbitssource(a0)
	bne.s	.sourok
	move.b	(a1)+,d7
	subq.l	#1,dly_sourcelen(a0)
.sourok:	subq.l	#1,dly_sourcelen(a0)
	swap	d7		; d7 = sample source
	tst.l	dly_mutein(a0)	; On coupe la source du delay ?
	ble	.suite1
	lea	dly_tapinfo(a0),a3
	move.l	dly_timefeed(a0),d1	; d1 = timefeed
	move.w	dly_ntaps(a0),d0	; d0 = nombre de taps
	subq.w	#1,d0

.taploop:
	move.l	dly_taptime(a3),d2	; d2 = longueur du tap
	beq.s	.debut1
	cmp.l	d1,d2		; Mise en attente ou directement sur le buffer ?
	bge.s	.tap_en_attente

; Tap directement sur le buffer (Delay time Û Time feed)
	add.l	d5,d2
	cmp.l	d1,d2
	blt.s	.buf1ok
	sub.l	d1,d2		; d2 = position (mÇmoire) dans le buffer
.buf1ok:	move.l	d7,d3
	muls.l	dly_taplevel(a3),d4:d3	; d4 = entrÇe dans le buffer au bon niveau
	move.w	(a4,d2.l),d3	; d3 = sample du buffer
	ext.l	d3
	add.l	d4,d3		; Mixage avec le contenu du buffer
	cmp.l	#MAX_SWORD,d3
	ble.s	.ok3
	move.w	#MAX_SWORD,d3
.ok3:	cmp.l	#MIN_SWORD,d3
	bge.s	.ok4
	move.w	#MIN_SWORD,d3
.ok4:	move.w	d3,(a4,d2.l)	; On remet tout áa dans le buffer
	bra	.nexttap

; Tap sur le buffer d'attente (Delay time Ú Timefeed)
.tap_en_attente:
	sub.l	d1,d2
	beq.s	.debut2
	move.l	dly_time2(a0),d3
	add.l	d6,d2
	cmp.l	d3,d2
	blt.s	.buf2ok
	sub.l	d3,d2		; d2 = position (mÇmoire) dans le buffer
.buf2ok:	move.l	d7,d3
	muls.l	dly_taplevel(a3),d4:d3	; d4 = entrÇe dans le buffer au bon niveau
	move.w	(a5,d2.l),d3	; d3 = sample du buffer
	ext.l	d3
	add.l	d4,d3		; Mixage avec le contenu du buffer
	cmp.l	#MAX_SWORD,d3
	ble.s	.ok5
	move.w	#MAX_SWORD,d3
.ok5:	cmp.l	#MIN_SWORD,d3
	bge.s	.ok6
	move.w	#MIN_SWORD,d3
.ok6:	move.w	d3,(a5,d2.l)	; On remet tout áa dans le buffer
	bra.s	.nexttap

; Mixage sur le dÇbut du buffer 1
.debut1:
	move.l	d7,d3
	muls.l	dly_taplevel(a3),d4:d3	; d4 = entrÇe dans le buffer au bon niveau
	move.w	fxdly_deb1(pc),d3	; d3 = sample du buffer
	ext.l	d3
	add.l	d4,d3		; Mixage avec le contenu du buffer
	cmp.l	#MAX_SWORD,d3
	ble.s	.ok7
	move.w	#MAX_SWORD,d3
.ok7:	cmp.l	#MIN_SWORD,d3
	bge.s	.ok8
	move.w	#MIN_SWORD,d3
.ok8:	move.w	d3,fxdly_deb1	; On remet tout áa dans le buffer
	bra.s	.nexttap

; Mixage sur le dÇbut du buffer 2
.debut2:
	move.l	d7,d3
	muls.l	dly_taplevel(a3),d4:d3	; d4 = entrÇe dans le buffer au bon niveau
	move.w	fxdly_deb2(pc),d3	; d3 = sample du buffer
	ext.l	d3
	add.l	d4,d3		; Mixage avec le contenu du buffer
	cmp.l	#MAX_SWORD,d3
	ble.s	.ok9
	move.w	#MAX_SWORD,d3
.ok9:	cmp.l	#MIN_SWORD,d3
	bge.s	.ok10
	move.w	#MIN_SWORD,d3
.ok10:	move.w	d3,fxdly_deb2	; On remet tout áa dans le buffer

.nexttap:	addq.l	#dly_tapnext,a3
	dbra	d0,.taploop
	subq.l	#1,dly_mutein(a0)

;--- Feedback ----------------------------------------------------------------
.suite1:
	move.w	(a4,d5.l),d0
	ext.l	d0
	moveq	#0,d1
	move.w	fxdly_deb1,d1	; Le sample du buffer 1
	swap	d1
	muls.l	dly_feedback(a0),d2:d1	; Feedback
	add.l	d0,d2		; Mixage avec avec les nouveaux ÇlÇments
	cmp.l	#MAX_SWORD,d2
	ble.s	.ok11
	move.w	#MAX_SWORD,d2
.ok11:	cmp.l	#MIN_SWORD,d2
	bge.s	.ok12
	move.w	#MIN_SWORD,d2
.ok12:	move.w	d2,(a4,d5.l)	; Replace dans le buffer 1

;--- Mixage du dÇbut du buffer 2 sur la fin du 1 -----------------------------
	move.w	fxdly_deb2,d0
	ext.l	d0
	move.w	(a4,d5.l),d1
	ext.l	d1
	add.l	d1,d0
	cmp.l	#MAX_SWORD,d0
	ble.s	.ok13
	move.w	#MAX_SWORD,d0
.ok13:	cmp.l	#MIN_SWORD,d0
	bge.s	.ok14
	move.w	#MIN_SWORD,d0
.ok14:	move.w	d0,(a4,d5.l)

;--- Mixage dry/wet ----------------------------------------------------------
	moveq	#0,d0
	move.l	d7,d0	; Reprend le sample source
	muls.l	dly_drylevel(a0),d1:d0	; d1 contient le dry au bon niveau
	move.w	fxdly_deb1,d2	; d2 = wet
	ext.l	d2
	add.l	d2,d1		; d1 = mixage dry/wet
	cmp.l	#MAX_SWORD,d1
	ble.s	.ok1
	move.w	#MAX_SWORD,d1
.ok1:	cmp.l	#MIN_SWORD,d1
	bge.s	.ok2
	move.w	#MIN_SWORD,d1
.ok2:	move.w	d1,(a2)+		; Sample dest ok

;--- Nouvelles positions -----------------------------------------------------
	addq.l	#2,d5		; Nouvelle position du buffer 1
	cmp.l	dly_timefeed(a0),d5
	blt.s	.ok15
	moveq	#0,d5
.ok15:	addq.l	#2,d6		; Nouvelle position du buffer 2
	cmp.l	dly_time2(a0),d6
	blt.s	.ok16
	moveq	#0,d6
.ok16:	move.l	dly_destlen(a0),d0
	subq.l	#2,d0
	bgt.s	.noend
	move.l	progression_len(pc),progression_pos	; Signale que tout est fini
	bra	fxdly_fin	
.noend:	move.l	d0,dly_destlen(a0)
	subq.l	#2,progression_cpt
	bgt	fxdly_16bits

;--- Arràt momentanÇ pour affichage de la progression ------------------------
	move.l	progression_step(pc),d0
	move.l	d0,progression_cpt
	add.l	d0,progression_pos
	movem.l	d0-d7/a0-a6,progression_savedreg
	move.l	#fxdly_reprise16bits,progression_res_adr
.fin:
	bra	fxdly_fin

;--- Reprise apräs affichage de la progression -------------------------------
fxdly_reprise16bits
	movem.l	progression_savedreg,d0-d7/a0-a6
	bra	fxdly_16bits



fxdly_fin:
	movem.l	(sp)+,d0-a6
	rts



*============================================================================*
*	TransformÇe de Fourier pour 1 frÇquence			*
*	a0 = Adresse du sample				*
*	a1 = Adresse d'une table de sinus			*
*	d1 = Longueur.l du sample				*
*	d2 = FrÇquence.l d'Çchantillonnage			*
*	d3 = FrÇquence.l Ö analyser				*
*	d4 = Nombre.w d'octets par sample			*
*	Renvoie l'adresse des puissance Re et Im dans d0 (2x32bits)	*
*============================================================================*
trans_fourier:
	movem.l	d1-a6,-(sp)
	lsl.l	#6,d3
	lsl.l	#6,d3
	moveq	#0,d6
	divul.l	d2,d5:d3		; d3 = incrÇment poids fort *4096/2„
	and.w	#4095,d3		; Modulo 2„
	divu.l	d2,d5:d6		; d6 = IncrÇment.l fractionnaire *4096/2„
	move.w	d3,fft_incmsl
	move.l	d6,fft_inclsl
	clr.l	fft_poslsl
	clr.l	fft_remsl
	clr.l	fft_relsl
	clr.l	fft_immsl
	clr.l	fft_imlsl
	move.l	d1,-(sp)		; Sauve la taille du sample
	lea	fft_poslsl(pc),a2
	cmp.w	#2,d4
	beq	.16bits

; En 8 bits 
;--- Partie imaginaire -------------------------------------------------------
.8bits:
	subq.l	#1,d1		; d1 = compteur
	moveq	#0,d5		; d5 = position poids fort
	move.l	fft_inclsl(pc),d0	; d0 = incrÇment fractionnaire
	move.w	fft_incmsl(pc),d3	; d3 = incrÇment poids fort
	moveq	#0,d7		; d7 = Energie imaginaire poids fort
	lea	fft_imlsl(pc),a3
	swap	d1
.8loop1:	swap	d1
.8loop2:	move.b	(a0)+,d2
	lsl.w	#8,d2		; d2 = sample 16 bits

	moveq	#0,d6
	muls.w	(a1,d5.w*2),d2	; * sin
	bpl.s	.8s1
	moveq	#-1,d6
.8s1:	add.l	d2,(a3)
	addx.l	d6,d7

	add.l	d0,(a2)
	addx.w	d3,d5
	and.w	#4095,d5
	dbra	d1,.8loop2
	swap	d1
	dbra	d1,.8loop1
	move.l	d7,fft_immsl

;--- Partie rÇelle -----------------------------------------------------------
	move.l	(sp),d1
	subq.l	#1,d1		; d1 = compteur
	move.w	#1024,d5		; d5 = position poids fort -> cosinus
	move.l	fft_inclsl(pc),d0	; d0 = incrÇment fractionnaire
	move.w	fft_incmsl(pc),d3	; d3 = incrÇment poids fort
	moveq	#0,d7		; d7 = Energie rÇelle poids fort
	lea	fft_relsl(pc),a3
	swap	d1
.8loop3:	swap	d1
.8loop4:	move.b	-(a0),d2
	lsl.w	#8,d2		; d2 = sample 16 bits

	moveq	#0,d6
	muls.w	(a1,d5.w*2),d2	; * cos
	bpl.s	.8s2
	moveq	#-1,d6
.8s2:	add.l	d2,(a3)
	addx.l	d6,d7

	add.l	d0,(a2)
	addx.w	d3,d5
	and.w	#4095,d5
	dbra	d1,.8loop4
	swap	d1
	dbra	d1,.8loop3
	move.l	d7,fft_remsl

	move.l	(sp)+,d1		; RÇcupäre la longueur
	move.l	fft_remsl(pc),d2
	move.l	fft_relsl(pc),d3
	divs.l	d1,d2:d3
	move.l	d3,fft_remsl	; Sauve la partie rÇelle
	move.l	fft_immsl(pc),d2
	move.l	fft_imlsl(pc),d3
	divs.l	d1,d2:d3
	move.l	d3,fft_relsl	; Sauve la partie imaginaire Ö cotÇ
	bra	.fin

; En 16 bits 
;--- Partie imaginaire -------------------------------------------------------
.16bits:
	lsr.l	#1,d1
	subq.l	#1,d1		; d1 = compteur
	moveq	#0,d5		; d5 = position poids fort
	move.l	fft_inclsl(pc),d0	; d0 = incrÇment fractionnaire
	move.w	fft_incmsl(pc),d3	; d3 = incrÇment poids fort
	moveq	#0,d7		; d7 = Energie imaginaire poids fort
	lea	fft_imlsl(pc),a3
	swap	d1
.16loop1:	swap	d1
.16loop2:	move.w	(a0)+,d2
	move.l	d2,d4		; d2 et d4 = sample 16 bits

	moveq	#0,d6
	muls.w	(a1,d5.w*2),d2	; * sin
	bpl.s	.16s1
	moveq	#-1,d6
.16s1:	add.l	d2,(a3)
	addx.l	d6,d7

	add.l	d0,(a2)
	addx.w	d3,d5
	and.w	#4095,d5
	dbra	d1,.16loop2
	swap	d1
	dbra	d1,.16loop1
	move.l	d7,fft_immsl

;--- Partie rÇelle -----------------------------------------------------------
	move.l	(sp),d1
	lsr.l	#1,d1
	subq.l	#1,d1		; d1 = compteur
	move.w	#1024,d5		; d5 = position poids fort -> cosinus
	move.l	fft_inclsl(pc),d0	; d0 = incrÇment fractionnaire
	move.w	fft_incmsl(pc),d3	; d3 = incrÇment poids fort
	moveq	#0,d7		; d7 = Energie rÇelle poids fort
	lea	fft_relsl(pc),a3
	swap	d1
.16loop3:	swap	d1
.16loop4:	move.w	-(a0),d2
	move.l	d2,d4		; d2 et d4 = sample 16 bits

	moveq	#0,d6
	muls.w	(a1,d5.w*2),d2	; * cos
	bpl.s	.16s2
	moveq	#-1,d6
.16s2:	add.l	d2,(a3)
	addx.l	d6,d7

	add.l	d0,(a2)
	addx.w	d3,d5
	and.w	#4095,d5
	dbra	d1,.16loop4
	swap	d1
	dbra	d1,.16loop3
	move.l	d7,fft_remsl

	move.l	(sp)+,d1		; RÇcupäre la longueur
	lsr.l	#1,d1
	move.l	fft_remsl(pc),d2
	move.l	fft_relsl(pc),d3
	divs.l	d1,d2:d3
	move.l	d3,fft_remsl	; Sauve la partie rÇelle
	move.l	fft_immsl(pc),d2
	move.l	fft_imlsl(pc),d3
	divs.l	d1,d2:d3
	move.l	d3,fft_relsl	; Sauve la partie imaginaire Ö cotÇ

.fin:	move.l	#fft_remsl,d0
	movem.l	(sp)+,d1-a6
	rts



*============================================================================*
*	RÇÇchantillonne un sample				*
*	a0 = adresse du sample source				*
*	a1 = adresse du sample destination			*
*	d0 = Longueur.l du sample source				*
*	d1 = Longueur.l du sample destination			*
*	d2 = Nombre.w d'octets par sample			*
*	d3 = Type.w de rÇÇchantillonnage :			*
*	     0 : Aucune interpolation				*
*	     1 : Interpolation linÇaire				*
*	     2 : Interpolation du 3äme degrÇ			*
*============================================================================*
change_sample_frequency:
	movem.l	d0-a6,-(sp)
	tst.w	d3		; Quel type de rÇÇchantillonnage ?
	beq.s	chgsamfreq_nointerp	; 0 = pas d'interpolation
	cmp.w	#1,d3
	beq	chgsamfreq_interplin	; 1 = interpolation linÇaire

; RÇÇchantillonnage sans interpolation 
chgsamfreq_nointerp:
	move.l	d0,d7
	moveq	#0,d6
	divul.l	d1,d5:d7		; d7 = partie entiäre de (lsour / ldest)
	divu.l	d1,d5:d6		; d6 = partie fractionnaire de (lsour / ldest)
	cmp.w	#2,d2
	beq.s	.16bits

.8bits:
	move.l	d1,d2
	subq.l	#1,d2		; d2 = compteur
	cmp.l	d0,d1		; Destination > source ?
	bgt.s	.8backw		; Oui, on marche Ö reculons

;--- A l'endroit si dest<source ----------------------------------------------
	moveq	#0,d0		; d0 = pointeur source
	moveq	#0,d1		; d1 =    "       "    partie fractionnaire
	swap	d2
.8fwlp1:	swap	d2
.8fwlp2:	move.b	(a0,d0.l),(a1)+	; Copie le sample
	add.l	d6,d1
	addx.l	d7,d0		; IncrÇmente le pointeur
	dbra	d2,.8fwlp2
	swap	d2
	dbra	d2,.8fwlp1
	bra	chgsamfreq_end

;--- A l'envers si dest>source -----------------------------------------------
.8backw:	add.l	d1,a1
	subq.l	#1,d0
	moveq	#-1,d1
	swap	d2
.8bwlp1:	swap	d2
.8bwlp2:	move.b	(a0,d0.l),-(a1)	; Copie le sample
	sub.l	d6,d1
	bcc.s	.8nc
	subq.l	#1,d0
.8nc:	sub.l	d7,d0		; IncrÇmente le pointeur
	dbra	d2,.8bwlp2
	swap	d2
	dbra	d2,.8bwlp1
	bra	chgsamfreq_end

.16bits:
	move.l	d1,d2
	lsr.l	#1,d2
	subq.l	#1,d2		; d2 = compteur
	cmp.l	d0,d1		; Destination > source ?
	bgt.s	.16backw		; Oui, on marche Ö reculons

;--- A l'endroit si dest<source ----------------------------------------------
	moveq	#0,d0		; d0 = pointeur source
	moveq	#0,d1		; d1 =    "       "    partie fractionnaire
	swap	d2
.16fwlp1:	swap	d2
.16fwlp2:	move.w	(a0,d0.l*2),(a1)+	; Copie le sample
	add.l	d6,d1
	addx.l	d7,d0		; IncrÇmente le pointeur
	dbra	d2,.16fwlp2
	swap	d2
	dbra	d2,.16fwlp1
	bra	chgsamfreq_end

;--- A l'envers si dest>source -----------------------------------------------
.16backw:	add.l	d1,a1
	lsr.l	#1,d0
	subq.l	#1,d0
	moveq	#0,d1
	swap	d2
.16bwlp1:	swap	d2
.16bwlp2:	move.w	(a0,d0.l*2),-(a1)	; Copie le sample
	sub.l	d6,d1
	bcc.s	.16nc
	subq.l	#1,d0
.16nc:	sub.l	d7,d0		; IncrÇmente le pointeur
	dbra	d2,.16bwlp2
	swap	d2
	dbra	d2,.16bwlp1
	bra	chgsamfreq_end

; RÇÇchantillonnage avec interpolation linÇaire 
chgsamfreq_interplin:
	move.l	d0,d7
	moveq	#0,d6
	divul.l	d1,d5:d7		; d7 = partie entiäre de (lsour / ldest)
	divu.l	d1,d5:d6		; d6 = partie fractionnaire de (lsour / ldest)
	cmp.w	#2,d2
	beq	.16bits

.8bits:
	move.l	d1,d2
	subq.l	#1,d2		; d2 = compteur
	cmp.l	d0,d1		; Destination > source ?
	bgt.s	.8backw		; Oui, on marche Ö reculons

;--- A l'endroit si dest<source ----------------------------------------------
	moveq	#0,d0		; d0 = pointeur source
	moveq	#0,d1		; d1 =    "       "    partie fractionnaire
	swap	d2
.8fwlp1:	swap	d2
.8fwlp2:
	move.b	1(a0,d0.l),d3	; On prend le 2äme sample
	ext.w	d3
	move.l	d1,d4		; On prend la partie fractionnaire
	swap	d4
	lsr.w	#1,d4		; -> mot non signÇ 0-$7fff
	muls.w	d4,d3

	move.b	(a0,d0.l),d5	; On prend le 1er sample
	ext.w	d5
	sub.w	#$8000,d4		; d4 = - (1 - partie fractionnaire)
	muls.w	d4,d5		; Le rÇsultat est nÇgatif
	sub.l	d5,d3		; C'est pour áa qu'on le soustrait Ö l'autre
	add.l	d3,d3		; RÇajuste Ö cause du bit de signe
	swap	d3		; On prend que ce dont on a besoin
	move.b	d3,(a1)+		; Copie le sample

	add.l	d6,d1
	addx.l	d7,d0		; IncrÇmente le pointeur
	dbra	d2,.8fwlp2
	swap	d2
	dbra	d2,.8fwlp1
	bra	chgsamfreq_end

;--- A l'envers si dest>source -----------------------------------------------
.8backw:	add.l	d1,a1
	subq.l	#1,d0
	moveq	#-1,d1
	swap	d2
.8bwlp1:	swap	d2
.8bwlp2:
	move.b	1(a0,d0.l),d3	; On prend le 2äme sample
	ext.w	d3
	move.l	d1,d4		; On prend la partie fractionnaire
	swap	d4
	lsr.w	#1,d4		; -> mot non signÇ 0-$7fff
	muls.w	d4,d3

	move.b	(a0,d0.l),d5	; On prend le 1er sample
	ext.w	d5
	sub.w	#$8000,d4		; d4 = - (1 - partie fractionnaire)
	muls.w	d4,d5		; Le rÇsultat est nÇgatif
	sub.l	d5,d3		; C'est pour áa qu'on le soustrait Ö l'autre
	add.l	d3,d3		; RÇajuste Ö cause du bit de signe
	swap	d3		; On prend que ce dont on a besoin
	move.b	d3,-(a1)		; Copie le sample

	sub.l	d6,d1
	bcc.s	.8nc
	subq.l	#1,d0
.8nc:	sub.l	d7,d0		; IncrÇmente le pointeur
	dbra	d2,.8bwlp2
	swap	d2
	dbra	d2,.8bwlp1
	bra	chgsamfreq_end

.16bits:
	move.l	d1,d2
	lsr.l	#1,d2
	subq.l	#1,d2		; d2 = compteur
	cmp.l	d0,d1		; Destination > source ?
	bgt.s	.16backw		; Oui, on marche Ö reculons

;--- A l'endroit si dest<source ----------------------------------------------
	moveq	#0,d0		; d0 = pointeur source
	moveq	#0,d1		; d1 =    "       "    partie fractionnaire
	swap	d2
.16fwlp1:	swap	d2
.16fwlp2:
	move.w	2(a0,d0.l*2),d3	; On prend le 2äme sample
	move.l	d1,d4		; On prend la partie fractionnaire
	swap	d4
	lsr.w	#1,d4		; -> mot non signÇ 0-$7fff
	muls.w	d4,d3

	move.w	(a0,d0.l*2),d5	; On prend le 1er sample
	sub.w	#$8000,d4		; d4 = - (1 - partie fractionnaire)
	muls.w	d4,d5		; Le rÇsultat est nÇgatif
	sub.l	d5,d3		; C'est pour áa qu'on le soustrait Ö l'autre
	add.l	d3,d3		; RÇajuste Ö cause du bit de signe
	swap	d3		; On prend que ce dont on a besoin
	move.w	d3,(a1)+		; Copie le sample

	add.l	d6,d1
	addx.l	d7,d0		; IncrÇmente le pointeur
	dbra	d2,.16fwlp2
	swap	d2
	dbra	d2,.16fwlp1
	bra.s	chgsamfreq_end

;--- A l'envers si dest>source -----------------------------------------------
.16backw:	add.l	d1,a1
	lsr.l	#1,d0
	subq.l	#1,d0
	moveq	#-1,d1
	swap	d2
.16bwlp1:	swap	d2
.16bwlp2:
	move.w	2(a0,d0.l*2),d3	; On prend le 2äme sample
	move.l	d1,d4		; On prend la partie fractionnaire
	swap	d4
	lsr.w	#1,d4		; -> mot non signÇ 0-$7fff
	muls.w	d4,d3

	move.w	(a0,d0.l*2),d5	; On prend le 1er sample
	sub.w	#$8000,d4		; d4 = - (1 - partie fractionnaire)
	muls.w	d4,d5		; Le rÇsultat est nÇgatif
	sub.l	d5,d3		; C'est pour áa qu'on le soustrait Ö l'autre
	add.l	d3,d3		; RÇajuste Ö cause du bit de signe
	swap	d3		; On prend que ce dont on a besoin
	move.w	d3,-(a1)		; Copie le sample

	sub.l	d6,d1
	bcc.s	.16nc
	subq.l	#1,d0
.16nc:	sub.l	d7,d0		; IncrÇmente le pointeur
	dbra	d2,.16bwlp2
	swap	d2
	dbra	d2,.16bwlp1
	bra.s	chgsamfreq_end





	nop






chgsamfreq_end:
	movem.l	(sp)+,d0-a6
	rts



*============================================================================*
*	Cherche les volumes stereo d'entrÇe de l'ADC en temps rÇel	*
*	Les buffers de digit ont du àtre activÇs au paravant		*
*	avec la fonction Start_Sample_Recording			*
*	Le volume est renvoyÇ dans d0, mot fort = L, mot faible = R	*
*============================================================================*
cherche_volume_buffer_stereo:
	movem.l	d1-d3/a0,-(sp)
	lea	sample_rec_buffer(pc),a0	; a0 pointe sur un buffer
	add.l	rec_sam_num_buf(pc),a0	; Ajuste sur le bon buffer
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	#1023,d3
.loop:
.left:	move.w	(a0)+,d2
	bmi.s	.neg_l
	neg.w	d2		; d2 = - | d2 |
.neg_l:	cmp.w	d0,d2
	bge.s	.right
	move.w	d2,d0
.right:	move.w	(a0)+,d2
	bmi.s	.neg_r
	neg.w	d2		; d2 = - | d2 |
.neg_r:	cmp.w	d1,d2
	bge.s	.next
	move.w	d2,d1
.next:	dbra	d3,.loop

	neg.w	d0
	swap	d0		; d0 mot fort = volume L
	neg.w	d1
	move.w	d1,d0		; d0 mot faible = volume R

	movem.l	(sp)+,d1-d3/a0
	rts



*============================================================================*
*	Digitalise un son Ö l'aide de la cartouche de ST Replay Pro	*
*============================================================================*
start_sample_recording_strp:





;--- Interruption pour savoir si on dÇpasse le niveau minimum ----------------
interruption_rec_sam_strp_trigger:
	or.w	#$2700,sr
	movem.l	d0-a6,-(sp)
	move.l	adr_record_inf(pc),a0		; a0 pointe sur les infos de digit
	move.w	$fffb0000,d0		; d0 = sample recueilli sur la cartouche (12 bits)




	movem.l	(sp)+,d0-a6
	rte







*============================================================================*
*	Digitalise un son Ö l'aide de l'ADC			*
*============================================================================*
start_sample_recording:
	movem.l	d0-a6,-(sp)
	pea	start_sample_recording2
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d0-a6
	rts

;--- DÇmarrage de l'enregistrement. Routine Superviseur !!! -----------------
start_sample_recording2:
	move.w	#1,flag_sample_rec	; Signale qu'on doit enregistrer
	move.w	#1,flag_sample_rec2	; Signale qu'on va enregistrer

	move.l	$ffff8930.w,old_matrix_cnx	; Sauve les configurations de la matrice
	move.w	$ffff8934.w,old_replay_frequency	; ainsi que la frÇquence de replay

	clr.w	-(sp)
	move.w	#5,-(sp)
	move.w	#$82,-(sp)		; ADC input
	trap	#14
	addq.l	#6,sp

	pea	sample_rec_buffer+4096(pc)
	pea	sample_rec_buffer(pc)
	move.w	#1,-(sp)
	move.w	#$83,-(sp)		; Fixe le buffer d'enregistrement
	trap	#14
	lea	12(sp),sp

	move.w	#1,-(sp)		; 16 bits stereo
	move.w	#$84,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	#2,-(sp)		; Interruption Ö la fin de l'enregistrement
	move.w	#1,-(sp)		; sur MFP gpi7
	move.w	#$87,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#1,-(sp)
	move.w	([adr_record_inf],rec_frequence),-(sp)	; FrÇquence d'Çchantillonnage
	clr.w	-(sp)
	move.w	#%1001,-(sp)	;  +---> DAC et DMA record
	move.w	#3,-(sp)		; ADC----------------^
	move.w	#$8b,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#%1100,-(sp)	; Enregistrement en boucle
	move.w	#$88,-(sp)
	trap	#14
	addq.l	#4,sp

	pea	sample_rec_buffer2+4096(pc)
	pea	sample_rec_buffer2(pc)
	move.w	#1,-(sp)
	move.w	#$83,-(sp)		; Fixe le buffer d'enregistrement numÇro 2
	trap	#14
	lea	12(sp),sp

	clr.l	rec_sam_num_buf	; Commence au buffer 0

	bclr	#7,$fffffa13.w	; Masque
	move.l	$13C.w,old_it_mfp15
	move.l	#interruption_rec_sam_trigger,$13C.w
	bset	#7,$fffffa07.w	; MFP-15
	bset	#3,$fffffa17.w	; Fin d'it en soft
	bset	#7,$fffffa13.w	; DÇmasque : c'est parti mon kiki !

	rts

;--- Interruption (MFP 15) pour savoir si on dÇpasse le niveau minimum ------
interruption_rec_sam_trigger:
	movem.l	d0-d4/a0-a2,-(sp)
	and.w	#%1111100011111111,sr
	bclr	#7,$fffffa0f.w

	tst.w	flag_sample_rec(pc)
	beq	itrecsamrec_stop
	move.l	adr_record_inf(pc),a0		; a0 pointe sur les infos de digit
	lea	sample_rec_buffer(pc),a1	; a1 pointe sur un buffer
	add.l	rec_sam_num_buf(pc),a1	; Ajuste sur le bon buffer
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	rec_trigger(a0),d0	; d0 = valeur seuil
	move.l	#1023,d1		; d1 = nbr - 1 d'ech Ö tester
	cmp.w	#3,rec_canal(a0)	; Left + Right
	beq.s	itrecsamt_mono
	cmp.w	#1,rec_canal(a0)	; Left
	beq.s	itrecsamt_left
	addq.l	#2,a1		; Right

itrecsamt_left:
	move.w	(a1),d2
	bpl.s	.pos
	neg.w	d2		; Valeur abs
.pos:	cmp.l	d0,d2
	bge.s	.trigok
	addq.l	#4,a1		; Sample suivant
	dbra	d1,itrecsamt_left
	bra.s	itrecsamt_fin
.trigok:	move.l	#interruption_rec_sam_record,$13c	; Maintenant on peut enregistrer
	addq.l	#1,d1
	bra	itrecsamrec_left

itrecsamt_mono:
	move.w	(a1),d2		; Celui de gauche d'abord
	bpl.s	.pos1
	neg.w	d2		; Valeur abs
.pos1:	cmp.l	d0,d2
	blt.s	.next
	move.w	2(a1),d2		; Puis celui de droite
	bpl.s	.pos2
	neg.w	d2		; Valeur abs
.pos2:	cmp.l	d0,d2
	bge.s	.trigok
.next	addq.l	#4,a1		; Sample suivant
	dbra	d1,itrecsamt_left
	bra.s	itrecsamt_fin
.trigok:	move.l	#interruption_rec_sam_record,$13c	; Maintenant on peut enregistrer
	addq.l	#1,d1
	bra	itrecsamrec_mono

itrecsamt_fin:
	or.w	#$2700,sr		; Pour ne pas àtre dÇrangÇ
	move.w	#2,flag_sample_rec2	; On est en phase de trigger

	move.l	#sample_rec_buffer,d1
	add.l	rec_sam_num_buf(pc),d1
	move.l	d1,d0		; d0 = adresse dÇbut nouveau buffer
	add.l	#4096,d1		; d1 = adresse fin nouveau buffer
	move.b	#$b0,$ffff8901.w
	move.b	d0,$ffff8907.w
	lsr.w	#8,d0
	move.b	d0,$ffff8905.w
	swap	d0
	move.b	d0,$ffff8903.w
	move.b	d1,$ffff8913.w
	lsr.w	#8,d1
	move.b	d1,$ffff8911.w
	swap	d1
	move.b	d1,$ffff890f.w

	eor.l	#4096,rec_sam_num_buf	; Change de buffer pour la prochaine fois
	movem.l	(sp)+,d0-d4/a0-a2
	rte

;--- Interruption (MFP 15) de transfert buffer -> sample --------------------
interruption_rec_sam_record:
	movem.l	d0-d4/a0-a2,-(sp)
	and.w	#%1111100011111111,sr
	bclr	#7,$fffffa0f.w

	tst.w	flag_sample_rec(pc)
	beq	itrecsamrec_stop
	move.l	adr_record_inf(pc),a0		; a0 pointe sur les infos de digit
	lea	sample_rec_buffer(pc),a1	; a1 pointe sur un buffer
	add.l	rec_sam_num_buf(pc),a1	; Ajuste sur le bon buffer
	moveq	#0,d1
	move.l	#1024,d1		; d1 = nbr d'ech Ö copier
	cmp.w	#3,rec_canal(a0)	; Left + Right
	beq	itrecsamrec_mono
	cmp.w	#1,rec_canal(a0)	; Left
	beq.s	itrecsamrec_left
	addq.l	#2,a1		; Right

itrecsamrec_left:
	move.l	rec_adresse(a0),a2	; a2 = adresse du sample
	move.l	rec_position(a0),d2	; d2 = position dans le sample
	cmp.w	#2,rec_nbits(a0)
	beq.s	.16bits

.8bits:
	move.l	rec_longueur(a0),d3
	sub.l	d2,d3		; d3 = nbr d'ech avant la fin du sample
	cmp.l	d3,d1
	blt.s	.8assez		; Y en a assez
	sub.l	d3,d1
	subq.l	#1,d3
.8loopt:	move.b	(a1),(a2,d2.l)
	addq.l	#4,a1
	addq.l	#1,d2
	dbra	d3,.8loopt
	bra.s	.8com
.8assez:	subq.l	#1,d1
.8loopa:	move.b	(a1),(a2,d2.l)
	addq.l	#4,a1
	addq.l	#1,d2
	dbra	d1,.8loopa
	moveq	#0,d1
.8com:	move.l	d2,rec_position(a0)	; Nouvelle position sauvÇe
	cmp.l	rec_longueur(a0),d2	; On en est Ö la fin ?
	blt	itrecsamrec_fin	; Non, on continuera la prochaine fois
	tst.w	rec_flag_loop(a0)
	beq	itrecsamrec_stop	; C'est fini, on arràte
	moveq	#0,d2		; Si on boucle, on continue
	move.l	d2,rec_position(a0)
	tst.l	d1
	ble	itrecsamrec_fin	; A pu rien Ö transfÇrer, on continue la prochaine fois
	bra.s	.8bits

.16bits:
	move.l	rec_longueur(a0),d3
	sub.l	d2,d3
	lsr.l	#1,d3		; d3 = nbr d'ech avant la fin du sample
	cmp.l	d3,d1
	blt.s	.16assez		; Y en a assez
	sub.l	d3,d1
	subq.l	#1,d3
.16loopt:	move.w	(a1),(a2,d2.l)
	addq.l	#4,a1
	addq.l	#2,d2
	dbra	d3,.16loopt
	bra.s	.16com
.16assez:	subq.l	#1,d1
.16loopa:	move.w	(a1),(a2,d2.l)
	addq.l	#4,a1
	addq.l	#2,d2
	dbra	d1,.16loopa
	moveq	#0,d1
.16com:	move.l	d2,rec_position(a0)	; Nouvelle position sauvÇe
	cmp.l	rec_longueur(a0),d2	; On en est Ö la fin ?
	blt	itrecsamrec_fin	; Non, on continuera la prochaine fois
	tst.w	rec_flag_loop(a0)
	beq	itrecsamrec_stop	; C'est fini, on arràte
	moveq	#0,d2		; Si on boucle, on continue
	move.l	d2,rec_position(a0)
	tst.l	d1
	ble	itrecsamrec_fin	; A pu rien Ö transfÇrer, on continue la prochaine fois
	bra.s	.16bits

itrecsamrec_mono:
	move.l	rec_adresse(a0),a2	; a2 = adresse du sample
	move.l	rec_position(a0),d2	; d2 = position dans le sample
	cmp.w	#2,rec_nbits(a0)
	beq.s	.16bits

.8bits:
	move.l	rec_longueur(a0),d3
	sub.l	d2,d3		; d3 = nbr d'ech avant la fin du sample
	cmp.l	d3,d1
	blt.s	.8assez		; Y en a assez
	sub.l	d3,d1
	subq.l	#1,d3
.8loopt:	move.b	(a1),d0
	ext.w	d0
	move.b	2(a1),d4
	ext.w	d4
	add.w	d4,d0
	lsr.w	#1,d0
	move.b	d0,(a2,d2.l)
	addq.l	#4,a1
	addq.l	#1,d2
	dbra	d3,.8loopt
	bra.s	.8com
.8assez:	subq.l	#1,d1
.8loopa:	move.b	(a1),d0
	ext.w	d0
	move.b	2(a1),d4
	ext.w	d4
	add.w	d4,d0
	lsr.w	#1,d0
	move.b	d0,(a2,d2.l)
	addq.l	#4,a1
	addq.l	#1,d2
	dbra	d1,.8loopa
	moveq	#0,d1
.8com:	move.l	d2,rec_position(a0)	; Nouvelle position sauvÇe
	cmp.l	rec_longueur(a0),d2	; On en est Ö la fin ?
	blt	itrecsamrec_fin	; Non, on continuera la prochaine fois
	tst.w	rec_flag_loop(a0)
	beq.s	itrecsamrec_stop	; C'est fini, on arràte
	moveq	#0,d2		; Si on boucle, on continue
	move.l	d2,rec_position(a0)
	tst.l	d1
	ble	itrecsamrec_fin	; A pu rien Ö transfÇrer, on continue la prochaine fois
	bra.s	.8bits

.16bits:
	move.l	rec_longueur(a0),d3
	sub.l	d2,d3
	lsr.l	#1,d3		; d3 = nbr d'ech avant la fin du sample
	cmp.l	d3,d1
	blt.s	.16assez		; Y en a assez
	sub.l	d3,d1
	subq.l	#1,d3
.16loopt:	move.w	(a1),d0
	ext.l	d0
	move.w	2(a1),d4
	ext.l	d4
	add.l	d4,d0
	lsr.l	#1,d0
	move.w	d0,(a2,d2.l)
	addq.l	#4,a1
	addq.l	#2,d2
	dbra	d3,.16loopt
	bra.s	.16com
.16assez:	subq.l	#1,d1
.16loopa:	move.w	(a1),d0
	ext.l	d0
	move.w	2(a1),d4
	ext.l	d4
	add.l	d4,d0
	lsr.l	#1,d0
	move.w	d0,(a2,d2.l)
	addq.l	#4,a1
	addq.l	#2,d2
	dbra	d1,.16loopa
	moveq	#0,d1
.16com:	move.l	d2,rec_position(a0)	; Nouvelle position sauvÇe
	cmp.l	rec_longueur(a0),d2	; On en est Ö la fin ?
	blt.s	itrecsamrec_fin	; Non, on continuera la prochaine fois
	tst.w	rec_flag_loop(a0)
	beq.s	itrecsamrec_stop	; C'est fini, on arràte
	moveq	#0,d2		; Si on boucle, on continue
	move.l	d2,rec_position(a0)
	tst.l	d1
	ble.s	itrecsamrec_fin	; A pu rien Ö transfÇrer, on continue la prochaine fois
	bra.s	.16bits

itrecsamrec_stop:
	or.w	#$2700,sr		; Evite les problämes
	clr.w	-(sp)		; Plus d'interruption Ö la fin de l'enregistrement
	move.w	#1,-(sp)		; sur MFP gpi7
	move.w	#$87,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	flag_sample_rec
	move.w	#4,flag_sample_rec2
	bclr	#7,$fffffa07.w	; Annule MFP-15
	bclr	#7,$fffffa13.w	; Masque l'interruption
	move.l	old_it_mfp15,$13C.w

	clr.w	-(sp)		; Arret de l'enregistrement
	move.w	#$88,-(sp)
	trap	#14
	addq.l	#4,sp

	move.l	old_matrix_cnx(pc),$ffff8930.w	; Reprend les configurations de la matrice
	move.w	old_replay_frequency(pc),$ffff8934.w	; ainsi que la frÇquence de replay

	bra.s	itrecsamrec_fin2

itrecsamrec_fin:
	or.w	#$2700,sr		; Pour ne pas àtre dÇrangÇ
	move.w	#3,flag_sample_rec2	; On est en phase d'enregistrement

	move.l	#sample_rec_buffer,d1
	add.l	rec_sam_num_buf(pc),d1
	move.l	d1,d0		; d0 = adresse dÇbut nouveau buffer
	add.l	#4096,d1		; d1 = adresse fin nouveau buffer
	move.b	#$b0,$ffff8901.w
	move.b	d0,$ffff8907.w
	lsr.w	#8,d0
	move.b	d0,$ffff8905.w
	swap	d0
	move.b	d0,$ffff8903.w
	move.b	d1,$ffff8913.w
	lsr.w	#8,d1
	move.b	d1,$ffff8911.w
	swap	d1
	move.b	d1,$ffff890f.w

	eor.l	#4096,rec_sam_num_buf	; Change de buffer pour la prochaine fois

itrecsamrec_fin2:
	movem.l	(sp)+,d0-d4/a0-a2
	rte



*============================================================================*
*	Affiche un vumätre					*
*	d0 = volume.w actuel					*
*	d1 = volume.w maximum atteint rÇcemment			*
*	d2 = colonne.w d'affichage (16 pixels/colonne)		*
*	d3 = ligne.w d'affichage				*
*	d4 = hauteur.w du vumätre en pixels			*
*============================================================================*
affiche_vumetre:
	movem.l	d0-d4/d6-d7/a0-a1,-(sp)
	move.l	adrecr(pc),a0
	lsl.w	#3,d2
	add.w	d2,a0
	moveq	#0,d2
	move.w	linewidth(pc),d2	; d2 = largeur d'une ligne en octets
	mulu.w	d2,d3
	add.l	d3,a0		; a0 = adresse d'affichage
	swap	d0		; Volumes * $10000
	clr.w	d0
	tst.l	d0
	bpl.s	.vol1ok
	subq.l	#1,d0		; Au cas ou volume = $8000 0000
.vol1ok:	swap	d1
	clr.w	d1
	tst.l	d1
	bpl.s	.vol2ok
	subq.l	#1,d1
.vol2ok:	move.l	#$7fffffff,d7
	move.l	d7,d6		; d6 = volume Ö la 1äre ligne
	ext.l	d4
	divu.l	d4,d7		; d7 = incrÇment de volume / ligne
	subq.w	#1,d4		; d4 = compteur de ligne

.loop:	move.l	a0,a1
	cmp.l	d0,d6
	ble.s	.aff1		; Si on est dans le volume normal
	cmp.l	d1,d6
	ble.s	.aff2		; Si on est dans le volume "fantìme"
.aff0:	clr.l	(a1)+		; Et si on n'a pas encore atteint 1 des 2 volumes
	clr.l	(a1)		; Noir
	bra.s	.affnext
.aff1:	move.l	#$ffff0000,(a1)+	; Bleu
	clr.l	(a1)
	bra.s	.affnext
.aff2:	clr.l	(a1)+		; Marron
	move.l	#$ffff0000,(a1)
.affnext:	add.l	d2,a0
	sub.l	d7,d6
	dbra	d4,.loop

	movem.l	(sp)+,d0-d4/d6-d7/a0-a1
	rts



*============================================================================*
*	Mixage de plusieurs samples				*
*	a0 = adresse d'un bloc d'informations			*
*	Ce bloc est composÇ de :				*
*	  - L : Adresse du buffer de destination			*
*	  - L : Longueur du buffer en octets			*
*	  - W : Taille d'un sample en octets (1 ou 2)		*
*	  - W : Nombre de samples Ö mixer			*
*	  - Informations sur chaque sample :			*
*	     - W : Nombre d'octets par sample (1 ou 2)		*
*	     - L : Adresse du sample				*
*	     - L : Point de rÇpÇtition du sample (-1 si pas boucle,	*
*	           -2 si plus rien Ö jouer)			*
*	     - L : Longueur du sample				*
*	     - L : Position courante				*
*	     - L : Volume de dÇbut (poids fort /32768)		*
*	     - L : Volume de dÇbut (poids faible, 32 bits)		*
*	     - L : IncrÇment de volume pour chaque sample (poids fort,	*
*	           /32768)					*
*	     - L : IncrÇment de volume pour chaque sample (poids faible,	*
*	           32 bits)					*
*	Attention, le tableau est modifiÇ pendant la routine		*
*============================================================================*
mixage_samples:
	movem.l	d0-a6,-(sp)
	add.w	#12,a0		; a0 au dÇbut des descripteurs de sample
	tst.w	mix2_nbrspl(a0)	; Tests de sÇcutitÇ
	beq	mixspl_fin
	tst.l	mix2_lonbuf(a0)
	beq	mixspl_fin

mixspl_mainloop:
	moveq	#0,d1		; d1 = sample destination
	move.l	a0,a1		; a1 pointe sur les infos du spl
	move.w	mix2_nbrspl(a0),d0
	subq.w	#1,d0		; d0 = compteur de sample

mixspl_splloop:
	cmp.l	#-2,mix_reps(a1)	; Sample fini ?
	beq	mixspl_splfin	; oui, suivant
	move.l	mix_pos(a1),d6	; d6 = position du sample (rÇutilisÇ en fin de boucle)
	move.l	mix_volh(a1),d5	; d5 = volume, poids fort (idem)
	cmp.w	#2,mix_nbits(a1)
	beq.s	.mix16

.mix8:	move.b	([mix_sadr,a1],d6.l),d2	; d2 = sample 8 bits
	asl.w	#8,d2		; Conversion 16 bits
	tst.w	d2
	bmi.s	.mix16n
	bra.s	.mix16p

.mix16:	moveq	#0,d4
	move.w	([mix_sadr,a1],d6.l),d2	; d2 = sample 16 bits
	bpl.s	.mix16p		; Si c'est positif

.mix16n:	neg.w	d2
	move.l	d5,d7
	add.l	d7,d7		; Volume /32768 -> /65536
	move.w	d7,d4		; d4 = vol mot faible
	clr.w	d7
	swap	d7		; d7 = vol mot fort
	mulu.w	d2,d7
	mulu.w	d2,d4
	clr.w	d4
	swap	d4
	add.l	d4,d7		; Mixage rÇsultat mots fort et faible
	neg.l	d7
	add.l	d7,d1		; Mixage rÇsultat mot faible
	bra.s	.mixfin

.mix16p:	move.l	d5,d7
	add.l	d7,d7		; Volume /32768 -> /65536
	move.w	d7,d4		; d4 = vol mot faible
	clr.w	d7
	swap	d7		; d7 = vol mot fort
	mulu.w	d2,d7
	mulu.w	d2,d4
	clr.w	d4
	swap	d4
	add.l	d4,d7		; Mixage rÇsultat mots fort et faible
	add.l	d7,d1		; Mixage rÇsultat mot faible

.mixfin:	moveq	#0,d7
	move.w	mix_nbits(a1),d7	; IncrÇmente la position
	add.l	d7,d6
	move.l	d6,mix_pos(a1)
	cmp.l	mix_repe(a1),d6
	blt.s	.rep_fin
	move.l	mix_reps(a1),mix_pos(a1)	; Bouclage
	tst.l	mix_reps(a1)	; Mais, les rÇpÇtitions Çtaient autorisÇes ?
	bpl.s	.rep_fin
	move.l	#-2,mix_reps(a1)	; Non, c'est terminÇ
.rep_fin:	move.l	mix_ivoll(a1),d6	; IncrÇmente le volume du sample
	move.l	mix_ivolh(a1),d7
	add.l	d6,mix_voll(a1)
	addx.l	d7,d5
	move.l	d5,mix_volh(a1)
mixspl_splfin:
	add.w	#mix_next,a1	; Sample suivant
	dbra	d0,mixspl_splloop

	moveq	#0,d0
	move.w	mix2_nbits(a0),d0
	cmp.w	#2,d0
	beq.s	.dest16
.dest8:	asr.l	#8,d1		; Conversion 8 bits
	cmp.w	#MAX_SBYTE,d1
	ble.s	.d8ok1
	moveq	#MAX_SBYTE,d1
.d8ok1:	cmp.w	#MIN_SBYTE,d1
	bge.s	.d8ok2
	moveq	#MIN_SBYTE,d1
.d8ok2:	move.b	d1,([mix2_adrbuf,a0])	; Destination 8 bits
	bra.s	.destend
.dest16:	cmp.l	#MAX_SWORD,d1
	ble.s	.d16ok1
	move.w	#MAX_SWORD,d1
.d16ok1:	cmp.l	#MIN_SWORD,d1
	bge.s	.d16ok2
	move.w	#MIN_SWORD,d1
.d16ok2:	move.w	d1,([mix2_adrbuf,a0])	; Destination 16 bits
.destend:	add.l	d0,mix2_adrbuf(a0)
	sub.l	d0,mix2_lonbuf(a0)
	bgt	mixspl_mainloop

mixspl_fin:
	movem.l	(sp)+,d0-a6
	rts



*============================================================================*
*	Modifie le volume d'un son				*
*	a0 = adresse du son					*
*	d0 = longueur.l en octets				*
*	d1 = volume.l de dÇbut /32768				*
*	d2,d3 = incrÇment de volume pour chaque sample (d3 = prÇcision)	*
*	d4 = nbr.w d'octets par sample (1 ou 2)			*
*============================================================================*
change_volume_sample:
	movem.l	d0-d7/a0,-(sp)
	add.l	d3,d3		; Resize de 31 Ö 32 bits
	moveq	#0,d7		; d7 = prÇcision du volume courant
	cmp.w	#2,d4
	beq.s	.16bits
.8bits:
	subq.l	#1,d0
	swap	d0
.8_loop2:	swap	d0
.8_loop1:	move.l	d2,-(sp)
	move.b	(a0),d2
	extb.l	d2
	muls.l	d1,d2
	add.l	d2,d2
	swap	d2
	cmp.w	#MAX_SBYTE,d2
	ble.s	.8_t2
	moveq	#MAX_SBYTE,d2
	bra.s	.8_ok
.8_t2:	cmp.w	#MIN_SBYTE,d2
	bge.s	.8_ok
	moveq	#MIN_SBYTE,d2
.8_ok:	move.b	d2,(a0)+
	move.l	(sp)+,d2
	add.l	d3,d7		; Change le volume pour le sample suivant
	addx.l	d2,d1
	dbra	d0,.8_loop1
	swap	d0
	dbra	d0,.8_loop2
	bra	.fin

.16bits:
	add.l	d1,d1		; Convertit /32768 -> /65536
	add.l	d3,d3
	addx.l	d2,d2
	lsr.l	#1,d0
	subq.l	#1,d0
	swap	d0
.16_loop2:	swap	d0
.16_loop1:	move.l	d2,-(sp)
	move.l	d1,d5
	clr.w	d5
	swap	d5		; d5 = poids.w fort du volume
	move.l	d1,d4
	and.l	#$FFFF,d4		; d4 = poids.w faible du volume
	move.w	(a0),d2
	bpl.s	.16_positif
	neg.w	d2
	move.w	d2,d6
	mulu.w	d4,d2
	clr.w	d2
	swap	d2		; d2 = rÇsultat poids faible
	mulu.w	d5,d6		; d6 = rÇsultat poids fort
	add.l	d6,d2		; d2 = rÇsultat entier
	cmp.l	#32768,d2
	ble.s	.16_n_ok
	move.w	#32768,d2
.16_n_ok:	neg.w	d2
	move.w	d2,(a0)+
	move.l	(sp)+,d2
	add.l	d3,d7
	addx.l	d2,d1		; Change le volume pour le sample suivant
	dbra	d0,.16_loop1
	swap	d0
	dbra	d0,.16_loop2
	bra.s	.fin
.16_positif:
	move.w	d2,d6
	mulu.w	d4,d2
	clr.w	d2
	swap	d2		; d2 = rÇsultat poids faible
	mulu.w	d5,d6		; d6 = rÇsultat poids fort
	add.l	d6,d2		; d2 = rÇsultat entier
	cmp.l	#MAX_SWORD,d2
	ble.s	.16_p_ok
	move.w	#MAX_SWORD,d2
.16_p_ok:	move.w	d2,(a0)+
	move.l	(sp)+,d2
	add.l	d3,d7
	addx.l	d2,d1		; Change le volume pour le sample suivant
	dbra	d0,.16_loop1
	swap	d0
	dbra	d0,.16_loop2

.fin:
	movem.l	(sp)+,d0-d7/a0
	rts



*============================================================================*
*	Recherche du volume maximum d'un son			*
*	a0 = adresse du son					*
*	d1 = longueur.l en octets				*
*	d2 = nombre.w d'octets par sample			*
*	Retour : volume dans d0				*
*============================================================================*
cherche_volume_sample:
	movem.l	d1/d2/a0,-(sp)
	moveq	#0,d0		; Volume maxi dans d0
	bmi.s	.fin		; Si longueur nulle
	subq.l	#1,d1
	cmp.w	#2,d2
	beq.s	.16bits

	swap	d1
.loop1:	swap	d1
.loop2:	move.b	(a0)+,d2
	ext.w	d2
	bpl.s	.suite1
	neg.w	d2		; Valeur absolue
.suite1:	cmp.w	d0,d2
	ble.s	.suite2
	move.w	d2,d0
.suite2:	dbra	d1,.loop2
	swap	d1
	dbra	d1,.loop1
	bra.s	.fin

.16bits:	lsr.l	#1,d1
	swap	d1
.16loop1:	swap	d1
.16loop2:	move.w	(a0)+,d2
	ext.l	d2
	bpl.s	.16suite1
	neg.l	d2		; Valeur absolue
.16suite1:	cmp.l	d0,d2
	ble.s	.16suite2
	move.l	d2,d0
.16suite2:	dbra	d1,.16loop2
	swap	d1
	dbra	d1,.16loop1

.fin:	movem.l	(sp)+,d1/d2/a0
	rts



*============================================================================*
*	Convertit une ligne GTK en ligne ProTracker			*
*	a0 = adresse de la ligne GTK				*
*	a1 = adresse de la ligne ProTracker			*
*	a3 = adresse de la table de correspondance des samples 256 octets	*
*	     (256->32). Les samples inexistants sont mis Ö 0.b		*
*	d0 = longueur.w de la ligne GTK				*
*============================================================================*
convert_gtk_2_nt:
	movem.l	d0-d5/a0-a3,-(sp)
	lea	nt_pernote(pc),a2	; a2 = adresse des pÇriodes ProTracker
	subq.w	#1,d0

cv_gtk2nt_loop:
	moveq	#0,d1
	move.b	(a0)+,d1		; d1 = note
	beq.s	.pas_note
	sub.w	#36,d1
	bpl.s	.note_t2
.note_t1:	add.w	#12,d1		; Trop bas : ajoute 1 octave
	bmi.s	.note_t1
.note_t2:	cmp.w	#36,d1
	blt.s	.note_ok
	sub.w	#12,d1		; Trop haut : enläve 1 octave
	bra.s	.note_t2
.note_ok:	move.w	(a2,d1.w*2),d1
.pas_note:	swap	d1		; Note convertie

	moveq	#0,d2		; d2 = instrument
	move.b	(a0)+,d2
	move.b	(a3,d2.w),d2	; Nouveau numÇro (pour passer de 256 samples Ö
	lsl.w	#8,d2		; 255).
	move.w	d2,d1
	lsl.w	#4,d1		; Poids faible ok
	and.w	#$F000,d2
	swap	d2
	add.l	d2,d1		; Poids fort ok

	moveq	#0,d2		; d2 = rÇsultat de l'effet (0 par dÇfaut)
	move.b	2(a0),d2
	beq.s	.no_vol
	lsr.b	#2,d2
	add.w	#$C00,d2		; Volume sur la colonne

.no_vol:	moveq	#0,d4		; On fait les effets maintenant
	moveq	#0,d5
	move.w	(a0),d3		; d3.w = effet entier
	move.b	(a0)+,d4		; d4.b = No d'effet
	move.b	(a0)+,d5		; d5.b = paramätre

	cmp.b	#1,d4		; Les effets qui ne changent pas
	beq.s	.nochange
	cmp.b	#2,d4
	beq.s	.nochange
	cmp.b	#3,d4
	beq.s	.nochange
	cmp.b	#4,d4
	beq.s	.nochange
	cmp.b	#7,d4
	beq.s	.nochange
	cmp.b	#$B,d4
	beq.s	.nochange
	cmp.b	#$F,d4
	bne.s	.suite
.nochange:	move.w	d3,d2
	bra	.fin

.suite:	cmp.b	#$05,d4		; Porta (+vib)
	bne.s	.06
	move.w	#$300,d2
	move.w	d5,d2
	bra	.fin
.06:	cmp.b	#$06,d4		; (vib+) Porta
	beq.s	.06_ok
	cmp.b	#$1A,d4		; (vol sl up exp+) porta
	beq.s	.06_ok
	cmp.b	#$1B,d4		; (vol sl down exp+) porta
	bne.s	.08
.06_ok:	move.w	#$300,d2
	bra	.fin
.08:	cmp.b	#$08,d4		; Set finetune
	bne.s	.09
	move.b	d5,d4
	; and.b	#15,d4		; Inutile ?
	lsr.b	#4,d5
	sub.b	d4,d5
	and.b	#15,d5
	add.w	#$E50,d5
	move.w	d5,d2
	bra	.fin
.09:	cmp.b	#$09,d4		; Note delay
	bne.s	.0A
	cmp.b	#15,d5
	ble.s	.09ok
	move.b	#15,d5
.09ok:	move.w	#$ED0,d2
	add.b	d5,d2
	bra	.fin
.0A:	cmp.b	#$0A,d4		; Note cut
	bne.s	.0C
	cmp.b	#15,d5
	ble.s	.0Aok
	move.b	#15,d5
.0Aok:	move.w	#$EC0,d2
	add.b	d5,d2
	bra	.fin
.0C:	cmp.b	#$0C,d4		; Set vib wave
	bne.s	.0D
	and.b	#15,d5
	move.w	#$E40,d2
	add.b	d5,d2
	bra	.fin
.0D:	cmp.b	#$0D,d4		; Break pattern to line
	bne.s	.0E
	move.w	#$D00,d2
	divu.w	#10,d5		; Conversion Hexa -> BCD
	lsl.b	#4,d5
	add.b	d5,d2
	swap	d5
	add.b	d5,d2
	bra	.fin
.0E:	cmp.b	#$0E,d4		; Set trem wave
	bne.s	.10
	and.b	#15,d5
	move.w	#$E70,d2
	add.b	d5,d2
	bra	.fin
.10:	cmp.b	#$10,d4		; Arpeggio
	bne.s	.11
	move.w	d5,d2
	bra	.fin
.11:	cmp.b	#$11,d4		; Fine porta up
	bne.s	.12
	cmp.b	#15,d5
	ble.s	.11ok
	move.b	#15,d5
.11ok:	move.w	#$E10,d2
	add.b	d5,d2
	bra	.fin
.12:	cmp.b	#$12,d4		; Fine porta down
	bne.s	.13
	cmp.b	#15,d5
	ble.s	.12ok
	move.b	#15,d5
.12ok:	move.w	#$E20,d2
	add.b	d5,d2
	bra	.fin
.13:	cmp.b	#$13,d4		; Roll + vol slide
	bne.s	.14
	and.b	#15,d5
	move.w	#$E90,d2
	add.b	d5,d2
	bra	.fin
.14:	cmp.b	#$14,d4		; Vol sl up
	bne.s	.15
	addq.w	#3,d5		; Arrondit par excäs
	add.w	d5,d5
	add.w	d5,d5
	and.w	#$F0,d5
	cmp.w	#$F0,d5
	ble.s	.14ok
	move.w	#$F0,d5
.14ok:	move.w	#$A00,d2
	move.b	d5,d2
	bra	.fin
.15:	cmp.b	#$15,d4		; Vol sl down
	bne.s	.18
	addq.w	#3,d5
	lsr.w	#2,d5
	cmp.b	#15,d5
	ble.s	.15ok
	move.b	#15,d5
.15ok:	move.w	#$A00,d2
	move.b	d5,d2
	bra	.fin
.18	cmp.b	#$18,d4		; Vol sl up + tone porta
	bne.s	.19
	addq.w	#3,d5
	add.w	d5,d5
	add.w	d5,d5
	and.w	#$F0,d5
	cmp.w	#$F0,d5
	ble.s	.18ok
	move.w	#$F0,d5
.18ok:	move.w	#$500,d2
	move.b	d5,d2
	bra	.fin
.19:	cmp.b	#$19,d4		; Vol sl down + tone porta
	bne.s	.1C
	addq.w	#3,d5
	lsr.w	#2,d5
	cmp.b	#15,d5
	ble.s	.19ok
	move.b	#15,d5
.19ok:	move.w	#$500,d2
	move.b	d5,d2
	bra	.fin
.1C	cmp.b	#$1C,d4		; Vol sl up + vib
	bne.s	.1D
	addq.w	#3,d5
	add.w	d5,d5
	add.w	d5,d5
	and.w	#$F0,d5
	cmp.w	#$F0,d5
	ble.s	.1Cok
	move.w	#$F0,d5
.1Cok:	move.w	#$600,d2
	move.b	d5,d2
	bra	.fin
.1D:	cmp.b	#$1D,d4		; Vol sl down + vib
	bne.s	.A4
	addq.w	#3,d5
	lsr.w	#2,d5
	cmp.b	#15,d5
	ble.s	.1Dok
	move.b	#15,d5
.1Dok:	move.w	#$600,d2
	move.b	d5,d2
	bra	.fin
.A4:	cmp.b	#$A4,d4		; Fine vol sl up
	bne.s	.A5
	addq.w	#3,d5
	lsr.w	#2,d5
	cmp.b	#15,d5
	ble.s	.A4ok
	move.b	#15,d5
.A4ok:	move.w	#$EA0,d2
	add.b	d5,d2
	bra	.fin
.A5:	cmp.b	#$A5,d4		; Fine vol sl down
	bne.s	.A8
	addq.w	#3,d5
	lsr.w	#2,d5
	cmp.b	#15,d5
	ble.s	.A5ok
	move.b	#15,d5
.A5ok:	move.w	#$EB0,d2
	add.b	d5,d2
	bra	.fin
.A8:	cmp.b	#$A8,d4		; Set nbr of frames
	bne.s	.AA
	move.w	#$F00,d2
	move.b	d5,d2
	bra	.fin
.AA:	cmp.b	#$AA,d4		; Pattern delay
	bne.s	.AB
	cmp.b	#15,d5
	ble.s	.AAok
	move.b	#15,d5
.AAok:	move.w	#$EE0,d2
	add.b	d5,d2
	bra	.fin
.AB:	cmp.b	#$AB,d4		; Extra fine tone porta
	bne.s	.AC
	add.w	#15,d5		; Arrondissement par excäs
	lsr.w	#4,d5
	move.w	#$300,d2
	move.b	d5,d2
	bra	.fin
.AC:	cmp.b	#$AC,d4		; Extra fine porta up
	bne.s	.AD
	add.w	#15,d5		; Arrondissement par excäs
	lsr.w	#4,d5
	move.w	#$100,d2
	move.b	d5,d2
	bra	.fin
.AD:	cmp.b	#$AD,d4		; Extra fine porta down
	bne.s	.2xxx
	add.w	#15,d5		; Arrondissement optimal
	lsr.w	#4,d5
	move.w	#$200,d2
	move.b	d5,d2
	bra	.fin

.B1:	cmp.b	#$B1,d4		; Pattern loop
	bne.s	.2xxx
	cmp.b	#15,d5
	ble.s	.B1ok
	move.b	#15,d5
.B1ok:	move.w	#$EB0,d2
	add.b	d5,d2
	bra.s	.fin

.2xxx:	lsr.b	#4,d4		; d4 = numÇro de fonction Ö 1 chiffre
	and.w	#$FFF,d3		; d3 = paramätre Ö 3 chiffres
	cmp.b	#$2,d4		; Set volume
	bne.s	.3xxx
	lsr.w	#2,d3
	cmp.w	#$40,d5
	ble.s	.2xxxok
	move.w	#$40,d5
.2xxxok:	move.w	#$C00,d2
	move.b	d3,d2
	bra.s	.fin
.3xxx:	cmp.b	#$3,d4		; Set exp vol
	bne.s	.4xxx
	; *** A faire...
	bra.s	.fin
.4xxx:	cmp.b	#$4,d4		; Set balance (-> effet 8xx et non E8x)
	bne.s	.7xxx
	lsr.w	#4,d3
	move.w	#$800,d2
	move.b	d3,d2
	bra.s	.fin
.7xxx:	cmp.b	#$7,d4		; Roll
	bne.s	.8xxx
	lsr.w	#8,d3
	move.w	#$E90,d2
	add.b	d3,d2
	bra.s	.fin
.8xxx:	cmp.b	#$8,d4		; Roll + vol slide + set balance
	bne.s	.9xxx
	and.w	#15,d3
	move.w	#$E90,d2
	add.b	d3,d2
	bra.s	.fin
.9xxx:	cmp.b	#$9,d4		; Offset sample
	bne.s	.fin
	cmp.w	#$FF,d5
	ble.s	.9xxxok
	move.w	#$FF,d5
.9xxxok:	move.w	#$900,d2
	move.b	d3,d2

.fin:	add.w	d2,d1		; Effet converti
	addq.l	#1,a0		; Saute la colonne de volume

	move.l	d1,(a1)+
	dbra	d0,cv_gtk2nt_loop

	movem.l	(sp)+,d0-d5/a0-a3
	rts



*============================================================================*
*	Copie un sample 8 bits en le transformant en sample 16 bits	*
*	a0 = adresse du sample				*
*	a1 = adresse destination				*
*	d0 = longueur du sample 8 bits en octets			*
*============================================================================*
copy_sample_8_2_16:
	movem.l	d0/a0-a1,-(sp)
	add.l	d0,a0
	add.l	d0,a1
	add.l	d0,a1
	subq.l	#1,d0
	bmi.s	.fin
	swap	d0
.loop1:	swap	d0
.loop2:	clr.b	-(a1)
	move.b	-(a0),-(a1)
	dbra	d0,.loop2
	swap	d0
	dbra	d0,.loop1
.fin:	movem.l	(sp)+,d0/a0-a1
	rts



*============================================================================*
*	Copie un sample 16 bits en le transformant en sample 8 bits	*
*	a0 = adresse du sample				*
*	a1 = adresse destination				*
*	d0 = longueur du sample 16 bits en octets			*
*============================================================================*
copy_sample_16_2_8:
	movem.l	d0/a0-a1,-(sp)
	lsr.l	#1,d0
	subq.l	#1,d0
	bmi.s	.fin
	swap	d0
.loop1:	swap	d0
.loop2:	move.b	(a0)+,(a1)+
	addq.l	#1,a0
	dbra	d0,.loop2
	swap	d0
	dbra	d0,.loop1
.fin:	movem.l	(sp)+,d0/a0-a1
	rts



*============================================================================*
*	Inverse un morceau de mÇmoire				*
*	a0 = adresse					*
*	d0 = longueur.l en octets Ö inverser			*
*	d1 = nombre.w d'octets par unitÇ de mÇmoire Ö inverser (1 ou 2)	*
*============================================================================*
invert_memory:
	movem.l	d0-d1/a0-a1,-(sp)
	lea	(a0,d0.l),a1
	lsr.l	#1,d0		; Compteur : la moitiÇ de la longueur (par dÇfaut)
	cmp.w	#2,d1
	beq.s	.word

	subq.l	#1,d0		; Inversion d'octets
	swap	d0
.loop_b1:	swap	d0
.loop_b2:	move.b	(a0),d1
	move.b	-(a1),(a0)+
	move.b	d1,(a1)
	dbra	d0,.loop_b2
	swap	d0
	dbra	d0,.loop_b1
	bra.s	.fin

.word:	lsr.l	#1,d0		; La moitiÇ car inversion de mots
	subq.l	#1,d0
	swap	d0
.loop_w1:	swap	d0
.loop_w2:	move.w	(a0),d1
	move.w	-(a1),(a0)+
	move.w	d1,(a1)
	dbra	d0,.loop_w2
	swap	d0
	dbra	d0,.loop_w1

.fin:	movem.l	(sp)+,d0-d1/a0-a1
	rts



*============================================================================*
*	Routine de dÇcompression de l'Atomik Packer 3.5		*
*	a0 = adresse du fichier Ö dÇcompresser			*
*============================================================================*
atomik_35_unpack:
	movem.l	a0-a6/d0-d7,-(a7)
	cmp.l	#$41544d35,(a0)+	; Identificateur 'ATM5'
	bne	atm35_e1
	link	a2,#-$1c
	move.l	(a0)+,d0
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	move.l	a5,a4
	lea	128(a4),a5
	lea	-12(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	moveq	#0,d0
	move.b	-(a6),d0
	move.w	d0,-2(a2)
	lsl.w	#2,d0
	sub.w	d0,a4
	lea	atm35_eb(pc),a3
	move.w	-2(a2),d0
	lsl.w	#2,d0
	add.w	#$8c,d0
	bra.s	atm35_b5
atm35_b4:	move.b	(a4)+,(a3)+
	subq.w	#1,d0
atm35_b5:	bne.s	atm35_b4
	movem.l	a3-a4,-(a7)
	pea	(a5)
	move.b	-(a6),d7
	bra	atm35_d5
atm35_b6:	move.w	d3,d5
atm35_b7:	add.b	d7,d7
atm35_b8:	dbcs	d5,atm35_b7
	beq.s	atm35_bb
	bcc.s	atm35_b9
	sub.w	d3,d5
	neg.w	d5
	bra.s	atm35_be
atm35_b9:	moveq	#3,d6
	bsr.s	atm35_c4
	beq.s	atm35_ba
	bra.s	atm35_bd
atm35_ba:	moveq	#7,d6
	bsr.s	atm35_c4
	beq.s	atm35_bc
	add.w	#$f,d5
	bra.s	atm35_bd
atm35_bb:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	atm35_b8
atm35_bc:	moveq	#$d,d6
	bsr.s	atm35_c4
	add.w	#$10e,d5
atm35_bd:	add.w	d3,d5
atm35_be:	lea	atm35_e2(pc),a4
	move.w	d5,d2
	bne.s	atm35_c8
	add.b	d7,d7
	bne.s	atm35_bf
	move.b	-(a6),d7
	addx.b	d7,d7
atm35_bf:	bcs.s	atm35_c0
	moveq	#1,d6
	bra.s	atm35_c9
atm35_c0:	moveq	#3,d6
	bsr.s	atm35_c4
	tst.b	-28(a2)
	beq.s	atm35_c1
	move.b	-18(a2,d5.w),-(a5)
	bra	atm35_d4
atm35_c1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	atm35_c2
	bra.s	atm35_c3
atm35_c2:	add.b	#-$10,d5
atm35_c3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	atm35_d4
atm35_c4:	clr.w	d5
atm35_c5:	add.b	d7,d7
	beq.s	atm35_c7
atm35_c6:	addx.w	d5,d5
	dbra	d6,atm35_c5
	tst.w	d5
	rts
atm35_c7:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	atm35_c6
atm35_c8:	moveq	#2,d6
atm35_c9:	bsr.s	atm35_c4
	move.w	d5,d4
	move.b	14(a4,d4.w),d6
	ext.w	d6
	tst.b	-27(a2)
	bne.s	atm35_ca
	addq.w	#4,d6
	bra.s	atm35_ce
atm35_ca:	bsr.s	atm35_c4
	move.w	d5,d1
	lsl.w	#4,d1
	moveq	#2,d6
	bsr.s	atm35_c4
	cmp.b	#7,d5
	blt.s	atm35_cc
	moveq	#0,d6
	bsr.s	atm35_c4
	beq.s	atm35_cb
	moveq	#2,d6
	bsr.s	atm35_c4
	add.w	d5,d5
	or.w	d1,d5
	bra.s	atm35_cf
atm35_cb:	or.b	-26(a2),d1
	bra.s	atm35_cd
atm35_cc:	or.b	-25(a2,d5.w),d1
atm35_cd:	move.w	d1,d5
	bra.s	atm35_cf
atm35_ce:	bsr.s	atm35_c4
atm35_cf:	add.w	d4,d4
	beq.s	atm35_d0
	add.w	-2(a4,d4.w),d5
atm35_d0:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
atm35_d1:	move.b	-(a4),-(a5)
	dbra	d2,atm35_d1
	bra.s	atm35_d4
atm35_d2:	add.b	d7,d7
	bne.s	atm35_d3
	move.b	-(a6),d7
	addx.b	d7,d7
atm35_d3:	bcs.s	atm35_dd
	move.b	-(a6),-(a5)
atm35_d4:	cmp.l	a5,a3
	bne.s	atm35_d2
	cmp.l	a6,a0
	beq.s	atm35_de
atm35_d5:	moveq	#0,d6
	bsr	atm35_c4
	beq.s	atm35_d8
	move.b	-(a6),d0
	lea	-26(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
atm35_d6:	cmp.b	d0,d1
	bne.s	atm35_d7
	addq.w	#2,d1
atm35_d7:	move.b	d1,(a1)+
	addq.w	#2,d1
	dbra	d2,atm35_d6
	st	-27(a2)
	bra.s	atm35_d9
atm35_d8:	sf	-27(a2)
atm35_d9:	moveq	#0,d6
	bsr	atm35_c4
	beq.s	atm35_db
	lea	-18(a2),a1
	moveq	#$f,d0
atm35_da:	move.b	-(a6),(a1)+
	dbra	d0,atm35_da
	st	-28(a2)
	bra.s	atm35_dc
atm35_db:	sf	-28(a2)
atm35_dc:	clr.w	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl.w	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub.w	d0,a3
	bra.s	atm35_d2
atm35_dd:	bra	atm35_b6
atm35_de:	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	atm35_e3
	move.l	(a7)+,a2
	movem.l	(a7)+,a3-a4
	move.l	(a7)+,d0
	bsr	atm35_e9
	move.w	-2(a2),d0
	lsl.w	#2,d0
	add.w	#$8c,d0
	bra.s	atm35_e0
atm35_df:	move.b	-(a3),-(a4)
	subq.w	#1,d0
atm35_e0:	bne.s	atm35_df
	unlk	a2
atm35_e1:	movem.l	(a7)+,a0-a6/d0-d7
	rts
atm35_e2:	dc.b	$00,$20,$00,$60,$01,$60,$03,$60
	dc.b	$07,$60,$0f,$60,$1f,$60,$00,$01
	dc.b	$03,$04,$05,$06,$07,$08
atm35_e3:	move.w	-2(a2),d7
atm35_e4:	dbra	d7,atm35_e5
	rts
atm35_e5:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
	lea	32000(a1),a2
atm35_e6:	moveq	#3,d6
atm35_e7:	move.w	(a1)+,d0
	moveq	#3,d5
atm35_e8:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbra	d5,atm35_e8
	dbra	d6,atm35_e7
	movem.w	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	atm35_e6
	bra.s	atm35_e4
atm35_e9:	lsr.l	#4,d0
	lea	-12(a6),a6
atm35_ea:	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbra	d0,atm35_ea
	rts



*============================================================================*
*	Unpacking routine of PACK-ICE 2.4			*
*	a0 = Adress of packed data				*
*============================================================================*
packice_24_unpack:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr	.getinfo
	cmpi.l	#'ICE!',d0
	bne	.not_packed
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(sp)
	adda.l	d0,a6
	move.l	a6,a1

	moveq	#119,d0
.save:	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5


	bsr	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.l	(sp),d0-a3

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1
.getbytes: lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	

.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	


.strings: lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_Åber
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1

.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes


.direkt_tab:
	dc.l	$7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l	270-1,15-1,8-1,5-1,2-1

.length_tab:
	dc.b	9,1,0,-1,-1
	dc.b	8,4,2,1,0

.more_offset:
	dc.b	11,4,7,0		; Bits lesen
	dc.w	$11f,-1,$1f	; Standard Offset



*============================================================================*
*	Unpacking source for Pack-Ice Version 2.1			*
*	a0 = pointer on packed data				*
*============================================================================*
packice_21_unpack:
	movem.l d0-a6,-(sp)		; save registers
	cmpi.l	#'Ice!',(a0)+	; Data packed?
	bne.s	.ice2_07		; no!
	move.l	(a0)+,d0
	lea	-8(a0,d0.l),a5
	move.l	(a0)+,(sp)
	lea	108(a0),a4
	movea.l a4,a6
	adda.l	(sp),a6
	movea.l a6,a3
	movea.l a6,a1		; save 120 bytes
	lea	ice2_21+120(pc),a2	; at the end of the
	moveq	#$77,d0		; unpacked data
.ice2_00:	move.b	-(a1),-(a2)
	dbra	d0,.ice2_00
	bsr	.ice2_0c
	bsr.s	.ice2_08
	bsr	.ice2_10		;; Picture decrunch!
	bcc.s	.ice2_04		;; These marked lines are only
	movea.l a3,a1		;; necessary, if you selected the
	move.w	#$0f9f,d7		;; additional picture packer
.ice2_01:	moveq	#3,d6		;; in Pack-Ice.
.ice2_02:	move.w	-(a1),d4		;;
	moveq	#3,d5		;; If you never use the picture
.ice2_03:	add.w	d4,d4		;; pack option, you may delete
	addx.w	d0,d0		;; all the lines marked with ";;"
	add.w	d4,d4		;;
	addx.w	d1,d1		;;
	add.w	d4,d4		;;
	addx.w	d2,d2		;;
	add.w	d4,d4		;;
	addx.w	d3,d3		;;
	dbra	d5,.ice2_03	;;
	dbra	d6,.ice2_02	;;
	movem.w d0-d3,(a1)		;;
	dbra	d7,.ice2_01	;;
.ice2_04:	move.l	(sp),d0		; move all data to
	lea	-120(a4),a1	; 120 bytes lower
.ice2_05:	move.b	(a4)+,(a1)+
	dbra	d0,.ice2_05
	subi.l	#$010000,d0
	bpl.s	.ice2_05
	moveq	#$77,d0		; restore saved data
	lea	ice2_21+120(pc),a2
.ice2_06:	move.b	-(a2),-(a3)
	dbra	d0,.ice2_06
.ice2_07:	movem.l (sp)+,d0-a6		; restore registers
	rts
.ice2_08:	bsr.s	.ice2_10
	bcc.s	.ice2_0b
	moveq	#0,d1
	bsr.s	.ice2_10
	bcc.s	.ice2_0a
	lea	.ice2_1e(pc),a1
	moveq	#4,d3
.ice2_09:	move.l	-(a1),d0
	bsr.s	.ice2_13
	swap	d0
	cmp.w	d0,d1
	dbne	d3,.ice2_09
	add.l	20(a1),d1
.ice2_0a:	move.b	-(a5),-(a6)
	dbra	d1,.ice2_0a
.ice2_0b:	cmpa.l	a4,a6
	bgt.s	.ice2_16
	rts
.ice2_0c:	moveq	#3,d0
.ice2_0d:	move.b	-(a5),d7
	ror.l	#8,d7
	dbra	d0,.ice2_0d
	rts
.ice2_0e:	move.w	a5,d7
	btst	#0,d7
	bne.s	.ice2_0f
	move.l	-(a5),d7
	addx.l	d7,d7
	bra.s	.ice2_15
.ice2_0f:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	bra.s	.ice2_15
.ice2_10:	add.l	d7,d7
	beq.s	.ice2_11
	rts
.ice2_11:	move.w	a5,d7
	btst	#0,d7
	bne.s	.ice2_12
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
.ice2_12:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
.ice2_13:	moveq	#0,d1
.ice2_14:	add.l	d7,d7
	beq.s	.ice2_0e
.ice2_15:	addx.w	d1,d1
	dbra	d0,.ice2_14
	rts
.ice2_16:	lea	.ice2_1f(pc),a1
	moveq	#3,d2
.ice2_17:	bsr.s	.ice2_10
	dbcc	d2,.ice2_17
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.ice2_18
	bsr.s	.ice2_13
.ice2_18:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.ice2_1a
	lea	.ice2_20(pc),a1
	moveq	#1,d2
.ice2_19:	bsr.s	.ice2_10
	dbcc	d2,.ice2_19
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.ice2_13
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.s	.ice2_1c
.ice2_1a:	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	.ice2_10
	bcc.s	.ice2_1b
	moveq	#8,d0
	moveq	#$40,d2
.ice2_1b:	bsr.s	.ice2_13
	add.w	d2,d1
.ice2_1c:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.ice2_1d:	move.b	-(a1),-(a6)
	dbra	d4,.ice2_1d
	bra	.ice2_08
	dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
	dc.b $00,$07,$00,$02,$00,$03,$00,$01
	dc.b $00,$03,$00,$01
.ice2_1e:	dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
	dc.b $00,$00,$00,$07,$00,$00,$00,$04
	dc.b $00,$00,$00,$01
.ice2_1f:	dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
	dc.b $01,$00
.ice2_20:	dc.b $0b,$04,$07,$00,$01,$20,$00,$00
	dc.b $00,$20



*============================================================================*
*	Copie un groupe de note dans la partition                   Type:	*
*	a0 = pointeur sur un champ de description (Ö mettre : x ) : 0 1 2	*
*	     -  0 : Adresse.l de la premiäre note source Ö copier   x x x	*
*	     -  4 : Adresse.l destination (ou transposition)        x x x	*
*	     -  8 : IncrÇment.l entre chaque ligne                  x x x	*
*	     - 12 : Nombre.w de lignes Ö copier                     x x x	*
*	     - 14 : Adresses.4l des masques de bloc a1, a2, b1, b2  x x x	*
*	     - 30 : Maskblock.w (0 ou 1)                            x x x	*
*	     - 32 : Replaceblock.w (0 ou 1)                         x x x	*
*	     - 34 : Nombre.w de pistes dans un pattern                x	*
*	     - 36 : Nombre.w de pistes dans ce preset                   x	*
*	     - 38 : Type.w de copie : 0=pattern, 1=piste, 2=preset  x x x	*
*	     - 40 : Adresse.l du tableau d'arrangement des pistes       x	*
*	            (sur le bon preset)				*
*============================================================================*
		rsreset
adrsour_bl:	rs.l	1
adrdest_bl:	rs.l	1
increm_bl:		rs.l	1
nlines_bl:		rs.w	1
adra1_bl:		rs.l	1
adra2_bl:		rs.l	1
adrb1_bl:		rs.l	1
adrb2_bl:		rs.l	1
maskblock_bl:	rs.w	1
replaceblock_bl:	rs.w	1
nbr_track_bl:	rs.w	1
preset_ntrk_bl:	rs.w	1
type_bl:		rs.w	1
adrpreset_bl:	rs.l	1

paste_note_block:
	movem.l	d0-d3/a1-a5,-(sp)
	move.l	adrsour_bl(a0),a1	; a1 = adresse source
	move.l	adrdest_bl(a0),a2	; a2 = adresse destination
	move.l	adrpreset_bl(a0),a3	; a3 = adresse du preset
	move.l	increm_bl(a0),d0	; d0 = incrÇment de ligne
	move.w	nlines_bl(a0),d1	; d1 = compteur de lignes
	subq.w	#1,d1
	tst.w	type_bl(a0)
	bne.s	pnb_pattern

pnbtra_loop:			; Track
	bsr	copie_note
	add.l	d0,a1
	add.l	d0,a2
	dbra	d1,pnbtra_loop
	bra.s	pnb_fin

pnb_pattern:			; Pattern
	cmp.w	#1,type_bl(a0)
	bne.s	pnb_preset
pnbpat_loop1:
	move.l	a1,a4
	move.l	a2,a5
	move.w	nbr_track_bl(a0),d2
	subq.w	#1,d2
pnbpat_loop2:
	bsr	copie_note
	addq.l	#5,a1
	addq.l	#5,a2
	dbra	d2,pnbpat_loop2
	move.l	a4,a1
	move.l	a5,a2
	add.l	d0,a1
	add.l	d0,a2
	dbra	d1,pnbpat_loop1
	bra.s	pnb_fin

pnb_preset:			; Preset
pnbpre_loop1:
	move.w	preset_ntrk_bl(a0),d2
	subq.w	#1,d2
	move.l	a1,a4
	move.l	a2,a5
pnbpre_loop2:
	move.w	(a3,d2.w*2),d3
	mulu.w	#5,d3
	add.l	d3,a1
	add.l	d3,a2
	bsr	copie_note
	move.l	a4,a1
	move.l	a5,a2
	dbra	d2,pnbpre_loop2
	add.l	d0,a1
	add.l	d0,a2
	dbra	d1,pnbpre_loop1

pnb_fin:
	movem.l	(sp)+,d0-d3/a1-a5
	rts



*============================================================================*
*	Echange des blocs de note dans un pattern			*
*	a0 = adresse des infos (voir + haut)			*
*	Pas besoin des masque ou de transparence (swap bourrin)	*
*============================================================================*
swap_note_block:
	movem.l	d0-d3/a1-a5,-(sp)
	move.l	adrsour_bl(a0),a1	; a1 = adresse source
	move.l	adrdest_bl(a0),a2	; a2 = adresse destination
	move.l	adrpreset_bl(a0),a3	; a3 = adresse du preset
	move.l	increm_bl(a0),d0	; d0 = incrÇment de ligne
	move.w	nlines_bl(a0),d1	; d1 = compteur de lignes
	subq.w	#1,d1
	tst.w	type_bl(a0)
	bne.s	snb_pattern

snbtra_loop:			; Track
	move.l	(a1),d3
	move.l	(a2),(a1)
	move.l	d3,(a2)
	move.b	4(a1),d3
	move.b	4(a2),4(a1)
	move.b	d3,4(a2)
	add.l	d0,a1
	add.l	d0,a2
	dbra	d1,snbtra_loop
	bra.s	snb_fin

snb_pattern:			; Pattern
	cmp.w	#1,type_bl(a0)
	bne.s	snb_preset
snbpat_loop1:
	move.l	a1,a4
	move.l	a2,a5
	move.w	nbr_track_bl(a0),d2
	subq.w	#1,d2
snbpat_loop2:
	move.l	(a1),d3
	move.l	(a2),(a1)
	move.l	d3,(a2)
	move.b	4(a1),d3
	move.b	4(a2),4(a1)
	move.b	d3,4(a2)
	addq.l	#5,a1
	addq.l	#5,a2
	dbra	d2,snbpat_loop2
	move.l	a4,a1
	move.l	a5,a2
	add.l	d0,a1
	add.l	d0,a2
	dbra	d1,snbpat_loop1
	bra.s	snb_fin

snb_preset:			; Preset
snbpre_loop1:
	move.w	preset_ntrk_bl(a0),d2
	subq.w	#1,d2
	move.l	a1,a4
	move.l	a2,a5
snbpre_loop2:
	move.w	(a3,d2.w*2),d3
	mulu.w	#5,d3
	add.l	d3,a1
	add.l	d3,a2
	move.l	(a1),d3
	move.l	(a2),(a1)
	move.l	d3,(a2)
	move.b	4(a1),d3
	move.b	4(a2),4(a1)
	move.b	d3,4(a2)
	move.l	a4,a1
	move.l	a5,a2
	dbra	d2,snbpre_loop2
	add.l	d0,a1
	add.l	d0,a2
	dbra	d1,snbpre_loop1

snb_fin:
	movem.l	(sp)+,d0-d3/a1-a5
	rts



*============================================================================*
*	Efface un bloc de notes dans un pattern			*
*	a0 = adresse des infos (voir plus haut)			*
*	Adresse source nÇcessaire				*
*	Pas besoin de masque destination				*
*============================================================================*
clear_note_block:
	movem.l	d0-d3/a1-a3,-(sp)
	move.l	adrsour_bl(a0),a1	; a1 = adresse source
	move.l	adrpreset_bl(a0),a3	; a3 = adresse du preset
	move.l	increm_bl(a0),d0	; d0 = incrÇment de ligne
	move.w	nlines_bl(a0),d1	; d1 = compteur de lignes
	subq.w	#1,d1
	tst.w	type_bl(a0)
	bne.s	cnb_pattern

cnbtra_loop:			; Track
	bsr	clear_note
	add.l	d0,a1
	dbra	d1,cnbtra_loop
	bra.s	cnb_fin

cnb_pattern:			; Pattern
	cmp.w	#1,type_bl(a0)
	bne.s	cnb_preset
cnbpat_loop1:
	move.l	a1,a2
	move.w	nbr_track_bl(a0),d2
	subq.w	#1,d2
cnbpat_loop2:
	bsr	clear_note
	addq.l	#5,a1
	dbra	d2,cnbpat_loop2
	move.l	a2,a1
	add.l	d0,a1
	dbra	d1,cnbpat_loop1
	bra.s	cnb_fin

cnb_preset:			; Preset
cnbpre_loop1:
	move.w	preset_ntrk_bl(a0),d2
	subq.w	#1,d2
	move.l	a1,a2
cnbpre_loop2:
	move.w	(a3,d2.w*2),d3
	mulu.w	#5,d3
	add.l	d3,a1
	bsr	clear_note
	move.l	a2,a1
	dbra	d2,cnbpre_loop2
	add.l	d0,a1
	dbra	d1,cnbpre_loop1

cnb_fin:
	movem.l	(sp)+,d0-d3/a1-a3
	rts



*============================================================================*
*	Transpose un bloc de notes dans un pattern			*
*	a0 = adresse des infos (voir plus haut)			*
*	Adresse source nÇcessaire				*
*	Remplacer l'adresse destination par la transposition.l		*
*	Pas besoin de masque destination				*
*============================================================================*
transpose_note_block:
	movem.l	d0-d4/a1-a3,-(sp)
	move.l	adrsour_bl(a0),a1	; a1 = adresse source
	move.l	adrdest_bl(a0),d4	; d4 = transposition
	move.l	adrpreset_bl(a0),a3	; a3 = adresse du preset
	move.l	increm_bl(a0),d0	; d0 = incrÇment de ligne
	move.w	nlines_bl(a0),d1	; d1 = compteur de lignes
	subq.w	#1,d1
	tst.w	type_bl(a0)
	bne.s	tnb_pattern

tnbtra_loop:			; Track
	bsr	transpose_note
	add.l	d0,a1
	dbra	d1,tnbtra_loop
	bra.s	tnb_fin

tnb_pattern:			; Pattern
	cmp.w	#1,type_bl(a0)
	bne.s	tnb_preset
tnbpat_loop1:
	move.l	a1,a2
	move.w	nbr_track_bl(a0),d2
	subq.w	#1,d2
tnbpat_loop2:
	bsr	transpose_note
	addq.l	#5,a1
	dbra	d2,tnbpat_loop2
	move.l	a2,a1
	add.l	d0,a1
	dbra	d1,tnbpat_loop1
	bra.s	tnb_fin

tnb_preset:			; Preset
tnbpre_loop1:
	move.w	preset_ntrk_bl(a0),d2
	subq.w	#1,d2
	move.l	a1,a2
tnbpre_loop2:
	move.w	(a3,d2.w*2),d3
	mulu.w	#5,d3
	add.l	d3,a1
	bsr	transpose_note
	move.l	a2,a1
	dbra	d2,tnbpre_loop2
	add.l	d0,a1
	dbra	d1,tnbpre_loop1

tnb_fin:
	movem.l	(sp)+,d0-d4/a1-a3
	rts



*============================================================================*
*	Copie une note dans un pattern				*
*	a0 = adresse du champ d'infos (voir + haut)			*
*	a1 = adresse source					*
*	a2 = adresse destination				*
*============================================================================*
copie_note:
	movem.l	d3/a4-a5,-(sp)
	tst.w	maskblock_bl(a0)
	bne.s	cn_masque

; Sans masque
	tst.l	(a1)		; source<>0 ?
	bne.s	.ok1
	tst.b	4(a1)
	bne.s	.ok1
	tst.w	replaceblock_bl(a0)	; Replaceblock=0 ?
	bne.s	cn_fin
.ok1:	move.l	(a1),(a2)		; Copie si source<>0 ou si replblock=0 sinon ne fait rien
	move.b	4(a1),4(a2)
	bra.s	cn_fin

; Avec masque
cn_masque:
	tst.l	(a1)		; source<>0 ?
	bne.s	.ok2
	tst.b	4(a1)
	bne.s	.ok2
	tst.w	replaceblock_bl(a0)	; Replaceblock=0 ?
	bne.s	cn_fin

.ok2:				; Copie si source<>0 ou si replblock=0 sinon ne fait rien
	move.l	adra1_bl(a0),a4	; (source AND blmask_a1) = blmask_a2 ?
	move.l	adra2_bl(a0),a5
	move.l	(a1),d3
	and.l	(a4),d3
	cmp.l	(a5),d3
	bne.s	.else_if
	move.b	4(a1),d3
	and.b	4(a4),d3
	cmp.b	4(a5),d3
	bne.s	.else_if
	move.l	adrb1_bl(a0),a4	; Oui, dest = ((source AND blmask_b1) OR blmask_b2)
	move.l	adrb2_bl(a0),a5
	move.l	(a1),d3
	and.l	(a4),d3
	or.l	(a5),d3
	move.l	d3,(a2)
	move.b	4(a1),d3
	and.b	4(a4),d3
	or.b	4(a5),d3
	move.b	d3,4(a2)
	bra.s	cn_fin
.else_if:				; Sinon, replaceblock = 0 ?
	tst.w	replaceblock_bl(a0)
	bne.s	cn_fin		; Non, on fait rien
	clr.l	(a2)		; Oui, on efface la destination
	clr.b	4(a2)

cn_fin:
	movem.l	(sp)+,d3/a4-a5
	rts



*============================================================================*
*	Efface une note dans un pattern				*
*	a0 = adresse du champ d'infos (voir + haut)			*
*	a1 = adresse de la note				*
*============================================================================*
clear_note:
	movem.l	d3/a4-a5,-(sp)
	tst.w	maskblock_bl(a0)
	beq.s	clrn_sansmasque
; Avec masque
	move.l	adra1_bl(a0),a4	; (source AND blmask_a1) = blmask_a2 ?
	move.l	adra2_bl(a0),a5
	move.l	(a1),d3
	and.l	(a4),d3
	cmp.l	(a5),d3
	bne.s	clrn_fin
	move.b	4(a1),d3
	and.b	4(a4),d3
	cmp.b	4(a5),d3
	bne.s	clrn_fin
clrn_sansmasque:
	clr.l	(a1)
	clr.b	4(a1)

clrn_fin:
	movem.l	(sp)+,d3/a4-a5
	rts



*============================================================================*
*	Transpose une note dans un pattern			*
*	a0 = adresse du champ d'infos (voir + haut)			*
*	a1 = adresse de la note				*
*	d4 = transposition.w (ou .l)				*
*============================================================================*
transpose_note:
	movem.l	d3/a4-a5,-(sp)
	tst.b	(a1)		; Pas de note ?
	beq.s	tran_fin		; Alors on se tire
	tst.w	maskblock_bl(a0)
	beq.s	tran_sansmasque
; Avec masque
	move.l	adra1_bl(a0),a4	; (source AND blmask_a1) = blmask_a2 ?
	move.l	adra2_bl(a0),a5
	move.l	(a1),d3
	and.l	(a4),d3
	cmp.l	(a5),d3
	bne.s	tran_fin
	move.b	4(a1),d3
	and.b	4(a4),d3
	cmp.b	4(a5),d3
	bne.s	tran_fin
tran_sansmasque:
	moveq	#0,d3
	move.b	(a1),d3
	add.w	d4,d3
	cmp.w	#127,d3
	ble.s	.ok1
	moveq	#127,d3		; Limite sup Ö G-8
.ok1:	cmp.w	#24,d3
	bge.s	.ok2
	moveq	#24,d3		; Limite inf Ö C-0
.ok2:	move.b	d3,(a1)
tran_fin:
	movem.l	(sp)+,d3/a4-a5
	rts



*============================================================================*
*	Convertit un ancien groupe de patterns GT de 4 octets/note	*
*	en patterns GT de 5 octets/note (commande de volume)		*
*	a0 = adresse des patterns				*
*	d0 = taille.l des patterns (en nombre de notes)		*
*============================================================================*
convert_gtk_2_gtk_vol:
	movem.l	d0/a0-a1,-(sp)
	lea	(a0,d0.l*4),a0	; Pointe sur la fin des anciens patterns
	lea	(a0,d0.l),a1	; Pointe sur la fin des nouveaux
.loop1:	clr.b	-(a1)		; Efface le volume interne
	move.l	-(a0),-(a1)	; Recopie la note
	subq.l	#1,d0
	bne.s	.loop1
	movem.l	(sp)+,d0/a0-a1
	rts



*============================================================================*
*	Convertit une voie Ultra Tracker en Graoumf-voie		*
*	a0 = adresse de la voie ULT				*
*	a1 = adresse de la voie GTK				*
*	d0 = nombre.w de voies dans un pattern ULT			*
*	Renvoie dans d0.l la longueur du pattern ULT		*
*============================================================================*
convert_ult_2_gtk:
	movem.l	d1-d7/a0-a1,-(sp)
	move.w	d0,d1
	move.w	d1,d2
	add.w	d1,d1
	add.w	d1,d1
	add.w	d2,d1		; d1 = incrÇment de ligne dans le pattern GTK
	moveq	#0,d0		; d0 = longueur du pattern ULT
	moveq	#64,d6		; d6 = nombre de lignes
cv_ult2gtk_loop2:
	move.b	(a0),d2
	moveq	#1,d5		; Nombre de rÇpÇtitions de la note par dÇfaut
	cmp.b	#$FC,d2
	bne.s	.finsi1
	move.b	1(a0),d5		; S'il y a rÇpÇtition, prends le nombre
	addq.l	#2,a0
	addq.l	#2,d0
.finsi1:	subq.w	#1,d5
	moveq	#0,d2		; d2 = la Graoumf-note
	move.b	(a0)+,d3
	beq.s	.nonote
	add.b	#23,d3		; Additionne 2 octaves
.nonote:	lsl.w	#8,d3
	move.b	(a0)+,d3		; L'instrument
	move.w	d3,d2
	swap	d2		; Note et instrument convertis

	; Les effets...
	moveq	#0,d7		; Pas de volume interne
	cmp.b	#$99,(a0)		; Fine sample offset
	bne.s	.suite
	move.w	1(a0),d2
	lsr.w	#6,d2
	add.w	#$9000,d2
	bra	.fin

.suite:	moveq	#0,d3
	moveq	#0,d4
	move.b	(a0),d3
	and.b	#$f,d3		; d3 = numÇro du 2äme effet
	move.b	1(a0),d4		; d4 = paramätre
	bsr	convert_ultfx_2_gtkfx
	moveq	#0,d3
	moveq	#0,d4
	move.b	(a0),d3
	lsr.b	#4,d3		; d3 = numÇro du 1er effet
	move.b	2(a0),d4		; d4 = paramätre
	bsr	convert_ultfx_2_gtkfx

.fin:	addq.l	#3,a0
	addq.l	#5,d0		; Hop, 5 octets de plus

.repblk:	move.l	d2,(a1)		; Met l'event
	move.b	d7,4(a1)		; Met le volume interne
	add.w	d1,a1		; Ligne suivante
	subq.w	#1,d6
	tst.w	d6
	beq.s	cv_ult2gtk_finvoie
	dbra	d5,.repblk		; RÇpÇtition...
	bra	cv_ult2gtk_loop2	; SÇrie d'events suivante

cv_ult2gtk_finvoie:
	movem.l	(sp)+,d1-d7/a0-a1
	rts



*============================================================================*
*	Convertit un effet Ultra Tracker en effet GTK		*
*	d2 = note.l GTK (effet.w = 0)				*
*	d3 = effet						*
*	d4 = paramätre					*
*	d7 = volume interne					*
*	En sortie :					*
*	d2 = note.l GTK					*
*	d7 = volume interne					*
*============================================================================*
convert_ultfx_2_gtkfx:
	cmp.b	#$1,d3		; Les effets qui ne changent pas
	beq.s	.no_chg		; Porta up
	cmp.b	#$2,d3		; Porta down
	beq.s	.no_chg
	cmp.b	#$3,d3		; Tone porta
	beq.s	.no_chg
	cmp.b	#$4,d3		; Vibrato
	beq.s	.no_chg
	cmp.b	#$7,d3		; Tremolo
	bne.s	.0
.no_chg:	lsl.w	#8,d3
	add.w	d4,d3
	move.w	d3,d2
	bra	.fin

.0:	tst.b	d3		; Arpeggio
	bne.s	.9
	tst.b	d4
	beq	.fin		; Pas d'effet finalement
	add.w	#$1000,d4
	move.w	d4,d2
	bra	.fin

.9:	cmp.b	#$9,d3		; Sample offset
	bne.s	.a
	add.w	d4,d4
	add.w	d4,d4
	add.w	#$9000,d4
	move.w	d4,d2
	bra	.fin

.a:	cmp.b	#$A,d3		; Volume slide
	bne.s	._b
	move.b	d4,d3
	lsr.b	#4,d4
	and.b	#15,d3
	sub.w	d3,d4
	bmi.s	.a_neg
	add.w	#$1400,d4
	move.w	d4,d2
	bra	.fin
.a_neg:	neg.w	d4
	add.w	#$1500,d4
	move.w	d4,d2
	bra	.fin

._b:	cmp.b	#$B,d3		; Balance
	bne.s	.c
	and.b	#15,d4
	lsl.w	#8,d4
	add.w	#$4000,d4
	move.w	d4,d2
	bra	.fin

.c:	cmp.b	#$C,d3		; Volume
	bne.s	.d
	tst.b	d4
	bne.s	.c_norm
	move.w	#$2000,d2
	bra	.fin
.c_norm:	move.b	d4,d7
	bra	.fin

.d:	cmp.b	#$d,d3		; Break pattern to line
	bne.s	.f
	move.w	d4,d3		; Conversion BCD -> Hexa
	lsr.w	#4,d4
	mulu.w	#10,d4
	add.b	d3,d4
	move.w	#$D00,d2
	move.b	d4,d2
	bra	.fin

.f:	cmp.b	#$F,d3		; Set speed/tempo
	bne.s	.e
	cmp.w	#$30,d4
	bge	.no_chg
	move.w	#$A800,d2
	add.w	d4,d2
	bra.s	.fin

.e:	cmp.b	#$E,d3		; Effets Çtendus
	bne.s	.fin
	move.b	d4,d3
	lsr.b	#4,d3
	and.b	#15,d4

.e1:	cmp.b	#1,d3		; Fine parta up
	bne.s	.e2
	add.w	#$1100,d4
	move.w	d4,d2
	bra.s	.fin

.e2:	cmp.b	#2,d3		; Fine porta down
	bne.s	.e8
	add.w	#$1200,d4
	move.w	d4,d2
	bra.s	.fin

.e8:	cmp.b	#8,d3		; Delay track
	bne.s	.e9
	add.w	#$AA00,d4
	move.w	d4,d2
	bra.s	.fin

.e9:	cmp.b	#9,d3		; Retrig note
	bne.s	.ea
	add.b	#$70,d4
	lsl.w	#8,d4
	move.w	d4,d2
	bra.s	.fin

.ea:	cmp.b	#$A,d3		; Fine volume up
	bne.s	.eb
	add.w	#$A400,d4
	move.w	d4,d2
	bra.s	.fin

.eb:	cmp.b	#$B,d3		; Fine volume down
	bne.s	.ec
	add.w	#$A500,d4
	move.w	d4,d2
	bra.s	.fin

.ec:	cmp.b	#$C,d3		; Cut note
	bne.s	.ed
	add.w	#$0A00,d4
	move.w	d4,d2
	bra.s	.fin

.ed:	cmp.b	#$D,d3		; Note delay
	bne.s	.fin
	add.w	#$0900,d4
	move.w	d4,d2

.fin:	rts



*============================================================================*
*	Convertit un sample 16 bits Intel en 16 bits Motorola		*
*	a0 = adresse du sample				*
*	d0 = longueur.l du sample en octets			*
*============================================================================*
intel_16_bits:
	movem.l	d0/d1/a0,-(sp)
	tst.l	d0
	beq.s	.fin
	lsr.l	#1,d0
	swap	d0
.loop2:	swap	d0
.loop1:	move.b	1(a0),d1
	move.b	(a0)+,(a0)+
	move.b	d1,-2(a0)
	dbra	d0,.loop1
	swap	d0
	dbra	d0,.loop2
.fin:	movem.l	(sp)+,d0/d1/a0
	rts



*============================================================================*
*	Convertit un pattern Scream Tracker 3 compactÇ en pattern GTK	*
*	a0 = adresse du pattern S3M compactÇ (sans le mot de longueur)	*
*	a1 = adresse du pattern GTK				*
*	a2 = adresse de la table de correspondance des voies		*
*	d0 = nombre.w de voies dans le Graoumf-pattern		*
*============================================================================*
convert_s3m_2_gtk:
	movem.l	d0-d5/a0-a5,-(sp)
	lea	cv_s3m2gtk_slides+32*2(pc),a4
	moveq	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	movem.l	d1-d4,-(a4)	; RÇinitialise l'Çtat des slides de
	movem.l	d1-d4,-(a4)	; volume pour chaque voie
	movem.l	d1-d4,-(a4)	; 4reg*4oct*4codes = 32voies*2octets
	movem.l	d1-d4,-(a4)
	lea	cv_s3m2gtk_porta+32(pc),a5
	movem.l	d1-d4,-(a5)	; Idem, pour les portamentos
	movem.l	d1-d4,-(a5)
	move.w	d0,d1
	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d0		; d0 = incrÇment d'adresse du pattern GTK
	moveq	#0,d1
	moveq	#63,d3		; d3 = compteur de ligne

cv_s3m2gtk_loop1:

.newtrk:	move.b	(a0)+,d1		; d1 = octet d'information
	beq	cv_s3m2gtk_finligne
	move.b	d1,d2
	and.b	#31,d2		; NumÇro de voie S3M
	lea	cv_s3m2gtk_slides(pc),a4
	lea	(a4,d2.w*2),a4	; a4 pointe sur l'Çtat du slide
	lea	cv_s3m2gtk_porta(pc),a5
	add.w	d2,a5		; a5 pointe sur l'Çtat du portamento
	move.b	(a2,d2.w),d2	; d2 = numÇro de voie GTK
	cmp.b	#255,d2
	bne.s	.track_ok
	btst	#5,d1		; Si la voie n'est pas autorisÇe
	beq.s	.s1
	addq.l	#2,a0
.s1:	btst	#6,d1
	beq.s	.s2
	addq.l	#1,a0
.s2:	btst	#7,d1
	beq.s	.newtrk
	addq.l	#2,a0
	bra.s	.newtrk

.track_ok:
	lea	(a1,d2.w*4),a3
	lea	(a3,d2.w),a3	; a3 pointe sur la note GTK
	btst	#5,d1		; Note + Instrument ?
	beq.s	.no_note
	moveq	#0,d4
	move.b	(a0)+,d4
	move.b	(a0)+,1(a3)	; Instrument converti
	cmp.w	#255,d4		; Note vide ?
	bne.s	.note_s1
	bra.s	.no_note
.note_s1:	cmp.w	#254,d4		; Coupe la note ?
	bne.s	.note_ok
	move.w	#$2000,2(a3)	; Oui, met le volume Ö 0
	bra.s	.no_note
.note_ok:	move.w	d4,d5
	and.b	#$f,d4
	lsr.b	#4,d5
	mulu.w	#12,d5
	add.w	d5,d4
	cmp.b	#24,d4		; Trop bas ?
	bge.s	.note_ok2
	moveq	#0,d4		; alors on ne met rien
.note_ok2:	move.b	d4,(a3)		; Note convertie

.no_note:	btst	#6,d1		; Volume ?
	beq.s	.no_vol
	move.w	#$800,d4		; $2000/4
	move.b	(a0)+,d4
	cmp.b	#255,d4
	beq.s	.no_vol
	add.w	d4,d4
	add.w	d4,d4		; Convertit 0-64 en 0-256
	cmp.w	#$2100,d4
	bne.s	.vol_ok1
	move.w	d4,2(a3)		; Volume $100 : commande 2100
	subq.w	#1,d4
.vol_ok1:	tst.b	d4
	bne.s	.vol_ok2
	move.w	d4,2(a3)		; Volume 0 : commande 2000
	addq.w	#1,d4
.vol_ok2:	move.b	d4,4(a3)		; Volume interne

.no_vol:	btst	#7,d1		; Effet ?
	beq	.newtrk
	moveq	#0,d4
	moveq	#0,d5
	move.b	(a0)+,d4		; d4 = effet
	move.b	(a0)+,d5		; d5 = paramätre ( -> nouvel effet)

.1:	cmp.b	#$1,d4		; Set Speed
	bne.s	.2
	add.w	#$A800,d5		; -> Set Number of Frames
	bra	.finfx

.2:	cmp.b	#$2,d4		; Jump to pos
	bne.s	.3
	add.w	#$B00,d5
	bra	.finfx

.3:	cmp.b	#$3,d4		; Break pattern
	bne.s	.4
	move.w	d5,d4		; Conversion BCD -> Hexa
	lsr.w	#4,d5
	mulu.w	#10,d5
	and.b	#15,d4
	add.b	d4,d5
	add.w	#$D00,d5
	bra	.finfx

.4:	cmp.b	#$4,d4		; Volume Slide
	bne.s	.5
	move.w	d5,d1
	and.b	#$F,d1
	bne.s	.4_s1
	lsr.b	#2,d5		; Volume slide up
	and.b	#$3C,d5
	beq.s	.4_cont
	add.w	#$1400,d5
	move.w	d5,(a4)		; On sauve l'Çtat de ce slide
	bra	.finfx
.4_cont:	move.w	(a4),d5		; Si y avait pas de paramätre
	bra	.finfx
.4_s1:	cmp.b	#$F,d1
	bne.s	.4_s2
	lsr.b	#2,d5		; Fine volume slide up
	and.b	#$3C,d5
	beq.s	.4_cont
	add.w	#$A400,d5
	move.w	d5,(a4)
	bra	.finfx
.4_s2:	move.w	d5,d1
	and.b	#$F0,d1
	bne.s	.4_s3
	and.b	#$F,d5		; Volume slide down
	beq.s	.4_cont
	add.b	d5,d5
	add.b	d5,d5
	add.w	#$1500,d5
	move.w	d5,(a4)
	bra	.finfx
.4_s3:	and.b	#$F,d5		; Fine volume slide down
	beq.s	.4_cont
	add.b	d5,d5
	add.b	d5,d5
	add.w	#$A500,d5
	move.w	d5,(a4)
	bra	.finfx

.5:	cmp.b	#$5,d4		; Portamento down
	bne.s	.6
	move.w	d5,d1
	and.w	#$F0,d1
	cmp.b	#$F0,d1
	bne.s	.5_s1
	and.b	#$F,d5		; Fine portamento down
	beq.s	.5_cont0
	move.b	d5,(a5)
.5_cont0:	move.b	(a5),d5
	add.w	#$1200,d5
	bra	.finfx
.5_s1:	cmp.b	#$E0,d1
	bne.s	.5_s2
	and.b	#$F,d5		; Extra fine porta down
	beq.s	.5_cont1
	move.b	d5,(a5)
.5_cont1:	move.b	(a5),d5
	add.w	#$AD00,d5
	bra	.finfx
.5_s2:	tst.b	d5
	beq.s	.5_cont2
	move.b	d5,(a5)
.5_cont2:	move.b	(a5),d5
	add.w	#$200,d5		; Normal porta down
	bra	.finfx

.6:	cmp.b	#$6,d4		; Porta up
	bne.s	.7
	move.w	d5,d1
	and.w	#$F0,d1
	cmp.b	#$F0,d1
	bne.s	.6_s1
	and.b	#$F,d5		; Fine portamento up
	beq.s	.6_cont0
	move.b	d5,(a5)
.6_cont0:	move.b	(a5),d5
	add.w	#$1100,d5
	bra	.finfx
.6_s1:	cmp.b	#$E0,d1
	bne.s	.6_s2
	and.b	#$F,d5		; Extra fine porta up
	beq.s	.6_cont1
	move.b	d5,(a5)
.6_cont1:	move.b	(a5),d5
	add.w	#$AC00,d5
	bra	.finfx
.6_s2:	tst.b	d5
	beq.s	.6_cont2
	move.b	d5,(a5)
.6_cont2:	move.b	(a5),d5
	add.w	#$100,d5		; Normal porta up
	bra	.finfx

.7:	cmp.b	#$7,d4		; Tone portamento
	bne.s	.8
	add.w	#$300,d5
	bra	.finfx

.8:	cmp.b	#$8,d4		; Vibrato
	bne.s	.9
	add.w	#$400,d5
	bra	.finfx

.9:	cmp.b	#$9,d4		; Tremor
	bne.s	.a
	add.w	#$B000,d5
	bra	.finfx

.a:	cmp.b	#$a,d4		; Arpeggio
	bne.s	.b_
	add.w	#$1000,d5
	bra	.finfx

.b_:	cmp.b	#$b,d4		; Vib + Vol slide
	bne.s	.c
	move.w	d5,d4
	and.w	#$f,d4
	lsr.w	#4,d5
	sub.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	beq.s	.b_cont
	bmi.s	.bneg
	add.w	#$1C00,d5
	move.w	d5,(a4)
	sub.b	#$1C-$14,(a4)
	bra	.finfx
.bneg:	sub.w	#$1D00,d5
	neg.w	d5
	move.w	d5,(a4)
	sub.b	#$1D-$14,(a4)
	bra	.finfx
.b_cont:	move.w	(a4),d5
	and.w	#$1ff,d5
	add.w	#$1C00,d5
	bra	.finfx

.c:	cmp.b	#$c,d4		; Vol slide + Tone porta
	bne.s	.f
	move.w	d5,d4
	and.w	#$f,d4
	lsr.w	#4,d5
	sub.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	beq.s	.c_cont
	bmi.s	.cneg
	add.w	#$1800,d5
	move.w	d5,(a4)
	sub.b	#$18-$14,(a4)
	bra	.finfx
.cneg:	sub.w	#$1900,d5
	neg.w	d5
	move.w	d5,(a4)
	sub.b	#$19-$14,(a4)
	bra	.finfx
.c_cont:	move.w	(a4),d5
	and.w	#$1ff,d5
	add.w	#$1800,d5
	bra	.finfx

.f:	cmp.b	#$f,d4		; Sample offset
	bne.s	.11
	add.w	#$9000,d5
	bra	.finfx

.11:	cmp.b	#$11,d4		; Retrig + volume slide
	bne.s	.12
	add.w	#$1300,d5
	bra	.finfx

.12:	cmp.b	#$12,d4		; Tremolo
	bne.s	.13
	add.w	#$0700,d5
	bra	.finfx

.13:	cmp.b	#$13,d4		; Effets Çtendus
	bne.s	.14
	move.b	d5,d4
	and.b	#$f,d5
	lsr.b	#4,d4
	cmp.b	#$2,d4		; Set finetune
	bne.s	.13_3
	cmp.b	#7,d5
	bgt.s	.13_2_neg
	lsl.b	#4,d5
	add.w	#$800,d5
	bra.s	.finfx
.13_2_neg:	sub.b	#$10,d5
	neg.b	d5
	add.w	#$800,d5
.13_3:	cmp.b	#$3,d4		; Set vibrato waveform
	bne.s	.13_4
	add.w	#$C00,d5
	bra.s	.finfx
.13_4:	cmp.b	#$4,d4		; Set tremolo waveform
	bne.s	.13_8
	add.w	#$E00,d5
	bra.s	.finfx
.13_8:	cmp.b	#$8,d4		; (Panoramic command)
	bne.s	.13_c
	add.b	#$40,d5
	lsl.w	#$8,d5
	bra.s	.finfx
.13_c:	cmp.b	#$c,d4		; Notecut
	bne.s	.13_d
	add.w	#$A00,d5
	bra.s	.finfx
.13_d:	cmp.b	#$d,d4		; Notedelay
	bne.s	.13_e
	add.w	#$900,d5
	bra.s	.finfx
.13_e:	cmp.b	#$e,d4		; Patterndelay
	bne.s	.14
	add.w	#$AA00,d5
	bra.s	.finfx
	
.14:	cmp.b	#$14,d4		; Set tempo
	bne.s	.defaut
	add.w	#$F00,d5

.finfx:	move.w	d5,2(a3)		; Effet converti
.defaut:	bra	.newtrk

cv_s3m2gtk_finligne:
	add.w	d0,a1		; Ligne suivante dans le pattern GTK
	dbra	d3,cv_s3m2gtk_loop1
	movem.l	(sp)+,d0-d5/a0-a5
	rts



*============================================================================*
*	Teste les coordonnÇes de la souris pour savoir sur quelle	*
*	icìne on a cliquÇ.					*
*	d0 = numÇro.w du panneau d'icìnes			*
*	d1 = x.w souris (pixels)				*
*	d2 = y.w souris (pixels)				*
*	a0 = adresse du tableau contenant les infos sur les panneaux	*
*	     d'icìnes					*
*	Au retour :					*
*	d0 = numÇro d'icìne, -1 si rien n'a ÇtÇ trouvÇ		*
*============================================================================*
teste_icones:
	movem.l	d1/d3/d4/a0,-(sp)
	mulu.w	#64*2*4,d0
	add.l	d0,a0
	asr.w	#3,d1		; Convertit coo. x souris en colonnes
	moveq	#63,d0
.loop:	move.w	(a0),d3		; d3 = abscisse (en colonnes) de l'icìne
	bmi.s	.suite		; NÇgatif : pas d'icìne ici
	cmp.w	d3,d1
	blt.s	.suite
	move.w	2(a0),d4		; d4 = ordonnÇe de l'icìne (en pixels)
	cmp.w	d4,d2
	blt.s	.suite
	add.w	6(a0),d4		; Additionne hauteur-1 en pixels
	cmp.w	d4,d2
	bgt.s	.suite
	add.w	4(a0),d3		; Additionne largeur-1 en colonnes de caractäres
	cmp.w	d3,d1
	ble.s	.ok
.suite:	addq.l	#8,a0		; Icìne suivante
	dbra	d0,.loop
	moveq	#-1,d0		; Renvoie -1 : on a cliquÇ ailleurs
	movem.l	(sp)+,d1/d3/d4/a0
	rts
.ok:	sub.w	#63,d0
	neg.w	d0		; Renvoie le numÇro de l'icìne (0-63)
	movem.l	(sp)+,d1/d3/d4/a0
	rts



*============================================================================*
*	Convertit un pattern au format OctaMED Pro de n voies en	*
*	un Graoumf-pattern de (n+k) voies			*
*	a0 = adresse du pattern OctaMED				*
*	a1 = adresse du Graoumf-pattern				*
*	a2 = adresse de la table des transpositions d'instrument	*
*	d0 = nombre.w de pistes OctaMED				*
*	d1 = nombre.w de lignes				*
*	d6 = diffÇrence.w entre le nombre de Graoumf-pistes et		*
*	     d'Octa-pistes					*
*============================================================================*
convert_mmd1_2_gtk:
	movem.l	d0-d6/a0-a2,-(sp)
	mulu.w	#5,d6		; DiffÇrence * 5 octets
	subq.w	#1,d0		; Pour le dbra
	subq.w	#1,d1		; d1 = compteur de lignes
cv_mmd12gtk_loopl:
	move.w	d0,d5		; d5 = compteur de voies
cv_mmd12gtk_loopv:

	moveq	#0,d3
	move.b	1(a0),d3		; d3 = numÇro de l'instrument
	and.b	#$3f,d3
	move.b	(a0),d4		; d4 = note
	and.b	#$7f,d4
	beq.s	.pasnote
	add.b	(a2,d3.w),d4	; Transpose
.pasnote:	move.b	d4,(a1)+		; Note convertie
	move.b	d3,(a1)+		; Instrument converti
	addq.l	#2,a0

	move.b	(a0)+,d3		; d3 = numÇro d'effet
	moveq	#0,d4
	move.b	(a0)+,d4		; d4 = paramätre de l'effet
	clr.w	d2		; d2 = Graoumf-effet

	cmp.b	#3,d3		; Les effets qui ne changent pas
	beq.s	.nochange
	cmp.b	#4,d3
	beq.s	.nochange
	cmp.b	#7,d3
	beq.s	.nochange
	cmp.b	#$b,d3
	beq.s	.nochange
	cmp.b	#$f,d3
	bne.s	.suite
	tst.b	d4		; Fonction F00 = break pattern (-> ligne 0)
	beq	.1d_set
	cmp.w	#$f0,d4		; Fonction F : tempo seulement si 31 < x < 241
	bgt	.ffx		; Si > 240, autres fonctions
	cmp.w	#$20,d4
	blt	.defaut
.nochange:	lsl.w	#8,d3
	add.w	d3,d4
	move.w	d4,d2
	bra	.fin

.suite:	tst.b	d3		; Arpeggio
	bne.s	.01
	tst.b	d4
	beq	.fin
	add.w	#$1000,d4
	move.w	d4,d2
	bra	.fin

.01:	cmp.b	#1,d3		; Porta up (rien si paramätre = 0)
	bne.s	.02
	tst.b	d4
	beq	.fin
	add.w	#$100,d4
	move.w	d4,d2
	bra	.fin

.02:	cmp.b	#2,d3		; Porta down ( ... )
	bne.s	.05
	tst.b	d4
	beq	.fin
	add.w	#$200,d4
	move.w	d4,d2
	bra	.fin

.05:	cmp.b	#5,d3		; Vol slide + porta
	bne.s	.06
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.05neg
	add.w	#$1800,d4
	move.w	d4,d2
	bra	.fin
.05neg:	move.w	#$1900,d2
	sub.w	d4,d2
	bra	.fin

.06:	cmp.b	#6,d3		; Vol slide + vib
	bne.s	.09
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.06neg
	add.w	#$1c00,d4
	move.w	d4,d2
	bra	.fin
.06neg:	move.w	#$1d00,d2
	sub.w	d4,d2
	bra	.fin

.09:	cmp.b	#$9,d3		; Set number of frames
	bne.s	.0a
	add.w	#$a800,d4
	move.w	d4,d2
	bra	.fin

.0a:	cmp.b	#$a,d3		; Vol slide
	beq.s	.0d
	cmp.b	#$d,d3
	bne.s	.0c
.0d	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.0aneg
	add.w	#$1400,d4
	move.w	d4,d2
	bra	.fin
.0aneg:	move.w	#$1500,d2
	sub.w	d4,d2
	bra	.fin

.0c:	cmp.b	#$c,d3		; Set volume
	bne.s	.11
	add.w	d4,d4		; <- En hexa ! (dÇcimal pas fait)
	add.w	d4,d4
	add.w	#$2000,d4
	move.w	d4,d2
	bra	.fin

.11	cmp.b	#$11,d3		; Fine porta up
	bne.s	.12
	add.w	#$1100,d4
	move.w	d4,d2
	bra	.fin

.12:	cmp.b	#$12,d3		; Fine porta down
	bne.s	.15
	add.w	#$1200,d4
	move.w	d4,d2
	bra	.fin

.15:	cmp.b	#$15,d3		; Set finetune
	bne.s	.18
	cmp.b	#7,d4
	bgt.s	.15neg
	add.w	#$800,d4
	move.w	d4,d2
	bra	.fin
.15neg:	move.w	#$810,d2
	sub.w	d4,d2
	bra	.fin

.18:	cmp.b	#$18,d3		; Note cut
	bne.s	.19
	add.w	#$a00,d4
	move.w	d4,d2
	bra	.fin

.19:	cmp.b	#$19,d3		; Play part of sample
	bne.s	.1a
	add.w	#$9000,d4
	move.w	d4,d2
	bra	.fin

.1a:	cmp.b	#$1a,d3		; Fine vol up
	bne.s	.1b
	move.w	#$a400,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra	.fin

.1b:	cmp.b	#$1b,d3		; Fine vol down
	bne.s	.1d
	move.w	#$a500,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra.s	.fin

.1d:	cmp.b	#$1d,d3		; Break pattern
	bne.s	.1e
.1d_set:	add.w	#$d00,d4
	move.w	d4,d2
	bra.s	.fin

.1e:	cmp.b	#$1e,d3		; Pattern delay
	bne.s	.1f
	add.w	#$aa00,d4
	move.w	d4,d2
	bra.s	.fin
.1f:	cmp.b	#$1f,d3		; Note delay/Retrig sample
	bne.s	.defaut
	move.w	d4,d3
	and.b	#$f,d3
	beq.s	.1f_delay
	add.b	#$70,d3		; -> Retrig
	lsl.w	#8,d3
	move.w	d3,d2
	bra.s	.fin
.1f_delay:	lsr.b	#4,d4		; -> Delay
	add.w	#$a00,d4
	move.w	d4,d2
	bra.s	.fin

.ffx:	cmp.b	#$F1,d4		; Fonctions spÇciales
	bne.s	.ff2
	move.w	#$7302,d2		; Joue 2 notes en double vitesse
	bra.s	.fin		; La vitesse dÇpend en fait de ce qu'il y a avant!
.ff2:	cmp.b	#$F2,d4		; Attend 1/2 note avant de jouer
	bne.s	.ff3
	move.w	#$0903,d2
	bra.s	.fin
.ff3:	cmp.b	#$F3,d4		; Joue 3 notes en 1 temps
	bne.s	.ffd
	move.w	#$7202,d2
	bra.s	.fin
.ffd:	cmp.b	#$FD,d4		; Change le pitch sans rejouer la note
	bne.s	.fff
	move.w	#$03FF,d2
	bra.s	.fin
.fff:	cmp.b	#$FF,d4		; Arràte la note
	bne.s	.fin
	move.w	#$0A00,d2
	bra.s	.fin

.defaut:	clr.w	d2		; rien par dÇfaut

.fin:	move.w	d2,(a1)+		; Effet converti
	clr.b	(a1)+		; Efface le volume interne
	dbra	d5,cv_mmd12gtk_loopv
	add.w	d6,a1		; Saute les derniäres voies du Graoumf-pattern
	dbra	d1,cv_mmd12gtk_loopl
	movem.l	(sp)+,d0-d6/a0-a2
	rts



*============================================================================*
*	Transforme un sample stereo en mono en ne gardant qu'un	*
*	seul canal.					*
*	a0 = adresse source					*
*	a1 = adresse destination				*
*	d0 = longueur.l (du sample mono, en octet)			*
*	d1 = taille.w d'un sample (1 ou 2)			*
*============================================================================*
stereo_2_mono_one:
	movem.l	d0/d1/a0/a1,-(sp)
	cmp.b	#2,d1
	beq.s	.16loop

.8loop:	move.b	(a0),(a1)+
	addq.l	#2,a0
	subq.l	#1,d0
	bgt.s	.8loop
	bra.s	.fin

.16loop:	move.w	(a0),(a1)+
	addq.l	#4,a0
	subq.l	#2,d0
	bgt.s	.16loop

.fin	movem.l	(sp)+,d0/d1/a0/a1
	rts



*============================================================================*
*	Transforme un sample stereo en mono en moyennant les deux canaux	*
*	a0 = adresse source					*
*	a1 = adresse destination				*
*	d0 = longueur.l (du sample mono, en octet)			*
*	d1 = taille.w d'un sample (1 ou 2)			*
*============================================================================*
stereo_2_mono_ave:
	movem.l	d0-d2/a0/a1,-(sp)
	moveq	#0,d2
	cmp.b	#2,d1
	beq.s	.16bits

.8loop:	move.b	(a0)+,d1
	move.b	(a0)+,d2
	ext.w	d1
	ext.w	d2
	add.w	d1,d2
	asr.w	#1,d2
	move.b	d2,(a1)+
	subq.l	#1,d0
	bgt.s	.8loop
	bra.s	.fin

.16bits:
.16loop:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	ext.l	d1
	ext.l	d2
	add.l	d1,d2
	asr.l	#1,d2
	move.w	d2,(a1)+
	subq.l	#2,d0
	bgt.s	.16loop

.fin:	movem.l	(sp)+,d0-d2/a0/a1
	rts



*============================================================================*
*	Transforme un sample stereo 16 bits en 8/16 bits stereo/mono	*
*	en moyennant les deux canaux si mono est choisi. La conversion	*
*	NE peut PAS àtre faite "sur place".			*
*	a0 = adresse source					*
*	a1 = adresse destination				*
*	d0 = longueur.l (du sample stereo 16 bits, en octet)		*
*	d1 = taille.w d'un sample destination (1 ou 2 pour 8 ou 16 bits)	*
*	d2 = Nombre.w de canaux pour le sample destination (1 ou 2)	*
*============================================================================*
convert_stereo16:
	movem.l	d0-d2/a0-a1,-(sp)
	lsr.l	#2,d0
	tst.l	d0
	beq.s	.fin
	subq.l	#1,d0
	cmp.w	#2,d1
	beq.s	.16bits

;--- 8 bits ------------------------------------------------------------------
.8bits:
	cmp.w	#2,d2
	beq.s	.8stereo

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.8mono:	swap	d0
.8mloop1:	swap	d0
.8mloop2:	move.b	(a0),d1
	move.b	2(a0),d2
	ext.w	d1
	ext.w	d2
	add.w	d1,d2
	asr.w	#1,d2
	move.b	d2,(a1)+
	addq.l	#4,a0
	dbra	d0,.8mloop2
	swap	d0
	dbra	d0,.8mloop1
	bra.s	.fin

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.8stereo:	swap	d0
.8sloop1:	swap	d0
.8sloop2:	move.b	(a0),(a1)+
	move.b	2(a0),(a1)+
	addq.l	#4,a0
	dbra	d0,.8sloop2
	swap	d0
	dbra	d0,.8sloop1
	bra.s	.fin

;--- 16 bits -----------------------------------------------------------------
.16bits:
	cmp.w	#2,d2
	beq.s	.16stereo

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.16mono:	swap	d0
.16mloop1:	swap	d0
.16mloop2:	move.w	(a0)+,d1
	move.w	(a0)+,d2
	ext.l	d1
	ext.l	d2
	add.l	d1,d2
	asr.l	#1,d2
	move.w	d2,(a1)+
	dbra	d0,.16mloop2
	swap	d0
	dbra	d0,.16mloop1
	bra.s	.fin

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.16stereo:	swap	d0
.16sloop1:	swap	d0
.16sloop2:	move.l	(a0)+,(a1)+
	dbra	d0,.16sloop2
	swap	d0
	dbra	d0,.16sloop1

.fin:	movem.l	(sp)+,d0-d2/a0-a1
	rts



*============================================================================*
*	Signe un sample					*
*	a0 = adresse					*
*	d0 = longueur.l en octets				*
*	d1 = taile.w d'un sample (1 = 8 bits, 2 = 16 bits)		*
*============================================================================*
signe_sample:
	movem.l	d0-d2/a0,-(sp)
	extb.l	d1
	moveq	#-128,d2
.loop:	add.b	d2,(a0)
	add.w	d1,a0
	sub.l	d1,d0
	bgt.s	.loop
	movem.l	(sp)+,d0-d2/a0
	rts



*============================================================================*
*	Convertit des patterns au format NoiseTracker en patterns	*
*	au format Graoumf Tracker				*
*	a0 = adresse des patterns				*
*	d0 = longueur.l (en mots longs) de pattern NT Ö convertir	*
*============================================================================*
convert_nt_2_gtk:
	movem.l	d0-d5/a0-a3,-(sp)

	move.l	d0,d5		; Conserve le nombre de notes dans d5

;--- Conversion intÇgrale des notes ------------------------------------------
	lea	nt_pernote(pc),a1	; a1 = adresse des pÇriodes des notes NT
	lea	(a0,d0.l*4),a0	; a0 pointe Ö la fin des patterns NT
	lea	(a0,d0.l),a3	; a1 pointe Ö la fin des patterns GT

cv_nt2gtk_loop:
	move.l	-(a0),d1		; d1 = ancienne note
	moveq	#0,d2		; d2 = nouvelle note
	move.l	d1,d3
	and.l	#$0fff0000,d3
	beq.s	cv_nt2gtk_instr	; S'il n'y a rien
	swap	d3
	moveq	#36,d4
	move.l	a1,a2
.loop:	cmp.w	(a2)+,d3		; recherche la note
	beq.s	.finloop
	addq.w	#1,d4
	cmp.w	#72,d4
	bne.s	.loop
	moveq	#0,d4
.finloop:	lsl.w	#8,d4
	swap	d4
	move.l	d4,d2		; Note convertie

cv_nt2gtk_instr:
	move.l	d1,d3
	and.l	#$f000f000,d3
	lsr.l	#8,d3
	swap	d3
	move.w	d3,d4
	swap	d3
	lsr.b	#4,d3
	add.w	d4,d3		; d3 = instrument
	ext.l	d3		; Vide la partie supÇrieure
	swap	d3
	add.l	d3,d2		; Instrument converti

	moveq	#0,d3
	move.w	d1,d3
	lsr.w	#8,d3
	and.b	#$f,d3		; d3 = numÇro d'effet
	move.w	d1,d4
	and.w	#$ff,d4		; d4 = paramätre 2 chiffres

	bsr	convert_profx_2_gtkfx	; Convertit l'effet

	clr.b	-(a3)		; Efface le volume interne
	move.l	d2,-(a3)		; Met la note
	subq.l	#1,d0
	bne	cv_nt2gtk_loop

;--- Elimine les slides avec paramätre nul -----------------------------------
	addq.l	#2,a3		; a3 pointe sur l'effet de la premiäre note

cv_nt2gtk_loop2:
	move.w	(a3),d0		; d0 = effet
	cmp.w	#$100,d0		; Porta up
	beq.s	.clr_fx
	cmp.w	#$200,d0		; Porta down
	beq.s	.clr_fx
	cmp.w	#$1100,d0		; Fine porta up
	beq.s	.clr_fx
	cmp.w	#$1200,d0		; Fine porta down
	beq.s	.clr_fx
	cmp.w	#$1400,d0		; Volume slide up
	beq.s	.clr_fx
	cmp.w	#$1500,d0		; Volume slide down
	bne.s	.nextnote
.clr_fx:	clr.w	(a3)		; Efface l'effet
.nextnote:	subq.l	#1,d5
	addq.l	#5,a3
	bne	cv_nt2gtk_loop2

	movem.l	(sp)+,d0-d5/a0-a3
	rts



*============================================================================*
*	Convertit un pattern au format 669 8 voies en un pattern	*
*	9 voies au format Graoumf Tracker			*
*	a0 = adresse du pattern 669				*
*	a1 = adresse du pattern GTK				*
*============================================================================*
convert_669_2_gtk:
	movem.l	d0-d3/a0-a2,-(sp)
	moveq	#63,d0		; d0 = compteur de lignes

cv_6692gtk_loop1:
	move.l	a1,a2		; a2 = pointe sur la voie sup. (1äre en fait) du pattern GT
	clr.l	(a1)+		; Saute la voie suplÇmentaire
	clr.b	(a1)+
	moveq	#7,d1		; d1 = compteur de voie

cv_6692gtk_loop2:
	move.b	(a0),d2
	cmp.b	#$ff,d2
	beq.s	cv_6692gtk_fx	; Il n'y a ni note, ni changement de volume
	cmp.b	#$fe,d2
	beq.s	cv_6692gtk_vol	; Il n'y a pas de note
	lsr.b	#2,d2
	cmp.b	#59,d2
	bgt.s	.trop		; Si c'est trop haut, on baisse d'une octave
	add.b	#12,d2
.trop:	add.b	#12,d2		; Met Ö la bonne octave
	move.b	d2,(a1)		; Note convertie

	move.w	(a0),d2		; RÇcupäre le numÇro de l'instrument
	lsr.w	#4,d2
	and.b	#63,d2
	addq.b	#1,d2		; Samples : 0-63   ->   1-64
	move.b	d2,1(a1)		; NumÇro d'instrument converti

cv_6692gtk_vol:
	move.w	#$2000,d2		; Fonction de volume
	move.b	1(a0),d2		; Prend le volume comme paramätre
	lsl.b	#4,d2		; Recalibre
	move.b	d2,4(a1)		; Hop, volume converti en interne
	tst.b	d2
	bne.s	cv_6692gtk_fx
	move.w	d2,2(a1)		; Volume 0 : commande 2000

cv_6692gtk_fx:
	move.b	2(a0),d2		; Prend l'effet
	cmp.b	#$ff,d2
	beq.s	cv_6692gtk_next	; En fait y en a pas, gros farceur !
	move.b	d2,d3
	lsr.b	#4,d3		; d3 = paramätre
	and.b	#15,d2		; d2 = effet
	bne.s	.portadwn		; 0 = Porta up
	move.b	#1,2(a1)
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
.portadwn:	subq.b	#1,d2		; 1 = Porta down
	bne.s	.tonep
	move.b	#2,2(a1)
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
.tonep:	subq.b	#1,d2		; 2 = Tone portamento
	bne.s	.vib
	move.b	#3,2(a1)
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
.vib:	subq.b	#1,d2		; 3 = Vibrato
	bne.s	.detune
	move.b	#4,2(a1)
	lsl.b	#4,d3
	add.b	#2,d3		; *** Amplitude arbitraire
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
.detune:	subq.b	#1,d2		; 4 = Detune *** ???
	bne.s	.setspeed
	move.b	#8,2(a1)
	cmp.b	#8,d3
	blt.s	.detunep
	sub.b	#16,d3		; Detune nÇgatif
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
.detunep:	lsl.b	#4,d3		; Detune positif
	move.b	d3,3(a1)
	bra.s	cv_6692gtk_next
.setspeed:	move.b	#$A8,2(a2)		; 5 = Set nbr of frames
	add.b	#2,d3		; *** ??? Pour une vitesse 4 on a un paramätre de 2 !!!
	move.b	d3,3(a2)		; On met áa sur la voie supplÇmentaire

cv_6692gtk_next:
	addq.l	#3,a0
	addq.l	#5,a1
	dbra	d1,cv_6692gtk_loop2

	dbra	d0,cv_6692gtk_loop1

	movem.l	(sp)+,d0-d3/a0-a2
	rts



*============================================================================*
*	Convertit une voie au format MTM en voie au format Graoumf	*
*	Tracker						*
*	a0 = adresse de la voie MTM				*
*	a1 = adresse de la voie GTK				*
*	d0 = nbr.w de voies d'un Graoumf-pattern			*
*	d1 = nbr.w de lignes Ö convertir				*
*============================================================================*
convert_mtm_voice_2_gtk:
	movem.l	d0-d4/a0/a1,-(sp)
	mulu.w	#5,d0		; 1 Graoumf-note = 5 octets
	subq.w	#1,d1		; d1 = compteur
cv_mtmv2gtk_loop:
	moveq	#0,d2
	move.w	d2,d4
	move.b	(a0),d2		; Prend la note
	lsr.b	#2,d2
	tst.b	d2
	beq.s	.instr		; Pas de note
	cmp.b	#59,d2
	bgt.s	.trop		; Si c'est trop haut, on baise d'une octave
	add.b	#12,d2		; Transpose 2 octaves au-dessus pour GT
.trop:	add.b	#12,d2
	lsl.w	#8,d2		; Place la note Ö l'extrÇmitÇ du mot
.instr:	move.w	(a0),d3		; Prend l'instrument
	lsr.w	#4,d3
	and.b	#63,d3		; Bien recalibrÇ
	move.b	d3,d2		; Place-le Ö l'autre extrÇmitÇ...
	swap	d2		; ...Et hop! Tour de passe-passe
	move.b	1(a0),d3
	and.b	#15,d3		; d3 = effet
	move.b	2(a0),d4		; d4 = paramätre
	bsr.s	convert_profx_2_gtkfx	; Conversion de l'effet
	move.l	d2,(a1)		; Pouf! on enregistre la note au bon format
	clr.b	4(a1)		; Efface le volume interne
	addq.l	#3,a0		; Suivant
	add.w	d0,a1		; Ligne suivante
	dbra	d1,cv_mtmv2gtk_loop
	movem.l	(sp)+,d0-d4/a0/a1
	rts



*============================================================================*
*	Converti un effet Protracker en un effet Graoumf Tracker	*
*	d2 = Note.l au format Graoumf (sans effet)			*
*	d3 = effet.b protracker (0-F)				*
*	d4 = paramätre.w protracker (0-FF)			*
*	Attention, ces registres ne sont pas sauvÇs			*
*	Au retour :					*
*	d2 = Note + Effet					*
*============================================================================*
convert_profx_2_gtkfx:
	cmp.b	#1,d3		; Les effets qui ne changent pas
	beq.s	.nochange
	cmp.b	#2,d3
	beq.s	.nochange
	cmp.b	#3,d3
	beq.s	.nochange
	cmp.b	#4,d3
	beq.s	.nochange
	cmp.b	#7,d3
	beq.s	.nochange
	cmp.b	#$B,d3
	bne.s	.suite
.nochange:	move.w	d4,d2
	lsl.w	#8,d3
	add.w	d3,d2
	and.w	#$fff,d2
	bra	.fin

.suite:	tst.b	d3		; Arpeggio
	bne.s	.5
	tst.b	d4
	beq	.fin
	add.w	#$1000,d4
	move.w	d4,d2
	bra	.fin

.5:	cmp.b	#5,d3		; Vol slide + porta
	bne.s	.6
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.5neg
	add.w	#$1800,d4
	move.w	d4,d2
	bra	.fin
.5neg:	move.w	#$1900,d2
	sub.w	d4,d2
	bra	.fin

.6:	cmp.b	#6,d3		; Vol slide + vib
	bne.s	.8
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.6neg
	add.w	#$1c00,d4
	move.w	d4,d2
	bra	.fin
.6neg:	move.w	#$1d00,d2
	sub.w	d4,d2
	bra	.fin

.8:	cmp.b	#8,d3		; Set balance
	bne.s	.9
	add.w	#$400,d4
	lsl.w	#4,d4
	move.w	d4,d2
	bra	.fin

.9:	cmp.b	#9,d3		; Play part of sample
	bne.s	.a
	add.w	#$9000,d4
	move.w	d4,d2
	bra	.fin

.a:	cmp.b	#10,d3		; Vol slide
	bne.s	.c
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.aneg
	add.w	#$1400,d4
	move.w	d4,d2
	bra	.fin
.aneg:	move.w	#$1500,d2
	sub.w	d4,d2
	bra	.fin

.c:	cmp.b	#$c,d3		; Set volume
	bne.s	.d
	add.w	d4,d4
	add.w	d4,d4
	add.w	#$2000,d4
	move.w	d4,d2
	bra	.fin

.d:	cmp.b	#$d,d3		; Break pattern to line
	bne.s	.e
	move.w	d4,d3		; Conversion BCD -> Hexa
	lsr.w	#4,d4
	mulu.w	#10,d4
	and.b	#$f,d3
	add.b	d3,d4
	move.w	#$D00,d2
	move.b	d4,d2
	bra	.fin

.e:	cmp.b	#14,d3		; Effets Çtendus
	bne	.f
	move.w	d4,d3
	lsr.b	#4,d3
	and.b	#$f,d4
.e1:	cmp.b	#1,d3		; Fine porta up
	bne.s	.e2
	add.w	#$1100,d4
	move.w	d4,d2
	bra	.fin

.e2:	cmp.b	#2,d3		; Fine porta down
	bne.s	.e4
	add.w	#$1200,d4
	move.w	d4,d2
	bra	.fin

.e4:	cmp.b	#4,d3		; Set vib wave
	bne.s	.e5
	add.w	#$c00,d4
	move.w	d4,d2
	bra	.fin

.e5:	cmp.b	#5,d3		; Set finetune
	bne.s	.e6
	cmp.b	#7,d4
	bgt.s	.e5neg
	lsl.b	#4,d4
	add.w	#$800,d4
	move.w	d4,d2
	bra	.fin
.e5neg:	move.w	#$810,d2
	sub.w	d4,d2
	bra	.fin

.e6:	cmp.b	#6,d3		; Pattern loop
	bne.s	.e7
	add.w	#$b100,d4
	move.w	d4,d2
	bra	.fin

.e7:	cmp.b	#7,d3		; Set trem wave
	bne.s	.e8
	add.w	#$e00,d4
	move.w	d4,d2
	bra	.fin

.e8:	cmp.b	#8,d3		; Set balance (2)
	bne.s	.e9
	lsl.w	#8,d4
	add.w	#$4000,d4
	move.w	d4,d2
	bra	.fin

.e9:	cmp.b	#9,d3		; Retrig sample
	bne.s	.e10
	lsl.w	#8,d4
	add.w	#$7000,d4
	move.w	d4,d2
	bra	.fin

.e10:	cmp.b	#10,d3		; Fine vol up
	bne.s	.e11
	move.w	#$a400,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra	.fin

.e11:	cmp.b	#11,d3		; Fine vol down
	bne.s	.e12
	move.w	#$a500,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra	.fin

.e12:	cmp.b	#12,d3		; Note cut
	bne.s	.e13
	add.w	#$a00,d4
	move.w	d4,d2
	bra	.fin

.e13:	cmp.b	#13,d3		; Note delay
	bne.s	.ee
	add.w	#$900,d4
	move.w	d4,d2
	bra	.fin

.ee:	cmp.b	#$e,d3		; Pattern delay
	bne	.fin
	add.w	#$aa00,d4
	move.w	d4,d2
	bra	.fin

.f:	cmp.b	#15,d3		; Tempo
	bne.s	.fin
	move.w	#$0F00,d2
	cmp.w	#$20,d4
	bge.s	.f_ok
	move.w	#$A800,d2
.f_ok:	move.b	d4,d2

.fin:	rts



*============================================================================*
*	Affiche un marqueur de sample				*
*	d0 = longueur.l en octets du sample affichÇ			*
*	d1 = nombre.w d'octets par sample			*
*	d2 = ligne.w d'affichage				*
*	d3 = largeur.w en pixels				*
*	d4 = hauteur.w en pixels				*
*	d5 = position.l du marqueur				*
*	d6 = numÇro.w de plan (0-3)				*
*============================================================================*
affiche_marqueur_sample:
	movem.l	d0-d7/a1,-(sp)
	cmp.b	#2,d1
	bne.s	.finsi
	lsr.l	#1,d0
	lsr.l	#1,d5
.finsi:	move.l	adrecr(pc),a1
	mulu.w	linewidth(pc),d2
	addq.l	#8,a1
	add.w	d6,d6
	add.w	d6,a1		; Ajuste sur la bonne colonne, puis sur le bon plan
	add.l	d2,a1		; a1 = adresse d'affichage du dÇbut du sample
	moveq	#0,d6
	moveq	#0,d7
	move.w	d3,d7
	subq.l	#1,d7		; d7 = largeur-1
	mulu.l	d5,d6:d7
	divu.l	d0,d6:d7		; d7 = position du curseur en pixels
	move.l	d7,d3
	lsr.w	#1,d3
	and.w	#$FFF8,d3
	add.w	d3,a1		; a1 = adresse d'affichage du marqueur
	not.b	d7
	and.w	#15,d7		; d7 = NumÇro du bit Ö positionner pour afficher le marqueur
	moveq	#0,d6
	bset	d7,d6		; d6 = masque
	move.w	linewidth(pc),d2
	subq.w	#1,d4		; d4 = compteur de ligne
.loop:	or.w	d6,(a1)		; Pixel!
	add.w	d2,a1		; Ligne suivante
	dbra	d4,.loop
	movem.l	(sp)+,d0-d7/a1
	rts



*============================================================================*
*	Efface un marqueur de sample				*
*	d0 = longueur.l en octets du sample affichÇ			*
*	d1 = nombre.w d'octets par sample			*
*	d2 = ligne.w d'affichage				*
*	d3 = largeur.w en pixels				*
*	d4 = hauteur.w en pixels				*
*	d5 = position.l du marqueur				*
*	d6 = numÇro.w de plan (0-3)				*
*============================================================================*
efface_marqueur_sample:
	movem.l	d0-d7/a1,-(sp)
	cmp.b	#2,d1
	bne.s	.finsi
	lsr.l	#1,d0
	lsr.l	#1,d5
.finsi:	move.l	adrecr(pc),a1
	mulu.w	linewidth(pc),d2
	addq.l	#8,d2
	add.w	d6,d6
	add.w	d6,d2		; Ajuste sur la bonne colonne, puis sur le bon plan
	add.l	d2,a1		; a1 = adresse d'affichage du dÇbut du sample
	moveq	#0,d6
	moveq	#0,d7
	move.w	d3,d7
	subq.l	#1,d7		; d7 = largeur-1
	mulu.l	d5,d6:d7
	divu.l	d0,d6:d7		; d7 = position du curseur en pixels
	move.l	d7,d3
	lsr.w	#1,d3
	and.w	#$FFF8,d3
	add.w	d3,a1		; a1 = adresse d'affichage du marqueur
	not.b	d7
	and.w	#15,d7		; d7 = NumÇro du bit Ö positionner pour effacer le marqueur
	moveq	#-1,d6
	bclr	d7,d6		; d6 = masque
	move.w	linewidth(pc),d2
	subq.w	#1,d4		; d4 = compteur de ligne
.loop:	and.w	d6,(a1)		; Efface le pixel
	add.w	d2,a1		; Ligne suivante
	dbra	d4,.loop
	movem.l	(sp)+,d0-d7/a1
	rts



*============================================================================*
*	Affiche un sample					*
*	a0 = adresse du sample				*
*	d0 = Longueur en octets.l				*
*	d1 = nbr d'octets par sample (1 = 8 bits, 2 = 16 bits).w	*
*	d2 = ligne d'affichage.w				*
*	d3 = largeur (en colonnes de 16 pixels).w			*
*	d4 = hauteur.w					*
*============================================================================*
affiche_sample:
	movem.l	d0-a6,-(sp)
	cmp.b	#2,d1
	bne.s	.finsi
	lsr.l	#1,d0		; Convertit nbr d'octets en nbr de samples
.finsi:	move.l	adrecr(pc),a1
	mulu.w	linewidth(pc),d2
	addq.l	#8,d2
	add.l	d2,a1		; a1 = adresse d'affichage
	move.w	d4,d2
	lsr.w	#1,d2
	mulu.w	linewidth(pc),d2
	lea	(a1,d2.l),a3	; a3 = adresse de niveau 0
	moveq	#0,d2
	move.w	d3,d2
	lsl.w	#4,d2
	subq.w	#1,d2		; d2 = nbr de pix -1
	moveq	#0,d7
	move.l	d0,d5
	divu.l	d2,d7:d5		; d5 = incrÇment de sample, partie entiäre
	moveq	#0,d6		;    = longueur spl / (nbr pix - 1)
	divu.l	d2,d7:d6		; d6 = inc. de sample, partie dÇcimale (en 2^-32)
	moveq	#0,d2
	subq.l	#1,d6		;      - 1 micropoil pour laisser apparaåtre le dernier sample
	subx.l	d2,d5
	cmp.b	#2,d1		; Sample 16 bits ?
	beq.s	aff_sam_16bits
	subq.w	#1,d3
	moveq	#0,d0		; d0 = position dans le sample
	moveq	#0,d7		; d7 = Position fine
aff_sam_loop1:
	move.w	d3,-(sp)
	move.l	a1,a2		; a2 adresse Çcran
	move.w	d4,d2
	subq.w	#1,d2		; d2 compteur de lignes
aff_sam_loop1_1:			; Efface 16 colonnes
	clr.l	(a2)
	clr.l	4(a2)
	add.w	linewidth(pc),a2
	dbra	d2,aff_sam_loop1_1
	move.w	#$8000,d2		; d2 = masque de bit
	moveq	#15,d1		; d1 = compteur de colonne
aff_sam_loop1_2:
	move.l	a3,a2
	move.w	(a0,d0.l),d3
	clr.b	d3		; d3 = sample
	muls.w	d4,d3
	swap	d3		; d3 = hauteur de la ligne (signÇ)
	tst.w	d3
	bpl.s	aff_sam_positif
	neg.w	d3
.loop:	or.w	d2,(a2)
	or.w	d2,6(a2)
	sub.w	linewidth(pc),a2
	dbra	d3,.loop
	bra.s	aff_sam_finsi
aff_sam_positif:
.loop:	or.w	d2,(a2)
	or.w	d2,6(a2)
	add.w	linewidth(pc),a2
	dbra	d3,.loop
aff_sam_finsi:
	add.l	d6,d7		; Prochain sample
	addx.l	d5,d0
	lsr.w	#1,d2
	dbra	d1,aff_sam_loop1_2
	addq.l	#8,a1
	addq.l	#8,a3
	move.w	(sp)+,d3
	dbra	d3,aff_sam_loop1
	movem.l	(sp)+,d0-a6
	rts

aff_sam_16bits:
	subq.w	#1,d3
	moveq	#0,d0		; d0 = position dans le sample
	moveq	#0,d7		; d7 = Position fine
aff_sam16_loop1:
	move.w	d3,-(sp)
	move.l	a1,a2		; a2 adresse Çcran
	move.w	d4,d2
	subq.w	#1,d2		; d2 compteur de lignes
aff_sam16_loop1_1:			; Efface 16 colonnes
	clr.l	(a2)
	clr.l	4(a2)
	add.w	linewidth(pc),a2
	dbra	d2,aff_sam16_loop1_1
	move.w	#$8000,d2		; d2 = masque de bit
	moveq	#15,d1		; d1 = compteur de colonne
aff_sam16_loop1_2:
	move.l	a3,a2
	move.w	(a0,d0.l*2),d3	; d3 = sample
	muls.w	d4,d3
	swap	d3		; d3 = hauteur de la ligne (signÇ)
	tst.w	d3
	bpl.s	aff_sam16_positif
	neg.w	d3
.loop:	or.w	d2,(a2)
	or.w	d2,6(a2)
	sub.w	linewidth(pc),a2
	dbra	d3,.loop
	bra.s	aff_sam16_finsi
aff_sam16_positif:
.loop:	or.w	d2,(a2)
	or.w	d2,6(a2)
	add.w	linewidth(pc),a2
	dbra	d3,.loop
aff_sam16_finsi:
	add.l	d6,d7		; Prochain sample
	addx.l	d5,d0
	lsr.w	#1,d2
	dbra	d1,aff_sam16_loop1_2
	addq.l	#8,a1
	addq.l	#8,a3
	move.w	(sp)+,d3
	dbra	d3,aff_sam16_loop1
	movem.l	(sp)+,d0-a6
	rts



*============================================================================*
*	Affiche un pattern.					*
*	d0 = le numÇro de la ligne Ö afficher			*
*	d1 = colonne du curseur				*
*	d2 = position du curseur dans la colonne (0-2/0-6/0-7)		*
*	a0 = adresse d'un tableau de renseignements:		*
*	     - nbr voies.w					*
*	     - nbr lignes max.w				*
*	     - nbr colonnes Ö afficher.w				*
*	     - nbr lignes Ö afficher.w				*
*	     - les numÇros de voies associÇes Ö chaque colonne.w (32)	*
*	     - QuantitÇ d'affichage.w (0 = note + instr, 1 = normal,	*
*	       2 = + effet + volume)				*
*	a1 = adresse du dÇbut du pattern				*
*	a2 = adresse d'affichage				*
*============================================================================*
affiche_pattern:
	movem.l	d0-a6,-(sp)

;--- PrÇliminaires -----------------------------------------------------------
; Calcule les index de voies pour le preset
	lea	8(a0),a3		; a3 = adresse du preset
	lea	patpreset5(pc),a4	; a4 = adresse du preset multipliÇ
	move.w	4(a0),d2
	subq.w	#1,d2		; d2 = compteur de voies
.loop:
	move.w	(a3)+,d3
	move.w	d3,d4		; {
	add.w	d3,d3		;   d3 = d3 * 5
	add.w	d3,d3		;
	add.w	d4,d3		; }
	move.w	d3,(a4)+		; On sauve le rÇsultat, comme áa on
	dbra	d2,.loop		; n'a plus Ö faire les multiplications

; Calcule le numÇro de la premiäre ligne Ö afficher
	move.l	a0,a3		; > a3 = adresse du tableau dÇsormais
	move.w	6(a3),d2		; Prend le nombre total de lignes
	move.w	d2,d3		; > d3
	lsr.w	#1,d2		; ... et le divise par 2
	move.w	d2,d6		; d6 = numÇro de ligne Ö afficher en rouge
	sub.w	d2,d0		; d0 = numÇro de raw pour la 1äre ligne

; A partir de áa trouve la bonne adresse dans le pattern
	move.w	d0,d2		; d2 = numÇro de raw de la 1äre ligne
	add.w	d0,d0		; {
	add.w	d0,d0		;   d0 = d0 * 5
	add.w	d2,d0		; }
	muls.w	(a3),d0		; Multiplie par le nombre de voies
	add.l	d0,a1		; a1 = bonne ligne du pattern

	subq.w	#1,d3		; d3 = compteur de lignes

; Choisit le bon type d'affichage
	tst.w	72(a3)
	beq.s	aff_pat_type0
	cmp.w	#2,72(a3)
	beq	aff_pat_type2
	bra	aff_pat_type1

;--- Affichage type 0 : note + instrument ------------------------------------
aff_pat_type0:

; Boucle en Y
; Registres entrant : d2, d3, d6, a1, a2, a3
aff_pat_t0_loop_y:

; Y a t-il une ligne Ö afficher ou du vide ?
	lea	1(a2),a0		; a0 = adresse d'affichage des numÇros
	tst.w	d2
	bmi	aff_pat_t0_blanc	; Si raw < 0
	cmp.w	2(a3),d2
	bge	aff_pat_t0_blanc	; ou si raw => taille en raws

; Affiche les numÇros de raw
	lea	table_byte2char(pc),a4
	move.b	(a4,d2.w*2),d1
	moveq	#1,d0		; d0 = Couleur bleue
	cmp.w	d6,d3
	bne.s	.fc1
	moveq	#2,d0		; ou rouge
.fc1:	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	1(a4,d2.w*2),d1
	bsr	affcar8x6_plan
	addq.l	#8,a0		; Pointe maintenant sur la 1äre colonne

	lea	patpreset5(pc),a4	; a4 = adresse du preset multipliÇ
	move.w	4(a3),d7
	subq.w	#1,d7		; d7 = compteur de colonnes

; Boucle en x
; Registres entrant : d0, d2, d3, d6, d7, a0, a1, a2, a3, a4
aff_pat_t0_loop_x:
	move.w	(a4)+,d5		; Offset de la voie par rapport au dÇbut de raw
	lea	(a1,d5.w),a5	; a5 sur la note Ö afficher

; Affiche la note
	move.b	(a5)+,d5		; *** Le MSByte de d5 doit àtre dÇjÖ nul !
	lea	nom_notes(pc),a6
	lea	(a6,d5.w*4),a6
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#1,a0
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a6),d1
	bsr	affcar8x6_plan
	addq.l	#1,a0

; Affiche l'instrument
	lea	table_byte2char2(pc),a6
	move.b	(a5)+,d5		; *** Le MSByte de d5 doit dÇjÖ àtre nul !
	lea	(a6,d5.w*2),a6
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a6),d1
	bsr	affcar8x6_plan
	addq.l	#8,a0

; Colonne suivante
	dbra	d7,aff_pat_t0_loop_x

; Ligne suivante
aff_pat_t0_next_line
	addq.w	#1,d2		; Raw suivante
	move.w	linewidth(pc),d4
	add.w	d4,d4		; * 6
	move.w	d4,d5
	add.w	d5,d5
	add.w	d5,d4
	add.w	d4,a2		; Ligne de caractäres suivante
	move.w	(a3),d4
	add.w	d4,a1		; * 5
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,a1		; Ligne de pattern suivante
	dbra	d3,aff_pat_t0_loop_y
	bra	aff_pat_fin

; Ligne non affichÇe
aff_pat_t0_blanc:
	move.w	#' ',d1
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	bsr	affcar8x6nt_ombr
	addq.l	#8,a0

	move.w	4(a3),d7
	subq.w	#1,d7		; d7 = compteur de colonnes

aff_pat_t0_blanc_loop_x:
	Rept	2
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	EndR
	bsr	affcar8x6nt_ombr
	addq.l	#8,a0
	dbra	d7,aff_pat_t0_blanc_loop_x

	bra.s	aff_pat_t0_next_line

;--- Affichage type 1 : note + instrument + effet ----------------------------
aff_pat_type1:

; Boucle en Y
; Registres entrant : d2, d3, d6, a1, a2, a3
aff_pat_t1_loop_y:

; Y a t-il une ligne Ö afficher ou du vide ?
	lea	1(a2),a0		; a0 = adresse d'affichage des numÇros
	tst.w	d2
	bmi	aff_pat_t1_blanc	; Si raw < 0
	cmp.w	2(a3),d2
	bge	aff_pat_t1_blanc	; ou si raw => taille en raws

; Affiche les numÇros de raw
	lea	table_byte2char(pc),a4
	move.b	(a4,d2.w*2),d1
	moveq	#1,d0		; d0 = Couleur bleue
	cmp.w	d6,d3
	bne.s	.fc1
	moveq	#2,d0		; ou rouge
.fc1:	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	1(a4,d2.w*2),d1
	bsr	affcar8x6_plan
	addq.l	#8,a0		; Pointe maintenant sur la 1äre colonne

	lea	patpreset5(pc),a4	; a4 = adresse du preset multipliÇ
	move.w	4(a3),d7
	subq.w	#1,d7		; d7 = compteur de colonnes

; Boucle en x
; Registres entrant : d0, d2, d3, d6, d7, a0, a1, a2, a3, a4
aff_pat_t1_loop_x:
	move.w	(a4)+,d5		; Offset de la voie par rapport au dÇbut de raw
	lea	(a1,d5.w),a5	; a5 sur la note Ö afficher

; Affiche la note
	move.b	(a5)+,d5		; *** Le MSByte de d5 doit àtre dÇjÖ nul !
	lea	nom_notes(pc),a6
	lea	(a6,d5.w*4),a6
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#1,a0
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a6),d1
	bsr	affcar8x6_plan
	addq.l	#1,a0

; Affiche l'instrument
	lea	table_byte2char2(pc),a6
	move.b	(a5)+,d5		; *** Le MSByte de d5 doit dÇjÖ àtre nul !
	lea	(a6,d5.w*2),a6
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a6),d1
	bsr	affcar8x6_plan
	addq.l	#1,a0


; Affiche l'effet
	tst.w	(a5)
	beq.s	.pasfx		; Pas d'effet : on n'affiche que des points
	move.b	(a5)+,d5		; *** Le MSByte de d5 doit dÇjÖ àtre nul !
	lea	table_byte2char3(pc),a6
	lea	(a6,d5.w*2),a6	; Affichage avec un point Ö la place du 0
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a6),d1
	bsr	affcar8x6_plan
	addq.l	#1,a0
	move.b	(a5)+,d5		; *** Le MSByte de d5 doit dÇjÖ àtre nul !
	lea	table_byte2char(pc),a6
	lea	(a6,d5.w*2),a6	; Affichage normal
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a6),d1
	bsr	affcar8x6_plan
	addq.l	#8,a0
	bra.s	.finfx

.pasfx:
	moveq	#9,d1		; Met des points
	bsr	affcar8x6_plan
	addq.l	#7,a0
	bsr	affcar8x6_plan
	addq.l	#1,a0
	bsr	affcar8x6_plan
	addq.l	#7,a0
	bsr	affcar8x6_plan
	addq.l	#8,a0
.finfx:

; Colonne suivante
	dbra	d7,aff_pat_t1_loop_x

; Ligne suivante
aff_pat_t1_next_line
	addq.w	#1,d2		; Raw suivante
	move.w	linewidth(pc),d4
	add.w	d4,d4		; * 6
	move.w	d4,d5
	add.w	d5,d5
	add.w	d5,d4
	add.w	d4,a2		; Ligne de caractäres suivante
	move.w	(a3),d4
	add.w	d4,a1		; * 5
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,a1		; Ligne de pattern suivante
	dbra	d3,aff_pat_t1_loop_y
	bra	aff_pat_fin

; Ligne non affichÇe
aff_pat_t1_blanc:
	move.w	#' ',d1
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	bsr	affcar8x6nt_ombr
	addq.l	#8,a0

	move.w	4(a3),d7
	subq.w	#1,d7		; d7 = compteur de colonnes

aff_pat_t1_blanc_loop_x:
	Rept	4
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	EndR
	bsr	affcar8x6nt_ombr
	addq.l	#8,a0
	dbra	d7,aff_pat_t1_blanc_loop_x

	bra.s	aff_pat_t1_next_line

;--- Affichage type 2 : note + instrument + effet + volume--------------------
aff_pat_type2:

; Boucle en Y
; Registres entrant : d2, d3, d6, a1, a2, a3
aff_pat_t2_loop_y:

; Y a t-il une ligne Ö afficher ou du vide ?
	lea	1(a2),a0		; a0 = adresse d'affichage des numÇros
	tst.w	d2
	bmi	aff_pat_t2_blanc	; Si raw < 0
	cmp.w	2(a3),d2
	bge	aff_pat_t2_blanc	; ou si raw => taille en raws

; Affiche les numÇros de raw
	lea	table_byte2char(pc),a4
	move.b	(a4,d2.w*2),d1
	moveq	#1,d0		; d0 = Couleur bleue
	cmp.w	d6,d3
	bne.s	.fc1
	moveq	#2,d0		; ou rouge
.fc1:	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	1(a4,d2.w*2),d1
	bsr	affcar8x6_plan
	addq.l	#8,a0		; Pointe maintenant sur la 1äre colonne

	lea	patpreset5(pc),a4	; a4 = adresse du preset multipliÇ
	move.w	4(a3),d7
	subq.w	#1,d7		; d7 = compteur de colonnes

; Boucle en x
; Registres entrant : d0, d2, d3, d6, d7, a0, a1, a2, a3, a4
aff_pat_t2_loop_x:
	move.w	(a4)+,d5		; Offset de la voie par rapport au dÇbut de raw
	lea	(a1,d5.w),a5	; a5 sur la note Ö afficher

; Affiche la note
	move.b	(a5)+,d5		; *** Le MSByte de d5 doit àtre dÇjÖ nul !
	lea	nom_notes(pc),a6
	lea	(a6,d5.w*4),a6
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#1,a0
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a6),d1
	bsr	affcar8x6_plan
	addq.l	#1,a0

; Affiche l'instrument
	lea	table_byte2char2(pc),a6
	move.b	(a5)+,d5		; *** Le MSByte de d5 doit dÇjÖ àtre nul !
	lea	(a6,d5.w*2),a6
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a6),d1
	bsr	affcar8x6_plan
	addq.l	#1,a0


; Affiche l'effet
	tst.w	(a5)
	beq.s	.pasfx		; Pas d'effet : on n'affiche que des points
	move.b	(a5)+,d5		; *** Le MSByte de d5 doit dÇjÖ àtre nul !
	lea	table_byte2char3(pc),a6
	lea	(a6,d5.w*2),a6	; Affichage avec un point Ö la place du 0
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a6),d1
	bsr	affcar8x6_plan
	addq.l	#1,a0
	move.b	(a5)+,d5		; *** Le MSByte de d5 doit dÇjÖ àtre nul !
	lea	table_byte2char(pc),a6
	lea	(a6,d5.w*2),a6	; Affichage normal
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a6),d1
	bsr	affcar8x6_plan
	addq.l	#1,a0
	bra.s	.finfx

.pasfx:
	moveq	#9,d1		; Met des points
	bsr	affcar8x6_plan
	addq.l	#7,a0
	bsr	affcar8x6_plan
	addq.l	#1,a0
	bsr	affcar8x6_plan
	addq.l	#7,a0
	bsr	affcar8x6_plan
	addq.l	#1,a0
	addq.l	#2,a5		; Saute l'effet dans le pattern
.finfx:

; Affiche le volume
	move.b	(a5),d5		; *** Le MSByte de d5 doit dÇjÖ àtre nul !
	lea	table_byte2char2(pc),a6
	lea	(a6,d5.w*2),a6
	move.b	(a6)+,d1
	bsr	affcar8x6_plan
	addq.l	#7,a0
	move.b	(a6),d1
	bsr	affcar8x6_plan
	addq.l	#8,a0

; Colonne suivante
	dbra	d7,aff_pat_t2_loop_x

; Ligne suivante
aff_pat_t2_next_line
	addq.w	#1,d2		; Raw suivante
	move.w	linewidth(pc),d4
	add.w	d4,d4		; * 6
	move.w	d4,d5
	add.w	d5,d5
	add.w	d5,d4
	add.w	d4,a2		; Ligne de caractäres suivante
	move.w	(a3),d4
	add.w	d4,a1		; * 5
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,a1		; Ligne de pattern suivante
	dbra	d3,aff_pat_t2_loop_y
	bra	aff_pat_fin

; Ligne non affichÇe
aff_pat_t2_blanc:
	move.w	#' ',d1
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	bsr	affcar8x6nt_ombr
	addq.l	#8,a0

	move.w	4(a3),d7
	subq.w	#1,d7		; d7 = compteur de colonnes

aff_pat_t2_blanc_loop_x:
	Rept	5
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	EndR
	bsr	affcar8x6nt_ombr
	addq.l	#8,a0
	dbra	d7,aff_pat_t2_blanc_loop_x

	bra.s	aff_pat_t2_next_line

;-----------------------------------------------------------------------------
aff_pat_fin:
	movem.l	(sp)+,d0-a6
	bsr	affiche_curseur	; Va afficher le curseur
	rts



*============================================================================*
*	Affiche le curseur					*
*	d1 = colonne du curseur				*
*	d2 = position du curseur dans la colonne (0-6)		*
*	a0 = tableau de renseignements (voir + haut)		*
*	a2 = adresse d'affichage				*
*============================================================================*
affiche_curseur:
	movem.l	d0-d3/a0/a2,-(sp)

;--- Effaáage du curseur prÇcÇdent -------------------------------------------
	move.w	oldcolcurs(pc),d1
	move.w	oldposcurs(pc),d2
	move.w	6(a0),d0
	and.b	#$FE,d0
	move.w	d0,d3
	add.w	d0,d0
	add.w	d3,d0		; INT(d0/2) * 6
	mulu.w	linewidth(pc),d0
	add.l	d0,a2		; a2 adresse de la ligne d'affichage
	lsl.w	#3,d1		; d1 * 24, 40 ou 48
	move.w	d1,d3
	add.w	d1,d1
	tst.w	72(a0)
	beq.s	.ok24_e
	add.w	d1,d1
	cmp.w	#2,72(a0)
	bne.s	.ok40_e
	add.w	d3,d1
.ok40_e:
.ok24_e:	add.w	d3,d1
	add.w	d1,a2		; Sur la bonne colonne
	lea	curs_x_table(pc),a0
	add.w	(a0,d2.w*2),a2	; Position exacte
	move.w	linewidth(pc),d1
	Rept	5
	clr.b	(a2)		; on efface
	add.w	d1,a2
	EndR
	clr.b	(a2)
	movem.l	(sp),d0-d3/a0/a2	; *** Les donnÇes restent quand màme dans la pile

;--- Affichage du nouveau curseur --------------------------------------------
	move.w	d1,oldcolcurs
	move.w	d2,oldposcurs
	move.w	6(a0),d0
	and.b	#$FE,d0
	move.w	d0,d3
	add.w	d0,d0
	add.w	d3,d0		; INT(d0/2) * 6
	mulu.w	linewidth(pc),d0
	add.l	d0,a2		; a2 adresse de la ligne d'affichage
	lsl.w	#3,d1		; d1 * 24, 40 ou 48
	move.w	d1,d3
	add.w	d1,d1
	tst.w	72(a0)
	beq.s	.ok24
	add.w	d1,d1
	cmp.w	#2,72(a0)
	bne.s	.ok40
	add.w	d3,d1
.ok40:
.ok24:	add.w	d3,d1
	add.w	d1,a2		; Sur la bonne colonne
	lea	curs_x_table(pc),a0
	add.w	(a0,d2.w*2),a2	; Position exacte
	moveq	#-1,d0
	move.w	linewidth(pc),d1
	Rept	5
	move.b	d0,(a2)		; on colorie
	add.w	d1,a2
	EndR
	move.b	d0,(a2)
	movem.l	(sp)+,d0-d3/a0/a2
	rts



*============================================================================*
*	Grise une surface en mettant un pixel sur deux en noir.	*
*	d0 = Abscisse.w de la surface, en colonnes de 8 pixels		*
*	d1 = OrdonnÇe.w, en pixels				*
*	d2 = Longueur.w - 1 , en colonnes de 8 pixels		*
*	d3 = Hauteur.w - 1, en pixels				*
*============================================================================*
grise_surface:
	movem.l	d0-a6,-(sp)
	move.l	adrecr(pc),a0	; Prend l'adresse de l'Çcran
	mulu.w	linewidth(pc),d1	; OrdonnÇe en octets
	moveq	#1,d4		; L'incrÇment pour passer d'une col Ö la suivante
	lsl.w	#2,d0
	btst	#2,d0
	beq.s	.suite
	subq.w	#3,d0		; Colonne impaire, on corrige l'erreur commise
	moveq	#7,d4		; Du coup on change l'incrÇment
.suite:	add.w	d0,a0
	add.l	d1,a0		; Adresse de la partie Ö griser
	moveq	#%01010101,d1	; Masque   : And
	moveq	#-$56,d7		; Masque 2 : Or
	moveq	#%110,d5		; Le schmurtz d'alternance
.loopy:
	move.w	d2,d0		; d0 = compteur de colonnes
	move.l	a0,a1		; a1 = adresse qu'on grise
	move.w	d4,d6		; d6 = incrÇment d'adresse
.loopx:
	and.b	d1,(a1)		; Masque les 4 plans
	and.b	d1,2(a1)
	or.b	d7,4(a1)
	or.b	d7,6(a1)
	add.w	d6,a1		; Additionne 1 ou 7 Ö a1 pour changer de colonne
	eor.b	d5,d6		; Alterne +1 <-> +7 Ö chaque fois
	dbra	d0,.loopx

	add.w	linewidth(pc),a0	; Ligne suivante
	not.w	d1		; On dÇcale le masque pour faire une grille
	not.w	d7
	dbra	d3,.loopy

	movem.l	(sp)+,d0-a6
	rts



*============================================================================*
*	Cadre (bords intÇrieurs) avec un texte centrÇ Ö l'intÇrieur	*
*	d0 = longueur.w maxi du texte (largeur du cadre, quoi)		*
*	a0 = adresse du tableau de donnÇes concernant le cadre		*
*	Seules les coordonnÇes, longueur et les couleurs doivent	*
*	àtre remplies					*
*	a1 = adresse du texte. A la fin a1 pointe sur la chaine suivante	*
*============================================================================*
cadre_centre:

	movem.l	d0-d3,-(sp)
	move.w	d0,c_large(a0)
	bsr	dessine_cadre_int	; Dessin du cadre
	add.w	c_colonne(a0),d0
	add.w	c_colonne(a0),d0	; d0 = position x du milieu du cadre (4 pix)
	move.l	a1,a2
	addq.w	#2,d0
.loop	subq.w	#1,d0		; Recherche la longueur de la
	tst.b	(a2)+		; chaine (sans le 0 final)
	bne.s	.loop		; RÇsultat : d0 position de la chaine
	move.w	d0,d2
	move.w	c_haut(a0),d3	; Hauteur du cadre
	subq.w	#5,d3		; Hauteur du texte
	asr.w	#1,d3		; MoitiÇ
	add.w	c_ligne(a0),d3	; NumÇro de ligne d'affichage pour le texte
	move.b	c_cbordo(a0),d0	; RÇcupäre les couleurs
	move.b	c_cborde(a0),d1
	bsr	affchaine_trans_ombr	; Affichage du texte
	movem.l	(sp)+,d0-d3
	rts



*============================================================================*
*	Affiche un cadre aux coordonnÇes indiquÇes.			*
*	Les contours sont Ö l'intÇrieur				*
*	a0 pointe sur le tableau d'informations pour le cadre		*
*	Structure du tableau:					*
*	- colonne.w	Une colonne fait 8 pixels		*
*	- ligne.w		NumÇro de la ligne			*
*	- largeur.w	-1 (en colonnes)			*
*	- hauteur.w	-1				*
*	- couleur.b	du fond				*
*	- couleur.b	du bord normal			*
*	- couleur.b	du bord ÇclairÇ			*
*	- couleur.b	du bord ombrÇ			*
*============================================================================*
dessine_cadre_int:

	movem.l	d0-d7/a0-a3,-(sp)
	move.l	adrecr(pc),a1	; a1 = adresse de l'Çcran
	move.w	c_ligne(a0),d0
	muls.w	linewidth(pc),d0
	add.l	d0,a1		; a1 Ö la bonne ligne
	move.w	c_large(a0),d6	; d6 = largeur
	move.w	c_haut(a0),d7	; d7 = hauteur
	move.w	c_colonne(a0),d0	; d0 = numÇro de colonne
	bclr	#0,d0
	lsl.w	#2,d0
	add.w	d0,a1		; a1 = adresse d'affichage (haut-gauche)

; Affichage du fond
	move.b	c_cfond(a0),d0	; d0 = couleur du fond
	prend_couleurs	d0	; d2-d5 contiennent la valeur de chaque plan
	move.w	linewidth(pc),d1	; d1 = saut de ligne
	subq.w	#6,d1
	move.l	a1,a3
	btst	#0,c_colonne+1(a0)
	beq.s	descadr_paire	; Colonne paire, ok
	addq.l	#1,a1		; Sinon on rajoute 1 Ö l'adresse d'aff.
	move.l	a1,a3

descadr_impaire:			; Affichage d'une colonne impaire
	move.l	a3,a2
	move.w	d7,d0		; d0 = compteur de ligne
descadr_imploop:
	remplit8pixels
	add.w	d1,a2		; Ligne suivante
	dbra	d0,descadr_imploop
	subq.w	#1,d6
	bmi.s	descadr_fondfin
	addq.l	#7,a3		; Colonne suivante (paire maintenant)
descadr_paire:			; Affichage d'une colonne impaire
	move.l	a3,a2
	move.w	d7,d0		; d0 = compteur de ligne
descadr_ploop:
	remplit8pixels
	add.w	d1,a2		; Ligne suivante
	dbra	d0,descadr_ploop
	addq.l	#1,a3		; Colonne suivante (impaire maintenant)
	dbra	d6,descadr_impaire
descadr_fondfin:

; Affichage des bords horizontaux hauts et bas
	move.b	c_cborde(a0),d0	; d0 = couleur du bord ÇclairÇ
	prend_couleurs	d0
	inverse_couleurs
	move.b	c_cbordo(a0),d0	; d0 = couleur du bord ombrÇ
	prend_couleurs	d0
	inverse_couleurs
	move.l	a1,a2		; a2 = adresse d'affichage
	move.w	c_large(a0),d6	; d6 = largeur
	btst	#0,c_colonne+1(a0)
	beq.s	descadr_paire2	; Si la colonne est paire

descadr_impaire2:			; Affichage sur une colonne impaire
	remplit8pixels
	addq.l	#1,a2
	subq.w	#1,d6
	bmi.s	descadr_bordhfin1
descadr_paire2:			; Affichage sur une colonne paire
	remplit8pixels
	subq.l	#5,a2
	dbra	d6,descadr_impaire2
	addq.l	#6,a2
descadr_bordhfin1:
	lea	-7(a2),a3		; a3 adresse du coin haut-droit du cadre

	inverse_couleurs		; Le bord ombrÇ maintenant
	move.l	a1,a2
	move.w	c_haut(a0),d0
	muls.w	linewidth(pc),d0
	add.l	d0,a2		; Derniäre ligne
	move.w	c_large(a0),d6	; d6 = largeur
	btst	#0,c_colonne+1(a0)
	beq.s	descadr_paire3	; Si la colonne est paire

descadr_impaire3:			; Affichage sur une colonne impaire
	remplit8pixels
	addq.l	#1,a2
	subq.w	#1,d6
	bmi.s	descadr_bordhfin2
descadr_paire3:			; Affichage sur une colonne paire
	remplit8pixels
	subq.l	#5,a2
	dbra	d6,descadr_impaire3
descadr_bordhfin2:

; Affiche les bords verticaux droit et gauche
	move.l	a3,a2
	moveq	#-2,d0
	moveq	#1,d1
	move.w	linewidth(pc),d6
	subq.w	#6,d6
	move.w	c_haut(a0),d7
descadr_borddloop:
	affiche_1pixel
	add.w	d6,a2
	dbra	d7,descadr_borddloop

	inverse_couleurs		; Le bord gauche maintenant
	move.l	a1,a2
	moveq	#$7F,d0
	moveq	#-128,d1
	move.w	c_haut(a0),d7
descadr_bordgloop:
	affiche_1pixel
	add.w	d6,a2
	dbra	d7,descadr_bordgloop

; Affiche maintenant les coins B-G et H-D
	sub.w	linewidth(pc),a2
	move.b	c_cbordn(a0),d6
	prend_couleurs	d6
	affiche_1pixel

	move.l	a3,a2
	moveq	#-2,d0
	moveq	#1,d1
	affiche_1pixel

	movem.l	(sp)+,d0-d7/a0-a3
	rts



*============================================================================*
*	Affiche un cadre aux coordonnÇes indiquÇes.			*
*	Les contours sont Ö l'extÇrieur				*
*	a0 pointe sur le tableau d'informations pour le cadre		*
*	Structure du tableau:					*
*	- colonne.w	Une colonne fait 8 pixels		*
*	- ligne.w		NumÇro de la ligne			*
*	- largeur.w	-1 (en colonnes)			*
*	- hauteur.w	-1				*
*	- couleur.b	du fond				*
*	- couleur.b	du bord normal			*
*	- couleur.b	du bord ÇclairÇ			*
*	- couleur.b	du bord ombrÇ			*
*============================================================================*
dessine_cadre_ext:

	movem.l	d0-d7/a0-a3,-(sp)
	move.l	adrecr(pc),a1	; a1 = adresse de l'Çcran
	move.w	c_ligne(a0),d0
	muls.w	linewidth(pc),d0
	add.l	d0,a1		; a1 Ö la bonne ligne
	move.w	c_large(a0),d6	; d6 = largeur
	move.w	c_haut(a0),d7	; d7 = hauteur
	move.w	c_colonne(a0),d0	; d0 = numÇro de colonne
	bclr	#0,d0
	lsl.w	#2,d0
	add.w	d0,a1		; a1 = adresse d'affichage (haut-gauche)

; Affichage du fond
	move.b	c_cfond(a0),d0	; d0 = couleur du fond
	prend_couleurs	d0	; d2-d5 contiennent la valeur de chaque plan
	move.w	linewidth(pc),d1	; d1 = saut de ligne
	subq.w	#6,d1
	move.l	a1,a3
	btst	#0,c_colonne+1(a0)
	beq.s	descadrext_paire	; Colonne paire, ok
	addq.l	#1,a1		; Sinon on rajoute 1 Ö l'adresse d'aff.
	move.l	a1,a3

descadrext_impaire:			; Affichage d'une colonne impaire
	move.l	a3,a2
	move.w	d7,d0		; d0 = compteur de ligne
descadrext_imploop:
	remplit8pixels
	add.w	d1,a2		; Ligne suivante
	dbra	d0,descadrext_imploop
	subq.w	#1,d6
	bmi.s	descadrext_fondfin
	addq.l	#7,a3		; Colonne suivante (paire maintenant)
descadrext_paire:			; Affichage d'une colonne impaire
	move.l	a3,a2
	move.w	d7,d0		; d0 = compteur de ligne
descadrext_ploop:
	remplit8pixels
	add.w	d1,a2		; Ligne suivante
	dbra	d0,descadrext_ploop
	addq.l	#1,a3		; Colonne suivante (impaire maintenant)
	dbra	d6,descadrext_impaire
descadrext_fondfin:

; Affichage des bords horizontaux hauts et bas
	move.b	c_cborde(a0),d0	; d0 = couleur du bord ÇclairÇ
	prend_couleurs	d0
	inverse_couleurs
	move.b	c_cbordo(a0),d0	; d0 = couleur du bord ombrÇ
	prend_couleurs	d0
	inverse_couleurs
	move.l	a1,a2		; a2 = adresse d'affichage
	sub.w	linewidth(pc),a2	; Commence une ligne plus haut
	move.w	c_large(a0),d6	; d6 = largeur
	btst	#0,c_colonne+1(a0)
	beq.s	descadrext_paire2	; Si la colonne est paire

descadrext_impaire2:			; Affichage sur une colonne impaire
	remplit8pixels
	addq.l	#1,a2
	subq.w	#1,d6
	bmi.s	descadrext_bordhfin1
descadrext_paire2:			; Affichage sur une colonne paire
	remplit8pixels
	subq.l	#5,a2
	dbra	d6,descadrext_impaire2
descadrext_bordhfin1:
	move.l	a2,a3		; a3 adresse du coin haut-droit du cadre (extÇrieur)

	inverse_couleurs		; Le bord ombrÇ maintenant
	move.l	a1,a2
	move.w	c_haut(a0),d0
	addq.w	#1,d0
	muls.w	linewidth(pc),d0
	add.l	d0,a2		; Apräs la derniäre ligne
	move.w	c_large(a0),d6	; d6 = largeur
	btst	#0,c_colonne+1(a0)
	beq.s	descadrext_paire3	; Si la colonne est paire

descadrext_impaire3:			; Affichage sur une colonne impaire
	remplit8pixels
	addq.l	#1,a2
	subq.w	#1,d6
	bmi.s	descadrext_bordhfin2
descadrext_paire3:			; Affichage sur une colonne paire
	remplit8pixels
	subq.l	#5,a2
	dbra	d6,descadrext_impaire3
descadrext_bordhfin2:

; Affiche les bords verticaux droit et gauche
	move.l	a3,a2
	moveq	#$7F,d0
	moveq	#-128,d1
	move.w	linewidth(pc),d6
	subq.w	#6,d6
	move.w	c_haut(a0),d7
descadrext_borddloop:
	affiche_1pixel
	add.w	d6,a2
	dbra	d7,descadrext_borddloop

	inverse_couleurs		; Le bord gauche maintenant
	move.l	a1,a2
	btst	#0,c_colonne+1(a0)
	beq.s	descadrext_paire4
	addq.l	#6,a2
descadrext_paire4:
	subq.l	#7,a2
	moveq	#-2,d0
	moveq	#1,d1
	move.w	c_haut(a0),d7
descadrext_bordgloop:
	affiche_1pixel
	add.w	d6,a2
	dbra	d7,descadrext_bordgloop

; Affiche maintenant les coins B-G et H-D
	sub.w	linewidth(pc),a2
	move.b	c_cbordn(a0),d6
	prend_couleurs	d6
	affiche_1pixel

	move.l	a3,a2
	moveq	#$7F,d0
	moveq	#-128,d1
	affiche_1pixel

	movem.l	(sp)+,d0-d7/a0-a3
	rts



*============================================================================*
*	Affiche une chaine ASCII en mode transparent		*
*	d0 = couleur					*
*	d2 = position x (4 pixels)				*
*	d3 = position y					*
*	a1 = adresse de la chaine (se termine par 0)		*
*	Au retour a1 pointe sur la chaine suivante			*
*============================================================================*
affchaine_trans:

	movem.l	d0-d3/a0,-(sp)
	move.l	adrecr(pc),a0
	muls.w	linewidth(pc),d3
	add.l	d3,a0		; a0 Ö la bonne ligne Çcran
	moveq	#0,d1		; Pour ne pas avoir de probläme octet/mot
	lsl.w	d2
	bclr	#2,d2		; Adresse paire ou impaire ?
	bne.s	.impaire
	bclr	#1,d2		; DÇcalage ou pas ?
	bne.s	.paire_dec

	add.w	d2,a0		; Paire normal
.loop1:	move.b	(a1)+,d1
	beq.s	affchaine1_fin
	bsr	affcar8x6
	addq.l	#1,a0
.entree1:	move.b	(a1)+,d1
	beq.s	affchaine1_fin
	bsr	affcar8x6
	addq.l	#7,a0
	bra.s	.loop1
.paire_dec:			; Paire dÇcalÇ
	add.w	d2,a0
.loop2:	move.b	(a1)+,d1
	beq.s	affchaine1_fin
	bsr	affcar8x6_dec
	addq.l	#1,a0
.entree2:	move.b	(a1)+,d1
	beq.s	affchaine1_fin
	bsr	affcar8x6_dec
	addq.l	#7,a0
	bra.s	.loop2

.impaire:
	bclr	#1,d2
	bne.s	.impaire_dec
	add.w	d2,a0		; Impaire normal
	addq.l	#1,a0
	bra.s	.entree1
.impaire_dec:			; Impaire dÇcalÇ
	add.w	d2,a0
	addq.l	#1,a0
	bra.s	.entree2

affchaine1_fin:
	movem.l	(sp)+,d0-d3/a0
	rts



*============================================================================*
*	Affiche une chaine ASCII en mode transparent ombrÇ		*
*	d0 = couleur de la partie ombrÇe				*
*	d1 = couleur de la partie ÇclairÇe			*
*	d2 = position x (4 pixels)				*
*	d3 = position y					*
*	a1 = adresse de la chaine (se termine par 0)		*
*	Au retour a1 pointe sur la chaine suivante			*
*============================================================================*
affchaine_trans_ombr:

	move.w	d0,-(sp)
	move.l	a2,-(sp)
	move.l	a1,a2		; Conserve l'adresse de de la chaine
	movem.l	d0-d3/a0,-(sp)	; Affiche la partie ombrÇe
	move.l	adrecr(pc),a0
	muls.w	linewidth(pc),d3
	add.l	d3,a0		; a0 Ö la bonne ligne Çcran
	moveq	#0,d1		; Pour ne pas avoir de probläme octet/mot
	lsl.w	d2
	bclr	#2,d2		; Adresse paire ou impaire ?
	bne.s	.impaire
	bclr	#1,d2		; DÇcalage ou pas ?
	bne.s	.paire_dec

	add.w	d2,a0		; Paire normal
.loop1:	move.b	(a1)+,d1
	beq.s	affchaine2_fin
	bsr	affcar8x6_ombr
	addq.l	#1,a0
.entree1:	move.b	(a1)+,d1
	beq.s	affchaine2_fin
	bsr	affcar8x6_ombr
	addq.l	#7,a0
	bra.s	.loop1
.paire_dec:			; Paire dÇcalÇ
	add.w	d2,a0
.loop2:	move.b	(a1)+,d1
	beq.s	affchaine2_fin
	bsr	affcar8x6_ombr_dec
	addq.l	#1,a0
.entree2:	move.b	(a1)+,d1
	beq.s	affchaine2_fin
	bsr	affcar8x6_ombr_dec
	addq.l	#7,a0
	bra.s	.loop2

.impaire:
	bclr	#1,d2
	bne.s	.impaire_dec
	add.w	d2,a0		; Impaire normal
	addq.l	#1,a0
	bra.s	.entree1
.impaire_dec:			; Impaire dÇcalÇ
	add.w	d2,a0
	addq.l	#1,a0
	bra.s	.entree2

affchaine2_fin:
	movem.l	(sp)+,d0-d3/a0
	move.l	a2,a1		; a1 adresse de l'ancienne chaine
	move.w	d1,d0		; d0 couleur ÇclairÇe
	bsr	affchaine_trans	; Va afficher la partie ÇclairÇe
	move.l	(sp)+,a2
	move.w	(sp)+,d0
	rts



*============================================================================*
*	Affiche une chaine ASCII en mode replace			*
*	d0 = couleur					*
*	d2 = position x (8 pixels)				*
*	d3 = position y					*
*	a1 = adresse de la chaine (se termine par 0)		*
*	Au retour a1 pointe sur la chaine suivante			*
*============================================================================*
affchaine_notrans:

	movem.l	d0-d3/a0,-(sp)	; Affiche la partie ombrÇe
	move.l	adrecr(pc),a0
	muls.w	linewidth(pc),d3
	add.l	d3,a0		; a0 Ö la bonne ligne Çcran
	moveq	#0,d1		; Pour ne pas avoir de probläme octet/mot
	lsl.w	#2,d2
	bclr	#2,d2		; Adresse paire ou impaire ?
	bne.s	.impaire

	add.w	d2,a0		; Paire
.loop1:	move.b	(a1)+,d1
	beq.s	affchaine3_fin
	bsr	affcar8x6nt_ombr
	addq.l	#1,a0
.entree1:	move.b	(a1)+,d1
	beq.s	affchaine3_fin
	bsr	affcar8x6nt_ombr
	addq.l	#7,a0
	bra.s	.loop1

.impaire:
	add.w	d2,a0		; Impaire
	addq.l	#1,a0
	bra.s	.entree1

affchaine3_fin:
	movem.l	(sp)+,d0-d3/a0
	rts



*============================================================================*
*	Affiche une chaine ASCII en mode plan			*
*	d0 = couleur					*
*	d2 = position x (8 pixels)				*
*	d3 = position y					*
*	a1 = adresse de la chaine (se termine par 0)		*
*	Au retour a1 pointe sur la chaine suivante			*
*============================================================================*
affchaine_plan:

	movem.l	d0-d3/a0,-(sp)	; Affiche la partie ombrÇe
	move.l	adrecr(pc),a0
	muls.w	linewidth(pc),d3
	add.l	d3,a0		; a0 Ö la bonne ligne Çcran
	moveq	#0,d1		; Pour ne pas avoir de probläme octet/mot
	lsl.w	#2,d2
	bclr	#2,d2		; Adresse paire ou impaire ?
	bne.s	.impaire

	add.w	d2,a0		; Paire
.loop1:	move.b	(a1)+,d1
	beq.s	affchaine4_fin
	bsr	affcar8x6_plan
	addq.l	#1,a0
.entree1:	move.b	(a1)+,d1
	beq.s	affchaine4_fin
	bsr	affcar8x6_plan
	addq.l	#7,a0
	bra.s	.loop1

.impaire:
	add.w	d2,a0		; Impaire
	addq.l	#1,a0
	bra.s	.entree1

affchaine4_fin:
	movem.l	(sp)+,d0-d3/a0
	rts



*============================================================================*
*	Affiche un caractäre 8x6 Ö l'adresse indiquÇe		*
*	d1 = numÇro ASCII du caractäre				*
*	d0 = couleur					*
*	a0 = adresse d'affichage				*
*	Vitesse moyenne : 7800 caractäres/seconde			*
*============================================================================*
affcar8x6:

	movem.l	d0-d5/a0-a1,-(sp)
	lea	fonte8x6(pc),a1
	move.w	linewidth(pc),d3
affcar1_bra:
	subq.w	#6,d3
	add.w	d1,d1
	add.w	d1,a1
	add.w	d1,d1
	add.w	d1,a1		; a1 pointe sur le caractäre
	moveq	#5,d1		; 6 lignes
affcar1_loop:
	move.w	d0,d2
	move.b	(a1)+,d4
	move.w	d4,d5
	not.w	d5
affcar1_plan:
	and.b	d5,(a0)
	lsr.w	d2
	bcc.s	affcar1_suitea
	or.b	d4,(a0)
affcar1_suitea:
	addq.l	#2,a0
	and.b	d5,(a0)
	lsr.w	d2
	bcc.s	affcar1_suiteb
	or.b	d4,(a0)
affcar1_suiteb:
	addq.l	#2,a0
	and.b	d5,(a0)
	lsr.w	d2
	bcc.s	affcar1_suitec
	or.b	d4,(a0)
affcar1_suitec:
	addq.l	#2,a0
	and.b	d5,(a0)
	lsr.w	d2
	bcc.s	affcar1_suited
	or.b	d4,(a0)
affcar1_suited:
	add.w	d3,a0
	dbra	d1,affcar1_loop
	movem.l	(sp)+,d0-d5/a0-a1
	rts



*============================================================================*
*	Affiche un caractäre 8x6 Ö l'adresse indiquÇe		*
*	avec un dÇcalage de 4 pixels sur la droite			*
*	d1 = numÇro ASCII du caractäre				*
*	d0 = couleur					*
*	a0 = adresse d'affichage				*
*============================================================================*
affcar8x6_dec:

	movem.l	d0-d7/a0-a2,-(sp)
	lea	fonte8x6(pc),a1
	move.w	linewidth(pc),d3
affcar2_bra:
	subq.w	#6,d3
	add.w	d1,d1
	add.w	d1,a1
	add.w	d1,d1
	add.w	d1,a1		; a1 pointe sur le caractäre
	lea	1(a0),a2
	move.w	a0,d1
	btst	#0,d1
	beq.s	affcar2_suite2
	addq.l	#6,a2
affcar2_suite2:
	moveq	#5,d1		; 6 lignes
affcar2_loop:
	move.w	d0,d2
	move.b	(a1)+,d4
	move.w	d4,d6
	lsr.b	#4,d4
	lsl.b	#4,d6
	move.w	d4,d5
	move.w	d6,d7
	not.w	d5
	not.w	d7
affcar2_plan:
	and.b	d5,(a0)
	and.b	d7,(a2)
	lsr.w	d2
	bcc.s	affcar2_suitea
	or.b	d4,(a0)
	or.b	d6,(a2)
affcar2_suitea:
	addq.l	#2,a0
	addq.l	#2,a2
	and.b	d5,(a0)
	and.b	d7,(a2)
	lsr.w	d2
	bcc.s	affcar2_suiteb
	or.b	d4,(a0)
	or.b	d6,(a2)
affcar2_suiteb:
	addq.l	#2,a0
	addq.l	#2,a2
	and.b	d5,(a0)
	and.b	d7,(a2)
	lsr.w	d2
	bcc.s	affcar2_suitec
	or.b	d4,(a0)
	or.b	d6,(a2)
affcar2_suitec:
	addq.l	#2,a0
	addq.l	#2,a2
	and.b	d5,(a0)
	and.b	d7,(a2)
	lsr.w	d2
	bcc.s	affcar2_suited
	or.b	d4,(a0)
	or.b	d6,(a2)
affcar2_suited:
	add.w	d3,a0
	add.w	d3,a2
	dbra	d1,affcar2_loop
	movem.l	(sp)+,d0-d7/a0-a2
	rts



*============================================================================*
*	Affiche un caractäre 8x6 Ö l'adresse indiquÇe dÇcalÇ d'un pixel	*
*	en bas Ö droite					*
*	d1 = numÇro ASCII du caractäre				*
*	d0 = couleur					*
*	a0 = adresse d'affichage				*
*	Vitesse moyenne : 7700 caractäres/seconde			*
*============================================================================*
affcar8x6_ombr:

	movem.l	d0-d5/a0-a1,-(sp)
	move.w	linewidth(pc),d3
	add.w	d3,a0
	lea	fonte8x6_ombr(pc),a1
	bra	affcar1_bra



*============================================================================*
*	Affiche un caractäre 8x6 Ö l'adresse indiquÇe dÇcalÇ d'un pixel	*
*	vers le bas et de 5 pixels sur la droite			*
*	d1 = numÇro ASCII du caractäre				*
*	d0 = couleur					*
*	a0 = adresse d'affichage				*
*============================================================================*
affcar8x6_ombr_dec:

	movem.l	d0-d7/a0-a2,-(sp)
	move.w	linewidth(pc),d3
	add.w	d3,a0
	lea	fonte8x6_ombr(pc),a1
	bra	affcar2_bra



*============================================================================*
*	Affiche un caractäre 8x6 Ö l'adresse indiquÇe sans transparence	*
*	DÇcalage d'1 pixel Ö droite				*
*	d0 = couleur					*
*	d1 = numÇro ASCII					*
*	a0 = adresse d'affichage				*
*============================================================================*
affcar8x6nt_ombr:
	movem.l	d0-d2/a0-a2,-(sp)
	move.w	linewidth(pc),d2
	lea	fonte8x6_ombr(pc),a1
	and.w	#$FF,d1
	add.w	d1,d1
	add.w	d1,a1
	add.w	d1,d1
	add.w	d1,a1		; a1 pointe sur le caractäre
	move.w	#3,d1
affcar5_loop:
	move.l	a0,a2
	lsr.w	#1,d0
	bcc.s	.s1
	REPT	5
	move.b	(a1)+,(a2)
	add.w	d2,a2
	ENDR
	move.b	(a1),(a2)
	subq.l	#5,a1
	bra.s	.s2
.s1:	REPT	5
	clr.b	(a2)
	add.w	d2,a2
	ENDR
	clr.b	(a2)
.s2:	addq.l	#2,a0
	dbra	d1,affcar5_loop
	movem.l	(sp)+,d0-d2/a0-a2
	rts



*============================================================================*
*	Affiche un caractäre 8x6 Ö l'adresse indiquÇe en ne modifiant	*
*	que les plans dÇsignÇs par la couleur			*
*	DÇcalage d'1 pixel Ö droite				*
*	d0 = couleur					*
*	d1 = numÇro ASCII					*
*	a0 = adresse d'affichage				*
*============================================================================*
affcar8x6_plan:
	movem.l	d0-d2/a0-a2,-(sp)
	move.w	linewidth(pc),d2
	lea	fonte8x6_ombr(pc),a1
	and.w	#$FF,d1
	add.w	d1,d1
	add.w	d1,a1
	add.w	d1,d1
	add.w	d1,a1		; a1 pointe sur le caractäre
	move.w	#3,d1
affcar6_loop:
	lsr.w	#1,d0
	bcc.s	.s1
	move.l	a0,a2
	REPT	5
	move.b	(a1)+,(a2)
	add.w	d2,a2
	ENDR
	move.b	(a1),(a2)
	subq.l	#5,a1
.s1:	addq.l	#2,a0
	dbra	d1,affcar6_loop
	movem.l	(sp)+,d0-d2/a0-a2
	rts



*============================================================================*
*	Fabrique la fonte ombrÇe Ö partir de la fonte dÇjÖ chargÇe	*
*============================================================================*
fabrique_fonte_ombr:

	movem.l	d1-d2/a1-a2,-(sp)
	lea	fonte8x6(pc),a2
	lea	fonte8x6_ombr(pc),a1
	move.w	#255,d2
fabrfnt_loop:
	REPT	6
	move.b	(a2)+,d1
	lsr.b	d1
	move.b	d1,(a1)+
	ENDR
	dbra	d2,fabrfnt_loop
	movem.l	(sp)+,d1-d2/a1-a2
	rts





*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*

	DATA

;--- Ne pas changer l'ordre de ces lignes !!! (cause GfA) --------------------
adrecr:		Ds.l	1	; Adresse de l'Çcran
linewidth:		Ds.w	1	; Largeur d'une ligne en octets
flag_sample_rec:	Ds.w	1	; Flag d'ordre pour l'enregistrement
				; 0 = Ordre d'arràter la digit
				; 1 = Ordre de commencer la digit
flag_sample_rec2:	Ds.w	1	; Flag d'indication
				; 1 = On a dÇclenchÇ quelque chose
				; 2 = Phase trigger active
				; 3 = Phase sampling active
				; 4 = Sampling fini
adr_record_inf:	Dc.l	record_inf	; Adresse des infos pour la digit d'un son
adr_sam_rec_buffer:	Dc.l	sample_rec_buffer
rec_sam_num_buf:	Dc.l	0	; NumÇro*4096 du buffer sur lequel on enregistre (0 ou 4096)
fxdly_deb1:	Ds.w	1	; Sample de dÇbut du buffer 1 (effet de Delay)
fxdly_deb2:	Ds.w	1	; Sample de dÇbut du buffer 2
songrecord_paramadr:	Ds.l	1	; Adresse des info sur l'enregistrement d'un mod (-> GTPLAY.PGT)
songrec_adr_buffer:	Ds.l	1	; Adresse du buffer final pour l'enregistrement d'un module
songrec_lon_buffer:	Ds.l	1	; Sa longueur en mÇmoire (en octets)
songrec_pos_buffer:	Ds.l	1	; Position de l'enregistrement dans le buffer
songrec_lon_sample:	Ds.l	1	; La longueur maximum de sample Ö enregistrer (octets)
songrec_pos_sample:	Ds.l	1	; Position de l'enregistrement dans le sample
songrec_type:	Ds.w	1	; Type: 0 = normal, 1 = bouclage
songrec_flag:	Ds.w	1	; 0 = arràte, 1 = continue Ö recopier
songrec_bits:	Ds.w	1	; 1 = 8 bits, 2 = 16 bits
songrec_stereo:	Ds.w	1	; 1 = mono, 2 = stereo
; sngrecparamadr+32
progression_pos:	Ds.l	1	; Nombre courant d'opÇrations effectuÇes
progression_len:	Ds.l	1	; Nombre total d'opÇrations Ö effectuer

;--- Maintenant c'est bon ----------------------------------------------------
numericpad_scancodes:	Dc.b	99,100,101,102
		Dc.b	103,104,105,74
		Dc.b	106,107,108,78
		Dc.b	109,110,111,114

fonte8x6:		incbin	'FONTE1.FNT'

nom_notes:	dc.b	'--- C#= D-= D#= E-= F-= F#= G-= G#= A-= A#= B-= '
	dc.b	'C-- C#- D-- D#- E-- F-- F#- G-- G#- A-- A#- B-- '
	dc.b	'C-0 C#0 D-0 D#0 E-0 F-0 F#0 G-0 G#0 A-0 A#0 B-0 '
	dc.b	'C-1 C#1 D-1 D#1 E-1 F-1 F#1 G-1 G#1 A-1 A#1 B-1 '
	dc.b	'C-2 C#2 D-2 D#2 E-2 F-2 F#2 G-2 G#2 A-2 A#2 B-2 '
	dc.b	'C-3 C#3 D-3 D#3 E-3 F-3 F#3 G-3 G#3 A-3 A#3 B-3 '
	dc.b	'C-4 C#4 D-4 D#4 E-4 F-4 F#4 G-4 G#4 A-4 A#4 B-4 '
	dc.b	'C-5 C#5 D-5 D#5 E-5 F-5 F#5 G-5 G#5 A-5 A#5 B-5 '
	dc.b	'C-6 C#6 D-6 D#6 E-6 F-6 F#6 G-6 G#6 A-6 A#6 B-6 '
	dc.b	'C-7 C#7 D-7 D#7 E-7 F-7 F#7 G-7 G#7 A-7 A#7 B-7 '
	dc.b	'C-8 C#8 D-8 D#8 E-8 F-8 F#8 G-8 '

curs_x_table:			; Colonne 4 (+16), plan 3 (+6)
	dc.w	22		; Offset Note
	dc.w	31,38		; Offset Instrument
	dc.w	39,46,47,54	; Offset Effet
	dc.w	55,62		; Offset Volume

nt_pernote:
	Dc.w	$358,$328,$2FA,$2D0,$2A6,$280
	Dc.w	$25C,$23A,$21A,$1FC,$1E0,$1C5
	Dc.w	$1AC,$194,$17D,$168,$153,$140
	Dc.w	$12E,$11D,$10D,$0FE,$0F0,$0E2
	Dc.w	$0D6,$0CA,$0BE,$0B4,$0AA,$0A0
	Dc.w	$097,$08F,$087,$07F,$078,$071

table_byte2char:			; Conversion byte -> ASCII hexa
	dc.b	'000102030405060708090A0B0C0D0E0F'
	dc.b	'101112131415161718191A1B1C1D1E1F'
	dc.b	'202122232425262728292A2B2C2D2E2F'
	dc.b	'303132333435363738393A3B3C3D3E3F'
	dc.b	'404142434445464748494A4B4C4D4E4F'
	dc.b	'505152535455565758595A5B5C5D5E5F'
	dc.b	'606162636465666768696A6B6C6D6E6F'
	dc.b	'707172737475767778797A7B7C7D7E7F'
	dc.b	'808182838485868788898A8B8C8D8E8F'
	dc.b	'909192939495969798999A9B9C9D9E9F'
	dc.b	'A0A1A2A3A4A5A6A7A8A9AAABACADAEAF'
	dc.b	'B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF'
	dc.b	'C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF'
	dc.b	'D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF'
	dc.b	'E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF'
	dc.b	'F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF'
table_byte2char2:			; Conversion byte -> ASCII hexa, remplace 0 par ' '
	dc.b	'   1 2 3 4 5 6 7 8 9 A B C D E F'
	dc.b	'101112131415161718191A1B1C1D1E1F'
	dc.b	'202122232425262728292A2B2C2D2E2F'
	dc.b	'303132333435363738393A3B3C3D3E3F'
	dc.b	'404142434445464748494A4B4C4D4E4F'
	dc.b	'505152535455565758595A5B5C5D5E5F'
	dc.b	'606162636465666768696A6B6C6D6E6F'
	dc.b	'707172737475767778797A7B7C7D7E7F'
	dc.b	'808182838485868788898A8B8C8D8E8F'
	dc.b	'909192939495969798999A9B9C9D9E9F'
	dc.b	'A0A1A2A3A4A5A6A7A8A9AAABACADAEAF'
	dc.b	'B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF'
	dc.b	'C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF'
	dc.b	'D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF'
	dc.b	'E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF'
	dc.b	'F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF'
table_byte2char3:			; Conversion byte -> ASCII hexa, remplace 0 par un point
	dc.b	9,'0',9,'1',9,'2',9,'3',9,'4',9,'5',9,'6',9,'7'
	dc.b	9,'8',9,'9',9,'A',9,'B',9,'C',9,'D',9,'E',9,'F'
	dc.b	'101112131415161718191A1B1C1D1E1F'
	dc.b	'202122232425262728292A2B2C2D2E2F'
	dc.b	'303132333435363738393A3B3C3D3E3F'
	dc.b	'404142434445464748494A4B4C4D4E4F'
	dc.b	'505152535455565758595A5B5C5D5E5F'
	dc.b	'606162636465666768696A6B6C6D6E6F'
	dc.b	'707172737475767778797A7B7C7D7E7F'
	dc.b	'808182838485868788898A8B8C8D8E8F'
	dc.b	'909192939495969798999A9B9C9D9E9F'
	dc.b	'A0A1A2A3A4A5A6A7A8A9AAABACADAEAF'
	dc.b	'B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF'
	dc.b	'C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF'
	dc.b	'D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF'
	dc.b	'E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF'
	dc.b	'F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF'



*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*

	BSS

old_it_mfp15:	Ds.l	1	; Adresse de l'ancienne interruption MFP 15
old_replay_frequency:	Ds.w	1	; Ancienne frÇquence de replay (contenu du MOT $ffff8934)
old_matrix_cnx:	Ds.l	1	; Ancienne connection de la matrice
keycode_result:	Ds.l	1	; \
		Ds.w	1	;  > *** Ne pas dissocier
		Ds.w	1	; /
fft_poslsl:	Ds.l	1	; Position.l fractionnaire *4096/2„
fft_incmsl:	Ds.w	1	; IncrÇment.w poids fort *4096/2„
fft_inclsl:	Ds.l	1	; IncrÇment.l fractionnaire *4096/2„
fft_remsl:		Ds.l	1	; Energie, partie rÇelle
fft_relsl:		Ds.l	1	; Energie, partie rÇelle fractionnaire
fft_immsl:		Ds.l	1	; Energie, partie imaginaire
fft_imlsl:		Ds.l	1	; Energie, partie imaginaire fractionnaire
progression_savedreg:	Ds.l	8+7	; Espace de sauvegarde de d0-d7/a0-a6
progression_res_adr:	Ds.l	1	; Adresse de reprise
progression_step:	Ds.l	1	; Nombre d'opÇration entre chaque indication de progression
progression_cpt:	Ds.l	1	; Compteur d'opÇrations (decrÇmentÇ). 0 = arràt et affichage de progression
oldcolcurs:	ds.w	1	; Ancienne colonne d'affichage du curseur
oldposcurs:	ds.w	1	; Ancienne position d'affichage du curseur dans la colonne
patpreset5:	ds.w	32	; MÇmorisation du prÇset d'aff de pat, * 5
cv_s3m2gtk_slides:	ds.w	32	; MÇmorisation de l'Çtat des slides de vol pour chaque voie
cv_s3m2gtk_porta:	ds.b	32	; MÇmorisation de l'Çtat des portamentos chaque voie
fonte8x6_ombr:	ds.b	6*256
; Espace pour les decrunchers (le màme pour tous)
ice2_21:		; ds.w	60	; free space (can be put in BSS)
speedpacker_adr:	; ds.l	1	; MÇmorise l'adresse de dÇcompactage
atm35_eb:		ds.w	142	; Espace pour Atomik Packer 3.5
record_inf:	ds.b	rec_next	; Infos pour la digit d'un son
		EVEN
; Buffer pour la digitalisation d'un son
sample_rec_buffer:	ds.b	1024*2*2
sample_rec_buffer2:	ds.b	1024*2*2



*˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜˜*
