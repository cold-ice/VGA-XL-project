Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity decoder is
port(	input: 	in  std_logic_vector(3 downto 0);
		output:	out std_logic_vector(0 to 6));
end decoder;

Architecture func of decoder is
begin

output(0) <= (input(2) XOR input(0)) and (input(1) NOR input(3)) ;
output(1) <= (not input(3) and input(2)) and (input(1) XOR input(0));
output(2) <= (input(3) NOR input (2)) and (not input(0) and input(1));
output(3) <= (((input(2) XOR input(0)) and (input(1) NOR input(3))) or (not input(3) and input(2) and input(1) and input(0)));
output(4) <= (((not input(3) and input(2)) and not(input(1) and not input(0))) or ((input(3) nor input(2)) and input(0)) or (input(3) and input(0) and not input(2) and not input(1)) );
output(5) <= ((not input(3) and not input(2) and (input(1) or input(0))) or (not input(3) and input(2) and input(1) and input(0)));
output(6) <= ((not input(3) and not input(2) and not input(1)) or (not input(3) and input(2) and input(1) and input(0)));
 
end func;