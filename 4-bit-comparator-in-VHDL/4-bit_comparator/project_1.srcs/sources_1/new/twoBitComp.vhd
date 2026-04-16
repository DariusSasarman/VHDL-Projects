library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity twoBitComp is
    Port ( A1 : in STD_LOGIC;
           A0 : in STD_LOGIC;
           B1 : in STD_LOGIC;
           B0 : in STD_LOGIC;
           A1A0_b_B1B0 : out STD_LOGIC;
           A1A0_e_B1B0 : out STD_LOGIC;
           A1A0_s_B1B0 : out STD_LOGIC);
end twoBitComp;
architecture Behavioral of twoBitComp is
component oneBitComp is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           AbB : out STD_LOGIC;
           AeB : out STD_LOGIC;
           AsB : out STD_LOGIC);
end component;
component and2 is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           AandB : out STD_LOGIC);
end component;
signal A1bB1, A1eB1, A1sB1, A0bB0, A0eB0, A0sB0, andBigger, andSmaller : std_logic ;
begin
C1 : oneBitComp port map ( A => A1, B=> B1, AbB => A1bB1, AeB => A1eB1, AsB => A1sB1);
C2 : oneBitComp port map ( A => A0, B=> B0, AbB => A0bB0, AeB => A0eB0, AsB => A0sB0);
C3 : and2 port map ( A => A1eB1, B => A0sB0, AandB => andSmaller);
C4 : and2 port map ( A=> A1eB1, B=>A0bB0, AandB => andBigger);
A1A0_e_B1B0 <= A1eB1 and A0eB0;
A1A0_s_B1B0 <= A1sB1 or andSmaller;
A1A0_b_B1B0 <= A1bB1 or andBigger;
end Behavioral;