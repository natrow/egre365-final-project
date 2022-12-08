library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SwitchDebouncer is
  generic (CLK_FREQ : positive := 100_000_000);
  port (clk       : in  std_logic;
        reset     : in  std_logic;
        switchIn  : in  std_logic;
        switchOut	 : out std_logic);
end SwitchDebouncer;

architecture Behavioral of SwitchDebouncer is

  signal sample	: std_logic;
  constant PULSE_COUNT_MAX	: integer := 20;
  signal sync : std_logic_vector(1 downto 0);
  signal counter : integer range 0 to PULSE_COUNT_MAX;

begin

SampleGen : process(clk)
  constant SAMPLE_COUNT_MAX : integer := (CLK_FREQ / 4000) - 1; -- 500 us
  variable counter : integer range 0 to SAMPLE_COUNT_MAX;

  begin

  if (clk'event and clk='1') then
    if (reset='1') then
      sample	<= '0';
      counter	:= 0;
    else
      if (counter=SAMPLE_COUNT_MAX) then
        counter	:= 0;
        sample	<= '1';
      else
        sample	<= '0';
        counter	:= counter + 1;
      end if;
    end if;
  end if;
end process;

Debounce : process(clk)
  begin
    if (clk'event and clk='1') then
      if (reset='1') then
        sync <= (others => '0');
        counter <= 0;
        switchOut <= '0';
      else
        sync <= sync(0) & switchIn;
        if (sync(1)='0') then      -- Switch not pressed
          counter <= 0;
          switchOut <= '0';
        elsif(sample = '1') then   -- Switch pressed
          if (counter=PULSE_COUNT_MAX) then
            switchOut <= '1';
          else
            counter <= counter + 1;
          end if;
        end if;
      end if;
    end if;
 end process;

end Behavioral;