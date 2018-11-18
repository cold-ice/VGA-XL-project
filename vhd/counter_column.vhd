LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY COUNTER_COLUMN IS

PORT(		STROBE  			: IN  STD_LOGIC;
			EN					: IN STD_LOGIC;
			CL					: IN STD_LOGIC;
			COUNT_X			: OUT INTEGER RANGE 0 TO 797
);

END COUNTER_COLUMN;

ARCHITECTURE behavioural OF COUNTER_COLUMN IS

SIGNAL COUNT_BUFFER : INTEGER RANGE 0 TO 797:=0;

BEGIN

COUNT_X <= COUNT_BUFFER;

Counter: PROCESS(STROBE, EN, CL)
BEGIN
	IF(EN='1') THEN
		IF(FALLING_EDGE(STROBE)) THEN
			IF(COUNT_BUFFER<797-1) THEN 
				COUNT_BUFFER <= COUNT_BUFFER+1;
			ELSE
				COUNT_BUFFER<=0;
				-- Giunti a 797 il contatore va resettato a 0 perche' e' trascorso esattamente
				-- il tempo totale di scansione di una riga
			END IF;
		END IF;
	ELSIF(CL='1') THEN
		COUNT_BUFFER <= 0;
	END IF;
END PROCESS;

END behavioural;