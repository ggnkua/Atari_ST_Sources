;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; File        : VGOVBE20.ASM
; Description : VBE 2.0 interface routines
; Notes       : Brought to you by Vertigo. If you use this, or have 
;	        learned from this, send us an email and/or Greet us
;               In your demo =).
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
; Modification History
; --------------------
;
; v1.0 -
; 08-06-96	- Rewritten new VBE 2.0 core			- TimJ
; 05-10-96	- Added vbeGetModeInfo 				- TimJ
; 24-10-96	- vbeGetModeInfo returns all VBE mode info	- TimJ
; 24-03-96      - Released                                      - Vertigo
;
; A nice fast clean VBE 2.0 assembly interface. This does everything you
; need including the mapping of low mem VBE pointers and strings into
; protected mode memory.
; It's all self contained and the header file is VGOVBE20.H
;
; The only major thing it lacks is it's own Virtual Linear Frame buffer
; code.
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; vbeDetect
; Detect and get VBE info
;
; In:
;   NONE
;
; Out:
;    EAX - returns pointer to a VBEINFO structure,
;          or NULL on failure
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        .code
vbeDetect:
	pushad
	; Allocate low memory buffer for
	; communcation with VBE
	mov	ax, 0100h
	mov	bx, 512/16
	int	031h
	jnc	@@vbedetectl1

	popad
	xor	eax,eax
	ret
@@vbedetectl1:
	; Save the real mode info
	mov	ecx,eax
	and	ecx,0FFFFh
	shl	ecx,4
        mov     [dosmem_address],ecx              ; save linear address
        mov     [dosmem_segment],ax
        mov     [dosmem_selector],dx
	; Request VBE 2.0 info
        mov     dword ptr [ecx.VBEINFOBLOCK.VbeSignature],'2EBV'
	; Get the VBE infomation block
        lea     edi,RMREGS
        mov     [rm_eax], 04f00h
        mov     [rm_es], ax
        mov     [rm_edi], 0
	mov     ax, 0300h			; simulate real mode int
	mov     bl, 010h
	mov	bh, 0
	mov     cx, 0
        push    ds
        pop     es
	int     031h
	jc	@@error				; DPMI error
        mov     eax,[rm_eax]
	cmp     al,04fh
	jne	@@error				; vbe not detected

        mov     esi,[dosmem_address]
        cmp     dword ptr [esi.VBEINFOBLOCK.VbeSignature],'ASEV'
	jne	@@error				; Not VESA!

	; Copy the block into protected mode memory
	mov	edi, offset vbeInfo
	mov	ecx, size vbeInfo
	rep	movsb
	; Copy needed information into a local buffer
	; and fix up the addresses in the vbeInfo block
	mov	ebp, offset vbeInfo		; pmode vbeinfo block
	mov	edi, offset localBuf		; local buffer
	; Copy the mode list
        mov     eax, [dosmem_address]
        mov     esi, [eax.VBEINFOBLOCK.VideoModePtr]
	mov     eax, esi
	and     eax, 0ffffh
	shr     esi, 16
	and     esi, 0ffffh
	shl     esi, 4
	add     esi, eax			; eax = linear addr

        mov     [ebp.VBEINFOBLOCK.VideoModePtr],edi

@@vbedetectl2:
	lodsw
	cmp	ax,-1				; end of list
	je	@@vbedetectl3
	stosw
	jmp	@@vbedetectl2
@@vbedetectl3:
	stosw                                   ; terminate list

	; Copy the OEM string

        mov     eax, [dosmem_address]
        mov     esi, [eax.VBEINFOBLOCK.OemStringPtr]
	mov     eax, esi
	and     eax, 0ffffh
	shr     esi, 16
	and     esi, 0ffffh
	shl     esi, 4
	add     esi, eax			; eax = linear addr

        mov     [ebp.VBEINFOBLOCK.OemStringPtr],edi

@@vbedetectl4:
	lodsb
	cmp	al,0				; end of list
	je	@@vbedetectl5
	stosb
	jmp	@@vbedetectl4
@@vbedetectl5:
	xor	al,al				; NULL terminate string
	stosb
	; Copy VBE 2.0 Strings to the local buffer
        mov     eax, [dosmem_address]
        cmp     [eax.VBEINFOBLOCK.VbeVersion],0200h
	jl	@@vbedetect_NOTVBE2

	; OEM Vendor Name

        mov     eax, [dosmem_address]
        mov     esi, [eax.VBEINFOBLOCK.OemVendorNamePtr]
	mov     eax, esi
	and     eax, 0ffffh
	shr     esi, 16
	and     esi, 0ffffh
	shl     esi, 4
	add     esi, eax			; eax = linear addr

        mov     [ebp.VBEINFOBLOCK.OemVendorNamePtr],edi

@@vbedetectl6:
	lodsb
	cmp	al,0				; end of list
	je	@@vbedetectl7
	stosb
	jmp	@@vbedetectl6
@@vbedetectl7:
	xor	al,al				; NULL terminate string
	stosb

	; OEM Product Name

	mov	eax, dosmem_address
        mov     esi, [eax.VBEINFOBLOCK.OemProductNamePtr]
	mov     eax, esi
	and     eax, 0ffffh
	shr     esi, 16
	and     esi, 0ffffh
	shl     esi, 4
	add     esi, eax			; eax = linear addr

        mov     [ebp.VBEINFOBLOCK.OemProductNamePtr],edi

@@vbedetectl8:
	lodsb
	cmp	al,0				; end of list
	je	@@vbedetectl9
	stosb
	jmp	@@vbedetectl8
@@vbedetectl9:
	xor	al,al				; NULL terminate string
	stosb

	; OEM Vendor Revision

        mov     eax, [dosmem_address]
        mov     esi, [eax.VBEINFOBLOCK.OemProductRevPtr]
	mov     eax, esi
	and     eax, 0ffffh
	shr     esi, 16
	and     esi, 0ffffh
	shl     esi, 4
	add     esi, eax			; eax = linear addr

        mov     [ebp.VBEINFOBLOCK.OemProductRevPtr],edi

@@vbedetectl10:
	lodsb
	cmp	al,0				; end of list
	je	@@vbedetectl11
	stosb
	jmp	@@vbedetectl10
@@vbedetectl11:
	xor	al,al				; NULL terminate string
	stosb

	jmp	@@vbedetect_ALMOSTDONE


	; set the VBE 2.0 strings to NULL

@@vbedetect_NOTVBE2:

        mov     [ebp.VBEINFOBLOCK.OemVendorNamePtr], edi
        mov     [ebp.VBEINFOBLOCK.OemProductNamePtr], edi
        mov     [ebp.VBEINFOBLOCK.OemProductRevPtr], edi
	xor	al,al
	stosb

@@vbedetect_ALMOSTDONE:


	; Check if we over-ran the local buffer

	cmp	edi,offset localBufEnd
	jge	@@error


	; The Boca Vortex VBE implementation returns a version number of
	; 2.2, but it's really only VBE 1.2 (2.2 is the version number of
	; their VBE BIOS!

        cmp     [ebp.VBEINFOBLOCK.VbeVersion],0200h
	jle	@@vbedetect_NOTMENTAL

        mov     esi,[ebp.VBEINFOBLOCK.OemStringPtr]
	mov	edi,offset vortexStr

	mov	ecx,6

@@vbedetectl12:
	lodsb
	cmp	byte ptr [edi],al
	jne	@@vbedetect_NOTMENTAL
	loop	@@vbedetectl12
        mov     [ebp.VBEINFOBLOCK.VbeVersion],0102h

@@vbedetect_NOTMENTAL:


	; Release DOS memory then return pointer to vbeInfo struct

	mov	ax, 0101h			; free dos memory buffer
        mov     dx, [dosmem_selector]
	int	031h
	popad
	mov eax,offset vbeInfo
	ret


	; Release DOS memory then return Null

@@error:
	mov	ax, 0101h			; free dos memory buffer
        mov     dx, [dosmem_selector]
	int	031h
	popad
	mov eax,0
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; vbeGetModeInfo
; Setup up a video mode
;
; In:
;   EAX -  Mode
;   EDX -> Address of VBEMODEINFO structure
;
; Out:
;    Returns 1, mode info has been copied to the VBEMODEINFO structure.
;    Otherwise returns 0 for failure.
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
vbeGetModeInfo:
	pushad

	; Save pointer

        mov     [vbeTempVar],eax
        mov     [vbeTempPointer],edx

	; Get the vbeInfo block

        call    vbeDetect
	cmp	eax,0
	je	@@vbeinfo_NOTFOUND		; VBE detect error

	; Allocate low memory buffer for
	; communcation with VBE

	mov	ax, 0100h
	mov	bx, 512/16
	int	031h
	jnc	@@vbeinfol1

	popad
	xor	eax,eax
	ret

@@vbeinfol1:

	; Save the real mode info

	mov	ecx,eax
	and	ecx,0FFFFh
	shl	ecx,4
        mov     [dosmem_address],ecx              ; save linear address
        mov     [dosmem_segment],ax
        mov     [dosmem_selector],dx

	mov	bx,ax				; bx = dosmem_segment

	mov	ebp,offset vbeInfo
	mov	ebp,dosmem_address

	; Get the VBE mode infomation block

        mov     eax,[vbeTempVar]
	mov     edi,offset RMREGS
	mov     rm_eax, 04f01h
	mov	rm_ebx, 0
	mov     rm_ecx, eax
        mov     ax,[dosmem_segment]
	mov	rm_es, ax
	mov     rm_edi, 0

	mov     ax, 0300h			; simulate real mode int
	mov     bl, 010h
	mov	bh, 0
	mov     cx, 0
	int     031h
	jc	@@vbeinfo_NOTFOUND		; DPMI error
        mov     eax,[rm_eax]
	cmp     al,04fh
	jne	@@vbeinfo_NOTFOUND		; vbe not detected

	; Copy block to passed structure

        mov     edi, [vbeTempPointer]
	mov	esi, ebp
	mov	ecx, size MODEINFOBLOCK
	rep	movsb

	; Cleanup

	mov	ax, 0101h			; free dos memory buffer
        mov     dx, [dosmem_selector]
	int	031h
	popad
	mov	eax,1
	ret

@@vbeinfo_NOTFOUND:

	mov	ax, 0101h			; free dos memory buffer
        mov     dx, [dosmem_selector]
	int	031h
	popad
	mov	eax,0
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; vbeOpen
; Setup up a video mode
;
; In:
;   EAX - X res
;   EDX - Y res
;   EBX - Colour depth
;
; Out:
;    EAX - returns pointer to a VESASURFACE structure,
;          or NULL on failure
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

VesaOpen        macro   x,y,c
        mov     eax,x
        mov     edx,y
        mov     ebx,c
        Call    vbeOpen
        endm

vbeOpen:
	pushad

	; Check we're not already open

        cmp     [vbeInit],1
	je	@@vbeopen_NOTFOUND

	; Save requested mode info

        mov     [vbeScreenWidth],eax
        mov     [vbeScreenHeight],edx
        mov     [vbeScreenBits],bl


	; Get the vbeInfo block

        call    vbeDetect
	cmp	eax,0
	je	@@vbeopen_NOTFOUND		; VBE detect error


	; Allocate low memory buffer for
	; communcation with VBE

	mov	ax, 0100h
	mov	bx, 512/16
	int	031h
	jnc	@@vbedetectl1

	popad
	xor	eax,eax
	ret

@@vbedetectl1:


	; Save the real mode info

	mov	ecx,eax
	and	ecx,0FFFFh
	shl	ecx,4
        mov     [dosmem_address],ecx              ; save linear address
        mov     [dosmem_segment],ax
        mov     [dosmem_selector],dx

	mov	bx,ax				; bx = dosmem_segment


	; Scan mode list for the mode

	mov	ebp,offset vbeInfo
        mov     esi,[ebp.VBEINFOBLOCK.VideoModePtr]
        mov     ebp,[dosmem_address]

	xor 	eax,eax

@@vbeopenl1:
	lodsw
	cmp	ax, -1                  	; End of list
	je	@@vbeopen_NOTFOUND

        mov     [vbeMode],ax                      ; Save mode number

	; Get the VBE mode infomation block

	mov     edi,offset RMREGS
	mov     rm_eax, 04f01h
	mov	rm_ebx, 0
	mov     rm_ecx, eax
        mov     ax,[dosmem_segment]
	mov	rm_es, ax
	mov     rm_edi, 0

	mov     ax, 0300h			; simulate real mode int
	mov     bl, 010h
	mov	bh, 0
	mov     cx, 0
	int     031h
	jc	@@vbeopen_NOTFOUND		; DPMI error
	mov	eax,rm_eax
	cmp     al,04fh
	jne	@@vbeopen_NOTFOUND		; vbe not detected

	; Check this is the mode we want

        movzx   eax, [ebp.MODEINFOBLOCK.XResolution]
        cmp     eax, [vbeScreenWidth]
	jnz	@@vbeopenl1
        movzx   eax, [ebp.MODEINFOBLOCK.YResolution]
        cmp     eax, [vbeScreenHeight]
	jnz	@@vbeopenl1
        mov     al, [ebp.MODEINFOBLOCK.BitsPerPixel]
        cmp     al, [vbeScreenBits]
	jnz	@@vbeopenl1

	; This is our mode, try setting it with LFB on

	mov	ax, 04f02h
        mov     bx, [vbeMode]
	or	bx, 4000h			; ask for LFB
	int	010h
	cmp	ah, 0
	jnz	@@vbeopen_NOLFB

	; Map LFB memory

        mov     ebx, [ebp.MODEINFOBLOCK.PhysBasePtr]
	mov     ecx, ebx
	shr     ebx, 16                 ; BX:CX = physical base ptr

	mov     esi, (4096*1024)-1	; 4Meg
	mov     edi, esi
	shr     esi, 16                 ; SI:DI = region size

	mov     ax, 0800h
	int     031h
	jc	@@vbeopen_NOTFOUND	; DPMI error

	shl     ebx, 16
	mov     bx, cx
        mov     [vbeLfbPtr], ebx          ; Save LFB pointer

	jmp     @@vbeopen_OK


	; No LFB available

@@vbeopen_NOLFB:

	;
	;
	; We should set up a virtual linear fraem buffer
	; here, but I'll do that later.
	;
	;
	jmp	@@vbeopen_NOTFOUND


@@vbeopen_OK:

	; Set scan line width to be sure

        mov     ecx, [vbeScreenWidth]
	mov     eax, 04f06h
	xor     ebx, ebx
	xor     edx, edx
	int     010h

	; Set init

	mov	vbeInit,1

	; build the vbe surface structure

	mov	edi,offset vbeSurface

	xor	eax,eax
        mov     ax,[vbeMode]
        mov     [edi.VBESURFACE.mode],eax

        mov     eax,[vbeScreenWidth]
        mov     [edi.VBESURFACE.width2],eax
        mov     eax,[vbeScreenHeight]
        mov     [edi.VBESURFACE.height],eax

        movzx   eax,[vbeScreenBits]
        mov     [edi.VBESURFACE.bits],eax
	shr	eax,3
        mov     [edi.VBESURFACE.depth],eax

        mov     eax,[vbeLfbPtr]
        mov     [edi.VBESURFACE.lfb],eax

	mov	ax, 0101h			; free dos memory buffer
        mov     dx, [dosmem_selector]
	int	031h
	popad
	mov	eax,offset vbeSurface
	ret


@@vbeopen_NOTFOUND:

	mov	ax, 0101h			; free dos memory buffer
        mov     dx, [dosmem_selector]
	int	031h
	popad
	mov	eax,0
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; vbeClose
; Close the driver
;
; In:
;   EAX - VBESURFACE
;
; Out:
;   NONE
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
vbeClose:
	pushad

	; Check we're open

        cmp     [vbeInit],0
	je	@@vbeclose_END


	;
	; We should check for a virtual LFB and
	; get rid of it
	;


	; Release LFB mapping

	mov     ax, 0801h
        mov     ebx, [vbeLfbPtr]
	mov     ecx, ebx
	shr     ebx, 16
	int     031h            ; release mapping


	; Reset video mode

	mov	eax,03h
	int	010h

	mov	vbeInit,0

@@vbeclose_END:
	popad
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; vbeSetScanWidth
; Set pixels per scan line of the display
;
; In:
;   EAX - Pixels per scan line
;
; Out:
;    Returns 1, new pixels per scan line set.
;    Otherwise returns 0 for failure.
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
vbeSetScanWidth:
	push ebx ecx edx
	mov	ecx,eax

	mov     eax, 04f06h
	xor     ebx, ebx
	xor     edx, edx
	int     010h

	cmp     al,04fh
	jne	@@vbesetscan_NOTFOUND		; vbe not detected

	mov	eax,1
	pop edx ecx ebx
	ret

@@vbesetscan_NOTFOUND:
	mov	eax,0
	pop edx ecx ebx
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; vbeGetScanWidth
; Get number of pixels per scan line
;
; In:
;   NONE
;
; Out:
;    Returns pixels per scan line, or 0 for failure.
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
vbeGetScanWidth:
	push ebx ecx edx

	mov     eax, 04f06h
	mov     ebx, 1
	xor	ecx, ecx
	int     010h

	cmp     al,04fh
	jne	@@vbegetline_NOTFOUND		; vbe not detected

	mov	eax,ecx
	pop edx ecx ebx
	ret

@@vbegetline_NOTFOUND:
	mov	eax,0
	pop edx ecx ebx
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; vbeSetDisplayStart
; Set new display start position
; Does NOT wait for vr.
;
; In:
;   EAX - new x position
;   EDX - new y position
;
; Out:
;    Returns 1, new display position set.
;    Otherwise returns 0 for failure.
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
vbeSetDisplayStart:
	push ebx ecx edx
	mov	ecx,eax

	mov     eax, 04f07h
	xor     ebx, ebx
	int     010h

	cmp     al,04fh
	jne	@@vbesetdisp_NOTFOUND		; vbe not detected

	mov	eax,1
	pop edx ecx ebx
	ret

@@vbesetdisp_NOTFOUND:
	mov	eax,0
	pop edx ecx ebx
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; vbeGetDisplayStart
; Get the display start position
;
; In:
;   EAX -> address of where to put x position (1 DWORD)
;   EDX -> address of where to put y position (1 DWORD)
;
; Out:
;    Returns 1, if x and y data was set.
;    Otherwise returns 0 for failure.
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
vbeGetDisplayStart:
	push ebx ecx edx
	push eax edx

	mov     eax, 04f07h
	mov     ebx, 1
	xor	edx,edx
	xor	ecx,ecx
	int     010h

	cmp     al,04fh
	jne	@@vbegetdisp_NOTFOUND		; vbe not detected

	pop eax					; get Y address
        mov     [dword ptr eax],edx
	pop edx					; get X address
        mov     [dword ptr edx],ecx

	mov	eax,1
	pop edx ecx ebx
	ret

@@vbegetdisp_NOTFOUND:
	pop edx eax
	mov	eax,0
	pop edx ecx ebx
	ret

        .data
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; DPMI Real mode register structure
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

RMREGS	label	dword
                rm_edi          dd      0
                rm_esi          dd      0
                rm_ebp          dd      0
                rm_esp          dd      0
                rm_ebx          dd      0
                rm_edx          dd      0
                rm_ecx          dd      0
                rm_eax          dd      0

                rm_flags        dw      0
                rm_es           dw      0
                rm_ds           dw      0
                rm_fs           dw      0
                rm_gs           dw      0
                rm_ip           dw      0
                rm_cs           dw      0
                rm_sp           dw      0
                rm_ss           dw      0
                rm_spare_data   dd      20 dup(0)

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; VBE Infomation Block
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
VBEINFOBLOCK    STRUC


VbeSignature        db 'VESA'        ; VBE Signature
VbeVersion          dw 0200h         ; VBE Version
OemStringPtr        dd 0             ; Pointer to OEM String
Capabilities        db 4 dup (0)     ; Capabilities of graphics cont.
VideoModePtr        dd 0             ; Pointer to Video Mode List
TotalMemory         dw 0             ; Number of 64kb memory blocks

	; Added for VBE 2.0

OemSoftwareRev      dw 0             ; VBE implementation Software revision
OemVendorNamePtr    dd 0             ; Pointer to Vendor Name String
OemProductNamePtr   dd 0             ; Pointer to Product Name String
OemProductRevPtr    dd 0             ; Pointer to Product Revision String
_Reserved_          db 222 dup (0)   ; Reserved for VBE implementation

	; scratch area

OemData             db   256 dup (0) ; Data Area for OEM Strings

VBEINFOBLOCK	ENDS


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; VBE Mode Infomation Block
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
MODEINFOBLOCK   STRUC

	; Mandatory information for all VBE revisions:

ModeAttributes      dw 0        ; mode attributes
WinAAttributes      db 0        ; window A attributes
WinBAttributes      db 0        ; window B attributes
WinGranularity      dw 0        ; window granularity
WinSize             dw 0        ; window size
WinASegment         dw 0        ; window A start segment
WinBSegment         dw 0        ; window B start segment
WinFuncPtr          dd 0        ; pointer to window function
BytesPerScanLine    dw 0        ; bytes per scan line

	; Mandatory information for VBE 1.2 and above:

XResolution         dw 0        ; horizontal resolution in pixels or chars
YResolution         dw 0        ; vertical resolution in pixels or chars
XCharSize           db 0        ; character cell width in pixels
YCharSize           db 0        ; character cell height in pixels
NumberOfPlanes      db 0        ; number of memory planes
BitsPerPixel        db 0        ; bits per pixel
NumberOfBanks       db 0        ; number of banks
MemoryModel         db 0        ; memory model type
BankSize            db 0        ; bank size in KB
NumberOfImagePages  db 0        ; number of images
_Reserved           db 0        ; reserved for page function

	; Direct Color fields (required for direct/6 and YUV/7 memory models)

RedMaskSize         db 0        ; size of direct color red mask in bits
RedFieldPosition    db 0        ; bit position of lsb of red mask
GreenMaskSize       db 0        ; size of direct color green mask in bits
GreenFieldPosition  db 0        ; bit position of lsb of green mask
BlueMaskSize        db 0        ; size of direct color blue mask in bits
BlueFieldPosition   db 0        ; bit position of lsb of blue mask
RsvdMaskSize        db 0        ; size of direct color reserved mask in bits
RsvdFieldPosition   db 0        ; bit position of lsb of reserved mask
DirectColorModeInfo db 0        ; direct color mode attributes

	; Mandatory information for VBE 2.0 and above:

PhysBasePtr         dd 0        ; physical address for flat frame buffer
OffScreenMemOffset  dd 0        ; pointer to start of off screen memory
OffScreenMemSize    dw 0        ; amount of off screen memory in 1k units
__Reserved          db 206 dup (0)

MODEINFOBLOCK	ENDS


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; VBE SURFACE
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
VBESURFACE2      STRUC

mode                    dd      0
width2                  dd      0
height                  dd      0
bits                    dd      0
depth                   dd      0
lfb                     dd      0

VBESURFACE2      ENDS


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; DATA
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
ALIGN 4
vbeInfo         VBEINFOBLOCK    <0>

ALIGN 4
vbeSurface      VBESURFACE2      <0>

ALIGN 4

vbeInit		dd	0

vbeMode         dw      0,0
vbeScreenWidth  dd      0
vbeScreenHeight dd      0
vbeScreenBits   db      0,0,0,0
vbeLfbPtr       dd      0

vbeTempVar      dd      0
vbeTempPointer  dd      0

dosmem_segment  dw      0,0
dosmem_selector dw      0,0
dosmem_address  dd      0

localBuf	label	dword
                db      1024 dup(0)
localBufEnd	label	dword

vortexStr	db	'VORTEX'



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ends

        .code

