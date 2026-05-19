library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PIPMIPS_CU is
    Port ( instruction : in STD_LOGIC_VECTOR (15 downto 13);
           AluOp : out STD_LOGIC_VECTOR(1 downto 0);
           RegDst : out STD_LOGIC;
           ExtOP : out STD_LOGIC;
           RegWrite : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Branch_type : out std_logic;
           Jump : out STD_LOGIC;
           AluSrcB : out STD_LOGIC;
           MemWrite : out STD_LOGIC;
           MemToReg : out STD_LOGIC);
end PIPMIPS_CU;

architecture Behavioral of PIPMIPS_CU is

begin

process(instruction)
begin
    case instruction is 
        when "000" =>  -- R-type
            AluOP   <= "00";    -- execute function
            RegDst  <= '1';     -- we have Dest register
            ExtOp   <= '0';     -- we don't need to extend
            RegWrite <= '1';    -- we're writing to Dest Reg
            Branch  <= '0';     -- we're not branching
            Branch_type <= '0'; -- don't care
            Jump    <= '0';     -- we're not jumping
            AluSrcB <= '0';     -- we're using RD2
            MemWrite <= '0';    -- reg op
            MemToReg <= '0';    -- Pass ALU result
        when "001" => -- LOADI
            AluOp   <= "01";    -- PASS B
            RegDst  <= '0';     -- we write into Target Register
            ExtOp   <= '1';     -- we need to extend immediate
            RegWrite <='1';     -- we write into Target Register
            Branch  <= '0';     -- we're not branching
            Branch_type <= '0'; -- don't care
            Jump    <= '0';     -- we're not jumping
            AluSrcB <= '1';     -- we're using immediate
            MemWrite <='0';     -- reg op
            MemToReg <='0';     -- Pass ALU result
        when "010" => -- ADDI
            AluOp   <= "10";    -- FORCE ADD
            RegDst  <= '0';     -- we write into Target Register
            ExtOp   <= '1';     -- we need to extend immediate
            RegWrite <='1';     -- we write into Target Register
            Branch  <= '0';     -- we're not branching
            Branch_type <= '0'; -- don't care
            Jump    <= '0';     -- we're not jumping
            AluSrcB <= '1';     -- we're ussing immediate
            MemWrite <='0';     -- reg op
            MemToReg <='0';     -- Pass ALU result
        when "011" => -- LW
            AluOp   <= "10";    -- FORCE ADD
            RegDst  <= '0';     -- we write into Target Register
            ExtOp   <= '1';     -- we need to extend immediate
            RegWrite <='1';     -- we write into Target Register
            Branch  <= '0';     -- we're not branching
            Branch_type <= '0'; -- don't care
            Jump    <= '0';     -- we're not jumping
            AluSrcB <= '1';     -- we're adding immediate
            MemWrite <= '0';    -- register operation
            MemToReg <= '1';    -- Pass Memory result
        when "100" => -- SW
            AluOp   <= "10";    -- FORCE ADD
            RegDst  <= '0';     -- Don't care
            ExtOp   <= '1';     -- we need to extend immediate;
            RegWrite<= '0';     -- we don't write into any register
            Branch <= '0';      -- we're not branching
            Branch_type <= '0'; -- don't care
            Jump   <= '0';      -- we're not jumping
            AluSrcB <='1';      -- We're adding immediate
            MemWrite <='1';     -- We do write into memory
            MemToReg <= '0';    -- Don't care
        when "101" => --BEQ
            AluOp   <="11";     -- FORCE SUB
            RegDst  <='0';      -- Don't care
            ExtOp   <='1';      -- We extend immediate
            RegWrite <= '0';    -- Not writing to registers
            Branch  <= '1';     -- We do branch
            Branch_type <= '0'; -- it's a EQUAL type
            Jump <= '0';        -- but not jump
            AluSrcB <='0';      -- We're subtracting R[s] and R[t]
            MemWrite <='0';     -- We're not writing
            MemToReg <='0';     -- Don't care
        when "110" => --BLT
            AluOp   <="11";     -- FORCE SUB
            RegDst  <='0';      -- Don't care
            ExtOp   <='1';      -- We extend immediate
            RegWrite <= '0';    -- Not writing to registers
            Branch  <= '1';     -- We do branch
            Branch_type <= '1'; -- It's a LESS THAN type
            Jump <= '0';        -- but not jump
            AluSrcB <='0';      -- We're subtracting R[s] and R[t]
            MemWrite <='0';     -- We're not writing
            MemToReg <='0';     -- Don't care
        when "111" => -- JUMP
            AluOp   <="00";     -- Don't care
            RegDst  <= '0';     -- Don't care
            ExtOp   <='0' ;     -- Don't care
            RegWrite<='0';      -- Don't write
            Branch_type <= '0'; -- Don't care
            Branch <='0';       -- Don't care
            Jump   <= '1';      -- We jump
            AluSrcB<= '0';      -- Don't care
            MemWrite<='0';      -- Don't write
            MemToReg<='0';     -- Don't write
        when others => -- Others
            AluOp   <="00";     -- Don't care
            RegDst  <= '0';     -- Don't care
            ExtOp   <='0' ;     -- Don't care
            RegWrite<='0';      -- Don't write
            Branch <='0';       -- Don't branch
            Branch_type <= '0'; -- Don't care
            Jump   <= '0';      -- Don't jump
            AluSrcB<= '0';      -- Don't care
            MemWrite<='0';      -- Don't write
            MemToReg<='0';     -- Don't write
     end case;
end process;

end Behavioral;
