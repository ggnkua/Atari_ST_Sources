# Shellscript: Okami-Shell UPN-Rechner
# @(#) calc.sh von wr 12.8.90 - 4.5.91

_=0.0

# Programmvariablen fr Binominalkoeffizienten und Summe 1..x
# (siehe tricks.doc)
BKOEFF="2 sto 1 sto 1 rcl fact 2 rcl fact 1 rcl 2 rcl - fact * /"
SUM="dup sqr + 2 /"

# English readers un-comment the following lines:
#echo ^033pOkami-Shell RPN calculator^033q^n
#echo Type ^`help^' for command survey.
#echo Type ^`exit^' to finish.
#PROMPT=rpn

# and comment the following lines:
echo ^033pOkami-Shell UPN-Rechner^033q^n
echo Hilfe durch Eingabe von ^`help^'.
echo Ende durch Eingabe von ^`exit^'.
PROMPT=upn

while true
do
  echo "$PROMPT ^> "^c
  read - UPN
  if [ -v UPN ]		# Leerzeile
  then
    continue
  fi
  if [ $UPN = exit ]
  then
    break
  fi

  upn $UPN
  _=$?

done

unset UPN PROMPT
