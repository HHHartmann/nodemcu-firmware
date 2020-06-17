#!/usr/bin/env zsh

set -e -u

SELFDIR=$(dirname $(readlink -f $0))

LUAFILES=(
  ${SELFDIR}/../lua_examples/lfs/_init.lua
  ${SELFDIR}/../lua_examples/lfs/dummy_strings.lua
  ${SELFDIR}/../lua_tests/*
)

if [ -e ${SELFDIR}/../luac.cross.int ]; then
  echo "Found integer Lua cross compiler..."
  ${SELFDIR}/../luac.cross.int -f -o ${NODEMCU_TESTTMP}/tmp-lfs-int.img   ${LUAFILES[@]}
fi

if [ -e ${SELFDIR}/../luac.cross ]; then 
  echo "Found float Lua cross compiler..."
  ${SELFDIR}/../luac.cross     -f -o ${NODEMCU_TESTTMP}/tmp-lfs-float.img ${LUAFILES[@]}
fi
