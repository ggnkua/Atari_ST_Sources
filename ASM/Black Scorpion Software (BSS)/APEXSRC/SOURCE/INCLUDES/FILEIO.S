
*-----------------------------------------------------------------------*
*	LOAD routines									*
*-----------------------------------------------------------------------*

LOAD_FILE:
	move.b	#1,BUSY
	clr.b		ALERT
	clr.b		Memory_error
	move.l	sp,LOAD_STACK
	move.l	#SELECTOR_MLOAD,SELECTOR_MESSAGE
	jsr		HIDE_MOUSE
	st		MENUPAL_CHANGED
	sf		anim
	tst.b		edit
	beq.s		.no
	push.w	BRUSH_SELECTED
	move.w	#3,BRUSH_SELECTED
	bsr		UPDATE_BRUSH
.no	move.w	DISKTYP1_BITS,d0
	btst		#Bit_DISKTYP1_JPG,d0
	bne		Load_JPG
	btst		#Bit_DISKTYP1_PC1,d0
	bne		Load_PC1
	btst		#Bit_DISKTYP1_LBM,d0
	bne		Load_LBM
	btst		#Bit_DISKTYP1_GIF,d0
	bne		Load_GIF
	btst		#Bit_DISKTYP1_TGA,d0
	bne		Load_TGA
	btst		#Bit_DISKTYP1_MTV,d0
	bne		Load_MTV
	btst		#Bit_DISKTYP1_SPU,d0
	bne		Load_SPU
	btst		#Bit_DISKTYP1_PCS,d0
	bne		Load_PCS
	btst		#Bit_DISKTYP1_FLI,d0
	bne		Load_FLI
	btst		#Bit_DISKTYP1_SEQ,d0
	bne		Load_SEQ
	btst		#Bit_DISKTYP1_ANM,d0
	bne		Load_ANM
	btst		#Bit_DISKTYP1_BLK,d0
	bne		Load_BLK
	btst		#Bit_DISKTYP1_CFN,d0
	bne		Load_CFN
	btst		#Bit_DISKTYP1_DAC,d0
	bne		Load_DAC
	btst		#Bit_DISKTYP1_CTL,d0
	bne		Load_MCL

END_LOAD:
	jsr		Redraw_menu_icons
	jsr		Superscaler
	tst.b		edit
	beq.s		.no
	jsr		Clear_brush
	pop.w		BRUSH_SELECTED
	bsr		UPDATE_BRUSH
.no	sf		FRAMECOUNT
	jsr		Refresh_info_bar
	jsr		MRELEASE
	st		MENUPAL_CHANGED
	move.l	LOAD_STACK,sp
	clr.w		DISKFUNC_BITS
	jsr		SHOW_MOUSE
	sf		ALERT
	clr.b		BUSY
	rts

	ifd		crap

KILL_FILE:
	move.b	#1,BUSY
	clr.b		ALERT
	clr.b		Memory_error
	move.l	sp,LOAD_STACK
	move.l	#SELECTOR_MKILL,SELECTOR_MESSAGE
	jsr		HIDE_MOUSE
	sf		anim
	jmp		Kill_ANY

END_KILL:
	sf		FRAMECOUNT		
	jsr		MRELEASE
	move.l	LOAD_STACK,sp
	clr.w		DISKFUNC_BITS
	jsr		SHOW_MOUSE
	sf		ALERT
	clr.b		BUSY
	rts

Kill_ANY:
	move.l	#STARd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.exit
	lea		FILENAME,a0
	jsr		DeleteFile
.exit	bra		END_KILL

	endc

*-----------------------------------------------------------------------*

Load_DAC:
	move.l	#DACd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.exit
	lea		FILENAME,a0
	jsr		OpenFile
	tst.l		d0
	bmi.s		.exit
	move.w	d0,FILE_HANDLE
	move.l	#1024,d1
	lea		COLOURS,a0
	move.l	a0,DISPLAY_COLOURS
	move.w	FILE_HANDLE,d0
	jsr		ReadFile
	move.w	FILE_HANDLE,d0
	jsr		CloseFile
	st		PALETTE_CHANGED
	jsr		Update_palette
	jsr		Remap_menu_bars
	bsr		EndFrame_handler
.exit	bra		END_LOAD

Load_CFN:
	move.l	#CFNd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.err
	lea		FILENAME,a0
	jsr		get_filesize
	move.l	d0,filebytes
	lea		FILENAME,a0
	bsr		OpenFile
	tst.l		d0
	bmi		.err
	move.w	d0,FILE_HANDLE
	move.l	filebytes,d1
	add.l		#256,d1
	move.w	CFN_HANDLE,d0
	jsr		Translate_block
	tst.l		d0
	bmi		.clos
	move.w	d0,CFN_HANDLE
	jsr		Find_block	
	move.l	filebytes,d1
	move.w	FILE_HANDLE,d0
	sf		font_loaded
	bsr		ReadFile
	tst.l		d0
	bmi.s		.clos
	st		font_loaded
.clos	move.w	FILE_HANDLE,d0
	bsr		CloseFile
.err	bra		END_LOAD

*-----------------------------------------------------------------------*
*	ST picture load subroutines							*
*-----------------------------------------------------------------------*

Load_PC1:
	IFD		READERS
	move.l	#PC1d,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.err
	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		.err
	tst.b		ALERT
	bne		.err
	lea		FILENAME,a0
	jsr		get_filesize
	move.l	d0,filebytes
	cmp.l		#32066,d0
	ble.s		.cont
	jsr		SIZE_ERROR
	tst.b		OK_CANCEL
	bne		.err
.cont	move.l	#40000,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.err
	move.l	a0,source_image
	lea		FILENAME,a0
	jsr		get_filesize
	move.l	d0,filebytes
	lea		FILENAME,a0
	jsr		OpenFile
	tst.l		d0
	bmi		.err
	move.w	d0,FILE_HANDLE
	move.l	filebytes,d1
	move.l	source_image,a0
	jsr		ReadFile
	tst.l		d0
	bpl		.c2
	move.w	FILE_HANDLE,d0
	jsr		CloseFile
	bra		.err
.c2	move.w	FILE_HANDLE,d0
	jsr		CloseFile
	move.l	source_image,a0
	lea		2(a0),a0
	bsr		convert_cols
	move.l	PACK_SCR,a1
	moveq		#0,d0
	move.w	#64000/4-1,d1
.lp	move.l	d0,(a1)+
	dbra		d1,.lp
	move.l	PACK_SCR,a1
	jsr		UNPACK_PC1
	move.w	#320,source_width
	move.w	#200,source_height
	move.w	#320,dest_width
	move.w	CANVAS_WIDTH,dest_scrwidth
	move.w	#200,dest_height
	move.l	PACK_SCR,source_image
	move.w	#fmat_bitplane,source_format
	sf		colours_available		
	st		sacrifice
	jsr		CONVERT_IMAGE
	sf		sacrifice
	jsr		MRELEASE
	jsr		Update_palette
	jsr		Remap_menu_bars
	st		CHANGE_MADE
	bsr		EndFrame_handler
	ENDC
.err	bra		END_LOAD

*-----------------------------------------------------------------------*
*	IMPORT picture load subroutines						*
*-----------------------------------------------------------------------*

Load_GIF:
	move.l	#GIFd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.err
	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		.err
	tst.b		ALERT
	bne		.err
	
*-----------------------------------------------------------------------*
	ifd		oldgif
*-----------------------------------------------------------------------*

	move.l	PACK_SCR,a0
	bsr		INIT_GIFTABLES
	move.l	PACK_SCR,a0
	add.l		#GIF_Workspace+1024,a0
	move.l	a0,GIF_Load_buffer
	move.l	#16384,GIF_Loadsize
	add.l		#16384+1024,a0
	move.l	a0,FREE_ADDR
	move.l	PACK_SCR,d0
	add.l		CANVAS_SIZE,d0
	sub.l		a0,d0
	move.l	d0,FREE_SPACE

	move.l	#FILENAME,FILENAME_PTR
	bsr		EXAMINE_GIF		
	tst.l		d0
	bmi		.err
.cont	cmp.l		#'GIF8',GIF_Signature
	beq		.cnt2
	jsr		TYPE_ERROR
	bra		.err
.cnt2	move.w	GIF_Width,d0
	move.w	GIF_Height,d1
	addq		#2,d1
	mulu		d1,d0		
	cmp.l		FREE_SPACE,d0
	bgt.s		.make
	move.l	FREE_ADDR,GIF_Unpack_buffer
	clr.l		FREE_SPACE
	bra.s		.made
.make	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.err 
	move.l	a0,GIF_Unpack_buffer
.made	bsr		READ_GIF
	st		PALETTE_CHANGED

	move.w	GIF_Width,d0
	move.w	GIF_Height,d1
	bsr		GetAspect
	move.w	GIF_Width,source_width
	move.w	GIF_Height,source_height
	move.w	new_imagewidth,dest_width
	move.w	new_imageheight,dest_height
	move.l	GIF_Rawdata,source_image

*-----------------------------------------------------------------------*
	elseif
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*	Copy filename									*
*-----------------------------------------------------------------------*
	lea		FILENAME,a0
	lea		gif_filename,a1
.cst:	move.b	(a0)+,(a1)+
	bne.s		.cst
*-----------------------------------------------------------------------*
*	Find file size									*
*-----------------------------------------------------------------------*
	lea		gif_filename,a0
	jsr		get_filesize
	move.l	d0,filebytes
*-----------------------------------------------------------------------*
*	Open GIF file for reading							*
*-----------------------------------------------------------------------*
	jsr		gif_openfile
*-----------------------------------------------------------------------*
*	GIF Inquire										*
*-----------------------------------------------------------------------*
	moveq		#gifcmd_inquire,d0
	move.l	filebytes,gif_filesize
	move.l	PACK_SCR,gif_filebuffer
	bsr		read_gif
*-----------------------------------------------------------------------*
*	Index start of GIF file for decoding					*
*-----------------------------------------------------------------------*
	moveq		#0,d1
	bsr		gif_index
*-----------------------------------------------------------------------*
*	Allocate space for file-buffer						*
*-----------------------------------------------------------------------*
	move.l	filebytes,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.er2
	move.l	a0,gif_filebuffer
*-----------------------------------------------------------------------*
*	Allocate space for decode-buffer						*
*-----------------------------------------------------------------------*
	move.w	gif_sd_width,d0
	mulu.w	gif_sd_height,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.er2
	move.l	a0,gif_imagebuffer
*-----------------------------------------------------------------------*
*	Decode first frame into buffer						*
*-----------------------------------------------------------------------*
	moveq		#gifcmd_decode,d0
	move.l	filebytes,gif_filesize
	move.l	PACK_SCR,gif_linebuffer
	bsr		read_gif
*-----------------------------------------------------------------------*
*	Close file										*
*-----------------------------------------------------------------------*
.er2:	jsr		gif_closefile
*-----------------------------------------------------------------------*
	lea		gif_palette,a0
	move.l	PALETTE_PTR,a1
	move.w	#256-1,d0
.cpa:	move.l	(a0)+,(a1)+
	dbra		d0,.cpa
*-----------------------------------------------------------------------*
	st		PALETTE_CHANGED
	move.w	gif_id_width,d0
	move.w	gif_id_height,d1
	bsr		GetAspect
	move.w	gif_id_width,source_width
	move.w	gif_id_height,source_height
	move.w	new_imagewidth,dest_width
	move.w	new_imageheight,dest_height
	move.l	gif_imagebuffer,source_image

*-----------------------------------------------------------------------*
	endc
*-----------------------------------------------------------------------*

	move.w	#fmat_bytepixel,source_format
	st		colours_available		
	st		avoid_editpack
	jsr		init_editbuffer
	tst.l		d0
	bmi		.err
	move.w	TAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,dest_image
	jsr		clear_page
	st		sacrifice
	jsr		CONVERT_IMAGE
	sf		sacrifice

	jsr		import
	jsr		MRELEASE
	jsr		Update_palette
	jsr		Remap_menu_bars
	st		CHANGE_MADE
	bsr		EndFrame_handler

.err	bra		END_LOAD

Load_LBM:
	move.l	#STARd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.err
	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		.err
	tst.b		ALERT
	bne		.err
	lea		FILENAME,a0
	jsr		get_filesize
	move.l	d0,filebytes
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,iff_handle
	jsr		Find_block
	move.l	a0,IFF_PTR
	lea		FILENAME,a0
	jsr		OpenFile
	tst.l		d0
	bpl.s		.c1
.stop	move.w	iff_handle,d0
	jsr		Remove_block
	bra		.err
.c1	move.w	d0,FILE_HANDLE
	move.l	IFF_PTR,a0
	move.l	filebytes,d1
	jsr		ReadFile
	move.w	FILE_HANDLE,d0
	jsr		CloseFile
	jsr		EXAMINE_IFF
	tst.l		d0
	bmi		.stop
	move.w	#fmat_bytepixel,source_format
	move.w	IFF_Width,d1
	add.w		#15,d1
	and.w		#-16,d1
	move.w	IFF_Height,d2
	move.w	IFF_Planes,d0
	cmp.w		#8,d0
	bgt.s		.true
	move.l	IFF_Type,d0
	btst		#AMIGA_HAM,d0
	beq.s		.norm
.true	add.w		d1,d1
	move.w	#fmat_wordpixel,source_format
.norm	mulu		d1,d2
	move.l	d2,d0
	move.l	d0,filebytes
	jsr		MALLOCATE_fast
	tst.l		d0	
	bmi		.stop
	move.w	d0,image_handle
	move.l	a0,IFF_image
	move.l	filebytes,d0
	jsr		memclr
	move.w	IFF_Width,d0
	add.w		#15,d0
	and.w		#-16,d0
	move.w	source_format,d3
	jsr		([length_routs.l,d3.w*4])
	move.w	d0,dest_scrwidth
	jsr		DECODE_IFF
	move.w	IFF_Width,d0
	add.w		#15,d0
	and.w		#-16,d0
	move.w	d0,IFF_Width
	move.w	iff_handle,d0
	jsr		Remove_block
	move.w	image_handle,d0
	jsr		Find_block
	move.l	a0,IFF_image
	sf		colours_available		
	cmp.w		#fmat_bytepixel,source_format
	bne.s		.no
	st		colours_available		
	move.w	IFF_Width,d0
	move.w	IFF_Height,d1
	move.l	IFF_image,a0
	jsr		BPS2BytePerPixel
.no	st		PALETTE_CHANGED
	move.w	IFF_Width,d0
	move.w	IFF_Height,d1
	bsr		GetAspect
	move.w	IFF_Width,source_width
	move.w	IFF_Height,source_height
	move.w	new_imagewidth,dest_width
	move.w	new_imageheight,dest_height
	move.l	IFF_image,source_image
	sf		avoid_editpack
	jsr		init_editbuffer
	tst.l		d0
	bmi		.err
	move.w	TAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,dest_image
	jsr		clear_page
	st		sacrifice
	jsr		CONVERT_IMAGE
	sf		sacrifice
	jsr		import
	jsr		MRELEASE
	jsr		Update_palette
	jsr		Remap_menu_bars
	st		CHANGE_MADE
	bsr		EndFrame_handler
.err	bra		END_LOAD

Load_TGA:
	IFD		READERS
	move.l	#TGAd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.err
*-----------------------------------*
*	Find file extension		*
*-----------------------------------*
	lea		FILENAME,a0
	move.w	#256-1,d0
.loop	move.b	(a0)+,d1
	beq		.err
	cmp.b		#'.',d1
	beq		.got
	dbra		d0,.loop
	bra		.err
.got	subq.l	#1,a0
	move.l	a0,sequential_name
*-----------------------------------*
*	Count digits			*
*-----------------------------------*
	moveq		#9-1,d0
	moveq		#0,d2	
.look	moveq		#0,d1
	move.b	-(a0),d1
	sub.w		#'0',d1
	bmi		.stop
	cmp.w		#9,d1
	bgt		.stop
	addq.l	#1,d2
	dbra		d0,.look	
*-----------------------------------*
*	Check for 'sequential' name	*
*-----------------------------------*
.stop	move.l	d2,sequential_digits
	bne		Load_sequential_TGA
*-----------------------------------*
*	Image is a single file		*
*-----------------------------------*
.norm	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		.err
	tst.b		ALERT
	bne		.err

	jsr		init_targabuffer
	tst.l		d0
	bmi		.err
	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,targa
	move.l	PACK_SCR,CIRCULAR_BUFFER
	jsr		read_targa
	tst.l		d0
	bmi		.err

	st		PALETTE_CHANGED
	tst.w		line_dir
	bpl.s		.c4
	st		image_inverted
.c4	move.w	targa_width,d0
	move.w	targa_height,d1
	bsr		GetAspect
	move.w	targa_width,source_width
	move.w	targa_height,source_height
	move.w	new_imagewidth,dest_width
	move.w	new_imageheight,dest_height
	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,source_image
	move.w	#fmat_wordpixel,source_format
	sf		colours_available		
	sf		avoid_editpack
	jsr		init_editbuffer
	tst.l		d0
	bmi		.err
	move.w	TAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,dest_image
	jsr		clear_page
	st		sacrifice
	jsr		CONVERT_IMAGE
	sf		sacrifice
	jsr		import

	sf		image_inverted
	jsr		Update_palette
	jsr		Remap_menu_bars
	st		CHANGE_MADE
	bsr		EndFrame_handler
	ENDC

.err:	sf		image_inverted

	move.w	BUFFER1_HANDLE,d0
	bmi.s		.err2
	jsr		Remove_block
.err2:

	bra		END_LOAD

init_targabuffer:
	move.l	PACK_SCR,CIRCULAR_BUFFER
	move.l	#FILENAME,tga_name
	jsr		examine_targa
	tst.l		d0
	bmi		.err
.c1:	move.w	targa_width,d0
	move.w	targa_height,d1
	cmp.w		#1280,d0
	ble.s		.c2
	jsr		SIZE_ERROR
	tst.b		OK_CANCEL
	bne		.err
.c2:	cmp.w		#1280,d1
	ble.s		.c2x
	jsr		SIZE_ERROR
	tst.b		OK_CANCEL
	bne		.err
.c2x:	mulu.w	d1,d0		
	add.l		d0,d0
	add.l		#256,d0
	jsr		Add_fast
	move.w	d0,BUFFER1_HANDLE
.err:	rts

Load_sequential_TGA:
	st		anim

	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		.err
	tst.b		ALERT
	bne		.err

	bsr		init_targabuffer
	tst.l		d0
	bmi		.err

	move.w	targa_width,d0
	move.w	targa_height,d1
	bsr		GetAspect
	move.w	#fmat_wordpixel,source_format
	sf		colours_available		
	move.w	targa_width,source_width
	move.w	targa_height,source_height
	move.w	new_imagewidth,dest_width
	move.w	new_imageheight,dest_height
	sf		avoid_editpack
	jsr		init_editbuffer
	tst.l		d0
	bmi		.err

.next:

	sf		image_inverted
	tst.w		line_dir
	bpl.s		.c4
	st		image_inverted
.c4:

	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,targa
	move.l	PACK_SCR,CIRCULAR_BUFFER
	jsr		read_targa
	tst.l		d0
	bne		.exit
	tst.b		Memory_error
	bne		.err
	tst.b		ALERT
	bne		.err

	st		CHANGE_MADE

	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,source_image

	move.w	TAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,dest_image

	jsr		clear_page

	jsr		CONVERT_IMAGE

	tst.b		edit
	beq.s		.done
	jsr		tab_screen
	tst.l		d0
	bmi.s		.done
.stor:
	tst.b		edit
	beq.s		.done
	jsr		dump_screen
.done:

	bsr		increment_name
	tst.l		d2
	bne		.exit

	lea		FILENAME,a0
	jsr		get_filesize
	tst.l		d0
	bmi		.exit

	move.l	PACK_SCR,CIRCULAR_BUFFER
	jsr		examine_targa
	tst.l		d0
	bmi		.exit

	move.w	targa_width,d0
	cmp.w		source_width,d0
	bne		.exit
	move.w	targa_height,d0
	cmp.w		source_height,d0
	bne		.exit

	tst.b		TERM_LOAD
	bne		.exit

	bsr		MidFrame_handler
	tst.b		Memory_error
	bne.s		.err
	tst.b		ALERT
	bne.s		.err

	jsr		Update_palette

	jsr		Remap_menu_bars
	bra		.next

.exit:
	bsr		EndFrame_handler
.err	sf		image_inverted

	move.w	BUFFER1_HANDLE,d0
	bmi.s		.err2
	jsr		Remove_block
.err2:

	bra		END_LOAD

increment_name:
	move.l	sequential_name,a0
	move.l	sequential_digits,d1
	moveq		#1,d2
	subq.l	#1,d1
.lp	moveq		#0,d0
	move.b	-(a0),d0
	add.w		d2,d0
	moveq		#0,d2
	cmp.w		#'9',d0
	ble.s		.ok
	move.w	#'0',d0
	moveq		#1,d2
.ok	move.b	d0,(a0)
	dbra		d1,.lp
	rts
	
sequential_name:		ds.l	1
sequential_digits:	ds.l	1

Load_JPG:
	IFD		READERS
	move.l	#JPGd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.err
	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		.err
	tst.b		ALERT
	bne		.err
	lea		FILENAME,a0
	jsr		get_filesize
	move.l	d0,filebytes
	move.l	PACK_SCR,jpeg
	move.w	#-1,jpeg_handle
	cmp.l		CANVAS_SIZE,d0
	ble.s		.go
	jsr		Add_normal
	tst.l		d0
	bmi		.err
	move.w	d0,jpeg_handle
	move.l	a0,jpeg	
.go	lea		FILENAME,a0
	jsr		OpenFile
	tst.l		d0
	bpl.s		.c0
	jsr		release_jpeg
	bra		.err
.c0	move.w	d0,FILE_HANDLE
	move.l	jpeg,a0
	move.l	filebytes,d1
	jsr		ReadFile
	tst.l		d0
	bpl		.c1
	bsr.s		.clos
	jsr		release_jpeg
	bra		.err

.clos	move.w	FILE_HANDLE,d0
	jsr		CloseFile
	rts

.c1	bsr.s		.clos
	lea		buffer48k,a0
	jsr		make_struct
	move.l	_JPD_struct,a0
	jsr		JPEG_opendriver
	tst.w		d0
	beq		.c4
	jsr		release_jpeg
	bra		.err
	
.c4	move.l	_JPD_struct,a0
	move.l	jpeg,JP_fileaddr(a0)
	move.l	filebytes,JP_filesize(a0)
	jsr		JPEG_getinformation
	tst.w		d0
	beq.s		.c2

.ce	bsr		close_jpeg
	jsr		release_jpeg
	bsr		TYPE_ERROR
	bra		.err		

.c2	move.l	_JPD_struct,a0
	move.w	#3,JP_type1(a0)
	move.w	#3,JP_type2(a0)
	jsr		JPEG_getsize
	tst.w		d0
	bne.s		.ce

	move.l	_JPD_struct,a0
	move.w	86(a0),targa_width
	move.w	88(a0),targa_height
	move.w	targa_width,d0
	mulu		targa_height,d0
	add.l		d0,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bpl		.c3
	bsr		close_jpeg
	bsr		release_jpeg
	bra		.err

.c3	move.w	d0,tga_handle
	move.l	a0,d0
	move.l	_JPD_struct,a0
	move.l	d0,JP_pixelbuffer(a0)
	move.l	#readcode,JP_codeslot2(a0)
	jsr		JPEG_decodeimage
	push.w	d0
	bsr		close_jpeg
	jsr		release_jpeg
	pop.w		d0
	tst.w		d0
	bne		.err
	move.w	tga_handle,d0
	jsr		Find_block
	move.l	a0,source_image
	move.w	targa_width,d0
	move.w	targa_height,d1
	bsr		GetAspect
	move.w	targa_width,source_width
	move.w	targa_height,source_height
	move.w	new_imagewidth,dest_width
	move.w	new_imageheight,dest_height
	move.w	#fmat_wordpixel,source_format
	sf		colours_available		
	sf		avoid_editpack
	jsr		init_editbuffer
	tst.l		d0
	bmi		.err
	move.w	TAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,dest_image
	jsr		clear_page
	st		sacrifice
	jsr		CONVERT_IMAGE
	sf		sacrifice
	jsr		import
	jsr		MRELEASE
	sf		image_inverted
	jsr		Update_palette
	jsr		Remap_menu_bars
	st		CHANGE_MADE
	bsr		EndFrame_handler
	ENDC
.err	bra		END_LOAD

close_jpeg:
	move.l	_JPD_struct,a0
	jsr		JPEG_closedriver
	rts

release_jpeg:
	move.w	jpeg_handle,d0
	bmi.s		.err
	jsr		Remove_block
.err	rts

Load_MTV:
	IFD		READERS
	move.l	#MTVd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.exit
	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		.exit
	tst.b		ALERT
	bne		.exit

	move.l	PACK_SCR,CIRCULAR_BUFFER
	move.l	#FILENAME,mtv_name
	jsr		examine_mtv
	tst.l		d0
	bmi		.exit

.c1	move.w	mtv_width,d0
	move.w	mtv_height,d1
	cmp.w		#1280,d0
	ble.s		.c2
	jsr		SIZE_ERROR
	tst.b		OK_CANCEL
	bne		.exit
.c2	cmp.w		#1280,d1
	ble.s		.c2x
	jsr		SIZE_ERROR
	tst.b		OK_CANCEL
	bne		.exit
.c2x	addq		#2,d1
	mulu		d1,d0		
	add.l		d0,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.exit
	move.l	a0,mtv
	jsr		read_mtv
	tst.l		d0
	bmi		.exit
.c3	st		PALETTE_CHANGED
	move.w	mtv_width,d0
	move.w	mtv_height,d1
	bsr		GetAspect
	move.w	mtv_width,source_width
	move.w	mtv_height,source_height
	move.w	new_imagewidth,dest_width
	move.w	new_imageheight,dest_height
	move.l	mtv,source_image
	move.w	#fmat_wordpixel,source_format
	sf		colours_available		
	sf		avoid_editpack
	jsr		init_editbuffer
	tst.l		d0
	bmi		.exit
	move.w	TAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,dest_image
	jsr		clear_page
	st		sacrifice
	jsr		CONVERT_IMAGE
	sf		sacrifice
	jsr		import
	jsr		MRELEASE
	jsr		Update_palette
	jsr		Remap_menu_bars
	st		CHANGE_MADE
	bsr		EndFrame_handler
	ENDC
.exit	bra		END_LOAD

Load_PCS:
	IFD		READERS
	move.l	#PCSd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.exit
	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		.exit
	tst.b		ALERT
	bne		.exit
	move.l	#200000,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.exit
	move.l	a0,.file_ptr
	move.l	#40000,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.exit
	move.l	a0,.palette_ptr
	lea		FILENAME,a0
	jsr		get_filesize
	move.l	d0,file_size
	lea		FILENAME,a0
	jsr		OpenFile
	tst.l		d0
	bmi		.exit
	move.w	d0,FILE_HANDLE
	move.l	file_size,d1
	move.l	.file_ptr,a0
	move.w	FILE_HANDLE,d0
	jsr		ReadFile
	move.w	FILE_HANDLE,d0
	jsr		CloseFile
	tst.l		d0
	bmi		.exit
	move.l	PACK_SCR,a0
	move.l	a0,BITMAP_1
	lea		32000(a0),a0
	move.l	a0,BITMAP_2
	move.l	.palette_ptr,a0
	move.l	a0,PALETTE_1
	lea		20000(a0),a0
	move.l	a0,PALETTE_2
	move.l	.file_ptr,a0
	cmp.l		#'ICE!',(a0)
	bne.s		.go
	move.l	#200000,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.exit
	move.l	a0,a1
	move.l	.file_ptr,a0
	move.l	a1,.file_ptr
	jsr		ice_decrunch
	move.l	.file_ptr,a0
.go	jsr		UNPACK_PCS
	move.l	.file_ptr,a1
	moveq		#0,d2
	move.w	#200-1,d7
.ylp	push.w	d7
	moveq		#0,d1
	move.w	#320-1,d6
.xlp	push.w	d6
	push.w	d1
	push.w	d2
	tst.w		d2
	bne.s		.ok
	moveq		#0,d1
.ok	push.l	a1
	jsr		DECODE_PCS
	pop.l		a1
	move.b	d0,(a1)+
	move.b	d1,(a1)+
	move.b	d2,(a1)+
	pop.w		d2
	pop.w		d1
	pop.w		d6
	addq		#1,d1
	dbra		d6,.xlp
	pop.w		d7
	addq		#1,d2
	dbra		d7,.ylp
	st		PALETTE_CHANGED
	move.w	mtv_width,d0
	move.w	mtv_height,d1
	bsr		GetAspect
	move.w	#320,source_width
	move.w	#200,source_height
	move.w	#320,dest_width
	move.w	#320,dest_scrwidth
	move.w	#200,dest_height
	move.l	.file_ptr,source_image
	move.w	#fmat_24bit_rgb,source_format
	sf		colours_available		
	st		sacrifice
	jsr		CONVERT_IMAGE
	sf		sacrifice
	jsr		MRELEASE
	jsr		Update_palette
	jsr		Remap_menu_bars
	st		CHANGE_MADE
	bsr		EndFrame_handler
	ENDC
.exit	bra		END_LOAD

.file_ptr		ds.l	1
.palette_ptr	ds.l	1

Load_SPU:
	IFD		READERS
	move.l	#SPUd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.exit
	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		.exit
	tst.b		ALERT
	bne		.exit
	move.l	#200000,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.exit
	move.l	a0,FREE_ADDR
	lea		FILENAME,a0
	jsr		get_filesize
	move.l	d0,file_size
	lea		FILENAME,a0
	jsr		OpenFile
	tst.l		d0
	bmi		.exit
	move.w	d0,FILE_HANDLE
	move.l	file_size,d1
	move.l	PACK_SCR,a0
	move.w	FILE_HANDLE,d0
	jsr		ReadFile
	move.w	FILE_HANDLE,d0
	jsr		CloseFile
	tst.l		d0
	bmi		.exit
	move.l	PACK_SCR,a0
	move.l	a0,SCREEN_PTR_1
	lea		32000(a0),a0
	move.l	a0,COLOUR_PTR_1
	move.l	FREE_ADDR,a1
	moveq		#0,d2
	move.w	#200-1,d7
.ylp	push.w	d7
	moveq		#0,d1
	move.w	#320-1,d6
.xlp	push.w	d6
	push.w	d1
	push.w	d2
	tst.w		d2
	bne.s		.ok
	moveq		#0,d1
.ok	push.l	a1
	jsr		DECODE_SPU
	pop.l		a1
	move.b	d0,(a1)+
	move.b	d1,(a1)+
	move.b	d2,(a1)+
	pop.w		d2
	pop.w		d1
	pop.w		d6
	addq		#1,d1
	dbra		d6,.xlp
	pop.w		d7
	addq		#1,d2
	dbra		d7,.ylp
	st		PALETTE_CHANGED
	move.w	mtv_width,d0
	move.w	mtv_height,d1
	bsr		GetAspect
	move.w	#320,source_width
	move.w	#200,source_height
	move.w	#320,dest_width
	move.w	#320,dest_scrwidth
	move.w	#200,dest_height
	move.l	FREE_ADDR,source_image
	move.w	#fmat_24bit_rgb,source_format
	sf		colours_available		
	st		sacrifice
	jsr		CONVERT_IMAGE
	sf		sacrifice
	jsr		MRELEASE
	jsr		Update_palette
	jsr		Remap_menu_bars
	st		CHANGE_MADE
	bsr		EndFrame_handler
	ENDC
.exit	bra		END_LOAD

*-----------------------------------------------------------------------*
*	ANIMATION load subroutines							*
*-----------------------------------------------------------------------*

Load_FLI:
	move.l	#FLId,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.err
	st		anim
	lea		FILENAME,a0
	bsr		OPEN_FLIC
	tst.l		d0
	bpl.s		.c1
	jsr		TYPE_ERROR
	bra		Open_error
.c1	move.w	FLC_Frames,MAXFRAME
	clr.w		CURFRAME
	not.w		LAST_CURFRAME
	st		FRAMECOUNT		
	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		.err
	tst.b		ALERT
	bne		.err
	move.w	FLC_ScrWidth,d0
	move.w	FLC_ScrHeight,d1
	bsr		GetAspect
	move.w	#fmat_bytepixel,source_format
	st		colours_available		
	move.w	FLC_ScrWidth,d0
	mulu		FLC_ScrHeight,d0
	cmp.w		#8,FLC_Depth
	beq.s		.ok
	add.l		d0,d0
	move.w	#fmat_wordpixel,source_format
	sf		colours_available		
.ok	add.l		#256,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.err
	move.w	d0,BUFFER1_HANDLE
	move.w	FLC_ScrWidth,source_width
	move.w	FLC_ScrHeight,source_height
	move.w	new_imagewidth,dest_width
	move.w	new_imageheight,dest_height
	sf		avoid_editpack
	jsr		init_editbuffer
	tst.l		d0
	bmi		.err
.next	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,FLC_ANIMBUFFER
	bsr		READ_FLIC_FRAME
	addq		#1,CURFRAME
	tst.b		Memory_error
	bne		.err
	tst.b		ALERT
	bne		.err
	st		CHANGE_MADE
	tst.b		FORCE_REMAP
	bne.s		.nskp
	move.b	FLC_ChangeMade,CHANGE_MADE
	beq.s		.stor
.nskp	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,source_image
	move.w	TAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,dest_image
	jsr		clear_page
	jsr		CONVERT_IMAGE
	tst.b		edit
	beq.s		.done
	jsr		tab_screen
	tst.l		d0
	bmi.s		.done
.stor	tst.b		edit
	beq.s		.done
	jsr		dump_screen
.done	tst.b		FLC_MoreToCome
	beq.s		.exit
	tst.b		TERM_LOAD
	bne		.exit
	bsr		MidFrame_handler
	tst.b		Memory_error
	bne.s		.err
	tst.b		ALERT
	bne.s		.err
	jsr		Update_palette
	jsr		Remap_menu_bars
	bra		.next
.exit	bsr		EndFrame_handler
.err	bsr		CLOSE_FLC
	bra		END_LOAD
Open_error:
	bsr		CLOSE_FLC
	bra		END_LOAD
Memory_full:
	bra		END_LOAD

Load_ANM:
	move.l	#ANMd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.err
	st		anim
	move.w	#1,MAXFRAME			*
	clr.w		CURFRAME
	not.w		LAST_CURFRAME
	st		FRAMECOUNT		
	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		.err
	tst.b		ALERT
	bne		.err
	move.l	#200000,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.err
	move.w	d0,BUFFER2_HANDLE
	jsr		OPEN_ANIM
	tst.l		d0
	bpl.s		.c1
	jsr		TYPE_ERROR
	bra		.err
.c1	move.w	IFF_Width,d0
	move.w	source_format,d3
	jsr		([length_routs.l,d3.w*4])
	mulu		IFF_Height,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.err
	move.w	d0,BUFFER1_HANDLE
	move.w	IFF_Width,d0
	move.w	IFF_Height,d1
	bsr		GetAspect
	move.w	IFF_Width,source_width
	move.w	IFF_Height,source_height
	move.w	new_imagewidth,dest_width
	move.w	new_imageheight,dest_height
	sf		colours_available		
	sf		avoid_editpack
	jsr		init_editbuffer
	tst.l		d0
	bmi		.err
.next	jsr		DECODE_ANIM_FRAME
	st		CHANGE_MADE
	tst.l		d0
	bmi		.exit
	addq		#1,CURFRAME
	tst.b		Memory_error
	bne		.err
	tst.b		ALERT
	bne		.err
	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,source_image
	move.w	TAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,dest_image
	jsr		clear_page
	st		sacrifice
	jsr		CONVERT_IMAGE
	sf		sacrifice
	tst.b		edit
	beq.s		.done
	jsr		tab_screen
	tst.l		d0
	bmi.s		.done
.stor	tst.b		edit
	beq.s		.done
	jsr		dump_screen
.done	tst.b		anim_done			*
	bne.s		.exit
	bsr		MidFrame_handler
	tst.b		Memory_error
	bne.s		.err
	tst.b		ALERT
	bne.s		.err
	jsr		Update_palette
	jsr		Remap_menu_bars
	tst.b		TERM_LOAD
	beq		.next
.exit	bsr		EndFrame_handler
.err	bsr		CLOSE_ANIM
	bra		END_LOAD

Load_SEQ:
	move.l	#SEQd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		SEQ_error
	st		anim
	lea		FILENAME,a0
	bsr		OPEN_SEQ
	tst.l		d0
	bpl.s		.c1
	jsr		TYPE_ERROR
	bra		SEQ_error
.c1	move.w	FLC_Frames,MAXFRAME
	clr.w		CURFRAME
	not.w		LAST_CURFRAME
	st		FRAMECOUNT		
	bsr		StrtFrame_handler
	tst.b		Memory_error
	bne		SEQ_error
	tst.b		ALERT
	bne		SEQ_error
	move.l	#(320*200)+256,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		SEQ_error
	move.w	d0,BUFFER1_HANDLE
	move.l	a0,FLC_ANIMBUFFER
	move.l	#(320*200),d0
	jsr		memclr
	move.w	#320,source_width
	move.w	#200,source_height
	move.w	#320,dest_width
	move.w	#200,dest_height
	move.w	#fmat_bytepixel,source_format
	st		colours_available		
	sf		avoid_editpack
	jsr		init_editbuffer
	tst.l		d0
	bmi		SEQ_error
.next	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,FLC_ANIMBUFFER
	bsr		READ_SEQ_FRAME
	addq		#1,CURFRAME
	tst.b		Memory_error
	bne		SEQ_error
	tst.b		ALERT
	bne		SEQ_error
	st		CHANGE_MADE
	tst.b		FORCE_REMAP
	bne.s		.nskp
	move.b	FLC_ChangeMade,CHANGE_MADE
	beq.s		.stor
.nskp	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,source_image
	move.w	TAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,dest_image
	jsr		clear_page
	jsr		CONVERT_IMAGE
	tst.b		edit
	beq.s		.done
	jsr		tab_screen
	tst.l		d0
	bmi.s		.done
.stor	tst.b		edit
	beq.s		.done
	jsr		dump_screen
.done	tst.b		FLC_MoreToCome
	beq.s		.exit
	bsr		MidFrame_handler
	tst.b		Memory_error
	bne.s		SEQ_error
	tst.b		ALERT
	bne.s		SEQ_error
	jsr		Update_palette
	jsr		Remap_menu_bars
	tst.b		TERM_LOAD
	beq		.next
.exit	bsr		EndFrame_handler
SEQ_error:
	bsr		CLOSE_SEQ
	bra		END_LOAD

*-----------------------------------------------------------------------*
*	MISC load subroutines								*
*-----------------------------------------------------------------------*

Load_BLK:
	move.l	#BLKd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.err
	jsr		Find_brush
	lea		FILENAME,a0
	bsr		OpenFile
	tst.l		d0
	bmi		.err
	move.w	d0,FILE_HANDLE
	moveq		#12+4+4,d1
	move.l	PACK_SCR,a0
	clr.l		(a0)
	bsr		ReadFile
	tst.l		d0
	bpl.s		.cont
.clos	move.w	FILE_HANDLE,d0
	bsr		CloseFile
	bra		.err
.cont	move.l	PACK_SCR,a0
	cmp.l		#'8Pla',(a0)+
	beq		.plan
	cmp.l		#'Byte',-4(a0)
	beq		.byte
	cmp.l		#'Word',-4(a0)
	beq.s		.word
	jsr		TYPE_ERROR
	bra.s		.clos
.word	tst.b		TRUE_FLAG
	bne.s		.c2
	jsr		MODE_ERROR
	bra		.clos
.c2	addq.l	#8,a0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	d1,File_Width
	move.w	d2,File_Height
	move.w	(a0)+,BRUSH_XBASE
	move.w	(a0)+,BRUSH_YBASE
	mulu		d2,d1
	add.l		d1,d1
	move.l	d1,BRUSH_SIZE
	move.w	File_Width,d1
	move.w	File_Height,d2
	jsr		Resize_brush
	tst.l		d0
	bmi		.err
	jsr		Find_brush
	move.w	File_Width,(a0)+
	move.w	File_Height,(a0)+
	move.w	FILE_HANDLE,d0
	move.l	BRUSH_SIZE,d1
	bsr		ReadFile
	bra		.clos
.plan	tst.b		TRUE_FLAG
	beq.s		.c4
	jsr		MODE_ERROR
	bra		.clos
.c4	addq.l	#8,a0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	d1,File_Width
	move.w	d2,File_Height
	move.w	(a0)+,BRUSH_XBASE
	move.w	(a0)+,BRUSH_YBASE
	add.w		#15,d1
	and.w		#-16,d1
	mulu		d2,d1
	lsr.l		#3,d1
	mulu.l	#9,d1
	add.l		#768,d1
	move.l	d1,BRUSH_SIZE
	move.w	File_Width,d1
	move.w	File_Height,d2
	jsr		Resize_brush
	tst.l		d0
	bmi		.err
	jsr		Find_brush
	move.w	File_Width,(a0)+
	move.w	File_Height,(a0)+
	move.w	FILE_HANDLE,d0
	move.l	BRUSH_SIZE,d1
	bsr		ReadFile
	bra		.clos
.byte	tst.b		TRUE_FLAG
	beq		.c3
	jsr		MODE_ERROR
	bra		.clos
.c3	addq.l	#8,a0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	d1,File_Width
	move.w	d2,File_Height
	move.w	(a0)+,BRUSH_XBASE
	move.w	(a0)+,BRUSH_YBASE
	mulu		d2,d1
	add.l		#768,d1
	move.l	d1,BRUSH_SIZE
	move.l	d1,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.clos
	move.w	d0,BUFFER1_HANDLE
	move.w	FILE_HANDLE,d0
	move.l	BRUSH_SIZE,d1
	bsr		ReadFile
	move.w	File_Width,d1
	move.w	File_Height,d2
	jsr		Resize_brush
	tst.l		d0
	bmi.s		.err
	jsr		Find_brush
	move.l	a0,a1
	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.w	File_Width,(a1)+
	move.w	File_Height,(a1)+
	move.w	#256-1,d0
.clp	move.w	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	dbra		d0,.clp
	bsr		CONVERT_BYTES_2_PLANES	
	jsr		MAKE_BLOCKMASK
	bra		.clos
.err	bra		END_LOAD

Load_MCL:
	move.l	#MCLd,DIRSPEC
	bsr		SELECT_A_FILE
	tst.b		File_error
	bne		.exit
	move.l	#max_handles*guide_len,d0
	move.l	d0,filebytes
	lea		FILENAME,a0
	jsr		OpenFile
	tst.l		d0
	bmi		.exit
	move.w	d0,FILE_HANDLE
	moveq		#18,d1
	sub.l		d1,filebytes
	lea		MCL_header,a0
	jsr		ReadFile
	cmp.l		#'Morp',MCL_header
	bne		.stop
	lea		MORPH_BUFFER,a0
	move.l	filebytes,d1
	move.w	FILE_HANDLE,d0
	jsr		ReadFile
	move.w	COUNT_WORD,GUIDE_COUNT
	move.w	START_WORD,FIRST_GUIDE
	move.w	SELECTED_WORD,GUIDE_SELECTED
	move.w	CANVAS_WIDTH,d4
	move.w	X_WORD,d5
	move.w	CANVAS_HEIGHT,d6
	move.w	Y_WORD,d7
	move.w	FIRST_GUIDE,d0
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
	move.l	a0,a1
.loop	move.w	guide_x1_1(a0),d1
	mulu		d4,d1
	divu		d5,d1
	move.w	d1,guide_x1_1(a0)
	move.w	guide_x2_1(a0),d1
	mulu		d4,d1
	divu		d5,d1
	move.w	d1,guide_x2_1(a0)
	move.w	guide_x1_2(a0),d1
	mulu		d4,d1
	divu		d5,d1
	move.w	d1,guide_x1_2(a0)
	move.w	guide_x2_2(a0),d1
	mulu		d4,d1
	divu		d5,d1
	move.w	d1,guide_x2_2(a0)
	move.w	guide_y1_1(a0),d1
	mulu		d6,d1
	divu		d7,d1
	move.w	d1,guide_y1_1(a0)
	move.w	guide_y2_1(a0),d1
	mulu		d6,d1
	divu		d7,d1
	move.w	d1,guide_y2_1(a0)
	move.w	guide_y1_2(a0),d1
	mulu		d6,d1
	divu		d7,d1
	move.w	d1,guide_y1_2(a0)
	move.w	guide_y2_2(a0),d1
	mulu		d6,d1
	divu		d7,d1
	move.w	d1,guide_y2_2(a0)
	move.w	guide_next(a0),d0
	bmi.s		.stop
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
	bra.s		.loop
.stop	move.w	FILE_HANDLE,d0
	jsr		CloseFile
.exit	bra		END_LOAD

*-----------------------------------------------------------------------*
*	SAVE routines									*
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
SAVE_FILE:
*-----------------------------------------------------------------------*
	move.b	#1,BUSY
	clr.b		ALERT
	clr.b		Memory_error
	move.l	sp,LOAD_STACK
	move.l	#SELECTOR_MSAVE,SELECTOR_MESSAGE
	jsr		HIDE_MOUSE
*-----------------------------------------------------------------------*
	jsr		Get_changes
	tst.l		d0
	bmi		END_SAVE
*-----------------------------------------------------------------------*
	
	IFD		WRITERS
	move.w	DISKTYP1_BITS,d0
	btst		#Bit_DISKTYP1_LBM,d0
	bne		Save_IFF
	btst		#Bit_DISKTYP1_GIF,d0
	bne		Save_GIF
	btst		#Bit_DISKTYP1_TGA,d0
	bne		Save_TGA
	btst		#Bit_DISKTYP1_MTV,d0
	bne		Save_MTV
	btst		#Bit_DISKTYP1_FLI,d0
	bne		Save_FLC
	btst		#Bit_DISKTYP1_BLK,d0
	bne		Save_BLK
	btst		#Bit_DISKTYP1_DAC,d0
	bne		Save_DAC
	btst		#Bit_DISKTYP1_CTL,d0
	bne		Save_MCL
	ENDC

END_SAVE:
	sf		FRAMECOUNT
	jsr		Refresh_info_bar
	jsr		Redraw_menu_icons
	jsr		Superscaler
	jsr		MRELEASE
	move.l	LOAD_STACK,sp
	clr.w		DISKFUNC_BITS
	jsr		SHOW_MOUSE
	sf		ALERT
	clr.b		BUSY
	rts

Save_MCL:
	IFD		WRITERS
	move.l	#MCLd,DIRSPEC
	bsr		SELECT_A_FILE
	move.l	DIRSPEC,a0
	jsr		Force_extension
	tst.b		File_error
	bne		.exit
	tst.w		GUIDE_COUNT
	bgt.s		.ok
	lea		WIN_CFG_Alert,a0
	jsr		DO_ALERT
	bra		.exit
.ok	lea		FILENAME,a0
	jsr		CreateFile
	tst.l		d0
	bmi		.exit
	move.w	d0,FILE_HANDLE
	move.w	CANVAS_WIDTH,X_WORD
	move.w	CANVAS_HEIGHT,Y_WORD
	move.w	GUIDE_COUNT,COUNT_WORD
	move.w	FIRST_GUIDE,START_WORD
	move.w	GUIDE_SELECTED,SELECTED_WORD
	lea		MCL_header,a0
	moveq		#18,d1
	move.w	FILE_HANDLE,d0
	jsr		WriteFile
	tst.l		d0
	bmi.s		.err
	lea		MORPH_BUFFER,a0
	move.l	#max_handles*guide_len,d1
	move.w	FILE_HANDLE,d0
	jsr		WriteFile
.err	move.w	FILE_HANDLE,d0
	jsr		CloseFile
	ENDC
.exit	bra		END_SAVE

MCL_header:
	dc.b		'MorphCTL'
X_WORD:
	ds.w		1
Y_WORD:
	ds.w		1
COUNT_WORD:
	ds.w		1
START_WORD:
	ds.w		1
SELECTED_WORD:
	ds.w		1
	
*-----------------------------------------------------------------------*
*	ANIMATION save subroutines							*
*-----------------------------------------------------------------------*

Save_FLC:
	IFD		WRITERS

;	jsr		Get_changes
;	tst.l		d0
;	bmi		END_SAVE

	move.l	#FLHd,DIRSPEC
	tst.b		TRUE_FLAG
	bne.s		.tc
	move.l	#FLCd,DIRSPEC
.tc	bsr		SELECT_A_FILE
	move.l	DIRSPEC,a0
	jsr		Force_extension
	tst.b		File_error
	bne		.err
*-----------------------------------*
	moveq		#1,d0
	moveq		#1,d1
	tst.b		TRUE_FLAG
	bne.s		.bp
	moveq		#2,d0
	moveq		#1,d1
.bp:	bsr		cut_handler
	tst.w		d0
	beq		.err
*-----------------------------------*
	sf		anim
*-----------------------------------*
	jsr		get_range
	moveq		#default2all,d0
	jsr		init_tween
	tst.l		d0
	bmi		.err
	move.w	TWEEN_END,d0
	sub.w		TWEEN_START,d0
	bpl.s		.abs
	neg.w		d0
.abs	addq		#1,d0
	clr.w		CURFRAME
	move.w	d0,MAXFRAME
	move.w	d0,FLC_Frames
*-----------------------------------*
	lea		FILENAME,a0
	jsr		CREATE_FLIC
	tst.l		d0
	bmi		.err
*-----------------------------------*
	move.w	TWEEN_START,d0
	jsr		Frame_goto
	not.w		LAST_CURFRAME
	st		FRAMECOUNT		
*-----------------------------------*
	move.w	FLC_ScrWidth,d0
	move.w	FLC_ScrHeight,d1
	bsr		GetAspect
*-----------------------------------*
.next:
*-----------------------------------*
	jsr		WRITE_FLIC_FRAME
*-----------------------------------*
	jsr		advance_tween
	tst.l		d0
	bmi.s		.stop
	tst.b		ABORT_TWEEN
	bne.s		.stop
	tst.b		TWEEN_FLAG
	beq.s		.stop
	tst.b		Memory_error
	bne.s		.stop
	tst.b		ALERT
	beq.s		.next
*-----------------------------------*
.stop	move.w	TWEEN_START,d0
	jsr		Frame_goto
	jsr		WRITE_FLIC_FRAME
	clr.w		CURFRAME
	jsr		UPDATE_FLC
	st		TWEEN_FLAG
	jsr		reset_tween
	ENDC
.err	bra		END_SAVE

*-----------------------------------------------------------------------*
*	Convert brush to bytepixel/wordpixel and write to disk as 'BLK'	*
*-----------------------------------------------------------------------*
	
Save_BLK:
	IFD		WRITERS
	move.l	#BLKd,DIRSPEC
	bsr		SELECT_A_FILE
	move.l	DIRSPEC,a0
	jsr		Force_extension
	tst.b		File_error
	bne		.exit
	move.w	BRUSH_HANDLE,d0
	jsr		Find_block
	move.w	(a0)+,File_Width
	move.w	(a0)+,File_Height
	tst.b		TRUE_FLAG
	beq		.ntc
.true	lea		FILENAME,a0
	bsr		CreateFile
	tst.l		d0
	bmi		.exit
	move.w	d0,FILE_HANDLE
	lea		WordPixel_header+12,a0
	move.w	File_Width,(a0)+
	move.w	File_Height,(a0)+
	move.w	BRUSH_XBASE,(a0)+
	move.w	BRUSH_YBASE,(a0)+
	lea		WordPixel_header,a0
	moveq		#12+4+4,d1
	move.w	FILE_HANDLE,d0
	bsr		WriteFile
	tst.l		d0
	bmi		.clos
	move.w	BRUSH_HANDLE,d0
	jsr		Find_brush
	addq.l	#4,a0
	move.w	File_Width,d1
	mulu		File_Height,d1
	add.l		d1,d1
	move.w	FILE_HANDLE,d0
	bsr		WriteFile
	bra		.clos
.bpln	lea		FILENAME,a0
	bsr		CreateFile
	tst.l		d0
	bmi		.exit
	move.w	d0,FILE_HANDLE
	lea		PlanPixel_header+12,a0
	move.w	File_Width,(a0)+
	move.w	File_Height,(a0)+
	move.w	BRUSH_XBASE,(a0)+
	move.w	BRUSH_YBASE,(a0)+
	lea		PlanPixel_header,a0
	moveq		#12+8,d1
	move.w	FILE_HANDLE,d0
	bsr		WriteFile
	tst.l		d0
	bmi		.clos
	lea		COLOURS,a0
	move.l	PACK_SCR,a1
	move.w	#256-1,d0
.cclp	addq		#1,a0
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	dbra		d0,.cclp
	move.l	PACK_SCR,a0
	move.l	#768,d1
	move.w	FILE_HANDLE,d0
	bsr		WriteFile
	tst.l		d0
	bmi		.clos
	move.w	BRUSH_HANDLE,d0
	jsr		Find_brush
	lea		768+4(a0),a0
	move.w	File_Width,d1
	add.w		#15,d1
	and.w		#-16,d1
	mulu		File_Height,d1
	lsr.l		#3,d1
	mulu.l	#9,d1
	move.w	FILE_HANDLE,d0
	bsr		WriteFile
	bra		.clos
.ntc	move.w	FLAG_BITS,d0
	and.w		#1<<Bit_FLAG_BITPLANES,d0
	bne		.bpln
.bpix	move.w	File_Width,d1
	mulu		File_Height,d1
	add.l		#12+4+4+768,d1
	move.l	d1,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.exit
	move.w	d0,BUFFER1_HANDLE
	lea		FILENAME,a0
	bsr		CreateFile
	tst.l		d0
	bmi		.exit
	move.w	d0,FILE_HANDLE
	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,a1
	lea		BytePixel_header,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	File_Width,(a1)+
	move.w	File_Height,(a1)+
	move.w	BRUSH_XBASE,(a1)+
	move.w	BRUSH_YBASE,(a1)+
	lea		COLOURS,a0
	move.w	#256-1,d0
.col	addq.l	#1,a0
	move.b	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	dbra		d0,.col
	push.l	a1
	jsr		Find_brush
	pop.l		a1
	add.l		#768+4,a0
	bsr		CONVERT_PLANES_2_BYTES
	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.w	File_Width,d1
	mulu		File_Height,d1
	add.l		#12+4+4+768,d1
	move.w	FILE_HANDLE,d0
	bsr		WriteFile
	tst.l		d0
	bpl.s		.cont
.clos	move.w	FILE_HANDLE,d0
	bsr		CloseFile
	bra.s		.exit
.cont	bra.s		.clos
	ENDC
.exit	bra		END_SAVE

*-----------------------------------------------------------------------*
*	Convert image to bitplanes and write to disk as 'GIF'			*
*-----------------------------------------------------------------------*

Save_GIF:
	IFD		WRITERS

;	jsr		Get_changes
;	tst.l		d0
;	bmi		END_SAVE

	move.l	#GIFd,DIRSPEC
	bsr		SELECT_A_FILE
	move.l	DIRSPEC,a0
	jsr		Force_extension
	tst.b		File_error
	bne		.exit

	moveq		#1,d0
	moveq		#1,d1
	bsr		cut_handler
	tst.w		d0
	beq		.exit

	tst.b		TRUE_FLAG
	bne.s		.true
.bpl	move.l	#COLOURS,GIFPAL_P
	move.l	LOG_SCR,GIFPIC_P
	bra		.save
.true	move.w	CANVAS_WIDTH,d0
	add.w		#15,d0
	and.w		#-16,d0
	mulu		CANVAS_HEIGHT,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.exit
	move.l	a0,dest_image
	move.l	a0,GIFPIC_P
	move.l	#NEW_COLOURS,GIFPAL_P
	move.l	LOG_SCR,source_image
	move.l	#COLOURS,source_palette
	move.l	#COLOURS,alt_palette
	move.l	#NEW_COLOURS,dest_palette

	move.w	CANVAS_WIDTH,source_width
	move.w	CANVAS_HEIGHT,source_height

	move.w	CANVAS_WIDTH,dest_width
	move.w	CANVAS_HEIGHT,dest_height	
	move.w	CANVAS_WIDTH,dest_scrwidth
	move.b	#logic_replace,logic_operation
	move.b	#make_new,palette_mode
	move.w	#fmat_wordpixel,source_format
	move.w	#fmat_bitplane,dest_format
	jsr		create_histogram
	tst.l		d0
	bmi		.exit
	jsr		REDUCE_COLOURMAP
	jsr		remove_histogram
.save	move.l	PACK_SCR,a0
	jsr		Init_GIF_Writer	
	move.l	#FILENAME,GIF_NAME

	move.w	CANVAS_WIDTH,gif_linewidth
	move.w	CUT_WIDTH,GIFWIDTH
	move.w	CUT_HEIGHT,GIFHEIGHT
	move.w	CUT_X,gif_xoff
	move.w	CUT_Y,gif_yoff
	sf		transparent_flag
	sf		interlace_flag
	clr.b		bgcolour
	clr.b		disposal
	clr.l		gif_delay

	move.w	CANVAS_WIDTH,d0
	move.w	CANVAS_HEIGHT,d1
	move.l	GIFPIC_P,a0
	jsr		BPS2BytePerPixel

	jsr		open_gif
	jsr		append_gif
	jsr		close_gif

	jsr		COPY_FRAME_2_LOG
	

	ENDC
.exit	bra		END_SAVE

*-----------------------------------------------------------------------*
*	Convert image to bitplanes and write to disk as 'IFF'			*
*-----------------------------------------------------------------------*

Save_IFF:
	IFD		WRITERS

;	jsr		Get_changes
;	tst.l		d0
;	bmi		END_SAVE

	move.l	#STARd,DIRSPEC
	bsr		SELECT_A_FILE
	lea		IFFd,a0
	jsr		Force_extension
	tst.b		File_error
	bne		.exit
	lea		FILENAME,a0
	jsr		CreateFile
	tst.l		d0
	bmi		.exit
	move.w	d0,FILE_HANDLE
	move.l	PACK_SCR,a0
	move.l	#'FORM',(a0)+
	move.w	CANVAS_WIDTH,d0
	tst.b		TRUE_FLAG
	beq.s		.nt1
	mulu		#3,d0
	mulu		CANVAS_HEIGHT,d0
	add.l		#4+20+8+8,d0
	bra.s		.g1
.nt1	mulu		CANVAS_HEIGHT,d0
	add.l		#4+20+8+768+8+8,d0
.g1	move.l	d0,(a0)+
	move.l	#'ILBM',(a0)+
	move.l	#'BMHD',(a0)+
	move.l	#20,(a0)+
	move.w	CANVAS_WIDTH,(a0)+
	move.w	CANVAS_HEIGHT,(a0)+
	clr.w		(a0)+
	clr.w		(a0)+
	tst.b		TRUE_FLAG
	beq.s		.nt2
	move.b	#24,(a0)+
	bra.s		.g2
.nt2	move.b	#8,(a0)+
.g2	clr.b		(a0)+
	clr.b		(a0)+
	clr.b		(a0)+
	clr.w		(a0)+
	move.w	CANVAS_HEIGHT,d0
	swap		d0
	clr.w		d0
	move.w	CANVAS_WIDTH,d1
	ext.l		d1
	divu.l	d1,d0
	mulu.l	#10,d0
	swap		d0
	move.b	d0,(a0)+	
	move.b	#11,(a0)+
	move.w	CANVAS_WIDTH,(a0)+
	move.w	CANVAS_HEIGHT,(a0)+
	tst.b		TRUE_FLAG
	bne.s		.nt3
	move.l	#'CMAP',(a0)+
	move.l	#768,(a0)+
	lea		COLOURS,a1
	move.w	#256-1,d0
.cclp	addq		#1,a1
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	dbra		d0,.cclp
.nt3	move.l	#'BODY',(a0)+
	move.w	CANVAS_WIDTH,d0
	move.l	#4+8+20+8+768+8+8,d1
	tst.b		TRUE_FLAG
	beq.s		.nt4
	move.l	#4+8+20+8+8,d1
	mulu		#3,d0
.nt4	mulu		CANVAS_HEIGHT,d0
	move.l	d0,(a0)+
	move.l	PACK_SCR,a0
	move.w	FILE_HANDLE,d0
	jsr		WriteFile
	tst.l		d0
	bmi		.clos
	tst.b		TRUE_FLAG
	bne.s		.true
.bpl	move.l	LOG_SCR,a0
	move.l	PACK_SCR,a1
	move.w	CANVAS_HEIGHT,d2
	subq		#1,d2
.ylp	move.l	a0,a3
	add.w		logwid,a0
	moveq		#8-1,d1
.plp	move.l	a3,a2
	addq.l	#2,a3
	move.w	CANVAS_WIDTH,d0
	lsr.w		#4,d0
	subq		#1,d0
.wlp	move.w	(a2),(a1)+
	lea		16(a2),a2
	dbra		d0,.wlp
	dbra		d1,.plp
	dbra		d2,.ylp
	move.l	PACK_SCR,a0
	move.w	FILE_HANDLE,d0
	move.w	CANVAS_WIDTH,d1
	mulu		CANVAS_HEIGHT,d1
	jsr		WriteFile
	bra		.clos
.true	move.l	LOG_SCR,a0
	move.w	CANVAS_HEIGHT,d7
	subq		#1,d7
.ylp2	move.l	PACK_SCR,a1
	moveq		#12,d3	; shifter
	moveq		#5,d4		; planes
	move.w	#3,d5		; pad
	bsr		.make_element
	moveq		#6,d3		; shifter
	moveq		#6,d4		; planes
	move.w	#2,d5		; pad
	bsr		.make_element
	moveq		#1,d3		; shifter
	moveq		#5,d4		; planes
	move.w	#3,d5		; pad
	bsr		.make_element
	add.w		logwid,a0
	pushall
	move.w	FILE_HANDLE,d0
	move.w	CANVAS_WIDTH,d1
	mulu		#3,d1
	move.l	PACK_SCR,a0
	jsr		WriteFile
	tst.l		d0
	bpl.s		.ok
	popall
	bra.s		.clos
.ok	popall
	dbra		d7,.ylp2
.clos	move.w	FILE_HANDLE,d0
	jsr		CloseFile
	ENDC
.exit	bra		END_SAVE

.make_element
	move.w	CANVAS_WIDTH,d6
	lsr.w		#4,d6
	mulu		d5,d6
	subq		#1,d6
.xlp2	clr.w		(a1)+
	dbra		d6,.xlp2
	subq		#1,d4
.plp2	move.l	a0,a2
	move.w	CANVAS_WIDTH,d6
	lsr.w		#4,d6
	subq		#1,d6
.xlp	moveq		#16-1,d5
.blp	move.w	(a2)+,d0
	lsr.w		d3,d0
	addx.w	d1,d1
	dbra		d5,.blp
	move.w	d1,(a1)+
	dbra		d6,.xlp
	addq		#1,d3
	dbra		d4,.plp2
	rts

*-----------------------------------------------------------------------*
*	Convert image to 24-bit BGR and write to disk as 'TGA' type #2	*
*-----------------------------------------------------------------------*

Save_TGA:
	IFD		WRITERS

;	jsr		Get_changes
;	tst.l		d0
;	bmi		END_SAVE


	move.l	#TGAd,DIRSPEC
	bsr		SELECT_A_FILE
	move.l	DIRSPEC,a0
	jsr		Force_extension
	tst.b		File_error
	bne		.exit

	moveq		#1,d0
	moveq		#1,d1
	tst.b		TRUE_FLAG
	bne.s		.tr
	moveq		#16,d0
	moveq		#16,d1
.tr:	bsr		cut_handler
	tst.w		d0
	beq		.exit	

	lea		FILENAME,a0
	bsr		CreateFile
	tst.l		d0
	bmi		.oerr
	move.w	d0,FILE_HANDLE

	move.l	PACK_SCR,a0

	move.b	#0,tga_id_len(a0)
	move.b	#0,tga_cmap_type(a0)
	move.b	#2,tga_image_type(a0)
	move.w	#0,tga_cmap_origin(a0)	
	move.w	#0,tga_cmap_length(a0)	
	move.b	#0,tga_cmap_bits(a0)	
	move.b	#24,tga_pixsize(a0)
	move.b	#0,tga_imgdesc(a0)
	clr.w		tga_xpos(a0)
	clr.w		tga_ypos(a0)
	move.w	CUT_WIDTH,d0
	ror.w		#8,d0
	move.w	d0,tga_width(a0)
	move		CUT_HEIGHT,d0
	ror.w		#8,d0
	move.w	d0,tga_height(a0)

	move.l	PACK_SCR,a0
	moveq		#18,d1
	move.w	FILE_HANDLE,d0
	bsr		WriteFile
	tst.l		d0
	bmi		.clos

	move.l	#8192,d0			; linebuffer
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.exit
	move.l	a0,dest_image

	move.l	LOG_SCR,a0
	move.w	CUT_Y,d0
	mulu.w	CANVAS_WIDTH,d0
	move.w	CUT_X,d1
	ext.l		d1
	add.l		d1,d0
	tst.b		TRUE_FLAG
	beq.s		.nt
	add.l		d0,d0
.nt:	add.l		d0,a0
	move.l	a0,source_image

	move.l	#COLOURS,source_palette
	move.l	#COLOURS,alt_palette
	move.l	#NEW_COLOURS,dest_palette
	move.w	CANVAS_WIDTH,source_width
	move.w	CUT_HEIGHT,source_height
	move.w	CUT_WIDTH,dest_width
	move.w	CUT_HEIGHT,dest_height	
	move.w	CUT_WIDTH,dest_scrwidth
	move.b	#logic_replace,logic_operation
	move.b	#use_new,palette_mode
	move.w	#fmat_bitplane,source_format
	tst.b		TRUE_FLAG
	beq.s		.bpl
	move.w	#fmat_wordpixel,source_format
.bpl	move.w	#fmat_24bit_bgr,dest_format
	st		output_image
	st		image_inverted
	jsr		REDUCE_COLOURMAP
	sf		image_inverted
	sf		output_image
	bra		.clos
.oerr	bra		.exit
.clos	move.w	FILE_HANDLE,d0
	bsr		CloseFile
	ENDC
.exit	bra		END_SAVE

*-----------------------------------------------------------------------*
*	Convert image to 24-bit RGB and write to disk as 'MTV/RAW' 		*
*-----------------------------------------------------------------------*

Save_MTV:
	IFD		WRITERS

;	jsr		Get_changes
;	tst.l		d0
;	bmi		END_SAVE

	move.l	#MTVd,DIRSPEC
	bsr		SELECT_A_FILE
	move.l	DIRSPEC,a0
	jsr		Force_extension
	tst.b		File_error
	bne		.exit
	lea		FILENAME,a0
	bsr		CreateFile
	tst.l		d0
	bmi		.oerr
	move.w	d0,FILE_HANDLE
	clr.l		file_size
	move.w	CANVAS_WIDTH,d0
	ext.l		d0
	jsr		NUM2ASCII
	lea		NUM_TEXT,a1
	moveq		#0,d7
	move.b	(a1)+,d7
	subq		#1,d7
	move.l	PACK_SCR,a0
.lp	move.b	(a1)+,(a0)+
	addq.l	#1,file_size
	dbra		d7,.lp
	move.b	#' ',(a0)+
	addq.l	#1,file_size
	push.l	a0
	move.w	CANVAS_HEIGHT,d0
	ext.l		d0
	jsr		NUM2ASCII
	pop.l		a0
	lea		NUM_TEXT,a1
	moveq		#0,d7
	move.b	(a1)+,d7
	subq		#1,d7
.lp2	move.b	(a1)+,(a0)+
	addq.l	#1,file_size
	dbra		d7,.lp2
	move.b	#10,(a0)+
	addq.l	#1,file_size
	move.l	PACK_SCR,a0
	move.l	file_size,d1
	move.w	FILE_HANDLE,d0
	bsr		WriteFile
	tst.l		d0
	bmi		.clos
	move.l	#8192,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.exit
	move.l	a0,dest_image
	move.l	LOG_SCR,source_image
	move.l	#COLOURS,source_palette
	move.l	#COLOURS,alt_palette
	move.l	#NEW_COLOURS,dest_palette
	move.w	CANVAS_WIDTH,source_width
	move.w	CANVAS_HEIGHT,source_height
	move.w	CANVAS_WIDTH,dest_width
	move.w	CANVAS_HEIGHT,dest_height	
	move.w	CANVAS_WIDTH,dest_scrwidth
	move.b	#logic_replace,logic_operation
	move.b	#use_new,palette_mode
	move.w	#fmat_bitplane,source_format
	tst.b		TRUE_FLAG
	beq.s		.bpl
	move.w	#fmat_wordpixel,source_format
.bpl	move.w	#fmat_24bit_rgb,dest_format
	st		output_image
	jsr		REDUCE_COLOURMAP
	sf		output_image
	bra		.clos
.oerr	bra		.exit
.clos	move.w	FILE_HANDLE,d0
	bsr		CloseFile
	ENDC
.exit	bra		END_SAVE

Save_DAC:
	IFD		WRITERS
	move.l	#DACd,DIRSPEC
	bsr		SELECT_A_FILE
	move.l	DIRSPEC,a0
	jsr		Force_extension
	tst.b		File_error
	bne		.exit
	lea		FILENAME,a0
	jsr		CreateFile
	tst.l		d0
	bmi.s		.exit
	move.w	d0,FILE_HANDLE
	move.l	#1024,d1
	lea		COLOURS,a0
	move.w	FILE_HANDLE,d0
	jsr		WriteFile
	move.w	FILE_HANDLE,d0
	jsr		CloseFile
	ENDC
.exit	bra		END_SAVE

*-----------------------------------------------------------------------*
*	Find rescale-ratio								*
*-----------------------------------------------------------------------*

*-----------------------------*
GetAspect:
*-----------------------------*
;	d0	x-size
;	d1	y-size
*-----------------------------*
	move.w	d0,old_imagewidth
	move.w	d1,old_imageheight
	move.w	CANVAS_WIDTH,d2
	move.w	CANVAS_HEIGHT,d3
	move.w	SCALER2_BITS,d7
	and.w		#1<<Bit_SCALER2_FIT,d7
	beq.s		.cont
	cmp.w		d2,d0
	ble.s		.ok1
	move.w	d2,d0
.ok1	cmp.w		d3,d1
	ble.s		.ok2
	move.w	d3,d1
.ok2	move.w	d0,new_imagewidth
	move.w	d1,new_imageheight
	rts
.cont	ext.l		d0
	ext.l		d1
	ext.l		d2
	ext.l		d3
	move.w	SCALER_BITS,d7
	and.w		#1<<Bit_SCALER_FINE,d7
	beq.s		.lock
	move.w	d0,new_imagewidth
	move.w	d1,new_imageheight
	move.w	d2,d4
	swap		d4
	clr.w		d4
	divu.l	d0,d4
	swap		d4
	tst.w		d4
	bne.s		.fit1
	move.w	d2,new_imagewidth
	move.w	d2,d0
	ext.l		d0
	swap		d4
	mulu.l	d4,d1
	add.l		#$8000,d1
	swap		d1
	move.w	d1,new_imageheight
	ext.l		d1
.fit1	move.w	d3,d4
	swap		d4
	clr.w		d4
	divu.l	d1,d4
	swap		d4
	tst.w		d4
	bne.s		.rts
	move.w	d3,new_imageheight
	swap		d4
	mulu.l	d4,d0
	add.l		#$8000,d0
	swap		d0
	move.w	d0,new_imagewidth
	bra.s		.rts
.lock	cmp.w		d2,d0
	bgt.s		.down
	cmp.w		d3,d1
	ble.s		.fits
.down	lsr.w		d0
	lsr.w		d1
	bra.s		.lock
.fits	move.w	d0,new_imagewidth
	move.w	d1,new_imageheight
.rts	rts

*-----------------------------*
import:
*-----------------------------*
.skip	tst.b		edit
	beq.s		.nedt
	jsr		tab_screen
	tst.l		d0
	bmi.s		.nedt
	st		MENUPAL_CHANGED
	jsr		Redraw_menu_icons
	jsr		dump_screen
.nedt	rts

*-----------------------------*
init_editbuffer:
*-----------------------------*
	move.w	CANVAS_WIDTH,tab_width
	move.w	CANVAS_HEIGHT,tab_height
	move.w	#1<<Bit_PASTE_SOLI,PASTE_BITS
	tst.b		dump_under
	bne.s		.du
	move.w	#1<<Bit_PASTE_XRAY,PASTE_BITS
*-----------------------------*
.du	move.w	LOG_HANDLE,TAB_HANDLE
	move.w	CANVAS_WIDTH,dest_scrwidth
	tst.b		edit
	beq		.exit
*-----------------------------*
*	Edit mode is enabled	*
*-----------------------------*
	move.w	old_imagewidth,d0
	tst.b		TRUE_FLAG
	bne.s		.true
	add.w		#15,d0
	and.w		#-16,d0
	move.w	d0,dest_scrwidth
	bra.s		.bpl	
.true	move.w	d0,dest_scrwidth
	add.w		d0,d0
.bpl	mulu		old_imageheight,d0
	tst.b		avoid_editpack
	bne.s		.breach
	cmp.l		CANVAS_SIZE,d0
	bgt.s		.breach
	move.w	PACK_HANDLE,TAB_HANDLE
	bra		.done
.force:
	move.w	CANVAS_WIDTH,dest_scrwidth
	move.w	CANVAS_WIDTH,tab_width
	move.w	CANVAS_HEIGHT,tab_height
	move.w	PACK_HANDLE,TAB_HANDLE
	bra		.exit
.breach:
	move.l	d0,dest_size
	add.l		#256,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bpl.s		.cont
	tst.b		avoid_editpack
	beq.s		.force
	bra.s		.err
.cont	move.w	d0,TAB_HANDLE
*-----------------------------*
.done	move.w	dest_scrwidth,tab_width
	move.w	old_imageheight,tab_height
	move.w	old_imagewidth,dest_width
	move.w	old_imageheight,dest_height
*-----------------------------*
.exit	moveq		#0,d0
	rts
.err	moveq		#-1,d0
	rts
	
dest_size:	ds.l	1
	
reduce_handler:
	move.b	#logic_replace,logic_operation
	move.w	DISKFLAG_BITS,d0
	move.b	#use_new,palette_mode
	btst		#Bit_DISKFLAG_KEEPCOL,d0
	beq.s		.nkp
	move.b	#use_old,palette_mode
	bra.s		.got
.nkp	btst		#Bit_DISKFLAG_MAKECOL,d0
	beq.s		.got
	move.b	#make_new,palette_mode
.got	sf		mip_map
	btst		#Bit_DISKFLAG_MIPMAP,d0
	sne		mip_map
	move.w	VCOL_BITS,d0
	and.w		#1<<Bit_VCOL_GREY,d0
	beq.s		.ok2
	move.b	#use_old,palette_mode
.ok2	rts

*-----------------------------------*
StrtFrame_handler:			*
*-----------------------------------*
	move.l	#COLOURS,DISPLAY_COLOURS
	move.l	#COLOURS,PALETTE_PTR		; incoming palette
	sf		dump_under
	move.b	PALETTE_CHANGED,d0
	or.b		d0,MENUPAL_CHANGED
	sf		TERM_LOAD
	jsr		Get_changes
	tst.l		d0
	bmi		.exit
	sf		FORCE_REMAP
	move.l	LOG_SCR,dest_image
	jsr		reduce_handler
	move.w	DISKOP_BITS,d0
	btst		#Bit_DISKOP_REPLACE,d0
	bne.s		.Repl
	btst		#Bit_DISKOP_PRECEDE,d0
	bne.s		.Prec
	btst		#Bit_DISKOP_INSERT,d0
	bne.s		.Inse
	btst		#Bit_DISKOP_APPEND,d0
	bne.s		.Appe
	btst		#Bit_DISKOP_PATCH,d0
	bne.s		.Patc
	btst		#Bit_DISKOP_ABOVE,d0
	bne.s		.Abov
	btst		#Bit_DISKOP_BELOW,d0
	bne		.Belo
.exit	bsr		Colour_handler
	rts
*-----------------------------------*
*	Replace old anim			*
*-----------------------------------*
.Repl	tst.b		anim
	beq.s		.Patc
	jsr		Clear_deltas
	bra.s		.exit
*-----------------------------------*
*	Precede old anim			*
*-----------------------------------*
.Prec	jsr		Frame_start
	jsr		Frame_left_ins_invoke
	move.l	LOG_SCR,a0
	bsr		CLEAR_CANVAS
	bra.s		.exit
*-----------------------------------*
*	Insert new anim			*
*-----------------------------------*
.Inse	jsr		Frame_left_ins_invoke
	move.l	LOG_SCR,a0
	bsr		CLEAR_CANVAS
	bra.s		.exit
*-----------------------------------*
*	Append new anim			*
*-----------------------------------*
.Appe	jsr		Frame_end
	jsr		Frame_right_ins_invoke
	move.l	LOG_SCR,a0
	bsr		CLEAR_CANVAS
	bra.s		.exit
*-----------------------------------*
*	Patch anim with new frames	*
*-----------------------------------*
.Patc	move.l	LOG_SCR,a0
	bsr		CLEAR_CANVAS
	bra.s		.exit
*-----------------------------------*
*	Fit bitmaps above current	*
*-----------------------------------*
.Abov	move.b	#logic_replace,logic_operation
	st		FORCE_REMAP
	move.l	#NEW_COLOURS,PALETTE_PTR
	move.l	#NEW_COLOURS,DISPLAY_COLOURS
	tst.b		edit
	bne		.exit
	move.b	#logic_overlay,logic_operation
	bra		.exit
*-----------------------------------*
*	Fit bitmaps below current	*
*-----------------------------------*
.Belo	move.b	#logic_replace,logic_operation
	st		FORCE_REMAP
	move.l	#NEW_COLOURS,PALETTE_PTR
	move.l	#NEW_COLOURS,DISPLAY_COLOURS
	st		dump_under
	tst.b		edit
	bne		.exit
	move.b	#logic_underlay,logic_operation
	bra		.exit

*-----------------------------------*
Colour_handler:				*
*-----------------------------------*
	move.l	#COLOURS,alt_palette
	move.l	#COLOURS,dest_palette
	cmp.b		#make_new,palette_mode
	beq.s		.bak
	cmp.b		#use_old,palette_mode
	bne.s		.rts
	move.l	#COLOURS,DISPLAY_COLOURS	
.bak	move.l	#NEW_COLOURS,PALETTE_PTR
.rts	move.l	PALETTE_PTR,source_palette
	rts

*-----------------------------------*
MidFrame_handler:				*
*-----------------------------------*
	move.b	PALETTE_CHANGED,d0
	or.b		d0,MENUPAL_CHANGED
	move.b	CHANGE_MADE,d0
	or.b		d0,BITMAP_CHANGED
*-----------------------------------*
	move.w	DISKOP_BITS,d0
*-----------------------------------*
	btst		#Bit_DISKOP_ABOVE,d0
	bne		.Abov
	btst		#Bit_DISKOP_BELOW,d0
	bne		.Abov
*-----------------------------------*
	jsr		Update_palette
*-----------------------------------*
	btst		#Bit_DISKOP_REPLACE,d0
	bne.s		.Inse
	btst		#Bit_DISKOP_PRECEDE,d0
	bne.s		.Inse
	btst		#Bit_DISKOP_INSERT,d0
	bne.s		.Inse
	btst		#Bit_DISKOP_APPEND,d0
	bne.s		.Inse
	btst		#Bit_DISKOP_PATCH,d0
	bne.s		.Patc
.exit	cmp.b		#right_button,BUTTONS
	bne.s		.ns
	lea		WIN_Funct_abort,a0
	sf		OK_CANCEL
	jsr		Dialog
	move.b	OK_CANCEL,TERM_LOAD
	jsr		HIDE_MOUSE
	jsr		Superscaler
	jsr		SHOW_MOUSE
.ns	rts
*-----------------------------------*
*	Insert new anim			*
*-----------------------------------*
.Inse	jsr		Frame_right_ins_invoke
	tst.b		edit
	beq.s		.ok
	move.l	LOG_SCR,a0
	bsr		CLEAR_CANVAS
.ok	bra.s		.exit
*-----------------------------------*
*	Patch anim with new frames	*
*-----------------------------------*
.Patc	jsr		Get_changes
	tst.l		d0
	bmi.s		.exit
	move.w	Delta_count,d0
	subq		#1,d0
	cmp.w		CUR_DELTAFRAME,d0
	beq.s		.rght
	jsr		Frame_right_invoke
	tst.b		edit
	beq.s		.exit
	move.l	LOG_SCR,a0
	bsr		CLEAR_CANVAS
	bra		.exit
.rght	bsr		Last_frame_handler
	bra		.exit
*-----------------------------------*
*	Patch anim with new frames	*
*-----------------------------------*
.Abov	jsr		display_new_colours
	st		BITMAP_CHANGED
	jsr		Get_changes
	tst.l		d0
	bmi		.exit
	move.w	Delta_count,d0
	subq		#1,d0
	cmp.w		CUR_DELTAFRAME,d0
	beq.s		.rgh2
	jsr		Frame_right_invoke
	bra		.exit
.rgh2	bsr.s		Last_frame_handler
	bra		.exit

*-----------------------------------*
EndFrame_handler:				*
*-----------------------------------*
	jsr		display_new_colours
	move.b	PALETTE_CHANGED,d0
	or.b		d0,MENUPAL_CHANGED
	move.b	CHANGE_MADE,d0
	or.b		d0,BITMAP_CHANGED
	jsr		Get_changes
	move.w	CUR_DELTAFRAME,d0
	jsr		Update_position
	jsr		Update_palette
	jsr		Remap_menu_bars
	rts

display_new_colours:
	move.l	DISPLAY_COLOURS,a0
	lea		COLOURS,a1
	cmp.l		a0,a1
	beq.s		.no
	jsr		COPYCOLS
	st		PALETTE_CHANGED
.no	jsr		Update_palette
	rts

Last_frame_handler:
	move.w	DISKFLAG_BITS,d0
	btst		#Bit_DISKFLAG_WRAP,d0
	beq.s		.nwrp
	jsr		Frame_start
	bra.s		.out
.nwrp	st		TERM_LOAD
.out	rts
	
REMAP_ROUT:		ds.l	1
PALETTE_PTR:	ds.l	1
TERM_LOAD:		ds.b	1
			even

*-----------------------------------------------------------------------*

REFORMAT_COLOURS:
	subq		#1,d0
	bmi.s		.rts
.lp	moveq		#0,d1
	move.w	(a0),d1
	move.w	d1,d2
	and.l		#%100010001000,d2
	lsr.w		#3,d2
	and.w		#$777,d1
	add.w		d1,d1
	or.w		d2,d1
	move.w	d1,(a0)+
	dbra		d0,.lp
.rts	rts

CONVERT_2_SPARROW:
	subq		#1,d0
	bmi.s		.rts
.lp	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	move.w	(a0)+,d1
	move.w	d1,d2
	move.w	d2,d3
	and.w		#$F00,d1
	and.w		#$0F0,d2
	and.w		#$00F,d3
	moveq		#5*4,d4
	lsl.l		d4,d1
	moveq		#4*4,d4
	lsl.l		d4,d2
	moveq		#1*4,d4
	lsl.l		d4,d3
	or.l		d1,d2
	or.l		d2,d3
	move.l	d3,(a1)+
	dbra		d0,.lp
.rts	rts

MASK_COLOURS:
	moveq		#16-1,d0
	lea		COLOURS,a0
	move.w	#$FFF,d2
.lp	move.w	(a0),d1
	and.w		d2,d1
	move.w	d1,(a0)+
	dbra		d0,.lp
	rts

CONVERT_BYTES_2_PLANES:
	move.w	File_Height,d7
	subq		#1,d7
.ylp	push.w	d7
	move.w	File_Width,d6
	lsr.w		#4,d6
	bra.s		.strt
.wlp	moveq		#16,d7
	bsr		Bytes2Words
	addq		#2,a1
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
.strt	dbra		d6,.wlp
	moveq		#16-1,d7
	and.w		File_Width,d7
	beq.s		.no
	bsr.s		Bytes2Words
	addq		#2,a1
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
.no	pop.w		d7
	dbra		d7,.ylp
	rts

CONVERT_PLANES_2_BYTES:
	move.w	File_Width,d7
	add.w		#15,d7
	lsr.w		#4,d7
	mulu		#18,d7
	move.w	d7,scrwid
	move.w	File_Height,d7
	subq		#1,d7
.ylp	push.w	d7
	push.l	a0
	move.w	File_Width,d6
	lsr.w		#4,d6
	bra.s		.strt
.wlp	addq		#2,a0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	moveq		#16,d7
	bsr		Words2Bytes
.strt	dbra		d6,.wlp
	moveq		#16-1,d7
	and.w		File_Width,d7
	beq.s		.no
	addq		#2,a0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	bsr		Words2Bytes
.no	pop.l		a0
	add.w		scrwid,a0
	pop.w		d7
	dbra		d7,.ylp
	rts

Bytes2Words:
	move.w	#16,d5
	sub.w		d7,d5
	bra.s		.strt
.lp16	move.b	(a0)+,d0
	add.b		d0,d0
	addx.w	d4,d4
	add.b		d0,d0
	swap		d4
	addx.w	d4,d4
	swap		d4
	add.b		d0,d0
	addx.w	d3,d3
	add.b		d0,d0
	swap		d3
	addx.w	d3,d3
	swap		d3
	add.b		d0,d0
	addx.w	d2,d2
	add.b		d0,d0
	swap		d2
	addx.w	d2,d2
	swap		d2
	add.b		d0,d0
	addx.w	d1,d1
	add.b		d0,d0
	swap		d1
	addx.w	d1,d1
	swap		d1
.strt	dbra		d7,.lp16
	lsl.w		d5,d1
	lsl.w		d5,d2
	lsl.w		d5,d3
	lsl.w		d5,d4
	swap		d1
	swap		d2
	swap		d3
	swap		d4
	lsl.w		d5,d1
	lsl.w		d5,d2
	lsl.w		d5,d3
	lsl.w		d5,d4
	swap		d1
	swap		d2
	swap		d3
	swap		d4
	rts

WBloop:
	add.w		d4,d4
	addx.w	d0,d0
	swap		d4
	add.w		d4,d4
	swap		d4
	addx.w	d0,d0
	add.w		d3,d3
	addx.w	d0,d0
	swap		d3
	add.w		d3,d3
	swap		d3
	addx.w	d0,d0
	add.w		d2,d2
	addx.w	d0,d0
	swap		d2
	add.w		d2,d2
	swap		d2
	addx.w	d0,d0
	add.w		d1,d1
	addx.w	d0,d0
	swap		d1
	add.w		d1,d1
	swap		d1
	addx.w	d0,d0
	move.b	d0,(a1)+
Words2Bytes:
	dbra		d7,WBloop
	rts

File_X:		ds.w	1
File_Y:		ds.w	1
File_Width:		ds.w	1
File_Height:	ds.w	1

*-----------------------------------------------------------------------*
*	File selector code								*
*-----------------------------------------------------------------------*

		rsreset
f_none	rs.b	1
f_cancel	rs.b	1
f_locate	rs.b	1

SELECT_A_FILE:
	bsr		FILE_SELECTOR
	tst.b		File_error
	bne		.exit
	lea		FILENAME,a1
.dir	lea		MAINPATH,a0		; copy path to FILENAME
.l1	move.b	(a0)+,d0
	cmp.b		#'*',d0
	beq.s		.file
	move.b	d0,(a1)+
	bra.s		.l1
.file	lea		NAMEBUFF,a0		; copy name to FILENAME
.l2	move.b	(a0)+,d0
	move.b	d0,(a1)+
	bne.s		.l2
.find	lea		FILENAME,a1		; find extension
.look	tst.b		(a1)+			; find end of name
	bne.s		.look
	subq		#5,a1
	moveq		#4-1,d0
.dig	cmp.b		#'.',(a1)+
	beq.s		.got
	dbra		d0,.dig
	move.b	#'.',(a1)+
	clr.b		(a1)
.got	clr.b		3(a1)
	move.l	a1,FILE_EXT
	pushall
	jsr		Remap_menu_bars
	jsr		Redraw_menu_icons
	popall
.exit	rts
	
NEW_SSP:		ds.l	1

FILE_SELECTOR:
	lea		MAINPATH,a1
.fz	tst.b		(a1)+
	bne.s		.fz
	subq.l	#1,a1
.look	move.b	-(a1),d0
	cmp.b		#'\',d0
	bne.s		.look
.makename:
	move.b	#'\',(a1)+
	move.b	#'*',(a1)+
	move.b	#'.',(a1)+
	move.l	DIRSPEC,a0
.lp	move.b	(a0)+,(a1)+
	bne.s		.lp
	jsr		Prepare_for_AES
	jsr		VSYNC
	jsr		Appl_init
;	bsr		V_Free
	jsr		F_select
	move.b	#f_none,File_error
	tst.w		int_out
	beq.s		.error
	tst.w		int_out+2
	beq.s		.cancel
	moveq		#0,d0
.exit	jsr		VSYNC
	jsr		Appl_exit
	jsr		Prepare_for_CUSTOM
	rts
.error:
	move.b	#f_locate,File_error
	moveq		#-1,d0
	bra.s		.exit
.cancel:
	move.b	#f_cancel,File_error
	moveq		#-1,d0
	bra.s		.exit

F_select:
	lea		control,a0
	move.w	#91,(a0)+
	move.w	#0,(a0)+
	move.w	#2,(a0)+
	move.w	#3,(a0)+
	move.w	#0,(a0)+
	move.l	#MAINPATH,addr_in
	move.l	#NAMEBUFF,addr_in+4
	move.l	SELECTOR_MESSAGE,addr_in+8
	jsr		AES
	rts

FILE_HANDLE:	ds.w  1
DISK_BYTES:		ds.l	1
DISK_ADDR:		ds.l	1
FILE_EXT:		ds.l	1
DIRSPEC:		ds.l	1

Init_paths:
	push.w	#25
	trap		#1
	addq		#2,sp
	add.w		#'A',d0
	IFD		FORCEPATH
	move.w	#'F',d0
	ENDC
	push.w	d0
	lea		MAINPATH,a0
	move.b	d0,(a0)+
	move.b	#':',(a0)+
	move.b	#'\',(a0)+
	move.b	#'*',(a0)+
	move.b	#'.',(a0)+
	move.b	#'*',(a0)+
	clr.b		(a0)
	pop.w		d0
	lea		SYSTEM_PATH,a0
	move.b	d0,(a0)+	
	move.b	#':',(a0)+	
	move.l	a0,PATH_PTR
	IFND		FORCEPATH
	push.w	#0
	pea		(a0)
	push.w	#71
	trap		#1
	addq.l	#8,sp
	ENDC
	move.l	PATH_PTR,a0
.lp	tst.b		(a0)+
	bne.s		.lp
	subq		#1,a0
	move.b	#'\',(a0)+	
	move.b	#'A',(a0)+	
	move.b	#'P',(a0)+	
	move.b	#'E',(a0)+	
	move.b	#'X',(a0)+	
	move.b	#'S',(a0)+	
	move.b	#'Y',(a0)+	
	move.b	#'S',(a0)+	
	move.b	#'\',(a0)+
	move.l	a0,SYSTEM_PTR
	clr.b		(a0)+
	rts
	
PATH_PTR:		ds.l	1
SYSTEM_PTR:		ds.l	1

*-----------------------------------------------------------------------*
*	File routines									*
*-----------------------------------------------------------------------*

MODE_ERROR:
	pushall
	lea		WIN_MODE_Error,a0
	jsr		DO_ALERT
	popall
	rts

TYPE_ERROR:
	pushall
	lea		WIN_TYPE_Error,a0
	jsr		DO_ALERT
	popall
	rts

SIZE_ERROR:
	pushall
	sf		OK_CANCEL
	lea		WIN_SIZE_Error,a0
	jsr		DO_ALERT
	popall
	rts

*-----------------------------------------------------------------------*

OPEN_ERROR:
	pushall
	lea		WIN_OPEN_Error,a0
	jsr		DO_ALERT
	popall
	rts

READ_ERROR:
	pushall
	lea		WIN_READ_Error,a0
	jsr		DO_ALERT
	popall
	rts

WRIT_ERROR:
	pushall
	lea		WIN_WRIT_Error,a0
	jsr		DO_ALERT
	popall
	rts

*-----------------------------------------------------------------------*

get_filesize:
	push.w	#0
	push.l	a0
	push.w	#47
	trap		#1
	addq		#2,sp
	move.l	d0,DTA
	push.w	#78
	trap		#1
	addq.l	#8,sp
	tst.l		d0
	bmi.s		.err
	move.l	DTA,a0
	move.l	26(a0),d0
.err	rts
	
convert_cols:
	move.l	PALETTE_PTR,a1
	move.w	#16-1,d0
.pal	move.w	(a0)+,d7
	bfextu	d7{20:8},d1
	bfextu	d7{24:8},d2
	bfextu	d7{28:8},d3
	and.w		#%11110000,d1
	and.w		#%11110000,d2
	and.w		#%11110000,d3
	add.b		d1,d1
	bcc.s		.nr
	or.b		#%00010000,d1
.nr	add.b		d2,d2
	bcc.s		.ng
	or.b		#%00010000,d2
.ng	add.b		d3,d3
	bcc.s		.nb
	or.b		#%00010000,d3
.nb	move.b	#0,(a1)+
	move.b	d1,(a1)+
	move.b	d2,(a1)+
	move.b	d3,(a1)+
	dbra		d0,.pal
	st		PALETTE_CHANGED
	rts

clear_page:
	tst.b		edit
	beq.s		.rts
	move.w	tab_width,d0
	cmp.w		dest_width,d0
	bgt		.clr
	move.w	tab_height,d0
	cmp.w		dest_height,d0
	bgt		.clr
.rts:	rts
.clr:	move.l	dest_image,a0
	tst.b		TRUE_FLAG
	bne.s		.tr
	move.w	tab_width,d0
	add.w		#16-1,d0
	and.w		#-16,d0
	mulu		tab_height,d0
	bra.s		.go
.tr:	move.w	tab_width,d0
	mulu		tab_height,d0
	add.l		d0,d0
.go:	jmp		memclr

cut_handler:
	tst.b		cut_mode
	bne.s		.cut
	move.w	CANVAS_WIDTH,CUT_WIDTH
	move.w	CANVAS_HEIGHT,CUT_HEIGHT
	move.w	#0,CUT_X
	move.w	#0,CUT_Y
	bra.s		.end
.cut:	move.w	CUT_XBASE,d3
	neg.w		d1
	and.w		d1,d3
	move.w	d3,CUT_X
	move.w	CUT_XSIZE,d3
	add.w		CUT_X,d3
	move.w	d0,d2
	subq.w	#1,d2
	add.w		d2,d3
	neg.w		d0
	and.w		d0,d3
	sub.w		CUT_X,d3
	move.w	d3,CUT_WIDTH
	move.w	CUT_YSIZE,CUT_HEIGHT
	move.w	CUT_YBASE,CUT_Y
	move.w	CANVAS_WIDTH,d0
	sub.w		CUT_WIDTH,d0
	sub.w		CUT_X,d0
	bpl.s		.end
	add.w		d0,CUT_X
.end:	move.w	CUT_WIDTH,d0
	beq.s		.err
	move.w	CUT_HEIGHT,d0
.err:	rts
	
*-----------------------------------------------------------------------*
* Create file.  INPUT a0 = filename, OUTPUT d0=handle				*
*-----------------------------------------------------------------------*
CreateFile:	move.w	#0,-(sp)
		move.l	a0,-(sp)
		move.w	#$3C,-(sp)
		trap		#1
		addq.w	#8,sp
		tst.l		d0
		bmi		OPEN_ERROR
		rts

*--------------------------------------------------------------------------*
* Open file.  INPUT a0 = filename, OUTPUT d0=handle
*--------------------------------------------------------------------------*
OpenFile:	move.w	#0,-(sp)
		move.l	a0,-(sp)
		move.w	#$3D,-(sp)
		trap		#1
		addq.w	#8,sp
		tst.l		d0
		bmi		OPEN_ERROR
		rts

*--------------------------------------------------------------------------*
* Delete file.  INPUT a0 = filename, OUTPUT d0=handle
*--------------------------------------------------------------------------*
DeleteFile:	move.l	a0,-(sp)
		move.w	#65,-(sp)
		trap		#1
		addq.l	#6,sp
		tst.l		d0
		bmi		OPEN_ERROR
		rts

*-------------------------------------------------------------------------*
* Close file. INPUT d0 = handle..
*--------------------------------------------------------------------------*
CloseFile:	move.w	d0,-(sp)
		move.w	#$3E,-(sp)
		trap		#1
		addq.w	#4,sp
		rts

*--------------------------------------------------------------------------*
* Write file. INPUT d0=handle, d1=size, a0=buffer, d0=error..
*--------------------------------------------------------------------------*
WriteFile:	move.l	a0,-(sp)
		move.l	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#$40,-(sp)	* Fwrite
		addq.b	#1,BUSY
		trap		#1
		subq.b	#1,BUSY
		lea		12(sp),sp
		tst.l		d0
		bmi		WRIT_ERROR
		rts

*--------------------------------------------------------------------------*
* Read file.  INPUT d0=handle, d1=size, a0=buffer, d0=error..
*--------------------------------------------------------------------------*
ReadFile:	move.l	a0,-(sp)
		move.l	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#$3F,-(sp)
		addq.b	#1,BUSY
		trap		#1
		subq.b	#1,BUSY
		lea		12(sp),sp
		tst.l		d0
		bmi		READ_ERROR
		rts

*--------------------------------------------------------------------------*
* Seek file.  INPUT d0=handle, d1=mode, d2=size, d0=error..
*--------------------------------------------------------------------------*
SeekFile:	move.w	d1,-(sp)
		move.w	d0,-(sp)
		move.l	d2,-(sp)
		move.w	#$42,-(sp)
		trap		#1
		lea		10(sp),sp
		tst.l		d0
		bmi		READ_ERROR
		rts	

*--------------------------------------------------------------------------*
* Patch file.  INPUT d0=handle, d1=size, d2=seek-to, a0=source d0=error..
*--------------------------------------------------------------------------*
PatchFile:	pushall
		moveq		#0,d1
		jsr		SeekFile
		tst.l		d0
		bmi.s		.err
		popall	
		jsr		WriteFile
		rts
.err		popall
		rts

*-----------------------------------------------------------------------*
Force_extension:
*-----------------------------------------------------------------------*
	pushall
	lea		FILENAME,a1
.fz	tst.b		(a1)+
	bne.s		.fz
	subq.l	#1,a1
.look	move.b	-(a1),d0
	cmp.b		#'.',d0
	bne.s		.cont
	cmp.b		#'\',-1(a1)
	beq.s		.makename2	
	bra.s		.makeext
.cont	cmp.b		#'\',d0
	bne.s		.look
.makename1:
	move.b	#'\',(a1)+
.makename2:
	move.b	#'N',(a1)+
	move.b	#'O',(a1)+
	move.b	#'_',(a1)+
	move.b	#'N',(a1)+
	move.b	#'A',(a1)+
	move.b	#'M',(a1)+
	move.b	#'E',(a1)+
.makeext:
	move.b	#'.',(a1)+
.lp	move.b	(a0)+,(a1)+
	bne.s		.lp
	popall
	rts

	include	incdir\ice_unpa.s

*-----------------------------------------------------------------------*
*		FILE SELECTOR NAME BUFFERS						*
*-----------------------------------------------------------------------*

JPGd:			dc.b	"JPG",0
PC1d:			dc.b	"PC1",0
IFFd:			dc.b	"IFF",0
PCSd:			dc.b	"PCS",0
SPUd:			dc.b	"SPU",0
GIFd:			dc.b	"GIF",0
TGAd:			dc.b	"TGA",0
MTVd:			dc.b	"MTV",0
BLKd:			dc.b	"APX",0
FLId:			dc.b	"FL?",0
FLCd:			dc.b	"FLC",0
FLHd:			dc.b	"FLH",0
SEQd:			dc.b	"SEQ",0
ANMd:			dc.b	"ANM",0
DACd:			dc.b	"DAC",0
CFNd:			dc.b	"CFN",0
MCLd:			dc.b	"FWR",0
STARd:		dc.b	"*",0

SYSTEM_PATH:	dc.b	"e:\apex"
			ds.b	256

PlanPixel_header:
	dc.b		"8PlaneMasked"
	ds.w		4
BytePixel_header:
	dc.b		"BytePerPixel"
	ds.w		4
WordPixel_header:
	dc.b		"WordPerPixel"
	ds.w		4
	
*-----------------------------------------------------------------------*
	BSS											*
*-----------------------------------------------------------------------*

CUT_X:		ds.w		1
CUT_Y:		ds.w		1
CUT_WIDTH:		ds.w		1
CUT_HEIGHT:		ds.w		1

CUT_XBASE:		ds.w		1
CUT_YBASE:		ds.w		1
CUT_XSIZE:		ds.w		1
CUT_YSIZE:		ds.w		1

new_imagewidth:	ds.w		1
new_imageheight:	ds.w		1
old_imagewidth:	ds.w		1
old_imageheight:	ds.w		1
jpeg_handle:	ds.w		1

image_handle:	ds.w		1
filebytes:		ds.l		1
CHANGE_MADE:	ds.b		1
File_error:		ds.b		1
anim:			ds.b		1
edit:			ds.b		1
dump_under:		ds.b		1
avoid_editpack:	ds.b		1
cut_mode:		ds.b		1
			even

file_size:		ds.l		1
DTA:			ds.l		1
BRUSH_SIZE:		ds.l		1
FREE_SPACE:		ds.l		1
FREE_ADDR:		ds.l		1
LOG_BACK:		ds.l		1
LOG_COPY:		ds.l		1
TAB_HANDLE:		ds.w		1
TAB_SCR:		ds.l		1

SELECTOR_MESSAGE:	ds.l		1
FILENAME_PTR:	ds.l		1
LOAD_STACK:		ds.l		1
DISPLAY_COLOURS:	ds.l		1

			ds.b		1
NAMEBUFF:		ds.b		256
			ds.b		1
FILENAME:		ds.b		256
			ds.b		1
MAINPATH:		ds.b		256
			even


*-----------------------------------------------------------------------*
	TEXT											*
*-----------------------------------------------------------------------*



