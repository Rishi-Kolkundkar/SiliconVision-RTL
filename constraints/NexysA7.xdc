## Clock signal (100 MHz onboard oscillator)
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { CLK }];

## Control Inputs
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { reset }]; # BTNC
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { start }]; # SW0

## Status Output
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { done_led }]; # LED0

## Debug Outputs (Anti-Optimization Shield mapped to LED15 - LED8)
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { debug[7] }]; # LED15
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { debug[6] }]; # LED14
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { debug[5] }]; # LED13
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { debug[4] }]; # LED12
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { debug[3] }]; # LED11
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { debug[2] }]; # LED10
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { debug[1] }]; # LED9
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { debug[0] }]; # LED8

## Configuration
set_property CFG_EXTRACT_RESET_DIRECTION true [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

## USB-UART Interface
set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports { usb_rx }]; # FPGA receives from PC
set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports { usb_tx }]; # FPGA transmits to PC