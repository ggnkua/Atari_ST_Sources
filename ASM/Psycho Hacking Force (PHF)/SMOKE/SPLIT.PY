f   = file("BORDER.PI1", "rb")
inp = f.read()
f.close()

f = file('BORDER.INL', 'wb')
f.write(inp[:34+(50*160)])
f.close()

f   = file("SPRITES.PI1", "rb")
inp = f.read()
f.close()

f = file('SPRITES.INL', 'wb')
f.write(inp[:34+(24*160)])
f.close()


