LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY REG_16bit IS

PORT(		DATA_IN  		: IN STD_LOGIC_VECTOR(15 downto 0);
			CLOCK_50			: IN STD_LOGIC;
			EN					: IN STD_LOGIC;
			CL					: IN STD_LOGIC;
			DATA_OUT			: OUT STD_LOGIC_VECTOR(15 downto 0)
);

END REG_16bit;

ARCHITECTURE behavioural OF REG_16bit IS

BEGIN

reg: PROCESS(CLOCK_50, CL)
BEGIN
IF(CL='1') THEN
	DATA_OUT<=(others=>'0');
ELSIF(RISING_EDGE(CLOCK_50)) THEN
	IF(EN='1') THEN
		DATA_OUT<=DATA_IN;
	END IF;
END IF;
END PROCESS;

END behavioural;