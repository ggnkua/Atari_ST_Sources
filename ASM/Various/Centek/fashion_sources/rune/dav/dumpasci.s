*-------------------------------------------------------------------------*

		****
		DATA
		****
		
dump_file		dc.b	"L:\DIRDUMP.TXT",0
		even	
		
		****
		BSS
		****

_asd_buffer	ds.b	256
_asd_bufptr	ds.l	1

		****
		TEXT
		****
		
		; sortie dump de la totalit‚ des fichiers
		; d'un arbre de file objets dans un fichier ascii
		
		rsset	8
_asd_fo		rs.l	1	; pointeur sur l'arbre de fichiers
		
		rsset	-2
_asd_handle	rs.w	1
		
		****
ascii_dump:
		link	a6,#-2
		movem.l	d1-d7/a0-a5,-(sp)
		
		
		clr.w	-(sp)
		pea	dump_file
		gem	fcreate
		
		move.w	d0,_asd_handle(a6)
		
		****
		
		lea	_asd_buffer,a2
		move.l	a2,_asd_bufptr
		
		move.l	_asd_fo(a6),a3
		
		****
.houba
		move.l	_asd_bufptr,-(sp)
		
		move.l	_asd_bufptr,a2
		lea	fo_name(a3),a4
.cop			
		move.b	(a4)+,(a2)+
		bne.s	.cop
		
		move.b	#"\",-1(a2)
		move.l	a2,_asd_bufptr
		
		****
		
		move.l	fo_child(a3),d0
		beq.s	.dump
		
		move.l	d0,a3
		bra.s	.houba
		
		****
.dump		
		; dump du chemin
		
		move.l	_asd_bufptr,a4
		
		cmp.w	#$10,fo_attr(a3)
		bne.s	.normal
.dir
		move.l	#"(emp",(a4)+
		move.l	#"ty d",(a4)+
		move.l	#"ir) ",(a4)+
.normal		
		subq	#1,a4
		move.b	#$0d,(a4)+
		move.b	#$0a,(a4)+
		
		lea	_asd_buffer,a2
		sub.l	a2,a4
		
		pea	_asd_buffer
		move.l	a4,-(sp)
		move.w	_asd_handle(a6),-(sp)
		gem	fwrite
		
		****
.hopla		
		move.l	(sp)+,_asd_bufptr
		
		move.l	fo_next(a3),d0
		beq.s	.fin_niveau
		
		move.l	d0,a3
		bra	.houba
		
		****
.fin_niveau
		move.l	fo_parent(a3),d0
		beq.s	.fin_tout
		
		move.l	d0,a3
		bra.s	.hopla
		
		****
.fin_tout		
		move.w	_asd_handle(a6),-(sp)
		gem	fclose
		
		****
.eok
		movem.l	(sp)+,d1-d7/a0-a5
		unlk	a6
		rtd	#4
		
		********

*-------------------------------------------------------------------------*
