# manages groups - file is to be sourced from main window
# needs grouplist


# close the wine group selection window if available
if { [ winfo exists .groupsel ] } { destroy .groupsel }


# startup only if window does not exist
if { [ winfo exists .groupman ] } {
  raise .groupman .
} else {


# okay, is not shown yet - open it


# window stuff
toplevel     .groupman
wm title     .groupman "TkWiCe [::msgcat::mc {Group Manager}]"
wm resizable .groupman false true
wm geometry  .groupman +[ winfo pointerx . ]+[ winfo pointery . ]
focus        .groupman


# other vars
set newgroup {}
set editgroupname {}


# create a nice window
frame .groupman.box
  listbox   .groupman.box.box -width 12 -height 7 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 0 -yscrollcommand {.groupman.box.scroll set}
	if { ${bTtk} } {
  	ttk::scrollbar .groupman.box.scroll -command {.groupman.box.box yview} -orient vertical
	} else {
		scrollbar .groupman.box.scroll -command {.groupman.box.box yview} -orient vertical
	}
  frame .groupman.box.blank -width 5 -borderwidth 0
  frame .groupman.box.frame
		if { ${bTtk} } {
    	ttk::labelframe .groupman.box.frame.new -text [::msgcat::mc {new group}]
		} else {
			labelframe .groupman.box.frame.new -text [::msgcat::mc {new group}] -padx 3 -pady 3
		}
      entry .groupman.box.frame.new.entry -width 12 -textvariable newgroup -background ${lightcolor} -highlightthickness 0 -validate key -vcmd { checktext %W %v %i %S }
      ::conmen .groupman.box.frame.new.entry
      proc trace_newgroup_id {} {
        global newgroup grouplist
        if { [ winfo exists .groupman.box.frame.new.ok ] } {
          if { [ string length ${newgroup} ] > {0} && [ lsearch [ lindex ${grouplist} 0 ] ${newgroup} ] == {-1} } {
            .groupman.box.frame.new.ok configure -state normal
          } else {
            .groupman.box.frame.new.ok configure -state disabled
          }
        }
      }
      trace variable newgroup w "trace_newgroup_id ;#"
      button .groupman.box.frame.new.ok -image ${groupadd} -text [::msgcat::mc {add}] -compound left -pady 0 -padx 3 -relief raised -borderwidth 1 -state disabled -command {
        lappend grouplist "\{${newgroup}\}"
        set grouplist [ lsort -dictionary ${grouplist} ]
        set initchannel [ open ${groupfile} w ]
        foreach entry ${grouplist} { puts ${initchannel} ${entry} }
        close ${initchannel}
        addmenugroups
        .groupman.box.box delete 0 end
        foreach groupname ${grouplist} {
          if { ${groupname} != {} } { .groupman.box.box insert end [ lindex ${groupname} 0 ] }
        }
        set groupindexnumber [ lsearch -exact ${grouplist} "\{${newgroup}\}" ]
        .groupman.box.box selection set ${groupindexnumber}
        .groupman.box.box activate ${groupindexnumber}
        .groupman.box.box see ${groupindexnumber}
        set editgroupname ${newgroup}
        set newgroup {}
      }
    bind .groupman.box.frame.new.entry <Return> { .groupman.box.frame.new.ok invoke }
    pack .groupman.box.frame.new.entry .groupman.box.frame.new.ok -side top -fill x
  pack .groupman.box.frame.new -side top
    frame .groupman.box.frame.blank -height 10
  pack .groupman.box.frame.blank -side top
		if { ${bTtk} } {
    	ttk::labelframe .groupman.box.frame.edit -text [::msgcat::mc {change}]
		} else {
			labelframe .groupman.box.frame.edit -text [::msgcat::mc {change}] -padx 3 -pady 3
		}
      entry .groupman.box.frame.edit.entry -width 12 -textvariable editgroupname -background ${lightcolor} -highlightthickness 0 -state disabled -validate key -vcmd { checktext %W %v %i %S }
      ::conmen .groupman.box.frame.edit.entry
      proc trace_editgroup_id {} {
        global editgroupname grouplist
        if { [ winfo exists .groupman.box.frame.new.ok ] } {
          if { [ string length ${editgroupname} ] > {0} } {
            .groupman.box.frame.edit.ok    configure -state normal
            .groupman.box.frame.edit.del   configure -state normal
            .groupman.box.frame.edit.entry configure -state normal
            if { ${editgroupname} == [ .groupman.box.box get [ .groupman.box.box curselection ] ] } { .groupman.box.frame.edit.ok configure -state disabled }
            if { [ lsearch [ .groupman.box.box get 0 end ] ${editgroupname} ] != {-1} } {
              .groupman.box.frame.edit.ok  configure -state disabled
            } else {
              .groupman.box.frame.edit.del configure -state disabled
            }
          } else {
            .groupman.box.frame.edit.ok    configure -state disabled
            .groupman.box.frame.edit.del   configure -state disabled
          }
        }
      }
      trace variable editgroupname w "trace_editgroup_id ;#"
      button .groupman.box.frame.edit.ok  -image ${change}  -text [::msgcat::mc {rename}] -compound left -pady 0 -padx 3 -relief raised -borderwidth 1 -state disabled -command {
        set groupindexcounter {0}
        set actualgroupselection [ .groupman.box.box get [ .groupman.box.box curselection ] ]
        if { [ .winelist.filter.show.group cget -text ] == ${actualgroupselection} } { .winelist.filter.show.group configure -text ${editgroupname} }
        foreach entry ${grouplist} {
          if { [ lindex ${entry} 0 ] == ${actualgroupselection} } {
            set groupindexnumber ${groupindexcounter}
            set grouplistnumbers [ lrange ${entry} 1 end ]
          }
          incr groupindexcounter
        }
        if { ${grouplistnumbers} == {} } {
          set grouplist [ lreplace ${grouplist} ${groupindexnumber} ${groupindexnumber} "\{${editgroupname}\}" ]
        } else {
          set grouplist [ lreplace ${grouplist} ${groupindexnumber} ${groupindexnumber} "\{${editgroupname}\} ${grouplistnumbers}" ]
        }
        set grouplist [ lsort -dictionary ${grouplist} ]
        set initchannel [ open ${groupfile} w ]
        foreach entry ${grouplist} { puts ${initchannel} ${entry} }
        close ${initchannel}
        addmenugroups
        .groupman.box.box delete 0 end
        foreach groupname ${grouplist} {
          if { ${groupname} != {} } { .groupman.box.box insert end [ lindex ${groupname} 0 ] }
        }
        set newgroup {}
        set countthrouggrouplistbox {0}
        foreach entry [ .groupman.box.box get 0 end ] {
          if { ${entry} == ${editgroupname} } { set groupindexnumber ${countthrouggrouplistbox} }
          incr countthrouggrouplistbox
        }
        .groupman.box.box selection set ${groupindexnumber}
        .groupman.box.box activate ${groupindexnumber}
        .groupman.box.box see ${groupindexnumber}
        .groupman.box.frame.edit.ok  configure -state disabled
        .groupman.box.frame.edit.del configure -state normal
      }
      bind .groupman.box.frame.edit.entry <Return> { .groupman.box.frame.edit.ok invoke }
      button .groupman.box.frame.edit.del -image ${delete2} -text [::msgcat::mc {dissolve}] -compound left -pady 0 -padx 3 -relief raised -borderwidth 1 -state disabled -command {
        set delgroupname ${editgroupname}
        set groupindexcounter {0}
        foreach entry ${grouplist} {
          if { [ lindex ${entry} 0 ] == ${editgroupname} } { set groupindexnumber ${groupindexcounter} }
          incr groupindexcounter
        }
        set grouplist [ lreplace ${grouplist} ${groupindexnumber} ${groupindexnumber} ]
        set grouplist [ lsort -dictionary ${grouplist} ]
        set initchannel [ open ${groupfile} w ]
        foreach entry ${grouplist} { puts ${initchannel} ${entry} }
        close ${initchannel}
        addmenugroups
        .groupman.box.box delete 0 end
        foreach groupname ${grouplist} {
          if { ${groupname} != {} } { .groupman.box.box insert end [ lindex ${groupname} 0 ] }
        }
        set newgroup {}
        .groupman.box.box selection set 0
        .groupman.box.box activate 0
        .groupman.box.box see 0
        set editgroupname [ .groupman.box.box get 0 ]
        if { [ .groupman.box.box size ] == {0} } {
          .groupman.box.frame.edit.ok    configure -state disabled
          .groupman.box.frame.edit.del   configure -state disabled
          .groupman.box.frame.edit.entry configure -state disabled
          focus .groupman.box.frame.new.entry
        }
        if { [ .winelist.filter.show.group cget -text ] == ${delgroupname} } { .winelist.filter.show.all5 invoke }
      }
    pack .groupman.box.frame.edit.entry .groupman.box.frame.edit.ok .groupman.box.frame.edit.del -side top -fill x
  pack .groupman.box.frame.new  -side top -fill x
  pack .groupman.box.frame.edit -side top -fill x
pack .groupman.box.box    -side left -fill both -expand true
pack .groupman.box.scroll -side left -fill y
pack .groupman.box.blank  -side left -fill y
pack .groupman.box.frame  -side left -fill y
if { ${bTtk} } {
	ttk::button .groupman.ok -image ${okaybutton} -text [::msgcat::mc {Close}] -compound left -command { destroy .groupman }
} else {
	button .groupman.ok -image ${okaybutton} -text [::msgcat::mc {Close}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { destroy .groupman }
}
frame .groupman.blank -height 5 -borderwidth 0
pack .groupman.box   -side top -padx 5 -pady 5 -fill both -expand true
pack .groupman.ok    -side top -padx 5 -pady 0 -fill x
pack .groupman.blank -side top -padx 5 -pady 0 -fill x
focus .groupman.box.box


# main keyboard bindings
bind .groupman <Key-Escape>    { destroy .groupman }
bind .groupman <Control-Key-q> { destroy .groupman }
bind .groupman <KeyPress-F2>   { destroy .groupman }


# place the window near the mouse
if { [ winfo exists .groupman ] } {
  tkwait visibility .groupman
  set xposition_group [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .groupman ] / 2" ]" ]
  set yposition_group [ expr "[ winfo pointery . ] - [ expr "[ winfo height .groupman ] / 2" ]" ]
  if { ${xposition_group} < {0} } { set xposition_group {0} }
  if { ${yposition_group} < {0} } { set yposition_group {0} }
  if { [ expr "[ winfo width  .groupman ] + ${xposition_group}" ] > [ winfo screenwidth  . ] } { set xposition_group [ expr "[ winfo screenwidth  . ] - [ winfo width  .groupman ]" ] }
  if { [ expr "[ winfo height .groupman ] + ${yposition_group}" ] > [ winfo screenheight . ] } { set yposition_group [ expr "[ winfo screenheight . ] - [ winfo height .groupman ]" ] }
  wm geometry .groupman +${xposition_group}+${yposition_group}
}


# do something if something is selected
bind .groupman.box.box <ButtonRelease-1> {
  if { [ .groupman.box.box size ] != {0} } {
    update
    set editgroupname [ .groupman.box.box get [ .groupman.box.box curselection ] ]
  }
}

bind .groupman <Key-Down> {
  if { [ .groupman.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .groupman.box.box curselection ] + 1" ]
    if { ${positionsline} < [ .groupman.box.box size ] } {
      .groupman.box.box selection clear 0 end
      .groupman.box.box selection set ${positionsline}
      .groupman.box.box activate ${positionsline}
      .groupman.box.box see ${positionsline}
      set editgroupname [ .groupman.box.box get [ .groupman.box.box curselection ] ]
    }
  }
}

bind .groupman <Key-Up> {
  if { [ .groupman.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .groupman.box.box curselection ] - 1" ]
    if { ${positionsline} >= {0} } {
      .groupman.box.box selection clear 0 end
      .groupman.box.box selection set ${positionsline}
      .groupman.box.box activate ${positionsline}
      .groupman.box.box see ${positionsline}
      set editgroupname [ .groupman.box.box get [ .groupman.box.box curselection ] ]
    }
  }
}

bind .groupman <Next> {
  if { [ .groupman.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .groupman.box.box curselection ] + 10" ]
    if { ${positionsline} >= [ .groupman.box.box size ] } { set positionsline [ expr "[ .groupman.box.box size ] - 1" ] }
    if { ${positionsline} < [ .groupman.box.box size ] } {
      .groupman.box.box selection clear 0 end
      .groupman.box.box selection set ${positionsline}
      .groupman.box.box activate ${positionsline}
      .groupman.box.box see ${positionsline}
      set editgroupname [ .groupman.box.box get [ .groupman.box.box curselection ] ]
    }
  }
}

bind .groupman <Prior> {
  if { [ .groupman.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .groupman.box.box curselection ] - 10" ]
    if { ${positionsline} < {0} } { set positionsline 0 }
    if { ${positionsline} >= {0} } {
      .groupman.box.box selection clear 0 end
      .groupman.box.box selection set ${positionsline}
      .groupman.box.box activate ${positionsline}
      .groupman.box.box see ${positionsline}
      set editgroupname [ .groupman.box.box get [ .groupman.box.box curselection ] ]
    }
  }
}

bind .groupman.box.box <Key-Home> {
  if { [ .groupman.box.box size ] != {0} } {
    update
    .groupman.box.box selection clear 0 end
    .groupman.box.box selection set 0
    .groupman.box.box activate 0
    .groupman.box.box see 0
    set editgroupname [ .groupman.box.box get [ .groupman.box.box curselection ] ]
  }
}

bind .groupman.box.box <Key-End> {
  if { [ .groupman.box.box size ] != {0} } {
    update
    .groupman.box.box selection clear 0 end
    .groupman.box.box selection set end
    .groupman.box.box activate end
    .groupman.box.box see end
    set editgroupname [ .groupman.box.box get [ .groupman.box.box curselection ] ]
  }
}

bind .groupman.box.box <Enter> { focus .groupman.box.box }
bind .groupman.box.box <Leave> {
  if { [ string length ${editgroupname} ] > {0} } {
    focus .groupman.box.frame.edit.entry
  } else {
    focus .groupman.box.frame.new.entry
  }
}


# fill the listbox with the groups
set groupwidth {12}
foreach groupname ${grouplist} {
  set toaddgroupname [ lindex ${groupname} 0 ]
  if { ${toaddgroupname} != {} } {
    .groupman.box.box insert end ${toaddgroupname}
    if { [ string length ${toaddgroupname} ] > ${groupwidth} } { set groupwidth [ string length ${toaddgroupname} ] }
  }
}
# correct the width of the entries and list
if { ${groupwidth} > {12} } {
  .groupman.box.box              configure -width ${groupwidth}
  .groupman.box.frame.new.entry  configure -width ${groupwidth}
  .groupman.box.frame.edit.entry configure -width ${groupwidth}
}


# select first line
if { [ .groupman.box.box size ] != {0} } {
  update
  .groupman.box.box selection set 0
  .groupman.box.box activate 0
  set editgroupname [ .groupman.box.box get 0 ]
} else {
  focus .groupman.box.frame.new.entry
}


# close the if construct
}
