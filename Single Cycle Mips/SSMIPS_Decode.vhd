library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SSMIPS_Decode is
    Port ( regWrite : in STD_LOGIC;
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           clk : in std_logic ;
           rst : in std_logic;
           WD : in STD_LOGIC_VECTOR (15 downto 0);
           Instr : in STD_LOGIC_VECTOR (15 downto 0);
           
           RD1 : out STD_LOGIC_VECTOR (15 downto 0);
           RD2 : out STD_LOGIC_VECTOR (15 downto 0);
           immExt : out STD_LOGIC_VECTOR (15 downto 0);
           func : out STD_LOGIC_VECTOR (2 downto 0);
           sa : out std_logic);
end SSMIPS_Decode;

architecture Behavioral of SSMIPS_Decode is

signal RA1 : std_logic_vector (2 downto 0);
signal RA2 : std_logic_vector (2 downto 0);
signal WA : std_logic_vector ( 2 downto 0);

type reg_file_type is array (7 downto 0) of std_logic_vector(15 downto 0);

signal reg_file : reg_file_type :=(
    others => x"0000"
);

begin

RA1 <= Instr ( 12 downto 10);
RA2 <= Instr ( 9 downto 7);

REGF_WA_MUX : process(Instr, RegDst)
begin
    if(RegDst = '0') then
        WA <= Instr( 9 downto 7);
    else
        WA <= Instr(6 downto 4);
    end if;
end process;


SCMIPS_RF: process(clk, regWrite,rst)
begin
    if(rst = '1') then
        reg_file <= (others => x"0000");
    elsif(rising_edge(clk)) then
        if(regWrite = '1') then
            reg_file(to_integer(unsigned(WA))) <= WD;
        end if;
    end if;
end process;   
RD1 <= reg_file(to_integer(unsigned(RA1)));
RD2 <= reg_file(to_integer(unsigned(RA2)));


EXT_UNIT : immExt <= ((15 downto 7 => Instr(6)) & Instr(6 downto 0)) 
                     when (ExtOp) = '1' else
                     ((15 downto 7 => '0')& Instr(6 downto 0));
                     
func <= instr(2 downto 0);
sa <= instr(3);

end Behavioral;
