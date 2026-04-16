library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity Four_bit_comparator is
    Port ( A_0 ,A_1 ,A_2 ,A_3 : in STD_LOGIC;
           B_0 , B_1 , B_2 ,B_3 : in STD_LOGIC;
           AbiggerB , AequalB ,AsmallerB : out STD_LOGIC);
end Four_bit_comparator;
architecture Behavioral of Four_bit_comparator is
component twoBitComp is
    Port ( A1 ,A0 : in STD_LOGIC;
           B1 ,B0 : in STD_LOGIC;
           A1A0_b_B1B0 , A1A0_e_B1B0, A1A0_s_B1B0 : out STD_LOGIC);
end component;
component and2 is
    Port ( A ,B : in STD_LOGIC;
           AandB : out STD_LOGIC);
end component;
signal A3A2bB3B2,A3A2eB3B2,A3A2sB3B2,A1A0bB1B0,A1A0eB1B0,A1A0sB1B0, andSmaller, andBigger : std_logic ; 
begin
C1 : twoBitComp port map (A1 => A_3, A0 => A_2, B1 => B_3, B0 => B_2, 
                          A1A0_b_B1B0 => A3A2bB3B2, A1A0_e_B1B0 => A3A2eB3B2, A1A0_s_B1B0 => A3A2sB3B2);
C2 : twoBitComp port map (A1 => A_1, A0 => A_0, B1 => B_1, B0 => B_0, 
                          A1A0_b_B1B0 => A1A0bB1B0, A1A0_e_B1B0 => A1A0eB1B0, A1A0_s_B1B0 => A1A0sB1B0);
C3 : and2 port map ( A => A3A2eB3B2, B=> A1A0sB1B0, AandB => andSmaller);
C4 : and2 port map ( A => A3A2eB3B2, B=> A1A0bB1B0, AandB => andBigger);
AbiggerB <= A3A2bB3B2 or andBigger;
AequalB <= A3A2eB3B2 and A1A0eB1B0;
AsmallerB<= A3A2sB3B2 or andSmaller;
end Behavioral;

