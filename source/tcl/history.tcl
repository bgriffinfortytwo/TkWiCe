# call: tclsh thisscript conffile hist_out
#       tclsh thisscript conffile hist_in
#       tclsh thisscript conffile clear
#       tclsh thisscript conffile

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
set conffile  [ lindex $argv 0 ]
if { [ llength $argv ] == {2} } {
  set show_list [ lindex $argv 1 ]
} else {
  set show_list {clear}
}
source ${conffile}


# Tile only for the tile theme
if { ( ${onecolor} == {false} && ${colortheme} != {tile} ) || ${onecolor} != {false} } {
	set bTtk 0
}


# load messages
msgcat::mclocale ${nls}
msgcat::mcload [ file join ${prog_dir} nls ]


set progname  [::msgcat::mc {TkWiCe History}]
wm title      . ${progname}
wm resizable  . true true
wm iconname   . ${progname}


# window placement
if { ${windowplacement} == {user} } {
  wm geometry . +${ulcx}+${ulcy}
} elseif { ${windowplacement} == {fullscreen} } {
  wm deiconify        .
  wm overrideredirect . true
  wm resizable        . false false
  . configure -borderwidth 3 -relief raised
  wm geometry . [ winfo screenwidth . ]x[ winfo screenheight . ]+0+0
} elseif  { ${windowplacement} == {maximized} } {
  if { [ info tclversion ] >= {8.5} } {
    if { $tcl_platform(platform) != {unix} } {
      wm state . zoomed
    } else {
      wm attributes . -zoomed
    }
  }
}


# icon
catch { wm iconphoto . -default [ image create photo -file [ file join ${prog_dir} img tkwice48.gif ] ] [ image create photo -file [ file join ${prog_dir} img tkwice32.gif ] ] }


# graphics
set reload       [ image create photo -file [ file join ${prog_dir} img reload.gif ] ]
set edit         [ image create photo -file [ file join ${prog_dir} img edit2.gif ] ]
set closebutton  [ image create photo -file [ file join ${prog_dir} img close.gif ] ]
set delete       [ image create photo -file [ file join ${prog_dir} img delete2.gif ] ]
set okay         [ image create photo -file [ file join ${prog_dir} img okay.gif ] ]
set inputbutton  [ image create photo -file [ file join ${prog_dir} img in.gif ] ]
set outputbutton [ image create photo -file [ file join ${prog_dir} img out.gif ] ]


# tablelist
set tablelist_version {false}
catch { set tablelist_version [ package require tablelist ] }
if { ${tablelist_version} == {false} } { lappend auto_path [ file join ${prog_dir} tcl tk ] }
package require tablelist
if { ${tablelist_version} == {false} } { set tablelist_version [ package require tablelist ] }
set tablelist_version $tablelist::version
# package conmen
set conmen_version {false}
catch { set conmen_version [ package require conmen ] }
if { ${conmen_version} == {false} } { lappend auto_path [ file join ${prog_dir} tcl tk ] }
package require conmen


# set colors
source [ file join ${prog_dir} tcl color.tcl ]
# source the option database
source [ file join ${prog_dir} tcl style.tcl ]
# currency - euro?
if { ${currency} == {euro} } { set currency "\u20ac" }
# get date
set today_year  [ clock format [ clock seconds ] -format %Y ]
set today_month [ clock format [ clock seconds ] -format %m ]
# take sure that we can calculate with dates
if { [string index ${today_month} 0] == "0" } {
  set today_month [string index ${today_month} 1]
}


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


# edit an entry of the tablelist
proc do_edit {} {
  global dataset dateformat show_list textfont titlefont lightcolor currency note wine_edit country price name_space changeline file delete okay closebutton bTtk

  # set up vars
  if { ${show_list} == {hist_in} } {
    set file {history.in}
  } else {
    set file {history.out}
  }
  if { [ string length [ lindex ${dataset} 0 ] ] == {10} } {
    set year [ string range [ lindex ${dataset} 0 ] 6 9 ]
    if { ${dateformat} == {dm} } {
      set month [ string range [ lindex ${dataset} 0 ] 3 4 ]
      set day [ string range [ lindex ${dataset} 0 ] 0 1 ]
    } else {
      set month [ string range [ lindex ${dataset} 0 ] 0 1 ]
      set day [ string range [ lindex ${dataset} 0 ] 3 4 ]
    }
  } else {
    set year {----}
    set month {--}
    set day {--}
  }
  set wine_edit [ lindex ${dataset} 1 ]
  set country [ lindex ${dataset} 2 ]
  set note [ lindex ${dataset} 3 ]
  set amount [ lindex ${dataset} 4 ]
  set price [ lindex ${dataset} 5 ]
  set changeline {}
  lappend changeline ${year} ${month} ${day} ${wine_edit} ${country} ${amount} ${price} ${note}

  # startup only if window not present
  if { [ winfo exists .edit ] } {
    raise .edit .

  # okay
  } else {

    # window stuff
    set titlename [::msgcat::mc {Global History Editor}]
    toplevel     .edit
    wm title     .edit ${titlename}
    focus        .edit
    wm transient .edit .

    # build gui
		if { ${bTtk} } {
    	ttk::labelframe .edit.frame1 -text ${titlename}
		} else {
			labelframe .edit.frame1 -text ${titlename} -padx 2 -pady 2
		}

      label .edit.frame1.date1 -text "[::msgcat::mc {Date}] " -font ${titlefont} -anchor w
      frame .edit.frame1.date2
        spinbox .edit.frame1.date2.day -from 1 -to 31 -textvariable day -width 2 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 3 } }
        if { ${dateformat} == {dm} } {
          label .edit.frame1.date2.fill1 -text {-}
        } else {
          label .edit.frame1.date2.fill1 -text {/}
        }
        spinbox .edit.frame1.date2.month -from 1 -to 12 -textvariable month -width 2 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 3 } }
        if { ${dateformat} == {dm} } {
          label .edit.frame1.date2.fill2 -text {-}
        } else {
          label .edit.frame1.date2.fill2 -text {/}
        }
        spinbox .edit.frame1.date2.year -from 1700 -to 9999 -textvariable year -width 4 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 5 } }
        .edit.frame1.date2.day   set ${day}
        .edit.frame1.date2.month set ${month}
        .edit.frame1.date2.year  set ${year}
      if { ${dateformat} == {dm} } {
        pack .edit.frame1.date2.day .edit.frame1.date2.fill1 .edit.frame1.date2.month .edit.frame1.date2.fill2 .edit.frame1.date2.year -side left
      } else {
        pack .edit.frame1.date2.month .edit.frame1.date2.fill1 .edit.frame1.date2.day .edit.frame1.date2.fill2 .edit.frame1.date2.year -side left
      }
      grid .edit.frame1.date1 .edit.frame1.date2 -sticky w

      label .edit.frame1.wine1 -text "[::msgcat::mc {Wine}] " -font ${titlefont} -anchor w
      entry .edit.frame1.wine2 -textvariable wine_edit -width $name_space -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
      grid .edit.frame1.wine1 .edit.frame1.wine2 -sticky w
      ::conmen .edit.frame1.wine2

      label .edit.frame1.country1 -text "[::msgcat::mc {Country}] " -font ${titlefont} -anchor w
      entry .edit.frame1.country2 -textvariable country -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
      grid .edit.frame1.country1 .edit.frame1.country2 -sticky w
      ::conmen .edit.frame1.country2

      label .edit.frame1.note1 -text "[::msgcat::mc {Note}] " -font ${titlefont} -anchor w
      entry .edit.frame1.note2 -textvariable note -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
      grid .edit.frame1.note1 .edit.frame1.note2 -sticky w
      ::conmen .edit.frame1.note2

      label .edit.frame1.amount1 -text "[::msgcat::mc {Quantity}] " -font ${titlefont} -anchor w
      frame .edit.frame1.amount2
        spinbox .edit.frame1.amount2.box -textvariable amount -from 1 -to 999 -width 3 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 4 } }
        .edit.frame1.amount2.box set ${amount}
        label .edit.frame1.amount2.text -text [::msgcat::mc {bottles}]
      pack .edit.frame1.amount2.box .edit.frame1.amount2.text -side left
      grid .edit.frame1.amount1 .edit.frame1.amount2 -sticky w

      label .edit.frame1.price1 -text "[::msgcat::mc {Cost}] " -font ${titlefont} -anchor w
      frame .edit.frame1.price2
        entry .edit.frame1.price2.entry -textvariable price -width 7 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is double %P ] && [ string length %P ] < 8 } }
        # comma to point translation
        bind .edit.frame1.price2.entry <KeyPress> {
          if { "%A" == {,} && ![ regexp {\.} ${price} ] } {
            append price {.}
            .edit.frame1.price2.entry icursor end
          }
        }
        label .edit.frame1.price2.currency -text "${currency} "
      pack .edit.frame1.price2.entry .edit.frame1.price2.currency -side left
      grid .edit.frame1.price1 .edit.frame1.price2 -sticky w

    frame .edit.frame2
      button .edit.frame2.ok -image ${okay} -text [::msgcat::mc {Take Over}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -command {
        set newline {}
        if { ${day} == {} } { set day {--} }
        if { ${month} == {} } { set month {--} }
        if { ${year} == {} } { set year {----} }
        if { [ string length ${day} ] != {2} } {
          set day   [ format "%2.2d" ${day} ]
        }
        if { [ string length ${month} ] != {2} } {
          set month [ format "%2.2d" ${month} ]
        }
        if { [ string length ${year} ] != {4} } {
          set year  [ format "%4.4d" ${year} ]
        }
        lappend newline ${year} ${month} ${day} ${wine_edit} ${country} ${amount} ${price} ${note}
        set initchannel [ open [ file join [ file dirname ${conffile} ] ${file} ] r ]
        set historylist [ read ${initchannel} ]
        set historylist2 [ string map [ list ${changeline} ${newline} ] ${historylist} ]
        # reorg historylist2: sort by line
        set historylist2 [ split ${historylist2} "\n" ]
        set historylist2 [ lsort ${historylist2} ]
        set initchannel [ open [ file join [ file dirname ${conffile} ] ${file} ] w ]
        # we don't like blanks in the list, so write line by line
        foreach line ${historylist2} {
          if {${line} != {}} {
            puts ${initchannel} ${line}
          }
        }
        close ${initchannel}
        .headline.re invoke
        destroy .edit
      }
      menubutton .edit.frame2.del -image ${delete} -text [::msgcat::mc {Delete Entry}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -highlightthickness 1 -menu .edit.frame2.del.menu -direction above
        set deleteconfirm [ menu .edit.frame2.del.menu -tearoff 0 ]
        ${deleteconfirm} add command -label [::msgcat::mc {Confirmation}] -command {
          set initchannel [ open [ file join [ file dirname ${conffile} ] ${file} ] r ]
          set historylist [ read ${initchannel} ]
          set historylist2 [ string map [ list ${changeline} {} ] ${historylist} ]
          # reorg historylist2: sort by line
          set historylist2 [ split ${historylist2} "\n" ]
          set historylist2 [ lsort ${historylist2} ]
          set initchannel [ open [ file join [ file dirname ${conffile} ] ${file} ] w ]
          # we don't like blanks in the list, so write line by line
          foreach line ${historylist2} {
            if {${line} != {}} {
              puts ${initchannel} ${line}
            }
          }
          close ${initchannel}
          .headline.re invoke
          destroy .edit
        }
      button .edit.frame2.abort -image ${closebutton} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -command {
        destroy .edit
      }
    pack .edit.frame2.ok .edit.frame2.del .edit.frame2.abort -side left -fill both -expand true

    pack .edit.frame1 .edit.frame2 -side top -padx 10 -pady 10 -fill both

    # window placement - mousepointer in the middle ...
    tkwait visibility .edit
    set xposition_info [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .edit ] / 2" ]" ]
    set yposition_info [ expr "[ winfo pointery . ] - [ expr "[ winfo height .edit ] / 2" ]" ]
    if { ${xposition_info} < {0} } { set xposition_info {0} }
    if { ${yposition_info} < {0} } { set yposition_info {0} }
    if { [ expr "[ winfo width  .edit ] + ${xposition_info}" ] > [ winfo screenwidth  . ] } { set xposition_info [ expr "[ winfo screenwidth  . ] - [ winfo width  .edit ]" ] }
    if { [ expr "[ winfo height .edit ] + ${yposition_info}" ] > [ winfo screenheight . ] } { set yposition_info [ expr "[ winfo screenheight . ] - [ winfo height .edit ]" ] }
    wm geometry .edit +${xposition_info}+${yposition_info}

    # keyboard bindings
    bind .edit <KeyPress-F2> { .edit.frame2.ok invoke }
    bind .edit <KeyPress-F8> { .edit.frame2.ok invoke }
    bind .edit <KeyPress-Delete> { .edit.frame2.del invoke }
    bind .edit <KeyPress-Escape> { .edit.frame2.abort invoke }
    bind .edit <Control-Key-q>   { .edit.frame2.abort invoke }
  }
}

# window
frame .headline
  button .headline.in -image ${inputbutton} -text [::msgcat::mc {Shopping History}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -command {
    if { ${show_list} == {hist_out} || ${show_list} == {clear} } {
      .headline.in  configure -relief sunken -background ${lightcolor}
      .headline.out configure -relief raised -background ${background}
      set show_list {hist_in}
      $show_list yes
    }
  }
  pack .headline.in -fill x -expand true -side left
  button .headline.re -image ${reload} -text [::msgcat::mc {Refresh}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -command {
    historyexist
    $show_list yes
    historyexist
  }
  pack .headline.re -side left
  button .headline.ed -image ${edit} -text [::msgcat::mc {Edit}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -state disabled -command {
    do_edit
  }
  pack .headline.ed -side left
  button .headline.out -image ${outputbutton} -text [::msgcat::mc {Drinking History}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -command {
    if { ${show_list} == {hist_in} || ${show_list} == {clear} } {
      .headline.out configure -relief sunken -background ${lightcolor}
      .headline.in  configure -relief raised -background ${background}
      set show_list {hist_out}
      $show_list yes
    }
  }
  pack .headline.out -fill x -expand true -side left
  if { ${show_list} == {hist_in} } {
    .headline.in  configure -relief sunken -background ${lightcolor}
    .headline.out configure -relief raised -background ${background}
  } elseif { ${show_list} == {hist_out} } {
    .headline.out configure -relief sunken -background ${lightcolor}
    .headline.in  configure -relief raised -background ${background}
  }

frame .list
  set listlength [ expr "$name_space + 71" ]
  set listlines [ expr "${listlines} - 10" ]
  if { ${listlines} < {10} } { set listlines {10} }
  tablelist::tablelist .list.box -columns "10 [::msgcat::mc {Date}] $name_space [::msgcat::mc {Wine}] 10 [::msgcat::mc {Country}] 30 [::msgcat::mc {Note}] 2 \u2211 7 ${currency}" -labelbackground ${background} -labelforeground ${textcolor} -labelrelief raised -labelcommand tablelist::sortByColumn -selectmode single -stripebg ${midcolor} -height ${listlines} -width ${listlength} -stretch all -background ${lightcolor} -resizablecolumns false -activestyle none -highlightthickness 0 -exportselection false -yscrollcommand [ list .list.yscroll set ]
  if { [ string range ${tablelist_version} 0 [ expr "[ string first {.} ${tablelist_version} ] - 1" ] ] >= {4} } {
    if { [ string range ${tablelist_version} 0 [ expr "[ string first {.} ${tablelist_version} ] - 1" ] ] == {4} && [ string range ${tablelist_version} [ expr "[ string first {.} ${tablelist_version} ] + 1" ] end ] > {2} } {
      .list.box configure -setfocus true
    } elseif { [ string range ${tablelist_version} 0 [ expr "[ string first {.} ${tablelist_version} ] - 1" ] ] > {4} } {
      .list.box configure -setfocus true
    }
  }
  .list.box columnconfigure 0 -maxwidth 10 -stretchable false
  .list.box columnconfigure 3 -maxwidth 30 -stretchable false
  .list.box columnconfigure 4 -maxwidth 2  -stretchable false -align right
  .list.box columnconfigure 5 -maxwidth 7  -stretchable false -align right
  pack .list.box -side left -fill both -expand true
	if { ${bTtk} } {
  	ttk::scrollbar .list.yscroll -command { .list.box yview } -orient vertical
	} else {
		scrollbar .list.yscroll -command { .list.box yview } -orient vertical
	}
  pack .list.yscroll -side right -fill y
bind [ .list.box bodytag ] <ButtonRelease-1> {
  global dataset
  if { [ .list.box size ] != {0} } {
    set dataset [ .list.box rowcget [ .list.box curselection ] -text ]
    .headline.ed configure -state normal
  }
}
bind [ .list.box bodytag ] <Double-1> { do_edit }
bind [ .list.box bodytag ] <Key-Down> {
  global dataset
  if { [ .list.box size ] != {0} } {
    update
    set positionsline [ expr "[ .list.box curselection ] + 1" ]
    if { ${positionsline} < [ .list.box size ] } {
      .list.box selection clear 0 end
      .list.box selection set ${positionsline}
      .list.box activate ${positionsline}
      .list.box see ${positionsline}
      set dataset [ .list.box rowcget ${positionsline} -text ]
      .headline.ed configure -state normal
    }
  }
}
bind [ .list.box bodytag ] <Key-Up> {
  global dataset
  if { [ .list.box size ] != {0} } {
    update
    set positionsline [ expr "[ .list.box curselection ] - 1" ]
    if { ${positionsline} >= {0} } {
      .list.box selection clear 0 end
      .list.box selection set ${positionsline}
      .list.box activate ${positionsline}
      .list.box see ${positionsline}
      set dataset [ .list.box rowcget ${positionsline} -text ]
      .headline.ed configure -state normal
    }
  }
}
bind . <Next> {
  global dataset
  if { [ .list.box size ] != {0} } {
    update
    set positionsline [ expr "[ .list.box curselection ] + 10" ]
    if { ${positionsline} >= [ .list.box size ] } { set  positionsline [ expr "[ .list.box size ] - 1" ] }
    if { ${positionsline} < [ .list.box size ] } {
      .list.box selection clear 0 end
      .list.box selection set ${positionsline}
      .list.box activate ${positionsline}
      .list.box see ${positionsline}
      set dataset [ .list.box rowcget ${positionsline} -text ]
      .headline.ed configure -state normal
    }
  }
}
bind . <Prior> {
  global dataset
  if { [ .list.box size ] != {0} } {
    update
    set positionsline [ expr "[ .list.box curselection ] - 10" ]
    if { ${positionsline} < {0} } { set positionsline 0 }
    if { ${positionsline} >= {0} } {
      .list.box selection clear 0 end
      .list.box selection set ${positionsline}
      .list.box activate ${positionsline}
      .list.box see ${positionsline}
      set dataset [ .list.box rowcget ${positionsline} -text ]
      .headline.ed configure -state normal
    }
  }
}
bind [ .list.box bodytag ] <Key-End> {
  global dataset
  if { [ .list.box size ] != {0} } {
    set positionsline [ expr "[ .list.box size ] - 1" ]
    update
    .list.box selection clear 0 end
    .list.box selection set end
    .list.box activate end
    .list.box see end
    set dataset [ .list.box rowcget ${positionsline} -text ]
    .headline.ed configure -state normal
  }
}
bind [ .list.box bodytag ] <Key-Home> {
  global dataset
  if { [ .list.box size ] != {0} } {
    set positionsline {0}
    update
    .list.box selection clear 0 end
    .list.box selection set 0
    .list.box activate 0
    .list.box see 0
    set dataset [ .list.box rowcget ${positionsline} -text ]
    .headline.ed configure -state normal
  }
}
bind [ .list.box bodytag ] <Return> {
  global dataset
  if { [ .list.box size ] != {0} && ${dataset} != {} } { do_edit }
}
bind [ .list.box bodytag ] <Double-1> {
  global dataset
  if { [ .list.box size ] != {0} && ${dataset} != {} } { do_edit }
}
menu .list.box.contextmenu -tearoff 0
.list.box.contextmenu add command -label [::msgcat::mc {Edit}] -command { .headline.ed invoke }
bind [ .list.box bodytag ] <Button-3> { tk_popup .list.box.contextmenu %X %Y }

frame .stats
  label .stats.00
  grid  .stats.00 -column 0 -row 0
  label .stats.01 -text [::msgcat::mc {Shopping}] -font ${titlefont} -relief raised -borderwidth 1
  grid  .stats.01 -columnspan 2 -column 1 -row 0 -sticky we
  label .stats.02 -text [::msgcat::mc {Drinking}] -font ${titlefont} -relief raised -borderwidth 1
  grid  .stats.02 -columnspan 2 -column 3 -row 0 -sticky we

  label .stats.10
  grid  .stats.10 -column 0 -row 1
  label .stats.11 -text [::msgcat::mc {Last 12 Months}] -font ${titlefont} -anchor w
  grid  .stats.11 -column 1 -row 1 -sticky w -padx 10
  label .stats.12 -text [::msgcat::mc {Cross-Check 36 Months}] -font ${titlefont} -anchor w
  grid  .stats.12 -column 2 -row 1 -sticky w -padx 10
  label .stats.13 -text [::msgcat::mc {Last 12 Months}] -font ${titlefont} -anchor w
  grid  .stats.13 -column 3 -row 1 -sticky w -padx 10
  label .stats.14 -text [::msgcat::mc {Cross-Check 36 Months}] -font ${titlefont} -anchor w
  grid  .stats.14 -column 4 -row 1 -sticky w -padx 10

  label .stats.20 -text [::msgcat::mc {Money}] -font ${titlefont} -anchor w
  grid  .stats.20 -column 0 -row 2 -sticky w -padx 10
  label .stats.21 -anchor e
  grid  .stats.21 -column 1 -row 2 -sticky e -padx 10
  label .stats.22 -anchor e
  grid  .stats.22 -column 2 -row 2 -sticky e -padx 10
  label .stats.23 -anchor e
  grid  .stats.23 -column 3 -row 2 -sticky e -padx 10
  label .stats.24 -anchor e
  grid  .stats.24 -column 4 -row 2 -sticky e -padx 10

  label .stats.30 -text [::msgcat::mc {Bottles}] -font ${titlefont} -anchor w
  grid  .stats.30 -column 0 -row 3 -sticky w -padx 10
  label .stats.31 -anchor e
  grid  .stats.31 -column 1 -row 3 -sticky e -padx 10
  label .stats.32 -anchor e
  grid  .stats.32 -column 2 -row 3 -sticky e -padx 10
  label .stats.33 -anchor e
  grid  .stats.33 -column 3 -row 3 -sticky e -padx 10
  label .stats.34 -anchor e
  grid  .stats.34 -column 4 -row 3 -sticky e -padx 10

  label .stats.40 -text [::msgcat::mc {Average}] -font ${titlefont} -anchor w
  grid  .stats.40 -column 0 -row 4 -sticky w -padx 10
  label .stats.41 -anchor e
  grid  .stats.41 -column 1 -row 4 -sticky e -padx 10
  label .stats.42 -anchor e
  grid  .stats.42 -column 2 -row 4 -sticky e -padx 10
  label .stats.43 -anchor e
  grid  .stats.43 -column 3 -row 4 -sticky e -padx 10
  label .stats.44 -anchor e
  grid  .stats.44 -column 4 -row 4 -sticky e -padx 10

  label .stats.50 -text [::msgcat::mc {1. Country}] -font ${titlefont} -anchor w
  grid  .stats.50 -column 0 -row 5 -sticky w -padx 10
  frame .stats.51
    label .stats.51.0 -anchor w
    pack  .stats.51.0 -side left
    label .stats.51.1 -anchor e
    pack  .stats.51.1 -side right
  grid  .stats.51 -column 1 -row 5 -sticky we -padx 10
  frame .stats.52
    label .stats.52.0 -anchor w
    pack  .stats.52.0 -side left
    label .stats.52.1 -anchor e
    pack  .stats.52.1 -side right
  grid  .stats.52 -column 2 -row 5 -sticky we -padx 10
  frame .stats.53
    label .stats.53.0 -anchor w
    pack  .stats.53.0 -side left
    label .stats.53.1 -anchor e
    pack  .stats.53.1 -side right
  grid  .stats.53 -column 3 -row 5 -sticky we -padx 10
  frame .stats.54
    label .stats.54.0 -anchor w
    pack  .stats.54.0 -side left
    label .stats.54.1 -anchor e
    pack  .stats.54.1 -side right
  grid  .stats.54 -column 4 -row 5 -sticky we -padx 10

  label .stats.60 -text [::msgcat::mc {2. Country}] -font ${titlefont} -anchor w
  grid  .stats.60 -column 0 -row 6 -sticky w -padx 10
  frame .stats.61
    label .stats.61.0 -anchor w
    pack  .stats.61.0 -side left
    label .stats.61.1 -anchor e
    pack  .stats.61.1 -side right
  grid  .stats.61 -column 1 -row 6 -sticky we -padx 10
  frame .stats.62
    label .stats.62.0 -anchor w
    pack  .stats.62.0 -side left
    label .stats.62.1 -anchor e
    pack  .stats.62.1 -side right
  grid  .stats.62 -column 2 -row 6 -sticky we -padx 10
  frame .stats.63
    label .stats.63.0 -anchor w
    pack  .stats.63.0 -side left
    label .stats.63.1 -anchor e
    pack  .stats.63.1 -side right
  grid  .stats.63 -column 3 -row 6 -sticky we -padx 10
  frame .stats.64
    label .stats.64.0 -anchor w
    pack  .stats.64.0 -side left
    label .stats.64.1 -anchor e
    pack  .stats.64.1 -side right
  grid  .stats.64 -column 4 -row 6 -sticky we -padx 10

  label .stats.70 -text [::msgcat::mc {3. Country}] -font ${titlefont} -anchor w
  grid  .stats.70 -column 0 -row 7 -sticky w -padx 10
  frame .stats.71
    label .stats.71.0 -anchor w
    pack  .stats.71.0 -side left
    label .stats.71.1 -anchor e
    pack  .stats.71.1 -side right
  grid  .stats.71 -column 1 -row 7 -sticky we -padx 10
  frame .stats.72
    label .stats.72.0 -anchor w
    pack  .stats.72.0 -side left
    label .stats.72.1 -anchor e
    pack  .stats.72.1 -side right
  grid  .stats.72 -column 2 -row 7 -sticky we -padx 10
  frame .stats.73
    label .stats.73.0 -anchor w
    pack  .stats.73.0 -side left
    label .stats.73.1 -anchor e
    pack  .stats.73.1 -side right
  grid  .stats.73 -column 3 -row 7 -sticky we -padx 10
  frame .stats.74
    label .stats.74.0 -anchor w
    pack  .stats.74.0 -side left
    label .stats.74.1 -anchor e
    pack  .stats.74.1 -side right
  grid  .stats.74 -column 4 -row 7 -sticky we -padx 10

frame .buttons
	if { ${bTtk} } {
  	ttk::button .buttons.ok -image ${closebutton} -text [::msgcat::mc {Close}] -compound left -command { exit }
	} else {
		button .buttons.ok -image ${closebutton} -text [::msgcat::mc {Close}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command { exit }
	}
  pack .buttons.ok -fill x -expand true -side left


# histories exist?
set history_in  "no"
set history_out "no"
proc historyexist {} {
  global history_in history_out conffile
  if { [ file exists [ file join [ file dirname ${conffile} ] history.in  ] ] } {
    if { [ file size [ file join [ file dirname ${conffile} ] history.in  ] ] > {9} } {
      set history_in {yes}
      .headline.in configure -state normal
    } else {
      .headline.in configure -state disable
    }
  } else {
    .headline.in configure -state disable
  }
  if { [ file exists [ file join [ file dirname ${conffile} ] history.out ] ] } {
    if { [ file size [ file join [ file dirname ${conffile} ] history.out  ] ] > {9} } {
      set history_out {yes}
      .headline.out configure -state normal
    } else {
      .headline.out configure -state disable
    }
  } else {
    .headline.out configure -state disable
  }
}
historyexist


# window placement - nothing out of the screen ...
tkwait visibility .
if { [ expr "[ winfo width  . ] + [ winfo x . ]" ] > [ winfo screenwidth  . ] } { set xposition_info [ expr "[ winfo screenwidth  . ] - [ winfo width  . ]" ] }
if { [ expr "[ winfo height . ] + [ winfo y . ]" ] > [ winfo screenheight . ] } { set yposition_info [ expr "[ winfo screenheight . ] - [ winfo height . ]" ] }
if { [ info exists xposition_info ] && [ info exists yposition_info ] } {
  wm geometry . +${xposition_info}+${yposition_info}
} elseif { [ info exists xposition_info ] } {
  wm geometry . +${xposition_info}+[ winfo y . ]
} elseif { [ info exists yposition_info ] } {
  wm geometry . +[ winfo x . ]+${yposition_info}
}
focus .list.box


# proc clear
proc clear {view} {
  # clear tablelist
  .list.box delete 0 [ .list.box size ]
}


# proc drink history
proc hist_out {view} {
  global conffile prog_dir today_year today_month dateformat currency titlefont textfont history_in dataset
  # clear tablelist
  if { ${view} == {yes} } { .list.box delete 0 [ .list.box size ] }
  .headline.ed configure -state disabled
  # set some vars
  set total_price {0.00}
  set total_bottles {0}
  set total_countries {}
  set twelve_price {0.00}
  set twelve_bottles {0}
  set twelve_countries {}
  set history_file [ file join [ file dirname ${conffile} ] history.out ]
  if { [ file exists ${history_file} ] } {
    if { [ file size ${history_file} ] > {9} } {
      set readchannel [ open ${history_file} r ]
      set historylist [ read ${readchannel} ]
      close ${readchannel}
    } else {
      set infotitle [::msgcat::mc {No history found!}]
      set infotext  "[::msgcat::mc {Seems you haven't added any}]\n[::msgcat::mc {bottle to the global history.}]"
      set infotype  {info}
      source [ file join ${prog_dir} tcl info.tcl ]
    exit
    }
  } else {
    set infotitle [::msgcat::mc {No history found!}]
    set infotext  "[::msgcat::mc {Seems you haven't added any}]\n[::msgcat::mc {bottle to the global history.}]"
    set infotype  {info}
    source [ file join ${prog_dir} tcl info.tcl ]
    exit
  }
  # build up line-list in big list and sort it
  set number {0}
  set historylist [ string trimright ${historylist} ]
  while { ${number} <= [ llength ${historylist} ] } {
    set summary {}
    set field1 [ lindex ${historylist} ${number} ]
    set field2 [ lindex ${historylist} [ expr "${number} + 1" ] ]
    set field3 [ lindex ${historylist} [ expr "${number} + 2" ] ]
    set field4 [ lindex ${historylist} [ expr "${number} + 3" ] ]
    set field5 [ lindex ${historylist} [ expr "${number} + 4" ] ]
    set field6 [ lindex ${historylist} [ expr "${number} + 7" ] ]
    set field7 [ lindex ${historylist} [ expr "${number} + 5" ] ]
    set field8 [ lindex ${historylist} [ expr "${number} + 6" ] ]
    if { ${field1} != {} || ${field2} != {} || ${field3} != {} || ${field4} != {} || ${field5} != {} || ${field6} != {} || ${field7} != {} || ${field8} != {} } {
      lappend summary ${field1} ${field2} ${field3} ${field4} ${field5} ${field6} ${field7} ${field8}
      lappend historylist2 ${summary}
    }
    set number [ expr "${number} + 8" ]
  }
  set historylist [ lsort ${historylist2} ]
  # fill tablelist
  foreach entry ${historylist} {
    set thirtysix {false}
    if { ${today_year} == [ lindex ${entry} 0 ] } { set thirtysix {true} }
    if { [ expr "${today_year} - 1" ] == [ lindex ${entry} 0 ] } { set thirtysix {true} }
    if { [ expr "${today_year} - 2" ] == [ lindex ${entry} 0 ] } { set thirtysix {true} }
    if { [ expr "${today_year} - 3" ] == [ lindex ${entry} 0 ] && ${today_month} < [ lindex ${entry} 1 ] } { set thirtysix {true} }
    if { ${thirtysix} == {true} } {
      if { [ lindex ${entry} 7 ] != {} } { set total_price [ expr "${total_price} + [ lindex ${entry} 7 ]" ] }
      if { [ lindex ${entry} 6 ] > {0} } { set total_bottles [ expr "${total_bottles} + [ lindex ${entry} 6 ]" ] }
      if { [ lindex ${entry} 4 ] != {} && [ lindex ${entry} 6 ] > {0} } {
        set counter {0}
        while { ${counter} < [ lindex ${entry} 6 ] } {
          lappend total_countries [ lindex ${entry} 4 ]
          incr counter
        }
      }
    }
    set twelve {false}
    if { ${today_year} == [ lindex ${entry} 0 ] } { set twelve {true} }
    if { [ expr "${today_year} - 1" ] == [ lindex ${entry} 0 ] && ${today_month} < [ lindex ${entry} 1 ] } { set twelve {true} }
    if { ${twelve} == {true} } {
      if { [ lindex ${entry} 7 ] != {} } { set twelve_price [ expr "${twelve_price} + [ lindex ${entry} 7 ]" ] }
      if { [ lindex ${entry} 6 ] > {0} } { set twelve_bottles [ expr "${twelve_bottles} + [ lindex ${entry} 6 ]" ] }
      if { [ lindex ${entry} 4 ] != {} && [ lindex ${entry} 6 ] > {0} } {
        set counter {0}
        while { ${counter} < [ lindex ${entry} 6 ] } {
          lappend twelve_countries [ lindex ${entry} 4 ]
          incr counter
        }
      }
    }
    set hist_line {}
    set date {}
    if { ${dateformat} == {dm} } {
      set date "[ lindex ${entry} 2 ].[ lindex ${entry} 1 ].[ lindex ${entry} 0 ]"
    } else {
      set date "[ lindex ${entry} 1 ]/[ lindex ${entry} 2 ]/[ lindex ${entry} 0 ]"
    }
    lappend hist_line ${date} [ lindex ${entry} 3 ] [ lindex ${entry} 4 ] [ lindex ${entry} 5 ] [ lindex ${entry} 6 ] [ lindex ${entry} 7 ]
    if { ${view} == {yes} } { .list.box insert end $hist_line }
  }
  # update view and select last line
  if { [ .list.box size ] != {0} } {
    .list.box selection set end
    .list.box activate end
    .list.box see end
    set dataset [ .list.box rowcget end -text ]
    .headline.ed configure -state normal
  }
  set total_price   [ format "%.2f" [ expr "${total_price} / 3" ] ]
  set total_bottles [ format "%.0f" [ expr "${total_bottles} / 3" ] ]
  .stats.24 configure -text "${total_price} ${currency}"
  .stats.34 configure -text "${total_bottles} [::msgcat::mc {Bottles}]"
  if { ${total_bottles} > {0} } { .stats.44 configure -text "[ format "%.2f" [ expr "${total_price} / ${total_bottles}" ] ] ${currency}/[::msgcat::mc {Bottle}]" }
  .stats.23 configure -text "[ format "%.2f" ${twelve_price} ] ${currency}"
  .stats.33 configure -text "${twelve_bottles} [::msgcat::mc {Bottles}]"
  if { ${twelve_bottles} > {0} } { .stats.43 configure -text "[ format "%.2f" [ expr "${twelve_price} / ${twelve_bottles}" ] ] ${currency}/[::msgcat::mc {Bottle}]" }
  # 12 months country top 3
  set twelve_countries2 {}
  foreach entry ${twelve_countries} {
    if { [ lsearch -exact ${twelve_countries2} ${entry} ] == "-1" } {
      lappend twelve_countries2 1 ${entry}
    } else {
      set index [ expr "[ lsearch -exact ${twelve_countries2} ${entry} ] - 1" ]
      set value [ expr "[ lindex ${twelve_countries2} $index ] + 1" ]
      set twelve_countries2 [ lreplace ${twelve_countries2} $index $index $value ]
    }
  }
  set number {0}
  set twelve_countries [ string trimright ${twelve_countries2} ]
  set twelve_countries2 {}
  while { ${number} <= [ llength ${twelve_countries} ] } {
    set summary {}
    set field1 [ lindex ${twelve_countries} ${number} ]
    set field2 [ lindex ${twelve_countries} [ expr "${number} + 1" ] ]
    if { ${field1} != {} || ${field2} != {} } {
      lappend summary ${field1} ${field2}
      lappend twelve_countries2 ${summary}
    }
    incr number 2
  }
  set twelve_countries [ lsort -dictionary -decreasing ${twelve_countries2} ]
  if { [ llength ${twelve_countries} ] >= 1 } {
    .stats.53.0 configure -text "[ lindex [ lindex ${twelve_countries} 0 ] 1 ] "
    .stats.53.1 configure -text "([ lindex [ lindex ${twelve_countries} 0 ] 0 ] [::msgcat::mc {Bottles}])"
  }
  if { [ llength ${twelve_countries} ] >= 2 } {
    .stats.63.0 configure -text "[ lindex [ lindex ${twelve_countries} 1 ] 1 ] "
    .stats.63.1 configure -text "([ lindex [ lindex ${twelve_countries} 1 ] 0 ] [::msgcat::mc {Bottles}])"
  }
  if { [ llength ${twelve_countries} ] >= 3 } {
    .stats.73.0 configure -text "[ lindex [ lindex ${twelve_countries} 2 ] 1 ] "
    .stats.73.1 configure -text "([ lindex [ lindex ${twelve_countries} 2 ] 0 ] [::msgcat::mc {Bottles}])"
  }
  # 36 months country top 3
  set total_countries2 {}
  foreach entry ${total_countries} {
    if { [ lsearch -exact ${total_countries2} ${entry} ] == "-1" } {
      lappend total_countries2 1 ${entry}
    } else {
      set index [ expr "[ lsearch -exact ${total_countries2} ${entry} ] - 1" ]
      set value [ expr "[ lindex ${total_countries2} $index ] + 1" ]
      set total_countries2 [ lreplace ${total_countries2} $index $index $value ]
    }
  }
  set number {0}
  set total_countries [ string trimright ${total_countries2} ]
  set total_countries2 {}
  while { ${number} <= [ llength ${total_countries} ] } {
    set summary {}
    set field1 [ lindex ${total_countries} ${number} ]
    set field2 [ lindex ${total_countries} [ expr "${number} + 1" ] ]
    if { ${field1} != {} || ${field2} != {} } {
      lappend summary ${field1} ${field2}
      lappend total_countries2 ${summary}
    }
    incr number 2
  }
  set total_countries [ lsort -dictionary -decreasing ${total_countries2} ]
  if { [ llength ${total_countries} ] >= 1 } {
    .stats.54.0 configure -text "[ lindex [ lindex ${total_countries} 0 ] 1 ] "
    .stats.54.1 configure -text "([ format "%.0f" [ expr "[ lindex [ lindex ${total_countries} 0 ] 0 ] / 3" ] ] [::msgcat::mc {Bottles}])"
  }
  if { [ llength ${total_countries} ] >= 2 } {
    .stats.64.0 configure -text "[ lindex [ lindex ${total_countries} 1 ] 1 ] "
    .stats.64.1 configure -text "([ format "%.0f" [ expr "[ lindex [ lindex ${total_countries} 1 ] 0 ] / 3" ] ] [::msgcat::mc {Bottles}])"
  }
  if { [ llength ${total_countries} ] >= 3 } {
    .stats.74.0 configure -text "[ lindex [ lindex ${total_countries} 2 ] 1 ] "
    .stats.74.1 configure -text "([ format "%.0f" [ expr "[ lindex [ lindex ${total_countries} 2 ] 0 ] / 3" ] ] [::msgcat::mc {Bottles}])"
  }
  update
  if { ${view} == {yes} && ${history_in} == {yes} } { hist_in no }
}


# proc buy history
proc hist_in {view} {
  global conffile prog_dir today_year today_month dateformat currency titlefont textfont history_out
  # clear tablelist
  if { ${view} == {yes} } { .list.box delete 0 [ .list.box size ] }
  .headline.ed configure -state disabled
  # set some vars
  set total_price {0.00}
  set total_bottles {0}
  set total_countries {}
  set twelve_price {0.00}
  set twelve_bottles {0}
  set twelve_countries {}
  # get list
  set history_file [ file join [ file dirname ${conffile} ] history.in ]
  if { [ file exists ${history_file} ] } {
    if { [ file size ${history_file} ] > {9} } {
      set readchannel [ open ${history_file} r ]
      set historylist [ read ${readchannel} ]
      close ${readchannel}
    } else {
      set infotitle [::msgcat::mc {No history found!}]
      set infotext  "[::msgcat::mc {Seems you haven't added any}]\n[::msgcat::mc {bottle to the global history.}]"
      set infotype  {info}
      source [ file join ${prog_dir} tcl info.tcl ]
      exit
    }
  } else {
    set infotitle [::msgcat::mc {No history found!}]
    set infotext  "[::msgcat::mc {Seems you haven't added any}]\n[::msgcat::mc {bottle to the global history.}]"
    set infotype  {info}
    source [ file join ${prog_dir} tcl info.tcl ]
    exit
  }
  # build up line-list in big list and sort it
  set number {0}
  set historylist [ string trimright ${historylist} ]
  while { ${number} <= [ llength ${historylist} ] } {
    set summary {}
    set field1 [ lindex ${historylist} ${number} ]
    set field2 [ lindex ${historylist} [ expr "${number} + 1" ] ]
    set field3 [ lindex ${historylist} [ expr "${number} + 2" ] ]
    set field4 [ lindex ${historylist} [ expr "${number} + 3" ] ]
    set field5 [ lindex ${historylist} [ expr "${number} + 4" ] ]
    set field6 [ lindex ${historylist} [ expr "${number} + 7" ] ]
    set field7 [ lindex ${historylist} [ expr "${number} + 5" ] ]
    set field8 [ lindex ${historylist} [ expr "${number} + 6" ] ]
    if { ${field1} != {} || ${field2} != {} || ${field3} != {} || ${field4} != {} || ${field5} != {} || ${field6} != {} || ${field7} != {} || ${field8} != {} } {
      lappend summary ${field1} ${field2} ${field3} ${field4} ${field5} ${field6} ${field7} ${field8}
      lappend historylist2 ${summary}
    }
    set number [ expr "${number} + 8" ]
  }
  set historylist [ lsort ${historylist2} ]
  # fill tablelist
  foreach entry ${historylist} {
    set thirtysix {false}
    if { ${today_year} == [ lindex ${entry} 0 ] } { set thirtysix {true} }
    if { [ expr "${today_year} - 1" ] == [ lindex ${entry} 0 ] } { set thirtysix {true} }
    if { [ expr "${today_year} - 2" ] == [ lindex ${entry} 0 ] } { set thirtysix {true} }
    if { [ expr "${today_year} - 3" ] == [ lindex ${entry} 0 ] && ${today_month} < [ lindex ${entry} 1 ] } { set thirtysix {true} }
    if { ${thirtysix} == {true} } {
      if { [ lindex ${entry} 7 ] != {} } { set total_price [ expr "${total_price} + [ lindex ${entry} 7 ]" ] }
      if { [ lindex ${entry} 6 ] > {0} } { set total_bottles [ expr "${total_bottles} + [ lindex ${entry} 6 ]" ] }
      if { [ lindex ${entry} 4 ] != {} && [ lindex ${entry} 6 ] > {0} } {
        set counter {0}
        while { ${counter} < [ lindex ${entry} 6 ] } {
          lappend total_countries [ lindex ${entry} 4 ]
          incr counter
        }
      }
    }
    set twelve {false}
    if { ${today_year} == [ lindex ${entry} 0 ] } { set twelve {true} }
    if { [ expr "${today_year} - 1" ] == [ lindex ${entry} 0 ] && ${today_month} < [ lindex ${entry} 1 ] } { set twelve {true} }
    if { ${twelve} == {true} } {
      if { [ lindex ${entry} 7 ] != {} } { set twelve_price [ expr "${twelve_price} + [ lindex ${entry} 7 ]" ] }
      if { [ lindex ${entry} 6 ] > {0} } { set twelve_bottles [ expr "${twelve_bottles} + [ lindex ${entry} 6 ]" ] }
      if { [ lindex ${entry} 4 ] != {} && [ lindex ${entry} 6 ] > {0} } {
        set counter {0}
        while { ${counter} < [ lindex ${entry} 6 ] } {
          lappend twelve_countries [ lindex ${entry} 4 ]
          incr counter
        }
      }
    }
    set hist_line {}
    set date {}
    if { ${dateformat} == {dm} } {
      set date "[ lindex ${entry} 2 ].[ lindex ${entry} 1 ].[ lindex ${entry} 0 ]"
    } else {
      set date "[ lindex ${entry} 1 ]/[ lindex ${entry} 2 ]/[ lindex ${entry} 0 ]"
    }
    lappend hist_line ${date} [ lindex ${entry} 3 ] [ lindex ${entry} 4 ] [ lindex ${entry} 5 ] [ lindex ${entry} 6 ] [ lindex ${entry} 7 ]
    if { ${view} == {yes} } { .list.box insert end $hist_line }
  }
  # update view and select last line
  if { [ .list.box size ] != {0} } {
    .list.box selection set end
    .list.box activate end
    .list.box see end
    set dataset [ .list.box rowcget end -text ]
    .headline.ed configure -state normal
  }
  set total_price   [ format "%.2f" [ expr "${total_price} / 3" ] ]
  set total_bottles [ format "%.0f" [ expr "${total_bottles} / 3" ] ]
  .stats.22 configure -text "${total_price} ${currency}"
  .stats.32 configure -text "${total_bottles} [::msgcat::mc {Bottles}]"
  if { ${total_bottles} > {0} } { .stats.42 configure -text "[ format "%.2f" [ expr "${total_price} / ${total_bottles}" ] ] ${currency}/[::msgcat::mc {Bottle}]" }
  .stats.21 configure -text "[ format "%.2f" ${twelve_price} ] ${currency}"
  .stats.31 configure -text "${twelve_bottles} [::msgcat::mc {Bottles}]"
  if { ${twelve_bottles} > {0} } { .stats.41 configure -text "[ format "%.2f" [ expr "${twelve_price} / ${twelve_bottles}" ] ] ${currency}/[::msgcat::mc {Bottle}]" }
  # 12 months country top 3
  set twelve_countries2 {}
  foreach entry ${twelve_countries} {
    if { [ lsearch -exact ${twelve_countries2} ${entry} ] == "-1" } {
      lappend twelve_countries2 1 ${entry}
    } else {
      set index [ expr "[ lsearch -exact ${twelve_countries2} ${entry} ] - 1" ]
      set value [ expr "[ lindex ${twelve_countries2} $index ] + 1" ]
      set twelve_countries2 [ lreplace ${twelve_countries2} $index $index $value ]
    }
  }
  set number {0}
  set twelve_countries [ string trimright ${twelve_countries2} ]
  set twelve_countries2 {}
  while { ${number} <= [ llength ${twelve_countries} ] } {
    set summary {}
    set field1 [ lindex ${twelve_countries} ${number} ]
    set field2 [ lindex ${twelve_countries} [ expr "${number} + 1" ] ]
    if { ${field1} != {} || ${field2} != {} } {
      lappend summary ${field1} ${field2}
      lappend twelve_countries2 ${summary}
    }
    incr number 2
  }
  set twelve_countries [ lsort -dictionary -decreasing ${twelve_countries2} ]
  if { [ llength ${twelve_countries} ] >= 1 } {
    .stats.51.0 configure -text "[ lindex [ lindex ${twelve_countries} 0 ] 1 ] "
    .stats.51.1 configure -text "([ lindex [ lindex ${twelve_countries} 0 ] 0 ] [::msgcat::mc {Bottles}])"
  }
  if { [ llength ${twelve_countries} ] >= 2 } {
    .stats.61.0 configure -text "[ lindex [ lindex ${twelve_countries} 1 ] 1 ] "
    .stats.61.1 configure -text "([ lindex [ lindex ${twelve_countries} 1 ] 0 ] [::msgcat::mc {Bottles}])"
  }
  if { [ llength ${twelve_countries} ] >= 3 } {
    .stats.71.0 configure -text "[ lindex [ lindex ${twelve_countries} 2 ] 1 ] "
    .stats.71.1 configure -text "([ lindex [ lindex ${twelve_countries} 2 ] 0 ] [::msgcat::mc {Bottles}])"
  }
  # 36 months country top 3
  set total_countries2 {}
  foreach entry ${total_countries} {
    if { [ lsearch -exact ${total_countries2} ${entry} ] == "-1" } {
      lappend total_countries2 1 ${entry}
    } else {
      set index [ expr "[ lsearch -exact ${total_countries2} ${entry} ] - 1" ]
      set value [ expr "[ lindex ${total_countries2} $index ] + 1" ]
      set total_countries2 [ lreplace ${total_countries2} $index $index $value ]
    }
  }
  set number {0}
  set total_countries [ string trimright ${total_countries2} ]
  set total_countries2 {}
  while { ${number} <= [ llength ${total_countries} ] } {
    set summary {}
    set field1 [ lindex ${total_countries} ${number} ]
    set field2 [ lindex ${total_countries} [ expr "${number} + 1" ] ]
    if { ${field1} != {} || ${field2} != {} } {
      lappend summary ${field1} ${field2}
      lappend total_countries2 ${summary}
    }
    incr number 2
  }
  set total_countries [ lsort -dictionary -decreasing ${total_countries2} ]
  if { [ llength ${total_countries} ] >= 1 } {
    .stats.52.0 configure -text "[ lindex [ lindex ${total_countries} 0 ] 1 ] "
    .stats.52.1 configure -text "([ format "%.0f" [ expr "[ lindex [ lindex ${total_countries} 0 ] 0 ] / 3" ] ] [::msgcat::mc {Bottles}])"
  }
  if { [ llength ${total_countries} ] >= 2 } {
    .stats.62.0 configure -text "[ lindex [ lindex ${total_countries} 1 ] 1 ] "
    .stats.62.1 configure -text "([ format "%.0f" [ expr "[ lindex [ lindex ${total_countries} 1 ] 0 ] / 3" ] ] [::msgcat::mc {Bottles}])"
  }
  if { [ llength ${total_countries} ] >= 3 } {
    .stats.72.0 configure -text "[ lindex [ lindex ${total_countries} 2 ] 1 ] "
    .stats.72.1 configure -text "([ format "%.0f" [ expr "[ lindex [ lindex ${total_countries} 2 ] 0 ] / 3" ] ] [::msgcat::mc {Bottles}])"
  }
  update
  if { ${view} == {yes} && ${history_out} == {yes} } { hist_out no }
}


# keyboard bindings
bind . <KeyPress-F3> { .headline.re invoke }
bind [ .list.box bodytag ] <KeyPress-F4> { .headline.ed invoke }
bind . <KeyPress-F6> { .headline.in invoke }
bind . <KeyPress-F7> { .headline.out invoke }
bind . <KeyPress-F10>    { exit }
bind . <KeyPress-Escape> { exit }
bind . <Control-Key-q>   { exit }


# startup
${show_list} yes


# pack together & show
update
pack .headline -padx 3 -pady 3 -fill x -side top
pack .list     -padx 3 -pady 3 -fill both -expand true -side top
pack .stats    -padx 3 -pady 3 -side top
pack .buttons  -padx 3 -pady 3 -fill x -side top


# update position if necessary
update
if { ${centerx} == {true} || ${centery} == {true} } {
  set ulcx3 ${ulcx}
  set ulcy3 ${ulcy}
  if { ${centerx} == {true} } { set ulcx3 [ expr "( [ winfo screenwidth  . ] - [ winfo width  . ] ) / 2" ] }
  if { ${centery} == {true} } { set ulcy3 [ expr "( [ winfo screenheight . ] - [ winfo height . ] ) / 2" ] }
  wm geometry . +${ulcx3}+${ulcy3}
}
