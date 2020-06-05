# manages dealer


# basic vars
set dealerfile [ file join ${datadir} dealer ]
set dealerlist {}


# select the first entry, and switch to edit mode
# if none entry selectable, clear edit and switch to new
proc dealer_select_top {} {
  global dealerlist dealereditname
  .dealer.top.right.notes.text delete 0.0 end
  set dealereditname {}
  if { [ .dealer.top.left.box.box size ] != {0} } {
    .dealer.top.left.box.box selection clear 0 end
    .dealer.top.left.box.box selection set 0
    .dealer.top.left.box.box activate 0
    .dealer.top.left.box.box see 0
    set selecteddealer [ .dealer.top.left.box.box get [ .dealer.top.left.box.box curselection ] ]
    set dealercounter {0}
    foreach entry ${dealerlist} {
      if { [ lindex ${entry} 0 ] == ${selecteddealer}} {
        set dealereditname [ lindex [ lindex ${dealerlist} ${dealercounter} ] 0 ]
        .dealer.top.right.notes.text insert end [ lindex [ lindex ${dealerlist} ${dealercounter} ] 1 ]
        .dealer.top.right.modeframe.edit invoke
        break
      }
      incr dealercounter
    }
  } else {
    .dealer.top.right.modeframe.new invoke
  }
}


# write dealer file
proc update_dealer {} {
  global dealerlist dealerfile
  # clear listbox
  .dealer.top.left.box.box delete 0 end
  # sort the list
  set dealerlist [ lsort -index 0 -dictionary ${dealerlist} ]
  # write it to listbox and file
  set initchannel [ open ${dealerfile} w ]
  foreach entry ${dealerlist} {
    # please no empty strings
    if { [ lindex ${entry} 0 ] != {} } {
      # listbox
      .dealer.top.left.box.box insert end [ lindex ${entry} 0 ]
      # file 
      puts ${initchannel} ${entry}
    }
  }
  close ${initchannel}
}


# add a new dealer
proc dealer_new {} {
  global dealereditname dealerlist
  # blank
  set dealereditname {}
  .dealer.top.right.notes.text delete 0.0 end
  # deselect listbox
  .dealer.top.left.box.box selection clear 0 end
  # take over action
  .dealer.top.right.action configure -command {
    # get text from textbox
    set dealertext [ .dealer.top.right.notes.text get 1.0 end ]
    set dealertext [ string trimright ${dealertext} ]
    set tmp1 {}
    set tmp2 {}
    regsub -all "\{" ${dealertext} {[} tmp1
    regsub -all "\}" ${tmp1} {]} tmp2
    if { ${tmp2} != ${dealertext} } { set dealertext ${tmp2} }
    # add new item to dealerlist
    set newlistitem {}
    lappend newlistitem ${dealereditname}
    lappend newlistitem ${dealertext}
    lappend dealerlist ${newlistitem}
    # write file and update listbox
    update_dealer
    # scroll and activate new entry
    set dealercounter {0}
    foreach entry ${dealerlist} {
      if { [ lindex ${entry} 0 ] == ${dealereditname}} {
        .dealer.top.left.box.box selection set ${dealercounter}
        .dealer.top.left.box.box activate ${dealercounter}
        .dealer.top.left.box.box see ${dealercounter}
        .dealer.top.right.notes.text delete 0.0 end
        .dealer.top.right.notes.text insert end [ lindex [ lindex ${dealerlist} ${dealercounter} ] 1 ]
        break
      }
      incr dealercounter
    }
    # switch to edit mode
    .dealer.top.right.modeframe.edit invoke
  }
}


# delete a dealer
proc dealer_delete {} {
  global dealereditname dealerlist
  .dealer.top.right.action configure -command {
    # build up a valid dealerlist
    set tmpdealerlist {}
    foreach entry ${dealerlist} {
      if { [ lindex ${entry} 0 ] != ${dealereditname}} {
        set newlistitem {}
        lappend newlistitem [ lindex ${entry} 0 ] [ lindex ${entry} 1 ]
        lappend tmpdealerlist ${newlistitem}
      }
    }
    set dealerlist ${tmpdealerlist}
    # write file and update listbox
    update_dealer
    dealer_select_top
  }
}


# edit a dealer
proc dealer_edit {} {
  global dealereditname dealerlist dealertochange
  # as this is run every time the selection changes
  # we can store the selection from the last run
  set dealertochange ${dealereditname}
  .dealer.top.right.action configure -command {
    # get text from textbox
    set dealertext [ .dealer.top.right.notes.text get 1.0 end ]
    set dealertext [ string trimright ${dealertext} ]
    set tmp1 {}
    set tmp2 {}
    regsub -all "\{" ${dealertext} {[} tmp1
    regsub -all "\}" ${tmp1} {]} tmp2
    if { ${tmp2} != ${dealertext} } { set dealertext ${tmp2} }
    # build up a valid dealerlist
    set tmpdealerlist {}
    foreach entry ${dealerlist} {
      if { [ lindex ${entry} 0 ] == ${dealertochange}} {
        set newlistitem {}
        lappend newlistitem ${dealereditname} ${dealertext}
        lappend tmpdealerlist ${newlistitem}
      } else {
        set newlistitem {}
        lappend newlistitem [ lindex ${entry} 0 ] [ lindex ${entry} 1 ]
        lappend tmpdealerlist ${newlistitem}
      }
    }
    set dealerlist ${tmpdealerlist}
    # write file and update listbox
    update_dealer
    # select the changed one
    set dealercounter {0}
    foreach entry ${dealerlist} {
      if { [ lindex ${entry} 0 ] == ${dealereditname}} {
        .dealer.top.left.box.box selection set ${dealercounter}
        .dealer.top.left.box.box activate ${dealercounter}
        .dealer.top.left.box.box see ${dealercounter}
        break
      }
      incr dealercounter
    }
    set dealertochange ${dealereditname}
  }
}



# window
proc dealerwindow {} {
  global lightcolor titlefont new3 edit2 delete2 okay close dealerfile dealereditname dealerlist bTtk

  # startup only if window does not exist
  if { [ winfo exists .dealer ] } {
    raise .dealer .
  } else {
    # window stuff
    toplevel     .dealer
    wm title     .dealer "TkWiCe [::msgcat::mc {Dealer Database}]"
    wm resizable .dealer true true
    wm geometry  .dealer +[ winfo pointerx . ]+[ winfo pointery . ]
    focus        .dealer
    # create a nice window
    frame .dealer.top
      frame .dealer.top.left -padx 5 -pady 5
        frame .dealer.top.left.box
          listbox   .dealer.top.left.box.box -width 30 -height 15 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 0 -yscrollcommand {.dealer.top.left.box.scroll set}
					if { ${bTtk} } {
          	ttk::scrollbar .dealer.top.left.box.scroll -command {.dealer.top.left.box.box yview} -orient vertical
					} else {
						scrollbar .dealer.top.left.box.scroll -command {.dealer.top.left.box.box yview} -orient vertical
					}
        pack .dealer.top.left.box.box    -side left -fill both -expand true
        pack .dealer.top.left.box.scroll -side left -fill y
        pack .dealer.top.left.box -side top -fill both -expand true

			if { ${bTtk} } {
      	ttk::labelframe .dealer.top.right -text [::msgcat::mc {Edit}]
			} else {
				labelframe .dealer.top.right -pady 5 -padx 5 -text [::msgcat::mc {Edit}]
			}

        label .dealer.top.right.modelabel -text "[::msgcat::mc {Mode}] " -font ${titlefont} -anchor w
        grid  .dealer.top.right.modelabel -column 0 -row 0 -sticky w
        frame .dealer.top.right.modeframe
          button .dealer.top.right.modeframe.new  -image ${new3}    -text [::msgcat::mc {New}]    -compound left -pady 1 -padx 1 -relief flat   -borderwidth 1 -command {
            .dealer.top.right.nameentry  configure -state normal
            .dealer.top.right.notes.text configure -state normal
            .dealer.top.right.modeframe.new  configure -relief raised
            .dealer.top.right.modeframe.edit configure -relief flat
            .dealer.top.right.modeframe.del  configure -relief flat
            .dealer.top.right.action configure -text [::msgcat::mc {Add}]
            focus .dealer.top.right.nameentry
            dealer_new
          }
          button .dealer.top.right.modeframe.edit -image ${edit2}   -text [::msgcat::mc {Edit}]   -compound left -pady 1 -padx 1 -relief raised -borderwidth 1 -command {
            set disableswitch {false}
            if { [ .dealer.top.left.box.box curselection ] == {} } { set disableswitch {true} }
            if { ${disableswitch} == {false} } {
              .dealer.top.right.nameentry  configure -state normal
              .dealer.top.right.notes.text configure -state normal
              .dealer.top.right.modeframe.new  configure -relief flat
              .dealer.top.right.modeframe.edit configure -relief raised
              .dealer.top.right.modeframe.del  configure -relief flat
              .dealer.top.right.action configure -text [::msgcat::mc {Take Over}]
              focus .dealer.top.right.nameentry
              dealer_edit
            }
          }
          button .dealer.top.right.modeframe.del  -image ${delete2} -text [::msgcat::mc {Delete}] -compound left -pady 1 -padx 1 -relief flat   -borderwidth 1 -command {
            set disableswitch {true}
            foreach entry ${dealerlist} {
              if { [ lindex ${entry} 0 ] == ${dealereditname} } { set disableswitch {false} }
            }
            if { [ .dealer.top.left.box.box curselection ] == {} } { set disableswitch {true} }
            if { ${disableswitch} == {false} } {
              .dealer.top.right.nameentry  configure -state disabled
              .dealer.top.right.notes.text configure -state disabled
              .dealer.top.right.modeframe.new  configure -relief flat
              .dealer.top.right.modeframe.edit configure -relief flat
              .dealer.top.right.modeframe.del  configure -relief raised
              .dealer.top.right.action configure -text [::msgcat::mc {Confirm}] -state normal
              dealer_delete
            }
          }
        pack .dealer.top.right.modeframe.new .dealer.top.right.modeframe.edit .dealer.top.right.modeframe.del -side left -fill x -expand true
        grid  .dealer.top.right.modeframe -column 1 -row 0 -sticky we

        frame .dealer.top.right.separator1 -pady 5
          frame .dealer.top.right.separator1.draw -height 0
          pack .dealer.top.right.separator1.draw
        grid .dealer.top.right.separator1 -column 0 -row 1

        label .dealer.top.right.namelabel -text "[::msgcat::mc {Dealer}] " -font ${titlefont} -anchor w
        grid  .dealer.top.right.namelabel -column 0 -row 2 -sticky w
        entry .dealer.top.right.nameentry -width 30 -textvariable dealereditname -background ${lightcolor} -highlightthickness 0 -validate key -vcmd { checktext %W %v %i %S }
        ::conmen .dealer.top.right.nameentry
        grid  .dealer.top.right.nameentry -column 1 -row 2 -sticky we

        label .dealer.top.right.noteslabel -text "[::msgcat::mc {Notes}] " -font ${titlefont} -anchor w
        grid  .dealer.top.right.noteslabel -column 0 -row 3 -sticky nw
        frame       .dealer.top.right.notes
          text      .dealer.top.right.notes.text   -wrap word -width 25 -height 5 -background ${lightcolor} -yscrollcommand ".dealer.top.right.notes.scroll set"
					if { ${bTtk} } {
          	ttk::scrollbar .dealer.top.right.notes.scroll -command ".dealer.top.right.notes.text yview"
					} else {
						scrollbar .dealer.top.right.notes.scroll -command ".dealer.top.right.notes.text yview"
					}
        pack .dealer.top.right.notes.text   -side left  -fill both -expand true
        pack .dealer.top.right.notes.scroll -side right -fill y
        grid .dealer.top.right.notes -column 1 -row 3 -sticky news
        ::conmen .dealer.top.right.notes.text

        frame .dealer.top.right.separator2 -pady 5
          frame .dealer.top.right.separator2.draw -height 0
          pack .dealer.top.right.separator2.draw
        grid .dealer.top.right.separator2 -column 0 -row 4

        button .dealer.top.right.action -image ${okay} -text [::msgcat::mc {Take Over}] -compound left -pady 1 -padx 1 -relief raised -borderwidth 1 -state disabled
        grid .dealer.top.right.action -column 0 -row 5 -sticky we -columnspan 2

        # resize only for text widgets
        grid columnconfigure .dealer.top.right 1 -weight 1
        grid rowconfigure .dealer.top.right 3 -weight 1

      frame .dealer.top.spaceright
      pack .dealer.top.left -side left -fill both -expand true
      pack .dealer.top.right -side left -fill both -expand true -pady 5
      pack .dealer.top.spaceright -side left -padx 5

			if { ${bTtk} } {
      	ttk::button .dealer.bottom -image ${close} -text [::msgcat::mc {Close}] -compound left -command { destroy .dealer }
			} else {
				button .dealer.bottom -image ${close} -text [::msgcat::mc {Close}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { destroy .dealer }
			}

    pack .dealer.top    -side top -fill both -expand true
    pack .dealer.bottom -side top -fill x -padx 5 -pady 5

    # bindings
    bind .dealer.top.left.box.box <ButtonRelease-1> {
      .dealer.top.right.modeframe.edit invoke
      set selecteddealer [ .dealer.top.left.box.box get [ .dealer.top.left.box.box curselection ] ]
      .dealer.top.right.notes.text delete 0.0 end
      set dealereditname {}
      set dealercounter {0}
      foreach entry ${dealerlist} {
        if { [ lindex ${entry} 0 ] == ${selecteddealer}} {
          set dealereditname [ lindex [ lindex ${dealerlist} ${dealercounter} ] 0 ]
          .dealer.top.right.notes.text insert end [ lindex [ lindex ${dealerlist} ${dealercounter} ] 1 ]
          .dealer.top.right.modeframe.edit invoke
          break
        }
        incr dealercounter
      }
    }

    bind .dealer.top.left.box.box <Key-Down> {
      if { [ .dealer.top.left.box.box size ] != {0} } {
        update
        set positionsline [ expr "[ .dealer.top.left.box.box curselection ] + 1" ]
        if { ${positionsline} < [ .dealer.top.left.box.box size ] } {
          .dealer.top.left.box.box selection clear 0 end
          .dealer.top.left.box.box selection set ${positionsline}
          .dealer.top.left.box.box activate ${positionsline}
          .dealer.top.left.box.box see ${positionsline}
          set selecteddealer [ .dealer.top.left.box.box get [ .dealer.top.left.box.box curselection ] ]
          .dealer.top.right.notes.text delete 0.0 end
          set dealereditname {}
          set dealercounter {0}
          foreach entry ${dealerlist} {
            if { [ lindex ${entry} 0 ] == ${selecteddealer}} {
              set dealereditname [ lindex [ lindex ${dealerlist} ${dealercounter} ] 0 ]
              .dealer.top.right.notes.text insert end [ lindex [ lindex ${dealerlist} ${dealercounter} ] 1 ]
              .dealer.top.right.modeframe.edit invoke
              break
            }
            incr dealercounter
          }
        }
      }
    }

    bind .dealer.top.left.box.box <Key-Up> {
      if { [ .dealer.top.left.box.box size ] != {0} } {
        update
        set positionsline [ expr "[ .dealer.top.left.box.box curselection ] - 1" ]
        if { ${positionsline} >= {0} } {
          .dealer.top.left.box.box selection clear 0 end
          .dealer.top.left.box.box selection set ${positionsline}
          .dealer.top.left.box.box activate ${positionsline}
          .dealer.top.left.box.box see ${positionsline}
          set selecteddealer [ .dealer.top.left.box.box get [ .dealer.top.left.box.box curselection ] ]
          .dealer.top.right.notes.text delete 0.0 end
          set dealereditname {}
          set dealercounter {0}
          foreach entry ${dealerlist} {
            if { [ lindex ${entry} 0 ] == ${selecteddealer}} {
              set dealereditname [ lindex [ lindex ${dealerlist} ${dealercounter} ] 0 ]
              .dealer.top.right.notes.text insert end [ lindex [ lindex ${dealerlist} ${dealercounter} ] 1 ]
              .dealer.top.right.modeframe.edit invoke
              break
            }
            incr dealercounter
          }
        }
      }
    }

    bind .dealer.top.left.box.box <Next> {
      if { [ .dealer.top.left.box.box size ] != {0} } {
        update
        set positionsline [ expr "[ .dealer.top.left.box.box curselection ] + 10" ]
        if { ${positionsline} >= [ .dealer.top.left.box.box size ] } { set positionsline [ expr "[ .dealer.top.left.box.box size ] - 1" ] }
        if { ${positionsline} < [ .dealer.top.left.box.box size ] } {
          .dealer.top.left.box.box selection clear 0 end
          .dealer.top.left.box.box selection set ${positionsline}
          .dealer.top.left.box.box activate ${positionsline}
          .dealer.top.left.box.box see ${positionsline}
          set selecteddealer [ .dealer.top.left.box.box get [ .dealer.top.left.box.box curselection ] ]
          .dealer.top.right.notes.text delete 0.0 end
          set dealereditname {}
          set dealercounter {0}
          foreach entry ${dealerlist} {
            if { [ lindex ${entry} 0 ] == ${selecteddealer}} {
              set dealereditname [ lindex [ lindex ${dealerlist} ${dealercounter} ] 0 ]
              .dealer.top.right.notes.text insert end [ lindex [ lindex ${dealerlist} ${dealercounter} ] 1 ]
              .dealer.top.right.modeframe.edit invoke
              break
            }
            incr dealercounter
          }
        }
      }
    }

    bind .dealer.top.left.box.box <Prior> {
      if { [ .dealer.top.left.box.box size ] != {0} } {
        update
        set positionsline [ expr "[ .dealer.top.left.box.box curselection ] - 10" ]
        if { ${positionsline} < {0} } { set positionsline 0 }
        if { ${positionsline} >= {0} } {
          .dealer.top.left.box.box selection clear 0 end
          .dealer.top.left.box.box selection set ${positionsline}
          .dealer.top.left.box.box activate ${positionsline}
          .dealer.top.left.box.box see ${positionsline}
          set selecteddealer [ .dealer.top.left.box.box get [ .dealer.top.left.box.box curselection ] ]
          .dealer.top.right.notes.text delete 0.0 end
          set dealereditname {}
          set dealercounter {0}
          foreach entry ${dealerlist} {
            if { [ lindex ${entry} 0 ] == ${selecteddealer}} {
              set dealereditname [ lindex [ lindex ${dealerlist} ${dealercounter} ] 0 ]
              .dealer.top.right.notes.text insert end [ lindex [ lindex ${dealerlist} ${dealercounter} ] 1 ]
              .dealer.top.right.modeframe.edit invoke
              break
            }
            incr dealercounter
          }
        }
      }
    }

    bind .dealer.top.left.box.box <Key-Home> {
      if { [ .dealer.top.left.box.box size ] != {0} } {
        update
        .dealer.top.left.box.box selection clear 0 end
        .dealer.top.left.box.box selection set 0
        .dealer.top.left.box.box activate 0
        .dealer.top.left.box.box see 0
        set selecteddealer [ .dealer.top.left.box.box get [ .dealer.top.left.box.box curselection ] ]
        .dealer.top.right.notes.text delete 0.0 end
        set dealereditname {}
        set dealercounter {0}
        foreach entry ${dealerlist} {
          if { [ lindex ${entry} 0 ] == ${selecteddealer}} {
            set dealereditname [ lindex [ lindex ${dealerlist} ${dealercounter} ] 0 ]
            .dealer.top.right.notes.text insert end [ lindex [ lindex ${dealerlist} ${dealercounter} ] 1 ]
            .dealer.top.right.modeframe.edit invoke
            break
          }
          incr dealercounter
        }
      }
    }

    bind .dealer.top.left.box.box <Key-End> {
      if { [ .dealer.top.left.box.box size ] != {0} } {
        update
        .dealer.top.left.box.box selection clear 0 end
        .dealer.top.left.box.box selection set end
        .dealer.top.left.box.box activate end
        .dealer.top.left.box.box see end
        set selecteddealer [ .dealer.top.left.box.box get [ .dealer.top.left.box.box curselection ] ]
        .dealer.top.right.notes.text delete 0.0 end
        set dealereditname {}
        set dealercounter {0}
        foreach entry ${dealerlist} {
          if { [ lindex ${entry} 0 ] == ${selecteddealer}} {
            set dealereditname [ lindex [ lindex ${dealerlist} ${dealercounter} ] 0 ]
            .dealer.top.right.notes.text insert end [ lindex [ lindex ${dealerlist} ${dealercounter} ] 1 ]
            .dealer.top.right.modeframe.edit invoke
            break
          }
          incr dealercounter
        }
      }
    }

    bind .dealer <Key-Escape>    { destroy .dealer }
    bind .dealer <Control-Key-q> { destroy .dealer }


    # startup - fill listbox, preselect buttons etc
    if {[ file exists ${dealerfile}]} {
      # get dealerlist from file
      set initchannel [ open ${dealerfile} r ]
      set dealerlist2 [ read -nonewline ${initchannel} ]
      close ${initchannel}
      if {[ llength ${dealerlist2} ] > {0}} {
        # convert dealerlist2 to dealerlist
        set dealerlist {}
        set dealerlistbuildswitch {0}
        foreach entry ${dealerlist2} {
          if {${dealerlistbuildswitch} == {0}} {
            set dealerlistbuildswitch {1}
            set newlistitem {}
            lappend newlistitem ${entry}
          } else {
            set dealerlistbuildswitch {0}
            lappend newlistitem ${entry}
            lappend dealerlist ${newlistitem}
          }
        }
        # fill listbox
        foreach entry ${dealerlist} {
          .dealer.top.left.box.box insert end [ lindex ${entry} 0 ]
        }
      }
    }
    dealer_select_top

    # place the window
    if { [ winfo exists .dealer ] } {
      tkwait visibility .dealer
      set xposition_info [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .dealer ] / 2" ]" ]
      set yposition_info [ expr "[ winfo pointery . ] - [ expr "[ winfo height .dealer ] / 2" ]" ]
      if { ${xposition_info} < {0} } { set xposition_info {0} }
      if { ${yposition_info} < {0} } { set yposition_info {0} }
      if { [ expr "[ winfo width  .dealer ] + ${xposition_info}" ] > [ winfo screenwidth  . ] } { set xposition_info [ expr "[ winfo screenwidth  . ] - [ winfo width  .dealer ]" ] }
      if { [ expr "[ winfo height .dealer ] + ${yposition_info}" ] > [ winfo screenheight . ] } { set yposition_info [ expr "[ winfo screenheight . ] - [ winfo height .dealer ]" ] }
      wm geometry .dealer +${xposition_info}+${yposition_info}
    }

  }
}


# trace for dealereditname / action
proc trace_dealereditname {} {
  global dealereditname dealerlist
  if { [ .dealer.top.right.modeframe.new cget -relief] == {raised} } {
    if { ${dealereditname} == {} } {
      .dealer.top.right.action configure -state disabled
    } else {
      set dealerswitch {false}
      foreach entry ${dealerlist} {
        if { [ lindex ${entry} 0 ] == ${dealereditname}} { set dealerswitch {true} }
      }
      if { ${dealerswitch} == {false} } {
        .dealer.top.right.action configure -state normal
      } else {
        .dealer.top.right.action configure -state disabled
      }
    }
  } elseif { [ .dealer.top.right.modeframe.edit cget -relief] == {raised} } {
    if {${dealereditname} == {}} {
      .dealer.top.right.action configure -state disabled
    } else {
      .dealer.top.right.action configure -state normal
    }
  } elseif {[ .dealer.top.right.modeframe.del cget -relief] == {raised}} {
    .dealer.top.right.action configure -state disabled
  }
}
trace variable dealereditname w "trace_dealereditname ;#"
