;
; PedroM - Operating System for Ti-89/Ti-92+/V200.
; Copyright (C) 2005-2009 Patrick Pelissier
;
; This program is free software ; you can redistribute it and/or modify it under the
; terms of the GNU General Public License as published by the Free Software Foundation;
; either version 2 of the License, or (at your option) any later version. 
; 
; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
; See the GNU General Public License for more details. 
; 
; You should have received a copy of the GNU General Public License along with this program;
; if not, write to the 
; Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 


; Memory move / copy
; String functions

;void *memmove (void *dest, const void *src, unsigned long len); 
memmove:
	move.l	4(a7),a0	; Destw
	move.l	8(a7),a1	; Src
	move.l	12(a7),d0	; Len
	beq.s	memend
memove_reg:
	cmp.l	a0,a1		
	bhi.s	memcpy_reg
	add.l	d0,a0		; src <= dest
	add.l	d0,a1
.loop2		move.b	-(a1),-(a0)
		subq.l	#1,d0
		bne.s	.loop2
memend	move.l	4(a7),a0
	rts
	
;void *memcpy (void *dest, const void *src, unsigned long len); 
;Speed of a copy of 3840 bytes:
;	Naive way: 53814 demi-cycles / New one: 11374 (AMS is 10703).
;Not fully optimised but clearly enought for most applications.
_memcpy:
memcpy:
	move.l	4(a7),a0	; Dest
	move.l	8(a7),a1	; Src
	move.l	12(a7),d0	; Len
	beq.s	memend
memcpy_reg:	
	moveq	#1,d2
	; Check for alignement of both src and dest.
	move.l	a0,d1		
	and.w	d2,d1
	beq.s	.DestAligned
	move.l	a1,d1
	and.w	d2,d1
	beq.s	.SlowCopy	; Dest is unaligned but src it is: Slow Copy.
	move.b	(a1)+,(a0)+	; Both are unaligned: Copy one byte.
	subq.l	#1,d0
	beq.s	.end
	bra.s	.FastCopy
.DestAligned
	move.l	a1,d1
	and.w	d2,d1
	bne.s	.SlowCopy	; Dest is aligned but src it is not: Slow Copy.
	; Now both src and dest are EVEN aligned.
.FastCopy:
		move.l	d0,d1
		lsr.l	#4,d1
		beq.s	.SemiFastLoopStart
		subq.w	#1,d1		; MAX: 65536*16=1M
.FastLoop		move.l	(a1)+,(a0)+
			move.l	(a1)+,(a0)+
			move.l	(a1)+,(a0)+
			move.l	(a1)+,(a0)+
			dbf	d1,.FastLoop
		moveq	#15,d1
		and.l	d1,d0
		beq.s	.end
.SemiFastLoopStart:
		move.w	d0,d1	; d0 is [1.15]
		lsr.w	#2,d1	; d1 is [0..3]
		subq.w	#3,d1
		neg.w	d1
		add.w	d1,d1	; d1 = 2*(3-d0/4)
		jmp	.SemiFastLoop(Pc,d1.w)
.SemiFastLoop	move.l	(a1)+,(a0)+ ; Jump here if d1=3
		move.l	(a1)+,(a0)+ ; Jump here if d1=2
		move.l	(a1)+,(a0)+ ; Jump here if d1=1
		andi.w	#3,d0	    ; Jump here if d1=0
		beq.s	.end	    ; Note that a word and is enough
	; Slow copy of src and dest
.SlowCopy
.loop		move.b	(a1)+,(a0)+
		subq.l	#1,d0		; Should work with long
		bne.s	.loop
.end	move.l	4(a7),a0
	rts
	
;void *memset (void *buffer, short c, unsigned long num);
; Speed for 3840 bytes: 46137 demi-cycles for naive-method to 7547 for new one (AMS is 6854)
; Not fully optimised but clearly enought for most applications.
_memset:	
memset:
	move.l	4(a7),a0		; Read address to fill
	move.w	8(a7),d2		; Read pattern
	move.l	10(a7),d0		; Read size 
	beq.s	memset_end		; Check if at least one byte
memset_reg:
	; First aligned dest to fill to an EVEN address
	move.l	a0,d1			
	andi.w	#1,d1			
	beq.s	.aligned
		move.b	d2,(a0)+	; The address is unaligned: Copy one byte 
		subq.l	#1,d0		; Remove one byte to fill
		beq.s	memset_end	; If no more byte, end
.aligned:
memset_reg_align:
	; Now the buffer to fill is aligned. Create a long pattern to fill.
	move.b	d2,d1			;
	lsl.w	#8,d1			; d1.ub = PATTERN
	move.b	d2,d1			; di.w = PATTERN | PATTERN
	move.w	d1,d2			; d2.w = PATTERN | PATTERN
	swap	d2			; d2.uw = PATTERN | PATTERN
	move.w	d1,d2			; d2.l = PATTERN | PATTERN | PATTERN | PATTERN
	; Long Word fill: 16 bytes per long word.
	move.l	d0,d1
	lsr.l	#4,d1			; Size / 16
	beq.s	.SemiFastLoopStart	; Size < 16 : Go to Semi final fill.
		subq.w	#1,d1		; Max: 65536*16=1M (Enought for ti-68k)
.AlignedLoop		move.l	d2,(a0)+
			move.l	d2,(a0)+
			move.l	d2,(a0)+
			move.l	d2,(a0)+
			dbf	d1,.AlignedLoop
		moveq	#15,d1
		and.l	d1,d0		; Fix size.
		beq.s	memset_end
.SemiFastLoopStart:
		move.w	d0,d1	; d0 is [1.15]
		lsr.w	#2,d1	; d1 is [0..3]
		subq.w	#3,d1
		neg.w	d1
		add.w	d1,d1	; d1 = 2*(3-d0/4)
		jmp	.SemiFastLoop(Pc,d1.w)
.SemiFastLoop	move.l	d2,(a0)+ ; Jump here if d1=3
		move.l	d2,(a0)+ ; Jump here if d1=2
		move.l	d2,(a0)+ ; Jump here if d1=1
		andi.w	#3,d0	    ; Jump here if d1=0
		beq.s	memset_end	    ; Note that a word and is enough
.final	; Final copy: no more than 3 bytes.
	subq.w	#1,d0
.UnAlignedLoop	move.b	d2,(a0)+
		dbf	d0,.UnAlignedLoop
memset_end:
	move.l	4(a7),a0
	rts
	
;void *memchr (const void *str, short c, unsigned long len); 
memchr:
	move.l	4(a7),a0
	move.w	8(a7),d2
	move.l	10(a7),d0
memchr_reg:
	beq.s	.error
	subq.w	#1,d0
.loop		cmp.b	(a0)+,d2
		dbeq	d0,.loop
	subq.l	#1,a0
	beq.s	.found
.error:	suba.l	a0,a0
.found	rts

;short memcmp (const void *s1, const void *s2, unsigned long len); 
memcmp:
	move.l	4(a7),a0		; s1
	move.l	8(a7),a1		; s2
	move.l	12(a7),d0		; Len
	beq.s	memcmp_end
memcmp_reg:
	subq.l	#1,d0
.loop		cmpm.b	(a1)+,(a0)+
		dbne	d0,.loop
	move.b	-(a0),d0
	sub.b	-(a1),d0
	ext.w	d0
memcmp_end:
	rts

index:				; Old compilers provide the function index (s,c)
;char *strchr (const char *str, short c);
strchr:
	move.l	4(a7),a0
	bsr.s	strlen_reg
	move.l	4(a7),a0
	move.w	8(a7),d2
	addq.l	#1,d0
	bra.s	memchr_reg

;unsigned long strlen (const char *str);
; Side Effect:
;	Doesn't destroy a1/d1/d2
strlen:
	move.l	4(a7),a0
strlen_reg
	move.l	a0,d0
.loop		tst.b	(a0)+
		bne.s	.loop
	sub.l	a0,d0
	neg.l	d0
	subq.l	#1,d0
	rts

;char *strcat (char *dest, const char *src);
strcat:
	move.l	4(a7),a0	; Dest
	move.l	8(a7),a1	; Src
	move.l	a0,d0
.loop		tst.b	(a0)+
		bne.s	.loop
	subq.l	#1,a0
.loop2		move.b	(a1)+,(a0)+
		bne.s	.loop2
	move.l	d0,a0
	rts

;char *strcpy (char *dest, const char *src);
strcpy:
	move.l	4(a7),a0	; Dest
	move.l	8(a7),a1	; Src
strcpy_reg:
	move.l	a0,d0
.loop2		move.b	(a1)+,(a0)+
		bne.s	.loop2
	move.l	d0,a0
	rts

;short strcmp (const unsigned char *s1, const unsigned char *s2);
strcmp:
	move.l	4(a7),a0
	move.l	8(a7),a1
strcmp_reg:
	clr.w	d0
	clr.w	d1
	bra.s	.next
.comp:		cmp.b	(a0)+,d1
		beq.s	.next
			move.b	-(a0),d0
			sub.w	d1,d0
			rts
.next		move.b	(a1)+,d1
		bne.s	.comp
	move.b	(a0),d0	
	ext.w	d0
	rts
	
;short cmpstri (const unsigned char *s1, const unsigned char *s2);
cmpstri:
	move.l	4(a7),a0
	move.l	8(a7),a1
	bra.s	.next
.comp:		cmpi.b	#'A'-1,d0
		bls.s	.NoCvtD0
		cmpi.b	#'Z',d0
		bhi.s	.NoCvtD0
			addi.b	#'a'-'A',d0
.NoCvtD0	cmpi.b	#'A'-1,d1
		bls.s	.NoCvtD1
		cmpi.b	#'Z',d1
		bhi.s	.NoCvtD1
			addi.b	#'a'-'A',d1
.NoCvtD1	cmp.b	d0,d1
		beq.s	.next
			moveq	#1,d0
			rts
.next		move.b	(a0)+,d0
		move.b	(a1)+,d1
		bne.s	.comp
	ext.w	d0
	rts

;short strncmp (const unsigned char *s1, const unsigned char *s2, unsigned long maxlen);
strncmp:
	move.l	4(a7),a0
	move.l	8(a7),a1
	move.l	12(a7),d1
	clr.w	d0
	subq.l	#1,d1
	blt.s	.end
.loop		move.b	(a0)+,d0
		beq.s	.final
		cmp.b	(a1)+,d0
		dbne	d1,.loop
	subq.l	#1,a1
.final:
	move.b	-(a0),d0
	sub.b	(a1),d0
	ext.w	d0
.end	rts
	
;char *strncpy (char *dest, const char *src, unsigned long maxlen); 
strncpy:
	move.l	4(a7),a0			; Dest 
	move.l	8(a7),a1			; Src
	move.l	12(a7),d1			; Len
.CopyLoop:	move.b	(a1)+,(a0)+
		beq.s	.EndOfString
		subq.l	#1,d1
		bne.s	.CopyLoop
.End:	move.l	4(a7),a0	;  Return dest
	rts
	;; We must fill the last remaining chars with 0
.NullCopy:	clr.b	(a0)+
.EndOfString:	subq.l	#1,d1
		bne.s	.NullCopy
	bra.s	.End

;char *strncat (char *dest, const char *src, unsigned long maxlen); 
strncat:
	move.l	4(a7),a0	; Dest
	move.l	8(a7),a1	; Src
	move.l	12(a7),d1
.loop		tst.b	(a0)+
		bne.s	.loop
	subq.l	#1,a0
	subq.l	#1,d1
	blt.s	.done
.loop2		move.b	(a1)+,(a0)+
		dbeq	d1,.loop2
.done	clr.b	(a0)
	move.l	4(a7),a0
	rts

;unsigned long strcspn (const char *s1, const char *s2);
strcspn:
	move.l	4(sp),a1		; S1
	move.l	8(sp),d2		; S2
.S1_Loop:
	move.b	(a1),d1
	beq.s	.S1_End
		move.l	d2,a0
		move.b	(a0)+,d0
		beq.s	.S2_End
.S2_Loop:		cmp.b	d0,d1
			beq.s	.S1_End
			move.b	(a0)+,d0
			bne.s	.S2_Loop
.S2_End:	addq.l	#1,a1
		bra.s	.S1_Loop
.S1_End:
	move.l	a1,d0
	sub.l	4(sp),d0
	rts

;char *strpbrk (const char *s1, const char *s2);
strpbrk:
	move.l	4(sp),a0		; S1*
.S1Loop:	moveq	#0,d2		; d2 = NULL
		move.b	(a0),d1
		beq.s	.Found		; Fail to find something
		move.l	8(a7),a1	; S2*
		move.b	(a1)+,d0	
		beq.s	.Found		; If s2 is null, it fails too!
.Loop2:			move.l	a0,d2
			cmp.b	d0,d1
			beq.s	.Found
			move.b	(a1)+,d0
			bne.s	.Loop2
		addq.l	#1,a0
		bra.s	.S1Loop
.Found:	move.l	d2,a0
	rts

;char *strrchr (const char *str, short c);
strrchr:
	move.l	4(sp),d1
	move.l	d1,a0
	move.b	9(sp),d0
.TheEnd:	tst.b	(a0)+
		bne.s	.TheEnd
.Loop:		cmp.b	-(a0),d0
		beq.s	.Found
		cmp.l	a0,d1
		bne.s	.Loop
	suba.l	a0,a0
.Found:	rts
	
;unsigned long strspn (const char *s1, const char *s2);
strspn:
	move.l	4(sp),a1
	move.l	8(sp),d2
.Loop:
		move.b	(a1),d1
		beq.s	.Found
		move.l	d2,a0
.TinyLoop:		move.b	(a0)+,d0
			beq.s	.Found
			cmp.b	d0,d1
			bne.s	.TinyLoop
		addq.l	#1,a1
		bra.s	.Loop
.Found	move.l	a1,d0
	sub.l	4(sp),d0
	rts

;char *strstr (const char *s1, const char *s2);
strstr:
	move.l	4(sp),a0
	move.l	8(sp),a1
.Loop1:		moveq	#0,d2
.Loop2:			; Scan starting from a0 the string str2 
			move.b	0(a0,d2.l),d1
			move.b	0(a1,d2.l),d0
			beq.s	.Exit
			addq.l	#1,d2
			cmp.b	d0,d1
			beq.s	.Loop2
		tst.b	(a0)+
		bne.s	.Loop1
	suba.l	a0,a0
.Exit:	rts

;char *strtok (char *s1, const char *s2); 
strtok:
	move.l	4(a7),d0	; s1
	beq.s	.NotNull
		move.l	d0,STRTOK_PTR	; Save Ptr
.NotNull:
	tst.l	STRTOK_PTR
	beq.s	.Error
	
	move.l	STRTOK_PTR,a1
.Loop		move.b	(a1)+,d1		; Next char
		beq.s	.EndOfString		; End of string
		move.l	8(a7),a0		; s2: Token Chars
.CharLoop		move.b	(a0)+,d0	; Read next Token Char
			beq.s	.Loop		; End of Token string ? Next char in string
			cmp.b	d1,d0		; Cmp 2 chars
			beq.s	.TokenCharFound	; Yes, found
			bra.s	.CharLoop	; No next Token
.EndOfString
	move.l	STRTOK_PTR,a0
	clr.l	STRTOK_PTR
	rts
.TokenCharFound
	move.l	STRTOK_PTR,a0
	clr.b	-1(a1)		; Clear Token
	move.l	a1,STRTOK_PTR
	rts	
.Error	suba.l	a0,a0
	rts
	
