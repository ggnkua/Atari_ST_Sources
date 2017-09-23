************************
* Encryption de la cle *
************************

    .EXPORT KeyEncrypt, KeyDecrypt


*****************************
* long KeyEncrypt(long key) *
*  D0                 D0    *
*****************************
KeyEncrypt:
    ROL.L   #7,D0
    NEG.L   D0
    RTS

*****************************
* long KeyDecrypt(long key) *
*  D0                 D0    *
*****************************
KeyDecrypt:
    NEG.L   D0
    ROR.L   #7,D0
    RTS

