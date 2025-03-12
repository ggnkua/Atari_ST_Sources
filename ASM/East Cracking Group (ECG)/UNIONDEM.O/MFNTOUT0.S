                lea     mid_fnt+'A',A0
                movea.l screen0,A6
src             SET 0
tar             SET 0
                REPT 8
                move.b  src(A0),tar(A6)
src             SET src+256
tar             SET tar+160
                ENDR
