LOG F:\LOGS\WHATARC.LOG
SCREEN 200
ARC_X K:\BT\ARC.TTP xo %1\%2 %3\%4
ZIP_X K:\BT\STZIP.TTP -x %1\%2 %3\
LZH_X K:\BT\LZH201K.TTP x %1\%2 %3\
ARJ_X K:\BT\UNARJ.TTP %1\%2 %3\%4
ARC_A K:\BT\ARC.TTP m %1\%2 %3\%4
LZH_A K:\BT\LZH201K.TTP m -m %1\%2 %3\%4
ZIP_A K:\BT\STZIP.TTP -a -m %1\%2 %3\%4
ARJ_A K:\BT\ARC.TTP m %1\%2 %3\%4
DEFAULT ARCmail
SEND 1:3817/1.0 ZIPmail              ; Tim Flynn 
SEND 1:3817/2.0 ZIPmail              ; Garald Harvey (my Host)
SEND 1:3817/12.0 ZIPmail             ; Mark Griggs
SEND 1:3817/13.0 ZIPmail             ; Robert Burgett
SEND 1:231/370.0 LZHmail             ; Bill Jones
SEND 1:347/11.0 LZHmail              ; Pat Moffit
SEND 1:138/162.0 LZHmail             ; Bryan Lane
SEND 1:206/2703.0 LZHmail            ; Brian Hall, FIDOdoor support BBS
NODUPS yes
DELPKT no

