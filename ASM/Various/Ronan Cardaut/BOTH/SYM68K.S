	include	d:\centinel\both\gem.equ

; ceci est un programme pour r‚cup‚rer les infos de d‚bug ds un 
; programme au format TOS
;
; en premier les symbols:
; voici une entr‚e de la table des symbols
; NOM		TAILLE
; name		8
; type		W
; value		L
;
; type nous donne plein d'infos sur le symbol...


; 0100		BSS		le symbol est en BSS
; 0200		TEXT		...
; 0400		DATA		...
; 0800		EXTERNAL	le symbol est d‚fini par XREF
; 1000		EQUR		le symbol est d‚fini en EQUR ds le source
; 2000		GLOBAL		le symbol est global
; 4000		EQU		le symbol est d‚fini par un EQU
; 8000		DEFINED		le symbol existe (?!?)

; les fichiers
; 0280		text file	c'est le source
; 02c0		text file ARCHIVE 	la alors... a koa ca sert ??

; divers
; 0048		L_NAME		le symbol est un nom long
; 				14 octets completent imm‚diatement apres notre entr‚e
;
; 0000		UNDEFINED	cette valeur est interdite, mais GAS (?!? Gnu ASsembleur ?!?)
;				l'utilise... On dirait que c'est ca qui fait dire … ADEBUG
				unknown symbol type ...

;j'ajoute que l'on peut avoir plusieurs de ces flags dans un meme type...
; exemple, un symbol type vaut A248... ca fait
; 8000		DEFINED
;+2000		GLOBAL
;+0200		TEXT
;+0048		longnom 
; soit un symbol global en section text avec un nom long...

				
	lea	PRG,a0
	lea	SYM_BUF,a1
	bsr	LOAD_SYM
	illegal	
		
	
LOAD_SYM
	*------------*
	* r‚cupere le ptr sur	
	*------------*
	move.l	a0,a2
	add.w	#$1c,a2		;header
	add.l	2(a0),a2	;TEXT
	add.l	6(a0),a2	;DATA
	move.l	a2,a6
	add.l	14(a0),a6	;fin des SYM
SYMBOL
	move	8(a2),d0	;SYM type
	move.l	a2,a3
	move	#8-1,d6
.NAME	move.b	(a3)+,(a1)+
	dbeq	d6,.NAME	;copie le nom du symbol
	cmp.b	#$48,d0
	beq	LONG_NAME
	
	
LONG_NAME
	*----------------*
	* on a 14 octets de plus
	* invent‚ par HISOFT !
	*----------------*
	lea	14(a2),a3
	move	#14-1,d6
.NAME	move.b	(a3)+,(a1)+
	dbeq	d6,.NAME
	add.w	#14+14,a2
	cmp.l	a6,a2
	blt.s	SYMBOL
	bra	FIN
	
	
			
FIN	
	
				
	

PRG	incbin	d:\CODE\GCC\TEST.PRG
	