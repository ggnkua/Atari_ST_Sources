                btst    #1,$FFFFA202.w  ;waitdsptorecieve
                beq.s   *-8
                btst    #0,$FFFFA202.w  ;waitdsptosend
                beq.s   *-8
