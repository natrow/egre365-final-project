library IEEE;
use IEEE.std_logic_1164.ALL;

entity toplevel is
    port(
		CPU_RESETN : in std_logic; -- Nexys 4 DDR active low reset button
        SYS_CLK : in std_logic; -- Nexys 4 DDR 100 MHz clock
        BTNC : in  std_logic; -- Center button
	    BTNL : in  std_logic; -- Left button
	    BTNR : in  std_logic; -- Right button
        LED : out std_logic_vector(15 downto 0); -- Nexys 4 DDR LEDs
        SW : in std_logic_vector(15 downto 0); -- Nexys 4 DDR switches
		SCK : out std_logic; -- SCK to SPI slave
        CS : out std_logic; -- SPI slave chip select
		MOSI : out std_logic; -- MOSI out to slave
		MISO : in std_logic; -- MOSI in from slave
		CA : out std_logic; -- Cathode A
		CB : out std_logic; -- Cathode B
		CC : out std_logic; -- Cathode C
		CD : out std_logic; -- Cathode D
		CE : out std_logic; -- Cathode E
		CF : out std_logic; -- Cathode F
		CG : out std_logic; -- Cathode G
		AN : out std_logic_vector(7 downto 0) -- Annodes
	);
end toplevel;

architecture Structural of toplevel is
	signal START_sig, tx_start_sig, tx_end_sig, bc_sig,
		bl_sig, br_sig, reset_high_sig : std_logic;
	signal master_data_parallel_sig, slave_data_parallel_sig,
		x_axis_data_sig, y_axis_data_sig, z_axis_data_sig,
		center_sig, left_sig, right_sig,
		delta_left_sig, delta_right_sig, tilt_meter_sig : std_logic_vector(15 downto 0);
	-- Extra Credit: 7 segment display
	signal a_sig, b_sig, c_sig, d_sig, e_sig, f_sig, g_sig : std_logic_vector(5 downto 0);
	signal bcd_sig : std_logic_vector(19 downto 0);
	signal blank5_sig, blank4_sig, blank3_sig, blank2_sig,
		neg4_sig, neg3_sig, neg2_sig, neg1_sig,
		clk_sig : std_logic;
	signal display_sig, tilt_meter_7s_sig, input_sig : std_logic_vector(15 downto 0);
begin
	reset_high_sig <= NOT CPU_RESETN;
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
			N => 16,
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
			N => 16
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
			f1001 => x"0000", -- User Defined
			f1010 => x"0000", -- User Defined
			f1011 => x"0000", -- User Defined
			f1100 => x"0000", -- User Defined
			f1101 => x"0000", -- User Defined
			f1110 => x"0000", -- User Defined
			f1111 => x"0000", -- User Defined
			s => SW(3 downto 0), -- Switch input
			y => LED -- Output LEDs
		);
	db_bc : entity work.SwitchDebouncer(Behavioral)
		port map(
			clk => SYS_CLK,
			reset => reset_high_sig,
			switchIn => BTNC,
			switchOut => bc_sig
		);
	db_bl : entity work.SwitchDebouncer(Behavioral)
		port map(
			clk => SYS_CLK,
			reset => reset_high_sig,
			switchIn => BTNL,
			switchOut => bl_sig
		);
    db_br :  entity work.SwitchDebouncer(Behavioral)
		port map(
			clk => SYS_CLK,
			reset => reset_high_sig,
			switchIn => BTNR,
			switchOut => br_sig
		);
	dff_bc : entity work.dff(simple)
		generic map(N => 16)
		port map(
			clk => SYS_CLK,
			reset => CPU_RESETN,
			d => x_axis_data_sig,
			en => bc_sig,
			y => center_sig
		);
	dff_bl : entity work.dff(simple)
		generic map(N => 16)
		port map(
			clk => SYS_CLK,
			reset => CPU_RESETN,
			d => x_axis_data_sig,
			en => bl_sig,
			y => left_sig
		);
	dff_br : entity work.dff(simple)
		generic map(N => 16)
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
			y => tilt_meter_sig,
			y_7s => tilt_meter_7s_sig
		);
	
	-- Extra Credit: 7 Segment Display
	mux2 : entity work.multiplexer(simple)
	generic map(
		N => 16
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
		f1000 => tilt_meter_7s_sig, -- Tilt-meter display
		f1001 => x"0000", -- User Defined
		f1010 => x"0000", -- User Defined
		f1011 => x"0000", -- User Defined
		f1100 => x"0000", -- User Defined
		f1101 => x"0000", -- User Defined
		f1110 => x"0000", -- User Defined
		f1111 => x"0000", -- User Defined
		s => SW(3 downto 0), -- Switch input
		y => display_sig -- Output for 7 segment display
	);
	s7_conv : entity work.sign_conv(simple)
		generic map(N => 16)
		port map(
			x => display_sig,
			y => input_sig
		);
	s7_bcd : entity work.s7_bcd(simple)
		port map(
			x => input_sig,
			y => bcd_sig
		);
	s7_enc5 : entity work.s7_encoder(simple)
		port map(
			x => "0000",
			blank_in => '1',
			neg_in => neg4_sig,
			blank_out => blank5_sig,
			a => a_sig(5),
			b => b_sig(5),
			c => c_sig(5),
			d => d_sig(5),
			e => e_sig(5),
			f => f_sig(5),
			g => g_sig(5)
		);
	s7_enc4 : entity work.s7_encoder(simple)
		port map(
			x => bcd_sig(19 downto 16),
			blank_in => blank5_sig,
			neg_in => neg3_sig,
			blank_out => blank4_sig,
			neg_out => neg4_sig,
			a => a_sig(4),
			b => b_sig(4),
			c => c_sig(4),
			d => d_sig(4),
			e => e_sig(4),
			f => f_sig(4),
			g => g_sig(4)
		);
	s7_enc3 : entity work.s7_encoder(simple)
		port map(
			x => bcd_sig(15 downto 12),
			blank_in => blank4_sig,
			neg_in => neg2_sig,
			blank_out => blank3_sig,
			neg_out => neg3_sig,
			a => a_sig(3),
			b => b_sig(3),
			c => c_sig(3),
			d => d_sig(3),
			e => e_sig(3),
			f => f_sig(3),
			g => g_sig(3)
		);
	s7_enc2 : entity work.s7_encoder(simple)
		port map(
			x => bcd_sig(11 downto 8),
			blank_in => blank3_sig,
			neg_in => neg1_sig,
			blank_out => blank2_sig,
			neg_out => neg2_sig,
			a => a_sig(2),
			b => b_sig(2),
			c => c_sig(2),
			d => d_sig(2),
			e => e_sig(2),
			f => f_sig(2),
			g => g_sig(2)
		);
	s7_enc1 : entity work.s7_encoder(simple)
		port map(
			x => bcd_sig(7 downto 4),
			blank_in => blank2_sig,
			neg_in => display_sig(15),
			neg_out => neg1_sig,
			a => a_sig(1),
			b => b_sig(1),
			c => c_sig(1),
			d => d_sig(1),
			e => e_sig(1),
			f => f_sig(1),
			g => g_sig(1)
		);
	s7_enc0 : entity work.s7_encoder(simple)
		port map(
			x => bcd_sig(3 downto 0),
			blank_in => '0',
			neg_in => '0',
			a => a_sig(0),
			b => b_sig(0),
			c => c_sig(0),
			d => d_sig(0),
			e => e_sig(0),
			f => f_sig(0),
			g => g_sig(0)
		);
	s7_clk_div : entity work.clock_divider(behavior)
		generic map(
			-- synthesis
			divisor => 50000
			-- simulation
			-- divisor => 200
		)
		port map(
			mclk => SYS_CLK,
			sclk => clk_sig
		);
	s7_mux : entity work.s7_multiplexer(simple)
		generic map(N => 6)
		port map (
			clk => clk_sig,
			xa => a_sig,
			xb => b_sig,
			xc => c_sig,
			xd => d_sig,
			xe => e_sig,
			xf => f_sig,
			xg => g_sig,
			ya => CA,
			yb => CB,
			yc => CC,
			yd => CD,
			ye => CE,
			yf => CF,
			yg => CG,
			an => AN(5 downto 0)
		);
	AN(7 downto 6) <= "11";
end Structural;
