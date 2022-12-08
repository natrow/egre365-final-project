library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tilt_meter is
    port (
        center : in std_logic_vector(15 downto 0);
        left : in std_logic_vector(15 downto 0);
        right : in std_logic_vector(15 downto 0);
        current : in std_logic_vector(15 downto 0);
        delta_left : out std_logic_vector(15 downto 0);
        delta_right : out std_logic_vector(15 downto 0);
        y : out std_logic_vector(15 downto 0)
    );
end tilt_meter;

architecture simple of tilt_meter is
    signal delta_left_sig, delta_right_sig : signed(15 downto 0);
begin
    output : process(center, left, right, current)
    begin
        delta_left_sig <= (signed(center) - signed(left))/to_signed(7, 16);
        delta_right_sig <= (signed(center) - signed(right))/to_signed(7, 16);
        delta_left <= std_logic_vector(delta_left_sig);
        delta_right <= std_logic_vector(delta_right_sig);
        y <= x"0000";
    end process;
end architecture;
