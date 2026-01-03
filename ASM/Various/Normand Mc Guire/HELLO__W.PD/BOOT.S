
*       boot - boot program that prints "Hello, world", forever
*
*                                               Author: Normand Mc Guire

GEMDOS  equ     1
Cconws  equ     9

        .data
stty    dc.b    $1b,'v'                 * enable wrap-around
message dc.b    'Hello, world ',0       * well-known string

        .text
boot:
        lea     -2(pc),a6       * set boot program load address into A6
        pea     stty(a6)        * enable wrap around when printing strings
        move.w  #Cconws,-(sp)   
        trap    #GEMDOS
        addq.l  #6,sp

loop:
        pea     message(a6)     * print message forever
        move.w  #Cconws,-(sp)
        trap    #GEMDOS
        addq.l  #6,sp
        bra     loop
        end
