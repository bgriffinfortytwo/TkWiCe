# creates a wine tasting sheet in HTML
# outsourced from tkwice.tcl

proc tastingsheet {iFileID} {
  global datadir database labelpic list_country

  # get the wine data
  if { [ file exists [ file join ${datadir} ${database} ${iFileID} ] ] } {
    source [ file join ${datadir} ${database} ${iFileID} ]
  } else {
    continue
  }

  # get a filename
  set sSheetFileName {}
  set aFileTypes { { {HTML} {.htm .HTM .html .HTML} } }
  set sSheetFileName [ tk_getSaveFile -initialdir ~ -parent . -title [::msgcat::mc {Save}] -defaultextension {.html} -filetypes ${aFileTypes} ]
  if { [ string length ${sSheetFileName} ] } {

    # translate color names
    set sColor {}
    if { ${color} == {Red} } {
      set sColor [::msgcat::mc {Red}]
      set sColorTable "<td class=\"fields\">[ htmlentities [::msgcat::mc {Garnet}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Brick}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Purple}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Cherry}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Ruby}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Black}] ]</td>"
    } elseif { ${color} == {White} } {
      set sColor [::msgcat::mc {White}]
      set sColorTable "<td class=\"fields\">[ htmlentities [::msgcat::mc {Bright}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Straw}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Citron}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Gold}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Oldgold}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Amber}] ]</td>"
    } elseif  { ${color} == "Ros\u00e9" } {
      set sColor [::msgcat::mc "Ros\u00e9"]
      set sColorTable "<td class=\"fields\">[ htmlentities [::msgcat::mc {Russet}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Salmon}] ]</td><td class=\"fields\">[ htmlentities [::msgcat::mc {Pinkish}] ]</td>"
    } elseif { ${color} == {Colorless} } {
      set sColor [::msgcat::mc {Colorless}]
      set sColorTable "<td></td>"
    }

    # build grape string
    set sGrapes {}
    if { [ string length ${grape1} ] } {
      set length [ string first "(" ${grape1} ]
      if { ${length} != {-1} } {
        set grape1 [ string range ${grape1} 0 [ expr "${length} - 2" ] ]
      }
      set sGrapes ${grape1}
      if { [ string length ${percent1} ] } {
        set sGrapes "${sGrapes} (${percent1}%)"
      }
    }
    if { [ string length ${grape2} ] } {
      set length [ string first "(" ${grape2} ]
      if { ${length} != {-1} } {
        set grape2 [ string range ${grape2} 0 [ expr "${length} - 2" ] ]
      }
      set sGrapes "${sGrapes}, ${grape2}"
      if { [ string length ${percent2} ] } {
        set sGrapes "${sGrapes} (${percent2}%)"
      }
    }
    if { [ string length ${grape3} ] } {
      set length [ string first "(" ${grape3} ]
      if { ${length} != {-1} } {
        set grape3 [ string range ${grape3} 0 [ expr "${length} - 2" ] ]
      }
      set sGrapes "${sGrapes}, ${grape3}"
      if { [ string length ${percent3} ] } {
        set sGrapes "${sGrapes} (${percent3}%)"
      }
    }
    if { [ string length ${grape4} ] } {
      set length [ string first "(" ${grape4} ]
      if { ${length} != {-1} } {
        set grape4 [ string range ${grape4} 0 [ expr "${length} - 2" ] ]
      }
      set sGrapes "${sGrapes}, ${grape4}"
      if { [ string length ${percent4} ] } {
        set sGrapes "${sGrapes} (${percent4}%)"
      }
    }
    if { [ string length ${grape5} ] } {
      set length [ string first "(" ${grape5} ]
      if { ${length} != {-1} } {
        set grape5 [ string range ${grape5} 0 [ expr "${length} - 2" ] ]
      }
      set sGrapes "${sGrapes}, ${grape5}"
      if { [ string length ${percent5} ] } {
        set sGrapes "${sGrapes} (${percent5}%)"
      }
    }

    # build wine name string
    set sTitle ${domain}
    if { [ string length ${winename} ] } {
      set sTitle "${sTitle} - ${winename}"
    }
    if { [ string length ${vineyard} ] } {
      set sTitle "${sTitle} (${vineyard})"
    }
    if { [ string length ${year} ] } {
      set sTitle "${sTitle}, ${year}"
    }

    # build region string
    set sFrom {}
    # country makro to string
    if { [ string length ${land} ] } {
      if { [ lsearch -regexp ${list_country} ^${land} ] != {-1} } {
        set land2 [ lindex ${list_country} [ lsearch -regexp ${list_country} ^${land} ] ]
        if { [ string range ${land2} 0 1 ] == ${land} } {
          set land [ string range ${land2} 2 [ string length ${land2} ] ]
        }
      }
    }
    set sFrom ${land}
    if { [ string length ${region} ] } {
      set sFrom "${sFrom} - ${region}"
    }
    if { [ string length ${village} ] } {
      set sFrom "${sFrom} - ${village}"
    }
    if { [ string length ${vineyard} ] } {
      set sFrom "${sFrom} - ${vineyard}"
    }

    # build alcohol string
    set sAlc [::msgcat::mc {unknown}]
    if { [ string length ${alc} ] } {
      set sAlc "${alc}%"
    }


    # build bio string
    set sBio [::msgcat::mc {unknown}]
    if { [ string length ${bio} ] } {
      set sBio ${bio}
    }


    # build barrel string
    set sBarrel [::msgcat::mc {unknown}]
    if { ${barrel} == {false} } {
      set sBarrel [::msgcat::mc {no}]
    } elseif { ${barrel} == "partial" } {
      set sBarrel [::msgcat::mc {partial}]
      if { [ string length ${barrel_months} ] } {
        set sBarrel "${sBarrel} - ${barrel_months} [::msgcat::mc {months}]"
      }
    } elseif { ${barrel} == {true} } {
      set sBarrel [::msgcat::mc {Barrel}]
      if { [ string length ${barrel_months} ] } {
        set sBarrel "${sBarrel} - ${barrel_months} [::msgcat::mc {months}]"
      }
    } elseif { ${barrel} == "barrique" } {
      set sBarrel [::msgcat::mc {Barrique}]
      if { [ string length ${barrel_months} ] } {
        set sBarrel "${sBarrel} - ${barrel_months} [::msgcat::mc {months}]"
      }
    } elseif { ${barrel} == {} } {
      set sBarrel [::msgcat::mc {unknown}]
    }


    # convert text to html
    set sColor       [ htmlentities ${sColor} ]
    set sGrapes      [ htmlentities ${sGrapes} ]
    set sTitle       [ htmlentities ${sTitle} ]
    set sFrom        [ htmlentities ${sFrom} ]
    set sBio         [ htmlentities ${sBio} ]
    set sClass       [ htmlentities ${classification} ]
    set sAlc         [ htmlentities ${sAlc} ]
    set sBarrel      [ htmlentities ${sBarrel} ]
    set sDomainnotes [ htmlentities ${domainnotes} ]
    set sWinenotes   [ htmlentities ${notes} ]


    # build notes text
    set sNotes {}
    if { [ string length ${sDomainnotes} ] } {
      set sNotes ${sDomainnotes}
    }
    if { [ string length ${sWinenotes} ] } {
      if { [ string length ${sDomainnotes} ] } {
        set sNotes "${sNotes}<br>"
      }
      set sNotes "${sNotes}${sWinenotes}"
    }


    # Image
    set sImageTag {}
    set sImage {}
    if { [ file exists [ file join ${datadir} ${labelpic} ${iFileID}.jpg ] ] } {
      set sImage [ file join ${datadir} ${labelpic} ${iFileID}.jpg ]
    } elseif { [ file exists [ file join ${datadir} ${labelpic} ${iFileID}.JPG ] ] } {
      set sImage [ file join ${datadir} ${labelpic} ${iFileID}.JPG ]
    } elseif { [ file exists [ file join ${datadir} ${labelpic} ${iFileID}.gif ] ] } {
      set sImage [ file join ${datadir} ${labelpic} ${iFileID}.gif ]
    } elseif { [ file exists [ file join ${datadir} ${labelpic} ${iFileID}.GIF ] ] } {
      set sImage [ file join ${datadir} ${labelpic} ${iFileID}.GIF ]
    }
    if { [ string length ${sImage} ] } {
      set sImage [ file nativename ${sImage} ]
      set sImageTag "<img src=\"file://${sImage}\" alt=\"${sTitle}\" /><br>"
    }


    # URL
    set sUrl [::msgcat::mc {unknown}]
    if { [ string length ${url} ] } {
	set sUrl "<a href=\"${url}\">${url}</a>"
    }


    # write file
    set initchannel [ open ${sSheetFileName} w ]
    fconfigure ${initchannel} -encoding {utf-8}
    puts ${initchannel} "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
<html>
<head>
<title>${sTitle}</title>
<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\">
<base target=\"_top\">
<style type=\"text/css\">
body {color:#000000; background-color:#ffffff; font-family:arial,helvetica,sans-serif;}
img {width:4.5cm; height:7.5cm; border:none; border-width:0px; float:right; margin-left:1em; margin-top:1em;}
h2 {font-variant:small-caps;}
h3 {font-variant:small-caps;}
ul {list-style-type:circle;}
table {border-collapse:collapse;}
td.descr {padding-right:0.5em; text-align:left; font-variant:small-caps;}
td.fields {padding-left:0.5em; padding-right:0.5em; border:solid; border-width:1px; font-size:small;}
td.explain {padding-right:0.5em; text-align:right; font-size:small;}
td.explain2 {padding-left:0.5em; text-align:left; font-size:small;}
td.blank {border:solid; border-width:1px;}
</style>
</head>
<body>
<div>
${sImageTag}
<h2>${sTitle}</h2>
<h3>[ htmlentities [::msgcat::mc {About the Wine}] ]</h3>
<ul>
<li><strong>[ htmlentities [::msgcat::mc {Color}] ]:</strong> ${sColor}</li>
<li><strong>[ htmlentities [::msgcat::mc {Region}] ]:</strong> ${sFrom}</li>
<li><strong>[ htmlentities [::msgcat::mc {Grapes}] ]:</strong> ${sGrapes}</li>
<li><strong>[ htmlentities [::msgcat::mc {Bio}] ]:</strong> ${sBio}</li>
<li><strong>[ htmlentities [::msgcat::mc {Classification}] ]:</strong> ${sClass}</li>
<li><strong>[ htmlentities [::msgcat::mc {Alcohol}] ]:</strong> ${sAlc}</li>
<li><strong>[ htmlentities [::msgcat::mc {Barrel}] ]:</strong> ${sBarrel}</li>
<li><strong>[ htmlentities [::msgcat::mc {Internet}] ]:</strong> ${sUrl}</li>
<li><strong>[ htmlentities [::msgcat::mc {Various}] ]:</strong> ${sNotes}</li>
</ul>
</div>
<div style=\"clear:both;font-size:0px;\">&nbsp;</div>
<h3>[ htmlentities [::msgcat::mc {Estimation}] ]</h3>
<table>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Tint}] ]
</td><td colspan=\"3\">
<table><tr>${sColorTable}</tr></table>
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Type of Taste}] ]
</td><td colspan=\"3\">
<table><tr>
<td class=\"fields\">[ htmlentities [::msgcat::mc {microbiological}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {floral}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {spicy}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {fruity}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {vegetal}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {nutty}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {caramelized}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {woody}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {earthy}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {chemical}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {pungent}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {oxidized}] ]</td>
</tr></table>
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Stopper}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {broken}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td width=\"100%\" class=\"explain2\">
[ htmlentities [::msgcat::mc {excellent}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Look}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {dusty}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {fascinating}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Nose}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {spoiled}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {infatuating}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Acidity}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {without}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {pronounced}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Sweetness}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {sweet}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {dry}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Tannin}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {soft}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {firm}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Body}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {lightly}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {vehemently}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Demand}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {easy}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {difficult}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Alcohol}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {flashy}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {integrated}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Authentic}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {untypical}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {typical}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Finish}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {untraceable}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {endless}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Harmony}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {bumpy}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {elegant}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Style}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {industrial}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {traditional}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Impression}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {failed}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {magnificent}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Headache}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {high risk}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {low risk}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Price Value}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {overpriced}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {cheap}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Evolution}] ]
</td><td class=\"explain\">
[ htmlentities [::msgcat::mc {unseasoned}] ]
</td><td><table><tr><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td><td class=\"blank\">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</td></tr></table></td><td class=\"explain2\">
[ htmlentities [::msgcat::mc {matured}] ]
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Air}] ]
</td><td colspan=\"3\">
<table><tr>
<td style=\"padding-right:0.5em\">[ htmlentities [::msgcat::mc {min.}] ]</td>
<td class=\"fields\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td style=\"padding-left:0.5em\">[ htmlentities [::msgcat::mc {Hours}] ]</td>
</tr></table>
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Decanter}] ]
</td><td colspan=\"3\">
<table><tr>
<td class=\"fields\">[ htmlentities [::msgcat::mc {yes}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {no}] ]</td>
</tr></table>
</td></tr>
<tr><td class=\"descr\">
[ htmlentities [::msgcat::mc {Sediment}] ]
</td><td colspan=\"3\">
<table><tr>
<td class=\"fields\">[ htmlentities [::msgcat::mc {yes}] ]</td>
<td class=\"fields\">[ htmlentities [::msgcat::mc {no}] ]</td>
</tr></table>
</td></tr>
</table>

</body>
</html>
"
    close ${initchannel}
  }
}
