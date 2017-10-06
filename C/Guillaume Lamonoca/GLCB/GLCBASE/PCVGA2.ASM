;pcvga2.asm  (partie assembleur du module de base PC VGA)
;
;Guillaume LAMONOCA
;Supelec (94)
;
;a assembler avec la commande "tasm /mx pcvga2.asm"

dosseg
.model large

.const

MAP_MASK        = 2
READ_MAP_SELECT = 4

donnee	equ [bp]

adr		equ [bp]
ecran	equ [bp+4]
larg	equ [bp+8]
haut	equ [bp+10]
recal	equ [bp+12]
recal2	equ [bp+14]


.data

extrn C addcnt:word
extrn C cntper:word
extrn C period:word
extrn C dacport:word
extrn C sndblast:word
extrn C voldigit:word
extrn C offstart:word
extrn C segdigit:word
extrn C offdigit:word
extrn C lendigit:word
extrn C repdigit:word
extrn C cntdigit:word

extrn C vblclock:word
extrn C mousex:word
extrn C mousey:word
extrn C mousek:word
extrn C msebuffer:word
extrn C statek:word
extrn C bufferflag:byte
extrn C kbufferflag:byte
extrn C nbrbuffer:word
extrn C msebufptr:word
extrn C keymap:byte
extrn C codekey:byte
extrn C keybuffer:byte
extrn C keybufptr:word
extrn C keybufend:word
extrn C keybufnbr:word

.code

public C sendinit
public C inithp
public C itmouse
public C killmse
public C initspl
public C freqspl
public C killspl
public C initvbl
public C killvbl
public C initkbd
public C killkbd
public C putplane
public C getplane
public C putsplane
public C getsplane

extended dw 0

adroldvbl equ this dword
offoldvbl dw 0
segoldvbl dw 0

adroldsmpl equ this dword
offoldsmpl dw 0
segoldsmpl dw 0

adroldkbd equ this dword
offoldkbd dw 0
segoldkbd dw 0









; initialise haut parleur interne du PC pour sortir des samples!!!
; on utilise un signal carre HF inaudible et on modifie son rapport cyclique
inithp		proc
			push ax

			in al,61h
			or al,03h
			out 61h,al
			mov al,0b2h
			out 43h,al
			xor al,al
			out 42h,al
			out 42h,al
			mov al,90h
			out 43h,al

			;modification du rapport cyclique:
			;mov al,octet de sample (repos=128)
			;or al,1
			;out 42h,al

			pop ax
			ret
inithp		endp




; se declenche a frequence fixe (utilisee pour samples)
; en fait il y a toujours une interruption qui s'execute a 18.3 hz
; (gere le moteur des drives et l'horloge systeme -biostime()-)
; interruption int 08h (irq0) vecteur a l'adresse 0000:0020
smpl_it		proc
			push es
			push ds
			push ax
			push dx
			push bx
			push cx

			mov ax,@data
			mov ds,ax

			mov ax,segdigit

			or ax,ax
			jnz go_on
			jmp end_spl

go_on:		mov es,ax
			mov bx,offdigit
			mov ah,es:[bx]

			;mov cx,voldigit
			;or cx,cx
			;jz l15
lvol:
			;sar ah,1
			;loop lvol
l15:
			add ah,128      ;on repasse en repos a 128

			mov dx,dacport

			test sndblast,1
			jnz sb_dac

other_dac:
			mov al,ah
			out dx,al
			jmp fin_spl

sb_dac:

wsp1:		in al,dx
			or al,al
			js wsp1
			mov al,10h
			out dx,al
wsp2:		in al,dx
			or al,al
			js wsp2
			mov al,ah
			out dx,al

fin_spl:
			add offdigit,1
			sub cntdigit,1
			jnz end_spl

			mov ax,repdigit
			or ax,ax
			js spl_cont

			sub repdigit,1
			jnz spl_cont

			mov segdigit,0


			test sndblast,1
			jnz sb_dac2

other_dac2:
			mov al,128
			out dx,al
			jmp fin_spl2

sb_dac2:
wsp12:		in al,dx
			or al,al
			js wsp12
			mov al,10h
			out dx,al
wsp22:		in al,dx
			or al,al
			js wsp22
			mov al,128
			out dx,al

fin_spl2:

			mov addcnt,0ffffh
			mov cntper,0

			mov al,0ffh
			mov dx,40h
			out dx,al
			nop
			nop
			out dx,al

			jmp akit

spl_cont:
			mov ax,offstart
			mov offdigit,ax
			mov ax,lendigit
			mov cntdigit,ax

end_spl:
			mov ax,addcnt
			add cntper,ax
			jc old_it
akit:
			mov dx,20h
			mov al,20h
			out dx,al

			pop cx
			pop bx
			pop dx
			pop ax
			pop ds
			pop es
			iret

old_it:
			pop cx
			pop bx
			pop dx
			pop ax
			pop ds
			pop es

			jmp adroldsmpl  ;on saute a l'ancienne it pour gerer le
							;moteur des drives (a environ 18.3 hz)
smpl_it		endp



; on detourne 0000:0020 et on change la frequence de l'irq0
; periode=1200000/frequence
initspl	proc
		push ds
		push dx
		push bx

		mov ax,0
		mov ds,ax
		mov bx,20h
		mov ax,[bx]
		mov offoldsmpl,ax
		mov ax,[bx+2]
		mov segoldsmpl,ax

		cli

		mov ax,offset smpl_it
		mov [bx],ax
		mov [bx+2],cs

		sti

		pop bx
		pop dx
		pop ds
		ret


initspl	endp


freqspl proc
		push ds
		push dx
		push bx

		mov ax,@data
		mov ds,ax
		mov ax,period
		mov addcnt,ax
		mov cntper,0

		mov dx,40h
		out dx,al
		nop
		mov al,ah
		out dx,al

		pop bx
		pop dx
		pop ds
		ret

freqspl endp

killspl	proc
		push ds
		push dx
		push bx

		mov ax,0
		mov ds,ax
		mov bx,20h

		cli

		mov ax,offoldsmpl
		mov [bx],ax
		mov ax,segoldsmpl
		mov [bx+2],ax

		mov ax,0ffffh ;periode pour 18.3 hz
		mov dx,40h
		out dx,al
		nop
		mov al,ah
		out dx,al


		sti

		pop bx
		pop dx
		pop ds
		ret

killspl	endp









; it keyboard
; interruption int 09h (irq1) vecteur a l'adresse 0000:0024
kbd_it		proc
			push es
			push ds
			push ax
			push dx
			push bx
			push cx

			mov ax,@data
			mov ds,ax

			mov dx,60h
			in al,dx

			cmp al,0e0h
			jne nek

			mov extended,1
			jmp end_kit

nek:
			or al,al
			js ku
kd:
			cmp extended,1
			jne nek2
			add al,128
nek2:
			mov extended,0
			lea bx,codekey
			xlat

			or al,al
			jz end_kit

			lea bx,keymap
			mov ah,0
			add bx,ax

			cmp byte ptr [bx],1
			je end_kit

			mov byte ptr [bx],1

			test kbufferflag,1
			jz end_kit

			cmp keybufnbr,256
			jz end_kit

			lea bx,keybuffer
			mov cx,keybufptr
			add bx,cx

			mov [bx],al

			inc cx
			and cx,255
			mov keybufptr,cx

			add keybufnbr,1

			jmp end_kit

ku:
			cmp extended,1
			je ek
			and al,127
ek:
			mov extended,0
			lea bx,codekey
			xlat

			or al,al
			jz end_kit

			lea bx,keymap
			mov ah,0
			add bx,ax
			mov byte ptr [bx],0


end_kit:
			mov dx,20h
			mov al,20h
			out dx,al

			pop cx
			pop bx
			pop dx
			pop ax
			pop ds
			pop es
			iret

kbd_it		endp


cbreak	proc
		iret
cbreak	endp

cerror	proc
		sti
		push cx
		mov cx,64
t1:		mov ax,0ffffh
t2:		dec ax
		jne t2
		loop t1
		mov al,01h
		pop cx
		iret
cerror	endp

; on detourne 0000:0024
initkbd	proc
		push ds
		push dx
		push bx

		push cs
		pop ds
		mov ax,2523h
		mov dx,offset cbreak
		int 21h

		mov al,24h
		mov dx,offset cerror
		int 21h

		mov ax,0
		mov ds,ax
		mov bx,24h
		mov ax,[bx]
		mov offoldkbd,ax
		mov ax,[bx+2]
		mov segoldkbd,ax

		cli

		mov ax,offset kbd_it
		mov [bx],ax
		mov [bx+2],cs

		sti

		pop bx
		pop dx
		pop ds
		ret


initkbd	endp



killkbd	proc
		push ds
		push dx
		push bx

		mov ax,0
		mov ds,ax
		mov bx,24h

		cli

		mov ax,offoldkbd
		mov [bx],ax
		mov ax,segoldkbd
		mov [bx+2],ax

		sti

		pop bx
		pop dx
		pop ds
		ret

killkbd	endp








; se declenche a chaque balayage ecran (vbl) (marche pas sur tous les pc!)
; interruption int 0Ah (irq2) vecteur a l'adresse 0000:0028
vbl_it  proc
		push ds
		push ax
		push dx

		mov ax,@data
		mov ds,ax

		mov dx,3c2h
		in al,dx
		test al,80h
		jnz vbl

		pop dx
		pop ax
		pop ds

		jmp adroldvbl

vbl:

		add vblclock,1

		mov dx,3d4h
		mov al,11h
		out dx,al
		inc dx
		in al,dx
		and al,0efh
		out dx,al
		jmp short $+2
		or al,10h
		out dx,al
		jmp short $+2
		mov dx,20h
		mov al,20h
		out dx,al

		pop dx
		pop ax
		pop ds
		iret

vbl_it	endp


initvbl	proc
		push ds
		push dx
		push bx

		mov ax,0
		mov ds,ax
		mov bx,28h
		mov ax,[bx]
		mov offoldvbl,ax
		mov ax,[bx+2]
		mov segoldvbl,ax

		cli

		mov ax,offset vbl_it
		mov [bx],ax
		mov [bx+2],cs

		mov dx,3d4h
		mov al,11h
		out dx,al
		inc dx
		in al,dx
		and al,0cfh
		out dx,al
		jmp short $+2
		or al,10h
		out dx,al
		mov dx,20h
		mov al,20h
		out dx,al

		sti

		pop bx
		pop dx
		pop ds
		ret


initvbl	endp

killvbl	proc
		push ds
		push dx
		push bx

		mov ax,0
		mov ds,ax
		mov bx,28h

		cli

		mov ax,offoldvbl
		mov [bx],ax
		mov ax,segoldvbl
		mov [bx+2],ax

		mov dx,3d5h
		in al,dx
		or al,20h
		out dx,al

		sti

		pop bx
		pop dx
		pop ds
		ret


killvbl	endp





; envoi d'une commande a la soundblaster
sendinit	proc
			push bp
			push ax
			push dx

			mov bp,sp
			add bp,10

			mov ax,[bp]
			mov ah,al

			mov dx,dacport
wi1:		in al,dx
			or al,al
			js wi1
			mov al,ah
			out dx,al

			pop dx
			pop ax
			pop bp
			ret
sendinit	endp




; se declenche a chaque evenement souris (deplacements+boutons)
mse_it  	proc
			push ds
			push ax
			mov ax,@data
			mov ds,ax

			sar cx,1
			mov mousex,cx
			mov mousey,dx

			mov ax,bx
			and ax,3
			mov mousek,ax

			mov ax,statek
			xor ax,mousek
			jz end_it

			ror al,1
			ror al,1
			or ax,mousek

			test bufferflag,1
			jz end_it

			cmp nbrbuffer,32
			jz end_it

			lea bx,msebuffer
			mov cx,msebufptr
			add bx,cx

			mov [bx],ax
			mov ax,mousex
			mov [bx+2],ax
			mov ax,mousey
			mov [bx+4],ax
			mov ax,vblclock
			mov [bx+6],ax

			add cx,8
			and cx,255
			mov msebufptr,cx

			add nbrbuffer,1

end_it:

			mov ax,mousek
			and ax,3
			mov statek,ax

			pop ax
			pop ds
			ret
mse_it		endp

itmouse		proc
			push bp
			push es
			push si
			push di

			push bx
			push cx
			push dx

			mov cx,1fh
			push cs
			pop es
			lea dx,mse_it
			mov ax,12
			int 33h

			pop dx
			pop cx
			pop bx

			pop di
			pop si
			pop es
			pop bp
			ret
itmouse		endp

killmse 	proc
			push bp
			push es
			push si
			push di

			push bx
			push cx
			push dx

			mov cx,0
			mov ax,0
			mov es,ax
			mov dx,0
			mov ax,12
			int 33h

			pop dx
			pop cx
			pop bx

			pop di
			pop si
			pop es
			pop bp
			ret
killmse		endp






putplane	proc

			push ax
			push bx
			push dx
			push cx
			push ds
			push es
			push bp
			push di
			push si

			mov bp,sp
			add bp,22

			les di,ecran
			lds	si,adr

			cld

			mov bx,recal
			mov dx,recal2
			mov ax,haut
			mov ah,al
pp1:
			mov cx,larg
			rep movsb
			add si,bx
			add di,dx
			dec ah
			jne pp1


			pop si
			pop di
			pop bp
			pop es
			pop ds
			pop cx
			pop dx
			pop bx
			pop ax

			ret
putplane	endp


getplane	proc

			push ax
			push bx
			push dx
			push cx
			push ds
			push es
			push bp
			push di
			push si

			mov bp,sp
			add bp,22

			les di,adr
			lds	si,ecran

			cld

			mov dx,recal
			mov bx,recal2
			mov ax,haut
			mov ah,al
gp1:
			mov cx,larg
			rep movsb
			add si,bx
			add di,dx
			dec ah
			jne gp1


			pop si
			pop di
			pop bp
			pop es
			pop ds
			pop cx
			pop dx
			pop bx
			pop ax

			ret
getplane	endp



putsplane	proc

			push ax
			push bx
			push dx
			push cx
			push ds
			push es
			push bp
			push di
			push si

			mov bp,sp
			add bp,22

			les di,ecran
			lds	si,adr

			cld

			mov bx,recal
			mov dx,recal2
			mov ax,haut
			mov ah,al
ps1:
			mov cx,larg
ps2:
			lodsb
			cmp al,255
			jne ps3

			inc di
			loop ps2
			jmp short ps4

ps3:		stosb
			loop ps2

ps4:		add si,bx
			add di,dx
			dec ah
			jne ps1

			pop si
			pop di
			pop bp
			pop es
			pop ds
			pop cx
			pop dx
			pop bx
			pop ax

			ret
putsplane	endp

getsplane	proc

			push ax
			push bx
			push dx
			push cx
			push ds
			push es
			push bp
			push di
			push si

			mov bp,sp
			add bp,22

			les di,adr
			lds	si,ecran

			cld

			mov dx,recal
			mov bx,recal2
			mov ax,haut
			mov ah,al
gs1:
			mov cx,larg
gs2:
			lodsb
			cmp al,0
			je gs3

			inc di
			loop gs2
			jmp short gs4
gs3:
			mov al,255
			stosb
			loop gs2
gs4:
			add si,bx
			add di,dx
			dec ah
			jne gs1

			pop si
			pop di
			pop bp
			pop es
			pop ds
			pop cx
			pop dx
			pop bx
			pop ax

			ret
getsplane	endp



end
