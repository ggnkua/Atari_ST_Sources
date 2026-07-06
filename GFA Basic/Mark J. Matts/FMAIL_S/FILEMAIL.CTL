systempath h:\qbbs\
mailarea f:\qbbs\msgs\0010
holdarea f:\qbbs\utils\filemail\holdarea\

protocol 
 key X 
 name X-Modem 
 path H:\QBBS\UTILS\TRANSFER\XYZ.TTP 
 send -x -u *file
 recv -x -d *path
 askfilename
end

protocol 
 key Y 
 name Y-Modem 
 path H:\QBBS\UTILS\TRANSFER\XYZ.TTP
 send -y -u *file
 recv -y -d *path
end

protocol 
 key Z 
 name Z-Modem 
 path H:\QBBS\UTILS\TRANSFER\XYZ.TTP 
 send -z -u *file
 recv -z -d *path
end

protocol 
 key J 
 name Jekyll, Full Duplex!
 path H:\QBBS\UTILS\TRANSFER\JEKYLL.TTP
 send -recvh:\qbbs\upload\ *FILE
 recv -recv*PATH *FILE
end
