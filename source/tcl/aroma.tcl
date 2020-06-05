# outsourced from editwine.tcl

# startup only if window not present
if { [ winfo exists .aroma ] } {
  raise .aroma .
} else {

  global closebutton okaybutton

  # window stuff
  toplevel     .aroma
  wm title     .aroma [::msgcat::mc {Aroma: Choose}]
  wm geometry  .aroma +[ winfo pointerx . ]+[ winfo pointery . ]
  focus        .aroma
  wm transient .aroma .

  # build gui
	if { ${bTtk} } {
  	ttk::labelframe .aroma.preview -text [::msgcat::mc {Selection}]
	} else {
		labelframe .aroma.preview -text [::msgcat::mc {Selection}] -padx 2 -pady 2
	}
    label .aroma.preview.text -text {} -font $titlefont -justify left
  pack .aroma.preview.text -side left -fill x -expand true
  frame     .aroma.choose
  listbox   .aroma.choose.box1 -height 20 -width 20 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 1 -highlightcolor ${selectbackground} -yscrollcommand {.aroma.choose.scroll1 set}
	if { ${bTtk} } {
  	ttk::scrollbar .aroma.choose.scroll1 -command {.aroma.choose.box1 yview} -orient vertical
	} else {
		scrollbar .aroma.choose.scroll1 -command {.aroma.choose.box1 yview} -orient vertical
	}
  listbox   .aroma.choose.box2 -height 20 -width 20 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 1 -highlightcolor ${selectbackground} -yscrollcommand {.aroma.choose.scroll2 set}
	if { ${bTtk} } {
  	ttk::scrollbar .aroma.choose.scroll2 -command {.aroma.choose.box2 yview} -orient vertical
  } else {
		scrollbar .aroma.choose.scroll2 -command {.aroma.choose.box2 yview} -orient vertical
	}
	listbox   .aroma.choose.box3 -height 20 -width 20 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 1 -highlightcolor ${selectbackground} -yscrollcommand {.aroma.choose.scroll3 set}
	if { ${bTtk} } {
  	ttk::scrollbar .aroma.choose.scroll3 -command {.aroma.choose.box3 yview} -orient vertical
  } else {
		scrollbar .aroma.choose.scroll3 -command {.aroma.choose.box3 yview} -orient vertical
	}
	pack .aroma.choose.box1    -side left -fill both -expand true
  pack .aroma.choose.scroll1 -side left -fill y
  pack .aroma.choose.box2    -side left -fill both -expand true
  pack .aroma.choose.scroll2 -side left -fill y
  pack .aroma.choose.box3    -side left -fill both -expand true
  pack .aroma.choose.scroll3 -side left -fill y
  frame  .aroma.menu
    button .aroma.menu.ok -image ${okaybutton} -text [::msgcat::mc {Take Over}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -state disabled -command {
      set aroma${aromabutton} [ .aroma.preview.text cget -text ]
      destroy .aroma
    }
    button .aroma.menu.abort -image ${closebutton} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { destroy .aroma }
  pack .aroma.menu.ok .aroma.menu.abort -side left -fill x -expand true
  pack .aroma.preview -side top -padx 5 -pady 5 -fill x
  pack .aroma.choose  -side top -padx 5 -pady 5 -fill both -expand true
  pack .aroma.menu    -side top -padx 5 -pady 5 -fill x

  # bindings for mouse scroll button on windows ...
  bind .aroma.choose.box1 <Enter> { focus .aroma.choose.box1 }
  bind .aroma.choose.box2 <Enter> { focus .aroma.choose.box2 }
  bind .aroma.choose.box3 <Enter> { focus .aroma.choose.box3 }

  # window placement - mousepointer in the middle ...
  tkwait visibility .aroma
  set xposition_aroma [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .aroma ] / 2" ]" ]
  set yposition_aroma [ expr "[ winfo pointery . ] - [ expr "[ winfo height .aroma ] / 2" ]" ]
  if { ${xposition_aroma} < {0} } { set xposition_aroma {0} }
  if { ${yposition_aroma} < {0} } { set yposition_aroma {0} }
  if { [ expr "[ winfo width  .aroma ] + ${xposition_aroma}" ] > [ winfo screenwidth  . ] } { set xposition_aroma [ expr "[ winfo screenwidth  . ] - [ winfo width  .aroma ]" ] }
  if { [ expr "[ winfo height .aroma ] + ${yposition_aroma}" ] > [ winfo screenheight . ] } { set yposition_aroma [ expr "[ winfo screenheight . ] - [ winfo height .aroma ]" ] }
  wm geometry .aroma +${xposition_aroma}+${yposition_aroma}

  # get list from aroma-file
  set aromalist {}
  set readchannel [ open [ file join ${prog_dir} ext aroma.${nls} ] r ]
  foreach entry [ read -nonewline ${readchannel} ] {
    lappend aromalist ${entry}
  }
  close ${readchannel}
  # list of aroma1, aroma2 and aroma3
  set list_aroma1 {}
  set list_aroma1_2 {}
  set list_aroma2 {}
  set list_aroma2_2 {}
  set list_aroma3 {}
  set list_aroma3_2 {}
  set number {0}
  while { ${number} <= [ llength ${aromalist} ] } {
    lappend list_aroma1 [ lindex ${aromalist} ${number} ]
    incr number
    lappend list_aroma2 [ lindex ${aromalist} ${number} ]
    incr number
    lappend list_aroma3 [ lindex ${aromalist} ${number} ]
    incr number
  }
  # 1st box
  foreach entry ${list_aroma1} {
    if { [ regexp -nocase [list ${entry}] ${list_aroma1_2} ] == {0} } {
      lappend list_aroma1_2 ${entry}
    }
  }
  foreach entry ${list_aroma1_2} {
    .aroma.choose.box1 insert end ${entry}
  }
  # 2nd box
  foreach entry ${list_aroma2} {
    if { [ regexp -nocase [list ${entry}] ${list_aroma2_2} ] == {0} } {
      lappend list_aroma2_2 ${entry}
    }
  }
  foreach entry ${list_aroma2_2} {
    .aroma.choose.box2 insert end ${entry}
  }
  # 3rd box
  foreach entry ${list_aroma3} {
    if { [ regexp -nocase [list ${entry}] ${list_aroma3_2} ] == {0} } {
      lappend list_aroma3_2 ${entry}
    }
  }
  foreach entry ${list_aroma3_2} {
    .aroma.choose.box3 insert end ${entry}
  }

  # bindings box1
  bind .aroma.choose.box1 <ButtonRelease-1> {
    # clear other boxes
    .aroma.choose.box2 delete 0 [ .aroma.choose.box2 size ]
    .aroma.choose.box3 delete 0 [ .aroma.choose.box3 size ]
    # list of aroma2 and aroma3
    set list_aroma2 {}
    set list_aroma3 {}
    set number {0}
    while { ${number} <= [ llength ${aromalist} ] } {
      if { [ lindex ${aromalist} ${number} ] == [ .aroma.choose.box1 get [ .aroma.choose.box1 curselection ] ] } {
        incr number
        lappend list_aroma2 [ lindex ${aromalist} ${number} ]
        incr number
        lappend list_aroma3 [ lindex ${aromalist} ${number} ]
        incr number
      } else {
        incr number 3
      }
    }
    # 2nd box
    set list_aroma2_2 {}
    foreach entry ${list_aroma2} {
      if { [ regexp -nocase [list ${entry}] ${list_aroma2_2} ] == {0} } {
        lappend list_aroma2_2 ${entry}
      }
    }
    foreach entry ${list_aroma2_2} {
      .aroma.choose.box2 insert end ${entry}
    }
    # 3rd box
    set list_aroma3_2 {}
    foreach entry ${list_aroma3} {
      if { [ regexp -nocase [list ${entry}] ${list_aroma3_2} ] == {0} } {
        lappend list_aroma3_2 ${entry}
      }
    }
    foreach entry ${list_aroma3_2} {
      .aroma.choose.box3 insert end ${entry}
    }
    .aroma.preview.text configure -text [ .aroma.choose.box1 get [ .aroma.choose.box1 curselection ] ]
    if { [ .aroma.preview.text cget -text ] != {} } { .aroma.menu.ok configure -state normal }
  }
  # bindings box2
  bind .aroma.choose.box2 <ButtonRelease-1> {
    # clear last box
    .aroma.choose.box3 delete 0 [ .aroma.choose.box3 size ]
    # list of aroma2 and aroma3
    set list_aroma3 {}
    set number {0}
    while { ${number} <= [ llength ${aromalist} ] } {
      if { [ lindex ${aromalist} [ expr "${number} + 1" ] ] == [ .aroma.choose.box2 get [ .aroma.choose.box2 curselection ] ] } {
        incr number 2
        lappend list_aroma3 [ lindex ${aromalist} ${number} ]
        incr number
      } else {
        incr number 3
      }
    }
    # 3rd box
    set list_aroma3_2 {}
    foreach entry ${list_aroma3} {
      if { [ regexp -nocase [list ${entry}] ${list_aroma3_2} ] == {0} } {
        lappend list_aroma3_2 ${entry}
      }
    }
    foreach entry ${list_aroma3_2} {
      .aroma.choose.box3 insert end ${entry}
    }
    .aroma.preview.text configure -text [ .aroma.choose.box2 get [ .aroma.choose.box2 curselection ] ]
    if { [ .aroma.preview.text cget -text ] != {} } { .aroma.menu.ok configure -state normal }
  }
  # bindings box3
  bind .aroma.choose.box3 <ButtonRelease-1> {
    .aroma.preview.text configure -text [ .aroma.choose.box3 get [ .aroma.choose.box3 curselection ] ]
    if { [ .aroma.preview.text cget -text ] != {} } { .aroma.menu.ok configure -state normal }
  }
  # binding double box1
  bind .aroma.choose.box1 <Double-1> {
    set aroma$aromabutton [ .aroma.preview.text cget -text ]
    destroy .aroma
  }
  # binding double box2
  bind .aroma.choose.box2 <Double-1> {
    set aroma$aromabutton [ .aroma.preview.text cget -text ]
    destroy .aroma
  }
  # binding double box3
  bind .aroma.choose.box3 <Double-1> {
    set aroma$aromabutton [ .aroma.preview.text cget -text ]
    destroy .aroma
  }
}
