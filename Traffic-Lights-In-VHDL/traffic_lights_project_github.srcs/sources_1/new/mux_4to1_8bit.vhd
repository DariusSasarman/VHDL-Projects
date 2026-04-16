library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity mux_4to1_8bit is
  Port (
    in1 : in std_logic_vector (7 downto 0);
    in2 : in std_logic_vector (7 downto 0);
    in3 : in std_logic_vector (7 downto 0);
    in4 : in std_logic_vector (7 downto 0);
    s : in std_logic_vector ( 1 downto 0);
    outp : out std_logic_vector (7 downto 0)
   );
end mux_4to1_8bit;

architecture Behavioral of mux_4to1_8bit is
component mux_2to1_8bit is
  Port (
    in1 : in std_logic_vector ( 7 downto 0);
    in2 : in std_logic_vector ( 7 downto 0);
    s : in std_logic;
    outp : out std_logic_vector (7 downto 0)
   );
end component mux_2to1_8bit;

signal rez_mux1 : std_Logic_vector ( 7 downto 0);
signal rez_mux2 : std_Logic_vector ( 7 downto 0);
begin

c0: mux_2to1_8bit port map ( in1 => in1, in2 => in2, s => s(0), outp => rez_mux1);
c1: mux_2to1_8bit port map ( in1 => in3, in2 => in4, s => s(0), outp => rez_mux2);
c2: mux_2to1_8bit port map ( in1 => rez_mux1, in2 => rez_mux2, s => s(1), outp => outp);

end Behavioral;
