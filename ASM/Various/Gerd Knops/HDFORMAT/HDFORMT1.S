;Demo 1 zum Bootsektor-Lader.
;Einfach eine Startmeldung ausgeben.
;Beim GFA-Assembler muû auch dies erst in Assembler-Source gewandelt werden!

                pea       start_text(pc)   ;Startmeldung ausgeben
                move.w    #9,-(sp)      ;Cconws
                trap      #1            ;Gemdos
                addq.w    #6,sp         ;Stack sÑubern
                pea       version(pc)
                move.w    #9,-(sp)
                trap      #1
                addq.w    #6,sp
                pea       mid_text(pc)
                move.w    #9,-(sp)
                trap      #1
                addq.w    #6,sp
                pea       datum(pc)
                move.w    #9,-(sp)
                trap      #1
                addq.w    #6,sp
                pea       end_text(pc)
                move.w    #9,-(sp)
                trap      #1
                addq.w    #6,sp
;Ende muss nicht sein

                .data 
start_text:     .dc.b 13,10,27,'J',27,'p'
                .dc.b ' Bootsektor-Lader fÅr HD-FORMAT '
                .dc.b 27,'q',13,10,' V',0
mid_text:       .dc.b ' (C) T. Muthmann ',0
end_text:       .dc.b 13,10,10,0

