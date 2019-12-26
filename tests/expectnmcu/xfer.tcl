namespace eval expectnmcu::xfer {
}

package require expectnmcu::core

# Open remote file `which` on `dev` in `mode` as Lua object `dfh`
proc ::expectnmcu::xfer::open { dev dfh which mode } {
  ::expectnmcu::core::send_exp_prompt ${dev} "${dfh} = file.open(\"${which}\",\"${mode}\")"
}

# Close Lua file object `dfh` on `dev`
proc ::expectnmcu::xfer::close { dev dfh } {
  ::expectnmcu::core::send_exp_prompt ${dev} "${dfh}:close()"
}

# Write to `dfh` on `dev` at `where` `what`, using base64 as transport
#
# This does not split lines; write only short amounts of data.
proc ::expectnmcu::xfer::pwrite { dev dfh where what } {
  send -i ${dev} -- [string cat \
    "do local d,e = encoder.fromBase64(\"[binary encode base64 -maxlen 0 ${what}]\");" \
    "${dfh}:seek(\"set\",${where});" \
    "print(${dfh}:write(d));" \
    "end\n" \
  ]
  expect {
    -i ${dev} -re "true\[\r\n\]+> " { }
    -i ${dev} -re ${::expectnmcu::core::panicre} { return -code error "Panic!" }
    -i ${dev} -ex "\n> " { return -code error "Bad result from pwrite" }
    timeout { return -code error "Timeout while waiting for pwrite" }
  }
}

# Read `howmuch` byetes from `dfh` on `dev` at `where`, using base64
# as transport.  This buffers the whole data and its base64 encoding
# in device RAM; read only short strings.
proc ::expectnmcu::xfer::pread { dev dfh where howmuch } {
  send -i ${dev} -- "${dfh}:seek(\"set\",${where}); print(encoder.toBase64(${dfh}:read(${howmuch})))\n"
  expect {
    -i ${dev} -re "\\)\\)\\)\[\r\n\]+(\[^\r\n\]+)\[\r\n\]+> " {
      return [binary decode base64 ${expect_out(1,string)}]
    }
    -i ${dev} -ex "\n> " { return -code error "No reply to pread" }
    -i ${dev} -re ${::expectnmcu::core::panicre} { return -code error "Panic!" }
    timeout { return -code error "Timeout while pread-ing" }
  }
}

# Send local file `lfn` to the remote filesystem on `dev` and name it `rfn`.
# Use `dfo` as the Lua handle to the remote file for the duration of writing,
# (and `nil` it out afterwards)
proc ::expectnmcu::xfer::sendfile { dev lfn rfn {dfo "xfo"} } {
  package require sha256

  set xln 48

  set ltf [::open ${lfn} ]
  fconfigure ${ltf} -translation binary
  ::expectnmcu::xfer::open ${dev} ${dfo} ${rfn} "w+"

  set lho [sha2::SHA256Init]

  set fpos 0
  while { 1 } {
    set data [read ${ltf} ${xln}]
    sha2::SHA256Update ${lho} ${data}
    ::expectnmcu::xfer::pwrite ${dev} ${dfo} ${fpos} ${data}
    set fpos [expr $fpos + ${xln}]
    if { [string length ${data}] != ${xln} } { break }
  }

  ::close ${ltf}
  ::expectnmcu::xfer::close ${dev} ${dfo}
  ::expectnmcu::core::send_exp_prompt ${dev} "${dfo} = nil"

  set exphash [sha2::Hex [sha2::SHA256Final ${lho}]]

  send -i ${dev} "=encoder.toHex(crypto.fhash(\"sha256\",\"${rfn}\"))\n"
  expect {
    -i ${dev} -re "\[\r\n\]+(\[a-f0-9\]+)\[\r\n\]+> " {
      if { ${expect_out(1,string)} != ${exphash} } {
        return -code error \
          "Sendfile checksum mismatch: ${expect_out(1,string)} != ${exphash}"
      }
    }
    -i ${dev} -re ${::expectnmcu::core::panicre} { return -code error "Panic!" }
    timeout { return -code error "Timeout while verifying checksum" }
  }

}

package provide expectnmcu::xfer 1.0
