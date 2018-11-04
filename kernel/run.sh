sh build.sh
cp ../files/bootloader.sna .
wine ../bin/CSpect.exe -zxnext -cur -brk -exit -w3 bootloader.sna 2>/dev/null