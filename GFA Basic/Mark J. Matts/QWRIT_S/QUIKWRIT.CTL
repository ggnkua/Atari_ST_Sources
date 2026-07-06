;
; This is used to read your system files. You MUST use this command
;
systempath h:\qbbs
;
; This is the path where the text files will be kept. If any
; of the folder do not exist Quick-Writer will create them.
;
textpath f:\qbbs\utils\qwikwrit\text\
;
; Title names a topic, the filename and an optional tearline
; the format of it is TITLE <title> <filename> <tearline>
; In the title *ALL* spaces MUST be replaced by an underscore
; You can have upto 9 seperate TITLE keywords. Please refer
; to the DOC's for an explanation of extra tearline parameters
;
title Once_upon_a_time onceupon ----< %name (%date) >----
title Modem_Monsters modemmon %ctr----< %name (%time %date) >---
title The_Little_Frog frog %full*
title BBS_News bbsnews
title The_Good,_The_Bad_&_The_Ugly companys %full*
title Politics_your_views politics ---( Written by %name [%date %time] )---

