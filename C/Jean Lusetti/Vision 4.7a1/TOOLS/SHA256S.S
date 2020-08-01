; Accumulate SHA-256 hash
; Port from https://github.com/Leffmann/SHA256
  .EXPORT SHA256Acc

; void SHA256Acc(void* data, uint32* hash, uint32 count)
; Unlike other PURE C calls, this one is passing parameters to the stack (cdecl)
SHA256Acc:
               movem.l   d2-d7/a2-a6, -(sp)
               movem.l   (12*4, sp), a0/a3/a6
               bra       .loop

               ; accumulate SHA-256 hash of 'count' number of 64-byte blocks

.hash:         move.l    a0, -(sp)

               ; copy the next block from data[] to w[] and pre-process it

               sub       #256, sp
               movem.l   (a0)+, d0-d7
               movem.l   d0-d7, (sp)
               movem.l   (a0)+, d0-d7
               movem.l   d0-d7, (32, sp)
               lea       (16*4, sp), a0
               lea       (-2*4, a0), a5
               lea       (-7*4, a0), a4
               move.l    sp, a2

               ;  i = 16
               ; A0 = w[i]
               ; A5 = w[i-2]
               ; A4 = w[i-7]
               ; A2 = w[i-16]

               moveq     #10, d3
               moveq     #48-1, d7

.pre:          ; t = w[i-16] + w[i-7]

               move.l    (a2)+, d0
               add.l     (a4)+, d0

               ; t += (w[i-15] ror 7) xor (w[i-15] rol 14) xor (w[i-15] lsr 3)

               move.l    (a2), d1
               move.l    d1, d2
               lsr.l     #3, d1
               swap      d2
               ror.l     #2, d2
               eor.l     d2, d1
               swap      d2
               ror.l     #5, d2
               eor.l     d2, d1
               add.l     d1, d0

               ; t += (w[i-2] rol 15) xor (w[i-2] rol 13) xor (w[i-2] lsr 10)

               move.l    (a5)+, d1
               move.l    d1, d2
               lsr.l     d3, d1
               swap      d2
               ror.l     #1, d2
               eor.l     d2, d1
               ror.l     #2, d2
               eor.l     d2, d1
               add.l     d1, d0

               ; w[i] = t

               move.l    d0, (a0)+

               dbf       d7, .pre

               movem.l   (a3), d0-d4/a0-a2
               lea       .constants, a5

               ; D0-D4/A0-A2 = h[0] to h[7]

               moveq     #64-1, d7

.compress:     ; t = (h[4] ror 6) xor (h[4] ror 11) xor (h[4] rol 7)

               move.l    d4, d5
               ror.l     #6, d5
               move.l    d5, d6
               ror.l     #5, d6
               eor.l     d6, d5
               move.l    d4, d6
               rol.l     #7, d6
               eor.l     d6, d5
               move.l    d5, a4

               ; t += (h[4] and h[5]) xor ((not h[4]) and h[6])

               move.l    d4, d6
               not.l     d6
               move.l    a1, d5
               and.l     d5, d6
               move.l    a0, d5
               and.l     d4, d5
               eor.l     d6, d5
               add.l     d5, a4

               ; t += h[7] + constants[i] + w[i]
               ; h[3] += t

               add.l     a2, a4
               add.l     (a5)+, a4
               add.l     (sp)+, a4
               add.l     a4, d3

               ; t += (h[0] ror 2) xor (h[0] ror 13) xor (h[0] rol 10)

               move.l    d0, d5
               ror.l     #2, d5
               move.l    d5, d6
               swap      d6
               ror.l     #4, d6
               eor.l     d6, d5
               move.l    d0, d6
               swap      d6
               rol.l     #3, d6
               eor.l     d6, d5
               add.l     d5, a4

               ; t += (h[0] and h[1]) xor (h[0] and h[2]) xor (h[1] and h[2])

               move.l    d0, d5
               and.l     d1, d5
               move.l    d0, d6
               and.l     d2, d6
               eor.l     d6, d5
               move.l    d1, d6
               and.l     d2, d6
               eor.l     d6, d5
               add.l     d5, a4

               ; shift the current hash, and insert t at h[0]

               move.l    a1, a2
               move.l    a0, a1
               move.l    d4, a0
               move.l    d3, d4
               move.l    d2, d3
               move.l    d1, d2
               move.l    d0, d1
               move.l    a4, d0

               dbf       d7, .compress

               ; accumulate
               ;
               ; A3 = hash[0]

               add.l     d0, (a3)+
               add.l     d1, (a3)+
               add.l     d2, (a3)+
               add.l     d3, (a3)+
               add.l     d4, (a3)+
               move.l    a0, d0
               add.l     d0, (a3)+
               move.l    a1, d0
               add.l     d0, (a3)+
               move.l    a2, d0
               add.l     d0, (a3)+
               sub       #32, a3

               move.l    (sp)+, a0
               add       #64, a0

               sub       #1, a6
.loop:         cmp.l     #0, a6
               bne       .hash

               movem.l   (sp)+, d2-d7/a2-a6
               rts


               .EVEN
.constants:    dc.l $428a2f98, $71374491, $b5c0fbcf, $e9b5dba5
               dc.l $3956c25b, $59f111f1, $923f82a4, $ab1c5ed5
               dc.l $d807aa98, $12835b01, $243185be, $550c7dc3
               dc.l $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174
               dc.l $e49b69c1, $efbe4786, $0fc19dc6, $240ca1cc
               dc.l $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da
               dc.l $983e5152, $a831c66d, $b00327c8, $bf597fc7
               dc.l $c6e00bf3, $d5a79147, $06ca6351, $14292967
               dc.l $27b70a85, $2e1b2138, $4d2c6dfc, $53380d13
               dc.l $650a7354, $766a0abb, $81c2c92e, $92722c85
               dc.l $a2bfe8a1, $a81a664b, $c24b8b70, $c76c51a3
               dc.l $d192e819, $d6990624, $f40e3585, $106aa070
               dc.l $19a4c116, $1e376c08, $2748774c, $34b0bcb5
               dc.l $391c0cb3, $4ed8aa4a, $5b9cca4f, $682e6ff3
               dc.l $748f82ee, $78a5636f, $84c87814, $8cc70208
               dc.l $90befffa, $a4506ceb, $bef9a3f7, $c67178f2
