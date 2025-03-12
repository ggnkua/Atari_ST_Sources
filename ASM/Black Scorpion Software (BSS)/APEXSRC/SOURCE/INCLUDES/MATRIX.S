*-----------------------------------------------------------------------*
*	Matrix ScreenEye interface							*
*-----------------------------------------------------------------------*
* uword, bool, short = word								*
*-----------------------------------------------------------------------*

FIELDnext		=	0
FIELDodd		=	1
FIELDeven		=	2

DIGdx7191		=	768
DIGdx9051		=	720
DIGdyS		=	576			/* full Screen	*/
DIGdyF		=	(DIGdyS/2)		/* single frame	*/

NOdmsd		=	0
DEFdmsdType		=	9051
			ifeq	DEFdmsdType-9051
ALTdmsdType		=	7191
			elseif
ALTdmsdType		=	9051
			endc

PUP_AUTO 		=	0
PUP_PAL 		=	1
PUP_NTSC		=	2
PUP_SECAM		=	3

PUP_VTR		=	0
PUP_TV		=	1
PUP_SVHS		=	1
PUP_FBAS		=	2
PUP_CVBS		=	2
PUP_BAS		=	3

*-----------------------------*
* TBlitWindow			*
*-----------------------------*
				rsreset
TBW_source:			rs.b	0

TBW_sidata:			rs.l	1	; -> to data
TBW_siw:			rs.w	1
TBW_sih:			rs.w	1
TBW_siplanes:		rs.w	1
TBW_sibpl:			rs.w	1

TBW_swx:			rs.w	1
TBW_swy:			rs.w	1
TBW_sww:			rs.w	1
TBW_swh:			rs.w	1
TBW_slen:			rs.b	0

TBW_dest:			rs.b	0

TBW_didata:			rs.l	1	; -> to data
TBW_diw:			rs.w	1
TBW_dih:			rs.w	1
TBW_diplanes:		rs.w	1
TBW_dibpl:			rs.w	1

TBW_dwx:			rs.w	1
TBW_dwy:			rs.w	1
TBW_dww:			rs.w	1
TBW_dwh:			rs.w	1
TBW_dlen:			rs.b	0
TBW_len:			rs.b	0

*-----------------------------*
* TImageWindow			*
*-----------------------------*

				rsreset
TIW_idata:			rs.l	1	; -> to data
TIW_iw:			rs.w	1
TIW_ih:			rs.w	1
TIW_iplanes:		rs.w	1
TIW_ibpl:			rs.w	1
TIW_wx:			rs.w	1
TIW_wy:			rs.w	1
TIW_ww:			rs.w	1
TIW_wh:			rs.w	1
TIW_len:			rs.b	0

*-----------------------------*
* TImage				*
*-----------------------------*

				rsreset
TI_idata:			rs.l	1	; -> to data
TI_iw:			rs.w	1
TI_ih:			rs.w	1
TI_iplanes:			rs.w	1
TI_ibpl:			rs.w	1
TI_len:			rs.b	0

*-----------------------------*
* TRectangle			*
*-----------------------------*

				rsreset
TR_wx:			rs.w	1
TR_wy:			rs.w	1
TR_ww:			rs.w	1
TR_wh:			rs.w	1
TR_len:			rs.b	0

*-----------------------------*
* POINT				*
*-----------------------------*

TP_x:				rs.w	1
TP_y:				rs.w	1
P_len:			rs.b	0

*-----------------------------*
* TDigiParam			*
*-----------------------------*

				rsreset
TDP_data:			rs.l	1	; -> to data
TDP_w:			rs.w	1
TDP_h:			rs.w	1
TDP_planes:			rs.w	1
TDP_bpl:			rs.w	1
TDP_YCtoF8format		rs.l	1	; -> to TYCtoF8format structure
TDP_waituntilgrabbed:	rs.w	1	; digitise parameter.
TDP_len:			rs.b	0

*-----------------------------*
* TYCtoF8format			*
*-----------------------------*

				rsreset
TYC_mask:			rs.w	1
TYC_shift:			rs.w	1
TYC_sign:			rs.w	1
TYC_rndofs:			rs.w	1
TYC_len:			rs.b	0

*-----------------------------*
* TDmsdParam			*
*-----------------------------*

				rsreset
TDM_dmsd:			rs.w	1
TDM_signal:			rs.w	1
TDM_source:			rs.w	1
TDM_standard:		rs.w	1
TDM_len:			rs.b	0

*-----------------------------*
* TScreenEyeParameterBlock	*
*-----------------------------*

					rsreset
TSE_version:			rs.w	1
TSE_magic:				rs.w	1
TSE_copyright:			rs.l	1 ; -> to "message".
TSE_instance:			rs.w	1
TSE_lock:				rs.w	1 ; 1 = locked : 0 = released
TSE_verbose:			rs.l	1 ; -> to verbose buffer..
TSE_DigiParam:			rs.l	1 ; -> to TDigiParam structure.
TSE_DmsdParam:			rs.l	1 ; -> to TDmsdParam structure.
TSE_reserved:			rs.l	32

TSE_BlitGreyWindow:		rs.l	1 ( TBlitWind *blitwind, POINT *zoom )
TSE_Blit555SWWindow:		rs.l	1 " 
TSE_Blit555HWSimWindow:		rs.l	1 "
TSE_Blit555Window:		rs.l	1 "
TSE_BlitRGBWindow:		rs.l	1 "
TSE_BlitF332Window:		rs.l	1 "
TSE_BlitF8GreyWindow:		rs.l	1 "
TSE_BlitFyc224Window:		rs.l	1 "

TSE_ImageInfo:			rs.l	1 ( char *info, TImage *img )
TSE_WindowInfo:			rs.l	1 ( char *info, TRectangle *wnd )
TSE_BlitWindowInfo:		rs.l	1 ( TBlitWindow *blitwind )
TSE_ImageWindowInfo:		rs.l	1 ( char *info, TImageWindow *imgwnd )

TSE_SetToFullSize:		rs.l	1 ( TImageWindow *imgwnd, void *data, short w, short h, short planes )

TSE_PixelPosition:		rs.l	1 ( TImageWindow *imgwnd )

TSE_InitGreyTo555Table:		rs.l	1 ( void )
TSE_InitGreyTo555TableWCols:	rs.l	1 ( void )
TSE_ShowHisto:			rs.l	1 ( char name, unsigned long *h, short maxi )

TSE_GrabFieldIntoFifo:		rs.l	1 ( bool wait, TFieldType field )

TSE_DigitiseFrame:		rs.l	1 ( TBlitWindow *blitwind, POINT *zoom, bool wait )
TSE_ResetGrabber:			rs.l	1 ( void )

TSE_chk_set_video_standard:	rs.l	1 ( unsigned standard )
TSE_chk_set_chan_sig:		rs.l	1 ( short *channel, short *signal, short *byps )
TSE_chk_set_signal:		rs.l	1 ( short channel, short *signal, short *byps )
TSE_set_lumi_cntrl:		rs.l	1 ( short aper, short cori, short bpss,  short pref, short byps )
TSE_GetDmsdStatus:		rs.l	1 ( bool *locked, bool *code, bool *fidt )
TSE_InitMdf:			rs.l	1 ( unsigned signal, unsigned source, short chip )
TSE_InitDmsd:			rs.l	1 ( unsigned chip )


TSE_DigitiseMatrix:		rs.l	1 ( short nx, short ny, TBlitWindow *blitwind, POINT *zoom, bool wait )
TSE_InterPolate555:		rs.l	1 ( TImageWindow *source, TImageWindow *destin, POINT *zoom )
TSE_StretchBlit:			rs.l	1 ( TImageWindow *source, TImageWindow *destin )

TSE_WriteRGBFiles:		rs.l	1 ( char *filename, short w, short h, uword *data )
TSE_WriteTargaFile:		rs.l	1 ( char *filename, short w, short h, uword *data )
TSE_WriteFrame:			rs.l	1 ( SEQUENCE *sequence, char *basename, short frame )
TSE_WriteSequenceHeader:	rs.l	1 ( SEQUENCE *sequence, char *basename, uword format )
TSE_SequenceWrite:		rs.l	1 ( SEQUENCE *sequence, char *basename, short from, short to, uword format )

TSE_ReadTargaFrame:		rs.l	1 ( SEQUENCE *sequence, char *basename, short frame )
TSE_ReadBlockFrame:		rs.l	1 ( SEQUENCE *sequence, char *basename, short frame )
TSE_ReadFrame:			rs.l	1 ( SEQUENCE *sequence, char *basename, short frame )
TSE_ReadSequenceHeader:		rs.l	1 ( SEQUENCE *sequence, char *basename )
TSE_SequenceRead:			rs.l	1 ( SEQUENCE *sequence, char *basename, short from, short to )

TSE_FreeConvBuffer:		rs.l	1 ( void )

TSE_InitSequence:			rs.l	1 ( SEQUENCE *sequence )
TSE_MallocSequence:		rs.l	1 ( SEQUENCE *sequence, short nreq, TImageWindow *srcwnd, POINT *zoom )
TSE_FreeSequence:			rs.l	1 ( SEQUENCE *sequence )
TSE_SequenceInfo:			rs.l	1 ( SEQUENCE *sequence )
TSE_RecordSequence:		rs.l	1 ( SEQUENCE *sequence, bool wait )
TSE_PlaySequence:			rs.l	1 ( SEQUENCE *sequence, TImageWindow *dstwnd )

TSE_RecordStart:			rs.l	1 ( SEQUENCE *sequence )
TSE_RecordStop:			rs.l	1 ( SEQUENCE *sequence )
TSE_RecordRestart:		rs.l	1 ( SEQUENCE *sequence )
TSE_RecordCurrFrame:		rs.l	1 ( SEQUENCE *sequence, bool wait )
TSE_RecordFrame:			rs.l	1 ( SEQUENCE *sequence, short frame, bool wait )

TSE_PlayStart:			rs.l	1 ( SEQUENCE *sequence, short step )
TSE_PlayRestart:			rs.l	1 ( SEQUENCE *sequence )
TSE_PlayStop:			rs.l	1 ( SEQUENCE *sequence )

TSE_PlaySyncCurrent:		rs.l	1 ( SEQUENCE *sequence )

TSE_ActivateFrame:		rs.l	1 ( SEQUENCE *sequence, short frame )
TSE_DisplayCurrentFrame: 	rs.l	1 ( SEQUENCE *sequence, TImageWindow *dstwnd )

TSE_ChkAndSetCurrentFrame:	rs.l	1 ( SEQUENCE *sequence, short frame )
TSE_DisplayFrame:			rs.l	1 ( SEQUENCE *sequence, short frame, TImageWindow *dstwnd )

TSE_AbortLoopFunction:		rs.l	1 ( void )

TSE_LoadMdfLcaFile:		rs.l	1 ( char typ, unsigned ver, unsigned rel )

TSE_SetDmsdType:			rs.l	1 ( short chip, unsigned lcatyp )
TSE_ResetDigiWindows:		rs.l	1 ( TBlitWindow *blitwind )
TSE_CheckDigiWindows:		rs.l	1 ( TBlitWindow *blitwind, POINT *zoom, TImage *dstimg )
TSE_LoadMatDigiFLcaData 	rs.l	1 ( unsigned chip, TDigitiserMode mode, POINT *zoom, bool init )

TSE_yuv_to_rgb:			rs.l	1 ( byte *out, uword y, uword cr, uword cb )
TSE_CheckCalcCSCtables:		rs.l	1 ( short *coeff )

*-----------------------------------------------------------------------*
*	Get MATRIX structure address							*
*-----------------------------------------------------------------------*

callmatrix		macro
	move.l	eye_ptr,a6
	move.l	\1(a6),a6
	jsr		(a6)
	endm

*-----------------------------------------------------------------------*
get_matrix:
*-----------------------------------------------------------------------*
	bsr		GetScreenEyeParameter
	cmp.l		#0,a0
	beq.s		.err
	move.l	a0,a6
	move.l	a0,eye_ptr
	st		matrix_flag
	rts
.err:	sf		matrix_flag
	rts

*-----------------------------------------------------------------------*
init_matrix:
*-----------------------------------------------------------------------*
	tst.b		matrix_flag
	beq		.no

;TSE_ResetGrabber:			rs.l	1 ( void )
;TSE_chk_set_video_standard:	rs.l	1 ( unsigned standard )
;TSE_chk_set_chan_sig:		rs.l	1 ( short *channel, short *signal, short *byps )
;TSE_chk_set_signal:		rs.l	1 ( short channel, short *signal, short *byps )
;TSE_set_lumi_cntrl:		rs.l	1 ( short aper, short cori, short bpss,  short pref, short byps )
;TSE_GetDmsdStatus:		rs.l	1 ( bool *locked, bool *code, bool *fidt )
;TSE_InitMdf:			rs.l	1 ( unsigned signal, unsigned source, short chip )
;TSE_InitDmsd:			rs.l	1 ( unsigned chip )

*-----------------------------------------------------------------------*
	callmatrix	TSE_ResetGrabber
*-----------------------------------------------------------------------*
	move.l	eye_ptr,a6
	move.l	TSE_DmsdParam(a6),a0
	move.w	TDM_dmsd(a0),dmsd
*-----------------------------------------------------------------------*
*	Set video standard AUTO/PAL/NTSC/SECAM					*
*-----------------------------------------------------------------------*
	moveq		#PUP_AUTO,d0
	callmatrix	TSE_chk_set_video_standard
*-----------------------------------------------------------------------*
*	Set signal type									*
*-----------------------------------------------------------------------*
	moveq		#PUP_SVHS,d0	; signal
	moveq		#1,d1			; source
	move.w	dmsd,d2		; chip
	callmatrix	TSE_InitMdf
*-----------------------------------------------------------------------*
*	Init Dmsd structure								*
*-----------------------------------------------------------------------*
	move.w	dmsd,d0
	callmatrix	TSE_InitDmsd
*-----------------------------------------------------------------------*
*	Set grab mode									*
*-----------------------------------------------------------------------*
	move.l	eye_ptr,a0
 	move.l	TSE_DigiParam(a0),a0
	move.w	#1,TDP_waituntilgrabbed(a0)	
*-----------------------------------------------------------------------*
*	Detect SE/SE+									*
*-----------------------------------------------------------------------*
	move.w	#DIGdx7191,field_width
	cmp.w		#7191,dmsd
	beq.s		.d71
	move.w	#DIGdx9051,field_width
.d71:	move.w	field_width,matrix_width
*-----------------------------------------------------------------------*
*	Detect PAL/NTSC									*
*-----------------------------------------------------------------------*
	move.l	eye_ptr,a6
	move.l	TSE_DmsdParam(a6),a0
	move.w	#576,d1
	cmp.w		#PUP_NTSC,TDM_standard(a0)
	bne.s		.pal
	move.w	#480,d1
.pal:	move.w	d1,matrix_height
	lsr.w		d1
	move.w	d1,field_height
*-----------------------------------------------------------------------*
	jsr		initfield_192x144
*-----------------------------------------------------------------------*
.no	move.w	field_width,eyesize
	rts

*-----------------------------------------------------------------------*
set_matrix:
*-----------------------------------------------------------------------*
	tst.b		matrix_flag
	bne		.go
	rts
.go	move.w	dmsd,d0		; chip type
	moveq		#0,d1			; mode 0=colour 1=yc 2=grey
	moveq		#1,d2			; init flag
	lea		zoomval,a0		; zoom ptr
	callmatrix	TSE_LoadMatDigiFLcaData
	rts







	rept		0

*-----------------------------------------------------------------------*
*	Get MATRIX structure address							*
*-----------------------------------------------------------------------*

get_matrix:
	bsr		GetScreenEyeParameter
	cmp.l		#0,a0
	beq.s		.err
	move.l	a0,a6
	move.l	a0,eye_ptr
	st		matrix_flag
	rts
.err:	sf		matrix_flag
	rts

init_matrix:
	tst.b		matrix_flag
	beq		.no
	move.l	eye_ptr,a0
	move.l	TSE_DmsdParam(a0),a0
	move.w	#PUP_AUTO,TDM_signal(a0)
	move.w	#1,TDM_source(a0)
	move.l	eye_ptr,a0
 	move.l	TSE_DigiParam(a0),a0
	move.w	#0,TDP_waituntilgrabbed(a0)	
	move.l	eye_ptr,a0
	move.l	TSE_DmsdParam(a0),a0
	move.w	TDM_dmsd(a0),dmsd
	move.w	dmsd,d0
	move.w	#DIGdx9051,eyesize
	cmp.w		#ALTdmsdType,d0
	bne.s		.ok
	move.w	#DIGdx7191,eyesize
.ok	moveq		#0,d1
	moveq		#1,d2
	move.w	#4,zoomx
	move.w	#2,zoomy
	lea		zoomval,a0
	move.l	eye_ptr,a1
	move.l	TSE_LoadMatDigiFLcaData(a1),a1
	jsr		(a1)
	move.w	dmsd,d2
	moveq		#1,d1
	moveq		#PUP_CVBS,d0
	move.l	eye_ptr,a0
	move.l	TSE_InitMdf(a0),a0
	jsr		(a0)
.no	rts

set_matrix:
	tst.b		matrix_flag
	bne		.go
	rts
.go	move.w	dmsd,d0
	moveq		#0,d1			; 0=colour 1=yc 2=grey
	moveq		#1,d2			; init flag
	lea		zoomval,a0		; zoom ptr
	move.l	eye_ptr,a1
	move.l	TSE_LoadMatDigiFLcaData(a1),a1
	jmp		(a1)

	endr


initfield_768x576:
	st		bigeye
	move.w	#1,zoomx
	move.w	#1,zoomy
	jsr		set_matrix
	move.l	#fetchfield_768x576,eyefetcher
	rts

initfield_768x288:
	st		bigeye
	move.w	#1,zoomx
	move.w	#1,zoomy
	jsr		set_matrix
	move.l	#fetchfield_768x288,eyefetcher
	rts

initfield_384x288:
	st		bigeye
	move.w	#1,zoomx
	move.w	#1,zoomy
	jsr		set_matrix
	move.l	#fetchfield_384x288,eyefetcher
	rts
	
initfield_192x144:
	sf		bigeye
	move.w	#4,zoomx
	move.w	#2,zoomy
	jsr		set_matrix
	move.l	#fetchfield_192x144,eyefetcher
	rts

initfield_96x72:
	sf		bigeye
	move.w	#4,zoomx
	move.w	#2,zoomy
	jsr		set_matrix
	move.l	#fetchfield_96x72,eyefetcher
	rts

fetchfield_768x576:
	push.l	eyeline
	push.l	eyebuffer
	push.w	grab_height
	lsr.w		grab_height
	move.l	eyeline,d6
	move.l	d6,linecopy
	add.l		d6,eyeline
	moveq		#FIELDodd,d0
	jsr		grab_eyefield
	jsr		fetchfield_768x288
	move.l	linecopy,d6
	add.l		d6,eyebuffer
	moveq		#FIELDeven,d0
	jsr		grab_eyefield
	jsr		fetchfield_768x288
	pop.w		grab_height
	pop.l		eyebuffer
	pop.l		eyeline
	rts

fetchfield_768x288:
	cacheoff	d7
	jsr		get_frame
	move.l	eyebuffer,a2
	move.l	eyeline,d7
	move.w	#288,d1
	sub.w		grab_height,d1
	lsr.w		d1
	bra.s		.st
.lskp	move.w	eyesize,d0
	subq		#1,d0
.pskp	tst.w		(a0)
	dbra		d0,.pskp
.st	dbra		d1,.lskp
	moveq		#0,d2
	move.w	eyesize,d2
	divu		#24,d2
	subq		#1,d2
	move.w	grab_height,d1
	subq		#1,d1
.ylp	move.l	a2,a1
	move.w	d2,d0
.xlp	move.w	(a0),(a1)+
	rept		24-1
	move.w	(a0),(a1)+
	endr
	dbra		d0,.xlp
	add.l		d7,a2
	dbra		d1,.ylp
	cacheon	d7
	rts

fetchfield_384x288:
	cacheoff	d7
	jsr		get_frame
	move.l	eyebuffer,a2
	move.l	eyeline,d7
	move.w	#288,d1
	sub.w		grab_height,d1
	lsr.w		d1
	bra.s		.st
.lskp	move.w	eyesize,d0
	lsr.w		d0
	subq		#1,d0
.pskp	tst.w		(a0)
	dbra		d0,.pskp
.st	dbra		d1,.lskp
	moveq		#0,d2
	move.w	eyesize,d2
	divu		#12*2,d2
	subq		#1,d2
	move.w	grab_height,d1
	subq		#1,d1
.ylp	move.l	a2,a1
	move.w	d2,d0
.xlp	move.w	(a0),(a1)+
	tst.w		(a0)
	rept		12-1
	move.w	(a0),(a1)+
	tst.w		(a0)
	endr
	dbra		d0,.xlp
	add.l		d7,a2
	dbra		d1,.ylp
	cacheon	d7
	rts

fetchfield_384x288_clipped:
	cacheoff	d7
	jsr		get_frame
	move.l	eyebuffer,a2
	move.l	eyeline,d7
	move.w	#288,d1
	sub.w		grab_height,d1
	lsr.w		d1
	bra.s		.st
.lskp	move.w	eyesize,d0
	lsr.w		d0
	subq		#1,d0
.pskp	tst.w		(a0)
	dbra		d0,.pskp
.st	dbra		d1,.lskp
	move.w	grab_height,d1
	subq		#1,d1
.ylp	move.l	a2,a1
	move.w	eyesize,d0
	lsr.w		d0
	sub.w		grab_width,d0
	bra.s		.st2
.el1	tst.w		(a0)
.st2	dbra		d0,.el1
	move.w	grab_width,d0
	lsr.w		#3,d0
	subq		#1,d0
.xlp	move.w	(a0),(a1)+
	tst.w		(a0)
	move.w	(a0),(a1)+
	tst.w		(a0)
	move.w	(a0),(a1)+
	tst.w		(a0)
	move.w	(a0),(a1)+
	tst.w		(a0)
	move.w	(a0),(a1)+
	tst.w		(a0)
	move.w	(a0),(a1)+
	tst.w		(a0)
	move.w	(a0),(a1)+
	tst.w		(a0)
	move.w	(a0),(a1)+
	tst.w		(a0)
	dbra		d0,.xlp
	move.w	eyesize,d0
	lsr.w		d0
	sub.w		grab_width,d0
	bra.s		.st3
.el2	tst.w		(a0)
.st3	dbra		d0,.el2
	add.l		d7,a2
	dbra		d1,.ylp
	cacheon	d7
	rts

fetchfield_192x144:
	tst.b		suppress_pip8
	bne.s		.tc
	tst.b		TRUE_FLAG
	beq		fetchfield_192x144bpl
.tc:	cacheoff	d7
	jsr		get_frame	
	move.l	eyebuffer,a2
	move.l	eyeline,d7
	move.w	#144,d1
	sub.w		grab_height,d1
	lsr.w		d1
	bra.s		.st
.lskp	move.w	eyesize,d0
	lsr.w		#2,d0
	subq		#1,d0
.pskp	tst.w		(a0)
	dbra		d0,.pskp
.st	dbra		d1,.lskp
	moveq		#0,d2
	move.w	eyesize,d2
	divu		#12*4,d2
	subq		#1,d2
	move.w	grab_height,d1
	subq		#1,d1
.ylp	move.l	a2,a1
	move.w	d2,d0
.xlp	move.w	(a0),(a1)+
	rept		12-1
	move.w	(a0),(a1)+
	endr
	dbra		d0,.xlp
	add.l		d7,a2
	dbra		d1,.ylp
	cacheon	d7
	rts

fetchfield_96x72:
	tst.b		suppress_pip8
	bne.s		.tc
	tst.b		TRUE_FLAG
	beq		fetchfield_96x72bpl
.tc:	cacheoff	d7
	jsr		get_frame
	move.l	eyebuffer,a2
	move.l	eyeline,d7
	move.w	#72,d1
	sub.w		grab_height,d1
	lsr.w		d1
	bra.s		.st
.lskp	move.w	eyesize,d0
	lsr.w		d0
	subq		#1,d0
.pskp	tst.w		(a0)
	dbra		d0,.pskp
.st	dbra		d1,.lskp
	move.w	grab_height,d1
	subq		#1,d1
.ylp	move.w	eyesize,d0
	lsr.w		#2,d0
	subq		#1,d0
.xlp1	tst.w		(a0)
	dbra		d0,.xlp1
	move.l	a2,a1
	move.w	eyesize,d0
	lsr.w		#3,d0
	subq		#1,d0
.xlp2	move.w	(a0),(a1)+
	tst.w		(a0)
	dbra		d0,.xlp2
	add.l		d7,a2
	dbra		d1,.ylp
	cacheon	d7
	rts

fetchfield_192x144bpl:
	move.w	eyesize,d0
	lsr.w		#2,d0
	move.w	d0,d1
	move.w	d0,d2
	lsr.w		#4,d0
	subq		#1,d0
	move.w	d0,bpleyesize
	and.w		#-16,d2
	sub.w		d2,d1
	lsr.w		d1
	move.w	d1,bpleyegap

	lea		IFACE_COLOURS,a5
	jsr		get_frame
	move.l	eyebuffer,a2
	move.l	eyeline,d7
	move.w	#144,d1
	sub.w		grab_height,d1
	lsr.w		d1
	bra.s		.st
.lskp	move.w	eyesize,d0
	lsr.w		#2,d0
	subq		#1,d0
.pskp	tst.w		(a0)
	dbra		d0,.pskp
.st	dbra		d1,.lskp
	move.w	grab_height,d1
	subq		#1,d1
.ylp	push.w	d1
	move.l	a2,a1
	
	move.w	bpleyegap,d0
	bra.s		.g1
.gl1	tst.w		(a0)	
.g1	dbra		d0,.gl1

	move.w	bpleyesize,d6
.xlp	swap		d6
	move.w	#16-1,d6
.blp	moveq		#32-1,d0
	move.w	(a0),d0
	lsr.w		#6,d0
	and.w		#32-1,d0
	move.w	(a5,d0.w*2),d0
	add.b		d0,d0
	addx.w	d4,d4
	swap		d4
	add.b		d0,d0
	addx.w	d4,d4
	swap		d4
	add.b		d0,d0
	addx.w	d3,d3
	swap		d3
	add.b		d0,d0
	addx.w	d3,d3
	swap		d3
	add.b		d0,d0
	addx.w	d2,d2
	swap		d2
	add.b		d0,d0
	addx.w	d2,d2
	swap		d2
	add.b		d0,d0
	addx.w	d1,d1
	swap		d1
	add.b		d0,d0
	addx.w	d1,d1
	swap		d1
	dbra		d6,.blp
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	swap		d6
	dbra		d6,.xlp

	move.w	bpleyegap,d0
	bra.s		.g2
.gl2	tst.w		(a0)	
.g2	dbra		d0,.gl2

	add.l		d7,a2
	pop.w		d1
	dbra		d1,.ylp
	rts

fetchfield_96x72bpl:
	move.w	eyesize,d0
	lsr.w		#3,d0
	move.w	d0,d1
	move.w	d0,d2
	lsr.w		#4,d0
	subq		#1,d0
	move.w	d0,bpleyesize
	and.w		#-16,d2
	sub.w		d2,d1
	and.w		#-2,d1
	move.w	d1,bpleyegap

	lea		IFACE_COLOURS,a5
	jsr		get_frame
	move.l	eyebuffer,a2
	move.l	eyeline,d7

	move.w	#72,d1
	sub.w		grab_height,d1
	lsr.w		d1
	bra.s		.st
.lskp	move.w	eyesize,d0
	lsr.w		d0
	subq		#1,d0
.pskp	tst.w		(a0)
	dbra		d0,.pskp
.st	dbra		d1,.lskp

	move.w	grab_height,d1
	subq		#1,d1

.ylp	push.w	d1
	move.l	a2,a1

	move.w	eyesize,d6
	lsr.w		#2,d6
	subq		#1,d6
.line	tst.w		(a0)
	dbra		d6,.line

	move.w	bpleyegap,d0
	bra.s		.g1
.gl1	tst.w		(a0)	
.g1	dbra		d0,.gl1

	move.w	bpleyesize,d6
.xlp	swap		d6
	move.w	#16-1,d6
.blp	moveq		#32-1,d0
	move.w	(a0),d0
	lsr.w		#6,d0
	and.w		#32-1,d0
	move.w	(a5,d0.w*2),d0
	tst.w		(a0)
	add.b		d0,d0
	addx.w	d4,d4
	swap		d4
	add.b		d0,d0
	addx.w	d4,d4
	swap		d4
	add.b		d0,d0
	addx.w	d3,d3
	swap		d3
	add.b		d0,d0
	addx.w	d3,d3
	swap		d3
	add.b		d0,d0
	addx.w	d2,d2
	swap		d2
	add.b		d0,d0
	addx.w	d2,d2
	swap		d2
	add.b		d0,d0
	addx.w	d1,d1
	swap		d1
	add.b		d0,d0
	addx.w	d1,d1
	swap		d1
	dbra		d6,.blp
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	swap		d6
	dbra		d6,.xlp

	move.w	bpleyegap,d0
	bra.s		.g2
.gl2	tst.w		(a0)	
.g2	dbra		d0,.gl2

	add.l		d7,a2
	pop.w		d1
	dbra		d1,.ylp
	rts

initfield_768x576e:
	st		bigeye
	move.w	#1,zoomx
	move.w	#1,zoomy
	jsr		set_matrix
	move.l	#exposefield_768x576,eyefetcher
	rts

initfield_768x288e:
	st		bigeye
	move.w	#1,zoomx
	move.w	#1,zoomy
	jsr		set_matrix
	move.l	#exposefield_768x288,eyefetcher
	rts

exposefield_768x576:
	push.l	eyeline
	push.l	eyebuffer
	push.w	grab_height
	lsr.w		grab_height
	move.l	eyeline,d6
	move.l	d6,linecopy
	add.l		d6,eyeline
	moveq		#FIELDodd,d0
	jsr		grab_eyefield
	jsr		exposefield_768x288
	move.l	linecopy,d6
	add.l		d6,eyebuffer
	moveq		#FIELDeven,d0
	jsr		grab_eyefield
	jsr		exposefield_768x288
	pop.w		grab_height
	pop.l		eyebuffer
	pop.l		eyeline
	rts

exposefield_768x288:
	cacheoff	d7
	jsr		get_frame
	move.l	#%1111100000000000,d4
	move.l	#%0000011111100000,d5
	move.l	#%0000000000011111,d6
	move.l	eyebuffer,a2
	move.l	eyeline,d7
	move.w	#288,d1
	sub.w		grab_height,d1
	lsr.w		d1
	bra.s		.st
.lskp	move.w	eyesize,d0
	subq		#1,d0
.pskp	tst.w		(a0)
	dbra		d0,.pskp
.st	dbra		d1,.lskp
	move.w	grab_height,d1
	subq		#1,d1
.ylp	push.w	d1
	move.l	a2,a1
	move.w	eyesize,d0
	lsr.w		#2,d0
	subq		#1,d0
.xlp
	rept		4
	move.w	(a0),d1
	move.l	d1,d2
	move.l	d1,d3
	and.l		d4,d1
	and.l		d5,d2
	and.l		d6,d3
	swap		d1
	lsr.l		#7,d1
	lsl.l		#5,d2
	or.l		d1,d2
	or.l		d2,d3
	add.l		d3,(a1)+
	endr
	dbra		d0,.xlp
	add.l		d7,a2
	pop.w		d1
	dbra		d1,.ylp
	cacheon	d7
	rts

*-----------------------------------------------------------------------*

get_frame:
	lea		$F68000,a0
	tst.b		bigeye
	bne.s		.big
	lea		$F6C000,a0
.big	move.b	#0,$F70001
	tst.w		(a0)
	tst.w		(a0)
	tst.w		(a0)
	tst.w		(a0)
	move.b	#2,$F70001
	rts

	ifd		crap

grab_eyefield:
	move.l	d0,d1
	move.l	eye_ptr,a6
	move.l	TSE_DigiParam(a6),a6
	move.w	eyesync(pc),d0
	move.w	d0,TDP_waituntilgrabbed(a6)
	move.l	eye_ptr,a6
 	move.l	TSE_GrabFieldIntoFifo(a6),a6
 	jmp		(a6)

	endc
	

grab_eyefield:
	move.l	d0,d1
	moveq		#0,d0
	move.w	eyesync(pc),d0
	MOVEM.L   D3-D5,-(A7) 
      MOVE.W    D0,D5 
      MOVE.W    D1,D4 
      MOVEQ     #30,D3
      BRA.S     m00E5 
m00E1:MOVE.W    D4,D0 
      TST.W     D0
      BEQ.S     m00E3 
      SUBQ.W    #1,D0 
      BEQ.S     m00E3 
      SUBQ.W    #1,D0 
      BEQ.S     m00E2 
      BRA.S     m00E4 
m00E2:MOVEQ     #3,D0 
	MOVE.B    D0,$F70001
      BRA.S     m00E4 
m00E3:MOVEQ     #1,D0 
	MOVE.B    D0,$F70001
m00E4:MOVEQ     #2,D0 
      AND.B     $F70001,D0
      BNE.S     m00E6 
      MOVEQ     #1,D0 
      JSR       m05D6 
      SUBQ.W    #1,D3 
m00E5:TST.W     D3
      BGT.S     m00E1 
m00E6:CLR.B     D0
	MOVE.B    D0,$F70001
      TST.W     D3
      BLE.S     m00EB 
      TST.W     D5
      BEQ.S     m00EA 
      MOVEQ     #30,D3
      BRA.S     m00E8 
m00E7:MOVEQ     #1,D0 
      JSR       m05D6 
      SUBQ.W    #1,D3 
m00E8:TST.W     D3
      BLE.S     m00E9 
      MOVEQ     #2,D0 
      AND.B     $F70001,D0
      BNE.S     m00E7 
m00E9:TST.W     D3
      BNE.S     m00EA 
      MOVEQ     #2,D0 
      BRA.S     m00EC 
m00EA:CLR.W     D0
      BRA.S     m00EC 
m00EB:MOVEQ     #1,D0 
m00EC:MOVEM.L   (A7)+,D3-D5 
      RTS 

m05D6:
	MOVEM.L   A2/D6-D7,-(A7)

;	cache		0
;	mulu		#128,d7
;.lp	move.w	.d,.d
;	dbra		d7,.lp
;	cache		ienab|denab|iclr|dclr|wa

      MOVEQ     #0,D7 
      MOVE.W    D0,D7 

;      PEA       1.W 
;      MOVE.W    #32,-(A7) 	;SUPER 
;      TRAP      #1
;      ADDQ.W    #6,A7 
;      MOVE.L    D0,D6 
;      BNE.S     m05D7 
;      CLR.L     -(A7) 
;      MOVE.W    #32,-(A7) 	;SUPER 
;      TRAP      #1
;      ADDQ.W    #6,A7 

	cache		ienab

m05D7:lea		$4ba.w,a2
	DIVU      #5,D7 
      AND.L     #65535,D7 
      ADD.L     	(a2),D7
m05D8:CMP.L		(a2),D7 
      BPL.S     m05D8 

	cache		ienab|denab|dclr

;      TST.W     D6
;      BNE.S     m05D9 
;      MOVE.L    D0,-(A7)
;      MOVE.W    #32,-(A7) 	;SUPER 
;      TRAP      #1
;      ADDQ.W    #6,A7 
;m05D9:

	MOVEM.L   (A7)+,A2/D6-D7
      RTS 

.d	ds.w		1


*-----------------------------------------------------------------------*
* Return -> to TScreenEyeParameterBlock in a0..  a0 = 0L if not found.	*
* Being in supervisor mode is necessary.						*
*-----------------------------------------------------------------------*

GetScreenEyeParameter:
		move.l	#'mSEY',d0
		bsr		FindEyeCookie
		move.l	d1,a0
		rts

FindEyeCookie:
		move.l	$5a0.w,a0
		cmp.l		#0,a0
		beq.s		.fin
.lp:		tst.l		(a0)
		beq.s		.fin
		cmp.l		(a0),d0
		beq.s		.found
		addq.l	#8,a0
		bra.s		.lp
.found:	moveq		#1,d0	; yes cookie
		move.l	4(a0),d1 ; yes value.
		rts
.fin:		moveq		#0,d0	; no cookie
		moveq		#0,d1	; no value.
		rts

*-----------------------------------------------------------------------*

matrix_width:	ds.w	1
matrix_height:	ds.w	1
field_width:	ds.w	1
field_height:	ds.w	1

bpleyegap:		ds.w	1
bpleyesize:		ds.w	1
eyesize:		ds.w	1
eyesync:		dc.w	0
dmsd:			ds.w	1

matrix_flag		ds.b	1
bigeye:		ds.b	1
suppress_pip8:	ds.b	1
			even
		
eye_ptr:		ds.l	1
eyefetcher:		ds.l	1
eyebuffer:		ds.l	1
eyeline:		ds.l	1
linecopy:		ds.l	1

zoomval:
zoomx:		dc.w	4
zoomy:		dc.w	2

*-----------------------------------------------------------------------*
		text
*-----------------------------------------------------------------------*

		
		
		