library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SevenSegDisplayer is
    Port ( clk : in STD_LOGIC;
           Digit0 : in STD_LOGIC_VECTOR (3 downto 0);
           Digit1 : in STD_LOGIC_VECTOR (3 downto 0);
           Digit2 : in STD_LOGIC_VECTOR (3 downto 0);
           Digit3 : in STD_LOGIC_VECTOR (3 downto 0);
           Cat : out STD_LOGIC_VECTOR (6 downto 0);
           An : out STD_LOGIC_VECTOR (3 downto 0));
end SevenSegDisplayer;

architecture Behavioral of SevenSegDisplayer is

signal mux1Q : std_logic_vector(3 downto 0) := (others => '0');
signal mux2Q : std_logic_vector(3 downto 0) := (others => '0');
signal counterQ : std_logic_vector(15 downto 0) :=(others => '0');
signal CatSig : std_logic_vector(7 downto 0) := (others => '0');

begin

counter: process(clk)
begin
    if(rising_edge(clk)) then
        if(counterQ = x"FFFF") then
            counterQ <= x"0000";
        else 
            counterQ <= std_logic_vector(unsigned(counterQ) + 1);
        end if;
    end if;
end process;

mux1Q <= Digit0 when counterQ(15 downto 14) = "00" else 
         Digit1 when counterQ(15 downto 14) = "01" else
         Digit2 when counterQ(15 downto 14) = "10" else
         Digit3;

mux2Q <= "1110" when counterQ(15 downto 14) = "00" else 
         "1101" when counterQ(15 downto 14) = "01" else
         "1011" when counterQ(15 downto 14) = "10" else
         "0111";

An <= mux2Q;
Cat <= CatSig(6 downto 0);

dcd : process(mux1Q)
begin
    case mux1Q is 
        when "0000" => CatSig <= x"C0";
        when "0001" => CatSig <= x"F9";
        when "0010" => CatSig <= x"A4";
        when "0011" => CatSig <= x"B0";
        when "0100" => CatSig <= x"99";
        when "0101" => CatSig <= x"92";
        when "0110" => CatSig <= x"82";
        when "0111" => CatSig <= x"F8";
        when "1000" => CatSig <= x"80";
        when "1001" => CatSig <= x"90";
        when "1010" => CatSig <= x"88";
        when "1011" => CatSig <= x"83";
        when "1100" => CatSig <= x"C6";
        when "1101" => CatSig <= x"A1";
        when "1110" => CatSig <= x"86";
        when others => CatSig <= x"8E";
    end case;
end process;

end Behavioral;
