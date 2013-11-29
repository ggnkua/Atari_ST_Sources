						EXPORT	Dreadlabel

						TEXT

;long Dreadlabel(const char *path, char *label, int length);
Dreadlabel: move.w d0,-(sp)
            move.l a1,-(sp)
            move.l a0,-(sp)
            move.w #338,-(sp)
            trap   #1
            lea    12(sp),sp
            rts
            
            END
