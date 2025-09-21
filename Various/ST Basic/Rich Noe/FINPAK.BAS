0     ' AUTHOR:  Rich Noe             Date Created  11-23-85
1     title$=" Financial Pak "
2     title$=chr$(32)+chr$(14)+chr$(15)+title$
3     title$=title$+chr$(14)+chr$(15)+chr$(32)
4     poke systab+24,1
5     a#=gb
6     gintin=peek(a#+8)
7     poke gintin+0,peek(systab+8)
8     poke gintin+2,2
9     s#=gintin+4
10    title$=title$+chr$(0)
11    poke s#,varptr(title$)
12    gemsys(105)
13    poke systab+24,0
15    DIM Z$(5)
20    DIM M$(5)
21    PR$="####.##%"
22    V$="$$#,###,###,###.##"
23    I$="###.##%"
26    I2$="##"
27    Y$="Y":N$="N"
30    DEFDBL J,B,R,A,Q,P,T
40    fullw 2:clearw 2:gotoxy 0,0
50    PRINT
70    PRINT
80    ?"   (1) Future Value of Investment         (11) Depreciated Investment"
100   ?"   (2) Future Value of Annuity            (12) Salvage Value year end"
120   ?"   (3) Future Value of Savings            (13) Discounted Comm. Paper"
140   ?"   (4) Withdrawals From Investment        (14) Loan Principal"
160   ?"   (5) Minimum Investment for Income      (15) Loan Payment Schedules"
180   ?"   (6) Income From Investments            (16) Final Loan Payments"
190   ?"   (7) Nominal Interest Rates             (17) Remaining Loan Balance"
210   ?"   (8) Effective Interest Rates           (18) Loan Repayment periods"
230   ?"   (9) Earned Interest Table              (19) Loan Ann. Interest Rate"
250   ?"  (10) Annual Depreciation Rate           (20) Mortgage Amortization"
260   PRINT:PRINT
270   INPUT "          Select a Program by Number (0 to Exit): ";Z
280   IF Z=0 THEN 5000
290   ON Z GOTO 330,510,690,880,1100,1330,1560,1780,1960,2030,2230,2420,2610
300   IF Z>13 THEN Z1=Z-13
310   ON Z1 GOTO 2820,2980,3170,3410,3670,3850,3910
320   GOTO 40
330   GOSUB 4500
340   PRINT"                         #1 Future Value of Investment"
350   GOTOXY 1,4:INPUT "Enter the Initial Value of Investment: ";P
355   GOTOXY 45,4:PRINT USING V$;P
360   INPUT " Enter Nominal Interest Rate: ";I:GOTOXY 56,5:PRINT USING I$;I
410   PRINT:INPUT " Enter Number of Compounding Periods Each Year: ";N
415   GOTOXY 59,7:PRINT N;" PER"
420   PRINT
430   INPUT " Enter Number of Years for the Investment: ";Y:GOTOXY 59,9:PRINT Y
435   GOTOXY 59,9:PRINT Y;" YRS"
440   PRINT
450   I=I/N/100
460   T=P*(I+1)^(N*Y):PRINT
470   PRINT" Future Value of This Investment is: ";:GOTOXY 45,12:PRINT USING V$;T
475   COLOR 2,0,1:GOTOXY 46,12:PRINT USING V$;T:COLOR 1,0,1
480   GOTOXY 1,17:INPUT "Want Another Future Value Calculation (Y or N): ";ANS$
490   IF LEFT$(ANS$,1)=Y$ THEN 330 ELSE 40
510   GOSUB 4500:PRINT"                   Future Value of Regular Deposits - Annunity"
550   GOTOXY 1,3:INPUT "Enter Amount of Regular Deposit: ";R
560   GOTOXY 45,3:PRINT USING V$;R
570   GOTOXY 1,5:INPUT "Enter Nominal Interest Rate: ";I
580   GOTOXY 56,5:PRINT USING I$;I
590   PRINT:INPUT " Enter Number of Deposits Each Year: ";N:GOTOXY 59,7:PRINT N
610   PRINT:INPUT " Enter the Number of Years: ";Y:GOTOXY 59,9:PRINT Y
620   I=I/N/100
630   T=R*((I+1)^(N*Y)-1)/I
640   ?:?
650   ?:?" FUTURE VALUE IS: ";:GOTOXY 45,13:COLOR 2,0,1:PRINT USING V$;T
655   COLOR 1,0,1
660   GOTOXY 1,16:INPUT "Another Future Value Calculation (Y or N): ";ANS$
670   IF LEFT$(ANS$,1)="y" THEN 510 ELSE CLEARW 2:GOTOXY O,O: GOTO 40
690   GOSUB 4500
700   PRINT "                    Future Value of Annuity or Savings Account"
710   GOSUB 4510
720   GOTOXY 1,4:INPUT " Enter Desired Future Value:";T:GOTOXY 45,4:?USING V$;T
740   INPUT " Enter Nominal Interest Rate: ";I:GOTOXY 56,5:PRINT USING I$;I
750   PRINT:INPUT " Enter Number of Deposits Per Year: ";N:GOTOXY 59,7:PRINT N
780   PRINT:INPUT " Enter the Number of Years: ";Y:GOTOXY 59,9:PRINT Y
790   I=I/N/100
800   R=T*I/((I+1)^(N*Y)-1)
802   R$=STR$(R):T$=STR$(T)
804   L1=LEN(R$):L2=LEN(T$)
810   PRINT:PRINT:PRINT" Regular deposits of: ";:GOTOXY (22-(13-L1)),12
815   PRINT USING V$;R;:PRINT" will yield:";:PRINT USING V$;T:PRINT" in: ";
816   PRINT Y;" years"
820   GOTOXY 1,16:INPUT "Another run (Y or N): ";ANS$
830   IF LEFT$(ANS$,1)="Y" THEN 690 ELSE 40
880   GOSUB 4500:?"                      Regular Withdrawals from an Investment"
910   GOTOXY 1,2:INPUT "Amount of initial investment: ";P
915   GOTOXY 46,2:PRINT USING V$;P
920   INPUT " Enter nominal interest rate: ";I:GOTOXY 56,3:?USING I$;I
940   PRINT:INPUT " Enter the number of withdrawals each year: ";N
945   GOTOXY 59,5:PRINT N
950   PRINT:INPUT " Enter the number of years: ";Y:GOTOXY 59,7:PRINT Y
970   I=I/N/100
980   R=P*(I/((I+1)^(N*Y)-1)+I)
990   GOTOXY 1,8:PRINT" You may withdraw: ";:PRINT USING V$;R;
995   PRINT" from your account: ";N:PRINT"times per year for : ";Y;
996   PRINT" years without reducing your initial investment"
1070  GOTOXY 1,14:INPUT "Do you want another calculation (Y or N): ";ANS$
1080  IF ANS$="Y" THEN 880 ELSE 40
1100  GOSUB 4500:?"                   INVESTMENT REQ. TO PROVIDE FUTURE VALUE"
1110  GOTOXY 1,2:INPUT "Enter amount you wish to end up with: ";T
1111  GOTOXY 45,2:PRINT USING V$;T
1120  INPUT " Enter the number of compounding periods each year: ";N
1125  GOTOXY 59,3:PRINT N
1130  PRINT:INPUT " Enter the number of years for this investment: ";Y
1135  GOTOXY 59,5:PRINT Y
1140  PRINT:INPUT " Enter the nominal interest rate: ";I:GOTOXY 59,7:PRINT I
1220  I1=I
1230  I=I/N/100
1240  P=T/(I+1)^(N*Y)
1250  GOTOXY 1,12:PRINT"You must invest: ";:PRINT USING V$;P;
1255  PRINT" to yield:    ";:PRINT USING V$;T
1260  GOTOXY 1,14:INPUT "Do you want to make another calculation: ";ANS$
1270  IF ANS$="Y" THEN 1100 ELSE 40
1330  GOSUB 4500:?"                         MINIMUM INVESTMENT FOR INCOME"
1340  GOTOXY 1,2
1380  INPUT "Enter number of withdrawals each year: ";N
1385  GOTOXY 59,2:PRINT N
1390  INPUT " Enter amount of each withdrawal: ";R:GOTOXY 45,3:PRINT USING V$;R
1420  INPUT " Enter the nominal interest rate: ";I:GOTOXY 56,4:PRINT USING I$;I
1430  PRINT:INPUT " Withdrawal to occur for how many years: ";Y:GOTOXY 59,6:? Y
1450  I1=I
1460  I=I/100
1470  P=R*N/I*(1-1/((1+I/N)^(N*Y)))
1490  GOTOXY 1,12:PRINT"A minimum investment of: ";:PRINT USING V$;P;
1495  PRINT" will yield your desired return"
1500  GOTOXY 1,14:INPUT "Do you want another calculation (Y or N): ";ANS$
1505  PRINT I2
1510  IF ANS$="Y" THEN 1330 ELSE 40
1560  GOSUB 4500:PRINT"                     NOMINAL INTEREST ON INVESTMENTS"
1570  GOTOXY 1,2:INPUT "Enter the amount of the principal: ";P
1575  GOTOXY 45,2:PRINT USING V$;P
1580  INPUT " Enter total amount of investment: ";T:GOTOXY 45,3:PRINT USING V$;T
1630  INPUT " Enter the number of years of the investment: ";Y:GOTOXY 59,4:? Y
1670  PRINT:INPUT " Enter the compounding periods each year: ";N:GOTOXY 59,6:? N
1680  I2=N*((T/P)^(1/(N*Y))-1)*100
1700  GOTOXY 1,12:?"The nominal interest rate for the above parameters is: ";
1705  PRINT I2
1710  GOTOXY 1,14:INPUT "Do you want another calculation (Y or N): ";ANS$
1720  IF ANS$="Y" THEN 1560 ELSE 40
1780  GOSUB 4500:?"                        EFFECTIVE INTEREST ON INVESTMENTS"
1830  GOTOXY 1,2:INPUT "Enter the amount of the initial investment";P:GOTOXY 45,2
1835  PRINT USING V$;P
1850  INPUT " Enter the desired future value: ";T:GOTOXY 45,3:PRINT USING V$;T
1870  INPUT " Enter the life of the investment in years";Y
1875  GOTOXY 56,4:PRINT Y;"years"
1880  A=((T / P) ^ (1 / Y) - 1) * 100
1900  GOTOXY 1,12:?"The effective annual interest rate of the investment is:";
1905  PRINT USING PR$;A
1930  GOTOXY 1,14:INPUT "Do you want to run another (Y or N): ";ANS$
1935  IF LEFT$(ANS$,1)=Y$ THEN 1780 ELSE 40
1960  REM  EARNED INTEREST TABLE
1970  GOSUB 4500
1980  PRINT "#9 EARNED INTEREST TABLE FOR INVESTMENT"
2010  PRINT "  ******** UNDER CONSTRUCTION ********"
2020  FOR I = 1 TO 2000: NEXT I: GOTO 40
2030  REM  DEPRECIATION RATE ON INVESTMENT
2040  GOSUB 4500
2050  PRINT "                   ANNUAL DEPRECIATION RATE OF AN INVESTMENT"
2080  GOTOXY 1,2:INPUT "Enter the Original Price of the Item";P
2090  GOTOXY 45,2:PRINT USING V$;P
2100  INPUT " Enter the Resale Price of the Item";T:GOTOXY 45,3:PRINT USING V$;T
2120  INPUT " Enter the Item's Life in Years";Y:GOTOXY 59,4:PRINT USING I2$;Y
2140  D = 100 * (1 - (T / P) ^ (1 / Y))
2160  GOTOXY 1,12:PRINT "If You Purchased This Item for:";:PRINT USING V$;P;
2170  ?" and Sold it ";:? using I2$;Y;:?" Years Later_"
2180  PRINT " for: ";:PRINT USING V$;T;:?", the Actual Depreciation Rate is: ";
2190  PRINT USING PR$;D
2200  GOTOXY 1,15:INPUT "Another Run (Y or N): ";ANS$
2210  IF  LEFT$ (ANS$,1) = "Y" THEN 2040 ELSE 40
2230  REM  CALCULATE THE AMOUNT OF DEPREC OF AN ITEM
2240  GOSUB 4500
2250  PRINT "                        AMOUNT DEPRECIATED WITHIN A YEAR"
2270  GOTOXY 1,2:INPUT "Enter the Original Price of the Item:";P
2275  GOTOXY 45,2:PRINT USING V$;P
2290  INPUT " Enter Number of years";K%:GOTOXY 59,3:PRINT K%
2300  INPUT " What percent do you want to depreciate";I:gotoxy 59,4:print i
2310  PRINT 
2320  I = I / 100
2330  PRINT : FOR Y% = 1 TO K%
2340  D = P * I * (1 - I) ^ (Y% - 1)
2350  PRINT "YEAR #";Y%;"DEPRECIATION IS $"; D
2385  next y%
2390  PRINT : INPUT "DO YOU WANT TO RUN ANOTHER (Y/N)";Y$
2400  IF  LEFT$ (Y$,1) = "Y" THEN  2230 ELSE 40
2420  GOSUB 4500
2430  PRINT "   #12 CALCULATE THE SALVAGE VALUE"
2440  PRINT "              OF AN ITEM..."
2450  PRINT
2460  INPUT "ENTER THE ORIGINAL PRICE OF THE ITEM";P
2470  PRINT 
2480  INPUT "ENTER THE ITEM'S DEPRECIATION RATE";I
2490  PRINT 
2500  INPUT "ENTER THE NUMBER OF YEARS";K%
2510  FOR Y% = 1 TO K%
2520  S =  P * (1 - I / 100) ^ Y%
2530  PRINT "YEAR #";Y%;"SALVAGE VALUE IS $";S
2575  next y%
2580  PRINT : INPUT "DO YOU WANT TO RUN ANOTHER (Y/N)";Y$
2590  IF  LEFT$ (Y$,1) = "Y" THEN  goto 2420 else 40
2600  GOTO 40
2610  REM  FIND AMOUNT OF DISC PAPER
2620  GOSUB 4500
2630  PRINT "#13 CALCULATE THE NET COST OF DISCOUNTED"
2640  PRINT "                 PAPER.."
2660  PRINT 
2670  INPUT "ENTER THE FUTURE VALUE OF THE NOTE";T
2680  INPUT "ENTER THE DISCOUNT RATE";D
2690  PRINT 
2700  INPUT "ENTER THE NUMBER OF DAYS TO MATURITY";N
2710  D = D / 100
2720  D1 = T * D * N / 360
2730  PRINT 
2740  PRINT "IF YOU PURCHASE A NOTE WORTH $";T
2750  PRINT "                DUE IN";N;"DAYS"
2760  PRINT "AT A DISCOUNT RATE OF";D * 100;"PERCENT,"
2770  PRINT "THE DISCOUNT AMOUNT WILL BE $";D1
2780  PRINT "AND THE COST WILL BE $";T - D1;" ."
2790  PRINT : PRINT : INPUT "DO YOU WANT TO RUN ANOTHER (Y/N)";Y$
2800  IF  LEFT$ (Y$,1) = "Y" THEN  GOTO 2610 ELSE 40
2820  GOSUB 4500
2830  PRINT  TAB( 5)"#14  PRINCIPAL ON A LOAN"
2840  PRINT 
2850  PRINT D$
2860  INPUT "HOW MANY PAYMENTS DO YOU MAKE EACH YEAR";N
2870  PRINT 
2880  INPUT "WHAT IS THE AMOUNT OF EACH PAYMENT";R
2890  PRINT 
2900  INPUT "WHAT IS THE LOAN ANNUAL INTEREST RATE";I
2910  PRINT 
2920  INPUT "ENTER THE LIFE OF THE LOAN IN YEARS";Y
2930  P = R * N * (1 - 1 / ((I / 100) / N + 1) ^ (N * Y)) / (I / 100)
2940  ?"The principal on this loan is: ";:?USING "$$#,###,###.##";P
2950  PRINT : PRINT : INPUT "DO YOU WANT TO RUN ANOTHER (Y/N)";Y$
2960  IF  LEFT$ (Y$,1) = "Y" THEN  GOTO 2820 ELSE 40
2980  rem
2990  GOSUB 4500:PRINT "    #15 REGULAR PAYMENT ON A LOAN.."
3000  PRINT 
3020  PRINT "WHAT IS THE LIFE OF THE LOAN IN YEARS"
3030  INPUT Y
3040  INPUT"WHAT IS THE ANNUAL INTEREST RATE ";I
3050  INPUT "HOW MANY PAYMENTS DO YOU MAKE EACH YEAR";N
3060  INPUT "WHAT IS THE LOAN PRINCIPAL AMOUNT";P
3070  PRINT : PRINT :R = ((I / 100) * P / N) / (1 - 1 / ((I / 100) / N + 1) ^ (N * Y))
3080  I1 = I
3090  PRINT "Regular payments of ";:?USING "$$#,###,###.##";R;
3100  PRINT " made ";N;" times each year"
3110  PRINT "are required to satisfy"
3120  PRINT "a loan of ";:?USING "$$#,###,###.##";P;: PRINT " for a period of ";
3125  PRINT USING "###";Y;:PRINT" years"
3130  PRINT "at an interest rate of";I1;" pecent per annum."
3140  PRINT : PRINT : INPUT "DO YOU WANT TO RUN ANOTHER (Y/N)";Y$
3150  IF  LEFT$ (Y$,1) = "Y" THEN  GOSUB 4370: GOTO 2980
3160  GOTO 40
3170  gosub 4500
3180  PRINT  TAB( 10)"#16  LAST PAYMENT ON A LOAN"
3190  PRINT 
3210  INPUT "WHAT IS THE LIFE OF THE LOAN IN YEARS";Y
3220  INPUT "ENTER THE ANNUAL INTEREST RATE";I
3230  PRINT 
3240  INPUT "WHAT IS THE AMOUNT OF EACH REGULAR PAYMENT";R
3250  PRINT 
3260  INPUT "HOW MANY PAYMENTS DO YOU MAKE EACH YEAR";N
3270  PRINT 
3280  INPUT "ENTER THE AMOUNT OF THE LOAN PRINCIPAL";P
3290  PRINT :I1 = I:I = I / 100:BO = P
3300  IF N * Y > 100 THEN  PRINT  TAB( 20)"WORKING THE PROBLEM"
3310  FOR K = 1 TO N * Y
3320  I2 =  INT ((BO * I / N) * 100 + .5) / 100
3330  A = R - I2
3340  BO = BO - A
3350  NEXT K
3360  PRINT "THE LAST PAYMENT FOR THIS LOAN,"
3370  PRINT "WILL BE $"; INT ((R + BO) * 100 + .5) / 100
3380  PRINT : PRINT : INPUT "DO YOU WANT TO RUN ANOTHER (Y/N)";Y$
3390  IF  LEFT$ (Y$,1) = "Y" THEN  GOSUB 4370: GOTO 3170
3400  GOTO 40
3410  gosub 4500
3420  PRINT "     #17 REMAINING BALANCE ON A LOAN"
3430  PRINT 
3450  INPUT "ENTER THE NUMBERS OF PAYMENTS MADE EACH YEAR";N
3460  PRINT 
3470  INPUT "ENTER THE ANNUAL INTEREST RATE";I
3480  PRINT 
3490  INPUT "WHAT IS THE AMOUNT OF EACH PAYMENT";R
3500  PRINT 
3510  INPUT "WHAT IS THE AMOUNT OF THE LOAN PRINCIPAL";P
3520  PRINT 
3530  PRINT "ENTER THE LAST PAYMENT MADE ,"
3540  INPUT "          (PAYMENT #, YEAR # )";N1,Y
3550  PRINT : PRINT "WORKING ON PROBLEM"
3560  I = I / 100
3570  BO = P
3580  FOR J1% = 1 TO N * (Y - 1) + N1
3590  I1 =  INT ((BO * I / N) * 100 + .5) / 100
3600  A = R - I1
3610  BO = BO - A
3620  NEXT J1%
3630  PRINT : PRINT "THE REMAINING BALANCE IS $"; INT (BO * 100 + .5) / 100
3640  PRINT : INPUT "DO YOU WANT TO RUN ANOTHER (Y/N)";Y$
3650  IF   LEFT$ (Y$,1) = "Y" THEN  GOSUB 4370: GOTO 3410
3660  GOTO 40
3670  gosub 4500
3680  PRINT  TAB( 10)"THE TERM OF A LOAN"
3690  PRINT 
3710  INPUT "ENTER THE NUMBER OF PAYMENTS EACH YEAR";N
3720  PRINT 
3730  INPUT "ENTER THE ANNUAL INTEREST RATE";I
3740  PRINT 
3750  INPUT "WHAT IS THE AMOUNT OF EACH REGULAR PAYMENT";R
3760  PRINT 
3770  INPUT "WHAT IS THE AMOUNT OF THE LOAN PRINCIPAL";P
3780  PRINT 
3790  Y =  - ( LOG (1 - (P * (I / 100)) / (N * R)) / ( LOG (1 + I / 100 / N) * N))
3800  PRINT "A TERM OF"; INT (Y * 10 + .5) / 10;"YEARS WILL SATISFY THIS LOAN."
3810  PRINT "SATISFY THIS SCHEDULE."
3820  PRINT : INPUT "DO YOU WANT TO RUN ANOTHER (Y/N)";Y$
3830  IF  LEFT$ (Y$,1) = "Y" THEN  GOSUB 4370: GOTO 3670
3840  GOTO 40
3850  gosub 4500
3860  PRINT "#19  THE ANNUAL INTEREST RATE ON A LOAN"
3880  PRINT "  ******** UNDER CONSTRUCTION ********"
3890  FOR I = 1 TO 2000: NEXT I
3900  GOTO 40
3910  gosub 4500
3920  PRINT "                         THE MORTGAGE AMORTIZATION TABLE"
3930  PRINT 
3940  PRINT "                           COMPUTE INTEREST PAYMENTS..."
3950  PRINT 
3980  REM  LEADING & TRAILING ZERO'S NOT ?"ED"
3990  C = 0
4000  INPUT "Enter Amount of Loan";A
4010  INPUT "Amount of Interest in Percent";J
4020  INPUT "Nunber of Years";N
4030  J = J / 100
4040  N = N * 12:I = J / 12:B = 1 + I:R = A * I / (1 - 1 / B ^ N)
4050  PRINT "Amount per Payment =";:? USING"$$,###,###.##";R
4060  Q = (R * N - A)
4080  PRINT "Total Interest=";:? USING"$$,###,###.##";Q
4090  PRINT "To Begin Listing Hit Any Key...":F=0
4100  A$=input$ (1)
4110  IF A$="" THEN 4100
4120  PRINT :B = A
4130  GOSUB 4370
4140  PRINT "PMT     INTEREST    PRINCIPAL      BALANCE"
4150  C = C + 1:L = B * I:P = R - L:B = B - P:IF B<0 THEN B=0
4160  PRINT USING"###";C;:PRINT USING"$$,###,###.##";L;P;B
4170  F = F + 1
4180  IF F = 14 THEN 4280
4190  IF N>C THEN 4150
4200  D=R+B
4230  PRINT "Last Payment was...";:? USING"$$,###,###.##";D
4240  INPUT "Do You Want to Run Another (Y/N)";Y$
4250  IF  LEFT$ (Y$,1) = "Y" THEN 3910 ELSE 40
4280  PRINT"TO CONTINUE STRIKE ANY KEY, ESC TO STOP"
4290  A$=input$(1) : IF A$="" THEN 4290
4300  IF A$=CHR$(27) THEN GOSUB 4370: GOTO 4240
4310  PRINT 
4320  F = 0
4330  GOSUB 4370
4340  GOTO 4140
4370  clearw 2:gotoxy 0,0:return
4380  clearw 2:gotoxy 0,0:RETURN
4390  REM 
4500  CLEARW 2:GOTOXY 0,0:RETURN
4510  RETURN
4999  STOP
5000  CLEARW 2:GOTOXY 39,12:PRINT"Bye":END
8880  A=((T / P) ^ (1 / Y) - 1) * 100
