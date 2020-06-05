# outsourced from editwine.tcl


# startup only if window not present
if { [ winfo exists .input ] } {
  raise .input .

# okay
} else {
  # window stuff
  set titlename [::msgcat::mc {New Delivery}]
  toplevel     .input
  wm title     .input ${titlename}
  wm geometry  .input +[ winfo pointerx . ]+[ winfo pointery . ]
  focus        .input
  wm transient .input .
  # .input configure -relief raised -borderwidth 3

  # build gui
	if { ${bTtk} } {
  	ttk::labelframe .input.frame1 -text ${titlename}
	} else {
		labelframe .input.frame1 -text ${titlename} -padx 2 -pady 2
	}

    set note {}
    if { ${domain} == {}   } { set note "${note}\n  \u2022 [::msgcat::mc {Winery}]" }
    if { ${land} == {}     } { set note "${note}\n  \u2022 [::msgcat::mc {Country}]" }
    if { ${winename} == {} } { set note "${note}\n  \u2022 [::msgcat::mc {Wine Name}]" }
    if { ${vineyard} == {} } { set note "${note}\n  \u2022 [::msgcat::mc {Vineyard}]" }
    if { ${year} == {}     } { set note "${note}\n  \u2022 [::msgcat::mc {Vintage}]" }
    if { ${price} == {}    } { set note "${note}\n  \u2022 [::msgcat::mc {Price}]" }
    if { ${note} != {} } {
      label .input.frame1.info1 -text "[::msgcat::mc {Note}] " -font ${titlefont} -anchor w
      label .input.frame1.info2 -text "[::msgcat::mc "You should have finished filling in:"]\n${note}\n\n[::msgcat::mc "If you're able to complete this do it,"]\n[::msgcat::mc "and press \u00bbAbort\u00ab now."]\n" -justify left -anchor w
      grid  .input.frame1.info1 .input.frame1.info2 -sticky nw
    }

    label .input.frame1.date1 -text "[::msgcat::mc {Date}] " -font ${titlefont} -anchor w
    frame .input.frame1.date2
      spinbox .input.frame1.date2.today_day -from 1 -to 31 -textvariable last_bought_day -width 2 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 3 } }
      bind .input.frame1.date2.today_day <Button-3> {
        set daywidget %W
        tk_popup ${setdaymenu} %X %Y
      }
      if { ${dateformat} == {dm} } {
        label .input.frame1.date2.fill1 -text {-}
      } else {
        label .input.frame1.date2.fill1 -text {/}
      }
      spinbox .input.frame1.date2.today_month -from 1 -to 12 -textvariable last_bought_month -width 2 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 3 } }
      bind .input.frame1.date2.today_month <Button-3> {
        set monthwidget %W
        tk_popup ${setmonthmenu} %X %Y
      }
      if { ${dateformat} == {dm} } {
        label .input.frame1.date2.fill2 -text {-}
      } else {
        label .input.frame1.date2.fill2 -text {/}
      }
      spinbox .input.frame1.date2.today_year -from [ expr "${today_year} - 1" ] -to 9999 -textvariable last_bought_year -width 4 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 5 } }
      bind .input.frame1.date2.today_year <Button-3> {
        set yearwidget %W
        tk_popup ${setyearmenu} %X %Y
      }
      .input.frame1.date2.today_day   set ${today_day}
      .input.frame1.date2.today_month set ${today_month}
      .input.frame1.date2.today_year  set ${today_year}
    if { ${dateformat} == {dm} } {
      pack .input.frame1.date2.today_day .input.frame1.date2.fill1 .input.frame1.date2.today_month .input.frame1.date2.fill2 .input.frame1.date2.today_year -side left
    } else {
      pack .input.frame1.date2.today_month .input.frame1.date2.fill1 .input.frame1.date2.today_day .input.frame1.date2.fill2 .input.frame1.date2.today_year -side left
    }
    grid .input.frame1.date1 .input.frame1.date2 -sticky w

    label .input.frame1.amount1 -text "[::msgcat::mc {Quantity}] " -font ${titlefont} -anchor w
    frame .input.frame1.amount2
      set new_amount {1}
      spinbox .input.frame1.amount2.box -textvariable new_amount -from 1 -to 999 -width 3 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is integer %P ] && [ string length %P ] < 4 } }
      .input.frame1.amount2.box set ${new_amount}
      label .input.frame1.amount2.text -text [::msgcat::mc {new bottle}]
    pack .input.frame1.amount2.box .input.frame1.amount2.text -side left
    grid .input.frame1.amount1 .input.frame1.amount2 -sticky w

    label .input.frame1.price1 -text "[::msgcat::mc {Price}] " -font ${titlefont}
    frame .input.frame1.price3
      entry .input.frame1.price3.price -textvariable new_price -width 7 -background ${lightcolor} -justify right -validate key -vcmd { expr { [ string is double %P ] && [ string length %P ] < 8 } }
      # comma to point translation
      bind .input.frame1.price3.price <KeyPress> {
        if { "%A" == {,} && ![ regexp {\.} ${new_price} ] } {
          append new_price {.}
          .input.frame1.price3.price icursor end
        }
      }
      label .input.frame1.price3.text -text ${currency}
    pack .input.frame1.price3.price .input.frame1.price3.text -side left
    grid .input.frame1.price1 .input.frame1.price3 -sticky w

    label .input.frame1.note1 -text "[::msgcat::mc {Note}] " -font ${titlefont} -anchor w
    set input_note {}
    frame .input.frame1.note2
      entry .input.frame1.note2.entry -textvariable input_note -width 30 -background ${lightcolor} -validate key -vcmd { checktext %W %v %i %S }
      button .input.frame1.note2.help -image ${helpbutton} -anchor nw -width 16 -height 16 -relief flat -borderwidth 0 -highlightthickness 0 -command { help_vintner input }
    pack .input.frame1.note2.entry -side left -fill x
    pack .input.frame1.note2.help  -side left -padx 6
    grid .input.frame1.note1 .input.frame1.note2 -sticky w
    focus .input.frame1.note2.entry
    bind .input.frame1.note2 <Return> { .input.frame2.ok invoke }
    ::conmen .input.frame1.note2.entry
    .input.frame1.note2.entry.conmen add separator
    .input.frame1.note2.entry.conmen add command -label "[::msgcat::mc {Dealer}]: [::msgcat::mc {choose}]" -command { help_vintner input }

    label .input.frame1.update_g_history1 -text "[::msgcat::mc {Effects}] " -font ${titlefont} -anchor w
    set update_global_history {true}
    checkbutton .input.frame1.update_g_history2 -text [::msgcat::mc {update global history}] -variable update_global_history -offvalue "false" -onvalue "true"
    .input.frame1.update_g_history2 select
    grid .input.frame1.update_g_history1 .input.frame1.update_g_history2 -sticky w

    label .input.frame1.update_w_history1 -text { } -anchor w
    set update_history {true}
    checkbutton .input.frame1.update_w_history2 -text [::msgcat::mc {update wine history}] -variable update_history -offvalue "false" -onvalue "true"
    .input.frame1.update_w_history2 select
    grid .input.frame1.update_w_history1 .input.frame1.update_w_history2 -sticky w

    label .input.frame1.update_historysum1 -text { } -anchor w
    set update_historysum {true}
    checkbutton .input.frame1.update_historysum2 -text [::msgcat::mc {update wine history counter}] -variable update_historysum -offvalue "false" -onvalue "true"
    .input.frame1.update_historysum2 select
    grid .input.frame1.update_historysum1 .input.frame1.update_historysum2 -sticky w

    label .input.frame1.stock1 -text { } -anchor w
    set update_stock {true}
    checkbutton .input.frame1.stock2 -text [::msgcat::mc {add to stock}] -variable update_stock -offvalue "false" -onvalue "true" -anchor w
    .input.frame1.stock2 select
    grid .input.frame1.stock1 .input.frame1.stock2 -sticky w

    label .input.frame1.averagepricecalc1 -text { } -anchor w
    set update_averagepricecalc {true}
    checkbutton .input.frame1.averagepricecalc2 -text [::msgcat::mc {calculate an average price}] -variable update_averagepricecalc -offvalue "false" -onvalue "true" -anchor w
    grid .input.frame1.averagepricecalc1 .input.frame1.averagepricecalc2 -sticky w

    label .input.frame1.maindealer1 -text { } -anchor w
    set update_maindealer {false}
    checkbutton .input.frame1.maindealer2 -text "\"[::msgcat::mc {Note}]\" = \"[::msgcat::mc {Dealer}] \#1\"" -variable update_maindealer -offvalue "false" -onvalue "true" -anchor w
    grid .input.frame1.maindealer1 .input.frame1.maindealer2 -sticky w

  frame .input.frame2
    button .input.frame2.ok -image ${okaybutton} -text [::msgcat::mc {Take Over}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command {
      if { ${new_amount} > {0} } {
        # do we have to change dealer number one
        if { ${update_maindealer} == {true} } { set dealer ${input_note} }
        # calculate an average price
        if { ${new_price} != {} && ${update_averagepricecalc} == {true} && ${bought_sum} > {0} && ${price} != {} } {
          set price [ format {%.2f} [ expr ( ${price} * ${bought_sum} + ${new_price} * ${new_amount} ) / ( ${bought_sum} + ${new_amount} ) ] ]
        } elseif { ${new_price} != {} && ${update_averagepricecalc} == {true} && ${bought_sum} == {0} && ${price} != {} } {
          set price [ format {%.2f} [ expr ( ${price} * ${amount} + ${new_price} * ${new_amount} ) / ( ${amount} + ${new_amount} ) ] ]
        } elseif { ${new_price} != {} && ${update_averagepricecalc} == {true} && ${price} == {} } {
          set price [ format {%.2f} ${new_price} ]
        }
        if { ${update_stock} == {true} } {
          set amount [ expr "${amount} + ${new_amount}" ]
          .editright.0.amount2.box set ${amount}
        }
        set last_bought {}
        if { [ string length ${last_bought_day} ] == {1} } {
          set last_bought_day   [ format "%2.2d" ${last_bought_day} ]
        }
        if { [ string length ${last_bought_month} ] == {1} } {
          set last_bought_month [ format "%2.2d" ${last_bought_month} ]
        }
        if { [ string length ${last_bought_year} ] == {1} || [ string length ${last_bought_year} ] == {2} || [ string length ${last_bought_year} ] == {3} } {
          set last_bought_year  [ format "%4.4d" ${last_bought_year} ]
        }
        if { ${last_bought_year} == {} } {
          if { ${dateformat} == {dm} } {
            set last_bought {--.--.----}
          } else {
            set last_bought {--/--/----}
          }
        } else {
          if { ${last_bought_month} == {} } { set last_bought_month {--} }
          if { ${last_bought_day} == {} } { set last_bought_day {--} }
          if { ${dateformat} == {dm} } {
            set last_bought "${last_bought_day}.${last_bought_month}.${last_bought_year}"
          } else {
            set last_bought "${last_bought_month}/${last_bought_day}/${last_bought_year}"
          }
        }
        # global history.in
        if { $update_global_history == {true} } {
          set winename_in ${domain}
          if { ${winename} != {} } { set winename_in "${winename_in} - ${winename}" }
          if { ${domain} == {}   } { set winename_in [ string range ${winename_in} 3 end ] }
          if { ${vineyard} != {} } { set winename_in "${winename_in} (${vineyard})" }
          if { ${year} != {}     } { set winename_in "${winename_in}, ${year}"      }
          if { [ .editleft.0.land2.2 cget -text ] == {} } {
            set input_land ${land}
          } else {
            set input_land [ .editleft.0.land2.2 cget -text ]
          }
          if { ${new_price} > 0 && ${new_price} != {} } {
            set input_price [ expr "${new_price} * ${new_amount}" ]
            set input_price [ format {%.2f} ${new_price} ]
          } elseif { ${price} > 0 && ${price} != {} } {
            set input_price [ expr "${price} * ${new_amount}" ]
            set input_price [ format "%.2f" ${input_price} ]
          } else {
            set input_price {}
          }
          set to_history_in {}
          lappend to_history_in ${last_bought_year} ${last_bought_month} ${last_bought_day} ${winename_in} ${input_land} ${new_amount} ${input_price} ${input_note}
          set initchannel [ open [ file join ${datadir} history.in ] a ]
          puts ${initchannel} ${to_history_in}
          close ${initchannel}
        }
        if { ${update_history} == {true} } {
          if { ${new_amount} == {1} } {
            if { ${input_note} == {} } {
              if { ${new_price} != {} } {
                set new_price [ format {%.2f} ${new_price} ]
                .editright.0.history2.message insert 1.0 "${last_bought} - ${new_amount} [::msgcat::mc {Bottle}], ${new_price} ${currency}\n"
              } else {
                .editright.0.history2.message insert 1.0 "${last_bought} - ${new_amount} [::msgcat::mc {Bottle}]\n"
              }
            } else {
              if { ${new_price} != {} } {
                set new_price [ format {%.2f} ${new_price} ]
                .editright.0.history2.message insert 1.0 "${last_bought} - ${new_amount} [::msgcat::mc {Bottle}], ${new_price} ${currency} - ${input_note}\n"
              } else {
                .editright.0.history2.message insert 1.0 "${last_bought} - ${new_amount} [::msgcat::mc {Bottle}] - ${input_note}\n"
              }
            }
          } else {
            if { ${input_note} == {} } {
              if { ${new_price} != {} } {
                set new_price [ format {%.2f} ${new_price} ]
                .editright.0.history2.message insert 1.0 "${last_bought} - ${new_amount} [::msgcat::mc {Bottles}], ${new_price} ${currency}\n"
              } else {
                .editright.0.history2.message insert 1.0 "${last_bought} - ${new_amount} [::msgcat::mc {Bottles}]\n"
              }
            } else {
               if { ${new_price} != {} } {
                 set new_price [ format {%.2f} ${new_price} ]
                 .editright.0.history2.message insert 1.0 "${last_bought} - ${new_amount} [::msgcat::mc {Bottles}], ${new_price} ${currency} - ${input_note}\n"
               } else {
                 .editright.0.history2.message insert 1.0 "${last_bought} - ${new_amount} [::msgcat::mc {Bottles}] - ${input_note}\n"
               }
            }
          }
        }
        if { ${update_historysum} == {true} } {
          set bought_sum [ expr "${bought_sum} + ${new_amount}" ]
          .editright.0.bought2.sum set ${bought_sum}
        }
      }
      destroy .input
    }
    button .input.frame2.abort -image ${closebutton} -text [::msgcat::mc {Abort}] -font ${titlefont} -compound left -pady 2 -padx 7 -relief raised -borderwidth 2 -command {
      destroy .input
    }
  pack .input.frame2.ok .input.frame2.abort -side left -fill x -expand true

  pack .input.frame1 .input.frame2 -side top -padx 10 -pady 10 -fill both

  bind .input <KeyPress-Escape> { .input.frame2.abort invoke }
  bind .input <Control-Key-q>   { .input.frame2.abort invoke }

  # window placement - mousepointer in the middle ...
  tkwait visibility .input
  set xposition_info [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .input ] / 2" ]" ]
  set yposition_info [ expr "[ winfo pointery . ] - [ expr "[ winfo height .input ] / 2" ]" ]
  if { ${xposition_info} < {0} } { set xposition_info {0} }
  if { ${yposition_info} < {0} } { set yposition_info {0} }
  if { [ expr "[ winfo width  .input ] + ${xposition_info}" ] > [ winfo screenwidth  . ] } { set xposition_info [ expr "[ winfo screenwidth  . ] - [ winfo width  .input ]" ] }
  if { [ expr "[ winfo height .input ] + ${yposition_info}" ] > [ winfo screenheight . ] } { set yposition_info [ expr "[ winfo screenheight . ] - [ winfo height .input ]" ] }
  wm geometry .input +${xposition_info}+${yposition_info}
}
