########################################################################
#
#  tk visual options database file
#
#  predefines some defaults for the widgets
#  needs a preloaded configuration file
#
########################################################################

# basic font setting
option add *Font ${textfont}

# one pixel for the input focus
option add *selectBorderWidth 1

# same settings for menus and buttons
option add *Button.activeBackground ${lightcolor}
option add *Menubutton.activeBackground ${lightcolor}
option add *Button.OverRelief raised
option add *Menubutton.OverRelief raised
option add *Button.BorderWidth 1
option add *Menubutton.BorderWidth 1

# entry
option add *Entry.Background ${lightcolor}

# list in file selection - only on unix
# set background in canvas widgets for a nicer file selection box
if { $tcl_platform(platform) == {unix} } { option add *Canvas.Background ${lightcolor} }

# scrolbar-modifications - only on unix
if { $tcl_platform(platform) == {unix} } {
  if { [ winfo screenheight . ] < 760 } {
    option add *Scrollbar.Width 9
  } else {
    option add *Scrollbar.Width 13
  }
  option add *Scrollbar.highlightThickness 0
  option add *Scrollbar.borderWidth 1
  option add *Scrollbar.Relief sunken
  option add *Scrollbar.activeRelief raised
  option add *Scrollbar.activeBackground ${background}
  option add *Scrollbar.elementBorderWidth 1
}
