		lea resource(pc),a0
		
; Set a resource file in memory
; a0-> resource file.

rsh_vrsn	equ 0	; resource version no.
rsh_object	equ 2	; offset to object[] 
rsh_tedinfo	equ 4	; offset to tedinfo[]
rsh_iconblk	equ 6	; offset to iconblk[]
rsh_bitblk	equ 8	; offset to bitblk[] 
rsh_frstr	equ 10	; offset to free string index 
rsh_string	equ 12	; offset to first string 
rsh_imdata	equ 14	; offset to image data 
rsh_frimg	equ 16	; offset to free image index 
rsh_trindex	equ 18	; offset to object tree index
rsh_nobs	equ 20	; number of objects 
rsh_ntree	equ 22	; number of trees 
rsh_nted	equ 24	; number of tedinfos 
rsh_nib		equ 26	; number of icon blocks 
rsh_nbb		equ 28	; number of bitblk blocks
rsh_nstring	equ 30  ; number of free strings 
rsh_nimages	equ 32	; number of free images 
rsh_rssize	equ 34 	; total bytes in resource 

fix_resource:	movem.l d0-d7/a1-a6,-(sp)
		move.l a0,d0
		moveq  #0,d1
fix_object:	move.w rsh_object(a0),d1
		lea (a0,d1.l),a1	; a1-> object[]
		move.w rsh_nobs(a0),d7	; number of objects 
		subq #1,d7
		bmi.s fix_tedinfo 
fix_object_lp:	move.w 6(a1),d2		; object type
		cmp.w #20,d2		; G_BOX?
		beq.s no_fix_obj
		cmp.w #25,d2		; G_IBOX?
		beq.s no_fix_obj
		cmp.w #27,d2		; G_BOXCHAR
		beq.s no_fix_obj
		add.l d0,12(a1)		; -> object specific structure
no_fix_obj:	lea 24(a1),a1
		dbf d7,fix_object_lp
fix_tedinfo:	move.w rsh_tedinfo(a0),d1
		lea (a0,d1.l),a1	; a1-> tedinfo[]
		move.w rsh_nted(a0),d7	; number of tedinfos 
		subq #1,d7
		bmi.s fix_iconblk 
ted_lp:		add.l d0,(a1)		; ->te_ptext
		add.l d0,4(a1)		; ->te_ptmplt
		add.l d0,8(a1)		; ->te_pvalid
		lea 28(a1),a1
		dbf d7,ted_lp
fix_iconblk: 	move.w rsh_iconblk(a0),d1
		lea (a0,d1.l),a1	; a1-> iconblk[]
		move.w rsh_nib(a0),d7	; number of iconblks 
		subq #1,d7
		bmi.s fix_bitblk 
icon_lp:	add.l d0,(a1)		; ->ib_pmask
		add.l d0,4(a1)		; ->ib_pdata
		add.l d0,8(a1)		; ->ib_ptext
		lea 34(a1),a1
		dbf d7,icon_lp
fix_bitblk:	move.w rsh_bitblk(a0),d1
		lea (a0,d1.l),a1	; a1-> iconblk[]
		move.w rsh_nbb(a0),d7	; number of iconblks 
		subq #1,d7
		bmi.s fix_tree
fix_bitblk_lp:	add.l d0,(a1)		; ->bi_pdata
		lea 14(a1),a1
		dbf d7,fix_bitblk_lp
fix_tree:	move.w rsh_trindex(a0),d1
		lea (a0,d1.l),a1
		move.w rsh_ntree(a0),d7
		move.l a1,a0		; return a0	
		subq #1,d7 
		bmi.s fixed
fix_tree_lp:	add.l d0,(a1)+
		dbf d7,fix_tree_lp
fixed:
		move.l (a0),a0
		movem.l (sp)+,d0-d7/a1-a6
		rts

resource:	incbin g:\c\proplay\proplay.rsc