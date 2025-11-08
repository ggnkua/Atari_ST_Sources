; IFF.S - IFF85 Format Parsing Helpers
; Provides generic chunk navigation for EA IFF 85 format files
;-----------------------------
; Configuration
;-----------------------------
IFF_MAX_LENGTH	equ	$20000		; 128KB max chunk size

;-----------------------------
; iff_check_chunk - Validate chunk without advancing
; Input:
;   a0 = Current position in IFF stream
;   d0.l = Expected chunk ID (4CC)
; Output:
;   d0.l = 0 on success, -1 on failure (CCR set)
;   a0 = Unchanged (still points to chunk header)
;   a1 = End of chunk body (if success)
; Trashes: None
;-----------------------------
iff_check_chunk:
	; Check chunk ID matches
	cmp.l	(a0),d0
	bne.s	.fail_id_mismatch

	; Read and validate size
	move.l	4(a0),d0		; d0 = chunk size
	beq.s	.fail_zero_size		; Size must be non-zero
	cmp.l	#IFF_MAX_LENGTH,d0	; Sanity check (128KB max)
	bgt.s	.fail_too_large

	; Calculate chunk end (header + size + body)
	lea	8(a0,d0.l),a1		; a1 = end of chunk body
	moveq	#0,d0			; Success
	rts

.fail_id_mismatch:
.fail_zero_size:
.fail_too_large:
	moveq	#-1,d0			; Failure
	rts

;-----------------------------
; iff_enter_chunk - Enter a regular chunk (return body bounds)
; Input:
;   a0 = Current position (at chunk header)
;   a1 = End of current scope (for bounds check)
; Output:
;   d0.l = 0 on success, -1 on failure (CCR set)
;   a0 = Start of chunk body (if success)
;   a1 = End of chunk body (if success)
; Trashes: a2
;-----------------------------
iff_enter_chunk:
	; Bounds check - need 8 bytes (ID + size)
	lea	8(a0),a2
	cmp.l	a2,a1
	blt.s	.fail_bounds

	; Read chunk size and validate
	move.l	4(a0),d0		; d0 = chunk size (body only)
	cmp.l	#IFF_MAX_LENGTH,d0	; Sanity check
	bgt.s	.fail_too_large

	; Calculate body range
	lea	8(a0),a0		; a0 = body start (skip header)
	lea	0(a0,d0.l),a2		; a2 = body end

	; Bounds check body end
	cmp.l	a2,a1
	blt.s	.fail_bounds

	move.l	a2,a1			; a1 = body end
	moveq	#0,d0			; Success
	rts

.fail_bounds:
.fail_zero_size:
.fail_too_large:
	moveq	#-1,d0
	rts

;-----------------------------
; iff_enter_group - Enter a group chunk (FORM/LIST/CAT)
; Input:
;   a0 = Current position (at group chunk header)
;   a1 = End of current scope (for bounds check)
;   d0.l = Expected group type (4CC, e.g., 'ILBM', 'TPN1', etc.)
; Output:
;   d0.l = 0 on success, -1 on failure (CCR set)
;   a0 = Start of group body (if success)
;   a1 = End of group body (if success)
; Trashes: a2
;-----------------------------
iff_enter_group:
	; Bounds check - need 12 bytes (ID + size + type)
	lea	12(a0),a2
	cmp.l	a2,a1
	blt.s	.fail_bounds

	; Check group type matches (do this before reading size so we can reuse d0)
	cmp.l	8(a0),d0		; Compare type field
	bne.s	.fail_type_mismatch

	; Read chunk size (includes type + body)
	; Now we can reuse d0 since we no longer need the type value
	move.l	4(a0),d0		; d0 = size (4 bytes type + body)
	beq.s	.fail_zero_size
	cmp.l	#IFF_MAX_LENGTH,d0	; Sanity check
	bgt.s	.fail_too_large

	; Calculate body range
	; Size includes the 4-byte type field, so:
	; body_end = header_start + 8 (header+size) + size - 4 (type already counted)
	lea	12(a0),a0		; a0 = body start (skip header+size+type)
	lea	-4(a0,d0.l),a2		; a2 = body end (size includes type, subtract 4)

	; Bounds check body end
	cmp.l	a2,a1
	blt.s	.fail_bounds

	move.l	a2,a1			; a1 = body end
	moveq	#0,d0			; Success
	rts

.fail_bounds:
.fail_zero_size:
.fail_too_large:
.fail_type_mismatch:
	moveq	#-1,d0
	rts

;-----------------------------
; iff_next_chunk - Advance to next chunk with IFF alignment
; Input:
;   a0 = Current chunk position (at chunk header)
;   a1 = End of current scope (for bounds check)
; Output:
;   d0.l = 0 on success, -1 on failure (CCR set)
;   a0 = Next chunk position (if success)
;   a1 = Unchanged (still end of scope)
; Trashes: a2
;-----------------------------
iff_next_chunk:
	; Read chunk size
	move.l	4(a0),d0		; d0 = chunk size
	beq.s	.fail_zero_size		; Zero size is invalid

	; Apply IFF even-alignment padding
	btst	#0,d0
	beq.s	.size_even
	addq.l	#1,d0
.size_even:
	; Calculate next chunk position
	lea	8(a0,d0.l),a2		; a2 = next chunk position

	; Bounds check - ensure next position is within scope
	cmp.l	a2,a1
	blt.s	.fail_bounds		; Next position exceeds end

	move.l	a2,a0			; a0 = next chunk
	moveq	#0,d0			; Success
	rts

.fail_zero_size:
.fail_bounds:
	moveq	#-1,d0
	rts

;-----------------------------
; iff_find_chunk - Find chunk by ID with optional skip count
; Input:
;   a0 = Current position in IFF stream
;   a1 = End of current scope
;   d0.l = Chunk ID to find (4CC)
;   d1.b = Skip count (0=first match, 1=second, etc.)
; Output:
;   d0.l = 0 on success, -1 on failure (CCR set)
;   a0 = Chunk header position (if success) - can be used with iff_enter_chunk/iff_enter_group
;   a1 = Unchanged (still end of current scope)
; Trashes: d2, a2
;-----------------------------
iff_find_chunk:
	move.l	d0,d2			; d2 = target chunk ID

.search_loop:
	; Bounds check - need 8 bytes (ID + size)
	lea	8(a0),a2
	cmp.l	a2,a1
	blt.s	.fail_not_found

	; Check if this chunk matches target
	cmp.l	(a0),d2
	bne.s	.next_chunk

	; Found a match - check skip count
	tst.b	d1
	beq.s	.found_target		; Skip count = 0, this is it
	subq.b	#1,d1			; Decrement skip count

.next_chunk:
	; Advance to next chunk using helper (validates bounds)
	bsr	iff_next_chunk
	beq.s	.search_loop		; Success, continue search
	; Fall through to fail if iff_next_chunk failed

.fail_not_found:
	moveq	#-1,d0
	rts

.found_target:
	; Return chunk header position
	; a0 already points to chunk header
	; a1 unchanged (still scope end)
	moveq	#0,d0			; Success
	rts
