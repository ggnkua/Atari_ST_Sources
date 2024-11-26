          .globl _vq_gdos

GEM       = 2

_vq_gdos: moveq.l #$FE,D0
          trap    #GEM
          addq.w  #$2,D0
          rts

          .end

