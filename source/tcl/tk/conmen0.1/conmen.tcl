########################################################################
#
#  conmen
#  ======
#
#  Simple Tcl/Tk widget providing right click copy & paste context menu.
#  Note that pasting content could bypass your validation ...
#
#
########################################################################
#
#  usage
#  -----
#    package require conmen
#    ::ttips pathName
#
#
#  so far supported widgets
#  ------------------------
#    * entry
#    * text ("select all" is currently disabled - sorry)
#
#
#  additional entries to the conmen menu
#  -------------------------------------
#    pathName.conmen add ?options?
#
#
########################################################################

package require Tk

proc ::conmen { args } {

  # check if widget exists
  if { [ winfo exists [ lindex ${args} 0 ] ] } {
    global CONMENTOWIDGET CONMENTOWIDGETTYPE

    # fishing for some basic settings ...
    set CONMENTOWIDGET     [ lindex ${args} 0 ]
    set CONMENTOWIDGETTYPE [ winfo class ${CONMENTOWIDGET} ]

    # predefine the menu
    set ${CONMENTOWIDGET}CONMENMENU [ menu ${CONMENTOWIDGET}.conmen -tearoff 0 -postcommand {
      # enable or disable the menu entries before display them
      # something to paste?
      set CONMENSELECTIONGET {}
      catch { set CONMENSELECTIONGET [ clipboard get ] }
      if { [ string length ${CONMENSELECTIONGET} ] > {0} } {
        ${CONMENTOWIDGET}.conmen entryconfigure 2 -state normal
      } else {
        ${CONMENTOWIDGET}.conmen entryconfigure 2 -state disabled
      }
      # something marked?
      if { ${CONMENTOWIDGETTYPE} == {Entry} } {
        if { [ ${CONMENTOWIDGET} selection present ] } {
          ${CONMENTOWIDGET}.conmen entryconfigure 0 -state normal
          ${CONMENTOWIDGET}.conmen entryconfigure 1 -state normal
          ${CONMENTOWIDGET}.conmen entryconfigure 3 -state normal
        } else {
          ${CONMENTOWIDGET}.conmen entryconfigure 0 -state disabled
          ${CONMENTOWIDGET}.conmen entryconfigure 1 -state disabled
          ${CONMENTOWIDGET}.conmen entryconfigure 3 -state disabled
        }
      } elseif { ${CONMENTOWIDGETTYPE} == {Text} } {
        if { [ llength [ ${CONMENTOWIDGET} tag ranges sel ] ] == {2} } {
          ${CONMENTOWIDGET}.conmen entryconfigure 0 -state normal
          ${CONMENTOWIDGET}.conmen entryconfigure 1 -state normal
          ${CONMENTOWIDGET}.conmen entryconfigure 3 -state normal
        } else {
          ${CONMENTOWIDGET}.conmen entryconfigure 0 -state disabled
          ${CONMENTOWIDGET}.conmen entryconfigure 1 -state disabled
          ${CONMENTOWIDGET}.conmen entryconfigure 3 -state disabled
        }
      }
      # something markable?
      if { ${CONMENTOWIDGETTYPE} == {Entry} } {
        if { [ string length [ ${CONMENTOWIDGET} get ] ] > {0} } {
          ${CONMENTOWIDGET}.conmen entryconfigure 5 -state normal
        } else {
          ${CONMENTOWIDGET}.conmen entryconfigure 5 -state disabled
        }
      } elseif { ${CONMENTOWIDGETTYPE} == {Text} } {
        if { [ string length [ ${CONMENTOWIDGET} get 1.0 end ] ] > {1} } {
          ${CONMENTOWIDGET}.conmen entryconfigure 5 -state normal
        } else {
          ${CONMENTOWIDGET}.conmen entryconfigure 5 -state disabled
        }
        # but so far this doesn't work on text widgets ...
        ${CONMENTOWIDGET}.conmen entryconfigure 5 -state disabled
      }
      # widget disabled?
      if { [ ${CONMENTOWIDGET} cget -state ] == {disabled} } {
        ${CONMENTOWIDGET}.conmen entryconfigure 0 -state disabled
        ${CONMENTOWIDGET}.conmen entryconfigure 2 -state disabled
        ${CONMENTOWIDGET}.conmen entryconfigure 3 -state disabled
      }
      # unksupported widget type
      if { ${CONMENTOWIDGETTYPE} != {Entry} && ${CONMENTOWIDGETTYPE} != {Text} } {
        ${CONMENTOWIDGET}.conmen entryconfigure 0 -state disabled
        ${CONMENTOWIDGET}.conmen entryconfigure 1 -state disabled
        ${CONMENTOWIDGET}.conmen entryconfigure 2 -state disabled
        ${CONMENTOWIDGET}.conmen entryconfigure 3 -state disabled
        ${CONMENTOWIDGET}.conmen entryconfigure 5 -state disabled
      }
    } ]

    # build the menu - and: action
    # entry: cut
    ${CONMENTOWIDGET}.conmen add command -label [::msgcat::mc {Cut}] -command {
      if { ${CONMENTOWIDGETTYPE} == {Entry} } {
        set CONMENSELECTIONGET {}
        catch { set CONMENSELECTIONGET [ selection get ] }
        clipboard clear
        clipboard append ${CONMENSELECTIONGET}
        ${CONMENTOWIDGET} delete sel.first sel.last
      } elseif { ${CONMENTOWIDGETTYPE} == {Text} } {
        tk_textCopy ${CONMENTOWIDGET}
        tk_textCut ${CONMENTOWIDGET}
      }
    }

    # entry: copy
    ${CONMENTOWIDGET}.conmen add command -label [::msgcat::mc {Copy}] -command {
      if { ${CONMENTOWIDGETTYPE} == {Entry} } {
        set CONMENSELECTIONGET {}
        catch { set CONMENSELECTIONGET [ selection get ] }
        clipboard clear
        clipboard append ${CONMENSELECTIONGET}
      } elseif { ${CONMENTOWIDGETTYPE} == {Text} } {
        tk_textCopy ${CONMENTOWIDGET}
      }
    }

    # entry: paste
    ${CONMENTOWIDGET}.conmen add command -label [::msgcat::mc {Paste}] -command {
      if { ${CONMENTOWIDGETTYPE} == {Entry} } {
        if { [ ${CONMENTOWIDGET} selection present ] } {
        # switch selection to clipboard
          set [ ${CONMENTOWIDGET} cget -textvariable ] [ string map [ list [ selection get ] ${CONMENSELECTIONGET} ] [ ${CONMENTOWIDGET} get] ]
          ${CONMENTOWIDGET} selection clear
        } else {
        # add clipboard
          set [ ${CONMENTOWIDGET} cget -textvariable ] "[ string range [ ${CONMENTOWIDGET} get ] 0 [ expr "[ ${CONMENTOWIDGET} index anchor ] - 1" ] ]${CONMENSELECTIONGET}[ string range [ ${CONMENTOWIDGET} get ] [ ${CONMENTOWIDGET} index anchor ] end ]"
          ${CONMENTOWIDGET} icursor [ expr "[ ${CONMENTOWIDGET} index anchor ] + [ string length ${CONMENSELECTIONGET} ]" ]
        }
      } elseif { ${CONMENTOWIDGETTYPE} == {Text} } {
        tk_textPaste ${CONMENTOWIDGET}
        tk_textCut ${CONMENTOWIDGET}
      }
    }

    # entry: delete
    ${CONMENTOWIDGET}.conmen add command -label [::msgcat::mc {Delete}] -command {
      if { ${CONMENTOWIDGETTYPE} == {Entry} } {
        ${CONMENTOWIDGET} delete sel.first sel.last
      } elseif { ${CONMENTOWIDGETTYPE} == {Text} } {
        set CONMENTOWIDSELSTART [ lindex [ ${CONMENTOWIDGET} tag ranges sel ] 0 ]
        set CONMENTOWIDSELEND   [ lindex [ ${CONMENTOWIDGET} tag ranges sel ] 1 ]
        ${CONMENTOWIDGET} delete ${CONMENTOWIDSELSTART} ${CONMENTOWIDSELEND}
      }
    }

    # usual separator (why ever)
    ${CONMENTOWIDGET}.conmen add separator

    # entry: select all
    ${CONMENTOWIDGET}.conmen add command -label [::msgcat::mc {Select All}] -command {
      if { ${CONMENTOWIDGETTYPE} == {Entry} } {
        ${CONMENTOWIDGET} selection range 0 end
      } elseif { ${CONMENTOWIDGETTYPE} == {Text} } {
      # not yet implemented and disabled in widget view
      }
    }

    # add binding to widget
    bind ${CONMENTOWIDGET} <Button-3> {+
      global CONMENTOWIDGET
      set CONMENTOWIDGET %W
      focus ${CONMENTOWIDGET}
      set CONMENTOWIDGETTYPE [ winfo class ${CONMENTOWIDGET} ]
      tk_popup ${CONMENTOWIDGET}.conmen %X %Y
    }
  }
}

package provide conmen 0.1
