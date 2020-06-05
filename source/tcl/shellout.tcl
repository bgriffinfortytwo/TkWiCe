# shell output - just source it

# need the length of a word ...
set stringbottlelength [ string length [::msgcat::mc {Bottle}] ]
if { [ string length [::msgcat::mc {Bottles}] ] > ${stringbottlelength} } { set stringbottlelength [ string length [::msgcat::mc {Bottles}] ] }

foreach wine [ glob -nocomplain [ file join ${datadir} ${database} * ] ] {
  # get rid of maybe old values
  set land     {}
  set domain   {}
  set winename {}
  set vineyard {}
  set year     {}
  # overwrite the blanked values
  source ${wine}
  # filter empty quantities
  if { ${amount} == {0} } { continue }
  # textblock land
  if { ${land} != {} } {
    set land "\[${land}\]"
  } else {
    set land "\[  \]"
  }
  # textblock show_wine
  if { ${winename} != {} && ${vineyard} != {} } {
    set show_wine "${domain} - ${winename} (${vineyard})"
  } elseif { ${winename} != {} } {
    set show_wine "${domain} - ${winename}"
  } else {
    set show_wine ${domain}
  }
  if { ${domain} == {} && ${winename} != {} } {
    if { ${vineyard} != {} } {
      set show_wine "${winename} (${vineyard})"
    } else {
      set show_wine ${winename}
    }
  }
  if { [ string length ${year} ] == {4} } {
    set show_wine "${show_wine}, ${year}                                                                                "
  } else {
    set show_wine "${show_wine}                                                                                "
  }
  # textblock show_amount
  if { ${amount} == {1} } {
    set show_amount " ${amount} [::msgcat::mc {Bottle}]"
  } else {
    set show_amount " ${amount} [::msgcat::mc {Bottles}]"
  }
  # put the together to 80 chars
  set show_wine [ string range ${show_wine} 0 [ expr "63 - [ string length ${stringbottlelength} ] - [ string length ${amount} ]" ] ]
  # build list of the wine
  lappend winelist "${land} ${show_wine} ${show_amount}"
}
set winelist [ lsort ${winelist} ]
foreach entry ${winelist} { puts ${entry} }
