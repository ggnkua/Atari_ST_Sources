;**************************************************
;* Bios  
;*
;*	This part emulates the Bios, Gemdos and XBios
;*	calls.
;**************************************************
Bios:       
                mov     ebx,d [R_A7]    ; Get SP
                lea     edx,[ebp+ebx]
                xor     ebx,ebx
                mov     bx,w [edx]      ; Bios Function
                cmp     bx,11
                jle     MyBios
SystemBios:     lea     ebx,trapcont    ; let emulator do it
                jmp     ebx             ; PRESERVE EAX!
MyBios:         jmp     d [BiosTab+ebx*4]
ReturnTrap:     lea     ebx,trapend
                jmp     ebx
BiosTab:        dd      SystemBios, Bios1, Bios2, SystemBios, Bios4
                dd      SystemBios, SystemBios, SystemBios, Bios8
                dd      SystemBios, Bios10, Bios11
;
;******Bios 1: Bconstat
Bios1:
;                jmp     SystemBios
                pushad
                mov     ax,0b00h
                int     21h
                movsx   eax,al
                mov     d [R_D0],eax
                popad
                jmp     ReturnTrap
Bios2:                                  ; ********* Bconin
;                jmp     SystemBios
                pushad
                xor     eax,eax
                int     16h

                cmp     al,'1'
                jnz     short @@nom
                mov     d mouse,1
@@nom:
                shl     eax,8           ; SCANCODE
                shr     ax,8            ; ASCII
                mov     d [R_D0],eax

;                test    b [ebp+484h],4  ; Shift?
;                jz      short @@noShift
                mov     ah,2
                int     16h             ; Get ShiftState
                mov     ah,al
                and     al,15
                shr     ah,2
                and     ah,3
                or      al,ah
                mov     b [R_D0+3],al
@@noShift:
                popad
                jmp     ReturnTrap
Bios3:
                cmp     w 2[edx],2      ; screen?
                jz      SystemBios
                jmp     ReturnTrap
Bios4:
                pushad
                setcolor 0,0,200,0
                popad

                pushad
                cmp     w [ebx+12],0    ; drive A?
                jne     @@exit
                xor     eax,eax
                mov     ax,w [ebx+10]   ; track
@@skip:         shl     eax,9           ; *512 bytes
                lea     esi,[DISK+eax]

                mov     edi,d [ebx+4]   ; buffer
                rol     edi,16
                lea     edi,[ebp+edi]

                xor     ecx,ecx
                mov     cx,w [ebx+8]    ; count
                shl     ecx,8           ; *512 bytes
@@copy:         mov     ax,[esi]
                rol     ax,8
                mov     [edi],ax
                add     esi,2
                add     edi,2
                dec     ecx
                jne     @@copy

@@exit:         popad

                popad
                add     esp,4
                ret

                mov     d [R_D0],0     ; Temporary Drive Error
                jmp     ReturnTrap
Bios8:
                mov     d [R_D0],-1     ; kan worden verzonden
                jmp     ReturnTrap
Bios10:
                mov     d [R_D0],15     ; geen drives beschikbaar
                jmp     ReturnTrap

Bios11:         pushad
                mov     ah,2
                int     16h             ; Get ShiftState
                mov     ah,al
                and     al,15
                shr     ah,2
                or      al,ah
                and     eax,3fh
                mov     d [R_D0],eax    ; Kbshift()
                popad
                jmp     ReturnTrap

;**************************************************
;* Xbios
;**************************************************
Xbios:      
                mov     ebx,d [R_A7]    ; Get SP
                lea     edx,[ebp+ebx]
                xor     ebx,ebx
                mov     bx,w [edx]      ; XBios Function
                cmp     bx,50
                jle     MyXBios
                lea     ebx,trapcont    ; let emulator do it
                jmp     ebx             ; PRESERVE EAX!
MyXBios:        jmp     d [XBiosTab+ebx*4]
XBiosTab:
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;0
        dd SystemBios,SystemBios,SystemBios,Xbios8,SystemBios ;5
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;10
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;15
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;20
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;25
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;30
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;35
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;40
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;45
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;50

Xbios8:
                pushad
                setcolor 0,0,200,0
                popad


                mov     d [R_D0],0     ; Temporary Drive Error
                jmp     ReturnTrap


;**************************************************
;* GemDos
;**************************************************
GemDos:     
                mov     ebx,d [R_A7]    ; Get SP
                lea     edx,[ebp+ebx]
                xor     ebx,ebx
                mov     bx,w [edx]      ; XBios Function
                cmp     bx,80
                jle     MyGemDos
                lea     ebx,trapcont    ; let emulator do it
                jmp     ebx             ; PRESERVE EAX!
MyGemDos:       jmp     d [GemDosTab+ebx*4]
GemDosTab:
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;0
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;5
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;10
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;15
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;20
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;25
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;30
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;35
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;40
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;45
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;50
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;55
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;60
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;65
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;70
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;75
        dd SystemBios,SystemBios,SystemBios,SystemBios,SystemBios ;80

;**************************************************
;* VDI/AES
;**************************************************
VDI_AES: ;       cmp     w [R_D0],200
         ;       je      AES
         ;       cmp     w [R_D0],115
         ;       je      VDI

                lea     ebx,trapcont
                jmp     ebx
