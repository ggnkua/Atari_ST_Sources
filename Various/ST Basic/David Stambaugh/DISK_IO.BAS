100   'Random I/O Files in ST BASIC
110   'ver. 011386
120   'Written by David Stambaugh
130   '(c)1986 Antic Publishing
132   'Additions (remarks) by Richard Karsmakers
134   'No rights reserved
140   '
150   disk=1: output=2
152   'disk=1 is a constant for the file number
154   'output=2 is a constant for the output window number
160   true=(-1): false=0
162   'both true and false are constants for comparisons in the program
170   clearw output: fullw output
172   'This takes care that the output screen is wiped and made full-screensize
180   '
190   open "R",#disk,"a:\test.dat",35
191   'the "R" stands for mode, which is "Random"
192   'the "R" can also be "I" for seq. input or "O" for seq. output
193   '#disk opens the channel number (#1)
194   '"a:\test.dat" means the file name. This should be between quotes
195   'the a: stands for access to drive A. Name format NNNNNNNN.XXX
196   '"35" stands for the record length. Default is 128, but it should
197   ' match your record size!
200   field #disk,10 as phone$, 25 as personal$
201   'The field command allocates space for a buffer in which the record is put
202   'The #disk is the same as the one that was opened (1)
203   'the "10" is the field width for the string "phone$"
204   'the "25" is the field width for the string "personal$"
205   'You can add more xx as yy$ to this list, but take care that the total
206   ' number of all numbers equals to the record size in the OPEN statement
210   print:gotoxy 10,0
212   'This command simply moves the cursor to a specific space
220   input "How many records to store > ";count%
230   '
240   for record=1 to count%
250   clearw output: gotoxy 10,0
260   print "Input for Record Number ";record;" of ";count%
262   'This line lets the user know which record he will define
270   gotoxy 0,5:input "NAME:",b$
280   gotoxy 0,10:input "PHONE:",a$
290   lset phone$=a$:lset personal$=b$
291   'The lset command takes care that a string is stored in another string
292   'In this case, A$ is transfered to phone$ and b$ to personal$
293   'The difference with LET (which you shouldn't use!) is that all
294   ' characters that are too much in a$ or b$ (more than the length in FIELD)
295   ' are ignored. All non-used characters to the right of the defined name
296   ' are filled with spaces. With the RSET command, this is done to the left.
297   'Numeric variables need to be converted to strings before using RSET
298   'or RSET (with help of MKD$, MKI$ or MKS$)!
300   gotoxy 10,15:print "Please wait. Writing data to file."
310   put #disk,record
312   'This PUTs the record to disk (writes is to disk)
314   'The record number should be an integer between 1 and 32767
320   next record
330   close #disk
332   'After writing to a file, it's wise to close it as well as opening it!
340   '
350   attempt=true
352   'Constant for read attempt succeeded or no
360   open "R",#disk,"a:\test.dat",35
362   'Have a look at the earlier OPEN command for explanation!
370   '
380   while attempt=true 'Is a record there to read?
390   a$="          "
400   b$="                         "
410   clearw output:gotoxy 0,0
420   choice%=false:input "( 0=end ) Look at file number ";choice%
422   'Which record does the user wish to view?
430   if choice% then gosub       readrecord else attempt=false
432   'if choice% is not equal to zero than read a record, else don't!
440   wend
450   '
460   close #disk
470   clearw output
480   '
490   end
500   '
510   '
520   readrecord:
530   if choice%>count% then return
532   'If record number is higher than the number of records, then ignore
540   field #disk,10 as phone$,25 as personal$
542   'Look above for explanation
550   get #disk,choice%
552   'This is the opposite to PUT, and GETs a file from disk (reads it)
560   lset a$=phone$:lset b$=personal$
562   'This time, you have to work vice versa with the LSET command to
564   ' ensure proper variables, since they have to be fetched from the buffer!
570   gotoxy 0,4: print "Name > ";b$
580   gotoxy 0,8: print "Phone > ";a$
590   for delay=0 to 2000: next delay
592   'Alright, ST Basic is already terribly slow, but David
594   'apparently thought it still went too fast here. So what?
600   return
