library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PIPMIPS_EX is
    Port ( 
           RD1 : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           EXT_IMM : in STD_LOGIC_VECTOR (15 downto 0);
           AluSrc : in std_logic;
           sa : in STD_LOGIC;
           Func : in STD_LOGIC_VECTOR (2 downto 0);
           ALUOP : in STD_LOGIC_VECTOR (1 downto 0);
           AluRes : out STD_LOGIC_VECTOR (15 downto 0));
end PIPMIPS_EX;

architecture Behavioral of PIPMIPS_EX is

signal alu_feed1 : std_logic_vector ( 15 downto 0);
signal alu_feed2 : std_logic_vector ( 15 downto 0);
signal alu_outp_val : std_logic_vector ( 15 downto 0);

signal alu_control : std_Logic_vector ( 3 downto 0);
--  0. ADD 000
--  1. SUB 001
--  2. AND 010
--  3. OR  011
--  4. XOR 100
--  5. SLT 101
--  6. SLL 110
--  7. SRL 111
--  8. PASS_A 
--  9. PASS_B
--  F. Pass 0


begin

SCMIPS_ALU_CU : process(func,AluOp)
begin
    case AluOp is 
        when "00" => alu_control <= '0' & func;     -- Do Func
        when "01" => alu_control <= "1001";         -- Pass B
        when "10" => alu_control <= "0000";         -- Force ADD
        when "11" => alu_control <= "0001";         -- Force SUB
        when others => alu_control <= "1111";       -- Pass 0
    end case;
end process;

alu_feed1 <= RD1;
alu_feed2 <= RD2 when ALuSrc = '0' else EXT_IMM;

SCMIPS_ALU: process(alu_feed1, alu_feed2, alu_control, sa)
begin
    case alu_control is
        --add
        when "0000" => alu_outp_val <= std_logic_vector(signed(alu_feed1) + signed(alu_feed2));
        --sub
        when "0001" => alu_outp_val <= std_logic_vector(signed(alu_feed1) - signed(alu_feed2));
        --and
        when "0010" => alu_outp_val <= alu_feed1 AND alu_feed2;
        --or
        when "0011" => alu_outp_val <= alu_feed1 OR alu_feed2;
        --xor
        when "0100" => alu_outp_val <= alu_feed1 XOR alu_feed2;
        --slt
        when "0101" => 
            if(signed(alu_feed1) < signed(alu_feed2)) then
                alu_outp_val <= x"0001";
            else
                alu_outp_val <= x"0000";
            end if;
        --shl
        when "0110" => 
            if (sa = '1') then
                alu_outp_val <= alu_feed1(14 downto 0) & '0';
            else
                alu_outp_val <= alu_feed1; 
            end if;
        --shr
        when "0111" => 
            if (sa = '1') then
                alu_outp_val <= '0' & alu_feed1(15 downto 1);
            else
                alu_outp_val <= alu_feed1;
            end if;
        --pass A
        when "1000" => alu_outp_val <= alu_feed1;
        --pass B
        when "1001" => alu_outp_val <= alu_feed2;
        when "1010" => alu_outp_val <= x"0000";
        when "1011" => alu_outp_val <= x"0000";
        when "1100" => alu_outp_val <= x"0000";
        when "1101" => alu_outp_val <= x"0000";
        when "1110" => alu_outp_val <= x"0000";
        when "1111" => alu_outp_val <= x"0000";
        when others => alu_outp_val <= x"0000";
    end case;
    
end process;

AluRes <= alu_outp_val;

end Behavioral;
