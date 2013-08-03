
;******************************************************************************
;*                                                                            *
;*   Insh_Allah's Libraries        Rev. 2.0         (c) Feb. 1994             *
;*                                                                            *
;*   This is a file from one of the Insh_Allah Libraries for                  *
;*   Turbo C and Pure C on Atari and MS DOS Systems.                          *
;*   This code is public domain from begin to end. Use it at your will.       *
;*                                                                            *
;*   Authors:  Insh_Allah, Richard O'Keefe (lots of string stuff),            *
;*             D.A. Gwyn (alloca) and other unanymous authors who             *
;*             wrote the library-functions for the GNU libraries              *
;*             (time, random, printf() and scanf() basics.)                   *
;*                                                                            *
;******************************************************************************/

;******************************************************************************
;
;    (USAGE)
;
; SYNOPSYS:
;
;   unsigned long wortel(unsigned long value);
;
; WHERE:
;
;   extra\addition.h
;
; SHORT DESCRIPTION:
;
;   unsigned long wortel(unsigned long value);
;      Calculate integer Square Root (SQRT) ULTRA-FAST for 32-bit values
;
; DESCRIPTION:
;
;   unsigned long wortel(unsigned long value);
;
;      This function is an highly-optimized version for an extremely OLD but
;      dangerously FAST algorithm for calculating the Square Root. In old times,
;      when nobody but some odd philosophers had heard about computers, people
;      had to calculate, so they needed FAST algorithms. This one is saved
;      through the memory of my parents for me (Insh_Allah). Mr Ni! did the
;      optimized ASM code here but the algorithm isn't harmed.
;
;      Let mew give you an example for the decimal cipher system we run with:
;
;        SQRT(10000000) = ????
;
;      Well, take the decimal point and devide the number in part of two
;      ciphers like this:
;
;        SQRT( 10 | 00 | 00 | 00 |. 00 ...... ) = ???
;
;      Take the Most Significant part and search the highest possible Square
;      value (will NEVER EXCEED 9**2 = 81 ;-)) and use this as 'preliminairy
;      answer 'ANS': in our example, 'ANS' will be '3' then! Next you
;      substract it from the original value like this (just the same way you
;      learned large divisions at primary school!) and PULL IN the next block
;      of two ciphers:
;
;        SQRT( 10 | 00 | 00 | 00 |. 00 ...... ) = 3???
;        3**2= 09 -  .
;             ----   .
;              01   00
;
;      Now multiply 'ANS' by 2 and put a '.' behind it, multiplied by '.'
;      (dot-calculus: search the highest value which can be filkled in at the
;      dot so the result is equal or smaller than the remainder of the last
;      substraction&pull-in:
;
;        SQRT( 10 | 00 | 00 | 00 |. 00 ...... ) = 31??
;             ..........                           ^
;                 0100                             |
;      6.*.=        61     -> 61*1=61   -----------+
;                ------ -
;                   39   00
;
;      and so on, untill you get a zero remainder or you like to quit when
;      accuracy is high enough. (ANS will be about 3162.2....)
;
;      Now this can be proven mathematically (take (10a+b)**2 ==
;      100(a**2)+20ab+(b**2) : 'a' are the ciphers for tens, hunderds, etc.
;      and 'b' are the 'ones' : what you do is 'search largest square' or
;      'a**2' and substract it, remaining 20ab+(b**2), which is decremented
;      when you take ANS ('a' here!), multiply it by 2 (NO! This is the trick
;      here! ;-]]] You multiply by >>>20<<< since you threw in that dot,
;      remember! (3*2=6 but what you did was (60+.)*.=??? to look for the
;      next digit!) and take out the 20ab+(b**2) :: (20a+b)*b == 20ab+(b**2)
;
;      Now ofcourse you mathematicians do is with Summa(a(n)*(10**n)) so
;      every a(n) is a digit in your number, but that's trivial. Computers
;      benefit because they talk BINARY: Try to redesign this scheme in
;      binary: (2a+b)**2 -> 4(a**2)+4ab+(b**2) so all you have to do is take
;      clusters of TWO bits, start by looking for the largest square which
;      can be either '0' or '1` (how easy,huhuhuh ;-))) and continue from
;      there: to find the next digit, you take ANS, and.... (4ab+(b**2))\b =
;      4a+b ---> (SMILE) shift ANS left 2 bits (== times 4) and add
;      000000000001: the 'dot' can either be '1' or '0': if the 'remainder is
;      too small to fit the '1' in the dot, it's '0', isn't it?! so you take
;      this value, compare it with the remainder and is it's OK, you shift in
;      a '1` into ANS, otherwise you shift in a '0', and adapt the remainder
;      accordingly, at last shifting in 2 extra bits from the original value
;      to be taken the square root from!
;
;      Oh, one other note: every 2-bit cluster adds one binary digit in the
;      answer: 32 bit in -> 16 result out.
;
;      Now all this craptalk from a bloody foreigner is quite obscure, so
;      let's enlighten this bit by an example: everybody knows that SQRT(81)
;      = 9, so SQRT(1010001b) = 1001b, shouldn't it?
;
;      ORIGINAL                                           ANS
;
;      01 01 00 01                                        ----
;               10 -> 1 squared                           1---
;      01
;     ----
;      00 01      1<<2 => 10.*. -> compare with 101
;                 0001 >= 0101 NO ->                      10--
;      00 00
;     -------
;         01 00     10<<2 => 100.*. -> compare with 1001
;                   0100 >= 1001 NO ->                    100-
;         00 00
;        -------
;         01 00 01   100<<2 => 1000.*. -> comapre with 10001
;                    010001 >= 10001 YES ->               1001
;         01 00 01
;        ----------
;         00 00 00.00                ->                   1001.
;                 .............................. ->       1001.000000000000000
;
;                 == 9(dec)
;
;      Another example?
;
;         SQRT(174) = 13.19... == 13 with remainder 5
;
;      ORIGINAL                                           ANS
;
;      10 10 11 10                                        ----
;                       10 > 1 YES (1 square)             1---
;      01
;     ----
;      01 10           1<<2 => REMAINDER >= 101 ? YES ->  11--
;      01 01
;     -------
;         01 11       11<<2 => REM. >= 1101 ? NO ->       110-
;
;         01 11 10    110<<2 => reM. >= 11001 ? YES ->    1101
;         01 10 01
;        ----------
;            01 01  == 5(dec)
;
;            01 01.00   1101<<2 => REM >= 110101 ? NO ->  1101.0
;
;            01 01.00 00 11010<<2+1 -> >= 1101001 ? NO -> 1101.00
;
;            01 01.000000   >= 11010001 ? YES ->          1101.001
;            00 11.010001
;           --------------
;               10.00111100 >= 110100101 ? YES ->         1101.0011
;                1.10100101
;             --------------
;                0 10010111 >= 1101001101 ? NO ->         1101.00110
;
;            --> ANS = 13.0 + .125 + .0625  (tolerance: +0.015625/-0.000000)
;                    = 13.1875      (absolute tolerance: 13.203125/13.1875)
;
;         Now hear this: SQRT(174) = (according to Japanese calculator, so
;         it might cheat ;-))) = 13.1909...
;
;         Did I hear somebody say: "Huh, could've invented that one myself!"
;         :-)
;
;    Now the last example showed how to do extend into floating/fixed point:
;    it's a breeze, besides accurate: unlimited accuracy, ultra-fast
;    iteration, compared to ANY algorithm tought in regular computation courses
;    as far as I've seen/heard about 'em.
;
; RETURN VALUE:
;
;    Returns the square root (rounded to the nearest lower integer) of the
;    32-bit input value.
;
; NOTES:
;
;    Only implemented for ATARI systems. C portable code will be introduced
;    at the next version of this library (I hope ;-))
;
; SEE ALSO:
;
;   sqrt()
;   #include <extra\addition.h>
;
;

                XDEF  wortel

; unsigned long wortel(unsigned long value);

						    TEXT
						      
; Aanroep: D0: Long Int
; Return:  D0: SQRT(D0)
;
; Trekt de wortel uit de long integer D0, antwoord staat weer in D0
;

wortel:
if 1
                move.l  d3,a0
                move.l  #$40000000,d1   ; mask
                moveq   #0,d2           ; result=0
loop:
                move.l  d2,d3           ; tmp=result
                add.l   d1,d3           ; tmp+=mask
                lsr.l   #1,d2           ; result>>=1
                cmp.l   d3,d0           ; x-tmp<0?
                bcs.s   cont            ; yep
                sub.l   d3,d0           ; x-=tmp
                add.l   d1,d2           ; result+=mask
cont:
                lsr.l   #2,d1           ; mask>>=2;
                bne.s   loop            ; nogmal
                move.l  d2,d0           ; d0=result
                move.l  a0,d3
                rts                     ; Einde

; the smallest squareroot routine up till now (very slow)
else
                moveq   #-1,d1
loop:
                addq.l  #2,d1
                sub.l   d1,d0
                bcc.s   loop
                lsr.l   #1,d1
                move.l  d1,d0
                rts
endif
                END




