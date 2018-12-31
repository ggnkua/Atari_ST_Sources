	output "SYSREC.PRG"

; d‚marrage TOS

	move.l 4(sp),a3
	lea 128(a3),a6			; command line
	move.l $18(a3),a4
	add.l $1c(a3),a4
	add.l #$1000,a4
	move.l a4,sp
	sub.l a3,a4
	move.l a4,-(sp)
	move.l a3,-(sp)
	clr.w -(sp)
	move.w #$4a,-(sp)
	trap #1
	lea 12(sp),sp

	bsr load_inf		; set some options from SYSREC.INF
	bsr fixe_options	; and get missing options from the user!
	
	move.l buff_size(pc),-(sp)
	move #$48,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,buffer
	bne.s mem_ok
	
	pea bug4(pc)
	bra error
	
mem_ok:
	move.l d0,zone_ptr
	
	pea nul(pc)
	move.l command(pc),-(sp)
	move.l programme(pc),-(sp)
	move #3,-(sp)
	move #75,-(sp)
	trap #1
	lea 16(sp),sp
	move.l d0,basepage
	bmi.s erreur_load

	move.l d0,a0
	lea 256(a0),a1			; start TEXT
	move.l a1,start_text
	move.l $18(a0),a0		; start_bss = end text+data
	move.l a0,end_text
	
	pea installe(pc)
	move #38,-(sp)
	trap #14
	addq.l #6,sp
	
	tst.b d6
	spl validate			; start immediately if not Alt-Help option

	btst #6,d6				; record offsets?
	sne offsets

	pea nul(pc)
	move.l basepage,-(sp)
	pea nul(pc)
	move #6,-(sp)
	move #75,-(sp)
	trap #1
	lea 16(sp),sp

	sf validate
	
	pea restore(pc)
	move #38,-(sp)
	trap #14
	addq.l #6,sp

	move.l options,d6
	btst #16,d6
	beq.s .no1	
	bsr save_data_bin		; sysrec.log
.no1:
	btst #17,d6
	beq.s .no2
	bsr save_data_txt		; sysrec.txt
.no2:	
	bra.s exit

erreur_load:
	pea bug1(pc)
	
error:
	move #9,-(sp)
	trap #1
	addq.l #6,sp

	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp

exit:
	clr -(sp)
	trap #1

fixe_options:
	pea intro(pc)
	move #9,-(sp)
	trap #1						; title
	addq.l #6,sp
	
	btst #8,d6					; a program name has been found?
	bne.s .no_prog				; yes,don't ask
	lea ask_prog(pc),a0
	moveq #124,d1
	moveq #8,d0				; after 2KB from zone
	bsr input_string
	move.l a3,programme
.no_prog:
	btst #9,d6					; a command line found?
	bne.s .no_cmd				; yes, dont' ask
	lea ask_cmd(pc),a0
	moveq #124,d1
	moveq #9,d0
	bsr input_string
	subq.l #1,a3
	move.l a3,command
.no_cmd:
	btst #10,d6					; a buffer size has been set?
	bne.s .no_buff
.again:
	lea ask_buff(pc),a0
	moveq #8,d1
	moveq #10,d0
	bsr input_string
	move.l a3,a0
	bsr char_to_integer
	beq.s .again				; can't be zero, ask again!
	move.l d1,buff_size
.no_buff:
	btst #12,d6
	bne.s .fin					; options found in INI file, don't ask!
	pea ask_rec(pc)
	move #9,-(sp)
	trap #1						; ask for options GBXVALO or ENTER for all
	addq.l #6,sp
.key:
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp				; read KEY
	cmp #13,d0
	beq.s .fin
	bsr.s char_to_mask
	beq.s .key					; invalid char, don't display
	move d0,-(sp)
	move #2,-(sp)
	move #3,-(sp)
	trap #13
	addq.l #6,sp				; write CHAR
	bra.s .key
.fin:
	move d6,d0
	and #$7F,d0					; any option set?
	bne.s .start				; if some options, keep them
	or #$7F,d6					; else ALL options
.start:
	btst #11,d6
	bne.s .no_alt_help
	pea ask_start(pc)
	move #9,-(sp)
	trap #1
	addq.l #6,sp				; ask for Alt+Help or immediate
.key2:
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp				; read KEY	
	cmp #13,d0					; ENTER, immediate
	beq.s .no_alt_help
	cmp #32,d0					; SPACE, alt help
	bne.s .key2
	or.b #$80,d6
.no_alt_help:
	btst #13,d6
	bne.s .no_log				; option already found in INI file
	moveq #16,d3
	lea ask_log(pc),a0
	bsr yes_no
.no_log:
	btst #14,d6
	bne.s .no_txt				; option already found in INI file
	moveq #17,d3
	lea ask_text(pc),a0
	bsr yes_no
.no_txt:
	rts	

	; input D0: char (lower or upper case)
	; output EQ if invalid NE if valid and D6 bit set

char_to_mask:
	lea .list(pc),a1
	moveq #1,d1					; bit mask
	and.b #$DF,d0				; to upper case
	lea sub_ptr(pc),a3
.find:
	move.b (a1)+,d2
	beq.s .fin
	cmp.b d2,d0
	beq.s .found
	add d1,d1
	addq.l #4,a3
	bra.s .find
.found:
	or d1,d6						; add mask
	cmp.b #'+',(a0)			; if +/- then particular fn to record
	beq.s .parsefn
	cmp.b #'-',(a0)
	beq.s .parsefn
.fin:
	rts
.list: dc.b "GBXVALO",0
	even
.parsefn:
	move.l fn_ptr(pc),a1
	move.l a1,(a3)				; start of list
.nombre_suiv:
	moveq #0,d1
	move.b (a0)+,d0
	beq.s .fin2
	cmp.b #'+',d0
	beq.s .plus
	cmp.b #'-',d0
	bne.s .fin2
	move #$8000,(a1)+			; marker for -nnn = STOP if nnn
	bra.s .digit
.plus:
	move #$0080,(a1)+					; marker for +nnn = record if nnn
.digit:
	moveq #0,d0
	move.b (a0)+,d0
	beq.s .fin2
	sub.b	#'0',d0
	bmi.s .dok
	cmp.b #10,d0
	bpl.s .dok
	muls #10,d1
	add.w d0,d1
	bra.s .digit
.dok:
	move d1,(a1)+				; fn number to record
	subq.l #1,a0
	bra.s .nombre_suiv
.fin2:
	clr.l (a1)+					; end of list
	move.l a1,fn_ptr
	subq.l #1,a0
	rts	
		




	; input A0=string to display
	; d3=bit to setin D6if YES

yes_no:
	pea (a0)
	move #9,-(sp)
	trap #1
	addq.l #6,sp
.key:
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp				; read KEY
	and #$DF,d0
	cmp #'Y',d0
	beq.s .yes
	cmp #'N',d0
	beq.s .no
	beq.s .key					; invalid char, don't display
.yes:
	bset d3,d6
.no:
	move d0,-(sp)
	move #2,-(sp)
	move #3,-(sp)
	trap #13
	addq.l #6,sp				; write CHAR
	rts

	; input D0 = string number (blocks of 128 bytes in ZONE)
	; D1 = max len <126
	; A0 prompt string
	; output: D0 and -1(a3) = len
	; A3 points to null terminated string
	
input_string:
	lsl.l #7,d0					;128 bytes per string
	lea zone(pc),a3		; string address
	add.l d0,a3
	move.b d1,(a3)
	pea (a0)
	move #9,-(sp)
	trap #1					; display prompt
	addq.l #6,sp
	pea (a3)
	move #$a,-(sp)
	trap #1
	addq.l #6,sp				; Cconrs
	moveq #0,d0
	addq.l #1,a3
	move.b (a3)+,d0			; len
	clr.b 0(a3,d0.l)			; nul terminated
	rts
	
installe:
	moveq #0,d1					; no 68060
	move.l $5a0.w,a0
	move.l a0,d0
	beq.s .fin
.encore:
	move.l (a0)+,d0
	beq.s .fin
	cmp.l #'_CPU',d0
	beq.s .found
	addq.l #4,a0
	bra.s .encore
.found:
	move.l (a0),d1
	cmp.l #40,d1
	bmi.s .fin
	dc.w $f4f8
.fin:
	move.l d1,_cpu
	move.l d6,options
	btst #0,d6
	beq.s .lb0	
	move.l $84.w,old_trap1
	move.l #my_trap1,$84.w
.lb0:
	btst #1,d6
	beq.s .lb1
	move.l $B4.w,old_trap13
	move.l #my_trap13,$B4.w
.lb1:
	btst #2,d6
	beq.s .lb2
	move.l $B8.w,old_trap14
	move.l #my_trap14,$B8.w
.lb2:
	btst #5,d6
	beq.s .lb3
	move.l $28.w,old_linea
	move.l #my_linea,$28.w
.lb3:
	move.l $502.w,old_alt_help
	move.l #my_alt_help,$502.w
	and #$18,d6						; bits VDI & AES
	beq.s .lb4
	move.l $88.w,old_trap2
	cmp #$18,d6						; VDI and AES?
	beq.s .both
	cmp #$10,d6						; AES only?
	beq.s .aes
	move.l #my_trap2_vdi,$88.w
	bra.s .lb4
.aes:
	move.l #my_trap2_aes,$88.w
	bra.s .lb4
.both:
	move.l #my_trap2,$88.w
.lb4:
	move #-1,$4ee.w
.exit:
	rts

restore:
	move.l options(pc),d6
	btst #0,d6
	beq.s .lb0
	move.l old_trap1,$84.w
.lb0:
	btst #1,d6
	beq.s .lb1
	move.l old_trap13,$B4.w
.lb1:
	btst #2,d6
	beq.s .lb2
	move.l old_trap14,$B8.w
.lb2:
	btst #5,d6
	beq.s .lb3
	move.l old_linea,$28.w
.lb3:
	move.l old_alt_help,$502.w
	and #$18,d6
	beq.s .lb4
	move.l old_trap2,$88.w
.lb4:
	move #-1,$4ee.w
	rts


load_inf:
	moveq #0,d0
	lea sysrecinf(pc),a0	; default INF file
	move.b (a6)+,d0	; command line size
	beq.s .loadfile	; empty, use default
	clr.b 0(a6,d0.l)	; nul terminated string
	move.l a6,a0
.loadfile:	
	moveq #0,d6			; no options for now
	move.l a0,a6
	clr -(sp)
	pea (a0)
	move #$3d,-(sp)
	trap #1
	addq.l #8,sp		; open SYSREC
	move d0,d7			; handle
	bmi fin_inf
	pea zone(pc)
	move.l #2048,-(sp)
	move d7,-(sp)
	move #$3f,-(sp)
	trap #1
	lea 12(sp),sp		; fread 2KB
	move.l d0,d3		; size
	move d7,-(sp)
	move #$3e,-(sp)
	trap #1
	addq.l #4,sp
	tst.l d3
	bmi fin_inf			; error code
	lea zone(pc),a0	; the file!
	lea 0(a0,d3.l),a1	; the end of file
	move.b #'"',(a1)+	; end of command line if needed
	move.b #13,(a1)+	; end of line
	move.b #0,(a1)		; end of file
	moveq #0,d0
parse_inf:
	move.b (a0)+,d0	; one char
	beq.s fin_inf			; end of file
	cmp #33,d0
	bmi.s parse_inf		; not a signifiant one
	cmp.b #';',d0		; a comment?
	bne.s .found
.next_line:				; if a comment, skip whole line
	move.b (a0)+,d0
	beq.s fin_inf
	cmp #13,d0
	beq.s parse_inf		; end reached
	cmp #10,d0
	beq.s parse_inf
	bra.s .next_line
.found:					; if not a comment, try to identify "X=" code
	cmp.b #'=',(a0)+
	bne.s .next_line	; bad format, not "X=", skip whole line
	and #$DF,d0			; to upper case
	cmp.b #'P',d0
	beq read_program_name
	cmp.b #'C',d0
	beq read_command_line
	cmp.b #'B',d0
	beq read_buffer_size
	cmp.b #'S',d0
	beq read_start_mode
	cmp.b #'R',d0
	beq read_record_options
	moveq #16,d1
	cmp.b #'L',d0
	beq read_file_save
	moveq #17,d1
	cmp.b #'T',d0
	beq read_file_save
	bra.s .next_line		; else, bad format, skip whole line
fin_inf:
	rts

read_record_options:
	move.b (a0)+,d0
	cmp #'A',d0
	bmi.s .fin
	bsr char_to_mask
	bra.s read_record_options
.fin:
	bset #12,d6				; if options empty, then ALL options
	bra.s parse_inf
	; read S=x to set start option
	; S=I immediate
	; S=A wait for alt help to start recording
	
read_start_mode:
	move.b (a0)+,d0
	and #$DF,d0
	cmp.b #'I',d0
	beq.s .immediate
	cmp.b #'A',d0
	bne parse_inf			; unknown option, return
	bset #7,d6				; wait for alt help
.immediate:		
	bset #11,d6				; validate START option
	bra parse_inf

	; for L=x or T=x; save LOG file or save TEXT file
	; L/T=Y for yes
	; L/T=N for no
	
read_file_save:
	move.b (a0)+,d0
	and #$DF,d0
	cmp.b #'N',d0
	beq.s .no
	cmp.b #'Y',d0
	bne parse_inf			; unknown option
	bset d1,d6				; set "save file"
.no:
	subq #3,d1
	bset d1,d6				; and set that option is valid
	bra parse_inf

	; for P="xxxx" read the filename string
	
read_program_name:
	cmp.b #'"',(a0)+
	bne.s .fin				; bad format!
	bsr read_string
	move.l a1,programme
	clr.b -1(a0)			; end of string
	bset #8,d6				; have a program name
.fin:
	bra parse_inf

	; for C="xxxx" read the command line string
	
read_command_line:
	cmp.b #'"',(a0)+
	bne.s .fin				; bad format!
	bsr read_string
	move.l a0,d1
	sub.l a1,d1			; line size+1
	subq.l #1,d1
	move.b d1,-(a1)	; store line size
	move.l a1,command
	bset #9,d6			; have a command line
.fin:
	bra parse_inf

read_string:
	move.l a0,a1
.lb0:
	move.b (a0)+,d0
	cmp.b #'"',d0		; end string marker?
	beq.s .fin			; yes, so END
	cmp #32,d0			; a valid char? >=32
	bpl.s .lb0			; yes go on
.fin:						; else, stop the string here...
	rts

	; for B=nnn set the buffer size!
	
read_buffer_size:
	bsr.s char_to_integer
	beq.s .null			; if 0, not a valid size!
	move.l d1,buff_size
	bset #10,d6			; mark buffer
.null:
	bra parse_inf
		
char_to_integer:
	moveq #0,d1			; size
.lb0:
	moveq #0,d2
	move.b (a0)+,d2
	cmp #'0',d2
	bmi.s .fin
	cmp #'9'+1,d2
	bpl.s .fin
	sub #'0',d2
	muls #10,d1
	add.l d2,d1
	bra.s .lb0
.fin:
	lsl.l #8,d1
	lsl.l #2,d1		; KB to bytes			
	rts


save_data_bin:
	clr -(sp)
	pea log_file
	move #60,-(sp)
	trap #1
	addq.l #8,sp			; fcreate
	move d0,d7
	bpl.s .ok
	pea bug2(pc)
	bra error
.ok:
	move.l buffer(pc),a0
	pea (a0)
	move.l zone_ptr,a1
	sub.l a0,a1
	move.l a1,-(sp)
	move d7,-(sp)
	move #64,-(sp)
	trap #1					; fwrite
	lea 12(sp),sp
	move d7,-(sp)
	move #62,-(sp)
	trap #1					; fclose
	addq.l #4,sp
	rts

save_data_txt:
	clr -(sp)
	pea txt_file
	move #60,-(sp)
	trap #1
	addq.l #8,sp			; fcreate
	move d0,d7
	bpl.s .ok
	pea bug3(pc)
	bra error
.ok:
	move.l buffer(pc),a3
	move.l zone_ptr,a4	; end marker !!
.loop:
	cmp.l a3,a4
	beq.s .fin
	lea out_buff(pc),a0
	moveq #22,d4			; default length
	moveq #32,d0			; space
	move (a3)+,d3			; one code
	beq.s .althelp1		; code 0 = Alt Help OFF
	bpl.s .user
	cmp #-1,d3
	beq.s .althelp2		; code FFFF = altHelp ON
	moveq #'*',d0			; char for supervisor
	and #$7FFF,d3			; remove supervisor byte
.user:
	move.b d0,18(a0)
	move d3,d0
	and #$FFF,d3			; function number
	and #$F000,d0			; group (0:vdi+subfn,1:gemdos,2:aes,3:bios,4:xbios,5:vdi,6:linea)
	rol #6,d0				; group*4
	seq vdisub				; FF if vdi + subfn
	move.l .table(pc,d0.l),a1
	move.l (a1)+,2(a0)
	move (a1)+,6(a0)		; group name
	bsr .function_number
	bsr .function_address
	bsr .function_name
	bra.s .common
.althelp1:
	lea ah1(pc),a0
	bra.s .common
.althelp2:
	lea ah2(pc),a0
.common:
	move.l a0,-(sp)		; out_buffer
	move.l d4,-(sp)		; size to write
	move d7,-(sp)
	move #64,-(sp)
	trap #1					; fwrite
	lea 12(sp),sp
	bra.s .loop
.fin:
	move d7,-(sp)
	move #62,-(sp)
	trap #1					; fclose
	addq.l #4,sp
	rts
.table: dc.l vdisubfn_tab,gemdos_tab,aes_tab,bios_tab,xbios_tab,vdi_tab,linea_tab
.function_number:
	lea 12(a0),a2
	ext.l d3
	move.l d3,d0
	moveq #2,d1
.decimal:
	divs #10,d0
	swap d0
	add #'0',d0
	move.b d0,-(a2)
	clr d0
	swap d0
	dbf d1,.decimal
	lea 17(a0),a2
	moveq #2,d1
	move.l d3,d2
.hex:
	move d2,d0
	and #$F,d0
	move.b .hex_to_ascii(pc,d0),-(a2)
	lsr.l #4,d2
	dbf d1,.hex
	rts
.hex_to_ascii: dc.b "0123456789ABCDEF"
.function_address:
	tst.b offsets
	beq.s .end_name	; no addr recorded
	move.l (a3)+,d2	; the absolute address
	sub.l basepage,d2
	sub.l #$100,d2		; OFFSET from Text Zone
	subq.l #2,d2		; one instruction back!
	move.b #'$',0(a0,d4.l)	; sign for HEX address
	add #11,d4		; 11 more bytes to save
	lea 0(a0,d4.l),a2
	move.b #32,-(a2)
	move.b #32,-(a2)
	moveq #7,d1			; eight digits
	bra.s .hex		
.function_name:
	tst.b vdisub
	bne .vdisub_name
.name_common:
	lea 0(a0,d4.l),a2		; where to copy the name
	bra.s .name_loop
.next_name:
	tst.b (a1)+
	bmi.s .end_name	; end of table, name unknown
	bne.s .next_name	; not zero, go on
.name_loop:
	dbf d3,.next_name
.copy_name:
	move.b (a1)+,(a2)+
	bmi.s .end_name
	beq.s .end_name
	addq.l #1,d4
	bra.s .copy_name
.end_name:
	rts
.vdisub_name:
	lea vdisubfn_trans(pc),a2
	move.l d3,d2		; function num
	moveq #0,d3			; translated num in new table
.next_fn:
	move (a2)+,d0		; fn
	bmi.s .no_fn_found	; end of table
	cmp d0,d2
	beq.s .fn_found
.update_d3:
	move (a2)+,d0
	bmi.s .next_fn		; end of table
	add (a2)+,d3
	sub d0,d3
	bra.s .update_d3
.fn_found:
	move (a3)+,d2		; subfn
.next_sub:
	move (a2)+,d0
	bmi.s .no_sub_found
	cmp d0,d2
	bmi.s .no_sub_found	; under intervall
	move (a2)+,d1
	cmp d1,d2
	bmi.s .sub_found		; into intervall
	add d1,d3
	sub d0,d3				; update d3
	bra.s .next_sub
.sub_found:
	add d2,d3
	sub d0,d3				; that is the translated function number!
	bra.s .name_common
.no_fn_found:	
	addq.l #2,a3		; skip sub-opcode
.no_sub_found:
	rts

	; interception GEMDOS
my_trap1:
	move.l a2,save_a2
	move #$1000,d0
	move.l gemdos_fn(pc),a2
	move.l old_trap1,a0
	bra.s common_dos
	; interception BIOS
my_trap13:
	move.l a2,save_a2
	move #$3000,d0
	move.l bios_fn(pc),a2
	move.l old_trap13,a0
	bra.s common_dos
	; interception XBIOS
my_trap14:
	move.l a2,save_a2
	move #$4000,d0
	move.l xbios_fn,a2
	move.l old_trap14,a0
	
common_dos:
	tst.b validate
	bne.s .ok
.fin:
	move.l save_a2(pc),a2
	jmp (a0)
.ok:
	move.l 2(sp),a1		; calling address
	cmp.l start_text,a1
	bmi.s .fin				; not in the program zone
	cmp.l end_text,a1
	bpl.s .fin				; not in the program zone
	lea 6(sp),a1
	cmp.l #30,_cpu
	bmi.s .old_stack
	addq.l #2,a1			; jump over format word
.old_stack:
	btst #5,(sp)			; supervisor?
	bne.s .lb0				; yes, A1 is correct
	move.l USP,a1			; else take user stack
	bra.s .lb1
.lb0:
	or #$8000,d0			; mark for supervisor
.lb1:
	move (a1),d1			; function number
	move.l zone_ptr,a1
	or d1,d0					; + trap id
	move d0,(a1)+
	cmp.l #0,a2
	beq.s .record			; if no pointer, then record all
.loop_fn:
	move.l (a2)+,d0		; end of list?	
	beq.s .fin				; no match found
	cmp.w d0,d1
	bne.s .loop_fn			; not this one...
	tst.l d0
	bpl.s .record			; if >0 then just record	
	move.l 2(sp),a2		; else calling address
	illegal					; and STOP debugger	
.record:
	tst.b offsets
	beq.s .no_adr
	move.l 2(sp),(a1)+
.no_adr:
	move.l a1,zone_ptr
	move.l save_a2(pc),a2
	jmp (a0)					; go on!
	

	; interception AES & VDI
	
	; here only if VDI
	
my_trap2_vdi:
	move.l a2,save_a2
	move.l vdi_fn(pc),a2
	cmp #$73,d0
	beq.s my_trap2_common
trap2_end:
	move.l save_a2(pc),a2
	move.l old_trap2,-(sp)
	rts

dont_record:
	move.l save_d0(pc),d0
	bra.s trap2_end
	
	; here only if AES
	
my_trap2_aes:
	move.l a2,save_a2
	move.l aes_fn(pc),a2
	cmp #$c8,d0
	bne.s trap2_end
	bra.s my_trap2_common
	
	; here if both AES and VDI
	
my_trap2:
	move.l a2,save_a2
	cmp #$c8,d0
	bne.s .lb0
	move.l aes_fn(pc),a2
	bra.s my_trap2_common
.lb0:
	cmp #$73,d0
	bne.s .lb1
	move.l vdi_fn(pc),a2
	bra.s my_trap2_common
.lb1:
	move.l #0,a2
	
	; here common part and VDI/AES
	
my_trap2_common:
	tst.b validate
	beq.s trap2_end
	move.l 2(sp),a1		; calling address
	cmp.l start_text,a1
	bmi .fin				; not in the program zone
	cmp.l end_text,a1
	bpl .fin				; not in the program zone	
	move.l d1,a1			; param block
	move.l (a1),a1			; control
	cmp.l #0,a2				; list of functions to record?
	beq.s .record			; no, so record all.
	move.l d0,save_d0
.parse_fn:
	move.l (a2)+,d0
	beq.s dont_record		; end of list
	cmp (a1),d0				; good function?
	bne.s .parse_fn		; no
	tst.l d0
	bpl.s .just_record
	move.l 2(sp),a2		; calling address
	illegal	
.just_record:
	move.l save_d0(pc),d0
.record:
	move.l zone_ptr,a0
	move (a1),(a0)			; function number
	cmp #$73,d0
	beq.s .vdi
	cmp #$c8,d0
	bne.s .fin				; ???
	or.b #$20,(a0)			; AES id
	bra.s .term
.vdi:
	move 10(a1),2(a0)		; sub-opcode
	beq.s .vdi_normal		; no sub-opcode!
	and.b #$0F,(a0)		; else 0 instead of 5
	addq.l #2,zone_ptr	; two more bytes
	bra.s .term	
.vdi_normal:
	or.b #$50,(a0)
.term:
	addq.l #2,zone_ptr
	tst.b offsets
	beq.s .no_adr
	move.l zone_ptr(pc),a1
	move.l 2(sp),(a1)		; store calling address
	addq.l #4,zone_ptr
.no_adr	
	btst #5,(sp)			; supervisor?
	beq.s .fin				; no
	or.b #$80,(a0)			; yes; mark it!
.fin:
	bra trap2_end
	
	; interception LineA
my_linea:
	movem.l d0-d1/a0-a2,-(sp)
	tst.b validate
	bne.s .ok
.fin:
	movem.l (sp)+,d0-d1/a0-a2
	move.l old_linea,-(sp)
	rts
.ok:
	move.l 2(sp),a1		; calling address
	cmp.l start_text,a1
	bmi.s .fin				; not in the program zone
	cmp.l end_text,a1
	bpl.s .fin				; not in the program zone	
	move.l zone_ptr,a0
	move -2(a1),d0
	and #$FFF,d0
	move.l linea_fn(pc),a2
	cmp.l #0,a2				
	beq.s .record			; if no list, then record all
.parse_fn:
	move.l (a2)+,d1		; next fn 
	beq.s .fin				; end of list, nothing found
	cmp d0,d1
	bne.s .parse_fn
	tst.l d1
	bpl.s .record			; if positive, then just record	
	move.l a1,a2			; calling address
	illegal		
.record:	
	or #$6000,d0
	btst #5,(sp)			; supervisor?
	beq.s .lb0				; no
	or #$8000,d0			; yes, mark it!
.lb0:
	move d0,(a0)+		; line a instruction
	tst.b offsets
	beq.s .no_adr
	move.l 2(sp),(a0)+
.no_adr:
	move.l a0,zone_ptr
	bra.s .fin	
	
	; toggles my flag with each Alt+Help
	
my_alt_help:
	move #-1,$4ee.w
	move.l zone_ptr(pc),a0
	addq.l #2,zone_ptr
	not.b validate
	beq.s .off
	move #-1,(a0)
	rts
.off:
	move #0,(a0)
	rts	

	data
	
validate: dc.b 0	; if FF recording, if 00 pause
offsets:  dc.b 0	; if FF add calling address
vdisub:	 dc.b 0

sysrecinf: dc.b "SYSREC.INF",0

intro: dc.b 27,"E"
	dc.b "         *****   SysRec  *****",13,10
	dc.b "         System calls recorder",13,10
	dc.b " (c)2011-2018 guillaume.tello@orange.fr",0
ask_prog:
	dc.b 13,10,10
	dc.b " Program name : ",0
	
ask_cmd:
	dc.b 13,10,10
	dc.b " Command line : ",0
	
ask_buff:
	dc.b 13,10,10
	dc.b " Buffer size (in KB) : ",0

ask_log:
	dc.b 13,10,10
	dc.b " Save LOG file (Y/N) : ",0
	
ask_text:
	dc.b 13,10,10
	dc.b " Save TEXT file (Y/N) : ",0
	
ask_rec:
	dc.b 13,10,10
	dc.b " Record what?",13,10
	dc.b " ------------",13,10,10
	dc.b " G: Gemdos",13,10
	dc.b " B: Bios",13,10
	dc.b " X: Xbios",13,10
	dc.b " A: AES",13,10
	dc.b " V: VDI",13,10
	dc.b " L: Line A",13,10
	dc.b " O: Offset from TEXT of calling address",13,10
	dc.b " Empty line for ALL",13,10,10
	dc.b " Your choice: ",0

ask_start: dc.b 13,10,10
	dc.b "When to start?",13,10
	dc.b "--------------",13,10,10
	dc.b "Immediately:       ENTER",13,10
	dc.b "Wait for Alt-Help: SPACE",13,10,10
	dc.b " Your choice: ",0
	
nul: dc.b 0,0
bug1: dc.b 27,"EProgram can't be found!",7,13,10,10,0
bug2: dc.b 27,"ECan't create LOG file!",7,13,10,10,0
bug3: dc.b 27,"ECan't create TXT file!",7,13,10,10,0
bug4: dc.b 27,"ECan't allocate buffer!",7,13,10,10,0
log_file: dc.b "SYSREC.LOG",0
txt_file: dc.b "SYSREC.TXT",0

	even
out_buff:	dc.b 13,10,"      (___/$___) :  "
				dc.b "                                                "
ah1:			dc.b 13,10," --- Alt Help OFF --"
ah2:			dc.b 13,10," --- Alt Help ON ---"
				


gemdos_tab: dc.b "GEMDOS"
				dc.b "Pterm0",0,"Cconin",0,"Cconout",0,"Cauxin",0,"Cauxout",0
				dc.b "Cprnout",0,"Crawio",0,"Crawcin",0,"Cnecin",0,"Cconws",0
				dc.b "Cconrs",0,"Cconis",0,0,0,"Dsetdrv",0
				dc.b 0,"Cconos",0,"Cprnos",0,"Cauxis",0,"Cauxos",0
				dc.b "Maddalt",0,0,0,0,0
				dc.b "Dgetdrv",0,"Fsetdta",0,0,0,0
				dc.b 0,0,"Super",0,0,0
				dc.b 0,0,0,0,0
				dc.b 0,0,"Tgetdate",0,"Tsetdate",0,"Tgettime",0
				dc.b "Tsettime",0,0,"Fgetdta",0,"Sversion",0,"Ptermres",0
				dc.b 0,"Sconfig",0,0,0,"Dfree",0
				dc.b 0,0,"Dcreate",0,"Ddelete",0,"Dsetpath",0
				dc.b "Fcreate",0,"Fopen",0,"Fclose",0,"Fread",0,"Fwrite",0
				dc.b "Fdelete",0,"Fseek",0,"Fattrib",0,"Mxalloc",0,"Fdup",0
				dc.b "Fforce",0,"Dgetpath",0,"Malloc",0,"Mfree",0,"Mshrink",0
				dc.b "Pexec",0,"Pterm",0,0,"Fsfirst",0,"Fsnext",0
				dc.b 0,0,0,0,0
				dc.b 0,"Frename",0,"Fdatime",0,0,0
				dc.b 0,0,"Flock",0,0,0
				rept 255-95
				dc.b 0
				endr
				dc.b "Syield",0,"Fpipe",0,0,0,0
				dc.b "Fcntl",0,"Finstat",0,"Foutstat",0,"Fgetchar",0,"Fputchar",0
				dc.b "Pwait",0,"Pnice",0,"Pgetpid",0,"Pgetppid",0,"Pgetpgrp",0
				dc.b "Psetpgrp",0,"Pgetuid",0,"Psetuid",0,"Pkill",0,"Psignal",0
				dc.b "Pvfork",0,"Pgetgid",0,"Psetgid",0,"Psigblock",0,"Psigsetmask",0
				dc.b "Pusrval",0,"Pdomain",0,"Psigreturn",0,"Pfork",0,"Pwait3",0
				dc.b "Fselect",0,"Prusage",0,"Psetlimit",0,"Talarm",0,"Pause",0
				dc.b "Sysconf",0,"Psigpending",0,"Dpathconf",0,"Pmsg",0,"Fmidipipe",0
				dc.b "Prenice",0,"Dopendir",0,"Dreaddir",0,"Drewinddir",0,"Dclosedir",0
				dc.b "Fxattr",0,"Flink",0,"Fsymlink",0,"Freadlink",0,"Dcntl",0
				dc.b "Fchown",0,"Fchmod",0,"Pumask",0,"Psemaphore",0,"Dlock",0
				dc.b "Psigpause",0,"Psigaction",0,"Pgeteuid",0,"Pgetegid",0,"Pwaitpid",0
				dc.b "Dgetcwd",0,"Salert",0	; 315 and 316
				dc.b -1								; end of list

bios_tab:	dc.b " BIOS "
				dc.b "Getmpb",0,"Bconstat",0,"Bconin",0,"Bconout",0,"Rwabs",0
				dc.b "Setexc",0,"Tickcal",0,"Getbpb",0,"Bcostat",0,"Mediach",0
				dc.b "Drvmap",0,"Kbshift",0
				dc.b -1

xbios_tab:	dc.b "XBIOS "
				dc.b "Initmous",0,"Ssbrk",0,"Physbase",0,"Logbase",0,"Getrez",0
				dc.b "(V)Setscreen",0,"Setpalette",0,"Setcolor",0,"Floprd",0,"Flopwr",0
				dc.b "Flopfmt",0,"Dbmsg",0,"Midiws",0,"Mfpint",0,"Iorec",0
				dc.b "Rsconf",0,"Keytbl",0,"Random",0,"Protobt",0,"Flopver",0
				dc.b "Scrdump",0,"Cursconf",0,"Settime",0,"Gettime",0,"Bioskeys",0
				dc.b "Ikbdws",0,"Jdisint",0,"Jenabint",0,"Giaccess",0,"Offgibit",0
				dc.b "Ongibit",0,"Xbtimer",0,"Dosound",0,"Setprt",0,"Kbdvbase",0
				dc.b "Kbrate",0,"Prtblk",0,"Vsync",0,"Supexec",0,"Puntaes",0
				dc.b 0,"Floprate",0,"DMAread",0,"DMAwrite",0,"Bconmap",0
				dc.b 0,"NVMaccess",0,0,"Metainit",0,0
				dc.b 0,0,0,0,0
				dc.b 0,0,0,0,0
				dc.b 0,0,0,0,"Blitmode",0
				dc.b 0,0,0,0,0
				dc.b 0,0,0,0,0
				dc.b 0,0,0,0,0
				dc.b "EsetShift",0,"EgetShift",0,"EsetBank",0,"EsetColor",0,"EsetPalette",0
				dc.b "EgetPalette",0,"Esetgray",0,"EsetSmear",0,"VsetMode",0,"VgetMonitor",0
				dc.b "VgetSync",0,"Vgetsize",0,"VsetMask",0,"VsetRGB",0,"VgetRGB",0
				dc.b 0,"Dsp_DoBlock",0,"Dsp_BlkHandshake",0,"Dsp_BlkUnpacked",0,"Dsp_InStream",0
				dc.b "Dsp_OutStream",0,"Dsp_IOStream",0,"Dsp_RemoveInterrupts",0,"Dsp_GetWordSize",0,"Dsp_Lock",0
				dc.b "Dsp_Unlock",0,"Dsp_Available",0,"Dsp_Reserve",0,"Dsp_LoadProg",0,"Dsp_ExecProg",0
				dc.b "Dsp_ExecBoot",0,"Dsp_LodToBinary",0,"Dsp_TriggerHC",0,"Dsp_RequestUniqueAbility",0,"Dsp_GetProgAbility",0
				dc.b "Dsp_FlushSubroutines",0,"Dsp_loadSubroutines",0,"Dsp_InqSubrAbility",0,"Dsp_RunSubroutine",0,"Dsp_Hf0",0
				dc.b "Dsp_Hf1",0,"Dsp_Hf2",0,"Dsp_Hf3",0,"Dsp_BlkWords",0,"Dsp_BlkBytes",0
				dc.b "Dsp_Hstat",0,"Dsp_SetVectors",0,"Dsp_MultBlocks",0,"Locksnd",0,"Unlocksnd",0
				dc.b "Soundcmd",0,"Setbuffer",0,"Setmode",0,"Settracks",0,"Setmontracks",0
				dc.b "Setinterrupt",0,"Buffoper",0,"Dsptristate",0,"Gpio",0,"Devconnect",0
				dc.b "Sndstatus",0,"Buffprt",0,0,0,0
				dc.b 0,0,0,0,0
				dc.b 0,0,0,0,0
				dc.b 0,0,0,0,0
				dc.b 0,0,0,0,0
				dc.b "Waveplay",0
				dc.b -1
				
aes_tab:		dc.b " AES  "
				dc.b 0,0,0,0,0
				dc.b 0,0,0,0,0
				dc.b "appl_init",0,"appl_read",0,"appl_write",0,"appl_find",0,"appl_tplay",0
				dc.b "appl_trecord",0,0,0,"appl_search",0,"appl_exit",0
				dc.b "evnt_keybd",0,"evnt_button",0,"evnt_mouse",0,"evnt_mesag",0,"evnt_timer",0
				dc.b "evnt_multi",0,"evnt_dclick",0,0,0,0
				dc.b "menu_bar",0,"menu_icheck",0,"menu_ienable",0,"menu_tnormal",0,"menu_text",0
				dc.b "menu_register",0,"menu_popup",0,"menu_attach",0,"menu_istart",0,"menu_settings",0
				dc.b "objc_add",0,"objc_delete",0,"objc_draw",0,"objc_find",0,"objc_offset",0
				dc.b "objc_order",0,"objc_edit",0,"objc_change",0,"objc_sysvar",0,0
				dc.b "form_do",0,"form_dial",0,"form_alert",0,"form_error",0,"form_center",0
				dc.b "form_keyb",0,"form_button",0,0,0,0
				dc.b 0,0,0,0,0
				dc.b 0,0,0,0,0
				dc.b "graf_rubberbox",0,"graf_dragbox",0,"graf_movebox",0,"graf_growbox",0,"graf_shrinkbox",0
				dc.b "graf_watchbox",0,"graf_slidebox",0,"graf_handle",0,"graf_mouse",0,"graf_mkstate",0
				dc.b "scrp_read",0,"scrp_write",0,0,0,0
				dc.b 0,0,0,0,0
				dc.b "fsel_input",0,"fsel_exinput",0,0,0,0
				dc.b 0,0,0,0,0
				dc.b "wind_create",0,"wind_open",0,"wind_close",0,"wind_delete",0,"wind_get",0
				dc.b "wind_set",0,"wind_find",0,"wind_update",0,"wind_calc",0,"wind_new",0
				dc.b "rsrc_load",0,"rsrc_free",0,"rsrc_gaddr",0,"rsrc_saddr",0,"rsrc_obfix",0
				dc.b "rsrc_rcfix",0,0,0,0,0
				dc.b "shel_read",0,"shel_write",0,"shel_get",0,"shel_put",0,"shel_find",0
				dc.b "shel_envrn",0,0,0,0,0
				dc.b "appl_getinfo",0
				dc.b -1
				
vdi_tab:		dc.b " VDI  "
				dc.b 0,"v_opnwk",0,"v_clswk",0,"v_clrwk",0,"v_updwk",0
				dc.b "Unknown sub-opcode 0",0,"v_pline",0,"v_pmarker",0,"v_gtext",0,"v_fillarea",0
				dc.b "v_cellarray",0,"Unknown sub-opcode 0",0,"vst_height",0,"vst_rotation",0,"vs_color",0
				dc.b "vsl_type",0,"vsl_width",0,"vsl_color",0,"vsm_type",0,"vsm_height",0
				dc.b "vsm_color",0,"vst_font",0,"vst_color",0,"vsf_interior",0,"vsf_style",0
				dc.b "vsf_color",0,"vq_color",0,"vq_cellarray",0,"vrq/vsm_locator",0,"vrq/vsm_valuator",0
				dc.b "vrq/vsm_choice",0,"vrq/vsm_string",0,"vswr_mode",0,"vsin_mode",0,0
				dc.b "vql_attributes",0,"vqm_attributes",0,"vqf_attributes",0,"vqt_attributes",0,"vst_alignment",0
				rept 100-40
				dc.b 0
				endr
				dc.b "v_opnvwk",0,"v_clsvwk",0,"vq_extnd",0,"v_contourfill",0,"vsf_perimeter",0
				dc.b "v_get_pixel",0,"vst_effects",0,"vst_point",0,"vsl_ends",0,"vro_cpyfm",0
				dc.b "vr_trnfm",0,"vsc_form",0,"vsf_udpat",0,"vsl_udsty",0,"vr_recfl",0
				dc.b "vqin_mode",0,"vqt_extend",0,"vqt_width",0,"vex_timv",0,"vst_loadfonts",0
				dc.b "vst_unloadfonts",0,"vrt_cpyfm",0,"v_show_c",0,"v_hide_c",0,"vq_mouse",0
				dc.b "vex_butv",0,"vex_motv",0,"vex_curv",0,"vq_key_s",0,"vs_clip",0
				dc.b "vqt_name",0,"vqt_fontinfo",0
				rept 230-132
				dc.b 0
				endr
				dc.b 0,0,"vqt_fontheader",0,0,"vqt_trackkern",0
				dc.b "vqt_pairkern",0,"vst_charmap",0,"vst_kern",0,0,"v_getbitmap_info",0
				dc.b "vqt_f_extent/16",0,"v_ftext/16/offset",0,"v_killoutline",0,"v_getoutline",0,"vst_scratch",0
				dc.b "vst_error",0,"vst_arbpt/32",0,"vq_advance/32",0,"vqt_devinfo",0,"v_savecache",0
				dc.b "v_loadcache",0,"v_flushcache",0,"vst_setsize/32",0,"vst_skew",0,"vqt_get_table",0
				dc.b "vqt_cachesize",0	; 255
				dc.b -1
				
				even

vdisubfn_trans:
				dc.w 5	;funtion number
							; then by 2, the subfunction intervals 
				dc.w 1,25+1,60,60+1,81,85+1,91,102+1,2000,2000+1,-1
				dc.w 6
				dc.w 13,13+1,-1
				dc.w 9
				dc.w 13,13+1,-1
				dc.w 11
				dc.w 1,13+1,-1
				dc.w -1

vdisubfn_tab: dc.b " VDI  "
				; 5 sub 1-25
				dc.b "vq_chcells",0,"v_exit_cur",0,"v_enter_cur",0,"v_cur_up",0,"v_cur_down",0
				dc.b "v_curright",0,"v_curleft",0,"v_curhome",0,"v_eeos",0,"v_eeol",0
				dc.b "vs_curaddress",0,"v_curtext",0,"v_rvon",0,"v_rvoff",0,"vq_curaddress",0
				dc.b "vq_tabstatus",0,"v_hardcopy",0,"v_dspcur",0,"v_rmcur",0,"v_form_adv",0
				dc.b "v_output_window",0,"v_clear_disp_list",0,"v_bit_image",0,"vq_scan",0,"v_alpha_text",0
				; 5 sub 60
				dc.b "vs_palette",0
				; 5 sub 81-85
				dc.b "vt_resolution",0,"vt_axis",0,"vt_origin",0,"vq_tdimensions",0,"vt_alignment",0
				; 5 sub 91-102
				dc.b "vqp_films",0,"vqp_state",0,"vsp_state",0,"vsp_save",0,"vsp_message",0
				dc.b "vqp_error",0,0,"v_meta_extents",0,"v_write_meta/pagesize/coords/bez_qual",0,"wm_filename",0
				dc.b 0,"v_fontinit",0
				; 5 sub 2000
				dc.b "v_pgcount",0
				; 6 sub 13
				dc.b "v_bez",0
				; 9 sub 13
				dc.b "v_bez_fill",0
				; 11 sub 1-13
				dc.b "v_bar",0,"v_arc",0,"v_piesclice",0,"v_circle",0,"v_ellipse",0
				dc.b "v_ellarc",0,"v_ellpie",0,"v_rbox",0,"v_rfbox",0,"v_justified",0
				dc.b 0,0,"v_bez_on/off",0
				dc.b -1
				
							
linea_tab:	dc.b "Line A"
				dc.b "Init",0,"Plot Pixel",0,"Get pixel",0,"Line",0,"Hline",0
				dc.b "Frect",0,"Fpoly",0,"Bitblt",0,"Textblt",0,"Showm",0
				dc.b "Hidem",0,"Transfm",0,"Undraw Sprite",0,"Draw Sprite",0,"Copy Raster",0
				dc.b "Seed Fill",0
				dc.b -1
				
			
	even

fn_ptr: dc.l fn_zone
sub_ptr:
gemdos_fn: dc.l 0
bios_fn: dc.l 0
xbios_fn: dc.l 0
vdi_fn: dc.l 0
aes_fn: dc.l 0
linea_fn: dc.l 0
	dc.l 0


	bss
programme: ds.l 1
options: ds.l 1
buff_size: ds.l 1
zone_ptr: ds.l 1
buffer: ds.l 1
command: ds.l 1
_cpu: ds.l 1
save_stack: ds.l 1
basepage: ds.l 1
start_text: ds.l 1
end_text: ds.l 1
old_trap1: ds.l 1
old_trap2: ds.l 1
old_trap13: ds.l 1
old_trap14: ds.l 1
old_linea: ds.l 1
old_alt_help: ds.l 1
save_a2: ds.l 1
save_d0: ds.l 1
fn_zone: ds.l 100

zone: ds.b 128*3+2048	; 3 strings and the buffer for SYSREC.INF

	end
