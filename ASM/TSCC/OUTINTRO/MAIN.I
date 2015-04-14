; Global constants

NULL		=	0
NIL		=	0
FALSE		=	0
TRUE		=	-1


; Demo object type enumeration

		rsreset
INIT		rs.l	1	; Treat defined object as init function (Call once)
DEINIT		rs.l	1	; Same as the Init object
MAIN		rs.l	1	; Call object in a mainloop
HALT		rs.l	1	; Stop the demo
