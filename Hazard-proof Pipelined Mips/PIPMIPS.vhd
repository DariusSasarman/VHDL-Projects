library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PIPMIPS is
    Port ( clk : in STD_LOGIC;
           rst : in STD_Logic;
           
           instruction_out : out std_logic_vector(15 downto 0);
           next_branch_addr_out : out std_logic_vector(15 downto 0);
           RD1_out : out std_logic_vector(15 downto 0);
           RD2_out : out std_logic_vector(15 downto 0);
           extImm_out : out std_logic_vector(15 downto 0);
           aluRes_out : out std_logic_vector(15 downto 0);
           memData_out : out std_logic_vector(15 downto 0);
           WD_out : out std_logic_vector(15 downto 0);
           
           cu_aluop_out : out std_logic_vector(1 downto 0); 
           cu_regdst_out : out std_logic;
           cu_extop_out : out std_logic;
           cu_regWrite_out : out std_logic;
           
           cu_branch_out : out std_logic;
           cu_branch_type_out : out std_logic;
           
           cu_jump_out : out std_logic ;
           cu_aluSrcB_out : out std_logic ;
           cu_memWrite_out : out std_logic;
           cu_memToReg_out : out std_logic 
         );
end PIPMIPS;

architecture Behavioral of PIPMIPS is

-- IF

component PIPMIPS_IF is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           freeze : in std_logic;
           branch : in STD_LOGIC;
           branch_addr : in std_logic_vector(15 downto 0);
           jump : in std_logic;
           jump_addr : in std_logic_vector(15 downto 0);  
           instruction : out STD_LOGIC_VECTOR (15 downto 0);
           inc_pc_addr : out std_logic_vector (15 downto 0)
         );
end component;

-- IF/ID

signal IFID_IN_INC_PC_ADDR : std_logic_vector(15 downto 0) := x"0000";
signal IFID_OUT_INC_PC_ADDR : std_logic_vector(15 downto 0) := x"0000";
signal IFID_IN_INSTRUCTION : std_Logic_vector (15 downto 0) := x"0000";
signal IFID_OUT_INSTRUCTION : std_Logic_vector (15 downto 0) := x"0000";

-- ID

signal JUMP_ADDR : std_logic_vector(15 downto 0) := x"0000";

component PIPMIPS_CU is
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
end component;

signal CU_ALUOP       : std_logic_vector(1 downto 0) := "00";
signal CU_REGDST      : std_logic := '0';
signal CU_EXTOP       : std_logic := '0';
signal CU_REGWRITE    : std_logic := '0';
signal CU_BRANCH      : std_logic := '0';
signal CU_BRANCH_TYPE : std_logic := '0';
signal CU_JUMP        : std_logic := '0';
signal CU_ALUSRCB     : std_logic := '0';
signal CU_MEMWRITE    : std_logic := '0';
signal CU_MEMTOREG    : std_logic := '0';

component PIPMIPS_ID is
    Port ( regWrite : in STD_LOGIC;
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           
           clk : in std_logic ;
           rst : in std_logic;
           
           WD : in STD_LOGIC_VECTOR (15 downto 0);
           WAI : in STD_logic_vector (2 downto 0);
           WAO : out STD_logic_vector (2 downto 0);
           Instr : in STD_LOGIC_VECTOR (15 downto 0);
           
           RD1 : out STD_LOGIC_VECTOR (15 downto 0);
           RD2 : out STD_LOGIC_VECTOR (15 downto 0);
           immExt : out STD_LOGIC_VECTOR (15 downto 0);
           func : out STD_LOGIC_VECTOR (2 downto 0);
           sa : out std_logic);
end component;

-- ID/EX

signal IDEX_IN_WA : std_logic_vector(2 downto 0);
signal IDEX_OUT_WA : std_logic_vector(2 downto 0);

signal IDEX_IN_RD1 : std_logic_vector(15 downto 0);
signal IDEX_OUT_RD1 : std_logic_vector(15 downto 0);

signal IDEX_IN_RD2 : std_logic_vector(15 downto 0);
signal IDEX_OUT_RD2 : std_logic_vector(15 downto 0);

signal IDEX_IN_IMMEXT : std_logic_vector(15 downto 0);
signal IDEX_OUT_IMMEXT : std_logic_vector(15 downto 0);

signal IDEX_IN_FUNC : std_logic_vector(2 downto 0);
signal IDEX_OUT_FUNC : std_logic_vector(2 downto 0);

signal IDEX_IN_SA : std_logic;
signal IDEX_OUT_SA : std_logic;

signal IDEX_IN_CU_MEMTOREG    : std_logic;
signal IDEX_OUT_CU_MEMTOREG   : std_logic;

signal IDEX_IN_CU_REGWRITE    : std_logic;
signal IDEX_OUT_CU_REGWRITE   : std_logic;

signal IDEX_IN_CU_MEMWRITE    : std_logic;
signal IDEX_OUT_CU_MEMWRITE   : std_logic;

signal IDEX_IN_CU_ALUOP : std_logic_vector(1 downto 0);
signal IDEX_OUT_CU_ALUOP : std_logic_vector(1 downto 0);

signal IDEX_IN_CU_ALUSRCB : std_logic; 
signal IDEX_OUT_CU_ALUSRCB : std_logic;

signal IDEX_IN_RS : std_logic_vector(2 downto 0);
signal IDEX_OUT_RS : std_logic_vector(2 downto 0);

signal IDEX_IN_RT : std_logic_vector(2 downto 0);
signal IDEX_OUT_RT : std_logic_vector(2 downto 0);

-- EX

component PIPMIPS_EX is
    Port ( 
           RD1 : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           EXT_IMM : in STD_LOGIC_VECTOR (15 downto 0);
           AluSrc : in std_logic;
           sa : in STD_LOGIC;
           Func : in STD_LOGIC_VECTOR (2 downto 0);
           ALUOP : in STD_LOGIC_VECTOR (1 downto 0);
           AluRes : out STD_LOGIC_VECTOR (15 downto 0));
end component;

-- EX/MEM


signal EXMEM_IN_ALURES : std_logic_vector(15 downto 0) := x"0000";
signal EXMEM_OUT_ALURES : std_logic_vector(15 downto 0) := x"0000";

signal EXMEM_IN_WA           : std_logic_vector(2 downto 0);
signal EXMEM_OUT_WA          : std_logic_vector(2 downto 0);

signal EXMEM_IN_RD2          : std_logic_vector(15 downto 0);
signal EXMEM_OUT_RD2         : std_logic_vector(15 downto 0);

signal EXMEM_IN_CU_MEMWRITE  : std_logic;
signal EXMEM_OUT_CU_MEMWRITE : std_logic;

signal EXMEM_IN_CU_MEMTOREG  : std_logic;
signal EXMEM_OUT_CU_MEMTOREG : std_logic;

signal EXMEM_IN_CU_REGWRITE  : std_logic;
signal EXMEM_OUT_CU_REGWRITE : std_logic;

-- MEM

component PIPMIPS_MEM is
    Port ( memWrite : in STD_LOGIC;
           rst : in std_logic;
           clk : in STD_LOGIC;
           AluResIn : in STD_LOGIC_VECTOR (15 downto 0);
           WDMem : in STD_LOGIC_VECTOR (15 downto 0);
           MemData : out STD_LOGIC_VECTOR (15 downto 0);
           AluResOut : out STD_LOGIC_VECTOR (15 downto 0)
         );
end component;

signal BRANCH_DECISION : std_logic := '0';

-- MEM/WB

signal MEMWB_IN_REGWRITE : Std_logic := '0';
signal MEMWB_OUT_CU_REGWRITE : Std_logic := '0';

signal MEMWB_IN_MEMDATA    : std_logic_vector(15 downto 0);
signal MEMWB_OUT_MEMDATA   : std_logic_vector(15 downto 0);

signal MEMWB_IN_ALURESOUT  : std_logic_vector(15 downto 0);
signal MEMWB_OUT_ALURESOUT : std_logic_vector(15 downto 0);

signal MEMWB_IN_WA         : std_logic_vector(2 downto 0);
signal MEMWB_OUT_WA        : std_logic_vector(2 downto 0);

signal MEMWB_IN_CU_MEMTOREG  : std_logic;
signal MEMWB_OUT_CU_MEMTOREG : std_logic;

-- WB

signal WB_WD : std_logic_vector (15 downto 0) := x"0000";
signal WB_WA : std_logic_vector (2 downto 0) := "000";
 

-- Forwarding Unit signals

signal final_RD1 : std_logic_vector(15 downto 0) := x"0000";
signal final_RD2 : std_logic_vector(15 downto 0) := x"0000"; 

-- Hazard detection unit signals

signal PC_freeze : std_logic := '0';
signal branch_addr : std_logic_vector(15 downto 0) := x"0000";

component PIPMIPS_HD is
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
end component;


begin

-- IF

PIPMIPS_InsFet : PIPMIPS_IF
    port map (
        clk => clk,
        rst => rst,
        freeze => PC_freeze,
        branch => BRANCH_DECISION,
        branch_addr  => branch_addr,
        jump => CU_JUMP, jump_addr => JUMP_ADDR,
        instruction => IFID_IN_INSTRUCTION,
        inc_pc_addr => IFID_IN_INC_PC_ADDR
    );

-- IF/ID

IFID_REG: process(clk, rst)
begin
    if rst = '1' then
        IFID_OUT_INC_PC_ADDR <= x"0000";
        IFID_OUT_INSTRUCTION <= x"0000";
    elsif rising_edge(clk) then
        if(branch_decision = '1' or CU_JUMP = '1') then
            IFID_OUT_INC_PC_ADDR <= x"0000";
            IFID_OUT_INSTRUCTION <= x"0000";
        elsif ( pc_freeze = '1') then
            IFID_OUT_INC_PC_ADDR <= IFID_OUT_INC_PC_ADDR;
            IFID_OUT_INSTRUCTION <= IFID_OUT_INSTRUCTION;
        else 
            IFID_OUT_INC_PC_ADDR <= IFID_IN_INC_PC_ADDR;
            IFID_OUT_INSTRUCTION <= IFID_IN_INSTRUCTION;
        end if;
    end if;
end process;

-- ID

PIPMIPS_ConUni : PIPMIPS_CU
    port map (
        instruction => IFID_OUT_INSTRUCTION(15 downto 13),
        AluOp => CU_ALUOP,
        RegDst => CU_REGDST,
        ExtOP => CU_EXTOP,
        RegWrite => CU_REGWRITE,
        Branch => CU_BRANCH,
        Branch_type => CU_BRANCH_TYPE,
        Jump => CU_JUMP,
        AluSrcB => CU_ALUSRCB,
        MemWrite => CU_MEMWRITE,
        MemToReg => CU_MEMTOREG
    );

PIPMIPS_InsDec : PIPMIPS_ID
    port map (
        regWrite => MEMWB_OUT_CU_REGWRITE,
        RegDst => CU_REGDST,
        ExtOp => CU_EXTOP,
        clk => clk,
        rst => rst,
        WD => WB_WD,
        WAI=> WB_WA,
        WAO => IDEX_IN_WA,
        Instr => IFID_OUT_INSTRUCTION,
        RD1 => IDEX_IN_RD1,
        RD2 => IDEX_IN_RD2,
        immExt=> IDEX_IN_IMMEXT,
        func => IDEX_IN_FUNC,
        sa => IDEX_IN_sa
    );
IDEX_IN_CU_ALUOP <= CU_ALUOP;
IDEX_IN_CU_REGWRITE <= CU_REGWRITE;
IDEX_IN_CU_ALUSRCB <= CU_ALUSRCB;
IDEX_IN_CU_MEMWRITE <= CU_MEMWRITE;
IDEX_IN_CU_MEMTOREG <= CU_MEMTOREG;
IDEX_IN_RS <= IFID_OUT_INSTRUCTION(12 downto 10);
IDEX_IN_RT <= IFID_OUT_INSTRUCTION(9 downto 7);

JUMP_ADDR <= "000" & IFID_OUT_INSTRUCTION(12 downto 0);
  
-- ID/EX

IDEX_REG : process(clk, rst)
begin
    if rst = '1' then
        IDEX_OUT_WA  <= (others => '0');
        IDEX_OUT_RD1 <= (others => '0');
        IDEX_OUT_RD2 <= (others => '0');
        IDEX_OUT_IMMEXT <= (others => '0');
        IDEX_OUT_FUNC <= (others => '0');
        IDEX_OUT_SA <= '0';
        IDEX_OUT_CU_MEMTOREG <= '0';
        IDEX_OUT_CU_REGWRITE <= '0';
        IDEX_OUT_CU_MEMWRITE <= '0';
        IDEX_OUT_CU_ALUOP <= (others => '0');
        IDEX_OUT_CU_ALUSRCB <= '0';
        IDEX_OUT_RS <= (others => '0');
        IDEX_OUT_RT <= (others => '0');
    elsif rising_edge(clk) then
        if( PC_freeze = '1') then 
            IDEX_OUT_WA  <= (others => '0');
            IDEX_OUT_RD1 <= (others => '0');
            IDEX_OUT_RD2 <= (others => '0');
            IDEX_OUT_IMMEXT <= (others => '0');
            IDEX_OUT_FUNC <= (others => '0');
            IDEX_OUT_SA <= '0';
            IDEX_OUT_CU_MEMTOREG <= '0';
            IDEX_OUT_CU_REGWRITE <= '0';
            IDEX_OUT_CU_MEMWRITE <= '0';
            IDEX_OUT_CU_ALUOP <= (others => '0');
            IDEX_OUT_CU_ALUSRCB <= '0';
            IDEX_OUT_RS <= (others => '0');
            IDEX_OUT_RT <= (others => '0');
        else 
            IDEX_OUT_WA <= IDEX_IN_WA;
            IDEX_OUT_RD1 <= IDEX_IN_RD1;
            IDEX_OUT_RD2 <= IDEX_IN_RD2;
            IDEX_OUT_IMMEXT <= IDEX_IN_IMMEXT;
            IDEX_OUT_FUNC <= IDEX_IN_FUNC;
            IDEX_OUT_SA <= IDEX_IN_SA;
            IDEX_OUT_CU_MEMTOREG <= IDEX_IN_CU_MEMTOREG;
            IDEX_OUT_CU_REGWRITE <= IDEX_IN_CU_REGWRITE;
            IDEX_OUT_CU_MEMWRITE <= IDEX_IN_CU_MEMWRITE;
            IDEX_OUT_CU_ALUOP <= IDEX_IN_CU_ALUOP;
            IDEX_OUT_CU_ALUSRCB <= IDEX_IN_CU_ALUSRCB;
            IDEX_OUT_RS <= IDEX_IN_RS;
            IDEX_OUT_RT <= IDEX_IN_RT;
        end if;
    end if;
end process IDEX_REG;

-- EX

PIPMIPS_EXec : PIPMIPS_EX
    port map (
        RD1 => final_RD1,
        RD2 => final_RD2,
        EXT_IMM => IDEX_OUT_IMMEXT,
        AluSrc => IDEX_OUT_CU_ALUSRCB,
        sa => IDEX_OUT_SA,
        Func => IDEX_OUT_FUNC,
        ALUOP => IDEX_OUT_CU_ALUOP,
        AluRes => EXMEM_IN_ALURES
        );
    
EXMEM_IN_WA <= IDEX_OUT_WA;
EXMEM_IN_RD2 <= Final_RD2;
EXMEM_IN_CU_MEMWRITE <= IDEX_OUT_CU_MEMWRITE;
EXMEM_IN_CU_MEMTOREG <= IDEX_OUT_CU_MEMTOREG;
EXMEM_IN_CU_REGWRITE <= IDEX_OUT_CU_REGWRITE;

-- EX/MEM

EXMEM_REG : process(clk, rst)
begin
    if rst = '1' then
        EXMEM_OUT_WA <= (others => '0');
        EXMEM_OUT_RD2 <= (others => '0');
        EXMEM_OUT_ALURES <= (others => '0');
        EXMEM_OUT_CU_MEMWRITE <= '0';
        EXMEM_OUT_CU_MEMTOREG <= '0';
        EXMEM_OUT_CU_REGWRITE <= '0';
    elsif rising_edge(clk) then
        EXMEM_OUT_WA <= EXMEM_IN_WA;
        EXMEM_OUT_RD2 <= EXMEM_IN_RD2;
        EXMEM_OUT_ALURES <= EXMEM_IN_ALURES;
        EXMEM_OUT_CU_MEMWRITE <= EXMEM_IN_CU_MEMWRITE;
        EXMEM_OUT_CU_MEMTOREG <= EXMEM_IN_CU_MEMTOREG;
        EXMEM_OUT_CU_REGWRITE <= EXMEM_IN_CU_REGWRITE;
    end if;
end process EXMEM_REG;

-- MEM

PIPMIPS_MEMo : PIPMIPS_MEM
    port map (
        memWrite => EXMEM_OUT_CU_MEMWRITE,
        rst => rst,
        clk => clk,
        AluResIn => EXMEM_OUT_ALURES,
        WDMem => EXMEM_OUT_RD2,
        MemData => MEMWB_IN_MEMDATA,
        AluResOut => MEMWB_IN_ALURESOUT
    );

MEMWB_IN_WA <= EXMEM_OUT_WA;
MEMWB_IN_CU_MEMTOREG <= EXMEM_OUT_CU_MEMTOREG;
MEMWB_IN_REGWRITE <= EXMEM_OUT_CU_REGWRITE;

-- MEM/WB

MEMWB_REG : process(clk, rst)
begin
    if rst = '1' then
        MEMWB_OUT_MEMDATA <= (others => '0');
        MEMWB_OUT_ALURESOUT  <= (others => '0');
        MEMWB_OUT_WA <= (others => '0');
        MEMWB_OUT_CU_MEMTOREG <= '0';
        MEMWB_OUT_CU_REGWRITE   <= '0';
    elsif rising_edge(clk) then
        MEMWB_OUT_MEMDATA <= MEMWB_IN_MEMDATA;
        MEMWB_OUT_ALURESOUT  <= MEMWB_IN_ALURESOUT;
        MEMWB_OUT_WA <= MEMWB_IN_WA;
        MEMWB_OUT_CU_MEMTOREG <= MEMWB_IN_CU_MEMTOREG;
        MEMWB_OUT_CU_REGWRITE <= MEMWB_IN_REGWRITE;
    end if;
end process MEMWB_REG;

-- WB

WB_WD <= MEMWB_OUT_MEMDATA when MEMWB_OUT_CU_MEMTOREG = '1' else MEMWB_OUT_ALURESOUT;
WB_WA <= MEMWB_OUT_WA;


-- Hazard Unit
PIPMIPS_HazardDetection: PIPMIPS_HD
    Port map( 
        IDEX_OUT_CU_MEMTOREG =>IDEX_OUT_CU_MEMTOREG,
        IDEX_OUT_WA =>IDEX_OUT_WA,
        IDEX_IN_RS =>IDEX_IN_RS,
        IDEX_IN_RT =>IDEX_IN_RT,
        PC_freeze =>  PC_freeze,
        IDEX_OUT_CU_REGWRITE => IDEX_OUT_CU_REGWRITE,
        EXMEM_IN_ALURES => EXMEM_IN_ALURES,
        EXMEM_OUT_cu_regWrite => EXMEM_OUT_cu_regWrite,
        EXMEM_OUT_WA => EXMEM_OUT_WA,
        EXMEM_OUT_ALURES => EXMEM_OUT_ALURES,
        MEMWB_OUT_CU_REGWRITE => MEMWB_OUT_CU_REGWRITE,
        MEMWB_OUT_WA => MEMWB_OUT_WA,
        WB_WD => Wb_Wd,
        IDEX_IN_RD1 =>IDEX_IN_RD1,
        IDEX_IN_RD2 =>IDEX_IN_RD2,
        IFID_OUT_INC_PC_ADDR =>IFID_OUT_INC_PC_ADDR,
        IDEX_IN_IMMEXT => idex_in_immext,
        CU_BRANCH => cu_branch,
        CU_BRANCH_TYPE => Cu_branch_type,
        branch_addr => branch_addr,
        BRANCH_DECISION => branch_decision 
    );

--- FORWARDING UNIT
ForwardingUnit: process( IDEX_OUT_RS, IDEX_OUT_RT,IDEX_OUT_RD1, IDEX_OUT_RD2,
                         EXMEM_OUT_CU_REGWRITE, MEMWB_OUT_CU_REGWRITE,
                         EXMEM_OUT_WA, MEMWB_OUT_WA, WB_WD , EXMEM_OUT_ALURES)
begin
    -- Forwarding for RD1 EX stage
    if(EXMEM_OUT_CU_REGWRITE = '1' and IDEX_OUT_RS = EXMEM_OUT_WA) then
        FINAL_RD1 <= EXMEM_OUT_ALURES;
    elsif (MEMWB_OUT_CU_REGWRITE = '1' and IDEX_OUT_RS = MEMWB_OUT_WA) then
        FINAL_RD1 <= WB_WD;
    else
        FINAL_RD1 <= IDEX_OUT_RD1;
    end if;
    -- Forwarding for RD2 EX stage
    if(EXMEM_OUT_CU_REGWRITE = '1' and IDEX_OUT_RT = EXMEM_OUT_WA) then
        FINAL_RD2 <= EXMEM_OUT_ALURES;
    elsif (MEMWB_OUT_CU_REGWRITE = '1' and IDEX_OUT_RT = MEMWB_OUT_WA) then
        FINAL_RD2 <= WB_WD;
    else
        FINAL_RD2 <= IDEX_OUT_RD2;
    end if;
    
end process;

instruction_out <= IFID_OUT_INSTRUCTION;

RD1_out <= FINAL_RD1;
RD2_out <= FINAL_RD2;
aluRes_out <= EXMEM_IN_ALURES;

next_branch_addr_out <= branch_addr;
extImm_out <= idex_in_immext;

memData_out <= MEMWB_OUT_MEMDATA;
WD_out <= WB_WD;

cu_aluop_out <= CU_ALUOP;
cu_regdst_out <= CU_REGDST;
cu_extop_out <= CU_EXTOP;
cu_regWrite_out <= CU_REGWRITE;
cu_branch_out <= branch_decision;
cu_branch_type_out <= CU_BRANCH_TYPE;
cu_jump_out <= CU_JUMP;
cu_aluSrcB_out <= CU_ALUSRCB;
cu_memWrite_out <= CU_MEMWRITE;
cu_memToReg_out <= CU_MEMTOREG;

end Behavioral;
