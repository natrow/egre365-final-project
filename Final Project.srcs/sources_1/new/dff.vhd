library IEEE;
use IEEE.std_logic_1164.all;

entity dff is
    generic (
        N : integer := 8
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        d : in std_logic_vector(N-1 downto 0);
        en : in std_logic;
        y : out std_logic_vector(N-1 downto 0)
    );
end dff;

architecture simple of dff is
    signal stored : std_logic_vector(N-1 downto 0);
begin
    output : process(clk, reset)
    begin
        if(reset = '0') then
            stored <= "0000000000000000";
        elsif(rising_edge(clk) and en = '1') then
            stored <= d;
        end if;
    end process;
end architecture;
