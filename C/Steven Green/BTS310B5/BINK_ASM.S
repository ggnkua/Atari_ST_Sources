; bink_asm.s
;
; ST version of bink_asm.asm
; (C) 1990 STeVeN W Green
;
;--------------------------------------------------------------------------;
;                                                                          ;
;                                                                          ;
;      ------------         Bit-Bucket Software, Co.                       ;
;      \ 10001101 /         Writers and Distributors of                    ;
;       \ 011110 /          Freely Available<tm> Software.                 ;
;        \ 1011 /                                                          ;
;         ------                                                           ;
;                                                                          ;
;  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. ;
;                                                                          ;
;                                                                          ;
;                   Assembly routines for BinkleyTerm                      ;
;                                                                          ;
;                                                                          ;
;    For complete  details  of the licensing restrictions, please refer    ;
;    to the License  agreement,  which  is published in its entirety in    ;
;    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    ;
;                                                                          ;
;    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    ;
;    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    ;
;    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    ;
;    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    ;
;    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    ;
;    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    ;
;    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    ;
;    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      ;
;                                                                          ;
;                                                                          ;
; You can contact Bit Bucket Software Co. at any one of the following      ;
; addresses:                                                               ;
;                                                                          ;
; Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  ;
; P.O. Box 460398                AlterNet 7:491/0                          ;
; Aurora, CO 80046               BBS-Net  86:2030/1                        ;
;                                Internet f491.n132.z1.fidonet.org         ;
;                                                                          ;
; Please feel free to contact us at any time to share your comments about  ;
; our software and/or licensing policies.                                  ;
;--------------------------------------------------------------------------;

  ifd LATTICE
	csect text,0
  else
	text 0
  endc	

;--------------------
; BOOL get_dcd()
;
; Returns TRUE if carrier is present
;        FALSE if no carrier
;
; Must be called in Superviser mode, e.g. with status = Supexec(get_dcd);

  ifd REGARGS
	xdef @get_dcd
@get_dcd:
  else
	xdef get_dcd
get_dcd:
  endc
	moveq.l #0,d0				; Clear all of D0
	move.l d0,a0				; Offset address as 8 bit from 0
	move.b $fffffa01(a0),d0		; read the mfp port
	andi.b #2,d0				; Mask off the dcd bit
	eori.b #2,d0				; Invert it
	rts


;---------------------
; BOOL get_cts()
;
; Returns TRUE if CTS is high (data can be sent)
;
; This was written by Iian Paton (2:295/5)

  ifd REGARGS
    xdef @get_cts
@get_cts:
  else
  	xdef get_cts
get_cts:
  endc
  	moveq.l #0,d0
  	move.l d0,a0
  	move.b $fffffa01(a0),d0
  	andi.b #4,d0
  	eori.b #4,d0
  	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;cProc   real_flush,<xdef>
;        parmW fhandle
;
;cBegin

  ifd REGARGS
	xdef @real_flush
@real_flush:
  else
	xdef real_flush
real_flush:
  endc
	moveq #0,d0
	rts



         end

