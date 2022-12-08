library IEEE;
use IEEE.std_logic_1164.ALL;

entity toplevel is
    port(
		CPU_RESETN : in STD_LOGIC; -- Nexys 4 DDR active low reset button
        SYS_CLK : in STD_LOGIC; -- Nexys 4 DDR 100 MHz clock
        BTNC : in  STD_LOGIC; -- Center button
	    BTNL : in  STD_LOGIC; -- Left button
	    BTNR : in  STD_LOGIC; -- Right button
        LED : out STD_LOGIC_VECTOR(15 downto 0); -- Nexys 4 DDR LEDs
        SW : in STD_LOGIC_VECTOR(15 downto 0); -- Nexys 4 DDR switches
		SCK : out STD_LOGIC; -- SCK to SPI slave
        CS : out STD_LOGIC; -- SPI slave chip select
		MOSI : out STD_LOGIC; -- MOSI out to slave
		MISO : in STD_LOGIC -- MOSI in from slave
	);
end toplevel;

architecture Structural of toplevel is
	constant N : integer := 16; -- number of bits send per SPI transaction
	signal START_sig, tx_start_sig, tx_end_sig, bc_sig, bl_sig, br_sig, not_reset_sig : std_logic;
	signal master_data_parallel_sig, slave_data_parallel_sig,
		x_axis_data_sig, y_axis_data_sig, z_axis_data_sig,
		center_sig, left_sig, right_sig,
		delta_left_sig, delta_right_sig, tilt_meter_sig : std_logic_vector(N-1 downto 0);
	signal zero_sig : std_logic_vector(N-1 downto 0) := x"0000";
begin
	not_reset_sig <= NOT CPU_RESETN;
	clk_div : entity work.clock_divider(behavior)
		generic map(
			-- synthesis
			divisor => 50000000
			-- simulation
			-- divisor => 200000
		)
		port map(
			mclk => SYS_CLK,
			sclk => START_sig
		);
	fsm : entity work.fsm(simple)
		port map(
			i_clk => SYS_CLK,
			i_rstb => CPU_RESETN,
			i_start => START_sig,
			o_tx_start => tx_start_sig,
			o_data_parallel => master_data_parallel_sig,
			i_tx_end => tx_end_sig,
			i_data_parallel => slave_data_parallel_sig,
			o_xaxis_data => x_axis_data_sig,
			o_yaxis_data => y_axis_data_sig,
			o_zaxis_data => z_axis_data_sig
		);
	spi : entity work.spi_controller(rtl)
		generic map(
			N => N,
			CLK_DIV => 100 -- input clock divider to generate output serial clock
		)
		port map(
			i_clk => SYS_CLK,
			i_rstb => CPU_RESETN,
			i_tx_start => tx_start_sig,
			o_tx_end => tx_end_sig,
			i_data_parallel => master_data_parallel_sig,
			o_data_parallel => slave_data_parallel_sig,
			o_sclk => SCK,
			o_ss => CS,
			o_mosi => MOSI,
			i_miso => MISO
		);
	mux : entity work.multiplexer(simple)
		generic map(
			N => N
		)
		port map(
			f0000 => x_axis_data_sig, -- Actual X-axis accelerometer data
			f0001 => y_axis_data_sig, -- Actual Y-axis accelerometer data 
			f0010 => z_axis_data_sig, -- Actual Z-axis accelerometer data
			f0011 => center_sig, -- Stored X-axis center data
			f0100 => left_sig, -- Stored X-axis max. left tilt data
			f0101 => right_sig, -- Stored X-axis max. right tilt data
			f0110 => delta_left_sig, -- X-axis left tilt “delta” value 
			f0111 => delta_right_sig, -- X-axis right tilt “delta” value
			f1000 => tilt_meter_sig, -- Tilt-meter display
			f1001 => zero_sig, -- User Defined
			f1010 => zero_sig, -- User Defined
			f1011 => zero_sig, -- User Defined
			f1100 => zero_sig, -- User Defined
			f1101 => zero_sig, -- User Defined
			f1110 => zero_sig, -- User Defined
			f1111 => zero_sig, -- User Defined
			s => SW(3 downto 0), -- Switch input
			y => LED -- Output LEDs
		);
	db_bc : entity work.SwitchDebouncer(Behavioral)
		port map(
			clk => SYS_CLK,
			reset => not_reset_sig,
			switchIn => BTNC,
			switchOut => bc_sig
		);
	db_bl : entity work.SwitchDebouncer(Behavioral)
		port map(
			clk => SYS_CLK,
			reset => not_reset_sig,
			switchIn => BTNL,
			switchOut => bl_sig
		);
    db_br :  entity work.SwitchDebouncer(Behavioral)
		port map(
			clk => SYS_CLK,
			reset => not_reset_sig,
			switchIn => BTNR,
			switchOut => br_sig
		);
	dff_bc : entity work.dff(simple)
		generic map(
			N => N
		)
		port map(
			clk => SYS_CLK,
			reset => CPU_RESETN,
			d => x_axis_data_sig,
			en => bc_sig,
			y => center_sig
		);
	dff_bl : entity work.dff(simple)
		generic map(
			N => N
		)
		port map(
			clk => SYS_CLK,
			reset => CPU_RESETN,
			d => x_axis_data_sig,
			en => bl_sig,
			y => left_sig
		);
	dff_br : entity work.dff(simple)
		generic map(
			N => N
		)
		port map(
			clk => SYS_CLK,
			reset => CPU_RESETN,
			d => x_axis_data_sig,
			en => br_sig,
			y => right_sig
		);
	tilt_meter : entity work.tilt_meter(simple)
		port map(
			center => center_sig,
			left => left_sig,
			right => right_sig,
			current => x_axis_data_sig,
			delta_left => delta_left_sig,
			delta_right => delta_right_sig,
			y => tilt_meter_sig
		);
end Structural;
