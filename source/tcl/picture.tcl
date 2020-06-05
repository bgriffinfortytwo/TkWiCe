# picture viewer / browser

# startup only if window does not exist
if { [ winfo exists .picture ] } {

  # if file_id has not changed, raise window ...
  if { ${shown_file_id} == ${file_id} } {
    raise .picture .
  } else {

	  # okay, show up new file
    $pic500 blank
    $pic250 blank
    $pic125 blank
    if { ${file_id} != {} } {
      if { ${img_version} != {false} && [ file exists [ file join ${datadir} ${labelpic} ${file_id}.jpg ] ] } {
        set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.jpg ] -width 300 -height 500 ]
        $pic500 copy $pic2 -subsample 1 1
        $pic250 copy $pic2 -subsample 2 2
        $pic125 copy $pic2 -subsample 4 4
      } elseif { ${img_version} != {false} && [ file exists [ file join ${datadir} ${labelpic} ${file_id}.JPG ] ] } {
        set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.JPG ] -width 300 -height 500 ]
        $pic500 copy $pic2 -subsample 1 1
        $pic250 copy $pic2 -subsample 2 2
        $pic125 copy $pic2 -subsample 4 4
      } elseif { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.gif ] ] } {
        set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.gif ] -width 300 -height 500 ]
        $pic500 copy $pic2 -subsample 1 1
        $pic250 copy $pic2 -subsample 2 2
        $pic125 copy $pic2 -subsample 4 4
      } elseif { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.GIF ] ] } {
        set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.GIF ] -width 300 -height 500 ]
        $pic500 copy $pic2 -subsample 1 1
        $pic250 copy $pic2 -subsample 2 2
        $pic125 copy $pic2 -subsample 4 4
      }
    }
    if { ${scale} == {1} } {
      .picture.picture configure -image $pic500
    } elseif { ${scale} == {2} } {
      .picture.picture configure -image $pic250
    } elseif { ${scale} == {4} } {
      .picture.picture configure -image $pic125
    }
    set shown_file_id ${file_id}
		
		# please no memory leaks ...
		if { [ info exists pic2 ] } {
			catch { image delete $pic2 }
		}
		
  }
	
} else {
	
  # restore filenumber - needed for browser-mode
  if { [ info exists file_id ] } {
    set shown_file_id ${file_id}
  } else {
    set shown_file_id {none}
  }

  # window stuff
  toplevel     .picture
  wm title     .picture "TkWiCe [::msgcat::mc {Photo}]"
  wm resizable .picture false false
  focus        .picture

  # set up button graphics
  set imgsave  [ image create photo -file [ file join ${prog_dir} img imgsave.gif ] ]
  set imgdel   [ image create photo -file [ file join ${prog_dir} img delete2.gif ] ]
  set imgclose [ image create photo -file [ file join ${prog_dir} img close.gif ] ]
  set imgblank [ image create photo -width 16 -height 16 ]

  # setup default scale
  if { [ file exists [ file join ${datadir} label.ini ] ] } {
    set readchannel [ open [ file join ${datadir} label.ini ] r ]
    set scale [ read ${readchannel} ]
    close ${readchannel}
    set scale [ string trimright ${scale} ]
  }
  if { ! [ info exists scale ] } { set scale {1} }

  # load Img if available
  set img_version {false}
  catch { set img_version [ package require Img ] }
  if { ${img_version} != {false} } {
    set types {
      { "Images" {.jpg .png .xpm .bmp .gif .pgm .ppm .PPM .PGM .GIF .BMP .XPM .PNG .JPG .jpeg .JPEG} }
      { "Images" {} {JPEG PNGF TIFF GIFF} }
      { "JPEG" {.jpg .JPG .jpeg .JPEG} }
      { "JPEG" {} {JPEG} }
      { "PNG" {.png .PNG} }
      { "PNG" {} {PNGF} }
      { "TIFF" {.tif .TIF .tiff .TIFF} }
      { "TIFF" {} {TIFF} }
      { "XPM" {.xpm .XPM} }
      { "BMP" {.bmp .BMP} }
      { "GIF" {.gif .GIF} }
      { "GIF" {} {GIFF} }
      { "PGM" {.pgm .PGM} }
      { "PPM" {.ppm .PPM} }
    }
  } else {
    set types {
      { "Images" {.gif .pgm .ppm .PPM .PGM .GIF} }
      { "Images" {} {GIFF} }
      { "GIF" {.gif .GIF} }
      { "GIF" {} {GIFF} }
      { "PGM" {.pgm .PGM} }
      { "PPM" {.ppm .PPM} }
    }
  }
  # initalize graphic vars with blank pic
  set pic500 [ image create photo -width 300 -height 500 ]
  set pic250 [ image create photo -width 150 -height 250 ]
  set pic125 [ image create photo -width  75 -height 125 ]
  set pic2 [ image create photo -width 300 -height 500 ]
  set pic3 [ image create photo -width 100 -height 166 ]
  # overwrite if correspondig graphic exist ....
  set startwithopendialog {false}
  if { ${img_version} != {false} && [ file exists [ file join ${datadir} ${labelpic} ${file_id}.jpg ] ] } {
    set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.jpg ] -width 300 -height 500 ]
  } elseif { ${img_version} != {false} && [ file exists [ file join ${datadir} ${labelpic} ${file_id}.JPG ] ] } {
    set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.JPG ] -width 300 -height 500 ]
  } elseif { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.gif ] ] } {
    set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.gif ] -width 300 -height 500 ]
  } elseif { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.GIF ] ] } {
    set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.GIF ] -width 300 -height 500 ]
  } else {
    if { [ winfo exists .editleft.1.picture.pic ] } { set startwithopendialog {true} }
  }
  # scale it
  if { ${scale} == {1} } {
    $pic500 copy $pic2 -subsample 1 1
  } elseif { ${scale} == {2} } {
    $pic250 copy $pic2 -subsample 2 2
  } elseif { ${scale} == {4} } {
    $pic125 copy $pic2 -subsample 4 4
  }

  # window
  frame .picture.menu -relief raised -borderwidth 2 -padx 0 -pady 0
    menubutton .picture.menu.menu -text [::msgcat::mc {Menu}] -font ${titlefont} -relief flat -borderwidth 0 -padx 3 -pady 1 -menu .picture.menu.menu.menu
      set picturemenu [ menu .picture.menu.menu.menu -tearoff 0 ]
      ${picturemenu} add command -image ${imgblank} -label " [::msgcat::mc {Open}]" -compound left -accelerator {F3} -command {
        if { ! [ info exists picopenpath ] } { set picopenpath "~" }
        set file {}
        set file [ tk_getOpenFile -initialdir ${picopenpath} -parent .picture -title [::msgcat::mc {Open}] -filetypes ${types} ]
        if { [ file exists ${file} ] } {
          set pic2   [ image create photo -file ${file} -width 300 -height 500 ]
          set pic500 [ image create photo -file ${file} ]
          set image_width  [ image width  $pic500 ]
          set image_height [ image height $pic500 ]
          set y_start  {0}
          set y_end    {500}
          set x_start  {0}
          set x_end    {300}
          set y2_start {0}
          set y2_end   {500}
          set x2_start {0}
          set x2_end   {300}
          # resize with ImageMagick if available and necessary
          if { ${image_width} > {300} || ${image_height} > {500} } {
            if { $tcl_platform(platform) == {unix} && [ auto_execok convert ] != {} && ${img_version} != {false} } {
              set convert [ auto_execok convert ]
              set tmp_image [ file join [ file nativename ${datadir} ] tmp.jpg ]
              eval exec "${convert} ${file} -geometry 300x500 ${tmp_image}"
              set file ${tmp_image}
              $pic500 blank
              $pic250 blank
              $pic125 blank
              $pic2 blank
              set pic2   [ image create photo -file ${file} -width 300 -height 500 ]
              set pic500 [ image create photo -file ${file} ]
		          set image_width  [ image width  $pic500 ]
              set image_height [ image height $pic500 ]
            }
          }
          # crop if necessary
          if { ${image_width} > {300} } {
            set x_start [ expr "(${image_width}  - 300) / 2" ]
            set x_end   [ expr "${x_start} + 300" ]
          }
          if { ${image_height} > {500} } {
            set y_start [ expr "(${image_height} - 500) / 2" ]
            set y_end   [ expr "${y_start} + 500" ]
          }
          if { ${image_height} < {500} } {
            set y_end ${image_height}
            set y2_start [ expr "(500 - ${image_height}) / 2" ]
            set y2_end   [ expr "${y2_start} + ${image_height}" ]
          }
          if { ${image_width} < {300} } {
            set x_end ${image_width}
            set x2_start [ expr "(300 - ${image_width}) / 2" ]
            set x2_end   [ expr "${x2_start} + ${image_width}" ]
          }
          $pic2 blank
          $pic2 copy $pic500 -from ${x_start} ${y_start} ${x_end} ${y_end} -to ${x2_start} ${y2_start} ${x2_end} ${y2_end}
          $pic500 blank
          $pic250 blank
          $pic125 blank
          if { ${scale} == {1} } {
            $pic500 copy $pic2 -subsample 1 1  -from 0 0 300 500 -to 0 0 300 500 -shrink
            .picture.picture configure -image $pic500 -width 300 -height 500
          } elseif { ${scale} == {2} } {
            $pic250 copy $pic2 -subsample 2 2  -from 0 0 300 500 -to 0 0 150 250 -shrink
            .picture.picture configure -image $pic250 -width 150 -height 250
          } elseif { ${scale} == {4} } {
            $pic125 copy $pic2 -subsample 4 4  -from 0 0 300 500 -to 0 0 75 125 -shrink
            .picture.picture configure -image $pic125 -width 75 -height 125
          }
          .picture.menu.save configure -state normal
        }
      }
      ${picturemenu} add cascade -image ${imgdel} -label " [::msgcat::mc {Delete}]" -compound left -menu .picture.menu.menu.delete
        set deletemenu [ menu .picture.menu.menu.delete -tearoff 0 ]
        ${deletemenu} add command -label [::msgcat::mc {Confirm}] -command {
          if { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.jpg  ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_id}.jpg  ] }
          if { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.jpeg ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_id}.jpeg ] }
          if { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.JPG  ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_id}.JPG  ] }
          if { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.JPEG ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_id}.JPEG ] }
          if { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.gif  ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_id}.gif  ] }
          if { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.GIF  ] ] } { file delete [ file join ${datadir} ${labelpic} ${file_id}.GIF  ] }
          if { [ winfo exists .editleft.1.picture.pic ] } {
            set picture [ image create photo -file [ file join ${prog_dir} img nop.gif ] -width 100 -height 166 ]
            .editleft.1.picture.pic configure -image $picture
          }
          if { [ winfo exists .winelist.filter.show.pic ] } {
            $pic blank
            .winelist.filter.show.pic configure -image $pic
          }
          $pic2 blank
          $pic500 blank
          $pic250 blank
          $pic125 blank
          .picture.menu.save configure -state disabled
          if { [ winfo exists .winelist.filter.show.pic ] } { trace_file_id }
          # update the last modified time stamp
          if { ${file_id} != {} && [ file exists [ file join ${datadir} ${database} ${file_id} ] ] } {
            set initchannel [ open [ file join ${datadir} ${database} ${file_id} ] a ]
            puts ${initchannel} "set last_modified_secondsdate \{[ clock seconds ]\}"
            close ${initchannel}
          }
        }
        ${picturemenu} add cascade -image ${imgblank} -label " [::msgcat::mc {Zoom}]" -compound left -menu .picture.menu.menu.scale
        set scalemenu [ menu .picture.menu.menu.scale -tearoff 0 ]
        ${scalemenu} add radiobutton -label {300x500} -variable scale -value 1 -selectcolor ${textcolor} -accelerator {++} -command {
          $pic500 blank
          $pic250 blank
          $pic125 blank
          $pic500 copy $pic2 -subsample 1 1 -from 0 0 300 500 -to 0 0 300 500 -shrink
          .picture.picture configure -image $pic500 -width 300 -height 500
          set scalechannel [ open [ file join ${datadir} label.ini ] w ]
          puts ${scalechannel} {1}
          close ${scalechannel}
          .picture.menu.save configure -text [::msgcat::mc {Save}] -font ${smallfont} -compound left -pady 2 -padx 7
        }
        ${scalemenu} add radio -label {150x250} -variable scale -value 2 -selectcolor ${textcolor} -accelerator {+/-} -command {
          $pic500 blank
          $pic250 blank
          $pic125 blank
          $pic250 copy $pic2 -subsample 2 2 -from 0 0 300 500 -to 0 0 150 250 -shrink
          .picture.picture configure -image $pic250 -width 150 -height 250
          set scalechannel [ open [ file join ${datadir} label.ini ] w ]
          puts ${scalechannel} {2}
          close ${scalechannel}
          .picture.menu.save configure -text [::msgcat::mc {Save}] -font ${smallfont} -compound left -pady 2 -padx 7
        }
        ${scalemenu} add radio -label {75x125} -variable scale -value 4 -selectcolor ${textcolor} -accelerator {--} -command {
          $pic500 blank
          $pic250 blank
          $pic125 blank
          $pic125 copy $pic2 -subsample 4 4 -from 0 0 300 500 -to 0 0 75 125 -shrink
          .picture.picture configure -image $pic125 -width  75 -height 125
          set scalechannel [ open [ file join ${datadir} label.ini ] w ]
          puts ${scalechannel} {4}
          close ${scalechannel}
          .picture.menu.save configure -text {} -compound none -pady 2 -padx 7
        }
      ${picturemenu} add separator
      ${picturemenu} add command -image ${imgclose} -label " [::msgcat::mc {Close}]" -compound left -accelerator {Qtrl+Q} -command { destroy .picture }
    frame .picture.menu.separator1 -padx 3 -pady 3
      frame .picture.menu.separator1.draw -width 2 -borderwidth 2 -relief sunken
    pack .picture.menu.separator1.draw -side left -fill y -expand true
    button .picture.menu.save -image ${imgsave} -relief flat -borderwidth 0 -state disabled -command {
      if { ${file_id} != {} } {
        if { [ winfo exists .editleft.1.picture.pic ] } {
          $pic3 copy $pic2 -subsample 3 3
          .editleft.1.picture.pic configure -image $pic3
        }
        if { ${img_version} != {false} } {
          $pic2 write [ file join ${datadir} ${labelpic} ${file_id}.jpg ] -format JPEG
        } else {
          $pic2 write [ file join ${datadir} ${labelpic} ${file_id}.gif ] -format GIF
        }
        if { [ winfo exists .winelist.filter.show.pic ] } {
          if { ${img_version} != {false} && [ file exists [ file join ${datadir} ${labelpic} ${file_id}.jpg ] ] } {
            set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.jpg ] -width 300 -height 500 ]
            $pic copy $pic2 -subsample 4 4
          } elseif { ${img_version} != {false} && [ file exists [ file join ${datadir} ${labelpic} ${file_id}.JPG ] ] } {
            set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.JPG ] -width 300 -height 500 ]
            $pic copy $pic2 -subsample 4 4
          } elseif { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.gif ] ] } {
            set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.gif ] -width 300 -height 500 ]
            $pic copy $pic2 -subsample 4 4
          } elseif { [ file exists [ file join ${datadir} ${labelpic} ${file_id}.GIF ] ] } {
            set pic2 [ image create photo -file [ file join ${datadir} ${labelpic} ${file_id}.GIF ] -width 300 -height 500 ]
            $pic copy $pic2 -subsample 4 4
          }
          .winelist.filter.show.pic configure -image $pic
        }
        .picture.menu.save configure -state disabled
        # update the last modified time stamp
        if { [ file exists [ file join ${datadir} ${database} ${file_id} ] ] } {
          set initchannel [ open [ file join ${datadir} ${database} ${file_id} ] a ]
          puts ${initchannel} "set last_modified_secondsdate \{[ clock seconds ]\}"
          close ${initchannel}
        }
      }
    }
    if { ${scale} == {1} } {
      .picture.menu.save configure -state disabled -text [::msgcat::mc {Save}] -font ${smallfont} -compound left -pady 2 -padx 7
    } elseif { ${scale} == {2} } {
      .picture.menu.save configure -state disabled -text [::msgcat::mc {Save}] -font ${smallfont} -compound left -pady 2 -padx 7
    } else {
      .picture.menu.save configure -state disabled -pady 2 -padx 7
    }
    pack .picture.menu.menu .picture.menu.separator1 .picture.menu.save -side left -fill y
  pack .picture.menu -side top -fill x
  if { ${scale} == {1} } {
    label .picture.picture -image $pic500 -padx 0 -pady 0 -anchor center
    .picture.picture configure -width 300 -height 500
  } elseif  { ${scale} == {2} } {
    label .picture.picture -image $pic250 -padx 0 -pady 0 -anchor center
    .picture.picture configure -width 150 -height 250
  } elseif  { ${scale} == {4} } {
    label .picture.picture -image $pic125 -padx 0 -pady 0 -anchor center
    .picture.picture configure -width  75 -height 125
  }
  pack .picture.picture -side top -fill both -expand true


  # keyboard bindings
  bind .picture <KeyPress-F2>     { .picture.menu.save invoke }
  bind .picture <KeyPress-F3>     { ${picturemenu} invoke 0 }
  bind .picture <KeyPress-Escape> { ${picturemenu} invoke 4 }
  bind .picture <Control-Key-q>   { ${picturemenu} invoke 4 }
  bind .picture <KeyPress> {
    if { {%A} == {-} } {
      if { ${scale} == {1} } {
        ${scalemenu} invoke 1
      } elseif { ${scale} == {2} } {
        ${scalemenu} invoke 2
      }
    } elseif { {%A} == {+} } {
      if { ${scale} == {2} } {
        ${scalemenu} invoke 0
      } elseif { ${scale} == {4} } {
        ${scalemenu} invoke 1
      }
    }
  }

  # window placement - mousepointer in the middle ...
  tkwait visibility .picture
  set xposition_picture [ expr "[ winfo pointerx . ] - [ expr "[ winfo width  .picture ] / 2" ]" ]
  set yposition_picture [ expr "[ winfo pointery . ] - [ expr "[ winfo height .picture ] / 2" ]" ]
  if { ${xposition_picture} < {0} } { set xposition_picture {0} }
  if { ${yposition_picture} < {0} } { set yposition_picture {0} }
  if { [ expr "[ winfo width  .picture ] + ${xposition_picture}" ] > [ winfo screenwidth  . ] } { set xposition_picture [ expr "[ winfo screenwidth  . ] - [ winfo width  .picture ]" ] }
  if { [ expr "[ winfo height .picture ] + ${yposition_picture}" ] > [ winfo screenheight . ] } { set yposition_picture [ expr "[ winfo screenheight . ] - [ winfo height .picture ]" ] }
  wm geometry .picture +${xposition_picture}+${yposition_picture}


  # wine editor and no picture yet ...
  if { ${startwithopendialog} == {true} } {	${picturemenu} invoke 0 }
}
