----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2026 12:54:01 PM
-- Design Name: 
-- Module Name: display - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Display is
--  Port ( );
    port(
        code  : in std_logic_vector (3 downto 0);
        seg   : out std_logic_vector (6 downto 0)
    );
end Display;

architecture behavioral of Display is

begin
    with code select seg <= "1000000" when "0000",  -- 0
                            "1111001" when "0001",  -- 1
                            "0100100" when "0010",  -- 2
                            "0110000" when "0011",  -- 3
                            "0011001" when "0100",  -- 4
                            "0010010" when "0101",  -- 5
                            "0000010" when "0110",  -- 6
                            "1111000" when "0111",  -- 7
                            "0000000" when "1000",  -- 8
                            "0010000" when "1001",  -- 9
                            "1111111" when "1111",  -- apagado
                            "1111111" when others;
end behavioral;