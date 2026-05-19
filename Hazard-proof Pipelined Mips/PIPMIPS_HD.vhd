library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PIPMIPS_HD is
    Port ( 
        -- LW Hazard
        IDEX_OUT_CU_MEMTOREG : in std_logic;
        IDEX_OUT_WA : in std_logic_vector(2 downto 0);
        IDEX_IN_RS : in std_logic_vector(2 downto 0);
        IDEX_IN_RT : in std_logic_vector(2 downto 0);
        PC_freeze : out std_logic; 
        
        -- Branch Hazard
        
        -- EX/ID forwarding
        IDEX_OUT_CU_REGWRITE : in std_logic;
        EXMEM_IN_ALURES : in std_logic_vector(15 downto 0);
        
        -- MEM/ID forwarding
        EXMEM_OUT_cu_regWrite : in std_logic;
        EXMEM_OUT_WA : in std_logic_vector(2 downto 0);
        EXMEM_OUT_ALURES : in std_logic_vector(15 downto 0);
        
        -- WB/ID forwarding
        MEMWB_OUT_CU_REGWRITE : in std_logic;
        MEMWB_OUT_WA : in std_logic_vector(2 downto 0);
        WB_WD : in std_logic_vector(15 downto 0);

        IDEX_IN_RD1 : in std_logic_vector(15 downto 0);
        IDEX_IN_RD2 : in std_logic_vector(15 downto 0);
        
        IFID_OUT_INC_PC_ADDR : in std_logic_vector(15 downto 0);
        IDEX_IN_IMMEXT : in std_logic_vector(15 downto 0);
        
        CU_BRANCH : in std_logic;
        CU_BRANCH_TYPE : in std_logic;
        
        branch_addr: out std_logic_vector(15 downto 0);
        BRANCH_DECISION : out std_logic
    );
end PIPMIPS_HD;

architecture Behavioral of PIPMIPS_HD is

signal branch_rd1 : std_logic_vector(15 downto 0) := x"0000";
signal branch_rd2 : std_logic_vector(15 downto 0) := x"0000";
signal branch_zero : std_logic := '0';
signal branch_negative : std_logic := '0';
signal pc_freeze_sig: std_logic := '0';

begin

-- LW Hazard Unit
PC_freeze_sig <= '1' when IDEX_OUT_CU_MEMTOREG = '1' and ( (IDEX_OUT_WA = IDEX_IN_RS) or ( IDEX_OUT_WA = IDEX_IN_RT) ) else '0';
PC_freeze <= PC_freeze_sig;
-- Branch Hazard Unit

--RD1/RD2 forwarding for correct branch decision-making
-- Executed in ID step, therefore we need to forward 
-- from EX,MEM,WB in this order, if it's the case

branch_RD1 <= EXMEM_IN_ALURES when (IDEX_OUT_CU_REGWRITE = '1' and IDEX_OUT_WA = IDEX_IN_RS) else
              EXMEM_OUT_ALURES when (EXMEM_OUT_cu_regWrite = '1' and EXMEM_OUT_WA = IDEX_IN_RS) else
              WB_WD when (MEMWB_OUT_CU_REGWRITE = '1' and MEMWB_OUT_WA = IDEX_IN_RS) else
              IDEX_IN_RD1;

branch_RD2 <= EXMEM_IN_ALURES when (IDEX_OUT_CU_REGWRITE = '1' and IDEX_OUT_WA = IDEX_IN_RT) else
              EXMEM_OUT_ALURES when (EXMEM_OUT_cu_regWrite = '1' and EXMEM_OUT_WA = IDEX_IN_RT) else
              WB_WD when (MEMWB_OUT_CU_REGWRITE = '1' and MEMWB_OUT_WA = IDEX_IN_RT) else
              IDEX_IN_RD2;

-- Branch calculation done with current branch+1 address and current IMMEDIATE extended
branch_addr <= std_logic_vector(unsigned(IFID_OUT_INC_PC_ADDR) + unsigned(IDEX_IN_IMMEXT));

-- Conditional Signals
branch_zero     <= '1' when branch_RD1 = branch_RD2 else '0';
branch_negative <= '1' when signed(branch_RD1) < signed(branch_RD2) else '0';
BRANCH_DECISION <= CU_BRANCH and (
    (not CU_BRANCH_TYPE and branch_zero) or
    (    CU_BRANCH_TYPE and branch_negative))
    and not PC_freeze_sig;
    


end Behavioral;
