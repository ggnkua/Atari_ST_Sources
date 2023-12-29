		text
	; A0 = Address of path where to find the *.dmo files
get_demofnames	movem.l	d0-a6,-(sp)
	
	;Set new dta
		move.l	a0,a1
		jsr	Fgetdta
		move.l	d0,old_dta(a6)
		move.l	my_dta(a6),a0
		move.l	a0,a5
		jsr	Fsetdta
		move.l	a1,a0

	;Copy the demo-path to our buffer, "demo_dir"
		lea	demo_dir,a1
.cpy_path	move.b	(a0)+,(a1)+
		bne.s	.cpy_path
		subq.l	#1,a1
		sub.l	#demo_dir,a1
		move.w	a1,d3
		move.w	d3,demdir_end		;Offset to end of path, to beginning of filename

	;Create the filemask
		lea	demo_dir,a0
		move.l	#'*.dm',(a0,d3.w)
		move.w	#'o'<<8,4(a0,d3.w)

		lea	demo_files,a2
		clr.w	(a2)
		move.w	#max_demoes-1,d7
	
		moveq	#0,d0
		jsr	Fsfirst
		bmi.s	.done
		bsr.s	.cpy_fname
	
.nxt_file	jsr	Fsnext
		bmi.s	.done
		bsr.s	.cpy_fname
		dbra	d7,.nxt_file
		bra.s	.done
	
	;A0 = full path-file
	;A1 = Filename in full-pathfile a0+pathsize
	;a2 = demo files
	;A5 = DTA
	
	;Copy the filename from the DTA buffer to our demo-files buffer
.cpy_fname	lea	d_fname(a5),a3
		moveq	#13,d1

.get_fname	move.b	(a3)+,(a2)+
		beq.s	.got_fname
		dbra	d1,.get_fname
		clr.b	(a2)+
.got_fname	rts
	
	;Set old dta back
.done		clr.b	(a2)		;Terminate the list of demo files
		move.l	old_dta(a6),a0
		jsr	Fsetdta

		movem.l	(sp)+,d0-a6
		rts
	

install_demoes	movem.l	d0-a6,-(sp)

		bsr	begin_upd
		lea	null_str,a3
		bsr	.set_fname
		sub.l	#d_name,a3
		bsr	.set_dname
		bsr	open_loading
		bsr	get_loading
		move.l	obj_addr(a5),a0
		movem.w	win_x(a5),d1-4
		jsr	update_it
		bsr	end_upd

		move.w	#max_demoes-1,d7
	
		lea	demo_dir,a0
		move.w	demdir_end,d3
		lea	demo_files,a3

.next		tst.b	(a3)
		beq	.exit

		bsr	.set_fname

	;A0 = full path/name
	;A3 = Pointer to the current demo-filename
	;D3 = Offset to the filename in full path/file (a0)
		lea	(a0,d3.w),a4
.create_pf	move.b	(a3)+,(a4)+
		bne.s	.create_pf
	
		suba.l	a1,a1
		suba.l	a2,a2
		moveq	#3,d0
		jsr	Pexec
		bmi	.exit
		move.l	d0,a1
		move.l	$c(a1),d0	;Lenght of program in D0
		add.l	$14(a1),d0	;Add lenght of data segment
		add.l	$1c(a1),d0	;Then the lengh of BSS area
		add.l	#$100,d0	;finally, the basepage size
		movem.l	d0-a6,-(sp)
		move.l	d0,-(sp)	;Number of byte to reserve
		move.l	a1,-(sp)	;From this address
		clr.w	-(sp)		;Dummy
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp
		movem.l	(sp)+,d0-a6
		
		move.l	a1,d1
		add.l	#$104,a1
	
	;Check file id
		movem.l	a0-5,-(sp)
		moveq	#19,d0
		lea	gd_id,a2
.check_id	cmpm.b	(a1)+,(a2)+
		bne.s	.not_gemdem
		dbra	d0,.check_id
		bra.s	.its_gemdem
.not_gemdem	jsr	mem_free
		movem.l	(sp)+,a0-5
		bra.s	.next

.its_gemdem:	
	;A1 now points to the init routine of the demo
	;D1 points to the demos basepage

		move.l	d1,a1
		move.l	#dpb_ssize,d0
		move.l	#aloc_memprotsel|aloc_super|aloc_prefertt,d1
		jsr	get_memory
		bne.s	.got_dpb_mem
		move.l	a1,d1
		bra.s	.no_memory

.got_dpb_mem:	move.l	d0,a3		;Address of new d_*
	;Clear
		move.l	a3,a0
		move.w	#(dpb_ssize/2)-1,d0
.clr_dpb:	clr.w	(a0)+
		dbra	d0,.clr_dpb
		move.l	demoes,d0
		bne.s	.find_end
		move.l	a3,demoes
		bra.s	.setup_demo

.find_end:	move.l	d0,a0
		move.l	d_next(a0),d0
		beq.s	.found_end
		move.l	d0,a0
		bra.s	.find_end

.found_end:	move.l	a3,d_next(a0)

.setup_demo:	move.l	a1,d_basepage(a3)
		lea	demo_init,a4
		add.w	#$108,a1
		movem.l	d0-a6,-(sp)
		jsr	(a1)
		movem.l	(sp)+,d0-a6
		bcc	.dmo_init_err
		move.l	d_mscnljmp(a3),d_sslj(a3)
		
		moveq	#max_demoes-1,d0
		sub.w	d7,d0
		add.w	#ME_LDEM0,d0
		lea	d_name(a3),a2
		move.l	menu_addr(a6),a0
		jsr	set_menu_text
		jsr	.set_dname
		movem.l	(sp)+,a0-5
		dbra	d7,.next
		bra.s	.exit
		
	;The demo's init routine could not allocate the necessary mem..
.no_memory	jsr	mem_free
		movem.l	(sp)+,a0-5
		and.b	#-2,ccr
		bra.s	.exit

.dmo_init_err:	move.l	d_basepage(a3),d1
		jsr	mem_free
		move.l	a3,d1
		bra.s	.no_memory

	;No more free "slots".. no more demoes can be installed
.no_freeslots	movem.l	(sp)+,a0-5
		and.b	#-2,ccr
		bra.s	.exit
		nop

.exit		bsr	get_loading
		bsr	delete_window
		movem.l	(sp)+,d0-a6
		rts
		
.set_fname	movem.l	d0-a6,-(sp)
		move.l	a3,a2
		bsr	get_loading
		move.l	obj_addr(a5),a0

		moveq	#L_FNAME,d0
		move.l	misc_buff1(a6),a1
		bsr	prepare_object
		moveq	#0,d2
		bsr	set_tetxt_obj
		movem.l	(sp)+,d0-a6
		rts

.set_dname	movem.l	d0-a6,-(sp)
		lea	d_name(a3),a2
		bsr	get_loading
		move.l	obj_addr(a5),a0

		moveq	#L_DNAME,d0
		move.l	misc_buff1(a6),a1
		bsr	prepare_object
		moveq	#0,d2
		bsr	set_tetxt_obj
		movem.l	(sp)+,d0-a6
		rts
	
