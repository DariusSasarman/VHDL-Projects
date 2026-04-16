library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity dmux_2to1_1bit is
    Port ( Inp : in STD_LOGIC;
           S : in STD_LOGIC;
           O0 : out STD_LOGIC;
           O1 : out STD_LOGIC);
end dmux_2to1_1bit;

architecture Behavioral of dmux_2to1_1bit is

begin

O0 <= Inp when S = '0' else '0';
O1 <= Inp when S = '1' else '0';

end Behavioral;
