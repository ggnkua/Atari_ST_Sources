						EXPORT	Dreadlabel
						EXPORT	Psetpriority
						EXPORT	Pgetpriority

						TEXT

;long Dreadlabel(const char *path, char *label, int length);
Dreadlabel: move.w d0,-(sp)
            move.l a1,-(sp)
            move.l a0,-(sp)
            move.w #338,-(sp)
            trap   #1
            lea    12(sp),sp
            rts

Psetpriority:
				move.w  d0,-(sp)
				move.w  d1,-(sp)
				move.w  0,-(sp)			/* Which is set always to PRIO_PROCESS	*/
				move.w  #$0159,-(sp)
				trap    #1
				addq.l  #8,sp

Pgetpriority:
				move.w  d0,-(sp)
				move.w  0,-(sp)			/* Which is set always to PRIO_PROCESS	*/
				move.w  #$0158,-(sp)
				trap    #1
				addq.l  #8,sp

            END

