*************************
*	           *
* VDI Macro definitions *
*	           *
*************************

	SECTION	text

;--------------------------------------------------------------
; call the vdi to perform the requested function
;--------------------------------------------------------------


call_vdi	MACRO
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#vdipb,d1
	move.w	#$73,d0
	trap	#GEM
	movem.l	(sp)+,d0-d7/a0-a6
	ENDM

	SECTION	bss
ptsout	ds.w	128
ptsin	ds.w	128
	SECTION	data
vdipb	dc.l	contrl,intin,ptsin,intout,ptsout
;--------------------------------------------------------------
	SECTION	text
v_pline	MACRO
	move.w	#6,contrl
	move.w	\1,contrl+2
	clr.w	contrl+6

	move.w	\2,contrl+12
	call_vdi
	ENDM

;--------------------------------------------------------------
v_bar	MACRO
	move.w	#11,contrl
	move.w	#6,contrl+2
	clr.w	contrl+6
	move.w	#1,contrl+10

	move.w	\1,contrl+12
	move.w	\2,ptsin
	move.w	\3,ptsin+2
	move.w	\4,ptsin+4
	move.w	\5,ptsin+6
	call_vdi
	ENDM
;--------------------------------------------------------------
v_pie	MACRO
	move.w	#11,contrl
	move.w	#4,contrl+2
	move.w	#2,contrl+6
	move.w	#3,contrl+10

	move.w	\1,contrl+12
	move.w	\2,intin
	move.w	\3,intin+2
	move.w	\4,ptsin
	move.w	\5,ptsin+2
	move.w	\6,ptsin+12
	call_vdi
	ENDM
;--------------------------------------------------------------
v_circle	MACRO
	move.w	#11,contrl
	move.w	#3,contrl+2
	clr.w	contrl+6
	move.w	#4,contrl+10

	move.w	\1,contrl+12
	move.w	\2,intin
	move.w	\3,intin+2
	move.w	\4,ptsin
	move.w	\5,ptsin+2
	move.w	\6,ptsin+8
	call_vdi
	ENDM
;--------------------------------------------------------------
v_ellipse	MACRO
	move.w	#11,contrl
	move.w	#2,contrl+2
	clr.w	contrl+6
	move.w	#5,contrl+10

	move.w	\1,contrl+12
	move.w	\2,ptsin
	move.w	\3,ptsin+2
	move.w	\4,ptsin+4
	move.w	\5,ptsin+6
	call_vdi
	ENDM
;--------------------------------------------------------------
v_ellpie	MACRO
	move.w	#11,contrl
	move.w	#2,contrl+2
	move.w	#2,contrl+6
	move.w	#7,contrl+10

	move.w	\1,contrl+12
	move.w	\2,intin
	move.w	\3,intin+2
	move.w	\4,ptsin
	move.w	\5,ptsin+2
	move.w	\6,ptsin+4
	move.w	\7,ptsin+6
	call_vdi
	ENDM
;--------------------------------------------------------------
v_rfbox	MACRO
	move.w	#11,contrl
	move.w	#2,contrl+2
	clr.w	contrl+6
	move.w	#9,contrl+10

	move.w	\1,contrl+12
	move.w	\2,ptsin
	move.w	\3,ptsin+2
	move.w	\4,ptsin+4
	move.w	\5,ptsin+6
	call_vdi
	ENDM
;--------------------------------------------------------------
vsl_type	MACRO
	move.w	#15,contrl
	clr.w	contrl+2
	move.w	#1,contrl+6

	move.w	\1,contrl+12
	move.w	\2,intin
	call_vdi
	ENDM
;--------------------------------------------------------------
vsl_width	MACRO
	move.w	#16,contrl
	move.w	#1,contrl+2
	clr.w	contrl+6

	move.w	\1,contrl+12
	move.w	\1,ptsin
	call_vdi
	ENDM
;--------------------------------------------------------------
vsl_color	MACRO
	move.w	#17,contrl
	clr.w	contrl+2
	move.w	#1,contrl+6

	move.w	\1,contrl+12
	move.w	\2,intin
	call_vdi
	ENDM
;--------------------------------------------------------------
vsf_fill	MACRO
	move.w	#23,contrl
	clr.w	contrl+2
	move.w	#1,contrl+6

	move.w	\1,contrl+12
	move.w	\2,intin
	call_vdi
	ENDM
;--------------------------------------------------------------
vsf_index	MACRO
	move.w	#24,contrl
	clr.w	contrl+2
	move.w	#1,contrl+6

	move.w	\1,contrl+12
	move.w	\2,intin
	call_vdi
	ENDM
;--------------------------------------------------------------
vsf_color	MACRO
	move.w	#25,contrl
	clr.w	contrl+2
	move.w	#1,contrl+6

	move.w	\1,contrl+12
	move.w	\2,intin
	call_vdi
	ENDM
;--------------------------------------------------------------
vswr_mode	MACRO
	move.w	#32,contrl
	clr.w	contrl+2
	move.w	#1,contrl+6

	move.w	\1,contrl+12
	move.w	\2,intin
	call_vdi
	ENDM
;--------------------------------------------------------------
v_opnvwk	MACRO
	move.w	#100,contrl
	clr.w	contrl+2
	move.w	#11,contrl+6
	move.w	\1,contrl+12		; handle
	move.w	\2,intin
	move.w	\3,intin+2
	move.w	\4,intin+4
	move.w	\5,intin+6
	move.w	\6,intin+8
	move.w	\7,intin+10
	move.w	\8,intin+12
	move.w	\9,intin+14
	move.w	\a,intin+16
	move.w	\b,intin+18
	move.w	\c,intin+20
	call_vdi
	ENDM
;--------------------------------------------------------------
v_clsvwk	MACRO
	move.w	#101,contrl
	clr.w	contrl+2
	clr.w	contrl+6

	move.w	\1,contrl+12
	call_vdi
	ENDM
;--------------------------------------------------------------
v_contourfill	MACRO
	move.w	#103,contrl
	move.w	#1,contrl+2
	move.w	#1,contrl+6

	move.w	\1,contrl+12
	move.w	\2,intin
	move.w	\3,ptsin
	move.w	\4,ptsin+2
	call_vdi
	ENDM
;--------------------------------------------------------------
vsf_perimeter	MACRO
	move.w	#104,contrl
	clr.w	contrl+2
	move.w	#1,contrl+6

	move.w	\1,contrl+12
	move.w	\2,intin
	call_vdi
	ENDM
;--------------------------------------------------------------
vsl_ends	MACRO
	move.w	#108,contrl
	clr.w	contrl+2
	move.w	#2,contrl+6

	move.w	\1,contrl+12
	move.w	\2,intin
	move.w	\3,intin+2
	call_vdi
	ENDM
;--------------------------------------------------------------
vst_load_fonts	MACRO
	move.w	#119,contrl
	clr.w	contrl+2
	move.w	#1,contrl+6

	move.w	\1,contrl+12
	clr.w	intin
	call_vdi
	ENDM
;--------------------------------------------------------------
vst_unload_fonts	MACRO
	move.w	#120,contrl
	clr.w	contrl+2
	move.w	#1,contrl+6

	move.w	\1,contrl+12
	clr.w	intin
	call_vdi
	ENDM
;--------------------------------------------------------------
vs_clip	MACRO
	move.w	#129,contrl
	move.w	#2,contrl+2
	move.w	#1,contrl+6

	move.w	\1,contrl+12
	move.w	\2,intin
	move.w	\3,ptsin
	move.w	\4,ptsin+2
	move.w	\5,ptsin+4
	move.w	\6,ptsin+6
	call_vdi
	ENDM
;--------------------------------------------------------------
	SECTION	data
;--------------------------------------------------------------
; MFDB block definition
	rsreset
fd_addr	rs.l	1	* address of the bitmap or 0 for screen/offscreen bitmap 
fd_w	rs.w	1	* width in pixels */
fd_h	rs.w	1	* height in pixels */
fd_wdwidth	rs.w	1	* width of a line in words (per plane) */
fd_stand	rs.w	1	* 0: device specific format, 1: standard format */
fd_nplanes	rs.w	1	* number of planes */
fd_r1	rs.w	1	* reserved, must be 0 */
fd_r2	rs.w	1	* reserved, must be 0 */
fd_r3	rs.w	1	* reserved, must be 0 */
;--------------------------------------------------------------
; XFNT_INFO	block
	rsreset
size	rs.l	1	* length of the structure, initialize this entry before calling vqt_xfntinfo() */
format	rs.w	1	* font format, e.g. 4 for TrueType */
id	rs.w	1	* font ID, e.g. 6059 */
index	rs.w	1	* index */
font_name	rs.b	50	* font name, e.g. "Century 725 Italic BT" */
family_name	rs.b	50	* name of the font family, e.g. "Century725 BT" */
style_name	rs.b	50	* name of the font style, e.g. "Italic" */
file_name1	rs.b	200	* name of the first font file, e.g. "C:\FONTS\TT1059M_.TTF" */
file_name2	rs.b	200	* name of the 2nd font file */
file_name3	rs.b	200	* name of the 3rd font file */
pt_cnt	rs.w	1	* number of available point sizes (vst_point()), e.g. 10 */
pt_sizes	rs.w	64	* available point sizes,
                              	* e.g. { 8, 9, 10, 11, 12, 14, 18, 24, 36, 48 } */
;--------------------------------------------------------------
; vdi calls
; contrl,contrl+2,contrl+6,contrl+12
; -1 indicates needs providing

vdi_1	dc.w	1,0,11,0
vdi_1_	dc.w	1,0,16,0
vdi_2	dc.w	2,0,0

vdi_3	dc.w	3,0,0
vdi_5_22	dc.w	5,0,0,22	; 22 =contrl+10
vdi_4	dc.w	4,0,0
vdi_100_1	dc.w	100,0,20,1	; 1 =contrl+10
vdi_101_1	dc.w	101,0,0,1	; as above
vdi_102	dc.w	102,0,1
vdi_102_1	dc.w	102,0,1,1	; last 1 = contrl+10
vdi_248	dc.w	248,0,1
vdi_248_4242	dc.w	248,0,7,4242	; 4242 = contrl+10

vdi_14	dc.w	14,0,4
vdi_26	dc.w	26,0,2
vdi_5_76	dc.w	5,0,3,76	; 76 = contrl+10
vdi_5_77	dc.w	5,0,0,77	; 77 = contrl+10




vdi_6	dc.w	6,-1,0
vdi_6_13	dc.w	6,-1,-1,13	; 13 = contrl+10
vdi_11_2	dc.w	11,4,2,2	; last 2 = contrl+10
vdi_11_6	dc.w	11,2,2,6	; 6 = contrl+10
vdi_11_8	dc.w	11,2,0,8	; 8 = contrl+10
vdi_11_13	dc.w	11,1,0,13	; 13 = contrl+10
vdi_5_99	dc.w	5,0,3,99	; 6 = contrl+10



vdi_35	dc.w	35,0,0

vdi_113	dc.w	113,0,1

vdi_9	dc.w	9,-1,0
vdi_9_13	dc.w	9,-1,-1,13	; 13 =contrl+10









vdi_37	dc.w	37,0,0


vdi_112	dc.w	112,0,-1
vdi_114	dc.w	114,2,0

vdi_7	dc.w	7,-1,0
vdi_18	dc.w	18,0,1
vdi_19	dc.w	19,1,0
vdi_20	dc.w	20,0,1
vdi_36	dc.w	36,0,0

vdi_8	dc.w	8,1,-1
vdi_11_10	dc.w	11,2,-1,10	; 10 = contrl+10
vdi_12	dc.w	12,1,0
vdi_13	dc.w	13,0,1
vdi_21	dc.w	21,0,1
vdi_22	dc.w	22,0,1
vdi_38	dc.w	38,0,0
vdi_39	dc.w	39,0,2
vdi_106	dc.w	106,0,1
vdi_107	dc.w	107,0,1
vdi_116	dc.w	116,0,-1
vdi_117	dc.w	117,0,1
vdi_119	dc.w	119,0,1
vdi_120	dc.w	120,0,1
vdi_130	dc.w	130,0,2,1	; 1 = contrl+10
vdi_131	dc.w	131,0,0
vdi_229	dc.w	229,0,5,0	; last 0 = contrl+10