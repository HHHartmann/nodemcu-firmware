#!/bin/bash

LFSFiles="../lua_modules/fifo/fifosock.lua ../lua_modules/fifo/fifo.lua ../lua_modules/ftp/ftpserver.lua ../lua_examples/telnet/telnet_pipe.lua"

echo $LFSFiles
../luac.cross -o BuiltinLFS.img -a 0x40219000 -f  $LFSFiles 

echo "LFSBEGINxxx" > BuiltinLFS.xxx
cat BuiltinLFS.img >> BuiltinLFS.xxx

xxd -i BuiltinLFS.xxx | sed 's/unsigned char/static const unsigned char/' > BuiltinLFS.h

