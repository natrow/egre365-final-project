library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sign_conv is
    generic (
        N : integer := 8
    );
    port (
        x : in std_logic_vector(N-1 downto 0);
        y : out std_logic_vector(N-1 downto 0)
    );
end sign_conv;

architecture simple of sign_conv is
begin
    output : process(x)
        variable x_int : unsigned(N-1 downto 0);
    begin
        if(x(N-1) = '1') then
            x_int := unsigned(not x) + to_unsigned(1, N);
            y <= std_logic_vector(x_int);
        else
            y <= x;
        end if;
    end process;
end architecture;