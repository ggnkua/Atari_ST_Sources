;       View Matrix creation and matrix multiplication.
;       Martin Griffiths March 1994.
;       

.386

_TEXT segment para public use32 'CODE'

assume cs:_TEXT, ds:_DATA

; Create a 3x3 3d view matrix.
; (not 486 optimised).
; EAX -> xang,yang,zang.

PUBLIC make_viewmatrix_

make_viewmatrix_ proc  near
                PUSHAD                  ; save all regs.
                LEA ESI,trig_tab
                LEA EDI,trig_tab+512
                MOV ECX,07Feh                
                MOV BX,[EAX+0]          ; xangle
                AND EBX,ECX
                MOV BP,[ESI+EBX]        ; sin(xangle)
                MOV DX,[EDI+EBX]        ; cos(xangle)
                MOV xyz_sins+0,BP
                MOV xyz_sins+2,DX
                
                MOV BX,[EAX+2]          ; yangle  
                AND EBX,ECX
                MOV BP,[ESI+EBX]        ; sin(yangle)
                MOV DX,[EDI+EBX]        ; cos(yangle)
                MOV xyz_sins+4,BP
                MOV xyz_sins+6,DX

                MOV BX,[EAX+4]           ; zangle       
                AND EBX,ECX
                MOV BP,[ESI+EBX]        ; sin(zangle)
                MOV DX,[EDI+EBX]        ; cos(zangle)
                MOV xyz_sins+8,BP
                MOV xyz_sins+10,DX
                
                LEA ESI,xyz_sins
                LEA EDI,_obj_matrix

; sin(zd)-sin(xd) - used twice - d3!!
                MOV AX,[ESI]
                IMUL WORD ptr [ESI+8]
                SHL EDX,16
                MOV DX,AX
                SAR EDX,15
                MOV xd3,DX
; sinz(zd)*cos(xd) - used twice - d4!!
                MOV AX,[ESI+2]
                IMUL WORD ptr [ESI+8]
                SHL EDX,16
                MOV DX,AX
                SAR EDX,15
                MOV xd4,DX
; Matrix (1,1) cos(yd)*cos(xd)-sin(yd)*sin(zd)*sin(xd)
                MOV AX,[ESI+6]
                MOV BX,[ESI+2]
                IMUL BX
                SHL EDX,16
                MOV DX,AX
                PUSH EDX
                MOV AX,[ESI+4]
                MOV BX,xd3
                IMUL BX
                SHL EDX,16
                MOV DX,AX
                POP EAX
                SUB EAX,EDX
                SAR EAX,15
                MOV [EDI+0],EAX
; Matrix (2,1) sin(yd)*cos(xd)+cos(yd)*sin(zd)*sin(xd)
                MOV AX,[ESI+4]
                IMUL WORD ptr [ESI+2]
                SHL EDX,16
                MOV DX,AX
                PUSH EDX
                MOV AX,[ESI+6]
                IMUL WORD ptr xd3
                SHL EDX,16
                MOV DX,AX
                POP EAX
                ADD EAX,EDX
                SAR EAX,15
                MOV [EDI+4],EAX
; Matrix (3,1) -cos(zd)*sin(xd)
                MOV AX,[ESI+10]          ; cos (zd)
                NEG AX                  ; -cos(zd)
                IMUL WORD ptr [ESI]      ; -cos(zd)*sin(xd)
                SHL EDX,16
                MOV DX,AX
                SAR EDX,15              ; correct result
                MOV [EDI+8],EDX
; Matrix (1,2) -sin(yd)*cos(zd)
                MOV AX,[ESI+4]           ; sin (yd)
                NEG AX                  ; -sin(yd)
                IMUL WORD ptr [ESI+10]   ; -sin(yd)*cos(zd)
                SHL EDX,16
                MOV DX,AX
                SAR EDX,15              ; correct result
                MOV [EDI+12],EDX
 ; Matrix (2,2) cos(yd)*cos(zd)
                MOV AX,[ESI+6]           ; cos (yd)
                IMUL WORD ptr [ESI+10]   ; cos(yd)*cos(zd)
                SHL EDX,16
                MOV DX,AX
                SAR EDX,15              ; correct result
                MOV [EDI+16],EDX
; Matrix (3,2) sin (zd)
                MOVSX EAX, WORD ptr [ESI+8]  ; sin (zd)
                MOV [EDI+20],EAX          ; store result.
; Matrix (1,3) cos(yd) * sin(xd) + sin(yd) * sin (zd) * cos (xd)
                MOV AX,[ESI+6]
                IMUL WORD ptr [ESI]
                SHL EDX,16
                MOV DX,AX
                PUSH EDX
                MOV AX,[ESI+4]
                IMUL WORD ptr xd4
                SHL EDX,16
                MOV DX,AX
                POP EAX
                ADD EAX,EDX
                SAR EAX,15
                MOV [EDI+24],EAX
; Matrix (2,3) sin(yd) * sin(xd) - cos(yd) * sin (zd) * cos (xd)
                MOV AX,[ESI+4]
                IMUL WORD ptr [ESI]
                SHL EDX,16
                MOV DX,AX
                PUSH EDX
                MOV AX,[ESI+6]
                IMUL WORD ptr xd4
                SHL EDX,16
                MOV DX,AX
                POP EAX
                SUB EAX,EDX
                SAR EAX,15
                MOV [EDI+28],EAX
 ; Matrix (3,3) cos(zd)*cos(xd)
                MOV AX,[ESI+10]          ; cos (zd)
                IMUL WORD ptr [ESI+2]    ; cos(zd)*cos(xd)
                SHL EDX,16
                MOV DX,AX
                SAR EDX,15              ; correct result
                MOV [EDI+32],EDX

                POPAD                    ; restore our regs
                RET

make_viewmatrix_ endp

; Translation of 3d co-ords
; (3X3 * 3 x 1 Mat Mult.)
; EAX -> x,y,z 
; EBX -> no. of co-ords
; EDX -> new x,y,z space

PUBLIC translate_crds_

translate_crds_ proc  near
                PUSHAD
                LEA EBP,_obj_matrix
                MOV ESI,EAX     ; ESI -> 
                MOV EDI,ECX     ; EDI -> new co-ords
                MOV EAX,EBX     ; no. of co-ords
trans_lp:       MOVSX ECX,WORD ptr [ESI+2]
                MOVSX EDX,WORD ptr [ESI]  
                IMUL EDX,DWORD ptr [EBP]
                MOVSX EBX,WORD ptr [ESI+4]
                IMUL ECX,DWORD ptr [EBP+4]
                ADD EDX,ECX
                IMUL EBX,DWORD ptr [EBP+8]
                ADD EDX,EBX
                SAR EDX,15
                MOV [EDI],DX                            ; store x
                MOVSX ECX,WORD ptr [ESI+2]
                MOVSX EDX,WORD ptr [ESI]  
                IMUL EDX,DWORD ptr [EBP+12]
                MOVSX EBX,WORD ptr [ESI+4]
                IMUL ECX,DWORD ptr [EBP+16]
                ADD EDX,ECX
                IMUL EBX,DWORD ptr [EBP+20]
                ADD EDX,EBX
                SAR EDX,15
                MOV [EDI+2],DX                          ; store y
                MOVSX ECX,WORD ptr [ESI+2]
                MOVSX EDX,WORD ptr [ESI]  
                IMUL EDX,DWORD ptr [EBP+24]
                MOVSX EBX,WORD ptr [ESI+4]
                IMUL ECX,DWORD ptr [EBP+28]
                IMUL EBX,DWORD ptr [EBP+32]
                ADD EDX,ECX
                ADD ESI,6
                ADD EDX,EBX
                ADD EDI,6
                SAR EDX,15
                MOV [EDI+4-6],DX                      ; store z
                DEC EAX
                JNZ trans_lp

                POPAD
                RET

translate_crds_ endp

; Perspective transform on 3d co-ords
; 486 optimised.
; EAX -> x,y,z 
; EBX -> no. of co-ords
; ECX -> new x,y,z space

PUBLIC perspect_crds_

perspect_crds_ proc  near
                PUSHAD
                MOV ESI,EAX     ; ESI -> 
                MOV EDI,ECX     ; EDI -> new co-ords
                MOV EBP,EBX     ; no. of co-ords
persp_lp:       MOVSX EBX,WORD ptr [ESI+4]        ; z
                MOVSX EDX,WORD ptr [ESI]  
                ADD EBX,256                       ; z + DIST
                SAL EDX,8                         ; x * dist
                MOV AX,DX
                SHR EDX,16
                IDIV BX    
                MOV [EDI],AX                      ; store x
                MOVSX EDX,WORD ptr [ESI+2]
                SAL EDX,8
                MOV AX,DX
                SHR EDX,16
                IDIV BX
                MOV [EDI+2],AX                    ; store y
                ADD ESI,6           
                MOV [EDI+4],BX                    ; store z
                ADD EDI,6
                DEC EBP
                JNZ persp_lp

                POPAD
                RET

perspect_crds_  endp

_TEXT           ends
                
_DATA segment para public use32 'DATA'

_obj_matrix     dd 9 dup (0)
xyz_sins        dw 6 dup (0)
xd3             dw 0
xd4             dw 0

PUBLIC _obj_matrix
                
; Sin/cos table.

                include trig.inc

_DATA           ends
                
                end
