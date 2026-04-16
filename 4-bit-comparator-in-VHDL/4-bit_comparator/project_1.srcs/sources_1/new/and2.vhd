library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity and2 is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           AandB : out STD_LOGIC);
end and2;

architecture Behavioral of and2 is

begin

AandB <= A and B;

end Behavioral;
