;
; Placer ces lignes au d‚but de tous vos programmes sous GEM
;
; Assembler              GEM_INIT.ASM
;

; premiŠre ‚tape: calculer l'espace m‚moire occup‚ par
; le programme et lib‚rer l'espace inutilis‚. Cr‚er ‚galement
; une pile de 4 Ko

               movea.l    4(sp),a5      ;4(sp) est le d‚but de la Basepage
               move.l     12(a5),d0     ;Taille du code du programme
               add.l      20(a5),d0     ;+ Longueur du segment Data
               add.l      28(a5),d0     ;+ Longueur du segment BSS
               addi.l     #$1100,d0     ;+ Basepage (256 octets)+ pile (4KB)

               move.l     d0,d1         ;Longueur plus
               add.l      a5,d1         ;adresse
               andi.l     #-2,d1        ;(arrondie)
               movea.l    d1,sp         ;donne le pointeur sur la pile

               move.l     d0,-(sp)      ;Taille de la m‚moire requise
               move.l     a5,-(sp)      ;Adresse de la zone
               clr.w      -(sp)         ;Octet "dummy" (factice) sans signification
               move.w     #$4a,-(sp)    ;Num‚ro de fonction mshrink
               trap       #1            ;Trap pour GEMDOS
               adda.l     #12,sp
               jmp        main          ;Saut dans l'application


; Sous-programmes AES et VDI

aes:           move.l     #aespb,d1     ;Bloc de paramŠtres AES
               move.w     #$c8,d0       ;Nombre magique pour l'AES
               trap       #2            ;Appel GEM
               rts        

vdi:           move.l     #vdipb,d1     ;Bloc de paramŠtres VDI
               move.w     #$73,d0       ;Code pour VDI
               trap       #2            ;Appel GEM
               rts        

; Voici les blocs de paramŠtres:

               .DATA 

aespb:         .DC.l control
               .DC.l global
               .DC.l int_in             ;Diff‚rence entre les tableaux
               .DC.l int_out            ;d'entiers VDI et AES: _
               .DC.l addr_in
               .DC.l addr_out

vdipb:         .DC.l contrl
               .DC.l intin
               .DC.l ptsin
               .DC.l intout
               .DC.l ptsout

; Voici les tableaux proprement dits:

               .BSS 

global:        .DS.w 16   ;AES
control:       .DS.w 10
int_in:        .DS.w 128
int_out:       .DS.w 128
addr_in:       .DS.l 128
addr_out:      .DS.l 128

contrl:        .DS.w 12   ;VDI
intin:         .DS.w 128
ptsin:         .DS.w 128
intout:        .DS.w 128
ptsout:        .DS.w 128

               .TEXT 

               .END 
