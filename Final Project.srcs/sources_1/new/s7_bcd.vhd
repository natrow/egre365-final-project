-- 16-bit double-dabble BCD converter circuit
--
-- Inspired by video here:
-- https://www.youtube.com/watch?v=hEDQpqhY2MA
--                                                            ,~~~,-------------------(19)~,
--                                          ,~~~,-------------| S |-,~~~,-------------(18) | 10,000's place
--                        ,~~~,-------------| J |-,~~~,-------|19 |-| W |-,~~~,-------(17) |
--      ,~~~,-------------| D |-,~~~,-------|10 |-| M |-,~~~,-'~~~'-|23 |-| α |-,~~~,-(16)~'
-- (15)-| A |-,~~~,-------| 4 |-| F |-,~~~,-'~~~'-|13 |-| P |-,~~~,-'~~~'-|27 |-| ε |-(15)~,
-- (14)-| 1 |-| B |-,~~~,-'~~~'-| 6 |-| H |-,~~~,-'~~~'-|16 |-| T |-,~~~,-'~~~'-|31 |-(14) | 1,000's place
-- (13)-'~~~'-| 2 |-| C |-,~~~,-'~~~'-| 8 |-| K |-,~~~,-'~~~'-|20 |-| X |-,~~~,-'~~~'-(13) |
-- (12)-------'~~~'-| 3 |-| E |-,~~~,-'~~~'-|11 |-| N |-,~~~,-'~~~'-|24 |-| β |-,~~~,-(12)~'
-- (11)-------------'~~~'-| 5 |-| G |-,~~~,-'~~~'-|14 |-| Q |-,~~~,-'~~~'-|28 |-| η |-(11)~,
-- (10)-------------------'~~~'-| 7 |-| I |-,~~~,-'~~~'-|17 |-| U |-,~~~,-'~~~'-|32 |-(10) | 100's place
--  (9)-------------------------'~~~'-| 9 |-| L |-,~~~,-'~~~'-|21 |-| Y |-,~~~,-'~~~'--(9) |
--  (8)-------------------------------'~~~'-|12 |-| O |-,~~~,-'~~~'-|25 |-| γ |-,~~~,--(8)~'
--  (7)-------------------------------------'~~~'-|15 |-| R |-,~~~,-'~~~'-|29 |-| θ |--(7)~,
--  (6)-------------------------------------------'~~~'-|18 |-| V |-,~~~,-'~~~'-|33 |--(6) | 10's place
--  (5)-------------------------------------------------'~~~'-|22 |-| Z |-,~~~,-'~~~'--(5) |
--  (4)-------------------------------------------------------'~~~'-|26 |-| δ |-,~~~,--(4)~'
--  (3)-------------------------------------------------------------'~~~'-|30 |-| λ |--(3)~,
--  (2)-------------------------------------------------------------------'~~~'-|34 |--(2) | 1's place
--  (1)-------------------------------------------------------------------------'~~~'--(1) |
--  (0)--------------------------------------------------------------------------------(0)~'

library IEEE;
use IEEE.std_logic_1164.all;

entity s7_bcd is
    port (
        x : in std_logic_vector(15 downto 0);
        y : out std_logic_vector(19 downto 0)
    );
end s7_bcd;

architecture simple of s7_bcd is
    signal dd1_sig, dd2_sig, dd3_sig, dd4_sig, dd5_sig, dd6_sig, 
        dd7_sig,  dd8_sig,  dd9_sig,  dd10_sig, dd11_sig, dd12_sig,
        dd13_sig, dd14_sig, dd15_sig, dd16_sig, dd17_sig, dd18_sig,
        dd19_sig, dd20_sig, dd21_sig, dd22_sig, dd23_sig, dd24_sig,
        dd25_sig, dd26_sig, dd27_sig, dd28_sig, dd29_sig, dd30_sig,
        dd31_sig, dd32_sig, dd33_sig, dd34_sig : std_logic_vector(3 downto 0);
begin
    dd1 : entity work.s7_dabble(simple)
        port map(
            x(3) => '0',
            x(2 downto 0) => x(15 downto 13),
            y => dd1_sig
        );
    dd2 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd1_sig(2 downto 0),
            x(0) => x(12),
            y => dd2_sig
        );
    dd3 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd2_sig(2 downto 0),
            x(0) => x(11),
            y => dd3_sig
        );
    dd4 : entity work.s7_dabble(simple)
        port map(
            x(3) => '0',
            x(2) => dd1_sig(3),
            x(1) => dd2_sig(3),
            x(0) => dd3_sig(3),
            y => dd4_sig
        );
    dd5 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd3_sig(2 downto 0),
            x(0) => x(10),
            y => dd5_sig
        );
    dd6 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd4_sig(2 downto 0),
            x(0) => dd5_sig(3),
            y => dd6_sig
        );
    dd7 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd5_sig(2 downto 0),
            x(0) => x(9),
            y => dd7_sig
        );
    dd8 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd6_sig(2 downto 0),
            x(0) => dd7_sig(3),
            y => dd8_sig
        );
    dd9 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd7_sig(2 downto 0),
            x(0) => x(8),
            y => dd9_sig
        );
    dd10 : entity work.s7_dabble(simple)
        port map(
            x(3) => '0',
            x(2) => dd4_sig(3),
            x(1) => dd6_sig(3),
            x(0) => dd8_sig(3),
            y => dd10_sig
        );
    dd11 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd8_sig(2 downto 0),
            x(0) => dd9_sig(3),
            y => dd11_sig
        );
    dd12 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd9_sig(2 downto 0),
            x(0) => x(7),
            y => dd12_sig
        );
    dd13 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd10_sig(2 downto 0),
            x(0) => dd11_sig(3),
            y => dd13_sig
        );
    dd14 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd11_sig(2 downto 0),
            x(0) => dd12_sig(3),
            y => dd14_sig
        );
    dd15 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd12_sig(2 downto 0),
            x(0) => x(6),
            y => dd15_sig
        );
    dd16 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd13_sig(2 downto 0),
            x(0) => dd14_sig(3),
            y => dd16_sig
        );
    dd17 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd14_sig(2 downto 0),
            x(0) => dd15_sig(3),
            y => dd17_sig
        );
    dd18 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd15_sig(2 downto 0),
            x(0) => x(5),
            y => dd18_sig
        );
    dd19 : entity work.s7_dabble(simple)
        port map(
            x(3) => '0',
            x(2) => dd10_sig(3),
            x(1) => dd13_sig(3),
            x(0) => dd16_sig(3),
            y => dd19_sig
        );
    dd20 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd16_sig(2 downto 0),
            x(0) => dd17_sig(3),
            y => dd20_sig
        );
    dd21 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd17_sig(2 downto 0),
            x(0) => dd18_sig(3),
            y => dd21_sig
        );
    dd22 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd18_sig(2 downto 0),
            x(0) => x(4),
            y => dd22_sig
        );
    dd23 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd19_sig(2 downto 0),
            x(0) => dd20_sig(3),
            y => dd23_sig
        );
    dd24 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd20_sig(2 downto 0),
            x(0) => dd21_sig(3),
            y => dd24_sig
        );
    dd25 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd21_sig(2 downto 0),
            x(0) => dd22_sig(3),
            y => dd25_sig
        );
    dd26 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd22_sig(2 downto 0),
            x(0) => x(3),
            y => dd26_sig
        );
    dd27 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd23_sig(2 downto 0),
            x(0) => dd24_sig(3),
            y => dd27_sig
        );
    dd28 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd24_sig(2 downto 0),
            x(0) => dd25_sig(3),
            y => dd28_sig
        );
    dd29 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd25_sig(2 downto 0),
            x(0) => dd26_sig(3),
            y => dd29_sig
        );
    dd30 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd26_sig(2 downto 0),
            x(0) => x(2),
            y => dd30_sig
        );
    dd31 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd27_sig(2 downto 0),
            x(0) => dd28_sig(3),
            y => dd31_sig
        );
    dd32 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd28_sig(2 downto 0),
            x(0) => dd29_sig(3),
            y => dd32_sig
        );
    dd33 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd29_sig(2 downto 0),
            x(0) => dd30_sig(3),
            y => dd33_sig
        );
    dd34 : entity work.s7_dabble(simple)
        port map(
            x(3 downto 1) => dd30_sig(2 downto 0),
            x(0) => x(1),
            y => dd34_sig
        );

    y(19) <= dd19_sig(3);
    y(18) <= dd23_sig(3);
    y(17) <= dd27_sig(3);
    y(16 downto 13) <= dd31_sig(3 downto 0);
    y(12 downto 9) <= dd32_sig(3 downto 0);
    y(8 downto 5) <= dd33_sig(3 downto 0);
    y(4 downto 1) <= dd34_sig(3 downto 0);
    y(0) <= x(0);
end simple;
