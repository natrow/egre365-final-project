library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity s7_dabble is
    port (
        x : in std_logic_vector(3 downto 0);
        y : out std_logic_vector(3 downto 0)
    );
end s7_dabble;

architecture simple of s7_dabble is
begin
    output : process(x)
        variable x_int : unsigned(3 downto 0);
    begin
        x_int := unsigned(x);
        -- numbers greater than four get "dabbled"
        if (x_int > to_unsigned(4, 4)) then
            -- y = x + 3
            y <= std_logic_vector(x_int + to_unsigned(3, 4));
        else
            y <= x;
        end if;
    end process;
end architecture;
