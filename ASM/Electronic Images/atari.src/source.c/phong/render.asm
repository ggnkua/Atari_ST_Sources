;       
;
;

.386


_TEXT segment para public use32 'CODE'

assume cs:_TEXT, ds:_DATA

PUBLIC interpolate_

;
;
;

interpolate_ 	proc near 
		sal	ebx,16			
		add	edi,(64*4)
		test	ecx,ecx			
		jle	noxl			
		sal	eax,16			
		sub	eax,ebx			
		mov	edx,eax			
		sar	edx,31			
		idiv 	ecx			
		sal	ecx,3
		lea	edi,[ecx*8+edi]
		neg	ecx
		add	ecx,offset ere3+(320*8)
		jmp	ecx
ere3:	
i		=	-324*64	
		rept 	320	
		mov	(i)[edi],ebx
		add	ebx,eax			
i		=	i+64
		endm
noxl:		mov	(i)[edi],ebx		
		ret
interpolate_	endp

;
;
;

PUBLIC rend_gourpolyz_

rend_gourpolyz_	proc near 
		push	ebp
		sub	ebx,eax			; dy 
		mov	word ptr [s_end],bx	; store dy
		mov	ebp,eax
		add	eax,eax			; dy * 2;
		add	eax, OFFSET _z_buffer  
		mov	dword ptr [zi_ptr],eax	; point to zbuffer;
		sal	ebp,6
		add	ebp,OFFSET _scan
yloopz:		movsx	esi,word ptr 2[ebp]
		movsx	ecx,word ptr 22[ebp]
		sub	ecx,esi			; dx
		jl	iszz
		inc 	ecx
		mov	ax,WORD ptr 62[ebp]	
		movsx   edi,WORD ptr 60[ebp]
		lea	esi,[esi*4+esi]		
		add	edi,dword ptr [_screen_ptr]	
		sal	esi,4		
		mov	dx,03c4h		
		add	edi,esi		
		out	dx,ax	
		sal	esi,3			
		add	esi,[zi_ptr]		 
		mov	eax,28[ebp]		
		sub	eax,8[ebp]		
		mov	edx,eax			
		sar	edx,31			
		idiv	ecx			
		sar	eax,8			
		mov	[daI],ax		
		mov	eax,24[ebp]		
		sub	eax,4[ebp]		
		mov	edx,eax			
		sar	edx,31			
		idiv	ecx			
		ror	eax,16			
		mov	edx,4[ebp]		
		ror	edx,16			
		mov	ebx,8[ebp]		
		sar	ebx,8			
xloopz:		cmp	[esi],dx		
		jle	nobzz			
		mov	[esi],dx		
		mov	[edi],bh		
nobzz:		add	edx,eax			
		adc	dx,0			
		add	esi,640			
		add	bx,[daI]
		add	edi,80			
		dec	ecx			
		jnz	xloopz	
iszz:		add	dword ptr [zi_ptr],2		 
		add	ebp,64
		dec 	word ptr [s_end]
		jge	yloopz
		pop	ebp
		ret
rend_gourpolyz_ endp 

;
;	Render a gouraud polygon ( MODE X)
;

PUBLIC rend_gourpoly_

rend_gourpoly_ 	proc near 
		push	ebp
		sub	ebx,eax			; dy 
		mov	ebp,eax
		sal	ebp,6
		add	ebp,OFFSET _scan
yloop:	 	movsx	esi,word ptr 22[ebp]
		lea	edx,[esi*4+esi]		
		movsx	ecx,word ptr 2[ebp]
		sal	edx,4		
		movsx   edi,WORD ptr 60[ebp]
		add	edi,edx		
		mov	ax,WORD ptr 62[ebp]	
		mov	dx,03c4h		
		add	edi,dword ptr [_screen_ptr]	
		out	dx,ax	
		mov	dx,8+2[ebp]		
		sub	ecx,esi			; -dx
		jge	isz	
		mov	edx,8[ebp]		
		sub	edx,28[ebp]		
		mov	eax,edx			
		sar	edx,31			
		idiv	ecx
		mov	edx,8[ebp]		
		ror	eax,16
		ror	edx,16
		sal	ecx,3
		add	ecx,offset ere+(200*8)
		clc
		jmp 	ecx
ere:		
i		= (-200*80) 
		REPT	200
		mov	( (i))[edi],dl
		adc 	edx,eax
i		= i + 80
		ENDM
isz:		mov	(i)[edi],dl
		add	ebp,64
		dec 	bx	
		jge	yloop
		pop	ebp
		ret
rend_gourpoly_ endp 

;
;	Render a polygon ( MODE X)
;

PUBLIC rend_poly_

rend_poly_ 	proc near 
		push	ebp
		sub	ebx,eax			; dy 
		mov	ebp,eax
		sal	ebp,6
		add	ebp,OFFSET _scan
p_yloop:	movsx	ecx,word ptr 2[ebp]
		dec	ecx			; (-1)
		movsx	edx,word ptr 22[ebp]
		sub	ecx,edx			; -dx
		dec	ecx	
		jge	p_isz
		mov	ax,WORD ptr 62[ebp]	
		lea	edx,[edx*4+edx]		
		movsx   edi,WORD ptr 60[ebp]
		sal	edx,4		
		add	edi,dword ptr [_screen_ptr]	
		add	edi,edx
		mov	dx,03c4h		
		out	dx,ax	
		imul 	ecx,6
		add	ecx,offset p_ere+(200*6)
		jmp 	ecx
p_ere:		
i		= (-200*80) 
		REPT	200
		mov	(i)[edi],bl
i		= i + 80
		ENDM
		mov	[edi],bl
p_isz:		add	ebp,64
		dec 	bx	
		jge	p_yloop
		pop	ebp
		ret
rend_poly_ 	endp 
_TEXT           ends
                
_DATA segment para public use32 'DATA'
save_bp		dd 0
zi_ptr		dd 0
s_end		dw 0
daI		dw 0
extrn 		_screen_ptr : byte 
extrn 		_scan : dword
extrn 		_z_buffer : word

_DATA           ends
                
                end
