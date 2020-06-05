#!/bin/sh
#\
exec tclsh8.5 "$0" "$@"

package require Tk [ info tclversion ]
package require msgcat


# switch to the install wizard directory
set self [ info script ]
if { [ file type $self ] == "link" } { set self [ file readlink $self ] }
set prog_dir [ file dirname $self ]
cd $prog_dir


# window related stuff
set progname {TkWiCe Install Wizard}
wm title     . $progname
wm resizable . true true
wm iconname  . $progname
wm minsize   . 700 500
wm geometry  . 700x500


# icon
catch { wm iconphoto . -default [ image create photo -file [ file join source img tkwice48.gif ] ] [ image create photo -file [ file join source img tkwice32.gif ] ] }


# tricky: get basic fontsize from temporary, unshown widget
set fontname helvetica
if { [ lsearch -exact [ font families ] Arial ] } {
  set fontname Arial
} elseif { [ lsearch -exact [ font families ] arial ] } {
  set fontname arial
}
set fontsize       {5}
set actualfontsize {0}
while { $actualfontsize < "14" } {
  incr fontsize
  set actualfontsize [ font metrics "${fontname} ${fontsize} normal" -ascent ]
}


# predefine some vars
set nls                   {en}
set operating_system      $tcl_platform(platform)
set update                {no}
set target                {}
set targetscript          {}
set fhs                   {false}
set bin_create            {false}
set installed_program_dir {}
set exec_string           {}
set steps_update          {9}
set steps_full            {13}
set aborttext             {}
set add_link              {false}
set add_startmenu         {false}
set add_desktop           {false}
set titlefont             "-family ${fontname} -size $fontsize -weight bold"
set textfont              "-family ${fontname} -size $fontsize -weight normal"
# update default values to local conditions
if { $operating_system == "unix" } {
  set add_link      {true}
  set add_startmenu {true}
  set add_desktop   {true}
}
if { $operating_system == "windows" } {
#  set winversion [ registry get {HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion} Version ]
set winversion {Windows 95}
  if { ${winversion} != {Windows 95} && ${winversion} != {Windows 98} && ${winversion} != {Windows ME} } {
    set add_startmenu {true}
    set add_desktop   {true}
  }
}
if { $operating_system != "unix" && $operating_system != "windows" } {
  set operating_system {generic}
  if { [ auto_execok /bin/sh ] != "" && [ file isdirectory /usr/local/ ] == "1" && [ auto_execok ln ] != "" } {
    set add_link {true}
  }
}
if { [ auto_execok tkwice ] != "" || [ auto_execok tkwice.tcl ] != "" } {
  set update {yes}
  set steps $steps_update
} else {
  set steps $steps_full
}
if { [ file exists [ file join source ini nls.ini ] ] == "1" } {
  set readchannel [ open [ file join source ini nls.ini ] r ]
  set nls [ read $readchannel ]
  close $readchannel
  set nls [ string trimright $nls ]
}
if { $operating_system == "windows" } {
  set wintarget [ registry get {HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion} ProgramFilesDir ]
  if { [ file isdirectory [ file join ${wintarget} tkwice ext ] ] && [ file isdirectory [ file join ${wintarget} tkwice tcl ] ] } {
    set update {yes}
    set steps  $steps_update
  }
  if { [ file exists [ file join ${wintarget} tkwice ini nls.ini ] ] } {
    set readchannel [ open [ file join ${wintarget} tkwice ini nls.ini ] r ]
    set nls [ read $readchannel ]
    close $readchannel
    set nls [ string trimright $nls ]
  }
}
set lc_all_locale {}
if { $operating_system == "unix" && [ auto_execok /bin/sh ] != "" } {
  catch { set lc_all_locale $env(LC_ALL) }
  if { [ string length $lc_all_locale ] >= "2" } {
    if { [ string first {EN} $lc_all_locale ] != "-1" } {
      if { [ string first {EN} $lc_all_locale ] == "0" || [ string first {EN} $lc_all_locale ] == "3" } { set nls {en} }
    } elseif { [ string first {DE} $lc_all_locale ] != "-1" } {
      if { [ string first {DE} $lc_all_locale ] == "0" || [ string first {DE} $lc_all_locale ] == "3" } { set nls {de} }
    } elseif { [ string first {FR} $lc_all_locale ] != "-1" } {
      if { [ string first {FR} $lc_all_locale ] == "0" || [ string first {FR} $lc_all_locale ] == "3" } { set nls {fr} }
    } elseif { [ string first {IT} $lc_all_locale ] != "-1" } {
      if { [ string first {IT} $lc_all_locale ] == "0" || [ string first {IT} $lc_all_locale ] == "3" } { set nls {it} }
    } elseif { [ string first {ES} $lc_all_locale ] != "-1" } {
      if { [ string first {ES} $lc_all_locale ] == "0" || [ string first {ES} $lc_all_locale ] == "3" } { set nls {es} }
    }
  }
}
if { $update == "yes" && $operating_system != "windows" } {
  if { [ auto_execok tkwice ] != "" } {
    set tkwice_place [ auto_execok tkwice ]
  } elseif { [ auto_execok tkwice.tcl ] != "" } {
    set tkwice_place [ auto_execok tkwice.tcl ]
  }
  if { [ file type $tkwice_place ] == "link" } {
    set tkwice_place [ file readlink $tkwice_place ]
  } else {
    # check if it is a shellscript to tkwice ...
    set readchannel [ open $tkwice_place r ]
    set content [ read $readchannel ]
    close $readchannel
    if { [ regexp {#!/bin/sh} $content ] == "1" && [ regexp {/tkwice/tkwice.tcl} $content ] == "1" } {
      # okay, it is a sh-script that calls tkwice.tcl ...
      set tkwice_place [ lindex $content [ lsearch -regexp $content {/tkwice/tkwice.tcl} ] ]
    }
  }
  set installed_program_dir [ file dirname $tkwice_place ]
  if { [ info exists installed_program_dir ] != "" } {
    if { [ file exists [ file join $installed_program_dir ini nls.ini ] ] == "1" } {
      set readchannel [ open [ file join $installed_program_dir ini nls.ini ] r ]
      set nls [ read $readchannel ]
      close $readchannel
      set nls [ string trimright $nls ]
    }
  }
}


# images (crated with: "base64 -e input.gif output")
set logo [ image create photo -width 325 -height 42 -data \
"R0lGODlhRQEqAMZaAEIQIUIUIUoUIUoYKUocKVIcKVIgMVIkMVIoOVooOVosOVowOVowQmMw
Qr0AUmM0QmM4QmM4SmM8Sms8SmtBSmtBUmtFUnNFUnNJUnNJWnNNWntRWntRY3tVY3tZY4RZ
Y4RZa4Rda4Rha4xlc4xpc5Rte5Rxe5R1e5R1hJx1hJx5hJx9jKWCjKWGjKWGlKWKlK2KlK2O
lK2OnK2SnLWSnLWWnLWapbWepb2epb2erb2irb2mrcamrcaqtcautcaytc6yvc62vc66xta6
xta+xtbDxtbDztbHzt7Hzt7Lzt7L1t7P1ufP1ufT1ufT3ufX3u/X3u/b3u/b5+/f5/fj5/fj
7/fn7/fr7//r7//v9///////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/////////////////////////yH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAh+QQBCgB/ACwA
AAAARQEqAAAH/oBLAIOEhYYAS3+Ki4yNihKEG405hTqNM4QMjps9IgwDAAYWLE+bpqeoqaqr
rK2ur7CxsrO0qIKHuIOJriuEBI0mhSaNH4TDqEcPuQAmWLXP0NHS09TV07fLhrutRIVJjBSF
FI0GhECoPgLZABZX1u/w8fLz9H9TJvj5wvn4U69Z5QbNWJQFFKEAzhQxITQg4aYlBgcZ2NBB
WaER9TJq3Mix46JCpwg16hFgEIImikIQArEIyaABBossshHp4yBGFxjayLKIyYRCSBitK+Gx
qNGjR0GaErkIiDoACZws0kHowMxBFX4CkLFIBCEaNgEsMlIoiCMqAQEQDZtrLdK3/nDjUlO6
iemfIQajMppSSOqfEoNIjBgUYpECQqUU2U1B6IOpFw8iFw67oLLlyivkat7MuRVdR0yP5E0M
jhAOReEA1MAEQIEiKYQaCL2pqAKhHq/sdt7Nu3ejz79vKgmogDQjFoRI/Ck4yEi3Qf52EDox
W6yitFFy0/bNvbtm4NWbHBikAIopl4Me/FFCCMsVQj7+BBtkNuyikoN4utLtvb9/juCFlQAh
22wy3iBW4DBIBIo0MEhmWg2gn2LbFTIhK4RcZpkF/3Xo4Vz8VVeICKgMRt8JgSniFQAaXIEf
B8FZ90da/uy3TAIf5qijLAFSeMgNp0g3iAsYDGKDIqwZ/vCcajEuohUA8W1yhRRU1ugjLjju
qOWWqPT4R1VAEPASE6ZYQUgIAX3zB1mDqIBYk4rMB8BkjpgIQAfVcannnl2GGFYiQgLwgEON
5BTKS/phgd+BssH5RxCFDOFIExEBaR+fmGbqpV12KrfJC4ZgwMiTg6AA2nZ/RODLDowQcZhE
7lya6axcbrqdFa8CwKojSRiiAiOAlXWqjH8sOUgCHHTAgCGn5UnrszvaSqwR+BHgVyMIFILb
IpQwdKGPjdC0zjHVaWiZetCm25u0jSA3yATf/kFCIdkt0kQheA7rCBAD4jIAV8PmMoC6BHfG
LiNZWGCMIz1U5UgBhNRQF6qL/mCRQwcJqGMABi9YGaPABYcs8sgkl2zyySinrPLKLLfs8ssw
xyzzzDTX3IgDOOes88489+zzz0AHLfTQRBdt9NFIJ6300kw37fTTNkct9dRUV2311VhnrfU8
Dh5SXzVAbADxASIUSE/XhCSwQrydKaABQQMYgJNr0oQ9dtlHzfCAAANQcGR3Dvog+OAeS9OL
AjD0MMMEAnx9NgBBRO6DB8x0N8IvigwxyBGKFOQpNIcnvnjjRblggAtA9ICCAC4ATiw8QABQ
QazLYUB3PQ4ibADmvlGl5goSRND6mrpGE/vsBNle1AFRKmKDVdzlXhdMMEEQ5SABZB8ASthr
jxIj/hsAEBQjSsRgxZfUD2D9Ij1QAJMGRihiRAVxc/D9/PV/z4j0ixzwixOvW4QHONSg7HXv
SwDQHrra9774oY9664ONJJz0Or5I7A8TUIEKLqCIGACACopxAmww8hrrdC97+lNE+Ma3iPKd
74TbA2AjZLiJAQolfetrxAAcZwVLsM99A4AfhRTYAAMmMAAL+JsPIKcIGixAgARUDA6vd0QU
/sFBTchiFkH4pWvdoAAhBM21NlEAuYXEi2D8gw4MwAMsWGEGAzBCFg5wGiyoYALLoeMf7IjH
RvDvCjAAAEZo2AgkGIB5v7kWAMaoRja6EY7xW+QivvgH2BygRkwohyMe/kAiKgBgCEEIwPk8
IIGPiDAUu4JNGE9Rxi4xkpCKgGVLDtk8SSqCko0oQQFKgAMyNWKNbXxjHLtYF7+YgETyUsAx
PnAMQyJylX/ApS33d4jMEHM5MUDXNE3ZJU2csXPZVEQCfKiIFWigCh9UBCD/gE4urtOPhwjB
+WSpIhSYYILchKY4yfkHc14zC+GETQkG0s9gOMIErtmBhAoSnwOkwJSw8UEBsqPKay7Fm0t5
5evo+QcR2BOftgQouhqBgw6MhwAjsNI4GeHPbebzB1liHt0McI6OfjSfItVngwJ4pUFQkRAE
NEQUF2EAMzICC05wxiHiAwUA0G5NAzPBAUIg/gMWSpWqLKSmFptwvlgGcAoCYIJLxjhNQwCh
qU81wsCWWkkAFGEcf1BANxyxRCmMIF8bKAEAa9pFVZqAgxUVqiOK6gikKrUQHJIlPcEqVluy
9RRRwEEE+ohWRqgVgebI5xUE8AQkyEYBS4CIMxg71p5CqacE5F8iFWFH6LnUopvQACIaUQMA
mMeWrf1DZRchGkVUAQgrYAAy2Qlc4TpCtYygJws4+IcHPDSfsN2tInqLWxVYRZUKaAIRLlBR
RphpBwe4oAwUkAMB0G6RqsyC8ALLyEbI1my1va1GZxjA5SrCuavM7V4+cCG+mEe6f6Buey2q
gRuw4FcneEENJmjf/uY+t7qubS9yoXsvncKWYQDYwISokADmTrPCf0jArsqpgSx0QD/orIKJ
UQyAKsDTFLKcYyEM4JCyMlLELH3bh8WiyhWwoAQ26C4jKpABACRmIRkQFUStwwQCNMzCjGiY
hhfBYQ/PN7mvkzEhaGxREC9is9vyKhdxvIiWDniaMRiBBIjwqAqAYCBalohSrwXi104Ymk8w
YXtfm0sASGAGPYBBAgywi2nmWRFr7EEWrFCDYUZgbX/IgQF48mieSPpbd/6DLNeYECsQoFkW
dWmiF93oSF7r0KpkggIOUAUhlxkAGA0xAFoglFPORJMXdgRg/hzoQRf6yovYNJf/4OnTvBg6
gCsYQAp8AIQYKIBOo2b0MPk8zSUUlSdZKAABUMJpRRTboofOdaanyZchao/NMGSzI3ZwAVAg
YATmgWa5FdEDxg0AA+p2ggZgUoF873sA/T4uTzVdxQAEgQLDU0QK4Brq9tabb/iWN4+tMwE8
uVoRQqjcIuYlkyUzQiXmzp66G8Fud8PbJtoLABEAmPIgsFx7B0/4HxZu0Xk3ggZ7C8ADWnCh
h99b3dQeYwKGCwK6IZwRNCe3CQtOhEAAADs=" ]
set icon [ image create photo -width 64 -height 64 -data \
"R0lGODlhQABAAOf/ADQdGTodFkIeGkAiFkYfFz4pJVUiHTwsMjIxNTgwMDcwN00oJzwwPVwm
LF8oJEI0O0YzNmUnJj43PEczOzs5Q04yOmwmKlAzNUo5M0U+QnAsLnYqMUk9ST9CSkw9Q0VA
SV03OkBCUHkyPlZEQW85PmQ/Qmo7SVdEUmBBSlFJTE1KVHA8RWJERIA3OktMW1pITmlBS2xB
Roc7PlNQX09UYlZSXFdRZm5KT4JCRYRCQHRITWdPUF1TWYFDTolBSGNTUnZLV4BJU4NJTFdb
aXxOToBMT1xbZH9OVXlSUGdXaYlKVXhTV4tPT3hYZKFJTVxlel9lcolVV4NXXYhVXWdjbXFh
X5tOVZJSXZBVWnVjWoFcX3lgYIlaWppRXI9WYI5bYpBbXYteY4diWYxdaWVxhXRudX1tZJNj
Y5dhY5lfaWxygJFkaY9kb6RbZ65XY5ZiapxgZYBwbqJgaINxYoRueYhvcp1oapZsaoZ0a51p
cJlrcqJncaRnbHd3mJRvdIlziHSAlZZxiod8eapsca5qcY56eI18cqVvd6ltd6dvcoB/h3iD
ipN4g6JzeHqDkJR6fJp2g5N+b7lqdbBueZV+dZ94eqN1gJ15gJGBd6d2drBydqN5dqx1d6t1
fLBzfad4fbZyeKx5c4qLkpiIf7F7g56GfqWDfq1+g7h6frd6g7t4hIeOnKqBhLB/f52Ke8F4
gIKRprd/gaaGiquEjJiPlbeEfb1/iaKLlb+AhJ+PjKWOhsN+i6iPgZyQqMSFisyCkdCCi6uV
jKyWh8qGk5KfrZmdrrGWoZ6fpamcmLSWm9SIlr6TmMKTkcKakKCkwNCYjaeoq6KtuLykprao
p7Gpsa2oxsWjp7usocCnsdCiocOpobOwqsCsnJy6182xoLK70N2uq727v7S+ysq2wdC1tsS7
t77I1tXEzs/JztPJxfC/t8bR3uXHzPDFweHNz+fSwc3a6Mnd8+bT3NXc5OPZ1ePZ4Njo9vLj
1t/o8enl6uPp7Ozo5u3z9vbz+Pzy+fj59SH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAsAAAA
AEAAQAAACP4AgwkUJkygQV4GBepaqIsXr1KlTEEMF05WDidO3LiR9OoVsI+/lIkcSfKXSWAm
TQ5bOUwXt4LBCBJEyEtXsIU1G97UlasUpVzlzFW0ImmjJEkfgSkDNozpyJXKQn7clfIXVZOU
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
3MmunMqtrMqqLMAscAEsDAIBAQA7" ]


proc copy {} {
  global titlefont textfont steps nls prog_dir target exec_string targetscript
  .buttonbar.back.button configure -state disabled
  .buttonbar.next.button configure -command {
    destroy .content.text
    label .content.title -text {} -font $titlefont -background {#f3f3f3} -foreground {#111111} -anchor w
    pack .content.title -side top -fill x -pady 10
    nls
  }
  .titlebar.step configure -text "0/${steps}"
  frame .content.text
    scrollbar .content.text.yscroll -orient vertical -borderwidth 1 -command { .content.text.text yview }
    text .content.text.text -wrap word -height 1 -width 1 -font $textfont -background {#f3f3f3} -foreground {#111111} -relief flat -borderwidth 0 -highlightthickness 0 -cursor [ . cget -cursor ] -yscrollcommand { .content.text.yscroll set }
    pack .content.text.text -side left -fill both -expand true
    pack .content.text.yscroll -side right -fill y
  pack .content.text -padx 3 -pady 3 -fill both -expand true -side top
  set copyfile [ file join source COPYING.html ]
  set copychannel [ open $copyfile r ]
  set content [ read $copychannel ]
  close $copychannel
  set html_out_widget {.content.text.text}
  source [ file join source tcl html.tcl ]
  .content.text.text configure -state disabled
  pack .content.text -side top -fill both -expand true -pady 10
  bind .content.text.text <Enter> { focus .content.text.text }
}


proc nls {} {
  global titlefont textfont nls steps prog_dir target exec_string targetscript
  .buttonbar.back.button configure -state normal -command {
    destroy .content.title
    destroy .content.cs
    destroy .content.en
    destroy .content.fr
    destroy .content.de
    destroy .content.it
    destroy .content.es
    copy
  }
  .buttonbar.next.button configure -command {
    set nlschannel [ open [ file join source ini nls.ini ] w ]
    puts $nlschannel $nls
    close $nlschannel
    destroy .content.cs
    destroy .content.en
    destroy .content.fr
    destroy .content.de
    destroy .content.it
    destroy .content.es
    helo
  }
  .titlebar.prestep configure -text [ ::msgcat::mc {Step} ]
  .titlebar.step configure -text "1/${steps}"
  radiobutton .content.cs -text "\u010ce\u0161tina" -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable nls -value cs -command {
    msgcat::mclocale ${nls}
    msgcat::mcload [ file join nls ]
    .titlebar.prestep       configure -text [ ::msgcat::mc {Step} ]
    .buttonbar.abort.button configure -text [ ::msgcat::mc {Abort} ]
    .buttonbar.back.button  configure -text [ ::msgcat::mc {Back} ]
    .buttonbar.next.button  configure -text [ ::msgcat::mc {Next} ]
    .content.title          configure -text [ ::msgcat::mc {Default Language} ]
  }
  radiobutton .content.en -text {English} -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable nls -value en -command {
    msgcat::mclocale ${nls}
    msgcat::mcload [ file join nls ]
    .titlebar.prestep       configure -text [ ::msgcat::mc {Step} ]
    .buttonbar.abort.button configure -text [ ::msgcat::mc {Abort} ]
    .buttonbar.back.button  configure -text [ ::msgcat::mc {Back} ]
    .buttonbar.next.button  configure -text [ ::msgcat::mc {Next} ]
    .content.title          configure -text [ ::msgcat::mc {Default Language} ]
  }
  radiobutton .content.fr -text "Fran\u00e7ais" -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable nls -value fr -command {
    msgcat::mclocale ${nls}
    msgcat::mcload [ file join nls ]
    .titlebar.prestep       configure -text [ ::msgcat::mc {Step} ]
    .buttonbar.abort.button configure -text [ ::msgcat::mc {Abort} ]
    .buttonbar.back.button  configure -text [ ::msgcat::mc {Back} ]
    .buttonbar.next.button  configure -text [ ::msgcat::mc {Next} ]
    .content.title          configure -text [ ::msgcat::mc {Default Language} ]
  }
  radiobutton .content.de -text {Deutsch} -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable nls -value de -command {
    msgcat::mclocale ${nls}
    msgcat::mcload [ file join nls ]
    .titlebar.prestep       configure -text [ ::msgcat::mc {Step} ]
    .buttonbar.abort.button configure -text [ ::msgcat::mc {Abort} ]
    .buttonbar.back.button  configure -text [ ::msgcat::mc {Back} ]
    .buttonbar.next.button  configure -text [ ::msgcat::mc {Next} ]
    .content.title          configure -text [ ::msgcat::mc {Default Language} ]
  }
  radiobutton .content.it -text {Italiano (principalmente incompleto)} -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable nls -value it -command {
    msgcat::mclocale ${nls}
    msgcat::mcload [ file join nls ]
    .titlebar.prestep       configure -text [ ::msgcat::mc {Step} ]
    .buttonbar.abort.button configure -text [ ::msgcat::mc {Abort} ]
    .buttonbar.back.button  configure -text [ ::msgcat::mc {Back} ]
    .buttonbar.next.button  configure -text [ ::msgcat::mc {Next} ]
    .content.title          configure -text [ ::msgcat::mc {Default Language} ]
  }
  radiobutton .content.es -text "Espa\u00f1ol (sobre todo incompleto)" -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable nls -value es -command {
    msgcat::mclocale ${nls}
    msgcat::mcload [ file join nls ]
    .titlebar.prestep       configure -text [ ::msgcat::mc {Step} ]
    .buttonbar.abort.button configure -text [ ::msgcat::mc {Abort} ]
    .buttonbar.back.button  configure -text [ ::msgcat::mc {Back} ]
    .buttonbar.next.button  configure -text [ ::msgcat::mc {Next} ]
    .content.title          configure -text [ ::msgcat::mc {Default Language} ]
  }
  pack .content.cs .content.en .content.fr .content.de .content.it .content.es -side top -fill x
  .content.${nls} invoke
}


proc helo {} {
  global titlefont textfont steps nls prog_dir target exec_string targetscript
  .buttonbar.back.button configure -state normal -command {
    destroy .content.text
    nls
  }
  .buttonbar.next.button configure -command {
    destroy .content.text
    extensions
  }
  .titlebar.step configure -text "2/${steps}"
  .content.title configure -text [ ::msgcat::mc {Welcome to TkWiCe!} ]
  text .content.text -wrap word -height 1 -width 1 -font $textfont -background {#f3f3f3} -foreground {#111111} -relief flat -borderwidth 0 -highlightthickness 0
  .content.text insert end [ ::msgcat::mc "This wizard will guide you step by step through the installation (of course it is possible to update a previous version, too). But note that some additional actions on some operating systems won't be done automatically - in that case you'll be adviced of what to do." ]
  .content.text configure -state disabled
  pack .content.text -side top -fill both -expand true -pady 10
}


proc extensions {} {
  global titlefont textfont steps tcl_platform nls prog_dir target exec_string targetscript
  .buttonbar.back.button configure -state normal -command {
    destroy .content.text
    helo
  }
  .buttonbar.next.button configure -command {
    destroy .content.text
    operating_system
  }
  .titlebar.step configure -text "3/${steps}"
  .content.title configure -text [ ::msgcat::mc {System Check} ]
  frame .content.text -background {#f3f3f3}
  label .content.text.11 -text {Tcl-Version: } -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  label .content.text.12 -text [ ::msgcat::mc {standby ...} ] -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  label .content.text.13 -text [ ::msgcat::mc {standby ...} ] -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  grid .content.text.11 -row 0 -column 0 -sticky w
  grid .content.text.12 -row 0 -column 1 -sticky w -padx 10
  grid .content.text.13 -row 0 -column 2 -sticky w
  label .content.text.21 -text {Tablelist-Extension: } -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  label .content.text.22 -text [ ::msgcat::mc {standby ...} ] -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  label .content.text.23 -text [ ::msgcat::mc {standby ...} ] -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  grid .content.text.21 -row 1 -column 0 -sticky w
  grid .content.text.22 -row 1 -column 1 -sticky w -padx 10
  grid .content.text.23 -row 1 -column 2 -sticky w
  label .content.text.31 -text {Img-Extension: } -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  label .content.text.32 -text [ ::msgcat::mc {standby ...} ] -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  label .content.text.33 -text [ ::msgcat::mc {standby ...} ] -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  grid .content.text.31 -row 2 -column 0 -sticky w
  grid .content.text.32 -row 2 -column 1 -sticky w -padx 10
  grid .content.text.33 -row 2 -column 2 -sticky w
  label .content.text.41 -text {ImageMagick: } -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  label .content.text.42 -text [ ::msgcat::mc {standby ...} ] -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  label .content.text.43 -text [ ::msgcat::mc {standby ...} ] -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  grid .content.text.41 -row 3 -column 0 -sticky w
  grid .content.text.42 -row 3 -column 1 -sticky w -padx 10
  grid .content.text.43 -row 3 -column 2 -sticky w
  label .content.text.5 -text {} -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  grid .content.text.5 -row 4 -column 0 -sticky w -columnspan 3 -pady 10
  pack .content.text -side top -fill x
  grid columnconfigure .content.text 2 -weight 1
  .buttonbar.back.button configure -state disabled
  .buttonbar.next.button configure -state disabled
  update
  after 350
  set system {okay}
  # Tcl-Version
  set text12 [ info patchlevel ]
  .content.text.12 configure -text $text12
  set tcltkver1 [ string range $text12 [ expr "[ string first {.} $text12 ] + 1" ] end ]
  set tcltkver2 {}
  regsub -all {0} $tcltkver1 {} tcltkver2
  regsub -all {1} $tcltkver2 {} tcltkver1
  regsub -all {2} $tcltkver1 {} tcltkver2
  regsub -all {3} $tcltkver2 {} tcltkver1
  regsub -all {4} $tcltkver1 {} tcltkver2
  regsub -all {5} $tcltkver2 {} tcltkver1
  regsub -all {6} $tcltkver1 {} tcltkver2
  regsub -all {7} $tcltkver2 {} tcltkver1
  regsub -all {8} $tcltkver1 {} tcltkver2
  regsub -all {9} $tcltkver2 {} tcltkver1
  regsub -all {\.} $tcltkver1 {} tcltkver2
  if { $tcltkver2 == "" } {
    set text12 [ info tclversion ]
    if { [ string range $text12 0 [ expr "[ string first {.} $text12 ] - 1" ] ] >= "8" } {
      if { [ string range $text12 0 [ expr "[ string first {.} $text12 ] - 1" ] ] == "8" && [ string range $text12 [ expr "[ string first {.} $text12 ] + 1" ] end ] > "3" } {
        if { [ string range $text12 [ expr "[ string first {.} $text12 ] + 1" ] end ] < "5" } {
          set text13 [ ::msgcat::mc {outdated (but could work)} ]
          set system {minor}
        } else {
          set text13 [ ::msgcat::mc {okay} ]
        }
      } elseif { [ string range $text12 0 [ expr "[ string first {.} $text12 ] - 1" ] ] > "8" } {
        set text13 [ ::msgcat::mc {okay} ]
      } else {
        set text13 [ ::msgcat::mc {too old - error!} ]
        set system {error}
      }
    } else {
      set text13 [ ::msgcat::mc {too old - error!} ]
      set system {error}
    }
  } else {
    set text13 [ ::msgcat::mc {unofficial release - validation impossible} ]
    set system {minor}
  }
  .content.text.13 configure -text $text13
  update
  after 350
  # Tablelist-Version
  set text22 [ ::msgcat::mc {none} ]
  catch { set text22 [ package require tablelist ] }
  .content.text.22 configure -text $text22
  if { $text22 == [ ::msgcat::mc {none} ] } {
    set text23 [ ::msgcat::mc {okay (fallback to builtin)} ]
  } else {
    if { [ string range $text22 0 [ expr "[ string first {.} $text22 ] - 1" ] ] >= "4" } {
      if { [ string range $text22 0 [ expr "[ string first {.} $text22 ] - 1" ] ] == "4" && [ string range $text22 [ expr "[ string first {.} $text22 ] + 1" ] end ] > "2" } {
        set text23 [ ::msgcat::mc {okay} ]
      } elseif { [ string range $text22 0 [ expr "[ string first {.} $text22 ] - 1" ] ] > "4" } {
        set text23 [ ::msgcat::mc {okay} ]
      } else {
        set text23 [ ::msgcat::mc {outdated (but could work)} ]
        set system {minor}
      }
    } else {
      set text23 [ ::msgcat::mc {outdated (but could work)} ]
      set system {minor}
    }
  }
  .content.text.23 configure -text $text23
  update
  after 350
  # Img-Version
  set text32 [ ::msgcat::mc {not available} ]
  set text33 [ ::msgcat::mc {only GIF image support} ]
  catch { set text32 [ package require Img ] }
  if { $text32 != [ ::msgcat::mc {not available} ] } {
    set text33 [ ::msgcat::mc {okay} ]
  } else {
    set system {minor}
  }
  .content.text.32 configure -text $text32
  .content.text.33 configure -text $text33
  update
  after 350
  # ImageMagick-Version
  if { $tcl_platform(platform) == "unix" && [ auto_execok convert ] != "" && [ auto_execok display ] != "" } {
    set text42 [ ::msgcat::mc {found} ]
    set text43 [ ::msgcat::mc {okay} ]
  } elseif { $tcl_platform(platform) == "unix" } {
    set text42 [ ::msgcat::mc {not available} ]
    set text43 [ ::msgcat::mc {no automatic image resizing} ]
    set system {minor}
  } else {
    set text42 [ ::msgcat::mc {skipping} ]
    set text43 [ ::msgcat::mc {unsupported on your operating system} ]
  }
  .content.text.42 configure -text $text42
  .content.text.43 configure -text $text43
  update
  after 350
  if { $system == "minor" } {
    .content.text.5 configure -text [ ::msgcat::mc {Something (minor) can be improved on your computer environment.} ]
    .buttonbar.back.button configure -state normal
    .buttonbar.next.button configure -state normal
  } elseif { $system == "error" } {
    .content.text.5 configure -text [ ::msgcat::mc {At least one major test above failed completely - stopped.} ]
  } else {
    .content.text.5 configure -text [ ::msgcat::mc {Your computer passed all tests.} ]
    .buttonbar.back.button configure -state normal
    .buttonbar.next.button configure -state normal
  }
}


proc operating_system {} {
  global titlefont textfont operating_system steps nls prog_dir target exec_string targetscript
  .buttonbar.back.button configure -command {
    destroy .content.windows
    destroy .content.unix
    destroy .content.mac
    destroy .content.generic
    extensions
  }
  .buttonbar.next.button configure -command {
    destroy .content.windows
    destroy .content.unix
    destroy .content.mac
    destroy .content.generic
    2update
  }
  .titlebar.step configure -text "4/${steps}"
  .content.title configure -text [::msgcat::mc {Operating System}]
  radiobutton .content.windows -text {Windows} -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable operating_system -value windows
  radiobutton .content.unix    -text {Unix (Linux, BSD, ...)} -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable operating_system -value unix
  radiobutton .content.mac     -text {Macintosh (TkWiCe completely untested!)} -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable operating_system -value macintosh
  radiobutton .content.generic -text [::msgcat::mc {Generic (any operating system)}] -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable operating_system -value generic
  pack .content.windows .content.unix .content.mac .content.generic -side top -fill x
  if { $operating_system == "macintosh" } {
    .content.windows configure -state disabled
  } elseif { $operating_system == "windows" } {
    .content.unix    configure -state disabled
    .content.mac     configure -state disabled
  } elseif { $operating_system == "unix" } {
    .content.windows configure -state disabled
  } else {
    set operating_system {generic}
    .content.windows configure -state disabled
    .content.unix    configure -state disabled
    .content.mac     configure -state disabled
  }
}


proc 2update {} {
  global titlefont textfont operating_system update steps steps_update steps_full nls prog_dir target exec_string targetscript
  .buttonbar.back.button configure -command {
    destroy .content.installation
    destroy .content.update
    destroy .content.text
    operating_system
  }
  .buttonbar.next.button configure -command {
    destroy .content.installation
    destroy .content.update
    destroy .content.text
    target
  }
  .titlebar.step configure -text "5/${steps}"
  .content.title configure -text [::msgcat::mc {Installation Type}]
  radiobutton .content.installation -text [::msgcat::mc {new installation}] -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable update -value no -command {
    set steps $steps_full
    .titlebar.step configure -text "5/${steps}"
  }
  radiobutton .content.update -text [::msgcat::mc {update existing installation}] -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable update -value yes -command {
    set steps $steps_update
    .titlebar.step configure -text "5/${steps}"
  }
  text .content.text -wrap word -height 1 -width 1 -font $textfont -background {#f3f3f3} -foreground {#111111} -relief flat -borderwidth 0 -highlightthickness 0
  set text [::msgcat::mc {Note: The update mechanism only works if you have installed TkWiCe with the included Install Wizard (respective into a directory named "tkwice", not "tkwice-0.2" or similar). If you want to update and this wizard can't, choose "new installation" and delete the old directory.}]
  .content.text insert end $text
  .content.text configure -state disabled
  pack .content.installation .content.update -side top -fill x
  pack .content.text -side top -fill both -expand true -pady 10
}


proc target {} {
  global titlefont textfont nls operating_system update target prog_dir steps installed_program_dir exec_string fhs bin_create targetscript env
  .buttonbar.back.button configure -command {
    destroy .content.text
    destroy .content.target
    destroy .content.text2
    2update
  }
  .buttonbar.next.button configure -command {
    source [ file join source ini $tcl_platform(platform).ini ]
    if { [ file nativename $datadir ] == [ file nativename [ file join $target tkwice ] ] } {
      .content.target.button.button flash
      .content.text2 configure -state normal
      .content.text2 delete 1.0 end
      .content.text2 insert end [::msgcat::mc {Directory would collide with database - choose another one!}]
      .content.text2 configure -state disabled
    } elseif { [ file isdirectory [ file join $target tkwice tcl ] ] == "1" && $update == "no" } {
      .content.target.button.button flash
      .content.text2 configure -state normal
      .content.text2 delete 1.0 end
      .content.text2 insert end [::msgcat::mc {Found a valid TkWice installation in the chosen directory - so go back and choose "Update" to replace it, or delete it.}]
      .content.text2 configure -state disabled
    } elseif { [ file isdirectory [ file join $target tkwice database ] ] == "1" } {
      .content.target.button.button flash
      .content.text2 configure -state normal
      .content.text2 delete 1.0 end
      .content.text2 insert end [::msgcat::mc {Found TkWiCe database files there - please choose another directory.}]
      .content.text2 configure -state disabled
    } elseif { [ file isdirectory $target ] == "0" } {
      .content.target.button.button flash
      .content.text2 configure -state normal
      .content.text2 delete 1.0 end
      .content.text2 insert end [::msgcat::mc {Path not found! Choose a existing directory.}]
      .content.text2 configure -state disabled
    } elseif { [ file exists [ file join ${target} setup.tcl ] ] } {
      .content.target.button.button flash
      .content.text2 configure -state normal
      .content.text2 delete 1.0 end
      .content.text2 insert end [::msgcat::mc {Found source directory "tkwice" in there; Can't install into source directory - choose another one! (Alternative rename the source directory and restart.)}]
      .content.text2 configure -state disabled
    } elseif { [ file exists [ file join $target tkwice setup.tcl ] ] } {
      .content.target.button.button flash
      .content.text2 configure -state normal
      .content.text2 delete 1.0 end
      .content.text2 insert end [::msgcat::mc {Found source directory "tkwice" in there; Can't install into source directory - choose another one! (Alternative rename the source directory and restart.)}]
      .content.text2 configure -state disabled
    } else {
      if { $update == "yes" } {
        if { [ file exists [ file join $target tkwice tkwice.tcl ] ] == "1" && [ file exists [ file join $target tkwice VERSION ] ] == "1" && [ file exists [ file join $target tkwice tcl editwine.tcl ] ] == "1" } {
          destroy .content.text
          destroy .content.target
          destroy .content.text2
          summary
        } else {
          .content.target.button.button flash
          .content.text2 configure -state normal
          .content.text2 delete 1.0 end
          .content.text2 insert end [::msgcat::mc {Main program files not found in the chosen directory!}]
          .content.text2 configure -state disabled
        }
      } else {
        destroy .content.text
        destroy .content.target
        destroy .content.text2
        summary
      }
    }
  }
  .titlebar.step configure -text "6/${steps}"
  set titletext [::msgcat::mc {Target Directory}]
  if { $update == "no" } {
    set text [::msgcat::mc {Where should the TkWiCe program directory be created in?}]
    if { $operating_system == "unix" } {
      if { [ file nativename ~ ] == "/root" || $env(USER) == {root} } {
        set fhs {true}
        if { [ file isdirectory /opt ] } {
          set target {/opt}
        } elseif { [ file isdirectory /usr/local/share ] } {
          set target {/usr/local/share/}
        } elseif { [ file isdirectory /usr/local ] } {
          set target {/usr/local/}
        } else {
          set target [ file nativename ~ ]
        }
      } else {
        set target [ file nativename ~ ]
      }
    } elseif { $operating_system == "windows" } {
      set target [ registry get {HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion} ProgramFilesDir ]
    } else {
      set target [ file nativename ~ ]
    }
  } else {
    set text [::msgcat::mc {In which directory remains the to update directory "tkwice"?}]
    if { [ auto_execok tkwice ] != "" } {
      set tkwice_place [ auto_execok tkwice ]
      if { [ file type $tkwice_place ] == "link" } { set tkwice_place [ file readlink $tkwice_place ] }
      set target [ file split [ file dirname $tkwice_place ] ]
      set target2 {}
      foreach entry [ lrange $target 0 [ expr ( [ llength $target ] - 2 ) ] ] { set target2 [ file join $target2 $entry ] }
      set target $target2
    } elseif { [ auto_execok tkwice.tcl ] != "" } {
      set tkwice_place [ auto_execok tkwice.tcl ]
      if { [ file type $tkwice_place ] == "link" } { set tkwice_place [ file readlink $tkwice_place ] }
      set target [ file split [ file dirname $tkwice_place ] ]
      set target2 {}
      foreach entry [ lrange $target 0 [ expr ( [ llength $target ] - 2 ) ] ] { set target2 [ file join $target2 $entry ] }
      set target $target2
    } else {
      if { $operating_system == "windows" } {
        set target [ registry get {HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion} ProgramFilesDir ]
      } else {
        set target [ file nativename ~ ]
      }
    }
    if { $installed_program_dir != "" } {
      set target [ file split [ file dirname $installed_program_dir ] ]
      set target2 {}
      foreach entry [ lrange $target 0 [ expr ( [ llength $target ] - 1 ) ] ] { set target2 [ file join $target2 $entry ] }
      set target $target2
    }
  }
  if { [ file isdirectory $target ] == "0" } { set target [ file nativename ~ ] }
  if { $update == "no" } {
    set text2 [::msgcat::mc {Though there might be a good choice predefined, you can choose any target directory you want. But note: You need write permissions in that directory.}]
  } else {
    set text2 [::msgcat::mc {If you don't know it anymore and the wizard failed finding the right location itself, just start the to update version and look directly after the start at the bottom status lines.}]
  }
  .content.title configure -text $titletext
  label .content.text -text $text -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  pack .content.text -side top -fill x
  frame .content.target -background {#f3f3f3}
  frame .content.target.entry -relief sunken -borderwidth 1 -background {#aa0044} -padx 0 -pady 0
  entry .content.target.entry.entry -textvariable target -width 30 -font $textfont -background {#ffffff} -foreground {#111111} -relief flat -borderwidth 0
  pack .content.target.entry.entry -padx 0 -pady 0
  frame .content.target.button -relief raised -borderwidth 2 -background {#aa0044} -padx 0 -pady 0
  button .content.target.button.button -text [::msgcat::mc {Choose}] -font $textfont -padx 5 -pady 0 -relief flat -background {#ffffff} -foreground {#111111} -activebackground {#aa0044} -activeforeground {#ffffff} -highlightthickness 0 -command {
    .content.target.entry.entry configure -state normal
    set target [ tk_chooseDirectory -mustexist true -initialdir $target -parent . -title Directory ]
  }
  pack .content.target.button.button -padx 0 -pady 0
  if { $fhs == {true} } {
    frame .content.target.fhs -relief raised -borderwidth 2 -background {#aa0044} -padx 0 -pady 0
    button .content.target.fhs.button -text [::msgcat::mc {force the FHS standard}] -font $textfont -padx 5 -pady 0 -relief flat -background {#ffffff} -foreground {#111111} -activebackground {#aa0044} -activeforeground {#ffffff} -highlightthickness 0 -command {
      set target {/opt}
      if { [ file isdirectory /opt ] != "1" } { file mkdir /opt }
      if { [ file isdirectory /opt/bin ] != "1" } {
        file mkdir /opt/bin
        set bin_create {true}
      }
      .content.target.entry.entry configure -state disabled
    }
    pack .content.target.fhs.button -padx 0 -pady 0
  }
  pack .content.target.entry -side left
  pack .content.target.button -side left -padx 10
  if { $fhs == {true} } { pack .content.target.fhs -side left -padx 0 }
  pack .content.target -side top -fill x
  text .content.text2 -wrap word -height 1 -width 1 -font $textfont -background {#f3f3f3} -foreground {#111111} -relief flat -borderwidth 0 -highlightthickness 0
  .content.text2 insert end $text2
  .content.text2 configure -state disabled
  pack .content.text2 -side top -fill both -expand true -pady 10
}


proc summary {} {
  global titlefont textfont nls update target oldnextbuttontext steps prog_dir exec_string targetscript
  set oldnextbuttontext [ .buttonbar.next.button cget -text ]
  .buttonbar.back.button configure -command {
    destroy .content.text
    .buttonbar.next.button configure -text $oldnextbuttontext
    target
  }
  .buttonbar.next.button configure -command {
    destroy .content.text
    destroy .buttonbar.back
    destroy .buttonbar.blank1
    .buttonbar.next.button configure -text $oldnextbuttontext
    install
  }
  if { $nls == "en" } {
    set nlstxt {English}
  } elseif { $nls == "fr" } {
    set nlstxt "Fran\u00e7ais"
  } elseif  { $nls == "de" } {
    set nlstxt {Deutsch}
  } elseif  { $nls == "it" } {
    set nlstxt {Italiano}
  } elseif  { $nls == "es" } {
    set nlstxt "Espa\u00f1ol"
  } elseif  { $nls == "cs" } {
    set nlstxt "\u010ce\u0161tina"
  }
  if { $update == "no" } {
    set updatetxt [::msgcat::mc {Target}]
  } else {
    set updatetxt [::msgcat::mc {Update}]
  }
  .titlebar.step configure -text "7/${steps}"
  .content.title configure -text [::msgcat::mc {Summary}]
  .buttonbar.next.button configure -text [::msgcat::mc {Start}]
  frame .content.text -background {#f3f3f3} -padx 10
  label .content.text.00 -text "[::msgcat::mc {Language Preset}] " -font $titlefont -background {#f3f3f3} -foreground {#111111} -anchor w -padx 0 -pady 5
  label .content.text.01 -text $nlstxt -font $textfont -background {#ffffff} -foreground {#111111} -anchor w -padx 5 -pady 0
  label .content.text.10 -text "$updatetxt " -font $titlefont -background {#f3f3f3} -foreground {#111111} -anchor w -padx 0 -pady 5
  label .content.text.11 -text $target -font $textfont -background {#ffffff} -foreground {#111111} -anchor w -padx 5 -pady 0
  grid .content.text.00 .content.text.01 -sticky we
  grid .content.text.10 .content.text.11 -sticky we
  pack .content.text -side top -fill x
  grid columnconfigure .content.text 1 -weight 1
}


proc install {} {
  global titlefont textfont steps update target nls prog_dir exec_string operating_system targetscript
  .buttonbar.abort.button configure -state disabled
  .buttonbar.next.button configure -state disabled -command {
    .buttonbar.abort.button configure -state normal
    destroy .content.progress
    destroy .content.text1
    destroy .content.text2
    destroy .content.text3
    destroy .content.text4
    done_inst
  }
  .titlebar.step configure -text "8/${steps}"
  .content.title configure -text [::msgcat::mc {Running Installation - Stand By}]
  # progress bar
  frame .content.progress -borderwidth 1 -relief solid -background {#f3f3f3} -pady 0 -padx 0
		label .content.progress.1 -text {  0%} -background {#f3f3f3} -foreground {#111111} -highlightthickness 0 -anchor w -padx 5 -font $textfont
		label .content.progress.2 -text {} -background {#f3f3f3} -foreground {#111111} -highlightthickness 0 -font $textfont
		label .content.progress.3 -text {} -background {#f3f3f3} -foreground {#111111} -highlightthickness 0 -font $textfont
		label .content.progress.4 -text {} -background {#f3f3f3} -foreground {#111111} -highlightthickness 0 -font $textfont
		label .content.progress.5 -text {} -background {#f3f3f3} -foreground {#111111} -highlightthickness 0 -font $textfont
		label .content.progress.6 -text {} -background {#f3f3f3} -foreground {#111111} -highlightthickness 0 -font $textfont
		label .content.progress.7 -text {} -background {#f3f3f3} -foreground {#111111} -highlightthickness 0 -font $textfont
		label .content.progress.8 -text {} -background {#f3f3f3} -foreground {#111111} -highlightthickness 0 -font $textfont
    pack .content.progress.1 .content.progress.2 .content.progress.3 .content.progress.4 .content.progress.5 .content.progress.6 .content.progress.7 .content.progress.8 -side left -fill x -expand true
  pack .content.progress -side top -fill x -pady 10
  # backup
  .content.progress.1 configure -text { 13%}
  .content.progress.1 configure -background {#aa0044} -foreground {#f3f3f3}
  set text1 [::msgcat::mc {backup old program files ...}]
  label .content.text1 -text $text1 -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  pack .content.text1 -side top -fill x
  update
  after 350
  if { [ file isdirectory [ file join $target tkwice ] ] == "1" } {
    if { [ file isdirectory [ file join $target tkwice.bak ] ] == "1" } { file delete -force [ file join $target tkwice.bak ] }
    file rename -force [ file join $target tkwice ] [ file join $target tkwice.bak ]
    set text1 "$text1 [::msgcat::mc {done.}]"
  } else {
    set text1 "$text1 [::msgcat::mc {nothing to do.}]"
  }
  .content.progress.1 configure -text { 25%}
  .content.progress.2 configure -background {#aa0044} -foreground {#f3f3f3}
  .content.text1 configure -text $text1
  update
  after 350
  # install
  .content.progress.1 configure -text { 38%}
  .content.progress.3 configure -background {#aa0044} -foreground {#f3f3f3}
  set text2 [::msgcat::mc {copying program files ...}]
  label .content.text2 -text $text2 -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  pack .content.text2 -side top -fill x
  update
  after 350
  file copy source [ file join $target tkwice ]
  .content.progress.1 configure -text { 50%}
  .content.progress.4 configure -background {#aa0044} -foreground {#f3f3f3}
  set text2 "$text2 [::msgcat::mc {done.}]"
  .content.text2 configure -text $text2
  update
  after 350
  # startup script
  .content.progress.1 configure -text { 63%}
  .content.progress.5 configure -background {#aa0044} -foreground {#f3f3f3}
  set text3 [::msgcat::mc {creating script files ...}]
  label .content.text3 -text $text3 -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  pack .content.text3 -side top -fill x
  update
  after 350
  if { $operating_system == "unix" } {
    set targetscript [ file join $target tkwice bin tkwice ]
    set exec_string "[ info nameofexecutable ] [ file join $target tkwice tkwice.tcl ]"
    set scriptchannel [ open $targetscript w ]
    puts $scriptchannel {#!/bin/sh}
    puts $scriptchannel {# small wrapper to start up TkWiCe}
    puts $scriptchannel {}
    puts $scriptchannel "${exec_string} \$@"
    puts $scriptchannel {}
    close $scriptchannel
    file attributes $targetscript -permissions rwxrwxr-x
    set text3 "$text3 [::msgcat::mc {done.}]"
  } elseif { $operating_system == "windows" } {
    set targetscript [ file join $target tkwice tkwice.bat ]
    set exec_string "[ file nativename [ info nameofexecutable ] ] \"[ file nativename [ file join $target tkwice tkwice.tcl ] ]\""
    set scriptchannel [ open $targetscript w ]
    puts $scriptchannel {@ECHO off}
    puts $scriptchannel {}
    puts $scriptchannel "${exec_string} %1"
    puts $scriptchannel {}
    close $scriptchannel
    set text3 "$text3 [::msgcat::mc {done.}]"
  } else {
    set text3 "$text3 [::msgcat::mc {nothing to do.}]"
  }
  .content.progress.1 configure -text { 75%}
  .content.progress.6 configure -background {#aa0044} -foreground {#f3f3f3}

  .content.text3 configure -text $text3
  update
  after 350
  # check
  .content.progress.1 configure -text { 88%}
  .content.progress.7 configure -background {#aa0044} -foreground {#f3f3f3}
  set text4 [::msgcat::mc {checking new installation ...}]
  label .content.text4 -text $text4 -font $textfont -background {#f3f3f3} -foreground {#111111} -anchor w
  pack .content.text4 -side top -fill x
  update
  after 350
  set error_check {false}
  if { [ file exists [ file join $target tkwice tkwice.tcl ] ] == "1" && [ file exists [ file join $target tkwice VERSION ] ] == "1" && [ file exists [ file join $target tkwice tcl editwine.tcl ] ] == "1" } {
    set targetversionchannel [ open [ file join $target tkwice VERSION ] r ]
    set targetversion [ read $targetversionchannel ]
    close $targetversionchannel
    set sourceversionchannel [ open [ file join source VERSION ] r ]
    set sourceversion [ read $sourceversionchannel ]
    close $sourceversionchannel
    if { $targetversion == $sourceversion } {
      set text4 "$text4 [::msgcat::mc {done.}]"
    } else {
      set error_check {true}
    }
  } else {
    set error_check {true}
  }
  if { $error_check == "true" } {
    .content.title configure -text [::msgcat::mc {Error!}]
    set text4 "$text4 [::msgcat::mc {Error!}]"
    .content.text4 configure -text $text4
    set text4 [::msgcat::mc {Something went wrong - can't go on!}]
    label .content.text4 -text $text4 -font $titlefont -background {#f3f3f3} -foreground {#111111} -anchor w
    pack .content.text4 -side top -fill x
    .buttonbar.abort.button configure -state normal -command { exit }
    tkwait window .
  }
  .content.progress.1 configure -text {100%}
  .content.progress.8 configure -background {#aa0044} -foreground {#f3f3f3}
  .content.text4 configure -text $text4
  update
  after 350
  .buttonbar.next.button configure -state normal
  .buttonbar.next.button invoke
}


proc done_inst {} {
  global titlefont textfont steps target exec_string aborttext nls prog_dir steps_full update add_link targetscript
  .buttonbar.next.button configure -command {
    destroy .content.text
    if { [ winfo exists .content.exec ] == "1" } { destroy .content.exec }
    set steps $steps_full
    if { $operating_system == "unix" || $operating_system == "generic" || $add_link == "true" } {
      add_link
    } else {
      add_startmenu
    }
  }
  .titlebar.step configure -text "9/${steps}"
  .content.title configure -text [ ::msgcat::mc {Congratulations!} ]
  text .content.text -wrap word -height 1 -width 1 -font $textfont -background {#f3f3f3} -foreground {#111111} -relief flat -borderwidth 0 -highlightthickness 0
  if { $update == "yes" } {
    .content.text insert end [::msgcat::mc {Your TkWiCe update was successfull. To start it just execute it the way you did it before. You can exit this install wizard now. Alternative you can go on through the steps of a full, new installation, too.}]
  } else {
    .content.text insert end [::msgcat::mc {Your wine cellar software is now installed; To start it just execute the following line (may work even without the interpreter call). If that's enough for you, you can exit this install wizard now. For additional stuff (informations, shortcuts etc.) switch to the next step.}]
  }
  .content.text configure -state disabled
  pack .content.text -side top -fill both -expand true -pady 10
  set exec_string "[ info nameofexecutable ] [ file join $target tkwice tkwice.tcl ]"
  if { $update == "no" } {
    frame .content.exec -background {#f3f3f3}
      label .content.exec.1 -text $exec_string -font $textfont -background {#ffffff} -foreground {#111111} -padx 5 -pady 0
      frame .content.exec.2 -relief raised -borderwidth 2 -background {#aa0044} -padx 0 -pady 0
      button .content.exec.2.button -text [::msgcat::mc {Test}] -font $textfont -padx 5 -pady 0 -relief flat -background {#ffffff} -foreground {#111111} -activebackground {#aa0044} -activeforeground {#ffffff} -highlightthickness 0 -command "exec $exec_string"
      pack .content.exec.2.button -padx 0 -pady 0
    pack .content.exec.1 .content.exec.2 -side left -padx 5
  pack .content.exec -side top -pady 10
  }
  set aborttext [ .buttonbar.abort.button cget -text ]
  .buttonbar.abort.button configure -text [::msgcat::mc {Exit}]
}


proc add_link {} {
  global titlefont textfont steps aborttext add_link exec_string operating_system nls prog_dir target bin_create targetscript
  .buttonbar.next.button configure -command {
    if { $add_link == "true" } {
      if { $target == {/opt} } {
        if { [ file isdirectory /opt/bin ] != "1" } { file mkdir /opt/bin }
      } elseif { [ file writable /usr/local/bin ] == "1"} {
        set targetscript {/usr/local/bin/tkwice}
      } else {
        if { [ file isdirectory [ file join ~ bin ] ] != "1" } {
          file mkdir [ file join ~ bin ]
          file attributes [ file join ~ bin ] -permissions rwxrwxr-x
          set bin_create {true}
        }
        set targetscript [ file join ~ bin tkwice ]
      }
      set scriptchannel [ open $targetscript w ]
      puts $scriptchannel {#!/bin/sh}
      puts $scriptchannel {# small wrapper for TkWiCe}
      puts $scriptchannel {}
      puts $scriptchannel "${exec_string} \$@"
      puts $scriptchannel {}
      close $scriptchannel
      file attributes $targetscript -permissions rwxrwxr-x
      update
    }
    destroy .content.add_link
    destroy .content.text
    add_startmenu
  }
  if { $target == {/opt} } {
    set targetscript {/opt/bin/tkwice}
  } elseif { [ file writable /usr/local/bin ] == "1"} {
    set targetscript {/usr/local/bin/tkwice}
  } else {
    if { [ file isdirectory [ file join ~ bin ] ] != "1" } {
      set bin_create {true}
    }
    set targetscript [ file join ~ bin tkwice ]
  }
  if { [ file exists $targetscript ] == "1" } { file delete $targetscript }
  .titlebar.step configure -text "10/${steps}"
  .content.title configure -text [::msgcat::mc {Filesystem Link}]
  .buttonbar.abort.button configure -text $aborttext
  checkbutton .content.add_link -text [::msgcat::mc {create a startup script in $PATH}] -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable add_link -offvalue false -onvalue true
  pack .content.add_link -side top -fill x -pady 0
  if { $operating_system == "macintosh" || $operating_system == "generic" } {
    set add_link {false}
    if { [ auto_execok /bin/sh ] != "" && [ file isdirectory /usr/local/ ] == "1" && [ auto_execok ln ] != "" } {
      set add_link {true}
    }
  }
  if { $add_link == "true" } {
    set text [::msgcat::mc {If you enable this, a short shell script will be created to start TkWiCe by just entering "tkwice" ("/usr/local/bin/tkwice" if possible, otherwise "~/bin/tkwice" - which might not be in your $PATH by default). Missing target directories will be created, and a existing file will be replaced.}]
  } else {
    if { $operating_system != "generic" } { .content.add_link configure -state disabled }
    set text [::msgcat::mc {Feature only relevant on unix like operating systems, and maybe even unnecessary on yours.}]
  }
  text .content.text -wrap word -height 1 -width 1 -font $textfont -background {#f3f3f3} -foreground {#111111} -relief flat -borderwidth 0 -highlightthickness 0
  pack .content.text -side top -fill both -expand true -pady 10
  .content.text insert end $text
  if { $bin_create != {true} && $add_link == {true} } {
   .content.text insert end "\n ${targetscript} "
   .content.text insert end [::msgcat::mc {is not supposed to be in path ...}]
  }
  .content.text configure -state disabled
}


proc add_startmenu {} {
  global titlefont textfont steps target exec_string add_startmenu operating_system nls prog_dir targetscript
  .buttonbar.next.button configure -command {
    if { $add_startmenu == "true" && $operating_system == "unix" } {
      if { [ file writable /usr/share/applications ] && [ file isdirectory /usr/share/applications ] } {
        set menutarget {/usr/local/applications}
      } elseif { [ file writable /usr/local/share/applications ] && [ file isdirectory /usr/local/share/applications ] } {
        set menutarget {/usr/local/share/applications}
      } else {
        if { [ file isdirectory [ file join ~ .local ] ] != "1" } { file mkdir [ file join ~ .local ] }
        if { [ file isdirectory [ file join ~ .local share ] ] != "1" } { file mkdir [ file join ~ .local share ] }
        if { [ file isdirectory [ file join ~ .local share applications ] ] != "1" } { file mkdir [ file join ~ .local share applications ] }
        set menutarget [ file join ~ .local share applications ]
      }
      set menutarget [ file join $menutarget tkwice.desktop ]
      if { [ file exists $menutarget ] == "1" } { file delete $menutarget }
      set scriptchannel [ open $menutarget w ]
      puts $scriptchannel {[Desktop Entry]}
      puts $scriptchannel {Version=1.0}
      puts $scriptchannel {Type=Application}
      puts $scriptchannel {Name=TkWiCe}
      puts $scriptchannel {Comment=wine cellar manager}
      puts $scriptchannel {Comment[de]=Weinkellerverwaltung}
      puts $scriptchannel "Exec=$exec_string"
      puts $scriptchannel "Path=[ file join $target tkwice ]"
      puts $scriptchannel "Icon=[ file join $target tkwice tkwice.xpm ]"
      puts $scriptchannel {Terminal=false}
      puts $scriptchannel {Categories=Application;Office;Database;}
      puts $scriptchannel {}
      close $scriptchannel
      update
    } elseif { $add_startmenu == "true" && $operating_system == "windows" } {
      set realfilename [ file nativename [ file join ${target} tkwice tkwice.tcl ] ]
      set groupname {TkWiCe}
      set proglinkname  {TkWiCe}
      set programs_menu [ registry get {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders} Programs ]
      set menu_dir [ file join ${programs_menu} ${groupname} ]
      if { ! [ file isdirectory ${menu_dir} ] } { file mkdir ${menu_dir} }
      if { [ file exists [ file join ${menu_dir} ${proglinkame} ] ] } { file delete [ file join ${menu_dir} ${proglinkname} ] }
      file link [ file join ${menu_dir} ${proglinkname} ] [ file join ${target} tkwice tkwice.tcl ]
    }
    destroy .content.add_startmenu
    destroy .content.text
    add_desktop
  }
  .titlebar.step configure -text "11/${steps}"
  .content.title configure -text [::msgcat::mc {Startmenu Entry}]
  checkbutton .content.add_startmenu -text [::msgcat::mc {create a entry in the startmenu}] -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable add_startmenu -offvalue false -onvalue true
  pack .content.add_startmenu -side top -fill x -pady 0
  if { $operating_system == "macintosh" || $operating_system == "generic" } { set add_startmenu "false"}
  if { $add_startmenu == "true" } {
    if { $operating_system == "windows" } {
      set text [::msgcat::mc {May not work - beta stage!}]
#      set winversion [ registry get {HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion} Version ]
set winversion {Windows 95}
      if { ${winversion} == {Windows 95} || ${winversion} == {Windows 98} || ${winversion} == {Windows ME} } {
        set add_startmenu {false}
        set add_desktop   {false}
        .content.add_startmenu configure -state disabled
        set text [::msgcat::mc {Sorry, unable to do this on your operating system automatically - you've got to do this on your own.}]
      }
    } else {
      set text [::msgcat::mc {The shortcut will be according to standards from "freedesktop.org". It only takes effect if your desktop environment is conform to it.}]
    }
  } elseif { $operating_system == "macintosh" || $operating_system == "generic" } {
    .content.add_startmenu configure -state disabled
    set text [::msgcat::mc {Sorry, unable to do this on your operating system automatically - you've got to do this on your own.}]
  } else {
    .content.add_startmenu configure -state disabled
    set text [::msgcat::mc {Sorry, unable to do this on your operating system automatically - you've got to do this on your own.}]
  }
  text .content.text -wrap word -height 1 -width 1 -font $textfont -background {#f3f3f3} -foreground {#111111} -relief flat -borderwidth 0 -highlightthickness 0
  pack .content.text -side top -fill both -expand true -pady 10
  .content.text insert end $text
  .content.text configure -state disabled
}


proc add_desktop {} {
  global titlefont textfont steps add_desktop operating_system target exec_string nls prog_dir targetscript
  .buttonbar.next.button configure -command {
    if { $add_desktop == "true" && $operating_system == "windows" } {
      set realfilename [ file nativename [ file join ${target} tkwice tkwice.tcl ] ]
      set win_desktop [ registry get {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders} Desktop ]
      if { [ file exists [ file nativename [ file join ${win_desktop} TkWiCe ] ] ] } { file delete [ file nativename [ file join ${win_desktop} TkWiCe ] ]  }
      file link [ file nativename [ file join ${win_desktop} TkWiCe ] ] ${realfilename}
    } elseif { $add_desktop == "true" && $operating_system == "unix" } {
      if { [ file isdirectory [ file join ~ Desktop ] ] != "1" } { file mkdir [ file join ~ Desktop ] }
      set menutarget [ file join ~ Desktop tkwice.desktop ]
      if { [ file exists $menutarget ] == "1" } { file delete $menutarget }
      set scriptchannel [ open $menutarget w ]
      puts $scriptchannel {[Desktop Entry]}
      puts $scriptchannel {Version=1.0}
      puts $scriptchannel {Type=Application}
      puts $scriptchannel {Name=TkWiCe}
      puts $scriptchannel {Comment=wine cellar manager}
      puts $scriptchannel {Comment[de]=Weinkellerverwaltung}
      puts $scriptchannel "Exec=$exec_string"
      puts $scriptchannel "Path=[ file join $target tkwice ]"
      puts $scriptchannel "Icon=[ file join $target tkwice tkwice.xpm ]"
      puts $scriptchannel {Terminal=false}
      puts $scriptchannel {Categories=Application;Office;Database;}
      puts $scriptchannel {}
      close $scriptchannel
      update
    }
    destroy .content.add_desktop
    destroy .content.text
    end
  }
  .titlebar.step configure -text "12/${steps}"
  .content.title configure -text [::msgcat::mc {Desktop Shortcut}]
  checkbutton .content.add_desktop -text [::msgcat::mc {create a shortcut to the desktop}] -font $textfont -background {#f3f3f3} -foreground {#111111} -activebackground {#f3f3f3} -activeforeground {#111111} -highlightthickness 0 -anchor w -variable add_desktop -offvalue false -onvalue true
  pack .content.add_desktop -side top -fill x -pady 0
  if { $operating_system == "macintosh" || $operating_system == "generic" } { set add_desktop "false"}
  if { $add_desktop == "true" } {
    if { $operating_system == "windows" } {
      set text [::msgcat::mc {May not work - beta stage!}]
#      set winversion [ registry get {HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion} Version ]
set winversion {Windows 95}
      if { ${winversion} == {Windows 95} || ${winversion} == {Windows 98} || ${winversion} == {Windows ME} } {
        set add_startmenu {false}
        set add_desktop   {false}
        .content.add_desktop configure -state disabled
        set text [::msgcat::mc {Sorry, unable to do this on your operating system automatically - you've got to do this on your own.}]
      }
    } else {
      set text [::msgcat::mc {The shortcut will created in the "~/Desktop" directory according to standards from "freedesktop.org". It only takes effect if your desktop environment is conform to it.}]
    }
  } else {
    .content.add_desktop configure -state disabled
    set text [::msgcat::mc {Sorry, unable to do this on your operating system automatically - you've got to do this on your own.}]
  }
  text .content.text -wrap word -height 1 -width 1 -font $textfont -background {#f3f3f3} -foreground {#111111} -relief flat -borderwidth 0 -highlightthickness 0
  pack .content.text -side top -fill both -expand true -pady 10
  .content.text insert end $text
  .content.text configure -state disabled
}


proc end {} {
  global titlefont textfont steps update nls prog_dir target exec_string targetscript
  destroy .buttonbar.abort
  .buttonbar.next.button configure -text [::msgcat::mc {Exit}] -command {
    exit
  }
  set text {}
  .titlebar.step configure -text "${steps}/${steps}"
  .content.title configure -text [::msgcat::mc {Congratulations!}]
  if { $update == "yes" } {
    set text [::msgcat::mc "Your TkWiCe update was successfull.\n\nHave fun!"]
  } else {
    set text [::msgcat::mc "Your new wine cellar manager is now fully installed on your computer.\n\nHave fun!"]
  }
  text .content.text -wrap word -height 1 -width 1 -font $textfont -background {#f3f3f3} -foreground {#111111} -relief flat -borderwidth 0 -highlightthickness 0
  pack .content.text -side top -fill both -expand true -pady 10
  .content.text insert end $text
  .content.text configure -state disabled
}


# load messages
msgcat::mclocale ${nls}
msgcat::mcload [ file join nls ]


# main window
frame .titlebar -relief raised -borderwidth 2 -background {#aa0044} -padx 3 -pady 3
label .titlebar.text -text $progname -font $titlefont -background {#aa0044} -foreground {#ffffff} -anchor w
pack .titlebar.text -side left -fill x
label .titlebar.prestep -text [ ::msgcat::mc {Step} ] -font $textfont -background {#aa0044} -foreground {#ffffff} -anchor e
label .titlebar.step -text {} -font $textfont -background {#aa0044} -foreground {#ffffff} -anchor e
pack .titlebar.step -side right
pack .titlebar.prestep -side right
frame .logobar -padx 0 -pady 0 -background {#ffffff}
label .logobar.logo -image $logo -padx 5 -pady 0 -anchor w -background {#ffffff}
label .logobar.icon -image $icon -padx 0 -pady 0 -anchor e -background {#ffffff}
pack .logobar.logo .logobar.icon -side left -fill x -expand true
frame .blank -height 10
frame .content -padx 10 -pady 10 -background {#f3f3f3} -borderwidth 1 -relief solid
frame .buttonbar -padx 3 -pady 3 -background {#ffffff}
frame .buttonbar.abort -relief raised -borderwidth 2 -background {#aa0044} -padx 0 -pady 0
button .buttonbar.abort.button -text [ ::msgcat::mc {Abort} ] -font $textfont -padx 10 -pady 0 -relief flat -background {#ffffff} -foreground {#111111} -activebackground {#aa0044} -activeforeground {#ffffff} -highlightthickness 0 -command { exit }
pack .buttonbar.abort.button -padx 0 -pady 0
label .buttonbar.blank1 -text { } -font $textfont -background {#ffffff}
frame .buttonbar.back -relief raised -borderwidth 2 -background {#aa0044} -padx 0 -pady 0
button .buttonbar.back.button -text [ ::msgcat::mc {Back} ] -font $textfont -padx 10 -pady 0 -relief flat -background {#ffffff} -foreground {#111111} -activebackground {#aa0044} -activeforeground {#ffffff} -highlightthickness 0 -command { }
pack .buttonbar.back.button -padx 0 -pady 0
label .buttonbar.blank2 -text { } -font $textfont -background {#ffffff}
frame .buttonbar.next -relief raised -borderwidth 2 -background {#aa0044} -padx 0 -pady 0
button .buttonbar.next.button -text [ ::msgcat::mc {Next} ] -font $textfont -padx 10 -pady 0 -relief flat -background {#ffffff} -foreground {#111111} -activebackground {#aa0044} -activeforeground {#ffffff} -highlightthickness 0 -command { operating_system }
pack .buttonbar.next.button -padx 0 -pady 0
pack .buttonbar.next .buttonbar.blank2 .buttonbar.back .buttonbar.blank1 .buttonbar.abort -side right
pack .titlebar  -side top -fill x    -padx 10 -pady 10
pack .logobar   -side top -fill x    -padx 10 -pady  0
pack .blank     -side top
pack .content   -side top -fill both -padx 10 -pady  0 -expand true
pack .buttonbar -side top -fill x    -padx 10 -pady 10
. configure -background {#ffffff}


# startup
copy
