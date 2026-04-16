library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity sim_comp_four_bits is
end sim_comp_four_bits;
architecture Behavioral of sim_comp_four_bits is
    component Four_bit_comparator
        Port (
            A_0, A_1, A_2, A_3 : in STD_LOGIC;
            B_0, B_1, B_2, B_3 : in STD_LOGIC;
            AbiggerB, AequalB, AsmallerB : out STD_LOGIC);
    end component;
    signal A_0, A_1, A_2, A_3 : STD_LOGIC := '0';
    signal B_0, B_1, B_2, B_3 : STD_LOGIC := '0';
    signal AbiggerB, AequalB, AsmallerB : STD_LOGIC;
begin
C1: Four_bit_comparator port map (
        A_0 => A_0,A_1 => A_1,A_2 => A_2,A_3 => A_3,
        B_0 => B_0,B_1 => B_1, B_2 => B_2,B_3 => B_3,
        AbiggerB => AbiggerB, AequalB => AequalB, AsmallerB => AsmallerB);
    B_0 <= not B_0 after 10 ns;   
    B_1 <= not B_1 after 20 ns;   
    B_2 <= not B_2 after 40 ns;  
    B_3 <= not B_3 after 80 ns;   
    A_0 <= not A_0 after 160 ns;  
    A_1 <= not A_1 after 320 ns;  
    A_2 <= not A_2 after 640 ns;  
    A_3 <= not A_3 after 1280 ns; 
end Behavioral; 

