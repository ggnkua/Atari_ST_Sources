*************************************************
*
* GEMMA Extension for STOS, interpreter version.
*
* VDI extension, v0.50 Part 1 (3)
*
* (c)1997 The GEMMA programming team
* All rights reserved.
*
* This source code, (or any derived from it) may only
* only be distributed under the GNU Public Licence
* (available on request). In essence this states that
* this source code must be available and that binaries
* must be distributed as freeware.
*
* The authors reserves the right to change the status of
* this software at any time, without prior warning or
* notification.
*
*    Supervisor mode   - The AES should NOT be called from
*                        supervisor mode (which STOS is in)
*    on-line help (not one help command per new command!)

* Jump header

	output C:\STOS\GEMMA.EXF

        bra     INIT

***********************************************
*
* Header
*

* Start of token list
        dc.b    128

TOKENS  

* even=instruction, odd=function
	dc.b	"v_bar",128
	dc.b	"vsf_interior",129
	dc.b	"vsf_colr",130
	dc.b	"vs_clip",131
	dc.b	"vst_point",132		* 5
	dc.b	"vqt_name",133
	dc.b	"vst_colr",134
	dc.b	"chandle",135
	dc.b	"v_pline",136
	dc.b	"v_pmarker",137		* 10
	dc.b	"v_fillarea",138
	dc.b	"v_conturfll",139
	dc.b	"vr_recfl",140
	dc.b	"v_arc",141
	dc.b	"v_pieslice",142	* 15
	dc.b	"v_circle",143
	dc.b	"v_ellarc",144
	dc.b	"v_ellpie",145
	dc.b	"v_ellipse",146
	dc.b	"v_rbox",147		* 20
	dc.b	"v_rfbox",148
	dc.b	"v_justified",149
	dc.b	"vswr_mode",150
	dc.b	"vs_colr",151
	dc.b	"vsl_type",152		* 25
	dc.b	"vsl_udsty",153
	dc.b	"vsl_width",154
	dc.b	"vsl_colr",155
	dc.b	"v_show_c",156
	dc.b	"vsl_ends",157		* 30
	dc.b	"v_hide_c",158
	dc.b	"vst_load_fonts",159
	dc.b	"v_gtext",160
	dc.b	"dummygemma6",161		* vst_font
	dc.b	"v_ftext",162		* 35
	dc.b	"v_get_pixel",163
	dc.b	"vst_font",164
	dc.b	"v_opnwk",165
	dc.b	"dummygemma8",166
	dc.b	"dummygemma9",167		* 40
	dc.b	"vsm_type",168
	dc.b	"vsm_height",169
	dc.b	"vst_height",170
	dc.b	"vst_rotation",171
	dc.b	"vst_effects",172	* 45
	dc.b	"vst_alignment",173
	dc.b	"vsf_style",174
	dc.b	"vsf_perimeter",175
	dc.b	"v_openvwk",176		* 49

* The end of the token list
        dc.b    0

	even
	
* Now the jump table

JUMPS   dc.w   49		in order of token, starting from 128
	dc.l	v_bar
	dc.l	vsf_interior
	dc.l	vsf_color
	dc.l	vs_clip
	dc.l	vst_point	* 5
	dc.l	vqt_name
	dc.l	vst_color
	dc.l	get_handle
	dc.l	v_pline
	dc.l	v_pmarker	* 10
	dc.l	v_fillarea
	dc.l	v_contourfill
	dc.l	vr_recfl
	dc.l	v_arc
	dc.l	v_pieslice	* 15
	dc.l	v_circle
	dc.l	v_ellarc
	dc.l	v_ellpie
	dc.l	v_ellipse
	dc.l	v_rbox		* 20
	dc.l	v_rfbox
	dc.l	v_justified
	dc.l	vswr_mode
	dc.l	vs_color
	dc.l	vsl_type	* 25
	dc.l	vsl_udsty
	dc.l	vsl_width
	dc.l	vsl_color
	dc.l	v_show_c
	dc.l	vsl_ends	* 30
	dc.l	v_hide_c
	dc.l	vst_load_fonts
	dc.l	v_gtext
	dc.l	dummy		* 34
	dc.l	v_ftext		* 35
	dc.l	v_get_pixel
	dc.l	vst_font
	dc.l	v_opnwk
	dc.l	dummy
	dc.l	dummy	* 40
	dc.l	vsm_type
	dc.l	vsm_height
	dc.l	vst_height
	dc.l	vst_rotation
	dc.l	vst_effects	* 45
	dc.l	vst_alignment
	dc.l	vsf_style
	dc.l	vsf_perimeter
	dc.l	v_openvwk

* The welcome mesages in English and French

WELCOME dc.b	10,13

	dc.b	10,13,"                          The GEMMA Extension v1.52"
	dc.b	10,13,"                       (c) 1997 The GEMMA programming team"
 	dc.b	10,13,"                           VDI routines installed.",10,13,0

	dc.b	10,13,"                          le Extension GEMMA v1.52"
	dc.b	10,13,"                     (c) 1997 Le GEMMA programming team"
 	dc.b	10,13,"                        routines de VDI installes.",10,13,0
        even

* Some system variables

RETURN	dc.l	0
SYSTEM	dc.l	0

* The routine that is called on start-up

INIT    lea     END,a0
        lea     COLDST,a1
        rts

COLDST	move.l	a0,SYSTEM
	lea     WELCOME,a0      ; vital stuff
        lea     WARMST,a1
        lea     TOKENS,a2
        lea     JUMPS,a3
        rts

* Executed on UNDO in editor

WARMST  rts

*************************
*
* Our commands
*
*

* The VDI commands --------------------------------------------

get_handle	move.l	(sp)+,RETURN
		cmpi.w	#0,d0
		bne	SYNTAX

		move.w	#77,control	graf_handle without other bits
		move.w	#0,control+2
		move.w	#5,control+4
		move.w	#0,control+6
		move.w	#0,control+8
		bsr	call_aes

		moveq.l	#0,d2
		move.w	int_out,d3

		move.l	RETURN,a0
		jmp	(a0)

vst_load_fonts	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX
		
		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#119,contrl
		clr.w	contrl1
		clr.w	contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5
		move.w	#0,intin
		bsr	call_vdi

*		moveq.l	#0,d2
		move.w	intout,d3

                move.l	RETURN,a0
                jmp	(a0)

v_openvwk	move.l	(sp)+,RETURN
		cmpi.w	#1,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6		

		
		move	#100,contrl
		move	#0,contrl1
		move	#11,contrl3
*		move	#1,contrl+12
		move	#1,intin+2
		move	#1,intin+4
		move	#1,intin+6
		move	#1,intin+8
		move	#1,intin+10
		move	#1,intin+12
		move	#1,intin+14
		move	#1,intin+16
		move	#1,intin+18
		move	#2,intin+20
		jsr	call_vdi

		move.l	#0,d2
		move.l	contrl6,d3

		move.l	RETURN,a0
		jmp	(a0)

vst_unload_fonts	move.l	(sp)+,RETURN
			cmpi.w	#1,d0
			bne	SYNTAX

			movem.l	(sp)+,d2-d4   * handle
			tst.b	d2
			bne	TYPEMIS
			move.w	d3,contrl6		

			move.w	#120,contrl
			clr.w	contrl1
			clr.w	contrl2
			move.w	#1,contrl3
			clr.w	contrl4
			clr.w	contrl5
			move.w	#0,intin
			bsr	call_vdi

			move.l	RETURN,a0
			jmp	(a0)

v_gtext		move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		move.w	#8,contrl
		move.w	#1,contrl1
		clr.w	contrl2
		clr.w	contrl4
		clr.w	contrl5

		movem.l	(sp)+,d2-d4   * text
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a3

		moveq	#0,d1
		moveq	#0,d0
		lea	intin,a4
.copy		move.b	(a3)+,d1		convert C string into words
		beq.s	.end
		move.w	d1,(a4)+
		addq.b	#1,d0
		bpl.s	.copy
.end		move.w	d0,contrl3
		move.w	#1,contrl1

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_ftext		move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		move.w	#241,contrl
		clr.w	contrl2
		clr.w	contrl4
		clr.w	contrl5

		movem.l	(sp)+,d2-d4   * text
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a3

		moveq	#0,d1
		moveq	#0,d0
		lea	intin,a4
.copyftext	move.b	(a3)+,d1		convert C string into words
		beq.s	.endftext
		move.w	d1,(a4)+
		addq.b	#1,d0
		bpl.s	.copyftext
.endftext	move.w	d0,contrl3
		move.w	#1,contrl1

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)


vst_font	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * font
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6		

		move.w	#21,contrl
		move.w  #0,contrl1
		move.w	#0,contrl2
		move.w	#1,contrl3
		move.w	#0,contrl4
		move.w  #0,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

vst_color	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * colour
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6
		
		move.w	#22,contrl
		clr.w	contrl1
		clr.w	contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

vqt_name	move.l	(sp)+,RETURN
		cmpi.w	#3,d0
		bne	SYNTAX

		move.w	#130,contrl
		clr.w	contrl1
		clr.w	contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		movem.l	(sp)+,d2-d4   * name space
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a0

		movem.l	(sp)+,d2-d4   * index
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		bsr	call_vdi

		lea.l	intout+2,a1
		move.l	a1,(a0)

		lea.l	intout,a1
		move.w	(a1),d3
		move.l	#0,d2	

                move.l	RETURN,a0
                jmp	(a0)

vst_point	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX
		
		move.w	#107,contrl
		clr.w	contrl1
		clr.w	contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		movem.l	(sp)+,d2-d4   * points
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		bsr	call_vdi

		move.w	intout,d3

                move.l	RETURN,a0
                jmp	(a0)

vs_clip		move.l	(sp)+,RETURN
		cmpi.w	#6,d0
		bne	SYNTAX

		move.w	#129,contrl
		move.w	#2,contrl1
		clr.w	contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+6

		movem.l	(sp)+,d2-d4   * x2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+4

		movem.l	(sp)+,d2-d4   * y1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

vsf_interior	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		move.w	#23,contrl
		move.w	#0,contrl1
		clr.w	contrl2
		clr.w	contrl4

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl3

		move.w	#1,contrl5

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	d3,intin

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

vsf_color	move.l	(sp)+,RETURN
		cmpi.w	#2,d0
		bne	SYNTAX

		move.w	#25,contrl
		move.w	#0,contrl1
		clr.w	contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_bar		move.l	(sp)+,RETURN
		cmpi.w	#5,d0
		bne	SYNTAX

		move.w	#11,contrl
		move.w	#2,contrl1
		clr.w	contrl2
		move.w	#0,contrl3
		clr.w	contrl4
		move.w	#1,contrl5
		move.w	#0,intin

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+6

		movem.l	(sp)+,d2-d4   * x2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+4

		movem.l	(sp)+,d2-d4   * y1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_show_c	move.l	(sp)+,RETURN
		cmpi.w	#0,d0
		bne	SYNTAX
		
		move.w	#77,control	graf_handle
		move.w	#0,control+2
		move.w	#5,control+4
		move.w	#0,control+6
		move.w	#0,control+8
		bsr	call_aes

		move.w	d0,current_handle

		move.w	#122,contrl
		clr.w	contrl1
		move.w	#1,contrl3
		move.w	current_handle,contrl6
		move.w	#0,intin
		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_hide_c	move.l	(sp)+,RETURN

		cmpi	#0,d0
		bne	SYNTAX
		
		move.w	#77,control	graf_handle
		move.w	#0,control+2
		move.w	#5,control+4
		move.w	#0,control+6
		move.w	#0,control+8
		bsr	call_aes
		move.w	d0,current_handle

		move.w	#123,contrl	
		clr.w	contrl1
		clr.w	contrl3
		move.w	current_handle,contrl6
		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

v_pmarker	move.l	(sp)+,RETURN
		cmpi	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* pts
*		tst.b	d2
*		bne	TYPEMIS
*		move.w	ptsin

		movem.l	(sp)+,d2-d4	* n
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl1

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6
		
		move.w	#7,contrl
		clr.w	contrl2
		clr.w	contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_fillarea	move.l	(sp)+,RETURN
		cmpi	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* pts
		tst.b	d2
		bne	TYPEMIS
*		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4	* n
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl1

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6
		
		move.w	#9,contrl
		clr.w	contrl2
		clr.w	contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_contourfill	move.l	(sp)+,RETURN
		cmpi	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * colour
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#103,contrl
		move.w	#0,contrl1
		clr.w	contrl2
		move.w	#0,contrl3
		clr.w	contrl4
		move.w	#0,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

vr_recfl	move.l	(sp)+,RETURN
		cmpi	#5,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+6

		movem.l	(sp)+,d2-d4   * x2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+4

		movem.l	(sp)+,d2-d4   * y1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#114,contrl
		move.w	#2,contrl1
		clr.w	contrl2
		move.w	#0,contrl3
		clr.w	contrl4
		move.w	#1,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_arc		move.l	(sp)+,RETURN
		cmpi	#6,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * end_angle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin+2

		movem.l	(sp)+,d2-d4   * start_angle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * r
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+12

		movem.l	(sp)+,d2-d4    * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4    * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		clr.w	ptsin+4
		clr.w	ptsin+6
		clr.w	ptsin+8
		clr.w	ptsin+10

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#11,contrl
		move.w	#4,contrl1
		clr.w	contrl2
		move.w	#2,contrl3
		clr.w	contrl4
		move.w	#2,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_pieslice	move.l	(sp)+,RETURN
		cmpi	#6,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * end_angle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin+2

		movem.l	(sp)+,d2-d4   * start_angle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * r
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+12

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#11,contrl
		move.w	#4,contrl1
		clr.w	contrl2
		move.w	#2,contrl3
		clr.w	contrl4
		move.w	#3,contrl5

		clr.w	ptsin+4
		clr.w	ptsin+6
		clr.w	ptsin+8
		clr.w	ptsin+10

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_circle	move.l	(sp)+,RETURN
		cmpi.w	#4,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * r
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+8

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#11,contrl
		move.w	#3,contrl1
		clr.w	contrl2
		move.w	#0,contrl3
		clr.w	contrl4
		move.w	#4,contrl5

		clr.w	ptsin+4
		clr.w	ptsin+6

		move.w	0,ptsin+10

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_ellarc	move.l	(sp)+,RETURN
		cmpi	#7,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * end_angle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin+2

		movem.l	(sp)+,d2-d4   * start_angle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * yr
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+6

		movem.l	(sp)+,d2-d4   * xr
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+4

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#11,contrl
		move.w	#2,contrl1
		clr.w	contrl2
		move.w	#3,contrl3
		clr.w	contrl4
		move.w	#6,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_ellpie	move.l	(sp)+,RETURN
		cmpi	#7,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * end_angle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin+2

		movem.l	(sp)+,d2-d4   * start_angle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * yr
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+6

		movem.l	(sp)+,d2-d4   * xr
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+4

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#11,contrl
		move.w	#2,contrl1
		clr.w	contrl2
		move.w	#2,contrl3
		clr.w	contrl4
		move.w	#7,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_ellipse	move.l	(sp)+,RETURN
		cmpi	#5,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * yr
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+6

		movem.l	(sp)+,d2-d4   * xr
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+4

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#11,contrl
		move.w	#2,contrl1
		clr.w	contrl2
		move.w	#0,contrl3
		clr.w	contrl4
		move.w	#5,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_rbox		move.l	(sp)+,RETURN
		cmpi	#5,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+6

		movem.l	(sp)+,d2-d4   * x2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+4

		movem.l	(sp)+,d2-d4   * y1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#11,contrl
		move.w	#2,contrl1
		clr.w	contrl2
		move.w	#0,contrl3
		clr.w	contrl4
		move.w	#8,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_rfbox		move.l	(sp)+,RETURN
		cmpi	#5,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * y2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+6

		movem.l	(sp)+,d2-d4   * x2
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+4

		movem.l	(sp)+,d2-d4   * y1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x1
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#11,contrl
		move.w	#2,contrl1
		clr.w	contrl2
		move.w	#0,contrl3
		clr.w	contrl4
		move.w	#9,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_justified	move.l	(sp)+,RETURN
		cmpi	#7,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * charflag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin+2

		movem.l	(sp)+,d2-d4   * wordflag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * length
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+4

		movem.l	(sp)+,d2-d4   * text (address)
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl3

		movem.l	(sp)+,d2-d4   * y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4   * x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		clr.w	ptsin+6

		move.w	#11,contrl
		move.w	#2,contrl1
		clr.w	contrl2
		clr.w	contrl4
		move.w	#10,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

vswr_mode	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * mode
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#32,contrl
		move.w	#0,contrl1
		clr.w	contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		move.w	#1,contrl5

		bsr	call_vdi

		move.w	intout,d3

                move.l	RETURN,a0
                jmp	(a0)

vs_color	move.l	(sp)+,RETURN
		cmpi	#5,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * b
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin+6

		movem.l	(sp)+,d2-d4   * g
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin+4

		movem.l	(sp)+,d2-d4   * r
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin+2

		movem.l	(sp)+,d2-d4   * index
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#14,contrl
		move.w	#0,contrl1
		clr.w	contrl2
		move.w	#4,contrl3
		clr.w	contrl4
		move.w	#1,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

vsl_type	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * type
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#15,contrl
		move.w	#0,contrl1
		clr.w	contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		move.w	#0,contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

vsl_color	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * colour
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#17,contrl
		move.w	#0,contrl1
		clr.w	contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

vsl_ends	move.l	(sp)+,RETURN
		cmpi	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * endstyle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin+2

		movem.l	(sp)+,d2-d4   * beginstyle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#108,contrl
		move.w	#0,contrl1
		clr.w	contrl2
		move.w	#2,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

                move.l	RETURN,a0
                jmp	(a0)

v_opnwk		move.l	(sp)+,RETURN
		cmpi	#0,d0
		bne	SYNTAX

		move.w	#1,contrl
		clr.w	contrl1
		clr.w	contrl2
		move.w	#11,contrl3
		clr.w	contrl4
		clr.w	contrl5
		clr.w	contrl6

		bsr	call_vdi

		move.w	contrl6,d3

		move.l	RETURN,a0
		jmp	(a0)

v_pline		move.l	(sp)+,RETURN
		cmpi	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4   * pts()
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,a4

		movem.l	(sp)+,d2-d4   * number
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl1

		lea	ptsin,a3

copy:		move.w	(a4)+,(a3)+
		dbf	d3,copy

		movem.l	(sp)+,d2-d4   * handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#6,contrl
		clr.w	contrl2
		move.w	#0,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

vsl_udsty	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* pattern
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#113,contrl
		move.w	#0,contrl1
		move.w	#0,contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

vsl_width	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* width
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		move.w	#0,ptsin+2

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#16,contrl
		move.w	#1,contrl1
		move.w	#0,contrl2
		move.w	#0,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

vsm_type	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* type
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#18,contrl
		move.w	#0,contrl1
		move.w	#0,contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

vsm_height	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* height
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		move.w	#0,ptsin

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#19,contrl
		move.w	#0,contrl1
		move.w	#0,contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

vst_height	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* height
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		move.w	#0,ptsin

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#12,contrl
		move.w	#1,contrl1
		move.w	#0,contrl2
		move.w	#0,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

vst_rotation	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* angle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#13,contrl
		move.w	#0,contrl1
		move.w	#0,contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

vst_effects	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* effects
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#106,contrl
		move.w	#0,contrl1
		move.w	#0,contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

vst_alignment	move.l	(sp)+,RETURN
		cmpi	#3,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* vertical
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin+2

		movem.l	(sp)+,d2-d4	* horizontal
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#39,contrl
		move.w	#0,contrl1
		move.w	#0,contrl2
		move.w	#2,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

vsf_style	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* style_index
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#24,contrl
		move.w	#0,contrl1
		move.w	#0,contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

vsf_perimeter	move.l	(sp)+,RETURN
		cmpi	#2,d0
		bne	SYNTAX

		movem.l	(sp)+,d2-d4	* flag
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,intin

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#104,contrl
		move.w	#0,contrl1
		move.w	#0,contrl2
		move.w	#1,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	RETURN,a0
		jmp	(a0)

v_get_pixel	move.l	(sp)+,RETURN
		cmpi	#3,d0
		bne	SYNTAX

		move.l	a5,(mystore)

		movem.l	(sp)+,d2-d4	* value (varptr)
		tst.b	d2
		bne	TYPEMIS
		move.l	d3,a5
		move.l	a5,(gotclicks)
*		move.w	d3,intin

		movem.l	(sp)+,d2-d4	* y
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin+2

		movem.l	(sp)+,d2-d4	* x
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,ptsin

		movem.l	(sp)+,d2-d4	* handle
		tst.b	d2
		bne	TYPEMIS
		move.w	d3,contrl6

		move.w	#105,contrl
		move.w	#1,contrl1
		move.w	#0,contrl2
		move.w	#0,contrl3
		clr.w	contrl4
		clr.w	contrl5

		bsr	call_vdi

		move.l	(gotclicks),a5
		move.w	intout,2(a5)

		move.w	intout+2,d3
		move.w	#0,d2

		move.l	RETURN,a0
		jmp	(a0)

*************************
*
* Odds and sods...
*

dummy	move.l	(sp)+,RETURN
	bra	NOTDONE

SYNTAX	moveq	#12,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

TYPEMIS	moveq	#19,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

NOTDONE	moveq	#0,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

call_vdi
	move.l	#vdi_params,d1
	move.w	#$73,d0
	trap	#2
	rts

call_aes
	move.l	#aes,d1
	move.w	#$C8,d0
	trap	#2
	move.w	int_out,d0
	rts

*************************
*
* Data space...
*

* these don't need initialising...
dummyout	ds.l	1
control		ds.w	5
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1
gemma		dc.b	0,4,"1.52"

*the VDI parameters

current_handle	ds.w	1

contrl		ds.w	1
contrl1		ds.w	1
contrl2		ds.w	1
contrl3		ds.w	1
contrl4		ds.w	1
contrl5		ds.w	1
contrl6		ds.w	1
contrl7		ds.w	1
contrl8		ds.w	1
contrl9		ds.w	1
contrl10	ds.w	1
contrl11	ds.w	1

intin		ds.w	128
intout		ds.w	128
ptsin		ds.w	128
ptsout		ds.w	128

global2		ds.w	14

dataspace	ds.w	17

vdi_params	dc.l	contrl,intin,ptsin,intout,ptsout
aes		dc.l	control,global2,int_in,int_out,addr_in,addr_out



mystore		ds.l	1
x_out		ds.l	1
y_out		ds.l	1
w_out		ds.l	1
h_out		ds.l	1
button		ds.l	1
kstate		ds.l	1
key_pressed	ds.l	1
gotclicks	ds.l	1
addr		ds.l	1
oldsp		ds.l	1
newsp		ds.l	1


END