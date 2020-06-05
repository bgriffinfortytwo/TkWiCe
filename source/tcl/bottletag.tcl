# creates bottle tag
# outsourced from tkwice.tcl

proc bottletag {iFileID} {
  global datadir database prog_dir

  if { [ file exists [ file join ${datadir} ${database} ${iFileID} ] ] } {
    source [ file join ${datadir} ${database} ${iFileID} ]
  } else {
    continue
  }

  set bottletag_file {}
  set filetypes { { {HTML} {.htm .HTM .html .HTML} } }
  set bottletag_file [ tk_getSaveFile -initialdir ~ -parent . -title [::msgcat::mc {Save}] -defaultextension {.html} -filetypes ${filetypes} ]
  if { [ string length ${bottletag_file} ] } {

    # path because of the image file
    set imagelocation "file://[ file nativename [ file join ${prog_dir} img bottletag.png ] ]"

    if { [ string length ${storage_id} ] > "6" } { set storage_id "[ string range ${storage_id} 0 5 ]..." }

    # convert some chars to html
    set domain_tag [ htmlentities ${domain} ]
    set winename_tag [ htmlentities ${winename} ]
    set region_tag [ htmlentities ${region} ]
    set village_tag [ htmlentities ${village} ]
    if { ${grape1} != {} } {
      set length [ string first "(" ${grape1} ]
      if { ${length} != "-1" } {
        set grape1 [ string range ${grape1} 0 [ expr "${length} - 2" ] ]
      }
      set grape1_bottle_tag_text "[::msgcat::mc {Grape #1:}] "
    } else {
      set grape1_bottle_tag_text {}
    }
    set grape1_tag [ htmlentities ${grape1} ]

    # date
    set today_year  [ clock format [ clock seconds ] -format %Y ]
    set today_month [ clock format [ clock seconds ] -format %m ]
    # take sure that we can calculate with dates
    if { [string index ${today_month} 0] == "0" } {
      set today_month [string index ${today_month} 1]
    }
    set next_bottle_year {}
    if { [ string length next_bottle ] > {3} } {
      set next_bottle_year [ string range ${next_bottle} 0 3 ]
    }
    set next_bottle_month {}
    if { [ string length next_bottle ] > {5} } {
      set next_bottle_month [ string range ${next_bottle} 4 5 ]
    }
    if { ${next_bottle_year} != {} } {
      if { ${next_bottle_year} <= ${today_year} } {
        if { ${next_bottle_year} == ${today_year} && ${next_bottle_month} <= ${today_month} } {
          set wait_till [::msgcat::mc {already}]
          set next_bottle_tag [::msgcat::mc {drinkable}]
        } elseif { ${next_bottle_year} < ${today_year} } {
          set wait_till [::msgcat::mc {already}]
          set next_bottle_tag [::msgcat::mc {drinkable}]
        } else {
          set wait_till [::msgcat::mc {wait till}]
          set next_bottle_tag "${next_bottle_month}/${next_bottle_year}"
        }
      } else {
        set wait_till [::msgcat::mc {wait till}]
        set next_bottle_tag "${next_bottle_month}/${next_bottle_year}"
      }
    } else {
      set wait_till [::msgcat::mc {wait till}]
      set next_bottle_tag "${next_bottle_month}/${next_bottle_year}"
    }
    if { ${next_bottle_tag} == {/} } { set next_bottle_tag {_______} }
    if { ${last_bottle} != {} } {
      set last_bottle_tag ${last_bottle}
    } else {
      set last_bottle_tag {_____}
    }
    # translate color names
    if { ${color} == {Red} } {
      set color2 [::msgcat::mc {Red}]
    } elseif { ${color} == {White} } {
      set color2 [::msgcat::mc {White}]
    } elseif  { ${color} == "Ros\u00e9" } {
      set color2 [::msgcat::mc "Ros\u00e9"]
    } elseif { ${color} == {Colorless} } {
      set color2 [::msgcat::mc {Colorless}]
    }

    # write bottle tag file
    set initchannel [ open ${bottletag_file} w ]
    fconfigure ${initchannel} -encoding {utf-8}
    puts ${initchannel} "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
<html>

<head>
  <title>TkWiCe [::msgcat::mc {Bottle Tag}]</title>
  <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\">
  <base target=\"_top\">
  <style type=\"text/css\">
    body {color:#000000; background-color:#ffffff; font-family:arial,helvetica,sans-serif}
    span.small {font-size:small}
  </style>
</head>

<body>
<center><table style=\"border-collapse:collapse\"><tr><td style=\"border:dashed; border-width:1px; border-color:#999999\">
  <table cellpadding=\"0\" style=\"border-collapse:collapse; table-layout:fixed\"><tr><td cellpadding=\"0\" style=\"width:23mm; height:23mm; text-align:center; padding:0px\"><span style=\"font-size:7mm\">${land}</span><br/><span style=\"font-size:4mm\">${storage_id}</span>
  </td><td colspan=\"2\" cellpadding=\"0\" style=\"width:52mm; height:23mm; text-align:left; padding:0px\"><span style=\"font-size:5mm\">${domain_tag}</span><br/><span style=\"font-size:4mm\">${winename_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Color}]</span><br/><span style=\"font-size:5mm\">${color2}</span>
  </td><td cellpadding=\"0\" rowspan=\"2\" style=\"width:29mm; height:29mm; border:dashed; border-width:1px; border-color:#999999; padding:0px\"><img src=\"${imagelocation}\" style=\"width:29mm; height:29mm\">
  </td><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">${wait_till}</span><br/><span style=\"font-size:4mm\">${next_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Vintage}]</span><br/><span style=\"font-size:6mm\">${year}</span>
  </td><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {drink till}]</span><br/><span style=\"font-size:4mm\">${last_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:4mm\">${region_tag}</span><br/><span style=\"font-size:3mm\">${village_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:8mm; text-align:center; vertical-align:top; padding:0px\"><span style=\"font-size:3mm\">${grape1_bottle_tag_text}</span><span style=\"font-size:4mm\">${grape1_tag}</span>
  </td></tr></table>
</td><td style=\"border:dashed; border-width:1px; border-color:#999999\">
  <table cellpadding=\"0\" style=\"border-collapse:collapse; table-layout:fixed\"><tr><td cellpadding=\"0\" style=\"width:23mm; height:23mm; text-align:center; padding:0px\"><span style=\"font-size:7mm\">${land}</span><br/><span style=\"font-size:4mm\">${storage_id}</span>
  </td><td colspan=\"2\" cellpadding=\"0\" style=\"width:52mm; height:23mm; text-align:left; padding:0px\"><span style=\"font-size:5mm\">${domain_tag}</span><br/><span style=\"font-size:4mm\">${winename_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Color}]</span><br/><span style=\"font-size:5mm\">${color2}</span>
  </td><td cellpadding=\"0\" rowspan=\"2\" style=\"width:29mm; height:29mm; border:dashed; border-width:1px; border-color:#999999; padding:0px\"><img src=\"${imagelocation}\" style=\"width:29mm; height:29mm\">
  </td><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">${wait_till}</span><br/><span style=\"font-size:4mm\">${next_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Vintage}]</span><br/><span style=\"font-size:6mm\">${year}</span>
  </td><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {drink till}]</span><br/><span style=\"font-size:4mm\">${last_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:4mm\">${region_tag}</span><br/><span style=\"font-size:3mm\">${village_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:8mm; text-align:center; vertical-align:top; padding:0px\"><span style=\"font-size:3mm\">${grape1_bottle_tag_text}</span><span style=\"font-size:4mm\">${grape1_tag}</span>
  </td></tr></table>
</td></tr><tr><td style=\"border:dashed; border-width:1px; border-color:#999999\">
  <table cellpadding=\"0\" style=\"border-collapse:collapse; table-layout:fixed\"><tr><td cellpadding=\"0\" style=\"width:23mm; height:23mm; text-align:center; padding:0px\"><span style=\"font-size:7mm\">${land}</span><br/><span style=\"font-size:4mm\">${storage_id}</span>
  </td><td colspan=\"2\" cellpadding=\"0\" style=\"width:52mm; height:23mm; text-align:left; padding:0px\"><span style=\"font-size:5mm\">${domain_tag}</span><br/><span style=\"font-size:4mm\">${winename_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Color}]</span><br/><span style=\"font-size:5mm\">${color2}</span>
  </td><td cellpadding=\"0\" rowspan=\"2\" style=\"width:29mm; height:29mm; border:dashed; border-width:1px; border-color:#999999; padding:0px\"><img src=\"${imagelocation}\" style=\"width:29mm; height:29mm\">
  </td><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">${wait_till}</span><br/><span style=\"font-size:4mm\">${next_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Vintage}]</span><br/><span style=\"font-size:6mm\">${year}</span>
  </td><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {drink till}]</span><br/><span style=\"font-size:4mm\">${last_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:4mm\">${region_tag}</span><br/><span style=\"font-size:3mm\">${village_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:8mm; text-align:center; vertical-align:top; padding:0px\"><span style=\"font-size:3mm\">${grape1_bottle_tag_text}</span><span style=\"font-size:4mm\">${grape1_tag}</span>
  </td></tr></table>
</td><td style=\"border:dashed; border-width:1px; border-color:#999999\">
  <table cellpadding=\"0\" style=\"border-collapse:collapse; table-layout:fixed\"><tr><td cellpadding=\"0\" style=\"width:23mm; height:23mm; text-align:center; padding:0px\"><span style=\"font-size:7mm\">${land}</span><br/><span style=\"font-size:4mm\">${storage_id}</span>
  </td><td colspan=\"2\" cellpadding=\"0\" style=\"width:52mm; height:23mm; text-align:left; padding:0px\"><span style=\"font-size:5mm\">${domain_tag}</span><br/><span style=\"font-size:4mm\">${winename_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Color}]</span><br/><span style=\"font-size:5mm\">${color2}</span>
  </td><td cellpadding=\"0\" rowspan=\"2\" style=\"width:29mm; height:29mm; border:dashed; border-width:1px; border-color:#999999; padding:0px\"><img src=\"${imagelocation}\" style=\"width:29mm; height:29mm\">
  </td><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">${wait_till}</span><br/><span style=\"font-size:4mm\">${next_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Vintage}]</span><br/><span style=\"font-size:6mm\">${year}</span>
  </td><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {drink till}]</span><br/><span style=\"font-size:4mm\">${last_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:4mm\">${region_tag}</span><br/><span style=\"font-size:3mm\">${village_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:8mm; text-align:center; vertical-align:top; padding:0px\"><span style=\"font-size:3mm\">${grape1_bottle_tag_text}</span><span style=\"font-size:4mm\">${grape1_tag}</span>
  </td></tr></table>
</td></tr><tr><td style=\"border:dashed; border-width:1px; border-color:#999999\">
  <table cellpadding=\"0\" style=\"border-collapse:collapse; table-layout:fixed\"><tr><td cellpadding=\"0\" style=\"width:23mm; height:23mm; text-align:center; padding:0px\"><span style=\"font-size:7mm\">${land}</span><br/><span style=\"font-size:4mm\">${storage_id}</span>
  </td><td colspan=\"2\" cellpadding=\"0\" style=\"width:52mm; height:23mm; text-align:left; padding:0px\"><span style=\"font-size:5mm\">${domain_tag}</span><br/><span style=\"font-size:4mm\">${winename_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Color}]</span><br/><span style=\"font-size:5mm\">${color2}</span>
  </td><td cellpadding=\"0\" rowspan=\"2\" style=\"width:29mm; height:29mm; border:dashed; border-width:1px; border-color:#999999; padding:0px\"><img src=\"${imagelocation}\" style=\"width:29mm; height:29mm\">
  </td><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">${wait_till}</span><br/><span style=\"font-size:4mm\">${next_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Vintage}]</span><br/><span style=\"font-size:6mm\">${year}</span>
  </td><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {drink till}]</span><br/><span style=\"font-size:4mm\">${last_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:4mm\">${region_tag}</span><br/><span style=\"font-size:3mm\">${village_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:8mm; text-align:center; vertical-align:top; padding:0px\"><span style=\"font-size:3mm\">${grape1_bottle_tag_text}</span><span style=\"font-size:4mm\">${grape1_tag}</span>
  </td></tr></table>
</td><td style=\"border:dashed; border-width:1px; border-color:#999999\">
  <table cellpadding=\"0\" style=\"border-collapse:collapse; table-layout:fixed\"><tr><td cellpadding=\"0\" style=\"width:23mm; height:23mm; text-align:center; padding:0px\"><span style=\"font-size:7mm\">${land}</span><br/><span style=\"font-size:4mm\">${storage_id}</span>
  </td><td colspan=\"2\" cellpadding=\"0\" style=\"width:52mm; height:23mm; text-align:left; padding:0px\"><span style=\"font-size:5mm\">${domain_tag}</span><br/><span style=\"font-size:4mm\">${winename_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Color}]</span><br/><span style=\"font-size:5mm\">${color2}</span>
  </td><td cellpadding=\"0\" rowspan=\"2\" style=\"width:29mm; height:29mm; border:dashed; border-width:1px; border-color:#999999; padding:0px\"><img src=\"${imagelocation}\" style=\"width:29mm; height:29mm\">
  </td><td cellpadding=\"0\" style=\"width:23mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">${wait_till}</span><br/><span style=\"font-size:4mm\">${next_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {Vintage}]</span><br/><span style=\"font-size:6mm\">${year}</span>
  </td><td cellpadding=\"0\" style=\"width:23mm; height:14mm; text-align:center; padding:0px\"><span style=\"font-size:3mm\">[::msgcat::mc {drink till}]</span><br/><span style=\"font-size:4mm\">${last_bottle_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:15mm; text-align:center; padding:0px\"><span style=\"font-size:4mm\">${region_tag}</span><br/><span style=\"font-size:3mm\">${village_tag}</span>
  </td></tr><tr><td cellpadding=\"0\" colspan=\"3\" style=\"width:75mm; height:8mm; text-align:center; vertical-align:top; padding:0px\"><span style=\"font-size:3mm\">${grape1_bottle_tag_text}</span><span style=\"font-size:4mm\">${grape1_tag}</span>
  </td></tr></table>
</td></tr></table></center>
</body>

</html>
"
    close ${initchannel}
  }
}
