\ this is the title that is printed when forth executes

: (cold-hook  ( -- )
 (cold-hook
 cr  ." FORTH-83  version 1.0 as of November 17 1985 "  cr
	." distributed by the San Leandro computer club " cr
;

' (cold-hook is cold-hook
