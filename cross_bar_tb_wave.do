onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cross_bar_tb/PCLK
add wave -noupdate /cross_bar_tb/PRESETN
add wave -noupdate /cross_bar_tb/slave_sel
add wave -noupdate /cross_bar_tb/cmd_sel
add wave -noupdate /cross_bar_tb/trans_num
add wave -noupdate -radix hexadecimal /cross_bar_tb/addr
add wave -noupdate -color {Medium Orchid} -radix unsigned /cross_bar_tb/master_1_rd_err_cnt
add wave -noupdate -color {Medium Orchid} -radix unsigned /cross_bar_tb/master_1_wr_err_cnt
add wave -noupdate -color {Medium Orchid} -radix unsigned /cross_bar_tb/master_2_rd_err_cnt
add wave -noupdate -color {Medium Orchid} -radix unsigned /cross_bar_tb/master_2_wr_err_cnt
add wave -noupdate -color {Medium Orchid} -radix binary /cross_bar_tb/cross_bar_0/slave_1_state
add wave -noupdate -color {Medium Orchid} -radix binary /cross_bar_tb/cross_bar_0/slave_2_state

add wave -noupdate -color {Orange} /cross_bar_tb/master_1_req
add wave -noupdate -color {Orange} /cross_bar_tb/master_1_cmd
add wave -noupdate -color {Orange} -radix hexadecimal /cross_bar_tb/master_1_addr
add wave -noupdate -color {Orange} -radix hexadecimal /cross_bar_tb/master_1_wdata
add wave -noupdate -color {Orange} /cross_bar_tb/master_1_ack
add wave -noupdate -color {Orange} -radix hexadecimal /cross_bar_tb/master_1_rdata

add wave -noupdate -color {Orange} /cross_bar_tb/master_2_req
add wave -noupdate -color {Orange} /cross_bar_tb/master_2_cmd
add wave -noupdate -color {Orange} -radix hexadecimal /cross_bar_tb/master_2_addr
add wave -noupdate -color {Orange} -radix hexadecimal /cross_bar_tb/master_2_wdata
add wave -noupdate -color {Orange} /cross_bar_tb/master_2_ack
add wave -noupdate -color {Orange} -radix hexadecimal /cross_bar_tb/master_2_rdata

add wave -noupdate /cross_bar_tb/slave_1_req
add wave -noupdate /cross_bar_tb/slave_1_cmd
add wave -noupdate -radix hexadecimal /cross_bar_tb/slave_1_addr
add wave -noupdate -radix hexadecimal /cross_bar_tb/slave_1_wdata
add wave -noupdate /cross_bar_tb/slave_1_ack
add wave -noupdate -radix hexadecimal /cross_bar_tb/slave_1_rdata
add wave -noupdate -radix hexadecimal /cross_bar_tb/slave_1_memory

add wave -noupdate /cross_bar_tb/slave_2_req
add wave -noupdate /cross_bar_tb/slave_2_cmd
add wave -noupdate -radix hexadecimal /cross_bar_tb/slave_2_addr
add wave -noupdate -radix hexadecimal /cross_bar_tb/slave_2_wdata
add wave -noupdate /cross_bar_tb/slave_2_ack
add wave -noupdate -radix hexadecimal /cross_bar_tb/slave_2_rdata
add wave -noupdate -radix hexadecimal /cross_bar_tb/slave_2_memory

add wave -noupdate /cross_bar_tb/i
add wave -noupdate -radix hexadecimal /cross_bar_tb/wdata
add wave -noupdate -radix hexadecimal /cross_bar_tb/rdata
add wave -noupdate /cross_bar_tb/ack1_delay
add wave -noupdate /cross_bar_tb/ack2_delay
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1183487 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 362
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {39852 ps} {1527524 ps}


run -all