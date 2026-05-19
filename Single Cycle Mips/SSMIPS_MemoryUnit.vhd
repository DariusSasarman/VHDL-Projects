library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SSMIPS_MemoryUnit is
    Port ( memWrite : in STD_LOGIC;
           rst : in std_logic ;
           clk : in STD_LOGIC;
           AluResIn : in STD_LOGIC_VECTOR (15 downto 0);
           WDMem : in STD_LOGIC_VECTOR (15 downto 0);
           MemData : out STD_LOGIC_VECTOR (15 downto 0);
           AluResOut : out STD_LOGIC_VECTOR (15 downto 0)
         );
end SSMIPS_MemoryUnit;

architecture Behavioral of SSMIPS_MemoryUnit is

type ram_type is array (31 downto 0) of std_logic_vector ( 15 downto 0);
signal ram : ram_type :=(
    others => x"0000"
);

begin

MemData <= ram(to_integer(unsigned(AluResIn)));

ram_proc: process(AluResIn,memWrite,WDMem)
begin
    if(rst = '1') then
        ram <= (others => x"0000");
    elsif(rising_edge(clk)) then
        if(memWrite = '1') then
            ram(to_integer(unsigned(AluResIn))) <= WDMem;            
        end if;
    end if;
end process;

AluResOut <= AluResIn;

end Behavioral;
