LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY COUNTER_ROW IS

PORT(		STROBE  			: IN  STD_LOGIC;
			EN					: IN STD_LOGIC;
			CL					: IN STD_LOGIC;
			COUNT_Y			: OUT INTEGER RANGE 0 TO 525
);

END COUNTER_ROW;

ARCHITECTURE behavioural OF COUNTER_ROW IS

SIGNAL COUNT_BUFFER : INTEGER RANGE 0 TO 525:=0;

BEGIN

COUNT_Y <= COUNT_BUFFER;

Counter: PROCESS(STROBE, EN, CL)
BEGIN
	IF(EN='1') THEN
		IF(FALLING_EDGE(STROBE)) THEN
			IF(COUNT_BUFFER<525-1) THEN
				COUNT_BUFFER <= COUNT_BUFFER+1;
			ELSE
				COUNT_BUFFER<=0;
				-- Giunti a 525 il contatore va resettato a 0 perche' e' trascorso esattamente
				-- il tempo totale di scansione dello schermo
			END IF;
		END IF;
	ELSIF(CL='1') THEN
		COUNT_BUFFER <= 0;		
	END IF;
END PROCESS;

END behavioural;