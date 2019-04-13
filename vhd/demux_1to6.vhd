library ieee;
use ieee.std_logic_1164.all;

entity demux_1to6 is
  generic(N : integer);
  port (
    sel : in  std_logic_vector(2 downto 0);
    y   : in  std_logic_vector(N-1 downto 0);
    a   : out std_logic_vector(N-1 downto 0);
    b   : out std_logic_vector(N-1 downto 0);
    c   : out std_logic_vector(N-1 downto 0);
    d   : out std_logic_vector(N-1 downto 0);
    e   : out std_logic_vector(N-1 downto 0);
    f   : out std_logic_vector(N-1 downto 0)
    );
end entity demux_1to6;

architecture rtl of demux_1to6 is

begin

  DEMUX_PROC : process (sel, y)
  begin
    case sel is
      when "000" =>
        a <= y;
      when "001" =>
        b <= y;
      when "010" =>
        c <= y;
      when "011" =>
        d <= y;
      when "100" =>
        e <= y;
      when "101" =>
        f <= y;
      when others =>
        a <= (others => '0');
        b <= (others => '0');
        c <= (others => '0');
        d <= (others => '0');
        e <= (others => '0');
        f <= (others => '0');
    end case;
  end process DEMUX_PROC;

end architecture rtl;
