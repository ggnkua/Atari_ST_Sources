( Sparrow SCSI Words )
( 91.10.31  atari!jtittsler )

hex 

: wr  ( val reg -- )         ( write 'val' to 5380 register )
   88 + wdl wdc ;

: rr  ( reg -- val )         ( read from 5380 register )
   88 + wdl rdc ;

: sreset ( -- )              ( reset the SCSI bus )
   80 1 wr  30 delay         ( assert reset )
   0 1 wr   30 delay         ( deassert reset )
   begin 7 rr drop 5 rr 10 and 0= until ;   ( clear interrupts that result )

: select ( devid -- )        ( select the specified SCSI device, no arb )
   0 3 wr
   0 4 wr   c 1 wr   0 wr
   5 1 wr   2 rr fe and 2 wr
            1 rr f7 and 1 wr
   begin 4 rr 40 and until 
            1 rr fa and 1 wr ;

: doack  ( -- )              ( assert ACK, wait for REQ to go away, clear ACK)
   1 rr 11 or 1 wr
   begin 4 rr 20 and 0= until
   1 rr ef and 1 wr ;

( send command to drive, except for final control byte )
: cmd  ( #blocks lsb xsb msb cmd -- #blocks )
   0 wr  2 3 wr  1 1 wr  doack
   swap rot 3 0 do   0 wr doack  loop
   dup 0 wr doack ;

: w4irq  ( -- )         ( wait for 5380 to assert HDIRQ )
   begin gpip c@io 20 and 0= until ;

: sread   ( #blocks lsb xsb msb -- status )
   7 rr drop            ( clear potential interrupt )
   1 select             ( select unit 0 )
   8 cmd                ( issue READ command )
   190 wdl 90 wdl wdc   ( set the number of blocks to DMA )
   0 0 wr doack         ( write final command byte to drive )
   1 3 wr 2 2 wr        ( data out phase )
   0 7 wr 0 wdl
   w4irq 7 rr drop      ( wait for interrupt, and clear it )
   0 3 wr  0 rr ff and doack  ( get status byte )
   w4irq doack ;        ( wait for, ack, and ignore the message byte )

: swrite  ( #blocks lsb xsb msb -- status )
   7 rr drop            ( clear potential pending interrupt )
   cr
   1 select             ( select the drive )
   ."  selected"
   0a cmd               ( issue the command )
   ."  commanded"
   190 wdl
   ."  190"
   wdc                  ( set number of blocks to DMA )
   ."  nonzero cnt"
   100 wdl
   100 0 wr doack       ( write final command byte to drive )
   101 1 wr  100 3 wr  102 2 wr  100 5 wr
   ."  wait4irq"
   w4irq
   ."  status"
   88 wdl 0 3 wr
   7 rr drop 0 3 wr
   0 rr ff and doack    ( get status byte )
   ."  message"
   w4irq doack
   ."  complete" ;      ( wait for, ack, and ignore the message byte )
