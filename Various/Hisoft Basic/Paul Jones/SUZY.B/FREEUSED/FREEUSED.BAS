'This Sub program requires a drive letter to be passed to the 
'sub in DRIVE$ the letter can be Upper or lower case.
'the free bytes of the drive will be returned in Free&
'the used bytes will be returned in Used&.
'This routine is PowerNet compatible.
'Writen by Chris Roberts @ DragonWare Software Inc.
'This code is in the public domain.

SUB DiskFreeUsed(free&,used&,DRIVE$)
SHARED free&,used&   
LOCAL buffer&(4),drive,Fclusters&,Tclusters&,BSECTOR&,SPCLUSTER&,tmp&
LET drive=ASC(UCASE$(drive$))-64      'get drive number
CALL dfree(buffer&(),drive)           'Read drive's FAT
LET fclusters&=buffer&(0)             'get free clusters
LET tclusters&=buffer&(1)             'get total clusters of drive
LET bsector&=buffer&(2)               'get sector size
LET spcluster&=buffer&(3)             'get cluster size
LET tmp&=bsector&*spcluster&          'get bytes per cluster
LET free&=fclusters&*tmp&             'find the free bytes
LET used&=tclusters&-fclusters&*tmp&  'find the used bytes on drive
END SUB