                EXPORT  objc_draw
                IMPORT  aes, intin, addrin

objc_draw:      lea     intin,A1
                move.l  A0,addrin               ;tree (u.U. relativ zu A1)
                move.w  D0,(A1)+                ;startob
                move.w  D1,(A1)+                ;depth
                move.w  D2,(A1)+                ;xclip
                move.l  4(A7),(A1)+             ;yclip, wclip
                move.w  8(A7),(A1)              ;hclip
                move.l  #$2A060101,D0
                bra     aes


