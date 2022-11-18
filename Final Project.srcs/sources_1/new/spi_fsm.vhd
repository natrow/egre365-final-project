library ieee;
use ieee.std_logic_1164.ALL;

entity spi_fsm is
    Port (
        i_clk           : in  std_logic;
        i_rstb          : in  std_logic;
        i_start         : in  std_logic;
        o_tx_start      : out std_logic;
        o_data_parallel : out std_logic_vector(15 downto 0);
        i_tx_end        : in  std_logic;
        i_data_parallel : in  std_logic_vector(15 downto 0);
        o_xaxis_data    : out std_logic_vector(15 downto 0);
        o_yaxis_data    : out std_logic_vector(15 downto 0);
        o_zaxis_data    : out std_logic_vector(15 downto 0)
    );
end spi_fsm;

architecture simple of spi_fsm is
    TYPE state_type IS (
        init, -- initial/reset state
        wbr0, wbr1, wbr2, wbr3, -- write baud rate
        wpc0, wpc1, wpc2, wpc3, -- write power control
        rxl0, rxl1, rxl2, rxl3, -- read x lower
        rxh0, rxh1, rxh2, rxh3, -- read x higher
        ryl0, ryl1, ryl2, ryl3, -- read y lower
        ryh0, ryh1, ryh2, ryh3, -- read y higher
        rzl0, rzl1, rzl2, rzl3, -- read z lower
        rzh0, rzh1, rzh2, rzh3, -- read z higher
        wtns, -- wait until !start (to validate rising edge)
        wtst  -- wait until start
    );
    signal present_state : state_type;
    signal next_state : state_type;
begin
    clocked : process(i_clk, i_rstb)
    begin
        if(i_rstb = '0') then
            present_state <= init;
        elsif(rising_edge(i_clk)) then
            present_state <= next_state;
        end if;

    end process clocked;
    
    nextstate : process(present_state, i_start, i_tx_end)
    begin
        case(present_state) is
            -- initial state
            when init =>
                if(i_start = '1') then
                    next_state <= wbr0;
                else
                    next_state <= init;
                end if;
            -- write baud rate register
            when wbr0 =>
                next_state <= wbr1;
            when wbr1 =>
                next_state <= wbr2;
            when wbr2 =>
                if(i_tx_end = '1') then
                    next_state <= wbr3;
                else
                    next_state <= wbr2;
                end if;
            when wbr3 =>
                if(i_tx_end = '0') then
                    next_state <= wpc0;
                else
                    next_state <= wbr3;
                end if;
            -- write power control register
            when wpc0 =>
                next_state <= wpc1;
            when wpc1 =>
                next_state <= wpc2;
            when wpc2 =>
                if(i_tx_end = '1') then
                    next_state <= wpc3;
                else
                    next_state <= wpc2;
                end if;
            when wpc3 =>
                if(i_tx_end = '0') then
                    next_state <= rxl0;
                else
                    next_state <= wpc3;
                end if;
            -- read x lower data
            when rxl0 =>
                next_state <= rxl1;
            when rxl1 =>
                next_state <= rxl2;
            when rxl2 =>
                if(i_tx_end = '1') then
                    next_state <= rxl3;
                else
                    next_state <= rxl2;
                end if;
            when rxl3 =>
                -- TODO: STORE DATA
                if(i_tx_end = '0') then
                    next_state <= rxh0;
                else
                    next_state <= rxl3;
                end if;
            -- read x higher data
            when rxh0 =>
                next_state <= rxh1;
            when rxh1 =>
                next_state <= rxh2;
            when rxh2 =>
                if(i_tx_end = '1') then
                    next_state <= rxh3;
                else
                    next_state <= rxh2;
                end if;
            when rxh3 =>
                -- TODO: STORE DATA
                if(i_tx_end = '0') then
                    next_state <= ryl0;
                else
                    next_state <= rxh3;
                end if;
            -- read y lower data
            when ryl0 =>
                next_state <= ryl1;
            when ryl1 =>
                next_state <= ryl2;
            when ryl2 =>
                if(i_tx_end = '1') then
                    next_state <= ryl3;
                else
                    next_state <= ryl2;
                end if;
            when ryl3 =>
                -- TODO: STORE DATA
                if(i_tx_end = '0') then
                    next_state <= ryh0;
                else
                    next_state <= ryl3;
                end if;
            -- read y higher data
            when ryh0 =>
                next_state <= ryh1;
            when ryh1 =>
                next_state <= ryh2;
            when ryh2 =>
                if(i_tx_end = '1') then
                    next_state <= ryh3;
                else
                    next_state <= ryh2;
                end if;
            when ryh3 =>
                -- TODO: STORE DATA
                if(i_tx_end = '0') then
                    next_state <= rzl0;
                else
                    next_state <= ryh3;
                end if;
            -- read z lower data
            when rzl0 =>
                next_state <= rzl1;
            when rzl1 =>
                next_state <= rzl2;
            when rzl2 =>
                if(i_tx_end = '1') then
                    next_state <= rzl3;
                else
                    next_state <= rzl2;
                end if;
            when rzl3 =>
                -- TODO: STORE DATA
                if(i_tx_end = '0') then
                    next_state <= rzh0;
                else
                    next_state <= rzl3;
                end if;
            -- read z higher data
            when rzh0 =>
                next_state <= rzh1;
            when rzh1 =>
                next_state <= rzh2;
            when rzh2 =>
                if(i_tx_end = '1') then
                    next_state <= rzh3;
                else
                    next_state <= rzh2;
                end if;
            when rzh3 =>
                -- TODO: STORE DATA
                if(i_tx_end = '0') then
                    next_state <= wtns;
                else
                    next_state <= rzh3;
                end if;
            -- wait until !start
            when wtns =>
                if(i_start = '0') then
                    next_state <= wtst;
                else
                    next_state <= wtns;
                end if;
            -- wait until start
            when wtst =>
                if(i_start = '1') then
                    next_state <= rxl0;
                else
                    next_state <= wtst;
                end if;
        end case;
    end process nextstate;
    
    output : process(present_state)
        begin
            -- o_data_parallel
            case(present_state) is
                -- write baud rate register
                when wbr0 | wbr1 | wbr2 | wbr3 =>
                    o_data_parallel <= x"2C08";
                -- write power control register
                when wpc0 | wpc1 | wpc2 | wpc3 =>
                    o_data_parallel <= x"2D08";
                -- read x lower
                when rxl0 | rxl1 | rxl2 | rxl3 =>
                    o_data_parallel <= x"0032";
                -- read x higher
                when rxh0 | rxh1 | rxh2 | rxh3 =>
                    o_data_parallel <= x"0033";
                -- read y lower
                when ryl0 | ryl1 | ryl2 | ryl3 =>
                    o_data_parallel <= x"0034";
                -- read y higher
                when ryh0 | ryh1 | ryh2 | ryh3 =>
                    o_data_parallel <= x"0035";
                -- read z lower
                when rzl0 | rzl1 | rzl2 | rzl3 =>
                    o_data_parallel <= x"0036";
                -- read z higher
                when rzh0 | rzh1 | rzh2 | rzh3 =>
                    o_data_parallel <= x"0037";  
                when others =>
                    o_data_parallel <= x"0000";
            end case;
            -- o_tx_start
            case (present_state) is
                when wbr1 | wpc1 | rxl1 | rxh1 | ryl1 | ryh1 | rzl1 | rzh1 =>
                    o_tx_start <= '1';
                when others =>
                    o_tx_start <= '0';
            end case;
    end process output;

    latched : process(i_clk)
        begin
            if(rising_edge(i_clk)) then
                case (present_state) is
                    -- initial/reset case
                    when init =>
                        o_xaxis_data <= x"0000";
                        o_yaxis_data <= x"0000";
                        o_zaxis_data <= x"0000";
                    -- read x lower
                    when rxl3 =>
                        o_xaxis_data(7 downto 0) <= i_data_parallel(7 downto 0);
                    -- read x higher
                    when rxh3 =>
                        o_xaxis_data(15 downto 8) <= i_data_parallel(7 downto 0);
                    -- read y lower
                    when ryl3 =>
                        o_yaxis_data(7 downto 0) <= i_data_parallel(7 downto 0);
                    -- read y higher
                    when ryh3 =>
                        o_yaxis_data(15 downto 8) <= i_data_parallel(7 downto 0);
                    -- read z lower
                    when rzl3 =>
                        o_zaxis_data(7 downto 0) <= i_data_parallel(7 downto 0);
                    -- read z higher
                    when rzh3 =>
                        o_zaxis_data(15 downto 8) <= i_data_parallel(7 downto 0);
                    when others =>
                        -- don't update bus
                end case;
            end if;
    end process latched;
end simple;
