.EXPORT		my_critic

.text

.EVEN

my_critic:

move.w 4(sp),d0
ext.l d0
rts

.end
