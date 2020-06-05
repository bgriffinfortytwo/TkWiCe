# simple HTML renderengine
# write ${content} to ${html_out_widget}

# set vars
set h1font    "\"[ font actual ${textfont} -family ]\" [ expr "[ font actual ${textfont} -size ] + 4" ] bold"
set h2font    "\"[ font actual ${textfont} -family ]\" [ expr "[ font actual ${textfont} -size ] + 2" ] bold"
set h3font    "\"[ font actual ${textfont} -family ]\" [ font actual ${textfont} -size ]                bold"
set smallfont "\"[ font actual ${textfont} -family ]\" [ expr "[ font actual ${textfont} -size ] - 2" ] normal"
set fxfont    "Courier [ font actual ${textfont} -size ] normal"
set html_listbullet "\u2022"
set listframe {0}

# set wraplength to $widgetwidth
set char_sum         [ expr "[ ${html_out_widget} cget -width ] - 4" ]
set width_char_count {0}
set teststring1      {}
set teststring2      {X}
while { ${width_char_count} < ${char_sum} } {
  set teststring1 "${teststring1}${teststring2}"
  incr width_char_count
}
set widgetwidth [ font measure ${fxfont} ${teststring1} ]
if { ${widgetwidth} < {300} } { set widgetwidth {300} }

# set the different text styles
${html_out_widget} tag configure h1         -font ${h1font} -justify center
${html_out_widget} tag configure h2         -font ${h2font}
${html_out_widget} tag configure h3         -font ${h3font}
${html_out_widget} tag configure small      -font ${smallfont}
${html_out_widget} tag configure text       -font ${textfont}
${html_out_widget} tag configure listbullet -font ${textfont} -lmargin1 [ font measure ${fxfont} {XX} ]
${html_out_widget} tag configure listtext   -font ${textfont} -lmargin1 [ font measure ${fxfont} {XXXXX} ] -lmargin2 [ font measure ${fxfont} {XXXX} ]

# replace and filter, especially </*> - don't need them
if { [ string first "<body>" ${content} ] != {-1} } {
  set content1 [ string range ${content} [ string first "<body>" ${content} ] end ]
} else {
  set content1 ${content}
}
regsub -all "<body>"                              ${content1} {}       content
regsub -all "</body>"                             ${content}  {}       content1
regsub -all "\n"                                  ${content1} " "      content
regsub -all "<br>"                                ${content}  "\n"     content1
regsub -all "  "                                  ${content1} " "      content
regsub -all "  "                                  ${content}  " "      content1
regsub -all "</h1>"                               ${content1} {}       content
regsub -all "</h2>"                               ${content}  {}       content1
regsub -all "</h3>"                               ${content1} {}       content
regsub -all "</p>"                                ${content}  {}       content1
regsub -all "</ul>"                               ${content1} {}       content
regsub -all "</li>"                               ${content}  {}       content1
regsub -all "&raquo;"                             ${content1} "\u00BB" content
regsub -all "&laquo;"                             ${content}  "\u00AB" content1
regsub -all "&amp;"                               ${content1} {\&}     content
regsub -all "&quot;"                              ${content}  "\""     content1
regsub -all "<!-- content end -->"                ${content1} {}       content
regsub -all "<!-- content -->"                    ${content}  {}       content1
regsub -all "</html>"                             ${content1} {}       content
regsub -all {<ul style="list-style-type:circle">} ${content}  {<ul>}   content1
regsub -all "<!-- hide"                           ${content1} {}       content
regsub -all "end -->"                             ${content}  {}       content1
regsub -all "&nbsp;"                              ${content1} " "      content
regsub -all "&eacute;"                            ${content}  "\u00e9" content1
regsub -all "&ntilde;"                            ${content1} "\u00f1" content
regsub -all "&ouml;"                              ${content}  "\u00f6" content1
regsub -all "&acirc;"                             ${content1} "\u00e2" content
regsub -all "&scaron;"                            ${content}  "\u0161" content1
# set content1 ${content}
set content [ string trim ${content1} ]

# infoline
if { [ info exists contentfile ] } { ${html_out_widget} insert end "\u00BB${contentfile}\u00AB\n\n" filefont }

# separate each part after "<" an display it corresponding to "*>"
# renderengine ...
set beginn {true}
set lasttag {}
while { [ regexp "<" ${content} ] == {1} } {
  if { [ string first "<h1>" ${content} ] == {0} } {
    if { ${beginn} != {true} } { ${html_out_widget} insert end "\n\n" small } else { set beginn {false} }
    regsub "<h1>" ${content} {} content1
    regsub -all "\n " ${content1} "\n" content
    set content1 ${content}
    set content [ string trim ${content1} ]
    if { [ regexp < ${content} ] == {1} } {
      set firstnewtag [ string first < ${content} ]
      set lastchar [ expr "${firstnewtag} - 1" ]
      set displaycontent [ string range ${content} 0 ${lastchar} ]
      regsub -all "&gt;" ${displaycontent}  ">" displaycontent1
      regsub -all "&lt;" ${displaycontent1} "<" displaycontent
      ${html_out_widget} insert end ${displaycontent} h1
      set content [ string range ${content} ${firstnewtag} end ]
    } else {
      regsub -all "&gt;" ${content}  ">" content1
      regsub -all "&lt;" ${content1} "<" content
      ${html_out_widget} insert end ${content} h1
      set content {}
    }
    set lasttag "<h1>"
  } elseif { [ string first "<h2>" ${content} ] == {0} } {
    if { ${beginn} != {true} } { ${html_out_widget} insert end "\n\n" small } else { set beginn {false} }
    regsub "<h2>" ${content} {} content1
    regsub -all "\n " ${content1} "\n" content
    set content1 ${content}
    set content [ string trim ${content1} ]
    if { [ regexp < ${content} ] == {1} } {
      set firstnewtag [ string first < ${content} ]
      set lastchar [ expr "${firstnewtag} - 1" ]
      set displaycontent [ string range ${content} 0 ${lastchar} ]
      regsub -all "&gt;" ${displaycontent}  ">" displaycontent1
      regsub -all "&lt;" ${displaycontent1} "<" displaycontent
      ${html_out_widget} insert end ${displaycontent} h2
      set content [ string range ${content} ${firstnewtag} end ]
    } else {
      regsub -all "&gt;" ${content}  ">" content1
      regsub -all "&lt;" ${content1} "<" content
      ${html_out_widget} insert end ${content} h2
      set content {}
    }
    set lasttag "<h2>"
  } elseif { [ string first "<h3>" ${content} ] == {0} } {
    if { ${beginn} != {true} } { ${html_out_widget} insert end "\n\n" small } else { set beginn {false} }
    regsub "<h3>" ${content} {} content1
    regsub -all "\n " ${content1} "\n" content
    set content1 ${content}
    set content [ string trim ${content1} ]
    if { [ regexp < ${content} ] == {1} } {
      set firstnewtag [ string first < ${content} ]
      set lastchar [ expr "${firstnewtag} - 1" ]
      set displaycontent [ string range ${content} 0 ${lastchar} ]
      regsub -all "&gt;" ${displaycontent}  ">" displaycontent1
      regsub -all "&lt;" ${displaycontent1} "<" displaycontent
      ${html_out_widget} insert end ${displaycontent} h3
      set content [ string range ${content} ${firstnewtag} end ]
    } else {
      regsub -all "&gt;" ${content}  ">" content1
      regsub -all "&lt;" ${content1} "<" content
      ${html_out_widget} insert end ${content} h3
      set content {}
    }
    set lasttag "<h3>"
  } elseif { [ string first "<p>" ${content} ] == {0} } {
    if { ${beginn} != {true} } { ${html_out_widget} insert end "\n\n" small } else { set beginn {false} }
    regsub "<p>" ${content} {} content1
    regsub -all "\n " ${content1} "\n" content
    set content1 ${content}
    set content [ string trim ${content1} ]
    if { [ regexp < ${content} ] == {1} } {
      set firstnewtag [ string first < ${content} ]
      set lastchar [ expr "${firstnewtag} - 1" ]
      set displaycontent [ string range ${content} 0 ${lastchar} ]
      regsub -all "&gt;" ${displaycontent}  ">" displaycontent1
      regsub -all "&lt;" ${displaycontent1} "<" displaycontent
      ${html_out_widget} insert end ${displaycontent} text
      set content [ string range ${content} ${firstnewtag} end ]
    } else {
      regsub -all "&gt;" ${content}  ">" content1
      regsub -all "&lt;" ${content1} "<" content
      ${html_out_widget} insert end ${content} text
      set content {}
    }
    set lasttag {}
  } elseif { [ string first "<ul>" ${content} ] == {0} } {
    set html_listbullet "\u2022"
    if { ${beginn} != {true} } { ${html_out_widget} insert end "\n" small } else { set beginn {false} }
    regsub "<ul>" ${content} {} content1
    regsub -all "\n " ${content1} "\n" content
    set content1 ${content}
    set content [ string trim ${content1} ]
  } elseif { [ string first "<ul style=\"list-style-type:decimal\">" ${content} ] == {0} } {
    set html_listbullet {0}
    if { ${beginn} != {true} } { ${html_out_widget} insert end "\n" small } else { set beginn {false} }
    regsub "<ul style=\"list-style-type:decimal\">" ${content} {} content1
    regsub -all "\n " ${content1} "\n" content
    set content1 ${content}
    set content [ string trim ${content1} ]
  } elseif { [ string first "<li>" ${content} ] == {0} } {
    if { ${beginn} != {true} } { ${html_out_widget} insert end "\n" small } else { set beginn {false} }
    regsub "<li>" ${content} {} content1
    regsub -all "\n " ${content1} "\n" content
    set content1 [ string trim ${content} ]
    if { $html_listbullet != "\u2022" } {
      set html_listbullet [ incr html_listbullet ]
      set html_listbullet2 "${html_listbullet}."
    } else {
      set html_listbullet2 ${html_listbullet}
    }
    if { [ regexp < ${content} ] == {1} } {
      set firstnewtag [ string first < ${content} ]
      set lastchar [ expr "${firstnewtag} - 1" ]
      set displaycontent [ string range ${content} 0 ${lastchar} ]
      regsub -all "&gt;" ${displaycontent}  ">" displaycontent1
      regsub -all "&lt;" ${displaycontent1} "<" displaycontent
      ${html_out_widget} insert end $html_listbullet2 listbullet
      ${html_out_widget} insert end "  ${displaycontent}" listtext
      set listframe [ incr listframe ]
      set content [ string range ${content} ${firstnewtag} end ]
    } else {
      ${html_out_widget} insert end $html_listbullet2 listbullet
      regsub -all "&gt;" ${content}  ">" content1
      regsub -all "&lt;" ${content1} "<" content
      ${html_out_widget} insert end "  ${content}" listtext
      set listframe [ incr listframe ]
      set content {}
    }
    set lasttag {}
  } elseif { [ string first "<a href=" ${content} ] == {0} } {
    if { ! [ info exists counter ] } { set counter {1} }
    # get link
    set link "0.html"
    set link [ string range ${content} 9 [ expr "[ string first "\">" ${content} ] -1 " ] ]
    # got link - go on
    if { [ lsearch ${history} ${link} ] == {-1} } {
      ${html_out_widget} tag configure link${counter} -font ${textfont} -foreground "#0000bb" -underline on
    } else {
      ${html_out_widget} tag configure link${counter} -font ${textfont} -foreground "#bb0077" -underline on
    }
    set content1 [ string range ${content} [ expr "[ string first > ${content} ] + 1"] end ]
    regsub -all "\n " ${content1} "\n" content
    set content1 [ string trim ${content} ]
    set content ${content1}
    if { [ regexp < ${content} ] == {1} } {
      set firstnewtag [ string first < ${content} ]
      set lastchar [ expr "${firstnewtag} - 1" ]
      set displaycontent [ string range ${content} 0 ${lastchar} ]
      regsub -all "&gt;" ${displaycontent}  ">" displaycontent1
      regsub -all "&lt;" ${displaycontent1} "<" displaycontent
      ${html_out_widget} insert end ${displaycontent} link${counter}
      set content [ string range ${content} ${firstnewtag} end ]
    } else {
      regsub -all "&gt;" ${content}  ">" content1
      regsub -all "&lt;" ${content1} "<" content
      ${html_out_widget} insert end ${content} link${counter}
      set content {}
    }
    ${html_out_widget} tag bind link${counter} <1> "showcontent ${link}"
    if { [ lsearch ${history} ${link} ] == {-1} } {
      ${html_out_widget} tag bind link${counter} <Any-Enter> "${html_out_widget} tag configure link${counter} -background \"#0000bb\" -foreground \"#ffffff\""
      ${html_out_widget} tag bind link${counter} <Any-Leave> "${html_out_widget} tag configure link${counter} -background \"#ffffff\" -foreground \"#0000bb\""
    } else {
      ${html_out_widget} tag bind link${counter} <Any-Enter> "${html_out_widget} tag configure link${counter} -background \"#bb0077\" -foreground \"#ffffff\""
      ${html_out_widget} tag bind link${counter} <Any-Leave> "${html_out_widget} tag configure link${counter} -background \"#ffffff\" -foreground \"#bb0077\""
    }
    incr counter
    regsub "</a>" ${content} <none> content1
    set content [ string trimleft ${content1} ]
  } elseif { [ string first "<a name=" ${content} ] == {0} } {
    if { ! [ info exists counter ] } { set counter {1} }
    # get anchor number
    set anchorhere [ string range ${content} 9 [ expr "[ string first "\">" ${content} ] -1 " ] ]
    set content1 [ string range ${content} [ expr "[ string first > ${content} ] + 1"] end ]
    regsub -all "\n " ${content1} "\n" content
    set content1 [ string trim ${content} ]
    set content ${content1}
    if { [ regexp < ${content} ] == {1} } {
      set firstnewtag [ string first < ${content} ]
      set lastchar [ expr "${firstnewtag} - 1" ]
      set content [ string range ${content} ${firstnewtag} end ]
    } else {
      set content {}
    }
    regsub "</a>" ${content} <none> content1
    set content [ string trimleft ${content1} ]
    if { ${anchor} == ${anchorhere} } {
      set scrolltoline [ ${html_out_widget} index end ]
    }
  } elseif { [ string first "<none>" ${content} ] == {0} } {
    if { ${beginn} == {true} } { set beginn {false} }
    regsub "<none>" ${content} {} content1
    regsub -all "\n " ${content1} "\n" content
    set content1 [ string trim ${content} ]
    set content ${content}
    if { [ regexp < ${content} ] == {1} } {
      set firstnewtag [ string first < ${content} ]
      set lastchar [ expr "${firstnewtag} - 1" ]
      set displaycontent [ string range ${content} 0 ${lastchar} ]
      regsub -all "&gt;" ${displaycontent}  ">" displaycontent1
      regsub -all "&lt;" ${displaycontent1} "<" displaycontent
      ${html_out_widget} insert end ${displaycontent} text
      set content [ string range ${content} ${firstnewtag} end ]
    } else {
      regsub -all "&gt;" ${content}  ">" content1
      regsub -all "&lt;" ${content1} "<" content
      ${html_out_widget} insert end ${content} text
      set content {}
    }
    set lasttag {}
  } else {
    regsub "<" ${content} {} content1
    set content ${content1}
    if { [ regexp < ${content} ] == {1} } {
      set firstnewtag [ string first < ${content} ]
      set lastchar [ expr "${firstnewtag} - 1" ]
      set displaycontent [ string range ${content} 0 ${lastchar} ]
      regsub -all "&gt;" ${displaycontent}  ">" displaycontent1
      regsub -all "&lt;" ${displaycontent1} "<" displaycontent
      ${html_out_widget} insert end "<${displaycontent}" text
      set content [ string range ${content} ${firstnewtag} end ]
    } else {
      regsub -all "&gt;" ${content}  ">" content1
      regsub -all "&lt;" ${content1} "<" content
      ${html_out_widget} insert end "<${content}" text
      set content {}
    }
  }
}
