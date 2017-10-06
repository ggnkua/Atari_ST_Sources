#::=# Thue program to add two binary numbers.
#::=# by Frédéric van der Plancke 2000, public domain.
#::=# 
#::=# Should work regardless of rule execution order.
#::=# format:
#::=#   BEFORE: _digitsoffirstnumber_+_digitsofsecondnumber_
#::=#   AFTER:  _digitsofsum_
#::=# warning:
#::=#   adding more than two binary numbers at once won't work.
#::=# 
#::=# Sorry, no comments; I think figuring how this works is
#::=# an interesting challenge... (a not too difficult one, IMHO.)
#::=# Have fun !

_+_::=<+|+>

+>0::=0?+>
+>1::=1?+>

+>_::=<@0C_

0<+::=<+0?
1<+::=<+1?
_<+::=_

0@0?::=0?0@
0@1?::=1?0@
1@0?::=0?1@
1@1?::=1?1@
0@|::=|0@
1@|::=|1@

0@0@0C::=<@0C0
0@0@1C::=<@0C1
0@1@0C::=<@0C1
0@1@1C::=<@1C0
1@0@0C::=<@0C1
1@0@1C::=<@1C0
1@1@0C::=<@1C0
1@1@1C::=<@1C1

0?<@::=<?0@
1?<@::=<?1@
0?<?::=<?0?
1?<?::=<?1?
|<?::=<@|
_<?::=_

0?|<@::=|0@0@
1?|<@::=|1@0@

_<@|::=_|0@

_|<@::=_
_0C::=_
_1C::=_1

::=


#::=#-------- replace next line by whatever you want;
#::=#         e.g. you can replace a number with ':::' to
#::=#         read it from stdin.

_111100_+_10010_
