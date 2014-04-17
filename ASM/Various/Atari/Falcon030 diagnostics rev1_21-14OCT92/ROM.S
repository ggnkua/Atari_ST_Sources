		.include hardware
	.include defs
	.include nvram

	.globl romtst,dspvers,config
*  ROM checksum test

* 07AUG92 : RWS : HACKED UP FOR SPARROW ROM (1 x 16bit, 512K)
*  Oct 14, 90: modified length of crc check (used to be only 64k)
*  Aug 30, 90: major rewrite for crc in rom check -tf-
*  March 15, 90: add TOS 1.62
*  Aug 4, 89: 256k at E00000, in 2 ROMs. 9 countries.
*  June 15, 89: if unlisted version display version number only once.
*  Feb 17, 89: revise procedure for checking version number and add turkish.
*  Oct 1, 87: For TOS V2. Check version and configuration bytes and do crc.
*  Feb 3, 87   edit for madmac
*  Nov 26, 86  Check for correct placement
*  Nov 13, 86  Check that ROMs are all of same type (US,French,etc.)
*  Oct 23, 86  Add Spanish 60 Hz ROM
*  Accumulate checksums for 2 boot ROMs or 6 TOS ROMs and display.
*  Display International versions
*  If multi-cycle, display errors only

latvrs  equ     $0162           ;latest version
version equ     $e00002         ;
config  equ     $e0001c         ;country/language and TV standard
osroml  equ     $e00000         ;start of rom
crcloc	equ	$e7fffe		;location of crc

romsiz  equ     $80000/2        ;size of TOS ROM (words)
romsiz4 equ     $80000          ;total TOS  d1,ibufhead(a0) ;store new head pointer to buffer record


	.text
romtst:
	lea     tcsmsg,a5
	bsr     dsptst

	clr.b   erflg0
	clr.b   erflg1

*       display version, TV standard, country/language
	bsr     dspvers

*       Get checksums for 1 ROM
tosrom1:
	movea.l #osroml,a0
	move.l  #romsiz,d4
	bsr     chksum          ;checksum E00000-E80000
	move    d1,csl0
;RWS.TPE	move    d2,csh0
	lea     csmsg,a5        ;display header
	bsr     dspmsg
	lea     romcs,a5
	bsr     dspmsg
	move    csl0,d1
;RWS.TPE	move    csh0,d2
	bsr     d_dsp           ;display checksums calculated

*       Get crc for 2 ROMs
	lea     osroml,a0
	move.l  #(romsiz*2)-2,d2      
	bsr     getcrc          ;even
	move    d0,crcl0
;RWS.T	adda.l  #1,a0           ;odd
;RWS.T	move.l  #romsiz-2,d2
;RWS.T	bsr     getcrc	
;	move    d0,crch0
	lea     romcrc,a5
	bsr     dspmsg

	move    crcl0,d1
;RWS.TPE	move    crch0,d2
	bsr     d_dsp         ;display crc calculated

*  get rom crc's in d1,d2
	lea      crcloc,a0
	move.w	(a0),d1

;RWS.TPE;	move.b   (a0),d1
;RWS.TPE;	lsl      #8,d1
;RWS.TPE;	move.b   2(a0),d1          ;d1 = low crc word
;RWS.TPE;	move.b   1(a0),d2
;RWS.TPE;	lsl      #8,d2
;RWS.TPE;	move.b   3(a0),d2          ;d2 = high crc word

*-------------------------------
*    displays crc errors
*         word d1,d2 compared with calculated d1,d2 in crch0/crcl0
*         
	bsr     escp            ;in case error - set video inverse
	clr.l   d6              ;clear flag
	cmp     crcl0,d1         ;check low crc
	beq.s   trom1
	bset    #1,d6           ;set error flag
	lea     crcerr,a5       ;display error msg
	bsr     dspmsg
;RWS.TPE	lea     crcer1,a5
;RWS.TPE	bsr     dspmsg
	bsr     dspwrd
	bsr     crlf
trom1:
;RWS.TPE	cmp     crch0,d2        ;check high crc
;RWS.TPE	beq.s   trom2
;RWS.TPE	bset    #1,d6
;RWS.TPE	lea     crcerr,a5
;RWS.TPE	bsr     dspmsg
;RWS.TPE	lea     crcer2,a5
;RWS.TPE	bsr     dspmsg
;RWS.TPE	move    d2,d1             ;dspwrd requires number in d1
;RWS.TPE	bsr     dspwrd
;RWS.TPE	bsr     crlf
trom2:  bsr     escq              ;turn off inverse video

	move.b  d6,erflg1       ;crc errors?

*       print failure or print pass and return to menu
romend: tst.b   erflg0
	bne.s   romfal
	tst.b   erflg1
	bne.s   romfal

	lea     pasmsg,a5
	bra.s   rend

romfal: lea     falmsg,a5
	move    #red,palette

rend:   move.b	#t_ROM,d0
	bsr     dsppf
romx:   rts

*       END OF ROM TEST MAIN
**********************************************

*--------------------------------------------------------
*       display version, country/language and TV standard
*               at current cursor position
dspvers:
	lea     vermsg,a5
	bsr     dspmsg
	move    version,d1      ;get version word
	move    d1,d2
	lsr     #8,d1   
	bsr     dspasc          ;high digit
	move    #'.',d1
	bsr     ascii_out
	move    d2,d1
	lsr     #4,d1
	bsr     dspasc
	move    d2,d1
	bsr     dspasc          ;low digit
	bsr     dspspc
	clr.l   d0
;        move    version,d0      ;get version number 
;        cmpi    #latvrs,d0      ;legal version?
;        ble     tos1            ;br ok
;        lea     future,a5
;        bsr     dspmsg
;        move    #yellow,palette

;tos1:
;	move    config,d0       ;get country code 
;	andi    #$1e,d0         ;use bits 1-4
;	lsl     #1,d0           ;long offset for msg ptr
;	lea     langtb,a0
;	move.l  0(a0,d0),a5
;	bsr     dspmsg          ;display country/language
;
;	btst    #0,config+1     ;test pal/ntsc bit
;	beq     ntsc
;	lea     palmsg,a5
;	bra     dsptv
;ntsc:   lea     ntscms,a5
;dsptv:  bsr     dspmsg          ;display TV standard
dspverx:
	rts

*----------------------------------------
*       display word values of d1,d2
*
d_dsp:  bsr     dspwrd          ;display value u206
;RWS.TPE	bsr     dsptab
;RWS.TPE	move    d2,d1
;RWS.TPE	bsr     dspwrd          ;display value u207
	bsr     crlf
	rts

	        
*-------------------------------
*       Checksum high and low 
*       Entry   a0=start address
*               d4=number of words
*       Exit:   d1.w=checksum of low ROM
*               d2.w=checksum of high ROM
chksum: moveq   #0,d1
	moveq   #0,d0
;RWS.TPE	moveq   #0,d2
chksm1: move.b  (a0)+,d0        ;read a byte
	add.w   d0,d1           ;accumulate checksum of low rom
	move.b  (a0)+,d0
	add.w   d0,d1           ;accumulate checksum of high rom
	subi.l  #1,d4
	bne.s   chksm1
	rts

*-------------------------------
*       generate crc for a block of data
*       entry:  a0 = start of block
*               d2 = number of bytes
*       exit:   d0 = crc

getcrc: move.l  a0,-(sp)
	clr     d0
	clr     d1
	clr     d3
	lea     crctab,a2
crclp:  move    d0,d1           ;d1=current crc value
	lsl     #8,d0           ;shift left (low byte in high)
	lsr     #8,d1           ;shift right (high byte in low)
	move.b  (a0)+,d3        ;get byte
;RWS.T	adda.l  #1,a0           ;advance ptr to next byte if high/low ROMs
	eor.b   d3,d1           ;eor with right shifted crc (high byte)
	lsl     #1,d1           ;x2, make it word-sized offset
	move    0(a2,d1),d4     ;use as offset into crctab
	eor     d4,d0           ;eor with lsl'd crc
	sub.l   #1,d2
	bne     crclp           ;until all bytes crc'd
	move.l  (sp)+,a0
	rts
	                
********************************
	.data
	.even

*       divisor for crc
crctab:
	dc.w    $0000,$1021,$2042,$3063,$4084,$50a5,$60c6,$70e7
	dc.w    $8108,$9129,$a14a,$b16b,$c18c,$d1ad,$e1ce,$f1ef
	dc.w    $1231,$0210,$3273,$2252,$52b5,$4294,$72f7,$62d6
	dc.w    $9339,$8318,$b37b,$a35a,$d3bd,$c39c,$f3ff,$e3de
	dc.w    $2462,$3443,$0420,$1401,$64e6,$74c7,$44a4,$5485
	dc.w    $a56a,$b54b,$8528,$9509,$e5ee,$f5cf,$c5ac,$d58d
	dc.w    $3653,$2672,$1611,$0630,$76d7,$66f6,$5695,$46b4
	dc.w    $b75b,$a77a,$9719,$8738,$f7df,$e7fe,$d79d,$c7bc
	dc.w    $48c4,$58e5,$6886,$78a7,$0840,$1861,$2802,$3823
	dc.w    $c9cc,$d9ed,$e98e,$f9af,$8948,$9969,$a90a,$b92b
	dc.w    $5af5,$4ad4,$7ab7,$6a96,$1a71,$0a50,$3a33,$2a12
	dc.w    $dbfd,$cbdc,$fbbf,$eb9e,$9b79,$8b58,$bb3b,$ab1a
	dc.w    $6ca6,$7c87,$4ce4,$5cc5,$2c22,$3c03,$0c60,$1c41
	dc.w    $edae,$fd8f,$cdec,$ddcd,$ad2a,$bd0b,$8d68,$9d49
	dc.w    $7e97,$6eb6,$5ed5,$4ef4,$3e13,$2e32,$1e51,$0e70
	dc.w    $ff9f,$efbe,$dfdd,$cffc,$bf1b,$af3a,$9f59,$8f78
	dc.w    $9188,$81a9,$b1ca,$a1eb,$d10c,$c12d,$f14e,$e16f
	dc.w    $1080,$00a1,$30c2,$20e3,$5004,$4025,$7046,$6067
	dc.w    $83b9,$9398,$a3fb,$b3da,$c33d,$d31c,$e37f,$f35e
	dc.w    $02b1,$1290,$22f3,$32d2,$4235,$5214,$6277,$7256
	dc.w    $b5ea,$a5cb,$95a8,$8589,$f56e,$e54f,$d52c,$c50d
	dc.w    $34e2,$24c3,$14a0,$0481,$7466,$6447,$5424,$4405
	dc.w    $a7db,$b7fa,$8799,$97b8,$e75f,$f77e,$c71d,$d73c
	dc.w    $26d3,$36f2,$0691,$16b0,$6657,$7676,$4615,$5634
	dc.w    $d94c,$c96d,$f90e,$e92f,$99c8,$89e9,$b98a,$a9ab
	dc.w    $5844,$4865,$7806,$6827,$18c0,$08e1,$3882,$28a3
	dc.w    $cb7d,$db5c,$eb3f,$fb1e,$8bf9,$9bd8,$abbb,$bb9a
	dc.w    $4a75,$5a54,$6a37,$7a16,$0af1,$1ad0,$2ab3,$3a92
	dc.w    $fd2e,$ed0f,$dd6c,$cd4d,$bdaa,$ad8b,$9de8,$8dc9
	dc.w    $7c26,$6c07,$5c64,$4c45,$3ca2,$2c83,$1ce0,$0cc1
	dc.w    $ef1f,$ff3e,$cf5d,$df7c,$af9b,$bfba,$8fd9,$9ff8
	dc.w    $6e17,$7e36,$4e55,$5e74,$2e93,$3eb2,$0ed1,$1ef0



;langtb: 
;	dc.l    usamsg          ;config word = 0
;	dc.l    germsg          ;1
;	dc.l    framsg          ;2
;	dc.l    ukmsg           ;3
;	dc.l    spnmsg          ;4
;	dc.l    itlmsg          ;5
;	dc.l    swdmsg          ;6
;	dc.l    swfmsg          ;7
;	dc.l    swgmsg          ;8
;	dc.l    trkmsg          ;9
;	dc.l    finmsg          ;10
;	dc.l    normsg          ;11
;	dc.l    denmsg          ;12
;	dc.l    arbmsg          ;13
;	dc.l    holmsg          ;14
;	dc.l    unasgn          ;15

tcsmsg: dc.b    'ROM checksum/crc test',cr,lf,eot
vermsg: dc.b    'TOS Version ',eot
romevn: dc.b    'ROM checksum, crc',cr,lf,eot

csmsg:  dc.b    cr,lf
	dc.b    'PROM',cr,lf,eot
romcs:  dc.b    'Calculated ROM checksum',tab,eot
romcrc: dc.b    'Calculated ROM CRC     ',tab,eot
crcerr: dc.b    'CRC  mismatch  in   u51',tab,eot

;palmsg: dc.b    'PAL',cr,lf,eot
;ntscms: dc.b    'NTSC',cr,lf,eot
;usamsg: dc.b    'USA ',eot
;germsg: dc.b    'German ',eot
;framsg: dc.b    'French ',eot
;ukmsg:  dc.b    'UK ',eot
;spnmsg: dc.b    'Spanish ',eot
;itlmsg: dc.b    'Italian ',eot
;swdmsg: dc.b    'Swedish ',eot
;swfmsg: dc.b    'Swiss French ',eot
;swgmsg: dc.b    'Swiss German ',eot
;trkmsg: dc.b    'Turkish ',eot
;finmsg: dc.b    'Finnish ',eot
;normsg: dc.b    'Norwegian ',eot
;denmsg: dc.b    'Danish ',eot
;arbmsg: dc.b    'Arabic ',eot
;holmsg: dc.b    'Dutch ',eot
unasgn: dc.b    ' ',eot			; was: Unused Country Code
future: dc.b    'New version number',cr,lf,eot
	.end
