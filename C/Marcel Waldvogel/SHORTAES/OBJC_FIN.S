                EXPORT  objc_find
                IMPORT  aes, intin, addrin

objc_find:      lea     intin,A1
                move.l  A0,addrin               ;tree (u.U. relativ zu A1)
                move.w  D0,(A1)+                ;startob
                move.w  D1,(A1)+                ;depth
                move.w  D2,(A1)+                ;mx
                move.w  4(A7),(A1)              ;my
                move.l	#$2B040101,D0
                bra     aes


