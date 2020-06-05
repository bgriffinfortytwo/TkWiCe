# helper tool for selecting a bio entry
# outsourced from editwine.tcl


# it is a proc ...
proc help_bio {} {


# start only once
if { [ winfo exists .help_bio ] } { raise .help_bio. ; return }


# some basic things
global prog_dir titlefont textfont lightcolor bio nls okaybutton closebutton select_bio bTtk


# window stuff
toplevel     .help_bio
wm title     .help_bio [::msgcat::mc {Bio}]
wm geometry  .help_bio +[ winfo pointerx . ]+[ winfo pointery . ]
focus        .help_bio
wm transient .help_bio .


# get list from bio-file
set readchannel [ open [ file join ${prog_dir} ext bio.${nls} ] r ]
foreach entry [ read -nonewline ${readchannel} ] {
  lappend list_bio ${entry}
}
close ${readchannel}


# build up window
if { ${bTtk} } {
	ttk::labelframe .help_bio.preview -text [::msgcat::mc {Selection}]
} else {
	labelframe .help_bio.preview -text [::msgcat::mc {Selection}] -padx 2 -pady 2
}
  label .help_bio.preview.text -text {} -font ${titlefont} -justify left
pack .help_bio.preview.text -side left -fill x -expand true
frame .help_bio.box
  listbox   .help_bio.box.box -width 20 -height 15 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 0 -yscrollcommand {.help_bio.box.scroll set}
	if { ${bTtk} } {
  	ttk::scrollbar .help_bio.box.scroll -command {.help_bio.box.box yview} -orient vertical
	} else {
		scrollbar .help_bio.box.scroll -command {.help_bio.box.box yview} -orient vertical
	}
pack .help_bio.box.box -side left -fill both -expand true
pack .help_bio.box.scroll -side left -fill y
frame .help_bio.menu
  button .help_bio.menu.ok -image ${okaybutton} -text [::msgcat::mc {Take Over}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -state disabled -command {
    set bio ${select_bio}
    .editleft.1.bio2.box configure -textvariable bio
    destroy .help_bio
  }
  button .help_bio.menu.abort -image ${closebutton} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { destroy .help_bio }
pack .help_bio.menu.ok .help_bio.menu.abort -side left -fill x -expand true
pack .help_bio.preview -side top -padx 5 -pady 5 -fill x
pack .help_bio.box     -side top -padx 5 -pady 5 -fill both -expand true
pack .help_bio.menu    -side top -padx 5 -pady 5 -fill x
focus .help_bio.box.box


# do something if something is selected
bind .help_bio.box.box <ButtonRelease-1> {
  .help_bio.menu.ok configure -state normal
  set select_bio [ .help_bio.box.box get [ .help_bio.box.box curselection ] ]
  .help_bio.preview.text configure -text ${select_bio}
}

bind .help_bio.box.box <Double-1> {
  set bio ${select_bio}
  .editleft.1.bio2.box configure -textvariable bio
  destroy .help_bio
}

bind .help_bio <Return> {
  if { [ info exists select_bio ] } {
    set bio ${select_bio}
    .editleft.1.bio2.box configure -textvariable bio
    destroy .help_bio
  }
}

bind .help_bio <Key-Down> {
  if { [ .help_bio.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_bio.box.box curselection ] + 1" ]
    if { ${positionsline} < [ .help_bio.box.box size ] } {
      .help_bio.menu.ok configure -state normal
      .help_bio.box.box selection clear 0 end
      .help_bio.box.box selection set ${positionsline}
      .help_bio.box.box activate ${positionsline}
      .help_bio.box.box see ${positionsline}
      set select_bio [ .help_bio.box.box get [ .help_bio.box.box curselection ] ]
      .help_bio.preview.text configure -text ${select_bio}
    }
  }
}

bind .help_bio <Key-Up> {
  if { [ .help_bio.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_bio.box.box curselection ] - 1" ]
    if { ${positionsline} >= {0} } {
      .help_bio.menu.ok configure -state normal
      .help_bio.box.box selection clear 0 end
      .help_bio.box.box selection set ${positionsline}
      .help_bio.box.box activate ${positionsline}
      .help_bio.box.box see ${positionsline}
      set select_bio [ .help_bio.box.box get [ .help_bio.box.box curselection ] ]
      .help_bio.preview.text configure -text ${select_bio}
    }
  }
}

bind .help_bio <Next> {
  if { [ .help_bio.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_bio.box.box curselection ] + 10" ]
    if { ${positionsline} >= [ .help_bio.box.box size ] } { set positionsline [ expr "[ .help_bio.box.box size ] - 1" ] }
    if { ${positionsline} < [ .help_bio.box.box size ] } {
      .help_bio.menu.ok configure -state normal
      .help_bio.box.box selection clear 0 end
      .help_bio.box.box selection set ${positionsline}
      .help_bio.box.box activate ${positionsline}
      .help_bio.box.box see ${positionsline}
      set select_bio [ .help_bio.box.box get [ .help_bio.box.box curselection ] ]
      .help_bio.preview.text configure -text ${select_bio}
    }
  }
}

bind .help_bio <Prior> {
  if { [ .help_bio.box.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_bio.box.box curselection ] - 10" ]
    if { ${positionsline} < {0} } { set positionsline 0 }
    if { ${positionsline} >= {0} } {
      .help_bio.menu.ok configure -state normal
      .help_bio.box.box selection clear 0 end
      .help_bio.box.box selection set ${positionsline}
      .help_bio.box.box activate ${positionsline}
      .help_bio.box.box see ${positionsline}
      set select_bio [ .help_bio.box.box get [ .help_bio.box.box curselection ] ]
      .help_bio.preview.text configure -text ${select_bio}
    }
  }
}

bind .help_bio <Key-Home> {
  if { [ .help_bio.box.box size ] != {0} } {
    update
    .help_bio.menu.ok configure -state normal
    .help_bio.box.box selection clear 0 end
    .help_bio.box.box selection set 0
    .help_bio.box.box activate 0
    .help_bio.box.box see 0
    set select_bio [ .help_bio.box.box get [ .help_bio.box.box curselection ] ]
    .help_bio.preview.text configure -text ${select_bio}
  }
}

bind .help_bio <Key-End> {
  if { [ .help_bio.box.box size ] != {0} } {
    update
    .help_bio.menu.ok configure -state normal
    .help_bio.box.box selection clear 0 end
    .help_bio.box.box selection set end
    .help_bio.box.box activate end
    .help_bio.box.box see end
    set select_bio [ .help_bio.box.box get [ .help_bio.box.box curselection ] ]
    .help_bio.preview.text configure -text ${select_bio}
  }
}

bind .help_bio <Key-Escape>    { destroy .help_bio }
bind .help_bio <Control-Key-q> { destroy .help_bio }

bind .help_bio <Key-space>  { .help_bio.menu.ok invoke }


# pack bio in listbox
foreach entry ${list_bio} {
  .help_bio.box.box insert end ${entry}
}


# place the window
tkwait visibility .help_bio
set xposition_info [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .help_bio ] / 2" ]" ]
set yposition_info [ expr "[ winfo pointery . ] - [ expr "[ winfo height .help_bio ] / 2" ]" ]
if { ${xposition_info} < {0} } { set xposition_info {0} }
if { ${yposition_info} < {0} } { set yposition_info {0} }
if { [ expr "[ winfo width  .help_bio ] + ${xposition_info}" ] > [ winfo screenwidth  . ] } { set xposition_info [ expr "[ winfo screenwidth  . ] - [ winfo width  .help_bio ]" ] }
if { [ expr "[ winfo height .help_bio ] + ${yposition_info}" ] > [ winfo screenheight . ] } { set yposition_info [ expr "[ winfo screenheight . ] - [ winfo height .help_bio ]" ] }
wm geometry .help_bio +${xposition_info}+${yposition_info}


# select first line
if { [ .help_bio.box.box size ] != {0} } {
  update
  .help_bio.box.box selection set 0
  .help_bio.box.box activate 0
  set select_bio [ .help_bio.box.box get 0 ]
  .help_bio.preview.text configure -text ${select_bio}
  .help_bio.menu.ok configure -state normal
}


# close the proc
}
