*
*
* 	JAGUAR GAME
*
*

; Directives par souci de clart‚ des sources :
; 
; - Les registres provenant de JAGUAR.INC doivent être utilisés en majuscule.
; - Les equivalences doivent être aussi mises en majuscule.
; - Les adresses sous ORG sont preced‚es du caractŠre soulign‚. (sauf locaux)
; - Les labels dans la definition de l'object-list sont pr‚cŠd‚s de "l_"
; - Le point-virgule des commentaires doit être mis sur la 2Šme tabulation. 



		include	"jaguar.inc"

		include	"obl_mac4.s"





; Constantes


; Screen

SCR_W		= 32
SCR_H		= 20
SCR_BLT		= WID32
SCR_WIDTH	= 32
PWIDTH		= PIXEL8
O_DEPTH		= O_DEPTH8
NB_COLORS	= 256 





; GPU equivalences

ISTACK		= G_ENDRAM-256-4	; Location of interrupt stack
ADR_GPUCODE	= G_RAM+$30		; == GPU Object Processor Interrupt

ISTACKD		= D_ENDRAM-256-4	; Location of interrupt stack
ADR_DPCODE	= D_RAM			; == DSP Object Processor Interrupt


*------------------------------------------------------------------------
		text
*-------------------------------------------------------------------------

		.68000



main:		move.l	#INITSTACK,a7		; Stack location = end of ram-4
		bsr	InitJag

		bra.s 	*

		illegal



*************** Initialize Jaguar video, object list and interrupts

InitJag:	move.l	#$70007,G_END
		move.l	#$70007,D_END
		move.w	#-1,VI
		bsr	vidinit			; Initialize video

		bsr	sndinit

		lea	def_list1,a0
		lea	objet_list,a1		; object-list address 
		lea	buf_list,a2
		jsr	Lister
		move.l	#update_list1,_update_list

		lea	gpucode_start,a0	; address of GPU code in RAM
		lea	ADR_GPUCODE+$8000,a1	; fast write mode only in G_RAM	
		move.l	#(gpucode_end-gpucode_start)-1,d0
		bsr	gpuload
		
		move.l  #G_OPENA|REGPAGE,G_FLAGS; Enable GPU Interrupts from OP
		move.l	#_gpucode,G_PC		; address of GPU code 
		move.l  #GPUGO,G_CTRL		; Start GPU
		
		move.l	def_list1,d0		; first object address
		swap	d0
		move.l	d0,OLP			; Start Object-list
		
		move.w	#CRY16|VIDEN|CSYNC|BGEN|PWIDTH4,VMODE
		rts
		
sndinit:
		moveq	#0,d0
		move.l	d0,R_I2S
		move.l	d0,L_I2S
		move.w	#$100,JOYSTICK
		
		move.l	d0,D_CTRL
		move.l	d0,D_FLAGS
		
		move.l	#24,SCLK
		move.l	#$15,SMODE
		
		move.w	d0,JPIT2
		move.w	d0,JPIT1
		
		lea	dspcode_start,a0	; address of GPU code in RAM
		lea	D_RAM,a1			
		move.l	#(dspcode_end-dspcode_start)-1,d0
		bsr	gpuload
		
		move.l	#_dspcode,D_PC		; address of GPU code 
		move.l  #DSPGO,D_CTRL		; Start GPU
		rts
		
		
********************************************************************
***       							****
********************************************************************


		dsp
		
		phrase
		
dspcode_start:
		org	D_RAM
		
		movei	#_dspcode,r0
		jump	(r0)
		nop
		nop
		nop
		nop
		
		movei	#_i2s_int,r29
		jump	(r29)
		nop
		nop
		nop
		nop
		
		movei	#_pit1,r29
		jump	(r29)
		nop
		
_dspcode:	movei	#ISTACKD,r31

		movei	#D_FLAGS,r1
		load	(r1),r0
		movei	#REGPAGE|D_I2SENA,r2
		or	r2,r0
		store	r0,(r1)
		nop
		nop
		
_run:		
		movei	#BG,r1		
		movei	#$F8FF,r0
		storew	r0,(r1)

		movei	#_run,r0
		jump	(r0)
		nop
		
_index1:	dc.l	0
_index2:	dc.l	2000

_i2s_int:	
	movei	#BG,r16
	movei	#$F0FF,r17
	storew	r17,(r16)

		movei	#_index2,r16
		movei	#sample2,r17
		load	(r16),r0
		add	r0,r17
		addq	#1,r0
		bclr	#12,r0
		store	r0,(r16)
		loadb	(r17),r0

		shlq	#24,r0
		sharq	#19,r0
		
		move	r0,r1

		movei	#_index1,r16		
		movei	#sample1,r17
		load	(r16),r0
		add	r0,r17
		addq	#1,r0
		bclr	#15,r0
		store	r0,(r16)
		loadb	(r17),r0

		shlq	#24,r0
		sharq	#18,r0
	
		
		add	r0,r1
		
		movei	#L_I2S,r16	
		store	r1,(r16)
		addq	#4,r16
		store	r1,(r16)
		subq	#4,r16
		
		movei	#D_FLAGS,r30
		load	(r31),r28
		load	(r30),r29
		addq	#4,r31
		bclr	#3,r29
		addq	#2,r28
		bset	#10,r29	
		jump	(r28)
		store	r29,(r30)
		nop
		nop

_pit1:
		movei	#D_FLAGS,r30
		load	(r31),r28
		load	(r30),r29
		addq	#4,r31
		bclr	#3,r29
		addq	#2,r28
		bset	#10,r29	
		jump	(r28)
		store	r29,(r30)
		nop
		nop

		
		.68000
dspcode_end:
		

*-------------------------------------------------------------------------
		gpu
*-------------------------------------------------------------------------

		phrase

gpucode_start:

		org	ADR_GPUCODE

****************************************************************************** 
*
*		            OP interrupt
*
****************************************************************************** 

r_stack		equr	r31	
r_reserved	equr	r30
r_save_hidata	equr	r29

r_base		equr	r28
r_temp		equr	r27
r_temp2		equr	r26


*---------------

_gpucode_op_it:	movei	#G_HIDATA,r_base	; * point to HIDATA register
		movei   #OBF,r_temp		; --- Write any value to OBF
		load	(r_base),r_save_hidata	; * to save the hidata value
		movei	#OB2,r_base
		load	(r_base),r_temp2
		storew  r_save_hidata,(r_temp)	; --- to restart Object Processor
		jump	(r_temp2)
		nop


***************************************************************************************** 
*
*			Update de l'object-list		            
*
***************************************************************************************** 

	;		r28	= r_base
	; 		r27	= r_temp
	; 		r26	= r_temp2
r_object	equr	r25
r_iwidth	equr	r24
r_xpos		equr	r23
r_width		equr	r22
r_data		equr	r21
r_height	equr	r20
r_ypos		equr	r19


_update_obl:	movei	#_update_list,r_base
		load	(r_base),r_base		; get update-list address

_update_next:	loadw	(r_base),r_temp		; ID object
		addq	#4,r_base

		cmpq	#0,r_temp		; Null terminated ?
		jr	ne,.test_bitmap
		nop
		movei	#_read_joy1,r_temp	; jump to next code
		jump	(r_temp)
		nop
		
.test_bitmap:	cmpq	#3,r_temp		; faux update … skipper  
		jr	mi,.type_bitmap
		nop
		movei	#_update_next,r_temp	; skip
		jump	(r_temp)
		addq	#5*4,r_base

.type_bitmap:	load	(r_base),r_object
		addq	#4,r_base
		load	(r_object),r_object	; get address object

		load	(r_base),r_width	; [ Width | Vscale & Hscale ]
		moveq	#0,r_data
		addq	#4,r_base

		cmpq	#2,r_temp		; test if scale bitmap
		jr	ne,.simple_bitmap
		nop

.scale_bitmap:	addq	#21,r_object		; point to last long of third phrase
		storeb	r_data,(r_object)	; clear remainder field (8bits)	
		addq	#1,r_object
		storew	r_width,(r_object)	; direct updating scale values
		subq	#22,r_object

.simple_bitmap:	shrq	#16,r_width		; keep only Width value	

		load	(r_base),r_data		; [ Data ]
		addq	#4,r_base

		load	(r_base),r_xpos		; [ XPOS | YPOS ]
		movei	#$ffff,r_temp
		addq	#4,r_base
		move	r_xpos,r_ypos
		shrq	#16,r_xpos
		and	r_temp,r_ypos
		
		load	(r_base),r_iwidth	; [ Height | IWidth ]
		addq	#4,r_base
		move	r_iwidth,r_height
		shrq	#16,r_height
		jr	ne,.actif		; Height null => end update
		nop
		addq	#8,r_base		; skip last update value
		movei	#_update_next,r_temp
		jump	(r_temp)
		nop

.actif:		and	r_temp,r_iwidth

		btst	#10,r_ypos		; YPOS negatif ? 
		jr	eq,.no_y_clip		; no need nop
		move	r_ypos,r_temp
		bclr	#0,r_temp		; YPOS pair 
		shlq	#16+5,r_temp		; extend on 32 bit for
		sharq	#17+5,r_temp		; comparaison and calculs
		move	r_temp,r_temp2
		add	r_height,r_temp2
		jr	mi,.no_y_clip		; => object not visible
		neg	r_temp			; delta y
		move	r_temp2,r_height	; new height value
		mult	r_width,r_temp
		add	r_temp,r_data		; new data value
		moveq	#0,r_ypos		; new YPOS value
		
.no_y_clip:	load	(r_object),r_temp2
		movei	#$7ff,r_temp		; clear data field
		and	r_temp,r_temp2
		shrq	#3,r_data		; phrase alignement
		shlq	#11,r_data		; shift
		or	r_data,r_temp2
		store	r_temp2,(r_object)	; data value updating 
		
		addq	#4,r_object		; point to Height & YPOS fields		
		load	(r_object),r_temp2
		movei	#$ff000007,r_temp	; clear height & ypos fields
		and	r_temp,r_temp2
		shlq	#14,r_height		; shift 
		addq	#25,r_ypos
		or	r_height,r_temp2
		shlq	#3,r_ypos		; shift 
		or	r_ypos,r_temp2
		store	r_temp2,(r_object)	; height & ypos values updating 

		equrundef r_width
		equrundef r_data
		equrundef r_height
		equrundef r_ypos

	;		r28	= r_base
	;		r27	= r_temp
	;		r26	= r_temp2
	;		r25	= r_object
	;		r24	= r_iwidth
	;		r23	= r_xpos
r_1stpix	equr	r22
r_flags		equr	r21
r_index		equr	r20
r_dwidth	equr	r19
		
		load	(r_base),r_1stpix	; [ Index | flag_upd | 1st Pix ]
		btst	#16,r_1stpix		; flag_upd = true ?
		jr	ne,.upd_fields
		bclr	#16,r_1stpix		; clear flag_upd
		addq	#8,r_object		; point to last long
		load	(r_object),r_temp2	; get last long
		movei	#$fffff000,r_temp	; clear XPOS fields
		addq	#8,r_base		; skip last update value
		and	r_temp,r_temp2
		movei	#.last_field,r_temp
		jump	(r_temp)
		nop

.upd_fields:	move	r_1stpix,r_index
		movei	#$ffff,r_temp
		shrq	#17,r_index
		store	r_1stpix,(r_base)	; save new flag_upd value
		shlq	#6,r_index		; shift 
		addq	#4,r_base
		and	r_temp,r_1stpix	
		
		addq	#4,r_object		; point to 2nd phrase
		load	(r_object),r_temp2
		or	r_index,r_temp2
		shlq	#17,r_1stpix		; shift 
		or	r_1stpix,r_temp2	; 1st pix updated
		
		load	(r_base),r_flags	; get flags values
		move	r_iwidth,r_dwidth
		addq	#4,r_base
		or	r_flags,r_temp2		; flags updated
		
		move	r_iwidth,r_temp
		shrq	#4,r_temp		; shift 
		or	r_temp,r_temp2		; one part of Iwidth updated
		
		store	r_temp2,(r_object)	; updating 3 fields

		addq	#4,r_object		; point to last longword
		load	(r_object),r_temp2
		shlq	#18,r_dwidth
		movei	#$0003f000,r_temp	; clear Iwidth,Dwidth & XPOS fields
		and	r_temp,r_temp2
		or 	r_dwidth,r_temp2
		shlq	#28,r_iwidth		; shift 
		or	r_iwidth,r_temp2	; last part of Iwidth updated

.last_field:	or	r_xpos,r_temp2
		store	r_temp2,(r_object)	; updating XPOS & Iwidth fields									
		
		movei	#_update_next,r_temp
		jump	(r_temp)
		nop

		equrundef r_object
		equrundef r_iwidth
		equrundef r_xpos
		equrundef r_1stpix
		equrundef r_flags



***************************************************************************************** 
*
*			Lecture du joystick		            
*
***************************************************************************************** 

	;		r28	= r_base
	;		r27	= r_temp
	;		r26	= r_temp2
r_joy1		equr	r25

_read_joy1:	;movei	#BG,r12
		;movei	#0,r13
		;storew	r13,(r12)

		movei	#JOYSTICK,r_base
		movei	#-1,r_temp		; Cumulative joypad reading
		movei	#$f0fffffc,r_temp2	; Joypad data mask
		
		movei	#$81fe,r_joy1		; Read joypad, pause button, A button
		storew	r_joy1,(r_base)
		load	(r_base),r_joy1
		or	r_temp2,r_joy1		; Mask off unused bits
		rorq	#4,r_joy1
		and	r_joy1,r_temp		; = xxAPxxxx RLDUxxxx xxxxxxxx xxxxxxxx

		movei	#$81fd,r_joy1		; Read *741 keys, B button
		storew	r_joy1,(r_base)
		load	(r_base),r_joy1	
		or	r_temp2,r_joy1		
		rorq	#8,r_joy1
		and	r_joy1,r_temp		; = xxAPxxBx RLDU741* xxxxxxxx xxxxxxxx

		movei	#$81fb,r_joy1		; Read 2580 keys, C button
		storew	r_joy1,(r_base)
		load	(r_base),r_joy1
		or	r_temp2,r_joy1
		rorq	#32-12,r_joy1
		and	r_joy1,r_temp		; = xxAPxxBx RLDU741* xxCxxxxx 2580xxxx

		movei	#$81f7,r_joy1		; Read 369# keys, Option button
		storew	r_joy1,(r_base)
		load	(r_base),r_joy1
		or	r_temp2,r_joy1
		rorq	#32-8,r_joy1
		and	r_joy1,r_temp		; = xxAPxxBx RLDU741* xxCxxxOx 2580369#

		movei	#-1,r_joy1		; inputs active low
		xor	r_temp,r_joy1		; now inputs active high

		movei	#_joy1,r_base
		load	(r_base),r_temp2	; old joycur needed for determining the new joyedge
.current:	store	r_joy1,(r_base)		; Current joypad reading stored into joycur

		xor	r_joy1,r_temp2
		addq	#4,r_base
		and	r_joy1,r_temp2		; IF DESIRED (AS DOCUMENTED ABOVE)  REMOVE THIS AND
.just_pressed:	store	r_temp2,(r_base)	; joypad, buttons, keys that were just pressed


		equrundef r_joy1



***************************************************************************************** 
*
*			Fin de l'interruption OP	            
*
***************************************************************************************** 

	;		r28	= r_base
	;		r27	= r_temp
	;		r26	= r_temp2
r_object	equr	r25


_it_end:	movei	#G_HIDATA,r_object	; * point to HIDATA register
		load	(r_stack),r_temp	; -- get address of last instruction
		movei   #G_FLAGS,r_base    	; ... point to GPU flags
		load    (r_base),r_temp2	; ... get GPU flags
		addq    #4,r_stack          	; -- correct stack pointer
		store	r_save_hidata,(r_object); * restore hidata value after last load
		bclr    #3,r_temp2          	; ... clear IMASK enables other ints
		addq    #2,r_temp         	; -- point to the next instruction
		bset    #12,r_temp2         	; ... clear pending interrupt
		jump    (r_temp)           	; -- Return to underlying GPU code
		store   r_temp2,(r_base)       	; ... Update GPU_FLAGS
		

		equrundef r_base
		equrundef r_temp
		equrundef r_temp2



***************************************************************************************** 
***************************************************************************************** 
*
*			VARIABLES GPU (only long!)
*
***************************************************************************************** 
***************************************************************************************** 


		long
		
_update_list:	dc.l	update_list1		; ptr update list

_joy1:		dc.l	0			; \  do not modify position
_joy1cur:	dc.l	0			; /

_vbl_count: 	dc.l	0



******************************************************************************************* 
******************************************************************************************* 
******************************************************************************************* 
******************************************************************************************* 
*
*		            GPU code normal (non sous interruption OP)
*
******************************************************************************************* 
******************************************************************************************* 
******************************************************************************************* 
******************************************************************************************* 
******************************************************************************************* 


r_temp		equr	r0
r_temp2		equr	r1
r_temp3		equr	r2
r_base		equr	r3
r_base2		equr	r4
r_base3		equr	r5
r_joy1		equr	r6
r_jump		equr	r7
r_quit		equr	r8
r_mask		equr	r9
r_add32		equr	r10
r_xpos		equr	r11
r_ypos		equr	r12


r_color		equr	r20

_gpucode:	movei	#ISTACK,r_stack

		movei	#BG,r_color		
		movei	#$F8FF,r0
	;	storew	r0,(r_color)

_gpu_main:	
		movei	#G_HIDATA,r13
		movei	#$12345678,r14
		movei	#$9ABCDEF0,r15
		movei	#dummy,r16
		
		store	r15,(r13)
		storep	r14,(r16)
		
		moveq	#0,r17
		moveq	#0,r18
		
		loadp	(r16),r17
		load	(r13),r18
		
		cmp	r17,r14
		jr	ne,_phrerr
		nop
		cmp	r18,r15
		jr	ne,_phrerr
		nop
		movei	#$8FFF,r0
		jr	_coul
		nop
		
_phrerr:	movei	#$F0FF,r0
_coul:		
	;	storew	r0,(r_color)
		
		movei	#_vbl_count,r_base
.wait_vbl:	load	(r_base),r_temp
		cmpq	#0,r_temp
		jr	eq,.wait_vbl
		nop
		moveq	#0,r_temp
		store	r_temp,(r_base)
		
		

******************************************************************************************* 
*
*		       Fin du code GPU (bouclage)  
*
******************************************************************************************* 



_end_shoot:	movei	#_gpu_main,r_jump
		jump	(r_jump)
		nop
		nop
		long
popopopo:


*-------------------------------------------------------------------------
		.68000		
*-------------------------------------------------------------------------

gpucode_end:

		PRINT "G-RAM Utilis‚e : ",(popopopo-G_RAM), " Octets."
		PRINT "G-RAM restant  : ",(ISTACK-popopopo), " Octets."



*******************************************************************************
*
*                              INCLUDES  
*
*******************************************************************************


		include "jag_tools.s"


;----------------------------------------------------------------------------------------
		data
;----------------------------------------------------------------------------------------

		phrase
dummy:		dc.l	0,0

*--------------- Object list definition ------------------------------------

; don't forget directive 4, please !

		long
def_list1:	dc.l	def_br_haut
		dc.l	def_br_bas
		dc.l	def_br_vbl

l_ecran:	dc.l	def_ecran

		
		dc.l	def_goto_stop
l_it:		dc.l	def_gpu_it
l_stop0:	dc.l	def_stop


NB_OBJ		=(*-def_list1)/4+1
		dc.l	-1
		
*--------------- Objects structure ---------------------------------------

	
def_br_haut:	obj_branch	507,O_BRLT,l_stop0
def_br_bas:	obj_branch	25,O_BRGT,l_stop0
def_br_vbl:	obj_branch	505,O_BRLT,l_it  

def_gpu_it:	obj_gpu		0,0,_update_obl
def_goto_stop:	obj_goto	l_stop0
def_stop:	obj_stop	O_STOPINTS,0,0  


def_ecran:	obj_bitmap	pic,SCR_W/8,SCR_WIDTH/8,SCR_H,0,O_DEPTH|O_NOGAP|O_TRANS,0,0,0,0



*--------------- Update list definition -------------------------------------- 

		long
update_list1:	

background_upd:	upd_bitmap l_ecran,pic,SCR_H,0,10,344/8,344,0,0,0

		
		dc.l 	0,-1,-1,-1,-1,-1


*--------------- Object-list Buffers ------------------------------------------

		long
buf_list:	dcb.l	NB_OBJ,0

		qphrase
objet_list:	dcb.l	NB_OBJ*6,0	; *6 coz nop objects inserted
					; WARNING : do not use this address
					; as begin of object-list, prefer
					; the first longword in buf_list
					; structure...


*******************************************************************************
*
*                             EXTERNALS  DATAS 
*
*******************************************************************************


sample2:	incbin	"f:/jaguar/travail/datas/toum.sam"
sample1:	incbin	"f:/jaguar/travail/datas/ever.sam"

*------------------------------------------------------------------------------		
		bss
*------------------------------------------------------------------------------		
		
pic:		ds.w	SCR_W*SCR_H		


		end




