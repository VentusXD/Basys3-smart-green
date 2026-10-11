Library IEEE;
use IEEE.std_logic_1164.all;

Entity LatchRS is
	port(
	RST : in std_logic;
	CLK : in std_logic;
	SET : in std_logic;
	CLR : in std_logic;
	QOUT : out std_logic
	);
end LatchRS;

Architecture Behavioral of LatchRS is
signal Qp, Qn : std_logic;
begin
	Combinational : process(Qp, SET, CLR)
	begin
		if SET = '1' then
			Qn <= '1';
		elsif CLR = '1' then
			Qn <= '0';
		else
			Qn <= Qp;
		end if;
		QOUT <= Qp;
	end process Combinational;
	Sequential : process(RST, CLK)
	begin
		if RST = '0' then
			Qp <= '0';
		elsif CLK'event and CLK = '1' then
			Qp <= Qn;
		end if;
	end process Sequential;
end Behavioral;