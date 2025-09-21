                EXPORT  graf_growbox, graf_shrinkbox
                IMPORT  aes, intin

graf_growbox:   move.l  #$49080100,A0
                bra.b   graf_8ii
graf_shrinkbox: move.l  #$4A080100,A0
graf_8ii:       lea     intin,A1                ;8 IntIn
                move.w  D0,(A1)+                ;stx
                move.w  D1,(A1)+                ;sty
                move.w  D2,(A1)+                ;stwidth
                move.l  A0,D0
                lea     4(A7),A0
                move.l  (A0)+,(A1)+             ;stheight, finx
                move.l  (A0)+,(A1)+             ;finy, finwidth
                move.w  (A0)+,(A1)+             ;finheight
                bra     aes


