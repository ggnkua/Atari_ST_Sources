	SECTION	text
stepingStone
	cmpi.w	#CUT,d0
	beq	cutCopyBlock
	cmpi.w	#COPY,d0
	beq	cutCopyBlock
	cmpi.w	#DELETE,d0
	beq	deleteBlock
	cmpi.w	#TRIM,d0
	beq	trimBlock
	cmpi.w	#PASTE,d0
	beq	pasteBlock
	cmpi.w	#OVERLAY,d0
	beq	pasteBlock
	cmpi.w	#BLOCKRESET,d0
	beq	blockReset
	cmpi.w	#ALTERINFO,d0
	beq	alterSampleInfo
	cmpi.w	#CLIPLOAD,d0
	beq	loadBlock
	cmpi.w	#CLIPSAVE,d0
	beq	saveBlock
	cmpi.w	#CLIPCLEAR,d0
	beq	clearBlock
	cmpi.w	#GEMCLIP,d0
	beq	toggleGEMClipboard

	cmpi.w	#CONVERTFORMAT,d0
	beq	convertFormat

	rts