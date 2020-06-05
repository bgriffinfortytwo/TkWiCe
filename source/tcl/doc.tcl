# call: tclsh thisscript conffile
#       tclsh thisscript conffile 0.jht

package require Tk [ info tclversion ]
package require msgcat


# ttk
set bTtk 0
if { [ info tclversion ] != {8.4} } {
	package require Ttk [ info tclversion ]
	if { [ lsearch -exact [ttk::themes] {clam} ] > 0 } {
		set sTheme clam
		ttk::setTheme ${sTheme}
	}
	set bTtk 1
}


# read the configuration file
source [ lindex $argv 0 ]


# Tile only for the tile theme
if { ( ${onecolor} == {false} && ${colortheme} != {tile} ) || ${onecolor} != {false} } {
	set bTtk 0
}


# load messages
msgcat::mclocale ${nls}
msgcat::mcload [ file join ${prog_dir} nls ]


# package conmen
set conmen_version {false}
catch { set conmen_version [ package require conmen ] }
if { ${conmen_version} == {false} } { lappend auto_path [ file join ${prog_dir} tcl tk ] }
package require conmen


# two lines because documentation is not translated so far ...
set nls2 ${nls}
set nls {en}


# set startup content
if { [ llength $argv ] == {2} } {
  set content [ lindex $argv 1 ]
} else {
  set content {404.html}
}


set progname  [::msgcat::mc {TkWiCe Help Browser}]
wm title      . ${progname}
wm resizable  . true true
wm iconname   . ${progname}


# icon
catch { wm iconphoto . -default [ image create photo -file [ file join ${prog_dir} img tkwice48.gif ] ] [ image create photo -file [ file join ${prog_dir} img tkwice32.gif ] ] }


# HTML files to select for browser
set types {
  { "HTML" {.htm .html .HTM .HTML} }
}


# set colors
source [ file join ${prog_dir} tcl color.tcl ]
# source the option database
source [ file join ${prog_dir} tcl style.tcl ]
# set blank history list
set history {}


# show content
proc showcontent { showfile } {
  global prog_dir nls nls2 h1font h2font h3font smallfont listfont textfont counter history history2
  if { [ regexp "#" ${showfile} ] } {
    set anchor  [ string range ${showfile} [ expr "[ string first "#" ${showfile} ] + 1" ] end ]
    set showfile [ string range ${showfile} 0 [ expr "[ string first "#" ${showfile} ] - 1" ] ]
  } else {
    set anchor {}
  }
  set scrolltoline {0.0}
  .text.text configure -state normal
  .text.text delete 0.0 end
  if { [ lsearch ${history} ${showfile} ] == {-1} } { lappend history ${showfile} }
  lappend history2 ${showfile}
  if { [ llength ${history2} ] > {2} } { set history2 [ lrange ${history2} 1 2 ] }
  if { [ llength ${history2} ] == {2} } {
    .menu.left configure -state normal
  } else {
    .menu.left configure -state disabled
  }
  .menu.right configure -state disabled
  if { ${showfile} == {index.html} } {
    .menu.home configure -state disabled
  } else {
    .menu.home configure -state normal
  }
  if { ${showfile} != {README.html} && ${showfile} != {COPYING.html} && ${showfile} != {TODO.html} && ${showfile} != {CHANGES.html} && ${showfile} != {LANGUAGE.html} } {
    if { [ file exists [ file join ${prog_dir} doc ${nls2} ${showfile} ] ] } {
      set contentfile [ file join ${prog_dir} doc ${nls2} ${showfile} ]
    } else {
      set contentfile [ file join ${prog_dir} doc ${nls} ${showfile} ]
    }
  } else {
    if { ${showfile} == {LANGUAGE.html} } {
      set contentfile [ file join ${prog_dir} LANGUAGES.html ]
    } else {
      set contentfile [ file join ${prog_dir} ${showfile} ]
    }
  }
  if { ! [ file exists ${contentfile} ] } {
    set contentfile [ file join ${prog_dir} doc ${nls} 404.html ]
  }
  set contentchannel [ open ${contentfile} r ]
  set content [ read ${contentchannel} ]
  close ${contentchannel}
  # set a font tag
  .text.text tag configure filefont -font "\"[ font actual ${textfont} -family ]\" [ expr "[ font actual ${textfont} -size ] - 2" ] normal" -justify right -foreground {#777777}
  set html_out_widget {.text.text}
  source [ file join ${prog_dir} tcl html.tcl ]
  if { ${scrolltoline} != {0.0} } {
    set scrolltoline [ string range ${scrolltoline} 0 [ expr "[ string first . ${scrolltoline} ] - 1" ] ]
    set scrolltoline [ expr "${scrolltoline} + 1" ]
    .text.text see ${scrolltoline}.0
  }
  .text.text configure -state disabled
}


# graphics for window
set left       [ image create photo -file [ file join ${prog_dir} img previous.gif ] ]
set right      [ image create photo -file [ file join ${prog_dir} img next.gif ] ]
set home       [ image create photo -file [ file join ${prog_dir} img house.gif ] ]
set help       [ image create photo -file [ file join ${prog_dir} img help.gif ] ]
set help2      [ image create photo -file [ file join ${prog_dir} img help2.gif ] ]
set hint       [ image create photo -file [ file join ${prog_dir} img delete2.gif ] ]
set closeimage [ image create photo -file [ file join ${prog_dir} img close.gif ] ]
set menugif    [ image create photo -file [ file join ${prog_dir} img menu.gif ] ]
set blank      [ image create photo -width 16 -height 16 ]

# window
frame .menu -borderwidth 2 -relief raised
  menubutton .menu.exit -text [::msgcat::mc {File}] -image ${menugif} -font ${smallfont} -compound top -relief flat -borderwidth 0 -padx 10 -pady 1 -menu .menu.exit.menu
    set exitmenu [ menu .menu.exit.menu -tearoff 0 ]
    ${exitmenu} add command -image ${help2} -label " [::msgcat::mc {About}]" -accelerator {?} -compound left -command {
      .menu.home configure -state normal
      set content "<h1>[::msgcat::mc {TkWiCe Help Browser}]</h1><p>[::msgcat::mc {This browser parses and renders simple HTML files. There are only a few tags supported, so it might not be a good choice for use with other HTML files out there.}]</p>"
      set html_out_widget {.text.text}
      .text.text configure -state normal
      .text.text delete 0.0 end
      source [ file join ${prog_dir} tcl html.tcl ]
      .text.text configure -state disabled
      set history2 {}
      .menu.right configure -state disabled
      .menu.left  configure -state disabled
    }
    ${exitmenu} add command -image ${blank} -label " [::msgcat::mc {Open file ...}]" -compound left -command {
      set newfile {}
      set newfile [ tk_getOpenFile -initialdir [ file join ${prog_dir} doc ] -parent . -title [::msgcat::mc {Open file ...}] -filetypes ${types} ]
      if { [ file exists ${newfile} ] } { showcontent ${newfile} }
    }
    ${exitmenu} add separator
    ${exitmenu} add command -image ${closeimage} -label " [::msgcat::mc {Close}]" -accelerator {Qtrl+Q} -compound left -command { exit }
  pack .menu.exit -side left -fill y

  frame .menu.separator1 -padx 5 -pady 3
    frame .menu.separator1.draw -width 2 -borderwidth 2 -relief sunken
  pack .menu.separator1.draw -side left -fill y -expand true
  pack .menu.separator1 -side left -fill y

  button .menu.home -image ${home} -text [::msgcat::mc {Home}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 15 -borderwidth 0 -command { showcontent {index.html} }
  pack .menu.home -side left -pady 0 -padx 0
  button .menu.left -image ${left} -text [::msgcat::mc {Back}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 2 -borderwidth 0 -state disabled -command {
    showcontent [ lindex ${history2} 0 ]
    .menu.right configure -state normal
    .menu.left  configure -state disabled
  }
  pack .menu.left -side left -pady 0 -padx 0
  button .menu.right -image ${right} -text [::msgcat::mc {Forward}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 2 -borderwidth 0 -state disabled -command {
    .menu.left  configure -state normal
    showcontent [ lindex ${history2} 0 ]
    .menu.right configure -state disabled
  }
  pack .menu.right -side left -pady 0 -padx 0
  button .menu.help -image ${help} -text [::msgcat::mc {About}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 2 -borderwidth 0 -command {
    .menu.home configure -state normal
    set content "<h1>[::msgcat::mc {TkWiCe Help Browser}]</h1><p>[::msgcat::mc {This browser parses and renders simple HTML files. There are only a few tags supported, so it might not be a good choice for use with other HTML files out there.}]</p>"
    set html_out_widget {.text.text}
    .text.text configure -state normal
    .text.text delete 0.0 end
    source [ file join ${prog_dir} tcl html.tcl ]
    .text.text configure -state disabled
    set history2 {}
    .menu.right configure -state disabled
    .menu.left  configure -state disabled
  }
  pack .menu.help -side right -pady 0 -padx 0
pack .menu -padx 3 -pady 3 -fill x -side top

if { [ string length [::msgcat::mc {The documentation is so far only available in english.}] ] != {0} } {
  frame .nls -background ${selectbackground} -relief groove -borderwidth 2 -padx 3 -pady 0
    label .nls.text -text [::msgcat::mc {The documentation is so far only available in english.}] -font ${smallfont} -anchor w -background ${selectbackground} -foreground ${selectforeground} -padx 0 -pady 0
    pack  .nls.text -side left -fill x -padx 0 -pady 0
    button .nls.button -image ${hint} -anchor e -width 16 -height 16 -background ${selectbackground} -highlightthickness 0 -padx 0 -pady 0 -relief flat -borderwidth 0 -command { destroy .nls }
    pack   .nls.button -side right -padx 0 -pady 0
  pack  .nls -padx 3 -pady 0 -fill x -side top
}

frame .text
	if { ${bTtk} } {
  	ttk::scrollbar .text.yscroll -command { .text.text yview } -orient vertical
	} else {
		scrollbar .text.yscroll -command { .text.text yview } -orient vertical
	}
  text      .text.text -setgrid true -font ${listfont} -wrap word -width 72 -height 30 -padx 10 -pady 10 -cursor [ . cget -cursor ] -highlightthickness 0 -yscrollcommand { .text.yscroll set }
            .text.text configure -background {#ffffff} -foreground {#000000}
            .text.text tag configure text -font ${textfont}
            .text.text insert end "\u00BB${content}\u00AB: [::msgcat::mc {rendering, one moment please ...}]" text
  pack .text.text -side left -fill both -expand true
  pack .text.yscroll -side right -fill y
pack .text -padx 3 -pady 3 -fill both -expand true -side top
::conmen .text.text

if { ${bTtk} } {
	ttk::button .ok -image ${closeimage} -text [::msgcat::mc {Close}] -compound left -command { exit }
} else {
	button .ok -image ${closeimage} -text [::msgcat::mc {Close}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { exit }
}
pack .ok -padx 3 -pady 3 -fill x -side top


# window placement - mousepointer in the middle ...
tkwait visibility .
set xposition_doc [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  . ] / 2" ]" ]
set yposition_doc [ expr "[ winfo pointery . ] - [ expr "[ winfo height . ] / 2" ]" ]
if { ${xposition_doc} < {0} } { set xposition_doc {0} }
if { ${yposition_doc} < {0} } { set yposition_doc {0} }
if { [ expr "[ winfo width  . ] + ${xposition_doc}" ] > [ winfo screenwidth  . ] } { set xposition_doc [ expr "[ winfo screenwidth  . ] - [ winfo width  . ]" ] }
if { [ expr "[ winfo height . ] + ${yposition_doc}" ] > [ winfo screenheight . ] } { set yposition_doc [ expr "[ winfo screenheight . ] - [ winfo height . ]" ] }
wm geometry . +${xposition_doc}+${yposition_doc}
focus .text.text


# some global bindings
bind . <KeyPress-F1>       { .menu.home invoke }
bind . <KeyPress-question> { .menu.help invoke }
bind . <KeyPress-Home>     { .menu.home invoke }
bind . <KeyPress-Escape>   { exit }
bind . <KeyPress-F10>      { exit }
bind . <Control-Key-q>     { exit }
bind . <KeyPress-Left>     { .menu.left invoke }
bind . <KeyPress-Right>    { .menu.right invoke }


# startup with the file "content"
update
showcontent ${content}
