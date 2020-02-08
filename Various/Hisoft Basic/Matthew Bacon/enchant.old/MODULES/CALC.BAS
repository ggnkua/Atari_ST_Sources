
' [CALC.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

CONST calc_add=1,calc_subtract=2,calc_divide=3,calc_multiply=4
CONST calc_plusorminus=5,calc_percent=6,calc_root=7,calc_SIN=8
CONST calc_COS=9,calc_TAN=10,calc_LOG=11,calc_INVLOG=12,calc_ln=13
CONST calc_INVLN=14,calc_overx=15,calc_square=16,calc_cube=17,calc_xN=18

FUNCTION calculate# (a#,b#,calc_type)
STATIC c#,d#

SELECT CASE calc_type
	CASE calc_add			' +
		calculate#=a#+b#
	CASE calc_subtract		' -
		calculate#=a#-b#
	CASE calc_divide		' ö
		calculate#=a#/b#
	CASE calc_multiply		' X
		calculate#=a#*b#
	CASE calc_plusorminus	' +/-  'a#' only
		calculate#=a#-(2*a#)
	CASE calc_percent		' %  b# % of a#
		calculate#=(a#/100)*b#
	CASE calc_root			' û 'a#' only
		calculate#=SQR(a#)
	CASE calc_SIN			' 'a#' only
		calculate#=SIN(a#/57.2957795152)
	CASE calc_COS			' 'a#' only
		calculate#=COS(a#/57.2957795152)
	CASE calc_TAN			' 'a#' only
		calculate#=TAN(a#/57.2957795152)
	CASE calc_LOG 			' 'a#' only
		calculate#=LOG10(a#)
	CASE calc_INVLOG 		' 'a#' only
		calculate#=10^a#
	CASE calc_ln 			' 'a#' only
		calculate#=LOG(a#)
	CASE calc_INVLN 		' 'a#' only
		calculate#=EXP(a#)
	CASE calc_overx			' 1/x  'a#' only
		calculate#=1/a#
	CASE calc_square		' x2  'a#' only
		calculate#=a#*a#
	CASE calc_cube			' x3  'a#' only
		calculate#=a#*a#*a#
	CASE calc_xN			' xN
		d#=1
		FOR c#=1 TO b#
			d#=d#*a#
		NEXT c#
		calculate#=d#
END SELECT
END FUNCTION


FUNCTION valid_text(BYVAL text$,BYVAL dummy)
IF LEN(text$)=dummy THEN
	Valid_Text=-1
ELSE
	Valid_Text=0
END IF
END FUNCTION


FUNCTION Valid_Digit(BYVAL value,BYVAL check, bse)
STATIC v$,c$,b$,n,l,v_v,v_c,d
' creates a check digit for a value with weight bytes chk and
' base value of bse. Returns the check digit code.

' Note that this code my be more than 1 byte (eg >9) so you
' might have to convert this down somehow.
' Also, values of each variable need to be positive. This is
' checked.

' Returns:
'  -1  Value negative
'  -2  Check digit negative
'  -3  Base value negative
'  -4  Lengths of value and check digit do not match
'        error will occur if check digit or value start with 0
'  Other values check digit (note this may include 0)

v$ = STR$(value)
IF LEFT$(v$, 1) = " " THEN
    v$ = RIGHT$(v$, LEN(v$) - 1)
ELSE
    valid_digit = -1: EXIT FUNCTION
END IF

c$ = STR$(chk)
IF LEFT$(c$, 1) = " " THEN
    c$ = RIGHT$(c$, LEN(c$) - 1)
ELSE
    valid_digit = -2: EXIT FUNCTION
END IF

b$ = STR$(bse)
IF LEFT$(b$, 1) = "-" THEN valid_digit = -3: EXIT FUNCTION

IF LEN(v$) <> LEN(c$) THEN
    valid_digit = -4
    EXIT FUNCTION
END IF

n = 0
FOR l = 1 TO LEN(v$)
   v_v = VAL(MID$(v$, l, 1))
   v_c = VAL(MID$(c$, l, 1))

   n = n + (v_v * v_c)
NEXT l

d = n MOD bse
valid_digit = bse - d
END FUNCTION


FUNCTION valid_format(txt$, code$)
STATIC a,b$,c$,valid

' N=number, L=letter, A=alpha numberic, S=space

' returns:
' 0 lengths of text and validation code different.
' 1 confired text string valid.
' -x. X contains the character position of the character that
'     doesn't apply to the validation code.

IF LEN(txt$) <> LEN(code$) THEN valid_format = 0: EXIT FUNCTION

FOR a = 1 TO LEN(txt$)
    b$ = MID$(txt$, a, 1)
    c$ = MID$(code$, a, 1)
    IF b$ <> c$ THEN
        ' ie both letters are the same, indicating possible
        ' correctness, ignore letters

        valid = 0
        SELECT CASE c$
            CASE "S"
                IF b$ <> " " THEN valid = -1
            CASE "N"
                IF ASC(b$) < 48 OR ASC(b$) > 57 THEN valid = -1
            CASE "L"
                ' capital letter (65,90)
                IF ASC(b$) < 65 OR ASC(b$) > 90 THEN valid = -1
            CASE "l"
                ' small letter (97,122)
                IF ASC(b$) < 97 OR ASC(b$) > 122 THEN valid = -1
            CASE "A"
                ' both capital and numbers
                valid = -1
                IF ASC(b$) >= 48 AND ASC(b$) <= 90 THEN
                    IF ASC(b$) <= 57 OR ASC(b$) >= 65 THEN valid = 1
                END IF
            CASE "a"
                ' both small and numbers
                valid = -1
                IF ASC(b$) >= 48 AND ASC(b$) <= 122 THEN
                    IF ASC(b$) <= 57 OR ASC(b$) >= 97 THEN valid = 1
                END IF
            CASE ELSE
                ' other characters sub-standard
                valid = -1
        END SELECT

    END IF

    IF valid = -1 THEN
'       Debug.Print valid, a
        EXIT FOR
    END IF

NEXT

IF valid = 0 THEN
    valid_format = 1
ELSE
    valid_format = VAL("-" + STR$(a))
END IF

END FUNCTION


FUNCTION valid_presence(txt$)
' checks to see if the text exists
' returns:
' 1 text exists
' 0 text doesn't exist

IF txt$ = "" THEN
    valid_presence = 0
ELSE
    valid_presence = 1
END IF

END FUNCTION

FUNCTION valid_range(num, r1, r2)
' checks to see if a number is valid. Note this is designed
' for numerate values, text characters are best checked with
' valid_format.

' r1=start value (inclusive)
' r2=end value (inclusive)
' num=number to check

' returns:
'  1 check confimed, number is range
'  0 check failed, number out of range

IF (num >= r1) AND (num <= r2) THEN
    valid_range = 1
ELSE
    valid_range = 0
End If

END FUNCTION

'[*END OF FILE*]
