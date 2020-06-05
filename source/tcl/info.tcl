# info window - source it to use; needed infos:
#   titlefont
#   infotitle
#   infotext
#   infotype (info/yesno - last gets infobutton back)

# startup only if window does not exist
if { [ winfo exists .info ] } {
  raise .info .
} else {

  # window stuff
  toplevel     .info
  wm title     .info ${infotitle}
  wm geometry  .info +[ winfo pointerx . ]+[ winfo pointery . ]
  wm transient .info .
  focus        .info

  # info graphic
  set infoimage  [ image create photo -file [ file join ${prog_dir} img comment.gif ] ]
  set closeimage [ image create photo -file [ file join ${prog_dir} img close.gif ] ]
  set yesimage   [ image create photo -file [ file join ${prog_dir} img okay.gif ] ]

  # draw elements
	if { ${bTtk} } {
  	ttk::labelframe .info.frame1 -text ${infotitle}
	} else {
		labelframe .info.frame1 -font ${titlefont} -text ${infotitle} -padx 8 -pady 0
	}
    label    .info.frame1.infoimage -image ${infoimage} -anchor n
    label    .info.frame1.text -text ${infotext} -justify left -anchor w
    pack     .info.frame1.infoimage .info.frame1.text -side left -padx 0 -pady 8 -fill y
  grid       .info.frame1 -sticky new -padx 5 -pady 5

  frame .info.frame2
    if { ${infotype} == {yesno} } {
      global infobutton
      set infobutton {no}
			if { ${bTtk} } {
				ttk::button .info.frame2.yes -image ${yesimage} -text [::msgcat::mc {Yes}] -compound left -command {
					set infobutton {yes}
					destroy .info
				}
			} else {
				button .info.frame2.yes -image ${yesimage} -text [::msgcat::mc {Yes}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command {
					set infobutton {yes}
					destroy .info
				}
			}
			if { ${bTtk} } {
				ttk::button .info.frame2.no -image ${closeimage} -text [::msgcat::mc {No}] -compound left -command {
					set infobutton {no}
					destroy .info
				}
			} else {
				button .info.frame2.no -image ${closeimage} -text [::msgcat::mc {No}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command {
					set infobutton {no}
					destroy .info
				}
			}
      pack .info.frame2.yes .info.frame2.no -side left -fill x -expand true
    } elseif { ${infotype} == {info} } {
			if { ${bTtk} } {
      	ttk::button .info.frame2.close -image ${closeimage} -text [::msgcat::mc {Close}] -compound left -command { destroy .info }
			} else {
				button .info.frame2.close -image ${closeimage} -text [::msgcat::mc {Close}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { destroy .info }
			}
      pack   .info.frame2.close -side left -fill x -expand true
    }
  grid .info.frame2 -sticky ew -padx 5 -pady 5

  # keybord bindings
  if { ${infotype} == {info} } {
    bind .info <Key> { destroy .info }
  } else {
    bind .info <Key-Escape> {
      set infobutton {no}
      destroy .info
    }
    bind .info <Control-Key-q> {
      set infobutton {no}
      destroy .info
    }
    bind .info <Key-Return> {
      set infobutton {yes}
      destroy .info
    }
  }

  # window placement - mousepointer in the middle ...
  tkwait visibility .info
  set xposition_info [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .info ] / 2" ]" ]
  set yposition_info [ expr "[ winfo pointery . ] - [ expr "[ winfo height .info ] / 2" ]" ]
  if { ${xposition_info} < {0} } { set xposition_info {0} }
  if { ${yposition_info} < {0} } { set yposition_info {0} }
  if { [ expr "[ winfo width  .info ] + ${xposition_info}" ] > [ winfo screenwidth  . ] } { set xposition_info [ expr "[ winfo screenwidth  . ] - [ winfo width  .info ]" ] }
  if { [ expr "[ winfo height .info ] + ${yposition_info}" ] > [ winfo screenheight . ] } { set yposition_info [ expr "[ winfo screenheight . ] - [ winfo height .info ]" ] }
  wm geometry .info +${xposition_info}+${yposition_info}

  # wait until window is gone ...
  tkwait window .info
}
