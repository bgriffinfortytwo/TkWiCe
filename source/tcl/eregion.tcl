# helper tool for choosing a region
# outsourced from editwine.tcl


# helper proc for search
proc help_region_search {} {
  if { [ .help_region.land.subs.subs.regionbox2 size ] != {0} } {
    update
    set positionsline [ .help_region.land.subs.subs.regionbox2 curselection ]
    if { ${positionsline} >= {0} } {
      .help_region.land.subs.subs.regionbox2 selection set ${positionsline}
      .help_region.land.subs.subs.regionbox2 activate ${positionsline}
      .help_region.land.subs.subs.regionbox2 see ${positionsline}
      set select_search [ .help_region.land.subs.subs.regionbox2 get ${positionsline} ]
      set select_country [ split [ string map [ list { :: } {:} ] [ .help_region.preview.text cget -text ] ] {:} ]
      if { [ string length [ .help_region.preview.text cget -text ] ] > {5} } {
        set now_land_macro [ string range [ .help_region.preview.text cget -text ] 1 2 ]
        set now_land_name [ lindex ${select_country} 1 ]
        .help_region.preview.text configure -text "\[${now_land_macro}\] :: ${now_land_name} :: ${select_search}"
      }
    }
  }
}


# helper proc for region
proc help_region_region {} {
  global list_complete
  if { [ .help_region.land.subs.subs.regionbox size ] != {0} } {
    update
    set positionsline [ .help_region.land.subs.subs.regionbox curselection ]
    if { ${positionsline} >= {0} } {
      .help_region.land.subs.subs.regionbox selection set ${positionsline}
      .help_region.land.subs.subs.regionbox activate ${positionsline}
      .help_region.land.subs.subs.regionbox see ${positionsline}
      set select_region [ .help_region.land.subs.subs.regionbox get ${positionsline} ]
      set select_country [ split [ string map [ list { :: } {:} ] [ .help_region.preview.text cget -text ] ] {:} ]
      if { [ string length [ .help_region.preview.text cget -text ] ] > {5} } {
        set now_land_macro [ string range [ .help_region.preview.text cget -text ] 1 2 ]
        set now_land_name [ lindex ${select_country} 1 ]
        .help_region.preview.text configure -text "\[${now_land_macro}\] :: ${now_land_name} :: ${select_region}"
      }
      .help_region.land.subs.subs.subregionbox delete 0 end
      # get the landcode and field 3
      set list_subregion {}
      set list_subregion2 {}
      set number {0}
      while { ${number} <= [ llength ${list_complete} ] } {
        if { [ lindex ${list_complete} ${number} ] == ${now_land_name} && ${select_region} == [ lindex ${list_complete} [ expr "${number} + 2" ] ] } {
          if { [ lindex ${list_complete} [ expr "${number} + 3" ] ] != {} } { lappend list_subregion [ lindex ${list_complete} [ expr "${number} + 3" ] ] }
        }
        incr number 4
      }
      set list_subregion [ lsort ${list_subregion} ]
      foreach entry ${list_subregion} {
        if { [ lsearch -exact ${list_subregion2} ${entry} ] == {-1} } { lappend list_subregion2 ${entry} }
      }
      foreach entry ${list_subregion2} {
        .help_region.land.subs.subs.subregionbox insert end ${entry}
      }
    }
  }
}


# helper proc for subregions
proc help_region_sub {} {
  if { [ .help_region.land.subs.subs.subregionbox size ] != {0} } {
    update
    set positionsline [ .help_region.land.subs.subs.subregionbox curselection ]
    if { ${positionsline} >= {0} } {
      .help_region.land.subs.subs.subregionbox selection set ${positionsline}
      .help_region.land.subs.subs.subregionbox activate ${positionsline}
      .help_region.land.subs.subs.subregionbox see ${positionsline}
      set select_subregion [ .help_region.land.subs.subs.subregionbox get ${positionsline} ]
      set select_country [ split [ string map [ list { :: } {:} ] [ .help_region.preview.text cget -text ] ] {:} ]
      if { [ string length [ .help_region.preview.text cget -text ] ] > {5} } {
        set now_land_macro [ string range [ .help_region.preview.text cget -text ] 1 2 ]
        set now_land_name [ lindex ${select_country} 1 ]
        set now_region_name [ lindex ${select_country} 2 ]
        .help_region.preview.text configure -text "\[${now_land_macro}\] :: ${now_land_name} :: ${now_region_name} :: ${select_subregion}"
      }
    }
  }
}


# helper proc for select a land
proc help_region_select_land {} {
global list_complete regionsearchstring list_region list_region2 list_search list_search2
  .help_region.land.subs.subs.regionbox delete 0 end
  .help_region.land.subs.subs.subregionbox delete 0 end
  .help_region.land.subs.subs.regionbox2 delete 0 end
  set select_land [ .help_region.land.countrybox get [ .help_region.land.countrybox curselection ] ]
  # get the landcode and field 2
  set list_region {}
  set list_region2 {}
  set list_search {}
  set list_search2 {}
  set number {0}
  while { ${number} <= [ llength ${list_complete} ] } {
    if { [ lindex ${list_complete} ${number} ] == ${select_land} } {
      set selected_land_short [ lindex ${list_complete} [ expr "${number} + 1" ] ]
      lappend list_region [ lindex ${list_complete} [ expr "${number} + 2" ] ]
      lappend list_search [ lindex ${list_complete} [ expr "${number} + 2" ] ]
      if { [ lindex ${list_complete} [ expr "${number} + 3" ] ] != {} } { lappend list_search "[ lindex ${list_complete} [ expr "${number} + 2" ] ] :: [ lindex ${list_complete} [ expr "${number} + 3" ] ]" }
    }
    incr number 4
  }
  set list_region [ lsort ${list_region} ]
  foreach entry ${list_region} {
    if { [ regexp -nocase [list ${entry}] ${list_region2} ] == {0} } { lappend list_region2 ${entry} }
  }
  foreach entry ${list_region2} {
    .help_region.land.subs.subs.regionbox insert end ${entry}
  }
  set list_search [ lsort -unique ${list_search} ]
  foreach entry ${list_search} {
    lappend list_search2 ${entry}
  }
  foreach entry ${list_search2} {
    if { [ regexp -nocase [list ${regionsearchstring}] [list ${entry}] ] == {0} && ${regionsearchstring} != {} } { continue }
    if { ${entry} != {} } { .help_region.land.subs.subs.regionbox2 insert end ${entry} }
  }
  # update infobar and enable or disable takover-button
  if { ${selected_land_short} == {} } {
    .help_region.menu.ok configure -state disabled
    .help_region.preview.text configure -text {}
  } else {
    .help_region.menu.ok configure -state normal
    .help_region.preview.text configure -text "\[${selected_land_short}\] :: ${select_land}"
  }
}


# main proc
proc help_region {} {
  if { [ winfo exists .help_region ] } { raise .help_region . ; return }
  global prog_dir titlefont textfont lightcolor selectbackground land region village closebutton okaybutton regionhitlist regionhitlist2 list_land2 datadir nationlist regionsearchstring list_region list_region2 list_search list_search2 bTtk
  toplevel     .help_region
  wm title     .help_region [::msgcat::mc {Growing Area}]
  wm geometry  .help_region +[ winfo pointerx . ]+[ winfo pointery . ]
  focus        .help_region
  wm transient .help_region .

  # build gui
	if { ${bTtk} } {
  	ttk::labelframe .help_region.preview -text [::msgcat::mc {Selection}]
	} else {
		labelframe .help_region.preview -text [::msgcat::mc {Selection}] -padx 2 -pady 2
	}
    label .help_region.preview.text -text {} -font ${titlefont} -justify left -width 93
  pack .help_region.preview.text -side left -fill x -expand true
  frame .help_region.land
    listbox .help_region.land.countrybox -height 20 -width 18 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 1 -highlightcolor ${selectbackground} -yscrollcommand {.help_region.land.countryscroll set}
		if { ${bTtk} } {
    	ttk::scrollbar .help_region.land.countryscroll -command {.help_region.land.countrybox yview} -orient vertical
		} else {
			scrollbar .help_region.land.countryscroll -command {.help_region.land.countrybox yview} -orient vertical
		}
    frame .help_region.land.space -width 5 -padx 0
    frame .help_region.land.subs
      frame .help_region.land.subs.land -padx 2 -pady 2 -relief sunken -borderwidth 1
        label .help_region.land.subs.land.0 -text "[::msgcat::mc {Country List}] " -font ${titlefont}
        # startup with a alphabetical list
        set regionhitlist {false}
        set regionhitlist2 {true}
        frame .help_region.land.subs.land.1
          radiobutton .help_region.land.subs.land.1.1 -text [::msgcat::mc {complete}] -variable regionhitlist -value {false} -padx 5 -command {
            if { ${regionhitlist2} == {false} } {
              set regionhitlist2 {true}
              .help_region.land.countrybox delete 0 end
              foreach entry ${list_land2} {
                .help_region.land.countrybox insert end ${entry}
              }
              .help_region.land.countrybox selection set 0
              .help_region.land.countrybox activate 0
              help_region_select_land
              focus .help_region.land.countrybox
            }
          }
          radiobutton .help_region.land.subs.land.1.2 -text [::msgcat::mc {from database}] -variable regionhitlist -value {true} -padx 5 -command {
            if { ${regionhitlist2} == {true} } {
              set regionhitlist2 {false}
              .help_region.land.countrybox delete 0 end
              foreach entry ${nationlist} {
                .help_region.land.countrybox insert end ${entry}
              }
              .help_region.land.countrybox selection set 0
              .help_region.land.countrybox activate 0
              help_region_select_land
              focus .help_region.land.countrybox
            }
          }
        pack .help_region.land.subs.land.1.1 .help_region.land.subs.land.1.2 -side left
        label .help_region.land.subs.land.2 -text "[::msgcat::mc {Region}] " -font ${titlefont}
        # take sure that it is deselected and false
        set searchforregions {false}
        frame .help_region.land.subs.land.3
          radiobutton .help_region.land.subs.land.3.1 -text [::msgcat::mc {choose}] -variable searchforregions -value {false} -padx 5 -command {
            .help_region.land.subs.land.3.3 configure -state disabled
            foreach window [ winfo children .help_region.land.subs.subs ] {
              pack forget ${window}
            }
            pack .help_region.land.subs.subs.regionbox       -side left -fill both -expand true
            pack .help_region.land.subs.subs.regionscroll    -side left -fill y
            pack .help_region.land.subs.subs.subregionbox    -side left -fill both -expand true
            pack .help_region.land.subs.subs.subregionscroll -side left -fill y
            .help_region.land.subs.subs.regionbox    selection clear 0 end
            .help_region.land.subs.subs.subregionbox selection clear 0 end
            focus .help_region.land.subs.subs.regionbox
          }
          radiobutton .help_region.land.subs.land.3.2 -text "[::msgcat::mc {search}]:" -variable searchforregions -value {true} -padx 5 -command {
            .help_region.land.subs.land.3.3 configure -state normal
            foreach window [ winfo children .help_region.land.subs.subs ] {
              pack forget ${window}
            }
            pack .help_region.land.subs.subs.regionbox2    -side left -fill both -expand true
            pack .help_region.land.subs.subs.regionscroll2 -side left -fill y
            .help_region.land.subs.subs.regionbox2 selection clear 0 end
            focus .help_region.land.subs.land.3.3
          }
          set regionsearchstring {}
          entry .help_region.land.subs.land.3.3 -textvariable regionsearchstring -width 15 -background ${lightcolor} -state disabled -highlightthickness 1 -highlightcolor ${selectbackground}
          ::conmen .help_region.land.subs.land.3.3
          bind .help_region.land.subs.land.3.3 <KeyRelease> {
            update
            .help_region.land.subs.subs.regionbox2 delete 0 end
            foreach entry ${list_search2} {
		if { [ regexp -nocase [list ${regionsearchstring}] [list ${entry}] ] == {0} && ${regionsearchstring} != {} } { continue }
              if { ${entry} != {} } { .help_region.land.subs.subs.regionbox2 insert end ${entry} }
            }
          }
        pack .help_region.land.subs.land.3.1 -side left
        pack .help_region.land.subs.land.3.2 -side left
        pack .help_region.land.subs.land.3.3 -side left -fill x -expand true
      grid .help_region.land.subs.land.0 -row 0 -column 0 -sticky w
      grid .help_region.land.subs.land.1 -row 0 -column 1 -sticky w
      grid .help_region.land.subs.land.2 -row 1 -column 0 -sticky w
      grid .help_region.land.subs.land.3 -row 1 -column 1 -sticky we
      grid columnconfigure .help_region.land.subs.land 1 -weight 1
    pack .help_region.land.subs.land -side top -fill x
      frame .help_region.land.subs.space1 -height 5 -pady 0
    pack .help_region.land.subs.space1 -side top
      frame .help_region.land.subs.subs
        listbox .help_region.land.subs.subs.regionbox -height 20 -width 20 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 1 -highlightcolor ${selectbackground} -yscrollcommand {.help_region.land.subs.subs.regionscroll set}
				if { ${bTtk} } {
        	ttk::scrollbar .help_region.land.subs.subs.regionscroll -command {.help_region.land.subs.subs.regionbox yview} -orient vertical
				} else {
					scrollbar .help_region.land.subs.subs.regionscroll -command {.help_region.land.subs.subs.regionbox yview} -orient vertical
				}
        listbox .help_region.land.subs.subs.subregionbox -height 20 -width 35 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 1 -highlightcolor ${selectbackground} -yscrollcommand {.help_region.land.subs.subs.subregionscroll set}
				if { ${bTtk} } {
        	ttk::scrollbar .help_region.land.subs.subs.subregionscroll -command {.help_region.land.subs.subs.subregionbox yview} -orient vertical
				} else {
					scrollbar .help_region.land.subs.subs.subregionscroll -command {.help_region.land.subs.subs.subregionbox yview} -orient vertical
				}
        # second box for search
        listbox .help_region.land.subs.subs.regionbox2 -height 20 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 1 -highlightcolor ${selectbackground} -yscrollcommand {.help_region.land.subs.subs.regionscroll2 set}
				if { ${bTtk} } {
        	ttk::scrollbar .help_region.land.subs.subs.regionscroll2 -command {.help_region.land.subs.subs.regionbox2 yview} -orient vertical
				} else {
					scrollbar .help_region.land.subs.subs.regionscroll2 -command {.help_region.land.subs.subs.regionbox2 yview} -orient vertical
				}
      pack .help_region.land.subs.subs.regionbox       -side left -fill both -expand true
      pack .help_region.land.subs.subs.regionscroll    -side left -fill y
      pack .help_region.land.subs.subs.subregionbox    -side left -fill both -expand true
      pack .help_region.land.subs.subs.subregionscroll -side left -fill y
    pack .help_region.land.subs.subs -side top -fill both -expand true
  pack .help_region.land.countrybox    -side left -fill both
  pack .help_region.land.countryscroll -side left -fill y
  pack .help_region.land.space         -side left
  pack .help_region.land.subs          -side left -fill both -expand true
  frame  .help_region.menu
    button .help_region.menu.ok -image ${okaybutton} -text [::msgcat::mc {Take Over}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -state disabled -command {
      if { [ string length [ .help_region.preview.text cget -text ] ] > {5} } {
        set country_getstring [ split [ string map [ list { :: } {:} ] [ .help_region.preview.text cget -text ] ] {:} ]
        set land    [ string range [ lindex ${country_getstring} 0 ] 1 2 ]
        set region  [ lindex ${country_getstring} 2 ]
        set village [ lindex ${country_getstring} 3 ]
        destroy .help_region
      } else {
        .help_region.menu.ok configure -state disabled
      }
    }
    button .help_region.menu.abort -image ${closebutton} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { destroy .help_region }
  pack .help_region.menu.ok .help_region.menu.abort -side left -fill x -expand true
  pack .help_region.preview -side top -padx 5 -pady 5 -fill x
  pack .help_region.land    -side top -padx 5 -pady 0 -fill both -expand true
  pack .help_region.menu    -side top -padx 5 -pady 5 -fill x


  # get list from regions-file
  set readchannel [ open [ file join ${prog_dir} ext regions ] r ]
  foreach entry [ read -nonewline ${readchannel} ] {
    lappend list_complete ${entry}
  }
  close ${readchannel}
  # buid up a list
  set number {0}
  while { ${number} <= [ llength ${list_complete} ] } {
    lappend list_land [ lindex ${list_complete} ${number} ]
    incr number 4
  }
  set list_land2 {}
  foreach entry ${list_land} {
    if { [ regexp -nocase [list ${entry}] ${list_land2} ] == {0} } {
      lappend list_land2 ${entry}
    }
  }
  # fill the list in the first listbox
  foreach entry ${list_land2} {
    .help_region.land.countrybox insert end ${entry}
  }

  # get a second list from history.in
  set nationlist {}
  set nationlist2 {}
  if { [ file exists [ file join ${datadir} history.in ] ] } {
    if { [ file size [ file join ${datadir} history.in ] ] > {15} } {
      set readchannel [ open [ file join ${datadir} history.in ] r ]
      # read it per line
      foreach line [ split [ read ${readchannel} ] \n ] {
        if { [ lindex ${line} 4] != {} && [ lindex ${line} 5] > {0} && [ string first {?} [ lindex ${line} 4] ] == {-1} && [ lsearch -exact ${list_land2} [ lindex ${line} 4] ] != {-1} } {
          if { [ regexp [ lindex ${line} 4] ${nationlist} ] != {1} } {
            append nationlist "[ lindex ${line} 5] \{[ lindex ${line} 4]\}\n"
          } else {
            set getstring "[ lindex ${nationlist} [ expr "[ lsearch ${nationlist} [ lindex ${line} 4] ] -1" ] ] \{[ lindex ${line} 4]\}"
            set newstring "[ expr "[lindex ${getstring} 0] + [ lindex ${line} 5]" ] \{[ lindex ${line} 4]\}"
            set nationlist [ string map [ list ${getstring} ${newstring} ] ${nationlist} ]
          }
        }
      }
      close ${readchannel}
    }
  }
  set nationlist [ string trimright ${nationlist} ]
  set counter {0}
  while { ${counter} <= [ llength ${nationlist} ] } {
    if { [ lindex ${nationlist} ${counter} ] != {} } {
      lappend nationlist2 "[ lindex ${nationlist} ${counter} ] [ lindex ${nationlist} [ expr "${counter} + 1" ] ]"
    }
    incr counter 2
  }
  set nationlist2 [ lsort -dictionary -decreasing ${nationlist2} ]
  set nationlist {}
  foreach entry ${nationlist2} {
    if { ${entry} != {} } { lappend nationlist [ lrange ${entry} 1 end ] }
  }
  # use the alternative list if three countries are bought so far
  if { [ llength ${nationlist} ] > {2} } {
    .help_region.land.subs.land.1.2 invoke
  } else {
    .help_region.land.countrybox selection set 0
    .help_region.land.countrybox activate 0
    help_region_select_land
  }
  if { [ llength ${nationlist} ] == {0} } {
    .help_region.land.subs.land.1.2 configure -state disabled
  }
  # startup in choose mode
  .help_region.land.subs.land.3.1 invoke


  # window placement near mouse, but not outside the window ...
  tkwait visibility .help_region
  set xposition_info [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .help_region ] / 2" ]" ]
  set yposition_info [ expr "[ winfo pointery . ] - [ expr "[ winfo height .help_region ] / 2" ]" ]
  if { ${xposition_info} < {0} } { set xposition_info {0} }
  if { ${yposition_info} < {0} } { set yposition_info {0} }
  if { [ expr "[ winfo width  .help_region ] + ${xposition_info}" ] > [ winfo screenwidth  . ] } { set xposition_info [ expr "[ winfo screenwidth  . ] - [ winfo width  .help_region ]" ] }
  if { [ expr "[ winfo height .help_region ] + ${yposition_info}" ] > [ winfo screenheight . ] } { set yposition_info [ expr "[ winfo screenheight . ] - [ winfo height .help_region ]" ] }
  wm geometry .help_region +${xposition_info}+${yposition_info}


  # bindings for land selection
  bind .help_region.land.countrybox <ButtonRelease-1> { help_region_select_land }
  bind .help_region.land.countrybox <Double-1> { .help_region.menu.ok invoke }
  bind .help_region.land.countrybox <Key-Down> {
    if { [ .help_region.land.countrybox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.countrybox curselection ] + 1" ]
      if { ${positionsline} < [ .help_region.land.countrybox size ] } {
        .help_region.land.countrybox selection clear 0 end
        .help_region.land.countrybox selection set ${positionsline}
        .help_region.land.countrybox activate ${positionsline}
        help_region_select_land
        .help_region.land.countrybox see ${positionsline}
      }
    }
  }
  bind .help_region.land.countrybox <Key-Up> {
    if { [ .help_region.land.countrybox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.countrybox curselection ] - 1" ]
      if { ${positionsline} >= {0} } {
        .help_region.land.countrybox selection clear 0 end
        .help_region.land.countrybox selection set ${positionsline}
        .help_region.land.countrybox activate ${positionsline}
        help_region_select_land
        .help_region.land.countrybox see ${positionsline}
      }
    }
  }
  bind .help_region.land.countrybox <Key-Next> {
    if { [ .help_region.land.countrybox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.countrybox curselection ] + 10" ]
      if { ${positionsline} >= [ .help_region.land.countrybox size ] } { set positionsline [ expr "[ .help_region.land.countrybox size ] - 1" ] }
      if { ${positionsline} < [ .help_region.land.countrybox size ] } {
        .help_region.land.countrybox selection clear 0 end
        .help_region.land.countrybox selection set ${positionsline}
        .help_region.land.countrybox activate ${positionsline}
        help_region_select_land
        .help_region.land.countrybox see ${positionsline}
      }
    }
  }
  bind .help_region.land.countrybox <Key-Prior> {
    if { [ .help_region.land.countrybox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.countrybox curselection ] - 10" ]
      if { ${positionsline} < {0} } { set positionsline 0 }
      if { ${positionsline} >= {0} } {
        .help_region.land.countrybox selection clear 0 end
        .help_region.land.countrybox selection set ${positionsline}
        .help_region.land.countrybox activate ${positionsline}
        help_region_select_land
        .help_region.land.countrybox see ${positionsline}
      }
    }
  }
  bind .help_region.land.countrybox <Key-Home> {
    if { [ .help_region.land.countrybox size ] != {0} } {
      update
      .help_region.land.countrybox selection clear 0 end
      .help_region.land.countrybox selection set {0}
      .help_region.land.countrybox activate {0}
      help_region_select_land
      .help_region.land.countrybox see {0}
    }
  }
  bind .help_region.land.countrybox <Key-End> {
    if { [ .help_region.land.countrybox size ] != {0} } {
      update
      .help_region.land.countrybox selection clear 0 end
      .help_region.land.countrybox selection set end
      .help_region.land.countrybox activate end
      help_region_select_land
      .help_region.land.countrybox see end
    }
  }

  # bindings for region selection
  bind .help_region.land.subs.subs.regionbox <ButtonRelease-1> { help_region_region }
  bind .help_region.land.subs.subs.regionbox <Double-1> { .help_region.menu.ok invoke }
  bind .help_region.land.subs.subs.regionbox <Key-Down> {
    if { [ .help_region.land.subs.subs.regionbox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.regionbox curselection ] + 1" ]
      if { ${positionsline} < [ .help_region.land.subs.subs.regionbox size ] } {
        .help_region.land.subs.subs.regionbox selection clear 0 end
        .help_region.land.subs.subs.regionbox selection set ${positionsline}
        .help_region.land.subs.subs.regionbox activate ${positionsline}
        help_region_region
        .help_region.land.subs.subs.regionbox see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.regionbox <Key-Up> {
    if { [ .help_region.land.subs.subs.regionbox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.regionbox curselection ] - 1" ]
      if { ${positionsline} >= {0} } {
        .help_region.land.subs.subs.regionbox selection clear 0 end
        .help_region.land.subs.subs.regionbox selection set ${positionsline}
        .help_region.land.subs.subs.regionbox activate ${positionsline}
        help_region_region
        .help_region.land.subs.subs.regionbox see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.regionbox <Key-Next> {
    if { [ .help_region.land.subs.subs.regionbox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.regionbox curselection ] + 10" ]
      if { ${positionsline} >= [ .help_region.land.subs.subs.regionbox size ] } { set positionsline [ expr "[ .help_region.land.subs.subs.regionbox size ] - 1" ] }
      if { ${positionsline} < [ .help_region.land.subs.subs.regionbox size ] } {
        .help_region.land.subs.subs.regionbox selection clear 0 end
        .help_region.land.subs.subs.regionbox selection set ${positionsline}
        .help_region.land.subs.subs.regionbox activate ${positionsline}
        help_region_region
        .help_region.land.subs.subs.regionbox see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.regionbox <Key-Prior> {
    if { [ .help_region.land.subs.subs.regionbox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.regionbox curselection ] - 10" ]
      if { ${positionsline} < {0} } { set positionsline 0 }
      if { ${positionsline} >= {0} } {
        .help_region.land.subs.subs.regionbox selection clear 0 end
        .help_region.land.subs.subs.regionbox selection set ${positionsline}
        .help_region.land.subs.subs.regionbox activate ${positionsline}
        help_region_region
        .help_region.land.subs.subs.regionbox see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.regionbox <Key-Home> {
    if { [ .help_region.land.subs.subs.regionbox size ] != {0} } {
      update
      .help_region.land.subs.subs.regionbox selection clear 0 end
      .help_region.land.subs.subs.regionbox selection set {0}
      .help_region.land.subs.subs.regionbox activate {0}
      help_region_region
      .help_region.land.subs.subs.regionbox see {0}
    }
  }
  bind .help_region.land.subs.subs.regionbox <Key-End> {
    if { [ .help_region.land.subs.subs.regionbox size ] != {0} } {
      update
      .help_region.land.subs.subs.regionbox selection clear 0 end
      .help_region.land.subs.subs.regionbox selection set end
      .help_region.land.subs.subs.regionbox activate end
      help_region_region
      .help_region.land.subs.subs.regionbox see end
    }
  }

  # bindings for region selection
  bind .help_region.land.subs.subs.subregionbox <ButtonRelease-1> { help_region_sub }
  bind .help_region.land.subs.subs.subregionbox <Double-1> { .help_region.menu.ok invoke }
  bind .help_region.land.subs.subs.subregionbox <Key-Down> {
    if { [ .help_region.land.subs.subs.subregionbox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.subregionbox curselection ] + 1" ]
      if { ${positionsline} < [ .help_region.land.subs.subs.subregionbox size ] } {
        .help_region.land.subs.subs.subregionbox selection clear 0 end
        .help_region.land.subs.subs.subregionbox selection set ${positionsline}
        .help_region.land.subs.subs.subregionbox activate ${positionsline}
        help_region_sub
        .help_region.land.subs.subs.subregionbox see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.subregionbox <Key-Up> {
    if { [ .help_region.land.subs.subs.subregionbox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.subregionbox curselection ] - 1" ]
      if { ${positionsline} >= {0} } {
        .help_region.land.subs.subs.subregionbox selection clear 0 end
        .help_region.land.subs.subs.subregionbox selection set ${positionsline}
        .help_region.land.subs.subs.subregionbox activate ${positionsline}
        help_region_sub
        .help_region.land.subs.subs.subregionbox see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.subregionbox <Key-Next> {
    if { [ .help_region.land.subs.subs.subregionbox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.subregionbox curselection ] + 10" ]
      if { ${positionsline} >= [ .help_region.land.subs.subs.subregionbox size ] } { set positionsline [ expr "[ .help_region.land.subs.subs.subregionbox size ] - 1" ] }
      if { ${positionsline} < [ .help_region.land.subs.subs.subregionbox size ] } {
        .help_region.land.subs.subs.subregionbox selection clear 0 end
        .help_region.land.subs.subs.subregionbox selection set ${positionsline}
        .help_region.land.subs.subs.subregionbox activate ${positionsline}
        help_region_sub
        .help_region.land.subs.subs.subregionbox see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.subregionbox <Key-Prior> {
    if { [ .help_region.land.subs.subs.subregionbox size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.subregionbox curselection ] - 10" ]
      if { ${positionsline} < {0} } { set positionsline 0 }
      if { ${positionsline} >= {0} } {
        .help_region.land.subs.subs.subregionbox selection clear 0 end
        .help_region.land.subs.subs.subregionbox selection set ${positionsline}
        .help_region.land.subs.subs.subregionbox activate ${positionsline}
        help_region_sub
        .help_region.land.subs.subs.subregionbox see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.subregionbox <Key-Home> {
    if { [ .help_region.land.subs.subs.subregionbox size ] != {0} } {
      update
      .help_region.land.subs.subs.subregionbox selection clear 0 end
      .help_region.land.subs.subs.subregionbox selection set {0}
      .help_region.land.subs.subs.subregionbox activate {0}
      help_region_sub
      .help_region.land.subs.subs.subregionbox see {0}
    }
  }
  bind .help_region.land.subs.subs.subregionbox <Key-End> {
    if { [ .help_region.land.subs.subs.subregionbox size ] != {0} } {
      update
      .help_region.land.subs.subs.subregionbox selection clear 0 end
      .help_region.land.subs.subs.subregionbox selection set end
      .help_region.land.subs.subs.subregionbox activate end
      help_region_sub
      .help_region.land.subs.subs.subregionbox see end
    }
  }

  # bindings for land selection
  bind .help_region.land.subs.subs.regionbox2 <ButtonRelease-1> { help_region_search }
  bind .help_region.land.subs.subs.regionbox2 <Double-1> { .help_region.menu.ok invoke }
  bind .help_region.land.subs.subs.regionbox2 <Key-Down> {
    if { [ .help_region.land.subs.subs.regionbox2 size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.regionbox2 curselection ] + 1" ]
      if { ${positionsline} < [ .help_region.land.subs.subs.regionbox2 size ] } {
        .help_region.land.subs.subs.regionbox2 selection clear 0 end
        .help_region.land.subs.subs.regionbox2 selection set ${positionsline}
        .help_region.land.subs.subs.regionbox2 activate ${positionsline}
        help_region_search
        .help_region.land.subs.subs.regionbox2 see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.regionbox2 <Key-Up> {
    if { [ .help_region.land.subs.subs.regionbox2 size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.regionbox2 curselection ] - 1" ]
      if { ${positionsline} >= {0} } {
        .help_region.land.subs.subs.regionbox2 selection clear 0 end
        .help_region.land.subs.subs.regionbox2 selection set ${positionsline}
        .help_region.land.subs.subs.regionbox2 activate ${positionsline}
        help_region_search
        .help_region.land.subs.subs.regionbox2 see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.regionbox2 <Key-Next> {
    if { [ .help_region.land.subs.subs.regionbox2 size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.regionbox2 curselection ] + 10" ]
      if { ${positionsline} >= [ .help_region.land.subs.subs.regionbox2 size ] } { set positionsline [ expr "[ .help_region.land.subs.subs.regionbox2 size ] - 1" ] }
      if { ${positionsline} < [ .help_region.land.subs.subs.regionbox2 size ] } {
        .help_region.land.subs.subs.regionbox2 selection clear 0 end
        .help_region.land.subs.subs.regionbox2 selection set ${positionsline}
        .help_region.land.subs.subs.regionbox2 activate ${positionsline}
        help_region_search
        .help_region.land.subs.subs.regionbox2 see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.regionbox2 <Key-Prior> {
    if { [ .help_region.land.subs.subs.regionbox2 size ] != {0} } {
      update
      set positionsline [ expr "[ .help_region.land.subs.subs.regionbox2 curselection ] - 10" ]
      if { ${positionsline} < {0} } { set positionsline 0 }
      if { ${positionsline} >= {0} } {
        .help_region.land.subs.subs.regionbox2 selection clear 0 end
        .help_region.land.subs.subs.regionbox2 selection set ${positionsline}
        .help_region.land.subs.subs.regionbox2 activate ${positionsline}
        help_region_search
        .help_region.land.subs.subs.regionbox2 see ${positionsline}
      }
    }
  }
  bind .help_region.land.subs.subs.regionbox2 <Key-Home> {
    if { [ .help_region.land.subs.subs.regionbox2 size ] != {0} } {
      update
      .help_region.land.subs.subs.regionbox2 selection clear 0 end
      .help_region.land.subs.subs.regionbox2 selection set {0}
      .help_region.land.subs.subs.regionbox2 activate {0}
      help_region_search
      .help_region.land.subs.subs.regionbox2 see {0}
    }
  }
  bind .help_region.land.subs.subs.regionbox2 <Key-End> {
    if { [ .help_region.land.subs.subs.regionbox2 size ] != {0} } {
      update
      .help_region.land.subs.subs.regionbox2 selection clear 0 end
      .help_region.land.subs.subs.regionbox2 selection set end
      .help_region.land.subs.subs.regionbox2 activate end
      help_region_search
      .help_region.land.subs.subs.regionbox2 see end
    }
  }


  # enter - leave bindings
  bind .help_region.land.countrybox <Enter> { focus .help_region.land.countrybox }
  bind .help_region.land.countrybox <Leave> { if { ${searchforregions} == {true} } { focus .help_region.land.subs.land.3.3 } }
  bind .help_region.land.subs.subs.regionbox <Enter> { focus .help_region.land.subs.subs.regionbox }
  bind .help_region.land.subs.subs.subregionbox <Enter> { focus .help_region.land.subs.subs.subregionbox }
  bind .help_region.land.subs.subs.regionbox2 <Enter> { focus .help_region.land.subs.subs.regionbox2 }
  bind .help_region.land.subs.subs.regionbox2 <Leave> { focus .help_region.land.subs.land.3.3 }

  # overall bindings
  bind .help_region <Return>        { .help_region.menu.ok invoke }
  bind .help_region <Key-Escape>    { destroy .help_region }
  bind .help_region <Control-Key-q> { destroy .help_region }

  # begin with selecting one country
  focus .help_region.land.countrybox
}
