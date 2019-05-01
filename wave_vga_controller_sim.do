onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /vga_controller_sim/VGA_ctrl/ROWS
add wave -noupdate /vga_controller_sim/VGA_ctrl/COLUMNS
add wave -noupdate /vga_controller_sim/VGA_ctrl/CLOCK_50
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/SW
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/VGA_R
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/VGA_G
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/VGA_B
add wave -noupdate /vga_controller_sim/VGA_ctrl/VGA_CLK
add wave -noupdate /vga_controller_sim/VGA_ctrl/VGA_BLANK
add wave -noupdate /vga_controller_sim/VGA_ctrl/VGA_VS
add wave -noupdate /vga_controller_sim/VGA_ctrl/VGA_HS
add wave -noupdate /vga_controller_sim/VGA_ctrl/LEDR
add wave -noupdate /vga_controller_sim/VGA_ctrl/LEDG
add wave -noupdate /vga_controller_sim/VGA_ctrl/UART_RXD
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/GPIO_1
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/GPIO_0
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/KEY
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/X_UPDATE
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/Y_UPDATE
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/Z_UPDATE
add wave -noupdate /vga_controller_sim/VGA_ctrl/data_out_ready
add wave -noupdate /vga_controller_sim/VGA_ctrl/HC_EN
add wave -noupdate /vga_controller_sim/VGA_ctrl/VC_EN
add wave -noupdate /vga_controller_sim/VGA_ctrl/STR_EN
add wave -noupdate /vga_controller_sim/VGA_ctrl/HC_CL
add wave -noupdate /vga_controller_sim/VGA_ctrl/VC_CL
add wave -noupdate /vga_controller_sim/VGA_ctrl/RGB_EN
add wave -noupdate /vga_controller_sim/VGA_ctrl/HS_CTRL
add wave -noupdate /vga_controller_sim/VGA_ctrl/VS_CTRL
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/X_UPDATE_S
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/Y_UPDATE_S
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/Z_UPDATE_S
add wave -noupdate /vga_controller_sim/VGA_ctrl/RGB_CTRL
add wave -noupdate /vga_controller_sim/VGA_ctrl/ROW
add wave -noupdate /vga_controller_sim/VGA_ctrl/COLUMN
add wave -noupdate /vga_controller_sim/VGA_ctrl/NRES
add wave -noupdate /vga_controller_sim/VGA_ctrl/uart_line
add wave -noupdate /vga_controller_sim/VGA_ctrl/DATA_READY_KEY
add wave -noupdate /vga_controller_sim/VGA_ctrl/FLAG
add wave -noupdate /vga_controller_sim/VGA_ctrl/DATA_READY
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/X_BUFF
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/Y_BUFF
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/Z_BUFF
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/X_KEY
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/Y_KEY
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/Z_KEY
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/COLUMNS
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/CLOCK_50
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/RESET
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/COLUMN
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/HC_EN
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/VC_EN
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/STR_EN
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/HC_CL
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/RGB_CTRL
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/HS_CTRL
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/STATUS
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/NEXTSTATUS
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/H_S
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/H_BACK_PORCH
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/H_VIDEO_OUT
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/H_FRONT_PORCH
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/H_BEGIN
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_H/H_END
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/ROWS
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/CLOCK_50
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/RESET
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/ROW
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/VC_CL
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/RGB_CTRL
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/VS_CTRL
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/STATUS
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/NEXTSTATUS
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/V_S
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/V_BACK_PORCH
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/V_VIDEO_OUT
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/V_FRONT_PORCH
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/V_BEGIN
add wave -noupdate /vga_controller_sim/VGA_ctrl/CU_V/V_END
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/ROWS
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/COLUMNS
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/CLOCK_50
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/HC_EN
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/VC_EN
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/STR_EN
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/RGB_EN
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/HS_CTRL
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/VS_CTRL
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/HC_CL
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/VC_CL
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/ROW
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/COLUMN
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/R
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/G
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/B
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/VS
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/HS
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/VGA_CLK
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/X_UPDATE
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/Y_UPDATE
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/Z_UPDATE
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/data_out_ready
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/STROBE_25
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/PIXEL_Y
add wave -noupdate /vga_controller_sim/VGA_ctrl/DP/PIXEL_X
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/X_RESULT
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/Y_RESULT
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/Z_RESULT
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/XPOS
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/YPOS
add wave -noupdate -radix hexadecimal /vga_controller_sim/VGA_ctrl/DP/ZPOS
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
