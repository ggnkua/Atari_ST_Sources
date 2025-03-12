*function trap111(var msg:msg_typ):integer;
                export  trap111
trap111:        movea.l 4(SP),A0
				move.l  A0,-(SP)    ;fill
                move.w  #111,-(SP)      ;nummer 111
                trap    #1
				addq    #6,SP
				rts
                END
