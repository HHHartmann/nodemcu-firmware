#!/bin/bash

LFSFiles="../lua_modules/fifo/fifosock.lua ../lua_modules/fifo/fifo.lua ../lua_modules/ftp/ftpserver.lua ../lua_examples/telnet/telnet_pipe.lua"

grep -A 1 \.rodata\.BuiltinLFS_xxx < ../app/mapfile | head -2 | tail -1 | sed "s/  */ /g" | cut -d " " -f2

grep -oba LFSBEGIN < ../bin/0x10000.bin | cut -d ":" -f 1

TARGET_ADDR=`grep -A 1 \.rodata\.BuiltinLFS_xxx < ../app/mapfile | head -2 | tail -1 | sed "s/  */ /g" | cut -d " " -f2`
FILE_OFFSET=`grep -oba LFSBEGIN < ../bin/0x10000.bin | cut -d ":" -f 1`

# rebuild LFS with target address
echo rebuilding img with target address $TARGET_ADDR
../luac.cross -o BuiltinLFS.img2 -a $TARGET_ADDR -f  $LFSFiles

echo patching LFS image at file address $FILE_OFFSET

cp ../bin/0x10000.bin ../bin/0x10000.bin2
dd if=BuiltinLFS.img2 of=../bin/0x10000.bin2 bs=1 seek=$FILE_OFFSET conv=notrunc

srec_cat -output ../bin/nodemcu.bin -binary ../bin/0x00000.bin -binary -fill 0xff 0x00000 0x10000 ../bin/0x10000.bin2 -binary -offset 0x10000

xxd -i ../bin/0x10000.bin > bin
xxd -i ../bin/0x10000.bin2 > bin2
xxd -i ../bin/nodemcu.bin > nodemcu.bin



ls -l ../bin/0x10000.bin*
ls -l BuiltinLFS.img*





exit


srec_cat                               \
    ../bin/0x10000.bin -binary -contradictory-bytes=warning \
    BuiltinLFS.img2 -binary -offset 0x$FILE_OFFSET  \
     \
    −output ../bin/0x10000.bin2 -binary  




srec_cat                               \
    ../bin/0x10000.bin -binary  \
    BuiltinLFS.img2 -binary -offset $FILE_OFFSET  \
    −o ../bin/0x10000.bin2



srec_cat                               \
    ../bin/0x10000.bin -binary −exclude −within BuiltinLFS.img2 \
    BuiltinLFS.img2 -binary -offset $FILE_OFFSET −exclude −within ../bin/0x10000.bin \
    −o ../bin/0x10000.bin2
