library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multiplexer is
    generic(
        N : integer := 8
    );
    port(
        a : in std_logic_vector(N-1 downto 0);
        b : in std_logic_vector(N-1 downto 0);
        c : in std_logic_vector(N-1 downto 0);
        d : in std_logic_vector(N-1 downto 0);
        s : in std_logic_vector(1 downto 0);
        y : out std_logic_vector(N-1 downto 0)
    );
end multiplexer;

architecture simple of multiplexer is
begin
    output : process(a, b, c, d, s)
    begin
        case s is
            when "00" =>
                y <= a;
            when "01" =>
                y <= b;
            when "10" =>
                y <= c;
            when "11" =>
                y <= d;
            when others =>
                y <= a;
        end case;
    end process;
end simple;
