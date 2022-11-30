-- ******************************************************************** 
--
-- File Name: spi_fsm_toplevel.vhd
-- 
-- scope: top level component for mapping onto Digilent Basys4 DDR board
--
-- rev 1.00.2019.10.29
-- 
-- ******************************************************************** 
-- ******************************************************************** 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_fsm_toplevel is
    Port ( CPU_RESETN : in	STD_LOGIC;						-- Nexys 4 DDR active low reset button
           SYS_CLK    : in	STD_LOGIC;						-- Nexys 4 DDR 100 MHz clock
           LED        : out	STD_LOGIC_VECTOR(15 downto 0);	-- Nexys 4 DDR LEDs
           SW         : in	STD_LOGIC_VECTOR(15 downto 0);  -- Nexys 4 DDR switches
		   SCK        : out STD_LOGIC;						-- SCK to SPI slave
           CS         : out STD_LOGIC;						-- SPI slave chip select
		   MOSI       : out STD_LOGIC;						-- MOSI out to slave
		   MISO       : in  STD_LOGIC);						-- MOSI in from slave
end spi_fsm_toplevel;

architecture Structural of spi_fsm_toplevel is

signal START_sig, tx_start_sig, tx_end_sig : std_logic;
signal i_data_parallel_sig, o_data_parallel_sig, o_x_axis_data_sig, o_y_axis_data_sig, o_z_axis_data_sig : std_logic_vector(15 downto 0);
constant N          : integer := 16;   -- number of bits send per SPI transaction
constant CLK_DIV    : integer := 100;  -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(2*CLK_DIV)

begin

--LED <= o_x_axis_data_sig;

clock_divider : entity work.clock_divider(behavior)
	generic map(
		divisor => 200000
	)
	port map(
		mclk => SYS_CLK,
		sclk => START_sig
	);

spi_fsm : entity work.spi_fsm(simple)
	port map(
		i_clk           => SYS_CLK,
        i_rstb          => CPU_RESETN,
        i_start         => START_sig,
        o_tx_start      => tx_start_sig,
        o_data_parallel => i_data_parallel_sig,
        i_tx_end        => tx_end_sig,
        i_data_parallel => o_data_parallel_sig,
        o_xaxis_data    => LED,
        o_yaxis_data    => o_y_axis_data_sig,
        o_zaxis_data    => o_z_axis_data_sig
	);
		
spi_controller : entity work.spi_controller(rtl)
  generic map(
	N                     => N,
	CLK_DIV               => CLK_DIV)
  port map(
	i_clk                       => SYS_CLK,
	i_rstb                      => CPU_RESETN,
	i_tx_start                  => tx_start_sig,
	o_tx_end                    => tx_end_sig,
	i_data_parallel             => i_data_parallel_sig,
	o_data_parallel             => o_data_parallel_sig,
	o_sclk                      => SCK,
	o_ss                        => CS,
	o_mosi                      => MOSI,
	i_miso                      => MISO);

end Structural;

