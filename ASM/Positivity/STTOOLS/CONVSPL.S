; SAMPLE CONVERTER.		by Alain BROBECKER (baah)
; Made on 19 June 96. Yup, I code one STe because my Archie had a small
; problem and I can' t cope with being unproductive.

 opt o+

;**************************************************************************
;*****				      *****
;*****		    CODE		      *****
;*****				      *****
;**************************************************************************

;--------------------------------------------------------------------------
; Release the unused memory. Must be at the very beginning of proggy.
  move.l	4(sp),a0	; Adress of the Base page.
  move.l	$c(a0),d0	; Length of Text section.
  add.l	$14(a0),d0	; .. Data section.
  add.l	$1c(a0),d0	; .. Bss section.
  add.l	#$1100,d0	; .. of the Base page ($100) + extra.
  move.l	d0,-(sp)	; Size of the memory we need.
  move.l	a0,-(sp)	; Adress where we need memory.
  clr.w	-(sp)	; ???
  move.w	#$4a,-(sp)	; "mshrink" function number.
  trap	#$1	; Call it.
  add.l	#$c,sp	; Reinit stack.
;--------------------------------------------------------------------------
; Initialise the AES.
  move.w	#$a,aes_control	; Function "appl_init".
  move.w	#$0,aes_control+2 ; No parameters in int_in.
  move.w	#$0,aes_control+6 ; No parameters in addr_in.
  move.l	#aes_parameters,d1 ; now call the aes.
  move.w	#$c8,d0	; For aes.
  trap	#$2

;--------------------------------------------------------------------------
; The main loop of proggy.
  move.l	#welcome_msg,a0	; Fame is important.
  jsr	aes_box	; And go on with the show.
main_proggy
  move.l	#filename,a0	; Let the user choose the file.
  jsr	aes_fileselect
  cmp.l	#-1,a0	; No file selected?
  beq	end_proggy
;----> Get file size <----------
  move.w	#0,-(sp)	; Normal file.
  move.l	a0,-(sp)	; Move adress of filename in stack.
  move.w	#$4e,-(sp)	; 'FSFirst' function.
  trap	#1
  addq.l	#8,sp
  tst.l	d0	; If d0<>0 the file hasn' t been found.
  beq.s	file_found
  move.l	#fsfirst_msg,a0 ; So say it to user.
  jsr	aes_box	; And go on with the show.
  bra.s	main_proggy
file_found
  move.w	#$2f,-(sp)	; 'FGetDTA' function.
  trap	#1	; d0=adress of Disk Tranfert Area. (DTA)
  addq.l	#2,sp
  move.l	d0,a0
  move.l	26(a0),d0	; Offset 26 of DTA contains file size.
  move.l	d0,file_size
;----> Allocate Memory <--------
  move.l	d0,-(sp)	; Size of memory needed.
  move.w	#$48,-(sp)	; 'Malloc' function.
  trap	#1
  addq.l	#6,sp
  tst.l	d0	; An error occured?
  bge.s	memalloc_ok
  move.l	#memalloc_msg,a0 ; So say it to user.
  jsr	aes_box	; And go on with the show.
  bra.s	main_proggy
memalloc_ok
  move.l	d0,allocated_mem
;----> Load the file <----------
  move.w	#0,-(sp)	; Read only.
  pea	filename
  move.w	#$3d,-(sp)	; 'FOpen' function.
  trap	#1
  addq.l	#8,sp
  tst.l	d0
  bmi.s	loading_error
  move.w	d0,handle	; Save handle number.
  move.l	allocated_mem,-(sp) ; Buffer where to read.
  move.l	file_size,-(sp) ; Nb of bytes to read.
  move.w	d0,-(sp)	; Handle.
  move.w	#$3f,-(sp)	; 'Fread' function.
  trap	#1
  add.l	#12,sp
  tst.l	d0
  bmi.s	loading_error
  move.w	handle,-(sp)
  move.w	#$3e,-(sp)	; 'Fclose' function.
  trap	#1
  addq.l	#4,sp
  tst.l	d0
  bge.s	loaded_ok
loading_error
  move.l	#loading_msg,a0 ; Say it to user.
  jsr	aes_box	; And go on with the show.
  bra	continue_proggy
loaded_ok
;----> Convert Sample<----------
  move.l	allocated_mem,a0
  move.l	file_size,d0
  subq.l	#$1,d0
convert_loop
  eor.b	#$80,(a0)+
  dbra	d0,convert_loop
;----> Select save file <-------
  move.l	#filename,a0	; Let the user choose the file.
  jsr	aes_fileselect
  cmp.l	#-1,a0	; No file selected?
  beq.s	continue_proggy
;----> Save file <--------------
  move.w	#0,-(sp)	; Normal file.
  pea	filename
  move.w	#$3c,-(sp)	; 'Fcreate' function.
  trap	#1
  addq.l	#8,sp
  tst.l	d0
  bmi.s	saving_error
  move.w	d0,handle	; File write.
  move.l	allocated_mem,-(sp)
  move.l	file_size,-(sp)
  move.w	d0,-(sp)
  move.w	#$40,-(sp)
  trap	#1	; We' ll have d0=written size.
  add.l	#12,sp	;   (except if an error occur)	
  cmp.l	file_size,d0	; Error (d0<0) or written size<>file_size?
  bne.s	saving_error
  move.w	handle,-(sp)	; File close.
  move.w	#$3e,-(sp)
  trap	#1
  addq.l	#4,sp
  tst.l	d0
  bge.s	saved_ok
saving_error
  move.l	#saving_msg,a0  ; Say it to user.
  jsr	aes_box	; And go on with the show.
saved_ok
;----> Wanna go on? <------------
continue_proggy
  move.l	#continue_msg,a0 ; Ask the user if he wants to continue.
  jsr	aes_box
  cmp.w	#1,a0
  bne.s	end_proggy
;----> Free Memory <------------
  move.l	allocated_mem,d0
  move.l	d0,-(sp)	; Adress of memory to free.
  move.w	#$48,-(sp)	; 'Malloc' function.
  trap	#1
  addq.l	#6,sp
  tst.l	d0	; Memory released ok?
  bge	main_proggy
  move.l	#memfree_msg,a0 ; So say it to user.
  jsr	aes_box	; And go on with the show.
  bra	main_proggy

;--------------------------------------------------------------------------
; Exit the AES and quit the proggy.
end_proggy
  move.w	#$13,aes_control ; Function "appl_exit".
  move.w	#$0,aes_control+2 ; No parameters in int_in.
  move.w	#$0,aes_control+6 ; No parameters in addr_in.
  move.l	#aes_parameters,d1 ; Now call the aes.
  move.w	#$c8,d0	; For aes.
  trap	#$2
  clr.w	-(sp)	; 'PTerm' function.
  trap	#$1



;**************************************************************************
;*****				      *****
;*****		  ROUTINES		      *****
;*****				      *****
;**************************************************************************

;--------------------------------------------------------------------------
;---	               AES_FILESELECT		        ---
;--------------------------------------------------------------------------
; Routine which creates a fileselector, and returns the path+name of the
; selected file in the buffer pointed by a0. Returns -1 in a0 if no file
; was selected!
aes_fileselect
  movem.l	d0-a6,-(sp)	; We don' t know what aes use, so...
  move.b	#$0,.fsel_fname	; Reset the default filename.
  move.w	#$5a,aes_control ; Function "fsel_input".
  move.w	#$0,aes_control+2 ; No parameters in int_in.
  move.w	#$2,aes_control+6 ; Two parameters in addr_in.
  move.l	#.fsel_path,aes_addr_in ; adress for "?.?" + path storage.
  move.l	#.fsel_fname,aes_addr_in+4 ; adress for fname storage.
  move.l	#aes_parameters,d1 ; Now call the aes.
  move.w	#$c8,d0	; For aes.
  trap	#$2
  movem.l	(sp)+,d0-a6
  cmpi.b	#$0,.fsel_fname	; fsel_fname is null?
  bne.s	.concatenate	; No, then concatenate path and filename.
  move.l	#-$1,a0	; Then nothing was selected, put -1 in a0
  rts		;   and quit the routine. 	

; A file has been selected, we must concatenate path and name.
.concatenate
  movem.l	a0-a1,-(sp)
  move.l	#.fsel_path,a1
.copy_path
  move.b	(a1)+,(a0)+	; Copy one character.
  bne.s	.copy_path	; Until char is 0. (Copied, too)
.flush_inpath		; Flush the "*.*" thingie or else.
  cmp.b	#'\',-(a0)	; Go back one char and compare with "\".
  bne.s	.flush_inpath
  addq.l	#$1,a0	; Do not flush the "\".
  move.l	#.fsel_fname,a1
.copy_fname
  move.b	(a1)+,(a0)+	; Copy one byte.
  bne.s	.copy_fname	; Until char is 0. (Copied, too)
  movem.l	(sp)+,a0-a1
  rts

.fsel_path	
  dc.b "\*.*",0
  ds.b	128
.fsel_fname
  ds.b	12
 even

;--------------------------------------------------------------------------
;---	                  AES_BOX		        ---
;--------------------------------------------------------------------------
; Routine which makes a box selector. a0 shall points on a string like
; '[0][Line1|Line2|..|Ligne5][Button1|Button2|Button3]'.
; The function returns the selected button in a0.
aes_box:
  movem.l	d0-d7/a1-a6,-(sp)
  move.w	#$34,aes_control ; Function "form_alert".
  move.w	#$1,aes_control+2 ; One parameter in int_in.
  move.w	#$1,aes_control+4 ; One parameter in int_out.
  move.w	#$1,aes_control+6 ; One parameter in addr_in.
  move.w	#$1,aes_int_in	; First button have the Default status.
  move.l	a0,aes_addr_in	; Adress of the box definition.
  move.l	#aes_parameters,d1 ; Now call the aes.
  move.w	#$c8,d0	; For aes.
  trap	#$2
  move.w	aes_int_out,a0	; Return the nb of the selected button.
  movem.l	(sp)+,d0-d7/a1-a6
  rts


;**************************************************************************
;*****                                                                *****
;*****		   DATAS                              *****
;*****                                                                *****
;**************************************************************************
aes_parameters
  dc.l	aes_control	; Points on the "control" array.
  dc.l	aes_global	; .. on "global" array.
  dc.l	aes_int_in	; Understood??...
  dc.l	aes_int_out
  dc.l	aes_addr_in
  dc.l	aes_addr_out

welcome_msg	dc.b '[1][ Sample converter|by Alain BROBECKER][baah]',0
loading_msg	dc.b '[1][Error while loading][Oh!]',0
saving_msg	dc.b '[1][Error while saving][Oh!]',0
continue_msg	dc.b '[2][Convert another?][Yes|No]',0
fsfirst_msg	dc.b '[1][File Not Found][Oh!]',0
memalloc_msg	dc.b '[1][Unable to|allocate memory][Oh!]',0
memfree_msg	dc.b '[1][Unable to|free memory][Oh!]',0

 even


;**************************************************************************
;*****                                                                *****
;*****		    BSS                               *****
;*****                                                                *****
;**************************************************************************
  SECTION BSS

aes_control	ds.w 5	; Arrays for AES routines.
aes_global	ds.w 16	;
aes_int_in  	ds.w 16	;
aes_int_out  	ds.w 7	;
aes_addr_in  	ds.l 2	;
aes_addr_out  	ds.l 1	;

handle	ds.w 1

file_size	ds.l 1

filename	ds.b 128

allocated_mem	ds.l 1	; Will contain adress of allocated mem.
