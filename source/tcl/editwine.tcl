# call: tclsh thisscript conffile file_id

package require Tk [ info tclversion ]
package require msgcat


# ttk
set ::bTtk 0
if { [ info tclversion ] != {8.4} } {
	package require Ttk [ info tclversion ]
	if { [ lsearch -exact [ttk::themes] {clam} ] >= 0 } {
		set sTheme clam
		ttk::setTheme ${sTheme}
	}
	set ::bTtk 1
}


set conffile [ lindex $argv 0 ]
set file_id  [ lindex $argv 1 ]
# subdir for database
set database {database}
set labelpic {labelpic}


source ${conffile}


# Tile only for the tile theme
if { ( ${onecolor} == {false} && ${colortheme} != {tile} ) || ${onecolor} != {false} } {
	set ::bTtk 0
}


# package ttips
set ttips_version {false}
catch { set ttips_version [ package require ttips ] }
if { ${ttips_version} == {false} } { lappend auto_path [ file join ${prog_dir} tcl tk ] }
package require ttips


# package conmen
set conmen_version {false}
catch { set conmen_version [ package require conmen ] }
if { ${conmen_version} == {false} } { lappend auto_path [ file join ${prog_dir} tcl tk ] }
package require conmen


# load messages
msgcat::mclocale ${nls}
msgcat::mcload [ file join ${prog_dir} nls ]


# currency - euro?
if { ${currency} == {euro} } { set currency "\u20ac" }


wm title . "[::msgcat::mc {TkWiCe Wine Editor}] - \#${file_id}"
if { [ winfo screenheight . ] < 760 } {
  wm minsize . 780 530
} else {
  wm minsize . 1000 680
}


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
set closebutton   [ image create photo -file [ file join ${prog_dir} img close.gif ] ]
set savebutton    [ image create photo -file [ file join ${prog_dir} img save.gif ] ]
set okaybutton    [ image create photo -file [ file join ${prog_dir} img okay.gif ] ]
set helpbutton    [ image create photo -file [ file join ${prog_dir} img help2.gif ] ]
set inbutton      [ image create photo -file [ file join ${prog_dir} img in.gif ] ]
set outbutton     [ image create photo -file [ file join ${prog_dir} img out.gif ] ]
set tagbutton     [ image create photo -file [ file join ${prog_dir} img tag.gif ] ]
set viewbutton    [ image create photo -file [ file join ${prog_dir} img view.gif ] ]
set l5            [ image create photo -file [ file join ${prog_dir} img l5.gif ] ]
set l51           [ image create photo -file [ file join ${prog_dir} img l51.gif ] ]
set l52           [ image create photo -file [ file join ${prog_dir} img l52.gif ] ]
set l53           [ image create photo -file [ file join ${prog_dir} img l53.gif ] ]
set l54           [ image create photo -file [ file join ${prog_dir} img l54.gif ] ]
set l55           [ image create photo -file [ file join ${prog_dir} img l55.gif ] ]
set b51           [ image create photo -file [ file join ${prog_dir} img b51.gif ] ]
set b52           [ image create photo -file [ file join ${prog_dir} img b52.gif ] ]
set b53           [ image create photo -file [ file join ${prog_dir} img b53.gif ] ]
set b54           [ image create photo -file [ file join ${prog_dir} img b54.gif ] ]
set b55           [ image create photo -file [ file join ${prog_dir} img b55.gif ] ]


# set colors
source [ file join ${prog_dir} tcl color.tcl ]
# source the option database
source [ file join ${prog_dir} tcl style.tcl ]
# additional colors
set fg ${textcolor}
set bg ${lightcolor}
# get datadir from conffile
set datadir [ file dirname ${conffile} ]
# get date
set today_year  [ clock format [ clock seconds ] -format %Y ]
set today_month [ clock format [ clock seconds ] -format %m ]
set today_day   [ clock format [ clock seconds ] -format %d ]
# take sure that we can calculate with dates
if { [string index ${today_month} 0] == "0" } {
  set today_month [string index ${today_month} 1]
}
if { [string index ${today_day} 0] == "0" } {
  set today_day [string index ${today_day} 1]
}
# list of bottlesizes
set bottlesizes {
  0.25 0.375 0.5 0.62 0.75 1.0 1.5 2.25 3.0 4.5 5.0 6.0 9.0 12.0 15.0 18.0
}
# introduce variables
set new {yes}
set litreprice {}


# if exists: delete updatefile
set updatefile [ file join ${datadir} update.lst ]
if { [ file exists ${updatefile} ] } { file delete ${updatefile} }


# source the files of the helper tools
source [ file join ${prog_dir} tcl evintner.tcl ]
source [ file join ${prog_dir} tcl egrape.tcl ]
source [ file join ${prog_dir} tcl ebio.tcl ]
source [ file join ${prog_dir} tcl eclass.tcl ]
source [ file join ${prog_dir} tcl eregion.tcl ]


# calculate points ...
proc points {} {
  global look nose finish balance impression typical weight manualpoints alcintegration
  if { ${look} != {} && ${nose} != {} && ${finish} != {} && ${balance} != {} && ${impression} != {} } {
    set pointsmin {0}
    set pointsmax {0}
    if { ${look} == {1} } {
      set lookmin {0}
      set lookmax {1}
    } elseif { ${look} == {2} } {
      set lookmin {2}
      set lookmax {4}
    } elseif { ${look} == {3} } {
      set lookmin {5}
      set lookmax {7}
    } elseif { ${look} == {4} } {
      set lookmin {8}
      set lookmax {9}
    } elseif { ${look} == {5} } {
      set lookmin {10}
      set lookmax {10}
    }
    if { ${nose} == {1} } {
      set nosemin {0}
      set nosemax {4}
    } elseif { ${nose} == {2} } {
      set nosemin {5}
      set nosemax {12}
    } elseif { ${nose} == {3} } {
      set nosemin {13}
      set nosemax {20}
    } elseif { ${nose} == {4} } {
      set nosemin {21}
      set nosemax {26}
    } elseif { ${nose} == {5} } {
      set nosemin {27}
      set nosemax {30}
    }
    if { ${finish} == {1} } {
      set finishmin {0}
      set finishmax {4}
    } elseif { ${finish} == {2} } {
      set finishmin {5}
      set finishmax {11}
    } elseif { ${finish} == {3} } {
      set finishmin {12}
      set finishmax {18}
    } elseif { ${finish} == {4} } {
      set finishmin {19}
      set finishmax {23}
    } elseif { ${finish} == {5} } {
      set finishmin {24}
      set finishmax {25}
    }
    if { ${balance} == {1} } {
      set balancemin {0}
      set balancemax {4}
    } elseif { ${balance} == {2} } {
      set balancemin {5}
      set balancemax {11}
    } elseif { ${balance} == {3} } {
      set balancemin {12}
      set balancemax {17}
    } elseif { ${balance} == {4} } {
      set balancemin {18}
      set balancemax {22}
    } elseif { ${balance} == {5} } {
      set balancemin {23}
      set balancemax {25}
    }
    if { ${impression} == {1} } {
      set impressionmin {0}
      set impressionmax {0}
    } elseif { ${impression} == {2} } {
      set impressionmin {1}
      set impressionmax {3}
    } elseif { ${impression} == {3} } {
      set impressionmin {4}
      set impressionmax {7}
    } elseif { ${impression} == {4} } {
      set impressionmin {8}
      set impressionmax {9}
    } elseif { ${impression} == {5} } {
      set impressionmin {10}
      set impressionmax {10}
    }
    set pointsmin [ expr "${lookmin} + ${nosemin} + ${finishmin} + ${balancemin} + ${impressionmin}" ]
    if { ${pointsmin} == {0} } { set pointsmin "0.1" }
    set pointsmax [ expr "${lookmax} + ${nosemax} + ${finishmax} + ${balancemax} + ${impressionmax}" ]
    while { [ expr "${pointsmax} - ${pointsmin}" ] > {3} } {
      if { ${weight} == {2} }     { set pointsmin [ expr "${pointsmin} * 1.01" ] }
      if { ${weight} == {3} }     { set pointsmin [ expr "${pointsmin} * 1.02" ] }
      if { ${weight} == {4} }     { set pointsmin [ expr "${pointsmin} * 1.03" ] }
      if { ${weight} == {5} }     { set pointsmin [ expr "${pointsmin} * 1.04" ] }
      if { ${typical} == {1} }    { set pointsmax [ expr "${pointsmax} / 1.02" ] }
      if { ${typical} == {3} }    { set pointsmin [ expr "${pointsmin} * 1.05" ] }
      if { ${typical} == {4} }    { set pointsmin [ expr "${pointsmin} * 1.10" ] }
      if { ${typical} == {5} }    { set pointsmin [ expr "${pointsmin} * 1.30" ] }
      if { ${pointsmin} > {0}   } { set pointsmin [ expr "${pointsmin} * 1.01" ] }
      if { ${pointsmax} < {100} } { set pointsmax [ expr "${pointsmax} / 1.01" ] }
    }
    if { ${pointsmax} > {100} } { set pointsmax {100} }
    if { ${alcintegration} == {1} } { set pointsmax [ expr "${pointsmax} * 0.95" ] }
    if { ${alcintegration} == {2} } { set pointsmax [ expr "${pointsmax} * 0.98" ] }
    if { ${alcintegration} == {3} } { set pointsmax [ expr "${pointsmax} * 0.99" ] }
    if { ${alcintegration} == {5} } { set pointsmax [ expr "${pointsmax} * 1.01" ] }
    if { ${pointsmax} > {100} } { set pointsmax {100} }
    set pointsmin [ expr "${pointsmax} - 3" ]
    if { ${pointsmin} < {1} } {
      set pointsmin {0}
      set pointsmax {3}
    }
    if { ${pointsmin} != {0}   } { set pointsmin [ format "%2.0f" ${pointsmin} ] }
    if { ${pointsmax} != {100} } { set pointsmax [ format "%2.0f" ${pointsmax} ] }
    if { ${pointsmin} < {10}   } { set pointsmin [ format "%1.0f" ${pointsmin} ] }
    if { ${pointsmax} < {10}   } { set pointsmax [ format "%1.0f" ${pointsmax} ] }
    if { ${pointsmin} == "97" && ${pointsmax} == {100} } {
      if { ${look} != {5} || ${nose} != {5} || ${finish} != {5} || ${balance} != {5} || ${impression} != {5} || ${alcintegration} != {5} } {
        set pointsmin "96"
        set pointsmax "99"
      }
    }
    if { ${manualpoints} == {false} } { .editright.1.labeltext.2 configure -text "([::msgcat::mc {maybe}] ${pointsmin}-${pointsmax} [::msgcat::mc {points}])" }
  } else {
    .editright.1.labeltext.2 configure -text {}
  }
}


# update litreprice if possible
proc update_litreprice {} {
  global currency litreprice size price textfont
  if { ! [ string is double ${price} ] } { set price {} }
  if { ${size} > {0} && ${price} > {0} } {
    set litreprice [ expr "${price} / ${size}" ]
    set litreprice [ format "%.2f" ${litreprice} ]
    .editright.0.price2.litreprice configure -text "(${litreprice} ${currency}/[::msgcat::mc {Litre}])"
  } else {
    .editright.0.price2.litreprice configure -text {}
  }
}


# cork quality - enable, disable
proc corkquality_state {setting} {
  global corkquality
  if { ${setting} == {enable} } {
    .editright.1.cork2.quality configure -text {} -state normal
    .editright.1.cork2.text configure -state normal
  } else {
    set corkquality {}
    .editright.1.cork2.quality configure -text {} -state disabled
    .editright.1.cork2.text configure -state disabled
  }
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


proc save {close} {
  global datadir file_id land region village domain winegrower domainnotes with_storage_id storage_id winename vineyard year barrel barrel_months grape1 percent1 grape2 percent2 grape3 percent3 grape4 percent4 grape5 percent5 color bio classification alc cork notes url next_bottle_year next_bottle_month last_bottle timelimitfactor dealer price bought_history bought_sum amount size corkquality look tint ground nose type database typical weight complex taste finish balance impression evolution evol_date fg bg today_year today_month aroma1 aroma2 bitterness sweet acid headache believable value air air_date air_decanter glass txt_look txt_nose txt_taste txt_impression prog_dir titlefont textfont old_land old_region old_village old_domain old_winename old_vineyard old_year old_grape1 old_grape2 old_grape3 old_grape4 old_grape5 old_color old_type old_bio old_price old_amount old_next_bottle old_last_bottle old_dealer old_storage_id updatefile manualpoints points_color points_luminance points_nose points_taste points_impression last_drunk alcintegration temperature tastetype bottler
  set save {true}
  # check domain
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${domain} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${domain} } {
    set domain ${tmp2}
    .editleft.0.domain2 configure -textvariable domain
  }
  # check country-code
  if { [ string length ${land} ] != {2} || ! [ string is upper ${land} ] } {
    set save {false}
    set count_flash {0}
    focus -force .editleft.0.land2.1
    while { ${count_flash} != {18} } {
      if { ${count_flash} == {0} || ${count_flash} == {2} || ${count_flash} == {4} || ${count_flash} == {6} || ${count_flash} == {8} || ${count_flash} == {10} || ${count_flash} == {12} || ${count_flash} == {14} || ${count_flash} == {16} || ${count_flash} == {18} } {
        .editleft.0.land2.1 configure -background {#cc3333} -foreground {#ffffff}
      } else {
        .editleft.0.land2.1 configure -background ${bg} -foreground ${fg}
      }
      update
      after 150
      incr count_flash
    }
  }
  # check region
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${region} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${region} } {
    set region ${tmp2}
    .editleft.0.region2 configure -textvariable region
  }
  # check village
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${village} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${village} } {
    set village ${tmp2}
    .editleft.0.village2 configure -textvariable village
  }
  # check winegrower
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${winegrower} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${winegrower} } {
    set winegrower ${tmp2}
    .editleft.0.winegrower2 configure -textvariable winegrower
  }
  # check url
  if { [ string length ${url} ] && [ string range ${url} 0 6 ] != {http://} && [ string range ${url} 0 7 ] != {https://} && [ string range ${url} 0 3 ] != {www.} } {
    set save {false}
    set count_flash {0}
    focus -force .editleft.0.url2.1
    while { ${count_flash} != {18} } {
      if { ${count_flash} == {0} || ${count_flash} == {2} || ${count_flash} == {4} || ${count_flash} == {6} || ${count_flash} == {8} || ${count_flash} == {10} || ${count_flash} == {12} || ${count_flash} == {14} || ${count_flash} == {16} || ${count_flash} == {18} } {
        .editleft.0.url2.1 configure -background {#cc3333} -foreground {#ffffff}
      } else {
        .editleft.0.url2.1 configure -background ${bg} -foreground ${fg}
      }
      update
      after 150
      incr count_flash
    }
  }
  # get domainnotes from text widget, remove blank ending-lines and check content
  set domainnotes [ .editleft.0.domainnotes2.text get 1.0 end ]
  set domainnotes [ string trimright ${domainnotes} ]
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${domainnotes} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${domainnotes} } {
    set domainnotes ${tmp2}
    .editleft.0.domainnotes2.text delete 1.0 end
    .editleft.0.domainnotes2.text insert end ${domainnotes}
  }
  # check storage_id
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${storage_id} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${storage_id} } {
    set storage_id ${tmp2}
    if { [ winfo exists .editleft.1.labeltext.4 ] } { .editleft.1.labeltext.4 configure -textvariable storage_id }
  }
  # check winename
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${winename} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${winename} } {
    set winename ${tmp2}
    .editleft.1.winename2 configure -textvariable winename
  }
  # check vineyard
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${vineyard} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${vineyard} } {
    set vineyard ${tmp2}
    .editleft.1.vineyard2 configure -textvariable vineyard
  }
  # check year
  if { ${year} != {} && ${save} != {false} } {
    if { ${year} > ${today_year} || [ string length ${year} ] != {4} || ${year} < {0} } {
      set save {false}
      set count_flash {0}
      focus -force .editleft.1.year2.year
      while { ${count_flash} != {18} } {
        if { ${count_flash} == {0} || ${count_flash} == {2} || ${count_flash} == {4} || ${count_flash} == {6} || ${count_flash} == {8} || ${count_flash} == {10} || ${count_flash} == {12} || ${count_flash} == {14} || ${count_flash} == {16} || ${count_flash} == {18} } {
          .editleft.1.year2.year configure -background {#cc3333} -foreground {#ffffff}
        } else {
          .editleft.1.year2.year configure -background ${bg} -foreground ${fg}
        }
        update
        after 150
        incr count_flash
      }
    }
  }
  # check barrel_months
  if { ${barrel} != "partial" && ${barrel} != {true} && ${barrel} != "barrique" } { set barrel_months {} }
  if { ${barrel_months} == {0} } { set barrel_months {} }
  if { ${barrel_months} != {} } {
    if { ${barrel_months} < {1} || ${barrel_months} > "999" } {
    }
  }
  # check alc
  if { ${alc} != {} && ${save} != {false} && ${alc} > "99.9" } {
    set save {false}
    set count_flash {0}
    focus -force .editleft.1.alc2.spin
    while { ${count_flash} != {18} } {
      if { ${count_flash} == {0} || ${count_flash} == {2} || ${count_flash} == {4} || ${count_flash} == {6} || ${count_flash} == {8} || ${count_flash} == {10} || ${count_flash} == {12} || ${count_flash} == {14} || ${count_flash} == {16} || ${count_flash} == {18} } {
        .editleft.1.alc2.spin configure -background {#cc3333} -foreground {#ffffff}
      } else {
        .editleft.1.alc2.spin configure -background ${bg} -foreground ${fg}
      }
      update
      after 150
      incr count_flash
    }
  }
  if { ${alc} != {} } {
    set alc2 {}
    set alc2 [ format "%.1f" ${alc} ]
    if  { [ string length ${alc2} ] != [ string length ${alc} ] } {
      set alc ${alc2}
      .editleft.1.alc2.spin configure -textvariable alc
    }
  }
  # classification
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${classification} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${classification} } {
    set classification ${tmp2}
    .editleft.1.class2.box configure -textvariable classification
  }
  # check bio
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${bio} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${bio} } {
    set bio ${tmp2}
    .editleft.1.bio2.box configure -textvariable bio
  }
  # check grape1
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${grape1} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${grape1} } {
    set grape1 ${tmp2}
    .editleft.1.grape1_2.grape1 configure -textvariable grape1
  }
  # check grape2
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${grape2} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${grape2} } {
    set grape2 ${tmp2}
    .editleft.1.grape2_2.grape2 configure -textvariable grape2
  }
  # check grape3
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${grape3} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${grape3} } {
    set grape3 ${tmp2}
    .editleft.1.grape3_2.grape3 configure -textvariable grape3
  }
  # check grape4
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${grape4} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${grape4} } {
    set grape4 ${tmp2}
    .editleft.1.grape4_2.grape4 configure -textvariable grape4
  }
  # check grape5
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${grape5} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${grape5} } {
    set grape5 ${tmp2}
    .editleft.1.grape5_2.grape5 configure -textvariable grape5
  }
  # check percent grape summary
  set percent_summary {0}
  if { ${percent1} != {} && ${save} != {false} } {
    set percent_summary ${percent1}
  }
  if { ${percent2} != {} && ${save} != {false} } {
    set percent_summary [ expr "${percent_summary} + ${percent2}" ]
  }
  if { ${percent3} != {} && ${save} != {false} } {
    set percent_summary [ expr "${percent_summary} + ${percent3}" ]
  }
  if { ${percent4} != {} && ${save} != {false} } {
    set percent_summary [ expr "${percent_summary} + ${percent4}" ]
  }
  if { ${percent5} != {} && ${save} != {false} } {
    set percent_summary [ expr "${percent_summary} + ${percent5}" ]
  }
  if { ${percent_summary} > {100} } {
    set save {false}
    set count_flash {0}
    focus -force .editleft.1.grape1_2.percent1_1
    while { ${count_flash} != {18} } {
      if { ${count_flash} == {0} || ${count_flash} == {2} || ${count_flash} == {4} || ${count_flash} == {6} || ${count_flash} == {8} || ${count_flash} == {10} || ${count_flash} == {12} || ${count_flash} == {14} || ${count_flash} == {16} || ${count_flash} == {18} } {
        if { ${percent1} != {} } { .editleft.1.grape1_2.percent1_1 configure -background {#cc3333} -foreground {#ffffff} }
        if { ${percent2} != {} } { .editleft.1.grape2_2.percent2_1 configure -background {#cc3333} -foreground {#ffffff} }
        if { ${percent3} != {} } { .editleft.1.grape3_2.percent3_1 configure -background {#cc3333} -foreground {#ffffff} }
        if { ${percent4} != {} } { .editleft.1.grape4_2.percent4_1 configure -background {#cc3333} -foreground {#ffffff} }
        if { ${percent5} != {} } { .editleft.1.grape5_2.percent5_1 configure -background {#cc3333} -foreground {#ffffff} }
      } else {
        if { ${percent1} != {} } {.editleft.1.grape1_2.percent1_1 configure -background ${bg} -foreground ${fg} }
        if { ${percent2} != {} } {.editleft.1.grape2_2.percent2_1 configure -background ${bg} -foreground ${fg} }
        if { ${percent3} != {} } {.editleft.1.grape3_2.percent3_1 configure -background ${bg} -foreground ${fg} }
        if { ${percent4} != {} } {.editleft.1.grape4_2.percent4_1 configure -background ${bg} -foreground ${fg} }
        if { ${percent5} != {} } {.editleft.1.grape5_2.percent5_1 configure -background ${bg} -foreground ${fg} }
      }
      update
      after 150
      incr count_flash
    }
  }
  # check size
  # get notes from text widget, remove blank ending-lines and check content
  set notes [ .editleft.1.notes2.text get 1.0 end ]
  set notes [ string trimright ${notes} ]
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${notes} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${notes} } {
    set notes ${tmp2}
    .editleft.1.notes2.text delete 1.0 end
    .editleft.1.notes2.text insert end ${notes}
  }
  # check dealer
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${dealer} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${dealer} } {
    set dealer ${tmp2}
    .editright.0.dealer2.text configure -textvariable dealer
  }
  # get historie from text widget, remove blank ending-lines and check content
  set bought_history [ .editright.0.history2.message get 1.0 end ]
  set bought_history [ string trimright ${bought_history} ]
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${bought_history} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${bought_history} } {
    set bought_history ${tmp2}
    .editright.0.history2.message delete 1.0 end
    .editright.0.history2.message insert end ${bought_history}
  }
  # format bought_sum
  if { ${bought_sum} == {} } { set bought_sum {0} }
  # check price
  if { ! [ string is double ${price} ] } {
    set save {false}
    set count_flash {0}
    focus -force .editright.0.price2.price
    while { ${count_flash} != {18} } {
      if { ${count_flash} == {0} || ${count_flash} == {2} || ${count_flash} == {4} || ${count_flash} == {6} || ${count_flash} == {8} || ${count_flash} == {10} || ${count_flash} == {12} || ${count_flash} == {14} || ${count_flash} == {16} || ${count_flash} == {18} } {
        .editright.0.price2.price configure -background {#cc3333} -foreground {#ffffff}
      } else {
        .editright.0.price2.price configure -background ${bg} -foreground ${fg}
      }
      update
      after 150
      incr count_flash
    }
  }
  if { ${price} != {} } {
    set price2 {}
    set price2 [ format "%.2f" ${price} ]
    if  { [ string length ${price2} ] != [ string length ${price} ] } {
      set price ${price2}
      .editright.0.price2.price configure -textvariable price
    }
  }
  # get historie from text widget, remove blank ending-lines and check content
  set drunk_history [ .editright.1.history2.message get 1.0 end ]
  set drunk_history [ string trimright ${drunk_history} ]
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${drunk_history} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${drunk_history} } {
    set drunk_history ${tmp2}
    .editright.1.history2.message delete 1.0 end
    .editright.1.history2.message insert end ${drunk_history}
  }
  # check aroma1
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${aroma1} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${aroma1} } {
    set aroma1 ${tmp2}
    .editright.1.aroma2.entry1 configure -textvariable aroma1
  }
  # check aroma2
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${aroma2} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${aroma2} } {
    set aroma2 ${tmp2}
    .editright.1.aroma2.entry2 configure -textvariable aroma2
  }
  # get txt_look from text widget, remove blank ending-lines and check content
  set txt_look [ .editright.1.text12.message get 1.0 end ]
  set txt_look [ string trimright ${txt_look} ]
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${txt_look} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${txt_look} } {
    set txt_look ${tmp2}
    .editright.1.text12.message delete 1.0 end
    .editright.1.text12.message insert end ${txt_look}
  }
  # get txt_nose from text widget, remove blank ending-lines and check content
  set txt_nose [ .editright.1.text22.message get 1.0 end ]
  set txt_nose [ string trimright ${txt_nose} ]
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${txt_nose} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${txt_nose} } {
    set txt_nose ${tmp2}
    .editright.1.text22.message delete 1.0 end
    .editright.1.text22.message insert end ${txt_nose}
  }
  # get txt_taste from text widget, remove blank ending-lines and check content
  set txt_taste [ .editright.1.text32.message get 1.0 end ]
  set txt_taste [ string trimright ${txt_taste} ]
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${txt_taste} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${txt_taste} } {
    set txt_taste ${tmp2}
    .editright.1.text32.message delete 1.0 end
    .editright.1.text32.message insert end ${txt_taste}
  }
  # get txt_impression from text widget, remove blank ending-lines and check content
  set txt_impression [ .editright.1.text42.message get 1.0 end ]
  set txt_impression [ string trimright ${txt_impression} ]
  set tmp1 {}
  set tmp2 {}
  regsub -all "\{" ${txt_impression} {[} tmp1
  regsub -all "\}" ${tmp1} {]} tmp2
  if { ${tmp2} != ${txt_impression} } {
    set txt_impression ${tmp2}
    .editright.1.text42.message delete 1.0 end
    .editright.1.text42.message insert end ${txt_impression}
  }
  # check next_bottle_month
  if { ${next_bottle_month} > {12} && ${save} != {false} } {
    set save {false}
    set count_flash {0}
    focus -force .editright.1.next_bottle2.today_month
    while { ${count_flash} != {18} } {
      if { ${count_flash} == {0} || ${count_flash} == {2} || ${count_flash} == {4} || ${count_flash} == {6} || ${count_flash} == {8} || ${count_flash} == {10} || ${count_flash} == {12} || ${count_flash} == {14} || ${count_flash} == {16} || ${count_flash} == {18} } {
        .editright.1.next_bottle2.today_month configure -background {#cc3333} -foreground {#ffffff}
      } else {
        .editright.1.next_bottle2.today_month configure -background ${bg} -foreground ${fg}
      }
      update
      after 150
      incr count_flash
    }
  }
  if { ${next_bottle_month} == {0} || ${next_bottle_month} == "00" } { set next_bottle_month {01} }
  # check next_bottle_year
  if { ${next_bottle_year} != {} && ${save} != {false} } {
    if { [ string length ${next_bottle_year} ] != {4} } {
      set save {false}
      set count_flash {0}
      focus -force .editright.1.next_bottle2.today_year
      while { ${count_flash} != {18} } {
        if { ${count_flash} == {0} || ${count_flash} == {2} || ${count_flash} == {4} || ${count_flash} == {6} || ${count_flash} == {8} || ${count_flash} == {10} || ${count_flash} == {12} || ${count_flash} == {14} || ${count_flash} == {16} || ${count_flash} == {18} } {
          .editright.1.next_bottle2.today_year configure -background {#cc3333} -foreground {#ffffff}
        } else {
          .editright.1.next_bottle2.today_year configure -background ${bg} -foreground ${fg}
        }
        update
        after 150
        incr count_flash
      }
    }
  }
  # check last_bottle
  if { ${last_bottle} != {} && ${save} != {false} } {
    if { [ string length ${last_bottle} ] != {4} } {
      set save {false}
      set count_flash {0}
      focus -force .editright.1.last_bottle2.drinkupbox
      while { ${count_flash} != {18} } {
        if { ${count_flash} == {0} || ${count_flash} == {2} || ${count_flash} == {4} || ${count_flash} == {6} || ${count_flash} == {8} || ${count_flash} == {10} || ${count_flash} == {12} || ${count_flash} == {14} || ${count_flash} == {16} || ${count_flash} == {18} } {
          .editright.1.last_bottle2.drinkupbox configure -background {#cc3333} -foreground {#ffffff}
        } else {
          .editright.1.last_bottle2.drinkupbox configure -background ${bg} -foreground ${fg}
        }
        update
        after 150
        incr count_flash
      }
    }
  }
  # check year to drink-date?
  if { ${year} != {} && ${save} != {false} } {
    if { [ string length ${last_bottle} ] == {4} && ${year} > ${last_bottle} } {
      set save {false}
      set count_flash {0}
      focus -force .editright.1.last_bottle2.drinkupbox
      while { ${count_flash} != {18} } {
        if { ${count_flash} == {0} || ${count_flash} == {2} || ${count_flash} == {4} || ${count_flash} == {6} || ${count_flash} == {8} || ${count_flash} == {10} || ${count_flash} == {12} || ${count_flash} == {14} || ${count_flash} == {16} || ${count_flash} == {18} } {
          .editright.1.last_bottle2.drinkupbox configure -background {#cc3333} -foreground {#ffffff}
          .editleft.1.year2.year configure -background {#cc3333} -foreground {#ffffff}
        } else {
          .editright.1.last_bottle2.drinkupbox configure -background ${bg} -foreground ${fg}
          .editleft.1.year2.year configure -background ${bg} -foreground ${fg}
        }
        update
        after 150
        incr count_flash
      }
    }
    if { [ string length ${next_bottle_year} ] == {4} && ${year} > ${next_bottle_year} } {
      set save {false}
      set count_flash {0}
      focus -force .editright.1.next_bottle2.today_year
      while { ${count_flash} != {18} } {
        if { ${count_flash} == {0} || ${count_flash} == {2} || ${count_flash} == {4} || ${count_flash} == {6} || ${count_flash} == {8} || ${count_flash} == {10} || ${count_flash} == {12} || ${count_flash} == {14} || ${count_flash} == {16} || ${count_flash} == {18} } {
          .editright.1.next_bottle2.today_year configure -background {#cc3333} -foreground {#ffffff}
          .editleft.1.year2.year configure -background {#cc3333} -foreground {#ffffff}
        } else {
          .editright.1.next_bottle2.today_year configure -background ${bg} -foreground ${fg}
          .editleft.1.year2.year configure -background ${bg} -foreground ${fg}
        }
        update
        after 150
        incr count_flash
      }
    }
  }
  # build and format next_bottle
  if { [ string length ${next_bottle_month} ] == {1} } {
    set next_bottle_month [ format "%2.2d" ${next_bottle_month} ]
  }
  if { [ string length ${next_bottle_year} ] == {1} || [ string length ${next_bottle_year} ] == {2} || [ string length ${next_bottle_year} ] == {3} } {
    set next_bottle_year  [ format "%4.4d" ${next_bottle_year} ]
  }
  if { ${next_bottle_year} == {} } {
    set next_bottle {}
  } else {
    if { ${next_bottle_month} == {} } { set next_bottle_month {01} }
    set next_bottle "${next_bottle_year}-${next_bottle_month}"
  }
  # check for last_drunk
  if { ! [ info exists last_drunk ] } { set last_drunk {} }
  # write file
  if { ${save} == {true} } {
    set initchannel [ open [ file join ${datadir} ${database} ${file_id} ] w ]
    puts ${initchannel} "set land \{${land}\}"
    puts ${initchannel} "set region \{${region}\}"
    puts ${initchannel} "set village \{${village}\}"
    puts ${initchannel} "set domain \{${domain}\}"
    puts ${initchannel} "set winegrower \{${winegrower}\}"
    puts ${initchannel} "set domainnotes \{${domainnotes}\}"
    puts ${initchannel} "set storage_id \{${storage_id}\}"
    puts ${initchannel} "set winename \{${winename}\}"
    puts ${initchannel} "set vineyard \{${vineyard}\}"
    puts ${initchannel} "set year \{${year}\}"
    puts ${initchannel} "set barrel \{${barrel}\}"
    puts ${initchannel} "set barrel_months \{${barrel_months}\}"
    puts ${initchannel} "set grape1 \{${grape1}\}"
    puts ${initchannel} "set percent1 \{${percent1}\}"
    puts ${initchannel} "set grape2 \{${grape2}\}"
    puts ${initchannel} "set percent2 \{${percent2}\}"
    puts ${initchannel} "set grape3 \{${grape3}\}"
    puts ${initchannel} "set percent3 \{${percent3}\}"
    puts ${initchannel} "set grape4 \{${grape4}\}"
    puts ${initchannel} "set percent4 \{${percent4}\}"
    puts ${initchannel} "set grape5 \{${grape5}\}"
    puts ${initchannel} "set percent5 \{${percent5}\}"
    puts ${initchannel} "set bottler \{${bottler}\}"
    puts ${initchannel} "set color \{${color}\}"
    puts ${initchannel} "set type \{${type}\}"
    puts ${initchannel} "set bio \{${bio}\}"
    puts ${initchannel} "set classification \{${classification}\}"
    puts ${initchannel} "set alc \{${alc}\}"
    puts ${initchannel} "set size \{${size}\}"
    puts ${initchannel} "set cork \{${cork}\}"
    puts ${initchannel} "set corkquality \{${corkquality}\}"
    puts ${initchannel} "set look \{${look}\}"
    puts ${initchannel} "set tint \{${tint}\}"
    puts ${initchannel} "set ground \{${ground}\}"
    puts ${initchannel} "set notes \{${notes}\}"
    puts ${initchannel} "set url \{${url}\}"
    puts ${initchannel} "set drunk_history \{${drunk_history}\}"
    puts ${initchannel} "set dealer \{${dealer}\}"
    puts ${initchannel} "set price \{${price}\}"
    puts ${initchannel} "set bought_history \{${bought_history}\}"
    puts ${initchannel} "set bought_sum \{${bought_sum}\}"
    puts ${initchannel} "set amount \{${amount}\}"
    puts ${initchannel} "set nose \{${nose}\}"
    puts ${initchannel} "set typical \{${typical}\}"
    puts ${initchannel} "set weight \{${weight}\}"
    puts ${initchannel} "set complex \{${complex}\}"
    puts ${initchannel} "set alcintegration \{${alcintegration}\}"
    puts ${initchannel} "set finish \{${finish}\}"
    puts ${initchannel} "set balance \{${balance}\}"
    puts ${initchannel} "set impression \{${impression}\}"
    puts ${initchannel} "set tastetype \{${tastetype}\}"
    puts ${initchannel} "set aroma1 \{${aroma1}\}"
    puts ${initchannel} "set aroma2 \{${aroma2}\}"
    puts ${initchannel} "set bitterness \{${bitterness}\}"
    puts ${initchannel} "set acid \{${acid}\}"
    puts ${initchannel} "set sweet \{${sweet}\}"
    puts ${initchannel} "set headache \{${headache}\}"
    puts ${initchannel} "set believable \{${believable}\}"
    puts ${initchannel} "set evolution \{${evolution}\}"
    puts ${initchannel} "set evol_date \{${evol_date}\}"
    puts ${initchannel} "set value \{${value}\}"
    puts ${initchannel} "set air \{${air}\}"
    puts ${initchannel} "set air_date \{${air_date}\}"
    puts ${initchannel} "set air_decanter \{${air_decanter}\}"
    puts ${initchannel} "set glass \{${glass}\}"
    puts ${initchannel} "set temperature \{${temperature}\}"
    puts ${initchannel} "set next_bottle \{${next_bottle}\}"
    puts ${initchannel} "set last_bottle \{${last_bottle}\}"
    puts ${initchannel} "set timelimitfactor \{${timelimitfactor}\}"
    puts ${initchannel} "set last_drunk \{${last_drunk}\}"
    puts ${initchannel} "set txt_look \{${txt_look}\}"
    puts ${initchannel} "set txt_nose \{${txt_nose}\}"
    puts ${initchannel} "set txt_taste \{${txt_taste}\}"
    puts ${initchannel} "set txt_impression \{${txt_impression}\}"
    puts ${initchannel} "set manualpoints \{${manualpoints}\}"
    puts ${initchannel} "set points_color \{${points_color}\}"
    puts ${initchannel} "set points_luminance \{${points_luminance}\}"
    puts ${initchannel} "set points_nose \{${points_nose}\}"
    puts ${initchannel} "set points_taste \{${points_taste}\}"
    puts ${initchannel} "set points_impression \{${points_impression}\}"
    puts ${initchannel} "set last_modified_secondsdate \{[ clock seconds ]\}"
    close ${initchannel}
    # check what is changed and write updatefile if necessary
    set update_winelist {false}
    if { ${old_land} != ${land} || \
         ${old_region} != ${region} || \
         ${old_village} != ${village} || \
         ${old_domain} != ${domain} || \
         ${old_winename} != ${winename} || \
         ${old_vineyard} != ${vineyard} || \
         ${old_year} != ${year} || \
         ${old_grape1} != ${grape1} || \
         ${old_grape2} != ${grape2} || \
         ${old_grape3} != ${grape3} || \
         ${old_grape4} != ${grape4} || \
         ${old_grape5} != ${grape5} || \
         ${old_color} != ${color} || \
         ${old_type} != ${type} || \
         ${old_bio} != ${bio} || \
         ${old_price} != ${price} || \
         ${old_amount} != ${amount} || \
         ${old_next_bottle} != ${next_bottle} || \
         ${old_last_bottle} != ${last_bottle} || \
         ${old_storage_id} != ${storage_id} } {
      set update_winelist {true}
    }
    if { ${update_winelist} == {true} } {
      set initchannel [ open ${updatefile} w ]
      puts ${initchannel} {list in main window needs to be rescanned}
      close ${initchannel}
    }
    # do we have a new dealer?
    # first: get list from vintner-file
    set vintnerlist {}
    set dealerlist {}
    set dealerfile [ file join ${datadir} dealer ]
    set tmpdealerlist {}
    if {[ file exists ${dealerfile}]} {
      # get dealerlist from file
      set initchannel [ open ${dealerfile} r ]
      set dealerlist2 [ read -nonewline ${initchannel} ]
      close ${initchannel}
      if {[ llength ${dealerlist2} ] > {0}} {
        # convert dealerlist2 to dealerlist
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
        # build up a temporary list with first items
        foreach entry ${dealerlist} {
          lappend tmpdealerlist [ lindex ${entry} 0 ]
        }
      }
    }
    if {[ lsearch -exact ${tmpdealerlist} ${dealer} ] == {-1}} {
      # add dealer to the dealer database
      set newlistitem {}
      lappend newlistitem ${dealer}
      lappend newlistitem {}
      lappend dealerlist ${newlistitem}
      set dealerlist [ lsort -index 0 -dictionary ${dealerlist} ]
      # write it to file
      set dealerfile [ file join ${datadir} dealer ]
      set initchannel [ open ${dealerfile} w ]
      foreach entry ${dealerlist} {
        if { [ lindex ${entry} 0 ] != {} } {
          puts ${initchannel} ${entry}
        }
      }
      close ${initchannel}
    }
    # close the window?
    if { ${close} == {close} } {
      exit
    } else {
      .menu.exit configure -text [::msgcat::mc {Close}]
    }
  }
}


proc colorchange {tint} {
  if { ${tint} == "Garnet" } {
    set tint_text [::msgcat::mc {Garnet}]
    .editright.1.tint2.button       configure -background "#ba4a00" -foreground {#ffffff} -text ${tint_text}
  } elseif { ${tint} == "Brick" } {
    set tint_text [::msgcat::mc {Brick}]
    .editright.1.tint2.button       configure -background "#a31000" -foreground {#ffffff} -text ${tint_text}
  } elseif { ${tint} == "Purple" } {
    set tint_text [::msgcat::mc {Purple}]
    .editright.1.tint2.button       configure -background "#910011" -foreground {#ffffff} -text ${tint_text}
  } elseif { ${tint} == "Cherry" } {
    set tint_text [::msgcat::mc {Cherry}]
    .editright.1.tint2.button       configure -background "#780018" -foreground {#ffffff} -text ${tint_text}
  } elseif { ${tint} == "Ruby" } {
    set tint_text [::msgcat::mc {Ruby}]
    .editright.1.tint2.button       configure -background "#6e0010" -foreground {#ffffff} -text ${tint_text}
  } elseif { ${tint} == "Black" } {
    set tint_text [::msgcat::mc {Black}]
    .editright.1.tint2.button       configure -background "#540012" -foreground {#ffffff} -text ${tint_text}
  } elseif { ${tint} == "Bright" } {
    set tint_text [::msgcat::mc {Bright}]
    .editright.1.tint2.button       configure -background "#fcffe8" -foreground "#000000" -text ${tint_text}
  } elseif { ${tint} == "Straw" } {
    set tint_text [::msgcat::mc {Straw}]
    .editright.1.tint2.button       configure -background "#fcffcc" -foreground "#000000" -text ${tint_text}
  } elseif { ${tint} == "Citron" } {
    set tint_text [::msgcat::mc {Citron}]
    .editright.1.tint2.button       configure -background "#fffeb3" -foreground "#000000" -text ${tint_text}
  } elseif { ${tint} == "Gold" } {
    set tint_text [::msgcat::mc {Gold}]
    .editright.1.tint2.button       configure -background "#fff88f" -foreground "#000000" -text ${tint_text}
  } elseif { ${tint} == "Oldgold" } {
    set tint_text [::msgcat::mc {Oldgold}]
    .editright.1.tint2.button       configure -background "#ffed75" -foreground "#000000" -text ${tint_text}
  } elseif { ${tint} == "Amber" } {
    set tint_text [::msgcat::mc {Amber}]
    .editright.1.tint2.button       configure -background "#ffe666" -foreground "#000000" -text ${tint_text}
  } elseif { ${tint} == "Russet" } {
    set tint_text [::msgcat::mc {Russet}]
    .editright.1.tint2.button       configure -background "#ffd6b5" -foreground "#000000" -text ${tint_text}
  } elseif { ${tint} == "Salmon" } {
    set tint_text [::msgcat::mc {Salmon}]
    .editright.1.tint2.button       configure -background "#ffc5b8" -foreground "#000000" -text ${tint_text}
  } elseif { ${tint} == "Pinkish" } {
    set tint_text [::msgcat::mc {Pinkish}]
    .editright.1.tint2.button       configure -background "#ffa091" -foreground "#000000" -text ${tint_text}
  }
}


# set blank values
set land {}
set region {}
set village {}
set domain {}
set winegrower {}
set domainnotes {}
set storage_id {}
set winename {}
set vineyard {}
set year [ expr "${today_year} -1" ]
set barrel {}
set barrel_months {}
set color {Red}
set type {Normal}
set bio {}
set classification {}
set alc {}
set grape1 {}
set percent1 {}
set grape2 {}
set percent2 {}
set grape3 {}
set percent3 {}
set grape4 {}
set percent4 {}
set grape5 {}
set percent5 {}
set bottler {}
set size {0.75}
set notes {}
set url {}
set drunk_history {}
set next_bottle {}
set last_bottle {}
set last_drunk {}
set timelimitfactor {}
set dealer {}
set price {}
set bought_history {}
set bought_sum {0}
set amount {0}
set cork {}
set corkquality {}
set look {}
set tint {}
set ground {}
set nose {}
set typical {}
set weight {}
set complex {}
set finish {}
set balance {}
set tastetype {}
set aroma1 {}
set aroma2 {}
set impression {}
set bitterness {}
set acid {}
set sweet {}
set alcintegration {}
set headache {}
set believable {}
set evolution {}
set evol_date {}
set air {}
set air_date {}
set air_decanter {}
set glass {}
set value {}
set txt_look {}
set txt_nose {}
set txt_taste {}
set txt_impression {}
set points_color {0}
set points_luminance {0}
set points_nose {0}
set points_taste {0}
set points_impression {0}
set temperature {}


# if filenumber exists, read values and overwrite defaults
if { [ file exists [ file join ${datadir} ${database} ${file_id} ] ] } {
  source [ file join ${datadir} ${database} ${file_id} ]
  set new {no}
}


# backup some settings to evaluate later if winelsit needs to be updated
set old_land ${land}
set old_region ${region}
set old_village ${village}
set old_domain ${domain}
set old_winename ${winename}
set old_vineyard ${vineyard}
set old_year ${year}
set old_grape1 ${grape1}
set old_grape2 ${grape2}
set old_grape3 ${grape3}
set old_grape4 ${grape4}
set old_grape5 ${grape5}
set old_color ${color}
set old_type ${type}
set old_bio ${bio}
set old_dealer ${dealer}
set old_price ${price}
set old_amount ${amount}
set old_next_bottle ${next_bottle}
set old_last_bottle ${last_bottle}
set old_storage_id ${storage_id}


# load Img if available
set img_version {false}
catch { set img_version [ package require Img ] }
# set up a basic graphic
set picture [ image create photo -width 100 -height 166 ]
# if correspondig graphic exist ....
if { ${img_version} != {false} && [ file exists [ file join ${datadir} ${labelpic} ${file_id}.jpg ] ] } {
  set picture2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.jpg ] -width 300 -height 500 ]
  $picture blank
  $picture copy $picture2 -subsample 3 3
} elseif { ${img_version} != {false} && [ file exists [ file join ${datadir} ${labelpic} ${file_id}.JPG ] ] } {
  set picture2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.JPG ] -width 300 -height 500 ]
  $picture blank
  $picture copy $picture2 -subsample 3 3
} elseif { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.gif ] ] } {
  set picture2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.gif ] -width 300 -height 500 ]
  $picture blank
  $picture copy $picture2 -subsample 3 3
} elseif { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.GIF ] ] } {
  set picture2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.GIF ] -width 300 -height 500 ]
  $picture blank
  $picture copy $picture2 -subsample 3 3
} else {
  set picture [ image create photo -file [ file join ${prog_dir} img nop.gif ] -width 100 -height 166 ]
}


# date menus
# menu day
set setdaymenu [ menu .daymenu -tearoff 0 ]
${setdaymenu} add command -label {01} -command { ${daywidget} set {01} }
${setdaymenu} add command -label {02} -command { ${daywidget} set {02} }
${setdaymenu} add command -label {03} -command { ${daywidget} set {03} }
${setdaymenu} add command -label {04} -command { ${daywidget} set {04} }
${setdaymenu} add command -label {05} -command { ${daywidget} set {05} }
${setdaymenu} add command -label {06} -command { ${daywidget} set {06} }
${setdaymenu} add command -label {07} -command { ${daywidget} set {07} }
${setdaymenu} add command -label {08} -command { ${daywidget} set {08} }
${setdaymenu} add command -label {09} -command { ${daywidget} set {09} }
${setdaymenu} add command -label {10} -command { ${daywidget} set {10} }
${setdaymenu} add command -label {11} -command { ${daywidget} set {11} }
${setdaymenu} add command -label {12} -command { ${daywidget} set {12} }
${setdaymenu} add command -label {13} -command { ${daywidget} set {13} }
${setdaymenu} add command -label {14} -command { ${daywidget} set {14} }
${setdaymenu} add command -label {15} -command { ${daywidget} set {15} }
${setdaymenu} add command -label {16} -command { ${daywidget} set {16} }
${setdaymenu} add command -label {17} -command { ${daywidget} set {17} }
${setdaymenu} add command -label {18} -command { ${daywidget} set {18} }
${setdaymenu} add command -label {19} -command { ${daywidget} set {19} }
${setdaymenu} add command -label {20} -command { ${daywidget} set {20} }
${setdaymenu} add command -label {21} -command { ${daywidget} set {21} }
${setdaymenu} add command -label {22} -command { ${daywidget} set {22} }
${setdaymenu} add command -label {23} -command { ${daywidget} set {23} }
${setdaymenu} add command -label {24} -command { ${daywidget} set {24} }
${setdaymenu} add command -label {25} -command { ${daywidget} set {25} }
${setdaymenu} add command -label {26} -command { ${daywidget} set {26} }
${setdaymenu} add command -label {27} -command { ${daywidget} set {27} }
${setdaymenu} add command -label {28} -command { ${daywidget} set {28} }
${setdaymenu} add command -label {29} -command { ${daywidget} set {29} }
${setdaymenu} add command -label {30} -command { ${daywidget} set {30} }
${setdaymenu} add command -label {31} -command { ${daywidget} set {31} }
if { ${today_day} < 10  && [ string lengt ${today_day}] > 1 } {
  ${setdaymenu} entryconfigure [ expr "[ string index ${today_day} 1 ] - 1" ] -font ${titlefont}
} else {
  ${setdaymenu} entryconfigure [ expr "${today_day} - 1" ] -font ${titlefont}
}
# menu month
set setmonthmenu [ menu .monthmenu -tearoff 0 ]
${setmonthmenu} add command -label "01 - [::msgcat::mc {January}]"   -command { ${monthwidget} set {01} }
${setmonthmenu} add command -label "02 - [::msgcat::mc {February}]"  -command { ${monthwidget} set {02} }
${setmonthmenu} add command -label "03 - [::msgcat::mc {March}]"     -command { ${monthwidget} set {03} }
${setmonthmenu} add command -label "04 - [::msgcat::mc {April}]"     -command { ${monthwidget} set {04} }
${setmonthmenu} add command -label "05 - [::msgcat::mc {May}]"       -command { ${monthwidget} set {05} }
${setmonthmenu} add command -label "06 - [::msgcat::mc {June}]"      -command { ${monthwidget} set {06} }
${setmonthmenu} add command -label "07 - [::msgcat::mc {July}]"      -command { ${monthwidget} set {07} }
${setmonthmenu} add command -label "08 - [::msgcat::mc {August}]"    -command { ${monthwidget} set {08} }
${setmonthmenu} add command -label "09 - [::msgcat::mc {September}]" -command { ${monthwidget} set {09} }
${setmonthmenu} add command -label "10 - [::msgcat::mc {October}]"   -command { ${monthwidget} set {10} }
${setmonthmenu} add command -label "11 - [::msgcat::mc {November}]"  -command { ${monthwidget} set {11} }
${setmonthmenu} add command -label "12 - [::msgcat::mc {December}]"  -command { ${monthwidget} set {12} }
if { ${today_month} < 10 && [ string lengt ${today_month}] > 1 } {
  ${setmonthmenu} entryconfigure [ expr "[ string index ${today_month} 1 ] - 1" ] -font ${titlefont}
} else {
  ${setmonthmenu} entryconfigure [ expr "${today_month} - 1" ] -font ${titlefont}
}
# menu year
set setyearmenu [ menu .setyearmenu -tearoff 0 ]
${setyearmenu} add command -label [ expr "${today_year} - 4"  ]    -command { ${yearwidget} set [ expr "${today_year} - 4"  ] }
${setyearmenu} add command -label [ expr "${today_year} - 3"  ]    -command { ${yearwidget} set [ expr "${today_year} - 3"  ] }
${setyearmenu} add command -label [ expr "${today_year} - 2"  ]    -command { ${yearwidget} set [ expr "${today_year} - 2"  ] }
${setyearmenu} add command -label [ expr "${today_year} - 1"  ]    -command { ${yearwidget} set [ expr "${today_year} - 1"  ] }
${setyearmenu} add command -label ${today_year} -font ${titlefont} -command { ${yearwidget} set ${today_year} }
${setyearmenu} add command -label [ expr "${today_year} + 1"  ]    -command { ${yearwidget} set [ expr "${today_year} + 1"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 2"  ]    -command { ${yearwidget} set [ expr "${today_year} + 2"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 3"  ]    -command { ${yearwidget} set [ expr "${today_year} + 3"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 4"  ]    -command { ${yearwidget} set [ expr "${today_year} + 4"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 5"  ]    -command { ${yearwidget} set [ expr "${today_year} + 5"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 6"  ]    -command { ${yearwidget} set [ expr "${today_year} + 6"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 7"  ]    -command { ${yearwidget} set [ expr "${today_year} + 7"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 8"  ]    -command { ${yearwidget} set [ expr "${today_year} + 8"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 9"  ]    -command { ${yearwidget} set [ expr "${today_year} + 9"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 10"  ]   -command { ${yearwidget} set [ expr "${today_year} + 10"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 11"  ]   -command { ${yearwidget} set [ expr "${today_year} + 11"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 12"  ]   -command { ${yearwidget} set [ expr "${today_year} + 12"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 13"  ]   -command { ${yearwidget} set [ expr "${today_year} + 13"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 14"  ]   -command { ${yearwidget} set [ expr "${today_year} + 14"  ] }
${setyearmenu} add command -label [ expr "${today_year} + 15"  ]   -command { ${yearwidget} set [ expr "${today_year} + 15"  ] }


frame .editleft
if { $::bTtk } {
	ttk::labelframe .editleft.0 -text [::msgcat::mc {Winery}]
} else {
	labelframe .editleft.0 -text [::msgcat::mc {Winery}] -padx 2 -pady 2
}

label .editleft.0.domain1 -text "[::msgcat::mc {Winery}] " -font ${titlefont} -anchor w
grid  .editleft.0.domain1 -column 0 -row 0 -sticky w
entry .editleft.0.domain2 -textvariable domain -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
grid  .editleft.0.domain2 -column 1 -row 0 -sticky we
::conmen .editleft.0.domain2

label  .editleft.0.land1 -text "[::msgcat::mc {Country Macro}] " -font ${titlefont} -anchor w
grid   .editleft.0.land1 -column 0 -row 1 -sticky w
frame  .editleft.0.land2
  entry  .editleft.0.land2.1 -textvariable land -width 3 -background ${lightcolor} -validate key -vcmd { expr { [ string is upper %P ] && [ string length %P ] < 3 } }
  label  .editleft.0.land2.2 -text {} -anchor w
  button .editleft.0.land2.3 -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -command { help_region }
  pack .editleft.0.land2.1 -side left
  pack .editleft.0.land2.2 -side left -fill x -expand true
  pack .editleft.0.land2.3 -side left
grid   .editleft.0.land2 -column 1 -row 1 -sticky we
::conmen .editleft.0.land2.1
.editleft.0.land2.1.conmen add separator
.editleft.0.land2.1.conmen add command -label [::msgcat::mc {choose}] -command { help_region }

label .editleft.0.region1 -text "[::msgcat::mc {Growing Area}] " -font ${titlefont} -anchor w
grid  .editleft.0.region1 -column 0 -row 2 -sticky w
frame .editleft.0.region2
  entry .editleft.0.region2.1 -textvariable region -width 35 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
  button .editleft.0.region2.2 -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -command { help_region }
  pack .editleft.0.region2.1 -side left -fill x -expand true
  pack .editleft.0.region2.2 -side left
grid  .editleft.0.region2 -column 1 -row 2 -sticky we
::conmen .editleft.0.region2.1
.editleft.0.region2.1.conmen add separator
.editleft.0.region2.1.conmen add command -label [::msgcat::mc {choose}] -command { help_region }

label .editleft.0.village1 -text "[::msgcat::mc {Sub-Region}] " -font ${titlefont} -anchor w
grid  .editleft.0.village1 -column 0 -row 3 -sticky w
frame .editleft.0.village2
  entry .editleft.0.village2.1 -textvariable village -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
  button .editleft.0.village2.2 -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -command { help_region }
  pack .editleft.0.village2.1 -side left -fill x -expand true
  pack .editleft.0.village2.2 -side left
grid  .editleft.0.village2 -column 1 -row 3 -sticky we
::conmen .editleft.0.village2.1
.editleft.0.village2.1.conmen add separator
.editleft.0.village2.1.conmen add command -label [::msgcat::mc {choose}] -command { help_region }

label .editleft.0.winegrower1 -text "[::msgcat::mc {Winegrower}] " -font ${titlefont} -anchor w
grid  .editleft.0.winegrower1 -column 0 -row 4 -sticky w
entry .editleft.0.winegrower2 -textvariable winegrower -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
grid  .editleft.0.winegrower2 -column 1 -row 4 -sticky we
::conmen .editleft.0.winegrower2

label .editleft.0.url1 -text "[::msgcat::mc {Internet}] " -font ${titlefont} -anchor w
grid  .editleft.0.url1 -column 0 -row 5 -sticky w
frame .editleft.0.url2
  entry .editleft.0.url2.1 -textvariable url -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
pack .editleft.0.url2.1 -side left -fill x -expand true
  menubutton .editleft.0.url2.2 -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editleft.0.url2.2.menu
  set urlmenu [ menu .editleft.0.url2.2.menu -tearoff 0 -postcommand {
    ${urlmenu} delete 0 1
    set selget {}
    catch { set selget [ selection get ] }
    if { [ string range ${selget} 0 6 ] == {http://} || [ string range ${selget} 0 7 ] == {https://} || [ string range ${selget} 0 3 ] == {www.} } {
      ${urlmenu} add command -label [::msgcat::mc {paste}] -command { set url ${selget} }
    } else {
      ${urlmenu} add command -label [::msgcat::mc {paste}] -state disabled
    }
    if { [ string range ${url} 0 6 ] == {http://} || [ string range ${url} 0 7 ] == {https://} || [ string range ${url} 0 3 ] == {www.} } {
      ${urlmenu} add command -label [::msgcat::mc {open}] -command { if { ${webbrowser} != {} && ${url} != {} } { catch { exec "${webbrowser}" ${url} } } }
    } else {
      ${urlmenu} add command -label [::msgcat::mc {open}] -state disabled
    }
  } ]
  ${urlmenu} add command -label [::msgcat::mc {paste}] -state disabled
  ${urlmenu} add command -label [::msgcat::mc {open}] -state disabled
pack .editleft.0.url2.2 -side left
grid  .editleft.0.url2 -column 1 -row 5 -sticky we
::conmen .editleft.0.url2.1
.editleft.0.url2.1.conmen add separator
.editleft.0.url2.1.conmen add command -label [::msgcat::mc {open}] -command {
  if { [ string range ${url} 0 6 ] == {http://} || [ string range ${url} 0 7 ] == {https://} || [ string range ${url} 0 3 ] == {www.} } {
    if { ${webbrowser} != {} && ${url} != {} } { catch { exec "${webbrowser}" ${url} } }
  }
}

label .editleft.0.domainnotes1 -text "[::msgcat::mc {Various}] " -font ${titlefont} -anchor w
grid  .editleft.0.domainnotes1 -column 0 -row 6 -sticky nw
frame .editleft.0.domainnotes2
text  .editleft.0.domainnotes2.text -wrap word -width 35 -height 3 -background ${lightcolor} -yscrollcommand ".editleft.0.domainnotes2.scroll set"
if { $::bTtk } {
	ttk::scrollbar .editleft.0.domainnotes2.scroll -command ".editleft.0.domainnotes2.text yview"
} else {
	scrollbar .editleft.0.domainnotes2.scroll -command ".editleft.0.domainnotes2.text yview"
}
.editleft.0.domainnotes2.text insert end ${domainnotes}
pack  .editleft.0.domainnotes2.text   -side left  -fill both -expand true
pack  .editleft.0.domainnotes2.scroll -side right -fill y
grid  .editleft.0.domainnotes2 -column 1 -row 6 -sticky news
::conmen .editleft.0.domainnotes2.text


frame .editleft.blank -height 4


if { $::bTtk } {
	ttk::labelframe .editleft.1
} else {
	labelframe .editleft.1 -padx 2 -pady 2
}
frame      .editleft.1.labeltext
  label    .editleft.1.labeltext.1 -text "[::msgcat::mc {Wine}] | " 
  label    .editleft.1.labeltext.2 -text [::msgcat::mc {storage ID}] -font ${smallfont}
  entry    .editleft.1.labeltext.3 -textvariable storage_id -width 6 -borderwidth 1 -background ${lightcolor} -font ${smallfont} -validate key -vcmd { checktext %W %v %i %S }
  ::conmen .editleft.1.labeltext.3
pack .editleft.1.labeltext.1 -side left
pack .editleft.1.labeltext.2 -side left
pack .editleft.1.labeltext.3 -side left
.editleft.1 configure -labelwidget .editleft.1.labeltext


label .editleft.1.winename1 -text "[::msgcat::mc {Name}] " -font ${titlefont} -anchor w
grid  .editleft.1.winename1 -column 0 -row 0 -sticky w
entry .editleft.1.winename2 -textvariable winename -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
grid  .editleft.1.winename2 -column 1 -row 0 -sticky we -columnspan 2
::conmen .editleft.1.winename2

label .editleft.1.vineyard1 -text "[::msgcat::mc {Vineyard}] " -font ${titlefont} -anchor w
grid  .editleft.1.vineyard1 -column 0 -row 1 -sticky w
entry .editleft.1.vineyard2 -textvariable vineyard -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
grid  .editleft.1.vineyard2 -column 1 -row 1 -sticky we -columnspan 2
::conmen .editleft.1.vineyard2

label .editleft.1.color1 -text "[::msgcat::mc {Color}]/[::msgcat::mc {Type}] " -font ${titlefont} -anchor w
grid .editleft.1.color1 -column 0 -row 2 -sticky w
frame .editleft.1.color2
  # Color
  if { [ string length [::msgcat::mc {Red}] ] > [ string length [::msgcat::mc {White}] ] } {
    set typelength [ string length [::msgcat::mc {Red}] ]
  } else {
    set typelength [ string length [::msgcat::mc {White}] ]
  }
  if { [ string length [::msgcat::mc "Ros\u00e9"] ] > ${typelength} } {
    set typelength [ string length [::msgcat::mc "Ros\u00e9"] ]
  }
  if { [ string length [::msgcat::mc {Colorless}] ] > ${typelength} } {
    set typelength [ string length [::msgcat::mc {Colorless}] ]
  }
  menubutton .editleft.1.color2.color -menu .editleft.1.color2.color.menu -relief sunken -borderwidth 2 -background ${lightcolor} -padx 1 -pady 1 -width ${typelength} -anchor w
  set colormenu [ menu .editleft.1.color2.color.menu -tearoff 0 ]
  ${colormenu} add command -label [::msgcat::mc {Red}] -command {
    set color {Red}
    .editleft.1.color2.color configure -text [::msgcat::mc {Red}]
    .editright.1.tint2.button configure -menu .editright.1.tint2.button.tintmenured
    .editright.1.tint2.button configure -state normal
    .editright.1.tint1        configure -state normal
  }
  ${colormenu} add command -label [::msgcat::mc {White}] -command {
    set color {White}
    .editleft.1.color2.color configure -text [::msgcat::mc {White}]
    .editright.1.tint2.button configure -menu .editright.1.tint2.button.tintmenuwhite
    .editright.1.tint2.button configure -state normal
    .editright.1.tint1        configure -state normal
  }
  ${colormenu} add command -label [::msgcat::mc "Ros\u00e9"] -command {
    set color "Ros\u00e9"
    .editleft.1.color2.color configure -text [::msgcat::mc "Ros\u00e9"]
    .editright.1.tint2.button configure -menu .editright.1.tint2.button.tintmenurose
    .editright.1.tint2.button configure -state normal
    .editright.1.tint1        configure -state normal
  }
  ${colormenu} add command -label [::msgcat::mc {Colorless}] -command {
    set color {Colorless}
    .editleft.1.color2.color configure -text [::msgcat::mc {Colorless}]
    .editright.1.tint2.button configure -state disabled
    .editright.1.tint1        configure -state disabled
  }
  if { ${color} == "Ros\u00e9" } {
    .editleft.1.color2.color configure -text [::msgcat::mc "Ros\u00e9"]
  } elseif { ${color} == {White} } {
    .editleft.1.color2.color configure -text [::msgcat::mc {White}]
  } elseif { ${color} == {Colorless} } {
    .editleft.1.color2.color configure -text [::msgcat::mc {Colorless}]
  } else {
    .editleft.1.color2.color configure -text [::msgcat::mc {Red}]
  }
  grid .editleft.1.color2.color -column 1 -row 3 -sticky w
  bind .editleft.1.color2.color <Button-3> { tk_popup ${colormenu} %X %Y }
  # Space
  label .editleft.1.color2.space -text { }
  # Type
  if { [ string length [::msgcat::mc {Still}] ] > [ string length [::msgcat::mc {Frizzante}] ] } {
    set typelength [ string length [::msgcat::mc {Still}] ]
  } else {
    set typelength [ string length [::msgcat::mc {Frizzante}] ]
  }
  if { [ string length [::msgcat::mc {Sparkling}] ] > ${typelength} } {
    set typelength [ string length [::msgcat::mc {Sparkling}] ]
  }
#  if { [ string length [::msgcat::mc {Port}] ] > ${typelength} } {
#    set typelength [ string length [::msgcat::mc {Port}] ]
#  }
  if { [ string length [::msgcat::mc {Fortified Wine}] ] > ${typelength} } {
    set typelength [ string length [::msgcat::mc {Fortified Wine}] ]
  }
  if { [ string length [::msgcat::mc {Liqueur}] ] > ${typelength} } {
    set typelength [ string length [::msgcat::mc {Liqueur}] ]
  }
  if { [ string length [::msgcat::mc {Distilled}] ] > ${typelength} } {
    set typelength [ string length [::msgcat::mc {Distilled}] ]
  }
  menubutton .editleft.1.color2.type -menu .editleft.1.color2.type.menu -relief sunken -borderwidth 2 -background ${lightcolor} -padx 1 -pady 1 -width ${typelength} -anchor w
  set typemenu [ menu .editleft.1.color2.type.menu -tearoff 0 ]
  ${typemenu} add command -label [::msgcat::mc {Still}] -command {
    set type {Normal}
    .editleft.1.color2.type configure -text [::msgcat::mc {Still}]
  }
  ${typemenu} add command -label [::msgcat::mc {Frizzante}] -command {
    set type {Frizzante}
    .editleft.1.color2.type configure -text [::msgcat::mc {Frizzante}]
  }
  ${typemenu} add command -label [::msgcat::mc {Sparkling}] -command {
    set type {Sparkling}
    .editleft.1.color2.type configure -text [::msgcat::mc {Sparkling}]
  }
#  ${typemenu} add command -label [::msgcat::mc {Port}] -command {
#    set type {Port}
#    .editleft.1.color2.type configure -text [::msgcat::mc {Port}]
#  }
  ${typemenu} add command -label [::msgcat::mc {Liqueur}] -command {
    set type {Liqueur}
    .editleft.1.color2.type configure -text [::msgcat::mc {Liqueur}]
  }
  ${typemenu} add command -label [::msgcat::mc {Fortified Wine}] -command {
    set type {Fortified}
    .editleft.1.color2.type configure -text [::msgcat::mc {Fortified Wine}]
  }
  ${typemenu} add command -label [::msgcat::mc {Distilled}] -command {
    set type {Distilled}
    .editleft.1.color2.type configure -text [::msgcat::mc {Distilled}]
  }
  if { ${type} == {Normal} } {
    .editleft.1.color2.type configure -text [::msgcat::mc {Still}]
  } elseif { ${type} == {Frizzante} } {
    .editleft.1.color2.type configure -text [::msgcat::mc {Frizzante}]
  } elseif { ${type} == {Sparkling} } {
    .editleft.1.color2.type configure -text [::msgcat::mc {Sparkling}]
  } elseif { ${type} == {Port} } {
    .editleft.1.color2.type configure -text [::msgcat::mc {Fortified Wine}]
    set type {Fortified}
  } elseif { ${type} == {Fortified} } {
    .editleft.1.color2.type configure -text [::msgcat::mc {Fortified Wine}]
  } elseif { ${type} == {Liqueur} } {
    .editleft.1.color2.type configure -text [::msgcat::mc {Liqueur}]
  } elseif { ${type} == {Distilled} } {
    .editleft.1.color2.type configure -text [::msgcat::mc {Distilled}]
  } else {
    .editleft.1.color2.type configure -text [::msgcat::mc {Still}]
    set type {Normal}
  }
bind .editleft.1.color2.type <Button-3> { tk_popup ${typemenu} %X %Y }
pack .editleft.1.color2.color .editleft.1.color2.space .editleft.1.color2.type -side left
grid .editleft.1.color2 -column 1 -row 2 -sticky w

frame .editleft.1.picture
  button .editleft.1.picture.pic -image $picture -borderwidth 1 -relief sunken -overrelief sunken -anchor nw -command {
    source [ file join ${prog_dir} tcl picture.tcl ]
  }
  pack .editleft.1.picture.pic -side left -fill x -expand true
grid .editleft.1.picture -column 2 -row 2 -sticky nse -rowspan 8

# Bottler
label .editleft.1.bottler1 -text "[::msgcat::mc {Bottler}] " -font ${titlefont} -anchor w
grid .editleft.1.bottler1 -column 0 -row 3 -sticky w
if { [ string length [::msgcat::mc {Producer}] ] > [ string length [::msgcat::mc {Trading Firm}] ] } {
  set bottlerlength [ string length [::msgcat::mc {Producer}] ]
} else {
  set bottlerlength [ string length [::msgcat::mc {Trading Firm}] ]
}
menubutton .editleft.1.bottler2 -menu .editleft.1.bottler2.menu -relief sunken -borderwidth 2 -background ${lightcolor} -padx 1 -pady 1 -width ${bottlerlength} -anchor w
set bottlermenu [ menu .editleft.1.bottler2.menu -tearoff 0 ]
${bottlermenu} add command -label [::msgcat::mc {unknown}] -command {
  set bottler {}
  .editleft.1.bottler2 configure -text [::msgcat::mc {unknown}]
}
${bottlermenu} add command -label [::msgcat::mc {Producer}] -command {
  set bottler {producer}
  .editleft.1.bottler2 configure -text [::msgcat::mc {Producer}]
}
${bottlermenu} add command -label [::msgcat::mc {Trading Firm}] -command {
  set bottler {tradingfirm}
  .editleft.1.bottler2 configure -text [::msgcat::mc {Trading Firm}]
}
if { ${bottler} == {tradingfirm} } {
  .editleft.1.bottler2 configure -text [::msgcat::mc {Trading Firm}]
} elseif { ${bottler} == {producer} } {
  .editleft.1.bottler2 configure -text [::msgcat::mc {Producer}]
} else {
  .editleft.1.bottler2 configure -text [::msgcat::mc {unknown}]
}
grid .editleft.1.bottler2 -column 1 -row 3 -sticky w
bind .editleft.1.bottler2 <Button-3> { tk_popup ${bottlermenu} %X %Y }

label .editleft.1.year1 -text "[::msgcat::mc {Vintage}] " -font ${titlefont} -anchor w
grid .editleft.1.year1 -column 0 -row 4 -sticky w
frame .editleft.1.year2
  # do not set it to from-year if no year given
  if { ${new} == {no} && ${year} == {} } {
    set year2 ${year}
    set leaveyear {yes}
  } else {
    set leaveyear {no}
  }
	spinbox .editleft.1.year2.year -textvariable year -from 1700 -to ${today_year} -width 5 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 5 } }
  if { ${leaveyear} == {yes} } {
    .editleft.1.year2.year set ${year2}
  }
  label .editleft.1.year2.text -text {} -width 1
  menubutton .editleft.1.year2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editleft.1.year2.help.menu
  set yearmenu [ menu .editleft.1.year2.help.menu -tearoff 0 ]
  ${yearmenu} add command -label [ expr "${today_year} - 1"  ] -command { .editleft.1.year2.year set [ expr "${today_year} - 1"  ] }
  ${yearmenu} add command -label [ expr "${today_year} - 2"  ] -command { .editleft.1.year2.year set [ expr "${today_year} - 2"  ] }
  ${yearmenu} add command -label [ expr "${today_year} - 3"  ] -command { .editleft.1.year2.year set [ expr "${today_year} - 3"  ] }
  ${yearmenu} add command -label [ expr "${today_year} - 4"  ] -command { .editleft.1.year2.year set [ expr "${today_year} - 4"  ] }
  ${yearmenu} add command -label [ expr "${today_year} - 5"  ] -command { .editleft.1.year2.year set [ expr "${today_year} - 5"  ] }
  ${yearmenu} add command -label [ expr "${today_year} - 6"  ] -command { .editleft.1.year2.year set [ expr "${today_year} - 6"  ] }
  ${yearmenu} add command -label [ expr "${today_year} - 7"  ] -command { .editleft.1.year2.year set [ expr "${today_year} - 7"  ] }
  ${yearmenu} add command -label [ expr "${today_year} - 8"  ] -command { .editleft.1.year2.year set [ expr "${today_year} - 8"  ] }
  ${yearmenu} add command -label [ expr "${today_year} - 9"  ] -command { .editleft.1.year2.year set [ expr "${today_year} - 9"  ] }
  ${yearmenu} add command -label [ expr "${today_year} - 10" ] -command { .editleft.1.year2.year set [ expr "${today_year} - 10" ] }
pack .editleft.1.year2.year .editleft.1.year2.text .editleft.1.year2.help -side left
grid .editleft.1.year2 -column 1 -row 4 -sticky w
bind .editleft.1.year2.year <Button-3> { tk_popup ${yearmenu} %X %Y }

label .editleft.1.alc1 -text "[::msgcat::mc {Alcohol}] " -font ${titlefont} -anchor w
grid  .editleft.1.alc1 -column 0 -row 5 -sticky w
frame .editleft.1.alc2
  set alc2 ${alc}
  spinbox .editleft.1.alc2.spin -textvariable alc -from 0.0 -to 99.9 -increment .1 -width 5 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is double %P ] && [ string length %P ] < 5 } }
  # comma to point translation
  bind .editleft.1.alc2.spin <KeyPress> {
    if { "%A" == {,} && ![ regexp {\.} ${alc} ] } {
      append alc {.}
      .editleft.1.alc2.spin icursor end
    }
  }
  .editleft.1.alc2.spin set ${alc2}
  label .editleft.1.alc2.text -text {%} -width 1
  menubutton .editleft.1.alc2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editleft.1.alc2.help.menu
  set alcmenu [ menu .editleft.1.alc2.help.menu -tearoff 0 ]
  ${alcmenu} add command -label "10.0" -command { .editleft.1.alc2.spin set "10.0" }
  ${alcmenu} add command -label "10.5" -command { .editleft.1.alc2.spin set "10.5" }
  ${alcmenu} add command -label "11.0" -command { .editleft.1.alc2.spin set "11.0" }
  ${alcmenu} add command -label "11.5" -command { .editleft.1.alc2.spin set "11.5" }
  ${alcmenu} add command -label "12.0" -command { .editleft.1.alc2.spin set "12.0" }
  ${alcmenu} add command -label "12.5" -command { .editleft.1.alc2.spin set "12.5" }
  ${alcmenu} add command -label "13.0" -command { .editleft.1.alc2.spin set "13.0" }
  ${alcmenu} add command -label "13.5" -command { .editleft.1.alc2.spin set "13.5" }
  ${alcmenu} add command -label "14.0" -command { .editleft.1.alc2.spin set "14.0" }
  ${alcmenu} add command -label "14.5" -command { .editleft.1.alc2.spin set "14.5" }
  ${alcmenu} add command -label "15.0" -command { .editleft.1.alc2.spin set "15.0" }
  ${alcmenu} add command -label "15.5" -command { .editleft.1.alc2.spin set "15.5" }
pack .editleft.1.alc2.spin .editleft.1.alc2.text .editleft.1.alc2.help -side left
grid .editleft.1.alc2 -column 1 -row 5 -sticky w
bind .editleft.1.alc2.spin <Button-3> { tk_popup ${alcmenu} %X %Y }

label .editleft.1.size1 -text "[::msgcat::mc {Bottle Size}] " -font ${titlefont} -anchor w
grid .editleft.1.size1 -column 0 -row 6 -sticky w
frame .editleft.1.size2
  set size2 ${size}
  spinbox .editleft.1.size2.size -textvariable size -values ${bottlesizes} -width 5 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is double %P ] && [ string length %P ] < 6 } }
  # comma to point translation
  bind .editleft.1.size2.size <KeyPress> {
    if { "%A" == {,} && ![ regexp {\.} ${size} ] } {
      append size {.}
      .editleft.1.size2.size icursor end
    }
  }
  .editleft.1.size2.size set ${size2}
  label .editleft.1.size2.text -text "[::msgcat::mc {Litre}] "
  label .editleft.1.size2.text2 -text {} -font ${smallfont}
pack .editleft.1.size2.size .editleft.1.size2.text .editleft.1.size2.text2 -side left
grid .editleft.1.size2 -column 1 -row 6 -sticky w
set sizemenu [ menu .editleft.1.size2.size.menu -tearoff 0 ]
${sizemenu} add command -label {0.375} -command { .editleft.1.size2.size set {0.375} }
${sizemenu} add command -label {0.5} -command { .editleft.1.size2.size set {0.5} }
${sizemenu} add command -label {0.62} -command { .editleft.1.size2.size set {0.62} }
${sizemenu} add command -label {0.75} -command { .editleft.1.size2.size set {0.75} }
${sizemenu} add command -label {1.0} -command { .editleft.1.size2.size set {1.0} }
${sizemenu} add command -label {1.5} -command { .editleft.1.size2.size set {1.5} }
${sizemenu} add command -label {2.25} -command { .editleft.1.size2.size set {2.25} }
${sizemenu} add command -label {3.0} -command { .editleft.1.size2.size set {3.0} }
${sizemenu} add command -label {4.5} -command { .editleft.1.size2.size set {4.5} }
${sizemenu} add command -label {5.0} -command { .editleft.1.size2.size set {5.0} }
${sizemenu} add command -label {6.0} -command { .editleft.1.size2.size set {6.0} }
${sizemenu} add command -label {9.0} -command { .editleft.1.size2.size set {9.0} }
${sizemenu} add command -label {12.0} -command { .editleft.1.size2.size set {12.0} }
${sizemenu} add command -label {15.0} -command { .editleft.1.size2.size set {15.0} }
${sizemenu} add command -label {18.0} -command { .editleft.1.size2.size set {18.0} }
bind .editleft.1.size2.size <Button-3> { tk_popup ${sizemenu} %X %Y }


set barrelmenulength [ string length [::msgcat::mc {no}] ]
if { [ string length [::msgcat::mc {unknown}] ]  > ${barrelmenulength} } { set barrelmenulength [ string length [::msgcat::mc {unknown}] ] }
if { [ string length [::msgcat::mc {partial}] ]  > ${barrelmenulength} } { set barrelmenulength [ string length [::msgcat::mc {partial}] ] }
if { [ string length [::msgcat::mc {Barrel}] ]   > ${barrelmenulength} } { set barrelmenulength [ string length [::msgcat::mc {Barrel}] ] }
if { [ string length [::msgcat::mc {Barrique}] ] > ${barrelmenulength} } { set barrelmenulength [ string length [::msgcat::mc {Barrique}] ] }
proc barrel_false {} {
  global barrel
  set barrel {false}
  .editleft.1.barrel2.check configure -text [::msgcat::mc {no}]
  .editleft.1.barrel2.text1 configure -state disabled
  .editleft.1.barrel2.list  configure -state disabled
  .editleft.1.barrel2.text2 configure -state disabled
}
proc barrel_none {} {
  global barrel
  set barrel {}
  .editleft.1.barrel2.check configure -text [::msgcat::mc {unknown}]
  .editleft.1.barrel2.text1 configure -state disabled
  .editleft.1.barrel2.list  configure -state disabled
  .editleft.1.barrel2.text2 configure -state disabled
}
proc barrel_partial {} {
  global barrel
  set barrel "partial"
  .editleft.1.barrel2.check configure -text [::msgcat::mc {partial}]
  .editleft.1.barrel2.text1 configure -state normal
  .editleft.1.barrel2.list  configure -state normal
  .editleft.1.barrel2.text2 configure -state normal
}
proc barrel_true {} {
  global barrel
  set barrel {true}
  .editleft.1.barrel2.check configure -text [::msgcat::mc {Barrel}]
  .editleft.1.barrel2.text1 configure -state normal
  .editleft.1.barrel2.list  configure -state normal
  .editleft.1.barrel2.text2 configure -state normal
}
proc barrel_barrique {} {
  global barrel
  set barrel "barrique"
  .editleft.1.barrel2.check configure -text [::msgcat::mc {Barrique}]
  .editleft.1.barrel2.text1 configure -state normal
  .editleft.1.barrel2.list  configure -state normal
  .editleft.1.barrel2.text2 configure -state normal
}
label .editleft.1.barrel1 -text "[::msgcat::mc {Barrel}] " -font ${titlefont} -anchor w
grid .editleft.1.barrel1 -column 0 -row 7 -sticky w
frame .editleft.1.barrel2
  menubutton .editleft.1.barrel2.check -menu .editleft.1.barrel2.check.menu -relief sunken -borderwidth 2 -background ${lightcolor} -padx 1 -pady 1 -width ${barrelmenulength} -anchor w
  set barrelmenu [ menu .editleft.1.barrel2.check.menu -tearoff 0 ]
  ${barrelmenu} add command -label [::msgcat::mc {no}] -command { barrel_false }
  ${barrelmenu} add command -label [::msgcat::mc {unknown}] -command { barrel_none }
  ${barrelmenu} add command -label [::msgcat::mc {partial}] -command { barrel_partial }
  ${barrelmenu} add command -label [::msgcat::mc {Barrel}] -command { barrel_true }
  ${barrelmenu} add command -label [::msgcat::mc {Barrique}] -command { barrel_barrique }
  label .editleft.1.barrel2.text1 -text [::msgcat::mc {min.}] -anchor w
  set barrel_months2 ${barrel_months}
  spinbox .editleft.1.barrel2.list -textvariable barrel_months -from 1 -to 999 -width 3 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 4 } }
  # contextmenu
  set barrelconmenu [ menu .editleft.1.barrel2.list.menu -tearoff 0 ]
  ${barrelconmenu} add command -label {3} -command { .editleft.1.barrel2.list set {3} }
  ${barrelconmenu} add command -label {4} -command { .editleft.1.barrel2.list set {4} }
  ${barrelconmenu} add command -label {5} -command { .editleft.1.barrel2.list set {5} }
  ${barrelconmenu} add command -label {6} -command { .editleft.1.barrel2.list set {6} }
  ${barrelconmenu} add command -label {7} -command { .editleft.1.barrel2.list set {7} }
  ${barrelconmenu} add command -label {8} -command { .editleft.1.barrel2.list set {8} }
  ${barrelconmenu} add command -label {9} -command { .editleft.1.barrel2.list set {9} }
  ${barrelconmenu} add command -label {10} -command { .editleft.1.barrel2.list set {10} }
  ${barrelconmenu} add command -label {11} -command { .editleft.1.barrel2.list set {11} }
  ${barrelconmenu} add command -label {12} -command { .editleft.1.barrel2.list set {12} }
  ${barrelconmenu} add command -label {13} -command { .editleft.1.barrel2.list set {13} }
  ${barrelconmenu} add command -label {14} -command { .editleft.1.barrel2.list set {14} }
  ${barrelconmenu} add command -label {15} -command { .editleft.1.barrel2.list set {15} }
  ${barrelconmenu} add command -label {16} -command { .editleft.1.barrel2.list set {16} }
  ${barrelconmenu} add command -label {17} -command { .editleft.1.barrel2.list set {17} }
  ${barrelconmenu} add command -label {18} -command { .editleft.1.barrel2.list set {18} }
  ${barrelconmenu} add command -label {19} -command { .editleft.1.barrel2.list set {19} }
  ${barrelconmenu} add command -label {20} -command { .editleft.1.barrel2.list set {20} }
  ${barrelconmenu} add command -label {21} -command { .editleft.1.barrel2.list set {21} }
  ${barrelconmenu} add command -label {22} -command { .editleft.1.barrel2.list set {22} }
  ${barrelconmenu} add command -label {23} -command { .editleft.1.barrel2.list set {23} }
  ${barrelconmenu} add command -label {24} -command { .editleft.1.barrel2.list set {24} }
  ${barrelconmenu} add command -label {30} -command { .editleft.1.barrel2.list set {30} }
  ${barrelconmenu} add command -label {36} -command { .editleft.1.barrel2.list set {36} }
  ${barrelconmenu} add command -label {42} -command { .editleft.1.barrel2.list set {42} }
  ${barrelconmenu} add command -label {48} -command { .editleft.1.barrel2.list set {48} }
  bind .editleft.1.barrel2.list <Button-3> {
    set barrelconmenulength [ ${barrelconmenu} index end ]
    set barrelconmenuindex {0}
    if { [ .editleft.1.barrel2.list cget -state ] == {disabled} } {
      while { ${barrelconmenuindex} <= ${barrelconmenulength} } {
        ${barrelconmenu} entryconfigure ${barrelconmenuindex} -state disabled
        incr barrelconmenuindex
      }
    } else {
      while { ${barrelconmenuindex} <= ${barrelconmenulength} } {
        ${barrelconmenu} entryconfigure ${barrelconmenuindex} -state normal
        incr barrelconmenuindex
      }
    }
    tk_popup ${barrelconmenu} %X %Y
  }
  label .editleft.1.barrel2.text2 -text [::msgcat::mc {months}] -anchor w -width 6
  if { ${barrel} == {false} } {
    .editleft.1.barrel2.check configure -text [::msgcat::mc {no}]
    .editleft.1.barrel2.text1 configure -state disabled
    .editleft.1.barrel2.list  configure -state disabled
    .editleft.1.barrel2.text2 configure -state disabled
    set barrel_months {}
  } elseif { ${barrel} == "partial" } {
    .editleft.1.barrel2.check configure -text [::msgcat::mc {partial}]
  } elseif { ${barrel} == {true} } {
    .editleft.1.barrel2.check configure -text [::msgcat::mc {Barrel}]
  } elseif { ${barrel} == "barrique" } {
    .editleft.1.barrel2.check configure -text [::msgcat::mc {Barrique}]
  } elseif { ${barrel} == {} } {
    .editleft.1.barrel2.check configure -text [::msgcat::mc {unknown}]
    .editleft.1.barrel2.text1 configure -state disabled
    .editleft.1.barrel2.list  configure -state disabled
    .editleft.1.barrel2.text2 configure -state disabled
    set barrel_months {}
  }
  set barrel_months ${barrel_months2}
  if { ${barrel_months} == {1} } { .editleft.1.barrel2.text2 configure -text [::msgcat::mc {month}] }
pack .editleft.1.barrel2.check .editleft.1.barrel2.text1 .editleft.1.barrel2.list .editleft.1.barrel2.text2 -side left
grid .editleft.1.barrel2 -column 1 -row 7 -sticky w
bind .editleft.1.barrel2.check <Button-3> { tk_popup ${barrelmenu} %X %Y }

label .editleft.1.class1 -text "[::msgcat::mc {Classification}] " -font ${titlefont} -anchor w
grid .editleft.1.class1 -column 0 -row 8 -sticky w
frame .editleft.1.class2
  entry  .editleft.1.class2.box -textvariable classification -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
  button .editleft.1.class2.button -image ${helpbutton} -anchor nw -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -command { help_class }
pack .editleft.1.class2.box -side left -fill x -expand true
pack .editleft.1.class2.button -side left
grid .editleft.1.class2 -column 1 -row 8 -sticky we
::conmen .editleft.1.class2.box
.editleft.1.class2.box.conmen add separator
.editleft.1.class2.box.conmen add command -label [::msgcat::mc {choose}] -command { help_class }

label .editleft.1.bio1 -text "[::msgcat::mc {Bio}] " -font ${titlefont} -anchor w
grid .editleft.1.bio1 -column 0 -row 9 -sticky w
frame .editleft.1.bio2
  entry  .editleft.1.bio2.box -textvariable bio -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
  button .editleft.1.bio2.button -image ${helpbutton} -anchor nw -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -command { help_bio }
pack .editleft.1.bio2.box -side left -fill x -expand true
pack .editleft.1.bio2.button -side left
grid .editleft.1.bio2 -column 1 -row 9 -sticky we
::conmen .editleft.1.bio2.box
.editleft.1.bio2.box.conmen add separator
.editleft.1.bio2.box.conmen add command -label [::msgcat::mc {choose}] -command { help_bio }

# grape percentage context menu
set grapepercentmenu [ menu .editleft.1.grapepercentmenu -tearoff 0 ]
${grapepercentmenu} add command -label {100} -command { ${percentwidget} set {100} }
${grapepercentmenu} add command -label {90} -command { ${percentwidget} set {90} }
${grapepercentmenu} add command -label {80} -command { ${percentwidget} set {80} }
${grapepercentmenu} add command -label {70} -command { ${percentwidget} set {70} }
${grapepercentmenu} add command -label {60} -command { ${percentwidget} set {60} }
${grapepercentmenu} add command -label {50} -command { ${percentwidget} set {50} }
${grapepercentmenu} add command -label {40} -command { ${percentwidget} set {40} }
${grapepercentmenu} add command -label {30} -command { ${percentwidget} set {30} }
${grapepercentmenu} add command -label {20} -command { ${percentwidget} set {20} }
${grapepercentmenu} add command -label {10} -command { ${percentwidget} set {10} }

label .editleft.1.grape1_1 -text "[::msgcat::mc {Grape #1}] " -font ${titlefont} -anchor w
grid .editleft.1.grape1_1 -column 0 -row 10 -sticky w
frame .editleft.1.grape1_2
  entry .editleft.1.grape1_2.grape1 -textvariable grape1 -width 32 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
pack .editleft.1.grape1_2.grape1 -side left -fill x -expand true
  button .editleft.1.grape1_2.help -image ${helpbutton} -anchor nw -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -command { help_grape 1 }
  set percent12 ${percent1}
  spinbox .editleft.1.grape1_2.percent1_1 -textvariable percent1 -from 0 -to 100 -width 3 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 4 } }
  ::conmen .editleft.1.grape1_2.percent1_1
  .editleft.1.grape1_2.percent1_1 set ${percent12}
  label .editleft.1.grape1_2.percent1_2 -text {%}
pack .editleft.1.grape1_2.help .editleft.1.grape1_2.percent1_1 .editleft.1.grape1_2.percent1_2 -side left
grid .editleft.1.grape1_2 -column 1 -row 10 -sticky we -columnspan 2
::conmen .editleft.1.grape1_2.grape1
.editleft.1.grape1_2.grape1.conmen add separator
.editleft.1.grape1_2.grape1.conmen add command -label [::msgcat::mc {search}] -command { help_grape 1 }
bind .editleft.1.grape1_2.percent1_1 <Button-3> {
  set percentwidget %W
  tk_popup ${grapepercentmenu} %X %Y
}

label .editleft.1.grape2_1 -text "[::msgcat::mc {Grape #2}] " -font ${titlefont} -anchor w
grid .editleft.1.grape2_1 -column 0 -row 11 -sticky w
frame .editleft.1.grape2_2
  entry .editleft.1.grape2_2.grape2 -textvariable grape2 -width 32 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
pack .editleft.1.grape2_2.grape2 -side left -fill x -expand true
  button .editleft.1.grape2_2.help -image ${helpbutton} -anchor nw -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -command { help_grape 2 }
  set percent22 ${percent2}
  spinbox .editleft.1.grape2_2.percent2_1 -textvariable percent2 -from 0 -to 100 -width 3 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 4 } }
  .editleft.1.grape2_2.percent2_1 set ${percent22}
  label .editleft.1.grape2_2.percent2_2 -text {%}
pack .editleft.1.grape2_2.help .editleft.1.grape2_2.percent2_1 .editleft.1.grape2_2.percent2_2 -side left
grid .editleft.1.grape2_2 -column 1 -row 11 -sticky we -columnspan 2
::conmen .editleft.1.grape2_2.grape2
.editleft.1.grape2_2.grape2.conmen add separator
.editleft.1.grape2_2.grape2.conmen add command -label [::msgcat::mc {search}] -command { help_grape 2 }
bind .editleft.1.grape2_2.percent2_1 <Button-3> {
  set percentwidget %W
  tk_popup ${grapepercentmenu} %X %Y
}

label .editleft.1.grape3_1 -text "[::msgcat::mc {Grape #3}] " -font ${titlefont} -anchor w
grid .editleft.1.grape3_1 -column 0 -row 12 -sticky w
frame .editleft.1.grape3_2
  entry .editleft.1.grape3_2.grape3 -textvariable grape3 -width 32 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
pack .editleft.1.grape3_2.grape3 -side left -fill x -expand true
  button .editleft.1.grape3_2.help -image ${helpbutton} -anchor nw -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -command { help_grape 3 }
  set percent32 ${percent3}
  spinbox .editleft.1.grape3_2.percent3_1 -textvariable percent3 -from 0 -to 100 -width 3 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 4 } }
  .editleft.1.grape3_2.percent3_1 set ${percent32}
  label .editleft.1.grape3_2.percent3_2 -text {%}
pack .editleft.1.grape3_2.help .editleft.1.grape3_2.percent3_1 .editleft.1.grape3_2.percent3_2 -side left
grid .editleft.1.grape3_2 -column 1 -row 12 -sticky we -columnspan 2
::conmen .editleft.1.grape3_2.grape3
.editleft.1.grape3_2.grape3.conmen add separator
.editleft.1.grape3_2.grape3.conmen add command -label [::msgcat::mc {search}] -command { help_grape 3 }
bind .editleft.1.grape3_2.percent3_1 <Button-3> {
  set percentwidget %W
  tk_popup ${grapepercentmenu} %X %Y
}

label .editleft.1.grape4_1 -text "[::msgcat::mc {Grape #4}] " -font ${titlefont} -anchor w
grid .editleft.1.grape4_1 -column 0 -row 13 -sticky w
frame .editleft.1.grape4_2
  entry .editleft.1.grape4_2.grape4 -textvariable grape4 -width 32 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
pack .editleft.1.grape4_2.grape4 -side left -fill x -expand true
  button .editleft.1.grape4_2.help -image ${helpbutton} -anchor nw -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -command { help_grape 4 }
  set percent42 ${percent4}
  spinbox .editleft.1.grape4_2.percent4_1 -textvariable percent4 -from 0 -to 100 -width 3 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 4 } }
  .editleft.1.grape4_2.percent4_1 set ${percent42}
  label .editleft.1.grape4_2.percent4_2 -text {%}
pack .editleft.1.grape4_2.help .editleft.1.grape4_2.percent4_1 .editleft.1.grape4_2.percent4_2 -side left
grid .editleft.1.grape4_2 -column 1 -row 13 -sticky we -columnspan 2
::conmen .editleft.1.grape4_2.grape4
.editleft.1.grape4_2.grape4.conmen add separator
.editleft.1.grape4_2.grape4.conmen add command -label [::msgcat::mc {search}] -command { help_grape 4 }
bind .editleft.1.grape4_2.percent4_1 <Button-3> {
  set percentwidget %W
  tk_popup ${grapepercentmenu} %X %Y
}

label .editleft.1.grape5_1 -text "[::msgcat::mc {Grape #5}] " -font ${titlefont} -anchor w
grid .editleft.1.grape5_1 -column 0 -row 14 -sticky w
frame .editleft.1.grape5_2
  entry .editleft.1.grape5_2.grape5 -textvariable grape5 -width 32 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
pack .editleft.1.grape5_2.grape5 -side left -fill x -expand true
  button .editleft.1.grape5_2.help -image ${helpbutton} -anchor nw -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -command { help_grape 5 }
  set percent52 ${percent5}
  spinbox .editleft.1.grape5_2.percent5_1 -textvariable percent5 -from 0 -to 100 -width 3 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 4 } }
  .editleft.1.grape5_2.percent5_1 set ${percent52}
  label .editleft.1.grape5_2.percent5_2 -text {%}
pack .editleft.1.grape5_2.help .editleft.1.grape5_2.percent5_1 .editleft.1.grape5_2.percent5_2 -side left
grid .editleft.1.grape5_2 -column 1 -row 14 -sticky we -columnspan 2
::conmen .editleft.1.grape5_2.grape5
.editleft.1.grape5_2.grape5.conmen add separator
.editleft.1.grape5_2.grape5.conmen add command -label [::msgcat::mc {search}] -command { help_grape 5 }
bind .editleft.1.grape5_2.percent5_1 <Button-3> {
  set percentwidget %W
  tk_popup ${grapepercentmenu} %X %Y
}

label .editleft.1.notes1 -text "[::msgcat::mc {Notes}] " -font ${titlefont} -anchor w
grid  .editleft.1.notes1 -column 0 -row 15 -sticky nw
frame .editleft.1.notes2
text  .editleft.1.notes2.text -wrap word -width 35 -height 3 -background ${lightcolor} -yscrollcommand ".editleft.1.notes2.scroll set"
if { $::bTtk } {
	ttk::scrollbar .editleft.1.notes2.scroll -command ".editleft.1.notes2.text yview"
} else {
	scrollbar .editleft.1.notes2.scroll -command ".editleft.1.notes2.text yview"
}
.editleft.1.notes2.text insert end ${notes}
pack  .editleft.1.notes2.text   -side left  -fill both -expand true
pack  .editleft.1.notes2.scroll -side right -fill y
grid  .editleft.1.notes2 -column 1 -row 15 -sticky news -columnspan 2
::conmen .editleft.1.notes2.text

# pack the left side together
pack .editleft.0     -side top -padx 0 -pady 0 -fill both -expand true
pack .editleft.blank -side top -padx 0 -pady 0 -fill x
pack .editleft.1     -side top -padx 0 -pady 0 -fill both -expand true
# resize only for text widgets
grid rowconfigure .editleft.0  6 -weight 1
grid rowconfigure .editleft.1 15 -weight 1


frame .editright
if { $::bTtk } {
	ttk::labelframe .editright.0 -text [::msgcat::mc {Shopping / Quantity}]
} else {
	labelframe .editright.0 -text [::msgcat::mc {Shopping / Quantity}] -padx 2 -pady 2
}

label .editright.0.dealer1 -text "[::msgcat::mc {Dealer}] \#1 " -font ${titlefont}
frame .editright.0.dealer2
  entry  .editright.0.dealer2.text -textvariable dealer -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
  button .editright.0.dealer2.help -image ${helpbutton} -anchor nw -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -command { help_vintner editor }
pack .editright.0.dealer2.text -side left -expand true -fill x
pack .editright.0.dealer2.help -side left
grid  .editright.0.dealer1 -column 0 -row 0 -sticky w
grid  .editright.0.dealer2 -column 1 -row 0 -sticky we
::conmen .editright.0.dealer2.text
.editright.0.dealer2.text.conmen add separator
.editright.0.dealer2.text.conmen add command -label [::msgcat::mc {choose}] -command { help_vintner editor }

label .editright.0.price1 -text "[::msgcat::mc {Price}] " -font ${titlefont}
frame .editright.0.price2
  entry .editright.0.price2.price -textvariable price -width 7 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is double %P ] && [ string length %P ] < 8 } }
  # comma to point translation
  bind .editright.0.price2.price <KeyPress> {
    if { "%A" == {,} && ![ regexp {\.} ${price} ] } {
      append price {.}
      .editright.0.price2.price icursor end
    }
  }
  label .editright.0.price2.text -text "${currency} "
  label .editright.0.price2.litreprice -text {} -font ${smallfont}
  update_litreprice
pack .editright.0.price2.price .editright.0.price2.text .editright.0.price2.litreprice -side left
grid  .editright.0.price1 -column 0 -row 1 -sticky w
grid  .editright.0.price2 -column 1 -row 1 -sticky w
::conmen .editright.0.price2.price

label  .editright.0.history1 -text "[::msgcat::mc {History}] " -font ${titlefont} -anchor nw
frame  .editright.0.history2
  text .editright.0.history2.message -width 41 -height 3 -wrap word -relief flat -yscrollcommand ".editright.0.history2.scroll set"
  ::conmen .editright.0.history2.message
	if { $::bTtk } {
  	ttk::scrollbar .editright.0.history2.scroll -command ".editright.0.history2.message yview"
	} else {
		scrollbar .editright.0.history2.scroll -command ".editright.0.history2.message yview"
	}
  .editright.0.history2.message insert 1.0 ${bought_history}
pack .editright.0.history2.message -side left  -fill both -expand true
pack .editright.0.history2.scroll  -side right -fill y
grid .editright.0.history1 -column 0 -row 2 -sticky nw
grid .editright.0.history2 -column 1 -row 2 -sticky news

label .editright.0.bought1 -text { } -font ${smallfont}
frame .editright.0.bought2
  label .editright.0.bought2.text1 -text [::msgcat::mc {added}] -font ${smallfont}
  spinbox .editright.0.bought2.sum -textvariable bought_sum -from 0 -to 999 -width 3 -relief flat -font ${smallfont} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 4 } }
  if { ${bought_sum} != {1} } {
    label .editright.0.bought2.text2 -text [::msgcat::mc {bottles so far to history}] -font ${smallfont}
  } else {
    label .editright.0.bought2.text2 -text [::msgcat::mc {bottle so far to history}] -font ${smallfont}
  }
pack .editright.0.bought2.text1 .editright.0.bought2.sum .editright.0.bought2.text2 -side left
grid .editright.0.bought1 -column 0 -row 3 -sticky w
grid .editright.0.bought2 -column 1 -row 3 -sticky w

label .editright.0.amount1 -text "[::msgcat::mc {Quantity}] " -font ${titlefont}
frame .editright.0.amount2
  spinbox .editright.0.amount2.box -textvariable amount -from 0 -to 999 -width 3 -relief flat -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 4 } }
  if { ${amount} != {1} } {
    label .editright.0.amount2.text -text [::msgcat::mc {Bottles}] -width 8 -anchor w
  } else {
    label .editright.0.amount2.text -text [::msgcat::mc {Bottle}] -width 8 -anchor w
  }
pack .editright.0.amount2.box .editright.0.amount2.text -side left
  button .editright.0.amount2.new -image ${inbutton} -text [::msgcat::mc {In}] -compound left -pady 1 -padx 1 -relief raised -borderwidth 1 -command { source [ file join ${prog_dir} tcl input.tcl  ] }
pack .editright.0.amount2.new -side left -fill x -expand true
  button .editright.0.amount2.out -image ${outbutton} -text [::msgcat::mc {Out}] -compound left -pady 1 -padx 1 -relief raised -borderwidth 1 -command { source [ file join ${prog_dir} tcl output.tcl ] }
pack .editright.0.amount2.out -side left -fill x -expand true
if { ${amount} == {0} } { .editright.0.amount2.out configure -state disable }
grid  .editright.0.amount1 -column 0 -row 4 -sticky w
grid  .editright.0.amount2 -column 1 -row 4 -sticky we


frame .editright.blank -height 4


proc switchmode {} {
  global viewmode
  # first get rid of old resizing settings
  set gridrowcount {0}
  set gridrowlast [ lindex [ grid size .editright.1 ] 1 ]
  while { ${gridrowlast} > ${gridrowcount} } {
    grid rowconfigure .editright.1 ${gridrowcount} -weight 0
    incr gridrowcount
  }
  # get rid of old widgets
  foreach widget [winfo children .editright.1 ] { grid remove ${widget} }
  # grid selected widgets
  if { ${viewmode} == {text} } {
    grid .editright.1.text11 .editright.1.text12 -sticky news -row 0
    grid .editright.1.text21 .editright.1.text22 -sticky news -row 1
    grid .editright.1.text31 .editright.1.text32 -sticky news -row 2
    grid .editright.1.text41 .editright.1.text42 -sticky news -row 3
    grid .editright.1.text51 .editright.1.text52 -sticky news -row 4
    grid rowconfigure .editright.1 0 -weight 1
    grid rowconfigure .editright.1 1 -weight 1
    grid rowconfigure .editright.1 2 -weight 1
    grid rowconfigure .editright.1 3 -weight 1
  } elseif { ${viewmode} == {buttons} } {
    grid .editright.1.look1
    grid .editright.1.look2
    grid .editright.1.nose1
    grid .editright.1.nose2
    grid .editright.1.typical1
    grid .editright.1.typical2
    grid .editright.1.weight1
    grid .editright.1.weight2
    grid .editright.1.complex1
    grid .editright.1.complex2
    grid .editright.1.alcintegration1
    grid .editright.1.alcintegration2
    grid .editright.1.finish1
    grid .editright.1.finish2
    grid .editright.1.balance1
    grid .editright.1.balance2
    grid .editright.1.impression1
    grid .editright.1.impression2
    grid .editright.1.acid1
    grid .editright.1.acid2
    grid .editright.1.sweet1
    grid .editright.1.sweet2
    grid .editright.1.bitterness1
    grid .editright.1.bitterness2
    grid .editright.1.headache1
    grid .editright.1.headache2
    grid .editright.1.believable1
    grid .editright.1.believable2
    grid .editright.1.value1
    grid .editright.1.value2
    grid .editright.1.evolution1
    grid .editright.1.evolution2
  } else {
    grid .editright.1.cork1        -row 0 -column 0 -sticky w
    grid .editright.1.cork2        -row 0 -column 1 -sticky w
    grid .editright.1.air1         -row 1 -column 0 -sticky nw
    grid .editright.1.air2         -row 1 -column 1 -sticky w
    grid .editright.1.tint1        -row 2 -column 0 -sticky w
    grid .editright.1.tint2        -row 2 -column 1 -sticky w
    grid .editright.1.tastetype1   -row 3 -column 0 -sticky w
    grid .editright.1.tastetype2   -row 3 -column 1 -sticky w
    grid .editright.1.aroma1       -row 4 -column 0 -sticky w
    grid .editright.1.aroma2       -row 4 -column 1 -sticky we
    grid .editright.1.aroma3       -row 5 -column 0 -sticky w
    grid .editright.1.aroma4       -row 5 -column 1 -sticky we
    grid .editright.1.depot1       -row 6 -column 0 -sticky w
    grid .editright.1.depot2       -row 6 -column 1 -sticky w
  }
  # need to get the row indexes for resizing
  set gridsize [ lindex [ grid size .editright.1 ] 1 ]
  # grid anytime widgets
  grid .editright.1.history1 .editright.1.history2 -sticky news -row [ expr "${gridsize} + 1" ]
  grid .editright.1.next_bottle1 .editright.1.next_bottle2 -sticky w -row [ expr "${gridsize} + 2" ]
  grid .editright.1.last_bottle1 .editright.1.last_bottle2 -sticky w -row [ expr "${gridsize} + 3" ]
  # resize the history
  grid rowconfigure .editright.1 [ expr "${gridsize} + 1" ] -weight 1
}


if { $::bTtk } {
	ttk::labelframe .editright.1
} else {
	labelframe .editright.1 -padx 2 -pady 2
}
frame      .editright.1.labeltext
  frame .editright.1.labeltext.switch -relief raised -borderwidth 1
    button .editright.1.labeltext.switch.1 -text {1} -relief flat -borderwidth 0 -padx 2 -pady 0 -font ${smallfont} -command {
      if { ${viewmode} != {buttons} } {
        set viewmode {buttons}
        .editright.1.labeltext.switch.1 configure -background ${lightcolor}
        .editright.1.labeltext.switch.2 configure -background ${background}
        .editright.1.labeltext.switch.3 configure -background ${background}
        switchmode
      }
    }
  pack .editright.1.labeltext.switch.1 -side left
    frame .editright.1.labeltext.switch.separator1 -padx 0 -pady 3
      frame .editright.1.labeltext.switch.separator1.draw -width 2 -borderwidth 2 -relief sunken
    pack .editright.1.labeltext.switch.separator1.draw -side left -fill y -expand true
  pack .editright.1.labeltext.switch.separator1 -side left -fill y -expand true
    button .editright.1.labeltext.switch.2 -text {2} -relief flat -borderwidth 0 -padx 2 -pady 0 -font ${smallfont} -command {
      if { ${viewmode} != {usage} } {
        set viewmode {usage}
        .editright.1.labeltext.switch.1 configure -background ${background}
        .editright.1.labeltext.switch.2 configure -background ${lightcolor}
        .editright.1.labeltext.switch.3 configure -background ${background}
        switchmode
      }
    }
  pack .editright.1.labeltext.switch.2 -side left
    frame .editright.1.labeltext.switch.separator2 -padx 0 -pady 3
      frame .editright.1.labeltext.switch.separator2.draw -width 2 -borderwidth 2 -relief sunken
    pack .editright.1.labeltext.switch.separator2.draw -side left -fill y -expand true
  pack .editright.1.labeltext.switch.separator2 -side left -fill y -expand true
    button .editright.1.labeltext.switch.3 -text {3} -relief flat -borderwidth 0 -padx 2 -pady 0 -font ${smallfont} -command {
      if { ${viewmode} != {text} } {
        set viewmode {text}
        .editright.1.labeltext.switch.1 configure -background ${background}
        .editright.1.labeltext.switch.2 configure -background ${background}
        .editright.1.labeltext.switch.3 configure -background ${lightcolor}
        switchmode
      }
    }
  pack .editright.1.labeltext.switch.3 -side left
  label .editright.1.labeltext.1 -text [::msgcat::mc {Drink}]
  label .editright.1.labeltext.2 -text {} -font ${smallitalicfont}
pack .editright.1.labeltext.switch -side left -padx 3
pack .editright.1.labeltext.1      -side left
pack .editright.1.labeltext.2      -side left -padx 3
.editright.1 configure -labelwidget .editright.1.labeltext


########################################################################
# ungrided widgets for alternative text view
########################################################################
#
label  .editright.1.text11 -text "[::msgcat::mc {Look}] " -font ${titlefont} -anchor nw
frame  .editright.1.text12
  text .editright.1.text12.message -background ${lightcolor} -width 40 -height 3 -wrap word -yscrollcommand ".editright.1.text12.scroll set"
	if { $::bTtk } {
  	ttk::scrollbar .editright.1.text12.scroll -command ".editright.1.text12.message yview"
	} else {
		scrollbar .editright.1.text12.scroll -command ".editright.1.text12.message yview"
	}
  .editright.1.text12.message insert end ${txt_look}
pack .editright.1.text12.message -side left  -fill both -expand true
pack .editright.1.text12.scroll  -side right -fill y
::conmen .editright.1.text12.message

label  .editright.1.text21 -text "[::msgcat::mc {Nose}] " -font ${titlefont} -anchor nw
frame  .editright.1.text22
  text .editright.1.text22.message -background ${lightcolor} -width 40 -height 3 -wrap word -yscrollcommand ".editright.1.text22.scroll set"
	if { $::bTtk } {
  	ttk::scrollbar .editright.1.text22.scroll -command ".editright.1.text22.message yview"
	} else {
		scrollbar .editright.1.text22.scroll -command ".editright.1.text22.message yview"
	}
  .editright.1.text22.message insert end ${txt_nose}
pack .editright.1.text22.message -side left  -fill both -expand true
pack .editright.1.text22.scroll  -side right -fill y
::conmen .editright.1.text22.message

label  .editright.1.text31 -text "[::msgcat::mc {Taste}] " -font ${titlefont} -anchor nw
frame  .editright.1.text32
  text .editright.1.text32.message -background ${lightcolor} -width 40 -height 3 -wrap word -yscrollcommand ".editright.1.text32.scroll set"
	if { $::bTtk } {
  	ttk::scrollbar .editright.1.text32.scroll -command ".editright.1.text32.message yview"
	} else {
		scrollbar .editright.1.text32.scroll -command ".editright.1.text32.message yview"
	}
  .editright.1.text32.message insert end ${txt_taste}
pack .editright.1.text32.message -side left  -fill both -expand true
pack .editright.1.text32.scroll  -side right -fill y
::conmen .editright.1.text32.message

label  .editright.1.text41 -text "[::msgcat::mc {Impression}] " -font ${titlefont} -anchor nw
frame  .editright.1.text42
  text .editright.1.text42.message -background ${lightcolor} -width 40 -height 3 -wrap word -yscrollcommand ".editright.1.text42.scroll set"
	if { $::bTtk } {
  	ttk::scrollbar .editright.1.text42.scroll -command ".editright.1.text42.message yview"
	} else {
		scrollbar .editright.1.text42.scroll -command ".editright.1.text42.message yview"
	}
  .editright.1.text42.message insert end ${txt_impression}
pack .editright.1.text42.message -side left  -fill both -expand true
pack .editright.1.text42.scroll  -side right -fill y
::conmen .editright.1.text42.message

proc manualpointscalc {type} {
  global points_color points_luminance points_nose points_taste points_impression manualpoints
  set points_color2 [ expr "${points_color} / 25" ]
  .editright.1.text52.frame.label1r configure -text "${points_color2}/4"
  set points_luminance2 [ expr "(${points_luminance} * 3) / 50" ]
  .editright.1.text52.frame.label2r configure -text "${points_luminance2}/6"
  set points_nose2 [ expr "(${points_nose} * 3) / 10" ]
  .editright.1.text52.frame.label3r configure -text "${points_nose2}/30"
  set points_taste2 [ expr "(${points_taste} * 35) / 100" ]
  .editright.1.text52.frame.label4r configure -text "${points_taste2}/35"
  set points_impression2 [ expr "${points_impression} / 4" ]
  .editright.1.text52.frame.label5r configure -text "${points_impression2}/25"
  set summary_manual_points [ expr "${points_color2} + ${points_luminance2} + ${points_nose2} + ${points_taste2} + ${points_impression2}" ]
  .editright.1.text51.points configure -text "(${summary_manual_points}/100)"
  if { ${type} == {color} } {
    if { ${points_color2} <= {1} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Color: not according, faulty}]"
    } elseif { ${points_color2} <= {3} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Color: according}]"
    } else {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Color: very beautiful color}]"
    }
  } elseif { ${type} == {luminance} } {
    if { ${points_luminance2} <= {1} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Clarity: milky, muddy}]"
    } elseif { ${points_luminance2} <= {3} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Clarity: dusty, dully, lackluster}]"
    } elseif { ${points_luminance2} <= {5} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Clarity: pure, clear}]"
    } else {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Clarity: brilliant, shining, crystal clear}]"
    }
  } elseif { ${type} == {nose} } {
    if { ${points_nose2} <= {4} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Nose: no smell, incorrectly, badly, spoiled}]"
    } elseif { ${points_nose2} <= {12} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Nose: weak, vague, neutral}]"
    } elseif { ${points_nose2} <= {20} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Nose: according, clean}]"
    } elseif { ${points_nose2} <= {26} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Nose: aromatical, finely, accords very well}]"
    } else {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Nose: characteristical, very finely and pronounced}]"
    }
  } elseif { ${type} == {taste} } {
    if { ${points_taste2} <= {5} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Taste: no wine taste, strange, spoiled}]"
    } elseif { ${points_taste2} <= {15} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Taste: thin, little expression, straight-lined}]"
    } elseif { ${points_taste2} <= {25} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Taste: specially straight-lined, slim to contentful}]"
    } elseif { ${points_taste2} <= {32} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Taste: contentful, aromatical, rich, characterful}]"
    } else {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Taste: stylistically, outstandingly, perfectly}]"
    }
  } elseif { ${type} == {impression} } {
    if { ${points_impression2} <= {5} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Impression: unsatisfactory, inharmoniously, atypical}]"
    } elseif { ${points_impression2} <= {15} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Impression: short finish, little harmoniously to balanced}]"
    } elseif { ${points_impression2} <= {22} } {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Impression: middle to long finish, balanced, delicious}]"
    } else {
      .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Impression: long finish, exemplary, real great wine}]"
    }
  }
  if { ${manualpoints} == {true} } {
    if { ${summary_manual_points} != {0} } {
      .editright.1.labeltext.2 configure -text "(${summary_manual_points} [::msgcat::mc {Points}])"
    } else {
      .editright.1.labeltext.2 configure -text {}
      .editright.1.text51.points configure -text {}
    }
  }
}
frame .editright.1.text51
  label .editright.1.text51.text -text "[::msgcat::mc {Points}] " -font ${titlefont} -anchor nw
  label .editright.1.text51.points -text {} -font ${smallfont} -anchor nw
pack .editright.1.text51.text .editright.1.text51.points -fill x
if { $::bTtk } {
	ttk::labelframe .editright.1.text52
} else {
	labelframe .editright.1.text52
}
  checkbutton .editright.1.text52.labelwidget -text [::msgcat::mc {manual allocation of points}] -variable manualpoints -onvalue {true} -offvalue {false} -command {
    .editright.1.text52.frame.label6 configure -text {}
    foreach child [ winfo children .editright.1.text52.frame ] {
      if { ${manualpoints} == {true} } {
        ${child} configure -state normal
        .editright.1.text51.points configure -state normal
        manualpointscalc general
      } else {
        ${child} configure -state disabled
        .editright.1.text51.points configure -state disabled
        points
      }
    }
  }
  pack .editright.1.text52.labelwidget
  .editright.1.text52 configure -labelwidget .editright.1.text52.labelwidget
  frame .editright.1.text52.frame -pady 0 -padx 0
    label .editright.1.text52.frame.label1 -text " [::msgcat::mc {Color}] " -borderwidth 0
    scale .editright.1.text52.frame.scale1 -length 200 -orient horizontal -showvalue false -from 0 -to 100 -font ${smallfont} -borderwidth 1 -highlightthickness 0 -variable points_color
    label .editright.1.text52.frame.label1r -text {0/4} -font ${smallfont} -width 7 -borderwidth 0 -anchor e
  grid .editright.1.text52.frame.label1  -row 0 -column 0 -sticky nw
  grid .editright.1.text52.frame.scale1  -row 0 -column 1 -sticky ew
  grid .editright.1.text52.frame.label1r -row 0 -column 2 -sticky w
    label .editright.1.text52.frame.label2 -text " [::msgcat::mc {Clarity}] " -borderwidth 0
    scale .editright.1.text52.frame.scale2 -length 200 -orient horizontal -showvalue false -from 0 -to 100 -font ${smallfont} -borderwidth 1 -highlightthickness 0 -variable points_luminance
    label .editright.1.text52.frame.label2r -text {0/6} -font ${smallfont} -width 7 -borderwidth 0 -anchor e
  grid .editright.1.text52.frame.label2  -row 1 -column 0 -sticky nw
  grid .editright.1.text52.frame.scale2  -row 1 -column 1 -sticky ew
  grid .editright.1.text52.frame.label2r -row 1 -column 2 -sticky w
    label .editright.1.text52.frame.label3 -text " [::msgcat::mc {Nose}] " -borderwidth 0
    scale .editright.1.text52.frame.scale3 -length 200 -orient horizontal -showvalue false -from 0 -to 100 -font ${smallfont} -borderwidth 1 -highlightthickness 0 -variable points_nose
    label .editright.1.text52.frame.label3r -text {0/30} -font ${smallfont} -width 7 -borderwidth 0 -anchor e
  grid .editright.1.text52.frame.label3  -row 2 -column 0 -sticky nw
  grid .editright.1.text52.frame.scale3  -row 2 -column 1 -sticky ew
  grid .editright.1.text52.frame.label3r -row 2 -column 2 -sticky w
    label .editright.1.text52.frame.label4 -text " [::msgcat::mc {Taste}] " -borderwidth 0
    scale .editright.1.text52.frame.scale4 -length 200 -orient horizontal -showvalue false -from 0 -to 100 -font ${smallfont} -borderwidth 1 -highlightthickness 0 -variable points_taste
    label .editright.1.text52.frame.label4r -text {0/35} -font ${smallfont} -width 7 -borderwidth 0 -anchor e
  grid .editright.1.text52.frame.label4  -row 3 -column 0 -sticky nw
  grid .editright.1.text52.frame.scale4  -row 3 -column 1 -sticky ew
  grid .editright.1.text52.frame.label4r -row 3 -column 2 -sticky w
    label .editright.1.text52.frame.label5 -text " [::msgcat::mc {Impression}] " -borderwidth 0
    scale .editright.1.text52.frame.scale5 -length 200 -orient horizontal -showvalue false -from 0 -to 100 -font ${smallfont} -borderwidth 1 -highlightthickness 0 -variable points_impression
    label .editright.1.text52.frame.label5r -text {0/25} -font ${smallfont} -width 7 -borderwidth 0 -anchor e
  grid .editright.1.text52.frame.label5  -row 4 -column 0 -sticky nw
  grid .editright.1.text52.frame.scale5  -row 4 -column 1 -sticky ew
  grid .editright.1.text52.frame.label5r -row 4 -column 2 -sticky w
    label .editright.1.text52.frame.label6 -text {} -font ${smallfont} -anchor w -borderwidth 0 -width 40
  grid .editright.1.text52.frame.label6 -row 5 -sticky we -columnspan 3
pack .editright.1.text52.frame -side left -fill x -pady 0 -padx 0
if { ${manualpoints} == {false} } {
  foreach child [ winfo children .editright.1.text52.frame ] {
    ${child} configure -state disabled
    .editright.1.text51.points configure -state disabled
  }
}
trace variable points_color      w "manualpointscalc color ;#"
trace variable points_luminance  w "manualpointscalc luminance ;#"
trace variable points_nose       w "manualpointscalc nose ;#"
trace variable points_taste      w "manualpointscalc taste ;#"
trace variable points_impression w "manualpointscalc impression ;#"
set lastmouseenter {false}
bind .editright.1.text52.frame.scale1 <Enter> {
  global lastmouseenter
  if { [ .editright.1.text52.frame.label6 cget -state ] == {normal} && ${lastmouseenter} != {color} } {
    .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Color}]"
    set lastmouseenter {color}
  }
}
bind .editright.1.text52.frame.scale2 <Enter> {
  global lastmouseenter
  if { [ .editright.1.text52.frame.label6 cget -state ] == {normal} && ${lastmouseenter} != {clarity} } {
    .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Clarity}]"
    set lastmouseenter {clarity}
  }
}
bind .editright.1.text52.frame.scale3 <Enter> {
  global lastmouseenter
  if { [ .editright.1.text52.frame.label6 cget -state ] == {normal} && ${lastmouseenter} != {nose} } {
    .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Bouquet, Flavours, Evolvement}]"
    set lastmouseenter {nose}
  }
}
bind .editright.1.text52.frame.scale4 <Enter> {
  global lastmouseenter
  if { [ .editright.1.text52.frame.label6 cget -state ] == {normal} && ${lastmouseenter} != {taste} } {
    .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Fruit, Body, Sweetness, Acidity, Tannin, Structure}]"
    set lastmouseenter {taste}
  }
}
bind .editright.1.text52.frame.scale5 <Enter> {
  global lastmouseenter
  if { [ .editright.1.text52.frame.label6 cget -state ] == {normal} && ${lastmouseenter} != {impression} } {
    .editright.1.text52.frame.label6 configure -text " [::msgcat::mc {Quality, Balance, Harmony, Finesse, Typic}]"
    set lastmouseenter {impression}
  }
}
bind .editright.1.text52.frame.scale1 <Button-1> { if { [ .editright.1.text52.frame.label6 cget -state ] == {normal} } { manualpointscalc color } }
bind .editright.1.text52.frame.scale2 <Button-1> { if { [ .editright.1.text52.frame.label6 cget -state ] == {normal} } { manualpointscalc luminance } }
bind .editright.1.text52.frame.scale3 <Button-1> { if { [ .editright.1.text52.frame.label6 cget -state ] == {normal} } { manualpointscalc nose } }
bind .editright.1.text52.frame.scale4 <Button-1> { if { [ .editright.1.text52.frame.label6 cget -state ] == {normal} } { manualpointscalc taste } }
bind .editright.1.text52.frame.scale5 <Button-1> { if { [ .editright.1.text52.frame.label6 cget -state ] == {normal} } { manualpointscalc impression } }
bind .editright.1.text52.frame.scale1 <Leave>    { .editright.1.text52.frame.label6 configure -text {} }
bind .editright.1.text52.frame.scale2 <Leave>    { .editright.1.text52.frame.label6 configure -text {} }
bind .editright.1.text52.frame.scale3 <Leave>    { .editright.1.text52.frame.label6 configure -text {} }
bind .editright.1.text52.frame.scale4 <Leave>    { .editright.1.text52.frame.label6 configure -text {} }
bind .editright.1.text52.frame.scale5 <Leave>    { .editright.1.text52.frame.label6 configure -text {} }
#
########################################################################
# end
########################################################################

########################################################################
# ungrided widgets for alternative usage view
########################################################################
#
set corkmenulength [ string length [::msgcat::mc {Cork}] ]
if { [ string length [::msgcat::mc {Granulate}] ] > ${corkmenulength} } { set corkmenulength [ string length [::msgcat::mc {Granulate}] ] }
if { [ string length [::msgcat::mc {Extrusion}] ] > ${corkmenulength} } { set corkmenulength [ string length [::msgcat::mc {Extrusion}] ] }
if { [ string length [::msgcat::mc {Glass}] ]     > ${corkmenulength} } { set corkmenulength [ string length [::msgcat::mc {Glass}] ] }
if { [ string length [::msgcat::mc {Screw}] ]     > ${corkmenulength} } { set corkmenulength [ string length [::msgcat::mc {Screw}] ] }
if { [ string length [::msgcat::mc {Stainless}] ] > ${corkmenulength} } { set corkmenulength [ string length [::msgcat::mc {Stainless}] ] }
if { [ string length [::msgcat::mc {unset}] ]     > ${corkmenulength} } { set corkmenulength [ string length [::msgcat::mc {unset}] ] }
label .editright.1.cork1 -text "[::msgcat::mc {Stopper}] " -font ${titlefont}
frame .editright.1.cork2
  menubutton .editright.1.cork2.cork -text {} -menu .editright.1.cork2.cork.menu -background ${lightcolor} -relief sunken -borderwidth 2 -padx 1 -pady 1 -width ${corkmenulength} -anchor w
  set corkmenu [ menu .editright.1.cork2.cork.menu -tearoff 0 ]
  ${corkmenu} add command -label [::msgcat::mc {Cork}] -command {
    set cork "Natural"
    .editright.1.cork2.cork configure -text [::msgcat::mc {Cork}]
    corkquality_state enable
  }
  ${corkmenu} add command -label [::msgcat::mc {Granulate}] -command {
    set cork "Granulate"
    .editright.1.cork2.cork configure -text [::msgcat::mc {Granulate}]
    corkquality_state enable
  }
  ${corkmenu} add command -label [::msgcat::mc {Extrusion}] -command {
    set cork "Extrusion"
    .editright.1.cork2.cork configure -text [::msgcat::mc {Extrusion}]
    corkquality_state disable
  }
  ${corkmenu} add command -label [::msgcat::mc {Glass}] -command {
    set cork "Glas"
    .editright.1.cork2.cork configure -text [::msgcat::mc {Glass}]
    corkquality_state disable
  }
  ${corkmenu} add command -label [::msgcat::mc {Screw}] -command {
    set cork "Screw"
    .editright.1.cork2.cork configure -text [::msgcat::mc {Screw}]
    corkquality_state disable
  }
  ${corkmenu} add command -label [::msgcat::mc {Stainless}] -command {
    set cork "Stainless"
    .editright.1.cork2.cork configure -text [::msgcat::mc {Stainless}]
    corkquality_state disable
  }
  ${corkmenu} add separator
  ${corkmenu} add command -label [::msgcat::mc {unset}] -command {
    set cork {}
    .editright.1.cork2.cork configure -text [::msgcat::mc {unset}]
    corkquality_state disable
  }
  if { [ info exists cork ] } {
    if { ${cork} == "Natural" } {
      .editright.1.cork2.cork configure -text [::msgcat::mc {Cork}]
    } elseif { ${cork} == "Granulate" } {
      .editright.1.cork2.cork configure -text [::msgcat::mc {Granulate}]
    } elseif { ${cork} == "Extrusion" } {
      .editright.1.cork2.cork configure -text [::msgcat::mc {Extrusion}]
    } elseif { ${cork} == "Glas" } {
      .editright.1.cork2.cork configure -text [::msgcat::mc {Glass}]
    } elseif { ${cork} == "Screw" } {
      .editright.1.cork2.cork configure -text [::msgcat::mc {Screw}]
    } elseif { ${cork} == "Stainless" } {
      .editright.1.cork2.cork configure -text [::msgcat::mc {Stainless}]
    } else {
      .editright.1.cork2.cork configure -text [::msgcat::mc {unset}]
    }
  }
  # get the lengths of the secondary fields
  set corkqualitylength [ string length [::msgcat::mc {unset}] ]
  if { [ string length [::msgcat::mc {broken}] ]     > ${corkqualitylength} } { set corkqualitylength [ string length [::msgcat::mc {broken}] ] }
  if { [ string length [::msgcat::mc {critical}] ]   > ${corkqualitylength} } { set corkqualitylength [ string length [::msgcat::mc {critical}] ] }
  if { [ string length [::msgcat::mc {acceptable}] ] > ${corkqualitylength} } { set corkqualitylength [ string length [::msgcat::mc {acceptable}] ] }
  if { [ string length [::msgcat::mc {good}] ]       > ${corkqualitylength} } { set corkqualitylength [ string length [::msgcat::mc {good}] ] }
  if { [ string length [::msgcat::mc {excellent}] ]  > ${corkqualitylength} } { set corkqualitylength [ string length [::msgcat::mc {excellent}] ] }
  label .editright.1.cork2.text -text " [::msgcat::mc {Quality}] " -font ${titlefont} -anchor w
  menubutton .editright.1.cork2.quality -text {} -menu .editright.1.cork2.quality.menu -background ${lightcolor} -relief sunken -borderwidth 2 -padx 1 -pady 1 -width ${corkqualitylength} -anchor w
  set qualitymenu [ menu .editright.1.cork2.quality.menu -tearoff 0 ]
  ${qualitymenu} add command -label [::msgcat::mc {broken}] -command {
    set corkquality {1}
    .editright.1.cork2.quality configure -text [::msgcat::mc {broken}]
  }
  ${qualitymenu} add command -label [::msgcat::mc {critical}] -command {
    set corkquality {2}
    .editright.1.cork2.quality configure -text [::msgcat::mc {critical}]
  }
  ${qualitymenu} add command -label [::msgcat::mc {acceptable}] -command {
    set corkquality {3}
    .editright.1.cork2.quality configure -text [::msgcat::mc {acceptable}]
  }
  ${qualitymenu} add command -label [::msgcat::mc {good}] -command {
    set corkquality {4}
    .editright.1.cork2.quality configure -text [::msgcat::mc {good}]
  }
  ${qualitymenu} add command -label [::msgcat::mc {excellent}] -command {
    set corkquality {5}
    .editright.1.cork2.quality configure -text [::msgcat::mc {excellent}]
  }
  ${qualitymenu} add separator
  ${qualitymenu} add command -label [::msgcat::mc {unset}] -command {
    set corkquality {}
    .editright.1.cork2.quality configure -text {}
  }
  if { [ info exists corkquality ] } {
    if { ${corkquality} == {1} } {
      .editright.1.cork2.quality configure -text [::msgcat::mc {broken}]
    } elseif { ${corkquality} == {2} } {
      .editright.1.cork2.quality configure -text [::msgcat::mc {critical}]
    } elseif { ${corkquality} == {3} } {
      .editright.1.cork2.quality configure -text [::msgcat::mc {acceptable}]
    } elseif { ${corkquality} == {4} } {
      .editright.1.cork2.quality configure -text [::msgcat::mc {good}]
    } elseif { ${corkquality} == {5} } {
      .editright.1.cork2.quality configure -text [::msgcat::mc {excellent}]
    }
  }
  pack .editright.1.cork2.cork .editright.1.cork2.text .editright.1.cork2.quality -side left
if { ${cork} != "Natural" && ${cork} != "Granulate" } { corkquality_state disable }
bind .editright.1.cork2.cork    <Button-3> { tk_popup ${corkmenu} %X %Y }
bind .editright.1.cork2.quality <Button-3> { if { [ .editright.1.cork2.quality cget -state ] != {disabled} } { tk_popup ${qualitymenu} %X %Y } }

set air2 ${air}
# we need to save air-date to set it right at start-up
set air_date_saved ${air_date}
proc air_update {} {
  global air air_date today_month today_year
  set air_date "${today_month}/${today_year}"
  .editright.1.air1 configure -text "${air_date} "
  if { ${air} == {1} } {
    .editright.1.air2.text2 configure -text [::msgcat::mc {Hour}]
  } else {
    .editright.1.air2.text2 configure -text [::msgcat::mc {Hours}]
  }
}
if { ${glassname01} == {} } { set glassname01 [::msgcat::mc {Glass #1}] }
if { ${glassname02} == {} } { set glassname02 [::msgcat::mc {Glass #2}] }
if { ${glassname03} == {} } { set glassname03 [::msgcat::mc {Glass #3}] }
if { ${glassname04} == {} } { set glassname04 [::msgcat::mc {Glass #4}] }
if { ${glassname05} == {} } { set glassname05 [::msgcat::mc {Glass #5}] }
if { ${glassname06} == {} } { set glassname06 [::msgcat::mc {Glass #6}] }
if { ${glassname07} == {} } { set glassname07 [::msgcat::mc {Glass #7}] }
if { ${glassname08} == {} } { set glassname08 [::msgcat::mc {Glass #8}] }
if { ${glassname09} == {} } { set glassname09 [::msgcat::mc {Glass #9}] }
if { ${glassname10} == {} } { set glassname10 [::msgcat::mc {Glass #10}] }
proc glass1 {} {
  global glass lightcolor glassname01
  set glass {1}
  .editright.1.air2.glass configure -text ${glassname01}
  air_update
}
proc glass2 {} {
  global glass lightcolor glassname02
  set glass {2}
  .editright.1.air2.glass configure -text ${glassname02}
  air_update
}
proc glass3 {} {
  global glass lightcolor glassname03
  set glass {3}
  .editright.1.air2.glass configure -text ${glassname03}
  air_update
}
proc glass4 {} {
  global glass lightcolor glassname04
  set glass {4}
  .editright.1.air2.glass configure -text ${glassname04}
  air_update
}
proc glass5 {} {
  global glass lightcolor glassname05
  set glass {5}
  .editright.1.air2.glass configure -text ${glassname05}
  air_update
}
proc glass6 {} {
  global glass lightcolor glassname06
  set glass {6}
  .editright.1.air2.glass configure -text ${glassname06}
  air_update
}
proc glass7 {} {
  global glass lightcolor glassname07
  set glass {7}
  .editright.1.air2.glass configure -text ${glassname07}
  air_update
}
proc glass8 {} {
  global glass lightcolor glassname08
  set glass {8}
  .editright.1.air2.glass configure -text ${glassname08}
  air_update
}
proc glass9 {} {
  global glass lightcolor glassname09
  set glass {9}
  .editright.1.air2.glass configure -text ${glassname09}
  air_update
}
proc glass10 {} {
  global glass lightcolor glassname10
  set glass {10}
  .editright.1.air2.glass configure -text ${glassname10}
  air_update
}
label .editright.1.air1 -text {} -font ${titlefont}
proc air_label {} {
  global air_date air_date air_decanter glass today_month today_year
  if { ${air_date} == {} && ${air_decanter} == {} && ${glass} == {} } {
    .editright.1.air1 configure -text "[::msgcat::mc {Usage}] "
  } else {
    if { ${air_date} == {} } { set air_date "${today_month}/${today_year}" }
    .editright.1.air1 configure -text "${air_date} "
  }
}
frame .editright.1.air2
  set temperature2 ${temperature}
  label .editright.1.air2.temperature1 -text "[::msgcat::mc {Temperature}] "
  frame .editright.1.air2.temperature2
    if { ${tempscale} == {fahrenheit} } {
      spinbox .editright.1.air2.temperature2.spin -textvariable temperature -from 40 -to 66 -width 4 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 3 } }
      label .editright.1.air2.temperature2.text -text {°F}
      menubutton .editright.1.air2.temperature2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.air2.temperature2.help.menu
      set temperaturemenu [ menu .editright.1.air2.temperature2.help.menu -tearoff 0 ]
      ${temperaturemenu} add command -label "40" -command { .editright.1.air2.temperature2.spin set "40" }
      ${temperaturemenu} add command -label "42" -command { .editright.1.air2.temperature2.spin set "42" }
      ${temperaturemenu} add command -label "44" -command { .editright.1.air2.temperature2.spin set "44" }
      ${temperaturemenu} add command -label "46" -command { .editright.1.air2.temperature2.spin set "46" }
      ${temperaturemenu} add command -label "48" -command { .editright.1.air2.temperature2.spin set "48" }
      ${temperaturemenu} add command -label "50" -command { .editright.1.air2.temperature2.spin set "50" }
      ${temperaturemenu} add command -label "52" -command { .editright.1.air2.temperature2.spin set "52" }
      ${temperaturemenu} add command -label "54" -command { .editright.1.air2.temperature2.spin set "54" }
      ${temperaturemenu} add command -label "56" -command { .editright.1.air2.temperature2.spin set "56" }
      ${temperaturemenu} add command -label "58" -command { .editright.1.air2.temperature2.spin set "58" }
      ${temperaturemenu} add command -label "60" -command { .editright.1.air2.temperature2.spin set "60" }
      ${temperaturemenu} add command -label "62" -command { .editright.1.air2.temperature2.spin set "62" }
      ${temperaturemenu} add command -label "64" -command { .editright.1.air2.temperature2.spin set "64" }
      ${temperaturemenu} add command -label "66" -command { .editright.1.air2.temperature2.spin set "66" }
    } else {
      spinbox .editright.1.air2.temperature2.spin -textvariable temperature -from 5 -to 18 -width 4 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 3 } }
      label .editright.1.air2.temperature2.text -text {°C}
      menubutton .editright.1.air2.temperature2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.air2.temperature2.help.menu
      set temperaturemenu [ menu .editright.1.air2.temperature2.help.menu -tearoff 0 ]
      ${temperaturemenu} add command -label {5} -command { .editright.1.air2.temperature2.spin set {5} }
      ${temperaturemenu} add command -label {6} -command { .editright.1.air2.temperature2.spin set {6} }
      ${temperaturemenu} add command -label {7} -command { .editright.1.air2.temperature2.spin set {7} }
      ${temperaturemenu} add command -label {8} -command { .editright.1.air2.temperature2.spin set {8} }
      ${temperaturemenu} add command -label {9} -command { .editright.1.air2.temperature2.spin set {9} }
      ${temperaturemenu} add command -label {10} -command { .editright.1.air2.temperature2.spin set {10} }
      ${temperaturemenu} add command -label {11} -command { .editright.1.air2.temperature2.spin set {11} }
      ${temperaturemenu} add command -label {12} -command { .editright.1.air2.temperature2.spin set {12} }
      ${temperaturemenu} add command -label {13} -command { .editright.1.air2.temperature2.spin set {13} }
      ${temperaturemenu} add command -label {14} -command { .editright.1.air2.temperature2.spin set {14} }
      ${temperaturemenu} add command -label {15} -command { .editright.1.air2.temperature2.spin set {15} }
      ${temperaturemenu} add command -label {16} -command { .editright.1.air2.temperature2.spin set {16} }
      ${temperaturemenu} add command -label {17} -command { .editright.1.air2.temperature2.spin set {17} }
      ${temperaturemenu} add command -label {18} -command { .editright.1.air2.temperature2.spin set {18} }
    }
    if { ${temperature2} != {} } {
      .editright.1.air2.temperature2.spin set ${temperature}
    } else {
	  	.editright.1.air2.temperature2.spin set {}
    }
  pack .editright.1.air2.temperature2.spin .editright.1.air2.temperature2.text .editright.1.air2.temperature2.help -side left
  bind .editright.1.air2.temperature2.spin <Button-3> { tk_popup ${temperaturemenu} %X %Y }
grid .editright.1.air2.temperature1 -sticky w -row 0 -column 0
grid .editright.1.air2.temperature2 -sticky w -row 0 -column 1 -columnspan 2
  label .editright.1.air2.text1 -text "[::msgcat::mc {Air}] "
  spinbox .editright.1.air2.air -from 0 -to 99.5 -increment .5 -textvariable air -width 4 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is double %P ] && [ string length %P ] < 5 } }
  set airmenu [ menu .editright.1.air2.air.menu -tearoff 0 ]
  ${airmenu} add command -label {0.0} -command { .editright.1.air2.air set {0.0} }
  ${airmenu} add command -label {0.5} -command { .editright.1.air2.air set {0.5} }
  ${airmenu} add command -label {1.0} -command { .editright.1.air2.air set {1.0} }
  ${airmenu} add command -label {1.5} -command { .editright.1.air2.air set {1.5} }
  ${airmenu} add command -label {2.0} -command { .editright.1.air2.air set {2.0} }
  ${airmenu} add command -label {2.5} -command { .editright.1.air2.air set {2.5} }
  ${airmenu} add command -label {3.0} -command { .editright.1.air2.air set {3.0} }
  ${airmenu} add command -label {3.5} -command { .editright.1.air2.air set {3.5} }
  ${airmenu} add command -label {4.0} -command { .editright.1.air2.air set {4.0} }
  ${airmenu} add command -label {4.5} -command { .editright.1.air2.air set {4.5} }
  ${airmenu} add command -label {5.0} -command { .editright.1.air2.air set {5.0} }
  ${airmenu} add command -label {5.5} -command { .editright.1.air2.air set {5.5} }
  ${airmenu} add command -label {6.0} -command { .editright.1.air2.air set {6.0} }
  ${airmenu} add command -label {7.0} -command { .editright.1.air2.air set {7.0} }
  ${airmenu} add command -label {8.0} -command { .editright.1.air2.air set {8.0} }
  ${airmenu} add command -label {9.0} -command { .editright.1.air2.air set {9.0} }
  ${airmenu} add command -label {12.0} -command { .editright.1.air2.air set {12.0} }
  ${airmenu} add command -label {18.0} -command { .editright.1.air2.air set {18.0} }
  ${airmenu} add command -label {24.0} -command { .editright.1.air2.air set {24.0} }
  ${airmenu} add command -label {48.0} -command { .editright.1.air2.air set {48.0} }
  bind .editright.1.air2.air <Button-3> { tk_popup ${airmenu} %X %Y }
  # comma to point translation
  bind .editright.1.air2.air <KeyPress> {
    if { "%A" == {,} && ![ regexp {\.} ${air} ] } {
      append air {.}
      .editright.1.air2.air icursor end
    }
  }
  .editright.1.air2.air set ${air2}
  if { ${air} == {1} } {
    label .editright.1.air2.text2 -text [::msgcat::mc {Hour}] -anchor w
  } else {
    label .editright.1.air2.text2 -text [::msgcat::mc {Hours}] -anchor w
  }
grid .editright.1.air2.text1 -sticky w  -row 1 -column 0
grid .editright.1.air2.air   -sticky w  -row 1 -column 1
grid .editright.1.air2.text2 -sticky we -row 1 -column 2
grid columnconfigure .editright.1.air2 2 -weight 1
  label .editright.1.air2.decantertext -text "[::msgcat::mc {Decanter}] "
  set decanterwidth [ string length [::msgcat::mc {yes}] ]
  if { [ string length [::msgcat::mc {no}] ] > ${decanterwidth} } { set decanterwidth [ string length [::msgcat::mc {no}] ] }
  menubutton .editright.1.air2.decanter -text {} -menu .editright.1.air2.decanter.menu -width ${decanterwidth} -background ${lightcolor} -relief sunken -borderwidth 2 -padx 1 -pady 1 -anchor w
  set decantermenu [ menu .editright.1.air2.decanter.menu -tearoff 0 ]
  ${decantermenu} add command -label [::msgcat::mc {unset}] -command {
    set air_decanter {}
    .editright.1.air2.decanter configure -text {}
  }
  ${decantermenu} add command -label [::msgcat::mc {yes}] -command {
    set air_decanter {true}
    .editright.1.air2.decanter configure -text [::msgcat::mc {yes}]
    air_update
  }
  ${decantermenu} add command -label [::msgcat::mc {no}] -command {
    set air_decanter {false}
    .editright.1.air2.decanter configure -text [::msgcat::mc {no}]
    air_update
  }
  if { ${air_decanter} == {true} } {
    .editright.1.air2.decanter configure -text [::msgcat::mc {yes}]
  } elseif { ${air_decanter} == {false} } {
    .editright.1.air2.decanter configure -text [::msgcat::mc {no}]
  }
grid .editright.1.air2.decantertext -sticky w -row 2 -column 0
grid .editright.1.air2.decanter     -sticky w -row 2 -column 1 -columnspan 2
set glassnamesmenulength [ string length ${glassname01} ]
if { [ string length ${glassname02} ] > ${glassnamesmenulength} } { set glassnamesmenulength [ string length ${glassname02} ] }
if { [ string length ${glassname03} ] > ${glassnamesmenulength} } { set glassnamesmenulength [ string length ${glassname03} ] }
if { [ string length ${glassname04} ] > ${glassnamesmenulength} } { set glassnamesmenulength [ string length ${glassname04} ] }
if { [ string length ${glassname05} ] > ${glassnamesmenulength} } { set glassnamesmenulength [ string length ${glassname05} ] }
if { [ string length ${glassname06} ] > ${glassnamesmenulength} } { set glassnamesmenulength [ string length ${glassname06} ] }
if { [ string length ${glassname07} ] > ${glassnamesmenulength} } { set glassnamesmenulength [ string length ${glassname07} ] }
if { [ string length ${glassname08} ] > ${glassnamesmenulength} } { set glassnamesmenulength [ string length ${glassname08} ] }
if { [ string length ${glassname09} ] > ${glassnamesmenulength} } { set glassnamesmenulength [ string length ${glassname09} ] }
if { [ string length ${glassname10} ] > ${glassnamesmenulength} } { set glassnamesmenulength [ string length ${glassname10} ] }
label .editright.1.air2.glasstext -text "[::msgcat::mc {Wine Glass}] "
menubutton .editright.1.air2.glass -text {} -width ${glassnamesmenulength} -menu .editright.1.air2.glass.menu -padx 1 -pady 1 -relief sunken -background ${lightcolor} -borderwidth 2 -anchor w
  set glasssesmenu [ menu .editright.1.air2.glass.menu -tearoff 0 ]
  ${glasssesmenu} add command -label ${glassname01} -command { glass1 }
  ${glasssesmenu} add command -label ${glassname02} -command { glass2 }
  ${glasssesmenu} add command -label ${glassname03} -command { glass3 }
  ${glasssesmenu} add command -label ${glassname04} -command { glass4 }
  ${glasssesmenu} add command -label ${glassname05} -command { glass5 }
  ${glasssesmenu} add command -label ${glassname06} -command { glass6 }
  ${glasssesmenu} add command -label ${glassname07} -command { glass7 }
  ${glasssesmenu} add command -label ${glassname08} -command { glass8 }
  ${glasssesmenu} add command -label ${glassname09} -command { glass9 }
  ${glasssesmenu} add command -label ${glassname10} -command { glass10 }
  ${glasssesmenu} add separator
  ${glasssesmenu} add command -label [::msgcat::mc {unset}] -command {
    set glass {}
    .editright.1.air2.glass configure -text {}
    if { ${air} == {} && ${air_decanter} == {} } {
      set air_date {}
      air_label
    }
  }
grid .editright.1.air2.glasstext -sticky w -row 3 -column 0
grid .editright.1.air2.glass     -sticky w -row 3 -column 1 -columnspan 2
if { ${glass} != {} } { glass${glass} }
# reset air_date
set air_date ${air_date_saved}
air_label
bind .editright.1.air2.decanter <Button-3> { tk_popup ${decantermenu} %X %Y }
bind .editright.1.air2.glass    <Button-3> { tk_popup ${glasssesmenu} %X %Y }

set colormenulength [ string length [::msgcat::mc {Garnet}] ]
if { [ string length [::msgcat::mc {Brick}] ]   > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Brick}] ] }
if { [ string length [::msgcat::mc {Purple}] ]  > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Purple}] ] }
if { [ string length [::msgcat::mc {Cherry}] ]  > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Cherry}] ] }
if { [ string length [::msgcat::mc {Ruby}] ]    > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Ruby}] ] }
if { [ string length [::msgcat::mc {Black}] ]   > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Black}] ] }
if { [ string length [::msgcat::mc {Bright}] ]  > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Bright}] ] }
if { [ string length [::msgcat::mc {Straw}] ]   > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Straw}] ] }
if { [ string length [::msgcat::mc {Citron}] ]  > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Citron}] ] }
if { [ string length [::msgcat::mc {Gold}] ]    > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Gold}] ] }
if { [ string length [::msgcat::mc {Oldgold}] ] > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Oldgold}] ] }
if { [ string length [::msgcat::mc {Amber}] ]   > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Amber}] ] }
if { [ string length [::msgcat::mc {Russet}] ]  > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Russet}] ] }
if { [ string length [::msgcat::mc {Salmon}] ]  > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Salmon}] ] }
if { [ string length [::msgcat::mc {Pinkish}] ] > ${colormenulength} } { set colormenulength [ string length [::msgcat::mc {Pinkish}] ] }
label .editright.1.tint1 -text "[::msgcat::mc {Tint}] " -font ${titlefont}
frame .editright.1.tint2
  if { ${color} == {Red} } {
    menubutton .editright.1.tint2.button -text ${tint} -menu .editright.1.tint2.button.tintmenured -background ${lightcolor} -relief sunken -borderwidth 2 -padx 1 -pady 1 -width ${colormenulength} -anchor w
  } elseif { ${color} == {White} } {
    menubutton .editright.1.tint2.button -text ${tint} -menu .editright.1.tint2.button.tintmenuwhite -background ${lightcolor} -relief sunken -borderwidth 2 -padx 1 -pady 1 -width ${colormenulength} -anchor w
  } elseif { ${color} == "Ros\u00e9" } {
    menubutton .editright.1.tint2.button -text ${tint} -menu .editright.1.tint2.button.tintmenurose -background ${lightcolor} -relief sunken -borderwidth 2 -padx 1 -pady 1 -width ${colormenulength} -anchor w
  } elseif { ${color} == {Colorless} } {
    menubutton .editright.1.tint2.button -text ${tint} -menu .editright.1.tint2.button.tintmenured -background ${lightcolor} -relief sunken -borderwidth 2 -padx 1 -pady 1 -width ${colormenulength} -anchor w
    .editright.1.tint1        configure -state disabled
    .editright.1.tint2.button configure -state disabled
  }
pack .editright.1.tint2.button -side left
set tintmenured [ menu .editright.1.tint2.button.tintmenured -tearoff 0 ]
${tintmenured} add command -label [::msgcat::mc {Garnet}] -background "#ba4a00" -activebackground "#ba4a00" -foreground {#ffffff} -activeforeground {#ffffff} -command {
  set tint "Garnet"
  colorchange ${tint}
}
${tintmenured} add command -label [::msgcat::mc {Brick}] -background "#a31000" -activebackground "#a31000" -foreground {#ffffff} -activeforeground {#ffffff} -command {
  set tint "Brick"
  colorchange ${tint}
}
${tintmenured} add command -label [::msgcat::mc {Purple}] -background "#910011" -activebackground "#910011" -foreground {#ffffff} -activeforeground {#ffffff} -command {
  set tint "Purple"
  colorchange ${tint}
}
${tintmenured} add command -label [::msgcat::mc {Cherry}] -background "#780018" -activebackground "#780018" -foreground {#ffffff} -activeforeground {#ffffff} -command {
  set tint "Cherry"
  colorchange ${tint}
}
${tintmenured} add command -label [::msgcat::mc {Ruby}] -background "#6e0010" -activebackground "#6e0010" -foreground {#ffffff} -activeforeground {#ffffff} -command {
  set tint "Ruby"
  colorchange ${tint}
}
${tintmenured} add command -label [::msgcat::mc {Black}] -background "#540012" -activebackground "#540012" -foreground {#ffffff} -activeforeground {#ffffff} -command {
  set tint "Black"
  colorchange ${tint}
}
${tintmenured} add separator
${tintmenured} add command -label [::msgcat::mc {unset}] -command {
  set tint {}
  .editright.1.tint2.button configure -text ${tint} -background ${lightcolor} -foreground ${textcolor}
}
set tintmenuwhite [ menu .editright.1.tint2.button.tintmenuwhite -tearoff 0 ]
${tintmenuwhite} add command -label [::msgcat::mc {Bright}] -background "#fcffe8" -activebackground "#fcffe8" -foreground "#000000" -activeforeground "#000000" -command {
  set tint "Bright"
  colorchange ${tint}
}
${tintmenuwhite} add command -label [::msgcat::mc {Straw}] -background "#fcffcc" -activebackground "#fcffcc" -foreground "#000000" -activeforeground "#000000" -command {
  set tint "Straw"
  colorchange ${tint}
}
${tintmenuwhite} add command -label [::msgcat::mc {Citron}] -background "#fffeb3" -activebackground "#fffeb3" -foreground "#000000" -activeforeground "#000000" -command {
  set tint "Citron"
  colorchange ${tint}
}
${tintmenuwhite} add command -label [::msgcat::mc {Gold}] -background "#fff88f" -activebackground "#fff88f" -foreground "#000000" -activeforeground "#000000" -command {
  set tint "Gold"
  colorchange ${tint}
}
${tintmenuwhite} add command -label [::msgcat::mc {Oldgold}] -background "#ffed75" -activebackground "#ffed75" -foreground "#000000" -activeforeground "#000000" -command {
  set tint "Oldgold"
  colorchange ${tint}
}
${tintmenuwhite} add command -label [::msgcat::mc {Amber}] -background "#ffe666" -activebackground "#ffe666" -foreground "#000000" -activeforeground "#000000" -command {
  set tint "Amber"
  colorchange ${tint}
}
${tintmenuwhite} add separator
${tintmenuwhite} add command -label [::msgcat::mc {unset}] -command {
  set tint {}
  .editright.1.tint2.button configure -text ${tint} -background ${lightcolor} -foreground ${textcolor}
}
set tintmenurose [ menu .editright.1.tint2.button.tintmenurose -tearoff 0 ]
${tintmenurose} add command -label [::msgcat::mc {Russet}] -background "#ffd6b5" -activebackground "#ffd6b5" -foreground "#000000" -activeforeground "#000000" -command {
  set tint "Russet"
  colorchange ${tint}
}
${tintmenurose} add command -label [::msgcat::mc {Salmon}] -background "#ffc5b8" -activebackground "#ffc5b8" -foreground "#000000" -activeforeground "#000000" -command {
  set tint "Salmon"
  colorchange ${tint}
}
${tintmenurose} add command -label [::msgcat::mc {Pinkish}] -background "#ffa091" -activebackground "#ffa091" -foreground "#000000" -activeforeground "#000000" -command {
  set tint "Pinkish"
  colorchange ${tint}
}
${tintmenurose} add separator
${tintmenurose} add command -label [::msgcat::mc {unset}] -command {
  set tint {}
  .editright.1.tint2.button configure -text ${tint} -background ${lightcolor} -foreground ${textcolor}
}
bind .editright.1.tint2.button <Button-3> { tk_popup [ .editright.1.tint2.button cget -menu ] %X %Y }

set tastetypelength [ string length [::msgcat::mc {microbiological}] ]
if { [ string length [::msgcat::mc {floral}] ]      > ${tastetypelength} } { set tastetypelength [ string length [::msgcat::mc {floral}] ] }
if { [ string length [::msgcat::mc {spicy}] ]       > ${tastetypelength} } { set tastetypelength [ string length [::msgcat::mc {spicy}] ] }
if { [ string length [::msgcat::mc {fruity}] ]      > ${tastetypelength} } { set tastetypelength [ string length [::msgcat::mc {fruity}] ] }
if { [ string length [::msgcat::mc {vegetal}] ]     > ${tastetypelength} } { set tastetypelength [ string length [::msgcat::mc {vegetal}] ] }
if { [ string length [::msgcat::mc {nutty}] ]       > ${tastetypelength} } { set tastetypelength [ string length [::msgcat::mc {nutty}] ] }
if { [ string length [::msgcat::mc {caramelized}] ] > ${tastetypelength} } { set tastetypelength [ string length [::msgcat::mc {caramelized}] ] }
if { [ string length [::msgcat::mc {woody}] ]       > ${tastetypelength} } { set tastetypelength [ string length [::msgcat::mc {woody}] ] }
if { [ string length [::msgcat::mc {earthy}] ]      > ${tastetypelength} } { set tastetypelength [ string length [::msgcat::mc {earthy}] ] }
if { [ string length [::msgcat::mc {chemical}] ]    > ${tastetypelength} } { set tastetypelength [ string length [::msgcat::mc {chemical}] ] }
if { [ string length [::msgcat::mc {pungent}] ]     > ${tastetypelength} } { set tastetypelength [ string length [::msgcat::mc {pungent}] ] }
if { [ string length [::msgcat::mc {oxidized}] ]    > ${tastetypelength} } { set tastetypelength [ string length [::msgcat::mc {oxidized}] ] }
set tastetype2 ${tastetype}
label .editright.1.tastetype1 -text "[::msgcat::mc {Type of Taste}] " -font ${titlefont} -anchor w
frame .editright.1.tastetype2
  menubutton .editright.1.tastetype2.menu -menu .editright.1.tastetype2.menu.menu -relief sunken -borderwidth 2 -background ${lightcolor} -padx 1 -pady 1 -width ${tastetypelength} -anchor w
  set tastetypemenu [ menu .editright.1.tastetype2.menu.menu -tearoff 0 ]
  ${tastetypemenu} add command -label [::msgcat::mc {microbiological}] -command {
    set tastetype {microbiological} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {microbiological}]
  }
  ${tastetypemenu} add command -label [::msgcat::mc {floral}] -command {
    set tastetype {floral} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {floral}]
  }
  ${tastetypemenu} add command -label [::msgcat::mc {spicy}] -command {
    set tastetype {spicy} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {spicy}]
  }
  ${tastetypemenu} add command -label [::msgcat::mc {fruity}] -command {
    set tastetype {fruity} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {fruity}]
  }
  ${tastetypemenu} add command -label [::msgcat::mc {vegetal}] -command {
    set tastetype {vegetal} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {vegetal}]
  }
  ${tastetypemenu} add command -label [::msgcat::mc {nutty}] -command {
    set tastetype {nutty} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {nutty}]
  }
  ${tastetypemenu} add command -label [::msgcat::mc {caramelized}] -command {
    set tastetype {caramelized} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {caramelized}]
  }
  ${tastetypemenu} add command -label [::msgcat::mc {woody}] -command {
    set tastetype {woody} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {woody}]
  }
  ${tastetypemenu} add command -label [::msgcat::mc {earthy}] -command {
    set tastetype {earthy} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {earthy}]
  }
  ${tastetypemenu} add command -label [::msgcat::mc {chemical}] -command {
    set tastetype {chemical} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {chemical}]
  }
  ${tastetypemenu} add command -label [::msgcat::mc {pungent}] -command {
    set tastetype {pungent} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {pungent}]
  }
  ${tastetypemenu} add command -label [::msgcat::mc {oxidized}] -command {
    set tastetype {oxidized} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {oxidized}]
  }
  ${tastetypemenu} add separator
  ${tastetypemenu} add command -label [::msgcat::mc {unset}] -command {
    set tastetype {} 
    .editright.1.tastetype2.menu configure -text {}
  }
  menubutton .editright.1.tastetype2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.tastetype2.help.menu
  set tastetypemenu2 [ menu .editright.1.tastetype2.help.menu -tearoff 0 ]
  ${tastetypemenu2} add command -label {          } -background {#fff753} -activebackground {#fff753} -font ${smallfont} -command {
    set tastetype {floral} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {floral}]
  }
  ${tastetypemenu2} add command -label {          } -background {#3c5a1e} -activebackground {#3c5a1e} -font ${smallfont} -command {
    set tastetype {spicy} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {spicy}]
  }
  ${tastetypemenu2} add command -label {          } -background {#d90200} -activebackground {#d90200} -font ${smallfont} -command {
    set tastetype {fruity} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {fruity}]
  }
  ${tastetypemenu2} add command -label {          } -background {#49cb00} -activebackground {#49cb00} -font ${smallfont} -command {
    set tastetype {vegetal} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {vegetal}]
  }
  ${tastetypemenu2} add command -label {          } -background {#68591b} -activebackground {#68591b} -font ${smallfont} -command {
    set tastetype {woody} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {woody}]
  }
  ${tastetypemenu2} add command -label {          } -background {#ab8814} -activebackground {#ab8814} -font ${smallfont} -command {
    set tastetype {earthy} 
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {earthy}]
  }
  if { ${tastetype} == {microbiological} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {microbiological}]
  } elseif { ${tastetype} == {floral} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {floral}]
  } elseif { ${tastetype} == {spicy} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {spicy}]
  } elseif { ${tastetype} == {fruity} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {fruity}]
  } elseif { ${tastetype} == {vegetal} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {vegetal}]
  } elseif { ${tastetype} == {nutty} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {nutty}]
  } elseif { ${tastetype} == {caramelized} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {caramelized}]
  } elseif { ${tastetype} == {woody} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {woody}]
  } elseif { ${tastetype} == {earthy} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {earthy}]
  } elseif { ${tastetype} == {chemical} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {chemical}]
  } elseif { ${tastetype} == {pungent} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {pungent}]
  } elseif { ${tastetype} == {oxidized} } {
    .editright.1.tastetype2.menu configure -text [::msgcat::mc {oxidized}]
  }
pack .editright.1.tastetype2.menu .editright.1.tastetype2.help -side left
bind .editright.1.tastetype2.menu <Button-3> { tk_popup ${tastetypemenu}  %X %Y }

label .editright.1.aroma1 -text "[::msgcat::mc {Aroma}] " -font ${titlefont} -anchor w
frame .editright.1.aroma2
  entry  .editright.1.aroma2.entry1  -textvariable aroma1 -width 18 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
pack .editright.1.aroma2.entry1 -side left -fill x -expand true
  button .editright.1.aroma2.button1 -image ${helpbutton} -anchor nw -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -command { set aromabutton {1} ; source [ file join ${prog_dir} tcl aroma.tcl ] }
pack .editright.1.aroma2.button1 -side left
::conmen .editright.1.aroma2.entry1
.editright.1.aroma2.entry1.conmen add separator
.editright.1.aroma2.entry1.conmen add command -label [::msgcat::mc {choose}] -command {  set aromabutton {1} ; source [ file join ${prog_dir} tcl aroma.tcl ] }

label .editright.1.aroma3 -text {}
frame .editright.1.aroma4
  entry  .editright.1.aroma4.entry2  -textvariable aroma2 -width 18 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
pack .editright.1.aroma4.entry2 -side left -fill x -expand true
  button .editright.1.aroma4.button2 -image ${helpbutton} -anchor nw -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -command { set aromabutton {2} ; source [ file join ${prog_dir} tcl aroma.tcl ] }
pack .editright.1.aroma4.button2 -side left
::conmen .editright.1.aroma4.entry2
.editright.1.aroma4.entry2.conmen add separator
.editright.1.aroma4.entry2.conmen add command -label [::msgcat::mc {choose}] -command {  set aromabutton {2} ; source [ file join ${prog_dir} tcl aroma.tcl ] }

set depotlength [ string length [::msgcat::mc {unset}] ]
if { [ string length [::msgcat::mc {no}] ]  > ${depotlength} } { set depotlength [ string length [::msgcat::mc {no}] ] }
if { [ string length [::msgcat::mc {yes}] ] > ${depotlength} } { set depotlength [ string length [::msgcat::mc {yes}] ] }
label .editright.1.depot1 -text "[::msgcat::mc {Sediment}] " -font ${titlefont} -anchor w
  menubutton .editright.1.depot2 -text [::msgcat::mc {unset}] -menu .editright.1.depot2.menu -background ${lightcolor} -relief sunken -borderwidth 2 -padx 1 -pady 1 -width ${depotlength} -anchor w
  set depotmenu [ menu .editright.1.depot2.menu -tearoff 0 ]
  ${depotmenu} add command -label [::msgcat::mc {unset}] -command {
    set ground {}
    .editright.1.depot2 configure -text [::msgcat::mc {unset}]
  }
  ${depotmenu} add command -label [::msgcat::mc {yes}] -command {
    set ground {true}
    .editright.1.depot2 configure -text [::msgcat::mc {yes}]
  }
  ${depotmenu} add command -label [::msgcat::mc {no}] -command {
    set ground {false}
    .editright.1.depot2 configure -text [::msgcat::mc {no}]
  }
  if { ${ground} == {true} } {
    .editright.1.depot2 configure -text [::msgcat::mc {yes}]
  } elseif { ${ground} == {false} } {
    .editright.1.depot2 configure -text [::msgcat::mc {no}]
  }
  bind .editright.1.depot2 <Button-3> { tk_popup ${depotmenu} %X %Y }
#
########################################################################
# end
########################################################################


set xbuttonmoveposition {0}
set xbuttonoldposition {0}
set xbuttonchange {false}
proc xbuttonmove {w direction delta} {
  global xbuttonmoveposition xbuttonchange xbuttonoldposition
  set widgetwidth [ ${w} cget -width ]
  if { ${direction} == {down} } {
    if { [ expr "${widgetwidth} + ${delta}" ] > {0} } {
      if { ${xbuttonmoveposition} != {-1} } {
        set xbuttonmoveposition {-1}
        set xbuttonchange {true}
      } else {
        set xbuttonchange {false}
      }
    } elseif { [ expr "${widgetwidth} + ${widgetwidth} + ${delta}" ] > {0} } {
      if { ${xbuttonmoveposition} != {-2} } {
        set xbuttonmoveposition {-2}
        set xbuttonchange {true}
      } else {
        set xbuttonchange {false}
      }
    } elseif { [ expr "${widgetwidth} + ${widgetwidth} + ${widgetwidth} + ${delta}" ] > {0} } {
      if { ${xbuttonmoveposition} != {-3} } {
        set xbuttonmoveposition {-3}
        set xbuttonchange {true}
      } else {
        set xbuttonchange {false}
      }
    } elseif { [ expr "${widgetwidth} + ${widgetwidth} + ${widgetwidth} + ${widgetwidth} + ${delta}" ] > {0} } {
      if { ${xbuttonmoveposition} != {-4} } {
        set xbuttonmoveposition {-4}
        set xbuttonchange {true}
      } else {
        set xbuttonchange {false}
      }
    }
  } elseif { ${direction} == {up} } {
    if { [ expr "${widgetwidth} + ${widgetwidth} + ${widgetwidth} + ${widgetwidth} - ${delta}" ] < {0} } {
      if { ${xbuttonmoveposition} != {+4} } {
        set xbuttonmoveposition {+4}
        set xbuttonchange {true}
      } else {
        set xbuttonchange {false}
      }
    } elseif { [ expr "${widgetwidth} + ${widgetwidth} + ${widgetwidth} - ${delta}" ] < {0} } {
      if { ${xbuttonmoveposition} != {+3} } {
        set xbuttonmoveposition {+3}
        set xbuttonchange {true}
      } else {
        set xbuttonchange {false}
      }
    } elseif { [ expr "${widgetwidth} + ${widgetwidth} - ${delta}" ] < {0} } {
      if { ${xbuttonmoveposition} != {+2} } {
        set xbuttonmoveposition {+2}
        set xbuttonchange {true}
      } else {
        set xbuttonchange {false}
      }
    } elseif { [ expr "${widgetwidth} - ${delta}" ] < {0} } {
      if { ${xbuttonmoveposition} != {+1} } {
        set xbuttonmoveposition {+1}
        set xbuttonchange {true}
      } else {
        set xbuttonchange {false}
      }
    }
  } else {
    if { ${xbuttonmoveposition} != {0} } {
      set xbuttonmoveposition {0}
      set xbuttonchange {true}
    } else {
      set xbuttonchange {false}
    }
  }
  if { ${xbuttonchange} == {true} } {
    if { [ string index ${w} end ] == {1} } {
      if { ${xbuttonmoveposition} == {-4} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {-3} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {-2} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {-1} } {
        set xbuttonchange {false}
      }
    } elseif { [ string index ${w} end ] == {2} } {
      if { ${xbuttonmoveposition} == {-4} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {-3} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {-2} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {+4} } {
        set xbuttonchange {false}
      }
    } elseif { [ string index ${w} end ] == {3} } {
      if { ${xbuttonmoveposition} == {-4} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {-3} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {+3} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {+4} } {
        set xbuttonchange {false}
      }
    } elseif { [ string index ${w} end ] == {4} } {
      if { ${xbuttonmoveposition} == {-4} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {+2} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {+3} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {+4} } {
        set xbuttonchange {false}
      }
    } elseif { [ string index ${w} end ] == {5} } {
      if { ${xbuttonmoveposition} == {+1} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {+2} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {+3} } {
        set xbuttonchange {false}
      } elseif { ${xbuttonmoveposition} == {+4} } {
        set xbuttonchange {false}
      }
    }
  }
  if { ${xbuttonchange} == {true} && ${xbuttonmoveposition} != ${xbuttonoldposition} } {
    set xbuttonoldposition ${xbuttonmoveposition}
    if { ${xbuttonmoveposition} == {-4} } {
      set nowchangewidgetnumber [ expr "[ string index ${w} end ] - 4" ]
    } elseif { ${xbuttonmoveposition} == {-3} } {
      set nowchangewidgetnumber [ expr "[ string index ${w} end ] - 3" ]
    } elseif { ${xbuttonmoveposition} == {-2} } {
      set nowchangewidgetnumber [ expr "[ string index ${w} end ] - 2" ]
    } elseif { ${xbuttonmoveposition} == {-1} } {
      set nowchangewidgetnumber [ expr "[ string index ${w} end ] - 1" ]
    } elseif { ${xbuttonmoveposition} == {+1} } {
      set nowchangewidgetnumber [ expr "[ string index ${w} end ] + 1" ]
    } elseif { ${xbuttonmoveposition} == {+2} } {
      set nowchangewidgetnumber [ expr "[ string index ${w} end ] + 2" ]
    } elseif { ${xbuttonmoveposition} == {+3} } {
      set nowchangewidgetnumber [ expr "[ string index ${w} end ] + 3" ]
    } elseif { ${xbuttonmoveposition} == {+4} } {
      set nowchangewidgetnumber [ expr "[ string index ${w} end ] + 4" ]
    } else {
      set nowchangewidgetnumber [ string index ${w} end ]
    }
    xbutton "[ string range ${w} 0 [ expr "[ string length ${w} ] - 2" ] ]${nowchangewidgetnumber}" invoke
  }
}

proc xbutton {w args} {
  global l5 l51 l52 l53 l54 l55 b51 b52 b53 b54 b55 lightcolor background look nose typical weight acid sweet bitterness complex finish balance believable value evolution evol_update today_month today_year impression headache alcintegration
  if { ${args} != {invoke} } {
    array set optionarray ${args}
    label ${w} -image ${optionarray(-image)} -anchor ${optionarray(-anchor)} -width ${optionarray(-width)} -height ${optionarray(-height)} -relief ${optionarray(-relief)} -borderwidth ${optionarray(-borderwidth)} -highlightthickness ${optionarray(-highlightthickness)}
    bind ${w} <Button-1> "eval [ list $optionarray(-command) ]"
    bind ${w} <Enter> "+ ${w} configure -background ${lightcolor}"
    bind ${w} <Leave> "+ ${w} configure -background ${background}"
    bind ${w} <B1-Motion> "
      if {%x < 0} {
        xbuttonmove ${w} down %x
      } elseif {%x > [ ${w} cget -width ]} {
        xbuttonmove ${w} up %x
      } else {
        xbuttonmove ${w} none %x
      }
    "
  } else {
    eval [ bind ${w} <Button-1> ]
  }
}

set ratewidth_a [ string length [::msgcat::mc {dusty}] ]
if { [ string length [::msgcat::mc {spoiled}]     ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {spoiled}] ] }
if { [ string length [::msgcat::mc {without}]     ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {without}] ] }
if { [ string length [::msgcat::mc {sweet}]       ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {sweet}] ] }
if { [ string length [::msgcat::mc {soft}]        ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {soft}] ] }
if { [ string length [::msgcat::mc {lightly}]     ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {lightly}] ] }
if { [ string length [::msgcat::mc {easy}]        ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {easy}] ] }
if { [ string length [::msgcat::mc {untypical}]   ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {untypical}] ] }
if { [ string length [::msgcat::mc {untraceable}] ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {untraceable}] ] }
if { [ string length [::msgcat::mc {bumpy}]       ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {bumpy}] ] }
if { [ string length [::msgcat::mc {industrial}]  ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {industrial}] ] }
if { [ string length [::msgcat::mc {failed}]      ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {failed}] ] }
if { [ string length [::msgcat::mc {high risk}]   ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {high risk}] ] }
if { [ string length [::msgcat::mc {overpriced}]  ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {overpriced}] ] }
if { [ string length [::msgcat::mc {unseasoned}]  ] > ${ratewidth_a} } { set ratewidth_a [ string length [::msgcat::mc {unseasoned}] ] }
set ratewidth_b [ string length [::msgcat::mc {fascinating}] ]
if { [ string length [::msgcat::mc {infatuating}] ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {infatuating}] ] }
if { [ string length [::msgcat::mc {pronounced}]  ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {pronounced}] ] }
if { [ string length [::msgcat::mc {dry}]         ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {dry}] ] }
if { [ string length [::msgcat::mc {firm}]        ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {firm}] ] }
if { [ string length [::msgcat::mc {vehemently}]  ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {vehemently}] ] }
if { [ string length [::msgcat::mc {difficult}]   ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {difficult}] ] }
if { [ string length [::msgcat::mc {typical}]     ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {typical}] ] }
if { [ string length [::msgcat::mc {endless}]     ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {endless}] ] }
if { [ string length [::msgcat::mc {elegant}]     ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {elegant}] ] }
if { [ string length [::msgcat::mc {traditional}] ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {traditional}] ] }
if { [ string length [::msgcat::mc {magnificent}] ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {magnificent}] ] }
if { [ string length [::msgcat::mc {low risk}]    ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {low risk}] ] }
if { [ string length [::msgcat::mc {cheap}]       ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {cheap}] ] }
if { [ string length [::msgcat::mc {matured}]     ] > ${ratewidth_b} } { set ratewidth_b [ string length [::msgcat::mc {matured}] ] }

label .editright.1.look1 -text "[::msgcat::mc {Look}] " -font ${titlefont}
frame .editright.1.look2
label .editright.1.look2.text1 -text [::msgcat::mc {dusty}] -width ${ratewidth_a} -anchor e
  frame .editright.1.look2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.look2.buttonbar.1 -image ${l51} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.look2.buttonbar.1 cget -image ] == ${b51} } {
        .editright.1.look2.buttonbar.1 configure -image ${l51}
        set look {}
      } else {
        .editright.1.look2.buttonbar.1 configure -image ${b51}
        .editright.1.look2.buttonbar.2 configure -image ${l52}
        .editright.1.look2.buttonbar.3 configure -image ${l53}
        .editright.1.look2.buttonbar.4 configure -image ${l54}
        .editright.1.look2.buttonbar.5 configure -image ${l55}
        set look {1}
      }
      points
    }
    xbutton .editright.1.look2.buttonbar.2 -image ${l52} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.look2.buttonbar.2 cget -image ] == ${b52} } {
        .editright.1.look2.buttonbar.2 configure -image ${l52}
        set look {}
      } else {
        .editright.1.look2.buttonbar.1 configure -image ${l51}
        .editright.1.look2.buttonbar.2 configure -image ${b52}
        .editright.1.look2.buttonbar.3 configure -image ${l53}
        .editright.1.look2.buttonbar.4 configure -image ${l54}
        .editright.1.look2.buttonbar.5 configure -image ${l55}
        set look {2}
      }
      points
    }
    xbutton .editright.1.look2.buttonbar.3 -image ${l53} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.look2.buttonbar.3 cget -image ] == ${b53} } {
        .editright.1.look2.buttonbar.3 configure -image ${l53}
        set look {}
      } else {
        .editright.1.look2.buttonbar.1 configure -image ${l51}
        .editright.1.look2.buttonbar.2 configure -image ${l52}
        .editright.1.look2.buttonbar.3 configure -image ${b53}
        .editright.1.look2.buttonbar.4 configure -image ${l54}
        .editright.1.look2.buttonbar.5 configure -image ${l55}
        set look {3}
      }
      points
    }
    xbutton .editright.1.look2.buttonbar.4 -image ${l54} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.look2.buttonbar.4 cget -image ] == ${b54} } {
        .editright.1.look2.buttonbar.4 configure -image ${l54}
        set look {}
      } else {
        .editright.1.look2.buttonbar.1 configure -image ${l51}
        .editright.1.look2.buttonbar.2 configure -image ${l52}
        .editright.1.look2.buttonbar.3 configure -image ${l53}
        .editright.1.look2.buttonbar.4 configure -image ${b54}
        .editright.1.look2.buttonbar.5 configure -image ${l55}
        set look {4}
      }
      points
    }
    xbutton .editright.1.look2.buttonbar.5 -image ${l55} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.look2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.look2.buttonbar.5 configure -image ${l55}
        set look {}
      } else {
        .editright.1.look2.buttonbar.1 configure -image ${l51}
        .editright.1.look2.buttonbar.2 configure -image ${l52}
        .editright.1.look2.buttonbar.3 configure -image ${l53}
        .editright.1.look2.buttonbar.4 configure -image ${l54}
        .editright.1.look2.buttonbar.5 configure -image ${b55}
        set look {5}
      }
      points
    }
    pack .editright.1.look2.buttonbar.1 .editright.1.look2.buttonbar.2 .editright.1.look2.buttonbar.3 .editright.1.look2.buttonbar.4 .editright.1.look2.buttonbar.5 -side left
  label .editright.1.look2.text2 -text [::msgcat::mc {fascinating}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.look2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.look2.help.menu
  set lookmenu [ menu .editright.1.look2.help.menu -tearoff 0 ]
  ${lookmenu} add command -label [::msgcat::mc {dusty}]       -command { if { [ .editright.1.look2.buttonbar.1 cget -image ] != ${b51} } { xbutton .editright.1.look2.buttonbar.1 invoke } }
  ${lookmenu} add command -label [::msgcat::mc {ordinary}]    -command { if { [ .editright.1.look2.buttonbar.2 cget -image ] != ${b52} } { xbutton .editright.1.look2.buttonbar.2 invoke } }
  ${lookmenu} add command -label [::msgcat::mc {significant}] -command { if { [ .editright.1.look2.buttonbar.3 cget -image ] != ${b53} } { xbutton .editright.1.look2.buttonbar.3 invoke } }
  ${lookmenu} add command -label [::msgcat::mc {high grade}]  -command { if { [ .editright.1.look2.buttonbar.4 cget -image ] != ${b54} } { xbutton .editright.1.look2.buttonbar.4 invoke } }
  ${lookmenu} add command -label [::msgcat::mc {fascinating}] -command { if { [ .editright.1.look2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.look2.buttonbar.5 invoke } }
  pack .editright.1.look2.text1 .editright.1.look2.buttonbar .editright.1.look2.text2 .editright.1.look2.help -side left
grid .editright.1.look1 .editright.1.look2 -sticky w
if { ${look} != {} } { xbutton .editright.1.look2.buttonbar.${look} invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.look2.buttonbar.1 -text [::msgcat::mc {dusty}]       -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.look2.buttonbar.2 -text [::msgcat::mc {ordinary}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.look2.buttonbar.3 -text [::msgcat::mc {significant}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.look2.buttonbar.4 -text [::msgcat::mc {high grade}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.look2.buttonbar.5 -text [::msgcat::mc {fascinating}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.look2.buttonbar.1 <Button-3> {+ tk_popup ${lookmenu} %X %Y }
bind .editright.1.look2.buttonbar.2 <Button-3> {+ tk_popup ${lookmenu} %X %Y }
bind .editright.1.look2.buttonbar.3 <Button-3> {+ tk_popup ${lookmenu} %X %Y }
bind .editright.1.look2.buttonbar.4 <Button-3> {+ tk_popup ${lookmenu} %X %Y }
bind .editright.1.look2.buttonbar.5 <Button-3> {+ tk_popup ${lookmenu} %X %Y }

label .editright.1.nose1 -text "[::msgcat::mc {Nose}] " -font ${titlefont}
frame .editright.1.nose2
label .editright.1.nose2.text1 -text [::msgcat::mc {spoiled}] -width ${ratewidth_a} -anchor e
  frame .editright.1.nose2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.nose2.buttonbar.1 -image ${l51} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.nose2.buttonbar.1 cget -image ] == ${b51} } {
        .editright.1.nose2.buttonbar.1 configure -image ${l51}
        set nose {}
      } else {
        .editright.1.nose2.buttonbar.1 configure -image ${b51}
        .editright.1.nose2.buttonbar.2 configure -image ${l52}
        .editright.1.nose2.buttonbar.3 configure -image ${l53}
        .editright.1.nose2.buttonbar.4 configure -image ${l54}
        .editright.1.nose2.buttonbar.5 configure -image ${l55}
        set nose {1}
      }
      points
    }
    xbutton .editright.1.nose2.buttonbar.2 -image ${l52} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.nose2.buttonbar.2 cget -image ] == ${b52} } {
        .editright.1.nose2.buttonbar.2 configure -image ${l52}
        set nose {}
      } else {
        .editright.1.nose2.buttonbar.1 configure -image ${l51}
        .editright.1.nose2.buttonbar.2 configure -image ${b52}
        .editright.1.nose2.buttonbar.3 configure -image ${l53}
        .editright.1.nose2.buttonbar.4 configure -image ${l54}
        .editright.1.nose2.buttonbar.5 configure -image ${l55}
        set nose {2}
      }
      points
    }
    xbutton .editright.1.nose2.buttonbar.3 -image ${l53} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.nose2.buttonbar.3 cget -image ] == ${b53} } {
        .editright.1.nose2.buttonbar.3 configure -image ${l53}
        set nose {}
      } else {
        .editright.1.nose2.buttonbar.1 configure -image ${l51}
        .editright.1.nose2.buttonbar.2 configure -image ${l52}
        .editright.1.nose2.buttonbar.3 configure -image ${b53}
        .editright.1.nose2.buttonbar.4 configure -image ${l54}
        .editright.1.nose2.buttonbar.5 configure -image ${l55}
        set nose {3}
      }
      points
    }
    xbutton .editright.1.nose2.buttonbar.4 -image ${l54} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.nose2.buttonbar.4 cget -image ] == ${b54} } {
        .editright.1.nose2.buttonbar.4 configure -image ${l54}
        set nose {}
      } else {
        .editright.1.nose2.buttonbar.1 configure -image ${l51}
        .editright.1.nose2.buttonbar.2 configure -image ${l52}
        .editright.1.nose2.buttonbar.3 configure -image ${l53}
        .editright.1.nose2.buttonbar.4 configure -image ${b54}
        .editright.1.nose2.buttonbar.5 configure -image ${l55}
        set nose {4}
      }
      points
    }
    xbutton .editright.1.nose2.buttonbar.5 -image ${l55} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.nose2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.nose2.buttonbar.5 configure -image ${l55}
        set nose {}
      } else {
        .editright.1.nose2.buttonbar.1 configure -image ${l51}
        .editright.1.nose2.buttonbar.2 configure -image ${l52}
        .editright.1.nose2.buttonbar.3 configure -image ${l53}
        .editright.1.nose2.buttonbar.4 configure -image ${l54}
        .editright.1.nose2.buttonbar.5 configure -image ${b55}
        set nose {5}
      }
      points
    }
    pack .editright.1.nose2.buttonbar.1 .editright.1.nose2.buttonbar.2 .editright.1.nose2.buttonbar.3 .editright.1.nose2.buttonbar.4 .editright.1.nose2.buttonbar.5 -side left
  label .editright.1.nose2.text2 -text [::msgcat::mc {infatuating}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.nose2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.nose2.help.menu
  set nosemenu [ menu .editright.1.nose2.help.menu -tearoff 0 ]
  ${nosemenu} add command -label [::msgcat::mc {spoiled}]     -command { if { [ .editright.1.nose2.buttonbar.1 cget -image ] != ${b51} } { xbutton .editright.1.nose2.buttonbar.1 invoke } }
  ${nosemenu} add command -label [::msgcat::mc {neutral}]     -command { if { [ .editright.1.nose2.buttonbar.2 cget -image ] != ${b52} } { xbutton .editright.1.nose2.buttonbar.2 invoke } }
  ${nosemenu} add command -label [::msgcat::mc {ordinary}]    -command { if { [ .editright.1.nose2.buttonbar.3 cget -image ] != ${b53} } { xbutton .editright.1.nose2.buttonbar.3 invoke } }
  ${nosemenu} add command -label [::msgcat::mc {fragrantly}]  -command { if { [ .editright.1.nose2.buttonbar.4 cget -image ] != ${b54} } { xbutton .editright.1.nose2.buttonbar.4 invoke } }
  ${nosemenu} add command -label [::msgcat::mc {infatuating}] -command { if { [ .editright.1.nose2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.nose2.buttonbar.5 invoke } }
  pack .editright.1.nose2.text1 .editright.1.nose2.buttonbar .editright.1.nose2.text2 .editright.1.nose2.help -side left
grid .editright.1.nose1 .editright.1.nose2 -sticky w
if { ${nose} != {} } { xbutton .editright.1.nose2.buttonbar.${nose} invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.nose2.buttonbar.1 -text [::msgcat::mc {spoiled}]     -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.nose2.buttonbar.2 -text [::msgcat::mc {neutral}]     -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.nose2.buttonbar.3 -text [::msgcat::mc {ordinary}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.nose2.buttonbar.4 -text [::msgcat::mc {fragrantly}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.nose2.buttonbar.5 -text [::msgcat::mc {infatuating}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.nose2.buttonbar.1 <Button-3> {+ tk_popup ${nosemenu} %X %Y }
bind .editright.1.nose2.buttonbar.2 <Button-3> {+ tk_popup ${nosemenu} %X %Y }
bind .editright.1.nose2.buttonbar.3 <Button-3> {+ tk_popup ${nosemenu} %X %Y }
bind .editright.1.nose2.buttonbar.4 <Button-3> {+ tk_popup ${nosemenu} %X %Y }
bind .editright.1.nose2.buttonbar.5 <Button-3> {+ tk_popup ${nosemenu} %X %Y }

label .editright.1.acid1 -text "[::msgcat::mc {Acidity}] " -font ${titlefont}
frame .editright.1.acid2
  label .editright.1.acid2.text1 -text [::msgcat::mc {without}] -width ${ratewidth_a} -anchor e
  frame .editright.1.acid2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.acid2.buttonbar.1 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.acid2.buttonbar.1 cget -image ] == ${b55} } {
        .editright.1.acid2.buttonbar.1 configure -image ${l5}
        set acid {}
      } else {
        .editright.1.acid2.buttonbar.1 configure -image ${b55}
        .editright.1.acid2.buttonbar.2 configure -image ${l5}
        .editright.1.acid2.buttonbar.3 configure -image ${l5}
        .editright.1.acid2.buttonbar.4 configure -image ${l5}
        .editright.1.acid2.buttonbar.5 configure -image ${l5}
        set acid {4}
      }
      points
    }
    xbutton .editright.1.acid2.buttonbar.2 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.acid2.buttonbar.2 cget -image ] == ${b55} } {
        .editright.1.acid2.buttonbar.2 configure -image ${l5}
        set acid {}
      } else {
        .editright.1.acid2.buttonbar.1 configure -image ${l5}
        .editright.1.acid2.buttonbar.2 configure -image ${b55}
        .editright.1.acid2.buttonbar.3 configure -image ${l5}
        .editright.1.acid2.buttonbar.4 configure -image ${l5}
        .editright.1.acid2.buttonbar.5 configure -image ${l5}
        set acid {1}
      }
      points
    }
    xbutton .editright.1.acid2.buttonbar.3 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.acid2.buttonbar.3 cget -image ] == ${b55} } {
        .editright.1.acid2.buttonbar.3 configure -image ${l5}
        set acid {}
      } else {
        .editright.1.acid2.buttonbar.1 configure -image ${l5}
        .editright.1.acid2.buttonbar.2 configure -image ${l5}
        .editright.1.acid2.buttonbar.3 configure -image ${b55}
        .editright.1.acid2.buttonbar.4 configure -image ${l5}
        .editright.1.acid2.buttonbar.5 configure -image ${l5}
        set acid {2}
      }
      points
    }
    xbutton .editright.1.acid2.buttonbar.4 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.acid2.buttonbar.4 cget -image ] == ${b55} } {
        .editright.1.acid2.buttonbar.4 configure -image ${l5}
        set acid {}
      } else {
        .editright.1.acid2.buttonbar.1 configure -image ${l5}
        .editright.1.acid2.buttonbar.2 configure -image ${l5}
        .editright.1.acid2.buttonbar.3 configure -image ${l5}
        .editright.1.acid2.buttonbar.4 configure -image ${b55}
        .editright.1.acid2.buttonbar.5 configure -image ${l5}
        set acid {5}
      }
      points
    }
    xbutton .editright.1.acid2.buttonbar.5 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.acid2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.acid2.buttonbar.5 configure -image ${l5}
        set acid {}
      } else {
        .editright.1.acid2.buttonbar.1 configure -image ${l5}
        .editright.1.acid2.buttonbar.2 configure -image ${l5}
        .editright.1.acid2.buttonbar.3 configure -image ${l5}
        .editright.1.acid2.buttonbar.4 configure -image ${l5}
        .editright.1.acid2.buttonbar.5 configure -image ${b55}
        set acid {3}
      }
      points
    }
    pack .editright.1.acid2.buttonbar.1 .editright.1.acid2.buttonbar.2 .editright.1.acid2.buttonbar.3 .editright.1.acid2.buttonbar.4 .editright.1.acid2.buttonbar.5 -side left
  label .editright.1.acid2.text2 -text [::msgcat::mc {pronounced}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.acid2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.acid2.help.menu
  set acidmenu [ menu .editright.1.acid2.help.menu -tearoff 0 ]
  ${acidmenu} add command -label [::msgcat::mc {without}]    -command { if { [ .editright.1.acid2.buttonbar.1 cget -image ] != ${b55} } { xbutton .editright.1.acid2.buttonbar.1 invoke } }
  ${acidmenu} add command -label [::msgcat::mc {flat}]       -command { if { [ .editright.1.acid2.buttonbar.2 cget -image ] != ${b55} } { xbutton .editright.1.acid2.buttonbar.2 invoke } }
  ${acidmenu} add command -label [::msgcat::mc {freshly}]    -command { if { [ .editright.1.acid2.buttonbar.3 cget -image ] != ${b55} } { xbutton .editright.1.acid2.buttonbar.3 invoke } }
  ${acidmenu} add command -label [::msgcat::mc {striking}]   -command { if { [ .editright.1.acid2.buttonbar.4 cget -image ] != ${b55} } { xbutton .editright.1.acid2.buttonbar.4 invoke } }
  ${acidmenu} add command -label [::msgcat::mc {pronounced}] -command { if { [ .editright.1.acid2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.acid2.buttonbar.5 invoke } }
  pack .editright.1.acid2.text1 .editright.1.acid2.buttonbar .editright.1.acid2.text2 .editright.1.acid2.help -side left
grid .editright.1.acid1 .editright.1.acid2 -sticky w
if { ${acid} == {1} } { xbutton .editright.1.acid2.buttonbar.2 invoke }
if { ${acid} == {2} } { xbutton .editright.1.acid2.buttonbar.3 invoke }
if { ${acid} == {3} } { xbutton .editright.1.acid2.buttonbar.5 invoke }
if { ${acid} == {4} } { xbutton .editright.1.acid2.buttonbar.1 invoke }
if { ${acid} == {5} } { xbutton .editright.1.acid2.buttonbar.4 invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.acid2.buttonbar.1 -text [::msgcat::mc {without}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.acid2.buttonbar.2 -text [::msgcat::mc {flat}]       -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.acid2.buttonbar.3 -text [::msgcat::mc {freshly}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.acid2.buttonbar.4 -text [::msgcat::mc {striking}]   -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.acid2.buttonbar.5 -text [::msgcat::mc {pronounced}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.acid2.buttonbar.1 <Button-3> {+ tk_popup ${acidmenu} %X %Y }
bind .editright.1.acid2.buttonbar.2 <Button-3> {+ tk_popup ${acidmenu} %X %Y }
bind .editright.1.acid2.buttonbar.3 <Button-3> {+ tk_popup ${acidmenu} %X %Y }
bind .editright.1.acid2.buttonbar.4 <Button-3> {+ tk_popup ${acidmenu} %X %Y }
bind .editright.1.acid2.buttonbar.5 <Button-3> {+ tk_popup ${acidmenu} %X %Y }

label .editright.1.sweet1 -text "[::msgcat::mc {Sweetness}] " -font ${titlefont}
frame .editright.1.sweet2
  label .editright.1.sweet2.text1 -text [::msgcat::mc {sweet}] -width ${ratewidth_a} -anchor e
  frame .editright.1.sweet2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.sweet2.buttonbar.1 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.sweet2.buttonbar.1 cget -image ] == ${b55} } {
        .editright.1.sweet2.buttonbar.1 configure -image ${l5}
        set sweet {}
      } else {
        .editright.1.sweet2.buttonbar.1 configure -image ${b55}
        .editright.1.sweet2.buttonbar.2 configure -image ${l5}
        .editright.1.sweet2.buttonbar.3 configure -image ${l5}
        .editright.1.sweet2.buttonbar.4 configure -image ${l5}
        .editright.1.sweet2.buttonbar.5 configure -image ${l5}
        set sweet {1}
      }
      points
    }
    xbutton .editright.1.sweet2.buttonbar.2 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.sweet2.buttonbar.2 cget -image ] == ${b55} } {
        .editright.1.sweet2.buttonbar.2 configure -image ${l5}
        set sweet {}
      } else {
        .editright.1.sweet2.buttonbar.1 configure -image ${l5}
        .editright.1.sweet2.buttonbar.2 configure -image ${b55}
        .editright.1.sweet2.buttonbar.3 configure -image ${l5}
        .editright.1.sweet2.buttonbar.4 configure -image ${l5}
        .editright.1.sweet2.buttonbar.5 configure -image ${l5}
        set sweet {4}
      }
      points
    }
    xbutton .editright.1.sweet2.buttonbar.3 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.sweet2.buttonbar.3 cget -image ] == ${b55} } {
        .editright.1.sweet2.buttonbar.3 configure -image ${l5}
        set sweet {}
      } else {
        .editright.1.sweet2.buttonbar.1 configure -image ${l5}
        .editright.1.sweet2.buttonbar.2 configure -image ${l5}
        .editright.1.sweet2.buttonbar.3 configure -image ${b55}
        .editright.1.sweet2.buttonbar.4 configure -image ${l5}
        .editright.1.sweet2.buttonbar.5 configure -image ${l5}
        set sweet {2}
      }
      points
    }
    xbutton .editright.1.sweet2.buttonbar.4 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.sweet2.buttonbar.4 cget -image ] == ${b55} } {
        .editright.1.sweet2.buttonbar.4 configure -image ${l5}
        set sweet {}
      } else {
        .editright.1.sweet2.buttonbar.1 configure -image ${l5}
        .editright.1.sweet2.buttonbar.2 configure -image ${l5}
        .editright.1.sweet2.buttonbar.3 configure -image ${l5}
        .editright.1.sweet2.buttonbar.4 configure -image ${b55}
        .editright.1.sweet2.buttonbar.5 configure -image ${l5}
        set sweet {5}
      }
      points
    }
    xbutton .editright.1.sweet2.buttonbar.5 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.sweet2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.sweet2.buttonbar.5 configure -image ${l5}
        set sweet {}
      } else {
        .editright.1.sweet2.buttonbar.1 configure -image ${l5}
        .editright.1.sweet2.buttonbar.2 configure -image ${l5}
        .editright.1.sweet2.buttonbar.3 configure -image ${l5}
        .editright.1.sweet2.buttonbar.4 configure -image ${l5}
        .editright.1.sweet2.buttonbar.5 configure -image ${b55}
        set sweet {3}
      }
      points
    }
    pack .editright.1.sweet2.buttonbar.1 .editright.1.sweet2.buttonbar.2 .editright.1.sweet2.buttonbar.3 .editright.1.sweet2.buttonbar.4 .editright.1.sweet2.buttonbar.5 -side left
  label .editright.1.sweet2.text2 -text [::msgcat::mc {dry}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.sweet2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.sweet2.help.menu
  set sweetmenu [ menu .editright.1.sweet2.help.menu -tearoff 0 ]
  ${sweetmenu} add command -label [::msgcat::mc {sweet}]      -command { if { [ .editright.1.sweet2.buttonbar.1 cget -image ] != ${b55} } { xbutton .editright.1.sweet2.buttonbar.1 invoke } }
  ${sweetmenu} add command -label [::msgcat::mc {semi sweet}] -command { if { [ .editright.1.sweet2.buttonbar.2 cget -image ] != ${b55} } { xbutton .editright.1.sweet2.buttonbar.2 invoke } }
  ${sweetmenu} add command -label [::msgcat::mc {medium}]     -command { if { [ .editright.1.sweet2.buttonbar.3 cget -image ] != ${b55} } { xbutton .editright.1.sweet2.buttonbar.3 invoke } }
  ${sweetmenu} add command -label [::msgcat::mc {semi dry}]   -command { if { [ .editright.1.sweet2.buttonbar.4 cget -image ] != ${b55} } { xbutton .editright.1.sweet2.buttonbar.4 invoke } }
  ${sweetmenu} add command -label [::msgcat::mc {dry}]        -command { if { [ .editright.1.sweet2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.sweet2.buttonbar.5 invoke } }
  pack .editright.1.sweet2.text1 .editright.1.sweet2.buttonbar .editright.1.sweet2.text2 .editright.1.sweet2.help -side left
grid .editright.1.sweet1 .editright.1.sweet2 -sticky w
if { ${sweet} == {1} } { xbutton .editright.1.sweet2.buttonbar.1 invoke }
if { ${sweet} == {2} } { xbutton .editright.1.sweet2.buttonbar.3 invoke }
if { ${sweet} == {3} } { xbutton .editright.1.sweet2.buttonbar.5 invoke }
if { ${sweet} == {4} } { xbutton .editright.1.sweet2.buttonbar.2 invoke }
if { ${sweet} == {5} } { xbutton .editright.1.sweet2.buttonbar.4 invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.sweet2.buttonbar.1 -text [::msgcat::mc {sweet}]      -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.sweet2.buttonbar.2 -text [::msgcat::mc {semi sweet}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.sweet2.buttonbar.3 -text [::msgcat::mc {medium}]     -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.sweet2.buttonbar.4 -text [::msgcat::mc {semi dry}]   -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.sweet2.buttonbar.5 -text [::msgcat::mc {dry}]        -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.sweet2.buttonbar.1 <Button-3> {+ tk_popup ${sweetmenu} %X %Y }
bind .editright.1.sweet2.buttonbar.2 <Button-3> {+ tk_popup ${sweetmenu} %X %Y }
bind .editright.1.sweet2.buttonbar.3 <Button-3> {+ tk_popup ${sweetmenu} %X %Y }
bind .editright.1.sweet2.buttonbar.4 <Button-3> {+ tk_popup ${sweetmenu} %X %Y }
bind .editright.1.sweet2.buttonbar.5 <Button-3> {+ tk_popup ${sweetmenu} %X %Y }

label .editright.1.bitterness1 -text "[::msgcat::mc {Tannin}] " -font ${titlefont}
frame .editright.1.bitterness2
  label .editright.1.bitterness2.text1 -text [::msgcat::mc {soft}] -width ${ratewidth_a} -anchor e
  frame .editright.1.bitterness2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.bitterness2.buttonbar.1 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.bitterness2.help cget -state ] != {disabled} } {
        if { [ .editright.1.bitterness2.buttonbar.1 cget -image ] == ${b55} } {
          .editright.1.bitterness2.buttonbar.1 configure -image ${l5}
          set bitterness {}
        } else {
          .editright.1.bitterness2.buttonbar.1 configure -image ${b55}
          .editright.1.bitterness2.buttonbar.2 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.3 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.4 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.5 configure -image ${l5}
          set bitterness {1}
        }
        points
      }
    }
    xbutton .editright.1.bitterness2.buttonbar.2 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.bitterness2.help cget -state ] != {disabled} } {
        if { [ .editright.1.bitterness2.buttonbar.2 cget -image ] == ${b55} } {
          .editright.1.bitterness2.buttonbar.2 configure -image ${l5}
          set bitterness {}
        } else {
          .editright.1.bitterness2.buttonbar.1 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.2 configure -image ${b55}
          .editright.1.bitterness2.buttonbar.3 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.4 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.5 configure -image ${l5}
          set bitterness {4}
        }
        points
      }
    }
    xbutton .editright.1.bitterness2.buttonbar.3 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.bitterness2.help cget -state ] != {disabled} } {
        if { [ .editright.1.bitterness2.buttonbar.3 cget -image ] == ${b55} } {
          .editright.1.bitterness2.buttonbar.3 configure -image ${l5}
          set bitterness {}
        } else {
          .editright.1.bitterness2.buttonbar.1 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.2 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.3 configure -image ${b55}
          .editright.1.bitterness2.buttonbar.4 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.5 configure -image ${l5}
          set bitterness {2}
        }
        points
      }
    }
    xbutton .editright.1.bitterness2.buttonbar.4 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.bitterness2.help cget -state ] != {disabled} } {
        if { [ .editright.1.bitterness2.buttonbar.4 cget -image ] == ${b55} } {
          .editright.1.bitterness2.buttonbar.4 configure -image ${l5}
          set bitterness {}
        } else {
          .editright.1.bitterness2.buttonbar.1 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.2 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.3 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.4 configure -image ${b55}
          .editright.1.bitterness2.buttonbar.5 configure -image ${l5}
          set bitterness {5}
        }
        points
      }
    }
    xbutton .editright.1.bitterness2.buttonbar.5 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.bitterness2.help cget -state ] != {disabled} } {
        if { [ .editright.1.bitterness2.buttonbar.5 cget -image ] == ${b55} } {
          .editright.1.bitterness2.buttonbar.5 configure -image ${l5}
          set bitterness {}
        } else {
          .editright.1.bitterness2.buttonbar.1 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.2 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.3 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.4 configure -image ${l5}
          .editright.1.bitterness2.buttonbar.5 configure -image ${b55}
          set bitterness {3}
        }
        points
      }
    }
    pack .editright.1.bitterness2.buttonbar.1 .editright.1.bitterness2.buttonbar.2 .editright.1.bitterness2.buttonbar.3 .editright.1.bitterness2.buttonbar.4 .editright.1.bitterness2.buttonbar.5 -side left
  label .editright.1.bitterness2.text2 -text [::msgcat::mc {firm}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.bitterness2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.bitterness2.help.menu
  set bitternessmenu [ menu .editright.1.bitterness2.help.menu -tearoff 0 ]
  ${bitternessmenu} add command -label [::msgcat::mc {soft}]       -command { if { [ .editright.1.bitterness2.buttonbar.1 cget -image ] != ${b55} } { xbutton .editright.1.bitterness2.buttonbar.1 invoke } }
  ${bitternessmenu} add command -label [::msgcat::mc {noticeably}] -command { if { [ .editright.1.bitterness2.buttonbar.2 cget -image ] != ${b55} } { xbutton .editright.1.bitterness2.buttonbar.2 invoke } }
  ${bitternessmenu} add command -label [::msgcat::mc {medium}]     -command { if { [ .editright.1.bitterness2.buttonbar.3 cget -image ] != ${b55} } { xbutton .editright.1.bitterness2.buttonbar.3 invoke } }
  ${bitternessmenu} add command -label [::msgcat::mc {obvious}]    -command { if { [ .editright.1.bitterness2.buttonbar.4 cget -image ] != ${b55} } { xbutton .editright.1.bitterness2.buttonbar.4 invoke } }
  ${bitternessmenu} add command -label [::msgcat::mc {firm}]       -command { if { [ .editright.1.bitterness2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.bitterness2.buttonbar.5 invoke } }
  pack .editright.1.bitterness2.text1 .editright.1.bitterness2.buttonbar .editright.1.bitterness2.text2 .editright.1.bitterness2.help -side left
grid .editright.1.bitterness1 .editright.1.bitterness2 -sticky w
if { ${tooltips} == {true} } {
  ::ttips .editright.1.bitterness2.buttonbar.1 -text [::msgcat::mc {soft}]       -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.bitterness2.buttonbar.2 -text [::msgcat::mc {noticeably}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.bitterness2.buttonbar.3 -text [::msgcat::mc {medium}]     -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.bitterness2.buttonbar.4 -text [::msgcat::mc {obvious}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.bitterness2.buttonbar.5 -text [::msgcat::mc {firm}]       -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.bitterness2.buttonbar.1 <Button-3> {+ tk_popup ${bitternessmenu} %X %Y }
bind .editright.1.bitterness2.buttonbar.2 <Button-3> {+ tk_popup ${bitternessmenu} %X %Y }
bind .editright.1.bitterness2.buttonbar.3 <Button-3> {+ tk_popup ${bitternessmenu} %X %Y }
bind .editright.1.bitterness2.buttonbar.4 <Button-3> {+ tk_popup ${bitternessmenu} %X %Y }
bind .editright.1.bitterness2.buttonbar.5 <Button-3> {+ tk_popup ${bitternessmenu} %X %Y }

label .editright.1.weight1 -text "[::msgcat::mc {Body}] " -font ${titlefont}
frame .editright.1.weight2
label .editright.1.weight2.text1 -text [::msgcat::mc {lightly}] -width ${ratewidth_a} -anchor e
  frame .editright.1.weight2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.weight2.buttonbar.1 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.weight2.buttonbar.1 cget -image ] == ${b55} } {
        .editright.1.weight2.buttonbar.1 configure -image ${l5}
        set weight {}
      } else {
        .editright.1.weight2.buttonbar.1 configure -image ${b55}
        .editright.1.weight2.buttonbar.2 configure -image ${l5}
        .editright.1.weight2.buttonbar.3 configure -image ${l5}
        .editright.1.weight2.buttonbar.4 configure -image ${l5}
        .editright.1.weight2.buttonbar.5 configure -image ${l5}
        set weight {1}
      }
      points
    }
    xbutton .editright.1.weight2.buttonbar.2 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.weight2.buttonbar.2 cget -image ] == ${b55} } {
        .editright.1.weight2.buttonbar.2 configure -image ${l5}
        set weight {}
      } else {
        .editright.1.weight2.buttonbar.1 configure -image ${l5}
        .editright.1.weight2.buttonbar.2 configure -image ${b55}
        .editright.1.weight2.buttonbar.3 configure -image ${l5}
        .editright.1.weight2.buttonbar.4 configure -image ${l5}
        .editright.1.weight2.buttonbar.5 configure -image ${l5}
        set weight {2}
      }
      points
    }
    xbutton .editright.1.weight2.buttonbar.3 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.weight2.buttonbar.3 cget -image ] == ${b55} } {
        .editright.1.weight2.buttonbar.3 configure -image ${l5}
        set weight {}
      } else {
        .editright.1.weight2.buttonbar.1 configure -image ${l5}
        .editright.1.weight2.buttonbar.2 configure -image ${l5}
        .editright.1.weight2.buttonbar.3 configure -image ${b55}
        .editright.1.weight2.buttonbar.4 configure -image ${l5}
        .editright.1.weight2.buttonbar.5 configure -image ${l5}
        set weight {3}
      }
      points
    }
    xbutton .editright.1.weight2.buttonbar.4 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.weight2.buttonbar.4 cget -image ] == ${b55} } {
        .editright.1.weight2.buttonbar.4 configure -image ${l5}
        set weight {}
      } else {
        .editright.1.weight2.buttonbar.1 configure -image ${l5}
        .editright.1.weight2.buttonbar.2 configure -image ${l5}
        .editright.1.weight2.buttonbar.3 configure -image ${l5}
        .editright.1.weight2.buttonbar.4 configure -image ${b55}
        .editright.1.weight2.buttonbar.5 configure -image ${l5}
        set weight {4}
      }
      points
    }
    xbutton .editright.1.weight2.buttonbar.5 -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.weight2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.weight2.buttonbar.5 configure -image ${l5}
        set weight {}
      } else {
        .editright.1.weight2.buttonbar.1 configure -image ${l5}
        .editright.1.weight2.buttonbar.2 configure -image ${l5}
        .editright.1.weight2.buttonbar.3 configure -image ${l5}
        .editright.1.weight2.buttonbar.4 configure -image ${l5}
        .editright.1.weight2.buttonbar.5 configure -image ${b55}
        set weight {5}
      }
      points
    }
    pack .editright.1.weight2.buttonbar.1 .editright.1.weight2.buttonbar.2 .editright.1.weight2.buttonbar.3 .editright.1.weight2.buttonbar.4 .editright.1.weight2.buttonbar.5 -side left
  label .editright.1.weight2.text2 -text [::msgcat::mc {vehemently}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.weight2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.weight2.help.menu
  set weightmenu [ menu .editright.1.weight2.help.menu -tearoff 0 ]
  ${weightmenu} add command -label [::msgcat::mc {lightly}]    -command { if { [ .editright.1.weight2.buttonbar.1 cget -image ] != ${b55} } { xbutton .editright.1.weight2.buttonbar.1 invoke } }
  ${weightmenu} add command -label [::msgcat::mc {medium}]     -command { if { [ .editright.1.weight2.buttonbar.2 cget -image ] != ${b55} } { xbutton .editright.1.weight2.buttonbar.2 invoke } }
  ${weightmenu} add command -label [::msgcat::mc {condensed}]  -command { if { [ .editright.1.weight2.buttonbar.3 cget -image ] != ${b55} } { xbutton .editright.1.weight2.buttonbar.3 invoke } }
  ${weightmenu} add command -label [::msgcat::mc {weighty}]    -command { if { [ .editright.1.weight2.buttonbar.4 cget -image ] != ${b55} } { xbutton .editright.1.weight2.buttonbar.4 invoke } }
  ${weightmenu} add command -label [::msgcat::mc {vehemently}] -command { if { [ .editright.1.weight2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.weight2.buttonbar.5 invoke } }
  pack .editright.1.weight2.text1 .editright.1.weight2.buttonbar .editright.1.weight2.text2 .editright.1.weight2.help -side left
grid .editright.1.weight1 .editright.1.weight2 -sticky w
if { ${weight} != {} } { xbutton .editright.1.weight2.buttonbar.${weight} invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.weight2.buttonbar.1 -text [::msgcat::mc {lightly}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.weight2.buttonbar.2 -text [::msgcat::mc {medium}]     -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.weight2.buttonbar.3 -text [::msgcat::mc {condensed}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.weight2.buttonbar.4 -text [::msgcat::mc {weighty}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.weight2.buttonbar.5 -text [::msgcat::mc {vehemently}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.weight2.buttonbar.1 <Button-3> {+ tk_popup ${weightmenu} %X %Y }
bind .editright.1.weight2.buttonbar.2 <Button-3> {+ tk_popup ${weightmenu} %X %Y }
bind .editright.1.weight2.buttonbar.3 <Button-3> {+ tk_popup ${weightmenu} %X %Y }
bind .editright.1.weight2.buttonbar.4 <Button-3> {+ tk_popup ${weightmenu} %X %Y }
bind .editright.1.weight2.buttonbar.5 <Button-3> {+ tk_popup ${weightmenu} %X %Y }

label .editright.1.complex1 -text "[::msgcat::mc {Demand}] " -font ${titlefont}
frame .editright.1.complex2
label .editright.1.complex2.text1 -text [::msgcat::mc {easy}] -width ${ratewidth_a} -anchor e
  frame .editright.1.complex2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.complex2.buttonbar.1  -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.complex2.buttonbar.1 cget -image ] == ${b55} } {
        .editright.1.complex2.buttonbar.1 configure -image ${l5}
        set complex {}
      } else {
        .editright.1.complex2.buttonbar.1 configure -image ${b55}
        .editright.1.complex2.buttonbar.2 configure -image ${l5}
        .editright.1.complex2.buttonbar.3 configure -image ${l5}
        .editright.1.complex2.buttonbar.4 configure -image ${l5}
        .editright.1.complex2.buttonbar.5 configure -image ${l5}
        set complex {1}
      }
      points
    }
    xbutton .editright.1.complex2.buttonbar.2  -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.complex2.buttonbar.2 cget -image ] == ${b55} } {
        .editright.1.complex2.buttonbar.2 configure -image ${l5}
        set complex {}
      } else {
        .editright.1.complex2.buttonbar.1 configure -image ${l5}
        .editright.1.complex2.buttonbar.2 configure -image ${b55}
        .editright.1.complex2.buttonbar.3 configure -image ${l5}
        .editright.1.complex2.buttonbar.4 configure -image ${l5}
        .editright.1.complex2.buttonbar.5 configure -image ${l5}
        set complex {2}
      }
      points
    }
    xbutton .editright.1.complex2.buttonbar.3  -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.complex2.buttonbar.3 cget -image ] == ${b55} } {
        .editright.1.complex2.buttonbar.3 configure -image ${l5}
        set complex {}
      } else {
        .editright.1.complex2.buttonbar.1 configure -image ${l5}
        .editright.1.complex2.buttonbar.2 configure -image ${l5}
        .editright.1.complex2.buttonbar.3 configure -image ${b55}
        .editright.1.complex2.buttonbar.4 configure -image ${l5}
        .editright.1.complex2.buttonbar.5 configure -image ${l5}
        set complex {3}
      }
      points
    }
    xbutton .editright.1.complex2.buttonbar.4  -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.complex2.buttonbar.4 cget -image ] == ${b55} } {
        .editright.1.complex2.buttonbar.4 configure -image ${l5}
        set complex {}
      } else {
        .editright.1.complex2.buttonbar.1 configure -image ${l5}
        .editright.1.complex2.buttonbar.2 configure -image ${l5}
        .editright.1.complex2.buttonbar.3 configure -image ${l5}
        .editright.1.complex2.buttonbar.4 configure -image ${b55}
        .editright.1.complex2.buttonbar.5 configure -image ${l5}
        set complex {4}
      }
      points
    }
    xbutton .editright.1.complex2.buttonbar.5  -image ${l5} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.complex2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.complex2.buttonbar.5 configure -image ${l5}
        set complex {}
      } else {
        .editright.1.complex2.buttonbar.1 configure -image ${l5}
        .editright.1.complex2.buttonbar.2 configure -image ${l5}
        .editright.1.complex2.buttonbar.3 configure -image ${l5}
        .editright.1.complex2.buttonbar.4 configure -image ${l5}
        .editright.1.complex2.buttonbar.5 configure -image ${b55}
        set complex {5}
      }
      points
    }
    pack .editright.1.complex2.buttonbar.1 .editright.1.complex2.buttonbar.2 .editright.1.complex2.buttonbar.3 .editright.1.complex2.buttonbar.4 .editright.1.complex2.buttonbar.5 -side left
  label .editright.1.complex2.text2 -text [::msgcat::mc {difficult}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.complex2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.complex2.help.menu
  set complexmenu [ menu .editright.1.complex2.help.menu -tearoff 0 ]
  ${complexmenu} add command -label [::msgcat::mc {easy}]      -command { if { [ .editright.1.complex2.buttonbar.1 cget -image ] != ${b55} } { xbutton .editright.1.complex2.buttonbar.1 invoke } }
  ${complexmenu} add command -label [::msgcat::mc {reserved}]  -command { if { [ .editright.1.complex2.buttonbar.2 cget -image ] != ${b55} } { xbutton .editright.1.complex2.buttonbar.2 invoke } }
  ${complexmenu} add command -label [::msgcat::mc {medium}]    -command { if { [ .editright.1.complex2.buttonbar.3 cget -image ] != ${b55} } { xbutton .editright.1.complex2.buttonbar.3 invoke } }
  ${complexmenu} add command -label [::msgcat::mc {claiming}]  -command { if { [ .editright.1.complex2.buttonbar.4 cget -image ] != ${b55} } { xbutton .editright.1.complex2.buttonbar.4 invoke } }
  ${complexmenu} add command -label [::msgcat::mc {difficult}] -command { if { [ .editright.1.complex2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.complex2.buttonbar.5 invoke } }
  pack .editright.1.complex2.text1 .editright.1.complex2.buttonbar .editright.1.complex2.text2 .editright.1.complex2.help -side left
grid .editright.1.complex1 .editright.1.complex2 -sticky w
if { ${complex} != {} } { xbutton .editright.1.complex2.buttonbar.${complex} invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.complex2.buttonbar.1 -text [::msgcat::mc {easy}]      -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.complex2.buttonbar.2 -text [::msgcat::mc {reserved}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.complex2.buttonbar.3 -text [::msgcat::mc {medium}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.complex2.buttonbar.4 -text [::msgcat::mc {claiming}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.complex2.buttonbar.5 -text [::msgcat::mc {difficult}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.complex2.buttonbar.1 <Button-3> {+ tk_popup ${complexmenu} %X %Y }
bind .editright.1.complex2.buttonbar.2 <Button-3> {+ tk_popup ${complexmenu} %X %Y }
bind .editright.1.complex2.buttonbar.3 <Button-3> {+ tk_popup ${complexmenu} %X %Y }
bind .editright.1.complex2.buttonbar.4 <Button-3> {+ tk_popup ${complexmenu} %X %Y }
bind .editright.1.complex2.buttonbar.5 <Button-3> {+ tk_popup ${complexmenu} %X %Y }

label .editright.1.alcintegration1 -text "[::msgcat::mc {Alcohol}] " -font ${titlefont}
frame .editright.1.alcintegration2
label .editright.1.alcintegration2.text1 -text [::msgcat::mc {flashy}] -width ${ratewidth_a} -anchor e
  frame .editright.1.alcintegration2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.alcintegration2.buttonbar.1 -image ${l51} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.alcintegration2.buttonbar.1 cget -image ] == ${b51} } {
        .editright.1.alcintegration2.buttonbar.1 configure -image ${l51}
        set alcintegration {}
      } else {
        .editright.1.alcintegration2.buttonbar.1 configure -image ${b51}
        .editright.1.alcintegration2.buttonbar.2 configure -image ${l52}
        .editright.1.alcintegration2.buttonbar.3 configure -image ${l53}
        .editright.1.alcintegration2.buttonbar.4 configure -image ${l54}
        .editright.1.alcintegration2.buttonbar.5 configure -image ${l55}
        set alcintegration {1}
      }
      points
    }
    xbutton .editright.1.alcintegration2.buttonbar.2 -image ${l52} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.alcintegration2.buttonbar.2 cget -image ] == ${b52} } {
        .editright.1.alcintegration2.buttonbar.2 configure -image ${l52}
        set alcintegration {}
      } else {
        .editright.1.alcintegration2.buttonbar.1 configure -image ${l51}
        .editright.1.alcintegration2.buttonbar.2 configure -image ${b52}
        .editright.1.alcintegration2.buttonbar.3 configure -image ${l53}
        .editright.1.alcintegration2.buttonbar.4 configure -image ${l54}
        .editright.1.alcintegration2.buttonbar.5 configure -image ${l55}
        set alcintegration {2}
      }
      points
    }
    xbutton .editright.1.alcintegration2.buttonbar.3 -image ${l53} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.alcintegration2.buttonbar.3 cget -image ] == ${b53} } {
        .editright.1.alcintegration2.buttonbar.3 configure -image ${l53}
        set alcintegration {}
      } else {
        .editright.1.alcintegration2.buttonbar.1 configure -image ${l51}
        .editright.1.alcintegration2.buttonbar.2 configure -image ${l52}
        .editright.1.alcintegration2.buttonbar.3 configure -image ${b53}
        .editright.1.alcintegration2.buttonbar.4 configure -image ${l54}
        .editright.1.alcintegration2.buttonbar.5 configure -image ${l55}
        set alcintegration {3}
      }
      points
    }
    xbutton .editright.1.alcintegration2.buttonbar.4 -image ${l54} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.alcintegration2.buttonbar.4 cget -image ] == ${b54} } {
        .editright.1.alcintegration2.buttonbar.4 configure -image ${l54}
        set alcintegration {}
      } else {
        .editright.1.alcintegration2.buttonbar.1 configure -image ${l51}
        .editright.1.alcintegration2.buttonbar.2 configure -image ${l52}
        .editright.1.alcintegration2.buttonbar.3 configure -image ${l53}
        .editright.1.alcintegration2.buttonbar.4 configure -image ${b54}
        .editright.1.alcintegration2.buttonbar.5 configure -image ${l55}
        set alcintegration {4}
      }
      points
    }
    xbutton .editright.1.alcintegration2.buttonbar.5 -image ${l55} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.alcintegration2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.alcintegration2.buttonbar.5 configure -image ${l55}
        set alcintegration {}
      } else {
        .editright.1.alcintegration2.buttonbar.1 configure -image ${l51}
        .editright.1.alcintegration2.buttonbar.2 configure -image ${l52}
        .editright.1.alcintegration2.buttonbar.3 configure -image ${l53}
        .editright.1.alcintegration2.buttonbar.4 configure -image ${l54}
        .editright.1.alcintegration2.buttonbar.5 configure -image ${b55}
        set alcintegration {5}
      }
      points
    }
    pack .editright.1.alcintegration2.buttonbar.1 .editright.1.alcintegration2.buttonbar.2 .editright.1.alcintegration2.buttonbar.3 .editright.1.alcintegration2.buttonbar.4 .editright.1.alcintegration2.buttonbar.5 -side left
  label .editright.1.alcintegration2.text2 -text [::msgcat::mc {integrated}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.alcintegration2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.alcintegration2.help.menu
  set alcintegrationmenu [ menu .editright.1.alcintegration2.help.menu -tearoff 0 ]
  ${alcintegrationmenu} add command -label [::msgcat::mc {flashy}]          -command { if { [ .editright.1.alcintegration2.buttonbar.1 cget -image ] != ${b51} } { xbutton .editright.1.alcintegration2.buttonbar.1 invoke } }
  ${alcintegrationmenu} add command -label [::msgcat::mc {little too much}] -command { if { [ .editright.1.alcintegration2.buttonbar.2 cget -image ] != ${b52} } { xbutton .editright.1.alcintegration2.buttonbar.2 invoke } }
  ${alcintegrationmenu} add command -label [::msgcat::mc {passable}]        -command { if { [ .editright.1.alcintegration2.buttonbar.3 cget -image ] != ${b53} } { xbutton .editright.1.alcintegration2.buttonbar.3 invoke } }
  ${alcintegrationmenu} add command -label [::msgcat::mc {observable}]      -command { if { [ .editright.1.alcintegration2.buttonbar.4 cget -image ] != ${b54} } { xbutton .editright.1.alcintegration2.buttonbar.4 invoke } }
  ${alcintegrationmenu} add command -label [::msgcat::mc {integrated}]      -command { if { [ .editright.1.alcintegration2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.alcintegration2.buttonbar.5 invoke } }
  pack .editright.1.alcintegration2.text1 .editright.1.alcintegration2.buttonbar .editright.1.alcintegration2.text2 .editright.1.alcintegration2.help -side left
grid .editright.1.alcintegration1 .editright.1.alcintegration2 -sticky w
if { ${alcintegration} != {} } { xbutton .editright.1.alcintegration2.buttonbar.${alcintegration} invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.alcintegration2.buttonbar.1 -text [::msgcat::mc {flashy}]          -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.alcintegration2.buttonbar.2 -text [::msgcat::mc {little too much}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.alcintegration2.buttonbar.3 -text [::msgcat::mc {passable}]        -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.alcintegration2.buttonbar.4 -text [::msgcat::mc {observable}]      -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.alcintegration2.buttonbar.5 -text [::msgcat::mc {integrated}]      -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.alcintegration2.buttonbar.1 <Button-3> {+ tk_popup ${alcintegrationmenu} %X %Y }
bind .editright.1.alcintegration2.buttonbar.2 <Button-3> {+ tk_popup ${alcintegrationmenu} %X %Y }
bind .editright.1.alcintegration2.buttonbar.3 <Button-3> {+ tk_popup ${alcintegrationmenu} %X %Y }
bind .editright.1.alcintegration2.buttonbar.4 <Button-3> {+ tk_popup ${alcintegrationmenu} %X %Y }
bind .editright.1.alcintegration2.buttonbar.5 <Button-3> {+ tk_popup ${alcintegrationmenu} %X %Y }

label .editright.1.typical1 -text "[::msgcat::mc {Authentic}] " -font ${titlefont}
frame .editright.1.typical2
label .editright.1.typical2.text1 -text [::msgcat::mc {untypical}] -width ${ratewidth_a} -anchor e
  frame .editright.1.typical2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.typical2.buttonbar.1 -image ${l51} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.typical2.buttonbar.1 cget -image ] == ${b51} } {
        .editright.1.typical2.buttonbar.1 configure -image ${l51}
        set typical {}
      } else {
        .editright.1.typical2.buttonbar.1 configure -image ${b51}
        .editright.1.typical2.buttonbar.2 configure -image ${l52}
        .editright.1.typical2.buttonbar.3 configure -image ${l53}
        .editright.1.typical2.buttonbar.4 configure -image ${l54}
        .editright.1.typical2.buttonbar.5 configure -image ${l55}
        set typical {1}
      }
      points
    }
    xbutton .editright.1.typical2.buttonbar.2 -image ${l52} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.typical2.buttonbar.2 cget -image ] == ${b52} } {
        .editright.1.typical2.buttonbar.2 configure -image ${l52}
        set typical {}
      } else {
        .editright.1.typical2.buttonbar.1 configure -image ${l51}
        .editright.1.typical2.buttonbar.2 configure -image ${b52}
        .editright.1.typical2.buttonbar.3 configure -image ${l53}
        .editright.1.typical2.buttonbar.4 configure -image ${l54}
        .editright.1.typical2.buttonbar.5 configure -image ${l55}
        set typical {2}
      }
      points
    }
    xbutton .editright.1.typical2.buttonbar.3 -image ${l53} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.typical2.buttonbar.3 cget -image ] == ${b53} } {
        .editright.1.typical2.buttonbar.3 configure -image ${l53}
        set typical {}
      } else {
        .editright.1.typical2.buttonbar.1 configure -image ${l51}
        .editright.1.typical2.buttonbar.2 configure -image ${l52}
        .editright.1.typical2.buttonbar.3 configure -image ${b53}
        .editright.1.typical2.buttonbar.4 configure -image ${l54}
        .editright.1.typical2.buttonbar.5 configure -image ${l55}
        set typical {3}
      }
      points
    }
    xbutton .editright.1.typical2.buttonbar.4 -image ${l54} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.typical2.buttonbar.4 cget -image ] == ${b54} } {
        .editright.1.typical2.buttonbar.4 configure -image ${l54}
        set typical {}
      } else {
        .editright.1.typical2.buttonbar.1 configure -image ${l51}
        .editright.1.typical2.buttonbar.2 configure -image ${l52}
        .editright.1.typical2.buttonbar.3 configure -image ${l53}
        .editright.1.typical2.buttonbar.4 configure -image ${b54}
        .editright.1.typical2.buttonbar.5 configure -image ${l55}
        set typical {4}
      }
      points
    }
    xbutton .editright.1.typical2.buttonbar.5 -image ${l55} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.typical2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.typical2.buttonbar.5 configure -image ${l55}
        set typical {}
      } else {
        .editright.1.typical2.buttonbar.1 configure -image ${l51}
        .editright.1.typical2.buttonbar.2 configure -image ${l52}
        .editright.1.typical2.buttonbar.3 configure -image ${l53}
        .editright.1.typical2.buttonbar.4 configure -image ${l54}
        .editright.1.typical2.buttonbar.5 configure -image ${b55}
        set typical {5}
      }
      points
    }
    pack .editright.1.typical2.buttonbar.1 .editright.1.typical2.buttonbar.2 .editright.1.typical2.buttonbar.3 .editright.1.typical2.buttonbar.4 .editright.1.typical2.buttonbar.5 -side left
  label .editright.1.typical2.text2 -text [::msgcat::mc {typical}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.typical2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.typical2.help.menu
  set typicalmenu [ menu .editright.1.typical2.help.menu -tearoff 0 ]
  ${typicalmenu} add command -label [::msgcat::mc {untypical}] -command { if { [ .editright.1.typical2.buttonbar.1 cget -image ] != ${b51} } { xbutton .editright.1.typical2.buttonbar.1 invoke } }
  ${typicalmenu} add command -label [::msgcat::mc {hardly}]    -command { if { [ .editright.1.typical2.buttonbar.2 cget -image ] != ${b52} } { xbutton .editright.1.typical2.buttonbar.2 invoke } }
  ${typicalmenu} add command -label [::msgcat::mc {could be}]  -command { if { [ .editright.1.typical2.buttonbar.3 cget -image ] != ${b53} } { xbutton .editright.1.typical2.buttonbar.3 invoke } }
  ${typicalmenu} add command -label [::msgcat::mc {almost}]    -command { if { [ .editright.1.typical2.buttonbar.4 cget -image ] != ${b54} } { xbutton .editright.1.typical2.buttonbar.4 invoke } }
  ${typicalmenu} add command -label [::msgcat::mc {typical}]   -command { if { [ .editright.1.typical2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.typical2.buttonbar.5 invoke } }
  pack .editright.1.typical2.text1 .editright.1.typical2.buttonbar .editright.1.typical2.text2 .editright.1.typical2.help -side left
grid .editright.1.typical1 .editright.1.typical2 -sticky w
if { ${typical} != {} } { xbutton .editright.1.typical2.buttonbar.${typical} invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.typical2.buttonbar.1 -text [::msgcat::mc {untypical}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.typical2.buttonbar.2 -text [::msgcat::mc {hardly}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.typical2.buttonbar.3 -text [::msgcat::mc {could be}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.typical2.buttonbar.4 -text [::msgcat::mc {almost}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.typical2.buttonbar.5 -text [::msgcat::mc {typical}]   -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.typical2.buttonbar.1 <Button-3> {+ tk_popup ${typicalmenu} %X %Y }
bind .editright.1.typical2.buttonbar.2 <Button-3> {+ tk_popup ${typicalmenu} %X %Y }
bind .editright.1.typical2.buttonbar.3 <Button-3> {+ tk_popup ${typicalmenu} %X %Y }
bind .editright.1.typical2.buttonbar.4 <Button-3> {+ tk_popup ${typicalmenu} %X %Y }
bind .editright.1.typical2.buttonbar.5 <Button-3> {+ tk_popup ${typicalmenu} %X %Y }

label .editright.1.finish1 -text "[::msgcat::mc {Finish}] " -font ${titlefont}
frame .editright.1.finish2
label .editright.1.finish2.text1 -text [::msgcat::mc {untraceable}] -width ${ratewidth_a} -anchor e
  frame .editright.1.finish2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.finish2.buttonbar.1 -image ${l51} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.finish2.buttonbar.1 cget -image ] == ${b51} } {
        .editright.1.finish2.buttonbar.1 configure -image ${l51}
        set finish {}
      } else {
        .editright.1.finish2.buttonbar.1 configure -image ${b51}
        .editright.1.finish2.buttonbar.2 configure -image ${l52}
        .editright.1.finish2.buttonbar.3 configure -image ${l53}
        .editright.1.finish2.buttonbar.4 configure -image ${l54}
        .editright.1.finish2.buttonbar.5 configure -image ${l55}
        set finish {1}
      }
      points
    }
    xbutton .editright.1.finish2.buttonbar.2 -image ${l52} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.finish2.buttonbar.2 cget -image ] == ${b52} } {
        .editright.1.finish2.buttonbar.2 configure -image ${l52}
        set finish {}
      } else {
        .editright.1.finish2.buttonbar.1 configure -image ${l51}
        .editright.1.finish2.buttonbar.2 configure -image ${b52}
        .editright.1.finish2.buttonbar.3 configure -image ${l53}
        .editright.1.finish2.buttonbar.4 configure -image ${l54}
        .editright.1.finish2.buttonbar.5 configure -image ${l55}
        set finish {2}
      }
      points
    }
    xbutton .editright.1.finish2.buttonbar.3 -image ${l53} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.finish2.buttonbar.3 cget -image ] == ${b53} } {
        .editright.1.finish2.buttonbar.3 configure -image ${l53}
        set finish {}
      } else {
        .editright.1.finish2.buttonbar.1 configure -image ${l51}
        .editright.1.finish2.buttonbar.2 configure -image ${l52}
        .editright.1.finish2.buttonbar.3 configure -image ${b53}
        .editright.1.finish2.buttonbar.4 configure -image ${l54}
        .editright.1.finish2.buttonbar.5 configure -image ${l55}
        set finish {3}
      }
      points
    }
    xbutton .editright.1.finish2.buttonbar.4 -image ${l54} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.finish2.buttonbar.4 cget -image ] == ${b54} } {
        .editright.1.finish2.buttonbar.4 configure -image ${l54}
        set finish {}
      } else {
        .editright.1.finish2.buttonbar.1 configure -image ${l51}
        .editright.1.finish2.buttonbar.2 configure -image ${l52}
        .editright.1.finish2.buttonbar.3 configure -image ${l53}
        .editright.1.finish2.buttonbar.4 configure -image ${b54}
        .editright.1.finish2.buttonbar.5 configure -image ${l55}
        set finish {4}
      }
      points
    }
    xbutton .editright.1.finish2.buttonbar.5 -image ${l55} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.finish2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.finish2.buttonbar.5 configure -image ${l55}
        set finish {}
      } else {
        .editright.1.finish2.buttonbar.1 configure -image ${l51}
        .editright.1.finish2.buttonbar.2 configure -image ${l52}
        .editright.1.finish2.buttonbar.3 configure -image ${l53}
        .editright.1.finish2.buttonbar.4 configure -image ${l54}
        .editright.1.finish2.buttonbar.5 configure -image ${b55}
        set finish {5}
      }
      points
    }
    pack .editright.1.finish2.buttonbar.1 .editright.1.finish2.buttonbar.2 .editright.1.finish2.buttonbar.3 .editright.1.finish2.buttonbar.4 .editright.1.finish2.buttonbar.5 -side left
  label .editright.1.finish2.text2 -text [::msgcat::mc {endless}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.finish2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.finish2.help.menu
  set finishmenu [ menu .editright.1.finish2.help.menu -tearoff 0 ]
  ${finishmenu} add command -label [::msgcat::mc {untraceable}] -command { if { [ .editright.1.finish2.buttonbar.1 cget -image ] != ${b51} } { xbutton .editright.1.finish2.buttonbar.1 invoke } }
  ${finishmenu} add command -label [::msgcat::mc {short}]       -command { if { [ .editright.1.finish2.buttonbar.2 cget -image ] != ${b52} } { xbutton .editright.1.finish2.buttonbar.2 invoke } }
  ${finishmenu} add command -label [::msgcat::mc {medium}]      -command { if { [ .editright.1.finish2.buttonbar.3 cget -image ] != ${b53} } { xbutton .editright.1.finish2.buttonbar.3 invoke } }
  ${finishmenu} add command -label [::msgcat::mc {long}]        -command { if { [ .editright.1.finish2.buttonbar.4 cget -image ] != ${b54} } { xbutton .editright.1.finish2.buttonbar.4 invoke } }
  ${finishmenu} add command -label [::msgcat::mc {endless}]     -command { if { [ .editright.1.finish2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.finish2.buttonbar.5 invoke } }
  pack .editright.1.finish2.text1 .editright.1.finish2.buttonbar .editright.1.finish2.text2 .editright.1.finish2.help -side left
grid .editright.1.finish1 .editright.1.finish2 -sticky w
if { ${finish} != {} } { xbutton .editright.1.finish2.buttonbar.${finish} invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.finish2.buttonbar.1 -text [::msgcat::mc {untraceable}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.finish2.buttonbar.2 -text [::msgcat::mc {short}]       -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.finish2.buttonbar.3 -text [::msgcat::mc {medium}]      -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.finish2.buttonbar.4 -text [::msgcat::mc {long}]        -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.finish2.buttonbar.5 -text [::msgcat::mc {endless}]     -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.finish2.buttonbar.1 <Button-3> {+ tk_popup ${finishmenu} %X %Y }
bind .editright.1.finish2.buttonbar.2 <Button-3> {+ tk_popup ${finishmenu} %X %Y }
bind .editright.1.finish2.buttonbar.3 <Button-3> {+ tk_popup ${finishmenu} %X %Y }
bind .editright.1.finish2.buttonbar.4 <Button-3> {+ tk_popup ${finishmenu} %X %Y }
bind .editright.1.finish2.buttonbar.5 <Button-3> {+ tk_popup ${finishmenu} %X %Y }

label .editright.1.balance1 -text "[::msgcat::mc {Harmony}] " -font ${titlefont}
frame .editright.1.balance2
label .editright.1.balance2.text1 -text [::msgcat::mc {bumpy}] -width ${ratewidth_a} -anchor e
  frame .editright.1.balance2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.balance2.buttonbar.1 -image ${l51} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.balance2.buttonbar.1 cget -image ] == ${b51} } {
        .editright.1.balance2.buttonbar.1 configure -image ${l51}
        set balance {}
      } else {
        .editright.1.balance2.buttonbar.1 configure -image ${b51}
        .editright.1.balance2.buttonbar.2 configure -image ${l52}
        .editright.1.balance2.buttonbar.3 configure -image ${l53}
        .editright.1.balance2.buttonbar.4 configure -image ${l54}
        .editright.1.balance2.buttonbar.5 configure -image ${l55}
        set balance {1}
      }
      points
    }
    xbutton .editright.1.balance2.buttonbar.2 -image ${l52} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.balance2.buttonbar.2 cget -image ] == ${b52} } {
        .editright.1.balance2.buttonbar.2 configure -image ${l52}
        set balance {}
      } else {
        .editright.1.balance2.buttonbar.1 configure -image ${l51}
        .editright.1.balance2.buttonbar.2 configure -image ${b52}
        .editright.1.balance2.buttonbar.3 configure -image ${l53}
        .editright.1.balance2.buttonbar.4 configure -image ${l54}
        .editright.1.balance2.buttonbar.5 configure -image ${l55}
        set balance {2}
      }
      points
    }
    xbutton .editright.1.balance2.buttonbar.3 -image ${l53} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.balance2.buttonbar.3 cget -image ] == ${b53} } {
        .editright.1.balance2.buttonbar.3 configure -image ${l53}
        set balance {}
      } else {
        .editright.1.balance2.buttonbar.1 configure -image ${l51}
        .editright.1.balance2.buttonbar.2 configure -image ${l52}
        .editright.1.balance2.buttonbar.3 configure -image ${b53}
        .editright.1.balance2.buttonbar.4 configure -image ${l54}
        .editright.1.balance2.buttonbar.5 configure -image ${l55}
        set balance {3}
      }
      points
    }
    xbutton .editright.1.balance2.buttonbar.4 -image ${l54} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.balance2.buttonbar.4 cget -image ] == ${b54} } {
        .editright.1.balance2.buttonbar.4 configure -image ${l54}
        set balance {}
      } else {
        .editright.1.balance2.buttonbar.1 configure -image ${l51}
        .editright.1.balance2.buttonbar.2 configure -image ${l52}
        .editright.1.balance2.buttonbar.3 configure -image ${l53}
        .editright.1.balance2.buttonbar.4 configure -image ${b54}
        .editright.1.balance2.buttonbar.5 configure -image ${l55}
        set balance {4}
      }
      points
    }
    xbutton .editright.1.balance2.buttonbar.5 -image ${l55} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.balance2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.balance2.buttonbar.5 configure -image ${l55}
        set balance {}
      } else {
        .editright.1.balance2.buttonbar.1 configure -image ${l51}
        .editright.1.balance2.buttonbar.2 configure -image ${l52}
        .editright.1.balance2.buttonbar.3 configure -image ${l53}
        .editright.1.balance2.buttonbar.4 configure -image ${l54}
        .editright.1.balance2.buttonbar.5 configure -image ${b55}
        set balance {5}
      }
      points
    }
    pack .editright.1.balance2.buttonbar.1 .editright.1.balance2.buttonbar.2 .editright.1.balance2.buttonbar.3 .editright.1.balance2.buttonbar.4 .editright.1.balance2.buttonbar.5 -side left
  label .editright.1.balance2.text2 -text [::msgcat::mc {elegant}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.balance2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.balance2.help.menu
  set balancemenu [ menu .editright.1.balance2.help.menu -tearoff 0 ]
  ${balancemenu} add command -label [::msgcat::mc {bumpy}]      -command { if { [ .editright.1.balance2.buttonbar.1 cget -image ] != ${b51} } { xbutton .editright.1.balance2.buttonbar.1 invoke } }
  ${balancemenu} add command -label [::msgcat::mc {receivable}] -command { if { [ .editright.1.balance2.buttonbar.2 cget -image ] != ${b52} } { xbutton .editright.1.balance2.buttonbar.2 invoke } }
  ${balancemenu} add command -label [::msgcat::mc {satisfying}] -command { if { [ .editright.1.balance2.buttonbar.3 cget -image ] != ${b53} } { xbutton .editright.1.balance2.buttonbar.3 invoke } }
  ${balancemenu} add command -label [::msgcat::mc {balanced}]   -command { if { [ .editright.1.balance2.buttonbar.4 cget -image ] != ${b54} } { xbutton .editright.1.balance2.buttonbar.4 invoke } }
  ${balancemenu} add command -label [::msgcat::mc {elegant}]    -command { if { [ .editright.1.balance2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.balance2.buttonbar.5 invoke } }
  pack .editright.1.balance2.text1 .editright.1.balance2.buttonbar .editright.1.balance2.text2 .editright.1.balance2.help -side left
grid .editright.1.balance1 .editright.1.balance2 -sticky w
if { ${balance} != {} } { xbutton .editright.1.balance2.buttonbar.${balance} invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.balance2.buttonbar.1 -text [::msgcat::mc {bumpy}]      -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.balance2.buttonbar.2 -text [::msgcat::mc {receivable}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.balance2.buttonbar.3 -text [::msgcat::mc {satisfying}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.balance2.buttonbar.4 -text [::msgcat::mc {balanced}]   -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.balance2.buttonbar.5 -text [::msgcat::mc {elegant}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.balance2.buttonbar.1 <Button-3> {+ tk_popup ${balancemenu} %X %Y }
bind .editright.1.balance2.buttonbar.2 <Button-3> {+ tk_popup ${balancemenu} %X %Y }
bind .editright.1.balance2.buttonbar.3 <Button-3> {+ tk_popup ${balancemenu} %X %Y }
bind .editright.1.balance2.buttonbar.4 <Button-3> {+ tk_popup ${balancemenu} %X %Y }
bind .editright.1.balance2.buttonbar.5 <Button-3> {+ tk_popup ${balancemenu} %X %Y }

label .editright.1.believable1 -text "[::msgcat::mc {Style}] " -font ${titlefont}
frame .editright.1.believable2
  label .editright.1.believable2.text1 -text [::msgcat::mc {industrial}] -width ${ratewidth_a} -anchor e
  frame .editright.1.believable2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.believable2.buttonbar.1 -image ${l51} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.believable2.buttonbar.1 cget -image ] == ${b51} } {
        .editright.1.believable2.buttonbar.1 configure -image ${l51}
        set believable {}
      } else {
        .editright.1.believable2.buttonbar.1 configure -image ${b51}
        .editright.1.believable2.buttonbar.2 configure -image ${l52}
        .editright.1.believable2.buttonbar.3 configure -image ${l53}
        .editright.1.believable2.buttonbar.4 configure -image ${l54}
        .editright.1.believable2.buttonbar.5 configure -image ${l55}
        set believable {1}
      }
    }
    xbutton .editright.1.believable2.buttonbar.2 -image ${l52} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.believable2.buttonbar.2 cget -image ] == ${b52} } {
        .editright.1.believable2.buttonbar.2 configure -image ${l52}
        set believable {}
      } else {
        .editright.1.believable2.buttonbar.1 configure -image ${l51}
        .editright.1.believable2.buttonbar.2 configure -image ${b52}
        .editright.1.believable2.buttonbar.3 configure -image ${l53}
        .editright.1.believable2.buttonbar.4 configure -image ${l54}
        .editright.1.believable2.buttonbar.5 configure -image ${l55}
        set believable {4}
      }
    }
    xbutton .editright.1.believable2.buttonbar.3 -image ${l53} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.believable2.buttonbar.3 cget -image ] == ${b53} } {
        .editright.1.believable2.buttonbar.3 configure -image ${l53}
        set believable {}
      } else {
        .editright.1.believable2.buttonbar.1 configure -image ${l51}
        .editright.1.believable2.buttonbar.2 configure -image ${l52}
        .editright.1.believable2.buttonbar.3 configure -image ${b53}
        .editright.1.believable2.buttonbar.4 configure -image ${l54}
        .editright.1.believable2.buttonbar.5 configure -image ${l55}
        set believable {2}
      }
    }
    xbutton .editright.1.believable2.buttonbar.4 -image ${l54} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.believable2.buttonbar.4 cget -image ] == ${b54} } {
        .editright.1.believable2.buttonbar.4 configure -image ${l54}
        set believable {}
      } else {
        .editright.1.believable2.buttonbar.1 configure -image ${l51}
        .editright.1.believable2.buttonbar.2 configure -image ${l52}
        .editright.1.believable2.buttonbar.3 configure -image ${l53}
        .editright.1.believable2.buttonbar.4 configure -image ${b54}
        .editright.1.believable2.buttonbar.5 configure -image ${l55}
        set believable {5}
      }
    }
    xbutton .editright.1.believable2.buttonbar.5 -image ${l55} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.believable2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.believable2.buttonbar.5 configure -image ${l55}
        set believable {}
      } else {
        .editright.1.believable2.buttonbar.1 configure -image ${l51}
        .editright.1.believable2.buttonbar.2 configure -image ${l52}
        .editright.1.believable2.buttonbar.3 configure -image ${l53}
        .editright.1.believable2.buttonbar.4 configure -image ${l54}
        .editright.1.believable2.buttonbar.5 configure -image ${b55}
        set believable {3}
      }
    }
    pack .editright.1.believable2.buttonbar.1 .editright.1.believable2.buttonbar.2 .editright.1.believable2.buttonbar.3 .editright.1.believable2.buttonbar.4 .editright.1.believable2.buttonbar.5 -side left
  label .editright.1.believable2.text2 -text [::msgcat::mc {traditional}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.believable2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.believable2.help.menu
  set believablemenu [ menu .editright.1.believable2.help.menu -tearoff 0 ]
  ${believablemenu} add command -label [::msgcat::mc {industrial}]  -command { if { [ .editright.1.believable2.buttonbar.1 cget -image ] != ${b51} } { xbutton .editright.1.believable2.buttonbar.1 invoke } }
  ${believablemenu} add command -label [::msgcat::mc {rather industrial}]  -command { if { [ .editright.1.believable2.buttonbar.2 cget -image ] != ${b52} } { xbutton .editright.1.believable2.buttonbar.2 invoke } }
  ${believablemenu} add command -label [::msgcat::mc {unsure}]      -command { if { [ .editright.1.believable2.buttonbar.3 cget -image ] != ${b53} } { xbutton .editright.1.believable2.buttonbar.3 invoke } }
  ${believablemenu} add command -label [::msgcat::mc {rather traditional}] -command { if { [ .editright.1.believable2.buttonbar.4 cget -image ] != ${b54} } { xbutton .editright.1.believable2.buttonbar.4 invoke } }
  ${believablemenu} add command -label [::msgcat::mc {traditional}] -command { if { [ .editright.1.believable2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.believable2.buttonbar.5 invoke } }
  pack .editright.1.believable2.text1 .editright.1.believable2.buttonbar .editright.1.believable2.text2 .editright.1.believable2.help -side left
grid .editright.1.believable1 .editright.1.believable2 -sticky w
if { ${believable} == {1} } { xbutton .editright.1.believable2.buttonbar.1 invoke }
if { ${believable} == {2} } { xbutton .editright.1.believable2.buttonbar.3 invoke }
if { ${believable} == {3} } { xbutton .editright.1.believable2.buttonbar.5 invoke }
if { ${believable} == {4} } { xbutton .editright.1.believable2.buttonbar.2 invoke }
if { ${believable} == {5} } { xbutton .editright.1.believable2.buttonbar.4 invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.believable2.buttonbar.1 -text [::msgcat::mc {industrial}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.believable2.buttonbar.2 -text [::msgcat::mc {rather industrial}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.believable2.buttonbar.3 -text [::msgcat::mc {unsure}]      -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.believable2.buttonbar.4 -text [::msgcat::mc {rather traditional}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.believable2.buttonbar.5 -text [::msgcat::mc {traditional}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.believable2.buttonbar.1 <Button-3> {+ tk_popup ${believablemenu} %X %Y }
bind .editright.1.believable2.buttonbar.2 <Button-3> {+ tk_popup ${believablemenu} %X %Y }
bind .editright.1.believable2.buttonbar.3 <Button-3> {+ tk_popup ${believablemenu} %X %Y }
bind .editright.1.believable2.buttonbar.4 <Button-3> {+ tk_popup ${believablemenu} %X %Y }
bind .editright.1.believable2.buttonbar.5 <Button-3> {+ tk_popup ${believablemenu} %X %Y }

label .editright.1.impression1 -text "[::msgcat::mc {Impression}] " -font ${titlefont}
frame .editright.1.impression2
label .editright.1.impression2.text1 -text [::msgcat::mc {failed}] -width ${ratewidth_a} -anchor e
  frame .editright.1.impression2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.impression2.buttonbar.1 -image ${l51} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.impression2.buttonbar.1 cget -image ] == ${b51} } {
        .editright.1.impression2.buttonbar.1 configure -image ${l51}
        set impression {}
      } else {
        .editright.1.impression2.buttonbar.1 configure -image ${b51}
        .editright.1.impression2.buttonbar.2 configure -image ${l52}
        .editright.1.impression2.buttonbar.3 configure -image ${l53}
        .editright.1.impression2.buttonbar.4 configure -image ${l54}
        .editright.1.impression2.buttonbar.5 configure -image ${l55}
        set impression {1}
      }
      points
    }
    xbutton .editright.1.impression2.buttonbar.2 -image ${l52} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.impression2.buttonbar.2 cget -image ] == ${b52} } {
        .editright.1.impression2.buttonbar.2 configure -image ${l52}
        set impression {}
      } else {
        .editright.1.impression2.buttonbar.1 configure -image ${l51}
        .editright.1.impression2.buttonbar.2 configure -image ${b52}
        .editright.1.impression2.buttonbar.3 configure -image ${l53}
        .editright.1.impression2.buttonbar.4 configure -image ${l54}
        .editright.1.impression2.buttonbar.5 configure -image ${l55}
        set impression {2}
      }
      points
    }
    xbutton .editright.1.impression2.buttonbar.3 -image ${l53} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.impression2.buttonbar.3 cget -image ] == ${b53} } {
        .editright.1.impression2.buttonbar.3 configure -image ${l53}
        set impression {}
      } else {
        .editright.1.impression2.buttonbar.1 configure -image ${l51}
        .editright.1.impression2.buttonbar.2 configure -image ${l52}
        .editright.1.impression2.buttonbar.3 configure -image ${b53}
        .editright.1.impression2.buttonbar.4 configure -image ${l54}
        .editright.1.impression2.buttonbar.5 configure -image ${l55}
        set impression {3}
      }
      points
    }
    xbutton .editright.1.impression2.buttonbar.4 -image ${l54} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.impression2.buttonbar.4 cget -image ] == ${b54} } {
        .editright.1.impression2.buttonbar.4 configure -image ${l54}
        set impression {}
      } else {
        .editright.1.impression2.buttonbar.1 configure -image ${l51}
        .editright.1.impression2.buttonbar.2 configure -image ${l52}
        .editright.1.impression2.buttonbar.3 configure -image ${l53}
        .editright.1.impression2.buttonbar.4 configure -image ${b54}
        .editright.1.impression2.buttonbar.5 configure -image ${l55}
        set impression {4}
      }
      points
    }
    xbutton .editright.1.impression2.buttonbar.5 -image ${l55} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.impression2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.impression2.buttonbar.5 configure -image ${l55}
        set impression {}
      } else {
        .editright.1.impression2.buttonbar.1 configure -image ${l51}
        .editright.1.impression2.buttonbar.2 configure -image ${l52}
        .editright.1.impression2.buttonbar.3 configure -image ${l53}
        .editright.1.impression2.buttonbar.4 configure -image ${l54}
        .editright.1.impression2.buttonbar.5 configure -image ${b55}
        set impression {5}
      }
      points
    }
    pack .editright.1.impression2.buttonbar.1 .editright.1.impression2.buttonbar.2 .editright.1.impression2.buttonbar.3 .editright.1.impression2.buttonbar.4 .editright.1.impression2.buttonbar.5 -side left
  label .editright.1.impression2.text2 -text [::msgcat::mc {magnificent}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.impression2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.impression2.help.menu
  set impressionmenu [ menu .editright.1.impression2.help.menu -tearoff 0 ]
  ${impressionmenu} add command -label [::msgcat::mc {failed}]      -command { if { [ .editright.1.impression2.buttonbar.1 cget -image ] != ${b51} } { xbutton .editright.1.impression2.buttonbar.1 invoke } }
  ${impressionmenu} add command -label [::msgcat::mc {workaday}]    -command { if { [ .editright.1.impression2.buttonbar.2 cget -image ] != ${b52} } { xbutton .editright.1.impression2.buttonbar.2 invoke } }
  ${impressionmenu} add command -label [::msgcat::mc {good}]        -command { if { [ .editright.1.impression2.buttonbar.3 cget -image ] != ${b53} } { xbutton .editright.1.impression2.buttonbar.3 invoke } }
  ${impressionmenu} add command -label [::msgcat::mc {very good}]   -command { if { [ .editright.1.impression2.buttonbar.4 cget -image ] != ${b54} } { xbutton .editright.1.impression2.buttonbar.4 invoke } }
  ${impressionmenu} add command -label [::msgcat::mc {magnificent}] -command { if { [ .editright.1.impression2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.impression2.buttonbar.5 invoke } }
  pack .editright.1.impression2.text1 .editright.1.impression2.buttonbar .editright.1.impression2.text2 .editright.1.impression2.help -side left
grid .editright.1.impression1 .editright.1.impression2 -sticky w
if { ${impression} != {} } { xbutton .editright.1.impression2.buttonbar.${impression} invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.impression2.buttonbar.1 -text [::msgcat::mc {failed}]      -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.impression2.buttonbar.2 -text [::msgcat::mc {workaday}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.impression2.buttonbar.3 -text [::msgcat::mc {good}]        -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.impression2.buttonbar.4 -text [::msgcat::mc {very good}]   -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.impression2.buttonbar.5 -text [::msgcat::mc {magnificent}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.impression2.buttonbar.1 <Button-3> {+ tk_popup ${impressionmenu} %X %Y }
bind .editright.1.impression2.buttonbar.2 <Button-3> {+ tk_popup ${impressionmenu} %X %Y }
bind .editright.1.impression2.buttonbar.3 <Button-3> {+ tk_popup ${impressionmenu} %X %Y }
bind .editright.1.impression2.buttonbar.4 <Button-3> {+ tk_popup ${impressionmenu} %X %Y }
bind .editright.1.impression2.buttonbar.5 <Button-3> {+ tk_popup ${impressionmenu} %X %Y }

label .editright.1.headache1 -text "[::msgcat::mc {Headache}] " -font ${titlefont}
frame .editright.1.headache2
  label .editright.1.headache2.text1 -text [::msgcat::mc {high risk}] -width ${ratewidth_a} -anchor e
  frame .editright.1.headache2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.headache2.buttonbar.1 -image ${l51} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.headache2.buttonbar.1 cget -image ] == ${b51} } {
        .editright.1.headache2.buttonbar.1 configure -image ${l51}
        set headache {}
      } else {
        .editright.1.headache2.buttonbar.1 configure -image ${b51}
        .editright.1.headache2.buttonbar.2 configure -image ${l52}
        .editright.1.headache2.buttonbar.3 configure -image ${l53}
        .editright.1.headache2.buttonbar.4 configure -image ${l54}
        .editright.1.headache2.buttonbar.5 configure -image ${l55}
        set headache {3}
      }
    }
    xbutton .editright.1.headache2.buttonbar.2 -image ${l52} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.headache2.buttonbar.2 cget -image ] == ${b52} } {
        .editright.1.headache2.buttonbar.2 configure -image ${l52}
        set headache {}
      } else {
        .editright.1.headache2.buttonbar.1 configure -image ${l51}
        .editright.1.headache2.buttonbar.2 configure -image ${b52}
        .editright.1.headache2.buttonbar.3 configure -image ${l53}
        .editright.1.headache2.buttonbar.4 configure -image ${l54}
        .editright.1.headache2.buttonbar.5 configure -image ${l55}
        set headache {4}
      }
    }
    xbutton .editright.1.headache2.buttonbar.3 -image ${l53} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.headache2.buttonbar.3 cget -image ] == ${b53} } {
        .editright.1.headache2.buttonbar.3 configure -image ${l53}
        set headache {}
      } else {
        .editright.1.headache2.buttonbar.1 configure -image ${l51}
        .editright.1.headache2.buttonbar.2 configure -image ${l52}
        .editright.1.headache2.buttonbar.3 configure -image ${b53}
        .editright.1.headache2.buttonbar.4 configure -image ${l54}
        .editright.1.headache2.buttonbar.5 configure -image ${l55}
        set headache {2}
      }
    }
    xbutton .editright.1.headache2.buttonbar.4 -image ${l54} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.headache2.buttonbar.4 cget -image ] == ${b54} } {
        .editright.1.headache2.buttonbar.4 configure -image ${l54}
        set headache {}
      } else {
        .editright.1.headache2.buttonbar.1 configure -image ${l51}
        .editright.1.headache2.buttonbar.2 configure -image ${l52}
        .editright.1.headache2.buttonbar.3 configure -image ${l53}
        .editright.1.headache2.buttonbar.4 configure -image ${b54}
        .editright.1.headache2.buttonbar.5 configure -image ${l55}
        set headache {5}
      }
    }
    xbutton .editright.1.headache2.buttonbar.5 -image ${l55} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.headache2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.headache2.buttonbar.5 configure -image ${l55}
        set headache {}
      } else {
        .editright.1.headache2.buttonbar.1 configure -image ${l51}
        .editright.1.headache2.buttonbar.2 configure -image ${l52}
        .editright.1.headache2.buttonbar.3 configure -image ${l53}
        .editright.1.headache2.buttonbar.4 configure -image ${l54}
        .editright.1.headache2.buttonbar.5 configure -image ${b55}
        set headache {1}
      }
    }
    pack .editright.1.headache2.buttonbar.1 .editright.1.headache2.buttonbar.2 .editright.1.headache2.buttonbar.3 .editright.1.headache2.buttonbar.4 .editright.1.headache2.buttonbar.5 -side left
  label .editright.1.headache2.text2 -text [::msgcat::mc {low risk}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.headache2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.headache2.help.menu
  set headachemenu [ menu .editright.1.headache2.help.menu -tearoff 0 ]
  ${headachemenu} add command -label [::msgcat::mc {high risk}]  -command { if { [ .editright.1.headache2.buttonbar.1 cget -image ] != ${b51} } { xbutton .editright.1.headache2.buttonbar.1 invoke } }
  ${headachemenu} add command -label [::msgcat::mc {critically}] -command { if { [ .editright.1.headache2.buttonbar.2 cget -image ] != ${b52} } { xbutton .editright.1.headache2.buttonbar.2 invoke } }
  ${headachemenu} add command -label [::msgcat::mc {medium}]     -command { if { [ .editright.1.headache2.buttonbar.3 cget -image ] != ${b53} } { xbutton .editright.1.headache2.buttonbar.3 invoke } }
  ${headachemenu} add command -label [::msgcat::mc {less risk}]  -command { if { [ .editright.1.headache2.buttonbar.4 cget -image ] != ${b54} } { xbutton .editright.1.headache2.buttonbar.4 invoke } }
  ${headachemenu} add command -label [::msgcat::mc {low risk}]   -command { if { [ .editright.1.headache2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.headache2.buttonbar.5 invoke } }
  pack .editright.1.headache2.text1 .editright.1.headache2.buttonbar .editright.1.headache2.text2 .editright.1.headache2.help -side left
grid .editright.1.headache1 .editright.1.headache2 -sticky w
if { ${headache} == {1} } { xbutton .editright.1.headache2.buttonbar.5 invoke }
if { ${headache} == {2} } { xbutton .editright.1.headache2.buttonbar.3 invoke }
if { ${headache} == {3} } { xbutton .editright.1.headache2.buttonbar.1 invoke }
if { ${headache} == {4} } { xbutton .editright.1.headache2.buttonbar.2 invoke }
if { ${headache} == {5} } { xbutton .editright.1.headache2.buttonbar.4 invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.headache2.buttonbar.1 -text [::msgcat::mc {high risk}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.headache2.buttonbar.2 -text [::msgcat::mc {critically}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.headache2.buttonbar.3 -text [::msgcat::mc {medium}]     -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.headache2.buttonbar.4 -text [::msgcat::mc {less risk}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.headache2.buttonbar.5 -text [::msgcat::mc {low risk}]   -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.headache2.buttonbar.1 <Button-3> {+ tk_popup ${headachemenu} %X %Y }
bind .editright.1.headache2.buttonbar.2 <Button-3> {+ tk_popup ${headachemenu} %X %Y }
bind .editright.1.headache2.buttonbar.3 <Button-3> {+ tk_popup ${headachemenu} %X %Y }
bind .editright.1.headache2.buttonbar.4 <Button-3> {+ tk_popup ${headachemenu} %X %Y }
bind .editright.1.headache2.buttonbar.5 <Button-3> {+ tk_popup ${headachemenu} %X %Y }

label .editright.1.value1 -text "[::msgcat::mc {Price Value}] " -font ${titlefont}
frame .editright.1.value2
  label .editright.1.value2.text1 -text [::msgcat::mc {overpriced}] -width ${ratewidth_a} -anchor e
  frame .editright.1.value2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.value2.buttonbar.1 -image ${l51} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.value2.buttonbar.1 cget -image ] == ${b51} } {
        .editright.1.value2.buttonbar.1 configure -image ${l51}
        set value {}
      } else {
        .editright.1.value2.buttonbar.1 configure -image ${b51}
        .editright.1.value2.buttonbar.2 configure -image ${l52}
        .editright.1.value2.buttonbar.3 configure -image ${l53}
        .editright.1.value2.buttonbar.4 configure -image ${l54}
        .editright.1.value2.buttonbar.5 configure -image ${l55}
        set value {1}
      }
    }
    xbutton .editright.1.value2.buttonbar.2 -image ${l52} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.value2.buttonbar.2 cget -image ] == ${b52} } {
        .editright.1.value2.buttonbar.2 configure -image ${l52}
        set value {}
      } else {
        .editright.1.value2.buttonbar.1 configure -image ${l51}
        .editright.1.value2.buttonbar.2 configure -image ${b52}
        .editright.1.value2.buttonbar.3 configure -image ${l53}
        .editright.1.value2.buttonbar.4 configure -image ${l54}
        .editright.1.value2.buttonbar.5 configure -image ${l55}
        set value {4}
      }
    }
    xbutton .editright.1.value2.buttonbar.3 -image ${l53} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.value2.buttonbar.3 cget -image ] == ${b53} } {
        .editright.1.value2.buttonbar.3 configure -image ${l53}
        set value {}
      } else {
        .editright.1.value2.buttonbar.1 configure -image ${l51}
        .editright.1.value2.buttonbar.2 configure -image ${l52}
        .editright.1.value2.buttonbar.3 configure -image ${b53}
        .editright.1.value2.buttonbar.4 configure -image ${l54}
        .editright.1.value2.buttonbar.5 configure -image ${l55}
        set value {2}
      }
    }
    xbutton .editright.1.value2.buttonbar.4 -image ${l54} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.value2.buttonbar.4 cget -image ] == ${b54} } {
        .editright.1.value2.buttonbar.4 configure -image ${l54}
        set value {}
      } else {
        .editright.1.value2.buttonbar.1 configure -image ${l51}
        .editright.1.value2.buttonbar.2 configure -image ${l52}
        .editright.1.value2.buttonbar.3 configure -image ${l53}
        .editright.1.value2.buttonbar.4 configure -image ${b54}
        .editright.1.value2.buttonbar.5 configure -image ${l55}
        set value {5}
      }
    }
    xbutton .editright.1.value2.buttonbar.5 -image ${l55} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.value2.buttonbar.5 cget -image ] == ${b55} } {
        .editright.1.value2.buttonbar.5 configure -image ${l55}
        set value {}
      } else {
        .editright.1.value2.buttonbar.1 configure -image ${l51}
        .editright.1.value2.buttonbar.2 configure -image ${l52}
        .editright.1.value2.buttonbar.3 configure -image ${l53}
        .editright.1.value2.buttonbar.4 configure -image ${l54}
        .editright.1.value2.buttonbar.5 configure -image ${b55}
        set value {3}
      }
    }
    pack .editright.1.value2.buttonbar.1 .editright.1.value2.buttonbar.2 .editright.1.value2.buttonbar.3 .editright.1.value2.buttonbar.4 .editright.1.value2.buttonbar.5 -side left
  label .editright.1.value2.text2 -text [::msgcat::mc {cheap}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.value2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.value2.help.menu
  set valuemenu [ menu .editright.1.value2.help.menu -tearoff 0 ]
  ${valuemenu} add command -label [::msgcat::mc {overpriced}] -command { if { [ .editright.1.value2.buttonbar.1 cget -image ] != ${b51} } { xbutton .editright.1.value2.buttonbar.1 invoke } }
  ${valuemenu} add command -label [::msgcat::mc {expensive}]  -command { if { [ .editright.1.value2.buttonbar.2 cget -image ] != ${b52} } { xbutton .editright.1.value2.buttonbar.2 invoke } }
  ${valuemenu} add command -label [::msgcat::mc {acceptable}] -command { if { [ .editright.1.value2.buttonbar.3 cget -image ] != ${b53} } { xbutton .editright.1.value2.buttonbar.3 invoke } }
  ${valuemenu} add command -label [::msgcat::mc {good value}] -command { if { [ .editright.1.value2.buttonbar.4 cget -image ] != ${b54} } { xbutton .editright.1.value2.buttonbar.4 invoke } }
  ${valuemenu} add command -label [::msgcat::mc {cheap}]      -command { if { [ .editright.1.value2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.value2.buttonbar.5 invoke } }
  pack .editright.1.value2.text1 .editright.1.value2.buttonbar .editright.1.value2.text2 .editright.1.value2.help -side left
grid .editright.1.value1 .editright.1.value2 -sticky w
if { ${value} == {1} } { xbutton .editright.1.value2.buttonbar.1 invoke }
if { ${value} == {2} } { xbutton .editright.1.value2.buttonbar.3 invoke }
if { ${value} == {3} } { xbutton .editright.1.value2.buttonbar.5 invoke }
if { ${value} == {4} } { xbutton .editright.1.value2.buttonbar.2 invoke }
if { ${value} == {5} } { xbutton .editright.1.value2.buttonbar.4 invoke }
if { ${tooltips} == {true} } {
  ::ttips .editright.1.value2.buttonbar.1 -text [::msgcat::mc {overpriced}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.value2.buttonbar.2 -text [::msgcat::mc {expensive}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.value2.buttonbar.3 -text [::msgcat::mc {acceptable}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.value2.buttonbar.4 -text [::msgcat::mc {good value}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.value2.buttonbar.5 -text [::msgcat::mc {cheap}]      -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.value2.buttonbar.1 <Button-3> {+ tk_popup ${valuemenu} %X %Y }
bind .editright.1.value2.buttonbar.2 <Button-3> {+ tk_popup ${valuemenu} %X %Y }
bind .editright.1.value2.buttonbar.3 <Button-3> {+ tk_popup ${valuemenu} %X %Y }
bind .editright.1.value2.buttonbar.4 <Button-3> {+ tk_popup ${valuemenu} %X %Y }
bind .editright.1.value2.buttonbar.5 <Button-3> {+ tk_popup ${valuemenu} %X %Y }

set evol_update {false}
if { ${evol_date} == {} } { 
  label .editright.1.evolution1 -text "[::msgcat::mc {Evolution}] " -font ${titlefont}
} else {
  label .editright.1.evolution1 -text "${evol_date} " -font ${titlefont}
}
frame .editright.1.evolution2
  label .editright.1.evolution2.text1 -text [::msgcat::mc {unseasoned}] -width ${ratewidth_a} -anchor e
  frame .editright.1.evolution2.buttonbar -borderwidth 1 -relief sunken
    xbutton .editright.1.evolution2.buttonbar.1 -image ${l51} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.evolution2.buttonbar.1 cget -image ] == ${b51} } {
        .editright.1.evolution2.buttonbar.1 configure -image ${l51}
        set evolution {}
        set evol_date {}
        .editright.1.evolution1 configure -text "[::msgcat::mc {Evolution}] "
      } else {
        .editright.1.evolution2.buttonbar.1 configure -image ${b51}
        .editright.1.evolution2.buttonbar.2 configure -image ${l52}
        .editright.1.evolution2.buttonbar.3 configure -image ${l53}
        .editright.1.evolution2.buttonbar.4 configure -image ${l54}
        .editright.1.evolution2.buttonbar.5 configure -image ${l55}
        set evolution {1}
        if { ${evol_update} == {true} } {
          set evol_date "${today_month}/${today_year}"
          .editright.1.evolution1 configure -text "${evol_date} "
        } else {
          set evol_update {true}
        }
      }
    }
    xbutton .editright.1.evolution2.buttonbar.2 -image ${l52} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.evolution2.buttonbar.2 cget -image ] == ${b53} } {
        .editright.1.evolution2.buttonbar.2 configure -image ${l52}
        set evolution {}
        set evol_date {}
        .editright.1.evolution1 configure -text "[::msgcat::mc {Evolution}] "
      } else {
        .editright.1.evolution2.buttonbar.1 configure -image ${l51}
        .editright.1.evolution2.buttonbar.2 configure -image ${b53}
        .editright.1.evolution2.buttonbar.3 configure -image ${l53}
        .editright.1.evolution2.buttonbar.4 configure -image ${l54}
        .editright.1.evolution2.buttonbar.5 configure -image ${l55}
        set evolution {4}
        if { ${evol_update} == {true} } {
          set evol_date "${today_month}/${today_year}"
          .editright.1.evolution1 configure -text "${evol_date} "
        } else {
          set evol_update {true}
        }
      }
    }
    xbutton .editright.1.evolution2.buttonbar.3 -image ${l53} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.evolution2.buttonbar.3 cget -image ] == ${b54} } {
        .editright.1.evolution2.buttonbar.3 configure -image ${l53}
        set evolution {}
        set evol_date {}
        .editright.1.evolution1 configure -text "[::msgcat::mc {Evolution}] "
      } else {
        .editright.1.evolution2.buttonbar.1 configure -image ${l51}
        .editright.1.evolution2.buttonbar.2 configure -image ${l52}
        .editright.1.evolution2.buttonbar.3 configure -image ${b54}
        .editright.1.evolution2.buttonbar.4 configure -image ${l54}
        .editright.1.evolution2.buttonbar.5 configure -image ${l55}
        set evolution {2}
        if { ${evol_update} == {true} } {
          set evol_date "${today_month}/${today_year}"
          .editright.1.evolution1 configure -text "${evol_date} "
        } else {
          set evol_update {true}
        }
      }
    }
    xbutton .editright.1.evolution2.buttonbar.4 -image ${l54} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.evolution2.buttonbar.4 cget -image ] == ${b55} } {
        .editright.1.evolution2.buttonbar.4 configure -image ${l54}
        set evolution {}
        set evol_date {}
        .editright.1.evolution1 configure -text "[::msgcat::mc {Evolution}] "
      } else {
        .editright.1.evolution2.buttonbar.1 configure -image ${l51}
        .editright.1.evolution2.buttonbar.2 configure -image ${l52}
        .editright.1.evolution2.buttonbar.3 configure -image ${l53}
        .editright.1.evolution2.buttonbar.4 configure -image ${b55}
        .editright.1.evolution2.buttonbar.5 configure -image ${l55}
        set evolution {5}
        if { ${evol_update} == {true} } {
          set evol_date "${today_month}/${today_year}"
          .editright.1.evolution1 configure -text "${evol_date} "
        } else {
          set evol_update {true}
        }
      }
    }
    xbutton .editright.1.evolution2.buttonbar.5 -image ${l55} -anchor nw -width 21 -height 14 -relief flat -borderwidth 0 -highlightthickness 0 -command {
      if { [ .editright.1.evolution2.buttonbar.5 cget -image ] == ${b52} } {
        .editright.1.evolution2.buttonbar.5 configure -image ${l55}
        set evolution {}
        set evol_date {}
        .editright.1.evolution1 configure -text "[::msgcat::mc {Evolution}] "
      } else {
        .editright.1.evolution2.buttonbar.1 configure -image ${l51}
        .editright.1.evolution2.buttonbar.2 configure -image ${l52}
        .editright.1.evolution2.buttonbar.3 configure -image ${l53}
        .editright.1.evolution2.buttonbar.4 configure -image ${l54}
        .editright.1.evolution2.buttonbar.5 configure -image ${b52}
        set evolution {3}
        if { ${evol_update} == {true} } {
          set evol_date "${today_month}/${today_year}"
          .editright.1.evolution1 configure -text "${evol_date} "
        } else {
          set evol_update {true}
        }
      }
    }
    pack .editright.1.evolution2.buttonbar.1 .editright.1.evolution2.buttonbar.2 .editright.1.evolution2.buttonbar.3 .editright.1.evolution2.buttonbar.4 .editright.1.evolution2.buttonbar.5 -side left
  label .editright.1.evolution2.text2 -text [::msgcat::mc {matured}] -width ${ratewidth_b} -anchor w
  menubutton .editright.1.evolution2.help -image ${helpbutton} -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -menu .editright.1.evolution2.help.menu
  set evolutionmenu [ menu .editright.1.evolution2.help.menu -tearoff 0 ]
  ${evolutionmenu} add command -label [::msgcat::mc {unseasoned}] -command { if { [ .editright.1.evolution2.buttonbar.1 cget -image ] != ${b51} } { xbutton .editright.1.evolution2.buttonbar.1 invoke } }
  ${evolutionmenu} add command -label [::msgcat::mc {young}]      -command { if { [ .editright.1.evolution2.buttonbar.2 cget -image ] != ${b52} } { xbutton .editright.1.evolution2.buttonbar.2 invoke } }
  ${evolutionmenu} add command -label [::msgcat::mc {seasoned}]   -command { if { [ .editright.1.evolution2.buttonbar.3 cget -image ] != ${b53} } { xbutton .editright.1.evolution2.buttonbar.3 invoke } }
  ${evolutionmenu} add command -label [::msgcat::mc {developed}]  -command { if { [ .editright.1.evolution2.buttonbar.4 cget -image ] != ${b54} } { xbutton .editright.1.evolution2.buttonbar.4 invoke } }
  ${evolutionmenu} add command -label [::msgcat::mc {matured}]    -command { if { [ .editright.1.evolution2.buttonbar.5 cget -image ] != ${b55} } { xbutton .editright.1.evolution2.buttonbar.5 invoke } }
  pack .editright.1.evolution2.text1 .editright.1.evolution2.buttonbar .editright.1.evolution2.text2 .editright.1.evolution2.help -side left
grid .editright.1.evolution1 .editright.1.evolution2 -sticky w
if { ${evolution} == {1} } { xbutton .editright.1.evolution2.buttonbar.1 invoke }
if { ${evolution} == {2} } { xbutton .editright.1.evolution2.buttonbar.3 invoke }
if { ${evolution} == {3} } { xbutton .editright.1.evolution2.buttonbar.5 invoke }
if { ${evolution} == {4} } { xbutton .editright.1.evolution2.buttonbar.2 invoke }
if { ${evolution} == {5} } { xbutton .editright.1.evolution2.buttonbar.4 invoke }
set evol_update {true}
if { ${tooltips} == {true} } {
  ::ttips .editright.1.evolution2.buttonbar.1 -text [::msgcat::mc {unseasoned}] -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.evolution2.buttonbar.2 -text [::msgcat::mc {young}]      -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.evolution2.buttonbar.3 -text [::msgcat::mc {seasoned}]   -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.evolution2.buttonbar.4 -text [::msgcat::mc {developed}]  -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
  ::ttips .editright.1.evolution2.buttonbar.5 -text [::msgcat::mc {matured}]    -font ${smallfont} -background ${selectbackground} -foreground ${selectforeground}
}
bind .editright.1.evolution2.buttonbar.1 <Button-3> {+ tk_popup ${evolutionmenu} %X %Y }
bind .editright.1.evolution2.buttonbar.2 <Button-3> {+ tk_popup ${evolutionmenu} %X %Y }
bind .editright.1.evolution2.buttonbar.3 <Button-3> {+ tk_popup ${evolutionmenu} %X %Y }
bind .editright.1.evolution2.buttonbar.4 <Button-3> {+ tk_popup ${evolutionmenu} %X %Y }
bind .editright.1.evolution2.buttonbar.5 <Button-3> {+ tk_popup ${evolutionmenu} %X %Y }


# widgets from here are shown everytime
label  .editright.1.history1 -text "[::msgcat::mc {History}] " -font ${titlefont} -anchor nw
frame  .editright.1.history2
  text .editright.1.history2.message -width 40 -height 3 -wrap word -relief flat -yscrollcommand ".editright.1.history2.scroll set"
  ::conmen .editright.1.history2.message
	if { $::bTtk } {
  	ttk::scrollbar .editright.1.history2.scroll -command ".editright.1.history2.message yview"
	} else {
		scrollbar .editright.1.history2.scroll -command ".editright.1.history2.message yview"
	}
  .editright.1.history2.message insert 1.0 ${drunk_history}
pack .editright.1.history2.message -side left  -fill both -expand true
pack .editright.1.history2.scroll  -side right -fill y
grid .editright.1.history1 .editright.1.history2 -sticky news

set nextlastwidth [ string length [::msgcat::mc {This Year}] ]
if { [ string length [::msgcat::mc {Ready}] ] > ${nextlastwidth} } { set nextlastwidth [ string length [::msgcat::mc {Ready}] ] }

label .editright.1.next_bottle1 -text "[::msgcat::mc {Next Bottle}] " -font ${titlefont}
frame .editright.1.next_bottle2
  if { ${next_bottle} != {} } {
    set next_bottle_month [ string range ${next_bottle} 5 6 ]
    set next_bottle_year [ string range ${next_bottle} 0 3 ]
  } else {
    set next_bottle_month {}
    set next_bottle_year {}
  }
  set next_bottle_month2 ${next_bottle_month}
  set next_bottle_year2 ${next_bottle_year}
  spinbox .editright.1.next_bottle2.today_month -from 1 -to 12 -textvariable next_bottle_month -width 2 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 3 } }
  bind .editright.1.next_bottle2.today_month <Button-3> {
    set monthwidget %W
    tk_popup ${setmonthmenu} %X %Y
  }
  label .editright.1.next_bottle2.fill2 -text {-}
  spinbox .editright.1.next_bottle2.today_year -from ${today_year} -to 9999 -textvariable next_bottle_year -width 4 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 5 } }
  bind .editright.1.next_bottle2.today_year <Button-3> {
    set yearwidget %W
    tk_popup ${setyearmenu} %X %Y
  }
  .editright.1.next_bottle2.today_month set ${next_bottle_month2}
  .editright.1.next_bottle2.today_year  set ${next_bottle_year2}
  button .editright.1.next_bottle2.today -text " [::msgcat::mc {Ready}] " -relief raised -borderwidth 1 -padx 1 -pady 1 -width ${nextlastwidth} -command {
    .editright.1.next_bottle2.today_month set ${today_month}
    .editright.1.next_bottle2.today_year  set ${today_year}
  }
pack .editright.1.next_bottle2.today_month -side left
pack .editright.1.next_bottle2.fill2       -side left
pack .editright.1.next_bottle2.today_year  -side left
pack .editright.1.next_bottle2.today       -side left -padx 4
grid .editright.1.next_bottle1 .editright.1.next_bottle2 -sticky w

label .editright.1.last_bottle1 -text "[::msgcat::mc {Drink Up}] " -font ${titlefont}
frame .editright.1.last_bottle2
  spinbox .editright.1.last_bottle2.blank1 -width 2 -background ${lightcolor} -state disabled
  label .editright.1.last_bottle2.blank2 -text {-} -state disabled
  set last_bottle2 ${last_bottle}
  spinbox .editright.1.last_bottle2.drinkupbox -from ${today_year} -to 9999 -textvariable last_bottle -width 4 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 5 } }
  bind .editright.1.last_bottle2.drinkupbox <Button-3> {
    set yearwidget %W
    tk_popup ${setyearmenu} %X %Y
  }
  .editright.1.last_bottle2.drinkupbox set ${last_bottle2}
  button .editright.1.last_bottle2.drinkupbutton -text [::msgcat::mc {This Year}] -relief raised -borderwidth 1 -padx 1 -pady 1 -width ${nextlastwidth} -command {
    .editright.1.last_bottle2.drinkupbox set ${today_year}
    if { ${next_bottle_year} == {} || ${next_bottle_year} > ${today_year} } {
      .editright.1.next_bottle2.today_month set ${today_month}
      .editright.1.next_bottle2.today_year  set ${today_year}
    }
  }
  set timelimitwidth [ string length [::msgcat::mc {Limiting Factor}] ]
  if { [ string length [::msgcat::mc {producers recommendation}] ] > ${timelimitwidth} } { set timelimitwidth [ string length [::msgcat::mc {producers recommendation}] ] }
  if { [ string length [::msgcat::mc {heard / read}] ]             > ${timelimitwidth} } { set timelimitwidth [ string length [::msgcat::mc {heard / read}] ] }
  if { [ string length [::msgcat::mc {guessing}] ]                 > ${timelimitwidth} } { set timelimitwidth [ string length [::msgcat::mc {guessing}] ] }
  if { [ string length [::msgcat::mc {Stopper}] ]                  > ${timelimitwidth} } { set timelimitwidth [ string length [::msgcat::mc {Stopper}] ] }
  if { [ string length [::msgcat::mc {potential}] ]                > ${timelimitwidth} } { set timelimitwidth [ string length [::msgcat::mc {potential}] ] }
  menubutton .editright.1.last_bottle2.timelimit -text [::msgcat::mc {Limiting Factor}] -menu .editright.1.last_bottle2.timelimit.menu -relief sunken -borderwidth 2 -background ${lightcolor} -padx 1 -pady 1 -width ${timelimitwidth} -anchor w
  set timelimitmenu [ menu .editright.1.last_bottle2.timelimit.menu -tearoff 0 ]
  ${timelimitmenu} add command -label [::msgcat::mc {heard / read}] -command {
    set timelimitfactor {0}
    .editright.1.last_bottle2.timelimit configure -text [::msgcat::mc {heard / read}]
  }
  ${timelimitmenu} add command -label [::msgcat::mc {guessing}] -command {
    set timelimitfactor {1}
    .editright.1.last_bottle2.timelimit configure -text [::msgcat::mc {guessing}]
  }
  ${timelimitmenu} add command -label [::msgcat::mc {potential}] -command {
    set timelimitfactor {2}
    .editright.1.last_bottle2.timelimit configure -text [::msgcat::mc {potential}]
  }
  ${timelimitmenu} add command -label [::msgcat::mc {Stopper}] -command {
    set timelimitfactor {3}
    .editright.1.last_bottle2.timelimit configure -text [::msgcat::mc {Stopper}]
  }
  ${timelimitmenu} add command -label [::msgcat::mc {producers recommendation}] -command {
    set timelimitfactor {4}
    .editright.1.last_bottle2.timelimit configure -text [::msgcat::mc {producers recommendation}]
  }
  ${timelimitmenu} add separator
  ${timelimitmenu} add command -label [::msgcat::mc {unset}] -command {
    set timelimitfactor {}
    .editright.1.last_bottle2.timelimit configure -text [::msgcat::mc {Limiting Factor}]
  }
  if { ${timelimitfactor} != {} } {
    ${timelimitmenu} invoke ${timelimitfactor}
  }
pack .editright.1.last_bottle2.blank1        -side left
pack .editright.1.last_bottle2.blank2        -side left
pack .editright.1.last_bottle2.drinkupbox    -side left
pack .editright.1.last_bottle2.drinkupbutton -side left -padx 4
pack .editright.1.last_bottle2.timelimit     -side left -fill x -expand true
grid .editright.1.last_bottle1 .editright.1.last_bottle2 -sticky w

pack .editright.0     -side top -padx 0 -pady 0 -fill x
pack .editright.blank -side top -padx 0 -pady 0 -fill x
pack .editright.1     -side top -padx 0 -pady 0 -fill both -expand true


frame .menu
button .menu.save -image ${savebutton}  -text [::msgcat::mc {Save}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -command { save open }
button .menu.exit -image ${closebutton} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -command { exit }
button .menu.saex -image ${okaybutton}  -text [::msgcat::mc {Save & Close}] -font ${titlefont} -compound left -pady 3 -padx 10 -relief raised -borderwidth 2 -command { save close }
pack .menu.save .menu.exit .menu.saex -side left -expand true -fill x


# blanks for spacing
frame .editright2 -width 8
frame .blankbottom -height 4


# pack all together
grid .editleft -sticky ewsn -padx 8 -pady 4 -row 0 -column 0
grid .editright -sticky ewsn -padx 0 -pady 4 -row 0 -column 1
grid .editright2 -sticky ewsn -padx 0 -pady 0 -row 0 -column 2
grid .menu -sticky ewsn -padx 8 -pady 0 -columnspan 3
grid .blankbottom -sticky ewsn -padx 8 -pady 0 -columnspan 3


# resizing stuff
grid columnconfigure .editleft.0  0 -weight 0
grid columnconfigure .editleft.0  1 -weight 1
grid columnconfigure .editleft.1  0 -weight 0
grid columnconfigure .editleft.1  1 -weight 1
grid columnconfigure .editright.0 1 -weight 1
grid rowconfigure    .editright.1 17 -weight 1
grid columnconfigure .editright.1 0 -weight 0
grid columnconfigure .editright.1 1 -weight 1
grid rowconfigure    .            0 -weight 1
grid columnconfigure .            0 -weight 1
grid columnconfigure .            1 -weight 1


# update position if necessary
if { ${centerx} == {true} || ${centery} == {true} } {
  tkwait visibility .
  if { ${centerx} == {true} } { set ulcx [ expr "( [ winfo screenwidth  . ] - [ winfo width  . ] ) / 2" ] }
  if { ${centery} == {true} } { set ulcy [ expr "( [ winfo screenheight . ] - [ winfo height . ] ) / 2" ] }
  wm geometry . +${ulcx}+${ulcy}
}


# get country and macro list
set readchannel [ open [ file join ${prog_dir} ext regions ] r ]
foreach entry [ read -nonewline ${readchannel} ] {
  lappend list_complete ${entry}
}
close ${readchannel}
set number {0}
while { ${number} <= [ llength ${list_complete} ] } {
  set field1 [ lindex ${list_complete} ${number} ]
  set field2 [ lindex ${list_complete} [ expr "${number} + 1" ] ]
  if { [ string index ${field1} 0 ] == { } } {
    set number [ expr "${number} + 4" ]
    continue
  }
  if { ${field1} != {} && ${field2} != {} } {
    set field {}
    append field ${field2} ${field1}
    lappend list_country ${field}
  }
  set number [ expr "${number} + 4" ]
}
set list_country2 {}
foreach entry ${list_country} {
  if { [ regexp -nocase [list ${entry}] ${list_country2} ] == {0} } {
    lappend list_country2 ${entry}
  }
}
set list_country [ string trimright ${list_country2} ]


# keyboard bindings
bind . <KeyPress-F2>   { .menu.save invoke }
bind . <KeyPress-F8>   { .menu.exit invoke }
bind . <Control-Key-q> { .menu.exit invoke }
bind . <KeyPress-F10>  { .menu.saex invoke }


# traceings
trace variable price w "update_litreprice ;#"

proc trace_barrel_months {} {
  global barrel_months
  if { ${barrel_months} == {1} } {
    .editleft.1.barrel2.text2 configure -text [::msgcat::mc {month}]
  } else {
    .editleft.1.barrel2.text2 configure -text [::msgcat::mc {months}]
  }
}
trace variable barrel_months w "trace_barrel_months ;#"

proc trace_size {} {
  global size
  if { ${size} > {0} && ${size} != "0.75" } {
    set sizemulti [ format "%.1f" [ expr "${size} / 0.75" ] ]
    .editleft.1.size2.text2 configure -text "(${sizemulti}x 0.75 [::msgcat::mc {Litre}])"
  } else {
    .editleft.1.size2.text2 configure -text {}
  }
}
trace variable size  w "update_litreprice ; trace_size ;#"

proc trace_new_amount {} {
  global new_amount
  if {  [ winfo exists .input.frame1.amount2.text ] } {
    if { ${new_amount} != {1} } {
      .input.frame1.amount2.text configure -text [::msgcat::mc {new bottles}]
    } else {
      .input.frame1.amount2.text configure -text [::msgcat::mc {new bottle}]
    }
  }
}
trace variable new_amount w "trace_new_amount ;#"

proc trace_amount {} {
  global amount
  if { ${amount} == {0} } {
    .editright.0.amount2.out configure -state disable
  } else {
    .editright.0.amount2.out configure -state normal
  }
  if { ${amount} != {1} } {
    .editright.0.amount2.text configure -text [::msgcat::mc {Bottles}]
  } else {
    .editright.0.amount2.text configure -text [::msgcat::mc {Bottle}]
  }
}
trace variable amount w "trace_amount ;#"

proc trace_bought_sum {} {
  global bought_sum
  if { ${bought_sum} != {1} } {
    .editright.0.bought2.text2 configure -text [::msgcat::mc {bottles so far to history}]
  } else {
    .editright.0.bought2.text2 configure -text [::msgcat::mc {bottle so far to history}]
  }
}
trace variable bought_sum w "trace_bought_sum ;#"

proc trace_consume_amount {} {
  global consume_amount
  if {  [ winfo exists .output.frame1.amount2.text ] } {
    if { ${consume_amount} != {1} } {
      .output.frame1.amount2.text configure -text [::msgcat::mc {bottles}]
    } else {
      .output.frame1.amount2.text configure -text [::msgcat::mc {bottle}]
    }
  }
}
trace variable consume_amount w "trace_consume_amount ;#"

proc trace_land {} {
  global land list_country
  if { [ string length ${land} ] != {2} } {
    .editleft.0.land2.2 configure -text {}
  } else {
    foreach entry ${list_country} {
      if { [ lsearch -exact [ string range ${entry} 0 1 ] ${land} ] != {-1} } {
       .editleft.0.land2.2 configure -text [ string range ${entry} 2 end ]
      }
    }
  }
}
trace variable land w "trace_land ;#"

proc trace_color {} {
  global color bitterness l5
  if { ${color} != {Red} } {
    .editright.1.bitterness1             configure -state disabled
    .editright.1.bitterness2.text1       configure -state disabled
    .editright.1.bitterness2.buttonbar.1 configure -state disabled -image ${l5}
    .editright.1.bitterness2.buttonbar.2 configure -state disabled -image ${l5}
    .editright.1.bitterness2.buttonbar.3 configure -state disabled -image ${l5}
    .editright.1.bitterness2.buttonbar.4 configure -state disabled -image ${l5}
    .editright.1.bitterness2.buttonbar.5 configure -state disabled -image ${l5}
    .editright.1.bitterness2.text2       configure -state disabled
    .editright.1.bitterness2.help        configure -state disabled
  } else {
    .editright.1.bitterness1             configure -state normal
    .editright.1.bitterness2.text1       configure -state normal
    .editright.1.bitterness2.buttonbar.1 configure -state normal
    .editright.1.bitterness2.buttonbar.2 configure -state normal
    .editright.1.bitterness2.buttonbar.3 configure -state normal
    .editright.1.bitterness2.buttonbar.4 configure -state normal
    .editright.1.bitterness2.buttonbar.5 configure -state normal
    .editright.1.bitterness2.text2       configure -state normal
    .editright.1.bitterness2.help        configure -state normal
    if { ${bitterness} == {1} } { if { [ .editright.1.bitterness2.buttonbar.1 cget -image ] == ${l5} } { xbutton .editright.1.bitterness2.buttonbar.1 invoke } }
    if { ${bitterness} == {2} } { if { [ .editright.1.bitterness2.buttonbar.3 cget -image ] == ${l5} } { xbutton .editright.1.bitterness2.buttonbar.3 invoke } }
    if { ${bitterness} == {3} } { if { [ .editright.1.bitterness2.buttonbar.5 cget -image ] == ${l5} } { xbutton .editright.1.bitterness2.buttonbar.5 invoke } }
    if { ${bitterness} == {4} } { if { [ .editright.1.bitterness2.buttonbar.2 cget -image ] == ${l5} } { xbutton .editright.1.bitterness2.buttonbar.2 invoke } }
    if { ${bitterness} == {5} } { if { [ .editright.1.bitterness2.buttonbar.4 cget -image ] == ${l5} } { xbutton .editright.1.bitterness2.buttonbar.4 invoke } }
  }
}
trace variable color w "trace_color ;#"

proc trace_classification {} {
  global classification barrel barrel_months land region village color winename
  if { ${land} == {ES} } {
    if { ${classification} == {DO / Roble} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
    } elseif { ${classification} == {DOC / Roble} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
    } elseif { ${classification} == {DO / Crianza} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
      if { ${region} == {Rioja} || ${village} == {Ribera del Duero} } {
        if { ${barrel_months} == {} || ${barrel_months} < {12} } { set barrel_months {12} }
      } else {
        if { ${barrel_months} == {} || ${barrel_months} < {6} } { set barrel_months {6} }
      }
    } elseif { ${classification} == {DOC / Crianza} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
      if { ${region} == {Rioja} || ${village} == {Ribera del Duero} } {
        if { ${barrel_months} == {} || ${barrel_months} < {12} } { set barrel_months {12} }
      } else {
        if { ${barrel_months} == {} || ${barrel_months} < {6} } { set barrel_months {6} }
      }
    } elseif { ${classification} == {DO / Reserva} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
      if { ${color} == {Red} } {
        if { ${barrel_months} == {} || ${barrel_months} < {12} } { set barrel_months {12} }
      } else {
        if { ${barrel_months} == {} || ${barrel_months} < {6} } { set barrel_months {6} }
      }
    } elseif { ${classification} == {DOC / Reserva} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
      if { ${color} == {Red} } {
        if { ${barrel_months} == {} || ${barrel_months} < {12} } { set barrel_months {12} }
      } else {
        if { ${barrel_months} == {} || ${barrel_months} < {6} } { set barrel_months {6} }
      }
    } elseif { ${classification} == {DO / Gran Reserva} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
      if { ${color} == {Red} } {
        if { ${barrel_months} == {} || ${barrel_months} < {24} } { set barrel_months {24} }
      } elseif { ${color} == {White} } {
        if { ${barrel_months} == {} || ${barrel_months} < {6} } { set barrel_months {6} }
      }
    } elseif { ${classification} == {DOC / Gran Reserva} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
      if { ${color} == {Red} } {
        if { ${barrel_months} == {} || ${barrel_months} < {24} } { set barrel_months {24} }
      } elseif { ${color} == {White} } {
        if { ${barrel_months} == {} || ${barrel_months} < {6} } { set barrel_months {6} }
      }
    }
  } elseif { ${land} == {IT} } {
    if { ${classification} == {DOC / Riserva} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
    } elseif { ${classification} == {DOCG / Riserva} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
    }
    # hmpf - here are wine names relevant, too ...
    if { ${winename} == {Brunello di Montalcino} || ${winename} == {Brunello Di Montalcino} || ${winename} == {Brunello di Montalcino Riserva} || ${winename} == {Brunello Di Montalcino Riserva} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
      if { ${barrel_months} == {} || ${barrel_months} < {30} } { set barrel_months {30} }
    } elseif { ${winename} == {Rosso di Montalcino} || ${winename} == {Rosso Di Montalcino} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
      if { ${barrel_months} == {} || ${barrel_months} < {12} } { set barrel_months {12} }
    } elseif { ${winename} == {Vino Nobile di Montepulciano} || ${winename} == {Vino Nobile Di Montepulciano} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
      if { ${barrel_months} == {} || ${barrel_months} < {12} } { set barrel_months {12} }
    } elseif { ${winename} == {Vino Nobile di Montepulciano Riserva} || ${winename} == {Vino Nobile Di Montepulciano Riserva} } {
      if { ${barrel} == {partial} || ${barrel} == {false} || ${barrel} == {} } { barrel_true }
      if { ${barrel_months} == {} || ${barrel_months} < {24} } { set barrel_months {24} }
    }
  }
}
trace variable classification w "trace_classification ;#"

trace variable air w "air_update ;#"


# do some initial things
if { ${land} != {} } { trace_land }
if { ${tint} != {} } { colorchange ${tint} }
points
trace_color
trace_size
manualpointscalc general
# if blank focus first entry
if { ${domain} == {} } { focus .editleft.0.domain2 }
# select one viewbutton
if { ${viewmode} == {buttons} } {
  .editright.1.labeltext.switch.1 configure -background ${lightcolor}
} elseif { ${viewmode} == {text} } {
  .editright.1.labeltext.switch.3 configure -background ${lightcolor}
   switchmode
} else {
  .editright.1.labeltext.switch.2 configure -background ${lightcolor}
   switchmode
}
