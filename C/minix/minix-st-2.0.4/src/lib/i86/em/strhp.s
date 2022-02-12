.define	.strhp
.text
.extern .reghp, .limhp, .fat
EHEAP = 17

.strhp:
	pop	bx
	pop	ax
	mov	.reghp,ax
	cmp	ax,.limhp
	jb	1f
	add	ax,#01000
	and	ax,#0177000
	mov	.limhp,ax
	cmp	ax,sp
	jae	2f
1:
	jmp	(bx)
2:
	mov	ax,#EHEAP
	jmp	.fat
