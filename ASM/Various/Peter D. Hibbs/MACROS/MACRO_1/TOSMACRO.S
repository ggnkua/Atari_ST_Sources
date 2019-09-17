;TOS MACRO file for DevPac assembler
;Version 1.      15-10-1993      Compiled by Peter Hibbs

;    ---------------- Operating System Macros -------------------

;Calls TRAP No #1 and then tidies up stack and tests d0.l

gemdos 	MACRO		trap No, stack size
	move	\1,-(sp)
	trap	#1
	add	\2,sp
	tst	d0
	ENDM

;Calls TRAP No #13 and then tidies up stack and tests d0.l

bios 	MACRO		trap No, stack size
	move	\1,-(sp)
	trap	#13
	add	\2,sp
	tst	d0
	ENDM

;Calls TRAP No #14 and then tidies up stack and tests d0.l

xbios 	MACRO		trap No, stack size
	move	\1,-(sp)
	trap	#14
	add	\2,sp
	tst	d0
	ENDM

;   ------------------------ GEMDOS (TRAP #1) ---------------------

p_term0	MACRO
	clr	-(sp)
	trap	#1
	illegal
	ENDM
	
c_conin	MACRO
	gemdos	#1,#2
	ENDM

c_conout	MACRO		1\char
	move	\1,-(sp)
	gemdos	#2,#4
	ENDM

c_auxin	MACRO
	gemdos	#3,#2
	ENDM
	
c_auxout	MACRO		1\char
	move	\1,-(sp)
	gemdos	#4,#4
	ENDM

c_prnout	MACRO		1\char
	move	\1,-(sp)
	gemdos	#5,#4
	ENDM

c_rawio	MACRO		1\char
	move	\1,-(sp)
	gemdos	#6,#4
	ENDM

c_rawcin	MACRO
	gemdos	#7,#2
	ENDM

c_necin	MACRO
	gemdos	#8,#2
	ENDM

c_conws 	MACRO		1\buffer_addr
	move.l	\1,-(sp)
	gemdos	#9,#6
	ENDM

c_conrs 	MACRO		1\buffer_addr
	move.l	\1,-(sp)
	gemdos	#10,#6
	ENDM

c_conis	MACRO
	gemdos	#11,#2
	ENDM

d_setdrv 	MACRO		1\drive_No
	move	\1,-(sp)
	gemdos	#14,#4
	ENDM

c_conos	MACRO
	gemdos	#16,#2
	ENDM

c_prnos	MACRO
	gemdos	#17,#2
	ENDM

c_auxis	MACRO
	gemdos	#18,#2
	ENDM

c_auxos	MACRO
	gemdos	#19,#2
	ENDM

m_addalt	MACRO		1\size,2\address
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	gemdos	#20,#10
	ENDM

d_getdrv	MACRO
	gemdos	#25,#2
	ENDM

f_setdta 	MACRO		1\buffer_address
	move.l	\1,-(sp)
	gemdos	#26,#6
	ENDM

super	MACRO
	clr.l	-(sp)
	gemdos	#32,#6
	ENDM

user	MACRO		1\old stack
	move.l	\1,-(sp)
	gemdos	#32,#6
	ENDM

t_getdate	MACRO
	gemdos	#42,#2
	ENDM

t_setdate 	MACRO		1\date
	move	\1,-(sp)
	gemdos	#43,#4
	ENDM

t_gettime	MACRO
	gemdos	#44,#2
	ENDM

t_settime 	MACRO		1\time
	move	\1,-(sp)
	gemdos	#45,#4
	ENDM

f_getdta	MACRO
	gemdos	#47,#2
	ENDM

s_version	MACRO
	gemdos	#48,#2
	ENDM

p_termres	MACRO		1\ret_code,2\bytes
	move	\1,-(sp)
	move.l	\2,-(sp)
	gemdos	#49,#8
	ENDM

d_free	MACRO		1\drive,2\buffer
	move	\1,-(sp)
	move.l	\2,-(sp)
	gemdos	#54,#8
	ENDM

d_create	MACRO		1\address
	move.l	\1,-(sp)
	gemdos	#57,#6
	ENDM

d_delete	MACRO		1\address
	move.l	\1,-(sp)
	gemdos	#58,#6
	ENDM

d_setpath	MACRO		1\address
	move.l	\1,-(sp)
	gemdos	#59,#6
	ENDM

f_create 	MACRO		1\attribute,2\filename
	move	\1,-(sp)
	move.l	\2,-(sp)
	gemdos	#60,#8
	ENDM

f_open 	MACRO		1\attribute,2\filename
	move	\1,-(sp)
	move.l	\2,-(sp)
	gemdos	#61,#8
	ENDM

f_close 	MACRO		1\fhandle
	move	\1,-(sp)
	gemdos	#62,#4
	ENDM

f_read 	MACRO		1\buffer,2\count,3\fhandle
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move	\3,-(sp)
	gemdos	#63,#12
	ENDM

f_write 	MACRO		1\buffer,2\count,3\fhandle
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move	\3,-(sp)
	gemdos	#64,#12
	ENDM

f_delete 	MACRO		1\filename
	move.l	\1,-(sp)
	gemdos	#65,#6
	ENDM

f_seek 	MACRO		1\mode,2\fhandle,3\offset
	move	\1,-(sp)
	move	\2,-(sp)
	move.l	\3,-(sp)
	gemdos	#66,#10
	ENDM

f_attrib	MACRO		1\attrib,2\get/set,3\address
	move	\1,-(sp)
	move	\2,-(sp)
	move.l	\3,-(sp)
	gemdos	#67,#10
	ENDM

f_dup	MACRO		1\standard_handle
	move	\1,-(sp)
	gemdos	#69,#4
	ENDM

f_force	MACRO		1\nstdh,2\stdh
	move	\1,-(sp)
	move	\2,-(sp)
	gemdos	#70,#6
	ENDM

d_getpath	MACRO		1\drive,2\address
	move	\1,-(sp)
	move.l	\2,-(sp)
	gemdos	#71,#8
	ENDM

m_alloc	MACRO		1\size
	move.l	\1,-(sp)
	gemdos	#72,#6
	ENDM

m_free	MACRO		1\address
	move.l	\1,-(sp)
	gemdos	#73,#6
	ENDM

m_shrink 	MACRO		1\newsize,2\block
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	clr	-(sp)
	gemdos	#74,#12
	ENDM

p_exec 	MACRO		1\environ,2\command,3\filename,4\mode
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move	\4,-(sp)
	gemdos	#75,#16
	ENDM

p_term 	MACRO		1\return_code or nothing
	IFNE 	\?1
	move	\1,-(sp)
	ELSE
	clr	-(sp)
	ENDC
	move	#76,-(sp)
	trap	#1
	illegal		generate error if no return
	ENDM

f_sfirst 	MACRO		1\attribute,2\filespec
	move	\1,-(sp)
	move.l	\2,-(sp)
	gemdos	#78,#8
	ENDM

f_snext	MACRO
	gemdos	#79,#2
	ENDM

f_rename	MACRO		1\newname,2\oldname
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	clr	-(sp)	dummy
	gemdos	#86,#12
	ENDM

f_datime	MACRO		1\mode,2\fhandle,3\buffer
	move	\1,-(sp)
	move.l	\3,-(sp)
	move	\2,-(sp)
	gemdos	#87,#10
	ENDM

;------------------------BIOS (TRAP #13) -------------------------

getmpb 	MACRO		1\pointer
	move.l	\1,-(sp)
	bios 	#0,#6
	ENDM

bconstat 	MACRO		1\device
	move	\1,-(sp)
	bios	#1,#4
	ENDM

bconin 	MACRO		1\device
	move	\1,-(sp)
	bios	#2,#4
	ENDM

bconout 	MACRO		1\character,2\device
	move	\1,-(sp)
	move	\2,-(sp)
	bios	#3,#6
	ENDM

rwabs 	MACRO		1\drive,2\recno,3\count,4\buffer,5\mode
	move	\1,-(sp)
	move	\2,-(sp)
	move	\3,-(sp)
	move.l	\4,-(sp)
	move	\5,-(sp)
	bios	#4,#14
	ENDM

setexc 	MACRO		1\vecaddress,2\vecnum
	move.l	\1,-(sp)
	move	\2,-(sp)
	bios	#5,#8
	ENDM

tickcal	MACRO
	bios	#6,#2
	ENDM

getbpb 	MACRO		1\deviceno
	move	\1,-(sp)
	bios	#7,#4
	ENDM

bcostat 	MACRO		1\deviceno
	move 	\1,-(sp)
	bios	#8,#4
	ENDM

mediach 	MACRO		1\deviceno
	move	\1,-(sp)
	bios	#9,#4
	ENDM

drvmap	MACRO
	bios	#10,#2
	ENDM

kbshift 	MACRO		1\mode
	move	\1,-(sp)
	bios	#11,#4
	ENDM

;-------------------- Extended BIOS (TRAP #14) ----------------

initmous 	MACRO		1\mode,2\parameter,3\vector
	move.l	\3,(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	xbios	#0,#12
	ENDM

physbase	MACRO
	xbios	#2,#2
	ENDM

logbase	MACRO
	xbios	#3,#2
	ENDM

getrez	MACRO
	xbios	#4,#2
	ENDM

setscreen 	MACRO		1\mode,2\physaddress,3\logaddress
	move	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	xbios	#5,#12
	ENDM

setpalette 	MACRO		1\pointer
	move.l	\1,-(sp)
	xbios	#6,#6
	ENDM

setcolor 	MACRO		1\color,2\colnumber
	move	\1,-(sp)
	move	\2,-(sp)
	xbios	#7,#6
	ENDM
	
floprd 	MACRO		1\count,2\sideno,3\trackno,4\sectno,5\driveno,6\buffer
	move	\1,-(sp)
	move	\2,-(sp)
	move	\3,-(sp)
	move	\4,-(sp)
	move	\5,-(sp)
	clr.l	-(sp)	; (filler)
	move.l	\6,-(sp)
	xbios	#8,#20
	ENDM

flopwr 	MACRO		1\count,2\sideno,3\trackno,4\sectno,5\driveno,6\buffer
	move	\1,-(sp)
	move	\2,-(sp)
	move	\3,-(sp)
	move	\4,-(sp)
	move	\5,-(sp)
	clr.l	-(sp)	; (filler)
	move.l	\6,-(sp)
	xbios	#9,#20
	ENDM

flopfmt 	MACRO		1\newdata,2\magic,3\interlv,4\sideno,5\trackno,6\sector,7\driveno,8\buffer
	move	\1,-(sp)
	move.l	\2,-(sp)
	move	\3,-(sp)
	move	\4,-(sp)
	move	\5,-(sp)
	move	\6,-(sp)
	move	\7,-(sp)
	clr.l	-(sp)	; (filler)
	move.l	\8,-(sp)
	xbios	#10,#26
	ENDM

midiws 	MACRO		1\pointer,2\count
	move.l	\1,-(sp)
	move	\2,-(sp)
	xbios	#12,#8
	ENDM

mfpint	MACRO		1\address,2\number
	move.l	\1,-(sp)
	move	\2,-(sp)
	xbios	#13,#8
	ENDM

iorec	MACRO		1\device
	move	\1,-(sp)
	xbios	#14,#4
	ENDM

rsconf	MACRO		1\scr,2\tsr,3\rsr,4\ucr,5\ctrl,6\baud
	move	\1,-(sp)
	move	\2,-(sp)
	move	\3,-(sp)
	move	\4,-(sp)
	move	\5,-(sp)
	move	\6,-(sp)
	xbios	#15,#14
	ENDM

keytbl	MACRO		1\caps,2\shift,3\unshift
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	xbios	#16,#14
	ENDM

random	MACRO
	xbios	#17,#2
	ENDM

protobt 	MACRO		1\execflag,2\disktype,3\serialno,4\buffer
	move	\1,-(sp)
	move	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	xbios	#18,#14
	ENDM

flopver 	MACRO		1\count,2\sideno,3\trackno,4\sectno,5\driveno,6\buffer
	move	\1,-(sp)
	move	\2,-(sp)
	move	\3,-(sp)
	move	\4,-(sp)
	move	\5,-(sp)
	clr.l	-(sp)	; (filler)
	move.l	\6,-(sp)
	xbios	#19,#20
	ENDM

scrdmp	MACRO
	xbios	#20,#2
	ENDM

cursconf 	MACRO		1\flash,2\function
	move	\1,-(sp)
	move	\2,-(sp)
	xbios	#21,#6
	ENDM

settime	MACRO		1\time
	move.l	\1,-(sp)
	xbios	#22,#6
	ENDM

gettime	MACRO
	xbios	#23,#2
	ENDM

bioskeys	MACRO
	xbios	#24,#2
	ENDM

ikbdws	MACRO		1\pointer,2\number
	move.l	\1,-(sp)
	move	\2,-(sp)
	xbios	#25,#8
	ENDM

jdisint	MACRO		1\number
	move	\1,-(sp)
	xbios	#26,#4
	ENDM

jenabint	MACRO		1\number
	move	\1,-(sp)
	xbios	#27,#4
	ENDM

giaccess	MACRO		1\register,2\data
	move	\1,-(sp)
	move	\2,-(sp)
	xbios	#28,#6
	ENDM

offgbit	MACRO		1\bit_mask
	move	\1,-(sp)
	xbios	#29,#4
	ENDM

ongibit	MACRO		1\bit_mask
	move	\1,-(sp)
	xbios	#30,#4
	ENDM

xbtimer	MACRO		1\vector,2\data,3\cntrl,4\timer
	move.l	\1,-(sp)
	move	\2,-(sp)
	move	\3,-(sp)
	move	\4,-(sp)
	xbios	#31,#12
	ENDM

dosound	MACRO		1\pointer
	move.l	\1,-(sp)
	xbios	#32,#6
	ENDM

setprt	MACRO		1\config
	move	\1,-(sp)
	xbios	#33,#4
	ENDM

kbdvbase	MACRO
	xbios	#34,#2
	ENDM

kbrate	MACRO		1\repeat,2\delay
	move	\1,-(sp)
	move	\2,-(sp)
	xbios	#35,#6
	ENDM

prtblk	MACRO		1\pointer
	move.l	\1,-(sp)
	xbios	#36,#6
	ENDM

vsync	MACRO
	xbios	#37,#2
	ENDM

supexec 	MACRO		1\where
	move.l	\1,-(sp)
	xbios	#38,#6
	ENDM

puntaes	MACRO
	xbios	#39,#2
	ENDM

;floprate

;dmaread

;dmawrite

;bconmap

;nvmaccess

;blitmode

;esetshift

;egetshift

;esetbank

;esetcolor

;esetpalette

;egetpalette

;esetgray

;esetsmear

