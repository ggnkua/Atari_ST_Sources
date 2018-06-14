;
;    OPT L0              ; TOS executable TOS
;    OPT P=68000
;    OPT D-,X-           ; no symbols debug
;    OPT Y-              ; no source debug
;
;                OPT O+,OW+                                  ;all optimisations warns
;O2: d16(an) -> (an) when d16=0


;pour autoload:
NOTRACKINFO     =     1                               ;don't update alTrackCurrent
NOSEEK          =     1                               ;don't seek first
FORCE2SIDES     =     1
FORCESECTORS    =     9                               ;0/9/10/11 use 0 to not force
USEMOVEP        =     0                               ;recommended to leave to 0, as the 68060 doesn't know movep
SHOWCOLORS      =     0
DONTSAVEREGS    =     1                               ;don't save/restore all registers when calling fdcAutoloader. Saves 8 bytes
DONTINITA0      =     0                               ;set to 1 if A0=alStruct before calling fdcAutoloader. Saves 4 bytes
DONTTOUCHVBL    =     1                               ;does not install the motoroff vbl. fdcVBL should still be called to handle motoroff. Saves 28 bytes
DONTINCLUDEVBL  =     1                               ;saves an extra 98 bytes. Motoroff code must be implemented
ASYNCADDR2      =     1                               ;maintain a second, offseted address (used for asynchronous loading like real time depacking). Costs 8 bytes + 4 in alStruct

;    OPT O+, OW+
;    OPT O1+,OW1-        ; backward branches
;    OPT O6+,OW6-        ; forward branches

    include "const.s"

        
            
                pea     -1.w
                move.w  #$48,-(a7)                          ;MALLOC
                trap    #1
                move.l  d0,a4

                move.l  d0,2(a7)
                trap    #1                                  ;MALLOC
                addq.l  #6,a7
                move.l  d0,a5                               ;a5: start of the malloced block
                add.l   d0,a4                               ;a4: end address of the malloced block
                move.l  a4,usp

        
                sub.l   #(LOADsize+511)/512*512,a4          ;a4:load address (end of the block)
                ;DMA can only read a multiple of 512 bytes, so align it

;a4: load address (end of the block)
;a5: start of the malloced block

                lea     alStruct(pc),a6                     ;a6:alStruct
                move.l  a4,(a6)+                            ;alAddress
                move.l  a4,d7
                add.l   d7,(a6)+                            ;alAddress2 (for async depack)
                move.l  (a6),d7                             ;d7=nb sector to read
                subq.l  #8,a6                               ;a6:alStruct

                bsr.s   fdcAutoloader                       ;prend ses paramètres de alStruct. Registres modifiés

    IFNE STAGE2len/512>0
                subq.l  #STAGE2len/512,d7                   ;nombre de secteur supplémentaire à attendre avant
                                                            ;de lancer stage2 (0 signifie, attend un secteur)
                                                            ;en effet, on ne veut pas lancer STAGE2 avant que tout soit lu.
    ENDC

                ;attend que tout stage2 ait été chargé
.waitstage2:    cmp.l   8(a6),d7
                bls.s   .waitstage2

                jmp     (a4)

        



alStruct:       dc.l    0                       ;address to read to
                dc.l    -256                    ;offset for address2
                dc.l    (LOADsize+511)/512      ;number of sectors to read
                dc.b    2                       ;sector to start to read from    ; sector 2
                dc.b    0                       ;side to start to read from      ; side 0
;                dc.b    0                      ;motoron                         ; can be saved to save 2 bytes
;                EVEN

SUPER:          include "autoload.s"






