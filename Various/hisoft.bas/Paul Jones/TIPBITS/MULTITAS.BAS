DEFINT a-z
LIBRARY "gemaes","gemvdi","gemdos","bios","xbios","speedo","falcon"
'$include GEMAES.BH
' The multitasking library source by Paul Jones 1997
' This code may be included in your own programs for free

FUNCTION aesversion
aesversion=PEEKW(PEEKL(GB+4))
END FUNCTION

FUNCTION max_progs
max_progs=PEEKW(PEEKL(GB+4)+ap_count)
END FUNCTION

FUNCTION appl_id
appl_id=PEEKW(PEEKL(GB+4)+ap_id)
END FUNCTION

SUB Multitask_name (name$)
STATIC mpos
IF max_progs=-1 OR aesversion>=&H410 THEN mpos=menu_register(appl_id,name$)
END SUB


PRINT aesversion
PRINT max_progs
PRINT appl_id
CALL Multitask_name (name$)
PRINT name$
