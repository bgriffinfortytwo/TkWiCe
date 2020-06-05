# helper tool for selecting an already known vintner
# outsourced from editwine.tcl


# it is a proc ...
proc help_vintner { vintnerfrom } {


# start only once
if { [ winfo exists .help_vintner ] } { raise .help_vintner . ; return }


# some basic things
global datadir titlefont textfont lightcolor dealer prog_dir okaybutton closebutton select_vintner vintnerwidget bTtk


# determine where the result should go to
if { ${vintnerfrom} == {input} } {
  set vintnerwidget {.input.frame1.note2.entry}
} else {
  set vintnerwidget {.editright.0.dealer2.text}
}


# window stuff
toplevel     .help_vintner
wm title     .help_vintner [::msgcat::mc {Dealer}]
wm geometry  .help_vintner +[ winfo pointerx . ]+[ winfo pointery . ]
focus        .help_vintner
wm transient .help_vintner .


# get list from vintner-file
set vintnerlist {}
set dealerfile [ file join ${datadir} dealer ]
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
      lappend vintnerlist [ lindex ${entry} 0 ]
    }
  }
}


# build up window
if { ${bTtk} } {
	ttk::labelframe .help_vintner.preview -text [::msgcat::mc {Selection}]
} else {
	labelframe .help_vintner.preview -text [::msgcat::mc {Selection}] -padx 2 -pady 2
}
label .help_vintner.preview.text -text {} -font ${titlefont} -justify left
pack .help_vintner.preview.text -side left -fill x -expand true
frame .help_vintner.box
  listbox   .help_vintner.box.box -width 20 -height 5 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 0 -yscrollcommand {.help_vintner.box.scroll set}
	if { ${bTtk} } {
  	ttk::scrollbar .help_vintner.box.scroll -command {.help_vintner.box.box yview} -orient vertical
	} else {
		scrollbar .help_vintner.box.scroll -command {.help_vintner.box.box yview} -orient vertical
	}
pack .help_vintner.box.box -side left -fill both -expand true
pack .help_vintner.box.scroll -side left -fill y
frame .help_vintner.menu
  button .help_vintner.menu.ok -image ${okaybutton} -text [::msgcat::mc {Take Over}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -state disabled -command {
    set [ ${vintnerwidget} cget -textvariable ] ${select_vintner}
    ${vintnerwidget} configure -textvariable [ ${vintnerwidget} cget -textvariable ]
    destroy .help_vintner
  }
  button .help_vintner.menu.abort -image ${closebutton} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { destroy .help_vintner }
pack .help_vintner.menu.ok .help_vintner.menu.abort -side left -fill x -expand true
pack .help_vintner.preview -side top -padx 5 -pady 5 -fill x
pack .help_vintner.box     -side top -padx 5 -pady 5 -fill both -expand true
pack .help_vintner.menu    -side top -padx 5 -pady 5 -fill x
focus .help_vintner.box.box


# place the window
if { [ winfo exists .help_vintner ] } {
  tkwait visibility .help_vintner
  set xposition_info [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .help_vintner ] / 2" ]" ]
  set yposition_info [ expr "[ winfo pointery . ] - [ expr "[ winfo height .help_vintner ] / 2" ]" ]
  if { ${xposition_info} < {0} } { set xposition_info {0} }
  if { ${yposition_info} < {0} } { set yposition_info {0} }
  if { [ expr "[ winfo width  .help_vintner ] + ${xposition_info}" ] > [ winfo screenwidth  . ] } { set xposition_info [ expr "[ winfo screenwidth  . ] - [ winfo width  .help_vintner ]" ] }
  if { [ expr "[ winfo height .help_vintner ] + ${yposition_info}" ] > [ winfo screenheight . ] } { set yposition_info [ expr "[ winfo screenheight . ] - [ winfo height .help_vintner ]" ] }
  wm geometry .help_vintner +${xposition_info}+${yposition_info}
}


# do something if something is selected
bind .help_vintner.box.box <ButtonRelease-1> {
  .help_vintner.menu.ok configure -state normal
  set select_vintner [ .help_vintner.box.box get [ .help_vintner.box.box curselection ] ]
  .help_vintner.preview.text configure -text ${select_vintner}
}

bind .help_vintner.box.box <Double-1> {
  if { [ info exists select_vintner ] } { .help_vintner.menu.ok invoke }
}

bind .help_vintner <Return> {
  if { [ info exists select_vintner ] } { .help_vintner.menu.ok invoke }
}

bind .help_vintner <Key-Down> {
  if { [ .help_vintner.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_vintner.box.box curselection ] + 1" ]
    if { ${positionsline} < [ .help_vintner.box.box size ] } {
      .help_vintner.menu.ok configure -state normal
      .help_vintner.box.box selection clear 0 end
      .help_vintner.box.box selection set ${positionsline}
      .help_vintner.box.box activate ${positionsline}
      .help_vintner.box.box see ${positionsline}
      set select_vintner [ .help_vintner.box.box get [ .help_vintner.box.box curselection ] ]
      .help_vintner.preview.text configure -text ${select_vintner}
    }
  }
}

bind .help_vintner <Key-Up> {
  if { [ .help_vintner.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_vintner.box.box curselection ] - 1" ]
    if { ${positionsline} >= {0} } {
      .help_vintner.menu.ok configure -state normal
      .help_vintner.box.box selection clear 0 end
      .help_vintner.box.box selection set ${positionsline}
      .help_vintner.box.box activate ${positionsline}
      .help_vintner.box.box see ${positionsline}
      set select_vintner [ .help_vintner.box.box get [ .help_vintner.box.box curselection ] ]
      .help_vintner.preview.text configure -text ${select_vintner}
    }
  }
}

bind .help_vintner <Next> {
  if { [ .help_vintner.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_vintner.box.box curselection ] + 10" ]
    if { ${positionsline} >= [ .help_vintner.box.box size ] } { set positionsline [ expr "[ .help_vintner.box.box size ] - 1" ] }
    if { ${positionsline} < [ .help_vintner.box.box size ] } {
      .help_vintner.menu.ok configure -state normal
      .help_vintner.box.box selection clear 0 end
      .help_vintner.box.box selection set ${positionsline}
      .help_vintner.box.box activate ${positionsline}
      .help_vintner.box.box see ${positionsline}
      set select_vintner [ .help_vintner.box.box get [ .help_vintner.box.box curselection ] ]
      .help_vintner.preview.text configure -text ${select_vintner}
    }
  }
}

bind .help_vintner <Prior> {
  if { [ .help_vintner.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_vintner.box.box curselection ] - 10" ]
    if { ${positionsline} < {0} } { set positionsline 0 }
    if { ${positionsline} >= {0} } {
      .help_vintner.menu.ok configure -state normal
      .help_vintner.box.box selection clear 0 end
      .help_vintner.box.box selection set ${positionsline}
      .help_vintner.box.box activate ${positionsline}
      .help_vintner.box.box see ${positionsline}
      set select_vintner [ .help_vintner.box.box get [ .help_vintner.box.box curselection ] ]
      .help_vintner.preview.text configure -text ${select_vintner}
    }
  }
}

bind .help_vintner <Key-Home> {
  if { [ .help_vintner.box.box size ] != {0} } {
    update
    .help_vintner.menu.ok configure -state normal
    .help_vintner.box.box selection clear 0 end
    .help_vintner.box.box selection set 0
    .help_vintner.box.box activate 0
    .help_vintner.box.box see 0
    set select_vintner [ .help_vintner.box.box get [ .help_vintner.box.box curselection ] ]
    .help_vintner.preview.text configure -text ${select_vintner}
  }
}

bind .help_vintner <Key-End> {
  if { [ .help_vintner.box.box size ] != {0} } {
    update
    .help_vintner.menu.ok configure -state normal
    .help_vintner.box.box selection clear 0 end
    .help_vintner.box.box selection set end
    .help_vintner.box.box activate end
    .help_vintner.box.box see end
    set select_vintner [ .help_vintner.box.box get [ .help_vintner.box.box curselection ] ]
    .help_vintner.preview.text configure -text ${select_vintner}
  }
}

bind .help_vintner <Key-Escape>    { destroy .help_vintner }
bind .help_vintner <Control-Key-q> { destroy .help_vintner }

bind .help_vintner <Key-space>  { .help_vintner.menu.ok invoke }


# pack vintner in listbox
set longline {10}
set minlines {2}
if { ${minlines} < [ llength ${vintnerlist} ] } {
  set minlines [ llength ${vintnerlist} ]
}
foreach entry ${vintnerlist} {
  .help_vintner.box.box insert end ${entry}
  if { ${longline} < [ string length ${entry} ] } { set longline [ string length ${entry} ] }
}
if { ${minlines} > {10} } { set minlines {10} }
.help_vintner.box.box configure -height ${minlines} -width ${longline}


# select first line
if { [ .help_vintner.box.box size ] != {0} } {
  update
  .help_vintner.box.box selection set 0
  .help_vintner.box.box activate 0
  set select_vintner [ .help_vintner.box.box get 0 ]
  .help_vintner.preview.text configure -text ${select_vintner}
  .help_vintner.menu.ok configure -state normal
}


# if no list - exit
if { [ llength ${vintnerlist} ] == {0} } {
  destroy .help_vintner
  set infotitle [::msgcat::mc {No dealers found!}]
    set infotext  [::msgcat::mc {There is none entry in your dealer database.}]
  set infotype  {info}
  source [ file join ${prog_dir} tcl info.tcl ]
}


# close the proc
}
