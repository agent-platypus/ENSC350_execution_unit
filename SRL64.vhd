library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

Entity SRL64 is
Generic ( N : natural := 64 );
Port ( X : in std_logic_vector( N-1 downto 0 );
Y : out std_logic_vector( N-1 downto 0 );
ShiftCount : in unsigned(integer(ceil(log2(real(N))))-1 downto 0 ) );
End Entity SRL64;




architecture behavior of SRL64 is
signal mux1, mux2: unsigned(N-1 downto 0);

--signal x_start, y_end:unsigned(N-1 downto 0);

begin
--x_start <= unsigned(X);



process(ShiftCount, X)

begin

	if ShiftCount(5 downto 4) = "00" then
	--shift 0
	mux1 <= unsigned(X);
	elsif ShiftCount(5 downto 4) = "01" then
	--shift 16
	mux1 <= shift_right(unsigned(X),16);
	elsif ShiftCount(5 downto 4) = "10" then
	--shift 32
	mux1 <= shift_right(unsigned(X),32);
	elsif ShiftCount(5 downto 4) = "11" then
	--shift 48
	mux1 <= shift_right(unsigned(X),48);
	else
	mux1 <= unsigned(X);
	end if;
end process;
	

process(ShiftCount, mux1)

begin
	if ShiftCount(3 downto 2) = "00" then
	--shift 0
	mux2 <= mux1;
	elsif ShiftCount(3 downto 2) = "01" then
	--shift 4
	mux2 <= shift_right(mux1,4);
	elsif ShiftCount(3 downto 2) = "10" then
	--shift 8
	mux2 <= shift_right(mux1,8);
	elsif ShiftCount(3 downto 2) = "11" then
	--shift 12
	mux2 <= shift_right(mux1,12);
	else
	mux2 <= mux1;
	end if;
end process;

process(ShiftCount, mux2)

begin
	if ShiftCount(1 downto 0) = "00" then
	--shift 0
	Y <= std_logic_vector(mux2);
	elsif ShiftCount(1 downto 0) = "01" then
	--shift 1
	Y <= std_logic_vector(shift_right(mux2,1));
	elsif ShiftCount(1 downto 0) = "10" then
	--shift 2
	Y <= std_logic_vector(shift_right(mux2,2));
	elsif ShiftCount(1 downto 0) = "11" then
	--shift 3
	Y <= std_logic_vector(shift_right(mux2,3));
	else
	Y <= std_logic_vector(mux2);
	end if;

	end process;
--	Y <= std_logic_vector(y_end);
end behavior;