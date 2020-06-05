# select the groups - file is to be sourced from main window
# needs grouplist


# close the grup manager if available
if { [ winfo exists .groupman ] } { destroy .groupman }


# startup only if window does not exist
if { [ winfo exists .groupsel ] } {
  raise .groupsel .
} else {


# okay, is not shown yet - go on
set grouplist [ lsort -dictionary ${grouplist} ]
if { ${file_id} >= {0} && ${file_id} < {1000000} } {


proc groupstatecheck {} {
  global groupstartlist firstgroupbuttonimage
  set groupactuallist {}
  foreach widget [ winfo children .groupsel.groups.list ] {
    if { [ ${widget} cget -image ] == ${firstgroupbuttonimage} } {
      lappend groupactuallist 0
    } else {
      lappend groupactuallist 1
    }
  }
  if { ${groupstartlist} == ${groupactuallist} } {
    .groupsel.menu.save configure -state disabled
  } else {
    .groupsel.menu.save configure -state normal
  }
}


# window stuff
toplevel     .groupsel
wm title     .groupsel "TkWiCe [::msgcat::mc {Group Selector}]"
wm resizable .groupsel false false
wm geometry  .groupsel +[ winfo pointerx . ]+[ winfo pointery . ]
focus        .groupsel


# inform user which wine will be group-managed
source [ file join ${datadir} ${database} ${file_id} ]
if { ${bTtk} } {
	ttk::labelframe .groupsel.inform -text [::msgcat::mc {Selected Wine}]
} else {
	labelframe .groupsel.inform -text [::msgcat::mc {Selected Wine}] -font ${smallfont}
}
  label .groupsel.inform.domain1 -text "[::msgcat::mc {Winery:}] " -font ${smallfont}
  label .groupsel.inform.domain2 -text ${domain} -font ${smallfont}
grid .groupsel.inform.domain1 -sticky w -column 0 -row 0
grid .groupsel.inform.domain2 -sticky w -column 1 -row 0
  label .groupsel.inform.name1   -text "[::msgcat::mc {Name:}] " -font ${smallfont}
  label .groupsel.inform.name2   -text ${winename} -font ${smallfont}
grid .groupsel.inform.name1 -sticky w -column 0 -row 1
grid .groupsel.inform.name2 -sticky w -column 1 -row 1
  label .groupsel.inform.year1   -text "[::msgcat::mc {Vintage:}] " -font ${smallfont}
  label .groupsel.inform.year2   -text ${year} -font ${smallfont}
grid .groupsel.inform.year1 -sticky w -column 0 -row 2
grid .groupsel.inform.year2 -sticky w -column 1 -row 2
grid columnconfigure .groupsel.inform 1 -weight 1

# frame around the selectable group names
if { ${bTtk} } {
	ttk::labelframe .groupsel.groups
} else {
	labelframe .groupsel.groups -padx 5 -pady 5
}
frame .groupsel.groups.labeltext
  label .groupsel.groups.labeltext.text -text "[::msgcat::mc {Groups}] "
  button .groupsel.groups.labeltext.edit -image ${group} -text [::msgcat::mc {Edit}] -font ${smallfont} -compound left -pady 0 -padx 2 -relief raised -borderwidth 1 -command {
    destroy .groupsel
    source [ file join ${prog_dir} tcl groupman.tcl ]
  }
pack .groupsel.groups.labeltext.text .groupsel.groups.labeltext.edit -side left
.groupsel.groups configure -labelwidget .groupsel.groups.labeltext
# set up the group buttons
frame .groupsel.groups.list -background ${midcolor} -pady 1 -padx 1 -relief sunken -borderwidth 1
set nextcolor ${midcolor}
set groupstartlist {}
if { [ llength ${grouplist} ] != {0} } {
  set groupbuttoncount {0}
  foreach groupname ${grouplist} {
    button .groupsel.groups.list.${groupbuttoncount} -image ${close} -text " [ lindex ${groupname} 0 ]" -compound left -anchor w -highlightthickness 0 -background ${nextcolor} -relief flat -overrelief flat -borderwidth 0 -padx 10 -pady 0 -command { groupstatecheck }
    if { ${nextcolor} == ${midcolor} } {
      set nextcolor ${lightcolor}
    } else {
      set nextcolor ${midcolor}
    }
    set firstgroupbuttonimage ${close}
    bind .groupsel.groups.list.${groupbuttoncount} <Button-1> {
      if { [ %W cget -image ] == ${firstgroupbuttonimage} } {
        %W configure -image ${okay}
      } else {
        %W configure -image ${close}
      }
    }
    if { [ lsearch ${groupname} ${file_id} ] != {-1} } {
      .groupsel.groups.list.${groupbuttoncount} configure -image ${okay}
    } else {
      .groupsel.groups.list.${groupbuttoncount} configure -image ${close}
    }
    pack .groupsel.groups.list.${groupbuttoncount} -side top -fill x
    incr groupbuttoncount
  }
  foreach widget [ winfo children .groupsel.groups.list ] {
    if { [ ${widget} cget -image ] == ${firstgroupbuttonimage} } {
      lappend groupstartlist 0
    } else {
      lappend groupstartlist 1
    }
  }
} else {
  label .groupsel.groups.list.text -text [::msgcat::mc {none group found}] -background ${midcolor}
  pack  .groupsel.groups.list.text -side top -fill x
}
pack .groupsel.groups.list -fill x


frame .groupsel.menu
  button .groupsel.menu.close -image ${close} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command {
    destroy .groupsel
  }
  button .groupsel.menu.save -image ${okay} -text [::msgcat::mc {Save & Close}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -state disabled -command {
    set becausegrouptreloadwinelist {false}
    set initchannel [ open ${groupfile} w ]
    foreach widget [ winfo children .groupsel.groups.list ] {
      # get its text
      set groupwidgetname [ string range [ ${widget} cget -text ] 1 end ]
      set grouplistnumbers {}
      # find the corresponding line in grouplist
      foreach entry ${grouplist} {
        if { [ lindex ${entry} 0 ] == ${groupwidgetname} } {
         # gets its numbers
          set grouplistnumbers [ lrange ${entry} 1 end ]
          # compare the numbers
          if { [ ${widget} cget -image ] == ${firstgroupbuttonimage} } {
            # file id not in list
            set groupindexnumber [ lsearch -exact ${grouplistnumbers} ${file_id} ]
            if { ${groupindexnumber} != {-1} } {
              set grouplistnumbers [ lreplace ${grouplistnumbers} ${groupindexnumber} ${groupindexnumber} ]
              if { ${showgroup} == ${groupwidgetname} } { set becausegrouptreloadwinelist {true} }
            }
          } else {
            # file id in list
            if { [ lsearch -exact ${grouplistnumbers} ${file_id} ] == {-1} } {
              lappend grouplistnumbers ${file_id}
            }
          }
          # write it down
          if { ${grouplistnumbers} == {} } {
            puts ${initchannel} "\{${groupwidgetname}\}"
          } else {
            puts ${initchannel} "\{${groupwidgetname}\} ${grouplistnumbers}"
          }
        }
      }
    }
    close ${initchannel}
    # reread grouplist per line
    set grouplist {}
    set initchannel [ open ${groupfile} r ]
    foreach line [ split [ read ${initchannel} ] \n ] {
      if { ${line} != {} } { lappend grouplist ${line} }
    }
    close ${initchannel}
    # close this window
    destroy .groupsel
    # reload winelist if any group selected
    if { ${becausegrouptreloadwinelist} == {true} && ${locked} != {true} } { update_winelist }
  }
  pack .groupsel.menu.close .groupsel.menu.save -side top -fill x
pack .groupsel.inform -side top -padx 5 -pady 5 -fill x
pack .groupsel.groups -side top -padx 5 -pady 5 -fill x
pack .groupsel.menu   -side top -padx 5 -pady 5 -fill x


# main keyboard bindings
bind .groupsel <Key-Escape>    { destroy .groupsel }
bind .groupsel <Control-Key-q> { destroy .groupsel }
bind .groupsel <KeyPress-F2>   { .groupsel.menu.save invoke }


# place the window near the mouse
if { [ winfo exists .groupsel ] } {
  tkwait visibility .groupsel
  set xposition_group [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .groupsel ] / 2" ]" ]
  set yposition_group [ expr "[ winfo pointery . ] - [ expr "[ winfo height .groupsel ] / 2" ]" ]
  if { ${xposition_group} < {0} } { set xposition_group {0} }
  if { ${yposition_group} < {0} } { set yposition_group {0} }
  if { [ expr "[ winfo width  .groupsel ] + ${xposition_group}" ] > [ winfo screenwidth  . ] } { set xposition_group [ expr "[ winfo screenwidth  . ] - [ winfo width  .groupsel ]" ] }
  if { [ expr "[ winfo height .groupsel ] + ${yposition_group}" ] > [ winfo screenheight . ] } { set yposition_group [ expr "[ winfo screenheight . ] - [ winfo height .groupsel ]" ] }
  wm geometry .groupsel +${xposition_group}+${yposition_group}
}


# close the opened ifs
}
}
