# update the config or database during first start of a new version
# outsourced from tkwice.tcl


# update dabase (rose) if version is 0.5 alpha1 or before
if { [ file exists [ file join ${datadir} conf-0.1 ] ] || [ file exists [ file join ${datadir} conf-0.2 ] ] || [ file exists [ file join ${datadir} conf-0.3 ] ] || [ file exists [ file join ${datadir} conf-0.4 ] ] || [ file exists [ file join ${datadir} conf-0.5 ] ] } {
  foreach wine [ glob -nocomplain [ file join ${datadir} ${database} * ] ] {
    set color {}
    source ${wine}
    if { ${color} != {Red} && ${color} != {White} } {
      set color "Ros\u00e9"
      set writeupdate [ open [ file join ${datadir} ${database} ${wine} ] a ]
      puts ${writeupdate} "set color \{${color}\}"
      close ${writeupdate}
    }
  }
}


# rename old configuration files
if { ! [ file exists ${conffile} ] } {
  if { [ file exists [ file join ${datadir} conf-0.1 ] ] } { file rename [ file join ${datadir} conf-0.1 ] ${conffile} }
  if { [ file exists [ file join ${datadir} conf-0.2 ] ] } { file rename [ file join ${datadir} conf-0.2 ] ${conffile} }
  if { [ file exists [ file join ${datadir} conf-0.3 ] ] } { file rename [ file join ${datadir} conf-0.3 ] ${conffile} }
  if { [ file exists [ file join ${datadir} conf-0.4 ] ] } { file rename [ file join ${datadir} conf-0.4 ] ${conffile} }
  if { [ file exists [ file join ${datadir} conf-0.5 ] ] } { file rename [ file join ${datadir} conf-0.5 ] ${conffile} }
  if { [ file exists [ file join ${datadir} prefs-0.5 ] ] } { file rename [ file join ${datadir} prefs-0.5 ] ${conffile} }
}


# import old vintnerfile to dealer-database
if { [ file exists [ file join ${datadir} vintner ] ] && ![ file exists [ file join ${datadir} dealer ] ] } {
  # read old file
  set readchannel [ open [ file join ${datadir} vintner ] r ]
  set vintnerlist [ read ${readchannel} ]
  close ${readchannel}
  set importvintnerlist [ lsort -dictionary ${vintnerlist} ]
  # build up a valid new list
  set importdealerlist {}
  foreach entry ${importvintnerlist} {
    set newlistitem {}
    set blank {}
    lappend newlistitem ${entry}
    lappend newlistitem ${blank}
    lappend importdealerlist ${newlistitem}
  }
  # write new file
  set initchannel [ open [ file join ${datadir} dealer ] w ]
  foreach entry ${importdealerlist} {
    puts ${initchannel} ${entry}
  }
  close ${initchannel}
}


# update and complete configuration
if { [ file exists ${conffile} ] } {
  # take sure that the configuration file is complete
  # first read it
  set readchannel [ open ${conffile} r ]
  set content_of_conf [ read -nonewline ${readchannel} ]
  close ${readchannel}
  set writeupdate [ open ${conffile} a ]
  # add missing stuff
  if { ! [ regexp {set nls}                   ${content_of_conf} ] } { puts ${writeupdate} "set nls \{en\}" }
  if { ! [ regexp {set webbrowser}            ${content_of_conf} ] } { puts ${writeupdate} "set webbrowser \{\}" }
  if { ! [ regexp {set picopenpath}           ${content_of_conf} ] } { puts ${writeupdate} "set picopenpath \{[ string trimright [ file nativename ~ ] {\\} ]\}" }
  if { ! [ regexp {set viewmode}              ${content_of_conf} ] } { puts ${writeupdate} "set viewmode \{buttons\}" }
  if { ! [ regexp {set glassname01}           ${content_of_conf} ] } { puts ${writeupdate} "set glassname01 \{\}" }
  if { ! [ regexp {set glassname02}           ${content_of_conf} ] } { puts ${writeupdate} "set glassname02 \{\}" }
  if { ! [ regexp {set glassname03}           ${content_of_conf} ] } { puts ${writeupdate} "set glassname03 \{\}" }
  if { ! [ regexp {set glassname04}           ${content_of_conf} ] } { puts ${writeupdate} "set glassname04 \{\}" }
  if { ! [ regexp {set glassname05}           ${content_of_conf} ] } { puts ${writeupdate} "set glassname05 \{\}" }
  if { ! [ regexp {set glassname06}           ${content_of_conf} ] } { puts ${writeupdate} "set glassname06 \{\}" }
  if { ! [ regexp {set glassname07}           ${content_of_conf} ] } { puts ${writeupdate} "set glassname07 \{\}" }
  if { ! [ regexp {set glassname08}           ${content_of_conf} ] } { puts ${writeupdate} "set glassname08 \{\}" }
  if { ! [ regexp {set glassname09}           ${content_of_conf} ] } { puts ${writeupdate} "set glassname09 \{\}" }
  if { ! [ regexp {set glassname10}           ${content_of_conf} ] } { puts ${writeupdate} "set glassname10 \{\}" }
  if { ! [ regexp {set manualpoints}          ${content_of_conf} ] } { puts ${writeupdate} "set manualpoints \{false\}" }
  if { ! [ regexp {set tooltips}              ${content_of_conf} ] } { puts ${writeupdate} "set tooltips \{true\}" }
  if { ! [ regexp {set grape_add_syn}         ${content_of_conf} ] } { puts ${writeupdate} "set grape_add_syn \{true\}" }
  if { ! [ regexp {set grape_add_switch}      ${content_of_conf} ] } { puts ${writeupdate} "set grape_add_switch \{false\}" }
  if { ! [ regexp {set grape_add_synonly}     ${content_of_conf} ] } { puts ${writeupdate} "set grape_add_synonly \{false\}" }
  if { ! [ regexp {set grape_add_lab}         ${content_of_conf} ] } { puts ${writeupdate} "set grape_add_lab \{false\}" }
  if { ! [ regexp {set grape_add_labnote}     ${content_of_conf} ] } { puts ${writeupdate} "set grape_add_labnote \{true\}" }
  if { ! [ regexp {set grape_add_labnote}     ${content_of_conf} ] } { puts ${writeupdate} "set grape_add_labnote \{false\}" }
  if { ! [ regexp {set grape_add_nat}         ${content_of_conf} ] } { puts ${writeupdate} "set grape_add_nat \{false\}" }
  if { ! [ regexp {set grape_add_scanrelated} ${content_of_conf} ] } { puts ${writeupdate} "set grape_add_scanrelated \{false\}" }
  if { ! [ regexp {set smallfont}             ${content_of_conf} ] } {
    set existingfontfamily [ font actual ${textfont} -family ]
    set existingfontsize [ font actual ${textfont} -size ]
    set titlefont "-family \"${existingfontfamily}\" -size ${existingfontsize} -weight bold"
    set textfont "-family \"${existingfontfamily}\" -size ${existingfontsize} -weight normal"
    set smallfont "-family \"${existingfontfamily}\" -size [ expr "${existingfontsize} -1" ] -weight normal"
    set smallitalicfont "-family \"${existingfontfamily}\" -size [ expr "${existingfontsize} -1" ] -weight normal -slant italic"
    set listfont "-family courier -size ${existingfontsize} -weight normal"
    puts ${writeupdate} "set titlefont \{$titlefont\}"
    puts ${writeupdate} "set textfont \{$textfont\}"
    puts ${writeupdate} "set smallfont \{$smallfont\}"
    puts ${writeupdate} "set smallitalicfont \{$smallitalicfont\}"
    puts ${writeupdate} "set listfont \{$listfont\}"
  }
  if { ! [ regexp {set tempscale}              ${content_of_conf} ] } { puts ${writeupdate} "set tempscale \{celsius\}" }
  # update version info and close the config file
  puts ${writeupdate} "set configmajor \{${majorversion}\}"
  puts ${writeupdate} "set configminor \{${minorversion}\}"
  puts ${writeupdate} "set configpatch \{${patchlevel}\}"
  close ${writeupdate}
}
