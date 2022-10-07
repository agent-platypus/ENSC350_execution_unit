library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.ALL;

Entity ExecUnit is
	Generic ( N : natural := 64 );
	Port ( A, B : in std_logic_vector( N-1 downto 0 );
		FuncClass, LogicFN, ShiftFN : in std_logic_vector( 1 downto 0 );
	AddnSub, ExtWord : in std_logic := '0';
				Y : out std_logic_vector( N-1 downto 0 );
		Zero, AltB, AltBu : out std_logic );
End Entity ExecUnit;

architecture rtl of ExecUnit is

----------------LOGIC UNIT---------------------
component LogicUnit
	Generic ( N : natural := 64 );
	Port ( A, B : in std_logic_vector( N-1 downto 0 );
	Y : out std_logic_vector( N-1 downto 0 );
	LogicFN : in std_logic_vector( 1 downto 0 ) );
end component;
----*************************--------------------

--------ADDER------------------------
component ArithUnit
	Generic ( N : natural := 64 );
	Port ( A, B : in std_logic_vector( N-1 downto 0 );
		 AddY, Y : out std_logic_vector( N-1 downto 0 );
		
	-- Control signals
		AddnSub, ExtWord : in std_logic := '0';
		
	-- Status signals
		Cout, Ovfl, Zero, AltB, AltBu : out std_logic );
end component;
--*********************-----------------------

-------------------SHIFTER---------------
component ShiftUnit
	Generic ( N : natural := 64 );
	Port ( 	A, B, C : in std_logic_vector( N-1 downto 0 );
	--C comes from the adder unit---
	---- A to be shifted by count from B---
						Y : out std_logic_vector( N-1 downto 0 );
				ShiftFN : in std_logic_vector( 1 downto 0 );
				ExtWord : in std_logic );
end component;
--*********************------------------

------arith unit------- output
signal AddY_sig: std_logic_vector(N-1 downto 0);

-----control signals-------
signal ExtWord_sig: std_logic;

----OPERAND SIGNALS----------
signal A_sig, B_sig, C_sig: std_logic_vector(N-1 downto 0);

----******-------------
signal Shift_out: std_logic_vector(N-1 downto 0);
signal Logic_out: std_logic_vector(N-1 downto 0);

-----concatenate
signal zero63: std_logic_vector(N-2 downto 0);
------------------

-------for the Y, cout and ovfl output of arithunit---------
signal garbage1: std_logic_vector(N-1 downto 0);

signal garbage2,garbage3: std_logic;
--------------------

signal AltB_sig, AltBu_sig: std_logic;

begin
A_sig <= A;
B_sig <= B;
ExtWord_sig <= ExtWord;
zero63 <= (others =>'0');

shift: ShiftUnit
generic map(N => N)
port map(A => A_sig, B => B_sig, C => Addy_Sig, Y => Shift_out, ShiftFN => ShiftFN, ExtWord => ExtWord_sig);

math: ArithUnit
generic map(N => N)
port map(A => A_sig, B => B_sig, AddY => AddY_sig, Y => garbage1, AddnSub => AddnSub, ExtWord => ExtWord_sig,
				Cout => garbage2, Ovfl => garbage3, AltB => AltB_sig, AltBu => AltBu_sig, Zero => Zero);

logitech: LogicUnit
generic map(N => N)
port map(A => A_sig, B => B_sig, Y => Logic_out, LogicFN => LogicFN);

func_mox: process(FuncClass, Logic_out, Shift_Out)
	begin
		if FuncClass = "00" then 
			Y <= Shift_Out;
		elsif FuncClass = "01" then 
			Y <= Logic_Out;
		elsif FuncClass = "10" then 
			Y <= zero63 & AltB_sig;--ATLB ???---;
		elsif FuncClass = "11" then
			Y <= zero63 & AltBu_sig;---ATLBU ???-----;
			else
			Y <= Shift_Out;
	end if;	
	end process;
	
AltB <= AltB_sig;
AltBu <= AltBu_sig;
end rtl;