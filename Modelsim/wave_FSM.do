onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Display
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/CSx
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/RESx
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/DCx
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/WRx
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/RDx
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/DATAx
add wave -noupdate -divider FSM
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/clk
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/nres
add wave -noupdate /HX8357_FSM_tb/disp_FSM/state
add wave -noupdate /HX8357_FSM_tb/disp_FSM/next_state
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/transmission_cmpl
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/data_lines
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/cmd
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/data
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/init
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/init_next
add wave -noupdate -radix unsigned /HX8357_FSM_tb/disp_FSM/cnt
add wave -noupdate -radix unsigned /HX8357_FSM_tb/disp_FSM/cnt_next
add wave -noupdate -radix unsigned /HX8357_FSM_tb/disp_FSM/inst_cnt
add wave -noupdate -radix unsigned /HX8357_FSM_tb/disp_FSM/inst_cnt_next
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/in_sleep
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/inst
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/inst_type
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/instruction
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_FSM/delay
add wave -noupdate -divider Controller
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_cont/clk
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_cont/nres
add wave -noupdate /HX8357_FSM_tb/disp_cont/state
add wave -noupdate /HX8357_FSM_tb/disp_cont/next_state
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_cont/data_in
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_cont/cmd
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_cont/data
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_cont/transmission_cmpl
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_cont/DorC
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_cont/DorC_next
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_cont/data_sample
add wave -noupdate -radix hexadecimal /HX8357_FSM_tb/disp_cont/data_sample_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {650 ns} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {603 ns} {1435 ns}
