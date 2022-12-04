library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity toplevel is
    port(
		CPU_RESETN : in STD_LOGIC; -- Nexys 4 DDR active low reset button
        SYS_CLK : in STD_LOGIC; -- Nexys 4 DDR 100 MHz clock
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
	constant CLK_DIV : integer := 100; -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(2*CLK_DIV)
	signal START_sig, tx_start_sig, tx_end_sig : std_logic;
	signal master_data_parallel_sig, slave_data_parallel_sig, x_axis_data_sig, y_axis_data_sig, z_axis_data_sig, zero_sig : std_logic_vector(N-1 downto 0);
begin
	clock_divider : entity work.clock_divider(behavior)
		generic map(
			-- synthesis
			divisor => 50000000 
			-- simulation
			--divisor => 200000
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
	spi_controller : entity work.spi_controller(rtl)
		generic map(
			N => N,
			CLK_DIV => CLK_DIV
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
	multiplexer : entity work.multiplexer(simple)
		generic map(
			N => N
		)
		port map(
			a => x_axis_data_sig,
			b => y_axis_data_sig,
			c => z_axis_data_sig,
			d => zero_sig,
			s => SW(1 downto 0),
			y => LED
		);
	zero_sig <= "0000000000000000";
end Structural;
