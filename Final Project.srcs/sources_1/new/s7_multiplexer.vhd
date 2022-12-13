library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity s7_multiplexer is
    generic (
        N : integer := 8
    );
    port (
        clk : in std_logic;
        xa : in std_logic_vector(N-1 downto 0);
        xb : in std_logic_vector(N-1 downto 0);
        xc : in std_logic_vector(N-1 downto 0);
        xd : in std_logic_vector(N-1 downto 0);
        xe : in std_logic_vector(N-1 downto 0);
        xf : in std_logic_vector(N-1 downto 0);
        xg : in std_logic_vector(N-1 downto 0);
        ya : out std_logic;
        yb : out std_logic;
        yc : out std_logic;
        yd : out std_logic;
        ye : out std_logic;
        yf : out std_logic;
        yg : out std_logic;
        an : out std_logic_vector(N-1 downto 0) -- anode
    );
end s7_multiplexer;

architecture simple of s7_multiplexer is
begin
    output : process(clk, xa, xb, xc, xd, xe, xf, xg)
        variable count : integer := 0;
    begin
        if(rising_edge(clk)) then
            ya <= xa(count);
            yb <= xb(count);
            yc <= xc(count);
            yd <= xd(count);
            ye <= xe(count);
            yf <= xf(count);
            yg <= xg(count);
            -- set anode to 1 (off)
            for i in 0 to N-1 loop
                an(i) <= '1';
            end loop;
            -- set count bit of anode to 0 (on)
            an(count) <= '0';
            count := count + 1;
            if(count = N) then
                count := 0;
            end if;
        end if;
    end process;
end simple;
