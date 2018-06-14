;exécuté dès que le loader a fini de lire X octets (ou Y secteurs)

;mapping mémoire:
; $4c6.l (_dskbuf):        pointeur vers secteur de boot
;  _dskbufp:               boot loader


;mapping mémoire fin du decrunch:
;BASEPAGE
;TEXT
;DATA
;BSS
;.
;.
;STACK
;END OF MEMORY

;à la fin du décrunch, reloger le programme, remplir la BASEPAGE, clearer la BSS

;    OPT L0              ; executable TOS
;    OPT P=68000
;    OPT D-,X-           ; no symbols debug
;    OPT Y-              ; no source debug

;    OPT O+, OW+
;    OPT O1+,OW1-        ; backward branches
;    OPT O6+,OW6-        ; forward branches


                include "const.s"

;a6: alStruct
;d4: load address (end of the block) (not used)
;a5: start of the malloced block

STAGE2START     = *

                ;show the welcome screen and the loading bar
                pea     MSG1(pc)
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7
                
                                                            
                lea     PACKEDFILE(pc),a0                   ;a0:Packed File (address to depack from)
                move.l  a5,a1                               ;a1:Destination (address to depack to)
                move.l  a0,pPACKEDFILE-PACKEDFILE(a0)       ;move.l a0,pPACKEDFILE(pc)

                lea.l   4(a6),a4                            ;a4:alAddress2 (for async depack) (offseted address)
                move.l  a1,a6                               ;a6:Destination
                
                bra.s   decrunch

pPACKEDFILE:    ds.l    1                                   ;start adress of packed data
                dc.w    -1                                  ;last number of dots

;this subroutine is called from depack
wait_sync:      movem.l d0-d3/a0-a3,-(a7)
;a0: current address in the packed file
                move.l  a0,d3
                lea     pPACKEDFILE(pc),a2
                move.l  (a2)+,a1                            ;a1: adresse of packed file
                                                            ;a2: pointer to number of dots
                sub.l   a1,d3                               ;d0:current offset
                move.l  #PACKlen/38,d1
                divu    d1,d3
                bmi.s   .endplot                            ; < 0 : don't plot
                move.w  d3,d0
                sub.w   (a2),d3
                beq.s   .endplot                            ; same number of dots: do nothing
                move.w  d0,(a2)                             ;else save the number of dots
                subq.w  #1,d3
                
.plot:
                pea     (2<<16)+('.')               ; C_CONOUT "."
                trap    #1
                addq.l  #4,a7
                dbra    d3,.plot

.endplot:       movem.l (a7)+,d0-d3/a0-a3
                rts


N2B_ASYNC       =     1    ; when set, decrunch will wait if (a4)<a0
                              ; Use this to throttle real time loading. It is advised
                              ; to set (a4) as the current loaded byte - N (N=255 seems good)
                              ; when loading is finished, put -1 in (a4)

N2B_TOWER       =     1                                   ; 0,1 or 6-10  0:8  1:14  n:4n+14 bytes
N2B_WAIT_SYNC   MACRO
                bsr.s   wait_sync
                or      #16,ccr
                ENDM
decrunch:
                include "n2bd.s"


;                move.b  #$0e,$ffff8800.w
;                move.b  $ffff8800.w,d0              ; read PSG register 14
;                or.b    #6,d0                       ; deselect drivea & driveb
;                move.b  d0,$ffff8802.w
                

                ;a6:Destination
            
;************************************************** START RELOCA
                ;relocate .PRG in a6
                ;include "..\unpack\RELOCA4.S"
RELOC_PRG
            movem.l d6-d7/a4-a6,-(a7)                       ;save registers
            lea     256(a6),a6                              ; a6 ==> début du programme (TEXT)
            move.l  a6,d7                                   ; d7 ==> valeur à additionner
            move.l  a6,a4                                   ; a4 ==> Début du programme
            add.l   #TEXTlen+DATAlen,a4                     ; a4 ==> segment BSS = table de relocation
            move.l  (a4)+,d6
            beq.s   FIN2071

reloc2071:  adda.l  d6,a6
            add.l   d7,(a6)
            moveq   #0,d6
boucl2071:  move.b  (a4)+,d6
            beq.s   FIN2071
            cmpi.b  #1,d6
            bne.s   reloc2071
            lea.l   254(a6),a6
            bra.s   boucl2071

FIN2071:    movem.l (a7)+,d6-d7/a4-a6
;************************************************** END RELOCA

                                                            ;a6=basepage
            lea     256(a6),a5                              ;a5=TEXT (début du programme)
            move.l  a6,a4                                   ;a4=basepage
            move.l  a5,a3                                   ;a3=TEXT
            sub.l   a0,a0                                   ;a0=0 (important)

            move.l  a6,(a4)+                                ;p_lowtpa 0x00 faked block start address (the malloc result is lower=a0)
            move.l  $436.w,(a4)+                            ;p_hitpa  0x04 top memory = end of the TIA block
            move.l  a3,(a4)+                                ;p_tbase  0x08 TEXT
            move.l  #TEXTlen,d0
            move.l  d0,(a4)+                                ;p_tlen   0x0c TEXTlen (+ stage2len)
            add.l   d0,a3
            move.l  a3,(a4)+                                ;p_dbase  0x10 DATA
            move.l  #DATAlen,d0
            move.l  d0,(a4)+                                ;p_dlen   0x14 DATAlen
            add.l   d0,a3                                   ;              a3=BSS
            move.l  a3,(a4)+                                ;p_bbase  0x18 BSS
            move.l  #BSSlen,d0
            move.l  d0,(a4)+                                ;p_blen   0x1C BSS length
            ;d0:length to clear (BSS)
            ;a3:start of BSS
            
            move.l  a0,(a4)+                                ;p_dta    0x20 DTA
            move.l  a0,(a4)+                                ;p_parent 0x24 parent BP
            move.l  a0,(a4)+                                ;p_reserv 0x28
            move.l  a4,(a4)
            addq.l  #4,(a4)+                                ;p_env    0x2c environment
                                                            ;p_undef  0x30 80 bytes unused reserved
                                                            ;p_cmdlin 0x80 128 bytes command line

;Efface la BSS
            lsr.l   #2,d0
.clearbss:  move.l  a0,(a3)+
            dbra    d0,.clearbss

;Passe en mode utilisateur
            and     #$dfff,sr

;Prépare le lancement
            pea     (a6)
            pea     0.w
            ;sub.l   a0,a0                                  ;a0=0

            jmp     (a5)

                
                
                ;le fichier décompacté et relogé se trouvera ici.
                ;inutile de faire un jmp (a6), donc

MSG1:       ;dc.b    27,'e'          ; show cursor
            dc.b    27,'w'          ; wrap off
            dc.b    "Loading HxC Manager...                 "
            dc.b    10              ;line down
            dc.b    27,'o'          ;clear start of line
            dc.b    ']'
            dc.b    13              ;go to start of line
            dc.b    '[',0
;            dc.b    "[......................................]"
            EVEN

PACKEDFILE:
