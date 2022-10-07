library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

Entity LogicUnit is
Generic ( N : natural := 64 );
Port ( A, B : in std_logic_vector( N-1 downto 0 );
			 Y : out std_logic_vector( N-1 downto 0 );
	 LogicFN : in std_logic_vector( 1 downto 0 ) );
End Entity LogicUnit;

architecture rtl of LogicUnit is

begin

process(LogicFN, B, A)
begin
	if LogicFN = "00" then
		Y <= B;
	elsif LogicFN = "01" then
		Y <= A XOR B;
	elsif LogicFN = "10" then
		Y <= A OR B;
	elsif LogicFN = "11" then
		Y <= A AND B;
	else 
		Y <= B;
	end if;
end process;

end rtl;