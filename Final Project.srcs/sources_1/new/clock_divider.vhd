library IEEE;
use IEEE.std_logic_1164.all;

ENTITY clock_divider is
-- use these values for simulation -----
--  GENERIC(DIVISOR : positive := 100);
----------------------------------------
-- use these values for synthesis ------
GENERIC(DIVISOR : positive := 10000000);
----------------------------------------
  PORT(mclk : IN  std_logic;
       sclk : OUT std_logic);
END clock_divider;

ARCHITECTURE behavior OF clock_divider IS

	SIGNAL sclki : std_logic := '0';
  
  BEGIN

    div_clk : PROCESS(mclk)
    
      VARIABLE count : integer RANGE 0 to DIVISOR/2 := 0;

      BEGIN
        IF(rising_edge(mclk)) THEN
          IF(count = (DIVISOR/2)-1) THEN
            sclki <= not sclki;
            count := 0;
          ELSE
            count := count + 1;
          END IF;
        END IF;
    END PROCESS div_clk;

    sclk <= sclki;
	 
END behavior;


