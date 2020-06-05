#!/bin/sh
#\
exec tclsh8.5 "$0" "$@"


# we need to work with the Tk toolkit and msgcat ...
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


# set "prog_dir" to program-directory
set self [ info script ]
if { [ file type ${self} ] == {link} } { set self [ file readlink ${self} ] }
set prog_dir [ file dirname ${self} ]
set prog_dir2 ${prog_dir}


# extensions
# tablelist
set tablelist_version {false}
catch { set tablelist_version [ package require tablelist ] }
if { $tablelist_version == {false} } { lappend auto_path [ file join ${prog_dir} tcl tk ] }
package require tablelist
if { $tablelist_version == {false} } { set tablelist_version [ package require tablelist ] }
set tablelist_version $tablelist::version
# Img
set img_version {false}
catch { set img_version [ package require Img ] }
# package conmen
set conmen_version {false}
catch { set conmen_version [ package require conmen ] }
if { ${conmen_version} == {false} } { lappend auto_path [ file join ${prog_dir} tcl tk ] }
package require conmen


# get version
set readchannel [ open [ file join ${prog_dir} VERSION ] r ]
set version_content [ read ${readchannel} ]
close ${readchannel}
# extract the parts of the content
set version_list [ split [ lindex ${version_content} 0 ] . ]
set majorversion [ lindex ${version_list} 0 ]
set minorversion [ lindex ${version_list} 1 ]
set patchlevel   [ lindex ${version_list} 2 ]
set version      "${majorversion}.${minorversion}"


# window related stuff
set progname {TkWiCe}
wm title      . "${progname} ${majorversion}.${minorversion}.${patchlevel}"
wm resizable  . true true
wm iconname   . ${progname}


# icon
catch { wm iconphoto . -default [ image create photo -file [ file join ${prog_dir} img tkwice48.gif ] ] [ image create photo -file [ file join ${prog_dir} img tkwice32.gif ] ] }


# graphics
set help        [ image create photo -file [ file join ${prog_dir} img help.gif ] ]
set search      [ image create photo -file [ file join ${prog_dir} img search.gif ] ]
set searchno    [ image create photo -file [ file join ${prog_dir} img searchno.gif ] ]
set edit        [ image create photo -file [ file join ${prog_dir} img edit.gif ] ]
set edit2       [ image create photo -file [ file join ${prog_dir} img edit2.gif ] ]
set new         [ image create photo -file [ file join ${prog_dir} img new.gif ] ]
set new2        [ image create photo -file [ file join ${prog_dir} img new2.gif ] ]
set new3        [ image create photo -file [ file join ${prog_dir} img new3.gif ] ]
set delete      [ image create photo -file [ file join ${prog_dir} img delete.gif ] ]
set delete2     [ image create photo -file [ file join ${prog_dir} img delete2.gif ] ]
set photo       [ image create photo -file [ file join ${prog_dir} img photo.gif ] ]
set history     [ image create photo -file [ file join ${prog_dir} img history.gif ] ]
set close       [ image create photo -file [ file join ${prog_dir} img close.gif ] ]
set okay        [ image create photo -file [ file join ${prog_dir} img okay.gif ] ]
set change      [ image create photo -file [ file join ${prog_dir} img reload.gif ] ]
set tool        [ image create photo -file [ file join ${prog_dir} img tool.gif ] ]
set input       [ image create photo -file [ file join ${prog_dir} img in.gif ] ]
set output      [ image create photo -file [ file join ${prog_dir} img out.gif ] ]
set mphone      [ image create photo -file [ file join ${prog_dir} img phone.gif ] ]
set mcomment    [ image create photo -file [ file join ${prog_dir} img comment2.gif ] ]
set mhelp       [ image create photo -file [ file join ${prog_dir} img help2.gif ] ]
set mlicense    [ image create photo -file [ file join ${prog_dir} img key.gif ] ]
set okaybutton  [ image create photo -file [ file join ${prog_dir} img okay.gif ] ]
set group       [ image create photo -file [ file join ${prog_dir} img group.gif ] ]
set groupadd    [ image create photo -file [ file join ${prog_dir} img groupadd.gif ] ]
set groupsel    [ image create photo -file [ file join ${prog_dir} img groupsel.gif ] ]
set tkwicegif   [ image create photo -file [ file join ${prog_dir} img menu.gif ] ]
set dealer      [ image create photo -file [ file join ${prog_dir} img dealer.gif ] ]
set icn_import  [ image create photo -file [ file join ${prog_dir} img import.gif ] ]
set icn_export  [ image create photo -file [ file join ${prog_dir} img export.gif ] ]
set icn_csv     [ image create photo -file [ file join ${prog_dir} img csv.gif ] ]
set icn_xml     [ image create photo -file [ file join ${prog_dir} img xml.gif ] ]
set icn_tasting [ image create photo -file [ file join ${prog_dir} img tasting.gif ] ]
set bottletag   [ image create photo -file [ file join ${prog_dir} img tag.gif ] ]


# source platform ini-file - unix, windows or macintosh
source [ file join ${prog_dir} ini $tcl_platform(platform).ini ]


########################################################################
# rename version 0.1 - 0.3 database directory to the actual one
# the user will be informed - look at the bottom lines of this source
set updated_db {no}
if { ! [ file isdirectory ${datadir} ] } {
  if { [ file isdirectory [ file join ~ .tkwice ] ] && [ file isdirectory [ file join ~ .tkwice database ] ] } {
    file rename [ file join ~ .tkwice ] ${datadir}
    set updated_db {yes}
  } elseif { [ file isdirectory [ file join ~ tkwice ] ] && [ file isdirectory [ file join ~ tkwice database ] ] } {
    file rename [ file join ~ tkwice ] ${datadir}
    set updated_db {yes}
  }
}
########################################################################


# set minimum readable font size
set fontname helvetica
if { [ lsearch -exact [ font families ] Arial ] } {
  set fontname Arial
} elseif { [ lsearch -exact [ font families ] arial ] } {
  set fontname arial
}
if { [ winfo screenheight . ] < 760 } { set fontname helvetica }
set fsize          {5}
set actualfontsize {0}
if { [ winfo screenheight . ] < 760 } {
  set minfontpixel {9}
} else {
  set minfontpixel {12}
}
while { $actualfontsize < ${minfontpixel} } {
  incr fsize
  set actualfontsize [ font metrics "${fontname} ${fsize} normal" -ascent ]
}
# set additional vars
set currency {euro}
set wish     [ info nameofexecutable ]
set locked   {false}


# database-subdir
set database {database}
set labelpic {labelpic}


# create infrastructure if not found and set defaults
if { ! [ file isdirectory ${datadir} ] } {
  file mkdir ${datadir}
}
if { ! [ file isdirectory [ file join ${datadir} ${database} ] ] } {
  file mkdir [ file join ${datadir} ${database} ]
}
if { ! [ file isdirectory [ file join ${datadir} ${labelpic} ] ] } {
  file mkdir [ file join ${datadir} ${labelpic} ]
}


# configuration - window and write file - source it
set changeconfig {true}
source [ file join ${prog_dir} tcl config.tcl ]


# set default language
set nls {en}
if { [ file exists [ file join ${prog_dir} ini nls.ini ] ] } {
  set readchannel [ open [ file join ${prog_dir} ini nls.ini ] r ]
  set nls [ read ${readchannel} ]
  close ${readchannel}
  set nls [ string trimright ${nls} ]
}


# predefine some vars for configuration (if not set in ./ini/*.ini)
set titlefont       "-family ${fontname} -size ${fsize} -weight bold"
set textfont        "-family ${fontname} -size ${fsize} -weight normal"
set smallfont       "-family ${fontname} -size [ expr "${fsize} -1" ] -weight normal"
set smallitalicfont "-family ${fontname} -size [ expr "${fsize} -1" ] -weight normal -slant italic"
set listfont        "-family Courier -size ${fsize} -weight normal"
set onecolor        {false}
set basecolor       {#dddddd}
set colortheme      {default}
set countrybuttons  {known}
set cbupdate        {true}
set colorname       {false}
set show_only_code  {false}
set dateformat      {dm}
set webbrowser      {}
set picopenpath     [ file nativename ~ ]
set viewmode        {buttons}
set glassname01     {}
set glassname02     {}
set glassname03     {}
set glassname04     {}
set glassname05     {}
set glassname06     {}
set glassname07     {}
set glassname08     {}
set glassname09     {}
set glassname10     {}
set manualpoints    {false}
set tooltips        {true}
set grape_add_syn         {true}
set grape_add_switch      {false}
set grape_add_synonly     {false}
set grape_add_lab         {false}
set grape_add_labnote     {true}
set grape_add_nat         {false}
set grape_add_scanrelated {false}
set tempscale       {celsius}


# overwrite previous settings with configuration (or take them to conffile)
if { [ lindex $argv 0 ] == {--profile} && [ lindex $argv 1 ] != {} } {
  set conffile [ file join ${datadir} "rc[ lindex $argv 1 ]" ]
  # if not present, import existing one if possible
  if { ! [ file exists ${conffile} ] && [ file exists [ file join ${datadir} tkwicerc ] ] } {
    file copy [ file join ${datadir} tkwicerc ] ${conffile}
  }
} else {
  set conffile [ file join ${datadir} tkwicerc ]
}
# import or update old configuration if found
if { ! [ file exists ${conffile} ] } {
  source [ file join ${prog_dir} tcl dbupd.tcl ]
} else {
  # check if conffile version is valid
  source ${conffile}
  if { [ info exists configmajor ] && [ info exists configminor ] && [ info exists configpatch ] } {
    if { ${configmajor} != ${majorversion} || ${configminor} != ${minorversion} || ${configpatch} != ${patchlevel} } {
      source [ file join ${prog_dir2} tcl dbupd.tcl ]
    }
  } else {
    source [ file join ${prog_dir2} tcl dbupd.tcl ]
  }
}
# test again if a valid config is now present
if { ! [ file exists ${conffile} ] } {
  # no valid config - first start of this software ... copyright:
  source [ file join ${prog_dir} tcl color.tcl ]
  set accept_return {refuse}
  wm iconify .
  update
  source [ file join ${prog_dir} tcl copy.tcl ]
  tkwait window .copy
  if {  [ info exist accept_return ] } {
    if { ${accept_return} == {refuse} } { exit }
  }
  # get a config
  writeconfig firststart
  if { [ lindex $argv 0 ] == {--profile} && [ lindex $argv 1 ] != {} } {
    exec ${wish} "${self}" --profile [ lindex $argv 1 ] &
  } else {
    exec ${wish} "${self}" &
  }
  exit
}
source ${conffile}
# prog_dir changed? write valid config ...
if { ${prog_dir2} != ${prog_dir} } {
  set prog_dir ${prog_dir2}
  writeconfig firststart
}


# Tile only for the tile theme
if { ( ${onecolor} == {false} && ${colortheme} != {tile} ) || ${onecolor} != {false} } {
	set bTtk 0
}


# load messages
msgcat::mclocale ${nls}
msgcat::mcload [ file join ${prog_dir} nls ]


# load external files / procs
source [ file join ${prog_dir} tcl txt2html.tcl ]
source [ file join ${prog_dir} tcl dealer.tcl ]
source [ file join ${prog_dir} tcl bottletag.tcl ]
source [ file join ${prog_dir} tcl tastesheet.tcl ]


# some other vars needed to be predefined
set sorting         {}
set filter          {available}
set file_id         {}
set new_file_id     {}
set red             {on}
set white           {on}
set rose            {on}
set searchstring    {}
set idsearchstring  {}
set showtype        {All Types}
set showbio         {all}
set countrycodelist {}
set countryfilter   {}
set showgroup       {}
set grouplist       {}
# currency - euro?
if { ${currency} == {euro} } { set currency "\u20ac" }


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


# set colors
source [ file join ${prog_dir} tcl color.tcl ]
# source the option database
source [ file join ${prog_dir} tcl style.tcl ]


# check for non-root on unix
if { $tcl_platform(platform) == {unix} } {
  if { [ pwd ] == {/root} || $env(USER) == {root} } {
    set infotitle {root detected!}
    set infotext  "There is no need to run TkWiCe as root!\n\Come back as user again.\n"
    set infotype  {info}
    source [ file join ${prog_dir} tcl info.tcl ]
    exit
  }
}


# started with options ...
# list profiles
if { [ string length ${argv} ] && [ lindex $argv 0 ] == {--lsprofiles} } {
  set counter {0}
  puts {So far created profiles:}
  puts {}
  foreach entry [ glob -nocomplain [ file join ${datadir} rc* ] ] {
    puts "  * [ string range [ file tail ${entry} ] 2 end ]"
    incr counter
  }
  if { ${counter} == {0} } {
    puts {  none found!}
  }
  puts {}
  exit
}
# shell output
if { [ string length ${argv} ] && [ lindex $argv 0 ] == {--ls} } {
  source [ file join ${prog_dir} tcl shellout.tcl ]
  exit
}
# help
if { [ string length ${argv} ] && [ lindex $argv 0 ] != {--profile} && [ lindex $argv 0 ] != {--lsprofile} && [ lindex $argv 0 ] != {--ls} } {
  puts "TkWiCe Version ${version}.${patchlevel}"
  puts {}
  puts {Options:}
  puts {  --lsprofiles       list available profile names}
  puts {  --profile [name]   startup with profile "name"}
  puts {                     (profile will be created if not found)}
  puts {  --ls               print cellar list to stdout and exit}
  puts {}
  exit
}


# re-get nameindices list if sorting changed - and sort mechanism for tablelist
set newsortindex {}
set lastsortorder {increasing}
proc nameindicesget { widget sortindex } {
  global nameindices newsortindex lastsortorder
  if { ${newsortindex} == ${sortindex} } {
    set lastsortorder [ ${widget} sortorder ]
    if { ${lastsortorder} == {increasing} } {
      set sortorder {decreasing}
    } else {
      set sortorder {increasing}
    }
  } else {
    set sortorder ${lastsortorder}
  }
  set newsortindex ${sortindex}
  ${widget} sortbycolumn ${sortindex} -${sortorder}
  set nameindices {}
  set step {0}
  set stepend [ expr "[ .winelist.text size ] -1" ]
  while { ${step} <= ${stepend} } {
    lappend nameindices [ .winelist.text rowcget ${step} -name ]
    incr step
  }
}


# selection in winelist
# first we need a switch - on the first start the statusline should not show wine, but program informations
set select_wine_first_start {true}
set nameindices {}
proc select_wine {} {
  global file_id select_wine_first_start nameindices listindextoset
  # clear any selection
  .winelist.text selection clear 0 [ .winelist.text size ]
  set match {false}
  # check if the file_id can be selected
  set listindextoset [ lsearch -exact ${nameindices} ${file_id} ]
  if { ${listindextoset} != {-1} } {
    .winelist.text selection set ${listindextoset}
    .winelist.text activate ${listindextoset}
    .winelist.text see ${listindextoset}
    infobar update
    .menu1.2.edit_wine          configure -state normal
    .menu1.2.edit_group         configure -state normal
    .menu1.2.consecutively_wine configure -state normal
    .menu1.2.delete_wine        configure -state normal
    set match {true}
  }
  # only of nothing could be selected - file_id was not found in actual list
  if { ${match} == {false} } {
    # check if anything entry is in the actual list
    if { [ .winelist.text size ] } {
      # okay, list exists - select first column
      .winelist.text selection set 0
      .winelist.text activate 0
      .winelist.text see 0
      .menu1.2.edit_wine          configure -state normal
      .menu1.2.edit_group         configure -state normal
      .menu1.2.consecutively_wine configure -state normal
      .menu1.2.delete_wine        configure -state normal
      set file_id [ .winelist.text rowcget 0 -name ]
      set listindextoset {0}
      # not the first start - update statusline
      if { ${select_wine_first_start} == {false} } { infobar update }
    } else {
    # blank list - disable some buttons
      .menu1.2.edit_wine          configure -state disabled
      .menu1.2.edit_group         configure -state disabled
      .menu1.2.consecutively_wine configure -state disabled
      .menu1.2.delete_wine        configure -state disabled
      set file_id {}
      set listindextoset {}
      .winelist.text see 0
    }
  }
  # first start switch - changing it
  if { ${select_wine_first_start} != {false} } { set select_wine_first_start {false} }
}


# second proc for country buttons ...
proc selectcountry {country widgetnumber} {
  global lightcolor background buttoncount countryfilter locked
  if { ${locked} != {true} } {
    if { [ .menu2.frame.$widgetnumber cget -relief ] == {groove} && ${widgetnumber} != {0} } {
      .menu2.frame.$widgetnumber configure -relief flat -background ${background}
      if { [ llength ${countryfilter} ] == {1} } {
        .menu2.frame.0 configure -relief groove -background ${lightcolor}
        set countryfilter {}
      } else {
        set listindex [ lsearch -exact ${countryfilter} ${country} ]
        set countryfilter [ lreplace ${countryfilter} ${listindex} ${listindex} ]
      }
    } elseif { ${widgetnumber} == {0} } {
      if { [ .menu2.frame.0 cget -relief ] != {groove} } {
        set counter {1}
        while { ${counter} <= ${buttoncount} } {
          .menu2.frame.${counter} configure -relief flat -background ${background}
          incr counter
        }
        .menu2.frame.0 configure -relief groove -background ${lightcolor}
      }
      set countryfilter {}
    } else {
      .menu2.frame.${widgetnumber} configure -relief groove -background ${lightcolor}
      if { [ .menu2.frame.0 cget -relief ] == {groove} } { .menu2.frame.0 configure -relief flat -background ${background} }
      lappend countryfilter ${country}
    }
    update_winelist
  }
}


# get list_country
proc get_list_country {} {
  global prog_dir list_country
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
    if { [ regexp -nocase [list ${entry}] ${list_country2} ] == {0} } { lappend list_country2 ${entry} }
  }
  set list_country [ string trimright ${list_country2} ]
}


# get country buttons
proc getcountries {delete} {
  global smallfont countrycodelist buttoncount list_country countrybuttons cbupdate
  get_list_country
  if { ${delete} == {delete} } {
    set destroycounter {1}
    while { ${destroycounter} <= ${buttoncount} } {
      destroy .menu2.frame.${destroycounter}
      incr destroycounter
    }
  }
  if { ${countrybuttons} == {known} } {
    set countrycodelist {}
    foreach entry ${list_country} {
      lappend countrycodelist [ string range ${entry} 0 1 ]
    }
  }
  # sort the list in full names
  set countrycodelist2 {}
  foreach entry ${list_country} {
    foreach entry2 ${countrycodelist} {
      if { [ lsearch -regexp ${entry} ^${entry2} ] != {-1} } { lappend countrycodelist2 ${entry2} }
    }
  }
  # start building buttons ...
  set buttonnumber {0}
  foreach entry ${countrycodelist2} {
    if { [ lsearch -regexp ${list_country} ^${entry} ] == {-1} } {
      continue
    } else {
      set text [ lindex ${list_country} [ lsearch -regexp ${list_country} ^${entry} ] ]
      if { [ string range ${text} 0 1 ] != ${entry} } { continue }
      set text [ string range ${text} 2 end ]
    }
    incr buttonnumber
    button .menu2.frame.${buttonnumber} -text ${text} -padx 7 -pady 0 -font ${smallfont} -relief flat -borderwidth 2 -command "selectcountry ${entry} ${buttonnumber}"
    pack .menu2.frame.${buttonnumber} -side left
    set buttoncount ${buttonnumber}
  }
  update
  .menu2.canvas configure -height [ winfo reqheight .menu2.frame ] -scrollregion "0 0 [ winfo reqwidth  .menu2.frame ] 0"
  .winelist.filter.scroll configure -command { .menu2.canvas xview }
}


# build a list of wines and calculate statusbar
proc scan_list {} {
  global prog_dir titlefont datadir winelist count_cellar count_worth count_database count_different filter average_price red white rose searchstring idsearchstring database showtype showbio listlength countrycodelist countryfilter countrybuttons cbupdate list_country show_only_code txt_look txt_nose txt_taste txt_impression selectbackground background lightcolor onecolor labelpic showgroup groupfile dateformat
  set today_year  [ clock format [ clock seconds ] -format %Y ]
  set today_month [ clock format [ clock seconds ] -format %m ]
  # take sure that we can calculate with dates
  if { [string index ${today_month} 0] == "0" } {
    set today_month [string index ${today_month} 1]
  }
  set winelist         {}
  set countrycodelist2 $countrycodelist
  set countrycodelist  {}
  set count_database   {0}
  set count_cellar     {0}
  set count_worth      {0}
  set count_different  {0}
  # get groupnumberlist if possible
  set groupnumbers {}
  if { ${showgroup} != {} } {
    set initchannel [ open ${groupfile} r ]
    foreach line [ split [ read ${initchannel} ] \n ] {
      if { [ lindex ${line} 0 ] == ${showgroup} } { set groupnumbers [ lrange ${line} 1 end ] }
    }
    close ${initchannel}
  }
  # country stuff
  get_list_country
  set summary_wines [ llength [ glob -nocomplain [ file join ${datadir} ${database} * ] ] ]
  set summary_now {0}
  if { [ winfo exists .progressbar ] } {
    set progressbar_length [ winfo width .progressbar ]
    .progressbar configure -width {0}
    pack .progressbar -fill none
  }
  # set retry timestamps once
  set retry-date1 "${today_year}-${today_month}"
  if { ${today_month} == {1} || ${today_month} == {01} } {
    set retry-date2 "[ expr "${today_year} - 1" ]-12"
  } else {
    set monthplainstring [ expr "${today_month} - 1" ]
    if { [ string length ${monthplainstring} ] == {1} } { set monthplainstring "0${monthplainstring}" }
    set retry-date2 "${today_year}-${monthplainstring}"
  }
  if { ${today_month} == {1} || ${today_month} == {01} } {
    set retry-date3 "[ expr "${today_year} - 1" ]-11"
  } elseif { ${today_month} == {2} || ${today_month} == {02} } {
    set retry-date3 "[ expr "${today_year} - 1" ]-12"
  } else {
    set monthplainstring [ expr "${today_month} - 2" ]
    if { [ string length ${monthplainstring} ] == {1} } { set monthplainstring "0${monthplainstring}" }
    set retry-date3 "${today_year}-${monthplainstring}"
  }
  # scan database
  set bBadDatabase false
  foreach wine [ glob -nocomplain [ file join ${datadir} ${database} * ] ] {
    set file [ file tail ${wine} ]
    # check if the file name is a valid one (only numbers, no dot, at least six chars)
    if { [ string length ${file} ] != 6 || ![ string is digit ${file} ] } {
      set infotitle [::msgcat::mc {Error!}]
      set infotext  "Found a bad file in the database directory:\n${wine}\n\n[::msgcat::mc {Really delete?}]"
      set infotype  {yesno}
      source [ file join ${prog_dir} tcl info.tcl ]
      if { ${infobutton} == {yes} } {
        file delete ${wine}
      }
      set bBadDatabase true
      continue
    }
    # blank values
    set land {}
    set region {}
    set village {}
    set domain {}
    set winegrower {}
    set domainnotes {}
    set storage_id {}
    set winename {}
    set vineyard {}
    set year {}
    set barrel {}
    set barrel_months {}
    set color {}
    set type {}
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
    set size {}
    set notes {}
    set url {}
    set drunk_history {}
    set next_bottle {}
    set last_bottle {}
    set dealer {}
    set price {}
    set bought_history {}
    set bought_sum {}
    set amount {}
    set cork {}
    set corkquality {}
    set look {}
    set tint {}
    set nose {}
    set typical {}
    set weight {}
    set complex {}
    set alcintegration {}
    set finish {}
    set balance {}
    set tastetype {}
    set aroma1 {}
    set aroma2 {}
    set impression {}
    set bitterness {}
    set acid {}
    set sweet {}
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
    set manualpoints {}
    set points_color {0}
    set points_luminance {0}
    set points_nose {0}
    set points_taste {0}
    set points_impression {0}
    set temperature {}
    set last_drunk {}
    set last_modified_secondsdate {0}
    set text {}
    source ${wine}
    set land2 ${land}
    # get coutry-code
    if { [ lsearch -exact ${countrycodelist} ${land} ] == {-1} && ${land} != {} } {
      if { ${countrybuttons} == {all} } {
        lappend countrycodelist ${land}
      } elseif { ${countrybuttons} == {available} && ${amount} > {0} } {
        lappend countrycodelist ${land}
      }
    }
    # calculate statusline
    incr count_database
    set count_cellar [ expr "${count_cellar} + ${amount}" ]
    if { ${price} != {} } {
      set price_summary [ expr "${price} * ${amount}" ]
    } else {
      set price_summary {0}
    }
    set count_worth [ expr "${count_worth} + ${price_summary}" ]
    if { ${amount} != {0} } { incr count_different }
    # textblock show_region
    if { ${show_only_code} == {false} && [ lsearch -regexp ${list_country} ^${land} ] != {-1} } {
      set land2 [ lindex ${list_country} [ lsearch -regexp ${list_country} ^${land} ] ]
      if { [ string range ${land2} 0 1 ] == ${land} } {
        set land [ string range ${land2} 2 [ string length ${land2} ] ]
      }
    }
    if { ${region} != {} && ${village} != {} } {
      set show_region "${land} - ${region} - ${village}"
    } elseif { ${region} != {} } {
      set show_region "${land} - ${region}"
    } else {
      set show_region "${land}"
    }
    # textblock show_wine
    if { ${winename} != {} && ${vineyard} != {} } {
      set show_wine "${domain} - ${winename} (${vineyard})"
    } elseif { ${winename} != {} } {
      set show_wine "${domain} - ${winename}"
    } else {
      set show_wine ${domain}
    }
    if { ${domain} == {} && ${winename} != {} } {
      if { ${vineyard} != {} } {
        set show_wine "${winename} (${vineyard})"
      } else {
        set show_wine ${winename}
      }
    }
    # textblock show_grape
    set show_grape {}
    if { ${grape1} != {} } {
      set length [ string first "(" ${grape1} ]
      if { ${length} != "-1" } {
        set grape1 [ string range ${grape1} 0 [ expr "${length} - 2" ] ]
      }
      set show_grape ${grape1}
    }
    if { ${grape2} != {} } {
      set length [ string first "(" ${grape2} ]
      if { ${length} != "-1" } {
        set grape2 [ string range ${grape2} 0 [ expr "${length} - 2" ] ]
      }
      if { ${show_grape} != {} } {
        set show_grape "${show_grape} - ${grape2}"
      } else {
        set show_grape ${grape2}
      }
    }
    if { ${grape3} != {} } {
      set length [ string first "(" ${grape3} ]
      if { ${length} != {-1} } {
        set grape3 [ string range ${grape3} 0 [ expr "${length} - 2" ] ]
      }
      if { ${show_grape} != {} } {
        set show_grape "${show_grape} - ${grape3}"
      } else {
        set show_grape ${grape3}
      }
    }
    if { ${grape4} != {} } {
      set length [ string first "(" ${grape4} ]
      if { ${length} != {-1} } {
        set grape4 [ string range ${grape4} 0 [ expr "${length} - 2" ] ]
      }
      if { ${show_grape} != {} } {
        set show_grape "${show_grape} - ${grape4}"
      } else {
        set show_grape ${grape4}
      }
    }
    if { ${grape5} != {} } {
      set length [ string first "(" ${grape5} ]
      if { ${length} != {-1} } {
        set grape5 [ string range ${grape5} 0 [ expr "${length} - 2" ] ]
      }
      if { ${show_grape} != {} } {
        set show_grape "${show_grape} - ${grape5}"
      } else {
        set show_grape ${grape5}
      }
    }
    # textblock show_amount
    if { ${amount} != {0} } {
      set show_amount ${amount}
    } else {
      set show_amount {-}
    }
    # translate color names
    if { ${color} == {Red} } {
      set color2 [::msgcat::mc {Red}]
    } elseif { ${color} == {White} } {
      set color2 [::msgcat::mc {White}]
    } elseif  { ${color} == "Ros\u00e9" } {
      set color2 [::msgcat::mc "Ros\u00e9"]
    } elseif  { ${color} == {Colorless} } {
      set color2 [::msgcat::mc {Colorless}]
    }
    # build list of the wine
    lappend text ${show_region} ${show_wine} ${year} ${color2} ${show_grape} ${last_bottle} ${show_amount} ${file}
    # before filter build and update scanline ...
    incr summary_now
    if { [ winfo exists .progressbar ] && ${summary_wines} != {0} } {
      if { ${summary_now} == ${summary_wines} } {
        pack .progressbar -fill x
        .progressbar configure -background ${background}
      } else {
        if { ${onecolor} == {true} } {
          .progressbar configure -width "[ expr " (${summary_now} * ${progressbar_length}) / ${summary_wines}" ]" -background ${lightcolor}
        } else {
          .progressbar configure -width "[ expr " (${summary_now} * ${progressbar_length}) / ${summary_wines}" ]" -background ${selectbackground}
        }
      }
      update
    }
    # first textfilter if set ...
    if { ${searchstring} != {} } {
      set searchfound {false}
      if { [ regexp -nocase [list ${searchstring}] ${show_region} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${show_wine} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${winegrower} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${domainnotes} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${year} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${barrel} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${grape1} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${grape2} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${grape3} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${grape4} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${grape5} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${color} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${bio} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${classification} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${alc} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${size} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${cork} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${tint} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${notes} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${url} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${drunk_history} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${dealer} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${price} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${bought_history} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${aroma1} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${aroma2} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${txt_look} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${txt_nose} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${txt_taste} ] } {
        set searchfound {true}
      } elseif { [ regexp -nocase [list ${searchstring}] ${txt_impression} ] } {
        set searchfound {true}
      } else {
        # type - need to search in the corresponding translation ... hmpf
        set sSearchType ""
        if { ${type} == {Normal} } {
          set sSearchType [::msgcat::mc {Still}]
        } elseif { ${type} == {Frizzante} } {
          set sSearchType [::msgcat::mc {Frizzante}]
        } elseif { ${type} == {Sparkling} } {
          set sSearchType [::msgcat::mc {Sparkling}]
        } elseif { ${type} == {Port} } {
          set sSearchType [::msgcat::mc {Fortified Wine}]
        } elseif { ${type} == {Fortified} } {
          set sSearchType [::msgcat::mc {Fortified Wine}]
        } elseif { ${type} == {Liqueur} } {
          set sSearchType [::msgcat::mc {Liqueur}]
        } elseif { ${type} == {Distilled} } {
          set sSearchType [::msgcat::mc {Distilled}]
        }
        if { [ regexp -nocase [list ${searchstring}] ${sSearchType} ] } {
          set searchfound {true}
        }
      }
      if { ${searchfound} == {false} } { continue }
    }
    # search for storage ID
    if { ${idsearchstring} != {} && [ regexp -nocase [list ${idsearchstring}] ${storage_id} ] != {1} } { continue }
    # countryfilter
    if { [ llength ${countryfilter} ] > {0} && [ lsearch -exact ${countryfilter} [ string range ${land2} 0 1 ] ] == {-1} } { continue }
    # type-filter
    if { ${showtype} != {All Types} } {
      if { ${type} == {Normal}    && ${showtype} != {Still}     } { continue }
      if { ${type} == {Frizzante} && ${showtype} != {Frizzante} } { continue }
      if { ${type} == {Sparkling} && ${showtype} != {Sparkling} } { continue }
      if { ${type} == {Liqueur}   && ${showtype} != {Liqueur}   } { continue }
      if { ${type} == {Fortified} && ${showtype} != {Fortified} } { continue }
      if { ${type} == {Distilled} && ${showtype} != {Distilled} } { continue }
    }
    # bio-filter
    if { ${showbio} == {bio} } {
      if { ${bio} == {} || ${bio} == [::msgcat::mc {No}] || ${bio} == [::msgcat::mc {no}] || ${bio} == {no} || ${bio} == {No} } { continue }
    }
    # color-filter
    if { ${color} == {Red}       && ${red}   == {off} } { continue }
    if { ${color} == {White}     && ${white} == {off} } { continue }
    if { ${color} == "Ros\u00e9" && ${rose}  == {off} } { continue }
    if { ${color} == {Colorless} && (${red} == {off} || ${white} == {off} || ${rose} == {off}) } { continue }
    # group-filter
    if { ${showgroup} != {} } {
      if { [ llength ${groupnumbers} ] == {0} || [ lsearch -exact ${groupnumbers} ${file} ] == {-1} } { continue }
    }
    # available
    if { ${filter} == {available} && ${amount} != {0} } {
      lappend winelist ${text}
      continue
    }
    # get date from next_bottle
    if { ${next_bottle} != {} || ${next_bottle} != {-------} } {
      set wine_year  [ string range ${next_bottle} 0 3 ]
      if { [string index ${next_bottle} 5] == {0} } {
        set wine_month [ string index ${next_bottle} 6 ]
      } else {
        set wine_month [ string range ${next_bottle} 5 6 ]
      }
    } else {
      set wine_year  ${today_year}
      set wine_month {13}
    }
    # to try
    if { ${filter} == {try} && ${amount} != {0} } {
      if { ${drunk_history} == {} && ${corkquality} == {} && ${look} == {} && ${nose} == {} && ${typical} == {} && ${weight} == {} && ${complex} == {} && ${finish} == {} && ${balance} == {} && ${impression} == {} && ${evolution} == {} && ${aroma1} == {} && ${aroma2} == {} && ${bitterness} == {} && ${acid} == {} && ${headache} == {} && ${believable} == {} && ${txt_look} == {} && ${txt_nose} == {} && ${txt_taste} == {} && ${txt_impression} == {} && ${value} == {} && ${alcintegration} == {} && ${points_color} == {0} && ${points_luminance} == {0} && ${points_nose} == {0} && ${points_taste} == {0} && ${points_impression} == {0} } {
        if { ${today_year} > ${wine_year} } {
          lappend winelist ${text}
          continue
        } elseif { ${today_year} == ${wine_year} && ${today_month} >= ${wine_month} } {
          lappend winelist ${text}
          continue
        } elseif { ${next_bottle} == {} } {
          lappend winelist ${text}
          continue
        }
      }
    }
    # to retry
    if { ${filter} == {retry} && ${amount} != {0} && ${next_bottle} != {} } {
      # filter the to-try wines out
      if { ${drunk_history} == {} && ${corkquality} == {} && ${look} == {} && ${nose} == {} && ${typical} == {} && ${weight} == {} && ${complex} == {} && ${finish} == {} && ${balance} == {} && ${impression} == {} && ${evolution} == {} && ${aroma1} == {} && ${aroma2} == {} && ${bitterness} == {} && ${acid} == {} && ${headache} == {} && ${believable} == {} && ${txt_look} == {} && ${txt_nose} == {} && ${txt_taste} == {} && ${txt_impression} == {} && ${value} == {} && ${alcintegration} == {} && ${points_color} == {0} && ${points_luminance} == {0} && ${points_nose} == {0} && ${points_taste} == {0} && ${points_impression} == {0} } {
        if { ${today_year} > ${wine_year} } {
          continue
        } elseif { ${today_year} == ${wine_year} && ${today_month} >= ${wine_month} } {
          continue
        }
      }
      # try to set last_drunk for wines without that timestamp ...
      if { ${last_drunk} == {} && [ string length ${drunk_history} ] >= {10} } {
        if { ${dateformat} == {dm} } {
          if { [ string index ${drunk_history} 3 ] == {0} || [ string index ${drunk_history} 3 ] == {1} } {
            if { [ string index ${drunk_history} 4 ] >= {0} && [ string index ${drunk_history} 4 ] < {10} && [ string range ${drunk_history} 6 9 ] > 1000 && [ string range ${drunk_history} 6 9 ] < 9999 } { set last_drunk "[ string range ${drunk_history} 6 9 ]-[ string index ${drunk_history} 3 ][ string index ${drunk_history} 4 ]" }
          }
        } else {
          if { [ string index ${drunk_history} 0 ] == {0} || [ string index ${drunk_history} 0 ] == {1} } {
            if { [ string index ${drunk_history} 1 ] >= {0} && [ string index ${drunk_history} 1 ] < {10} && [ string range ${drunk_history} 6 9 ] > 1000 && [ string range ${drunk_history} 6 9 ] < 9999 } { set last_drunk "[ string range ${drunk_history} 6 9 ]-[ string index ${drunk_history} 0 ][ string index ${drunk_history} 1 ]" }
          }
        }
      }
      # take sure we've got a last_drunk timestamp
      if { ${last_drunk} == {} } { set last_drunk {0001-01} }
      # is it to drink?
      if { ${today_year} > ${wine_year} } {
        if { ${last_drunk} < ${next_bottle} } {
          lappend winelist ${text}
          continue
        }
      } elseif { ${today_year} == ${wine_year} && ${today_month} >= ${wine_month} } {
        if { ${last_drunk} < ${next_bottle} } {
          lappend winelist ${text}
          continue
        }
      } else {
        continue
      }
    }
    # to drink
    if { ${filter} == {drink} && ${amount} != {0} } {
      if { ${today_year} > ${wine_year} } {
        lappend winelist ${text}
        continue
      } elseif { ${today_year} == ${wine_year} && ${today_month} >= ${wine_month} } {
        lappend winelist ${text}
        continue
      }
    }
    # wait-filter
    if { ${filter} == {wait} && ${amount} != {0} } {
      if { ${today_year} < ${wine_year} } {
        lappend winelist ${text}
        continue
      } elseif { ${today_year} == ${wine_year} && ${today_month} < ${wine_month} } {
        lappend winelist ${text}
        continue
      }
    }
    if { ${filter} == {none} } {
      lappend winelist ${text}
      continue
    }
    # 432000 seconds are 5 days ...
    if { ${filter} == {new} } {
      # seconf if clause, so clock won't be asked each time if not necessary ...
      if { [ expr "[ clock seconds ] - ${last_modified_secondsdate}" ] <= 432000 } {
        lappend winelist ${text}
        continue
      }
    }
  }
  # scan is done - reset progressbar (maybe not done with corrupted database)
  if { [ winfo exists .progressbar ] && ${bBadDatabase} } {
    pack .progressbar -fill x
    .progressbar configure -background ${background}
  }
  set countrycodelist [ lsort -dictionary ${countrycodelist} ]
  if { ${countrycodelist2} != {} && ${countrybuttons} != {known} && ${cbupdate} != {false} } {
    if { [ llength ${countrycodelist} ] != [ llength ${countrycodelist2} ] || ${countrycodelist} != ${countrycodelist2} } {
      set countrycodelist2 ${countrycodelist}
      getcountries delete
      if { ${countryfilter} != {} } {
        set countryfilter {}
        update_winelist
      }
    }
  }
  # calculate average price and cellar summary
  set average_price {0}
  if { ${count_cellar} != {0} } {
    set average_price [ expr "round (100 * ${count_worth} / ${count_cellar})" ]
    set average_price [ expr "${average_price} / 100.00" ]
  }
  set average_price [ format "%.2f" ${average_price} ]
  set count_worth [ format "%.2f" ${count_worth} ]
}
# run it at startup ...
scan_list


# export actual list to csv
proc csvexport {sCsvSeparator} {
  global winelist datadir database list_country
  # sort
  set exportlist {}
  foreach winerow ${winelist} {
    lappend exportlist [ lindex ${winerow} end ]
  }
  # exportfile
  set csvfilename {}
  set filetypes { { {CSV} {.csv .CSV} } }
  set csvfilename [ tk_getSaveFile -initialdir ~ -parent . -title [::msgcat::mc {Save}] -defaultextension {.csv} -filetypes ${filetypes} ]
  if { [ string length ${csvfilename} ] } {
    set csvfile [ open ${csvfilename} w ]
    puts ${csvfile} "\"ID\"${sCsvSeparator}[ csvclean [::msgcat::mc {Winery}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Name}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Vintage}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Country}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Growing Area}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Sub-Region}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Vineyard}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Color}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Alcohol}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Classification}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Barrel}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {months}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Bio}] ]${sCsvSeparator}[ csvclean "[::msgcat::mc {Grape}] #1" ]${sCsvSeparator}[ csvclean % ]${sCsvSeparator}[ csvclean "[::msgcat::mc {Grape}] #2" ]${sCsvSeparator}[ csvclean % ]${sCsvSeparator}[ csvclean "[::msgcat::mc {Grape}] #3" ]${sCsvSeparator}[ csvclean % ]${sCsvSeparator}[ csvclean "[::msgcat::mc {Grape}] #4" ]${sCsvSeparator}[ csvclean % ]${sCsvSeparator}[ csvclean "[::msgcat::mc {Grape}] #5" ]${sCsvSeparator}[ csvclean % ]${sCsvSeparator}[ csvclean [::msgcat::mc {Price}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Quantity}] ]${sCsvSeparator}[ csvclean [::msgcat::mc {Internet}] ]"
    # scan database
    foreach sFileId [ lsort ${exportlist} ] {
      source [ file join ${datadir} ${database} ${sFileId} ]
      # full country name
      if { [ lsearch -regexp ${list_country} ^${land} ] != {-1} } {
        set land2 [ lindex ${list_country} [ lsearch -regexp ${list_country} ^${land} ] ]
        if { [ string range ${land2} 0 1 ] == ${land} } {
          set land [ string range ${land2} 2 [ string length ${land2} ] ]
        }
      }
      # barrel
      set sBarrel {}
      if { ${barrel} == {false} } {
        set sBarrel [::msgcat::mc {no}]
      } elseif { ${barrel} == "partial" } {
        set sBarrel [::msgcat::mc {partial}]
      } elseif { ${barrel} == {true} } {
        set sBarrel [::msgcat::mc {Barrel}]
      } elseif { ${barrel} == "barrique" } {
        set sBarrel [::msgcat::mc {Barrique}]
      } elseif { ${barrel} == {} } {
        set sBarrel [::msgcat::mc {unknown}]
      }
      # write in file
      puts ${csvfile} "${sFileId}${sCsvSeparator}[ csvclean ${domain} ]${sCsvSeparator}[ csvclean ${winename} ]${sCsvSeparator}[ csvclean ${year} ]${sCsvSeparator}[ csvclean ${land} ]${sCsvSeparator}[ csvclean ${region} ]${sCsvSeparator}[ csvclean ${village} ]${sCsvSeparator}[ csvclean ${vineyard} ]${sCsvSeparator}[ csvclean [::msgcat::mc ${color}] ]${sCsvSeparator}[ csvclean ${alc} ]${sCsvSeparator}[ csvclean ${classification} ]${sCsvSeparator}[ csvclean ${sBarrel} ]${sCsvSeparator}[ csvclean ${barrel_months} ]${sCsvSeparator}[ csvclean ${bio} ]${sCsvSeparator}[ csvclean ${grape1} ]${sCsvSeparator}[ csvclean ${percent1} ]${sCsvSeparator}[ csvclean ${grape2} ]${sCsvSeparator}[ csvclean ${percent2} ]${sCsvSeparator}[ csvclean ${grape3} ]${sCsvSeparator}[ csvclean ${percent3} ]${sCsvSeparator}[ csvclean ${grape4} ]${sCsvSeparator}[ csvclean ${percent4} ]${sCsvSeparator}[ csvclean ${grape5} ]${sCsvSeparator}[ csvclean ${percent5} ]${sCsvSeparator}[ csvclean ${price} ]${sCsvSeparator}[ csvclean ${amount} ]${sCsvSeparator}[ csvclean ${url} ]"
    }
    close ${csvfile}
  }
}
proc csvclean {sValue} {
  if { [ string is double ${sValue} ] } {
    regsub -all {\.} ${sValue} {,} sValue
  }
  regsub -all "\"" ${sValue} {""} sValue
  return "\"${sValue}\""
}


# export actual list to xml
proc xmlexport {} {
  global winelist datadir database list_country currency
  # sort
  set exportlist {}
  foreach winerow ${winelist} {
    lappend exportlist [ lindex ${winerow} end ]
  }
  # exportfile
  set xmlfilename {}
  set filetypes { { {XML} {.xml .XML} } }
  set xmlfilename [ tk_getSaveFile -initialdir ~ -parent . -title [::msgcat::mc {Save}] -defaultextension {.xml} -filetypes ${filetypes} ]
  if { [ string length ${xmlfilename} ] } {
    set xmlfile [ open ${xmlfilename} w ]
    puts ${xmlfile} "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    puts ${xmlfile} "<tkwice date=\"[ xmlclean [ clock format [ clock seconds ] ] ]\">"
    # scan database
    foreach sFileId [ lsort ${exportlist} ] {
      source [ file join ${datadir} ${database} ${sFileId} ]
      # full country name
      if { [ lsearch -regexp ${list_country} ^${land} ] != {-1} } {
        set land2 [ lindex ${list_country} [ lsearch -regexp ${list_country} ^${land} ] ]
        if { [ string range ${land2} 0 1 ] == ${land} } {
          set land [ string range ${land2} 2 [ string length ${land2} ] ]
        }
      }
      # barrel
      set sBarrel {}
      if { ${barrel} == {false} } {
        set sBarrel [::msgcat::mc {no}]
      } elseif { ${barrel} == "partial" } {
        set sBarrel [::msgcat::mc {partial}]
      } elseif { ${barrel} == {true} } {
        set sBarrel [::msgcat::mc {Barrel}]
      } elseif { ${barrel} == "barrique" } {
        set sBarrel [::msgcat::mc {Barrique}]
      } elseif { ${barrel} == {} } {
        set sBarrel [::msgcat::mc {unknown}]
      }
      # write in file
      puts ${xmlfile} "<wine id=\"${sFileId}\">";
      puts ${xmlfile} "<winery>[ xmlclean ${domain} ]</winery>";
      puts ${xmlfile} "<name>[ xmlclean ${winename} ]</name>";
      puts ${xmlfile} "<vintage>[ xmlclean ${year} ]</vintage>";
      puts ${xmlfile} "<country>[ xmlclean ${land} ]</country>";
      puts ${xmlfile} "<region>[ xmlclean ${region} ]</region>";
      puts ${xmlfile} "<subregion>[ xmlclean ${village} ]</subregion>";
      puts ${xmlfile} "<vineyard>[ xmlclean ${vineyard} ]</vineyard>";
      puts ${xmlfile} "<color>[ xmlclean ${color} ]</color>";
      puts ${xmlfile} "<alcohol>[ xmlclean ${alc} ]</alcohol>";
      puts ${xmlfile} "<classification>[ xmlclean ${classification} ]</classification>";
      puts ${xmlfile} "<barrel months=\"[ xmlclean ${barrel_months} ]\">[ xmlclean ${sBarrel} ]</barrel>";
      puts ${xmlfile} "<bio>[ xmlclean ${bio} ]</bio>";
      puts ${xmlfile} "<grape_1 percent=\"[ xmlclean ${percent1} ]\">[ xmlclean ${grape1} ]</grape_1>";
      puts ${xmlfile} "<grape_2 percent=\"[ xmlclean ${percent2} ]\">[ xmlclean ${grape2} ]</grape_2>";
      puts ${xmlfile} "<grape_3 percent=\"[ xmlclean ${percent3} ]\">[ xmlclean ${grape3} ]</grape_3>";
      puts ${xmlfile} "<grape_4 percent=\"[ xmlclean ${percent4} ]\">[ xmlclean ${grape4} ]</grape_4>";
      puts ${xmlfile} "<grape_5 percent=\"[ xmlclean ${percent5} ]\">[ xmlclean ${grape5} ]</grape_5>";
      puts ${xmlfile} "<price currency=\"[ xmlclean ${currency} ]\">[ xmlclean ${price} ]</price>";
      puts ${xmlfile} "<amount>[ xmlclean ${amount} ]</amount>";
      puts ${xmlfile} "<url>[ xmlclean ${url} ]</url>";
      puts ${xmlfile} "</wine>";
    }
    puts ${xmlfile} "</tkwice>"
    close ${xmlfile}
  }
}
proc xmlclean {sValue} {
  regsub -all {&} ${sValue} {&amp;} sValue
  return [ encoding convertto utf-8 ${sValue} ]
}




# update infobar
set listindextoset {}
proc infobar { clear_bar } {
  global listindextoset
  if { ${clear_bar} == {clear} || ${listindextoset} > [ .winelist.text size ] || ${listindextoset} < {0}  } {
    set info_text {}
  } else {
    set completeline [ .winelist.text get ${listindextoset} ]
    set info_text [ lindex ${completeline} 1 ]
    if { [ lindex ${completeline} 2 ] != {} } { set info_text "${info_text}, [ lindex ${completeline} 2 ]" }
  }
  .infobar configure -text ${info_text}
}


# update statusbar
proc statusbar {} {
  global count_database count_cellar count_different count_worth currency average_price
  .statusbar configure -text "${count_database} [::msgcat::mc {wines in database}] / ${count_cellar} [::msgcat::mc {bottles in cellar}] (${count_different} [::msgcat::mc {different}]) -- ${count_worth} ${currency} [::msgcat::mc {cellar worth}] (${average_price} ${currency}/[::msgcat::mc {bottle}])"
}


# update winelist
proc update_winelist {} {
  global winelist midcolor lightcolor sorting colorname locked nameindices
  set locked {true}
  update
  if { ${sorting} != {} } {
    set sorting [ .winelist.text sortcolumn ]
    set sortorder [ .winelist.text sortorderlist ]
  } else {
    set sorting {0}
    set sortorder {increasing}
  }
  .winelist.text delete 0 [ .winelist.text size ]
  infobar clear
  scan_list
  foreach wine ${winelist} {
    .winelist.text insert end ${wine}
    if { ${colorname} == {true} } {
      if { [ lindex ${wine} 3 ] == [::msgcat::mc {Red}] } {
        .winelist.text cellconfigure end,3 -foreground {#a31000} -selectforeground {#a31000} -text "\u25CF"
      } elseif { [ lindex ${wine} 3 ] == [::msgcat::mc "Ros\u00e9"] } {
        .winelist.text cellconfigure end,3 -foreground {#ffa091} -selectforeground {#ffa091} -text "\u25CF"
      } elseif { [ lindex ${wine} 3 ] == [::msgcat::mc {White}] } {
        .winelist.text cellconfigure end,3 -foreground {#fff88f} -selectforeground {#fff88f} -text "\u25CF"
      } elseif { [ lindex ${wine} 3 ] == [::msgcat::mc {Colorless}] } {
        .winelist.text cellconfigure end,3 -text {}
      }
    }
    .winelist.text rowconfigure end -name [ lindex ${wine} 7 ]
  }
  if { ${sorting} == {0} } {
    .winelist.text sortbycolumn 2 -${sortorder}
    .winelist.text sortbycolumn 1 -${sortorder}
    .winelist.text sortbycolumn 0 -${sortorder}
  } elseif { ${sorting} == {1} } {
    .winelist.text sortbycolumn 2 -${sortorder}
    .winelist.text sortbycolumn 0 -${sortorder}
    .winelist.text sortbycolumn 1 -${sortorder}
  } elseif { ${sorting} == {2} } {
    .winelist.text sortbycolumn 1 -${sortorder}
    .winelist.text sortbycolumn 0 -${sortorder}
    .winelist.text sortbycolumn 2 -${sortorder}
  } elseif { ${sorting} == {3} } {
    .winelist.text sortbycolumn 2 -${sortorder}
    .winelist.text sortbycolumn 1 -${sortorder}
    .winelist.text sortbycolumn 0 -${sortorder}
    .winelist.text sortbycolumn 3 -${sortorder}
  } elseif { ${sorting} == {4} } {
    .winelist.text sortbycolumn 2 -${sortorder}
    .winelist.text sortbycolumn 1 -${sortorder}
    .winelist.text sortbycolumn 0 -${sortorder}
    .winelist.text sortbycolumn 4 -${sortorder}
  } elseif { ${sorting} == {5} } {
    .winelist.text sortbycolumn 2 -${sortorder}
    .winelist.text sortbycolumn 1 -${sortorder}
    .winelist.text sortbycolumn 0 -${sortorder}
    .winelist.text sortbycolumn 5 -${sortorder}
  } else {
    .winelist.text sortbycolumn 2 -${sortorder}
    .winelist.text sortbycolumn 1 -${sortorder}
    .winelist.text sortbycolumn 0 -${sortorder}
    .winelist.text sortbycolumn 6 -${sortorder}
  }
  set nameindices {}
  set step {0}
  set stepend [ expr "[ .winelist.text size ] - 1" ]
  while { ${step} <= ${stepend} } {
    lappend nameindices [ .winelist.text rowcget ${step} -name ]
    incr step
  }
  statusbar
  select_wine
  set locked {false}
}


# find a new filename and exec wine-editor with it
proc new_file_id {edit} {
  global datadir new_file_id prog_dir conffile file_id wish database winelist labelpic
  set already_exists {true}
  while { $already_exists == {true} } {
    set new_file_id [ string range [ expr rand() ] 3 8 ]
    if { ! [ file exists [ file join ${datadir} ${database} ${new_file_id} ] ] } { set already_exists {false} }
  }
  if { ${edit} == {new} } {
    # unwanted when editing a wine - the dealer window
    if {[ winfo exists .dealer]} { destroy .dealer }
    # change mouse cursor
    set cursor [ . cget -cursor ]
    . configure -cursor watch
    update
    exec ${wish} [ file join ${prog_dir} tcl editwine.tcl ] ${conffile} ${new_file_id}
    # select if new file is saved
    if { [ file exists [ file join ${datadir} ${database} ${new_file_id} ] ] } {
      update_winelist
    } else {
      # not saved - delete possible pictures ...
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.jpg  ] ] == "1" } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.jpg  ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.jpeg ] ] == "1" } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.jpeg ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.JPG  ] ] == "1" } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.JPG  ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.JPEG ] ] == "1" } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.JPEG ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.gif  ] ] == "1" } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.gif  ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.GIF  ] ] == "1" } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.GIF  ] }
    }
    set file_id ${new_file_id}
    select_wine
    # reset mouse cursor
    . configure -cursor ${cursor}
  }
}


proc do_selected {todo} {
  global datadir labelpic winelist count_database count_cellar count_different count_worth currency average_price file_id new_file_id filter prog_dir conffile wish database titlefont textfont searchstring idsearchstring bTtk
  if { ${todo} == {edit} } {
    # unwanted when editing a wine - the dealer window
    if {[ winfo exists .dealer]} { destroy .dealer }
    # change mouse cursor
    set cursor [ . cget -cursor ]
    . configure -cursor watch
    update
    # update mechanism for wine list - part I
    set update_winelist {false}
    set getdate [ file mtime [ file join ${datadir} ${database} ${file_id} ] ]
    exec ${wish} [ file join ${prog_dir} tcl editwine.tcl ] ${conffile} ${file_id}
    # exists the updatefile?
    set updatefile [ file join ${datadir} update.lst ]
    if { [ file exists ${updatefile} ] } {
      set update_winelist {true}
    } elseif { [ file mtime [ file join ${datadir} ${database} ${file_id} ] ] != ${getdate} && ${filter} == {try} } {
      set update_winelist {true}
    } elseif { [ file mtime [ file join ${datadir} ${database} ${file_id} ] ] != ${getdate} && [ string length ${searchstring} ] != {0} } {
      set update_winelist {true}
    } elseif { [ file mtime [ file join ${datadir} ${database} ${file_id} ] ] != ${getdate} && [ string length ${idsearchstring} ] != {0} } {
      set update_winelist {true}
    }
    if { ${update_winelist} == {true} } { update_winelist }
    # reset mouse cursor
    . configure -cursor ${cursor}
    select_wine
  } elseif { ${todo} == {sequitur} } {
    # introduce some necessary newer vars ... hmpf
    set domainnotes {}
    set winegrower {}
    set barrel {}
    set barrel_months {}
    set update_winelist {false}
    source [ file join ${datadir} ${database} ${file_id} ]
    if { ${year} != {} } { incr year }
    new_file_id sequitur
    set initchannel [ open [ file join ${datadir} ${database} $new_file_id ] w ]
    puts ${initchannel} "set land \{${land}\}"
    puts ${initchannel} "set region \{${region}\}"
    puts ${initchannel} "set village \{${village}\}"
    puts ${initchannel} "set domain \{${domain}\}"
    puts ${initchannel} "set domainnotes \{${domainnotes}\}"
    puts ${initchannel} "set winegrower \{${winegrower}\}"
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
    puts ${initchannel} "set color \{${color}\}"
    puts ${initchannel} "set type \{${type}\}"
    puts ${initchannel} "set alc \{${alc}\}"
    puts ${initchannel} "set bio \{${bio}\}"
    puts ${initchannel} "set classification \{${classification}\}"
    puts ${initchannel} "set size \{${size}\}"
    puts ${initchannel} "set url \{${url}\}"
    puts ${initchannel} "set notes \{${notes}\}"
    puts ${initchannel} "set drunk_history \{\}"
    puts ${initchannel} "set next_bottle \{\}"
    puts ${initchannel} "set last_bottle \{\}"
    puts ${initchannel} "set dealer \{\}"
    puts ${initchannel} "set price \{\}"
    puts ${initchannel} "set amount \{0\}"
    close ${initchannel}
    # unwanted when editing a wine - the dealer window
    if {[ winfo exists .dealer]} { destroy .dealer }
    # change mouse cursor
    set cursor [ . cget -cursor ]
    . configure -cursor watch
    update
    # update mechanism for wine list - part I
    set getdate [ file mtime [ file join ${datadir} ${database} $new_file_id ] ]
    # execute wine editor
    exec ${wish} [ file join ${prog_dir} tcl editwine.tcl ] ${conffile} ${new_file_id}
    # exists the updatefile?
    set updatefile [ file join ${datadir} update.lst ]
    if { [ file mtime [ file join ${datadir} ${database} ${new_file_id} ] ] != ${getdate} } {
      set update_winelist {true}
    }
    if { ${update_winelist} == {true} } {
      update_winelist
      select_wine
      source [ file join ${datadir} ${database} ${new_file_id} ]
      if { ${filter} != {none} && ${filter} != {new} && ${amount} == {0} } {
        set infotitle [::msgcat::mc {Information}]
        set infotext  "[::msgcat::mc {Actuall stock of the new entry is set to be zero.}]\n\n[::msgcat::mc "Choose \u00bb Modified\u00ab or \u00bbAll\u00ab from the"]\n[::msgcat::mc "\u00bbShow\u00ab-menu to see such entries in the list."]"
        set infotype  {info}
        source [ file join ${prog_dir} tcl info.tcl ]
      } else {
        set file_id ${new_file_id}
        select_wine
      }
      infobar update
    } else {
      file delete [ file join ${datadir} ${database} ${new_file_id} ]
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.jpg  ] ] } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.jpg  ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.jpeg ] ] } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.jpeg ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.JPG  ] ] } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.JPG  ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.JPEG ] ] } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.JPEG ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.gif  ] ] } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.gif  ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${new_file_id}.GIF  ] ] } { file delete [ file join ${datadir} ${labelpic} ${new_file_id}.GIF  ] }
    }
    # reset mouse cursor
    . configure -cursor ${cursor}
  } elseif { ${todo} == {delete} } {
    # delete a wine from database and rebuild list
    source [ file join ${datadir} ${database} ${file_id} ]
    set file_to_delete ${file_id}
    set infotitle [::msgcat::mc {Confirmation: Delete}]
    set infotext  "[::msgcat::mc {File ID:}] ${file_id}\n[::msgcat::mc {Winery:}] ${domain}\n[::msgcat::mc {Name:}] ${winename}\n[::msgcat::mc {Vintage:}] ${year}\n\n[::msgcat::mc {Really delete?}]"
    set infotype  {yesno}
    source [ file join ${prog_dir} tcl info.tcl ]
    if { ${infobutton} == {yes} } {
      file delete [ file join ${datadir} ${database} ${file_to_delete} ]
      if { [ file exists [ file join ${datadir} ${labelpic} ${file_to_delete}.jpg  ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_to_delete}.jpg  ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${file_to_delete}.jpeg ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_to_delete}.jpeg ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${file_to_delete}.JPG  ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_to_delete}.JPG  ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${file_to_delete}.JPEG ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_to_delete}.JPEG ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${file_to_delete}.gif  ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_to_delete}.gif  ] }
      if { [ file exists [ file join ${datadir} ${labelpic} ${file_to_delete}.GIF  ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_to_delete}.GIF  ] }
      update_winelist
      select_wine
    }
  } elseif { ${todo} == {select} } {
    select_wine
  }
}


# 1. menubar
frame .menu1 -borderwidth 2 -relief raised

  menubutton .menu1.tkwice -text ${progname} -image ${tkwicegif} -font ${smallfont} -compound top -pady 2 -padx 7 -borderwidth 0 -relief flat -menu .menu1.tkwice.menu
  set tkwicemenu [ menu .menu1.tkwice.menu -tearoff 1 ]
  ${tkwicemenu} add command -label " [::msgcat::mc {Dealer Database}]" -image ${dealer} -compound left -command { dealerwindow }
  ${tkwicemenu} add command -label " [::msgcat::mc {Group Manager}]" -image ${group} -compound left -command { source [ file join ${prog_dir} tcl groupman.tcl ] }
  ${tkwicemenu} add command -label " [::msgcat::mc {Preferences}]" -image ${tool} -compound left -command { writeconfig edit }
  ${tkwicemenu} add separator
  ${tkwicemenu} add cascade -image ${icn_export} -label " [::msgcat::mc {Export}] / [::msgcat::mc {Printable}]" -compound left -menu .menu1.tkwice.menu.export
    set exportmenu [ menu .menu1.tkwice.menu.export -tearoff 1 ]
    ${exportmenu} add command -label " [::msgcat::mc {List}]: [::msgcat::mc {CSV File}] \[,\]" -image ${icn_csv} -compound left -command { csvexport {,} }
    ${exportmenu} add command -label " [::msgcat::mc {List}]: [::msgcat::mc {CSV File}] \[;\]" -image ${icn_csv} -compound left -command { csvexport {;} }
    ${exportmenu} add command -label " [::msgcat::mc {List}]: [::msgcat::mc {XML File}]" -image ${icn_xml} -compound left -command { xmlexport }
#    ${exportmenu} add command -label " [::msgcat::mc {List}]: [::msgcat::mc {Wine Tasting Cover Sheet}]" -image ${icn_export} -compound left -command { tastingcoversheet }
    ${exportmenu} add command -label " [::msgcat::mc {Selection}]: [::msgcat::mc {Wine Tasting Sheet}]" -image ${icn_tasting} -compound left -command { tastingsheet ${file_id} }
    ${exportmenu} add command -label " [::msgcat::mc {Selection}]: [::msgcat::mc {Bottle Tag}]" -image ${bottletag} -compound left -command { bottletag ${file_id} }
#  ${tkwicemenu} add cascade -image ${icn_import} -label " [::msgcat::mc {Import}]" -compound left -menu .menu1.tkwice.menu.import
#    set importmenu [ menu .menu1.tkwice.menu.import -tearoff 1 ]
#    ${importmenu} add command -label " [::msgcat::mc {New Wines from CSV File}]" -image ${icn_import} -compound left -command { csvimport }
  ${tkwicemenu} add separator
  ${tkwicemenu} add command -label " [::msgcat::mc {Refresh}]" -image ${change} -compound left -accelerator {Qtrl+R} -command { if { ${locked} != {true} } { update_winelist } }
  ${tkwicemenu} add separator
  ${tkwicemenu} add command -label " [::msgcat::mc {Exit}]" -image ${close} -compound left -accelerator {Qtrl+Q} -command { exit }
pack .menu1.tkwice -side left -fill y
bind .menu1.tkwice <Enter> { .menu1.tkwice configure -background ${lightcolor} }
bind .menu1.tkwice <Leave> { .menu1.tkwice configure -background ${background} }

  frame .menu1.separator1 -padx 3 -pady 3
    frame .menu1.separator1.draw -width 2 -borderwidth 2 -relief sunken
  pack .menu1.separator1.draw -side left -fill y -expand true
pack .menu1.separator1 -side left -fill y -expand true

  frame .menu1.2
    button .menu1.2.new_wine -image ${new} -text [::msgcat::mc {New}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 7 -borderwidth 0 -command { new_file_id new }
    button .menu1.2.edit_wine -image $edit -text [::msgcat::mc {Edit}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 7 -borderwidth 0 -state disabled -command { do_selected edit }
    button .menu1.2.edit_group -image ${groupsel} -text [::msgcat::mc {Groups}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 7 -borderwidth 0 -state disabled -command { source [ file join ${prog_dir} tcl groupsel.tcl ] }
    button .menu1.2.consecutively_wine -image $new2 -text [::msgcat::mc {Next Vintage}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 7 -borderwidth 0 -state disabled -command { do_selected sequitur }
    button .menu1.2.delete_wine -image $delete -text [::msgcat::mc {Delete}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 7 -borderwidth 0 -state disabled -command { do_selected delete }
  pack .menu1.2.new_wine .menu1.2.edit_wine .menu1.2.edit_group .menu1.2.consecutively_wine .menu1.2.delete_wine -side left
  bind .menu1.2.new_wine <Enter> { .menu1.2.new_wine configure -background ${lightcolor} }
  bind .menu1.2.new_wine <Leave> { .menu1.2.new_wine configure -background ${background} }
  bind .menu1.2.edit_wine <Enter> { .menu1.2.edit_wine configure -background ${lightcolor} }
  bind .menu1.2.edit_wine <Leave> { .menu1.2.edit_wine configure -background ${background} }
  bind .menu1.2.edit_group <Enter> { .menu1.2.edit_group configure -background ${lightcolor} }
  bind .menu1.2.edit_group <Leave> { .menu1.2.edit_group configure -background ${background} }
  bind .menu1.2.consecutively_wine <Enter> { .menu1.2.consecutively_wine configure -background ${lightcolor} }
  bind .menu1.2.consecutively_wine <Leave> { .menu1.2.consecutively_wine configure -background ${background} }
  bind .menu1.2.delete_wine <Enter> { .menu1.2.delete_wine configure -background ${lightcolor} }
  bind .menu1.2.delete_wine <Leave> { .menu1.2.delete_wine configure -background ${background} }
pack .menu1.2 -side left -expand true

  frame .menu1.separator2 -padx 3 -pady 3
    frame .menu1.separator2.draw -width 2 -borderwidth 2 -relief sunken
  pack .menu1.separator2.draw -side left -fill y -expand true
pack .menu1.separator2 -side left -fill y -expand true

  frame .menu1.4
    menubutton .menu1.4.history -image ${history} -text [::msgcat::mc {History}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 7 -borderwidth 0 -menu .menu1.4.history.menu
    set historymenu [ menu .menu1.4.history.menu -tearoff 1 ]
    ${historymenu} add command -image ${input}  -label " [::msgcat::mc {Shopping}]" -compound left -accelerator {F6} -command { exec ${wish} [ file join ${prog_dir} tcl history.tcl ] ${conffile} hist_in & }
    ${historymenu} add command -image ${output} -label " [::msgcat::mc {Drinking}]" -compound left -accelerator {F7} -command { exec ${wish} [ file join ${prog_dir} tcl history.tcl ] ${conffile} hist_out & }
    button .menu1.4.labelpic -image ${photo} -text [::msgcat::mc {Photo}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 7 -borderwidth 0 -command { source [ file join ${prog_dir} tcl picture.tcl ] }
  pack .menu1.4.history .menu1.4.labelpic -side left
  bind .menu1.4.history <Enter> { .menu1.4.history configure -background ${lightcolor} }
  bind .menu1.4.history <Leave> { .menu1.4.history configure -background ${background} }
  bind .menu1.4.labelpic <Enter> { .menu1.4.labelpic configure -background ${lightcolor} }
  bind .menu1.4.labelpic <Leave> { .menu1.4.labelpic configure -background ${background} }
pack .menu1.4 -side left -expand true

  frame .menu1.separator3 -padx 3 -pady 3
    frame .menu1.separator3.draw -width 2 -borderwidth 2 -relief sunken
  pack .menu1.separator3.draw -side left -fill y -expand true
pack .menu1.separator3 -side left -fill y -expand true

  frame .menu1.3
    frame .menu1.3.search -borderwidth 0
      entry .menu1.3.search.box -textvariable searchstring -highlightthickness 0 -width 16 -relief sunken -background ${lightcolor}
      ::conmen .menu1.3.search.box
      label .menu1.3.search.label -text [::msgcat::mc {Searchstring}] -font ${smallfont} -padx 0 -pady 0 -anchor w
    pack .menu1.3.search.label -side bottom -padx 0 -pady 0 -fill both
    pack .menu1.3.search.box   -side bottom -padx 0 -pady 0 -fill y
    frame .menu1.3.idsearch -borderwidth 0
      entry .menu1.3.idsearch.box -textvariable idsearchstring -highlightthickness 0 -width 6 -relief sunken -background ${lightcolor}
      ::conmen .menu1.3.idsearch.box
      label .menu1.3.idsearch.label -text [::msgcat::mc {Storage}] -font ${smallfont} -padx 0 -pady 0 -anchor w
    pack .menu1.3.idsearch.label -side bottom -padx 0 -pady 0 -fill both
    pack .menu1.3.idsearch.box   -side bottom -padx 0 -pady 0 -fill y
    button .menu1.3.go  -image ${search}   -text [::msgcat::mc {Search}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 2 -borderwidth 0 -state disabled -command { if { [ string length ${searchstring} ] != "0" } { update_winelist } }
    button .menu1.3.clr -image ${searchno} -text [::msgcat::mc {Clear}]  -font ${smallfont} -compound top -relief flat -pady 2 -padx 2 -borderwidth 0 -state disabled -command {
      if { [ string length ${searchstring} ] != {0} || [ string length ${idsearchstring} ] != {0} } {
        set searchstring {}
        set idsearchstring {}
        update_winelist
      }
    }
    bind .menu1.3.search.box <Return> { update_winelist }
    bind .menu1.3.search.box <Escape> {
      set searchstring {}
      update_winelist
    }
    bind . <Control-f> { focus .menu1.3.search.box }
    bind .menu1.3.idsearch.box <Return> { update_winelist }
    bind .menu1.3.idsearch.box <Escape> {
      set idsearchstring {}
      update_winelist
    }
    bind .menu1.3.go <Enter> { .menu1.3.go configure -background ${lightcolor} }
    bind .menu1.3.go <Leave> { .menu1.3.go configure -background ${background} }
    bind .menu1.3.clr <Enter> { .menu1.3.clr configure -background ${lightcolor} }
    bind .menu1.3.clr <Leave> { .menu1.3.clr configure -background ${background} }
  pack .menu1.3.search   -side left -fill y
  pack .menu1.3.idsearch -side left -fill y
  pack .menu1.3.go       -side left
  pack .menu1.3.clr      -side left
pack .menu1.3 -side left -expand true
proc trace_searchstring {} {
  global searchstring idsearchstring
  if { ${searchstring} == {} && ${idsearchstring} == {} } {
    .menu1.3.go  configure -state disabled
    .menu1.3.clr configure -state disabled
  } else {
    .menu1.3.go  configure -state normal
    .menu1.3.clr configure -state normal
  }
}
trace variable searchstring w "trace_searchstring ;#"
trace variable idsearchstring w "trace_searchstring ;#"

  frame .menu1.separator4 -padx 3 -pady 3
    frame .menu1.separator4.draw -width 2 -borderwidth 2 -relief sunken
  pack .menu1.separator4.draw -side left -fill y -expand true
pack .menu1.separator4 -side left -fill y -expand true

  menubutton .menu1.help -image ${help} -text [::msgcat::mc {Help}] -font ${smallfont} -compound top -relief flat -pady 2 -padx 7 -borderwidth 0 -menu .menu1.help.menu
  set helpmenu [ menu .menu1.help.menu -tearoff 1 ]
  ${helpmenu} add command -image ${mphone} -label " [::msgcat::mc {Check Newer Version}]" -compound left -command { source [ file join ${prog_dir} tcl update.tcl ] }
  ${helpmenu} add separator
  ${helpmenu} add command -image ${mlicense} -label " [::msgcat::mc {Copyright}]" -compound left -command { exec ${wish} [ file join ${prog_dir} tcl doc.tcl ] ${conffile} COPYING.html & }
  ${helpmenu} add command -image ${mhelp} -label " [::msgcat::mc {Documentation}]" -compound left -accelerator {F1} -command { exec ${wish} [ file join ${prog_dir} tcl doc.tcl ] ${conffile} index.html & }
pack .menu1.help -side right -pady 0 -padx 0
bind .menu1.help <Enter> { .menu1.help configure -background ${lightcolor} }
bind .menu1.help <Leave> { .menu1.help configure -background ${background} }


# country button bar
frame .menu2 -padx 2 -pady 0
  canvas .menu2.canvas -height [ expr "[ font metrics ${smallfont} -ascent ] + [ font metrics ${smallfont} -descent ]" ] -background ${background} -xscrollcommand ".winelist.filter.scroll set"
  pack   .menu2.canvas -side left -fill x -expand true
  frame .menu2.frame
    button .menu2.frame.0 -text [::msgcat::mc {All}] -padx 7 -pady 0 -font ${smallfont} -relief groove -background ${lightcolor} -borderwidth 2 -command { selectcountry "" 0 }
  pack .menu2.frame.0 -side left
  .menu2.canvas create window 0 0 -window .menu2.frame -anchor nw
grid .menu2 -sticky ewns


# winelist
frame .winelist
if { ${colorname} == {true} } {
  set listlength [ expr "${region_space} + ${name_space} + ${grapes_space} + 26" ]
  tablelist::tablelist .winelist.text -columns "${region_space} [::msgcat::mc {Region}] ${name_space} [::msgcat::mc {Name}] 4 [::msgcat::mc {Year}] 2 [::msgcat::mc {Color}] ${grapes_space} [::msgcat::mc {Grapes}] 4 [::msgcat::mc {Until}] 2 \u2211" -labelbackground ${background} -labelforeground ${textcolor} -labelrelief raised -labelcommand tablelist::sortByColumn -selectmode single -stripebg ${midcolor} -height ${listlines} -width ${listlength} -stretch all -background ${lightcolor} -resizablecolumns false -activestyle none -highlightthickness 0 -exportselection false -labelborderwidth 1 -yscrollcommand [ list .winelist.yscroll set ] -labelcommand { nameindicesget }
} else {
  set colorstringlength [ string length [::msgcat::mc {Red}] ]
  if { [ string length [::msgcat::mc {White}] ]     > ${colorstringlength} } { set colorstringlength [ string length [::msgcat::mc {White}] ] }
  if { [ string length [::msgcat::mc "Ros\u00e9"] ] > ${colorstringlength} } { set colorstringlength [ string length [::msgcat::mc "Ros\u00e9"] ] }
  if { [ string length [::msgcat::mc {Colorless}] ] > ${colorstringlength} } { set colorstringlength [ string length [::msgcat::mc {Colorless}] ] }
  set listlength [ expr "${region_space} + ${name_space} + ${grapes_space} + ${colorstringlength} + 24" ]
  tablelist::tablelist .winelist.text -columns "${region_space} [::msgcat::mc {Region}] ${name_space} [::msgcat::mc {Name}] 4 [::msgcat::mc {Year}] ${colorstringlength} [::msgcat::mc {Color}] ${grapes_space} [::msgcat::mc {Grapes}] 4 [::msgcat::mc {Until}] 2 \u2211" -labelbackground ${background} -labelforeground ${textcolor} -labelrelief raised -labelcommand tablelist::sortByColumn -selectmode single -stripebg ${midcolor} -height ${listlines} -width ${listlength} -stretch all -background ${lightcolor} -resizablecolumns false -activestyle none -highlightthickness 0 -exportselection false -labelborderwidth 1 -yscrollcommand [ list .winelist.yscroll set ] -labelcommand { nameindicesget }
}
if { [ string range ${tablelist_version} 0 [ expr "[ string first {.} ${tablelist_version} ] - 1" ] ] >= {4} } {
  if { [ string range ${tablelist_version} 0 [ expr "[ string first {.} ${tablelist_version} ] - 1" ] ] == {4} && [ string range ${tablelist_version} [ expr "[ string first {.} ${tablelist_version} ] + 1" ] end ] > {2} } {
    .winelist.text configure -setfocus true
  } elseif { [ string range ${tablelist_version} 0 [ expr "[ string first {.} ${tablelist_version} ] - 1" ] ] > {4} } {
    .winelist.text configure -setfocus true
  }
}
.winelist.text columnconfigure 2 -maxwidth 4 -stretchable false
.winelist.text columnconfigure 3 -maxwidth 5 -stretchable false
.winelist.text columnconfigure 5 -maxwidth 4 -stretchable false
.winelist.text columnconfigure 6 -maxwidth 3 -stretchable false -align right
pack .winelist.text -side left -fill both -expand true
if { ${bTtk} } {
	ttk::scrollbar .winelist.yscroll -command { .winelist.text yview } -orient vertical
} else {
	scrollbar .winelist.yscroll -command { .winelist.text yview } -orient vertical
}
pack .winelist.yscroll -side left -fill y
bind [ .winelist.text bodytag ] <Enter> {
  set focusinmainwin {true}
  if { [ string range [ focus ] 0 4 ] == {.conf} }     { set focusinmainwin {false} }
  if { [ string range [ focus ] 0 4 ] == {.info} }     { set focusinmainwin {false} }
  if { [ string range [ focus ] 0 8 ] == {.groupsel} } { set focusinmainwin {false} }
  if { [ string range [ focus ] 0 8 ] == {.groupman} } { set focusinmainwin {false} }
  if { [ string range [ focus ] 0 7 ] == {.picture} }  { set focusinmainwin {false} }
  if { ${focusinmainwin} == {true} } { focus .winelist.text }
}
set theoldfileselection {}
bind [ .winelist.text bodytag ] <ButtonRelease-1> {
  global theoldfileselection
  if { [ catch { set file_id [ .winelist.text rowcget [ .winelist.text curselection ] -name ] } ] == {0} } {
    if { ${theoldfileselection} != [ .winelist.text rowcget [ .winelist.text curselection ] -name ] && [ .winelist.text size ] != {0} } {
      catch { set file_id [ .winelist.text rowcget [ .winelist.text curselection ] -name ] }
      if { ${file_id} != {} } { do_selected select }
      set theoldfileselection ${file_id}
    }
  }
}
bind [ .winelist.text bodytag ] <Double-1> {
  update
  if { [ .winelist.text size ] != {0} && ${file_id} != {} } { do_selected edit }
}
bind [ .winelist.text bodytag ] <Return> {
  if { [ .winelist.text size ] != {0} && ${file_id} != {} } { do_selected edit }
}
bind . <Key-Down> {
  global file_id
  if { [ .winelist.text size ] != {0} } {
    update
    set positionsline [ expr "[ .winelist.text curselection ] + 1" ]
    if { ${positionsline} < [ .winelist.text size ] } {
      .winelist.text selection clear 0 end
      .winelist.text selection set ${positionsline}
      set file_id [ .winelist.text rowcget ${positionsline} -name ]
      do_selected select
    }
  }
}
bind . <Key-Up> {
  global file_id
  if { [ .winelist.text size ] != {0} } {
    update
    set positionsline [ expr "[ .winelist.text curselection ] - 1" ]
    if { ${positionsline} >= {0} } {
      .winelist.text selection clear 0 end
      .winelist.text selection set ${positionsline}
      set file_id [ .winelist.text rowcget ${positionsline} -name ]
      do_selected select
    }
  }
}
bind . <Next> {
  global file_id
  if { [ .winelist.text size ] != {0} } {
    update
    set positionsline [ expr "[ .winelist.text curselection ] + 10" ]
    if { ${positionsline} >= [ .winelist.text size ] } { set  positionsline [ expr "[ .winelist.text size ] - 1" ] }
    if { ${positionsline} < [ .winelist.text size ] } {
      .winelist.text selection clear 0 end
      .winelist.text selection set ${positionsline}
      set file_id [ .winelist.text rowcget ${positionsline} -name ]
      do_selected select
    }
  }
}
bind . <Prior> {
  global file_id
  if { [ .winelist.text size ] != {0} } {
    update
    set positionsline [ expr "[ .winelist.text curselection ] - 10" ]
    if { ${positionsline} < {0} } { set positionsline 0 }
    if { ${positionsline} >= {0} } {
      .winelist.text selection clear 0 end
      .winelist.text selection set ${positionsline}
      set file_id [ .winelist.text rowcget ${positionsline} -name ]
      do_selected select
    }
  }
}
bind . <Key-End> {
  global file_id
  if { [ .winelist.text size ] != {0} } {
    update
    .winelist.text selection clear 0 end
    .winelist.text selection set end
    set file_id [ .winelist.text rowcget end -name ]
    do_selected select
  }
}
bind . <Key-Home> {
  global file_id
  if { [ .winelist.text size ] != {0} } {
    update
    .winelist.text selection clear 0 end
    .winelist.text selection set 0
    set file_id [ .winelist.text rowcget 0 -name ]
    do_selected select
  }
}

menu .winelist.text.contextmenu -tearoff 0
.winelist.text.contextmenu add command -label [::msgcat::mc {New}]          -command { .menu1.2.new_wine invoke }
.winelist.text.contextmenu add separator
.winelist.text.contextmenu add command -label [::msgcat::mc {Edit}]         -command { .menu1.2.edit_wine invoke }
.winelist.text.contextmenu add command -label [::msgcat::mc {Groups}]       -command { .menu1.2.edit_group invoke }
.winelist.text.contextmenu add command -label [::msgcat::mc {Photo}]        -command { .menu1.4.labelpic invoke }
.winelist.text.contextmenu add command -label [::msgcat::mc {Next Vintage}] -command { .menu1.2.consecutively_wine invoke }
.winelist.text.contextmenu add command -label [::msgcat::mc {Delete}]       -command { .menu1.2.delete_wine invoke }
.winelist.text.contextmenu add separator
.winelist.text.contextmenu add command -label [::msgcat::mc {Refresh}]      -command { update_winelist }
bind [ .winelist.text bodytag ] <Button-3> {
  if { [ .menu1.2.edit_wine cget -state ] == {disabled} } {
    .winelist.text.contextmenu entryconfigure 2 -state disabled
    .winelist.text.contextmenu entryconfigure 3 -state disabled
    .winelist.text.contextmenu entryconfigure 4 -state disabled
    .winelist.text.contextmenu entryconfigure 5 -state disabled
    .winelist.text.contextmenu entryconfigure 6 -state disabled
  } else {
    .winelist.text.contextmenu entryconfigure 2 -state normal
    .winelist.text.contextmenu entryconfigure 3 -state normal
    .winelist.text.contextmenu entryconfigure 4 -state normal
    .winelist.text.contextmenu entryconfigure 5 -state normal
    .winelist.text.contextmenu entryconfigure 6 -state normal
  }
  tk_popup .winelist.text.contextmenu %X %Y
}

# filterframe
frame .winelist.filter -padx 0 -pady 0

	if { ${bTtk} } {
  	ttk::scrollbar .winelist.filter.scroll -command { .menu2.canvas xview } -orient horizontal
	} else {
		scrollbar .winelist.filter.scroll -command { .menu2.canvas xview } -orient horizontal
	}

  frame .winelist.filter.show -padx 0 -pady 0 -relief raised -borderwidth 1

    button .winelist.filter.show.available -text [::msgcat::mc {Available}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${filter} == {available} } {
          set filter {none}
          .winelist.filter.show.all1      configure -relief groove -background ${lightcolor}
          .winelist.filter.show.available configure -relief flat   -background ${background}
        } else {
          .winelist.filter.show.available configure -relief groove -background ${lightcolor}
          .winelist.filter.show.try       configure -relief flat   -background ${background}
          .winelist.filter.show.retry     configure -relief flat   -background ${background}
          .winelist.filter.show.drink     configure -relief flat   -background ${background}
          .winelist.filter.show.wait      configure -relief flat   -background ${background}
          .winelist.filter.show.new       configure -relief flat   -background ${background}
          .winelist.filter.show.all1      configure -relief flat   -background ${background}
          set filter {available}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.try -text [::msgcat::mc {To Try}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${filter} == {try} } {
          set filter {none}
          .winelist.filter.show.all1      configure -relief groove -background ${lightcolor}
          .winelist.filter.show.try       configure -relief flat   -background ${background}
        } else {
          .winelist.filter.show.available configure -relief flat   -background ${background}
          .winelist.filter.show.try       configure -relief groove -background ${lightcolor}
          .winelist.filter.show.retry     configure -relief flat   -background ${background}
          .winelist.filter.show.drink     configure -relief flat   -background ${background}
          .winelist.filter.show.wait      configure -relief flat   -background ${background}
          .winelist.filter.show.new       configure -relief flat   -background ${background}
          .winelist.filter.show.all1      configure -relief flat   -background ${background}
          set filter {try}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.retry -text [::msgcat::mc {Retry}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${filter} == {retry} } {
          set filter {none}
          .winelist.filter.show.all1      configure -relief groove -background ${lightcolor}
          .winelist.filter.show.retry     configure -relief flat   -background ${background}
        } else {
          .winelist.filter.show.available configure -relief flat   -background ${background}
          .winelist.filter.show.try       configure -relief flat   -background ${background}
          .winelist.filter.show.retry     configure -relief groove -background ${lightcolor}
          .winelist.filter.show.drink     configure -relief flat   -background ${background}
          .winelist.filter.show.wait      configure -relief flat   -background ${background}
          .winelist.filter.show.new       configure -relief flat   -background ${background}
          .winelist.filter.show.all1      configure -relief flat   -background ${background}
          set filter {retry}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.drink -text [::msgcat::mc {Drinkable}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${filter} == {drink} } {
          set filter {none}
          .winelist.filter.show.all1      configure -relief groove -background ${lightcolor}
          .winelist.filter.show.drink     configure -relief flat   -background ${background}
        } else {
          .winelist.filter.show.available configure -relief flat   -background ${background}
          .winelist.filter.show.try       configure -relief flat   -background ${background}
          .winelist.filter.show.retry     configure -relief flat   -background ${background}
          .winelist.filter.show.drink     configure -relief groove -background ${lightcolor}
          .winelist.filter.show.wait      configure -relief flat   -background ${background}
          .winelist.filter.show.new       configure -relief flat   -background ${background}
          .winelist.filter.show.all1      configure -relief flat   -background ${background}
          set filter {drink}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.wait -text [::msgcat::mc {Wait}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${filter} == {wait} } {
          set filter {none}
          .winelist.filter.show.all1      configure -relief groove -background ${lightcolor}
          .winelist.filter.show.wait      configure -relief flat   -background ${background}
        } else {
          .winelist.filter.show.available configure -relief flat   -background ${background}
          .winelist.filter.show.try       configure -relief flat   -background ${background}
          .winelist.filter.show.retry     configure -relief flat   -background ${background}
          .winelist.filter.show.drink     configure -relief flat   -background ${background}
          .winelist.filter.show.wait      configure -relief groove -background ${lightcolor}
          .winelist.filter.show.new       configure -relief flat   -background ${background}
          .winelist.filter.show.all1      configure -relief flat   -background ${background}
          set filter {wait}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.new -text [::msgcat::mc {Modified}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${filter} == {new} } {
          set filter {none}
          .winelist.filter.show.all1      configure -relief groove -background ${lightcolor}
          .winelist.filter.show.new       configure -relief flat   -background ${background}
        } else {
          .winelist.filter.show.available configure -relief flat   -background ${background}
          .winelist.filter.show.try       configure -relief flat   -background ${background}
          .winelist.filter.show.retry     configure -relief flat   -background ${background}
          .winelist.filter.show.drink     configure -relief flat   -background ${background}
          .winelist.filter.show.wait      configure -relief flat   -background ${background}
          .winelist.filter.show.new       configure -relief groove -background ${lightcolor}
          .winelist.filter.show.all1      configure -relief flat   -background ${background}
          set filter {new}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.all1 -text [::msgcat::mc {All}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${filter} != {none} } {
          .winelist.filter.show.available configure -relief flat   -background ${background}
          .winelist.filter.show.try       configure -relief flat   -background ${background}
          .winelist.filter.show.retry     configure -relief flat   -background ${background}
          .winelist.filter.show.drink     configure -relief flat   -background ${background}
          .winelist.filter.show.wait      configure -relief flat   -background ${background}
          .winelist.filter.show.new       configure -relief flat   -background ${background}
          .winelist.filter.show.all1      configure -relief groove -background ${lightcolor}
          set filter {none}
          update_winelist
        }
      }
    }

    frame .winelist.filter.show.separator1 -padx 3 -pady 2
      frame .winelist.filter.show.separator1.draw -height 2 -borderwidth 2 -relief sunken
    pack .winelist.filter.show.separator1.draw -side top -fill x -expand true

    button .winelist.filter.show.red -text [::msgcat::mc {Red}] -activebackground {#a31000} -activeforeground {#ffffff} -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { $red == {on} && $white == {off} && $rose == {off} } {
          set white {on}
          set rose {on}
          .winelist.filter.show.red   configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.white configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.rose  configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.all2  configure -relief groove -background ${lightcolor}
        } else {
          set red {on}
          set white {off}
          set rose {off}
          .winelist.filter.show.red   configure -relief groove -background {#a31000}     -foreground {#ffffff}
          .winelist.filter.show.white configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.rose  configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.all2  configure -relief flat   -background ${background}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.white -text [::msgcat::mc {White}] -activebackground {#fff88f} -activeforeground {#000000} -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { $red == {off} && $white == {on} && $rose == {off} } {
          set red {on}
          set rose {on}
          .winelist.filter.show.red   configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.white configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.rose  configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.all2  configure -relief groove -background ${lightcolor}
        } else {
          set red {off}
          set white {on}
          set rose {off}
          .winelist.filter.show.red   configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.white configure -relief groove -background {#fff88f}     -foreground {#000000}
          .winelist.filter.show.rose  configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.all2  configure -relief flat   -background ${background}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.rose -text [::msgcat::mc "Ros\u00e9"] -activebackground {#ffa091} -activeforeground {#000000} -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { $red == {off} && $white == {off} && $rose == {on} } {
          set red {on}
          set white {on}
          .winelist.filter.show.red   configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.white configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.rose  configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.all2  configure -relief groove -background ${lightcolor}
        } else {
          set red {off}
          set white {off}
          set rose {on}
          .winelist.filter.show.red   configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.white configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.rose  configure -relief groove -background {#ffa091}     -foreground {#000000}
          .winelist.filter.show.all2  configure -relief flat   -background ${background}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.all2 -text [::msgcat::mc {All}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { $red != {on} || $white != {on} || $rose != {on} } {
          set red {on}
          set white {on}
          set rose {on}
          .winelist.filter.show.red   configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.white configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.rose  configure -relief flat   -background ${background} -foreground {#000000}
          .winelist.filter.show.all2  configure -relief groove -background ${lightcolor}
          update_winelist
	  		}
      }
    }

    frame .winelist.filter.show.separator2 -padx 3 -pady 2
      frame .winelist.filter.show.separator2.draw -height 2 -borderwidth 2 -relief sunken
    pack .winelist.filter.show.separator2.draw -side top -fill x -expand true

    button .winelist.filter.show.still -text [::msgcat::mc {Still}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${showtype} == {Still} } {
          set showtype {All Types}
          .winelist.filter.show.all3      configure -relief groove -background ${lightcolor}
          .winelist.filter.show.still     configure -relief flat   -background ${background}
        } else {
          .winelist.filter.show.still     configure -relief groove -background ${lightcolor}
          .winelist.filter.show.frizzante configure -relief flat   -background ${background}
          .winelist.filter.show.sparkling configure -relief flat   -background ${background}
          .winelist.filter.show.all3      configure -relief flat   -background ${background}
          set showtype {Still}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.frizzante -text [::msgcat::mc {Frizzante}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${showtype} == {Frizzante} } {
          set showtype {All Types}
          .winelist.filter.show.all3      configure -relief groove -background ${lightcolor}
          .winelist.filter.show.frizzante configure -relief flat   -background ${background}
        } else {
          .winelist.filter.show.still     configure -relief flat   -background ${background}
          .winelist.filter.show.frizzante configure -relief groove -background ${lightcolor}
          .winelist.filter.show.sparkling configure -relief flat   -background ${background}
          .winelist.filter.show.all3      configure -relief flat   -background ${background}
          set showtype {Frizzante}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.sparkling -text [::msgcat::mc {Sparkling}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${showtype} == {Sparkling} } {
          set showtype {All Types}
          .winelist.filter.show.all3      configure -relief groove -background ${lightcolor}
          .winelist.filter.show.sparkling configure -relief flat   -background ${background}
        } else {
          .winelist.filter.show.still     configure -relief flat   -background ${background}
          .winelist.filter.show.frizzante configure -relief flat   -background ${background}
          .winelist.filter.show.sparkling configure -relief groove -background ${lightcolor}
          .winelist.filter.show.all3      configure -relief flat   -background ${background}
          set showtype {Sparkling}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.all3 -text [::msgcat::mc {All}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${showtype} != {All Types} } {
          set showtype {All Types}
          .winelist.filter.show.still     configure -relief flat   -background ${background}
          .winelist.filter.show.frizzante configure -relief flat   -background ${background}
          .winelist.filter.show.sparkling configure -relief flat   -background ${background}
          .winelist.filter.show.all3      configure -relief groove -background ${lightcolor}
          update_winelist
        }
      }
    }

    frame .winelist.filter.show.separator3 -padx 3 -pady 2
      frame .winelist.filter.show.separator3.draw -height 2 -borderwidth 2 -relief sunken
    pack .winelist.filter.show.separator3.draw -side top -fill x -expand true

    button .winelist.filter.show.bio -text [::msgcat::mc {Bio}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${showbio} == {all} } {
          set showbio {bio}
          .winelist.filter.show.bio  configure -relief groove -background ${lightcolor}
          .winelist.filter.show.all4 configure -relief flat   -background ${background}
        } else {
          set showbio {all}
          .winelist.filter.show.bio  configure -relief flat   -background ${background}
          .winelist.filter.show.all4 configure -relief groove -background ${lightcolor}
        }
        update_winelist
      }
    }
    button .winelist.filter.show.all4 -text [::msgcat::mc {All}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
      if { ${locked} != {true} } {
        if { ${showbio} == {bio} } {
          set showbio {all}
          .winelist.filter.show.bio  configure -relief flat   -background ${background}
          .winelist.filter.show.all4 configure -relief groove -background ${lightcolor}
          update_winelist
        }
      }
    }

    frame .winelist.filter.show.separator4 -padx 3 -pady 2
      frame .winelist.filter.show.separator4.draw -height 2 -borderwidth 2 -relief sunken
    pack .winelist.filter.show.separator4.draw -side top -fill x -expand true

    set grouplabelwidth [ string length [::msgcat::mc {Available}] ]
    if { [ string length [::msgcat::mc {To Try}] ]    > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {To Try}] ] }
    if { [ string length [::msgcat::mc {Retry}] ]     > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {Retry}] ] }
    if { [ string length [::msgcat::mc {Drinkable}] ] > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {Drinkable}] ] }
    if { [ string length [::msgcat::mc {Wait}] ]      > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {Wait}] ] }
    if { [ string length [::msgcat::mc {Modified}] ]  > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {Modified}] ] }
    if { [ string length [::msgcat::mc {All}] ]       > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {All}] ] }
    if { [ string length [::msgcat::mc {Red}] ]       > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {Red}] ] }
    if { [ string length [::msgcat::mc {White}] ]     > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {White}] ] }
    if { [ string length [::msgcat::mc "Ros\u00e9"] ] > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc "Ros\u00e9"] ] }
    if { [ string length [::msgcat::mc {Still}] ]     > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {Still}] ] }
    if { [ string length [::msgcat::mc {Frizzante}] ] > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {Frizzante}] ] }
    if { [ string length [::msgcat::mc {Sparkling}] ] > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {Sparkling}] ] }
    if { [ string length [::msgcat::mc {Bio}] ]       > ${grouplabelwidth} } { set grouplabelwidth [ string length [::msgcat::mc {Bio}] ] }
    menubutton .winelist.filter.show.group -text [::msgcat::mc {Group}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -width ${grouplabelwidth} -menu .winelist.filter.show.group.menu
    # group-file
    proc writegroupfile {} {
      # new blank file
      global groupfile grouplist
      set initchannel [ open ${groupfile} w ]
      puts ${initchannel} ${grouplist}
      close ${initchannel}
    }
    set groupfile [ file join ${datadir} groups ]
    if { [ file exists ${groupfile} ] == {0} } {
      set grouplist {}
      writegroupfile
    }
    # read groupfile per line and build grouplist
    set initchannel [ open ${groupfile} r ]
    foreach line [ split [ read ${initchannel} ] \n ] {
      if { ${line} != {} } { lappend grouplist ${line} }
    }
    close ${initchannel}
    # do something if group selected
    proc groupmenuexec {selection} {
      global locked showgroup background lightcolor
      if { ${locked} != {true} && ${showgroup} != ${selection} } {
        set showgroup ${selection}
        .winelist.filter.show.group configure -relief groove -background ${lightcolor} -text ${selection}
        .winelist.filter.show.all5  configure -relief flat   -background ${background}
        update_winelist
      }
    }
    # update the group menu
    proc addmenugroups {} {
      global groupmenu grouplist datadir
      set grouplist [ lsort -dictionary ${grouplist} ]
      if { [winfo exists .winelist.filter.show.group.menu ] } { destroy .winelist.filter.show.group.menu }
      set groupmenu [ menu .winelist.filter.show.group.menu -tearoff 0 ]
      set grouplistnames {}
      if { [ llength ${grouplist} ] > 0 } {
        foreach groupname ${grouplist} {
          lappend grouplistnames [ lindex ${groupname} 0 ]
        }
        foreach groupname2 ${grouplistnames} {
          ${groupmenu} add command -label ${groupname2} -command "groupmenuexec \"$groupname2\""
        }
        ${groupmenu} add separator
        ${groupmenu} add command -label [::msgcat::mc {none}] -command { .winelist.filter.show.all5 invoke }
        ${groupmenu} add separator
      }
      ${groupmenu} add command -label [::msgcat::mc {Group Manager}] -command { source [ file join ${prog_dir} tcl groupman.tcl ] }
    }
    # fill menu up first time
    addmenugroups
    button .winelist.filter.show.all5 -text [::msgcat::mc {All}] -padx 1 -pady 0 -borderwidth 2 -font ${smallfont} -command {
     if { ${locked} != {true} && ${showgroup} != {} } {
        set showgroup {}
        .winelist.filter.show.group configure -relief flat   -background ${background} -text [::msgcat::mc {Group}]
        .winelist.filter.show.all5  configure -relief groove -background ${lightcolor}
        update_winelist
      }
    }

  frame .winelist.filter.show.separator5

  set pic [ image create photo -width 75 -height 125 ]
  button .winelist.filter.show.pic -image ${pic} -width 75 -height 125 -padx 2 -pady 2 -anchor nw -relief flat -overrelief flat -borderwidth 0 -highlightthickness 0 -command { .menu1.4.labelpic invoke }

  pack .winelist.filter.show.available .winelist.filter.show.try .winelist.filter.show.retry .winelist.filter.show.drink .winelist.filter.show.wait .winelist.filter.show.new .winelist.filter.show.all1 .winelist.filter.show.separator1 .winelist.filter.show.red .winelist.filter.show.white .winelist.filter.show.rose .winelist.filter.show.all2 .winelist.filter.show.separator2 .winelist.filter.show.still .winelist.filter.show.frizzante .winelist.filter.show.sparkling .winelist.filter.show.all3 .winelist.filter.show.separator3 .winelist.filter.show.bio .winelist.filter.show.all4 .winelist.filter.show.separator4 .winelist.filter.show.group .winelist.filter.show.all5 -side top -fill x
  pack .winelist.filter.show.separator5 -side top -fill both -expand true
  pack .winelist.filter.show.pic -side top


# pack filterframe together
grid .winelist.filter.scroll -sticky new  -padx 0 -pady 0
grid .winelist.filter.show   -sticky news -padx 0 -pady 0
grid rowconfigure .winelist.filter 1 -weight 1
pack .winelist.filter -side right -anchor n -fill both


# infobar
label .infobar -anchor w -borderwidth 0 -padx 5 -pady 2


# statusbar
label .statusbar -borderwidth 0 -padx 5 -pady 0
statusbar


# progressbar
frame .progressbar -height 4


# pack all together
pack .menu1       -fill x    -expand false -side top
pack .menu2       -fill x    -expand false -side top
pack .winelist    -fill both -expand true  -side top
pack .infobar     -fill x    -expand false -side top
pack .statusbar   -fill x    -expand false -side top
pack .progressbar -fill x    -expand false -side top


# some cosmetics ...
.winelist.filter.show.available configure -relief groove -background ${lightcolor}
.winelist.filter.show.try       configure -relief flat
.winelist.filter.show.retry     configure -relief flat
.winelist.filter.show.drink     configure -relief flat
.winelist.filter.show.wait      configure -relief flat
.winelist.filter.show.new       configure -relief flat
.winelist.filter.show.all1      configure -relief flat
.winelist.filter.show.red       configure -relief flat
.winelist.filter.show.white     configure -relief flat
.winelist.filter.show.rose      configure -relief flat
.winelist.filter.show.all2      configure -relief groove -background ${lightcolor}
.winelist.filter.show.still     configure -relief flat
.winelist.filter.show.frizzante configure -relief flat
.winelist.filter.show.sparkling configure -relief flat
.winelist.filter.show.all3      configure -relief groove -background ${lightcolor}
.winelist.filter.show.bio       configure -relief flat
.winelist.filter.show.all4      configure -relief groove -background ${lightcolor}
.winelist.filter.show.group     configure -relief flat
.winelist.filter.show.all5      configure -relief groove -background ${lightcolor}


# update position if necessary
tkwait visibility .
if { ${centerx} == {true} || ${centery} == {true} } {
  set ulcx3 ${ulcx}
  set ulcy3 ${ulcy}
  if { ${centerx} == {true} } { set ulcx3 [ expr "( [ winfo screenwidth  . ] - [ winfo width  . ] ) / 2" ] }
  if { ${centery} == {true} } { set ulcy3 [ expr "( [ winfo screenheight . ] - [ winfo height . ] ) / 2" ] }
  wm geometry . +${ulcx3}+${ulcy3}
}


# tracings
set theoldfileid {}
proc trace_file_id {} {
  global pic file_id datadir labelpic img_version theoldfileid
  if { ${theoldfileid} != ${file_id} } {
    if { [ winfo exists .picture ]  } { .menu1.4.labelpic invoke }
    if { [ winfo exists .groupsel ] } { destroy .groupsel }
    # update small pic preview
    $pic blank
		# image delete $pic
    if { ${file_id} != {} } {
      if { ${img_version} != {false} && [ file exists [ file join ${datadir} ${labelpic} ${file_id}.jpg ] ] } {
        set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.jpg ] -width 300 -height 500 ]
        $pic copy ${pic2} -subsample 4 4
      } elseif { ${img_version} != {false} && [ file exists [ file join ${datadir} ${labelpic} ${file_id}.JPG ] ] } {
        set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.JPG ] -width 300 -height 500 ]
        $pic copy ${pic2} -subsample 4 4
      } elseif { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.gif ] ] } {
        set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.gif ] -width 300 -height 500 ]
        $pic copy ${pic2} -subsample 4 4
      } elseif { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.GIF ] ] } {
        set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.GIF ] -width 300 -height 500 ]
        $pic copy ${pic2} -subsample 4 4
      }
      .winelist.filter.show.pic configure -image ${pic}
			# please no memory leaks ...
			if { [ info exists pic2 ] } {
				image delete $pic2
			}
    }
    set theoldfileid ${file_id}
  }
}
trace variable file_id w "trace_file_id ;#"


# some global bindings
bind . <KeyPress-F1> { exec ${wish} [ file join ${prog_dir} tcl doc.tcl ] ${conffile} index.html & }
bind . <KeyPress-F2> { .menu1.2.new_wine invoke }
bind . <KeyPress-F3> { if { ${locked} != {true} } { update_winelist } }
bind . <Control-Key-r> { if { ${locked} != {true} } { update_winelist } }
bind . <KeyPress-F4> { if { ${file_id} != {} } { .menu1.2.edit_wine invoke } }
bind . <KeyPress-F5> { if { ${file_id} != {} } { .menu1.2.consecutively_wine invoke } }
bind . <KeyPress-F6> { exec ${wish} [ file join ${prog_dir} tcl history.tcl ] ${conffile} hist_in & }
bind . <KeyPress-F7> { exec ${wish} [ file join ${prog_dir} tcl history.tcl ] ${conffile} hist_out & }
bind . <KeyPress-F8> { if { ${file_id} != {} } { .menu1.2.delete_wine invoke } }
bind . <KeyPress-F9> { .menu1.4.labelpic invoke }
bind . <KeyPress-F10> { exit }
bind . <Control-Key-q> { exit }
bind [ .winelist.text bodytag ] <KeyPress-Delete>  { if { ${file_id} != {} } { .menu1.2.delete_wine invoke } }
bind . <Control-Key-g> { .menu1.2.edit_group invoke }

# update countrybuttons size and scrollbar
update
.menu2.canvas configure -height [ winfo reqheight .menu2.frame ] -scrollregion "0 0 [ winfo reqwidth .menu2.frame ] 0"
.winelist.filter.scroll configure -command { .menu2.canvas xview }

# fill listbox with database and init infobar
update_winelist
.infobar configure -text "[::msgcat::mc {Storage -- database}] \u00BB[ file nativename ${datadir} ]\u00AB -- [::msgcat::mc {program}] \u00BB[ file nativename ${prog_dir} ]\u00AB -- Version \u00BB${version}.${patchlevel}\u00AB"

# delete placeholder and add country buttons
getcountries init


# inform the user if dabase name changed
if { ${updated_db} == {yes} } {
  set infotitle {Database Update}
  set infotext  "Renamed database directory to:\n[ file nativename ${datadir} ]"
  set infotype  {info}
  source [ file join ${prog_dir} tcl info.tcl ]
}
