if 1=1
  macro addpath
  	if developerpath
  	  dc.b "c:\\\\utils\\\\devpac\\\\s\\\\tlktlk2\\\\diskdata\\\\"
  	else
  	  dc.b "tlktlk2.d8a\\\\"
  	endif
  	endm
else
  macro addpath
  	if developerpath
  	  dc.b "c:\\utils\\devpac\\s\\tlktlk2\\diskdata\\"
  	else
  	  dc.b "tlktlk2.d8a\\"
  	endif
  	endm
endif

macro wait4copperlistdone
.copperlistdone\~:
	cmp.w #0,copperlistdone
	beq .copperlistdone\~
	endm

macro copycopper2copperlea
	lea \1,a0
	bsr copycopperlist2copperlist
	endm

macro copycopper2smokecopperlea
	lea \1,a0
	bsr copycopperlist2smokecopperlist
	endm

deiceme equ 1
dontdeiceme equ 0

macro musload
	pushall
	lea mus\1filename,a0
	lea mus\1,a1
	move.l #\2,d0
	bsr loadfile
	cmp.l #0,d0
	beq .ok\~
	add.w #1,loaddatacurrentdisk
.retry\~:
	bsr loaddatanextdisk
	if enableforcemediachange
	  bsr forcemediachange
	endif
	lea mus\1filename,a0
	lea mus\1,a1
	move.l #\2,d0
	bsr loadfile
	cmp.l #0,d0
	bne .retry\~
.ok\~:
	popall
	endm

macro dataload
	pushall
	lea \1filename,a0
	lea \1,a1
	move.l #\2,d0
	bsr loadfile
	cmp.l #0,d0
	beq .ok\~
	add.w #1,loaddatacurrentdisk
.retry\~:
	bsr loaddatanextdisk
	if enableforcemediachange
  	bsr forcemediachange
	endif
	lea \1filename,a0
	lea \1,a1
	move.l #\2,d0
	bsr loadfile
	cmp.l #0,d0
	bne .retry\~
.ok\~:
	if \3
  	lea \1,a0
  	jsr deice1pos
	endif
	popall
	endm

macro runtimeload
	pushall
	lea \1filename,a0
	lea \1,a1
	move.l #\2,d0
	bsr loadfile
	cmp.l #0,d0
	beq .ok\~
	bra loaddataerrormessage
.ok\~:
	if \3
	lea \1,a0
	jsr deice1pos
	endif
	popall
	endm

macro loadupdategauge
	bsr loaddataupdategauge
	endm

macro framebsr
; Usage: framebsr [framecounter],[subroutine]
	cmp.l #\1,framecounter
	bne .framebsrnope\~
	bsr \2
.framebsrnope\~:
	endm

macro resetframecount
	move.l #0,framecounter
	endm

macro waitforframecount
	if \1<1 ; disallow values lower than 1
	  fail "macro waitforframecount received input lower than 1"
	endif
.framewait\~:
	vblwait 1
	cmp.l #\1,framecounter
	blt .framewait\~
	cmp.l #\1,framecounter
	bgt .error\~
	bra .exit\~
.error\~:
	move.w #$0f33,$ffff8240
	move.w #$0f33,currentpalette
.exit\~:
	endm

macro waitforframecountwithfade
	if \1<1 ; disallow values lower than 1
	fail
	endif
.framewait\~:
	vblwait 1
	bsr fadepalettesdoonefade
	cmp.l #\1,framecounter
	blt .framewait\~
	cmp.l #\1,framecounter
	bgt .error\~
	bra .exit\~
.error\~:
	move.w #$0f33,$ffff8240
	move.w #$0f33,currentpalette
.exit\~:
	endm

macro flashfromwhite
	pushall
	lea currentpalette,a0
	lea flashfromwhitepal,a1
	movem.l (a0)+,d0-d7
	movem.l d0-d7,(a1)
	setpalette allwhitepal
	vblwait 1
	fade2palette flashfromwhitepal,1
	popall
	endm

macro vblinstall
	pusha0
	lea \1,a0
	move.l a0,vblextraaddress
	popa0
	endm

macro copy2copperlea
; In: a0 - address of doo
;     d0 - scroll value to put in copper list
	movem.l a0/d0,-(sp)
	lea \1,a0
	move.l #\2,d0
	bsr copydoolines2copper
	movem.l (sp)+,a0/d0
	endm

macro copy2coppera0
; In: a0 - address of doo
;     d0 - scroll value to put in copper list
	pushd0
	move.l #\1,d0
	bsr copydoolines2copper
	popd0
	endm

macro copy2smokecopperlea
; In: a0 - address of doo
;     d0 - scroll value to put in copper list
	movem.l a0/d0,-(sp)
	lea \1,a0
	move.l #\2,d0
	bsr copydoolines2smokecopper
	movem.l (sp)+,a0/d0
	endm


macro copy2smokecoppera0
; In: a0 - address of doo
;     d0 - scroll value to put in copper list
	pushd0
	move.l #\1,d0
	bsr copydoolines2smokecopper
	popd0
	endm

macro copy2coppermove
; In: a0 - address of pointer to doo
;     d0 - scroll value to put in copper list
	movem.l a0/d0,-(sp)
	move.l \1,a0
	move.l #\2,d0
	bsr copydoolines2copper
	movem.l (sp)+,a0/d0
	endm

macro deiceleasmokescreen
	movem.l a0/a1,-(sp)
	lea \1,a0
	move.l smokescreenaddress,a1
	jsr deice
	movem.l (sp)+,a0/a1
	endm

macro deiceleascreen
	movem.l a0/a1,-(sp)
	lea \1,a0
	move.l screenaddress,a1
	jsr deice
	movem.l (sp)+,a0/a1
	endm

macro deicelealea
	movem.l a0/a1,-(sp)
	lea \1,a0
	lea \2,a1
	jsr deice
	movem.l (sp)+,a0/a1
	endm

macro vblwaitwithpalettefade
; Usage: vblwait [number of frames to wait, minimum 1]
	if \1<1 ; disallow values lower than 1
	  fail
	endif
	pushd0
	move.l #\1-1,d0
	bsr wait4vbld0withpalettefade
	popd0
	endm

macro vblwait
; Usage: vblwait [number of frames to wait, minimum 1]
	if \1<1 ; disallow values lower than 1
	  fail
	endif
	pushd0
	move.l #\1-1,d0
	jsr wait4vbld0
	popd0
	endm

macro syncwait
; Usage: syncwait [maxYMiser zync value (in hex) to wait for]
	pushd0
	move.l #\1,d0
	jsr wait4sync
	popd0
	endm

macro setpalette
	pusha0
	lea \1,a0
	bsr setpalettenextframe
	popa0
	endm

macro fade2palette
; Usage: fade2palette [address to palette],[number of frames between steps, minimum 1]
	if \2<1 ; disallow values lower than 1
	  fail
	endif
	movem.l a0/d0,-(sp)
	lea \1,a0
	move.l #\2-1,d0
	bsr fadepalettesaesthetic
	movem.l (sp)+,a0/d0
	endm

macro fade2palettescrollleft
; Usage: fade2palette [address to palette],[number of frames between steps, minimum 1]
	if \2<1 ; disallow values lower than 1
	  fail
	endif
	movem.l a0/d0,-(sp)
	lea \1,a0
	move.l #\2-1,d0
	bsr fadepalettesaestheticandscrollleft
	movem.l (sp)+,a0/d0
	endm

macro fade2palettescrollright
; Usage: fade2palette [address to palette],[number of frames between steps, minimum 1]
	if \2<1 ; disallow values lower than 1
	  fail
	endif
	movem.l a0/d0,-(sp)
	lea \1,a0
	move.l #\2-1,d0
	bsr fadepalettesaestheticandscrollright
	movem.l (sp)+,a0/d0
	endm

