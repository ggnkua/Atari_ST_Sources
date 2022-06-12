;
; PedroM - Operating System for Ti-89/Ti-92+/V200.
; Copyright (C) 2003, 2005-2009 Patrick Pelissier
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


;	ifd	WANT_ASSERT
;HEAP_CHECK	MACRO
;	jsr	HeapCheck
;	ENDM
;	endif
;	ifnd	WANT_ASSERT
HEAP_CHECK	MACRO
	ENDM
;	endif

ROM_BASE	EQU	0
END_ARCHIVE	EQU	$FFFFFFFF


;******************************************************************
;***                                                            ***
;***            	Heap routines				***
;***                                                            ***
;******************************************************************

; Struct:
;	It is a LIST of block.
;
;	Each block is :
;		+ SIZE.l	= Size of the block (in bytes)
;		+ HANDLE.w	= Corresponding Handle + Bit 15 if locked
;		if the block is free, then HANDLE = 0
;		It is also needed because of the bad implementation of the function 'realloc' of Tigcc which checks at -2(a0) the handle !

HeapInit:
	lea	HEAP_START,a0
	move.l	#HEAP_END-HEAP_START,(a0)+	; Set Size
;	move.l	#-HEAP_END+HEAP_START,(a0)	; Set Size
;	neg.l	(a0)+                           ; HEAP_START is a linker symbol so we can't use directly HEAP_END-HEAP_START
	clr.w	(a0)+				; Free Block
	moveq	#-1,d0
	lea	HEAP_TABLE,a0
	move.l	a0,HEAP_PTR
	move.l	d0,(a0)+			; Handle 0
	move.w	#HANDLE_MAX-2,d0
.loop		clr.l	(a0)+
		dbf	d0,.loop
	rts
	
;HANDLE HeapAllocThrow (unsigned long Size);
HeapAllocThrow:
	move.l	4(a7),d0
	bsr.s	HeapAlloc_reg
	tst.w	d0
	bne.s	.ok
;		ER_THROW MEMORY_ERROR
	nop
.ok:	rts

;HANDLE HeapAllocESTACK (unsigned long Size);
HeapAllocESTACK:
	; Since the EStack if fixed, HeapAllocESTACK = HeapAlloc!
;HANDLE HeapAlloc (unsigned long Size);
HeapAlloc:
	move.l	4(a7),d0		; Read Size to alloc
HeapAlloc_reg:				; *** Fix and check size of block to alloc ***
	HEAP_CHECK
	move.l	d0,-(a7)		; Push size (In case it is called via _reg)
	bsr.s	Alloc_Handle		; Alloc a Handle ? 
	tst.w	d0			; Success ?
	bne.s	.Ok			; Yes => Quit
		jsr	HeapCompress	; No, so compress the Heap
		move.l	(a7),d0		; Reload the size
		bsr.s	Alloc_Handle	; And try again !
.Ok	addq.l	#4,a7			; Pop the saved size
	rts				; Return

Alloc_Handle:
	addq.l	#7,d0			; 6 for Block Header + 1 For alignement
	moveq	#$FFFFFFFE,d1		; Word Alignement 
	and.l	d1,d0			; Fix size
	lea	HEAP_START,a0		; *** Find a Free block *** 
.loop		cmp.l	#HEAP_END,a0	; Have we reached the end of the Heap ?
		bcc.s	HeapAlloc_Error	; Yes so there is no space left, quit
		move.l	(a0)+,d1	; Read size of the block
		move.w	(a0)+,d2	; Read type of block
		bne.s	.allocated	; Allocated block ?
			cmp.l	d1,d0	; Check is size ok ?
			bls.s	.found	; Free block Found !
.allocated:	lea	-6(a0,d1.l),a0	; Skip this block
		bra.s	.loop		; Next block
.found:					; *** Test is we create a new free block and the end of the found block ***
	sub.l	d0,d1			; Calculate the free space after
	cmp.l	#8,d1			; keeping the needed byte
	bhi.s	.create			; Reserve all the block ? (ie enought space for a header and the smallest data (2) after ?)
		add.l	d1,d0		; D0 = All the block
		bra.s	.GetHandle	; Continue
.create					; *** Create a new empty block ***
	lea	-6(a0,d0.l),a1		; Set Ptr to new free block
	move.l	d1,(a1)+		; Set size of free blocks
	clr.w	(a1)+			; Set Free Blocks	
.GetHandle:				; *** Get a Free Handle ***
	move.l	d0,-6(a0)		; Save size of allocated block
	pea	(a0)			; Preserve Ptr
	jsr	HeapGetHandle		; Get new Handle
	move.l	(a7)+,a0		; Pop Ptr
	tst.w	d0			; Succesfull ?
	bne.s	.set_handle
		clr.w	-(a0)		; Block is free
		bra.s	HeapAlloc_Error
.set_handle:				; *** Set Handle ***
	move.w	d0,-2(a0)		; Save Handle (For debug mainly)
	lsl.w	#2,d0			; Handle x4
	lea	HEAP_TABLE,a1		; Get Heap Table 
	move.l	a0,0(a1,d0.w)		; Write the new address in the Heap Table
	lsr.w	#2,d0			; Fix handle
	move.l	-6(a0),d1		; *** Clear the allocated block ***
	lsr.l	#1,d1			; Convert byte size to word syze
	subq.l	#3,d1			; Remove Header (6 bytes)
.ClearLoop		clr.w	(a0)+	; Clear data
			subq.l	#1,d1	; No Dbf because d1 may be > 64K !
			bne.s	.ClearLoop
	HEAP_CHECK
	rts

HeapAlloc_Error:
	moveq	#0,d0			; An error occured : return H_NULL
	rts
	
;HANDLE HeapGetHandle (void);
HeapGetHandle:
	lea	HEAP_TABLE,a0
	move.w	#HANDLE_MAX-1,d0
.loop		tst.l	(a0)+
		beq.s	.found
		dbra	d0,.loop
	bra.s	HeapAlloc_Error
.found	sub.w	#HANDLE_MAX-1,d0
	neg.w	d0
	rts

;void HeapFreePtr (void *Ptr);
free:	
HeapFreePtr:
	move.l	4(a7),a0		; Read pointer 
	move.w	-(a0),d0		; Read handle
	bra.s	HeapFree_reg		; Free handle

;void HeapFreeIndir (void *PtrHandle);
HeapFreeIndir:
	move.l	4(a7),a0	; Read pointer to handle
	move.w	(a0),d0		; Read handle
	beq.s	HeapAlloc_Error	; Check if not 0
	clr.w	(a0)		; Clear Handle
	bra.s	HeapFree_reg	; Free Handle

;void HeapFree (HANDLE Handle); 
HeapFree:
	move.w	4(a7),d0
	beq.s	HeapAlloc_Error
HeapFree_reg:	
	HEAP_CHECK
	lsl.w	#2,d0			; *** Read Block Addr and clear Handle ***
	lea	HEAP_TABLE,a0		; Get Heap Table ptr
	move.l	0(a0,d0.w),a1		; Read address
	move.l	a1,d1			; Check if Null
	beq.s	HeapAlloc_Error	
	clr.l	0(a0,d0.w)		; Clear Handle
	cmp.l	#ROM_BASE,a1		; If the handle was in archive
	bhi.s	.cant_merge2		; Just clear its reference !
	move.w	-(a1),d1		; *** Create a Free block ***
	clr.w	(a1)			; Free the block
	move.l	-(a1),d2		; d2 = Size of the block
	lsl.w	#2,d1			; We check if the Heap was corrupted...
	cmp.w	d1,d0			; d1 = Saved Handle = d0.w = Deref Handle
	bne	HeapCorrupted		; The Heap is corrupted !!!
	; Now start and check if we can merge Free Blocks
	; Search for previous block of a1
	lea	HEAP_START,a0
	moveq	#0,d2			; "First Block"
.loop		cmp.l	a1,a0
		bhi	HeapCorrupted	; Error !
		beq.s	.found		; Current Block = New Free bLock ? Yes => Found previous block
		move.l	a0,d2		; Save Previous Block
		add.l	(a0),a0		; Next Block
		bra.s	.loop	
.found:	tst.l	d2
	beq.s	.cant_merge		; d2.l = 0, so there is no previous block
		; Check merge with previous block
		move.l	d2,a0			; a0 = Previous block
		tst.w	4(a0)			; a0 = Previous block
		bne.s	.cant_merge
			move.l	(a1),d0		; Size of Free Block
			add.l	d0,(a0)		; Add it to the previous size
			move.l	a0,a1		; Set new Free Block
.cant_merge:
	; Next block
	move.l	(a1),d0			; Read size
	lea	0(a1,d0.l),a0		; Ptr to next block
	cmp.l	#HEAP_END,a0		; End of the Heap
	bcc.s	.cant_merge2
		; Check Merge with next block
		tst.w	4(a0)
		bne.s	.cant_merge2
			move.l	(a0),d0		; Size of Next Block
			add.l	d0,(a1)		; Add it to the Free Block size
.cant_merge2:
	HEAP_CHECK
	rts
	
;short HeapGetLock (HANDLE Handle);
HeapGetLock:
	move.w	4(a7),a0		; Handle
	trap	#3			; Deref Handle
	move.w	-(a0),d0		; Read internal flags
	andi.w	#$8000,d0		; 
	cmp.l	#ROM_BASE,a0
	bls.s	.Ok
		moveq	#1,d0		; Archive files are always locked
.Ok	rts


;HANDLE HeapUnlock (HANDLE Handle);
HeapUnlock:
	move.w	4(a7),a0		; Handle
HeapUnlock_reg:
	move.w	a0,d0
	beq.s	.No
		trap	#3			; Deref Handle
		andi.w	#$7FFF,-(a0)		; UnLock Handle (Do nothing or archived)
.No	rts
	
;; We can merge HeapLock and HLock quite easily.
;HANDLE HeapLock (HANDLE Handle);
HeapLock:
;void *HLock (HANDLE Handle);
HLock:
	move.w	4(a7),a0		; Handle
HeapLock_reg:
	move.w	a0,d0			; If H_NULL, returns NULL
	beq.s	HLock_error
		trap	#3		; Deref Handle
		ori.w	#$8000,-2(a0)	; Lock Handle
	rts				; Return Ptr to Block in a0 / Handle in d0
HLock_error:	
	suba.l	a0,a0
	rts	

;void *HeapAllocPtr (unsigned long Size);
malloc:	
HeapAllocPtr:
	move.l	4(a7),d0		; Read size
	beq.s	HLock_error
	addq.l	#2,d0			; +2 for storing the Handle (Needed for compatibility)
	jsr	HeapAlloc_reg		; Alloc
	suba.l	a0,a0			; Null Ptr
	move.w	d0,-(a7)
	beq.s	.error
		bsr.s	HLock		; Lock Handle and Deref it
		move.w	(a7),(a0)+	; Store the Handle in the first word (To be compatible with Tigcc realloc function!)
.error	addq.l	#2,a7
	rts

;unsigned long HeapSize (HANDLE Handle);
HeapSize:
	move.w	4(a7),a0		; Handle
	trap	#3			; Deref Handle
	cmp.l	#ROM_BASE,a0		; Check if it is archived?
	blt.s	.Ram
		moveq	#0,d0		; Read size of Files. 
		move.w	(a0),d0		; as a long word.
		addq.l	#2,d0		; +2
		rts
.Ram:	move.l	-6(a0),d0		; Read size of Handle
	subq.l	#6,d0			; Minus header
	rts

;void *HeapEnd (void);
HeapEnd:
	lea	HEAP_END,a0
	rts
	
;void *HeapDeref (HANDLE Handle);
; I could use trap #3, but many nostub programs (like db92 & Vti)
; use some hard hack to get Heap Table.
; To keep compatiblity with them, I don't use trap #3
HeapDeref:
	moveq	#0,d0		; To avoid bug in SetFileInUseBit for tigcc's programs. I can't do it after, since some programs (Fz programs) assume that this function returns the handle *4 in d0.w...
	move.w	4(a7),d0
	lsl.w	#2,d0
	movea.l	HEAP_PTR,a0
	move.l	0(a0,d0.w),a0
	rts

;unsigned long HeapAvail (void);
HeapAvail:
	lea	HEAP_START,a0
	moveq	#0,d0
.loop		cmp.l	#HEAP_END,a0
		bcc.s	.end		
		move.l	(a0)+,d1	; Read Block Size
		ble	HeapCorrupted
		tst.w	(a0)+		; Allocated ?
		bne.s	.allocated	; Free Block
			add.l	d1,d0	; Add Free size to alloc size
.allocated:	lea	-6(a0,d1.l),a0	; Next block
		bra.s	.loop	
.end:	rts	

; HANDLE HeapPtrToHandle(void *ptr);
HeapPtrToHandle:
	move.l	4(a7),a0
HeapPtrToHandle_reg
	lea	HEAP_TABLE+4,a1
	moveq	#0,d0
	move.w	#HANDLE_MAX-2,d2
.loop		addq.w	#1,d0		; Handle ++
		cmp.l	(a1)+,a0	; Check Handle 
		dbeq	d2,.loop	; Continue ?
	bne.s	.NotFound		; Not found?
	rts
.NotFound	
	clr.w	d0	
	rts

; unsigned long HeapMax(void);
; Return min(65520, HeapMax())
HeapMax2:
	bsr.s	HeapMax
	move.l	#65520,d1
	cmp.l	d1,d0
	bls.s	.Ok
		exg	d1,d0
.Ok:	rts

; unsigned long HeapMax(void);
HeapMax:	; Find max Free Block
	bsr.s	HeapCompress
	lea	HEAP_START,a0
	moveq	#0,d0
.loop		cmp.l	#HEAP_END,a0
		bcc.s	.end
		move.l	(a0)+,d1
		ble	HeapCorrupted
		tst.w	(a0)+
		bne.s	.allocated		; Free Block ?
			cmp.l	d1,d0		; size of Free Blocks > current max ?
			bhi.s	.allocated
				move.l	d1,d0	
.allocated:	lea	-6(a0,d1.l),a0		; Skip this block
		bra.s	.loop	
.end:	subq.l	#6,d0				; minus The header !
	rts	

;void HeapCompress (void);
HeapCompress:
	HEAP_CHECK
	; Recherche d'un bloc libre
	lea	HEAP_START,a0
	bra.s	.loop
.Bloop:		add.l	d1,a0			; Find a free block
.loop		cmp.l	#HEAP_END,a0
		bcc.s	.end
		move.l	(a0),d1			; Next Block
		ble	HeapCorrupted
		tst.w	4(a0)			; Allocated block
		bne.s	.Bloop
.free						; Find Free Block
		move.l	(a0),d1			; (Re)read block size
		lea	0(a0,d1.l),a1		; Next Block
		cmp.l	#HEAP_END,a1
		bcc.s	.end
		move.w	4(a1),d0		; Test next block if Free Block
		bne.s	.allocated
			move.l	(a1),d1		; Read Block Size
			ble	HeapCorrupted
			add.l	d1,(a0)		; Increase Block size
			bra.s	.free		; Continue
.allocated:	; Test if next block is locked
		btst.l	#15,d0
		beq.s	.notlocked
			move.l	a1,a0		; New starting Block
			bra.s	.loop		; Search for a new free block from a0
.notlocked:	; Move Block from top to end
		move.l	a0,d2			; Save Ptr value
		move.l	(a1),d0			; d0.l = Number of bytes
		lsr.l	#1,d0			; Number of word
.Block_move		move.w	(a1)+,(a0)+
			subq.l	#1,d0
			bne.s	.Block_move
		; Create New Free block at the end
		move.l	d1,(a0)			; Same size
		clr.w	4(a0)			; Free block
		; Fix the handle table
		move.l	d2,a1			; Get Ptr
		addq.l	#6,d2			; Skip Ptr
		move.w	4(a1),d0		; Read Handle + Lock/extra flag
		lsl.w	#2,d0			; Index (Lock/Extra flag are cleared)
		lea	HEAP_TABLE,a1		; Heap Table
		move.l	d2,0(a1,d0.w)		; Write new address in HeapTable[Handle]
		bra.s	.free			; Continue moving 
.end:
	HEAP_CHECK
	rts	

;short FreeHandles (void);
FreeHandles:
	lea	HEAP_TABLE,a0
	moveq	#0,d0
	move.w	#HANDLE_MAX-1,d2
.loop		tst.l	(a0)+
		bne.s	.next
			addq.l	#1,d0
.next		dbra	d2,.loop
	rts

;HANDLE HeapRealloc (HANDLE Handle, unsigned long NewSize);
; Throw error if NewSise > 65520
HeapRealloc2:
	cmpi.l	#65520,6(a7)		; Check max size
	bls.s	HeapRealloc		; 
	clr.w	d0			; H_NULL
	rts				; Return H_NULL

;HANDLE HeapRealloc (HANDLE Handle, unsigned long NewSize);
HeapRealloc:
	HEAP_CHECK
	move.l	6(a7),d2	; New Size
	move.w	4(a7),d0	; Handle
	bne.s	.Realloc
		move.l	d2,d0
		bra	HeapAlloc_reg
.Realloc:
	move.l	d3,-(a7)
	move.w	d0,d3
	; Update new size
	addq.l	#7,d2			; 6 for Block Header + 1 For alignement
	moveq	#$FFFFFFFE,d1		; Word Alignement 
	and.l	d1,d2			; Fix size
	; Deref Handle
	move.w	d0,a0
	trap	#3
	; Return H_NULL if Handle is archived.
	clr.w	d0
	cmp.l	#$200000,a0
	bhi	.final
	; Read old size
	subq.l	#6,a0			; Get Header
	move.l	(a0),d0			; Read Size
	lea	0(a0,d0.l),a1		; Next Block
	cmp.l	d2,d0			; Cmp size ?
	bge.s	.reduce
		; Increase size of handle
		; Is next block free ?
		tst.w	4(a1)
		bne.s	.alloc_new
			; Is size of next free block enought ?	
			move.l	(a1),d1
			add.l	d0,d1		; Size of the 2 blocks
			sub.l	d2,d1
			blt.s	.alloc_new	; Next Free Block is not enought to realloc handle
				; Is the remain of the free block is > 8 (Header + data)
				cmp.l	#8,d1
				bge.s	.create
					add.l	d1,d2	; Augment size to alloc
					moveq	#0,d1	; No new block
.create				; Augment Block size
				lea	0(a0,d2.l),a1	; Next Free block
				move.l	d2,(a0)
				; Test if we create a new free block
				tst.l	d1
				beq.s	.end
					move.l	d1,(a1)+	; Size of th next free block
					clr.w	(a1)+		; Free Block (Fix me : useless ?)
					bra.s	.end		; Exit function
.alloc_new	; Test if Locked block (Cannot be relocated)
		clr.w	d0		; H_NULL
		tst.w	4(a0)
		blt.s	.final
			; Alloc a new handle
			move.l	d2,d0		; Size to alloc
			jsr	HeapAlloc_reg	; Try to alloc it ?
			tst.w	d0		; Error ?
			beq.s	.final
				move.w	d3,a0	; Old Handle
				trap	#3	; Deref
				lea	-6(a0),a1	; Old Ptr
				move.w	d0,a0	; Deref new Handle
				trap	#3
				subq.l	#2,a0
				; Copy the handle
				move.l	(a1)+,d1	; Read old size
				subq.l	#4,d1		; - Size (Long)
				lsr.l	#1,d1		; From byte to word
.copy_loop:				move.w	(a1)+,(a0)+	; Copy Blocks
					subq.l	#1,d1		; It copies also Old Handle in the block
					bne.s	.copy_loop	; 
				move.w	d0,-(a7)	; Save new Handle
				move.w	d3,d0		; Free Old handle
				jsr	HeapFree_reg	; ...
				move.w	(a7)+,d0	; New handle
				lea	HEAP_TABLE,a0	; Exchange handles in the HeapTable
				lsl.w	#2,d0		; x4
				lsl.w	#2,d3		; The handle number inside the block was already copied
				move.l	0(a0,d0.w),0(a0,d3.w)	; Copy new one in old one
				clr.l	0(a0,d0.w)		; Clear new handle
				bra.s	.end		; Quit
.reduce:	; Reduce Handle size
	tst.w	4(a1)			; Is next Block Free ?
	bne.s	.nofree			
		; Next Block is free ! (Increase it)
		move.l	(a1),d1		; d1 = Block size
		add.l	d0,d1		; d1 = Block size + Old Bsize
		sub.l	d2,d1		; d1 = Block size + Old Bsize - New BSize
		; Create new block
.createn	lea	0(a0,d2.l),a1	; New Next Block
		move.l	d1,(a1)+	; New Next Block size
		clr.w	(a1)+		; Set it as free
		move.l	d2,(a0)		; Fix org size in org block
		bra.s	.end
.nofree:	; Next Block is not free
	; Can we create a new free block ?
	sub.l	d2,d0
	move.l	d0,d1			; New Block size
	cmp.l	#8,d0			; Can we create a new one ?
	bge.s	.createn
.end	move.w	4+4(a7),d0		; Return previous handle
.final	move.l	(a7)+,d3
	HEAP_CHECK
	rts

;HANDLE HeapAllocHighThrow (unsigned long Size);
HeapAllocHighThrow:
	move.l	4(a7),-(a7)
	bsr.s	HeapAllocHigh
	addq.l	#4,a7
	tst.w	d0
	bne.s	.ok
;		ER_THROW MEMORY_ERROR
	nop
.ok:	rts

;HANDLE HeapAllocHigh (unsigned long Size);
HeapAllocHigh:
	HEAP_CHECK
	jsr	HeapCompress		; Compress the Heap First
	move.l	4(a7),d0		; Read Size to alloc
	addq.l	#7,d0			; 6 for Block Header + 1 For alignement
	moveq	#$FFFFFFFE,d1		; Word Alignement 
	and.l	d1,d0			; Fix size
	lea	HEAP_START,a0		; *** Find a Free block *** 
	suba.l	a1,a1			; No block found
.loop		cmp.l	#HEAP_END,a0	; Have we reached the end of the Heap ?
		bcc.s	.found		; Yes so there is no space left, quit the loop
		move.l	(a0)+,d1	; Read size of the block
		move.w	(a0)+,d2	; Read type of block
		bne.s	.allocated	; Allocated block ?
			cmp.l	d1,d0	; Check is size ok ?
			bhi.s	.allocated	; Free block Found !
				move.l	a0,a1	; New free block with an upper address
.allocated:	lea	-6(a0,d1.l),a0	; Skip this block
		bra.s	.loop		; Next block
.found:					; *** Test is we create a new free block and the end of the found block ***
	move.l	a1,d2			; Success to find at least a block ?
	beq	HeapAlloc_Error		; No quit on an error
	move.l	a1,a0			; The block where we will working
	move.l	-6(a1),d1		; Size of the block
	sub.l	d0,d1			; Calculate the free space after
	cmp.l	#8,d1			; keeping the needed byte
	bhi.s	.create			; Reserve all the block ? (ie enought space for a header and the smallest data (2) after ?)
		add.l	d1,d0		; D0 = Taille du block a allouer All the block
		bra.s	.GetHandle	; Continue
.create					; *** Create a new empty block ***
	lea	0(a1,d1.l),a0		; Set Ptr to the allocated block
	clr.w	-(a1)			; Set Free Blocks	
	move.l	d1,-(a1)		; Set size of free blocks
.GetHandle:				; *** Get a Free Handle ***
	move.l	d0,-6(a0)		; Save size of allocated block
	pea	(a0)			; Preserve Ptr
	jsr	HeapGetHandle		; Get new Handle
	move.l	(a7)+,a0		; Pop Ptr
	tst.w	d0			; Succesfull ?
	bne.s	.set_handle
		clr.w	-(a0)		; Block is free
		bra	HeapAlloc_Error
.set_handle:				; *** Set Handle ***
	ori.w	#$8000,d0		; Lock Handle
	move.w	d0,-2(a0)		; Save Handle (For debug mainly)
	lsl.w	#2,d0			; Handle x4
	lea	HEAP_TABLE,a1		; Get Heap Table 
	move.l	a0,0(a1,d0.w)		; Write the new address in the Heap Table
	lsr.w	#2,d0			; Fix handle
	move.l	-6(a0),d1		; *** Clear the allocated block ***
	lsr.l	#1,d1			; Convert byte size to word syze
	subq.l	#3,d1			; Remove Header (6 bytes)
.ClearLoop		clr.w	(a0)+	; Clear data
			subq.l	#1,d1	; No Dbf because d1 may be > 64K !
			bne.s	.ClearLoop
	HEAP_CHECK
	rts

;HANDLE HeapMoveHigh (HANDLE Handle);
HeapMoveHigh:
	HEAP_CHECK
	move.w	4(a7),a0
	trap	#3
	move.w	-(a0),d0
	ori.w	#$8000,d0		; Handle Locked ?
	beq.s	.Ok
.Error		moveq	#0,d0
		rts
.Ok:	move.l	-(a0),-(a7)
	jsr	HeapAllocHigh
	addq.l	#4,a7
	tst.w	d0
	beq.s	.Error
	move.w	d0,a0		; Deref new Handle
	trap	#3		; Copy the handle
	move.l	(a0),d1		; Read Size
	lsr.l	#1,d1		; From byte to word
.copy_loop:	move.w	(a1)+,(a0)+	; Copy Blocks
		subq.l	#1,d1		; May be more than 128Kb ! (In fact, no since we alloc twice)
		bne.s	.copy_loop
	move.w	d0,-(a7)	; Save new Handle
	move.w	6(a7),d0	; Free Old handle
	jsr	HeapFree_reg	; ...
	lea	HEAP_TABLE,a0	; Exchange handles in the HeapTable
	move.w	(a7)+,d0	; New handle
	move.w	4(a7),d1	; Original handle
	lsl.w	#2,d0
	lsl.w	#2,d1
	move.l	0(a0,d0.w),0(a0,d1.w)	; Copy new one in old one
	clr.l	0(a0,d0.w)		; Clear new handle
	move.w	4(a7),d0	; Original handle
	HEAP_CHECK
	rts
	
; Note:
;	It resets the system if an error is discovered !
HeapCheck:
	movem.l	d0-d2/a0-a1,-(a7)
	lea	HEAP_TABLE,a1
	; Check the Heap List
	lea	HEAP_START,a0
.loop		cmp.l	#HEAP_END,a0
		bcc.s	.End
		move.w	4(a0),d2
		beq.s	.free
			lsl.w	#2,d2		; I can forget to delete the flags
			move.l	0(a1,d2.w),d2
			subq.l	#6,d2
			cmp.l	d2,a0
			bne.s	HeapCorrupted
.free		move.l	(a0),d2
		cmp.l	#6,d2
		bls.s	HeapCorrupted
		cmp.l	#256000,d2
		bhi.s	HeapCorrupted
		btst.l	#0,d2
		bne.s	HeapCorrupted
		add.l	d2,a0
		bra.s	.loop
.End:	cmp.l	#HEAP_END,a0
	bne.s	HeapCorrupted
	; Check the Heap Table (a1)
	moveq	#-1,d0
	move.l	(a1)+,d1
	cmp.l	d0,d1
	bne.s	HeapCorrupted
	move.w	#HANDLE_MAX-2,d2
.HeapTableLoop:
		move.l	(a1)+,d1
		beq.s	.Ok
		cmp.l	d0,d1
		beq.s	.Ok
		cmp.l	#HEAP_START-1,d1	; < HeapStart ?
		bls.s	HeapCorrupted
		cmp.l	#END_ARCHIVE-1,d1	; > EndArchive ?
		bhi.s	HeapCorrupted
		andi.w	#1,d1			; Odd address ?
		bne.s	HeapCorrupted
.Ok		dbf	d2,.HeapTableLoop
	movem.l	(a7)+,d0-d2/a0-a1
	rts
	
HeapCorrupted
;	ifd	WANT_ASSERT
	bra	*
;	endif
;	lea	HeapCorrupted_str(Pc),a0
;	jmp	SYSTEM_ERROR
		

; UniOs Deref (a0.w = handle).
Trap_3:
	adda.w	a0,a0
	adda.w	a0,a0
	adda.l	#HEAP_TABLE,a0
	move.l	(a0),a0
	rte
