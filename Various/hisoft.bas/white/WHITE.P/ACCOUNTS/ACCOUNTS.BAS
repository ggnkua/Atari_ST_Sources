100   dim balance(26), stdorders(100), uncleared(26)
200   clearw 2 : fullw 2
250   folder$ = "\LIVEdata\"
300   months$ = "***JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC"
350   sorted% = 0%
400   '====================================================================
500   message$ = "COPYRIGHT ½ 1986, Peter White. All rights reserved"
550   print message$
600   gotoxy 1 ,5 : ?"Todays date :"
700   gotoxy 13 ,5 : input "",date$ : gosub parse.date
800   if date$ = "EXIT" then end
900   if date$ = "BAD  DATE" then goto 600
1000  today = date : today$ = date$
1100  '
1200  '-- See if any standing orders have become due
1300  '
1400  open "R", #2, folder$ + "stdorders.dat", 30
1500  field #2, 4 as o.date$,1 as o.flag$,1 as o.accnt$,10 as o.reason$,4 as o.value$,10 as o.ref$
1600  if lof(2) <= 1% then gosub init.stdorders
1700  get #2, 1% : gosub unlset.stdorder : so.date = date
1800  if so.date < today then message$ = "Standing orders may not be upto date"
1900  file% = 1%
2000  open "R", file%, folder$ + "accounts.dat", 30
2100  field #1, 4 as a.date$,1 as a.flag$,1 as a.accnt$,10 as a.reason$,4 as a.value$,10 as a.ref$
2200  '
2300  '
2400  MAIN.MENU: clearw 2 : gotoxy 1,1 : ? today$,space$(40),folder$
2500  gotoxy 6,18: ? message$ : message$ = ""
2600  gotoxy 8,2:? "T h e   H o m e   A c c o u n t a n t"
2700  gotoxy 4,4:? " 1 - Add a transaction        11 - Add a standing order"
2800  gotoxy 4,5:? " 2 - Update a transaction     12 - Update a standing order"
2900  gotoxy 4,6:? " 3 - List transactions        13 - List standing orders"
3000  gotoxy 4,7:? " 4 - Print transactions       14 - Print standing orders"
3100  gotoxy 4,8:? " 5 - Sort transactions        15 - Include standing orders"
3200  gotoxy 4,9:? " 6 - List balances            99 - Exit to BASIC"
3300  gotoxy 10,12:  input "Enter option : ", reply$
3400  reply% = val(reply$) 
3500  if reply% = 99 then end
3600  on reply% + 1% gosub o.0, at, ut, lt, pt, sort, bal, mut, o.8, o.9, o.10, aso, uso, lso, pso, do.stdorders
3700  goto main.menu
3800  o.0:
3900  o.7:
4000  o.8:
4100  o.9:
4200  o.10: message$ = "Invalid option" : return
4300  '
4400  at: file% = 1% : date = today : sorted% = 0% : goto 4600
4500  aso: file% = 2% : date = 1 : goto 4600
4600  account$ = "C" : reason$ = space$(10) : amount = 0 : refno$ = space$(10)
4650  flag$ = "N"
4700  record% = lof(file%) + 1% : gosub show.record : gosub ask.record
4800  if date$ <> "exit" then goto 4700
4900  return
5000  '
5100  ut: file% = 1% : sorted% = 0% : goto 5300
5200  uso: file% = 2% : goto 5300
5300  clearw 2 : gotoxy 10,12 : input "Enter record number : ", record$
5400  if len(record$) = 0 then return
5500  record% = val(record$) : if record% = 0 then return
5600  get file%, record% : on file% gosub unlset.account, unlset.stdorder
5700  gosub show.record : gosub ask.record : goto 5300
5800  '
5900  ask.record:
6000  gosub ask.date : if date$ = "exit" then return
6100  gosub ask.account : gosub ask.reason
6200  gosub ask.amount : gosub ask.refno
6250  if file% = 1% then gosub ask.flag
6300  on file% gosub lset.account, lset.stdorder
6400  gotoxy 10,18 : input "Type Y to confirm ", reply$
6500  if reply$ = "Y" then put file%, record% : return
6600  goto ask.record
6700  '
6701  ' Print/list standing orders
6702  '
6800  pso: open "O",#3,"\REPORTS\STDORDERS.RPT"
6810  lso: file% = 2% : maxso% = lof(file%) : clearw 2
6900  for record% = 1% to maxso%
7000  get file%, record% : gosub unlset.stdorder
7100  gosub format.detail
7150  if reply% = 13 then print r$ else print#3, r$
7200  next
7300  if reply% = 13 then input "Hit RETURN to continue", reply$
7310  if reply% = 14 then close #3 : message$ = "Report created."
7400  return
7500  '--
7600  '-- List/print transactions
7700  '--
7710  pt:
7720  gotoxy 10,12: input "To which file [ACCOUNTS.RPT]:",file$
7730  if len(file$) = 0 then file$ = "ACCOUNTS.RPT"
7740  file$ = "\REPORTS\" + file$
7750  open "O", #3, file$
7760  goto lpt
7800  lt:
7850  lpt: file% = 1% : active.accounts$ = "" : money = 0
7900  gotoxy 10,13: input "List which account(s)  [All]: ", accounts.to.list$
8000  gotoxy 10,14: input "Start date    [First record]: ", date$
8100  if len(date$) = 0 then start.date = 0 else gosub parse.date : start.date = date
8200  gotoxy 10,15: input "End date             [Today]: ", date$
8300  if len(date$) = 0 then end.date = today else gosub parse.date : end.date = date
8350  if end.date > so.date and sorted% = 0% then gosub sort
8400  maxrec% = lof(file%) : last.date = 0
8500  clearw 2
8600  for record% = 1% to maxrec%
8700  get file%, record% : gosub unlset.account
8800  if date < last.date then message$ = "Transactions need sorting."
8900  acnt% = asc(account$) - 64%
9000  if instr(0,active.accounts$,account$) <> 0 then goto 9200
9100  active.accounts$ = active.accounts$ + account$ : balance(acnt%) = 0 : uncleared(acnt%) = 0
9200  if date <= today and flag$ = "Y" then balance(acnt%) = balance(acnt%) + amount
9250  if date <= today and flag$ = "N" then uncleared(acnt%) = uncleared(acnt%) + amount
9300  if len(accounts.to.list$) <> 0 then if instr(0,accounts.to.list$,account$) = 0 then goto 10000
9350  money = money + amount
9400  if date > end.date or date < start.date then goto 10000
9600  gosub format.detail
9601  m=money*sgn(money)
9602  ma$=str$(m):mb$=string$(10," ")+ma$:mc$=right$(mb$,10%)
9603  r$ = r$ + mc$
9604  if money > 0 then r$ = r$ + "-"
9610  if reply% = 3 then print r$ else print #3, r$
10000 last.date = date
10100 next
10200 if reply% = 3 then input "Hit RETURN to continue", reply$
10210 if reply% = 4 then close #3 : message$ = "Report created"
10220 return
10400 format.detail: gosub decode.date
10401 rec$="  "+str$(record%):rec$=right$(rec$,4%)
10402 if flag$ = "Y" then r$ = rec$ + " " else r$ = rec$ + "*"
10403 r$ = r$ + date$ + " " + account$ + " " + refno$ + " " + reason$
10503 am=amount*sgn(amount)
10504 ma$=str$(am):mb$=string$(10," ")+ma$:am$=right$(mb$,10%)
10505 if amount >= 0 then r$ = r$ + am$ + space$(10)
10506 if amount < 0  then r$ = r$ + space$(10) + am$
11300 return
11400 '--------
11500 mut: file% = 1% : sorted% = 0% : clearw 2
11600 maxrec% = lof(1)
11700 for record% = 1% to maxrec%
11800 get #1, record% : gosub unlset.account
11900 gosub user.code 'call user specified update code once per record 
12000 gosub lset.account : if date$ <> "exit" then put file%, record%
12100 next
12200 return
12300 '--------
12400 user.code: ' User specified mass-update code
12500 gosub show.record
12600 gosub ask.record
12700 return
12800 '--------
12900 show.record: clearw 2 : gotoxy 5,2 : ? "-- Record"; record%; "--"
13000 gotoxy 5, 5 : gosub decode.date : print "Date ........"; date$;
13100 gotoxy 5, 6 : print "Account ....."; account$
13200 gotoxy 5, 7 : print "Reason ......"; reason$
13300 gotoxy 5, 8 : ? using "Amount _.._.._.. ######.##"; amount
13400 gotoxy 5, 9 : print "Ref no ......"; refno$
13450 gotoxy 5,10 : print "Processed ..."; flag$
13500 return
13600 '==================================================================
13700 lset.account: 'Encode account record
13800 lset a.date$ = mkd$(date) : lset a.accnt$ = account$
13900 lset a.reason$ = reason$  : lset a.value$ = mkd$(amount)
14000 lset a.ref$ = refno$      : lset a.flag$ = flag$
14100 return
14200 '---------
14300 unlset.account: 'Decode account record
14400 date = cvd(a.date$)  : account$ = a.accnt$
14500 reason$ = a.reason$  : amount = cvd(a.value$)
14600 refno$ = a.ref$      : flag$ = a.flag$
14700 return
14800 '------
14900 lset.stdorder: 'Encode standing order record
15000 lset o.date$ = mkd$(date) : lset o.accnt$ = account$
15100 lset o.reason$ = reason$  : lset o.value$ = mkd$(amount)
15200 lset o.ref$ = refno$      : lset o.flag$ = flag$
15300 return
15400 '---------
15500 unlset.stdorder: 'Decode standing order record
15600 date = cvd(o.date$)  : account$ = o.accnt$
15700 reason$ = o.reason$  : amount = cvd(o.value$)
15800 refno$ = o.ref$      : flag$ = o.flag$
15900 return
16000 '==================================================================
16100 ask.date:
16200 gotoxy 30,5 : input "";reply$ : if len(reply$) <> 0 then date$ = reply$
16300 if date$ = "EXIT" or date$ = "exit" then date$ = "exit" : goto 16600
16400 gosub parse.date : if date$ <> "BAD  DATE" then goto 16600
16500 gosub show.record : goto ask.date
16600 return
16700 '----------
16800 ask.account:
16900 gotoxy 30,6: input "";reply$
17000 if len(reply$) <> 0 then account$ = reply$
17100 return
17200 '----------
17300 ask.reason:
17400 gotoxy 30,7 : input "";reply$
17500 if len(reply$) <> 0 then reason$ = reply$
17600 return
17700 '----------
17800 ask.amount:
17900 gotoxy 30,8 : input ""; reply$
18000 if len(reply$) <> 0 then amount = val(reply$)
18100 return
18200 '----------
18300 ask.refno:
18400 gotoxy 30,9 : input ""; reply$
18500 if len(reply$) <> 0 then refno$ = reply$
18600 return
18610 '----------
18620 ask.flag:
18630 gotoxy 30,10: input ""; reply$
18640 if len(reply$) <> 0 then flag$ = reply$
18645 if flag$ <> "Y" then flag$ = "N"
18650 return
18660 '----------
18700 error.handler:
18800 unknown.error:
18900 ?"Unexpected error number ";err;" on line ";eln
19000 stop
19001 '----------
19100 parse.date:
19200 day$ = left$(date$,2) : day% = val(day$)
19300 month$ = mid$(date$,4,3)
19400 month% = instr(0,months$,month$) / 3%
19500 year$ = right$(date$, 2) : if year$ = "**" then year% = 0% else year% = val(year$)
19600 date = day% + 32% * (month% + (13% * year%))
19700 return
19701 '----------
19800 decode.date:
19900 ym% = date / 32% : day% = date - ym% * 32
20000 year% = ym% / 13% : month% = ym% - year% * 13%
20100 day$ = right$(str$(day%+100),2) 
20200 month$ = mid$(months$,month%*3%+1%,3%)
20300 if year% = 0 then year$ = "**" else year$ = right$(str$(year%+100%), 2%)
20400 date$ = day$ + "-" + month$ + "-" + year$
20500 return
20600 ' ---------
20700 sort:
20800 n% = lof(1) : first.swap% = 1% : sorted% = 1%
20900 try.swap.again: swapped% = 0% :gotoxy 1,18:?"Working ... ";
21000 for record% = first.swap% to n% - 1%
21100 get #1, record% : gosub unlset.account : gosub save.record
21200 get #1, record% + 1% : gosub unlset.account
21300 if date >= save.date then gosub save.record : goto sort.next
21400 put #1, record%
21500 date = save.date : account$ = save.account$ : reason$ = save.reason$
21600 amount = save.amount : refno$ = save.refno$ : flag$ = save.flag$
21700 gosub lset.account : put #1, record% + 1%
21800 if swapped% = 0% then swapped% = record%
21900 sort.next: next
22000 n% = n% - 1% : if swapped% = 0% then return
22100 first.swap% = swapped% - 1% : if first.swap% = 0% then first.swap% = 1%
22200 goto try.swap.again
22300 save.record:
22400 save.date = date : save.account$ = account$ : save.reason$ = reason$
22500 save.amount = amount : save.refno$ = refno$ : save.flag$ = flag$
22600 return
22700 '-----------
22800 bal: clearw 2 : total = 0 : untotal = 0
22900 if len(active.accounts$) <> 0 then goto 23200
23000 message$ = "Balances only available after 'List accounts'"
23100 return
23200 ? "Accnt       Processed         Actuals"
23210 ? "      -- yes ------- no --"
23250 for account% = 1 to 26
23300 accnt$ = chr$(account%+64)
23400 if instr(0,active.accounts$,accnt$) = 0 then goto 23700
23402 v1 = -balance(account%) : v2 = -uncleared(account%)
23500 ? using "  \\  ######.##   ######.##   ######.##";accnt$; v1 ; v2 ; v1+v2
23600 total = total - balance(account%)
23650 untotal = untotal - uncleared(account%)
23700 next
23800 ?
23850 ? using "     ######.##   ######.##   ######.##"; total, untotal, total+untotal
23860 ?
23900 input "Hit RETURN to continue", reply$
24000 return
24100 do.stdorders: gosub read.stdorders
24200 so.date = stdorders(1)
24300 if so.date >= today then goto end.stdorders
24400 for day = so.date+1 to today 'Check each intervening day
24500 date = day : gosub decode.date
24600 if day% = 0% or month% = 0 or year% = 0 then goto 25900
24700 gotoxy 6,18 : ?"Checking for standing orders due on "; date$
24800 this.day% = day% : this.month% = month% : this.year% = year%
24900 for i% = 2% to stdorders% 'Check each standing order
25000 date = stdorders(i%) : gosub decode.date
25100 if day% <> this.day% then 25700
25200 if month% <> 0 and month% <> this.month% then goto 25700
25300 if year% <> 0 and year% <> this.year% then goto 25700
25400 get #2, i% : gosub unlset.stdorder
25500 if amount = 0 then goto 25700 ' Ignore cancelled std orders
25600 date = day : gosub lset.account  : put #1, lof(1) + 1 : sorted% = 0%
25700 next 
25800 date = day : gosub lset.stdorder : put #2, 1%
25900 next
25905 gosub init.stdorders
25907 end.stdorders:
25910 return
26000 init.stdorders: date = today : account$ = "" : refno$ = "LAST RUN" : reason$ = "COMPLETE" : amount = 0
26100 gosub lset.stdorder : put #2, 1% : so.date = today 
26300 return
26400 read.stdorders: stdorders% = lof(2)
26500 for stdorder% = 1% to stdorders%
26600 get #2, stdorder% : gosub unlset.stdorder
26700 stdorders(stdorder%) = date
26800 next
26900 return
