onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/io/clk
add wave -noupdate /top/io/load_en
add wave -noupdate /top/io/reset_n
add wave -noupdate /top/io/opcode
add wave -noupdate /top/io/operand_a
add wave -noupdate /top/io/operand_b
add wave -noupdate /top/io/write_pointer
add wave -noupdate /top/io/read_pointer
add wave -noupdate /top/io/instruction_word
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {51 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ns} {163 ns}
