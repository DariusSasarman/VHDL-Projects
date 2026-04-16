library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AandNotB is
    Port ( in1 : in STD_LOGIC;
           in2 : in STD_LOGIC;
           outp : out STD_LOGIC);
end AandNotB;

architecture Behavioral of AandNotB is

component and2 is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           AandB : out STD_LOGIC);
end component;

signal notin2 : std_logic ;

begin

notin2 <= (not in2);
-- should work, right??
c1 : and2 port map (in1,notin2,outp);

end Behavioral;
