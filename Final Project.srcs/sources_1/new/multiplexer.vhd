library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multiplexer is
    generic(
        N : integer := 8
    );
    port(
        f0000 : in std_logic_vector(N-1 downto 0);
        f0001 : in std_logic_vector(N-1 downto 0);
        f0010 : in std_logic_vector(N-1 downto 0);
        f0011 : in std_logic_vector(N-1 downto 0);
        f0100 : in std_logic_vector(N-1 downto 0);
        f0101 : in std_logic_vector(N-1 downto 0);
        f0110 : in std_logic_vector(N-1 downto 0);
        f0111 : in std_logic_vector(N-1 downto 0);
        f1000 : in std_logic_vector(N-1 downto 0);
        f1001 : in std_logic_vector(N-1 downto 0);
        f1010 : in std_logic_vector(N-1 downto 0);
        f1011 : in std_logic_vector(N-1 downto 0);
        f1100 : in std_logic_vector(N-1 downto 0);
        f1101 : in std_logic_vector(N-1 downto 0);
        f1110 : in std_logic_vector(N-1 downto 0);
        f1111 : in std_logic_vector(N-1 downto 0);
        s : in std_logic_vector(3 downto 0);
        y : out std_logic_vector(N-1 downto 0)
    );
end multiplexer;

architecture simple of multiplexer is
begin
    output : process(f0000, f0001, f0010, f0011, s)
    begin
        case s is
            when "0000" =>
                y <= f0000;
            when "0001" =>
                y <= f0001;
            when "0010" =>
                y <= f0010;
            when "0011" =>
                y <= f0011;
            when "0100" =>
                y <= f0100;
            when "0101" =>
                y <= f0101;
            when "0110" =>
                y <= f0110;
            when "0111" =>
                y <= f0111;
            when "1000" =>
                y <= f1000;
            when "1001" =>
                y <= f1001;
            when "1010" =>
                y <= f1010;
            when "1011" =>
                y <= f1011;
            when "1100" =>
                y <= f1100;
            when "1101" =>
                y <= f1101;
            when "1110" =>
                y <= f1110;
            when "1111" =>
                y <= f1111;
            when others =>
                y <= f0000;
        end case;
    end process;
end simple;
