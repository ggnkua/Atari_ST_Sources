;Definitionen fÅr das MacOS

;Device Manager Parameter Block Header
qLink     = 0       ;.l internally
qType     = 4       ;.w internally
ioTrap    = 6       ;.w internally
ioCmdAddr           = 8              ;.l internally
ioCompletion        = 12             ;.l completion routine
ioResult  = 16      ;.w result code
ioNamePtr           = 18             ;.l driver name
ioVRefNum           = 22             ;.w drive number

;specific to IOParam structure
ioRefNum  = 24      ;.w driver reference number
ioVersNum           = 26             ;.b not used
ioPermssn           = 27             ;.w read/write permission
ioMisc    = 28      ;.l not used
ioBuffer  = 32      ;.l pointer to data buffer
ioReqCount          = 36             ;.l requested number of bytes
ioActCount          = 40             ;.l actual number of bytes
ioPosMode           = 44             ;.w positioning mode
ioPosOffset         = 46             ;.w positioning offset

;specific to CntrlParam structure
ioCRefNum           = 24             ;.w driver reference number
csCode    = 26      ;.w type of control or status request
csParam   = 28      ;.22bytes control or status information


