########################################################################
#
#  ttips
#  =====
#
#  simple Tcl/Tk widget providing tooltips
#
#
########################################################################
#
#  usage
#  -----
#    package require ttips
#    ::ttips pathName -text mytext ?options?
#
#  optional supported arguments
#  ----------------------------
#    -font
#    -background
#    -foreground
#
#  So if you want the tooltip "close" shown to the widget ".close",
#  add after loading the package once a line like this to your
#  program source:
#
#  ::ttips .close -text "close" -background {#00f} -foreground {#fff}
#
#
########################################################################


package require Tk


proc ::ttips { args } {
  # initial stuff
  global TTIPSARGS TTIPSARGSLIST
  set TTIPSARGS ${args}
  lappend TTIPSARGSLIST ${args}

  # basic stuff
  set TTIPSTOWIDGET [ lindex ${args} 0 ]

  # binding to mouse leave - destroy
  bind ${TTIPSTOWIDGET} <Leave> {+
    set TTIPSTOPLEVEL [ winfo toplevel "%W" ]
    if { [ winfo exists ${TTIPSTOPLEVEL}ttipshintwindow ] } { destroy ${TTIPSTOPLEVEL}ttipshintwindow }
    focus -force ${TTIPSTOPLEVEL}
  }

  # binding to mouse enter
  bind ${TTIPSTOWIDGET} <Enter> {+
    # basic settings
    label .ttipstempwindow
    set TTIPSFONT       [ .ttipstempwindow cget -font ]
    set TTIPSBACKGROUND [ .ttipstempwindow cget -background ]
    set TTIPSFOREGROUND [ .ttipstempwindow cget -foreground ]
    set TTIPSTEXT { }
    destroy .ttipstempwindow
    set TTIPSBACKGROUND2 ${TTIPSBACKGROUND}

    # find out the parent window
    set TTIPSTOPLEVEL [ winfo toplevel "%W" ]

    # fishing for the right settings ...
    foreach TTIPSARGS ${TTIPSARGSLIST} { if { [ lindex ${TTIPSARGS} 0 ] == "%W" } { set TTIPSARGS2 ${TTIPSARGS} } }

    # override some settings
    set ttipscountarguments {1}
    while { ${ttipscountarguments} < [ llength ${TTIPSARGS2} ] } {
      if { [ lindex ${TTIPSARGS2} ${ttipscountarguments} ] == {-background} } {
        incr ttipscountarguments
        set TTIPSBACKGROUND [ lindex ${TTIPSARGS2} ${ttipscountarguments} ]
      } elseif { [ lindex ${TTIPSARGS2} ${ttipscountarguments} ] == {-foreground} } {
        incr ttipscountarguments
        set TTIPSFOREGROUND [ lindex ${TTIPSARGS2} ${ttipscountarguments} ]
      } elseif { [ lindex ${TTIPSARGS2} ${ttipscountarguments} ] == {-font} } {
        incr ttipscountarguments
        set TTIPSFONT [ lindex ${TTIPSARGS2} ${ttipscountarguments} ]
      } elseif { [ lindex ${TTIPSARGS2} ${ttipscountarguments} ] == {-text} } {
        incr ttipscountarguments
        set TTIPSTEXT [ lindex ${TTIPSARGS2} ${ttipscountarguments} ]
      }
      incr ttipscountarguments
    }

    # set border solid if no background was specified
    if { ${TTIPSBACKGROUND} == ${TTIPSBACKGROUND2} } {
      set TTIPSRELIEF {solid}
      set TTIPSBORDERWIDTH {1}
    } else {
      set TTIPSRELIEF {flat}
      set TTIPSBORDERWIDTH {0}
    }

    # next find out a usable size for tooltip
    label .ttipstempwindow -text " ${TTIPSTEXT} " -font ${TTIPSFONT} -background ${TTIPSBACKGROUND} -foreground ${TTIPSFOREGROUND} -padx 1 -pady 1 -relief ${TTIPSRELIEF} -borderwidth ${TTIPSBORDERWIDTH}
    set TTIPSHOWWIDTH  [ winfo reqwidth  .ttipstempwindow ]
    set TTIPSHOWHEIGHT [ winfo reqheight .ttipstempwindow ]
    destroy .ttipstempwindow

    # take sure that the tooltip doesn't exist yet
    if { [ winfo exists ${TTIPSTOPLEVEL}ttipshintwindow ] } { destroy ${TTIPSTOPLEVEL}ttipshintwindow }

    # window stuff
    toplevel            ${TTIPSTOPLEVEL}ttipshintwindow
    focus               ${TTIPSTOPLEVEL}ttipshintwindow
    wm geometry         ${TTIPSTOPLEVEL}ttipshintwindow ${TTIPSHOWWIDTH}x${TTIPSHOWHEIGHT}
    wm withdraw         ${TTIPSTOPLEVEL}ttipshintwindow
    wm focusmodel       ${TTIPSTOPLEVEL}ttipshintwindow passive
    wm transient        ${TTIPSTOPLEVEL}ttipshintwindow ${TTIPSTOPLEVEL}
    wm overrideredirect ${TTIPSTOPLEVEL}ttipshintwindow true
    wm deiconify        ${TTIPSTOPLEVEL}ttipshintwindow
    wm resizable        ${TTIPSTOPLEVEL}ttipshintwindow false false
    wm geometry         ${TTIPSTOPLEVEL}ttipshintwindow +[ expr "[ winfo pointerx . ] + 5" ]+[ expr "[ winfo pointery . ] + 5" ]

    # display tooltip
    label ${TTIPSTOPLEVEL}ttipshintwindow.text -text ${TTIPSTEXT} -font ${TTIPSFONT} -background ${TTIPSBACKGROUND} -foreground ${TTIPSFOREGROUND} -padx 1 -pady 1 -relief ${TTIPSRELIEF} -borderwidth ${TTIPSBORDERWIDTH}
    pack  ${TTIPSTOPLEVEL}ttipshintwindow.text -fill x
    raise ${TTIPSTOPLEVEL}ttipshintwindow ${TTIPSTOPLEVEL}
  }
}

package provide ttips 0.2
