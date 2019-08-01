;----------------------------------------------------------------------------
;File name:	RA_REL.I			Revision date:	1998.08.15
;Created by:	Ulf Ronald Andersson		Creation date:	1994.08.23
;----------------------------------------------------------------------------
	IFND	RA_REL_defined	;ensures single inclusion
RA_REL_defined	SET	1
;----------------------------------------------------------------------------
;Library Macros:
;
;rel_define	group		;defines 'group' for relocation info
;rel_ref	group,loc	;makes 'loc' member of relocation 'group'
;rel_generate	group,bas1,siz1	;generates 'group'_rel_table (N*'siz1' bytes)
;relocate	group,admd,bas2,offs,siz2,indflag
;
;'group'	name of relocation group (prefix/infix of internal labels)
;'admd'		suffixed to table label in 'pea' operation in 'relocate'
;'bas1'		base for code locations before relocation
;'bas2'		base for code locations after relocation
;'offs'		relocation offset to be added to each code location
;'siz1'		size of each entry in relocation table (must be 2 or 4)
;'siz2'		size of relocation offset
;'indflag'	'_ind' to use 'move.l' for bas2 & offs, absent => 'pea'
;----------------------------------------------------------------------------
rel_define	MACRO	group
		IFNE	NARG=1
		IFND	zz_rel_\1_cnt
zz_rel_\1_cnt	SET	0
		ELSEIF
		FAIL	"rel"-group \1 is already defined
		ENDC
		ELSEIF
		FAIL	"rel_define \1" needs 1 argument only
		ENDC
		ENDM	;rel_define
;-------------------------------------
rel_ref		MACRO	group,location
		IFNE	NARG=2
zz_rel_cnt	SET	zz_rel_\1_cnt
zz_rel_\1_cnt	SET	zz_rel_\1_cnt+1
zz_\1_\<zz_rel_cnt>:	=	(\2)
		ELSEIF
		FAIL	"rel_ref" needs 2 arguments
		ENDC
		ENDM	;rel_ref
;-------------------------------------
rel_generate	MACRO	group,loc_base,gen_size
		IFNE	NARG=3
		IFD	zz_rel_\1_cnt
		IFND	zz_\1_generated
		IFNE	(\3=2)|(\3=4)
zz_\1_gen_size	=	\3
\1_rel_table:
		dc.l	zz_rel_\1_cnt
zz_rel_base:	SET	\2
zz_rel_cnt	SET	0
		IFNE	(\3=2)
		repeat	zz_rel_\1_cnt,<zz_rel_gen_code \1,W>
		ELSEIF
		repeat	zz_rel_\1_cnt,<zz_rel_gen_code \1,L>
		ENDC
zz_\1_generated	SET	1
		ELSEIF
		FAIL	"rel_generate \1" needs size 2 or 4
		ENDC
		ELSEIF
		FAIL	"rel"-group \1 is already generated
		ENDC
		ELSEIF
		FAIL	"rel"-group \1 is not defined for generation
		ENDC
		ELSEIF
		FAIL	"rel_generate \1" needs 2 arguments
		ENDC
		ENDM	;rel_generate
;-------------------------------------
zz_rel_gen_code	MACRO	group,size
		dc.\2	zz_\1_\<zz_rel_cnt>-zz_rel_base
zz_rel_cnt	SET	zz_rel_cnt+1
		ENDM	;rel_gen_code
;-------------------------------------
relocate	MACRO	group,grp_mod,loc_base,ref_offs,ref_size,ind_flag
		IFNE	(NARG=5)|(NARG=6)
		IFD	zz_\1_generated
		IFNE	(\5=2)|(\5=4)
		IFC	'','\6'
		pea	\4		;push ref_offs
		pea	\3		;push loc_base
		ELSEIF
		IFC	'_ind','\6'
		move.l	\4,-(sp)	;push ref_offs
		move.l	\3,-(sp)	;push loc_base
		ELSEIF
		FAIL	arg 6 of "relocate \1" is not "_ind"/absent
		ENDC
		ENDC
		pea	\1_rel_table\2	;push group table base
zz_rel_gen_size	SET	zz_\1_gen_size
zz_rel_ref_size	SET	\5
		IFD	reloc_def_\<zz_rel_gen_size>_\<zz_rel_ref_size>
		bsr	reloc_sub_\<zz_rel_gen_size>_\<zz_rel_ref_size>
		lea	12(sp),sp
		ELSEIF
		bsr.s	reloc_sub_\<zz_rel_gen_size>_\<zz_rel_ref_size>
		lea	12(sp),sp
		bra.s	zz_rel_past_sub_\@
		zz_make_rel_sub
zz_rel_past_sub_\@:
		ENDC
		ELSEIF
		FAIL	"relocate \1" needs arg 5 as ref_size 2 or 4
		ENDC
		ELSEIF
		FAIL	"rel"-group \1 is ungenerated for relocation
		ENDC
		ELSEIF
		FAIL	"relocate \1" needs 5 or 6 arguments
		ENDC
		ENDM	;relocate
;-------------------------------------
zz_make_rel_sub	MACRO
reloc_def_\<zz_rel_gen_size>_\<zz_rel_ref_size>	SET	1
reloc_sub_\<zz_rel_gen_size>_\<zz_rel_ref_size>:
		link	a6,#0
		movem.l	d0-d2/a0-a1,-(sp)
		move.l	8(a6),a0	;a0 -> group relocation table
		move.l	12(a6),a1	;a1 = loc_base
		move.l	16(a6),d1	;d1 = ref_offs
		move.l	(a0)+,d2	;d2 = relocations to fix
		beq.s	.done_\@
.loop_\@:
		IFNE	zz_rel_gen_size=2
		move	(a0)+,d0
		IFNE	zz_rel_ref_size=2	;gen_size=2, ref_size=2
		add.w	d1,(a1,d0.w)
		ELSEIF				;gen_size=2, ref_size=4
		add.l	d1,(a1,d0.w)
		ENDC
		ELSEIF		;gen_size=4
		move.l	(a0)+,d0
		IFNE	zz_rel_ref_size=2	;gen_size=4, ref_size=2
		add.w	d1,(a1,d0.l)
		ELSEIF				;gen_size=4, ref_size=4
		add.l	d1,(a1,d0.l)
		ENDC
		ENDC
		subq.l	#1,d2
		bne.s	.loop_\@
.done_\@:
		movem.l	(sp)+,d0-d2/a0-a1
		unlk	a6
		rts
		ENDM
;----------------------------------------------------------------------------
		ENDC	;ensures single pass 1 inclusion
;----------------------------------------------------------------------------
;End of file:	RA_REL.I
;----------------------------------------------------------------------------
