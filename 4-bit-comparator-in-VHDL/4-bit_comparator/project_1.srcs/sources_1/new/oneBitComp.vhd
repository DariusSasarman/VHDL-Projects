library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity oneBitComp is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           AbB : out STD_LOGIC;
           AeB : out STD_LOGIC;
           AsB : out STD_LOGIC);
end oneBitComp;
architecture Behavioral of oneBitComp is
    component AandNotB is
    Port ( in1 : in STD_LOGIC;
           in2 : in STD_LOGIC;
           outp : out STD_LOGIC);
    end component;
begin
c1 : AandNotB port map ( in1 => A, in2=> B, outp => AbB);
AeB <= A xnor B;
c2 : AandNotB port map ( in1 => B, in2=> A, outp => AsB);
end Behavioral;