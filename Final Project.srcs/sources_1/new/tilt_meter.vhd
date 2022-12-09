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
    signal delta_left_sig, delta_right_sig, current_sig, center_sig,
        lt1, lt2, lt3, lt4, lt5, lt6, lt7,
        rt1, rt2, rt3, rt4, rt5, rt6, rt7 : signed(15 downto 0);
begin
    output : process(center, left, right, current)
    begin
        delta_left_sig <= (signed(left) - signed(center))/to_signed(7, 16);
        delta_right_sig <= (signed(right) - signed(center))/to_signed(7, 16);
        delta_left <= std_logic_vector(delta_left_sig);
        delta_right <= std_logic_vector(delta_right_sig);
        current_sig <= signed(current);
        center_sig <= signed(center);

        lt1 <= center_sig + delta_left_sig;
        lt2 <= resize(center_sig + (delta_left_sig * to_signed(2, 16)), 16);
        lt3 <= resize(center_sig + (delta_left_sig * to_signed(3, 16)), 16);
        lt4 <= resize(center_sig + (delta_left_sig * to_signed(4, 16)), 16);
        lt5 <= resize(center_sig + (delta_left_sig * to_signed(5, 16)), 16);
        lt6 <= resize(center_sig + (delta_left_sig * to_signed(6, 16)), 16);
        lt7 <= resize(center_sig + (delta_left_sig * to_signed(7, 16)), 16);

        rt1 <= center_sig + delta_right_sig;
        rt2 <= resize(center_sig + (delta_right_sig * to_signed(2, 16)), 16);
        rt3 <= resize(center_sig + (delta_right_sig * to_signed(3, 16)), 16);
        rt4 <= resize(center_sig + (delta_right_sig * to_signed(4, 16)), 16);
        rt5 <= resize(center_sig + (delta_right_sig * to_signed(5, 16)), 16);
        rt6 <= resize(center_sig + (delta_right_sig * to_signed(6, 16)), 16);
        rt7 <= resize(center_sig + (delta_right_sig * to_signed(7, 16)), 16);

        -- y(15)
        y(15) <= '0';
        -- y(14)
        if(lt7 <= current_sig) then
            y(14) <= '1';
        else
            y(14) <= '0';
        end if;
        -- y(13)
        if(lt6 <= current_sig and current_sig < lt7) then
            y(13) <= '1';
        else
            y(13) <= '0';
        end if;
        -- y(12)
        if(lt5 <= current_sig and current_sig < lt6) then
            y(12) <= '1';
        else
            y(12) <= '0';
        end if;
        -- y(11)
        if(lt4 <= current_sig and current_sig < lt5) then
            y(11) <= '1';
        else
            y(11) <= '0';
        end if;
        -- y(10)
        if(lt3 <= current_sig and current_sig < lt4) then
            y(10) <= '1';
        else
            y(10) <= '0';
        end if;
        -- y(9)
        if(lt2 <= current_sig and current_sig < lt3) then
            y(9) <= '1';
        else
            y(9) <= '0';
        end if;
        -- y(8)
        if(lt1 <= current_sig and current_sig < lt2) then
            y(8) <= '1';
        else
            y(8) <= '0';
        end if;
        -- y(7)
        y(7) <= '1';
        -- y(6)
        if(rt2 <= current_sig and current_sig < rt1) then
            y(6) <= '1';
        else
            y(6) <= '0';
        end if;
        -- y(5)
        if(rt3 <= current_sig and current_sig < rt2) then
            y(5) <= '1';
        else
            y(5) <= '0';
        end if;
        -- y(4)
        if(rt4 <= current_sig and current_sig < rt3) then
            y(4) <= '1';
        else
            y(4) <= '0';
        end if;
        -- y(3)
        if(rt5 <= current_sig and current_sig < rt4) then
            y(3) <= '1';
        else
            y(3) <= '0';
        end if;
        -- y(2)
        if(rt6 <= current_sig and current_sig < rt5) then
            y(2) <= '1';
        else
            y(2) <= '0';
        end if;
        -- y(1)
        if(rt7 <= current_sig and current_sig < rt6) then
            y(1) <= '1';
        else
            y(1) <= '0';
        end if;
        -- y(0)
        if(current_sig < rt7) then
            y(0) <= '1';
        else
            y(0) <= '0';
        end if;
    end process;
end architecture;
