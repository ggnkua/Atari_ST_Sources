;Sammlung der Fehlercodes

E_OK      = 0       ;no error

;BIOS errors
EDRVNR    = -2      ;drive not ready
EUNCMD    = -3      ;unknown command
E_CRC     = -4      ;crc error
EBADRQ    = -5      ;bad request
E_SEEK    = -6      ;seek error
EMEDIA    = -7      ;unknown media
ESECNF    = -8      ;sector not found
EPAPER    = -9      ;out of paper
EWRITF    = -10     ;write failure
EREADF    = -11     ;read failure
EWRPRO    = -13     ;media write protected
E_CHNG    = -14     ;media changed
EUNDEV    = -15     ;unknown device
EBADSF    = -16     ;bad sectors on format
EOTHER    = -17     ;request disk swap

;GEMDOS errors
EINVFN    = -32     ;invalid function number
EFILNF    = -33     ;file not found
EPTHNF    = -34     ;path not found
ENHNDL    = -35     ;no more handles
EACCDN    = -36     ;access denied
EIHNDL    = -37     ;invalid handle
ENSMEM    = -39     ;not enough memory
EIMBA     = -40     ;invalid memory block
EDRIVE    = -46     ;invalid drive id
ENSAME    = -48     ;rename to different drive
ENMFIL    = -49     ;no more files
ERANGE    = -64     ;range error
EINTRN    = -65     ;internal error
EPLFMT    = -66     ;bad executable format
ENOEXEC   = EPLFMT
EGSBF     = -67     ;memory block growth failure

ENAMETOOLONG        = ERANGE         ;a filename component is too long
ELOOP     = -80     ;too many symbolic links

EDOM      = -100    ;domain error
EEXIST    = -101    ;file exists for (O_CREAT|O_EXCL)
EMOUNT    = -200

