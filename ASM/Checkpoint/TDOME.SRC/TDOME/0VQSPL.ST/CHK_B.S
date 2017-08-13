sector_buffer_address:DC.L 0

check_Disk_B:   >PART

*    DC.L $4AFC4E71

db_loop:
                movea.l sector_buffer_address(PC),A0
                lea     boot_sector_struct(PC),A1
                moveq   #load__sectors__,D0
                bsr     __KernelCall

                not.w   $FFFF8240.w

                movea.l sector_buffer_address(PC),A0
                cmpi.l  #"TD#2",$0020(A0)
                bne.s   db_loop
disk_b_ok:
                clr.w   $FFFF8240.w
                rts

boot_sector_struct:
                DC.W 0          ; track
                DC.W 1          ; sector
                DC.W 0          ; side
                DC.W 1          ; count
                ENDPART

