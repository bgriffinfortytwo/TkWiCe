# helper tool for selecting a classes entry
# outsourced from editwine.tcl


# it is a proc ...
proc help_class {} {


# start only once
if { [ winfo exists .help_class ] } { raise .help_class . ; return }


# some basic things
global prog_dir titlefont textfont lightcolor land prog_dir okaybutton closebutton select_class bTtk


# window stuff
toplevel     .help_class
wm title     .help_class [::msgcat::mc {Classification}]
wm geometry  .help_class +[ winfo pointerx . ]+[ winfo pointery . ]
focus        .help_class
wm transient .help_class .


# get list from classes-file
set readchannel [ open [ file join ${prog_dir} ext classes ] r ]
foreach entry [ read -nonewline ${readchannel} ] {
  lappend list_classes ${entry}
}
close ${readchannel}
# list of classes for land
set number {1}
set list_class {}
while { ${number} <= [ llength ${list_classes} ] } {
  if { ${land} == [ lindex ${list_classes} [ expr " ${number} - 1" ] ] } {
    lappend list_class [ lindex ${list_classes} ${number} ]
  }
  incr number 2
}


# build up window
if { ${bTtk} } {
	ttk::labelframe .help_class.preview -text [::msgcat::mc {Selection}]
} else {
	labelframe .help_class.preview -text [::msgcat::mc {Selection}] -padx 2 -pady 2
}
  label .help_class.preview.text -text {} -font ${titlefont} -justify left
pack .help_class.preview.text -side left -fill x -expand true
listbox .help_class.box -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 0
frame .help_class.menu
  button .help_class.menu.ok -image ${okaybutton} -text [::msgcat::mc {Take Over}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -state disabled -command {
    set classification ${select_class}
    .editleft.1.class2.box configure -textvariable classification
    destroy .help_class
  }
  button .help_class.menu.abort -image ${closebutton} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { destroy .help_class }
pack .help_class.menu.ok .help_class.menu.abort -side left -fill x -expand true
pack .help_class.preview -side top -padx 5 -pady 5 -fill x
pack .help_class.box     -side top -padx 5 -pady 5 -fill both -expand true
pack .help_class.menu    -side top -padx 5 -pady 5 -fill x


# do something if something is selected
bind .help_class.box <ButtonRelease-1> {
  .help_class.menu.ok configure -state normal
  set select_class [ .help_class.box get [ .help_class.box curselection ] ]
  .help_class.preview.text configure -text ${select_class}
}

bind .help_class.box <Double-1> {
  set classification ${select_class}
  .editleft.1.class2.box configure -textvariable classification
  destroy .help_class
}

bind .help_class <Return> {
  if { [ info exists select_class ] } {
    set classification ${select_class}
    .editleft.1.class2.box configure -textvariable classification
    destroy .help_class
  }
}

bind .help_class <Key-Down> {
  if { [ .help_class.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_class.box curselection ] + 1" ]
    if { ${positionsline} < [ .help_class.box size ] } {
      .help_class.box selection clear 0 end
      .help_class.box selection set ${positionsline}
      .help_class.box activate ${positionsline}
      set select_class [ .help_class.box get [ .help_class.box curselection ] ]
      .help_class.preview.text configure -text ${select_class}
    }
  }
}

bind .help_class <Key-Up> {
  if { [ .help_class.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_class.box curselection ] - 1" ]
    if { ${positionsline} >= {0} } {
      .help_class.box selection clear 0 end
      .help_class.box selection set ${positionsline}
      .help_class.box activate ${positionsline}
      set select_class [ .help_class.box get [ .help_class.box curselection ] ]
      .help_class.preview.text configure -text ${select_class}
    }
  }
}

bind .help_class <Next> {
  if { [ .help_class.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_class.box curselection ] + 10" ]
    if { ${positionsline} >= [ .help_class.box size ] } { set positionsline [ expr "[ .help_class.box size ] - 1" ] }
    if { ${positionsline} < [ .help_class.box size ] } {
      .help_class.box selection clear 0 end
      .help_class.box selection set ${positionsline}
      .help_class.box activate ${positionsline}
      set select_class [ .help_class.box get [ .help_class.box curselection ] ]
      .help_class.preview.text configure -text ${select_class}
    }
  }
}

bind .help_class <Prior> {
  if { [ .help_class.box size ] != {0} } {
    update
    set positionsline [ expr "[ .help_class.box curselection ] - 10" ]
    if { ${positionsline} < {0} } { set positionsline 0 }
    if { ${positionsline} >= {0} } {
      .help_class.box selection clear 0 end
      .help_class.box selection set ${positionsline}
      .help_class.box activate ${positionsline}
      set select_class [ .help_class.box get [ .help_class.box curselection ] ]
      .help_class.preview.text configure -text ${select_class}
    }
  }
}

bind .help_class <Key-Home> {
  if { [ .help_class.box size ] != {0} } {
    update
    .help_class.menu.ok configure -state normal
    .help_class.box selection clear 0 end
    .help_class.box selection set 0
    .help_class.box activate 0
    set select_class [ .help_class.box get [ .help_class.box curselection ] ]
    .help_class.preview.text configure -text ${select_class}
  }
}

bind .help_class <Key-End> {
  if { [ .help_class.box size ] != {0} } {
    update
    .help_class.menu.ok configure -state normal
    .help_class.box selection clear 0 end
    .help_class.box selection set end
    .help_class.box activate end
    set select_class [ .help_class.box get [ .help_class.box curselection ] ]
    .help_class.preview.text configure -text ${select_class}
  }
}

bind .help_class <Key-Escape>    { destroy .help_class }
bind .help_class <Control-Key-q> { destroy .help_class }

bind .help_class <Key-space> { .help_class.menu.ok invoke }


# pack classes in listbox
set longline {10}
foreach entry ${list_class} {
  .help_class.box insert end ${entry}
  if { ${longline} < [ string length ${entry} ] } { set longline [ string length ${entry} ] }
}
.help_class.box configure -height [ llength ${list_class} ] -width ${longline}


# if no list - exit
if { [ llength ${list_class} ] == {0} } {
  destroy .help_class
  set infotitle [::msgcat::mc {No classes found!}]
  set infotext  [::msgcat::mc {To the requestet country none class is known.}]
  set infotype  {info}
  source [ file join ${prog_dir} tcl info.tcl ]


# place the window
} else {
  tkwait visibility .help_class
  set xposition_info [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .help_class ] / 2" ]" ]
  set yposition_info [ expr "[ winfo pointery . ] - [ expr "[ winfo height .help_class ] / 2" ]" ]
  if { ${xposition_info} < {0} } { set xposition_info {0} }
  if { ${yposition_info} < {0} } { set yposition_info {0} }
  if { [ expr "[ winfo width  .help_class ] + ${xposition_info}" ] > [ winfo screenwidth  . ] } { set xposition_info [ expr "[ winfo screenwidth  . ] - [ winfo width  .help_class ]" ] }
  if { [ expr "[ winfo height .help_class ] + ${yposition_info}" ] > [ winfo screenheight . ] } { set yposition_info [ expr "[ winfo screenheight . ] - [ winfo height .help_class ]" ] }
  wm geometry .help_class +${xposition_info}+${yposition_info}


# select first line
  update
  .help_class.box selection set 0
  .help_class.box activate 0
  set select_class [ .help_class.box get [ .help_class.box curselection ] ]
  .help_class.preview.text configure -text ${select_class}
  .help_class.menu.ok configure -state normal
}


# close the proc
}
