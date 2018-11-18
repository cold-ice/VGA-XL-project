LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY STROBE_GEN IS

GENERIC (DIVIDER			: INTEGER);
PORT(		CLOCK_50  		: IN  STD_LOGIC;
			EN					: IN STD_LOGIC;
			STROBE			: OUT STD_LOGIC
);

END STROBE_GEN;

ARCHITECTURE behavioural OF STROBE_GEN IS

SIGNAL STROBE_BUFFER, FLAG : STD_LOGIC :='0';

BEGIN

STROBE <= STROBE_BUFFER;

Strobe_gen: PROCESS(EN, CLOCK_50)
BEGIN
IF(EN='0') THEN
	STROBE_BUFFER <= '0';
ELSIF(FALLING_EDGE(CLOCK_50)) THEN
	STROBE_BUFFER <=  NOT STROBE_BUFFER;
END IF;

END PROCESS;

END behavioural;