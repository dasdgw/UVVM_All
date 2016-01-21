#========================================================================================================================
# Copyright (c) 2016 by Bitvis AS.  All rights reserved.
#
# UVVM UTILITY LIBRARY AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM UTILITY LIBRARY.
#========================================================================================================================

# This file may be called with an argument
# arg 1: Part directory of this library/module

# Overload quietly (Modelsim specific command) to let it work in Riviera-Pro
proc quietly { args } {
  if {[llength $args] == 0} {
    puts "quietly"
  } else {
    # this works since tcl prompt only prints the last command given. list prints "".
    uplevel $args; list;
  }
}

if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
} else {
  onerror {abort all}
}
#Just in case...
quietly quit -sim   

# Detect simulator
if {[catch {eval "vsim -version"} message] == 0} { 
  quietly set version [eval "vsim -version"]
  # puts "Version is: $version"
  if {[regexp -nocase {modelsim} $version]} {
    quietly set simulator "modelsim"
  } elseif {[regexp -nocase {aldec} $version]} {
    quietly set simulator "rivierapro"
  } else {
    puts "Unknown simulator. Attempting use use Modelsim commands."
    quietly set simulator "modelsim"
  }  
} else { 
    puts "vsim -version failed with the following message:\n $message"
    abort all
}

# Set up uart_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_uart"
quietly set part_name "bitvis_uart"
# path from mpf-file in sim
quietly set uart_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set uart_part_path "$1/..//$part_name"
  unset 1
}


# Testbenches reside in the design library. Hence no regeneration of lib.
#------------------------------------------------------------------------

if { [string equal -nocase $simulator "modelsim"] } {
  set compdirectives "-2008 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -dbg -work $lib_name"
}

eval vcom  $compdirectives  $uart_part_path/tb/uart_vvc_th.vhd
eval vcom  $compdirectives  $uart_part_path/tb/uart_vvc_tb.vhd
