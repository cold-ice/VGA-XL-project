onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /vga_decoder_tb/CLOCK_25
add wave -noupdate /vga_decoder_tb/SYS0
add wave -noupdate /vga_decoder_tb/SYS1
add wave -noupdate /vga_decoder_tb/SYS2
add wave -noupdate /vga_decoder_tb/SYS3
add wave -noupdate /vga_decoder_tb/HCHECK
add wave -noupdate /vga_decoder_tb/VCHECK
add wave -noupdate /vga_decoder_tb/TOTCHECK
add wave -noupdate /vga_decoder_tb/ROW
add wave -noupdate /vga_decoder_tb/COLUMN
add wave -noupdate /vga_decoder_tb/CHECKX
add wave -noupdate /vga_decoder_tb/CHECKY
add wave -noupdate /vga_decoder_tb/CHECKZ
add wave -noupdate -radix hexadecimal -radixshowbase 0 /vga_decoder_tb/XPOS
add wave -noupdate -radix hexadecimal -radixshowbase 0 /vga_decoder_tb/YPOS
add wave -noupdate -radix hexadecimal -radixshowbase 0 /vga_decoder_tb/ZPOS
add wave -noupdate /vga_decoder_tb/H_S
add wave -noupdate /vga_decoder_tb/H_BACK_PORCH
add wave -noupdate /vga_decoder_tb/H_VIDEO_OUT
add wave -noupdate /vga_decoder_tb/H_FRONT_PORCH
add wave -noupdate /vga_decoder_tb/H_BEGIN
add wave -noupdate /vga_decoder_tb/H_END
add wave -noupdate /vga_decoder_tb/V_S
add wave -noupdate /vga_decoder_tb/V_BACK_PORCH
add wave -noupdate /vga_decoder_tb/V_VIDEO_OUT
add wave -noupdate /vga_decoder_tb/V_FRONT_PORCH
add wave -noupdate /vga_decoder_tb/V_BEGIN
add wave -noupdate /vga_decoder_tb/V_END
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
