# script to determine if there is an update available
# source it for usage
# required informations:
# prog_dir


# we need HTTP
package require http


# where to find the necessary information ...
set homeurl {http://www.tkwice.org/}
# set homeurl {http://localhost/~jo/tkwice.org/tkwice/}
set versionurl "${homeurl}latest.txt"


# get localversion
set readchannel [ open [ file join ${prog_dir} VERSION ] r ]
set versionfile_content [ read ${readchannel} ]
close ${readchannel}
set versionfile_list [ split [ lindex ${version_content} 0 ] . ]
set existingversion "[ lindex ${versionfile_list} 0 ].[ lindex ${versionfile_list} 1 ].[ lindex ${versionfile_list} 2 ]"


# get webservers version
set availableversion {}
catch {
  set token [::http::geturl ${versionurl}]
  ::http::wait ${token}
  set querryresult [::http::data ${token}] ; list
  ::http::cleanup ${token}
  set availableversion [ string trimright ${querryresult} ]
}

# inform the user about the result
if { [ string length ${availableversion} ] != {0} && [ string length ${availableversion} ] < {10} } {
  if { ${existingversion} eq ${availableversion} } {
    # no update
    set infotitle [::msgcat::mc {No Update Available}]
    set infotext  [::msgcat::mc {You're already running the latest available version.}]
  } else {
    # split them up
    set newversionavailable {true}
    set existingversion  [ split ${existingversion} {.} ]
    set availableversion [ split ${availableversion} {.} ]
    # check if this is an alpha version
    if { [ lindex ${existingversion} 0 ] > [ lindex ${availableversion} 0 ] } {
      set newversionavailable {false}
    } elseif { [ lindex ${existingversion} 0 ] == [ lindex ${availableversion} 0 ] } {
      if { [ lindex ${existingversion} 1 ] > [ lindex ${availableversion} 1 ] } {
        set newversionavailable {false}
      } elseif { [ lindex ${existingversion} 1 ] == [ lindex ${availableversion} 1 ] } {
        if { [ lindex ${existingversion} 2 ] > [ lindex ${availableversion} 2 ] } {
          set newversionavailable {false}
        }
      }
    }
    set existingversion "[ lindex ${existingversion} 0 ].[ lindex ${existingversion} 1 ].[ lindex ${existingversion} 2 ]"
    set availableversion "[ lindex ${availableversion} 0 ].[ lindex ${availableversion} 1 ].[ lindex ${availableversion} 2 ]"
    if { ${newversionavailable} == {false} } {
      # alpha version
      set infotitle [::msgcat::mc {Alpha Version}]
      set infotext  [::msgcat::mc {No valid results possible.}]
    } else {
      # update available
      set infotitle [::msgcat::mc {Update Available}]
      set infotext  "[::msgcat::mc {This Version:}] ${existingversion}\n[::msgcat::mc {Available Version:}] ${availableversion}\n\n[::msgcat::mc {To get the latest release visit:}]\n${homeurl}"
    }
    # unsplit
  }
} elseif { [ string length ${availableversion} ] > {9} } {
  # we get something wrong
  set infotitle [::msgcat::mc {Error}]
  set infotext  "[::msgcat::mc {Instead of sending version informations the server said:}]\n\n${availableversion}"
} else {
  # failed
  set infotitle [::msgcat::mc {Host Unreachable}]
  set infotext  [::msgcat::mc {Unable to connect to the server.}]
}
set infotype  {info}
source [ file join ${prog_dir} tcl info.tcl ]
