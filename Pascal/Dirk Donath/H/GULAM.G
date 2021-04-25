# -----------------------------------------------------------------------------
# GULAM.G                                                   
#
# Dirk Donath, Vogelpothsweg 20, 4600 Dortmund 1
# -----------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------
# Alias-Definitionen:
# -----------------------------------------------------------------------------
#
alias type   'more  '
alias del    'rm    '
alias dir    'ls -F '
alias ls     'ls -FL'
alias copy   'cp    '
alias rd     'rmdir '
alias md     'mkdir '
alias a:     'cd a:\'
alias b:     'cd b:\'
alias c:     'cd c:\'
alias d:     'cd d:\'
alias e:     'cd e:\'
alias f:     'cd f:\'
alias g:     'cd g:\'
alias h:     'cd h:\'
alias invoff set rgb '111-000-'               # Bildschirm schwarz auf weiss
alias invon  set rgb '000-111-'               # Bildschirm weiss auf schwarz
#
# -----------------------------------------------------------------------------
# Aenderungen einiger Editorkommandos:
# -----------------------------------------------------------------------------
#
# Funktionstasten:
# ----------------
uekb 081 36              # F1       =  Blockpuffer loeschen
uekb 082 3b              # F2       =  Blockpuffer einfuegen
uekb 083 2c              # F3       =  vorwaerts suchen
uekb 084 2f              # F4       =  suchen und ersetzen
#
# Tasten des Zahlenfeldes:
# ------------------------
uekb 0b0 30              # 0        =  Marke setzen
uekb 0b1 1f              # 1        =  End
uekb 0b2 0f              # 2        =  runter
uekb 0b3 61              # 3        =  PgDown
uekb 0b4 1a              # 4        =  links
uekb 0b5 00              # 5        =  Noop
uekb 0b6 1b              # 6        =  rechts
uekb 0b7 1e              # 7        =  Home
uekb 0b8 23              # 8        =  rauf
uekb 0b9 62              # 9        =  PgUp
uekb 0c4 10              # Enter    =  Return
#
# Sonstige Tasten:
# ----------------
uekb 14d 25              # Return   =  Return mit Einrueckung
uekb 159 20              # ^Y       =  Zeile loeschen
uekb 07f 1d              # Delete   =  Delete
uekb 08d 54              # Insert   =  zum Textende
uekb 08e 55              # ClrHome  =  zum Textanfang
#
# -----------------------------------------------------------------------------
# Aktionen beim Start von GULAM:
# -----------------------------------------------------------------------------
#
msoff                    # Maus abschalten
set home $cwd
set prompt '$cwd>'
echo ' '
mem
echo ' '
#
# -----------------------------------------------------------------------------
#
