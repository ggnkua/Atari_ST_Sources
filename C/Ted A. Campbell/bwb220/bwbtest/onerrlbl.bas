rem onerrlbl.bas -- test bwBASIC ON ERROR GOSUB statement with label
print "Test bwBASIC ON ERROR GOSUB statement"
on error gosub handler
print "The next line will include an error"
if d$ = 78.98 then print "This should not print"
print "This is the line after the error"
end
handler:
print "This is the error handler"
print "The error number is ";err
print "The error line   is ";erl
return
