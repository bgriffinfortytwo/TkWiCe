# helper tool for selecting a grape (2 procs)
# outsourced from editwine.tcl


proc scanforgrapesynonyms {select_grape} {
  # proc that scans for secondary synonym grape names
  global grape_add_scanrelated list_grape2
  .help_grape.box.ext.names.box delete 0 end
  if { ${grape_add_scanrelated} == {true} } {
    set number2 {0}
    set synonymname [ .help_grape.box.ext.syn.syn3 cget -text ]
    set synonymname2 [ string map "{ [::msgcat::mc {or}] } {|}" ${synonymname} ]
    if { [ llength [ split ${synonymname2} {|} ] ] > 1 } {
      foreach grapeinlist [ split ${synonymname2} {|} ] {
        .help_grape.box.ext.names.box insert end ${grapeinlist}
      }
    } elseif { ${synonymname} != {} } {
      .help_grape.box.ext.names.box insert end ${synonymname}
      while { ${number2} <= [ llength ${list_grape2} ] } {
        if { [ regexp ${synonymname} [ lindex ${list_grape2} [ expr "${number2} + 1" ] ] ] } {
          if { [ lindex ${list_grape2} ${number2} ] != ${select_grape} } {
            .help_grape.box.ext.names.box insert end [ lindex ${list_grape2} ${number2} ]
          }
        }
        incr number2 4
      }
    } else {
      while { ${number2} <= [ llength ${list_grape2} ] } {
        if { [ regexp ${select_grape} [ lindex ${list_grape2} [ expr "${number2} + 1" ] ] ] } {
          if { [ lindex ${list_grape2} ${number2} ] != ${select_grape} } {
            .help_grape.box.ext.names.box insert end [ lindex ${list_grape2} ${number2} ]
          }
        }
        incr number2 4
      }
    }
  }
}


proc grapeselectionset {} {
  # second proc building the selected text string
  global grape_add_switch grape_add_syn grape_add_lab grape_add_nat grape_add_synonly grape_add_labnote select_grape
  set grapetakeover {}
  if { ${grape_add_switch} == {true} && ${grape_add_syn} == {true} } {
    if { [ .help_grape.box.ext.syn.syn3 cget -text ] != {} } {
      set grapetakeover "[ .help_grape.box.ext.syn.syn3 cget -text ] (${select_grape}; "
    } else {
      set grapetakeover "${select_grape} ("
    }
  } else {
    if { ${grape_add_syn} == {true}  && ${grape_add_synonly} == {true}  && [ .help_grape.box.ext.syn.syn3 cget -text ] != {} } {
      set grapetakeover "[ .help_grape.box.ext.syn.syn3 cget -text ] ("
    } else {
      set grapetakeover "${select_grape} ("
      if { ${grape_add_syn} == {true} && [ .help_grape.box.ext.syn.syn3 cget -text ] != {} } { set grapetakeover "${grapetakeover}[ .help_grape.box.ext.syn.syn3 cget -text ]; " }
    }
  }
  if { ${grape_add_lab} == {true} && [ .help_grape.box.ext.lab.lab2 cget -text ] != {} } {
    set grapetakeover "${grapetakeover}[::msgcat::mc {Lab Hybrid:}] [ .help_grape.box.ext.lab.lab2 cget -text ]"
  } elseif { ${grape_add_labnote} == {true} && [ .help_grape.box.ext.lab.lab2 cget -text ] != {} } {
    set grapetakeover "${grapetakeover}[::msgcat::mc {Lab Grape}]"
  } elseif { ${grape_add_nat} == {true} && [ .help_grape.box.ext.nat.nat2 cget -text ] != {} } {
    set grapetakeover "${grapetakeover}[::msgcat::mc {Parents:}] [ .help_grape.box.ext.nat.nat2 cget -text ]"
  }
  set grapetakeover "${grapetakeover})"
  set grapetakeover [ string map {{; )} {)}} ${grapetakeover} ]
  set grapetakeover [ string map {() {}} ${grapetakeover} ]
  .help_grape.preview.text configure -text [ string trimright ${grapetakeover} ]
}


# it is a proc ...
proc help_grape {grapenumber} {


# start only once
if { [ winfo exists .help_grape ] } { raise .help_grape . ; return }


# some basic things
global prog_dir titlefont textfont lightcolor midcolor grapenum grape1 grape2 grape3 grape4 grape5 list_grape list_grape2 search closebutton okaybutton grape_add_switch grape_add_syn grape_add_lab grape_add_nat grape_add_synonly grape_add_labnote grape_add_scanrelated select_grape bTtk


# window stuff
toplevel     .help_grape
wm title     .help_grape [::msgcat::mc {Grape}]
wm geometry  .help_grape +[ winfo pointerx . ]+[ winfo pointery . ]
focus        .help_grape
wm transient .help_grape .


# some vars
set list_grape {}
set list_grape2 {}
set search {}
set grapenum ${grapenumber}


# get list from grape-file
set readchannel [ open [ file join ${prog_dir} ext grapes ] r ]
# read it per line
foreach line [ split [ read ${readchannel} ] \n ] {
  # get rid of comments in it
  if { [ string index ${line} 0 ] != {#} } {
    foreach entry ${line} { lappend list_grape2 ${entry} }
  }
}
close ${readchannel}
set number {0}
while { ${number} <= [ llength ${list_grape2} ] } {
  lappend list_grape [ lindex ${list_grape2} ${number} ]
  incr number 4
}
set list_grape [ lsort ${list_grape} ]


# build up window
if { ${bTtk} } {
	ttk::labelframe .help_grape.preview -text [::msgcat::mc {Selection}]
} else {
	labelframe .help_grape.preview -text [::msgcat::mc {Selection}] -padx 2 -pady 2
}
  label .help_grape.preview.text -text {} -font ${titlefont} -justify left -width 70 -height 2
  .help_grape.preview.text configure -wraplength [ winfo reqwidth .help_grape.preview.text ]
pack .help_grape.preview.text -side top -fill x -expand true
if { ${bTtk} } {
	ttk::labelframe .help_grape.search -text [::msgcat::mc {Search}]
} else {
	labelframe .help_grape.search -text [::msgcat::mc {Search}] -padx 2 -pady 2
}
  entry .help_grape.search.text -textvariable search -background ${lightcolor} -highlightthickness 0
  ::conmen .help_grape.search.text
  focus .help_grape.search.text
  bind .help_grape.search.text <KeyRelease> {
    # only if key was not arrow up or down
    if { "%K" == "Up" || "%K" == "Down" } { break }
    update
    .help_grape.box.box delete 0 [ .help_grape.box.box size ]
    foreach entry ${list_grape} {
      if { [ regexp -nocase [list ${search}] ${entry} ] == {0} } { continue }
      if { ${entry} != {} } {
        .help_grape.box.box insert end ${entry}
      }
    }
    if { [ .help_grape.box.box size ] != {0} } {
      .help_grape.box.box selection clear 0 end
      .help_grape.box.box selection set 0
      .help_grape.box.box activate 0
      .help_grape.box.box see 0
      set select_grape [ .help_grape.box.box get 0 ]
      set number2 {0}
      set select_grape2 {}
      while { ${number2} <= [ llength ${list_grape2} ] } {
        if { [ lindex ${list_grape2} ${number2} ] == ${select_grape} } {
          set select_grape2 [ lindex ${list_grape2} [ expr "${number2} + 1" ] ]
          .help_grape.box.ext.syn.syn3 configure -text [ string map [ list { or } " [::msgcat::mc {or}] "] [ lindex ${list_grape2} [ expr "${number2} + 1" ] ] ]
          .help_grape.box.ext.lab.lab2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 2" ] ]
          .help_grape.box.ext.nat.nat2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 3" ] ]
        }
        incr number2 4
      }
      .help_grape.menu.ok configure -state normal
      scanforgrapesynonyms ${select_grape}
      grapeselectionset
    } else {
      .help_grape.preview.text     configure -text {}
      .help_grape.box.ext.syn.syn3 configure -text {}
      .help_grape.box.ext.lab.lab2 configure -text {}
      .help_grape.box.ext.nat.nat2 configure -text {}
      .help_grape.box.ext.names.box delete 0 end
      .help_grape.menu.ok configure -state disabled
    }
  }
pack .help_grape.search.text -side left -fill x -expand true
frame .help_grape.box
  listbox   .help_grape.box.box -width 30 -height 20 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 0 -yscrollcommand {.help_grape.box.scroll set}
	if { ${bTtk} } {
  	ttk::scrollbar .help_grape.box.scroll -command {.help_grape.box.box yview} -orient vertical
	} else {
		scrollbar .help_grape.box.scroll -command {.help_grape.box.box yview} -orient vertical
	}
  frame .help_grape.box.space -width 5 -borderwidth 0
  frame .help_grape.box.ext
		if { ${bTtk} } {
    	ttk::labelframe .help_grape.box.ext.syn -text [::msgcat::mc {Synonym / Family Name}]
		} else {
			labelframe .help_grape.box.ext.syn -text [::msgcat::mc {Synonym / Family Name}]
		}
      label .help_grape.box.ext.syn.syn3 -width 40 -height 2 -anchor nw -relief flat -borderwidth 0 -background ${midcolor} -padx 3
      .help_grape.box.ext.syn.syn3 configure -wraplength [ winfo reqwidth .help_grape.box.ext.syn.syn3 ]
      checkbutton .help_grape.box.ext.syn.syn1 -text [::msgcat::mc {take synonym into account}] -variable grape_add_syn -offvalue "false" -onvalue "true" -command {
        grapeselectionset
        if { ${grape_add_syn} == {true} } {
          .help_grape.box.ext.syn.syn2 configure -state normal
          .help_grape.box.ext.syn.syn4 configure -state normal
        } else {
          .help_grape.box.ext.syn.syn2 configure -state disabled
          .help_grape.box.ext.syn.syn4 configure -state disabled
        }
      }
      checkbutton .help_grape.box.ext.syn.syn2 -text [::msgcat::mc {switch selection and addition}] -variable grape_add_switch -offvalue "false" -onvalue "true" -command {
        if { ${grape_add_switch} == {true} } {
          set grape_add_synonly {false}
        }
        grapeselectionset
      }
      checkbutton .help_grape.box.ext.syn.syn4 -text [::msgcat::mc {synonym only}] -variable grape_add_synonly -offvalue "false" -onvalue "true" -command {
        if { ${grape_add_synonly} == {true} } {
          set grape_add_switch {false}
        }
        grapeselectionset
      }
      pack .help_grape.box.ext.syn.syn3 -side top -anchor w -fill x -padx 5 -pady 5
      pack .help_grape.box.ext.syn.syn1 -side top -anchor w
      pack .help_grape.box.ext.syn.syn2 -side top -anchor w
      pack .help_grape.box.ext.syn.syn4 -side top -anchor w
    pack .help_grape.box.ext.syn -side top -anchor w
    frame .help_grape.box.ext.blank01 -height 10 -borderwidth 0 -pady 0
    pack  .help_grape.box.ext.blank01
		if { ${bTtk} } {
    	ttk::labelframe .help_grape.box.ext.lab -text [::msgcat::mc {Lab Hybrid}]
		} else {
			labelframe .help_grape.box.ext.lab -text [::msgcat::mc {Lab Hybrid}]
		}
      label .help_grape.box.ext.lab.lab2 -width 40 -anchor w -relief flat -borderwidth 0 -background ${midcolor} -padx 3
      checkbutton .help_grape.box.ext.lab.lab3 -text [::msgcat::mc {add a lab hybrid notice}] -variable grape_add_labnote -offvalue "false" -onvalue "true" -command {
        if { ${grape_add_labnote} == {true} } {
          set grape_add_lab {false}
        }
        grapeselectionset
      }
      checkbutton .help_grape.box.ext.lab.lab1 -text [::msgcat::mc {add the lab hybrid parents}] -variable grape_add_lab -offvalue "false" -onvalue "true" -command {
        if { ${grape_add_lab} == {true} } {
          set grape_add_labnote {false}
        }
        grapeselectionset
      }
      pack .help_grape.box.ext.lab.lab2 -side top -anchor w -fill x -padx 5 -pady 5
      pack .help_grape.box.ext.lab.lab3 -side top -anchor w
      pack .help_grape.box.ext.lab.lab1 -side top -anchor w
    pack .help_grape.box.ext.lab -side top -anchor w
    frame .help_grape.box.ext.blank02 -height 10 -borderwidth 0 -pady 0
    pack  .help_grape.box.ext.blank02
		if { ${bTtk} } {
    	ttk::labelframe .help_grape.box.ext.nat -text [::msgcat::mc {Natural Hybrid}]
		} else {
			labelframe .help_grape.box.ext.nat -text [::msgcat::mc {Natural Hybrid}]
		}
      label .help_grape.box.ext.nat.nat2 -width 40 -anchor w -relief flat -borderwidth 0 -background ${midcolor} -padx 3
      checkbutton .help_grape.box.ext.nat.nat1 -text [::msgcat::mc {add the natural parents}] -variable grape_add_nat -offvalue "false" -onvalue "true" -command { grapeselectionset }
      pack .help_grape.box.ext.nat.nat2 -side top -anchor w -fill x -padx 5 -pady 5
      pack .help_grape.box.ext.nat.nat1 -side top -anchor w
    pack .help_grape.box.ext.nat -side top -anchor w
    frame .help_grape.box.ext.blank03 -height 10 -borderwidth 0 -pady 0
    pack  .help_grape.box.ext.blank03
		if { ${bTtk} } {
    	ttk::labelframe .help_grape.box.ext.names
		} else {
			labelframe .help_grape.box.ext.names -padx 5 -pady 5
		}
    checkbutton .help_grape.box.ext.names.check -text [::msgcat::mc {scan for related grape names}] -variable grape_add_scanrelated -offvalue "false" -onvalue "true" -command {
      if { ${grape_add_scanrelated} == {false} || [ .help_grape.box.box curselection ] == {} } {
        .help_grape.box.ext.names.box delete 0 end
      } else {
        scanforgrapesynonyms [ .help_grape.box.box get [ .help_grape.box.box curselection ] ]
      }
    }
    .help_grape.box.ext.names configure -labelwidget .help_grape.box.ext.names.check
      listbox   .help_grape.box.ext.names.box -height 3 -selectmode single -background ${midcolor} -exportselection false -activestyle none -highlightthickness 0 -relief flat -borderwidth 3 -yscrollcommand {.help_grape.box.ext.names.scroll set}
			if { ${bTtk} } {
				ttk::scrollbar .help_grape.box.ext.names.scroll -command {.help_grape.box.ext.names.box yview} -orient vertical
			} else {
				scrollbar .help_grape.box.ext.names.scroll -command {.help_grape.box.ext.names.box yview} -orient vertical
			}
      pack .help_grape.box.ext.names.box -side left -fill both -expand true
      pack .help_grape.box.ext.names.scroll -side left -fill y
    pack .help_grape.box.ext.names -side top -anchor w -fill both -expand true
    if { ${grape_add_syn} == {true} } {
      .help_grape.box.ext.syn.syn1 select
      if { ${grape_add_switch}  == {true} } { .help_grape.box.ext.syn.syn2 select }
      if { ${grape_add_synonly} == {true} } { .help_grape.box.ext.syn.syn4 select }
    } else {
      set grape_add_switch {false}
      .help_grape.box.ext.syn.syn2 configure -state disabled
      set grape_add_synonly {false}
      .help_grape.box.ext.syn.syn4 configure -state disabled
    }
    if { ${grape_add_lab}         == {true} } { .help_grape.box.ext.lab.lab1 select }
    if { ${grape_add_labnote}     == {true} } { .help_grape.box.ext.lab.lab3 select }
    if { ${grape_add_nat}         == {true} } { .help_grape.box.ext.nat.nat1 select }
    if { ${grape_add_scanrelated} == {true} } { .help_grape.box.ext.names.check select }
pack .help_grape.box.box -side left -fill both -expand true
pack .help_grape.box.scroll -side left -fill y
pack .help_grape.box.space -side left -fill y
pack .help_grape.box.ext -side left -fill y
frame .help_grape.menu
  button .help_grape.menu.ok -image ${okaybutton} -text [::msgcat::mc {Take Over}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -state disabled -command {
    set grapenumvar {}
    append grapenumvar grape ${grapenum}
    set $grapenumvar [ .help_grape.preview.text cget -text ]
    set editfield {}
    append editfield .editleft.1.grape ${grapenum} _2.grape ${grapenum}
    ${editfield} configure -textvariable ${grapenumvar}
    destroy .help_grape
  }
  button .help_grape.menu.abort -image ${closebutton} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { destroy .help_grape }
pack .help_grape.menu.ok .help_grape.menu.abort -side left -fill x -expand true
pack .help_grape.preview   -side top -padx 5 -pady 5 -fill x
pack .help_grape.search    -side top -padx 5 -pady 5 -fill x
pack .help_grape.box       -side top -padx 5 -pady 5 -fill both -expand true
pack .help_grape.menu      -side top -padx 5 -pady 5 -fill x


# do something if something is selected
# note: binding to space does not make sense - deleted
bind .help_grape.box.ext.names.box <ButtonRelease-1> {
  if { [ .help_grape.box.ext.names.box size ] != {0} && [ .help_grape.box.ext.names.box curselection ] != {} } {
    .help_grape.box.ext.syn.syn3 configure -text [ .help_grape.box.ext.names.box get [ .help_grape.box.ext.names.box curselection ] ]
    grapeselectionset
  }
}

bind .help_grape.box.box <ButtonRelease-1> {
  if { [ .help_grape.box.box size ] != {0} } {
    .help_grape.menu.ok configure -state normal
    set select_grape [ .help_grape.box.box get [ .help_grape.box.box curselection ] ]
    set number2 {0}
    set select_grape2 {}
    while { ${number2} <= [ llength ${list_grape2} ] } {
      if { [ lindex ${list_grape2} ${number2} ] == ${select_grape} } {
        set select_grape2 [ lindex ${list_grape2} [ expr "${number2} + 1" ] ]
        .help_grape.box.ext.syn.syn3 configure -text [ string map [ list { or } " [::msgcat::mc {or}] "] [ lindex ${list_grape2} [ expr "${number2} + 1" ] ] ]
        .help_grape.box.ext.lab.lab2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 2" ] ]
        .help_grape.box.ext.nat.nat2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 3" ] ]
      }
      incr number2 4
    }
    scanforgrapesynonyms ${select_grape}
    grapeselectionset
  }
}

bind .help_grape.box.box <Double-1> {
  if { [ .help_grape.preview.text cget -text ] != {} } {
    set grapenumvar {}
    append grapenumvar grape ${grapenum}
    set $grapenumvar [ .help_grape.preview.text cget -text ]
    set editfield {}
    append editfield .editleft.1.grape ${grapenum} _2.grape ${grapenum}
    ${editfield} configure -textvariable ${grapenumvar}
    destroy .help_grape
  }
}

bind .help_grape <Return> { .help_grape.menu.ok invoke }

bind .help_grape <Key-Down> {
  if { [ .help_grape.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_grape.box.box curselection ] + 1" ]
    if { ${positionsline} < [ .help_grape.box.box size ] } {
      .help_grape.menu.ok configure -state normal
      .help_grape.box.box selection clear 0 end
      .help_grape.box.box selection set ${positionsline}
      .help_grape.box.box activate ${positionsline}
      .help_grape.box.box see ${positionsline}
      set select_grape [ .help_grape.box.box get [ .help_grape.box.box curselection ] ]
      set number2 {0}
      set select_grape2 {}
      while { ${number2} <= [ llength ${list_grape2} ] } {
        if { [ lindex ${list_grape2} ${number2} ] == ${select_grape} } {
          set select_grape2 [ lindex ${list_grape2} [ expr "${number2} + 1" ] ]
          .help_grape.box.ext.syn.syn3 configure -text [ string map [ list { or } " [::msgcat::mc {or}] "] [ lindex ${list_grape2} [ expr "${number2} + 1" ] ] ]
          .help_grape.box.ext.lab.lab2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 2" ] ]
          .help_grape.box.ext.nat.nat2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 3" ] ]
        }
        incr number2 4
      }
      scanforgrapesynonyms ${select_grape}
      grapeselectionset
    }
  }
}

bind .help_grape <Key-Up> {
  if { [ .help_grape.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_grape.box.box curselection ] - 1" ]
    if { ${positionsline} >= {0} } {
      .help_grape.menu.ok configure -state normal
      .help_grape.box.box selection clear 0 end
      .help_grape.box.box selection set ${positionsline}
      .help_grape.box.box activate ${positionsline}
      .help_grape.box.box see ${positionsline}
      set select_grape [ .help_grape.box.box get [ .help_grape.box.box curselection ] ]
      set number2 {0}
      set select_grape2 {}
      while { ${number2} <= [ llength ${list_grape2} ] } {
        if { [ lindex ${list_grape2} ${number2} ] == ${select_grape} } {
          set select_grape2 [ lindex ${list_grape2} [ expr "${number2} + 1" ] ]
          .help_grape.box.ext.syn.syn3 configure -text [ string map [ list { or } " [::msgcat::mc {or}] "] [ lindex ${list_grape2} [ expr "${number2} + 1" ] ] ]
          .help_grape.box.ext.lab.lab2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 2" ] ]
          .help_grape.box.ext.nat.nat2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 3" ] ]
        }
        incr number2 4
      }
      scanforgrapesynonyms ${select_grape}
      grapeselectionset
    }
  }
}

bind .help_grape <Key-Next> {
  if { [ .help_grape.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_grape.box.box curselection ] + 10" ]
    if { ${positionsline} >= [ .help_grape.box.box size ] } { set  positionsline [ expr "[ .help_grape.box.box size ] - 1" ] }
    if { ${positionsline} < [ .help_grape.box.box size ] } {
      .help_grape.menu.ok configure -state normal
      .help_grape.box.box selection clear 0 end
      .help_grape.box.box selection set ${positionsline}
      .help_grape.box.box activate ${positionsline}
      .help_grape.box.box see ${positionsline}
      set select_grape [ .help_grape.box.box get [ .help_grape.box.box curselection ] ]
      set number2 {0}
      set select_grape2 {}
      while { ${number2} <= [ llength ${list_grape2} ] } {
        if { [ lindex ${list_grape2} ${number2} ] == ${select_grape} } {
          set select_grape2 [ lindex ${list_grape2} [ expr "${number2} + 1" ] ]
          .help_grape.box.ext.syn.syn3 configure -text [ string map [ list { or } " [::msgcat::mc {or}] "] [ lindex ${list_grape2} [ expr "${number2} + 1" ] ] ]
          .help_grape.box.ext.lab.lab2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 2" ] ]
          .help_grape.box.ext.nat.nat2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 3" ] ]
        }
        incr number2 4
      }
      scanforgrapesynonyms ${select_grape}
      grapeselectionset
    }
  }
}

bind .help_grape <Key-Prior> {
  if { [ .help_grape.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_grape.box.box curselection ] - 10" ]
    if { ${positionsline} < {0} } { set positionsline 0 }
    if { ${positionsline} >= {0} } {
      .help_grape.menu.ok configure -state normal
      .help_grape.box.box selection clear 0 end
      .help_grape.box.box selection set ${positionsline}
      .help_grape.box.box activate ${positionsline}
      .help_grape.box.box see ${positionsline}
      set select_grape [ .help_grape.box.box get [ .help_grape.box.box curselection ] ]
      set number2 {0}
      set select_grape2 {}
      while { ${number2} <= [ llength ${list_grape2} ] } {
        if { [ lindex ${list_grape2} ${number2} ] == ${select_grape} } {
          set select_grape2 [ lindex ${list_grape2} [ expr "${number2} + 1" ] ]
          .help_grape.box.ext.syn.syn3 configure -text [ string map [ list { or } " [::msgcat::mc {or}] "] [ lindex ${list_grape2} [ expr "${number2} + 1" ] ] ]
          .help_grape.box.ext.lab.lab2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 2" ] ]
          .help_grape.box.ext.nat.nat2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 3" ] ]
        }
        incr number2 4
      }
      scanforgrapesynonyms ${select_grape}
      grapeselectionset
    }
  }
}

bind .help_grape <Key-Home> {
  if { [ .help_grape.box.box size ] != {0} } {
    update
    .help_grape.menu.ok configure -state normal
    .help_grape.box.box selection clear 0 end
    .help_grape.box.box selection set 0
    .help_grape.box.box activate 0
    .help_grape.box.box see 0
    set select_grape [ .help_grape.box.box get [ .help_grape.box.box curselection ] ]
    set number2 {0}
    set select_grape2 {}
    while { ${number2} <= [ llength ${list_grape2} ] } {
      if { [ lindex ${list_grape2} ${number2} ] == ${select_grape} } {
        set select_grape2 [ lindex ${list_grape2} [ expr "${number2} + 1" ] ]
        .help_grape.box.ext.syn.syn3 configure -text [ string map [ list { or } " [::msgcat::mc {or}] "] [ lindex ${list_grape2} [ expr "${number2} + 1" ] ] ]
        .help_grape.box.ext.lab.lab2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 2" ] ]
        .help_grape.box.ext.nat.nat2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 3" ] ]
      }
      incr number2 4
    }
    scanforgrapesynonyms ${select_grape}
    grapeselectionset
  }
}

bind .help_grape <Key-End> {
  if { [ .help_grape.box.box size ] != {0} } {
    update
    .help_grape.menu.ok configure -state normal
    .help_grape.box.box selection clear 0 end
    .help_grape.box.box selection set end
    .help_grape.box.box activate end
    .help_grape.box.box see end
    set select_grape [ .help_grape.box.box get [ .help_grape.box.box curselection ] ]
    set number2 {0}
    set select_grape2 {}
    while { ${number2} <= [ llength ${list_grape2} ] } {
      if { [ lindex ${list_grape2} ${number2} ] == ${select_grape} } {
        set select_grape2 [ lindex ${list_grape2} [ expr "${number2} + 1" ] ]
        .help_grape.box.ext.syn.syn3 configure -text [ string map [ list { or } " [::msgcat::mc {or}] "] [ lindex ${list_grape2} [ expr "${number2} + 1" ] ] ]
        .help_grape.box.ext.lab.lab2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 2" ] ]
        .help_grape.box.ext.nat.nat2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 3" ] ]
      }
      incr number2 4
    }
    scanforgrapesynonyms ${select_grape}
    grapeselectionset
  }
}

bind .help_grape <Key-Escape>    { destroy .help_grape }
bind .help_grape <Control-Key-q> { destroy .help_grape }


# binding for input-focus
bind .help_grape.box.box <Enter> { focus .help_grape.box.box }
bind .help_grape.box.box <Leave> { focus .help_grape.search.text }


# pack grapes in listbox
foreach entry $list_grape {
  if { ${entry} != {} } {
    .help_grape.box.box insert end ${entry}
  }
}


# preselct first entry
if { [ .help_grape.box.box size ] != {0} } {
  .help_grape.box.box selection clear 0 end
  .help_grape.box.box selection set 0
  .help_grape.box.box activate 0
  .help_grape.box.box see 0
  set select_grape [ .help_grape.box.box get 0 ]
  set number2 {0}
  set select_grape2 {}
  while { ${number2} <= [ llength ${list_grape2} ] } {
    if { [ lindex ${list_grape2} ${number2} ] == ${select_grape} } {
      set select_grape2 [ lindex ${list_grape2} [ expr "${number2} + 1" ] ]
      .help_grape.box.ext.syn.syn3 configure -text [ string map [ list { or } " [::msgcat::mc {or}] "] [ lindex ${list_grape2} [ expr "${number2} + 1" ] ] ]
      .help_grape.box.ext.lab.lab2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 2" ] ]
      .help_grape.box.ext.nat.nat2 configure -text [ lindex ${list_grape2} [ expr "${number2} + 3" ] ]
    }
    incr number2 4
  }
  .help_grape.menu.ok configure -state normal
  scanforgrapesynonyms ${select_grape}
  grapeselectionset
}


# place the window
tkwait visibility .help_grape
set xposition_info [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .help_grape ] / 2" ]" ]
set yposition_info [ expr "[ winfo pointery . ] - [ expr "[ winfo height .help_grape ] / 2" ]" ]
if { ${xposition_info} < {0} } { set xposition_info {0} }
if { ${yposition_info} < {0} } { set yposition_info {0} }
if { [ expr "[ winfo width  .help_grape ] + ${xposition_info}" ] > [ winfo screenwidth  . ] } { set xposition_info [ expr "[ winfo screenwidth  . ] - [ winfo width  .help_grape ]" ] }
if { [ expr "[ winfo height .help_grape ] + ${yposition_info}" ] > [ winfo screenheight . ] } { set yposition_info [ expr "[ winfo screenheight . ] - [ winfo height .help_grape ]" ] }
wm geometry .help_grape +${xposition_info}+${yposition_info}


# close the proc
}
