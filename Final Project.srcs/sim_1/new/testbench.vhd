library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity testbench is
end testbench;

architecture simple of testbench is
	signal center_sig, left_sig, right_sig, current_sig,
		delta_left_sig, delta_right_sig, y_sig, y_7s_sig : std_logic_vector(15 downto 0);
begin
	DUT : entity work.tilt_meter(simple)
		port map (
			center => center_sig,
			left => left_sig,
			right => right_sig,
			current => current_sig,
			delta_left => delta_left_sig,
			delta_right => delta_right_sig,
			y => y_sig,
			y_7s => y_7s_sig
		);
	
	left_sig <= std_logic_vector(to_signed(70, 16));
	right_sig <= std_logic_vector(to_signed(-70, 16));
	center_sig <= std_logic_vector(to_signed(0, 16));
	current_sig <= std_logic_vector(to_signed(0, 16)) after 0 ms,
		std_logic_vector(to_signed(10, 16)) after 1 ms,
		std_logic_vector(to_signed(20, 16)) after 2 ms,
		std_logic_vector(to_signed(30, 16)) after 3 ms,
		std_logic_vector(to_signed(40, 16)) after 4 ms,
		std_logic_vector(to_signed(50, 16)) after 5 ms,
		std_logic_vector(to_signed(60, 16)) after 6 ms,
		std_logic_vector(to_signed(70, 16)) after 7 ms,
		std_logic_vector(to_signed(-10, 16)) after 8 ms,
		std_logic_vector(to_signed(-20, 16)) after 9 ms,
		std_logic_vector(to_signed(-30, 16)) after 10 ms,
		std_logic_vector(to_signed(-40, 16)) after 11 ms,
		std_logic_vector(to_signed(-50, 16)) after 12 ms,
		std_logic_vector(to_signed(-60, 16)) after 13 ms,
		std_logic_vector(to_signed(-70, 16)) after 14 ms,
		std_logic_vector(to_signed(-80, 16)) after 15 ms;
end simple;
