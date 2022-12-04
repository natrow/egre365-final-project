library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture rtl of testbench is

-- This procedure waits for N number of falling edges on the specified
-- clock signal
	
procedure waitclocks(signal clock : std_logic;
                       N : INTEGER) is
	begin
		for i in 1 to N loop
			wait until clock'event and clock='0';	-- wait on falling edge
		end loop;
end waitclocks;

constant N          : integer := 16;   -- number of bits send per SPI transaction
constant NO_VECTORS : integer := 8;    -- number of SPI transactions to simulate
constant CLK_DIV    : integer := 100;  -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(2*CLK_DIV)

type output_value_array is array (1 to NO_VECTORS) of std_logic_vector(N-1 downto 0);

constant i_data_values : output_value_array := (std_logic_vector(to_unsigned(16#2C08#,N)),
                                                std_logic_vector(to_unsigned(16#2D08#,N)),
                                                std_logic_vector(to_unsigned(16#B201#,N)),
                                                std_logic_vector(to_unsigned(16#B302#,N)),
                                                std_logic_vector(to_unsigned(16#B403#,N)),
                                                std_logic_vector(to_unsigned(16#B504#,N)),
                                                std_logic_vector(to_unsigned(16#B605#,N)),
                                                std_logic_vector(to_unsigned(16#B706#,N)));

constant o_data_values : output_value_array := (std_logic_vector(to_unsigned(16#00A1#,N)),
                                                std_logic_vector(to_unsigned(16#00B2#,N)),
                                                std_logic_vector(to_unsigned(16#0032#,N)),
                                                std_logic_vector(to_unsigned(16#0033#,N)),
                                                std_logic_vector(to_unsigned(16#0034#,N)),
                                                std_logic_vector(to_unsigned(16#0035#,N)),
                                                std_logic_vector(to_unsigned(16#0036#,N)),
                                                std_logic_vector(to_unsigned(16#0037#,N)));

signal o_data_index    : integer := 1;
signal i_data_index    : integer := 1;
signal send_data_index : integer := 1;
signal count_fall      : integer := 0;
signal count_rise      : integer := 0;
signal sys_clk_sig     : STD_LOGIC:= '0';		-- start system clock at '0'
signal cpu_resetn_sig  : STD_LOGIC := '1';		-- default for reset signal is '1'
signal sck_sig         : STD_LOGIC;
signal cs_sig          : STD_LOGIC;
signal mosi_sig        : STD_LOGIC;
signal miso_sig        : STD_LOGIC;
signal tx_start_s        : std_logic := '0';  -- default idle
signal tx_end_s          : std_logic;
signal o_data_parallel_s : STD_LOGIC_VECTOR(15 downto 0);
signal i_data_parallel_s : STD_LOGIC_VECTOR(15 downto 0);

signal slave_data_sent : STD_LOGIC_VECTOR(N-1 downto 0);

signal start_clk : STD_LOGIC := '0';
signal led_data_sig : STD_LOGIC_VECTOR(15 downto 0);
signal sw_sig : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";

begin
DUT : ENTITY work.toplevel(Structural)
	port map(
		CPU_RESETN => cpu_resetn_sig,
		SYS_CLK => sys_clk_sig,
		LED => led_data_sig,
		SW => sw_sig,
		SCK => sck_sig,
		CS => cs_sig,
		MOSI => mosi_sig,
		MISO => miso_sig
	);

-- master clock and reset signals

sys_clk_sig <= not sys_clk_sig after 5 ns;

-- Simulation of an SPI slave replying to the master
-- slave places proper vector from o_data_values onto miso_sig
-- on falling edge of sck_sig

spi_slave_sim : process(sck_sig, cpu_resetn_sig)
begin
	if(cpu_resetn_sig='0') then
		o_data_index      <= 1;			-- initialize to first input vector
		slave_data_sent   <= o_data_values(1);
		miso_sig      <= '0';
		count_fall  <= 0;
	else
		if(falling_edge(sck_sig)) then
			if(cs_sig='0') then
				count_fall     <= count_fall+1;
				slave_data_sent   <= std_logic_vector(shift_left(unsigned(slave_data_sent),1));
				miso_sig      <= slave_data_sent(N-1) after 63 ns;
			else
				count_fall     <= 0;
			end if;
			if(count_fall = 16) then
			  count_fall <= 1;
			  if(o_data_index = NO_VECTORS) then
			    o_data_index <= 1;
			    slave_data_sent <= std_logic_vector(shift_left(unsigned(o_data_values(1)),1));
				miso_sig      <= o_data_values(1)(N-1) after 63 ns;
			  else
			    o_data_index <= o_data_index + 1;
			    slave_data_sent   <= std_logic_vector(shift_left(unsigned(o_data_values(o_data_index+1)),1));
				miso_sig      <= o_data_values(o_data_index+1)(N-1) after 63 ns;
			  end if;
			end if;
		end if;
	end if;
end process spi_slave_sim;

end rtl;
