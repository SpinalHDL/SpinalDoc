process(clk,reset)
begin
	if reset = '1' then
		...
	elsif rising_edge(clk) then
		...
	end if;
end process;


architecture arch of something is
  signal sub_condA : std_logic;
  signal sub_condB : std_logic;
  signal sub_result : std_logic;
  
  component SubComponent
    port(condA  : in std_logic;
	     condB  : in std_logic;
	     result : in std_logic);
  end component;
begin
  sub : SubComponent 
	port map (condA  => sub_condA 
	          condB  => sub_condB 
	          result => sub_result);
end arch;


