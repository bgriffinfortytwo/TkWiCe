# providing procedure "writeconfig"

# check text - convert some illegal chars by typing ...
proc checktext {widget validate_option string_id char} {
  if { ${char} == "\{" } {
    after idle [ list ${widget} configure -validate ${validate_option} ]
    ${widget} delete ${string_id}
    ${widget} insert ${string_id} {[}
  } elseif { ${char} == "\}" } {
    after idle [ list ${widget} configure -validate ${validate_option} ]
    ${widget} delete ${string_id}
    ${widget} insert ${string_id} {]}
  }
  return 1
}

proc writeconfig {firststart} {
  if { [ winfo exists .conf ] } { focus .conf; return }
  global argv progname conffile self changeconfig nls fontfamily fontsize fontstyle titlefont textfont smallfont smallitalicfont listfont basecolor lightcolor midcolor listlines region_space name_space grapes_space currency currency2 prog_dir wish countrybuttons cbupdate colorname show_only_code ulcx ulcy windowplacement centerx centery colortheme onecolor dateformat webbrowser picopenpath viewmode glassname01 glassname02 glassname03 glassname04 glassname05 glassname06 glassname07 glassname08 glassname09 glassname10 close okay manualpoints tooltips grape_add_switch grape_add_syn grape_add_lab grape_add_nat grape_add_synonly grape_add_labnote grape_add_scanrelated majorversion minorversion patchlevel tempscale bTtk
  set changeconfig {true}
  if { ${firststart} != {firststart} } {
    set changeconfig {false}
    set basecolor2 ${basecolor}
    if { ${currency} == "\u20ac" } { set currency {euro} }
    # conffile-editor
    toplevel     .conf
    wm title     .conf "TkWiCe [::msgcat::mc {Preferences}]"
    wm resizable .conf true true
    wm geometry  .conf +[ winfo pointerx . ]+[ winfo pointery . ]
    focus        .conf

    # some vars needed
    set fontfamily [ font actual ${textfont} -family ]
    set fontsize   [ font actual ${textfont} -size ]

    frame .conf.top
    frame .conf.top.partselect -background ${midcolor} -relief sunken -borderwidth 1
      button .conf.top.partselect.1 -text [::msgcat::mc {Country}] -anchor w -background ${midcolor} -relief flat -padx 3 -pady 3 -highlightthickness 0 -command {
        .conf.top.partselect.1 configure -background ${selectbackground} -foreground ${selectforeground} -relief groove
        .conf.top.partselect.2 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.3 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.4 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.5 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        destroy .conf.top.parts.frame
        frame .conf.top.parts.frame
          label .conf.top.parts.frame.nls_description -text "[::msgcat::mc {Language}] " -font ${titlefont}
          frame .conf.top.parts.frame.nls
            radiobutton .conf.top.parts.frame.nls.6 -text [::msgcat::mc {czech}] -variable nls -value cs
            grid .conf.top.parts.frame.nls.6 -sticky w
            radiobutton .conf.top.parts.frame.nls.1 -text [::msgcat::mc {english}] -variable nls -value en
            grid .conf.top.parts.frame.nls.1 -sticky w
            radiobutton .conf.top.parts.frame.nls.2 -text [::msgcat::mc {french}] -variable nls -value fr
            grid .conf.top.parts.frame.nls.2 -sticky w
            radiobutton .conf.top.parts.frame.nls.3 -text [::msgcat::mc {german}] -variable nls -value de
            grid .conf.top.parts.frame.nls.3 -sticky w
            radiobutton .conf.top.parts.frame.nls.4 -text "[::msgcat::mc {italian}] (principalmente incompleto)" -variable nls -value it
            grid .conf.top.parts.frame.nls.4 -sticky w
            radiobutton .conf.top.parts.frame.nls.5 -text "[::msgcat::mc {spanish}] (sobre todo incompleto)" -variable nls -value es
            grid .conf.top.parts.frame.nls.5 -sticky w
          grid .conf.top.parts.frame.nls_description .conf.top.parts.frame.nls -sticky nw
          frame .conf.top.parts.frame.blank01 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank01 -columnspan 2
          # currency
          if { ! [ info exists currency2 ] } {
            if { ${currency} != "euro" } {
              set currency2 ${currency}
            } else {
              set currency2 {$}
            }
          }
          if { ${currency2} == {} } { set currency2 {$} }
          label         .conf.top.parts.frame.currency_description -text "[::msgcat::mc {Currency}] " -font ${titlefont}
          frame         .conf.top.parts.frame.currency_selection
            radiobutton .conf.top.parts.frame.currency_selection.1 -text "\u20ac" -variable currency -value euro -command {
              .conf.top.parts.frame.currency_selection.3 configure -state disable
            }
            radiobutton .conf.top.parts.frame.currency_selection.2 -text {} -variable currency -command {
              .conf.top.parts.frame.currency_selection.3 configure -state normal
            }
            entry       .conf.top.parts.frame.currency_selection.3 -textvariable currency2 -width 10 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            ::conmen    .conf.top.parts.frame.currency_selection.3
          pack          .conf.top.parts.frame.currency_selection.1 .conf.top.parts.frame.currency_selection.2 .conf.top.parts.frame.currency_selection.3 -side left
          grid          .conf.top.parts.frame.currency_description .conf.top.parts.frame.currency_selection -sticky w
          if { ${currency} == {euro} } {
            .conf.top.parts.frame.currency_selection.3 configure -state disable
          } else {
            .conf.top.parts.frame.currency_selection.3 configure -state normal
            .conf.top.parts.frame.currency_selection.2 invoke
          }
          frame .conf.top.parts.frame.blank02 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank02 -columnspan 2
          # date format
          label .conf.top.parts.frame.dateformat_description -text "[::msgcat::mc {Date Format}] " -font ${titlefont}
          frame .conf.top.parts.frame.dateformat_checkbox
            radiobutton .conf.top.parts.frame.dateformat_checkbox.1 -text {31.12.2000} -variable dateformat -value dm
            radiobutton .conf.top.parts.frame.dateformat_checkbox.2 -text {12/31/2000} -variable dateformat -value md
          pack  .conf.top.parts.frame.dateformat_checkbox.1 .conf.top.parts.frame.dateformat_checkbox.2 -side left
          grid  .conf.top.parts.frame.dateformat_description .conf.top.parts.frame.dateformat_checkbox -sticky nw
          frame .conf.top.parts.frame.blank021 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank021 -columnspan 2
          # temperature format
          label .conf.top.parts.frame.temperatureformat_description -text "[::msgcat::mc {Temperature}] " -font ${titlefont}
          frame .conf.top.parts.frame.temperatureformat_checkbox
            radiobutton .conf.top.parts.frame.temperatureformat_checkbox.1 -text {Celsius} -variable tempscale -value celsius
            radiobutton .conf.top.parts.frame.temperatureformat_checkbox.2 -text {Fahrenheit} -variable tempscale -value fahrenheit
          pack  .conf.top.parts.frame.temperatureformat_checkbox.1 .conf.top.parts.frame.temperatureformat_checkbox.2 -side left
          grid  .conf.top.parts.frame.temperatureformat_description .conf.top.parts.frame.temperatureformat_checkbox -sticky nw
        pack .conf.top.parts.frame -fill both -expand true
        .conf.top.parts configure -text [ .conf.top.partselect.1 cget -text ]
        grid columnconfigure .conf.top.parts.frame 1 -weight 1
        frame .conf.top.parts.frame.fill
        grid .conf.top.parts.frame.fill -sticky news -columnspan 2
        grid rowconfigure .conf.top.parts.frame 6 -weight 1
      }
      button .conf.top.partselect.2 -text [::msgcat::mc {Look & Feel}] -anchor w -background ${midcolor} -relief flat -padx 3 -pady 3 -highlightthickness 0 -command {
        .conf.top.partselect.1 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.2 configure -background ${selectbackground} -foreground ${selectforeground} -relief groove
        .conf.top.partselect.3 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.4 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.5 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        destroy .conf.top.parts.frame
        frame .conf.top.parts.frame
          label .conf.top.parts.frame.windowplacement_description -text "[::msgcat::mc {Window Placement}] " -font ${titlefont}
          frame .conf.top.parts.frame.windowplacement_selection
            radiobutton .conf.top.parts.frame.windowplacement_selection.1 -text [::msgcat::mc {by operating system}] -variable windowplacement -value system -command {
              .conf.top.parts.frame.ulcx_description configure -state disabled
              .conf.top.parts.frame.ulcx_selection.1 configure -state disabled
              .conf.top.parts.frame.ulcx_selection.2 configure -state disabled
              .conf.top.parts.frame.ulcx_selection.3 configure -state disabled
              .conf.top.parts.frame.ulcy_description configure -state disabled
              .conf.top.parts.frame.ulcy_selection.1 configure -state disabled
              .conf.top.parts.frame.ulcy_selection.2 configure -state disabled
              .conf.top.parts.frame.ulcy_selection.3 configure -state disabled
            }
            grid .conf.top.parts.frame.windowplacement_selection.1 -sticky w
            radiobutton .conf.top.parts.frame.windowplacement_selection.4 -text [::msgcat::mc {maximized (may not work!)}] -variable windowplacement -value maximized -command {
              .conf.top.parts.frame.ulcx_description configure -state disabled
              .conf.top.parts.frame.ulcx_selection.1 configure -state disabled
              .conf.top.parts.frame.ulcx_selection.2 configure -state disabled
              .conf.top.parts.frame.ulcx_selection.3 configure -state disabled
              .conf.top.parts.frame.ulcy_description configure -state disabled
              .conf.top.parts.frame.ulcy_selection.1 configure -state disabled
              .conf.top.parts.frame.ulcy_selection.2 configure -state disabled
              .conf.top.parts.frame.ulcy_selection.3 configure -state disabled
            }
            if { [ info tclversion ] < {8.5} } {
              if { ${windowplacement} == {maximized} } { set windowplacement {system} }
              .conf.top.parts.frame.windowplacement_selection.4 configure -state disabled
            }
            grid .conf.top.parts.frame.windowplacement_selection.4 -sticky w
            radiobutton .conf.top.parts.frame.windowplacement_selection.3 -text [::msgcat::mc {fullscreen}] -variable windowplacement -value fullscreen -command {
              .conf.top.parts.frame.ulcx_description configure -state disabled
              .conf.top.parts.frame.ulcx_selection.1 configure -state disabled
              .conf.top.parts.frame.ulcx_selection.2 configure -state disabled
              .conf.top.parts.frame.ulcx_selection.3 configure -state disabled
              .conf.top.parts.frame.ulcy_description configure -state disabled
              .conf.top.parts.frame.ulcy_selection.1 configure -state disabled
              .conf.top.parts.frame.ulcy_selection.2 configure -state disabled
              .conf.top.parts.frame.ulcy_selection.3 configure -state disabled
              set infotitle [::msgcat::mc {Warning - Fullscreen}]
              set infotext "[::msgcat::mc {Recommended only for experienced users!}]\n\n[::msgcat::mc {Check first that all buttons fit to desktop size -}]\n[::msgcat::mc {otherwise they could be out of reach ...}]\n\n[::msgcat::mc {Therefore you should be able to handle your}]\n[::msgcat::mc {desktop with the keyboard!}]"
              set infotype {info}
              source [ file join ${prog_dir} tcl info.tcl ]
              raise .conf .
            }
            grid .conf.top.parts.frame.windowplacement_selection.3 -sticky w
            radiobutton .conf.top.parts.frame.windowplacement_selection.2 -text [::msgcat::mc {usersettings:}] -variable windowplacement -value user -command {
              .conf.top.parts.frame.ulcx_description configure -state normal
              if { ${centerx} == {false} } {
                .conf.top.parts.frame.ulcx_selection.1 configure -state normal
                .conf.top.parts.frame.ulcx_selection.2 configure -state normal
              }
              .conf.top.parts.frame.ulcx_selection.3 configure -state normal
              .conf.top.parts.frame.ulcy_description configure -state normal
              if { ${centery} == {false} } {
                .conf.top.parts.frame.ulcy_selection.1 configure -state normal
                .conf.top.parts.frame.ulcy_selection.2 configure -state normal
              }
              .conf.top.parts.frame.ulcy_selection.3 configure -state normal
            }
            grid .conf.top.parts.frame.windowplacement_selection.2 -sticky w
          grid .conf.top.parts.frame.windowplacement_description .conf.top.parts.frame.windowplacement_selection -sticky nw
          # ulcx - from 0 to 999
          label .conf.top.parts.frame.ulcx_description -text { } -font ${titlefont}
          frame .conf.top.parts.frame.ulcx_selection
            spinbox .conf.top.parts.frame.ulcx_selection.1 -textvariable ulcx -from 0 -to 999 -width 4 -background ${lightcolor} -justify right
                    .conf.top.parts.frame.ulcx_selection.1 set ${ulcx}
            label   .conf.top.parts.frame.ulcx_selection.2 -text [::msgcat::mc {pixel from east}] -width 16 -anchor w
            checkbutton .conf.top.parts.frame.ulcx_selection.3 -text [::msgcat::mc {middle}] -variable centerx -offvalue "false" -onvalue "true" -command {
              if { ${centerx} == {false} } {
                .conf.top.parts.frame.ulcx_selection.1 configure -state normal
                .conf.top.parts.frame.ulcx_selection.2 configure -state normal
              } else {
                .conf.top.parts.frame.ulcx_selection.1 configure -state disabled
                .conf.top.parts.frame.ulcx_selection.2 configure -state disabled
              }
            }
          pack .conf.top.parts.frame.ulcx_selection.1 .conf.top.parts.frame.ulcx_selection.2 .conf.top.parts.frame.ulcx_selection.3 -side left
          grid .conf.top.parts.frame.ulcx_description .conf.top.parts.frame.ulcx_selection -sticky w
          if { ${centerx} == {true} } {
            .conf.top.parts.frame.ulcx_selection.1 configure -state disabled
            .conf.top.parts.frame.ulcx_selection.2 configure -state disabled
          }
          # ulcy - from 0 to 999
          label .conf.top.parts.frame.ulcy_description -text { } -font ${titlefont}
          frame .conf.top.parts.frame.ulcy_selection
            spinbox .conf.top.parts.frame.ulcy_selection.1 -textvariable ulcy -from 0 -to 999 -width 4 -background ${lightcolor} -justify right
                    .conf.top.parts.frame.ulcy_selection.1 set ${ulcy}
            label   .conf.top.parts.frame.ulcy_selection.2 -text [::msgcat::mc {pixel from north}] -width 16 -anchor w
            checkbutton .conf.top.parts.frame.ulcy_selection.3 -text [::msgcat::mc {equator}] -variable centery -offvalue "false" -onvalue "true" -command {
              if { ${centery} == {false} } {
                .conf.top.parts.frame.ulcy_selection.1 configure -state normal
                .conf.top.parts.frame.ulcy_selection.2 configure -state normal
              } else {
                .conf.top.parts.frame.ulcy_selection.1 configure -state disabled
                .conf.top.parts.frame.ulcy_selection.2 configure -state disabled
              }
            }
          pack .conf.top.parts.frame.ulcy_selection.1 .conf.top.parts.frame.ulcy_selection.2 .conf.top.parts.frame.ulcy_selection.3 -side left
          grid .conf.top.parts.frame.ulcy_description .conf.top.parts.frame.ulcy_selection -sticky w
          if { ${centery} == {true} } {
            .conf.top.parts.frame.ulcy_selection.1 configure -state disabled
            .conf.top.parts.frame.ulcy_selection.2 configure -state disabled
          }
          if { ${windowplacement} != {user} } {
            .conf.top.parts.frame.ulcx_description configure -state disabled
            .conf.top.parts.frame.ulcx_selection.1 configure -state disabled
            .conf.top.parts.frame.ulcx_selection.2 configure -state disabled
            .conf.top.parts.frame.ulcx_selection.3 configure -state disabled
            .conf.top.parts.frame.ulcy_description configure -state disabled
            .conf.top.parts.frame.ulcy_selection.1 configure -state disabled
            .conf.top.parts.frame.ulcy_selection.2 configure -state disabled
            .conf.top.parts.frame.ulcy_selection.3 configure -state disabled
          }
          frame .conf.top.parts.frame.blank03 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank03 -columnspan 2
          # fontfamily for text and title - times, helvetica or courier
          label         .conf.top.parts.frame.fontfamily_description -text "[::msgcat::mc {Font}] " -font ${titlefont}
          frame         .conf.top.parts.frame.fontfamily_selection
          listbox .conf.top.parts.frame.fontfamily_selection.list -width 25 -height 6 -selectmode single -background ${lightcolor} -exportselection false -activestyle none -highlightthickness 0 -yscrollcommand {.conf.top.parts.frame.fontfamily_selection.scroll set}
					if { ${bTtk} } {
          	ttk::scrollbar .conf.top.parts.frame.fontfamily_selection.scroll -command {.conf.top.parts.frame.fontfamily_selection.list yview} -orient vertical
					} else {
						scrollbar .conf.top.parts.frame.fontfamily_selection.scroll -command {.conf.top.parts.frame.fontfamily_selection.list yview} -orient vertical
					}
          frame .conf.top.parts.frame.fontfamily_selection.space -width 8
					if { ${bTtk} } {
          	ttk::labelframe .conf.top.parts.frame.fontfamily_selection.example -text [::msgcat::mc {Selection}]
					} else {
						labelframe .conf.top.parts.frame.fontfamily_selection.example -text [::msgcat::mc {Selection}] -padx 2 -pady 2
					}
            # as list is uppercase, show now and search later for a corresponding one
            set fontfamily2 "[ string toupper [ string index ${fontfamily} 0 ] ][ string range ${fontfamily} 1 end ]"
            label .conf.top.parts.frame.fontfamily_selection.example.fontname1 -text ${fontfamily2} -font ${titlefont} -anchor s
            label .conf.top.parts.frame.fontfamily_selection.example.fontname2 -text ${fontfamily2}
            label .conf.top.parts.frame.fontfamily_selection.example.fontname3 -text ${fontfamily2} -font ${smallfont} -anchor n
          pack .conf.top.parts.frame.fontfamily_selection.example.fontname1 -side top -fill both -expand true
          pack .conf.top.parts.frame.fontfamily_selection.example.fontname2 -side top -fill x
          pack .conf.top.parts.frame.fontfamily_selection.example.fontname3 -side top -fill both -expand true
          pack .conf.top.parts.frame.fontfamily_selection.list    -side left -fill both
          pack .conf.top.parts.frame.fontfamily_selection.scroll  -side left -fill y
          pack .conf.top.parts.frame.fontfamily_selection.space   -side left
          pack .conf.top.parts.frame.fontfamily_selection.example -side left -fill both -expand true
          set fontlist [ font families ]
          lappend fontlist Helvetica Courier Times
          set fontlist2 {}
          set markline {-1}
          foreach entry ${fontlist} {
            if { ${entry} != {} } { lappend fontlist2 "[ string toupper [ string index ${entry} 0 ] ][ string range ${entry} 1 end ]" }
          }
          set fontlist2 [ lsort -unique ${fontlist2} ]
          foreach entry ${fontlist2} {
            if { ${entry} != {} } {
              set entry "[ string toupper [ string index ${entry} 0 ] ][ string range ${entry} 1 end ]"
              .conf.top.parts.frame.fontfamily_selection.list insert end ${entry}
              if { ${entry} == ${fontfamily2} } { set markline [ expr "[ .conf.top.parts.frame.fontfamily_selection.list size ] -1" ] }
            }
          }
          # use and mark Helvetica if font not found
          if { ${markline} == {-1} } { set markline [ lsearch -exact ${fontlist2} Helvetica ] }
          .conf.top.parts.frame.fontfamily_selection.list selection clear 0 end
          .conf.top.parts.frame.fontfamily_selection.list selection set ${markline}
          .conf.top.parts.frame.fontfamily_selection.list activate ${markline}
          .conf.top.parts.frame.fontfamily_selection.list see ${markline}
          bind .conf.top.parts.frame.fontfamily_selection.list <Enter> { focus %W }
          bind .conf.top.parts.frame.fontfamily_selection.list <ButtonRelease-1> {
            set fontfamily [ %W get [ %W curselection ] ]
            set selecttitlefont "-family \"${fontfamily}\" -size ${fontsize} -weight bold"
            set selecttextfont  "-family \"${fontfamily}\" -size ${fontsize} -weight normal"
            set selectsmallfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal"
            .conf.top.parts.frame.fontfamily_selection.example.fontname1 configure -text ${fontfamily} -font ${selecttitlefont}
            .conf.top.parts.frame.fontfamily_selection.example.fontname2 configure -text ${fontfamily} -font ${selecttextfont}
            .conf.top.parts.frame.fontfamily_selection.example.fontname3 configure -text ${fontfamily} -font ${selectsmallfont}
          }
          bind .conf.top.parts.frame.fontfamily_selection.list <Key-Down> {
            update
            set positionsline [ expr "[ %W curselection ] + 1" ]
            if { ${positionsline} < [ %W size ] } {
              %W selection clear 0 end
              %W selection set ${positionsline}
              %W activate ${positionsline}
              %W see ${positionsline}
              set fontfamily [ %W get ${positionsline} ]
              set selecttitlefont "-family \"${fontfamily}\" -size ${fontsize} -weight bold"
              set selecttextfont  "-family \"${fontfamily}\" -size ${fontsize} -weight normal"
              set selectsmallfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal"
              .conf.top.parts.frame.fontfamily_selection.example.fontname1 configure -text ${fontfamily} -font ${selecttitlefont}
              .conf.top.parts.frame.fontfamily_selection.example.fontname2 configure -text ${fontfamily} -font ${selecttextfont}
              .conf.top.parts.frame.fontfamily_selection.example.fontname3 configure -text ${fontfamily} -font ${selectsmallfont}
            }
          }
          bind .conf.top.parts.frame.fontfamily_selection.list <Key-Up> {
            update
            set positionsline [ expr "[ %W curselection ] - 1" ]
              if { ${positionsline} >= {0} } {
              %W selection clear 0 end
              %W selection set ${positionsline}
              %W activate ${positionsline}
              %W see ${positionsline}
              set fontfamily [ %W get ${positionsline} ]
              set selecttitlefont "-family \"${fontfamily}\" -size ${fontsize} -weight bold"
              set selecttextfont  "-family \"${fontfamily}\" -size ${fontsize} -weight normal"
              set selectsmallfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal"
              .conf.top.parts.frame.fontfamily_selection.example.fontname1 configure -text ${fontfamily} -font ${selecttitlefont}
              .conf.top.parts.frame.fontfamily_selection.example.fontname2 configure -text ${fontfamily} -font ${selecttextfont}
              .conf.top.parts.frame.fontfamily_selection.example.fontname3 configure -text ${fontfamily} -font ${selectsmallfont}
            }
          }
          bind .conf.top.parts.frame.fontfamily_selection.list <Next> {
            update
            set positionsline [ expr "[ %W curselection ] + 10" ]
            if { ${positionsline} >= [ %W size ] } { set positionsline [ expr "[ %W size ] - 1" ] }
            if { ${positionsline} < [ %W size ] } {
              %W selection clear 0 end
              %W selection set ${positionsline}
              %W activate ${positionsline}
              %W see ${positionsline}
              set fontfamily [ %W get ${positionsline} ]
              set selecttitlefont "-family \"${fontfamily}\" -size ${fontsize} -weight bold"
              set selecttextfont  "-family \"${fontfamily}\" -size ${fontsize} -weight normal"
              set selectsmallfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal"
              .conf.top.parts.frame.fontfamily_selection.example.fontname1 configure -text ${fontfamily} -font ${selecttitlefont}
              .conf.top.parts.frame.fontfamily_selection.example.fontname2 configure -text ${fontfamily} -font ${selecttextfont}
              .conf.top.parts.frame.fontfamily_selection.example.fontname3 configure -text ${fontfamily} -font ${selectsmallfont}
            }
          }
          bind .conf.top.parts.frame.fontfamily_selection.list <Prior> {
            update
            set positionsline [ expr "[ %W curselection ] - 10" ]
            if { ${positionsline} < {0} } { set positionsline 0 }
            if { ${positionsline} >= {0} } {
              %W selection clear 0 end
              %W selection set ${positionsline}
              %W activate ${positionsline}
              %W see ${positionsline}
              set fontfamily [ %W get ${positionsline} ]
              set selecttitlefont "-family \"${fontfamily}\" -size ${fontsize} -weight bold"
              set selecttextfont  "-family \"${fontfamily}\" -size ${fontsize} -weight normal"
              set selectsmallfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal"
              .conf.top.parts.frame.fontfamily_selection.example.fontname1 configure -text ${fontfamily} -font ${selecttitlefont}
              .conf.top.parts.frame.fontfamily_selection.example.fontname2 configure -text ${fontfamily} -font ${selecttextfont}
              .conf.top.parts.frame.fontfamily_selection.example.fontname3 configure -text ${fontfamily} -font ${selectsmallfont}
            }
          }
          bind .conf.top.parts.frame.fontfamily_selection.list <Key-Home> {
            update
            %W selection clear 0 end
            %W selection set 0
            %W activate 0
            %W see 0
            set fontfamily [ %W get 0 ]
            set selecttitlefont "-family \"${fontfamily}\" -size ${fontsize} -weight bold"
            set selecttextfont  "-family \"${fontfamily}\" -size ${fontsize} -weight normal"
            set selectsmallfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal"
            .conf.top.parts.frame.fontfamily_selection.example.fontname1 configure -text ${fontfamily} -font ${selecttitlefont}
            .conf.top.parts.frame.fontfamily_selection.example.fontname2 configure -text ${fontfamily} -font ${selecttextfont}
            .conf.top.parts.frame.fontfamily_selection.example.fontname3 configure -text ${fontfamily} -font ${selectsmallfont}
          }
          bind .conf.top.parts.frame.fontfamily_selection.list <Key-End> {
            update
            %W selection clear 0 end
            %W selection set end
            %W activate end
            %W see end
            set fontfamily [ %W get end ]
            set selecttitlefont "-family \"${fontfamily}\" -size ${fontsize} -weight bold"
            set selecttextfont  "-family \"${fontfamily}\" -size ${fontsize} -weight normal"
            set selectsmallfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal"
            .conf.top.parts.frame.fontfamily_selection.example.fontname1 configure -text ${fontfamily} -font ${selecttitlefont}
            .conf.top.parts.frame.fontfamily_selection.example.fontname2 configure -text ${fontfamily} -font ${selecttextfont}
            .conf.top.parts.frame.fontfamily_selection.example.fontname3 configure -text ${fontfamily} -font ${selectsmallfont}
          }
          grid .conf.top.parts.frame.fontfamily_description .conf.top.parts.frame.fontfamily_selection
          grid configure .conf.top.parts.frame.fontfamily_description -sticky nw
          grid configure .conf.top.parts.frame.fontfamily_selection   -sticky nwe
          # fontsize - from 4 to 24
          label .conf.top.parts.frame.fontsize_description -font ${titlefont}
          frame .conf.top.parts.frame.fontsize_selection
            label   .conf.top.parts.frame.fontsize_selection.0 -text "[::msgcat::mc {Size:}] "
            spinbox .conf.top.parts.frame.fontsize_selection.1 -textvariable fontsize -from 4 -to 24 -width 3 -background ${lightcolor} -justify right -command {
              set selecttitlefont "-family \"${fontfamily}\" -size ${fontsize} -weight bold"
              set selecttextfont  "-family \"${fontfamily}\" -size ${fontsize} -weight normal"
              set selectsmallfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal"
              .conf.top.parts.frame.fontfamily_selection.example.fontname1 configure -text ${fontfamily} -font ${selecttitlefont}
              .conf.top.parts.frame.fontfamily_selection.example.fontname2 configure -text ${fontfamily} -font ${selecttextfont}
              .conf.top.parts.frame.fontfamily_selection.example.fontname3 configure -text ${fontfamily} -font ${selectsmallfont}
            }
                    .conf.top.parts.frame.fontsize_selection.1 set $fontsize
            label   .conf.top.parts.frame.fontsize_selection.2 -text [::msgcat::mc {Note: affect window sizes}]
          pack .conf.top.parts.frame.fontsize_selection.0 .conf.top.parts.frame.fontsize_selection.1 .conf.top.parts.frame.fontsize_selection.2 -side left
          grid    .conf.top.parts.frame.fontsize_description .conf.top.parts.frame.fontsize_selection -sticky w
          frame .conf.top.parts.frame.blank04 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank04 -columnspan 2
          # colors
          label .conf.top.parts.frame.color_description -text "[::msgcat::mc {Window Colors}] " -font ${titlefont}
          frame .conf.top.parts.frame.color_button
            radiobutton .conf.top.parts.frame.color_button.1 -text "[::msgcat::mc {calculate scheme:}] " -variable onecolor -value true -command {
              .conf.top.parts.frame.color_button.2.1 configure -state normal
              .conf.top.parts.frame.color_button.2.2 configure -state normal
              .conf.top.parts.frame.color_button.4   configure -state disabled
              source [ file join ${prog_dir} tcl color.tcl ]
              .conf.top.parts.frame.ulcx_selection.1     configure -background ${lightcolor}
              .conf.top.parts.frame.ulcy_selection.1     configure -background ${lightcolor}
              .conf.top.parts.frame.fontsize_selection.1 configure -background ${lightcolor}
              .conf.top.partselect   configure -background ${midcolor}
              .conf.top.partselect.1 configure -background ${midcolor}         -foreground ${textcolor}
              .conf.top.partselect.2 configure -background ${selectbackground} -foreground ${selectforeground}
              .conf.top.partselect.3 configure -background ${midcolor}         -foreground ${textcolor}
              .conf.top.partselect.4 configure -background ${midcolor}         -foreground ${textcolor}
              .conf.top.partselect.5 configure -background ${midcolor}         -foreground ${textcolor}
              .conf.top.parts.frame.fontfamily_selection.list configure -background ${lightcolor} -foreground ${textcolor}
              .winelist.text                  configure -labelbackground ${background} -labelforeground ${textcolor} -stripebg ${midcolor} -background ${lightcolor}
            }
            frame .conf.top.parts.frame.color_button.2
              button .conf.top.parts.frame.color_button.2.1 -text $basecolor -relief raised -padx 2 -pady 2 -command {
                set basecolor2 [ tk_chooseColor -initialcolor $basecolor -title [::msgcat::mc {configure: colors}] ]
                if { $basecolor2 != {} } {
                  set basecolor $basecolor2
                  .conf.top.parts.frame.color_button.2.1 configure -text $basecolor
                  source [ file join ${prog_dir} tcl color.tcl ]
                  .conf.top.parts.frame.ulcx_selection.1     configure -background ${lightcolor}
                  .conf.top.parts.frame.ulcy_selection.1     configure -background ${lightcolor}
                  .conf.top.parts.frame.fontsize_selection.1 configure -background ${lightcolor}
                  .conf.top.partselect   configure -background ${midcolor}
                  .conf.top.partselect.1 configure -background ${midcolor}         -foreground ${textcolor}
                  .conf.top.partselect.2 configure -background ${selectbackground} -foreground ${selectforeground}
                  .conf.top.partselect.3 configure -background ${midcolor}         -foreground ${textcolor}
                  .conf.top.partselect.4 configure -background ${midcolor}         -foreground ${textcolor}
                  .conf.top.partselect.5 configure -background ${midcolor}         -foreground ${textcolor}
                  .conf.top.parts.frame.fontfamily_selection.list configure -background ${lightcolor} -foreground ${textcolor}
                  .winelist.text                  configure -labelbackground ${background} -labelforeground ${textcolor} -stripebg ${midcolor} -background ${lightcolor}
                }
              }
              button .conf.top.parts.frame.color_button.2.2 -text [::msgcat::mc {default}] -relief raised -padx 2 -pady 2 -command {
                set basecolor {#dddddd}
                .conf.top.parts.frame.color_button.2.1 configure -text $basecolor
                source [ file join ${prog_dir} tcl color.tcl ]
                .conf.top.parts.frame.ulcx_selection.1     configure -background ${lightcolor}
                .conf.top.parts.frame.ulcy_selection.1     configure -background ${lightcolor}
                .conf.top.parts.frame.fontsize_selection.1 configure -background ${lightcolor}
                .conf.top.partselect   configure -background ${midcolor}
                .conf.top.partselect.1 configure -background ${midcolor}         -foreground ${textcolor}
                .conf.top.partselect.2 configure -background ${selectbackground} -foreground ${selectforeground}
                .conf.top.partselect.3 configure -background ${midcolor}         -foreground ${textcolor}
                .conf.top.partselect.4 configure -background ${midcolor}         -foreground ${textcolor}
                .conf.top.partselect.5 configure -background ${midcolor}         -foreground ${textcolor}
                .conf.top.parts.frame.fontfamily_selection.list configure -background ${lightcolor} -foreground ${textcolor}
                .winelist.text                  configure -labelbackground ${background} -labelforeground ${textcolor} -stripebg ${midcolor} -background ${lightcolor}
              }
            pack .conf.top.parts.frame.color_button.2.1 .conf.top.parts.frame.color_button.2.2 -side left
            grid .conf.top.parts.frame.color_button.1 .conf.top.parts.frame.color_button.2 -sticky w
            radiobutton .conf.top.parts.frame.color_button.3 -text "[::msgcat::mc {use color theme:}] " -variable onecolor -value false -command {
              .conf.top.parts.frame.color_button.2.1 configure -state disabled
              .conf.top.parts.frame.color_button.2.2 configure -state disabled
              .conf.top.parts.frame.color_button.4   configure -state normal
              source [ file join ${prog_dir} tcl color.tcl ]
              .conf.top.parts.frame.ulcx_selection.1     configure -background ${lightcolor}
              .conf.top.parts.frame.ulcy_selection.1     configure -background ${lightcolor}
              .conf.top.parts.frame.fontsize_selection.1 configure -background ${lightcolor}
              .conf.top.partselect   configure -background ${midcolor}
              .conf.top.partselect.1 configure -background ${midcolor}         -foreground ${textcolor}
              .conf.top.partselect.2 configure -background ${selectbackground} -foreground ${selectforeground}
              .conf.top.partselect.3 configure -background ${midcolor}         -foreground ${textcolor}
              .conf.top.partselect.4 configure -background ${midcolor}         -foreground ${textcolor}
              .conf.top.partselect.5 configure -background ${midcolor}         -foreground ${textcolor}
              .conf.top.parts.frame.fontfamily_selection.list configure -background ${lightcolor} -foreground ${textcolor}
              .winelist.text configure -labelbackground ${background} -labelforeground ${textcolor} -stripebg ${midcolor} -background ${lightcolor}
            }
            set colorthemelist {}
            foreach colorthemefile [ glob -nocomplain [ file join ${prog_dir} rgb * ] ] {
              lappend colorthemelist [ file tail ${colorthemefile} ]
            }
            set colorthemelist [ lsort ${colorthemelist} ]
            set optionmenu [ tk_optionMenu .conf.top.parts.frame.color_button.4 colortheme blafasel ]
            ${optionmenu} delete 0
            set length_colorthemelist [ llength ${colorthemelist} ]
            for { set index_colorthemelist 0 } { ${index_colorthemelist} < ${length_colorthemelist} } { incr index_colorthemelist } {
              ${optionmenu} insert ${index_colorthemelist} radiobutton -label [ lindex ${colorthemelist} ${index_colorthemelist} ] -variable colorthemevar -command { global colorthemevar; set colortheme ${colorthemevar} }
            }
            .conf.top.parts.frame.color_button.4 configure -padx 2 -pady 2
          grid .conf.top.parts.frame.color_button.3 .conf.top.parts.frame.color_button.4 -sticky w
          label .conf.top.parts.frame.color_button.5 -text [::msgcat::mc {Note: changes complete visible after saving}]
          grid .conf.top.parts.frame.color_button.5 -sticky w -columnspan 2
          grid .conf.top.parts.frame.color_description .conf.top.parts.frame.color_button -sticky nw
          if { ${onecolor} == {true} } {
            .conf.top.parts.frame.color_button.4   configure -state disabled
          } else {
            .conf.top.parts.frame.color_button.2.1 configure -state disabled
            .conf.top.parts.frame.color_button.2.2 configure -state disabled
          }
          frame .conf.top.parts.frame.blank05 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank05 -columnspan 2
          label .conf.top.parts.frame.tooltips_description -text "[::msgcat::mc {Tooltips}] " -font ${titlefont}
          checkbutton .conf.top.parts.frame.tooltips_checkbutton -text [::msgcat::mc {show tooltips}] -variable tooltips -onvalue true -offvalue false
          grid  .conf.top.parts.frame.tooltips_description .conf.top.parts.frame.tooltips_checkbutton -sticky w
        pack .conf.top.parts.frame -fill both -expand true
        .conf.top.parts configure -text [ .conf.top.partselect.2 cget -text ]
        grid columnconfigure .conf.top.parts.frame 1 -weight 1
        frame .conf.top.parts.frame.fill
        grid .conf.top.parts.frame.fill -sticky news -columnspan 2
        grid rowconfigure .conf.top.parts.frame 10 -weight 1
      }
      button .conf.top.partselect.3 -text [::msgcat::mc {General}] -anchor w -background ${midcolor} -relief flat  -padx 3 -pady 3 -highlightthickness 0 -command {
        .conf.top.partselect.1 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.2 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.3 configure -background ${selectbackground} -foreground ${selectforeground} -relief groove
        .conf.top.partselect.4 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.5 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        destroy .conf.top.parts.frame
        frame .conf.top.parts.frame
          label .conf.top.parts.frame.browser_description -text "[::msgcat::mc {Webbrowser}] " -font ${titlefont}
          frame .conf.top.parts.frame.browser_frame
            entry    .conf.top.parts.frame.browser_frame.entry -textvariable webbrowser -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            ::conmen .conf.top.parts.frame.browser_frame.entry
            .conf.top.parts.frame.browser_frame.entry.conmen add separator
            .conf.top.parts.frame.browser_frame.entry.conmen add command -label [::msgcat::mc {Choose}] -command { .conf.top.parts.frame.browser_frame.button invoke }
            button   .conf.top.parts.frame.browser_frame.button -text [::msgcat::mc {Choose}] -relief raised -padx 1 -pady 1 -command { set webbrowser [ tk_getOpenFile -initialdir ~ -parent .conf -title [::msgcat::mc {Webbrowser}] ] }
            pack     .conf.top.parts.frame.browser_frame.entry .conf.top.parts.frame.browser_frame.button -side left
          grid  .conf.top.parts.frame.browser_description .conf.top.parts.frame.browser_frame -sticky nw
          frame .conf.top.parts.frame.blank06 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank06 -columnspan 2
          label .conf.top.parts.frame.picopenpath_description -text "[::msgcat::mc {Picture Path}] " -font ${titlefont}
          frame .conf.top.parts.frame.picopenpath_frame
            entry    .conf.top.parts.frame.picopenpath_frame.entry -textvariable picopenpath -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            ::conmen .conf.top.parts.frame.picopenpath_frame.entry
            .conf.top.parts.frame.picopenpath_frame.entry.conmen add separator
            .conf.top.parts.frame.picopenpath_frame.entry.conmen add command -label [::msgcat::mc {Choose}] -command { .conf.top.parts.frame.picopenpath_frame.button invoke }
            button   .conf.top.parts.frame.picopenpath_frame.button -text [::msgcat::mc {Choose}] -relief raised -padx 1 -pady 1 -command { set picopenpath [ tk_chooseDirectory -initialdir ~ -parent .conf -title [::msgcat::mc {Picture Path}] ] }
            pack     .conf.top.parts.frame.picopenpath_frame.entry .conf.top.parts.frame.picopenpath_frame.button -side left
          grid  .conf.top.parts.frame.picopenpath_description .conf.top.parts.frame.picopenpath_frame -sticky nw

        pack .conf.top.parts.frame -fill both -expand true
        .conf.top.parts configure -text [ .conf.top.partselect.3 cget -text ]
        grid columnconfigure .conf.top.parts.frame 1 -weight 1
        frame .conf.top.parts.frame.fill
        grid .conf.top.parts.frame.fill -sticky news -columnspan 2
        grid rowconfigure .conf.top.parts.frame 2 -weight 1
      }
      button .conf.top.partselect.4 -text [::msgcat::mc {Main Window}] -anchor w -background ${midcolor} -relief flat -padx 3 -pady 3 -highlightthickness 0 -command {
        .conf.top.partselect.1 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.2 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.3 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.4 configure -background ${selectbackground} -foreground ${selectforeground} -relief groove
        .conf.top.partselect.5 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        destroy .conf.top.parts.frame
        frame .conf.top.parts.frame
          label .conf.top.parts.frame.country_description -text "[::msgcat::mc {Country Bar}] " -font ${titlefont}
          frame .conf.top.parts.frame.country_checkbox
            radiobutton .conf.top.parts.frame.country_checkbox.1 -text [::msgcat::mc {database}] -variable countrybuttons -value all       -command { .conf.top.parts.frame.country_update1 configure -state normal }
            radiobutton .conf.top.parts.frame.country_checkbox.2 -text [::msgcat::mc {available}] -variable countrybuttons -value available -command { .conf.top.parts.frame.country_update1 configure -state normal }
            radiobutton .conf.top.parts.frame.country_checkbox.3 -text [::msgcat::mc {known}] -variable countrybuttons -value known     -command { .conf.top.parts.frame.country_update1 configure -state disabled }
          pack  .conf.top.parts.frame.country_checkbox.1 .conf.top.parts.frame.country_checkbox.2 .conf.top.parts.frame.country_checkbox.3 -side left
          grid  .conf.top.parts.frame.country_description .conf.top.parts.frame.country_checkbox -sticky w
          label .conf.top.parts.frame.country_update0 -text {}
          checkbutton .conf.top.parts.frame.country_update1 -text [::msgcat::mc {update dynamically}] -variable cbupdate -offvalue "false" -onvalue "true"
          if { ${cbupdate} == {true} } {
            .conf.top.parts.frame.country_update1 select
          } else {
            .conf.top.parts.frame.country_update1 deselect
          }
          if { ${countrybuttons} == {known} } { .conf.top.parts.frame.country_update1 configure -state disabled }
          grid  .conf.top.parts.frame.country_update0 .conf.top.parts.frame.country_update1 -sticky w
          frame .conf.top.parts.frame.blank07 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank07 -columnspan 2
          # listlines
          label   .conf.top.parts.frame.lines_description -text "[::msgcat::mc {Winelist Rows}] " -font ${titlefont}
          spinbox .conf.top.parts.frame.lines_selection   -textvariable listlines -from 17 -to 99 -width 3 -background ${lightcolor} -justify right
                  .conf.top.parts.frame.lines_selection set ${listlines}
          grid    .conf.top.parts.frame.lines_description .conf.top.parts.frame.lines_selection -sticky w
          frame .conf.top.parts.frame.blank08 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank08 -columnspan 2
          # listlength : region_space, name_space and grapes_space
          label .conf.top.parts.frame.length_description -text "[::msgcat::mc {Winelist Widths}] " -font ${titlefont}
          frame .conf.top.parts.frame.length_boxes
            spinbox  .conf.top.parts.frame.length_boxes.box1 -textvariable region_space -from 1 -to 999 -width 3 -background ${lightcolor} -justify right
                     .conf.top.parts.frame.length_boxes.box1 set ${region_space}
            label    .conf.top.parts.frame.length_boxes.txt1 -text [::msgcat::mc "chars column \u00bbRegion\u00ab"]
            grid     .conf.top.parts.frame.length_boxes.box1 .conf.top.parts.frame.length_boxes.txt1 -sticky w
            spinbox  .conf.top.parts.frame.length_boxes.box2 -textvariable name_space -from 1 -to 999 -width 3 -background ${lightcolor} -justify right
                     .conf.top.parts.frame.length_boxes.box2 set ${name_space}
            label    .conf.top.parts.frame.length_boxes.txt2 -text [::msgcat::mc "chars column \u00bbName\u00ab"]
            grid     .conf.top.parts.frame.length_boxes.box2 .conf.top.parts.frame.length_boxes.txt2 -sticky w
            spinbox  .conf.top.parts.frame.length_boxes.box3 -textvariable grapes_space -from 1 -to 999 -width 3 -background ${lightcolor} -justify right
                     .conf.top.parts.frame.length_boxes.box3 set ${grapes_space}
            label    .conf.top.parts.frame.length_boxes.txt3 -text [::msgcat::mc "chars column \u00bbGrapes\u00ab"]
            grid     .conf.top.parts.frame.length_boxes.box3 .conf.top.parts.frame.length_boxes.txt3 -sticky w
          grid  .conf.top.parts.frame.length_description .conf.top.parts.frame.length_boxes -sticky nw
          frame .conf.top.parts.frame.blank09 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank09 -columnspan 2
          # show_only_code buttons
          label .conf.top.parts.frame.show_only_code_description -text "[::msgcat::mc {Winelist Countries}] " -font ${titlefont}
          frame .conf.top.parts.frame.show_only_code_checkbox
            radiobutton .conf.top.parts.frame.show_only_code_checkbox.1 -text [::msgcat::mc {macros (shorter)}] -variable show_only_code -value true
            radiobutton .conf.top.parts.frame.show_only_code_checkbox.2 -text [::msgcat::mc {full name}] -variable show_only_code -value false
          pack  .conf.top.parts.frame.show_only_code_checkbox.1 .conf.top.parts.frame.show_only_code_checkbox.2 -side left
          grid  .conf.top.parts.frame.show_only_code_description .conf.top.parts.frame.show_only_code_checkbox -sticky w
          frame .conf.top.parts.frame.blank10 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank10 -columnspan 2
          # list colors
          label .conf.top.parts.frame.colorname_description -text "[::msgcat::mc {Winelist Colornames}] " -font ${titlefont}
          frame .conf.top.parts.frame.colorname_checkbox
            frame .conf.top.parts.frame.colorname_checkbox.check
              radiobutton .conf.top.parts.frame.colorname_checkbox.check.1 -text [::msgcat::mc {as text}] -variable colorname -value false
              radiobutton .conf.top.parts.frame.colorname_checkbox.check.2 -text [::msgcat::mc {as color (slower)}] -variable colorname -value true
            pack  .conf.top.parts.frame.colorname_checkbox.check.1 .conf.top.parts.frame.colorname_checkbox.check.2 -side left -anchor w
            label .conf.top.parts.frame.colorname_checkbox.text -text [::msgcat::mc {Note: color requires unicode character 25CF}]
            pack .conf.top.parts.frame.colorname_checkbox.check .conf.top.parts.frame.colorname_checkbox.text -side top -anchor w
          grid  .conf.top.parts.frame.colorname_description .conf.top.parts.frame.colorname_checkbox -sticky nw

        pack .conf.top.parts.frame -fill both -expand true
        .conf.top.parts configure -text [ .conf.top.partselect.4 cget -text ]
        grid columnconfigure .conf.top.parts.frame 1 -weight 1
        frame .conf.top.parts.frame.fill
        grid .conf.top.parts.frame.fill -sticky news -columnspan 2
        grid rowconfigure .conf.top.parts.frame 9 -weight 1
      }
      button .conf.top.partselect.5 -text [::msgcat::mc {Wine Editor}] -anchor w -background ${midcolor} -relief flat -padx 3 -pady 3 -highlightthickness 0 -command {
        .conf.top.partselect.1 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.2 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.3 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.4 configure -background ${midcolor}         -foreground ${textcolor} -relief flat
        .conf.top.partselect.5 configure -background ${selectbackground} -foreground ${selectforeground} -relief groove
        destroy .conf.top.parts.frame
        frame .conf.top.parts.frame
          label         .conf.top.parts.frame.viewmode_description -text "[::msgcat::mc {Default Drink Frame}] " -font ${titlefont}
          frame         .conf.top.parts.frame.viewmode_selection
            radiobutton .conf.top.parts.frame.viewmode_selection.1 -text "1: [::msgcat::mc {button mode (entries will be evaluated in later versions)}]" -variable viewmode -value buttons
          grid          .conf.top.parts.frame.viewmode_selection.1 -sticky w
            radiobutton .conf.top.parts.frame.viewmode_selection.2 -text "2: [::msgcat::mc {usage mode}]" -variable viewmode -value usage
          grid          .conf.top.parts.frame.viewmode_selection.2 -sticky w
            radiobutton .conf.top.parts.frame.viewmode_selection.3 -text "3: [::msgcat::mc {text mode (text can not be evaluated)}]" -variable viewmode -value text
          grid          .conf.top.parts.frame.viewmode_selection.3 -sticky w
          grid          .conf.top.parts.frame.viewmode_description .conf.top.parts.frame.viewmode_selection -sticky nw
          frame .conf.top.parts.frame.blank11 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank11 -columnspan 2
          label         .conf.top.parts.frame.grapes_description -text "[::msgcat::mc {Grape Selection}] " -font ${titlefont}
          frame         .conf.top.parts.frame.grapes_selection
            checkbutton .conf.top.parts.frame.grapes_selection.1 -text [::msgcat::mc {take synonym into account}] -variable grape_add_syn -offvalue "false" -onvalue "true"
          grid          .conf.top.parts.frame.grapes_selection.1 -sticky w
            checkbutton .conf.top.parts.frame.grapes_selection.2 -text [::msgcat::mc {switch selection and addition}] -variable grape_add_switch -offvalue "false" -onvalue "true"
          grid          .conf.top.parts.frame.grapes_selection.2 -sticky w
            checkbutton .conf.top.parts.frame.grapes_selection.3 -text [::msgcat::mc {synonym only}] -variable grape_add_synonly -offvalue "false" -onvalue "true"
          grid          .conf.top.parts.frame.grapes_selection.3 -sticky w
            checkbutton .conf.top.parts.frame.grapes_selection.4 -text [::msgcat::mc {add a lab hybrid notice}] -variable grape_add_labnote -offvalue "false" -onvalue "true"
          grid          .conf.top.parts.frame.grapes_selection.4 -sticky w
            checkbutton .conf.top.parts.frame.grapes_selection.5 -text [::msgcat::mc {add the lab hybrid parents}] -variable grape_add_lab -offvalue "false" -onvalue "true"
          grid          .conf.top.parts.frame.grapes_selection.5 -sticky w
            checkbutton .conf.top.parts.frame.grapes_selection.6 -text [::msgcat::mc {add the natural parents}] -variable grape_add_nat -offvalue "false" -onvalue "true"
          grid          .conf.top.parts.frame.grapes_selection.6 -sticky w
            checkbutton .conf.top.parts.frame.grapes_selection.7 -text [::msgcat::mc {scan for related grape names}] -variable grape_add_scanrelated -offvalue "false" -onvalue "true"
          grid          .conf.top.parts.frame.grapes_selection.7 -sticky w
          grid          .conf.top.parts.frame.grapes_description .conf.top.parts.frame.grapes_selection -sticky nw
          frame .conf.top.parts.frame.blank12 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank12 -columnspan 2
          label .conf.top.parts.frame.wineglasses_description -text "[::msgcat::mc {Glasses Names}] " -font ${titlefont}
          frame .conf.top.parts.frame.wineglasses_frame
            label .conf.top.parts.frame.wineglasses_frame.glass1t -text "[::msgcat::mc {Glass #1}] "
            entry .conf.top.parts.frame.wineglasses_frame.glass1e -textvariable glassname01 -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            grid .conf.top.parts.frame.wineglasses_frame.glass1t .conf.top.parts.frame.wineglasses_frame.glass1e -sticky w
            label .conf.top.parts.frame.wineglasses_frame.glass2t -text "[::msgcat::mc {Glass #2}] "
            entry .conf.top.parts.frame.wineglasses_frame.glass2e -textvariable glassname02 -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            grid .conf.top.parts.frame.wineglasses_frame.glass2t .conf.top.parts.frame.wineglasses_frame.glass2e -sticky w
            label .conf.top.parts.frame.wineglasses_frame.glass3t -text "[::msgcat::mc {Glass #3}] "
            entry .conf.top.parts.frame.wineglasses_frame.glass3e -textvariable glassname03 -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            grid .conf.top.parts.frame.wineglasses_frame.glass3t .conf.top.parts.frame.wineglasses_frame.glass3e -sticky w
            label .conf.top.parts.frame.wineglasses_frame.glass4t -text "[::msgcat::mc {Glass #4}] "
            entry .conf.top.parts.frame.wineglasses_frame.glass4e -textvariable glassname04 -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            grid .conf.top.parts.frame.wineglasses_frame.glass4t .conf.top.parts.frame.wineglasses_frame.glass4e -sticky w
            label .conf.top.parts.frame.wineglasses_frame.glass5t -text "[::msgcat::mc {Glass #5}] "
            entry .conf.top.parts.frame.wineglasses_frame.glass5e -textvariable glassname05 -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            grid .conf.top.parts.frame.wineglasses_frame.glass5t .conf.top.parts.frame.wineglasses_frame.glass5e -sticky w
            label .conf.top.parts.frame.wineglasses_frame.glass6t -text "[::msgcat::mc {Glass #6}] "
            entry .conf.top.parts.frame.wineglasses_frame.glass6e -textvariable glassname06 -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            grid .conf.top.parts.frame.wineglasses_frame.glass6t .conf.top.parts.frame.wineglasses_frame.glass6e -sticky w
            label .conf.top.parts.frame.wineglasses_frame.glass7t -text "[::msgcat::mc {Glass #7}] "
            entry .conf.top.parts.frame.wineglasses_frame.glass7e -textvariable glassname07 -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            grid .conf.top.parts.frame.wineglasses_frame.glass7t .conf.top.parts.frame.wineglasses_frame.glass7e -sticky w
            label .conf.top.parts.frame.wineglasses_frame.glass8t -text "[::msgcat::mc {Glass #8}] "
            entry .conf.top.parts.frame.wineglasses_frame.glass8e -textvariable glassname08 -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            grid .conf.top.parts.frame.wineglasses_frame.glass8t .conf.top.parts.frame.wineglasses_frame.glass8e -sticky w
            label .conf.top.parts.frame.wineglasses_frame.glass9t -text "[::msgcat::mc {Glass #9}] "
            entry .conf.top.parts.frame.wineglasses_frame.glass9e -textvariable glassname09 -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            grid .conf.top.parts.frame.wineglasses_frame.glass9t .conf.top.parts.frame.wineglasses_frame.glass9e -sticky w
            label .conf.top.parts.frame.wineglasses_frame.glass10t -text "[::msgcat::mc {Glass #10}] "
            entry .conf.top.parts.frame.wineglasses_frame.glass10e -textvariable glassname10 -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
            grid .conf.top.parts.frame.wineglasses_frame.glass10t .conf.top.parts.frame.wineglasses_frame.glass10e -sticky w
            ::conmen .conf.top.parts.frame.wineglasses_frame.glass1e
            ::conmen .conf.top.parts.frame.wineglasses_frame.glass2e
            ::conmen .conf.top.parts.frame.wineglasses_frame.glass3e
            ::conmen .conf.top.parts.frame.wineglasses_frame.glass4e
            ::conmen .conf.top.parts.frame.wineglasses_frame.glass5e
            ::conmen .conf.top.parts.frame.wineglasses_frame.glass6e
            ::conmen .conf.top.parts.frame.wineglasses_frame.glass7e
            ::conmen .conf.top.parts.frame.wineglasses_frame.glass8e
            ::conmen .conf.top.parts.frame.wineglasses_frame.glass9e
            ::conmen .conf.top.parts.frame.wineglasses_frame.glass10e
          grid  .conf.top.parts.frame.wineglasses_description .conf.top.parts.frame.wineglasses_frame -sticky nw
          frame .conf.top.parts.frame.blank13 -height 7 -borderwidth 0 -pady 0
          grid .conf.top.parts.frame.blank13 -columnspan 2
          # how to add points by default
          label .conf.top.parts.frame.pointsmanually_description -text "[::msgcat::mc {Points Allocation}] " -font ${titlefont}
          frame .conf.top.parts.frame.pointsmanually_checkbox
            radiobutton .conf.top.parts.frame.pointsmanually_checkbox.1 -text [::msgcat::mc {automatically}] -variable manualpoints -value false
            radiobutton .conf.top.parts.frame.pointsmanually_checkbox.2 -text [::msgcat::mc {manually}] -variable manualpoints -value true
          pack  .conf.top.parts.frame.pointsmanually_checkbox.1 .conf.top.parts.frame.pointsmanually_checkbox.2 -side left
          grid  .conf.top.parts.frame.pointsmanually_description .conf.top.parts.frame.pointsmanually_checkbox -sticky w

        pack .conf.top.parts.frame -fill both -expand true
        .conf.top.parts configure -text [ .conf.top.partselect.5 cget -text ]
        grid columnconfigure .conf.top.parts.frame 1 -weight 1
        frame .conf.top.parts.frame.fill
        grid .conf.top.parts.frame.fill -sticky news -columnspan 2
        grid rowconfigure .conf.top.parts.frame 7 -weight 1
      }
    pack .conf.top.partselect.1 -side top -fill x -padx 5 -pady 5
    pack .conf.top.partselect.2 -side top -fill x -padx 5 -pady 0
    pack .conf.top.partselect.3 -side top -fill x -padx 5 -pady 5
    pack .conf.top.partselect.4 -side top -fill x -padx 5 -pady 0
    pack .conf.top.partselect.5 -side top -fill x -padx 5 -pady 5
		if { ${bTtk} } {
    	ttk::labelframe .conf.top.parts -text {}
		} else {
			labelframe .conf.top.parts -text {} -padx 10 -pady 10
		}
      frame .conf.top.parts.frame
      pack .conf.top.parts.frame -side top -fill both -expand true
    # menu
    frame    .conf.menu
			if { ${bTtk} } {
      	ttk::button .conf.menu.ok -image ${okay} -text [::msgcat::mc {Save & Restart}] -compound left -command {
					set titlefont "-family \"${fontfamily}\" -size ${fontsize} -weight bold"
					set textfont  "-family \"${fontfamily}\" -size ${fontsize} -weight normal"
					set smallfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal"
					set smallitalicfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal -slant italic"
					set listfont  "-family courier -size ${fontsize} -weight normal"
					if { ${currency} != {euro} } { set currency ${currency2} }
					set changeconfig {true}
					destroy .conf
				}
			} else {
				button .conf.menu.ok -image ${okay} -text [::msgcat::mc {Save & Restart}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -command {
					set titlefont "-family \"${fontfamily}\" -size ${fontsize} -weight bold"
					set textfont  "-family \"${fontfamily}\" -size ${fontsize} -weight normal"
					set smallfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal"
					set smallitalicfont "-family \"${fontfamily}\" -size [ expr "${fontsize} -1" ] -weight normal -slant italic"
					set listfont  "-family courier -size ${fontsize} -weight normal"
					if { ${currency} != {euro} } { set currency ${currency2} }
					set changeconfig {true}
					destroy .conf
				}
			}
			if { ${bTtk} } {
      	ttk::button .conf.menu.abort -image ${close} -text [::msgcat::mc {Abort}] -compound left -command {
					source ${conffile}
					if { ${currency} == {euro} } { set currency "\u20ac" }
						source [ file join ${prog_dir} tcl color.tcl ]
						.menu1.3.search.box   configure -background ${lightcolor}
						.menu1.3.idsearch.box configure -background ${lightcolor}
						.winelist.text configure -labelbackground ${background} -labelforeground ${textcolor} -stripebg ${midcolor} -background ${lightcolor}
						set changeconfig {false}
						destroy .conf
					}
			} else {
				button .conf.menu.abort -image ${close} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -command {
					source ${conffile}
					if { ${currency} == {euro} } { set currency "\u20ac" }
						source [ file join ${prog_dir} tcl color.tcl ]
						.menu1.3.search.box   configure -background ${lightcolor}
						.menu1.3.idsearch.box configure -background ${lightcolor}
						.winelist.text configure -labelbackground ${background} -labelforeground ${textcolor} -stripebg ${midcolor} -background ${lightcolor}
						set changeconfig {false}
						destroy .conf
					}
			}
    pack .conf.menu.ok .conf.menu.abort -side left -fill x -expand true
    # all together
    pack .conf.top.partselect -side left -fill y -padx 10 -pady 10
    pack .conf.top.parts      -side left -fill both -expand true -padx 10 -pady 10
    pack .conf.top            -side top  -fill both -expand true
    pack .conf.menu           -side top  -fill x
    .conf.top.partselect.1 invoke
    bind .conf <KeyPress-F2>     { .conf.menu.ok invoke }
    bind .conf <KeyPress-Escape> { .conf.menu.abort invoke }
    bind .conf <Control-Key-q>   { .conf.menu.abort invoke }
    # determine the window size
    wm iconify .conf
    .conf.top.partselect.5 invoke
    update
    set confminwidth  [ winfo width .conf ]
    set confminheight [ winfo height .conf ]
    .conf.top.partselect.4 invoke
    update
    if { [ winfo width  .conf ] > ${confminwidth}  } { set confminwidth  [ winfo width .conf ]  }
    if { [ winfo height .conf ] > ${confminheight} } { set confminheight [ winfo height .conf ] }
    .conf.top.partselect.3 invoke
    update
    if { [ winfo width  .conf ] > ${confminwidth}  } { set confminwidth  [ winfo width .conf ]  }
    if { [ winfo height .conf ] > ${confminheight} } { set confminheight [ winfo height .conf ] }
    .conf.top.partselect.2 invoke
    update
    if { [ winfo width  .conf ] > ${confminwidth}  } { set confminwidth  [ winfo width .conf ]  }
    if { [ winfo height .conf ] > ${confminheight} } { set confminheight [ winfo height .conf ] }
    .conf.top.partselect.1 invoke
    update
    if { [ winfo width  .conf ] > ${confminwidth}  } { set confminwidth  [ winfo width .conf ]  }
    if { [ winfo height .conf ] > ${confminheight} } { set confminheight [ winfo height .conf ] }
    wm minsize   .conf ${confminwidth} ${confminheight}
    wm geometry  .conf ${confminwidth}x${confminheight}
    wm deiconify .conf
    # wait until window is gone
    tkwait window .conf
  }
  # paths should end without backslashes
  set picopenpath [ string trimright ${picopenpath} {\\} ]
  set prog_dir [ string trimright ${prog_dir} {\\} ]
  #write configuration
  if { ${changeconfig} == {true} } {
    set initchannel [ open ${conffile} w ]
    puts ${initchannel} "# configuration-file for TkWice"
    puts ${initchannel} "set nls \{${nls}\}"
    puts ${initchannel} "set titlefont \{${titlefont}\}"
    puts ${initchannel} "set textfont \{$textfont\}"
    puts ${initchannel} "set smallfont \{${smallfont}\}"
    puts ${initchannel} "set smallitalicfont \{${smallitalicfont}\}"
    puts ${initchannel} "set listfont \{${listfont}\}"
    puts ${initchannel} "set onecolor \{${onecolor}\}"
    puts ${initchannel} "set basecolor \{${basecolor}\}"
    puts ${initchannel} "set colortheme \{${colortheme}\}"
    puts ${initchannel} "set listlines \{${listlines}\}"
    puts ${initchannel} "set region_space \{${region_space}\}"
    puts ${initchannel} "set name_space \{${name_space}\}"
    puts ${initchannel} "set grapes_space \{${grapes_space}\}"
    puts ${initchannel} "set currency \{${currency}\}"
    puts ${initchannel} "set prog_dir \{${prog_dir}\}"
    puts ${initchannel} "set countrybuttons \{${countrybuttons}\}"
    puts ${initchannel} "set cbupdate \{${cbupdate}\}"
    puts ${initchannel} "set colorname \{${colorname}\}"
    puts ${initchannel} "set show_only_code \{${show_only_code}\}"
    puts ${initchannel} "set ulcx \{${ulcx}\}"
    puts ${initchannel} "set ulcy \{${ulcy}\}"
    puts ${initchannel} "set centerx \{${centerx}\}"
    puts ${initchannel} "set centery \{${centery}\}"
    puts ${initchannel} "set windowplacement \{${windowplacement}\}"
    puts ${initchannel} "set dateformat \{${dateformat}\}"
    puts ${initchannel} "set webbrowser \{${webbrowser}\}"
    puts ${initchannel} "set picopenpath \{${picopenpath}\}"
    puts ${initchannel} "set viewmode \{$viewmode\}"
    puts ${initchannel} "set glassname01 \{${glassname01}\}"
    puts ${initchannel} "set glassname02 \{${glassname02}\}"
    puts ${initchannel} "set glassname03 \{${glassname03}\}"
    puts ${initchannel} "set glassname04 \{${glassname04}\}"
    puts ${initchannel} "set glassname05 \{${glassname05}\}"
    puts ${initchannel} "set glassname06 \{${glassname06}\}"
    puts ${initchannel} "set glassname07 \{${glassname07}\}"
    puts ${initchannel} "set glassname08 \{${glassname08}\}"
    puts ${initchannel} "set glassname09 \{${glassname09}\}"
    puts ${initchannel} "set glassname10 \{${glassname10}\}"
    puts ${initchannel} "set manualpoints \{${manualpoints}\}"
    puts ${initchannel} "set tooltips \{${tooltips}\}"
    puts ${initchannel} "set grape_add_syn \{${grape_add_syn}\}"
    puts ${initchannel} "set grape_add_switch \{${grape_add_switch}\}"
    puts ${initchannel} "set grape_add_synonly \{${grape_add_synonly}\}"
    puts ${initchannel} "set grape_add_lab \{${grape_add_lab}\}"
    puts ${initchannel} "set grape_add_labnote \{${grape_add_labnote}\}"
    puts ${initchannel} "set grape_add_nat \{${grape_add_nat}\}"
    puts ${initchannel} "set grape_add_scanrelated \{${grape_add_scanrelated}\}"
    puts ${initchannel} "set tempscale \{${tempscale}\}"
    puts ${initchannel} "set configmajor \{${majorversion}\}"
    puts ${initchannel} "set configminor \{${minorversion}\}"
    puts ${initchannel} "set configpatch \{${patchlevel}\}"
    close ${initchannel}
    # restart if config saved and not the first start
    if { ${firststart} != {firststart} } {
      if { [ lindex $argv 0 ] == {--profile} && [ lindex $argv 1 ] != {} } {
        exec ${wish} "${self}" --profile [ lindex $argv 1 ] &
      } else {
        exec ${wish} "${self}" &
      }
      exit
    }
  }
  # first start, set euro new if currency is euro
  if { ${currency} == {euro} } { set currency "\u20ac" }
}

# traceings
proc trace_colortheme {} {
  if { [ winfo exists .conf ] } {
    global colortheme prog_dir onecolor basecolor titlefont bTtk
    if { [ winfo exists .conf.top.parts.frame.color_button.4 ] }       { .conf.top.parts.frame.color_button.4 configure -text ${colortheme} }
    source [ file join ${prog_dir} tcl color.tcl ]
    if { [ winfo exists .conf.top.parts.frame.ulcx_selection.1 ] }     { .conf.top.parts.frame.ulcx_selection.1     configure -background ${lightcolor} }
    if { [ winfo exists .conf.top.parts.frame.ulcy_selection.1 ] }     { .conf.top.parts.frame.ulcy_selection.1     configure -background ${lightcolor} }
    if { [ winfo exists .conf.top.parts.frame.fontsize_selection.1 ] } { .conf.top.parts.frame.fontsize_selection.1 configure -background ${lightcolor} }
    if { [ winfo exists .conf.top.partselect ] }                       { .conf.top.partselect configure -background ${midcolor} }
    if { [ winfo exists .conf.top.partselect.1 ] }                     { .conf.top.partselect.1 configure -background ${midcolor}         -foreground ${textcolor} }
    if { [ winfo exists .conf.top.partselect.2 ] }                     { .conf.top.partselect.2 configure -background ${selectbackground} -foreground ${selectforeground} }
    if { [ winfo exists .conf.top.partselect.3 ] }                     { .conf.top.partselect.3 configure -background ${midcolor}         -foreground ${textcolor} }
    if { [ winfo exists .conf.top.partselect.4 ] }                     { .conf.top.partselect.4 configure -background ${midcolor}         -foreground ${textcolor} }
    if { [ winfo exists .conf.top.partselect.5 ] }                     { .conf.top.partselect.5 configure -background ${midcolor}         -foreground ${textcolor} }
    .winelist.text configure -labelbackground ${background} -labelforeground ${textcolor} -stripebg ${midcolor} -background ${lightcolor}
  }
}
trace variable colortheme w "trace_colortheme ;#"
