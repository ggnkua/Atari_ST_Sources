*
* This program echoes its parameter line to the console
*
* It is used as an example for DEBUG+
*
         TEXT

space    EQU      32

start
         move.l   4(a7),a0       ; base page
         lea      $80(a0),a0     ; parmeter line
         clr.w    d0
         move.b   (a0)+,d0       ; length of paramter line
         clr.b    0(a0,d0)       ; append null byte to parameter line
loop
         tst.b    (a0)           ; have we come to the end
         beq.s    error
         cmpi.b   #space,(a0)    ; ignore leading spaces
         bne.s    echo
         add.l    #1,a0
         bra.s    loop
error
         lea      bad,a1         ; no parameter line
         bsr      puts
         move.w   #1,d0
         bsr      exit
echo
         lea      tag,a1         ; output 'ECHO>'
         bsr      puts
         move.l   a0,a1          ; output the parameter line
         bsr      puts
         lea      newline,a1     ; output a newline
         bsr      puts
         clr.w    d0
         bsr      exit
*
* Output a string pointed to by A1
*
puts
         move.l   a1,-(a7)
         move.w   #9,-(a7)
         trap     #1
         addq     #6,a7
         rts
*
* Exit with return code held in D0
*
exit
         move.w   d0,-(a7)
         move.w   #$4C,-(a7)
         trap     #1
*
* Strings
*
         DATA

bad      DC.B     'No paramter line given',$D,$A,0
tag      DC.B     'ECHO> ',0
newline  DC.B     $D,$A,0

         END
