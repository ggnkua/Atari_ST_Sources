;=========================================================================;
;                            DSP SoundTracking                            ;
;                    (C)oderight Nullos / DNT-Crew 1994                   ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Ce source contient une partie des routines du soundtracker DSP.          ;
;A savoir:                                                                ;
;         o Driver d'interruptions                                        ;
;         o Initialisation du DSP                                         ;
;                                                                         ;
;Comme d'habitude, un 'tab settings' = 11 est le bienvenu...              ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Le cas d'un programme en tache de fond utilisant une routine de reception;
;ou transmission Host, est correctement trait‚, s'il utilise les registres;
;(r4,n4,m4) pour son driver d'interruption.                               ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Ceci est un programme freeware, MAIS ce n'est pas du domaine public.     ;
;Si vous utilisez tout ou partie de ce source ou d'un autre source formant;
;ma routine de soundtracker au DSP, dans un but non-lucratif, n'oubliez   ;
;pas de me le signaler.                                                   ;
;Si par contre il s'agit d'une utilisation dans le cadre d'un programme   ;
;commercial, il faudra demander mon autorisation, certes par simple       ;
;formalit‚ mais quand mˆme...                                             ;
;======================================================= Version 2.7 =====;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; D‚finitions standards, hors listing de d‚buggage ;;;;;;;;;;;;;;;;;;
	include	'include\ioequ.asm'
	include	'include\intequ.asm'
	include	'include\readwrit.asm'
	himem	x:$3fff,y:$3fff,p:$7fff
	OPT	W

DspMixer	ident	2,7		;Mixage Soundtracker au DSP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; D‚finitions pour la taille des buffers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
freq	equ	49170		;Fr‚quence de replay d‚sir‚e
hz	equ	50		;Fr‚quence du gestionnaire


maxspl	equ	(672*50/hz+8)	;672+s‚curit‚: avanc‚e maxi en DMA.
maxech	equ	freq/hz		;Nb maxi d'‚chantillons rejou‚s.

	IF	(maxspl>$800)||(maxech>$400)
	fail	'Buffers SSI trop grands!!'
	ENDIF

BASEAD	equ	$2000		;Position P:..=Y:.. de la routine.

MixCodSize	equ	$220		;Taille approximatives
MixVarSize	equ	$100		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Drivers d'interruption ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org	p:$0		;
	jmp	<P_begin		;

	org	p:I_SSIRD		;
	movep	x:<<M_RX,x:(r3)+	;Reception SSI du DMA
	nop			;
	movep	x:<<M_SR,x:(r3)+	;Reception en overrun
	movep	x:<<M_RX,x:(r3)+

	movep	y:(r7)+,x:<<M_TX	;Vecteur SSI-transmit, mode short
	nop			;
	movep	x:<<M_SR,y:(r7)+	;Idem, en underrun
	movep	y:(r7)+,x:<<M_TX	;

	org	p:I_HSTUC0		;
	jsr	>Interrupt_Mixer	;Routine globale en interruption.
	jsr	>P_loader		;Loader de programmes.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	comment	%
INTERDITS AU PROGRAMME HOTE:.... o (r7, m7) et (r3, m3)
			  (n7 et n3 sont libres)
			o (r3, m3) ne sont pas interdits si le mode
			  de transfert DMA des samples n'est pas
			  actif.

JAMAIS UTILISES PAR LE MIXEUR:.. o (r4, m4, n4) sont totalement inutilis‚s
			  par le mixeur.
			  Ils peuvent donc ‚tre utilis‚s pendant une
			  interruption du programme h“te.
		%
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Pr‚paration des hostilit‚s & Corps du mixeur ;;;;;;;;;;;;;;;;;;;;;;
	org	p:$40
P_begin	movep	#1,x:<<M_PBC	;Host enable
	movep	#B_HCIE,x:<<M_HCR	;Host Command
	movep	#B_SSL|B_HPL1,x:<<M_IPR ;SSI en IPL3, Host en IPL2
	movep	#$4100,x:<<M_CRA	;SSI en 2 mots/frame, 16 bits
	movep	#$0800,x:<<M_CRB	;SSI off
	movep	#$01f8,x:<<M_PCC	;Port C en SSI
	movep	#$0008,x:<<M_PCDDR	;Idem
	andi	#%11110000,mr	;Vroom, autorise tout le monde.
	jmp	<*		;Hop, fini...

