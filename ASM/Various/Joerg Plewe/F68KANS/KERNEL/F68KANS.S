.CODE
version         EQU $19940105

.INCLUDE 'imghead.s'
* .INCLUDE 'comments.s' 
.INCLUDE 'equ.s'
.INCLUDE 'init.s'

.INCLUDE 'cmacros.s'
.INCLUDE 'code.s'


.DATA
datas:			* extremely important label!
.INCLUDE 'sysvars.s'
.INCLUDE 'dmacros.s'
.INCLUDE 'uservars.s'
.INCLUDE 'vocstack.s'
.INCLUDE 'errmsg.s'
.INCLUDE 'header.s'


.END











