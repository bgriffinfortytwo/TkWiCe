# outsourced from editwine.tcl


# startup only if window not present
if { [ winfo exists .output ] } {
  raise .output .

# okay
} else {

  # window stuff
  set titlename [::msgcat::mc {Outgoing Bottles}]
  toplevel     .output
  wm title     .output ${titlename}
  wm geometry  .output +[ winfo pointerx . ]+[ winfo pointery . ]
  focus        .output
  wm transient .output .
  # .output configure -relief raised -borderwidth 3

  # build gui
	if { ${bTtk} } {
  	ttk::labelframe .output.frame1 -text ${titlename}
	} else {
		labelframe .output.frame1 -text ${titlename} -padx 2 -pady 2
	}

    set note {}
    if { ${domain} == {}   } { set note "${note}\n  \u2022 [::msgcat::mc {Winery}]" }
    if { ${land} == {}     } { set note "${note}\n  \u2022 [::msgcat::mc {Country}]" }
    if { ${winename} == {} } { set note "${note}\n  \u2022 [::msgcat::mc {Wine Name}]" }
    if { ${vineyard} == {} } { set note "${note}\n  \u2022 [::msgcat::mc {Vineyard}]" }
    if { ${year} == {}     } { set note "${note}\n  \u2022 [::msgcat::mc {Vintage}]" }
    if { ${price} == {}    } { set note "${note}\n  \u2022 [::msgcat::mc {Price}]" }
    if { ${note} != {} } {
      label .output.frame1.info1 -text "[::msgcat::mc {Note}] " -font ${titlefont} -anchor w
      label .output.frame1.info2 -text "[::msgcat::mc "You should have finished filling in:"]\n${note}\n\n[::msgcat::mc "If you're able to complete this do it,"]\n[::msgcat::mc "and press \u00bbAbort\u00ab now."]\n" -justify left -anchor w
      grid  .output.frame1.info1 .output.frame1.info2 -sticky nw
    }

    label .output.frame1.date1 -text "[::msgcat::mc {Date}] " -font ${titlefont} -anchor w
    frame .output.frame1.date2
      spinbox .output.frame1.date2.today_day -from 1 -to 31 -textvariable consume_day -width 2 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 3 } }
      bind .output.frame1.date2.today_day <Button-3> {
        set daywidget %W
        tk_popup ${setdaymenu} %X %Y
      }
      if { ${dateformat} == {dm} } {
        label .output.frame1.date2.fill1 -text {-}
      } else {
        label .output.frame1.date2.fill1 -text {/}
      }
      spinbox .output.frame1.date2.today_month -from 1 -to 12 -textvariable consume_month -width 2 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 3 } }
      bind .output.frame1.date2.today_month <Button-3> {
        set monthwidget %W
        tk_popup ${setmonthmenu} %X %Y
      }
      if { ${dateformat} == {dm} } {
        label .output.frame1.date2.fill2 -text {-}
      } else {
        label .output.frame1.date2.fill2 -text {/}
      }
      spinbox .output.frame1.date2.today_year -from [ expr "${today_year} - 1" ] -to 9999 -textvariable consume_year -width 4 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 5 } }
      bind .output.frame1.date2.today_year <Button-3> {
        set yearwidget %W
        tk_popup ${setyearmenu} %X %Y
      }
      .output.frame1.date2.today_day   set ${today_day}
      .output.frame1.date2.today_month set ${today_month}
      .output.frame1.date2.today_year  set ${today_year}
    if { ${dateformat} == {dm} } {
      pack .output.frame1.date2.today_day .output.frame1.date2.fill1 .output.frame1.date2.today_month .output.frame1.date2.fill2 .output.frame1.date2.today_year -side left
    } else {
      pack .output.frame1.date2.today_month .output.frame1.date2.fill1 .output.frame1.date2.today_day .output.frame1.date2.fill2 .output.frame1.date2.today_year -side left
    }
    grid .output.frame1.date1 .output.frame1.date2 -sticky w

    label .output.frame1.amount1 -text "[::msgcat::mc {Quantity}] " -font ${titlefont} -anchor w
    frame .output.frame1.amount2
      set consume_amount {1}
      spinbox .output.frame1.amount2.box -textvariable consume_amount -from 1 -to ${amount} -width 3 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 4 } }
      .output.frame1.amount2.box set ${consume_amount}
      label .output.frame1.amount2.text -text [::msgcat::mc {bottle}]
    pack .output.frame1.amount2.box .output.frame1.amount2.text -side left
    grid .output.frame1.amount1 .output.frame1.amount2 -sticky w

    label .output.frame1.note1 -text "[::msgcat::mc {Note}] " -font ${titlefont} -anchor w
    set consume_notes {}
    entry .output.frame1.note2 -textvariable consume_notes -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
    grid .output.frame1.note1 .output.frame1.note2 -sticky w
    focus .output.frame1.note2
    bind .output.frame1.note2 <Return> { .output.frame2.ok invoke }
    ::conmen .output.frame1.note2

    label .output.frame1.update_g_history1 -text "[::msgcat::mc {Effects}] " -font ${titlefont} -anchor w
    set update_global_cons_history {true}
    checkbutton .output.frame1.update_g_history2 -text [::msgcat::mc {update global history}] -variable update_global_cons_history -offvalue "false" -onvalue "true"
    .output.frame1.update_g_history2 select
    grid .output.frame1.update_g_history1 .output.frame1.update_g_history2 -sticky w

    label .output.frame1.update_w_history1 -text { } -anchor w
    set update_history {true}
    checkbutton .output.frame1.update_w_history2 -text [::msgcat::mc {update wine history}] -variable update_cons_history -offvalue "false" -onvalue "true"
    .output.frame1.update_w_history2 select
    grid .output.frame1.update_w_history1 .output.frame1.update_w_history2 -sticky w

    label .output.frame1.stock1 -text { } -anchor w
    set update_stock {true}
    checkbutton .output.frame1.stock2 -text [::msgcat::mc {subtract from stock}] -variable update_cons_stock -offvalue "false" -onvalue "true" -anchor w
    .output.frame1.stock2 select
    grid .output.frame1.stock1 .output.frame1.stock2 -sticky w

  frame .output.frame2
    button .output.frame2.ok -image ${okaybutton} -text [::msgcat::mc {Take Over}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command {
      if { ${consume_amount} > {0} } {
        if { ${update_cons_stock} == {true} && ${amount} < ${consume_amount} } {
          set amount {0}
          .editright.0.amount2.box set ${amount}
          set infotitle [::msgcat::mc {Note}]
          set infotext  [::msgcat::mc {You've drunk more bottles than available ...}]
          set infotype  {info}
          source [ file join ${prog_dir} tcl info.tcl ]
        }
        if { ${update_cons_stock} == {true} && ${amount} >= ${consume_amount} } {
          set amount [ expr "${amount} - ${consume_amount}" ]
          .editright.0.amount2.box set ${amount}
        }
        set consume {}
        if { [ string length ${consume_day} ] == {1} } {
          set consume_day   [ format "%2.2d" ${consume_day} ]
        }
        if { [ string length ${consume_month} ] == {1} } {
          set consume_month [ format "%2.2d" ${consume_month} ]
        }
        if { [ string length ${consume_year} ] == {1} || [ string length ${consume_year} ] == {2} || [ string length ${consume_year} ] == {3} } {
          set consume_year  [ format "%4.4d" ${consume_year} ]
        }
        if { ${consume_year} == {} } {
          if { ${dateformat} == {dm} } {
            set consume {--.--.----}
          } else {
            set consume {--/--/----}
          }
        } else {
          if { ${consume_month} == {} } { set consume_month {--} }
          if { ${consume_day} == {} } { set consume_day {--} }
          if { ${dateformat} == {dm} } {
            set consume "${consume_day}.${consume_month}.${consume_year}"
          } else {
            set consume "${consume_month}/${consume_day}/${consume_year}"
          }
        }
        # set up last_drunk var
        if { ${consume_year} != {----} && ${consume_month} != {--} } {
          # okay, date is guilty
          set last_drunk_new "${consume_year}-${consume_month}"
          if { ! [ info exists last_drunk ] } {
            # introduce new var
            set last_drunk ${last_drunk_new}
          } elseif { ${last_drunk_new} > ${last_drunk} } {
            # new date is newer than old date
            set last_drunk ${last_drunk_new}
          }
        }
        # global history.out
        if { $update_global_cons_history == {true} } {
          set winename_out ${domain}
          if { ${winename} != {} } { set winename_out "${winename_out} - ${winename}" }
          if { ${domain} == {}   } { set winename_out [ string range ${winename_out} 3 end ] }
          if { ${vineyard} != {} } { set winename_out "${winename_out} (${vineyard})" }
          if { ${year} != {}     } { set winename_out "${winename_out}, ${year}"      }
          if { [ .editleft.0.land2.2 cget -text ] == {} } {
            set consume_land ${land}
          } else {
            set consume_land [ .editleft.0.land2.2 cget -text ]
          }
          if { ${price} > 0 && ${price} != {} } {
            set consume_price [ expr "${price} * ${consume_amount}" ]
            set consume_price [ format "%.2f" ${consume_price} ]
          } else {
            set consume_price {}
          }
          set to_history_out {}
          lappend to_history_out ${consume_year} ${consume_month} ${consume_day} ${winename_out} ${consume_land} ${consume_amount} ${consume_price} ${consume_notes}
          set initchannel [ open [ file join ${datadir} history.out ] a ]
          puts ${initchannel} ${to_history_out}
          close ${initchannel}
        }
        # else
        if { ${update_cons_history} == {true} } {
          if { ${consume_notes} != {} } {
            if { ${consume_amount} == {1} } {
              .editright.1.history2.message insert 1.0 "${consume} - ${consume_amount} [::msgcat::mc {Bottle}] - ${consume_notes}\n"
            } else {
              .editright.1.history2.message insert 1.0 "${consume} - ${consume_amount} [::msgcat::mc {Bottles}] - ${consume_notes}\n"
            }
          } else {
            if { ${consume_amount} == {1} } {
              .editright.1.history2.message insert 1.0 "${consume} - ${consume_amount} [::msgcat::mc {Bottle}]\n"
            } else {
              .editright.1.history2.message insert 1.0 "${consume} - ${consume_amount} [::msgcat::mc {Bottles}]\n"
            }
          }
        }
      }
      destroy .output
    }
    button .output.frame2.abort -image ${closebutton} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command {
      destroy .output
    }
  pack .output.frame2.ok .output.frame2.abort -side left -fill x -expand true

  pack .output.frame1 .output.frame2 -side top -padx 10 -pady 10 -fill both

  bind .output <KeyPress-Escape> { .output.frame2.abort invoke }
  bind .output <Control-Key-q>   { .output.frame2.abort invoke }

  # window placement - mousepointer in the middle ...
  tkwait visibility .output
  set xposition_info [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .output ] / 2" ]" ]
  set yposition_info [ expr "[ winfo pointery . ] - [ expr "[ winfo height .output ] / 2" ]" ]
  if { ${xposition_info} < {0} } { set xposition_info {0} }
  if { ${yposition_info} < {0} } { set yposition_info {0} }
  if { [ expr "[ winfo width  .output ] + ${xposition_info}" ] > [ winfo screenwidth  . ] } { set xposition_info [ expr "[ winfo screenwidth  . ] - [ winfo width  .output ]" ] }
  if { [ expr "[ winfo height .output ] + ${yposition_info}" ] > [ winfo screenheight . ] } { set yposition_info [ expr "[ winfo screenheight . ] - [ winfo height .output ]" ] }
  wm geometry .output +${xposition_info}+${yposition_info}
}
