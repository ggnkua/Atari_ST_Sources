                EXPORT  objc_change
                IMPORT  aes, intin, addrin

objc_change:    lea     intin,A1
                move.l  A0,addrin               ;tree (u.U. relativ zu A1)
                move.w  D0,(A1)+                ;object
                move.w  D1,(A1)+                ;resvd
                move.w  D2,(A1)+                ;xclip
                lea     4(A7),A0                ;A0 zeigt ins Stackframe
                move.l  (A0)+,(A1)+             ;yclip, wclip
                move.l  (A0)+,(A1)+             ;hclip, newstate
                move.w  (A0)+,(A1)+             ;redraw
                move.l  #$2F080101,D0
                bra     aes


