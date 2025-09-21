                EXPORT  form_error
                IMPORT  aes, intin

form_error:     move.w  D0,intin                ;num
                move.l  #$35010100,D0
                bra     aes


