LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ADDER IS

PORT(		DATA_IN0  		: IN SIGNED(15 downto 0);
			DATA_IN1  		: IN SIGNED(15 downto 0);
			C0					: IN STD_LOGIC;
			DATA_OUT			: OUT SIGNED(15 downto 0)
);

END ADDER;

ARCHITECTURE behavioural OF ADDER IS

SIGNAL SUM, SUBTRACTION : SIGNED(15 downto 0);

BEGIN

WITH C0 SELECT DATA_OUT<=	SUM WHEN '0',
									SUBTRACTION WHEN '1',
									SUM WHEN others;
									
SUM<=DATA_IN0 + DATA_IN1;
SUBTRACTION<=DATA_IN0 - DATA_IN1;

END behavioural;