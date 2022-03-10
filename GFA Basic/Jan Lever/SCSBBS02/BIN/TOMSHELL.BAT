alias l ls
alias ll dir
alias q exit
alias h history
alias a: cd a:
alias b: cd b:
alias d: cd d:
alias ed a:\bin\gnome.ttp
set pause 25
set quick on
set f10 "exit\r"
set f1 "set disk\r"
set owrite ask

cls
echo $date $time
echo Memory free: $mem , free on drive d: $disk
if $dcd == on then echo "Carrier present!"
if $dcd == off then echo "No carrier present."
echo

