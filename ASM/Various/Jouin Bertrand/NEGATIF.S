     section Text

     * calcul de x+(-x)
     move.w #10,d0

     move.w d0,d1
     not.w d1       * x complement‚
     addq.w #1,d1   * -x dans d1
     add.w d0,d1    * resultat de
                    * x-x dans d1
     move.w #0,-(a7)
     trap #1

