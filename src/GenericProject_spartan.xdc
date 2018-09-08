##CONFIG
#set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVTTL } [get_ports { cclk }]; #CCLK_0 cclk

##Clock interface
set_property -dict { PACKAGE_PIN G11   IOSTANDARD LVTTL } [get_ports { clk_50 }]; #IO_L12P_T1_MRCC_14 clk_50
create_clock -add -name clk_50 -period 20.00 [get_ports { clk_50 }];

set_property -dict { PACKAGE_PIN G4   IOSTANDARD LVTTL } [get_ports { clk_32 }]; #IO_L12N_T1_MRCC_14 clk_32

##Userlogic interface
# set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVTTL } [get_ports { userlogic_busy }]; #IO_L1P_T0_D00_MOSI_14 userlogic_busy
# set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVTTL } [get_ports { userlogic_sleep }]; #IO_L1N_T0_D01_DIN_14 userlogic_sleep


##Flash Interface
set_property -dict { PACKAGE_PIN C10   IOSTANDARD LVTTL } [get_ports { flash_ce }]; #IO_L2N_T0_D03_14 flash_ce
set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVTTL } [get_ports { flash_si }]; #IO_L2P_T0_D02_14 flash_si

##LEDs interface
set_property -dict { PACKAGE_PIN A12   IOSTANDARD LVTTL } [get_ports { leds[0] }]; #IO_L4P_T0_D04_14 leds[0]
set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVTTL } [get_ports { leds[1] }]; #IO_L4N_T0_D05_14 leds[1]
set_property -dict { PACKAGE_PIN B13   IOSTANDARD LVTTL } [get_ports { leds[2] }]; #IO_L5P_T0_D06_14 leds[2]
set_property -dict { PACKAGE_PIN B14   IOSTANDARD LVTTL } [get_ports { leds[3] }]; #IO_L5N_T0_D07_14 leds[3]

##GPIOs
set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVTTL } [get_ports { gpio[0] }]; #IO_L6N_T0_D08_VREF_14 gpio[0]
set_property -dict { PACKAGE_PIN F12   IOSTANDARD LVTTL } [get_ports { gpio[1] }]; #IO_L7P_T1_D09_14 gpio[1]
set_property -dict { PACKAGE_PIN E12   IOSTANDARD LVTTL } [get_ports { gpio[2] }]; #IO_L7N_T1_D10_14 gpio[2]
set_property -dict { PACKAGE_PIN D12   IOSTANDARD LVTTL } [get_ports { gpio[3] }]; #IO_L8P_T1_D11_14 gpio[3]
set_property -dict { PACKAGE_PIN D13   IOSTANDARD LVTTL } [get_ports { gpio[4] }]; #IO_L8N_T1_D12_14 gpio[4]
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVTTL } [get_ports { gpio[5] }]; #IO_L9P_T1_DQS_14 gpio[5]
set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVTTL } [get_ports { gpio[6] }]; #IO_L9N_T1_DQS_D13_14 gpio[6]
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVTTL } [get_ports { gpio[7] }]; #IO_L10P_T1_D14_14 gpio[7]
set_property -dict { PACKAGE_PIN E13   IOSTANDARD LVTTL } [get_ports { gpio[8] }]; #IO_L10N_T1_D15_14 gpio[8]
set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVTTL } [get_ports { gpio[9] }]; #IO_L11P_T1_SRCC_14 gpio[9]

set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVTTL } [get_ports { gpio[10] }]; #IO_L11N_T1_SRCC_14 gpio[10]
set_property -dict { PACKAGE_PIN H11   IOSTANDARD LVTTL } [get_ports { gpio[11] }]; #IO_L13P_T2_MRCC_14 gpio[11]
set_property -dict { PACKAGE_PIN H12   IOSTANDARD LVTTL } [get_ports { gpio[12] }]; #IO_L13N_T2_MRCC_14 gpio[12]
set_property -dict { PACKAGE_PIN H13   IOSTANDARD LVTTL } [get_ports { gpio[13] }]; #IO_L14P_T2_SRCC_14 gpio[13]
set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVTTL } [get_ports { gpio[14] }]; #IO_L14N_T2_SRCC_14 gpio[14]
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVTTL } [get_ports { gpio[15] }]; #IO_L15P_T2_DQS_RDWR_B_14 gpio[15]
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVTTL } [get_ports { gpio[16] }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 gpio[16]
set_property -dict { PACKAGE_PIN L12   IOSTANDARD LVTTL } [get_ports { gpio[17] }]; #IO_L16P_T2_CSI_B_14 gpio[17]
set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVTTL } [get_ports { gpio[18] }]; #IO_L16N_T2_D31_14 gpio[18]
set_property -dict { PACKAGE_PIN J11   IOSTANDARD LVTTL } [get_ports { gpio[19] }]; #IO_L17P_T2_D30_14 gpio[19]

##XMEM
set_property -dict { PACKAGE_PIN J12   IOSTANDARD LVTTL } [get_ports { mcu_ad[0] }]; #IO_L17N_T2_D29_14 mcu_ad[0]
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVTTL } [get_ports { mcu_ad[1] }]; #IO_L18P_T2_D28_14 mcu_ad[1]
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVTTL } [get_ports { mcu_ad[2] }]; #IO_L18N_T2_D27_14 mcu_ad[2]
set_property -dict { PACKAGE_PIN K11   IOSTANDARD LVTTL } [get_ports { mcu_ad[3] }]; #IO_L19P_T3_D26_14 mcu_ad[3]
set_property -dict { PACKAGE_PIN K12   IOSTANDARD LVTTL } [get_ports { mcu_ad[4] }]; #IO_L19N_T3_D25_VREF_14 mcu_ad[4]
set_property -dict { PACKAGE_PIN M11   IOSTANDARD LVTTL } [get_ports { mcu_ad[5] }]; #IO_L20P_T3_D24_14 mcu_ad[5]
set_property -dict { PACKAGE_PIN M12   IOSTANDARD LVTTL } [get_ports { mcu_ad[6] }]; #IO_L20N_T3_D23_14 mcu_ad[6]
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVTTL } [get_ports { mcu_ad[7] }]; #IO_L21P_T3_DQS_14 mcu_ad[7]

set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVTTL } [get_ports { mcu_ale }]; #IO_L21N_T3_DQS_D22_14 mcu_ale

set_property -dict { PACKAGE_PIN P12   IOSTANDARD LVTTL } [get_ports { mcu_a[8] }]; #IO_L22P_T3_D21_14 mcu_a[8]
set_property -dict { PACKAGE_PIN P13   IOSTANDARD LVTTL } [get_ports { mcu_a[9] }]; #IO_L22N_T3_D20_14 mcu_a[9]
set_property -dict { PACKAGE_PIN N10   IOSTANDARD LVTTL } [get_ports { mcu_a[10] }]; #IO_L23P_T3_D19_14 mcu_a[10]
set_property -dict { PACKAGE_PIN N11   IOSTANDARD LVTTL } [get_ports { mcu_a[11] }]; #IO_L23N_T3_D18_14 mcu_a[11]
set_property -dict { PACKAGE_PIN P10   IOSTANDARD LVTTL } [get_ports { mcu_a[12] }]; #IO_L24P_T3_D17_14 mcu_a[12]
set_property -dict { PACKAGE_PIN P11   IOSTANDARD LVTTL } [get_ports { mcu_a[13] }]; #IO_L24N_T3_D16_14 mcu_a[13]
set_property -dict { PACKAGE_PIN M10   IOSTANDARD LVTTL } [get_ports { mcu_a[14] }]; #IO_25_14 mcu_a[14]


set_property -dict { PACKAGE_PIN D3   IOSTANDARD LVTTL } [get_ports { mcu_rd }]; #IO_L1P_T0_34 mcu_rd
set_property -dict { PACKAGE_PIN C3   IOSTANDARD LVTTL } [get_ports { mcu_wr }]; #IO_L1N_T0_34 mcu_wr
