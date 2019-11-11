* STE SIMM mixer by David Hoggan
* Lets STE configure 2.5 Megs properly
* MUST BE FIRST IN AUTO FOLDER!

* This program asssumes 2Mb in bank 0 and 0.5Mb in bank 1.
* It has been found that the other way around doesn't work
* - the MMU configures to a 1Mb machine.

* Install your SIMMs as follows:
*
* (back of STE)
*
* |--  1meg SIMM  --|
* |-- .5meg SIMM  --|
* |--  1meg SIMM  --|
* |-- .5meg SIMM  --|
*
* (front of STE)

    clr.l   -(sp)
    move.w  #32,-(sp)       Switch to super mode
    trap    #1
    addq.l  #6,sp

    cmp.l   #$280000,$42E   RAM <= 2.5 megs?
    ble     already         If so, nothing to do
    cmp.b   #9,$424         Is it installed properly?
    bne     already         If so, nothing to do

    move.l  #$280000,$42E   Set phystop
    move.l  $4F2,a0         Find reset address
    jmp     (a0)            Reset system

already: move.l d0,-(sp)        Returned stack
    move.w  #32,-(sp)       Switch back to user mode
    trap    #1
    addq.l  #6,sp
    clr.w   -(sp)           Back to TOS
    trap    #1
