Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

Entity CounterM10 is
	port(
	RST : in std_logic;
	CLK : in std_logic;
	ENI : in std_logic;
	ENO : out std_logic;
	CNT : out std_logic_vector(3 downto 0)
	);
end CounterM10;

Architecture Behavioral of CounterM10 is
signal Cp, Cn : std_logic_vector(3 downto 0);
begin
	Combinational : process(Cp, ENI)
	begin
		if ENI = '1' then
			if Cp = "1001" then
				Cn <= "0000";
				ENO <= '1';
			else
				Cn <= Cp + 1;
				ENO <= '0';
			end if;
		else
			Cn <= Cp;
			ENO <= '0';
		end if;
		CNT <= Cp;
	end process Combinational;
	Sequential : process(RST, CLK)
	begin
		if RST = '0' then
			Cp <= "0000";
		elsif CLK'event and CLK = '1' then
			Cp <= Cn;
		end if;
	end process Sequential;
end Behavioral;