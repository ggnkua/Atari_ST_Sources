* ATAPI extensions thing keys. This file is to be included in software
* using the ATAPI extensions thing.

********************************************************************************
* Offset to start of vectors table. Each "entry" (these are in fact JMP
* instructions) are 6 bytes long and is relative to the thing linkage block
* base address (as returned in A2 after a SMS.UTHG call).

ATP_VECTS equ       $100

* Vectors (JMP branches) for ATAPI extensions:

ATP_JIDEN equ       ATP_VECTS+0
ATP_JRSET equ       ATP_VECTS+6
ATP_JATPK equ       ATP_VECTS+12
ATP_JANPK equ       ATP_VECTS+18
ATP_JZPKT equ       ATP_VECTS+24
ATP_JQPKT equ       ATP_VECTS+30
ATP_JUQPK equ       ATP_VECTS+36
ATP_JRUNQ equ       ATP_VECTS+42
ATP_JDSNS equ       ATP_VECTS+48
ATP_JWPCC equ       ATP_VECTS+54
ATP_JFEAT equ       ATP_VECTS+60
ATP_JSLEP equ       ATP_VECTS+66
ATP_JSTBY equ       ATP_VECTS+72
ATP_NIMP1 equ       ATP_VECTS+78
ATP_NIMP2 equ       ATP_VECTS+84
ATP_NIMP3 equ       ATP_VECTS+90

********************************************************************************
* ATAPI packets keys:

* Offsets in packet header:

PKT_LINK  equ       0                             Link to next packet.
PKT_FLAGS equ       4                             Various flags (byte).
PKT_DRIVE equ       5                             Associated drive number.
PKT_STATS equ       6                             Packet command status (byte).
PKT_ERROR equ       7                             Packet command error (byte).
PKT_SAVE1 equ       8                             Save area for status+error.
PKT_BUFF  equ       10                            Address of buffer.
PKT_BUFLN equ       14                            Length of buffer.
PKT_SKIP  equ       18                            Nb of leading bytes to skip.
PKT_DDONE equ       22                            Nb bytes already transfered.
PKT_POSTP equ       26                            Post processing routine.
PKT_DATA  equ       30                            Actual packet data.

PKT_LENGT equ       48                            Total length of packet+header.

* PKT_FLAGS bits:

PKT..TRNS equ       0                             Set for transient packets.
PKT..AERR equ       4                             Set for ATA (not ATAPI) error.
PKT..SENT equ       5                             Packet command sent flag.
PKT..DXCH equ       6                             Packet data exchanged flag.
PKT..COMP equ       7                             Packet command completed flag.

* PKT_DRIVE bits:

PKT..SLAV equ       0                             Set for slave drv addressing.
PKT..DRIV equ       %00000111                     Mask for drive number.
