# startup only if window not present
if { [ winfo exists .copy ] } {
  raise .copy .
} else {


  # window stuff
  toplevel     .copy
  wm title     .copy {TkWiCe Copyright Notice}
  wm resizable .copy true true
  focus        .copy


  # get content of file
  set copyfile [ file join ${prog_dir} COPYING.html ]
  set copychannel [ open ${copyfile} r ]
  set content [ read ${copychannel} ]
  close ${copychannel}


  # load messages
  msgcat::mclocale ${nls}
  msgcat::mcload [ file join ${prog_dir} nls ]


  # graphics
  set nobutton  [ image create photo -file [ file join ${prog_dir} img close.gif ] ]
  set yesbutton [ image create photo -file [ file join ${prog_dir} img okay.gif ] ]


  # window
  frame .copy.text
		if { ${bTtk} } {
    	ttk::scrollbar .copy.text.yscroll -command { .copy.text.text yview } -orient vertical
		} else {
			scrollbar .copy.text.yscroll -command { .copy.text.text yview } -orient vertical
		}
    text      .copy.text.text -font ${listfont} -wrap word -width 72 -height 35 -padx 10 -pady 10 -cursor [ .copy cget -cursor ] -highlightthickness 0 -yscrollcommand { .copy.text.yscroll set }
              .copy.text.text configure -background {#ffffff} -foreground {#000000}
    set html_out_widget {.copy.text.text}
    source [ file join ${prog_dir} tcl html.tcl ]
  pack .copy.text.text -side left -fill both -expand true
  pack .copy.text.yscroll -side right -fill y
  button .copy.yes -image ${yesbutton} -text [::msgcat::mc {Accept}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command {
    set accept_return {accept}
    destroy .copy
    unset accept_return
  }
  button .copy.no -image ${nobutton} -text [::msgcat::mc {Refuse}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { exit }
  pack .copy.text -padx 3 -pady 3 -side top -fill both -expand true
  pack .copy.yes .copy.no -padx 3 -pady 3 -side left -fill x -expand true
  .copy.text.text configure -state disabled

  # keyboard
  bind   .copy <Return> { destroy .copy }

  focus .copy.text.text
}
