#--------------------------------------------------------
if __name__ == '__main__':
#--------------------------------------------------------

   print 'read'
   f   = file('two.tga', 'rb')
   s   = f.read()
   f.close()

   print 'convert & save'
   f   = file('two.inl', 'wb')
   f.write(s[18:3618])
   f.close()

   print 'ok'
