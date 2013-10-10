                .486p
                .Model Flat
                .Stack 1000h
                .Code
                include std.inc

;***********************************************
;*
;*	M68030 DisAssembler v0.95, (c) Frans van Nispen (xlr8@tref.nl)
;*
;*	This file is part of the Tos040 project.
;*
;* In  : esi = Adres (Word Tweaked)
;*       edi = OutputString adres
;* Out : edx = Opcode length
;
; Things to do:
;
; d8(PC,An,Xn) d8 Adjust 'offset' to make it show the address it points to, as
;		now it just shows the exact value it contains which is a releative offset.
;
; RegisterList in MoveM
; BFxxxx
; MMU commando's
;

                public  d68030

d68030:         pushad
;           lea     esi,TestOpcodes ; For testing only
;           mov     ebp,esi         ; For testing only

                mov     d [D68adres],esi        ; disassemble adres

                mov     ax,w [esi]              ; ax=word!
                add     esi,2

                mov     bl,ah
                shr     bl,2                    ; get 1st nibble
                and     ebx,3Ch                 ; 1st nibble*4
                jmp     d [DisTab+ebx]

op_0:           test    ah,1
                jnz     op_0_odd
                call    getSize
                cmp     bl,3                    ; 11
                jz      op_0_extend
                mov     bl,ah
                and     ebx,14
                jmp     d [op_0_tab+ebx*2]
op_0_tab:       dd      op_00,op_02,op_04,op_06,op_08,op_0a,op_0c,op_0e
op_00:          mov     edx,'iro'               ; ORI
                jmp     op_0_imm
op_02:          mov     edx,'idna'              ; ANDI
                jmp     op_0_imm
op_04:          mov     edx,'ibus'              ; SUBI
                jmp     op_0_imm
op_06:          mov     edx,'idda'              ; ADDI
                jmp     op_0_imm
op_08:          call    op_0_Bits               ; BTST,BCLR,BSET,BCHG
                mov     edx,'#'
                call    OutLong
                mov     dx,w [esi]
                add     esi,2
                mov     ecx,2
                call    HexOut
                mov     edx,','
                call    OutLong
                mov     bl,al                   ; EA
                call    EA
                jmp     d68_exit
op_0a:          mov     edx,'iroe'              ; EORI
                jmp     op_0_imm
op_0c:          mov     edx,'ipmc'              ; CMPI
                jmp     op_0_imm
op_0e:          mov     edx,'evom'              ; MOVES
                call    OutLong
                mov     edx,'s'
                call    OutLong
                call    OutSize
                mov     dx,w [esi]
                add     esi,2
                mov     bl,dh
                shr     bl,3
                and     ebx,11110b
                mov     bx,w [regTab+ebx]
                mov     w [@@temp],bx
                test    dh,8
                jz      short @@toXn
                xor     edx,edx
                mov     dx,bx
                call    OutLong
                mov     edx,','
                call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit
@@toXn:         mov     bl,al
                call    EA
                mov     edx,','
                call    OutLong
                xor     edx,edx
                mov     dx,w [@@temp]
                call    OutLong
                jmp     d68_exit
@@temp:         dw      0
op_0_imm:       call    OutLong                 ; xxxI #...,EA
                call    OutSize
                mov     edx,'#'
                call    OutLong
                xor     edx,edx
                dec     bl
                js      short @@byte
                jz      short @@word
                mov     edx,d [esi]
                add     esi,4
                rol     edx,16
                jmp     short @@out
@@word:         mov     dx,w [esi]
                add     esi,2
                jmp     short @@out
@@byte:         mov     dx,w [esi]
                add     esi,2
                and     dx,255
@@out:          mov     ecx,8
                call    HexOut
                cmp     al,3ch
                jz      short @@CCR
                cmp     al,7ch
                jz      short @@SR
                mov     edx,','
                call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit
@@CCR:          mov     edx,'RCC,'
                jmp     short @@out1
@@SR:           mov     edx,'RS,'
@@out1:         call    OutLong
                jmp     d68_exit
op_0_extend:    cmp     ah,08                   ; BSET?
                jz      op_08
;
; CHK2, CMP2
;
; CAS.W, CAS.L
;
;

                jmp     d68_exit
op_0_odd:       call    getMode
                dec     bl
                jnz     @@Bits             ;*********************  MOVEP
                mov     edx,'evom'
                call    OutLong
                mov     dx,' l'
                test    al,40h                  ; W/L
                jnz     short @@movepl
                mov     dx,' w'
@@movepl:       shl     edx,16
                mov     dx,'.p'
                call    OutLong
                test    al,80h                  ; to/from mem
                jnz     short @@movepFromReg
                movsx   edx,w [esi]
                add     esi,2
                mov     ecx,8
                call    HexOut
                mov     dx,')0'
                mov     bl,al
                and     bl,7                    ; adres register
                add     dl,bl
                shl     edx,16
                mov     dx,'a('
                call    OutLong
                mov     edx,'0'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dl,bl
                shl     edx,16
                mov     dx,'d,'
                call    OutLong
                jmp     d68_exit
@@movepFromReg: mov     edx,',0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                movsx   edx,w [esi]
                add     esi,2
                mov     ecx,8
                call    HexOut
                mov     dx,')0'
                mov     bl,al
                and     bl,7                    ; adres register
                add     dl,bl
                shl     edx,16
                mov     dx,'a('
                call    OutLong
                jmp     d68_exit
@@Bits:         call    op_0_Bits               ; BTST,BCLR,BSET,BCHG
                mov     edx,',0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                mov     bl,al                   ; EA
                call    EA
                jmp     d68_exit
op_0_Bits:      mov     bl,al
                shr     bl,4
                and     ebx,1100b
                mov     edx,d [@@bitTab+ebx]
                call    OutLong
                call    Space
                ret
@@bitTab:       db      'btstbchgbclrbset'

op_move:        mov     edx,'evom'
                call    OutLong
                mov     bl,ah
                shr     bl,4
                and     ebx,3
                mov     bl,b [moveSize+ebx]
                call    OutSizeMove
                mov     bl,al
                call    EAmove
                mov     edx,','
                call    OutLong
                mov     bl,ah
                shr     bl,1
                and     bl,7                    ; register
                mov     ecx,eax
                shr     ecx,3
                and     ecx,0111000b
                or      bl,cl
                call    EAmove
                jmp     d68_exit
moveSize:       db      0,0,2,1

op_4:           test    ah,1                    ; ODD
                jz      @@op_4
                test    al,40h                  ; chk?
                jz      short @@op_4_chk
                call    getMode
                jz      short @@op_4_extb
                mov     edx,' ael'
                call    OutLong                 ; LEA
                mov     bl,al
                call    EA
                mov     edx,','
                call    OutLong
                mov     edx,'0a'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@op_4_extb:    mov     edx,'btxe'              ; EXTB
                call    OutLong
                call    Space
                mov     edx,'0d'
                mov     bl,al
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@op_4_chk:     mov     edx,'.khc'              ; CHK.x
                call    OutLong
                mov     edx,' l'
                test    al,80h                  ; long?
                jz      short @@op_4_chkl
                mov     edx,' w'
@@op_4_chkl:    call    OutLong
                mov     bl,al
                call    EA
                mov     edx,','
                call    OutLong
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@op_4:         call    getSize
                mov     cl,ah
                and     ecx,14
                jmp     d [op_4_tab+ecx*2]
op_4_tab:       dd      op_40,op_42,op_44,op_46,op_48,op_4a,op_4c,op_4e
op_40:          cmp     bl,3
                jz      short @@op_400                  ; NEGX
                mov     edx,'xgen'
                jmp     op_4_ea
@@op_400:       mov     edx,'evom'                      ; MOVE SR,...
                call    OutLong
                mov     edx,',rs '
                call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit
op_42:          cmp     bl,3                            ; CLR
                jz      short @@op_420
                mov     edx,'rlc'
                jmp     op_4_ea
@@op_420:       mov     edx,'evom'                      ; MOVE CCR,...
                call    OutLong
                mov     edx,'rcc '
                call    OutLong
                mov     edx,','
                call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit
op_44:          cmp     bl,3
                jz      short @@op_440
                mov     edx,'gen'                       ; NEG
                jmp     op_4_ea
@@op_440:       mov     edx,'evom'                      ; MOVE ...,CCR
                call    OutLong
                call    Space
                mov     bl,al
                mov     ecx,0                   ; byte
                mov     d [EAsize],ecx
                call    EA_
                mov     edx,'rcc,'
                call    OutLong
                jmp     d68_exit
op_46:          cmp     bl,3
                jz      short @@op_460                  ; NOT
                mov     edx,'ton'
                jmp     op_4_ea
@@op_460:       mov     edx,'evom'                      ; MOVE ...,SR
                call    OutLong
                call    Space
                mov     bl,al
                mov     ecx,1                   ; word
                mov     d [EAsize],ecx
                call    EA_
                mov     edx,'rs,'
                call    OutLong
                jmp     d68_exit
op_48:          mov     bx,ax
                and     bx,0fff8h
                cmp     bx,4848h
                jz      @@op_4_bkpt
                cmp     bx,4840h
                jz      @@swap
                cmp     bx,4880h
                jz      @@extw
                cmp     bx,48c0h
                jz      @@extw
                call    getSize
                jz      short @@nbcd
                dec     bl
                jz      @@pea
                mov     edx,'evom'                      ; MOVEM R->M
                call    OutLong
                mov     edx,' l.m'
                test    al,40h
                jnz     short @@2
                mov     edx,' w.m'
@@2:            call    OutLong
                mov     dx,w [esi]
                add     esi,2
                mov     ecx,4
                call    HexOut
                mov     edx,','
                call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit
@@op_4_bkpt:    mov     edx,'tpkb'              ; BKPT
                call    OutLong
                mov     edx,'# '
                call    OutLong
                mov     dl,al
                and     dl,7
                mov     ecx,1
                call    HexOut
                jmp     d68_exit
@@nbcd:         mov     edx,'dcbn'                      ; NBCD
                call    OutLong
                call    Space
                mov     bl,al
                call    EA
                jmp     d68_exit
@@pea:          mov     edx,'aep'                       ; PEA
                call    OutLong
                call    Space
                mov     bl,al
                call    EA
                jmp     d68_exit
@@swap:         mov     edx,'paws'                      ; SWAP
                call    OutLong
                call    Space
                mov     edx,'0d'
                mov     bl,al
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@extw:         mov     edx,'.txe'                      ; EXT.x
                call    OutLong
                mov     edx,' l'
                test    al,40h
                jnz     short @@1
                mov     edx,' w'
@@1:            call    OutLong
                mov     edx,'0d'
                mov     bl,al
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
op_4a:          cmp     ax,4afch
                jnz     short @@op_4aa                  ; ILLEGAL
                mov     edx,'elli'
                call    OutLong
                mov     edx,'lag'
                call    OutLong
                jmp     d68_exit
@@op_4aa:       cmp     bl,3
                jz      short @@op_4a0
                mov     edx,'tst'                       ; TST
                jmp     op_4_ea
@@op_4a0:       mov     edx,' sat'                      ; TAS
                call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit
op_4c:          cmp     bl,1
                jz      short @@divl
                cmp     bl,0
                jz      @@mull
                mov     edx,'evom'                      ; MOVEM M->R
                call    OutLong
                mov     edx,' l.m'
                test    al,40h
                jnz     short @@3
                mov     edx,' w.m'
@@3:            call    OutLong
                mov     dx,w [esi]
                add     esi,2
                push    edx
                mov     bl,al
                call    EA
                mov     edx,','
                call    OutLong
                mov     ecx,4
                pop     edx
                call    HexOut
                jmp     d68_exit

@@divl:         mov     edx,'vid'                       ; divu.l/divs.l
                call    OutLong
                push    eax
                mov     ax,w [esi]
                add     esi,2
                mov     edx,'s'
                test    ah,8
                jnz     short @@1
                mov     edx,'u'
@@1:            call    OutLong
                mov     edx,' l.'
                test    ah,4
                jnz     short @@2
                mov     edx,' l.l'
@@2:            call    OutLong
                pop     ebx
                call    EA
                mov     edx,','
                call    OutLong
                mov     bl,al
                and     bl,7
                mov     edx,'0d'
                add     dh,bl
                call    OutLong
                mov     bh,ah
                shr     bh,4
                cmp     bh,bl
                jz      d68_exit
                mov     edx,':'
                call    OutLong
                mov     edx,'0d'
                add     dh,bh
                call    OutLong
                jmp     d68_exit

@@mull:         mov     edx,'lum'                    ; mulu.l/muls.l
                call    OutLong
                push    eax
                mov     ax,w [esi]
                add     esi,2
                mov     edx,'s'
                test    ah,8
                jnz     short @@1_
                mov     edx,'u'
@@1_:           call    OutLong
                mov     edx,' l.'
                call    OutLong
                pop     ebx
                call    EA
                mov     edx,','
                call    OutLong
                mov     bl,ah
                shr     bl,4
                and     bl,7
                mov     edx,'0d'
                add     dh,bl
                call    OutLong
                mov     bl,ah
                test    ah,4
                jz      d68_exit
                mov     edx,':'
                call    OutLong
                mov     edx,'0d'
                add     dh,bl
                call    OutLong
                jmp     d68_exit

op_4e:          test    al,80h                          ; JMP/JSR
                jnz     @@Jxx
                mov     bl,al
                shr     bl,4
                cmp     bl,4
                jz      short @@trap
                cmp     bl,5
                jz      @@link
                cmp     bl,6
                jz      @@moveUSP
                test    al,8                            ; movec?
                jnz     @@movec
                mov     bl,al
                and     ebx,15
                lea     ecx,[ebx*4]
                add     ecx,ebx                         ; 5 chars
                mov     edx,d [@@op_4_tab+ecx]
                call    OutLong
                xor     edx,edx
                mov     dl,b [@@op_4_tab+ecx+4]
                call    OutLong
                jmp     d68_exit
@@op_4_tab:     db      'resetnop  stop rte  rtd  rts  trapvrtr  '
                align   4
@@trap:         mov     edx,'part'
                call    OutLong
                mov     edx,'# '
                call    OutLong
                mov     dl,al
                and     edx,15
                mov     ecx,1
                call    HexOut
                jmp     d68_exit
@@link:         test    al,8
                jnz     short @@unlink          ; LINK
                mov     edx,'knil'
                call    OutLong
                mov     dx,',0'
                mov     bl,al
                and     bl,7
                add     dl,bl
                rol     edx,16
                mov     dx,'a '
                call    OutLong
                mov     edx,'#'
                call    OutLong
                mov     dx,w [esi]
                add     esi,2
                mov     ecx,4
                call    HexOut
                jmp     d68_exit
@@unlink:       mov     edx,'klnu'              ; UNLK
                call    OutLong
                call    Space
                mov     dx,'0a'
                mov     bl,al
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@moveUSP:      mov     edx,'evom'              ; MOVE USP
                call    OutLong
                call    Space
                test    al,8
                jz      short @@toUSP
                mov     edx,',psu'
                call    OutLong
                mov     edx,'0a'
                mov     bl,al
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@toUSP:        mov     edx,'0a'
                mov     bl,al
                and     bl,7
                add     dh,bl
                call    OutLong
                mov     edx,'psu,'
                call    OutLong
                jmp     d68_exit
@@Jxx:          mov     edx,' rsj'              ; JSR
                test    al,40h
                jz      short @@Jmp
                mov     edx,' pmj'
@@Jmp:          call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit
@@movec:        mov     edx,'evom'
                call    OutLong
                mov     edx,' c'
                call    OutLong
                test    al,1
                jnz     short @@toCONTROL
                mov     ax,w [esi]
                add     esi,2
                call    getCtrlReg
                call    OutLong
                mov     edx,','
                call    OutLong
                call    getRegExt
                call    OutLong
                jmp     d68_exit
@@toCONTROL:    mov     ax,w [esi]
                add     esi,2
                call    getRegExt
                call    OutLong
                mov     edx,','
                call    OutLong
                call    getCtrlReg
                call    OutLong
                jmp     d68_exit

op_4_ea:        call    OutLong
                call    OutSize
                mov     bl,al
                call    EA
                jmp     d68_exit
                
op_5:           call    getSize
                cmp     bl,3
                jnz     @@addq
                mov     bl,al
                and     bl,0f8h
                cmp     bl,0c8h
                jz      short @@dbra            ; Scc
                mov     edx,'s'
                call    OutLong
                call    getCC
                mov     bl,al
                call    EA
                jmp     d68_exit
@@dbra:         mov     edx,'bd'              ; DBcc
                call    OutLong
                call    getCC
                mov     edx,'0d'
                mov     bl,al
                and     bl,7
                add     dh,bl
                call    OutLong
                mov     edx,','
                call    OutLong
                movsx   edx,w [esi]
                add     edx,esi
                add     esi,2
                sub     edx,ebp
                mov     ecx,8
                call    HexOut
                jmp     d68_exit
@@addq:         test    ah,1                    ; ADDQ
                jnz     short @@subq
                mov     edx,'qdda'
                jmp     short @@doQuick
@@subq:         mov     edx,'qbus'              ; SUBQ
@@doQuick:      call    OutLong
                call    OutSize
                mov     bl,ah
                shr     bl,1
                and     bl,7
                mov     edx,'0#'
                add     dh,bl
                call    OutLong
                mov     edx,','
                call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit

op_6:           mov     edx,'b'                         ; Bcc
                call    OutLong
                mov     bl,ah
                and     ebx,15
                xor     edx,edx
                mov     dx,w [@@BccTab+ebx*2]
                call    OutLong
                test    al,al
                jz      short @@Bcc16
                cmp     al,255
                jz      short @@Bcc32
                mov     edx,' s.'
                call    OutLong
                movsx   edx,al
                add     edx,esi
                jmp     short @@1
@@Bcc16:        call    Space
                movsx   edx,w [esi]
                add     edx,esi
                add     esi,2
                jmp     short @@1
@@Bcc32:        mov     edx,' l.'
                call    OutLong
                mov     edx,d [esi]
                rol     edx,16
                add     edx,esi
                add     esi,4
@@1:            sub     edx,ebp
                mov     ecx,8
                call    HexOut
                jmp     d68_exit
@@BccTab:       db      'rasrhilscccsneeqvcvsplmigeltgtle'

op_7:           mov     edx,'evom'              ; MOVEQ
                call    OutLong
                mov     edx,'# q'
                call    OutLong
                movsx   edx,al
                mov     ecx,8
                call    HexOut
                mov     edx,','
                call    OutLong
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit

op_8:           call    getSize
                test    ah,1
                jnz     @@odd
                call    getSize
                cmp     bl,3
                jnz     short @@op_8_or
                mov     edx,'uvid'              ; DIVU
                jmp     @@divs
@@op_8_or:      mov     edx,'ro'                ; OR EA,Dn
                call    OutLong
                call    OutSize
                jmp     @@divs1
@@odd:          mov     bx,ax
                and     bx,81f8h
                cmp     bx,8100h
                jz      @@sbcdD
                cmp     bx,8108h
                jz      @@sbcdA
                cmp     bx,8180h
                jz      @@unpkD
                cmp     bx,8188h
                jz      @@unpkA
                cmp     bx,8140h
                jz      @@packD
                cmp     bx,8148h
                jz      @@packA
                call    getSize
                cmp     bl,3
                jnz     @@op_8_or1
                mov     edx,'svid'              ; DIVS
@@divs:         call    OutLong
                mov     edx,' w.'
                call    OutLong
@@divs1:        mov     bl,al
                call    EA
                mov     edx,','
                call    OutLong
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@op_8_or1:     mov     edx,'ro'                ; OR Dx,EA
                call    OutLong
                call    OutSize
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                mov     edx,','
                call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit
@@sbcdD:        mov     edx,'dcbs'
                call    OutLong
                call    DxDy
                jmp     d68_exit
@@sbcdA:        mov     edx,'dcbs'
                call    OutLong
                call    AxAy
                jmp     d68_exit
@@unpkD:        mov     edx,'kpnu'
@@unpk:         call    OutLong
                call    DxDy
                mov     edx,'#,'
                call    OutLong
                mov     dx,w [esi]
                add     esi,2
                mov     ecx,4
                call    HexOut
                jmp     d68_exit
@@unpkA:        mov     edx,'kpnu'
@@unpk1:        call    OutLong
                call    AxAy
                mov     edx,'#,'
                call    OutLong
                mov     dx,w [esi]
                add     esi,2
                mov     ecx,4
                call    HexOut
                jmp     d68_exit
@@packD:        mov     edx,'kcap'
                jmp     short @@unpk
@@packA:        mov     edx,'kcap'
                jmp     short @@unpk1
DxDy:           call    Space
                mov     edx,'0d'
                mov     bl,al
                and     bl,7
                add     dh,bl
                call    OutLong
                mov     edx,','
                call    OutLong
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                ret
AxAy:           call    Space
                mov     edx,'a(-'
                call    OutLong
                mov     edx,'-,)0'
                mov     bl,al
                and     bl,7
                add     dl,bl
                call    OutLong
                mov     edx,'a('
                call    OutLong
                mov     edx,')0'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dl,bl
                call    OutLong
                ret

op_9:           call    getSize
                test    ah,1
                jnz     @@odd
                cmp     bl,3
                jz      @@suba
                mov     edx,'bus'               ; SUB
                call    OutLong
                call    OutSize
                mov     bl,al
                call    EA
                mov     edx,','
                call    OutLong
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@suba:         mov     edx,'abus'              ; SUBA
                call    OutLong
                mov     d [EAsize],1    ; word
                mov     edx,' w.'
                test    ah,1
                jz      short @@subaw
                mov     d [EAsize],2    ; long
                mov     edx,' l.'
@@subaw:        call    OutLong
                mov     bl,al
                call    EA_
                mov     edx,','
                call    OutLong
                mov     edx,'0a'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@odd:          cmp     bl,3
                jz      @@suba
                call    getMode
                dec     ebx
                js      short @@subxD
                jz      short @@subxA
                mov     edx,'bus'
                call    OutLong
                call    OutSize
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                mov     edx,','
                call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit
@@subxD:        mov     edx,'xbus'
                call    OutLong
                call    OutSize
                dec     edi                     ; remove space
                call    DxDy
                jmp     d68_exit
@@subxA:        mov     edx,'xbus'
                call    OutLong
                call    OutSize
                dec     edi                     ; remove space
                call    AxAy
                jmp     d68_exit

op_A:           mov     edx,'eniL'
                call    OutLong
                mov     edx,' A'               ; LineA $...
                call    OutLong
                mov     dx,ax
                mov     cx,3
                call    HexOut
                jmp     d68_exit

op_B:           call    getSize
                cmp     bl,3
                jz      @@cmpa
                test    ah,1
                jz      short @@cmp
                call    getMode
                cmp     bl,1
                jz      short @@cmpm
                mov     edx,'roe'
                jmp     short @@cmp1
@@cmpm:         mov     edx,'mpmc'              ; CMPM
                call    OutLong
                mov     edx,'a( '
                call    OutLong
                mov     edx,',+)0'
                mov     bl,al
                and     bl,7
                add     dl,bl
                call    OutLong
                mov     edx,'a('
                call    OutLong
                mov     edx,'+)0'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dl,bl
                call    OutLong
                jmp     d68_exit
@@cmp:          mov     edx,'pmc'               ; CMP
@@cmp1:         call    OutLong
                call    OutSize
                mov     bl,al
                call    EA
                mov     edx,','
                call    OutLong
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@cmpa:         mov     edx,'apmc'              ; CMPA
                call    OutLong
                mov     edx,' w.'
                mov     d [EAsize],1    ; word
                test    ah,1
                jz      short @@cmpaw
                mov     edx,' l.'
                mov     d [EAsize],2    ; long
@@cmpaw:        call    OutLong
                mov     bl,al
                call    EA_
                mov     edx,','
                call    OutLong
                mov     edx,'0a'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit

op_C:           call    getSize
                test    ah,1
                jnz     @@odd
                call    getSize
                cmp     bl,3
                jnz     short @@op_c_and
                mov     edx,'ulum'              ; MULU
                jmp     @@muls
@@op_c_and:     mov     edx,'dna'               ; AND EA,Dn
                call    OutLong
                call    OutSize
                jmp     @@muls1
@@odd:          mov     bx,ax
                and     bx,81f8h
                cmp     bx,8100h
                jz      @@abcdD
                cmp     bx,8108h
                jz      @@abcdA
                cmp     bx,8188h
                jz      @@exgDA
                cmp     bx,8140h
                jz      @@exgDD
                cmp     bx,8148h
                jz      @@exgAA
                call    getSize
                cmp     bl,3
                jnz     @@op_c_and1
                mov     edx,'slum'              ; MULS
@@muls:         call    OutLong
                mov     edx,' w.'
                call    OutLong
@@muls1:        mov     bl,al
                call    EA
                mov     edx,','
                call    OutLong
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@op_c_and1:    mov     edx,'dna'               ; AND Dx,EA
                call    OutLong
                call    OutSize
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                mov     edx,','
                call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit
@@abcdD:        mov     edx,'dcba'
                call    OutLong
                call    DxDy
                jmp     d68_exit
@@abcdA:        mov     edx,'dcba'
                call    OutLong
                call    AxAy
                jmp     d68_exit
@@exgDD:        mov     cx,'dd'
                jmp     short @@exg
@@exgAA:        mov     cx,'aa'
                jmp     short @@exg
@@exgDA:        mov     cx,'da'
@@exg:          mov     edx,' gxe'              ; EXG
                call    OutLong
                mov     edx,'0 '
                mov     dl,ch
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                mov     edx,','
                call    OutLong
                mov     edx,'0 '
                mov     dl,cl
                mov     bl,al
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit

op_D:           call    getSize
                test    ah,1
                jnz     @@odd
                cmp     bl,3
                jz      @@suba
                mov     edx,'dda'               ; ADD
                call    OutLong
                call    OutSize
                mov     bl,al
                call    EA
                mov     edx,','
                call    OutLong
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@suba:         mov     edx,'adda'              ; ADDA
                call    OutLong
                mov     d [EAsize],1    ; word
                mov     edx,' w.'
                test    ah,1
                jz      short @@subaw
                mov     d [EAsize],2    ; long
                mov     edx,' l.'
@@subaw:        call    OutLong
                mov     bl,al
                call    EA_
                mov     edx,','
                call    OutLong
                mov     edx,'0a'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@odd:          cmp     bl,3
                jz      @@suba
                call    getMode
                dec     ebx
                js      short @@subxD
                jz      short @@subxA
                mov     edx,'dda'
                call    OutLong
                call    OutSize
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                add     dh,bl
                call    OutLong
                mov     edx,','
                call    OutLong
                mov     bl,al
                call    EA
                jmp     d68_exit
@@subxD:        mov     edx,'xdda'
                call    OutLong
                call    OutSize
                dec     edi                     ; remove space
                call    DxDy
                jmp     d68_exit
@@subxA:        mov     edx,'xdda'
                call    OutLong
                call    OutSize
                dec     edi                     ; remove space
                call    AxAy
                jmp     d68_exit

op_E:           call    getSize
                cmp     bl,3
                jz      @@rolMem
                mov     bl,al
                shr     bl,2
                and     bl,6
                mov     bh,ah
                and     bh,1
                or      bl,bh
                and     ebx,7
                mov     edx,d [@@ShiftTab+ebx*4]
                call    OutLong
                call    OutSize
                mov     edx,'0d'
                mov     bl,ah
                shr     bl,1
                and     bl,7
                test    al,20h
                jnz     short @@regs
                dec     bl
                and     bl,7
                inc     bl
                mov     edx,'0#'
@@regs:         add     dh,bl
                call    OutLong
                mov     edx,','
                call    OutLong
                mov     edx,'0d'
                mov     bl,al
                and     bl,7
                add     dh,bl
                call    OutLong
                jmp     d68_exit
@@rolMem:       test    ah,8
                jnz     @@BFxxx
                mov     bl,ah
                and     ebx,7
                mov     edx,d [@@ShiftTab+ebx*4]
                call    OutLong
                call    Space
                mov     bl,al
                call    EA
                jmp     d68_exit
@@ShiftTab:     dd      'rsa','lsa','rsl','lsl','rxor','lxor','ror','lor'
@@BFxxx:        mov     edx,'xxFB'
                call    OutLong
                add     esi,2           ; correct temporary for disass.
                jmp     d68_exit

op_F:           mov     bx,ax
                and     bx,0fc0h
                jz      @@1
                mov     edx,'eniL'
                call    OutLong
                mov     edx,' F'               ; LineA $...
                call    OutLong
                mov     dx,ax
                mov     cx,3
                call    HexOut
                jmp     d68_exit



@@1:            mov     edx,'?UMM'
                call    OutLong
                call    Space
                add     esi,2
                mov     bl,al
                call    EA
                jmp     d68_exit

d68_exit:       mov     b [edi],0               ; end od ASCIIZ-string
                mov     edx,d [D68adres]        ; get initial PC
                sub     esi,edx                 ; opcode length
                mov     d [@@temp],esi
                popad
                mov     edx,d [@@temp]          ; Length
                ret
@@temp:         dd      0

;**************************************************
;* Get Size
;**************************************************
getSize:        mov     bl,al
                shr     bl,6                    ; bl=ss
                and     ebx,3
                ret
getMode:        mov     bl,al
                shr     bl,3
                and     bl,7                    ; mode
                ret
;**************************************************
;* Output Size .l,.w,.b
;**************************************************
OutSize:        call    getSize
OutSizeMove:    xor     edx,edx
                mov     dx,w [@@sizeTab+ebx*2]
                call    OutLong
                call    Space
                ret
@@sizeTab:      db      '.b.w.l'
                align   4
;**************************************************
;* Output EA for Destination, ebx=mmm|rrr
;**************************************************

EAmove:         mov     cl,ah
                shr     cl,4
                and     ecx,3
                mov     cl,b [moveSize+ecx]
                mov     d [EAsize],ecx
                jmp     short EA_
EA:             mov     cl,al
                shr     cl,6
                and     ecx,3
                mov     d [EAsize],ecx
EA_:            push    eax
                mov     bh,bl                   ; reg
                and     bh,7
                shr     bl,3
                and     bl,7                    ; mode
                jnz     short @@An              ; Dn
                mov     edx,'0d'
                add     dh,bh
                call    OutLong
                jmp     @@exit
@@An:           dec     bl                      ; An
                jnz     short @@An1
                mov     edx,'0a'
                add     dh,bh
                call    OutLong
                jmp     @@exit
@@An1:          dec     bl                      ; (An)
                jnz     short @@An2
                mov     edx,'a('
                call    OutLong
                mov     edx,')0'
                add     dl,bh
                call    OutLong
                jmp     @@exit
@@An2:          dec     bl                      ; (An)+
                jnz     short @@An3
                mov     edx,'a('
                call    OutLong
                mov     edx,'+)0'
                add     dl,bh
                call    OutLong
                jmp     @@exit
@@An3:          dec     bl                      ; -(An)
                jnz     short @@An4
                mov     edx,'a(-'
                call    OutLong
                mov     edx,')0'
                add     dl,bh
                call    OutLong
                jmp     @@exit
@@An4:          dec     bl                      ; (d16,An)
                jnz     short @@An5
                movsx   edx,w [esi]
                add     esi,2
                test    edx,80000000h
                jz      short @@An41
                neg     edx
                push    edx
                mov     edx,'-'
                call    OutLong
                pop     edx
@@An41:         mov     ecx,8
                call    HexOut
                mov     edx,'a('
                call    OutLong
                mov     edx,')0'
                add     dl,bh
                call    OutLong
                jmp     @@exit
@@An5:          dec     bl                      ; d8(An,Xn)
                jnz     short @@An6
                mov     edx,'0a'
                add     dh,bh
                jmp     @@extend
@@An6:          test    bh,bh                   ; Abs.W
                jnz     @@long
                movsx   edx,w [esi]
                add     esi,2
                mov     ecx,8
                call    HexOut
                mov     edx,'w.'
                call    OutLong
                jmp     @@exit
@@long:         dec     bh                      ; Abs.L
                jnz     short @@PC16
                mov     edx,d [esi]
                rol     edx,16
                add     esi,4
                mov     ecx,8
                call    HexOut
                jmp     @@exit
@@PC16:         dec     bh                      ; d16(PC)
                jnz     short @@PC8
                movsx   edx,w [esi]
                add     edx,esi                 ; PC+Base
                add     esi,2
                sub     edx,ebp                 ; PC
                mov     ecx,8
                call    HexOut
                mov     edx,')CP('
                call    OutLong
                jmp     @@exit
@@PC8:          dec     bh                      ; d8(PC,Xn)
                jnz     short @@Imm
                mov     edx,'CP'
                jmp     short @@extend
@@Imm:          mov     ebx,d [EAsize]          ; Imm
                dec     bl
                jns     short @@Im_word
                mov     edx,'#'
                call    OutLong
                mov     dx,w [esi]
                add     esi,2
                mov     ecx,2                   ; 2 nibbles
                call    HexOut
                jmp     short @@exit
@@Im_word:      dec     bl
                jns     short @@Im_long
                mov     edx,'#'
                call    OutLong
                mov     dx,w [esi]
                add     esi,2
                mov     ecx,4                   ; 2 nibbles
                call    HexOut
                jmp     short @@exit
@@Im_long:      mov     edx,'#'
                call    OutLong
                mov     edx,d [esi]
                rol     edx,16
                add     esi,4
                mov     ecx,8                   ; 2 nibbles
                call    HexOut
@@exit:         pop     eax
                ret
@@extend:       mov     d [@@ext_reg],edx       ; d8(XX,Xn*Scale)
                mov     ax,w [esi]
                add     esi,2
                call    getRegExt
                mov     bl,ah
                mov     edx,'l.'
                test    ah,8                    ; L/W?
                jne     short @@longext
                mov     edx,'w.'
@@longext:      shr     bl,1
                and     ebx,3
                jz      short @@noScale
                shl     edx,16
                mov     dl,'*'
                mov     dh,b [@@scaleTab+ebx]
                rol     edx,16
@@noScale:      mov     d [@@ext_scale],edx
                test    ah,1                    ; Full extend?
                jnz     short @@full
                xor     edx,edx
                mov     dl,al
                mov     ecx,2
                call    HexOut
                mov     edx,'('
                call    OutLong
                mov     edx,d [@@ext_reg]
                call    OutLong
                mov     edx,','
                call    OutLong
                xor     edx,edx
                mov     dx,w [EAext_dat]
                call    OutLong
                mov     edx,d [@@ext_scale]
                call    OutLong
                mov     edx,')'
                call    OutLong
                jmp     @@exit
@@full:         mov     edx,'[('
                call    OutLong
                mov     bl,al
                shr     bl,4
                and     ebx,3                   ; BD size
                jz      short @@fullAn
                dec     ebx
                jz      short @@fullAn
                dec     ebx
                jnz     short @@BDlong
                movsx   edx,w [esi]
                add     esi,2
                jmp     short @@BD
@@BDlong:       mov     edx,d [esi]
                add     esi,4
                rol     edx,16
@@BD:           mov     ecx,8
                call    HexOut
                test    al,80h
                jnz     short @@BaseSupp        ; An/PC suppressed
                mov     edx,','
                call    OutLong
@@fullAn:       test    al,80h                  ; Base Register?
                jnz     short @@Index
                mov     edx,d [@@ext_reg]
                call    OutLong
@@BaseSupp:     test    al,4                    ; Post/Pre?
                jz      short @@Index
                mov     edx,']'
                call    OutLong
@@Index:        mov     edx,','
                call    OutLong
                test    al,40h                  ; Index?
                jnz     short @@OD
                xor     edx,edx
                mov     dx,w [EAext_dat]
                call    OutLong
                mov     edx,d [@@ext_scale]
                call    OutLong
                test    al,4                    ; post/pre?
                jnz     short @@OD
                mov     edx,']'
                call    OutLong
@@OD:           mov     bl,al
                xor     edx,edx
                and     ebx,3
                jz      short @@noOD
                dec     ebx
                jz      short @@noOD
                mov     edx,','
                call    OutLong
                dec     ebx
                jnz     short @@ODlong
                movsx   edx,w [esi]
                add     esi,2
                jmp     short @@ODout
@@ODlong:       mov     edx,d [esi]
                add     esi,4
                rol     edx,16
@@ODout:        mov     ecx,8
                call    HexOut
@@noOD:         mov     edx,')'
                call    OutLong
                jmp     @@exit
@@ext_reg:      dd      0                       ; An or PC
@@ext_scale:    dd      0                       ; scale
@@scaleTab:     db      '1248'
regTab:         db      'd0d1d2d3d4d5d6d7a0a1a2a3a4a5a6a7'
EAext_dat:      dw      0                       ; Xn
EAsize:         dd      0
getRegExt:      mov     bl,ah
                shr     bl,3
                and     ebx,011110b
                xor     edx,edx
                mov     dx,w [regTab+ebx]
                mov     w [EAext_dat],dx
                ret
getCC:          mov     bl,ah
                and     ebx,15
                xor     edx,edx
                mov     dx,w [@@CCtab+ebx*2]
                call    OutLong
                cmp     bl,2
                jl      short @@1
                call    Space
@@1:            ret
@@CCtab:        db      't f hilscccsneeqvcvsplmigeltgtle'

getCtrlReg:     mov     ebx,eax
                and     ebx,0fffh
                cmp     ebx,0
                jnz     short @@1
                mov     edx,'CFS'
                ret
@@1:            cmp     ebx,1
                jnz     short @@2
                mov     edx,'CFD'
                ret
@@2:            cmp     ebx,800h
                jnz     short @@3
                mov     edx,'PSU'
                ret
@@3:            cmp     ebx,801h
                jnz     short @@4
                mov     edx,'RBV'
                ret
@@4:            cmp     ebx,2
                jnz     short @@5
                mov     edx,'RCAC'
                ret
@@5:            cmp     ebx,802h
                jnz     short @@6
                mov     edx,'RAAC'
                ret
@@6:            cmp     ebx,8003h
                jnz     short @@7
                mov     edx,'PSM'
                ret
@@7:            cmp     ebx,804h
                jnz     short @@8
                mov     edx,'PSI'
                ret
@@8:            mov     edx,'????'
                ret

;**************************************************
;* Output chars in EDX to outputstring (Reversed!)
;**************************************************
OutLong:        mov     b [edi],dl
                add     edi,1
                shr     edx,8                   ; next byte
                jnz     short OutLong
                ret
Space:          mov     b [edi],' '
                add     edi,1
                ret
;**************************************************
;* Output HEX in EDX, length ECX
;**************************************************
HexOut:         push    eax
                push    ecx
                mov     eax,edx
                shl     ecx,2
                ror     edx,cl
                pop     ecx
                cmp     eax,10
                jl      short @@skip0
                mov     b [edi],'$'
                add     edi,1
@@skip0:        rol     edx,4                   ; Skip leading zero's
                mov     al,dl
                and     eax,15
                jnz     short @@loop1
                dec     ecx
                jnz     short @@skip0
                inc     ecx
@@loop:         mov     al,dl
                and     eax,15                  ; Mask Nibble
@@loop1:        mov     al,b HexTab[eax]
                mov     b [edi],al
                add     edi,1
                rol     edx,4
                dec     ecx
                jnz     short @@loop
                pop     eax
                ret

                .Data
HexTab:         db      '0123456789ABCDEF'
DisTab:         dd      op_0,op_move,op_move,op_move,op_4,op_5,op_6,op_7
                dd      op_8,op_9,op_A,op_B,op_C,op_D,op_E,op_F

TestOpcodes:    dw      0e00ah

D68adres:       dd      0

                END
