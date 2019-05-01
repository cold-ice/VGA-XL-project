onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /rs232_tb/uut/clk
add wave -noupdate /rs232_tb/uut/rst
add wave -noupdate /rs232_tb/uut/uart_line
add wave -noupdate /rs232_tb/uut/data_out_ready
add wave -noupdate -radix hexadecimal /rs232_tb/uut/data_out
add wave -noupdate -radix hexadecimal /rs232_tb/uut/data_out_x
add wave -noupdate -radix hexadecimal /rs232_tb/uut/data_out_y
add wave -noupdate -radix hexadecimal /rs232_tb/uut/data_out_z
add wave -noupdate /rs232_tb/uut/uart_clock_out
add wave -noupdate /rs232_tb/uut/status
add wave -noupdate /rs232_tb/uut/uart_clock
add wave -noupdate /rs232_tb/uut/clock_mem
add wave -noupdate /rs232_tb/uut/clear
add wave -noupdate /rs232_tb/uut/tc_char
add wave -noupdate /rs232_tb/uut/shift_enable
add wave -noupdate /rs232_tb/uut/data_in_ready
add wave -noupdate -radix hexadecimal /rs232_tb/uut/data_out_aux
add wave -noupdate /rs232_tb/uut/data_ready_buff
add wave -noupdate /rs232_tb/uut/stato
add wave -noupdate -radix hexadecimal /rs232_tb/uut/divisor
add wave -noupdate -radix hexadecimal /rs232_tb/uut/divisor2
add wave -noupdate /rs232_tb/uut/bits_per_data
add wave -noupdate /rs232_tb/uut/fsm/clock
add wave -noupdate /rs232_tb/uut/fsm/reset
add wave -noupdate /rs232_tb/uut/fsm/uart_line
add wave -noupdate /rs232_tb/uut/fsm/tc_char
add wave -noupdate /rs232_tb/uut/fsm/clear
add wave -noupdate /rs232_tb/uut/fsm/shift_enable
add wave -noupdate /rs232_tb/uut/fsm/waiting
add wave -noupdate /rs232_tb/uut/fsm/current_state
add wave -noupdate /rs232_tb/uut/fsm/next_state
add wave -noupdate /rs232_tb/uut/buff/clock
add wave -noupdate /rs232_tb/uut/buff/reset
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/data_in_buff
add wave -noupdate /rs232_tb/uut/buff/data_in_ready
add wave -noupdate /rs232_tb/uut/buff/data_out_ready
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/data_out_x
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/data_out_y
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/data_out_z
add wave -noupdate /rs232_tb/uut/buff/load_reg1
add wave -noupdate /rs232_tb/uut/buff/load_reg2
add wave -noupdate /rs232_tb/uut/buff/load_reg_buff0
add wave -noupdate /rs232_tb/uut/buff/load_reg_buff1
add wave -noupdate /rs232_tb/uut/buff/load_reg_buff2
add wave -noupdate /rs232_tb/uut/buff/load_reg_buff3
add wave -noupdate /rs232_tb/uut/buff/load_reg_buff4
add wave -noupdate /rs232_tb/uut/buff/load_reg_buff5
add wave -noupdate /rs232_tb/uut/buff/load_out_regs
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/to_start_stop1
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/to_start_stop2
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/start_byte
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/stop_byte
add wave -noupdate /rs232_tb/uut/buff/out_counter3
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg0
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg1
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg2
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg3
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg4
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg5
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg0_out
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg1_out
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg2_out
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg3_out
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg4_out
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/reg5_out
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/in_reg_out1
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/in_reg_out2
add wave -noupdate -radix hexadecimal /rs232_tb/uut/buff/in_reg_out3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2343097 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {5250 ns}
