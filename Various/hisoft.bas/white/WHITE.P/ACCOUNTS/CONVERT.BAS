200   clearw 2 : fullw 2
300   months$ = "***JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC"
310   file$ = "accounts.dat" : flag$="Y" : gosub convert
320   file$ = "stdorder.dat" : flag$="N" : gosub convert
330   end
390   convert:
400   open "R", #1, "\livedata\" + file$, 29
450   field #1, 4 as a.date$,1 as a.accnt$,10 as a.reason$,4 as a.value$,10 as a.ref$
490   kill "\testdata\" + file$
500   open "R", #2, "\testdata\" + file$, 30
600   field #2, 4 as o.date$,1 as o.flag$,1 as o.accnt$,10 as o.reason$,4 as o.value$,10 as o.ref$
700   n% = lof(1) : ?"File ";file$;" has ";n%;" records"
800   for record% = 1% to n% 
900   get #1, record% : gosub unlset.old.format
1000  gosub lset.new.format : put #2, record%
1100  next
1150  close #1 : close #2
1200  return
14900 '==================================================================
15000 lset.new.format: 'Encode new account record
15100 lset o.date$ = mkd$(date) : lset o.accnt$ = account$
15200 lset o.reason$ = reason$  : lset o.value$ = mkd$(amount)
15300 lset o.ref$ = refno$      : lset o.flag$ = flag$
15400 return
15500 '---------
15600 unlset.old.format: 'Decode old account record
15700 date = cvd(a.date$)  : account$ = a.accnt$
15800 reason$ = a.reason$  : amount = cvd(a.value$)
15900 refno$ = a.ref$
16000 return
16100 '------
20000 error.handler:
20100 unknown.error:
20200 ?"Unexpected error number ";err;" on line ";eln
20300 stop
20400 parse.date:
20500 day$ = left$(date$,2) : day% = val(day$)
20600 month$ = mid$(date$,4,3)
20700 month% = instr(0,months$,month$) / 3%
20800 year$ = right$(date$, 2) : if year$ = "**" then year% = 0% else year% = val(year$)
20900 date = day% + 32% * (month% + (13% * year%))
21000 return
21100 decode.date:
21200 ym% = date / 32% : day% = date - ym% * 32
21300 year% = ym% / 13% : month% = ym% - year% * 13%
21400 day$ = right$(str$(day%+100),2) 
21500 month$ = mid$(months$,month%*3%+1%,3%)
21600 if year% = 0 then year$ = "**" else year$ = right$(str$(year%+100%), 2%)
21700 date$ = day$ + "-" + month$ + "-" + year$
21800 return
21900 ' --------
25300 return
