# source this to set window colors
# needed: onecolor [true|false], basecolor, colortheme
# sets: a colorpalette and some colornames:
#       lightcolor, background, textcolor, midcolor

# first set basic colors
if { ${onecolor} == {true} } {
  tk_setPalette ${basecolor}
  # tricky: get colors from temporary, unshown widget
  button .colortempbutton
  set lightcolor [ .colortempbutton cget -activebackground ]
  set background [ .colortempbutton cget -background ]
  set textcolor  [ .colortempbutton cget -foreground ]
  set selectbackground ${background}
  set selectforeground ${textcolor}
  destroy .colortempbutton
  # calculate midcolor ...
  scan [ string range ${background} 1 2 ] %x rcolor1dec
  scan [ string range ${lightcolor} 1 2 ] %x rcolor2dec
  scan [ string range ${background} 3 4 ] %x gcolor1dec
  scan [ string range ${lightcolor} 3 4 ] %x gcolor2dec
  scan [ string range ${background} 5 6 ] %x bcolor1dec
  scan [ string range ${lightcolor} 5 6 ] %x bcolor2dec
  set rmidcolor [ format %x [ expr round "(${rcolor1dec} + ${rcolor2dec} + ${rcolor2dec}) / 3" ] ]
  set gmidcolor [ format %x [ expr round "(${gcolor1dec} + ${gcolor2dec} + ${gcolor2dec}) / 3" ] ]
  set bmidcolor [ format %x [ expr round "(${bcolor1dec} + ${bcolor2dec} + ${bcolor2dec}) / 3" ] ]
  set midcolor "\#${rmidcolor}${gmidcolor}${bmidcolor}"
} elseif { ${onecolor} == {false} } {
  source [ file join ${prog_dir} rgb ${colortheme} ]
	if { ${colortheme} != {tile} } {
		set bTtk 0
	}
}

# Tile
if { ${bTtk} } {
	source [ file join ${prog_dir} rgb default ]
	# tricky: get background color from temporary, unshown widget
  button .colortempbutton
  set background [ .colortempbutton cget -background ]
	# correct background value on clam theme
	if { ${background} == {#d9d9d9} && [ lsearch -exact [ttk::themes] {clam} ] > 0 } {
		set background {#dcdad5}
	}
	destroy .colortempbutton
	# not the default font for tiled buttons
	ttk::style configure TButton -font ${titlefont}	
}

# set and calc the rest
tk_setPalette background          ${background} \
							highlightBackground ${background} \
							activeBackground    ${lightcolor} \
							activebackground    ${lightcolor} \
							selectColor         ${lightcolor} \
							foreground          ${textcolor} \
							activeForeground    ${textcolor} \
							highlightColor      ${textcolor} \
							selectForeground    ${selectforeground} \
							selectBackground    ${selectbackground}
