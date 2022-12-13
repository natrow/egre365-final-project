library IEEE;
use IEEE.std_logic_1164.all;

entity s7_encoder is
    port (
        x : in std_logic_vector(3 downto 0);
        blank_in : in std_logic;
        neg_in : in std_logic;
        blank_out : out std_logic;
        neg_out : out std_logic;
        a : out std_logic;
        b : out std_logic;
        c : out std_logic;
        d : out std_logic;
        e : out std_logic;
        f : out std_logic;
        g : out std_logic
    );
end s7_encoder;

architecture simple of s7_encoder is
begin
    output : process(x, blank_in, neg_in)
    begin
        if(x = "0000" and blank_in = '1') then
            a <= '1';
            b <= '1';
            c <= '1';
            d <= '1';
            e <= '1';
            f <= '1';
            g <= not neg_in;
            blank_out <= '1';
            neg_out <= '0';
        else
            a <= (not x(3) and not x(2) and not x(1) and x(0))
                or (x(2) and not x(1) and not x(0));
            b <= (x(2) and not x(1) and x(0))
                or (x(2) and x(1) and not x(0));
            c <= not x(2) and x(1) and not x(0);
            d <= (not x(3) and not x(2) and not x(1) and x(0))
                or (x(2) and not x(1) and not x(0))
                or (x(2) and x(1) and x(0));
            e <= (x(2) and not x(1)) or x(0);
            f <= (not x(3) and not x(2) and x(0))
                or (not x(2) and x(1)) or (x(1) and x(0));
            g <= (not x(3) and not x(2) and not x(1))
                or (x(2) and x(1) and x(0));
            blank_out <= '0';
            neg_out <= neg_in;
        end if;
    end process;
end simple;
